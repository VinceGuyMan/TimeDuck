// MARK: - TimeDuck · AchievementEngine.swift
// Declarative achievement system and unlock evaluator for Wave 8.
// Philosophy: Curated milestones, discoveries, and memories — NO engagement grind.
// Invariant: Evaluation observes time events and NEVER alters clock state.

import Foundation

// MARK: - Achievement Model

enum AchievementCategory: String, Codable {
    case milestone = "Milestone"
    case story = "Duck Story"
    case exploration = "Exploration"
    case secret = "Secret Discovery"
}

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let hint: String
    let isHidden: Bool
    let category: AchievementCategory
    let glyph: [String]
    let rewardCompanionId: TimeCompanionId?
    let rewardDescription: String?

    var displayTitle: String {
        title
    }

    var displayDescription: String {
        description
    }

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Achievement Unlock Toast

struct AchievementUnlockToast: Equatable {
    let id: String
    let title: String
    let description: String
    let glyph: [String]
    let rewardDescription: String?
    let timestamp: Date

    var isSecret: Bool
}

// MARK: - Achievement Engine Coordinator

final class AchievementEngine {
    static let shared = AchievementEngine()

    private(set) var catalog: [String: Achievement] = [:]
    private(set) var orderedCatalog: [Achievement] = []
    private(set) var unlockedTimestamps: [String: Date] = [:]
    private(set) var pendingToasts: [AchievementUnlockToast] = []
    private(set) var activeToast: AchievementUnlockToast? = nil
    private(set) var activeToastUntil: Date = .distantPast

    // Event evaluation counters
    private(set) var breadcrumbsFedTotal: Int = 0
    private(set) var costumesTried: Set<Int> = []

    // Callback for UI / Sound trigger
    var onUnlock: ((Achievement, AchievementUnlockToast) -> Void)?

    init() {
        registerCuratedAchievements()
    }

