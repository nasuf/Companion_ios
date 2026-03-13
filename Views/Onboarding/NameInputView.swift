import SwiftUI

struct NameInputView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("给\(viewModel.pronoun)起个名字")
                .font(.largeTitle.bold())

            Text("你可以随时在设置中修改")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("输入名字", text: $viewModel.name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 40)
                .focused($isFocused)
                .onSubmit {
                    createAgent()
                }

            if let error = viewModel.error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            // Preview card
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: viewModel.gender.icon)
                            .foregroundStyle(.purple)
                        Text(viewModel.name.isEmpty ? "..." : viewModel.name)
                            .font(.headline)
                    }
                    ForEach(viewModel.dimensions) { dim in
                        HStack {
                            Text(dim.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ProgressView(value: dim.value)
                                .tint(.purple)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                createAgent()
            } label: {
                Group {
                    if viewModel.isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("创建 AI 伙伴")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(BrandGradient.primary)
                        .opacity(isButtonDisabled ? 0.3 : 1.0)
                )
            }
            .disabled(isButtonDisabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .sensoryFeedback(.success, trigger: appViewModel.agentId)
        }
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
