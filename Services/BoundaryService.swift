import Foundation

struct BoundaryStatus: Decodable {
    let patience: Int
    let zone: String
}

enum BoundaryService {
    static func get(agentId: String, userId: String) async throws -> BoundaryStatus {
        try await APIClient.shared.request(
            method: "GET",
            path: "/boundary/\(agentId)/\(userId)"
        )
    }
}
