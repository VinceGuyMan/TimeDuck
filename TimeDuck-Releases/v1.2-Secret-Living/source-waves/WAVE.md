# ✨ Wave 2: Secret Moments & Living Costumes

**Target Release Candidate**: `v1.2.0-dev`  
**Focus**: Costume-Specific Micro-Reactions, Ultra-Rare Secret Events, Multi-Track Soundtrack Architecture

---

## 📦 What is Included

### 1. Costume-Specific Micro-Actions (`CostumeBehavior`)
Decoupled companion personality hooks tied to active hats:
- **Detective**: Performs magnifying glass clue inspection on timer pause (`onTimerPause`).
- **Wizard**: Casts arcane magic spell and fireworks on timer completion (`onTimerComplete`).
- **Barista**: Enjoys an espresso break during Pomodoro break phases (`onBreakStart`).
- **Tactical Bandanas**: Enters focused tactical crouch during active focus runs.
- **Sleepy Cap**: Snoozes deeply during extended inactivity.
- **Royal Crown**: Issues imperial proclamation upon timer victory.
- **Cyber Shades**: Glints with cyan neon laser focus on splits and laps.

### 2. Ultra-Rare Secret Moments Engine
Deterministic, rate-safe secret moments:
- **Golden Duck**: Radiant golden shimmer across all duck sprite pixels.
- **Ghost Glitch**: Ethereal CRT phantom glitch in spectral cyan.
- **UFO Beam**: High-frequency cosmic beam contact.
- **Victory Shades**: Retro shades overlay on major accomplishments.
- **Rate-Safety**: Evaluated at most once per 60–120s of active user time with fixed probability windows (independent of display frame rate).
- **Deterministic Test Seams**: `DuckBrain.forceRareEvent(_:)` and `DuckBrain.clearRareEvent()` allow 100% test coverage.

### 3. Dual Soundtrack Architecture
- **Theme Alpha (`TimeDuckTheme.m4a`)**: Existing 8-bit pond groove soundtrack.
- **Theme Beta Slot (`TimeDuckNightTheme.m4a`)**: Clean placeholder slot for upcoming "Night Focus" lofi audio track.
- **Graceful Fallback**: Missing future assets gracefully fallback to Theme Alpha without crashing or corrupting audio state.
- **Independent Controls**: Music volume and mute remain completely decoupled from procedural sound effects.

---

## 🛠️ Code Locations & Architecture

- `src/Engine/CostumeBehavior.swift`: Pure companion reaction resolver (`onTimerPause`, `onTimerComplete`, `onBreakStart`, `preferredIdlePose`).
- `src/Engine/DuckBrain.swift`: `RareSecretEventType`, deterministic hooks, and rare event trigger pipeline.
- `src/Audio/SoundEngine.swift`: `SoundtrackTrack` enum, track cycler, and graceful fallback URL resolver.
- `src/Views/TimeDuckView.swift`: Shimmering color maps for rare events (`getDuckColorMap(rareEvent:)`).

---

## 🧪 Verification & Testing

Run the automated test suite for Wave 2:
```bash
./build.sh --test
```
Key tests executed:
- `testCostumeMicroActions`: Verifies pause, complete, and break hooks for all costumes.
- `testRareSecretEventsDeterministicSeams`: Tests deterministic event forcing and speech lines.
- `testRareSecretColorMaps`: Validates golden and ghost color overrides.
- `testSoundtrackSelectionAndFallback`: Verifies track enum and missing asset graceful recovery.

**Status**: Verified & Ready for v1.2.0 Packaging.
