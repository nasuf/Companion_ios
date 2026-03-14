import Foundation

enum IntimacyService {
    static func get(agentId: String, userId: String) async throws -> IntimacyData {
        try await APIClient.shared.request(
            method: "GET",
            path: "/intimacy/\(agentId)/\(userId)"
        )
    }
}
