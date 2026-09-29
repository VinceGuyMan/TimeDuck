// MARK: - TimeDuck · AccessoryAttachment.swift
// Living Wardrobe: Pixel-art attachment anchor system.
// Dynamically attaches hats, bandanas, face shades, and seasonal headwear to duck skull geometry.

import Foundation

// MARK: - Duck Head Anchor

struct DuckHeadAnchor: Equatable {
    var x: Int
    var y: Int
    var facingBack: Bool
    var isPecking: Bool
    var isSleeping: Bool
}

// MARK: - Duck Bill Anchor

struct DuckBillAnchor: Equatable {
    var x: Int // Sprite-relative column of bill tip
    var y: Int // Sprite-relative row of bill tip
    var facingLeft: Bool
}

// MARK: - Duck Bill Anchor Resolver

enum DuckBillAnchorResolver {
    /// Resolves the physical beak/bill tip coordinates from an active duck frame matrix.
    static func resolve(rows: [String], flip: Bool = false) -> DuckBillAnchor {
        guard !rows.isEmpty else {
            return DuckBillAnchor(x: flip ? 1 : 11, y: 4, facingLeft: flip)
        }

        let width = rows[0].count

        // Check if the sprite itself naturally faces backward/left (e.g. DUCK_LOOK_BACK)
        let isNaturallyFacingBack = rows.contains { row in
            row.hasPrefix(".oo") || row.hasPrefix("ooo")
        }
        let effectiveFacingLeft = flip ? !isNaturallyFacingBack : isNaturallyFacingBack

        // Scan for beak pixels ('o' for bill, 'r' for open beak)
        var beakPoints: [(r: Int, c: Int)] = []
        for (rIdx, row) in rows.enumerated() {
            for (cIdx, char) in row.enumerated() {
                if char == "o" || char == "r" {
                    beakPoints.append((r: rIdx, c: cIdx))
                }
            }
        }

        guard !beakPoints.isEmpty else {
            return DuckBillAnchor(x: effectiveFacingLeft ? 1 : width - 2, y: 4, facingLeft: effectiveFacingLeft)
        }

        if effectiveFacingLeft {
            if flip {
                let maxPoint = beakPoints.max(by: { $0.c < $1.c })!
                let resolvedX = width - 1 - maxPoint.c
                return DuckBillAnchor(x: max(0, resolvedX), y: maxPoint.r, facingLeft: true)
            } else {
                let minPoint = beakPoints.min(by: { $0.c < $1.c })!
                return DuckBillAnchor(x: max(0, minPoint.c), y: minPoint.r, facingLeft: true)
            }
        } else {
            if flip {
                let minPoint = beakPoints.min(by: { $0.c < $1.c })!
                let resolvedX = width - 1 - minPoint.c
                return DuckBillAnchor(x: min(width - 1, resolvedX), y: minPoint.r, facingLeft: false)
            } else {
                let maxPoint = beakPoints.max(by: { $0.c < $1.c })!
                return DuckBillAnchor(x: min(width - 1, maxPoint.c), y: maxPoint.r, facingLeft: false)
            }
        }
    }
}

// MARK: - Duck Anchor Resolver

