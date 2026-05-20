import SwiftUI

struct PrototypeChatHeader: View {
    @Environment(\.prototypePalette) private var palette
    let agentName: String
    let status: AgentStatus?
    let onProfile: () -> Void
    let onDrawer: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onProfile) {
                PrototypeAvatar(name: agentName, size: 38)
            }
            .buttonStyle(.prototypeGlassPress)

            VStack(alignment: .leading, spacing: 3) {
                Text(agentName)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(palette.fg)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.linearGradient(colors: [Color(hex: 0xFF4D42), Color(hex: 0xFFC736)], startPoint: .top, endPoint: .bottom))
                    Text("22天")
                    if let status {
                        Text("· \(status.displayStatus)")
                    }
                }
                .font(.system(size: 10.5, weight: .semibold))
                .foregroundStyle(palette.muted)
            }

            Spacer()

            Button(action: onDrawer) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(palette.fg)
                    .frame(width: 36, height: 36)
                    .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.26), interactive: true)
            }
            .buttonStyle(.prototypeGlassProminentPress)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .frame(height: 54)
        .background(Color.white.opacity(0.08))
        .prototypeLiquidGlass(cornerRadius: 0, tint: Color.white.opacity(0.08))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.hairline)
                .frame(height: 1)
        }
    }
}
