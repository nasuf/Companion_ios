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
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .foregroundStyle(isUser ? .white : .primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                Text(formatTime(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
    }

    private func formatTime(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr) else {
            return ""
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
    }
}
