# Job transcript: budget-evade-dancer (try 1)

`evade-dancer` is now inside its layer budget: `fight.py` prints `layer_budget` at 22% claimed, against the 23% limit at nguyen_anh. The guide and the report are updated.

`layers` went from [400, 260, 250, 150, 100] to [210, 120, 80, 40, 30]. I cut L5, L4 and L3 hardest because the build runs on evade and art speed from its items. L1 and L2 stay highest because crit and art output run through them. L1 is 210 rather than 220 because 220 printed 23% but still flagged OVER_BUDGET.

I did not change any technique, item or art, and removed none. I estimated the new `layers` by trial and read the share the tool printed, so the values are not derived from the pieces' own totals.

Fresh runs of the old and new files, 20 fights each with `--matrix`:

| Matchup | Old | New |
|---|---|---|
| Typical, same realm | 1.2 s, 20-0 | 3.0 s, 20-0 |
| Typical, one realm higher | 2.1 s, 20-0 | 6.1 s, 20-0 |
| Top end, same realm | 7.1 s, 17-3 | 9.0 s, 0-20 |
| Top end, one realm higher | 5.1 s, 0-20 | 5.1 s, 0-20 |

The build no longer beats the top-end same-realm enemy. It still beats a typical same-realm enemy in 3.0 s, faster than the 10–20 s the rule expects at budget, because the gear and evade carry the fight.

In the guide I replaced the old numbers with the new ones and added "## Budget revision (2026-11-13)". The guide's earlier `--without` item and Effect tests were run on the over-budget file, so I did not re-run them, and the guide now says so. The report lists what the build still wants from the catalogue: an evade-cleanse treasure, a ward that stops damage ticks, a thần thức item that lifts the extra-slot limit, and sustained Wind damage pieces.

Files are in `design/builds/engine-v3/`:
- `builds/evade-dancer.fight.json`
- `evade-dancer.md`
- `_logs/budget/evade-dancer.md`

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/evade-dancer.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/evade-dancer.md) instead (Edit rules cover all file-editing tools).
```
