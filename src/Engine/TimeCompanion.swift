// MARK: - TimeDuck · TimeCompanion.swift
// Extensible TimeCompanion system for Wave 8 (TimeCompanions + Achievements).
// Invariant: Companions observe time events and define personality / presentation.
// They NEVER own or manipulate timekeeping engines.

import Foundation

// MARK: - Companion Identifier

enum TimeCompanionId: String, CaseIterable, Codable, Equatable {
    case timeDuck = "timeduck"
    case girlDuck = "girl_duck"
    case guardDuck = "guard_duck"
    case duckling = "duckling"
    case cyberDuck = "cyber_duck"

    var rawId: String { rawValue }

    static func safeResolve(_ stringValue: String?) -> TimeCompanionId {
        guard let s = stringValue else { return .timeDuck }
        return TimeCompanionId(rawValue: s) ?? .timeDuck
    }
}

// MARK: - TimeCompanion Protocol & Model

struct TimeCompanion: Equatable {
    let id: TimeCompanionId
    let displayName: String
    let subtitle: String
    let bio: String
    let portraitSprite: [String]
    let isSecret: Bool
    let defaultUnlocked: Bool
    let speedMultiplier: Double
    let idlePoseBiases: [DuckPose: Int]
    let customPhrases: [DuckPhrase.Category: [String]]

    static func == (lhs: TimeCompanion, rhs: TimeCompanion) -> Bool {
        lhs.id == rhs.id
    }

    /// Resolves custom sprite rows for the companion given pose, timing, and animation state.
    func resolveSprite(
        pose: DuckPose,
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
        blinkUntil: Date,
        poseUntil: Date,
        isChonky: Bool
    ) -> [String] {
        // If Chonky Duck mode is active, render companion-specific chonky sprites
        if isChonky {
            switch id {
            case .timeDuck:
                if now < poseUntil {
                    switch pose {
                    case .chonkyBurp: return DUCK_CHONK_BURP
                    case .chonkyPant: return DUCK_CHONK_PANT
                    case .chonkySit:  return DUCK_CHONK_SIT
                    default: break
                    }
                }
                if isRunning {
                    return Int(t * 3.5) % 2 == 0 ? DUCK_CHONK_WADDLE_A : DUCK_CHONK_WADDLE_B
                }
                return DUCK_CHONK_BASE
            case .girlDuck:
                return GIRL_DUCK_CHONK_BASE
            case .guardDuck:
                return GUARD_DUCK_CHONK_BASE
            case .duckling:
                return DUCKLING_CHONK_BASE
            case .cyberDuck:
                return CYBER_DUCK_CHONK_BASE
            }
        }

        switch id {
        case .timeDuck:
            // Handled by standard DuckBrain sprite resolver
            return resolveStandardTimeDuckSprite(
                pose: pose, t: t, now: now, isFlapping: isFlapping, isQuacking: isQuacking,
                isPetting: isPetting, isEating: isEating, isBreakRunning: isBreakRunning,
                isRunning: isRunning, isSleeping: isSleeping, stridePhase: stridePhase,
                blinkUntil: blinkUntil, poseUntil: poseUntil
            )

        case .girlDuck:
            return resolveGirlDuckSprite(
                pose: pose, t: t, now: now, isFlapping: isFlapping, isQuacking: isQuacking,
                isPetting: isPetting, isEating: isEating, isBreakRunning: isBreakRunning,
                isRunning: isRunning, isSleeping: isSleeping, stridePhase: stridePhase,
                blinkUntil: blinkUntil, poseUntil: poseUntil
            )

        case .guardDuck:
            return resolveGuardDuckSprite(
                pose: pose, t: t, now: now, isFlapping: isFlapping, isQuacking: isQuacking,
                isPetting: isPetting, isEating: isEating, isBreakRunning: isBreakRunning,
                isRunning: isRunning, isSleeping: isSleeping, stridePhase: stridePhase,
                blinkUntil: blinkUntil, poseUntil: poseUntil
            )

        case .duckling:
            return resolveDucklingSprite(
                pose: pose, t: t, now: now, isFlapping: isFlapping, isQuacking: isQuacking,
                isPetting: isPetting, isEating: isEating, isBreakRunning: isBreakRunning,
                isRunning: isRunning, isSleeping: isSleeping, stridePhase: stridePhase,
                blinkUntil: blinkUntil, poseUntil: poseUntil
            )

        case .cyberDuck:
            return resolveCyberDuckSprite(
                pose: pose, t: t, now: now, isFlapping: isFlapping, isQuacking: isQuacking,
                isPetting: isPetting, isEating: isEating, isBreakRunning: isBreakRunning,
                isRunning: isRunning, isSleeping: isSleeping, stridePhase: stridePhase,
                blinkUntil: blinkUntil, poseUntil: poseUntil
            )
        }
    }

