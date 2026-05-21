import SwiftUI

struct PrototypeSceneHubView: View {
    @Environment(\.prototypePalette) private var palette
    let openRoute: (PrototypeRoute) -> Void

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .scene) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    moduleGrid
                    signalList
                }
                .padding(.horizontal, 16)
                .padding(.top, 76)
                .padding(.bottom, 126)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 16) {
                PrototypeKicker(text: "real world board")
                Text("我想，参与你的每一个真实时刻")
                    .font(.system(size: 41, weight: .heavy))
                    .lineSpacing(-1)
                    .frame(maxWidth: 292, alignment: .leading)
                Text("那些你说过的约定、期待和小事，我都记得。")
                    .font(.system(size: 14, weight: .regular))
                    .lineSpacing(5)
                    .foregroundStyle(Color(hex: 0x151D22).opacity(0.56))
                    .frame(maxWidth: 292, alignment: .leading)
            }
            .padding(.horizontal, 6)
            .padding(.top, 16)

            PrototypeRouteMap()
                .frame(width: 252, height: 164)
                .offset(x: 120, y: 160)
        }
        .frame(maxWidth: .infinity, minHeight: 318, alignment: .topLeading)
    }

    private var moduleGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(PrototypeFixtures.sceneModules) { module in
                Button {
                    openRoute(module.route)
                } label: {
                    PrototypeSceneModuleCard(module: module)
                }
                .buttonStyle(.prototypeGlassPress)
            }
        }
    }

    private var signalList: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 12) {
                Text("陪你一起等")
                    .font(.system(size: 22, weight: .heavy))
                Spacer()
                Text("\(PrototypeFixtures.agentName) 只在需要你行动时提醒你")
                    .font(.system(size: 11, weight: .semibold))
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: 0x151D22).opacity(0.52))
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 160, alignment: .trailing)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 11)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.075))
                    .frame(height: 1)
            }

            ForEach([("19:30", "影院 B612", "已出票"), ("18m", "奶茶配送", "路上"), ("11m", "专注计时", "进行中")], id: \.0) { item in
                Button {
                } label: {
                    HStack(spacing: 12) {
                        Text(item.0)
                            .font(.system(size: 17, weight: .heavy))
                            .monospacedDigit()
                            .frame(width: 64, alignment: .leading)
                        Text(item.1)
                            .font(.system(size: 14, weight: .heavy))
                        Spacer()
                        Text(item.2)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(Color(hex: 0x151D22).opacity(0.48))
                    }
                    .foregroundStyle(Color(hex: 0x10171D))
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.black.opacity(0.075))
                            .frame(height: 1)
                    }
                }
                .buttonStyle(.prototypeGlassPress)
            }
        }
        .padding(.top, 4)
    }
}

private struct PrototypeSceneModuleCard: View {
    let module: PrototypeSceneModule

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [
                    module.color.opacity(0.84),
                    secondaryColor.opacity(0.76)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.34))
                .frame(width: 132, height: 118)
                .blur(radius: 2)
                .offset(x: 78, y: -32)

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .frame(width: 120, height: 88)
                .rotationEffect(.degrees(-9))
                .offset(x: 78, y: 132)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Image(systemName: module.symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(module.color.opacity(0.90))
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.10), radius: 16, y: 8)
                    Spacer()
                    Text(module.status)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(Color(hex: 0x10171D).opacity(0.68))
                        .padding(.horizontal, 10)
                        .frame(height: 25)
                        .background(Color.white.opacity(0.54))
                        .clipShape(Capsule())
                }

                Spacer(minLength: 34)

                Text(module.title)
                    .font(.system(size: 24, weight: .heavy))
                    .lineSpacing(-1)
                Text(module.subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: 0x10171D).opacity(0.62))
                    .lineLimit(2)
                    .padding(.top, 8)
                Text("进入 ›")
                    .font(.system(size: 12, weight: .heavy))
                    .padding(.top, 16)
            }
            .padding(17)
        }
        .foregroundStyle(Color(hex: 0x10171D))
        .frame(maxWidth: .infinity, minHeight: 206, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            LinearGradient(
                colors: [Color.white.opacity(0.50), Color.white.opacity(0.18), Color.white.opacity(0.62)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .allowsHitTesting(false)
        )
        .shadow(color: module.color.opacity(0.22), radius: 28, y: 18)
    }

    private var secondaryColor: Color {
        module.id == "progress" ? Color(hex: 0x18C6C0) : Color(hex: 0xFFC936)
    }
}

private struct PrototypeRouteMap: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(Color.white.opacity(0.28))
                .overlay(PrototypeMapGrid().opacity(0.60).clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous)))
                .mask(
                    RadialGradient(
                        colors: [.black, .black.opacity(0.86), .clear],
                        center: .center,
                        startRadius: 40,
                        endRadius: 132
                    )
                )

            Path { path in
                path.move(to: CGPoint(x: 28, y: 122))
                path.addCurve(to: CGPoint(x: 132, y: 70), control1: CGPoint(x: 66, y: 44), control2: CGPoint(x: 102, y: 42))
                path.addCurve(to: CGPoint(x: 226, y: 42), control1: CGPoint(x: 166, y: 104), control2: CGPoint(x: 206, y: 86))
            }
            .stroke(Color(hex: 0x1F6FFF).opacity(0.34), style: StrokeStyle(lineWidth: 4, lineCap: .round))

            ForEach(Array([
                (CGPoint(x: 48, y: 116), Color(hex: 0xFF7A3D)),
                (CGPoint(x: 132, y: 62), Color(hex: 0x1F6FFF)),
                (CGPoint(x: 218, y: 44), Color(hex: 0x22C66B))
            ].enumerated()), id: \.offset) { _, item in
                let point = item.0
                let color = item.1
                Circle()
                    .fill(color)
                    .frame(width: 13, height: 13)
                    .shadow(color: color.opacity(0.28), radius: 10)
                    .position(point)
            }

            Text("LIVE")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(Color(hex: 0x1F6FFF))
                .padding(.horizontal, 10)
                .frame(height: 24)
                .background(Color.white.opacity(0.66))
                .clipShape(Capsule())
                .position(x: 202, y: 132)
        }
        .accessibilityHidden(true)
    }
}

private struct PrototypeMapGrid: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            stride(from: 0, through: size.width, by: 30).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
            }
            stride(from: 0, through: size.height, by: 30).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(Color.black.opacity(0.08)), lineWidth: 1)
        }
    }
}
