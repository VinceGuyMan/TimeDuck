// MARK: - TimeDuck · DuckBrainTests.swift
// Unit tests for duck phrases, behavioral phases, poke escalation, and sprite frames.

import Foundation

struct DuckBrainTests {
    static func runAll() {
        print("▸ Testing Duck Brain & Personality Engine…")
        testPhraseCategories()
        testAntiRepetition()
        testPokeEscalation()
        testBehaviorPhases()
        testPoseTransitions()
        testSpriteResolvers()
        testBreadcrumbPeckAnimationFrames()
        testRareMoments()
        testMusicSoundIndependence()
    }

    static func testPhraseCategories() {
        runTest("testPhraseCategories") {
            let categories: [DuckPhrase.Category] = [
                .idle, .timerReady, .timerStart, .timerEarly, .timerHalfway,
                .timerAlmost, .timerFinal, .timerPaused, .timerResumed, .timerComplete,
                .stopwatchRunning, .stopwatchLong, .stopwatchLap, .pomoFocus, .pomoBreak,
                .pomoStreak, .wakeUp, .crumb, .rare,
                .poke(level: 1), .poke(level: 5),
                .hatChange(.wizard), .hatChange(.crown),
                .themeChange(.arcade), .themeChange(.amber),
                .soundToggle(true), .soundToggle(false)
            ]

            for cat in categories {
                let phrase = DuckPhrase.get(for: cat)
                assertTrue(!phrase.isEmpty, "Phrase for \(cat) should not be empty")
                assertTrue(phrase.count <= 26, "Phrase '\(phrase)' should fit within UI boundaries (<= 26 chars)")
            }
        }
    }

    static func testAntiRepetition() {
        runTest("testAntiRepetition") {
            var seen = Set<String>()
            for _ in 0..<20 {
                seen.insert(DuckPhrase.get(for: .idle))
            }
            assertTrue(seen.count > 1, "Phrase generator should pick diverse phrases from pool")
        }
    }

    static func testPokeEscalation() {
        runTest("testPokeEscalation") {
            let brain = DuckBrain()
            let p1 = brain.onPoke()
            assertEqual(p1.level, 1, "Initial poke should be level 1")

            let p2 = brain.onPoke()
            assertEqual(p2.level, 2, "Second immediate poke should be level 2")

            let p3 = brain.onPoke()
            assertEqual(p3.level, 3, "Third immediate poke should be level 3")

            let p4 = brain.onPoke()
            assertEqual(p4.level, 4, "Fourth immediate poke should be level 4")

            let p5 = brain.onPoke()
            assertTrue(p5.level >= 5, "Fifth immediate poke should be level 5 or higher")
            assertEqual(brain.currentPose, .tactical, "High-level poke should trigger tactical pose")
        }
    }

    static func testBehaviorPhases() {
        runTest("testBehaviorPhases") {
            let brain = DuckBrain()
            let now = Date()

            // 1. Relaxed when nothing is running
            brain.update(
                dt: 0.1, now: now, mode: .timer,
                isRunning: false, isFinished: false,
                remainingFraction: 1.0, remainingSeconds: 300, elapsedSeconds: 0,
                userInactivitySeconds: 5, duckCurX: 100, gridW: 164,
                onWanderTarget: { _ in }, onSpeak: { _, _ in }
            )
            assertEqual(brain.currentPhase, .relaxed, "Inactive session should be relaxed phase")

            // 2. Focus when running
            brain.update(
                dt: 0.1, now: now, mode: .timer,
                isRunning: true, isFinished: false,
                remainingFraction: 0.8, remainingSeconds: 240, elapsedSeconds: 60,
                userInactivitySeconds: 5, duckCurX: 100, gridW: 164,
                onWanderTarget: { _ in }, onSpeak: { _, _ in }
            )
            assertEqual(brain.currentPhase, .focus, "Running session should be focus phase")

            // 3. Urgency when < 10s
            brain.update(
                dt: 0.1, now: now, mode: .timer,
                isRunning: true, isFinished: false,
                remainingFraction: 0.02, remainingSeconds: 5, elapsedSeconds: 295,
                userInactivitySeconds: 5, duckCurX: 100, gridW: 164,
                onWanderTarget: { _ in }, onSpeak: { _, _ in }
            )
            assertEqual(brain.currentPhase, .urgency, "Session under 10s should be urgency phase")

            // 4. Victory when isFinished
            brain.update(
                dt: 0.1, now: now, mode: .timer,
                isRunning: false, isFinished: true,
                remainingFraction: 0.0, remainingSeconds: 0, elapsedSeconds: 300,
                userInactivitySeconds: 5, duckCurX: 100, gridW: 164,
                onWanderTarget: { _ in }, onSpeak: { _, _ in }
            )
            assertEqual(brain.currentPhase, .victory, "Finished session should be victory phase")

            // 5. Sleepy after 40s inactivity
            brain.update(
                dt: 0.1, now: now, mode: .timer,
                isRunning: false, isFinished: false,
                remainingFraction: 1.0, remainingSeconds: 300, elapsedSeconds: 0,
                userInactivitySeconds: 45, duckCurX: 100, gridW: 164,
                onWanderTarget: { _ in }, onSpeak: { _, _ in }
            )
            assertEqual(brain.currentPhase, .sleepy, "Inactive for 45s should enter sleepy phase")
        }
    }

