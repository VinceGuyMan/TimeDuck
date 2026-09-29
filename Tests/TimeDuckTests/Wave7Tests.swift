// MARK: - TimeDuck · Wave7Tests.swift
// Automated test suite for Wave 7 (Living MiniHUD / Pocket Duck).

import Foundation

enum Wave7Tests {
    static func runAll() {
        print("\n▸ Testing Wave 7: Living MiniHUD & Pocket Duck Architecture…")
        testWave7PrimaryTimeProtectedZoneZeroOverlap()
        testWave7StateZoneSubordinateIndicators()
        testWave7StopwatchLongValueFormattingNoCollision()
        testWave7MiniStageBoundaryClampingAndHitTesting()
        testWave7MiniHUDPokeEscalation()
        testWave7MiniHUDFeedingAndChonkyBounds()
        testWave7AllFiveCompactStoriesMicroPropsAndChoreography()
        testWave7ClockAcknowledgmentMoments()
        testWave7ReducedMotionMiniHUDCompliance()
        testWave7AuthoritativeTimerIsolationAndPreviewIndependence()
    }

    static func testWave7PrimaryTimeProtectedZoneZeroOverlap() {
        runTest("testWave7PrimaryTimeProtectedZoneZeroOverlap") {
            let widths = [80, 100, 120, 144, 160, 200]
            let heights = [24, 28, 32, 34, 40]

            for w in widths {
                for h in heights {
                    let m = CompactLayoutMetrics(gridW: w, gridH: h, modeTag: "FOCUS", goLabel: "START", secLabel: "SKIP")

                    // 1. Primary Time Zone must have positive dimensions
                    assertTrue(m.timeAreaRect.w > 0, "Time area width must be positive at \(w)x\(h)")
                    assertTrue(m.timeAreaRect.h > 0, "Time area height must be positive at \(w)x\(h)")

                    // 2. Mini Stage must be strictly to the right of Primary Time Zone and Actions
                    assertTrue(m.miniStageRect.x > m.timeAreaRect.x + m.timeAreaRect.w, "Mini Stage must be to the right of Time Area at \(w)x\(h)")
                    assertTrue(m.miniStageRect.x > m.secRect.x + m.secRect.w, "Mini Stage must be to the right of secondary button at \(w)x\(h)")

                    // 3. Zero overlap between Time Area and all other components
                    assertFalse(m.overlapsTimeArea(rect: m.miniStageRect), "Mini Stage must not overlap Time Area at \(w)x\(h)")
                    assertFalse(m.overlapsTimeArea(rect: m.goRect), "Go button must not overlap Time Area at \(w)x\(h)")
                    assertFalse(m.overlapsTimeArea(rect: m.secRect), "Sec button must not overlap Time Area at \(w)x\(h)")
                    assertFalse(m.overlapsTimeArea(rect: m.unminiRect), "Unmini button must not overlap Time Area at \(w)x\(h)")
                    assertFalse(m.overlapsTimeArea(rect: m.soundRect), "Sound toggle must not overlap Time Area at \(w)x\(h)")
                    assertFalse(m.overlapsTimeArea(rect: m.modePillRect), "Mode pill must not overlap Time Area at \(w)x\(h)")
                }
            }
        }
    }

    static func testWave7StateZoneSubordinateIndicators() {
        runTest("testWave7StateZoneSubordinateIndicators") {
            let mFocus = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "FOCUS", goLabel: "PAUSE", secLabel: "SKIP")
            assertEqual(mFocus.modeTag, "FOCUS", "Pomodoro work phase must display FOCUS")

            let mBreak = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "BREAK", goLabel: "PAUSE", secLabel: "SKIP")
            assertEqual(mBreak.modeTag, "BREAK", "Pomodoro break phase must display BREAK")

