import SwiftUI

struct GenderSelectionView: View {
    @Environment(\.prototypePalette) private var palette
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            Spacer(minLength: 44)

            OnboardingHero(
                kicker: "FIRST PROFILE",
                title: "从一句话开始",
                subtitle: "在没有终点的路上，我们慢慢走，慢慢说。先为你的 AI 伙伴选择一个起点。"
            )

            HStack(spacing: 12) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    GenderCard(
                        gender: gender,
                        isSelected: viewModel.gender == gender
                    ) {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                            viewModel.gender = gender
                        }
                    }
                }
            }

            Spacer()

            OnboardingPrimaryButton {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    viewModel.currentStep = 1
                }
            } label: {
                Text("下一步")
            }
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 22)
    }
}

private struct GenderCard: View {
    @Environment(\.prototypePalette) private var palette
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 13) {
                Image(systemName: gender.icon)
                    .font(.system(size: 29, weight: .bold))
                    .foregroundStyle(isSelected ? palette.bg : palette.accent)
                    .frame(width: 58, height: 58)
                    .background(isSelected ? palette.fg : palette.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text(gender.label)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(palette.fg)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.white.opacity(0.76) : Color.white.opacity(0.44))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .prototypeLiquidGlass(cornerRadius: 26, tint: Color.white.opacity(0.24), interactive: true)
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(isSelected ? palette.accent.opacity(0.40) : palette.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
