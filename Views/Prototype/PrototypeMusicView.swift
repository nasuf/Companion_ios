import SwiftUI

struct PrototypeMusicView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var selectedTab: MusicTab = .agent
    @State private var showsLyrics = false
    @State private var isPlaying = true

    private enum MusicTab: String, CaseIterable, Identifiable {
        case agent
        case user

        var id: String { rawValue }
        var title: String { self == .agent ? "小芜在播" : "我的收藏" }
    }

    private var tracks: [PrototypeTrack] {
        selectedTab == .agent ? PrototypeFixtures.tracks : Self.userTracks
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .music) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    intro
                    player
                    tabs
                    trackList
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "shared rhythm")
            Text("今晚随机播到这首")
                .font(.system(size: 34, weight: .heavy))
            Text("此刻的旋律，我把耳机分你一半，听只属于我们的歌")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    private var player: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                PrototypeAssetImage(name: "music-cover-01.jpg")
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text("now playing")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(palette.subtle)
                    Text("房东的猫 · 云烟成雨")
                        .font(.system(size: 18, weight: .heavy))
                    Text("小芜正在同步播放。喜欢这一句的话，可以直接发回聊天。")
                        .font(.system(size: 11))
                        .foregroundStyle(palette.muted)
                        .lineLimit(2)
                }
            }

            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    showsLyrics.toggle()
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.linearGradient(colors: [palette.accent.opacity(0.18), Color(hex: 0x18C6C0).opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))

                    if showsLyrics {
                        VStack(alignment: .leading, spacing: 9) {
                            ForEach(Array(Self.lyrics.enumerated()), id: \.offset) { index, line in
                                Text(line)
                                    .font(.system(size: index == 2 ? 18 : 13, weight: index == 2 ? .heavy : .semibold))
                                    .foregroundStyle(index == 2 ? palette.fg : palette.muted)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(22)
                    } else {
                        HStack(alignment: .center, spacing: 7) {
                            ForEach(Array(Self.wave.enumerated()), id: \.offset) { index, height in
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(index.isMultiple(of: 3) ? palette.accent : Color(hex: 0x18C6C0))
                                    .frame(width: 8, height: CGFloat(height))
                                    .opacity(isPlaying ? 0.92 : 0.42)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 142)
                    }
                }
                .frame(height: 168)
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 54, height: 54)
                        .background(palette.fg)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                VStack(spacing: 7) {
                    HStack {
                        Text("01:42")
                        Spacer()
                        Text("03:58")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(palette.subtle)
                    GeometryReader { proxy in
                        Capsule()
                            .fill(palette.hairline)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(palette.accent)
                                    .frame(width: proxy.size.width * 0.43)
                            }
                    }
                    .frame(height: 7)
                }
            }
        }
        .prototypeCard(cornerRadius: 30, padding: 16)
        .padding(.horizontal, 16)
    }

    private var tabs: some View {
        HStack(spacing: 8) {
            ForEach(MusicTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(selectedTab == tab ? palette.fg : Color.white.opacity(0.52))
                        .foregroundStyle(selectedTab == tab ? palette.bg : palette.fg)
                        .clipShape(Capsule())
                        .prototypeLiquidGlass(cornerRadius: 21, tint: Color.white.opacity(0.18), interactive: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var trackList: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Text(selectedTab == .agent ? "小芜的歌单" : "我的歌单")
                    .font(.system(size: 18, weight: .heavy))
                Spacer()
                Text(selectedTab == .agent ? "专辑与歌单" : "切换后同步给小芜")
                    .font(.system(size: 11))
                    .foregroundStyle(palette.subtle)
            }

            ForEach(tracks) { track in
                HStack(spacing: 12) {
                    PrototypeAssetImage(name: track.cover)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .heavy))
                        Text("\(track.artist) · \(track.album)")
                            .font(.system(size: 10))
                            .foregroundStyle(palette.muted)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(track.count)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(track.isPlaying ? palette.accent : palette.subtle)
                }
                .padding(11)
                .background(track.isPlaying ? palette.accentSoft.opacity(0.72) : Color.white.opacity(0.50))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 14)
        .padding(.horizontal, 16)
    }

    private static let wave = [66, 112, 52, 126, 78, 108, 64, 96, 48, 132, 84, 116, 70, 101, 56, 124]
    private static let lyrics = ["你的晚风里有一点潮湿", "我先不说话，陪你听到副歌", "这句像傍晚路灯刚亮的时候", "如果你也喜欢，就让这一句多停一会儿", "下一首换你收藏里的那首晴天"]
    private static let userTracks: [PrototypeTrack] = [
        PrototypeTrack(title: "晴天", artist: "周杰伦", album: "叶惠美", count: "11 首", cover: "music-cover-07.jpg", isPlaying: false),
        PrototypeTrack(title: "我记得", artist: "赵雷", album: "署前街少年", count: "10 首", cover: "music-cover-08.jpg", isPlaying: false),
        PrototypeTrack(title: "句号", artist: "邓紫棋", album: "摩天动物园", count: "13 首", cover: "music-cover-09.jpg", isPlaying: false),
        PrototypeTrack(title: "NEW BOY", artist: "朴树", album: "我去2000年", count: "11 首", cover: "music-cover-10.jpg", isPlaying: false)
    ]
}
