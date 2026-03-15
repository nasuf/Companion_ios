import SwiftUI

struct MessageBubble: View {
    let message: Message

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Group {
                            if isUser {
                                BrandGradient.primary
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .background {
                        if !isUser {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(isUser ? 0.3 : 0.15), lineWidth: 1)
                    )
                    .foregroundStyle(isUser ? .white : .primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                    .shadow(color: isUser ? Color(red: 1.0, green: 0.5, blue: 0.4).opacity(0.3) : Color.black.opacity(0.05), radius: 5, y: 2)

                Text(DateFormatting.time(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
    }

}
