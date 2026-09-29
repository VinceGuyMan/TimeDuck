# 🌊 Wave 7.2: Story Finales + Seamless Scene Handoffs + Sleep FX Polish

## Candidate Version
`v1.7.2-dev`

## Overview & Purpose
Wave 7.2 polishes TimeDuck's theatrical Duck Stories and presentation polish into an organic, seamless experience. It addresses the three targeted presentation problems identified during visual QA:
1. **Dedicated Post-Completion Finale Loops**: Each Duck Story now features a unique post-completion celebration payoff followed by a repeatable, seamless resting finale loop that plays indefinitely while the completed timer remains on screen.
2. **Seamless Scene Handoffs & Boundary Snapping Elimination**: Fixed awkward frame jumps and pose resetting at 1-minute milestones ($0.20, 0.40, 0.60, 0.80$) through anticipation handoffs, persistent orientation tracking, and decoupled scene clocks.
3. **Anatomically Grounded Bill Snore FX**: Replaced crude blue dots with classic pixel-art `Z` particles ($3\times 3, 4\times 4, 5\times 5$) dynamically anchored to TimeDuck's bill tip via `DuckBillAnchorResolver`, with strict particle lifecycle and zero UI overlap.

---

## 🎭 The 5 Story Finales

### 1. The Feast — Digestion Payoff & Satisfied Resting Loop
- **Payoff (0.0 ... 4.0s)**: TimeDuck pauses in Absolute Unit state ($5 \to 0$), belly wobbles, burps once with steam puffs, and digests step-by-step back to normal proportions.
- **Repeatable Resting Finale Loop (10s cycle)**:
  - `0.0 ... 2.5s`: Calm standing breath (`DUCK_BASE`).
  - `2.5 ... 4.5s`: Content head tilt & gentle belly pat (`DUCK_HEAD_TILT`).
  - `4.5 ... 6.5s`: Sits comfortably on pond ground (`DUCK_SIT_TRANSITION`).
  - `6.5 ... 8.5s`: Small satisfied tail wag (`DUCK_IDLE_WAG`).
  - `8.5 ... 10.0s`: Resting breath, occasional "WORTH IT." on interaction.

### 2. The Expedition — Summit Flag & Panoramic Horizon Loop
- **Payoff (0.0 ... 4.0s)**: TimeDuck reaches the summit peak, plants the summit flag once with fanfare audio, and cheers.
- **Repeatable Resting Finale Loop (12s cycle)**:
  - `0.0 ... 3.0s`: Standing proud posture surveying the panoramic mountain view (`DUCK_PROUD`).
  - `3.0 ... 5.5s`: Investigates the waving summit flag beside it (`DUCK_INVESTIGATE_B`).
  - `5.5 ... 8.0s`: Sits down on summit rock to enjoy the vista (`DUCK_SIT_TRANSITION`).
  - `8.0 ... 10.5s`: Victorious wing stretch (`DUCK_WING_STRETCH`).
  - `10.5 ... 12.0s`: Calm standing summit posture beside the gently waving flag.

### 3. Night Shift — Shift Complete Relief & Peaceful Sleep Loop
- **Payoff (0.0 ... 3.0s)**: Checks timer, experiences visible relief ("SHIFT COMPLETE."), and collapses onto floor.
- **Repeatable Resting Finale Loop (8s cycle)**:
  - `0.0 ... 4.0s`: Deep peaceful sleep pose (`DUCK_SLEEP_DEEP`).
  - `4.0 ... 6.5s`: Sleepy feather twitch / gentle breathing rise (`DUCK_NIGHT_DROOP`).
  - `6.5 ... 8.0s`: Returns to deep sleep, emitting gentle pixel `Z` snores from beak tip.

### 4. The WOD — Cooldown Celebration & Resting Gym Loop
- **Payoff (0.0 ... 3.5s)**: Completes final rep, catches breath, checks timer, celebrates ("WORKOUT COMPLETE.").
- **Repeatable Resting Finale Loop (10s cycle)**:
  - `0.0 ... 2.5s`: Victorious bicep flex (`DUCK_WOD_FLEX`).
  - `2.5 ... 5.0s`: Relaxes, wipes brow, drinks water (`DUCK_SWALLOW`).
  - `5.0 ... 7.5s`: Sits on gym mat to rest legs (`DUCK_SIT_TRANSITION`).
  - `7.5 ... 10.0s`: Stands proud and energized (`DUCK_PROUD`).

### 5. The Rescue — Freedom Duo Living Tableau
- **Payoff (0.0 ... 3.5s)**: Coordinated leap and landing outside the security facility, confirming safety.
- **Repeatable Resting Finale Loop (12s cycle)**:
  - `0.0 ... 3.0s`: Girl Duck and TimeDuck stand side-by-side in freedom, gazing at each other (`ACTOR_GIRL_DUCK_NOTICE` + `DUCK_HEAD_TILT`).
  - `3.0 ... 6.0s`: Synchronized tail wag & gentle breathing (`ACTOR_GIRL_DUCK_IDLE_B` + `DUCK_IDLE_WAG`).
  - `6.0 ... 9.0s`: Girl Duck cheers (`ACTOR_GIRL_DUCK_CHEER_B`) while TimeDuck happily pecks breadcrumbs (`DUCK_PECK_B` / `DUCK_SWALLOW`).
  - `9.0 ... 12.0s`: Both stand in calm, victorious companionship (`ACTOR_GIRL_DUCK_BASE` + `DUCK_PROUD`).

---

## 🪟 MiniHUD / Pocket Duck Finale Adaptation
- Mini Stage seamlessly displays dedicated compact finale props and resting poses (`PROP_MINI_SUMMIT_FLAG_A/B`, `ACTOR_MINI_GIRL_DUCK_A`, etc.).
- Primary time and completed "DONE" state remain the unquestioned visual hero with zero overlap.
- Snore particles in MiniHUD are strictly clamped within Mini Stage boundaries `(m.duckX ..< m.duckX + m.duckW)`.

---

## 💤 Anatomically Grounded Sleep FX
- **`DuckBillAnchorResolver`**: Dynamically calculates the exact pixel coordinate of the bill/beak tip across standing, sitting, drooping, deep sleep, and chonky frames for normal and flipped orientations.
- **Pixel `Z` Glyphs**: 3 custom pixel matrices (`GLYPH_SNORE_Z_SMALL` $3\times 3$, `GLYPH_SNORE_Z_MED` $4\times 4$, `GLYPH_SNORE_Z_LARGE` $5\times 5$) rendered in CRT cyan.
- **Strict Lifecycle**: Maximum 2–3 active snores, periodic gentle cadence ($2.2 \dots 3.2\text{s}$), instant cleanup upon waking, poke, breadcrumb, mode switch, timer reset, or alarm dismiss via `clearSleepFX()`.

---

## 🛠️ Developer QA Tooling
- **`Stories → Story Preview → Transition QA`**: Quick-access submenu for jumping to boundary thresholds ($19\% \to 21\%, 39\% \to 41\%, 59\% \to 61\%, 79\% \to 81\%, 99\% \to 100\%$) across all 5 stories.
- **`Stories → Story Preview → Finale QA`**: Direct menu trigger for previewing the post-completion finale and resting loops of all 5 stories.

---

## 🧪 Verification & Test Suite
- Automated test runner: **146 tests passed (0 failures)**.
- Full test suite: `Tests/TimeDuckTests/Wave7_2Tests.swift` registered in `Tests/TestRunner.swift`.