    /// Resolves companion-specific color mapping with theme/rare event overlays.
    func resolveColorMap(rareEvent: RareSecretEventType? = nil) -> [Character: Color] {
        var map = getDuckColorMap(rareEvent: rareEvent)
        switch id {
        case .girlDuck:
            map["m"] = Pal.magenta
            map["p"] = Pal.cheek
        case .guardDuck:
            map["k"] = Pal.duckEye
            map["w"] = Pal.white
            map["a"] = Pal.amber
        case .cyberDuck:
            map["b"] = Pal.cyan
            map["v"] = Pal.violet
            map["m"] = Pal.magenta
        case .duckling, .timeDuck:
            break
        }
        return map
    }

    // MARK: - Specific Companion Resolvers

    private func resolveStandardTimeDuckSprite(
        pose: DuckPose, t: Double, now: Date, isFlapping: Bool, isQuacking: Bool,
        isPetting: Bool, isEating: Bool, isBreakRunning: Bool, isRunning: Bool,
        isSleeping: Bool, stridePhase: Double, blinkUntil: Date, poseUntil: Date
    ) -> [String] {
        if pose == .celebrating || isFlapping {
            return Int(t * 6) % 2 == 0 ? DUCK_YAY_A : DUCK_YAY_B
        }
        if isQuacking { return DUCK_QUACK_ROWS }
        if isPetting || pose == .petting { return DUCK_PET_ROWS }
        if isEating || pose == .pecking {
            return Int(t * 6) % 2 == 0 ? DUCK_PECK_A : DUCK_PECK_B
        }
        if isBreakRunning { return DUCK_RELAX_ROWS }
        if isRunning {
            let ph = stridePhase.truncatingRemainder(dividingBy: 3)
            return ph < 1 ? DUCK_RUN_A : (ph < 2 ? DUCK_RUN_B : DUCK_RUN_C)
        }
        if now < poseUntil {
            switch pose {
            case .preening: return Int(t * 4) % 2 == 0 ? DUCK_PREEN_A : DUCK_PREEN_B
            case .sitting: return DUCK_SIT
            case .headTilt: return DUCK_LOOK_UP
            case .tactical: return DUCK_TACTICAL
            case .sideEye: return DUCK_SIDE_EYE
            case .lookingBack: return DUCK_LOOK_BACK
            case .grooving: return Int(t * 5) % 2 == 0 ? DUCK_BOB : DUCK_BASE
            case .shuffling: return Int(t * 6) % 2 == 0 ? DUCK_SHUFFLE_A : DUCK_SHUFFLE_B
            case .featherRuffle: return Int(t * 5) % 2 == 0 ? DUCK_RUFFLE_A : DUCK_RUFFLE_B
            case .curiousPeek: return Int(t * 4) % 2 == 0 ? DUCK_PEEK_A : DUCK_PEEK_B
            case .wingStretch: return Int(t * 4) % 2 == 0 ? DUCK_STRETCH_A : DUCK_STRETCH_B
            case .yawning: return DUCK_YAWN
            case .investigating: return Int(t * 3) % 2 == 0 ? DUCK_INVESTIGATE_A : DUCK_INVESTIGATE_B
            case .confused: return Int(t * 4) % 2 == 0 ? DUCK_CONFUSED_A : DUCK_CONFUSED_B
            case .proud: return DUCK_PROUD
            case .sneezing: return Int(t * 5) % 2 == 0 ? DUCK_SNEEZE_A : DUCK_SNEEZE_B
            case .footTapping: return Int(t * 6) % 2 == 0 ? DUCK_FOOT_TAP_A : DUCK_FOOT_TAP_B
            case .scratching: return Int(t * 5) % 2 == 0 ? DUCK_SCRATCH_A : DUCK_SCRATCH_B
            case .adjustingHat: return DUCK_ADJUST_HAT
            case .droopSleep: return DUCK_DROOP_SLEEP
            case .curiousPoke: return DUCK_CURIOUS_POKE
            case .irritated: return DUCK_IRRITATED
            case .dodging: return DUCK_DODGE
            case .duckingDown: return DUCK_DUCK_DOWN
            case .chomping: return Int(t * 8) % 2 == 0 ? DUCK_CHOMP_A : DUCK_CHOMP_B
            case .tantrum: return Int(t * 8) % 2 == 0 ? DUCK_TANTRUM_A : DUCK_TANTRUM_B
            case .playingDead: return DUCK_PLAY_DEAD
            case .surrender: return DUCK_SURRENDER
            case .swallowing: return DUCK_SWALLOW
            case .crumbOnBeak: return DUCK_CRUMB_BEAK
            case .tailWiggle: return Int(t * 6) % 2 == 0 ? DUCK_WIGGLE_A : DUCK_WIGGLE_B
            default: break
            }
        }
        if isSleeping { return DUCK_SLEEP_DEEP }
        if now < blinkUntil { return DUCK_BLINK_ROWS }
        let wagCycle = Int(t * 2.5) % 4
        if wagCycle == 0 { return DUCK_BASE }
        else if wagCycle == 1 { return DUCK_IDLE_B }
        else { return DUCK_IDLE_WAG }
    }

