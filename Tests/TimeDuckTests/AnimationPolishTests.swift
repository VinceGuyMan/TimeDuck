// MARK: - TimeDuck · AnimationPolishTests.swift
// Automated test suite for Wave 7.1 (Animation Director Pass & Motion Polish).

import Foundation

enum AnimationPolishTests {
    static func runAll() {
        print("\n▸ Testing Wave 7.1: Animation Director Pass (Choreography & Motion Polish)…")
        testRedesignedGirlDuckVisualProportionsAndSkullAnchor()
        testRedesignedGuardDuckProportionsAndPivotTurn()
        testTimeDuckTransitionAndAnticipationFrames()
        testTheFeastAnticipationPeckSwallowAndDigestionLoops()
        testTheExpeditionNaturalPacingAndTransitionFrames()
        testNightShiftPacingAndDroopFaceSplash()
        testTheWodPhysicalEquipmentMountingAndWeightBrace()
        testTheRescueStealthChoreographyAndVentKickContact()
        testLivingWardrobeSkullAnchorStabilityAcrossAllNewFrames()
        testStoryLoopStabilityUnderExtendedDurations()
        testReducedMotionComplianceAndTimerIsolation()
    }

    static func testRedesignedGirlDuckVisualProportionsAndSkullAnchor() {
        runTest("testRedesignedGirlDuckVisualProportionsAndSkullAnchor") {
            let girlPoses: [([String], String)] = [
                (ACTOR_GIRL_DUCK_BASE, "Base"),
                (ACTOR_GIRL_DUCK_IDLE_B, "Idle B"),
                (ACTOR_GIRL_DUCK_NOTICE, "Notice"),
                (ACTOR_GIRL_DUCK_WADDLE_A, "Waddle A"),
                (ACTOR_GIRL_DUCK_WADDLE_B, "Waddle B"),
                (ACTOR_GIRL_DUCK_KICK_ANTICIPATE, "Kick Anticipate"),
                (ACTOR_GIRL_DUCK_KICK, "Kick Contact"),
                (ACTOR_GIRL_DUCK_KICK_RECOVER, "Kick Recover"),
                (ACTOR_GIRL_DUCK_CHEER_A, "Cheer A"),
                (ACTOR_GIRL_DUCK_CHEER_B, "Cheer B")
            ]

            for (pose, name) in girlPoses {
                assertEqual(pose.count, 10, "Girl Duck \(name) height must be 10 rows")
                for (rIdx, row) in pose.enumerated() {
                    assertEqual(row.count, 13, "Girl Duck \(name) row \(rIdx) width must be 13 columns")
                }
                // Verify magenta hairbow pixel 'm' on skull crown
                let hasBow = pose[0].contains("m") || pose[1].contains("m")
                assertTrue(hasBow, "Girl Duck \(name) must feature magenta hairbow on skull crown")

                // Verify valid skull anchor resolution
                let anchor = DuckAnchorResolver.resolve(rows: pose)
                assertTrue(anchor.y >= 0 && anchor.y <= 3, "Girl Duck \(name) skull anchor Y must be valid (0...3)")
            }

            // Verify blush cheek 'p' in notice and base poses
            assertTrue(ACTOR_GIRL_DUCK_BASE.contains { $0.contains("p") }, "Girl Duck Base must contain blush pixel 'p'")
            assertTrue(ACTOR_GIRL_DUCK_NOTICE.contains { $0.contains("p") }, "Girl Duck Notice must contain blush pixel 'p'")
        }
    }

