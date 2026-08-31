// MARK: - TimeDuck · Theme.swift
// Color systems, palettes, theme definitions, and dynamic rainbow generators.

import Foundation

typealias Color = UInt32

@inline(__always)
func rgb(_ r: Int, _ g: Int, _ b: Int) -> Color {
    Color(((max(0, min(255, r))) << 16) | ((max(0, min(255, g))) << 8) | (max(0, min(255, b))))
}

// MARK: - Themes & Costumes

enum ThemeType: Int, Codable, CaseIterable {
    case arcade = 0
    case gameboy = 1
    case amber = 2
    case synthwave = 3
    case pond = 4
    case terminal = 5
    case paperwhite = 6
    case electricPond = 7

    var displayName: String {
        switch self {
        case .arcade:       return "ARCADE NEON"
        case .gameboy:      return "GAME BOY DMG"
        case .amber:        return "AMBER CRT"
        case .synthwave:    return "SYNTHWAVE"
        case .pond:         return "DUCK POND"
        case .terminal:     return "TERMINAL GREEN"
        case .paperwhite:   return "PAPERWHITE"
        case .electricPond: return "ELECTRIC POND"
        }
    }
}

enum DuckHat: Int, Codable, CaseIterable {
    case none = 0
    case wizard = 1
    case detective = 2
    case cyber = 3
    case barista = 4
    case sleepcap = 5
    case crown = 6
    case bandanaMidnight = 7
    case bandanaCrimson = 8
    case bandanaForestCamo = 9
    case bandanaDesertCamo = 10

    var displayName: String {
        switch self {
        case .none:              return "CLASSIC DUCK"
        case .wizard:            return "WIZARD HAT"
        case .detective:         return "DETECTIVE CAP"
        case .cyber:             return "CYBER SHADES"
        case .barista:           return "BARISTA"
        case .sleepcap:          return "SLEEPY CAP"
        case .crown:             return "ROYAL CROWN"
        case .bandanaMidnight:   return "TACTICAL (MIDNIGHT)"
        case .bandanaCrimson:    return "CRIMSON RONIN"
        case .bandanaForestCamo: return "FOREST CAMO"
        case .bandanaDesertCamo: return "DESERT CAMO"
        }
    }

    var isTacticalBandana: Bool {
        switch self {
        case .bandanaMidnight, .bandanaCrimson, .bandanaForestCamo, .bandanaDesertCamo:
            return true
        default:
            return false
        }
    }
}

struct ThemeDefinition {
    let bg: Color
    let bgDeep: Color
    let panel: Color
    let panelHi: Color
    let grid: Color
    let ink: Color
    let inkDim: Color
    let inkFaint: Color
    let green: Color
    let greenDim: Color
    let amber: Color
    let amberDim: Color
    let red: Color
    let redDim: Color
    let cyan: Color
    let magenta: Color
    let violet: Color
    let duckBody: Color
    let duckShad: Color
    let duckBill: Color
    let duckEye: Color
    let white: Color
    let cheek: Color
    let sweat: Color
}

enum ThemeRegistry {
    static var current: ThemeType = .arcade

    static let arcadeTheme = ThemeDefinition(
        bg: rgb(10, 10, 16),
        bgDeep: rgb(6, 6, 10),
        panel: rgb(18, 18, 30),
        panelHi: rgb(28, 28, 46),
        grid: rgb(24, 24, 40),
        ink: rgb(234, 246, 255),
        inkDim: rgb(110, 118, 148),
        inkFaint: rgb(58, 62, 86),
        green: rgb(83, 255, 122),
        greenDim: rgb(24, 108, 60),
        amber: rgb(255, 194, 77),
        amberDim: rgb(122, 86, 26),
        red: rgb(255, 77, 94),
        redDim: rgb(120, 30, 42),
        cyan: rgb(77, 217, 255),
        magenta: rgb(255, 95, 208),
        violet: rgb(157, 107, 255),
        duckBody: rgb(255, 216, 77),
        duckShad: rgb(201, 166, 46),
        duckBill: rgb(255, 138, 60),
        duckEye: rgb(20, 20, 32),
        white: rgb(255, 255, 255),
        cheek: rgb(255, 159, 178),
        sweat: rgb(110, 190, 255)
    )

