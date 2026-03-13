import Foundation

struct EmotionState: Codable {
    let agentId: String
    let valence: Double
    let arousal: Double
    let dominance: Double
    let tone: String

    enum CodingKeys: String, CodingKey {
        case valence, arousal, dominance, tone
        case agentId = "agent_id"
    }
}

struct EmotionTimelineEntry: Codable, Identifiable {
    let timestamp: String
    let valence: Double
    let arousal: Double
    let dominance: Double
    let messagePreview: String

    var id: String { timestamp }

    enum CodingKeys: String, CodingKey {
        case timestamp, valence, arousal, dominance
        case messagePreview = "message_preview"
    }

    var date: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: timestamp) ?? ISO8601DateFormatter().date(from: timestamp)
    }
}
