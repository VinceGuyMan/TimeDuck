// MARK: - TimeDuck · WhatsNew.swift
// Reusable, version-aware release announcement and "What's Next" update popup system.

import Foundation
import AppKit
import QuartzCore

// MARK: - Data Models

struct ReleaseHighlight: Equatable {
    let title: String
    let description: String
    let badge: String?

    init(title: String, description: String, badge: String? = nil) {
        self.title = title
        self.description = description
        self.badge = badge
    }
}

struct ReleaseAnnouncement: Equatable {
    let version: String
    let title: String
    let subtitle: String
    let highlightsTitle: String
    let highlights: [ReleaseHighlight]
    let nextVersion: String?
    let nextTitle: String?
    let nextSubtitle: String?
    let nextTeasers: [String]?

    var hasNextPreview: Bool {
        guard let teasers = nextTeasers, !teasers.isEmpty else { return false }
        return nextVersion != nil || nextTitle != nil
    }
}

// MARK: - Release Catalog

enum WhatsNewCatalog {
    static let v1_1_0 = ReleaseAnnouncement(
        version: "1.1.0",
        title: "TIMEDUCK v1.1",
        subtitle: "TACTICAL & EXPRESSIVE",
        highlightsTitle: "WHAT'S NEW IN v1.1",
        highlights: [
            ReleaseHighlight(
                title: "4 TACTICAL BANDANAS",
                description: "Midnight, Crimson, Forest & Desert",
                badge: "GEAR"
            ),
            ReleaseHighlight(
                title: "2 NEW DUCK EXPRESSIONS",
                description: "Feather Ruffle & Curious Peek poses",
                badge: "MOOD"
            ),
            ReleaseHighlight(
                title: "3 NEW CRT THEMES",
                description: "Terminal Green (VT220), Paperwhite & Electric",
                badge: "CRT"
            ),
            ReleaseHighlight(
                title: "EXPANDED PHRASES",
                description: "20+ situation-aware quips with memory",
                badge: "VOICE"
            )
        ],
        nextVersion: "1.2.0",
        nextTitle: "COMING NEXT · v1.2",
        nextSubtitle: "SECRET LIVING",
        nextTeasers: [
            "• Costumes that react in new ways",
            "• Rare secret events & surprises",
            "• Expanded soundtrack & duck secrets",
            "\"Your duck has secrets to discover.\""
        ]
    )

    static func announcement(for version: String) -> ReleaseAnnouncement? {
        if version == "1.1.0" || version.hasPrefix("1.1") {
            return v1_1_0
        }
        return nil
    }

    static var current: ReleaseAnnouncement {
        announcement(for: AppVersion.version) ?? v1_1_0
    }
}

// MARK: - Version-Aware Persistence Manager

final class WhatsNewManager {
    static let shared = WhatsNewManager()
    static let defaultsKey = "td.lastSeenWhatsNewVersion"

    var lastSeenVersion: String? {
        get {
            UserDefaults.standard.string(forKey: Self.defaultsKey)
        }
        set {
            if let val = newValue {
                UserDefaults.standard.set(val, forKey: Self.defaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.defaultsKey)
            }
        }
    }

    func shouldPresentAutomatically(currentVersion: String = AppVersion.version) -> Bool {
        guard let last = lastSeenVersion else {
            return true
        }
        return last != currentVersion
    }

    func markAcknowledged(version: String = AppVersion.version) {
        lastSeenVersion = version
    }

    func resetAcknowledgment() {
        lastSeenVersion = nil
    }
}

// MARK: - Presentation Coordinator & Window Controller

final class WhatsNewWindowController: NSObject, NSWindowDelegate {
    static let shared = WhatsNewWindowController()

    private var window: NSWindow?
    private var host: PixelHostView?
    private var canvas: PixelCanvas?
    private var ctx: CGContext?
    private var frameTimer: Timer?
    private weak var snd: SoundEngine?
    private var announcement: ReleaseAnnouncement = WhatsNewCatalog.current
    private var isAcknowledgedOnClose = true

    // Canvas layout dimensions (spacious 250×175 grid for clean, non-overlapping pixel layout)
    private let gridW = 250
    private let gridH = 175
    private let scale = 3
    private var isHoveringButton = false
    private var isHoveringClose = false
    private var animationStartTime = Date()

