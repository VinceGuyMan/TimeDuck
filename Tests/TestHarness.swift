// MARK: - TimeDuck · TestHarness.swift
// Portable, dependency-free test runner and assertion framework for TimeDuck.

import Foundation

public struct TestFailure {
    public let message: String
    public let file: String
    public let line: Int
}

public final class TestSuiteContext {
    public static let shared = TestSuiteContext()
    public var currentTestName: String = ""
    public var passedCount: Int = 0
    public var failedCount: Int = 0
    public var failures: [TestFailure] = []

    public func reset() {
        currentTestName = ""
        passedCount = 0
        failedCount = 0
        failures.removeAll()
    }

    public func recordSuccess() {
        passedCount += 1
        print("  ✅ [PASS] \(currentTestName)")
    }

    public func recordFailure(_ message: String, file: String = #file, line: Int = #line) {
        failedCount += 1
        let f = TestFailure(message: message, file: file, line: line)
        failures.append(f)
        print("  ❌ [FAIL] \(currentTestName): \(message) (at \(URL(fileURLWithPath: file).lastPathComponent):\(line))")
    }
}

public func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
    if actual != expected {
        let msg = message.isEmpty ? "Expected '\(expected)', got '\(actual)'" : "\(message) (Expected '\(expected)', got '\(actual)')"
        TestSuiteContext.shared.recordFailure(msg, file: file, line: line)
    }
}

public func assertEqual(_ actual: Double, _ expected: Double, accuracy: Double, _ message: String = "", file: String = #file, line: Int = #line) {
    if abs(actual - expected) > accuracy {
        let msg = message.isEmpty ? "Expected '\(expected)' +/- \(accuracy), got '\(actual)'" : "\(message) (Expected '\(expected)' +/- \(accuracy), got '\(actual)')"
        TestSuiteContext.shared.recordFailure(msg, file: file, line: line)
    }
}

public func assertTrue(_ condition: Bool, _ message: String = "Expected true, got false", file: String = #file, line: Int = #line) {
    if !condition {
        TestSuiteContext.shared.recordFailure(message, file: file, line: line)
    }
}

public func assertFalse(_ condition: Bool, _ message: String = "Expected false, got true", file: String = #file, line: Int = #line) {
    if condition {
        TestSuiteContext.shared.recordFailure(message, file: file, line: line)
    }
}

public func assertNotNil<T>(_ value: T?, _ message: String = "Expected non-nil value", file: String = #file, line: Int = #line) {
    if value == nil {
        TestSuiteContext.shared.recordFailure(message, file: file, line: line)
    }
}

public func assertNil<T>(_ value: T?, _ message: String = "Expected nil value", file: String = #file, line: Int = #line) {
    if value != nil {
        TestSuiteContext.shared.recordFailure(message, file: file, line: line)
    }
}

public func runTest(_ name: String, _ testBlock: () throws -> Void) {
    let ctx = TestSuiteContext.shared
    ctx.currentTestName = name
    let prevFailures = ctx.failedCount
    do {
        try testBlock()
        if ctx.failedCount == prevFailures {
            ctx.recordSuccess()
        }
    } catch {
        ctx.recordFailure("Threw unexpected error: \(error)")
    }
}
