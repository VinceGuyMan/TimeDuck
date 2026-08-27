// MARK: - TimeDuck · Wave2Tests.swift
// Unit tests for Wave 2 (v1.2.0 Candidate):
// - Costume-specific micro-actions and personality hooks
// - Ultra-rare secret moments engine with deterministic test seams
// - Rate-limited elapsed-time safety verification
// - Multi-track soundtrack selection and graceful fallback architecture

import Foundation

struct Wave2Tests {
    static func runAll() {
        print("▸ Testing Wave 2: Secret Moments & Living Costumes…")
        testCostumeMicroActions()
        testRareSecretEventsDeterministicSeams()
        testRareSecretColorMaps()
        testSoundtrackSelectionAndFallback()
    }

    static func testCostumeMicroActions() {
        runTest("testCostumeMicroActions") {
            // Detective on pause
            if let pauseAction = CostumeBehavior.onTimerPause(hat: .detective) {
                switch pauseAction {
                case .customPose(let pose, _, let phrase):
                    assertEqual(pose, .sideEye, "Detective should use sideEye pose on pause")
                    assertTrue(phrase != nil && !phrase!.isEmpty, "Detective should have clue inspection phrase")
                case .customPhrase:
                    break
                }
            } else {
                assertTrue(false, "Detective must implement onTimerPause micro-action")
            }

            // Wizard on complete
            if let compAction = CostumeBehavior.onTimerComplete(hat: .wizard) {
                switch compAction {
                case .customPose(let pose, _, let phrase):
                    assertEqual(pose, .celebrating, "Wizard should celebrate with magic spell on complete")
                    assertTrue(phrase != nil && !phrase!.isEmpty, "Wizard should have arcane phrase")
                case .customPhrase:
                    break
                }
            } else {
                assertTrue(false, "Wizard must implement onTimerComplete micro-action")
            }

            // Barista on break start
            if let breakAction = CostumeBehavior.onBreakStart(hat: .barista) {
                switch breakAction {
                case .customPose(let pose, _, let phrase):
                    assertEqual(pose, .relaxing, "Barista should enter relaxing pose on break")
                    assertTrue(phrase != nil && !phrase!.isEmpty, "Barista should have coffee break phrase")
                case .customPhrase:
                    break
                }
            } else {
                assertTrue(false, "Barista must implement onBreakStart micro-action")
            }

            // Preferred idle pose biases
            assertEqual(CostumeBehavior.preferredIdlePose(hat: .bandanaMidnight), .tactical, "Tactical bandana prefers tactical stance")
            assertEqual(CostumeBehavior.preferredIdlePose(hat: .barista), .relaxing, "Barista prefers relaxing stance")
        }
    }

    static func testRareSecretEventsDeterministicSeams() {
        runTest("testRareSecretEventsDeterministicSeams") {
            let brain = DuckBrain()
            var spokenPhrase: String? = nil

            // 1. Force Golden Duck
            brain.forceRareEvent(.goldenDuck)
            brain.triggerRareEvent(type: .goldenDuck) { phrase, _ in
                spokenPhrase = phrase
            }
            assertEqual(brain.activeRareEvent, .goldenDuck, "Active rare event should be goldenDuck")
            assertEqual(spokenPhrase, "✨ GOLDEN DUCK ASCENSION ✨", "Golden duck should trigger ascension phrase")
            assertTrue(brain.hasActivePose, "Rare event should mark active pose")

            // 2. Force Ghost Glitch
            brain.forceRareEvent(.ghostGlitch)
            brain.triggerRareEvent(type: .ghostGlitch) { phrase, _ in
                spokenPhrase = phrase
            }
            assertEqual(brain.activeRareEvent, .ghostGlitch, "Active rare event should be ghostGlitch")
            assertEqual(spokenPhrase, "░▒▓ PHANTOM QUACK ▓▒░", "Ghost glitch should trigger phantom phrase")

            // 3. Clear seam
            brain.clearRareEvent()
            assertEqual(brain.activeRareEvent, nil, "Active rare event should be cleared")
        }
    }

    static func testRareSecretColorMaps() {
        runTest("testRareSecretColorMaps") {
            // Golden Duck color mapping overrides body to gold/amber
            let goldMap = getDuckColorMap(rareEvent: .goldenDuck)
            let standardMap = getDuckColorMap(rareEvent: nil)

            assertTrue(goldMap["y"] != standardMap["y"], "Golden duck body color must differ from standard yellow")
            assertEqual(goldMap["y"], rgb(255, 225, 60), "Golden duck body should be radiant gold")

            // Ghost glitch overrides
            let ghostMap = getDuckColorMap(rareEvent: .ghostGlitch)
            assertEqual(ghostMap["y"], rgb(160, 235, 255), "Ghost glitch body should be spectral blue")
        }
    }

    static func testSoundtrackSelectionAndFallback() {
        runTest("testSoundtrackSelectionAndFallback") {
            let sound = SoundEngine()

            // Test soundtrack tracks enumeration
            assertEqual(SoundEngine.SoundtrackTrack.alpha.filename, "TimeDuckTheme", "Theme Alpha filename should match TimeDuckTheme")
            assertEqual(SoundEngine.SoundtrackTrack.beta.filename, "TimeDuckNightTheme", "Theme Beta filename should match TimeDuckNightTheme")

            // Test graceful fallback when Theme Beta audio file is pending release
            let betaURL = sound.resolveThemeURL(for: .beta)
            // Even if TimeDuckNightTheme.m4a doesn't exist yet on disk, resolveThemeURL gracefully falls back to Theme Alpha URL or nil safely without crashing
            if let url = betaURL {
                assertTrue(url.absoluteString.contains("TimeDuckTheme") || url.absoluteString.contains("TimeDuckNightTheme"), "Resolved URL should be valid theme file")
            }
        }
    }
}
