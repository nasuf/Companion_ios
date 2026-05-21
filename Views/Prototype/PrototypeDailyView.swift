import SwiftUI

struct PrototypeDailyView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var activeTab: PrototypeDailyTab
    @State private var photoViewer: DailyPhotoViewerState?

    init(initialTab: PrototypeDailyTab) {
        _activeTab = State(initialValue: initialTab)
    }

    var body: some View {
        PrototypeScreen(showsBottomPadding: false, backgroundStyle: .daily) {
            ZStack {
                DailyAura(accent: meta.accent, accent2: meta.accent2)

                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
                        PrototypeDetailActions(shareAction: {})
                            .padding(.top, 12)

                        DailyIntro()
                            .padding(.horizontal, 26)

                        Section {
                            DailyHeroBoard(meta: meta)
                                .padding(.horizontal, 16)

                            content
                                .padding(.horizontal, 16)
                        } header: {
                            DailyTabBar(activeTab: $activeTab, meta: meta)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.clear)
                                .zIndex(40)
                        }
                    }
                    .padding(.bottom, 42)
                }
            }
        }
        .fullScreenCover(item: $photoViewer) { viewer in
            DailyPhotoViewer(
                group: viewer.group,
                initialIndex: viewer.initialIndex
            )
        }
    }

    @ViewBuilder
    private var content: some View {
        switch activeTab {
        case .photo:
            DailyPhotoContent(groups: Self.photoGroups) { group, index in
                photoViewer = DailyPhotoViewerState(group: group, initialIndex: index)
            }
        case .book:
            DailyBookContent(items: Self.books, accent: meta.accent)
        case .film:
            DailyFilmContent(films: Self.films)
        case .food:
            DailyFoodContent(dishes: Self.dishes, accent: meta.accent)
        }
    }

    private var meta: DailyTabMeta {
        Self.metas[activeTab] ?? Self.metas[.photo]!
    }

    private static let metas: [PrototypeDailyTab: DailyTabMeta] = [
        .photo: DailyTabMeta(
            tab: .photo,
            accent: Color(hex: 0x1F6FFF),
            accent2: Color(hex: 0x18C6C0),
            image: "unsplash-1500530855697-b586d89ba3ee.jpg",
            kicker: "photo diary",
            title: "把照片整理成一句自然分享",
            description: "照片分享不需要长文案，保留画面、时间和一句像朋友会说的话就够了。",
            chip: "32 张照片"
        ),
        .book: DailyTabMeta(
            tab: .book,
            accent: Color(hex: 0x7C3CFF),
            accent2: Color(hex: 0xFF8A3D),
            image: "daily-journal.jpg",
            kicker: "reading notes",
            title: "把读到的一句，变成能聊下去的话",
            description: "书摘不只是复制文字，小芜会帮你保留出处、情绪和想发给对方的语气。",
            chip: "5 本书"
        ),
        .film: DailyTabMeta(
            tab: .film,
            accent: Color(hex: 0xFF6A3D),
            accent2: Color(hex: 0x1F6FFF),
            image: "movie-bouquet.jpg",
            kicker: "watch list",
            title: "看完一幕，就留下一句观后感",
            description: "影视内容更适合做成片单、台词和观后聊题，不像书摘那样安静。",
            chip: "5 部影片"
        ),
        .food: DailyTabMeta(
            tab: .food,
            accent: Color(hex: 0x22C66B),
            accent2: Color(hex: 0xFFBE3D),
            image: "unsplash-1512621776951-a57141f2eefd.jpg",
            kicker: "taste card",
            title: "把一顿饭，记成今天的味道",
            description: "美食分享要带菜名、口味和做法，像一张能回看的生活小票。",
            chip: "5 道菜"
        )
    ]

    private static let photoGroups = [
        DailyPhotoGroupData(title: "傍晚光线", subtitle: "适合一句很短的晚安。", count: "7 张", images: [
            "unsplash-1500530855697-b586d89ba3ee-2.jpg",
            "unsplash-1500534314209-a25ddb2bd429.jpg",
            "unsplash-1493246507139-91e8fad9978e.jpg",
            "unsplash-1506744038136-46273834b3fb.jpg",
            "unsplash-1470770841072-f978cf4d019e.jpg"
        ]),
        DailyPhotoGroupData(title: "桌面碎片", subtitle: "咖啡、书页、拍立得和没收好的耳机。", count: "12 张", images: [
            "daily-journal.jpg",
            "unsplash-1499750310107-5fef28a66643.jpg",
            "unsplash-1516321318423-f06f85e504b3.jpg",
            "unsplash-1515378791036-0648a3ef77b2.jpg",
            "unsplash-1518005020951-eccb494ad742.jpg"
        ]),
        DailyPhotoGroupData(title: "路上看到", subtitle: "可以整理成一张“今天经过这里”的卡。", count: "5 张", images: [
            "unsplash-1519681393784-d120267933ba.jpg",
            "unsplash-1481277542470-605612bd2d61.jpg",
            "unsplash-1477959858617-67f85cf4f1df.jpg",
            "unsplash-1500534314209-a25ddb2bd429.jpg",
            "unsplash-1511818966892-d7d671e672a2.jpg"
        ]),
        DailyPhotoGroupData(title: "小物件", subtitle: "不用解释也能知道今天怎么过的。", count: "8 张", images: [
            "unsplash-1515879218367-8466d910aaa4.jpg",
            "unsplash-1513519245088-0e12902e5a38.jpg",
            "unsplash-1484480974693-6ca0a78fb36b.jpg",
            "unsplash-1516035069371-29a1b244cc32.jpg"
        ])
    ]

    private static let books = [
        DailyBookItem(title: "《海边的卡夫卡》", author: "村上春树", note: "一个关于离开、寻找和自我确认的故事，适合在情绪还没完全落地的时候慢慢读。", thought: "小芜的思考：这本书不是鼓励逃走，而是在问你要怎么带着自己继续往前。", summary: "分享摘要：暴风雨会过去，但穿过去的人会变得不一样。"),
        DailyBookItem(title: "《也许你该找个人聊聊》", author: "洛莉·戈特利布", note: "把咨询室里的真实片段写得很轻，没有说教感，适合和小芜一起拆情绪。", thought: "小芜的思考：很多困住人的不是事件本身，而是我们反复讲给自己的版本。", summary: "分享摘要：如果今天不想解释太多，也可以先承认自己有点累。"),
        DailyBookItem(title: "《悉达多》", author: "赫尔曼·黑塞", note: "更像一段缓慢的内在旅程，适合做成短摘录，不适合硬聊大道理。", thought: "小芜的思考：有些答案不是被说服来的，是生活慢慢把它递给你。", summary: "分享摘要：今晚先不追答案，先把心放慢一点。"),
        DailyBookItem(title: "《蛤蟆先生去看心理医生》", author: "罗伯特·戴博德", note: "用童话式人物讲情绪整理，适合拆成“今天为什么突然低落”的轻讨论。", thought: "小芜的思考：难受不一定要立刻解决，先知道它从哪里来。", summary: "分享摘要：我可能不是矫情，只是太久没认真照顾自己。"),
        DailyBookItem(title: "《深夜食堂》", author: "安倍夜郎", note: "每篇都很短，适合从一道食物聊到一个人，也适合做成睡前分享。", thought: "小芜的思考：食物有时候不是重点，重点是有人愿意听你把一天讲完。", summary: "分享摘要：今天想被一碗热的东西安慰一下。")
    ]

    private static let films = [
        DailyFilmItem(title: "花束般的恋爱", image: "movie-bouquet.jpg", note: "两个认真生活的人走到一起，又慢慢错开。适合生成一段不夸张的观后感。", tags: ["菅田将晖", "有村架纯", "恋爱"]),
        DailyFilmItem(title: "海街日记", image: "movie-poster.jpg", note: "节奏很慢，但很适合做成共同观影后的轻聊天。", tags: ["绫濑遥", "长泽雅美", "家庭"]),
        DailyFilmItem(title: "大都会", image: "movie-metropolis.jpg", note: "画面强烈，适合整理成“今晚看到的一幕”而不是长影评。", tags: ["Fritz Lang", "科幻", "默片"]),
        DailyFilmItem(title: "寻子遇仙记", image: "movie-the-kid.jpg", note: "轻喜剧更适合发一句“今晚先笑一下”，不用解释太多。", tags: ["Charlie Chaplin", "喜剧", "默片"]),
        DailyFilmItem(title: "卡里加里博士的小屋", image: "movie-caligari.jpg", note: "更像夜晚的奇怪梦，适合收藏成一张氛围片单。", tags: ["Robert Wiene", "表现主义", "悬疑"])
    ]

    private static let dishes = [
        DailyFoodItem(title: "番茄牛腩饭", note: "番茄炒出沙，牛腩小火收汁，最后浇在热米饭上。适合记录成“今天把自己喂好了”。", recipe: "步骤：煎香洋葱 / 加番茄和牛腩 / 小火 28 分钟 / 收汁", image: "unsplash-1546069901-ba9599a7e63c.jpg"),
        DailyFoodItem(title: "桂花拿铁", note: "咖啡味轻，桂花香明显，适合下午困的时候。分享时可以带一句“今天被一杯甜的救了一下”。", recipe: "配方：浓缩咖啡 / 牛奶 / 桂花蜜 / 少冰", image: "unsplash-1509042239860-f550ce710b93.jpg"),
        DailyFoodItem(title: "清爽拌面", note: "不重油，适合晚上不想点外卖时的轻食。可以生成一张菜谱卡。", recipe: "步骤：煮面 6 分钟 / 过冷水 / 加黄瓜丝和酱汁", image: "unsplash-1512621776951-a57141f2eefd-2.jpg"),
        DailyFoodItem(title: "莓果酸奶碗", note: "蓝莓和坚果铺在酸奶上，适合作为早晨第一张轻分享。", recipe: "步骤：酸奶打底 / 加莓果 / 撒燕麦和坚果 / 淋蜂蜜", image: "unsplash-1488477181946-6428a0291777.jpg"),
        DailyFoodItem(title: "周末烤吐司", note: "黄油边缘烤到微焦，适合配一句“今天慢一点”。", recipe: "步骤：厚切吐司 / 抹黄油 / 烤 6 分钟 / 加果酱", image: "unsplash-1484723091739-30a097e8f929.jpg")
    ]
}

