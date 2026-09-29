# Official Release Specification: TimeDuck v1.2 — Secret Living

- **Official Version**: `v1.2.0`
- **Release Name**: Secret Living
- **Source Wave**: `Wave 2: Secret Moments & Living Costumes`
- **Status**: Ready for Implementation

---

## 1. Release Purpose

TimeDuck v1.2 ("Secret Living") introduces dynamic personality hooks tied directly to active costumes, an ultra-rare secret moments engine that rewards long-term companion engagement, and a dual-soundtrack audio architecture that supports multi-track background music with graceful asset fallbacks.

---

## 2. Complete Feature Set

1. **Costume-Specific Micro-Actions (`CostumeBehavior`)**:
   - Decoupled companion personality reactions tied to active hats/accessories:
     - **Detective**: Performs magnifying glass clue inspection when timer is paused (`onTimerPause`).
     - **Wizard**: Casts an arcane spell and triggers fireworks on timer completion (`onTimerComplete`).
     - **Barista**: Enjoys an espresso break when Pomodoro break starts (`onBreakStart`).
     - **Tactical Bandanas**: Enters a focused tactical crouch during active focus countdowns.
     - **Sleepy Cap**: Snoozes deeply during prolonged user inactivity.
     - **Royal Crown**: Issues an imperial proclamation speech upon timer victory.
     - **Cyber Shades**: Glints with cyan neon laser focus when recording stopwatch laps and splits.

2. **Ultra-Rare Secret Moments Engine**:
   - Rare, deterministic visual events triggered during active sessions:
     - **Golden Duck**: Radiant golden shimmer across all duck sprite pixels.
     - **Ghost Glitch**: Ethereal CRT phantom glitch in spectral cyan.
     - **UFO Beam**: High-frequency cosmic beam contact from above.
     - **Victory Shades**: Retro sunglasses overlay on major milestone accomplishments.
   - **Rate-Safety Guarantee**: Evaluated at most once per 60–120s of active user session time with fixed probability windows (independent of display frame rate).
   - **Deterministic Test Seams**: `DuckBrain.forceRareEvent(_:)` and `DuckBrain.clearRareEvent()` provide 100% test coverage.

3. **Dual Soundtrack Architecture**:
   - **Theme Alpha (`TimeDuckTheme.m4a`)**: Primary 8-bit pond groove soundtrack.
   - **Theme Beta Slot (`TimeDuckNightTheme.m4a`)**: Clean placeholder slot for upcoming "Night Focus" lofi audio track.
   - **Graceful Fallback**: Missing future audio assets gracefully fall back to Theme Alpha without crashing or corrupting audio state.
   - **Independent Audio Controls**: Music volume and mute toggles remain completely decoupled from procedural sound effects.

---

## 3. UI/UX Changes

- **Soundtrack Menu**: Menu bar includes track cycler and soundtrack selection options (`Track: Alpha`, `Track: Beta (Night Focus)`).
- **Costume Behavior Feedback**: Distinct speech and animation cues trigger contextually during pause, complete, and break phase transitions based on active costume.

---

## 4. Animation & Visual Changes

- **Costume Reactions**: New transient poses for magnifying glass search, spellcasting, espresso sipping, and tactical crouch.
- **Color Remaps (`src/Views/TimeDuckView.swift`)**:
  - `getDuckColorMap(rareEvent:)` applies procedural color transforms for Golden Duck (gold shimmer) and Ghost Glitch (cyan ghost overlay).

---

## 5. Audio Changes

- `SoundEngine.swift` updated with `SoundtrackTrack` enum (`alpha`, `beta`) and track switching pipeline.
- Added graceful URL resolution that verifies asset existence before playback.

---

## 6. Secrets & Easter Eggs

- Golden Duck, Ghost Glitch, and UFO Beam rare rolls represent the canonical secret moments of TimeDuck.
- Discovery of secret events is designed to be organic and unobtrusive.

---

## 7. Accessibility Changes

- Rare event color shifts and glitch animations adhere to reduced motion settings if enabled, preventing jarring visual flashes.

---

## 8. Technical & Runtime Changes

- **`src/Engine/CostumeBehavior.swift`**: New pure companion reaction resolver implementing `onTimerPause`, `onTimerComplete`, `onBreakStart`, and `preferredIdlePose`.
- **`src/Engine/DuckBrain.swift`**: `RareSecretEventType` enum, deterministic test hooks, and rate-safe evaluation pipeline.
- **`src/Audio/SoundEngine.swift`**: Multi-track soundtrack player and URL resolver with fallback.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Rare event timers are rate-limited to wall-clock active time rather than frame ticks to avoid high-frequency triggers on high-refresh ProMotion displays (120Hz).

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testCostumeMicroActions`: Verifies pause, complete, and break hooks for all costumes.
2. `testRareSecretEventsDeterministicSeams`: Tests deterministic event forcing, expiration, and speech lines.
3. `testRareSecretColorMaps`: Validates golden and ghost color overrides across palettes.
4. `testSoundtrackSelectionAndFallback`: Verifies track enum and missing asset graceful recovery.

---

## 11. Documentation Requirements

- Document the new soundtrack selector and costume micro-reaction capabilities in user documentation.

---

## 12. Known Dependencies Between Features

- `CostumeBehavior` relies on `DuckHat` definitions from Wave 1.
- `getDuckColorMap` integrates with `TimeDuckView` rendering pipeline.

---

## 13. Explicit Completion Criteria

- [ ] Each active costume triggers its specific micro-action on pause, complete, or break.
- [ ] Golden Duck, Ghost Glitch, UFO Beam, and Victory Shades trigger and expire safely.
- [ ] Soundtrack track cycling works with graceful fallback if Theme Beta is absent.
- [ ] `./build.sh --test` executes all Wave 2 test suites with 0 failures.
