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
