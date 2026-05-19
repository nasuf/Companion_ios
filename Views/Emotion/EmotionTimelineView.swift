import SwiftUI
import Charts

struct EmotionTimelineView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var viewModel: EmotionViewModel?

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            Group {
                if let viewModel {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            PrototypeDetailActions()
                            header
                            content(viewModel)
                        }
                        .padding(.top, 18)
                        .padding(.bottom, 28)
                    }
                    .refreshable { await viewModel.load() }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .task {
            if viewModel == nil, let agentId = appViewModel.agentId {
                let vm = EmotionViewModel(agentId: agentId)
                viewModel = vm
                await vm.load()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "emotion signal")
            Text("情绪正在发生")
                .font(.system(size: 33, weight: .heavy))
            Text("PAD 曲线来自后端真实情绪接口，用来观察小芜的状态变化。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private func content(_ viewModel: EmotionViewModel) -> some View {
        if viewModel.isLoading && viewModel.currentEmotion == nil && viewModel.timeline.isEmpty {
            PrototypeEmotionLoading()
                .padding(.horizontal, 16)
        } else if viewModel.currentEmotion == nil && viewModel.timeline.isEmpty {
            PrototypeEmotionEmpty()
                .padding(.horizontal, 16)
        } else {
            VStack(spacing: 16) {
                if let current = viewModel.currentEmotion {
                    CurrentEmotionCard(current: current)
                }
                if !viewModel.timeline.isEmpty {
                    EmotionChartCard(timeline: viewModel.timeline)
                    EmotionHistoryList(entries: viewModel.timeline)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct CurrentEmotionCard: View {
    @Environment(\.prototypePalette) private var palette
    let current: EmotionState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("当前情绪")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(palette.subtle)
                    Text(current.tone)
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(palette.fg)
                }
                Spacer()
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 52, height: 52)
                    .background(palette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            HStack(spacing: 10) {
                EmotionMeter(title: "P", label: "愉悦", value: current.pleasure, color: Color(hex: 0xFF6A3D))
                EmotionMeter(title: "A", label: "唤醒", value: current.arousal, color: Color(hex: 0x1F6FFF))
                EmotionMeter(title: "D", label: "支配", value: current.dominance, color: Color(hex: 0x4D8870))
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
    }
}

private struct EmotionMeter: View {
    @Environment(\.prototypePalette) private var palette
    let title: String
    let label: String
    let value: Double
    let color: Color

    private var normalized: Double {
        min(max((value + 1) / 2, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(color)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundStyle(palette.subtle)
            }
            GeometryReader { proxy in
                Capsule()
                    .fill(color.opacity(0.14))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(color)
                            .frame(width: max(8, proxy.size.width * normalized))
                    }
            }
            .frame(height: 8)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct EmotionChartCard: View {
    @Environment(\.prototypePalette) private var palette
    let timeline: [EmotionTimelineEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("情绪变化")
                    .font(.system(size: 18, weight: .heavy))
                Spacer()
                Text("\(timeline.count) 条记录")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(palette.subtle)
            }

            Chart {
                ForEach(Array(timeline.enumerated()), id: \.offset) { index, entry in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Pleasure", entry.pleasure)
                    )
                    .foregroundStyle(palette.accent)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Index", index),
                        y: .value("Pleasure", entry.pleasure)
                    )
                    .foregroundStyle(.linearGradient(
                        colors: [palette.accent.opacity(0.28), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .interpolationMethod(.catmullRom)
                }
            }
            .frame(height: 210)
            .chartYScale(domain: -1...1)
            .chartXAxis(.hidden)
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
    }
}

private struct EmotionHistoryList: View {
    @Environment(\.prototypePalette) private var palette
    let entries: [EmotionTimelineEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("历史片段")
                .font(.system(size: 18, weight: .heavy))

            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(DateFormatting.dateTime(entry.timestamp))
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(palette.subtle)
                        Spacer()
                        Text(String(format: "P %.1f  A %.1f  D %.1f", entry.pleasure, entry.arousal, entry.dominance))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(palette.muted)
                    }
                    Text(entry.messagePreview)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.fg)
                        .lineLimit(2)
                }
                .padding(12)
                .background(Color.white.opacity(0.52))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 15)
    }
}

private struct PrototypeEmotionLoading: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("正在读取情绪状态")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private struct PrototypeEmotionEmpty: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(palette.accent)
            Text("暂无情绪数据")
                .font(.system(size: 18, weight: .heavy))
            Text("聊天后会自动记录情绪变化")
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 190)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}
