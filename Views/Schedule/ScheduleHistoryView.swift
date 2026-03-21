import SwiftUI

struct ScheduleHistoryView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var data: ScheduleHistoryResponse?
    @State private var isLoading = true
    @State private var selectedDate: String?

    /// 有作息记录的日期集合
    private var availableDates: Set<String> {
        Set(data?.schedules.map(\.date) ?? [])
    }

    /// 当前选中日期的作息
    private var selectedSchedule: DaySchedule? {
        guard let sel = selectedDate else { return data?.schedules.first }
        return data?.schedules.first { $0.date == sel }
    }

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let data, !data.schedules.isEmpty {
                VStack(spacing: 16) {
                    // 日历网格
                    CalendarGrid(
                        dates: availableDates,
                        selected: selectedDate ?? data.schedules.first?.date,
                        onSelect: { selectedDate = $0 }
                    )
                    .glassCard(padding: 14)

                    // 选中日期的作息
                    if let day = selectedSchedule {
                        DayScheduleCard(day: day)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            } else {
                EmptyStateView(
                    icon: "calendar",
                    title: "暂无作息记录",
                    subtitle: "AI 每天凌晨会自动生成作息表"
                )
                .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .navigationTitle("AI 作息")
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground()
        .task { await loadData() }
        .refreshable { await loadData() }
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

// MARK: - CalendarGrid

private struct CalendarGrid: View {
    let dates: Set<String>
    let selected: String?
    let onSelect: (String) -> Void

    /// 从可用日期范围生成日历天数
    private var calendarDays: [CalendarDay] {
        guard let earliest = dates.compactMap({ parseDate($0) }).min(),
              let latest = dates.compactMap({ parseDate($0) }).max() else {
            return []
        }
        let cal = Calendar.current
        // 从 earliest 所在周的周一开始
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: earliest)?.start ?? earliest
        // 到 latest 所在周的周日结束
        let endDate = cal.date(byAdding: .day, value: 6, to: cal.dateInterval(of: .weekOfYear, for: latest)?.start ?? latest)!

        var days: [CalendarDay] = []
        var current = startOfWeek
        while current <= endDate {
            let str = formatDate(current)
            days.append(CalendarDay(
                date: current,
                dateString: str,
                hasData: dates.contains(str),
                isToday: cal.isDateInToday(current)
            ))
            current = cal.date(byAdding: .day, value: 1, to: current)!
        }
        return days
    }

    var body: some View {
        VStack(spacing: 8) {
            // 星期头
            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { d in
                    Text(d)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 日期网格
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(calendarDays) { day in
                    Button {
                        if day.hasData { onSelect(day.dateString) }
                    } label: {
                        Text("\(Calendar.current.component(.day, from: day.date))")
                            .font(.system(size: 13, weight: day.dateString == selected ? .bold : .regular))
                            .foregroundStyle(
                                day.dateString == selected ? .white :
                                day.hasData ? .primary :
                                .secondary.opacity(0.3)
                            )
                            .frame(width: 32, height: 32)
                            .background(
                                day.dateString == selected
                                    ? AnyShapeStyle(BrandGradient.primary)
                                    : day.isToday
                                        ? AnyShapeStyle(Color.white.opacity(0.08))
                                        : AnyShapeStyle(Color.clear)
                            )
                            .clipShape(Circle())
                    }
                    .disabled(!day.hasData)
                }
            }
        }
    }

    private func parseDate(_ str: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

private struct CalendarDay: Identifiable {
    let date: Date
    let dateString: String
    let hasData: Bool
    let isToday: Bool
    var id: String { dateString }
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
