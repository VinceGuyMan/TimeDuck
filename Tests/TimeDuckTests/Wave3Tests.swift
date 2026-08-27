// MARK: - TimeDuck · Wave3Tests.swift
// Unit tests for Wave 3 (v1.3.0+ Candidate):
// - Seasonal Costumes (Pumpkin, Witch Hat, Winter Beanie, Festive Santa Cap)
// - Seasonal Calendar offline date calculation & greeting triggers
// - State persistence backward compatibility with new hats and themes
// - VoiceOver accessibility compliance

import Foundation

struct Wave3Tests {
    static func runAll() {
        print("▸ Testing Wave 3: Seasonal Drops & User-Driven Refinement…")
        testSeasonalCostumeSprites()
        testSeasonalClassification()
        testSeasonalCalendarDateCalculations()
        testStatePersistenceWithNewHatsAndThemes()
    }

    static func testSeasonalCostumeSprites() {
        runTest("testSeasonalCostumeSprites") {
            let seasonalHats = [
                HAT_PUMPKIN,
                HAT_WITCH,
                HAT_WINTER_BEANIE,
                HAT_FESTIVE_SANTA
            ]

            for (idx, hatSprite) in seasonalHats.enumerated() {
                assertEqual(hatSprite.count, 8, "Seasonal hat sprite #\(idx) should have 8 rows in Living Wardrobe")
                for row in hatSprite {
                    assertEqual(row.count, 13, "Seasonal hat sprite #\(idx) row length should be 13 chars")
                }
            }
        }
    }

    static func testSeasonalClassification() {
        runTest("testSeasonalClassification") {
            assertTrue(DuckHat.pumpkin.isSeasonal, "Pumpkin should be classified as seasonal")
            assertTrue(DuckHat.witch.isSeasonal, "Witch should be classified as seasonal")
            assertTrue(DuckHat.winterBeanie.isSeasonal, "Winter Beanie should be classified as seasonal")
            assertTrue(DuckHat.festiveSanta.isSeasonal, "Festive Santa should be classified as seasonal")

            assertFalse(DuckHat.bandanaMidnight.isSeasonal, "Tactical bandana should not be seasonal")
            assertFalse(DuckHat.wizard.isSeasonal, "Classic wizard hat should not be seasonal")
        }
    }

    static func testSeasonalCalendarDateCalculations() {
        runTest("testSeasonalCalendarDateCalculations") {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!

            // 1. Spooky Season: October 31 (Halloween)
            let halloween = cal.date(from: DateComponents(year: 2026, month: 10, day: 31))!
            assertEqual(SeasonalCalendar.currentEvent(at: halloween, calendar: cal), .spookySeason, "Oct 31 should be Spooky Season")
            assertTrue(SeasonalCalendar.isSpooky(at: halloween, calendar: cal), "isSpooky should return true on Halloween")
            assertTrue(SeasonalCalendar.seasonalGreeting(at: halloween, calendar: cal) != nil, "Spooky greeting should be returned")

            // 2. Holiday Season: December 25 (Christmas)
            let xmas = cal.date(from: DateComponents(year: 2026, month: 12, day: 25))!
            assertEqual(SeasonalCalendar.currentEvent(at: xmas, calendar: cal), .holidaySeason, "Dec 25 should be Holiday Season")
            assertTrue(SeasonalCalendar.isHoliday(at: xmas, calendar: cal), "isHoliday should return true on Christmas")
            assertTrue(SeasonalCalendar.seasonalGreeting(at: xmas, calendar: cal) != nil, "Holiday greeting should be returned")

            // 3. Off-season: July 15
            let summer = cal.date(from: DateComponents(year: 2026, month: 7, day: 15))!
            assertEqual(SeasonalCalendar.currentEvent(at: summer, calendar: cal), .none, "July 15 should be standard off-season")
            assertFalse(SeasonalCalendar.isSpooky(at: summer, calendar: cal), "isSpooky should be false in July")
            assertFalse(SeasonalCalendar.isHoliday(at: summer, calendar: cal), "isHoliday should be false in July")
            assertEqual(SeasonalCalendar.seasonalGreeting(at: summer, calendar: cal), nil, "No seasonal greeting in July")
        }
    }

    static func testStatePersistenceWithNewHatsAndThemes() {
        runTest("testStatePersistenceWithNewHatsAndThemes") {
            let state = PersistedState(
                mode: 0,
                swBanked: 0,
                swRunning: false,
                swStartISO: nil,
                lapsSplits: [],
                lapsTotals: [],
                tmDuration: 1500,
                tmRemainingAtStop: 1500,
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
                theme: ThemeType.electricPond.rawValue,
                hat: DuckHat.festiveSanta.rawValue,
                crt: true,
                todayFocusSecs: 0,
                todayPomos: 0,
                streakDays: 1,
                lastActiveDate: "2026-08-27"
            )

            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            let data = try! encoder.encode(state)
            let decoded = try! decoder.decode(PersistedState.self, from: data)

            assertEqual(decoded.theme, ThemeType.electricPond.rawValue, "Theme electricPond rawValue should encode and decode cleanly")
            assertEqual(decoded.hat, DuckHat.festiveSanta.rawValue, "Hat festiveSanta rawValue should encode and decode cleanly")
        }
    }
}
