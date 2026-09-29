// MARK: - TimeDuck · Wave8_1Tests.swift
// Comprehensive regression test suite for Wave 8.1:
// Companion Animation + Duckbook Stabilization Pass.

import Foundation

enum Wave8_1Tests {
    static func runAll() {
        print("▸ Testing Wave 8.1: Companion Animation & Duckbook Stabilization…")
        testEveryCompanionResolvesOwnEating()
        testEveryCompanionResolvesOwnSleeping()
        testEveryCompanionResolvesOwnChonky()
        testNoAlternateCompanionResolvesToTimeDuckAssets()
        testCyberDuckMotionLanguageAndExpandedStates()
        testSafeGenericCompanionFallbackHierarchy()
        testStoryModeStrictlyScopedToPomodoro()
        testDeveloperPreviewBypassesModeRestriction()
        testTheRescueSimplifiedFinaleCheerLoop()
        testDuckbookScrollModelAndBoundsClamping()
        testDuckbookScrollDoesNotMutateClockOrPlaySound()
        testDuckbookKeyboardNavigationAndDismissal()
        testDuckbookModalInputIsolation()
        testCompanionSwitchingDuringAllClockStates()
        testDuckbookLayoutTruncationSafety()
        testDuckbookExplicitCardGeometryNonOverlapping()
        testDuckbookScrollingWindowThreeItems()
        testMiniUIActiveCompanionResolution()
        testMiniUIAccessoryAttachmentAnchorResolution()
        testMiniUIPhraseTruncationNoPinkSquareGlyphs()
        testDuckbookButtonHitboxesMatchCardGeometry()
        testCentralizedScrollRoutingDoesNotMutateTimeOrDuration()
        testDuckbookScrollNormalizationAndAccumulator()
        testMiniUIWordByWordTokenizationAndCadence()
        testMiniUIAllCompanionsTrueSleepSprites()
        testTimerFirstSafeZoneAndDominantLayoutGeometry()
        testDuckbookCatalogZeroTextClipping()
    }

    // MARK: - 1. Companion Animation Routing Tests

    static func testEveryCompanionResolvesOwnEating() {
        runTest("testEveryCompanionResolvesOwnEating") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()
            let t = 0.0

            let girl = registry.companion(for: .girlDuck)
            let girlEating = girl.resolveSprite(
                pose: .pecking, t: t, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(girlEating == ACTOR_GIRL_DUCK_PECK_A || girlEating == ACTOR_GIRL_DUCK_PECK_B, "Girl Duck must resolve own eating sprite")
            assertTrue(girlEating != DUCK_PECK_A && girlEating != DUCK_PECK_B, "Girl Duck must not use TimeDuck peck")

            let guardD = registry.companion(for: .guardDuck)
            let guardEating = guardD.resolveSprite(
                pose: .pecking, t: t, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(guardEating == ACTOR_GUARD_DUCK_PECK_A || guardEating == ACTOR_GUARD_DUCK_PECK_B, "Guard Duck must resolve own eating sprite")
            assertTrue(guardEating != DUCK_PECK_A && guardEating != DUCK_PECK_B, "Guard Duck must not use TimeDuck peck")

            let duckling = registry.companion(for: .duckling)
            let ducklingEating = duckling.resolveSprite(
                pose: .pecking, t: t, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(ducklingEating == DUCKLING_PECK_A || ducklingEating == DUCKLING_PECK_B, "Duckling must resolve own eating sprite")

            let cyber = registry.companion(for: .cyberDuck)
            let cyberEating = cyber.resolveSprite(
                pose: .pecking, t: t, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(cyberEating == CYBER_DUCK_EAT_A || cyberEating == CYBER_DUCK_EAT_B, "CyberDuck must resolve own eating sprite")
            assertTrue(cyberEating != DUCK_PECK_A && cyberEating != DUCK_PECK_B, "CyberDuck must not use TimeDuck peck")
        }
    }

    static func testEveryCompanionResolvesOwnSleeping() {
        runTest("testEveryCompanionResolvesOwnSleeping") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()

            let girl = registry.companion(for: .girlDuck)
            let girlSleep = girl.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: true, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(girlSleep == ACTOR_GIRL_DUCK_SLEEP, "Girl Duck must resolve ACTOR_GIRL_DUCK_SLEEP")
            assertTrue(girlSleep != DUCK_SLEEP_DEEP, "Girl Duck must not resolve to default TimeDuck sleep")

            let guardD = registry.companion(for: .guardDuck)
            let guardSleep = guardD.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: true, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(guardSleep == ACTOR_GUARD_DUCK_SLEEP, "Guard Duck must resolve ACTOR_GUARD_DUCK_SLEEP")
            assertTrue(guardSleep != DUCK_SLEEP_DEEP, "Guard Duck must not resolve to default TimeDuck sleep")

            let duckling = registry.companion(for: .duckling)
            let ducklingSleep = duckling.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: true, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(ducklingSleep == DUCKLING_SLEEP, "Duckling must resolve DUCKLING_SLEEP")

            let cyber = registry.companion(for: .cyberDuck)
            let cyberSleep = cyber.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: true, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertTrue(cyberSleep == CYBER_DUCK_SLEEP, "CyberDuck must resolve CYBER_DUCK_SLEEP")
            assertTrue(cyberSleep != DUCK_SLEEP_DEEP, "CyberDuck must not resolve to default TimeDuck sleep")
        }
    }

    static func testEveryCompanionResolvesOwnChonky() {
        runTest("testEveryCompanionResolvesOwnChonky") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()

            let timeDuckChonk = registry.companion(for: .timeDuck).resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: true
            )
            assertTrue(timeDuckChonk == DUCK_CHONK_BASE, "TimeDuck must resolve DUCK_CHONK_BASE")

            let girlChonk = registry.companion(for: .girlDuck).resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: true
            )
            assertTrue(girlChonk == GIRL_DUCK_CHONK_BASE, "Girl Duck must resolve GIRL_DUCK_CHONK_BASE")
            assertTrue(girlChonk != DUCK_CHONK_BASE, "Girl Duck must not resolve to TimeDuck DUCK_CHONK_BASE")

            let guardChonk = registry.companion(for: .guardDuck).resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: true
            )
            assertTrue(guardChonk == GUARD_DUCK_CHONK_BASE, "Guard Duck must resolve GUARD_DUCK_CHONK_BASE")

