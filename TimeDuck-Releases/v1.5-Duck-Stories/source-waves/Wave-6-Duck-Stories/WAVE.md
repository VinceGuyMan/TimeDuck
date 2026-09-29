# 🌊 Wave 6 — Duck Stories

## 🦆 Overview & Theatrical Architecture

**Wave 6: Duck Stories** introduces an internal procedural pixel-art narrative engine starring TimeDuck that quietly unfolds alongside real focus, timer, and stopwatch sessions.

A Duck Story is a miniature procedural pixel-art show performed by TimeDuck:
- It progresses deterministically with normalized session progress ($0.0 \dots 1.0$).
- It incorporates expressive temporary poses, procedural props, minimal scenery, lightweight secondary actors (Girl Duck, Guard Ducks), sound cues, and rich situation-aware dialogue variants.
- It is 100% procedurally rendered with TimeDuck's established GBC/PS1 pixel architecture with zero video playback, zero external frameworks, and zero asset bloat.

### The Sacred Architectural Rule:
> **STORIES OBSERVE TIME. STORIES NEVER OWN TIME.**
> `TimerEngine`, `StopwatchModel`, `PomodoroModel`, and wall-clock time accuracy remain 100% authoritative and decoupled. Stories observe start, progress, milestone, pause, resume, completion, and reset events. If any part of the story layer encounters an edge case or fails, TimeDuck's core timekeeper continues running flawlessly.

---

## 🎭 The Five Reference Stories

### 1. The Feast (Primary: Pomodoro Focus)
- **Concept**: A 5-stage feeding story where TimeDuck becomes progressively stuffed as work advances.
- **Fullness Stages**:
  - Stage 0 ($0\%$): Normal TimeDuck eats Bread #1. ("FUEL ACQUIRED.")
  - Stage 1 ($20\%$): Slightly satisfied belly eats Bread #2. ("MORE BREAD?")
  - Stage 2 ($40\%$): Visible round belly eats Bread #3. ("VISIBLE BELLY.")
  - Stage 3 ($60\%$): Chunkier waddle eats Bread #4. ("THIS SEEMS EXCESSIVE.")
  - Stage 4 ($80\%$): Very full unit eats Bread #5. ("I REGRET NOTHING.")
  - Stage 5 ($100\%$): ABSOLUTE UNIT. Focus complete, belly wobble, steam puff, procedural burp (`snd.duckBurp`), step-by-step digestion deflation, and closing payoff ("WE BOTH DID OUR PART.", "WORTH IT.").

### 2. The Expedition (Primary: Long Countdown Timers $\ge 5	ext{m}$)
- **Concept**: TimeDuck prepares for and climbs toward a mountain summit.
- **Progression**:
  - $0\%$: Checks pixel map (`DUCK_MAP_CHECK_A`), trail sign prop appears (`PROP_TRAIL_SIGN`). ("EXPEDITION COMMENCED.")
  - $20\%$: Hiking waddle, campfire prop in background (`PROP_CAMPFIRE`). ("STEADY MARCH.")
  - $40\%$: Mountain climb, investigates mystery rock. ("THAT ROCK LOOKED IMPORTANT.")
  - $60\%$: High ridge, wind effect, checks map (upside down!). ("MAP WAS UPSIDE DOWN.")
  - $80\%$: Final summit push. ("SUMMIT IN SIGHT!")
  - $100\%$: Plants summit flag (`PROP_SUMMIT_FLAG`), cheer pose (`DUCK_SUMMIT_CHEER`), procedural fanfare (`snd.flagPlantFanfare`), and victory closure ("FLAG PLANTED. SUMMIT CLEAR.").

