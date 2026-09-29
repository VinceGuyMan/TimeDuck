# 🌊 Wave 8: TimeCompanions + Achievements + Duckbook

## Candidate Version
`v1.8.0-dev`

## Overview & Purpose
Wave 8 transforms TimeDuck into a rich, living timekeeping universe with two core interconnected systems:
1. **TimeCompanions**: An extensible, first-class flock of companions sharing the stable TimeDuck timing engine, each with unique pixel art, color remaps, animation personalities, phrases, and behavioral traits.
2. **Achievements / Duckbook Engine**: A 20-achievement discovery journal, domain-event driven achievement evaluation system, non-intrusive CRT toast notifications, and in-app Duckbook modal interface for selecting companions, viewing badges, and uncovering secrets.

The core foundational architecture remains strictly preserved:
> **TIME ENGINE = STABLE**  
> **DUCK = CHAOS**

---

## 🦆 TimeCompanion Roster

| Companion | Identifier | Portrait / Badge | Unlock Condition | Personality & Presentation |
| :--- | :--- | :--- | :--- | :--- |
| **TimeDuck** | `timeduck` | Classic Yellow | Default (Always unlocked) | The canonical, dependable classic duck. Balanced idle and reaction tendencies. |
| **Girl Duck** | `girlduck` | Ribbon Bow & Peach Blush | Complete The Rescue (`story_rescue`) | Cheerful, social, playful, supportive. Distinct wink, bow, and upbeat celebratory dances. |
| **Guard Duck** | `guardduck` | Military Cap & Dark Plumage | Complete 10 Total Timers (`first_10_timers`) | Absurdly serious, hyper-vigilant patrol routines, sharp salutes, treats crumbs as security incidents. |
| **Duckling** | `duckling` | Tiny Emerald Chick | Feed 15 Breadcrumbs (`feed_15_crumbs`) | High-energy micro-chaos machine, rapid waddles, tiny reactions, disproportionate excitement. |
| **CyberDuck** | `cyberduck` | Secret Cyber Matrix CRT | Discover Pond Maestro (`secret_pond_maestro`) | Secret glitch companion, CRT scanline aesthetics, digital matrix quacks, synthetic audio cues. |

---

## 🏆 Achievement System (20 Curated Milestones)

### Timer Milestones
1. **First Waddle** (`first_timer`): Successfully complete your first timer session.
2. **Tenacious Duck** (`first_10_timers`): Complete 10 timer sessions. Unlocks Guard Duck.
3. **Pond Marathon** (`marathon_timer`): Complete a single timer session lasting $\ge 45$ minutes.
4. **Quack of Dawn** (`early_bird`): Complete a timer between 5:00 AM and 7:00 AM.
5. **Night Owl... Duck?** (`night_owl`): Complete a timer between 11:00 PM and 4:00 AM.
6. **Pond Century** (`century_timer`): Reach 100 total completed timer sessions.

### Mode & Focus Milestones
7. **Focused Duck** (`pomodoro_work`): Complete a 25-minute Pomodoro focus sprint.
8. **Master of Time** (`pomodoro_cycle`): Complete a full 4-sprint Pomodoro work/break cycle.
9. **Pocket Sized** (`minihud_completion`): Complete a timer while in compact MiniHUD mode.
10. **Split Second** (`stopwatch_split`): Record 5 or more lap splits in a single stopwatch session.

### Interaction & Antics Milestones
11. **Personal Space** (`poke_escalation_max`): Reach max poke escalation (Stage 5+).
12. **Breadwinner** (`feed_15_crumbs`): Feed TimeDuck 15 breadcrumbs. Unlocks Duckling.
13. **Absolute Unit** (`chonky_mode`): Feed TimeDuck enough to enter Chonky Duck mode.
14. **Fashionably Late** (`costume_collector`): Try on 5 different hats or accessories.

### Story Finales & Theatrical Shows
15. **Worth It.** (`story_feast`): Experience the full digestion finale of The Feast.
16. **Summit Duck** (`story_expedition`): Plant the summit flag in The Expedition.
17. **Clocked Out** (`story_nightshift`): Finish the late night desk shift in Night Shift.
18. **No Days Off** (`story_wod`): Complete all heavy reps in The WOD.
19. **Leave No Duck Behind** (`story_rescue`): Escape the facility and liberate Girl Duck in The Rescue. Unlocks Girl Duck.

### Secret Discoveries
20. **Pond Maestro** (`secret_pond_maestro`): Toggle sound effects 10 times in a single session. Unlocks CyberDuck.

---

## 📖 Duckbook UI Architecture

- **Modal Window**: Accessible via menu bar (`Companions → Open Duckbook…` or shortcut `⌘B` / `D` key).
- **Three Tabs**:
  1. `Companions`: Companion roster cards with portraits, descriptions, selection state, and unlock hints.
  2. `Achievements`: Grid of pixel badges with timestamps, progress, and secret `???` representations.
  3. `Secrets`: Discovered rare Easter eggs and secret companion status.
- **Accessibility & Navigation**:
  - Full keyboard navigation (Tab between cards, Arrow keys to navigate, Space/Enter to select, Esc to close).
  - Screen reader VoiceOver accessibility labels and dynamic accessibility summaries.
  - Reduced Motion awareness: instant transitions without sliding animations.

---

## 🔔 Non-Intrusive Toast Queue

- Floating CRT-styled toast HUD rendered in the top-right corner of the canvas.
- Queues multiple simultaneous unlocks gracefully (displays sequentially for 3.5s each).
- Never blocks timer controls, never steals keyboard focus, and never mutates timer engine state.

---

## 🧪 Verification & Test Suite

- Total test suite: **211 tests passed (0 failures)**.
- Full test suite: `Tests/TimeDuckTests/Wave8Tests.swift` registered in `Tests/TestRunner.swift`.
- Invariant verification:
  - Finished / running `+1 MIN` preserved.
  - State persistence backward compatibility & migration fallback.
  - Corrupted companion ID resilience.
