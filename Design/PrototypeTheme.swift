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

enum CreationPalette {
    static let fg = Color(hex: 0x10161A)
    static let body = Color(hex: 0x182026).opacity(0.58)
    static let label = Color(hex: 0x182026).opacity(0.50)
    static let subtle = Color(hex: 0x182026).opacity(0.34)
    static let hairline = Color(hex: 0x182026).opacity(0.075)
    static let accent = Color(hex: 0x18C6C0)
    static let accentInk = Color(hex: 0x143137)
    static let blue = Color(hex: 0x1F6FFF)
    static let purple = Color(hex: 0x7C3CFF)
    static let action = Color(hex: 0x1F6FFF)
    static let actionAlt = Color(hex: 0x18C6C0)
    static let actionInk = Color(hex: 0x123F86)
    static let actionSoft = Color(hex: 0xEAF5FF)
    static let card = Color.white.opacity(0.78)
    static let cardStrong = Color.white.opacity(0.88)
    static let track = Color(hex: 0x182026).opacity(0.08)

    static var actionGradient: LinearGradient {
        LinearGradient(
            colors: [actionAlt, action],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static let traitColors = [
        Color(hex: 0x18C6C0),
        Color(hex: 0x1F6FFF),
        Color(hex: 0x7C3CFF),
        Color(hex: 0xFF6A3D),
        Color(hex: 0x22C66B),
        Color(hex: 0xFFC936),
        Color(hex: 0xE35B6F)
    ]
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

struct PrototypeGlassPressButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.965
    var pressedOpacity: Double = 0.86
    var pressedBrightness: Double = 0.018

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? pressedOpacity : 1)
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.74), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrototypeGlassPressButtonStyle {
    static var prototypeGlassPress: PrototypeGlassPressButtonStyle {
        PrototypeGlassPressButtonStyle()
    }

    static var prototypeGlassProminentPress: PrototypeGlassPressButtonStyle {
        PrototypeGlassPressButtonStyle(scale: 0.975, pressedOpacity: 0.92, pressedBrightness: 0.026)
    }
}

struct PrototypeGlassSegmentedControl<Option: Hashable>: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var selection: Option
    let options: [Option]
    let title: (Option) -> String
    var activeTint: Color?
    var activeForeground: Color?
    var inactiveForeground: Color?
    var trackTint: Color = Color.white.opacity(0.28)
    var height: CGFloat = 38

    @Namespace private var selectionNamespace

    init(
        options: [Option],
        selection: Binding<Option>,
        title: @escaping (Option) -> String,
        activeTint: Color? = nil,
        activeForeground: Color? = nil,
        inactiveForeground: Color? = nil,
        trackTint: Color = Color.white.opacity(0.28),
        height: CGFloat = 38
    ) {
        self.options = options
        _selection = selection
        self.title = title
        self.activeTint = activeTint
        self.activeForeground = activeForeground
        self.inactiveForeground = inactiveForeground
        self.trackTint = trackTint
        self.height = height
    }

    var body: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 3
            let spacing: CGFloat = 3
            let width = max(0, (proxy.size.width - padding * 2 - spacing * CGFloat(max(0, options.count - 1))) / CGFloat(max(1, options.count)))

            ZStack(alignment: .leading) {
                glassLayer(width: width, padding: padding, spacing: spacing)

                HStack(spacing: spacing) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                                selection = option
                            }
                        } label: {
                            Text(title(option))
                                .font(.system(size: 12, weight: .heavy))
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                                .foregroundStyle(selection == option ? selectedForeground : unselectedForeground)
                                .frame(maxWidth: .infinity)
                                .frame(height: height - padding * 2)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.prototypeGlassProminentPress)
                    }
                }
                .padding(padding)
            }
            .contentShape(Capsule())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateSelection(
                            at: value.location.x,
                            totalWidth: proxy.size.width,
                            padding: padding,
                            spacing: spacing
                        )
                    }
            )
        }
        .frame(height: height)
        .sensoryFeedback(.selection, trigger: selection)
        .animation(.spring(response: 0.34, dampingFraction: 0.78), value: selection)
    }

    private var selectedForeground: Color {
        activeForeground ?? activeTint ?? palette.accentInk
    }

    private var unselectedForeground: Color {
        inactiveForeground ?? palette.muted
    }

    private var selectedTint: Color {
        activeTint ?? palette.accent
    }

    private var selectionIndex: Int {
        options.firstIndex(of: selection) ?? 0
    }

    private func updateSelection(
        at locationX: CGFloat,
        totalWidth: CGFloat,
        padding: CGFloat,
        spacing: CGFloat
    ) {
        guard !options.isEmpty else { return }

        let usableWidth = max(1, totalWidth - padding * 2 - spacing * CGFloat(max(0, options.count - 1)))
        let segmentWidth = usableWidth / CGFloat(options.count)
        let clampedX = min(max(locationX - padding, 0), usableWidth - 1)
        let rawIndex = Int((clampedX / segmentWidth).rounded(.down))
        let index = min(max(rawIndex, 0), options.count - 1)
        let next = options[index]

        guard next != selection else { return }
        withAnimation(.spring(response: 0.30, dampingFraction: 0.76)) {
            selection = next
        }
    }

    @ViewBuilder
    private func glassLayer(width: CGFloat, padding: CGFloat, spacing: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 8) {
                ZStack(alignment: .leading) {
                    track

                    selectedPill
                        .frame(width: width, height: height - padding * 2)
                        .offset(x: padding + CGFloat(selectionIndex) * (width + spacing))
                }
            }
        } else {
            ZStack(alignment: .leading) {
                track

                selectedPill
                    .frame(width: width, height: height - padding * 2)
                    .offset(x: padding + CGFloat(selectionIndex) * (width + spacing))
            }
        }
    }

    @ViewBuilder
    private var track: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(Color.white.opacity(0.08))
                .glassEffect(.regular.tint(trackTint).interactive(), in: .rect(cornerRadius: height / 2))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.60), lineWidth: 1)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.white.opacity(0.52), lineWidth: 1))
        }
    }

    @ViewBuilder
    private var selectedPill: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.58),
                            selectedTint.opacity(0.16),
                            Color.white.opacity(0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.78), lineWidth: 1)
                )
                .overlay(
                    Capsule()
                        .stroke(selectedTint.opacity(0.28), lineWidth: 1)
                        .blur(radius: 1.2)
                        .padding(1)
                )
                .shadow(color: selectedTint.opacity(0.16), radius: 13, y: 6)
                .glassEffect(.regular.tint(Color.white.opacity(0.36)).interactive(), in: .rect(cornerRadius: height / 2 - 3))
                .glassEffectID("prototype-segmented-selection", in: selectionNamespace)
        } else {
            Capsule()
                .fill(Color.white.opacity(0.62))
                .overlay(Capsule().stroke(selectedTint.opacity(0.28), lineWidth: 1))
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
