# Official Release Specification: TimeDuck v1.4 — The Living Duck Update

- **Official Version**: `v1.4.0`
- **Release Name**: The Living Duck Update
- **Source Waves**: `Wave 4: Living Wardrobe` + `Wave 5: Living Duck`
- **Status**: Ready for Implementation (Combined Major Release)

---

## 1. Release Purpose

TimeDuck v1.4 ("The Living Duck Update") is a foundational personality, interaction, animation, and presentation overhaul. Combining Wave 4 (physical costume attachment and accessory dynamics) and Wave 5 (autonomous companion life, escalating poke physics, feeding mechanics, Chonky mode, 450+ situational quips, procedural sound synthesis, and CRT startup splash), this release makes TimeDuck feel genuinely alive while strictly preserving the mathematical authority and accuracy of the core timer engines.

### Sacred Visual Rule:
> **DO NOT REDESIGN THE DUCK.**
> All 25+ new poses, temporary expressions, and squash/stretch frames strictly preserve TimeDuck's established body proportions, face silhouette, golden bill, pixel grid matrix ($13	imes 10$), and nostalgic Game Boy Color / PS1-era aesthetic.

---

## 2. Complete Feature Set

### 2.1 Physical Living Wardrobe Attachment (`src/Graphics/AccessoryAttachment.swift`)
- **`DuckHeadAnchor` & `DuckAnchorResolver`**:
  - Dynamically inspects the active duck sprite matrix to calculate the true skull crown coordinate `(headX, headY)`.
  - Sinks 1px on breathing (`DUCK_IDLE_B`), drops 1px on waddle strides (`DUCK_RUN_B`), sinks 2px on cozy sleep (`DUCK_SLEEP_DEEP`) and tactical crouch (`DUCK_TACTICAL`), drops 3px and shifts right 1px on floor pecks (`DUCK_PEEK_B`), and tilts forward on head tilts (`DUCK_LOOK_UP`, `DUCK_PEEK_B`).
  - Detects turned-head backward facing poses (`DUCK_LOOK_BACK`) and mirrors accessories horizontally.
  - Dynamically anchors all 15 hats, caps, and bandanas across all 25+ poses with zero mid-air floating or detachment.
- **Refined Tactical Bandanas**:
  - Low-profile crown keeping duck skull visible (`...kdyyy.....`).
  - Dense forehead wrap band directly above eye line (`.kkykddwddk..`).
  - Tied knot at skull rear (columns 1–2).
  - Dual asymmetrical loose tails: upper tail (3px, `kdd`) and lower tail (2px, `.kk`).
  - Secondary motion flutter on waddle stride (`DUCK_RUN_B`) and celebration hops (`DUCK_YAY_B`).
  - Guaranteed contrast across all 8 CRT themes with 100% unobstructed eyes (`kw`) and beak (`ooo`).

### 2.2 Massively Expanded Idle Life
- **Weighted Rarity System**:
  - **Common (65%)**: Preening wing feathers, feather ruffle / wing shake, curious peek, sit-down loaf, head tilt / look up, fidget shuffle.
  - **Uncommon (30%)**: Sleepy yawn, scratching head/hat with foot, wing stretch, adjusting headwear, investigating pond floor pixel, impatient foot tapping.
  - **Rare (5%)**: Proud puff posture, sneeze with particle flutter, droop sleepiness, retro glitch twitch.
- Natural pacing with 10–24s intervals between idle actions without spamming active focus sessions.

### 2.3 Multi-Tier Escalating Poke Physics & Forgiveness
- **Tier 1: Gentle Touch (1–2 pokes)**:
  - Reactions: Gentle head bob, curious glance (`DUCK_CURIOUS_POKE`), happy chirps (`snd.happyChirp`), floating red heart particles.
- **Tier 2: Mild Annoyance (3–4 pokes)**:
  - Reactions: Irritated side-eye (`DUCK_IRRITATED`), agile dodge (`DUCK_DODGE`), backward look (`DUCK_LOOK_BACK`), dry quacks (`snd.quack`).
