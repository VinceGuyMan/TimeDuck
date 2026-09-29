// MARK: - TimeDuck · Wave1Tests.swift
// Unit tests for Wave 1 (v1.1.0 Candidate):
// - Tactical Bandana collection (Midnight, Crimson, Forest Camo, Desert Camo)
// - New idle animations (feather ruffle, curious peek)
// - Expanded phrase engine (20+ lines, context categories, anti-repetition)
// - 3 New CRT Palettes (Terminal Green, Paperwhite, Electric Pond)
// - State persistence compatibility with new hats and themes

import Foundation

struct Wave1Tests {
    static func runAll() {
        print("▸ Testing Wave 1: Tactical Duck & Expressive Companion…")
        testTacticalBandanaSprites()
        testTacticalBandanaClassification()
        testFeatherRuffleAndCuriousPeekAnimations()
        testExpandedPhraseEngine()
        testNewCRTPalettes()
        testStatePersistenceWithNewHatsAndThemes()
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
                assertEqual(bandana.count, 8, "Bandana sprite #\(idx) should have 8 rows")
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
            assertEqual(ruffleRowsA, DUCK_RUFFLE_A, "Frame A must match DUCK_RUFFLE_A")
            assertEqual(ruffleRowsB, DUCK_RUFFLE_B, "Frame B must match DUCK_RUFFLE_B")

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
            assertEqual(peekRowsA, DUCK_PEEK_A, "Frame A must match DUCK_PEEK_A")
            assertEqual(peekRowsB, DUCK_PEEK_B, "Frame B must match DUCK_PEEK_B")
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

    static func testStatePersistenceWithNewHatsAndThemes() {
        runTest("testStatePersistenceWithNewHatsAndThemes") {
            let bandanaHats: [DuckHat] = [.bandanaMidnight, .bandanaCrimson, .bandanaForestCamo, .bandanaDesertCamo]
            let newThemes: [ThemeType] = [.terminal, .paperwhite, .electricPond]

            for hat in bandanaHats {
                let state = PersistedState(
                    mode: 0,
                    swBanked: 0,
                    swRunning: false,
                    swStartISO: nil,
                    lapsSplits: [],
                    lapsTotals: [],
                    tmDuration: 300,
                    tmRemainingAtStop: 300,
                    tmRunning: false,
                    tmEndISO: nil,
                    tmCompletionRecorded: false,
                    pomoPhase: 0,
                    pomoCycles: 0,
                    pomoWorkDuration: 1500,
                    pomoShortBreakDuration: 300,
                    pomoLongBreakDuration: 900,
                    pomoRemainingAtStop: 1500,
                    pomoRunning: false,
                    pomoEndISO: nil,
                    pomoCompletionRecorded: false,
                    theme: 0,
                    hat: hat.rawValue,
                    crt: true,
                    todayFocusSecs: 0,
                    todayPomos: 0,
                    streakDays: 1,
                    lastActiveDate: "2026-08-31"
                )

                let encoder = JSONEncoder()
                let data = try encoder.encode(state)
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(PersistedState.self, from: data)

                assertEqual(decoded.hat, hat.rawValue, "Decoded hat raw value must match original \(hat)")
                let decodedHat = decoded.hat.flatMap { DuckHat(rawValue: $0) }
                assertEqual(decodedHat, hat, "Decoded DuckHat must match \(hat)")
            }

            for theme in newThemes {
                let state = PersistedState(
                    mode: 0,
                    swBanked: 0,
                    swRunning: false,
                    swStartISO: nil,
                    lapsSplits: [],
                    lapsTotals: [],
                    tmDuration: 300,
                    tmRemainingAtStop: 300,
                    tmRunning: false,
                    tmEndISO: nil,
                    tmCompletionRecorded: false,
                    pomoPhase: 0,
                    pomoCycles: 0,
                    pomoWorkDuration: 1500,
                    pomoShortBreakDuration: 300,
                    pomoLongBreakDuration: 900,
                    pomoRemainingAtStop: 1500,
                    pomoRunning: false,
                    pomoEndISO: nil,
                    pomoCompletionRecorded: false,
                    theme: theme.rawValue,
                    hat: 0,
                    crt: true,
                    todayFocusSecs: 0,
                    todayPomos: 0,
                    streakDays: 1,
                    lastActiveDate: "2026-08-31"
                )

                let encoder = JSONEncoder()
                let data = try encoder.encode(state)
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(PersistedState.self, from: data)

                assertEqual(decoded.theme, theme.rawValue, "Decoded theme raw value must match original \(theme)")
                let decodedTheme = decoded.theme.flatMap { ThemeType(rawValue: $0) }
                assertEqual(decodedTheme, theme, "Decoded ThemeType must match \(theme)")
            }
        }
    }
}
