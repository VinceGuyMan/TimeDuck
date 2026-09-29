// MARK: - TimeDuck · DuckBrain.swift
// Duck personality, expanded phrase library, behavioral phases,
// low-cost idle behaviors, contextual reactions, and rare events.

import Foundation

// MARK: - Duck Pose

enum DuckPose: Equatable, Hashable {
    case standing
    case waddling
    case celebrating
    case quacking
    case petting
    case pecking
    case relaxing
    case sleeping
    case headTilt
    case preening
    case sitting
    case tactical
    case sideEye
    case lookingBack
    case grooving
    case shuffling
    case featherRuffle
    case curiousPeek

    // Wave 5: New Idle Behaviors
    case wingStretch
    case yawning
    case investigating
    case confused
    case proud
    case sneezing
    case footTapping
    case scratching
    case adjustingHat
    case droopSleep

    // Wave 5: Poke Escalation
    case curiousPoke
    case irritated
    case dodging
    case duckingDown
    case chomping
    case tantrum
    case playingDead
    case surrender

    // Wave 5: Feeding & Swallow Reactions
    case swallowing
    case crumbOnBeak
    case tailWiggle

    // Wave 5: Chonky Duck Temporary Mode
    case chonky
    case chonkyBurp
    case chonkyPant
    case chonkySit
}

// MARK: - Rare Secret Event Types (Wave 2)

enum RareSecretEventType: String, CaseIterable, Equatable {
    case goldenDuck
    case ghostGlitch
    case ufoBeam
    case victoryShades
}

// MARK: - Behavior Phases

enum DuckBehaviorPhase: String, Equatable {
    case relaxed     // Nothing running: wandering, preening, sitting
    case mission     // Just started: attentive, ready
    case focus       // Actively running: quiet, unobtrusive, occasional clock glance
    case suspicious  // Mid-way / tactical: side-eye, tactical crouch
    case urgency     // Under 10s: alert, clock-watching, ready to celebrate
    case victory     // Complete: joyful celebration, wing flaps
    case breakTime   // Pomodoro break: shades, coffee, relax pose
    case sleepy      // Extended inactivity: snoozing, dream thoughts
}

// MARK: - Phrase Library

struct DuckPhrase {
    enum Category: Equatable, Hashable {
        case idle
        case timerReady
        case timerStart
        case timerShort
        case timerLong
        case timerEarly
        case timerHalfway
        case timerAlmost
        case timerFinal
        case timerPaused
        case timerResumed
        case timerComplete
        case victory
        case stopwatchRunning
        case stopwatchLong
        case stopwatchLap
        case stopwatchFastLap
        case stopwatchSlowLap
        case pomoFocus
        case pomoDeepFocus
        case pomoBreak
        case pomoStreak
        case pomoRepeated
        case wakeUp
        case inactivityLong
        case userReturn
        case poke(level: Int)
        case pokeForgive
        case crumb
        case crumbRepeat
        case crumbChonky
        case crumbChonkyBurp
        case crumbChonkyWaddle
        case lateNight
        case earlyMorning
        case sessionMarathon
        case hatChange(DuckHat)
        case themeChange(ThemeType)
        case soundToggle(Bool)
        case rare
        case duckJokes
        case programmerJokes
        case timerJokes
        case story(DuckStoryId)
        case storyPoke(DuckStoryId)
    }