private struct DailyTabMeta {
    let tab: PrototypeDailyTab
    let accent: Color
    let accent2: Color
    let image: String
    let kicker: String
    let title: String
    let description: String
    let chip: String
}

private struct DailyAura: View {
    let accent: Color
    let accent2: Color

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: 0xFF7940).opacity(0.18),
                                Color(hex: 0x7C3CFF).opacity(0.12),
                                accent.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 10)
                    .offset(
                        x: 120 + cos(time / 5.8) * 14,
                        y: -232 + sin(time / 5.8) * 18
                    )

                RoundedRectangle(cornerRadius: 160, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.10), accent2.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 260)
                    .blur(radius: 18)
                    .offset(
                        x: -146 + sin(time / 6.6) * 12,
                        y: 264 + cos(time / 6.6) * 16
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct DailyIntro: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PrototypeKicker(text: "daily board")
                .font(.system(size: 12, weight: .heavy))
            Text("你说的我都懂，你想的我都在")
                .font(.system(size: 34, weight: .heavy))
                .lineSpacing(-1)
                .frame(maxWidth: 320, alignment: .leading)
            Text("你向世界提问，我陪你一起找答案，我们都在彼此的陪伴里，慢慢变得更好")
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(4)
                .foregroundStyle(palette.muted)
                .frame(maxWidth: 316, alignment: .leading)
        }
    }
}

