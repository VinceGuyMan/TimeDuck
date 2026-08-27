// MARK: - TimeDuck · StatusDuck.swift
// Bespoke micro pixel-art TimeDuck companion living inside the macOS status bar.
// Retina-crisp, template-toggled, energy-efficient micro-animation system.

import Foundation
import AppKit

// MARK: - Status Duck Poses

public enum StatusDuckPose: String, CaseIterable {
    case idle      // Standard proud resting posture
    case blink     // Micro eye-blink
    case lookUp    // Head tilted up looking at timer numbers
    case bob       // Subtle body/head groove bob (music/idle breath)
    case alert     // Perked up posture for timer start / <10s countdown
    case victoryA  // Celebratory hop (wings up)
    case victoryB  // Celebratory hop (wings spread)
    case sleep     // Cozy resting sleep pose
}

// MARK: - Status Duck Sprite Frames

public enum StatusDuckSprite {
    public static let rawFrames: [StatusDuckPose: [String]] = [
        .idle: [
            ".....#####....",
            "...########...",
            "...######.##..",
            "...#######OOO.",
            "..########OO..",
            ".#########....",
            "###.######....",
            "###.#######...",
            ".##.#######...",
            "..########....",
            "...OO...OO...."
        ],
        .blink: [
            ".....#####....",
            "...########...",
            "...#########..",
            "...#######OOO.",
            "..########OO..",
            ".#########....",
            "###.######....",
            "###.#######...",
            ".##.#######...",
            "..########....",
            "...OO...OO...."
        ],
        .lookUp: [
            "....######....",
            "...########...",
            "...######.##..",
            "...########OOO",
            "..########OOO.",
            ".#########....",
            "###.######....",
            "###.#######...",
            ".##.#######...",
            "..########....",
            "...OO...OO...."
        ],
        .bob: [
            "..............",
            ".....#####....",
            "...########...",
            "...######.##..",
            "...#######OOO.",
            "..########OO..",
            "###.######....",
            "###.#######...",
            ".##.#######...",
            "..########....",
            "...OO...OO...."
        ],
        .alert: [
            "....######....",
            "...########...",
            "...######.##..",
            "...#######OOO.",
            "..########....",
            ".#########OO..",
            "###.######....",
            "###.#######...",
            ".##.#######...",
            "..########....",
            "...OO...OO...."
        ],
        .victoryA: [
            "...##...##....",
            ".....#####....",
            "...########...",
            "...######.##..",
            "...#######OOO.",
            "..########OO..",
            ".##########...",
            "..########....",
            "...OO...OO....",
            "..............",
            ".............."
        ],
        .victoryB: [
            "..............",
            ".....#####....",
            "...########...",
            "...######.##..",
            "...#######OOO.",
            "..########OO..",
            "##..####..##..",
            ".##########...",
            "..########....",
            "...OO...OO....",
            ".............."
        ],
        .sleep: [
            "..............",
            ".....#####....",
            "...########...",
            "...######..#..",
            "...#######OOO.",
            "..########OO..",
            ".#########....",
            "###.######....",
            "###.#######...",
            "..########....",
            "...OO...OO...."
        ]
    ]

    // Pre-rendered and cached immutable NSImage instances (18×18 points, template-tinted)
    public static let cachedImages: [StatusDuckPose: NSImage] = {
        var dict: [StatusDuckPose: NSImage] = [:]
        for pose in StatusDuckPose.allCases {
            if let rows = rawFrames[pose] {
                dict[pose] = makeTemplateImage(rows: rows, canvasW: 18, canvasH: 18)
            }
        }
        return dict
    }()

    public static func image(for pose: StatusDuckPose) -> NSImage {
        cachedImages[pose] ?? cachedImages[.idle]!
    }

    private static func makeTemplateImage(rows: [String], canvasW: Int, canvasH: Int) -> NSImage {
        let spriteW = rows[0].count
        let spriteH = rows.count
        let offsetX = (canvasW - spriteW) / 2
        let offsetY = (canvasH - spriteH) / 2

        let img = NSImage(size: NSSize(width: CGFloat(canvasW), height: CGFloat(canvasH)), flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            ctx.setFillColor(NSColor.black.cgColor)
            ctx.setShouldAntialias(false)

            for (r, row) in rows.enumerated() {
                let y = canvasH - 1 - (offsetY + r) // AppKit bottom-left coordinate space
                for (c, ch) in row.enumerated() {
                    let x = offsetX + c
                    if ch == "#" || ch == "O" {
                        ctx.fill(CGRect(x: CGFloat(x), y: CGFloat(y), width: 1, height: 1))
                    }
                }
            }
            return true
        }
        img.isTemplate = true
        return img
    }
}

