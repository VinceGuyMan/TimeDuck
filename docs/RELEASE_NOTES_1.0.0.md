# TimeDuck 1.0.0

Native macOS pixel-duck timer. First public cut.

## In the box

- Countdown timer (default 1:00) with 1 / 5 / 15 / 25 minute presets and +/-1 / +5 minute bumps
- Pomodoro engine with 4-cycle long-break sequencing
- Stopwatch with lap splits and clipboard export
- Mini HUD and always-on-top pin
- Menu bar companion that keeps time after the window is hidden
- Five CRT themes, seven costumes, original theme track, procedural 8-bit SFX
- Offline-only persistence and an automated unit suite

## Install

Build on the target Mac:

```bash
./build.sh --release
```

Open `build/TimeDuck.app`. If Gatekeeper complains, right-click then Open.

Requires macOS 12+.
