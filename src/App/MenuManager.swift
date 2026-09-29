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
    private var aiAutoDetectItem: NSMenuItem?

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

        // 4. AI LiveSplit Submenu
        let aiMenuItem = NSMenuItem(title: "AI LiveSplit", action: nil, keyEquivalent: "")
        mainMenu.addItem(aiMenuItem)
        let aiSubmenu = NSMenu(title: "AI LiveSplit")
        let aiAuto = NSMenuItem(title: "Metal/GPU Auto-Detect", action: #selector(delegate.menuToggleGPUAutoDetect(_:)), keyEquivalent: "a")
        aiAuto.state = (delegate.gpuMonitor?.isEnabled ?? false) ? .on : .off
        aiAuto.target = delegate
        aiSubmenu.addItem(aiAuto)
        aiSubmenu.addItem(.separator())
        aiSubmenu.addItem(withTitle: "IPC Port: 1834 (Active)", action: nil, keyEquivalent: "")
        aiSubmenu.addItem(withTitle: "URL Scheme: timeduck://", action: nil, keyEquivalent: "")
        aiMenuItem.submenu = aiSubmenu

        // 5. Companions Submenu
        let compMenuItem = NSMenuItem(title: "Companions", action: nil, keyEquivalent: "")
        mainMenu.addItem(compMenuItem)
        compMenuItem.submenu = createCompanionsSubmenu(delegate: delegate)

        // 5. Costume Submenu
        let hatMenuItem = NSMenuItem(title: "Costume", action: nil, keyEquivalent: "")
        mainMenu.addItem(hatMenuItem)
        hatMenuItem.submenu = createCostumeSubmenu(delegate: delegate)

        // 5. Theme Submenu
        let themeMenuItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        mainMenu.addItem(themeMenuItem)
        themeMenuItem.submenu = createThemeSubmenu(delegate: delegate)

        // 6. Stories Submenu
        let storiesMenuItem = NSMenuItem(title: "Stories", action: nil, keyEquivalent: "")
        mainMenu.addItem(storiesMenuItem)
        storiesMenuItem.submenu = createStoriesSubmenu(delegate: delegate)

        // 7. Window Submenu
        let windowMenuItem = NSMenuItem(title: "Window", action: nil, keyEquivalent: "")
        mainMenu.addItem(windowMenuItem)
        let windowSubmenu = NSMenu(title: "Window")
        windowSubmenu.addItem(withTitle: "Show TimeDuck", action: #selector(delegate.menuShowTimeDuck(_:)), keyEquivalent: "").target = delegate
        windowSubmenu.addItem(withTitle: "Toggle Mini Mode", action: #selector(delegate.menuToggleMini(_:)), keyEquivalent: "m").target = delegate
        windowSubmenu.addItem(withTitle: "Toggle Always On Top", action: #selector(delegate.menuTogglePin(_:)), keyEquivalent: "p").target = delegate
        let splashItem = NSMenuItem(title: "Show Startup Animation", action: #selector(delegate.toggleStartupAnimation(_:)), keyEquivalent: "")
        splashItem.state = (UserDefaults.standard.object(forKey: "td.showStartupSplash") as? Bool ?? true) ? .on : .off
        splashItem.target = delegate
        windowSubmenu.addItem(splashItem)
        windowSubmenu.addItem(.separator())
        windowSubmenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenuItem.submenu = windowSubmenu

        NSApp.mainMenu = mainMenu
    }

    // MARK: - Submenu Generators

    func createCostumeSubmenu(delegate: AppDelegate) -> NSMenu {
        let hatSub = NSMenu(title: "Costume")
        let currentHat = delegate.view.currentHat
        for hat in DuckHat.allCases {
            let item = NSMenuItem(title: hat.displayName, action: #selector(delegate.menuSelectHat(_:)), keyEquivalent: "")
            item.tag = hat.rawValue
            item.state = (hat == currentHat) ? .on : .off
            item.target = delegate
            hatSub.addItem(item)
        }
        return hatSub
    }

    func createThemeSubmenu(delegate: AppDelegate) -> NSMenu {
        let themeSub = NSMenu(title: "Theme")
        let currentTheme = ThemeRegistry.current
        for theme in ThemeType.allCases {
            let item = NSMenuItem(title: theme.displayName, action: #selector(delegate.menuSelectTheme(_:)), keyEquivalent: "")
            item.tag = theme.rawValue
            item.state = (theme == currentTheme) ? .on : .off
            item.target = delegate
            themeSub.addItem(item)
        }
        return themeSub
    }

    func createStoriesSubmenu(delegate: AppDelegate) -> NSMenu {
        let storiesSubmenu = NSMenu(title: "Stories")
        let currentStory = delegate.view.storyEngine.selectedStoryId

        // 1. Auto
        let autoItem = NSMenuItem(title: "Auto", action: #selector(delegate.menuSelectStory(_:)), keyEquivalent: "")
        autoItem.representedObject = DuckStoryId.auto.rawValue
        autoItem.state = (currentStory == .auto) ? .on : .off
        autoItem.target = delegate
        storiesSubmenu.addItem(autoItem)

        // 2. Off
        let offItem = NSMenuItem(title: "Off", action: #selector(delegate.menuSelectStory(_:)), keyEquivalent: "")
        offItem.representedObject = DuckStoryId.off.rawValue
        offItem.state = (currentStory == .off) ? .on : .off
        offItem.target = delegate
        storiesSubmenu.addItem(offItem)

        storiesSubmenu.addItem(.separator())

        // 3. Concrete Stories
        let concreteStories: [DuckStoryId] = [.theFeast, .theExpedition, .nightShift, .theWod, .theRescue]
        for story in concreteStories {
            let item = NSMenuItem(title: story.displayName, action: #selector(delegate.menuSelectStory(_:)), keyEquivalent: "")
            item.representedObject = story.rawValue
            item.state = (story == currentStory) ? .on : .off
            item.target = delegate
            storiesSubmenu.addItem(item)
        }

        storiesSubmenu.addItem(.separator())

        // 4. Story Preview (Developer QA Tooling)
        let previewParentItem = NSMenuItem(title: "Story Preview", action: nil, keyEquivalent: "")
        let previewSubmenu = NSMenu(title: "Story Preview")

        // Speed Multipliers
        let currentSpeed = delegate.view.storySpeedMultiplier
        let speedOptions: [(String, Double)] = [
            ("Speed: 0.25x (Slow-Mo QA)", 0.25),
            ("Speed: 0.5x (Half Speed)", 0.5),
            ("Speed: 1x (Real Time)", 1.0),
            ("Speed: 5x (Fast QA)", 5.0),
            ("Speed: 10x (Ultra QA)", 10.0)
        ]
        for (label, speed) in speedOptions {
            let speedItem = NSMenuItem(title: label, action: #selector(delegate.menuSetStorySpeedMultiplier(_:)), keyEquivalent: "")
            speedItem.representedObject = speed
            speedItem.state = (abs(currentSpeed - speed) < 0.05) ? .on : .off
            speedItem.target = delegate
            previewSubmenu.addItem(speedItem)
        }

        previewSubmenu.addItem(.separator())

        let storySceneMap: [DuckStoryId: [(String, Double)]] = [
            .theFeast: [
                ("Stage 1: Light Appetite (0%)", 0.0),
                ("Stage 2: Satisfied (20%)", 0.20),
                ("Stage 3: Notable Chonk (40%)", 0.40),
                ("Stage 4: Heavy Unit (60%)", 0.60),
                ("Stage 5: Absolute Unit (80%)", 0.80),
                ("Preview Finale (Digestion & Settle)", 1.00)
            ],
            .theExpedition: [
                ("Scene 1: Trailhead (0%)", 0.0),
                ("Scene 2: Campfire (20%)", 0.20),
                ("Scene 3: The Climb (40%)", 0.40),
                ("Scene 4: Final Ascent (60%)", 0.60),
                ("Scene 5: Summit (80%)", 0.80),
                ("Preview Finale (Flag & Resting Summit)", 1.00)
            ],
            .nightShift: [
                ("Scene 1: Shift Start (0%)", 0.0),
                ("Scene 2: First Yawn (20%)", 0.20),
                ("Scene 3: Fighting Droop (40%)", 0.40),
                ("Scene 4: Blanket Battle (60%)", 0.60),
                ("Scene 5: Final Stretch (80%)", 0.80),
                ("Preview Finale (Shift Done & Sleep Loop)", 1.00)
            ],
            .theWod: [
                ("Scene 1: Warmup & Board (0%)", 0.0),
                ("Scene 2: Elliptical (20%)", 0.20),
                ("Scene 3: Treadmill (40%)", 0.40),
                ("Scene 4: Dumbbells (60%)", 0.60),
                ("Scene 5: Flex Victory (80%)", 0.80),
                ("Preview Finale (Cooldown & Resting Gym)", 1.00)
            ],
            .theRescue: [
                ("Scene 1: Infiltration (0%)", 0.0),
                ("Scene 2: Cameras (20%)", 0.20),
                ("Scene 3: Guard Patrol (40%)", 0.40),
                ("Scene 4: Girl Duck (60%)", 0.60),
                ("Scene 5: Escape Sprint (80%)", 0.80),
                ("Preview Finale (Freedom Duo Tableau)", 1.00)
            ]
        ]

        let transitions: [(String, Double)] = [
            ("Scene 1 → 2 (19%)", 0.19),
            ("Scene 2 → 3 (39%)", 0.39),
            ("Scene 3 → 4 (59%)", 0.59),
            ("Scene 4 → 5 (79%)", 0.79),
            ("Scene 5 → Finale (99%)", 0.99)
        ]

        for story in concreteStories {
            let storyItem = NSMenuItem(title: story.displayName, action: nil, keyEquivalent: "")
            let msSub = NSMenu(title: story.displayName)
            let checkpoints = storySceneMap[story] ?? [("0%", 0.0), ("100%", 1.0)]
            for (label, p) in checkpoints {
                let stepItem = NSMenuItem(title: label, action: #selector(delegate.menuPreviewStoryMilestone(_:)), keyEquivalent: "")
                stepItem.representedObject = ["story": story.rawValue, "progress": p] as [String: Any]
                stepItem.target = delegate
                msSub.addItem(stepItem)
            }

            msSub.addItem(.separator())
            let transSubItem = NSMenuItem(title: "Transitions", action: nil, keyEquivalent: "")
            let transSub = NSMenu(title: "Transitions")
            for (tLabel, p) in transitions {
                let item = NSMenuItem(title: tLabel, action: #selector(delegate.menuPreviewStoryTransition(_:)), keyEquivalent: "")
                item.representedObject = ["story": story.rawValue, "startProgress": p] as [String: Any]
                item.target = delegate
                transSub.addItem(item)
            }
            transSubItem.submenu = transSub
            msSub.addItem(transSubItem)

            storyItem.submenu = msSub
            previewSubmenu.addItem(storyItem)
        }

        previewSubmenu.addItem(.separator())

        // Quick Finale QA Submenu
        let finaleQAItem = NSMenuItem(title: "Finale QA (Resting Loops)", action: nil, keyEquivalent: "")
        let finaleQASub = NSMenu(title: "Finale QA")
        for story in concreteStories {
            let item = NSMenuItem(title: "\(story.displayName) Finale", action: #selector(delegate.menuPreviewStoryFinale(_:)), keyEquivalent: "")
            item.representedObject = story.rawValue
            item.target = delegate
            finaleQASub.addItem(item)
        }
        finaleQAItem.submenu = finaleQASub
        previewSubmenu.addItem(finaleQAItem)

        // Quick Transition QA Submenu
        let transQAItem = NSMenuItem(title: "Transition QA", action: nil, keyEquivalent: "")
        let transQASub = NSMenu(title: "Transition QA")
        for story in concreteStories {
            let storyTransItem = NSMenuItem(title: story.displayName, action: nil, keyEquivalent: "")
            let sTransMenu = NSMenu(title: story.displayName)
            for (tLabel, p) in transitions {
                let item = NSMenuItem(title: tLabel, action: #selector(delegate.menuPreviewStoryTransition(_:)), keyEquivalent: "")
                item.representedObject = ["story": story.rawValue, "startProgress": p] as [String: Any]
                item.target = delegate
                sTransMenu.addItem(item)
            }
            storyTransItem.submenu = sTransMenu
            transQASub.addItem(storyTransItem)
        }
        transQAItem.submenu = transQASub
        previewSubmenu.addItem(transQAItem)

        previewSubmenu.addItem(.separator())
        let viewportToggle = NSMenuItem(
            title: delegate.view.mini ? "Viewport: MiniHUD ✓" : "Viewport: Full Window",
            action: #selector(delegate.menuTogglePreviewViewport(_:)),
            keyEquivalent: ""
        )
        viewportToggle.target = delegate
        previewSubmenu.addItem(viewportToggle)

        let clearPrev = NSMenuItem(title: "Clear Preview", action: #selector(delegate.menuClearStoryPreview(_:)), keyEquivalent: "")
        clearPrev.target = delegate
        previewSubmenu.addItem(clearPrev)
        previewParentItem.submenu = previewSubmenu
        storiesSubmenu.addItem(previewParentItem)

        return storiesSubmenu
    }

    // MARK: - Status Bar Item

    func buildStatusItem() {
        guard let delegate = appDelegate else { return }
        let item = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
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

        let aiAuto = NSMenuItem(title: "AI Auto-Detect (Metal/GPU)", action: #selector(delegate.menuToggleGPUAutoDetect(_:)), keyEquivalent: "")
        aiAuto.target = delegate
        aiAuto.state = (delegate.gpuMonitor?.isEnabled ?? false) ? .on : .off
        menu.addItem(aiAuto)
        aiAutoDetectItem = aiAuto

        // Companions Submenu in Status Menu
        let compItem = NSMenuItem(title: "Companions", action: nil, keyEquivalent: "")
        compItem.submenu = createCompanionsSubmenu(delegate: delegate)
        menu.addItem(compItem)

        // Theme Submenu in Status Menu
        let themeItem = NSMenuItem(title: "Theme", action: nil, keyEquivalent: "")
        themeItem.submenu = createThemeSubmenu(delegate: delegate)
        menu.addItem(themeItem)

        // Costume Submenu in Status Menu
        let hatItem = NSMenuItem(title: "Costume", action: nil, keyEquivalent: "")
        hatItem.submenu = createCostumeSubmenu(delegate: delegate)
        menu.addItem(hatItem)

        // Stories Submenu in Status Menu
        let storiesItem = NSMenuItem(title: "Stories", action: nil, keyEquivalent: "")
        storiesItem.submenu = createStoriesSubmenu(delegate: delegate)
        menu.addItem(storiesItem)

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
        aiAutoDetectItem?.state = (delegate.gpuMonitor?.isEnabled ?? false) ? .on : .off
    }

    func createCompanionsSubmenu(delegate: AppDelegate) -> NSMenu {
        let compSub = NSMenu(title: "Companions")
        let activeId = TimeCompanionRegistry.shared.activeCompanionId

        for comp in TimeCompanionRegistry.shared.allCompanions {
            let isUnlocked = TimeCompanionRegistry.shared.isUnlocked(comp.id)
            let title = isUnlocked ? comp.displayName : (comp.isSecret ? "??? (Secret)" : "\(comp.displayName) (Locked)")
            let item = NSMenuItem(title: title, action: #selector(delegate.menuSelectCompanion(_:)), keyEquivalent: "")
            item.representedObject = comp.id.rawValue
            item.state = (comp.id == activeId) ? .on : .off
            item.isEnabled = isUnlocked
            item.target = delegate
            compSub.addItem(item)
        }
        compSub.addItem(.separator())
        let bookItem = NSMenuItem(title: "Open Duckbook…", action: #selector(delegate.menuOpenDuckbook(_:)), keyEquivalent: "d")
        bookItem.target = delegate
        compSub.addItem(bookItem)

        #if DEBUG
        compSub.addItem(.separator())
        let devStatus = DeveloperOverride.shared.isUnlockAllActive ? "✓ Dev: Unlock Everything (Active)" : "Dev: Unlock Everything (QA)"
        let devToggle = NSMenuItem(title: devStatus, action: #selector(delegate.menuToggleDevUnlockAll(_:)), keyEquivalent: "")
        devToggle.target = delegate
        compSub.addItem(devToggle)

        let devReset = NSMenuItem(title: "Dev: Reset Progression to Genuine", action: #selector(delegate.menuResetDevProgression(_:)), keyEquivalent: "")
        devReset.target = delegate
        compSub.addItem(devReset)
        #endif

        return compSub
    }

}
