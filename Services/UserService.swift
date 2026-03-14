import Foundation

enum UserService {
    static func create(name: String) async throws -> AppUser {
        try await APIClient.shared.request(
            method: "POST",
            path: "/users",
            body: UserCreate(name: name, email: nil)
        )
    }

    static func get(id: String) async throws -> AppUser {
        try await APIClient.shared.request(
            method: "GET",
            path: "/users/\(id)"
        )
    }

    static func getPortrait(userId: String, agentId: String) async throws -> PortraitResponse {
        try await APIClient.shared.request(
            method: "GET",
            path: "/users/\(userId)/portrait",
            queryItems: [URLQueryItem(name: "agent_id", value: agentId)]
        )
    }
}

struct PortraitResponse: Decodable {
    let portrait: String
}
