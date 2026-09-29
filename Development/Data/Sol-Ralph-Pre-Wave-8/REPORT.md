# Sol Ralph Pre-Wave-8 Foundation Audit

Audit date: 2026-08-27  
Scope: `/Users/homebase/Documents/TimeDuck-DuckDrops` only  
Audited branch/commit: `duckdrops-dev` at `bd6dcae9`  
Release firewall: no commit, push, merge, tag, release, Homebrew change, public-worktree change, Wave 8 work, companion work, or achievement work was performed.

## 1. BASELINE

- Branch: `duckdrops-dev`.
- Starting commit: `bd6dcae9` (`bd6dcae9f...`).
- Starting status: the development worktree was already dirty with the unreleased Wave 5–7.2 line. Modified tracked files included DuckDrops documentation, the runner/build script, AppDelegate/MenuManager/Persistence/SoundEngine, DuckBrain/Formatting/TimerEngine, accessory/compact/sprite/view code, and DuckBrain tests. Untracked content included the Wave 5, 6, 7, 7.2 and Animation Director reports/tests plus `DuckStoryEngine.swift`. Those user/Gemini changes were preserved.
- Original independently observed test result: **146 / 146 PASSED**, 0 failed, 0.145 seconds.
- Original clean app build: succeeded, no compiler warnings emitted. Arm64 Mach-O executable: 1,076,840 bytes (1,052 KiB on disk); app bundle: 1,856 KiB on disk; ad-hoc signed.
- Public worktree baseline: `/Users/homebase/Documents/TimeDuck` was clean at `57832771f930227f398ced0259392aed15800ceb`.

## 2. ARCHITECTURE MAP

- Clocks: `StopwatchModel`, `TimerModel`, and `PomodoroModel` own authoritative wall-clock anchors, stopped values, phase state, and completion-recorded flags. Animation delta never advances authoritative time.
- Coordination: `AppDelegate` owns all clocks, `StatsTracker`, `SoundEngine`, `TimeDuckView`, current mode, frame/status timers, commands, persistence, and app/window lifecycle.
- View state: `TimeDuckView` observes clocks, renders full/MiniHUD modes, runs DuckBrain/story theatrical updates, and independently services both countdown completions through `processTimeEvents` even when a mode or window is hidden.
- Duck state: `DuckBrain` owns behavior phase, temporary poses, feeding/poke history, Chonky state, rare moments, and phrase selection.
- Stories: `DuckStoryEngine` owns selection, session lifecycle, milestones, active story, actors, props, performance override, finale coordinator, and isolated preview snapshots. Stories receive read-only clock context.
- Animation/effects: `TimeDuckView` owns frame delta, breadcrumbs, general particles, snore particles, speech/toast/hop/flap state, and clipping. Story actors/props are identifier-deduplicated in `DuckStoryEngine`.
- Audio: `SoundEngine` owns one persistent `AVAudioEngine`/player node, cached procedural buffers, soundtrack player, mute guards, and one-shot scheduling.
- Persistence: `Store` snapshots clock/stats/presentation state to atomic JSON on one serial queue. `AppDelegate` restores through model validation APIs.
- MiniHUD: `CompactLayout` defines protected clock/control/stage geometry; `TimeDuckView` fits actual display strings and clips stage effects.
- Preview tooling: `AppDelegate` creates synthetic contexts; `DuckStoryEngine.beginPreview/endPreview` substitutes a fresh story instance and restores the live session snapshot. Preview has no stats, persistence, or completion authority.

## 3. DEFECTS FOUND

### SR-001 — High — Story lifecycle cancellation/resurrection

- Reproduction: cancel a progressed story, then allow the normal view update/tick; actors/props and the old story could return. Auto selection could also retain an old mode's story.
- Root cause: cancellation cleared presentation arrays but retained prepared/active ownership, and update paths did not require a started session.
- Fix: explicit prepared/started/paused lifecycle gates; cancellation invalidates preparation and releases the active story; new sessions re-resolve selection.
- Regression: `testCancelledStoryCannotResurrect`, `testAutoStoryReResolvesAfterModeChange`, `testStoryPauseResumePreservesScene`.

