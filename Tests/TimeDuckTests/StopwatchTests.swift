// MARK: - TimeDuck · StopwatchTests.swift

import Foundation

enum StopwatchTests {
    static func runAll() {
        print("")
        print("▸ Testing Stopwatch Engine & Laps…")

        runTest("testStopwatchInitialState") {
            let sw = StopwatchModel()
            assertFalse(sw.isRunning)
            assertEqual(sw.elapsed, 0)
            assertTrue(sw.laps.isEmpty)
        }

        runTest("testStopwatchStartPauseResume") {
            let sw = StopwatchModel()
            let t0 = Date()

            sw.start(now: t0)
            assertTrue(sw.isRunning)
            assertEqual(sw.elapsed(at: t0), 0, accuracy: 0.001)

            // Advance 12.5 seconds
            let t1 = t0.addingTimeInterval(12.5)
            assertEqual(sw.elapsed(at: t1), 12.5, accuracy: 0.001)

            // Stop at t1
            sw.stop(now: t1)
            assertFalse(sw.isRunning)
            assertEqual(sw.banked, 12.5, accuracy: 0.001)

            // Advance 10 seconds while stopped
            let t2 = t1.addingTimeInterval(10.0)
            assertEqual(sw.elapsed(at: t2), 12.5, accuracy: 0.001)

            // Resume at t2
            sw.start(now: t2)
            assertTrue(sw.isRunning)

            // Advance 5.5 seconds after resume
            let t3 = t2.addingTimeInterval(5.5)
            assertEqual(sw.elapsed(at: t3), 18.0, accuracy: 0.001)
        }

        runTest("testStopwatchLaps") {
            let sw = StopwatchModel()
            let t0 = Date()
            sw.start(now: t0)

            // Lap 1 at +5s
            let t1 = t0.addingTimeInterval(5.0)
            let lap1 = sw.lap(now: t1)
            assertNotNil(lap1)
            assertEqual(lap1?.index ?? 0, 1)
            assertEqual(lap1?.split ?? 0, 5.0, accuracy: 0.001)
            assertEqual(lap1?.total ?? 0, 5.0, accuracy: 0.001)

            // Immediate double tap should be ignored
            let lapDup = sw.lap(now: t1)
            assertNil(lapDup)

            // Lap 2 at +13s (split = 8s)
            let t2 = t0.addingTimeInterval(13.0)
            let lap2 = sw.lap(now: t2)
            assertNotNil(lap2)
            assertEqual(lap2?.index ?? 0, 2)
            assertEqual(lap2?.split ?? 0, 8.0, accuracy: 0.001)
            assertEqual(lap2?.total ?? 0, 13.0, accuracy: 0.001)

            assertEqual(sw.laps.count, 2)
        }

        runTest("testStopwatchReset") {
            let sw = StopwatchModel()
            let t0 = Date()
            sw.start(now: t0)
            sw.lap(now: t0.addingTimeInterval(5.0))
            sw.stop(now: t0.addingTimeInterval(10.0))

            assertEqual(sw.laps.count, 1)
            assertEqual(sw.banked, 10.0, accuracy: 0.001)

            sw.reset()
            assertFalse(sw.isRunning)
            assertEqual(sw.banked, 0)
            assertEqual(sw.elapsed, 0)
            assertTrue(sw.laps.isEmpty)
        }

        runTest("testStopwatchRestoreState") {
            let sw = StopwatchModel()
            let t0 = Date()
            let startAnchor = t0.addingTimeInterval(-10.0) // started 10s ago

            sw.restoreState(
                banked: 20.0,
                running: true,
                startAnchor: startAnchor,
                splits: [10.0, 10.0],
                totals: [10.0, 20.0]
            )

            assertTrue(sw.isRunning)
            assertEqual(sw.laps.count, 2)
            assertEqual(sw.elapsed(at: t0), 30.0, accuracy: 0.001)
        }
    }
}
