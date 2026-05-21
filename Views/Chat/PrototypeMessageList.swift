import SwiftUI

struct PrototypeMessageList: View {
    static let bottomID = "prototype_chat_bottom"

    @Environment(\.prototypePalette) private var palette
    let messages: [Message]
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMoreHistory: Bool
    let isTyping: Bool
    let showEmojiPanel: Bool
    let showMorePanel: Bool
    let loadMoreHistory: () -> Void
    let onMessageVisible: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 13) {
                topHistoryTrigger

                if isLoading && messages.isEmpty {
                    ProgressView()
                        .padding(.top, 40)
                } else if messages.isEmpty {
                    PrototypeEmptyConversation()
                        .padding(.top, 32)
                }

                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                    PrototypeMessageBubble(message: message)
                        .id(message.id)
                        .onAppear { onMessageVisible(index) }
                }

                if isTyping {
                    PrototypeTypingBubble()
                }

                Color.clear
                    .frame(height: bottomSpacerHeight)
                    .id(Self.bottomID)
            }
            .padding(.top, 22)
        }
        .scrollIndicators(.hidden)
    }

    @ViewBuilder
    private var topHistoryTrigger: some View {
        if isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        } else if hasMoreHistory {
            Color.clear
                .frame(height: 1)
                .onAppear(perform: loadMoreHistory)
        }
    }

    private var bottomSpacerHeight: CGFloat {
        if showMorePanel || showEmojiPanel { return 18 }
        return 20
    }
}

private struct PrototypeEmptyConversation: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrototypeKicker(text: "companion")
            Text("我在。")
                .font(.system(size: 20, weight: .heavy))
            Text("从一句很短的话开始也可以。这里会接入真实聊天记录和 WebSocket 回复。")
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .prototypeCard(cornerRadius: 20, padding: 14)
        .padding(.horizontal, 16)
    }
}

private struct PrototypeTypingBubble: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            PrototypeAvatar(name: PrototypeFixtures.agentName, size: 36)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(palette.subtle)
                        .frame(width: 5, height: 5)
                        .opacity(index == 1 ? 0.55 : 0.9)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.24))
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}
