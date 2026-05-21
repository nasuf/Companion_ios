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
        ZStack(alignment: .topLeading) {
            OnlineHeroFloaters()

            VStack(alignment: .leading, spacing: 16) {
                PrototypeKicker(text: "online room")
                Text("我想和你做的事情有很多")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(palette.fg)
                    .lineSpacing(-1)
                    .frame(maxWidth: 292, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
        .padding(.top, 46)
        .padding(.horizontal, 18)
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

private struct OnlineHeroFloaters: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack(alignment: .topLeading) {
                OnlinePrimaryFloater()
                    .frame(width: 204, height: 172)
                    .rotationEffect(.degrees(13 + sin(time / 3.0) * 2.8))
                    .offset(
                        x: 220 + cos(time / 3.8) * 11,
                        y: 18 + sin(time / 3.8) * 9
                    )

                OnlineGlassTile()
                    .frame(width: 84, height: 84)
                    .rotationEffect(.degrees(10 + sin(time / 3.25 + 0.6) * 2.5))
                    .offset(
                        x: 282 + cos(time / 3.25 + 0.6) * 5,
                        y: 122 - sin(time / 3.25 + 0.6) * 6
                    )

                OnlineGlassOrb()
                    .frame(width: 104, height: 104)
                    .rotationEffect(.degrees(8 - sin(time / 3.6) * 6))
                    .offset(
                        x: 238 + cos(time / 3.6 + 1.2) * 7,
                        y: 100 + sin(time / 3.6 + 1.2) * 5
                    )
            }
        }
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .topLeading)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct OnlinePrimaryFloater: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0x3D9EFF).opacity(0.56),
                            Color(hex: 0x18C6C0).opacity(0.28)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.80),
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.0)
                ],
                center: UnitPoint(x: 0.35, y: 0.24),
                startRadius: 0,
                endRadius: 42
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
        .opacity(0.78)
        .shadow(color: Color(hex: 0x5B8FDE).opacity(0.18), radius: 30, y: 18)
    }
}

private struct OnlineGlassOrb: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.48),
                            Color(hex: 0xE8FEFF).opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial.opacity(0.78), in: RoundedRectangle(cornerRadius: 36, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(Color.white.opacity(0.58), lineWidth: 1)
                )
                .shadow(color: Color(hex: 0x548BC4).opacity(0.18), radius: 24, y: 14)

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.36), lineWidth: 1)
                .padding(18)

            Circle()
                .fill(Color(hex: 0xE8FEFF))
                .frame(width: 12, height: 12)
                .shadow(color: Color(hex: 0x1F6FFF).opacity(0.28), radius: 18)
                .offset(x: -28, y: -26)

            Circle()
                .fill(Color(hex: 0xE8FEFF).opacity(0.82))
                .frame(width: 10, height: 10)
                .shadow(color: Color(hex: 0x18C6C0).opacity(0.24), radius: 16)
                .offset(x: 26, y: -6)

            Circle()
                .fill(Color(hex: 0xE8FEFF).opacity(0.88))
                .frame(width: 12, height: 12)
                .shadow(color: Color(hex: 0x1F6FFF).opacity(0.22), radius: 16)
                .offset(x: -4, y: 30)
        }
    }
}

private struct OnlineGlassTile: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.56),
                            Color.white.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.78),
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.0)
                ],
                center: UnitPoint(x: 0.32, y: 0.22),
                startRadius: 0,
                endRadius: 22
            )
        }
        .background(.ultraThinMaterial.opacity(0.54), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.50), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x5184BE).opacity(0.20), radius: 26, y: 16)
    }
}

private struct PrototypePortalCard: View {
    let portal: PrototypePortal

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                BreathingPortalImage(name: portal.image)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                PortalBottomBlur()

                PortalText(portal: portal)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .background(Color.white.opacity(0.34))
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.white.opacity(0.86), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 28, y: 16)
        }
        .frame(height: 232)
    }
}

private struct BreathingPortalImage: View {
    let name: String
    @State private var breathes = false

    var body: some View {
        GeometryReader { proxy in
            PrototypeAssetImage(name: name)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(breathes ? 1.105 : 1.075)
                .offset(
                    x: breathes ? motion.endX : motion.startX,
                    y: breathes ? motion.endY : motion.startY
                )
                .animation(
                    .easeInOut(duration: motion.duration)
                        .repeatForever(autoreverses: true),
                    value: breathes
                )
                .onAppear {
                    breathes = true
                }
        }
        .accessibilityHidden(true)
    }

    private var motion: (startX: CGFloat, endX: CGFloat, startY: CGFloat, endY: CGFloat, duration: Double) {
        switch name {
        case "movie-bouquet.jpg":
            return (-7, 8, 4, -6, 8.8)
        case "game-pieces.jpg":
            return (8, -6, -5, 6, 9.4)
        case "vinyl-record.jpg":
            return (-5, 7, -4, 5, 10.2)
        default:
            return (6, -7, 5, -5, 8.4)
        }
    }
}

private struct PortalBottomBlur: View {
    var body: some View {
        VStack {
            Spacer()
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        stops: [
                            .init(color: Color.white.opacity(0.0), location: 0.0),
                            .init(color: Color.white.opacity(0.50), location: 0.30),
                            .init(color: Color.white.opacity(0.88), location: 0.56),
                            .init(color: Color.white.opacity(1.0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: Color.black.opacity(0.0), location: 0.0),
                            .init(color: Color.black.opacity(0.36), location: 0.18),
                            .init(color: Color.black.opacity(0.92), location: 0.46),
                            .init(color: Color.black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 174)
        }
        .allowsHitTesting(false)
    }
}

private struct PortalText: View {
    let portal: PrototypePortal

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(portal.title)
                .font(.system(size: 21, weight: .heavy))
                .foregroundStyle(Color(hex: 0x11161A))
            Text(portal.subtitle)
                .font(.system(size: 12, weight: .regular))
                .lineSpacing(2)
                .lineLimit(2)
                .foregroundStyle(Color(hex: 0x182026).opacity(0.62))
            HStack {
                Text(portal.metric)
                    .foregroundStyle(Color(hex: 0x11161A))
                Spacer()
                Text("›")
                    .font(.system(size: 17, weight: .heavy))
            }
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(Color(hex: 0x13191E).opacity(0.58))
            .padding(.top, 7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
