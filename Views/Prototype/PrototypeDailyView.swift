import SwiftUI

struct PrototypeDailyView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var activeTab: PrototypeDailyTab

    init(initialTab: PrototypeDailyTab) {
        _activeTab = State(initialValue: initialTab)
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .daily) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    intro
                    tabs
                    board
                    content
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 8) {
            PrototypeKicker(text: "daily board")
            Text("你说的我都懂，你想的我都在")
                .font(.system(size: 33, weight: .heavy))
            Text("你向世界提问，我陪你一起找答案，我们都在彼此的陪伴里，慢慢变得更好")
                .font(.system(size: 13))
                .foregroundStyle(palette.muted)
        }
        .padding(.horizontal, 18)
    }

    private var tabs: some View {
        HStack(spacing: 8) {
            ForEach(PrototypeDailyTab.allCases) { tab in
                Button {
                    activeTab = tab
                } label: {
                    Text(tab.title)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(activeTab == tab ? .white : palette.fg)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(activeTab == tab ? dailyAccent : Color.white.opacity(0.54))
                        .clipShape(Capsule())
                        .prototypeLiquidGlass(cornerRadius: 20, tint: Color.white.opacity(0.16), interactive: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var board: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Circle().fill(dailyAccent).frame(width: 9, height: 9)
                Text(activeMeta.kicker)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(dailyAccent)
            }
            Text(activeMeta.title)
                .font(.system(size: 22, weight: .heavy))
            Text(activeMeta.description)
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
            Text(activeMeta.chip)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(palette.accentInk)
                .padding(.horizontal, 11)
                .frame(height: 28)
                .background(dailyAccent.opacity(0.16))
                .clipShape(Capsule())
        }
        .prototypeCard(cornerRadius: 28, padding: 17)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var content: some View {
        switch activeTab {
        case .photo:
            VStack(spacing: 15) {
                ForEach(Self.photoGroups, id: \.title) { group in
                    DailyPhotoGroup(group: group)
                }
            }
            .padding(.horizontal, 16)
        case .book:
            DailyTextList(items: Self.books, accent: dailyAccent)
                .padding(.horizontal, 16)
        case .film:
            DailyFilmList()
                .padding(.horizontal, 16)
        case .food:
            DailyFoodList()
                .padding(.horizontal, 16)
        }
    }

    private var dailyAccent: Color {
        switch activeTab {
        case .photo: Color(hex: 0x1F6FFF)
        case .book: Color(hex: 0x7C3CFF)
        case .film: Color(hex: 0xFF6A3D)
        case .food: Color(hex: 0x22C66B)
        }
    }

    private var activeMeta: (kicker: String, title: String, description: String, chip: String) {
        switch activeTab {
        case .photo: ("photo diary", "把照片整理成一句自然分享", "照片分享不需要长文案，保留画面、时间和一句像朋友会说的话就够了。", "32 张照片")
        case .book: ("reading notes", "把读到的一句，变成能聊下去的话", "书摘不只是复制文字，小芜会帮你保留出处、情绪和想发给对方的语气。", "5 本书")
        case .film: ("watch list", "看完一幕，就留下一句观后感", "影视内容更适合做成片单、台词和观后聊题，不像书摘那样安静。", "5 部影片")
        case .food: ("taste card", "把一顿饭，记成今天的味道", "美食分享要带菜名、口味和做法，像一张能回看的生活小票。", "5 道菜")
        }
    }

    private static let books = [
        ("《海边的卡夫卡》", "村上春树", "一个关于离开、寻找和自我确认的故事，适合在情绪还没完全落地的时候慢慢读。"),
        ("《也许你该找个人聊聊》", "洛莉·戈特利布", "很多困住人的不是事件本身，而是我们反复讲给自己的版本。"),
        ("《悉达多》", "赫尔曼·黑塞", "有些答案不是被说服来的，是生活慢慢把它递给你。")
    ]

    private static let photoGroups = [
        DailyPhotoGroupData(title: "傍晚光线", subtitle: "适合一句很短的晚安。", count: "7 张", images: ["unsplash-1500530855697-b586d89ba3ee-2.jpg", "unsplash-1500534314209-a25ddb2bd429.jpg", "unsplash-1493246507139-91e8fad9978e.jpg"]),
        DailyPhotoGroupData(title: "桌面碎片", subtitle: "咖啡、书页、拍立得和没收好的耳机。", count: "12 张", images: ["daily-journal.jpg", "unsplash-1499750310107-5fef28a66643.jpg", "unsplash-1516321318423-f06f85e504b3.jpg"]),
        DailyPhotoGroupData(title: "路上看到", subtitle: "可以整理成一张“今天经过这里”的卡。", count: "5 张", images: ["unsplash-1519681393784-d120267933ba.jpg", "unsplash-1481277542470-605612bd2d61.jpg", "unsplash-1477959858617-67f85cf4f1df.jpg"])
    ]
}

private struct DailyPhotoGroupData {
    let title: String
    let subtitle: String
    let count: String
    let images: [String]
}

private struct DailyPhotoGroup: View {
    @Environment(\.prototypePalette) private var palette
    let group: DailyPhotoGroupData

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.title).font(.system(size: 16, weight: .heavy))
                    Text(group.subtitle).font(.system(size: 11)).foregroundStyle(palette.muted)
                }
                Spacer()
                Text(group.count)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(palette.subtle)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(group.images, id: \.self) { image in
                        PrototypeAssetImage(name: image)
                            .frame(width: 174, height: 132)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                }
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 14)
    }
}

