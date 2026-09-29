# TimeDuck — Terra Re-Verification Gate
## Post-Blocker-Repair / Pre-Wave-8

Date: 2026-08-27  
Scope: `/Users/homebase/Documents/TimeDuck-DuckDrops` only  
Branch: `duckdrops-dev`  
Role: independent re-verifier; no product-source repair performed.

## 1. BASELINE

- Workspace: `/Users/homebase/Documents/TimeDuck-DuckDrops`.
- Branch: `duckdrops-dev`.
- Public worktree: `/Users/homebase/Documents/TimeDuck`, clean on `main` at `5783277`.
- `./build.sh --clean`: passed.
- `./build.sh --test`: **182 / 182 passed**, 0 failures.
- `./build.sh --app`: passed; no compiler warnings emitted.

## 2. BLOCKER 1 RE-VERIFICATION

Most repaired paths correctly call `TimeDuckView.resetStoryForClockReconfiguration()`: Stopwatch secondary reset, Timer DONE, Timer/Pomodoro presets, direct entry, finished adjustments routed through `adjustTime`, phase skip/advance, quick starts, and full reset.

However, the Timer secondary action remains a live bypass. In `AppDelegate.secondaryAction`, the Timer branch calls `tm.add(60)` directly, without calling the reconfiguration helper. This action is the visible `+1 MIN` control and is also keyboard `L`.

### Reproduction

1. Set a Timer to five seconds, start it, and wait for completion/finale.
2. Trigger the visible `+1 MIN` action (or press `L`).
3. The clock becomes a stopped `01:05` next-session configuration, but the preceding story finale remains active and continues to render with its actors/effects.

This is the original finished-clock-adjustment failure class. A subsequent Start may construct a fresh story, but the intervening stopped clock state is contaminated and the lifecycle contract is broken.

## 3. BLOCKER 1 OVER-CLEANUP CHECK

The helper itself has appropriate scope: it cancels a story only for semantic reset/reconfiguration operations. Running adjustments through `adjustTime`, pause/resume, theme/costume selection, and MiniHUD/full switching do not call it.

No over-cleanup regression was identified in the inspected helper callers. The remaining issue is under-coverage: the Timer `secondaryAction` path bypasses the helper.

## 4. BLOCKER 2 RE-VERIFICATION

Source inspection found `clearViewportOwnedEffects()` now clears snores, particles, breadcrumbs, speech, toast, ember budget, and pet/hop/peck transient state. `setMini(_:)` calls it before changing coordinate systems.

The prior MiniHUD-breadcrumb-to-full-clock leak is addressed by this implementation. Story session state and authoritative clocks are not cleared by viewport switching.

## 5. BLOCKER 2 SIBLING EFFECT AUDIT

Inspected viewport-local state:

- `parts`, `crumbs`, and `snoreParticles`: cleared.
- `speechText`, `speechUntil`, and `toastText`: cleared.
- `emberBudget`, `petUntil`, `hopUntil`, and `peckUntil`: reset.
- `stars`: reseeded for the target viewport.
- Story actors/props: remain story-owned rather than viewport-owned; MiniHUD uses its own bounded rendering path.

No additional viewport-coordinate leak was identified in this source pass.

## 6. BLOCKER 3 RE-VERIFICATION

Timer and Pomodoro now sanitize running restores consistently:

- their `remaining(at:)` results are finite, non-negative, and capped at the model maximum;
- a future restored end wall is re-anchored to `min(rawRemaining, configured/current phase duration, maximumDuration)`;
- a past end wall remains present, preserving finished semantics.

The model code supports valid running restores, maximum-domain restores, and past-end completion behavior. The 182-test run passed the dedicated Timer and Pomodoro restore cases.

## 7. RESTORE INVARIANT CONSISTENCY

The revised Timer and Pomodoro policies keep configured duration/phase duration authoritative for a reconstructed running anchor. This prevents a decoded timestamp from supplying more remaining time than its current session can own. No restore-domain regression was found.

## 8. SIBLING FIX VERIFICATION

- Pomodoro next phase: invokes the reset/reconfiguration helper before advancing and starting the next phase.
- Quick starts: invoke the helper after mode switch and before starting a fresh clock/story session.
- Finished keyboard/scroll adjustments through `adjustTime`: invoke the helper.
- **Timer secondary `+1 MIN` / `L`: remains uncorrected and is the blocking sibling path.**

## 9. NEW TEST QUALITY

The new tests validate the helper behavior and restore logic, and they would catch regressions inside those helpers.

They do not exercise the actual `AppDelegate.secondaryAction` Timer branch. For example, the Timer DONE/preset tests manually call `view.resetStoryForClockReconfiguration()` before mutating the clock. This test shape therefore cannot fail when a UI command omits the helper. The 182/182 result does not verify all claimed command-path coverage.

## 10. FUZZ RESULT

The existing multi-seed deterministic fuzz ran as part of the passing 182-test suite (15,000 operations reported by the suite/report). It did not cover the omitted Timer secondary-command lifecycle transition.

## 11. ADVERSARIAL UI/LIFECYCLE RESULT

Manual UI verification reproduced the blocker through the running app:

`Timer completion → active finale → +1 MIN / L → stopped 01:05 clock with old finale still rendered`.

This fails the required lifecycle separation for a newly configured clock session.

## 12. REGRESSION SANITY

The normal automated suite, including preview, finales, scene transitions, MiniHUD geometry, persistence, and completion idempotence, passed. No evidence from this pass suggests the three repaired helpers introduced a separate regression.

The unresolved Timer secondary-action bypass is nevertheless sufficient to prevent a foundation freeze.

## 13. BUILD RESULT

`./build.sh --clean` and `./build.sh --app` succeeded. No compiler warnings were emitted.

## 14. TEST RESULT

`182 / 182 PASSED`

## 15. PUBLIC WORKTREE STATUS

`/Users/homebase/Documents/TimeDuck` remains clean on `main` at `5783277`.

## 16. SOURCE FILES CHANGED BY TERRA

NONE. This report is the only artifact added by Terra.

## 17. RESIDUAL RISKS

- **Release-blocking:** Timer `+1 MIN` / keyboard `L` leaves a finished-session story finale active after clock reconfiguration.
- UI-command integration coverage remains incomplete where tests directly invoke lifecycle helpers instead of the command handlers that must call them.

## 18. PRE-WAVE-8 FOUNDATION VERDICT

TimeCompanions/Achievements must **not** begin. Repair the Timer secondary-action lifecycle bypass and add a command-path regression test before another independent re-verification.

## FINAL VERDICT

TERRA VERIFICATION GATE: BLOCK
