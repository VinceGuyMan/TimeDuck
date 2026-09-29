# TimeDuck Canonical Palette Specification
===========================================

## 1. Authoritative Character Palette

The canonical companion artwork is rendered in the **Arcade Neon** character color profile. Every color is strictly mapped to an immutable character token.

| Token | Swatch | Color Name | HEX | RGB | Functional Role & Usage |
|---|---|---|---|---|---|
| `y` | 🟨 | **Duck Body (Gold)** | `#FFD84D` | `(255, 216, 77)` | Main cranial dome, cheeks, chest, core torso, primary wing plumage |
| `d` | 🟤 | **Duck Shadow (Dark Gold)** | `#C9A62E` | `(201, 166, 46)` | Tail feathers, wing shadow crease, underbelly depth contouring |
| `o` | 🟧 | **Duck Bill / Feet (Orange)** | `#FF8A3C` | `(255, 138, 60)` | Upper and lower beak bill, standing webbed feet |
| `k` | ⬛ | **Duck Eye (Dark Obsidian)** | `#141420` | `(20, 20, 32)` | Eye pupil, sleepy closed eye slit, gentledom top hat |
| `w` | ⬜ | **White Highlight** | `#FFFFFF` | `(255, 255, 255)` | Eye catchlight / sclera, barista apron, chef toque blanche |
| `p` | 🌸 | **Cheek Blush (Rose)** | `#FF9FB2` | `(255, 159, 178)` | Expressive cheek blush during petting, running, quacking |
| `b` | 🔷 | **Cyan Neon** | `#4DD9FF` | `(77, 217, 255)` | Cyber shades, cosmonaut helmet glass reflection, chrono glitch FX |
| `v` | 🟪 | **Arcane Violet** | `#9D6BFF` | `(157, 107, 255)` | Wizard hat fabric, cyber oni horns, artist beret wool |
| `m` | 🌺 | **Magenta Neon** | `#FF5FD0` | `(255, 95, 208)` | Cyberpunk UI accent, chromatic dispersion highlights |
| `g` | 🟩 | **Terminal Green** | `#53FF7A` | `(83, 255, 122)` | Barista visor, habitat cattails and pond reeds |
| `r` | 🟥 | **Ronin Red** | `#FF4D5E` | `(255, 77, 94)` | Crimson bandana, sleepycap stripes, royal crown rubies |
| `a` | 🟨 | **Amber CRT** | `#FFC24D` | `(255, 194, 77)` | Detective houndstooth cap, desert camo, steampunk brass |
| `s` | 🟦 | **Coffee Sweat/Steam** | `#6EBEFF` | `(110, 190, 255)` | Rising steam above coffee mug in break relaxation pose |

---

## 2. CRT Presentation Themes (10 Profiles)

| Theme | Display Name | Background | Primary Duck Body | Shadow | Beak / Bill | Eye |
|---|---|---|---|---|---|---|
| `arcade` | **ARCADE NEON** | `#0A0A10` | `#FFD84D` | `#C9A62E` | `#FF8A3C` | `#141420` |
| `gameboy` | **GAME BOY DMG** | `#8BAC0F` | `#9BBC0F` | `#6E8E0A` | `#306230` | `#0F380F` |
| `amber` | **AMBER CRT** | `#120A00` | `#FFC32D` | `#BE780F` | `#FF870A` | `#1E1000` |
| `synthwave` | **SYNTHWAVE** | `#120724` | `#FFD741` | `#D78C28` | `#FF5A82` | `#19082D` |
| `pond` | **DUCK POND** | `#10202C` | `#FFDC50` | `#D2A528` | `#FF8232` | `#121923` |
| `terminal` | **TERMINAL GREEN**| `#041006` | `#4DFF4D` | `#1EA02D` | `#FFBE28` | `#041006` |
| `paperwhite` | **PAPERWHITE** | `#EEF2F6` | `#F5B419` | `#C3870F` | `#E15F19` | `#121C2A` |
| `electricPond` | **ELECTRIC POND** | `#080E1A` | `#FFE11E` | `#CDA00A` | `#FF7814` | `#080E1A` |
| `solarFlare` | **SOLAR FLARE 1984**| `#120804` | `#FFBE28` | `#C86E14` | `#FF4614` | `#140A05` |
| `kyotoMatcha` | **KYOTO MATCHA** | `#141A16` | `#F5D755` | `#B9962D` | `#EB782D` | `#121814` |

---

## 3. Rare Event Color Shift Overrides

- **Golden Duck**: `y` -> `#FFE13C`, `d` -> `#DCA014`, `w` -> `#FFFFC8`, `o` -> `#FF8C14`
- **Ghost Glitch**: `y` -> `#A0EBFF`, `d` -> `#5A96DC`, `o` -> `#78D2FF`, `p` -> `#C88CFF`
- **UFO Beam**: `y` -> `#64FFB4`, `d` -> `#28B46E`
- **Victory Shades**: `k` -> `#4DD9FF`, `w` -> `#4DD9FF`
