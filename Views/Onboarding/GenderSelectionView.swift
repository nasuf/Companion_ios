import SwiftUI

struct GenderSelectionView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("选择性别")
                .font(.largeTitle.bold())
                .foregroundStyle(.primary)

            Text("为你的 AI 伙伴选择性别")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    GenderCard(
                        gender: gender,
                        isSelected: viewModel.gender == gender
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.gender = gender
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                withAnimation {
                    viewModel.currentStep = 1
                }
            } label: {
                Text("下一步")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(BrandGradient.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

private struct GenderCard: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: gender.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(isSelected ? .white : .secondary)

                Text(gender.label)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                Group {
                    if isSelected {
                        BrandGradient.primary
                    } else {
                        Color.clear
                    }
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .white.opacity(0.4) : .white.opacity(0.15), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? .purple.opacity(0.4) : .clear, radius: 12)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}
