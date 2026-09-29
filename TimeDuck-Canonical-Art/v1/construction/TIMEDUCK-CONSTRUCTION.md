# TimeDuck Canonical Construction Specification
=================================================

## 1. Visual Anatomy & Component Hierarchy

```
                       HEAD (Z=50)
                      /           \
             EYES (Z=70)         BEAK (Z=60)
             /         \          /        \
       Pupil (71)   Sclera (72) Upper (61) Lower (62)

                        BODY (Z=20)
                      /      |     \
             TAIL (Z=10)  SHADING (30)  FEET (Z=80)
                                        /         \
                                 Left (81)      Right (82)
```

---

## 2. Coordinate System & Canonical Frame

- **Canvas Dimensions**: 13 × 10 pixels (native coordinate system: `(0,0)` top-left, `(12,9)` bottom-right)
- **Ground Line Alignment**: Baseline y=9 (feet sit on `duckGroundY`, pond ripple plane at `duckGroundY + 1`)
- **Pivot Point / Anchor**: (x: 6, y: 9) (centered horizontally, base of feet)

```
      x: 0 1 2 3 4 5 6 7 8 9 10 11 12
   y:0   . . . . y y y y . .  .  .  .    [Crown / Skull Top]
   y:1   . . . y y y y y y .  .  .  .    [Forehead / Skull]
   y:2   . . . y y y k w y .  .  .  .    [Eyes: Pupil 'k', Sclera 'w']
   y:3   . . y y y y y y o o  o  .  .    [Upper Beak 'ooo', Cheek 'p' variant]
   y:4   . d y y y y y y y o  o  .  .    [Lower Beak 'oo', Back Shadow 'd']
   y:5   . d d y y y y y y y  .  .  .    [Tail Base 'dd', Mid Torso]
   y:6   d d d y y y y y y y  .  .  .    [Tail Tip 'ddd', Core Torso]
   y:7   . d d d d y y y y y  y  .  .    [Underbelly Shadow 'dddd', Chest]
   y:8   . . d d y y y y y y  y  .  .    [Underbelly 'dd', Lower Belly]
   y:9   . . . o o . . o o .  .  .  .    [Feet: Left 'oo', Right 'oo']
```

---

## 3. Layer Draw Order & Z-Index Table

| Layer Z | Component | Identifier | Palette Token | Role & Overlap Behavior |
|---|---|---|---|---|
| **10** | Tail Feathers | `comp_tail_neutral` | `d` (duckShad) | Lowest body layer; behind torso |
| **20** | Body Core / Torso | `comp_body_core` | `y` (duckBody) | Central structural yellow torso |
| **30** | Underbelly Shading | `comp_shading_underbelly` | `d` (duckShad) | Overlays lower body to create depth |
| **50** | Head & Skull | `comp_head_crown_skull` | `y` (duckBody) | Head dome, cheeks, and cranial volume |
| **55** | Cheek Blush | `comp_cheek_blush` | `p` (cheek) | Expressive blush on right cheek `(8,3)` |
| **60** | Beak / Bill | `comp_beak_neutral` | `o` (duckBill) | Upper/lower bill extending forward |
| **70** | Eyes | `comp_eye_neutral_open` | `k` / `w` | Pupil at `(6,2)`, catchlight at `(7,2)` |
| **80** | Feet | `comp_feet_standing` | `o` (duckBill) | Standing webbed feet at `(3..4, 9)` and `(7..8, 9)` |
| **90** | Wardrobe / Hats | *Hats Collection* | Variable | Attached at offset `hatY = duckY - 4` |

---

## 4. Pose & Expression Component Substitutions

- **Blink**: Replace `comp_eye_neutral_open` with `comp_eye_blink` (`yy` feather lid).
- **Sleep**: Replace `comp_eye_neutral_open` with `comp_eye_sleep` (`kkk` closed eye slit) and replace feet with `comp_feet_sleep_spread`.
- **Quack**: Replace `comp_beak_neutral` with `comp_beak_quack` (open mouth with interior cavity).
- **Happy / Pet**: Replace eye with `comp_eye_pet_heart` (`^^`) and add `comp_cheek_blush`.
- **Waddle Run**: Cycle feet across `comp_feet_waddle_a`, `comp_feet_waddle_b`, `comp_feet_standing`.
- **Tail Wag**: Substitute `comp_tail_neutral` with `comp_tail_wag_lift`.
- **Sitting Loaf**: Shift head by +1y and replace feet with `comp_feet_sit_tucked`.
