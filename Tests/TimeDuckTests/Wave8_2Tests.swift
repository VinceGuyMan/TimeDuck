// MARK: - TimeDuck · Wave8_2Tests.swift
// Unit test suite for TimeDuck v1.8.1:
// AI Auto-Splitter, LiveSplit Protocol & Remote IPC Controls.

import Foundation

enum Wave8_2Tests {
    static func runAll() {
        print("")
        print("▸ Testing Wave 8.2: AI Auto-Splitter & LiveSplit Protocol (v1.8.1)…")

        runTest("testStopwatchCustomLapLabels") {
            let sw = StopwatchModel()
            let t0 = Date()
            sw.start(now: t0)

            // Lap 1: Thinking / TTFT
            let t1 = t0.addingTimeInterval(3.25)
            let lap1 = sw.lap(now: t1, label: "THINKING")
            assertNotNil(lap1)
            assertEqual(lap1?.label ?? "", "THINKING")
            assertEqual(lap1?.split ?? 0, 3.25, accuracy: 0.001)

            // Lap 2: Tool call
            let t2 = t0.addingTimeInterval(7.50)
            let lap2 = sw.lap(now: t2, label: "TOOL:SEARCH")
            assertNotNil(lap2)
            assertEqual(lap2?.label ?? "", "TOOL:SEARCH")
            assertEqual(lap2?.split ?? 0, 4.25, accuracy: 0.001)
            assertEqual(lap2?.total ?? 0, 7.50, accuracy: 0.001)

            // Lap 3: Unlabeled backwards compatibility
            let t3 = t0.addingTimeInterval(11.00)
            let lap3 = sw.lap(now: t3)
            assertNotNil(lap3)
            assertNil(lap3?.label)
            assertEqual(lap3?.split ?? 0, 3.50, accuracy: 0.001)

            assertEqual(sw.laps.count, 3)
        }

        runTest("testLapJSONCodablePreservation") {
            let lapWithLabel = Lap(index: 1, split: 2.5, total: 2.5, hue: 0.5, label: "TTFT")
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()

            let dataWithLabel = try encoder.encode(lapWithLabel)
            let decodedWithLabel = try decoder.decode(Lap.self, from: dataWithLabel)
            assertEqual(decodedWithLabel.label ?? "", "TTFT")
            assertEqual(decodedWithLabel.index, 1)
            assertEqual(decodedWithLabel.split, 2.5, accuracy: 0.001)

            let lapWithoutLabel = Lap(index: 2, split: 4.0, total: 6.5, hue: 0.7)
            let dataWithoutLabel = try encoder.encode(lapWithoutLabel)
            let decodedWithoutLabel = try decoder.decode(Lap.self, from: dataWithoutLabel)
            assertNil(decodedWithoutLabel.label)
            assertEqual(decodedWithoutLabel.index, 2)
            assertEqual(decodedWithoutLabel.total, 6.5, accuracy: 0.001)
        }

        runTest("testURLSchemeActionAndLabelParsing") {
            func parseURL(_ urlString: String) -> (action: String, label: String?) {
                guard let url = URL(string: urlString) else { return ("", nil) }
                let host = url.host?.lowercased() ?? ""
                let rawPath = url.path.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let action: String
                if host == "split" || host == "stopwatch" || host == "timer" || host == "api" {
                    action = rawPath.isEmpty ? "start" : rawPath
                } else if !host.isEmpty {
                    action = host
                } else {
                    action = rawPath.isEmpty ? "start" : rawPath
                }
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let label = components?.queryItems?.first(where: {
                    $0.name.lowercased() == "label" || $0.name.lowercased() == "name"
                })?.value
                return (action, label)
            }

            let res1 = parseURL("timeduck://split/start?label=DeepSeek-R1")
            assertEqual(res1.action, "start")
            assertEqual(res1.label ?? "", "DeepSeek-R1")

            let res2 = parseURL("timeduck://split/lap?label=Thinking")
            assertEqual(res2.action, "lap")
            assertEqual(res2.label ?? "", "Thinking")

            let res3 = parseURL("timeduck://stopwatch/stop?name=Done")
            assertEqual(res3.action, "stop")
            assertEqual(res3.label ?? "", "Done")

            let res4 = parseURL("timeduck://reset")
            assertEqual(res4.action, "reset")
            assertNil(res4.label)

            let res5 = parseURL("timeduck://api/split?label=Tool")
            assertEqual(res5.action, "split")
            assertEqual(res5.label ?? "", "Tool")
        }

        runTest("testStatusDictionaryJSONSerialization") {
            let sw = StopwatchModel()
            let t0 = Date()
            sw.start(now: t0)
            _ = sw.lap(now: t0.addingTimeInterval(2.0), label: "THINKING")

            var lapsData: [[String: Any]] = []
            for l in sw.laps {
                var d: [String: Any] = [
                    "index": l.index,
                    "split": l.split,
                    "total": l.total
                ]
                if let label = l.label {
                    d["label"] = label
                }
                lapsData.append(d)
            }

            let statusDict: [String: Any] = [
                "version": AppVersion.version,
                "mode": "stopwatch",
                "running": sw.isRunning,
                "elapsed": sw.elapsed(at: t0.addingTimeInterval(5.0)),
                "laps": lapsData
            ]

            let jsonData = try JSONSerialization.data(withJSONObject: statusDict, options: [.prettyPrinted])
            assertFalse(jsonData.isEmpty)

            let jsonObject = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            assertNotNil(jsonObject)
            assertEqual(jsonObject?["version"] as? String ?? "", "1.2.0")
            assertEqual(jsonObject?["mode"] as? String ?? "", "stopwatch")
            assertEqual(jsonObject?["running"] as? Bool ?? false, true)
            let lapsArray = jsonObject?["laps"] as? [[String: Any]]
            assertEqual(lapsArray?.count ?? 0, 1)
            assertEqual(lapsArray?.first?["label"] as? String ?? "", "THINKING")
        }

        runTest("testAISpeedrunLifecycleSequence") {
            let sw = StopwatchModel()
            let t0 = Date()

            // 1. Start Prompt
            sw.reset()
            sw.start(now: t0)
            assertTrue(sw.isRunning)
            assertEqual(sw.elapsed(at: t0), 0)

            // 2. Thinking / TTFT Split
            let t1 = t0.addingTimeInterval(1.85)
            let ttftLap = sw.lap(now: t1, label: "TTFT")
            assertNotNil(ttftLap)
            assertEqual(ttftLap?.split ?? 0, 1.85, accuracy: 0.001)

            // 3. Tool Execution Split
            let t2 = t0.addingTimeInterval(4.20)
            let toolLap = sw.lap(now: t2, label: "TOOL:BASH")
            assertNotNil(toolLap)
            assertEqual(toolLap?.split ?? 0, 2.35, accuracy: 0.001)

            // 4. Response Completion Stop
            let t3 = t0.addingTimeInterval(9.50)
            let finalLap = sw.lap(now: t3, label: "COMPLETION")
            sw.stop(now: t3)
            assertFalse(sw.isRunning)
            assertEqual(finalLap?.split ?? 0, 5.30, accuracy: 0.001)
            assertEqual(sw.banked, 9.50, accuracy: 0.001)
            assertEqual(sw.laps.count, 3)

            // 5. Fresh Prompt Start Resets Cleanly
            let t4 = t3.addingTimeInterval(10.0)
            sw.reset()
            sw.start(now: t4)
            assertTrue(sw.isRunning)
            assertEqual(sw.banked, 0)
            assertTrue(sw.laps.isEmpty)
        }
    }
}