### 3. Night Shift (Primary: Late Night Sessions $\ge 22:00$ or $\le 05:00$)
- **Concept**: TimeDuck desperately attempts to remain awake while the user works late into the night.
- **Progression**:
  - $0\%$: Sips steaming coffee mug (`PROP_COFFEE_CUP`), alert stance. ("NIGHT OPERATIONS.")
  - $20\%$: Slower blinks, big yawn (`DUCK_YAWN`), shakes feathers awake. ("THAT WAS A LONG BLINK.")
  - $40\%$: Head droop (`DUCK_NIGHT_DROOP`), snaps awake, stacks second coffee cup (`PROP_COFFEE_STACK`). ("COFFEE IS A VEGETABLE.")
  - $60\%$: Splashes water on face (`DUCK_NIGHT_FACE_SPLASH`), paces back and forth. ("EXTREMELY AWAKE.")
  - $80\%$: 1-second micro-nap, snaps awake, throws blanket (`DUCK_NIGHT_BLANKET_THROW`). ("I WAS RESTING MY EYES.")
  - $100\%$: Collapses into brief 1s snooze, wakes up refreshed ("NIGHT DUTY CLEAR. WORTH IT."), cleans up props.

### 4. The WOD (Workout Of the Day) (Primary: Stopwatch & Workouts)
- **Concept**: TimeDuck goes to a tiny procedural gym and completes his daily workout montage.
- **Progression**:
  - $0\%$: Workout chalkboard prop (`PROP_WORKOUT_BOARD`), jumping jacks warmup (`DUCK_WOD_WARMUP_A/B`). ("TODAY'S WOD: SURVIVE.")
  - $20\%$: Machine 1 — Elliptical machine frame (`PROP_ELLIPTICAL_FRAME`), pedaling feet (`DUCK_ELLIPTICAL_A/B`), mechanical cadence clicks (`snd.gymTick`). ("WHY GOES NOWHERE?", "DISTANCE: EMOTIONAL.")
  - $40\%$: Machine 2 — Treadmill sprint (`PROP_TREADMILL_FRAME`, `DUCK_TREADMILL_A/B`), flying sweat pixels. ("CARDIO WAS A MISTAKE.")
  - $60\%$: Machine 3 — Dumbbell rack (`PROP_DUMBBELLS`), dumbbell curls (`DUCK_DUMBBELL_A/B`). ("ONE MORE REP.")
  - $80\%$: Machine 4 — Cable burnout / final sprint. ("LEG DAY IS EVERY DAY WHEN YOU WADDLE.")
  - $100\%$: WOD Complete! Flexes bicep wings (`DUCK_WOD_FLEX`), "PERSONAL BEST: SURVIVED.", cleans up gym equipment.

### 5. The Rescue (Primary: Long Timers & Focus)
- **Concept**: An original stealth-action comedy parody starring TimeDuck as a tiny covert operative.
- **Five Acts**:
  - Act 1 ($0-20\%$): Infiltration. Approaches facility, stealth crouch (`DUCK_STEALTH_CROUCH`), metal crate prop (`PROP_METAL_CRATE`). ("STEALTH LEVEL: BIRD.")
  - Act 2 ($20-40\%$): Security Cameras. Camera sweeps left/right (`PROP_SECURITY_CAMERA_LEFT`), soft radar sweep ticks (`snd.cameraSweepTick`), duck freezes or hides in cardboard box (`DUCK_STEALTH_BOX_DISGUISE`). ("NO ONE SAW THAT.")
  - Act 3 ($40-60\%$): Guard Duck Patrol. Guard duck actor (`ACTOR_GUARD_DUCK_PATROL_A/B`) walks across. TimeDuck sneaks behind. ("QUACK AUTH? ...QUACK. OK.")
  - Act 4 ($60-80\%$): Girl Duck Encounter. Enters holding area, Girl Duck actor (`ACTOR_GIRL_DUCK_KICK`) kicks open the ventilation grille (`PROP_FACILITY_VENT`)! ("TOOK YOU LONG ENOUGH.")
  - Act 5 ($80-100\%$): Escape. Warning beacon flashes (`PROP_SECURITY_LIGHT`), both ducks sprint toward the exit. At $100\%$, dramatic leap to exterior freedom; Girl Duck drops fresh golden breadcrumb for TimeDuck (`ACTOR_GIRL_DUCK_CHEER`, "BEST. MISSION. EVER.").

---

## 👥 Secondary Actor Architecture

