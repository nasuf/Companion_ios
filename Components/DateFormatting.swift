import Foundation

/// Cached date formatters to avoid repeated allocation in view rendering loops.
/// All methods must be called from the main actor (DateFormatter is not thread-safe).
@MainActor
enum DateFormatting {
    private static let isoParser: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let isoFallback = ISO8601DateFormatter()

    private static let shortDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f
    }()

    private static let dateTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd HH:mm"
        return f
    }()

    private static let detailDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    private static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    /// Parse ISO 8601 date string. Also handles Python's `str(datetime)` format
    /// which uses a space instead of 'T' (e.g. "2026-03-20 10:15:06.579000+00:00").
    static func parse(_ dateStr: String) -> Date? {
        if let d = isoParser.date(from: dateStr) ?? isoFallback.date(from: dateStr) {
            return d
        }
        // Python str(datetime) uses space instead of T
        let normalized = dateStr.replacingOccurrences(of: " ", with: "T", range: dateStr.range(of: " "))
        return isoParser.date(from: normalized) ?? isoFallback.date(from: normalized)
    }

    /// "MM/dd" — for memory timeline cards
    static func short(_ dateStr: String) -> String {
        guard let date = parse(dateStr) else { return dateStr }
        return shortDate.string(from: date)
    }

    /// "MM/dd HH:mm" — for emotion timeline entries
    static func dateTime(_ dateStr: String) -> String {
        guard let date = parse(dateStr) else { return dateStr }
        return self.dateTime.string(from: date)
    }

    /// "yyyy-MM-dd HH:mm" — for memory detail view
    static func detail(_ dateStr: String) -> String {
        guard let date = parse(dateStr) else { return dateStr }
        return detailDate.string(from: date)
    }

    /// "HH:mm" — for message bubbles
    static func time(_ dateStr: String) -> String {
        guard let date = parse(dateStr) else { return "" }
        return timeOnly.string(from: date)
    }

    /// ISO 8601 string from current date — for creating local messages.
    /// Uses nonisolated helper since ISO8601DateFormatter is thread-safe.
    nonisolated static func nowISO() -> String {
        _isoWriter.string(from: Date())
    }

    // Separate instance for writing (nonisolated-safe since ISO8601DateFormatter is thread-safe)
    private nonisolated(unsafe) static let _isoWriter = ISO8601DateFormatter()
}
