// MARK: - TimeDuck · CompactLayoutTests.swift
// Exhaustive test suite for Compact Mode layout geometry, non-overlap guarantees,
// adaptive font scaling across all timer/stopwatch/pomodoro formats, and exit button hitbox validity.

import Foundation

enum CompactLayoutTests {
    static func runAll() {
        print("")
        print("▸ Testing Compact Mode Layout Geometry & Collision Prevention…")

        runTest("testCompactLayoutNonOverlappingRegions") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "START", secLabel: "LAP")

            // 1. Duck panel must be strictly on the right
            assertTrue(m.duckX >= 115, "Duck panel X should be >= 115, got \(m.duckX)")
            assertTrue(m.duckX + m.duckW <= 144 - 2, "Duck panel right edge must fit within canvas")
            assertTrue(m.duckW >= 20, "Duck panel width must be at least 20, got \(m.duckW)")

            // 2. Buttons must be strictly to the left of the duck panel separator
            assertTrue(m.secRect.x + m.secRect.w < m.duckX, "Secondary button must be left of duck panel")
            assertTrue(m.goRect.x + m.goRect.w < m.secRect.x, "Go button must be left of secondary button")

            // 3. Top-right controls must be strictly left of duck panel
            assertTrue(m.unminiRect.x + m.unminiRect.w <= m.duckX - 1, "Unmini expand button must be left of duck separator")
            assertTrue(m.soundRect.x + m.soundRect.w < m.unminiRect.x, "Sound toggle must be left of unmini button")

            // 4. Mode pill must be top-left
            assertTrue(m.modePillRect.x == 4, "Mode pill X should be 4")
            assertTrue(m.modePillRect.x + m.modePillRect.w < m.soundRect.x, "Mode pill must not collide with top-right sound button")

