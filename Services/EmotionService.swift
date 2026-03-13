import Foundation

enum EmotionService {
    static func current(agentId: String) async throws -> EmotionState {
        try await APIClient.shared.request(
            method: "GET",
            path: "/emotions/\(agentId)/current"
        )
    }

    static func timeline(agentId: String, limit: Int = 50) async throws -> [EmotionTimelineEntry] {
        try await APIClient.shared.request(
            method: "GET",
            path: "/emotions/\(agentId)/timeline",
            queryItems: [URLQueryItem(name: "limit", value: String(limit))]
        )
    }
}
