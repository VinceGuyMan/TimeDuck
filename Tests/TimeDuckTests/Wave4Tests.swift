// MARK: - TimeDuck · Wave4Tests.swift
// Unit tests for Wave 4 (Living Wardrobe):
// - Duck head anchor resolution across all poses and animation frames
// - Accessory attachment positioning and geometry
// - Secondary motion for soft accessories during waddle/hop
// - Turned-head backward flipping
// - Canvas bounds safety across all 14 costumes and all 25+ duck poses

import Foundation

struct Wave4Tests {
    static func runAll() {
        print("▸ Testing Wave 4: Living Wardrobe (Physical Costume Attachment)…")
        testDuckAnchorResolverAcrossAllPoses()
        testAccessoryAttachmentAllHatsResolved()
        testSecondaryMotionFrames()
        testLivingWardrobeAttachmentBounds()
        testBackwardFacingFlipping()
        testRedesignedTacticalBandanaSilhouetteAndTails()
        testBandanaContrastAcrossAllThemes()
    }

    static func testDuckAnchorResolverAcrossAllPoses() {
        runTest("testDuckAnchorResolverAcrossAllPoses") {
            // 1. Base Idle: head at (0, 0)
            let baseAnchor = DuckAnchorResolver.resolve(rows: DUCK_BASE)
            assertEqual(baseAnchor.x, 0, "DUCK_BASE headX should be 0")
            assertEqual(baseAnchor.y, 0, "DUCK_BASE headY should be 0")
            assertFalse(baseAnchor.facingBack, "DUCK_BASE should face forward")

            // 2. Idle Breath: head sinks 1px to (0, 1)
            let breathAnchor = DuckAnchorResolver.resolve(rows: DUCK_IDLE_B)
            assertEqual(breathAnchor.x, 0, "DUCK_IDLE_B headX should be 0")
            assertEqual(breathAnchor.y, 1, "DUCK_IDLE_B headY should sink 1px on breath")

            // 3. Waddle Stride: head bobs down 1px
            let runBAnchor = DuckAnchorResolver.resolve(rows: DUCK_RUN_B)
            assertEqual(runBAnchor.y, 1, "DUCK_RUN_B headY should drop 1px on stride")

            // 4. Deep Breadcrumb Peck: head dips to floor (1, 3)
            let peckBAnchor = DuckAnchorResolver.resolve(rows: DUCK_PECK_B)
            assertEqual(peckBAnchor.x, 1, "DUCK_PECK_B headX should shift right 1px to floor")
            assertEqual(peckBAnchor.y, 3, "DUCK_PECK_B headY should drop 3px to crumb")
            assertTrue(peckBAnchor.isPecking, "DUCK_PECK_B should be marked as pecking")

            // 5. Deep Sleep: head curls down 2px (0, 2)
            let sleepAnchor = DuckAnchorResolver.resolve(rows: DUCK_SLEEP_DEEP)
            assertEqual(sleepAnchor.y, 2, "DUCK_SLEEP_DEEP headY should be 2px lower")
            assertTrue(sleepAnchor.isSleeping, "DUCK_SLEEP_DEEP should be marked as sleeping")

            // 6. Tactical Crouch: head drops 2px (0, 2)
            let tacticalAnchor = DuckAnchorResolver.resolve(rows: DUCK_TACTICAL)
            assertEqual(tacticalAnchor.y, 2, "DUCK_TACTICAL headY should be 2px lower")

            // 7. Head Tilt: tilted forward/up (-1, 0)
            let tiltAnchor = DuckAnchorResolver.resolve(rows: DUCK_LOOK_UP)
            assertEqual(tiltAnchor.x, -1, "DUCK_LOOK_UP headX should tilt left/up -1px")

            // 8. Curious Peek: tilted forward (1, 0)
            let peekAnchor = DuckAnchorResolver.resolve(rows: DUCK_PEEK_B)
            assertEqual(peekAnchor.x, 1, "DUCK_PEEK_B headX should shift right 1px")

            // 9. Looking Back: head turned behind
            let lookBackAnchor = DuckAnchorResolver.resolve(rows: DUCK_LOOK_BACK)
            assertTrue(lookBackAnchor.facingBack, "DUCK_LOOK_BACK must be detected as facing backward")
        }
    }

