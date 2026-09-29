// MARK: - TimeDuck · TimeDuckView.swift
// Stage coordinator and presentation engine.
// Renders the whole instrument into an integer pixel canvas, upscaled with nearest-neighbor.
// Pure presentation: reads the engine, never owns time.

import Foundation
import AppKit

// ── Small World Elements ─────────────────────────────────────────────────────

struct Star {
    var x: Int, y: Int
    var hue: Double, phase: Double, speed: Double
}

struct Particle {
    var x: Double, y: Double, vx: Double, vy: Double
    var life: Double, maxLife: Double
    var c: Color
    var grav: Double
}

struct SnoreParticle {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var life: Double
    var maxLife: Double
    var facingLeft: Bool
    var isMini: Bool
}

struct Breadcrumb {
    var x: Double, y: Double
    var life: Double
}

struct Btn {
    let id: String
    let x: Int, y: Int, w: Int, h: Int
}

// ── The View ─────────────────────────────────────────────────────────────────

final class TimeDuckView: NSObject {
    let sw: StopwatchModel
    let tm: TimerModel
    let pomo: PomodoroModel
    let stats: StatsTracker
    weak var snd: SoundEngine?

    // Geometry
    var scale = 7
    var gridW = 164
    var gridH = 100
    private(set) var mini = false
    var buttons: [Btn] = []
    var hoverId: String?

    // Rendering
    private var ctx: CGContext?
    var canvas = PixelCanvas(w: 1, h: 1)
    private var rowFactor: [Double] = []
    private var vig: [Double] = []
    var crtEnabled = true

    // Duck Costume & Customization
    var currentHat: DuckHat = .none
    var currentMode: Mode = .pomodoro

    // Ambience & Pets
    private var stars: [Star] = []
    private var parts: [Particle] = []
    private var snoreParticles: [SnoreParticle] = []
    private var nextSnoreTime = Date.distantPast
    private var crumbs: [Breadcrumb] = []
    private var emberBudget = 0.0
    private var lastFrame = Date()

    // Duck Brain & Physics
    private(set) var duckX = 120
    var duckGroundY = 68
    private var duckTargetX: Double = 120
    private var duckCurX: Double = 120
    private var duckFlip = false
    private var blinkUntil = Date.distantPast
    private var nextBlink = Date().addingTimeInterval(3)
    private var hopUntil = Date.distantPast
    private var flapUntil = Date.distantPast
    private var quackUntil = Date.distantPast
    private var peckUntil = Date.distantPast
    private var petUntil = Date.distantPast
    private var stridePhase = 0.0
    private var lastUserActivity = Date()

    // Speech Bubble & Word-by-Word MiniUI Queue
    private var speechText: String? = nil
    private var speechBorn = Date.distantPast
    private var speechUntil = Date.distantPast
    private var speechWords: [String] = []

    // FX Bookkeeping
    private var ghostPrev = ""
    private var ghostUntil = Date.distantPast
    private var toastText: String? = nil
    private var toastBorn = Date.distantPast
    private var pressMap: [String: Date] = [:]
    private var lastWholeSec = -1
    private var alertedTimerEnd: Date?
    private var alertedPomodoroEnd: Date?
    private var timerAlarmDismissed = false
    private var pomodoroAlarmDismissed = false
    var alarmDismissed: Bool {
        get {
            switch currentMode {
            case .timer: return timerAlarmDismissed
            case .pomodoro: return pomodoroAlarmDismissed
            case .stopwatch: return true
            }
        }
        set {
            switch currentMode {
            case .timer: timerAlarmDismissed = newValue
            case .pomodoro: pomodoroAlarmDismissed = newValue
            case .stopwatch: break
            }
        }
    }
    private var confettiPulse = Date.distantPast
    var onCompletionAlarm: (() -> Void)?

    let brain = DuckBrain()
    let storyEngine = DuckStoryEngine()

    // MARK: - Story Preview
    var isPreviewingStory = false
    var previewProgress: Double? = nil
    var storySpeedMultiplier: Double = 1.0

    // MARK: - Startup Splash Show
    var isShowingSplash = false
    private var splashStartTime: Date = .distantPast
    private let splashDuration: Double = 2.8
    private var splashVariant: Int = 0
    private var splashReadyChimed = false

    static let splashMessages = [
        "CALIBRATING QUACK...",
        "COUNTING BREADCRUMBS...",
        "WINDING CLOCKWORK...",
        "POLISHING BEAK...",
        "SYNCHRONIZING WADDLE...",
        "LOCATING POND...",
        "CHECKING FEATHER BUOYANCY...",
        "WARMING PHOSPHORS...",
        "DUCK FOUND.",
        "TIME ACQUIRED.",
        "READY TO QUACK."
    ]

    func startStartupSplash() {
        let showPref = UserDefaults.standard.object(forKey: "td.showStartupSplash") as? Bool ?? true
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        guard showPref && !reduceMotion else {
            isShowingSplash = false
            return
        }
        isShowingSplash = true
        splashStartTime = Date()
        splashVariant = Int.random(in: 0...3)
        splashReadyChimed = false
    }

    func skipSplash() {
        guard isShowingSplash else { return }
        isShowingSplash = false
        if !splashReadyChimed {
            snd?.splashBootChime()
            splashReadyChimed = true
        }
    }

    init(sw: StopwatchModel, tm: TimerModel, pomo: PomodoroModel, stats: StatsTracker) {
        self.sw = sw
        self.tm = tm
        self.pomo = pomo
        self.stats = stats
        super.init()
        seedStars()
        setupStoryEngine()
    }

    private func setupStoryEngine() {
        storyEngine.onSpeak = { [weak self] text, dur in
            self?.speak(text, duration: dur)
        }
        storyEngine.onDuckPose = { [weak self] pose, dur in
            self?.brain.setPose(pose, duration: dur)
        }
        storyEngine.onDropCrumb = { [weak self] in
            guard let self = self else { return }
            self.dropBreadcrumb(at: Double(self.duckX + (self.duckFlip ? -20 : 20)))
        }
        storyEngine.onPlaySound = { [weak self] sndName in
            guard let self = self, let snd = self.snd else { return }
            switch sndName {
            case "duckBurp": snd.duckBurp()
            case "gymTick": snd.gymTick()
            case "cameraSweepTick": snd.cameraSweepTick()
            case "alertBlip": snd.alertBlip()
            case "flagPlantFanfare": snd.flagPlantFanfare()
            default: break
            }
        }
        storyEngine.onSpawnSteamPuff = { [weak self] in
            self?.spawnSteamPuff()
        }
        storyEngine.onSpawnSweat = { [weak self] in
            self?.spawnSweat()
        }
        storyEngine.onStoryCompleted = { [weak self] storyId in
            guard let self = self else { return }
            AchievementEngine.shared.evaluateEvent(
                .storyCompleted(storyId: storyId),
                stats: self.stats,
                now: Date()
            )
        }
    }

    func getStoryContext() -> DuckStoryContext {
        let now = Date()
        let localHour = Calendar.current.component(.hour, from: now)
        var p = 0.0
        var total = 0.0
        var rem = 0.0
        var elapsed = 0.0

        if isPreviewingStory, let prevP = previewProgress {
            p = prevP
            total = 300.0
            elapsed = 300.0 * prevP
            rem = max(0.0, total - elapsed)
        } else {
            switch currentMode {
            case .timer:
                total = tm.duration
                rem = tm.remaining
                elapsed = max(0.0, total - rem)
                p = total > 0 ? min(1.0, max(0.0, elapsed / total)) : 0.0
            case .pomodoro:
                total = pomo.currentDuration
                rem = pomo.remaining
                elapsed = max(0.0, total - rem)
                p = total > 0 ? min(1.0, max(0.0, elapsed / total)) : 0.0
            case .stopwatch:
                total = 300.0
                elapsed = sw.elapsed
                rem = max(0.0, total - elapsed)
                p = min(1.0, max(0.0, elapsed / total))
            }
        }

        let isAnyPaused = (currentMode == .timer && !tm.isRunning && tm.remaining < tm.duration) ||
                          (currentMode == .pomodoro && !pomo.isRunning && pomo.remaining < pomo.currentDuration) ||
                          (currentMode == .stopwatch && !sw.isRunning && sw.elapsed > 0)

        return DuckStoryContext(
            mode: currentMode,
            isRunning: isPreviewingStory ? true : isAnyRunning,
            isPaused: isPreviewingStory ? false : isAnyPaused,
            isFinished: isPreviewingStory ? p >= 1.0 : isFinished,
            normalizedProgress: p,
            sessionDuration: total,
            remainingSeconds: rem,
            elapsedSeconds: elapsed,
            isCompact: mini,
            reduceMotion: NSWorkspace.shared.accessibilityDisplayShouldReduceMotion,
            localHour: localHour,
            currentHat: currentHat,
            currentTheme: ThemeRegistry.current
        )
    }

    /// Indicates whether high-rate animation (confetti, petting, moving, particles, idle poses) is currently occurring.
    var storyRequiresHighRateAnimation: Bool {
        storyEngine.isSessionStarted && (!storyEngine.isSessionPaused || storyEngine.isFinaleActive)
    }

    var hasActiveAnimation: Bool {
        if isShowingSplash { return true }
        if isEditingTime { return true }
        let now = Date()
        if !parts.isEmpty || !snoreParticles.isEmpty || !crumbs.isEmpty { return true }
        if now < hopUntil || now < flapUntil || now < quackUntil || now < peckUntil || now < petUntil { return true }
        if now < speechUntil || now.timeIntervalSince(toastBorn) < 1.6 { return true }
        if abs(duckTargetX - duckCurX) > 0.5 { return true }
        if isFinished && !alarmDismissed { return true }
        if brain.hasActivePose { return true }
        if storyRequiresHighRateAnimation { return true }
        return false
    }

    var isFinished: Bool {
        (currentMode == .pomodoro && pomo.finished) || (currentMode == .timer && tm.finished)
    }

    func clearSleepFX() {
        snoreParticles.removeAll()
        nextSnoreTime = .distantPast
    }

    var activeSnoreParticleCount: Int { snoreParticles.count }
    var activeTemporaryParticleCount: Int { parts.count }
    var activeBreadcrumbCount: Int { crumbs.count }

    func clearViewportOwnedEffects() {
        clearSleepFX()
        parts.removeAll()
        crumbs.removeAll()
        speechText = nil
        speechUntil = .distantPast
        toastText = nil
        emberBudget = 0
        petUntil = .distantPast
        hopUntil = .distantPast
        peckUntil = .distantPast
    }

    func clearTemporaryEffects() {
        clearViewportOwnedEffects()
        duckTargetX = duckCurX
    }

    func endStoryPreview() {
        guard isPreviewingStory else { return }
        isPreviewingStory = false
        previewProgress = nil
        storySpeedMultiplier = 1.0
        storyEngine.endPreview()
        clearTemporaryEffects()
    }

    /// Terminates previous story session, clears viewport effects, and rearms for a newly configured or reset clock session.
    func resetStoryForClockReconfiguration() {
        endStoryPreview()
        clearTemporaryEffects()
        let ctx = getStoryContext()
        storyEngine.cancelSession(context: ctx)
    }

    func spawnSnoreParticle(
        rows: [String],
        duckX: Int,
        duckY: Int,
        flip: Bool,
        isMini: Bool,
        now: Date
    ) {
        guard now >= nextSnoreTime, snoreParticles.count < 3 else { return }
        let billAnchor = DuckBillAnchorResolver.resolve(rows: rows, flip: flip)
        let spawnX = Double(duckX + billAnchor.x)
        let spawnY = Double(duckY + billAnchor.y)
        let horizontalSpeed = isMini ? Double.random(in: 1.5...3.0) : Double.random(in: 3.5...6.0)
        let verticalSpeed = isMini ? Double.random(in: -4.5...(-2.5)) : Double.random(in: -9.0...(-6.0))
        snoreParticles.append(SnoreParticle(
            x: spawnX,
            y: spawnY,
            vx: (billAnchor.facingLeft ? -1.0 : 1.0) * horizontalSpeed,
            vy: verticalSpeed,
            life: isMini ? 2.2 : 2.5,
            maxLife: isMini ? 2.2 : 2.5,
            facingLeft: billAnchor.facingLeft,
            isMini: isMini
        ))
        nextSnoreTime = now.addingTimeInterval(
            isMini ? Double.random(in: 2.5...3.5) : Double.random(in: 2.2...3.2)
        )
    }

    // MARK: - Direct Time Entry (Inline Editing)

    var isEditingTime: Bool = false
    var editBuffer: String = ""

    func beginTimeEdit() {
        guard currentMode == .timer || currentMode == .pomodoro else { return }
        isEditingTime = true
        editBuffer = ""
        toast("TYPE TIME (ENTER TO SET)")
    }

    func cancelTimeEdit() {
        isEditingTime = false
        editBuffer = ""
        toast("CANCELLED")
    }

    func commitTimeEdit() -> Bool {
        guard isEditingTime else { return false }
        isEditingTime = false
        let input = editBuffer
        editBuffer = ""
        guard let seconds = Fmt.parseDuration(input) else {
            toast("INVALID TIME")
            snd?.tone(freq: 220, dur: 0.12, vol: 0.10, type: .square)
            return false
        }
        resetStoryForClockReconfiguration()
        if currentMode == .timer {
            tm.setDuration(seconds)
            toast("TIMER: \(Fmt.tm(seconds))")
        } else if currentMode == .pomodoro {
            switch pomo.phase {
            case .work:
                pomo.setWorkDuration(seconds)
                toast("FOCUS: \(Fmt.tm(seconds))")
            case .shortBreak:
                pomo.setShortBreakDuration(seconds)
                toast("SHORT: \(Fmt.tm(seconds))")
            case .longBreak:
                pomo.setLongBreakDuration(seconds)
                toast("LONG: \(Fmt.tm(seconds))")
            }
        }
        snd?.blip()
        return true
    }

    func handleEditKey(_ e: NSEvent) -> Bool {
        guard isEditingTime else { return false }

        if e.keyCode == 53 { // Escape
            cancelTimeEdit()
            return true
        } else if e.keyCode == 36 || e.keyCode == 76 { // Return / Enter
            _ = commitTimeEdit()
            return true
        } else if e.keyCode == 51 { // Delete / Backspace
            if !editBuffer.isEmpty {
                editBuffer.removeLast()
            }
            return true
        } else if let chars = e.characters {
            for ch in chars {
                if ch.isNumber || ch == ":" || ch == "m" || ch == "s" || ch == "h" || ch == "." {
                    if editBuffer.count < 10 {
                        editBuffer.append(ch)
                    }
                }
            }
            return true
        }
        return false
    }