    static let gameboyTheme = ThemeDefinition(
        bg: rgb(139, 172, 15),
        bgDeep: rgb(110, 142, 10),
        panel: rgb(125, 158, 12),
        panelHi: rgb(155, 188, 15),
        grid: rgb(75, 105, 10),
        ink: rgb(15, 56, 15),
        inkDim: rgb(48, 98, 48),
        inkFaint: rgb(70, 115, 70),
        green: rgb(15, 56, 15),
        greenDim: rgb(48, 98, 48),
        amber: rgb(30, 75, 30),
        amberDim: rgb(60, 110, 60),
        red: rgb(15, 56, 15),
        redDim: rgb(48, 98, 48),
        cyan: rgb(15, 56, 15),
        magenta: rgb(30, 75, 30),
        violet: rgb(48, 98, 48),
        duckBody: rgb(155, 188, 15),
        duckShad: rgb(110, 142, 10),
        duckBill: rgb(48, 98, 48),
        duckEye: rgb(15, 56, 15),
        white: rgb(155, 188, 15),
        cheek: rgb(110, 142, 10),
        sweat: rgb(48, 98, 48)
    )

    static let amberTheme = ThemeDefinition(
        bg: rgb(18, 10, 0),
        bgDeep: rgb(10, 5, 0),
        panel: rgb(35, 20, 2),
        panelHi: rgb(55, 32, 4),
        grid: rgb(48, 28, 4),
        ink: rgb(255, 185, 30),
        inkDim: rgb(180, 115, 10),
        inkFaint: rgb(90, 55, 5),
        green: rgb(255, 215, 70),
        greenDim: rgb(120, 80, 10),
        amber: rgb(255, 180, 0),
        amberDim: rgb(110, 70, 0),
        red: rgb(255, 120, 20),
        redDim: rgb(130, 45, 0),
        cyan: rgb(255, 220, 100),
        magenta: rgb(255, 160, 40),
        violet: rgb(220, 130, 30),
        duckBody: rgb(255, 195, 45),
        duckShad: rgb(190, 120, 15),
        duckBill: rgb(255, 135, 10),
        duckEye: rgb(30, 16, 0),
        white: rgb(255, 235, 160),
        cheek: rgb(255, 150, 40),
        sweat: rgb(255, 210, 80)
    )

    static let synthwaveTheme = ThemeDefinition(
        bg: rgb(18, 7, 36),
        bgDeep: rgb(10, 4, 22),
        panel: rgb(32, 14, 60),
        panelHi: rgb(48, 22, 88),
        grid: rgb(44, 18, 78),
        ink: rgb(255, 240, 255),
        inkDim: rgb(160, 120, 200),
        inkFaint: rgb(85, 55, 120),
        green: rgb(0, 255, 200),
        greenDim: rgb(0, 110, 95),
        amber: rgb(255, 195, 60),
        amberDim: rgb(130, 90, 20),
        red: rgb(255, 40, 120),
        redDim: rgb(135, 15, 65),
        cyan: rgb(0, 240, 255),
        magenta: rgb(255, 45, 180),
        violet: rgb(175, 60, 255),
        duckBody: rgb(255, 215, 65),
        duckShad: rgb(215, 140, 40),
        duckBill: rgb(255, 90, 130),
        duckEye: rgb(25, 8, 45),
        white: rgb(255, 255, 255),
        cheek: rgb(255, 80, 180),
        sweat: rgb(0, 240, 255)
    )

