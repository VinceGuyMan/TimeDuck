# Contributing to TimeDuck

Thank you for your interest in contributing to **TimeDuck**!

TimeDuck is designed to be a small, charming, native macOS timer utility and desktop companion — **not a productivity suite**.

## Product Philosophy & Guardrails

### What TimeDuck Is:
- A small, delightful pixel-art desktop timer, stopwatch, and Pomodoro instrument.
- 100% native macOS (Swift / AppKit / CoreGraphics).
- Zero external dependencies.
- 100% local, offline, and private.

### Architectural Non-Goals & Strict Out-of-Scope Items:
- AI or LLM integrations
- User accounts, registration, or authentication
- Cloud synchronization or remote databases
- Heavy task managers, complex project boards, or issue trackers
- Social feeds, leaderboards, or manipulative gamification
- Telemetry, analytics, tracking, or background networking
- Third-party binary frameworks, package bloat, or Electron wrappers

Core additions must preserve TimeDuck's lightweight footprint (<25MB RAM, ~0% idle CPU), instant launch, and 100% offline privacy. Future major capabilities (such as optional clock-replacement modes) must strictly retain the app's handcrafted pixel-art identity and zero-dependency architecture.

## Development & Building

### Prerequisites
- macOS 12.0 or later
- Xcode Command Line Tools (`xcode-select --install`) or full Xcode

```bash
./build.sh --app
./build.sh --test
./build.sh --clean
```

## Code Style & Architecture Guidelines

- **Wall-Clock Accuracy**: Never rely on timer ticks or animation frame rate to measure time. All timing must derive from wall-clock anchors (`Date`).
- **Energy Efficiency**: Keep rendering lightweight. Use adaptive refresh rates and avoid unnecessary redraws when idle or hidden.
- **Clean Audio**: Use persistent audio buffers and avoid heap allocations inside realtime audio threads.
- **Simplicity**: Prefer clear, idiomatic Swift over clever abstractions.
- **Zero Dependencies**: Keep the project lightweight and dependency-free.

## Submitting Changes

1. Fork the repository and create a feature branch.
2. Write unit tests for new or modified logic in `Tests/TimeDuckTests/`.
3. Verify that all tests pass (`./build.sh --test`).
4. Open a Pull Request detailing the problem and your solution.
