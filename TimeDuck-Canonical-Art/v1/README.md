# TimeDuck Canonical Master Art Package
=======================================

> [!IMPORTANT]
> **THIS IS THE AUTHORITATIVE CANONICAL VISUAL SOURCE FOR TIMEDUCK.**  
> **DO NOT RECONSTRUCT THE CHARACTER FROM SCREENSHOTS.**  
> **DO NOT GENERATE A SUBSTITUTE FROM AN AI PROMPT.**  
> **USE THESE ASSETS DIRECTLY.**

---

## 📁 Package Directory Map

```text
TimeDuck-Canonical-Art/
├── README.md                          # Master package guide
├── CURRENT.md                         # Active canonical version indicator (v1)
└── v1/
    ├── TIMEDUCK-CANONICAL-ART-BIBLE.md # Mandatory art rules, proportions & guidelines
    ├── SOURCE-PROVENANCE.md           # Commit tracking & authoritative source files
    ├── IMMUTABILITY.md                # Immutability guarantee & versioning policy
    ├── manifest.json                  # Machine-readable asset metadata
    ├── SHA256SUMS.txt                 # Cryptographic checksums
    │
    ├── construction/                  # TIME DUCK CONSTRUCTION KIT
    │   ├── COMPONENTS.json            # Anatomical component manifest
    │   ├── TIMEDUCK-CONSTRUCTION.md   # Structural & coordinate spec
    │   ├── components/                # Isolated transparent component PNGs
    │   ├── svg/                       # Layered addressable SVG master
    │   ├── reconstructed/             # Reconstructed duck from isolated components
    │   └── validation/                # 100% pixel-identity diff & report
    │
    ├── masters/                       # Lossless Native Masters (13x10)
    │   ├── native/                    # Core neutral, idle, waddle, sleep masters
    │   ├── poses/                     # All 32 production pose PNGs
    │   ├── expressions/               # Quack, blush, heart eyes, side-eye variants
    │   ├── status-duck/               # 14x11 micro status-bar duck masters
    │   └── habitat/                   # Cattail, reeds, lily, crumbs
    │
    ├── svg/                           # Pixel-perfect Rectilinear SVGs
    │   ├── TimeDuck-Canonical.svg
    │   ├── TimeDuck-Canonical-Transparent.svg
    │   ├── TimeDuck-Canonical-Layered.svg
    │   └── poses/                     # SVGs for all 32 poses
    │
    ├── hi-res/                        # Integer Nearest-Neighbor Upscales
    │   ├── 2x/ (26x20)
    │   ├── 4x/ (52x40)
    │   ├── 8x/ (104x80)
    │   ├── 16x/ (208x160)
    │   ├── 32x/ (416x320)
    │   └── 64x/ (832x640)
    │
    ├── webp/                          # Lossless WebP Package
    │   ├── transparent/
    │   ├── hi-res/
    │   └── animations/
    │
    ├── animations/                    # 12 Canonical Animation Cycles
    │   ├── frames/                    # Ordered PNG frame sequences
    │   ├── gif/                       # Native, 4x, 8x framed GIFs
    │   └── webp/                      # Animated WebPs
    │
    ├── palette/                       # Complete Color Specification
    │   ├── TIMEDUCK-PALETTE.md        # Tokens, HEX, RGB, roles & 10 CRT themes
    │   ├── TimeDuck-Palette.png       # Visual palette card
    │   ├── TimeDuck-Palette.svg
    │   └── TimeDuck-Palette.json
    │
    ├── reference/                     # Turnarounds & Anchors
    │   ├── TimeDuck-Character-Sheet.png / .webp / .svg
    │   └── ANCHORS.md                 # Spatial coordinates & attachment points
    │
    ├── wardrobe/                      # Living Wardrobe Collection
    │   ├── masters/                   # 16 costume overlays
    │   ├── composites/                # Duck + costume reference composites
    │   └── WARDROBE-SPEC.md           # Costume attachment rules
    │
    ├── promo/                         # Production Promotional Cutouts
    │   ├── TimeDuck-Hero-Transparent.png
    │   ├── TimeDuck-Square.png (512x512 profile avatar)
    │   └── TimeDuck-Banner.png (1280x640 social banner)
    │
    └── qa/                            # Quality Assurance & Verification
        ├── background-tests/          # Contrast checks on 10 backgrounds
        ├── integrity-test.py          # Automated verification script
        └── INTEGRITY-REPORT.md        # Validation test results
```

---

## 🎯 Quick Reference

- **Native Resolution**: `13 × 10 pixels`
- **Master Native Sprite**: [`v1/masters/native/TimeDuck-Native-Neutral.png`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/TimeDuck-Canonical-Art/v1/masters/native/TimeDuck-Native-Neutral.png)
- **Layered SVG**: [`v1/svg/TimeDuck-Canonical-Layered.svg`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/TimeDuck-Canonical-Art/v1/svg/TimeDuck-Canonical-Layered.svg)
- **Character Reference Sheet**: [`v1/reference/TimeDuck-Character-Sheet.png`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/TimeDuck-Canonical-Art/v1/reference/TimeDuck-Character-Sheet.png)
- **Palette Documentation**: [`v1/palette/TIMEDUCK-PALETTE.md`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/TimeDuck-Canonical-Art/v1/palette/TIMEDUCK-PALETTE.md)
- **Construction Spec**: [`v1/construction/TIMEDUCK-CONSTRUCTION.md`](file:///Users/homebase/Documents/TimeDuck-DuckDrops/TimeDuck-Canonical-Art/v1/construction/TIMEDUCK-CONSTRUCTION.md)