// MARK: - Status Duck Micro-Animation Coordinator

public final class StatusDuckAnimator {
    public private(set) var currentPose: StatusDuckPose = .idle {
        didSet {
            if oldValue != currentPose {
                onPoseChanged?(StatusDuckSprite.image(for: currentPose))
            }
        }
    }

    public var onPoseChanged: ((NSImage) -> Void)?

    private var actionTimer: Timer?
    private var schedulerTimer: Timer?
    private var lastActivityTime: Date = Date()
    private var isPlayingVictory = false
    private var victoryStep = 0

    public init() {
        scheduleNextIdleAction()
    }

    deinit {
        actionTimer?.invalidate()
        schedulerTimer?.invalidate()
    }

    public var currentImage: NSImage {
        StatusDuckSprite.image(for: currentPose)
    }

    // MARK: - Event Hooks

    public func onUserActivity() {
        lastActivityTime = Date()
        if currentPose == .sleep {
            currentPose = .idle
            scheduleNextIdleAction()
        }
    }

    public func onTimerStart() {
        lastActivityTime = Date()
        guard !isPlayingVictory else { return }
        setTemporaryPose(.alert, duration: 1.6)
    }

    public func onTimerUrgency() {
        lastActivityTime = Date()
        guard !isPlayingVictory else { return }
        if currentPose != .alert {
            currentPose = .alert
        }
    }

    public func onTimerVictory() {
        lastActivityTime = Date()
        startVictoryCelebration()
    }

    public func onMusicBeat() {
        guard currentPose == .idle, !isPlayingVictory else { return }
        setTemporaryPose(.bob, duration: 0.28)
    }

    // MARK: - Idle & Micro-Animation Scheduler

    public func syncState(isTimerRunning: Bool, remaining: TimeInterval, isFinished: Bool, isMusicOn: Bool) {
        if isFinished {
            if !isPlayingVictory {
                startVictoryCelebration()
            }
            return
        }

        if isTimerRunning {
            if remaining <= 10.0 && remaining > 0 {
                onTimerUrgency()
                return
            } else if currentPose == .alert && !isPlayingVictory {
                currentPose = .idle
            }
        }

        // Sleep state after 45s of stillness
        let idleSecs = Date().timeIntervalSince(lastActivityTime)
        if !isTimerRunning && idleSecs > 45.0 && currentPose != .sleep && !isPlayingVictory {
            currentPose = .sleep
        }
    }

    private func scheduleNextIdleAction() {
        schedulerTimer?.invalidate()
        let nextInterval = Double.random(in: 4.5...8.5)

        schedulerTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.performRandomIdleAction()
        }
    }

    private func performRandomIdleAction() {
        guard !isPlayingVictory else { return }

        if currentPose == .sleep {
            // Subtle breath during sleep
            setTemporaryPose(.idle, duration: 0.3) { [weak self] in
                self?.currentPose = .sleep
                self?.scheduleNextIdleAction()
            }
            return
        }

        guard currentPose == .idle else {
            scheduleNextIdleAction()
            return
        }

        let roll = Double.random(in: 0...1)
        if roll < 0.70 {
            // 70% chance: Natural blink
            setTemporaryPose(.blink, duration: 0.14) { [weak self] in
                self?.scheduleNextIdleAction()
            }
        } else if roll < 0.85 {
            // 15% chance: Head tilt / look up
            setTemporaryPose(.lookUp, duration: 0.45) { [weak self] in
                self?.scheduleNextIdleAction()
            }
        } else {
            // 15% chance: Groove bob
            setTemporaryPose(.bob, duration: 0.30) { [weak self] in
                self?.scheduleNextIdleAction()
            }
        }
    }

    private func setTemporaryPose(_ pose: StatusDuckPose, duration: TimeInterval, completion: (() -> Void)? = nil) {
        actionTimer?.invalidate()
        currentPose = pose

        actionTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPlayingVictory {
                self.currentPose = .idle
            }
            completion?()
        }
    }

    private func startVictoryCelebration() {
        guard !isPlayingVictory else { return }
        isPlayingVictory = true
        victoryStep = 1
        currentPose = .victoryA
        actionTimer?.invalidate()

        actionTimer = Timer.scheduledTimer(withTimeInterval: 0.22, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.victoryStep += 1
            self.currentPose = (self.victoryStep % 2 == 1) ? .victoryA : .victoryB

            if self.victoryStep >= 10 { // ~2.2s fanfare celebration
                timer.invalidate()
                self.isPlayingVictory = false
                self.currentPose = .idle
                self.scheduleNextIdleAction()
            }
        }
    }
}
