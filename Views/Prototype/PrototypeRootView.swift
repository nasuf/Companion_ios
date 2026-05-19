import SwiftUI

struct PrototypeRootView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var selectedTab: PrototypeTab = .chat
    @State private var theme: PrototypeTheme = .blue
    @State private var path: [PrototypeRoute] = []

    let conversationId: String
    let agentId: String
    let userId: String

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                activeTabView

                PrototypeBottomTabBar(selectedTab: $selectedTab)
            }
            .environment(\.prototypeTheme, theme)
            .navigationDestination(for: PrototypeRoute.self) { route in
                PrototypeRouteView(route: route)
                    .environment(\.prototypeTheme, theme)
            }
        }
    }

    @ViewBuilder
    private var activeTabView: some View {
        switch selectedTab {
        case .chat:
            ChatView(conversationId: conversationId, agentId: agentId, userId: userId)
        case .online:
            PrototypeOnlineHubView(openRoute: openRoute)
        case .scene:
            PrototypeSceneHubView(openRoute: openRoute)
        case .profile:
            PrototypeProfileShellView(
                selectedTheme: $theme,
                openRoute: openRoute,
                resetAgent: resetAgent
            )
        }
    }

    private func openRoute(_ route: PrototypeRoute) {
        path.append(route)
    }

    private func resetAgent() {
        Task {
            await appViewModel.deleteAgent()
        }
    }
}
