# WAVE 7 — LIVING MINIHUD / POCKET DUCK

**Status:** IMPLEMENTED / UNRELEASED  
**Branch:** `duckdrops-dev`  
**Target:** TimeDuck DuckDrops Development Worktree  

---

## 1. Executive Summary

Wave 7 brings TimeDuck's compact window mode (**MiniHUD / Pocket Duck**) fully to life while strictly enforcing the supreme design mandate: **THE TIMER IS THE STAR**. 

In earlier versions, compact mode was a minimal, relatively static utility widget. Wave 7 establishes a strict mathematical zone system that guarantees the primary time digits are always the undisputed visual hero of the interface, while transforming the right-side companion area into a dedicated, boundary-clamped **Mini Stage** hosting micro-animations, living companion behaviors, poke escalation, crumb feeding, Chonky states, clock drama acknowledgment, and purpose-built compact choreography for all five Duck Stories.

---

## 2. Visual Hierarchy & Protected Zone Architecture

### The Non-Negotiable Visual Hierarchy
1. **Primary Time Display**: Maximum scale, maximum contrast, stable placement, phosphor persistence.
2. **Current Mode / State Badge**: Subordinate pill (`FOCUS`, `BREAK`, `TIMER`, `SW`, `PAUSED`) positioned in top-left state zone.
3. **TimeDuck Companion / Mini Stage**: Dedicated right-hand column separated by structural rule, housing living behaviors without bleeding.
4. **Essential Controls**: Restrained, quiet action buttons (`START`, `PAUSE`, `RESUME`, `SKIP`, `+1M`, `LAP`, `RESET`, `DONE`) with hover-triggered illumination.
5. **Story / Effect / Decoration**: Micro-props and particle effects strictly clipped to Mini Stage bounds `[duckX, duckX + duckW - 1]`.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ [FOCUS] [●]                                    [🔉] [⤢] │                   │
│                                                         │    Mini Stage     │
│   24:59                                   [PAUSE] [SKIP]│     TimeDuck      │
│                                                         │    (Living Show)  │
│ ────────────────────────────────────────────────────────┴───────────────────│
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
└─────────────────────────────────────────────────────────────────────────────┘
```

### Zone Geometry (`CompactLayoutMetrics`)
- **Primary Time Zone (`timeAreaRect`)**: $x=4$ to $x=	ext{goX}-3$, $y=11..27$. Absolutely protected from duck sprites, props, and buttons.
- **State Zone (`modePillRect`)**: $x=4$, $y=2..9$. Displays active mode and phase with semantic color tinting.
- **Title Control Zone (`soundRect`, `unminiRect`)**: $y=2..9$, right-aligned before Mini Stage rule.
- **Action Control Zone (`goRect`, `secRect`)**: $x=	ext{goX}..	ext{secX}+	ext{secW}$, $y=12..25$. Clear, responsive, quiet buttons.
- **Mini Stage Zone (`miniStageRect`)**: $x=	ext{duckX}..	ext{duckX}+	ext{duckW}-1$, $y=	ext{duckY}..	ext{duckY}+	ext{duckH}-1$. Dedicated canvas with background fill (`Pal.bgDeep`) and boundary rule (`Pal.grid`).
- **Progress Zone (`progressBarRect`)**: $x=3..	ext{gridW}-4$, $y=	ext{gridH}-3..	ext{gridH}-2$.

---

## 3. Clock Fitting & Long Stopwatch Protection

To guarantee that long stopwatch values (e.g. `12:47:19.85` or `1:05:42.10`) never truncate, collide, or bleed into adjacent zones, `CompactLayoutMetrics.resolveTimeRenderStyle` implements 5 dynamic scale levels:
1. `heroLarge`: Standard $2	imes$ hero font for typical mm:ss countdowns.
2. `heroWithSmallFrac`: $2	imes$ hero font for main digits + $1	imes$ small font for centiseconds.
3. `smallScale2`: $2	imes$ small font for hour-spanning stopwatch values (`1:05:42.10`).
4. `heroScale1`: $1	imes$ hero font for long multi-digit strings.
5. `smallScale1`: $1	imes$ small font fallback ensuring 100% boundary safety on narrow custom widths.

---

## 4. Living Mini Stage Companion Behaviors

1. **Clock Drama Acknowledgment**:
   - When remaining time drops below 10 seconds, TimeDuck glances toward the clock (`DUCK_GLANCE_CLOCK`) or points excitedly at the digits (`DUCK_POINT_CLOCK`).
   - When the timer completes, TimeDuck engages in full-stage celebration (`DUCK_YAY_A`/`DUCK_YAY_B`).
   - When paused, TimeDuck adopts a relaxed loaf posture.
2. **Interactive Poke Escalation**:
   - **Tier 1 (Pokes 1–2)**: Curious head tilt and happy response.
   - **Tier 2 (Pokes 3–4)**: Suspicious side-eye, dodge hop, or feather ruffle.
   - **Tier 3 (Pokes 5+)**: Tantrum, feigned collapse, or white-flag surrender.
3. **Pocket Feeding & Chonky Duck**:
   - Breadcrumbs spawn with explicit beak-alignment inside the Mini Stage.
   - Chonky Stages 1 through 5, belly wobble, and post-session steam burp are fully supported within compact dimensions.
4. **Living Wardrobe MiniHUD Compliance**:
   - All 15 hats and tactical bandanas dynamically anchor to duck pose coordinates inside Mini Stage, clamped to prevent boundary overflow.
5. **Micro-Dialogue & Particle Clipping**:
   - Speech bubbles fit to available Mini Stage width (`NOM.`, `SHHH.`, `GAINS.`, `AWAKE.`, `SUMMIT!`).
   - All particle emissions (steam, sweat, hearts, embers, confetti) are clipped strictly to `miniStageRect`.

---

## 5. Duck Stories — MiniHUD Editions

All 5 Duck Stories feature purpose-built compact choreography:
- **The Feast**: Miniature feeding peck cycles, progressive chonk enlargement (Stages 1–5), belly wobbles, and digestive steam puffs.
- **The Expedition**: Micro trail sign ($5	imes 5$), animated campfire flames ($5	imes 4$), rock waddle, storm lean, and animated summit flag ($5	imes 6$).
- **Night Shift**: Steaming micro coffee mug ($4	imes 4$), heavy droop eyelids, splash awakenings, and blanket burrito micro-nap.
- **The WOD**: Mounted pedaling on micro elliptical ($8	imes 7$), running on animated treadmill belt ($9	imes 4$), dumbbell curls ($5	imes 3$), and flex victory.
- **The Rescue**: Micro metal crate ($6	imes 5$) stealth peek, animated camera beam sweep, single Guard Duck patrol ($9	imes 8$), and Girl Duck ($9	imes 8$) reunion with magenta bow.

---

## 6. Developer Story Preview Viewport Toggle

The Developer Story Preview system now includes full viewport toggling:
- **Menu Path**: `Stories → Story Preview → Viewport: Full Window / Viewport: MiniHUD`
- **Instant Testing**: Switch between Full Window and MiniHUD while scrubbing through story milestones at $1	imes, 5	imes, 10	imes$ speed multipliers without affecting the authoritative timer engines.

---

## 7. Verification & Automated Test Coverage

- **Total Passing Automated Tests**: **121 / 121** across all test suites in **0.147s**.
- **Dedicated Wave 7 Test Suite (`Tests/TimeDuckTests/Wave7Tests.swift`)**:
  - `testWave7PrimaryTimeProtectedZoneZeroOverlap`: Mathematical guarantee of zero overlap between Time Area and all controls / Mini Stage across all window sizes.
  - `testWave7StateZoneSubordinateIndicators`: Validates mode and phase pill tags across all states.
  - `testWave7StopwatchLongValueFormattingNoCollision`: Verifies centisecond and hour stopwatch formatting styles fit `maxWidth`.
  - `testWave7MiniStageBoundaryClampingAndHitTesting`: Validates Mini Stage containment and isolated click handling.
  - `testWave7MiniHUDPokeEscalation`: Validates poke escalation tiers.
  - `testWave7MiniHUDFeedingAndChonkyBounds`: Validates all Chonky stage sprites fit Mini Stage bounds.
  - `testWave7AllFiveCompactStoriesMicroPropsAndChoreography`: Validates all 5 compact stories run without errors.
  - `testWave7ClockAcknowledgmentMoments`: Validates clock glance/point sprite matrices.
  - `testWave7ReducedMotionMiniHUDCompliance`: Validates accessibility mode.
  - `testWave7AuthoritativeTimerIsolationAndPreviewIndependence`: Validates model isolation during high-speed previews.
