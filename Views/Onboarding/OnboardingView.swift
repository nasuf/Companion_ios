import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            PrototypeBackground(style: .onboarding)
            TabView(selection: $viewModel.currentStep) {
                GenderSelectionView(viewModel: viewModel)
                    .tag(0)
                PersonalitySliderView(viewModel: viewModel)
                    .tag(1)
                NameInputView(viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .environment(\.prototypeTheme, .blue)
    }
}

struct OnboardingHero: View {
    @Environment(\.prototypePalette) private var palette
    let kicker: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrototypeKicker(text: kicker)
            Text(title)
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(palette.fg)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            PrototypeFloatingGlassTile(
                size: CGSize(width: 96, height: 88),
                colors: [Color(hex: 0x18C6C0), Color(hex: 0x1F6FFF)],
                opacity: 0.42
            )
            .offset(x: 8, y: -4)
        }
    }
}

struct OnboardingPrimaryButton<Label: View>: View {
    @Environment(\.prototypePalette) private var palette
    let isDisabled: Bool
    let action: () -> Void
    @ViewBuilder var label: () -> Label

    init(isDisabled: Bool = false, _ action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.isDisabled = isDisabled
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action) {
            label()
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(palette.bg)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(palette.fg.opacity(isDisabled ? 0.35 : 1))
                .clipShape(Capsule())
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
}
