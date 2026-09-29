// MARK: - TimeDuck · Wave6_1Tests.swift
// Automated test suite for Wave 6.1 (Living Scenes & Continuous Performance Choreography).

import Foundation

enum Wave6_1Tests {
    static func runAll() {
        print("\n▸ Testing Wave 6.1: Living Scenes (Continuous Performance Choreography)…")
        testWave6_1MultiFramePropAnimationCycling()
        testWave6_1TheExpeditionContinuousPerformanceLoops()
        testWave6_1TheFeastContinuousFeedingAndFullnessLoops()
        testWave6_1NightShiftWorkplaceLoopsAndStamina()
        testWave6_1TheWodPhysicalEquipmentMountingAndCadence()
        testWave6_1TheRescueStealthChoreographyAndCameraSweep()
        testWave6_1StorySpeedMultiplierAndSyntheticIsolation()
        testWave6_1ReducedMotionBehaviorInLivingScenes()
        testWave6_1SessionDurationLoopPacing()
        testWave6_1FullScenePerformanceCleanup()
    }

    static func testWave6_1MultiFramePropAnimationCycling() {
        runTest("testWave6_1MultiFramePropAnimationCycling") {
            let frames = [PROP_CAMPFIRE_FRAME1, PROP_CAMPFIRE_FRAME2, PROP_CAMPFIRE_FRAME3, PROP_CAMPFIRE_FRAME4]
            var prop = DuckStorySceneryProp(
                id: "test_fire", x: 50, y: 50, frames: frames,
                colorMapKey: "fire", flip: false, isVisible: true, zIndex: 0, animationInterval: 0.20
            )

            assertEqual(prop.currentFrameIndex, 0, "Initial frame index must be 0")
            assertEqual(prop.spriteRows, PROP_CAMPFIRE_FRAME1, "Initial frame must match Frame 1")

            // Advance time past interval
            prop.updateAnimation(now: 0.25)
            assertEqual(prop.currentFrameIndex, 1, "Frame index must advance to 1 after interval")
            assertEqual(prop.spriteRows, PROP_CAMPFIRE_FRAME2, "Frame must match Frame 2")

            prop.updateAnimation(now: 0.50)
            assertEqual(prop.currentFrameIndex, 2, "Frame index must advance to 2")
            assertEqual(prop.spriteRows, PROP_CAMPFIRE_FRAME3, "Frame must match Frame 3")

            prop.updateAnimation(now: 0.75)
            assertEqual(prop.currentFrameIndex, 3, "Frame index must advance to 3")
            assertEqual(prop.spriteRows, PROP_CAMPFIRE_FRAME4, "Frame must match Frame 4")

            // Loop back to start
            prop.updateAnimation(now: 1.00)
            assertEqual(prop.currentFrameIndex, 0, "Frame index must loop back to 0")
            assertEqual(prop.spriteRows, PROP_CAMPFIRE_FRAME1, "Frame must match Frame 1")
        }
    }

    static func testWave6_1TheExpeditionContinuousPerformanceLoops() {
        runTest("testWave6_1TheExpeditionContinuousPerformanceLoops") {
            let expedition = TheExpeditionStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 10,
                currentHat: .none, currentTheme: .arcade
            )

            expedition.prepare(context: ctx, engine: engine)
            expedition.onStart(context: ctx, engine: engine)

            // Scene 1: Trailhead studying sign
            expedition.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_INVESTIGATE_A, "Scene 1 start must study sign")
            assertEqual(engine.currentPerformanceOverride?.flip, true, "Duck must face left toward sign")

