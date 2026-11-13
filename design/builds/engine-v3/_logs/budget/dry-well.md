# Budget report: dry-well (Khô Tỉnh), 2026-11-13

**Claimed share (nguyen_anh, budget 23 %):** 25 % before → 23 % after (`layer_budget`).

**`layers` (L1–L5):** `[160, 0, 250, 0, 0]` → `[160, 0, 230, 0, 0]`. Only L3 (gear) cut, by 20. Reason: the seven items and two techniques already run as Effects, no Meridian Map source is named for the L3 value, and the concept (Ice stacks, drain bills, art speed) needs gear damage least. I measured the slope: L3 150 would claim 13 % and fight almost identically (top_end nguyen_anh+0 61.8 s, 0 wins), so the build has headroom; I took the smallest cut that fits.

**Fights (20 each, `--matrix`):**

| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 6.5 s, 20-0-0 | 6.3 s, 20-0-0 |
| typical hoa_than+1 | 65.0 s, 20-0-0 | 65.8 s, 20-0-0 |
| top_end nguyen_anh+0 | 62.5 s, 0-12-8 | 62.0 s, 0-12-8 |
| top_end hoa_than+1 | 10.7 s, 0-20-0 | 10.7 s, 0-20-0 |

The build beats a typical same-realm enemy in about 6 s, quicker than the 10–20 s expected at budget. It cannot beat the top-end enemy (0 wins); the top-end nguyen_anh+0 fight is long (62 s) and the build runs dry at 8.2 s while the foe runs dry at 33.8 s. The guide's older top_end nguyen_anh+0 numbers (17 s) came from an older engine state.

**Removed pieces:** none. No technique, item or art was changed.

**What the build lacks to stay strong (catalogue pieces it would want):**
- An item that raises the bills the foe's drain wards pay (Weighted Bucket / Absolute Zero payoff), Ice or Water.
- Linh lực sustain on a necklace or ring (Water Table / Frost Tithe returns, Owed Water repayment): it runs dry at 8–9 s in the long fights.
- Engine support for Toll Taker and the exact Deep Freeze trigger (events for Ice stacks crossing 10 and for the extra art cost the foe pays); both are unmodelled or approximated, so the build's signature is under-measured.
- A cheap utility piece (TT 7 or less) to fill the last unused thần thức.