            // 5. Time display area must be strictly left of the go button
            assertTrue(m.timeAreaRect.x == 4, "Time area X should be 4")
            assertTrue(m.timeAreaRect.x + m.maxTimeWidth < m.goRect.x, "Time area right bound must be left of go button")
        }

        runTest("testStopwatchFormattingAndFontScalingUnderHour") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "START", secLabel: "LAP")
            let testTimes = [
                0.0,       // 00:00.00
                5.12,      // 00:05.12
                754.56,    // 12:34.56
                3599.99    // 59:59.99
            ]

            for t in testTimes {
                let formatted = Fmt.sw(t)
                let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: formatted, maxWidth: m.maxTimeWidth)
                let totalW = style.totalWidth

                // Must fit within maxTimeWidth
                assertTrue(totalW <= m.maxTimeWidth, "Formatted '\(formatted)' total width \(totalW) exceeds maxTimeWidth \(m.maxTimeWidth)")

                // Right edge of rendered time must never touch go button
                let timeRight = m.timeAreaRect.x + totalW
                assertTrue(timeRight < m.goRect.x, "Time display right edge (\(timeRight)) collides with go button (\(m.goRect.x)) for '\(formatted)'")

                // Right edge must never touch duck panel
                assertTrue(timeRight < m.duckX, "Time display right edge (\(timeRight)) collides with duck panel (\(m.duckX)) for '\(formatted)'")
            }
        }

        runTest("testStopwatchFormattingAndFontScalingOverHour") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "START", secLabel: "LAP")
            let testTimes = [
                3600.0,      // 1:00:00.00
                45296.78,    // 12:34:56.78
                359999.99    // 99:59:59.99
            ]

            for t in testTimes {
                let formatted = Fmt.sw(t)
                let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: formatted, maxWidth: m.maxTimeWidth)
                let totalW = style.totalWidth

                // Must fit within maxTimeWidth
                assertTrue(totalW <= m.maxTimeWidth, "Over-hour '\(formatted)' total width \(totalW) exceeds maxTimeWidth \(m.maxTimeWidth)")

                let timeRight = m.timeAreaRect.x + totalW
                assertTrue(timeRight < m.goRect.x, "Over-hour time right edge (\(timeRight)) collides with go button (\(m.goRect.x)) for '\(formatted)'")
                assertTrue(timeRight < m.duckX, "Over-hour time right edge (\(timeRight)) collides with duck panel (\(m.duckX)) for '\(formatted)'")
            }
        }

        runTest("testStopwatchCentisecondContinuityZeroCollisions") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "PAUSE", secLabel: "LAP")

            // Test 100 centisecond increments near 0, 1 minute, and 1 hour
            let baseIntervals: [Double] = [0.0, 59.0, 3599.0]
            for base in baseIntervals {
                for cs in 0..<100 {
                    let t = base + Double(cs) / 100.0
                    let formatted = Fmt.sw(t)
                    let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: formatted, maxWidth: m.maxTimeWidth)
                    let totalW = style.totalWidth

                    assertTrue(totalW <= m.maxTimeWidth, "Centisecond tick '\(formatted)' total width \(totalW) exceeds maxTimeWidth \(m.maxTimeWidth)")
                    let timeRight = m.timeAreaRect.x + totalW
                    assertTrue(timeRight < m.goRect.x, "Collision at '\(formatted)': timeRight \(timeRight) >= goRect.x \(m.goRect.x)")
                    assertTrue(timeRight < m.duckX, "Collision at '\(formatted)': timeRight \(timeRight) >= duckX \(m.duckX)")
                }
            }
        }

        runTest("testCompactLayoutResponsivenessAcrossWidths") {
            let widths = [80, 100, 120, 144, 180, 220]
            let testModes: [(String, String, String)] = [
                ("SW", "START", "LAP"),
                ("TIMER", "START", "+1M"),
                ("POMO", "START", "SKIP")
            ]

            for w in widths {
                for (tag, go, sec) in testModes {
                    let m = CompactLayoutMetrics(gridW: w, gridH: 34, modeTag: tag, goLabel: go, secLabel: sec)

                    assertTrue(m.duckW >= 17, "Width \(w): duckW should be >= 17, got \(m.duckW)")
                    assertTrue(m.duckX + m.duckW <= w - 2, "Width \(w): duck panel exceeds canvas width")
                    assertTrue(m.secRect.x + m.secRect.w < m.duckX, "Width \(w): sec button collides with duck panel")
                    assertTrue(m.goRect.x + m.goRect.w < m.secRect.x, "Width \(w): go button collides with sec button")
                    assertTrue(m.timeAreaRect.x + m.maxTimeWidth < m.goRect.x, "Width \(w): time area collides with go button")
                    assertTrue(m.unminiRect.x + m.unminiRect.w <= m.duckX - 1, "Width \(w): unmini button collides with duck panel")

                    // Test all sample strings fit without collision
                    let samples = ["00:00", "25:00", "00:00.00", "1:00:00.00"]
                    for s in samples {
                        let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: s, maxWidth: m.maxTimeWidth)
                        assertTrue(style.totalWidth <= m.maxTimeWidth, "Width \(w), string '\(s)': width \(style.totalWidth) > maxTimeWidth \(m.maxTimeWidth)")
                    }
                }
            }
        }

        runTest("testCompactExpandControlPlacementAndHitbox") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "POMO", goLabel: "START", secLabel: "SKIP")

            // Expand button must be visible, non-zero dimensions
            assertTrue(m.unminiRect.w >= 8, "Unmini button width must be >= 8, got \(m.unminiRect.w)")
            assertTrue(m.unminiRect.h >= 6, "Unmini button height must be >= 6, got \(m.unminiRect.h)")

            // Must be at top row (y = 2..10)
            assertTrue(m.unminiRect.y >= 2 && m.unminiRect.y <= 4, "Unmini button Y must be in top row, got \(m.unminiRect.y)")

            // Must be strictly left of duck panel separator
            assertTrue(m.unminiRect.x + m.unminiRect.w < m.duckX, "Unmini button must be strictly left of duck panel")

            // Must be right of mode pill
            assertTrue(m.unminiRect.x > m.modePillRect.x + m.modePillRect.w, "Unmini button must be to the right of mode pill")
        }

        runTest("testAllModesCompactLayout") {
            let modes: [(Mode, String, String, String)] = [
                (.pomodoro, "POMO", "START", "SKIP"),
                (.timer, "TIMER", "START", "+1M"),
                (.stopwatch, "SW", "START", "LAP")
            ]

            for (_, tag, go, sec) in modes {
                let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: tag, goLabel: go, secLabel: sec)
                let timeStrings = [
                    "00:00", "05:00", "25:00", "50:00", "1:00:00",
                    "09.4", "00.00", "00:00.00", "59:59.99", "1:00:00.00",
                    "01:00_", "25:00_"
                ]
                for s in timeStrings {
                    let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: s, maxWidth: m.maxTimeWidth)
                    assertTrue(style.totalWidth <= m.maxTimeWidth, "Tag \(tag), string '\(s)': width \(style.totalWidth) exceeds \(m.maxTimeWidth)")
                    let tr = m.timeAreaRect.x + style.totalWidth
                    assertTrue(tr < m.goRect.x, "Tag \(tag), string '\(s)': time right edge \(tr) collides with go \(m.goRect.x)")
                    assertTrue(tr < m.duckX, "Tag \(tag), string '\(s)': time right edge \(tr) collides with duck \(m.duckX)")
                }
            }
        }
    }
}
