// MARK: - TimeDuck · Wave1Tests.swift
// Unit tests for Wave 1 (v1.1.0 Candidate):
// - Tactical Bandana collection (Midnight, Crimson, Forest Camo, Desert Camo)
// - New idle animations (feather ruffle, curious peek)
// - Expanded phrase engine (20+ lines, context categories, anti-repetition)
// - 3 New CRT Palettes (Terminal Green, Paperwhite, Electric Pond)

import Foundation

struct Wave1Tests {
    static func runAll() {
        print("▸ Testing Wave 1: Tactical Duck & Expressive Companion…")
        testTacticalBandanaSprites()
        testTacticalBandanaClassification()
        testFeatherRuffleAndCuriousPeekAnimations()
        testExpandedPhraseEngine()
        testNewCRTPalettes()
    }

    static func testTacticalBandanaSprites() {
        runTest("testTacticalBandanaSprites") {
            let bandanas = [
                HAT_BANDANA_MIDNIGHT,
                HAT_BANDANA_CRIMSON,
                HAT_BANDANA_FOREST,
                HAT_BANDANA_DESERT
            ]

            for (idx, bandana) in bandanas.enumerated() {
                assertEqual(bandana.count, 8, "Bandana sprite #\(idx) should have 8 rows in Living Wardrobe")
                for row in bandana {
                    assertEqual(row.count, 13, "Bandana sprite #\(idx) row length should be 13 chars")
                }
            }
        }
    }

    static func testTacticalBandanaClassification() {
        runTest("testTacticalBandanaClassification") {
            assertTrue(DuckHat.bandanaMidnight.isTacticalBandana, "Midnight should be classified as tactical bandana")
            assertTrue(DuckHat.bandanaCrimson.isTacticalBandana, "Crimson should be classified as tactical bandana")
            assertTrue(DuckHat.bandanaForestCamo.isTacticalBandana, "Forest Camo should be classified as tactical bandana")
            assertTrue(DuckHat.bandanaDesertCamo.isTacticalBandana, "Desert Camo should be classified as tactical bandana")

            assertFalse(DuckHat.wizard.isTacticalBandana, "Wizard should not be classified as tactical bandana")
            assertFalse(DuckHat.none.isTacticalBandana, "None should not be classified as tactical bandana")
        }
    }

    static func testFeatherRuffleAndCuriousPeekAnimations() {
        runTest("testFeatherRuffleAndCuriousPeekAnimations") {
            let brain = DuckBrain()
            let now = Date()

            // 1. Feather Ruffle
            brain.setPose(.featherRuffle, duration: 2.0)
            let ruffleRowsA = brain.getSpriteRows(
                t: 0.0, now: now, isFlapping: false, isQuacking: false, isPetting: false,
                isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false,
                stridePhase: 0, blinkUntil: .distantPast
            )
            let ruffleRowsB = brain.getSpriteRows(
                t: 0.2, now: now, isFlapping: false, isQuacking: false, isPetting: false,
                isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false,
                stridePhase: 0, blinkUntil: .distantPast
            )
            assertEqual(ruffleRowsA.count, 10, "Feather ruffle frame A must have 10 rows")
            assertEqual(ruffleRowsB.count, 10, "Feather ruffle frame B must have 10 rows")

            // 2. Curious Peek
            brain.setPose(.curiousPeek, duration: 2.0)
            let peekRowsA = brain.getSpriteRows(
                t: 0.0, now: now, isFlapping: false, isQuacking: false, isPetting: false,
                isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false,
                stridePhase: 0, blinkUntil: .distantPast
            )
            let peekRowsB = brain.getSpriteRows(
                t: 0.3, now: now, isFlapping: false, isQuacking: false, isPetting: false,
                isEating: false, isBreakRunning: false, isRunning: false, isSleeping: false,
                stridePhase: 0, blinkUntil: .distantPast
            )
            assertEqual(peekRowsA.count, 10, "Curious peek frame A must have 10 rows")
            assertEqual(peekRowsB.count, 10, "Curious peek frame B must have 10 rows")
        }
    }

    static func testExpandedPhraseEngine() {
        runTest("testExpandedPhraseEngine") {
            let bandanaHats: [DuckHat] = [
                .bandanaMidnight, .bandanaCrimson, .bandanaForestCamo, .bandanaDesertCamo
            ]
            for hat in bandanaHats {
                let phrase = DuckPhrase.get(for: .hatChange(hat))
                assertTrue(!phrase.isEmpty, "Bandana phrase for \(hat) must not be empty")
                assertTrue(phrase.count <= 26, "Bandana phrase must fit display width (<= 26 chars)")
            }

            let newThemes: [ThemeType] = [.terminal, .paperwhite, .electricPond]
            for theme in newThemes {
                let phrase = DuckPhrase.get(for: .themeChange(theme))
                assertTrue(!phrase.isEmpty, "Theme phrase for \(theme) must not be empty")
                assertTrue(phrase.count <= 26, "Theme phrase must fit display width (<= 26 chars)")
            }
        }
    }

    static func testNewCRTPalettes() {
        runTest("testNewCRTPalettes") {
            let themes: [ThemeType] = [.terminal, .paperwhite, .electricPond]
            for theme in themes {
                let def = Pal.definition(for: theme)
                assertTrue(def.bg != def.ink, "Theme \(theme.displayName) background must differ from primary ink")
                assertTrue(def.green != def.red, "Theme \(theme.displayName) green status color must differ from red alert")

                // Test rainbow color generation
                ThemeRegistry.current = theme
                let rainbowColor = rainbow(0.5)
                assertTrue(rainbowColor > 0, "Rainbow color value must be positive")
            }
            // Restore default
            ThemeRegistry.current = .arcade
        }
    }
}
