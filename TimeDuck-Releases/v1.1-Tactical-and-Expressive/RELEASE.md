# Official Release Specification: TimeDuck v1.1 — Tactical & Expressive

- **Official Version**: `v1.1.0`
- **Release Name**: Tactical & Expressive
- **Source Wave**: `Wave 1: Tactical Duck & Expressive Companion`
- **Status**: Implemented & QA Verified

---

## 1. Release Purpose

TimeDuck v1.1 ("Tactical & Expressive") expands TimeDuck from a minimalist focus companion into an expressive, customizable desktop presence. This release delivers four bespoke tactical bandana accessories, new multi-frame idle animation cycles, over 20 situation-aware contextual dialogue lines, three high-contrast retro CRT display palettes, a reusable version-aware "What's New / What's Next" release announcement experience, and a dedicated "Show TimeDuck" status bar menu command—while strictly preserving the mathematical accuracy and independence of the underlying timer engines.

---

## 2. Complete Feature Set

1. **Tactical Bandana Costume Collection**:
   - Four distinct 6×13 pixel-art headwear variants featuring fluttering knot detailing:
     - **Midnight Operative** (`DuckHat.bandanaMidnight`): Stealth matte black & graphite weave.
     - **Crimson Ronin** (`DuckHat.bandanaCrimson`): Bold ruby headband with trailing ties.
     - **Forest Camo** (`DuckHat.bandanaForestCamo`): Woodland green & shadow pattern.
     - **Desert Camo** (`DuckHat.bandanaDesertCamo`): Amber desert sand & earth pattern.
   - Integrated with the `isTacticalBandana` classification property for specialized behavior hooks.

2. **Richer Expressive Idle Animations**:
   - **Feather Ruffle** (`DuckPose.featherRuffle`): Multi-frame wing fluff and body shake (`DUCK_RUFFLE_A`, `DUCK_RUFFLE_B`).
   - **Curious Peek / Tilt** (`DuckPose.curiousPeek`): Alert head tilt and inquisitive eye glance (`DUCK_PEEK_A`, `DUCK_PEEK_B`).
   - Natural, weighted idle invocation in `DuckBrain.performRandomIdleAction()`.

3. **Expanded Context-Aware Phrase Engine**:
   - 20+ new situational phrases across focus categories:
     - Late-night session quips (e.g., `"LATE NIGHT FOCUS."`, `"BURNING POND OIL."`)
     - Long timer & milestone alerts (e.g., `"TERMINAL APPROACH."`, `"CROSSING THE MIDPOINT."`)
     - Tactical start lines (e.g., `"TACTICAL COUNTDOWN."`, `"MISSION CLOCK COMMENCED."`)
   - Strict UI width constraint: all strings guaranteed $\le 26$ characters to prevent speech bubble clipping.
   - Anti-repetition rotation to ensure phrase diversity.

4. **Three New CRT Display Palettes**:
   - **Terminal Green** (`ThemeType.terminal`): Classic VT220 phosphor green with dark matrix CRT backing.
   - **Paperwhite** (`ThemeType.paperwhite`): Crisp, glare-free e-ink grayscale with cyan/amber accents.
   - **Electric Pond** (`ThemeType.electricPond`): High-voltage deep navy with neon cyan, amber, and electric magenta accents.

5. **Version-Aware "What's New / What's Next" Announcement Experience**:
   - Automatic, one-time-per-version popup window presented upon first launch of each newly installed release.
   - Preserves version acknowledgment in `UserDefaults` (`td.lastSeenWhatsNewVersion`) so subsequent launches do not repeat the announcement.
   - Two distinct sections:
     - **What's New in v1.1**: Highlights 4 bandanas, 2 idle animations, 3 CRT themes, and expanded phrases with live animated duck sprite and palette swatches.
     - **What's Next (v1.2 Preview)**: Teases the upcoming *v1.2 Secret Living* update (reactive costumes, rare secret events, expanded soundtrack) without implementing v1.2 features.
   - **Manual Reopen**: "What's New in TimeDuck…" menu command available in both Main Application and Status Bar menus.

6. **Menu Bar — "Show TimeDuck" Command**:
   - Dedicated menu command placed at the top of the macOS status item menu.
   - Activates TimeDuck, brings the existing window to the foreground, unminimizes if miniaturized, unhides if hidden, and focuses without creating duplicate windows or altering active timer/pomodoro/stopwatch states.

---

## 3. UI/UX Changes

- **Costume Selection**: Menu bar (`Costumes` / `Hats`) and keyboard shortcuts cycle through the four new tactical bandanas in addition to the original classic wardrobe.
- **Theme Selection**: Menu bar (`Themes` / `Display`) and theme cycler include Terminal Green, Paperwhite, and Electric Pond.
- **Speech Presentation**: Speech bubbles dynamically render the expanded phrase catalog with strict boundary safety.
- **Status Bar Menu**: "Show TimeDuck" positioned prominently at the top; "What's New in TimeDuck…" added near "About TimeDuck".
- **Update Experience**: Pixel-rendered CRT announcement window for release highlights and next-version roadmap teasers.

---

## 4. Animation & Visual Changes