    private func resolveGirlDuckSprite(
        pose: DuckPose, t: Double, now: Date, isFlapping: Bool, isQuacking: Bool,
        isPetting: Bool, isEating: Bool, isBreakRunning: Bool, isRunning: Bool,
        isSleeping: Bool, stridePhase: Double, blinkUntil: Date, poseUntil: Date
    ) -> [String] {
        if pose == .celebrating || isFlapping {
            return Int(t * 6) % 2 == 0 ? ACTOR_GIRL_DUCK_CHEER_A : ACTOR_GIRL_DUCK_CHEER_B
        }
        if isQuacking { return ACTOR_GIRL_DUCK_NOTICE }
        if isPetting || pose == .petting { return ACTOR_GIRL_DUCK_NOTICE }
        if isEating || pose == .pecking || pose == .chomping || pose == .swallowing {
            return Int(t * 6) % 2 == 0 ? ACTOR_GIRL_DUCK_PECK_A : ACTOR_GIRL_DUCK_PECK_B
        }
        if isBreakRunning { return ACTOR_GIRL_DUCK_IDLE_B }
        if isRunning {
            let step = Int(t * 4.5) % 2
            return step == 0 ? ACTOR_GIRL_DUCK_WADDLE_A : ACTOR_GIRL_DUCK_WADDLE_B
        }
        if now < poseUntil {
            switch pose {
            case .proud: return ACTOR_GIRL_DUCK_BASE
            case .celebrating: return ACTOR_GIRL_DUCK_CHEER_A
            case .headTilt, .curiousPeek, .investigating: return ACTOR_GIRL_DUCK_NOTICE
            case .tailWiggle, .grooving: return Int(t * 6) % 2 == 0 ? ACTOR_GIRL_DUCK_CHEER_A : ACTOR_GIRL_DUCK_BASE
            case .yawning, .featherRuffle: return ACTOR_GIRL_DUCK_IDLE_B
            default: break
            }
        }
        if isSleeping { return ACTOR_GIRL_DUCK_SLEEP }
        let wagCycle = Int(t * 2.5) % 4
        if wagCycle == 0 { return ACTOR_GIRL_DUCK_BASE }
        else if wagCycle == 1 { return ACTOR_GIRL_DUCK_IDLE_B }
        else { return ACTOR_GIRL_DUCK_BASE }
    }

