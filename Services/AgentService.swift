import Foundation

enum AgentService {
    static func create(name: String, userId: String, personality: [String: Double], values: [String: String]? = nil) async throws -> Agent {
        try await APIClient.shared.request(
            method: "POST",
            path: "/agents",
            body: AgentCreate(name: name, userId: userId, personality: personality, values: values)
        )
    }

    static func list(userId: String) async throws -> [Agent] {
        try await APIClient.shared.request(
            method: "GET",
            path: "/agents",
            queryItems: [URLQueryItem(name: "user_id", value: userId)]
        )
    }

    static func get(id: String) async throws -> Agent {
        try await APIClient.shared.request(
            method: "GET",
            path: "/agents/\(id)"
        )
    }

    static func delete(id: String) async throws {
        try await APIClient.shared.requestVoid(
            method: "DELETE",
            path: "/agents/\(id)"
        )
    }
}
