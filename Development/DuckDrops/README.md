# 🦆 TimeDuck Content Roadmap & Duck Drops

This directory tracks the development candidates and future content roadmap for TimeDuck.

> **Status**: Development Candidate Staging (v1.0.0 is frozen and published).
> **Release Target**: These waves are pre-built, tested, and staged for phased independent releases.

---

## 🌊 Wave Overview

| Wave | Code Name | Candidate Version | Core Theme | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Wave 1** | Tactical Duck & Expressive Companion | `v1.1.0-dev` | Tactical Bandanas, New Idle Animations, 20+ Phrases, 3 CRT Palettes | **Verified & Ready** |
| **Wave 2** | Secret Moments & Living Costumes | `v1.2.0-dev` | Costume Micro-Actions, Ultra-Rare Secret Events, Dual Soundtrack Slot | **Verified & Ready** |
| **Wave 3** | Seasonal Drops & Community Refinement | `v1.3.0+-dev` | Seasonal Costumes, Offline Date Engine, VoiceOver A11y, Backlog Manifest | **Verified & Ready** |
| **Wave 4** | Living Wardrobe & Physical Attachment | `v1.4.0-dev` | Dynamic Head Anchors, Bandana Redesign, Secondary Motion | **Verified & Ready** |

---

## 🧭 Product Philosophy

1. **Time Engine = Stable, Duck = Chaos**:
   - The countdown timer, stopwatch, and pomodoro clock must remain mathematically correct, low-latency, and rock-solid.
   - Duck companion antics, animations, hats, and phrases run strictly in presentation layers and never block timer state transitions.
2. **No Productivity Bloat**:
   - TimeDuck is a companion and precision timer, not a task manager or enterprise dashboard.
   - Zero cloud dependencies, zero telemetry, zero accounts.
3. **Local & Offline Always**:
   - All holiday dates, seasonal events, and rare rolls evaluate locally with zero network calls.

---

## 🧪 Verification Commands

```bash
# Run all automated tests (75 test cases covering baseline + Waves 1, 2, 3, and 4)
./build.sh --clean && ./build.sh --test

# Build verified development app bundle
./build.sh
```
