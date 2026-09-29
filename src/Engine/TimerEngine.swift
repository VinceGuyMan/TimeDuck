// MARK: - TimeDuck · TimerEngine.swift
// Core timing instruments: Stopwatch, Countdown Timer, and Pomodoro Focus Engine.
// Precision guarantee: All elapsed time derives from wall-clock Date anchors,
// never from animation frames, display links, or UI callbacks.

import Foundation

// MARK: - App Modes

enum Mode: Int, Codable, CaseIterable {
    case stopwatch = 0
    case timer = 1
    case pomodoro = 2

    var displayName: String {
        switch self {
        case .stopwatch: return "STOPWATCH"
        case .timer:     return "TIMER"
        case .pomodoro:  return "POMODORO"
        }
    }
}

// MARK: - Stopwatch & Laps

struct Lap: Codable, Equatable {
    let index: Int          // 1-based index
    let split: TimeInterval // duration of this lap alone
    let total: TimeInterval // cumulative duration at lap moment
    let hue: Double         // rainbow identity hue per lap
    let label: String?      // custom label (e.g. "THINKING", "TOOL", "DONE")

    init(index: Int, split: TimeInterval, total: TimeInterval, hue: Double, label: String? = nil) {
        self.index = index
        self.split = split
        self.total = total
        self.hue = hue
        self.label = label
    }
}

final class StopwatchModel {
    private static let maximumElapsed: TimeInterval = 999_999 * 3600 + 3599.99
    private static let maximumLapCount = 1_000
    private(set) var startAnchor: Date?      // wall-clock anchor when running began
    private(set) var banked: TimeInterval = 0 // accumulated time from prior runs
    private(set) var laps: [Lap] = []
    private var lastLapTotal: TimeInterval = 0

    var isRunning: Bool { startAnchor != nil }

    /// Returns elapsed seconds at a given moment. Accurate under load, sleep, and backgrounding.
    func elapsed(at date: Date = Date()) -> TimeInterval {
        guard let anchor = startAnchor else {
            return min(StopwatchModel.maximumElapsed, max(0, banked))
        }
        return min(StopwatchModel.maximumElapsed, max(0, banked + date.timeIntervalSince(anchor)))
    }

    var elapsed: TimeInterval { elapsed(at: Date()) }

    func start(now: Date = Date()) {
        guard startAnchor == nil else { return }
        startAnchor = now
    }

    func stop(now: Date = Date()) {
        guard let anchor = startAnchor else { return }
        banked = min(StopwatchModel.maximumElapsed, banked + max(0, now.timeIntervalSince(anchor)))
        startAnchor = nil
    }

    @discardableResult
    func lap(now: Date = Date(), label: String? = nil) -> Lap? {
        guard laps.count < StopwatchModel.maximumLapCount else { return nil }
        let t = elapsed(at: now)
        guard t > lastLapTotal + 0.001 else { return nil } // ignore zero-length double-taps
        let l = Lap(
            index: laps.count + 1,
            split: max(0, t - lastLapTotal),
            total: t,
            hue: Double((laps.count * 67) % 100) / 100.0,
            label: label
        )
        laps.append(l)
        lastLapTotal = t
        return l
    }

    func reset() {
        startAnchor = nil
        banked = 0
        laps.removeAll()
        lastLapTotal = 0
    }

    func restoreState(banked: TimeInterval, running: Bool, startAnchor: Date?, splits: [Double], totals: [Double]) {
        self.banked = banked.isFinite ? min(StopwatchModel.maximumElapsed, max(0, banked)) : 0
        if running, let anchor = startAnchor {
            self.startAnchor = anchor
        } else {
            self.startAnchor = nil
        }
        laps.removeAll()
        var previousTotal = 0.0
        for i in 0..<min(StopwatchModel.maximumLapCount, min(splits.count, totals.count)) {
            let split = splits[i]
            let total = totals[i]
            guard split.isFinite, total.isFinite,
                  split >= 0, total >= previousTotal else { continue }
            laps.append(Lap(
                index: laps.count + 1,
                split: split,
                total: total,
                hue: Double((laps.count * 67) % 100) / 100.0
            ))
            previousTotal = total
        }
        lastLapTotal = laps.last?.total ?? 0
    }
}

