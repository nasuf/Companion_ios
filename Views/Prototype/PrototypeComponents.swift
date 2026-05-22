import SwiftUI

enum PrototypeBackgroundStyle {
    case base
    case onboarding
    case online
    case scene
    case game
    case music
    case daily
    case movie
    case profile
}

struct PrototypeScreen<Content: View>: View {
    @Environment(\.prototypePalette) private var palette
    let showsBottomPadding: Bool
    let backgroundStyle: PrototypeBackgroundStyle
    let animatesBackground: Bool
    @ViewBuilder var content: () -> Content

    init(
        showsBottomPadding: Bool = true,
        backgroundStyle: PrototypeBackgroundStyle = .base,
        animatesBackground: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsBottomPadding = showsBottomPadding
        self.backgroundStyle = backgroundStyle
        self.animatesBackground = animatesBackground
        self.content = content
    }

    var body: some View {
        ZStack {
            PrototypeBackground(style: backgroundStyle, isAnimated: animatesBackground)
            content()
                .padding(.bottom, showsBottomPadding ? 92 : 0)
        }
        .foregroundStyle(palette.fg)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PrototypeBackground: View {
    @Environment(\.prototypePalette) private var palette
    var style: PrototypeBackgroundStyle = .base
    var isAnimated = true

    var body: some View {
        Group {
            if style == .game {
                PrototypeGameBackground(isAnimated: isAnimated)
            } else if isAnimated {
                TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
                    backgroundLayers(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            } else {
                backgroundLayers(time: 0)
            }
        }
    }

    private func backgroundLayers(time: TimeInterval) -> some View {
        ZStack {
            baseFill

            LinearGradient(
                colors: [
                    Color.white.opacity(style == .movie ? 0.38 : style == .onboarding ? 0.34 : 0.62),
                    Color.white.opacity(style == .onboarding ? 0.08 : 0.16),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.42)
            )

            if style != .onboarding {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.035)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            ForEach(Array(ambientFields.enumerated()), id: \.offset) { index, field in
                RoundedRectangle(cornerRadius: field.cornerRadius, style: .continuous)
                    .fill(field.gradient)
                    .frame(width: field.size.width, height: field.size.height)
                    .rotationEffect(.degrees(field.rotation + sin(time / field.period + Double(index)) * field.rotationDrift))
                    .offset(
                        x: field.offset.width + cos(time / field.period + Double(index) * 0.7) * field.drift.width,
                        y: field.offset.height + sin(time / (field.period * 0.86) + Double(index)) * field.drift.height
                    )
                    .blur(radius: field.blur)
                    .opacity(field.opacity)
            }

            if style == .game || style == .scene || style == .profile || style == .online {
                PrototypeFineGrid(step: style == .game ? 42 : 24, lineOpacity: style == .game ? 0.034 : 0.18)
                    .opacity(style == .game ? 1 : style == .online ? 0.16 : 0.10)
                    .offset(y: style == .game ? sin(time / 8) * 5 : 0)
            }

            if style == .music {
                PrototypeWaveMist(time: time)
                    .opacity(0.22)
            }
        }
        .ignoresSafeArea()
    }

    private var baseFill: some View {
        Group {
            if style == .onboarding {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFBFEFD),
                        Color(hex: 0xF7FCFB),
                        Color(hex: 0xF6FBFA)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if style == .online {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFFAF4).opacity(0.88),
                        Color(hex: 0xF9FAFF).opacity(0.96),
                        Color(hex: 0xEEF9F8).opacity(0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if style == .daily {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFFAF4).opacity(0.94),
                        Color(hex: 0xFBFBFF).opacity(0.98),
                        Color(hex: 0xEEF9F8).opacity(0.96)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if style == .profile {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFFAF4).opacity(0.92),
                        Color(hex: 0xF9FBFF).opacity(0.98),
                        Color(hex: 0xEEF9F8).opacity(0.98)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else if style == .game {
                LinearGradient(
                    colors: [
                        Color(hex: 0xFFFEFB),
                        Color(hex: 0xEEFCFF),
                        Color(hex: 0xFFF7F1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                palette.bg
            }
        }
    }

    private var ambientFields: [PrototypeAmbientField] {
        switch style {
        case .base:
            return [
                PrototypeAmbientField.topAccent(palette, width: 360, height: 240, x: 150, y: -118),
                PrototypeAmbientField.sideAccent(palette, width: 220, height: 170, x: -126, y: 168, opacity: 0.20),
                PrototypeAmbientField.warm(width: 190, height: 150, x: 190, y: 594, opacity: 0.10)
            ]
        case .onboarding:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x18C6C0).opacity(0.22), Color(hex: 0x1F6FFF).opacity(0.12)], width: 330, height: 260, x: 142, y: -58, opacity: 0.92),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x7C3CFF).opacity(0.12), Color(hex: 0x18C6C0).opacity(0.08)], width: 270, height: 224, x: -112, y: 300, opacity: 0.80),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x1F6FFF).opacity(0.10), Color(hex: 0x18C6C0).opacity(0.10)], width: 310, height: 240, x: 162, y: 560, opacity: 0.72)
            ]
        case .online:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x7BBEFF).opacity(0.28), Color(hex: 0x18C6C0).opacity(0.12)], width: 290, height: 240, x: 164, y: 80, opacity: 0.76),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFFBE8C).opacity(0.20), Color(hex: 0xFFFAF4).opacity(0.12)], width: 240, height: 210, x: -120, y: 176, opacity: 0.70),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xBA9DFF).opacity(0.17), Color(hex: 0x1F6FFF).opacity(0.08)], width: 320, height: 270, x: 156, y: 590, opacity: 0.72)
            ]
        case .scene:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x1F6FFF).opacity(0.22), Color(hex: 0x18C6C0).opacity(0.14)], width: 260, height: 218, x: 156, y: 96, opacity: 0.74),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF7A3D).opacity(0.14), Color(hex: 0xFFC936).opacity(0.10)], width: 250, height: 194, x: -118, y: 430, opacity: 0.72),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x7C3CFF).opacity(0.12), Color(hex: 0x22C66B).opacity(0.08)], width: 170, height: 150, x: 190, y: 650, opacity: 0.70)
            ]
        case .game:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF6948).opacity(0.18), Color(hex: 0xFFC936).opacity(0.08)], width: 210, height: 180, x: -128, y: -310, opacity: 0.76),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x1D76FF).opacity(0.14), Color(hex: 0x18C6C0).opacity(0.10)], width: 240, height: 210, x: 178, y: -246, opacity: 0.58),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF5E3B).opacity(0.18), Color(hex: 0xFFCF40).opacity(0.16)], width: 180, height: 180, x: -178, y: 44, opacity: 0.58)
            ]
        case .music:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x18C6C0).opacity(0.18), Color(hex: 0x1F6FFF).opacity(0.12)], width: 300, height: 230, x: 132, y: 96, opacity: 0.78),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF7A3D).opacity(0.11), Color(hex: 0xFFC936).opacity(0.10)], width: 220, height: 176, x: -104, y: 530, opacity: 0.68)
            ]
        case .daily:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF7940).opacity(0.18), Color(hex: 0x7C3CFF).opacity(0.12), Color(hex: 0x1F6FFF).opacity(0.10)], width: 260, height: 236, x: 146, y: 94, opacity: 0.76),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x1F6FFF).opacity(0.10), Color(hex: 0x18C6C0).opacity(0.10)], width: 280, height: 230, x: -126, y: 576, opacity: 0.70)
            ]
        case .movie:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x202724).opacity(0.22), Color(hex: 0x947C66).opacity(0.13)], width: 310, height: 230, x: 146, y: 96, opacity: 0.70),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xE35B6F).opacity(0.09), Color(hex: 0x1F6FFF).opacity(0.08)], width: 226, height: 176, x: -102, y: 560, opacity: 0.62)
            ]
        case .profile:
            return [
                PrototypeAmbientField.custom(colors: [Color(hex: 0x1F6FFF).opacity(0.22), Color(hex: 0x18C6C0).opacity(0.12)], width: 300, height: 230, x: 162, y: 48, opacity: 0.80),
                PrototypeAmbientField.custom(colors: [Color(hex: 0xFF8A3D).opacity(0.15), Color(hex: 0xFFC936).opacity(0.08)], width: 230, height: 190, x: -120, y: 206, opacity: 0.74),
                PrototypeAmbientField.custom(colors: [Color(hex: 0x7C3CFF).opacity(0.12), Color(hex: 0x1F6FFF).opacity(0.08)], width: 260, height: 218, x: 156, y: 620, opacity: 0.70)
            ]
        }
    }
}

