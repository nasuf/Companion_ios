import Foundation

enum BackendConfig {
    static var baseURL: String {
        if let override = ProcessInfo.processInfo.environment["API_BASE_URL"],
           !override.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return override
        }

#if DEBUG
        #if targetEnvironment(simulator)
        return "http://127.0.0.1:8000"
        #else
        return "http://192.168.1.102:8000"
        #endif
#else
        return "http://127.0.0.1:8000"
#endif
    }
}

enum SSEEvent {
    case token(String)
    case reply(text: String, index: Int, stickerURL: String?)
    case typing(duration: Double)
    case delay(duration: Double)
    case pending(status: String, delay: Double?)
    case proactive(text: String, agentId: String)
    case done
}


// MARK: - WebSocket Client

actor WebSocketClient {
    private var task: URLSessionWebSocketTask?
    private var pingTask: Task<Void, Never>?
    private var isConnected = false
    private let baseURL: String

    init() {
        self.baseURL = BackendConfig.baseURL
    }

    func connect(conversationId: String) -> AsyncThrowingStream<SSEEvent, Error> {
        disconnect()

        let wsURL = baseURL
            .replacingOccurrences(of: "http://", with: "ws://")
            .replacingOccurrences(of: "https://", with: "wss://")
        guard let url = URL(string: "\(wsURL)/ws/\(conversationId)") else {
            return AsyncThrowingStream { $0.finish(throwing: APIError.invalidURL) }
        }

        let session = URLSession(configuration: .default)
        let wsTask = session.webSocketTask(with: url)
        self.task = wsTask
        wsTask.resume()
        isConnected = true

        startPing()

        return AsyncThrowingStream { continuation in
            Task {
                defer {
                    continuation.finish()
                }
                while self.isConnected {
                    do {
                        let msg = try await wsTask.receive()
                        switch msg {
                        case .string(let text):
                            guard let data = text.data(using: .utf8),
                                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                  let type = json["type"] as? String,
                                  let payload = json["data"] as? [String: Any]
                            else { continue }

                            switch type {
                            case "typing":
                                let dur = payload["duration"] as? Double ?? 1.0
                                continuation.yield(.typing(duration: dur))
                            case "delay":
                                let dur = payload["duration"] as? Double ?? 5.0
                                continuation.yield(.delay(duration: dur))
                            case "reply":
                                if let text = payload["text"] as? String,
                                   let index = payload["index"] as? Int {
                                    let sticker = payload["sticker_url"] as? String
                                    continuation.yield(.reply(text: text, index: index, stickerURL: sticker))
                                }
                            case "pending":
                                let status = payload["status"] as? String ?? "pending"
                                let delay = payload["delay"] as? Double
                                continuation.yield(.pending(status: status, delay: delay))
                            case "proactive":
                                if let text = payload["text"] as? String {
                                    let agentId = payload["agent_id"] as? String ?? ""
                                    continuation.yield(.proactive(text: text, agentId: agentId))
                                }
                            case "done":
                                continuation.yield(.done)
                            case "pong":
                                break
                            case "error":
                                let msg = payload["message"] as? String ?? "Unknown error"
                                continuation.finish(throwing: APIError.networkError(
                                    NSError(domain: "WS", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
                                ))
                                return
                            default:
                                break
                            }
                        case .data:
                            break
                        @unknown default:
                            break
                        }
                    } catch {
                        if self.isConnected {
                            continuation.finish(throwing: error)
                        }
                        return
                    }
                }
            }
        }
    }

    func send(message: String) async throws {
        guard let task = task else {
            throw APIError.networkError(NSError(domain: "WS", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not connected"]))
        }
        let payload: [String: Any] = ["type": "message", "data": ["message": message]]
        let data = try JSONSerialization.data(withJSONObject: payload)
        try await task.send(.string(String(data: data, encoding: .utf8)!))
    }

    func disconnect() {
        isConnected = false
        pingTask?.cancel()
        pingTask = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
    }

    private func startPing() {
        pingTask?.cancel()
        pingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled, self.isConnected else { break }
                let ping: [String: Any] = ["type": "ping"]
                if let data = try? JSONSerialization.data(withJSONObject: ping) {
                    try? await self.task?.send(.string(String(data: data, encoding: .utf8)!))
                }
            }
        }
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code, let message): return "HTTP \(code): \(message)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

actor APIClient {
    static let shared = APIClient()

    let baseURL: String

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        self.baseURL = BackendConfig.baseURL
#if DEBUG
        print("[API] baseURL=\(baseURL)")
#endif
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Generic Request

    func request<T: Decodable>(
        method: String,
        path: String,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let request = try buildRequest(method: method, path: path, body: body, queryItems: queryItems)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func requestVoid(
        method: String,
        path: String,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        let request = try buildRequest(method: method, path: path, body: body, queryItems: queryItems)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    // MARK: - SSE Stream

    func stream(
        path: String,
        body: some Encodable
    ) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let request = try buildRequest(method: "POST", path: path, body: body)
                    let (bytes, response) = try await session.bytes(for: request)
                    try validateResponse(response, data: nil)

                    var currentEvent = ""
                    for try await line in bytes.lines {
                        if line.hasPrefix("event: ") {
                            currentEvent = String(line.dropFirst(7))
                        } else if line.hasPrefix("data: ") {
                            let dataStr = String(line.dropFirst(6))
                            if currentEvent == "done" {
                                break
                            }
                            guard let jsonData = dataStr.data(using: .utf8),
                                  let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                            else { continue }

                            if currentEvent == "reply",
                               let text = dict["text"] as? String,
                               let index = dict["index"] as? Int {
                                let stickerURL = dict["sticker_url"] as? String
                                continuation.yield(.reply(text: text, index: index, stickerURL: stickerURL))
                            } else if currentEvent == "token", let token = dict["token"] as? String {
                                continuation.yield(.token(token))
                            } else if currentEvent == "typing" {
                                let duration = dict["duration"] as? Double ?? 1.0
                                continuation.yield(.typing(duration: duration))
                            } else if currentEvent == "delay" {
                                let duration = dict["duration"] as? Double ?? 5.0
                                continuation.yield(.delay(duration: duration))
                            } else if currentEvent == "pending" {
                                let status = dict["status"] as? String ?? "pending"
                                let delay = dict["delay"] as? Double
                                continuation.yield(.pending(status: status, delay: delay))
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private

    private func buildRequest(
        method: String,
        path: String,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "authToken"), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }

    private func validateResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard (200...299).contains(httpResponse.statusCode) else {
            var message = "Unknown error"
            if let data,
               let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = body["detail"] {
                if let detailString = detail as? String {
                    message = detailString
                } else if let detailData = try? JSONSerialization.data(withJSONObject: detail),
                          let detailJSON = String(data: detailData, encoding: .utf8) {
                    message = detailJSON
                }
            }
            throw APIError.httpError(httpResponse.statusCode, message)
        }
    }
}
