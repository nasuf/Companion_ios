import SwiftUI


struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var lastVisibleIndex: Int = 0
    @State private var showSettingsDrawer = false
    @State private var drawerDestination: DrawerDestination?

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

                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .onAppear { lastVisibleIndex = max(lastVisibleIndex, index) }
                        }

                        // Bottom anchor: scroll target
                        Color.clear
                            .frame(height: 16)
                            .id("bottom_spacer")
                    }
                    .padding(.top, 12)
                }
                .onTapGesture { isInputFocused = false }
                .onChange(of: viewModel.scrollToBottom) {
                    // User's own send → always scroll
                    if viewModel.scrollToBottom {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                        viewModel.scrollToBottom = false
                    }
                }
                .onChange(of: viewModel.hasUnreadReply) {
                    guard viewModel.hasUnreadReply else { return }
                    let totalCount = viewModel.messages.count
                    // Within last 3 messages (倒数3条以内) → auto-scroll
                    if lastVisibleIndex >= totalCount - 4 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo("bottom_spacer", anchor: .bottom)
                        }
                        viewModel.hasUnreadReply = false
                    }
                    // Otherwise → badge shows via overlay (do nothing here)
                }
                .onChange(of: viewModel.messages.count) { oldCount, newCount in
                    // Initial load → always scroll
                    if oldCount == 0 && newCount > 0 {
                        proxy.scrollTo("bottom_spacer", anchor: .bottom)
                    }
                }
                .overlay(alignment: .bottom) {
                    // Show "新消息" only when:
                    // 1. There IS unread reply content (hasUnreadReply)
                    // 2. User has scrolled away from bottom (!isAtBottom)
                    // 3. Not currently showing loading/typing indicator
                    if viewModel.hasUnreadReply && lastVisibleIndex < viewModel.messages.count - 4 && !viewModel.isTyping {
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
        .overlay {
            if showSettingsDrawer {
                ZStack(alignment: .trailing) {
                    Color.black.opacity(0.24)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.28)) {
                                showSettingsDrawer = false
                            }
                        }
                        .transition(.opacity)

                    ChatSideDrawer(
                        isPresented: $showSettingsDrawer,
                        emotionState: viewModel.emotionState,
                        intimacy: viewModel.intimacy,
                        boundary: viewModel.boundaryStatus,
                        onNavigate: { dest in
                            showSettingsDrawer = false
                            drawerDestination = dest
                        }
                    )
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .padding(.trailing, 8)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(duration: 0.28), value: showSettingsDrawer)
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
                    BoundaryMoodIndicator(boundary: boundary)
                }
            }

            // Principal: AI status label (7.5) — shown below nav title via subtitle trick
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    if let status = viewModel.agentStatus {
                        AgentStatusBadge(status: status)
                    }
                    Button {
                        withAnimation(.spring(duration: 0.28)) {
                            showSettingsDrawer.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .gradientBackground()
        .navigationDestination(item: $drawerDestination) { dest in
            switch dest {
            case .memory: MemoryTimelineView()
            case .emotion: EmotionTimelineView()
            case .portrait: UserPortraitView()
            case .schedule: ScheduleHistoryView()
            case .settings: SettingsView()
            }
        }
        .task {
            await viewModel.loadHistory()
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.viewModel.loadStatus() }
                group.addTask { await self.viewModel.loadIntimacy() }
                group.addTask { await self.viewModel.loadBoundary() }
                group.addTask { await self.viewModel.loadEmotion() }
                group.addTask { await self.viewModel.connectToChat() }
            }
            viewModel.startStatusPolling()
        }
        .onDisappear {
            viewModel.stopStatusPolling()
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

            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isConnected ? Color.green.opacity(0.8) : Color.orange.opacity(0.8))
                    .frame(width: 7, height: 7)
                Text(viewModel.deliveryHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)

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

// MARK: - EmotionBadge

private struct EmotionBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let emotion: EmotionState

    private var color: Color {
        switch emotion.tone {
        case "高兴", "喜悦", "兴奋": return .pink
        case "平静", "放松": return .teal
        case "难过", "伤心", "忧郁": return .blue
        case "愤怒", "生气": return .red
        case "焦虑", "紧张": return .orange
        default: return .secondary
        }
    }

    private var padColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.55) : Color.black.opacity(0.45)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.06)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.1)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.22) : Color.black.opacity(0.08)
    }

    private var padText: String {
        String(
            format: "P%+.1f  A%+.1f  D%+.1f",
            emotion.pleasure,
            emotion.arousal,
            emotion.dominance
        )
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            badgeContent(spacing: 6, toneSize: 10, padSize: 9)
            badgeContent(spacing: 5, toneSize: 9, padSize: 8)
            compactBadge
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(borderColor, lineWidth: 0.8)
        )
        .shadow(color: shadowColor, radius: 8, y: 3)
    }

    private func badgeContent(spacing: CGFloat, toneSize: CGFloat, padSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text(emotion.tone)
                .font(.system(size: toneSize, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(padText)
                .font(.system(size: padSize, weight: .medium, design: .monospaced))
                .foregroundStyle(padColor)
                .lineLimit(1)
        }
    }

    private var compactBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)

            Text(emotion.tone)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Text(String(format: "P%.1f", emotion.pleasure))
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(padColor)
                .lineLimit(1)
        }
    }
}

