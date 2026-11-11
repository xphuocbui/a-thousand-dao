# Job transcript: tune2-soul-song-seal (try 1)

The three off-target rows are now on target, and `lint_arts.py` reports 0 findings. The numbers below are from the last `suite_check` run.

| Row | Realm | Before | After |
|---|---|---|---|
| hollow-bell-canon (suite) | Trúc Cơ | x1.31, 3-16 | x0.89, 20-0 |
| hollow-bell-canon (suite) | Kết Đan | x1.17, 0-20 | x0.93, 20-0 |
| marching-dirge | Trúc Cơ | 0-20 | x0.96, 12-8 |
| marching-dirge | Kết Đan | 0-20 | x0.97, 14-6 |
| blood-ink-writ | Trúc Cơ | 0-20 | x0.92, 12-8 |
| blood-ink-writ | Kết Đan | 0-20 | x0.91, 13-5 |

- **Hollow Bell Canon speed:** it is at x0.89–0.93, inside the x0.7–1.0 target. It wins every fight (20-0 at both realms), which meets "and winning".
- **Soul damage finding:** a Soul-type `free_hit` did almost nothing against the typical foe. Raising the Lance's from 30 to 80 changed no row. I switched the canon's payoff hits to `elem` type, and that is what made the suite win.
- **Lance Fully Lit:** it now needs 6 Tolls AND one of the old four conditions, so it has two conditions instead of one OR-group. It fires 1.4–3.0 times a fight.
- **Death Knell (the Bell's top step):** it needs 7 Tolls and does not fire in a typical build (0 per fight in the last run).
- **Both canon arts engage:** the Bell's first step fires 3.0–3.4 times a fight, and the Lance's empower fires as above. `suite_check` printed no NEVER_ENGAGED line.
- **Blood-Ink Writ:** its Withering had to last longer than the cooldown, or it expired between casts. With a 4 s Withering and a 3 s cooldown it swung from 0-20 to 20-0, so I tuned the damage bonus and Stagnation down from there. I also cut its health cost from 8 % to 3 %, which is a change to the rule as designed.
- **Dirge:** the March is now +35 % speed for a 5 % cost, and the finale is stronger.
- **Files:** the Lance row in the `family-soul-song-seal.md` table is updated, and the full change list is in `design/arts/tune2-soul-song-seal.md`.
- **Note to fix:** the "4 % per different status" figure in Blood-Ink's rule text does not match its data value of 3. That mismatch was already there; I left the text as it was.

TUNE-DONE design/arts/tune2-soul-song-seal.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-soul-song-seal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-soul-song-seal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune2-soul-song-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune2-soul-song-seal.md) instead (Edit rules cover all file-editing tools).
```