    private static let phrases: [String: [String]] = [
        "idle": [
            "QUACK.",
            "STANDBY MODE.",
            "AWAITING ORDERS.",
            "PERIMETER SECURE.",
            "POND PATROL.",
            "BREAD SEARCH.",
            "SYSTEMS NOMINAL.",
            "AT YOUR SERVICE.",
            "OPERATIONAL DUCK.",
            "ALL QUIET.",
            "FEATHERS ALIGNED.",
            "CHRONO-POND READY.",
            "BEAK CALIBRATION OK.",
            "OPTIMAL WADDLE.",
            "POND RADAR CLEAR.",
            "POND SURFACE: CALM.",
            "FLOAT EFFICIENCY: 100%.",
            "THE WATER IS CRISP.",
            "JUST A DUCK AND A CLOCK.",
            "READY WHEN YOU ARE, BOSS.",
            "YOU KNOW WHAT TIME IT IS?",
            "TIMEDUCK."
        ],
        "timerReady": [
            "PRESS SPACE, BOSS.",
            "TIMER LOCKED IN.",
            "READY WHEN YOU ARE.",
            "COUNTDOWN ARMED.",
            "STANDING BY.",
            "AWAITING LAUNCH.",
            "FLIGHT PLAN READY.",
            "CLOCK PRIMED.",
            "WING ON THE TRIGGER.",
            "LET'S TIME SOMETHING.",
            "YOU KNOW WHAT TIME IT IS?",
            "TIMEDUCK."
        ],
        "timerStart": [
            "QUACK TO WORK.",
            "MISSION START.",
            "OPERATION: FOCUS.",
            "I'M TIMING YOU.",
            "LOCK IN.",
            "ENGAGING TIMER.",
            "NO DISTRACTIONS.",
            "CHRONO-QUACK!",
            "COUNTDOWN COMMENCED.",
            "TACTICAL COUNTDOWN.",
            "MISSION CLOCK COMMENCED.",
            "TARGET SIGHTED.",
            "TIME IS ROLLING.",
            "INTO THE POND WE GO.",
            "FOCUS ENGINES FIRED.",
            "COUNTING EVERY SECOND."
        ],
        "timerShort": [
            "QUICK SPRINT!",
            "POND DASH.",
            "SHORT MISSION.",
            "LIGHTNING QUACK.",
            "FAST FOCUS BURST.",
            "SWIFT FLIGHT.",
            "QUICK BLIP IN TIME.",
            "SHORT AND SHARP."
        ],
        "timerLong": [
            "LONG VOYAGE AHEAD.",
            "MARATHON FOCUS.",
            "PACK EXTRA BREAD.",
            "ENDURANCE FLIGHT.",
            "LONG POND EXPEDITION.",
            "DEEP WATER SESSION.",
            "SETTLE IN, SOLDIER.",
            "STEADY WINGS, LONG HAUL."
        ],
        "timerEarly": [
            "PACING WELL.",
            "IN THE ZONE.",
            "STEADY FLIGHT.",
            "MOMENTUM BUILDING.",
            "LOOK AT YOU GO.",
            "AERODYNAMIC GLIDE.",
            "RADAR CLEAR.",
            "GOOD ALTITUDE.",
            "SMOOTH RHYTHM.",
            "CRUISING SPEED."
        ],
        "timerHalfway": [
            "HALFWAY THERE.",
            "50% COMPLETE.",
            "HOLD THE LINE.",
            "STILL WATCHING.",
            "SMOOTH SAILING.",
            "HALFWAY POINT.",
            "CROSSING THE MIDPOINT.",
            "HALF THE POND CROSSED.",
            "CRESTING THE WAVE.",
            "MIDPOINT REACHED.",
            "NO SLOWING DOWN NOW.",
            "DOWNHILL FROM HERE."
        ],
        "timerAlmost": [
            "FINAL STRETCH.",
            "ALMOST HOME.",
            "FINISH STRONG.",
            "DON'T STOP NOW.",
            "BRING IT HOME.",
            "TERMINAL APPROACH.",
            "VICTORY QUACK PRIMED.",
            "RUNWAY IN SIGHT.",
            "HOMESTRETCH FLIGHT.",
            "HOLD CONCENTRATION.",
            "FINAL YARDS TO POND.",
            "ALMOST IN THE NEST."
        ],
        "timerFinal": [
            "FINAL SECONDS!",
            "COUNTING DOWN!",
            "BRACE FOR QUACK!",
            "STAND BY!",
            "HOMESTRETCH!",
            "3... 2... 1...",
            "TOUCHDOWN IMMINENT!",
            "VICTORY IN SIGHT!"
        ],
        "timerPaused": [
            "TACTICAL PAUSE.",
            "HOLDING POSITION.",
            "CLOCK SUSPENDED.",
            "STANDING BY.",
            "RESTING WINGS.",
            "COFFEE TIME?",
            "TEMPORARY CEASEFIRE.",
            "HOVERING IN PLACE.",
            "TIME ON ICE.",
            "PAUSED. I REMEMBER."
        ],
        "timerResumed": [
            "AND WE'RE BACK.",
            "RESUMING MISSION.",
            "QUACK IN ACTION.",
            "UNPAUSED.",
            "CLOCK ROLLING.",
            "BACK IN FLIGHT.",
            "ENGAGING PROPULSION.",
            "MOMENTUM RESTORED."
        ],
        "timerComplete": [
            "MISSION COMPLETE.",
            "PERFECT RUN!",
            "TIME'S UP! GREAT JOB!",
            "TACTICAL SUCCESS.",
            "TARGET REACHED.",
            "VICTORY QUACK!",
            "YOU DID IT.",
            "FEATHERS UNRUFFLED.",
            "FLAWLESS EXECUTION.",
            "FEATHERS OF GLORY.",
            "PRECISION MISSION CLEAR.",
            "LANDED WITH STYLE.",
            "POND GOLD MEDAL.",
            "CHRONO-VICTORY!",
            "TIME CONQUERED.",
            "IN THE LOG BOOK."
        ],
        "victory": [
            "GLORIOUS FINISH!",
            "CELEBRATION TIME.",
            "MAXIMUM SATISFACTION.",
            "THAT'S HOW WE DO IT.",
            "POND HERO.",
            "FLAP THOSE WINGS.",
            "CHAMPION OF TIME.",
            "FEATHERS HELD HIGH.",
            "SUPERB PERFORMANCE.",
            "QUACK OF TRIUMPH."
        ],
        "stopwatchRunning": [
            "CLOCK TICKING.",
            "PRECISION TIMING.",
            "EVERY MILLISECOND.",
            "TRACKING TIME.",
            "CHRONO-STREAM LIVE.",
            "WATCHING HUNDREDTHS.",
            "STREAMING SECONDS.",
            "STOPWATCH UNLEASHED."
        ],
        "stopwatchLong": [
            "ENDURANCE RUN.",
            "MARATHON DUCK.",
            "TIME WARP.",
            "EPIC FLIGHT.",
            "LONG VOYAGE.",
            "DEEP CHRONO EXPEDITION.",
            "UNSTOPPABLE CLOCK.",
            "HOURGLASS RUNNING WIDE."
        ],
        "stopwatchLap": [
            "NICE LAP.",
            "SPLIT LOGGED.",
            "RECORDED.",
            "KEEP PACING.",
            "LAP TIME CAPTURED.",
            "MARKER DOWN.",
            "SPLIT IN THE BOOKS.",
            "PACING CONFIRMED."
        ],
        "stopwatchFastLap": [
            "FAST SPLIT!",
            "SPEED DEMON!",
            "NEW BEST PACE!",
            "TURBO WADDLE!",
            "AERODYNAMIC SPEED!",
            "HOT LAP LOGGED!"
        ],
        "stopwatchSlowLap": [
            "CASUAL SPLIT.",
            "SCENIC ROUTE LAP.",
            "TAKING IN THE POND.",
            "STEADY PACE.",
            "CRUISING SPLIT.",
            "LEISURELY LAP."
        ],
        "pomoFocus": [
            "FOCUS, HUMAN.",
            "POMODORO LOCKED.",
            "NO SOCIAL MEDIA.",
            "HEAD DOWN.",
            "DEEP WORK TIME.",
            "QUACK TO WORK.",
            "DEEP POND FOCUS.",
            "CONCENTRATION LOCK.",
            "TUNNEL VISION ON.",
            "ZERO DISTRACTIONS.",
            "PRODUCTIVITY SURGE.",
            "FEATHERS IN THE ZONE."
        ],
        "pomoDeepFocus": [
            "FLOW STATE ACHIEVED.",
            "DEEP POND FOCUS.",
            "SYNAPSE SYNCED.",
            "TIME WARP FOCUS.",
            "CHRONO-HARMONY.",
            "DO NOT BREAK THE FLOW.",
            "PERFECT PRODUCTIVITY.",
            "THE ZONE IS STRONG."
        ],
        "pomoBreak": [
            "TACTICAL BREAK.",
            "HYDRATE, SOLDIER.",
            "STRETCH WINGS.",
            "BREAD BREAK.",
            "RECHARGE BATTERIES.",
            "SIP WATER.",
            "WELL EARNED.",
            "HYDRATION PROTOCOL.",
            "POND STROLL TIME.",
            "REST THOSE NEURONS.",
            "SHAKE OFF THE FOCUS.",
            "FEATHER RESTORATION."
        ],
        "pomoStreak": [
            "STREAK LOOKING GOOD.",
            "PRODUCTIVITY BEAST.",
            "UNSTOPPABLE FLOCK.",
            "ANOTHER ONE DOWN.",
            "POMODORO MASTER.",
            "LEGENDARY STREAK.",
            "UNBREAKABLE FLOCK.",
            "FOCUS MACHINE.",
            "COMBO MULTIPLIER UP.",
            "STREAK FIRE BURNING."
        ],
        "pomoRepeated": [
            "RELENTLESS DISCIPLINE.",
            "CYCLE AFTER CYCLE.",
            "UNSTOPPABLE ENGINE.",
            "CHRONO-STAMINA 100%.",
            "THE HABIT IS FORGED.",
            "ELITE POMO SQUAD.",
            "REPEAT FOCUS MASTER.",
            "IRON FOCUS."
        ],
        "wakeUp": [
            "WAKING UP.",
            "WELCOME BACK.",
            "BACK ON RADAR.",
            "STILL ON DUTY.",
            "REPORTING IN.",
            "*YAWN* READY.",
            "EYES OPEN.",
            "POND PATROL RESUMES."
        ],
        "inactivityLong": [
            "QUIET ON THE POND...",
            "DRIFTING ON STILL WATER.",
            "DUCK NAP COMMENCING.",
            "ZZZ... TIME FLIES... ZZZ",
            "DREAMING OF CRUMBS.",
            "STANDBY ENERGY MODE.",
            "LOW POWER FLOATING.",
            "WAKE ME WHEN NEEDED."
        ],
        "userReturn": [
            "OH! YOU'RE BACK.",
            "RADAR RE-ACQUIRED.",
            "FEATHERS ADJUSTED.",
            "BACK IN ACTION.",
            "LET'S GET TIMING.",
            "POND PATROL ALERT.",
            "GLAD YOU RETURNED.",
            "READY FOR MISSIONS."
        ],
        "pokeForgive": [
            "CEASEFIRE ACCEPTED.",
            "FEATHERS RE-SMOOTHED.",
            "ALL IS FORGIVEN.",
            "TRUCE COMMENCED.",
            "PEACE ON THE POND.",
            "WE ARE COOL AGAIN."
        ],
        "crumb": [
            "YUM!",
            "BREAD!",
            "BREAD LOCATED!",
            "CRUMB SECURED.",
            "SNACK TIME.",
            "EXCELLENT HARVEST.",
            "CARBOHYDRATE BOOST.",
            "NOM."
        ],
        "crumbRepeat": [
            "MORE BREAD?!",
            "GLORIOUS FEAST!",
            "CRUMB STACK EXPANDING.",
            "BREAD HEAVEN.",
            "CONTINUOUS FEEDING!",
            "CRUMB PROTOCOL ACTIVE."
        ],
        "crumbChonky": [
            "TOO MUCH BREAD.",
            "I AM SPHERICAL.",
            "MAXIMUM CHONK.",
            "POND GRAVITY UP.",
            "YOU DID THIS.",
            "HEAVY WADDLE TIME.",
            "AERO-CHONK ENGAGED.",
            "NO REGRETS."
        ],
        "crumbChonkyBurp": [
            "*BURP* EXCUSE ME.",
            "PRESSURE RELEASED.",
            "TACTICAL BURP.",
            "BREAD EXHAUST.",
            "PARDON THE QUACK.",
            "SATISFACTION CONFIRMED."
        ],
        "crumbChonkyWaddle": [
            "WADDLING IT OFF.",
            "SLOW BUT POWERFUL.",
            "CHONK DISPERSING...",
            "BURNING CRUMB FUEL.",
            "HEAVY TREAD.",
            "RESTORING SLEEK DUCK."
        ],
        "lateNight": [
            "MIDNIGHT OIL BURNING.",
            "POND SLEEPS, WE FLY.",
            "NIGHT PATROL.",
            "03:00 HOURS FOCUS.",
            "NOCTURNAL DUCK.",
            "STARS ALIGNED.",
            "LATE OPS ACTIVE.",
            "DARK POND RESOLVE."
        ],
        "earlyMorning": [
            "EARLY BIRD QUACKS.",
            "SUNRISE OVER POND.",
            "DAWN PATROL.",
            "FRESH COFFEE HOURS.",
            "MORNING FLIGHT.",
            "FIRST ON THE WATER.",
            "NEW DAY, NEW TIME.",
            "ROOSTER? NO, DUCK."
        ],
        "sessionMarathon": [
            "LEGENDARY DURATION.",
            "IRON WINGS.",
            "TIME WEAVER.",
            "UNSTOPPABLE RUN.",
            "ENDURANCE CHAMPION.",
            "CHRONO-TITAN."
        ],
        "duckJokes": [
            "CLEVER DUCK? WISE QUACKER.",
            "DUCK FEATHERS? BUTT-QUACKS.",
            "WAKE UP? QUACK OF DAWN.",
            "TV SHOW? DUCK-UMENTARY.",
            "CROSS ROAD? NOT CHICKEN.",
            "BALLET? THE NUT-QUACKER.",
            "PAYS WITH? POND MONEY.",
            "SICK DUCK? GOES TO DUCKTOR.",
            "CRATE OF DUCKS? QUACKERS.",
            "TIRED DUCK? QUACK-A-CHINO.",
            "FLY SOUTH? TOO FAR TO WALK.",
            "FAVORITE SNACK? QUACKERS."
        ],
        "programmerJokes": [
            "NOT A BUG, IT'S A FEATURE.",
            "RUBBER DUCK: 100% SUCCESS.",
            "GIT COMMIT -M 'BREAD'.",
            "STACK OVERFLOW? POND FLOW.",
            "WHILE(TRUE) { QUACK(); }",
            "10 DUCKS: COUNT OR EAT.",
            "O(1) BREAD INGESTION.",
            "SEGFAULT AT POND:0xFEED.",
            "COMPILING DUCK: 0 ERRORS.",
            "OPTIMIZE WADDLE ALGO."
        ],
        "timerJokes": [
            "MISSED TICK YESTERDAY.",
            "SICK CLOCK? HAD TICKITIS.",
            "HUNGRY CLOCK? BACK 4 SECS.",
            "TIME FLIES, DUCKS WADDLE.",
            "WAITING FOR PROPER TIDE.",
            "SECONDS ARE TINY HOURS.",
            "CLOCK TICKS, DUCK FLOATS.",
            "TIME CANNOT EVEN SWIM.",
            "LOST TIME? I PECKED IT.",
            "TIMEDUCK PRECISION POND."
        ],
        "rare": [
            "I KNOW WHAT YOU DID.",
            "THE POND REMEMBERS.",
            "BREAD AT 240°.",
            "CHRONO-SURGE NOMINAL.",
            "TOP SECRET QUACK.",
            "TACTICAL WADDLE.",
            "COSMIC POND ALIGNED.",
            "GLITCH IN WATER MATRIX.",
            "DID THAT PIXEL MOVE?",
            "42 SECS TO ENLIGHTEN.",
            "QUANTUM ENTANGLED QUACK.",
            "THE POND LOOKS BACK."
        ]
    ]