    static let pondTheme = ThemeDefinition(
        bg: rgb(16, 32, 44),
        bgDeep: rgb(10, 20, 30),
        panel: rgb(25, 48, 64),
        panelHi: rgb(38, 70, 92),
        grid: rgb(30, 58, 76),
        ink: rgb(240, 250, 255),
        inkDim: rgb(125, 170, 195),
        inkFaint: rgb(65, 95, 115),
        green: rgb(90, 225, 130),
        greenDim: rgb(30, 100, 55),
        amber: rgb(255, 205, 80),
        amberDim: rgb(130, 95, 30),
        red: rgb(255, 105, 115),
        redDim: rgb(130, 40, 50),
        cyan: rgb(110, 220, 255),
        magenta: rgb(255, 140, 200),
        violet: rgb(150, 150, 245),
        duckBody: rgb(255, 220, 80),
        duckShad: rgb(210, 165, 40),
        duckBill: rgb(255, 130, 50),
        duckEye: rgb(18, 25, 35),
        white: rgb(255, 255, 255),
        cheek: rgb(255, 165, 180),
        sweat: rgb(115, 215, 255)
    )

    static let terminalTheme = ThemeDefinition(
        bg: rgb(4, 16, 6),
        bgDeep: rgb(2, 8, 3),
        panel: rgb(8, 28, 12),
        panelHi: rgb(16, 48, 20),
        grid: rgb(12, 38, 16),
        ink: rgb(51, 255, 51),
        inkDim: rgb(26, 140, 36),
        inkFaint: rgb(14, 70, 20),
        green: rgb(51, 255, 51),
        greenDim: rgb(20, 110, 30),
        amber: rgb(180, 255, 60),
        amberDim: rgb(90, 140, 20),
        red: rgb(255, 80, 60),
        redDim: rgb(130, 25, 20),
        cyan: rgb(80, 255, 180),
        magenta: rgb(180, 255, 120),
        violet: rgb(90, 210, 100),
        duckBody: rgb(77, 255, 77),
        duckShad: rgb(30, 160, 45),
        duckBill: rgb(255, 190, 40),
        duckEye: rgb(4, 16, 6),
        white: rgb(210, 255, 210),
        cheek: rgb(40, 180, 50),
        sweat: rgb(100, 255, 200)
    )

    static let paperwhiteTheme = ThemeDefinition(
        bg: rgb(238, 242, 246),
        bgDeep: rgb(222, 228, 236),
        panel: rgb(248, 250, 252),
        panelHi: rgb(255, 255, 255),
        grid: rgb(195, 205, 218),
        ink: rgb(18, 28, 42),
        inkDim: rgb(92, 110, 132),
        inkFaint: rgb(150, 166, 186),
        green: rgb(16, 140, 72),
        greenDim: rgb(80, 180, 120),
        amber: rgb(195, 115, 12),
        amberDim: rgb(230, 165, 60),
        red: rgb(205, 38, 48),
        redDim: rgb(240, 110, 120),
        cyan: rgb(12, 125, 175),
        magenta: rgb(160, 45, 130),
        violet: rgb(95, 60, 165),
        duckBody: rgb(245, 180, 25),
        duckShad: rgb(195, 135, 15),
        duckBill: rgb(225, 95, 25),
        duckEye: rgb(18, 28, 42),
        white: rgb(255, 255, 255),
        cheek: rgb(235, 130, 140),
        sweat: rgb(70, 160, 225)
    )

    static let electricPondTheme = ThemeDefinition(
        bg: rgb(8, 14, 26),
        bgDeep: rgb(4, 7, 14),
        panel: rgb(14, 26, 48),
        panelHi: rgb(22, 42, 74),
        grid: rgb(28, 40, 68),
        ink: rgb(0, 240, 255),
        inkDim: rgb(45, 135, 175),
        inkFaint: rgb(24, 70, 95),
        green: rgb(0, 255, 160),
        greenDim: rgb(0, 120, 80),
        amber: rgb(255, 210, 0),
        amberDim: rgb(140, 110, 0),
        red: rgb(255, 50, 100),
        redDim: rgb(130, 20, 50),
        cyan: rgb(0, 240, 255),
        magenta: rgb(255, 0, 180),
        violet: rgb(150, 50, 255),
        duckBody: rgb(255, 225, 30),
        duckShad: rgb(205, 160, 10),
        duckBill: rgb(255, 120, 20),
        duckEye: rgb(8, 14, 26),
        white: rgb(255, 255, 255),
        cheek: rgb(255, 100, 170),
        sweat: rgb(0, 240, 255)
    )

