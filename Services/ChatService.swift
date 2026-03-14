import Foundation

struct ChatRequest: Encodable {
    let message: String
}

enum ChatService {
    static func send(conversationId: String, message: String) async -> AsyncThrowingStream<SSEEvent, Error> {
        await APIClient.shared.stream(
            path: "/chat/\(conversationId)",
            body: ChatRequest(message: message)
        )
    }

    static func loadMessages(conversationId: String) async throws -> [Message] {
        try await APIClient.shared.request(
            method: "GET",
            path: "/conversations/\(conversationId)/messages"
        )
    }
}
