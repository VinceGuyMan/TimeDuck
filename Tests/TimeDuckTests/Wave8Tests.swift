// MARK: - TimeDuck · Wave8Tests.swift
// Automated test suite for Wave 8 (TimeCompanions + Achievements):
// - First-class TimeCompanion system (TimeDuck, Girl Duck, Guard Duck, Duckling, CyberDuck)
// - Companion selection, unlock condition evaluation, and persistence/fallback
// - Declarative Achievement Engine (20 curated achievements + hidden discoveries)
// - Achievement idempotency, reward unlocks, domain event dispatching
// - Duckbook Engine navigation, selection, and VoiceOver accessibility
// - Toast unlock presentation and queueing lifecycle
// - Invariant regressions: +1 MIN timer lifecycle, timer state preservation during companion switches
// - Developer-only "Unlock Everything" override mode and persistence isolation

import Foundation
import AppKit

enum Wave8Tests {
    static func runAll() {
        print("")
        print("▸ Testing Wave 8: TimeCompanions, Achievements & Duckbook…")
        testDefaultCompanion()
        testCompanionCatalogAndTraits()
        testCompanionSelectionAndLockedRejection()
        testCompanionPersistenceAndStateRestoration()
        testCorruptedUnknownSavedCompanionFallback()
        testCompanionUnlockViaAchievementReward()
        testCompanionSpriteAndColorMapResolvers()
        testAchievementCatalogStructure()
        testAchievementIdempotency()
        testAchievementPersistenceAndRestoration()
        testHiddenAchievementsDisplay()
        testMultipleSimultaneousUnlocks()
        testTimerCompletionDomainEventUnlocks()
        testStoryCompletionDomainEventUnlocks()
        testFeedingAndChonkyAchievementUnlocks()
        testPokeEscalationAchievementUnlock()
        testCostumeExplorationAchievementUnlock()
        testStopwatchLapAchievementUnlock()
        testRareSecretEventAchievementUnlocks()
        testPondMaestroSoundToggleUnlock()
        testStreakAchievementUnlock()
        testDuckbookEngineNavigation()
        testDuckbookAccessibilitySummary()
        testToastQueueingAndLifecycle()
        testRegressionFinishedRunningPlusOneMinPreserved()
        testRegressionTimerLifecycleDuringCompanionSwitch()
        testRegressionAchievementUnlockDuringTimerFinish()
        #if DEBUG
        testDeveloperOverrideUnlockAllCompanionsAndAchievements()
        testDeveloperOverrideResetToGenuine()
        testDeveloperOverridePersistenceIsolation()
        #endif
    }

    // MARK: - Test 1: Default Companion
    static func testDefaultCompanion() {
        runTest("testDefaultCompanion") {
            let registry = TimeCompanionRegistry()
            assertEqual(registry.activeCompanionId, .timeDuck, "Default active companion must be TimeDuck")
            assertTrue(registry.isUnlocked(.timeDuck), "TimeDuck must always be unlocked by default")
            assertEqual(registry.activeCompanion.displayName, "TimeDuck", "Active companion name must be TimeDuck")
        }
    }

    // MARK: - Test 2: Companion Catalog and Traits
    static func testCompanionCatalogAndTraits() {
        runTest("testCompanionCatalogAndTraits") {
            let registry = TimeCompanionRegistry()
            let all = registry.allCompanions
            assertEqual(all.count, 5, "Catalog must contain exactly 5 companions in initial roster")

            let ids = Set(all.map(\.id))
            assertTrue(ids.contains(.timeDuck), "Catalog must include TimeDuck")
            assertTrue(ids.contains(.girlDuck), "Catalog must include Girl Duck")
            assertTrue(ids.contains(.guardDuck), "Catalog must include Guard Duck")
            assertTrue(ids.contains(.duckling), "Catalog must include Duckling")
            assertTrue(ids.contains(.cyberDuck), "Catalog must include CyberDuck")

            // Secret status
            let cyber = registry.companion(for: .cyberDuck)
            assertTrue(cyber.isSecret, "CyberDuck must be designated as a secret companion")
            assertFalse(registry.companion(for: .timeDuck).isSecret, "TimeDuck is not secret")
            assertFalse(registry.companion(for: .girlDuck).isSecret, "Girl Duck is not secret")

            // Speed multipliers
            let duckling = registry.companion(for: .duckling)
            assertTrue(duckling.speedMultiplier > 1.2, "Duckling must possess faster speed multiplier: \(duckling.speedMultiplier)")

            let guardDuck = registry.companion(for: .guardDuck)
            assertTrue(guardDuck.speedMultiplier < 1.0, "Guard Duck must possess deliberate patrol speed multiplier: \(guardDuck.speedMultiplier)")
        }
    }

