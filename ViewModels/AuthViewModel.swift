import Foundation

enum AuthMode: String, CaseIterable {
    case login
    case register

    var title: String {
        switch self {
        case .login: "登录"
        case .register: "注册"
        }
    }

    var switchPrompt: String {
        switch self {
        case .login: "还没有账号？"
        case .register: "已有账号？"
        }
    }

    var switchAction: String {
        switch self {
        case .login: "立即注册"
        case .register: "返回登录"
        }
    }
}

@Observable
final class AuthViewModel {
    var mode: AuthMode = .login
    var username = ""
    var password = ""
    var confirmPassword = ""
    var isSubmitting = false
    var error: String?

    var canSubmit: Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !isSubmitting, !trimmedUsername.isEmpty, !password.isEmpty else {
            return false
        }
        if mode == .register {
            return password.count >= 6 && password == confirmPassword
        }
        return true
    }

    @MainActor
    func submit(appViewModel: AppViewModel) async {
        guard canSubmit else { return }

        isSubmitting = true
        error = nil

        do {
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            let response: AuthResponse
            switch mode {
            case .login:
                response = try await UserService.login(username: trimmedUsername, password: password)
            case .register:
                response = try await UserService.register(username: trimmedUsername, password: password)
            }

            await appViewModel.applyAuthenticatedSession(response)
            password = ""
            confirmPassword = ""
        } catch {
            self.error = Self.userFacingAuthError(error, mode: mode)
        }

        isSubmitting = false
    }

    func toggleMode() {
        mode = mode == .login ? .register : .login
        error = nil
        password = ""
        confirmPassword = ""
    }

    private static func userFacingAuthError(_ error: Error, mode: AuthMode) -> String {
        if case APIError.httpError(let code, let message) = error {
            if code == 401 {
                return "用户名或密码不正确。"
            }
            if code == 409 {
                return "这个用户名已经被注册了，换一个试试。"
            }
            if code == 422 {
                return mode == .register
                    ? "用户名需为 2-30 个字符，密码至少 6 个字符。"
                    : "请检查用户名和密码后再试一次。"
            }
            if code == 429 {
                return message.isEmpty ? "尝试过于频繁，请稍后再试。" : message
            }
            if code >= 500 {
                return "后端服务暂时没有完成登录请求，请稍后再试。"
            }
        }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .cannotConnectToHost, .notConnectedToInternet, .networkConnectionLost:
                return "暂时连不上后端服务，请确认服务已启动。"
            default:
                break
            }
        }

        return "登录没有完成，请稍后再试。"
    }
}
