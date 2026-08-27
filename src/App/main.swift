// MARK: - TimeDuck · main.swift
// Application bootstrap and entrypoint.

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
