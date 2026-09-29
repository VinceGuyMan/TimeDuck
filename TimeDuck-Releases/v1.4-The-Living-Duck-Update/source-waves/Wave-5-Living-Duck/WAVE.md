# 🌊 Wave 5 — Living Duck

## 🦆 Overview & Creative Philosophy

**Wave 5: Living Duck** is a comprehensive personality, interaction, animation, and presentation expansion for TimeDuck.

While TimeDuck's precision timer, stopwatch, and pomodoro engines remain mathematically rock-solid, Wave 5 brings the companion to life with deep behavioral autonomy, expressive situational reactions, escalating poke physics, explicit feeding beak alignment, temporary overfeeding chonky modes, 450+ rich quips & jokes across 40+ categories with ring-buffer anti-repetition memory, procedural sound synthesis, and a nostalgic CRT startup splash show.

### Core Visual Golden Rule:
> **DO NOT REDESIGN THE DUCK.**
> All 25+ new poses, temporary expressions, and squash/stretch frames strictly preserve TimeDuck's established body proportions, face silhouette, orange bill, pixel grid matrix (13x10), and Game Boy Color / PS1-era aesthetic. A user seeing any frame instantly recognizes: **THAT IS TIMEDUCK.**

---

## 🚀 Key Feature Areas

### 1. Massively Expanded Idle Life
- **Weighted Rarity Architecture**:
  - **Common (65%)**: Preening wing feathers, feather ruffle / wing shake, curious peek, sit-down loaf, head tilt / look up, fidget shuffle.
  - **Uncommon (30%)**: Sleepy yawn, scratching head/hat with foot, wing stretch, adjusting headwear, investigating pond floor pixel, impatient foot tapping.
  - **Rare (5%)**: Proud puff posture, sneeze with particle flutter, droop sleepiness, retro glitch twitch.
- **Natural Timing & Restraint**: Idle actions execute with realistic 10–24s intervals and never spam during intense focus sessions.

### 2. Multi-Tier Escalating Poke Physics & Forgiveness
- **Tier 1: Gentle Touch (1–2 pokes)**:
  - Reactions: Gentle head bob, curious glance (`DUCK_CURIOUS_POKE`), happy chirps (`snd.happyChirp`), floating red heart particles.
- **Tier 2: Mild Annoyance (3–4 pokes)**:
  - Reactions: Irritated side-eye (`DUCK_IRRITATED`), agile dodge (`DUCK_DODGE`), backward look (`DUCK_LOOK_BACK`), dry quacks (`snd.quack`).
- **Tier 3: Chaotic Escalation (5+ rapid pokes)**:
  - Reactions: Cursor chomp attack (`DUCK_CHOMP_A/B`), full comedic tantrum with foot stomps and wings (`DUCK_TANTRUM_A/B`, `snd.tantrumQuacks`), dramatic playing dead (`DUCK_PLAY_DEAD`), white-flag surrender (`DUCK_SURRENDER`), or squatting duck-down (`DUCK_DUCK_DOWN`).
- **Cooldown & Forgiveness**:
  - After 4.5 seconds of peace, the poke streak resets to 0.
  - If excessive prodding occurred, TimeDuck delivers a witty forgiveness ceasefire phrase ("CEASEFIRE ACCEPTED.", "ALL IS FORGIVEN.", "TRUCE COMMENCED.").

### 3. Advanced Feeding Pipeline & Mathematical Beak Alignment
- **Zero Forehead Eating**:
  - When approaching breadcrumbs from the left, duck faces right (`flip = false`) with beak tip at offset `x + 11`. Target coordinate is mathematically computed as `crumbX - 11.0`.
  - When approaching from the right, duck faces left (`flip = true`) with beak tip at offset `x + 1`. Target coordinate is computed as `crumbX - 1.0`.
  - Upon arrival (`abs(beakX - crumbX) < 4`), duck performs animated pecking (`DUCK_PECK_B`), executes procedural crunch audio (`snd.crumbCrunch`), swallows food (`DUCK_SWALLOW`, `DUCK_CRUMB_BEAK`, `DUCK_WIGGLE_A/B`), and spawns golden crumb burst particles.

