// MARK: - TimeDuck · PixelCanvas.swift
// Low-level software rasterizer for the pixel art viewport and CRT scanline shader.

import Foundation

final class PixelCanvas {
    let w: Int, h: Int
    var p: UnsafeMutablePointer<UInt8>
    private var capacity: Int

    init(w: Int, h: Int) {
        self.w = max(1, w)
        self.h = max(1, h)
        self.capacity = self.w * self.h * 4
        self.p = UnsafeMutablePointer<UInt8>.allocate(capacity: self.capacity)
        self.p.initialize(repeating: 0, count: self.capacity)
    }

    deinit {
        p.deallocate()
    }

    @inline(__always)
    func fillAll(_ c: Color) {
        let r = UInt8((c >> 16) & 255)
        let g = UInt8((c >> 8) & 255)
        let b = UInt8(c & 255)
        var i = 0
        let n = w * h * 4
        while i < n {
            p[i] = r
            p[i+1] = g
            p[i+2] = b
            p[i+3] = 255
            i += 4
        }
    }

    @inline(__always)
    func set(_ x: Int, _ y: Int, _ c: Color, a: UInt8 = 255) {
        guard x >= 0, y >= 0, x < w, y < h else { return }
        let i = (y * w + x) * 4
        if a >= 255 {
            p[i] = UInt8((c >> 16) & 255)
            p[i+1] = UInt8((c >> 8) & 255)
            p[i+2] = UInt8(c & 255)
            p[i+3] = 255
        } else {
            let al = Double(a) / 255.0
            for k in 0..<3 {
                let src = Double((c >> (16 - 8 * k)) & 255)
                p[i+k] = UInt8(Double(p[i+k]) * (1.0 - al) + src * al)
            }
            p[i+3] = 255
        }
    }

    func fillRect(_ x: Int, _ y: Int, _ rw: Int, _ rh: Int, _ c: Color, a: UInt8 = 255) {
        guard rw > 0, rh > 0 else { return }
        for yy in y..<(y + rh) {
            for xx in x..<(x + rw) {
                set(xx, yy, c, a: a)
            }
        }
    }

    func frameRect(_ x: Int, _ y: Int, _ rw: Int, _ rh: Int, _ c: Color, a: UInt8 = 255) {
        guard rw > 0, rh > 0 else { return }
        for xx in x..<(x + rw) {
            set(xx, y, c, a: a)
            set(xx, y + rh - 1, c, a: a)
        }
        for yy in y..<(y + rh) {
            set(x, yy, c, a: a)
            set(x + rw - 1, yy, c, a: a)
        }
    }

    func hline(_ x0: Int, _ x1: Int, _ y: Int, _ c: Color, a: UInt8 = 255) {
        guard x0 <= x1 else { return }
        for xx in x0...x1 {
            set(xx, y, c, a: a)
        }
    }

    func vline(_ x: Int, _ y0: Int, _ y1: Int, _ c: Color, a: UInt8 = 255) {
        guard y0 <= y1 else { return }
        for yy in y0...y1 {
            set(x, yy, c, a: a)
        }
    }

    @discardableResult
    func drawText(_ s: String, x: Int, y: Int, c: Color, font: [Character: [UInt8]],
                  gw: Int, gh: Int, scale: Int = 1, a: UInt8 = 255) -> Int {
        var cx = x
        let adv = (gw + 1) * scale
        for ch in s {
            if let rows = font[ch] ?? font[Character(ch.uppercased())] {
                for ry in 0..<gh {
                    let bits = ry < rows.count ? rows[ry] : 0
                    for rx in 0..<gw where (bits >> (gw - 1 - rx)) & 1 == 1 {
                        for sy in 0..<scale {
                            for sx in 0..<scale {
                                set(cx + rx * scale + sx, y + ry * scale + sy, c, a: a)
                            }
                        }
                    }
                }
            } else {
                frameRect(cx, y, gw * scale, gh * scale, Pal.magenta)
            }
            cx += adv
        }
        return cx - x - scale
    }

    @discardableResult
    func smallText(_ s: String, x: Int, y: Int, c: Color, scale: Int = 1, a: UInt8 = 255) -> Int {
        drawText(s.uppercased(), x: x, y: y, c: c, font: FONT3, gw: 3, gh: 5, scale: scale, a: a)
    }

