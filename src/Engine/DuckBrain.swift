// MARK: - TimeDuck · DuckBrain.swift
// Duck personality, expanded phrase library, behavioral phases,
// low-cost idle behaviors, contextual reactions, and rare events.

import Foundation

// MARK: - Duck Pose

enum DuckPose: Equatable {
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
    enum Category: Equatable {
        case idle
        case timerReady
        case timerStart
        case timerEarly
        case timerHalfway
        case timerAlmost
        case timerFinal
        case timerPaused
        case timerResumed
        case timerComplete
        case stopwatchRunning
        case stopwatchLong
        case stopwatchLap
        case pomoFocus
        case pomoBreak
        case pomoStreak
        case wakeUp
        case poke(level: Int)
        case hatChange(DuckHat)
        case themeChange(ThemeType)
        case soundToggle(Bool)
        case crumb
        case rare
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
            "FEATHERS ALIGNED."
        ],
        "timerReady": [
            "PRESS SPACE, BOSS.",
            "TIMER LOCKED IN.",
            "READY WHEN YOU ARE.",
            "COUNTDOWN ARMED.",
            "STANDING BY."
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
            "COUNTDOWN COMMENCED."
        ],
        "timerEarly": [
            "PACING WELL.",
            "IN THE ZONE.",
            "STEADY FLIGHT.",
            "MOMENTUM BUILDING.",
            "LOOK AT YOU GO."
        ],
        "timerHalfway": [
            "HALFWAY THERE.",
            "50% COMPLETE.",
            "HOLD THE LINE.",
            "STILL WATCHING.",
            "SMOOTH SAILING.",
            "HALFWAY POINT."
        ],
        "timerAlmost": [
            "FINAL STRETCH.",
            "ALMOST HOME.",
            "FINISH STRONG.",
            "DON'T STOP NOW.",
            "BRING IT HOME."
        ],
        "timerFinal": [
            "FINAL SECONDS!",
            "COUNTING DOWN!",
            "BRACE FOR QUACK!",
            "STAND BY!",
            "HOMESTRETCH!"
        ],
        "timerPaused": [
            "TACTICAL PAUSE.",
            "HOLDING POSITION.",
            "CLOCK SUSPENDED.",
            "STANDING BY.",
            "RESTING WINGS.",
            "COFFEE TIME?"
        ],
        "timerResumed": [
            "AND WE'RE BACK.",
            "RESUMING MISSION.",
            "QUACK IN ACTION.",
            "UNPAUSED.",
            "CLOCK ROLLING."
        ],
        "timerComplete": [
            "MISSION COMPLETE.",
            "PERFECT RUN!",
            "TIME'S UP! GREAT JOB!",
            "TACTICAL SUCCESS.",
            "TARGET REACHED.",
            "VICTORY QUACK!",
            "YOU DID IT.",
            "FEATHERS UNRUFFLED."
        ],
        "stopwatchRunning": [
            "CLOCK TICKING.",
            "PRECISION TIMING.",
            "EVERY MILLISECOND.",
            "TRACKING TIME."
        ],
        "stopwatchLong": [
            "ENDURANCE RUN.",
            "MARATHON DUCK.",
            "TIME WARP.",
            "EPIC FLIGHT.",
            "LONG VOYAGE."
        ],
        "stopwatchLap": [
            "NICE LAP.",
            "SPLIT LOGGED.",
            "FAST SPLIT!",
            "RECORDED.",
            "KEEP PACING."
        ],
        "pomoFocus": [
            "FOCUS, HUMAN.",
            "POMODORO LOCKED.",
            "NO SOCIAL MEDIA.",
            "HEAD DOWN.",
            "DEEP WORK TIME.",
            "QUACK TO WORK."
        ],
        "pomoBreak": [
            "TACTICAL BREAK.",
            "HYDRATE, SOLDIER.",
            "STRETCH WINGS.",
            "BREAD BREAK.",
            "RECHARGE BATTERIES.",
            "SIP WATER.",
            "WELL EARNED."
        ],
        "pomoStreak": [
            "STREAK LOOKING GOOD.",
            "PRODUCTIVITY BEAST.",
            "UNSTOPPABLE FLOCK.",
            "ANOTHER ONE DOWN.",
            "POMODORO MASTER."
        ],
        "wakeUp": [
            "WAKING UP.",
            "WELCOME BACK.",
            "BACK ON RADAR.",
            "STILL ON DUTY.",
            "REPORTING IN.",
            "*YAWN* READY."
        ],
        "crumb": [
            "YUM!",
            "BREAD!",
            "BREAD LOCATED!",
            "CRUMB SECURED.",
            "SNACK TIME."
        ],
        "rare": [
            "I KNOW WHAT YOU DID.",
            "THE POND REMEMBERS.",
            "BREAD AT 240°.",
            "CHRONO-SURGE NOMINAL.",
            "TOP SECRET QUACK.",
            "TACTICAL WADDLE."
        ]
    ]

    private static var lastSpoken: String? = nil

    static func get(for category: Category) -> String {
        let pool: [String]
        switch category {
        case .idle: pool = phrases["idle"] ?? ["QUACK."]
        case .timerReady: pool = phrases["timerReady"] ?? ["READY."]
        case .timerStart: pool = phrases["timerStart"] ?? ["QUACK TO WORK."]
        case .timerEarly: pool = phrases["timerEarly"] ?? ["PACING WELL."]
        case .timerHalfway: pool = phrases["timerHalfway"] ?? ["HALFWAY THERE."]
        case .timerAlmost: pool = phrases["timerAlmost"] ?? ["FINAL STRETCH."]
        case .timerFinal: pool = phrases["timerFinal"] ?? ["FINAL SECONDS!"]
        case .timerPaused: pool = phrases["timerPaused"] ?? ["TACTICAL PAUSE."]
        case .timerResumed: pool = phrases["timerResumed"] ?? ["AND WE'RE BACK."]
        case .timerComplete: pool = phrases["timerComplete"] ?? ["MISSION COMPLETE."]
        case .stopwatchRunning: pool = phrases["stopwatchRunning"] ?? ["CLOCK TICKING."]
        case .stopwatchLong: pool = phrases["stopwatchLong"] ?? ["ENDURANCE RUN."]
        case .stopwatchLap: pool = phrases["stopwatchLap"] ?? ["NICE LAP."]
        case .pomoFocus: pool = phrases["pomoFocus"] ?? ["FOCUS, HUMAN."]
        case .pomoBreak: pool = phrases["pomoBreak"] ?? ["TACTICAL BREAK."]
        case .pomoStreak: pool = phrases["pomoStreak"] ?? ["STREAK LOOKING GOOD."]
        case .wakeUp: pool = phrases["wakeUp"] ?? ["REPORTING IN."]
        case .crumb: pool = phrases["crumb"] ?? ["BREAD!"]
        case .rare: pool = phrases["rare"] ?? ["TOP SECRET QUACK."]
        case .soundToggle(let on):
            pool = on ? ["QUACK MODE ON.", "AUDIO ARMED.", "SOUND ENGAGED."] : ["SILENT OPS.", "STEALTH MODE.", "AUDIO MUTED."]
        case .poke(let level):
            switch level {
            case 1: pool = ["QUACK!", "❤️", "NICE PET!", "QUACK QUACK!"]
            case 2: pool = ["HELLO.", "YES?", "ATTENTION GRANTED.", "BOOP."]
            case 3: pool = ["THAT TICKLES.", "TACTICAL PROD.", "REPORTING IN."]
            case 4: pool = ["IS THIS A DRILL?", "WATCH THE FEATHERS.", "I'M ON DUTY!"]
            default: pool = ["AM DUCK.", "MAXIMUM QUACK.", "TACTICAL OVERLOAD!", "RELEASE THE BREAD!"]
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
            }
        case .themeChange(let theme):
            switch theme {
            case .arcade: pool = ["NEON ARCADE GLOW.", "ARCADE VIBES.", "HIGH SCORE MODE."]
            case .gameboy: pool = ["8-BIT NOSTALGIA.", "DMG GREEN.", "RETRO BRICK."]
            case .amber: pool = ["WARM AMBER GLOW.", "AMBER RETRO.", "VINTAGE CRT."]
            case .synthwave: pool = ["VAPORWAVE POND.", "RETRO GLOW.", "SYNTHWAVE DUCK."]
            case .pond: pool = ["NATURAL HABITAT.", "HOME SWEET POND.", "FRESH WATER."]
            }
        }

        let candidates = pool.count > 1 ? pool.filter { $0 != lastSpoken } : pool
        let chosen = candidates.randomElement() ?? pool.first ?? "QUACK."
        lastSpoken = chosen
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
    private var nextIdleAction = Date().addingTimeInterval(Double.random(in: 10...20))

    // Poke escalation
    private var pokeStreak = 0
    private var lastPokeTime = Date.distantPast

    // Autonomous wandering
    private var wanderUntil = Date.distantPast

    // Rare event tracking
    private var rareEventUntil = Date.distantPast
    private var nextRareEventCheck = Date().addingTimeInterval(Double.random(in: 45...120))

    /// Returns true if an active non-standard idle animation is currently playing
    var hasActivePose: Bool {
        Date() < poseUntil || Date() < rareEventUntil
    }

    func setPose(_ pose: DuckPose, duration: Double) {
        currentPose = pose
        poseUntil = Date().addingTimeInterval(duration)
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
            setPose(.headTilt, duration: 1.0)
            onSpeak(DuckPhrase.get(for: .wakeUp), 2.2)
        }

        // Progress milestones during running sessions
        if isRunning && (mode == .timer || mode == .pomodoro) {
            if remainingFraction <= 0.50 && !halfwayNoticed && remainingFraction > 0.45 {
                halfwayNoticed = true
                setPose(.sideEye, duration: 1.5)
                if Double.random(in: 0...1) < 0.6 {
                    onSpeak(DuckPhrase.get(for: .timerHalfway), 2.2)
                }
            } else if remainingFraction <= 0.15 && !almostNoticed && remainingFraction > 0.08 {
                almostNoticed = true
                setPose(.tactical, duration: 1.8)
                if Double.random(in: 0...1) < 0.6 {
                    onSpeak(DuckPhrase.get(for: .timerAlmost), 2.2)
                }
            }
        }

        // Long stopwatch milestone (> 10m)
        if mode == .stopwatch && isRunning && elapsedSeconds >= 600 && !longStopwatchNoticed {
            longStopwatchNoticed = true
            setPose(.grooving, duration: 2.0)
            onSpeak(DuckPhrase.get(for: .stopwatchLong), 2.4)
        }

        // Autonomous Idle Actions (when relaxed & not busy)
        if currentPhase == .relaxed && now > nextIdleAction && now >= poseUntil {
            nextIdleAction = now.addingTimeInterval(Double.random(in: 12...28))
            performRandomIdleAction(gridW: gridW, duckCurX: duckCurX, onWanderTarget: onWanderTarget, onSpeak: onSpeak)
        }

        // Rare Idle Event Roll (occasional delight)
        if currentPhase == .relaxed && now > nextRareEventCheck && now >= poseUntil {
            nextRareEventCheck = now.addingTimeInterval(Double.random(in: 90...240))
            if Int.random(in: 1...10) == 1 { // 10% chance when window fires
                triggerRareEvent(onSpeak: onSpeak)
            }
        }

        // Reset pose if time expired
        if now >= poseUntil && currentPose != .standing {
            currentPose = .standing
        }
    }

    private func performRandomIdleAction(
        gridW: Int,
        duckCurX: Double,
        onWanderTarget: (Double) -> Void,
        onSpeak: (String, Double) -> Void
    ) {
        let roll = Int.random(in: 0...100)
        if roll < 22 {
            // Preen wing feathers
            setPose(.preening, duration: 1.8)
        } else if roll < 42 {
            // Sit down cozy loaf
            setPose(.sitting, duration: 3.5)
        } else if roll < 62 {
            // Head tilt / look up at timer
            setPose(.headTilt, duration: 2.2)
        } else if roll < 78 {
            // Foot shuffle fidget
            setPose(.shuffling, duration: 1.4)
        } else if roll < 90 {
            // Suspicious side eye
            setPose(.sideEye, duration: 1.8)
        } else {
            // Gentle wander (move 20-35px within pond band)
            let minX = 24.0
            let maxX = Double(gridW - 38)
            let offset = Double.random(in: 20...40) * (Bool.random() ? 1.0 : -1.0)
            let targetX = max(minX, min(maxX, duckCurX + offset))
            onWanderTarget(targetX)
        }
    }

    private func triggerRareEvent(onSpeak: (String, Double) -> Void) {
        let roll = Int.random(in: 0...3)
        switch roll {
        case 0:
            // Tactical perimeter scan
            setPose(.tactical, duration: 2.4)
            onSpeak("PERIMETER CLEAR.", 2.2)
        case 1:
            // Tiny groove bob
            setPose(.grooving, duration: 2.5)
            onSpeak("♪ CHRONO-GROOVE ♪", 2.2)
        case 2:
            // Looking back
            setPose(.lookingBack, duration: 2.0)
            onSpeak(DuckPhrase.get(for: .rare), 2.4)
        default:
            // Direct stare with quip
            setPose(.sideEye, duration: 2.2)
            onSpeak(DuckPhrase.get(for: .rare), 2.4)
        }
    }

    // MARK: - Reaction Triggers

    func onPoke() -> (phrase: String, level: Int) {
        let now = Date()
        if now.timeIntervalSince(lastPokeTime) < 3.5 {
            pokeStreak += 1
        } else {
            pokeStreak = 1
        }
        lastPokeTime = now
        let level = min(5, pokeStreak)

        if level >= 4 {
            setPose(.tactical, duration: 1.2)
        } else {
            setPose(.petting, duration: 0.9)
        }

        let phrase = DuckPhrase.get(for: .poke(level: level))
        return (phrase, level)
    }

    func onTimerStart(mode: Mode) -> String {
        halfwayNoticed = false
        almostNoticed = false
        longStopwatchNoticed = false
        setPose(.headTilt, duration: 1.2)
        let cat: DuckPhrase.Category = (mode == .pomodoro) ? .pomoFocus : .timerStart
        return DuckPhrase.get(for: cat)
    }

    func onTimerPause(mode: Mode) -> String {
        setPose(.sideEye, duration: 1.4)
        return DuckPhrase.get(for: .timerPaused)
    }

    func onTimerResume(mode: Mode) -> String {
        setPose(.standing, duration: 0.5)
        return DuckPhrase.get(for: .timerResumed)
    }

    func onTimerComplete(mode: Mode, isWorkPomodoro: Bool) -> String {
        setPose(.celebrating, duration: 3.0)
        if mode == .pomodoro {
            return isWorkPomodoro ? DuckPhrase.get(for: .timerComplete) : DuckPhrase.get(for: .pomoBreak)
        }
        return DuckPhrase.get(for: .timerComplete)
    }

    func onLap() -> String {
        setPose(.headTilt, duration: 0.8)
        return DuckPhrase.get(for: .stopwatchLap)
    }

    func onCrumb() -> String {
        setPose(.pecking, duration: 1.2)
        return DuckPhrase.get(for: .crumb)
    }

    func onHatChange(_ hat: DuckHat) -> String {
        setPose(.headTilt, duration: 1.2)
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