- **Tier 3: Chaotic Escalation (5+ rapid pokes)**:
  - Reactions: Cursor chomp attack (`DUCK_CHOMP_A/B`), full comedic tantrum (`DUCK_TANTRUM_A/B`, `snd.tantrumQuacks`), dramatic playing dead (`DUCK_PLAY_DEAD`), white-flag surrender (`DUCK_SURRENDER`), or squatting duck-down (`DUCK_DUCK_DOWN`).
- **Cooldown & Forgiveness**:
  - After 4.5 seconds of peace, the poke streak resets to 0.
  - Following heavy prodding, TimeDuck delivers a witty ceasefire line (e.g. `"CEASEFIRE ACCEPTED."`, `"ALL IS FORGIVEN."`, `"TRUCE COMMENCED."`).

### 2.4 Advanced Feeding Pipeline & Mathematical Beak Alignment
- **Zero Forehead Eating**:
  - Approaching from the left: duck faces right (`flip = false`) with beak tip at offset `x + 11`. Target coordinate is computed as `crumbX - 11.0`.
  - Approaching from the right: duck faces left (`flip = true`) with beak tip at offset `x + 1`. Target coordinate is computed as `crumbX - 1.0`.
  - Arrival within 4px triggers animated pecking (`DUCK_PECK_B`), crunchy procedural audio (`snd.crumbCrunch`), swallowing (`DUCK_SWALLOW`, `DUCK_CRUMB_BEAK`), and golden crumb burst particles.

### 2.5 Overfeeding & Temporary Chonky Duck Mode
- **Mechanics**:
  - Feeding 4+ crumbs within a rolling 20-second window triggers Chonky Duck mode (`DUCK_CHONK_BASE`, `DUCK_CHONK_WADDLE_A/B`, `DUCK_CHONK_BURP`, `DUCK_CHONK_PANT`, `DUCK_CHONK_SIT`).
  - Movement speed drops from 28 px/s to 16 px/s with heavy waddles.
  - Emits procedural duck burp (`snd.duckBurp`) with rising steam puff particles.
  - Duration: 4.5 seconds before feather shake (`.featherRuffle`) cleanly restores normal TimeDuck.
  - Cooldown: 40-second cooldown prevents immediate re-triggering.

### 2.6 Massive Phrase Library & Ring-Buffer Anti-Repetition
- **450+ Hand-Crafted Retro Lines**:
  - 40+ situational categories: Timer readiness, start, short sprints, long journeys, halfway milestones, final stretch, completion, victory, stopwatch running, laps, fast/slow splits, pomodoro deep work, breaks, streaks, wake up, long inactivity, return, pokes (tiers 1-5), forgiveness, feeding, chonky burps, late night (03:00), early morning sunrise, programmer jokes, duck jokes, timer jokes, and secret moments.
  - Strict UI boundary guarantee: all phrases formatted to $\le 26$ characters.
  - 25-item historical ring buffer prevents immediate back-to-back repeats.

### 2.7 Nostalgic CRT Startup Splash Show
- **2.8s Retro Visual Sequence**:
  - Phase 0 (0.0–0.45s): CRT horizontal phosphor beam wake and center expansion.
  - Phase 1 (0.45–1.35s): Glowing TIMEDUCK hero logo assembly with scanlines.
  - Phase 2 (1.35–2.35s): Animated hatching egg (`SPLASH_EGG_A/B/HATCH`) with cycling absurd status messages ("CALIBRATING QUACK...", "COUNTING BREADCRUMBS...", "WINDING CLOCKWORK...", "POLISHING BEAK...", "LOCATING POND...").
  - Phase 3 (2.35–2.80s): Cheerful victory hop (`DUCK_YAY_A`), procedural boot chime (`snd.splashBootChime`), and "READY TO QUACK!" prompt.
- **Skip & Accessibility**: Instant skip on mouse click, Space, Return, or Esc; bypasses instantly if macOS Reduced Motion is enabled; toggleable via menu bar (`Window -> Show Startup Animation`) and `td.showStartupSplash`.

