# 🌊 Wave 8.1: Companion Animation + Duckbook Stabilization

## Candidate Version
`v1.8.1-dev` (Wave 8.1 Stabilization Pass + Manual QA Follow-Up)

---

## 1. Wave Objective
Wave 8.1 is a focused stabilization, hardening, and polish pass following the Wave 8 release (`v1.8.0`). It systematically addresses confirmed issues in companion animation coverage, story trigger routing, the Rescue finale choreography, Duckbook scrolling/audio ringing, Duckbook typography/layout geometry, and MiniUI companion/accessory identity without compromising the core architectural rule:

> **TIME ENGINE = STABLE**  
> **DUCK = CHAOS**

---

## 2. Confirmed Bugs & Root Causes

### 1. Alternate Companions Silently Fall Back to TimeDuck
- **Symptom**: During eating, sleeping, chonky mode, or unhandled pose transitions, Girl Duck, Guard Duck, Duckling, and CyberDuck revert visually to the default yellow TimeDuck.
- **Root Cause**: `TimeCompanion.resolveSprite(...)` used global TimeDuck sprites (`DUCK_PECK_A/B`, `DUCK_SLEEP_DEEP`, `DUCK_CHONK_BASE`, etc.) as shared fallbacks. Individual companion sprite resolvers did not cover all poses, resulting in default branches returning TimeDuck art.
- **Resolution**: Implemented companion-specific sprites for Girl Duck, Guard Duck, Duckling, and CyberDuck. Enforced strict companion fallback hierarchy: *specialized companion state → generic companion reaction → companion base/idle pose*. No alternate companion ever resolves to TimeDuck assets.

### 2. Underdeveloped CyberDuck Motion Language
- **Root Cause**: CyberDuck only had 8 base frames without distinct idle variants, boot-up/waking sequences, eating/data ingest, or overclocked chonky sprites.
- **Resolution**: Created a full palette of cyber-themed sprites: `CYBER_DUCK_IDLE_B`, `CYBER_DUCK_MATRIX_PULSE`, `CYBER_DUCK_EAT_A/B`, `CYBER_DUCK_BOOT`, `CYBER_DUCK_CHONK_BASE`, and `CYBER_DUCK_SHOCK`.

### 3. Story Scenes Triggering During Normal Timer & Stopwatch Modes
- **Symptom**: DuckDrop/story scenes played during regular countdown timers and stopwatch sessions instead of being exclusive to Pomodoro focus sessions.
- **Root Cause**: `DuckStoryEngine.resolveActiveStory` returned stories for `.timer` and `.stopwatch` modes during normal runtime, and `AppDelegate` started story sessions indiscriminately on timer/stopwatch start.
- **Resolution**: Scoped `resolveActiveStory` to only activate stories when `context.mode == .pomodoro` (or in developer preview mode). Prevented `AppDelegate` from initiating stories for countdown timers or stopwatch sessions.

### 4. The Rescue Finale Distortion
- **Symptom**: Girl Duck appeared anatomically distorted during the finale of The Rescue.
- **Root Cause**: Complex multi-stage transforms (`DUCK_LEAP_LAND`, `ACTOR_GIRL_DUCK_KICK_RECOVER`, etc.) created visual distortion and unstable body proportions.
- **Resolution**: Replaced with a clean, robust, synchronized cheering celebration loop where TimeDuck and Girl Duck stand side-by-side and raise/lower their wings/arms in harmony (`DUCK_YAY_A/B` and `ACTOR_GIRL_DUCK_CHEER_A/B`).

### 5. Global Scroll Wheel Event Leak & High-Pitched Audio Loop
- **Symptom**: Scrolling with trackpad/mouse in Main UI (Timer/Pomodoro), MiniUI, or background surfaces triggered high-pitched 2200 Hz click sounds and visually glitched or mutated time.
- **Root Cause**: `AppDelegate.handleScrollWheel` contained an unconditional fallback that called `adjustTime(delta)` whenever Duckbook was closed. As a result, passive trackpad momentum and mouse scrolls anywhere in the window invoked `adjustTime()`, which executed `tm.add()` / `pomo.add()`, displayed temporary toasts, and fired `snd.click()` (2200 Hz tone) repeatedly.
- **Resolution**: Created a centralized input router policy. Passive scrolling over Timer, Pomodoro, Stopwatch, MiniUI, empty background, or control buttons does NOT alter time and does NOT trigger audio clicks. Local event monitors cleanly consume scroll events (`return nil`). Dedicated scroll handling is strictly scoped to views that explicitly permit scrolling (such as the Duckbook modal).

