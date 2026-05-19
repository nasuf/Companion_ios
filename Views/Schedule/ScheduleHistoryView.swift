import SwiftUI

struct ScheduleHistoryView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var data: ScheduleHistoryResponse?
    @State private var isLoading = true
    @State private var selectedDate: String?

    private var availableDates: Set<String> {
        Set(data?.schedules.map(\.date) ?? [])
    }

    private var selectedSchedule: DaySchedule? {
        guard let selectedDate else { return data?.schedules.first }
        return data?.schedules.first { $0.date == selectedDate }
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    header
                    content
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .refreshable { await loadData() }
        }
        .task { await loadData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "daily rhythm")
            Text("AI 作息轨迹")
                .font(.system(size: 33, weight: .heavy))
            Text("生活画像和作息记录来自后端 agent schedule history。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            ScheduleLoadingPanel()
                .padding(.horizontal, 16)
        } else if let data, !data.schedules.isEmpty {
            VStack(spacing: 16) {
                if let overview = data.lifeOverview, !overview.isEmpty {
                    LifeOverviewCard(overview: overview)
                }
                PrototypeCalendarGrid(
                    dates: availableDates,
                    selected: selectedDate ?? data.schedules.first?.date,
                    onSelect: { selectedDate = $0 }
                )
                if let selectedSchedule {
                    DayScheduleCard(day: selectedSchedule)
                }
            }
            .padding(.horizontal, 16)
        } else {
            ScheduleEmptyPanel()
                .padding(.horizontal, 16)
        }
    }

    private func loadData() async {
        guard let agentId = appViewModel.agentId else {
            isLoading = false
            return
        }
        isLoading = data == nil
        data = try? await ScheduleService.getHistory(agentId: agentId)
        selectedDate = selectedDate ?? data?.schedules.first?.date
        isLoading = false
    }
}

private struct LifeOverviewCard: View {
    @Environment(\.prototypePalette) private var palette
    let overview: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("生活画像")
                    .font(.system(size: 18, weight: .heavy))
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(palette.accent)
            }
            Text(overview)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.muted)
                .lineSpacing(4)
        }
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private struct PrototypeCalendarGrid: View {
    @Environment(\.prototypePalette) private var palette
    let dates: Set<String>
    let selected: String?
    let onSelect: (String) -> Void

    private var calendarDays: [CalendarDay] {
        guard let earliest = dates.compactMap({ parseDate($0) }).min(),
              let latest = dates.compactMap({ parseDate($0) }).max()
        else { return [] }

        let calendar = Calendar.current
        let start = calendar.dateInterval(of: .weekOfYear, for: earliest)?.start ?? earliest
        let end = calendar.date(byAdding: .day, value: 6, to: calendar.dateInterval(of: .weekOfYear, for: latest)?.start ?? latest) ?? latest

        var days: [CalendarDay] = []
        var current = start
        while current <= end {
            let string = formatDate(current)
            days.append(CalendarDay(
                date: current,
                dateString: string,
                hasData: dates.contains(string),
                isToday: calendar.isDateInToday(current)
            ))
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        return days
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("日期记录")
                    .font(.system(size: 18, weight: .heavy))
                Spacer()
                Text("\(dates.count) 天")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(palette.subtle)
            }

            HStack {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(palette.subtle)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 7) {
                ForEach(calendarDays) { day in
                    Button {
                        if day.hasData { onSelect(day.dateString) }
                    } label: {
                        Text("\(Calendar.current.component(.day, from: day.date))")
                            .font(.system(size: 12, weight: day.dateString == selected ? .heavy : .semibold))
                            .foregroundStyle(day.dateString == selected ? palette.bg : day.hasData ? palette.fg : palette.subtle.opacity(0.36))
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(day.dateString == selected ? palette.fg : day.isToday ? palette.accentSoft : Color.white.opacity(day.hasData ? 0.46 : 0.18))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(!day.hasData)
                }
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 16)
    }

    private func parseDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private struct CalendarDay: Identifiable {
    let date: Date
    let dateString: String
    let hasData: Bool
    let isToday: Bool
    var id: String { dateString }
}

private struct DayScheduleCard: View {
    @Environment(\.prototypePalette) private var palette
    let day: DaySchedule

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.date)
                        .font(.system(size: 19, weight: .heavy))
                    Text("当天作息")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(palette.subtle)
                }
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(palette.accent)
            }

            VStack(spacing: 10) {
                ForEach(Array(day.schedule.enumerated()), id: \.offset) { _, slot in
                    SlotRow(slot: slot)
                }
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private struct SlotRow: View {
    @Environment(\.prototypePalette) private var palette
    let slot: ScheduleSlot

    private var statusColor: Color {
        switch slot.type {
        case "sleep": Color(hex: 0x7C3CFF)
        case "work": Color(hex: 0xFF7A3D)
        case "routine": Color(hex: 0xFFC936)
        case "rest": Color(hex: 0x4D8870)
        case "social": Color(hex: 0x1F6FFF)
        default: Color(hex: 0x18C6C0)
        }
    }

    private var statusText: String {
        switch slot.type {
        case "sleep": "睡眠"
        case "work": "忙碌"
        case "routine": "日常"
        case "rest": "休息"
        case "social": "社交"
        default: "空闲"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(slot.start)-\(slot.end)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundStyle(palette.subtle)
                .frame(width: 94, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(slot.activity)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(palette.fg)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Circle().fill(statusColor).frame(width: 6, height: 6)
                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(palette.muted)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(statusColor.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct ScheduleLoadingPanel: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("正在读取作息")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private struct ScheduleEmptyPanel: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(palette.accent)
            Text("暂无作息记录")
                .font(.system(size: 18, weight: .heavy))
            Text("AI 每天凌晨会自动生成作息表")
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 190)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}