    // MARK: - Test 3: Companion Selection and Locked Rejection
    static func testCompanionSelectionAndLockedRejection() {
        runTest("testCompanionSelectionAndLockedRejection") {
            let registry = TimeCompanionRegistry()
            // Fresh state: only timeDuck unlocked
            assertFalse(registry.isUnlocked(.guardDuck), "Guard Duck should start locked")
            assertFalse(registry.select(.guardDuck), "Selecting locked companion must fail and return false")
            assertEqual(registry.activeCompanionId, .timeDuck, "Active companion must remain TimeDuck")

            // Unlock and select
            assertTrue(registry.unlock(.guardDuck), "Unlocking Guard Duck must succeed")
            assertTrue(registry.isUnlocked(.guardDuck), "Guard Duck is now unlocked")
            assertTrue(registry.select(.guardDuck), "Selecting unlocked Guard Duck must succeed")
            assertEqual(registry.activeCompanionId, .guardDuck, "Active companion must now be Guard Duck")
        }
    }

    // MARK: - Test 4: Companion Persistence and State Restoration
    static func testCompanionPersistenceAndStateRestoration() {
        runTest("testCompanionPersistenceAndStateRestoration") {
            let registry = TimeCompanionRegistry()
            registry.restoreState(activeId: "girl_duck", unlockedIds: ["timeduck", "girl_duck", "duckling"])

            assertEqual(registry.activeCompanionId, .girlDuck, "Active companion should restore to Girl Duck")
            assertTrue(registry.isUnlocked(.girlDuck), "Girl Duck should be restored as unlocked")
            assertTrue(registry.isUnlocked(.duckling), "Duckling should be restored as unlocked")
            assertFalse(registry.isUnlocked(.guardDuck), "Guard Duck should remain locked")
        }
    }

    // MARK: - Test 5: Corrupted / Unknown Saved Companion Fallback
    static func testCorruptedUnknownSavedCompanionFallback() {
        runTest("testCorruptedUnknownSavedCompanionFallback") {
            let registry = TimeCompanionRegistry()
            // Pass nonexistent / future unknown companion ID
            registry.restoreState(activeId: "future_quantum_robo_duck_v99", unlockedIds: ["timeduck", "invalid_id_xyz"])

            assertEqual(registry.activeCompanionId, .timeDuck, "Unknown companion ID must gracefully fall back to TimeDuck")
            assertTrue(registry.isUnlocked(.timeDuck), "TimeDuck remains unlocked")
        }
    }

    // MARK: - Test 6: Companion Unlock via Achievement Reward
    static func testCompanionUnlockViaAchievementReward() {
        runTest("testCompanionUnlockViaAchievementReward") {
            let engine = AchievementEngine()
            let reg = TimeCompanionRegistry.shared
            reg.restoreState(activeId: "timeduck", unlockedIds: ["timeduck"])

            assertFalse(reg.isUnlocked(.duckling), "Duckling starts locked")
            engine.unlock("first_waddle")
            assertTrue(reg.isUnlocked(.duckling), "Unlocking first_waddle must automatically unlock Duckling")

            assertFalse(reg.isUnlocked(.girlDuck), "Girl Duck starts locked")
            engine.unlock("leave_no_duck_behind")
            assertTrue(reg.isUnlocked(.girlDuck), "Unlocking leave_no_duck_behind must automatically unlock Girl Duck")

            assertFalse(reg.isUnlocked(.guardDuck), "Guard Duck starts locked")
            engine.unlock("clocked_out")
            assertTrue(reg.isUnlocked(.guardDuck), "Unlocking clocked_out must automatically unlock Guard Duck")

            assertFalse(reg.isUnlocked(.cyberDuck), "CyberDuck starts locked")
            engine.unlock("secret_glitch")
            assertTrue(reg.isUnlocked(.cyberDuck), "Unlocking secret_glitch must automatically unlock CyberDuck")
        }
    }

