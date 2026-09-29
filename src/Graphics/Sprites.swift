// MARK: - TimeDuck · Sprites.swift
// Pixel fonts, duck animation frames, hat overlays, and sprite color mappings.

import Foundation

// MARK: - 3×5 Pixel Font
let FONT3: [Character: [UInt8]] = [
    "0": [7,5,5,5,7], "1": [2,6,2,2,7], "2": [7,1,7,4,7], "3": [7,1,7,1,7],
    "4": [5,5,7,1,1], "5": [7,4,7,1,7], "6": [7,4,7,5,7], "7": [7,1,2,2,2],
    "8": [7,5,7,5,7], "9": [7,5,7,1,7],
    "A": [2,5,7,5,5], "B": [6,5,6,5,6], "C": [3,4,4,4,3], "D": [6,5,5,5,6],
    "E": [7,4,6,4,7], "F": [7,4,6,4,4], "G": [3,4,5,5,3], "H": [5,5,7,5,5],
    "I": [7,2,2,2,7], "J": [1,1,1,5,2], "K": [5,5,6,5,5], "L": [4,4,4,4,7],
    "M": [5,7,7,5,5], "N": [6,5,5,5,5], "O": [2,5,5,5,2], "P": [6,5,6,4,4],
    "Q": [2,5,5,7,3], "R": [6,5,6,5,5], "S": [3,4,2,1,6], "T": [7,2,2,2,2],
    "U": [5,5,5,5,7], "V": [5,5,5,5,2], "W": [5,5,7,7,5], "X": [5,5,2,5,5],
    "Y": [5,5,2,2,2], "Z": [7,1,2,4,7],
    ":": [0,2,0,2,0], ".": [0,0,0,0,2], "-": [0,0,7,0,0], "_": [0,0,0,0,7],
    "!": [2,2,2,0,2], "?": [6,1,2,0,2], "/": [1,1,2,4,4], "%": [5,1,2,4,5],
    "(": [1,2,2,2,1], ")": [4,2,2,2,4], "+": [0,2,7,2,0], ">": [4,2,1,2,4],
    "<": [1,2,4,2,1], "=": [0,7,0,7,0], "*": [5,2,7,2,5], "#": [5,7,5,7,5],
    ",": [0,0,0,2,4], "'": [2,2,0,0,0], "\"": [5,5,0,0,0], "|": [2,2,2,2,2],
    "[": [3,2,2,2,3], "]": [6,2,2,2,6], "^": [2,5,0,0,0], "@": [7,5,7,4,3],
    "…": [0,0,0,0,5], "’": [2,2,0,0,0], "‘": [2,2,0,0,0], "“": [5,5,0,0,0],
    "”": [5,5,0,0,0], "—": [0,0,7,0,0], "–": [0,0,7,0,0], "~": [0,5,2,0,0],
    "$": [2,7,6,7,2], "★": [2,7,7,2,5], "·": [0,0,2,0,0],
    " ": [0,0,0,0,0]
]

// MARK: - 5×7 Hero Font (Main Clock Digits)
let FONT5: [Character: [UInt8]] = [
    "0": [14,17,19,21,25,17,14], "1": [4,12,4,4,4,4,14], "2": [14,17,1,2,4,8,31],
    "3": [31,2,4,2,1,17,14],     "4": [2,6,10,18,31,2,2], "5": [31,16,30,1,1,17,14],
    "6": [6,8,16,30,17,17,14],   "7": [31,1,2,4,8,8,8],   "8": [14,17,17,14,17,17,14],
    "9": [14,17,17,15,1,2,12],
    ":": [0,4,4,0,4,4,0], ".": [0,0,0,0,0,12,12], "-": [0,0,14,0,0,0,0], " ": [0,0,0,0,0,0,0],
    "P": [30,17,17,30,16,16,16], "O": [14,17,17,17,17,17,14], "M": [17,27,21,21,17,17,17]
]

// MARK: - Duck Sprites & Costume Map
func getDuckColorMap(rareEvent: RareSecretEventType? = nil) -> [Character: Color] {
    var map: [Character: Color] = [
        "y": Pal.duckBody, "d": Pal.duckShad, "o": Pal.duckBill,
        "k": Pal.duckEye,  "w": Pal.white,    "p": Pal.cheek,
        "b": Pal.cyan,     "v": Pal.violet,   "m": Pal.magenta,
        "g": Pal.green,    "r": Pal.red,      "a": Pal.amber,
        "s": Pal.sweat,    "-": Pal.duckEye,  "^": Pal.duckEye,
        "z": Pal.cyan
    ]
    if let rare = rareEvent {
        switch rare {
        case .goldenDuck:
            map["y"] = rgb(255, 225, 60)
            map["d"] = rgb(220, 160, 20)
            map["w"] = rgb(255, 255, 200)
            map["o"] = rgb(255, 140, 20)
        case .ghostGlitch:
            map["y"] = rgb(160, 235, 255)
            map["d"] = rgb(90, 150, 220)
            map["o"] = rgb(120, 210, 255)
            map["p"] = rgb(200, 140, 255)
        case .ufoBeam:
            map["y"] = rgb(100, 255, 180)
            map["d"] = rgb(40, 180, 110)
        case .victoryShades:
            map["k"] = Pal.cyan
            map["w"] = Pal.cyan
        }
    }
    return map
}

// ── Base Idle & Tail Wag Frames ──────────────────────────────────────────────

let DUCK_BASE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Idle breathing: head sinks 1px, tail flips up
let DUCK_IDLE_B: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    "..dddyyyyyy..",
    "...oo..oo...."
]

// Idle tail wag
let DUCK_IDLE_WAG: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Blink (eyes closed)
let DUCK_BLINK_ROWS: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyyyyy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// ── Waddling & Walking Frames ────────────────────────────────────────────────

let DUCK_RUN_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "....oo...oo.."
]

let DUCK_RUN_B: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    "..ddyyyyyy...",
    "..oo....oo..."
]

let DUCK_RUN_C: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypooo.",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

// ── Paused & Slump ───────────────────────────────────────────────────────────

let DUCK_PAUSE: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykk.....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    "..ddyyyyyy...",
    "...oooo......"
]

// ── Celebration & Jumping ────────────────────────────────────────────────────

let DUCK_YAY_A: [String] = [
    "....d..d.....",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

let DUCK_YAY_B: [String] = [
    "...d....d....",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    "..ddyyyyyy...",
    "....oooo....."
]

// Quacking animation (wide open beak)
let DUCK_QUACK_ROWS: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypoooo",
    ".dyyyyyyy.oo.",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Happy Petting / Heart eyes & blush
let DUCK_PET_ROWS: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^^y....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Pecking breadcrumbs (head down munching)
let DUCK_PECK_A: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyyykwy...",
    "..dyyyyyyoo..",
    ".ddyyyyyyooo.",
    "dddyyyyyyyoo.",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_PECK_B: [String] = [
    ".............",
    ".............",
    ".............",
    ".....yyyy....",
    "....yyyyyy...",
    ".dddyyykwy...",
    "..ddyyyyyoo..",
    ".ddddyyyyyooo",
    "..ddyyyyyyooo",
    "...oo..oo..o."
]

// Break relaxation pose (relaxing with coffee mug & shades)
let DUCK_RELAX_ROWS: [String] = [
    ".............",
    "....s.s......",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykkk....",
    "..yyyyyyooo..",
    ".ddyyyyyyyoo.",
    "ddddyyyyyywww",
    ".ddddyyyyywww",
    "...oooo...www"
]

// ── Expressive & Idle Life Frames ───────────────────────────────────────────

// Head tilt / glance up at timer
let DUCK_LOOK_UP: [String] = [
    "...yyyyy.....",
    "...yykwyy....",
    "..yyyyyyyoo..",
    "..yyyyyyyoo..",
    ".dyyyyyyy....",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Preening feathers (grooming wing)
let DUCK_PREEN_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyy.....",
    ".dyyyyyyooo..",
    ".ddyyyydoo...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_PREEN_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyyyyy....",
    "..yyykwy.....",
    ".dyyyyydooo..",
    ".ddyyyydoo...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Cozy sitting loaf (feet tucked)
let DUCK_SIT: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..dddddddd..."
]

// Tactical crouch / sneak stance
let DUCK_TACTICAL: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yyykkk....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    "..ddddddddd..",
    "...oo..oo...."
]