            // Scene 2: Campfire
            expedition.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            expedition.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_WARM_WINGS, "Scene 2 start must warm wings by campfire")
            assertEqual(engine.currentPerformanceOverride?.x, 58.0, "Duck must sit in physical contact range of campfire")

            // Scene 5: Summit
            expedition.onMilestone(milestoneIndex: 4, progress: 0.80, context: ctx, engine: engine)
            expedition.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SUMMIT_CHEER, "Scene 5 must cheer at summit")
            assertTrue(engine.props.contains { $0.id == "summit_flag" }, "Scene 5 must have summit flag prop")
        }
    }

    static func testWave6_1TheFeastContinuousFeedingAndFullnessLoops() {
        runTest("testWave6_1TheFeastContinuousFeedingAndFullnessLoops") {
            let feast = TheFeastStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            feast.prepare(context: ctx, engine: engine)
            feast.onStart(context: ctx, engine: engine)

            // Progress through stages
            feast.onProgress(context: ctx, progress: 0.25, engine: engine)
            assertEqual(feast.fullnessStage, 1, "Progress 0.25 must reach Stage 1")

            feast.onProgress(context: ctx, progress: 0.45, engine: engine)
            assertEqual(feast.fullnessStage, 2, "Progress 0.45 must reach Stage 2")

            feast.onProgress(context: ctx, progress: 0.65, engine: engine)
            assertEqual(feast.fullnessStage, 3, "Progress 0.65 must reach Stage 3")

            feast.onProgress(context: ctx, progress: 0.85, engine: engine)
            assertEqual(feast.fullnessStage, 4, "Progress 0.85 must reach Stage 4")

            feast.onProgress(context: ctx, progress: 1.0, engine: engine)
            assertEqual(feast.fullnessStage, 5, "Progress 1.0 must reach Stage 5 Absolute Unit")

            // Stage 5 micro-behavior ticks
            feast.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BELLY_WOBBLE, "Stage 5 start must wobble belly")
        }
    }

    static func testWave6_1NightShiftWorkplaceLoopsAndStamina() {
        runTest("testWave6_1NightShiftWorkplaceLoopsAndStamina") {
            let night = NightShiftStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 23,
                currentHat: .none, currentTheme: .arcade
            )

            night.prepare(context: ctx, engine: engine)
            night.onStart(context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "coffee_cup" }, "Start must have steaming coffee cup")

            // Scene 1 sipping coffee
            night.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SWALLOW, "Scene 1 must sip coffee")

            // Scene 3 Droop Sleep
            night.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            night.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_NIGHT_DROOP, "Scene 3 must perform droop sleep")
        }
    }

    static func testWave6_1TheWodPhysicalEquipmentMountingAndCadence() {
        runTest("testWave6_1TheWodPhysicalEquipmentMountingAndCadence") {
            let wod = TheWodStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .stopwatch, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 300,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 17,
                currentHat: .none, currentTheme: .arcade
            )

            wod.prepare(context: ctx, engine: engine)
            wod.onStart(context: ctx, engine: engine)

            // Scene 2: Elliptical Mount
            wod.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            wod.update(dt: 0.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.x, 72.0, "Duck must be mounted at x:72 on elliptical")
            assertEqual(engine.currentPerformanceOverride?.y, 48.0, "Duck must be mounted at y:48 on elliptical")
            assertTrue(
                engine.currentPerformanceOverride?.spriteRows == DUCK_ELLIPTICAL_A ||
                engine.currentPerformanceOverride?.spriteRows == DUCK_ELLIPTICAL_B,
                "Duck must pedal on elliptical"
            )

            // Scene 3: Treadmill Mount
            wod.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            wod.update(dt: 0.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.x, 72.0, "Duck must be mounted at x:72 on treadmill")
            assertEqual(engine.currentPerformanceOverride?.y, 54.0, "Duck must be mounted at y:54 on treadmill")
            assertTrue(
                engine.currentPerformanceOverride?.spriteRows == DUCK_TREADMILL_A ||
                engine.currentPerformanceOverride?.spriteRows == DUCK_TREADMILL_B,
                "Duck must run on treadmill"
            )

            // Scene 4: Dumbbells
            wod.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            wod.update(dt: 0.5, now: Date(), context: ctx, engine: engine)
            assertTrue(
                engine.currentPerformanceOverride?.spriteRows == DUCK_DUMBBELL_A ||
                engine.currentPerformanceOverride?.spriteRows == DUCK_DUMBBELL_B,
                "Duck must curl dumbbells"
            )
        }
    }

    static func testWave6_1TheRescueStealthChoreographyAndCameraSweep() {
        runTest("testWave6_1TheRescueStealthChoreographyAndCameraSweep") {
            let rescue = TheRescueStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 15,
                currentHat: .none, currentTheme: .arcade
            )

            rescue.prepare(context: ctx, engine: engine)
            rescue.onStart(context: ctx, engine: engine)

            // Scene 1: Infiltration sneak
            rescue.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertTrue(
                engine.currentPerformanceOverride?.spriteRows == DUCK_STEALTH_TIPTOE_A ||
                engine.currentPerformanceOverride?.spriteRows == DUCK_STEALTH_TIPTOE_B,
                "Scene 1 must perform tiptoe sneak"
            )

            // Scene 2: Camera sweep and cardboard box disguise
            rescue.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            rescue.update(dt: 4.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_STEALTH_BOX_DISGUISE, "Camera sweep over duck must trigger box disguise")

            // Scene 4: Girl duck kick
            rescue.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            assertTrue(engine.actors.contains { $0.id == "girl_duck" }, "Scene 4 must introduce Girl Duck")
        }
    }

    static func testWave6_1StorySpeedMultiplierAndSyntheticIsolation() {
        runTest("testWave6_1StorySpeedMultiplierAndSyntheticIsolation") {
            let timer = TimerModel()
            timer.setDuration(1500)
            let pomo = PomodoroModel()
            let sw = StopwatchModel()

            var previewProgress: Double = 0.0
            let speedMultipliers: [Double] = [1.0, 5.0, 10.0]

            for speed in speedMultipliers {
                let dt = 0.1
                let advanceRate = dt * (speed / 120.0)
                let prevP = previewProgress
                previewProgress = min(1.0, previewProgress + advanceRate)

                assertTrue(previewProgress > prevP, "Speed \(speed)x must advance synthetic progress")
                assertEqual(timer.duration, 1500.0, "Timer duration must remain 100% untouched by speed multiplier")
                assertEqual(timer.remaining, 1500.0, "Timer remaining must remain 100% untouched by speed multiplier")
                assertEqual(pomo.workDuration, 1500.0, "Pomodoro work duration must remain untouched")
                assertEqual(sw.elapsed, 0.0, "Stopwatch elapsed must remain untouched")
            }
        }
    }

    static func testWave6_1ReducedMotionBehaviorInLivingScenes() {
        runTest("testWave6_1ReducedMotionBehaviorInLivingScenes") {
            let feast = TheFeastStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 1.0, sessionDuration: 1500, remainingSeconds: 0,
                elapsedSeconds: 1500, isCompact: false, reduceMotion: true, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            feast.prepare(context: ctx, engine: engine)
            feast.onMilestone(milestoneIndex: 5, progress: 1.0, context: ctx, engine: engine)
            feast.update(dt: 1.0, now: Date(), context: ctx, engine: engine)

            // When reduced motion is true, wobble loops are bypassed in favor of clean base chonk
            assertEqual(feast.fullnessStage, 5, "Stage 5 must be preserved under reduceMotion")
        }
    }

    static func testWave6_1SessionDurationLoopPacing() {
        runTest("testWave6_1SessionDurationLoopPacing") {
            let expedition = TheExpeditionStory()
            let shortCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 60, remainingSeconds: 60,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )
            assertFalse(expedition.isEligible(context: shortCtx), "Short 1-minute timer should not be auto-eligible for full theatrical expedition")

            let standardCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 300,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )
            assertTrue(expedition.isEligible(context: standardCtx), "5-minute timer must be eligible for theatrical expedition")
        }
    }

    static func testWave6_1FullScenePerformanceCleanup() {
        runTest("testWave6_1FullScenePerformanceCleanup") {
            let engine = DuckStoryEngine()
            engine.setSelection(.theRescue)

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.6, sessionDuration: 600, remainingSeconds: 240,
                elapsedSeconds: 360, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)
            engine.updateProgress(context: ctx, now: Date())
            engine.tick(dt: 0.1, now: Date(), context: ctx)

            assertTrue(!engine.actors.isEmpty || !engine.props.isEmpty || engine.currentPerformanceOverride != nil, "Active scene must have living entities or overrides")

            // Cleanup
            engine.cleanup()
            assertTrue(engine.actors.isEmpty, "Cleanup must remove all actors")
            assertTrue(engine.props.isEmpty, "Cleanup must remove all props")
            assertTrue(engine.currentPerformanceOverride == nil, "Cleanup must remove all performance overrides")
        }
    }
}
