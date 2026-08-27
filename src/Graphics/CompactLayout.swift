// MARK: - TimeDuck · CompactLayout.swift
// Authoritative geometry and font scaling engine for Compact Mode.
// Defines strictly non-overlapping, responsive protected zones for:
// - Mode indicator/pill (top-left)
// - Navigation & Exit controls (top-right)
// - Primary time display with bounded font scaling (center-left)
// - Primary action controls (center-right)
// - Dedicated duck companion panel (far-right)
// - Progress bar (bottom)

import Foundation

public enum CompactTimeRenderStyle: Equatable {
    case heroLarge(mainPart: String, fracPart: String, mainW: Int, fracW: Int, totalW: Int)
    case heroWithSmallFrac(mainPart: String, fracPart: String, mainW: Int, fracW: Int, totalW: Int)
    case smallScale2(mainPart: String, fracPart: String, mainW: Int, fracW: Int, totalW: Int)
    case heroScale1(mainPart: String, fracPart: String, mainW: Int, fracW: Int, totalW: Int)
    case smallScale1(fullText: String, totalW: Int)

    public var totalWidth: Int {
        switch self {
        case .heroLarge(_, _, _, _, let totalW): return totalW
        case .heroWithSmallFrac(_, _, _, _, let totalW): return totalW
        case .smallScale2(_, _, _, _, let totalW): return totalW
        case .heroScale1(_, _, _, _, let totalW): return totalW
        case .smallScale1(_, let totalW): return totalW
        }
    }
}

public struct CompactLayoutMetrics: Equatable {
    public let gridW: Int
    public let gridH: Int

    // 1. Dedicated Duck Panel (Far-Right)
    public let duckX: Int
    public let duckY: Int
    public let duckW: Int
    public let duckH: Int
    public let duckSpriteX: Int
    public let duckSpriteY: Int

    // 2. Top-Right Navigation Controls (Strictly left of duck panel separator)
    public let unminiRect: (x: Int, y: Int, w: Int, h: Int)
    public let soundRect: (x: Int, y: Int, w: Int, h: Int)

    // 3. Mode Pill (Top-Left)
    public let modePillRect: (x: Int, y: Int, w: Int, h: Int)
    public let modeTag: String

    // 4. Action Buttons (Go & Sec)
    public let goRect: (x: Int, y: Int, w: Int, h: Int)
    public let secRect: (x: Int, y: Int, w: Int, h: Int)

    // 5. Primary Time Area (Protected Region)
    public let timeAreaRect: (x: Int, y: Int, w: Int, h: Int)
    public let maxTimeWidth: Int

    // 6. Progress Bar
    public let progressBarRect: (x: Int, y: Int, w: Int, h: Int)

    public init(gridW: Int, gridH: Int, modeTag: String, goLabel: String, secLabel: String) {
        self.gridW = max(60, gridW)
        self.gridH = max(20, gridH)
        self.modeTag = modeTag

        // 1. Duck Panel
        let dW: Int
        if gridW >= 130 {
            dW = 25
        } else if gridW >= 100 {
            dW = 19
        } else {
            dW = 17
        }
        self.duckW = dW
        self.duckX = gridW - dW - 2
        self.duckY = 2
        self.duckH = max(16, gridH - 4)
        self.duckSpriteX = self.duckX + (dW - 13) / 2
        self.duckSpriteY = max(3, min(gridH - 16, (gridH - 10) / 2))

        // 2. Top-Right Controls (Header row y=2..9, strictly to the left of duck separator)
        let topBarY = 2
        let topBarH = 8
        let unminiW = gridW < 90 ? 8 : 10
        let unminiX = self.duckX - unminiW - 2
        self.unminiRect = (x: unminiX, y: topBarY, w: unminiW, h: topBarH)

        let soundW = gridW < 90 ? 8 : 10
        let soundX = unminiX - soundW - 2
        self.soundRect = (x: soundX, y: topBarY, w: soundW, h: topBarH)

        // Mode Pill (Top Left)
        let pillW = PixelCanvas.smallWidth(modeTag) + (gridW < 90 ? 4 : 6)
        self.modePillRect = (x: 4, y: topBarY, w: pillW, h: topBarH)

        // 3. Action Buttons
        let btnY = max(11, min(gridH - 17, 12))
        let btnH = max(10, min(14, gridH - btnY - 7))

        let goTextW = PixelCanvas.smallWidth(goLabel)
        let secTextW = PixelCanvas.smallWidth(secLabel)

        let goW: Int
        let secW: Int
        let btnGap: Int

        if gridW >= 130 {
            goW = max(22, goTextW + 6)
            secW = max(20, secTextW + 6)
            btnGap = 2
        } else if gridW >= 100 {
            goW = max(16, goTextW + 4)
            secW = max(14, secTextW + 4)
            btnGap = 2
        } else if gridW >= 80 {
            goW = max(12, min(16, goTextW + 2))
            secW = max(11, min(14, secTextW + 2))
            btnGap = 1
        } else {
            goW = 10
            secW = 10
            btnGap = 1
        }

        let secX = self.duckX - 3 - secW
        let goX = secX - btnGap - goW
        self.secRect = (x: secX, y: btnY, w: secW, h: btnH)
        self.goRect = (x: goX, y: btnY, w: goW, h: btnH)

        // 4. Primary Time Area (Strictly from x=4 to goX - 3)
        let timeX = 4
        let maxW = max(10, goX - timeX - 3)
        self.maxTimeWidth = maxW
        let timeY = max(11, min(gridH - 18, 12))
        let timeH = max(10, min(16, gridH - timeY - 5))
        self.timeAreaRect = (x: timeX, y: timeY, w: maxW, h: timeH)

        // 5. Progress Bar
        let pY = gridH - 4
        let pW = max(4, self.duckX - 6)
        self.progressBarRect = (x: 4, y: pY, w: pW, h: 2)
    }

