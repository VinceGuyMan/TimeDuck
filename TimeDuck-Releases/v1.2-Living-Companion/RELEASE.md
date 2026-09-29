# TimeDuck v1.2.0 — The Living Companion Update

**Release date:** 2026-09-29  
**GitHub tag:** `v1.2.0`  
**Baseline:** `v1.1.0` at `b04ef33`  
**Scope:** DuckDrops Waves 2 through 8.2

## Release summary

TimeDuck 1.2.0 gathers the planned DuckDrops work into one release-sized update. The app keeps its original timer contract while adding a reactive companion, theatrical focus sessions, a stronger compact view, a persistent Duckbook, and a local protocol for timing AI work.

## Included

- Reactive costumes, seasonal windows, secret moments, accessibility labels, reduced-motion handling, and soundtrack fallback.
- Three-tier companion interaction, feeding, Chonky mode, expanded phrases, and a CRT startup splash.
- Five procedural Pomodoro stories with secondary actors, animated props, scene choreography, transition matrices, and post-completion finales.
- MiniHUD safe-zone geometry, five clock scales, compact stories, sleep effects, and animation polish.
- Five selectable TimeCompanions, twenty achievements, domain events, CRT toast notifications, and the three-tab Duckbook.
- Loopback AI LiveSplit controls at `127.0.0.1:1834`, `timeduck://` URL actions, labeled laps, terminal wrappers, and the passive Apple Silicon GPU watcher.
- A version-aware What's New panel that presents this release and marks Wave 9 as a future design track.

## Validation evidence

- `./build.sh --test` — 262 passed, 0 failed.
- `./build.sh --release` — release application bundle built successfully.
- The release branch is reconciled with the GitHub `main` tip before publication.

## Compatibility and privacy

- macOS 12 Monterey or later.
- Apple Silicon and Intel build targets remain supported by the existing build configuration.
- State decoding retains defensive fallbacks for older and incomplete JSON profiles.
- No telemetry, accounts, cloud sync, or remote network service. The AI control server is loopback-only.

## Deliberate boundary

Wave 9 is not included. The proposed world clock, scheduled alarms, digital menu-bar clock mode, and Westminster/ambient chimes are documented in [`docs/WAVE_9_HANDOFF.md`](../../docs/WAVE_9_HANDOFF.md) and require a separate scope decision.