### SR-002 — High — Finale one-shot not rearmed

- Reproduction: complete a story finale, immediately start a new session of the same story, and complete again; the new payoff could remain suppressed.
- Root cause: the reused story instance retained its private finale one-shot state.
- Fix: a post-finale start prepares a fresh story session and clears finale ownership.
- Regression: `testFinaleOneShotRearmsForNewSession`.

### SR-003 — High — Paused Pomodoro duration divergence

- Reproduction: pause a Pomodoro phase, adjust its time, resume; remaining time and configured phase duration disagreed.
- Root cause: the paused adjustment changed remaining time without symmetrically changing the phase duration.
- Fix: apply the same bounded delta to both values.
- Regression: `testPomodoroPausedAdjustmentKeepsDurationConsistent`.

### SR-004 — High — Cross-mode alarm ownership collision

- Reproduction: Timer and Pomodoro complete independently, dismiss one mode's alarm, switch modes, then attempt the next-phase action.
- Root cause: one global dismissal bit represented two independent completed clocks.
- Fix: independent Timer and Pomodoro dismissal state with a current-mode projection.
- Regression: `testIndependentCompletedModeAlarmOwnership`.

### SR-005 — Medium — MiniHUD finale clock frozen

- Reproduction: enter a story finale in MiniHUD; finale rendering read `finaleElapsedTime`, but it never advanced.
- Root cause: private story finale loops advanced while the coordinator clock was left at zero.
- Fix: advance the coordinator finale clock in the bounded theatrical tick.
- Regression: `testEngineFinaleClockAdvancesAndRemainsBounded` simulates six hours for every story.

### SR-006 — Medium — WOD frame-level audio/particle spam

- Reproduction: run WOD cadence at 60 FPS; a beat window emitted repeated gym ticks and excessive sweat.
- Root cause: time-window conditions were evaluated every frame rather than on beat edges; the sweat callback was also unwired.
- Fix: edge-trigger cadence state, reset it per scene/session, and wire sweat emission through the bounded view particle owner.
- Regression: `testWodCadenceEventsAreEdgeTriggered`.

### SR-007 — High — Quick-start and phase-skip story bypass

- Reproduction: use quick Timer/Pomodoro starts or skip a Pomodoro phase while a story/finale is active.
- Root cause: command bridges mutated clocks without applying the story lifecycle transition.
- Fix: quick starts begin the appropriate story; next phases start a fresh session; skip cancels the old story first.
- Regression: lifecycle, cancellation, and mode-operation fuzz coverage.

### SR-008 — High — Developer preview mutated live/user story state

- Reproduction: enter preview during a live story, change preview milestone/finale, clear preview; the same engine/story instance and persisted selection had been mutated.
- Root cause: preview called the normal persistent selection path and reused live theatrical ownership.
- Fix: snapshot the live coordinator, instantiate a preview-only story, avoid UserDefaults writes, restore the exact live snapshot, and clear preview effects on exit.
- Regression: `testDeveloperPreviewRestoresLiveStoryAndUserSelection`.

### SR-009 — High — Stale debounced save could overwrite termination state

- Reproduction: schedule a debounced snapshot, then perform an immediate final save; the queued stale work item could write after the final snapshot.
- Root cause: cancellation and immediate write were not ordered on the same queue.
- Fix: serialize cancel, immediate save, and debounced save ownership on one queue, including safe same-queue synchronization.
- Regression: `testImmediatePersistenceCannotBeOverwrittenByStaleDebounce`.

### SR-010 — Medium — Persisted invalid state accepted into runtime

- Reproduction: restore corrupt-but-decodable negative/non-finite/non-monotonic clock, lap, statistic, date, enum, or duration values.
- Root cause: the coordinator assigned several decoded fields directly and models incompletely sanitized restore data.
- Fix: model-level finite/range validation, lap monotonicity checks, valid date handling, safe enum fallbacks, and stats restore API.
- Regression: `testPersistenceBackwardCompatibilityAndRestoreSanitization`.