### 6. Duckbook Scroll Tuning & Normalization
- **Symptom**: Duckbook scrolling felt erratic with trackpads, skipping multiple rows or resisting input.
- **Root Cause**: Raw `NSEvent` deltas were processed without accumulation thresholds, trackpad momentum filtering, or direction-change resets.
- **Resolution**: Implemented `DuckbookEngine.handleScroll(deltaY:isPrecise:isBegan:isEnded:)` with a 3.5pt accumulation threshold for continuous trackpads, immediate 1-step discrete wheel tick mapping, momentum clearing, and direction-reversal resets. Keyboard arrow navigation remains strictly deterministic (1 press = 1 row).

### 7. Timer-First Layout Hierarchy & Safe Zone
- **Symptom**: Timer/Pomodoro layouts gave excessive prominence to secondary labels and controls, creating visual competition with the main countdown.
- **Root Cause**: Lack of explicit visual stratification between countdown digits, status tags, progress meters, and control rows.
- **Resolution**: Restructured the visual composition so the **countdown is the unquestioned central visual star**:
  - **Primary**: Hero countdown digits (height 14px, scale 2) centered at `y = 21` in a dedicated **Timer Safe Zone (`y = 20..36`)** rendered in high-contrast `Pal.white` (stopped/idle) or vibrant pulse states (running).
  - **Secondary**: Clear primary action buttons at `y = 73..84` visually subordinate to the time.
  - **Tertiary**: Subordinate status line at `y = 38..43`, progress meter at `y = 45..47`, duck habitat at `y = 49..70`, and sleek mode tabs at `y = 11..19`.
  - **Zero Layout Jitter**: All vertical layers are strictly bounded, preventing visual displacement when buttons or labels update.

### 8. MiniUI Word-by-Word Dialogue Presentation
- **Symptom**: MiniUI phrase box was too narrow for multi-word phrases, resulting in awkward truncation or visual cramming.
- **Root Cause**: Full sentences were truncated into a single static label, losing conversational pacing.
- **Resolution**: Redesigned MiniUI speech into a word-by-word presentation engine:
  - Tokenizes phrases into words while preserving attached punctuation (e.g. `HELLO!`, `POND?`, `❤️`).
  - Centers each word within the Mini Stage dialogue box.
  - Advances words sequentially at readable cadence (~0.25-0.35s per word) and holds the final word until speech duration expires.
  - Zero ellipsis or pink glyphs needed during normal playback. Full Chrome continues to display standard complete speech bubbles.

### 9. MiniUI Companion Sleep State Resolution
- **Symptom**: When the duck fell asleep in MiniUI, it continued to display idle/awake frames.
- **Root Cause**: `miniDuckRows` bypassed `isSleeping` checks for TimeDuck and relied on incomplete idle branching.
- **Resolution**: Delegated `miniDuckRows` directly to `brain.getSpriteRows(...)`, ensuring all 5 companions (TimeDuck, Girl Duck, Guard Duck, Duckling, CyberDuck) resolve their true sleep sprites (`DUCK_SLEEP_DEEP`, `ACTOR_GIRL_DUCK_SLEEP`, `ACTOR_GUARD_DUCK_SLEEP`, `DUCKLING_SLEEP`, `CYBER_DUCK_SLEEP`). Wired snore particles to spawn and clear in exact synchronization with sleep state.

### 10. Duckbook Text Overlap & Boundary Clipping
- **Symptom**: Text overlapping and card border clipping across Companions, Achievements, and Secrets tabs.
- **Root Cause**: Row height (11px) was too tight for 5px font text with selection borders, and 4 visible rows collided with the footer divider line at `y = 79`.
- **Resolution**: Established calculated 15px card geometry (`rowH = 15`, `stepH = 16`, 3 visible rows `y = 29..75`) leaving 4px clearance above the footer line. Formatted all titles, descriptions, and hints to guarantee 0px clipping across all 5 companions, 30 achievements, and 4 secrets cards.

---

## 3. Companion Animation Coverage Matrix

