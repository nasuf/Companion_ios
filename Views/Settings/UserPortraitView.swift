import SwiftUI

struct UserPortraitView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var userPortrait: String?
    @State private var aiPortrait: String?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView()
                } else {
                    // AI Portrait (Life Overview)
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "AI 生活画像"), systemImage: "sparkles")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        if let aiPortrait, !aiPortrait.isEmpty {
                            Text(aiPortrait)
                                .font(.body)
                                .lineSpacing(6)
                                .glassCard(padding: 16)
                        } else {
                            EmptyStateView(
                                icon: "sparkles",
                                title: String(localized: "暂无 AI 画像"),
                                subtitle: String(localized: "AI 正在构建自己的生活方式...")
                            )
                            .glassCard(padding: 20)
                        }
                    }

                    // User Portrait
                    VStack(alignment: .leading, spacing: 12) {
                        Label(String(localized: "用户画像"), systemImage: "person.text.rectangle")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        if let userPortrait, !userPortrait.isEmpty {
                            Text(userPortrait)
                                .font(.body)
                                .lineSpacing(6)
                                .glassCard(padding: 16)
                        } else {
                            EmptyStateView(
                                icon: "person.text.rectangle",
                                title: String(localized: "暂无画像"),
                                subtitle: String(localized: "多和 AI 聊天后会自动生成你的画像")
                            )
                            .glassCard(padding: 20)
                        }
                    }
                }
            }
            .padding(.vertical)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(String(localized: "综合画像"))
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground()
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        guard let agentId = appViewModel.agentId else {
            isLoading = false
            return
        }
        
        isLoading = true
        
        await withTaskGroup(of: Void.self) { group in
            // Load User Portrait
            group.addTask {
                do {
                    let response = try await UserService.getPortrait(
                        userId: appViewModel.userId,
                        agentId: agentId
                    )
                    await MainActor.run { self.userPortrait = response.portrait }
                } catch { }
            }
            
            // Load AI Portrait
            group.addTask {
                do {
                    let agent = try await AgentService.get(id: agentId)
                    await MainActor.run { self.aiPortrait = agent.lifeOverview }
                } catch { }
            }
        }
        
        isLoading = false
    }
}
