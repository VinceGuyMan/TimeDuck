// MARK: - TimeDuck · TimerEngineTests.swift

import Foundation

enum TimerEngineTests {
    static func runAll() {
        print("")
        print("▸ Testing Countdown Timer Engine…")

        runTest("testTimerInitialState") {
            let tm = TimerModel()
            assertFalse(tm.isRunning)
            assertEqual(tm.duration, 60)
            assertEqual(tm.remaining, 60)
            assertFalse(tm.finished)
        }

        runTest("testTimerStartPauseResume") {
            let tm = TimerModel()
            let t0 = Date()

            // Start timer (default 60s)
            tm.toggle(now: t0)
            assertTrue(tm.isRunning)
            assertEqual(tm.remaining(at: t0), 60, accuracy: 0.001)

            // Advance 10 seconds
            let t1 = t0.addingTimeInterval(10)
            assertEqual(tm.remaining(at: t1), 50, accuracy: 0.001)
            assertFalse(tm.isFinished(at: t1))

            // Pause timer at t1
            tm.toggle(now: t1)
            assertFalse(tm.isRunning)
            assertEqual(tm.remainingAtStop, 50, accuracy: 0.001)

            // Advance 20 seconds while paused
            let t2 = t1.addingTimeInterval(20)
            assertEqual(tm.remaining(at: t2), 50, accuracy: 0.001)

            // Resume at t2
            tm.toggle(now: t2)
            assertTrue(tm.isRunning)
            assertEqual(tm.remaining(at: t2), 50, accuracy: 0.001)

            // Advance 5 seconds after resume
            let t3 = t2.addingTimeInterval(5)
            assertEqual(tm.remaining(at: t3), 45, accuracy: 0.001)
        }

        runTest("testTimerExpiration") {
            let tm = TimerModel()
            let t0 = Date()
            tm.setDuration(10)
            tm.toggle(now: t0)

            let tNearEnd = t0.addingTimeInterval(9.5)
            assertFalse(tm.isFinished(at: tNearEnd))
            assertEqual(tm.remaining(at: tNearEnd), 0.5, accuracy: 0.001)

            let tEnd = t0.addingTimeInterval(10.0)
            assertTrue(tm.isFinished(at: tEnd))
            assertEqual(tm.remaining(at: tEnd), 0, accuracy: 0.001)

            let tPast = t0.addingTimeInterval(15.0)
            assertTrue(tm.isFinished(at: tPast))
            assertEqual(tm.remaining(at: tPast), 0, accuracy: 0.001)
        }

        runTest("testTimerSetDurationAndAdd") {
            let tm = TimerModel()
            tm.setDuration(600)
            assertEqual(tm.duration, 600)
            assertEqual(tm.remaining, 600)

            // Clamp lower bound to 5s
            tm.setDuration(2)
            assertEqual(tm.duration, 5)

            // Add delta while stopped
            tm.add(60)
            assertEqual(tm.duration, 65)
            assertEqual(tm.remaining, 65)

            // Add delta while running
            let t0 = Date()
            tm.toggle(now: t0)
            tm.add(60)
            assertEqual(tm.duration, 125)
            assertEqual(tm.remaining(at: t0), 125, accuracy: 0.001)
        }

        runTest("testTimerQuickAdjustments") {
            let tm = TimerModel()
            // Fresh state: 60s
            assertEqual(tm.duration, 60)

            // +10s
            tm.add(10)
            assertEqual(tm.duration, 70)

            // -10s
            tm.add(-10)
            assertEqual(tm.duration, 60)

            // +1m (60s)
            tm.add(60)
            assertEqual(tm.duration, 120)

            // -1m (60s)
            tm.add(-60)
            assertEqual(tm.duration, 60)

            // +5m (300s)
            tm.add(300)
            assertEqual(tm.duration, 360)

            // -5m (300s)
            tm.add(-300)
            assertEqual(tm.duration, 60)

            // Subtracting below 5s clamps to 5s
            tm.add(-100)
            assertEqual(tm.duration, 5)
        }

        runTest("testTimerRestartAndClear") {
            let tm = TimerModel()
            tm.setDuration(120)
            let t0 = Date()
            tm.toggle(now: t0)

            // Advance 30s
            let t1 = t0.addingTimeInterval(30)
            tm.toggle(now: t1)
            assertEqual(tm.remaining(at: t1), 90, accuracy: 0.001)

            // Restart
            tm.restart(now: t1)
            assertFalse(tm.isRunning)
            assertEqual(tm.remaining, 120)

            // Clear
            tm.clear()
            assertFalse(tm.isRunning)
            assertEqual(tm.duration, 60)
            assertEqual(tm.remaining, 60)
        }

        runTest("testTimerRestoreStateRunning") {
            let tm = TimerModel()
            let t0 = Date()
            let endWall = t0.addingTimeInterval(150)

            tm.restoreState(duration: 300, remainingAtStop: 150, running: true, endWall: endWall, completionRecorded: true)
            assertTrue(tm.isRunning)
            assertTrue(tm.completionRecorded)
            assertEqual(tm.duration, 300)
            assertEqual(tm.remaining(at: t0), 150, accuracy: 0.001)

            let tEnd = t0.addingTimeInterval(151)
            assertTrue(tm.isFinished(at: tEnd))
        }
    }
}
