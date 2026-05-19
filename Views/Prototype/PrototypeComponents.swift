import SwiftUI

struct PrototypeScreen<Content: View>: View {
    @Environment(\.prototypePalette) private var palette
    let showsBottomPadding: Bool
    @ViewBuilder var content: () -> Content

    init(showsBottomPadding: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.showsBottomPadding = showsBottomPadding
        self.content = content
    }

    var body: some View {
        ZStack {
            PrototypeBackground()
            content()
                .padding(.bottom, showsBottomPadding ? 92 : 0)
        }
        .foregroundStyle(palette.fg)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct PrototypeBackground: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.62), palette.bg],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(palette.accentSoft.opacity(0.72))
                .frame(width: 260, height: 260)
                .blur(radius: 52)
                .offset(x: 88, y: -88)
        }
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(palette.accent.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 46)
                .offset(x: -92, y: 118)
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

struct PrototypeAvatar: View {
    @Environment(\.prototypePalette) private var palette
    let name: String
    var size: CGFloat = 38

    var body: some View {
        ZStack {
            Circle()
                .fill(.linearGradient(colors: [palette.accentSoft, .white.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
            Text(String(name.prefix(1)))
                .font(.system(size: size * 0.42, weight: .heavy))
                .foregroundStyle(palette.accentInk)
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(palette.hairline, lineWidth: 1))
    }
}

struct PrototypeBottomTabBar: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var selectedTab: PrototypeTab

    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                GlassEffectContainer(spacing: 10) {
                    tabButtons
                }
            } else {
                tabButtons
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .background(Color.white.opacity(0.42))
        .prototypeLiquidGlass(cornerRadius: 30, tint: Color.white.opacity(0.32))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.16), radius: 24, y: 12)
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private var tabButtons: some View {
        HStack {
            ForEach(PrototypeTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                        selectedTab = tab
                    }
                } label: {
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? palette.accentInk : palette.subtle)
                        .frame(width: 46, height: 46)
                        .background(selectedTab == tab ? Color.white.opacity(0.58) : Color.clear)
                        .clipShape(Circle())
                        .prototypeLiquidGlass(
                            cornerRadius: 23,
                            tint: selectedTab == tab ? palette.accentSoft.opacity(0.46) : Color.white.opacity(0.08),
                            interactive: true
                        )
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel(tab.title)
            }
        }
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
