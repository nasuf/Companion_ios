import Foundation
import SwiftUI

struct BoundaryStatus: Decodable, Equatable {
    let patience: Int
    let zone: String

    var zoneColor: Color {
        switch zone {
        case "blocked": return .red
        case "low": return .orange
        case "medium": return .yellow
        default: return .green
        }
    }

    var zoneTone: String {
        switch zone {
        case "blocked": return "拉黑"
        case "low": return "不满"
        case "medium": return "微恼"
        default: return "正常"
        }
    }
}

enum BoundaryService {
    static func get(agentId: String, userId: String) async throws -> BoundaryStatus {
        try await APIClient.shared.request(
            method: "GET",
            path: "/boundary/\(agentId)/\(userId)"
        )
    }
}