    static func testRedesignedGuardDuckProportionsAndPivotTurn() {
        runTest("testRedesignedGuardDuckProportionsAndPivotTurn") {
            let guardPoses: [([String], String)] = [
                (ACTOR_GUARD_DUCK_BASE, "Base"),
                (ACTOR_GUARD_DUCK_PATROL_A, "Patrol A"),
                (ACTOR_GUARD_DUCK_PATROL_B, "Patrol B"),
                (ACTOR_GUARD_DUCK_STOP, "Stop Plant"),
                (ACTOR_GUARD_DUCK_TURN, "Pivot Turn"),
                (ACTOR_GUARD_DUCK_SUSPICIOUS, "Suspicious"),
                (ACTOR_GUARD_DUCK_ALERT, "Alert")
            ]

            for (pose, name) in guardPoses {
                assertEqual(pose.count, 10, "Guard Duck \(name) height must be 10 rows")
                for (rIdx, row) in pose.enumerated() {
                    assertEqual(row.count, 13, "Guard Duck \(name) row \(rIdx) width must be 13 columns")
                }
                // Verify guard security cap pixels 'k' in top rows
                let hasCap = pose[0].contains("k") || pose[1].contains("k")
                assertTrue(hasCap, "Guard Duck \(name) must feature security cap")
            }

            // Verify pivot turn frame differs from patrol frames
            assertTrue(ACTOR_GUARD_DUCK_TURN != ACTOR_GUARD_DUCK_PATROL_A, "Pivot turn must be distinct from patrol A")
            assertTrue(ACTOR_GUARD_DUCK_TURN != ACTOR_GUARD_DUCK_PATROL_B, "Pivot turn must be distinct from patrol B")
            // Verify pivot turn faces center (beak pixels in middle columns)
            assertTrue(ACTOR_GUARD_DUCK_TURN[3].contains("ooo") || ACTOR_GUARD_DUCK_TURN[4].contains("ooo"), "Pivot turn must have front-facing beak")
        }
    }

    static func testTimeDuckTransitionAndAnticipationFrames() {
        runTest("testTimeDuckTransitionAndAnticipationFrames") {
            let transitionFrames: [([String], String)] = [
                (DUCK_BRAKE_STOP, "Brake Stop"),
                (DUCK_SIT_TRANSITION, "Sit Transition"),
                (DUCK_PECK_ANTICIPATE, "Peck Anticipate"),
                (DUCK_PECK_RECOVER, "Peck Recover"),
                (DUCK_WEIGHT_BRACE, "Weight Brace"),
                (DUCK_LEAP_ANTICIPATE, "Leap Anticipate"),
                (DUCK_LEAP_LAND, "Leap Land")
            ]

            for (frame, name) in transitionFrames {
                assertEqual(frame.count, 10, "\(name) height must be 10 rows")
                for (rIdx, row) in frame.enumerated() {
                    assertEqual(row.count, 13, "\(name) row \(rIdx) width must be 13 columns")
                }
                let anchor = DuckAnchorResolver.resolve(rows: frame)
                assertTrue(anchor.y >= 0 && anchor.y <= 3, "\(name) skull anchor Y must be valid (0...3)")
            }
        }
    }

    static func testTheFeastAnticipationPeckSwallowAndDigestionLoops() {
        runTest("testTheFeastAnticipationPeckSwallowAndDigestionLoops") {
            let feast = TheFeastStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            feast.prepare(context: ctx, engine: engine)
            feast.onStart(context: ctx, engine: engine)

            // 1. Neutral stage (0.5s)
            feast.update(dt: 0.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BASE, "0.5s must be neutral base")

            // 2. Anticipation stage (2.5s)
            feast.update(dt: 2.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_PECK_ANTICIPATE, "2.5s must pull head back in peck anticipation")

            // 3. Physical peck contact (4.0s)
            feast.update(dt: 1.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_PECK_B, "4.0s must peck crumb with physical contact")

            // 4. Swallow & settle (6.0s)
            feast.update(dt: 2.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SWALLOW, "6.0s must swallow crumb")

            // 5. Digestion completion sequence
            feast.onComplete(context: ctx, engine: engine)
            assertTrue(feast.isDigesting, "Feast onComplete must trigger digestion mode")
        }
    }

