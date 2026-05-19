import SwiftUI

struct PrototypeChatDrawer: View {
    @Environment(\.prototypePalette) private var palette
    let emotionState: EmotionState?
    let intimacy: IntimacyData?
    let boundary: BoundaryStatus?
    let onNavigate: (PrototypeRoute) -> Void

    private let entries: [(title: String, icon: String, color: Color, route: PrototypeRoute)] = [
        ("天气", "sun.max", Color(hex: 0x1F6FFF), .schedule),
        ("胶囊", "capsule", Color(hex: 0x18C6C0), .memory),
        ("遗言", "envelope", Color(hex: 0x7C3CFF), .settings),
        ("成就", "award", Color(hex: 0xFF8A3D), .emotion),
        ("打卡", "checkmark", Color(hex: 0x22C66B), .progress),
        ("商城", "bag", Color(hex: 0xFFBE3D), .settings)
    ]

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 10) {
                ForEach(entries.prefix(5), id: \.title) { entry in
                    drawerButton(entry)
                }
            }
            .padding(8)
            .prototypeLiquidGlass(cornerRadius: 34, tint: Color.white.opacity(0.30))

            drawerButton(entries[5])
                .padding(8)
                .prototypeLiquidGlass(cornerRadius: 30, tint: Color.white.opacity(0.30))

            statusSummary
        }
        .frame(width: 72)
    }

    private func drawerButton(_ entry: (title: String, icon: String, color: Color, route: PrototypeRoute)) -> some View {
        Button {
            onNavigate(entry.route)
        } label: {
            Image(systemName: entry.icon)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(entry.color)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .accessibilityLabel(entry.title)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusSummary: some View {
        if emotionState != nil || intimacy != nil || boundary != nil {
            VStack(spacing: 6) {
                if let emotionState {
                    Text(emotionState.tone)
                }
                if let intimacy {
                    Text(intimacy.level.label)
                }
                if let boundary {
                    Text("\(boundary.patience)")
                }
            }
            .font(.system(size: 9, weight: .heavy))
            .foregroundStyle(palette.muted)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.18))
        }
    }
}
