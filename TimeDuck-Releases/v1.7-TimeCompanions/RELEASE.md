# Official Release Specification: TimeDuck v1.7 — TimeCompanions

- **Official Version**: `v1.7.0`
- **Release Name**: TimeCompanions
- **Source Waves**: `Wave 8: TimeCompanions + Achievements + Duckbook` + `Wave 8.1: Companion Animation + Duckbook Stabilization`
- **Status**: Ready for Implementation (Combined Major Release)

---

## 1. Release Purpose

TimeDuck v1.7 ("TimeCompanions") expands TimeDuck into an extensible, multi-companion ecosystem with an in-app achievement journal and companion selector (**Duckbook**). Unifying Wave 8 (the 5-companion roster, 20 curated achievements, Duckbook modal, and CRT toast system) and Wave 8.1 (companion animation coverage, story trigger scoping, centralized scroll event routing, timer-first safe zone hierarchy, word-by-word MiniUI dialogue, and layout geometry stabilization), this release delivers deep companion variety while maintaining the sacred rule:

> **TIME ENGINE = STABLE**  
> **DUCK = CHAOS**

---

## 2. Complete Feature Set

### 2.1 The Five TimeCompanions Roster

| Companion | Identifier | Portrait / Badge | Unlock Condition | Personality & Presentation |
| :--- | :--- | :--- | :--- | :--- |
| **TimeDuck** | `timeduck` | Classic Yellow | Default (Always unlocked) | The canonical, dependable classic duck. Balanced idle and reaction tendencies. |
| **Girl Duck** | `girlduck` | Ribbon Bow & Peach Blush | Complete The Rescue (`story_rescue`) | Cheerful, social, playful, supportive. Distinct wink, bow, and upbeat celebratory dances. |
| **Guard Duck** | `guardduck` | Military Cap & Dark Plumage | Complete 10 Total Timers (`first_10_timers`) | Absurdly serious, hyper-vigilant patrol routines, sharp salutes, treats crumbs as security incidents. |
| **Duckling** | `duckling` | Tiny Emerald Chick | Feed 15 Breadcrumbs (`feed_15_crumbs`) | High-energy micro-chaos machine, rapid waddles, tiny reactions, disproportionate excitement. |
| **CyberDuck** | `cyberduck` | Secret Cyber Matrix CRT | Discover Pond Maestro (`secret_pond_maestro`) | Secret glitch companion, CRT scanline aesthetics, digital matrix quacks, synthetic audio cues. |

### 2.2 Companion Animation Coverage & Dedicated Sprite Matrices
- Full companion-specific sprite coverage eliminating any fallback to default yellow TimeDuck during eating, sleeping, Chonky mode, or pose transitions:
  - **Girl Duck**: `ACTOR_GIRL_DUCK_BASE`, `_IDLE_B`, `_WADDLE_A/B`, `_CHEER_A/B`, `_PECK_A/B`, `_SLEEP`, `_NOTICE`, `GIRL_DUCK_CHONK_BASE`.
  - **Guard Duck**: `ACTOR_GUARD_DUCK_BASE`, `_STOP`, `_PATROL_A/B`, `_ALERT`, `_PECK_A/B`, `_SLEEP`, `_TURN`, `_SUSPICIOUS`, `GUARD_DUCK_CHONK_BASE`.
  - **Duckling**: `DUCKLING_BASE`, `_IDLE_WAG`, `_RUN_A..C`, `_YAY_A/B`, `_PECK_A/B`, `_SLEEP`, `_LOOK_UP`, `_CHAOS`, `DUCKLING_CHONK_BASE`.
  - **CyberDuck**: `CYBER_DUCK_BASE`, `_IDLE_B`, `_RUN_A..C`, `_YAY_A/B`, `_EAT_A/B`, `_SLEEP`, `_BOOT`, `_MATRIX_PULSE`, `_SHOCK`, `CYBER_DUCK_CHONK_BASE`.
- Enforced companion fallback hierarchy: *specialized companion state $	o$ generic companion reaction $	o$ companion base/idle pose*.

### 2.3 Curated Achievement System (20 Milestones Across 5 Categories)

