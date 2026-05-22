import SwiftUI

private enum MusicTab: String, CaseIterable, Identifiable {
    case agent
    case user

    var id: String { rawValue }
    var title: String { self == .agent ? "小芜在播" : "我的收藏" }
}

struct PrototypeMusicView: View {
    @State private var selectedTab: MusicTab = .agent
    @State private var showsLyrics = false
    @State private var isPlaying = true

    private var tracks: [PrototypeTrack] {
        selectedTab == .agent ? PrototypeFixtures.tracks : Self.userTracks
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .music, animatesBackground: false) {
            ZStack {
                MusicBackdrop()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        MusicActions()
                        MusicIntro()

                        MusicPlayerCard(
                            showsLyrics: $showsLyrics,
                            isPlaying: $isPlaying
                        )

                        MusicTabs(selection: $selectedTab)
                        MusicTrackSection(tab: selectedTab, tracks: tracks)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }
            }
        }
    }

    private static let userTracks: [PrototypeTrack] = [
        PrototypeTrack(title: "晴天", artist: "周杰伦", album: "叶惠美", count: "11 首", cover: "music-cover-07.jpg", isPlaying: false),
        PrototypeTrack(title: "我记得", artist: "赵雷", album: "署前街少年", count: "10 首", cover: "music-cover-08.jpg", isPlaying: false),
        PrototypeTrack(title: "句号", artist: "邓紫棋", album: "摩天动物园", count: "13 首", cover: "music-cover-09.jpg", isPlaying: false),
        PrototypeTrack(title: "NEW BOY", artist: "朴树", album: "我去2000年", count: "11 首", cover: "music-cover-10.jpg", isPlaying: false),
        PrototypeTrack(title: "小幸运", artist: "田馥甄", album: "小幸运 - Single", count: "1 首", cover: "music-cover-11.jpg", isPlaying: false)
    ]
}

private struct MusicBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xF8FBFA), Color(hex: 0xF6F8FF), Color(hex: 0xFAF7F2)],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color(hex: 0x1F6FFF).opacity(0.18), .clear],
                center: UnitPoint(x: 0.86, y: 0.12),
                startRadius: 12,
                endRadius: 240
            )

            RadialGradient(
                colors: [Color(hex: 0x7C3CFF).opacity(0.10), .clear],
                center: UnitPoint(x: 0.12, y: 0.22),
                startRadius: 10,
                endRadius: 240
            )

            RadialGradient(
                colors: [Color(hex: 0x18C6C0).opacity(0.16), .clear],
                center: UnitPoint(x: 0.78, y: 0.36),
                startRadius: 20,
                endRadius: 260
            )
        }
        .ignoresSafeArea()
    }
}

private struct MusicActions: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x101820))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.82))
                    .clipShape(Circle())
                    .prototypeLiquidGlass(cornerRadius: 25, tint: Color.white.opacity(0.34), interactive: true)
            }
            .buttonStyle(.prototypeGlassProminentPress)

            Spacer()

            Button {
            } label: {
                Text("发聊天")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 50)
                    .background(Color(hex: 0x101820))
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: 0x101820).opacity(0.18), radius: 22, y: 12)
            }
            .buttonStyle(.prototypeGlassProminentPress)
        }
    }
}

private struct MusicIntro: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SHARED RHYTHM")
                .font(.system(size: 15, weight: .heavy))
                .tracking(0.8)
                .foregroundStyle(Color(hex: 0x1F6FFF))

            Text("今晚随机播到这首")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(Color(hex: 0x101820))
                .lineSpacing(-3)

            Text("此刻的旋律，我把耳机分你一半，听只属于我们的歌")
                .font(.system(size: 16, weight: .medium))
                .lineSpacing(7)
                .foregroundStyle(Color(hex: 0x101820).opacity(0.54))
                .frame(maxWidth: 326, alignment: .leading)
        }
        .padding(.top, 14)
        .padding(.horizontal, 12)
    }
}

private struct MusicPlayerCard: View {
    @Binding var showsLyrics: Bool
    @Binding var isPlaying: Bool

