import SwiftUI

struct PrototypeChatHeader: View {
    @Environment(\.prototypePalette) private var palette
    let agentName: String
    let status: AgentStatus?
    let onProfile: () -> Void
    let onDrawer: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onProfile) {
                PrototypeAvatar(name: agentName, size: 48)
            }
            .buttonStyle(.prototypeGlassPress)

            VStack(alignment: .leading, spacing: 5) {
                Text(agentName)
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(palette.fg)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.linearGradient(colors: [Color(hex: 0xFF4D42), Color(hex: 0xFFC736)], startPoint: .top, endPoint: .bottom))
                    Text("22天")
                }
                .font(.system(size: 13.5, weight: .heavy))
                .foregroundStyle(Color(hex: 0xFF6A24))
            }

            Spacer()

            Button(action: onDrawer) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(palette.fg)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.90))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(palette.hairline, lineWidth: 1))
            }
            .buttonStyle(.prototypeGlassProminentPress)
        }
        .padding(.horizontal, 26)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .frame(height: 88)
        .background(Color.white.opacity(0.94).ignoresSafeArea(edges: .top))
    }
}