    // Button hit boundaries (canvas space)
    private var continueBtnRect: (x: Int, y: Int, w: Int, h: Int) {
        (x: 55, y: 153, w: 140, h: 16)
    }

    private var closeBtnRect: (x: Int, y: Int, w: Int, h: Int) {
        (x: gridW - 16, y: 4, w: 12, h: 10)
    }

    func show(
        announcement: ReleaseAnnouncement = WhatsNewCatalog.current,
        snd: SoundEngine? = nil,
        parentWindow: NSWindow? = nil,
        acknowledgeOnDismiss: Bool = true
    ) {
        self.announcement = announcement
        self.snd = snd
        self.isAcknowledgedOnClose = acknowledgeOnDismiss
        self.animationStartTime = Date()

        if window == nil {
            setupWindow()
        }

        guard let win = window else { return }
        win.center()
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        startAnimationPump()
        renderFrame()
    }

    private func setupWindow() {
        let frame = NSRect(x: 0, y: 0, width: gridW * scale, height: gridH * scale)
        let canvas = PixelCanvas(w: gridW, h: gridH)
        self.canvas = canvas

        guard let c = CGContext(
            data: UnsafeMutableRawPointer(canvas.p),
            width: gridW,
            height: gridH,
            bitsPerComponent: 8,
            bytesPerRow: gridW * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        self.ctx = c

        let host = PixelHostView(frame: frame)
        host.wantsLayer = true
        host.onClick = { [weak self] p in self?.handleClick(p) }
        host.onHover = { [weak self] p in self?.handleHover(p) }
        self.host = host

        let win = NSWindow(
            contentRect: frame,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "\(AppVersion.appName) · What's New"
        win.contentView = host
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = true
        win.level = .floating
        win.delegate = self
        self.window = win

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            guard let self = self, let w = self.window, w.isKeyWindow else { return e }
            if e.keyCode == 49 || e.keyCode == 36 || e.keyCode == 76 || e.keyCode == 53 { // Space, Return, Enter, Esc
                self.dismissAndAcknowledge()
                return nil
            }
            return e
        }
    }

    private func startAnimationPump() {
        frameTimer?.invalidate()
        frameTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 15.0, repeats: true) { [weak self] _ in
            self?.renderFrame()
        }
    }

    private func stopAnimationPump() {
        frameTimer?.invalidate()
        frameTimer = nil
    }

