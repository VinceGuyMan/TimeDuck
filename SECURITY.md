# Security Policy

TimeDuck is a fully offline macOS utility. It does not open network sockets, phone home, or ship a crash reporter.

## Supported versions

| Version | Supported |
| --- | --- |
| 1.0.x | Yes |

## Reporting a vulnerability

Open a private report if you find a local issue that could:

- corrupt `~/Library/Application Support/TimeDuck/state.json` in a harmful way
- execute unexpected code from a crafted file the app reads
- escalate privileges on the host Mac

Do not file a public issue for an exploitable local bug. Use GitHub private vulnerability reporting if enabled, otherwise open an issue titled SECURITY with no exploit details and wait for contact.

Include macOS version, TimeDuck version (title bar), and reproduction steps.
