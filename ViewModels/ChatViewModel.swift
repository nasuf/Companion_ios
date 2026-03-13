import Foundation

@Observable
final class ChatViewModel {
    var messages: [Message] = []
    var inputText = ""
    var isStreaming = false
    var isLoading = false
    var error: String?
    var scrollToBottom = false

    private let conversationId: String
    private var streamTask: Task<Void, Never>?

    init(conversationId: String) {
        self.conversationId = conversationId
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
        scrollToBottom = true
        error = nil

        streamTask = Task {
            do {
                let stream = await ChatService.send(conversationId: conversationId, message: text)
                for try await token in stream {
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
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                }
            }
            isStreaming = false
        }
    }

    func cancel() {
        streamTask?.cancel()
        isStreaming = false
    }
}
