import SwiftUI

struct PrototypeMovieView: View {
    @State private var selectedIndex = 0
    @State private var showsControls = false

    private var movie: PrototypeMovie { PrototypeFixtures.movies[selectedIndex] }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .movie, animatesBackground: false) {
            ZStack {
                CinemaBackdrop()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        CinemaActions()

                        CinemaIntro(movie: movie)

                        CinemaPlayer(
                            movie: movie,
                            movies: PrototypeFixtures.movies,
                            selectedIndex: $selectedIndex,
                            showsControls: $showsControls
                        )

                        CinemaBarragePanel(movie: movie, rows: Self.barrage)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 106)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private static let barrage = [
        ("01:46", "小芜：如果你不想说话，我们就先看完这一幕。"),
        ("01:42", "小芜：这里的眼神好适合暂停一下。"),
        ("01:43", "你：这句台词有点像我们刚才说的。")
    ]
}

private struct CinemaBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: 0x151823),
                    Color(hex: 0x15151D),
                    Color(hex: 0x110B0D),
                    Color(hex: 0x07080B)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color(hex: 0xFF6A3D).opacity(0.26), .clear],
                center: UnitPoint(x: 0.86, y: 0.02),
                startRadius: 18,
                endRadius: 280
            )

            RadialGradient(
                colors: [Color(hex: 0x1F6FFF).opacity(0.18), .clear],
                center: UnitPoint(x: 0.16, y: 0.46),
                startRadius: 14,
                endRadius: 260
            )

            CinemaGrid()
                .opacity(0.9)
        }
        .ignoresSafeArea()
    }
}

private struct CinemaGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                var x: CGFloat = 0
                while x <= proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += 34
                }

                var y: CGFloat = 0
                while y <= proxy.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: proxy.size.width, y: y))
                    y += 68
                }
            }
            .stroke(Color.white.opacity(0.035), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

private struct CinemaActions: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
                    .prototypeLiquidGlass(cornerRadius: 21, tint: Color.white.opacity(0.12), interactive: true)
                    .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1))
            }
            .buttonStyle(.prototypeGlassProminentPress)

            Spacer()

            Button {
            } label: {
                Text("发聊天")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x101820))
                    .padding(.horizontal, 18)
                    .frame(height: 42)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
                    .prototypeLiquidGlass(cornerRadius: 21, tint: Color.white.opacity(0.22), interactive: true)
            }
            .buttonStyle(.prototypeGlassProminentPress)
        }
        .padding(.top, 4)
        .padding(.bottom, 12)
    }
}

private struct CinemaIntro: View {
    let movie: PrototypeMovie

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CINEMA PLAYER")
                .font(.system(size: 13, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(Color(hex: 0xFFB3A2))

            Text("你和我的共同影厅")
                .font(.system(size: 33, weight: .heavy))
                .lineSpacing(-3)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 4)

            Text(movie.intro)
                .font(.system(size: 15, weight: .medium))
                .lineSpacing(5)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 326, alignment: .leading)
        }
    }
}

private struct CinemaPlayer: View {
    let movie: PrototypeMovie
    let movies: [PrototypeMovie]
    @Binding var selectedIndex: Int
    @Binding var showsControls: Bool

    var body: some View {
        VStack(spacing: 18) {
            Button {
                withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                    showsControls.toggle()
                }
            } label: {
                CinemaScreen(movie: movie, showsControls: showsControls)
            }
            .buttonStyle(.prototypeGlassPress)

            CinemaMovieRail(
                movies: movies,
                selectedIndex: $selectedIndex,
                showsControls: $showsControls
            )
        }
    }
}

private struct CinemaScreen: View {
    let movie: PrototypeMovie
    let showsControls: Bool

    var body: some View {
        ZStack {
            BreathingMoviePoster(name: movie.poster)
                .frame(height: 408)
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.18), Color.black.opacity(0.66)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Text(movie.title)
                    Spacer(minLength: 18)
                    Text(movie.state)
                }
                .font(.system(size: 12, weight: .heavy))
                .tracking(0.4)
                .foregroundStyle(.white.opacity(0.84))
                .padding(.top, 18)
                .padding(.horizontal, 17)

                Spacer()

                CinemaCaption(movie: movie)
                    .padding(.horizontal, 24)
                    .padding(.bottom, showsControls ? 18 : 42)

                if showsControls {
                    CinemaInlineControls(movie: movie)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(height: 408)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.54), radius: 34, y: 26)
        .shadow(color: Color(hex: 0xFF6A3D).opacity(0.14), radius: 52, y: 18)
        .contentShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
    }
}

private struct BreathingMoviePoster: View {
    let name: String
    @State private var breathes = false

    var body: some View {
        GeometryReader { proxy in
            PrototypeAssetImage(name: name)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(breathes ? 1.075 : 1.035)
                .offset(x: breathes ? 7 : -6, y: breathes ? -5 : 7)
                .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: breathes)
                .onAppear {
                    breathes = true
                }
        }
        .clipped()
    }
}

private struct CinemaCaption: View {
    let movie: PrototypeMovie

    var body: some View {
        VStack(spacing: 13) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: 0xFF6A3D))
                    .frame(width: 8, height: 8)
                    .shadow(color: Color(hex: 0xFF6A3D).opacity(0.7), radius: 8)

                Text("正在播放 · \(movie.title)")
                    .font(.system(size: 18, weight: .heavy))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }

            Text("“\(movie.subtitle)”")
                .font(.system(size: 16, weight: .heavy))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.36), radius: 9, y: 4)
    }
}

private struct CinemaInlineControls: View {
    let movie: PrototypeMovie

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(Color(hex: 0x101820))
                .frame(width: 46, height: 46)
                .background(Color.white.opacity(0.96))
                .clipShape(Circle())

