// MARK: - TimeDuck · DomainEvents.swift
// Strongly typed, decoupled domain events for Wave 8 (TimeCompanions + Achievements).
// Invariant: Observers react to events and NEVER own or mutate timekeeping state.

import Foundation

/// Application domain events published by clock, interaction, story, and cosmetic systems.
enum TimeDuckEvent: Equatable {
    case timerStarted(mode: Mode, duration: TimeInterval)
    case timerPaused(mode: Mode)
    case timerResumed(mode: Mode)
    case timerCompleted(mode: Mode, duration: TimeInterval, isWorkPomodoro: Bool, isMiniHUD: Bool)
    case timerExtended(delta: TimeInterval, isFinished: Bool)
    case timerCancelled(mode: Mode)
    case stopwatchLap(split: TimeInterval, total: TimeInterval, lapIndex: Int)
    case stopwatchReset
    case breadcrumbFed(totalFedToday: Int, triggeredChonky: Bool)
    case duckPoked(level: Int, isTantrum: Bool)
    case costumeChanged(hat: DuckHat)
    case themeChanged(theme: ThemeType)
    case storyStarted(storyId: DuckStoryId)
    case storyCompleted(storyId: DuckStoryId)
    case rareEventTriggered(type: RareSecretEventType)
    case miniHUDToggled(isMini: Bool)
    case soundToggled(enabled: Bool)
    case streakUpdated(days: Int)
    case companionSelected(id: String)
    case achievementUnlocked(id: String)
}

/// Lightweight protocol for systems that observe application domain events.
protocol TimeDuckEventObserver: AnyObject {
    func handleEvent(_ event: TimeDuckEvent)
}
