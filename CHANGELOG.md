# Changelog

All notable changes to TimeDuck are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-09-29

### The Living Companion Update

This release consolidates DuckDrops Waves 2 through 8.2 into one public update following v1.1.0.

### Added

- **Living costumes and seasonal drops** — reactive costume micro-actions, four rare secret moments, offline seasonal windows, accessibility labels, reduced-motion behavior, and dual soundtrack fallback.
- **Living Duck** — three-tier poke escalation, breadcrumb feeding, temporary Chonky mode, a larger phrase library, and the CRT startup splash.
- **Duck Stories and Living Scenes** — five procedural Pomodoro stories, secondary actors, animated props, physical equipment mounting, and continuous scene choreography.
- **Living MiniHUD** — protected clock geometry, five scale levels, a dedicated mini stage, transition matrices, completion finales, and beak-anchored sleep effects.
- **TimeCompanions** — five selectable companions, twenty achievements, domain events, CRT unlock toasts, and the three-tab Duckbook journal.
- **AI LiveSplit Protocol** — loopback HTTP controls on `127.0.0.1:1834`, native `timeduck://` actions, labeled laps, terminal helpers, and a passive Apple Silicon GPU compute watcher.
- **Version-aware What's New** — a reusable in-app release panel with a v1.2.0 announcement and a clearly marked Wave 9 horizon preview.

### Hardening

- Defensive persistence decoding accepts unknown enum values, missing optional keys, and unassigned companion identifiers without crashing.
- Centralized MiniHUD safe zones and scroll routing prevent visual controls from changing authoritative timer state.
- GPU monitor callbacks remain main-thread safe while keeping synchronous state transitions deterministic for the test runner.

### Validation

- `./build.sh --test` — **262 passed, 0 failed**.
- `./build.sh --release` — release application bundle built successfully.

### Scope boundary

Wave 9's world clock, scheduled alarms, menu-bar clock mode, and ambient chimes remain a separate design track. They are documented in [`docs/WAVE_9_HANDOFF.md`](docs/WAVE_9_HANDOFF.md) and are not included in v1.2.0.

## [1.1.0] - 2026-08-31

### Tactical & Expressive

- Version-aware What's New and What's Next announcement panel with manual reopening from the application and menu-bar menus.
- Four tactical bandanas, richer idle expressions, twenty-plus context-aware phrases, and three CRT themes.
- Menu-bar **Show TimeDuck** focus command that restores the existing window without interrupting active timers.
- Dedicated Wave 1 tests for sprites, expressions, phrase bounds, CRT contrast, persistence, and non-destructive window foregrounding.

## [1.0.0] - 2026-08-26

### Initial Release

- Countdown, Pomodoro, and wall-clock stopwatch engines with presets, laps, and clipboard summaries.
- Five CRT palettes, seven costumes, scanlines, vignette effects, ambient backdrop, status-item presence, and procedural sound.
- Compact MiniHUD mode, keyboard controls, atomic local state, and zero-telemetry offline operation.

[1.2.0]: https://github.com/VinceGuyMan/TimeDuck/releases/tag/v1.2.0
[1.1.0]: https://github.com/VinceGuyMan/TimeDuck/releases/tag/v1.1.0
[1.0.0]: https://github.com/VinceGuyMan/TimeDuck/releases/tag/v1.0.0