// Suspicious side-eye glance
let DUCK_SIDE_EYE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyywky....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Head turned looking backward
let DUCK_LOOK_BACK: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...ywkyyy....",
    ".ooyyyyyy....",
    ".ooyyyyyyd...",
    "...yyyyyydd..",
    "...yyyyyyddd.",
    "..yyyyyydddd.",
    "..yyyyyyydd..",
    "...oo..oo...."
]

// Rhythm head bob / groove
let DUCK_BOB: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    "ddddyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Foot shuffle fidget frames
let DUCK_SHUFFLE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "....oo.oo...."
]

let DUCK_SHUFFLE_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

// Feather ruffle / wing shake frames (Wave 1)
let DUCK_RUFFLE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".dddyyyyyy...",
    "ddddyyyyyy...",
    "..ddddyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_RUFFLE_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    "ddddyyyyyyy..",
    ".dddyyyyyyy..",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Curious head tilt / peek frames (Wave 1)
let DUCK_PEEK_A: [String] = [
    "....yyyyy....",
    "...yyyyyyy...",
    "...yyykwyy...",
    "..yyyyyyyooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_PEEK_B: [String] = [
    ".....yyyyy...",
    "....yyyyyyy..",
    "....yyykwyy..",
    "...yyyyyyyooo",
    "..dyyyyyyyoo.",
    "..ddyyyyyyy..",
    ".dddyyyyyyy..",
    "..ddddyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Deep cozy sleep
let DUCK_SLEEP_DEEP: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykkk....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    "ddddyyyyyy...",
    ".ddddddddd...",
    "..oooooooo..."
]

// ── Wave 5: Idle & Personality Behaviors ──────────────────────────────────────

// Wing stretch A & B
let DUCK_STRETCH_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    "ddddyyyyyy...",
    ".dddyyyyyy...",
    "..ddddyyyyy..",
    "...ddyyyyyy..",
    "...oo..oo...."
]

let DUCK_STRETCH_B: [String] = [
    "..d.yyyy.d...",
    ".ddyyyyyydd..",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Big sleepy yawn
let DUCK_YAWN: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy--y....",
    "..yyyyyyoooo.",
    ".dyyyyyy.oo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Investigating floor pixel
let DUCK_INVESTIGATE_A: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

let DUCK_INVESTIGATE_B: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..dyyyyyooo..",
    ".ddyyyyyyoo..",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

// Confused double-take & spin
let DUCK_CONFUSED_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...ykwkkwy...",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_CONFUSED_B: [String] = [
    ".....yyyy....",
    "....yyyyyy...",
    "...yywkkyy...",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Proud stance (beak held high, puffed chest)
let DUCK_PROUD: [String] = [
    "....yyyyy....",
    "...yyyyyyy...",
    "...yyykwyoo..",
    "..yyyyyyyooo.",
    ".dyyyyyyyy...",
    ".ddyyyyyyyy..",
    "dddyyyyyyyy..",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Sneeze (anticipation + burst)
let DUCK_SNEEZE_A: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy--y....",
    "..yyyyyyooo..",
    ".ddyyyyyyoo..",
    "ddddyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_SNEEZE_B: [String] = [
    "..s.yyyy.....",
    ".ssyyyyyy....",
    "...yyykwy....",
    "..yyyyyypoooo",
    ".dyyyyyyy.oo.",
    "ddddyyyyyy...",
    ".dddyyyyyy...",
    "..ddddyyyyy..",
    "...ddyyyyyy..",
    "...oo..oo...."
]

// Impatient foot tap
let DUCK_FOOT_TAP_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_FOOT_TAP_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyo..",
    "...oo....o..."
]

// Scratching head/hat with foot
let DUCK_SCRATCH_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy.o..",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo........"
]

let DUCK_SCRATCH_B: [String] = [
    "....yyyy..o..",
    "...yyyyyy.o..",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo........"
]

// Adjust headwear / settle hat
let DUCK_ADJUST_HAT: [String] = [
    "....yyyy.d...",
    "...yyyyyyd...",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Droop sleep (nodding off)
let DUCK_DROOP_SLEEP: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy--y....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

// ── Wave 5: Poke Escalation Reactions ────────────────────────────────────────

// Tier 1: Curious / early poke
let DUCK_CURIOUS_POKE: [String] = [
    "....yyyyy....",
    "...yyyyyyy...",
    "...yyykwyy...",
    "..yyyyyyyooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Tier 2: Irritated glare
let DUCK_IRRITATED: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykkky...",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Tier 2: Dodge / lean back
let DUCK_DODGE: [String] = [
    "...yyyy......",
    "..yyyyyy.....",
    "..yyykwy.....",
    ".yyyyyyooo...",
    "dyyyyyyyoo...",
    "ddyyyyyyy....",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Tier 3: Duck down flat under cursor
let DUCK_DUCK_DOWN: [String] = [
    ".............",
    ".............",
    ".............",
    "....yyyy.....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    "ddddyyyyyyy..",
    ".dddddddddd..",
    "...oooooo...."
]

// Tier 3: Chomp / snap at cursor
let DUCK_CHOMP_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooooo",
    ".dyyyyyyy....",
    ".ddyyyyyy.oo.",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_CHOMP_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyypoooo",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Tier 3: Tantrum stomping
let DUCK_TANTRUM_A: [String] = [
    "...d....d....",
    "....yyyy.....",
    "...yyykkky...",
    "..yyyyyyoooo.",
    ".dyyyyyyy.oo.",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "..oo...oo...."
]

let DUCK_TANTRUM_B: [String] = [
    "....d..d.....",
    "....yyyy.....",
    "...yyykkky...",
    "..yyyyyyoooo.",
    ".dyyyyyyy.oo.",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "....oo...oo.."
]

// Tier 3: Play dead / dramatic flop
let DUCK_PLAY_DEAD: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    ".............",
    "....yyyy.....",
    "...yyy-yy....",
    "..yyyyyyooo..",
    ".ddyyyyyyyyoo",
    "dddddddddddoo"
]

// Tier 3: Fake surrender (wings up)
let DUCK_SURRENDER: [String] = [
    "..d......d...",
    "..d.yyyy.d...",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

// ── Wave 5: Feeding & Swallow Reactions ──────────────────────────────────────

// Satisfied swallow / neck back
let DUCK_SWALLOW: [String] = [
    "...yyyyy.....",
    "...yyykwy....",
    "..yyyyyyooo..",
    "..dyyyyyyoo..",
    ".ddyyyyyy....",
    ".dddyyyyyy...",
    "ddddyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Crumb stuck on beak
let DUCK_CRUMB_BEAK: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^^y....",
    "..yyyyyypoooa",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// Satisfied tail wiggle
let DUCK_WIGGLE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^^y....",
    "..yyyyyypooo.",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_WIGGLE_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^^y....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    "ddddyyyyyy...",
    ".dddyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// ── Wave 5: Chonky Duck (Overfed Temporary Mode) ──────────────────────────────

// Chonky base stance (wider round belly, unmistakably TimeDuck)
let DUCK_CHONK_BASE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "..ooo..ooo..."
]

// Chonky waddle A & B (slow heavy steps)
let DUCK_CHONK_WADDLE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    ".ooo....ooo.."
]

let DUCK_CHONK_WADDLE_B: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "...ooo..ooo.."
]

// Chonky sit loaf
let DUCK_CHONK_SIT: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "..dddddddd..."
]

// Chonky tiny burp
let DUCK_CHONK_BURP: [String] = [
    "...s.yyyy....",
    "..ssyyyyyy...",
    "...yyy--y....",
    "..yyyyyyoooo.",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "..ooo..ooo..."
]

// Chonky pant (one exhausted flap)
let DUCK_CHONK_PANT: [String] = [
    "....d..d.....",
    "....yyyy.....",
    "...yyy--y....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "..ooo..ooo..."
]

// ── Hat & Costume Overlays (Living Wardrobe) ─────────────────────────────────

let HAT_WIZARD: [String] = [
    ".....v.......",
    "....vvv......",
    "...vvavv.....",
    "..vvvvvvv....",
    ".vvvvvvvvv...",
    ".............",
    ".............",
    "............."
]

let HAT_WIZARD_ALT: [String] = [
    "......v......",
    "....vvv......",
    "...vvavv.....",
    "..vvvvvvv....",
    ".vvvvvvvvv...",
    ".............",
    ".............",
    "............."
]