    private static var recentHistory: [String] = []
    private static let historyMaxCapacity = 25

    static func get(for category: Category) -> String {
        let activeCompanion = TimeCompanionRegistry.shared.activeCompanion
        if let customList = activeCompanion.customPhrases[category], !customList.isEmpty {
            let lastSpoken = recentHistory.last
            let nonImmediate = customList.count > 1 ? customList.filter { $0 != lastSpoken } : customList
            let freshCandidates = nonImmediate.filter { !recentHistory.contains($0) }
            let chosen = (!freshCandidates.isEmpty ? freshCandidates.randomElement() : nonImmediate.randomElement()) ?? customList.first ?? "QUACK."
            recentHistory.append(chosen)
            if recentHistory.count > historyMaxCapacity {
                recentHistory.removeFirst()
            }
            return chosen
        }
        let pool: [String]
        switch category {
        case .idle: pool = phrases["idle"] ?? ["QUACK."]
        case .timerReady: pool = phrases["timerReady"] ?? ["READY."]
        case .timerStart: pool = phrases["timerStart"] ?? ["QUACK TO WORK."]
        case .timerShort: pool = phrases["timerShort"] ?? ["QUICK SPRINT!"]
        case .timerLong: pool = phrases["timerLong"] ?? ["LONG VOYAGE."]
        case .timerEarly: pool = phrases["timerEarly"] ?? ["PACING WELL."]
        case .timerHalfway: pool = phrases["timerHalfway"] ?? ["HALFWAY THERE."]
        case .timerAlmost: pool = phrases["timerAlmost"] ?? ["FINAL STRETCH."]
        case .timerFinal: pool = phrases["timerFinal"] ?? ["FINAL SECONDS!"]
        case .timerPaused: pool = phrases["timerPaused"] ?? ["TACTICAL PAUSE."]
        case .timerResumed: pool = phrases["timerResumed"] ?? ["AND WE'RE BACK."]
        case .timerComplete: pool = phrases["timerComplete"] ?? ["MISSION COMPLETE."]
        case .victory: pool = phrases["victory"] ?? ["VICTORY QUACK!"]
        case .stopwatchRunning: pool = phrases["stopwatchRunning"] ?? ["CLOCK TICKING."]
        case .stopwatchLong: pool = phrases["stopwatchLong"] ?? ["ENDURANCE RUN."]
        case .stopwatchLap: pool = phrases["stopwatchLap"] ?? ["NICE LAP."]
        case .stopwatchFastLap: pool = phrases["stopwatchFastLap"] ?? ["FAST SPLIT!"]
        case .stopwatchSlowLap: pool = phrases["stopwatchSlowLap"] ?? ["STEADY PACE."]
        case .pomoFocus: pool = phrases["pomoFocus"] ?? ["FOCUS, HUMAN."]
        case .pomoDeepFocus: pool = phrases["pomoDeepFocus"] ?? ["FLOW STATE ACHIEVED."]
        case .pomoBreak: pool = phrases["pomoBreak"] ?? ["TACTICAL BREAK."]
        case .pomoStreak: pool = phrases["pomoStreak"] ?? ["STREAK LOOKING GOOD."]
        case .pomoRepeated: pool = phrases["pomoRepeated"] ?? ["RELENTLESS DISCIPLINE."]
        case .wakeUp: pool = phrases["wakeUp"] ?? ["REPORTING IN."]
        case .inactivityLong: pool = phrases["inactivityLong"] ?? ["DREAMING OF CRUMBS."]
        case .userReturn: pool = phrases["userReturn"] ?? ["OH! YOU'RE BACK."]
        case .pokeForgive: pool = phrases["pokeForgive"] ?? ["CEASEFIRE ACCEPTED."]
        case .crumb: pool = phrases["crumb"] ?? ["BREAD!"]
        case .crumbRepeat: pool = phrases["crumbRepeat"] ?? ["MORE BREAD?!"]
        case .crumbChonky: pool = phrases["crumbChonky"] ?? ["TOO MUCH BREAD."]
        case .crumbChonkyBurp: pool = phrases["crumbChonkyBurp"] ?? ["*BURP* EXCUSE ME."]
        case .crumbChonkyWaddle: pool = phrases["crumbChonkyWaddle"] ?? ["WADDLING IT OFF."]
        case .lateNight: pool = phrases["lateNight"] ?? ["MIDNIGHT OIL BURNING."]
        case .earlyMorning: pool = phrases["earlyMorning"] ?? ["EARLY BIRD QUACKS."]
        case .sessionMarathon: pool = phrases["sessionMarathon"] ?? ["LEGENDARY DURATION."]
        case .rare: pool = phrases["rare"] ?? ["TOP SECRET QUACK."]
        case .duckJokes: pool = phrases["duckJokes"] ?? ["CLEVER DUCK? WISE QUACKER."]
        case .programmerJokes: pool = phrases["programmerJokes"] ?? ["RUBBER DUCK: 100% SUCCESS."]
        case .timerJokes: pool = phrases["timerJokes"] ?? ["TIME FLIES, DUCKS WADDLE."]
        case .soundToggle(let on):
            pool = on ? ["QUACK MODE ON.", "AUDIO ARMED.", "SOUND ENGAGED.", "ACOUSTIC POND ON."] : ["SILENT OPS.", "STEALTH MODE.", "AUDIO MUTED.", "POND RADAR OFF."]
        case .poke(let level):
            switch level {
            case 1:
                pool = [
                    "QUACK!", "❤️", "NICE PET!", "QUACK QUACK!",
                    "BOOP.", "GENTLE TOUCH.", "GREETINGS.", "FEATHERS APPROVED."
                ]
            case 2:
                pool = [
                    "HELLO.", "YES?", "ATTENTION GRANTED.", "TICKLES.",
                    "I AM A TIMER.", "PLEASE FOCUS.", "EYE ON THE CLOCK.", "PROD RECEIVED."
                ]
            case 3:
                pool = [
                    "THAT TICKLES.", "WATCH FEATHERS.", "I'M ON DUTY!", "TACTICAL PROD.",
                    "TACTICAL LIMIT.", "QUACK ALERT.", "DO NOT DISTRACT.", "AUDIT IN PROGRESS."
                ]
            case 4:
                pool = [
                    "IS THIS A DRILL?", "SERIOUS DUCK WORK.", "FEATHER RUFFLE.", "TACTICAL WARNING.",
                    "UNAUTHORIZED PROD.", "QUACK ESCALATION.", "DEFENSE POSTURE.", "PROD LIMIT HIT."
                ]
            default:
                pool = [
                    "AM DUCK.", "MAXIMUM QUACK.", "TACTICAL OVERLOAD!", "RELEASE THE BREAD!",
                    "CANNOT HIT SQUISHY DUCK!", "DODGE PROTOCOL!", "CRUNCH THE CURSOR!",
                    "ANGRY WING FLAPS!", "SYSTEM ERROR: DUCK AFK.", "I YIELD! TAKE THE POND!"
                ]
            }
        case .hatChange(let hat):
            switch hat {
            case .none: pool = ["AERODYNAMIC.", "FEATHERS FREE.", "SLEEK."]
            case .wizard: pool = ["MAGIC DUCK.", "YOU SHALL NOT SLACK.", "CASTING FOCUS."]
            case .detective: pool = ["MYSTERY SOLVED.", "THE CLOCK DID IT.", "INVESTIGATING TIME."]
            case .cyber: pool = ["NEO-DUCK 2077.", "CYBER-POND READY.", "SYSTEM OVERCLOCK."]
            case .barista: pool = ["DOUBLE ESPRESSO.", "FRESH ROAST.", "CAFFEINE APPLIED."]
            case .sleepcap: pool = ["NIGHT OPS.", "COZY DUTY.", "BEDTIME TIMING."]
            case .crown: pool = ["ROYAL QUACK.", "KING OF THE POND.", "BOW TO THE DUCK."]
            case .bandanaMidnight: pool = ["TACTICAL OPS.", "STEALTH PROTOCOL.", "SHADOW DUCK."]
            case .bandanaCrimson: pool = ["RONIN SPIRIT.", "CRIMSON RESOLVE.", "BLADE OF FOCUS."]
            case .bandanaForestCamo: pool = ["CANOPY CAMOUFLAGE.", "WOODLAND PATROL.", "UNDETECTED."]
            case .bandanaDesertCamo: pool = ["DESERT DUCK.", "HEATWAVE OPS.", "SANDSTORM FOCUS."]
            case .pumpkin: pool = ["SPOOKY QUACK.", "PUMPKIN POWER.", "GOURD VIBES."]
            case .witch: pool = ["BREWING FOCUS.", "COVEN OF QUACKS.", "SPELLCASTING."]
            case .winterBeanie: pool = ["COZY KNIT.", "SNOW POND READY.", "WARM FEATHERS."]
            case .festiveSanta: pool = ["HO HO QUACK!", "FESTIVE CHEER.", "HOLIDAY SPIRIT."]
            }
        case .themeChange(let theme):
            switch theme {
            case .arcade: pool = ["NEON ARCADE GLOW.", "ARCADE VIBES.", "HIGH SCORE MODE."]
            case .gameboy: pool = ["8-BIT NOSTALGIA.", "DMG GREEN.", "RETRO BRICK."]
            case .amber: pool = ["WARM AMBER GLOW.", "AMBER RETRO.", "VINTAGE CRT."]
            case .synthwave: pool = ["VAPORWAVE POND.", "RETRO GLOW.", "SYNTHWAVE DUCK."]
            case .pond: pool = ["NATURAL HABITAT.", "HOME SWEET POND.", "FRESH WATER."]
            case .terminal: pool = ["PHOSPHOR MATRIX.", "VT220 GREEN.", "MAINFRAME DUCK."]
            case .paperwhite: pool = ["CRISP E-INK.", "PAPER WHITE FOCUS.", "MINIMALIST POND."]
            case .electricPond: pool = ["HIGH VOLTAGE POND.", "ELECTRIC NIGHT.", "NEON SHOCKWAVE."]
            }
        case .story(let storyId):
            switch storyId {
            case .theFeast: pool = ["FUEL ACQUIRED.", "MORE BREAD?", "VISIBLE BELLY.", "I REGRET NOTHING."]
            case .theExpedition: pool = ["EXPEDITION START.", "STEADY MARCH.", "MAP WAS UPSIDE DOWN.", "SUMMIT IN SIGHT!"]
            case .nightShift: pool = ["NIGHT OPERATIONS.", "LONG BLINK.", "COFFEE IS A VEGETABLE.", "AWAKE!"]
            case .theWod: pool = ["TODAY'S WOD: SURVIVE.", "WHY GOES NOWHERE?", "CARDIO WAS A MISTAKE.", "ONE MORE REP."]
            case .theRescue: pool = ["STEALTH LEVEL: BIRD.", "NO ONE SAW THAT.", "TOOK YOU LONG ENOUGH.", "BEST. MISSION. EVER."]
            default: pool = ["QUACK.", "TIME IS RUNNING.", "CHRONO-POND READY."]
            }
        case .storyPoke(let storyId):
            switch storyId {
            case .theFeast: pool = ["PROTECTING THE BREAD.", "DON'T TOUCH MY CRUMB!"]
            case .theExpedition: pool = ["I'M NAVIGATING.", "CHECKING THE MAP."]
            case .nightShift: pool = ["THAT DIDN'T HELP.", "STILL AWAKE, BARELY."]
            case .theWod: pool = ["REST BETWEEN SETS.", "WATCH THE FORM!"]
            case .theRescue: pool = ["SHHH. STEALTH OPS.", "KEEP IT DOWN!"]
            default: pool = ["FOCUS ON THE MISSION.", "PROD RECEIVED."]
            }
        }

        // Anti-repetition: never repeat the exact previous phrase if pool has > 1 options
        let lastSpoken = recentHistory.last
        let nonImmediate = pool.count > 1 ? pool.filter { $0 != lastSpoken } : pool
        let freshCandidates = nonImmediate.filter { !recentHistory.contains($0) }
        let chosen = (!freshCandidates.isEmpty ? freshCandidates.randomElement() : nonImmediate.randomElement()) ?? pool.first ?? "QUACK."

        recentHistory.append(chosen)
        if recentHistory.count > historyMaxCapacity {
            recentHistory.removeFirst()
        }

        return chosen
    }
}

