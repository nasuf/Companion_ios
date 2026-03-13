import Foundation

struct Memory: Codable, Identifiable {
    let id: String
    let userId: String
    let type: String?
    let level: Int
    let content: String
    let summary: String?
    let importance: Double
    let createdAt: String
    var similarity: Double?

    enum CodingKeys: String, CodingKey {
        case id, type, level, content, summary, importance, similarity
        case userId = "user_id"
        case createdAt = "created_at"
    }

    var levelLabel: String {
        switch level {
        case 1: return String(localized: "核心记忆")
        case 2: return String(localized: "重要记忆")
        default: return String(localized: "普通记忆")
        }
    }
}

struct MemorySearchRequest: Encodable {
    let query: String
    let topK: Int

    enum CodingKeys: String, CodingKey {
        case query
        case topK = "top_k"
    }
}