let HAT_DETECTIVE: [String] = [
    ".............",
    "....aaaa.....",
    "...aaaaaa....",
    "..aaaaaaaa...",
    "aaaaaaaaaaaa.",
    ".............",
    ".............",
    "............."
]

let HAT_CYBER: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    ".............",
    ".....bbbb....",
    "....bbbbbb...",
    "............."
]

let HAT_BARISTA: [String] = [
    ".............",
    "...wwwwww....",
    "..wwwwwwww...",
    "..gggggggg...",
    ".gggggggggg..",
    ".............",
    ".............",
    "............."
]

let HAT_SLEEPCAP: [String] = [
    "....rrrrww...",
    "...rrrrrrw...",
    "..rrrrrrrr...",
    ".rrrrrrrrr...",
    "wwwwwwwwwww..",
    ".............",
    ".............",
    "............."
]

let HAT_SLEEPCAP_ALT: [String] = [
    "...rrrrrww...",
    "..rrrrrrrw...",
    ".rrrrrrrrr...",
    ".rrrrrrrrr...",
    "wwwwwwwwwww..",
    ".............",
    ".............",
    "............."
]

let HAT_CROWN: [String] = [
    ".............",
    "...a.a.a.....",
    "...aaaaa.....",
    "...aaaaa.....",
    "..rrrrrrr....",
    ".............",
    ".............",
    "............."
]

// ── Tactical Bandana Collection (Wave 1 / Wave 4 Redesign) ───────────────────

let HAT_BANDANA_MIDNIGHT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kd........",
    ".kk.kddwddk..",
    "kdd..........",
    ".kk.........."
]

let HAT_BANDANA_MIDNIGHT_ALT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kd........",
    "kdd.kddwddk..",
    ".kk..........",
    "..k.........."
]

let HAT_BANDANA_CRIMSON: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kr........",
    ".rk.rrrrwrrk.",
    "krr..........",
    ".rk.........."
]

let HAT_BANDANA_CRIMSON_ALT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kr........",
    "krr.rrrrwrrk.",
    ".rk..........",
    "..r.........."
]

let HAT_BANDANA_FOREST: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kg........",
    ".gk.gdggdkg..",
    "kgd..........",
    ".gk.........."
]

let HAT_BANDANA_FOREST_ALT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...kg........",
    "kgd.gdggdkg..",
    ".gk..........",
    "..g.........."
]

let HAT_BANDANA_DESERT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...ka........",
    ".ak.adaddka..",
    "kad..........",
    ".ak.........."
]

let HAT_BANDANA_DESERT_ALT: [String] = [
    ".............",
    ".............",
    ".............",
    ".............",
    "...ka........",
    "kad.adaddka..",
    ".ak..........",
    "..a.........."
]

// ── Seasonal Costumes (Wave 3) ───────────────────────────────────────────────

let HAT_PUMPKIN: [String] = [
    ".....g.......",
    "....aaaa.....",
    "...aaooaa....",
    "..aaooaoaa...",
    "..aaaaaaaa...",
    ".............",
    ".............",
    "............."
]

let HAT_WITCH: [String] = [
    "......v......",
    ".....vvv.....",
    "....vvavv....",
    "...vvvvvvv...",
    ".vvvvvvvvvvv.",
    ".............",
    ".............",
    "............."
]

let HAT_WINTER_BEANIE: [String] = [
    ".....w.......",
    "....bbb......",
    "...bbbbbb....",
    "..bbbbbbbb...",
    ".wwwwwwwwww..",
    ".............",
    ".............",
    "............."
]

let HAT_FESTIVE_SANTA: [String] = [
    "....rrrrw....",
    "...rrrrrrw...",
    "..rrrrrrrr...",
    ".rrrrrrrrr...",
    "wwwwwwwwwww..",
    ".............",
    ".............",
    "............."
]

let HAT_FESTIVE_SANTA_ALT: [String] = [
    "...rrrrrw....",
    "..rrrrrrrw...",
    ".rrrrrrrrr...",
    ".rrrrrrrrr...",
    "wwwwwwwwwww..",
    ".............",
    ".............",
    "............."
]

// ── Startup Splash & Loading Show Graphics ──────────────────────────────────

let SPLASH_EGG_A: [String] = [
    "....wwwwww...",
    "...wwwwwwww..",
    "..wwwwwwwwww.",
    "..wwwwwwwwww.",
    ".wwwwwwwwwwww",
    ".wwwwwwwwwwww",
    "..wwwwwwwwww.",
    "...wwwwwwww..",
    "....wwwwww...",
    "............."
]

let SPLASH_EGG_B: [String] = [
    "....wwwwww...",
    "...wwwwkwww..",
    "..wwwwkwwwww.",
    "..wwwkwwwwww.",
    ".wwwwkwwwwww.",
    ".wwwwkwwwwww.",
    "..wwwwkwwwww.",
    "...wwwwwwww..",
    "....wwwwww...",
    "............."
]

let SPLASH_EGG_HATCH: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".wwwwwwwwwwww",
    ".wwwwwwwwwwww",
    "..wwwwwwwwww.",
    "...wwwwwwww..",
    "....wwwwww...",
    "............."
]

// MARK: - Wave 6: Duck Stories (The Feast Fullness Stages)

/// Stage 1: Slight belly curve, satisfied.
let DUCK_CHONK_STAGE1: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Stage 2: Visible round belly, contented stance.
let DUCK_CHONK_STAGE2: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    ".ddddyyyyyyy.",
    "..ooo..ooo..."
]

/// Stage 3: Chunkier wide body, heavy stance.
let DUCK_CHONK_STAGE3: [String] = [
    "...yyyyy.....",
    "..yyyyyyy....",
    "..yyyykwyy...",
    ".yyyyyyyyyooo",
    "ddyyyyyyyyyoo",
    "dddyyyyyyyyyy",
    "ddddyyyyyyyyy",
    "dddddyyyyyyyy",
    ".dddddyyyyyy.",
    "..oooo..oooo."
]

/// Stage 4: Very full unit, wings resting on belly.
let DUCK_CHONK_STAGE4: [String] = [
    "..yyyyyyy....",
    ".yyyyyyyyy...",
    ".yyyyykwyy...",
    "yyyyyyyyyyooo",
    "ddyyyyyyyyyoo",
    "dddyyyyyyyyyy",
    "dddddyyyyyyyy",
    "ddddddyyyyyyy",
    ".ddddddyyyyy.",
    "..oooo..oooo."
]

/// Stage 5: ABSOLUTE UNIT (Maximum spherical fullness).
let DUCK_CHONK_STAGE5: [String] = [
    ".yyyyyyyyyy..",
    "yyyyyyyyyyyy.",
    "yyyyyykwyyyy.",
    "yyyyyyyyyyooo",
    "ddyyyyyyyyyoo",
    "ddddyyyyyyyyy",
    "dddddyyyyyyyy",
    "ddddddyyyyyyy",
    ".ddddddyyyyy.",
    "..oooo..oooo."
]

/// Digestion belly pat.
let DUCK_BELLY_PAT: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^wy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyydyyyy.",
    "dddyyyyddyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Digestion rumble belly wobble.
let DUCK_BELLY_WOBBLE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy-wy....",
    "..yyyyyyooo..",
    ".ddyyyyyyyyoo",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    "dddddyyyyyyy.",
    "..ddddyyyyy..",
    "..ooo..ooo..."
]

// MARK: - Wave 6: Duck Stories (The Expedition)

/// Checking imaginary map frame A.
let DUCK_MAP_CHECK_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy-wy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyywwwwwwwy.",
    "dddywawaawwy.",
    "ddddwwwwwwwy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Checking imaginary map frame B (turned sideways).
let DUCK_MAP_CHECK_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyywwwwwwwy.",
    "dddywaaaawwy.",
    "ddddwwwwwwwy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Determined expedition march waddle A.
let DUCK_EXPEDITION_WADDLE_A: [String] = [
    ".....yyyy....",
    "....yyyyyy...",
    "....yyykwy...",
    "...yyyyyyooo.",
    "..dyyyyyyyyyoo",
    ".ddyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyy...",
    "...oooo.oo..."
]

