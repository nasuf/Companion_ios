import SwiftUI

struct PrototypeGameView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var activeGroupID = PrototypeFixtures.gameGroups.first?.id ?? "board"

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .game) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    intro
                    groupList
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 14) {
            PrototypeKicker(text: "live mini game")
            Text("在游戏里慢慢呼吸")
                .font(.system(size: 34, weight: .heavy))
            Text("不用多说，一起玩一会儿就好")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
            HStack(spacing: 10) {
                metric("16", "可玩游戏")
                metric("12848", "累计积分")
                metric("语音", "可同步")
            }
        }
        .padding(.horizontal, 18)
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 17, weight: .heavy))
            Text(label).font(.system(size: 9, weight: .semibold)).foregroundStyle(palette.subtle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var groupList: some View {
        VStack(spacing: 12) {
            ForEach(PrototypeFixtures.gameGroups) { group in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.84)) {
                        activeGroupID = group.id
                    }
                } label: {
                    GameGroupCard(group: group, isOpen: activeGroupID == group.id)
                }
                .buttonStyle(.prototypeGlassPress)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct GameGroupCard: View {
    @Environment(\.prototypePalette) private var palette
    let group: PrototypeGameGroup
    let isOpen: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            ZStack(alignment: .bottomLeading) {
                GeometryReader { proxy in
                    PrototypeAssetImage(name: group.image)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .overlay(.linearGradient(colors: [.clear, Color.black.opacity(0.72)], startPoint: .top, endPoint: .bottom))
                }
                .frame(height: isOpen ? 184 : 116)

                VStack(alignment: .leading, spacing: 7) {
                    Text(group.kicker)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.72))
                    Text(group.title)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(.white)
                    Text(group.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                    HStack {
                        chip(group.badge)
                        chip(group.metric)
                    }
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            if isOpen {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(group.games) { game in
                        ZStack(alignment: .bottomLeading) {
                            GeometryReader { proxy in
                                PrototypeAssetImage(name: game.image)
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                                    .clipped()
                                    .overlay(.linearGradient(colors: [.clear, Color.black.opacity(0.70)], startPoint: .top, endPoint: .bottom))
                            }
                            .frame(height: 118)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(game.title)
                                    .font(.system(size: 14, weight: .heavy))
                                Text(game.note)
                                    .font(.system(size: 10))
                                    .lineLimit(2)
                            }
                            .foregroundStyle(.white)
                            .padding(10)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(10)
        .background(group.color.opacity(isOpen ? 0.13 : 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 32, tint: Color.white.opacity(0.24), interactive: true)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.70), lineWidth: 1)
        )
        .shadow(color: group.color.opacity(isOpen ? 0.16 : 0.08), radius: 22, y: 12)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .frame(height: 26)
            .background(Color.white.opacity(0.20))
            .clipShape(Capsule())
    }
}