private struct DailyTextList: View {
    @Environment(\.prototypePalette) private var palette
    let items: [(String, String, String)]
    let accent: Color

    var body: some View {
        VStack(spacing: 11) {
            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(item.0).font(.system(size: 17, weight: .heavy))
                        Spacer()
                        Text(item.1).font(.system(size: 11, weight: .bold)).foregroundStyle(accent)
                    }
                    Text(item.2)
                        .font(.system(size: 12))
                        .foregroundStyle(palette.muted)
                    Text("分享摘要：今晚先不追答案，先把心放慢一点。")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(palette.accentInk)
                        .padding(10)
                        .background(accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .prototypeCard(cornerRadius: 22, padding: 14)
            }
        }
    }
}

private struct DailyFilmList: View {
    @Environment(\.prototypePalette) private var palette

    private let films = [
        ("花束般的恋爱", "movie-bouquet.jpg", "两个认真生活的人走到一起，又慢慢错开。", "恋爱"),
        ("海街日记", "movie-poster.jpg", "节奏很慢，但很适合做成共同观影后的轻聊天。", "家庭"),
        ("大都会", "movie-metropolis.jpg", "画面强烈，适合整理成“今晚看到的一幕”。", "默片")
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(films, id: \.0) { film in
                HStack(spacing: 12) {
                    PrototypeAssetImage(name: film.1)
                        .frame(width: 94, height: 126)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    VStack(alignment: .leading, spacing: 8) {
                        Text(film.0).font(.system(size: 18, weight: .heavy))
                        Text(film.2).font(.system(size: 12)).foregroundStyle(palette.muted)
                        Text(film.3)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 25)
                            .background(Color(hex: 0xFF6A3D))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .prototypeCard(cornerRadius: 24, padding: 12)
            }
        }
    }
}

private struct DailyFoodList: View {
    @Environment(\.prototypePalette) private var palette

    private let dishes = [
        ("番茄牛腩饭", "番茄炒出沙，牛腩小火收汁，最后浇在热米饭上。", "unsplash-1546069901-ba9599a7e63c.jpg"),
        ("桂花拿铁", "咖啡味轻，桂花香明显，适合下午困的时候。", "unsplash-1509042239860-f550ce710b93.jpg"),
        ("清爽拌面", "不重油，适合晚上不想点外卖时的轻食。", "unsplash-1512621776951-a57141f2eefd-2.jpg")
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(dishes, id: \.0) { dish in
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dish.0).font(.system(size: 18, weight: .heavy))
                        Text(dish.1).font(.system(size: 12)).foregroundStyle(palette.muted)
                        Text("步骤：煎香 / 小火 / 收汁")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(palette.accentInk)
                    }
                    Spacer()
                    PrototypeAssetImage(name: dish.2)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .prototypeCard(cornerRadius: 24, padding: 12)
            }
        }
    }
}
