// MARK: - TimeDuck · DuckbookEngine.swift
// Duckbook state coordinator and presentation models for Wave 8.
// The cozy retro living journal for TimeCompanions, Achievements, and Secrets.

import Foundation

enum DuckbookTab: Int, CaseIterable, Codable {
    case companions = 0
    case achievements = 1
    case secrets = 2

    var title: String {
        switch self {
        case .companions:   return "COMPANIONS"
        case .achievements: return "ACHIEVEMENTS"
        case .secrets:      return "SECRETS"
        }
    }
}

final class DuckbookEngine {
    static let shared = DuckbookEngine()

    private(set) var isOpen: Bool = false
    private(set) var activeTab: DuckbookTab = .companions
    private(set) var selectedIndex: Int = 0
    private(set) var scrollOffset: Int = 0

    // Callback on state change
    var onChange: (() -> Void)?

    private var accumulatedDeltaY: Double = 0.0
    private let scrollThreshold: Double = 3.5

    func open(tab: DuckbookTab = .companions) {
        isOpen = true
        activeTab = tab
        selectedIndex = 0
        scrollOffset = 0
        accumulatedDeltaY = 0.0
        onChange?()
    }

    func close() {
        isOpen = false
        accumulatedDeltaY = 0.0
        onChange?()
    }

    func toggle() {
        if isOpen {
            close()
        } else {
            open()
        }
    }

    func setTab(_ tab: DuckbookTab) {
        guard activeTab != tab else { return }
        activeTab = tab
        selectedIndex = 0
        scrollOffset = 0
        accumulatedDeltaY = 0.0
        onChange?()
    }

    func nextTab() {
        let all = DuckbookTab.allCases
        let next = (activeTab.rawValue + 1) % all.count
        setTab(all[next])
    }

    func prevTab() {
        let all = DuckbookTab.allCases
        let prev = (activeTab.rawValue - 1 + all.count) % all.count
        setTab(all[prev])
    }

    func maxItemsForCurrentTab() -> Int {
        switch activeTab {
        case .companions:
            return TimeCompanionRegistry.shared.allCompanions.count
        case .achievements:
            return AchievementEngine.shared.orderedCatalog.count
        case .secrets:
            return 4 // 4 secret summary categories
        }
    }

    func moveSelection(delta: Int) {
        let maxItems = maxItemsForCurrentTab()
        guard maxItems > 0 else { return }
        let newIndex = min(max(0, selectedIndex + delta), maxItems - 1)
        if newIndex != selectedIndex {
            selectedIndex = newIndex
            // Adjust scroll offset if needed (visible window: 3 items)
            if selectedIndex < scrollOffset {
                scrollOffset = selectedIndex
            } else if selectedIndex >= scrollOffset + 3 {
                scrollOffset = selectedIndex - 2
            }
            onChange?()
        }
    }

    @discardableResult
    func handleScroll(deltaY: Double, isPrecise: Bool = false, isBegan: Bool = false, isEnded: Bool = false) -> Int {
        if isBegan || isEnded {
            accumulatedDeltaY = 0.0
        }
        if !isPrecise {
            if deltaY > 0 {
                moveSelection(delta: -1)
                return -1
            } else if deltaY < 0 {
                moveSelection(delta: 1)
                return 1
            }
            return 0
        }

        if (accumulatedDeltaY > 0 && deltaY < 0) || (accumulatedDeltaY < 0 && deltaY > 0) {
            accumulatedDeltaY = 0.0
        }

        accumulatedDeltaY += deltaY
        if abs(accumulatedDeltaY) >= scrollThreshold {
            let steps = Int(accumulatedDeltaY / scrollThreshold)
            accumulatedDeltaY -= Double(steps) * scrollThreshold
            let moveDelta = -steps
            moveSelection(delta: moveDelta)
            return moveDelta
        }
        return 0
    }

    @discardableResult
    func confirmSelection() -> Bool {
        switch activeTab {
        case .companions:
            let companions = TimeCompanionRegistry.shared.allCompanions
            guard selectedIndex >= 0 && selectedIndex < companions.count else { return false }
            let comp = companions[selectedIndex]
            if TimeCompanionRegistry.shared.isUnlocked(comp.id) {
                let success = TimeCompanionRegistry.shared.select(comp.id)
                onChange?()
                return success
            }
            return false
        case .achievements, .secrets:
            return true
        }
    }

    // MARK: - Accessibility Helper

    func accessibilitySummary() -> String {
        switch activeTab {
        case .companions:
            let companions = TimeCompanionRegistry.shared.allCompanions
            guard selectedIndex >= 0 && selectedIndex < companions.count else { return "Duckbook Companions" }
            let c = companions[selectedIndex]
            let unlocked = TimeCompanionRegistry.shared.isUnlocked(c.id)
            let isCurrent = (c.id == TimeCompanionRegistry.shared.activeCompanionId)
            let status = isCurrent ? "Active" : (unlocked ? "Unlocked" : "Locked")
            return "Companion: \(c.displayName). Status: \(status). \(c.subtitle). \(c.bio)"
        case .achievements:
            let items = AchievementEngine.shared.orderedCatalog
            guard selectedIndex >= 0 && selectedIndex < items.count else { return "Duckbook Achievements" }
            let a = items[selectedIndex]
            let unlocked = AchievementEngine.shared.isUnlocked(a.id)
            if a.isHidden && !unlocked {
                return "Secret Achievement: Locked. ???"
            }
            return "Achievement: \(a.title). Status: \(unlocked ? "Unlocked" : "Locked"). \(a.description)"
        case .secrets:
            let totalFed = AchievementEngine.shared.breadcrumbsFedTotal
            let streak = StatsTracker().streakDays
            return "Secrets Journal: Total breadcrumbs fed: \(totalFed). Current streak: \(streak) days."
        }
    }
}
