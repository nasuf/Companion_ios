import Foundation
import SwiftUI

/// Response from GET /intimacy/{agent_id}/{user_id}
struct IntimacyData: Decodable {
    let growthIntimacy: Double
    let topicIntimacy: Double
    let level: IntimacyLevel
    let topicDepth: TopicDepth

    enum CodingKeys: String, CodingKey {
        case growthIntimacy = "growth_intimacy"
        case topicIntimacy  = "topic_intimacy"
        case level
        case topicDepth     = "topic_depth"
    }
}

struct IntimacyLevel: Decodable {
    let level: String   // "L1" … "L5"
    let label: String   // "初识" … "挚友"
    let score: Double

    var badgeColor: Color {
        switch level {
        case "L5": return .pink
        case "L4": return .red
        case "L3": return .orange
        case "L2": return .yellow
        default:   return .gray
        }
    }

    /// SF Symbol name for the badge
    var symbolName: String {
        switch level {
        case "L5": return "heart.fill"
        case "L4": return "heart"
        case "L3": return "star.fill"
        case "L2": return "star"
        default:   return "leaf"
        }
    }
}

struct TopicDepth: Decodable {
    let depth: String
    let label: String
    let score: Double
}
