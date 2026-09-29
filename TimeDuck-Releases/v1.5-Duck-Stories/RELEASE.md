# Official Release Specification: TimeDuck v1.5 — Duck Stories

- **Official Version**: `v1.5.0`
- **Release Name**: Duck Stories
- **Source Waves**: `Wave 6: Duck Stories` + `Wave 6.1: Living Scenes`
- **Status**: Ready for Implementation (Combined Major Release)

---

## 1. Release Purpose

TimeDuck v1.5 ("Duck Stories") introduces an internal procedural pixel-art narrative engine starring TimeDuck that quietly unfolds alongside active work and focus sessions. Incorporating Wave 6 (the five reference stories and theatrical architecture) and Wave 6.1 (continuous performance choreography, animated multi-frame props, physical mounting, and developer speed controls), this release transforms background companion waiting into living theatrical pixel shows.

### The Sacred Architectural Mandate:
> **STORIES OBSERVE TIME. STORIES NEVER OWN TIME.**
> `TimerEngine`, `StopwatchModel`, `PomodoroModel`, and wall-clock accuracy remain 100% authoritative and decoupled. Stories observe start, progress ($0.0 \dots 1.0$), milestone, pause, resume, completion, and reset events. If any part of the theatrical layer encounters an edge case or fails, TimeDuck's core timekeeper continues running flawlessly.

---

## 2. Complete Feature Set

### 2.1 The Five Reference Stories

1. **The Feast (Primary: Pomodoro Focus)**:
   - *Theme*: A continuous 5-stage feeding story where TimeDuck becomes progressively stuffed as work advances.
   - *Fullness Stages*:
     - Stage 0 ($0\%$): Normal TimeDuck eats Bread #1 ("FUEL ACQUIRED.").
     - Stage 1 ($20\%$): Slightly satisfied belly eats Bread #2 ("MORE BREAD?").
     - Stage 2 ($40\%$): Visible round belly eats Bread #3, pats belly ("VISIBLE BELLY.").
     - Stage 3 ($60\%$): Chunkier waddle eats Bread #4, loaf sit ("THIS SEEMS EXCESSIVE.").
     - Stage 4 ($80\%$): Very full unit eats Bread #5, suspicious glance ("I REGRET NOTHING.").
     - Stage 5 ($100\%$): ABSOLUTE UNIT. Belly wobbles, failed hop attempt, steam puff, procedural burp (`snd.duckBurp`), step-by-step digestion deflation, and closing payoff ("WE BOTH DID OUR PART.", "WORTH IT.").

2. **The Expedition (Primary: Long Countdown Timers $\ge 5	ext{m}$)**:
   - *Theme*: TimeDuck prepares for and climbs toward a mountain summit.
   - *Choreography*:
     - Scene 1 ($0\%$): Checks map (`DUCK_MAP_CHECK_A`), trail sign prop appears (`PROP_TRAIL_SIGN`), wrong-direction turnaround gag.
     - Scene 2 ($20\%$): Campfire flame animates across 4 flickering frames (`PROP_CAMPFIRE`). TimeDuck warms wings, pokes fire with stick (sparks fly!), cozy doze.
     - Scene 3 ($40\%$): Hops uphill onto Rock A, stumbles and wipes brow, investigates mystery rock, traverses to Rock B.
     - Scene 4 ($60\%$): High altitude wind lean into headwind, bandana tails flutter, determined march.
     - Scene 5 ($80-100\%$): Final summit push. Reaches peak, plants animated waving flag (`PROP_SUMMIT_FLAG`), cheer pose (`DUCK_SUMMIT_CHEER`), procedural fanfare (`snd.flagPlantFanfare`), and victory closure ("FLAG PLANTED. SUMMIT CLEAR.").

3. **Night Shift (Primary: Late Night Sessions $\ge 22:00$ or $\le 05:00$)**:
   - *Theme*: TimeDuck desperately attempts to stay awake during late-night work sessions.
   - *Choreography*:
     - Scene 1 ($0\%$): Sips steaming coffee mug (`PROP_COFFEE_CUP`), alert typing stance.
     - Scene 2 ($20\%$): Slow blinks, wide beak yawn (`DUCK_YAWN`), feather shake.
     - Scene 3 ($40\%$): Head droop (`DUCK_NIGHT_DROOP`), snaps awake with wide eyes, splashes water on face (`DUCK_NIGHT_FACE_SPLASH`), stacks second coffee cup (`PROP_COFFEE_STACK`).
     - Scene 4 ($60-80\%$): Shivers, wraps cozy blanket burrito (`DUCK_NIGHT_BLANKET_THROW`), 1s micro-nap, alarm tick, throws blanket off.
     - Scene 5 ($100\%$): Refreshed morning sunrise stretch and victory wake ("NIGHT DUTY CLEAR. WORTH IT.").

