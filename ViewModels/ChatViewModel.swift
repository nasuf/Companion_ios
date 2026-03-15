import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var inputText = ""
    var isStreaming = false
    var isLoading = false
    var isTyping = false          // AI is composing (typing indicator phase)
    var error: String?
    var scrollToBottom = false

    // AI status (7.5)
    var agentStatus: AgentStatus?

    // Intimacy (7.7)
    var intimacy: IntimacyData?

    // Boundary (7.6)
    var boundaryStatus: BoundaryStatus?

    private let conversationId: String
    private let agentId: String
    private let userId: String
    private var streamTask: Task<Void, Never>?
    private var typingTask: Task<Void, Never>?

    init(conversationId: String, agentId: String, userId: String) {
        self.conversationId = conversationId
        self.agentId = agentId
        self.userId = userId
    }

    private let pageSize = 100
    var hasMoreHistory = false
    var isLoadingMoreHistory = false
    private var historyOffset = 0

    func loadHistory() async {
        isLoading = true
        do {
            // Fetch latest 100 (returned newest-first from API) and reverse for display
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
            // Prepend older messages (reversed so oldest-first)
            messages = fetched.reversed() + messages
            historyOffset += fetched.count
            hasMoreHistory = fetched.count == pageSize
        } catch {
            self.error = error.localizedDescription
        }
        isLoadingMoreHistory = false
    }

    func loadStatus() async {
        agentStatus = try? await AgentService.getStatus(agentId: agentId)
    }

    func loadIntimacy() async {
        intimacy = try? await IntimacyService.get(agentId: agentId, userId: userId)
    }

    func loadBoundary() async {
        boundaryStatus = try? await BoundaryService.get(agentId: agentId, userId: userId)
    }

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }

        inputText = ""
        let userMsg = Message.userMessage(conversationId: conversationId, content: text)
        messages.append(userMsg)

        let aiMsg = Message.assistantPlaceholder(conversationId: conversationId)
        messages.append(aiMsg)
        let aiIndex = messages.count - 1

        isStreaming = true
        isTyping = false
        scrollToBottom = true
        error = nil

        streamTask = Task {
            do {
                let stream = await ChatService.send(conversationId: conversationId, message: text)
                for try await event in stream {
                    switch event {
                    case .typing(let duration):
                        isTyping = true
                        typingTask?.cancel()
                        typingTask = Task {
                            try? await Task.sleep(for: .seconds(duration))
                            if !Task.isCancelled {
                                isTyping = false
                            }
                        }

                    case .token(let token):
                        isTyping = false
                        typingTask?.cancel()
                        let current = messages[aiIndex]
                        messages[aiIndex] = Message(
                            id: current.id,
                            conversationId: current.conversationId,
                            role: .assistant,
                            content: current.content + token,
                            createdAt: current.createdAt
                        )
                        scrollToBottom = true
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
            typingTask?.cancel()
            isStreaming = false
            isTyping = false
        }
    }

    func cancel() {
        streamTask?.cancel()
        typingTask?.cancel()
        isStreaming = false
        isTyping = false
    }
}
