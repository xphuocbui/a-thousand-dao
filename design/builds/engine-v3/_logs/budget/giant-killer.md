# Giant Killer (Sơn Hạ Châm): layer budget report, 2026-11-13

## Claimed share
- Before: 88 % of the typical-to-top-end gap (`OVER_BUDGET`; ket_dan budget 17 %).
- After: 17 % (`layer_budget`).

## Layers
| | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| Before | 200 | 225 | 250 | 130 | 100 |
| After | 200 | 70 | 54 | 20 | 10 |

L4 and L5 were cut to the typical enemy's own values (nothing claimed) first: the L5 "Against the Heavens" piece is unmodelled and the techniques and items already run as Effects. L1 was kept whole; the remaining budget went to L2 (+30) and L3 (+14). The probe showed the L1 claim alone is about 11 % of the gap.

## Fights (`--matrix`, 20 seeds; mean time, wins)
| Matchup | Before | After |
|---|---|---|
| typical, ket_dan+0 | 1.0 s, 20 | 3.2 s, 20 |
| typical, nguyen_anh+1 | 1.9 s, 20 | 5.8 s, 20 |
| typical, hoa_than+2 | 4.4 s, 17 | 8.1 s, 0 |
| top_end, ket_dan+0 | 2.1 s, 0 | 2.9 s, 0 |
| top_end, nguyen_anh+1 | 1.6 s, 0 | 1.4 s, 0 |
| top_end, hoa_than+2 | 1.0 s, 0 | 1.0 s, 0 |

Same-realm typical is 3.2 s, still well under the 10-20 s the budget aims for: crit 0.5 x2 and +50 % art speed, not `layers`, make it quick. shatter-edge-cleave (the build's heavy cleave) never fires at the same realm.

## Changes outside `layers`
No techniques, items or arts removed. The file's `_comment` records the cut; the guide gained a "Budget revision (2026-11-13)" section and a new results table; the stale L5 line in UNMODELLED was reworded. The `--without` tests were not re-run.

## What the build lacks to stay strong
- A realm-gap damage piece (identity "half a realm" / Against the Heavens), so punch-up power returns without layers.
- Physical penetration or realm pierce.
- A modifier raising Metal stack applied per hit so the 6-stack break (shatter-edge-cleave) fires.
- A drain-ward armour for Metal (current wards are cast or per-hit).
- Possibly a slower-start fix: the typical same-realm fight is far shorter than budget intent, so more room may exist for the Meridian Map to carry the L2/L3 claim once the tree is drawn.
