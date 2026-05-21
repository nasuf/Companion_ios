import SwiftUI

struct AuthView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel = AuthViewModel()
    @State private var showsPasswordLogin = false
    @FocusState private var focusedField: AuthFieldKind?

    var body: some View {
        ZStack {
            PrototypeBackground(style: .onboarding)

            loginCanvas

            if showsPasswordLogin {
                passwordOverlay
                    .transition(.opacity)
            }
        }
        .environment(\.prototypeTheme, .blue)
        .sensoryFeedback(.success, trigger: appViewModel.userId)
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: showsPasswordLogin)
    }

    private var loginCanvas: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let side: CGFloat = 26
            let actionTop = max(height - 234, height * 0.735)

            ZStack(alignment: .topLeading) {
                brandHeader
                    .frame(width: width - side * 2, alignment: .leading)
                    .offset(x: side, y: max(80, height * 0.105))

                heroCopy
                    .frame(width: width - side * 2, height: 274, alignment: .topLeading)
                    .offset(x: side, y: max(220, height * 0.245))

                loginActions
                    .frame(width: width - side * 2)
                    .offset(x: side, y: actionTop)
            }
        }
    }

    private var brandHeader: some View {
        HStack(spacing: 16) {
            PrototypeAssetImage(name: "logo.png", contentMode: .fit)
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
                .shadow(color: CreationPalette.action.opacity(0.16), radius: 30, y: 18)

            VStack(alignment: .leading, spacing: 8) {
                Text("「伴生」")
                    .font(.system(size: 25, weight: .heavy))
                    .foregroundStyle(CreationPalette.action)
                Text("Ban Sheng")
                    .font(.system(size: 18.5, weight: .medium))
                    .foregroundStyle(CreationPalette.body.opacity(0.76))
            }
        }
    }

    private var heroCopy: some View {
        ZStack(alignment: .topLeading) {
            AuthGlassOrb()
                .frame(width: 174, height: 154)
                .rotationEffect(.degrees(9))
                .offset(x: 218, y: 80)

            VStack(alignment: .leading, spacing: 18) {
                Text("从一句话开始")
                    .font(.system(size: 43, weight: .heavy))
                    .foregroundStyle(CreationPalette.fg)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text("在没有终点的路上，\n我们慢慢走，慢慢说。")
                    .font(.system(size: 18, weight: .semibold))
                    .lineSpacing(9)
                    .foregroundStyle(CreationPalette.body.opacity(0.76))
            }
            .frame(width: 322, alignment: .leading)
        }
    }

    private var loginActions: some View {
        VStack(spacing: 18) {
            Button {
                openPasswordLogin(mode: .login)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "iphone")
                        .font(.system(size: 20, weight: .bold))
                    Text("手机号登录")
                        .font(.system(size: 18, weight: .heavy))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(CreationPalette.actionGradient)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .prototypeLiquidGlass(cornerRadius: 26, tint: CreationPalette.action.opacity(0.32), interactive: true)
                .shadow(color: CreationPalette.action.opacity(0.22), radius: 26, y: 16)
            }
            .buttonStyle(.prototypeGlassProminentPress)

            HStack(spacing: 8) {
                Rectangle()
                    .fill(.linearGradient(
                        colors: [.clear, CreationPalette.hairline, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                Text("or")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(CreationPalette.body.opacity(0.58))
                Rectangle()
                    .fill(.linearGradient(
                        colors: [.clear, CreationPalette.hairline, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
            }

            HStack(spacing: 25) {
                SocialLoginButton(kind: .apple)
                SocialLoginButton(kind: .douyin)
                SocialLoginButton(kind: .wechat)
            }
            .frame(maxWidth: .infinity)

            Button {
                openPasswordLogin(mode: .login)
            } label: {
                Text("邮箱密码登录")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(CreationPalette.actionInk)
                    .padding(.horizontal, 16)
                    .frame(height: 34)
                    .background(Color.white.opacity(0.42))
                    .clipShape(Capsule())
                    .prototypeLiquidGlass(cornerRadius: 17, tint: Color.white.opacity(0.24), interactive: true)
            }
            .buttonStyle(.prototypeGlassPress)
            .accessibilityLabel("邮箱密码登录")

            Text("登录即表示同意 隐私协议 · 数据可删除")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(CreationPalette.body.opacity(0.62))
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var passwordOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                    showsPasswordLogin = false
                }

            passwordLoginPanel
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var passwordLoginPanel: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("邮箱密码登录")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(CreationPalette.fg)
                    Text("临时入口，逻辑与 Web 端一致。")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(CreationPalette.body)
                }
                Spacer()
                Button {
                    focusedField = nil
                    showsPasswordLogin = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(CreationPalette.body)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.50))
                        .clipShape(Circle())
                }
                .buttonStyle(.prototypeGlassPress)
            }

            PrototypeGlassSegmentedControl(
                options: AuthMode.allCases,
                selection: $viewModel.mode,
                title: { $0.title },
                activeTint: CreationPalette.action,
                activeForeground: CreationPalette.actionInk,
                inactiveForeground: CreationPalette.body,
                trackTint: Color.white.opacity(0.34),
                height: 38
            )

            AuthTextField(
                title: "邮箱 / 用户名",
                text: $viewModel.username,
                systemImage: "person.fill",
                placeholder: viewModel.mode == .register ? "2-30个字符" : "输入邮箱或用户名",
                isSecure: false,
                focusedField: $focusedField,
                field: .username,
                submitLabel: .next
            )
            .onSubmit {
                focusedField = .password
            }

            AuthTextField(
                title: "密码",
                text: $viewModel.password,
                systemImage: "lock.fill",
                placeholder: viewModel.mode == .register ? "至少6个字符" : "输入密码",
                isSecure: true,
                focusedField: $focusedField,
                field: .password,
                submitLabel: viewModel.mode == .register ? .next : .go
            )
            .onSubmit {
                if viewModel.mode == .register {
                    focusedField = .confirmPassword
                } else {
                    submit()
                }
            }

            if viewModel.mode == .register {
                AuthTextField(
                    title: "确认密码",
                    text: $viewModel.confirmPassword,
                    systemImage: "checkmark.seal.fill",
                    placeholder: "再次输入密码",
                    isSecure: true,
                    focusedField: $focusedField,
                    field: .confirmPassword,
                    submitLabel: .go
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .onSubmit(submit)
            }

            if let error = viewModel.error {
                AuthNotice(text: error, tint: Color(hex: 0xE35B6F), symbol: "exclamationmark.circle.fill")
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else if let appError = appViewModel.error, !appError.isEmpty {
                AuthNotice(text: appError, tint: CreationPalette.action, symbol: "info.circle.fill")
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Button(action: submit) {
                HStack(spacing: 10) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(viewModel.isSubmitting ? "\(viewModel.mode.title)中..." : viewModel.mode.title)
                }
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(CreationPalette.actionGradient)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .prototypeLiquidGlass(cornerRadius: 20, tint: CreationPalette.action.opacity(0.32), interactive: true)
            }
            .buttonStyle(.prototypeGlassProminentPress)
            .disabled(!viewModel.canSubmit)
            .opacity(viewModel.canSubmit ? 1 : 0.48)

            HStack(spacing: 4) {
                Text(viewModel.mode.switchPrompt)
                    .foregroundStyle(CreationPalette.body)
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                        viewModel.toggleMode()
                    }
                } label: {
                    Text(viewModel.mode.switchAction)
                        .fontWeight(.heavy)
                        .foregroundStyle(CreationPalette.actionInk)
                }
                .buttonStyle(.prototypeGlassPress)
            }
            .font(.system(size: 12.5, weight: .semibold))
        }
        .padding(14)
        .background(Color.white.opacity(0.58))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 26, tint: Color.white.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x40546A).opacity(0.12), radius: 30, y: 16)
    }

    private func openPasswordLogin(mode: AuthMode) {
        viewModel.mode = mode
        showsPasswordLogin = true
    }

    private func submit() {
        focusedField = nil
        Task {
            await viewModel.submit(appViewModel: appViewModel)
        }
    }
}