4. **The WOD (Workout Of the Day) (Primary: Stopwatch & Workouts)**:
   - *Theme*: TimeDuck visits a tiny procedural gym for a workout montage.
   - *Choreography*:
     - Scene 1 ($0\%$): Workout board prop (`PROP_WORKOUT_BOARD`), jumping jacks warmup (`DUCK_WOD_WARMUP_A/B`).
     - Scene 2 ($20\%$): **Physically mounted at $(x=72, y=48)$ on the Elliptical machine** (`PROP_ELLIPTICAL_FRAME`), pedaling feet in cadence, gym cadence ticks (`snd.gymTick`).
     - Scene 3 ($40\%$): **Mounted on Treadmill belt $(x=72, y=54)$** (`PROP_TREADMILL_FRAME`), running stride, flying sweat droplets.
     - Scene 4 ($60-80\%$): Dumbbell rack (`PROP_DUMBBELLS`), curls weights at $(x=65, y=56)$ (`DUCK_DUMBBELL_A/B`), struggles on rep 3.
     - Scene 5 ($100\%$): WOD Complete! Flexes bicep wings (`DUCK_WOD_FLEX`), "PERSONAL BEST: SURVIVED.", cleans up gym equipment.

5. **The Rescue (Primary: Long Timers & Focus)**:
   - *Theme*: Stealth-action comedy parody starring TimeDuck as a covert operative.
   - *Choreography*:
     - Act 1 ($0-20\%$): Infiltration. Tiptoes forward, drops into crouch behind metal crate (`PROP_METAL_CRATE`).
     - Act 2 ($20-40\%$): Security Cameras. Camera sweeps left/center/right (`PROP_SECURITY_CAMERA`), radar ticks (`snd.cameraSweepTick`), duck drops cardboard box disguise (`DUCK_STEALTH_BOX_DISGUISE`).
     - Act 3 ($40-60\%$): Guard Duck Patrol. Guard duck actor (`ACTOR_GUARD_DUCK_PATROL_A/B`) walks across. TimeDuck sneaks behind.
     - Act 4 ($60-80\%$): Girl Duck Encounter. Enters holding area, Girl Duck actor (`ACTOR_GIRL_DUCK_KICK`) kicks open ventilation grille (`PROP_FACILITY_VENT`)!
     - Act 5 ($80-100\%$): Escape. Warning beacon flashes (`PROP_SECURITY_LIGHT`), both ducks sprint toward the exit. Leap to freedom; Girl Duck drops golden breadcrumb payoff (`ACTOR_GIRL_DUCK_CHEER`, "BEST. MISSION. EVER.").

### 2.2 Secondary Actor Framework (`DuckStoryActor`)
- Lightweight actor system with independent pixel coordinate $(x, y)$, velocity, movement speed, and horizontal flip:
  - **Girl Duck**: Canonical TimeDuck proportions with magenta/pink hairbow (`m`, `p`) and rosy cheek blush.
  - **Guard Duck**: Security patrol cap (`k`) with navy visor and flashlight beam.

### 2.3 Animated Procedural Props Layer
- Multi-frame animated prop matrices:
  - `PROP_CAMPFIRE` (4 frames, flickering flame + embers)
  - `PROP_ELLIPTICAL_FRAME` (Pedal positions A & B)
  - `PROP_TREADMILL_FRAME` (Conveyor belt motion lines A & B)
  - `PROP_SECURITY_CAMERA` (Left, Center, Right sweep angles)
  - `PROP_SUMMIT_FLAG` (3 flapping wave frames)
  - `PROP_COFFEE_CUP` (2 steam curl frames)
  - `PROP_SECURITY_LIGHT` (On/Off alarm beacon pulse)

### 2.4 Living Scenes Continuous Performance Loops
- Continuous performance model: `SCENE → CONTINUOUS REPEATABLE PERFORMANCE → TRANSITION → NEXT SCENE`.
- Replaces static milestone waiting with active prop interaction and natural rest loops.

