import Foundation

struct AppUser: Codable, Identifiable {
    let id: String
    let name: String
    let email: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
    }
}

struct UserCreate: Encodable {
    let name: String
    let email: String?
}
