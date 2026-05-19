import SwiftUI

struct MemoryDetailView: View {
    @Environment(\.prototypePalette) private var palette
    let memory: Memory

    var body: some View {
        PrototypeScreen(showsBottomPadding: false) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    PrototypeDetailActions()
                    header
                    contentCard
                    metadataCard
                }
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            PrototypeKicker(text: "memory detail")
            Text(memory.levelLabel)
                .font(.system(size: 32, weight: .heavy))
            HStack(spacing: 8) {
                badge(memory.sourceLabel, color: memory.prototypeDetailColor)
                if !memory.typeLabel.isEmpty {
                    badge(memory.typeLabel, color: palette.accent)
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let summary = memory.summary, !summary.isEmpty {
                textBlock(title: "摘要", content: summary)
            }
            textBlock(title: "原文", content: memory.content)
        }
        .prototypeCard(cornerRadius: 28, padding: 17)
        .padding(.horizontal, 16)
    }

    private var metadataCard: some View {
        VStack(spacing: 12) {
            metadata("来源", memory.sourceLabel)
            if !memory.typeLabel.isEmpty {
                metadata("类型", memory.typeLabel)
            }
            metadata("重要度", String(format: "%.0f%%", memory.importance * 100))
            metadata("创建时间", DateFormatting.detail(memory.createdAt))
            if let similarity = memory.similarity {
                metadata("相似度", String(format: "%.1f%%", similarity * 100))
            }
        }
        .prototypeCard(cornerRadius: 24, padding: 16)
        .padding(.horizontal, 16)
    }

    private func textBlock(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(palette.subtle)
            Text(content)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.fg)
                .lineSpacing(5)
        }
    }

    private func metadata(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(palette.muted)
            Spacer()
            Text(value)
                .foregroundStyle(palette.fg)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 13, weight: .semibold))
    }

    private func badge(_ title: String, color: Color) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 11)
            .frame(height: 28)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

private extension Memory {
    var prototypeDetailColor: Color {
        switch level {
        case 1: Color(hex: 0xFF6A3D)
        case 2: Color(hex: 0x1F6FFF)
        default: Color(hex: 0x4D8870)
        }
    }
}
