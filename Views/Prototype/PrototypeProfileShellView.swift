import SwiftUI

struct PrototypeProfileShellView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @Binding var selectedTheme: PrototypeTheme
    let openRoute: (PrototypeRoute) -> Void
    let resetAgent: () -> Void

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .onboarding) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    hero
                    profileStats
                    themePicker
                    settingsList
                }
                .padding(.top, 74)
                .padding(.horizontal, 16)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 18) {
            PrototypeKicker(text: "personal space")
                .foregroundStyle(.white.opacity(0.72))
            Text("\(PrototypeFixtures.userName)和\(PrototypeFixtures.agentName)")
                .font(.system(size: 28, weight: .heavy))
            Text("我们一起走过的时光，都在这里慢慢沉淀。")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.72))
            HStack {
                ProfilePerson(name: PrototypeFixtures.userName, image: "user-avatar-shanmu.jpg")
                Spacer()
                Image(systemName: "link")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white.opacity(0.72))
                Spacer()
                ProfilePerson(name: PrototypeFixtures.agentName, image: "agent-avatar.svg")
            }
        }
        .foregroundStyle(.white)
        .padding(18)
        .background(.linearGradient(colors: [palette.accentInk, palette.accent], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: palette.accent.opacity(0.24), radius: 26, y: 16)
    }

    private var profileStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("我们的时光").font(.system(size: 16, weight: .heavy))
                Spacer()
                Text("唯一伴生对象 · 女 · ENFP")
                    .font(.system(size: 10))
                    .foregroundStyle(palette.muted)
            }
            HStack {
                ForEach([("亲密阶段", "P4", "稳定陪伴"), ("陪伴天数", "126", "天"), ("累计聊天", "48", "小时"), ("消息总数", "3,284", "条")], id: \.0) { stat in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stat.0).font(.system(size: 9)).foregroundStyle(palette.subtle)
                        Text(stat.1).font(.system(size: 19, weight: .heavy))
                        Text(stat.2).font(.system(size: 9)).foregroundStyle(palette.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .prototypeCard(cornerRadius: 22, padding: 15)
    }

    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("界面风格").font(.system(size: 16, weight: .heavy))
                Spacer()
                Text(selectedTheme.name).font(.system(size: 11)).foregroundStyle(palette.muted)
            }
            HStack(spacing: 8) {
                ForEach(PrototypeTheme.allCases) { theme in
                    Button {
                        selectedTheme = theme
                    } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(theme.palette.accent)
                                .frame(width: 16, height: 16)
                            Text(theme.name)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(palette.muted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedTheme == theme ? theme.palette.accentSoft : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .prototypeCard(cornerRadius: 22, padding: 15)
    }

    private var settingsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("系统设置").font(.system(size: 16, weight: .heavy))
            ForEach([
                ("通知提醒", "主动消息、任务提醒、免打扰时段", "bell", PrototypeRoute.settings),
                ("隐私与安全", "本机加密、登录设备、敏感内容保护", "lock.shield", PrototypeRoute.settings),
                ("记忆", "查看 L1 / L2 / L3 记忆", "brain.head.profile", PrototypeRoute.memory),
                ("情绪轨迹", "查看情绪状态与 PAD 曲线", "heart.text.square", PrototypeRoute.emotion),
                ("作息", "查看生活画像和每日作息", "calendar.badge.clock", PrototypeRoute.schedule)
            ], id: \.0) { row in
                Button {
                    openRoute(row.3)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: row.2)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(palette.accent)
                            .frame(width: 34, height: 34)
                            .background(palette.accentSoft)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text(row.0).font(.system(size: 14, weight: .bold))
                            Text(row.1).font(.system(size: 10)).foregroundStyle(palette.muted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(palette.subtle)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }

            Button(role: .destructive, action: resetAgent) {
                HStack {
                    Image(systemName: appViewModel.isDeletingAgent ? "hourglass" : "archivebox")
                    VStack(alignment: .leading) {
                        Text(appViewModel.isDeletingAgent ? "正在删除 agent" : "删除当前 agent")
                            .font(.system(size: 14, weight: .bold))
                        Text(appViewModel.isDeletingAgent ? "正在清理对话、记忆、画像和触发器" : "删除后才可以重新创建新的伴生对象")
                            .font(.system(size: 10))
                    }
                    Spacer()
                }
            }
            .disabled(appViewModel.isDeletingAgent)
            .padding(.top, 8)
        }
        .prototypeCard(cornerRadius: 22, padding: 15)
    }
}

private struct ProfilePerson: View {
    let name: String
    let image: String

    var body: some View {
        VStack(spacing: 6) {
            PrototypeAssetImage(name: image)
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            Text(name)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.75))
        }
    }
}