// MARK: - Countdown Timer

final class TimerModel {
    private static let maximumDuration: TimeInterval = 99 * 3600 + 3599
    private(set) var duration: TimeInterval = 60         // default 1m (01:00)
    private(set) var remainingAtStop: TimeInterval = 60  // remaining when paused/stopped
    private(set) var endWall: Date?                      // wall-clock finish timestamp
    private(set) var completionRecorded = false

    var isRunning: Bool { endWall != nil }

    func remaining(at date: Date = Date()) -> TimeInterval {
        guard let end = endWall else { return min(TimerModel.maximumDuration, max(0, remainingAtStop)) }
        let rem = end.timeIntervalSince(date)
        guard rem.isFinite else { return 0 }
        return min(TimerModel.maximumDuration, max(0, rem))
    }

    var remaining: TimeInterval { remaining(at: Date()) }

    func isFinished(at date: Date = Date()) -> Bool {
        guard isRunning, let end = endWall else { return false }
        return date >= end
    }

    var finished: Bool { isFinished(at: Date()) }

    func setDuration(_ d: TimeInterval) {
        let clamped = min(max(5, d), TimerModel.maximumDuration) // 5s to 99h 59m 59s
        duration = clamped
        if finished {
            endWall = nil
            remainingAtStop = clamped
        } else if isRunning {
            endWall = Date().addingTimeInterval(clamped)
        } else {
            remainingAtStop = clamped
        }
        completionRecorded = false
    }

    func add(_ delta: TimeInterval) {
        if finished {
            endWall = nil
            duration = min(max(5, duration + delta), TimerModel.maximumDuration)
            remainingAtStop = duration
        } else if isRunning {
            let adjustedDuration = min(max(5, duration + delta), TimerModel.maximumDuration)
            let appliedDelta = adjustedDuration - duration
            let newEnd = (endWall ?? Date()).addingTimeInterval(appliedDelta)
            endWall = newEnd
            duration = adjustedDuration
        } else {
            let newDuration = min(max(5, duration + delta), TimerModel.maximumDuration)
            setDuration(newDuration)
        }
        completionRecorded = false
    }

    func toggle(now: Date = Date()) {
        if isRunning {
            remainingAtStop = remaining(at: now)
            endWall = nil
        } else {
            let r = remainingAtStop > 0 ? remainingAtStop : duration
            remainingAtStop = r
            endWall = now.addingTimeInterval(r)
            completionRecorded = false
        }
    }

    func restart(now: Date = Date(), autoStart: Bool = false) {
        completionRecorded = false
        if autoStart {
            remainingAtStop = duration
            endWall = now.addingTimeInterval(duration)
        } else {
            endWall = nil
            remainingAtStop = duration
        }
    }

    func clear() {
        endWall = nil
        duration = 60
        remainingAtStop = 60
        completionRecorded = false
    }

    func restoreState(duration: TimeInterval, remainingAtStop: TimeInterval, running: Bool, endWall: Date?,
                      completionRecorded: Bool = false, now: Date = Date()) {
        self.duration = duration.isFinite ? min(max(5, duration), TimerModel.maximumDuration) : 60
        self.remainingAtStop = remainingAtStop.isFinite && remainingAtStop > 0
            ? min(remainingAtStop, min(self.duration, TimerModel.maximumDuration))
            : self.duration
        if running, let end = endWall {
            let rem = end.timeIntervalSince(now)
            if rem.isFinite && rem > 0 {
                let clampedRem = min(rem, min(self.duration, TimerModel.maximumDuration))
                self.endWall = now.addingTimeInterval(clampedRem)
            } else if rem.isFinite {
                self.endWall = end
            } else {
                self.endWall = nil
            }
        } else {
            self.endWall = nil
        }
        self.completionRecorded = completionRecorded
    }