    static func definition(for type: ThemeType) -> ThemeDefinition {
        switch type {
        case .arcade:       return arcadeTheme
        case .gameboy:      return gameboyTheme
        case .amber:        return amberTheme
        case .synthwave:    return synthwaveTheme
        case .pond:         return pondTheme
        case .terminal:     return terminalTheme
        case .paperwhite:   return paperwhiteTheme
        case .electricPond: return electricPondTheme
        }
    }

    static func active() -> ThemeDefinition {
        definition(for: current)
    }
}

enum Pal {
    static func definition(for type: ThemeType) -> ThemeDefinition {
        ThemeRegistry.definition(for: type)
    }

    static var bg: Color { ThemeRegistry.active().bg }
    static var bgDeep: Color { ThemeRegistry.active().bgDeep }
    static var panel: Color { ThemeRegistry.active().panel }
    static var panelHi: Color { ThemeRegistry.active().panelHi }
    static var grid: Color { ThemeRegistry.active().grid }
    static var ink: Color { ThemeRegistry.active().ink }
    static var inkDim: Color { ThemeRegistry.active().inkDim }
    static var inkFaint: Color { ThemeRegistry.active().inkFaint }
    static var green: Color { ThemeRegistry.active().green }
    static var greenDim: Color { ThemeRegistry.active().greenDim }
    static var amber: Color { ThemeRegistry.active().amber }
    static var amberDim: Color { ThemeRegistry.active().amberDim }
    static var red: Color { ThemeRegistry.active().red }
    static var redDim: Color { ThemeRegistry.active().redDim }
    static var cyan: Color { ThemeRegistry.active().cyan }
    static var magenta: Color { ThemeRegistry.active().magenta }
    static var violet: Color { ThemeRegistry.active().violet }
    static var duckBody: Color { ThemeRegistry.active().duckBody }
    static var duckShad: Color { ThemeRegistry.active().duckShad }
    static var duckBill: Color { ThemeRegistry.active().duckBill }
    static var duckEye: Color { ThemeRegistry.active().duckEye }
    static var white: Color { ThemeRegistry.active().white }
    static var cheek: Color { ThemeRegistry.active().cheek }
    static var sweat: Color { ThemeRegistry.active().sweat }
}

func rainbow(_ t: Double, vq: Double = 1.0) -> Color {
    if ThemeRegistry.current == .gameboy {
        let v = Int(t * 4) % 4
        return v == 0 ? Pal.ink : (v == 1 ? Pal.greenDim : (v == 2 ? Pal.inkDim : Pal.duckBody))
    }
    if ThemeRegistry.current == .amber {
        return Int(t * 3) % 2 == 0 ? Pal.amber : Pal.green
    }
    if ThemeRegistry.current == .terminal {
        let v = Int(t * 4) % 3
        return v == 0 ? Pal.green : (v == 1 ? Pal.greenDim : Pal.white)
    }
    if ThemeRegistry.current == .paperwhite {
        let v = Int(t * 5) % 4
        return v == 0 ? Pal.cyan : (v == 1 ? Pal.green : (v == 2 ? Pal.amber : Pal.red))
    }
    if ThemeRegistry.current == .electricPond {
        let v = Int(t * 4) % 3
        return v == 0 ? Pal.cyan : (v == 1 ? Pal.amber : Pal.magenta)
    }
    let h = (t.truncatingRemainder(dividingBy: 1.0)) * 6.0
    let i = Int(h) % 6
    let f = h - h.rounded(.down)
    let s = 0.8, v = max(0, min(1, vq))
    let p = v * (1 - s), q = v * (1 - s * f), tt = v * (1 - s * (1 - f))
    let (r, g, b): (Double, Double, Double)
    switch i {
    case 0:  (r, g, b) = (v, tt, p)
    case 1:  (r, g, b) = (q, v, p)
    case 2:  (r, g, b) = (p, v, tt)
    case 3:  (r, g, b) = (p, q, v)
    case 4:  (r, g, b) = (tt, p, v)
    default: (r, g, b) = (v, p, q)
    }
    return rgb(Int(r * 255), Int(g * 255), Int(b * 255))
}
