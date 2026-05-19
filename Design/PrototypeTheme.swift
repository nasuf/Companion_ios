import SwiftUI
import UIKit

enum PrototypeTheme: String, CaseIterable, Identifiable {
    case blue
    case warm
    case mint
    case rose
    case dark

    var id: String { rawValue }

    var name: String {
        switch self {
        case .blue: "雾白"
        case .warm: "暖石"
        case .mint: "青植"
        case .rose: "淡蔷"
        case .dark: "夜幕"
        }
    }

    var subtitle: String {
        switch self {
        case .blue: "安静、克制、展示友好"
        case .warm: "柔和但不过甜"
        case .mint: "清醒、健康、松弛"
        case .rose: "亲密、柔软、低饱和"
        case .dark: "低亮度、深夜对话"
        }
    }

    var palette: PrototypePalette {
        switch self {
        case .blue:
            PrototypePalette(
                bg: Color(hex: 0xF7F8F6),
                surface: Color.white.opacity(0.86),
                surface2: Color(hex: 0xEFF2F0),
                fg: Color(hex: 0x151716),
                muted: Color(hex: 0x68706D),
                subtle: Color(hex: 0x98A09C),
                hairline: Color.black.opacity(0.075),
                accent: Color(hex: 0x3B6F78),
                accentInk: Color(hex: 0x173B42),
                accentSoft: Color(hex: 0xE7F0EE),
                tab: Color(hex: 0x121413).opacity(0.94)
            )
        case .warm:
            PrototypePalette(
                bg: Color(hex: 0xF8F6F1),
                surface: Color.white.opacity(0.86),
                surface2: Color(hex: 0xF1ECE4),
                fg: Color(hex: 0x181614),
                muted: Color(hex: 0x706A62),
                subtle: Color(hex: 0xA0998E),
                hairline: Color(hex: 0x281F14).opacity(0.075),
                accent: Color(hex: 0x8A6B3F),
                accentInk: Color(hex: 0x4C351A),
                accentSoft: Color(hex: 0xF0EADF),
                tab: Color(hex: 0x1A1611).opacity(0.94)
            )
        case .mint:
            PrototypePalette(
                bg: Color(hex: 0xF5F8F5),
                surface: Color.white.opacity(0.86),
                surface2: Color(hex: 0xEDF3EF),
                fg: Color(hex: 0x141817),
                muted: Color(hex: 0x62706A),
                subtle: Color(hex: 0x96A29D),
                hairline: Color(hex: 0x142A22).opacity(0.075),
                accent: Color(hex: 0x4C7963),
                accentInk: Color(hex: 0x1C3F31),
                accentSoft: Color(hex: 0xE6F0EA),
                tab: Color(hex: 0x101714).opacity(0.94)
            )
        case .rose:
            PrototypePalette(
                bg: Color(hex: 0xF9F6F6),
                surface: Color.white.opacity(0.86),
                surface2: Color(hex: 0xF2EBED),
                fg: Color(hex: 0x181516),
                muted: Color(hex: 0x71666A),
                subtle: Color(hex: 0xA3969B),
                hairline: Color(hex: 0x311620).opacity(0.075),
                accent: Color(hex: 0x9A6871),
                accentInk: Color(hex: 0x512D35),
                accentSoft: Color(hex: 0xF1E7EA),
                tab: Color(hex: 0x181214).opacity(0.94)
            )
        case .dark:
            PrototypePalette(
                bg: Color(hex: 0x111513),
                surface: Color.white.opacity(0.055),
                surface2: Color(hex: 0x252B28),
                fg: Color(hex: 0xF5F4F1),
                muted: Color(hex: 0xAEB7B2),
                subtle: Color(hex: 0x7E8782),
                hairline: Color.white.opacity(0.08),
                accent: Color(hex: 0x9FC4BC),
                accentInk: Color(hex: 0xDCEFEB),
                accentSoft: Color(hex: 0x263D39),
                tab: Color(hex: 0x080A09).opacity(0.95)
            )
        }
    }
}

struct PrototypePalette {
    let bg: Color
    let surface: Color
    let surface2: Color
    let fg: Color
    let muted: Color
    let subtle: Color
    let hairline: Color
    let accent: Color
    let accentInk: Color
    let accentSoft: Color
    let tab: Color
}

private struct PrototypeThemeKey: EnvironmentKey {
    static let defaultValue: PrototypeTheme = .blue
}

extension EnvironmentValues {
    var prototypeTheme: PrototypeTheme {
        get { self[PrototypeThemeKey.self] }
        set { self[PrototypeThemeKey.self] = newValue }
    }

    var prototypePalette: PrototypePalette {
        prototypeTheme.palette
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension View {
    func prototypeCard(cornerRadius: CGFloat = 18, padding: CGFloat = 13) -> some View {
        modifier(PrototypeCardModifier(cornerRadius: cornerRadius, padding: padding))
    }

    @ViewBuilder
    func prototypeLiquidGlass(
        cornerRadius: CGFloat = 18,
        tint: Color = .white.opacity(0.18),
        interactive: Bool = false
    ) -> some View {
        if #available(iOS 26.0, *) {
            if interactive {
                self.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

private struct PrototypeCardModifier: ViewModifier {
    @Environment(\.prototypePalette) private var palette
    let cornerRadius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(palette.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .prototypeLiquidGlass(cornerRadius: cornerRadius, tint: palette.surface.opacity(0.35))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(palette.hairline, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 18, y: 10)
    }
}

struct PrototypeAssetImage: View {
    let name: String
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let image = UIImage.prototype(named: name) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Rectangle()
                    .fill(.linearGradient(
                        colors: [Color(hex: 0xE7F0EE), Color.white.opacity(0.45)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        }
    }
}

extension UIImage {
    static func prototype(named rawName: String) -> UIImage? {
        let url = URL(fileURLWithPath: rawName)
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension.isEmpty ? nil : url.pathExtension
        let directories = ["assets/prototype", "assets/prototype/remote", "assets/prototype/games", "assets/prototype/auth", nil]

        for directory in directories {
            if let path = Bundle.main.path(forResource: base, ofType: ext, inDirectory: directory) {
                return UIImage(contentsOfFile: path)
            }
            if let image = UIImage(named: base) {
                return image
            }
        }
        return nil
    }
}
