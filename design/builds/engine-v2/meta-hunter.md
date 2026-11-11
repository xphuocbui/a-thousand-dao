# The Open Ledger (Khai Bạ), rebuilt from the library

A Metal cultivator who swears never to pay in blood and never to stall a foe with Stagnation, rebuilt as a Hunter's Reach (bow and spear) plus Nine Seal Ledger (seal) hunter that stacks Slowed Time and seals on the foe.

Files: `builds/meta-hunter.fight.json` (Nguyên Anh, the defining realm), `builds/meta-hunter.ket_dan.fight.json` (Kết Đan). The old file had a Kết Đan file; the two `vs-*` files were matchup variants, not realms, and were not rebuilt.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Whetted Tally (Metal debuff stacks, 3 s) | Pinning Arrow (`pinning-arrow`) | Hunter's Reach Canon (1) |
| Closing the Book (heavy phys hit) | Nocked Arrow (`nocked-arrow`) | Hunter's Reach Canon (3) |
| Bloodhound's Count (sixth-slot closer) | Coiling Thrust (`coiling-thrust`) | Hunter's Reach Canon (5) |
| Writ of Reckoning (the curse-laying identity art) | Ambush Talisman (`ambush-talisman`) | Nine Seal Ledger (1) |
| Clean the Page (cleanse art) | Frozen Hour Seal (`frozen-hour-seal`); dropped at Kết Đan (5 slots) | Nine Seal Ledger (3) |
| Ink-Line Breath (linh lực restore art) | Branding Seal (`branding-seal`) | Nine Seal Ledger (6) |

Kept unchanged: realm, root (`purity` metal 80), layers, crit, ward, body, cleanse share, Withering curse, leech, gain on hit, art speed and cost. The old file held no Effects, counters or states, so none were removed; the old `unmodelled` lines about Dear Blood and Called Debt belonged to the invented Writ and are dropped. The Debt Called, Ledger Seal and L4 lines stay.

## Techniques chosen and why

- **Hunter's Reach Canon** (Yellow main, `kim`): the main method. A "hunter" concept: Slowed Time and Coils feed Nocked Arrow and Coiling Thrust, a whole suite with its engine.
- **Nine Seal Ledger** (Heaven secret, `kim`): the "ledger" and "seal" of the concept. It adds Slowed Time (cross-feeding the first suite), Seals counted by Branding Seal, and curse-duration and seal passives.
- Both are usable by a Metal root. Six arts fill the six Nguyên Anh slots exactly, all unlocked by layer 6 (allowed at Nguyên Anh and Kết Đan).
- Passed over: Nine-Temper Scripture (its Blood-Quench Blade pays 6 % health, against the build's oath), Hundred-Blades Canon (kept in mind as a third technique, but no slot is left).

## Lost in the move

- **Dear Blood / Called Debt** (foe's health-paid costs ×1.5 and a return tick): the Writ had no library equivalent. No library art counters health payment, so the build's first answer is gone; the taken art (Ambush Talisman) is a control and Chaos hit.
- **Stagnation immunity engine** (Clean Ledger, Clean the Page's cleanse): no library art caps Stagnation or cleanses it; Clean the Page was lost, and Withering plus leech sustain remain.
- **Oath check:** none of the six arts pays health or lays Stagnation (checked against the INDEX rules and the Hunter's Reach family file; Seal arts read from the INDEX line only). Pinning Arrow, Coiling Thrust, Nocked Arrow and Frozen Hour Seal lay Slowed Time; whether that counts as "stalling a foe" is the designer's call.
- The ward, leech and Metal-debuff stack identity of Whetted Tally has no one-to-one library art; Pinning Arrow is the closest (a status-laying opener).
- At Kết Đan Frozen Hour Seal was dropped for slots.

## Matchups (Nguyên Anh unless noted; 20 fights)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, nguyên_anh | 1.8 | 20-0-0 | never | 1.8 | none |
| top_end, nguyên_anh | 4.5 | 20-0-0 | never | never | trig_budget 1.5, trig_cap 10.6 |
| typical, hóa_thần+1 | 2.4 | 20-0-0 | never | 2.4 | trig_budget 2.8, trig_cap 2.9 |
| top_end, hóa_thần+1 | 4.7 | 17-3-0 | never | never | trig_cap 8.6 |
| typical, kết_đan (own file) | 2.4 | 20-0-0 | never | 2.0 | trig_budget 1.9, trig_cap 1.8 |

## --without tests (typical, same realm)

| Run | Mean s | W-L-other | Note |
|---|---|---|---|
| Full build | 1.8 | 20-0-0 | nothing fires |
| `--without tech:hunters-reach-canon` | 1.8 | 20-0-0 | identical; also identical against top_end (4.5 s, 20-0) |
| `--without branding-seal` | 1.8 | 20-0-0 | identical; the art never fires at typical |

Against top_end, same realm, `--without branding-seal`: 4.5 s, 20-0 becomes 14.8 s, 20-0 (foe dry 13.7); at hóa_thần+1 top_end: 4.7 s, 17-3 becomes 6.4 s, 0-20. (The `--without` of an art id was accepted by fight.py; the identity piece chosen is Branding Seal, as the Seal-ledger closer.)

## UNMODELLED

- Debt Called Per modifier (+0.4 % more per Stagnation stack on me): not in the engine; L5 left at 0.
- Ledger Seal's entries and oath: no engine rule for the oath.
- L4 against a known quarry: run at 100 points, assumes not blind.
- hunters-reach-canon and nine-seal-ledger `status_duration_pct` passives: no engine stat.
- nine-seal-ledger `art_speed_pct`, `art_cost_pct` and `x_soul` seal-scoped passives: the engine applies them to every art, so the run overstates them for non-seal arts.
- Kết Đan: Frozen Hour Seal left out for slots.

## Observations

At the same realm against a typical foe the fight lasts 1.8 s, far under the 30–60 s band, and no art ever fires (all six NEVER_FIRED), as the old guide already said of the basic attack ("about 2 s"). Against top_end the fight is 4.5 s, also short of the band, and every art fires (Frozen Hour Seal and Branding Seal once). The technique passives are inert here: removing Hunter's Reach Canon changed nothing in any matchup. The guide's claim of 6 wins in 20 against a top-end generalist no longer holds, since the rebuilt build wins 20-0 (17-3 a realm up), but that is a different build, with no Dear Blood or Stagnation answers to test, so the guide's counter claims (health-payers, Stagnation) cannot be checked on this file. The one stress point is Branding Seal: without it top_end takes 14.8 s and a realm up the build loses 0-20. NEVER_FIRED at the typical foe: all six at nguyên_anh; at hóa_thần+1 Frozen Hour Seal and Branding Seal; at kết_đan Branding Seal.