    // MARK: - Sizing & Canvas Setup

    var duckHitRect: (x: Int, y: Int, w: Int, h: Int) {
        if mini {
            let m = compactLayoutMetrics()
            return (x: m.duckX, y: m.duckY, w: m.duckW, h: m.duckH)
        } else {
            return (x: duckX - 4, y: duckGroundY - 14, w: 22, h: 18)
        }
    }

    var groundHitRect: (x: Int, y: Int, w: Int, h: Int)? {
        if mini { return nil }
        return (x: 14, y: duckGroundY - 16, w: gridW - 28, h: 22)
    }

    func setMini(_ m: Bool) {
        clearViewportOwnedEffects()
        mini = m
        gridW = m ? 144 : 164
        gridH = m ? 34 : 100
        scale = m ? 5 : 7
        seedStars()
        rebuildCanvas()
    }

    func resize(gridW gw: Int, gridH gh: Int) {
        let nw = mini ? max(80, min(gw, 220)) : max(130, min(gw, 280))
        let nh = mini ? max(20, min(gh, 60)) : max(75, min(gh, 160))
        guard nw != gridW || nh != gridH else { return }
        gridW = nw; gridH = nh
        seedStars()
        rebuildCanvas()
    }

    func rebuildCanvas() {
        canvas = PixelCanvas(w: gridW, h: gridH)
        rowFactor = PixelCanvas.makeRowFactor(h: gridH, enabled: crtEnabled)
        vig = PixelCanvas.makeVignette(w: gridW, h: gridH)
        guard let c = CGContext(
            data: UnsafeMutableRawPointer(canvas.p),
            width: gridW,
            height: gridH,
            bitsPerComponent: 8,
            bytesPerRow: gridW * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        ctx = c
        duckGroundY = mini ? gridH - 4 : 68
        if duckTargetX > Double(gridW - 24) || duckTargetX < 14 {
            duckTargetX = mini ? Double(gridW - 17) : Double(gridW - 36)
            duckCurX = duckTargetX
        }
        duckX = Int(duckCurX)
    }

    private func seedStars() {
        var rng = SystemRandomNumberGenerator()
        stars.removeAll(keepingCapacity: true)
        let n = mini ? 6 : 32
        for _ in 0..<n {
            stars.append(Star(
                x: Int.random(in: 1..<max(2, gridW - 1), using: &rng),
                y: Int.random(in: 1..<max(2, mini ? gridH - 3 : 50), using: &rng),
                hue: Double.random(in: 0...1),
                phase: Double.random(in: 0...(2 * Double.pi)),
                speed: Double.random(in: 0.6...2.2)
            ))
        }
    }

    // MARK: - Interaction Surface

    func layoutButtons() -> [Btn] {
        if DuckbookEngine.shared.isOpen && !mini {
            var bs: [Btn] = []
            let modalX = 6
            let modalY = 8
            let modalW = gridW - 12
            _ = gridH - 16

            // Close button (top right)
            bs.append(Btn(id: "db-close", x: modalX + modalW - 12, y: modalY + 2, w: 9, h: 8))

            // Tab buttons
            bs.append(Btn(id: "db-tab-0", x: modalX + 6, y: modalY + 11, w: 44, h: 8))
            bs.append(Btn(id: "db-tab-1", x: modalX + 54, y: modalY + 11, w: 52, h: 8))
            bs.append(Btn(id: "db-tab-2", x: modalX + 110, y: modalY + 11, w: 34, h: 8))

            // Companion select rows or list rows
            let count: Int
            switch DuckbookEngine.shared.activeTab {
            case .companions:
                count = TimeCompanionRegistry.shared.allCompanions.count
            case .achievements:
                count = AchievementEngine.shared.orderedCatalog.count
            case .secrets:
                count = 4
            }
            let start = min(max(0, DuckbookEngine.shared.scrollOffset), max(0, count - 3))
            let end = min(count, start + 3)
            for (rowIdx, itemIdx) in (start..<end).enumerated() {
                let btnId = (DuckbookEngine.shared.activeTab == .companions) ? "db-comp-\(itemIdx)" :
                            ((DuckbookEngine.shared.activeTab == .achievements) ? "db-ach-\(itemIdx)" : "db-sec-\(itemIdx)")
                bs.append(Btn(id: btnId, x: modalX + 4, y: modalY + 21 + rowIdx * 16, w: modalW - 8, h: 15))
            }
            return bs
        }
        if mini {
            let m = compactLayoutMetrics()
            var bs: [Btn] = []
            // Mode cycle pill (top-left)
            bs.append(Btn(id: "tab-cycle", x: m.modePillRect.x, y: m.modePillRect.y, w: m.modePillRect.w, h: m.modePillRect.h))
            // Clock time edit hit area
            bs.append(Btn(id: "clock-area", x: m.timeAreaRect.x, y: m.timeAreaRect.y, w: m.timeAreaRect.w, h: m.timeAreaRect.h))
            // Action controls (center)
            bs.append(Btn(id: "go", x: m.goRect.x, y: m.goRect.y, w: m.goRect.w, h: m.goRect.h))
            bs.append(Btn(id: "sec", x: m.secRect.x, y: m.secRect.y, w: m.secRect.w, h: m.secRect.h))
            // Top right glyph toggles
            bs.append(Btn(id: "toggle-sound", x: m.soundRect.x - 1, y: m.soundRect.y - 1, w: m.soundRect.w + 2, h: m.soundRect.h + 2))
            bs.append(Btn(id: "unmini", x: m.unminiRect.x - 1, y: m.unminiRect.y - 1, w: m.unminiRect.w + 2, h: m.unminiRect.h + 2))
            // Duck petting area
            bs.append(Btn(id: "pet-duck", x: m.duckX, y: m.duckY, w: m.duckW, h: m.duckH))
            return bs
        }
        var bs: [Btn] = []

        // Top bar toggles
        bs.append(Btn(id: "tgl-duckbook", x: gridW - 68, y: 1, w: 10, h: 8))
        bs.append(Btn(id: "tgl-mini", x: gridW - 57, y: 1, w: 10, h: 8))
        bs.append(Btn(id: "tgl-hat", x: gridW - 46, y: 1, w: 10, h: 8))
        bs.append(Btn(id: "tgl-theme", x: gridW - 35, y: 1, w: 10, h: 8))
        bs.append(Btn(id: "tgl-pin", x: gridW - 24, y: 1, w: 10, h: 8))
        bs.append(Btn(id: "toggle-sound", x: gridW - 13, y: 1, w: 10, h: 8))

        // Mode tabs
        bs.append(Btn(id: "tab-pomo", x: 4, y: 11, w: 32, h: 8))
        bs.append(Btn(id: "tab-tm", x: 38, y: 11, w: 25, h: 8))
        bs.append(Btn(id: "tab-sw", x: 65, y: 11, w: 42, h: 8))

        // Central clock clickable area for direct editing
        bs.append(Btn(id: "clock-area", x: 6, y: 19, w: gridW - 55, h: 26))

        // Main controls row (y: 73)
        let btnW = 48
        bs.append(Btn(id: "go", x: 6, y: 73, w: btnW, h: 11))
        bs.append(Btn(id: "sec", x: 58, y: 73, w: btnW, h: 11))
        bs.append(Btn(id: "reset", x: 110, y: 73, w: btnW, h: 11))

        // Bottom sub-bar chips (y: 87)
        if currentMode == .timer {
            let presets = ["1M", "5M", "15M", "25M"]
            for (i, p) in presets.enumerated() {
                bs.append(Btn(id: "preset-\(p)", x: 6 + i * 20, y: 87, w: 18, h: 9))
            }
            bs.append(Btn(id: "tm-m1", x: 92, y: 87, w: 18, h: 9))
            bs.append(Btn(id: "tm-p1", x: 113, y: 87, w: 18, h: 9))
            bs.append(Btn(id: "tm-p5", x: 134, y: 87, w: 24, h: 9))
        } else if currentMode == .pomodoro {
            bs.append(Btn(id: "pomo-25", x: 6, y: 87, w: 24, h: 9))
            bs.append(Btn(id: "pomo-50", x: 32, y: 87, w: 24, h: 9))
            bs.append(Btn(id: "pomo-p1", x: 92, y: 87, w: 18, h: 9))
            bs.append(Btn(id: "pomo-p5", x: 113, y: 87, w: 20, h: 9))
            bs.append(Btn(id: "feed-crumb", x: 136, y: 87, w: 22, h: 9))
        }

        return bs
    }

    func press(_ id: String) {
        pressMap[id] = Date()
        lastUserActivity = Date()
        clearSleepFX()
    }

    func toast(_ s: String) {
        clearSleepFX()
        toastText = s
        toastBorn = Date()
        lastUserActivity = Date()
    }

    func speak(_ s: String, duration: Double = 2.4) {
        speechText = s
        speechBorn = Date()
        speechUntil = Date().addingTimeInterval(duration)
        speechWords = s.replacingOccurrences(of: "\n", with: " ").split(separator: " ").map(String.init)
    }

    func duckHop() {
        hopUntil = Date().addingTimeInterval(0.40)
        quackUntil = Date().addingTimeInterval(0.35)
        lastUserActivity = Date()
        clearSleepFX()
        snd?.quack()
    }

    func petDuck() {
        lastUserActivity = Date()
        clearSleepFX()
        let ctx = getStoryContext()
        if storyEngine.activeStory != nil, let storyPoke = storyEngine.handleInteraction(type: "poke", context: ctx) {
            petUntil = Date().addingTimeInterval(0.85)
            duckHop()
            snd?.quack()
            speak(storyPoke, duration: 2.2)
            return
        }
        let res = brain.onPoke()
        petUntil = Date().addingTimeInterval(0.85)
        duckHop()
        if res.isTantrum {
            spawnConfetti(12)
            snd?.tantrumQuacks()
        } else if res.level >= 5 {
            spawnConfetti(6)
            snd?.annoyedQuack()
        } else if res.level >= 3 {
            snd?.quack(pitch: 0.85)
        } else if res.level == 2 {
            snd?.quack(pitch: 1.05)
        } else {
            spawnHearts(6)
            snd?.happyChirp()
        }
        speak(res.phrase)
        AchievementEngine.shared.evaluateEvent(
            .duckPoked(level: res.level, isTantrum: res.isTantrum),
            stats: stats,
            now: Date()
        )
    }

    func dropBreadcrumb(at gx: Double? = nil) {
        let x = gx ?? Double(Int.random(in: 20..<max(25, gridW - 35)))
        let y = Double(duckGroundY - 2)
        crumbs.append(Breadcrumb(x: x, y: y, life: 14.0))
        if crumbs.count > 32 {
            crumbs.removeFirst(crumbs.count - 32)
        }
        clearSleepFX()

        // Explicit Beak Alignment Calculation:
        // When approaching from the left, duck faces right (beak tip at x + 11 in DUCK_PECK_B).
        // When approaching from the right, duck faces left (beak tip at x + 1 in DUCK_PECK_B).
        let targetX: Double
        if duckCurX + 6 <= x {
            targetX = x - 11.0
        } else {
            targetX = x - 1.0
        }
        duckTargetX = max(18.0, min(Double(gridW - 32), targetX))
        lastUserActivity = Date()
        toast("CRUMB DROPPED")
        snd?.happyChirp()
    }

    func spawnHearts(_ n: Int) {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 6), oy = Double(duckGroundY - 12)
        for _ in 0..<n {
            appendParticle(Particle(
                x: ox, y: oy,
                vx: Double.random(in: -14...14, using: &rng),
                vy: Double.random(in: -24...(-10), using: &rng),
                life: Double.random(in: 0.8...1.4, using: &rng),
                maxLife: 1.4,
                c: Pal.red,
                grav: -10
            ))
        }
    }

