# Official Release Specification: TimeDuck v1.6 — Pocket Duck

- **Official Version**: `v1.6.0`
- **Release Name**: Pocket Duck
- **Source Waves**: `Wave 7: Living MiniHUD` + `Wave 7.1: Animation Director Pass` + `Wave 7.2: Story Finales, Transitions & Sleep FX`
- **Status**: Ready for Implementation (Combined Major Release)

---

## 1. Release Purpose

TimeDuck v1.6 ("Pocket Duck") transforms TimeDuck's compact window mode into a fully realized, living companion experience (**Living MiniHUD / Pocket Duck**) while establishing the supreme architectural mandate: **THE TIMER IS THE STAR**.

This release unifies Wave 7 (the mathematical protected zone system, Mini Stage, compact Chonky Duck, and 5 compact story editions), Wave 7.1 (the Animation Director pass: Girl Duck & Guard Duck redesigns, front-facing pivot turns, and 7 canonical transition matrices), and Wave 7.2 (dedicated post-completion finale loops, seamless milestone scene handoffs, and anatomically grounded pixel-art bill snore FX).

---

## 2. Complete Feature Set

### 2.1 Visual Hierarchy & Protected Zone Architecture (`CompactLayoutMetrics`)
- **Strict Visual Hierarchy**:
  1. **Primary Time Display**: Maximum scale, high-contrast, phosphor persistence.
  2. **Mode / State Badge**: Subordinate pill (`FOCUS`, `BREAK`, `TIMER`, `SW`, `PAUSED`) in top-left state zone.
  3. **Mini Stage**: Dedicated right-hand column separated by structural vertical rule, housing living companion behaviors without canvas bleeding.
  4. **Essential Controls**: Restrained, quiet action buttons (`START`, `PAUSE`, `RESUME`, `SKIP`, `+1M`, `LAP`, `RESET`, `DONE`) with hover illumination.
  5. **Story / Effect / Decoration**: Micro-props and particle effects strictly clipped to Mini Stage bounds `[duckX, duckX + duckW - 1]`.
- **Zone Geometry**:
  - `timeAreaRect`: $x=4$ to $x=	ext{goX}-3$, $y=11..27$. Absolutely protected from duck sprites and props.
  - `modePillRect`: $x=4$, $y=2..9$.
  - `miniStageRect`: $x=	ext{duckX}..	ext{duckX}+	ext{duckW}-1$, $y=	ext{duckY}..	ext{duckY}+	ext{duckH}-1$. Dedicated canvas with `Pal.bgDeep` fill and boundary rule.
  - `progressBarRect`: $x=3..	ext{gridW}-4$, $y=	ext{gridH}-3..	ext{gridH}-2$.

### 2.2 Dynamic Clock Fitting & Long Stopwatch Protection
- Five dynamic scale levels in `CompactLayoutMetrics.resolveTimeRenderStyle` prevent any text truncation or overlap:
  1. `heroLarge`: Standard $2	imes$ hero font for typical mm:ss countdowns.
  2. `heroWithSmallFrac`: $2	imes$ hero font for main digits + $1	imes$ small font for centiseconds.
  3. `smallScale2`: $2	imes$ small font for hour-spanning stopwatch values (`1:05:42.10`).
  4. `heroScale1`: $1	imes$ hero font for long multi-digit strings.
  5. `smallScale1`: $1	imes$ small font fallback guaranteeing boundary safety on narrow custom widths.

### 2.3 Living Mini Stage Companion Behaviors
- **Clock Drama Acknowledgment**: When remaining time drops $< 10	ext{s}$, TimeDuck glances at the clock (`DUCK_GLANCE_CLOCK`) or points excitedly (`DUCK_POINT_CLOCK`). On completion, performs full celebration (`DUCK_YAY_A/B`). When paused, adopts relaxed loaf posture.
- **Interactive MiniHUD Antics**: Escalating poke tiers (1, 2, 3), pocket breadcrumb feeding with explicit beak alignment, Chonky Duck mode, and dynamic wardrobe attachment clamped to Mini Stage.
- **Micro-Dialogue & Effect Containment**: Speech bubbles fit to Mini Stage width (`NOM.`, `SHHH.`, `GAINS.`, `AWAKE.`, `SUMMIT!`). All particles clipped strictly to `miniStageRect`.

