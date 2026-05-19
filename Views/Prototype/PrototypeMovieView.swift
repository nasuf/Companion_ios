import SwiftUI

struct PrototypeMovieView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var selectedIndex = 0
    @State private var showsControls = true

    private var movie: PrototypeMovie { PrototypeFixtures.movies[selectedIndex] }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions(shareAction: {})
                    intro
                    player
                    barragePanel
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "cinema player")
            Text("你和我的共同影厅")
                .font(.system(size: 34, weight: .heavy))
            Text(movie.intro)
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    private var player: some View {
        VStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    showsControls.toggle()
                }
            } label: {
                ZStack(alignment: .bottomLeading) {
                    PrototypeAssetImage(name: movie.poster)
                        .frame(height: 392)
                        .clipped()
                        .overlay(.linearGradient(colors: [Color.black.opacity(0.10), Color.black.opacity(0.68)], startPoint: .top, endPoint: .bottom))

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(movie.title)
                            Spacer()
                            Text(movie.state)
                        }
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.82))

                        Spacer()

                        Text("正在播放 · \(movie.title)")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(.white)
                        Text(movie.subtitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.76))

                        if showsControls {
                            movieControls
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(18)
                }
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .prototypeLiquidGlass(cornerRadius: 32, tint: Color.white.opacity(0.14), interactive: true)
            }
            .buttonStyle(.plain)

            movieRail
        }
        .padding(.horizontal, 16)
    }

    private var movieControls: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(palette.fg)
                .frame(width: 44, height: 44)
                .background(.white)
                .clipShape(Circle())
            VStack(spacing: 7) {
                HStack {
                    Text(movie.time)
                    Spacer()
                    Text(movie.duration)
                }
                .font(.system(size: 10, weight: .heavy))
                Capsule()
                    .fill(Color.white.opacity(0.30))
                    .frame(height: 6)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white)
                            .frame(width: 96)
                    }
            }
            Text(movie.barrage)
                .font(.system(size: 10, weight: .heavy))
                .padding(.horizontal, 9)
                .frame(height: 30)
                .background(Color.white.opacity(0.22))
                .clipShape(Capsule())
        }
        .foregroundStyle(.white)
    }

    private var movieRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(PrototypeFixtures.movies.enumerated()), id: \.offset) { index, item in
                    Button {
                        selectedIndex = index
                    } label: {
                        PrototypeAssetImage(name: item.poster)
                            .frame(width: 92, height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(alignment: .bottom) {
                                Text(item.title)
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(.linearGradient(colors: [.clear, Color.black.opacity(0.72)], startPoint: .top, endPoint: .bottom))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(index == selectedIndex ? Color.white : Color.clear, lineWidth: 3)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var barragePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("正在播放弹幕")
                    .font(.system(size: 17, weight: .heavy))
                Spacer()
                Text(movie.title)
                    .font(.system(size: 11))
                    .foregroundStyle(palette.subtle)
            }
            ForEach(Self.barrage, id: \.0) { item in
                HStack(spacing: 10) {
                    Circle().fill(palette.accent).frame(width: 7, height: 7)
                    Text(item.1)
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Text(item.0)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(palette.subtle)
                }
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 15)
        .padding(.horizontal, 16)
    }

    private static let barrage = [
        ("00:18", "这段好像周末突然亮起来。"),
        ("00:42", "我先不说话，这里很好看。"),
        ("01:06", "等上映那天我们留第一场。"),
        ("01:31", "这一幕可以做成回顾卡。")
    ]
}