    func spawnSteamPuff() {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 6), oy = Double(duckGroundY - 8)
        for _ in 0..<5 {
            appendParticle(Particle(
                x: ox, y: oy,
                vx: Double.random(in: -8...8, using: &rng),
                vy: Double.random(in: -18...(-8), using: &rng),
                life: Double.random(in: 0.6...1.2, using: &rng),
                maxLife: 1.2,
                c: Pal.sweat,
                grav: -3
            ))
        }
    }

    func spawnSweat() {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 7), oy = Double(duckGroundY - 9)
        for _ in 0..<2 {
            appendParticle(Particle(
                x: ox, y: oy,
                vx: Double.random(in: 8...16, using: &rng),
                vy: Double.random(in: -14...(-8), using: &rng),
                life: Double.random(in: 0.45...0.75, using: &rng),
                maxLife: 0.75,
                c: Pal.sweat,
                grav: 45
            ))
        }
    }

    func spawnCrumbParticles() {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + (duckFlip ? 1 : 11)), oy = Double(duckGroundY - 4)
        for _ in 0..<4 {
            appendParticle(Particle(
                x: ox, y: oy,
                vx: Double.random(in: -10...10, using: &rng),
                vy: Double.random(in: -15...(-5), using: &rng),
                life: Double.random(in: 0.4...0.8, using: &rng),
                maxLife: 0.8,
                c: Pal.amber,
                grav: 60
            ))
        }
    }

    func spawnConfetti(_ n: Int) {
        if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
            // Respect system reduced motion: skip high-velocity particles
            return
        }
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 6), oy = Double(duckGroundY - 10)
        for _ in 0..<n {
            appendParticle(Particle(
                x: ox, y: oy,
                vx: Double.random(in: -50...50, using: &rng),
                vy: Double.random(in: -100...(-40), using: &rng),
                life: Double.random(in: 0.8...1.6, using: &rng),
                maxLife: 1.6,
                c: rainbow(Double.random(in: 0...1)),
                grav: 170
            ))
        }
    }

    func dismissAlarm() {
        clearSleepFX()
        switch currentMode {
        case .timer: timerAlarmDismissed = true
        case .pomodoro: pomodoroAlarmDismissed = true
        case .stopwatch: break
        }
    }

    // MARK: - Master Render

    func render() {
        let now = Date()
        let t = now.timeIntervalSinceReferenceDate
        let dt = TimeDuckView.clampAnimationDelta(now.timeIntervalSince(lastFrame))
        lastFrame = now

        if isShowingSplash {
            renderSplash(t, now)
            let bandY = Int(t * 22) % (gridH + 44) - 22
            canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: bandY, bandH: 5)
            return
        }

        canvas.fillAll(mini ? Pal.bgDeep : Pal.bg)

        updateDuckBrain(dt, now: now)

        if mini {
            stepParticles(dt)
            stepSnoreParticles(dt)
            renderMini(t, now)
            canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: Int(t * 14) % (gridH + 30) - 15, bandH: 4)
            return
        }

        drawStars(t)
        drawEmbers(dt)
        drawBreadcrumbs()
        drawStoryScenery(zIndex: 0)
        drawChrome(t, now)
        drawClockArea(t, now)
        drawStoryActors()
        drawDuck(t, now)
        drawStoryScenery(zIndex: 1)
        stepParticles(dt)
        drawParticles()
        stepSnoreParticles(dt)
        drawSnoreParticles(nil)

        let bandY = Int(t * 22) % (gridH + 44) - 22
        canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: bandY, bandH: 5)

        drawToastOverlay(t)
        drawAchievementToastOverlay(now)

        if DuckbookEngine.shared.isOpen && !mini {
            drawDuckbookOverlay(t, now)
        }
    }

    static func clampAnimationDelta(_ rawDelta: TimeInterval) -> TimeInterval {
        min(0.1, max(0, rawDelta.isFinite ? rawDelta : 0))
    }

    // MARK: - Startup Splash Show Renderer

    private func renderSplash(_ t: Double, _ now: Date) {
        let elapsed = now.timeIntervalSince(splashStartTime)
        if elapsed >= splashDuration {
            skipSplash()
            return
        }

        canvas.fillAll(Pal.bgDeep)
        canvas.frameRect(0, 0, gridW, gridH, Pal.grid)
        canvas.frameRect(1, 1, gridW - 2, gridH - 2, Pal.panel)

        drawStars(t)

        if elapsed < 0.45 {
            // Phase 0: CRT Phosphor Beam wake
            let beamProgress = elapsed / 0.45
            let beamH = max(2, Int(beamProgress * Double(gridH - 10)))
            let beamY = (gridH - beamH) / 2
            let beamW = max(10, Int(beamProgress * Double(gridW - 20)))
            let beamX = (gridW - beamW) / 2
            canvas.fillRect(beamX, beamY, beamW, beamH, Pal.panelHi, a: UInt8(beamProgress * 200))
            canvas.hline(beamX, beamX + beamW - 1, gridH / 2, Pal.white)
        } else if elapsed < 1.35 {
            // Phase 1: TIMEDUCK logo assembly & phosphor scan
            let logoStr = "TIMEDUCK"
            let logoW = PixelCanvas.heroWidth(logoStr, scale: 2)
            let logoX = max(4, (gridW - logoW) / 2)
            let logoY = mini ? 4 : 26

            canvas.fillRect(logoX - 4, logoY - 3, logoW + 8, 18, Pal.panelHi, a: 160)
            canvas.frameRect(logoX - 4, logoY - 3, logoW + 8, 18, Pal.green)
            canvas.heroText(logoStr, x: logoX, y: logoY, c: Pal.green, scale: 2)

            let subStr = "V\(AppVersion.version) · CHRONO COMPANION"
            let subW = PixelCanvas.smallWidth(subStr)
            let subX = (gridW - subW) / 2
            canvas.smallText(subStr, x: subX, y: logoY + 22, c: Pal.amber)

            let hint = "PRESS ANY KEY TO SKIP"
            let hintW = PixelCanvas.smallWidth(hint)
            canvas.smallText(hint, x: (gridW - hintW) / 2, y: gridH - 12, c: Pal.inkDim)
        } else if elapsed < 2.35 {
            // Phase 2: Duck / Egg hatch & rotating absurd loading messages
            let eggX = (gridW - 13) / 2
            let eggY = mini ? 6 : 28

            let eggRows: [String]
            let eggSubphase = (elapsed - 1.35) / 1.00
            if eggSubphase < 0.35 {
                eggRows = SPLASH_EGG_A
            } else if eggSubphase < 0.70 {
                eggRows = SPLASH_EGG_B
            } else {
                eggRows = SPLASH_EGG_HATCH
            }

            var colorMap = getDuckColorMap()
            if splashVariant == 3 {
                colorMap = getDuckColorMap(rareEvent: .goldenDuck)
            }
            canvas.drawSprite(eggRows, x: eggX, y: eggY, map: colorMap, flip: false)

            let msgIdx = Int((elapsed - 1.35) * 5) % TimeDuckView.splashMessages.count
            let msg = TimeDuckView.splashMessages[msgIdx]
            let msgW = PixelCanvas.smallWidth(msg)
            let msgX = max(4, (gridW - msgW) / 2)
            canvas.smallText(msg, x: msgX, y: eggY + 16, c: Pal.green)

            let pBarW = min(80, gridW - 40)
            let pBarX = (gridW - pBarW) / 2
            let pBarY = eggY + 25
            let frac = min(1.0, (elapsed - 0.45) / 1.9)
            let litW = Int(Double(pBarW) * frac)
            for i in 0..<litW {
                let h = Double(i) / Double(pBarW)
                canvas.fillRect(pBarX + i, pBarY, 1, 2, rainbow(h))
            }
            if litW < pBarW {
                canvas.hline(pBarX + litW, pBarX + pBarW - 1, pBarY, Pal.grid)
                canvas.hline(pBarX + litW, pBarX + pBarW - 1, pBarY + 1, Pal.grid)
            }

            let hint = "PRESS ANY KEY TO SKIP"
            let hintW = PixelCanvas.smallWidth(hint)
            canvas.smallText(hint, x: (gridW - hintW) / 2, y: gridH - 12, c: Pal.inkDim)
        } else {
            // Phase 3: Ready! Transition
            if !splashReadyChimed {
                snd?.splashBootChime()
                splashReadyChimed = true
            }

            let duckX = (gridW - 13) / 2
            let duckY = mini ? 6 : 28
            canvas.drawSprite(DUCK_YAY_A, x: duckX, y: duckY, map: getDuckColorMap(), flip: false)

            let readyStr = "READY TO QUACK!"
            let readyW = PixelCanvas.smallWidth(readyStr)
            let readyX = (gridW - readyW) / 2
            canvas.smallText(readyStr, x: readyX, y: duckY + 16, c: Pal.green)

            let hint = "PRESS ANY KEY"
            let hintW = PixelCanvas.smallWidth(hint)
            canvas.smallText(hint, x: (gridW - hintW) / 2, y: gridH - 12, c: Pal.white)
        }
    }

    func makeImage() -> CGImage? {
        guard let ctx = ctx else { return nil }
        return ctx.makeImage()
    }

    // MARK: - Duck Brain & Physics

    private func updateDuckBrain(_ dt: Double, now: Date) {
        let dx = duckTargetX - duckCurX
        if abs(dx) > 1.0 {
            let speed = brain.isChonky ? 16.0 : 28.0 // Heavy waddle during chonky mode!
            duckCurX += (dx > 0 ? 1 : -1) * min(abs(dx), speed * dt)
            duckFlip = dx < 0
            stridePhase += dt * (brain.isChonky ? 5.0 : 9.0)
        } else {
            // Check if arrived at a breadcrumb (explicit beak alignment hit detection)
            let beakX = duckCurX + (duckFlip ? 1.0 : 11.0)
            if let idx = crumbs.firstIndex(where: { abs($0.x - beakX) < 4.0 || abs($0.x - (duckCurX + 6)) < 6.0 }) {
                peckUntil = now.addingTimeInterval(1.0)
                crumbs.remove(at: idx)
                snd?.crumbCrunch()
                let res = brain.onCrumbEaten()
                if res.triggeredChonky {
                    snd?.duckBurp()
                    spawnSteamPuff()
                    toast("MAXIMUM CHONK!")
                } else {
                    spawnCrumbParticles()
                }
                speak(res.phrase, duration: 2.4)
                AchievementEngine.shared.evaluateEvent(
                    .breadcrumbFed(totalFedToday: crumbs.count, triggeredChonky: res.triggeredChonky),
                    stats: stats,
                    now: now
                )
            }
        }
        duckX = Int(duckCurX)

        // Age breadcrumbs
        for i in crumbs.indices.reversed() {
            crumbs[i].life -= dt
            if crumbs[i].life <= 0 { crumbs.remove(at: i) }
        }

        // Coordinate DuckBrain behavioral updates
        let isRunning = isAnyRunning
        let remainingSec: Double
        let remFrac: Double
        switch currentMode {
        case .pomodoro:
            remainingSec = pomo.isRunning ? pomo.remaining : pomo.remainingAtStop
            remFrac = pomo.currentDuration > 0 ? remainingSec / pomo.currentDuration : 0
        case .timer:
            remainingSec = tm.isRunning ? tm.remaining : tm.remainingAtStop
            remFrac = tm.duration > 0 ? remainingSec / tm.duration : 0
        case .stopwatch:
            remainingSec = 0
            remFrac = 0
        }
        let inactivity = now.timeIntervalSince(lastUserActivity)

        brain.update(
            dt: dt,
            now: now,
            mode: currentMode,
            isRunning: isRunning,
            isFinished: isFinished,
            remainingFraction: remFrac,
            remainingSeconds: remainingSec,
            elapsedSeconds: sw.elapsed,
            userInactivitySeconds: inactivity,
            duckCurX: duckCurX,
            gridW: gridW,
            onWanderTarget: { [weak self] targetX in
                guard let self = self else { return }
                self.duckTargetX = targetX
            },
            onSpeak: { [weak self] text, dur in
                self?.speak(text, duration: dur)
            }
        )

        // Story Engine Progress & Lifecycle
        if isPreviewingStory, let currP = previewProgress, storySpeedMultiplier > 0 {
            let advanceRate = dt * (storySpeedMultiplier / 120.0)
            previewProgress = min(1.0, currP + advanceRate)
        }

        let ctx = getStoryContext()
        storyEngine.updateProgress(context: ctx, now: now)
        storyEngine.tick(dt: dt, now: now, context: ctx)
    }

    // MARK: - Alarm & Event Handling

    /// Processes timer completions independently of rendering so hidden windows still alert and record stats.
    /// Services ALL engines (timer/pomodoro) regardless of currentMode so inactive-mode and hidden-window
    /// completions are always handled (stats recorded, fanfare played, duplicate prevented).
    @discardableResult
    func processTimeEvents(_ now: Date = Date()) -> Bool {
        var didRecordCompletion = false
        var shouldPlayCompletionAlarm = false

        // Timer completion (always, even if not current mode)
        if tm.isFinished(at: now) && !tm.completionRecorded {
            tm.markCompletionRecorded()
            stats.addFocusSeconds(tm.duration, now: now)
            shouldPlayCompletionAlarm = true
            timerAlarmDismissed = false
            if currentMode == .timer {
                spawnConfetti(75)
                flapUntil = now.addingTimeInterval(1.2)
                confettiPulse = now
                let quip = brain.onTimerComplete(mode: .timer, isWorkPomodoro: false, hat: currentHat)
                speak(quip)
            }
            didRecordCompletion = true
            AchievementEngine.shared.evaluateEvent(
                .timerCompleted(mode: .timer, duration: tm.duration, isWorkPomodoro: false, isMiniHUD: mini),
                stats: stats,
                now: now
            )
        }

        // Pomodoro completion (always, even if not current mode)
        if pomo.isFinished(at: now) && !pomo.completionRecorded {
            if pomo.phase == .work {
                stats.recordPomodoroCompleted(duration: pomo.workDuration, now: now)
            }
            pomo.markCompletionRecorded()
            shouldPlayCompletionAlarm = true
            pomodoroAlarmDismissed = false
            if currentMode == .pomodoro {
                spawnConfetti(75)
                flapUntil = now.addingTimeInterval(1.2)
                confettiPulse = now
                let quip = brain.onTimerComplete(mode: .pomodoro, isWorkPomodoro: pomo.phase == .work, hat: currentHat)
                speak(quip)
            }
            didRecordCompletion = true
            AchievementEngine.shared.evaluateEvent(
                .timerCompleted(mode: .pomodoro, duration: pomo.workDuration, isWorkPomodoro: pomo.phase == .work, isMiniHUD: mini),
                stats: stats,
                now: now
            )
        }

        if shouldPlayCompletionAlarm {
            clearSleepFX()
            if let onCompletionAlarm = onCompletionAlarm {
                onCompletionAlarm()
            } else {
                snd?.victoryFanfare()
            }
        }

        // Urgency ticks and lastWholeSec only for the visible current mode
        let isRunning = (currentMode == .pomodoro && pomo.isRunning) || (currentMode == .timer && tm.isRunning)
        let r = currentMode == .pomodoro ? pomo.remaining : tm.remaining
        if isRunning {
            let s = Int(r.rounded(.up))
            if r <= 10.05 && s != lastWholeSec && r > 0 {
                lastWholeSec = s
                snd?.tick(urgency: max(0, min(1, (10 - r) / 10)))
            }
        } else {
            lastWholeSec = -1
        }
        return didRecordCompletion
    }

    // MARK: - Mini Mode (Compact Mode)

    // MARK: - Mini Mode (Compact Mode)

    func compactLayoutMetrics() -> CompactLayoutMetrics {
        var goLabel = "START"
        var secLabel = "ACTION"

        switch currentMode {
        case .pomodoro:
            goLabel = pomo.isRunning ? "PAUSE" : "START"
            secLabel = "SKIP"
        case .timer:
            goLabel = tm.isRunning ? "PAUSE" : (tm.remainingAtStop < tm.duration ? "RESUME" : "START")
            secLabel = "+1M"
        case .stopwatch:
            goLabel = sw.isRunning ? "PAUSE" : (sw.elapsed > 0 ? "RESUME" : "START")
            secLabel = sw.isRunning ? "LAP" : (sw.elapsed > 0 ? "RESET" : "LAP")
        }

        if isFinished && !alarmDismissed {
            goLabel = "DONE"
        }

        let modeTag: String
        switch currentMode {
        case .pomodoro:
            modeTag = pomo.isRunning ? (pomo.phase == .work ? "FOCUS" : "BREAK") : "POMO"
        case .timer:
            modeTag = "TIMER"
        case .stopwatch:
            modeTag = "SW"
        }

        return CompactLayoutMetrics(
            gridW: gridW,
            gridH: gridH,
            modeTag: modeTag,
            goLabel: goLabel,
            secLabel: secLabel
        )
    }

    private func drawCompactTime(
        _ str: String,
        x timeX: Int,
        y timeY: Int,
        maxWidth: Int,
        color: Color,
        alpha: UInt8 = 255
    ) {
        let style = CompactLayoutMetrics.resolveTimeRenderStyle(for: str, maxWidth: maxWidth)
        switch style {
        case .heroLarge(let mainPart, let fracPart, let mainW, _, _):
            canvas.heroText(mainPart, x: timeX, y: timeY, c: color, scale: 2, a: alpha)
            if !fracPart.isEmpty {
                canvas.heroText(fracPart, x: timeX + mainW + 2, y: timeY, c: color, scale: 2, a: alpha)
            }
        case .heroWithSmallFrac(let mainPart, let fracPart, let mainW, _, _):
            canvas.heroText(mainPart, x: timeX, y: timeY, c: color, scale: 2, a: alpha)
            if !fracPart.isEmpty {
                canvas.smallText(fracPart, x: timeX + mainW + 2, y: timeY + 9, c: color, scale: 1, a: alpha)
            }
        case .smallScale2(let mainPart, let fracPart, let mainW, _, _):
            canvas.smallText(mainPart, x: timeX, y: timeY + 2, c: color, scale: 2, a: alpha)
            if !fracPart.isEmpty {
                canvas.smallText(fracPart, x: timeX + mainW + 2, y: timeY + 7, c: color, scale: 1, a: alpha)
            }
        case .heroScale1(let mainPart, let fracPart, let mainW, _, _):
            canvas.heroText(mainPart, x: timeX, y: timeY + 4, c: color, scale: 1, a: alpha)
            if !fracPart.isEmpty {
                canvas.heroText(fracPart, x: timeX + mainW + 1, y: timeY + 4, c: color, scale: 1, a: alpha)
            }
        case .smallScale1(let fullText, _):
            canvas.smallText(fullText, x: timeX, y: timeY + 5, c: color, scale: 1, a: alpha)
        }
    }

    private func renderMini(_ t: Double, _ now: Date) {
        let bc = stateBorderColor(now)
        canvas.frameRect(0, 0, gridW, gridH, Pal.grid)
        canvas.frameRect(1, 1, gridW - 2, gridH - 2, bc)

        let m = compactLayoutMetrics()
        let running = isAnyRunning

        let str: String
        switch currentMode {
        case .pomodoro:
            str = Fmt.tm(pomo.isRunning || pomo.remainingAtStop < pomo.currentDuration ? pomo.remaining : pomo.currentDuration, drama: pomo.isRunning && pomo.remaining < 10)
        case .timer:
            str = Fmt.tm(tm.isRunning || tm.remainingAtStop < tm.duration ? tm.remaining : tm.duration, drama: tm.isRunning && tm.remaining < 10)
        case .stopwatch:
            str = Fmt.sw(sw.elapsed)
        }

        // Top-Left: Mode & State Badge
        let modeHovered = hoverId == "tab-cycle"
        let isPaused = !running && (
            (currentMode == .pomodoro && pomo.remainingAtStop < pomo.currentDuration) ||
            (currentMode == .timer && tm.remainingAtStop < tm.duration) ||
            (currentMode == .stopwatch && sw.elapsed > 0)
        )
        let pillBorderCol: Color
        let pillTextCol: Color
        if isFinished && !alarmDismissed {
            let blink = Int(t * 3) % 2 == 0
            pillBorderCol = blink ? Pal.white : Pal.red
            pillTextCol = blink ? Pal.white : Pal.red
        } else if isPaused {
            pillBorderCol = modeHovered ? Pal.white : Pal.amber
            pillTextCol = modeHovered ? Pal.white : Pal.amber
        } else if running {
            let col = (currentMode == .pomodoro && pomo.phase != .work) ? Pal.cyan : Pal.green
            pillBorderCol = modeHovered ? Pal.white : col
            pillTextCol = modeHovered ? Pal.white : col
        } else {
            pillBorderCol = modeHovered ? Pal.white : Pal.inkDim
            pillTextCol = modeHovered ? Pal.white : Pal.ink
        }

        canvas.fillRect(m.modePillRect.x, m.modePillRect.y, m.modePillRect.w, m.modePillRect.h, Pal.panelHi)
        canvas.frameRect(m.modePillRect.x, m.modePillRect.y, m.modePillRect.w, m.modePillRect.h, pillBorderCol)
        canvas.smallText(m.modeTag, x: m.modePillRect.x + 3, y: m.modePillRect.y + 1, c: pillTextCol)

        // Top-Right: Sound toggle & Expand / Exit Compact button
        drawTitleToggle("toggle-sound", x: m.soundRect.x, on: snd?.enabled ?? true, glyph: .speaker)
        drawTitleToggle("unmini", x: m.unminiRect.x, on: false, glyph: .expand)

        // Center-Left: Primary Time Digits in Protected Region
        let textCol: Color
        if isFinished && !alarmDismissed {
            textCol = Int(t * 4) % 2 == 0 ? Pal.white : Pal.red
        } else if running {
            textCol = Pal.green.withPulse(t, amp: 0.08)
        } else {
            textCol = Pal.ink
        }

        if isEditingTime {
            let cursor = (Int(t * 4) % 2 == 0) ? "_" : " "
            let disp = editBuffer.isEmpty ? ("01:00" + cursor) : (editBuffer + cursor)
            drawCompactTime(disp, x: m.timeAreaRect.x, y: m.timeAreaRect.y, maxWidth: m.maxTimeWidth, color: Pal.amber)
        } else {
            // Phosphor Ghosting
            if str != ghostPrev {
                ghostPrev = str
                ghostUntil = now.addingTimeInterval(0.10)
            }
            if now < ghostUntil {
                drawCompactTime(str, x: m.timeAreaRect.x, y: m.timeAreaRect.y, maxWidth: m.maxTimeWidth, color: textCol, alpha: 40)
            }
            drawCompactTime(str, x: m.timeAreaRect.x, y: m.timeAreaRect.y, maxWidth: m.maxTimeWidth, color: textCol)
        }

        // Center-Right: Action buttons (GO, SEC) - Clear but Quiet with Hover Emphasis
        var goLabel = "START"
        var goStyle: BtnStyle = .primary
        var secLabel = "ACTION"
        var secStyle: BtnStyle = .normal

        switch currentMode {
        case .pomodoro:
            goLabel = pomo.isRunning ? "PAUSE" : "START"
            goStyle = pomo.isRunning ? .danger : .primary
            secLabel = "SKIP"
            secStyle = .accent
        case .timer:
            goLabel = tm.isRunning ? "PAUSE" : (tm.remainingAtStop < tm.duration ? "RESUME" : "START")
            goStyle = tm.isRunning ? .danger : .primary
            secLabel = "+1M"
            secStyle = .normal
        case .stopwatch:
            goLabel = sw.isRunning ? "PAUSE" : (sw.elapsed > 0 ? "RESUME" : "START")
            goStyle = sw.isRunning ? .danger : .primary
            secLabel = sw.isRunning ? "LAP" : (sw.elapsed > 0 ? "RESET" : "LAP")
            secStyle = sw.isRunning ? .accent : .normal
        }

        if isFinished && !alarmDismissed {
            goLabel = "DONE"
            goStyle = .alarm
        }

        drawButton(id: "go", label: goLabel, x: m.goRect.x, y: m.goRect.y, w: m.goRect.w, h: m.goRect.h, style: goStyle)
        drawButton(id: "sec", label: secLabel, x: m.secRect.x, y: m.secRect.y, w: m.secRect.w, h: m.secRect.h, style: secStyle)

        // Far-Right: Dedicated Mini Stage
        drawMiniStage(m, t: t, now: now, running: running)

        // Bottom Progress Bar
        drawMiniProgressBar(t, x: m.progressBarRect.x, y: m.progressBarRect.y, w: m.progressBarRect.w)
    }

    private func drawMiniStage(
        _ m: CompactLayoutMetrics,
        t: Double,
        now: Date,
        running: Bool
    ) {
        // 1. Far-Right: Dedicated Mini Stage Box (Protected Column)
        canvas.vline(m.duckX - 1, 2, gridH - 3, Pal.grid)
        canvas.fillRect(m.duckX, m.duckY, m.duckW, m.duckH, Pal.bgDeep)

        let duckHovered = hoverId == "pet-duck" || hoverId == "duck"
        if duckHovered {
            canvas.frameRect(m.duckX, m.duckY, m.duckW, m.duckH, Pal.panelHi)
        }

        let dx = m.duckSpriteX
        let dy = m.duckSpriteY
        var duckRows = miniDuckRows(t, running: running, now: now)
        var duckFlip = false
        var duckDrawX = dx
        var duckDrawY = dy

        // 2. Duck Stories in Mini Stage
        if storyEngine.selectedStoryId != .off, let activeStory = storyEngine.activeStory {
            let storyId = storyEngine.selectedStoryId
            let sceneIdx = activeStory.activeSceneIndex
            let sceneTime = activeStory.sceneElapsedTime

            if storyEngine.isFinaleActive {
                let finaleTime = storyEngine.finaleElapsedTime
                switch storyId {
                case .theFeast:
                    if let feast = activeStory as? TheFeastStory, feast.isDigesting {
                        duckRows = feast.getSpriteOverride() ?? DUCK_BASE
                    } else {
                        let t = finaleTime.truncatingRemainder(dividingBy: 10.0)
                        duckRows = (t < 5.0) ? DUCK_BASE : DUCK_IDLE_WAG
                    }
                case .theExpedition:
                    let flagFrames = [PROP_MINI_SUMMIT_FLAG_A, PROP_MINI_SUMMIT_FLAG_B]
                    let flagFrame = flagFrames[Int(finaleTime * 3) % 2]
                    let flagX = m.duckX + 1
                    let flagY = max(m.duckY + 1, dy + 1)
                    canvas.drawSprite(flagFrame, x: flagX, y: flagY, map: ["k": Pal.inkDim, "r": Pal.red, "s": Pal.grid], flip: false)
                    duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                    let t = finaleTime.truncatingRemainder(dividingBy: 12.0)
                    duckRows = (t < 6.0) ? DUCK_PROUD : DUCK_BASE
                case .nightShift:
                    duckRows = DUCK_SLEEP_DEEP
                case .theWod:
                    let t = finaleTime.truncatingRemainder(dividingBy: 10.0)
                    duckRows = (t < 5.0) ? DUCK_WOD_FLEX : DUCK_PROUD
                case .theRescue:
                    let girlX = m.duckX + 1
                    let girlY = dy + 1
                    canvas.drawSprite(ACTOR_MINI_GIRL_DUCK_A, x: girlX, y: girlY, map: ["m": Pal.magenta, "y": Pal.duckBody, "k": Pal.duckEye, "w": Pal.white, "o": Pal.amber, "d": Pal.duckShad], flip: false)
                    duckDrawX = min(m.duckX + m.duckW - 13, dx + 3)
                    duckRows = DUCK_PROUD
                    duckFlip = true
                default: break
                }
            } else {
                switch storyId {
                case .theFeast:
                    // The Feast in Mini Stage
                    if let feast = activeStory as? TheFeastStory {
                        let stage = feast.fullnessStage
                        let feeding = (Int(sceneTime * 2) % 4) < 2
                        if feeding && stage < 5 {
                            let crumbX = max(m.duckX + 1, min(m.duckX + m.duckW - 4, dx - 2))
                            let crumbY = dy + 7
                            canvas.fillRect(crumbX, crumbY, 2, 2, Pal.amber)
                            canvas.set(crumbX + 1, crumbY + 1, Pal.white)
                            duckRows = (Int(sceneTime * 4) % 2 == 0) ? DUCK_PECK_B : DUCK_SWALLOW
                            duckFlip = true
                        } else {
                            switch stage {
                            case 0: duckRows = running ? DUCK_RUN_A : DUCK_BASE
                            case 1: duckRows = DUCK_CHONK_STAGE1
                            case 2: duckRows = DUCK_CHONK_STAGE2
                            case 3: duckRows = DUCK_CHONK_STAGE3
                            case 4: duckRows = DUCK_CHONK_STAGE4
                            case 5: duckRows = (Int(sceneTime * 3) % 2 == 0) ? DUCK_CHONK_STAGE5 : DUCK_BELLY_WOBBLE
                            default: duckRows = DUCK_CHONK_STAGE5
                            }
                        }
                    }

                case .theExpedition:
                    // The Expedition in Mini Stage
                    switch sceneIdx {
                    case 0: // Scene 1: Micro trail sign + map
                        let signX = m.duckX + 1
                        let signY = max(m.duckY + 1, dy + 2)
                        canvas.drawSprite(PROP_MINI_TRAIL_SIGN, x: signX, y: signY, map: ["a": Pal.amber, "k": Pal.inkDim, "s": Pal.grid], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = (Int(sceneTime * 2) % 4 < 2) ? DUCK_INVESTIGATE_A : DUCK_MAP_CHECK_A
                        duckFlip = true
                    case 1: // Scene 2: Micro animated campfire
                        let fireFrames = [PROP_MINI_CAMPFIRE_A, PROP_MINI_CAMPFIRE_B]
                        let fireFrame = fireFrames[Int(sceneTime * 4) % 2]
                        let fireX = m.duckX + 1
                        let fireY = max(m.duckY + 2, dy + 4)
                        canvas.drawSprite(fireFrame, x: fireX, y: fireY, map: ["r": Pal.red, "o": Pal.amber, "a": Pal.amber, "w": Pal.white], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = DUCK_WARM_WINGS
                        duckFlip = true
                    case 2: // Scene 3: Micro rock hop
                        let rockX = m.duckX + 1
                        let rockY = max(m.duckY + 2, dy + 5)
                        canvas.drawSprite(PROP_MINI_ROCK, x: rockX, y: rockY, map: ["s": Pal.grid], flip: false)
                        duckRows = (Int(sceneTime * 3) % 2 == 0) ? DUCK_EXPEDITION_WADDLE_A : DUCK_INVESTIGATE_B
                    case 3: // Scene 4: Wind lean
                        duckRows = (Int(sceneTime * 3) % 2 == 0) ? DUCK_WIND_LEAN_A : DUCK_WIND_LEAN_B
                        duckFlip = true
                    case 4: // Scene 5: Micro animated summit flag
                        let flagFrames = [PROP_MINI_SUMMIT_FLAG_A, PROP_MINI_SUMMIT_FLAG_B]
                        let flagFrame = flagFrames[Int(sceneTime * 3) % 2]
                        let flagX = m.duckX + 1
                        let flagY = max(m.duckY + 1, dy + 1)
                        canvas.drawSprite(flagFrame, x: flagX, y: flagY, map: ["k": Pal.inkDim, "r": Pal.red, "s": Pal.grid], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = DUCK_SUMMIT_CHEER
                    default: break
                    }

                case .nightShift:
                    // Night Shift in Mini Stage
                    switch sceneIdx {
                    case 0: // Scene 1: Micro steaming coffee
                        let coffeeFrames = [PROP_MINI_COFFEE_A, PROP_MINI_COFFEE_B]
                        let coffeeFrame = coffeeFrames[Int(sceneTime * 3) % 2]
                        let coffeeX = m.duckX + 1
                        let coffeeY = max(m.duckY + 2, dy + 4)
                        canvas.drawSprite(coffeeFrame, x: coffeeX, y: coffeeY, map: ["s": Pal.sweat, "w": Pal.white, "a": Pal.amber], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = DUCK_SWALLOW
                        duckFlip = true
                    case 1: // Scene 2: Big yawn
                        duckRows = (Int(sceneTime * 2) % 4 < 2) ? DUCK_YAWN : DUCK_FEATHER_RUFFLE_A
                    case 2: // Scene 3: Droop sleep & splash
                        duckRows = (Int(sceneTime * 2) % 4 < 2) ? DUCK_NIGHT_DROOP : DUCK_NIGHT_FACE_SPLASH
                    case 3: // Scene 4: Blanket micro-nap
                        duckRows = (Int(sceneTime * 2) % 4 < 2) ? DUCK_NIGHT_DROOP : DUCK_NIGHT_BLANKET_THROW
                    case 4: // Scene 5: Morning victory
                        duckRows = DUCK_EXPEDITION_WADDLE_A
                    default: break
                    }

                case .theWod:
                    // The WOD in Mini Stage
                    switch sceneIdx {
                    case 0: // Scene 1: Warmup jacks
                        duckRows = (Int(sceneTime * 4) % 2 == 0) ? DUCK_WOD_WARMUP_A : DUCK_WOD_WARMUP_B
                    case 1: // Scene 2: Micro Elliptical (Physically mounted and pedaling!)
                        let ellipFrames = [PROP_MINI_ELLIPTICAL_A, PROP_MINI_ELLIPTICAL_B]
                        let ellipFrame = ellipFrames[Int(sceneTime * 4) % 2]
                        let ellipX = m.duckX + 1
                        let ellipY = max(m.duckY + 1, dy + 1)
                        canvas.drawSprite(ellipFrame, x: ellipX, y: ellipY, map: ["s": Pal.cyan, "k": Pal.inkDim], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 1)
                        duckDrawY = dy - 1
                        duckRows = (Int(sceneTime * 4) % 2 == 0) ? DUCK_ELLIPTICAL_A : DUCK_ELLIPTICAL_B
                    case 2: // Scene 3: Micro Treadmill (Mounted on moving belt with sweat!)
                        let treadFrames = [PROP_MINI_TREADMILL_A, PROP_MINI_TREADMILL_B]
                        let treadFrame = treadFrames[Int(sceneTime * 5) % 2]
                        let treadX = m.duckX + 1
                        let treadY = max(m.duckY + 2, dy + 4)
                        canvas.drawSprite(treadFrame, x: treadX, y: treadY, map: ["s": Pal.grid, "k": Pal.inkDim], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 1)
                        duckRows = (Int(sceneTime * 5) % 2 == 0) ? DUCK_TREADMILL_A : DUCK_TREADMILL_B
                    case 3: // Scene 4: Micro Dumbbells
                        let dbX = m.duckX + 1
                        let dbY = max(m.duckY + 2, dy + 5)
                        canvas.drawSprite(PROP_MINI_DUMBBELLS, x: dbX, y: dbY, map: ["k": Pal.inkDim, "s": Pal.grid], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = (Int(sceneTime * 3) % 2 == 0) ? DUCK_DUMBBELL_A : DUCK_DUMBBELL_B
                    case 4: // Scene 5: Flex victory
                        duckRows = DUCK_WOD_FLEX
                    default: break
                    }

                case .theRescue:
                    // The Rescue in Mini Stage
                    switch sceneIdx {
                    case 0: // Scene 1: Micro metal crate sneak
                        let crateX = m.duckX + 1
                        let crateY = max(m.duckY + 2, dy + 3)
                        canvas.drawSprite(PROP_MINI_METAL_CRATE, x: crateX, y: crateY, map: ["s": Pal.grid, "a": Pal.amber], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 2)
                        duckRows = (Int(sceneTime * 3) % 2 == 0) ? DUCK_STEALTH_CROUCH : DUCK_STEALTH_TIPTOE_A
                    case 1: // Scene 2: Micro camera sweep & box disguise
                        let camFrames = [PROP_MINI_SECURITY_CAMERA_L, PROP_MINI_SECURITY_CAMERA_R]
                        let camFrame = camFrames[Int(sceneTime * 2) % 2]
                        let camX = min(m.duckX + m.duckW - 6, dx + 8)
                        let camY = m.duckY + 1
                        canvas.drawSprite(camFrame, x: camX, y: camY, map: ["s": Pal.grid, "r": Pal.red, "k": Pal.inkDim], flip: false)
                        duckRows = (Int(sceneTime * 2) % 4 < 2) ? DUCK_STEALTH_BOX_DISGUISE : DUCK_STEALTH_CROUCH
                    case 2: // Scene 3: Micro Guard Duck Patrol
                        let guardFrames = [ACTOR_MINI_GUARD_DUCK_A, ACTOR_MINI_GUARD_DUCK_B]
                        let guardFrame = guardFrames[Int(sceneTime * 3) % 2]
                        let guardX = m.duckX + 1
                        let guardY = dy + 1
                        canvas.drawSprite(guardFrame, x: guardX, y: guardY, map: ["k": Pal.inkDim, "d": Pal.ink, "o": Pal.amber, "s": Pal.grid], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 3)
                        duckRows = DUCK_STEALTH_CROUCH
                        duckFlip = true
                    case 3: // Scene 4: Micro Girl Duck Actor
                        let girlFrames = [ACTOR_MINI_GIRL_DUCK_A, ACTOR_MINI_GIRL_DUCK_B]
                        let girlFrame = girlFrames[Int(sceneTime * 3) % 2]
                        let girlX = m.duckX + 1
                        let girlY = dy + 1
                        canvas.drawSprite(girlFrame, x: girlX, y: girlY, map: ["m": Pal.magenta, "y": Pal.duckBody, "k": Pal.duckEye, "w": Pal.white, "o": Pal.amber, "d": Pal.duckShad], flip: false)
                        duckDrawX = min(m.duckX + m.duckW - 13, dx + 3)
                        duckRows = DUCK_YAY_A
                        duckFlip = true
                    case 4: // Scene 5: Escape
                        duckRows = (Int(sceneTime * 4) % 2 == 0) ? DUCK_RUN_A : DUCK_RUN_B
                    default: break
                    }
                case .auto, .off: break
                }
            }
        }

        let isSleeping = (now.timeIntervalSince(lastUserActivity) > 35 && !running && !(isFinished && !alarmDismissed)) || brain.currentPhase == .sleepy || (storyEngine.selectedStoryId == .nightShift && storyEngine.isFinaleActive)
        if isSleeping {
            spawnSnoreParticle(rows: duckRows, duckX: duckDrawX, duckY: duckDrawY, flip: duckFlip, isMini: true, now: now)
        } else if !snoreParticles.isEmpty {
            clearSleepFX()
        }

        // 3. Draw TimeDuck Sprite in Mini Stage
        canvas.drawSprite(
            duckRows,
            x: duckDrawX,
            y: duckDrawY,
            map: TimeCompanionRegistry.shared.activeCompanion.resolveColorMap(rareEvent: brain.activeRareEvent),
            flip: duckFlip
        )

        // 4. Draw Living Wardrobe Hat in Mini Stage (clamped to Mini Stage bounds)
        drawDuckHat(
            currentHat,
            duckX: duckDrawX,
            duckY: duckDrawY,
            duckRows: duckRows,
            t: t,
            isRunning: running,
            isCelebrating: isFinished && !alarmDismissed,
            flip: duckFlip
        )

        // 5. Draw Micro Breadcrumbs in Mini Stage
        for c in crumbs {
            let bx = Int(c.x), by = Int(c.y)
            if bx >= m.duckX && bx < m.duckX + m.duckW && by >= m.duckY && by < m.duckY + m.duckH {
                canvas.fillRect(bx, by, 2, 2, Pal.amber)
                canvas.set(bx + 1, by + 1, Pal.white)
            }
        }

        // 6. Draw Word-by-Word Dialogue in Mini Stage (Strictly within Mini Stage)
        if let text = speechText, !text.isEmpty && now < speechUntil && !speechWords.isEmpty {
            let totalDur = max(0.1, speechUntil.timeIntervalSince(speechBorn))
            let elapsed = max(0.0, now.timeIntervalSince(speechBorn))
            let wordDur = min(0.38, max(0.20, (totalDur * 0.72) / Double(speechWords.count)))
            let wordIdx = min(speechWords.count - 1, Int(elapsed / wordDur))
            let rawWord = speechWords[wordIdx]
            let maxWordW = max(8, m.duckW - 2)
            let word = PixelCanvas.fitSmallText(rawWord, maxWidth: maxWordW)
            if !word.isEmpty {
                let textW = PixelCanvas.smallWidth(word)
                let textX = m.duckX + max(1, (m.duckW - textW) / 2)
                let textY = max(m.duckY + 1, min(gridH - 7, dy - 6))
                canvas.fillRect(textX - 1, textY - 1, textW + 2, 7, Pal.bgDeep)
                canvas.frameRect(textX - 1, textY - 1, textW + 2, 7, Pal.inkDim)
                canvas.smallText(word, x: textX, y: textY, c: Pal.ink)
            }
        }

        // 7. Draw Micro Particles & Snore FX (Clipped to Mini Stage)
        for p in parts {
            let px = Int(p.x), py = Int(p.y)
            if px >= m.duckX && px < m.duckX + m.duckW && py >= m.duckY && py < m.duckY + m.duckH {
                canvas.set(px, py, p.c)
            }
        }
        drawSnoreParticles(m)
    }

    private func drawMiniProgressBar(_ t: Double, x: Int, y: Int, w: Int) {
        guard w > 0 else { return }
        let frac: Double
        switch currentMode {
        case .pomodoro:
            frac = pomo.currentDuration > 0 ? (pomo.isRunning ? pomo.remaining : pomo.remainingAtStop) / pomo.currentDuration : 0
        case .timer:
            frac = tm.duration > 0 ? (tm.isRunning ? tm.remaining : tm.remainingAtStop) / tm.duration : 0
        case .stopwatch:
            frac = sw.isRunning ? 1.0 : (sw.elapsed > 0 ? 0.5 : 0.0)
        }

        let litW = Int(Double(w) * max(0, min(1, frac)))
        for i in 0..<litW {
            let h = Double(i) / Double(w)
            canvas.fillRect(x + i, y, 1, 2, rainbow(h, vq: isAnyRunning ? 1.0 : 0.6))
        }
        if litW < w {
            canvas.hline(x + litW, x + w - 1, y, Pal.grid)
            canvas.hline(x + litW, x + w - 1, y + 1, Pal.grid)
        }
    }

    private func miniDuckRows(_ t: Double, running: Bool, now: Date) -> [String] {
        let isFlapping = isFinished && !alarmDismissed
        let isQuacking = now < hopUntil || now < quackUntil
        let isPetting = now < petUntil
        let isEating = crumbs.count > 0
        let isBreakRunning = (currentMode == .pomodoro && pomo.phase != .work && pomo.isRunning)
        let isSleeping = (now.timeIntervalSince(lastUserActivity) > 35 && !running && !(isFinished && !alarmDismissed)) || brain.currentPhase == .sleepy || (storyEngine.selectedStoryId == .nightShift && storyEngine.isFinaleActive)

        return brain.getSpriteRows(
            t: t,
            now: now,
            isFlapping: isFlapping,
            isQuacking: isQuacking,
            isPetting: isPetting,
            isEating: isEating,
            isBreakRunning: isBreakRunning,
            isRunning: running,
            isSleeping: isSleeping,
            stridePhase: t * 6.0,
            blinkUntil: blinkUntil
        )
    }

    // MARK: - Full Chrome

    var isAnyRunning: Bool {
        sw.isRunning || tm.isRunning || pomo.isRunning
    }

    private func drawStars(_ t: Double) {
        for s in stars {
            let a = UInt8(40 + 60 * pow(sin(t * s.speed + s.phase) * 0.5 + 0.5, 2))
            canvas.set(s.x, s.y, rainbow(s.hue, vq: 0.55), a: a)
        }
    }

    private func drawEmbers(_ dt: Double) {
        guard isAnyRunning else { return }
        emberBudget += dt * 4.5
        while emberBudget >= 1 {
            emberBudget -= 1
            var rng = SystemRandomNumberGenerator()
            appendParticle(Particle(
                x: Double(Int.random(in: 2..<max(3, gridW - 2), using: &rng)),
                y: Double(gridH - 2),
                vx: Double.random(in: -3...3),
                vy: Double.random(in: -16...(-7)),
                life: Double.random(in: 2.5...4.5),
                maxLife: 4.5,
                c: Int.random(in: 0...2) == 0 ? Pal.amber : Pal.green,
                grav: -2
            ))
        }
    }

    private func drawBreadcrumbs() {
        for c in crumbs {
            let bx = Int(c.x), by = Int(c.y)
            canvas.fillRect(bx, by, 2, 2, Pal.amber)
            canvas.set(bx + 1, by + 1, Pal.white)
        }
    }

    private func drawChrome(_ t: Double, _ now: Date) {
        // Outer bezel
        canvas.frameRect(0, 0, gridW, gridH, Pal.grid)
        canvas.frameRect(1, 1, gridW - 2, gridH - 2, Pal.panel)

        // Titlebar
        canvas.hline(1, gridW - 2, 9, Pal.grid)
        canvas.smallText("TIMEDUCK V\(AppVersion.version)", x: 4, y: 3, c: Pal.inkDim)

        // Titlebar toggles
        drawTitleToggle("tgl-duckbook", x: gridW - 68, on: DuckbookEngine.shared.isOpen, glyph: .book)
        drawTitleToggle("tgl-mini", x: gridW - 57, on: false, glyph: .expand)
        drawTitleToggle("tgl-hat", x: gridW - 46, on: currentHat != .none, glyph: .hat)
        drawTitleToggle("tgl-theme", x: gridW - 35, on: true, glyph: .palette)
        drawTitleToggle("tgl-pin", x: gridW - 24, on: pinOn, glyph: .pin)
        drawTitleToggle("toggle-sound", x: gridW - 13, on: snd?.enabled ?? true, glyph: .speaker)

        // Mode Tabs
        drawTab(id: "tab-pomo", label: "POMO", x: 4, selected: currentMode == .pomodoro)
        drawTab(id: "tab-tm", label: "TIMER", x: 38, selected: currentMode == .timer)
        drawTab(id: "tab-sw", label: "STOPWATCH", x: 65, selected: currentMode == .stopwatch)

        // Main controls row (y: 73)
        drawMainControls(t, now: now)

        // Mode Sub-panels (y: 87)
        switch currentMode {
        case .pomodoro:
            drawPomodoroSubpanel(t)
        case .timer:
            drawTimerSubpanel(t)
        case .stopwatch:
            drawLapsSubpanel(t)
        }
    }

    private func drawTab(id: String, label: String, x: Int, selected: Bool) {
        let w = PixelCanvas.smallWidth(label) + 6, y = 11, h = 8
        let hovered = hoverId == id
        if selected {
            canvas.fillRect(x, y, w, h, Pal.panelHi)
            canvas.frameRect(x, y, w, h, Pal.green)
            canvas.smallText(label, x: x + 3, y: y + 2, c: Pal.ink)
        } else {
            canvas.frameRect(x, y, w, h, hovered ? Pal.inkDim : Pal.grid)
            canvas.smallText(label, x: x + 3, y: y + 2, c: hovered ? Pal.ink : Pal.inkDim)
        }
    }

    private enum BtnStyle { case normal, primary, accent, danger, alarm }

    private func drawButton(id: String, label: String, x: Int, y: Int, w: Int, h: Int, style: BtnStyle) {
        let hovered = hoverId == id
        let pressedAt = pressMap[id] ?? .distantPast
        let pressed = Date().timeIntervalSince(pressedAt) < 0.13
        var frame = Pal.inkDim
        var txt = Pal.ink
        var fill: Color? = Pal.panel
        switch style {
        case .normal: break
        case .primary: frame = Pal.green; fill = Pal.greenDim; txt = Pal.green
        case .accent: frame = Pal.cyan; fill = Pal.panelHi; txt = Pal.cyan
        case .danger: frame = Pal.red; fill = Pal.redDim; txt = rgb(255, 170, 180)
        case .alarm:
            let blink = Int(Date().timeIntervalSinceReferenceDate * 3) % 2 == 0
            frame = blink ? Pal.white : Pal.red
            fill = blink ? Pal.redDim : Pal.panel
            txt = blink ? Pal.white : Pal.red
        }
        if hovered { txt = Pal.white }
        if let f = fill { canvas.fillRect(x + 1, y + 1, w - 2, h - 2, f) }
        canvas.frameRect(x, y, w, h, pressed ? Pal.white : frame)
        if pressed {
            canvas.hline(x + 1, x + w - 2, y + 1, Pal.bgDeep, a: 120)
        } else if hovered {
            canvas.hline(x + 2, x + w - 3, y + h - 2, frame, a: 90)
        }
        canvas.smallText(label, x: x + (w - PixelCanvas.smallWidth(label)) / 2, y: y + (h - 5) / 2 + 1, c: txt)
    }

    private func drawMainControls(_ t: Double, now: Date) {
        let btnW = 48, y = 73, h = 11

        var goLabel = "START"
        var secLabel = "ACTION"
        var resetLabel = "RESET"
        var goStyle: BtnStyle = .primary
        var secStyle: BtnStyle = .normal
        var resetStyle: BtnStyle = .normal

        switch currentMode {
        case .pomodoro:
            goLabel = pomo.isRunning ? "PAUSE" : "START"
            goStyle = pomo.isRunning ? .danger : .primary
            secLabel = "SKIP"
            secStyle = .accent
            resetLabel = pomo.finished && !alarmDismissed ? "DONE" : "RESET"
            resetStyle = pomo.finished && !alarmDismissed ? .alarm : .normal

        case .timer:
            goLabel = tm.isRunning ? "PAUSE" : (tm.remainingAtStop < tm.duration ? "RESUME" : "START")
            goStyle = tm.isRunning ? .danger : .primary
            secLabel = "+1 MIN"
            secStyle = .normal
            resetLabel = tm.finished && !alarmDismissed ? "DONE" : "CLEAR"
            resetStyle = tm.finished && !alarmDismissed ? .alarm : .normal

        case .stopwatch:
            goLabel = sw.isRunning ? "PAUSE" : (sw.elapsed > 0 ? "RESUME" : "START")
            goStyle = sw.isRunning ? .danger : .primary
            secLabel = "LAP"
            secStyle = sw.isRunning ? .accent : .normal
            resetLabel = "RESET"
            resetStyle = .normal
        }

        drawButton(id: "go", label: goLabel, x: 6, y: y, w: btnW, h: h, style: goStyle)
        drawButton(id: "sec", label: secLabel, x: 58, y: y, w: btnW, h: h, style: secStyle)
        drawButton(id: "reset", label: resetLabel, x: 110, y: y, w: btnW, h: h, style: resetStyle)
    }

    private func drawPomodoroSubpanel(_ t: Double) {
        canvas.hline(4, gridW - 5, 85, Pal.grid)
        // Cycle egg dots
        let cycle = pomo.cyclesCompleted % 4
        for i in 0..<4 {
            let ex = 6 + i * 7, ey = 89
            let filled = i < cycle || (pomo.cyclesCompleted > 0 && cycle == 0)
            if filled {
                canvas.fillRect(ex, ey, 4, 5, Pal.green)
            } else {
                canvas.frameRect(ex, ey, 4, 5, Pal.inkDim)
            }
        }
        canvas.smallText("C\(pomo.cyclesCompleted + 1)", x: 36, y: 89, c: Pal.inkDim)
        canvas.smallText("S:\(stats.streakDays)D", x: 54, y: 89, c: Pal.amber)
        drawButton(id: "pomo-25", label: "25M", x: 80, y: 87, w: 18, h: 9, style: .normal)
        drawButton(id: "pomo-p1", label: "+1M", x: 100, y: 87, w: 18, h: 9, style: .normal)
        drawButton(id: "pomo-p5", label: "+5M", x: 120, y: 87, w: 18, h: 9, style: .normal)
        drawButton(id: "feed-crumb", label: "FEED", x: 140, y: 87, w: 20, h: 9, style: .normal)
    }

    private func drawTimerSubpanel(_ t: Double) {
        canvas.hline(4, gridW - 5, 85, Pal.grid)
        let presets = [("preset-1M", "1M"), ("preset-5M", "5M"), ("preset-15M", "15M"), ("preset-25M", "25M")]
        for (i, p) in presets.enumerated() {
            drawButton(id: p.0, label: p.1, x: 6 + i * 20, y: 87, w: 18, h: 9, style: .normal)
        }
        drawButton(id: "tm-m1", label: "-1M", x: 92, y: 87, w: 18, h: 9, style: .normal)
        drawButton(id: "tm-p1", label: "+1M", x: 113, y: 87, w: 18, h: 9, style: .normal)
        drawButton(id: "tm-p5", label: "+5M", x: 134, y: 87, w: 24, h: 9, style: .normal)
    }

    private func drawLapsSubpanel(_ t: Double) {
        canvas.hline(4, gridW - 5, 85, Pal.grid)
        guard !sw.laps.isEmpty else {
            let hint = sw.isRunning ? "PRESS L FOR LAP · C COPIES" : "LAPS LAND HERE · C COPIES"
            let fit = PixelCanvas.fitSmallText(hint, maxWidth: gridW - 12)
            canvas.smallText(fit, x: (gridW - PixelCanvas.smallWidth(fit)) / 2, y: 89, c: Pal.inkFaint)
            return
        }
        let show = Array(sw.laps.suffix(4))
        let best = sw.laps.map(\.split).min() ?? 0
        let worst = sw.laps.map(\.split).max() ?? 0

        for (i, l) in show.reversed().enumerated() {
            let lx = 6 + (i % 2) * 78
            let ly = 87 + (i / 2) * 6
            canvas.fillRect(lx, ly + 1, 3, 3, rainbow(l.hue, vq: 0.9))
            canvas.smallText(String(format: "%02d", l.index), x: lx + 5, y: ly, c: Pal.inkDim)
            let col = sw.laps.count >= 3 ? (l.split == best ? Pal.green : (l.split == worst ? Pal.red : Pal.ink)) : Pal.ink
            canvas.smallText(Fmt.lapSplit(l.split), x: lx + 13, y: ly, c: col)
        }
    }

    // MARK: - Clock Area

    private func drawClockArea(_ t: Double, _ now: Date) {
        if isEditingTime {
            let cursor = (Int(t * 4) % 2 == 0) ? "_" : " "
            let disp = editBuffer.isEmpty ? ("01:00" + cursor) : (editBuffer + cursor)
            let mw = PixelCanvas.heroWidth(disp, scale: 2)
            let x0 = max(8, (gridW - mw) / 2)
            let clockY = 22

            canvas.heroText(disp, x: x0, y: clockY, c: Pal.amber, scale: 2)
            let hint = "TYPE TIME · ENTER: SET · ESC: CANCEL"
            canvas.smallText(hint, x: (gridW - PixelCanvas.smallWidth(hint)) / 2, y: 39, c: Pal.amber)
            drawProgressBar(t)
            return
        }

        var str: String
        var color: Color = Pal.ink

        switch currentMode {
        case .pomodoro:
            str = Fmt.tm(
                pomo.isRunning || pomo.remainingAtStop < pomo.currentDuration ? pomo.remaining : pomo.currentDuration,
                drama: pomo.isRunning && pomo.remaining < 10
            )
            if pomo.finished && !alarmDismissed {
                color = Int(t * 4) % 2 == 0 ? Pal.white : Pal.red
            } else if pomo.isRunning {
                color = pomo.phase == .work ? Pal.green.withPulse(t, amp: 0.08) : Pal.cyan.withPulse(t, amp: 0.08)
            } else {
                color = Pal.white
            }

        case .timer:
            str = Fmt.tm(
                tm.isRunning || tm.remainingAtStop < tm.duration ? tm.remaining : tm.duration,
                drama: tm.isRunning && tm.remaining < 10
            )
            if tm.finished && !alarmDismissed {
                color = Int(t * 4) % 2 == 0 ? Pal.white : Pal.red
            } else if tm.isRunning {
                color = tm.remaining <= 5 ? Pal.red : (tm.remaining <= 10 ? Pal.amber : Pal.cyan.withPulse(t, amp: 0.08))
            } else {
                color = Pal.white
            }

        case .stopwatch:
            str = Fmt.sw(sw.elapsed)
            color = sw.isRunning ? Pal.green.withPulse(t, amp: 0.08) : (sw.elapsed > 0 ? Pal.amber : Pal.white)
        }

        let mainScale = 2
        let fracScale = 2
        let main: Substring, frac: Substring
        if let dot = str.firstIndex(of: ".") {
            main = str[..<dot]
            frac = str[dot...]
        } else {
            main = str[...]
            frac = ""
        }

        let mw = PixelCanvas.heroWidth(String(main), scale: mainScale)
        let fw = frac.isEmpty ? 0 : PixelCanvas.heroWidth(String(frac), scale: fracScale)
        let totalW = mw + (fw == 0 ? 0 : fw + 3)
        let x0 = max(8, (gridW - totalW) / 2)
        let clockY = 21

        // CRT Phosphor Ghosting
        if str != ghostPrev {
            ghostPrev = str
            ghostUntil = Date().addingTimeInterval(0.10)
        }
        if Date() < ghostUntil {
            canvas.heroText(String(main), x: x0, y: clockY, c: color, scale: mainScale, a: 40)
        }

        canvas.heroText(String(main), x: x0, y: clockY, c: color, scale: mainScale)
        if !frac.isEmpty {
            canvas.heroText(String(frac), x: x0 + mw + 3, y: clockY, c: color, scale: fracScale)
        }

        // Subordinate status line under clock (Safe Band Y: 38..43)
        let status = statusLine(now)
        let fit = PixelCanvas.fitSmallText(status, maxWidth: gridW - 12)
        canvas.smallText(fit, x: (gridW - PixelCanvas.smallWidth(fit)) / 2, y: 38, c: Pal.inkDim)

        // Progress meter bar (Safe Band Y: 45..47)
        drawProgressBar(t)
    }

    private func drawProgressBar(_ t: Double) {
        let x = 6, w = gridW - 12, y = 45
        let frac: Double
        switch currentMode {
        case .pomodoro:
            frac = pomo.currentDuration > 0 ? (pomo.isRunning ? pomo.remaining : pomo.remainingAtStop) / pomo.currentDuration : 0
        case .timer:
            frac = tm.duration > 0 ? (tm.isRunning ? tm.remaining : tm.remainingAtStop) / tm.duration : 0
        case .stopwatch:
            frac = sw.isRunning ? 1.0 : (sw.elapsed > 0 ? 0.5 : 0.0)
        }

        let litW = Int(Double(w) * max(0, min(1, frac)))
        for i in 0..<litW {
            let h = Double(i) / Double(w)
            canvas.fillRect(x + i, y, 1, 2, rainbow(h, vq: isAnyRunning ? 1.0 : 0.6))
        }
        canvas.hline(x + litW, x + w - 1, y, Pal.grid)
        canvas.hline(x + litW, x + w - 1, y + 1, Pal.grid)
    }

    private func statusLine(_ now: Date) -> String {
        switch currentMode {
        case .pomodoro:
            if pomo.finished && !alarmDismissed { return "CYCLE COMPLETE · SPACE TO ADVANCE" }
            if pomo.isRunning {
                let phaseTag = pomo.phase == .work ? "FOCUS" : (pomo.phase == .shortBreak ? "SHORT BREAK" : "LONG BREAK")
                return "\(phaseTag) · CYCLE \(pomo.cyclesCompleted + 1)"
            }
            if pomo.remainingAtStop < pomo.currentDuration { return "PAUSED · SPACE RESUMES" }
            return "POMODORO · FOCUS 25M"

        case .timer:
            if tm.finished && !alarmDismissed { return "COMPLETE · SPACE CLEARS" }
            if tm.isRunning { return "COUNTDOWN ACTIVE" }
            if tm.remainingAtStop < tm.duration { return "PAUSED · SPACE RESUMES" }
            return "COUNTDOWN TIMER · READY"

        case .stopwatch:
            if sw.isRunning {
                return sw.laps.isEmpty ? "STOPWATCH RUNNING" : "LAP \(sw.laps.count + 1) IN PROGRESS"
            }
            if sw.elapsed > 0 { return "PAUSED · SPACE RESUMES" }
            return "STOPWATCH · READY"
        }
    }

    // MARK: - Duck Habitat & Animations

    private func drawDuck(_ t: Double, _ now: Date) {
        // Pond ground line in its dedicated band
        canvas.hline(14, gridW - 15, duckGroundY + 1, Pal.grid)
        canvas.fillRect(14, duckGroundY + 1, gridW - 28, 1, Pal.bgDeep, a: 140)

        var dy = duckGroundY - 10
        let flip = duckFlip

        let celebrate = isFinished
        let isMoving = abs(duckTargetX - duckCurX) > 1.0
        let running = isAnyRunning || isMoving
        let isEating = now < peckUntil
        let isQuacking = now < quackUntil
        let isPetting = now < petUntil
        let isSleeping = (now.timeIntervalSince(lastUserActivity) > 35 && !running && !celebrate) || brain.currentPhase == .sleepy
        let isBreakRunning = currentMode == .pomodoro && pomo.phase != .work && pomo.isRunning

        // Natural blinks timer
        if now > nextBlink {
            blinkUntil = now.addingTimeInterval(0.22)
            nextBlink = now.addingTimeInterval(Double.random(in: 2.2...5.5))
        }

        let rows = brain.getSpriteRows(
            t: t,
            now: now,
            isFlapping: now < flapUntil || celebrate,
            isQuacking: isQuacking,
            isPetting: isPetting,
            isEating: isEating,
            isBreakRunning: isBreakRunning,
            isRunning: running,
            isSleeping: isSleeping,
            stridePhase: stridePhase,
            blinkUntil: blinkUntil
        )

        if celebrate {
            dy -= abs(sin(t * 7)) > 0.4 ? 2 : 0
        } else if isPetting {
            dy -= Int(abs(sin(t * 10)) * 2)
        }

        if now < hopUntil && !running && !celebrate { dy -= 3 }

        var resolvedRows = rows
        var customDuckX = duckX
        var customDuckY = dy
        var customFlip = flip

        if let perf = storyEngine.currentPerformanceOverride {
            if let perfRows = perf.spriteRows {
                resolvedRows = perfRows
            }
            if let px = perf.x {
                customDuckX = Int(px)
            }
            if let py = perf.y {
                customDuckY = Int(py)
            }
            if let pf = perf.flip {
                customFlip = pf
            }
        } else if let feastRows = storyEngine.getFeastSpriteOverride() {
            if !isEating && !isPetting && !running {
                resolvedRows = feastRows
            }
        }

        let isSleepingOrNightShiftSleep = isSleeping || (storyEngine.selectedStoryId == .nightShift && storyEngine.isFinaleActive)
        if isSleepingOrNightShiftSleep {
            spawnSnoreParticle(rows: resolvedRows, duckX: customDuckX, duckY: customDuckY, flip: customFlip, isMini: false, now: now)
        } else {
            if !snoreParticles.isEmpty {
                clearSleepFX()
            }
        }

        // Draw Base Duck
        canvas.drawSprite(resolvedRows, x: customDuckX, y: customDuckY, map: TimeCompanionRegistry.shared.activeCompanion.resolveColorMap(rareEvent: brain.activeRareEvent), flip: customFlip)

        // Draw Hat Overlay via Living Wardrobe Attachment Engine
        drawDuckHat(
            currentHat,
            duckX: customDuckX,
            duckY: customDuckY,
            duckRows: resolvedRows,
            t: t,
            isRunning: running,
            isCelebrating: celebrate,
            flip: customFlip
        )

        // Draw Speech Bubble if active
        if let msg = speechText, now < speechUntil {
            canvas.drawSpeechBubble(text: msg, targetX: customDuckX, targetY: customDuckY, isFlipped: customDuckX > gridW - 45)
        }
    }

    // MARK: - Story Theatrical Renderers

    private func drawStoryScenery(zIndex: Int) {
        guard !mini else { return }
        for prop in storyEngine.props where prop.zIndex == zIndex && prop.isVisible {
            let map: [Character: Color]
            switch prop.colorMapKey {
            case "wood":
                map = ["a": Pal.amber, "k": Pal.bgDeep, "s": Pal.grid, "w": Pal.white]
            case "fire":
                map = ["r": Pal.red, "o": Pal.duckBill, "a": Pal.amber, "w": Pal.white]
            case "flag":
                map = ["r": Pal.red, "k": Pal.bgDeep, "s": Pal.grid]
            case "coffee":
                map = ["w": Pal.white, "a": Pal.amber, "s": Pal.sweat]
            case "metal":
                map = ["s": Pal.grid, "k": Pal.bgDeep, "r": Pal.red, "a": Pal.amber]
            case "gym":
                map = ["a": Pal.amber, "k": Pal.bgDeep, "w": Pal.white, "s": Pal.grid]
            default:
                map = getDuckColorMap(rareEvent: brain.activeRareEvent)
            }
            canvas.drawSprite(prop.spriteRows, x: prop.x, y: prop.y, map: map, flip: prop.flip)
        }
    }

    private func drawStoryActors() {
        guard !mini else { return }
        for actor in storyEngine.actors where actor.isVisible {
            var map = actor.colorMapOverride ?? getDuckColorMap(rareEvent: brain.activeRareEvent)
            map["m"] = Pal.magenta
            map["p"] = Pal.cheek
            map["k"] = Pal.bgDeep
            map["s"] = Pal.grid
            map["w"] = Pal.white
            canvas.drawSprite(actor.spriteRows, x: Int(actor.x), y: Int(actor.y), map: map, flip: actor.flip)
        }
    }

    private func drawDuckHat(
        _ hat: DuckHat,
        duckX: Int,
        duckY: Int,
        duckRows: [String],
        t: Double,
        isRunning: Bool,
        isCelebrating: Bool,
        flip: Bool
    ) {
        guard hat != .none else { return }
        let anchor = DuckAnchorResolver.resolve(rows: duckRows)
        let (hatRows, xOff, yOff, hatFlip) = AccessoryAttachment.getSprite(
            for: hat,
            anchor: anchor,
            t: t,
            isRunning: isRunning,
            isCelebrating: isCelebrating
        )
        guard !hatRows.isEmpty else { return }
        let finalFlip = flip ? !hatFlip : hatFlip
        let drawX = duckX + (flip ? -xOff : xOff)
        let drawY = duckY + yOff
        let hatColorMap = TimeCompanionRegistry.shared.activeCompanion.resolveColorMap(rareEvent: brain.activeRareEvent)
        canvas.drawSprite(hatRows, x: drawX, y: drawY, map: hatColorMap, flip: finalFlip)
    }

    // MARK: - Titlebar Glyphs

    private var pinOn = false
    func setPin(_ on: Bool) { pinOn = on }

    private enum Glyph { case pin, expand, speaker, hat, palette, book }

    private func drawTitleToggle(_ id: String, x: Int, on: Bool, glyph: Glyph) {
        let hovered = hoverId == id
        let pressedAt = pressMap[id] ?? .distantPast
        let pressed = Date().timeIntervalSince(pressedAt) < 0.13
        let c: Color = on ? Pal.green : (hovered ? Pal.white : (id == "unmini" ? Pal.ink : Pal.inkDim))
        if hovered {
            canvas.fillRect(x - 1, 1, 11, 8, Pal.panelHi)
            canvas.frameRect(x - 1, 1, 11, 8, Pal.white)
        } else if id == "unmini" {
            canvas.fillRect(x - 1, 1, 11, 8, Pal.panel)
            canvas.frameRect(x - 1, 1, 11, 8, Pal.inkDim)
        }
        if pressed {
            canvas.hline(x, x + 9, 2, Pal.bgDeep)
        }
        let rows: [String]
        switch glyph {
        case .hat:
            rows = ["..c..", ".ccc.", "ccccc", ".....", "....."]
        case .palette:
            rows = [".ccc.", "c.c.c", "ccccc", ".c.c.", "..c.."]
        case .book:
            rows = [".cccc", "c.c.c", "c.c.c", "c.c.c", ".cccc"]
        case .pin:
            rows = on ? ["..c..", ".ccc.", "..c..", "..c..", "..c.."]
                     : ["..c..", ".c.c.", "..c..", "..c..", "..c.."]
        case .expand:
            rows = [
                "cc.cc",
                "c...c",
                ".....",
                "c...c",
                "cc.cc"
            ]
        case .speaker:
            rows = on ? ["..c.c", ".cc.c", "ccc.c", ".cc.c", "..c.c"]
                     : ["..c..", ".cc.x", "ccc.x", ".cc.x", "..c.."]
        }
        for (ry, row) in rows.enumerated() {
            for (rx, chr) in row.enumerated() {
                if chr == "c" { canvas.set(x + rx, 2 + ry, c) }
                else if chr == "x" { canvas.set(x + rx, 2 + ry, Pal.red) }
            }
        }
    }

    // MARK: - Particles & Toast

    private func stepParticles(_ dt: Double) {
        for i in parts.indices.reversed() {
            var p = parts[i]
            p.life -= dt
            if p.life <= 0 { parts.remove(at: i); continue }
            p.vy += p.grav * dt
            p.x += p.vx * dt
            p.y += p.vy * dt
            parts[i] = p
        }
        if parts.count > 240 { parts.removeFirst(parts.count - 240) }
    }

    private func appendParticle(_ particle: Particle) {
        parts.append(particle)
        if parts.count > 240 {
            parts.removeFirst(parts.count - 240)
        }
    }

    private func drawParticles() {
        for p in parts {
            let k = min(1, p.life / min(0.4, p.maxLife))
            canvas.set(Int(p.x), Int(p.y), p.c, a: UInt8(255 * k))
        }
    }

    private func stepSnoreParticles(_ dt: Double) {
        for i in snoreParticles.indices.reversed() {
            var s = snoreParticles[i]
            s.life -= dt
            if s.life <= 0 { snoreParticles.remove(at: i); continue }
            s.x += s.vx * dt
            s.y += s.vy * dt
            snoreParticles[i] = s
        }
    }

    private func drawSnoreParticles(_ m: CompactLayoutMetrics? = nil) {
        for s in snoreParticles {
            let progress = 1.0 - max(0.0, s.life / s.maxLife)
            let glyph: [String]
            if progress < 0.35 {
                glyph = GLYPH_SNORE_Z_SMALL
            } else if progress < 0.70 {
                glyph = GLYPH_SNORE_Z_MED
            } else {
                glyph = GLYPH_SNORE_Z_LARGE
            }

            let alpha: UInt8 = UInt8(255.0 * min(1.0, max(0.0, s.life / 0.6)))
            let snoreColor = Pal.cyan

            let originX = Int(s.x)
            let originY = Int(s.y)

            for (rIdx, row) in glyph.enumerated() {
                for (cIdx, char) in row.enumerated() {
                    if char == "z" {
                        let px = originX + cIdx
                        let py = originY + rIdx

                        if let miniMetrics = m {
                            if s.isMini && px >= miniMetrics.duckX && px < miniMetrics.duckX + miniMetrics.duckW &&
                               py >= miniMetrics.duckY && py < miniMetrics.duckY + miniMetrics.duckH {
                                canvas.set(px, py, snoreColor, a: alpha)
                            }
                        } else if !s.isMini && !mini {
                            if px >= 0 && px < gridW && py >= 0 && py < gridH {
                                canvas.set(px, py, snoreColor, a: alpha)
                            }
                        }
                    }
                }
            }
        }
    }

    private func drawToastOverlay(_ t: Double) {
        guard let txt = toastText else { return }
        let age = Date().timeIntervalSince(toastBorn)
        guard age < 1.6 else { toastText = nil; return }
        let w = PixelCanvas.smallWidth(txt) + 6
        let rise = min(4, Int(age * 14))
        let alpha: UInt8 = age > 1.2 ? UInt8(255 * (1.6 - age) / 0.4) : 255
        let x = (gridW - w) / 2, y = 35 - rise
        canvas.fillRect(x, y, w, 8, Pal.bgDeep, a: alpha)
        canvas.frameRect(x, y, w, 8, Pal.cyan, a: alpha)
        canvas.smallText(txt, x: x + 3, y: y + 2, c: Pal.cyan, a: alpha)
    }

    private func stateBorderColor(_ now: Date) -> Color {
        if isFinished && !alarmDismissed {
            return Int(now.timeIntervalSinceReferenceDate * 4) % 2 == 0 ? Pal.red : Pal.white
        }
        if isAnyRunning { return Pal.greenDim }
        return Pal.grid
    }

// MARK: - Wave 8: Achievement Toast & Duckbook Journal Overlay

    func drawAchievementToastOverlay(_ now: Date) {
        AchievementEngine.shared.updateToasts(now: now)
        guard let toast = AchievementEngine.shared.activeToast else { return }

        let bannerW = min(gridW - 12, 150)
        let bannerH = 18
        let bannerX = (gridW - bannerW) / 2
        let bannerY = mini ? 2 : 4

        // Background fill & double border
        canvas.fillRect(bannerX, bannerY, bannerW, bannerH, Pal.bgDeep, a: 245)
        canvas.frameRect(bannerX, bannerY, bannerW, bannerH, Pal.cyan)
        canvas.frameRect(bannerX + 1, bannerY + 1, bannerW - 2, bannerH - 2, Pal.panel)

        // Glyph badge stamp (5x5)
        let glyphMap: [Character: Color] = [
            "w": Pal.white, "g": Pal.green, "r": Pal.red, "a": Pal.amber,
            "b": Pal.cyan, "k": Pal.bgDeep, ".": Pal.clear
        ]
        canvas.drawSprite(toast.glyph, x: bannerX + 4, y: bannerY + 6, map: glyphMap, flip: false)

        // Title: "★ <TITLE> ★"
        let titleStr = "★ \(toast.title.uppercased()) ★"
        canvas.smallText(titleStr, x: bannerX + 12, y: bannerY + 3, c: Pal.amber)

        // Description or reward subtitle
        let subStr: String
        if let reward = toast.rewardDescription, !reward.isEmpty {
            subStr = reward.uppercased()
        } else {
            subStr = toast.description.uppercased()
        }
        let truncatedSub = String(subStr.prefix(26))
        canvas.smallText(truncatedSub, x: bannerX + 12, y: bannerY + 10, c: Pal.cyan)
    }

    func drawDuckbookOverlay(_ t: Double, _ now: Date) {
        let modalX = 6
        let modalY = 8
        let modalW = gridW - 12
        let modalH = gridH - 16

        // Modal backdrop panel & high-contrast phosphor border
        canvas.fillRect(modalX, modalY, modalW, modalH, Pal.bgDeep, a: 245)
        canvas.frameRect(modalX, modalY, modalW, modalH, Pal.cyan)
        canvas.frameRect(modalX + 1, modalY + 1, modalW - 2, modalH - 2, Pal.panel)

        // Header
        canvas.smallText("DUCKBOOK", x: modalX + 6, y: modalY + 3, c: Pal.amber)
        let countStr = "\(AchievementEngine.shared.unlockedCount)/\(AchievementEngine.shared.totalCount) UNLOCKED"
        canvas.smallText(countStr, x: modalX + 54, y: modalY + 3, c: Pal.inkDim)

        // Close button [X]
        let closeHovered = (hoverId == "db-close")
        canvas.fillRect(modalX + modalW - 12, modalY + 2, 9, 8, closeHovered ? Pal.panelHi : Pal.panel)
        canvas.frameRect(modalX + modalW - 12, modalY + 2, 9, 8, closeHovered ? Pal.white : Pal.inkDim)
        canvas.smallText("X", x: modalX + modalW - 9, y: modalY + 3, c: closeHovered ? Pal.white : Pal.inkDim)

        // Tab header bar (y: modalY + 11)
        canvas.hline(modalX + 2, modalX + modalW - 3, modalY + 10, Pal.grid)
        canvas.hline(modalX + 2, modalX + modalW - 3, modalY + 19, Pal.grid)

        let tabs = DuckbookTab.allCases
        let tabXOffsets = [6, 54, 110]
        let tabWidths = [44, 52, 34]

        for (idx, tab) in tabs.enumerated() {
            let isSelected = (DuckbookEngine.shared.activeTab == tab)
            let tx = modalX + tabXOffsets[idx]
            let tw = tabWidths[idx]
            let hovered = (hoverId == "db-tab-\(idx)")

            if isSelected {
                canvas.fillRect(tx, modalY + 11, tw, 8, Pal.panelHi)
                canvas.frameRect(tx, modalY + 11, tw, 8, Pal.cyan)
                canvas.smallText(tab.title, x: tx + 3, y: modalY + 12, c: Pal.white)
            } else {
                if hovered {
                    canvas.fillRect(tx, modalY + 11, tw, 8, Pal.panel)
                    canvas.frameRect(tx, modalY + 11, tw, 8, Pal.inkDim)
                }
                canvas.smallText(tab.title, x: tx + 3, y: modalY + 12, c: hovered ? Pal.white : Pal.inkDim)
            }
        }

        // Content Area (y: modalY + 21 ... modalY + modalH - 12)
        switch DuckbookEngine.shared.activeTab {
        case .companions:
            drawDuckbookCompanionsTab(modalX: modalX, modalY: modalY, modalW: modalW, modalH: modalH, t: t)
        case .achievements:
            drawDuckbookAchievementsTab(modalX: modalX, modalY: modalY, modalW: modalW, modalH: modalH)
        case .secrets:
            drawDuckbookSecretsTab(modalX: modalX, modalY: modalY, modalW: modalW, modalH: modalH)
        }

        // Footer Hint Bar
        canvas.hline(modalX + 2, modalX + modalW - 3, modalY + modalH - 9, Pal.grid)
        canvas.smallText("TAB:SWITCH  ARROWS:NAV  ENTER:SELECT  ESC:CLOSE", x: modalX + 4, y: modalY + modalH - 6, c: Pal.inkDim)
    }

    private func drawDuckbookCompanionsTab(modalX: Int, modalY: Int, modalW: Int, modalH: Int, t: Double) {
        let companions = TimeCompanionRegistry.shared.allCompanions
        let selectedIdx = DuckbookEngine.shared.selectedIndex
        let activeId = TimeCompanionRegistry.shared.activeCompanionId

        let startIdx = min(max(0, DuckbookEngine.shared.scrollOffset), max(0, companions.count - 3))
        let endIdx = min(companions.count, startIdx + 3)

        for (row, i) in (startIdx..<endIdx).enumerated() {
            let comp = companions[i]
            let isCurrentSelected = (i == selectedIdx)
            let isCurrentlyActive = (comp.id == activeId)
            let isUnlocked = TimeCompanionRegistry.shared.isUnlocked(comp.id)

            let rowY = modalY + 21 + row * 16
            let rowW = modalW - 8
            let rowX = modalX + 4
            let rowH = 15

            if isCurrentSelected {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panelHi)
                canvas.frameRect(rowX, rowY, rowW, rowH, Pal.amber)
                canvas.smallText(">", x: rowX + 1, y: rowY + 5, c: Pal.amber)
            } else if isCurrentlyActive {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panel)
                canvas.frameRect(rowX, rowY, rowW, rowH, Pal.green)
            } else {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panel)
            }

            // Portrait Sprite (10x10 centered vertically inside 15px card)
            let portrait = isUnlocked ? comp.portraitSprite : PORTRAIT_LOCKED_SECRET
            let pColorMap = isUnlocked ? comp.resolveColorMap() : getDuckColorMap()
            canvas.drawSprite(portrait, x: rowX + 4, y: rowY + 2, map: pColorMap, flip: false)

            // Name & Status
            if isUnlocked {
                let nameColor = isCurrentlyActive ? Pal.green : (isCurrentSelected ? Pal.white : Pal.ink)
                let nameStr = String(comp.displayName.uppercased().prefix(20))
                canvas.smallText(nameStr, x: rowX + 17, y: rowY + 2, c: nameColor)
                let subText = String(comp.subtitle.prefix(21))
                canvas.smallText(subText, x: rowX + 17, y: rowY + 8, c: Pal.inkDim)

                if isCurrentlyActive {
                    canvas.smallText("[ACTIVE]", x: rowX + rowW - 36, y: rowY + 5, c: Pal.green)
                } else {
                    canvas.smallText("[SELECT]", x: rowX + rowW - 36, y: rowY + 5, c: isCurrentSelected ? Pal.cyan : Pal.inkDim)
                }
            } else {
                canvas.smallText("??? [LOCKED]", x: rowX + 17, y: rowY + 2, c: Pal.inkDim)
                let lockHint = comp.isSecret ? "SECRET POND DISCOVERY" : "UNLOCK VIA MILESTONE"
                canvas.smallText(lockHint, x: rowX + 17, y: rowY + 8, c: Pal.inkDim)
                canvas.smallText("[LOCKED]", x: rowX + rowW - 36, y: rowY + 5, c: Pal.inkDim)
            }
        }

        // Scroll track indicator if list exceeds visible 3 items
        if companions.count > 3 {
            let trackY = modalY + 21
            let trackH = 3 * 16 - 1
            let thumbH = max(8, Int(Double(trackH) * 3.0 / Double(companions.count)))
            let scrollY = trackY + Int(Double(startIdx) / Double(max(1, companions.count - 3)) * Double(trackH - thumbH))
            canvas.fillRect(modalX + modalW - 3, scrollY, 2, thumbH, Pal.cyan)
        }
    }

    private func drawDuckbookAchievementsTab(modalX: Int, modalY: Int, modalW: Int, modalH: Int) {
        let items = AchievementEngine.shared.orderedCatalog
        let selectedIdx = DuckbookEngine.shared.selectedIndex
        let startIdx = min(max(0, DuckbookEngine.shared.scrollOffset), max(0, items.count - 3))
        let endIdx = min(items.count, startIdx + 3)

        for (row, i) in (startIdx..<endIdx).enumerated() {
            let ach = items[i]
            let isCurrentSelected = (i == selectedIdx)
            let isUnlocked = AchievementEngine.shared.isUnlocked(ach.id)

            let rowY = modalY + 21 + row * 16
            let rowW = modalW - 8
            let rowX = modalX + 4
            let rowH = 15

            if isCurrentSelected {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panelHi)
                canvas.frameRect(rowX, rowY, rowW, rowH, Pal.amber)
                canvas.smallText(">", x: rowX + 1, y: rowY + 5, c: Pal.amber)
            } else if isUnlocked {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panel)
            } else {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.bgDeep)
                canvas.frameRect(rowX, rowY, rowW, rowH, Pal.grid)
            }

            // Glyph Badge Stamp (5x5 centered vertically)
            let glyph = (ach.isHidden && !isUnlocked) ? BADGE_GLYPH_SECRET : (isUnlocked ? ach.glyph : BADGE_GLYPH_LOCKED)
            let glyphMap: [Character: Color] = [
                "w": isUnlocked ? Pal.white : Pal.inkDim,
                "g": isUnlocked ? Pal.green : Pal.inkDim,
                "r": isUnlocked ? Pal.red : Pal.inkDim,
                "a": isUnlocked ? Pal.amber : Pal.inkDim,
                "b": isUnlocked ? Pal.cyan : Pal.inkDim,
                "k": Pal.bgDeep,
                ".": Pal.clear
            ]
            canvas.drawSprite(glyph, x: rowX + 6, y: rowY + 5, map: glyphMap, flip: false)

            // Title & Description
            if isUnlocked {
                let titleStr = String(ach.title.uppercased().prefix(20))
                canvas.smallText(titleStr, x: rowX + 17, y: rowY + 2, c: isCurrentSelected ? Pal.white : Pal.cyan)
                let descStr = String(ach.description.prefix(21))
                canvas.smallText(descStr, x: rowX + 17, y: rowY + 8, c: Pal.inkDim)
                canvas.smallText("★ DONE", x: rowX + rowW - 32, y: rowY + 5, c: Pal.amber)
            } else {
                let lockedTitle = ach.isHidden ? "??? [SECRET]" : String(ach.title.uppercased().prefix(20))
                canvas.smallText(lockedTitle, x: rowX + 17, y: rowY + 2, c: Pal.inkDim)
                let hintStr = ach.isHidden ? "DISCOVER BY EXPLORING" : String(ach.hint.prefix(21))
                canvas.smallText(hintStr, x: rowX + 17, y: rowY + 8, c: Pal.inkDim)
                canvas.smallText("[LOCK]", x: rowX + rowW - 30, y: rowY + 5, c: Pal.inkDim)
            }
        }

        // Scroll track indicator if list exceeds visible 3 items
        if items.count > 3 {
            let trackY = modalY + 21
            let trackH = 3 * 16 - 1
            let thumbH = max(8, Int(Double(trackH) * 3.0 / Double(items.count)))
            let scrollY = trackY + Int(Double(startIdx) / Double(max(1, items.count - 3)) * Double(trackH - thumbH))
            canvas.fillRect(modalX + modalW - 3, scrollY, 2, thumbH, Pal.cyan)
        }
    }

    private func drawDuckbookSecretsTab(modalX: Int, modalY: Int, modalW: Int, modalH: Int) {
        let fedCount = AchievementEngine.shared.breadcrumbsFedTotal
        let hatCount = AchievementEngine.shared.costumesTried.count
        let streak = StatsTracker().streakDays
        let cyberUnlocked = TimeCompanionRegistry.shared.isUnlocked(.cyberDuck)

        struct SecretCardData {
            let title: String
            let titleColor: Color
            let val: String
            let valColor: Color
            let sub: String
        }

        let cards: [SecretCardData] = [
            SecretCardData(title: "BREADCRUMBS FED", titleColor: Pal.amber, val: "\(fedCount) CRUMBS", valColor: Pal.white, sub: "FEEDS PRODUCE CHONKY DUCK"),
            SecretCardData(title: "COSTUMES EXPLORED", titleColor: Pal.cyan, val: "\(hatCount)/15 WARDROBE", valColor: Pal.white, sub: "TRY CAPS, HATS & BANDANAS"),
            SecretCardData(title: "FOCUS FLOCK STREAK", titleColor: Pal.green, val: "\(streak) DAYS", valColor: Pal.white, sub: "DAILY FOCUS MISSION STREAK"),
            SecretCardData(title: "QUANTUM ANOMALY", titleColor: Pal.violet, val: cyberUnlocked ? "CYBERDUCK" : "LOCKED", valColor: cyberUnlocked ? Pal.cyan : Pal.inkDim, sub: cyberUnlocked ? "0xFEED POND TELEMETRY OK" : "POND MAESTRO UNLOCKS GHOST")
        ]

        let selectedIdx = DuckbookEngine.shared.selectedIndex
        let startIdx = min(max(0, DuckbookEngine.shared.scrollOffset), max(0, cards.count - 3))
        let endIdx = min(cards.count, startIdx + 3)

        for (row, i) in (startIdx..<endIdx).enumerated() {
            let c = cards[i]
            let isCurrentSelected = (i == selectedIdx)
            let rowY = modalY + 21 + row * 16
            let rowW = modalW - 8
            let rowX = modalX + 4
            let rowH = 15

            if isCurrentSelected {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panelHi)
                canvas.frameRect(rowX, rowY, rowW, rowH, Pal.amber)
                canvas.smallText(">", x: rowX + 1, y: rowY + 5, c: Pal.amber)
            } else {
                canvas.fillRect(rowX, rowY, rowW, rowH, Pal.panel)
            }

            canvas.smallText(c.title, x: rowX + 5, y: rowY + 2, c: c.titleColor)
            canvas.smallText(c.val, x: rowX + rowW - 48, y: rowY + 2, c: c.valColor)
            canvas.smallText(c.sub, x: rowX + 5, y: rowY + 8, c: Pal.inkDim)
        }

        if cards.count > 3 {
            let trackY = modalY + 21
            let trackH = 3 * 16 - 1
            let thumbH = max(8, Int(Double(trackH) * 3.0 / Double(cards.count)))
            let scrollY = trackY + Int(Double(startIdx) / Double(max(1, cards.count - 3)) * Double(trackH - thumbH))
            canvas.fillRect(modalX + modalW - 3, scrollY, 2, thumbH, Pal.cyan)
        }
    }

}

// MARK: - Pulse Helper

extension Color {
    func withPulse(_ t: Double, amp: Double) -> Color {
        let k = 1 - amp / 2 + amp * sin(t * 2.4) / 2
        let r = Double((self >> 16) & 255) * k
        let g = Double((self >> 8) & 255) * k
        let b = Double(self & 255) * k
        return rgb(Int(r), Int(g), Int(b))
    }
}

    