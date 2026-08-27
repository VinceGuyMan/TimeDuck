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
}
