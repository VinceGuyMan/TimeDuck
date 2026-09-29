# Wave 9 Handoff: The Native Clock Replacement Architecture

**Status**: Wave 8 Complete (`v1.8.0` / Build `8`)  
**Baseline Test Suite**: **214 / 214 tests passing (0 failures)**  
**Target Release**: TimeDuck Wave 9 (`v1.9.0`)

---

## 1. Executive Summary & Wave 8 Retrospective

Wave 8 established the **TimeCompanion** system and the **Achievements / Duckbook** framework. TimeDuck evolved from a single pixel-art duck into an extensible flock of companions (TimeDuck, Girl Duck, Guard Duck, Duckling, and CyberDuck) and a 20-achievement discovery journal without compromising the core tenet: **TIME ENGINE = STABLE / DUCK = CHAOS**.

Key Wave 8 architectural deliveries:
1. **TimeCompanion Registry & Decoupled Sprite System**:
   - Clean protocol and registry pattern (`TimeCompanionId`, `TimeCompanion`, `TimeCompanionRegistry`).
   - Dynamic per-companion sprite resolvers (`resolveSprite(...)`) and color palette remaps (`resolveColorMap(...)`).
   - State persistence and corrupted ID fallback guarantee (`unknown_id` -> `.timeDuck`).
2. **Declarative Achievement Engine**:
   - 20 curated achievements (including 3 hidden secret milestones).
   - Domain event-driven evaluation (`TimeDuckEvent` dispatcher) spanning timer completions, stories, poke escalation, breadcrumbs, stopwatch splits, and secret events.
   - Strictly idempotent unlocks with timestamp recording and reward dispatching.
   - Non-intrusive toast queue with rate-limited CRT overlay rendering.
3. **Duckbook In-App Journal**:
   - 3-tab modal overlay (`.companions`, `.achievements`, `.secrets`).
   - Full keyboard navigation (Tab, Arrow keys, Enter/Space, Esc/D/B) and VoiceOver accessibility summaries.
4. **Authoritative Clock Isolation**:
   - Zero presentation or gamification hooks mutate wall-clock timekeeping models.
   - Finished / running `+1 MIN` invariant, Pomodoro cycle transitions, and stopwatch precision remained fully preserved.

---

## 2. Wave 9 Vision: Replacing the macOS Clock App

Wave 9 begins TimeDuck's transition toward becoming a complete, delight-infused replacement for the macOS native Clock application (`/System/Applications/Clock.app`). 

### Core Capabilities for Wave 9
1. **World Clock (Multi-City Chrono Radar)**:
   - Live time tracking across customizable world timezones (e.g. UTC, Tokyo, London, San Francisco, New York).
   - Retro CRT digital clocks with daytime/nighttime sun/moon micro-glyphs and companion timezone travelers.
2. **Alarm Engine (Scheduled Wall-Clock Alarms)**:
   - One-time and recurring alarms (weekdays, weekends, custom days).
   - Procedural synth wake chimes + Duck wake-up animations with gentle snooze escalation.
3. **Menu Bar Clock Mode**:
   - Optional configurable menu bar digital readout (replacing macOS menu bar clock) with animated status duck.
4. **Enhanced Audio Synthesizer**:
   - Procedural hourly chimes (gentle retro Westminster quarters or 8-bit pond bell).
   - Sleep timer mode with white noise / rain / pond ambient sound generator.

---

## 3. Strict Invariants for Wave 9

When implementing Wave 9, subsequent engineers must enforce the following non-negotiable invariants:

1. **Timer Engine Isolation**:
   - World clock, alarms, and menu bar time display must derive strictly from authoritative system wall-clock dates (`Date()`, `Calendar`, `TimeZone`).
   - Never tie alarm triggers or world clock rendering to display link frame counts or animation deltas.
2. **Zero Gamification Intrusion**:
   - Alarms and world clocks must remain clean, functional utilities. Do not add XP, penalties, or nagging notifications.
3. **Energy Efficiency (0% CPU when idle / closed)**:
   - Keep background timers at 1 Hz for menu bar / alarm checks when the main window is hidden.
   - Zero wakeups when alarms are disabled and window is hidden.
4. **Persistence & Migration Guarantee**:
   - Extend `PersistedState` with backward-compatible optional fields (`alarms`, `worldClockCities`, `hourlyChimeEnabled`).
   - Validate and sanitize all restored timezones and calendar triggers.

---

## 4. Verification Baseline Checklist for Wave 9

- [ ] All 214 baseline tests continue passing (`./build.sh --test`).
- [ ] Add `WorldClockTests.swift` testing timezone conversion, DST shifts, and sorting.
- [ ] Add `AlarmEngineTests.swift` testing alarm scheduling, snooze state, daily repeats, and missed alarm recovery.
- [ ] Ensure `./build.sh --app` builds clean without warnings or sandbox violations.
