// MARK: - TimeDuck · ViewportTransform.swift
// Single authoritative coordinate mapping between AppKit host view bounds
// and the aspect-fitted logical integer pixel canvas.

import Foundation
import CoreGraphics

public struct ViewportTransform: Equatable {
    public let hostWidth: CGFloat
    public let hostHeight: CGFloat
    public let canvasWidth: Int
    public let canvasHeight: Int

    public let scale: CGFloat
    public let viewportRect: CGRect // In AppKit host coordinates (origin at bottom-left)

    public init(hostSize: CGSize, canvasWidth: Int, canvasHeight: Int) {
        self.hostWidth = max(1.0, hostSize.width)
        self.hostHeight = max(1.0, hostSize.height)
        self.canvasWidth = max(1, canvasWidth)
        self.canvasHeight = max(1, canvasHeight)

        let scaleX = self.hostWidth / CGFloat(self.canvasWidth)
        let scaleY = self.hostHeight / CGFloat(self.canvasHeight)
        let uniformScale = min(scaleX, scaleY)
        self.scale = max(0.001, uniformScale)

        let drawnW = CGFloat(self.canvasWidth) * self.scale
        let drawnH = CGFloat(self.canvasHeight) * self.scale
        let originX = (self.hostWidth - drawnW) / 2.0
        let originY = (self.hostHeight - drawnH) / 2.0

        self.viewportRect = CGRect(x: originX, y: originY, width: drawnW, height: drawnH)
    }

    /// Converts a point in host NSView coordinate space (origin at bottom-left)
    /// to logical integer canvas coordinate space (origin at top-left).
    /// Returns `nil` if the point is outside the rendered canvas viewport.
    public func hostPointToCanvasPoint(_ hostPoint: CGPoint) -> (x: Int, y: Int)? {
        guard viewportRect.contains(hostPoint) else { return nil }

        let relX = hostPoint.x - viewportRect.origin.x
        // In AppKit, hostPoint.y is measured from bottom of host.
        // The top of the viewport in AppKit coordinates is viewportRect.origin.y + viewportRect.height.
        // Logical canvas y=0 is at the top of the canvas.
        let relYFromTop = (viewportRect.origin.y + viewportRect.height) - hostPoint.y
        let gx = Int(relX / scale)
        let gy = Int(relYFromTop / scale)

        guard gx >= 0, gx < canvasWidth, gy >= 0, gy < canvasHeight else { return nil }
        return (gx, gy)
    }

    /// Converts a logical canvas point (top-left origin) to the center of that pixel
    /// in host NSView coordinate space.
    public func canvasPointToHostPoint(gx: Int, gy: Int) -> CGPoint {
        let relX = (CGFloat(gx) + 0.5) * scale
        let relYFromTop = (CGFloat(gy) + 0.5) * scale
        let hostX = viewportRect.origin.x + relX
        let hostY = (viewportRect.origin.y + viewportRect.height) - relYFromTop
        return CGPoint(x: hostX, y: hostY)
    }

    /// Converts a logical canvas rectangle to host NSView coordinate space rectangle.
    public func canvasRectToHostRect(gx: Int, gy: Int, gw: Int, gh: Int) -> CGRect {
        let x = viewportRect.origin.x + CGFloat(gx) * scale
        let h = CGFloat(gh) * scale
        let y = (viewportRect.origin.y + viewportRect.height) - CGFloat(gy + gh) * scale
        let w = CGFloat(gw) * scale
        return CGRect(x: x, y: y, width: w, height: h)
    }

    public var isLetterboxed: Bool {
        viewportRect.origin.y > 0.001
    }

    public var isPillarboxed: Bool {
        viewportRect.origin.x > 0.001
    }
}
