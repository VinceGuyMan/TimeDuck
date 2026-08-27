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
}

final class StopwatchModel {
    private(set) var startAnchor: Date?      // wall-clock anchor when running began
    private(set) var banked: TimeInterval = 0 // accumulated time from prior runs
    private(set) var laps: [Lap] = []
    private var lastLapTotal: TimeInterval = 0

    var isRunning: Bool { startAnchor != nil }

    /// Returns elapsed seconds at a given moment. Accurate under load, sleep, and backgrounding.
    func elapsed(at date: Date = Date()) -> TimeInterval {
        guard let anchor = startAnchor else { return banked }
        return max(0, banked + date.timeIntervalSince(anchor))
    }

    var elapsed: TimeInterval { elapsed(at: Date()) }

    func start(now: Date = Date()) {
        guard startAnchor == nil else { return }
        startAnchor = now
    }

    func stop(now: Date = Date()) {
        guard let anchor = startAnchor else { return }
        banked += max(0, now.timeIntervalSince(anchor))
        startAnchor = nil
    }

    @discardableResult
    func lap(now: Date = Date()) -> Lap? {
        let t = elapsed(at: now)
        guard t > lastLapTotal + 0.001 else { return nil } // ignore zero-length double-taps
        let l = Lap(
            index: laps.count + 1,
            split: max(0, t - lastLapTotal),
            total: t,
            hue: Double((laps.count * 67) % 100) / 100.0
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
        self.banked = max(0, banked)
        if running, let anchor = startAnchor {
            self.startAnchor = anchor
        } else {
            self.startAnchor = nil
        }
        laps.removeAll()
        for i in 0..<min(splits.count, totals.count) {
            laps.append(Lap(
                index: i + 1,
                split: splits[i],
                total: totals[i],
                hue: Double((i * 67) % 100) / 100.0
            ))
        }
        lastLapTotal = laps.last?.total ?? 0
    }
}

// MARK: - Countdown Timer

final class TimerModel {
    private(set) var duration: TimeInterval = 60         // default 1m (01:00)
    private(set) var remainingAtStop: TimeInterval = 60  // remaining when paused/stopped
    private(set) var endWall: Date?                      // wall-clock finish timestamp
    private(set) var completionRecorded = false

    var isRunning: Bool { endWall != nil }

    func remaining(at date: Date = Date()) -> TimeInterval {
        guard let end = endWall else { return max(0, remainingAtStop) }
        return max(0, end.timeIntervalSince(date))
    }

    var remaining: TimeInterval { remaining(at: Date()) }

    func isFinished(at date: Date = Date()) -> Bool {
        guard isRunning, let end = endWall else { return false }
        return date >= end
    }

    var finished: Bool { isFinished(at: Date()) }

    func setDuration(_ d: TimeInterval) {
        let clamped = min(max(5, d), 99 * 3600 + 3599) // 5s to 99h 59m 59s
        duration = clamped
        if isRunning {
            endWall = Date().addingTimeInterval(clamped)
        } else {
            remainingAtStop = clamped
        }
        completionRecorded = false
    }

    func add(_ delta: TimeInterval) {
        if isRunning {
            let newEnd = (endWall ?? Date()).addingTimeInterval(delta)
            endWall = newEnd
            duration = max(5, duration + delta)
        } else {
            let newDuration = max(5, duration + delta)
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
                      completionRecorded: Bool = false) {
        self.duration = duration > 0 ? duration : 60
        self.remainingAtStop = remainingAtStop > 0 ? remainingAtStop : self.duration
        if running, let end = endWall {
            self.endWall = end
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
        workDuration = max(60, d)
        if phase == .work && !isRunning {
            remainingAtStop = workDuration
        }
        if phase == .work { completionRecorded = false }
    }

    func setShortBreakDuration(_ d: TimeInterval) {
        shortBreakDuration = max(60, d)
        if phase == .shortBreak && !isRunning {
            remainingAtStop = shortBreakDuration
        }
        if phase == .shortBreak { completionRecorded = false }
    }

    func setLongBreakDuration(_ d: TimeInterval) {
        longBreakDuration = max(60, d)
        if phase == .longBreak && !isRunning {
            remainingAtStop = longBreakDuration
        }
        if phase == .longBreak { completionRecorded = false }
    }

    func remaining(at date: Date = Date()) -> TimeInterval {
        guard let end = endWall else { return max(0, remainingAtStop) }
        return max(0, end.timeIntervalSince(date))
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
            cyclesCompleted += 1
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
            cyclesCompleted += 1
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
        if isRunning {
            endWall = (endWall ?? Date()).addingTimeInterval(delta)
            switch phase {
            case .work:       workDuration = max(60, workDuration + delta)
            case .shortBreak: shortBreakDuration = max(60, shortBreakDuration + delta)
            case .longBreak:  longBreakDuration = max(60, longBreakDuration + delta)
            }
        } else {
            remainingAtStop = max(5, remainingAtStop + delta)
        }
        completionRecorded = false
    }

    func restoreState(phase: Int, cycles: Int, remainingAtStop: TimeInterval, running: Bool, endWall: Date?,
                      workDuration: TimeInterval = 25 * 60, shortBreakDuration: TimeInterval = 5 * 60,
                      longBreakDuration: TimeInterval = 15 * 60, completionRecorded: Bool = false) {
        self.phase = PomodoroPhase(rawValue: phase) ?? .work
        self.cyclesCompleted = max(0, cycles)
        self.workDuration = workDuration > 0 ? workDuration : 25 * 60
        self.shortBreakDuration = shortBreakDuration > 0 ? shortBreakDuration : 5 * 60
        self.longBreakDuration = longBreakDuration > 0 ? longBreakDuration : 15 * 60
        self.remainingAtStop = remainingAtStop > 0 ? remainingAtStop : currentDuration
        if running, let end = endWall {
            self.endWall = end
        } else {
            self.endWall = nil
        }
        self.completionRecorded = completionRecorded
    }

    func markCompletionRecorded() { completionRecorded = true }
}