// MARK: - Duck Brain Coordinator

final class DuckBrain {
    // Current state & pose
    private(set) var currentPhase: DuckBehaviorPhase = .relaxed
    private(set) var currentPose: DuckPose = .standing
    private(set) var poseUntil: Date = .distantPast

    // Timing milestones tracking
    private var halfwayNoticed = false
    private var almostNoticed = false
    private var longStopwatchNoticed = false
    private var nextIdleAction = Date().addingTimeInterval(Double.random(in: 8...16))

    // Poke escalation & forgiveness
    private(set) var pokeStreak = 0
    private var lastPokeTime = Date.distantPast
    private var hadExcessivePokes = false

    // Feeding & Chonky State
    private(set) var crumbsEatenTimestamps: [Date] = []
    private(set) var isChonky = false
    private(set) var chonkyUntil = Date.distantPast
    private var lastChonkyEndTime = Date.distantPast

    // Context tracking
    private var sessionStartTime = Date()
    private var pauseCount = 0
    private var fastestLap: Double? = nil

    // Autonomous wandering
    private var wanderUntil = Date.distantPast

    // Rare event tracking
    private var rareEventUntil = Date.distantPast
    private var nextRareEventCheck = Date().addingTimeInterval(Double.random(in: 45...120))
    private(set) var activeRareEvent: RareSecretEventType? = nil
    private var forcedRareEvent: RareSecretEventType? = nil