1. **Timer Milestones**:
   - `first_timer` ("First Waddle"): Successfully complete your first timer session.
   - `first_10_timers` ("Tenacious Duck"): Complete 10 timer sessions. *Unlocks Guard Duck*.
   - `marathon_timer` ("Pond Marathon"): Complete a single timer session lasting $\ge 45$ minutes.
   - `early_bird` ("Quack of Dawn"): Complete a timer between 5:00 AM and 7:00 AM.
   - `night_owl` ("Night Owl... Duck?"): Complete a timer between 11:00 PM and 4:00 AM.
   - `century_timer` ("Pond Century"): Reach 100 total completed timer sessions.

2. **Mode & Focus Milestones**:
   - `pomodoro_work` ("Focused Duck"): Complete a 25-minute Pomodoro focus sprint.
   - `pomodoro_cycle` ("Master of Time"): Complete a full 4-sprint Pomodoro work/break cycle.
   - `minihud_completion` ("Pocket Sized"): Complete a timer while in compact MiniHUD mode.
   - `stopwatch_split` ("Split Second"): Record 5 or more lap splits in a single stopwatch session.

3. **Interaction & Antics Milestones**:
   - `poke_escalation_max` ("Personal Space"): Reach max poke escalation (Stage 5+).
   - `feed_15_crumbs` ("Breadwinner"): Feed TimeDuck 15 breadcrumbs. *Unlocks Duckling*.
   - `chonky_mode` ("Absolute Unit"): Feed TimeDuck enough to enter Chonky Duck mode.
   - `costume_collector` ("Fashionably Late"): Try on 5 different hats or accessories.

4. **Story Finales & Theatrical Shows**:
   - `story_feast` ("Worth It."): Experience the full digestion finale of The Feast.
   - `story_expedition` ("Summit Duck"): Plant the summit flag in The Expedition.
   - `story_nightshift` ("Clocked Out"): Finish the late night desk shift in Night Shift.
   - `story_wod` ("No Days Off"): Complete all heavy reps in The WOD.
   - `story_rescue` ("Leave No Duck Behind"): Escape the facility and liberate Girl Duck in The Rescue. *Unlocks Girl Duck*.

5. **Secret Discoveries**:
   - `secret_pond_maestro` ("Pond Maestro"): Toggle sound effects 10 times in a single session. *Unlocks CyberDuck*.

### 2.4 In-App Duckbook Modal Architecture (`⌘B` / `D`)
- Modal window featuring three dedicated tabs:
  1. `Companions`: Companion roster cards with portraits, descriptions, active status, and unlock hints.
  2. `Achievements`: Pixel badge grid with unlock timestamps, progress indicators, and secret `???` representations.
  3. `Secrets`: Discovered rare Easter eggs and secret companion statuses.
- **Tuned Geometry & Scrolling**:
  - Calculated 15px card geometry (`rowH = 15`, `stepH = 16`, 3 visible rows `y = 29..75`) leaving 4px clearance above footer divider line.
  - Normalized scroll handling: 3.5pt accumulation threshold for continuous trackpads, 1-step discrete wheel ticks, momentum filtering, and direction-reversal resets.
  - Full keyboard navigation (Tab between cards, Arrow keys to scroll, Space/Enter to select, Esc to close).
  - Full VoiceOver accessibility labels and dynamic summaries.

### 2.5 Non-Intrusive CRT Toast Queue
- Floating CRT-styled toast HUD rendered in the top-right corner of the canvas.
- Queues multiple simultaneous unlocks gracefully (displays sequentially for 3.5s each).
- Never steals keyboard focus, never blocks timer controls, and never mutates timer engine state.

### 2.6 Core Platform Stabilizations & Hardening (Wave 8.1)
- **Centralized Scroll Event Routing**: Passive scrolling over Timer, Pomodoro, Stopwatch, MiniUI, empty background, or control buttons does NOT alter time and does NOT trigger audio clicks. Local event monitors cleanly consume scroll events (`return nil`). Dedicated scroll handling is strictly scoped to views that explicitly permit scrolling (such as the Duckbook modal).
- **Story Trigger Scoping**: `DuckStoryEngine.resolveActiveStory` is scoped to activate stories exclusively during `.pomodoro` focus sessions (or in developer preview mode). Regular countdown timers and stopwatch sessions remain clean and distraction-free.
- **Timer-First Safe Zone Hierarchy**:
  - Primary countdown digits (height 14px, scale 2) centered at `y = 21` in a dedicated **Timer Safe Zone (`y = 20..36`)** rendered in high-contrast `Pal.white`.
  - Zero layout jitter: All vertical layers (mode tabs, timer digits, status lines, progress meters, duck habitat, action buttons) are strictly bounded.
