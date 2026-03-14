import SwiftUI

struct UserPortraitView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var portrait: String?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if let portrait, !portrait.isEmpty {
                Text(portrait)
                    .font(.body)
                    .lineSpacing(6)
                    .glassCard()
                    .padding()
            } else {
                EmptyStateView(
                    icon: "person.text.rectangle",
                    title: String(localized: "暂无画像"),
                    subtitle: String(localized: "多和 AI 聊天后会自动生成你的画像")
                )
                .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .navigationTitle(String(localized: "用户画像"))
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground()
        .task {
            await loadPortrait()
        }
    }

    private func loadPortrait() async {
        guard let agentId = appViewModel.agentId else {
            isLoading = false
            return
        }
        do {
            let response = try await UserService.getPortrait(
                userId: appViewModel.userId,
                agentId: agentId
            )
            portrait = response.portrait
        } catch {
            // 404 means no portrait yet, treat as empty
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