### SR-011 — Medium — Temporary effect ownership leaked across transitions

- Reproduction: sleep then wake via keyboard/menu, reset, change mode, toggle MiniHUD, or leave preview; snores, breadcrumbs, speech, or particles could survive their owner.
- Root cause: cleanup was tied to selected pointer-input paths rather than lifecycle transitions.
- Fix: centralized `clearTemporaryEffects`, explicit wake cleanup, bounded snore emission, mode/viewport clipping, and lifecycle calls from reset/mode/preview actions.
- Regression: `testSleepAndTemporaryEffectOwnershipAcrossWakePaths`.

### SR-012 — High — Completed clock could resurrect and double-record

- Reproduction: complete and record a Timer/Pomodoro, then adjust duration/preset before reset; the expired wall anchor remained while completion protection was cleared.
- Root cause: adjustment APIs treated an expired running anchor like a live session.
- Fix: finished adjustments stop the expired session and configure a new stopped session before clearing completion state.
- Regression: `testCompletedClockAdjustmentCannotResurrectOrDoubleRecord`.

### SR-013 — Medium — Extreme MiniHUD value and resource-bound failures

- Reproduction: render extreme Stopwatch/non-finite values; the fallback reported a fitted width but returned the unbounded original text. Particles/breadcrumbs also lacked insertion-time guarantees.
- Root cause: geometry and displayed text were computed separately; formatting assumed finite values.
- Fix: return the actual fitted string, make formatters finite-safe, cap Stopwatch display domain, and cap particle/breadcrumb arrays at ownership boundaries.
- Regression: `testExtremeMiniHUDFormattingAndResourceBounds`.

### SR-014 — Medium — Simultaneous completions doubled alarm audio

- Reproduction: Timer and Pomodoro expire on the same event-service tick.
- Root cause: each completion path invoked its own fanfare.
- Fix: record both clocks/stats independently but coalesce alarm playback once per service pass.
- Regression: `testSimultaneousCompletionsCoalesceAudioButNotRecords`.

### SR-015 — Medium — Repeated adjustments bypassed clock maximums

- Reproduction: repeatedly add time while running/paused/restored; duration and end-wall deltas could diverge beyond the supported 99:59:59 domain.
- Root cause: setters clamped values, but adjustment/restore paths did not consistently clamp the applied delta.
- Fix: one maximum per model and clamped applied deltas/end anchors in every path.
- Regression: `testClockAdjustmentUpperBoundsPreserveWallAnchorConsistency`.

### SR-016 — Medium — Preview inherited real completion

- Reproduction: leave a real clock completed, then preview a story at 20%; the preview entered finale immediately.
- Root cause: synthetic preview progress was combined with the real clock's `isFinished` bit.
- Fix: preview completion derives only from synthetic preview progress.
- Regression: `testPreviewCompletionStateIsIndependentFromRealClockCompletion`.

### SR-017 — High — Hostile persisted counters could overflow

- Reproduction: decode `Int.max` for cycles, Pomodoro count, or streak, then advance/render/record.
- Root cause: decoding succeeded and later `+ 1` / `cycles + 1` arithmetic could trap.
- Fix: generous restore limits and safe saturating/wrapping increments that preserve Pomodoro phase cadence.
- Regression: `testHostilePersistedCountersCannotOverflowRuntime`.

### SR-018 — Low — Paused stories pinned 60 FPS

- Reproduction: pause a story with actors still visible.
- Root cause: high-rate animation was requested by actor existence, even though the paused story tick was correctly frozen.
- Fix: high-rate ownership now follows started/paused/finale lifecycle.
- Regression: `testPausedStoryDoesNotDemandHighRateAnimation`.

### SR-019 — Medium — Stopwatch stopped-time and lap history unbounded

- Reproduction: stop after an extreme elapsed interval or generate/restore thousands of laps.
- Root cause: the stopped elapsed path returned raw banked time, and lap arrays had no bound.
- Fix: cap banked/running/stopped elapsed consistently and bound live/restored lap history to 1,000 entries.
- Regression: `testStopwatchBoundsElapsedAndLapHistory`.