    private func resolveGuardDuckSprite(
        pose: DuckPose, t: Double, now: Date, isFlapping: Bool, isQuacking: Bool,
        isPetting: Bool, isEating: Bool, isBreakRunning: Bool, isRunning: Bool,
        isSleeping: Bool, stridePhase: Double, blinkUntil: Date, poseUntil: Date
    ) -> [String] {
        if pose == .celebrating || isFlapping {
            return ACTOR_GUARD_DUCK_ALERT
        }
        if isQuacking { return ACTOR_GUARD_DUCK_ALERT }
        if isPetting || pose == .petting { return ACTOR_GUARD_DUCK_SUSPICIOUS }
        if isEating || pose == .pecking || pose == .chomping || pose == .swallowing {
            return Int(t * 6) % 2 == 0 ? ACTOR_GUARD_DUCK_PECK_A : ACTOR_GUARD_DUCK_PECK_B
        }
        if isBreakRunning { return ACTOR_GUARD_DUCK_STOP }
        if isRunning {
            let step = Int(t * 4.0) % 2
            return step == 0 ? ACTOR_GUARD_DUCK_PATROL_A : ACTOR_GUARD_DUCK_PATROL_B
        }
        if now < poseUntil {
            switch pose {
            case .tactical, .proud: return ACTOR_GUARD_DUCK_STOP
            case .sideEye, .lookingBack, .curiousPoke, .irritated: return ACTOR_GUARD_DUCK_SUSPICIOUS
            case .headTilt, .investigating: return ACTOR_GUARD_DUCK_TURN
            case .tantrum, .confused: return ACTOR_GUARD_DUCK_ALERT
            default: break
            }
        }
        if isSleeping { return ACTOR_GUARD_DUCK_SLEEP }
        let wagCycle = Int(t * 2.0) % 4
        if wagCycle == 0 { return ACTOR_GUARD_DUCK_BASE }
        else if wagCycle == 1 { return ACTOR_GUARD_DUCK_STOP }
        else { return ACTOR_GUARD_DUCK_BASE }
    }

    private func resolveDucklingSprite(
        pose: DuckPose, t: Double, now: Date, isFlapping: Bool, isQuacking: Bool,
        isPetting: Bool, isEating: Bool, isBreakRunning: Bool, isRunning: Bool,
        isSleeping: Bool, stridePhase: Double, blinkUntil: Date, poseUntil: Date
    ) -> [String] {
        if pose == .celebrating || isFlapping {
            return Int(t * 8) % 2 == 0 ? DUCKLING_YAY_A : DUCKLING_YAY_B
        }
        if isQuacking { return DUCKLING_CHAOS }
        if isPetting || pose == .petting { return DUCKLING_LOOK_UP }
        if isEating || pose == .pecking || pose == .chomping || pose == .swallowing {
            return Int(t * 8) % 2 == 0 ? DUCKLING_PECK_A : DUCKLING_PECK_B
        }
        if isBreakRunning { return DUCKLING_SIT }
        if isRunning {
            let ph = (stridePhase * 1.5).truncatingRemainder(dividingBy: 3)
            return ph < 1 ? DUCKLING_RUN_A : (ph < 2 ? DUCKLING_RUN_B : DUCKLING_RUN_C)
        }
        if now < poseUntil {
            switch pose {
            case .headTilt, .curiousPeek, .investigating: return DUCKLING_LOOK_UP
            case .sitting, .yawning: return DUCKLING_SIT
            case .tantrum, .sneezing, .curiousPoke: return DUCKLING_CHAOS
            case .celebrating: return DUCKLING_YAY_A
            default: break
            }
        }
        if isSleeping { return DUCKLING_SLEEP }
        let wagCycle = Int(t * 3.5) % 4
        if wagCycle == 0 { return DUCKLING_BASE }
        else if wagCycle == 1 { return DUCKLING_IDLE_B }
        else { return DUCKLING_IDLE_WAG }
    }