/// Determined expedition march waddle B.
let DUCK_EXPEDITION_WADDLE_B: [String] = [
    "...yyyy......",
    "..yyyyyy.....",
    "..yyykwy.....",
    ".yyyyyyooo...",
    "dyyyyyyyyyoo.",
    "ddyyyyyyyyy..",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyy...",
    "..oo.oooo...."
]

/// Reaching summit celebration.
let DUCK_SUMMIT_CHEER: [String] = [
    ".yy..yyyy..yy",
    ".yy.yyyyyy.yy",
    "..yyyyykwyyyy",
    "...yyyyyyooo.",
    "..dyyyyyyyyyoo",
    ".ddyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

// MARK: - Wave 6: Duck Stories (Night Shift)

/// Drooping sleepy head.
let DUCK_NIGHT_DROOP: [String] = [
    ".............",
    ".....yyyy....",
    "....yyyyyy...",
    "....yyy--yooo",
    "...dyyyyyyyoo",
    "..ddyyyyyyyy.",
    ".dddyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Snapping awake in shock.
let DUCK_NIGHT_SNAP_AWAKE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwk....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Splashing pixel water droplets on face.
let DUCK_NIGHT_FACE_SPLASH: [String] = [
    "....yyyy..b..",
    "...yyyyyy.b..",
    "...yyy--y.b..",
    "..yyyyyyooob.",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Throwing blanket away.
let DUCK_NIGHT_BLANKET_THROW: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyybbbbb",
    ".ddddyyybbbbb",
    "..ooo..obbbbb"
]

// MARK: - Wave 6: Duck Stories (The WOD / Workout)

/// WOD warmup jumping jacks A.
let DUCK_WOD_WARMUP_A: [String] = [
    ".....yyyy....",
    "....yyyyyy...",
    "....yyykwy...",
    "...yyyyyyooo.",
    "..dyyyyyyyyyoo",
    ".ddyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    ".oooo..oooo.."
]

/// WOD warmup jumping jacks B.
let DUCK_WOD_WARMUP_B: [String] = [
    ".yy..yyyy..yy",
    ".yy.yyyyyy.yy",
    "..yyyyykwyyyy",
    "...yyyyyyooo.",
    "..dyyyyyyyyyoo",
    ".ddyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Pedaling elliptical stride A.
let DUCK_ELLIPTICAL_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    ".oooo...oo..."
]

/// Pedaling elliptical stride B.
let DUCK_ELLIPTICAL_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "...oo...oooo."
]

/// Treadmill sprint stride A.
let DUCK_TREADMILL_A: [String] = [
    "s...yyyy.....",
    ".s.yyyyyy....",
    "..syyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "oooo....oo..."
]

/// Treadmill sprint stride B.
let DUCK_TREADMILL_B: [String] = [
    "s...yyyy.....",
    ".s.yyyyyy....",
    "..syyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..oo....oooo."
]

/// Dumbbell lift frame A (down).
let DUCK_DUMBBELL_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyydyyyy.",
    "kddyyyydkdyy.",
    "kdddyyyykdyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Dumbbell lift frame B (raised).
let DUCK_DUMBBELL_B: [String] = [
    "..k.yyyy..k..",
    "..k.yyyyyyk..",
    "...yyy^wy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Gym victory bicep flex.
let DUCK_WOD_FLEX: [String] = [
    "..d.yyyy..d..",
    "..dyyyyyyyd..",
    "...yyy^wy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

// MARK: - Wave 6: Duck Stories (The Rescue Stealth Parody)

/// Stealth low crouch.
let DUCK_STEALTH_CROUCH: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwyooo.",
    "..dyyyyyyyyoo",
    ".ddyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo..."
]

/// Stealth tiptoe sneak A.
let DUCK_STEALTH_TIPTOE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyy...",
    "...o....o...."
]

/// Stealth tiptoe sneak B.
let DUCK_STEALTH_TIPTOE_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    "ddddyyyyyyyy.",
    ".ddddyyyyy...",
    "....o....o..."
]

/// Peeking around corner.
let DUCK_STEALTH_CORNER_PEEK: [String] = [
    ".......yyyy..",
    "......yyyyyy.",
    "......yyykwy.",
    ".....yyyyyooo",
    "....dyyyyyyoo",
    "...ddyyyyyyy.",
    "..dddyyyyyyy.",
    ".ddddyyyyyyy.",
    "..ddddyyyyy..",
    "...ooo..ooo.."
]

/// Cardboard box stealth disguise ($13 \times 10$).
let DUCK_STEALTH_BOX_DISGUISE: [String] = [
    ".............",
    ".aaaaaaaaaaa.",
    ".aaaaaaaaaaa.",
    ".aawwaawaawa.",
    ".aaaaaaaaaaa.",
    ".aaaaaaaaaaa.",
    ".aaaaaaaaaaa.",
    ".aaaaaaaaaaa.",
    ".aaaaaaaaaaa.",
    "...oo...oo..."
]

/// Heroic dramatic leap.
let DUCK_STEALTH_LEAP: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyyyoo",
    "ddyyyyyyyyyy.",
    "dddyyyyyyyyy.",
    ".ddddyyyyyy..",
    "..ooo..ooo...",
    "............."
]

// MARK: - Wave 6 & 7.1: Secondary Actors (Girl Duck)