    @discardableResult
    func heroText(_ s: String, x: Int, y: Int, c: Color, scale: Int, a: UInt8 = 255) -> Int {
        drawText(s, x: x, y: y, c: c, font: FONT5, gw: 5, gh: 7, scale: scale, a: a)
    }

    static func smallWidth(_ s: String, scale: Int = 1) -> Int {
        max(0, s.count * 4 * scale - scale)
    }

    static func heroWidth(_ s: String, scale: Int) -> Int {
        s.count * 6 * scale - scale
    }

    static func fitSmallText(_ s: String, maxWidth: Int, scale: Int = 1) -> String {
        guard maxWidth > 0 else { return "" }
        let maxChars = max(1, (maxWidth + scale) / (4 * scale))
        if s.count <= maxChars { return s }
        if maxChars <= 3 { return String(s.prefix(maxChars)) }
        return String(s.prefix(maxChars - 1)) + "…"
    }

    func drawSprite(_ rows: [String], x: Int, y: Int, map: [Character: Color], flip: Bool = false) {
        let fw = rows.first?.count ?? 0
        for (ry, row) in rows.enumerated() {
            for (rx, ch) in row.enumerated() {
                guard let c = map[ch] else { continue }
                let px = flip ? (x + fw - 1 - rx) : (x + rx)
                set(px, y + ry, c)
            }
        }
    }

    func drawSpeechBubble(text: String, targetX: Int, targetY: Int, isFlipped: Bool = false) {
        let maxAvailableW = w - 8
        let fitText = PixelCanvas.fitSmallText(text, maxWidth: maxAvailableW)
        let txtW = PixelCanvas.smallWidth(fitText)
        let bubbleW = txtW + 6
        let bubbleH = 9
        var bx = isFlipped ? targetX - bubbleW - 2 : targetX - 4
        bx = max(2, min(w - bubbleW - 2, bx))
        let by = max(2, min(h - bubbleH - 12, targetY - bubbleH - 4))

        fillRect(bx, by, bubbleW, bubbleH, Pal.bgDeep)
        frameRect(bx, by, bubbleW, bubbleH, Pal.ink)
        // Arrow pointing down to duck
        let arrowX = max(bx + 2, min(bx + bubbleW - 4, targetX + (isFlipped ? 10 : 2)))
        set(arrowX, by + bubbleH, Pal.ink)
        set(arrowX + (isFlipped ? -1 : 1), by + bubbleH + 1, Pal.ink)

        smallText(fitText, x: bx + 3, y: by + 2, c: Pal.ink)
    }

    func applyCRT(rowFactor: [Double], vig: [Double], bandY: Int, bandH: Int) {
        var i = 0
        for y in 0..<h {
            let rf = rowFactor[y]
            let dist = abs(y - bandY)
            let boost = dist < bandH ? 1.0 + 0.14 * (1.0 - Double(dist) / Double(bandH)) : 1.0
            for _ in 0..<w {
                let f = rf * vig[i / 4] * boost
                p[i]   = UInt8(min(255.0, Double(p[i])   * f))
                p[i+1] = UInt8(min(255.0, Double(p[i+1]) * f))
                p[i+2] = UInt8(min(255.0, Double(p[i+2]) * f))
                i += 4
            }
        }
    }

    static func makeRowFactor(h: Int, enabled: Bool) -> [Double] {
        guard enabled else { return [Double](repeating: 1.0, count: h) }
        return (0..<h).map { y in y % 2 == 0 ? 1.0 : ((y % 6 == 3) ? 0.74 : 0.86) }
    }

    static func makeVignette(w: Int, h: Int) -> [Double] {
        var out = [Double](repeating: 1.0, count: w * h)
        let cx = Double(w) / 2.0, cy = Double(h) / 2.0
        let maxD = (cx * cx + cy * cy).squareRoot()
        for y in 0..<h {
            for x in 0..<w {
                let dx = Double(x) - cx, dy = Double(y) - cy
                let d = (dx * dx + dy * dy).squareRoot() / maxD
                out[y * w + x] = 1.0 - 0.22 * d * d
            }
        }
        return out
    }
}