    /// Deterministic test seam for testing rare secret events.
    func forceRareEvent(_ event: RareSecretEventType?) {
        forcedRareEvent = event
    }

    func clearRareEvent() {
        activeRareEvent = nil
        forcedRareEvent = nil
        rareEventUntil = .distantPast
    }

    /// Returns true if an active non-standard idle animation is currently playing
    var hasActivePose: Bool {
        Date() < poseUntil || Date() < rareEventUntil || isChonky
    }

    func setPose(_ pose: DuckPose, duration: Double, now: Date = Date()) {
        currentPose = pose
        poseUntil = now.addingTimeInterval(duration)
    }

    // MARK: - State Evaluation & Autonomous Behavior

    func update(
        dt: Double,
        now: Date,
        mode: Mode,
        isRunning: Bool,
        isFinished: Bool,
        remainingFraction: Double,
        remainingSeconds: Double,
        elapsedSeconds: Double,
        userInactivitySeconds: Double,
        duckCurX: Double,
        gridW: Int,
        onWanderTarget: (Double) -> Void,
        onSpeak: (String, Double) -> Void
    ) {
        // Evaluate Chonky State expiration
        if isChonky && now >= chonkyUntil {
            isChonky = false
            lastChonkyEndTime = now
            setPose(.featherRuffle, duration: 1.4, now: now)
            onSpeak(DuckPhrase.get(for: .crumbChonkyWaddle), 2.2)
        }

        // Clean old feeding timestamps (keep 20s window)
        crumbsEatenTimestamps.removeAll { now.timeIntervalSince($0) > 20.0 }

        // Poke streak cooldown & forgiveness
        if pokeStreak > 0 && now.timeIntervalSince(lastPokeTime) > 4.5 {
            if hadExcessivePokes {
                onSpeak(DuckPhrase.get(for: .pokeForgive), 2.2)
                hadExcessivePokes = false
            }
            pokeStreak = 0
        }

        // Evaluate Behavior Phase
        let oldPhase = currentPhase
        if isFinished {
            currentPhase = .victory
        } else if mode == .pomodoro && isRunning && remainingFraction <= 1.0 && remainingFraction >= 0 {
            currentPhase = .focus
        } else if isRunning {
            if remainingSeconds <= 10.0 && remainingSeconds > 0 && mode != .stopwatch {
                currentPhase = .urgency
            } else {
                currentPhase = .focus
            }
        } else if userInactivitySeconds > 35.0 && !isRunning && !isFinished {
            currentPhase = .sleepy
        } else {
            currentPhase = .relaxed
        }

        // Wake up transition
        if oldPhase == .sleepy && currentPhase != .sleepy {
            setPose(.headTilt, duration: 1.0, now: now)
            onSpeak(DuckPhrase.get(for: .wakeUp), 2.2)
        }

        // Progress milestones during running sessions
        if isRunning && (mode == .timer || mode == .pomodoro) {
            if remainingFraction <= 0.50 && !halfwayNoticed && remainingFraction > 0.45 {
                halfwayNoticed = true
                setPose(.sideEye, duration: 1.5, now: now)
                if Double.random(in: 0...1) < 0.6 {
                    onSpeak(DuckPhrase.get(for: .timerHalfway), 2.2)
                }
            } else if remainingFraction <= 0.15 && !almostNoticed && remainingFraction > 0.08 {
                almostNoticed = true
                setPose(.tactical, duration: 1.8, now: now)
                if Double.random(in: 0...1) < 0.6 {
                    onSpeak(DuckPhrase.get(for: .timerAlmost), 2.2)
                }
            }
        }

        // Long stopwatch milestone (> 10m)
        if mode == .stopwatch && isRunning && elapsedSeconds >= 600 && !longStopwatchNoticed {
            longStopwatchNoticed = true
            setPose(.grooving, duration: 2.0, now: now)
            onSpeak(DuckPhrase.get(for: .stopwatchLong), 2.4)
        }

        // Autonomous Idle Actions (when relaxed & not busy & not chonky)
        if currentPhase == .relaxed && now > nextIdleAction && now >= poseUntil && !isChonky {
            nextIdleAction = now.addingTimeInterval(Double.random(in: 10...24))
            performWeightedIdleAction(gridW: gridW, duckCurX: duckCurX, onWanderTarget: onWanderTarget, onSpeak: onSpeak)
        }

        // Rare Idle Event Roll (occasional delight, rate-limited by elapsed time)
        if currentPhase == .relaxed && now > nextRareEventCheck && now >= poseUntil && !isChonky {
            nextRareEventCheck = now.addingTimeInterval(Double.random(in: 90...240))
            if forcedRareEvent != nil || Int.random(in: 1...10) == 1 { // 10% chance when window fires
                triggerRareEvent(type: forcedRareEvent, onSpeak: onSpeak)
            }
        }

        // Clear expired rare events
        if now >= rareEventUntil && activeRareEvent != nil {
            activeRareEvent = nil
        }

        // Reset pose if time expired
        if now >= poseUntil && currentPose != .standing && !isChonky {
            currentPose = .standing
        }
    }