### 2.4 Five Compact Story Editions
- **The Feast**: Micro feeding peck cycles, progressive chonk enlargement (Stages 1–5), belly wobbles, and digestive steam puffs.
- **The Expedition**: Micro trail sign ($5	imes 5$), animated campfire flames ($5	imes 4$), rock waddle, storm lean, and animated summit flag ($5	imes 6$).
- **Night Shift**: Steaming micro coffee mug ($4	imes 4$), heavy droop eyelids, splash awakenings, and blanket burrito micro-nap.
- **The WOD**: Mounted pedaling on micro elliptical ($8	imes 7$), running on animated treadmill belt ($9	imes 4$), dumbbell curls ($5	imes 3$), and flex victory.
- **The Rescue**: Micro metal crate ($6	imes 5$) stealth peek, animated camera beam sweep, single Guard Duck patrol ($9	imes 8$), and Girl Duck ($9	imes 8$) reunion with magenta bow.

### 2.5 Animation Director Pass (Wave 7.1)
- **Girl Duck Redesign**: Exact TimeDuck $13	imes 10$ proportions, golden bill (`ooo`), expressive eyes, magenta hairbow (`m`) anchored at skull crown rows 0–1, and rosy cheek blush (`p`).
- **Guard Duck Redesign**: TimeDuck $13	imes 10$ proportions, security patrol cap (`kkkk`), silver badge (`w`), flashlight prop (`k`), and dedicated front-facing pivot turn frame `ACTOR_GUARD_DUCK_TURN`.
- **Seven Canonical Transition Matrices ($13	imes 10$)**:
  1. `DUCK_BRAKE_STOP`: Deceleration plant frame.
  2. `DUCK_SIT_TRANSITION`: Half-crouch transition connecting standing and sitting.
  3. `DUCK_PECK_ANTICIPATE`: Head pull-back wind-up prior to pecking.
  4. `DUCK_PECK_RECOVER`: Head lift settle following crumb contact.
  5. `DUCK_WEIGHT_BRACE`: Knee bend and wing lock prior to dumbbell curls.
  6. `DUCK_LEAP_ANTICIPATE`: Deep crouch spring wind-up before jumping.
  7. `DUCK_LEAP_LAND`: Ground impact absorption and cushion settlement.

### 2.6 Dedicated Story Finales & Seamless Scene Handoffs (Wave 7.2)
- **Dedicated Post-Completion Finale Loops**:
  1. **The Feast (10s cycle)**: Digestion payoff ($5 	o 0$), belly wobble, steam burp $	o$ calm breath, content head tilt, ground sit, satisfied tail wag.
  2. **The Expedition (12s cycle)**: Summit flag plant and fanfare $	o$ panoramic horizon survey, flag investigation, summit rock rest, wing stretch.
  3. **Night Shift (8s cycle)**: Visible relief ("SHIFT COMPLETE.") $	o$ deep peaceful sleep with gentle feather twitches and pixel `Z` snores.
  4. **The WOD (10s cycle)**: Final rep celebration $	o$ victorious bicep flex, water drink, gym mat rest, proud stance.
  5. **The Rescue (12s cycle)**: Coordinated freedom leap $	o$ side-by-side freedom tableau, synchronized tail wag, Girl Duck cheer, TimeDuck crumb peck.
- **Seamless Scene Handoffs**: Anticipation handoffs, persistent orientation tracking, and decoupled scene clocks eliminate pose jumping and boundary snapping at milestones $0.20, 0.40, 0.60, 0.80$.

### 2.7 Anatomically Grounded Sleep FX (Wave 7.2)
- **`DuckBillAnchorResolver`**: Dynamically calculates the exact pixel coordinate of the bill/beak tip across standing, sitting, drooping, deep sleep, and chonky frames.
- **Pixel `Z` Glyphs**: 3 custom CRT cyan pixel matrices (`GLYPH_SNORE_Z_SMALL` $3	imes 3$, `GLYPH_SNORE_Z_MED` $4	imes 4$, `GLYPH_SNORE_Z_LARGE` $5	imes 5$).
- **Strict Particle Lifecycle**: Maximum 2–3 active snores, periodic gentle cadence ($2.2 \dots 3.2	ext{s}$), instant cleanup on waking, poke, breadcrumb, reset, or mode switch via `clearSleepFX()`.

