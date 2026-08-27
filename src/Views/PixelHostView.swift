// MARK: - TimeDuck · PixelHostView.swift
// Host NSView that renders the rasterized pixel canvas via a CALayer.

import Foundation
import AppKit

final class PixelHostView: NSView {
    var onDraw: ((CGImage) -> Void)?
    var onClick: ((NSPoint) -> Void)?
    var onHover: ((NSPoint) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    func setCursor(_ cursor: NSCursor) {
        cursor.set()
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        dirtyRect.fill()
    }

    override func mouseDown(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        onClick?(p)
    }

    override func mouseMoved(with event: NSEvent) {
        let p = convert(event.locationInWindow, from: nil)
        onHover?(p)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for ta in trackingAreas {
            removeTrackingArea(ta)
        }
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeInKeyWindow, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }

    // MARK: - Accessibility (VoiceOver & Assistive Tech)

    override func isAccessibilityElement() -> Bool {
        true
    }

    override func accessibilityRole() -> NSAccessibility.Role? {
        .group
    }

    override func accessibilityLabel() -> String? {
        "TimeDuck Desktop Companion and Precision Timer"
    }

    override func accessibilityHelp() -> String? {
        "Space to start/pause. 1, 2, 3 to switch modes. H to cycle hats. T to cycle themes. Q to pet duck."
    }
}
