// MARK: - TimeDuck · GPUMonitorTests.swift
// Unit test suite for Native macOS Metal/GPU Compute Auto-Watcher.

import Foundation

enum GPUMonitorTests {
    static func runAll() {
        print("")
        print("▸ Testing Metal/GPU Compute Auto-Watcher (GPUMonitor)…")

        runTest("testIOKitGPUReadingAvailability") {
            let util = GPUMonitor.readCurrentUtilization()
            // On macOS Apple Silicon development machine, this returns 0...100
            if let u = util {
                assertTrue(u >= 0 && u <= 100)
            }
        }

        runTest("testGPUMonitorInitialState") {
            let monitor = GPUMonitor()
            monitor.stopMonitoring()
            assertEqual(monitor.state, .idle)
            assertEqual(monitor.utilizationThreshold, 25)
            assertEqual(monitor.activationSamplesRequired, 2)
            assertEqual(monitor.cooldownDuration, 0.5, accuracy: 0.001)
        }

        runTest("testGPUMonitorActivationUnderSustainedHighLoad") {
            let monitor = GPUMonitor()
            monitor.stopMonitoring()

            var startTriggered = false
            monitor.onInferenceStart = {
                startTriggered = true
            }

            let t0 = Date()
            // Sample 1: Low GPU (10%)
            monitor.processSample(utilization: 10, now: t0)
            assertEqual(monitor.state, .idle)
            assertFalse(startTriggered)

            // Sample 2: First High GPU Spike (80%) — requires 2 consecutive samples
            let t1 = t0.addingTimeInterval(0.1)
            monitor.processSample(utilization: 80, now: t1)
            assertEqual(monitor.state, .idle)
            assertFalse(startTriggered)

            // Sample 3: Second Consecutive High GPU Sample (85%) — activates!
            let t2 = t1.addingTimeInterval(0.1)
            monitor.processSample(utilization: 85, now: t2)
            if case .active(let startTime) = monitor.state {
                assertEqual(startTime, t2)
            } else {
                assertTrue(false, "Expected .active state after 2 high samples")
            }
        }

        runTest("testGPUMonitorCooldownResilienceToInterTokenPauses") {
            let monitor = GPUMonitor()
            monitor.stopMonitoring()

            let t0 = Date()
            monitor.processSample(utilization: 90, now: t0)
            monitor.processSample(utilization: 90, now: t0.addingTimeInterval(0.1))

            // Now in active state
            if case .active = monitor.state {
                // Expected
            } else {
                assertTrue(false, "Expected active state")
            }

            // GPU momentarily dips between token batches (util = 5%)
            let tDip = t0.addingTimeInterval(0.3)
            monitor.processSample(utilization: 5, now: tDip)
            if case .coolingDown(_, let lastActive) = monitor.state {
                assertEqual(lastActive, tDip)
            } else {
                assertTrue(false, "Expected coolingDown state on GPU dip")
            }

            // Next token batch spikes again before 0.5s cooldown expires (after 0.15s)
            let tReSpike = tDip.addingTimeInterval(0.15)
            monitor.processSample(utilization: 80, now: tReSpike)
            if case .active = monitor.state {
                // Re-activated successfully!
            } else {
                assertTrue(false, "Expected recovery to active state during inter-token pause")
            }
        }

        runTest("testGPUMonitorStopAfterCooldownExpiration") {
            let monitor = GPUMonitor()
            monitor.stopMonitoring()

            var recordedDuration: TimeInterval?
            monitor.onInferenceStop = { duration in
                recordedDuration = duration
            }

            let t0 = Date()
            monitor.processSample(utilization: 90, now: t0)
            monitor.processSample(utilization: 90, now: t0.addingTimeInterval(0.1))

            // Inference completes, GPU drops to 0%
            let tEnd = t0.addingTimeInterval(4.0)
            monitor.processSample(utilization: 0, now: tEnd)

            // 0.2s later (still in cooldown)
            monitor.processSample(utilization: 0, now: tEnd.addingTimeInterval(0.2))
            if case .coolingDown = monitor.state {
                // Still cooling down
            } else {
                assertTrue(false, "Expected coolingDown at +0.2s")
            }

            // 0.6s later (exceeds cooldown duration of 0.5s)
            let tFinal = tEnd.addingTimeInterval(0.6)
            monitor.processSample(utilization: 0, now: tFinal)
            assertEqual(monitor.state, .idle)
            assertNotNil(recordedDuration)
        }

        runTest("testGPUMonitorEnabledPersistence") {
            let monitor = GPUMonitor()
            let original = monitor.isEnabled

            monitor.isEnabled = true
            assertEqual(UserDefaults.standard.bool(forKey: "td.gpu_auto_detect"), true)

            monitor.isEnabled = false
            assertEqual(UserDefaults.standard.bool(forKey: "td.gpu_auto_detect"), false)

            monitor.isEnabled = original
        }
    }
}
