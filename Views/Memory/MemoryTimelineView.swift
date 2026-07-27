import SwiftUI

private struct MemoryLevelFilter: Hashable {
    let title: String
    let level: Int?
}

struct MemoryTimelineView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var viewModel: MemoryViewModel?

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            Group {
                if let viewModel {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            PrototypeDetailActions()
                            header
                            searchBox(viewModel)
                            levelFilters(viewModel)
                            memoryContent(viewModel)
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
            if viewModel == nil {
                let vm = MemoryViewModel(userId: appViewModel.userId)
                viewModel = vm
                await vm.load()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "memory archive")
            Text("我们记住的事")
                .font(.system(size: 33, weight: .heavy))
            Text("核心记忆、重要记忆和模糊记忆会在这里按真实接口同步。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    private func searchBox(_ viewModel: MemoryViewModel) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(palette.subtle)
            TextField("搜索记忆...", text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.searchQuery = $0 }
            ))
            .font(.system(size: 14, weight: .semibold))
            .submitLabel(.search)
            .onSubmit { Task { await viewModel.search() } }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color.white.opacity(0.60))
        .clipShape(Capsule())
        .prototypeLiquidGlass(cornerRadius: 23, tint: Color.white.opacity(0.26), interactive: true)
        .padding(.horizontal, 16)
    }

    private func levelFilters(_ viewModel: MemoryViewModel) -> some View {
        PrototypeGlassSegmentedControl(
            options: Self.levelFilterOptions,
            selection: Binding(
                get: { Self.levelFilterOptions.first { $0.level == viewModel.selectedLevel } ?? Self.levelFilterOptions[0] },
                set: { option in Task { await viewModel.filterByLevel(option.level) } }
            ),
            title: { $0.title },
            activeTint: palette.accent,
            activeForeground: palette.accentInk,
            inactiveForeground: palette.muted,
            height: 38
        )
        .padding(.horizontal, 16)
    }

    private static let levelFilterOptions = [
        MemoryLevelFilter(title: "全部", level: nil),
        MemoryLevelFilter(title: "L1 核心", level: 1),
        MemoryLevelFilter(title: "L2 重要", level: 2),
        MemoryLevelFilter(title: "L3 模糊", level: 3)
    ]

    @ViewBuilder
    private func memoryContent(_ viewModel: MemoryViewModel) -> some View {
        if viewModel.isLoading && viewModel.memories.isEmpty {
            PrototypeLoadingPanel(title: "正在整理记忆")
                .padding(.horizontal, 16)
        } else if viewModel.memories.isEmpty {
            PrototypeEmptyPanel(icon: "brain.head.profile", title: "暂无记忆", subtitle: "和 AI 聊天后会自动生成记忆")
                .padding(.horizontal, 16)
        } else {
            VStack(spacing: 12) {
                MemorySummaryStrip(memories: viewModel.memories)
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.memories) { memory in
                        NavigationLink {
                            MemoryDetailView(memory: memory)
                        } label: {
                            PrototypeMemoryCard(memory: memory)
                        }
                        .buttonStyle(.prototypeGlassPress)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct MemorySummaryStrip: View {
    @Environment(\.prototypePalette) private var palette
    let memories: [Memory]

    var body: some View {
        HStack(spacing: 10) {
            summary("L1", count: memories.filter { $0.level == 1 }.count, color: Color(hex: 0xFF6A3D))
            summary("L2", count: memories.filter { $0.level == 2 }.count, color: Color(hex: 0x1F6FFF))
            summary("L3", count: memories.filter { $0.level == 3 }.count, color: Color(hex: 0x4D8870))
        }
    }

    private func summary(_ label: String, count: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(color)
            Text("\(count)")
                .font(.system(size: 21, weight: .heavy))
                .foregroundStyle(palette.fg)
            Text("条")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(palette.subtle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .prototypeCard(cornerRadius: 22, padding: 13)
    }
}

private struct PrototypeMemoryCard: View {
    @Environment(\.prototypePalette) private var palette
    let memory: Memory

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(memory.prototypeLevelColor)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(palette.hairline)
                    .frame(width: 1, height: 72)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(memory.levelLabel)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(memory.prototypeLevelColor)
                        .padding(.horizontal, 9)
                        .frame(height: 24)
                        .background(memory.prototypeLevelColor.opacity(0.12))
                        .clipShape(Capsule())
                    if !memory.typeLabel.isEmpty {
                        Text(memory.typeLabel)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(palette.subtle)
                    }
                    Spacer()
                    Text(DateFormatting.dateTime(memory.createdAt))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(palette.subtle)
                }

                Text(memory.content)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.fg)
                    .lineLimit(3)

                HStack {
                    Text(memory.sourceLabel)
                    Spacer()
                    Text(String(format: "%.0f%%", memory.importance * 100))
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(palette.muted)
            }
            .prototypeCard(cornerRadius: 22, padding: 13)
        }
    }
}

private struct PrototypeLoadingPanel: View {
    @Environment(\.prototypePalette) private var palette
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private struct PrototypeEmptyPanel: View {
    @Environment(\.prototypePalette) private var palette
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(palette.accent)
            Text(title)
                .font(.system(size: 18, weight: .heavy))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 190)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}

private extension Memory {
    var prototypeLevelColor: Color {
        switch level {
        case 1: Color(hex: 0xFF6A3D)
        case 2: Color(hex: 0x1F6FFF)
        default: Color(hex: 0x4D8870)
        }
    }
}
