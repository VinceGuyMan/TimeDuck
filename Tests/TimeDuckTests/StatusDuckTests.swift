// MARK: - TimeDuck · StatusDuckTests.swift

import Foundation
import AppKit

enum StatusDuckTests {
    static func runAll() {
        print("")
        print("▸ Testing Animated Status Duck Engine…")

        runTest("testStatusDuckAllFramesExist") {
            for pose in StatusDuckPose.allCases {
                let img = StatusDuckSprite.image(for: pose)
                assertEqual(img.size.width, 18)
                assertEqual(img.size.height, 18)
                assertTrue(img.isTemplate)
            }
        }

        runTest("testStatusDuckRawFrameDimensions") {
            for (pose, rows) in StatusDuckSprite.rawFrames {
                assertTrue(!rows.isEmpty, "Rows empty for \(pose)")
                let expectedWidth = rows[0].count
                assertEqual(expectedWidth, 14, "Expected width 14 for \(pose)")
                assertEqual(rows.count, 11, "Expected height 11 for \(pose)")
                for row in rows {
                    assertEqual(row.count, expectedWidth, "Row length mismatch in \(pose)")
                }
            }
        }

        runTest("testStatusDuckAnimatorInitialState") {
            let animator = StatusDuckAnimator()
            assertEqual(animator.currentPose, .idle)
            assertEqual(animator.currentImage.size.width, 18)
        }

        runTest("testStatusDuckAnimatorEventHooks") {
            let animator = StatusDuckAnimator()
            var lastImage: NSImage?
            animator.onPoseChanged = { img in
                lastImage = img
            }

            // Timer Start triggers alert pose
            animator.onTimerStart()
            assertEqual(animator.currentPose, .alert)
            assertTrue(lastImage != nil)

            // Timer Urgency (<10s)
            animator.onTimerUrgency()
            assertEqual(animator.currentPose, .alert)

            // User activity wakes up
            animator.onUserActivity()
            assertTrue(animator.currentPose == .alert || animator.currentPose == .idle)
        }

        runTest("testStatusDuckAnimatorSyncState") {
            let animator = StatusDuckAnimator()

            // Timer running with 5s remaining -> Alert pose
            animator.syncState(isTimerRunning: true, remaining: 5.0, isFinished: false, isMusicOn: false)
            assertEqual(animator.currentPose, .alert)

            // Finished -> Victory fanfare begins
            animator.syncState(isTimerRunning: false, remaining: 0.0, isFinished: true, isMusicOn: false)
            assertTrue(animator.currentPose == .victoryA || animator.currentPose == .victoryB)
        }
    }
}