The `DuckStoryActor` struct provides a lightweight actor framework:
- Independent pixel coordinate position $(x, y)$, movement vector, move speed, and orientation flip.
- **Girl Duck**: Retains authentic TimeDuck proportions with magenta/pink bow accent (`m`, `p`) and cheerful expressive eyes.
- **Guard Duck**: Security patrol cap (`k`) with navy visor and flashlight beam.

---

## 🏛️ Procedural Scenery & Prop Layer

Procedural props conform to minimal grid matrices and render with contextual CRT palettes:
- `PROP_TRAIL_SIGN`, `PROP_CAMPFIRE`, `PROP_SUMMIT_FLAG`
- `PROP_COFFEE_CUP`, `PROP_COFFEE_STACK`
- `PROP_WORKOUT_BOARD`, `PROP_ELLIPTICAL_FRAME`, `PROP_TREADMILL_FRAME`, `PROP_DUMBBELLS`
- `PROP_SECURITY_CAMERA_LEFT/RIGHT`, `PROP_FACILITY_VENT`, `PROP_METAL_CRATE`, `PROP_SECURITY_LIGHT`

---

## 🎛️ Story Selection & Developer Preview

- **Story Submenu**: Menu bar `Stories -> [Off | Auto (Recommended) | The Feast | The Expedition | Night Shift | The WOD | The Rescue]`. Persisted via `td.storySelection`.
- **Auto Logic**:
  - Late Night ($\ge 22:00$ or $\le 05:00$) $\rightarrow$ Night Shift
  - Stopwatch $\rightarrow$ The WOD
  - Long Timer ($\ge 15	ext{m}$) $\rightarrow$ The Expedition or The Rescue
  - Pomodoro $\rightarrow$ The Feast
- **Developer Story Preview**: `Stories -> Story Preview -> [Story Name] -> [0% | 20% | 40% | 60% | 80% | 100%]`. Feeds synthetic progress directly to the presentation layer for rapid QA without modifying timer models.

---

## 🧪 Automated Testing Verification

All 111 unit and integration tests passing:
```bash
./build.sh --clean && ./build.sh --test
```
- Story registration and menu selection persistence
- Auto selection context resolution logic
- Normalized progress scaling and milestone ordering
- Missed-milestone wake/sleep recovery
- Timer isolation and precision math independence
- The Feast 5-stage fullness and digestion cycle
- The Expedition trail props and summit celebration
- Night Shift local clock eligibility and coffee stacks
- The WOD gym machine sequence (elliptical, treadmill, dumbbells)
- The Rescue 5-act progression, secondary actors, and bread payoff
- Secondary actor lifecycle, movement physics, and snap-to-target
- Living Wardrobe dynamic head anchors across all 20+ story poses
- Story cleanup contract on reset, mode switch, and completion
- Wave 6.1 Multi-frame prop animation cycling
- Wave 6.1 Continuous performance loops and physical contact mounting
- Wave 6.1 Accelerated story preview speed multipliers ($1	imes, 5	imes, 10	imes$)

---

## 🎬 Wave 6.1 — Living Scenes & Continuous Performance Choreography

Wave 6.1 evolves Duck Stories from static milestone tableaux into **living, continuous theatrical scenes**:
`SCENE → CONTINUOUS REPEATABLE PERFORMANCE → TRANSITION → NEXT SCENE`

### 1. The Core Transformation
* **Previously**: Stories placed a static prop or milestone pose and sat idle between milestones.
* **Now**: TimeDuck actively performs with every prop in the story world using continuous, repeatable micro-behavior loops with weighted variations and natural rests.

### 2. Scene-by-Scene Living Choreography
* **The Expedition**:
  - *Scene 1 (Trailhead)*: Walks to trail sign, inspects sign facing left, pulls out map, turns map upside down, marches right, wrong-direction turnaround gag.
  - *Scene 2 (Campfire)*: Campfire flame animates across 4 flickering frames. TimeDuck sits in contact range, warms wings, pokes fire with stick (sparks fly!), eats ration, cozy doze, walks around camp.
  - *Scene 3 (The Climb)*: Hops uphill onto Rock A, stumbles and recovers with feather wipe, inspects suspicious rock, pushes onward to Rock B.
  - *Scene 4 (Final Ascent)*: High altitude wind lean into headwind, bandana tails react, slips back and catches footing, determined march.
  - *Scene 5 (Summit)*: Reaches summit, pants, plants animated waving flag, fanfare sounds, poses for imaginary summit photo snapshot, admires view.