### SR-020 — Low — Rapid FEED history unbounded between frames

- Reproduction: invoke FEED thousands of times before DuckBrain's next update.
- Root cause: timestamp pruning occurred only in update, not at insertion.
- Fix: retain a bounded recent feeding window while preserving the Chonky threshold.
- Regression: `testRapidFeedHistoryRemainsBounded`.

## 4. TEST-QUALITY FINDINGS

- The original 146-test green baseline did not compile `TimeDuckView.swift` into the test runner. The build script now includes the real view and story engine, enabling lifecycle/MiniHUD/effect tests against runtime code.
- `testSleepFXClearSleepFXPurgesParticlesInstantly` only exercised bill anchors; it did not create a view, spawn snores, or call `clearSleepFX`.
- `testWave7AuthoritativeTimerIsolationAndPreviewIndependence` advanced a local `Double`; it did not invoke preview, a clock, the story engine, or the view.
- `testWave6StoryCleanupContract` asserted arrays but did not prove that active/prepared ownership was invalidated or that a later tick could not resurrect state.
- `testWave5ProceduralAudioGenerators` ends in unconditional `assertTrue(true)` after fire-and-forget calls. It is a smoke test, not behavioral proof.
- Tests are manually registered through `runAll`; omitted files can silently disappear. The audit suite is explicitly registered and the test build compiles every file under `Tests/TimeDuckTests`.
- No existing assertion was weakened and no test was disabled.

## 5. TIMER / POMO / STOPWATCH FINDINGS

- Wall-clock anchors remain authoritative and animation/preview speed cannot change them.
- Completion servicing is mode-independent and idempotent; simultaneous clocks record independently and play one alarm.
- Timer/Pomodoro adjustment, completion, restart, pause/resume, maximum-duration, and stale-alarm transitions were hardened.
- Stopwatch running/stopped values and lap history are bounded; lap splits restored from disk must be finite and monotonic.
- Deterministic mixed-operation fuzz preserved non-negative remaining times, bounded durations, valid phase state, and no completion resurrection.

## 6. STORY ENGINE FINDINGS

- All five stories were exercised at every milestone boundary using `boundary - 0.000001`, exact boundary, and `boundary + 0.000001`.
- Cancellation, mode change, pause/resume, new session, preview, and finale ownership are explicit.
- Actors and props use identifier replacement rather than blind accumulation.
- No unreachable registered story or impossible milestone transition was reproduced after fixes.

## 7. FINALE FINDINGS

- Active scene to completion to finale entry is guarded and enters once.
- One-shot payoff re-arms for a new session and is not replayed by the loop.
- Every finale was simulated for six theatrical hours; coordinator time advanced and actor/prop arrays remained bounded.
- Reset, mode change, new session, and preview exit clear or restore finale ownership.
- No recursive finale restart, audio replay loop, or unbounded finale collection was reproduced after fixes.

## 8. SCENE TRANSITION FINDINGS

- All 25 handoffs (four inter-scene plus scene-five-to-finale for each of five stories) received structural boundary coverage.
- Tests assert valid scene advancement, bounded actors/props, and continuity-oriented transition frames immediately around every threshold.
- No repeated cleanup/re-add growth, missing active story, or frame-zero state reset was reproduced after lifecycle fixes.
- Pixel-perfect subjective continuity still requires human visual inspection; the gate standard used here is plausible structural continuity, not invented interpolation.

## 9. SLEEP / PARTICLE FINDINGS

- Bill anchors were verified for normal, flipped, sleeping, and representative sprite forms; MiniHUD/full rendering clips snores to their owner viewport.
- Snore count is bounded at three and clears on explicit wake/input, reset, mode change, MiniHUD transitions, and preview cleanup.
- General particles are capped at 240, breadcrumbs at 32, feeding history at 32, and story actors/props are ID-deduplicated.
- WOD sweat is now wired through the bounded particle owner; cadence events are edge-triggered.