    // MARK: - Test 7: Companion Sprite and Color Map Resolvers
    static func testCompanionSpriteAndColorMapResolvers() {
        runTest("testCompanionSpriteAndColorMapResolvers") {
            let reg = TimeCompanionRegistry()
            let now = Date()

            // 1. TimeDuck Sprite
            let td = reg.companion(for: .timeDuck)
            let tdRows = td.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertEqual(tdRows.count, 10, "TimeDuck sprite must have 10 rows")

            // 2. Girl Duck Sprite & Color Map
            let gd = reg.companion(for: .girlDuck)
            let gdRows = gd.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertEqual(gdRows, ACTOR_GIRL_DUCK_BASE, "Girl Duck must resolve ACTOR_GIRL_DUCK_BASE")
            let gdMap = gd.resolveColorMap()
            assertTrue(gdMap["m"] != nil, "Girl Duck color map must contain magenta for ribbon")

            // 3. Guard Duck Sprite
            let guardD = reg.companion(for: .guardDuck)
            let guardRows = guardD.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertEqual(guardRows, ACTOR_GUARD_DUCK_BASE, "Guard Duck must resolve ACTOR_GUARD_DUCK_BASE")

            // 4. Duckling Sprite
            let dk = reg.companion(for: .duckling)
            let dkRows = dk.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertEqual(dkRows, DUCKLING_BASE, "Duckling must resolve DUCKLING_BASE")

            // 5. CyberDuck Sprite & Color Map
            let cyber = reg.companion(for: .cyberDuck)
            let cyberRows = cyber.resolveSprite(
                pose: .standing, t: 0, now: now, isFlapping: false, isQuacking: false,
                isPetting: false, isEating: false, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast, poseUntil: .distantPast, isChonky: false
            )
            assertEqual(cyberRows, CYBER_DUCK_BASE, "CyberDuck must resolve CYBER_DUCK_BASE")
            let cyberMap = cyber.resolveColorMap()
            assertTrue(cyberMap["b"] != nil && cyberMap["v"] != nil, "CyberDuck color map must contain cyan and violet")
        }
    }

    // MARK: - Test 8: Achievement Catalog Structure
    static func testAchievementCatalogStructure() {
        runTest("testAchievementCatalogStructure") {
            let engine = AchievementEngine()
            assertEqual(engine.totalCount, 20, "Catalog must contain exactly 20 curated achievements")

            let expectedIds = [
                "first_waddle", "focused_duck", "marathon_duck", "quack_of_dawn", "night_owl",
                "absolute_unit", "breadwinner", "personal_space", "worth_it", "summit_duck",
                "clocked_out", "no_days_off", "leave_no_duck_behind", "pocket_sized", "fashionably_late",
                "speed_demon", "secret_glitch", "golden_feathers", "pond_maestro", "flock_veteran"
            ]

            for id in expectedIds {
                assertNotNil(engine.catalog[id], "Catalog must contain achievement ID: \(id)")
                let a = engine.catalog[id]!
                assertFalse(a.title.isEmpty, "Achievement title must not be empty")
                assertFalse(a.description.isEmpty, "Achievement description must not be empty")
                assertEqual(a.glyph.count, 5, "Badge glyph must be 5 rows high")
                for row in a.glyph {
                    assertEqual(row.count, 5, "Badge glyph row must be 5 chars wide")
                }
            }
        }
    }

    // MARK: - Test 9: Achievement Idempotency
    static func testAchievementIdempotency() {
        runTest("testAchievementIdempotency") {
            let engine = AchievementEngine()
            let firstDate = Date().addingTimeInterval(-100)
            let secondDate = Date()

            assertTrue(engine.unlock("first_waddle", now: firstDate), "First unlock should return true")
            assertTrue(engine.isUnlocked("first_waddle"), "Achievement should be unlocked")
            assertEqual(engine.unlockDate(for: "first_waddle"), firstDate, "First unlock date preserved")

            assertFalse(engine.unlock("first_waddle", now: secondDate), "Subsequent unlock of already unlocked achievement must return false")
            assertEqual(engine.unlockDate(for: "first_waddle"), firstDate, "First unlock timestamp must never be overwritten")
        }
    }

