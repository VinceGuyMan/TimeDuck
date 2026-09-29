# 🥷 Wave 1: Tactical Duck & Expressive Companion

**Target Release Candidate**: `v1.1.0-dev`  
**Focus**: Tactical Bandana Collection, Richer Idle Animations, 20+ Contextual Phrases, 3 Retro CRT Palettes

---

## 📦 What is Included

### 1. Tactical Bandana Costume Collection
Four original, bespoke 6x13 pixel-art bandana variants with fluttering knots:
- **Midnight Operative** (`DuckHat.bandanaMidnight`): Stealth matte black & graphite weave.
- **Crimson Ronin** (`DuckHat.bandanaCrimson`): Bold ruby headband with trailing ties.
- **Forest Camo** (`DuckHat.bandanaForestCamo`): Woodland green & shadow pattern.
- **Desert Camo** (`DuckHat.bandanaDesertCamo`): Amber desert sand & earth pattern.

### 2. New Expressive Idle Animations
- **Feather Ruffle** (`DuckPose.featherRuffle`): Multi-frame wing fluff and body shake (`DUCK_RUFFLE_A`, `DUCK_RUFFLE_B`).
- **Curious Peek / Tilt** (`DuckPose.curiousPeek`): Alert head tilt and inquisitive eye glance (`DUCK_PEEK_A`, `DUCK_PEEK_B`).

### 3. Expanded Context-Aware Phrase Engine
20+ new phrases across all categories:
- Late-night session quips ("LATE NIGHT FOCUS.", "BURNING POND OIL.")
- Long timer & milestone alerts ("TERMINAL APPROACH.", "CROSSING THE MIDPOINT.")
- Tactical start lines ("TACTICAL COUNTDOWN ENGAGED.", "MISSION CLOCK COMMENCED.")
- Anti-repetition engine ensures diverse rotation.

### 4. Three New CRT Themes
- **Terminal Green** (`ThemeType.terminal`): Classic VT220 phosphor green with dark matrix CRT backing.
- **Paperwhite** (`ThemeType.paperwhite`): Crisp, glare-free e-ink grayscale with cyan/amber accents.
- **Electric Pond** (`ThemeType.electricPond`): High-voltage deep navy with neon cyan, amber, and electric magenta.

---

## 🛠️ Code Locations & Architecture

- `src/Graphics/Theme.swift`: `DuckHat` enum cases (7..10), `ThemeType` cases (5..7), and palette definitions.
- `src/Graphics/Sprites.swift`: `HAT_BANDANA_*` sprite arrays, `DUCK_RUFFLE_*`, `DUCK_PEEK_*`.
- `src/Engine/DuckBrain.swift`: New poses in `DuckPose`, expanded `DuckPhrase` pool, idle action weights in `performRandomIdleAction`.
- `src/Views/TimeDuckView.swift`: Hat drawing in `drawDuckHat` and theme rendering.

---

## 🧪 Verification & Testing

Run the automated test suite for Wave 1:
```bash
./build.sh --test
```
Key tests executed:
- `testTacticalBandanaSprites`: Verifies 6x13 dimensions and character alignments.
- `testTacticalBandanaClassification`: Verifies `isTacticalBandana` property.
- `testFeatherRuffleAndCuriousPeekAnimations`: Verifies 10-row duck frame generation.
- `testExpandedPhraseEngine`: Validates UI character width bounds (<= 26 chars).
- `testNewCRTPalettes`: Validates contrast ratio and rainbow generators.

**Status**: Verified & Ready for v1.1.0 Packaging.