/// Girl Duck Idle (Pink/magenta bow accent on skull crown, canonical TimeDuck proportions).
let ACTOR_GIRL_DUCK_BASE: [String] = [
    "..mm.yyyy....",
    ".mmmm..yy....",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Idle breathing bob.
let ACTOR_GIRL_DUCK_IDLE_B: [String] = [
    ".............",
    "..mm.yyyy....",
    ".mmmm..yy....",
    "...yyykpy....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    "..dddyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Alert Notice (Notices TimeDuck).
let ACTOR_GIRL_DUCK_NOTICE: [String] = [
    "..mm.yyyy....",
    ".mmmm..yy....",
    "...yykwpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Waddle A (Moving stride).
let ACTOR_GIRL_DUCK_WADDLE_A: [String] = [
    "..mm.yyyy....",
    ".mmmm..yy....",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

/// Girl Duck Waddle B.
let ACTOR_GIRL_DUCK_WADDLE_B: [String] = [
    "...mm.yyy....",
    "..mmmm.yy....",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "..oo...oo...."
]

/// Girl Duck Kick Anticipation (Wind-up lean back).
let ACTOR_GIRL_DUCK_KICK_ANTICIPATE: [String] = [
    ".mm..yyyy....",
    "mmmm...yy....",
    "..yyy.ykpy...",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyy...",
    "..ddyyyyyoo..",
    "...oo........"
]

/// Girl Duck Kicking vent open (Foot extended horizontally contacting vent).
let ACTOR_GIRL_DUCK_KICK: [String] = [
    "...mm.yyyy...",
    "..mmmm..yy...",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyooo",
    "..ddyyyyyyy..",
    "...oo........"
]

/// Girl Duck Kick Recovery (Foot planting back).
let ACTOR_GIRL_DUCK_KICK_RECOVER: [String] = [
    "..mm.yyyy....",
    ".mmmm..yy....",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Cheerful victory A (Wings raised).
let ACTOR_GIRL_DUCK_CHEER_A: [String] = [
    ".d..mm.yyyy.d",
    ".d.mmmm..yy.d",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Cheerful victory B.
let ACTOR_GIRL_DUCK_CHEER_B: [String] = [
    "..d.mm.yyyy.d",
    "...mmmm..yy..",
    "...yyykpy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let ACTOR_GIRL_DUCK_CHEER = ACTOR_GIRL_DUCK_CHEER_A

/// Girl Duck Peck A (Pecking breadcrumb with bow & blush)
let ACTOR_GIRL_DUCK_PECK_A: [String] = [
    ".............",
    "..mm.........",
    ".mmmm.yyyy...",
    "...yyykpyoo..",
    "..yyyyyyyoo..",
    ".dyyyyyyy....",
    "dddyyyyyy....",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Peck B (Beak to floor with bow & blush)
let ACTOR_GIRL_DUCK_PECK_B: [String] = [
    ".............",
    ".............",
    "..mm.yyyy....",
    ".mmmm.yyy....",
    "...yyykpy....",
    "..yyyyyy.....",
    ".dyyyyyyoo...",
    "dddyyyyyyoo..",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

/// Girl Duck Sleep (Sleeping pose with bow & blush)
let ACTOR_GIRL_DUCK_SLEEP: [String] = [
    ".............",
    ".............",
    "..mm.........",
    ".mmmm.yyyy...",
    "...yyyykpy...",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    "ddddyyyyyy...",
    ".ddddddddd...",
    "..oooooooo..."
]

/// Girl Duck Chonky Base (Absolute unit with bow & blush)
let GIRL_DUCK_CHONK_BASE: [String] = [
    "...mm.yyyy.....",
    "..mmmm..yy.....",
    "....yyykpy.....",
    "...yyyyyyooo...",
    "..yyyyyyyyyoo..",
    ".dyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    ".ddyyyyyyyyyy..",
    "..ddddyyyyyy...",
    "...dddddddd....",
    "....oooo.oooo.."
]

// MARK: - Wave 6 & 7.1: Secondary Actors (Guard Duck)

/// Guard Duck Base (TimeDuck with security cap, chest badge, and flashlight).
let ACTOR_GUARD_DUCK_BASE: [String] = [
    "..kkkk.......",
    ".kkkkkk......",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddywayyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Guard Duck Peck A (Tactical sample intake with cap)
let ACTOR_GUARD_DUCK_PECK_A: [String] = [
    ".............",
    "..kkkk.......",
    ".kkkkkkyyy...",
    "...yyykwyoo..",
    "..yyyyyyyoo..",
    ".ddywayyy....",
    "dddyyyyyy....",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Guard Duck Peck B (Tactical floor inspection with cap)
let ACTOR_GUARD_DUCK_PECK_B: [String] = [
    ".............",
    ".............",
    "..kkkkyyyy...",
    ".kkkkkkyyy...",
    "...yyykwy....",
    "..yyyyyy.....",
    ".ddywayyoo...",
    "dddyyyyyyoo..",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

/// Guard Duck Sleep (Sleeping at security desk with cap)
let ACTOR_GUARD_DUCK_SLEEP: [String] = [
    ".............",
    ".............",
    "..kkkk.......",
    ".kkkkkkyyy...",
    "...yyyykwy...",
    "..yyyyyyooo..",
    ".ddywayyyoo..",
    "ddddyyyyyy...",
    ".ddddddddd...",
    "..oooooooo..."
]

/// Guard Duck Chonky Base (Heavy tactical unit with cap)
let GUARD_DUCK_CHONK_BASE: [String] = [
    "...kkkk........",
    "..kkkkkkyy.....",
    "....yyykwy.....",
    "...yyyyyyooo...",
    "..yyywayyyyoo..",
    ".dyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    ".ddyyyyyyyyyy..",
    "..ddddyyyyyy...",
    "...dddddddd....",
    "....oooo.oooo.."
]

/// Guard Duck Patrol A (Walk waddle stride).
let ACTOR_GUARD_DUCK_PATROL_A: [String] = [
    "..kkkk.......",
    ".kkkkkk......",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo.k",
    ".ddywayyyy.kw",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

/// Guard Duck Patrol B.
let ACTOR_GUARD_DUCK_PATROL_B: [String] = [
    "...kkkk......",
    "..kkkkkk.....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo.k",
    ".ddywayyyy.kw",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "..oo...oo...."
]

/// Guard Duck Stop (Decelerate and plant feet).
let ACTOR_GUARD_DUCK_STOP: [String] = [
    "..kkkk.......",
    ".kkkkkk......",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo.k",
    ".ddywayyyy.kw",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...ooo..ooo.."
]

/// Guard Duck Turn (Front-facing pivot frame before changing direction).
let ACTOR_GUARD_DUCK_TURN: [String] = [
    "...kkkkkk....",
    "..kkkkkkkk...",
    "...ywk.kwy...",
    "...yyoooyy...",
    "..dyyyyyyd.k.",
    "..ddywayyddkw",
    ".dddyyyyyydd.",
    "..dddddddd...",
    "...dddddd....",
    "...oo..oo...."
]

/// Guard Duck Suspicious (Side-eye inspection).
let ACTOR_GUARD_DUCK_SUSPICIOUS: [String] = [
    "..kkkk.......",
    ".kkkkkk......",
    "...yyy-ky....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo.k",
    ".ddywayyyy.kw",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Guard Duck Alert with Flashlight Beam.
let ACTOR_GUARD_DUCK_ALERT: [String] = [
    "..kkkk....www",
    ".kkkkkk..wwww",
    "...yyykwywwww",
    "..yyyyyyoooww",
    ".dyyyyyyyookw",
    ".ddywayyyy.kw",
    "dddyyyyyyy.ww",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let ACTOR_GUARD_DUCK_FLASHLIGHT = ACTOR_GUARD_DUCK_ALERT

// MARK: - Wave 7.1: Transition & Anticipation Sprites (TimeDuck)

/// Braking plant frame for run-to-stop or waddle-to-stop.
let DUCK_BRAKE_STOP: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    ".ooo....ooo.."
]

/// Half-crouch transition between standing and sitting loaf.
let DUCK_SIT_TRANSITION: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    ".ddddyyyyyy..",
    "...ooo.ooo..."
]

/// Bread peck anticipation (head pulls back slightly before pecking).
let DUCK_PECK_ANTICIPATE: [String] = [
    ".....yyyy....",
    "....yyyyyy...",
    "....yyykwy...",
    "...yyyyyyooo.",
    "..dyyyyyyyoo.",
    "..ddyyyyyyy..",
    ".dddyyyyyyy..",
    "..ddddyyyyyy.",
    "...ddyyyyyyy.",
    "....oo..oo..."
]

/// Bread peck recovery (head lifts up with crumb).
let DUCK_PECK_RECOVER: [String] = [
    "...yyyy......",
    "..yyyyyy.....",
    "..yyykwy.....",
    ".yyyyyyoooa..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// Weight lifting brace (knees and wings brace before dumbbell curl).
let DUCK_WEIGHT_BRACE: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "..ooo..ooo..."
]

/// Leap anticipation (deep crouch spring before launch).
let DUCK_LEAP_ANTICIPATE: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwyooo.",
    "..dyyyyyyyoo.",
    ".ddddyyyyyy..",
    "dddddyyyyyy..",
    ".ddddyyyyyy..",
    "...oooooo...."
]

/// Leap landing cushion (feet spread, absorbing impact).
let DUCK_LEAP_LAND: [String] = [
    ".............",
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    ".ddddyyyyyy..",
    ".ooo....ooo.."
]

// MARK: - Wave 6: Procedural Scenery & Prop Matrices

/// $7 \times 5$ folded map.
let PROP_MAP: [String] = [
    "wwwwwww",
    "wawaaww",
    "waaaaww",
    "wawaaww",
    "wwwwwww"
]

/// $7 \times 10$ summit flag on pole - Frame 1.
let PROP_SUMMIT_FLAG_FRAME1: [String] = [
    "krrrrr.",
    "krrrrrr",
    "krrrrr.",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "sssssss"
]

/// $7 \times 10$ summit flag on pole - Frame 2 (wave).
let PROP_SUMMIT_FLAG_FRAME2: [String] = [
    "k.rrrrr",
    "krrrrrr",
    "k.rrrr.",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "sssssss"
]

/// $7 \times 10$ summit flag on pole - Frame 3 (wave).
let PROP_SUMMIT_FLAG_FRAME3: [String] = [
    "krrrrr.",
    "k.rrrrr",
    "krrrrrr",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "k......",
    "sssssss"
]

let PROP_SUMMIT_FLAG = PROP_SUMMIT_FLAG_FRAME1

/// $7 \times 7$ wooden trail sign.
let PROP_TRAIL_SIGN: [String] = [
    "aaaaaaa",
    "akkkkka",
    "aaaaaaa",
    "...a...",
    "...a...",
    "...a...",
    ".sssss."
]

/// $7 \times 6$ cozy tiny campfire - Flame 1.
let PROP_CAMPFIRE_FRAME1: [String] = [
    "...r...",
    "..ror..",
    ".rooor.",
    "..ror..",
    ".aaaaa.",
    "aaaaaaa"
]

/// $7 \times 6$ cozy tiny campfire - Flame 2 (shifted left + spark).
let PROP_CAMPFIRE_FRAME2: [String] = [
    "..r..w.",
    ".rror..",
    ".roor..",
    "..ror..",
    ".aaaaa.",
    "aaaaaaa"
]

/// $7 \times 6$ cozy tiny campfire - Flame 3 (shifted right + spark).
let PROP_CAMPFIRE_FRAME3: [String] = [
    ".w..r..",
    "..rorr.",
    "..roor.",
    "..ror..",
    ".aaaaa.",
    "aaaaaaa"
]

/// $7 \times 6$ cozy tiny campfire - Flame 4 (ember burst).
let PROP_CAMPFIRE_FRAME4: [String] = [
    "..ror..",
    ".rooor.",
    ".roror.",
    "..ror..",
    ".aaaaa.",
    "aaaaaaa"
]

let PROP_CAMPFIRE = PROP_CAMPFIRE_FRAME1

/// $5 \times 6$ steaming coffee cup - Steam Frame 1.
let PROP_COFFEE_CUP_FRAME1: [String] = [
    ".s.s.",
    "wwwww",
    "waaaw",
    "waaaw",
    ".www.",
    "....."
]

/// $5 \times 6$ steaming coffee cup - Steam Frame 2.
let PROP_COFFEE_CUP_FRAME2: [String] = [
    "..s.s",
    "wwwww",
    "waaaw",
    "waaaw",
    ".www.",
    "....."
]

let PROP_COFFEE_CUP = PROP_COFFEE_CUP_FRAME1

/// $5 \times 9$ stack of empty coffee cups.
let PROP_COFFEE_STACK: [String] = [
    "wwwww",
    "waaaw",
    ".www.",
    "wwwww",
    "waaaw",
    ".www.",
    "wwwww",
    "waaaw",
    ".www."
]

/// $11 \times 9$ elliptical machine frame - Pedal A.
let PROP_ELLIPTICAL_FRAME_A: [String] = [
    "...s...s...",
    "...s...s...",
    "..ss...ss..",
    "..s.....s..",
    ".ss.....ss.",
    ".s.......s.",
    "sssssssssss",
    "..sss.sss..",
    ".sssssssss."
]

/// $11 \times 9$ elliptical machine frame - Pedal B.
let PROP_ELLIPTICAL_FRAME_B: [String] = [
    "...s...s...",
    "...s...s...",
    "..ss...ss..",
    "..s.....s..",
    ".ss.....ss.",
    ".s.......s.",
    "sssssssssss",
    ".sss...sss.",
    ".sssssssss."
]

let PROP_ELLIPTICAL_FRAME = PROP_ELLIPTICAL_FRAME_A

/// $12 \times 6$ treadmill base & rails - Belt 1.
let PROP_TREADMILL_FRAME_A: [String] = [
    "s..........s",
    "s..........s",
    "ssssssssssss",
    ".ssssssssss.",
    "k.k.k.k.k.k.",
    "ssssssssssss"
]

/// $12 \times 6$ treadmill base & rails - Belt 2.
let PROP_TREADMILL_FRAME_B: [String] = [
    "s..........s",
    "s..........s",
    "ssssssssssss",
    ".ssssssssss.",
    ".k.k.k.k.k.k",
    "ssssssssssss"
]

let PROP_TREADMILL_FRAME = PROP_TREADMILL_FRAME_A

/// $7 \times 4$ tiny dumbbell rack.
let PROP_DUMBBELLS: [String] = [
    "k.k.k.k",
    "k.k.k.k",
    "sssssss",
    "s.....s"
]

/// $10 \times 8$ gym workout chalkboard.
let PROP_WORKOUT_BOARD: [String] = [
    "aaaaaaaaaa",
    "akkkkkkkka",
    "akwwwwwwka",
    "akwwwwwwka",
    "akwwwwwwka",
    "akwwwwwwka",
    "aaaaaaaaaa",
    "..a....a.."
]

/// $6 \times 5$ security camera pointing left.
let PROP_SECURITY_CAMERA_LEFT: [String] = [
    "ssssss",
    "skkkks",
    "rrkkss",
    ".sssss",
    "...s.."
]

/// $6 \times 5$ security camera pointing center.
let PROP_SECURITY_CAMERA_CENTER: [String] = [
    "ssssss",
    "skkkks",
    "skrrks",
    ".sssss",
    "...s.."
]

/// $6 \times 5$ security camera pointing right.
let PROP_SECURITY_CAMERA_RIGHT: [String] = [
    "ssssss",
    "skkkks",
    "sskkrr",
    "sssss.",
    "..s..."
]

/// $8 \times 8$ facility wall vent grille (intact).
let PROP_FACILITY_VENT: [String] = [
    "ssssssss",
    "skkkkkks",
    "skkkkkks",
    "ssssssss",
    "skkkkkks",
    "skkkkkks",
    "ssssssss",
    "ssssssss"
]

/// $8 \times 8$ facility wall vent grille (kicked open ajar).
let PROP_FACILITY_VENT_OPEN: [String] = [
    "ssssssss",
    "skkkkkks",
    "skkkkkks",
    "skkkkks.",
    "skkkks..",
    "skkks...",
    "ssss....",
    "ssssssss"
]

/// $9 \times 8$ facility storage crate.
let PROP_METAL_CRATE: [String] = [
    "sssssssss",
    "saaaaaaas",
    "sa.a.a.as",
    "sa..a..as",
    "sa.a.a.as",
    "saaaaaaas",
    "sssssssss",
    "sssssssss"
]

/// $6 \times 5$ overhead flashing security beacon ON.
let PROP_SECURITY_LIGHT_ON: [String] = [
    ".rrrr.",
    "rrrrrr",
    "rrrrrr",
    "ssssss",
    "..ss.."
]

/// $6 \times 5$ overhead flashing security beacon OFF.
let PROP_SECURITY_LIGHT_OFF: [String] = [
    ".kkkk.",
    "kkkkkk",
    "kkkkkk",
    "ssssss",
    "..ss.."
]

let PROP_SECURITY_LIGHT = PROP_SECURITY_LIGHT_ON

/// $7 \times 5$ climbing trail rock A.
let PROP_CLIMB_ROCK_A: [String] = [
    "...ss..",
    "..ssss.",
    ".ssssss",
    "sssssss",
    "sssssss"
]

/// $9 \times 6$ climbing trail rock B.
let PROP_CLIMB_ROCK_B: [String] = [
    "....sss..",
    "...sssss.",
    "..sssssss",
    ".ssssssss",
    "sssssssss",
    "sssssssss"
]

// ── Living Scene Duck Poses ──────────────────────────────────────────────────

/// TimeDuck poking campfire with tiny stick.
let DUCK_POKE_FIRE_A: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo.a",
    ".dyyyyyyyoo.a",
    ".ddyyyyyyy..a",
    "dddyyyyyyy..a",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let DUCK_POKE_FIRE_B: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyykwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyooa.",
    ".ddyyyyyyy.a.",
    "dddyyyyyyy.aa",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// TimeDuck sitting cozy warming wings by campfire.
let DUCK_WARM_WINGS: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...yyy^^y....",
    "..yyyyyyooop.",
    ".dyyyyyyyyy..",
    "ddyyyyyyyyy..",
    "dddyyyyyyyy..",
    ".ddddyyyyyy..",
    "..dddddddd...",
    "............."
]

/// TimeDuck leaning determined into high-altitude mountain wind.
let DUCK_WIND_LEAN_A: [String] = [
    "...yyyy......",
    "..yyyyyy.....",
    "..yyykwy.....",
    ".yyyyyyooo...",
    "dyyyyyyyoo...",
    "ddyyyyyyy....",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

let DUCK_WIND_LEAN_B: [String] = [
    "...yyyy......",
    "..yyyyyy.....",
    "..yyykwy.....",
    ".yyyyyyooo...",
    "dyyyyyyyoo...",
    "ddyyyyyyy....",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "..oo.....oo.."
]

/// TimeDuck posing for imaginary summit victory photo.
let DUCK_SUMMIT_PHOTO: [String] = [
    "....d..d.....",
    "....yyyy.....",
    "...yyy^^y.w..",
    "..yyyyyypooow",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// ── Sprite Aliases for Story Compatibility ────────────────────────────────────
let DUCK_WADDLE_A: [String] = DUCK_RUN_A
let DUCK_WADDLE_B: [String] = DUCK_RUN_B
let DUCK_FEATHER_RUFFLE_A: [String] = DUCK_RUFFLE_A
let DUCK_FEATHER_RUFFLE_B: [String] = DUCK_RUFFLE_B
let DUCK_HEAD_TILT: [String] = DUCK_PEEK_A
let DUCK_CURIOUS_PEEK: [String] = DUCK_PEEK_A
let DUCK_WING_STRETCH: [String] = DUCK_YAY_A

// MARK: - Wave 7: Compact MiniHUD Story Micro-Sprites & Props

/// $5 \times 5$ micro wooden trail sign.
let PROP_MINI_TRAIL_SIGN: [String] = [
    "aaaaa",
    "akkka",
    "aaaaa",
    "..a..",
    ".sss."
]

/// $5 \times 4$ micro animated campfire.
let PROP_MINI_CAMPFIRE_A: [String] = [
    "..r..",
    ".ror.",
    ".aaa.",
    "aaaaa"
]

let PROP_MINI_CAMPFIRE_B: [String] = [
    ".w.r.",
    "..ror",
    ".aaa.",
    "aaaaa"
]

/// $4 \times 3$ micro trail rock.
let PROP_MINI_ROCK: [String] = [
    ".ss.",
    "ssss",
    "ssss"
]

/// $5 \times 6$ micro animated summit flag.
let PROP_MINI_SUMMIT_FLAG_A: [String] = [
    "krrr.",
    "krrrr",
    "krrr.",
    "k....",
    "k....",
    "sssss"
]

let PROP_MINI_SUMMIT_FLAG_B: [String] = [
    "k.rrr",
    "krrrr",
    "k.rr.",
    "k....",
    "k....",
    "sssss"
]

/// $4 \times 4$ micro steaming coffee cup.
let PROP_MINI_COFFEE_A: [String] = [
    ".s..",
    "wwww",
    "waaw",
    ".ww."
]

let PROP_MINI_COFFEE_B: [String] = [
    "..s.",
    "wwww",
    "waaw",
    ".ww."
]

/// $8 \times 7$ micro elliptical machine frame.
let PROP_MINI_ELLIPTICAL_A: [String] = [
    "..s...s.",
    "..s...s.",
    ".ss...ss",
    "ssssssss",
    ".sss.sss",
    "..sssss.",
    ".sssssss"
]

let PROP_MINI_ELLIPTICAL_B: [String] = [
    "..s...s.",
    "..s...s.",
    ".ss...ss",
    "ssssssss",
    "sss...ss",
    "..sssss.",
    ".sssssss"
]

/// $9 \times 4$ micro treadmill.
let PROP_MINI_TREADMILL_A: [String] = [
    "s.......s",
    "sssssssss",
    ".k.k.k.k.",
    "sssssssss"
]

let PROP_MINI_TREADMILL_B: [String] = [
    "s.......s",
    "sssssssss",
    "k.k.k.k..",
    "sssssssss"
]

/// $5 \times 3$ micro dumbbell rack.
let PROP_MINI_DUMBBELLS: [String] = [
    "k.k.k",
    "sssss",
    "s...s"
]

/// $4 \times 3$ micro security camera.
let PROP_MINI_SECURITY_CAMERA_L: [String] = [
    "ssss",
    "rrks",
    ".ss."
]

let PROP_MINI_SECURITY_CAMERA_R: [String] = [
    "ssss",
    "skrr",
    ".ss."
]

/// $6 \times 5$ micro metal crate.
let PROP_MINI_METAL_CRATE: [String] = [
    "ssssss",
    "saaaas",
    "sa..as",
    "saaaas",
    "ssssss"
]

/// $9 \times 8$ micro Guard Duck actor with security cap & badge.
let ACTOR_MINI_GUARD_DUCK_A: [String] = [
    "..kkkk...",
    "..kkkk...",
    "...ykwyoo",
    "..ywayyoo",
    ".dyyyyyy.",
    ".ddyyyyy.",
    "..ddyyyy.",
    "...oo.oo."
]

let ACTOR_MINI_GUARD_DUCK_B: [String] = [
    "..kkkk...",
    "..kkkk...",
    "...ykwyoo",
    "..ywayyoo",
    ".ddyyyyy.",
    "..ddyyyy.",
    "...ddyyy.",
    "..oo...oo"
]

/// $9 \times 8$ micro Girl Duck actor with magenta bow and blush cheek.
let ACTOR_MINI_GIRL_DUCK_A: [String] = [
    "..mm.mm..",
    "..yyyyy..",
    "...ykpyoo",
    "..yyyyyoo",
    ".dyyyyyy.",
    ".ddyyyyy.",
    "..ddyyyy.",
    "...oo.oo."
]

let ACTOR_MINI_GIRL_DUCK_B: [String] = [
    "..mm.mm..",
    "..yyyyy..",
    "...ykpyoo",
    "..yyyyyoo",
    ".ddyyyyy.",
    "..ddyyyy.",
    "...ddyyy.",
    "..oo...oo"
]

// ── Clock Acknowledgment Poses ───────────────────────────────────────────────

/// TimeDuck looking left toward the primary timer digits.
let DUCK_GLANCE_CLOCK: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...ykwyyy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// TimeDuck pointing wing toward the primary timer digits.
let DUCK_POINT_CLOCK: [String] = [
    "....yyyy.....",
    "...yyyyyy....",
    "...ykwyyy....",
    ".dyyyyyyooo..",
    "dddyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

// ── Sleep FX Snore Z Glyphs ──────────────────────────────────────────────────

/// $3 \times 3$ micro snore z glyph.
let GLYPH_SNORE_Z_SMALL: [String] = [
    "zzz",
    "..z",
    "zzz"
]

/// $4 \times 4$ medium snore Z glyph.
let GLYPH_SNORE_Z_MED: [String] = [
    "zzzz",
    "...z",
    "..z.",
    "zzzz"
]

/// $5 \times 5$ large snore Z glyph.
let GLYPH_SNORE_Z_LARGE: [String] = [
    "zzzzz",
    "....z",
    "..zz.",
    ".z...",
    "zzzzz"
]







// MARK: - Wave 8: TimeCompanions & Achievements Sprites

// ── Companion Portrait Badges (10x10) ──────────────────────────────────────────

let PORTRAIT_TIMEDUCK: [String] = [
    "...yyyy...",
    "..yyyyyy..",
    "..yyykwy..",
    ".yyyyyyooo",
    ".dyyyyyyoo",
    ".ddyyyyyy.",
    "dddyyyyyy.",
    ".ddddyyyy.",
    "..ddyyyy..",
    "...oo..oo."
]

let PORTRAIT_GIRL_DUCK: [String] = [
    ".mm.yyyy..",
    "mmmm..yy..",
    "..yyykpy..",
    ".yyyyyyooo",
    ".dyyyyyyoo",
    ".ddyyyyyy.",
    "dddyyyyyy.",
    ".ddddyyyy.",
    "..ddyyyy..",
    "...oo..oo."
]

let PORTRAIT_GUARD_DUCK: [String] = [
    ".kkkk.....",
    "kkkkkk....",
    "..yyykwy..",
    ".yyyyyyooo",
    ".dyyyyyyoo",
    ".ddywayyy.",
    "dddyyyyyy.",
    ".ddddyyyy.",
    "..ddyyyy..",
    "...oo..oo."
]

let PORTRAIT_DUCKLING: [String] = [
    "..........",
    "..........",
    "...yyyy...",
    "..yykkwy..",
    "..yyyyyooo",
    "..dyyyyyoo",
    ".ddyyyyy..",
    ".dddyyyy..",
    "..ddyyyy..",
    "...o..o..."
]

let PORTRAIT_CYBER_DUCK: [String] = [
    "...bbbb...",
    "..bbbbbb..",
    "..yybbby..",
    ".yyyyyyooo",
    ".dyyyyyyoo",
    ".ddyyyyyy.",
    "dddyyyyyy.",
    ".ddddyyyy.",
    "..ddyyyy..",
    "...oo..oo."
]

let PORTRAIT_LOCKED_SECRET: [String] = [
    "..kkkkkk..",
    ".kk....kk.",
    ".k..kk..k.",
    "....kk..k.",
    "...kkk....",
    "...kkk....",
    "..........",
    "...kkk....",
    "...kkk....",
    ".........."
]

// ── Duckling (Tiny Duck) Full Sprites (13x10) ────────────────────────────────

let DUCKLING_BASE: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_IDLE_B: [String] = [
    ".............",
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwyooo.",
    ".dyyyyyyypoo.",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_IDLE_WAG: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    "ddyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_RUN_A: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "....o...o...."
]

let DUCKLING_RUN_B: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "..o...o......"
]

let DUCKLING_RUN_C: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    "ddyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_YAY_A: [String] = [
    ".............",
    "....d..d.....",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_YAY_B: [String] = [
    ".............",
    "...d....d....",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "....oooo....."
]

let DUCKLING_SLEEP: [String] = [
    ".............",
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkk.....",
    "..yyyyyyooo..",
    ".ddyyyyyyoo..",
    "ddddyyyyy....",
    "..dddddd.....",
    "...oooo......"
]

let DUCKLING_PECK_A: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yyyykkwy..",
    "..dyyyyyyoo..",
    ".ddyyyyyyooo.",
    "dddyyyyyyyoo.",
    "..ddyyyyy....",
    "...o...o.....",
    "............."
]

let DUCKLING_PECK_B: [String] = [
    ".............",
    ".............",
    ".............",
    "....yyyy.....",
    "...yyyykkwy..",
    ".dddyyyyyoo..",
    "..ddyyyyyooo.",
    "..ddyyyyyooo.",
    "...o...o...o.",
    "............."
]

let DUCKLING_LOOK_UP: [String] = [
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyyyoo..",
    "..yyyyyyyoo..",
    ".dyyyyyyy....",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..ddyyyy.....",
    "...o...o....."
]

let DUCKLING_SIT: [String] = [
    ".............",
    ".............",
    "....yyyy.....",
    "...yykkwy....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyy....",
    "dddyyyyyy....",
    "..dddddd.....",
    "............."
]

let DUCKLING_CHAOS: [String] = [
    "....d..d.....",
    "...dyyyyd....",
    "...yykkwy....",
    "..yyyyyyooooo",
    ".dyyyyyyy.oo.",
    "dddyyyyyy....",
    ".dddyyyyy....",
    "..ddyyyy.....",
    "...o...o.....",
    "............."
]

/// Duckling Chonky Base (Tiny round ball chick)
let DUCKLING_CHONK_BASE: [String] = [
    "....yyyyy....",
    "...yykkwyy...",
    "..yyyyyyyyooo",
    ".dyyyyyyyyoo.",
    "ddyyyyyyyyy..",
    "ddyyyyyyyyy..",
    ".ddyyyyyyyy..",
    "..ddddyyyy...",
    "...dddddd....",
    "....oo.oo...."
]

// ── CyberDuck (Secret Companion) Sprites (13x10) ─────────────────────────────

let CYBER_DUCK_BASE: [String] = [
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck Idle B (Breathing phosphor clock cycle)
let CYBER_DUCK_IDLE_B: [String] = [
    ".............",
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyyooo..",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "ddddyyyyyyy..",
    "..dddyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck Matrix Phosphor Pulse (Quantum scan pattern)
let CYBER_DUCK_MATRIX_PULSE: [String] = [
    "....vvvv.....",
    "...vbbbbv....",
    "...yybbby....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyvyyyyy...",
    "dddyvyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let CYBER_DUCK_RUN_A: [String] = [
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "....oo...oo.."
]

let CYBER_DUCK_RUN_B: [String] = [
    ".............",
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    "..ddyyyyyy...",
    "..oo....oo..."
]

let CYBER_DUCK_RUN_C: [String] = [
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyypooo.",
    "ddyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo...oo..."
]

let CYBER_DUCK_YAY_A: [String] = [
    "....b..b.....",
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

let CYBER_DUCK_YAY_B: [String] = [
    "...b....b....",
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbby....",
    "..yyyyyypooo.",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    "..ddyyyyyy...",
    "....oooo....."
]

let CYBER_DUCK_SLEEP: [String] = [
    ".............",
    ".............",
    "....bbbb.....",
    "...bbbbbb....",
    "...yykkky....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    "ddddyyyyyy...",
    ".ddddddddd...",
    "..oooooooo..."
]

/// CyberDuck System Boot / Power On
let CYBER_DUCK_BOOT: [String] = [
    "....b..b.....",
    "...bbbbbb....",
    "...yykwby....",
    "..yyyyyyooo..",
    ".dyyyyyyyoo..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck Data Ingestion / Byte Feed A
let CYBER_DUCK_EAT_A: [String] = [
    ".............",
    "....bbbb.....",
    "...bbbbbb....",
    "...yybbbyooo.",
    "..yyyyyyyoo..",
    ".dyyyyyyy....",
    "dddyyyyyy....",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck Data Ingestion / Byte Feed B
let CYBER_DUCK_EAT_B: [String] = [
    ".............",
    ".............",
    "....bbbb.....",
    "...bbbbbby...",
    "...yybbby....",
    "..yyyyyy.....",
    ".dyyyyyyoo...",
    "dddyyyyyyoo..",
    ".ddddyyyyyy..",
    "...oo..oo...."
]

let CYBER_DUCK_GLITCH: [String] = [
    "....vvvv.....",
    "...vvvvvv....",
    "...yyvvvy....",
    "..yyyyyymooo.",
    ".dyyyyyyymm..",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck High-Voltage Shock / Poke Defense Reaction
let CYBER_DUCK_SHOCK: [String] = [
    "....vvvv..v..",
    "...vvvvvv.vv.",
    "...yybbbyv...",
    "..yyyyyymooo.",
    ".dyyyyyyymm..",
    "vddyyyyyyy...",
    "vdddyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

let CYBER_DUCK_SCAN: [String] = [
    "....bbbb.....",
    "...bbbbbb.bbb",
    "...yybbbybbbb",
    "..yyyyyyooobb",
    ".dyyyyyyyoo.b",
    ".ddyyyyyyy...",
    "dddyyyyyyy...",
    ".ddddyyyyyy..",
    "..ddyyyyyyy..",
    "...oo..oo...."
]

/// CyberDuck Chonky Base (Overclocked Buffer Overflow Unit)
let CYBER_DUCK_CHONK_BASE: [String] = [
    "...bbbb........",
    "..bbbbbbby.....",
    "....yybbby.....",
    "...yyyyyyooo...",
    "..yyyyyyyyyoo..",
    ".dyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    "ddyyyyyyyyyyy..",
    ".ddyyyyyyyyyy..",
    "..ddddyyyyyy...",
    "...dddddddd....",
    "....oooo.oooo.."
]

// ── Achievement Badge Stamps (5x5) ───────────────────────────────────────────

let BADGE_GLYPH_TIMER: [String] = [
    ".www.",
    "w...w",
    "w.w.w",
    "w...w",
    ".www."
]

let BADGE_GLYPH_POMO: [String] = [
    "..g..",
    ".rrr.",
    "rrrrr",
    "rrrrr",
    ".rrr."
]

let BADGE_GLYPH_STAR: [String] = [
    "..a..",
    ".aaa.",
    "aaaaa",
    ".a.a.",
    "a...a"
]

let BADGE_GLYPH_CROWN: [String] = [
    "a.a.a",
    "aaaaa",
    "aaaaa",
    "rrrrr",
    "....."
]

let BADGE_GLYPH_HEART: [String] = [
    ".r.r.",
    "rrrrr",
    "rrrrr",
    ".rrr.",
    "..r.."
]

let BADGE_GLYPH_SHIELD: [String] = [
    "bbbbb",
    "bwwwb",
    "bwwwb",
    ".bbb.",
    "..b.."
]

let BADGE_GLYPH_BREAD: [String] = [
    ".aaa.",
    "aaaaa",
    "aaaaa",
    "aaaaa",
    ".aaa."
]

let BADGE_GLYPH_SUN: [String] = [
    "a.a.a",
    ".aaa.",
    "aaaaa",
    ".aaa.",
    "a.a.a"
]

let BADGE_GLYPH_MOON: [String] = [
    "..bb.",
    ".bbb.",
    ".bbb.",
    ".bbb.",
    "..bb."
]

let BADGE_GLYPH_FLAG: [String] = [
    "krrr.",
    "krrrr",
    "krrr.",
    "k....",
    "k...."
]

let BADGE_GLYPH_GHOST: [String] = [
    ".bbb.",
    "bwkwb",
    "bbbbb",
    "bbbbb",
    "b.b.b"
]

let BADGE_GLYPH_LOCKED: [String] = [
    ".kkk.",
    "k...k",
    "kkkkk",
    "kkkkk",
    "kkkkk"
]

let BADGE_GLYPH_SECRET: [String] = [
    ".kkk.",
    "..k.k",
    "...k.",
    ".....",
    "...k."
]
