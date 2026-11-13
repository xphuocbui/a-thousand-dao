# Budget report: status-collector (Hóa Thần)

**Claimed share of the typical-to-top-end layer gap:** 76 % before, 28 % after (budget 30 %). `fight.py` now prints `layer_budget`.

**Layers (L1-L5):** before `[400, 250, 250, 150, 52]`, after `[200, 130, 130, 80, 30]`. All five were cut roughly in half; no layer was singled out because the concept relies on arts and statuses, not layers.

**Fights (20 each, all wins both times):**

| Matchup | Mean s before | Mean s after |
|---|---|---|
| typical | 2.0 | 2.9 |
| top_end | 5.1 | 9.3 |

`--matrix` after: every art fires against top_end; against typical Rime Lock Seal, Black Ice Glaze, Shatter Palm and Gathered Ruin Verdict never fire (the fight ends first).

**Removed pieces:** none. Techniques, items and arts are unchanged.

**What the build still lacks to stay strong (catalogue wishes):**
- A fast opener or burst that fires against a typical foe: the build wins in under 3 s without most of its suite, but at budget it should take 10-20 s, so it is still well above the band against typical foes. The remaining gap is the unmodelled/ungated pieces, so the budget may need a second look at the engine's typical-foe numbers.
- Wood-family item laying Poison and Stagnation (Blight Canker was swapped out for Settle the Account).
- Metal or Earth item laying Sundered or Exposed.
- An item that raises Marked Prey's count cap (+16 L5 limit).
- Engine support for Toll Taker, Deep Freeze and the stack effect/duration passives (currently unmodelled), which would add strength legitimately instead of through layers.
