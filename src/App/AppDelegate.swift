// MARK: - TimeDuck · AppDelegate.swift
// Main application coordinator: Window lifecycle, adaptive frame pump,
// input dispatch, menu bar management, and state coordination.

import Foundation
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let sw = StopwatchModel()
    let tm = TimerModel()
    let pomo = PomodoroModel()
    let stats = StatsTracker()
    let snd = SoundEngine()

    var view: TimeDuckView!
    var host: PixelHostView!
    var window: NSWindow!
    private var menuManager: MenuManager!

    private var frameTimer: Timer?
    private var statusTimer: Timer?
    private var currentFrameInterval: TimeInterval = 1.0 / 60.0

    var currentMode: Mode = .pomodoro {
        didSet {
            if view != nil { view.currentMode = currentMode }
            updateDisplayPumpRate()
            menuManager?.syncStatus()
        }
    }

    var isWindowVisible: Bool {
        window != nil && window.isVisible && !window.isMiniaturized
    }

    // MARK: - NSApplicationDelegate Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        view = TimeDuckView(sw: sw, tm: tm, pomo: pomo, stats: stats)
        view.snd = snd

        restoreState()

        view.currentMode = currentMode
        view.crtEnabled = UserDefaults.standard.object(forKey: "td.crt") as? Bool ?? true
        view.buttons = view.layoutButtons()
        view.rebuildCanvas()

        let frame = NSRect(
            x: 0, y: 0,
            width: view.gridW * view.scale,
            height: view.gridH * view.scale
        )
        host = PixelHostView(frame: frame)
        host.wantsLayer = true
        host.onDraw = { [weak self] img in self?.pushImage(img) }
        host.onClick = { [weak self] p in self?.handleClick(p) }
        host.onHover = { [weak self] p in self?.handleHover(p) }

        window = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = AppVersion.appName
        window.contentView = host
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .normal
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.minSize = NSSize(width: 200, height: 60)
        window.delegate = self
        window.center()

        menuManager = MenuManager(appDelegate: self)
        menuManager.setup()

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            self?.handleKeyEvent(e) ?? e
        }
        NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] e in
            self?.handleScrollWheel(e)
            return e
        }

        startDisplayPump()
        startStatusSyncTimer()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if snd.musicEnabled {
            snd.startMusic()
        }

        // Check for first launch of new version to display What's New
        if WhatsNewManager.shared.shouldPresentAutomatically() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                self?.showWhatsNew(nil)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showWindow()
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        frameTimer?.invalidate()
        statusTimer?.invalidate()
        Store.cancelPending()
        persistImmediate()
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Window close does NOT quit the application; it keeps TimeDuck active in the menu bar.
        window.orderOut(nil)
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
        return false
    }

    func windowDidResize(_ notification: Notification) {
        handleWindowResize()
    }

    func handleWindowResize() {
        guard host != nil, view != nil else { return }
        host.updateTrackingAreas()
        view.buttons = view.layoutButtons()
        updateDisplayPumpRate()
        frameTick()
    }

    func windowDidMiniaturize(_ notification: Notification) {
        updateDisplayPumpRate()
    }

    func windowDidDeminiaturize(_ notification: Notification) {
        updateDisplayPumpRate()
    }

    func windowDidBecomeKey(_ notification: Notification) {
        updateDisplayPumpRate()
    }

    func windowDidResignKey(_ notification: Notification) {
        updateDisplayPumpRate()
    }

    // MARK: - Window Visibility Controls

    func showWindow() {
        if window.isMiniaturized {
            window.deminiaturize(nil)
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        if let wake = view.brain.onWindowRestore() {
            view.speak(wake, duration: 2.2)
        }
        updateDisplayPumpRate()
        menuManager.syncStatus()
    }

    func hideWindow() {
        window.orderOut(nil)
        updateDisplayPumpRate()
        menuManager.syncStatus()
    }

    @objc func toggleWindowVisibility(_ sender: Any?) {
        if isWindowVisible && NSApp.isActive {
            hideWindow()
        } else {
            showWindow()
        }
    }

    // MARK: - Adaptive Display Pump (Energy Efficiency)

    private func targetFrameInterval() -> TimeInterval? {
        guard isWindowVisible else { return nil } // 0 FPS when hidden
        if view.hasActiveAnimation || sw.isRunning || (tm.isRunning && tm.remaining < 10) || (pomo.isRunning && pomo.remaining < 10) {
            return 1.0 / 60.0 // 60 FPS for precision stopwatch, tenths drama, and animations
        }
        if view.isAnyRunning {
            return 1.0 / 30.0 // 30 FPS for active running timer/pomodoro
        }
        if NSApp.isActive {
            return 1.0 / 15.0 // 15 FPS for retro pixel art idle animations
        }
        return 1.0 / 10.0     // 10 FPS for background idle
    }

    private func startDisplayPump() {
        updateDisplayPumpRate()
    }

    func updateDisplayPumpRate() {
        frameTimer?.invalidate()
        frameTimer = nil

        guard let interval = targetFrameInterval() else { return }
        currentFrameInterval = interval

        frameTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.frameTick()
        }
    }

    private func frameTick() {
        guard isWindowVisible else {
            frameTimer?.invalidate()
            frameTimer = nil
            return
        }

        if view.processTimeEvents() {
            menuManager.statusDuckAnimator.onTimerVictory()
            persistDebounced()
        }
        view.render()
        if let img = view.makeImage() {
            pushImage(img)
        }

        // Dynamically adjust refresh rate if activity changed
        if let target = targetFrameInterval(), abs(target - currentFrameInterval) > 0.005 {
            updateDisplayPumpRate()
        }
    }

    private func pushImage(_ img: CGImage) {
        guard let layer = host.layer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.contents = img
        layer.contentsGravity = .resizeAspect
        layer.magnificationFilter = .nearest
        CATransaction.commit()
    }

    private func startStatusSyncTimer() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.stats.checkDayRollover()
            if self.view.processTimeEvents() {
                self.menuManager.statusDuckAnimator.onTimerVictory()
                self.persistDebounced()
            }
            self.menuManager.syncStatus()
        }
    }

    // MARK: - State Restoration & Persistence

    private func restoreState() {
        guard let s = Store.load() else { return }
        currentMode = Mode(rawValue: s.mode) ?? .pomodoro

        let iso = ISO8601DateFormatter()
        let swStart = s.swStartISO.flatMap { iso.date(from: $0) }
        sw.restoreState(
            banked: s.swBanked,
            running: s.swRunning,
            startAnchor: swStart,
            splits: s.lapsSplits,
            totals: s.lapsTotals
        )

        let tmEnd = s.tmEndISO.flatMap { iso.date(from: $0) }
        tm.restoreState(
            duration: s.tmDuration,
            remainingAtStop: s.tmRemainingAtStop,
            running: s.tmRunning,
            endWall: tmEnd,
            completionRecorded: s.tmCompletionRecorded ?? false
        )

        let pomoEnd = s.pomoEndISO.flatMap { iso.date(from: $0) }
        pomo.restoreState(
            phase: s.pomoPhase ?? 0,
            cycles: s.pomoCycles ?? 0,
            remainingAtStop: s.pomoRemainingAtStop ?? (s.pomoWorkDuration ?? 1500),
            running: s.pomoRunning ?? false,
            endWall: pomoEnd,
            workDuration: s.pomoWorkDuration ?? (25 * 60),
            shortBreakDuration: s.pomoShortBreakDuration ?? (5 * 60),
            longBreakDuration: s.pomoLongBreakDuration ?? (15 * 60),
            completionRecorded: s.pomoCompletionRecorded ?? false
        )

        if let th = s.theme, let themeType = ThemeType(rawValue: th) {
            ThemeRegistry.current = themeType
        }
        if let h = s.hat, let hatType = DuckHat(rawValue: h) {
            view.currentHat = hatType
        }
        if let sec = s.todayFocusSecs { stats.todayFocusSeconds = sec }
        if let p = s.todayPomos { stats.todayPomodoros = p }
        if let st = s.streakDays { stats.streakDays = st }
        if let l = s.lastActiveDate { stats.lastActiveDateStr = l }
        stats.checkDayRollover()

        UserDefaults.standard.set(s.crt, forKey: "td.crt")
    }

    func persistDebounced() {
        Store.saveDebounced(
            sw: sw, tm: tm, pomo: pomo, stats: stats,
            mode: currentMode, theme: ThemeRegistry.current,
            hat: view.currentHat, crt: view.crtEnabled
        )
    }

    func persistImmediate() {
        Store.saveImmediate(
            sw: sw, tm: tm, pomo: pomo, stats: stats,
            mode: currentMode, theme: ThemeRegistry.current,
            hat: view.currentHat, crt: view.crtEnabled
        )
    }

    // MARK: - Input & Action Handlers

    private func currentViewportTransform() -> ViewportTransform {
        ViewportTransform(hostSize: host.bounds.size, canvasWidth: view.gridW, canvasHeight: view.gridH)
    }

    private func handleClick(_ p: NSPoint) {
        let transform = currentViewportTransform()
        guard let (gx, gy) = transform.hostPointToCanvasPoint(p) else {
            // Click outside the rendered canvas viewport (in letterbox/pillarbox padding)
            return
        }

        // Check button hits
        for b in view.buttons where !b.id.isEmpty {
            if gx >= b.x && gx < b.x + b.w && gy >= b.y && gy < b.y + b.h {
                activate(b.id)
                view.press(b.id)
                return
            }
        }

        // Click duck to pet!
        let dh = view.duckHitRect
        if gx >= dh.x && gx < dh.x + dh.w && gy >= dh.y && gy < dh.y + dh.h {
            view.petDuck()
            updateDisplayPumpRate()
            return
        }

        // Click pond ground to drop breadcrumb (Full mode only)
        if let gh = view.groundHitRect {
            if gx >= gh.x && gx < gh.x + gh.w && gy >= gh.y && gy < gh.y + gh.h {
                view.dropBreadcrumb(at: Double(gx))
                updateDisplayPumpRate()
                return
            }
        }
    }

    private func handleHover(_ p: NSPoint) {
        let transform = currentViewportTransform()
        guard let (gx, gy) = transform.hostPointToCanvasPoint(p) else {
            if view.hoverId != nil {
                view.hoverId = nil
                host.setCursor(NSCursor.arrow)
                host.toolTip = nil
            }
            return
        }

        var hit: String? = nil
        for b in view.buttons where !b.id.isEmpty {
            if gx >= b.x && gx < b.x + b.w && gy >= b.y && gy < b.y + b.h {
                hit = b.id
                break
            }
        }

        if hit == nil {
            let dh = view.duckHitRect
            if gx >= dh.x && gx < dh.x + dh.w && gy >= dh.y && gy < dh.y + dh.h {
                hit = "pet-duck"
            }
        }

        if hit != view.hoverId {
            view.hoverId = hit
            host.setCursor(hit != nil ? NSCursor.pointingHand : NSCursor.arrow)
            if let hit = hit {
                switch hit {
                case "unmini": host.toolTip = "Exit Compact Mode (M)"
                case "tgl-mini": host.toolTip = "Enter Compact Mode (M)"
                case "toggle-sound": host.toolTip = snd.enabled ? "Mute Sound (S)" : "Unmute Sound (S)"
                case "tab-cycle": host.toolTip = "Switch Mode (1/2/3)"
                case "pet-duck": host.toolTip = "Pet Duck (Q)"
                case "clock-area": host.toolTip = "Edit Time (E)"
                case "go": host.toolTip = "Start / Pause (Space)"
                case "sec":
                    switch currentMode {
                    case .pomodoro: host.toolTip = "Skip Phase (L)"
                    case .timer: host.toolTip = "Add 1 Minute (Shift+Up)"
                    case .stopwatch: host.toolTip = sw.isRunning ? "Record Lap (L)" : (sw.elapsed > 0 ? "Reset (R)" : "Record Lap (L)")
                    }
                case "reset": host.toolTip = "Reset / Clear (R)"
                default: host.toolTip = nil
                }
            } else {
                host.toolTip = nil
            }
        }
    }

    func activate(_ id: String) {
        snd.click()
        menuManager.statusDuckAnimator.onUserActivity()
        switch id {
        case "tab-pomo": switchMode(.pomodoro)
        case "tab-tm":   switchMode(.timer)
        case "tab-sw":   switchMode(.stopwatch)
        case "tab-cycle":
            let all = Mode.allCases
            let nextIdx = (currentMode.rawValue + 1) % all.count
            switchMode(all[nextIdx])
        case "pet-duck":
            view.petDuck()
        case "clock-area":
            view.beginTimeEdit()
        case "go":       primaryAction()
        case "sec":      secondaryAction()
        case "reset":    resetAction()
        case "tgl-hat":  cycleHat()
        case "tgl-theme":cycleTheme()
        case "tgl-pin":  togglePin()
        case "tgl-mini", "unmini": toggleMini()
        case "toggle-sound":
            snd.enabled.toggle()
            view.toast(snd.enabled ? "SOUND ON" : "SOUND OFF")
            let quip = view.brain.onSoundToggle(snd.enabled)
            view.speak(quip, duration: 2.0)
            if snd.enabled { snd.quack() }
        case "feed-crumb":
            view.dropBreadcrumb()
        case "preset-1M":  tm.setDuration(60); view.toast("1 MIN"); snd.blip()
        case "preset-3M":  tm.setDuration(3 * 60); view.toast("3 MIN"); snd.blip()
        case "preset-5M":  tm.setDuration(5 * 60); view.toast("5 MIN"); snd.blip()
        case "preset-15M": tm.setDuration(15 * 60); view.toast("15 MIN"); snd.blip()
        case "preset-25M": tm.setDuration(25 * 60); view.toast("25 MIN"); snd.blip()
        case "preset-45M": tm.setDuration(45 * 60); view.toast("45 MIN"); snd.blip()
        case "tm-m1":      adjustTime(-60)
        case "tm-p1":      adjustTime(60)
        case "tm-p5":      adjustTime(300)
        case "pomo-25":    pomo.setWorkDuration(25 * 60); view.toast("POMO 25M"); snd.blip()
        case "pomo-50":    pomo.setWorkDuration(50 * 60); view.toast("DEEP 50M"); snd.blip()
        case "pomo-p1":    adjustTime(60)
        case "pomo-p5":    adjustTime(300)
        case "pomo-skip":  pomo.skipPhase(); view.toast("SKIPPED"); snd.blip()
        default: break
        }
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func adjustTime(_ delta: TimeInterval) {
        menuManager.statusDuckAnimator.onUserActivity()
        guard currentMode == .timer || currentMode == .pomodoro else { return }
        if currentMode == .timer {
            tm.add(delta)
        } else {
            pomo.add(delta)
        }
        let sign = delta >= 0 ? "+" : ""
        let absD = abs(delta)
        let label = absD >= 60 ? "\(sign)\(Int(delta / 60)) MIN" : "\(sign)\(Int(delta)) SEC"
        view.toast(label)
        snd.click()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func primaryAction() {
        menuManager.statusDuckAnimator.onUserActivity()
        switch currentMode {
        case .pomodoro:
            if pomo.finished && !view.alarmDismissed {
                view.dismissAlarm()
                pomo.advancePhase(autoStart: true)
                view.toast("NEXT PHASE")
                let quip = view.brain.onTimerStart(mode: .pomodoro)
                view.speak(quip, duration: 2.2)
                menuManager.statusDuckAnimator.onTimerStart()
                return
            }
            pomo.toggle()
            view.toast(pomo.isRunning ? "FOCUSING" : "PAUSED")
            let quip = pomo.isRunning ? view.brain.onTimerStart(mode: .pomodoro) : view.brain.onTimerPause(mode: .pomodoro)
            view.speak(quip, duration: 2.2)
            if pomo.isRunning { menuManager.statusDuckAnimator.onTimerStart() }

        case .timer:
            if tm.finished && !view.alarmDismissed {
                view.dismissAlarm()
                tm.restart()
                view.toast("CLEARED")
                return
            }
            tm.toggle()
            view.toast(tm.isRunning ? "COUNTING" : "HELD")
            let quip = tm.isRunning ? view.brain.onTimerStart(mode: .timer) : view.brain.onTimerPause(mode: .timer)
            view.speak(quip, duration: 2.2)
            if tm.isRunning { menuManager.statusDuckAnimator.onTimerStart() }

        case .stopwatch:
            if sw.isRunning {
                sw.stop()
                view.toast("PAUSED")
                let quip = view.brain.onTimerPause(mode: .stopwatch)
                view.speak(quip, duration: 2.0)
            } else {
                let wasResumed = sw.banked > 0
                sw.start()
                view.toast(wasResumed ? "RESUMED" : "STARTED")
                let quip = wasResumed ? view.brain.onTimerResume(mode: .stopwatch) : view.brain.onTimerStart(mode: .stopwatch)
                view.speak(quip, duration: 2.0)
            }
        }
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func secondaryAction() {
        menuManager.statusDuckAnimator.onUserActivity()
        switch currentMode {
        case .pomodoro:
            pomo.skipPhase()
            view.toast("PHASE SKIPPED")
            snd.blip()

        case .timer:
            tm.add(60)
            view.toast("+1 MIN")
            snd.blip()

        case .stopwatch:
            if sw.isRunning {
                if let l = sw.lap() {
                    snd.blip()
                    view.duckHop()
                    view.toast(String(format: "LAP %02D %@", l.index, Fmt.lapSplit(l.split)))
                    let quip = view.brain.onLap()
                    view.speak(quip, duration: 2.0)
                }
            } else if sw.elapsed > 0 {
                resetAction()
            } else {
                view.toast("NOT RUNNING")
            }
        }
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func resetAction() {
        menuManager.statusDuckAnimator.onUserActivity()
        switch currentMode {
        case .pomodoro:
            if pomo.finished && !view.alarmDismissed { view.dismissAlarm() }
            pomo.reset()
            view.toast("RESET POMO")

        case .timer:
            if tm.finished && !view.alarmDismissed { view.dismissAlarm() }
            tm.clear()
            view.toast("CLEARED")

        case .stopwatch:
            guard sw.elapsed > 0 else { return }
            sw.reset()
            view.toast("RESET")
        }
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func switchMode(_ m: Mode) {
        menuManager.statusDuckAnimator.onUserActivity()
        currentMode = m
        view.buttons = view.layoutButtons()
        let names = ["STOPWATCH", "TIMER", "POMODORO"]
        view.toast(names[m.rawValue])
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    func cycleHat() {
        let all = DuckHat.allCases
        let nextIdx = (view.currentHat.rawValue + 1) % all.count
        view.currentHat = all[nextIdx]
        view.toast(view.currentHat.displayName)
        view.duckHop()
        let quip = view.brain.onHatChange(view.currentHat)
        view.speak(quip, duration: 2.2)
        updateDisplayPumpRate()
        persistDebounced()
    }

    func cycleTheme() {
        let all = ThemeType.allCases
        let nextIdx = (ThemeRegistry.current.rawValue + 1) % all.count
        ThemeRegistry.current = all[nextIdx]
        view.toast(ThemeRegistry.current.displayName)
        view.rebuildCanvas()
        let quip = view.brain.onThemeChange(ThemeRegistry.current)
        view.speak(quip, duration: 2.2)
        updateDisplayPumpRate()
        persistDebounced()
    }

    func togglePin() {
        let on = !(window.level == .floating)
        window.level = on ? .floating : .normal
        view.setPin(on)
        view.toast(on ? "PINNED ON TOP" : "UNPINNED")
        snd.blip()
    }

    func toggleMini() {
        view.setMini(!view.mini)
        relayoutWindow()
        view.toast(view.mini ? "MINI MODE" : "FULL MODE")
        snd.blip()
    }

    func relayoutWindow() {
        let w = CGFloat(view.gridW * view.scale)
        let h = CGFloat(view.gridH * view.scale)
        var f = window.frame
        let oldSize = window.frame.size
        f.origin.y += oldSize.height - h
        f.size = NSSize(width: w, height: h)
        window.setFrame(f, display: true, animate: false)
        host.frame = NSRect(origin: .zero, size: f.size)
        view.buttons = view.layoutButtons()
        view.rebuildCanvas()
        host.updateTrackingAreas()
        updateDisplayPumpRate()
        frameTick()
    }

    private func handleScrollWheel(_ e: NSEvent) {
        guard currentMode == .timer || currentMode == .pomodoro else { return }
        let delta = e.deltaY < 0 ? 10.0 : -10.0
        if abs(delta) > 0 {
            adjustTime(delta)
        }
    }

    func handleKeyEvent(_ e: NSEvent) -> NSEvent? {
        // Intercept all keyboard input during direct time entry
        if view.isEditingTime {
            if view.handleEditKey(e) {
                updateDisplayPumpRate()
                menuManager.syncStatus()
                persistDebounced()
                return nil
            }
        }

        guard e.charactersIgnoringModifiers != nil else { return e }
        let flags = e.modifierFlags.intersection([.command, .option, .control, .shift, .function])

        // Arrow Key Quick Adjustments
        switch e.keyCode {
        case 126: // Up Arrow
            if e.modifierFlags.contains(.shift) {
                adjustTime(300) // +5 MIN
            } else if e.modifierFlags.contains(.option) {
                adjustTime(10)  // +10 SEC
            } else {
                adjustTime(60)  // +1 MIN
            }
            return nil
        case 125: // Down Arrow
            if e.modifierFlags.contains(.shift) {
                adjustTime(-300) // -5 MIN
            } else if e.modifierFlags.contains(.option) {
                adjustTime(-10)  // -10 SEC
            } else {
                adjustTime(-60)  // -1 MIN
            }
            return nil
        case 124: // Right Arrow
            adjustTime(10) // +10 SEC
            return nil
        case 123: // Left Arrow
            adjustTime(-10) // -10 SEC
            return nil
        default: break
        }

        guard flags.isEmpty || flags == .function else { return e }

        switch e.keyCode {
        case 49: primaryAction()                     // Space
        case 36, 76:                                 // Return
            if view.mini { toggleMini() } else { primaryAction() }
        case 37: secondaryAction()                   // L (Lap/Skip)
        case 15: resetAction()                       // R (Reset)
        case 18: switchMode(.stopwatch)              // 1
        case 19: switchMode(.timer)                  // 2
        case 20: switchMode(.pomodoro)               // 3
        default:
            if let ch = e.characters?.lowercased() {
                switch ch {
                case "e": view.beginTimeEdit(); updateDisplayPumpRate()
                case "+", "=": adjustTime(300)
                case "-", "_": adjustTime(-300)
                case "h": cycleHat()
                case "t": cycleTheme()
                case "q": view.duckHop(); updateDisplayPumpRate()
                case "b": view.dropBreadcrumb(); updateDisplayPumpRate()
                case "p": togglePin()
                case "m": toggleMini()
                case "s": activate("toggle-sound")
                case "c": copySummary()
                case "x": quitApp(nil)
                default: return e
                }
            } else { return e }
        }
        return nil
    }

    func copySummary() {
        var lines: [String] = []
        lines.append("⏱ TimeDuck Summary (@ \(Date()))")
        lines.append("• Today's Focus: \(Fmt.durationWords(stats.todayFocusSeconds))")
        lines.append("• Pomodoro Sessions: \(stats.todayPomodoros)")
        lines.append("• Current Streak: \(stats.streakDays) day(s) 🔥")
        if currentMode == .stopwatch && !sw.laps.isEmpty {
            lines.append("")
            lines.append("Laps:")
            for l in sw.laps {
                lines.append(String(format: "  %02d  split %@  total %@", l.index, Fmt.lapSplit(l.split), Fmt.hm(l.total)))
            }
        }
        let newline = "\u{000A}"
        let txt = lines.joined(separator: newline)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(txt, forType: .string)
        view.toast("SUMMARY COPIED")
        snd.blip()
    }

    // MARK: - Menu Bar Action Bridges

    @objc func showWhatsNew(_ sender: Any?) {
        WhatsNewWindowController.shared.show(
            announcement: WhatsNewCatalog.current,
            snd: snd,
            parentWindow: window,
            acknowledgeOnDismiss: true
        )
    }

    @objc func menuShowTimeDuck(_ sender: Any?) {
        showWindow()
    }

    @objc func showAbout(_ sender: Any?) {
        let alert = NSAlert()
        alert.messageText = AppVersion.fullDisplayString
        alert.informativeText = """
        \(AppVersion.subtitle)

        • Precision stopwatch, countdown timer & Pomodoro focus engine
        • Original TimeDuck Theme soundtrack & procedural 8-bit chiptunes
        • 8 authentic retro CRT color palettes & customizable costumes
        • Playful duck companion with dynamic mood and reactions
        • Zero telemetry, fully offline, native macOS utility

        \(AppVersion.copyright)
        """
        alert.runModal()
    }

    @objc func quitApp(_ sender: Any?) {
        Store.cancelPending()
        persistImmediate()
        NSApp.terminate(nil)
    }

    @objc func menuSelectStopwatch(_ sender: Any?) { switchMode(.stopwatch) }
    @objc func menuSelectTimer(_ sender: Any?)     { switchMode(.timer) }
    @objc func menuSelectPomodoro(_ sender: Any?)  { switchMode(.pomodoro) }

    @objc func menuPlayPause(_ sender: Any?)   { primaryAction() }
    @objc func menuResetTimer(_ sender: Any?)  { resetAction() }
    @objc func menuToggleMini(_ sender: Any?)  { toggleMini() }
    @objc func menuTogglePin(_ sender: Any?)   { togglePin() }
    @objc func toggleSoundMute(_ sender: Any?) { activate("toggle-sound") }

    @objc func toggleMusic(_ sender: Any?) {
        snd.musicEnabled.toggle()
        view.toast(snd.musicEnabled ? "MUSIC ON" : "MUSIC OFF")
        let quip = snd.musicEnabled ? "MUSIC ENGAGED." : "QUIET POND."
        view.speak(quip, duration: 2.0)
        menuManager.syncStatus()
    }

    @objc func menuSelectHat(_ sender: NSMenuItem) {
        if let hat = DuckHat(rawValue: sender.tag) {
            view.currentHat = hat
            view.toast(hat.displayName)
            let quip = view.brain.onHatChange(hat)
            view.speak(quip, duration: 2.2)
            updateDisplayPumpRate()
            persistDebounced()
        }
    }

    @objc func menuSelectTheme(_ sender: NSMenuItem) {
        if let theme = ThemeType(rawValue: sender.tag) {
            ThemeRegistry.current = theme
            view.toast(theme.displayName)
            view.rebuildCanvas()
            let quip = view.brain.onThemeChange(theme)
            view.speak(quip, duration: 2.2)
            updateDisplayPumpRate()
            persistDebounced()
        }
    }

    @objc func quickStart5Min(_ sender: Any?) {
        switchMode(.timer)
        tm.setDuration(5 * 60)
        tm.restart(autoStart: true)
        view.toast("5 MIN TIMER")
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    @objc func quickStart15Min(_ sender: Any?) {
        switchMode(.timer)
        tm.setDuration(15 * 60)
        tm.restart(autoStart: true)
        view.toast("15 MIN TIMER")
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    @objc func quickStart25Min(_ sender: Any?) {
        switchMode(.timer)
        tm.setDuration(25 * 60)
        tm.restart(autoStart: true)
        view.toast("25 MIN TIMER")
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }

    @objc func quickStartPomodoro(_ sender: Any?) {
        switchMode(.pomodoro)
        pomo.reset()
        pomo.setWorkDuration(25 * 60)
        pomo.toggle()
        view.toast("POMODORO FOCUS")
        snd.blip()
        updateDisplayPumpRate()
        menuManager.syncStatus()
        persistDebounced()
    }
}