private enum AuthFieldKind {
    case username
    case password
    case confirmPassword
}

private enum SocialLoginKind {
    case apple
    case douyin
    case wechat

    var assetName: String {
        switch self {
        case .apple: "apple.svg"
        case .douyin: "douyin.svg"
        case .wechat: "wechat.svg"
        }
    }

    var fallbackIcon: String {
        switch self {
        case .apple: "apple.logo"
        case .douyin: "music.note"
        case .wechat: "ellipsis.message.fill"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .apple: "Apple 登录"
        case .douyin: "抖音登录"
        case .wechat: "微信登录"
        }
    }

    var fill: Color {
        switch self {
        case .apple: Color(hex: 0x111318)
        case .douyin: Color(hex: 0x1A1D22)
        case .wechat: Color(hex: 0x09C519)
        }
    }
}

private struct SocialLoginButton: View {
    let kind: SocialLoginKind

    var body: some View {
        Button {
            // Social login endpoints are not wired yet; password login is the temporary real path.
        } label: {
            ZStack {
                Circle()
                    .fill(kind.fill)
                SocialLoginGlyph(kind: kind)
                    .frame(width: 28, height: 28)
            }
            .frame(width: 58, height: 58)
            .overlay(Circle().stroke(Color.white.opacity(0.72), lineWidth: 1))
            .shadow(color: kind.fill.opacity(0.24), radius: 18, y: 10)
        }
        .buttonStyle(.prototypeGlassProminentPress)
        .accessibilityLabel(kind.accessibilityLabel)
    }
}

