# Budget report: deity-warden (2026-11-13)

Files changed: `design/builds/engine-v3/builds/deity-warden.fight.json` (`layers` only) and `design/builds/engine-v3/deity-warden.md`. No technique, item or art was removed.

## Claimed share

| | Share of the typical-to-top-end gap | Budget at hoa_than |
|---|---|---|
| Before | 86 % (OVER_BUDGET) | 30 % |
| After | 28 % (`layer_budget`) | 30 % |

## Layers (L1-L5)

| | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| Before | 400 | 300 | 250 | 150 | 100 |
| After | 170 | 130 | 130 | 70 | 40 |

Why: the old numbers counted what the techniques' passives and items' modifiers already give as Effects, so they were double-counted, and L1 400 was past the soft knee. The cuts fell first on L1 and L2 (offence), which a defensive wall needs least. `ward.layers` and `body.layers` were not touched. Other trials: `[120,100,100,60,40]` = 21 % (typical 7.4 s), `[200,150,150,80,50]` = 35 % (still OVER_BUDGET).

## Fights (20 each, `--matrix`)

| Foe | Mean s before | Mean s after | Wins before | Wins after |
|---|---|---|---|---|
| typical hoa_than | 3.6 | 5.7 | 20-0 | 20-0 |
| top_end hoa_than | 5.2 | 14.8 | 20-0 | 20-0 |

Health left stays at 100 % in all four. The typical fight (5.7 s) is still under the 10-20 s a build at its budget is expected to take, so the wall remains stronger than the budget assumes; I did not cut further because it is already inside the budget and the defensive blocks are outside `layers`.

`--without` on the new file: Anchor 5.5 s / 31.8 s (typical / top-end; it now matters at top-end), Iron Skin Renewed and Shattering Ward NO_CHANGE.

## What the build now lacks

- An offence source that is not a layer: Metal debuff stacks (Closing Palm role) and an Earth/Metal stack-strength piece, so the Metal half of the root contributes (metal family).
- A thần thức piece for the earth family, so more extra slots can be carried.
- Pieces the engine cannot yet run, which a Warden would want: a cleanse-on-a-clock treasure, a soul art (Deaf Verdict), a ward that pays per hit and drains.
- Meridian Map nodes for Earth `attack_pct` and body layers (the only legitimate source left for `layers`).
