# The Empty Hall (Không Đường): carry one art and leave every other slot empty, so each empty slot speeds the art up and rings a Metal stack onto the foe.

Defining realm: Deity Transformation (Hóa Thần, `hoa_than`). File: `builds/one-art.fight.json`. The old `one-art*.fight.json` files were not found by Glob (only the guide, a sheet and a driver note exist), so the realm, layers and effects come from the guide. No other-realm files were written, because no old fight file named one.

## Rebuild

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Grindstone Stroke (invented, 6.75 coefficient) | `shatter-edge-cleave` (closest: a heavy Physical Metal art that cashes in Metal debuff stacks) | nine-temper-scripture (6) |
| Whetstone Scripture / True Scripture (one-art technique) | nine-temper-scripture | main, Yellow |
| Ore-Vein Scripture (Physical damage passive) | hundred-blades-canon (Metal damage, crit, art speed passives) | secret |
| Foe-facing passives and crit | afterimage-sword-canon (art speed, crit passives) | secret |
| Vow, Clear Path, Undivided, Quiet Channels, Empty Hall, Steady Breath, Blood Drinker | kept as Effects or fields (Đạo and item pieces) | none |
| Called Blow | crit chance 0.333, mult 3.0 | none |

## Techniques chosen and why

The main technique is nine-temper-scripture (kim). Its cleave breaks the Metal debuff stacks that Empty Hall lays, so the rest of the build feeds it. Two kim secrets add crit and art-speed passives. Only the cleave is slotted, so the Vow stays whole: the other arts of these techniques are carried but never slotted.

## Lost in the move

- The 6.75 and 9.55 coefficient: the Vow's `art_coef_add` has no key and library arts take no overrides. The cleave is 1.6 at the library value.
- The 12 s, 12.5 % identity: the cleave costs 9 % with an 8 s cooldown.
- Each Empty Hall ring's free echo hit: only the Metal stacks are modelled.
- Measured Stroke, Open Sky, the Nine Rods Array, the Iron-Sand Hand Bath and Treasure Nurtured Within were left out.

## Results (`--matrix`; there is no +1 realm above hoa_than)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, same realm | 8.1 | 20-0-0 | never | 8.0 | trig_budget 1.0 per fight |
| top_end, same realm | 1.6 | 0-20-0 | 1.0 | never | none |

## --without tests (typical, same realm)

| Removed | Mean s | W-L | Foe dry | Health left | Cleave fires |
|---|---|---|---|---|---|
| none | 8.1 | 20-0 | 8.0 | 80 % | 2.0 |
| `tech:nine-temper-scripture` | 8.1 | 20-0 | 8.0 | 79 % | 2.0 |
| `empty-hall` (identity) | 10.4 | 20-0 | 9.6 | 68 % | 3.2 |

## UNMODELLED

- Vow of the One Stroke: no key for the extra coefficient, and arts take no overrides.
- Empty Hall rings: modelled as 6 Metal stacks laid at firing; the echo hit of each ring is not modelled.
- Called Blow: a fixed 33.3 % chance; the real meter is deterministic.
- Six wards: modelled as the realm's typical Common Ward.
- Single-Notch Sword: reduced to +30 art speed and Blood Drinker 6 %; its penetration and growth are not modelled.
- Open Sky, Whole Weight and plain armour: folded into layers L2 80 and L3 40; L4 is 0 because the fight is blind.
- Technique passives with no engine stat (stack and status duration) are not run. The `[kim]`-scoped art speed passives apply to every art.

## Observations

A fight against a typical foe at the same realm lasts 8.1 s, far below the 30-60 s band, and the build wins all 20 runs with 80 % health left. The numbers are mine, not the old file's, because that file was missing; the layers, crit and art speed (+280 from Clear Path, +30 from the sword, plus the technique passives) are read from the guide, and the guide's 2.5 s stroke is not checked against a measured cooldown. Against top_end the build loses all 20 runs in 1.6 s and the cleave never fires (NEVER_FIRED); the build is never dry against typical but is dry at 1.0 s against top_end. The guide's claim that the empty slots make one art strong holds for the typical foe, but the claim that the Metal stacks matter does not: removing Empty Hall lengthens the fight from 8.1 s to 10.4 s without changing the win count, and the main technique's passives change nothing measurable (79 % against 80 % health left). The `trig_budget` clip (1.0 per fight) shows the cleave's cash-in hits hit the trigger budget. Every number here is one run of 20 seeds and not a verdict.
