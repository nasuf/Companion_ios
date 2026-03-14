import SwiftUI

struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    init(conversationId: String, agentId: String, userId: String) {
        _viewModel = State(initialValue: ChatViewModel(
            conversationId: conversationId,
            agentId: agentId,
            userId: userId
        ))
    }

    private var streamingWithEmptyContent: Bool {
        viewModel.isStreaming &&
        (viewModel.messages.last.map { $0.role == .assistant && $0.content.isEmpty } ?? false)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // Show typing indicator when AI is composing or streaming an empty placeholder
                        if viewModel.isTyping || streamingWithEmptyContent {
                            TypingIndicator()
                                .padding(.leading, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("typing")
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onTapGesture {
                    isInputFocused = false
                }
                .onChange(of: viewModel.scrollToBottom) {
                    if viewModel.scrollToBottom, let lastId = viewModel.messages.last?.id {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                        viewModel.scrollToBottom = false
                    }
                }
                .onChange(of: viewModel.isTyping) {
                    if viewModel.isTyping {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }

            // Input bar
            HStack(spacing: 12) {
                TextField(String(localized: "输入消息..."), text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isInputFocused)
                    .onSubmit {
                        viewModel.send()
                    }

                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: viewModel.isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isStreaming
                            ? Color.gray
                            : Color.purple
                        )
                        .clipShape(Circle())
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isStreaming)
                .sensoryFeedback(.impact, trigger: viewModel.messages.count)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(appViewModel.agentName ?? String(localized: "聊天"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Leading: Intimacy badge (7.7)
            ToolbarItem(placement: .topBarLeading) {
                if let intimacy = viewModel.intimacy {
                    IntimacyBadge(level: intimacy.level)
                }
            }

            // Principal: AI status label (7.5) — shown below nav title via subtitle trick
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    if let status = viewModel.agentStatus {
                        AgentStatusBadge(status: status)
                    }
                    NavigationLink {
                        SettingsHubView()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .gradientBackground()
        .task {
            await viewModel.loadHistory()
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.viewModel.loadStatus() }
                group.addTask { await self.viewModel.loadIntimacy() }
            }
        }
        .onDisappear {
            viewModel.cancel()
        }
    }
}

// MARK: - AgentStatusBadge (7.5)

private struct AgentStatusBadge: View {
    let status: AgentStatus

    private var color: Color {
        switch status.status {
        case "sleep": return .indigo
        case "busy":  return .orange
        default:      return .green
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.statusIcon)
                .font(.system(size: 9))
            Text(status.activity)
                .font(.caption2)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - IntimacyBadge (7.7)

private struct IntimacyBadge: View {
    let level: IntimacyLevel

    private var badgeColor: Color {
        switch level.level {
        case "L5": return .pink
        case "L4": return .red
        case "L3": return .orange
        case "L2": return .yellow
        default:   return .gray
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.symbolName)
                .font(.system(size: 9))
            Text(level.label)
                .font(.caption2)
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - SettingsHubView

/// Hub page for Memory / Emotion / Settings
struct SettingsHubView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        List {
            NavigationLink {
                MemoryTimelineView()
            } label: {
                Label(String(localized: "记忆"), systemImage: "brain.head.profile")
            }

            NavigationLink {
                EmotionTimelineView()
            } label: {
                Label(String(localized: "情绪"), systemImage: "heart.text.square")
            }

            NavigationLink {
                SettingsView()
            } label: {
                Label(String(localized: "设置"), systemImage: "gearshape")
            }
        }
        .navigationTitle(appViewModel.agentName ?? String(localized: "更多"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
