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

    // Speech Bubble
    private var speechText: String? = nil
    private var speechUntil = Date.distantPast

    // FX Bookkeeping
    private var ghostPrev = ""
    private var ghostUntil = Date.distantPast
    private var toastText: String? = nil
    private var toastBorn = Date.distantPast
    private var pressMap: [String: Date] = [:]
    private var lastWholeSec = -1
    private var alertedTimerEnd: Date?
    private var alertedPomodoroEnd: Date?
    var alarmDismissed = false
    private var confettiPulse = Date.distantPast

    let brain = DuckBrain()

    init(sw: StopwatchModel, tm: TimerModel, pomo: PomodoroModel, stats: StatsTracker) {
        self.sw = sw
        self.tm = tm
        self.pomo = pomo
        self.stats = stats
        super.init()
        seedStars()
    }

    /// Indicates whether high-rate animation (confetti, petting, moving, particles, idle poses) is currently occurring.
    var hasActiveAnimation: Bool {
        if isEditingTime { return true }
        let now = Date()
        if !parts.isEmpty || !crumbs.isEmpty { return true }
        if now < hopUntil || now < flapUntil || now < quackUntil || now < peckUntil || now < petUntil { return true }
        if now < speechUntil || now.timeIntervalSince(toastBorn) < 1.6 { return true }
        if abs(duckTargetX - duckCurX) > 0.5 { return true }
        if isFinished && !alarmDismissed { return true }
        if brain.hasActivePose { return true }
        return false
    }

    var isFinished: Bool {
        (currentMode == .pomodoro && pomo.finished) || (currentMode == .timer && tm.finished)
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
    }

    func toast(_ s: String) {
        toastText = s
        toastBorn = Date()
        lastUserActivity = Date()
    }

    func speak(_ s: String, duration: Double = 2.4) {
        speechText = s
        speechUntil = Date().addingTimeInterval(duration)
    }

    func duckHop() {
        hopUntil = Date().addingTimeInterval(0.40)
        quackUntil = Date().addingTimeInterval(0.35)
        lastUserActivity = Date()
        snd?.quack()
    }

    func petDuck() {
        lastUserActivity = Date()
        let res = brain.onPoke()
        petUntil = Date().addingTimeInterval(0.85)
        duckHop()
        if res.level >= 4 {
            spawnConfetti(15)
            snd?.quack(pitch: 0.85)
        } else {
            spawnHearts(6 + res.level * 2)
            snd?.happyChirp()
        }
        speak(res.phrase)
    }

    func dropBreadcrumb(at gx: Double? = nil) {
        let x = gx ?? Double(Int.random(in: 20..<max(25, gridW - 35)))
        let y = Double(duckGroundY - 2)
        crumbs.append(Breadcrumb(x: x, y: y, life: 12.0))
        duckTargetX = max(18, min(Double(gridW - 32), x - 4))
        lastUserActivity = Date()
        toast("CRUMB DROPPED")
        let quip = brain.onCrumb()
        speak(quip)
        snd?.happyChirp()
    }

    func spawnHearts(_ n: Int) {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 6), oy = Double(duckGroundY - 12)
        for _ in 0..<n {
            parts.append(Particle(
                x: ox, y: oy,
                vx: Double.random(in: -20...20, using: &rng),
                vy: Double.random(in: -45...(-20), using: &rng),
                life: Double.random(in: 0.8...1.4, using: &rng),
                maxLife: 1.4,
                c: Pal.red,
                grav: -10
            ))
        }
    }

    func spawnConfetti(_ n: Int) {
        var rng = SystemRandomNumberGenerator()
        let ox = Double(duckX + 6), oy = Double(duckGroundY - 10)
        for _ in 0..<n {
            parts.append(Particle(
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
        alarmDismissed = true
    }

    // MARK: - Master Render

    func render() {
        let now = Date()
        let t = now.timeIntervalSinceReferenceDate
        let dt = min(0.1, now.timeIntervalSince(lastFrame))
        lastFrame = now

        canvas.fillAll(mini ? Pal.bgDeep : Pal.bg)

        updateDuckBrain(dt, now: now)

        if mini {
            renderMini(t, now)
            canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: Int(t * 14) % (gridH + 30) - 15, bandH: 4)
            return
        }

        drawStars(t)
        drawEmbers(dt)
        drawBreadcrumbs()
        drawChrome(t, now)
        drawClockArea(t, now)
        drawDuck(t, now)
        stepParticles(dt)
        drawParticles()

        let bandY = Int(t * 22) % (gridH + 44) - 22
        canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: bandY, bandH: 5)

        drawToastOverlay(t)
    }

    func makeImage() -> CGImage? {
        guard let ctx = ctx else { return nil }
        return ctx.makeImage()
    }

    // MARK: - Duck Brain & Physics

    private func updateDuckBrain(_ dt: Double, now: Date) {
        let dx = duckTargetX - duckCurX
        if abs(dx) > 1.0 {
            let speed = 28.0
            duckCurX += (dx > 0 ? 1 : -1) * min(abs(dx), speed * dt)
            duckFlip = dx < 0
            stridePhase += dt * 9
        } else {
            // Check if arrived at a breadcrumb
            if let idx = crumbs.firstIndex(where: { abs($0.x - (duckCurX + 6)) < 8 }) {
                peckUntil = now.addingTimeInterval(0.9)
                crumbs.remove(at: idx)
                snd?.quack()
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
    }

    // MARK: - Alarm & Event Handling

    /// Processes timer completions independently of rendering so hidden windows still alert and record stats.
    /// Services ALL engines (timer/pomodoro) regardless of currentMode so inactive-mode and hidden-window
    /// completions are always handled (stats recorded, fanfare played, duplicate prevented).
    @discardableResult
    func processTimeEvents(_ now: Date = Date()) -> Bool {
        var didRecordCompletion = false

        // Timer completion (always, even if not current mode)
        if tm.isFinished(at: now) && !tm.completionRecorded {
            tm.markCompletionRecorded()
            stats.addFocusSeconds(tm.duration, now: now)
            snd?.victoryFanfare()
            alarmDismissed = false
            if currentMode == .timer {
                spawnConfetti(75)
                flapUntil = now.addingTimeInterval(1.2)
                confettiPulse = now
                let quip = brain.onTimerComplete(mode: .timer, isWorkPomodoro: false)
                speak(quip)
            }
            didRecordCompletion = true
        }

        // Pomodoro completion (always, even if not current mode)
        if pomo.isFinished(at: now) && !pomo.completionRecorded {
            if pomo.phase == .work {
                stats.recordPomodoroCompleted(duration: pomo.workDuration, now: now)
            }
            pomo.markCompletionRecorded()
            snd?.victoryFanfare()
            alarmDismissed = false
            if currentMode == .pomodoro {
                spawnConfetti(75)
                flapUntil = now.addingTimeInterval(1.2)
                confettiPulse = now
                let quip = brain.onTimerComplete(mode: .pomodoro, isWorkPomodoro: pomo.phase == .work)
                speak(quip)
            }
            didRecordCompletion = true
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

        let modeTag = currentMode == .pomodoro ? "POMO" : (currentMode == .timer ? "TIMER" : "SW")

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

        // Top-Left: Mode pill / switch button
        let modeHovered = hoverId == "tab-cycle"
        canvas.fillRect(m.modePillRect.x, m.modePillRect.y, m.modePillRect.w, m.modePillRect.h, Pal.panelHi)
        canvas.frameRect(m.modePillRect.x, m.modePillRect.y, m.modePillRect.w, m.modePillRect.h, modeHovered ? Pal.white : Pal.green)
        canvas.smallText(m.modeTag, x: m.modePillRect.x + 3, y: m.modePillRect.y + 1, c: modeHovered ? Pal.white : Pal.green)

        // Top-Right: Sound toggle & Expand / Exit Compact button (strictly left of duck separator)
        drawTitleToggle("toggle-sound", x: m.soundRect.x, on: snd?.enabled ?? true, glyph: .speaker)
        drawTitleToggle("unmini", x: m.unminiRect.x, on: false, glyph: .expand)

        // Center-Left: Time Digits in protected region
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

        // Center-Right: Action buttons (GO, SEC)
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

        // Far-Right: Dedicated Animated Duck Box (Protected Column)
        canvas.vline(m.duckX - 1, 2, gridH - 3, Pal.grid)
        canvas.fillRect(m.duckX, m.duckY, m.duckW, m.duckH, Pal.bgDeep)

        let duckHovered = hoverId == "pet-duck" || hoverId == "duck"
        if duckHovered {
            canvas.frameRect(m.duckX, m.duckY, m.duckW, m.duckH, Pal.panelHi)
        }

        let dx = m.duckSpriteX
        let dy = m.duckSpriteY
        let rows = miniDuckRows(t, running: running, now: now)
        canvas.drawSprite(rows, x: dx, y: dy, map: getDuckColorMap(), flip: false)
        drawDuckHat(currentHat, duckX: dx, duckY: dy, flip: false)

        // Bottom Progress Bar
        drawMiniProgressBar(t, x: m.progressBarRect.x, y: m.progressBarRect.y, w: m.progressBarRect.w)
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
        if isFinished && !alarmDismissed {
            return Int(t * 6) % 2 == 0 ? DUCK_YAY_A : DUCK_YAY_B
        }
        if now < hopUntil || now < quackUntil {
            return DUCK_QUACK_ROWS
        }
        if now < petUntil {
            return DUCK_PET_ROWS
        }
        if running {
            let ph = (t * 6).truncatingRemainder(dividingBy: 3)
            return ph < 1 ? DUCK_RUN_A : (ph < 2 ? DUCK_RUN_B : DUCK_RUN_C)
        }
        let breathe = Int(t * 1.5) % 3
        return breathe == 0 ? DUCK_BASE : (breathe == 1 ? DUCK_IDLE_B : DUCK_IDLE_WAG)
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
            parts.append(Particle(
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
                color = Pal.ink
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
                color = Pal.ink
            }

        case .stopwatch:
            str = Fmt.sw(sw.elapsed)
            color = sw.isRunning ? Pal.green.withPulse(t, amp: 0.08) : (sw.elapsed > 0 ? Pal.amber : Pal.ink)
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
        let clockY = 22

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

        // Mode badge under clock
        let status = statusLine(now)
        let fit = PixelCanvas.fitSmallText(status, maxWidth: gridW - 12)
        canvas.smallText(fit, x: (gridW - PixelCanvas.smallWidth(fit)) / 2, y: 39, c: Pal.inkDim)

        // Progress meter bar
        drawProgressBar(t)
    }

    private func drawProgressBar(_ t: Double) {
        let x = 6, w = gridW - 12, y = 46
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
                let eta = now.addingTimeInterval(pomo.remaining)
                let comp = Calendar.current.dateComponents([.hour, .minute], from: eta)
                return String(format: "\(pomo.phase.title) · DONE BY %02d:%02d", comp.hour ?? 0, comp.minute ?? 0)
            }
            return "POMODORO FOCUS · SPACE TO START"

        case .timer:
            if tm.finished && !alarmDismissed { return "COMPLETE · SPACE CLEARS" }
            if tm.isRunning {
                let eta = now.addingTimeInterval(tm.remaining)
                let comp = Calendar.current.dateComponents([.hour, .minute], from: eta)
                return String(format: "RUNNING · DONE BY %02d:%02d", comp.hour ?? 0, comp.minute ?? 0)
            }
            if tm.remainingAtStop < tm.duration { return "PAUSED · SPACE RESUMES" }
            return "COUNTDOWN TIMER · SPACE TO START"

        case .stopwatch:
            if sw.isRunning {
                return sw.laps.isEmpty ? "RUNNING" : "LAP \(sw.laps.count + 1) IN PROGRESS"
            }
            if sw.elapsed > 0 { return "PAUSED · SPACE RESUMES" }
            return "STOPWATCH · SPACE TO START"
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
        } else if isSleeping {
            if Int(t * 2.5) % 4 == 0 && parts.count < 60 {
                parts.append(Particle(
                    x: Double(duckX + (flip ? 2 : 10)), y: Double(dy - 2),
                    vx: flip ? Double.random(in: -7...(-3)) : Double.random(in: 3...7),
                    vy: Double.random(in: -14...(-8)),
                    life: 2.0, maxLife: 2.0, c: Pal.cyan, grav: -1
                ))
            }
        }

        if now < hopUntil && !running && !celebrate { dy -= 3 }

        // Draw Base Duck
        canvas.drawSprite(rows, x: duckX, y: dy, map: getDuckColorMap(), flip: flip)

        // Draw Hat Overlay
        drawDuckHat(currentHat, duckX: duckX, duckY: dy, flip: flip)

        // Draw Speech Bubble if active
        if let msg = speechText, now < speechUntil {
            canvas.drawSpeechBubble(text: msg, targetX: duckX, targetY: dy, isFlipped: duckX > gridW - 45)
        }
    }

    private func drawDuckHat(_ hat: DuckHat, duckX: Int, duckY: Int, flip: Bool) {
        guard hat != .none else { return }
        let rows: [String]
        switch hat {
        case .wizard:            rows = HAT_WIZARD
        case .detective:         rows = HAT_DETECTIVE
        case .cyber:             rows = HAT_CYBER
        case .barista:           rows = HAT_BARISTA
        case .sleepcap:          rows = HAT_SLEEPCAP
        case .crown:             rows = HAT_CROWN
        case .bandanaMidnight:   rows = HAT_BANDANA_MIDNIGHT
        case .bandanaCrimson:    rows = HAT_BANDANA_CRIMSON
        case .bandanaForestCamo: rows = HAT_BANDANA_FOREST
        case .bandanaDesertCamo: rows = HAT_BANDANA_DESERT
        case .none:              return
        }
        var hatY = duckY - 4
        if brain.currentPose == .sitting { hatY += 1 }
        canvas.drawSprite(rows, x: duckX, y: hatY, map: getDuckColorMap(), flip: flip)
    }

    // MARK: - Titlebar Glyphs

    private var pinOn = false
    func setPin(_ on: Bool) { pinOn = on }

    private enum Glyph { case pin, expand, speaker, hat, palette }

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

    private func drawParticles() {
        for p in parts {
            let k = min(1, p.life / min(0.4, p.maxLife))
            canvas.set(Int(p.x), Int(p.y), p.c, a: UInt8(255 * k))
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
