// MARK: - TimeDuck · FormattingTests.swift

import Foundation

enum FormattingTests {
    static func runAll() {
        print("")
        print("▸ Testing Precision Time Formatting…")

        runTest("testStopwatchFormattingUnderHour") {
            assertEqual(Fmt.sw(0), "00:00.00")
            assertEqual(Fmt.sw(5.12), "00:05.12")
            assertEqual(Fmt.sw(65.45), "01:05.45")
            assertEqual(Fmt.sw(59 * 60 + 59.99), "59:59.99")
        }

        runTest("testStopwatchFormattingOverHour") {
            assertEqual(Fmt.sw(3600), "1:00:00.00")
            assertEqual(Fmt.sw(3665.45), "1:01:05.45")
            assertEqual(Fmt.sw(10 * 3600 + 15 * 60 + 20.35), "10:15:20.35")
        }

        runTest("testTimerFormattingStandard") {
            assertEqual(Fmt.tm(300), "05:00")
            assertEqual(Fmt.tm(1500), "25:00")
            assertEqual(Fmt.tm(3600), "1:00:00")
            assertEqual(Fmt.tm(3665), "1:01:05")
        }

        runTest("testTimerFormattingSubTenSecondsDrama") {
            let formatted = Fmt.tm(9.4)
            assertTrue(formatted.contains("9.") || formatted.contains("09."))

            let dramaZero = Fmt.tm(0.5, drama: true)
            assertTrue(dramaZero.contains("0."))
        }

        runTest("testDurationWords") {
            assertEqual(Fmt.durationWords(0), "0m")
            assertEqual(Fmt.durationWords(45), "0m")
            assertEqual(Fmt.durationWords(60), "1m")
            assertEqual(Fmt.durationWords(1500), "25m")
            assertEqual(Fmt.durationWords(3600), "1h")
            assertEqual(Fmt.durationWords(5400), "1h 30m")
            assertEqual(Fmt.durationWords(7200), "2h")
        }

        runTest("testHM") {
            assertEqual(Fmt.hm(0), "0:00")
            assertEqual(Fmt.hm(65), "1:05")
            assertEqual(Fmt.hm(600), "10:00")
        }

        runTest("testParseDuration") {
            // Numeric minutes
            assertEqual(Fmt.parseDuration("5"), 300)
            assertEqual(Fmt.parseDuration("1"), 60)
            assertEqual(Fmt.parseDuration("0.5"), 30)

            // Colon formats
            assertEqual(Fmt.parseDuration(":30"), 30)
            assertEqual(Fmt.parseDuration("0:30"), 30)
            assertEqual(Fmt.parseDuration("5:30"), 330)
            assertEqual(Fmt.parseDuration("1:30:00"), 5400)
            assertEqual(Fmt.parseDuration("0:05"), 5)

            // Unit formats
            assertEqual(Fmt.parseDuration("30s"), 30)
            assertEqual(Fmt.parseDuration("10m"), 600)
            assertEqual(Fmt.parseDuration("1h"), 3600)
            assertEqual(Fmt.parseDuration("1h30m"), 5400)
            assertEqual(Fmt.parseDuration("1h 30m 15s"), 5415)

            // Bounds & Invalid
            assertEqual(Fmt.parseDuration("2s"), 5) // Clamped to 5s min
            assertEqual(Fmt.parseDuration(""), nil)
            assertEqual(Fmt.parseDuration("invalid"), nil)
            assertEqual(Fmt.parseDuration("-5"), nil)
            assertEqual(Fmt.parseDuration("1:80"), nil) // Invalid seconds
        }
    }
}