private struct PrototypeAmbientField {
    let gradient: LinearGradient
    let size: CGSize
    let offset: CGSize
    let drift: CGSize
    let blur: CGFloat
    let cornerRadius: CGFloat
    let rotation: Double
    let rotationDrift: Double
    let period: Double
    let opacity: Double

    static func topAccent(
        _ palette: PrototypePalette,
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat
    ) -> PrototypeAmbientField {
        custom(
            colors: [palette.accentSoft.opacity(0.82), Color.white.opacity(0.16)],
            width: width,
            height: height,
            x: x,
            y: y,
            opacity: 0.82
        )
    }

    static func sideAccent(
        _ palette: PrototypePalette,
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat,
        opacity: Double
    ) -> PrototypeAmbientField {
        custom(
            colors: [palette.accent.opacity(0.16), palette.accentSoft.opacity(0.10)],
            width: width,
            height: height,
            x: x,
            y: y,
            opacity: opacity
        )
    }

    static func warm(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) -> PrototypeAmbientField {
        custom(colors: [Color(hex: 0xFF8A3D).opacity(0.12), Color(hex: 0xFFC936).opacity(0.08)], width: width, height: height, x: x, y: y, opacity: opacity)
    }

    static func rose(width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat, opacity: Double) -> PrototypeAmbientField {
        custom(colors: [Color(hex: 0xE35B6F).opacity(0.13), Color(hex: 0x7C3CFF).opacity(0.08)], width: width, height: height, x: x, y: y, opacity: opacity)
    }

