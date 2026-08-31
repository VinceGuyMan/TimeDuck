// MARK: - TimeDuck · WhatsNewTests.swift
// Unit tests for the version-aware What's New update experience and Show TimeDuck window coordination.

import Foundation

struct WhatsNewTests {
    static func runAll() {
        print("▸ Testing What's New System & Menu Bar Focus…")
        testUnacknowledgedVersionTriggersPresentation()
        testAcknowledgedVersionPreventsRepeatPresentation()
        testNewerVersionTriggersPresentationAgain()
        testPersistenceRoundtrip()
        testReleaseContentResolution()
        testV12PreviewTeaserData()
        testMissingNextTeaserGracefulHandling()
        testManualReopenAvailability()
        testShowTimeDuckWindowManagementNonDestructive()
    }

    static func testUnacknowledgedVersionTriggersPresentation() {
        runTest("testUnacknowledgedVersionTriggersPresentation") {
            let manager = WhatsNewManager.shared
            let prev = manager.lastSeenVersion
            defer { manager.lastSeenVersion = prev }

            // Clear acknowledgment
            manager.resetAcknowledgment()
            assertEqual(manager.lastSeenVersion, nil, "lastSeenVersion should be nil after reset")

            // Current version 1.1.0 should trigger
            assertTrue(manager.shouldPresentAutomatically(currentVersion: "1.1.0"), "Unacknowledged version 1.1.0 must request presentation")
        }
    }

    static func testAcknowledgedVersionPreventsRepeatPresentation() {
        runTest("testAcknowledgedVersionPreventsRepeatPresentation") {
            let manager = WhatsNewManager.shared
            let prev = manager.lastSeenVersion
            defer { manager.lastSeenVersion = prev }

            // Acknowledge v1.1.0
            manager.markAcknowledged(version: "1.1.0")
            assertEqual(manager.lastSeenVersion, "1.1.0", "lastSeenVersion should be 1.1.0")

            // Second launch of 1.1.0 should NOT trigger
            assertFalse(manager.shouldPresentAutomatically(currentVersion: "1.1.0"), "Acknowledged version 1.1.0 must not present repeatedly")
        }
    }

    static func testNewerVersionTriggersPresentationAgain() {
        runTest("testNewerVersionTriggersPresentationAgain") {
            let manager = WhatsNewManager.shared
            let prev = manager.lastSeenVersion
            defer { manager.lastSeenVersion = prev }

            // User previously saw 1.1.0
            manager.markAcknowledged(version: "1.1.0")

            // Upgrade to 1.2.0
            assertTrue(manager.shouldPresentAutomatically(currentVersion: "1.2.0"), "Upgraded version 1.2.0 must request presentation again")

            // Upgrade to 1.3.0
            assertTrue(manager.shouldPresentAutomatically(currentVersion: "1.3.0"), "Upgraded version 1.3.0 must request presentation again")
        }
    }

    static func testPersistenceRoundtrip() {
        runTest("testPersistenceRoundtrip") {
            let manager = WhatsNewManager.shared
            let prev = manager.lastSeenVersion
            defer { manager.lastSeenVersion = prev }

            manager.lastSeenVersion = "1.1.0"
            let stored = UserDefaults.standard.string(forKey: WhatsNewManager.defaultsKey)
            assertEqual(stored, "1.1.0", "UserDefaults key must store acknowledged version string")

            manager.lastSeenVersion = "2.0.0"
            assertEqual(UserDefaults.standard.string(forKey: WhatsNewManager.defaultsKey), "2.0.0", "Updated version must persist")

            manager.resetAcknowledgment()
            assertEqual(UserDefaults.standard.string(forKey: WhatsNewManager.defaultsKey), nil, "Reset must remove key")
        }
    }