    private func registerCuratedAchievements() {
        let items: [Achievement] = [
            // 1. First Waddle
            Achievement(
                id: "first_waddle",
                title: "First Waddle",
                description: "Successfully complete your first countdown timer.",
                hint: "Complete any countdown timer session.",
                isHidden: false,
                category: .milestone,
                glyph: BADGE_GLYPH_TIMER,
                rewardCompanionId: .duckling,
                rewardDescription: "Unlocked Companion: Duckling!"
            ),
            // 2. Focused Duck
            Achievement(
                id: "focused_duck",
                title: "Focused Duck",
                description: "Complete a full Pomodoro work focus session.",
                hint: "Finish a Pomodoro focus interval without quitting.",
                isHidden: false,
                category: .milestone,
                glyph: BADGE_GLYPH_POMO,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 3. Marathon Duck
            Achievement(
                id: "marathon_duck",
                title: "Marathon Duck",
                description: "Complete a focus session of 45 minutes or longer.",
                hint: "Run and finish a single timer of at least 45 minutes.",
                isHidden: false,
                category: .milestone,
                glyph: BADGE_GLYPH_STAR,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 4. Quack of Dawn
            Achievement(
                id: "quack_of_dawn",
                title: "Quack of Dawn",
                description: "Complete a timer between 5:00 AM and 8:00 AM.",
                hint: "Finish a focus session in the early morning.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_SUN,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 5. Night Owl... Duck?
            Achievement(
                id: "night_owl",
                title: "Night Owl... Duck?",
                description: "Complete a timer late at night between 11:00 PM and 5:00 AM.",
                hint: "Finish a focus session during the late night shift.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_MOON,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 6. Absolute Unit
            Achievement(
                id: "absolute_unit",
                title: "Absolute Unit",
                description: "Witness the majestic sphere of Chonky Duck mode.",
                hint: "Feed TimeDuck rapid breadcrumbs in succession.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_BREAD,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 7. Breadwinner
            Achievement(
                id: "breadwinner",
                title: "Breadwinner",
                description: "Feed TimeDuck a lifetime total of 25 breadcrumbs.",
                hint: "Keep the duck well fed during focus pauses.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_HEART,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 8. Personal Space
            Achievement(
                id: "personal_space",
                title: "Personal Space",
                description: "Reach maximum poke escalation and witness duck chaos.",
                hint: "Repeatedly tap or prod the duck on duty.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_SHIELD,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 9. Worth It. (The Feast)
            Achievement(
                id: "worth_it",
                title: "Worth It.",
                description: "Complete the full narrative cycle of The Feast.",
                hint: "Run a timer with The Feast story enabled until the finale.",
                isHidden: false,
                category: .story,
                glyph: BADGE_GLYPH_BREAD,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 10. Summit Duck (The Expedition)
            Achievement(
                id: "summit_duck",
                title: "Summit Duck",
                description: "Hike, climb, and plant the flag in The Expedition.",
                hint: "Complete a focus session running The Expedition.",
                isHidden: false,
                category: .story,
                glyph: BADGE_GLYPH_FLAG,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 11. Clocked Out (Night Shift)
            Achievement(
                id: "clocked_out",
                title: "Clocked Out",
                description: "Survive late-night duties and complete Night Shift.",
                hint: "Complete a focus session running Night Shift.",
                isHidden: false,
                category: .story,
                glyph: BADGE_GLYPH_MOON,
                rewardCompanionId: .guardDuck,
                rewardDescription: "Unlocked Companion: Guard Duck!"
            ),
            // 12. No Days Off (The WOD)
            Achievement(
                id: "no_days_off",
                title: "No Days Off",
                description: "Complete a full procedural gym workout in The WOD.",
                hint: "Complete a session running The WOD.",
                isHidden: false,
                category: .story,
                glyph: BADGE_GLYPH_CROWN,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 13. Leave No Duck Behind (The Rescue)
            Achievement(
                id: "leave_no_duck_behind",
                title: "Leave No Duck Behind",
                description: "Infiltrate security and complete The Rescue.",
                hint: "Complete a focus session running The Rescue.",
                isHidden: false,
                category: .story,
                glyph: BADGE_GLYPH_HEART,
                rewardCompanionId: .girlDuck,
                rewardDescription: "Unlocked Companion: Girl Duck!"
            ),
            // 14. Pocket Sized
            Achievement(
                id: "pocket_sized",
                title: "Pocket Sized",
                description: "Successfully finish a timer while working in MiniHUD mode.",
                hint: "Switch to MiniHUD and let a countdown timer reach zero.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_TIMER,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 15. Fashionably Late
            Achievement(
                id: "fashionably_late",
                title: "Fashionably Late",
                description: "Explore the living wardrobe and try on at least 5 different hats.",
                hint: "Cycle through various costumes in the Costume menu.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_STAR,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 16. Speed Demon
            Achievement(
                id: "speed_demon",
                title: "Speed Demon",
                description: "Log a stopwatch lap split in under 5.0 seconds.",
                hint: "Record a rapid split while the stopwatch is ticking.",
                isHidden: false,
                category: .exploration,
                glyph: BADGE_GLYPH_TIMER,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 17. Ghost in the Pond (Secret)
            Achievement(
                id: "secret_glitch",
                title: "Ghost in the Pond",
                description: "Witness a rare phantom glitch or spectral anomaly.",
                hint: "???",
                isHidden: true,
                category: .secret,
                glyph: BADGE_GLYPH_GHOST,
                rewardCompanionId: .cyberDuck,
                rewardDescription: "Unlocked Secret Companion: CyberDuck!"
            ),
            // 18. Golden Feathers (Secret)
            Achievement(
                id: "golden_feathers",
                title: "Golden Feathers",
                description: "Experience the ultra-rare Golden Duck Ascension.",
                hint: "???",
                isHidden: true,
                category: .secret,
                glyph: BADGE_GLYPH_STAR,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 19. Pond Maestro (Secret)
            Achievement(
                id: "pond_maestro",
                title: "Pond Maestro",
                description: "Switch soundtrack tracks and customize pond audio.",
                hint: "???",
                isHidden: true,
                category: .secret,
                glyph: BADGE_GLYPH_STAR,
                rewardCompanionId: nil,
                rewardDescription: nil
            ),
            // 20. Flock Veteran
            Achievement(
                id: "flock_veteran",
                title: "Flock Veteran",
                description: "Build a 3-day consecutive focus streak.",
                hint: "Use TimeDuck across multiple consecutive days.",
                isHidden: false,
                category: .milestone,
                glyph: BADGE_GLYPH_CROWN,
                rewardCompanionId: nil,
                rewardDescription: nil
            )
        ]

        orderedCatalog = items
        for item in items {
            catalog[item.id] = item
        }
    }

    func isUnlocked(_ id: String) -> Bool {
        #if DEBUG
        if DeveloperOverride.shared.isUnlockAllActive {
            return true
        }
        #endif
        return unlockedTimestamps[id] != nil
    }

    func unlockDate(for id: String) -> Date? {
        #if DEBUG
        if DeveloperOverride.shared.isUnlockAllActive {
            return unlockedTimestamps[id] ?? Date(timeIntervalSince1970: 0)
        }
        #endif
        return unlockedTimestamps[id]
    }

    var unlockedCount: Int {
        #if DEBUG
        if DeveloperOverride.shared.isUnlockAllActive {
            return orderedCatalog.count
        }
        #endif
        return unlockedTimestamps.count
    }

    var totalCount: Int {
        orderedCatalog.count
    }

    /// Evaluates incoming domain events against achievement conditions.
    /// Thread-safe and strictly idempotent.
    @discardableResult
    func evaluateEvent(_ event: TimeDuckEvent, stats: StatsTracker, now: Date = Date()) -> [Achievement] {
        var unlockedNow: [Achievement] = []

        switch event {
        case .timerCompleted(let mode, let duration, let isWorkPomodoro, let isMiniHUD):
            // 1. First Waddle
            if unlock("first_waddle", now: now), let a = catalog["first_waddle"] {
                unlockedNow.append(a)
            }
            // 2. Focused Duck
            if mode == .pomodoro && isWorkPomodoro {
                if unlock("focused_duck", now: now), let a = catalog["focused_duck"] {
                    unlockedNow.append(a)
                }
            }
            // 3. Marathon Duck
            if duration >= 2700 {
                if unlock("marathon_duck", now: now), let a = catalog["marathon_duck"] {
                    unlockedNow.append(a)
                }
            }
            // 4. Quack of Dawn (05:00 ... 07:59)
            let hour = Calendar.current.component(.hour, from: now)
            if hour >= 5 && hour < 8 {
                if unlock("quack_of_dawn", now: now), let a = catalog["quack_of_dawn"] {
                    unlockedNow.append(a)
                }
            }
            // 5. Night Owl (23:00 ... 04:59)
            if hour >= 23 || hour < 5 {
                if unlock("night_owl", now: now), let a = catalog["night_owl"] {
                    unlockedNow.append(a)
                }
            }
            // 14. Pocket Sized
            if isMiniHUD {
                if unlock("pocket_sized", now: now), let a = catalog["pocket_sized"] {
                    unlockedNow.append(a)
                }
            }

        case .breadcrumbFed(_, let triggeredChonky):
            breadcrumbsFedTotal += 1
            if triggeredChonky {
                if unlock("absolute_unit", now: now), let a = catalog["absolute_unit"] {
                    unlockedNow.append(a)
                }
            }
            if breadcrumbsFedTotal >= 25 {
                if unlock("breadwinner", now: now), let a = catalog["breadwinner"] {
                    unlockedNow.append(a)
                }
            }

        case .duckPoked(let level, _):
            if level >= 5 {
                if unlock("personal_space", now: now), let a = catalog["personal_space"] {
                    unlockedNow.append(a)
                }
            }

        case .storyCompleted(let storyId):
            switch storyId {
            case .theFeast:
                if unlock("worth_it", now: now), let a = catalog["worth_it"] {
                    unlockedNow.append(a)
                }
            case .theExpedition:
                if unlock("summit_duck", now: now), let a = catalog["summit_duck"] {
                    unlockedNow.append(a)
                }
            case .nightShift:
                if unlock("clocked_out", now: now), let a = catalog["clocked_out"] {
                    unlockedNow.append(a)
                }
            case .theWod:
                if unlock("no_days_off", now: now), let a = catalog["no_days_off"] {
                    unlockedNow.append(a)
                }
            case .theRescue:
                if unlock("leave_no_duck_behind", now: now), let a = catalog["leave_no_duck_behind"] {
                    unlockedNow.append(a)
                }
            default: break
            }

        case .costumeChanged(let hat):
            if hat != .none {
                costumesTried.insert(hat.rawValue)
                if costumesTried.count >= 5 {
                    if unlock("fashionably_late", now: now), let a = catalog["fashionably_late"] {
                        unlockedNow.append(a)
                    }
                }
            }

        case .stopwatchLap(let split, _, _):
            if split > 0.05 && split < 5.0 {
                if unlock("speed_demon", now: now), let a = catalog["speed_demon"] {
                    unlockedNow.append(a)
                }
            }

        case .rareEventTriggered(let type):
            if type == .ghostGlitch {
                if unlock("secret_glitch", now: now), let a = catalog["secret_glitch"] {
                    unlockedNow.append(a)
                }
            } else if type == .goldenDuck {
                if unlock("golden_feathers", now: now), let a = catalog["golden_feathers"] {
                    unlockedNow.append(a)
                }
            }

        case .soundToggled:
            if unlock("pond_maestro", now: now), let a = catalog["pond_maestro"] {
                unlockedNow.append(a)
            }

        case .streakUpdated(let days):
            if days >= 3 {
                if unlock("flock_veteran", now: now), let a = catalog["flock_veteran"] {
                    unlockedNow.append(a)
                }
            }

        default: break
        }

        // Evaluate streak from stats directly as well
        if stats.streakDays >= 3 {
            if unlock("flock_veteran", now: now), let a = catalog["flock_veteran"] {
                unlockedNow.append(a)
            }
        }

        return unlockedNow
    }

    /// Idempotently unlocks an achievement, queues toast presentation, and grants companion rewards.
    @discardableResult
    func unlock(_ id: String, now: Date = Date()) -> Bool {
        guard unlockedTimestamps[id] == nil, let achievement = catalog[id] else {
            return false
        }
        unlockedTimestamps[id] = now

        // Check if achievement carries a companion unlock reward
        if let compId = achievement.rewardCompanionId {
            TimeCompanionRegistry.shared.unlock(compId)
        }

        // Create unlock toast
        let toast = AchievementUnlockToast(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            glyph: achievement.glyph,
            rewardDescription: achievement.rewardDescription,
            timestamp: now,
            isSecret: achievement.isHidden
        )
        pendingToasts.append(toast)
        onUnlock?(achievement, toast)
        return true
    }

    /// Updates active toast lifecycle. Toasts display for ~3.5 seconds before popping next from queue.
    func updateToasts(now: Date = Date()) {
        if activeToast != nil && now >= activeToastUntil {
            activeToast = nil
        }
        if activeToast == nil && !pendingToasts.isEmpty {
            activeToast = pendingToasts.removeFirst()
            activeToastUntil = now.addingTimeInterval(3.6)
        }
    }

    func clearActiveToast() {
        activeToast = nil
        activeToastUntil = .distantPast
    }

    func restoreState(
        unlockedAchievements: [String: String]?,
        breadcrumbsTotal: Int? = 0,
        triedHats: [Int]? = []
    ) {
        let formatter = ISO8601DateFormatter()
        var restored: [String: Date] = [:]
        if let map = unlockedAchievements {
            for (key, val) in map {
                if let date = formatter.date(from: val) {
                    restored[key] = date
                } else {
                    restored[key] = Date()
                }
                // Also ensure companion rewards for previously unlocked achievements are unlocked
                if let achievement = catalog[key], let compId = achievement.rewardCompanionId {
                    TimeCompanionRegistry.shared.unlock(compId)
                }
            }
        }
        self.unlockedTimestamps = restored
        self.breadcrumbsFedTotal = max(0, breadcrumbsTotal ?? 0)
        self.costumesTried = Set(triedHats ?? [])
    }
}