* **The Feast**:
  - *Continuous Feeding*: Bread appears, duck walks to bread, beak connects with exact coordinate, pecks and swallows.
  - *Stage 1*: Energetic waddles.
  - *Stage 2*: Satisfied waddle, belly pat.
  - *Stage 3*: Round belly waddle, looks down at tummy with curiosity, loaf sit.
  - *Stage 4*: Heavy waddle, suspicious of extra bread, rests.
  - *Stage 5 (Absolute Unit)*: Belly wobble, failed adorable hop attempt, exhausted flap, existential stare at user.
  - *Completion*: Full digestion mini-show with belly wobble $	o$ steam puff $	o$ procedural burp $	o$ deflation.
* **Night Shift**:
  - *Scene 1*: Walks to steaming coffee cup, sips, paces alert.
  - *Scene 2*: Slow blinks, big yawn, feather shake, stares into cup.
  - *Scene 3*: Head droop sleep, snaps awake with wide eyes, splashes water on face, paces.
  - *Scene 4*: 1s blanket micro-nap, throws blanket away, drinks coffee.
  - *Scene 5*: Final victory stretch and refreshed morning wake.
* **The WOD**:
  - *Scene 1*: Inspects chalkboard, jumping jacks warmup, wing stretches.
  - *Scene 2 (Elliptical)*: **Physically mounted at $(x=72, y=48)$ on the machine**. Pedals and duck feet cycle in cadence, gym tick SFX.
  - *Scene 3 (Treadmill)*: **Mounted on moving belt $(x=72, y=54)$**. Sprinting stride, sweat droplets flying.
  - *Scene 4 (Dumbbells)*: Picks up dumbbells at $(x=65, y=56)$, curls them up and down, struggles on rep 3.
  - *Scene 5 (Flex)*: Bicep wing flex, celebrates.
* **The Rescue**:
  - *Scene 1 (Infiltration)*: Tiptoes forward, drops into crouch behind crate, peeks corner.
  - *Scene 2 (Cameras)*: Security camera sweeps left/center/right. When camera away $	o$ dashes. When camera approaches $	o$ hides inside cardboard box disguise! When camera passes $	o$ peeks out.
  - *Scene 3 (Guards)*: Guard Duck patrols back and forth. TimeDuck hides behind crate, matches guard's pace sneaking behind, freezes when guard pauses.
  - *Scene 4 (Girl Duck)*: Girl Duck kicks vent open, leaps out, greets TimeDuck.
  - *Scene 5 (Escape)*: Warning beacon flashes, both sprint across facility, leap to freedom, golden breadcrumb drop payoff.

### 3. Animated Props Layer
Props now support multi-frame animations with custom intervals:
* `PROP_CAMPFIRE` (4 frames, flickering flame + embers)
* `PROP_ELLIPTICAL_FRAME` (Pedal positions A & B)
* `PROP_TREADMILL_FRAME` (Belt motion lines A & B)
* `PROP_SECURITY_CAMERA` (Left, Center, Right sweep angles)
* `PROP_SUMMIT_FLAG` (3 flapping wave frames)
* `PROP_COFFEE_CUP` (2 steam curl frames)
* `PROP_SECURITY_LIGHT` (On/Off alarm beacon pulse)

### 4. Developer Story Preview & Speed Controls
The Status Item and Main Menu `Stories -> Story Preview` now include:
* **Speed Multipliers**: `Speed: 1x (Real Time)`, `Speed: 5x (Fast QA)`, `Speed: 10x (Ultra QA)`.
* **Scene Checkpoints**: Jump directly to any scene in any story.
* Accelerations and preview progress apply **strictly to the theatrical layer** and never alter or control `TimerEngine`.
