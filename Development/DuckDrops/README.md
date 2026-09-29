# TimeDuck DuckDrops

This directory holds the source-wave specifications and implementation notes that feed public releases.

> **Current public release:** v1.2.0 — The Living Companion Update
> **Included:** Waves 2 through 8.2
> **Held separately:** Wave 9 clock-replacement proposal

## Wave status

| Wave | Theme | Public treatment |
| --- | --- | --- |
| 1 | Tactical Duck & Expressive Companion | Published in v1.1.0 |
| 2 | Secret Moments & Living Costumes | Included in v1.2.0 |
| 3 | Seasonal Drops & Accessible Duck | Included in v1.2.0 |
| 4 | Living Wardrobe & Physical Attachment | Included in v1.2.0 |
| 5 | Living Duck | Included in v1.2.0 |
| 6 / 6.1 | Duck Stories & Living Scenes | Included in v1.2.0 |
| 7 / 7.1 / 7.2 | MiniHUD, motion polish & finales | Included in v1.2.0 |
| 8 / 8.1 | TimeCompanions, achievements & Duckbook | Included in v1.2.0 |
| 8.2 | AI LiveSplit Protocol | Included in v1.2.0 |
| 9 | Native clock replacement proposal | Held for a separate release decision |

## Verification

```bash
./build.sh --test
./build.sh --release
```

The current v1.2.0 release gate records 262 passing tests and a successful release bundle build.

## Product rules

1. Timer engines remain authoritative; companion behavior observes time without owning it.
2. The application remains offline-first with no accounts, telemetry, or cloud dependency.
3. Full Window and MiniHUD preserve the primary clock safe zone.