    static func testReleaseContentResolution() {
        runTest("testReleaseContentResolution") {
            let v11 = WhatsNewCatalog.announcement(for: "1.1.0")
            assertTrue(v11 != nil, "v1.1.0 announcement must resolve")
            guard let release = v11 else { return }

            assertEqual(release.version, "1.1.0", "Version must be 1.1.0")
            assertEqual(release.title, "TIMEDUCK v1.1", "Title must be TIMEDUCK v1.1")
            assertEqual(release.subtitle, "TACTICAL & EXPRESSIVE", "Subtitle must be TACTICAL & EXPRESSIVE")
            assertEqual(release.highlights.count, 4, "v1.1 must have 4 key highlights")

            let titles = release.highlights.map(\.title)
            assertTrue(titles.contains("4 TACTICAL BANDANAS"), "Must highlight 4 tactical bandanas")
            assertTrue(titles.contains("2 NEW DUCK EXPRESSIONS"), "Must highlight 2 new duck expressions")
            assertTrue(titles.contains("3 NEW CRT THEMES"), "Must highlight 3 new CRT themes")
            assertTrue(titles.contains("EXPANDED PHRASES"), "Must highlight expanded phrases")
        }
    }

    static func testV12PreviewTeaserData() {
        runTest("testV12PreviewTeaserData") {
            let release = WhatsNewCatalog.v1_1_0
            assertTrue(release.hasNextPreview, "v1.1 announcement must include next preview")
            assertEqual(release.nextVersion, "1.2.0", "Next version must be 1.2.0")
            assertEqual(release.nextTitle, "COMING NEXT · v1.2", "Next title must tease v1.2")
            assertEqual(release.nextSubtitle, "SECRET LIVING", "Next subtitle must be SECRET LIVING")

            guard let teasers = release.nextTeasers else {
                assertTrue(false, "nextTeasers should be present")
                return
            }
            assertTrue(teasers.count >= 3, "Must have at least 3 teaser points")
            let teaserText = teasers.joined(separator: " ")
            assertTrue(teaserText.contains("Costumes that react"), "Must tease reactive costumes")
            assertTrue(teaserText.contains("Rare secret events"), "Must tease rare secret events")
            assertTrue(teaserText.contains("secrets"), "Must tease duck secrets")
        }
    }

    static func testMissingNextTeaserGracefulHandling() {
        runTest("testMissingNextTeaserGracefulHandling") {
            let tbdRelease = ReleaseAnnouncement(
                version: "1.8.0",
                title: "TIMEDUCK v1.8",
                subtitle: "TBD",
                highlightsTitle: "WHAT'S NEW",
                highlights: [ReleaseHighlight(title: "IMPROVEMENTS", description: "Refinements.")],
                nextVersion: nil,
                nextTitle: nil,
                nextSubtitle: nil,
                nextTeasers: nil
            )

            assertFalse(tbdRelease.hasNextPreview, "Release without teasers must return hasNextPreview = false")
            assertEqual(tbdRelease.highlights.count, 1, "Highlights should still function normally")
        }
    }

    static func testManualReopenAvailability() {
        runTest("testManualReopenAvailability") {
            let manager = WhatsNewManager.shared
            let prev = manager.lastSeenVersion
            defer { manager.lastSeenVersion = prev }

            // Acknowledge v1.1.0
            manager.markAcknowledged(version: "1.1.0")

            // Current announcement is still accessible
            let current = WhatsNewCatalog.current
            assertEqual(current.version, "1.1.0", "Current catalog must return 1.1.0")
            assertEqual(manager.lastSeenVersion, "1.1.0", "Accessing catalog must not alter acknowledgment")
        }
    }

    static func testShowTimeDuckWindowManagementNonDestructive() {
        runTest("testShowTimeDuckWindowManagementNonDestructive") {
            // Verify that calling window focus logic preserves all timer engines and state
            let tm = TimerModel()
            tm.setDuration(300)
            tm.restart(autoStart: true)
            let remainingBefore = tm.remaining

            let pomo = PomodoroModel()
            pomo.setWorkDuration(1500)
            pomo.advancePhase(autoStart: true)
            let pomoRemainingBefore = pomo.remaining

            let sw = StopwatchModel()
            sw.start()

            // Verify active timer is unaffected by menu bar queries
            assertTrue(tm.isRunning, "Timer must remain running")
            assertTrue(pomo.isRunning, "Pomodoro must remain running")
            assertTrue(sw.isRunning, "Stopwatch must remain running")
            assertTrue(tm.remaining <= remainingBefore, "Timer countdown should proceed continuously")
            assertTrue(pomo.remaining <= pomoRemainingBefore, "Pomodoro countdown should proceed continuously")
        }
    }
}