private struct SocialLoginGlyph: View {
    let kind: SocialLoginKind

    var body: some View {
        Group {
            if let image = UIImage.prototype(named: kind.assetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                fallback
            }
        }
        .foregroundStyle(Color.white)
    }

    @ViewBuilder
    private var fallback: some View {
        switch kind {
        case .apple:
            Image(systemName: kind.fallbackIcon)
                .font(.system(size: 26, weight: .heavy))
        case .douyin:
            ZStack {
                Text("♪")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .offset(x: -1, y: 1)
                    .foregroundStyle(Color(hex: 0x25F4EE).opacity(0.72))
                Text("♪")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .offset(x: 1, y: -1)
                    .foregroundStyle(Color(hex: 0xFE2C55).opacity(0.72))
                Text("♪")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
            }
        case .wechat:
            WeChatGlyph()
        }
    }
}

private struct WeChatGlyph: View {
    var body: some View {
        ZStack {
            BubbleShape(tail: .left)
                .fill(Color.white)
                .frame(width: 24, height: 18)
                .offset(x: -5, y: -3)
            BubbleShape(tail: .right)
                .fill(Color.white)
                .frame(width: 21, height: 16)
                .offset(x: 6, y: 5)
            Circle()
                .fill(Color(hex: 0x09C519))
                .frame(width: 3.2, height: 3.2)
                .offset(x: -10, y: -6)
            Circle()
                .fill(Color(hex: 0x09C519))
                .frame(width: 3.2, height: 3.2)
                .offset(x: -2, y: -6)
            Circle()
                .fill(Color(hex: 0x09C519))
                .frame(width: 2.8, height: 2.8)
                .offset(x: 2, y: 3)
            Circle()
                .fill(Color(hex: 0x09C519))
                .frame(width: 2.8, height: 2.8)
                .offset(x: 9, y: 3)
        }
    }
}

private struct BubbleShape: Shape {
    enum Tail {
        case left
        case right
    }

    let tail: Tail

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height * 0.84
        )

        path.addRoundedRect(
            in: bubbleRect,
            cornerSize: CGSize(width: bubbleRect.height / 2, height: bubbleRect.height / 2)
        )

        switch tail {
        case .left:
            path.move(to: CGPoint(x: rect.minX + rect.width * 0.26, y: bubbleRect.maxY - 1))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: bubbleRect.maxY - 2))
        case .right:
            path.move(to: CGPoint(x: rect.maxX - rect.width * 0.26, y: bubbleRect.maxY - 1))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.42, y: bubbleRect.maxY - 2))
        }

        path.closeSubpath()
        return path
    }
}

private struct AuthTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String
    let placeholder: String
    let isSecure: Bool
    var focusedField: FocusState<AuthFieldKind?>.Binding
    let field: AuthFieldKind
    let submitLabel: SubmitLabel

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(CreationPalette.actionInk)
                .frame(width: 32, height: 32)
                .background(CreationPalette.actionSoft.opacity(0.62))
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(CreationPalette.label)
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                .font(.system(size: 14.5, weight: .bold))
                .foregroundStyle(CreationPalette.fg)
                .focused(focusedField, equals: field)
                .submitLabel(submitLabel)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 54)
        .background(Color.white.opacity(0.64))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.22), interactive: true)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(focusedField.wrappedValue == field ? CreationPalette.action.opacity(0.38) : Color.white.opacity(0.62), lineWidth: 1)
        )
    }
}

private struct AuthNotice: View {
    let text: String
    let tint: Color
    let symbol: String

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: symbol)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
            Text(text)
                .font(.system(size: 11.5, weight: .bold))
                .lineSpacing(2)
                .foregroundStyle(CreationPalette.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.50))
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 17, tint: Color.white.opacity(0.20))
    }
}

private struct AuthGlassOrb: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [CreationPalette.actionAlt.opacity(0.60), CreationPalette.action.opacity(0.74)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: CreationPalette.action.opacity(0.18), radius: 28, y: 16)

            Circle()
                .fill(Color.white.opacity(0.26))
                .frame(width: 72, height: 72)
                .offset(x: -30, y: -38)

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.50), lineWidth: 1.5)
                .padding(30)

            Circle()
                .fill(Color.white.opacity(0.80))
                .frame(width: 15, height: 15)
                .offset(x: -42, y: -42)
            Circle()
                .fill(Color.white.opacity(0.86))
                .frame(width: 17, height: 17)
                .offset(x: 52, y: -4)
            Circle()
                .fill(Color.white.opacity(0.84))
                .frame(width: 19, height: 19)
                .offset(x: 4, y: 50)
        }
    }
}