enum DuckAnchorResolver {
    /// Resolves the physical skull anchor coordinates from an active duck frame matrix.
    static func resolve(rows: [String]) -> DuckHeadAnchor {
        guard !rows.isEmpty else {
            return DuckHeadAnchor(x: 0, y: 0, facingBack: false, isPecking: false, isSleeping: false)
        }

        // 1. Detect head turned backward pose (DUCK_LOOK_BACK)
        let isFacingBack = rows.contains { row in
            row.contains("ywk") || (row.hasPrefix(".oo") && row.contains("yy"))
        }

        // 2. Detect deep sleep pose (DUCK_SLEEP_DEEP)
        let isSleeping = rows.count >= 10 &&
            rows[0].allSatisfy({ $0 == "." }) &&
            rows[1].allSatisfy({ $0 == "." }) &&
            rows.contains { $0.contains("kkk") }

        // 3. Detect deep floor peck pose (DUCK_PECK_B)
        let isDeepPeck = rows.count >= 10 &&
            rows[0].allSatisfy({ $0 == "." }) &&
            rows[1].allSatisfy({ $0 == "." }) &&
            rows[2].allSatisfy({ $0 == "." })

        if isDeepPeck {
            return DuckHeadAnchor(x: 1, y: 3, facingBack: false, isPecking: true, isSleeping: false)
        }
        if isSleeping {
            return DuckHeadAnchor(x: 0, y: 2, facingBack: false, isPecking: false, isSleeping: true)
        }

        // 4. Scan for skull crown row (topmost row with duck head body pixels across all companions)
        var headY = 0
        var headX = 0

        for (rowIndex, row) in rows.prefix(7).enumerated() {
            let bodyCount = row.filter { $0 == "y" || $0 == "b" || $0 == "m" || $0 == "k" }.count
            // Require at least 3 body/head pixels to skip stray wing tips
            if bodyCount >= 3 {
                headY = rowIndex
                if let firstHead = row.firstIndex(where: { $0 == "y" || $0 == "b" || $0 == "m" || $0 == "k" }) {
                    let col = row.distance(from: row.startIndex, to: firstHead)
                    if col <= 3 {
                        headX = -1 // Tilted forward/up (DUCK_LOOK_UP, DUCK_SWALLOW)
                    } else if col >= 5 {
                        headX = 1  // Shifted forward/right (DUCK_PEEK_B, DUCK_CONFUSED_B)
                    }
                }
                break
            }
        }

        return DuckHeadAnchor(x: headX, y: headY, facingBack: isFacingBack, isPecking: false, isSleeping: false)
    }
}

// MARK: - Living Wardrobe Accessory Attachment Engine

enum AccessoryAttachment {
    /// Resolves the attached accessory sprite, adjusted draw coordinates, and orientation.
    static func getSprite(
        for hat: DuckHat,
        anchor: DuckHeadAnchor,
        t: Double = 0.0,
        isRunning: Bool = false,
        isCelebrating: Bool = false
    ) -> (rows: [String], xOffset: Int, yOffset: Int, flip: Bool) {
        guard hat != .none else { return ([], 0, 0, false) }

        // Subtle 1-pixel secondary motion on alternate stride/hop frames for soft fabrics
        let useSecondary = (isRunning && Int(t * 8) % 2 == 1) || (isCelebrating && Int(t * 6) % 2 == 1)

        let x = anchor.x
        let y = anchor.y - 4
        let flip = anchor.facingBack

        let rows: [String]
        switch hat {
        case .none:
            return ([], 0, 0, false)
        case .wizard:
            rows = useSecondary ? HAT_WIZARD_ALT : HAT_WIZARD
        case .detective:
            rows = HAT_DETECTIVE
        case .cyber:
            rows = HAT_CYBER
        case .barista:
            rows = HAT_BARISTA
        case .sleepcap:
            rows = useSecondary ? HAT_SLEEPCAP_ALT : HAT_SLEEPCAP
        case .crown:
            rows = HAT_CROWN
        case .bandanaMidnight:
            rows = useSecondary ? HAT_BANDANA_MIDNIGHT_ALT : HAT_BANDANA_MIDNIGHT
        case .bandanaCrimson:
            rows = useSecondary ? HAT_BANDANA_CRIMSON_ALT : HAT_BANDANA_CRIMSON
        case .bandanaForestCamo:
            rows = useSecondary ? HAT_BANDANA_FOREST_ALT : HAT_BANDANA_FOREST
        case .bandanaDesertCamo:
            rows = useSecondary ? HAT_BANDANA_DESERT_ALT : HAT_BANDANA_DESERT
        case .pumpkin:
            rows = HAT_PUMPKIN
        case .witch:
            rows = HAT_WITCH
        case .winterBeanie:
            rows = HAT_WINTER_BEANIE
        case .festiveSanta:
            rows = useSecondary ? HAT_FESTIVE_SANTA_ALT : HAT_FESTIVE_SANTA
        }

        return (rows, x, y, flip)
    }
}
