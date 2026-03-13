import Foundation

enum ConversationService {
    static func create(userId: String, agentId: String) async throws -> Conversation {
        try await APIClient.shared.request(
            method: "POST",
            path: "/conversations",
            body: ConversationCreate(userId: userId, agentId: agentId)
        )
    }

    static func list(userId: String) async throws -> [Conversation] {
        try await APIClient.shared.request(
            method: "GET",
            path: "/conversations",
            queryItems: [URLQueryItem(name: "user_id", value: userId)]
        )
    }

    static func get(id: String) async throws -> Conversation {
        try await APIClient.shared.request(
            method: "GET",
            path: "/conversations/\(id)"
        )
    }

    static func delete(id: String) async throws {
        try await APIClient.shared.requestVoid(
            method: "DELETE",
            path: "/conversations/\(id)"
        )
    }
}
