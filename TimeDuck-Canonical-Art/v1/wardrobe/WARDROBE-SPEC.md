# TimeDuck Living Wardrobe Specification
=======================================

## 1. Architectural Principles

1. **Decoupled Anatomy**: The base duck master remains 100% untouched. All wardrobe items are overlay layers.
2. **Standard Head Anchor**:
   - Standard Hat Offset: `hatY = duckY - 4`
   - Sitting Loaf Offset: `hatY = duckY - 3` (+1y cranial displacement)
   - Z-Order: `Z = 90` (renders on top of cranial dome and eyes)
3. **Horizontal Registration**: All 16 hats share the exact 13-column width registration matching the duck's cranial horizon.

---

## 2. Master Wardrobe Catalog (16 Costumes)

| Costume Identifier | Dimensions | Display Name | Visual Description | Signature Reaction |
|---|---|---|---|---|
| `HAT_WIZARD` | 13×6 | **Wizard Hat** | Star-spangled pointed purple cone with gold star | Arcane magic fireworks on timer completion |
| `HAT_DETECTIVE` | 13×6 | **Detective Cap** | Houndstooth deerstalker cap with bill brim | Magnifying glass investigation on pause |
| `HAT_CYBER` | 13×6 | **Cyber Shades** | Glowing cyan retro futuristic visor | Laser focus on stopwatch laps |
| `HAT_BARISTA` | 13×6 | **Barista Cap** | White cap with green apron visor band | Espresso sipping during break times |
| `HAT_SLEEPCAP` | 13×6 | **Sleepy Cap** | Red-and-white striped nightcap with pompom | Instant cozy snoozing on inactivity |
| `HAT_CROWN` | 13×6 | **Royal Crown** | Golden imperial crown with ruby gemstones | Royal decree celebration fanfare |
| `HAT_BANDANA_MIDNIGHT` | 13×8 | **Midnight Bandana** | Tactical dark obsidian combat bandana | Focused tactical crouch during active timer |
| `HAT_BANDANA_CRIMSON` | 13×8 | **Crimson Ronin** | Japanese ronin crimson combat bandana | Blade of focus on timer completion |
| `HAT_BANDANA_FOREST` | 13×8 | **Forest Camo** | Woodland canopy camouflage combat bandana | Undetected pond patrol mode |
| `HAT_BANDANA_DESERT` | 13×8 | **Desert Camo** | Sandstorm tactical combat bandana | Heatwave ops focus |
| `HAT_COSMONAUT` | 13×6 | **Cosmonaut Helmet**| Glass astronaut bubble with cyan reflection | Weightless Zero-G Float pose (`.zeroGFloat`) |
| `HAT_CYBER_ONI` | 13×6 | **Cyber Oni** | Neon kabuki mask with cyber horns | Demon matrix purge celebration |
| `HAT_STEAMPUNK` | 13×6 | **Steampunk Cap** | Brass top hat with copper goggle lenses | Clockwork gear lock on pause |
| `HAT_GENTLEDOM` | 13×6 | **Gentledom** | Charcoal silk top hat with gold monocle | Distinguished victory decree |
| `HAT_ARTIST` | 13×6 | **Artist Beret** | French wool beret with RGB pigment streak | Watercolor mixing during rest phase |
| `HAT_CHEF` | 13×6 | **Master Chef** | Pleated white culinary toque blanche | Culinary perfection quips and broth tasting |
