import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Level badge + type + source
                HStack {
                    Text(memory.levelLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(memory.levelColor)
                        .clipShape(Capsule())

                    if !memory.typeLabel.isEmpty {
                        Text(memory.typeLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

                    Text(memory.sourceLabel)
                        .font(.caption)
                        .foregroundStyle(memory.isAIMemory ? .purple : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(memory.isAIMemory ? Color.purple.opacity(0.1) : Color.clear)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Spacer()
                }

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    if let summary = memory.summary, !summary.isEmpty {
                        Text(String(localized: "摘要"))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(summary)
                            .font(.body)
                    }

                    Text(String(localized: "原文"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                    Text(memory.content)
                        .font(.body)
                }
                .glassCard()

                // Metadata
                VStack(spacing: 12) {
                    MetadataRow(label: String(localized: "来源"),
                                value: memory.sourceLabel)
                    if !memory.typeLabel.isEmpty {
                        MetadataRow(label: String(localized: "类型"),
                                    value: memory.typeLabel)
                    }
                    MetadataRow(label: String(localized: "重要度"),
                                value: String(format: "%.0f%%", memory.importance * 100))
                    MetadataRow(label: String(localized: "创建时间"),
                                value: DateFormatting.detail(memory.createdAt))
                    if let similarity = memory.similarity {
                        MetadataRow(label: String(localized: "相似度"),
                                    value: String(format: "%.1f%%", similarity * 100))
                    }
                }
                .glassCard()
            }
            .padding()
        }
        .navigationTitle(String(localized: "记忆详情"))
        .navigationBarTitleDisplayMode(.inline)
        .gradientBackground()
    }

}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }
}