    private func performWeightedIdleAction(
        gridW: Int,
        duckCurX: Double,
        onWanderTarget: (Double) -> Void,
        onSpeak: (String, Double) -> Void
    ) {
        let roll = Int.random(in: 0...100)

        // Common Motions (0...64) - 65%
        if roll < 12 {
            // Preen wing feathers
            setPose(.preening, duration: 1.8)
        } else if roll < 24 {
            // Feather ruffle / wing shake
            setPose(.featherRuffle, duration: 1.6)
        } else if roll < 36 {
            // Curious peek / inquisitive glance
            setPose(.curiousPeek, duration: 2.0)
        } else if roll < 48 {
            // Sit down cozy loaf
            setPose(.sitting, duration: 3.2)
        } else if roll < 58 {
            // Head tilt / look up
            setPose(.headTilt, duration: 2.0)
        } else if roll < 65 {
            // Foot shuffle fidget
            setPose(.shuffling, duration: 1.4)
        }

        // Uncommon Motions (65...94) - 30%
        else if roll < 70 {
            // Sleepy yawn
            setPose(.yawning, duration: 2.2)
        } else if roll < 75 {
            // Scratch head/hat with foot
            setPose(.scratching, duration: 1.8)
        } else if roll < 80 {
            // Wing stretch
            setPose(.wingStretch, duration: 1.8)
        } else if roll < 85 {
            // Adjust / settle headwear
            setPose(.adjustingHat, duration: 1.6)
        } else if roll < 90 {
            // Investigate floor pixel
            setPose(.investigating, duration: 2.0)
        } else if roll < 95 {
            // Impatient foot tap
            setPose(.footTapping, duration: 1.6)
        }

        // Rare Motions (95...100) - 5%
        else if roll < 97 {
            // Sneezing
            setPose(.sneezing, duration: 1.4)
        } else if roll < 99 {
            // Proud stance & occasional quip
            setPose(.proud, duration: 2.5)
            if Bool.random() {
                onSpeak(DuckPhrase.get(for: .idle), 2.2)
            }
        } else {
            // Confused double-take & spin
            setPose(.confused, duration: 1.8)
        }

        // 25% chance to couple with a gentle wander if standing
        if roll % 4 == 0 && currentPose == .standing {
            let minX = 24.0
            let maxX = Double(gridW - 38)
            let offset = Double.random(in: 20...40) * (Bool.random() ? 1.0 : -1.0)
            let targetX = max(minX, min(maxX, duckCurX + offset))
            onWanderTarget(targetX)
        }
    }

    func triggerRareEvent(type: RareSecretEventType? = nil, onSpeak: (String, Double) -> Void) {
        let event = type ?? forcedRareEvent ?? RareSecretEventType.allCases.randomElement() ?? .goldenDuck
        activeRareEvent = event
        rareEventUntil = Date().addingTimeInterval(3.0)

        switch event {
        case .goldenDuck:
            setPose(.celebrating, duration: 3.0)
            onSpeak("✨ GOLDEN DUCK ASCENSION ✨", 2.8)
        case .ghostGlitch:
            setPose(.sideEye, duration: 2.6)
            onSpeak("░▒▓ PHANTOM QUACK ▓▒░", 2.6)
        case .ufoBeam:
            setPose(.headTilt, duration: 2.8)
            onSpeak("🛸 POND CONTACT: CLASS 4 🛸", 2.8)
        case .victoryShades:
            setPose(.grooving, duration: 3.0)
            onSpeak("😎 ULTRA-SHADES ENGAGED 😎", 2.8)
        }
        AchievementEngine.shared.evaluateEvent(.rareEventTriggered(type: event), stats: StatsTracker())
    }

