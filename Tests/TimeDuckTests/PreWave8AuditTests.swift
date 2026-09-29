// MARK: - TimeDuck · PreWave8AuditTests.swift
// Adversarial regression coverage for the Sol Ralph pre-Wave-8 foundation audit.

import Foundation
import AppKit

enum PreWave8AuditTests {
    static func runAll() {
        print("\n▸ Testing Pre-Wave-8 Adversarial State & Lifecycle Invariants…")
        testCancelledStoryCannotResurrect()
        testAutoStoryReResolvesAfterModeChange()
        testStoryPauseResumePreservesScene()
        testFinaleOneShotRearmsForNewSession()
        testPomodoroPausedAdjustmentKeepsDurationConsistent()
        testIndependentCompletedModeAlarmOwnership()
        testEngineFinaleClockAdvancesAndRemainsBounded()
        testWodCadenceEventsAreEdgeTriggered()
        testAllStoryMilestoneBoundaries()
        testDeveloperPreviewRestoresLiveStoryAndUserSelection()
        testImmediatePersistenceCannotBeOverwrittenByStaleDebounce()
        testPersistenceBackwardCompatibilityAndRestoreSanitization()
        testHostilePersistedCountersCannotOverflowRuntime()
        testStopwatchBoundsElapsedAndLapHistory()
        testRapidFeedHistoryRemainsBounded()
        testPausedStoryDoesNotDemandHighRateAnimation()
        testSleepAndTemporaryEffectOwnershipAcrossWakePaths()
        testCompletedClockAdjustmentCannotResurrectOrDoubleRecord()
        testDeterministicClockAndStoryOperationFuzz()
        testExtremeMiniHUDFormattingAndResourceBounds()
        testSimultaneousCompletionsCoalesceAudioButNotRecords()
        testClockAdjustmentUpperBoundsPreserveWallAnchorConsistency()
        testPreviewCompletionStateIsIndependentFromRealClockCompletion()
        testPomodoroBreakDurationAdjustmentsWhileFinished()
        testThemeAndCostumeSelectionPreservedDuringStoryPreview()
        testStopwatchMiniHUDResetCancelsStoryAndRearmsFreshSession()
        testTimerDoneActionClearsFinaleAndRearmsStoppedClock()
        testTimerPresetClearsFinishedFinaleAndReconfiguresClock()
        testPomodoroPresetClearsFinishedFinaleAndReconfiguresDuration()
        testDirectTimeEntryClearsFinishedFinaleAndReconfiguresDuration()
        testViewportTransitionClearsAllCoordinateOwnedEffects()
        testTimerRestoreRunningClockValidRemaining()
        testTimerRestoreRunningClockExcessiveFutureClampedToDuration()
        testTimerRestoreRunningClockMaxDurationBoundary()
        testTimerRestoreRunningClockPastEndWall()
        testPomodoroRestoreRunningClockExcessiveFutureClampedToDuration()
        testVisiblePlusOneMinActionOnFinishedTimerCancelsStoryFinaleAndReconfiguresClock()
        testVisiblePlusOneMinActionOnRunningTimerPreservesActiveStorySession()
    }

    private static func context(
        mode: Mode = .timer,
        progress: Double = 0.0,
        running: Bool = true,
        paused: Bool = false,
        finished: Bool = false,
        duration: Double = 600
    ) -> DuckStoryContext {
        DuckStoryContext(
            mode: mode,
            isRunning: running,
            isPaused: paused,
            isFinished: finished,
            normalizedProgress: progress,
            sessionDuration: duration,
            remainingSeconds: max(0, duration * (1.0 - progress)),
            elapsedSeconds: max(0, duration * progress),
            isCompact: false,
            reduceMotion: false,
            localHour: 12,
            currentHat: .none,
            currentTheme: .arcade
        )
    }

    static func testCancelledStoryCannotResurrect() {
        runTest("testCancelledStoryCannotResurrect") {
            let engine = DuckStoryEngine(initialSelection: .theRescue)
            let active = context(progress: 0.6)
            engine.prepareSession(context: active)
            engine.startSession(context: active)
            engine.updateProgress(context: active, now: Date())
            assertNotNil(engine.activeStory)

            engine.cancelSession(context: active)
            assertNil(engine.activeStory, "Cancellation must release the active story")
            assertFalse(engine.isPrepared, "Cancellation must invalidate the prepared session")

            engine.updateProgress(context: active, now: Date())
            engine.tick(dt: 0.1, now: Date(), context: active)
            assertTrue(engine.actors.isEmpty, "A cancelled story must not recreate actors on later view ticks")
            assertTrue(engine.props.isEmpty, "A cancelled story must not recreate props on later view ticks")
            assertNil(engine.currentPerformanceOverride, "A cancelled story must not recreate a performance override")
        }
    }

    static func testAutoStoryReResolvesAfterModeChange() {
        runTest("testAutoStoryReResolvesAfterModeChange") {
            let engine = DuckStoryEngine(initialSelection: .auto)
            let timer = context(mode: .timer, duration: 900)
            engine.prepareSession(context: timer)
            engine.startSession(context: timer)
            assertNil(engine.activeStory, "Standard timer must not auto-select stories (Wave 8.1)")

            let stopwatch = context(mode: .stopwatch, duration: 300)
            engine.startSession(context: stopwatch)
            assertNil(engine.activeStory, "Stopwatch session must not auto-select stories (Wave 8.1)")

            let pomo = context(mode: .pomodoro, duration: 1500)
            engine.startSession(context: pomo)
            assertTrue(engine.activeStory != nil, "Pomodoro session must auto-select active story")
        }
    }

    static func testStoryPauseResumePreservesScene() {
        runTest("testStoryPauseResumePreservesScene") {
            let engine = DuckStoryEngine(initialSelection: .theExpedition)
            let running = context(progress: 0.61)
            engine.prepareSession(context: running)
            engine.startSession(context: running)
            engine.updateProgress(context: running, now: Date())
            assertEqual(engine.activeStory?.activeSceneIndex, 3)

            let paused = context(progress: 0.61, running: false, paused: true)
            engine.pauseSession(context: paused)
            engine.startSession(context: running)
            assertEqual(engine.activeStory?.activeSceneIndex, 3, "Resume must not replay onStart or reset the active scene")
            assertFalse(engine.props.contains(where: { $0.id == "trail_sign" }), "Resume must not replace the current scene's scenery with Scene 1")
            assertFalse(engine.isSessionPaused, "Resume must clear the paused lifecycle state")
        }
    }

    static func testFinaleOneShotRearmsForNewSession() {
        runTest("testFinaleOneShotRearmsForNewSession") {
            let engine = DuckStoryEngine(initialSelection: .theExpedition)
            var fanfareCount = 0
            engine.onPlaySound = { name in
                if name == "flagPlantFanfare" { fanfareCount += 1 }
            }

            let finished = context(progress: 1.0, running: false, finished: true)
            engine.prepareSession(context: finished)
            engine.startSession(context: finished)
            engine.updateProgress(context: finished, now: Date())
            assertEqual(fanfareCount, 1, "First finale must fire its one-shot exactly once")

            let newSession = context(progress: 0.0)
            engine.startSession(context: newSession)
            engine.updateProgress(context: finished, now: Date())
            assertEqual(fanfareCount, 2, "A genuinely new session must re-arm the finale one-shot")
        }
    }

