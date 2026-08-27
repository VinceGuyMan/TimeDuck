# Changelog

All notable changes to TimeDuck will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-26

### Added
- Countdown timer with on-screen presets 1M / 5M / 15M / 25M, -1M / +1M / +5M bumps, and additional 3M / 45M actions in the engine.
- Pomodoro focus engine with automatic 4-cycle long-break sequencing and custom work duration support (25M standard, 50M deep focus).
- High-resolution stopwatch with split-time lap tracking, fastest/slowest lap highlighting, and clipboard summary export (`C`).
- 5 CRT palettes: Arcade Neon, Game Boy DMG, Amber CRT, Synthwave, Duck Pond.
- 7 duck costumes: Classic, Wizard Hat, Detective Cap, Cyber Shades, Barista, Sleepy Cap, Royal Crown.
- CRT scanline shader with phosphor ghosting and vignette.
- Interactive duck: idle breathing, tail wagging, blinking, petting, breadcrumbs, quacking.
- Mini HUD mode (`M`) and always-on-top pinning (`P`).
- Original TimeDuck Theme soundtrack plus procedural 8-bit SFX.
- Menu bar live countdown; hiding the window keeps an active timer running.
- Adaptive frame pump: 60 / 30 / 15 / 10 / 0 FPS.
- Atomic JSON persistence and daily focus stats.
- Automated unit suite covering timer, stopwatch, pomodoro, formatting, stats, duck, persistence.
