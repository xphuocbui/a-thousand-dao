# Job transcript: budget-mirror-hide (try 1)

mirror-hide is now within its layer budget. `layers` went from `[400, 250, 200, 120, 0]` to `[180, 90, 50, 0, 0]`, which claims 16% of the gap (budget 17%). `fight.py` now prints `layer_budget` instead of `OVER_BUDGET`.

I cut L4 first, then L3, then L2 and L1, since a block tank needs those least. The `body` layers and the ward are unchanged. I removed no techniques, items or arts.

Fights from `--matrix` at Kết Đan (20 fights each; the old time is from the guide's geared table):

| Matchup | Old | New |
|---|---|---|
| typical ket_dan+0 | 5.0 s, 20-0 | 13.6 s, 20-0 |
| typical nguyen_anh+1 | 7.5 s, 20-0 | 45.5 s, 20-0 |
| typical hoa_than+2 | 19.8 s, 20-0 | 66.0 s, 20-0 |
| top_end ket_dan+0 | 66.1 s, 20-0 | 67.2 s, 20-0 |
| top_end nguyen_anh+1 | 46.9 s, 9-11 | 68.0 s, 20-0 |
| top_end hoa_than+2 | 2.6 s, 0-20 | 5.7 s, 0-20 |

Same-realm typical now takes 13.6 s, inside the 10–20 s band for a build at budget. Same-realm top-end is still a 20-0 win at about 67 s.

The build now runs out of linh lực at 36 s against typical hoa_than+2 and at 6 s against top_end ket_dan+0. The pieces it would want from the catalogue:
- a Return-channel Effect (a free Physical hit scaled by the hit stopped)
- linh lực regeneration or cost reduction
- an Effect that pays Strata per hit taken, to feed Strata Hammer
- a metal armour or necklace for the Iron Hide Manual
- a health-payment art for Debt of Stone

The guide's before/after table is replaced with the new numbers, and a "## Budget revision (2026-11-13)" section is added. The report is at `design/builds/engine-v3/_logs/budget/mirror-hide.md`.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/mirror-hide.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/mirror-hide.md) instead (Edit rules cover all file-editing tools).
```
