import SwiftUI

struct PrototypeMessageBubble: View {
    @Environment(\.prototypePalette) private var palette
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isUser {
                Spacer(minLength: 52)
                bubble
                PrototypeAssetImage(name: "user-avatar-shanmu.jpg")
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
            } else {
                PrototypeAvatar(name: PrototypeFixtures.agentName, size: 24)
                bubble
                Spacer(minLength: 52)
            }
        }
        .padding(.horizontal, 12)
    }

    private var bubble: some View {
        Text(message.content)
            .font(.system(size: 13.5))
            .lineSpacing(2)
            .foregroundStyle(isUser ? palette.bg : palette.fg)
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(isUser ? palette.fg : Color.white.opacity(0.62))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .prototypeLiquidGlass(
                cornerRadius: 18,
                tint: isUser ? palette.fg.opacity(0.16) : Color.white.opacity(0.22),
                interactive: false
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isUser ? palette.fg.opacity(0.18) : palette.hairline, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(isUser ? 0.10 : 0.05), radius: 10, y: 5)
    }
}
