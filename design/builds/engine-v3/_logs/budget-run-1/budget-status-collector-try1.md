# Job transcript: budget-status-collector (try 1)

status-collector is now under its layer budget: `layers` claim 28% of the gap, against the 30% hoa_than budget. `fight.py` prints `layer_budget` instead of `OVER_BUDGET`.

**Layers (L1–L5):** `[400, 250, 250, 150, 52]` became `[200, 130, 130, 80, 30]`. I cut all five by about half rather than sparing any one. The concept sits in the arts, the Marked Prey effect and the stack items, not in raw layers. Techniques, items and arts are unchanged, and nothing was removed.

**Fights (20 each, all wins both before and after):**

| Matchup | Mean time before | Mean time after |
|---|---|---|
| typical | 2.0 s | 2.9 s |
| top_end | 5.1 s | 9.3 s |

Against a typical foe the build still wins in under 3 s, well short of the 10–20 s a budget build should take. I did not tune further. Against top_end it is now closer to that band.

**Guide edits:**
- I replaced the old geared numbers in the before/after table with the new ones.
- I added a "Budget revision (2026-11-13)" section.
- The `--without` table in the guide was measured before the cut, so I left it as history and labelled it.
- The guide had old "2.9 / 5.4" geared figures. Re-running the file as it stood before my edit gave 2.0 / 5.1, so those figures were stale.

**Files:**
- `design/builds/engine-v3/builds/status-collector.fight.json`
- `design/builds/engine-v3/status-collector.md`
- `design/builds/engine-v3/_logs/budget/status-collector.md` (new report)

**What the build still wants from the catalogue** (also in the report):
- A Wood item that lays Poison and Stagnation.
- A Metal or Earth item that lays Sundered or Exposed.
- An item that raises the Marked Prey cap.
- Engine support for Toll Taker, Deep Freeze and the stack effect and duration passives, which the sim cannot run yet.

The system noted that the guide changed on disk after my last read. I did not re-read it, and I made no edits to revert or reconcile.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/status-collector.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/status-collector.md) instead (Edit rules cover all file-editing tools).
```
