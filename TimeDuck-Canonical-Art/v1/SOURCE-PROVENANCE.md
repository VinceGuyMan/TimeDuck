# TimeDuck Source Provenance & Lineage
======================================

## 1. Inspected Production Commit

- **Repository**: `/Users/homebase/Documents/TimeDuck`
- **Git Commit Hash**: `0aca94357cd0f2a6475175a346087f5a5d72a0c5`
- **Application Version**: `v1.2.0` (Build `2`)
- **Date Frozen**: August 31, 2026

---

## 2. Authoritative Production Source Files

The canonical companion artwork and animation systems are strictly extracted from:

1. **`src/Graphics/Sprites.swift`**:
   - `DUCK_BASE`: Master 13×10 standing duck sprite.
   - 31 Additional Duck Pose Matrices (`DUCK_IDLE_B`, `DUCK_IDLE_WAG`, `DUCK_RUN_A/B/C`, `DUCK_YAY_A/B`, `DUCK_PET_ROWS`, `DUCK_ZERO_G_A/B`, etc.).
   - 16 Authoritative Hat / Costume Overlays (`HAT_WIZARD`, `HAT_DETECTIVE`, `HAT_CYBER`, `HAT_COSMONAUT`, etc.).
   - Habitat flora and ecological elements (`POND_CATTAIL`, `POND_REED_A/B`, `POND_LILY`, `CRUMB_GOLDEN`, `CRUMB_COFFEE`).
2. **`src/Graphics/Theme.swift`**:
   - `ThemeRegistry` defining the 10 CRT theme palettes (`arcade`, `gameboy`, `amber`, `synthwave`, `pond`, `terminal`, `paperwhite`, `electricPond`, `solarFlare`, `kyotoMatcha`).
   - Rare event color transformations (`goldenDuck`, `ghostGlitch`, `ufoBeam`, `victoryShades`).
3. **`src/Graphics/StatusDuck.swift`**:
   - 8 micro-companion status bar poses (14×11 pixels rendered into 18×18 points template).
4. **`src/Engine/DuckBrain.swift` & `src/Engine/CostumeBehavior.swift`**:
   - State machines, behavioral phases, animation framerates, and costume personality hooks.
5. **`src/Views/TimeDuckView.swift`**:
   - Baseline registration (`duckGroundY = 68`), hat attachment offset (`hatY = duckY - 4`), and ripple plane physics (`duckGroundY + 1`).

---

## 3. Discovered Historical Ambiguities & Resolution

- **App Icon vs In-App Sprite**: AppIcon contains high-res rendered variants. The in-app companion rendered by `TimeDuckView.swift` and defined in `Sprites.swift` is the single authoritative source of truth for the living companion.
- **Hat Attachment Offsets**: `Sprites.swift` defines hats with varying vertical empty padding. In `TimeDuckView.swift`, all hats attach at `hatY = duckY - 4` (and `duckY - 3` for sitting). This offset is preserved in `reference/ANCHORS.md` and `wardrobe/WARDROBE-SPEC.md`.