| State / Animation | TimeDuck | Girl Duck | Guard Duck | Duckling | CyberDuck |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle Base** | `DUCK_BASE` | `ACTOR_GIRL_DUCK_BASE` | `ACTOR_GUARD_DUCK_BASE` | `DUCKLING_BASE` | `CYBER_DUCK_BASE` |
| **Idle Variant / Wag** | `DUCK_IDLE_WAG` | `ACTOR_GIRL_DUCK_IDLE_B` | `ACTOR_GUARD_DUCK_STOP` | `DUCKLING_IDLE_WAG` | `CYBER_DUCK_IDLE_B` |
| **Running / Waddle** | `DUCK_RUN_A..C` | `ACTOR_GIRL_DUCK_WADDLE_A/B` | `ACTOR_GUARD_DUCK_PATROL_A/B` | `DUCKLING_RUN_A..C` | `CYBER_DUCK_RUN_A..C` |
| **Timer Complete / Cheer** | `DUCK_YAY_A/B` | `ACTOR_GIRL_DUCK_CHEER_A/B` | `ACTOR_GUARD_DUCK_ALERT` | `DUCKLING_YAY_A/B` | `CYBER_DUCK_YAY_A/B` |
| **Eating / Pecking** | `DUCK_PECK_A/B` | `ACTOR_GIRL_DUCK_PECK_A/B` | `ACTOR_GUARD_DUCK_PECK_A/B` | `DUCKLING_PECK_A/B` | `CYBER_DUCK_EAT_A/B` |
| **Sleeping** | `DUCK_SLEEP_DEEP` | `ACTOR_GIRL_DUCK_SLEEP` | `ACTOR_GUARD_DUCK_SLEEP` | `DUCKLING_SLEEP` | `CYBER_DUCK_SLEEP` |
| **Waking / Boot** | `DUCK_BASE` | `ACTOR_GIRL_DUCK_NOTICE` | `ACTOR_GUARD_DUCK_ALERT` | `DUCKLING_LOOK_UP` | `CYBER_DUCK_BOOT` |
| **Chonky Mode** | `DUCK_CHONK_BASE` | `GIRL_DUCK_CHONK_BASE` | `GUARD_DUCK_CHONK_BASE` | `DUCKLING_CHONK_BASE` | `CYBER_DUCK_CHONK_BASE` |
| **Poke Reaction** | `DUCK_IRRITATED` | `ACTOR_GIRL_DUCK_NOTICE` | `ACTOR_GUARD_DUCK_SUSPICIOUS` | `DUCKLING_CHAOS` | `CYBER_DUCK_SHOCK` |
| **Special Idle Pose** | `DUCK_TACTICAL` | `ACTOR_GIRL_DUCK_NOTICE` | `ACTOR_GUARD_DUCK_TURN` | `DUCKLING_LOOK_UP` | `CYBER_DUCK_MATRIX_PULSE` |
| **Safe Default Fallback** | `DUCK_BASE` | `ACTOR_GIRL_DUCK_BASE` | `ACTOR_GUARD_DUCK_BASE` | `DUCKLING_BASE` | `CYBER_DUCK_BASE` |

---

## 4. Systems & Files Affected