    private func renderFrame() {
        guard let canvas = canvas, let ctx = ctx, host != nil else { return }
        let now = Date()
        let t = now.timeIntervalSince(animationStartTime)

        canvas.fillAll(Pal.bgDeep)

        // Outer Bezel Frame
        canvas.frameRect(0, 0, gridW, gridH, Pal.grid)
        canvas.frameRect(1, 1, gridW - 2, gridH - 2, Pal.panel)

        // Top Titlebar
        canvas.hline(1, gridW - 2, 18, Pal.grid)
        canvas.smallText(announcement.title, x: 8, y: 5, c: Pal.white)
        canvas.smallText(announcement.subtitle, x: 8, y: 11, c: Pal.green)

        // Top-Right Close Button [X]
        let cr = closeBtnRect
        if isHoveringClose {
            canvas.fillRect(cr.x, cr.y, cr.w, cr.h, Pal.redDim)
        }
        canvas.frameRect(cr.x, cr.y, cr.w, cr.h, isHoveringClose ? Pal.red : Pal.grid)
        canvas.smallText("X", x: cr.x + 4, y: cr.y + 2, c: isHoveringClose ? Pal.white : Pal.inkDim)

        // ── Left Column: Live Visual Showcase (x: 8..72, w: 64) ─────────────

        // Box 1: Duck Costume Showcase (x: 8, y: 22, w: 64, h: 62)
        canvas.fillRect(8, 22, 64, 62, Pal.panel)
        canvas.frameRect(8, 22, 64, 62, Pal.grid)

        // Dynamic Bandana Costume Cycle (Midnight, Crimson, Forest, Desert)
        let bandanaIndex = Int(t / 2.0) % 4
        let currentBandanaName: String
        let currentBandanaRows: [String]
        switch bandanaIndex {
        case 0:
            currentBandanaName = "MIDNIGHT"
            currentBandanaRows = HAT_BANDANA_MIDNIGHT
        case 1:
            currentBandanaName = "CRIMSON"
            currentBandanaRows = HAT_BANDANA_CRIMSON
        case 2:
            currentBandanaName = "FOREST"
            currentBandanaRows = HAT_BANDANA_FOREST
        default:
            currentBandanaName = "DESERT"
            currentBandanaRows = HAT_BANDANA_DESERT
        }

        // Live duck animation cycle
        let animStep = Int(t * 3) % 4
        let duckRows: [String]
        if animStep == 0 {
            duckRows = DUCK_BASE
        } else if animStep == 1 {
            duckRows = DUCK_RUFFLE_A
        } else if animStep == 2 {
            duckRows = DUCK_PEEK_A
        } else {
            duckRows = DUCK_IDLE_B
        }

        let duckX = 33
        let duckY = 34
        canvas.drawSprite(duckRows, x: duckX, y: duckY, map: getDuckColorMap(), flip: false)
        let hatY = duckY - 4
        canvas.drawSprite(currentBandanaRows, x: duckX, y: hatY, map: getDuckColorMap(), flip: false)

        let gearLabel = "GEAR: \(currentBandanaName)"
        let gearW = PixelCanvas.smallWidth(gearLabel)
        canvas.smallText(gearLabel, x: 8 + (64 - gearW) / 2, y: 58, c: Pal.amber)
        canvas.smallText("4 BANDANAS", x: 8 + (64 - PixelCanvas.smallWidth("4 BANDANAS")) / 2, y: 70, c: Pal.inkDim)

        // Box 2: Palette Swatch Box (x: 8, y: 88, w: 64, h: 56)
        canvas.fillRect(8, 88, 64, 56, Pal.panel)
        canvas.frameRect(8, 88, 64, 56, Pal.grid)
        canvas.smallText("3 CRT PALETTES", x: 11, y: 92, c: Pal.cyan)

        // Row 1: Terminal Green swatch
        canvas.fillRect(12, 104, 10, 6, rgb(4, 16, 6))
        canvas.frameRect(12, 104, 10, 6, rgb(51, 255, 51))
        canvas.smallText("TERMINAL", x: 26, y: 105, c: rgb(51, 255, 51))

        // Row 2: Paperwhite swatch
        canvas.fillRect(12, 118, 10, 6, rgb(238, 242, 246))
        canvas.frameRect(12, 118, 10, 6, rgb(18, 28, 42))
        canvas.smallText("PAPERWHITE", x: 26, y: 119, c: Pal.white)

        // Row 3: Electric Pond swatch
        canvas.fillRect(12, 132, 10, 6, rgb(8, 14, 26))
        canvas.frameRect(12, 132, 10, 6, rgb(0, 240, 255))
        canvas.smallText("E-POND", x: 26, y: 133, c: rgb(0, 240, 255))

        // ── Right Column: WHAT'S NEW & WHAT'S NEXT (x: 78..242, w: 164) ──────
        let rightX = 78

        // Section 1: WHAT'S NEW IN v1.1 (y: 22..85)
        canvas.smallText("▸ \(announcement.highlightsTitle)", x: rightX, y: 22, c: Pal.amber)

        var hy = 30
        for h in announcement.highlights.prefix(4) {
            canvas.smallText("• \(h.title)", x: rightX + 4, y: hy, c: Pal.white)
            canvas.smallText(h.description, x: rightX + 8, y: hy + 6, c: Pal.inkDim)
            hy += 14
        }

        // Section 2: WHAT'S NEXT (Preview only, clearly differentiated, y: 91..144)
        if announcement.hasNextPreview {
            canvas.hline(rightX, gridW - 8, 87, Pal.grid)
            canvas.smallText("▸ \(announcement.nextTitle ?? "COMING NEXT · v1.2")", x: rightX, y: 91, c: Pal.cyan)
            if let sub = announcement.nextSubtitle {
                canvas.smallText(sub, x: rightX + 6, y: 97, c: Pal.violet)
            }

            var ty = 105
            if let teasers = announcement.nextTeasers {
                for (idx, t) in teasers.prefix(4).enumerated() {
                    let col = (idx == teasers.count - 1) ? Pal.greenDim : Pal.ink
                    let indent = (idx == teasers.count - 1) ? (rightX + 4) : (rightX + 4)
                    canvas.smallText(t, x: indent, y: ty, c: col)
                    ty += 8
                }
            }
        }

        // ── Bottom Action Bar (y: 148..175) ──────────────────────────────────
        canvas.hline(1, gridW - 2, 148, Pal.grid)
        let btn = continueBtnRect
        let btnBg = isHoveringButton ? Pal.panelHi : Pal.panel
        let btnBorder = isHoveringButton ? Pal.white : Pal.green
        let btnTextCol = isHoveringButton ? Pal.white : Pal.green

        canvas.fillRect(btn.x, btn.y, btn.w, btn.h, btnBg)
        canvas.frameRect(btn.x, btn.y, btn.w, btn.h, btnBorder)
        let label = "CONTINUE [ENTER / SPACE]"
        let labelW = PixelCanvas.smallWidth(label)
        let lx = btn.x + (btn.w - labelW) / 2
        canvas.smallText(label, x: lx, y: btn.y + 5, c: btnTextCol)

        // Apply CRT Scanlines and Vignette
        let rowFactor = PixelCanvas.makeRowFactor(h: gridH, enabled: true)
        let vig = PixelCanvas.makeVignette(w: gridW, h: gridH)
        let bandY = Int(t * 18) % (gridH + 20) - 10
        canvas.applyCRT(rowFactor: rowFactor, vig: vig, bandY: bandY, bandH: 4)

        if let img = ctx.makeImage() {
            pushImage(img)
        }
    }

