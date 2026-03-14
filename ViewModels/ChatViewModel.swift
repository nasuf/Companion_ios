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

    func loadHistory() async {
        isLoading = true
        do {
            messages = try await ChatService.loadMessages(conversationId: conversationId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
        scrollToBottom = true
    }

    func loadStatus() async {
        agentStatus = try? await AgentService.getStatus(agentId: agentId)
    }

    func loadIntimacy() async {
        intimacy = try? await IntimacyService.get(agentId: agentId, userId: userId)
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
