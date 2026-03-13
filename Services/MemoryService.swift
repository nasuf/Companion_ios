import Foundation

enum MemoryService {
    static func list(userId: String, level: Int? = nil) async throws -> [Memory] {
        var queryItems = [URLQueryItem(name: "user_id", value: userId)]
        if let level {
            queryItems.append(URLQueryItem(name: "level", value: String(level)))
        }
        return try await APIClient.shared.request(
            method: "GET",
            path: "/memories",
            queryItems: queryItems
        )
    }

    static func search(userId: String, query: String, topK: Int = 10) async throws -> [Memory] {
        try await APIClient.shared.request(
            method: "POST",
            path: "/memories/search",
            body: MemorySearchRequest(query: query, topK: topK),
            queryItems: [URLQueryItem(name: "user_id", value: userId)]
        )
    }
}