private struct DailyTabBar: View {
    @Binding var activeTab: PrototypeDailyTab
    let meta: DailyTabMeta
    @GestureState private var isTouching = false
    @Namespace private var tabGlassNamespace

    var body: some View {
        GeometryReader { proxy in
            let padding: CGFloat = 7
            let spacing: CGFloat = 6
            let options = PrototypeDailyTab.allCases
            let width = segmentWidth(totalWidth: proxy.size.width, padding: padding, spacing: spacing, count: options.count)

            ZStack(alignment: .leading) {
                DailyTabTrack()

                DailyTabSelectionPill(meta: meta, isTouching: isTouching, namespace: tabGlassNamespace)
                    .frame(width: width, height: 38)
                    .offset(x: padding + CGFloat(selectionIndex) * (width + spacing))

                HStack(spacing: spacing) {
                    ForEach(options) { tab in
                        Button {
                            select(tab)
                        } label: {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundStyle(activeTab == tab ? Color.white : Color(hex: 0x141E22).opacity(0.58))
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .contentShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .buttonStyle(.prototypeGlassPress)
                        .accessibilityLabel(tab.title)
                    }
                }
                .padding(padding)
            }
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isTouching) { _, state, _ in
                        state = true
                    }
                    .onChanged { value in
                        updateSelection(
                            at: value.location.x,
                            totalWidth: proxy.size.width,
                            padding: padding,
                            spacing: spacing
                        )
                    }
            )
        }
        .frame(height: 52)
        .shadow(color: Color(hex: 0x2C3448).opacity(0.08), radius: 22, y: 12)
        .sensoryFeedback(.selection, trigger: activeTab)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: activeTab)
    }

    private var selectionIndex: Int {
        PrototypeDailyTab.allCases.firstIndex(of: activeTab) ?? 0
    }

    private func segmentWidth(totalWidth: CGFloat, padding: CGFloat, spacing: CGFloat, count: Int) -> CGFloat {
        max(0, (totalWidth - padding * 2 - spacing * CGFloat(max(0, count - 1))) / CGFloat(max(1, count)))
    }

    private func select(_ tab: PrototypeDailyTab) {
        guard tab != activeTab else { return }
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            activeTab = tab
        }
    }

    private func updateSelection(at locationX: CGFloat, totalWidth: CGFloat, padding: CGFloat, spacing: CGFloat) {
        let options = PrototypeDailyTab.allCases
        guard !options.isEmpty else { return }
        let width = segmentWidth(totalWidth: totalWidth, padding: padding, spacing: spacing, count: options.count)
        let clamped = min(max(locationX - padding, 0), max(0, totalWidth - padding * 2))
        let raw = Int((clamped / max(1, width + spacing)).rounded(.down))
        let next = options[min(max(raw, 0), options.count - 1)]
        select(next)
    }
}