## 10. MINIHUD FINDINGS

- Clock, controls, state zone, and theatrical stage remain geometrically separated across tested widths/modes.
- Extreme values now fit the actual rendered string; non-finite values cannot generate enormous or lying layout widths.
- Story props/dialogue/actors/particles/snores are clipped to the stage, preserving timer hierarchy.
- Repeated compact/full transitions clear coordinate-owned temporary effects.
- No redesign or aesthetic change was introduced by this audit.

## 11. LIVING WARDROBE FINDINGS

- Existing all-hat attachment coverage spans legacy, Wave 5, Wave 6, transition, Chonky, action, and flipped poses.
- Skull/bill anchor and mirror math remained valid in the representative structural suite.
- No reproducible detached accessory, invalid fallback, or z-order regression was found in the stopping pass.
- Visual judgment on every pixel pose remains a manual QA risk noted below.

## 12. AUDIO FINDINGS

- Completion audio is coalesced per service tick; WOD cadence audio is edge-triggered.
- Delayed procedural notes re-check SFX enablement before playback; soundtrack operations obey the independent music preference.
- Story cues are routed through bounded one-shot story lifecycle paths.
- Missing soundtrack assets fall back or fail silently; debug diagnostics are compiled only under `DEBUG`.
- The sole `fatalError` is the impossible failure to create a standard mono AVAudioFormat during SoundEngine construction; it was judged not a reachable asset/runtime-input crash.

## 13. PERSISTENCE FINDINGS

- State writes use atomic `Data.write` and are ordered on one serial save queue.
- Immediate termination saves cancel and supersede stale debounced snapshots.
- Corrupt/truncated/empty JSON safely returns defaults through the existing load failure path.
- Missing new optional keys and unknown future fields decode compatibly; unknown raw enums fall back in the coordinator/model.
- Current schema was compared with the public `5783277` persistence schema; required v1 fields remain compatible and newer fields are optional.
- Negative, non-finite, impossible, and overflow-sized model/stat values are sanitized before runtime use.

## 14. APP LIFECYCLE FINDINGS

- Hidden windows run zero display FPS while the one-second status timer continues completion servicing.
- Frame/status timers are invalidated on termination and frame closures capture the coordinator weakly.
- Theatrical delta is clamped to 0...0.1 seconds to prevent wake/catch-up explosions; wall-clock authority is not clamped.
- Story pause/reset/mode/preview transitions now share explicit cleanup rules.
- No timer resurrection or duplicate completion was reproduced across hide/service and repeated-operation tests.

## 15. PERFORMANCE FINDINGS

- Measured final test runtime: 0.280 seconds for 169 tests on this host.
- Final optimized arm64 executable: 1,102,344 bytes (1,080 KiB on disk). Final app bundle: 1,880 KiB on disk.
- Hidden display pump: 0 FPS by code; visible paused stories no longer force 60 FPS.
- Bounded runtime collections: laps 1,000; general particles 240; breadcrumbs 32; feed timestamps 32; snores 3; phrase history uses its existing fixed cap; story actors/props are ID-deduplicated.
- No Instruments allocation/energy run was performed, so no unsupported CPU, memory, or battery percentage claim is made.

## 16. DEVELOPER TOOLING FINDINGS

- Preview, Transition QA, and Finale QA use synthetic progress and a fresh story instance.
- Preview cannot mutate authoritative clocks, stats, completion flags, Pomodoro counts, persisted story selection, or Store state through its engine paths.
- Leaving preview restores the live story/coordinator snapshot and destroys preview-owned temporary effects.
- Developer menus remain present in this unreleased development build. Compile-time exclusion from a future release remains a release-configuration decision, not a Wave 8 feature.

## 17. FUZZ / ADVERSARIAL RESULTS