- **MiniUI Word-by-Word Dialogue Engine**:
  - Tokenizes phrases into words while preserving attached punctuation (e.g., `HELLO!`, `POND?`, `❤️`).
  - Advances words sequentially at readable cadence (~0.25-0.35s per word) and holds final word until speech duration expires.
- **MiniUI Companion Sleep State Resolution**:
  - All 5 companions resolve their true sleep sprites and spawn synchronized snore particles in MiniUI.
- **The Rescue Finale Hardening**:
  - Replaced multi-stage transforms with a clean, synchronized cheering celebration loop (`DUCK_YAY_A/B` + `ACTOR_GIRL_DUCK_CHEER_A/B`).

---

## 3. UI/UX Changes

- Added `Companions → Open Duckbook…` (`⌘B`) and quick key `D` to open Duckbook.
- Added toast notification overlay for achievement unlocks.
- Upgraded MiniUI dialogue presentation to word-by-word scrolling.

---

## 4. Animation & Visual Changes

- Complete sprite libraries for Girl Duck, Guard Duck, Duckling, and CyberDuck.
- 15px Duckbook badge and card rendering.
- Word-by-word centered dialogue engine in MiniHUD.

---

## 5. Audio Changes

- Added CyberDuck synthetic digital sound effects.
- Eliminated unwanted 2200 Hz click audio loops during passive trackpad scrolling.

---

## 6. Secrets & Easter Eggs

- CyberDuck secret companion unlocked via Pond Maestro achievement.
- Achievements tab tracks secret discovery milestones.

---

## 7. Accessibility Changes

- Duckbook includes full VoiceOver accessibility support and keyboard-only navigation.
- Reduced motion preference provides instant tab transitions in Duckbook without sliding animations.

---

## 8. Technical & Runtime Changes

- **`src/Engine/TimeCompanion.swift`**: Defines companion roster, identifier enums, traits, and sprite resolution hierarchy.
- **`src/Engine/DuckbookEngine.swift`**: Manages companion selection, achievement evaluation, persistence, and normalized scrolling.
- **`src/App/AppDelegate.swift`**: Centralizes scroll event routing and protects clocks from passive scroll mutation.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- All 20 edge-case defects identified in Sol-Ralph, Gemini, and Terra pre-Wave-8 audits (SR-001 through SR-020) and Wave 8.1 stabilization pass are fully verified and incorporated.

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test` (241 total test cases):
1. `testCentralizedScrollRoutingDoesNotMutateTimeOrDuration`: Verifies passive scrolling does not alter duration or trigger audio clicks.
2. `testDuckbookScrollNormalizationAndAccumulator`: Verifies scroll threshold stepping and wheel tick handling.
3. `testMiniUIWordByWordTokenizationAndCadence`: Verifies dialogue splitting and word progression.
4. `testMiniUIAllCompanionsTrueSleepSprites`: Verifies all 5 companions resolve true sleep sprites in MiniUI.
5. `testTimerFirstSafeZoneAndDominantLayoutGeometry`: Verifies timer safe zone (`y = 20..36`) has zero overlap.
6. `testDuckbookCatalogZeroTextClipping`: Verifies zero text clipping across all companions, achievements, and secrets.
7. `testAchievementEvaluationEngine`: Validates all 20 achievement triggers and companion unlock rules.

---

## 11. Documentation Requirements

- Document the TimeCompanion roster, achievement catalog, and Duckbook navigation shortcuts in `README.md`.

---

## 12. Known Dependencies Between Features

- TimeCompanion unlocks depend on `DuckbookEngine` event evaluation.
- Duckbook UI depends on `CompactLayout` and `PixelCanvas` text fitting.

---

## 13. Explicit Completion Criteria

- [ ] All 5 TimeCompanions are selectable with distinct sprites across all idle, waddle, eating, sleeping, and Chonky poses.
- [ ] All 20 achievements evaluate and unlock correctly with toast notifications.
- [ ] Duckbook modal opens via `⌘B` / `D`, navigates smoothly via keyboard/scroll, and exhibits zero text clipping.
- [ ] Passive mouse/trackpad scrolling never mutates timer durations or triggers audio clicks.
- [ ] `./build.sh --clean && ./build.sh --test` passes all 241 test cases (0 failures).
- [ ] `./build.sh` produces a production-ready application bundle.
