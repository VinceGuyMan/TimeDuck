# TimeDuck Canonical Anchors & Spatial Registration
===================================================

## 1. Native Space

- **Dimensions**: 13 pixels wide × 10 pixels high
- **Origin**: (0, 0) top-left
- **Baseline / Ground**: y=9 (Feet rest on duckGroundY)
- **Pond Water Surface**: y=10 (Water ripple plane at duckGroundY + 1)

---

## 2. Key Anchor Coordinates

| Anchor Point | Coordinate (x, y) | Purpose |
|---|---|---|
| **Head Crown** | `(6, 0)` | Top center of skull; attaches crowns, wizard cones |
| **Hat Horizon** | `(duckX, duckY - 4)` | Base registration for all 16 wardrobe hats |
| **Eye Anchor** | `(6, 2)` | Center of pupil / eye sockets |
| **Beak Bill** | `(8, 3)` | Base of upper beak bill |
| **Chest / Heart** | `(6, 5)` | Center of torso / emotion heart spawn point |
| **Tail Tip** | `(0, 6)` | Furthest point of tail wag movement |
| **Left Foot** | `(3, 9)` | Back webbed foot contact point |
| **Right Foot** | `(7, 9)` | Front webbed foot contact point |
| **Speech Bubble** | `(duckX, duckY - 12)` | Tail arrow anchor for dialogue bubble |
| **Water Ripple** | `(duckX + 6, duckGroundY + 1)` | Center of concentric elliptical water ripples |
