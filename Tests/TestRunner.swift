// MARK: - TimeDuck · TestRunner.swift
// CLI test runner for automated validation.

import Foundation

@main
struct TestRunner {
    static func main() {
        print("🦆 Running TimeDuck Automated Test Suite…")
        let startTime = Date()
        let ctx = TestSuiteContext.shared
        ctx.reset()

        TimerEngineTests.runAll()
        StopwatchTests.runAll()
        PomodoroTests.runAll()
        StatsTrackerTests.runAll()
        FormattingTests.runAll()
        PersistenceTests.runAll()
        DuckBrainTests.runAll()
        StatusDuckTests.runAll()
        ViewportTransformTests.runAll()
        CompactLayoutTests.runAll()
        Wave1Tests.runAll()
        Wave2Tests.runAll()
        Wave3Tests.runAll()
        Wave4Tests.runAll()
        Wave5Tests.runAll()
        Wave6Tests.runAll()
        Wave6_1Tests.runAll()
        Wave7Tests.runAll()
        AnimationPolishTests.runAll()
        Wave7_2Tests.runAll()
        PreWave8AuditTests.runAll()
        Wave8Tests.runAll()
        Wave8_1Tests.runAll()
        Wave8_2Tests.runAll()
        GPUMonitorTests.runAll()
        WhatsNewTests.runAll()

        let elapsed = String(format: "%.3fs", Date().timeIntervalSince(startTime))
        print("")
        print(String(repeating: "─", count: 48))
        print("Test Results: \(ctx.passedCount) passed, \(ctx.failedCount) failed (\(ctx.passedCount + ctx.failedCount) total) in \(elapsed)")
        print(String(repeating: "─", count: 48))
        print("")

        if ctx.failedCount > 0 {
            print("❌ Test run FAILED with \(ctx.failedCount) failure(s).")
            print("")
            exit(1)
        } else {
            print("✨ All \(ctx.passedCount) tests PASSED.")
            print("")
            exit(0)
        }
    }
}
