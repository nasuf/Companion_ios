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
                                        EmotionGauge(label: "V", value: current.valence)
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
                                                y: .value("Valence", entry.valence)
                                            )
                                            .foregroundStyle(.purple)
                                            .interpolationMethod(.catmullRom)

                                            AreaMark(
                                                x: .value("Index", index),
                                                y: .value("Valence", entry.valence)
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
                                                Text(formatDate(entry.timestamp))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                Spacer()
                                                HStack(spacing: 8) {
                                                    Text("V:\(String(format: "%.1f", entry.valence))")
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
                            }
                            .padding(.horizontal)
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

    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr) else {
            return dateStr
        }
        let df = DateFormatter()
        df.dateFormat = "MM/dd HH:mm"
        return df.string(from: date)
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
