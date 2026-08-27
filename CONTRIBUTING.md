# Contributing to TimeDuck

Thank you for your interest in contributing to **TimeDuck**!

TimeDuck is designed to be a small, charming, native macOS timer utility and desktop companion — **not a productivity suite**.

## Product Philosophy & Guardrails

### What TimeDuck Is:
- A small, delightful pixel-art desktop timer, stopwatch, and Pomodoro instrument.
- 100% native macOS (Swift / AppKit / CoreGraphics).
- Zero external dependencies.
- 100% local, offline, and private.

### What We Do NOT Add (Out of Scope):
- AI or LLM integrations
- User accounts or authentication
- Cloud synchronization
- Task managers, todo lists, or project boards
- Calendar integrations
- Productivity scoring, gamification, or achievements
- Telemetry, analytics, or background networking
- External libraries, frameworks, or package bloat

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
