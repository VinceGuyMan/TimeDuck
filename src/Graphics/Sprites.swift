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
    "&": [2,5,2,5,3], "•": [0,2,2,0,0], "·": [0,0,2,0,0], "▸": [4,6,7,6,4],
    "►": [4,6,7,6,4], "~": [0,5,2,0,0],
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
func getDuckColorMap() -> [Character: Color] {
    [
        "y": Pal.duckBody, "d": Pal.duckShad, "o": Pal.duckBill,
        "k": Pal.duckEye,  "w": Pal.white,    "p": Pal.cheek,
        "b": Pal.cyan,     "v": Pal.violet,   "m": Pal.magenta,
        "g": Pal.green,    "r": Pal.red,      "a": Pal.amber,
        "s": Pal.sweat,    "-": Pal.duckEye,  "^": Pal.duckEye,
        "z": Pal.cyan
    ]
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

// ── Hat Overlays ─────────────────────────────────────────────────────────────

let HAT_WIZARD: [String] = [
    ".....v.......",
    "....vvv......",
    "...vvavv.....",
    "..vvvvvvv....",
    ".vvvvvvvvv...",
    "............."
]

let HAT_DETECTIVE: [String] = [
    ".............",
    "....aaaa.....",
    "...aaaaaa....",
    "..aaaaaaaa...",
    "aaaaaaaaaaaa.",
    "............."
]

let HAT_CYBER: [String] = [
    ".............",
    ".............",
    "....bbbbbb...",
    "...bbbbbbbb..",
    ".............",
    "............."
]

let HAT_BARISTA: [String] = [
    ".............",
    "...wwwwww....",
    "...wwwwww....",
    "..gggggggg...",
    ".............",
    "............."
]

let HAT_SLEEPCAP: [String] = [
    "....rrrrww...",
    "...rrrrrrw...",
    "..rrrrrrrr...",
    ".rrrrrrrrr...",
    "wwwwwwwwwww..",
    "............."
]

let HAT_CROWN: [String] = [
    ".............",
    "...a.a.a.....",
    "...aaaaa.....",
    "...aaaaa.....",
    "..rrrrrrr....",
    "............."
]

// ── Tactical Bandana Collection (Wave 1) ─────────────────────────────────────

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
let HAT_BANDANA_FOREST_CAMO = HAT_BANDANA_FOREST

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
let HAT_BANDANA_DESERT_CAMO = HAT_BANDANA_DESERT