### 2.8 Procedural Audio Synthesis (`src/Audio/SoundEngine.swift`)
- `annoyedQuack()`: Low pitch-descending irritable quack.
- `tantrumQuacks()`: Rapid multi-tone frantic quack burst with pitch vibrato.
- `crumbCrunch()`: Crispy high-frequency dual-band noise crunch.
- `duckBurp()`: Low-pass filtered pitch-decaying comedic bubble resonance.
- `splashBootChime()`: Upward arpeggiated 8-bit boot fanfare (C5 $	o$ E5 $	o$ G5 $	o$ C6).

---

## 3. UI/UX Changes

- Breadcrumbs spawned via canvas click.
- Cursor interaction supports click/poke detection and multi-tier escalation.
- Startup splash window displays on initial launch with skip controls and menu toggle.

---

## 4. Animation & Visual Changes

- 25+ new duck pose matrices defined in `Sprites.swift`.
- Dynamic accessory attachment coordinates resolved per frame.
- Chonky Duck sprite matrices and steam puff particles.
- Egg hatching sequence frames (`SPLASH_EGG_A`, `_B`, `_HATCH`).

---

## 5. Audio Changes

- Added real-time procedural sound generators in `SoundEngine.swift` without adding external audio files.

---

## 6. Secrets & Easter Eggs

- Chonky Duck mode and poke tantrum surrender states serve as playful interactive secrets.

---

## 7. Accessibility Changes

- Startup splash automatically skips if macOS Reduced Motion is enabled.
- All 450+ phrases adhere strictly to $\le 26$ characters to eliminate speech bubble clipping.

---

## 8. Technical & Runtime Changes

- **`src/Graphics/AccessoryAttachment.swift`**: Full implementation of `DuckHeadAnchor`, `DuckAnchorResolver`, and `AccessoryAttachment`.
- **`src/Engine/DuckBrain.swift`**: Extended `DuckPose`, `DuckPhrase`, poke escalation logic, crumb ingestion queue, and Chonky state machine.
- **`src/Views/TimeDuckView.swift`**: Integrated splash controller, crumb spawning, and dynamic hat drawing.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Feeding coordinates calculate beak tip accurately for both normal ($x+11$) and horizontally flipped ($x+1$) orientations.
- Breadcrumb array capped at insertion to prevent memory growth under rapid clicking.

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testDuckAnchorResolverAcrossAllPoses`: Tests anchor resolution across base, breath, waddle, floor peck, sleep, crouch, tilt, and turned-head poses.
2. `testAccessoryAttachmentAllHatsResolved`: Verifies all 15 costumes resolve non-empty matrices.
3. `testRedesignedTacticalBandanaSilhouetteAndTails`: Verifies low-profile skull crown, forehead wrap band, and dual tails.
4. `testEscalatingPokePhysicsAndCooldown`: Verifies Tiers 1, 2, 3 escalation and 4.5s ceasefire forgiveness.
5. `testBeakFeedingMathematicalAlignment`: Verifies left-facing and right-facing beak arrival coordinates.
6. `testChonkyDuckModeLifecycle`: Verifies 4+ crumbs trigger, 4.5s duration, burp sound, and clean restoration.
7. `testPhraseCatalogBoundsAndAntiRepetition`: Verifies 450+ phrases, length $\le 26$, and 25-item ring buffer.
8. `testStartupSplashShowLifecycle`: Verifies 4-phase sequence, instant skip, and reduced motion bypass.

---

## 11. Documentation Requirements

- Update `README.md` and user guides to cover interactive companion mechanics, feeding, poke physics, and splash animation.

---

## 12. Known Dependencies Between Features

- Feeding and Chonky mode depend on procedural audio in `SoundEngine`.
- Living wardrobe dynamically depends on pose matrices in `Sprites.swift`.

---

## 13. Explicit Completion Criteria

- [ ] Hats and bandanas physically anchor to duck skull across all 25+ poses with zero detachment.
- [ ] Clicking duck triggers escalating poke reactions and ceasefire forgiveness.
- [ ] Dropping breadcrumbs causes duck to waddle and eat with exact beak alignment.
- [ ] Rapid feeding triggers Chonky Duck mode with burp and steam, restoring cleanly after 4.5s.
- [ ] Startup splash plays smoothly on launch and skips on click/Esc.
- [ ] `./build.sh --test` passes all Wave 4 & 5 test suites.
