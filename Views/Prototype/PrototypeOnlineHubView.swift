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
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(PrototypeFixtures.portals) { portal in
                Button {
                    openRoute(portal.route)
                } label: {
                    PrototypePortalCard(portal: portal)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct PrototypePortalCard: View {
    @Environment(\.prototypePalette) private var palette
    let portal: PrototypePortal

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PrototypeAssetImage(name: portal.image)
                .frame(height: 112)
                .clipped()
                .overlay(.linearGradient(colors: [.clear, Color.white.opacity(0.82)], startPoint: .top, endPoint: .bottom))

            VStack(alignment: .leading, spacing: 6) {
                Text(portal.title)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(palette.fg)
                Text(portal.subtitle)
                    .font(.system(size: 10.5))
                    .lineLimit(3)
                    .foregroundStyle(palette.muted)
                HStack {
                    Text(portal.metric)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.fg.opacity(0.66))
                .padding(.top, 8)
            }
            .padding(14)
        }
        .frame(height: 220)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 32, tint: Color.white.opacity(0.32), interactive: true)
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.86), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 24, y: 14)
    }
}
