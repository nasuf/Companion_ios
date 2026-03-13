import SwiftUI

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

    var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode") }
    }
    var locale: AppLocale {
        didSet { UserDefaults.standard.set(locale.rawValue, forKey: "appLocale") }
    }

    var isInitialized = false
    var error: String?

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
        self.themeMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "themeMode") ?? "") ?? .system
        self.locale = AppLocale(rawValue: UserDefaults.standard.string(forKey: "appLocale") ?? "") ?? .chinese
    }

    func initialize() async {
        // Verify existing user or create new one
        if !userId.isEmpty {
            do {
                let _ = try await UserService.get(id: userId)
            } catch {
                // User no longer exists (DB was reset), clear everything
                userId = ""
                agentId = nil
                agentName = nil
                conversationId = nil
            }
        }
        if userId.isEmpty {
            do {
                let user = try await UserService.create(name: "User_\(Int.random(in: 1000...9999))")
                userId = user.id
            } catch {
                self.error = error.localizedDescription
            }
        }

        if let agentId, !agentId.isEmpty {
            do {
                let _ = try await AgentService.get(id: agentId)
                // Ensure we have a conversation
                await ensureConversation()
            } catch {
                self.agentId = nil
                self.agentName = nil
                self.conversationId = nil
            }
        }

        isInitialized = true
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

    func deleteAgent() async {
        guard let agentId else { return }
        do {
            try await AgentService.delete(id: agentId)
        } catch {
            // Agent may already be gone, continue cleanup
        }
        self.agentId = nil
        self.agentName = nil
        self.conversationId = nil
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
