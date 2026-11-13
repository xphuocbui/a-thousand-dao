# Job transcript: budget-armoury-mind (try 1)

`armoury-mind` is now within its layer budget: `fight.py` prints `layer_budget` at 23%, down from 75% (OVER_BUDGET). It still doesn't reach the 10–20 s a build at its budget should need against a typical foe, and the report says what it lacks.

**Layers.** `layers` went from `[266, 265, 250, 130, 0]` to `[150, 150, 120, 0, 0]`. The techniques' passives and the items' modifiers already run as Effects, so the old values counted the gear twice. I cut the fourth layer first because the concept needs it least. I did not change any technique, item, art or Effect, and I removed nothing.

**Fights** (mean time, wins of 20, from the `--matrix` run):

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 1.5 s, 20 wins | 3.7 s, 20 wins |
| typical hoa_than+1 | 3.2 s, 20 wins | 5.6 s, 20 wins |
| top_end nguyen_anh+0 | 2.4 s, 0 wins | 2.4 s, 0 wins |
| top_end hoa_than+1 | 1.5 s, 0 wins | 1.5 s, 0 wins |

The build still beats typical enemies and still loses to top-end ones. The two `--without` tests in the guide predate this revision and were not re-run; the guide says so.

**What it lacks to stay strong:**
- an Effect that counts equipped weapons,
- a Metal armour with a standing drain ward,
- a soul-defence piece,
- engine support for Edge Past the Rack.

I found 150/150/120 by trial and error on `fight.py`'s printed share. I did not confirm that it is the largest round set of values that stays at 23%.

The guide now has a "## Budget revision (2026-11-13)" section, and I replaced the old numbers in its other sections. The report is at `design/builds/engine-v3/_logs/budget/armoury-mind.md`.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/armoury-mind.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/armoury-mind.md) instead (Edit rules cover all file-editing tools).
```
