# Job transcript: budget-meta-hunter (try 2)

`meta-hunter` is now within its layer budget: `layers` went from [200, 280, 250, 150, 80] to [70, 110, 100, 70, 0]. That moves the claimed share from 80% to 22% against the 23% nguyên_anh budget. `fight.py` now prints `layer_budget` instead of `OVER_BUDGET`.

I cut L5 first. The file's own note already said L5 was left at 0, and the Marked Prey Effect feeds it anyway. Then I cut L4, then L1, and kept L2 and L3 highest because marks and seals are the concept.

I did not remove or change any technique, item, art or Effect. The `--matrix` runs (20 fights each) went like this:

| Matchup | Mean s, old → new | Wins, old → new |
|---|---|---|
| typical, nguyên_anh | 2.1 → 5.3 | 20 → 20 |
| top_end, nguyên_anh | 3.6 → 9.4 | 20 → 20 |
| typical, hóa_thần+1 | 2.6 → 12.9 | 20 → 20 |
| top_end, hóa_thần+1 | 5.3 → 27.7 | 20 → 19 (1 loss) |

The typical nguyên_anh fight at 5.3 s is still shorter than the 10–20 s a build at budget should take. Getting there would mean cutting the build's own pieces, which you ruled out.

In the guide `meta-hunter.md` I added "## Budget revision (2026-11-13)" with the changes and fight results. The older "Before and after" and `--without` tables are not updated; the new section says the "Before and after" numbers are replaced. The report is at `design/builds/engine-v3/_logs/budget/meta-hunter.md`. It also lists the pieces the build would want from the catalogue:
- A bow or spear weapon.
- Slowed Time and seal-duration pieces.
- A seal-scoped ring or necklace.
- A cleanse or Stagnation-cap piece.
- A health-pay counter.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/meta-hunter.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/meta-hunter.md) instead (Edit rules cover all file-editing tools).
```
