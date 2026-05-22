import SwiftUI

struct PrototypeChatComposer: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isWaitingReply: Bool
    @Binding var showEmojiPanel: Bool
    @Binding var showMorePanel: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            emojiPanel

            inputRow

            morePanel
        }
        .padding(.horizontal, 28)
        .padding(.top, showEmojiPanel ? 10 : 8)
        .padding(.bottom, 18)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: showMorePanel)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: showEmojiPanel)
    }

    @ViewBuilder
    private var emojiPanel: some View {
        if showEmojiPanel {
            PrototypeEmojiPanel { emoji in
                text.append(emoji)
            } close: {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    showEmojiPanel = false
                }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(2)
        }
    }

    @ViewBuilder
    private var morePanel: some View {
        if showMorePanel {
            PrototypeChatMorePanel()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(0)
        }
    }

    private var inputRow: some View {
        HStack(spacing: 16) {
            inputCapsule

            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    showMorePanel.toggle()
                    if showMorePanel { showEmojiPanel = false }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(showMorePanel ? CreationPalette.blue : palette.fg)
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(showMorePanel ? 45 : 0))
                    .background(LinearGradient(colors: [Color.white.opacity(0.74), Color.white.opacity(0.52)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())
                    .prototypeLiquidGlass(cornerRadius: 26, tint: Color.white.opacity(showMorePanel ? 0.38 : 0.28), interactive: true)
                    .overlay(Circle().stroke(Color.white.opacity(0.72), lineWidth: 1))
                    .shadow(color: CreationPalette.blue.opacity(showMorePanel ? 0.16 : 0.0), radius: 16, y: 8)
                    .shadow(color: Color.black.opacity(showMorePanel ? 0.02 : 0.08), radius: 18, y: 10)
            }
            .buttonStyle(.prototypeGlassProminentPress)

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
            TextField(showMorePanel ? "选择一个功能..." : "发消息...", text: $text, axis: .vertical)
                .lineLimit(1...4)
                .font(.system(size: 16.5, weight: .regular))
                .focused(isFocused)
                .onSubmit(onSend)

            Image(systemName: "mic")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(palette.accentInk)
                .accessibilityLabel("语音")

            Button {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                    showEmojiPanel.toggle()
                    if showEmojiPanel { showMorePanel = false }
                }
            } label: {
                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xFFD96C))
            }
            .buttonStyle(.prototypeGlassPress)
        }
        .foregroundStyle(palette.muted)
        .padding(.leading, 20)
        .padding(.trailing, 16)
        .frame(minHeight: 52)
        .background(Color.white.opacity(0.78))
        .clipShape(Capsule())
        .prototypeLiquidGlass(cornerRadius: 26, tint: Color.white.opacity(0.30), interactive: true)
        .overlay(Capsule().stroke(palette.hairline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.07), radius: 14, y: 8)
    }

    private var sendButtonColor: Color {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isWaitingReply
            ? palette.subtle.opacity(0.5)
            : CreationPalette.blue
    }

    private var shouldShowSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWaitingReply
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
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
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
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
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
