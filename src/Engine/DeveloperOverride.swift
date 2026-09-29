// MARK: - TimeDuck · DeveloperOverride.swift
// Developer-only override engine for Wave 8 (TimeCompanions + Achievements).
// STRICT SECURITY & ISOLATION:
// - Only compiled in DEBUG / developer builds (#if DEBUG).
// - Completely absent from release builds.
// - In-memory / ephemeral override that never corrupts genuine persisted progression.
// - Supports easy runtime toggling and local file-based overrides (ignored by git).

#if DEBUG
import Foundation

final class DeveloperOverride {
    static let shared = DeveloperOverride()

    /// Local file name for developer overrides. Ignored by git (.gitignore).
    static let localOverrideFileName = ".timeduck_dev_unlock"

    /// In-memory override switch for developer QA testing.
    var isUnlockAllActive: Bool = false {
        didSet {
            onOverrideChanged?()
        }
    }

    var onOverrideChanged: (() -> Void)?

    init() {
        checkLocalConfigFile()
    }

    /// Checks if a local override configuration file exists.
    func checkLocalConfigFile() {
        let fm = FileManager.default
        let currentDir = fm.currentDirectoryPath
        let path = (currentDir as NSString).appendingPathComponent(Self.localOverrideFileName)
        if fm.fileExists(atPath: path) {
            isUnlockAllActive = true
        }
    }

    /// Toggles the unlock-all mode on or off.
    func toggleUnlockAll() {
        isUnlockAllActive.toggle()
    }

    /// Resets all overrides back to genuine progression.
    func resetToGenuine() {
        isUnlockAllActive = false
    }
}
#endif
