import Foundation

struct Agent: Codable, Identifiable {
    let id: String
    let name: String
    let userId: String
    let personality: [String: Double]?
    let background: String?
    let values: [String: String]?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, personality, background, values
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

/// Response from GET /agents/{agent_id}/status
struct AgentStatus: Decodable {
    let activity: String
    let type: String
    let status: String   // "idle" | "busy" | "sleep"

    var statusIcon: String {
        switch status {
        case "sleep": return "moon.fill"
        case "busy":  return "clock.fill"
        default:      return "circle.fill"
        }
    }

}

struct AgentCreate: Encodable {
    let name: String
    let userId: String
    let personality: [String: Double]?
    let values: [String: String]?

    enum CodingKeys: String, CodingKey {
        case name, personality, values
        case userId = "user_id"
    }
}
