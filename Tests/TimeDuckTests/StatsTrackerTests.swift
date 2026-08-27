// MARK: - TimeDuck · StatsTrackerTests.swift

import Foundation

enum StatsTrackerTests {
    static func runAll() {
        print("")
        print("▸ Testing Focus Statistics & Daily Streaks…")

        runTest("testStatsInitialState") {
            let stats = StatsTracker()
            assertEqual(stats.todayFocusSeconds, 0)
            assertEqual(stats.todayPomodoros, 0)
            assertEqual(stats.streakDays, 1)
            assertFalse(stats.lastActiveDateStr.isEmpty)
        }

        runTest("testRecordPomodoroCustomDurations") {
            let stats = StatsTracker()
            let t0 = Date()

            // Record a standard 25m session (1500s)
            stats.recordPomodoroCompleted(duration: 25 * 60, now: t0)
            assertEqual(stats.todayPomodoros, 1)
            assertEqual(stats.todayFocusSeconds, 1500)

            // Record a deep work 50m session (3000s)
            stats.recordPomodoroCompleted(duration: 50 * 60, now: t0)
            assertEqual(stats.todayPomodoros, 2)
            assertEqual(stats.todayFocusSeconds, 4500)

            // Add custom 10m focus
            stats.addFocusSeconds(600, now: t0)
            assertEqual(stats.todayPomodoros, 2)
            assertEqual(stats.todayFocusSeconds, 5100)
        }

        runTest("testDayRolloverConsecutiveStreak") {
            let stats = StatsTracker()
            let cal = Calendar.current
            let t0 = Date()

            stats.recordPomodoroCompleted(duration: 25 * 60, now: t0)
            assertEqual(stats.todayPomodoros, 1)
            assertEqual(stats.todayFocusSeconds, 1500)
            assertEqual(stats.streakDays, 1)

            // Tomorrow (+1 day)
            guard let tomorrow = cal.date(byAdding: .day, value: 1, to: t0) else {
                TestSuiteContext.shared.recordFailure("Failed to compute tomorrow")
                return
            }

            // Record on tomorrow directly (cross + first activity inside record -> bump)
            stats.recordPomodoroCompleted(duration: 25 * 60, now: tomorrow)
            assertEqual(stats.todayPomodoros, 1)
            assertEqual(stats.streakDays, 2)
        }

        runTest("testDayRolloverBrokenStreak") {
            let stats = StatsTracker()
            let cal = Calendar.current
            let t0 = Date()

            stats.recordPomodoroCompleted(duration: 25 * 60, now: t0)
            stats.streakDays = 5

            // Skip 2 days (+2 days)
            guard let inTwoDays = cal.date(byAdding: .day, value: 2, to: t0) else {
                TestSuiteContext.shared.recordFailure("Failed to compute inTwoDays")
                return
            }

            stats.checkDayRollover(now: inTwoDays)
            assertEqual(stats.todayPomodoros, 0)
            assertEqual(stats.todayFocusSeconds, 0)
            assertEqual(stats.streakDays, 1)  // gap >1 resets (in check)
        }
    }
}