    var body: some View {
        VStack(spacing: 16) {
            if !showsLyrics {
                HStack(alignment: .top, spacing: 14) {
                    MusicVinylCover()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOW PLAYING")
                            .font(.system(size: 11, weight: .black))
                            .tracking(0.9)
                            .foregroundStyle(Color(hex: 0x8EE7FF))

                        Text("房东的猫 · 云烟成雨")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Text("小芜正在同步播放。喜欢这一句的话，可以直接发回聊天。")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.66))
                            .lineSpacing(3)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    showsLyrics.toggle()
                }
            } label: {
                Group {
                    if showsLyrics {
                        MusicLyricsDisplay(isPlaying: isPlaying)
                    } else {
                        MusicWaveDisplay(isPlaying: isPlaying)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: showsLyrics ? 210 : 98)
            }
            .buttonStyle(.prototypeGlassPress)

            MusicControls(isPlaying: $isPlaying)
        }
        .padding(.horizontal, 17)
        .padding(.top, showsLyrics ? 18 : 17)
        .padding(.bottom, 16)
        .frame(minHeight: showsLyrics ? 328 : 328)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x162B3A), Color(hex: 0x101A25), Color(hex: 0x091018)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                MusicPlayerGrid()
                RadialGradient(
                    colors: [Color(hex: 0x1F6FFF).opacity(0.20), .clear],
                    center: UnitPoint(x: 0.08, y: 0.82),
                    startRadius: 8,
                    endRadius: 190
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x1F6FFF).opacity(0.14), radius: 34, y: 18)
        .shadow(color: Color.black.opacity(0.18), radius: 28, y: 18)
    }
}

private struct MusicPlayerGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                var x: CGFloat = 0
                while x < proxy.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: proxy.size.height))
                    x += 34
                }
            }
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

private struct MusicVinylCover: View {
    @State private var floats = false

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [Color(hex: 0xFFED9D), Color(hex: 0x15233D), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 56
                )
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 2)
                    .padding(22)
                    .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 2).padding(12))
                    .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 2).padding(4))
            )
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(hex: 0x0A1430), Color(hex: 0x123B77), Color(hex: 0x050914)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .frame(width: 104, height: 104)
            .shadow(color: Color.black.opacity(0.30), radius: 24, y: 14)
            .offset(y: floats ? -7 : 1)
            .rotationEffect(.degrees(floats ? 2 : -1))
            .animation(.easeInOut(duration: 6.8).repeatForever(autoreverses: true), value: floats)
            .onAppear { floats = true }
    }
}

private struct MusicWaveDisplay: View {
    let isPlaying: Bool

    private let wave = [66, 112, 52, 126, 78, 108, 64, 96, 48, 132, 84, 116, 70, 101, 56, 124, 88, 136, 58, 104]

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            ForEach(Array(wave.enumerated()), id: \.offset) { index, height in
                MusicWaveBar(height: height, delay: Double(index) * 0.09, isPlaying: isPlaying)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .accessibilityLabel("音乐波形")
    }
}

private struct MusicWaveBar: View {
    let height: Int
    let delay: Double
    let isPlaying: Bool
    @State private var animates = false

    var body: some View {
        RoundedRectangle(cornerRadius: 99, style: .continuous)
            .fill(LinearGradient(colors: [Color(hex: 0xA9F5FF), Color(hex: 0x5ED8FF), Color(hex: 0x2178FF)], startPoint: .top, endPoint: .bottom))
            .frame(maxWidth: .infinity)
            .frame(height: CGFloat(height) * 0.62)
            .scaleEffect(y: isPlaying ? (animates ? 1.0 : 0.46) : 0.46, anchor: .center)
            .opacity(isPlaying ? (animates ? 1 : 0.48) : 0.42)
            .animation(.easeInOut(duration: 1.35).delay(delay).repeatForever(autoreverses: true), value: animates)
            .onAppear { animates = true }
    }
}

private struct MusicLyricsDisplay: View {
    let isPlaying: Bool
    @State private var rolls = false

