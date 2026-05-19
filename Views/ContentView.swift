import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        Group {
            if !appViewModel.isInitialized {
                ZStack {
                    PrototypeBackground(style: .onboarding)
                    ProgressView()
                        .scaleEffect(1.25)
                }
                .environment(\.prototypeTheme, .blue)
            } else if appViewModel.isProvisioningAgent, appViewModel.agentId != nil {
                AgentProvisioningView()
                    .transition(.opacity)
            } else if let conversationId = appViewModel.conversationId,
                      let agentId = appViewModel.agentId {
                PrototypeRootView(
                    conversationId: conversationId,
                    agentId: agentId,
                    userId: appViewModel.userId
                )
                .id("\(agentId):\(conversationId)")
                .transition(.opacity)
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appViewModel.isInitialized)
        .animation(.easeInOut(duration: 0.5), value: appViewModel.agentId)
        .animation(.easeInOut(duration: 0.5), value: appViewModel.isProvisioningAgent)
        .task {
            await appViewModel.initialize()
        }
    }
}
