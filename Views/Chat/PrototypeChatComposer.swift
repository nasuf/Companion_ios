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
        VStack(spacing: 14) {
            if showEmojiPanel {
                PrototypeEmojiPanel { emoji in
                    text.append(emoji)
                } close: {
                    showEmojiPanel = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            inputRow

            if showMorePanel {
                PrototypeChatMorePanel()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, showMorePanel || showEmojiPanel ? 10 : 8)
        .padding(.bottom, 18)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: showMorePanel)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: showEmojiPanel)
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
                Image(systemName: showMorePanel ? "xmark" : "plus")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(showMorePanel ? Color.white : palette.fg)
                    .frame(width: 52, height: 52)
                    .background(showMorePanel ? CreationPalette.actionGradient : LinearGradient(colors: [Color.white.opacity(0.72), Color.white.opacity(0.52)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(Circle())
                    .prototypeLiquidGlass(cornerRadius: 26, tint: (showMorePanel ? CreationPalette.action : Color.white).opacity(0.28), interactive: true)
                    .overlay(Circle().stroke(Color.white.opacity(0.72), lineWidth: 1))
                    .shadow(color: (showMorePanel ? CreationPalette.action : Color.black).opacity(showMorePanel ? 0.26 : 0.08), radius: 18, y: 10)
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(tools, id: \.0) { tool in
                VStack(spacing: 8) {
                    Image(systemName: tool.1)
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(tool.2)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .fill(Color(hex: 0x22C66B))
                                .frame(width: 9, height: 9)
                                .offset(x: -5, y: 5)
                        }
                    Text(tool.0)
                        .font(.system(size: 13.5, weight: .heavy))
                        .foregroundStyle(palette.muted)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 30, tint: Color.white.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.62), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 22, y: 12)
    }
}
