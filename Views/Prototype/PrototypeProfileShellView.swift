import SwiftUI

struct PrototypeProfileShellView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @Binding var selectedTheme: PrototypeTheme
    let openRoute: (PrototypeRoute) -> Void
    let resetAgent: () -> Void

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .profile) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    profileStats
                    themePicker
                    settingsList
                }
                .padding(.top, 74)
                .padding(.horizontal, 18)
                .padding(.bottom, 126)
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .topLeading) {
            ProfileFloatingPlate()
                .frame(width: 218, height: 174)
                .rotationEffect(.degrees(12))
                .offset(x: 206, y: -28)

            ProfileFloatingPlate(colors: [Color(hex: 0xFF8A3D), Color(hex: 0x7C3CFF)], opacity: 0.22)
                .frame(width: 156, height: 120)
                .rotationEffect(.degrees(-10))
                .offset(x: -52, y: 202)

            VStack(alignment: .leading, spacing: 13) {
                PrototypeKicker(text: "personal space")
                Text("\(PrototypeFixtures.userName)和\(PrototypeFixtures.agentName)")
                    .font(.system(size: 34, weight: .heavy))
                    .lineSpacing(1)
                    .frame(maxWidth: 286, alignment: .leading)
                Text("我们一起走过的时光，都在这里慢慢沉淀。")
                    .font(.system(size: 13.2, weight: .regular))
                    .lineSpacing(4)
                    .foregroundStyle(Color(hex: 0x182026).opacity(0.58))
                    .frame(maxWidth: 274, alignment: .leading)
            }
            .padding(.top, 54)

            ProfileOrbit()
                .frame(width: 214, height: 146)
                .offset(x: 144, y: 178)
        }
        .frame(maxWidth: .infinity, minHeight: 330, alignment: .topLeading)
    }

    private var profileStats: some View {
        ProfileSection(title: "我们的时光", trailing: "唯一伴生对象 · 女 · ENFP") {
            HStack(spacing: 0) {
                ForEach([("亲密阶段", "P4", "稳定陪伴"), ("陪伴天数", "126", "天"), ("累计聊天", "48", "小时"), ("消息总数", "3,284", "条")], id: \.0) { stat in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(stat.0)
                            .font(.system(size: 10, weight: .bold))
                            .lineLimit(2)
                            .foregroundStyle(palette.muted)
                            .frame(height: 27, alignment: .topLeading)
                        Text(stat.1)
                            .font(.system(size: 21, weight: .heavy))
                            .foregroundStyle(palette.accentInk)
                            .monospacedDigit()
                        Text(stat.2)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: 0x182026).opacity(0.44))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, stat.0 == "亲密阶段" ? 2 : 10)
                    .overlay(alignment: .leading) {
                        if stat.0 != "亲密阶段" {
                            Rectangle()
                                .fill(Color.black.opacity(0.08))
                                .frame(width: 1)
                        }
                    }
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 4)
        }
    }

    private var themePicker: some View {
        ProfileSection(title: "界面风格", trailing: selectedTheme.name) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PrototypeTheme.allCases) { theme in
                        Button {
                            withAnimation(.spring(response: 0.30, dampingFraction: 0.80)) {
                                selectedTheme = theme
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(theme.palette.accent)
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(Color.white.opacity(0.76), lineWidth: 1))
                                Text(theme.name)
                                    .font(.system(size: 10, weight: .heavy))
                                if selectedTheme == theme {
                                    Capsule()
                                        .fill(theme.palette.accent)
                                        .frame(width: 12, height: 2)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .foregroundStyle(selectedTheme == theme ? palette.fg : Color(hex: 0x182026).opacity(0.52))
                            .frame(height: 30)
                            .padding(.horizontal, 8)
                            .background(selectedTheme == theme ? Color.white.opacity(0.36) : Color.clear)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.prototypeGlassPress)
                    }
                }
            }
            .padding(.top, 9)
        }
    }

    private var settingsList: some View {
        ProfileSection(title: "系统设置", trailing: "通知、隐私、订阅和数据") {
            VStack(spacing: 0) {
                ForEach(settingRows, id: \.title) { row in
                    Button {
                        if let route = row.route {
                            openRoute(route)
                        }
                    } label: {
                        ProfileSettingRow(row: row)
                    }
                    .buttonStyle(.prototypeGlassPress)
                }

                Button(role: .destructive, action: resetAgent) {
                    ProfileSettingRow(
                        row: ProfileSetting(
                            title: appViewModel.isDeletingAgent ? "正在删除 agent" : "删除当前 agent",
                            subtitle: appViewModel.isDeletingAgent ? "正在清理对话、记忆、画像和触发器" : "删除后才可以重新创建新的伴生对象",
                            symbol: appViewModel.isDeletingAgent ? "hourglass" : "archivebox",
                            accent: Color(hex: 0xE35B6F),
                            route: nil,
                            isDanger: true
                        )
                    )
                }
                .disabled(appViewModel.isDeletingAgent)
                .buttonStyle(.prototypeGlassPress)
            }
            .padding(.top, 2)
        }
    }

    private var settingRows: [ProfileSetting] {
        [
            ProfileSetting(title: "通知提醒", subtitle: "主动消息、任务提醒、免打扰时段", symbol: "bell", accent: Color(hex: 0x1F6FFF), route: .settings),
            ProfileSetting(title: "隐私与安全", subtitle: "本机加密、登录设备、敏感内容保护", symbol: "lock.shield", accent: Color(hex: 0x18C6C0), route: .settings),
            ProfileSetting(title: "记忆", subtitle: "查看 L1 / L2 / L3 记忆", symbol: "brain.head.profile", accent: Color(hex: 0x7C3CFF), route: .memory),
            ProfileSetting(title: "情绪轨迹", subtitle: "查看情绪状态与 PAD 曲线", symbol: "heart.text.square", accent: Color(hex: 0x22C66B), route: .emotion),
            ProfileSetting(title: "作息", subtitle: "查看生活画像和每日作息", symbol: "calendar.badge.clock", accent: Color(hex: 0xFF8A3D), route: .schedule)
        ]
    }
}

