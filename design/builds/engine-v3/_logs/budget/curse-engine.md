# curse-engine: budget revision (2026-11-13)

Files edited: `builds/curse-engine.fight.json` (`layers` only), `curse-engine.md`. No technique, item or art was changed or removed.

## Claimed share (Nascent Soul [Nguyên Anh], budget 23 %)
- Before: 38 % (OVER_BUDGET). After: 22 % (`layer_budget`).

## Layers [L1..L5]
- Before: [330, 0, 150, 80, 0]. After: [310, 0, 0, 80, 0].
- L3 150 removed: gear that the items already give as `item:` Effects (counted twice). L1 330 -> 310 to get under 23 %. L4 80 (Nine Rods) kept.

## Fights (`--matrix`, mean s, wins-losses-draws)
| Matchup | Before | After |
|---|---|---|
| typical nguyen_anh+0 | 2.3, 20-0-0 | 4.4, 20-0-0 |
| typical hoa_than+1 | 6.1, 20-0-0 | 8.8, 20-0-0 |
| top_end nguyen_anh+0 | 9.9, 14-5-1 | 12.6, 0-20-0 |
| top_end hoa_than+1 | 7.9, 0-20-0 | 7.9, 0-20-0 |

Typical same-realm still dies in 4.4 s, faster than the 10-20 s target; top-end same-realm is now a loss. The build runs dry on linh lực at 9.0 s against top-end.

## What the build now lacks
- A curse-scoped weapon (stack effect/duration for curses; the sword's boosts are Metal-debuff scoped).
- Linh lực sustain without an art-speed cost (Wood or Water pendant, e.g. `wood-sap-heart-pendant`, `water-moon-well-pendant`); it goes dry at 9 s.
- A seal-scoped L4 source (Insect-Waking Incense is unmodelled) and a ward that beats ws 120.
