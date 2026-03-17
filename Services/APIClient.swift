import Foundation

enum SSEEvent {
    case token(String)
    case reply(text: String, index: Int, stickerURL: String?)
    case typing(duration: Double)
    case delay(duration: Double)
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
        self.baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:8000"
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
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }

    private func validateResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        guard (200...299).contains(httpResponse.statusCode) else {
            var message = "Unknown error"
            if let data, let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = body["detail"] as? String {
                message = detail
            }
            throw APIError.httpError(httpResponse.statusCode, message)
        }
    }
}