- `testDeterministicClockAndStoryOperationFuzz`: 5,000 fixed-seed (`0x54494D454455434B`) mixed operations across Timer, Stopwatch, Pomodoro, stories, preview, start/pause/reset/adjust/phase/mode transitions.
- Invariants checked after each operation include non-negative clocks, supported maximums, valid phase/mode/story state, bounded collections, no cancelled-story resurrection, and preview restoration.
- All five stories were tested at 30 milestone-neighborhood points (six thresholds including start, at exact/adjacent values where applicable) plus six-hour finales.
- Additional chaos tests exercised 1,100 live laps, 1,500 restored laps, 10,000 rapid feeds, simultaneous completions, extreme persisted integers, and repeated temporary FX creation/cleanup.
- Final result: no reproducible invariant failure after the last fixes.

## 18. FALSE POSITIVES / REJECTED CONCERNS

- Story animation speed and preview speed do not touch authoritative wall-clock anchors.
- Two completion service callers (frame pump and status timer) are intentional; model completion flags make the operation idempotent.
- Debug `print` calls are behind `#if DEBUG` and are not production console spam.
- The AVAudioFormat construction `fatalError` is not controlled by an asset, persisted value, or user operation.
- `git diff --check` reports trailing whitespace/EOF blanks in pre-existing dirty files (`IDEAS.md`, `README.md`, `Sprites.swift`). They predated this audit and were not mechanically rewritten.
- No networking, analytics, telemetry, account, or tracking dependency/import/call was found.

## 19. COMPLETE TEST RESULT

**169 / 169 PASSED** in 0.280 seconds; 0 failed.

New pre-Wave-8 regression tests:

1. `testCancelledStoryCannotResurrect`
2. `testAutoStoryReResolvesAfterModeChange`
3. `testStoryPauseResumePreservesScene`
4. `testFinaleOneShotRearmsForNewSession`
5. `testPomodoroPausedAdjustmentKeepsDurationConsistent`
6. `testIndependentCompletedModeAlarmOwnership`
7. `testEngineFinaleClockAdvancesAndRemainsBounded`
8. `testWodCadenceEventsAreEdgeTriggered`
9. `testAllStoryMilestoneBoundaries`
10. `testDeveloperPreviewRestoresLiveStoryAndUserSelection`
11. `testImmediatePersistenceCannotBeOverwrittenByStaleDebounce`
12. `testPersistenceBackwardCompatibilityAndRestoreSanitization`
13. `testHostilePersistedCountersCannotOverflowRuntime`
14. `testStopwatchBoundsElapsedAndLapHistory`
15. `testRapidFeedHistoryRemainsBounded`
16. `testPausedStoryDoesNotDemandHighRateAnimation`
17. `testSleepAndTemporaryEffectOwnershipAcrossWakePaths`
18. `testCompletedClockAdjustmentCannotResurrectOrDoubleRecord`
19. `testDeterministicClockAndStoryOperationFuzz`
20. `testExtremeMiniHUDFormattingAndResourceBounds`
21. `testSimultaneousCompletionsCoalesceAudioButNotRecords`
22. `testClockAdjustmentUpperBoundsPreserveWallAnchorConsistency`
23. `testPreviewCompletionStateIsIndependentFromRealClockCompletion`

## 20. BUILD RESULT

- Final command: `./build.sh --clean && ./build.sh --app`.
- Result: success.
- Compiler warnings emitted: 0.
- Artifact: optimized arm64 Mach-O, ad-hoc signed, identifier `com.oxalpha.timeduck`.
- Executable: 1,102,344 bytes; app bundle: 1,880 KiB on disk.

## 21. EXACT FILES CHANGED

Files modified or added by this audit (some were already dirty with unreleased Wave work; unrelated content was preserved):

- `Tests/TestRunner.swift`
- `Tests/TimeDuckTests/PreWave8AuditTests.swift` (new)
- `build.sh`
- `src/App/AppDelegate.swift`
- `src/App/Persistence.swift`
- `src/Engine/DuckBrain.swift`
- `src/Engine/DuckStoryEngine.swift`
- `src/Engine/Formatting.swift`
- `src/Engine/StatsTracker.swift`
- `src/Engine/TimerEngine.swift`
- `src/Graphics/CompactLayout.swift`
- `src/Views/TimeDuckView.swift`
- `Development/DuckDrops/Sol-Ralph-Pre-Wave-8/REPORT.md` (new)

