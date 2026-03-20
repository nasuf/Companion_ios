import Foundation
import SwiftUI

struct Memory: Codable, Identifiable {
    let id: String
    let userId: String
    let type: String?
    let source: String?
    let level: Int
    let content: String
    let summary: String?
    let importance: Double
    let createdAt: String
    var similarity: Double?

    enum CodingKeys: String, CodingKey {
        case id, type, source, level, content, summary, importance, similarity
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

    var levelColor: Color {
        switch level {
        case 1: return .red
        case 2: return .orange
        default: return .blue
        }
    }

    /// English type → Chinese display label (handles pipe-separated values like "identity|emotion")
    var typeLabel: String {
        guard let type, !type.isEmpty else { return "" }
        return type.split(separator: "|").map { part in
            switch part.trimmingCharacters(in: .whitespaces) {
            case "identity": return "身份"
            case "emotion": return "情绪"
            case "preference": return "偏好"
            case "life": return "生活"
            case "thought": return "思维"
            case "consolidated": return "合并"
            default: return String(part)
            }
        }.joined(separator: "·")
    }

    /// Source display label
    var sourceLabel: String {
        switch source {
        case "ai": return "TA的记忆"
        default: return "关于你的记忆"
        }
    }

    var isAIMemory: Bool {
        source == "ai"
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