    static func testTheExpeditionNaturalPacingAndTransitionFrames() {
        runTest("testTheExpeditionNaturalPacingAndTransitionFrames") {
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

            // Scene 1 Trailhead: studies sign -> checks map -> folds map -> waddles -> brakes -> looks ahead
            expedition.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_INVESTIGATE_A, "1.0s must study sign")

            expedition.update(dt: 3.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_MAP_CHECK_B, "4.5s must check map")

            expedition.update(dt: 5.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BRAKE_STOP, "10.0s must plant feet with brake stop")

            // Scene 2 Campfire: lowers to sit -> warms wings -> pokes fire -> dozes -> rises up -> ruffles
            expedition.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            expedition.update(dt: 0.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SIT_TRANSITION, "Campfire start must lower with sit transition")

            expedition.update(dt: 2.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_WARM_WINGS, "3.0s must warm wings by fire")

            expedition.update(dt: 9.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SIT_TRANSITION, "12.0s must rise up with sit transition")

            // Scene 3 Climb: brake stop at rock -> steps onto Rock A -> balances -> steps to Rock B
            expedition.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            expedition.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BRAKE_STOP, "Climb start must brace with brake stop")
        }
    }

    static func testNightShiftPacingAndDroopFaceSplash() {
        runTest("testNightShiftPacingAndDroopFaceSplash") {
            let night = NightShiftStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 23,
                currentHat: .none, currentTheme: .arcade
            )

            night.prepare(context: ctx, engine: engine)
            night.onStart(context: ctx, engine: engine)

            // Scene 1: sips coffee -> wag -> typing -> waddle -> brake stop
            night.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_SWALLOW, "1.0s must sip coffee")

            night.update(dt: 3.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_IDLE_WAG, "4.0s must wag tail refreshed")

            night.update(dt: 6.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BRAKE_STOP, "10.5s must brake stop")

            // Scene 3: droop sleep -> snap awake -> cold face splash
            night.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            night.update(dt: 2.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_NIGHT_DROOP, "2.0s must droop sleep")

            night.update(dt: 3.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_NIGHT_SNAP_AWAKE, "5.0s must snap awake")

            night.update(dt: 2.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_NIGHT_FACE_SPLASH, "7.5s must cold face splash")
        }
    }

    static func testTheWodPhysicalEquipmentMountingAndWeightBrace() {
        runTest("testTheWodPhysicalEquipmentMountingAndWeightBrace") {
            let wod = TheWodStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .stopwatch, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 0,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 15,
                currentHat: .none, currentTheme: .arcade
            )

            wod.prepare(context: ctx, engine: engine)
            wod.onStart(context: ctx, engine: engine)

            // Scene 2 Elliptical: mounted at (x: 72, y: 48)
            wod.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            wod.update(dt: 2.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.x, 72.0, "Elliptical X must mount at 72")
            assertEqual(engine.currentPerformanceOverride?.y, 48.0, "Elliptical Y must mount at 48")

            // Scene 3 Treadmill: mounted at (x: 72, y: 54)
            wod.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            wod.update(dt: 2.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.x, 72.0, "Treadmill X must mount at 72")
            assertEqual(engine.currentPerformanceOverride?.y, 54.0, "Treadmill Y must mount at 54")

            // Scene 4 Dumbbells: curls -> peak contraction -> lower -> weight brace
            wod.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            wod.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            assertTrue(
                engine.currentPerformanceOverride?.spriteRows == DUCK_DUMBBELL_A ||
                engine.currentPerformanceOverride?.spriteRows == DUCK_DUMBBELL_B,
                "Dumbbell start must curl weights"
            )

            wod.update(dt: 6.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_DUMBBELL_B, "7.0s must hold peak bicep contraction")

            wod.update(dt: 4.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_WEIGHT_BRACE, "11.0s must brace knees with DUCK_WEIGHT_BRACE")
        }
    }

    static func testTheRescueStealthChoreographyAndVentKickContact() {
        runTest("testTheRescueStealthChoreographyAndVentKickContact") {
            let rescue = TheRescueStory()
            let engine = DuckStoryEngine()

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 600, remainingSeconds: 600,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            rescue.prepare(context: ctx, engine: engine)
            rescue.onStart(context: ctx, engine: engine)

            // Scene 1 Infiltration: tiptoe -> brake stop -> corner peek -> crouch
            rescue.update(dt: 4.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_BRAKE_STOP, "4.5s must brake stop into crate cover")

            // Scene 2 Cameras: box disguise drops BEFORE sweep passes
            rescue.onMilestone(milestoneIndex: 1, progress: 0.20, context: ctx, engine: engine)
            rescue.update(dt: 3.0, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_STEALTH_BOX_DISGUISE, "3.0s must drop box disguise before beam reaches duck")

            // Scene 3 Guard Patrol: guard patrol -> stop plant -> front-facing pivot turn -> patrol back
            rescue.onMilestone(milestoneIndex: 2, progress: 0.40, context: ctx, engine: engine)
            rescue.update(dt: 5.0, now: Date(), context: ctx, engine: engine)
            let guardActor = engine.actors.first { $0.id == "guard_duck" }
            assertTrue(guardActor != nil, "Scene 3 must contain Guard Duck actor")
            assertEqual(guardActor?.spriteRows, ACTOR_GUARD_DUCK_STOP, "5.0s guard must plant feet with ACTOR_GUARD_DUCK_STOP")

            rescue.update(dt: 1.0, now: Date(), context: ctx, engine: engine) // 6.0s
            let turningGuard = engine.actors.first { $0.id == "guard_duck" }
            assertEqual(turningGuard?.spriteRows, ACTOR_GUARD_DUCK_TURN, "6.0s guard must execute front-facing pivot turn")

            // Scene 4 Girl Duck Reunion: notice blush -> waddles to vent -> winds up kick -> kicks vent with physical contact
            rescue.onMilestone(milestoneIndex: 3, progress: 0.60, context: ctx, engine: engine)
            rescue.update(dt: 1.0, now: Date(), context: ctx, engine: engine)
            let girlNotice = engine.actors.first { $0.id == "girl_duck" }
            assertEqual(girlNotice?.spriteRows, ACTOR_GIRL_DUCK_NOTICE, "Scene 4 start Girl Duck must notice with blush")

            rescue.update(dt: 5.0, now: Date(), context: ctx, engine: engine) // 6.0s
            let girlWindup = engine.actors.first { $0.id == "girl_duck" }
            assertEqual(girlWindup?.spriteRows, ACTOR_GIRL_DUCK_KICK_ANTICIPATE, "6.0s Girl Duck must wind up leg in kick anticipation")

            rescue.update(dt: 1.5, now: Date(), context: ctx, engine: engine) // 7.5s
            let girlKick = engine.actors.first { $0.id == "girl_duck" }
            assertEqual(girlKick?.spriteRows, ACTOR_GIRL_DUCK_KICK, "7.5s Girl Duck must kick vent with physical contact")

            // Scene 5 Freedom Leap: sprint -> deep leap anticipation -> airborne leap together -> cushion landing -> cheer
            rescue.onMilestone(milestoneIndex: 4, progress: 0.80, context: ctx, engine: engine)
            rescue.update(dt: 4.5, now: Date(), context: ctx, engine: engine)
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_LEAP_ANTICIPATE, "4.5s TimeDuck must crouch in deep leap anticipation")

            rescue.update(dt: 1.5, now: Date(), context: ctx, engine: engine) // 6.0s
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_STEALTH_LEAP, "6.0s TimeDuck must be airborne in freedom leap")

            rescue.update(dt: 2.0, now: Date(), context: ctx, engine: engine) // 8.0s
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_LEAP_LAND, "8.0s TimeDuck must cushion landing with DUCK_LEAP_LAND")
        }
    }

    static func testLivingWardrobeSkullAnchorStabilityAcrossAllNewFrames() {
        runTest("testLivingWardrobeSkullAnchorStabilityAcrossAllNewFrames") {
            let allNewSprites: [([String], String)] = [
                (ACTOR_GIRL_DUCK_BASE, "Girl Duck Base"),
                (ACTOR_GIRL_DUCK_IDLE_B, "Girl Duck Idle B"),
                (ACTOR_GIRL_DUCK_NOTICE, "Girl Duck Notice"),
                (ACTOR_GIRL_DUCK_WADDLE_A, "Girl Duck Waddle A"),
                (ACTOR_GIRL_DUCK_WADDLE_B, "Girl Duck Waddle B"),
                (ACTOR_GIRL_DUCK_KICK_ANTICIPATE, "Girl Duck Kick Anticipate"),
                (ACTOR_GIRL_DUCK_KICK, "Girl Duck Kick Contact"),
                (ACTOR_GIRL_DUCK_KICK_RECOVER, "Girl Duck Kick Recover"),
                (ACTOR_GIRL_DUCK_CHEER_A, "Girl Duck Cheer A"),
                (ACTOR_GIRL_DUCK_CHEER_B, "Girl Duck Cheer B"),
                (ACTOR_GUARD_DUCK_BASE, "Guard Duck Base"),
                (ACTOR_GUARD_DUCK_PATROL_A, "Guard Duck Patrol A"),
                (ACTOR_GUARD_DUCK_PATROL_B, "Guard Duck Patrol B"),
                (ACTOR_GUARD_DUCK_STOP, "Guard Duck Stop"),
                (ACTOR_GUARD_DUCK_TURN, "Guard Duck Turn"),
                (ACTOR_GUARD_DUCK_SUSPICIOUS, "Guard Duck Suspicious"),
                (ACTOR_GUARD_DUCK_ALERT, "Guard Duck Alert"),
                (DUCK_BRAKE_STOP, "Duck Brake Stop"),
                (DUCK_SIT_TRANSITION, "Duck Sit Transition"),
                (DUCK_PECK_ANTICIPATE, "Duck Peck Anticipate"),
                (DUCK_PECK_RECOVER, "Duck Peck Recover"),
                (DUCK_WEIGHT_BRACE, "Duck Weight Brace"),
                (DUCK_LEAP_ANTICIPATE, "Duck Leap Anticipate"),
                (DUCK_LEAP_LAND, "Duck Leap Land")
            ]

            let allHats = DuckHat.allCases.filter { $0 != .none }

            for (sprite, spriteName) in allNewSprites {
                let anchor = DuckAnchorResolver.resolve(rows: sprite)
                assertTrue(anchor.y >= 0 && anchor.y <= 4, "\(spriteName) anchor Y (\(anchor.y)) must be within range 0...4")

                for hat in allHats {
                    let accessory = AccessoryAttachment.getSprite(for: hat, anchor: anchor)
                    assertTrue(!accessory.rows.isEmpty, "\(spriteName) with \(hat.displayName) must resolve non-empty accessory rows")
                }
            }
        }
    }

    static func testStoryLoopStabilityUnderExtendedDurations() {
        runTest("testStoryLoopStabilityUnderExtendedDurations") {
            let stories: [DuckStory] = [
                TheFeastStory(),
                TheExpeditionStory(),
                NightShiftStory(),
                TheWodStory(),
                TheRescueStory()
            ]

            let ctx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.50, sessionDuration: 600, remainingSeconds: 300,
                elapsedSeconds: 300, isCompact: false, reduceMotion: false, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            for story in stories {
                let engine = DuckStoryEngine()
                story.prepare(context: ctx, engine: engine)
                story.onStart(context: ctx, engine: engine)

                // Simulate 60 seconds of 10Hz updates (600 frames)
                for _ in 0..<600 {
                    story.update(dt: 0.1, now: Date(), context: ctx, engine: engine)
                    engine.tick(dt: 0.1, now: Date(), context: ctx)

                    if let ov = engine.currentPerformanceOverride {
                        if let x = ov.x {
                            assertTrue(!x.isNaN && !x.isInfinite, "\(story.title) X coordinate must remain finite")
                            assertTrue(x >= -20 && x <= 200, "\(story.title) X coordinate \(x) must be on stage")
                        }
                        if let y = ov.y {
                            assertTrue(!y.isNaN && !y.isInfinite, "\(story.title) Y coordinate must remain finite")
                        }
                        if let rows = ov.spriteRows {
                            assertEqual(rows.count, 10, "\(story.title) sprite must have 10 rows")
                        }
                    }

                    for actor in engine.actors {
                        assertTrue(!actor.x.isNaN && !actor.x.isInfinite, "\(story.title) actor X must remain finite")
                    }
                }
            }
        }
    }

    static func testReducedMotionComplianceAndTimerIsolation() {
        runTest("testReducedMotionComplianceAndTimerIsolation") {
            let feast = TheFeastStory()
            let engine = DuckStoryEngine()

            let reducedMotionCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.50, sessionDuration: 600, remainingSeconds: 300,
                elapsedSeconds: 300, isCompact: false, reduceMotion: true, localHour: 12,
                currentHat: .none, currentTheme: .arcade
            )

            feast.prepare(context: reducedMotionCtx, engine: engine)
            feast.onStart(context: reducedMotionCtx, engine: engine)
            feast.onProgress(context: reducedMotionCtx, progress: 0.50, engine: engine)
            feast.update(dt: 1.0, now: Date(), context: reducedMotionCtx, engine: engine)

            // Verify static posture is held without jumping animations
            assertEqual(engine.currentPerformanceOverride?.spriteRows, DUCK_CHONK_STAGE2, "Under Reduced Motion, Feast Stage 2 must hold static chonky frame")
        }
    }
}