    // MARK: - Test 10: Achievement Persistence and Restoration
    static func testAchievementPersistenceAndRestoration() {
        runTest("testAchievementPersistenceAndRestoration") {
            let engine = AchievementEngine()
            let date1 = Date()
            let isoFormatter = ISO8601DateFormatter()
            let map: [String: String] = [
                "first_waddle": isoFormatter.string(from: date1),
                "focused_duck": isoFormatter.string(from: date1)
            ]

            engine.restoreState(
                unlockedAchievements: map,
                breadcrumbsTotal: 17,
                triedHats: [1, 2, 3]
            )

            assertTrue(engine.isUnlocked("first_waddle"), "first_waddle should be restored")
            assertTrue(engine.isUnlocked("focused_duck"), "focused_duck should be restored")
            assertFalse(engine.isUnlocked("marathon_duck"), "marathon_duck should remain locked")
            assertEqual(engine.breadcrumbsFedTotal, 17, "Lifetime breadcrumbs should restore to 17")
            assertEqual(engine.costumesTried.count, 3, "Costumes tried should restore count 3")
        }
    }

    // MARK: - Test 11: Hidden Achievements Display
    static func testHiddenAchievementsDisplay() {
        runTest("testHiddenAchievementsDisplay") {
            let engine = AchievementEngine()
            let secret = engine.catalog["secret_glitch"]!
            assertTrue(secret.isHidden, "secret_glitch must be marked isHidden")
            assertEqual(secret.hint, "???", "Secret achievement hint must be '???'")

            let normal = engine.catalog["first_waddle"]!
            assertFalse(normal.isHidden, "first_waddle is not hidden")
            assertFalse(normal.hint == "???", "Normal achievement hint must describe the task")
        }
    }

