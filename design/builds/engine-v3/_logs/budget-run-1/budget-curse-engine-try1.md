# Job transcript: budget-curse-engine (try 1)

`curse-engine` is now within its layer budget: `layers` went from `[330, 0, 150, 80, 0]` to `[310, 0, 0, 80, 0]`. `fight.py` prints `layer_budget` at 22% (budget 23%, was 38%). The cost is that it no longer beats the top-end enemy of its own realm.

**Why these cuts:**
- **L3 150 removed:** this was gear. The items' modifiers already run as Effects, so the points were counted twice.
- **L1 330 to 310:** a small trim to get under the line.
- **L4 80 kept:** that is the Nine Rods formation, and curse stacking needs it most.

**Fights from `--matrix`** (mean seconds, wins out of 20):

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 2.3 s, 20 wins | 4.4 s, 20 wins |
| typical hoa_than+1 | 6.1 s, 20 wins | 8.8 s, 20 wins |
| top_end nguyen_anh+0 | 9.9 s, 14 wins | 12.6 s, 0 wins |
| top_end hoa_than+1 | 7.9 s, 0 wins | 7.9 s, 0 wins |

It still kills a typical same-realm enemy in 4.4 s, well under the 10–20 s a budgeted build should take. Against the top-end same-realm enemy it runs out of linh lực (spirit energy) at about 9 s and loses every fight.

**Files changed:**
- **`curse-engine.fight.json`:** `layers` only.
- **`curse-engine.md`:** updated before-and-after table, plus a new "Budget revision (2026-11-13)" section.
- **`_logs/budget/curse-engine.md`:** the report, created.

No techniques, items or arts were changed or removed.

**What the build now lacks** (also in the report):
- A curse-scoped weapon.
- Linh lực sustain that costs no art speed.
- A seal-scoped L4 source.
- A ward stronger than ws 120.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/curse-engine.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/curse-engine.md) instead (Edit rules cover all file-editing tools).
```
