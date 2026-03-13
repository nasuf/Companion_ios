import Foundation

enum Gender: String, CaseIterable {
    case male, female, random

    var label: String {
        switch self {
        case .male: return String(localized: "男生")
        case .female: return String(localized: "女生")
        case .random: return String(localized: "随机")
        }
    }

    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .random: return "sparkles"
        }
    }
}

struct PersonalityDimension: Identifiable {
    let id: String
    let name: String
    let lowLabel: String
    let highLabel: String
    var value: Double = 0.5
}

@Observable
final class OnboardingViewModel {
    var currentStep = 0
    var gender: Gender = .random
    var name = ""
    var isCreating = false
    var error: String?

    var dimensions: [PersonalityDimension] = [
        PersonalityDimension(id: "liveliness", name: String(localized: "活泼度"),
                             lowLabel: String(localized: "安静内敛"), highLabel: String(localized: "外向活跃")),
        PersonalityDimension(id: "rationality", name: String(localized: "理性度"),
                             lowLabel: String(localized: "感性直觉"), highLabel: String(localized: "逻辑分析")),
        PersonalityDimension(id: "empathy", name: String(localized: "感性度"),
                             lowLabel: String(localized: "冷静客观"), highLabel: String(localized: "温柔共情")),
        PersonalityDimension(id: "planning", name: String(localized: "计划度"),
                             lowLabel: String(localized: "随性而为"), highLabel: String(localized: "条理规划")),
        PersonalityDimension(id: "spontaneity", name: String(localized: "随性度"),
                             lowLabel: String(localized: "严谨自律"), highLabel: String(localized: "自由洒脱")),
        PersonalityDimension(id: "imagination", name: String(localized: "脑洞度"),
                             lowLabel: String(localized: "务实落地"), highLabel: String(localized: "天马行空")),
        PersonalityDimension(id: "humor", name: String(localized: "幽默度"),
                             lowLabel: String(localized: "严肃认真"), highLabel: String(localized: "风趣幽默")),
    ]

    /// Computed pronoun based on selected gender
    var pronoun: String {
        switch gender {
        case .male: return "他"
        case .female: return "她"
        case .random: return "TA"
        }
    }

    func randomizeAll() {
        for i in dimensions.indices {
            dimensions[i].value = Double.random(in: 0...1)
        }
    }

    private func dimValue(_ id: String) -> Double {
        dimensions.first(where: { $0.id == id })?.value ?? 0.5
    }

    var bigFivePersonality: [String: Double] {
        let openness = (dimValue("imagination") + dimValue("spontaneity")) / 2
        let conscientiousness = dimValue("planning")
        let extraversion = (dimValue("liveliness") + dimValue("humor")) / 2
        let agreeableness = dimValue("empathy")
        let neuroticism = 1.0 - dimValue("rationality")
        return [
            "openness": openness,
            "conscientiousness": conscientiousness,
            "extraversion": extraversion,
            "agreeableness": agreeableness,
            "neuroticism": neuroticism,
        ]
    }

    func createAgent(appViewModel: AppViewModel) async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = String(localized: "请输入名字")
            return
        }

        guard !appViewModel.userId.isEmpty else {
            error = "用户未初始化，请重启应用"
            return
        }

        isCreating = true
        error = nil

        do {
            let resolvedGender: String
            if gender == .random {
                resolvedGender = Bool.random() ? "male" : "female"
            } else {
                resolvedGender = gender.rawValue
            }

            let agent = try await AgentService.create(
                name: name.trimmingCharacters(in: .whitespaces),
                userId: appViewModel.userId,
                personality: bigFivePersonality,
                values: ["gender": resolvedGender]
            )

            let conversation = try await ConversationService.create(
                userId: appViewModel.userId,
                agentId: agent.id
            )

            appViewModel.agentId = agent.id
            appViewModel.agentName = agent.name
            appViewModel.conversationId = conversation.id
        } catch {
            self.error = error.localizedDescription
        }

        isCreating = false
    }
}