    private func resolveCyberDuckSprite(
        pose: DuckPose, t: Double, now: Date, isFlapping: Bool, isQuacking: Bool,
        isPetting: Bool, isEating: Bool, isBreakRunning: Bool, isRunning: Bool,
        isSleeping: Bool, stridePhase: Double, blinkUntil: Date, poseUntil: Date
    ) -> [String] {
        if pose == .celebrating || isFlapping {
            return Int(t * 6) % 2 == 0 ? CYBER_DUCK_YAY_A : CYBER_DUCK_YAY_B
        }
        if isQuacking { return CYBER_DUCK_SCAN }
        if isPetting || pose == .petting {
            return (Int(t * 8) % 2 == 0) ? CYBER_DUCK_SHOCK : CYBER_DUCK_GLITCH
        }
        if isEating || pose == .pecking || pose == .chomping || pose == .swallowing {
            return Int(t * 6) % 2 == 0 ? CYBER_DUCK_EAT_A : CYBER_DUCK_EAT_B
        }
        if isBreakRunning { return CYBER_DUCK_SLEEP }
        if isRunning {
            let ph = stridePhase.truncatingRemainder(dividingBy: 3)
            return ph < 1 ? CYBER_DUCK_RUN_A : (ph < 2 ? CYBER_DUCK_RUN_B : CYBER_DUCK_RUN_C)
        }
        if now < poseUntil {
            switch pose {
            case .sideEye, .investigating: return CYBER_DUCK_SCAN
            case .confused, .dodging, .curiousPoke, .irritated: return CYBER_DUCK_SHOCK
            case .headTilt, .tactical: return CYBER_DUCK_MATRIX_PULSE
            case .yawning, .preening: return CYBER_DUCK_BOOT
            case .celebrating: return CYBER_DUCK_YAY_A
            default: break
            }
        }
        if isSleeping { return CYBER_DUCK_SLEEP }
        let wagCycle = Int(t * 2.5) % 4
        if wagCycle == 0 { return CYBER_DUCK_BASE }
        else if wagCycle == 1 { return CYBER_DUCK_IDLE_B }
        else if wagCycle == 2 { return CYBER_DUCK_MATRIX_PULSE }
        else { return CYBER_DUCK_BASE }
    }
}

// MARK: - Companion Registry & Manager

final class TimeCompanionRegistry {
    static let shared = TimeCompanionRegistry()

    private(set) var activeCompanionId: TimeCompanionId = .timeDuck
    private(set) var unlockedCompanionIds: Set<TimeCompanionId> = [.timeDuck]

    private var companionCatalog: [TimeCompanionId: TimeCompanion] = [:]

    init() {
        registerCompanions()
    }

