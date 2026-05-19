import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            PrototypeBackground(style: .onboarding)
            CreateAgentFormView(viewModel: viewModel)
        }
        .environment(\.prototypeTheme, .blue)
    }
}

struct CreateAgentFormView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Bindable var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                OnboardingHero(
                    kicker: "FIRST PROFILE",
                    title: "没有偶然的相遇\n只有灵魂与灵魂的呼应",
                    subtitle: "在这里，你设定的每一笔，都是找寻的起点"
                )
                .padding(.top, 34)
                .padding(.bottom, 22)

                soulProfileIntro
                    .padding(.bottom, 8)

                basicFields

                traitStudio
                    .padding(.top, 20)

                if let error = viewModel.error {
                    Text(error)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0xE35B6F))
                        .padding(.top, 12)
                }

                OnboardingPrimaryButton(isDisabled: isButtonDisabled, createAgent) {
                    if viewModel.isCreating {
                        ProgressView()
                            .tint(Color.white)
                    } else {
                        Text("让故事开始")
                    }
                }
                .padding(.top, 22)
                .padding(.bottom, 36)
            }
            .padding(.horizontal, 22)
            .padding(.top, 34)
        }
        .sensoryFeedback(.success, trigger: appViewModel.agentId)
    }

    private var soulProfileIntro: some View {
        VStack(alignment: .leading, spacing: 7) {
            PrototypeKicker(text: "SOUL PROFILE")
            Text("灵魂印记")
                .font(.system(size: 23, weight: .heavy))
                .foregroundStyle(CreationPalette.fg)
            Text("设定你的轮廓，让同频的TA找到你")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(CreationPalette.body)
        }
        .padding(.horizontal, 4)
    }

    private var basicFields: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Text("名字")
                    .creationFieldLabel()
                TextField(
                    "",
                    text: $viewModel.name,
                    prompt: Text("输入名字").foregroundStyle(CreationPalette.subtle)
                )
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(CreationPalette.fg)
                    .focused($isFocused)
                    .onSubmit(createAgent)
            }
            .frame(minHeight: 54)
            .overlay(alignment: .bottom) {
                CreationDivider()
            }

            HStack(spacing: 14) {
                Text("性别")
                    .creationFieldLabel()
                GenderSegmentedPicker(selection: $viewModel.gender)
            }
            .frame(minHeight: 54)
            .overlay(alignment: .bottom) {
                CreationDivider()
            }
        }
        .padding(.horizontal, 4)
    }

    private var traitStudio: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("灵魂倾向")
                    .creationFieldLabel()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        viewModel.randomizeAll()
                    }
                } label: {
                    Text("随机生成")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(CreationPalette.actionInk)
                        .padding(.horizontal, 13)
                        .frame(height: 32)
                        .background(CreationPalette.actionSoft.opacity(0.86))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(CreationPalette.action.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .frame(minHeight: 54)

            CreationTraitMap(dimensions: viewModel.dimensions)
                .frame(height: 138)
                .padding(.top, 2)

            VStack(spacing: 0) {
                ForEach(viewModel.dimensions.indices, id: \.self) { index in
                    CreationDimensionRow(
                        dimension: $viewModel.dimensions[index],
                        accent: CreationPalette.traitColors[index % CreationPalette.traitColors.count],
                        isFirst: index == viewModel.dimensions.startIndex,
                        isLast: index == viewModel.dimensions.index(before: viewModel.dimensions.endIndex)
                    )
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.horizontal, 4)
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

private struct GenderSegmentedPicker: View {
    @Binding var selection: Gender
    @Namespace private var selectionNamespace

    var body: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 3
            let spacing: CGFloat = 3
            let width = max(0, (proxy.size.width - padding * 2 - spacing * 2) / CGFloat(Gender.allCases.count))

            ZStack(alignment: .leading) {
                glassLayer(width: width, padding: padding, spacing: spacing)

                segmentButtons
                    .padding(padding)
            }
        }
        .frame(height: 38)
        .animation(.spring(response: 0.34, dampingFraction: 0.78), value: selection)
    }

    private var segmentButtons: some View {
        HStack(spacing: 3) {
            ForEach(Gender.allCases, id: \.self) { gender in
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        selection = gender
                    }
                } label: {
                    Text(gender.label)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(selection == gender ? CreationPalette.actionInk : CreationPalette.body)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var selectionIndex: Int {
        Gender.allCases.firstIndex(of: selection) ?? 0
    }

    @ViewBuilder
    private func glassLayer(width: CGFloat, padding: CGFloat, spacing: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: 8) {
                ZStack(alignment: .leading) {
                    track

                    selectedPill
                        .frame(width: width, height: 32)
                        .offset(x: padding + CGFloat(selectionIndex) * (width + spacing))
                }
            }
        } else {
            ZStack(alignment: .leading) {
                track

                selectedPill
                    .frame(width: width, height: 32)
                    .offset(x: padding + CGFloat(selectionIndex) * (width + spacing))
            }
        }
    }

    @ViewBuilder
    private var track: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(Color.white.opacity(0.08))
                .glassEffect(.regular.tint(Color.white.opacity(0.28)).interactive(), in: .rect(cornerRadius: 19))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.60), lineWidth: 1)
                )
        } else {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.white.opacity(0.52), lineWidth: 1))
        }
    }

    @ViewBuilder
    private var selectedPill: some View {
        if #available(iOS 26.0, *) {
            Capsule()
                .fill(CreationPalette.actionSoft.opacity(0.36))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.72), lineWidth: 1)
                )
                .shadow(color: CreationPalette.action.opacity(0.10), radius: 10, y: 4)
                .glassEffect(.regular.tint(CreationPalette.actionSoft.opacity(0.62)).interactive(), in: .rect(cornerRadius: 16))
                .glassEffectID("gender-selection-pill", in: selectionNamespace)
        } else {
            Capsule()
                .fill(CreationPalette.actionSoft.opacity(0.62))
        }
    }
}

