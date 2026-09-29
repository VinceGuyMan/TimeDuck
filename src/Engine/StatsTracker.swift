// MARK: - TimeDuck · StatsTracker.swift
// Daily focus stats, pomodoro session counting, and streak management.
// Tracks actual elapsed focus time without hardcoded duration assumptions.

import Foundation

final class StatsTracker: Codable {
    // Defensive persistence limits, intentionally well above realistic use.
    private static let maximumCount = 1_000_000
    private static let maximumFocusSeconds: TimeInterval = 360_000_000_000
    var todayFocusSeconds: TimeInterval = 0
    var todayPomodoros: Int = 0
    var streakDays: Int = 1
    var lastActiveDateStr: String = ""

    init() {
        lastActiveDateStr = StatsTracker.todayKey()
        checkDayRollover()
    }

    func restoreState(
        todayFocusSeconds: TimeInterval,
        todayPomodoros: Int,
        streakDays: Int,
        lastActiveDate: String
    ) {
        self.todayFocusSeconds = todayFocusSeconds.isFinite
            ? min(max(0, todayFocusSeconds), StatsTracker.maximumFocusSeconds)
            : 0
        self.todayPomodoros = min(max(0, todayPomodoros), StatsTracker.maximumCount)
        self.streakDays = min(max(1, streakDays), StatsTracker.maximumCount)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.isLenient = false
        if formatter.date(from: lastActiveDate) != nil {
            lastActiveDateStr = lastActiveDate
        } else {
            lastActiveDateStr = StatsTracker.todayKey()
        }
        checkDayRollover()
    }

    private static func todayKey(for date: Date = Date()) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.timeZone = Calendar.current.timeZone
        return fmt.string(from: date)
    }

    /// Checks if a new day has arrived and resets daily tallies.
    /// Does NOT update lastActiveDateStr — that is deferred to record methods
    /// so that the streak bump can detect the day crossing.
    func checkDayRollover(now: Date = Date()) {
        let today = StatsTracker.todayKey(for: now)
        if lastActiveDateStr.isEmpty {
            return
        }
        if lastActiveDateStr != today {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            fmt.timeZone = Calendar.current.timeZone
            if let lastDate = fmt.date(from: lastActiveDateStr) {
                let startOfLast = Calendar.current.startOfDay(for: lastDate)
                let startOfNow = Calendar.current.startOfDay(for: now)
                let diff = Calendar.current.dateComponents([.day], from: startOfLast, to: startOfNow).day ?? 0
                if diff > 1 {
                    streakDays = 1
                }
            }
            todayFocusSeconds = 0
            todayPomodoros = 0
        }
    }

    /// Records focus seconds from any focus session (custom or standard).
    /// Streak bump only on first positive activity after crossing to a consecutive day.
    func addFocusSeconds(_ secs: TimeInterval, now: Date = Date()) {
        let prevLast = lastActiveDateStr
        checkDayRollover(now: now)
        let wasFirstToday = (todayFocusSeconds == 0 && todayPomodoros == 0)
        let safeSeconds = secs.isFinite ? max(0, secs) : 0
        todayFocusSeconds = min(StatsTracker.maximumFocusSeconds, todayFocusSeconds + safeSeconds)
        lastActiveDateStr = StatsTracker.todayKey(for: now)

        if wasFirstToday && !prevLast.isEmpty && prevLast != lastActiveDateStr {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            fmt.timeZone = Calendar.current.timeZone
            if let lastDate = fmt.date(from: prevLast) {
                let startOfLast = Calendar.current.startOfDay(for: lastDate)
                let startOfNow = Calendar.current.startOfDay(for: now)
                let diff = Calendar.current.dateComponents([.day], from: startOfLast, to: startOfNow).day ?? 0
                if diff == 1 {
                    streakDays = min(StatsTracker.maximumCount, streakDays + 1)
                } else if diff > 1 {
                    streakDays = 1
                }
            }
        }
    }

    /// Records a completed Pomodoro session with its configured duration.
    func recordPomodoroCompleted(duration: TimeInterval = 25 * 60, now: Date = Date()) {
        let prevLast = lastActiveDateStr
        checkDayRollover(now: now)
        let wasFirstToday = (todayPomodoros == 0 && todayFocusSeconds == 0)
        todayPomodoros = min(StatsTracker.maximumCount, todayPomodoros + 1)
        let safeDuration = duration.isFinite ? max(0, duration) : 0
        todayFocusSeconds = min(StatsTracker.maximumFocusSeconds, todayFocusSeconds + safeDuration)
        lastActiveDateStr = StatsTracker.todayKey(for: now)

        if wasFirstToday && !prevLast.isEmpty && prevLast != lastActiveDateStr {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            fmt.timeZone = Calendar.current.timeZone
            if let lastDate = fmt.date(from: prevLast) {
                let startOfLast = Calendar.current.startOfDay(for: lastDate)
                let startOfNow = Calendar.current.startOfDay(for: now)
                let diff = Calendar.current.dateComponents([.day], from: startOfLast, to: startOfNow).day ?? 0
                if diff == 1 {
                    streakDays = min(StatsTracker.maximumCount, streakDays + 1)
                } else if diff > 1 {
                    streakDays = 1
                }
            }
        }
    }
}
