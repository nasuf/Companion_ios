import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @State private var showDeleteAlert = false

    var body: some View {
        @Bindable var app = appViewModel

        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    header
                    appearanceSection(themeMode: $app.themeMode, locale: $app.locale)
                    agentSection
                    aboutSection
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
        .alert("确认清空", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                deleteAgent()
            }
        } message: {
            Text("将彻底清除所有对话记录、记忆、画像及 AI 相关数据，此操作不可撤销")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "system panel")
            Text("设置")
                .font(.system(size: 33, weight: .heavy))
            Text("通知、语言、外观和当前 agent 数据都在这里集中管理。")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    private func appearanceSection(
        themeMode: Binding<ThemeMode>,
        locale: Binding<AppLocale>
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionHeader(title: "外观与语言", subtitle: "本机偏好")
            PrototypePickerRow(
                icon: "circle.lefthalf.filled",
                title: "主题",
                subtitle: themeMode.wrappedValue.label
            ) {
                Picker("主题", selection: themeMode) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            PrototypePickerRow(
                icon: "character.bubble",
                title: "语言",
                subtitle: locale.wrappedValue.label
            ) {
                Picker("语言", selection: locale) {
                    ForEach(AppLocale.allCases, id: \.self) { locale in
                        Text(locale.label).tag(locale)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
        .padding(.horizontal, 16)
    }

    private var agentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsSectionHeader(title: "AI 伙伴", subtitle: "当前伴生对象")

            if let agentName = appViewModel.agentName {
                SettingsInfoRow(icon: "person.crop.circle", title: "名字", value: agentName)
                if let agentId = appViewModel.agentId {
                    SettingsInfoRow(icon: "number", title: "ID", value: "\(agentId.prefix(8))...")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color(hex: 0xE35B6F))
                            .frame(width: 38, height: 38)
                            .background(Color(hex: 0xE35B6F).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("清空所有数据")
                                .font(.system(size: 14, weight: .heavy))
                            Text("删除对话、记忆、画像及 AI 相关数据")
                                .font(.system(size: 11))
                                .foregroundStyle(palette.muted)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            } else {
                Text("当前没有 agent")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.white.opacity(0.48))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
        .padding(.horizontal, 16)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsSectionHeader(title: "关于", subtitle: "客户端信息")
            SettingsInfoRow(icon: "app.badge", title: "版本", value: "1.0.0")
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
        .padding(.horizontal, 16)
    }

    private func deleteAgent() {
        Task {
            await appViewModel.deleteAgent()
        }
    }
}

private struct SettingsSectionHeader: View {
    @Environment(\.prototypePalette) private var palette
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .heavy))
            Spacer()
            Text(subtitle)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(palette.subtle)
        }
    }
}

private struct PrototypePickerRow<Control: View>: View {
    @Environment(\.prototypePalette) private var palette
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder var control: () -> Control

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                SettingsIcon(symbol: icon)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .heavy))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(palette.muted)
                }
                Spacer()
            }
            control()
        }
        .padding(12)
        .background(Color.white.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SettingsInfoRow: View {
    @Environment(\.prototypePalette) private var palette
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            SettingsIcon(symbol: icon)
            Text(title)
                .font(.system(size: 14, weight: .heavy))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(palette.muted)
        }
        .padding(12)
        .background(Color.white.opacity(0.48))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SettingsIcon: View {
    @Environment(\.prototypePalette) private var palette
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(palette.accent)
            .frame(width: 38, height: 38)
            .background(palette.accentSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
