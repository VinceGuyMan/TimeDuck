// MARK: - TimeDuck · MenuManager.swift
// Main application menu bar and system status bar item integration.

import Foundation
import AppKit

final class MenuManager: NSObject {
    private weak var appDelegate: AppDelegate?
    let statusDuckAnimator = StatusDuckAnimator()
    private var statusItem: NSStatusItem?
    private var statusHeaderItem: NSMenuItem?
    private var statsSummaryItem: NSMenuItem?
    private var soundToggleItem: NSMenuItem?
    private var musicToggleItem: NSMenuItem?

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
    }

    func setup() {
        buildMainMenu()
        buildStatusItem()
    }

    // MARK: - Main Application Menu

    func buildMainMenu() {
        guard let delegate = appDelegate else { return }
        let mainMenu = NSMenu()

        // 1. App Submenu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appSubmenu = NSMenu()
        appSubmenu.addItem(withTitle: "About TimeDuck", action: #selector(delegate.showAbout(_:)), keyEquivalent: "").target = delegate
        appSubmenu.addItem(withTitle: "What's New in TimeDuck…", action: #selector(delegate.showWhatsNew(_:)), keyEquivalent: "").target = delegate
        appSubmenu.addItem(.separator())
        appSubmenu.addItem(withTitle: "Hide TimeDuck", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appSubmenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h").keyEquivalentModifierMask = [.command, .option]
        appSubmenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appSubmenu.addItem(.separator())
        appSubmenu.addItem(withTitle: "Quit TimeDuck", action: #selector(delegate.quitApp(_:)), keyEquivalent: "q").target = delegate
        appMenuItem.submenu = appSubmenu

        // 2. Mode Submenu
        let modeMenuItem = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        mainMenu.addItem(modeMenuItem)
        let modeSubmenu = NSMenu(title: "Mode")
        let m1 = NSMenuItem(title: "Stopwatch", action: #selector(delegate.menuSelectStopwatch(_:)), keyEquivalent: "1")
        m1.target = delegate
        let m2 = NSMenuItem(title: "Countdown Timer", action: #selector(delegate.menuSelectTimer(_:)), keyEquivalent: "2")
        m2.target = delegate
        let m3 = NSMenuItem(title: "Pomodoro Focus", action: #selector(delegate.menuSelectPomodoro(_:)), keyEquivalent: "3")
        m3.target = delegate
        modeSubmenu.addItem(m1)
        modeSubmenu.addItem(m2)
        modeSubmenu.addItem(m3)
        modeMenuItem.submenu = modeSubmenu

        // 3. Audio Submenu
        let audioMenuItem = NSMenuItem(title: "Audio", action: nil, keyEquivalent: "")
        mainMenu.addItem(audioMenuItem)
        let audioSubmenu = NSMenu(title: "Audio")
        audioSubmenu.addItem(withTitle: "Theme Music", action: #selector(delegate.toggleMusic(_:)), keyEquivalent: "").target = delegate
        audioSubmenu.addItem(withTitle: "Sound Effects", action: #selector(delegate.toggleSoundMute(_:)), keyEquivalent: "").target = delegate
        audioMenuItem.submenu = audioSubmenu

        // 4. Costume Submenu
        let hatMenuItem = NSMenuItem(title: "Costume", action: nil, keyEquivalent: "")
        mainMenu.addItem(hatMenuItem)
        let hatSubmenu = NSMenu(title: "Costume")
        for hat in DuckHat.allCases {
            let item = NSMenuItem(title: hat.displayName, action: #selector(delegate.menuSelectHat(_:)), keyEquivalent: "")
            item.tag = hat.rawValue
            item.target = delegate
            hatSubmenu.addItem(item)
        }
        hatMenuItem.submenu = hatSubmenu

        // 5. Theme Submenu
        let themeMenuItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        mainMenu.addItem(themeMenuItem)
        let themeSubmenu = NSMenu(title: "Theme")
        for theme in ThemeType.allCases {
            let item = NSMenuItem(title: theme.displayName, action: #selector(delegate.menuSelectTheme(_:)), keyEquivalent: "")
            item.tag = theme.rawValue
            item.target = delegate
            themeSubmenu.addItem(item)
        }
        themeMenuItem.submenu = themeSubmenu

        // 6. Window Submenu
        let windowMenuItem = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        mainMenu.addItem(windowMenuItem)
        let windowSubmenu = NSMenu(title: "Window")
        windowSubmenu.addItem(withTitle: "Show TimeDuck", action: #selector(delegate.menuShowTimeDuck(_:)), keyEquivalent: "").target = delegate
        windowSubmenu.addItem(withTitle: "Toggle Mini Mode", action: #selector(delegate.menuToggleMini(_:)), keyEquivalent: "m").target = delegate
        windowSubmenu.addItem(withTitle: "Toggle Always On Top", action: #selector(delegate.menuTogglePin(_:)), keyEquivalent: "p").target = delegate
        windowSubmenu.addItem(.separator())
        windowSubmenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenuItem.submenu = windowSubmenu

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Status Bar Item

    func buildStatusItem() {
        guard let delegate = appDelegate else { return }
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = statusDuckAnimator.currentImage
            button.imagePosition = .imageOnly
            button.title = ""
            button.toolTip = "TimeDuck"
        }

        statusDuckAnimator.onPoseChanged = { [weak self] img in
            self?.statusItem?.button?.image = img
        }

        let menu = NSMenu()

        // 1. Show TimeDuck (Direct, reliable window foregrounding option at top)
        let showWin = NSMenuItem(title: "Show TimeDuck", action: #selector(delegate.menuShowTimeDuck(_:)), keyEquivalent: "")
        showWin.target = delegate
        menu.addItem(showWin)

        menu.addItem(.separator())

        let header = NSMenuItem(title: "TimeDuck Ready", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        statusHeaderItem = header

        let stats = NSMenuItem(title: "Today: 0 pomos · 0m focus", action: nil, keyEquivalent: "")
        stats.isEnabled = false
        menu.addItem(stats)
        statsSummaryItem = stats

        menu.addItem(.separator())

        // Quick Preset Timers
        let quickHeader = NSMenuItem(title: "Quick Timers", action: nil, keyEquivalent: "")
        quickHeader.isEnabled = false
        menu.addItem(quickHeader)

        let q5 = NSMenuItem(title: "Start 5 Minutes", action: #selector(delegate.quickStart5Min(_:)), keyEquivalent: "")
        q5.target = delegate
        menu.addItem(q5)

        let q15 = NSMenuItem(title: "Start 15 Minutes", action: #selector(delegate.quickStart15Min(_:)), keyEquivalent: "")
        q15.target = delegate
        menu.addItem(q15)

        let q25 = NSMenuItem(title: "Start 25 Minutes", action: #selector(delegate.quickStart25Min(_:)), keyEquivalent: "")
        q25.target = delegate
        menu.addItem(q25)

        let qPomo = NSMenuItem(title: "Start Pomodoro (25m Focus)", action: #selector(delegate.quickStartPomodoro(_:)), keyEquivalent: "")
        qPomo.target = delegate
        menu.addItem(qPomo)

        menu.addItem(.separator())

        let pauseResume = NSMenuItem(title: "Play / Pause", action: #selector(delegate.menuPlayPause(_:)), keyEquivalent: " ")
        pauseResume.target = delegate
        menu.addItem(pauseResume)

        let reset = NSMenuItem(title: "Reset Timer", action: #selector(delegate.menuResetTimer(_:)), keyEquivalent: "r")
        reset.target = delegate
        menu.addItem(reset)

        menu.addItem(.separator())

        // Audio & Preferences
        let music = NSMenuItem(title: "Theme Music", action: #selector(delegate.toggleMusic(_:)), keyEquivalent: "")
        music.target = delegate
        music.state = delegate.snd.musicEnabled ? .on : .off
        menu.addItem(music)
        musicToggleItem = music

        let sound = NSMenuItem(title: "Sound Effects", action: #selector(delegate.toggleSoundMute(_:)), keyEquivalent: "")
        sound.target = delegate
        sound.state = delegate.snd.enabled ? .on : .off
        menu.addItem(sound)
        soundToggleItem = sound

        // Theme Submenu in Menu Bar
        let themeItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        let themeSub = NSMenu()
        for theme in ThemeType.allCases {
            let sub = NSMenuItem(title: theme.displayName, action: #selector(delegate.menuSelectTheme(_:)), keyEquivalent: "")
            sub.tag = theme.rawValue
            sub.target = delegate
            themeSub.addItem(sub)
        }
        themeItem.submenu = themeSub
        menu.addItem(themeItem)

        // Costume Submenu in Menu Bar
        let hatItem = NSMenuItem(title: "Costume", action: nil, keyEquivalent: "")
        let hatSub = NSMenu()
        for hat in DuckHat.allCases {
            let sub = NSMenuItem(title: hat.displayName, action: #selector(delegate.menuSelectHat(_:)), keyEquivalent: "")
            sub.tag = hat.rawValue
            sub.target = delegate
            hatSub.addItem(sub)
        }
        hatItem.submenu = hatSub
        menu.addItem(hatItem)

        menu.addItem(.separator())

        let whatsNew = NSMenuItem(title: "What's New in TimeDuck…", action: #selector(delegate.showWhatsNew(_:)), keyEquivalent: "")
        whatsNew.target = delegate
        menu.addItem(whatsNew)

        let about = NSMenuItem(title: "About TimeDuck", action: #selector(delegate.showAbout(_:)), keyEquivalent: "")
        about.target = delegate
        menu.addItem(about)

        let quit = NSMenuItem(title: "Quit TimeDuck", action: #selector(delegate.quitApp(_:)), keyEquivalent: "q")
        quit.target = delegate
        menu.addItem(quit)

        item.menu = menu
        statusItem = item
    }

    // MARK: - Live Status Sync

    func syncStatus() {
        guard let delegate = appDelegate, let item = statusItem else { return }

        let fullTitle: String
        let isRunning: Bool
        let remaining: TimeInterval
        let isFinished: Bool

        switch delegate.currentMode {
        case .pomodoro:
            isFinished = delegate.pomo.finished && !delegate.view.alarmDismissed
            isRunning = delegate.pomo.isRunning
            remaining = delegate.pomo.remaining
            if isFinished {
                fullTitle = "Pomodoro · Complete! Take a break"
            } else if isRunning {
                let line = Fmt.tm(delegate.pomo.remaining, drama: false)
                fullTitle = "\(delegate.pomo.phase.title) · \(line)"
            } else {
                fullTitle = "Pomodoro Focus (Paused)"
            }

        case .timer:
            isFinished = delegate.tm.finished && !delegate.view.alarmDismissed
            isRunning = delegate.tm.isRunning
            remaining = delegate.tm.remaining
            if isFinished {
                fullTitle = "Timer · Time's Up!"
            } else if isRunning {
                let line = Fmt.tm(delegate.tm.remaining, drama: false)
                fullTitle = "Timer · \(line)"
            } else {
                fullTitle = "Countdown Timer (Paused)"
            }

        case .stopwatch:
            isFinished = false
            isRunning = delegate.sw.isRunning
            remaining = 999
            if isRunning {
                let line = Fmt.sw(delegate.sw.elapsed)
                fullTitle = "Stopwatch · \(line)"
            } else {
                fullTitle = "Stopwatch (Paused)"
            }
        }

        // The normal macOS menu bar presence is the animated TimeDuck ONLY (no text)
        item.button?.title = ""
        item.button?.image = statusDuckAnimator.currentImage
        statusDuckAnimator.syncState(
            isTimerRunning: isRunning,
            remaining: remaining,
            isFinished: isFinished,
            isMusicOn: delegate.snd.musicEnabled
        )

        statusHeaderItem?.title = fullTitle
        statsSummaryItem?.title = "Today: \(delegate.stats.todayPomodoros) pomos · \(Fmt.durationWords(delegate.stats.todayFocusSeconds)) focus"
        soundToggleItem?.state = delegate.snd.enabled ? .on : .off
        musicToggleItem?.state = delegate.snd.musicEnabled ? .on : .off
    }
}