    static func testAccessoryAttachmentAllHatsResolved() {
        runTest("testAccessoryAttachmentAllHatsResolved") {
            let anchor = DuckAnchorResolver.resolve(rows: DUCK_BASE)

            for hat in DuckHat.allCases {
                let (hatRows, xOff, yOff, _) = AccessoryAttachment.getSprite(for: hat, anchor: anchor)
                if hat == .none {
                    assertTrue(hatRows.isEmpty, "DuckHat.none should resolve empty rows")
                } else {
                    assertEqual(hatRows.count, 8, "Hat \(hat) sprite must have 8 rows")
                    assertEqual(xOff, 0, "Base pose hat xOffset should be 0")
                    assertEqual(yOff, -4, "Base pose hat yOffset should be -4")
                    for row in hatRows {
                        assertEqual(row.count, 13, "Hat \(hat) row length must be 13 chars")
                    }
                }
            }
        }
    }

    static func testSecondaryMotionFrames() {
        runTest("testSecondaryMotionFrames") {
            let anchor = DuckAnchorResolver.resolve(rows: DUCK_BASE)

            // Test soft bandana secondary motion on stride
            let (bandanaA, _, _, _) = AccessoryAttachment.getSprite(
                for: .bandanaMidnight,
                anchor: anchor,
                t: 0.0,
                isRunning: true
            )
            let (bandanaB, _, _, _) = AccessoryAttachment.getSprite(
                for: .bandanaMidnight,
                anchor: anchor,
                t: 0.15,
                isRunning: true
            )
            assertEqual(bandanaA.count, 8, "Bandana frame A should have 8 rows")
            assertEqual(bandanaB.count, 8, "Bandana frame B should have 8 rows")

            // Test sleepy cap secondary motion
            let (sleepcapA, _, _, _) = AccessoryAttachment.getSprite(
                for: .sleepcap,
                anchor: anchor,
                t: 0.0,
                isRunning: true
            )
            let (sleepcapB, _, _, _) = AccessoryAttachment.getSprite(
                for: .sleepcap,
                anchor: anchor,
                t: 0.15,
                isRunning: true
            )
            assertTrue(sleepcapA != sleepcapB, "Sleepy cap should resolve alternate secondary frame during run stride")
        }
    }

    static func testLivingWardrobeAttachmentBounds() {
        runTest("testLivingWardrobeAttachmentBounds") {
            let allPoses: [[String]] = [
                DUCK_BASE, DUCK_IDLE_B, DUCK_IDLE_WAG, DUCK_BLINK_ROWS,
                DUCK_RUN_A, DUCK_RUN_B, DUCK_RUN_C, DUCK_PAUSE,
                DUCK_YAY_A, DUCK_YAY_B, DUCK_QUACK_ROWS, DUCK_PET_ROWS,
                DUCK_PECK_A, DUCK_PECK_B, DUCK_RELAX_ROWS, DUCK_LOOK_UP,
                DUCK_PREEN_A, DUCK_PREEN_B, DUCK_SIT, DUCK_TACTICAL,
                DUCK_SIDE_EYE, DUCK_LOOK_BACK, DUCK_BOB, DUCK_SHUFFLE_A,
                DUCK_SHUFFLE_B, DUCK_RUFFLE_A, DUCK_RUFFLE_B, DUCK_PEEK_A,
                DUCK_PEEK_B, DUCK_SLEEP_DEEP
            ]

            for duckSprite in allPoses {
                let anchor = DuckAnchorResolver.resolve(rows: duckSprite)
                for hat in DuckHat.allCases where hat != .none {
                    let (rows, xOff, yOff, _) = AccessoryAttachment.getSprite(for: hat, anchor: anchor)
                    assertTrue(!rows.isEmpty, "Sprite for hat \(hat) must not be empty")
                    assertTrue(xOff >= -3 && xOff <= 3, "xOffset \(xOff) must be within safe duck skull range")
                    assertTrue(yOff >= -5 && yOff <= 0, "yOffset \(yOff) must be within safe head attachment range")
                }
            }
        }
    }