    static func custom(
        colors: [Color],
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat,
        opacity: Double
    ) -> PrototypeAmbientField {
        PrototypeAmbientField(
            gradient: LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing),
            size: CGSize(width: width, height: height),
            offset: CGSize(width: x, height: y),
            drift: CGSize(width: 12, height: 18),
            blur: 28,
            cornerRadius: min(width, height) * 0.34,
            rotation: -12,
            rotationDrift: 7,
            period: 7.5,
            opacity: opacity
        )
    }
}

private struct PrototypeFineGrid: View {
    var step: CGFloat = 24
    var lineOpacity: Double = 0.18

    var body: some View {
        Canvas { context, size in
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(path, with: .color(Color.black.opacity(lineOpacity)), lineWidth: 0.5)
        }
        .ignoresSafeArea()
    }
}

private struct PrototypeGameBackground: View {
    let isAnimated: Bool
    @State private var floats = false
    @State private var piecesFloat = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0xFFFEFB),
                    Color(hex: 0xEEFCFF),
                    Color(hex: 0xFFF7F1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            LinearGradient(
                colors: [
                    Color.white.opacity(0.62),
                    Color.white.opacity(0.16),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: UnitPoint(x: 0.5, y: 0.42)
            )

            Color.clear
                .overlay(alignment: .topLeading) {
                    gameBlob(
                        colors: [Color(hex: 0xFF6948).opacity(0.18), Color(hex: 0xFFC936).opacity(0.08)],
                        width: 210,
                        height: 180,
                        x: -128,
                        y: -310,
                        opacity: 0.76,
                        delay: 0
                    )
                }
                .overlay(alignment: .topTrailing) {
                    gameBlob(
                        colors: [Color(hex: 0x1D76FF).opacity(0.14), Color(hex: 0x18C6C0).opacity(0.10)],
                        width: 240,
                        height: 210,
                        x: 44,
                        y: -246,
                        opacity: 0.58,
                        delay: 0.8
                    )
                }
                .overlay(alignment: .leading) {
                    gameBlob(
                        colors: [Color(hex: 0xFF5E3B).opacity(0.18), Color(hex: 0xFFCF40).opacity(0.16)],
                        width: 180,
                        height: 180,
                        x: -104,
                        y: 44,
                        opacity: 0.58,
                        delay: 1.4
                    )
                }

            PrototypeGameBoardBackdropSmooth(floats: floats, piecesFloat: piecesFloat)

            PrototypeFineGrid(step: 42, lineOpacity: 0.034)
                .offset(y: floats ? 5 : -2)
                .animation(isAnimated ? .easeInOut(duration: 8).repeatForever(autoreverses: true) : nil, value: floats)
        }
        .ignoresSafeArea()
        .onAppear {
            guard isAnimated else { return }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                floats = true
            }
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                piecesFloat = true
            }
        }
    }

    private func gameBlob(
        colors: [Color],
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        y: CGFloat,
        opacity: Double,
        delay: Double
    ) -> some View {
        RoundedRectangle(cornerRadius: min(width, height) * 0.34, style: .continuous)
            .fill(.linearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: width, height: height)
            .rotationEffect(.degrees(floats ? -5 : -16))
            .offset(x: x + (floats ? 12 : -6), y: y + (floats ? 18 : -8))
            .blur(radius: 28)
            .opacity(opacity)
            .animation(isAnimated ? .easeInOut(duration: 7.5 + delay).delay(delay).repeatForever(autoreverses: true) : nil, value: floats)
    }
}

