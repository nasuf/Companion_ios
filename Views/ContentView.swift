import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        Group {
            if !appViewModel.isInitialized {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gradientBackground()
            } else if let conversationId = appViewModel.conversationId,
                      let agentId = appViewModel.agentId {
                NavigationStack {
                    ChatView(conversationId: conversationId, agentId: agentId, userId: appViewModel.userId)
                }
                .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appViewModel.isInitialized)
        .animation(.easeInOut(duration: 0.5), value: appViewModel.agentId)
        .task {
            await appViewModel.initialize()
        }
    }
}
