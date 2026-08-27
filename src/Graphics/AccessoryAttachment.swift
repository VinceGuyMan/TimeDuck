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

        // 4. Scan for skull crown row (topmost row with duck head body pixels)
        var headY = 0
        var headX = 0

        for (rowIndex, row) in rows.prefix(5).enumerated() {
            let yCount = row.filter { $0 == "y" }.count
            // Require at least 3 yellow pixels to skip wing tips (e.g. DUCK_YAY_A row 0 "....d..d.....")
            if yCount >= 3 {
                headY = rowIndex
                if let firstY = row.firstIndex(of: "y") {
                    let col = row.distance(from: row.startIndex, to: firstY)
                    if col <= 3 {
                        headX = -1 // Tilted forward/up (DUCK_LOOK_UP)
                    } else if col >= 5 {
                        headX = 1  // Shifted forward/right (DUCK_PEEK_B)
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
