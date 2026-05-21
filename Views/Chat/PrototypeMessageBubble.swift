import SwiftUI

struct PrototypeMessageBubble: View {
    @Environment(\.prototypePalette) private var palette
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            if isUser {
                Spacer(minLength: 6)
                bubble
                PrototypeAssetImage(name: "user-avatar-shanmu.jpg")
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.7), lineWidth: 1)
                    )
            } else {
                PrototypeAvatar(name: PrototypeFixtures.agentName, size: 36)
                bubble
                Spacer(minLength: 6)
            }
        }
        .padding(.horizontal, 28)
    }

    private var bubble: some View {
        Text(message.content)
            .font(.system(size: 17, weight: .regular))
            .lineSpacing(4)
            .foregroundStyle(isUser ? Color.white : palette.fg)
            .padding(.horizontal, isUser ? 18 : 20)
            .padding(.vertical, 12)
            .background(isUser ? Color(hex: 0x168BFF) : Color.white.opacity(0.94))
            .clipShape(PrototypeCornerBubbleShape(isUser: isUser))
            .overlay(
                PrototypeCornerBubbleShape(isUser: isUser)
                    .stroke(isUser ? Color.white.opacity(0.05) : Color.black.opacity(0.045), lineWidth: 1)
            )
            .shadow(color: (isUser ? Color(hex: 0x168BFF) : Color.black).opacity(isUser ? 0.18 : 0.07), radius: isUser ? 20 : 18, y: isUser ? 12 : 10)
    }
}

private struct PrototypeCornerBubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 22
        let sharpRadius: CGFloat = 5
        let topLeading = isUser ? radius : sharpRadius
        let topTrailing = isUser ? sharpRadius : radius
        let bottomLeading = radius
        let bottomTrailing = radius

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + topLeading, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topTrailing, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + topTrailing),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomTrailing))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - bottomTrailing, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + bottomLeading, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeading),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeading))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topLeading, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.closeSubpath()
        return path
    }
}
