import SwiftUI

struct MemoryTimelineView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: MemoryViewModel?

    var body: some View {
        Group {
            if let viewModel {
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField(String(localized: "搜索记忆..."), text: Binding(
                            get: { viewModel.searchQuery },
                            set: { viewModel.searchQuery = $0 }
                        ))
                        .onSubmit {
                            Task { await viewModel.search() }
                        }
                    }
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Level filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: String(localized: "全部"), isSelected: viewModel.selectedLevel == nil) {
                                Task { await viewModel.filterByLevel(nil) }
                            }
                            FilterChip(title: "L1", isSelected: viewModel.selectedLevel == 1) {
                                Task { await viewModel.filterByLevel(1) }
                            }
                            FilterChip(title: "L2", isSelected: viewModel.selectedLevel == 2) {
                                Task { await viewModel.filterByLevel(2) }
                            }
                            FilterChip(title: "L3", isSelected: viewModel.selectedLevel == 3) {
                                Task { await viewModel.filterByLevel(3) }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // Timeline
                    if viewModel.isLoading && viewModel.memories.isEmpty {
                        ShimmerList()
                        Spacer()
                    } else if viewModel.memories.isEmpty {
                        Spacer()
                        EmptyStateView(
                            icon: "brain",
                            title: String(localized: "暂无记忆"),
                            subtitle: String(localized: "和 AI 聊天后会自动生成记忆")
                        )
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.memories) { memory in
                                    NavigationLink {
                                        MemoryDetailView(memory: memory)
                                    } label: {
                                        MemoryCard(memory: memory)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .refreshable {
                            await viewModel.load()
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(String(localized: "记忆"))
        .gradientBackground()
        .task {
            if viewModel == nil {
                let vm = MemoryViewModel(userId: appViewModel.userId)
                viewModel = vm
                await vm.load()
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? AnyShapeStyle(BrandGradient.primary) : AnyShapeStyle(.ultraThinMaterial))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct MemoryCard: View {
    let memory: Memory

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(memory.levelColor)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 1)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(memory.levelLabel)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(memory.levelColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(memory.levelColor.opacity(0.15))
                        .clipShape(Capsule())

                    if !memory.typeLabel.isEmpty {
                        Text(memory.typeLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    if memory.isAIMemory {
                        Label("TA", systemImage: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                    }

                    Spacer()

                    Text(DateFormatting.short(memory.createdAt))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(memory.summary ?? memory.content)
                    .font(.subheadline)
                    .lineLimit(3)

                if memory.importance >= 0.7 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text(String(format: "%.0f%%", memory.importance * 100))
                            .font(.caption2)
                    }
                    .foregroundStyle(.orange)
                }
            }
            .glassCard()
        }
        .padding(.vertical, 4)
    }

}
