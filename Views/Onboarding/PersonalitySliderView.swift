import SwiftUI

struct PersonalitySliderView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("个性塑造")
                    .font(.largeTitle.bold())
                    .padding(.top, 20)

                Text("调整滑块定义 AI 的性格")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Randomize all button
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.randomizeAll()
                    }
                } label: {
                    Label("全部随机", systemImage: "dice")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }

                VStack(spacing: 4) {
                    ForEach($viewModel.dimensions) { $dim in
                        CompactDimensionSlider(dimension: $dim)
                    }
                }
                .padding(.horizontal)

                Button {
                    withAnimation {
                        viewModel.currentStep = 2
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
}

private struct CompactDimensionSlider: View {
    @Binding var dimension: PersonalityDimension

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(dimension.lowLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 56, alignment: .leading)

                Slider(value: $dimension.value, in: 0...1, step: 0.01)
                    .tint(.purple)

                Text(dimension.highLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(width: 56, alignment: .trailing)

                // Per-dimension random button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dimension.value = Double.random(in: 0...1)
                    }
                } label: {
                    Image(systemName: "dice")
                        .font(.caption)
                        .foregroundStyle(.purple.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            Text(dimension.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
