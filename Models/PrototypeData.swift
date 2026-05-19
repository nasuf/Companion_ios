import SwiftUI

enum PrototypeTab: String, CaseIterable, Identifiable {
    case chat
    case online
    case scene
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chat: "聊天"
        case .online: "线上交互"
        case .scene: "场景交互"
        case .profile: "个人中心"
        }
    }

    var icon: String {
        switch self {
        case .chat: "bubble.left.and.bubble.right"
        case .online: "music.note.list"
        case .scene: "mappin.and.ellipse"
        case .profile: "person.crop.circle"
        }
    }
}

enum PrototypeRoute: Hashable, Identifiable {
    case music
    case movie
    case game
    case daily(PrototypeDailyTab = .photo)
    case offlineInvite
    case progress
    case memory
    case emotion
    case portrait
    case schedule
    case settings

    var id: String {
        switch self {
        case .music: "music"
        case .movie: "movie"
        case .game: "game"
        case .daily(let tab): "daily-\(tab.rawValue)"
        case .offlineInvite: "offlineInvite"
        case .progress: "progress"
        case .memory: "memory"
        case .emotion: "emotion"
        case .portrait: "portrait"
        case .schedule: "schedule"
        case .settings: "settings"
        }
    }
}

enum PrototypeDailyTab: String, CaseIterable, Identifiable {
    case photo
    case book
    case film
    case food

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo: "照片"
        case .book: "书籍"
        case .film: "影视"
        case .food: "美食"
        }
    }
}

struct PrototypePortal: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let metric: String
    let image: String
    let route: PrototypeRoute
}

struct PrototypeSceneModule: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let status: String
    let symbol: String
    let color: Color
    let route: PrototypeRoute
}

struct PrototypeTrack: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String
    let count: String
    let cover: String
    let isPlaying: Bool
}

struct PrototypeMovie: Identifiable {
    let id = UUID()
    let title: String
    let poster: String
    let state: String
    let time: String
    let duration: String
    let barrage: String
    let intro: String
    let subtitle: String
}

struct PrototypeGameGroup: Identifiable {
    let id: String
    let kicker: String
    let title: String
    let badge: String
    let metric: String
    let image: String
    let color: Color
    let subtitle: String
    let games: [PrototypeGame]
}

struct PrototypeGame: Identifiable {
    let id = UUID()
    let title: String
    let note: String
    let image: String
}

enum PrototypeFixtures {
    static let userName = "山木"
    static let agentName = "小芜"

    static let portals: [PrototypePortal] = [
        PrototypePortal(id: "daily", title: "日常分享", subtitle: "照片、书籍影视和美食被整理成自然分享卡。", metric: "今日 5 张", image: "daily-journal.jpg", route: .daily(.photo)),
        PrototypePortal(id: "movie", title: "一起看电影", subtitle: "海报轮播、同步进度、共同弹幕。", metric: "房间就绪", image: "movie-bouquet.jpg", route: .movie),
        PrototypePortal(id: "game", title: "一起玩游戏", subtitle: "动态棋盘、低压力小游戏和语音同步。", metric: "16 个游戏", image: "game-pieces.jpg", route: .game),
        PrototypePortal(id: "music", title: "一起听音乐", subtitle: "同步播放、共享乐评和轻聊天。", metric: "播放中", image: "vinyl-record.jpg", route: .music)
    ]

    static let sceneModules: [PrototypeSceneModule] = [
        PrototypeSceneModule(id: "offline", title: "线下活动邀请", subtitle: "周六 19:30 · 电影预约 B612", status: "已出票", symbol: "mappin", color: Color(hex: 0xFF7A3D), route: .offlineInvite),
        PrototypeSceneModule(id: "progress", title: "动态进程显示", subtitle: "外卖、包裹和任务集中追踪", status: "3 进行中", symbol: "arrow.up.right", color: Color(hex: 0x1F6FFF), route: .progress)
    ]

    static let tracks: [PrototypeTrack] = [
        PrototypeTrack(title: "云烟成雨", artist: "房东的猫", album: "云烟成雨 - Single", count: "1 首", cover: "music-cover-01.jpg", isPlaying: true),
        PrototypeTrack(title: "夜空中最亮的星", artist: "逃跑计划", album: "世界", count: "10 首", cover: "music-cover-02.jpg", isPlaying: false),
        PrototypeTrack(title: "给你一瓶魔法药水", artist: "告五人", album: "玫瑰凭证", count: "8 首", cover: "music-cover-03.jpg", isPlaying: false),
        PrototypeTrack(title: "慢慢喜欢你", artist: "莫文蔚", album: "慢慢喜欢你 - Single", count: "1 首", cover: "music-cover-04.jpg", isPlaying: false)
    ]

    static let movies: [PrototypeMovie] = [
        PrototypeMovie(title: "超级马力欧银河大电影", poster: "movie-super-mario-galaxy.jpeg", state: "正在热映", time: "00:18:42", duration: "01:38", barrage: "26 弹幕", intro: "真期待一起和你看这部电影，终于上映了，我等了很久呢", subtitle: "这段像把周末直接点亮了。"),
        PrototypeMovie(title: "曼达洛人与古古", poster: "movie-mandalorian-grogu.jpg", state: "近期上映", time: "预告 01:08", duration: "02:16", barrage: "42 想看", intro: "这部马上就要上映了，我们先把预告看完。", subtitle: "等上映那天，我们把第一场留给它。"),
        PrototypeMovie(title: "Project Hail Mary", poster: "movie-project-hail-mary.jpg", state: "近期上映", time: "00:36:05", duration: "02:12", barrage: "19 弹幕", intro: "这部刚上映不久，很适合留一个安静的夜晚。", subtitle: "如果宇宙只剩一个声音，我想和你一起听。")
    ]

    static let gameGroups: [PrototypeGameGroup] = [
        PrototypeGameGroup(id: "board", kicker: "slow strategy", title: "棋牌游戏", badge: "静心对弈", metric: "4 款棋类", image: "category-board-hero.jpg", color: Color(hex: 0x1F6FFF), subtitle: "从安静落子开始，不急着赢，只把这一局慢慢下完。", games: [
            PrototypeGame(title: "围棋", note: "黑白落子，适合慢慢想。", image: "go-conquest.jpg"),
            PrototypeGame(title: "五子棋", note: "五子连线，几分钟开局。", image: "gomoku-lets-go.jpg"),
            PrototypeGame(title: "象棋", note: "攻守推进，一边聊一边下。", image: "chinese-chess.jpg"),
            PrototypeGame(title: "国际象棋", note: "节奏更锋利的策略局。", image: "chess-ultra.jpg")
        ]),
        PrototypeGameGroup(id: "together", kicker: "co-op room", title: "双人同行", badge: "一起过关", metric: "4 个搭档局", image: "category-coop-hero.jpg", color: Color(hex: 0xFF7A3D), subtitle: "需要一点配合，也允许一点手忙脚乱，笑出来就算赢。", games: [
            PrototypeGame(title: "双人厨房", note: "分工备餐，别把锅烧糊。", image: "overcooked-2.jpg"),
            PrototypeGame(title: "乒乓大战", note: "短回合接球，节奏很轻。", image: "eleven-table-tennis.jpg"),
            PrototypeGame(title: "经典台球", note: "瞄准、撞球、慢慢收杆。", image: "pure-pool.jpg"),
            PrototypeGame(title: "异界冒险", note: "两个人一起探索下一格。", image: "it-takes-two.jpg")
        ])
    ]
}