private struct ProfileSection<Content: View>: View {
    @Environment(\.prototypePalette) private var palette
    let title: String
    let trailing: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 12) {
                Text(title)
                    .font(.system(size: 17, weight: .heavy))
                Spacer()
                Text(trailing)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(palette.muted)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.08))
                    .frame(height: 1)
            }

            content()
        }
    }
}

private struct ProfileOrbit: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 68, y: 90))
                path.addQuadCurve(to: CGPoint(x: 150, y: 48), control: CGPoint(x: 96, y: 50))
            }
            .stroke(Color(hex: 0x1F6FFF).opacity(0.26), lineWidth: 1.5)
            .rotationEffect(.degrees(-18))

            ForEach([
                CGPoint(x: 58, y: 78),
                CGPoint(x: 104, y: 62),
                CGPoint(x: 146, y: 45)
            ], id: \.x) { point in
                Circle()
                    .fill(point.x == 104 ? Color(hex: 0xFFBE3D) : point.x == 146 ? Color(hex: 0x7C3CFF) : Color(hex: 0x18C6C0))
                    .frame(width: 8, height: 8)
                    .shadow(color: Color(hex: 0x18C6C0).opacity(0.30), radius: 10)
                    .position(point)
            }

            VStack(spacing: 7) {
                PrototypeAssetImage(name: "user-avatar-shanmu.jpg")
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.82), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.12), radius: 22, y: 12)
                Text(PrototypeFixtures.userName)
                    .profileOrbitLabel()
            }
            .position(x: 48, y: 98)

            VStack(spacing: 7) {
                PrototypeAvatar(name: PrototypeFixtures.agentName, size: 82)
                Text(PrototypeFixtures.agentName)
                    .profileOrbitLabel()
            }
            .position(x: 168, y: 48)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct ProfileFloatingPlate: View {
    var colors: [Color] = [Color(hex: 0x1F6FFF), Color(hex: 0x18C6C0)]
    var opacity: Double = 0.56

    var body: some View {
        RoundedRectangle(cornerRadius: 58, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colors.map { $0.opacity(opacity) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(Color.white.opacity(0.58))
                    .frame(width: 58, height: 58)
                    .blur(radius: 2)
                    .offset(x: 48, y: 22)
            }
            .blur(radius: 0.2)
    }
}

private struct ProfileSetting {
    let title: String
    let subtitle: String
    let symbol: String
    let accent: Color
    let route: PrototypeRoute?
    var isDanger = false
}

private struct ProfileSettingRow: View {
    let row: ProfileSetting

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: row.symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(row.accent)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(row.title)
                    .font(.system(size: 14.5, weight: .bold))
                    .foregroundStyle(row.isDanger ? Color(hex: 0xE35B6F) : Color(hex: 0x12171B))
                Text(row.subtitle)
                    .font(.system(size: 11.2, weight: .regular))
                    .lineSpacing(2)
                    .foregroundStyle(Color(hex: 0x182026).opacity(0.56))
            }

            Spacer()

            Text("›")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(row.isDanger ? Color(hex: 0xE35B6F) : Color(hex: 0x182026).opacity(0.32))
        }
        .frame(minHeight: 68)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.08))
                .frame(height: 1)
        }
    }
}

private extension View {
    func profileOrbitLabel() -> some View {
        self
            .font(.system(size: 10.5, weight: .heavy))
            .foregroundStyle(Color(hex: 0x12171B).opacity(0.68))
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color.white.opacity(0.68))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
    }
}