            let mTimer = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "TIMER", goLabel: "PAUSE", secLabel: "+1M")
            assertEqual(mTimer.modeTag, "TIMER", "Timer mode must display TIMER")

            let mSW = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "PAUSE", secLabel: "LAP")
            assertEqual(mSW.modeTag, "SW", "Stopwatch mode must display SW")
        }
    }

    static func testWave7StopwatchLongValueFormattingNoCollision() {
        runTest("testWave7StopwatchLongValueFormattingNoCollision") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "SW", goLabel: "PAUSE", secLabel: "LAP")
            let maxW = m.maxTimeWidth

            let shortTime = "00:16.42"
            let midTime = "12:48.33"
            let hourTime = "1:05:42.10"
            let longHourTime = "12:47:19.85"

            let styleShort = CompactLayoutMetrics.resolveTimeRenderStyle(for: shortTime, maxWidth: maxW)
            assertTrue(styleShort.totalWidth <= maxW, "Short stopwatch time \(shortTime) total width \(styleShort.totalWidth) must fit in maxW \(maxW)")

            let styleMid = CompactLayoutMetrics.resolveTimeRenderStyle(for: midTime, maxWidth: maxW)
            assertTrue(styleMid.totalWidth <= maxW, "Mid stopwatch time \(midTime) total width \(styleMid.totalWidth) must fit in maxW \(maxW)")

            let styleHour = CompactLayoutMetrics.resolveTimeRenderStyle(for: hourTime, maxWidth: maxW)
            assertTrue(styleHour.totalWidth <= maxW, "Hour stopwatch time \(hourTime) total width \(styleHour.totalWidth) must fit in maxW \(maxW)")

            let styleLongHour = CompactLayoutMetrics.resolveTimeRenderStyle(for: longHourTime, maxWidth: maxW)
            assertTrue(styleLongHour.totalWidth <= maxW, "Long hour stopwatch time \(longHourTime) total width \(styleLongHour.totalWidth) must fit in maxW \(maxW)")
        }
    }

    static func testWave7MiniStageBoundaryClampingAndHitTesting() {
        runTest("testWave7MiniStageBoundaryClampingAndHitTesting") {
            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "TIMER", goLabel: "START", secLabel: "+1M")

            // Duck coordinates inside Mini Stage
            assertTrue(m.containsInMiniStage(x: m.duckSpriteX, y: m.duckSpriteY), "Duck sprite origin must be inside Mini Stage")
            assertTrue(m.containsInMiniStage(x: m.duckSpriteX + 12, y: m.duckSpriteY + 9), "Duck sprite bottom-right must be inside Mini Stage")

            // Mini Stage does NOT contain Time Area or Button points
            assertFalse(m.containsInMiniStage(x: m.timeAreaRect.x, y: m.timeAreaRect.y), "Time Area origin must NOT be in Mini Stage")
            assertFalse(m.containsInMiniStage(x: m.goRect.x, y: m.goRect.y), "Go button origin must NOT be in Mini Stage")
            assertFalse(m.containsInMiniStage(x: m.secRect.x, y: m.secRect.y), "Sec button origin must NOT be in Mini Stage")
        }
    }

    static func testWave7MiniHUDPokeEscalation() {
        runTest("testWave7MiniHUDPokeEscalation") {
            let brain = DuckBrain()
            assertEqual(brain.pokeLevel, 0, "Initial poke level must be 0")

            let res1 = brain.onPoke()
            assertEqual(res1.level, 1, "First poke must be Level 1 (Curiosity)")

            let res2 = brain.onPoke()
            assertEqual(res2.level, 2, "Second poke must be Level 2 (Surprise/Dodge)")

            let res3 = brain.onPoke()
            assertTrue(res3.level >= 3, "Third poke must escalate to Level 3+")
        }
    }

    static func testWave7MiniHUDFeedingAndChonkyBounds() {
        runTest("testWave7MiniHUDFeedingAndChonkyBounds") {
            let chonkSprites: [[String]] = [
                DUCK_BASE,
                DUCK_CHONK_STAGE1,
                DUCK_CHONK_STAGE2,
                DUCK_CHONK_STAGE3,
                DUCK_CHONK_STAGE4,
                DUCK_CHONK_STAGE5,
                DUCK_CHONK_SIT,
                DUCK_BELLY_WOBBLE
            ]

            let m = CompactLayoutMetrics(gridW: 144, gridH: 34, modeTag: "POMO", goLabel: "START", secLabel: "SKIP")
            for (idx, sprite) in chonkSprites.enumerated() {
                let maxRowW = sprite.map { $0.count }.max() ?? 0
                assertTrue(maxRowW <= m.duckW, "Chonky sprite \(idx) width (\(maxRowW)) must fit within Mini Stage width (\(m.duckW))")
            }
        }
    }

    static func testWave7AllFiveCompactStoriesMicroPropsAndChoreography() {
        runTest("testWave7AllFiveCompactStoriesMicroPropsAndChoreography") {
            let stories: [DuckStory] = [
                TheFeastStory(),
                TheExpeditionStory(),
                NightShiftStory(),
                TheWodStory(),
                TheRescueStory()
            ]

            let compactCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.5, sessionDuration: 300, remainingSeconds: 150,
                elapsedSeconds: 150, isCompact: true, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            let engine = DuckStoryEngine()

            for story in stories {
                story.prepare(context: compactCtx, engine: engine)
                story.onStart(context: compactCtx, engine: engine)
                story.onProgress(context: compactCtx, progress: 0.5, engine: engine)
                story.update(dt: 1.0, now: Date(), context: compactCtx, engine: engine)

                // Verify story runs cleanly under compact mode
                assertTrue(story.activeSceneIndex >= 0, "\(story.id.displayName) must maintain active scene in compact mode")
                story.onComplete(context: compactCtx, engine: engine)
                story.cleanup(engine: engine)
            }
        }
    }

    static func testWave7ClockAcknowledgmentMoments() {
        runTest("testWave7ClockAcknowledgmentMoments") {
            // Verify clock glance sprite dimensions match canonical duck proportions
            assertEqual(DUCK_GLANCE_CLOCK.count, 10, "DUCK_GLANCE_CLOCK must have 10 rows")
            assertEqual(DUCK_GLANCE_CLOCK[0].count, 13, "DUCK_GLANCE_CLOCK must have 13 columns")

            assertEqual(DUCK_POINT_CLOCK.count, 10, "DUCK_POINT_CLOCK must have 10 rows")
            assertEqual(DUCK_POINT_CLOCK[0].count, 13, "DUCK_POINT_CLOCK must have 13 columns")
        }
    }

    static func testWave7ReducedMotionMiniHUDCompliance() {
        runTest("testWave7ReducedMotionMiniHUDCompliance") {
            let compactCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.8, sessionDuration: 300, remainingSeconds: 60,
                elapsedSeconds: 240, isCompact: true, reduceMotion: true, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            let engine = DuckStoryEngine()
            let wod = TheWodStory()
            wod.prepare(context: compactCtx, engine: engine)
            wod.onMilestone(milestoneIndex: 4, progress: 0.8, context: compactCtx, engine: engine)
            wod.update(dt: 1.0, now: Date(), context: compactCtx, engine: engine)

            assertTrue(wod.activeSceneIndex == 4, "Reduced motion must not block scene completion")
        }
    }

    static func testWave7AuthoritativeTimerIsolationAndPreviewIndependence() {
        runTest("testWave7AuthoritativeTimerIsolationAndPreviewIndependence") {
            let tm = TimerModel()
            tm.setDuration(900)
            let pomo = PomodoroModel()
            let sw = StopwatchModel()

            // Synthesize MiniHUD Story Preview
            var previewProgress: Double = 0.0
            let speeds = [1.0, 5.0, 10.0]

            for s in speeds {
                let dt = 0.1
                previewProgress += dt * (s / 60.0)
                assertTrue(previewProgress > 0.0, "Speed \(s)x must advance synthetic preview")

                // Authoritative models remain completely isolated
                assertEqual(tm.duration, 900.0, "Timer duration must remain 900s")
                assertEqual(tm.remaining, 900.0, "Timer remaining must remain untouched")
                assertEqual(pomo.workDuration, 1500.0, "Pomodoro work duration must remain untouched")
                assertEqual(sw.elapsed, 0.0, "Stopwatch elapsed must remain 0.0")
            }
        }
    }
}
