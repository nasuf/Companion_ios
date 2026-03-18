import Foundation

struct ChatRequest: Encodable {
    let message: String
}

enum ChatService {
    private static let ws = WebSocketClient()

    /// 建立 WebSocket 连接，返回事件流
    static func connect(conversationId: String) async -> AsyncThrowingStream<SSEEvent, Error> {
        await ws.connect(conversationId: conversationId)
    }

    /// 通过 WebSocket 发送消息
    static func send(message: String) async throws {
        try await ws.send(message: message)
    }

    /// 断开 WebSocket 连接
    static func disconnect() async {
        await ws.disconnect()
    }

    /// REST API 加载历史消息（WebSocket 不涉及历史加载）
    static func loadMessages(conversationId: String, limit: Int = 100, offset: Int = 0) async throws -> [Message] {
        try await APIClient.shared.request(
            method: "GET",
            path: "/conversations/\(conversationId)/messages?limit=\(limit)&offset=\(offset)"
        )
    }
}