private struct CreationTraitMap: View {
    let dimensions: [PersonalityDimension]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                CreationTraitGrid()
                    .opacity(0.92)

                Path { path in
                    let midY = proxy.size.height * 0.50
                    path.move(to: CGPoint(x: 28, y: midY))
                    path.addLine(to: CGPoint(x: proxy.size.width - 28, y: midY))
                }
                .stroke(CreationPalette.fg.opacity(0.12), lineWidth: 1)

                ForEach(Array(dimensions.enumerated()), id: \.element.id) { index, dimension in
                    Circle()
                        .fill(CreationPalette.traitColors[index % CreationPalette.traitColors.count])
                        .frame(width: 13, height: 13)
                        .position(
                            x: proxy.size.width * (0.18 + Double(index) * 0.105),
                            y: proxy.size.height * (0.10 + (1 - dimension.value) * 0.80)
                        )
                        .shadow(color: CreationPalette.traitColors[index % CreationPalette.traitColors.count].opacity(0.22), radius: 14, y: 8)
                }
            }
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.10),
                    .init(color: .black, location: 0.90),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

private struct CreationTraitGrid: View {
    var body: some View {
        Canvas { context, size in
            let grid = Color(hex: 0x15181C).opacity(0.045)
            var path = Path()
            let xStep: CGFloat = 34
            let yStep: CGFloat = 34
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += xStep
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += yStep
            }
            context.stroke(path, with: .color(grid), lineWidth: 1)

            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.62, y: -10, width: 190, height: 118)),
                with: .color(CreationPalette.blue.opacity(0.10))
            )
            context.fill(
                Path(ellipseIn: CGRect(x: size.width * 0.04, y: size.height * 0.54, width: 170, height: 110)),
                with: .color(CreationPalette.accent.opacity(0.10))
            )
        }
    }
}

private struct CreationDimensionRow: View {
    @Binding var dimension: PersonalityDimension
    let accent: Color
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 9) {
            Circle()
                .fill(accent)
                .frame(width: 8, height: 8)
                .shadow(color: accent.opacity(0.18), radius: 12, y: 6)
                .overlay(alignment: .top) {
                    if !isFirst {
                        Rectangle()
                            .fill(.linearGradient(colors: [.clear, accent.opacity(0.28)], startPoint: .top, endPoint: .bottom))
                            .frame(width: 1, height: 30)
                            .offset(y: -31)
                    }
                }
                .overlay(alignment: .bottom) {
                    if !isLast {
                        Rectangle()
                            .fill(.linearGradient(colors: [accent.opacity(0.28), .clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 1, height: 30)
                            .offset(y: 31)
                    }
                }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(dimension.name)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(CreationPalette.fg)
                    Spacer()
                    Text("\(Int(dimension.value * 100))")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundStyle(CreationPalette.fg)
                        .monospacedDigit()
                }

                Slider(value: $dimension.value, in: 0...1, step: 0.01)
                    .tint(accent)

                HStack {
                    Text(dimension.lowLabel)
                    Spacer()
                    Text(dimension.highLabel)
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(CreationPalette.subtle)
            }
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                CreationDivider()
            }
        }
        .frame(minHeight: 58)
    }
}

private struct CreationDivider: View {
    var body: some View {
        LinearGradient(
            colors: [.clear, CreationPalette.hairline, CreationPalette.hairline, .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
    }
}

private extension Text {
    func creationFieldLabel() -> some View {
        self
            .font(.system(size: 12, weight: .heavy))
            .foregroundStyle(CreationPalette.label)
            .frame(width: 54, alignment: .leading)
    }
}

struct OnboardingHero: View {
    let kicker: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrototypeKicker(text: kicker)
            Text(title)
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(CreationPalette.fg)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(CreationPalette.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            PrototypeFloatingGlassTile(
                size: CGSize(width: 96, height: 88),
                colors: [CreationPalette.accent, CreationPalette.blue],
                opacity: 0.62
            )
            .offset(x: 8, y: -8)
        }
    }
}

struct OnboardingPrimaryButton<Label: View>: View {
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
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if isDisabled {
                        Capsule()
                            .fill(CreationPalette.action.opacity(0.22))
                    } else {
                        Capsule()
                            .fill(CreationPalette.actionGradient)
                    }
                }
                .shadow(color: CreationPalette.action.opacity(isDisabled ? 0 : 0.24), radius: 24, y: 12)
                .clipShape(Capsule())
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
    }
}