            VStack(spacing: 8) {
                HStack {
                    Text(movie.time)
                    Spacer()
                    Text(movie.duration)
                }
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.white)

                Capsule()
                    .fill(Color.white.opacity(0.35))
                    .frame(height: 5)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color.white)
                            .frame(maxWidth: 92)
                    }
            }

            Text(movie.barrage)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Color.white.opacity(0.22))
                .clipShape(Capsule())
        }
    }
}

private struct CinemaMovieRail: View {
    let movies: [PrototypeMovie]
    @Binding var selectedIndex: Int
    @Binding var showsControls: Bool
    @State private var scrollPosition: Int?

    private let cellWidth: CGFloat = 112

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(alignment: .bottom, spacing: -4) {
                        ForEach(Array(movies.enumerated()), id: \.offset) { index, movie in
                            Button {
                                select(index)
                            } label: {
                                CinemaPosterThumb(movie: movie, isSelected: index == selectedIndex)
                                    .frame(width: cellWidth, height: 150)
                            }
                            .buttonStyle(.prototypeGlassPress)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(.horizontal, max(0, (proxy.size.width - cellWidth) / 2))
                .scrollClipDisabled()
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition, anchor: .center)
                .onAppear {
                    scrollPosition = selectedIndex
                }
                .onChange(of: selectedIndex) { _, newValue in
                    if scrollPosition != newValue {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
                            scrollPosition = newValue
                        }
                    }
                }
                .onChange(of: scrollPosition) { _, newValue in
                    guard let newValue, newValue != selectedIndex else { return }
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                        selectedIndex = newValue
                        showsControls = false
                    }
                }

                HStack {
                    railArrow(systemName: "chevron.left", direction: -1)
                    Spacer()
                    railArrow(systemName: "chevron.right", direction: 1)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .zIndex(30)
            }
        }
        .frame(height: 182)
        .animation(.spring(response: 0.42, dampingFraction: 0.84), value: selectedIndex)
    }

    private func railArrow(systemName: String, direction: Int) -> some View {
        let isAtBoundary = (direction < 0 && selectedIndex == 0) || (direction > 0 && selectedIndex == movies.count - 1)

        return Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                selectedIndex = min(max(selectedIndex + direction, 0), movies.count - 1)
                showsControls = false
            }
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(.white.opacity(isAtBoundary ? 0.40 : 0.86))
                .frame(width: 38, height: 78)
                .background(Color.white.opacity(isAtBoundary ? 0.08 : 0.13))
                .clipShape(Capsule())
                .prototypeLiquidGlass(cornerRadius: 20, tint: Color.white.opacity(0.10), interactive: true)
                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
        }
        .disabled(isAtBoundary)
        .buttonStyle(.prototypeGlassProminentPress)
    }

    private func select(_ index: Int) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            selectedIndex = index
            scrollPosition = index
            showsControls = false
        }
    }
}

private struct CinemaPosterThumb: View {
    let movie: PrototypeMovie
    let isSelected: Bool

    var body: some View {
        PrototypeAssetImage(name: movie.poster)
            .frame(width: isSelected ? 112 : 74, height: isSelected ? 140 : 98)
            .clipShape(RoundedRectangle(cornerRadius: isSelected ? 24 : 20, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                Text(movie.title)
                    .font(.system(size: isSelected ? 13 : 10, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                    .padding(isSelected ? 12 : 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(isSelected ? 0.70 : 0.56)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: isSelected ? 24 : 20, style: .continuous)
                    .stroke(Color.white.opacity(isSelected ? 0.84 : 0), lineWidth: 2)
            )
            .saturation(isSelected ? 1 : 0.72)
            .opacity(isSelected ? 1 : 0.62)
            .shadow(color: Color.black.opacity(isSelected ? 0.42 : 0.22), radius: isSelected ? 20 : 10, y: isSelected ? 12 : 7)
            .animation(.spring(response: 0.42, dampingFraction: 0.84), value: isSelected)
    }
}

private struct CinemaBarragePanel: View {
    let movie: PrototypeMovie
    let rows: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text("正在播放弹幕")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(.white)

                Spacer()

                Text(movie.title)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.48))
                    .lineLimit(1)
            }
            .padding(.bottom, 8)

            CinemaBarrageTicker(rows: rows)
        }
        .padding(.horizontal, 18)
        .padding(.top, 22)
        .padding(.bottom, 24)
        .background(Color(hex: 0x242126).opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1.2)
        )
        .shadow(color: Color.black.opacity(0.46), radius: 34, y: 22)
        .padding(.top, 6)
    }
}

private struct CinemaBarrageTicker: View {
    let rows: [(String, String)]
    @State private var rolls = false

    private var tickerRows: [(String, String)] {
        rows + rows
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 14) {
                ForEach(Array(tickerRows.enumerated()), id: \.offset) { _, row in
                    CinemaBarrageRow(row: row)
                }
            }
            .offset(y: rolls ? -CGFloat(rows.count) * 70 : proxy.size.height + 10)
            .animation(.linear(duration: 11).repeatForever(autoreverses: false), value: rolls)
            .onAppear {
                rolls = true
            }
        }
        .frame(height: 204)
        .mask(
            LinearGradient(
                colors: [.clear, .black, .black, .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .accessibilityHidden(true)
    }
}

private struct CinemaBarrageRow: View {
    let row: (String, String)

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: 0xFF6A3D))
                .frame(width: 8, height: 8)
                .shadow(color: Color(hex: 0xFF6A3D).opacity(0.48), radius: 6)

            Text(row.1)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.72))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 10)

            Text(row.0)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(.white.opacity(0.48))
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 56)
        .background(Color.white.opacity(0.065))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
