# Changelog

All notable changes to TimeDuck will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-08-31

### Added
- **Version-Aware "What's New / What's Next" Announcement**: Reusable, pixel-styled update popup that automatically appears once per newly installed release version, celebrating v1.1 features with real animated sprites and teasing upcoming *v1.2 Secret Living* developments.
- **Manual What's New Reopening**: Added "What's New in TimeDuck…" menu command to both the Main Application Menu and Status Bar menu for on-demand review.
- **Menu Bar "Show TimeDuck" Command**: Dedicated menu option positioned at the top of the status bar menu that foregrounds, restores, unminimizes, and focuses TimeDuck without creating duplicate windows or interrupting active timers.
- **Tactical Bandana Wardrobe**: 4 bespoke pixel-art tactical bandanas (Midnight Operative, Crimson Ronin, Forest Camo, Desert Camo) with tied knots and fluttering detail.
- **Richer Idle Animations**: Multi-frame feather ruffle wing fluff (`DuckPose.featherRuffle`) and curious peek head tilt (`DuckPose.curiousPeek`).
- **Expanded Context-Aware Phrase Engine**: 20+ new situational quips and quacks across timer milestones, late-night focus sessions, and tactical start lines with anti-repetition rotation.
- **3 New CRT Themes**: Terminal Green (VT220 phosphor), Paperwhite (glare-free e-ink grayscale), and Electric Pond (high-voltage neon navy & cyan).
- **Automated Test Coverage**: Dedicated Wave 1 and What's New test suites validating bandana sprites, classifications, idle animation ticks, phrase bounds (<= 26 chars), CRT palette contrast, persistence roundtrips, and non-destructive window foregrounding (72/72 tests passing).

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
