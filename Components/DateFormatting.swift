import Foundation

/// Cached date formatters to avoid repeated allocation in view rendering loops.
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

    /// Parse ISO 8601 date string, trying fractional seconds first.
    static func parse(_ dateStr: String) -> Date? {
        isoParser.date(from: dateStr) ?? isoFallback.date(from: dateStr)
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
}