    private func pushImage(_ img: CGImage) {
        guard let layer = host?.layer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.contents = img
        layer.contentsGravity = .resizeAspect
        layer.magnificationFilter = .nearest
        CATransaction.commit()
    }

    // MARK: - Input Handlers

    private func canvasCoordinates(from hostPoint: NSPoint) -> (x: Int, y: Int)? {
        guard let host = host else { return nil }
        let bounds = host.bounds
        guard bounds.width > 0, bounds.height > 0 else { return nil }
        let gx = Int((hostPoint.x / bounds.width) * CGFloat(gridW))
        let gy = Int(((bounds.height - hostPoint.y) / bounds.height) * CGFloat(gridH))
        guard gx >= 0, gx < gridW, gy >= 0, gy < gridH else { return nil }
        return (gx, gy)
    }

    private func handleClick(_ p: NSPoint) {
        guard let (gx, gy) = canvasCoordinates(from: p) else { return }

        let btn = continueBtnRect
        if gx >= btn.x && gx < btn.x + btn.w && gy >= btn.y && gy < btn.y + btn.h {
            dismissAndAcknowledge()
            return
        }

        let cr = closeBtnRect
        if gx >= cr.x && gx < cr.x + cr.w && gy >= cr.y && gy < cr.y + cr.h {
            dismissAndAcknowledge()
            return
        }
    }

    private func handleHover(_ p: NSPoint) {
        guard let (gx, gy) = canvasCoordinates(from: p) else {
            if isHoveringButton || isHoveringClose {
                isHoveringButton = false
                isHoveringClose = false
                host?.setCursor(NSCursor.arrow)
            }
            return
        }

        let btn = continueBtnRect
        let hoverBtn = gx >= btn.x && gx < btn.x + btn.w && gy >= btn.y && gy < btn.y + btn.h

        let cr = closeBtnRect
        let hoverClose = gx >= cr.x && gx < cr.x + cr.w && gy >= cr.y && gy < cr.y + cr.h

        if hoverBtn != isHoveringButton || hoverClose != isHoveringClose {
            isHoveringButton = hoverBtn
            isHoveringClose = hoverClose
            host?.setCursor((hoverBtn || hoverClose) ? NSCursor.pointingHand : NSCursor.arrow)
        }
    }

    func dismissAndAcknowledge() {
        if isAcknowledgedOnClose {
            WhatsNewManager.shared.markAcknowledged(version: announcement.version)
        }
        snd?.blip()
        stopAnimationPump()
        window?.orderOut(nil)
    }

    // MARK: - NSWindowDelegate

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        dismissAndAcknowledge()
        return true
    }
}
