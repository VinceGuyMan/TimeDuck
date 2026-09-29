# TimeDuck Canonical Art Bible
==============================
**Version 1.0.0 (Authoritative & Frozen)**  
**Target Application**: TimeDuck v1.2.0 (Build 2, Commit `0aca94357cd0f2a6475175a346087f5a5d72a0c5`)

---

> [!IMPORTANT]
> **CANONICAL VISUAL TRUTH RULE**:
> DO NOT REDRAW TIMEDUCK FROM MEMORY OR FROM AN AI DESCRIPTION.
> ALWAYS USE THE CANONICAL MASTER ASSET OR THE DECOMPOSED CONSTRUCTION KIT PIECES.

---

## 1. Character Identity & Proportions

TimeDuck is a precision pixel-art desktop companion and timing mascot. It is intentionally designed on a strict **13 × 10 pixel grid** with bold silhouettes, expressive micro-features, and distinct retro-arcade color values.

### Proportions & Anatomy
- **Grid Size**: Exactly 13 pixels wide by 10 pixels high.
- **Head & Cranial Dome**: 7 pixels wide × 4 pixels high (occupies y=0..3).
- **Eye Construction**:
  - Right eye pupil: 1 pixel obsidian `(6, 2)`.
  - Right eye catchlight / sclera: 1 pixel white `(7, 2)`.
- **Beak Bill**:
  - Upper bill: 3 pixels wide `(8..10, 3)`.
  - Lower bill: 2 pixels wide `(9..10, 4)`.
- **Tail Feathers**: 3 pixels wide × 3 pixels high stepped shaded wedge on left `(0..2, 4..6)`.
- **Underbelly Depth**: Shaded contouring along rows y=7..8.
- **Feet**: 2 webbed feet, each 2 pixels wide, situated at `(3..4, 9)` and `(7..8, 9)`.

---

## 2. Palette & Color Rules

1. **Character Source Colors (Arcade Neon Profile)**:
   - Primary Body (`y`): `#FFD84D` / `rgb(255, 216, 77)`
   - Plumage Shadow (`d`): `#C9A62E` / `rgb(201, 166, 46)`
   - Beak Bill & Feet (`o`): `#FF8A3C` / `rgb(255, 138, 60)`
   - Eye Pupil (`k`): `#141420` / `rgb(20, 20, 32)`
   - Eye Catchlight (`w`): `#FFFFFF` / `rgb(255, 255, 255)`
   - Cheek Blush (`p`): `#FF9FB2` / `rgb(255, 159, 178)`
2. **Strictly No Gradients**: Pixel art colors must be flat and unblended.
3. **Strictly No Anti-Aliasing**: No transitional semi-transparent border pixels. Every pixel is either fully opaque (`alpha=255`) or completely transparent (`alpha=0`).

---

## 3. Scaling & Export Rules

- **Allowed Scaling**: **INTEGER NEAREST-NEIGHBOR ONLY** (1x, 2x, 4x, 8x, 16x, 32x, 64x).
- **Prohibited**: Bilinear, bicubic, Lanczos, Gaussian blur, vector smoothing, or Bézier reinterpretation.
- **Vectors**: All SVGs must utilize rectilinear `<rect>` geometry without curved approximations.

---

## 4. Wardrobe & Accessory Anchoring

- Hats and accessories must NEVER be baked directly into base duck masters.
- Attach accessories at standard cranial offset `hatY = duckY - 4` (or `duckY - 3` in sitting pose).
- Wardrobe renders at `Z = 90` on top of the cranial dome.

---

## 5. Prohibited Transformations

- ❌ Smoothing out the pixel edges.
- ❌ Adding curved vector Bézier lines.
- ❌ Adding drop shadows or inner glows not present in production.
- ❌ Re-coloring based on personal aesthetic preferences.
- ❌ Rotating by non-orthogonal angles without preserving pixel geometry.
