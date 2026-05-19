import SwiftUI

struct UserPortraitView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var userPortrait: String?
    @State private var aiPortrait: String?
    @State private var isLoading = true

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    header
                    content
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .refreshable { await loadData() }
        }
        .task { await loadData() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "portrait map")
            Text("综合画像")
                .font(.system(size: 33, weight: .heavy))
            Text("这里把关于你和小芜自己的画像分开呈现，避免记忆混在一起。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            PortraitLoadingPanel()
                .padding(.horizontal, 16)
        } else {
            VStack(spacing: 16) {
                PortraitCard(
                    kicker: "AI LIFE",
                    title: "AI 生活画像",
                    icon: "sparkles",
                    text: aiPortrait,
                    emptyTitle: "暂无 AI 画像",
                    emptySubtitle: "AI 正在构建自己的生活方式..."
                )
                PortraitCard(
                    kicker: "USER PROFILE",
                    title: "用户画像",
                    icon: "person.text.rectangle",
                    text: userPortrait,
                    emptyTitle: "暂无画像",
                    emptySubtitle: "多和 AI 聊天后会自动生成你的画像"
                )
            }
            .padding(.horizontal, 16)
        }
    }

    private func loadData() async {
        guard let agentId = appViewModel.agentId else {
            isLoading = false
            return
        }

        isLoading = true

        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                do {
                    let response = try await UserService.getPortrait(
                        userId: appViewModel.userId,
                        agentId: agentId
                    )
                    await MainActor.run { self.userPortrait = response.portrait }
                } catch { }
            }

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

private struct PortraitCard: View {
    @Environment(\.prototypePalette) private var palette
    let kicker: String
    let title: String
    let icon: String
    let text: String?
    let emptyTitle: String
    let emptySubtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(kicker)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(palette.accent)
                    Text(title)
                        .font(.system(size: 22, weight: .heavy))
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 48, height: 48)
                    .background(palette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if let text, !text.isEmpty {
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.muted)
                    .lineSpacing(5)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text(emptyTitle)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(palette.fg)
                    Text(emptySubtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(palette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.white.opacity(0.48))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 17)
    }
}

private struct PortraitLoadingPanel: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("正在读取画像")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 170)
        .prototypeCard(cornerRadius: 26, padding: 16)
    }
}