- **Sprite Definitions (`src/Graphics/Sprites.swift`)**:
  - Add bandana sprite matrices ($8	imes 13$ strings):
    - `HAT_BANDANA_MIDNIGHT`
    - `HAT_BANDANA_CRIMSON`
    - `HAT_BANDANA_FOREST` / `HAT_BANDANA_FOREST_CAMO`
    - `HAT_BANDANA_DESERT` / `HAT_BANDANA_DESERT_CAMO`
  - Add idle animation frames (10-row duck matrices):
    - `DUCK_RUFFLE_A` and `DUCK_RUFFLE_B`
    - `DUCK_PEEK_A` and `DUCK_PEEK_B`
- **Pose System (`src/Engine/DuckBrain.swift`)**:
  - Add `.featherRuffle` and `.curiousPeek` to `DuckPose` enum.
  - Wire frame generation in `DuckBrain.getSpriteRows()`.
- **Hat Rendering (`src/Views/TimeDuckView.swift`)**:
  - Support rendering bandana sprite rows in `drawDuckHat()`.
- **What's New View (`src/App/WhatsNew.swift`)**:
  - Pixel-rendered window featuring live animated companion duck, bandana preview cycler, and palette swatch chips.

---

## 5. Audio Changes

- No new audio files required for v1.1. Existing 8-bit sound effects and soundtrack remain fully active.

---

## 6. Secrets & Easter Eggs

- No secret events introduced in v1.1 (the Secret Moments engine is teased in What's Next for v1.2).

---

## 7. Accessibility Changes

- All three new CRT themes adhere to high-contrast readability standards for timer digits and UI controls.
- Speech bubble bounds remain strictly clamped to prevent off-screen or cropped text.

---

## 8. Technical & Runtime Changes

- **`src/Graphics/Theme.swift`**:
  - Extend `DuckHat` enum with cases:
    - `case bandanaMidnight = 7`
    - `case bandanaCrimson = 8`
    - `case bandanaForestCamo = 9`
    - `case bandanaDesertCamo = 10`
  - Add computed property `var isTacticalBandana: Bool { (7...10).contains(rawValue) }`.
  - Extend `ThemeType` enum with cases:
    - `case terminal = 5`
    - `case paperwhite = 6`
    - `case electricPond = 7`
  - Define `ThemeDefinition` instances for the new themes in `ThemeRegistry`.
- **`src/App/WhatsNew.swift`**:
  - `ReleaseAnnouncement`, `ReleaseHighlight`, `WhatsNewCatalog`, `WhatsNewManager`, `WhatsNewWindowController`.
- **`src/App/MenuManager.swift`**:
  - Top "Show TimeDuck" command and "What's New in TimeDuck…" menu items.
- **Persistence Compatibility**:
  - Raw integer values `7..10` for hats and `5..7` for themes ensure seamless JSON decode roundtrip with existing `state.json` files.
  - `UserDefaults` key `"td.lastSeenWhatsNewVersion"` tracks update announcement acknowledgment.

---

## 9. Bug Fixes & Polish Incorporated from Follow-up Waves

- Note on Wardrobe Anchors: In v1.1, bandanas render via baseline costume overlay. Dynamic anatomical skull anchoring and trailing fluttering secondary motion will be introduced in v1.4 (The Living Duck Update).

---

## 10. Testing & Verification Requirements

Automated unit tests to run via `./build.sh --test`:
1. `testTacticalBandanaSprites`: Verifies dimensions, character encoding, and row bounds for all 4 bandanas.
2. `testTacticalBandanaClassification`: Verifies `isTacticalBandana` property returns `true` for cases 7..10 and `false` for others.
3. `testFeatherRuffleAndCuriousPeekAnimations`: Verifies 10-row duck sprite generation across all frame ticks.
4. `testExpandedPhraseEngine`: Validates all new phrases conform to length $\le 26$ characters and categorize correctly.
5. `testNewCRTPalettes`: Validates color palette contrast ratios and character color mappings.
6. `testStatePersistenceWithNewHatsAndThemes`: Validates JSON encode/decode roundtrip preserving new hat and theme raw values.
7. `testUnacknowledgedVersionTriggersPresentation`: Validates first launch triggers What's New.
8. `testAcknowledgedVersionPreventsRepeatPresentation`: Validates acknowledgment prevents repeated popup.
9. `testNewerVersionTriggersPresentationAgain`: Validates upgrade to future version triggers popup once.
10. `testShowTimeDuckWindowManagementNonDestructive`: Validates non-destructive window foregrounding.

---

## 11. Documentation Requirements

- Update `README.md` to document the 4 Tactical Bandanas, 3 new CRT Palettes, and What's New menu item.
- Update `CHANGELOG.md` with the complete v1.1.0 release notes.
- Update `docs/RELEASE_NOTES_1.1.0.md`.

---

## 12. Explicit Completion Criteria

- [x] All 4 Tactical Bandanas are selectable and render cleanly above TimeDuck.
- [x] All 3 new CRT Themes render valid background, foreground, and accent palettes.
- [x] Idle animation engine triggers Feather Ruffle and Curious Peek during resting periods.
- [x] Expanded phrase pool rotates without clipping speech bubbles ($\le 26$ chars).
- [x] What's New update experience automatically appears on first launch per version.
- [x] What's New manually reopenable from Main Menu and Status Bar menu.
- [x] "Show TimeDuck" command brings window forward without resetting timer state.
- [x] `./build.sh --clean && ./build.sh --test` passes 100% of test cases (72/72 tests).
- [x] `./build.sh --release` produces a valid, runnable macOS application bundle.
