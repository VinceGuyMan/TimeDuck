// MARK: - TimeDuck · StatsTracker.swift
// Daily focus stats, pomodoro session counting, and streak management.
// Tracks actual elapsed focus time without hardcoded duration assumptions.

import Foundation

final class StatsTracker: Codable {
    var todayFocusSeconds: TimeInterval = 0
    var todayPomodoros: Int = 0
    var streakDays: Int = 1
    var lastActiveDateStr: String = ""

    init() {
        lastActiveDateStr = StatsTracker.todayKey()
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
        todayFocusSeconds += max(0, secs)
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
                    streakDays += 1
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
        todayPomodoros += 1
        todayFocusSeconds += max(0, duration)
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
                    streakDays += 1
                } else if diff > 1 {
                    streakDays = 1
                }
            }
        }
    }
}
