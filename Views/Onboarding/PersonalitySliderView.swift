import SwiftUI

struct PersonalitySliderView: View {
    @Environment(\.prototypePalette) private var palette
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                OnboardingHero(
                    kicker: "SOUL PROFILE",
                    title: "灵魂印记",
                    subtitle: "设定你的轮廓，让同频的 TA 找到你。每一笔都会进入真实创建接口。"
                )
                .padding(.top, 54)

                traitMap

                Button {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.randomizeAll()
                    }
                } label: {
                    Label("随机生成", systemImage: "dice")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(palette.accentInk)
                        .padding(.horizontal, 14)
                        .frame(height: 38)
                        .background(Color.white.opacity(0.62))
                        .clipShape(Capsule())
                        .prototypeLiquidGlass(cornerRadius: 19, tint: Color.white.opacity(0.20), interactive: true)
                }
                .buttonStyle(.plain)

                VStack(spacing: 10) {
                    ForEach($viewModel.dimensions) { $dimension in
                        PrototypeDimensionSlider(dimension: $dimension)
                    }
                }

                OnboardingPrimaryButton {
                    withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                        viewModel.currentStep = 2
                    }
                } label: {
                    Text("下一步")
                }
                .padding(.top, 4)
                .padding(.bottom, 36)
            }
            .padding(.horizontal, 22)
        }
    }

    private var traitMap: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.linearGradient(colors: [palette.accentSoft.opacity(0.88), Color.white.opacity(0.52)], startPoint: .topLeading, endPoint: .bottomTrailing))

                Path { path in
                    for index in viewModel.dimensions.indices {
                        let x = proxy.size.width * (0.12 + Double(index) * 0.12)
                        let y = proxy.size.height * (0.86 - viewModel.dimensions[index].value * 0.64)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(palette.accent, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                ForEach(Array(viewModel.dimensions.enumerated()), id: \.element.id) { index, dimension in
                    Circle()
                        .fill(Self.colors[index % Self.colors.count])
                        .frame(width: 15, height: 15)
                        .position(
                            x: proxy.size.width * (0.12 + Double(index) * 0.12),
                            y: proxy.size.height * (0.86 - dimension.value * 0.64)
                        )
                }
            }
        }
        .frame(height: 156)
        .prototypeLiquidGlass(cornerRadius: 28, tint: Color.white.opacity(0.22))
    }

    private static let colors = [
        Color(hex: 0x18C6C0),
        Color(hex: 0x1F6FFF),
        Color(hex: 0x7C3CFF),
        Color(hex: 0xFF6A3D),
        Color(hex: 0x22C66B),
        Color(hex: 0xFFC936),
        Color(hex: 0xE35B6F)
    ]
}

private struct PrototypeDimensionSlider: View {
    @Environment(\.prototypePalette) private var palette
    @Binding var dimension: PersonalityDimension

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dimension.name)
                    .font(.system(size: 14, weight: .heavy))
                Spacer()
                Text("\(Int(dimension.value * 100))")
                    .font(.system(size: 12, weight: .heavy, design: .monospaced))
                    .foregroundStyle(palette.accent)
            }
            Slider(value: $dimension.value, in: 0...1, step: 0.01)
                .tint(palette.accent)
            HStack {
                Text(dimension.lowLabel)
                Spacer()
                Text(dimension.highLabel)
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(palette.subtle)
        }
        .padding(13)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 18, tint: Color.white.opacity(0.18), interactive: true)
    }
}
