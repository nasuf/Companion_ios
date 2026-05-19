import SwiftUI

struct PrototypeChatComposer: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let isConnected: Bool
    let isWaitingReply: Bool
    let deliveryHint: String
    @Binding var showEmojiPanel: Bool
    @Binding var showMorePanel: Bool
    let onSend: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if showEmojiPanel {
                PrototypeEmojiPanel { emoji in
                    text.append(emoji)
                } close: {
                    showEmojiPanel = false
                }
            }

            if showMorePanel {
                PrototypeChatMorePanel()
            }

            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    TextField("发消息…", text: $text, axis: .vertical)
                        .lineLimit(1...4)
                        .font(.system(size: 13))
                        .focused(isFocused)
                        .onSubmit(onSend)

                    Image(systemName: "mic")
                        .font(.system(size: 15, weight: .semibold))
                        .opacity(0.55)
                        .accessibilityLabel("语音")

                    Button {
                        withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                            showEmojiPanel.toggle()
                            if showEmojiPanel { showMorePanel = false }
                        }
                    } label: {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
                .foregroundStyle(palette.muted)
                .padding(.horizontal, 13)
                .frame(minHeight: 40)
                .background(Color.white.opacity(0.58))
                .clipShape(Capsule())
                .prototypeLiquidGlass(cornerRadius: 20, tint: Color.white.opacity(0.22), interactive: true)

                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.86)) {
                        showMorePanel.toggle()
                        if showMorePanel { showEmojiPanel = false }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(palette.fg)
                        .frame(width: 40, height: 40)
                        .prototypeLiquidGlass(cornerRadius: 20, tint: Color.white.opacity(0.25), interactive: true)
                }
                .buttonStyle(.plain)

                Button(action: onSend) {
                    Image(systemName: isWaitingReply ? "stop.fill" : "arrow.up")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(palette.bg)
                        .frame(width: 40, height: 40)
                        .background(sendButtonColor)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isWaitingReply)
            }
            .padding(.horizontal, 13)
            .padding(.top, 8)

            HStack(spacing: 7) {
                Circle()
                    .fill(isConnected ? Color(hex: 0x4D8870) : Color(hex: 0xD3914B))
                    .frame(width: 6, height: 6)
                Text(deliveryHint)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(palette.subtle)
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 7)
            .padding(.bottom, 14)
        }
        .background(Color.white.opacity(0.08))
        .prototypeLiquidGlass(cornerRadius: 0, tint: Color.white.opacity(0.10))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
        }
    }

    private var sendButtonColor: Color {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isWaitingReply
            ? palette.subtle.opacity(0.5)
            : palette.fg
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
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
    }
}

private struct PrototypeChatMorePanel: View {
    @Environment(\.prototypePalette) private var palette

    private let tools = [
        ("图片", "photo", Color(hex: 0x1F6FFF)),
        ("拍摄", "camera", Color(hex: 0x18C6C0)),
        ("红包", "gift", Color(hex: 0xFF4D5F)),
        ("位置", "location", Color(hex: 0x22C66B)),
        ("查找", "magnifyingglass", Color(hex: 0x7C3CFF)),
        ("电话", "phone", Color(hex: 0xFF8A3D))
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ForEach(tools, id: \.0) { tool in
                VStack(spacing: 7) {
                    Image(systemName: tool.1)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(tool.2)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    Text(tool.0)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(palette.muted)
                }
            }
        }
        .padding(16)
    }
}
