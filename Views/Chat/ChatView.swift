import SwiftUI

struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @State private var showDrawer = false
    @State private var showEmojiPanel = false
    @State private var showMorePanel = false
    @State private var lastVisibleIndex = -1
    @State private var messageScrollTarget: String? = PrototypeMessageList.bottomID
    @State private var composerHeight: CGFloat = 116

    private let openRoute: ((PrototypeRoute) -> Void)?
    private let panelAnimation = Animation.spring(response: 0.32, dampingFraction: 0.84)

    init(
        conversationId: String,
        agentId: String,
        userId: String,
        openRoute: ((PrototypeRoute) -> Void)? = nil
    ) {
        self.openRoute = openRoute
        _viewModel = State(initialValue: ChatViewModel(
            conversationId: conversationId,
            agentId: agentId,
            userId: userId
        ))
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, animatesBackground: false) {
            ZStack(alignment: .bottomTrailing) {
                chatSurface
                .blur(radius: showDrawer ? 3.5 : 0)

                if showDrawer {
                    drawerOverlay
                }
            }
        }
        .task {
            await startChat()
        }
        .onDisappear(perform: stopChat)
    }

    private var chatSurface: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                PrototypeChatHeader(
                    agentName: appViewModel.agentName ?? PrototypeFixtures.agentName,
                    status: viewModel.agentStatus,
                    onProfile: { openRoute?(.portrait) },
                    onDrawer: { toggleDrawer() }
                )

                messageArea
            }

            blockedOverlay
                .padding(.bottom, composerHeight)

            PrototypeChatComposer(
                text: $viewModel.inputText,
                isFocused: $isInputFocused,
                isWaitingReply: viewModel.isWaitingReply,
                showEmojiPanel: $showEmojiPanel,
                showMorePanel: $showMorePanel,
                onSend: sendMessage
            )
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ChatComposerHeightKey.self, value: proxy.size.height)
                }
            )
        }
        .onPreferenceChange(ChatComposerHeightKey.self) { height in
            guard height > 0, abs(height - composerHeight) > 0.5 else { return }
            withAnimation(panelAnimation) {
                composerHeight = height
                messageScrollTarget = PrototypeMessageList.bottomID
            }
        }
    }

    private var messageArea: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                PrototypeMessageList(
                    messages: viewModel.messages,
                    isLoading: viewModel.isLoading,
                    isLoadingMore: viewModel.isLoadingMoreHistory,
                    hasMoreHistory: viewModel.hasMoreHistory,
                    isTyping: viewModel.isTyping,
                    bottomInset: composerHeight,
                    scrollTarget: $messageScrollTarget,
                    loadMoreHistory: { Task { await viewModel.loadMoreHistory() } },
                    onMessageVisible: { index in
                        guard index > lastVisibleIndex else { return }
                        lastVisibleIndex = index
                    }
                )
                .onTapGesture {
                    isInputFocused = false
                    showEmojiPanel = false
                    showMorePanel = false
                }

                if viewModel.hasUnreadReply && lastVisibleIndex < viewModel.messages.count - 4 && !viewModel.isTyping {
                    Button {
                        scrollToBottom(proxy)
                        viewModel.hasUnreadReply = false
                    } label: {
                        Label("新消息", systemImage: "arrow.down")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .prototypeLiquidGlass(cornerRadius: 17, tint: .white.opacity(0.28), interactive: true)
                    }
                    .padding(.bottom, 10)
                    .buttonStyle(.prototypeGlassProminentPress)
                }
            }
            .onChange(of: viewModel.scrollToBottom) {
                guard viewModel.scrollToBottom else { return }
                scrollToBottom(proxy)
                viewModel.scrollToBottom = false
            }
            .onChange(of: viewModel.messages.count) { oldCount, newCount in
                if oldCount == 0 && newCount > 0 {
                    proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.hasUnreadReply) {
                guard viewModel.hasUnreadReply else { return }
                if lastVisibleIndex >= viewModel.messages.count - 4 {
                    scrollToBottom(proxy)
                    viewModel.hasUnreadReply = false
                }
            }
            .onChange(of: showMorePanel) { wasOpen, isOpen in
                keepBottomPinnedAfterComposerChange(proxy, wasOpen: wasOpen, isOpen: isOpen)
            }
            .onChange(of: showEmojiPanel) { wasOpen, isOpen in
                keepBottomPinnedAfterComposerChange(proxy, wasOpen: wasOpen, isOpen: isOpen)
            }
            .onChange(of: composerHeight) {
                syncMessageListWithComposer(proxy)
            }
        }
    }

    @ViewBuilder
    private var blockedOverlay: some View {
        if viewModel.boundaryStatus?.zone == "blocked" {
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .foregroundStyle(.red)
                Text("对方暂时不想聊天，试着道个歉吧")
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .prototypeLiquidGlass(cornerRadius: 0, tint: .white.opacity(0.18))
        }
    }

    private var drawerOverlay: some View {
        ZStack(alignment: .trailing) {
            Color.black.opacity(0.14)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { toggleDrawer() }

            PrototypeChatDrawer(
                emotionState: viewModel.emotionState,
                intimacy: viewModel.intimacy,
                boundary: viewModel.boundaryStatus,
                onNavigate: { route in
                    showDrawer = false
                    openRoute?(route)
                }
            )
            .padding(.trailing, 12)
            .padding(.bottom, 116)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }

    private func startChat() async {
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

    private func stopChat() {
        viewModel.stopStatusPolling()
        viewModel.disconnectFromChat()
    }

    private func sendMessage() {
        viewModel.send()
        isInputFocused = false
        showEmojiPanel = false
        showMorePanel = false
    }

    private func toggleDrawer() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            showDrawer.toggle()
            showEmojiPanel = false
            showMorePanel = false
            isInputFocused = false
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            messageScrollTarget = PrototypeMessageList.bottomID
            proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
        }
    }

    private func keepBottomPinnedAfterComposerChange(_ proxy: ScrollViewProxy, wasOpen: Bool, isOpen: Bool) {
        guard wasOpen || isOpen || lastVisibleIndex >= viewModel.messages.count - 3 else { return }
        animateMessageListBottom(proxy)
        Task { @MainActor in
            await Task.yield()
            animateMessageListBottom(proxy)
        }
    }

    private func animateMessageListBottom(_ proxy: ScrollViewProxy) {
        withAnimation(panelAnimation) {
            messageScrollTarget = PrototypeMessageList.bottomID
            proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
        }
    }

    private func syncMessageListWithComposer(_ proxy: ScrollViewProxy) {
        guard lastVisibleIndex >= viewModel.messages.count - 4 || showEmojiPanel || showMorePanel else { return }
        animateMessageListBottom(proxy)
    }
}

private struct ChatComposerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
