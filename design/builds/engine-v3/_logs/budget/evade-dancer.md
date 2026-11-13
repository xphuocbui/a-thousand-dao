# Budget report: evade-dancer (Drifting Wind Dancer, Phiêu Phong Vũ Giả)

Date 2026-11-13. Realm nguyen_anh, budget 23 %.

## Claimed share
Before 103 % (OVER_BUDGET). After 22 % (`layer_budget`).

## Layers (L1-L5)
Before [400, 260, 250, 150, 100]. After [210, 120, 80, 40, 30].
Cut hardest: L5, L4, L3 (the concept runs on evade and art speed from items). L1 and L2 kept highest (crit and art output).
An exact 220 on L1 printed 23 % but flagged OVER_BUDGET by rounding, so L1 is 210.

## Fights (20 runs, `--matrix`, mean s and wins-losses)
| Matchup | Before | After |
|---|---|---|
| typical, same realm | 1.2 s, 20-0 | 3.0 s, 20-0 |
| typical, one realm higher | 2.1 s, 20-0 | 6.1 s, 20-0 |
| top end, same realm | 7.1 s, 17-3 | 9.0 s, 0-20 |
| top end, one realm higher | 5.1 s, 0-20 | 5.1 s, 0-20 |

The typical same-realm fight is 3.0 s, still below the 10-20 s expected at budget: the evade and speed gear carry it.

## Changes beyond `layers`
None. No technique, item or art was removed. Guide updated (numbers, new "Budget revision (2026-11-13)" section). The earlier `--without` tests in the guide were not re-run and are marked so.

## What the build lacks to stay strong
- An evade-cleanse treasure (Wind family) to answer damage ticks and own stacks.
- A ward that stops damage ticks, for an evade build.
- A thần thức (divine sense) pendant or banner that lifts the extra-slot limit, so Slow Hour Needle fits.
- The engine cannot yet run Phantom Dodge (basics counting as evades); once it can, the fan gains most.
- Top-end damage: with the layers cut the build cannot beat the top-end same-realm foe; it needs sustained-damage Wind arts or Wind-stack payoff pieces.