// MARK: - AgentStatusBadge (7.5)

private struct AgentStatusBadge: View {
    let status: AgentStatus

    private var color: Color {
        switch status.status {
        case "sleep": return .indigo
        case "very_busy": return .red
        case "busy":  return .orange
        default:      return .green
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.statusIcon)
                .font(.system(size: 9))
            Text("\(status.displayStatus) · \(status.activity)")
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
    let boundary: BoundaryStatus

    private var icon: String {
        switch boundary.zone {
        case "blocked": return "xmark.circle.fill"
        case "low": return "exclamationmark.triangle.fill"
        case "medium": return "cloud.fill"
        default: return "face.smiling"
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text("\(boundary.patience)")
                .font(.caption2)
        }
        .foregroundStyle(boundary.zoneColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(boundary.zoneColor.opacity(0.12))
        .clipShape(Capsule())
    }
}

// MARK: - DrawerDestination

enum DrawerDestination: Hashable, Identifiable {
    case memory, emotion, portrait, schedule, settings
    var id: Self { self }
}

// MARK: - ChatSideDrawer

private struct ChatSideDrawer: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Binding var isPresented: Bool
    @GestureState private var dragOffset: CGFloat = 0
    let emotionState: EmotionState?
    let intimacy: IntimacyData?
    let boundary: BoundaryStatus?
    var onNavigate: (DrawerDestination) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 34, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appViewModel.agentName ?? String(localized: "更多"))
                            .font(.title3.weight(.semibold))
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(duration: 0.28)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }

                // 状态面板：情绪 + 亲密度 + 耐心
                VStack(spacing: 10) {
                    if let emotionState {
                        drawerMetric(label: "情绪", systemImage: "heart.fill") {
                            EmotionBadge(emotion: emotionState)
                        }
                    }
                    if let intimacy {
                        drawerMetric(label: "亲密度", systemImage: "person.2.fill") {
                            HStack(spacing: 6) {
                                Text(intimacy.level.label)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(intimacy.level.badgeColor)
                                Text(String(format: "%.0f", intimacy.level.score))
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(intimacy.level.badgeColor.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                    if let boundary {
                        drawerMetric(label: "耐心", systemImage: "gauge.medium") {
                            HStack(spacing: 6) {
                                Text(boundary.zoneTone)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(boundary.zoneColor)
                                Text("\(boundary.patience)")
                                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(boundary.zoneColor.opacity(0.12))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("快捷入口")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 10) {
                        drawerButton(title: "记忆", subtitle: "查看 L1 / L2 / L3 记忆", systemImage: "brain.head.profile") {
                            onNavigate(.memory)
                        }
                        drawerButton(title: "情绪", subtitle: "查看情绪轨迹和当前状态", systemImage: "heart.text.square") {
                            onNavigate(.emotion)
                        }
                        drawerButton(title: "画像", subtitle: "查看用户与 AI 画像", systemImage: "person.text.rectangle") {
                            onNavigate(.portrait)
                        }
                        drawerButton(title: "作息", subtitle: "查看生活画像和每日作息", systemImage: "calendar.badge.clock") {
                            onNavigate(.schedule)
                        }
                        drawerButton(title: "设置", subtitle: "主题、语言和清空数据", systemImage: "gearshape") {
                            onNavigate(.settings)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .frame(width: 296)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 28, x: -12, y: 0)
        .offset(x: max(0, dragOffset))
        .gesture(
            DragGesture(minimumDistance: 12)
                .updating($dragOffset) { value, state, _ in
                    if value.translation.width > 0 {
                        state = value.translation.width
                    }
                }
                .onEnded { value in
                    guard value.translation.width > 72 else { return }
                    withAnimation(.spring(duration: 0.28)) {
                        isPresented = false
                    }
                }
        )
    }

    private func drawerMetric<Content: View>(
        label: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .frame(width: 14)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            content()
        }
    }

    private func drawerButton(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
}