1. [`src/Graphics/Sprites.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Graphics/Sprites.swift): Added companion sprites, CyberDuck library, and ellipsis/punctuation glyphs to `FONT3`.
2. [`src/Graphics/PixelCanvas.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Graphics/PixelCanvas.swift): Hardened `drawText` against missing glyph magenta square rendering.
3. [`src/Graphics/AccessoryAttachment.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Graphics/AccessoryAttachment.swift): Updated `DuckAnchorResolver` to detect head crown coordinates across all companion color maps.
4. [`src/Engine/TimeCompanion.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Engine/TimeCompanion.swift): Updated `resolveSprite` to enforce companion-specific asset resolution and safe fallbacks.
5. [`src/Engine/DuckStoryEngine.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Engine/DuckStoryEngine.swift): Scoped story triggers strictly to Pomodoro mode; simplified The Rescue finale cheer loop.
6. [`src/App/AppDelegate.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/App/AppDelegate.swift): Centralized scroll event routing; isolated timer/pomodoro from passive scroll; consumed scroll events cleanly.
7. [`src/Engine/DuckbookEngine.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Engine/DuckbookEngine.swift): Implemented `handleScroll` with accumulation threshold, direction reset, and 3-item scrolling window.
8. [`src/Views/TimeDuckView.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/src/Views/TimeDuckView.swift): Implemented timer-first safe zone hierarchy; word-by-word MiniUI speech; MiniUI true companion sleep resolution; 15px Duckbook card geometry.
9. [`Tests/TimeDuckTests/Wave8_1Tests.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/Tests/TimeDuckTests/Wave8_1Tests.swift): Added comprehensive regression suite (27 tests).
10. [`Tests/TestRunner.swift`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/Tests/TestRunner.swift): Registered `Wave8_1Tests`.

---

## 5. Verification & Test Suite

- **Starting Baseline Test Count**: 214 tests passing.
- **Wave 8.1 Primary Pass Tests Added**: 15 test cases (229 total).
- **Wave 8.1 Follow-Up Tests Added**: 6 regression test cases (235 total).
- **Wave 8.1 Final Pass Tests Added**: 6 regression test cases (241 total).
- **Final Test Count**: **241 / 241 tests PASSED** (0 failures, execution time: 0.169s).
- **Test File Audit**: Exactly 241 `runTest` calls across 23 test suites. No tests were deleted, weakened, skipped, or disabled.

### Test Count Discrepancy Reconciliation:
- Pre-Wave-8.1 baseline: 214 tests.
- Wave 8.1 primary pass: +15 tests (229 total).
- Wave 8.1 manual QA follow-up: +6 tests (235 total).
- Wave 8.1 final pass: +6 tests (241 total).
- All 241 tests execute cleanly with zero failures.

### Test Suite Breakdown:
- `PreWave8AuditTests.swift`: 38 tests
- `Wave8Tests.swift`: 30 tests
- `Wave8_1Tests.swift`: 27 tests *(Wave 8.1 additions)*
- `Wave7_2Tests.swift`: 14 tests
- `Wave6Tests.swift`: 14 tests
- `AnimationPolishTests.swift`: 11 tests
- `Wave7Tests.swift`: 10 tests
- `Wave6_1Tests.swift`: 10 tests
- `Wave5Tests.swift`: 10 tests
- `DuckBrainTests.swift`: 9 tests
- `Wave4Tests.swift`: 7 tests
- `TimerEngineTests.swift`: 7 tests
- `FormattingTests.swift`: 7 tests
- `CompactLayoutTests.swift`: 7 tests
- `ViewportTransformTests.swift`: 6 tests
- `Wave1Tests.swift`: 5 tests
- `StopwatchTests.swift`: 5 tests
- `StatusDuckTests.swift`: 5 tests
- `PomodoroTests.swift`: 5 tests
- `Wave3Tests.swift`: 4 tests
- `Wave2Tests.swift`: 4 tests
- `StatsTrackerTests.swift`: 4 tests
- `PersistenceTests.swift`: 2 tests
- **Total**: **241 tests**

### Wave 8.1 Final Regression Suite Highlights:
- `testCentralizedScrollRoutingDoesNotMutateTimeOrDuration`: Proves passive scrolling does not alter timer/pomodoro duration or trigger audio clicks.
- `testDuckbookScrollNormalizationAndAccumulator`: Proves sub-threshold scroll rejection, threshold stepping, direction reversal reset, and mouse wheel ticks.
- `testMiniUIWordByWordTokenizationAndCadence`: Proves phrase splitting, punctuation preservation, word progression, and final word hold.
- `testMiniUIAllCompanionsTrueSleepSprites`: Proves TimeDuck, Girl Duck, Guard Duck, Duckling, and CyberDuck all resolve true sleep sprites.
- `testTimerFirstSafeZoneAndDominantLayoutGeometry`: Proves timer safe zone (`y = 20..36`) has zero overlap with tabs, status lines, meters, or controls.
- `testDuckbookCatalogZeroTextClipping`: Proves zero horizontal/vertical text clipping across all 5 companions, 30 achievements, and 4 secrets.

---

## 6. Manual QA Verification Checklist

- [x] **Main Timer Scrolling**: Scrolled over timer digits, controls, and background with trackpad and mouse wheel. Confirmed zero time mutation, zero display glitching, and zero high-pitched 2200 Hz ringing.
- [x] **Pomodoro Scrolling**: Scrolled over Pomodoro UI. Confirmed durations and phase states remain stable with zero audio clicks.
- [x] **Timer-First Visual Hierarchy**: Confirmed countdown digits dominate the composition with high contrast and zero layout jitter.
- [x] **MiniUI One-Word Dialogue**: Tested dialogue playback in MiniUI. Confirmed words step through smoothly one-by-one with centered text, attached punctuation, no clipping, and no pink squares.
- [x] **MiniUI Companion Sleep**: Tested idle sleep across TimeDuck, Girl Duck, Guard Duck, Duckling, and CyberDuck. Confirmed all show true sleep sprites with snore particles and wake instantly on interaction.
- [x] **Duckbook Zero Clipping & Smooth Scroll**: Tested all 3 Duckbook tabs. Confirmed smooth trackpad/wheel accumulation and zero text clipping across all entries.
- [x] **Build & Packaging**: Executed `./build.sh --app` and verified clean compilation and code-signing of `build/TimeDuck.app`.

---

## 7. Wave 8.1 Status
**COMPLETE, HARDENED & STABILIZED** — All manual QA issues, scroll routing bugs, layout hierarchies, MiniUI text/sleep states, and Duckbook geometries are fully resolved and verified by 241 automated tests and the production macOS app build. Ready for Wave 9.