### 2.5 Story Selection & Developer Preview Tooling
- **Menu Bar Controls**: `Stories -> [Off | Auto (Recommended) | The Feast | The Expedition | Night Shift | The WOD | The Rescue]`, persisted via `td.storySelection`.
- **Developer Story Preview**:
  - Direct progress scrubbing: `0% | 20% | 40% | 60% | 80% | 100%`.
  - Speed Multipliers: `1x (Real Time)`, `5x (Fast QA)`, `10x (Ultra QA)`.
  - Preview affects **strictly the presentation layer** without touching `TimerEngine`.

---

## 3. UI/UX Changes

- Added `Stories` menu to macOS menu bar for selecting stories or auto-selection mode.
- Added developer preview submenus for manual inspection and QA scrubbing.

---

## 4. Animation & Visual Changes

- New secondary actor sprites: Girl Duck and Guard Duck matrices.
- 20+ story-specific duck poses defined in `Sprites.swift`.
- Multi-frame prop sprite matrices.

---

## 5. Audio Changes

- Added procedural story sound cues in `SoundEngine.swift`:
  - `flagPlantFanfare()`: Upward triumph arpeggio.
  - `gymTick()`: Mechanical equipment cadence click.
  - `cameraSweepTick()`: Soft high-frequency radar sweep pulse.

---

## 6. Secrets & Easter Eggs

- The Rescue stealth parody and Girl Duck breadcrumb drop serve as narrative rewards.

---

## 7. Accessibility Changes

- Story props and actors are positioned strictly within the duck habitat area to avoid obstructing timer numbers.
- Reduced motion setting suppresses rapid camera sweeps and high-velocity sweat/ember bursts.

---

## 8. Technical & Runtime Changes

- **`src/Engine/DuckStoryEngine.swift`**: Complete narrative engine coordinator managing story lifecycle, milestones, active actors, props, and preview snapshots.
- **`src/Views/TimeDuckView.swift`**: Renders story layer behind/around TimeDuck.
- **`src/App/AppDelegate.swift`**: Routes timer/pomodoro progress events to `DuckStoryEngine`.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Note on Mode Scoping (Stabilized in v1.7 / Wave 8.1): In initial v1.5 development, stories could be configured for Timer and Stopwatch modes. Wave 8.1 subsequently stabilized user experience by scoping default story auto-selection strictly to Pomodoro focus sessions to preserve minimalist stopwatch/timer workflows.

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testStoryRegistrationAndAutoSelection`: Verifies story registry and auto-selection resolution.
2. `testStoryMilestoneOrderingAndProgression`: Verifies normalized progress ($0.0 \dots 1.0$) triggers correct milestones.
3. `testTheFeastFullnessAndDigestion`: Verifies 5-stage fullness, belly wobbles, and burp deflation.
4. `testTheExpeditionPropsAndFlagFanfare`: Verifies trail props, campfire, and summit celebration.
5. `testNightShiftLocalClockEligibility`: Verifies 22:00–05:00 window detection and coffee stack props.
6. `testTheWodGymMachineChoreography`: Verifies elliptical, treadmill, dumbbell sequences and flex finish.
7. `testTheRescueActorsAndGrilleKick`: Verifies Girl Duck, Guard Duck, camera sweep, and escape.
8. `testMultiFramePropAnimationCycling`: Verifies multi-frame prop ticks.
9. `testStoryIsolationFromTimerEngine`: Guarantees preview scrubbing and story errors never alter timer models.

---

## 11. Documentation Requirements

- Document the 5 Duck Stories, auto-selection behavior, and developer preview shortcuts in `README.md`.

---

## 12. Known Dependencies Between Features

- Story prop rendering depends on CRT palette mapping.
- Secondary actors depend on `AccessoryAttachment` anchor coordinates.

---

## 13. Explicit Completion Criteria

- [ ] All 5 Duck Stories progress smoothly across session milestones $0\% \dots 100\%$.
- [ ] Multi-frame props animate their flickering flames, treadmill belts, and waving flags.
- [ ] Girl Duck and Guard Duck render with accurate TimeDuck proportions and distinct styling.
- [ ] Menu bar story selector and developer preview speed multipliers ($1	imes, 5	imes, 10	imes$) function reliably.
- [ ] `./build.sh --test` passes 100% of test cases.