### 4. Overfeeding & Temporary Chonky Duck Mode
- **Mechanics**:
  - If duck is fed 4+ breadcrumbs within a rolling 20-second window, TimeDuck temporarily transforms into a rotund, wide boy (`DUCK_CHONK_BASE`, `DUCK_CHONK_WADDLE_A/B`, `DUCK_CHONK_BURP`, `DUCK_CHONK_PANT`, `DUCK_CHONK_SIT`).
  - Heavy waddle physics: Movement speed drops from 28 px/s to 16 px/s with weighted stomps.
  - Procedural duck burp sound (`snd.duckBurp`) with rising steam puff particles.
  - Temporary duration: Lasts 4.5 seconds before duck performs a feather shake (`.featherRuffle`) and cleanly restores to sleek normal TimeDuck.
  - Cooldown: 40-second cooldown prevents immediate re-triggering.

### 5. Massive Phrase Library & Anti-Repetition Engine
- **450+ Hand-Crafted Retro Lines**:
  - 40+ situational categories: Timer readiness, start, short sprints, long journeys, halfway milestones, final stretch, completion, victory, stopwatch running, laps, fast/slow splits, pomodoro deep work, breaks, streaks, wake up, long inactivity, return, pokes (tiers 1-5), forgiveness, feeding, chonky burps, late night (03:00), early morning sunrise, programmer jokes, duck jokes, timer jokes, and secret moments.
  - **Strict UI Boundary Guarantee**: All phrases formatted to `<= 26` characters to prevent any speech bubble overflows or clipping.
  - **Ring-Buffer Anti-Repetition**: 25-item historical memory buffer guarantees no immediate back-to-back repeats.

### 6. Nostalgic CRT Startup Splash Show
- **Retro Visual Sequence (2.8s total)**:
  - Phase 0 (0.0–0.45s): CRT horizontal phosphor beam wake and center expansion.
  - Phase 1 (0.45–1.35s): Glowing TIMEDUCK hero logo assembly with phosphor scanlines.
  - Phase 2 (1.35–2.35s): Animated hatching egg (`SPLASH_EGG_A/B/HATCH`) and cycling absurd status messages ("CALIBRATING QUACK...", "COUNTING BREADCRUMBS...", "WINDING CLOCKWORK...", "POLISHING BEAK...", "LOCATING POND...").
  - Phase 3 (2.35–2.80s): Cheerful victory hop (`DUCK_YAY_A`), procedural boot chime (`snd.splashBootChime`), and "READY TO QUACK!" prompt.
- **Accessibility & Skip Controls**:
  - Instant skip on any mouse click, Space, Return, or Escape key.
  - Reduced Motion support: Automatically bypasses or finishes instantly if macOS Reduced Motion is enabled.
  - Toggle Preference: Accessible via menu bar (`Window -> Show Startup Animation`) and `td.showStartupSplash` default.
  - Fail-safe launch: If splash fails or completes, normal TimeDuck clock renders immediately without blocking.

### 7. Procedural Audio Synthesis
- Added custom procedural sound generation routines in `SoundEngine.swift`:
  - `annoyedQuack()`: Low pitch-descending irritable quack.
  - `tantrumQuacks()`: Rapid multi-tone frantic quack burst with pitch vibrato.
  - `crumbCrunch()`: Crispy high-frequency dual-band noise crunch.
  - `duckBurp()`: Low-pass filtered pitch-decaying comedic bubble resonance.
  - `splashBootChime()`: Upward arpeggiated 8-bit boot fanfare (C5 -> E5 -> G5 -> C6).

### 8. Living Wardrobe Physical Attachment
- All 25+ new poses fully integrated into `DuckAnchorResolver`:
  - Prefix scan depth expanded to support deep crouches, flattened squashes, and tilted heads.
  - All 15 hats, caps, and bandanas physically anchor with exact skull alignment (`xOffset in -3...3`, `yOffset in -5...0`).

---

## 🧪 Automated Testing Verification

All 87 automated unit and integration tests passing:
```bash
./build.sh --clean && ./build.sh --test
```
- Idle matrix dimensions (13x10) and palette character validity
- Escalating poke tiers (1, 2, 3) and forgiveness cooldown
- Breadcrumb feeding and mathematical beak alignment
- Chonky Duck mode trigger, duration, and clean restoration
- Phrase library size (450+ lines) and category coverage
- Anti-repetition ring buffer integrity
- Living Wardrobe accessory anchors across all 25+ new poses
- Startup splash lifecycle, egg frames, and sound routines
- Mathematical timer isolation
