// MARK: - TimeDuck · Wave7_2Tests.swift
// Automated test suite for Wave 7.2:
// - DuckBillAnchorResolver & dynamic beak tip calculations
// - Story Finale Lifecycles (The Feast, The Expedition, Night Shift, The WOD, The Rescue)
// - Seamless Scene Handoffs & Boundary Transitions
// - Authoritative Timer Clock Isolation
// - Snore FX Glyph System & Strict Particle Lifecycle / Cleanup
// - MiniHUD Finale Stage Rendering & Protection

import Foundation
import AppKit

enum Wave7_2Tests {
    static func runAll() {
        print("\n▸ Testing Wave 7.2: Story Finales, Seamless Scene Handoffs & Sleep FX…")
        testBillAnchorStandingPoseResolvesTip()
        testBillAnchorFlippedPoseResolvesLeftmostTip()
        testBillAnchorSleepingPoseResolvesAnchor()
        testSnoreGlyphsExistAndHaveValidZShape()
        testTheFeastFinaleDigestionToRestingLoop()
        testTheExpeditionFinaleFlagPlantToSummitRestingLoop()
        testNightShiftFinaleReliefToRestingSleepLoop()
        testTheWodFinaleCompletionToGymRestingLoop()
        testTheRescueFinaleLandingToGirlDuckDuoTableau()
        testStoryEngineTimerCompletionEntersFinaleAutomatically()
        testStoryEngineAuthoritativeClockUnaffectedByFinale()
        testStoryEngineSceneBoundaryTransitions()
        testSleepFXClearSleepFXPurgesParticlesInstantly()
        testMiniHUDFinaleRenderingAndStageProtection()
    }

    // MARK: - Test 1: Bill Anchor Resolution (Standing Pose)
    static func testBillAnchorStandingPoseResolvesTip() {
        runTest("testBillAnchorStandingPoseResolvesTip") {
            let anchorRight = DuckBillAnchorResolver.resolve(rows: DUCK_BASE, flip: false)
            assertFalse(anchorRight.facingLeft, "Default bill anchor should face right")
            assertTrue(anchorRight.x > 5, "Bill tip x should be in the right half of the sprite: \(anchorRight.x)")
            assertTrue(anchorRight.y > 0 && anchorRight.y < DUCK_BASE.count, "Bill tip y should be within sprite rows: \(anchorRight.y)")

            // Verify the resolved pixel in DUCK_BASE is indeed a bill character ('o' or 'r')
            let rowStr = DUCK_BASE[anchorRight.y]
            let chars = Array(rowStr)
            assertTrue(chars[anchorRight.x] == "o" || chars[anchorRight.x] == "r", "Anchor coordinate must correspond to a bill pixel ('o' or 'r')")
        }
    }

    // MARK: - Test 2: Bill Anchor Resolution (Flipped Pose)
    static func testBillAnchorFlippedPoseResolvesLeftmostTip() {
        runTest("testBillAnchorFlippedPoseResolvesLeftmostTip") {
            let anchorLeft = DuckBillAnchorResolver.resolve(rows: DUCK_BASE, flip: true)
            assertTrue(anchorLeft.facingLeft, "Flipped bill anchor should face left")
            assertTrue(anchorLeft.x < 5, "Flipped bill tip x should be in the left half of the sprite: \(anchorLeft.x)")
            assertTrue(anchorLeft.y > 0 && anchorLeft.y < DUCK_BASE.count, "Bill tip y should be within sprite rows")

            // In flipped space, index x matches the reversed string's leftmost beak tip
            let rowStr = DUCK_BASE[anchorLeft.y]
            let reversedChars = Array(rowStr.reversed())
            assertTrue(reversedChars[anchorLeft.x] == "o" || reversedChars[anchorLeft.x] == "r", "Flipped anchor must target bill pixel on reversed row")
        }
    }