    private func registerCompanions() {
        // 1. TimeDuck (The Canonical Original)
        companionCatalog[.timeDuck] = TimeCompanion(
            id: .timeDuck,
            displayName: "TimeDuck",
            subtitle: "The Original Precision Companion",
            bio: "Dependable, slightly absurd, and fiercely dedicated to timing integrity. The canonical guardian of the pond.",
            portraitSprite: PORTRAIT_TIMEDUCK,
            isSecret: false,
            defaultUnlocked: true,
            speedMultiplier: 1.0,
            idlePoseBiases: [
                .standing: 40, .featherRuffle: 15, .preening: 10,
                .sitting: 10, .headTilt: 10, .curiousPeek: 10, .shuffling: 5
            ],
            customPhrases: [:]
        )

        // 2. Girl Duck (Rescue Veteran & Playful Companion)
        companionCatalog[.girlDuck] = TimeCompanion(
            id: .girlDuck,
            displayName: "Girl Duck",
            subtitle: "Cheerful, Social & Spirited",
            bio: "Promoted from the legendary Rescue mission. Playful, supportive, and loves celebrating completed focus sessions.",
            portraitSprite: PORTRAIT_GIRL_DUCK,
            isSecret: false,
            defaultUnlocked: false,
            speedMultiplier: 1.05,
            idlePoseBiases: [
                .standing: 30, .celebrating: 20, .featherRuffle: 15,
                .tailWiggle: 15, .curiousPeek: 10, .headTilt: 10
            ],
            customPhrases: [
                .idle: [
                    "POND IS CHEERFUL TODAY!", "READY WHEN YOU ARE! ❤️", "YOU'VE GOT THIS, BOSS!",
                    "BEST TIMING DUO EVER!", "FEATHERS LOOKING FABULOUS.", "HAPPY WADDLE!"
                ],
                .timerStart: [
                    "LET'S DO THIS TOGETHER!", "FOCUS TIME! YAY!", "OPERATION: PRODUCTIVE DUCK!",
                    "COUNTING WITH A SMILE!", "LOCKED IN AND READY!"
                ],
                .timerComplete: [
                    "YAY! PERFECT RUN! 🎉", "I KNEW YOU COULD DO IT!", "GLORIOUS FINISH!",
                    "MISSION ACCOMPLISHED WITH STYLE!", "HIGH FLAP! 💖"
                ],
                .victory: [
                    "WE DID IT! 🎉", "CHAMPIONS OF THE POND!", "CELEBRATION TIME!"
                ],
                .poke(level: 1): [
                    "HEHE, TICKLES! ❤️", "HELLO FRIEND!", "BOOP! 💕", "NICE TO MEET YOU!"
                ],
                .crumb: [
                    "THANK YOU FOR THE SNACK!", "DELICIOUS BREAD! 💖", "YUMMY!"
                ]
            ]
        )

        // 3. Guard Duck (Tactical Security & Military Discipline)
        companionCatalog[.guardDuck] = TimeCompanion(
            id: .guardDuck,
            displayName: "Guard Duck",
            subtitle: "Absurdly Serious Security Patrol",
            bio: "Treats ordinary countdowns like high-stakes tactical operations. Constantly inspecting perimeters and suspecting breadcrumbs.",
            portraitSprite: PORTRAIT_GUARD_DUCK,
            isSecret: false,
            defaultUnlocked: false,
            speedMultiplier: 0.92,
            idlePoseBiases: [
                .standing: 35, .tactical: 25, .sideEye: 20,
                .lookingBack: 10, .proud: 10
            ],
            customPhrases: [
                .idle: [
                    "PERIMETER SECURE.", "SECTOR 4 CLEAR.", "STANDBY AT THE WATCHTOWER.",
                    "TACTICAL TIME PATROL ACTIVE.", "EYES ON HORIZON.", "NO UNAUTHORIZED SLACKING."
                ],
                .timerStart: [
                    "TACTICAL OPERATION COMMENCED.", "COUNTDOWN ARMED. CODE: ALPHA.",
                    "DISCIPLINE IS VICTORY.", "TIME IS UNDER MILITARY SURVEILLANCE."
                ],
                .timerPaused: [
                    "HOLDING TACTICAL POSITION.", "CEASEFIRE SUSPENDED.", "STAND AT ATTENTION."
                ],
                .timerComplete: [
                    "MISSION OBJECTIVE COMPLETED.", "TACTICAL VICTORY CONFIRMED.",
                    "PERIMETER DEFENDED.", "OUTSTANDING DRILL, SOLDIER."
                ],
                .poke(level: 1): [
                    "STATE YOUR BUSINESS.", "UNAUTHORIZED PHYSICAL CONTACT LOGGED.",
                    "SECURITY DRILL IN PROGRESS.", "PROCEED WITH CAUTION."
                ],
                .poke(level: 4): [
                    "TACTICAL THREAT DETECTED!", "ENGAGING DEFENSIVE COUNTERMEASURES!",
                    "SECURITY ALERT: CODE RED!"
                ],
                .crumb: [
                    "FOREIGN CARBOHYDRATE DETECTED.", "CONFISCATED FOR SAMPLING.", "PROVISIONS SECURED."
                ]
            ]
        )

        // 4. Duckling / Tiny Duck (Small Chaos Machine)
        companionCatalog[.duckling] = TimeCompanion(
            id: .duckling,
            displayName: "Duckling",
            subtitle: "Tiny High-Energy Chaos Machine",
            bio: "Small, relentless, and ridiculously fast. Mimics TimeDuck with disproportionate enthusiasm and rapid waddles.",
            portraitSprite: PORTRAIT_DUCKLING,
            isSecret: false,
            defaultUnlocked: false,
            speedMultiplier: 1.45,
            idlePoseBiases: [
                .standing: 25, .shuffling: 25, .footTapping: 15,
                .curiousPoke: 15, .sneezing: 10, .quacking: 10
            ],
            customPhrases: [
                .idle: [
                    "PEEP!", "TINY QUACK!", "LOOK AT ME GO!", "WADDLE WADDLE WADDLE!",
                    "SO MUCH ENERGY!", "ZOOM!", "IS IT TIME YET?!"
                ],
                .timerStart: [
                    "FAST FOCUS GO GO GO!", "RACING THE CLOCK!", "TINY LEGS, BIG SPEED!",
                    "LET'S TIME IT FAST!"
                ],
                .timerComplete: [
                    "WE WON! WE WON! 🐣", "PEEP PEEP HURRAY!", "TINY VICTORY DANCE!",
                    "SUPER DUCKLING CLEAR!"
                ],
                .poke(level: 1): [
                    "PEEP! 🐣", "HEHE! AGAIN!", "TINY BOOP!", "SQUEAK!"
                ],
                .crumb: [
                    "BREAD BIGGER THAN ME!", "NOM NOM NOM NOM!", "MORE CRUMBS PLEASE!"
                ]
            ]
        )

        // 5. CyberDuck (Secret Companion · Chrono-Anomaly)
        companionCatalog[.cyberDuck] = TimeCompanion(
            id: .cyberDuck,
            displayName: "CyberDuck",
            subtitle: "0xPOND · Quantum Anomaly",
            bio: "A glitch in the time-matrix. Emits faint phosphor scans and communicates in hexadecimal pond telemetry.",
            portraitSprite: PORTRAIT_CYBER_DUCK,
            isSecret: true,
            defaultUnlocked: false,
            speedMultiplier: 1.15,
            idlePoseBiases: [
                .standing: 30, .sideEye: 25, .investigating: 20,
                .confused: 15, .proud: 10
            ],
            customPhrases: [
                .idle: [
                    "0xFEED: POND NOMINAL.", "QUANTUM TICKS: SYNCHRONIZED.", "PING: 1ms.",
                    "CHRONO-MATRIX ONLINE.", "SYSTEM OVERCLOCKED.", "REALITY REFRESH: 60Hz."
                ],
                .timerStart: [
                    "INITIALIZING COUNTDOWN THREAD.", "QUANTUM HARMONY LOCKED.", "EXECUTION: COMMENCED."
                ],
                .timerComplete: [
                    "0x00: EXECUTION SUCCESS.", "CHRONO-STREAM RESOLVED.", "CYBER-VICTORY LOGGED."
                ],
                .poke(level: 1): [
                    "SYSTEM INTERRUPT 0x01.", "CURSOR HITBOX CONFIRMED.", "TOUCH TELEMETRY LOGGED."
                ],
                .crumb: [
                    "INGESTING 64-BIT CRUMB.", "CALORIE PARSER: OK.", "ENERGY HARVESTED."
                ]
            ]
        )
    }

