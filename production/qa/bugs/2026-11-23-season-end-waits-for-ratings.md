# Performance: End turn waits 40-50 s for the rating batch

> **Found:** 2026-11-23 (user: "why does the world turn take so long, do we have ratings on?"). **Status: open**, for
> the owner of Power Rankings (`src/gameplay/combat/ranking/`, `design/gdd/power-rankings.md`; the other session's).

## Measurement (greybox map screen, 1280x720, seed 7, three End turns pressed back to back)

| End turn | Ratings on | `--ratings-off` |
|---|---|---|
| 1 | 2.3 s | 0.9 s |
| 2 | 43.1 s | 0.8 s |
| 3 | 49.3 s | 0.9 s |

## Why
Rule 13 resolves ratings one season late: each End turn waits for the previous season's batch (`SeasonBatch`, worker
processes) to finish before it applies it. `combat_rankings.json` sets `season_fight_budget` 10000; a batch of that
size takes about 40-50 s here. A player who ends a season quickly (the common case once a run is underway) waits for
all of it; the demo, which presses through seasons, always does.

## Done on the UI side
Test runs (`--demo`, `--shot-and-quit`) now default to ratings off (`--ratings-on` keeps them), and the test world
cache keys on that choice. The game itself is unchanged.

## Options for the owner (not decided here)
1. A smaller `season_fight_budget`, or a budget that scales with how long the player took over the season.
2. Applying a batch two seasons late, or applying whatever finished and carrying the rest over.
3. Showing the wait ("The rankings are being fought…") so it does not read as a hang.
