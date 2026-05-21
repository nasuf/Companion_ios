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
            nativeTabView
                .tint(CreationPalette.blue)
            .environment(\.prototypeTheme, theme)
            .navigationDestination(for: PrototypeRoute.self) { route in
                PrototypeRouteView(route: route)
                    .environment(\.prototypeTheme, theme)
            }
        }
    }

    @ViewBuilder
    private var nativeTabView: some View {
        TabView(selection: $selectedTab) {
            ChatView(
                conversationId: conversationId,
                agentId: agentId,
                userId: userId,
                openRoute: openRoute
            )
            .tag(PrototypeTab.chat)
            .tabItem { tabLabel(.chat) }

            PrototypeOnlineHubView(openRoute: openRoute)
                .tag(PrototypeTab.online)
                .tabItem { tabLabel(.online) }

            PrototypeSceneHubView(openRoute: openRoute)
                .tag(PrototypeTab.scene)
                .tabItem { tabLabel(.scene) }

            PrototypeProfileShellView(
                selectedTheme: $theme,
                openRoute: openRoute,
                resetAgent: resetAgent
            )
            .tag(PrototypeTab.profile)
            .tabItem { tabLabel(.profile) }
        }
    }

    private func tabLabel(_ tab: PrototypeTab) -> some View {
        Label(tab.title, systemImage: tab.icon)
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
