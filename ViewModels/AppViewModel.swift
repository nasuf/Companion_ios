import SwiftUI

@MainActor
@Observable
final class AppViewModel {
    var userId: String {
        didSet { UserDefaults.standard.set(userId, forKey: "userId") }
    }
    var agentId: String? {
        didSet { UserDefaults.standard.set(agentId, forKey: "agentId") }
    }
    var agentName: String? {
        didSet { UserDefaults.standard.set(agentName, forKey: "agentName") }
    }
    var conversationId: String? {
        didSet { UserDefaults.standard.set(conversationId, forKey: "conversationId") }
    }
    var authToken: String? {
        didSet { UserDefaults.standard.set(authToken, forKey: "authToken") }
    }
    var username: String {
        didSet { UserDefaults.standard.set(username, forKey: "username") }
    }
    var role: String {
        didSet { UserDefaults.standard.set(role, forKey: "role") }
    }

    var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode") }
    }
    var locale: AppLocale {
        didSet { UserDefaults.standard.set(locale.rawValue, forKey: "appLocale") }
    }

    var isInitialized = false
    var isProvisioningAgent = false
    var isDeletingAgent = false
    var agentDeletionStats: [String: Int]?
    var provisionProgress: AgentProvisionStatus?
    var error: String?

    private var provisionPollingTask: Task<Void, Never>?

    var hasAuthenticatedSession: Bool {
        !userId.isEmpty && !(authToken ?? "").isEmpty
    }

    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    init() {
        self.userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        self.agentId = UserDefaults.standard.string(forKey: "agentId")
        self.agentName = UserDefaults.standard.string(forKey: "agentName")
        self.conversationId = UserDefaults.standard.string(forKey: "conversationId")
        self.authToken = UserDefaults.standard.string(forKey: "authToken")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.role = UserDefaults.standard.string(forKey: "role") ?? "user"
        self.themeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "themeMode") ?? "") ?? .system
        self.locale = AppLocale(rawValue: UserDefaults.standard.string(forKey: "appLocale") ?? "") ?? .chinese
    }

    func initialize() async {
        if let authToken, !authToken.isEmpty {
            do {
                let auth = try await UserService.me()
                applyAuth(auth)
                await refreshAgentSessionIfNeeded()
            } catch {
                clearSession()
            }
        }

        isInitialized = true
    }

    @discardableResult
    func ensureUser() async -> Bool {
        guard hasAuthenticatedSession else {
            error = "请先登录或注册，再创建你的 AI 伙伴。"
            return false
        }

        do {
            let auth = try await UserService.me()
            applyAuth(auth)
            error = nil
            return true
        } catch {
            clearSession()
            self.error = "登录状态已失效，请重新登录。"
            return false
        }
    }

    func applyAuthenticatedSession(_ response: AuthResponse) async {
        applyAuth(response)
        await refreshAgentSessionIfNeeded()
        error = nil
    }

    func signOut() {
        clearSession()
        error = nil
    }

    private func applyAuth(_ response: AuthResponse) {
        let previousUserId = userId
        authToken = response.token
        userId = response.userId
        username = response.username
        role = response.role

        if let responseAgentId = response.agentId, !responseAgentId.isEmpty {
            agentId = responseAgentId
            agentName = response.agentName
            conversationId = response.conversationId
        } else if previousUserId != response.userId {
            clearAgentState()
        }
    }

    private func refreshAgentSessionIfNeeded() async {
        guard let agentId, !agentId.isEmpty else { return }
        do {
            let _ = try await AgentService.get(id: agentId)
            if let progress = try? await AgentService.getProvisionStatus(agentId: agentId),
               !progress.isComplete {
                provisionProgress = progress
                isProvisioningAgent = true
                startProvisionPolling()
            } else {
                await ensureConversation()
                if conversationId == nil {
                    markProvisionFinalizationFailed(agentId: agentId)
                }
            }
        } catch {
            if let progress = try? await AgentService.getProvisionStatus(agentId: agentId),
               !progress.isComplete {
                provisionProgress = progress
                isProvisioningAgent = true
                startProvisionPolling()
            } else {
                clearAgentState()
            }
        }
    }

    /// Find existing conversation or create a new one for the current agent.
    func ensureConversation() async {
        guard let agentId, !agentId.isEmpty, !userId.isEmpty else { return }

        // If we already have a valid conversationId, verify it
        if let convId = conversationId, !convId.isEmpty {
            do {
                let _ = try await ConversationService.get(id: convId)
                return
            } catch {
                // Invalid, will create new
            }
        }

        // Try to find an existing conversation
        do {
            let conversations = try await ConversationService.list(userId: userId)
            if let existing = conversations.first(where: { $0.agentId == agentId }) {
                conversationId = existing.id
                return
            }
        } catch { }

        // Create new conversation
        do {
            let conversation = try await ConversationService.create(userId: userId, agentId: agentId)
            conversationId = conversation.id
        } catch {
            self.error = error.localizedDescription
        }
    }

    func beginAgentProvisioning(agent: Agent) {
        agentId = agent.id
        agentName = agent.name
        conversationId = nil
        agentDeletionStats = nil
        provisionProgress = AgentProvisionStatus(
            agentId: agent.id,
            status: "provisioning",
            stage: "initializing",
            percent: 0,
            message: "正在初始化...",
            current: nil,
            total: nil
        )
        isProvisioningAgent = true
        startProvisionPolling()
    }

    func startProvisionPolling() {
        guard let agentId, !agentId.isEmpty else { return }
        if provisionPollingTask != nil { return }

        provisionPollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                await self.pollProvisionStatus(agentId: agentId)

                if Task.isCancelled { return }
                if let progress = self.provisionProgress, progress.isComplete || progress.isFailed {
                    return
                }

                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    func retryProvisionPolling() {
        provisionPollingTask?.cancel()
        provisionPollingTask = nil
        error = nil
        isProvisioningAgent = true
        startProvisionPolling()
    }

    private func pollProvisionStatus(agentId: String) async {
        do {
            let progress = try await AgentService.getProvisionStatus(agentId: agentId)
            provisionProgress = progress

            if progress.isComplete {
                provisionPollingTask?.cancel()
                provisionPollingTask = nil
                await ensureConversation()
                if conversationId != nil {
                    isProvisioningAgent = false
                    provisionProgress = nil
                } else {
                    markProvisionFinalizationFailed(agentId: agentId)
                }
            } else if progress.isFailed {
                provisionPollingTask?.cancel()
                provisionPollingTask = nil
                isProvisioningAgent = true
            } else {
                isProvisioningAgent = true
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func markProvisionFinalizationFailed(agentId: String) {
        isProvisioningAgent = true
        provisionProgress = AgentProvisionStatus(
            agentId: agentId,
            status: "provisioning",
            stage: "failed",
            percent: 100,
            message: "AI 伙伴已创建，但对话入口创建失败，请重试检查。",
            current: nil,
            total: nil
        )
    }

    func deleteAgent() async {
        guard let agentId, !isDeletingAgent else { return }
        let deletingAgentId = agentId

        isDeletingAgent = true
        error = nil
        agentDeletionStats = nil

        do {
            let response = try await AgentService.delete(id: deletingAgentId)
            guard response.ok else {
                throw APIError.httpError(500, "Agent deletion did not complete")
            }
            agentDeletionStats = response.stats
            clearAgentState()
        } catch {
            if shouldResetLocalSessionForUnavailableDelete(error) {
                resetLocalSessionForRebuild()
            } else {
                self.error = Self.userFacingDeletionError(error)
            }
        }

        isDeletingAgent = false
    }

    private func shouldResetLocalSessionForUnavailableDelete(_ error: Error) -> Bool {
        if case APIError.httpError(let code, _) = error {
            return code == 405
        }
        return false
    }

    private func resetLocalSessionForRebuild() {
        clearSession()
        error = "当前后端还没有加载移动端删除接口，已退出这次未完成的创建。你可以直接重新创建一个测试用户和 AI 伙伴；旧的失败记录需要重启后端后再清理。"
    }

    private static func userFacingDeletionError(_ error: Error) -> String {
        if case APIError.httpError(let code, _) = error {
            if code == 405 {
                return "当前后端还没有加载移动端删除接口。请重启后端服务后再点“删除重建”。"
            }
            if code == 401 || code == 403 {
                return "当前登录状态没有删除权限。请确认使用的是当前用户的移动端登录态。"
            }
            if code >= 500 {
                return "后端清理数据时出错了。可以稍后重试，或查看后端日志确认删除任务是否完成。"
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotConnectToHost, .notConnectedToInternet, .networkConnectionLost:
                return "暂时连不上后端服务。请确认后端正在运行，再点“删除重建”。"
            default:
                break
            }
        }

        return "删除没有完成。请稍后重试，或确认后端服务状态。"
    }

    private func clearSession() {
        userId = ""
        username = ""
        role = "user"
        clearAgentState()
        agentDeletionStats = nil
        authToken = nil
    }

    private func clearAgentState() {
        agentId = nil
        agentName = nil
        conversationId = nil
        isProvisioningAgent = false
        isDeletingAgent = false
        provisionProgress = nil
        provisionPollingTask?.cancel()
        provisionPollingTask = nil
    }
}

enum ThemeMode: String, CaseIterable {
    case system, light, dark

    var label: String {
        switch self {
        case .system: return String(localized: "跟随系统")
        case .light: return String(localized: "浅色模式")
        case .dark: return String(localized: "深色模式")
        }
    }
}

enum AppLocale: String, CaseIterable {
    case chinese = "zh-Hans"
    case english = "en"

    var label: String {
        switch self {
        case .chinese: return "中文"
        case .english: return "English"
        }
    }
}
