# Official Release Specification: TimeDuck v1.3 — Seasonal & Accessible

- **Official Version**: `v1.3.0`
- **Release Name**: Seasonal & Accessible
- **Source Wave**: `Wave 3: Seasonal Drops & Community Refinement`
- **Status**: Ready for Implementation

---

## 1. Release Purpose

TimeDuck v1.3 ("Seasonal & Accessible") delivers four permanent seasonal wardrobe items, a fully offline calendar engine for seasonal greetings, full VoiceOver screen-reader accessibility for macOS assistive technology, and system-wide Reduced Motion compliance.

---

## 2. Complete Feature Set

1. **Permanent Seasonal Wardrobe**:
   - Four original seasonal hats added permanently to the user's wardrobe (never revoked or time-locked):
     - **Pumpkin Cap** (`DuckHat.pumpkin`): Jack-o'-lantern carved crown with green vine stem.
     - **Witch Hat** (`DuckHat.witch`): Pointed purple felt hat with gold buckle.
     - **Winter Beanie** (`DuckHat.winterBeanie`): Cozy knit cyan beanie with white pompom.
     - **Festive Santa Cap** (`DuckHat.festiveSanta`): Classic holiday red cap with snow-white trim.
   - `isSeasonal` helper property identifies seasonal costumes.

2. **Offline Date-Aware Calendar Engine (`SeasonalCalendar`)**:
   - **Spooky Season Window**: October 24 through November 1 (triggers spooky greetings & pumpkin quips).
   - **Holiday Season Window**: December 15 through January 2 (triggers festive cheer & winter waddle greetings).
   - **100% Offline & Local**: Evaluates `Calendar.current` date components with zero network or NTP calls.
   - **Non-Intrusive Execution**: Seasonal dialogue triggers smoothly during idle or start phases without blocking timers.

3. **VoiceOver & Assistive Technology Support**:
   - `PixelHostView.swift` implements standard AppKit accessibility protocols (`isAccessibilityElement`, `accessibilityRole = .group`, `accessibilityLabel`, `accessibilityHelp`).
   - Enables VoiceOver screen readers to announce TimeDuck mode, state, time remaining, and keyboard shortcuts.

4. **Reduced Motion Compliance**:
   - Respects macOS system preference `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`.
   - When enabled, disables high-velocity confetti particles and flashing celebratory effects.

5. **Zero-Migration State Persistence**:
   - `PersistedState` encodes raw integer values `11..14` for seasonal hats, guaranteeing seamless forward and backward compatibility with `state.json`.

---

## 3. UI/UX Changes

- **Costume Selector**: Includes Pumpkin Cap, Witch Hat, Winter Beanie, and Festive Santa Cap.
- **Seasonal Greetings**: During Spooky and Holiday windows, TimeDuck offers contextual seasonal greetings upon launch or session start.

---

## 4. Animation & Visual Changes

- **Sprite Matrices (`src/Graphics/Sprites.swift`)**:
  - `HAT_PUMPKIN` ($6	imes 13$)
  - `HAT_WITCH` ($6	imes 13$)
  - `HAT_WINTER_BEANIE` ($6	imes 13$)
  - `HAT_FESTIVE_SANTA` ($6	imes 13$)
- **Reduced Motion Rendering**: Confetti bursts are suppressed when reduced motion is requested.

---

## 5. Audio Changes

- No new audio assets required for v1.3.

---

## 6. Secrets & Easter Eggs

- Special seasonal dialogue triggers only on specific calendar dates (Halloween, Christmas, New Year's Day) via local offline calendar evaluation.

---

## 7. Accessibility Changes

- Full AppKit accessibility protocol conformance on `PixelHostView`.
- VoiceOver labels and help strings configured for non-sighted users.
- Reduced motion toggle fully wired to particle emission systems.

---

## 8. Technical & Runtime Changes

- **`src/Engine/SeasonalCalendar.swift`**: New offline date engine providing `currentEvent`, `isSpooky`, `isHoliday`, and `seasonalGreeting`.
- **`src/Graphics/Theme.swift`**: Added `DuckHat` cases:
  - `case pumpkin = 11`
  - `case witch = 12`
  - `case winterBeanie = 13`
  - `case festiveSanta = 14`
  - Computed property `var isSeasonal: Bool { (11...14).contains(rawValue) }`.
- **`src/Views/PixelHostView.swift`**: Accessibility properties and protocol overrides.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Date parsing strictly uses `Calendar.current` components rather than string formatting to eliminate locale-specific date parsing traps.

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testSeasonalCostumeSprites`: Verifies 6×13 dimensions for all 4 seasonal hats.
2. `testSeasonalClassification`: Verifies `isSeasonal` property on `DuckHat`.
3. `testSeasonalCalendarDateCalculations`: Tests Halloween, Christmas, and off-season dates deterministically.
4. `testStatePersistenceWithNewHatsAndThemes`: Validates JSON roundtrip persistence with seasonal hats.

---

## 11. Documentation Requirements

- Document the permanent seasonal wardrobe and accessibility features in `README.md`.

---

## 12. Known Dependencies Between Features

- `SeasonalCalendar` integrates with `DuckBrain` phrase engine.
- `PixelHostView` accessibility integrates with macOS AppKit accessibility hierarchy.

---

## 13. Explicit Completion Criteria

- [ ] All 4 seasonal hats are permanently unlocked and selectable in the wardrobe.
- [ ] Seasonal date windows correctly detect Spooky and Holiday periods offline.
- [ ] VoiceOver correctly navigates and announces TimeDuck's main view.
- [ ] Reduced motion preference suppresses rapid particle animations.
- [ ] `./build.sh --test` passes 100% of test cases.
