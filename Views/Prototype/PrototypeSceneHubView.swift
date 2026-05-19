import SwiftUI

struct PrototypeSceneHubView: View {
    @Environment(\.prototypePalette) private var palette
    let openRoute: (PrototypeRoute) -> Void

    var body: some View {
        PrototypeScreen(backgroundStyle: .scene) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    PrototypeRouteMap()
                        .frame(height: 126)
                    moduleGrid
                    waitingPanel
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrototypeKicker(text: "real world board")
            Text("我想，参与你的每一个真实时刻")
                .font(.system(size: 31, weight: .heavy))
                .foregroundStyle(palette.fg)
            Text("那些你说过的约定、期待和小事，我都记得。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.top, 76)
    }

    private var moduleGrid: some View {
        HStack(spacing: 12) {
            ForEach(PrototypeFixtures.sceneModules) { module in
                Button {
                    openRoute(module.route)
                } label: {
                    PrototypeSceneModuleCard(module: module)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var waitingPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("陪你一起等")
                        .font(.system(size: 18, weight: .heavy))
                    Text("\(PrototypeFixtures.agentName) 只在需要你行动时提醒你")
                        .font(.system(size: 12))
                        .foregroundStyle(palette.muted)
                }
                Spacer()
            }
            ForEach([("19:30", "影院 B612", "已出票"), ("18m", "奶茶配送", "路上"), ("11m", "专注计时", "进行中")], id: \.0) { item in
                HStack {
                    Text(item.0).font(.system(size: 14, weight: .heavy))
                    Text(item.1).font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Text(item.2).font(.system(size: 11)).foregroundStyle(palette.subtle)
                }
            }
        }
        .prototypeCard(cornerRadius: 24, padding: 15)
    }
}

private struct PrototypeSceneModuleCard: View {
    @Environment(\.prototypePalette) private var palette
    let module: PrototypeSceneModule

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: module.symbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(module.color)
                    .frame(width: 42, height: 42)
                    .background(module.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Spacer()
                Text(module.status)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(palette.muted)
                    .padding(.horizontal, 9)
                    .frame(height: 24)
                    .background(Color.white.opacity(0.5))
                    .clipShape(Capsule())
            }

            Text(module.title)
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(palette.fg)
            Text(module.subtitle)
                .font(.system(size: 11))
                .foregroundStyle(palette.muted)
                .lineLimit(2)
            Text("进入 ›")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.fg)
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .prototypeCard(cornerRadius: 24, padding: 13)
    }
}

private struct PrototypeRouteMap: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.24))
                .prototypeLiquidGlass(cornerRadius: 28, tint: Color.white.opacity(0.22))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.78), lineWidth: 1)
                )

            Path { path in
                path.move(to: CGPoint(x: 24, y: 92))
                path.addCurve(to: CGPoint(x: 140, y: 70), control1: CGPoint(x: 64, y: 22), control2: CGPoint(x: 102, y: 42))
                path.addCurve(to: CGPoint(x: 286, y: 30), control1: CGPoint(x: 184, y: 110), control2: CGPoint(x: 242, y: 104))
            }
            .stroke(.linearGradient(colors: [Color(hex: 0xFF7A3D), palette.accent], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 5, lineCap: .round))

            ForEach([CGPoint(x: 72, y: 58), CGPoint(x: 220, y: 66), CGPoint(x: 294, y: 26)], id: \.x) { point in
                Circle()
                    .fill(palette.accent)
                    .frame(width: 14, height: 14)
                    .position(point)
            }

            Text("LIVE")
                .font(.system(size: 9, weight: .heavy))
                .foregroundStyle(palette.accent)
                .position(x: 306, y: 48)
        }
    }
}
