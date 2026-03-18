import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var showDeleteAlert = false

    var body: some View {
        @Bindable var app = appViewModel

        List {
            // Theme
            Section {
                Picker(String(localized: "主题"), selection: $app.themeMode) {
                    ForEach(ThemeMode.allCases, id: \.self) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
            } header: {
                Text("外观")
            }

            // Language
            Section {
                Picker(String(localized: "语言"), selection: $app.locale) {
                    ForEach(AppLocale.allCases, id: \.self) { locale in
                        Text(locale.label).tag(locale)
                    }
                }
            } header: {
                Text("语言")
            }

            // Agent info
            if let agentName = appViewModel.agentName {
                Section {
                    HStack {
                        Text(String(localized: "名字"))
                        Spacer()
                        Text(agentName)
                            .foregroundStyle(.secondary)
                    }
                    if let agentId = appViewModel.agentId {
                        HStack {
                            Text("ID")
                            Spacer()
                            Text(agentId.prefix(8) + "...")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("清空所有数据")
                        }
                    }
                } header: {
                    Text("AI 伙伴")
                }
            }

            // About
            Section {
                HStack {
                    Text(String(localized: "版本"))
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("关于")
            }
        }
        .navigationTitle(String(localized: "设置"))
        .alert(String(localized: "确认清空"), isPresented: $showDeleteAlert) {
            Button(String(localized: "取消"), role: .cancel) {}
            Button(String(localized: "清空"), role: .destructive) {
                deleteAgent()
            }
        } message: {
            Text("将彻底清除所有对话记录、记忆、画像及AI相关数据，此操作不可撤销")
        }
    }

    private func deleteAgent() {
        Task {
            await appViewModel.deleteAgent()
        }
    }
}