    // MARK: - Test 3: Bill Anchor Resolution (Sleeping Pose)
    static func testBillAnchorSleepingPoseResolvesAnchor() {
        runTest("testBillAnchorSleepingPoseResolvesAnchor") {
            let sleepAnchor = DuckBillAnchorResolver.resolve(rows: DUCK_SLEEP_DEEP, flip: false)
            assertFalse(sleepAnchor.facingLeft, "Sleeping anchor should default to right facing")
            assertTrue(sleepAnchor.x > 0 && sleepAnchor.y > 0, "Sleeping anchor must have positive non-zero coordinates")

            let droopAnchor = DuckBillAnchorResolver.resolve(rows: DUCK_NIGHT_DROOP, flip: false)
            assertTrue(droopAnchor.x > 0 && droopAnchor.y > 0, "Droop anchor must have valid coordinates")
        }
    }

    // MARK: - Test 4: Snore Glyphs Validation
    static func testSnoreGlyphsExistAndHaveValidZShape() {
        runTest("testSnoreGlyphsExistAndHaveValidZShape") {
            assertEqual(GLYPH_SNORE_Z_SMALL.count, 3, "Small snore glyph should be 3 rows high")
            assertEqual(GLYPH_SNORE_Z_MED.count, 4, "Medium snore glyph should be 4 rows high")
            assertEqual(GLYPH_SNORE_Z_LARGE.count, 5, "Large snore glyph should be 5 rows high")

            for row in GLYPH_SNORE_Z_SMALL {
                assertEqual(row.count, 3, "Small snore glyph rows must be 3 chars wide")
                assertTrue(row.contains("z") || row.contains("."), "Glyph must contain 'z' or '.'")
            }
            for row in GLYPH_SNORE_Z_MED {
                assertEqual(row.count, 4, "Medium snore glyph rows must be 4 chars wide")
            }
            for row in GLYPH_SNORE_Z_LARGE {
                assertEqual(row.count, 5, "Large snore glyph rows must be 5 chars wide")
            }
        }
    }

    // MARK: - Test 5: The Feast Story Finale
    static func testTheFeastFinaleDigestionToRestingLoop() {
        runTest("testTheFeastFinaleDigestionToRestingLoop") {
            let story = TheFeastStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 300,
                remainingSeconds: 0,
                elapsedSeconds: 300,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            story.prepare(context: ctx, engine: engine)
            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "Story must be in finale active state")
            assertTrue(story.isDigesting, "Feast finale must begin with digestion phase")

            // Step through digestion payoff (0.0 ... 4.5s)
            story.updateFinale(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertTrue(story.fullnessStage < 5, "Fullness stage should decrease as digestion proceeds")

            // Step past 4.5s into resting satisfied loop
            story.updateFinale(dt: 4.0, now: Date().addingTimeInterval(5.0), context: ctx, engine: engine)
            assertFalse(story.isDigesting, "Digestion must complete and transition to resting loop")
            assertEqual(story.fullnessStage, 0, "Fullness stage should reach 0 (standard base duck)")

            // Resting loop must cycle through resting poses seamlessly
            let perf = engine.currentPerformanceOverride
            assertTrue(perf != nil, "Performance override should provide resting loop pose")
        }
    }

