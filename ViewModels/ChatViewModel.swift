import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var inputText = ""
    var isConnected = false
    var isWaitingReply = false  // AI 正在生成回复
    var isTyping = false       // 显示"正在输入"指示器
    var deliveryHint = "在线"
    var countdown: Int?
    private var countdownTimer: Timer?
    var error: String?
    var scrollToBottom = false
    var hasUnreadReply = false

    // AI status (7.5)
    var agentStatus: AgentStatus?

    // Intimacy (7.7)
    var intimacy: IntimacyData?

    // Boundary (7.6)
    var boundaryStatus: BoundaryStatus?

    // Emotion (real-time PAD)
    var emotionState: EmotionState?

    private let conversationId: String
    private let agentId: String
    private let userId: String
    private var listenTask: Task<Void, Never>?
    private var typingTask: Task<Void, Never>?
    private var reconnectAttempts = 0
    private let maxReconnectDelay: Double = 30

    init(conversationId: String, agentId: String, userId: String) {
        self.conversationId = conversationId
        self.agentId = agentId
        self.userId = userId
    }

    private let pageSize = 100
    var hasMoreHistory = false
    var isLoadingMoreHistory = false
    var isLoading = false
    private var historyOffset = 0

    // MARK: - History (REST API)

    func loadHistory() async {
        isLoading = true
        do {
            let fetched = try await ChatService.loadMessages(
                conversationId: conversationId,
                limit: pageSize,
                offset: 0
            )
            messages = fetched.reversed()
            historyOffset = fetched.count
            hasMoreHistory = fetched.count == pageSize
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
        scrollToBottom = true
    }

    func loadMoreHistory() async {
        guard hasMoreHistory, !isLoadingMoreHistory else { return }
        isLoadingMoreHistory = true
        do {
            let fetched = try await ChatService.loadMessages(
                conversationId: conversationId,
                limit: pageSize,
                offset: historyOffset
            )
            messages = fetched.reversed() + messages
            historyOffset += fetched.count
            hasMoreHistory = fetched.count == pageSize
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingMoreHistory = false
    }

    // MARK: - Status loaders

    func loadStatus() async {
        agentStatus = try? await AgentService.getStatus(agentId: agentId)
    }

    func loadIntimacy() async {
        intimacy = try? await IntimacyService.get(agentId: agentId, userId: userId)
    }

    func loadBoundary() async {
        boundaryStatus = try? await BoundaryService.get(agentId: agentId, userId: userId)
    }

    func loadEmotion() async {
        emotionState = try? await EmotionService.current(agentId: agentId)
    }

    // MARK: - WebSocket 连接

    func connectToChat() async {
        let stream = await ChatService.connect(conversationId: conversationId)
        isConnected = true
        deliveryHint = "在线"
        reconnectAttempts = 0

        listenTask = Task {
            do {
                for try await event in stream {
                    await handleEvent(event)
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }

            // 连接断开 — 尝试重连
            isConnected = false
            isTyping = false
            isWaitingReply = false
            deliveryHint = "重连中"
            typingTask?.cancel()

            if !Task.isCancelled {
                await reconnect()
            }
        }
    }

    func disconnectFromChat() {
        listenTask?.cancel()
        listenTask = nil
        typingTask?.cancel()
        typingTask = nil
        isConnected = false
        isTyping = false
        isWaitingReply = false
        deliveryHint = "已断开"
        Task { await ChatService.disconnect() }
    }

    private func reconnect() async {
        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts - 1)), maxReconnectDelay)
        try? await Task.sleep(for: .seconds(delay))
        guard !Task.isCancelled else { return }

        // 重连后加载可能错过的消息
        await loadHistory()
        await connectToChat()
    }

    // MARK: - 发送消息

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, isConnected else { return }

        inputText = ""

        // 只插入用户消息气泡，不创建 AI placeholder
        let userMsg = Message.userMessage(conversationId: conversationId, content: text)
        messages.append(userMsg)
        scrollToBottom = true
        isWaitingReply = true
        deliveryHint = "发送中"
        error = nil

        Task {
            do {
                try await ChatService.send(message: text)
            } catch {
                self.error = error.localizedDescription
                isWaitingReply = false
                deliveryHint = "发送失败"
            }
        }
    }

    // MARK: - 事件处理

    @MainActor
    private func handleEvent(_ event: SSEEvent) {
        switch event {
        case .typing(let duration):
            isTyping = true
            deliveryHint = "对方正在输入…"
            stopCountdown()
            typingTask?.cancel()
            typingTask = Task {
                try? await Task.sleep(for: .seconds(duration))
                if !Task.isCancelled {
                    isTyping = false
                    if self.isConnected {
                        self.deliveryHint = "在线"
                    }
                }
            }

        case .delay(let duration):
            isTyping = true
            let d = Int(duration.rounded())
            deliveryHint = "预计 \(d) 秒后回复"
            startCountdown(seconds: d)
            typingTask?.cancel()
            typingTask = Task {
                try? await Task.sleep(for: .seconds(min(duration, 10)))
                if !Task.isCancelled {
                    isTyping = false
                }
            }

        case .reply(let text, _, _):
            isTyping = false
            typingTask?.cancel()
            stopCountdown()
            deliveryHint = "在线"

            // 微信模式：直接插入完整消息气泡
            let msg = Message.assistantMessage(conversationId: conversationId, content: text)
            // TODO: 处理 stickerURL（如需要）
            messages.append(msg)
            hasUnreadReply = true
            
            // Refresh real-time status
            Task {
                await loadEmotion()
                await loadBoundary()
                await loadIntimacy()
            }

        case .token(let token):
            // 兼容旧的 boundary/template 回复
            isTyping = false
            typingTask?.cancel()
            stopCountdown()
            if let last = messages.last, last.role == .assistant {
                let updated = Message(
                    id: last.id,
                    conversationId: last.conversationId,
                    role: .assistant,
                    content: last.content + token,
                    createdAt: last.createdAt
                )
                messages[messages.count - 1] = updated
            } else {
                messages.append(Message.assistantMessage(conversationId: conversationId, content: token))
            }
            hasUnreadReply = true

        case .pending(let status, let delay):
            switch status {
            case "aggregating":
                deliveryHint = "消息已进入聚合"
                stopCountdown()
            case "queued":
                if let delay = delay {
                    let d = Int(delay.rounded())
                    deliveryHint = "已排队，预计 \(d) 秒后回复"
                    if d > 0 {
                        startCountdown(seconds: d)
                    } else {
                        stopCountdown()
                    }
                } else {
                    deliveryHint = "消息已排队"
                    stopCountdown()
                }
            default:
                deliveryHint = "消息处理中"
                stopCountdown()
            }

        case .proactive(let text, _):
            // 服务端主动消息
            stopCountdown()
            let msg = Message.assistantMessage(conversationId: conversationId, content: text)
            messages.append(msg)
            hasUnreadReply = true
            deliveryHint = "在线"
            
            Task { await loadEmotion() }

        case .done:
            isWaitingReply = false
            isTyping = false
            typingTask?.cancel()
            stopCountdown()
            deliveryHint = isConnected ? "在线" : "已断开"
            scrollToBottom = true
            
            Task {
                await loadEmotion()
                await loadBoundary()
                await loadIntimacy()
            }
        }
    }

    private func startCountdown(seconds: Int) {
        stopCountdown()
        countdown = seconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let current = self.countdown, current > 1 {
                self.countdown = current - 1
                // 保持提示词前缀，仅更新数字
                if self.deliveryHint.contains("排队") {
                    self.deliveryHint = "已排队，预计 \(current - 1) 秒后回复"
                } else if self.deliveryHint.contains("预计") {
                    self.deliveryHint = "预计 \(current - 1) 秒后回复"
                }
            } else {
                self.stopCountdown()
                self.deliveryHint = "即将回复"
            }
        }
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdown = nil
    }

    func cancel() {
        disconnectFromChat()
    }
}