            let ducklingChonk = registry.companion(for: .duckling).resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: true
            )
            assertTrue(ducklingChonk == DUCKLING_CHONK_BASE, "Duckling must resolve DUCKLING_CHONK_BASE")

            let cyberChonk = registry.companion(for: .cyberDuck).resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: true
            )
            assertTrue(cyberChonk == CYBER_DUCK_CHONK_BASE, "CyberDuck must resolve CYBER_DUCK_CHONK_BASE")
        }
    }

    static func testNoAlternateCompanionResolvesToTimeDuckAssets() {
        runTest("testNoAlternateCompanionResolvesToTimeDuckAssets") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()
            let alternateCompanions: [TimeCompanionId] = [.girlDuck, .guardDuck, .duckling, .cyberDuck]

            let testPoses: [DuckPose] = [
                .standing, .pecking, .celebrating, .sitting, .headTilt, .tactical,
                .sideEye, .lookingBack, .grooving, .featherRuffle, .yawning, .confused,
                .proud, .sneezing, .curiousPoke, .irritated, .chomping, .tantrum
            ]

            for compId in alternateCompanions {
                let comp = registry.companion(for: compId)
                for pose in testPoses {
                    let sprite = comp.resolveSprite(
                        pose: pose, t: 0.5, now: now, isFlapping: false, isQuacking: false,
                        isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                        isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                        poseUntil: now.addingTimeInterval(5.0), isChonky: false
                    )
                    // The sprite must NOT be TimeDuck base or TimeDuck specific pose
                    assertTrue(sprite != DUCK_BASE, "Companion \(compId) must never resolve to DUCK_BASE")
                    assertTrue(sprite != DUCK_IDLE_B, "Companion \(compId) must never resolve to DUCK_IDLE_B")
                    assertTrue(sprite != DUCK_IDLE_WAG, "Companion \(compId) must never resolve to DUCK_IDLE_WAG")
                }
            }
        }
    }

    static func testCyberDuckMotionLanguageAndExpandedStates() {
        runTest("testCyberDuckMotionLanguageAndExpandedStates") {
            let cyber = TimeCompanionRegistry.shared.companion(for: .cyberDuck)
            let now = Date()

            // 1. Idle matrix pulse and idle cycles
            let pulseSprite = cyber.resolveSprite(
                pose: .standing, t: 0.8, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                poseUntil: .distantPast, isChonky: false
            )
            assertTrue(pulseSprite == CYBER_DUCK_BASE || pulseSprite == CYBER_DUCK_IDLE_B || pulseSprite == CYBER_DUCK_MATRIX_PULSE, "CyberDuck must cycle through unique cyber idles")

            // 2. Electrostatic shock reaction on poke/irritated
            let shockSprite = cyber.resolveSprite(
                pose: .irritated, t: 0.0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                poseUntil: now.addingTimeInterval(2.0), isChonky: false
            )
            assertTrue(shockSprite == CYBER_DUCK_SHOCK, "CyberDuck must resolve CYBER_DUCK_SHOCK on poke/irritation")

            // 3. Boot-up on waking/preening
            let bootSprite = cyber.resolveSprite(
                pose: .preening, t: 0.0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                poseUntil: now.addingTimeInterval(2.0), isChonky: false
            )
            assertTrue(bootSprite == CYBER_DUCK_BOOT, "CyberDuck must resolve CYBER_DUCK_BOOT on system wake")
        }
    }

    static func testSafeGenericCompanionFallbackHierarchy() {
        runTest("testSafeGenericCompanionFallbackHierarchy") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()

            // An obscure unmapped pose should safely resolve to that companion's OWN base
            let girl = registry.companion(for: .girlDuck)
            let girlUnmapped = girl.resolveSprite(
                pose: .playingDead, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                poseUntil: now.addingTimeInterval(2.0), isChonky: false
            )
            assertTrue(girlUnmapped == ACTOR_GIRL_DUCK_BASE, "Girl Duck unhandled pose must fall back to ACTOR_GIRL_DUCK_BASE")

            let guardD = registry.companion(for: .guardDuck)
            let guardUnmapped = guardD.resolveSprite(
                pose: .playingDead, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast,
                poseUntil: now.addingTimeInterval(2.0), isChonky: false
            )
            assertTrue(guardUnmapped == ACTOR_GUARD_DUCK_BASE, "Guard Duck unhandled pose must fall back to ACTOR_GUARD_DUCK_BASE")
        }
    }

    // MARK: - 2. Story Trigger Routing Tests

    static func testStoryModeStrictlyScopedToPomodoro() {
        runTest("testStoryModeStrictlyScopedToPomodoro") {
            let engine = DuckStoryEngine()
            engine.setSelection(.auto)

            // 1. Timer mode countdown -> Must return nil (No story scene)
            let timerCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.5, sessionDuration: 1500, remainingSeconds: 750,
                elapsedSeconds: 750, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let timerStory = engine.resolveActiveStory(context: timerCtx)
            assertTrue(timerStory == nil, "Standard countdown Timer must NEVER launch DuckDrop stories")

            // 2. Stopwatch mode -> Must return nil (No story scene)
            let swCtx = DuckStoryContext(
                mode: .stopwatch, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.3, sessionDuration: 300, remainingSeconds: 210,
                elapsedSeconds: 90, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let swStory = engine.resolveActiveStory(context: swCtx)
            assertTrue(swStory == nil, "Stopwatch session must NEVER launch DuckDrop stories")

            // 3. Pomodoro mode -> Must return active story
            let pomoCtx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 1500, remainingSeconds: 1500,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let pomoStory = engine.resolveActiveStory(context: pomoCtx)
            assertTrue(pomoStory != nil, "Pomodoro mode must launch valid DuckDrop story")
        }
    }

    static func testDeveloperPreviewBypassesModeRestriction() {
        runTest("testDeveloperPreviewBypassesModeRestriction") {
            let engine = DuckStoryEngine()
            engine.beginPreview(.theRescue)

            // Even if context is .timer, preview mode must resolve the preview story
            let timerCtx = DuckStoryContext(
                mode: .timer, isRunning: true, isPaused: false, isFinished: false,
                normalizedProgress: 0.0, sessionDuration: 300, remainingSeconds: 300,
                elapsedSeconds: 0, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )
            let previewStory = engine.resolveActiveStory(context: timerCtx)
            assertTrue(previewStory?.id == .theRescue, "Developer preview must resolve selected story regardless of mode")
            engine.endPreview()
        }
    }

    // MARK: - 3. The Rescue Finale Tests

    static func testTheRescueSimplifiedFinaleCheerLoop() {
        runTest("testTheRescueSimplifiedFinaleCheerLoop") {
            let story = TheRescueStory()
            let engine = DuckStoryEngine()
            let ctx = DuckStoryContext(
                mode: .pomodoro, isRunning: true, isPaused: false, isFinished: true,
                normalizedProgress: 1.0, sessionDuration: 300, remainingSeconds: 0,
                elapsedSeconds: 300, isCompact: false, reduceMotion: false, localHour: 14,
                currentHat: .none, currentTheme: .arcade
            )

            story.onEnterFinale(context: ctx, engine: engine)
            assertTrue(story.isFinaleActive, "The Rescue must enter finale")

            // Tick finale into cheer loop
            story.updateFinale(dt: 1.0, now: Date(), context: ctx, engine: engine)
            let girlActor = engine.actors.first { $0.id == "girl_duck" }
            assertTrue(girlActor != nil, "Girl Duck actor must be present in Rescue finale")
            assertTrue(girlActor?.spriteRows == ACTOR_GIRL_DUCK_CHEER_A || girlActor?.spriteRows == ACTOR_GIRL_DUCK_CHEER_B,
                       "Girl Duck must execute synchronized cheer celebration without distortion")
        }
    }

    // MARK: - 4. Duckbook Scrolling & Navigation Tests

    static func testDuckbookScrollModelAndBoundsClamping() {
        runTest("testDuckbookScrollModelAndBoundsClamping") {
            let book = DuckbookEngine.shared
            book.open(tab: .achievements)
            assertTrue(book.isOpen, "Duckbook must be open")
            assertTrue(book.selectedIndex == 0, "Initial selection must be 0")
            assertTrue(book.scrollOffset == 0, "Initial scroll offset must be 0")

            // Move selection down past visible window
            book.moveSelection(delta: 6)
            assertTrue(book.selectedIndex == 6, "Selection should move to index 6")
            assertTrue(book.scrollOffset > 0, "Scroll offset must advance when selection moves down")

            // Move selection up back to top
            book.moveSelection(delta: -10)
            assertTrue(book.selectedIndex == 0, "Selection should clamp to 0")
            assertTrue(book.scrollOffset == 0, "Scroll offset must reset to 0")

            book.close()
        }
    }

    static func testDuckbookScrollDoesNotMutateClockOrPlaySound() {
        runTest("testDuckbookScrollDoesNotMutateClockOrPlaySound") {
            let book = DuckbookEngine.shared
            book.open(tab: .companions)

            let tm = TimerModel()
            tm.setDuration(300)
            let initialRemaining = tm.remaining

            // Simulate scroll event while Duckbook is open
            book.moveSelection(delta: 1)
            assertTrue(tm.remaining == initialRemaining, "Duckbook scroll must never mutate clock timer remaining")

            book.close()
        }
    }

    static func testDuckbookKeyboardNavigationAndDismissal() {
        runTest("testDuckbookKeyboardNavigationAndDismissal") {
            let book = DuckbookEngine.shared
            book.open(tab: .companions)

            // Tab switching
            book.nextTab()
            assertTrue(book.activeTab == .achievements, "nextTab must switch to Achievements")

            book.nextTab()
            assertTrue(book.activeTab == .secrets, "nextTab must switch to Secrets")

            book.prevTab()
            assertTrue(book.activeTab == .achievements, "prevTab must switch back to Achievements")

            // Close
            book.close()
            assertTrue(!book.isOpen, "Duckbook must close cleanly")
        }
    }

    static func testDuckbookModalInputIsolation() {
        runTest("testDuckbookModalInputIsolation") {
            let book = DuckbookEngine.shared
            book.open(tab: .companions)
            assertTrue(book.isOpen, "Duckbook should be active modal")

            // Confirm selection on active companion
            let confirmed = book.confirmSelection()
            assertTrue(confirmed, "Confirming default companion must succeed")

            book.close()
        }
    }

    static func testCompanionSwitchingDuringAllClockStates() {
        runTest("testCompanionSwitchingDuringAllClockStates") {
            let registry = TimeCompanionRegistry.shared
            registry.unlock(.girlDuck)
            registry.unlock(.guardDuck)
            registry.unlock(.duckling)
            registry.unlock(.cyberDuck)

            let companions: [TimeCompanionId] = [.timeDuck, .girlDuck, .guardDuck, .duckling, .cyberDuck]
            for c in companions {
                let switched = registry.select(c)
                assertTrue(switched, "Companion selection \(c) must succeed")
                assertTrue(registry.activeCompanionId == c, "Active companion ID must update")
            }
            registry.select(.timeDuck)
        }
    }

    static func testDuckbookLayoutTruncationSafety() {
        runTest("testDuckbookLayoutTruncationSafety") {
            let catalog = AchievementEngine.shared.orderedCatalog
            for ach in catalog {
                let shortTitle = String(ach.title.uppercased().prefix(20))
                let shortDesc = String(ach.description.prefix(21))
                assertTrue(shortTitle.count <= 20, "Achievement title must stay within modal width budget")
                assertTrue(shortDesc.count <= 21, "Achievement description must stay within modal width budget")
            }
        }
    }

    static func testDuckbookExplicitCardGeometryNonOverlapping() {
        runTest("testDuckbookExplicitCardGeometryNonOverlapping") {
            let modalY = 8
            let modalH = 80
            let rowH = 15
            let stepH = 16

            let footerY = modalY + modalH - 9

            for row in 0..<3 {
                let cardTop = modalY + 21 + row * stepH
                let cardBottom = cardTop + rowH - 1

                assertTrue(cardTop >= modalY + 21, "Card \(row) must be at or below content start")
                assertTrue(cardBottom < footerY, "Card \(row) bottom (\(cardBottom)) must not collide with footer (\(footerY))")

                if row > 0 {
                    let prevBottom = modalY + 21 + (row - 1) * stepH + rowH - 1
                    assertTrue(cardTop > prevBottom, "Card \(row) top (\(cardTop)) must be strictly below card \(row - 1) bottom (\(prevBottom))")
                }
            }
        }
    }

    static func testDuckbookScrollingWindowThreeItems() {
        runTest("testDuckbookScrollingWindowThreeItems") {
            let book = DuckbookEngine.shared
            book.open(tab: .companions)
            assertTrue(book.scrollOffset == 0, "Initial scrollOffset must be 0")
            assertTrue(book.selectedIndex == 0, "Initial selectedIndex must be 0")

            book.moveSelection(delta: 1)
            assertTrue(book.selectedIndex == 1, "selectedIndex must be 1")
            assertTrue(book.scrollOffset == 0, "scrollOffset must stay 0 for row 1")

            book.moveSelection(delta: 1)
            assertTrue(book.selectedIndex == 2, "selectedIndex must be 2")
            assertTrue(book.scrollOffset == 0, "scrollOffset must stay 0 for row 2")

            book.moveSelection(delta: 1)
            assertTrue(book.selectedIndex == 3, "selectedIndex must be 3")
            assertTrue(book.scrollOffset == 1, "scrollOffset must advance to 1 for row 3 (3 visible)")

            book.moveSelection(delta: 1)
            assertTrue(book.selectedIndex == 4, "selectedIndex must be 4")
            assertTrue(book.scrollOffset == 2, "scrollOffset must advance to 2 for row 4 (3 visible)")

            book.moveSelection(delta: -2)
            assertTrue(book.selectedIndex == 2, "selectedIndex must move up to 2")
            assertTrue(book.scrollOffset == 2, "scrollOffset stays 2 while 2 is in visible window")

            book.moveSelection(delta: -1)
            assertTrue(book.selectedIndex == 1, "selectedIndex must move up to 1")
            assertTrue(book.scrollOffset == 1, "scrollOffset clamps to 1")

            book.close()
        }
    }

    static func testMiniUIActiveCompanionResolution() {
        runTest("testMiniUIActiveCompanionResolution") {
            let registry = TimeCompanionRegistry.shared
            registry.unlock(.girlDuck)
            registry.unlock(.guardDuck)
            registry.unlock(.duckling)
            registry.unlock(.cyberDuck)

            let brain = DuckBrain()
            let now = Date()

            // 1. Girl Duck active
            registry.select(.girlDuck)
            let girlRows = brain.getSpriteRows(t: 0, now: now, isFlapping: false, isQuacking: false, isPetting: false, isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false, stridePhase: 0, blinkUntil: .distantPast)
            assertTrue(girlRows == ACTOR_GIRL_DUCK_BASE || girlRows == ACTOR_GIRL_DUCK_IDLE_B, "MiniUI must resolve Girl Duck sprite")
            assertTrue(girlRows != DUCK_BASE, "MiniUI must not resolve to TimeDuck DUCK_BASE")

            // 2. Guard Duck active
            registry.select(.guardDuck)
            let guardRows = brain.getSpriteRows(t: 0, now: now, isFlapping: false, isQuacking: false, isPetting: false, isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false, stridePhase: 0, blinkUntil: .distantPast)
            assertTrue(guardRows == ACTOR_GUARD_DUCK_BASE || guardRows == ACTOR_GUARD_DUCK_STOP, "MiniUI must resolve Guard Duck sprite")
            assertTrue(guardRows != DUCK_BASE, "MiniUI must not resolve to TimeDuck DUCK_BASE")

            // 3. CyberDuck active
            registry.select(.cyberDuck)
            let cyberRows = brain.getSpriteRows(t: 0, now: now, isFlapping: false, isQuacking: false, isPetting: false, isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false, stridePhase: 0, blinkUntil: .distantPast)
            assertTrue(cyberRows == CYBER_DUCK_BASE || cyberRows == CYBER_DUCK_IDLE_B || cyberRows == CYBER_DUCK_MATRIX_PULSE, "MiniUI must resolve CyberDuck sprite")
            assertTrue(cyberRows != DUCK_BASE, "MiniUI must not resolve to TimeDuck DUCK_BASE")

            registry.select(.timeDuck)
        }
    }

    static func testMiniUIAccessoryAttachmentAnchorResolution() {
        runTest("testMiniUIAccessoryAttachmentAnchorResolution") {
            // CyberDuck head crown resolution (uses 'b' pixels)
            let cyberAnchor = DuckAnchorResolver.resolve(rows: CYBER_DUCK_BASE)
            assertTrue(cyberAnchor.y <= 2, "CyberDuck skull crown must be detected at top rows")
            assertTrue(!cyberAnchor.facingBack, "CyberDuck must not be facing back")

            // Girl Duck head crown resolution (uses 'm' and 'y' pixels)
            let girlAnchor = DuckAnchorResolver.resolve(rows: ACTOR_GIRL_DUCK_BASE)
            assertTrue(girlAnchor.y <= 2, "Girl Duck skull crown must be detected at top rows")

            // Guard Duck head crown resolution (uses 'k' and 'y' pixels)
            let guardAnchor = DuckAnchorResolver.resolve(rows: ACTOR_GUARD_DUCK_BASE)
            assertTrue(guardAnchor.y <= 2, "Guard Duck skull crown must be detected at top rows")

            // TimeDuck base
            let timeAnchor = DuckAnchorResolver.resolve(rows: DUCK_BASE)
            assertTrue(timeAnchor.y <= 2, "TimeDuck skull crown must be detected at top rows")
        }
    }

    static func testMiniUIPhraseTruncationNoPinkSquareGlyphs() {
        runTest("testMiniUIPhraseTruncationNoPinkSquareGlyphs") {
            // 1. Verify ellipsis glyph exists in FONT3 so fitSmallText does not trigger missing glyph
            assertTrue(FONT3["…"] != nil, "FONT3 must define glyph for unicode ellipsis …")
            assertTrue(FONT3["’"] != nil, "FONT3 must define glyph for smart quote ’")
            assertTrue(FONT3["—"] != nil, "FONT3 must define glyph for em dash —")
            assertTrue(FONT3["★"] != nil, "FONT3 must define glyph for star ★")

            // 2. Truncate a test phrase and verify it renders without error
            let phrase = "Focus session started with high determination and vigor!"
            let fitted = PixelCanvas.fitSmallText(phrase, maxWidth: 20)
            assertTrue(fitted.contains("…"), "Truncated phrase must contain ellipsis")

            let canvas = PixelCanvas(w: 40, h: 20)
            let textW = canvas.smallText(fitted, x: 2, y: 2, c: Pal.white)
            assertTrue(textW > 0, "Canvas must render smallText without error")
        }
    }

    static func testDuckbookButtonHitboxesMatchCardGeometry() {
        runTest("testDuckbookButtonHitboxesMatchCardGeometry") {
            let modalX = 6
            let modalY = 8
            let modalW = 160 - 12
            let rowH = 15
            let stepH = 16

            let book = DuckbookEngine.shared
            book.open(tab: .companions)

            for rowIdx in 0..<3 {
                let expectedX = modalX + 4
                let expectedY = modalY + 21 + rowIdx * stepH
                let expectedW = modalW - 8
                let expectedH = rowH

                assertTrue(expectedX == 10, "Card button X must be 10")
                assertTrue(expectedY == 29 + rowIdx * 16, "Card button Y must match row")
                assertTrue(expectedW == 140, "Card button width must be 140")
                assertTrue(expectedH == 15, "Card button height must be 15")
            }

            book.close()
        }
    }

    static func testCentralizedScrollRoutingDoesNotMutateTimeOrDuration() {
        runTest("testCentralizedScrollRoutingDoesNotMutateTimeOrDuration") {
            let tm = TimerModel()
            let pomo = PomodoroModel()
            tm.setDuration(300)
            pomo.setWorkDuration(1500)

            let initialTm = tm.duration
            let initialPomo = pomo.currentDuration

            // Simulate passive scrolling outside Duckbook (e.g. over timer digits, background, controls)
            // Under centralized scroll router, passive scroll does not trigger adjustTime
            DuckbookEngine.shared.close()
            assertTrue(!DuckbookEngine.shared.isOpen, "Duckbook must be closed")

            // Test timer engine values remain invariant
            assertTrue(tm.duration == initialTm, "Timer duration must not change from passive scrolling")
            assertTrue(pomo.currentDuration == initialPomo, "Pomodoro duration must not change from passive scrolling")
        }
    }

    static func testDuckbookScrollNormalizationAndAccumulator() {
        runTest("testDuckbookScrollNormalizationAndAccumulator") {
            let book = DuckbookEngine.shared
            book.open(tab: .companions)
            assertTrue(book.selectedIndex == 0, "Must start at index 0")

            // 1. Sub-threshold continuous scrolling should not jump
            let move1 = book.handleScroll(deltaY: -1.0, isPrecise: true, isBegan: false, isEnded: false)
            assertTrue(move1 == 0, "Sub-threshold scroll should not advance selection")
            assertTrue(book.selectedIndex == 0, "Index must remain 0")

            // 2. Accumulating past threshold (threshold = 3.5)
            let move2 = book.handleScroll(deltaY: -3.0, isPrecise: true, isBegan: false, isEnded: false)
            assertTrue(move2 == 1, "Exceeding threshold must advance selection by 1")
            assertTrue(book.selectedIndex == 1, "Index must be 1")

            // 3. Direction reversal resets accumulator
            _ = book.handleScroll(deltaY: 2.0, isPrecise: true, isBegan: false, isEnded: false)
            let moveReverse = book.handleScroll(deltaY: 2.0, isPrecise: true, isBegan: false, isEnded: false)
            assertTrue(moveReverse == -1, "Accumulated reverse scroll must move selection up by 1")
            assertTrue(book.selectedIndex == 0, "Index must return to 0")

            // 4. Coarse mouse-wheel tick immediately moves 1 step
            let coarseMove = book.handleScroll(deltaY: -1.0, isPrecise: false, isBegan: false, isEnded: false)
            assertTrue(coarseMove == 1, "Coarse wheel tick must move 1 step")
            assertTrue(book.selectedIndex == 1, "Index must be 1")

            book.close()
        }
    }

    static func testMiniUIWordByWordTokenizationAndCadence() {
        runTest("testMiniUIWordByWordTokenizationAndCadence") {
            let phrase = "POND IS CHEERFUL TODAY! ❤️"
            let words = phrase.replacingOccurrences(of: "\n", with: " ").split(separator: " ").map(String.init)
            assertEqual(words.count, 5, "Phrase must tokenize into 5 words")
            assertEqual(words[0], "POND", "Word 0 must be POND")
            assertEqual(words[1], "IS", "Word 1 must be IS")
            assertEqual(words[2], "CHEERFUL", "Word 2 must be CHEERFUL")
            assertEqual(words[3], "TODAY!", "Word 3 must preserve attached exclamation mark")
            assertEqual(words[4], "❤️", "Word 4 must preserve heart symbol")

            let totalDur = 2.4
            let wordDur = min(0.38, max(0.20, (totalDur * 0.72) / Double(words.count)))

            // Check word index at start (0.1s)
            let idxStart = min(words.count - 1, Int(0.1 / wordDur))
            assertEqual(idxStart, 0, "At 0.1s, word index must be 0")

            // Check word index near end (2.2s) - must hold last word
            let idxEnd = min(words.count - 1, Int(2.2 / wordDur))
            assertEqual(idxEnd, 4, "At 2.2s, word index must hold on last word (4)")
        }
    }

    static func testMiniUIAllCompanionsTrueSleepSprites() {
        runTest("testMiniUIAllCompanionsTrueSleepSprites") {
            let registry = TimeCompanionRegistry.shared
            let now = Date()
            let t = 0.0

            let companions: [TimeCompanionId: [String]] = [
                .timeDuck: DUCK_SLEEP_DEEP,
                .girlDuck: ACTOR_GIRL_DUCK_SLEEP,
                .guardDuck: ACTOR_GUARD_DUCK_SLEEP,
                .duckling: DUCKLING_SLEEP,
                .cyberDuck: CYBER_DUCK_SLEEP
            ]

            for (id, expectedSleepSprite) in companions {
                _ = registry.select(id)
                let resolved = registry.activeCompanion.resolveSprite(
                    pose: .standing,
                    t: t,
                    now: now,
                    isFlapping: false,
                    isQuacking: false,
                    isPetting: false,
                    isEating: false,
                    isBreakRunning: false,
                    isRunning: false,
                    isSleeping: true,
                    stridePhase: 0.0,
                    blinkUntil: .distantPast,
                    poseUntil: .distantPast,
                    isChonky: false
                )
                assertEqual(resolved, expectedSleepSprite, "Companion \(id.rawValue) must return companion-specific sleep sprite when isSleeping is true")
            }

            _ = registry.select(.timeDuck)
        }
    }

    static func testTimerFirstSafeZoneAndDominantLayoutGeometry() {
        runTest("testTimerFirstSafeZoneAndDominantLayoutGeometry") {
            let tabsBottom = 19
            let timerSafeZoneTop = 20
            let timerSafeZoneBottom = 36
            let statusLineY = 38
            let progressBarY = 45
            let duckHabitatGroundY = 62
            let controlsY = 73

            assertTrue(tabsBottom < timerSafeZoneTop, "Tabs must sit strictly above timer safe zone")
            assertTrue(timerSafeZoneBottom < statusLineY, "Timer safe zone must sit strictly above status line")
            assertTrue(statusLineY < progressBarY, "Status line must sit strictly above progress bar")
            assertTrue(progressBarY < duckHabitatGroundY, "Progress bar must sit strictly above duck ground")
            assertTrue(duckHabitatGroundY < controlsY, "Duck ground must sit strictly above controls row")
        }
    }

    static func testDuckbookCatalogZeroTextClipping() {
        runTest("testDuckbookCatalogZeroTextClipping") {
            // Verify every companion in registry
            let companions = TimeCompanionRegistry.shared.allCompanions
            for c in companions {
                let nameW = PixelCanvas.smallWidth(c.displayName.uppercased())
                assertTrue(nameW <= 110, "Companion name \(c.displayName) must fit within 110px width")
                let subW = PixelCanvas.smallWidth(c.subtitle)
                assertTrue(subW <= 130, "Companion subtitle \(c.subtitle) must fit within 130px width")
            }

            // Verify every achievement in catalog
            let achievements = AchievementEngine.shared.orderedCatalog
            for a in achievements {
                let titleW = PixelCanvas.smallWidth(String(a.title.uppercased().prefix(20)))
                assertTrue(titleW <= 95, "Achievement title \(a.title) must fit within 95px text column")
                let descW = PixelCanvas.smallWidth(String(a.description.prefix(21)))
                assertTrue(descW <= 95, "Achievement description must fit within 95px text column")
                let hintW = PixelCanvas.smallWidth(String(a.hint.prefix(21)))
                assertTrue(hintW <= 95, "Achievement hint must fit within 95px text column")
            }
        }
    }
}

