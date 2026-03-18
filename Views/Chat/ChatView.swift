import SwiftUI

// MARK: - Scroll Position Tracking

private struct ContentBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var isNearBottom = true
    @State private var scrollViewHeight: CGFloat = 0

    init(conversationId: String, agentId: String, userId: String) {
        _viewModel = State(initialValue: ChatViewModel(
            conversationId: conversationId,
            agentId: agentId,
            userId: userId
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Top trigger: when visible, load older messages
                        Group {
                            if viewModel.isLoadingMoreHistory {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            } else if viewModel.hasMoreHistory {
                                Color.clear
                                    .frame(height: 1)
                                    .onAppear {
                                        Task { await viewModel.loadMoreHistory() }
                                    }
                            }
                        }
                        .id("top_trigger")

                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        // 微信模式：只在 AI 正在输入时显示 typing indicator
                        if viewModel.isTyping {
                            TypingIndicator()
                                .padding(.leading, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Bottom anchor: scroll target
                        Color.clear
                            .frame(height: 1)
                            .id("bottom_spacer")
                    }
                    .padding(.top, 12)
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear.preference(
                                key: ContentBottomKey.self,
                                value: contentGeo.frame(in: .named("chatScroll")).maxY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "chatScroll")
                .background(
                    GeometryReader { scrollGeo in
                        Color.clear.onAppear { scrollViewHeight = scrollGeo.size.height }
                            .onChange(of: scrollGeo.size.height) { _, h in scrollViewHeight = h }
                    }
                )
                .onPreferenceChange(ContentBottomKey.self) { contentBottom in
                    // 200pt threshold ≈ 1.5–2 message bubbles
                    isNearBottom = contentBottom <= scrollViewHeight + 200
                    if isNearBottom {
                        viewModel.hasUnreadReply = false
                    }
                }
                .onTapGesture { isInputFocused = false }
                .onChange(of: viewModel.scrollToBottom) {
                    // Only auto-scroll for user's own send action
                    if viewModel.scrollToBottom {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                        viewModel.scrollToBottom = false
                    }
                }
                .onChange(of: viewModel.hasUnreadReply) {
                    // When new reply arrives and user can see the last message → auto-scroll
                    if viewModel.hasUnreadReply && isNearBottom {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                        viewModel.hasUnreadReply = false
                    }
                    // If last message is off-screen, the badge will show via the overlay
                }
                .onChange(of: viewModel.messages.count) { oldCount, newCount in
                    if oldCount == 0 && newCount > 0 {
                        proxy.scrollTo("bottom_spacer", anchor: .bottom)
                    }
                }
                .overlay(alignment: .bottom) {
                    // Show "新消息" only when:
                    // 1. There IS unread reply content (hasUnreadReply)
                    // 2. User has scrolled away from bottom (!isAtBottom)
                    // 3. Not currently showing loading/typing indicator
                    if viewModel.hasUnreadReply && !isNearBottom && !viewModel.isTyping {
                        Button {
                            withAnimation(.spring(duration: 0.35)) {
                                proxy.scrollTo("bottom_spacer", anchor: .bottom)
                            }
                            viewModel.hasUnreadReply = false
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 11, weight: .bold))
                                Text("新消息")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        }
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(duration: 0.3), value: viewModel.hasUnreadReply)
                    }
                }
            }

            // Blocked overlay (7.6)
            blockedOverlay

            // Emoji Picker & Input bar wrapped in glass
            inputArea
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Principal: Title and Intimacy Badge
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(appViewModel.agentName ?? String(localized: "聊天"))
                        .font(.headline)
                    if let intimacy = viewModel.intimacy {
                        IntimacyBadge(level: intimacy.level)
                    }
                }
            }

            // Leading: Boundary mood (7.6)
            ToolbarItem(placement: .topBarLeading) {
                if let boundary = viewModel.boundaryStatus, boundary.zone != "normal" {
                    BoundaryMoodIndicator(zone: boundary.zone, patience: boundary.patience)
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
                group.addTask { await self.viewModel.loadBoundary() }
                group.addTask { await self.viewModel.connectToChat() }
            }
        }
        .onDisappear {
            viewModel.disconnectFromChat()
        }
    }

    @ViewBuilder
    private var blockedOverlay: some View {
        if viewModel.boundaryStatus?.zone == "blocked" {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.red)
                Text("对方暂时不想聊天，试着道个歉吧")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
        }
    }

    private var emojiPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(["😊", "😂", "🥰", "🥺", "✨", "🔥", "💔", "🤔", "🙌", "👀", "🌸", "💯"], id: \.self) { emoji in
                    Button {
                        viewModel.inputText.append(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 24))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var inputArea: some View {
        VStack(spacing: 0) {
            // Inline Emoji Picker
            emojiPicker
            
            // Input bar
            HStack(spacing: 12) {
                TextField(String(localized: "输入消息..."), text: $viewModel.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .focused($isInputFocused)
                    .onSubmit {
                        viewModel.send()
                    }

                Button {
                    viewModel.send()
                } label: {
                    Image(systemName: viewModel.isWaitingReply ? "stop.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isWaitingReply
                            ? AnyShapeStyle(Color.gray.opacity(0.5))
                            : AnyShapeStyle(BrandGradient.primary)
                        )
                        .clipShape(Circle())
                        .shadow(color: (viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isWaitingReply) ? .clear : Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.4), radius: 4, y: 2)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isWaitingReply)
                .sensoryFeedback(.impact, trigger: viewModel.messages.count)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(.regularMaterial)
        .background(
            Color.black.opacity(0.05)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.white.opacity(0.2)),
            alignment: .top
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
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

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.symbolName)
                .font(.system(size: 9))
            Text(level.label)
                .font(.caption2)
        }
        .foregroundStyle(level.badgeColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(level.badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - BoundaryMoodIndicator (7.6)

private struct BoundaryMoodIndicator: View {
    let zone: String
    let patience: Int

    private var icon: String {
        switch zone {
        case "blocked": return "xmark.circle.fill"
        case "low": return "exclamationmark.triangle.fill"
        case "medium": return "cloud.fill"
        default: return "face.smiling"
        }
    }

    private var color: Color {
        switch zone {
        case "blocked": return .red
        case "low": return .orange
        case "medium": return .yellow
        default: return .green
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text("\(patience)")
                .font(.caption2)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
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
                UserPortraitView()
            } label: {
                Label(String(localized: "画像"), systemImage: "person.text.rectangle")
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