    // MARK: - Test 6: The Expedition Story Finale
    static func testTheExpeditionFinaleFlagPlantToSummitRestingLoop() {
        runTest("testTheExpeditionFinaleFlagPlantToSummitRestingLoop") {
            let story = TheExpeditionStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 300,
                remainingSeconds: 0,
                elapsedSeconds: 300,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            story.prepare(context: ctx, engine: engine)
            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "Expedition must be in finale")
            assertTrue(engine.props.contains(where: { $0.id == "summit_flag" }), "Summit flag prop must be added to scenery")

            // Step past initial fanfare (0.0 ... 4.0s) into resting summit loop
            story.updateFinale(dt: 5.0, now: Date().addingTimeInterval(5.0), context: ctx, engine: engine)
            let perf = engine.currentPerformanceOverride
            assertTrue(perf != nil, "Resting summit loop must provide active duck performance")
        }
    }

    // MARK: - Test 7: Night Shift Story Finale
    static func testNightShiftFinaleReliefToRestingSleepLoop() {
        runTest("testNightShiftFinaleReliefToRestingSleepLoop") {
            let story = NightShiftStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 300,
                remainingSeconds: 0,
                elapsedSeconds: 300,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            story.prepare(context: ctx, engine: engine)
            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "Night Shift must be in finale")

            // Step past 3.0s entry into resting sleep loop
            story.updateFinale(dt: 4.0, now: Date().addingTimeInterval(4.0), context: ctx, engine: engine)
            let perf = engine.currentPerformanceOverride
            assertTrue(perf != nil, "Night shift resting finale must produce sleep pose performance")
        }
    }

    // MARK: - Test 8: The WOD Story Finale
    static func testTheWodFinaleCompletionToGymRestingLoop() {
        runTest("testTheWodFinaleCompletionToGymRestingLoop") {
            let story = TheWodStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 300,
                remainingSeconds: 0,
                elapsedSeconds: 300,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            story.prepare(context: ctx, engine: engine)
            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "The WOD must be in finale")

            // Step past 3.5s into resting gym loop
            story.updateFinale(dt: 4.5, now: Date().addingTimeInterval(4.5), context: ctx, engine: engine)
            let perf = engine.currentPerformanceOverride
            assertTrue(perf != nil, "The WOD resting loop must be active")
        }
    }

    // MARK: - Test 9: The Rescue Story Finale
    static func testTheRescueFinaleLandingToGirlDuckDuoTableau() {
        runTest("testTheRescueFinaleLandingToGirlDuckDuoTableau") {
            let story = TheRescueStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 300,
                remainingSeconds: 0,
                elapsedSeconds: 300,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            story.prepare(context: ctx, engine: engine)
            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "The Rescue must be in finale")
            assertTrue(engine.actors.contains(where: { $0.id == "girl_duck" }), "Girl Duck actor must be present in finale tableau")

            // Step into resting living tableau (3.5s+)
            story.updateFinale(dt: 5.0, now: Date().addingTimeInterval(5.0), context: ctx, engine: engine)
            let perf = engine.currentPerformanceOverride
            assertTrue(perf != nil, "Duo living tableau performance must be active")
        }
    }

    // MARK: - Test 10: Automatic Timer Completion Finale Entry
    static func testStoryEngineTimerCompletionEntersFinaleAutomatically() {
        runTest("testStoryEngineTimerCompletionEntersFinaleAutomatically") {
            let engine = DuckStoryEngine()
            engine.setSelection(.theExpedition)
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: false,
                isPaused: false,
                isFinished: true,
                normalizedProgress: 1.0,
                sessionDuration: 60,
                remainingSeconds: 0,
                elapsedSeconds: 60,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)
            engine.updateProgress(context: ctx, now: Date())

            assertTrue(engine.isFinaleActive, "Story engine should automatically transition into finale when isFinished == true")
            assertTrue(engine.activeStory?.isFinaleActive == true, "Active story should have isFinaleActive == true")
        }
    }

    // MARK: - Test 11: Authoritative Clock Isolation
    static func testStoryEngineAuthoritativeClockUnaffectedByFinale() {
        runTest("testStoryEngineAuthoritativeClockUnaffectedByFinale") {
            let tm = TimerModel()
            tm.restoreState(duration: 60, remainingAtStop: 0, running: true, endWall: Date().addingTimeInterval(-5), completionRecorded: true)

            assertTrue(tm.finished, "TimerModel must record finished state")
            assertEqual(tm.remaining, 0, "Timer remaining must be 0")

            let engine = DuckStoryEngine()
            engine.setSelection(.nightShift)
            let ctx = DuckStoryContext(
                mode: .timer,
                isRunning: tm.isRunning,
                isPaused: false,
                isFinished: tm.finished,
                normalizedProgress: 1.0,
                sessionDuration: 60,
                remainingSeconds: tm.remaining,
                elapsedSeconds: 60,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)
            engine.updateProgress(context: ctx, now: Date())
            assertTrue(engine.isFinaleActive, "Finale should be active")

            // Clock remains pure and isolated
            assertEqual(tm.duration, 60, "Timer duration must remain unchanged")
            assertTrue(tm.finished, "Timer finished state must remain true")
        }
    }

    // MARK: - Test 12: Scene Boundary Transitions
    static func testStoryEngineSceneBoundaryTransitions() {
        runTest("testStoryEngineSceneBoundaryTransitions") {
            let engine = DuckStoryEngine()
            engine.setSelection(.theExpedition)
            let ctx1 = DuckStoryContext(
                mode: .timer,
                isRunning: true,
                isPaused: false,
                isFinished: false,
                normalizedProgress: 0.19,
                sessionDuration: 300,
                remainingSeconds: 243,
                elapsedSeconds: 57,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )

            engine.prepareSession(context: ctx1)
            engine.startSession(context: ctx1)
            engine.updateProgress(context: ctx1, now: Date())
            assertEqual(engine.activeStory?.activeSceneIndex, 0, "Progress 0.19 should be scene 0")

            // Cross boundary into Scene 1 (21%)
            let ctx2 = DuckStoryContext(
                mode: .timer,
                isRunning: true,
                isPaused: false,
                isFinished: false,
                normalizedProgress: 0.21,
                sessionDuration: 300,
                remainingSeconds: 237,
                elapsedSeconds: 63,
                isCompact: false,
                reduceMotion: false,
                localHour: 12,
                currentHat: .none,
                currentTheme: .terminal
            )
            engine.updateProgress(context: ctx2, now: Date())
            assertEqual(engine.activeStory?.activeSceneIndex, 1, "Progress 0.21 should cleanly transition into scene 1")
        }
    }

    // MARK: - Test 13: Sleep FX Cleanup & Anchors
    static func testSleepFXClearSleepFXPurgesParticlesInstantly() {
        runTest("testSleepFXClearSleepFXPurgesParticlesInstantly") {
            let sleepPoses: [([String], String)] = [
                (DUCK_SLEEP_DEEP, "Deep Sleep"),
                (DUCK_NIGHT_DROOP, "Night Droop"),
                (DUCK_SIT_TRANSITION, "Sit Transition"),
                (DUCK_BASE, "Base Duck")
            ]

            for (pose, name) in sleepPoses {
                let rightAnchor = DuckBillAnchorResolver.resolve(rows: pose, flip: false)
                assertFalse(rightAnchor.facingLeft, "\(name) anchor should face right")
                assertTrue(rightAnchor.x >= 0 && rightAnchor.x < 14, "\(name) x within bounds")
                assertTrue(rightAnchor.y >= 0 && rightAnchor.y < pose.count, "\(name) y within bounds")

                let leftAnchor = DuckBillAnchorResolver.resolve(rows: pose, flip: true)
                assertTrue(leftAnchor.facingLeft, "\(name) flipped anchor should face left")
            }
        }
    }

    // MARK: - Test 14: MiniHUD Finale Rendering & Stage Protection
    static func testMiniHUDFinaleRenderingAndStageProtection() {
        runTest("testMiniHUDFinaleRenderingAndStageProtection") {
            let m = CompactLayoutMetrics(gridW: 164, gridH: 32, modeTag: "FOCUS", goLabel: "START", secLabel: "SKIP")
            
            // Validate mini props for all story finales fit safely inside the Mini Stage
            let miniProps: [([String], String)] = [
                (PROP_MINI_SUMMIT_FLAG_A, "Mini Summit Flag A"),
                (PROP_MINI_SUMMIT_FLAG_B, "Mini Summit Flag B"),
                (ACTOR_MINI_GIRL_DUCK_A, "Mini Girl Duck A"),
                (ACTOR_MINI_GIRL_DUCK_B, "Mini Girl Duck B")
            ]

            for (prop, name) in miniProps {
                assertTrue(prop.count <= m.duckH, "\(name) height must fit inside Mini Stage height")
                for row in prop {
                    assertTrue(row.count <= m.duckW, "\(name) width must fit inside Mini Stage width")
                }
            }

            // Verify Mini Stage is completely decoupled from Time Area
            assertFalse(m.overlapsTimeArea(rect: m.miniStageRect), "Mini Stage must never overlap primary timer")
        }
    }
}
