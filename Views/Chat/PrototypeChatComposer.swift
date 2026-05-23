import SwiftUI
import UIKit

enum PrototypeChatInputMode: Equatable {
    case none
    case keyboard
    case emoji
    case more
}

struct PrototypeChatComposer: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var text: String
    let isWaitingReply: Bool
    @Binding var inputMode: PrototypeChatInputMode
    let emojiPanelHeight: CGFloat
    let accessoryPanelHeight: CGFloat
    let onFocusChanged: (Bool) -> Void
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            emojiPanel

            inputRow

            morePanel
        }
        .padding(.horizontal, 28)
        .padding(.top, inputMode == .emoji ? 10 : 8)
        .padding(.bottom, 18)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: inputMode)
    }

    @ViewBuilder
    private var emojiPanel: some View {
        if inputMode == .emoji {
            PrototypeEmojiPanel { emoji in
                text.append(emoji)
            } close: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    inputMode = .none
                }
            }
            .frame(height: emojiPanelHeight)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(2)
        }
    }

    @ViewBuilder
    private var morePanel: some View {
        if inputMode == .more {
            PrototypeChatMorePanel()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .frame(height: accessoryPanelHeight)
                .zIndex(0)
        }
    }

    private var inputRow: some View {
        HStack(spacing: 16) {
            inputCapsule

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    inputMode = inputMode == .more ? .none : .more
                    Self.dismissKeyboard()
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(inputMode == .more ? CreationPalette.blue : palette.fg)
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(inputMode == .more ? 45 : 0))
                    .background(Color.white.opacity(0.86))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white.opacity(0.72), lineWidth: 1))
                    .shadow(color: CreationPalette.blue.opacity(inputMode == .more ? 0.16 : 0.0), radius: 16, y: 8)
                    .shadow(color: Color.black.opacity(inputMode == .more ? 0.02 : 0.08), radius: 18, y: 10)
            }
            .buttonStyle(.prototypeGlassProminentPress)
            .accessibilityLabel(inputMode == .more ? "关闭功能面板" : "打开功能面板")
            .accessibilityIdentifier("chat.more.button")

            if shouldShowSend {
                Button(action: onSend) {
                    Image(systemName: isWaitingReply ? "stop.fill" : "arrow.up")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .frame(width: 48, height: 48)
                        .background(sendButtonColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.prototypeGlassProminentPress)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var inputCapsule: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(inputMode == .more ? "选择一个功能..." : "发消息...")
                        .font(.system(size: 16.5))
                        .foregroundStyle(palette.subtle)
                        .allowsHitTesting(false)
                }

                PrototypeChatTextView(
                    text: $text,
                    onFocusChanged: onFocusChanged,
                    onSubmit: onSend
                )
                .frame(minHeight: 24, maxHeight: 72)
                .accessibilityLabel("消息输入框")
                .accessibilityIdentifier("chat.message.input")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "mic")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(palette.accentInk)
                .accessibilityLabel("语音")

            Button {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    inputMode = inputMode == .emoji ? .none : .emoji
                    Self.dismissKeyboard()
                }
            } label: {
                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFFD96C))
            }
            .accessibilityLabel("表情")
            .accessibilityIdentifier("chat.emoji.button")
            .buttonStyle(.prototypeGlassPress)
        }
        .foregroundStyle(palette.muted)
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .frame(minHeight: 52)
        .contentShape(Capsule())
        .background(inputCapsuleBackground)
        .overlay(Capsule().stroke(palette.hairline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.07), radius: 14, y: 8)
    }

    private var inputCapsuleBackground: some View {
        Capsule()
            .fill(Color.white.opacity(0.86))
            .allowsHitTesting(false)
    }

    private var sendButtonColor: Color {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isWaitingReply
            ? palette.subtle.opacity(0.5)
            : CreationPalette.blue
    }

    private var shouldShowSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWaitingReply
    }

    private static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private struct PrototypeChatTextView: UIViewRepresentable {
    @Binding var text: String
    let onFocusChanged: (Bool) -> Void
    let onSubmit: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16.5)
        textView.textColor = UIColor(Color(hex: 0x151716))
        textView.tintColor = UIColor(CreationPalette.blue)
        textView.returnKeyType = .send
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.smartQuotesType = .no
        textView.textContentType = .none
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.inputAssistantItem.leadingBarButtonGroups = []
        textView.inputAssistantItem.trailingBarButtonGroups = []
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }

        let contentHeight = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)).height
        textView.isScrollEnabled = contentHeight > 72
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 0
        let fittingSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let height = uiView.sizeThatFits(fittingSize).height
        return CGSize(width: width, height: min(max(24, height), 72))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onFocusChanged: onFocusChanged, onSubmit: onSubmit)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String
        private let onFocusChanged: (Bool) -> Void
        private let onSubmit: () -> Void

        init(text: Binding<String>, onFocusChanged: @escaping (Bool) -> Void, onSubmit: @escaping () -> Void) {
            _text = text
            self.onFocusChanged = onFocusChanged
            self.onSubmit = onSubmit
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            onFocusChanged(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            onFocusChanged(false)
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText replacement: String) -> Bool {
            if replacement == "\n" {
                onSubmit()
                return false
            }
            return true
        }
    }
}