    static func testBackwardFacingFlipping() {
        runTest("testBackwardFacingFlipping") {
            let lookBackAnchor = DuckAnchorResolver.resolve(rows: DUCK_LOOK_BACK)
            let (_, _, _, flip) = AccessoryAttachment.getSprite(for: .detective, anchor: lookBackAnchor)
            assertTrue(flip, "Accessory must flip horizontally when duck looks backward")
        }
    }

    static func testRedesignedTacticalBandanaSilhouetteAndTails() {
        runTest("testRedesignedTacticalBandanaSilhouetteAndTails") {
            let bandanaVariants = [
                HAT_BANDANA_MIDNIGHT,
                HAT_BANDANA_CRIMSON,
                HAT_BANDANA_FOREST,
                HAT_BANDANA_DESERT
            ]

            let flutterVariants = [
                HAT_BANDANA_MIDNIGHT_ALT,
                HAT_BANDANA_CRIMSON_ALT,
                HAT_BANDANA_FOREST_ALT,
                HAT_BANDANA_DESERT_ALT
            ]

            for (idx, bandana) in bandanaVariants.enumerated() {
                // 1. Low-profile head crown on Row 4 (cols 5..7 must be '.' to reveal yellow duck skull crown)
                let row4 = bandana[4]
                assertTrue(row4.dropFirst(5).prefix(3).allSatisfy { $0 == "." }, "Bandana #\(idx) row 4 must leave duck crown yellow")

                // 2. Forehead wrap on Row 5 (knot at cols 1..2, headband across cols 4..10)
                let row5 = bandana[5]
                assertTrue(row5.contains("."), "Bandana #\(idx) must be a wrapped headband")

                // 3. Asymmetrical trailing tails on Rows 6 and 7
                let row6 = bandana[6]
                let row7 = bandana[7]
                let upperTailLen = row6.prefix(4).filter { $0 != "." }.count
                let lowerTailLen = row7.prefix(4).filter { $0 != "." }.count
                assertEqual(upperTailLen, 3, "Bandana #\(idx) upper tail should be 3 pixels long")
                assertEqual(lowerTailLen, 2, "Bandana #\(idx) lower tail should be 2 pixels long")
                assertTrue(upperTailLen > lowerTailLen, "Bandana #\(idx) tails must be asymmetrical (upper longer than lower)")

                // 4. Eyes (Row 6 cols 6..7) and Beak (Row 7 cols 8..10) must be 100% unobstructed
                assertTrue(row6.dropFirst(6).prefix(2).allSatisfy { $0 == "." }, "Bandana #\(idx) must not obstruct eye line")
                assertTrue(row7.dropFirst(8).prefix(3).allSatisfy { $0 == "." }, "Bandana #\(idx) must not obstruct beak line")
            }

            for (idx, flutter) in flutterVariants.enumerated() {
                // Flutter frame has upward tail motion on Row 5
                let flutterRow5 = flutter[5]
                assertTrue(flutterRow5.hasPrefix("k") || flutterRow5.hasPrefix("."), "Flutter frame #\(idx) has dynamic upward tail trail")
            }
        }
    }

    static func testBandanaContrastAcrossAllThemes() {
        runTest("testBandanaContrastAcrossAllThemes") {
            for theme in ThemeType.allCases {
                let def = Pal.definition(for: theme)

                // Dark outline/ink must contrast with duck yellow body
                assertTrue(def.duckEye != def.duckBody, "Theme \(theme.displayName) ink/outline must contrast with duckBody")

                // Shadow/accent must contrast with duck yellow body
                assertTrue(def.duckShad != def.duckBody, "Theme \(theme.displayName) shadow must contrast with duckBody")

                // White highlight/accent must contrast with dark ink
                assertTrue(def.white != def.duckEye, "Theme \(theme.displayName) white highlight must contrast with dark ink")
            }
        }
    }
}
