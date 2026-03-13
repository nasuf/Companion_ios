import Foundation

@Observable
final class EmotionViewModel {
    var currentEmotion: EmotionState?
    var timeline: [EmotionTimelineEntry] = []
    var isLoading = false
    var error: String?

    private let agentId: String

    init(agentId: String) {
        self.agentId = agentId
    }

    func load() async {
        isLoading = true
        do {
            async let emotionResult = EmotionService.current(agentId: agentId)
            async let timelineResult = EmotionService.timeline(agentId: agentId)
            currentEmotion = try await emotionResult
            timeline = try await timelineResult
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