private struct DailyTabTrack: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.60))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.78), lineWidth: 1)
            )
            .prototypeLiquidGlass(cornerRadius: 22, tint: Color.white.opacity(0.24), interactive: true)
    }
}

private struct DailyTabSelectionPill: View {
    let meta: DailyTabMeta
    let isTouching: Bool
    let namespace: Namespace.ID

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 15, style: .continuous)
        shape
            .fill(
                LinearGradient(
                    colors: [meta.accent, meta.accent2],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(shape.stroke(Color.white.opacity(0.35), lineWidth: 1))
            .scaleEffect(isTouching ? 1.025 : 1)
            .shadow(color: meta.accent.opacity(isTouching ? 0.28 : 0.20), radius: isTouching ? 22 : 18, y: isTouching ? 10 : 8)
            .prototypeLiquidGlass(cornerRadius: 15, tint: meta.accent.opacity(isTouching ? 0.34 : 0.22), interactive: true)
            .modifier(DailyTabGlassID(namespace: namespace))
    }
}

private struct DailyTabGlassID: ViewModifier {
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffectID("daily-tab-selection", in: namespace)
        } else {
            content
        }
    }
}

private struct DailyHeroBoard: View {
    let meta: DailyTabMeta

    var body: some View {
        ZStack(alignment: .topLeading) {
            BreathingDailyImage(name: meta.image)
                .frame(height: 270)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.06),
                    Color.black.opacity(0.26),
                    Color.black.opacity(0.78)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [meta.accent.opacity(0.20), Color.clear],
                center: UnitPoint(x: 0.82, y: 0.18),
                startRadius: 0,
                endRadius: 140
            )
            .blendMode(.screen)

