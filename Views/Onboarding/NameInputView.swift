import SwiftUI

struct NameInputView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.prototypePalette) private var palette
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                OnboardingHero(
                    kicker: "LET STORY BEGIN",
                    title: "给\(viewModel.pronoun)起个名字",
                    subtitle: "最后一步会创建 TA 的身份、经历和初始记忆，完成后自动进入对话。"
                )
                .padding(.top, 64)

                TextField("输入名字", text: $viewModel.name)
                    .font(.system(size: 24, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                    .frame(height: 66)
                    .background(Color.white.opacity(0.60))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .prototypeLiquidGlass(cornerRadius: 24, tint: Color.white.opacity(0.24), interactive: true)
                    .focused($isFocused)
                    .onSubmit(createAgent)

                if let error = viewModel.error {
                    Text(error)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0xE35B6F))
                }

                previewCard

                OnboardingPrimaryButton(isDisabled: isButtonDisabled, createAgent) {
                    if viewModel.isCreating {
                        ProgressView()
                            .tint(palette.bg)
                    } else {
                        Text("让故事开始")
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 36)
            }
            .padding(.horizontal, 22)
        }
        .sensoryFeedback(.success, trigger: appViewModel.agentId)
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.gender.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(palette.accent)
                    .frame(width: 48, height: 48)
                    .background(palette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.name.isEmpty ? "未命名" : viewModel.name)
                        .font(.system(size: 22, weight: .heavy))
                    Text("唯一伴生对象 · \(viewModel.gender.label)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(palette.muted)
                }
            }

            ForEach(viewModel.dimensions) { dimension in
                HStack(spacing: 10) {
                    Text(dimension.name)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(palette.muted)
                        .frame(width: 58, alignment: .leading)
                    GeometryReader { proxy in
                        Capsule()
                            .fill(palette.hairline)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(palette.accent)
                                    .frame(width: max(8, proxy.size.width * dimension.value))
                            }
                    }
                    .frame(height: 7)
                }
            }
        }
        .prototypeCard(cornerRadius: 28, padding: 16)
    }

    private var isButtonDisabled: Bool {
        viewModel.isCreating || viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func createAgent() {
        isFocused = false
        Task {
            await viewModel.createAgent(appViewModel: appViewModel)
        }
    }
}