    static func testPoseTransitions() {
        runTest("testPoseTransitions") {
            let brain = DuckBrain()
            brain.setPose(.preening, duration: 1.0)
            assertEqual(brain.currentPose, .preening, "Pose should be preening")
            assertTrue(brain.hasActivePose, "hasActivePose should be true")

            brain.setPose(.sitting, duration: 1.0)
            assertEqual(brain.currentPose, .sitting, "Pose should be sitting")

            brain.setPose(.tactical, duration: 1.0)
            assertEqual(brain.currentPose, .tactical, "Pose should be tactical")
        }
    }

    static func testSpriteResolvers() {
        runTest("testSpriteResolvers") {
            let brain = DuckBrain()
            let now = Date()
            let poses: [DuckPose] = [
                .standing, .waddling, .celebrating, .quacking, .petting,
                .pecking, .relaxing, .sleeping, .headTilt, .preening,
                .sitting, .tactical, .sideEye, .lookingBack, .grooving, .shuffling
            ]

            for pose in poses {
                brain.setPose(pose, duration: 2.0)
                let rows = brain.getSpriteRows(
                    t: 1.0, now: now,
                    isFlapping: false, isQuacking: false, isPetting: false,
                    isEating: false, isBreakRunning: false, isRunning: false,
                    isSleeping: false, stridePhase: 0, blinkUntil: .distantPast
                )
                assertEqual(rows.count, 10, "Sprite for \(pose) must have 10 rows")
                for r in rows {
                    assertEqual(r.count, 13, "Sprite row '\(r)' for \(pose) must have 13 columns")
                }
            }
        }
    }

    static func testBreadcrumbPeckAnimationFrames() {
        runTest("testBreadcrumbPeckAnimationFrames") {
            // Verify DUCK_PECK_A & DUCK_PECK_B geometry
            assertEqual(DUCK_PECK_A.count, 10, "DUCK_PECK_A must have 10 rows")
            assertEqual(DUCK_PECK_B.count, 10, "DUCK_PECK_B must have 10 rows")
            
            // In DUCK_PECK_A: feet on row 9, beak reaches forward/down
            assertTrue(DUCK_PECK_A[9].contains("oo..oo"), "DUCK_PECK_A feet must be grounded at row 9")
            assertTrue(DUCK_PECK_A[5].contains("ooo") || DUCK_PECK_A[6].contains("oo"), "DUCK_PECK_A beak must lead downward arc")
            
            // In DUCK_PECK_B: beak contacts ground level at row 9, crown is high up at row 3
            assertTrue(DUCK_PECK_B[9].hasSuffix("o."), "DUCK_PECK_B beak tip must contact ground row 9")
            assertTrue(DUCK_PECK_B[8].hasSuffix("ooo"), "DUCK_PECK_B beak body must reach cols 10-12")
            assertTrue(DUCK_PECK_B[3].contains("yyyy"), "DUCK_PECK_B crown must be at row 3 (not colliding forehead-first)")
            
            // Verify brain eating frame alternation
            let brain = DuckBrain()
            let eatingRowsA = brain.getSpriteRows(
                t: 0.0, now: Date(),
                isFlapping: false, isQuacking: false, isPetting: false,
                isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast
            )
            assertEqual(eatingRowsA, DUCK_PECK_A, "Eating at t=0 should resolve to DUCK_PECK_A")
            
            let eatingRowsB = brain.getSpriteRows(
                t: 0.2, now: Date(),
                isFlapping: false, isQuacking: false, isPetting: false,
                isEating: true, isBreakRunning: false, isRunning: false,
                isSleeping: false, stridePhase: 0, blinkUntil: .distantPast
            )
            assertEqual(eatingRowsB, DUCK_PECK_B, "Eating at t=0.2 should resolve to DUCK_PECK_B")
        }
    }

    static func testRareMoments() {
        runTest("testRareMoments") {
            let brain = DuckBrain()
            let quip = DuckPhrase.get(for: .rare)
            assertTrue(!quip.isEmpty, "Rare quip should be populated")

            let lapQuip = brain.onLap()
            assertTrue(!lapQuip.isEmpty, "Lap quip should be populated")

            let hatQuip = brain.onHatChange(.wizard)
            assertTrue(!hatQuip.isEmpty, "Hat quip should be populated")
        }
    }

    static func testMusicSoundIndependence() {
        runTest("testMusicSoundIndependence") {
            let userDefaults = UserDefaults.standard
            let originalMusic = userDefaults.object(forKey: "td.music")
            let originalSound = userDefaults.object(forKey: "td.sound")

            userDefaults.set(true, forKey: "td.music")
            userDefaults.set(false, forKey: "td.sound")

            let musicOn = userDefaults.bool(forKey: "td.music")
            let soundOn = userDefaults.bool(forKey: "td.sound")
            assertTrue(musicOn, "Music should be enabled")
            assertTrue(!soundOn, "Sound should be disabled")

            // Restore
            if let om = originalMusic { userDefaults.set(om, forKey: "td.music") } else { userDefaults.removeObject(forKey: "td.music") }
            if let os = originalSound { userDefaults.set(os, forKey: "td.sound") } else { userDefaults.removeObject(forKey: "td.sound") }
        }
    }
}
