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
}