### 2.8 Developer QA Tooling
- **Viewport Toggle**: `Stories → Story Preview → Viewport: Full Window / Viewport: MiniHUD`.
- **Playback Speeds**: `0.25x (Slow-Mo QA)`, `0.5x (Half Speed)`, `1x (Real Time)`, `5x (Fast QA)`, `10x (Ultra QA)`.
- **Transition QA & Finale QA Submenus**: Direct jumps to boundary thresholds ($19\% 	o 21\%$, etc.) and finale loops across all 5 stories.

---

## 3. UI/UX Changes

- Compact window mode (MiniHUD) upgraded to a full interactive companion habitat.
- Seamless window resizing and viewport toggling.

---

## 4. Animation & Visual Changes

- Compact prop sprites ($5	imes 5$ trail sign, $4	imes 4$ coffee cup, etc.).
- 7 canonical transition matrices in `Sprites.swift`.
- Girl Duck and Guard Duck redesigned sprite sets.
- Pixel `Z` snore glyph matrices.

---

## 5. Audio Changes

- Added `gymTick()`, `cameraSweepTick()`, `flagPlantFanfare()`, and `duckBurp()` procedural audio integrations.

---

## 6. Secrets & Easter Eggs

- MiniHUD clock glance moments (<10s) and full-stage completion dances.

---

## 7. Accessibility Changes

- Primary countdown digits guaranteed 100% boundary safety and zero overlap in MiniHUD.
- Reduced motion preference disables high-speed preview animations, particle bursts, and abrupt transitions.

---

## 8. Technical & Runtime Changes

- **`src/Graphics/CompactLayout.swift`**: Defines `CompactLayoutMetrics` zone geometry and dynamic time rendering styles.
- **`src/Engine/DuckStoryEngine.swift`**: Coordinates transitions, finale loops, and preview snapshots.
- **`src/Graphics/AccessoryAttachment.swift`**: `DuckBillAnchorResolver` implementation for anatomical sleep FX.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Viewport-owned effects (breadcrumbs, particles, speech, toast, ember budgets) are cleanly purged upon Full $\leftrightarrow$ MiniHUD transitions via `clearViewportOwnedEffects()`.
- Coordinator `finaleElapsedTime` advances continuously during MiniHUD finales to animate compact props.

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testWave7PrimaryTimeProtectedZoneZeroOverlap`: Verifies zero overlap between time area and Mini Stage across all window sizes.
2. `testWave7StopwatchLongValueFormattingNoCollision`: Verifies 5 dynamic scale levels fit `maxWidth`.
3. `testWave7MiniStageBoundaryClampingAndHitTesting`: Validates Mini Stage containment and isolated click handling.
4. `testRedesignedGirlDuckVisualProportionsAndSkullAnchor`: Validates Girl Duck $13	imes 10$ proportions and hairbow anchor.
5. `testRedesignedGuardDuckProportionsAndPivotTurn`: Validates Guard Duck pivot turn frame.
6. `testTimeDuckTransitionAndAnticipationFrames`: Validates all 7 transition matrices.
7. `testAllStoryMilestoneBoundaries`: Tests all 25 scene handoffs across all 5 stories without snapping.
8. `testEngineFinaleClockAdvancesAndRemainsBounded`: Simulates 6-hour finales across all 5 stories.
9. `testSleepFXClearSleepFXPurgesParticlesInstantly`: Verifies snore particle lifecycle and instant cleanup.

---

## 11. Documentation Requirements

- Document MiniHUD / Pocket Duck features, protected zone architecture, and developer QA menus in `README.md`.

---

## 12. Known Dependencies Between Features

- Mini Stage rendering depends on `CompactLayoutMetrics`.
- Snore FX depends on `DuckBillAnchorResolver`.

---

## 13. Explicit Completion Criteria

- [ ] MiniHUD displays large high-contrast timer digits with zero overlap from controls or companion.
- [ ] Mini Stage hosts living companion antics, feeding, Chonky mode, and compact stories.
- [ ] Girl Duck and Guard Duck render with canonical proportions and smooth pivot turns.
- [ ] All 5 Duck Stories play seamless transitions and repeatable resting finale loops.
- [ ] Pixel `Z` snores emit accurately from bill tip and clear on interaction.
- [ ] `./build.sh --test` passes 100% of test cases.