private struct PrototypeGameBoardBackdropSmooth: View {
    let floats: Bool
    let piecesFloat: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(.linearGradient(
                        colors: [
                            Color(hex: 0x2DE087).opacity(0.52),
                            Color(hex: 0x2574FF).opacity(0.48)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(boardGrid.clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous)))
                    .overlay(boardPieces)
                    .shadow(color: Color(hex: 0x1F6FFF).opacity(0.13), radius: 32, y: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.white.opacity(0.36), lineWidth: 1)
                    )
            }
            .frame(width: 178, height: 126)
            .opacity(0.52)
            .rotationEffect(.degrees(floats ? -0.4 : -3.4))
            .position(
                x: proxy.size.width - 76 + (floats ? 7 : -5),
                y: 156 + (floats ? 8 : -6)
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: floats)
        }
        .ignoresSafeArea()
    }

    private var boardGrid: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 28
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += step
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += step
            }
            context.stroke(path, with: .color(Color(hex: 0x142836).opacity(0.12)), lineWidth: 0.7)
        }
    }

    private var boardPieces: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.82))
                .frame(width: 18, height: 18)
                .position(x: 42, y: piecesFloat ? 46 : 38)
            Capsule()
                .fill(Color.white.opacity(0.82))
                .frame(width: 34, height: 20)
                .position(x: 150, y: piecesFloat ? 55 : 63)
            Capsule()
                .fill(Color.white.opacity(0.82))
                .frame(width: 42, height: 18)
                .position(x: 84, y: piecesFloat ? 102 : 94)
        }
        .shadow(color: Color(hex: 0x1F4356).opacity(0.11), radius: 13, y: 10)
        .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: piecesFloat)
    }
}

private struct PrototypeWaveMist: View {
    @Environment(\.prototypePalette) private var palette
    let time: TimeInterval

    var body: some View {
        Canvas { context, size in
            let baseY = size.height * 0.34
            var path = Path()
            path.move(to: CGPoint(x: -20, y: baseY))
            stride(from: -20, through: size.width + 20, by: 14).forEach { x in
                let y = baseY + sin((x / 42) + time * 0.7) * 9
                path.addLine(to: CGPoint(x: x, y: y))
            }
            path.addLine(to: CGPoint(x: size.width + 20, y: baseY + 72))
            path.addLine(to: CGPoint(x: -20, y: baseY + 72))
            path.closeSubpath()
            context.fill(path, with: .linearGradient(
                Gradient(colors: [palette.accent.opacity(0.20), Color.clear]),
                startPoint: CGPoint(x: 0, y: baseY),
                endPoint: CGPoint(x: 0, y: baseY + 72)
            ))
        }
        .ignoresSafeArea()
    }
}

struct PrototypeKicker: View {
    @Environment(\.prototypePalette) private var palette
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .heavy))
            .foregroundStyle(palette.accent)
    }
}

struct PrototypeFloatingGlassTile: View {
    let size: CGSize
    var colors: [Color] = [Color(hex: 0x18C6C0), Color(hex: 0x1F6FFF)]
    var opacity: Double = 0.78

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let bob = sin(time / 2.4) * 5
            let tilt = sin(time / 3.2) * 4