    static func testPomodoroPausedAdjustmentKeepsDurationConsistent() {
        runTest("testPomodoroPausedAdjustmentKeepsDurationConsistent") {
            let pomo = PomodoroModel()
            pomo.add(60)
            assertEqual(pomo.workDuration, 26 * 60, "Paused +1 minute must update the authoritative work duration")
            assertEqual(pomo.remainingAtStop, 26 * 60, "Paused +1 minute must update remaining time by the same amount")

            pomo.add(-120)
            assertEqual(pomo.workDuration, 24 * 60, "Paused subtraction must keep duration synchronized")
            assertEqual(pomo.remainingAtStop, 24 * 60, "Paused subtraction must keep remaining synchronized")
        }
    }

    static func testIndependentCompletedModeAlarmOwnership() {
        runTest("testIndependentCompletedModeAlarmOwnership") {
            let sw = StopwatchModel()
            let tm = TimerModel()
            let pomo = PomodoroModel()
            let stats = StatsTracker()
            let view = TimeDuckView(sw: sw, tm: tm, pomo: pomo, stats: stats)
            let now = Date()

            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: now.addingTimeInterval(-1))
            pomo.restoreState(
                phase: PomodoroPhase.work.rawValue,
                cycles: 0,
                remainingAtStop: 60,
                running: true,
                endWall: now.addingTimeInterval(-1),
                workDuration: 60
            )

            view.currentMode = .timer
            _ = view.processTimeEvents(now)
            assertFalse(view.alarmDismissed, "Timer completion must begin undismissed")
            view.dismissAlarm()
            assertTrue(view.alarmDismissed, "Dismissing Timer must affect Timer")

            view.currentMode = .pomodoro
            assertFalse(view.alarmDismissed, "Dismissing Timer must not dismiss an independently completed Pomodoro")
        }
    }

    static func testEngineFinaleClockAdvancesAndRemainsBounded() {
        runTest("testEngineFinaleClockAdvancesAndRemainsBounded") {
            let stories: [DuckStoryId] = [.theFeast, .theExpedition, .nightShift, .theWod, .theRescue]
            let finished = context(progress: 1.0, running: false, finished: true)

            for storyId in stories {
                let engine = DuckStoryEngine(initialSelection: storyId)
                engine.prepareSession(context: finished)
                engine.startSession(context: finished)
                engine.updateProgress(context: finished, now: Date())

                for step in 0..<360 { // six simulated hours in one-minute steps
                    engine.tick(
                        dt: 60,
                        now: Date(timeIntervalSinceReferenceDate: Double(step * 60)),
                        context: finished
                    )
                    assertTrue(engine.actors.count <= 1, "\(storyId) actors must remain bounded in a long finale")
                    assertTrue(engine.props.count <= 2, "\(storyId) props must remain bounded in a long finale")
                }

                assertEqual(engine.finaleElapsedTime, 6 * 60 * 60, accuracy: 0.001, "Engine finale clock must advance for MiniHUD choreography")
                assertTrue(engine.activeStory?.finaleElapsedTime.isFinite == true, "Story finale time must remain finite")
            }
        }
    }

    static func testWodCadenceEventsAreEdgeTriggered() {
        runTest("testWodCadenceEventsAreEdgeTriggered") {
            let engine = DuckStoryEngine(initialSelection: .theWod)
            var gymTicks = 0
            var sweatBursts = 0
            engine.onPlaySound = { if $0 == "gymTick" { gymTicks += 1 } }
            engine.onSpawnSweat = { sweatBursts += 1 }

            let elliptical = context(progress: 0.21)
            engine.prepareSession(context: elliptical)
            engine.startSession(context: elliptical)
            engine.updateProgress(context: elliptical, now: Date())
            for frame in 0..<60 {
                engine.tick(dt: 1.0 / 60.0, now: Date(timeIntervalSinceReferenceDate: Double(frame) / 60.0), context: elliptical)
            }
            assertEqual(gymTicks, 1, "One cadence beat must not retrigger on every 60 FPS frame")

            let treadmill = context(progress: 0.41)
            engine.updateProgress(context: treadmill, now: Date())
            for frame in 0..<30 {
                engine.tick(dt: 1.0 / 60.0, now: Date(timeIntervalSinceReferenceDate: 1 + Double(frame) / 60.0), context: treadmill)
            }
            assertEqual(sweatBursts, 1, "One sweat beat must not retrigger on every 60 FPS frame")
        }
    }

    static func testAllStoryMilestoneBoundaries() {
        runTest("testAllStoryMilestoneBoundaries") {
            let stories: [DuckStoryId] = [.theFeast, .theExpedition, .nightShift, .theWod, .theRescue]
            let boundaries = [0.20, 0.40, 0.60, 0.80, 1.00]

            for storyId in stories {
                for (boundaryIndex, boundary) in boundaries.enumerated() {
                    let engine = DuckStoryEngine(initialSelection: storyId)
                    let below = context(progress: boundary - 0.000001, finished: false)
                    engine.prepareSession(context: below)
                    engine.startSession(context: below)
                    engine.updateProgress(context: below, now: Date())

                    if let feast = engine.activeStory as? TheFeastStory {
                        assertEqual(feast.fullnessStage, boundaryIndex, "Feast stage immediately below \(boundary)")
                    } else {
                        assertEqual(engine.activeStory?.activeSceneIndex, min(4, boundaryIndex), "\(storyId) scene immediately below \(boundary)")
                    }

                    let exact = context(progress: boundary, running: boundary < 1.0, finished: boundary >= 1.0)
                    engine.updateProgress(context: exact, now: Date())
                    assertEqual(engine.currentMilestoneIndex, boundaryIndex + 1, "\(storyId) milestone at exact boundary \(boundary)")
                    if boundary < 1.0 {
                        if let feast = engine.activeStory as? TheFeastStory {
                            assertEqual(feast.fullnessStage, boundaryIndex + 1, "Feast exact stage at \(boundary)")
                        } else {
                            assertEqual(engine.activeStory?.activeSceneIndex, min(4, boundaryIndex + 1), "\(storyId) exact scene at \(boundary)")
                        }
                        assertFalse(engine.isFinaleActive, "\(storyId) must not enter finale before 100%")
                    } else {
                        assertTrue(engine.isFinaleActive, "\(storyId) must enter finale at exactly 100%")
                    }

                    let above = context(progress: min(1.0, boundary + 0.000001), running: boundary < 1.0, finished: boundary >= 1.0)
                    engine.updateProgress(context: above, now: Date())
                    assertTrue(engine.actors.count <= 1, "\(storyId) boundary actors must not duplicate")
                    assertTrue(engine.props.count <= 2, "\(storyId) boundary props must not duplicate")
                }
            }
        }
    }

    static func testDeveloperPreviewRestoresLiveStoryAndUserSelection() {
        runTest("testDeveloperPreviewRestoresLiveStoryAndUserSelection") {
            let defaultsKey = "td.storySelection"
            let originalDefault = UserDefaults.standard.object(forKey: defaultsKey)
            defer {
                if let originalDefault = originalDefault {
                    UserDefaults.standard.set(originalDefault, forKey: defaultsKey)
                } else {
                    UserDefaults.standard.removeObject(forKey: defaultsKey)
                }
            }

            UserDefaults.standard.set(DuckStoryId.nightShift.rawValue, forKey: defaultsKey)
            let engine = DuckStoryEngine(initialSelection: .nightShift)
            let live = context(progress: 0.41)
            engine.prepareSession(context: live)
            engine.startSession(context: live)
            engine.updateProgress(context: live, now: Date())
            engine.tick(dt: 0.25, now: Date(), context: live)

            let liveStory = engine.activeStory
            let liveScene = liveStory?.activeSceneIndex
            let liveProps = engine.props.map(\.id)
            let liveOverride = engine.currentPerformanceOverride?.spriteRows

            engine.beginPreview(.theRescue)
            let preview = context(progress: 1.0, running: false, finished: true)
            engine.prepareSession(context: preview)
            engine.startSession(context: preview)
            engine.updateProgress(context: preview, now: Date())
            assertEqual(engine.selectedStoryId, .theRescue)
            assertTrue(engine.isFinaleActive)
            assertEqual(UserDefaults.standard.string(forKey: defaultsKey), DuckStoryId.nightShift.rawValue, "Preview must not overwrite the saved user selection")

            engine.endPreview()
            assertEqual(engine.selectedStoryId, .nightShift, "Preview exit must restore the live selection")
            assertTrue(engine.activeStory === liveStory, "Preview exit must restore the exact live story instance")
            assertEqual(engine.activeStory?.activeSceneIndex, liveScene, "Preview exit must restore the live scene")
            assertEqual(engine.props.map(\.id), liveProps, "Preview exit must restore live props")
            assertEqual(engine.currentPerformanceOverride?.spriteRows, liveOverride, "Preview exit must restore the live pose")
            assertTrue(engine.isSessionStarted, "Preview exit must restore live session lifecycle")
        }
    }

    static func testImmediatePersistenceCannotBeOverwrittenByStaleDebounce() {
        runTest("testImmediatePersistenceCannotBeOverwrittenByStaleDebounce") {
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("TimeDuck-PreWave8-\(UUID().uuidString)", isDirectory: true)
            Store.storageDirectoryOverrideURL = tempDir
            defer {
                Store.cancelPending()
                Store.storageDirectoryOverrideURL = nil
                try? FileManager.default.removeItem(at: tempDir)
            }

            let oldStopwatch = StopwatchModel()
            oldStopwatch.restoreState(banked: 10, running: false, startAnchor: nil, splits: [], totals: [])
            let newStopwatch = StopwatchModel()
            newStopwatch.restoreState(banked: 20, running: false, startAnchor: nil, splits: [], totals: [])
            let timer = TimerModel()
            let pomo = PomodoroModel()
            let stats = StatsTracker()

            Store.saveDebounced(
                sw: oldStopwatch, tm: timer, pomo: pomo, stats: stats,
                mode: .stopwatch, theme: .arcade, hat: .none, crt: true, delay: 0.05
            )
            Store.saveImmediate(
                sw: newStopwatch, tm: timer, pomo: pomo, stats: stats,
                mode: .stopwatch, theme: .arcade, hat: .none, crt: true
            )

            Thread.sleep(forTimeInterval: 0.10)
            let loaded = Store.load()
            assertEqual(loaded?.swBanked, 20, "A stale debounced snapshot must never overwrite the final immediate save")
        }
    }

    static func testPersistenceBackwardCompatibilityAndRestoreSanitization() {
        runTest("testPersistenceBackwardCompatibilityAndRestoreSanitization") {
            let legacyJSON = """
            {
              "mode": 999,
              "swBanked": 12.5,
              "swRunning": false,
              "lapsSplits": [],
              "lapsTotals": [],
              "tmDuration": 60,
              "tmRemainingAtStop": 60,
              "tmRunning": false,
              "crt": true,
              "futureField": { "ignored": true }
            }
            """.data(using: .utf8)!
            let legacy = try JSONDecoder().decode(PersistedState.self, from: legacyJSON)
            assertEqual(legacy.mode, 999, "Unknown enum raw values should decode for safe fallback by the coordinator")
            assertNil(legacy.pomoPhase, "Missing newer optional keys must remain backward-compatible")

            let stopwatch = StopwatchModel()
            stopwatch.restoreState(
                banked: .nan,
                running: false,
                startAnchor: nil,
                splits: [5, -1, 2, .infinity],
                totals: [5, 4, 7, 9]
            )
            assertEqual(stopwatch.banked, 0, "Non-finite persisted stopwatch time must fall back safely")
            assertEqual(stopwatch.laps.count, 2, "Negative, non-monotonic, and non-finite laps must be rejected")
            assertTrue(stopwatch.laps.allSatisfy { $0.split >= 0 && $0.total >= 0 })

            let timer = TimerModel()
            timer.restoreState(duration: .infinity, remainingAtStop: -.infinity, running: false, endWall: nil)
            assertEqual(timer.duration, 60, "Non-finite timer duration must fall back to default")
            assertEqual(timer.remainingAtStop, 60)

            let pomo = PomodoroModel()
            pomo.restoreState(
                phase: 999, cycles: -4, remainingAtStop: .nan,
                running: false, endWall: nil,
                workDuration: .infinity, shortBreakDuration: -5, longBreakDuration: .nan
            )
            assertEqual(pomo.phase, .work, "Unknown Pomodoro phase must fall back to work")
            assertEqual(pomo.cyclesCompleted, 0)
            assertEqual(pomo.workDuration, 25 * 60)
            assertEqual(pomo.shortBreakDuration, 60, "Invalid short break duration must clamp safely")
            assertEqual(pomo.longBreakDuration, 15 * 60)

            let stats = StatsTracker()
            stats.restoreState(
                todayFocusSeconds: -.infinity,
                todayPomodoros: -8,
                streakDays: -2,
                lastActiveDate: "not-a-date"
            )
            assertEqual(stats.todayFocusSeconds, 0)
            assertEqual(stats.todayPomodoros, 0)
            assertEqual(stats.streakDays, 1)
            assertFalse(stats.lastActiveDateStr.isEmpty)
        }
    }

    static func testHostilePersistedCountersCannotOverflowRuntime() {
        runTest("testHostilePersistedCountersCannotOverflowRuntime") {
            let pomo = PomodoroModel()
            pomo.restoreState(
                phase: PomodoroPhase.work.rawValue,
                cycles: Int.max,
                remainingAtStop: 60,
                running: false,
                endWall: nil
            )
            assertEqual(pomo.cyclesCompleted, 1_000_000, "Persisted cycle counts must be bounded before UI arithmetic")
            pomo.advancePhase()
            assertEqual(pomo.cyclesCompleted, 1, "A bounded cycle counter must roll safely without breaking phase cadence")
            assertEqual(pomo.phase, .shortBreak)

            let stats = StatsTracker()
            stats.restoreState(
                todayFocusSeconds: .greatestFiniteMagnitude,
                todayPomodoros: Int.max,
                streakDays: Int.max,
                lastActiveDate: stats.lastActiveDateStr
            )
            stats.recordPomodoroCompleted(duration: .greatestFiniteMagnitude)
            stats.addFocusSeconds(.infinity)
            assertEqual(stats.todayPomodoros, 1_000_000)
            assertEqual(stats.streakDays, 1_000_000)
            assertTrue(stats.todayFocusSeconds.isFinite, "Restored and accumulated focus time must stay finite")
        }
    }

    static func testStopwatchBoundsElapsedAndLapHistory() {
        runTest("testStopwatchBoundsElapsedAndLapHistory") {
            let sw = StopwatchModel()
            let start = Date(timeIntervalSince1970: 1_000)
            sw.start(now: start)
            for second in 1...1_100 {
                _ = sw.lap(now: start.addingTimeInterval(Double(second)))
            }
            assertEqual(sw.laps.count, 1_000, "Lap history must remain bounded under rapid long-running input")

            sw.stop(now: Date.distantFuture)
            let maximumElapsed = 999_999 * 3600.0 + 3599.99
            assertTrue(sw.elapsed.isFinite)
            assertTrue(sw.elapsed <= maximumElapsed, "Stopped Stopwatch time must preserve the same cap as running time")

            let restored = StopwatchModel()
            let splits = Array(repeating: 1.0, count: 1_500)
            let totals = (1...1_500).map(Double.init)
            restored.restoreState(banked: 1_500, running: false, startAnchor: nil, splits: splits, totals: totals)
            assertEqual(restored.laps.count, 1_000, "Persisted lap arrays must be bounded during restore")
        }
    }

    static func testRapidFeedHistoryRemainsBounded() {
        runTest("testRapidFeedHistoryRemainsBounded") {
            let brain = DuckBrain()
            for _ in 0..<10_000 {
                _ = brain.onCrumbEaten()
            }
            assertTrue(brain.crumbsEatenTimestamps.count <= 32, "Rapid FEED input must not grow Chonky history without bound")
            assertTrue(brain.isChonky, "Bounding the history must preserve the overfeeding behavior")
        }
    }

    static func testPausedStoryDoesNotDemandHighRateAnimation() {
        runTest("testPausedStoryDoesNotDemandHighRateAnimation") {
            let view = TimeDuckView(
                sw: StopwatchModel(),
                tm: TimerModel(),
                pomo: PomodoroModel(),
                stats: StatsTracker()
            )
            view.skipSplash()
            let running = context(mode: .timer, progress: 0.45, running: true)
            view.storyEngine.prepareSession(context: running)
            view.storyEngine.startSession(context: running)
            view.storyEngine.updateProgress(context: running, now: Date())
            assertTrue(view.storyRequiresHighRateAnimation, "A running story should request the high-rate animation pump")

            let paused = context(mode: .timer, progress: 0.45, running: false, paused: true)
            view.storyEngine.pauseSession(context: paused)
            assertFalse(view.storyRequiresHighRateAnimation, "Static paused actors must not pin the app at 60 FPS")

            view.storyEngine.resumeSession(context: running)
            assertTrue(view.storyRequiresHighRateAnimation, "Resuming the story should restore high-rate animation")
        }
    }

    static func testSleepAndTemporaryEffectOwnershipAcrossWakePaths() {
        runTest("testSleepAndTemporaryEffectOwnershipAcrossWakePaths") {
            let view = TimeDuckView(
                sw: StopwatchModel(),
                tm: TimerModel(),
                pomo: PomodoroModel(),
                stats: StatsTracker()
            )
            let t0 = Date()

            for index in 0..<10 {
                view.spawnSnoreParticle(
                    rows: DUCK_SLEEP_DEEP,
                    duckX: 40,
                    duckY: 20,
                    flip: index % 2 == 1,
                    isMini: true,
                    now: t0.addingTimeInterval(Double(index * 4))
                )
            }
            assertEqual(view.activeSnoreParticleCount, 3, "Snore emitter must remain strictly bounded")

            view.toast("WAKE")
            assertEqual(view.activeSnoreParticleCount, 0, "Keyboard/menu toast wake paths must purge snores immediately")

            view.spawnSnoreParticle(rows: DUCK_SLEEP_DEEP, duckX: 40, duckY: 20, flip: false, isMini: false, now: t0)
            view.setMini(true)
            assertEqual(view.activeSnoreParticleCount, 0, "Compact/full switching must not carry particles between coordinate spaces")

            view.spawnSnoreParticle(rows: DUCK_SLEEP_DEEP, duckX: 40, duckY: 20, flip: true, isMini: true, now: t0)
            view.currentMode = .timer
            view.dismissAlarm()
            assertEqual(view.activeSnoreParticleCount, 0, "Alarm dismissal must purge sleep FX")

            view.spawnSteamPuff()
            view.dropBreadcrumb(at: 40)
            assertTrue(view.activeTemporaryParticleCount > 0)
            assertTrue(view.activeBreadcrumbCount > 0)
            view.clearTemporaryEffects()
            assertEqual(view.activeTemporaryParticleCount, 0, "Reset/preview cleanup must purge temporary particles")
            assertEqual(view.activeBreadcrumbCount, 0, "Reset/preview cleanup must purge breadcrumbs and their movement target")
        }
    }

    static func testCompletedClockAdjustmentCannotResurrectOrDoubleRecord() {
        runTest("testCompletedClockAdjustmentCannotResurrectOrDoubleRecord") {
            let now = Date()
            let tm = TimerModel()
            let pomo = PomodoroModel()
            let stats = StatsTracker()
            let view = TimeDuckView(sw: StopwatchModel(), tm: tm, pomo: pomo, stats: stats)

            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: now.addingTimeInterval(-1))
            view.currentMode = .timer
            _ = view.processTimeEvents(now)
            assertEqual(stats.todayFocusSeconds, 60)

            tm.add(60)
            assertFalse(tm.isRunning, "Adjusting an expired Timer must configure a stopped next session, not resurrect the old anchor")
            assertEqual(tm.duration, 120)
            assertEqual(tm.remainingAtStop, 120)
            _ = view.processTimeEvents(now.addingTimeInterval(500))
            assertEqual(stats.todayFocusSeconds, 60, "Configuring after completion must not record the prior Timer twice")

            pomo.restoreState(
                phase: PomodoroPhase.work.rawValue, cycles: 0, remainingAtStop: 60,
                running: true, endWall: now.addingTimeInterval(-1), workDuration: 60
            )
            view.currentMode = .pomodoro
            _ = view.processTimeEvents(now)
            let recordedPomos = stats.todayPomodoros
            pomo.setWorkDuration(25 * 60)
            assertFalse(pomo.isRunning, "Changing a preset after Pomodoro completion must not retain an expired running anchor")
            _ = view.processTimeEvents(now.addingTimeInterval(500))
            assertEqual(stats.todayPomodoros, recordedPomos, "Changing a completed Pomodoro preset must not double-record completion")
        }
    }

    static func testDeterministicClockAndStoryOperationFuzz() {
        runTest("testDeterministicClockAndStoryOperationFuzz") {
            let seeds: [UInt64] = [0x54494D454455434B, 0xCAFEBABE12345678, 0xDEADBEEF98765432]

            for initialSeed in seeds {
                var seed = initialSeed
                func nextRandom() -> UInt64 {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return seed
                }

                let sw = StopwatchModel()
                let tm = TimerModel()
                let pomo = PomodoroModel()
                let story = DuckStoryEngine(initialSelection: .auto)
                let base = Date()
                var mode: Mode = .timer

                for step in 0..<5_000 {
                    let now = base.addingTimeInterval(Double(step) * 0.25)
                    let operation = Int(nextRandom() % 16)
                    switch operation {
                    case 0: sw.start(now: now)
                    case 1: sw.stop(now: now)
                    case 2: _ = sw.lap(now: now)
                    case 3: sw.reset()
                    case 4: tm.toggle(now: now)
                    case 5: tm.add(Double(Int(nextRandom() % 121) - 60))
                    case 6: tm.restart(now: now, autoStart: nextRandom() % 2 == 0)
                    case 7: pomo.toggle(now: now)
                    case 8: pomo.add(Double(Int(nextRandom() % 121) - 60))
                    case 9: pomo.advancePhase(autoStart: nextRandom() % 2 == 0, now: now)
                    case 10: pomo.reset()
                    case 11: mode = Mode(rawValue: Int(nextRandom() % 3)) ?? .timer
                    case 12:
                        let ctx = fuzzContext(mode: mode, sw: sw, tm: tm, pomo: pomo)
                        story.startSession(context: ctx)
                    case 13:
                        let ctx = fuzzContext(mode: mode, sw: sw, tm: tm, pomo: pomo)
                        story.pauseSession(context: ctx)
                    case 14:
                        let previewId: DuckStoryId = [.theFeast, .theExpedition, .nightShift, .theWod, .theRescue][Int(nextRandom() % 5)]
                        story.beginPreview(previewId)
                        let ctx = context(mode: mode, progress: Double(nextRandom() % 1_001) / 1_000.0)
                        story.prepareSession(context: ctx)
                        story.startSession(context: ctx)
                    default:
                        story.endPreview()
                        let ctx = fuzzContext(mode: mode, sw: sw, tm: tm, pomo: pomo)
                        story.cancelSession(context: ctx)
                    }

                    let ctx = fuzzContext(mode: mode, sw: sw, tm: tm, pomo: pomo)
                    story.updateProgress(context: ctx, now: now)
                    story.tick(dt: 0.1, now: now, context: ctx)

                    assertTrue(sw.elapsed(at: now).isFinite && sw.elapsed(at: now) >= 0, "Fuzz step \(step): Stopwatch invariant")
                    assertTrue(tm.duration.isFinite && tm.duration >= 5, "Fuzz step \(step): Timer duration invariant")
                    assertTrue(tm.remaining(at: now).isFinite && tm.remaining(at: now) >= 0, "Fuzz step \(step): Timer remaining invariant")
                    assertTrue(pomo.currentDuration.isFinite && pomo.currentDuration >= 60, "Fuzz step \(step): Pomodoro duration invariant")
                    assertTrue(pomo.remaining(at: now).isFinite && pomo.remaining(at: now) >= 0, "Fuzz step \(step): Pomodoro remaining invariant")
                    assertTrue(pomo.cyclesCompleted >= 0, "Fuzz step \(step): Pomodoro cycle invariant")
                    assertTrue(story.actors.count <= 1 && story.props.count <= 2, "Fuzz step \(step): bounded story entity invariant")
                    if story.activeStory == nil {
                        assertFalse(story.isPrepared, "Fuzz step \(step): nil story cannot remain prepared")
                    }
                }
            }
        }
    }

    private static func fuzzContext(
        mode: Mode,
        sw: StopwatchModel,
        tm: TimerModel,
        pomo: PomodoroModel
    ) -> DuckStoryContext {
        let total: Double
        let remaining: Double
        let elapsed: Double
        let running: Bool
        let finished: Bool
        switch mode {
        case .stopwatch:
            total = 300
            elapsed = min(total, sw.elapsed)
            remaining = max(0, total - elapsed)
            running = sw.isRunning
            finished = false
        case .timer:
            total = tm.duration
            remaining = tm.remaining
            elapsed = max(0, total - remaining)
            running = tm.isRunning
            finished = tm.finished
        case .pomodoro:
            total = pomo.currentDuration
            remaining = pomo.remaining
            elapsed = max(0, total - remaining)
            running = pomo.isRunning
            finished = pomo.finished
        }
        return DuckStoryContext(
            mode: mode,
            isRunning: running,
            isPaused: !running && elapsed > 0,
            isFinished: finished,
            normalizedProgress: total > 0 ? min(1, max(0, elapsed / total)) : 0,
            sessionDuration: total,
            remainingSeconds: remaining,
            elapsedSeconds: elapsed,
            isCompact: false,
            reduceMotion: false,
            localHour: 12,
            currentHat: .none,
            currentTheme: .arcade
        )
    }

    static func testExtremeMiniHUDFormattingAndResourceBounds() {
        runTest("testExtremeMiniHUDFormattingAndResourceBounds") {
            let layout = CompactLayoutMetrics(
                gridW: 80, gridH: 20,
                modeTag: "SW", goLabel: "PAUSE", secLabel: "LAP"
            )
            let extreme = Fmt.sw(999_999 * 3600 + 3599.99)
            let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: extreme, maxWidth: layout.maxTimeWidth)
            assertTrue(style.totalWidth <= layout.maxTimeWidth, "Extreme stopwatch text must fit the protected width")
            if case .smallScale1(let renderedText, let reportedWidth) = style {
                assertEqual(PixelCanvas.smallWidth(renderedText), reportedWidth, "Fallback width metadata must equal the text actually rendered")
            }
            assertEqual(Fmt.sw(.infinity), "00:00.00")
            assertEqual(Fmt.tm(.nan), "00:00")
            assertEqual(Fmt.hm(.infinity), "00:00")
            assertEqual(Fmt.durationWords(.nan), "0m")

            assertEqual(TimeDuckView.clampAnimationDelta(-10), 0, "Backward wall-clock jumps must not reverse theatrical physics")
            assertEqual(TimeDuckView.clampAnimationDelta(10), 0.1, accuracy: 0.0001, "Wake/render catch-up must be capped")
            assertEqual(TimeDuckView.clampAnimationDelta(.nan), 0)

            let view = TimeDuckView(
                sw: StopwatchModel(), tm: TimerModel(), pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.spawnHearts(2_000)
            assertEqual(view.activeTemporaryParticleCount, 240, "Rapid input must be bounded before the next render tick")
            for index in 0..<100 {
                view.dropBreadcrumb(at: Double(20 + index % 40))
            }
            assertEqual(view.activeBreadcrumbCount, 32, "Rapid feeding must keep a bounded breadcrumb queue")
        }
    }

    static func testSimultaneousCompletionsCoalesceAudioButNotRecords() {
        runTest("testSimultaneousCompletionsCoalesceAudioButNotRecords") {
            let now = Date()
            let tm = TimerModel()
            let pomo = PomodoroModel()
            let stats = StatsTracker()
            let view = TimeDuckView(sw: StopwatchModel(), tm: tm, pomo: pomo, stats: stats)
            var alarmCount = 0
            view.onCompletionAlarm = { alarmCount += 1 }

            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: now.addingTimeInterval(-1))
            pomo.restoreState(
                phase: PomodoroPhase.work.rawValue, cycles: 0, remainingAtStop: 60,
                running: true, endWall: now.addingTimeInterval(-1), workDuration: 60
            )

            assertTrue(view.processTimeEvents(now))
            assertEqual(alarmCount, 1, "Simultaneous completions must produce one non-overlapping alarm fanfare")
            assertTrue(tm.completionRecorded)
            assertTrue(pomo.completionRecorded)
            assertEqual(stats.todayFocusSeconds, 120, "Both authoritative completions must still record their focus duration")
            assertEqual(stats.todayPomodoros, 1)

            assertFalse(view.processTimeEvents(now.addingTimeInterval(10)))
            assertEqual(alarmCount, 1, "Repeated status/frame pumps must not replay completion audio")
            assertEqual(stats.todayFocusSeconds, 120, "Repeated pumps must not duplicate stats")
        }
    }

    static func testClockAdjustmentUpperBoundsPreserveWallAnchorConsistency() {
        runTest("testClockAdjustmentUpperBoundsPreserveWallAnchorConsistency") {
            let maximum = 99 * 3600 + 3599.0
            let now = Date()

            let timer = TimerModel()
            timer.setDuration(maximum - 30)
            timer.toggle(now: now)
            timer.add(60)
            assertEqual(timer.duration, maximum, "Timer quick adjustments must honor the documented maximum")
            assertEqual(timer.remaining(at: now), maximum, accuracy: 0.001, "Timer endWall must move only by the capped delta")

            let pomo = PomodoroModel()
            pomo.setWorkDuration(maximum - 30)
            pomo.add(60)
            assertEqual(pomo.workDuration, maximum, "Pomodoro adjustments must honor the same bounded clock domain")
            assertEqual(pomo.remainingAtStop, maximum, "Paused Pomodoro duration and remaining must stay synchronized at the cap")

            pomo.toggle(now: now)
            pomo.add(60)
            assertEqual(pomo.workDuration, maximum)
            assertEqual(pomo.remaining(at: now), maximum, accuracy: 0.001, "Running Pomodoro endWall must not move beyond its capped duration")
        }
    }

    static func testPreviewCompletionStateIsIndependentFromRealClockCompletion() {
        runTest("testPreviewCompletionStateIsIndependentFromRealClockCompletion") {
            let now = Date()
            let timer = TimerModel()
            let stats = StatsTracker()
            timer.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: now.addingTimeInterval(-1))
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: timer, pomo: PomodoroModel(), stats: stats
            )
            view.currentMode = .timer
            view.isPreviewingStory = true
            view.previewProgress = 0.20

            let previewContext = view.getStoryContext()
            assertEqual(previewContext.normalizedProgress, 0.20, accuracy: 0.0001)
            assertFalse(previewContext.isFinished, "A completed real Timer must not force a partial QA preview into finale")

            _ = view.processTimeEvents(now)
            assertTrue(timer.completionRecorded, "Preview must not suppress authoritative real-clock completion")
            assertEqual(stats.todayFocusSeconds, 60, "Preview must not suppress real completion statistics")

            view.previewProgress = 1.0
            assertTrue(view.getStoryContext().isFinished, "A 100% preview must own its own synthetic completion state")
        }
    }

    static func testPomodoroBreakDurationAdjustmentsWhileFinished() {
        runTest("testPomodoroBreakDurationAdjustmentsWhileFinished") {
            let now = Date()
            let pomo = PomodoroModel()
            pomo.restoreState(
                phase: PomodoroPhase.shortBreak.rawValue,
                cycles: 1,
                remainingAtStop: 300,
                running: true,
                endWall: now.addingTimeInterval(-1),
                workDuration: 25 * 60,
                shortBreakDuration: 5 * 60,
                longBreakDuration: 15 * 60
            )

            assertTrue(pomo.finished, "Short break must be finished")
            pomo.setShortBreakDuration(10 * 60)
            assertFalse(pomo.isRunning, "Adjusting finished break duration must stop running anchor")
            assertEqual(pomo.shortBreakDuration, 10 * 60)
            assertEqual(pomo.remainingAtStop, 10 * 60)

            // Long break adjustment while finished
            pomo.restoreState(
                phase: PomodoroPhase.longBreak.rawValue,
                cycles: 4,
                remainingAtStop: 900,
                running: true,
                endWall: now.addingTimeInterval(-1),
                workDuration: 25 * 60,
                shortBreakDuration: 5 * 60,
                longBreakDuration: 15 * 60
            )
            assertTrue(pomo.finished, "Long break must be finished")
            pomo.setLongBreakDuration(20 * 60)
            assertFalse(pomo.isRunning, "Adjusting finished long break duration must stop running anchor")
            assertEqual(pomo.longBreakDuration, 20 * 60)
            assertEqual(pomo.remainingAtStop, 20 * 60)
        }
    }

    static func testThemeAndCostumeSelectionPreservedDuringStoryPreview() {
        runTest("testThemeAndCostumeSelectionPreservedDuringStoryPreview") {
            let originalTheme = ThemeRegistry.current
            defer { ThemeRegistry.current = originalTheme }

            ThemeRegistry.current = .synthwave
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: TimerModel(), pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.currentHat = .bandanaMidnight

            view.storyEngine.beginPreview(.theExpedition)
            view.isPreviewingStory = true
            view.previewProgress = 0.50

            // Context generated during preview should preserve active theme and costume
            let ctx = view.getStoryContext()
            assertEqual(ctx.currentTheme, .synthwave)
            assertEqual(ctx.currentHat, .bandanaMidnight)
            assertEqual(view.storyEngine.selectedStoryId, .theExpedition)

            ThemeRegistry.current = .amber
            view.currentHat = .wizard
            let ctx2 = view.getStoryContext()
            assertEqual(ctx2.currentTheme, .amber)
            assertEqual(ctx2.currentHat, .wizard)

            view.storyEngine.endPreview()
            view.isPreviewingStory = false
            assertEqual(ThemeRegistry.current, .amber, "Theme change during preview must remain in theme registry")
            assertEqual(view.currentHat, .wizard, "Costume change during preview must remain in view state")
        }
    }

    static func testStopwatchMiniHUDResetCancelsStoryAndRearmsFreshSession() {
        runTest("testStopwatchMiniHUDResetCancelsStoryAndRearmsFreshSession") {
            let sw = StopwatchModel()
            let view = TimeDuckView(
                sw: sw, tm: TimerModel(), pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.currentMode = .stopwatch
            view.storyEngine.setSelection(.theRescue)
            view.setMini(true)

            // Start stopwatch and story
            sw.start()
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            assertTrue(view.storyEngine.isSessionStarted)
            assertTrue(view.storyEngine.activeStory != nil)

            // Advance time and populate props/actors
            let stepDate = Date().addingTimeInterval(50)
            view.storyEngine.updateProgress(context: view.getStoryContext(), now: stepDate)
            view.storyEngine.tick(dt: 0.1, now: stepDate, context: view.getStoryContext())

            // Pause stopwatch
            sw.stop(now: stepDate)
            view.storyEngine.pauseSession(context: view.getStoryContext())
            assertTrue(sw.elapsed > 0)
            assertFalse(sw.isRunning)

            // MiniHUD RESET action
            view.resetStoryForClockReconfiguration()
            sw.reset()

            // Verify story is completely cleaned and ready for a fresh session
            assertFalse(view.storyEngine.isSessionStarted, "MiniHUD reset must terminate story session")
            assertFalse(view.storyEngine.isPrepared, "MiniHUD reset must unprepare story session")
            assertNil(view.storyEngine.activeStory, "MiniHUD reset must release active story instance")
            assertTrue(view.storyEngine.actors.isEmpty, "MiniHUD reset must clean all actors")
            assertTrue(view.storyEngine.props.isEmpty, "MiniHUD reset must clean all props")

            // Re-start stopwatch -> must instantiate a brand new story session from beginning
            sw.start()
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            assertTrue(view.storyEngine.isSessionStarted)
            assertEqual(view.storyEngine.currentMilestoneIndex, 0, "Fresh session must start at milestone 0")
        }
    }

    static func testTimerDoneActionClearsFinaleAndRearmsStoppedClock() {
        runTest("testTimerDoneActionClearsFinaleAndRearmsStoppedClock") {
            let tm = TimerModel()
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: tm, pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.currentMode = .timer
            view.storyEngine.setSelection(.theExpedition)

            // Put timer into completed state with active finale
            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: Date().addingTimeInterval(-5))
            assertTrue(tm.finished)
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            view.storyEngine.enterFinale(context: view.getStoryContext())
            assertTrue(view.storyEngine.isFinaleActive)

            // User triggers DONE action (clearing finished timer)
            view.dismissAlarm()
            view.resetStoryForClockReconfiguration()
            tm.restart()

            // Verify finale is cleared, clock is configured and stopped
            assertFalse(view.storyEngine.isFinaleActive, "DONE action must clear finale")
            assertFalse(view.storyEngine.isSessionStarted, "DONE action must reset story session")
            assertNil(view.storyEngine.activeStory, "DONE action must release active story")
            assertFalse(tm.isRunning, "Cleared timer must be stopped")
            assertEqual(tm.duration, 60)
            assertEqual(tm.remainingAtStop, 60)

            // Starting timer again starts a fresh story session
            tm.toggle()
            assertTrue(tm.isRunning)
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            assertTrue(view.storyEngine.isSessionStarted)
            assertFalse(view.storyEngine.isFinaleActive)
        }
    }

    static func testTimerPresetClearsFinishedFinaleAndReconfiguresClock() {
        runTest("testTimerPresetClearsFinishedFinaleAndReconfiguresClock") {
            let tm = TimerModel()
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: tm, pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.currentMode = .timer
            view.storyEngine.setSelection(.theFeast)

            // Put timer in finale
            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: Date().addingTimeInterval(-1))
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            view.storyEngine.enterFinale(context: view.getStoryContext())
            assertTrue(view.storyEngine.isFinaleActive)

            // Select 5M preset
            view.resetStoryForClockReconfiguration()
            tm.setDuration(300)

            assertFalse(view.storyEngine.isFinaleActive, "Preset selection must clear active finale")
            assertNil(view.storyEngine.activeStory)
            assertEqual(tm.duration, 300)
            assertEqual(tm.remainingAtStop, 300)
            assertFalse(tm.isRunning)
        }
    }

    static func testPomodoroPresetClearsFinishedFinaleAndReconfiguresDuration() {
        runTest("testPomodoroPresetClearsFinishedFinaleAndReconfiguresDuration") {
            let pomo = PomodoroModel()
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: TimerModel(), pomo: pomo, stats: StatsTracker()
            )
            view.currentMode = .pomodoro
            view.storyEngine.setSelection(.theWod)

            // Put pomodoro in finale
            pomo.restoreState(phase: 0, cycles: 1, remainingAtStop: 1500, running: true, endWall: Date().addingTimeInterval(-1))
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            view.storyEngine.enterFinale(context: view.getStoryContext())
            assertTrue(view.storyEngine.isFinaleActive)

            // Select 50M pomo preset
            view.resetStoryForClockReconfiguration()
            pomo.setWorkDuration(50 * 60)

            assertFalse(view.storyEngine.isFinaleActive, "Pomo preset must clear finale")
            assertNil(view.storyEngine.activeStory)
            assertEqual(pomo.workDuration, 50 * 60)
            assertEqual(pomo.remainingAtStop, 50 * 60)
            assertFalse(pomo.isRunning)
        }
    }

    static func testDirectTimeEntryClearsFinishedFinaleAndReconfiguresDuration() {
        runTest("testDirectTimeEntryClearsFinishedFinaleAndReconfiguresDuration") {
            let tm = TimerModel()
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: tm, pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.currentMode = .timer
            view.storyEngine.setSelection(.nightShift)

            // Finished finale
            tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: Date().addingTimeInterval(-1))
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            view.storyEngine.enterFinale(context: view.getStoryContext())
            assertTrue(view.storyEngine.isFinaleActive)

            // Direct edit
            view.beginTimeEdit()
            view.editBuffer = "10:00"
            let ok = view.commitTimeEdit()
            assertTrue(ok)

            assertFalse(view.storyEngine.isFinaleActive, "Direct time commit must clear finale")
            assertNil(view.storyEngine.activeStory)
            assertEqual(tm.duration, 600)
            assertEqual(tm.remainingAtStop, 600)
            assertFalse(tm.isRunning)
        }
    }

    static func testViewportTransitionClearsAllCoordinateOwnedEffects() {
        runTest("testViewportTransitionClearsAllCoordinateOwnedEffects") {
            let view = TimeDuckView(
                sw: StopwatchModel(), tm: TimerModel(), pomo: PomodoroModel(), stats: StatsTracker()
            )
            view.setMini(false)

            // Populate effects in Full Mode (crumbs, snores, particles, speech)
            view.dropBreadcrumb(at: 40)
            view.dropBreadcrumb(at: 80)
            view.spawnConfetti(20)
            view.speak("QUACK IN FULL MODE", duration: 5.0)
            assertTrue(view.activeBreadcrumbCount > 0, "Full mode must have breadcrumbs")
            assertTrue(view.activeTemporaryParticleCount > 0, "Full mode must have particles")

            // Switch to MiniHUD
            view.setMini(true)
            assertEqual(view.activeBreadcrumbCount, 0, "Switching to MiniHUD must clear viewport-owned breadcrumbs")
            assertEqual(view.activeTemporaryParticleCount, 0, "Switching to MiniHUD must clear viewport-owned particles")
            assertEqual(view.activeSnoreParticleCount, 0, "Switching to MiniHUD must clear viewport-owned snores")

            // Populate effects in MiniHUD
            view.dropBreadcrumb(at: 30)
            view.spawnConfetti(10)
            view.speak("QUACK IN MINI MODE", duration: 5.0)
            assertTrue(view.activeBreadcrumbCount > 0, "Mini mode must have breadcrumbs")
            assertTrue(view.activeTemporaryParticleCount > 0, "Mini mode must have particles")

            // Switch back to Full Mode
            view.setMini(false)
            assertEqual(view.activeBreadcrumbCount, 0, "Switching to Full Mode must clear MiniHUD breadcrumbs (no leak into clock band)")
            assertEqual(view.activeTemporaryParticleCount, 0, "Switching to Full Mode must clear MiniHUD particles")
            assertEqual(view.activeSnoreParticleCount, 0, "Switching to Full Mode must clear snores")
        }
    }

    static func testTimerRestoreRunningClockValidRemaining() {
        runTest("testTimerRestoreRunningClockValidRemaining") {
            let tm = TimerModel()
            let now = Date()
            let duration: TimeInterval = 25 * 60 // 25 min
            let endWall = now.addingTimeInterval(20 * 60) // 20 min remaining

            tm.restoreState(
                duration: duration,
                remainingAtStop: duration,
                running: true,
                endWall: endWall,
                completionRecorded: false,
                now: now
            )

            assertTrue(tm.isRunning, "Restored timer must be running")
            assertEqual(tm.duration, 25 * 60)
            assertEqual(tm.remaining(at: now), 20 * 60, accuracy: 0.1, "Remaining time must be ~20 minutes")
            assertFalse(tm.finished)
        }
    }

    static func testTimerRestoreRunningClockExcessiveFutureClampedToDuration() {
        runTest("testTimerRestoreRunningClockExcessiveFutureClampedToDuration") {
            let tm = TimerModel()
            let now = Date()
            let duration: TimeInterval = 60 // 60 seconds
            let excessiveEndWall = now.addingTimeInterval(315_360_000) // 10 years in future

            tm.restoreState(
                duration: duration,
                remainingAtStop: duration,
                running: true,
                endWall: excessiveEndWall,
                completionRecorded: false,
                now: now
            )

            assertTrue(tm.isRunning)
            assertEqual(tm.duration, 60)
            assertEqual(tm.remaining(at: now), 60, accuracy: 0.001, "Remaining time must be clamped to configured duration (60s)")
        }
    }

    static func testTimerRestoreRunningClockMaxDurationBoundary() {
        runTest("testTimerRestoreRunningClockMaxDurationBoundary") {
            let tm = TimerModel()
            let now = Date()
            let maxDuration: TimeInterval = 99 * 3600 + 3599
            let farEndWall = now.addingTimeInterval(500_000) // Beyond max duration

            tm.restoreState(
                duration: maxDuration,
                remainingAtStop: maxDuration,
                running: true,
                endWall: farEndWall,
                completionRecorded: false,
                now: now
            )

            assertTrue(tm.isRunning)
            assertEqual(tm.duration, maxDuration)
            assertEqual(tm.remaining(at: now), maxDuration, accuracy: 0.001, "Remaining time must not exceed maximum supported domain")
        }
    }

    static func testTimerRestoreRunningClockPastEndWall() {
        runTest("testTimerRestoreRunningClockPastEndWall") {
            let tm = TimerModel()
            let now = Date()
            let duration: TimeInterval = 60
            let pastEndWall = now.addingTimeInterval(-10) // 10 seconds ago

            tm.restoreState(
                duration: duration,
                remainingAtStop: duration,
                running: true,
                endWall: pastEndWall,
                completionRecorded: false,
                now: now
            )

            assertTrue(tm.isRunning)
            assertTrue(tm.isFinished(at: now), "Past endWall must evaluate to finished")
            assertEqual(tm.remaining(at: now), 0, accuracy: 0.001)
        }
    }

    static func testPomodoroRestoreRunningClockExcessiveFutureClampedToDuration() {
        runTest("testPomodoroRestoreRunningClockExcessiveFutureClampedToDuration") {
            let pomo = PomodoroModel()
            let now = Date()
            let workDuration: TimeInterval = 25 * 60
            let excessiveEndWall = now.addingTimeInterval(1_000_000_000) // 30+ years in future

            pomo.restoreState(
                phase: PomodoroPhase.work.rawValue,
                cycles: 2,
                remainingAtStop: workDuration,
                running: true,
                endWall: excessiveEndWall,
                workDuration: workDuration,
                shortBreakDuration: 5 * 60,
                longBreakDuration: 15 * 60,
                completionRecorded: false,
                now: now
            )

            assertTrue(pomo.isRunning)
            assertEqual(pomo.workDuration, 25 * 60)
            assertEqual(pomo.remaining(at: now), 25 * 60, accuracy: 0.001, "Remaining Pomodoro work time must be clamped to current work duration")
        }
    }

    static func testVisiblePlusOneMinActionOnFinishedTimerCancelsStoryFinaleAndReconfiguresClock() {
        runTest("testVisiblePlusOneMinActionOnFinishedTimerCancelsStoryFinaleAndReconfiguresClock") {
            let app = AppDelegate()
            let view = TimeDuckView(sw: app.sw, tm: app.tm, pomo: app.pomo, stats: app.stats)
            view.snd = app.snd
            app.view = view
            app.currentMode = .timer
            view.currentMode = .timer
            view.storyEngine.setSelection(.theExpedition)

            // 1. Timer finishes and active story enters finale
            app.tm.restoreState(duration: 60, remainingAtStop: 60, running: true, endWall: Date().addingTimeInterval(-2))
            assertTrue(app.tm.finished)
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            view.storyEngine.enterFinale(context: view.getStoryContext())
            assertTrue(view.storyEngine.isFinaleActive, "Finale must be active after timer completion")

            // 2. Invoke the EXACT command/action handler corresponding to visible "+1 MIN / L" action (sec button)
            app.secondaryAction()

            // 3. Assertions
            assertFalse(app.tm.finished, "Timer must no longer be finished")
            assertFalse(app.tm.isRunning, "Timer must be stopped in configured state")
            assertEqual(app.tm.duration, 120, "Timer duration must be incremented by 60s")
            assertEqual(app.tm.remainingAtStop, 120, "Timer remaining must match duration")
            assertFalse(view.storyEngine.isFinaleActive, "Old story finale must be cancelled")
            assertFalse(view.storyEngine.isSessionStarted, "Old story session must be terminated")
            assertNil(view.storyEngine.activeStory, "Old story instance must be released")
            assertTrue(view.storyEngine.actors.isEmpty, "All actors must be cleared")
            assertTrue(view.storyEngine.props.isEmpty, "All props must be cleared")

            // 4. Invoke START through the normal command path (primaryAction)
            app.primaryAction()

            // 5. Assert a fresh story lifecycle/session begins
            assertTrue(app.tm.isRunning, "Timer must be running")
            assertTrue(view.storyEngine.isSessionStarted, "Fresh story session must be started")
            assertFalse(view.storyEngine.isFinaleActive, "Fresh story session cannot be in finale")
            assertEqual(view.storyEngine.currentMilestoneIndex, 0, "Fresh session must start at milestone 0")
        }
    }

    static func testVisiblePlusOneMinActionOnRunningTimerPreservesActiveStorySession() {
        runTest("testVisiblePlusOneMinActionOnRunningTimerPreservesActiveStorySession") {
            let app = AppDelegate()
            let view = TimeDuckView(sw: app.sw, tm: app.tm, pomo: app.pomo, stats: app.stats)
            view.snd = app.snd
            app.view = view
            app.currentMode = .timer
            view.currentMode = .timer
            view.storyEngine.setSelection(.theExpedition)

            // 1. Start a running timer session with active story
            app.tm.setDuration(300)
            app.tm.restart(autoStart: true)
            assertTrue(app.tm.isRunning)
            view.storyEngine.prepareSession(context: view.getStoryContext())
            view.storyEngine.startSession(context: view.getStoryContext())
            assertTrue(view.storyEngine.isSessionStarted)
            let initialStory = view.storyEngine.activeStory
            assertTrue(initialStory != nil)

            // 2. Invoke visible "+1 MIN / L" action (sec button) while timer is RUNNING
            app.secondaryAction()

            // 3. Assertions
            assertTrue(app.tm.isRunning, "Running timer must remain running")
            assertEqual(app.tm.duration, 360, "Running timer duration must increase by 60s")
            assertTrue(view.storyEngine.isSessionStarted, "Active story session must remain started")
            assertFalse(view.storyEngine.isFinaleActive, "Story must not enter finale")
            assertTrue(view.storyEngine.activeStory === initialStory, "Active story instance must be preserved uninterrupted")
        }
    }
}



