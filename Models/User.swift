import Foundation

struct AppUser: Decodable, Identifiable {
    let id: String
    let name: String
    let email: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, username, email
        case createdAt = "created_at"
    }

    init(id: String, name: String, email: String?, createdAt: String) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
            ?? container.decode(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
    }
}

struct AuthRegisterRequest: Encodable {
    let username: String
    let password: String
}

struct AuthResponse: Decodable {
    let token: String
    let userId: String
    let username: String
    let hasAgent: Bool
    let agentId: String?
    let agentName: String?
    let conversationId: String?

    enum CodingKeys: String, CodingKey {
        case token, username
        case userId = "user_id"
        case hasAgent = "has_agent"
        case agentId = "agent_id"
        case agentName = "agent_name"
        case conversationId = "conversation_id"
    }
}
