import Foundation

struct ScheduleSlot: Decodable {
    let start: String
    let end: String
    let activity: String
    let type: String?
}

struct DaySchedule: Decodable, Identifiable {
    let date: String
    let schedule: [ScheduleSlot]
    var id: String { date }
}

struct ScheduleHistoryResponse: Decodable {
    let lifeOverview: String?
    let schedules: [DaySchedule]

    enum CodingKeys: String, CodingKey {
        case lifeOverview = "life_overview"
        case schedules
    }
}

enum ScheduleService {
    static func getHistory(agentId: String, days: Int = 30) async throws -> ScheduleHistoryResponse {
        try await APIClient.shared.request(
            method: "GET",
            path: "/agents/\(agentId)/schedule-history?days=\(days)"
        )
    }
}
