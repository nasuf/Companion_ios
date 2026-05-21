import SwiftUI

struct PrototypeOnlineHubView: View {
    @Environment(\.prototypePalette) private var palette
    let openRoute: (PrototypeRoute) -> Void

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .online) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    portalGrid
                }
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            PrototypeKicker(text: "online room")
            Text("我想和你做的事情有很多")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(palette.fg)
                .frame(maxWidth: 300, alignment: .leading)
        }
        .padding(.top, 72)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .trailing) {
            PrototypeFloatingGlassTile(
                size: CGSize(width: 112, height: 112),
                colors: [Color(hex: 0x1F6FFF), Color(hex: 0x18C6C0)],
                opacity: 0.70
            )
                .padding(.trailing, 26)
                .padding(.top, 88)
        }
    }

    private var portalGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(PrototypeFixtures.portals.enumerated()), id: \.element.id) { index, portal in
                Button {
                    openRoute(portal.route)
                } label: {
                    PrototypePortalCard(portal: portal)
                }
                .buttonStyle(.prototypeGlassPress)
                .offset(y: index == 1 || index == 3 ? 12 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, -4)
    }
}

private struct PrototypePortalCard: View {
    let portal: PrototypePortal

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                PrototypeAssetImage(name: portal.image)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .overlay(.linearGradient(colors: [.clear, Color.white.opacity(0.40), Color.white.opacity(0.86)], startPoint: .top, endPoint: .bottom))

                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(portal.title)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(Color(hex: 0x11161A))
                        Text(portal.subtitle)
                            .font(.system(size: 10.4, weight: .regular))
                            .lineSpacing(1.5)
                            .lineLimit(2)
                            .foregroundStyle(Color(hex: 0x182026).opacity(0.62))
                        HStack {
                            Text(portal.metric)
                                .foregroundStyle(Color(hex: 0x11161A))
                            Spacer()
                            Text("›")
                                .font(.system(size: 17, weight: .heavy))
                        }
                        .font(.system(size: 10.5, weight: .heavy))
                        .foregroundStyle(Color(hex: 0x13191E).opacity(0.58))
                        .padding(.top, 7)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.54))
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .prototypeLiquidGlass(cornerRadius: 26, tint: Color.white.opacity(0.26))
                }
                .padding(10)
            }
            .background(Color.white.opacity(0.34))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .prototypeLiquidGlass(cornerRadius: 32, tint: Color.white.opacity(0.20), interactive: true)
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.86), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 28, y: 16)
        }
        .frame(height: 198)
    }
}
