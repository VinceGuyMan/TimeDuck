// MARK: - TimeDuck · Persistence.swift
// Atomic JSON state persistence with debouncing and safe schema fallback.
// Wave 8: Added TimeCompanion and Achievement progression persistence.

import Foundation

struct PersistedState: Codable {
    var mode: Int
    var swBanked: TimeInterval
    var swRunning: Bool
    var swStartISO: String?
    var lapsSplits: [Double]
    var lapsTotals: [Double]
    var tmDuration: TimeInterval
    var tmRemainingAtStop: TimeInterval
    var tmRunning: Bool
    var tmEndISO: String?
    var tmCompletionRecorded: Bool?
    var pomoPhase: Int?
    var pomoCycles: Int?
    var pomoWorkDuration: Double?
    var pomoShortBreakDuration: Double?
    var pomoLongBreakDuration: Double?
    var pomoRemainingAtStop: Double?
    var pomoRunning: Bool?
    var pomoEndISO: String?
    var pomoCompletionRecorded: Bool?
    var theme: Int?
    var hat: Int?
    var crt: Bool
    var todayFocusSecs: Double?
    var todayPomos: Int?
    var streakDays: Int?
    var lastActiveDate: String?
    // Wave 8 Additions
    var selectedCompanion: String?
    var unlockedCompanions: [String]?
    var unlockedAchievements: [String: String]?
    var breadcrumbsFedTotal: Int?
    var costumesTried: [Int]?
}

enum Store {
    private static let isoFormatter = ISO8601DateFormatter()
    private static let saveQueue = DispatchQueue(label: "com.oxalpha.timeduck.persistence", qos: .utility)
    private static let saveQueueKey: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        saveQueue.setSpecific(key: key, value: ())
        return key
    }()
    private static var pendingSaveItem: DispatchWorkItem?
    static var storageDirectoryOverrideURL: URL?

    static var storageDirectoryURL: URL {
        if let override = storageDirectoryOverrideURL {
            try? FileManager.default.createDirectory(at: override, withIntermediateDirectories: true)
            return override
        }
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = appSupport.appendingPathComponent("TimeDuck", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static var stateFileURL: URL {
        storageDirectoryURL.appendingPathComponent("state.json")
    }

    /// Cancels any pending debounced save so that a subsequent immediate save is not overwritten by a stale async item.
    static func cancelPending() {
        syncOnSaveQueue {
            pendingSaveItem?.cancel()
            pendingSaveItem = nil
        }
    }

    static func saveImmediate(
        sw: StopwatchModel,
        tm: TimerModel,
        pomo: PomodoroModel,
        stats: StatsTracker,
        mode: Mode,
        theme: ThemeType,
        hat: DuckHat,
        crt: Bool
    ) {
        let st = makeSnapshot(sw: sw, tm: tm, pomo: pomo, stats: stats, mode: mode, theme: theme, hat: hat, crt: crt)
        syncOnSaveQueue {
            pendingSaveItem?.cancel()
            pendingSaveItem = nil
            writeState(st)
        }
    }

    /// Coalesces rapid updates (e.g. scroll wheel time tweaks, rapid clicks) into a single write.
    static func saveDebounced(
        sw: StopwatchModel,
        tm: TimerModel,
        pomo: PomodoroModel,
        stats: StatsTracker,
        mode: Mode,
        theme: ThemeType,
        hat: DuckHat,
        crt: Bool,
        delay: TimeInterval = 0.35
    ) {
        let st = makeSnapshot(sw: sw, tm: tm, pomo: pomo, stats: stats, mode: mode, theme: theme, hat: hat, crt: crt)
        saveQueue.async {
            pendingSaveItem?.cancel()
            let item = DispatchWorkItem {
                writeState(st)
                pendingSaveItem = nil
            }
            pendingSaveItem = item
            saveQueue.asyncAfter(deadline: .now() + delay, execute: item)
        }
    }

    private static func syncOnSaveQueue(_ work: () -> Void) {
        if DispatchQueue.getSpecific(key: saveQueueKey) != nil {
            work()
        } else {
            saveQueue.sync(execute: work)
        }
    }

    private static func makeSnapshot(
        sw: StopwatchModel,
        tm: TimerModel,
        pomo: PomodoroModel,
        stats: StatsTracker,
        mode: Mode,
        theme: ThemeType,
        hat: DuckHat,
        crt: Bool
    ) -> PersistedState {
        // Collect achievement date map
        var achMap: [String: String] = [:]
        for (k, v) in AchievementEngine.shared.unlockedTimestamps {
            achMap[k] = isoFormatter.string(from: v)
        }

        return PersistedState(
            mode: mode.rawValue,
            swBanked: sw.banked,
            swRunning: sw.isRunning,
            swStartISO: sw.startAnchor.map { isoFormatter.string(from: $0) },
            lapsSplits: sw.laps.map(\.split),
            lapsTotals: sw.laps.map(\.total),
            tmDuration: tm.duration,
            tmRemainingAtStop: tm.remainingAtStop,
            tmRunning: tm.isRunning,
            tmEndISO: tm.endWall.map { isoFormatter.string(from: $0) },
            tmCompletionRecorded: tm.completionRecorded,
            pomoPhase: pomo.phase.rawValue,
            pomoCycles: pomo.cyclesCompleted,
            pomoWorkDuration: pomo.workDuration,
            pomoShortBreakDuration: pomo.shortBreakDuration,
            pomoLongBreakDuration: pomo.longBreakDuration,
            pomoRemainingAtStop: pomo.remainingAtStop,
            pomoRunning: pomo.isRunning,
            pomoEndISO: pomo.endWall.map { isoFormatter.string(from: $0) },
            pomoCompletionRecorded: pomo.completionRecorded,
            theme: theme.rawValue,
            hat: hat.rawValue,
            crt: crt,
            todayFocusSecs: stats.todayFocusSeconds,
            todayPomos: stats.todayPomodoros,
            streakDays: stats.streakDays,
            lastActiveDate: stats.lastActiveDateStr,
            selectedCompanion: TimeCompanionRegistry.shared.unlockedCompanionIds.contains(TimeCompanionRegistry.shared.activeCompanionId) ? TimeCompanionRegistry.shared.activeCompanionId.rawValue : TimeCompanionId.timeDuck.rawValue,
            unlockedCompanions: TimeCompanionRegistry.shared.unlockedCompanionIds.map(\.rawValue),
            unlockedAchievements: achMap,
            breadcrumbsFedTotal: AchievementEngine.shared.breadcrumbsFedTotal,
            costumesTried: Array(AchievementEngine.shared.costumesTried)
        )
    }

    private static func writeState(_ state: PersistedState) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(state)
            try data.write(to: stateFileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("[TimeDuck] Failed to persist state: \(error)")
            #endif
        }
    }

    /// Loads saved state, safely ignoring corruption or missing files.
    static func load() -> PersistedState? {
        guard FileManager.default.fileExists(atPath: stateFileURL.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: stateFileURL)
            return try JSONDecoder().decode(PersistedState.self, from: data)
        } catch {
            #if DEBUG
            print("[TimeDuck] Failed to load persisted state, starting with defaults: \(error)")
            #endif
            return nil
        }
    }
}