    // MARK: - Test 12: Multiple Simultaneous Unlocks
    static func testMultipleSimultaneousUnlocks() {
        runTest("testMultipleSimultaneousUnlocks") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            // 04:00 AM (early morning / night owl window) timer of 50 minutes (3000s)
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = 4
            comps.minute = 30
            let testDate = Calendar.current.date(from: comps)!

            let event = TimeDuckEvent.timerCompleted(mode: .timer, duration: 3000, isWorkPomodoro: false, isMiniHUD: true)
            let unlocked = engine.evaluateEvent(event, stats: stats, now: testDate)

            // Should unlock: first_waddle, marathon_duck, night_owl, pocket_sized
            let unlockedIds = Set(unlocked.map(\.id))
            assertTrue(unlockedIds.contains("first_waddle"), "Must unlock first_waddle")
            assertTrue(unlockedIds.contains("marathon_duck"), "Must unlock marathon_duck")
            assertTrue(unlockedIds.contains("night_owl"), "Must unlock night_owl")
            assertTrue(unlockedIds.contains("pocket_sized"), "Must unlock pocket_sized")
        }
    }

    // MARK: - Test 13: Timer Completion Domain Event Unlocks
    static func testTimerCompletionDomainEventUnlocks() {
        runTest("testTimerCompletionDomainEventUnlocks") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            // Pomodoro work completion
            let pomoEvent = TimeDuckEvent.timerCompleted(mode: .pomodoro, duration: 1500, isWorkPomodoro: true, isMiniHUD: false)
            engine.evaluateEvent(pomoEvent, stats: stats)
            assertTrue(engine.isUnlocked("focused_duck"), "Pomodoro work session must unlock focused_duck")

            // Early morning timer (06:30 AM)
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            comps.hour = 6
            comps.minute = 30
            let dawnDate = Calendar.current.date(from: comps)!

            let dawnEvent = TimeDuckEvent.timerCompleted(mode: .timer, duration: 300, isWorkPomodoro: false, isMiniHUD: false)
            engine.evaluateEvent(dawnEvent, stats: stats, now: dawnDate)
            assertTrue(engine.isUnlocked("quack_of_dawn"), "Early morning timer must unlock quack_of_dawn")
        }
    }

    // MARK: - Test 14: Story Completion Domain Event Unlocks
    static func testStoryCompletionDomainEventUnlocks() {
        runTest("testStoryCompletionDomainEventUnlocks") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            engine.evaluateEvent(.storyCompleted(storyId: .theFeast), stats: stats)
            assertTrue(engine.isUnlocked("worth_it"), "The Feast must unlock worth_it")

            engine.evaluateEvent(.storyCompleted(storyId: .theExpedition), stats: stats)
            assertTrue(engine.isUnlocked("summit_duck"), "The Expedition must unlock summit_duck")

            engine.evaluateEvent(.storyCompleted(storyId: .nightShift), stats: stats)
            assertTrue(engine.isUnlocked("clocked_out"), "Night Shift must unlock clocked_out")

            engine.evaluateEvent(.storyCompleted(storyId: .theWod), stats: stats)
            assertTrue(engine.isUnlocked("no_days_off"), "The WOD must unlock no_days_off")

            engine.evaluateEvent(.storyCompleted(storyId: .theRescue), stats: stats)
            assertTrue(engine.isUnlocked("leave_no_duck_behind"), "The Rescue must unlock leave_no_duck_behind")
        }
    }

    // MARK: - Test 15: Feeding and Chonky Achievement Unlocks
    static func testFeedingAndChonkyAchievementUnlocks() {
        runTest("testFeedingAndChonkyAchievementUnlocks") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            // Trigger Chonky
            engine.evaluateEvent(.breadcrumbFed(totalFedToday: 5, triggeredChonky: true), stats: stats)
            assertTrue(engine.isUnlocked("absolute_unit"), "Triggering Chonky Duck must unlock absolute_unit")

            // Feed 25 breadcrumbs total
            for _ in 1..<25 {
                engine.evaluateEvent(.breadcrumbFed(totalFedToday: 1, triggeredChonky: false), stats: stats)
            }
            assertTrue(engine.isUnlocked("breadwinner"), "25 total breadcrumbs fed must unlock breadwinner")
        }
    }

    // MARK: - Test 16: Poke Escalation Achievement Unlock
    static func testPokeEscalationAchievementUnlock() {
        runTest("testPokeEscalationAchievementUnlock") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            engine.evaluateEvent(.duckPoked(level: 2, isTantrum: false), stats: stats)
            assertFalse(engine.isUnlocked("personal_space"), "Level 2 poke should not unlock personal_space")

            engine.evaluateEvent(.duckPoked(level: 5, isTantrum: true), stats: stats)
            assertTrue(engine.isUnlocked("personal_space"), "Level 5 poke escalation must unlock personal_space")
        }
    }

    // MARK: - Test 17: Costume Exploration Achievement Unlock
    static func testCostumeExplorationAchievementUnlock() {
        runTest("testCostumeExplorationAchievementUnlock") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            let hats: [DuckHat] = [.wizard, .detective, .cyber, .barista, .sleepcap]
            for h in hats {
                engine.evaluateEvent(.costumeChanged(hat: h), stats: stats)
            }
            assertTrue(engine.isUnlocked("fashionably_late"), "Trying 5 distinct hats must unlock fashionably_late")
        }
    }

    // MARK: - Test 18: Stopwatch Lap Achievement Unlock
    static func testStopwatchLapAchievementUnlock() {
        runTest("testStopwatchLapAchievementUnlock") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            // Slow lap (8.2s)
            engine.evaluateEvent(.stopwatchLap(split: 8.2, total: 20.0, lapIndex: 1), stats: stats)
            assertFalse(engine.isUnlocked("speed_demon"), "8.2s lap split should not unlock speed_demon")

            // Fast lap (3.4s)
            engine.evaluateEvent(.stopwatchLap(split: 3.4, total: 23.4, lapIndex: 2), stats: stats)
            assertTrue(engine.isUnlocked("speed_demon"), "Sub-5.0s lap split must unlock speed_demon")
        }
    }

    // MARK: - Test 19: Rare Secret Event Achievement Unlocks
    static func testRareSecretEventAchievementUnlocks() {
        runTest("testRareSecretEventAchievementUnlocks") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            engine.evaluateEvent(.rareEventTriggered(type: .ghostGlitch), stats: stats)
            assertTrue(engine.isUnlocked("secret_glitch"), "Ghost glitch must unlock secret_glitch")

            engine.evaluateEvent(.rareEventTriggered(type: .goldenDuck), stats: stats)
            assertTrue(engine.isUnlocked("golden_feathers"), "Golden duck must unlock golden_feathers")
        }
    }

    // MARK: - Test 20: Pond Maestro Sound Toggle Unlock
    static func testPondMaestroSoundToggleUnlock() {
        runTest("testPondMaestroSoundToggleUnlock") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            engine.evaluateEvent(.soundToggled(enabled: true), stats: stats)
            assertTrue(engine.isUnlocked("pond_maestro"), "Toggling sound must unlock pond_maestro")
        }
    }

    // MARK: - Test 21: Streak Achievement Unlock
    static func testStreakAchievementUnlock() {
        runTest("testStreakAchievementUnlock") {
            let engine = AchievementEngine()
            let stats = StatsTracker()

            engine.evaluateEvent(.streakUpdated(days: 3), stats: stats)
            assertTrue(engine.isUnlocked("flock_veteran"), "3-day streak must unlock flock_veteran")
        }
    }

    // MARK: - Test 22: Duckbook Engine Navigation
    static func testDuckbookEngineNavigation() {
        runTest("testDuckbookEngineNavigation") {
            let book = DuckbookEngine()
            assertFalse(book.isOpen, "Duckbook should start closed")

            book.open()
            assertTrue(book.isOpen, "Duckbook open should set isOpen = true")
            assertEqual(book.activeTab, .companions, "Default active tab should be .companions")

            // Tab cycling
            book.nextTab()
            assertEqual(book.activeTab, .achievements, "nextTab from .companions should go to .achievements")
            book.nextTab()
            assertEqual(book.activeTab, .secrets, "nextTab from .achievements should go to .secrets")
            book.nextTab()
            assertEqual(book.activeTab, .companions, "nextTab from .secrets should wrap to .companions")

            // Selection movement
            book.moveSelection(delta: 1)
            assertEqual(book.selectedIndex, 1, "Moving selection delta 1 should advance index")
            book.moveSelection(delta: -5)
            assertEqual(book.selectedIndex, 0, "Moving selection negative should clamp to 0")

            book.close()
            assertFalse(book.isOpen, "close() should set isOpen = false")
        }
    }

    // MARK: - Test 23: Duckbook Accessibility Summary
    static func testDuckbookAccessibilitySummary() {
        runTest("testDuckbookAccessibilitySummary") {
            let book = DuckbookEngine()
            book.open(tab: .companions)
            let compSummary = book.accessibilitySummary()
            assertTrue(compSummary.contains("Companion: TimeDuck"), "Companions accessibility summary must describe active companion")

            book.setTab(.achievements)
            let achSummary = book.accessibilitySummary()
            assertTrue(achSummary.contains("Achievement:"), "Achievements accessibility summary must describe achievement")

            book.setTab(.secrets)
            let secSummary = book.accessibilitySummary()
            assertTrue(secSummary.contains("Secrets Journal:"), "Secrets accessibility summary must describe secrets")
        }
    }

    // MARK: - Test 24: Toast Queueing and Lifecycle
    static func testToastQueueingAndLifecycle() {
        runTest("testToastQueueingAndLifecycle") {
            let engine = AchievementEngine()
            let now = Date()

            // Unlock two achievements in succession
            engine.unlock("first_waddle", now: now)
            engine.unlock("focused_duck", now: now)

            assertEqual(engine.pendingToasts.count, 2, "Pending toasts should contain 2 entries")

            // Step toasts
            engine.updateToasts(now: now)
            assertNotNil(engine.activeToast, "Active toast should pop from pending queue")
            assertEqual(engine.activeToast?.id, "first_waddle", "First toast should be first_waddle")
            assertEqual(engine.pendingToasts.count, 1, "Pending queue should decrement to 1")

            // Step past 3.6s
            let later = now.addingTimeInterval(4.0)
            engine.updateToasts(now: later)
            assertEqual(engine.activeToast?.id, "focused_duck", "Second toast should now be active")

            engine.clearActiveToast()
            assertNil(engine.activeToast, "clearActiveToast must clear active toast")
        }
    }

    // MARK: - Test 25: Regression Finished / Running +1 MIN Preserved
    static func testRegressionFinishedRunningPlusOneMinPreserved() {
        runTest("testRegressionFinishedRunningPlusOneMinPreserved") {
            let tm = TimerModel()
            tm.setDuration(60)
            tm.toggle()
            assertTrue(tm.isRunning, "Timer should be running")

            // Add 1 min while running -> stays running, duration extends
            tm.add(60)
            assertTrue(tm.isRunning, "Timer must remain running after +1 MIN")
            assertEqual(tm.duration, 120, "Timer duration extended to 120")

            // Finish timer
            let pastDate = Date().addingTimeInterval(-5)
            tm.restoreState(duration: 120, remainingAtStop: 0, running: true, endWall: pastDate, completionRecorded: true)
            assertTrue(tm.finished, "Timer is finished")

            // Add 1 min while finished -> reconfigures clock to 180s and clears finished state
            tm.add(60)
            assertFalse(tm.finished, "Adding +1 MIN to finished timer must clear finished state")
            assertFalse(tm.isRunning, "Timer remains stopped ready for user restart")
            assertEqual(tm.duration, 180, "Timer duration updated to 180s")
        }
    }

    // MARK: - Test 26: Regression Timer Lifecycle During Companion Switch
    static func testRegressionTimerLifecycleDuringCompanionSwitch() {
        runTest("testRegressionTimerLifecycleDuringCompanionSwitch") {
            let tm = TimerModel()
            tm.setDuration(300)
            tm.toggle()
            assertTrue(tm.isRunning, "Timer must be running")

            let reg = TimeCompanionRegistry.shared
            reg.unlock(.guardDuck)
            assertTrue(reg.select(.guardDuck), "Selecting Guard Duck succeeds")

            // Timekeeping engine remains running and unaffected
            assertTrue(tm.isRunning, "TimerModel must remain running after switching companion")
            assertEqual(tm.duration, 300, "Timer duration must remain unchanged")
            assertTrue(tm.remaining > 0 && tm.remaining <= 300, "Remaining time must be valid")
        }
    }

    // MARK: - Test 27: Regression Achievement Unlock During Timer Finish
    static func testRegressionAchievementUnlockDuringTimerFinish() {
        runTest("testRegressionAchievementUnlockDuringTimerFinish") {
            let tm = TimerModel()
            let stats = StatsTracker()
            let engine = AchievementEngine()

            tm.setDuration(60)
            tm.toggle()
            let finishDate = Date().addingTimeInterval(61)

            // Authoritative finish check first
            assertTrue(tm.isFinished(at: finishDate), "Timer isFinished check must return true")
            assertFalse(tm.completionRecorded, "completionRecorded starts false")
            tm.markCompletionRecorded()
            assertTrue(tm.completionRecorded, "completionRecorded set before any side effect")
            stats.addFocusSeconds(tm.duration, now: finishDate)

            // Evaluate achievement after authoritative state resolution
            let unlocked = engine.evaluateEvent(
                .timerCompleted(mode: .timer, duration: tm.duration, isWorkPomodoro: false, isMiniHUD: false),
                stats: stats,
                now: finishDate
            )
            assertTrue(unlocked.contains(where: { $0.id == "first_waddle" }), "first_waddle unlocked")
            assertTrue(tm.isFinished(at: finishDate), "TimerModel isFinished(at: finishDate) remains true")
            assertEqual(stats.todayFocusSeconds, 60, "Stats recorded exactly 60 seconds")
        }
    }

    // MARK: - Test 28: Developer Override Unlock All Companions and Achievements
    static func testDeveloperOverrideUnlockAllCompanionsAndAchievements() {
        runTest("testDeveloperOverrideUnlockAllCompanionsAndAchievements") {
            #if DEBUG
            let reg = TimeCompanionRegistry.shared
            let engine = AchievementEngine.shared
            reg.restoreState(activeId: "timeduck", unlockedIds: ["timeduck"])
            engine.restoreState(unlockedAchievements: [:])

            assertFalse(reg.isUnlocked(.cyberDuck), "CyberDuck starts locked")
            assertFalse(engine.isUnlocked("secret_glitch"), "Secret glitch starts locked")

            // Enable Dev Unlock All
            DeveloperOverride.shared.isUnlockAllActive = true
            for comp in reg.allCompanions {
                assertTrue(reg.isUnlocked(comp.id), "In dev override mode, \(comp.displayName) must be unlocked")
            }
            assertTrue(reg.select(.cyberDuck), "Selecting secret CyberDuck in dev mode must succeed")
            assertEqual(reg.activeCompanionId, .cyberDuck, "Active companion is now CyberDuck")

            for ach in engine.orderedCatalog {
                assertTrue(engine.isUnlocked(ach.id), "In dev override mode, achievement \(ach.id) must be unlocked")
                assertNotNil(engine.unlockDate(for: ach.id), "In dev override mode, unlock date must be non-nil")
            }
            assertEqual(engine.unlockedCount, engine.totalCount, "Unlocked count must equal total count in dev mode")

            // Cleanup
            DeveloperOverride.shared.resetToGenuine()
            reg.sanitizeActiveCompanion()
            assertEqual(reg.activeCompanionId, .timeDuck, "After dev mode reset, unearned active companion sanitizes to TimeDuck")
            #endif
        }
    }

    // MARK: - Test 29: Developer Override Reset to Genuine
    static func testDeveloperOverrideResetToGenuine() {
        runTest("testDeveloperOverrideResetToGenuine") {
            #if DEBUG
            let reg = TimeCompanionRegistry.shared
            let engine = AchievementEngine.shared
            reg.restoreState(activeId: "timeduck", unlockedIds: ["timeduck", "girl_duck"])
            engine.restoreState(unlockedAchievements: ["first_waddle": "2026-08-27T00:00:00Z"])

            DeveloperOverride.shared.isUnlockAllActive = true
            assertTrue(reg.isUnlocked(.guardDuck), "Guard Duck unlocked in dev mode")
            assertTrue(engine.isUnlocked("secret_glitch"), "Secret glitch unlocked in dev mode")

            // Reset
            DeveloperOverride.shared.resetToGenuine()
            assertFalse(reg.isUnlocked(.guardDuck), "Guard Duck locked after dev reset")
            assertTrue(reg.isUnlocked(.girlDuck), "Girl Duck remains unlocked from genuine progression")
            assertTrue(engine.isUnlocked("first_waddle"), "first_waddle remains unlocked from genuine progression")
            assertFalse(engine.isUnlocked("secret_glitch"), "Secret glitch locked after dev reset")
            assertEqual(engine.unlockedCount, 1, "Only genuine unlocks count")
            #endif
        }
    }

    // MARK: - Test 30: Developer Override Persistence Isolation
    static func testDeveloperOverridePersistenceIsolation() {
        runTest("testDeveloperOverridePersistenceIsolation") {
            #if DEBUG
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            Store.storageDirectoryOverrideURL = tempDir
            defer {
                Store.storageDirectoryOverrideURL = nil
                try? FileManager.default.removeItem(at: tempDir)
            }

            let reg = TimeCompanionRegistry.shared
            let engine = AchievementEngine.shared
            let sw = StopwatchModel()
            let tm = TimerModel()
            let pomo = PomodoroModel()
            let stats = StatsTracker()

            reg.restoreState(activeId: "timeduck", unlockedIds: ["timeduck"])
            engine.restoreState(unlockedAchievements: [:])

            // Turn on Dev mode and select an unearned companion
            DeveloperOverride.shared.isUnlockAllActive = true
            assertTrue(reg.select(.guardDuck), "Guard Duck selected in dev mode")

            // Save immediate state
            Store.saveImmediate(
                sw: sw, tm: tm, pomo: pomo, stats: stats,
                mode: .timer, theme: .terminal, hat: .none, crt: true
            )

            // Verify the loaded state from disk contains ONLY genuine progression
            let loaded = Store.load()
            assertNotNil(loaded, "Persisted state must exist")
            if let st = loaded {
                assertEqual(st.selectedCompanion, "timeduck", "Persisted selectedCompanion must sanitize to timeduck and isolate unearned companion")
                assertEqual(st.unlockedCompanions, ["timeduck"], "Persisted unlockedCompanions must not include fake dev unlocks")
                assertEqual(st.unlockedAchievements?.count, 0, "Persisted achievements must be empty")
            }

            // Cleanup
            DeveloperOverride.shared.resetToGenuine()
            reg.sanitizeActiveCompanion()
            #endif
        }
    }
}
