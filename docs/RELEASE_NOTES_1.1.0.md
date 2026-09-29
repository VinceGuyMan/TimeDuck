# TimeDuck 1.1.0 — Tactical & Expressive

The first official post-v1.0 content, expression, and usability update for TimeDuck.

## What's New in v1.1.0

- **Version-Aware Update Experience ("What's New / What's Next")**:
  - Automatically introduces each new version on first launch with a TimeDuck pixel-styled update popup.
  - Showcases newly unlocked features alongside a mysterious preview of the upcoming *v1.2 Secret Living* release.
  - Reopenable at any time via the *What's New in TimeDuck…* menu command.
- **Menu Bar "Show TimeDuck" Command**:
  - Instantly brings TimeDuck to the front, restores from minimized or hidden states, and focuses the existing window without interrupting active timers or creating duplicate windows.
- **Tactical Bandana Wardrobe**: Four bespoke pixel-art bandana headwear variants (`Midnight Operative`, `Crimson Ronin`, `Forest Camo`, `Desert Camo`) featuring low-profile wraps and trailing fluttering ties.
- **Richer Expressive Idle Life**:
  - `Feather Ruffle`: Multi-frame wing fluff and body shake.
  - `Curious Peek`: Alert head tilt and inquisitive glance.
- **Expanded Situational Dialogue**: Over 20 new context-aware lines across late-night sessions, tactical countdowns, and progress milestones, backed by anti-repetition memory.
- **Three New Retro CRT Palettes**:
  - `Terminal Green`: Classic VT220 phosphor green with dark matrix CRT backing.
  - `Paperwhite`: Crisp, glare-free e-ink grayscale with cyan/amber accents.
  - `Electric Pond`: High-voltage deep navy with neon cyan, amber, and electric magenta accents.
- **Automated Test Suite**: 72 automated unit and integration tests covering bandanas, idle frames, phrase limits ($\le 26$ chars), CRT palettes, state persistence, update acknowledgment, and non-destructive window management.

## Coming Next in v1.2 — Secret Living

- Costumes gain subtle context-aware reactions and micro-behaviors.
- Rare secret events and Easter eggs to discover during deep focus sessions.
- Multi-track background atmosphere and expanded audio design.

## A Note of Gratitude

Thank you to everyone who has downloaded, shared, starred, or simply spent some focus time with TimeDuck. Your support means a lot, and I'm excited to keep making this little duck stranger, livelier, and more useful with every update.

## Installation / Updating

Install via Homebrew:

```bash
brew install --cask VinceGuyMan/tap/timeduck
```

Or build from source:

```bash
./build.sh --release
```

Open `build/TimeDuck.app`.

Requires macOS 12+ (Apple Silicon or Intel).