    func markCompletionRecorded() { completionRecorded = true }
}

// MARK: - Pomodoro Focus Engine

enum PomodoroPhase: Int, Codable, CaseIterable {
    case work = 0
    case shortBreak = 1
    case longBreak = 2

    var title: String {
        switch self {
        case .work:       return "FOCUS"
        case .shortBreak: return "SHORT BREAK"
        case .longBreak:  return "LONG BREAK"
        }
    }

    var defaultDuration: TimeInterval {
        switch self {
        case .work:       return 25 * 60 // 25 mins
        case .shortBreak: return 5 * 60  // 5 mins
        case .longBreak:  return 15 * 60 // 15 mins
        }
    }
}

final class PomodoroModel {
    private static let maximumDuration: TimeInterval = 99 * 3600 + 3599
    // Far beyond a plausible lifetime total, but low enough to keep corrupt
    // persisted integers away from overflowing UI and transition arithmetic.
    private static let maximumCycleCount = 1_000_000
    private(set) var phase: PomodoroPhase = .work
    private(set) var cyclesCompleted: Int = 0
    private(set) var workDuration: TimeInterval = 25 * 60
    private(set) var shortBreakDuration: TimeInterval = 5 * 60
    private(set) var longBreakDuration: TimeInterval = 15 * 60
    private(set) var remainingAtStop: TimeInterval = 25 * 60
    private(set) var endWall: Date?
    private(set) var completionRecorded = false

    var isRunning: Bool { endWall != nil }

    var currentDuration: TimeInterval {
        switch phase {
        case .work:       return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak:  return longBreakDuration
        }
    }

    func setWorkDuration(_ d: TimeInterval) {
        let wasFinished = phase == .work && finished
        workDuration = min(max(60, d), PomodoroModel.maximumDuration)
        if wasFinished {
            endWall = nil
            remainingAtStop = workDuration
        } else if phase == .work && !isRunning {
            remainingAtStop = workDuration
        }
        if phase == .work { completionRecorded = false }
    }

    func setShortBreakDuration(_ d: TimeInterval) {
        let wasFinished = phase == .shortBreak && finished
        shortBreakDuration = min(max(60, d), PomodoroModel.maximumDuration)
        if wasFinished {
            endWall = nil
            remainingAtStop = shortBreakDuration
        } else if phase == .shortBreak && !isRunning {
            remainingAtStop = shortBreakDuration
        }
        if phase == .shortBreak { completionRecorded = false }
    }

    func setLongBreakDuration(_ d: TimeInterval) {
        let wasFinished = phase == .longBreak && finished
        longBreakDuration = min(max(60, d), PomodoroModel.maximumDuration)
        if wasFinished {
            endWall = nil
            remainingAtStop = longBreakDuration
        } else if phase == .longBreak && !isRunning {
            remainingAtStop = longBreakDuration
        }
        if phase == .longBreak { completionRecorded = false }
    }

    func remaining(at date: Date = Date()) -> TimeInterval {
        guard let end = endWall else { return min(PomodoroModel.maximumDuration, max(0, remainingAtStop)) }
        let rem = end.timeIntervalSince(date)
        guard rem.isFinite else { return 0 }
        return min(PomodoroModel.maximumDuration, max(0, rem))
    }

    var remaining: TimeInterval { remaining(at: Date()) }

    func isFinished(at date: Date = Date()) -> Bool {
        guard isRunning, let end = endWall else { return false }
        return date >= end
    }

    var finished: Bool { isFinished(at: Date()) }

    func toggle(now: Date = Date()) {
        if isRunning {
            remainingAtStop = remaining(at: now)
            endWall = nil
        } else {
            let r = remainingAtStop > 0 ? remainingAtStop : currentDuration
            remainingAtStop = r
            endWall = now.addingTimeInterval(r)
            completionRecorded = false
        }
    }