    private let lyrics = ["你的晚风里有一点潮湿", "我先不说话，陪你听到副歌", "这句像傍晚路灯刚亮的时候", "如果你也喜欢，就让这一句多停一会儿", "下一首换你收藏里的那首晴天", "等旋律落下来，再慢慢回消息"]

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(lyrics.enumerated()), id: \.offset) { index, line in
                    Text(line)
                        .font(.system(size: index == 2 ? 22 : 16, weight: index == 2 ? .heavy : .semibold))
                        .foregroundStyle(index == 2 ? Color.white : Color.white.opacity(0.30))
                        .lineLimit(1)
                        .offset(x: index.isMultiple(of: 2) ? 0 : 18)
                }
            }
            .offset(y: rolls && isPlaying ? -58 : 36)
            .animation(.easeInOut(duration: 10.5).repeatForever(autoreverses: true), value: rolls)

            VStack(alignment: .leading, spacing: 14) {
                Capsule()
                    .fill(LinearGradient(colors: [Color(hex: 0x8EE7FF), Color(hex: 0x1F6FFF)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 34, height: 4)
                    .shadow(color: Color(hex: 0x4ECAFF).opacity(0.55), radius: 18)

                Text("这句像傍晚路灯刚亮的时候")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .shadow(color: Color(hex: 0x5DD8FF).opacity(0.30), radius: 34, y: 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .mask(
            LinearGradient(colors: [.clear, .black, .black, .clear], startPoint: .top, endPoint: .bottom)
        )
        .onAppear { rolls = true }
    }
}

private struct MusicControls: View {
    @Binding var isPlaying: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    isPlaying.toggle()
                }
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(colors: [Color(hex: 0x8EE7FF).opacity(0.32), Color(hex: 0x1F6FFF).opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color(hex: 0x1F6FFF).opacity(0.24), radius: 22, y: 10)
            }
            .buttonStyle(.prototypeGlassProminentPress)

            VStack(spacing: 8) {
                HStack {
                    Text("01:42")
                    Spacer()
                    Text("03:58")
                }
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.white.opacity(0.66))

                GeometryReader { proxy in
                    Capsule()
                        .fill(Color.white.opacity(0.16))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(LinearGradient(colors: [Color(hex: 0x8EE7FF), Color(hex: 0x1F6FFF)], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * 0.43)
                        }
                }
                .frame(height: 6)
            }
        }
    }
}

private struct MusicTabs: View {
    @Binding var selection: MusicTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MusicTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) {
                        selection = tab
                    }
                } label: {
                    Text(tab.title)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(selection == tab ? Color.white : Color(hex: 0x101820).opacity(0.52))
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background {
                            if selection == tab {
                                LinearGradient(colors: [Color(hex: 0x1F6FFF), Color(hex: 0x18C6C0)], startPoint: .leading, endPoint: .trailing)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .shadow(color: Color(hex: 0x1F6FFF).opacity(0.20), radius: 18, y: 10)
                            }
                        }
                }
                .buttonStyle(.prototypeGlassPress)
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .prototypeLiquidGlass(cornerRadius: 24, tint: Color.white.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct MusicTrackSection: View {
    let tab: MusicTab
    let tracks: [PrototypeTrack]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                Text(tab == .agent ? "小芜的歌单" : "我的歌单")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x101820))
                Spacer()
                Text(tab == .agent ? "专辑与歌单" : "切换后同步给小芜")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x101820).opacity(0.42))
            }
            .padding(.horizontal, 3)
            .padding(.bottom, 9)

            VStack(spacing: 0) {
                ForEach(tracks) { track in
                    MusicTrackRow(track: track)
                    if track.id != tracks.last?.id {
                        Rectangle()
                            .fill(Color(hex: 0x101820).opacity(0.07))
                            .frame(height: 1)
                            .padding(.leading, 63)
                    }
                }
            }
        }
        .padding(.top, 6)
    }
}

private struct MusicTrackRow: View {
    let track: PrototypeTrack

    var body: some View {
        HStack(spacing: 11) {
            PrototypeAssetImage(name: track.cover)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(alignment: .bottomTrailing) {
                    if track.isPlaying {
                        Circle()
                            .fill(Color(hex: 0x8EE7FF))
                            .frame(width: 8, height: 8)
                            .padding(5)
                    }
                }
                .shadow(color: Color.black.opacity(0.12), radius: 16, y: 8)

            VStack(alignment: .leading, spacing: 5) {
                Text(track.title)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color(hex: 0x101820))
                Text("\(track.artist) · \(track.album)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: 0x101820).opacity(0.56))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Text(track.count)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(track.isPlaying ? Color(hex: 0x397782) : Color(hex: 0x101820).opacity(0.44))
                .padding(.horizontal, 8)
                .frame(height: 28)
                .background(Color.white.opacity(0.62))
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }
}
