# TimeDuck Public Release Map

This is the canonical mapping between internal DuckDrops waves and public releases.

| Version | Release | Included source waves | Status |
| --- | --- | --- | --- |
| **v1.0.0** | Original Public Release | Baseline timer, Pomodoro, stopwatch, CRT companion | Published and frozen |
| **v1.1.0** | Tactical & Expressive | Wave 1 | Published on GitHub |
| **v1.2.0** | The Living Companion Update | Waves 2, 3, 4, 5, 6, 6.1, 7, 7.1, 7.2, 8, 8.1, 8.2 | Current consolidated release |
| **Wave 9** | Clockwork Pond proposal | Native clock replacement design | Held for a separate release decision |
| **v1.3+** | Future updates | To be scoped after v1.2.0 | Reserved |

## v1.2.0 scope

The consolidated release includes living costumes and seasonal accessibility, the expanded duck, five focus stories, MiniHUD and finale polish, TimeCompanions, achievements, Duckbook, and the AI LiveSplit protocol.

Wave 9 is deliberately outside this release. Its world clock, scheduled alarms, digital menu-bar clock mode, and ambient chimes remain specified in [`docs/WAVE_9_HANDOFF.md`](docs/WAVE_9_HANDOFF.md) without implementation claims.

## Product invariants

1. Timer engines remain authoritative; companion animation and stories observe time without owning it.
2. The app remains offline-first with no telemetry, accounts, or cloud dependency.
3. Full Window and MiniHUD preserve the primary clock safe zone.
4. Public release notes and implementation status must agree with GitHub tags.
