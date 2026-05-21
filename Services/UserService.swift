import Foundation

enum UserService {
    static func create(name: String) async throws -> AppUser {
        let username = "\(sanitizeUsername(name))_\(UUID().uuidString.prefix(8))"
        let response = try await register(
            username: username,
            password: UUID().uuidString + UUID().uuidString
        )
        UserDefaults.standard.set(response.token, forKey: "authToken")
        return AppUser(
            id: response.userId,
            name: response.username,
            email: nil,
            createdAt: ""
        )
    }

    static func register(username: String, password: String) async throws -> AuthResponse {
        try await APIClient.shared.request(
            method: "POST",
            path: "/auth/register",
            body: AuthRegisterRequest(
                username: username,
                password: password
            )
        )
    }

    static func login(username: String, password: String) async throws -> AuthResponse {
        try await APIClient.shared.request(
            method: "POST",
            path: "/auth/login",
            body: AuthLoginRequest(username: username, password: password)
        )
    }

    static func me() async throws -> AuthResponse {
        try await APIClient.shared.request(
            method: "GET",
            path: "/auth/me"
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

private func sanitizeUsername(_ raw: String) -> String {
    let allowed = raw.filter { character in
        character.isLetter || character.isNumber || character == "_"
    }
    let fallback = allowed.isEmpty ? "User" : String(allowed.prefix(20))
    return fallback.count >= 2 ? fallback : "User_\(fallback)"
}
