import SwiftUI

struct ScheduleHistoryView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var data: ScheduleHistoryResponse?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let data {
                VStack(spacing: 20) {
                    // 生活画像
                    if let overview = data.lifeOverview, !overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("生活画像", systemImage: "sparkles")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(overview)
                                .font(.subheadline)
                                .lineSpacing(5)
                        }
                        .glassCard(padding: 14)
                    }

                    // 作息历史
                    if data.schedules.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: "暂无作息记录",
                            subtitle: "AI 每天凌晨会自动生成作息表"
                        )
                        .frame(minHeight: 150)
                    } else {
                        ForEach(data.schedules) { day in
                            DayScheduleCard(day: day)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("AI 作息")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground()
        .task {
            await loadData()
        }
        .refreshable {
            await loadData()
        }
    }

    private func loadData() async {
        guard let agentId = appViewModel.agentId else {
            isLoading = false
            return
        }
        isLoading = data == nil
        data = try? await ScheduleService.getHistory(agentId: agentId)
        isLoading = false
    }
}

// MARK: - DayScheduleCard

private struct DayScheduleCard: View {
    let day: DaySchedule

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(day.date)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(day.schedule.enumerated()), id: \.offset) { index, slot in
                    SlotRow(slot: slot)
                    if index < day.schedule.count - 1 {
                        Divider().opacity(0.3)
                    }
                }
            }
        }
        .glassCard(padding: 14)
    }
}

// MARK: - SlotRow

private struct SlotRow: View {
    let slot: ScheduleSlot

    private var statusColor: Color {
        switch slot.type {
        case "sleep": return .indigo
        case "work": return .orange
        case "routine": return .yellow
        default: return .green
        }
    }

    private var statusText: String {
        switch slot.type {
        case "sleep": return "睡眠"
        case "work": return "忙碌"
        case "routine": return "日常"
        case "rest": return "休息"
        case "social": return "社交"
        default: return "空闲"
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Text("\(slot.start)-\(slot.end)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(slot.activity)
                .font(.subheadline)
                .lineLimit(1)

            Spacer()

            HStack(spacing: 4) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                Text(statusText)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