private struct PrototypeEmojiPanel: View {
    @Environment(\.prototypePalette) private var palette
    let pick: (String) -> Void
    let close: () -> Void

    private let emojis = ["😊", "😂", "🥹", "🤍", "🙌", "🌧️", "☀️", "🎧", "🍿", "🎮", "📚", "🍰", "🧋", "🌙", "✨", "🫶", "😌", "😭", "👍", "👀"]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("常用表情")
                    .font(.system(size: 13, weight: .heavy))
                Spacer()
                Button("关闭", action: close)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(palette.accent)
                    .buttonStyle(.prototypeGlassPress)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(emojis, id: \.self) { emoji in
                    Button {
                        pick(emoji)
                    } label: {
                        Text(emoji)
                            .font(.system(size: 20))
                            .frame(height: 34)
                            .frame(maxWidth: .infinity)
                            .background(palette.surface2)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.prototypeGlassPress)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.84))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.66), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.07), radius: 18, y: 10)
    }
}

private struct PrototypeChatMorePanel: View {
    @Environment(\.prototypePalette) private var palette

    private let tools: [PrototypeChatToolItem] = [
        PrototypeChatToolItem("图片", "photo", Color(hex: 0x1F6FFF)),
        PrototypeChatToolItem("拍摄", "camera", Color(hex: 0x18C6C0)),
        PrototypeChatToolItem("红包", "gift", Color(hex: 0xFF4D5F)),
        PrototypeChatToolItem("位置", "location", Color(hex: 0x22C66B)),
        PrototypeChatToolItem("查找", "magnifyingglass", Color(hex: 0x7C3CFF)),
        PrototypeChatToolItem("电话", "phone", Color(hex: 0xFF8A3D))
    ]

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) {
                ForEach(tools.prefix(3)) { tool in
                    PrototypeChatToolButton(tool: tool)
                }
            }

            HStack(spacing: 0) {
                ForEach(tools.suffix(3)) { tool in
                    PrototypeChatToolButton(tool: tool)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.86))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.66), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.07), radius: 18, y: 10)
    }
}

private struct PrototypeChatToolItem: Identifiable {
    let title: String
    let symbol: String
    let color: Color

    var id: String { title }

    init(_ title: String, _ symbol: String, _ color: Color) {
        self.title = title
        self.symbol = symbol
        self.color = color
    }
}

private struct PrototypeChatToolButton: View {
    @Environment(\.prototypePalette) private var palette
    let tool: PrototypeChatToolItem

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: tool.symbol)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(tool.color)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(hex: 0x22C66B))
                        .frame(width: 9, height: 9)
                        .offset(x: -5, y: 5)
                }

            Text(tool.title)
                .font(.system(size: 13.5, weight: .heavy))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}
