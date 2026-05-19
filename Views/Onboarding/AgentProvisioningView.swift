import SwiftUI

struct AgentProvisioningView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var localPercent = 0
    @State private var localMessage = "正在初始化..."
    @State private var tickerTask: Task<Void, Never>?

    private let llmBasePercent = 15
    private let llmTargetPercent = 70
    private let llmEstimatedSeconds: Double = 45
    private let rotatingMessages = [
        "正在塑造身份基础...",
        "正在编织生活经历...",
        "正在唤醒情绪记忆...",
        "正在确立价值观与思维...",
        "正在校对一致性..."
    ]

    var body: some View {
        ZStack {
            PrototypeBackground()

            VStack(spacing: 22) {
                statusGlyph

                VStack(spacing: 9) {
                    PrototypeKicker(text: "BUILDING COMPANION")
                    Text(title)
                        .font(.system(size: 31, weight: .heavy))
                        .foregroundStyle(palette.fg)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.muted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }

                progressCard

                if progress?.isFailed == true {
                    failedActions
                }
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 460)
        }
        .environment(\.prototypeTheme, .blue)
        .task(id: appViewModel.agentId) {
            appViewModel.startProvisionPolling()
        }
        .onAppear {
            syncFromProgress()
            updateTicker()
        }
        .onDisappear {
            tickerTask?.cancel()
            tickerTask = nil
        }
        .onChange(of: progress?.stage) {
            syncFromProgress()
            updateTicker()
        }
        .onChange(of: progress?.percent) {
            syncFromProgress()
        }
    }

    private var progress: AgentProvisionStatus? {
        appViewModel.provisionProgress
    }

    private var title: String {
        progress?.isFailed == true ? "生成失败" : "正在创建你的 AI 伙伴"
    }

    private var subtitle: String {
        if progress?.isFailed == true {
            return "TA 的初始化没有完成。可以返回重建，或稍后再重试进度检查。"
        }
        if progress?.isComplete == true {
            return "创建完成，即将进入聊天。"
        }
        return "正在为 TA 构建完整的人生经历、性格底色和初始记忆。"
    }

    private var displayPercent: Int {
        if progress?.isFailed == true { return max(0, progress?.percent ?? localPercent) }
        return min(100, max(localPercent, progress?.percent ?? 0))
    }

    private var displayMessage: String {
        if progress?.stage == "llm_generating" {
            return localMessage
        }
        return progress?.message ?? localMessage
    }

    private var statusGlyph: some View {
        ZStack {
            Circle()
                .fill(progress?.isFailed == true ? Color(hex: 0xFFE8EC) : palette.accentSoft)
                .frame(width: 88, height: 88)
                .prototypeLiquidGlass(cornerRadius: 44, tint: Color.white.opacity(0.30))

            Image(systemName: progress?.isFailed == true ? "xmark" : "sparkles")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(progress?.isFailed == true ? Color(hex: 0xE35B6F) : palette.accent)
                .rotationEffect(.degrees(progress?.stage == "llm_generating" ? 18 : 0))
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: progress?.stage == "llm_generating")
        }
    }

    private var progressCard: some View {
        VStack(spacing: 14) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(palette.hairline)
                    Capsule()
                        .fill(.linearGradient(
                            colors: [palette.accent, Color(hex: 0xFF8A3D), Color(hex: 0xE35B6F)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: proxy.size.width * CGFloat(displayPercent) / 100)
                }
            }
            .frame(height: 9)

            HStack(alignment: .firstTextBaseline) {
                Text(displayMessage)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(palette.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Text("\(displayPercent)%")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(palette.accent)
                    .monospacedDigit()
            }

            stageTimeline
        }
        .prototypeCard(cornerRadius: 28, padding: 18)
    }

    private var stageTimeline: some View {
        let stages = [
            ("queued", "排队"),
            ("mbti_deriving", "性格"),
            ("llm_generating", "背景"),
            ("embedding", "记忆"),
            ("complete", "完成")
        ]

        return HStack(spacing: 6) {
            ForEach(Array(stages.enumerated()), id: \.offset) { index, item in
                VStack(spacing: 6) {
                    Circle()
                        .fill(stageIsReached(item.0, index: index) ? palette.accent : palette.hairline)
                        .frame(width: 8, height: 8)
                    Text(item.1)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(stageIsReached(item.0, index: index) ? palette.accent : palette.subtle)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 2)
    }

    private var failedActions: some View {
        HStack(spacing: 12) {
            Button {
                appViewModel.retryProvisionPolling()
            } label: {
                Text("重试检查")
                    .font(.system(size: 13, weight: .heavy))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .prototypeLiquidGlass(cornerRadius: 23, tint: Color.white.opacity(0.26), interactive: true)
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    await appViewModel.deleteAgent()
                }
            } label: {
                Text("删除重建")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(hex: 0xE35B6F))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func syncFromProgress() {
        guard let progress else { return }
        if progress.stage != "llm_generating" {
            localPercent = max(localPercent, progress.percent)
            localMessage = progress.message
        } else {
            localPercent = max(localPercent, max(llmBasePercent, progress.percent))
            if !rotatingMessages.contains(localMessage) {
                localMessage = rotatingMessages[0]
            }
        }
    }

    private func updateTicker() {
        tickerTask?.cancel()
        tickerTask = nil

        guard progress?.stage == "llm_generating" else { return }

        tickerTask = Task {
            let startedAt = Date()
            var tick = 0
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startedAt)
                let ratio = min(1, elapsed / llmEstimatedSeconds)
                let percent = llmBasePercent + Int((Double(llmTargetPercent - llmBasePercent) * ratio).rounded())
                let message = rotatingMessages[(tick / 6) % rotatingMessages.count]

                await MainActor.run {
                    localPercent = max(localPercent, percent)
                    localMessage = message
                }

                tick += 1
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func stageIsReached(_ stage: String, index: Int) -> Bool {
        guard let current = progress?.stage else { return index == 0 }
        let order = [
            "queued", "initializing", "mbti_deriving", "mbti_done",
            "prompt_building", "llm_generating", "llm_done",
            "converting", "embedding", "storing", "complete"
        ]
        guard let currentIndex = order.firstIndex(of: current) else { return false }
        guard let stageIndex = order.firstIndex(of: stage) else { return false }
        return currentIndex >= stageIndex
    }
}