    // MARK: - Reaction Triggers

    var pokeLevel: Int { min(6, pokeStreak) }

    func onPoke() -> (phrase: String, level: Int, pose: DuckPose, isTantrum: Bool) {
        let now = Date()
        if now.timeIntervalSince(lastPokeTime) < 3.5 {
            pokeStreak += 1
        } else {
            pokeStreak = 1
        }
        lastPokeTime = now
        let level = min(6, pokeStreak)

        var chosenPose: DuckPose = .petting
        var isTantrum = false

        if level <= 2 {
            // Tier 1: Gentle / Curious / Happy
            chosenPose = (level == 1) ? .petting : .curiousPoke
            setPose(chosenPose, duration: 0.9)
        } else if level <= 4 {
            // Tier 2: Irritated / Suspicious / Dodge
            let roll = Int.random(in: 0...2)
            if roll == 0 {
                chosenPose = .irritated
            } else if roll == 1 {
                chosenPose = .dodging
            } else {
                chosenPose = .lookingBack
            }
            setPose(chosenPose, duration: 1.2)
        } else {
            // Tier 3: Excessive Poke Chaos!
            hadExcessivePokes = true
            let roll = Int.random(in: 0...4)
            if roll == 0 {
                chosenPose = .chomping
            } else if roll == 1 {
                chosenPose = .tantrum
                isTantrum = true
            } else if roll == 2 {
                chosenPose = .duckingDown
            } else if roll == 3 {
                chosenPose = .playingDead
            } else {
                chosenPose = .surrender
            }
            setPose(chosenPose, duration: 1.6)
        }

        let phrase = DuckPhrase.get(for: .poke(level: level))
        return (phrase, level, chosenPose, isTantrum)
    }

    func onTimerStart(mode: Mode, duration: Double = 0) -> String {
        halfwayNoticed = false
        almostNoticed = false
        longStopwatchNoticed = false
        pauseCount = 0
        setPose(.headTilt, duration: 1.2)

        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 23 || hour <= 4 {
            return DuckPhrase.get(for: .lateNight)
        } else if hour >= 5 && hour <= 7 {
            return DuckPhrase.get(for: .earlyMorning)
        }

        if mode == .pomodoro {
            return DuckPhrase.get(for: .pomoFocus)
        }
        if duration > 0 && duration <= 300 {
            return DuckPhrase.get(for: .timerShort)
        } else if duration >= 2700 {
            return DuckPhrase.get(for: .timerLong)
        }
        return DuckPhrase.get(for: .timerStart)
    }

    func onTimerPause(mode: Mode, hat: DuckHat = .none) -> String {
        pauseCount += 1
        if let action = CostumeBehavior.onTimerPause(hat: hat) {
            switch action {
            case .customPose(let pose, let dur, let phrase):
                setPose(pose, duration: dur)
                if let p = phrase { return p }
            case .customPhrase(let p):
                setPose(.sideEye, duration: 1.4)
                return p
            }
        }
        setPose(.sideEye, duration: 1.4)
        return DuckPhrase.get(for: .timerPaused)
    }

    func onTimerResume(mode: Mode) -> String {
        setPose(.standing, duration: 0.5)
        return DuckPhrase.get(for: .timerResumed)
    }

    func onTimerComplete(mode: Mode, isWorkPomodoro: Bool, hat: DuckHat = .none) -> String {
        if let action = CostumeBehavior.onTimerComplete(hat: hat) {
            switch action {
            case .customPose(let pose, let dur, let phrase):
                setPose(pose, duration: dur)
                if let p = phrase { return p }
            case .customPhrase(let p):
                setPose(.celebrating, duration: 3.0)
                return p
            }
        }
        setPose(.celebrating, duration: 3.0)
        if mode == .pomodoro {
            return isWorkPomodoro ? DuckPhrase.get(for: .timerComplete) : DuckPhrase.get(for: .pomoBreak)
        }
        return DuckPhrase.get(for: .timerComplete)
    }

    func onBreakStart(hat: DuckHat = .none) -> String {
        if let action = CostumeBehavior.onBreakStart(hat: hat) {
            switch action {
            case .customPose(let pose, let dur, let phrase):
                setPose(pose, duration: dur)
                if let p = phrase { return p }
            case .customPhrase(let p):
                setPose(.relaxing, duration: 3.0)
                return p
            }
        }
        setPose(.relaxing, duration: 3.0)
        return DuckPhrase.get(for: .pomoBreak)
    }

    func onLap(time: Double? = nil) -> String {
        setPose(.headTilt, duration: 0.8)
        if let t = time {
            if let best = fastestLap, t < best {
                fastestLap = t
                return DuckPhrase.get(for: .stopwatchFastLap)
            } else if fastestLap == nil {
                fastestLap = t
            }
        }
        return DuckPhrase.get(for: .stopwatchLap)
    }

    func onCrumbEaten() -> (phrase: String, triggeredChonky: Bool) {
        let now = Date()
        crumbsEatenTimestamps.append(now)
        if crumbsEatenTimestamps.count > 32 {
            crumbsEatenTimestamps.removeFirst(crumbsEatenTimestamps.count - 32)
        }

        // Check if overfeeding threshold met (4+ crumbs in 20s) and cooldown elapsed (40s)
        if crumbsEatenTimestamps.count >= 4 && !isChonky && now.timeIntervalSince(lastChonkyEndTime) > 40.0 {
            isChonky = true
            chonkyUntil = now.addingTimeInterval(4.5)
            setPose(.chonkyBurp, duration: 1.8)
            let phrase = DuckPhrase.get(for: .crumbChonky)
            return (phrase, true)
        }

        // Standard feeding reaction
        if isChonky {
            setPose(.chonkyBurp, duration: 1.5)
            return (DuckPhrase.get(for: .crumbChonkyBurp), false)
        }

        let roll = Int.random(in: 0...2)
        if roll == 0 {
            setPose(.swallowing, duration: 1.0)
            return (DuckPhrase.get(for: .crumb), false)
        } else if roll == 1 {
            setPose(.crumbOnBeak, duration: 1.2)
            return (DuckPhrase.get(for: .crumbRepeat), false)
        } else {
            setPose(.tailWiggle, duration: 1.2)
            return (DuckPhrase.get(for: .crumb), false)
        }
    }

    func onHatChange(_ hat: DuckHat) -> String {
        setPose(.adjustingHat, duration: 1.2)
        return DuckPhrase.get(for: .hatChange(hat))
    }

