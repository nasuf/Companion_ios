import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var inputText = ""
    var isConnected = false
    var isWaitingReply = false  // AI 正在生成回复
    var isTyping = false       // 显示"正在输入"指示器
    var deliveryHint = "在线"
    var error: String?
    var scrollToBottom = false
    var hasUnreadReply = false

    // AI status (7.5)
    var agentStatus: AgentStatus?

    // Intimacy (7.7)
    var intimacy: IntimacyData?

    // Boundary (7.6)
    var boundaryStatus: BoundaryStatus?

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

    // MARK: - WebSocket 连接

    func connectToChat() async {
        let stream = await ChatService.connect(conversationId: conversationId)
        isConnected = true
        deliveryHint = "在线"
        reconnectAttempts = 0

        listenTask = Task {
            do {
                for try await event in stream {
                    handleEvent(event)
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

    private func handleEvent(_ event: SSEEvent) {
        switch event {
        case .typing(let duration):
            isTyping = true
            deliveryHint = "对方正在输入…"
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
            deliveryHint = "预计 \(Int(duration.rounded())) 秒后回复"
            typingTask?.cancel()
            typingTask = Task {
                try? await Task.sleep(for: .seconds(min(duration, 10)))
                if !Task.isCancelled {
                    isTyping = false
                }
            }

        case .reply(let text, _, let stickerURL):
            isTyping = false
            typingTask?.cancel()
            deliveryHint = "在线"

            // 微信模式：直接插入完整消息气泡
            var msg = Message.assistantMessage(conversationId: conversationId, content: text)
            // TODO: 处理 stickerURL（如需要）
            messages.append(msg)
            hasUnreadReply = true

        case .token(let token):
            // 兼容旧的 boundary/template 回复
            isTyping = false
            typingTask?.cancel()
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
            case "queued":
                if let delay {
                    deliveryHint = "已排队，预计 \(Int(delay.rounded())) 秒后回复"
                } else {
                    deliveryHint = "消息已排队"
                }
            default:
                deliveryHint = "消息处理中"
            }

        case .proactive(let text, _):
            // 服务端主动消息
            let msg = Message.assistantMessage(conversationId: conversationId, content: text)
            messages.append(msg)
            hasUnreadReply = true
            deliveryHint = "在线"

        case .done:
            isWaitingReply = false
            isTyping = false
            typingTask?.cancel()
            deliveryHint = isConnected ? "在线" : "已断开"
        }
    }

    func cancel() {
        disconnectFromChat()
    }
}
