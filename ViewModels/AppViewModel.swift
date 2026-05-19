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
        self.themeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "themeMode") ?? "") ?? .system
        self.locale = AppLocale(rawValue: UserDefaults.standard.string(forKey: "appLocale") ?? "") ?? .chinese
    }

    func initialize() async {
        let hasUser = await ensureUser()

        if hasUser, let agentId, !agentId.isEmpty {
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
                clearAgentState()
            }
        }

        isInitialized = true
    }

    @discardableResult
    func ensureUser() async -> Bool {
        if !userId.isEmpty, (authToken ?? "").isEmpty {
            clearSession()
        }

        if !userId.isEmpty {
            do {
                let _ = try await UserService.get(id: userId)
            } catch {
                // User no longer exists (DB was reset), clear everything
                clearSession()
            }
        }
        if userId.isEmpty {
            do {
                let user = try await UserService.create(name: "User_\(Int.random(in: 1000...9999))")
                userId = user.id
                authToken = UserDefaults.standard.string(forKey: "authToken")
                error = nil
                return true
            } catch {
                self.error = "用户初始化失败：\(error.localizedDescription)。请确认后端服务已启动并可访问。"
                return false
            }
        }

        error = nil
        return true
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
            self.error = "删除 agent 失败：\(error.localizedDescription)"
        }

        isDeletingAgent = false
    }

    private func clearSession() {
        userId = ""
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
