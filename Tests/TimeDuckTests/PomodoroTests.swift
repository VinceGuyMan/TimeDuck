// MARK: - TimeDuck · PomodoroTests.swift

import Foundation

enum PomodoroTests {
    static func runAll() {
        print("")
        print("▸ Testing Pomodoro Focus Engine…")

        runTest("testPomodoroInitialState") {
            let pomo = PomodoroModel()
            assertEqual(pomo.phase, .work)
            assertEqual(pomo.cyclesCompleted, 0)
            assertEqual(pomo.workDuration, 25 * 60)
            assertEqual(pomo.shortBreakDuration, 5 * 60)
            assertEqual(pomo.longBreakDuration, 15 * 60)
            assertEqual(pomo.remaining, 25 * 60)
            assertFalse(pomo.isRunning)
        }

        runTest("testPomodoroCycleAdvancement") {
            let pomo = PomodoroModel()

            // Cycle 1: Work (25m) -> Short Break
            assertEqual(pomo.phase, .work)
            pomo.advancePhase()
            assertEqual(pomo.phase, .shortBreak)
            assertEqual(pomo.cyclesCompleted, 1)
            assertEqual(pomo.remaining, 5 * 60)

            // Short Break -> Work
            pomo.advancePhase()
            assertEqual(pomo.phase, .work)
            assertEqual(pomo.cyclesCompleted, 1)
            assertEqual(pomo.remaining, 25 * 60)

            // Cycle 2: Work -> Short Break
            pomo.advancePhase()
            assertEqual(pomo.phase, .shortBreak)
            assertEqual(pomo.cyclesCompleted, 2)

            // Short Break -> Work
            pomo.advancePhase()
            assertEqual(pomo.phase, .work)

            // Cycle 3: Work -> Short Break
            pomo.advancePhase()
            assertEqual(pomo.phase, .shortBreak)
            assertEqual(pomo.cyclesCompleted, 3)

            // Short Break -> Work
            pomo.advancePhase()
            assertEqual(pomo.phase, .work)

            // Cycle 4: Work -> LONG Break!
            pomo.advancePhase()
            assertEqual(pomo.phase, .longBreak)
            assertEqual(pomo.cyclesCompleted, 4)
            assertEqual(pomo.remaining, 15 * 60)

            // Long Break -> Work
            pomo.advancePhase()
            assertEqual(pomo.phase, .work)
            assertEqual(pomo.cyclesCompleted, 4)
            assertEqual(pomo.remaining, 25 * 60)
        }

        runTest("testPomodoroSkipPhase") {
            let pomo = PomodoroModel()

            // Skip Work -> Short Break
            pomo.skipPhase()
            assertEqual(pomo.phase, .shortBreak)
            assertEqual(pomo.remaining, 5 * 60)

            // Skip Short Break -> Work
            pomo.skipPhase()
            assertEqual(pomo.phase, .work)
            assertEqual(pomo.remaining, 25 * 60)
        }

        runTest("testPomodoroCustomDuration") {
            let pomo = PomodoroModel()
            pomo.setWorkDuration(50 * 60) // 50 min deep work
            assertEqual(pomo.workDuration, 50 * 60)
            assertEqual(pomo.currentDuration, 50 * 60)
            assertEqual(pomo.remaining, 50 * 60)

            let t0 = Date()
            pomo.toggle(now: t0)
            assertTrue(pomo.isRunning)

            // Advance 10m
            let t1 = t0.addingTimeInterval(10 * 60)
            assertEqual(pomo.remaining(at: t1), 40 * 60, accuracy: 0.001)

            pomo.markCompletionRecorded()
            assertTrue(pomo.completionRecorded)
            pomo.setWorkDuration(25 * 60)
            assertFalse(pomo.completionRecorded)
        }

        runTest("testPomodoroReset") {
            let pomo = PomodoroModel()
            pomo.setWorkDuration(50 * 60)
            pomo.advancePhase()
            pomo.advancePhase()
            assertEqual(pomo.cyclesCompleted, 1)

            pomo.reset()
            assertEqual(pomo.phase, .work)
            assertEqual(pomo.cyclesCompleted, 0)
            assertEqual(pomo.remaining, 50 * 60)
            assertFalse(pomo.isRunning)
        }
    }
}
