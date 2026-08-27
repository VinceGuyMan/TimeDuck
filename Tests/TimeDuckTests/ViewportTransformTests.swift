// MARK: - TimeDuck · ViewportTransformTests.swift

import Foundation
import CoreGraphics

enum ViewportTransformTests {
    static func runAll() {
        print("")
        print("▸ Testing Viewport Coordinate Transformations & Hit-Testing…")

        runTest("testNativeOneToOneMapping") {
            let vt = ViewportTransform(hostSize: CGSize(width: 164, height: 100), canvasWidth: 164, canvasHeight: 100)
            assertEqual(vt.scale, 1.0)
            assertEqual(vt.viewportRect.origin.x, 0.0)
            assertEqual(vt.viewportRect.origin.y, 0.0)
            assertEqual(vt.viewportRect.width, 164.0)
            assertEqual(vt.viewportRect.height, 100.0)
            assertTrue(!vt.isLetterboxed)
            assertTrue(!vt.isPillarboxed)

            // Top-left in AppKit is at (0, 100)
            let tl = vt.hostPointToCanvasPoint(CGPoint(x: 0.5, y: 99.5))
            assertTrue(tl != nil)
            assertEqual(tl?.x, 0)
            assertEqual(tl?.y, 0)

            // Bottom-right in AppKit is at (164, 0)
            let br = vt.hostPointToCanvasPoint(CGPoint(x: 163.5, y: 0.5))
            assertTrue(br != nil)
            assertEqual(br?.x, 163)
            assertEqual(br?.y, 99)
        }

        runTest("testIntegerScale2xMapping") {
            let vt = ViewportTransform(hostSize: CGSize(width: 328, height: 200), canvasWidth: 164, canvasHeight: 100)
            assertEqual(vt.scale, 2.0)
            assertEqual(vt.viewportRect.origin.x, 0.0)
            assertEqual(vt.viewportRect.origin.y, 0.0)
            assertEqual(vt.viewportRect.width, 328.0)
            assertEqual(vt.viewportRect.height, 200.0)

            // Host point (10, 190) -> relX = 10, relYFromTop = 200 - 190 = 10 -> gx = 5, gy = 5
            let pt = vt.hostPointToCanvasPoint(CGPoint(x: 10.0, y: 190.0))
            assertTrue(pt != nil)
            assertEqual(pt?.x, 5)
            assertEqual(pt?.y, 5)
        }

        runTest("testPillarboxWiderHost") {
            // Window is 800 wide, 400 high. Canvas is 164x100.
            // ScaleX = 800/164 = 4.878, ScaleY = 400/100 = 4.0.
            // Scale = 4.0. Drawn width = 656, drawn height = 400.
            // Pillarbox originX = (800 - 656)/2 = 72, originY = 0.
            let vt = ViewportTransform(hostSize: CGSize(width: 800, height: 400), canvasWidth: 164, canvasHeight: 100)
            assertEqual(vt.scale, 4.0)
            assertEqual(vt.viewportRect.origin.x, 72.0)
            assertEqual(vt.viewportRect.origin.y, 0.0)
            assertEqual(vt.viewportRect.width, 656.0)
            assertEqual(vt.viewportRect.height, 400.0)
            assertTrue(vt.isPillarboxed)
            assertTrue(!vt.isLetterboxed)

            // Point in left pillarbox margin (x < 72) must return nil
            let leftMargin = vt.hostPointToCanvasPoint(CGPoint(x: 50.0, y: 200.0))
            assertTrue(leftMargin == nil, "Left pillarbox margin must return nil")

            // Point in right pillarbox margin (x > 728) must return nil
            let rightMargin = vt.hostPointToCanvasPoint(CGPoint(x: 750.0, y: 200.0))
            assertTrue(rightMargin == nil, "Right pillarbox margin must return nil")

            // Point exactly at top-left of canvas (72, 400)
            let tl = vt.hostPointToCanvasPoint(CGPoint(x: 72.5, y: 399.5))
            assertTrue(tl != nil)
            assertEqual(tl?.x, 0)
            assertEqual(tl?.y, 0)

            // Point exactly at bottom-right of canvas (72 + 655.5, 0.5)
            let br = vt.hostPointToCanvasPoint(CGPoint(x: 727.5, y: 0.5))
            assertTrue(br != nil)
            assertEqual(br?.x, 163)
            assertEqual(br?.y, 99)
        }

        runTest("testLetterboxTallerHost") {
            // Window is 400 wide, 800 high. Canvas is 164x100.
            // ScaleX = 400/164 = 2.439, ScaleY = 800/100 = 8.0.
            // Scale = 2.439024... Drawn width = 400.
            let vt = ViewportTransform(hostSize: CGSize(width: 400, height: 800), canvasWidth: 164, canvasHeight: 100)
            assertTrue(vt.isLetterboxed)
            assertTrue(!vt.isPillarboxed)
            assertEqual(vt.viewportRect.origin.x, 0.0)
            assertTrue(vt.viewportRect.origin.y > 0.0)

            // Top letterbox margin click must return nil
            let topMargin = vt.hostPointToCanvasPoint(CGPoint(x: 200.0, y: 790.0))
            assertTrue(topMargin == nil, "Top letterbox margin must return nil")

            // Bottom letterbox margin click must return nil
            let bottomMargin = vt.hostPointToCanvasPoint(CGPoint(x: 200.0, y: 10.0))
            assertTrue(bottomMargin == nil, "Bottom letterbox margin must return nil")
        }

        runTest("testBidirectionalMappingConsistency") {
            let vt = ViewportTransform(hostSize: CGSize(width: 1000, height: 600), canvasWidth: 144, canvasHeight: 34)

            // Test multiple logical coordinates
            let testPoints = [(0, 0), (143, 33), (72, 17), (20, 10), (100, 25)]
            for (gx, gy) in testPoints {
                let hostPt = vt.canvasPointToHostPoint(gx: gx, gy: gy)
                let mappedBack = vt.hostPointToCanvasPoint(hostPt)
                assertTrue(mappedBack != nil, "Mapped back point should not be nil for (\(gx), \(gy))")
                assertEqual(mappedBack?.x, gx)
                assertEqual(mappedBack?.y, gy)
            }
        }

        runTest("testCanvasRectToHostRect") {
            let vt = ViewportTransform(hostSize: CGSize(width: 328, height: 200), canvasWidth: 164, canvasHeight: 100)
            // Button at gx: 10, gy: 20, gw: 30, gh: 10
            let r = vt.canvasRectToHostRect(gx: 10, gy: 20, gw: 30, gh: 10)
            assertEqual(r.origin.x, 20.0) // 10 * 2.0
            assertEqual(r.width, 60.0)   // 30 * 2.0
            assertEqual(r.height, 20.0)  // 10 * 2.0
            // Top of canvas is at host Y = 200. Button top at gy: 20 -> host Y = 200 - 40 = 160.
            // Button bottom at gy: 30 -> host Y = 200 - 60 = 140.
            assertEqual(r.origin.y, 140.0)
        }
    }
}
