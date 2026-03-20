import SwiftUI
import Charts

struct EmotionTimelineView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: EmotionViewModel?

    var body: some View {
        Group {
            if let viewModel {
                ScrollView {
                    VStack(spacing: 20) {
                        // Current emotion card
                        if let current = viewModel.currentEmotion {
                            GlassCard {
                                VStack(spacing: 12) {
                                    Text("当前情绪")
                                        .font(.headline)
                                    Text(current.tone)
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(.purple)
                                    HStack(spacing: 20) {
                                        EmotionGauge(label: "P", value: current.pleasure)
                                        EmotionGauge(label: "A", value: current.arousal)
                                        EmotionGauge(label: "D", value: current.dominance)
                                        }
                                        }
                                        }
                                        .padding(.horizontal)
                                        }

                                        // Chart
                                        if !viewModel.timeline.isEmpty {
                                        GlassCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                        Text("情绪变化")
                                        .font(.headline)

                                        Chart {
                                        ForEach(Array(viewModel.timeline.enumerated()), id: \.offset) { index, entry in
                                           LineMark(
                                               x: .value("Index", index),
                                               y: .value("Pleasure", entry.pleasure)
                                           )
                                           .foregroundStyle(.purple)
                                           .interpolationMethod(.catmullRom)

                                           AreaMark(
                                               x: .value("Index", index),
                                               y: .value("Pleasure", entry.pleasure)
                                           )
                                           .foregroundStyle(
                                               .linearGradient(
                                                   colors: [.purple.opacity(0.3), .clear],
                                                   startPoint: .top,
                                                   endPoint: .bottom
                                               )
                                           )
                                           .interpolationMethod(.catmullRom)
                                        }
                                        }
                                        .frame(height: 200)
                                        .chartYScale(domain: -1...1)
                                        }
                                        }
                                        .padding(.horizontal)

                                        // History entries
                                        VStack(spacing: 8) {
                                        ForEach(viewModel.timeline) { entry in
                                        GlassCard {
                                        VStack(alignment: .leading, spacing: 6) {
                                           HStack {
                                               Text(DateFormatting.dateTime(entry.timestamp))
                                                   .font(.caption)
                                                   .foregroundStyle(.secondary)
                                               Spacer()
                                               HStack(spacing: 8) {
                                                   Text("P:\(String(format: "%.1f", entry.pleasure))")
                                                   Text("A:\(String(format: "%.1f", entry.arousal))")
                                                   Text("D:\(String(format: "%.1f", entry.dominance))")
                                               }
                                               .font(.caption2.monospacedDigit())
                                               .foregroundStyle(.secondary)
                                           }
                                           Text(entry.messagePreview)
                                               .font(.subheadline)
                                               .lineLimit(2)
                                        }
                                        }
                                        }
                                        }                            .padding(.horizontal)
                        } else if !viewModel.isLoading {
                            EmptyStateView(
                                icon: "heart",
                                title: String(localized: "暂无情绪数据"),
                                subtitle: String(localized: "聊天后会自动记录情绪变化")
                            )
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.load()
                }
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(String(localized: "情绪"))
        .gradientBackground()
        .task {
            if viewModel == nil, let agentId = appViewModel.agentId {
                let vm = EmotionViewModel(agentId: agentId)
                viewModel = vm
                await vm.load()
            }
        }
    }

}

private struct EmotionGauge: View {
    let label: String
    let value: Double

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Gauge(value: (value + 1) / 2) {
                EmptyView()
            }
            .gaugeStyle(.accessoryCircular)
            .tint(.purple)
            .scaleEffect(0.8)
            Text(String(format: "%.2f", value))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
