# curse-engine: The Straw Effigy (Thảo Nhân Chú), rebuilt from the library

Every small blow writes another curse on the foe; when the board is full, the big seal comes down.

Files: `builds/curse-engine.fight.json` (Nascent Soul, nguyen_anh, defining realm) and `builds/curse-engine.ket-dan.fight.json`.

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Slipper Blow (quick palm, lays Sundered) | `sundering-wedge` (lays 2 Sundered) | hundred-blades-canon (6) |
| Straw Binding (quick blow, lays Exposed) | `needle-rain` (six cheap hits, each one a litany trigger); Exposed is laid by the Litany and by the wedge's cracked step | hundred-blades-canon (1) |
| Iron Nail (heavy seal, reads the board) | `branding-seal` (heavy seal, 40 % soul passes wards) | nine-seal-ledger (6) |
| Iron Nail's wait for the board | `frozen-hour-seal` (reads Slowed Time, pulls the other arts closer) | nine-seal-ledger (3) |
| Sealed Meridian / delay | `pinning-arrow` (Slowed Time, delays the foe's longest timer) | hunters-reach-canon (1) |
| (new, no old piece) | `ambush-talisman` (hidden talismans spring on the next hit) | nine-seal-ledger (1) |
| Straw-Man Litany Scripture (main method) | hunters-reach-canon (main) with hundred-blades-canon and nine-seal-ledger as auxiliaries | n/a |
| Ash of the Effigy, Paper Boat Crossing, Paper Money Burning | none | lost |
| Kept as Effects: Litany (four fixed if-chains), Driven Nail, Weight of Names, Marked Prey, Blood Drinker | n/a | n/a |

Nascent Soul carries all six arts. Ket Dan (5 slots) drops `ambush-talisman`.

## Techniques chosen and why

- **hunters-reach-canon (main, Yellow, kim).** The only kim main that carries a curse art (`pinning-arrow`, Slowed Time) and a status-duration passive scoped to curses. Its other arts (nocked-arrow, coiling-thrust) were not slotted.
- **hundred-blades-canon (secret, kim).** The suite whose arts lay Sundered, the old build's core curse, and a many-hit art to feed the Litany and Driven Nail. Its passives also carry curse duration.
- **nine-seal-ledger (secret, kim).** Seal arts and `status_duration +20 [curse]` are the closest library match to the Iron Nail and its tolling seal. It gives the heavy hit (`branding-seal`) and a timer-mover.
- All three name kim only, so wood (the build's second root) is unused. The wood curse suite (rotting-canopy-canon) would not fit the six slots next to these.
- Purity: the old file had no `purity` field. I wrote `{"metal": 80, "wood": 40}` from the guide's "Metal–Wood, Metal higher"; the amounts are my reading, not the old build's.

## What was lost in the move

- **Iron Nail has no equivalent.** No library seal waits for the full board and reads curse stacks. `branding-seal` is the nearest heavy seal.
- Paid in Nails (the Nail's refund), Nail Into Straw (+60 more on Metal) and the Nine Knots seal bonus left with the invented Scripture.
- Ash of the Effigy, Paper Boat Crossing and Paper Money Burning: no library art answers cleanse, escape or heal here.
- The old Nail guard ("fires when the last name is on") is not expressible on a library art without an override.
- Insect-Waking Incense (seal-scoped L4) cannot be written without an art override. Only the Nine Rods formation (+80 L4) stays.
- The old per-art `x` bonuses (L2 140–220, L4 150 on the Nail) are gone because arts take no overrides. L2 is now 0 in the whole build.

## Matchups (Nascent Soul file, `--matrix`)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 1.9 | 20-0-0 | never | 1.9 | driven-nail 3.0, trig_budget 0.1 |
| typical hoa_than+1 | 3.0 | 20-0-0 | never | 3.0 | driven-nail 8.5, trig_budget 0.9 |
| top_end nguyen_anh+0 | 5.2 | 20-0-0 | never | never | driven-nail 26.4 |
| top_end hoa_than+1 | 4.3 | 0-20-0 | 4.0 | never | driven-nail 14.8 |
| top_end ket_dan+0 (Ket Dan file, no matrix) | 8.3 | 0-20-0 | 7.8 | never | driven-nail 39.3 |

Health left: 100 % / 100 % / 95 % / 0 % / 0 %. The Ket Dan file was run once without `--matrix`, so it has only the top_end same-realm row.

## `--without` tests (typical, same realm, nguyen_anh+0)

| Removed | Before | After |
|---|---|---|
| `tech:hunters-reach-canon` (main method) | 1.9 s, 20-0, 100 % | 2.0 s, 20-0, 100 % (identity reads `changed`) |
| `driven-nail` (identity piece) | 1.9 s, 20-0, 100 % | 1.9 s, 20-0, 100 % (`NO_CHANGE`) |

For top_end at the same realm: without the main method 5.2 → 5.3 s; without Driven Nail 5.2 → 5.2 s. Only top_end hoa_than+1 moves with Driven Nail removed (4.3 → 4.5 s, still 0-20).

## UNMODELLED

- Sealed Meridian's layer: the engine status takes no layer here, so it may lock the engine default instead of the foe's L2.
- Litany refresh of the curse with least time left, and the "fewer stacks than the most" rule: written as fixed if-chains, with no refresh.
- Weight of Names and Marked Prey: read `foe.distinct_statuses`, which counts non-curse statuses and not stacks.
- Fourth Nail (curse_slots +1, curses on you last twice as long): no keystone field. Heavy Breath is laid by the litany but may not fit a fourth slot.
- Backlash and Ash of the Effigy: the engine has no cleansing enemy.
- Insect-Waking Incense: seal-scoped L4 needs an art override.
- Linh lực on hit: not modelled.
- Paid in Nails and Nail Into Straw: lost with the invented Scripture.
- Technique passives with no engine stat (status_duration, stack_duration) and scoped passives the engine applies to every art (hundred-blades kim art_speed, nine-seal art_speed, art_cost, x_soul): printed by fight.py as UNMODELLED.
- Ket Dan: `ambush-talisman` left out (five slots).

## Observations

At the same realm the typical foe dies in 1.9 s and the top_end foe in 5.2 s with 95 % health left, both under the 30–60 s band, and the build also beats typical foes one realm up. It loses top_end at the next realm (hoa_than+1, 0-20, dry at 4.0 s) and the Ket Dan file loses top_end 0-20 at 8.3 s. The guide's claims partly hold: a quick win with health to spare against a same-realm foe, but not the guide's 1.5 s at 70 % against top_end, and the claim that "Driven Nail is core" does not: removing it changes nothing at the same realm, and the engine clipped it 26.4 times per top_end fight. The `--without tech:hunters-reach-canon` test is a 0.1 s change at most, so the main method contributes little beyond `pinning-arrow`. In the typical nguyen_anh+0 fight, `needle-rain`, `sundering-wedge`, `frozen-hour-seal` and `branding-seal` are NEVER_FIRED because the fight ends before they come up (the foe dies in 1.9 s). Every art fires in the other matchups. The Litany's Heavy Breath fourth name and the build's Sealed Meridian protection were not checked in the output.
