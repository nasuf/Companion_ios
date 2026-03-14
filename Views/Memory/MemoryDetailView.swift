import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory

    private var levelColor: Color {
        switch memory.level {
        case 1: return .red
        case 2: return .orange
        default: return .blue
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Level badge + type
                HStack {
                    Text(memory.levelLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(levelColor)
                        .clipShape(Capsule())

                    if let type = memory.type {
                        Text(type)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

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
                    MetadataRow(label: String(localized: "重要度"),
                                value: String(format: "%.0f%%", memory.importance * 100))
                    MetadataRow(label: String(localized: "创建时间"),
                                value: formatDate(memory.createdAt))
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

    private func formatDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) ?? ISO8601DateFormatter().date(from: dateStr) else {
            return dateStr
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: date)
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