    public static func resolveTimeRenderStyle(for timeString: String, maxWidth: Int) -> CompactTimeRenderStyle {
        let mainPart: String
        let fracPart: String
        if let dot = timeString.firstIndex(of: ".") {
            mainPart = String(timeString[..<dot])
            fracPart = String(timeString[dot...])
        } else {
            mainPart = timeString
            fracPart = ""
        }

        // Candidate 1: Hero Large (FONT5 Scale 2 main + FONT5 Scale 2 frac)
        let h2MainW = PixelCanvas.heroWidth(mainPart, scale: 2)
        let h2FracW = fracPart.isEmpty ? 0 : (PixelCanvas.heroWidth(fracPart, scale: 2) + 2)
        let h2TotalW = h2MainW + h2FracW
        if h2TotalW <= maxWidth {
            return .heroLarge(mainPart: mainPart, fracPart: fracPart, mainW: h2MainW, fracW: h2FracW, totalW: h2TotalW)
        }

        // Candidate 2: Hero Main with Compact Small Frac (FONT5 Scale 2 main + FONT3 Scale 1 frac)
        let s1FracW = fracPart.isEmpty ? 0 : (PixelCanvas.smallWidth(fracPart, scale: 1) + 2)
        let c2TotalW = h2MainW + s1FracW
        if c2TotalW <= maxWidth {
            return .heroWithSmallFrac(mainPart: mainPart, fracPart: fracPart, mainW: h2MainW, fracW: s1FracW, totalW: c2TotalW)
        }

        // Candidate 3: Small Scale 2 Main with Small Frac (FONT3 Scale 2 main + FONT3 Scale 1 frac)
        let s2MainW = PixelCanvas.smallWidth(mainPart, scale: 2)
        let c3TotalW = s2MainW + s1FracW
        if c3TotalW <= maxWidth {
            return .smallScale2(mainPart: mainPart, fracPart: fracPart, mainW: s2MainW, fracW: s1FracW, totalW: c3TotalW)
        }

        // Candidate 4: Hero Scale 1 (FONT5 Scale 1 main + FONT5 Scale 1 frac)
        let h1MainW = PixelCanvas.heroWidth(mainPart, scale: 1)
        let h1FracW = fracPart.isEmpty ? 0 : (PixelCanvas.heroWidth(fracPart, scale: 1) + 1)
        let c4TotalW = h1MainW + h1FracW
        if c4TotalW <= maxWidth {
            return .heroScale1(mainPart: mainPart, fracPart: fracPart, mainW: h1MainW, fracW: h1FracW, totalW: c4TotalW)
        }

        // Candidate 5: Small Scale 1 with Frac (FONT3 Scale 1 for full text)
        let s1TotalW = PixelCanvas.smallWidth(timeString, scale: 1)
        if s1TotalW <= maxWidth {
            return .smallScale1(fullText: timeString, totalW: s1TotalW)
        }

        // Candidate 6 (Extreme narrow fallback): Small Scale 1 main digits only
        let s1MainW = PixelCanvas.smallWidth(mainPart, scale: 1)
        return .smallScale1(fullText: mainPart, totalW: min(s1MainW, maxWidth))
    }

    public static func == (lhs: CompactLayoutMetrics, rhs: CompactLayoutMetrics) -> Bool {
        lhs.gridW == rhs.gridW &&
        lhs.gridH == rhs.gridH &&
        lhs.duckX == rhs.duckX &&
        lhs.duckY == rhs.duckY &&
        lhs.duckW == rhs.duckW &&
        lhs.duckH == rhs.duckH &&
        lhs.modeTag == rhs.modeTag &&
        lhs.maxTimeWidth == rhs.maxTimeWidth
    }
}