            VStack(alignment: .leading, spacing: 0) {
                DailyBoardMark(text: meta.kicker, accent: meta.accent)

                Spacer()
                    .frame(height: 48)

                Text(meta.title)
                    .font(.system(size: 26, weight: .heavy))
                    .lineSpacing(-1)
                    .foregroundStyle(.white)
                    .frame(maxWidth: 272, alignment: .leading)
                Text(meta.description)
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(3)
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(maxWidth: 266, alignment: .leading)
                    .padding(.top, 9)

                Spacer(minLength: 0)
            }
            .padding(20)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    DailyBoardChip(text: meta.chip)
                }
            }
            .padding(.trailing, 18)
            .padding(.bottom, 18)
            .allowsHitTesting(false)
        }
        .frame(height: 270)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.46), lineWidth: 1)
        )
        .shadow(color: meta.accent.opacity(0.20), radius: 30, y: 16)
    }
}

private struct DailyBoardMark: View {
    let text: String
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(accent)
                .frame(width: 8, height: 8)
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 22, height: 22)
                }
            Text(text.uppercased())
                .font(.system(size: 11, weight: .black))
        }
        .foregroundStyle(.white.opacity(0.94))
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(Color.white.opacity(0.22))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.34), lineWidth: 1))
        .prototypeLiquidGlass(cornerRadius: 16, tint: Color.white.opacity(0.12))
        .shadow(color: Color.black.opacity(0.10), radius: 10, y: 5)
    }
}

private struct DailyBoardChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 17)
            .frame(height: 38)
            .background(Color.white.opacity(0.20))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(0.28), lineWidth: 1))
            .prototypeLiquidGlass(cornerRadius: 19, tint: Color.white.opacity(0.12))
            .shadow(color: Color.black.opacity(0.12), radius: 12, y: 6)
    }
}

private struct BreathingDailyImage: View {
    let name: String
    @State private var breathes = false

    var body: some View {
        GeometryReader { proxy in
            PrototypeAssetImage(name: name)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(breathes ? 1.075 : 1.035)
                .offset(x: breathes ? 6 : -5, y: breathes ? -4 : 6)
                .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: breathes)
                .onAppear {
                    breathes = true
                }
        }
        .accessibilityHidden(true)
    }
}

private struct DailyPhotoContent: View {
    let groups: [DailyPhotoGroupData]
    let openPhoto: (DailyPhotoGroupData, Int) -> Void

    var body: some View {
        VStack(spacing: 20) {
            ForEach(groups, id: \.title) { group in
                DailyPhotoGroup(group: group, openPhoto: openPhoto)
            }
        }
    }
}

private struct DailyPhotoViewerState: Identifiable {
    let id = UUID()
    let group: DailyPhotoGroupData
    let initialIndex: Int
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
    let openPhoto: (DailyPhotoGroupData, Int) -> Void
    @State private var anchorIndex = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(group.title)
                        .font(.system(size: 22, weight: .heavy))
                    Text(group.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(palette.muted)
                }
                Spacer()
                Text("\(group.images.count) 张")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(palette.subtle)
            }

            ScrollViewReader { proxy in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 9) {
                            ForEach(Array(group.images.enumerated()), id: \.offset) { index, image in
                                Button {
                                    openPhoto(group, index)
                                } label: {
                                    PrototypeAssetImage(name: image)
                                        .frame(width: 108, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .shadow(color: Color(hex: 0x22364A).opacity(0.12), radius: 14, y: 8)
                                }
                                .buttonStyle(.prototypeGlassPress)
                                .accessibilityLabel("\(group.title) 第 \(index + 1) 张")
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 4)
                    }

                    HStack {
                        Button {
                            scrollPhotos(direction: -1, proxy: proxy)
                        } label: {
                            DailyRailButton(systemName: "chevron.left")
                        }
                        .buttonStyle(.prototypeGlassPress)
                        .accessibilityLabel("上一组照片")

                        Spacer()

                        Button {
                            scrollPhotos(direction: 1, proxy: proxy)
                        } label: {
                            DailyRailButton(systemName: "chevron.right")
                        }
                        .buttonStyle(.prototypeGlassPress)
                        .accessibilityLabel("下一组照片")
                    }
                    .padding(.horizontal, 7)
                }
            }
        }
    }

    private func scrollPhotos(direction: Int, proxy: ScrollViewProxy) {
        let maxIndex = max(group.images.count - 1, 0)
        anchorIndex = min(max(anchorIndex + direction * 2, 0), maxIndex)
        withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
            proxy.scrollTo(anchorIndex, anchor: .leading)
        }
    }
}

