import SwiftUI
import UIKit

struct ChatView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel: ChatViewModel
    @State private var isInputFocused = false
    @State private var showDrawer = false
    @State private var inputMode: PrototypeChatInputMode = .none
    @State private var lastVisibleIndex = -1
    @State private var isBottomVisible = true
    @State private var composerHeight: CGFloat = 88
    @State private var isKeyboardVisible = false
    @State private var keyboardReplacementHeight: CGFloat = 286
    @State private var pinBottomForInputTransition = false

    private let openRoute: ((PrototypeRoute) -> Void)?
    private let panelAnimation = Animation.spring(response: 0.32, dampingFraction: 0.84)
    private let emojiPanelHeight: CGFloat = 190
    private let customPanelSpacing: CGFloat = 12

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
        .background(ChatKeyboardPrewarmView())
        .task {
            await startChat()
        }
        .onDisappear(perform: stopChat)
    }

    private var chatSurface: some View {
        VStack(spacing: 0) {
            PrototypeChatHeader(
                agentName: appViewModel.agentName ?? PrototypeFixtures.agentName,
                status: viewModel.agentStatus,
                onProfile: { openRoute?(.portrait) },
                onDrawer: { toggleDrawer() }
            )

            ZStack(alignment: .bottom) {
                messageArea(bottomInset: reservedComposerHeight)

                blockedOverlay
                    .padding(.bottom, reservedComposerHeight)

                PrototypeChatComposer(
                    text: $viewModel.inputText,
                    isWaitingReply: viewModel.isWaitingReply,
                    inputMode: $inputMode,
                    emojiPanelHeight: emojiPanelHeight,
                    accessoryPanelHeight: keyboardReplacementHeight,
                    onFocusChanged: handleInputFocusChanged,
                    onSend: sendMessage
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: ChatComposerHeightKey.self, value: proxy.size.height)
                    }
                )
            }
        }
        .onPreferenceChange(ChatComposerHeightKey.self) { height in
            guard inputMode == .none || inputMode == .keyboard else { return }
            guard height > 0, abs(height - composerHeight) > 0.5 else { return }
            withAnimation(panelAnimation) {
                composerHeight = height
            }
        }
    }

    private func messageArea(bottomInset: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                PrototypeMessageList(
                    messages: viewModel.messages,
                    isLoading: viewModel.isLoading,
                    isLoadingMore: viewModel.isLoadingMoreHistory,
                    hasMoreHistory: viewModel.hasMoreHistory,
                    canLoadMoreHistory: canLoadMoreHistory,
                    isTyping: viewModel.isTyping,
                    bottomInset: effectiveMessageBottomInset(bottomInset),
                    loadMoreHistory: { Task { await viewModel.loadMoreHistory() } },
                    onMessageVisible: { index in
                        guard index > lastVisibleIndex else { return }
                        lastVisibleIndex = index
                    },
                    onBottomVisibilityChanged: { isVisible in
                        isBottomVisible = isVisible
                    }
                )
                .onTapGesture {
                    dismissKeyboard()
                    inputMode = .none
                }
                .animation(panelAnimation, value: reservedComposerHeight)

                if viewModel.hasUnreadReply && lastVisibleIndex < viewModel.messages.count - 4 && !viewModel.isTyping {
                    Button {
                        scrollToBottom(proxy)
                        viewModel.hasUnreadReply = false
                    } label: {
                        Label("新消息", systemImage: "arrow.down")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
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
            .onChange(of: inputMode) { oldMode, newMode in
                handleInputModeChanged(from: oldMode, to: newMode, proxy: proxy)
            }
            .onChange(of: reservedComposerHeight) {
                syncBottomAfterLayoutChange(proxy, animation: panelAnimation)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
                syncBottomWithKeyboard(proxy, notification: notification)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                syncBottomWithKeyboard(proxy, notification: notification)
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
            .background(Color.white.opacity(0.92))
            .padding(.bottom, 8)
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
        dismissKeyboard()
        inputMode = .none
    }

    private func toggleDrawer() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            showDrawer.toggle()
            inputMode = .none
            dismissKeyboard()
        }
    }

    private func handleInputFocusChanged(_ focused: Bool) {
        isInputFocused = focused
        if focused {
            inputMode = .keyboard
        } else if inputMode == .keyboard {
            inputMode = .none
        }
    }

    private func handleInputModeChanged(from oldMode: PrototypeChatInputMode, to newMode: PrototypeChatInputMode, proxy: ScrollViewProxy) {
        guard oldMode != newMode else { return }
        pinBottomForInputTransition = shouldStartPinnedInputTransition(from: oldMode, to: newMode)
        guard pinBottomForInputTransition else { return }
        scrollToBottomAfterLayout(proxy, delayNanoseconds: 0, animation: panelAnimation)
        if newMode == .none {
            resetInputTransitionPinLater()
        }
    }

    private func dismissKeyboard() {
        isInputFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
        }
    }

    private func syncBottomAfterLayoutChange(_ proxy: ScrollViewProxy, animation: Animation?) {
        guard shouldKeepBottomPinned else { return }
        scrollToBottomAfterLayout(proxy, delayNanoseconds: 0, animation: animation)
    }

    private func syncBottomWithKeyboard(_ proxy: ScrollViewProxy, notification: Notification) {
        let screenHeight = UIScreen.main.bounds.height
        let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let wasKeyboardVisible = isKeyboardVisible
        let willBeKeyboardVisible = endFrame.minY < screenHeight - 1
        let keyboardHeight = max(0, screenHeight - endFrame.minY)
        if keyboardHeight > 120 {
            keyboardReplacementHeight = keyboardHeight
        }
        isKeyboardVisible = willBeKeyboardVisible

        guard inputMode == .keyboard || inputMode == .none else { return }
        guard shouldKeepBottomPinned || wasKeyboardVisible || willBeKeyboardVisible else { return }
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let animation = Animation.easeOut(duration: max(0.16, duration))
        scrollToBottomAfterLayout(proxy, delayNanoseconds: 0, animation: animation)
    }

    private func scrollToBottomAfterLayout(_ proxy: ScrollViewProxy, delayNanoseconds: UInt64, animation: Animation?) {
        Task { @MainActor in
            if delayNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: delayNanoseconds)
            } else {
                await Task.yield()
            }
            animateMessageListBottom(proxy, animation: animation)
        }
    }

    private func animateMessageListBottom(_ proxy: ScrollViewProxy, animation: Animation?) {
        if let animation {
            withAnimation(animation) {
                proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
            }
        } else {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                proxy.scrollTo(PrototypeMessageList.bottomID, anchor: .bottom)
            }
        }
    }

    private func effectiveMessageBottomInset(_ baseInset: CGFloat) -> CGFloat {
        max(baseInset, 8)
    }

    private var shouldKeepBottomPinned: Bool {
        isBottomVisible || isKeyboardVisible || inputMode != .none || pinBottomForInputTransition || viewModel.messages.count <= 4
    }

    private var canLoadMoreHistory: Bool {
        !isInputFocused && !isKeyboardVisible && inputMode == .none
    }

    private var reservedComposerHeight: CGFloat {
        switch inputMode {
        case .emoji:
            composerHeight + customPanelSpacing + emojiPanelHeight
        case .more:
            composerHeight + customPanelSpacing + keyboardReplacementHeight
        case .none, .keyboard:
            composerHeight
        }
    }

    private func shouldStartPinnedInputTransition(from oldMode: PrototypeChatInputMode, to newMode: PrototypeChatInputMode) -> Bool {
        isBottomVisible || oldMode != .none || newMode != .none || isKeyboardVisible || viewModel.messages.count <= 4
    }

    private func resetInputTransitionPinLater() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 360_000_000)
            if inputMode == .none {
                pinBottomForInputTransition = false
            }
        }
    }
}

private struct ChatComposerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ChatKeyboardPrewarmView: UIViewRepresentable {
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        textField.alpha = 0.01
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
        textField.isAccessibilityElement = false
        textField.textColor = .clear
        textField.tintColor = .clear
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.smartQuotesType = .no
        textField.textContentType = .none
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []

        Task { @MainActor in
            for _ in 1...20 {
                guard !context.coordinator.didPrewarm else { return }
                if textField.window != nil { break }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            guard textField.window != nil else { return }
            guard !context.coordinator.didPrewarm else { return }
            context.coordinator.didPrewarm = true
            UIView.performWithoutAnimation {
                textField.becomeFirstResponder()
                textField.reloadInputViews()
            }
            try? await Task.sleep(nanoseconds: 20_000_000)
            UIView.performWithoutAnimation {
                textField.resignFirstResponder()
            }
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var didPrewarm = false
    }
}
