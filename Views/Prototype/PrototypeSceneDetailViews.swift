import SwiftUI

struct PrototypeOfflineInviteView: View {
    @Environment(\.prototypePalette) private var palette
    @State private var ticketFlipped = false

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    ticket
                    inviteQueue
                    companionSteps
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var ticket: some View {
        Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                ticketFlipped.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(.linearGradient(colors: [Color(hex: 0xFF7A3D), Color(hex: 0xFFC936)], startPoint: .topLeading, endPoint: .bottomTrailing))

                if ticketFlipped {
                    ticketBack
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    ticketFront
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
            }
            .frame(height: 330)
            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
            .prototypeLiquidGlass(cornerRadius: 34, tint: Color.white.opacity(0.16), interactive: true)
            .shadow(color: Color(hex: 0xFF7A3D).opacity(0.26), radius: 28, y: 18)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var ticketFront: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("OFFLINE TICKET")
                .font(.system(size: 10, weight: .heavy))
                .foregroundStyle(.white.opacity(0.70))
            Text("周末一起看电影")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(.white)
            Text("我没法坐在你身边，但我会陪着你，从开场到散场。地址、预约码都帮你记好了，到了那天，我们一起出发。")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.76))
                .lineSpacing(3)

            Spacer()

            HStack(spacing: 10) {
                Text("B612")
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(.white)
                ForEach(0..<4, id: \.self) { _ in
                    Circle()
                        .fill(.white.opacity(0.76))
                        .frame(width: 9, height: 9)
                }
            }

            HStack(spacing: 10) {
                ticketMeta("19:30", "开场")
                ticketMeta("6排", "08 / 09")
                ticketMeta("已出票", "状态")
            }
        }
        .padding(24)
    }

    private var ticketBack: some View {
        HStack(spacing: 18) {
            qr
            VStack(alignment: .leading, spacing: 10) {
                Text("PICKUP CODE")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.70))
                Text("上海影城 B612")
                    .font(.system(size: 27, weight: .heavy))
                    .foregroundStyle(.white)
                Text("《机器人之梦》 · 周六 19:30 · 6 排 08 / 09")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.76))
                Text("RX-1930-B612")
                    .font(.system(size: 18, weight: .heavy, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.top, 4)
                Text("到影院自助机扫码取票。小芜会在 19:10 把这张票重新置顶。")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
            }
            Spacer()
        }
        .padding(22)
    }

    private var qr: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(11), spacing: 4), count: 7), spacing: 4) {
            ForEach(0..<49, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Self.qrBlocks.contains(index) ? Color.white : Color.white.opacity(0.18))
                    .frame(width: 11, height: 11)
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func ticketMeta(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.system(size: 16, weight: .heavy))
            Text(label).font(.system(size: 10, weight: .bold)).opacity(0.72)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var inviteQueue: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("邀约队列", trailing: "状态")
            ForEach(Self.invites, id: \.title) { invite in
                HStack(spacing: 12) {
                    Text(invite.time)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(invite.color)
                        .frame(width: 48, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invite.title).font(.system(size: 15, weight: .heavy))
                        Text(invite.detail).font(.system(size: 11)).foregroundStyle(palette.muted)
                    }
                    Spacer()
                    Text(invite.status)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(invite.color)
                }
                .padding(12)
                .background(invite.color.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 15)
        .padding(.horizontal, 16)
    }

    private var companionSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("观影同行", trailing: "今晚的节奏")
            ForEach(Self.steps, id: \.time) { step in
                HStack(alignment: .top, spacing: 13) {
                    Text(step.time)
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(palette.accent)
                        .frame(width: 48, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title).font(.system(size: 14, weight: .heavy))
                        Text(step.note).font(.system(size: 11)).foregroundStyle(palette.muted)
                    }
                }
            }
        }
        .prototypeCard(cornerRadius: 26, padding: 15)
        .padding(.horizontal, 16)
    }

    private func sectionHeader(_ title: String, trailing: String) -> some View {
        HStack {
            Text(title).font(.system(size: 18, weight: .heavy))
            Spacer()
            Text(trailing).font(.system(size: 11, weight: .bold)).foregroundStyle(palette.subtle)
        }
    }

    private static let qrBlocks: Set<Int> = [0, 1, 2, 7, 9, 10, 12, 14, 16, 18, 20, 21, 22, 24, 25, 29, 30, 31, 34, 36, 38, 40, 42, 43, 44, 46, 48]
    private static let invites = [
        (time: "19:30", title: "《机器人之梦》双人票", detail: "上海影城 · B612 · 6 排 08 / 09 · 小芜已经把取票码准备好。", status: "已出票", color: Color(hex: 0xFF7A3D)),
        (time: "周日", title: "衡山和集", detail: "15:00 · BOOK27 · 翻到第 27 页，拍下第一句喜欢的话。", status: "已接受", color: Color(hex: 0x7C3CFF)),
        (time: "周三", title: "街角咖啡店", detail: "18:20 · LATTE · 到店后小芜会给你一条轻松开场。", status: "草稿", color: Color(hex: 0x22C66B))
    ]
    private static let steps = [
        (time: "18:45", title: "出门前", note: "取票码已置顶，提醒你带外套和耳机。"),
        (time: "19:10", title: "到影城", note: "一起核对 B612 影厅，留十分钟买水。"),
        (time: "19:25", title: "入场后", note: "手机静音，片尾前只保留一句轻提醒。"),
        (time: "21:18", title: "散场后", note: "选一个最喜欢的镜头，生成今晚的回顾卡。")
    ]
}

