import Foundation

struct Conversation: Codable, Identifiable {
    let id: String
    let userId: String
    let agentId: String
    let title: String?
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case userId = "user_id"
        case agentId = "agent_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ConversationCreate: Encodable {
    let userId: String
    let agentId: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case agentId = "agent_id"
    }
}
