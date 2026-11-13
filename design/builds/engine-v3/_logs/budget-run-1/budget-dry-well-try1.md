# Job transcript: budget-dry-well (try 1)

dry-well now prints `layer_budget` instead of `OVER_BUDGET`: it claims 23 % of the gap at nguyen_anh, down from 25 % (the budget is 23 %).

**The change.** `layers` went from `[160, 0, 250, 0, 0]` to `[160, 0, 230, 0, 0]`. I cut only L3 (gear), since that is the layer the build needs least. The seven items already run as Effects, and the file names no Meridian Map source for the 250. I kept L1 at 160. I removed no techniques, items or arts. I chose 230 as the smallest cut that fits the budget, though the budget alone doesn't settle this. A harder cut to L3 150 claims 13 % and fights almost identically (about 62 s against the top-end enemy, no wins).

**Fights** (20 each, `--matrix`, before → after):

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 6.5 s, 20 wins | 6.3 s, 20 wins |
| typical hoa_than+1 | 65.0 s, 20 wins | 65.8 s, 20 wins |
| top_end nguyen_anh+0 | 62.5 s, 0 wins | 62.0 s, 0 wins |
| top_end hoa_than+1 | 10.7 s, 0 wins | 10.7 s, 0 wins |

No outcome changed. The build still beats a typical same-realm enemy in about 6 s, quicker than the 10–20 s expected at budget.

**What the build lacks.** It would want items that raise the bills the foe's drain wards pay, linh lực sustain (it runs dry at 8–9 s), and a cheap utility piece. The engine also doesn't model Toll Taker or the exact Deep Freeze trigger, so the build's signature is under-measured.

**Guide numbers.** The guide's older top_end nguyen_anh+0 figure of about 17 s came from an earlier engine state. Today's engine gives about 62 s with the build's L3 at 250 as well, so that jump is not from this revision. I replaced the guide's before-and-after table with today's numbers. The guide's `--without` table was not rerun and still shows the old figures.

I edited only the build file and the guide in `design/builds/engine-v3`, and created the report. The report is `design/builds/engine-v3/_logs/budget/dry-well.md`. The guide has the new "Budget revision (2026-11-13)" section.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/dry-well.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/dry-well.md) instead (Edit rules cover all file-editing tools).
```
