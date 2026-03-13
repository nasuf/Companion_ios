import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct Message: Codable, Identifiable {
    let id: String
    let conversationId: String
    let role: MessageRole
    let content: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, role, content
        case conversationId = "conversation_id"
        case createdAt = "created_at"
    }
}

extension Message {
    static func userMessage(conversationId: String, content: String) -> Message {
        Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .user,
            content: content,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    static func assistantPlaceholder(conversationId: String) -> Message {
        Message(
            id: UUID().uuidString,
            conversationId: conversationId,
            role: .assistant,
            content: "",
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
