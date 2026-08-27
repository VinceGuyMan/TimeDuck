// MARK: - TimeDuck · Formatting.swift
// Precise string formatters for stopwatch, countdown, pomodoro, and statistics.

import Foundation

enum Fmt {
    /// Formats stopwatch intervals: "MM:SS.cc" under an hour, "H:MM:SS.cc" for one hour and above.
    static func sw(_ t: TimeInterval) -> String {
        let isNeg = t < 0
        var x = abs(t)
        let cs = Int((x * 100).rounded(.down)) % 100
        x -= Double(cs) / 100.0
        let totalSeconds = Int(x)
        let s = totalSeconds % 60
        let m = (totalSeconds / 60) % 60
        let h = totalSeconds / 3600
        let base = h > 0
            ? String(format: "%d:%02d:%02d.%02d", h, m, s, cs)
            : String(format: "%02d:%02d.%02d", m, s, cs)
        return isNeg ? "-" + base : base
    }

    /// Formats timer countdown intervals: "MM:SS", "H:MM:SS". Shows tenths/hundredths under 10 seconds or in drama mode.
    static func tm(_ t: TimeInterval, drama: Bool = false) -> String {
        let x = max(0, t)
        if drama || x < 10.0 {
            let s = floor(x)
            let frac = Int(((x - s) * (x < 1.0 ? 100 : 10)).rounded(.down))
            let pad = x < 1.0 ? 2 : 1
            let totalSeconds = Int(s)
            let sec = totalSeconds % 60
            let m = (totalSeconds / 60) % 60
            let h = totalSeconds / 3600
            if h > 0 {
                return String(format: "%d:%02d:%02d.%0*d", h, m, sec, pad, frac)
            }
            return String(format: "%d:%02d.%0*d", m, sec, pad, frac)
        }
        let whole = Int(x.rounded(.up))
        let h = whole / 3600
        let m = (whole % 3600) / 60
        let s = whole % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    /// Lap split formatting (identical to stopwatch resolution).
    static func lapSplit(_ t: TimeInterval) -> String {
        sw(t)
    }

    /// Formats minutes and seconds: "M:SS".
    static func hm(_ t: TimeInterval) -> String {
        let s = max(0, Int(t.rounded()))
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    /// Human-friendly duration: "Xh Ym", "Xh", "Ym".
    static func durationWords(_ t: TimeInterval) -> String {
        let totalMins = max(0, Int(t / 60))
        let hrs = totalMins / 60
        let mins = totalMins % 60
        if hrs > 0 {
            return mins > 0 ? "\(hrs)h \(mins)m" : "\(hrs)h"
        }
        return "\(mins)m"
    }

    /// Parses user-typed duration strings into seconds.
    /// Supported formats:
    /// - "5" or "5m" -> 5 minutes (300s) [plain integer/decimal without ':' is interpreted as minutes]
    /// - "30s" or ":30" or "0:30" -> 30 seconds
    /// - "5:30" -> 5 minutes 30 seconds (330s)
    /// - "1:30:00" -> 1 hour 30 minutes 0 seconds (5400s)
    /// - "1h" or "1h30m" -> 1 hour (3600s) or 1h 30m (5400s)
    /// Returns clamped non-negative TimeInterval (clamped between 5s and 99h 59m 59s), or nil if invalid.
    static func parseDuration(_ raw: String) -> TimeInterval? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return nil }

        // 1. Compound unit formats: "1h30m", "10m", "45s"
        let unitRegexPattern = "^(?:(\\d+(?:\\.\\d+)?)\\s*h)?\\s*(?:(\\d+(?:\\.\\d+)?)\\s*m)?\\s*(?:(\\d+(?:\\.\\d+)?)\\s*s)?$"
        if let regex = try? NSRegularExpression(pattern: unitRegexPattern, options: []),
           let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: trimmed.utf16.count)),
           trimmed.contains(where: { $0 == "h" || $0 == "m" || $0 == "s" }) {
            var totalSecs: Double = 0
            var matched = false
            let ns = trimmed as NSString
            if match.range(at: 1).location != NSNotFound {
                let hStr = ns.substring(with: match.range(at: 1))
                if let h = Double(hStr), h >= 0 { totalSecs += h * 3600; matched = true }
            }
            if match.range(at: 2).location != NSNotFound {
                let mStr = ns.substring(with: match.range(at: 2))
                if let m = Double(mStr), m >= 0 { totalSecs += m * 60; matched = true }
            }
            if match.range(at: 3).location != NSNotFound {
                let sStr = ns.substring(with: match.range(at: 3))
                if let s = Double(sStr), s >= 0 { totalSecs += s; matched = true }
            }
            if matched && totalSecs > 0 {
                return min(max(5, totalSecs), 99 * 3600 + 3599)
            }
        }

        // 2. Colon-separated formats: ":30", "5:30", "1:30:00"
        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":", omittingEmptySubsequences: false).map(String.init)
            if parts.count == 2 {
                let minStr = parts[0].isEmpty ? "0" : parts[0]
                let secStr = parts[1]
                guard let m = Double(minStr), let s = Double(secStr), m >= 0, s >= 0, s < 60 else { return nil }
                let secs = m * 60 + s
                guard secs > 0 else { return nil }
                return min(max(5, secs), 99 * 3600 + 3599)
            } else if parts.count == 3 {
                let hrStr = parts[0].isEmpty ? "0" : parts[0]
                let minStr = parts[1]
                let secStr = parts[2]
                guard let h = Double(hrStr), let m = Double(minStr), let s = Double(secStr),
                      h >= 0, m >= 0, s >= 0, m < 60, s < 60 else { return nil }
                let secs = h * 3600 + m * 60 + s
                guard secs > 0 else { return nil }
                return min(max(5, secs), 99 * 3600 + 3599)
            }
            return nil
        }

        // 3. Plain numeric: default to minutes (e.g. "5" -> 5m, "0.5" -> 30s)
        if let val = Double(trimmed), val > 0 {
            let secs = val * 60.0
            return min(max(5, secs), 99 * 3600 + 3599)
        }

        return nil
    }
}