private struct DailyRailButton: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(.white.opacity(0.94))
            .frame(width: 34, height: 34)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x141A22).opacity(0.32), Color(hex: 0x141A22).opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.34), lineWidth: 1))
            .prototypeLiquidGlass(cornerRadius: 17, tint: Color.white.opacity(0.16))
            .shadow(color: Color(hex: 0x121C2A).opacity(0.18), radius: 12, y: 6)
    }
}

private struct DailyPhotoViewer: View {
    @Environment(\.dismiss) private var dismiss
    let group: DailyPhotoGroupData
    @State private var currentIndex: Int

    init(group: DailyPhotoGroupData, initialIndex: Int) {
        self.group = group
        _currentIndex = State(initialValue: min(max(initialIndex, 0), max(group.images.count - 1, 0)))
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 8)
                    .padding(.horizontal, 18)

                TabView(selection: $currentIndex) {
                    ForEach(Array(group.images.enumerated()), id: \.offset) { index, image in
                        PrototypeAssetImage(name: image, contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(index)
                            .accessibilityLabel("\(group.title) 第 \(index + 1) 张")
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.34, dampingFraction: 0.86), value: currentIndex)

                thumbnailStrip
            }
        }
        .preferredColorScheme(.dark)
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.10))
                    .clipShape(Circle())
                    .prototypeLiquidGlass(cornerRadius: 22, tint: Color.white.opacity(0.18), interactive: true)
            }
            .buttonStyle(.prototypeGlassPress)
            .accessibilityLabel("关闭")

            VStack(alignment: .leading, spacing: 3) {
                Text(group.title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                Text("\(currentIndex + 1) / \(group.images.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.58))
            }

            Spacer()
        }
    }

    private var thumbnailStrip: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 10) {
                Text(group.subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white.opacity(0.58))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 9) {
                        ForEach(Array(group.images.enumerated()), id: \.offset) { index, image in
                            Button {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    currentIndex = index
                                }
                            } label: {
                                PrototypeAssetImage(name: image)
                                    .frame(width: 54, height: 68)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(index == currentIndex ? Color.white : Color.white.opacity(0.20), lineWidth: index == currentIndex ? 2.5 : 1)
                                    )
                                    .opacity(index == currentIndex ? 1 : 0.62)
                                    .scaleEffect(index == currentIndex ? 1.05 : 1)
                            }
                            .buttonStyle(.prototypeGlassPress)
                            .id(index)
                            .accessibilityLabel("查看第 \(index + 1) 张")
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                }
            }
            .padding(.top, 14)
            .padding(.bottom, 24)
            .background(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.66),
                        Color.black.opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .bottom)
            )
            .onChange(of: currentIndex) { _, value in
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    proxy.scrollTo(value, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(currentIndex, anchor: .center)
            }
        }
    }
}

private struct DailyBookItem {
    let title: String
    let author: String
    let note: String
    let thought: String
    let summary: String
}

private struct DailyBookContent: View {
    let items: [DailyBookItem]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items, id: \.title) { item in
                DailyBookRow(item: item, accent: accent)
            }
        }
        .padding(.leading, 10)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(hex: 0x141E22).opacity(0.10))
                .frame(width: 1)
        }
    }
}