    var activeCompanion: TimeCompanion {
        companionCatalog[activeCompanionId] ?? companionCatalog[.timeDuck]!
    }

    func companion(for id: TimeCompanionId) -> TimeCompanion {
        companionCatalog[id] ?? companionCatalog[.timeDuck]!
    }

    var allCompanions: [TimeCompanion] {
        TimeCompanionId.allCases.compactMap { companionCatalog[$0] }
    }

    func isUnlocked(_ id: TimeCompanionId) -> Bool {
        #if DEBUG
        if DeveloperOverride.shared.isUnlockAllActive {
            return true
        }
        #endif
        return unlockedCompanionIds.contains(id) || id == .timeDuck
    }

    /// Sanitizes active companion to ensure it is valid under genuine progression.
    func sanitizeActiveCompanion() {
        if !isUnlocked(activeCompanionId) {
            activeCompanionId = .timeDuck
        }
    }

    @discardableResult
    func unlock(_ id: TimeCompanionId) -> Bool {
        guard !unlockedCompanionIds.contains(id) else { return false }
        unlockedCompanionIds.insert(id)
        return true
    }

    @discardableResult
    func select(_ id: TimeCompanionId) -> Bool {
        guard isUnlocked(id) else { return false }
        activeCompanionId = id
        return true
    }

    func restoreState(activeId: String?, unlockedIds: [String]?) {
        var restoredSet: Set<TimeCompanionId> = [.timeDuck]
        if let list = unlockedIds {
            for raw in list {
                if let resolved = TimeCompanionId(rawValue: raw) {
                    restoredSet.insert(resolved)
                }
            }
        }
        unlockedCompanionIds = restoredSet

        let targetId = TimeCompanionId.safeResolve(activeId)
        if isUnlocked(targetId) {
            activeCompanionId = targetId
        } else {
            activeCompanionId = .timeDuck
        }
    }
}
