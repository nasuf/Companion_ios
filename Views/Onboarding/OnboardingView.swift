import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentStep) {
            GenderSelectionView(viewModel: viewModel)
                .tag(0)

            PersonalitySliderView(viewModel: viewModel)
                .tag(1)

            NameInputView(viewModel: viewModel)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .gradientBackground()
    }
}