            ZStack {
                RoundedRectangle(cornerRadius: size.width * 0.26, style: .continuous)
                    .fill(.linearGradient(
                        colors: colors.map { $0.opacity(0.82) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))

                RoundedRectangle(cornerRadius: size.width * 0.20, style: .continuous)
                    .stroke(Color.white.opacity(0.46), lineWidth: 1)
                    .padding(size.width * 0.16)

                Circle()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: size.width * 0.10, height: size.width * 0.10)
                    .offset(x: -size.width * 0.20, y: -size.height * 0.18)

                Circle()
                    .fill(Color.white.opacity(0.48))
                    .frame(width: size.width * 0.08, height: size.width * 0.08)
                    .offset(x: size.width * 0.16, y: size.height * 0.08)
            }
            .frame(width: size.width, height: size.height)
            .rotationEffect(.degrees(8 + tilt))
            .offset(y: bob)
            .opacity(opacity)
            .shadow(color: colors.last?.opacity(0.22) ?? .clear, radius: 32, y: 18)
        }
        .accessibilityHidden(true)
    }
}

struct PrototypeAvatar: View {
    @Environment(\.prototypePalette) private var palette
    let name: String
    var size: CGFloat = 38

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xF2FDFF),
                            Color(hex: 0x8EE7FF),
                            Color(hex: 0x4D91FF),
                            Color(hex: 0x7C3CFF)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(Color.white.opacity(0.32))
                .frame(width: size * 0.82, height: size * 0.82)
                .offset(x: -size * 0.10, y: -size * 0.02)

            Circle()
                .fill(Color.white.opacity(0.94))
                .frame(width: size * 0.58, height: size * 0.58)
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x16385F), Color(hex: 0x1F6FFF), Color(hex: 0x7C3CFF)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: size * 0.48, height: size * 0.22)
                        .offset(y: -size * 0.06)
                }
                .overlay {
                    HStack(spacing: size * 0.15) {
                        Circle()
                            .fill(Color(hex: 0x101820))
                            .frame(width: size * 0.055, height: size * 0.09)
                        Circle()
                            .fill(Color(hex: 0x101820))
                            .frame(width: size * 0.055, height: size * 0.09)
                    }
                    .offset(y: size * 0.05)
                }
                .overlay(alignment: .bottom) {
                    Capsule()
                        .stroke(Color(hex: 0x1C2B3A), lineWidth: max(1.1, size * 0.032))
                        .frame(width: size * 0.18, height: size * 0.08)
                        .offset(y: -size * 0.13)
                }

            Circle()
                .fill(Color(hex: 0xFFF06A))
                .frame(width: size * 0.10, height: size * 0.10)
                .overlay(
                    Circle()
                        .fill(Color(hex: 0x21D3C2))
                        .frame(width: size * 0.06, height: size * 0.06)
                        .offset(x: size * 0.04, y: size * 0.03)
                )
                .offset(x: size * 0.31, y: -size * 0.34)
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x1F6FFF).opacity(0.18), radius: size * 0.34, y: size * 0.14)
        .accessibilityLabel(name)
    }
}

struct PrototypeDetailActions: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.prototypePalette) private var palette
    var shareAction: (() -> Void)?

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .frame(width: 38, height: 38)
                    .prototypeLiquidGlass(cornerRadius: 19, tint: Color.white.opacity(0.24), interactive: true)
            }
            .buttonStyle(.prototypeGlassProminentPress)

            Spacer()

            if let shareAction {
                Button(action: shareAction) {
                    Text("发聊天")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(palette.accentInk)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(Color.white.opacity(0.76))
                        .clipShape(Capsule())
                        .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.28), interactive: true)
                }
                .buttonStyle(.prototypeGlassProminentPress)
            }
        }
        .foregroundStyle(palette.fg)
        .padding(.horizontal, 18)
    }
}

struct PrototypeRouteView: View {
    let route: PrototypeRoute

    var body: some View {
        switch route {
        case .music:
            PrototypeMusicView()
        case .movie:
            PrototypeMovieView()
        case .game:
            PrototypeGameView()
        case .daily(let tab):
            PrototypeDailyView(initialTab: tab)
        case .offlineInvite:
            PrototypeOfflineInviteView()
        case .progress:
            PrototypeProgressView()
        case .memory:
            MemoryTimelineView()
        case .emotion:
            EmotionTimelineView()
        case .portrait:
            UserPortraitView()
        case .schedule:
            ScheduleHistoryView()
        case .settings:
            SettingsView()
        }
    }
}
