// MARK: - TimeDuck · Wave6Tests.swift
// Dedicated automated test suite for Wave 6: Duck Stories.
// Validates story engine architecture, normalized progress, milestone ordering,
// secondary actors, procedural scenery, all 5 reference stories, and timer isolation.

import Foundation

struct Wave6Tests {
    static func runAll() {
        print("▸ Testing Wave 6: Duck Stories (Theatrical Shows & Narrative Engine)…")
        testWave6StoryRegistryAndSelection()
        testWave6AutoSelectionLogic()
        testWave6NormalizedProgressAndMilestoneOrdering()
        testWave6MissedMilestoneRecovery()
        testWave6TimerIsolationGuarantee()
        testWave6TheFeastFullnessStages()
        testWave6TheExpeditionPropsAndCompletion()
        testWave6NightShiftTimeEligibilityAndCoffee()
        testWave6TheWodGymMachineSequence()
        testWave6TheRescueFiveActsAndActors()
        testWave6SecondaryActorLifecycleAndMovement()
        testWave6LivingWardrobeAttachmentAcrossWave6Poses()
        testWave6StoryCleanupContract()
        testWave6SyntheticProgressIsolationAndStoryCheckpoints()
    }

    static func testWave6StoryRegistryAndSelection() {
        runTest("testWave6StoryRegistryAndSelection") {
            UserDefaults.standard.removeObject(forKey: "td.storySelection")
            let engine = DuckStoryEngine(initialSelection: .auto)
            assertTrue(engine.selectedStoryId == .auto, "Default story selection must be .auto")
            
            let allIds = DuckStoryId.allCases
            assertEqual(allIds.count, 7, "DuckStoryId must have 7 cases (off, auto, 5 stories)")
            
            for id in allIds {
                assertTrue(!id.displayName.isEmpty, "Story display name must not be empty for \(id)")
            }

            engine.setSelection(.theFeast)
            assertTrue(engine.selectedStoryId == .theFeast, "Story selection should update to .theFeast")
        }
    }

    static func testWave6AutoSelectionLogic() {
        runTest("testWave6AutoSelectionLogic") {
            let engine = DuckStoryEngine()
            engine.setSelection(.auto)

            // 1. Late night context (hour = 23) -> Night Shift
            let lateNightCtx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 23,
                currentHat: .none, currentTheme: .arcade
            )
            let resolvedNight = engine.resolveActiveStory(context: lateNightCtx)
            assertTrue(resolvedNight?.id == .nightShift, "Late night auto selection must choose Night Shift")

            // 2. Stopwatch session -> nil (Stories strictly scoped to Pomodoro in Wave 8.1)
            let swCtx = DuckStoryContext(
                mode: .stopwatch, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.2, sessionDuration: 300, remainingSeconds: 240,
                elapsedSeconds: 60, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let resolvedSw = engine.resolveActiveStory(context: swCtx)
            assertTrue(resolvedSw == nil, "Stopwatch mode must not trigger stories")

            // 3. Standard Pomodoro focus (hour = 14) -> Story resolves (The Feast / The Expedition / The WOD)
            let pomoCtx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 300,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let resolvedPomo = engine.resolveActiveStory(context: pomoCtx)
            assertTrue(resolvedPomo?.id == .theFeast, "Daytime pomodoro auto selection must choose The Feast")
        }
    }