    func onThemeChange(_ theme: ThemeType) -> String {
        setPose(.sideEye, duration: 1.2)
        return DuckPhrase.get(for: .themeChange(theme))
    }

    func onSoundToggle(_ enabled: Bool) -> String {
        setPose(.headTilt, duration: 1.0)
        return DuckPhrase.get(for: .soundToggle(enabled))
    }

    func onWindowRestore() -> String? {
        if currentPhase == .sleepy {
            setPose(.headTilt, duration: 1.2)
            return DuckPhrase.get(for: .wakeUp)
        }
        return nil
    }

    // MARK: - Sprite Frame Resolver

    func getSpriteRows(
        t: Double,
        now: Date,
        isFlapping: Bool,
        isQuacking: Bool,
        isPetting: Bool,
        isEating: Bool,
        isBreakRunning: Bool,
        isRunning: Bool,
        isSleeping: Bool,
        stridePhase: Double,
        blinkUntil: Date
    ) -> [String] {
        return TimeCompanionRegistry.shared.activeCompanion.resolveSprite(
            pose: currentPose,
            t: t,
            now: now,
            isFlapping: isFlapping,
            isQuacking: isQuacking,
            isPetting: isPetting,
            isEating: isEating,
            isBreakRunning: isBreakRunning,
            isRunning: isRunning,
            isSleeping: isSleeping,
            stridePhase: stridePhase,
            blinkUntil: blinkUntil,
            poseUntil: poseUntil,
            isChonky: isChonky
        )
    }

    private func legacy_getSpriteRows(
        t: Double,
        now: Date,
        isFlapping: Bool,
        isQuacking: Bool,
        isPetting: Bool,
        isEating: Bool,
        isBreakRunning: Bool,
        isRunning: Bool,
        isSleeping: Bool,
        stridePhase: Double,
        blinkUntil: Date
    ) -> [String] {
        // Chonky Duck Temporary Mode Rendering
        if isChonky {
            if now < poseUntil {
                switch currentPose {
                case .chonkyBurp:
                    return DUCK_CHONK_BURP
                case .chonkyPant:
                    return DUCK_CHONK_PANT
                case .chonkySit:
                    return DUCK_CHONK_SIT
                default:
                    break
                }
            }
            if isRunning {
                return Int(t * 3.5) % 2 == 0 ? DUCK_CHONK_WADDLE_A : DUCK_CHONK_WADDLE_B
            }
            return DUCK_CHONK_BASE
        }

        // High priority animation overrides
        if currentPose == .celebrating || isFlapping {
            return Int(t * 6) % 2 == 0 ? DUCK_YAY_A : DUCK_YAY_B
        }
        if isQuacking {
            return DUCK_QUACK_ROWS
        }
        if isPetting || currentPose == .petting {
            return DUCK_PET_ROWS
        }
        if isEating || currentPose == .pecking {
            return Int(t * 6) % 2 == 0 ? DUCK_PECK_A : DUCK_PECK_B
        }
        if isBreakRunning {
            return DUCK_RELAX_ROWS
        }

        // Active running animation
        if isRunning {
            let ph = stridePhase.truncatingRemainder(dividingBy: 3)
            return ph < 1 ? DUCK_RUN_A : (ph < 2 ? DUCK_RUN_B : DUCK_RUN_C)
        }

        // Pose-specific renderings
        if now < poseUntil {
            switch currentPose {
            case .preening:
                return Int(t * 4) % 2 == 0 ? DUCK_PREEN_A : DUCK_PREEN_B
            case .sitting:
                return DUCK_SIT
            case .headTilt:
                return DUCK_LOOK_UP
            case .tactical:
                return DUCK_TACTICAL
            case .sideEye:
                return DUCK_SIDE_EYE
            case .lookingBack:
                return DUCK_LOOK_BACK
            case .grooving:
                return Int(t * 5) % 2 == 0 ? DUCK_BOB : DUCK_BASE
            case .shuffling:
                return Int(t * 6) % 2 == 0 ? DUCK_SHUFFLE_A : DUCK_SHUFFLE_B
            case .featherRuffle:
                return Int(t * 5) % 2 == 0 ? DUCK_RUFFLE_A : DUCK_RUFFLE_B
            case .curiousPeek:
                return Int(t * 4) % 2 == 0 ? DUCK_PEEK_A : DUCK_PEEK_B

            // Wave 5 Idle Additions
            case .wingStretch:
                return Int(t * 4) % 2 == 0 ? DUCK_STRETCH_A : DUCK_STRETCH_B
            case .yawning:
                return DUCK_YAWN
            case .investigating:
                return Int(t * 3) % 2 == 0 ? DUCK_INVESTIGATE_A : DUCK_INVESTIGATE_B
            case .confused:
                return Int(t * 4) % 2 == 0 ? DUCK_CONFUSED_A : DUCK_CONFUSED_B
            case .proud:
                return DUCK_PROUD
            case .sneezing:
                return Int(t * 5) % 2 == 0 ? DUCK_SNEEZE_A : DUCK_SNEEZE_B
            case .footTapping:
                return Int(t * 6) % 2 == 0 ? DUCK_FOOT_TAP_A : DUCK_FOOT_TAP_B
            case .scratching:
                return Int(t * 5) % 2 == 0 ? DUCK_SCRATCH_A : DUCK_SCRATCH_B
            case .adjustingHat:
                return DUCK_ADJUST_HAT
            case .droopSleep:
                return DUCK_DROOP_SLEEP

            // Wave 5 Poke Escalation Additions
            case .curiousPoke:
                return DUCK_CURIOUS_POKE
            case .irritated:
                return DUCK_IRRITATED
            case .dodging:
                return DUCK_DODGE
            case .duckingDown:
                return DUCK_DUCK_DOWN
            case .chomping:
                return Int(t * 8) % 2 == 0 ? DUCK_CHOMP_A : DUCK_CHOMP_B
            case .tantrum:
                return Int(t * 8) % 2 == 0 ? DUCK_TANTRUM_A : DUCK_TANTRUM_B
            case .playingDead:
                return DUCK_PLAY_DEAD
            case .surrender:
                return DUCK_SURRENDER

            // Wave 5 Feeding & Swallow Additions
            case .swallowing:
                return DUCK_SWALLOW
            case .crumbOnBeak:
                return DUCK_CRUMB_BEAK
            case .tailWiggle:
                return Int(t * 6) % 2 == 0 ? DUCK_WIGGLE_A : DUCK_WIGGLE_B

            default:
                break
            }
        }

        // Sleeping / Inactive state
        if isSleeping || currentPhase == .sleepy {
            return DUCK_SLEEP_DEEP
        }

        // Base Idle breathing, tail wag, and blinks
        if now < blinkUntil {
            return DUCK_BLINK_ROWS
        }
        let wagCycle = Int(t * 2.5) % 4
        if wagCycle == 0 {
            return DUCK_BASE
        } else if wagCycle == 1 {
            return DUCK_IDLE_B
        } else {
            return DUCK_IDLE_WAG
        }
    }
}
