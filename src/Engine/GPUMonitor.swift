// MARK: - TimeDuck · GPUMonitor.swift
// Native macOS Apple Silicon Metal/GPU Compute Auto-Watcher.
// Passively monitors GPU compute utilization using IOKit (IOAccelerator)
// to automatically time local AI inference (Unsloth, Hermes, PyTorch, MLX, llama.cpp)
// with zero configuration, zero proxies, and zero external dependencies.

import Foundation
import IOKit

final class GPUMonitor {
    enum State: Equatable {
        case idle
        case active(startTime: Date)
        case coolingDown(startTime: Date, lastActiveTime: Date)
    }

    private(set) var state: State = .idle
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.oxalpha.timeduck.gpu-monitor", qos: .utility)

    // Configuration
    var utilizationThreshold: Int = 25
    var activationSamplesRequired: Int = 2
    var cooldownDuration: TimeInterval = 0.5
    var samplingInterval: TimeInterval = 0.1

    private var consecutiveActiveSamples = 0

    var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "td.gpu_auto_detect") }
        set {
            UserDefaults.standard.set(newValue, forKey: "td.gpu_auto_detect")
            if newValue {
                startMonitoring()
            } else {
                stopMonitoring()
            }
        }
    }

    var onInferenceStart: (() -> Void)?
    var onInferenceStop: ((TimeInterval) -> Void)?

    /// Keep callbacks on the main thread for UI consumers, while making the
    /// state machine deterministic when it is driven synchronously by tests.
    private func notifyOnMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    init() {
        if isEnabled {
            startMonitoring()
        }
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Lifecycle

    func startMonitoring() {
        guard timer == nil else { return }
        consecutiveActiveSamples = 0
        state = .idle

        let t = DispatchSource.makeTimerSource(queue: queue)
        t.schedule(deadline: .now() + samplingInterval, repeating: samplingInterval)
        t.setEventHandler { [weak self] in
            self?.pollGPUSample(now: Date())
        }
        self.timer = t
        t.resume()
    }

    func stopMonitoring() {
        timer?.cancel()
        timer = nil
        consecutiveActiveSamples = 0
        state = .idle
    }

    // MARK: - Sampling & State Transitions

    func pollGPUSample(now: Date = Date()) {
        guard let util = GPUMonitor.readCurrentUtilization() else { return }
        processSample(utilization: util, now: now)
    }

    func processSample(utilization: Int, now: Date = Date()) {
        let isHighCompute = utilization >= utilizationThreshold

        switch state {
        case .idle:
            if isHighCompute {
                consecutiveActiveSamples += 1
                if consecutiveActiveSamples >= activationSamplesRequired {
                    state = .active(startTime: now)
                    consecutiveActiveSamples = 0
                    notifyOnMain { [weak self] in
                        self?.onInferenceStart?()
                    }
                }
            } else {
                consecutiveActiveSamples = 0
            }

        case .active(let startTime):
            if isHighCompute {
                consecutiveActiveSamples = 0
            } else {
                // GPU dropped below threshold; enter cooldown
                state = .coolingDown(startTime: startTime, lastActiveTime: now)
            }

        case .coolingDown(let startTime, let lastActive):
            if isHighCompute {
                // Re-spiked during cooldown window (e.g. next token batch)
                state = .active(startTime: startTime)
            } else {
                let elapsedIdle = now.timeIntervalSince(lastActive)
                if elapsedIdle >= cooldownDuration {
                    // Sustained idle: inference session completed!
                    let totalDuration = lastActive.timeIntervalSince(startTime)
                    state = .idle
                    consecutiveActiveSamples = 0
                    notifyOnMain { [weak self] in
                        self?.onInferenceStop?(totalDuration)
                    }
                }
            }
        }
    }

    // MARK: - IOKit Hardware Query

    static func readCurrentUtilization() -> Int? {
        var iterator: io_iterator_t = 0
        let matchDict = IOServiceMatching("IOAccelerator")
        let result = IOServiceGetMatchingServices(0, matchDict, &iterator)
        guard result == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        var service = IOIteratorNext(iterator)
        while service != 0 {
            defer {
                IOObjectRelease(service)
                service = IOIteratorNext(iterator)
            }
            if let prop = IORegistryEntryCreateCFProperty(
                service,
                "PerformanceStatistics" as CFString,
                kCFAllocatorDefault,
                0
            )?.takeRetainedValue() as? [String: Any] {
                if let util = prop["Device Utilization %"] as? Int {
                    return util
                }
            }
        }
        return nil
    }
}