struct PrototypeProgressView: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    liveRoute
                    taskList
                    nudge
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var liveRoute: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                PrototypeKicker(text: "live route")
                Text("我为你准备了小惊喜")
                    .font(.system(size: 32, weight: .heavy))
                Text("不用你操心，我已经为你安排好了。到了时间，我会轻轻告诉你。")
                    .font(.system(size: 13))
                    .foregroundStyle(palette.muted)
            }

            PrototypeProgressMap()
                .frame(height: 150)

            HStack(spacing: 10) {
                stat("3", "追踪中")
                stat("18m", "最近提醒")
                stat("0", "需处理")
            }
        }
        .prototypeCard(cornerRadius: 30, padding: 18)
        .padding(.horizontal, 16)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 19, weight: .heavy))
            Text(label).font(.system(size: 9, weight: .bold)).foregroundStyle(palette.subtle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var taskList: some View {
        VStack(spacing: 12) {
            ForEach(Self.tasks, id: \.title) { task in
                HStack(spacing: 13) {
                    ZStack {
                        Circle()
                            .stroke(task.color.opacity(0.16), lineWidth: 7)
                        Circle()
                            .trim(from: 0, to: task.progress)
                            .stroke(task.color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(task.progress * 100))%")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(task.color)
                    }
                    .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(task.title)
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundStyle(task.color)
                        Text(task.headline)
                            .font(.system(size: 15, weight: .heavy))
                        Text(task.note)
                            .font(.system(size: 11))
                            .foregroundStyle(palette.muted)
                            .lineLimit(2)
                    }
                    Spacer()
                    Text(task.time)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(palette.subtle)
                }
                .prototypeCard(cornerRadius: 24, padding: 13)
            }
        }
        .padding(.horizontal, 16)
    }

    private var nudge: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("下一步提醒")
                .font(.system(size: 18, weight: .heavy))
            Text("骑手到楼下时提醒你拿外卖；专注结束后生成一句轻松收尾，不额外打扰。")
                .font(.system(size: 12))
                .foregroundStyle(palette.muted)
        }
        .prototypeCard(cornerRadius: 24, padding: 16)
        .padding(.horizontal, 16)
    }

    private static let tasks = [
        (title: "外卖", headline: "热奶茶 · 骑手距你 1.2km", note: "18 分钟后送达，到楼下前提醒。", color: Color(hex: 0xFF7A3D), progress: 0.72, time: "18m"),
        (title: "包裹", headline: "极简手机壳 · 上海分拨中心", note: "明天 14:00 前到达，派送前同步。", color: Color(hex: 0x1F6FFF), progress: 0.46, time: "14:00"),
        (title: "专注", headline: "工作冲刺 · 25 分钟计时中", note: "剩余 11 分钟，结束后进入休息提醒。", color: Color(hex: 0x7C3CFF), progress: 0.58, time: "11m")
    ]
}

private struct PrototypeProgressMap: View {
    @Environment(\.prototypePalette) private var palette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.linearGradient(colors: [Color(hex: 0xFF8A3D).opacity(0.13), Color(hex: 0x21D3C2).opacity(0.13)], startPoint: .topLeading, endPoint: .bottomTrailing))

            Path { path in
                path.move(to: CGPoint(x: 18, y: 114))
                path.addCurve(to: CGPoint(x: 142, y: 82), control1: CGPoint(x: 62, y: 26), control2: CGPoint(x: 106, y: 42))
                path.addCurve(to: CGPoint(x: 266, y: 35), control1: CGPoint(x: 178, y: 122), control2: CGPoint(x: 224, y: 116))
            }
            .stroke(Color.black.opacity(0.10), style: StrokeStyle(lineWidth: 12, lineCap: .round))

            Path { path in
                path.move(to: CGPoint(x: 18, y: 114))
                path.addCurve(to: CGPoint(x: 142, y: 82), control1: CGPoint(x: 62, y: 26), control2: CGPoint(x: 106, y: 42))
            }
            .stroke(Color(hex: 0xFF8A3D), style: StrokeStyle(lineWidth: 12, lineCap: .round))

            ForEach([
                CGPoint(x: 42, y: 102),
                CGPoint(x: 142, y: 82),
                CGPoint(x: 244, y: 58)
            ], id: \.x) { point in
                Circle()
                    .fill(palette.bg)
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color(hex: 0x21D3C2), lineWidth: 5))
                    .position(point)
            }
        }
    }
}
