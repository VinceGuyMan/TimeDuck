# 👔 Wave 4: Living Wardrobe (Physical Costume Attachment)

**Target Release Candidate**: `v1.4.0-dev` (or bundled with Waves 1–3)  
**Focus**: Physical Pixel-Art Costume Attachment, Dynamic Head/Body Anchors, Bandana Redesign, Subtle Secondary Motion

---

## 🔍 Problem Being Solved

In previous builds, costumes were rendered as a static overlay at a fixed `y = duckY - 4`. As TimeDuck animated (breathing down, bobbing, waddling, deep sleeping, crouching, or pecking breadcrumbs on the floor), the duck's skull moved underneath while the costume remained static in mid-air. This created visual detachment where hats floated above the duck's head during slumps/breathing and tactical bandanas appeared as detached ribbons.

---

## 🛠️ Attachment Architecture

We introduced a lightweight, zero-dependency pixel-art attachment engine:

### 1. `DuckHeadAnchor` & `DuckAnchorResolver` (`src/Graphics/AccessoryAttachment.swift`)
- Inspects the active duck sprite matrix dynamically to extract the true skull crown `(headX, headY)`.
- Sinks 1px on breath (`DUCK_IDLE_B`), drops 1px on waddle stride (`DUCK_RUN_B`), sinks 2px on cozy sleep (`DUCK_SLEEP_DEEP`) and tactical crouch (`DUCK_TACTICAL`), drops 3px and shifts right 1px on floor pecks (`DUCK_PEEK_B`), and tilts forward on head tilts (`DUCK_LOOK_UP`, `DUCK_PEEK_B`).
- Detects turned-head backward facing poses (`DUCK_LOOK_BACK`) and mirrors accessories horizontally.

### 2. `AccessoryAttachment` Engine
- Maps each costume (`DuckHat`) to its physical attachment category:
  - **Headwear** (`.headTop`): Seated on skull crown (Wizard, Detective, Barista, Sleepy Cap, Crown, Pumpkin, Witch, Winter Beanie, Festive Santa).
  - **Headwrap** (`.headWrap`): Wrapped around the forehead across rows 0–2 with knot & trailing ties behind (Midnight, Crimson, Forest, Desert).
  - **Eyewear** (`.faceEyes`): Visor across eye row (Cyber Shades).
- Resolves subtle integer-aligned secondary motion frames on stride/hop phases without subpixel blur.

---

## 🥷 Tactical Bandana Visual Polish (Low-Profile Wrap & Trailing Tails)

All four tactical bandanas were refined to unmistakably read as a **tied headwrap / bandana** rather than a cap:
1. **Low-Profile Crown**:
   - The top row of the bandana leaves the duck's yellow skull crown visible (`...kdyyy.....`), hugging the head rather than stacking upward.
2. **Forehead Wrap Band**:
   - Dense fabric wraps tightly across the forehead directly above the eye line (`.kkykddwddk..`).
3. **Knot at Skull Back**:
   - A distinct tied knot sits at the rear curve of the head (columns 1–2).
4. **Dual Asymmetrical Loose Tails**:
   - Two loose cloth tails trail behind the duck's head:
     - **Upper tail**: 3 pixels long (`kdd` on Row 2), extending backward with a slight downward drape.
     - **Lower tail**: 2 pixels long (`.kk` on Row 3), shorter loose tail.
5. **Secondary Motion Reaction**:
   - During waddle strides (`DUCK_RUN_B`) and celebration hops (`DUCK_YAY_B`), momentum causes the tails to flutter dynamically up and back by 1 pixel (`HAT_BANDANA_*_ALT`), settling cleanly on the resting frame.
6. **Theme Contrast Guarantee**:
   - Dark border bounding ink (`k`), highlight thread (`w`), and rich pattern weaves ensure 100% crisp visibility across all 8 CRT themes without requiring white CRT flashes or selection highlights.
7. **Unobstructed Features**:
   - Duck eyes (`kw`) and beak (`ooo`) remain 100% unobstructed across all animations.

---

## 🧪 Verification & Testing

Run the automated test suite for Wave 4:
```bash
./build.sh --test
```
Key tests executed:
- `testDuckAnchorResolverAcrossAllPoses`: Tests anchor resolution across base, breath, waddle, floor peck, sleep, crouch, tilt, and turned-head poses.
- `testAccessoryAttachmentAllHatsResolved`: Verifies all 14 costumes resolve non-empty 8x13 matrices.
- `testSecondaryMotionFrames`: Verifies alternate secondary frames for soft fabrics.
- `testLivingWardrobeAttachmentBounds`: Ensures coordinates remain within safe canvas bounds.
- `testBackwardFacingFlipping`: Verifies horizontal flipping when duck faces backward.
- `testRedesignedTacticalBandanaSilhouetteAndTails`: Verifies low-profile skull crown, forehead wrap band, dual asymmetrical tails, and eye/beak clearance.
- `testBandanaContrastAcrossAllThemes`: Validates outline and fabric contrast across all 8 CRT palettes.

**Status**: Verified & Staged Locally (Unreleased).