    static func testWave6NormalizedProgressAndMilestoneOrdering() {
        runTest("testWave6NormalizedProgressAndMilestoneOrdering") {
            let engine = DuckStoryEngine()
            engine.setSelection(.theFeast)

            var spoken: [String] = []
            engine.onSpeak = { text, _ in spoken.append(text) }

            var ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)
            assertTrue(spoken.contains("FUEL ACQUIRED."), "Start must trigger opening phrase")

            // Step through milestones
            let steps: [Double] = [0.20, 0.40, 0.60, 0.80, 1.00]
            for (i, p) in steps.enumerated() {
                ctx.normalizedProgress = p
                engine.updateProgress(context: ctx, now: Date())
                assertEqual(engine.currentMilestoneIndex, i + 1, "Milestone index should advance to \(i + 1)")
            }
        }
    }

    static func testWave6MissedMilestoneRecovery() {
        runTest("testWave6MissedMilestoneRecovery") {
            let engine = DuckStoryEngine()
            engine.setSelection(.theFeast)

            var ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)

            // Jump immediately to 75% progress (simulating wake from sleep)
            ctx.normalizedProgress = 0.75
            engine.updateProgress(context: ctx, now: Date())

            // Should cleanly advance to milestone 3 (60%)
            assertEqual(engine.currentMilestoneIndex, 3, "Engine must recover to highest milestone without freezing")
            if let feast = engine.activeStory as? TheFeastStory {
                assertEqual(feast.fullnessStage, 3, "Feast story must reflect stage 3 fullness")
            }
        }
    }

    static func testWave6TimerIsolationGuarantee() {
        runTest("testWave6TimerIsolationGuarantee") {
            let timer = TimerModel()
            timer.setDuration(300)
            timer.toggle()

            let engine = DuckStoryEngine()
            engine.setSelection(.theRescue)

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: timer.isRunning, isPaused: !timer.isRunning, isFinished: timer.finished,
                normalizedProgress: 0.5, sessionDuration: 300, remainingSeconds: timer.remaining,
                elapsedSeconds: 150, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            engine.prepareSession(context: ctx)
            engine.startSession(context: ctx)
            engine.updateProgress(context: ctx, now: Date())

            // Assert timer accuracy is 100% unaffected by story execution
            assertTrue(timer.isRunning, "Timer running state must be completely isolated from story engine")
            assertEqual(timer.remaining, 300.0, accuracy: 1.0, "Timer remaining value must remain mathematically authoritative")
            assertEqual(timer.duration, 300.0, "Timer duration must remain mathematically authoritative")

            timer.clear()
            engine.cancelSession(context: ctx)
            assertTrue(engine.actors.isEmpty, "Cancelling session must cleanly wipe story actors")
            assertTrue(engine.props.isEmpty, "Cancelling session must cleanly wipe story props")
        }
    }

    static func testWave6TheFeastFullnessStages() {
        runTest("testWave6TheFeastFullnessStages") {
            let feast = TheFeastStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            feast.prepare(context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 0, "Initial stage must be 0")

            feast.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 1, "Milestone 1 must be stage 1")
            assertTrue(feast.getSpriteOverride() == DUCK_CHONK_STAGE1, "Stage 1 must return DUCK_CHONK_STAGE1")

            feast.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 2, "Milestone 2 must be stage 2")
            assertTrue(feast.getSpriteOverride() == DUCK_CHONK_STAGE2, "Stage 2 must return DUCK_CHONK_STAGE2")

            feast.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 3, "Milestone 3 must be stage 3")
            assertTrue(feast.getSpriteOverride() == DUCK_CHONK_STAGE3, "Stage 3 must return DUCK_CHONK_STAGE3")

            feast.onMilestone(milestoneIndex: 4, progress: 0.80, context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 4, "Milestone 4 must be stage 4")
            assertTrue(feast.getSpriteOverride() == DUCK_CHONK_STAGE4, "Stage 4 must return DUCK_CHONK_STAGE4")

            feast.onMilestone(milestoneIndex: 5, progress: 1.00, context: ctx, engine: engine)
            assertEqual(feast.fullnessStage, 5, "Milestone 5 must be stage 5 (Absolute Unit)")
            assertTrue(feast.getSpriteOverride() == DUCK_CHONK_STAGE5, "Stage 5 must return DUCK_CHONK_STAGE5")
        }
    }

    static func testWave6TheExpeditionPropsAndCompletion() {
        runTest("testWave6TheExpeditionPropsAndCompletion") {
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
            assertTrue(engine.props.contains { $0.id == "trail_sign" }, "Start must place trail sign prop")

            expedition.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "campfire" }, "Milestone 1 must place campfire prop")

            expedition.onComplete(context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "summit_flag" }, "Completion must plant summit flag")
        }
    }

    static func testWave6NightShiftTimeEligibilityAndCoffee() {
        runTest("testWave6NightShiftTimeEligibilityAndCoffee") {
            let night = NightShiftStory()
            let engine = DuckStoryEngine()

            let dayCtx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            assertFalse(night.isEligible(context: dayCtx), "Night Shift should not be auto-eligible at 2:00 PM")

            let nightCtx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 23,
                currentHat: .none, currentTheme: .arcade
            )
            assertTrue(night.isEligible(context: nightCtx), "Night Shift must be eligible at 11:00 PM")

            night.prepare(context: nightCtx, engine: engine)
            night.onStart(context: nightCtx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "coffee_cup" }, "Start must spawn coffee cup prop")

            night.onMilestone(milestoneIndex: 2, progress: 0.40, context: nightCtx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "coffee_stack" }, "Milestone 2 must spawn coffee stack prop")
        }
    }

    static func testWave6TheWodGymMachineSequence() {
        runTest("testWave6TheWodGymMachineSequence") {
            let wod = TheWodStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .stopwatch, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 300,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 15,
                currentHat: .none, currentTheme: .arcade
            )

            wod.prepare(context: ctx, engine: engine)
            wod.onStart(context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "workout_board" }, "Start must spawn workout board")

            wod.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "elliptical" }, "Milestone 1 must spawn elliptical machine")

            wod.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "treadmill" }, "Milestone 2 must spawn treadmill")

            wod.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "dumbbells" }, "Milestone 3 must spawn dumbbell rack")
        }
    }

    static func testWave6TheRescueFiveActsAndActors() {
        runTest("testWave6TheRescueFiveActsAndActors") {
            let rescue = TheRescueStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 16,
                currentHat: .none, currentTheme: .arcade
            )

            // Act 1: Infiltration
            rescue.prepare(context: ctx, engine: engine)
            rescue.onStart(context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "metal_crate" }, "Act 1 must place metal crate prop")

            // Act 2: Security Camera Sweep
            rescue.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "security_cam" }, "Act 2 must spawn security camera")

            // Act 3: Guard Duck Patrol
            rescue.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            assertTrue(engine.actors.contains { $0.id == "guard_duck" }, "Act 3 must spawn Guard Duck actor")

            // Act 4: Girl Duck Encounter
            rescue.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            assertTrue(engine.actors.contains { $0.id == "girl_duck" }, "Act 4 must introduce Girl Duck actor")

            // Act 5: Escape & Payoff
            rescue.onMilestone(milestoneIndex: 4, progress: 0.80, context: ctx, engine: engine)
            assertTrue(engine.props.contains { $0.id == "warning_light" }, "Act 5 must activate warning light")

            rescue.onComplete(context: ctx, engine: engine)
            assertTrue(engine.actors.contains { $0.id == "girl_duck" }, "Completion must show Girl Duck celebration")
        }
    }

    static func testWave6SecondaryActorLifecycleAndMovement() {
        runTest("testWave6SecondaryActorLifecycleAndMovement") {
            var actor = DuckStoryActor(
                id: "test_guard", name: "Guard", x: 100.0, y: 50.0,
                spriteRows: ACTOR_GUARD_DUCK_PATROL_A, colorMapOverride: nil,
                flip: false, isVisible: true, targetX: 60.0, moveSpeed: 20.0
            )

            // Update 1 second of movement
            actor.updateMovement(dt: 1.0)
            assertEqual(actor.x, 80.0, "Actor must advance toward target by moveSpeed * dt (100 - 20 = 80)")
            assertTrue(actor.flip == true, "Moving left must set flip = true")

            // Update another 1.5 seconds -> arrives at target
            actor.updateMovement(dt: 1.5)
            assertEqual(actor.x, 60.0, "Actor must snap to target when within reach")
            assertTrue(actor.targetX == nil, "targetX must clear upon arrival")
        }
    }

    static func testWave6LivingWardrobeAttachmentAcrossWave6Poses() {
        runTest("testWave6LivingWardrobeAttachmentAcrossWave6Poses") {
            let poses: [([String], String)] = [
                (DUCK_CHONK_STAGE1, "DUCK_CHONK_STAGE1"),
                (DUCK_CHONK_STAGE2, "DUCK_CHONK_STAGE2"),
                (DUCK_CHONK_STAGE3, "DUCK_CHONK_STAGE3"),
                (DUCK_CHONK_STAGE4, "DUCK_CHONK_STAGE4"),
                (DUCK_CHONK_STAGE5, "DUCK_CHONK_STAGE5"),
                (DUCK_MAP_CHECK_A, "DUCK_MAP_CHECK_A"),
                (DUCK_MAP_CHECK_B, "DUCK_MAP_CHECK_B"),
                (DUCK_SUMMIT_CHEER, "DUCK_SUMMIT_CHEER"),
                (DUCK_NIGHT_DROOP, "DUCK_NIGHT_DROOP"),
                (DUCK_NIGHT_SNAP_AWAKE, "DUCK_NIGHT_SNAP_AWAKE"),
                (DUCK_ELLIPTICAL_A, "DUCK_ELLIPTICAL_A"),
                (DUCK_TREADMILL_A, "DUCK_TREADMILL_A"),
                (DUCK_DUMBBELL_B, "DUCK_DUMBBELL_B"),
                (DUCK_WOD_FLEX, "DUCK_WOD_FLEX"),
                (DUCK_STEALTH_CROUCH, "DUCK_STEALTH_CROUCH"),
                (DUCK_STEALTH_TIPTOE_A, "DUCK_STEALTH_TIPTOE_A"),
                (DUCK_STEALTH_LEAP, "DUCK_STEALTH_LEAP")
            ]

            for (matrix, name) in poses {
                let anchor = DuckAnchorResolver.resolve(rows: matrix)
                assertTrue(anchor.x >= -3 && anchor.x <= 3, "Anchor X must be within [-3, 3] for \(name)")
                assertTrue(anchor.y >= 0 && anchor.y <= 6, "Anchor Y must be within [0, 6] for \(name)")

                for hat in DuckHat.allCases where hat != .none {
                    let attachment = AccessoryAttachment.getSprite(for: hat, anchor: anchor)
                    assertTrue(!attachment.rows.isEmpty, "Hat \(hat) must produce sprite rows for \(name)")
                }
            }
        }
    }

    static func testWave6StoryCleanupContract() {
        runTest("testWave6StoryCleanupContract") {
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

            assertTrue(!engine.actors.isEmpty || !engine.props.isEmpty, "Active story should contain actors or props")

            // Cancel / Cleanup
            engine.cancelSession(context: ctx)
            assertTrue(engine.actors.isEmpty, "Engine cleanup must remove all actors")
            assertTrue(engine.props.isEmpty, "Engine cleanup must remove all props")
            assertEqual(engine.currentMilestoneIndex, 0, "Engine cleanup must reset milestone index to 0")
        }
    }

    static func testWave6SyntheticProgressIsolationAndStoryCheckpoints() {
        runTest("testWave6SyntheticProgressIsolationAndStoryCheckpoints") {
            let timer = TimerModel()
            timer.setDuration(1500)
            let pomo = PomodoroModel()
            let sw = StopwatchModel()

            let stories: [DuckStoryId] = [.theFeast, .theExpedition, .nightShift, .theWod, .theRescue]
            let checkpoints: [Double] = [0.0, 0.20, 0.40, 0.60, 0.80, 1.00]

            for storyId in stories {
                let engine = DuckStoryEngine(initialSelection: storyId)
                for p in checkpoints {
                    let syntheticDuration = 300.0
                    let syntheticElapsed = syntheticDuration * p
                    let syntheticRemaining = max(0.0, syntheticDuration - syntheticElapsed)

                    let syntheticCtx = DuckStoryContext(
                        mode: .timer,
                        isRunning: true,
                        isPaused: false,
                        isFinished: p >= 1.0,
                        normalizedProgress: p,
                        sessionDuration: syntheticDuration,
                        remainingSeconds: syntheticRemaining,
                        elapsedSeconds: syntheticElapsed,
                        isCompact: false,
                        reduceMotion: false,
                        localHour: (storyId == .nightShift ? 23 : 14),
                        currentHat: .none,
                        currentTheme: .arcade
                    )

                    engine.prepareSession(context: syntheticCtx)
                    engine.startSession(context: syntheticCtx)
                    if p > 0.0 {
                        engine.updateProgress(context: syntheticCtx, now: Date())
                    }

                    // Verify timer, pomo, sw engines remained 100% untouched
                    assertEqual(timer.duration, 1500.0, "Timer duration must not be modified by preview")
                    assertEqual(timer.remaining, 1500.0, "Timer remaining must not be modified by preview")
                    assertFalse(timer.isRunning, "Timer running state must not be modified by preview")
                    assertEqual(pomo.workDuration, 1500.0, "Pomodoro work duration must not be modified by preview")
                    assertEqual(sw.elapsed, 0.0, "Stopwatch elapsed must not be modified by preview")

                    // Clean up
                    engine.cleanup()
                    assertTrue(engine.actors.isEmpty, "Cleanup must remove all actors for \(storyId) at \(Int(p * 100))%")
                    assertTrue(engine.props.isEmpty, "Cleanup must remove all props for \(storyId) at \(Int(p * 100))%")
                }
            }
        }
    }
}
