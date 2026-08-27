// MARK: - TimeDuck · AppVersion.swift
// Single authoritative source of truth for versioning and app metadata.

import Foundation

enum AppVersion {
    static let version = "1.0.0"
    static let build = "1"
    static let appName = "TimeDuck"
    static let subtitle = "Living Pixel Duck Desktop Companion & Precision Instrument"
    static let copyright = "Open source under the MIT License."

    static var displayString: String {
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return bundleVersion ?? version
    }

    static var fullDisplayString: String {
        "TimeDuck v\(displayString)"
    }
}