    func advancePhase(autoStart: Bool = false, now: Date = Date()) {
        endWall = nil
        completionRecorded = false
        if phase == .work {
            cyclesCompleted = cyclesCompleted >= PomodoroModel.maximumCycleCount ? 1 : cyclesCompleted + 1
            if cyclesCompleted % 4 == 0 {
                phase = .longBreak
            } else {
                phase = .shortBreak
            }
        } else {
            phase = .work
        }
        remainingAtStop = currentDuration
        if autoStart {
            endWall = now.addingTimeInterval(remainingAtStop)
        }
    }

    func skipPhase(autoStart: Bool = false, now: Date = Date()) {
        endWall = nil
        completionRecorded = false
        if phase == .work {
            cyclesCompleted = cyclesCompleted >= PomodoroModel.maximumCycleCount ? 1 : cyclesCompleted + 1
            if cyclesCompleted % 4 == 0 {
                phase = .longBreak
            } else {
                phase = .shortBreak
            }
        } else {
            phase = .work
        }
        remainingAtStop = currentDuration
        if autoStart {
            endWall = now.addingTimeInterval(remainingAtStop)
        }
    }

    func reset() {
        endWall = nil
        phase = .work
        cyclesCompleted = 0
        remainingAtStop = workDuration
        completionRecorded = false
    }

    func add(_ delta: TimeInterval) {
        let oldDuration = currentDuration
        let adjustedDuration = min(max(60, oldDuration + delta), PomodoroModel.maximumDuration)
        let appliedDelta = adjustedDuration - oldDuration

        if finished {
            endWall = nil
            switch phase {
            case .work:       workDuration = adjustedDuration
            case .shortBreak: shortBreakDuration = adjustedDuration
            case .longBreak:  longBreakDuration = adjustedDuration
            }
            remainingAtStop = currentDuration
        } else if isRunning {
            endWall = (endWall ?? Date()).addingTimeInterval(appliedDelta)
            switch phase {
            case .work:       workDuration = adjustedDuration
            case .shortBreak: shortBreakDuration = adjustedDuration
            case .longBreak:  longBreakDuration = adjustedDuration
            }
        } else {
            switch phase {
            case .work:       workDuration = adjustedDuration
            case .shortBreak: shortBreakDuration = adjustedDuration
            case .longBreak:  longBreakDuration = adjustedDuration
            }
            remainingAtStop = min(PomodoroModel.maximumDuration, max(5, remainingAtStop + appliedDelta))
        }
        completionRecorded = false
    }

    func restoreState(phase: Int, cycles: Int, remainingAtStop: TimeInterval, running: Bool, endWall: Date?,
                      workDuration: TimeInterval = 25 * 60, shortBreakDuration: TimeInterval = 5 * 60,
                      longBreakDuration: TimeInterval = 15 * 60, completionRecorded: Bool = false,
                      now: Date = Date()) {
        self.phase = PomodoroPhase(rawValue: phase) ?? .work
        self.cyclesCompleted = min(max(0, cycles), PomodoroModel.maximumCycleCount)
        self.workDuration = workDuration.isFinite ? min(max(60, workDuration), PomodoroModel.maximumDuration) : 25 * 60
        self.shortBreakDuration = shortBreakDuration.isFinite ? min(max(60, shortBreakDuration), PomodoroModel.maximumDuration) : 5 * 60
        self.longBreakDuration = longBreakDuration.isFinite ? min(max(60, longBreakDuration), PomodoroModel.maximumDuration) : 15 * 60
        self.remainingAtStop = remainingAtStop.isFinite && remainingAtStop > 0
            ? min(remainingAtStop, min(currentDuration, PomodoroModel.maximumDuration))
            : currentDuration
        if running, let end = endWall {
            let rem = end.timeIntervalSince(now)
            if rem.isFinite && rem > 0 {
                let clampedRem = min(rem, min(currentDuration, PomodoroModel.maximumDuration))
                self.endWall = now.addingTimeInterval(clampedRem)
            } else if rem.isFinite {
                self.endWall = end
            } else {
                self.endWall = nil
            }
        } else {
            self.endWall = nil
        }
        self.completionRecorded = completionRecorded
    }

    func markCompletionRecorded() { completionRecorded = true }
}