No historical Wave report was rewritten by this audit.

## 22. PUBLIC WORKTREE VERIFICATION

`/Users/homebase/Documents/TimeDuck` was read only for baseline/final verification. It remains clean at exactly:

`57832771f930227f398ced0259392aed15800ceb`

It was not modified. No public-repository, Homebrew, push, merge, tag, release, or worktree-writing action occurred.

## 23. REMAINING RISKS

- No automated macOS UI driver exercised real physical mouse/keyboard/window-server timing, monitor changes, or accessibility toggles; geometry and command paths were tested structurally/in-process.
- System sleep/wake and multi-hour behavior were simulated through clock dates/theatrical ticks, not an actual multi-hour hardware sleep.
- Audio lifecycle was code-audited and generator-smoke-tested without asserting speaker output or AVAudioEngine behavior across every hardware route change.
- Visual handoff/accessory quality is partly subjective; structural continuity and anchors passed, but a human pixel-by-pixel review on real displays is still appropriate.
- No Instruments run was performed; array/timer/closure ownership conclusions are code-supported, not a claim of zero allocations or leaks.
- The repository remains intentionally dirty with the unreleased Wave 5–7.2 line and these uncommitted audit changes; independent diff review is required before any commit.

## 24. WAVE 8 WARNINGS

- Keep all future unlock/achievement authority out of `DuckStoryEngine` and preview callbacks; preview must remain incapable of incrementing or persisting user progress.
- Do not derive achievement time from animation/finale elapsed values. Only clock models and idempotent completion servicing may provide authoritative session results.
- Preserve per-mode completion/alarm ownership if companions observe completion.
- New companion effects need explicit owner/session tokens or equivalent cleanup hooks; do not rely on pointer input to clear them.
- Bound every new roster/history/particle/event collection at insertion and validate all new persisted counters before arithmetic.
- Do not overload `DuckBrain` or the single `TimeDuckView` with companion persistence authority without an explicit ownership boundary.
- These are observations only. No Wave 8 abstraction, roster, unlock, achievement, Chrono Duck, dumpster/laptop companion, stealth warrior, or tactical mech was implemented.

## 25. RALPH ITERATION SUMMARY

1. **Baseline/archaeology:** verified branch/worktrees, independently reproduced 146/146, clean-built the app, traced clock-to-persistence ownership. Found that tests omitted the real view runtime.
2. **Story/timer authority:** attacked cancel/pause/reset/mode/finale/new-session paths. Fixed story resurrection, stale auto selection, pause semantics, finale rearm, paused Pomodoro divergence, alarm ownership, and quick-start/skip lifecycle.
3. **Finale/handoff/effects:** attacked all story thresholds, long finales, WOD cadence, sleep/MiniHUD cleanup. Fixed finale time, WOD event spam/wiring, and temporary-effect ownership.
4. **Preview/persistence firewall:** attacked preview during live/completed clocks and reordered saves. Fixed live preview mutation, real-completion contamination, stale-save overwrite, backward-compat sanitization, and hostile counter overflow.
5. **Clock/resource fuzz:** ran fixed-seed mixed operations and extreme inputs. Fixed completed-clock resurrection, simultaneous alarm audio, duration-anchor maximums, MiniHUD extreme formatting, bounded Stopwatch time/laps, and bounded FEED history.
6. **Lifecycle/performance:** reviewed frame/status pumps, hide/show, delayed audio, and collections. Fixed paused stories pinning 60 FPS.
7. **Fresh stopping pass:** re-audited completion ordering, audio mute guards, preview/Store/stats crossings, timers/closures, force-crash sites, every append site, static warnings, and offline/privacy requirements. Found no further meaningful reproducible defect.

## 26. FINAL VERDICT

The foundation is suitable to proceed to independent review. This is not authorization to merge, release, or begin Wave 8.

SOL RALPH GATE: PASS