private struct DailyBookRow: View {
    @Environment(\.prototypePalette) private var palette
    let item: DailyBookItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(item.title)
                .font(.system(size: 19, weight: .heavy))
            Text(item.author)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(Color(hex: 0x141E22).opacity(0.44))
            Text(item.note)
                .font(.system(size: 12, weight: .regular))
                .lineSpacing(3)
                .foregroundStyle(palette.muted)
            DailyBookInsights(item: item, accent: accent)
                .padding(.top, 2)
        }
        .padding(.leading, 18)
        .padding(.vertical, 16)
        .overlay(alignment: .topLeading) {
            Circle()
                .fill(accent)
                .frame(width: 9, height: 9)
                .shadow(color: accent.opacity(0.18), radius: 0)
                .offset(x: -14, y: 25)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: 0x141E22).opacity(0.08))
                .frame(height: 1)
        }
    }
}

private struct DailyBookInsights: View {
    let item: DailyBookItem
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            DailyBookInsightLine(
                title: "小芜的思考",
                text: stripped(item.thought, prefix: "小芜的思考："),
                accent: accent
            )
            DailyBookInsightLine(
                title: "分享摘要",
                text: stripped(item.summary, prefix: "分享摘要："),
                accent: Color(hex: 0xFF8A3D)
            )
        }
    }

    private func stripped(_ value: String, prefix: String) -> String {
        value.hasPrefix(prefix) ? String(value.dropFirst(prefix.count)) : value
    }
}

private struct DailyBookInsightLine: View {
    let title: String
    let text: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 5) {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)
                Text(title)
                    .font(.system(size: 10, weight: .heavy))
            }
            .foregroundStyle(Color(hex: 0x141E22).opacity(0.66))
            .frame(width: 78, alignment: .leading)

            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .lineSpacing(2)
                .foregroundStyle(Color(hex: 0x141E22).opacity(0.64))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.52))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.58), lineWidth: 1)
                )
        )
    }
}

private struct DailyFilmItem {
    let title: String
    let image: String
    let note: String
    let tags: [String]
}

private struct DailyFilmContent: View {
    let films: [DailyFilmItem]

    var body: some View {
        VStack(spacing: 14) {
            ForEach(films, id: \.title) { film in
                DailyFilmRow(film: film)
            }
        }
    }
}

private struct DailyFilmRow: View {
    @Environment(\.prototypePalette) private var palette
    let film: DailyFilmItem

    var body: some View {
        HStack(spacing: 13) {
            PrototypeAssetImage(name: film.image)
                .frame(width: 78, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color(hex: 0x181F2A).opacity(0.16), radius: 16, y: 9)
            VStack(alignment: .leading, spacing: 8) {
                Text(film.title)
                    .font(.system(size: 18, weight: .heavy))
                Text(film.note)
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(3)
                    .foregroundStyle(palette.muted)
                HStack(spacing: 6) {
                    ForEach(film.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(Color(hex: 0x141E22).opacity(0.58))
                            .padding(.horizontal, 8)
                            .frame(height: 24)
                            .background(Color.white.opacity(0.62))
                            .clipShape(Capsule())
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }
}

private struct DailyFoodItem {
    let title: String
    let note: String
    let recipe: String
    let image: String
}

private struct DailyFoodContent: View {
    let dishes: [DailyFoodItem]
    let accent: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(dishes, id: \.title) { dish in
                DailyFoodRow(dish: dish, accent: accent)
            }
        }
    }
}

private struct DailyFoodRow: View {
    @Environment(\.prototypePalette) private var palette
    let dish: DailyFoodItem
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(dish.title)
                    .font(.system(size: 18, weight: .heavy))
                Text(dish.note)
                    .font(.system(size: 12, weight: .regular))
                    .lineSpacing(3)
                    .foregroundStyle(palette.muted)
                Text(dish.recipe)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(accent)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            PrototypeAssetImage(name: dish.image)
                .frame(width: 88, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: accent.opacity(0.18), radius: 16, y: 8)
        }
        .padding(.vertical, 13)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(hex: 0x141E22).opacity(0.07))
                .frame(height: 1)
        }
    }
}
