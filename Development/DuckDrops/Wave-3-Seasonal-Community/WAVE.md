# 🎃 Wave 3: Seasonal Drops & Community Refinement

**Target Release Candidate**: `v1.3.0+-dev`  
**Focus**: Permanent Seasonal Costumes, Offline Date-Aware Calendar Engine, VoiceOver Accessibility, Community Backlog

---

## 📦 What is Included

### 1. Permanent Seasonal Costumes
Four original seasonal hats that are added permanently to the user's wardrobe (never revoked or time-locked):
- **Pumpkin Cap** (`DuckHat.pumpkin`): Jack-o'-lantern carved crown with green vine stem.
- **Witch Hat** (`DuckHat.witch`): Pointed purple felt hat with gold buckle.
- **Winter Beanie** (`DuckHat.winterBeanie`): Cozy knit cyan beanie with white pompom.
- **Festive Santa Cap** (`DuckHat.festiveSanta`): Classic holiday red cap with snow-white trim.

### 2. Offline Date-Aware Calendar Engine (`SeasonalCalendar`)
- **Spooky Season Window**: October 24 through November 1 (Halloween greetings & pumpkin quips).
- **Holiday Season Window**: December 15 through January 2 (Festive cheer & winter waddle).
- **100% Offline & Local**: Uses `Calendar.current` date components with zero network or NTP calls.
- **Non-Intrusive**: Seasonal greetings trigger gracefully without interrupting user workflows or timer accuracy.

### 3. VoiceOver & Assistive Tech Accessibility
- `PixelHostView.swift` implements standard AppKit accessibility protocols (`isAccessibilityElement`, `accessibilityRole = .group`, `accessibilityLabel`, `accessibilityHelp`).
- Screen readers can clearly announce TimeDuck's presence, purpose, and key shortcuts.
- System Reduced Motion preference (`NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`) is respected by disabling high-velocity confetti particles.

### 4. Zero-Migration Backward Compatibility
- State persistence (`PersistedState`) encodes raw integer values (`11..14`), guaranteeing existing user `state.json` files seamlessly load without data loss.

---

## 🛠️ Code Locations & Architecture

- `src/Engine/SeasonalCalendar.swift`: Date calculation engine (`currentEvent`, `isSpooky`, `isHoliday`, `seasonalGreeting`).
- `src/Graphics/Theme.swift`: Seasonal `DuckHat` enum cases (11..14) and `isSeasonal` helper.
- `src/Graphics/Sprites.swift`: `HAT_PUMPKIN`, `HAT_WITCH`, `HAT_WINTER_BEANIE`, `HAT_FESTIVE_SANTA`.
- `src/Views/PixelHostView.swift`: AppKit accessibility conformance.
- `src/Views/TimeDuckView.swift`: Reduced motion checks and seasonal hat rendering.

---

## 🧪 Verification & Testing

Run the automated test suite for Wave 3:
```bash
./build.sh --test
```
Key tests executed:
- `testSeasonalCostumeSprites`: Verifies 6x13 dimensions for all four seasonal hats.
- `testSeasonalClassification`: Verifies `isSeasonal` property.
- `testSeasonalCalendarDateCalculations`: Tests Halloween, Christmas, and off-season dates deterministically.
- `testStatePersistenceWithNewHatsAndThemes`: Validates JSON encode/decode roundtrip with new hats and themes.

**Status**: Verified & Ready for v1.3.0+ Packaging.
