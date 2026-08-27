// MARK: - TimeDuck · PersistenceTests.swift

import Foundation

enum PersistenceTests {
    static func runAll() {
        print("")
        print("▸ Testing JSON State Persistence…")

        runTest("testPersistedStateEncodeDecodeRoundtrip") {
            let original = PersistedState(
                mode: 2,
                swBanked: 45.2,
                swRunning: false,
                swStartISO: nil,
                lapsSplits: [10.0, 35.2],
                lapsTotals: [10.0, 45.2],
                tmDuration: 600,
                tmRemainingAtStop: 420,
                tmRunning: true,
                tmEndISO: "2026-08-26T20:00:00Z",
                tmCompletionRecorded: true,
                pomoPhase: 1,
                pomoCycles: 3,
                pomoWorkDuration: 3000,
                pomoRemainingAtStop: 300,
                pomoRunning: false,
                pomoEndISO: nil,
                pomoCompletionRecorded: false,
                theme: 3,
                hat: 2,
                crt: true,
                todayFocusSecs: 4500,
                todayPomos: 3,
                streakDays: 4,
                lastActiveDate: "2026-08-26"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(original)

            let decoder = JSONDecoder()
            let decoded = try decoder.decode(PersistedState.self, from: data)

            assertEqual(decoded.mode, original.mode)
            assertEqual(decoded.swBanked, original.swBanked)
            assertEqual(decoded.swRunning, original.swRunning)
            assertEqual(decoded.lapsSplits, original.lapsSplits)
            assertEqual(decoded.tmDuration, original.tmDuration)
            assertEqual(decoded.tmRemainingAtStop, original.tmRemainingAtStop)
            assertEqual(decoded.tmCompletionRecorded, original.tmCompletionRecorded)
            assertEqual(decoded.pomoWorkDuration, original.pomoWorkDuration)
            assertEqual(decoded.todayFocusSecs, original.todayFocusSecs)
            assertEqual(decoded.streakDays, original.streakDays)
        }

        runTest("testCorruptJSONHandling") {
            let corruptData = "{\"invalid\": 123, broken".data(using: .utf8)!
            let decoded = try? JSONDecoder().decode(PersistedState.self, from: corruptData)
            assertNil(decoded)
        }
    }
}
