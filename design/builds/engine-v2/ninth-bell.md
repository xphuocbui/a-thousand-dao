# The Ninth Bell (Cửu Hưởng Đạo): a Metal (kim) art build that wants its timers to line up, rebuilt on library arts

Fight file: `design/builds/engine-v2/builds/ninth-bell.fight.json` (Core Formation, ket_dan; the old build had only this one fight file, so there is no other realm file).

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| First Toll (Nhất Hưởng), 2.4, 2 s | `whetstone-pass` | nine-temper-scripture (1) |
| Second Toll (Nhị Hưởng), 3.3, 4 s | `blood-quench-blade` | nine-temper-scripture (2) |
| (no old piece: the timing of the Tolls) | `sheathed-edge` | nine-temper-scripture (4) |
| Great Toll (Đại Hưởng), 4.5, 6 s | `shatter-edge-cleave` | nine-temper-scripture (6) |
| Tolled Seal, the seal form | `frozen-hour-seal` | nine-seal-ledger (3) |
| Nine-Toll Timetable (main technique) | nine-temper-scripture (main, kim) | n/a |
| On the Beat, Sustained Note, Bare Vessel, Ringing Ground | unchanged: not art pieces; carried as `unmodelled`, as in the old file | n/a |

Kept as in the old file: Core Formation, `layers [134,0,110,0,0]`, art speed +100, art cost 25 %, regen +4, crit chance 0 with mult 1.5, ward ws 120 / we 120, body n 1.6 / 2.0. `purity {"metal": 80}` is added: the old file had no purity, and the guide only says Metal, so 80 is my assumption. The old arts' `x` tags were removed with the arts.

## Techniques chosen and why

- **nine-temper-scripture** (main, kim, 4 arts: whetstone-pass 1, blood-quench-blade 2, sheathed-edge 4, shatter-edge-cleave 6). It is the Metal main method whose engine is a timer and a count: every Metal art adds a Temper (crit chance), crits bank keen strikes. The build has crit 0, so Temper is the only source of crit. The whole suite is carried, all layers ≤ 9.
- **nine-seal-ledger** (secret, kim). The guide's arts were `seal` form (Tolled Seal), and this canon is the seal canon with timer-moving arts. Only `frozen-hour-seal` (layer 3) is slotted: the five slots at ket_dan are full with 4 temper arts + 1 seal art. The seal passives (art speed +12, cost -9, crit damage +27) are the draw.
- Rejected: hunters-reach-canon (also kim, but its engine wants spear/bow arts and Slowed Time stacking, and is a worse fit for the rhythm concept).

## What was lost

- The Nine-Toll Timetable's three bell arts as a rhythm: cooldowns authored at 2/4/6 s so that +100 art speed gives exactly 1/2/3 s. The library arts have their own cooldowns, so "tuned to the exact art speed" no longer holds; no library art has a beat-aligned cooldown. The closest I took is the Metal suite with a timer engine.
- The Great Toll's "half the damage in one stroke" has no library equivalent (the closest is `shatter-edge-cleave`, which pays off on Metal debuff stacks, not on the third beat).
- "Seven arts in one meter" at Deity Transformation: no second realm file was asked for.
- Crit stays a sacrifice in the guide; here Temper creates crit anyway.
- Still unmodelled from before: On the Beat, Bare Vessel, Sustained Note (they are Đạo/tree pieces; the engine has no on-beat guard).

## Fight results (matrix, 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical ket_dan+0 | 6.2 | 20-0-0 | never | 6.1 | none |
| typical nguyen_anh+1 | 11.5 | 0-20-0 | 10.0 | 10.5 | none |
| typical hoa_than+2 | 5.9 | 0-20-0 | 5.9 | never | none |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 | never | none |
| top_end nguyen_anh+1 | 1.4 | 0-20-0 | 1.4 | never | none |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never | none |

## --without tests (typical, same realm ket_dan+0, before and after)

| Test | Mean s | W-L | Foe dry | Health left |
|---|---|---|---|---|
| baseline | 6.2 | 20-0 | 6.1 | 71 % |
| `--without tech:nine-temper-scripture` (main technique passives) | 6.7 | 20-0 | 6.2 | 70 % |
| `--without whetstone-pass` (identity piece; the guide's identity piece, On the Beat, is not modelled, so I used the suite's opening art) | 7.5 | 20-0 | 6.8 | 64 % |

Note: removing `whetstone-pass` removes the art from the loadout, not an Effect of it; removing the main technique removes only its passives (arts stay).

## UNMODELLED

- Sustained Note's cap and reset on a missed beat: kept from the old file; the fight is short.
- v1 pierce_pct 30: old field with no engine key.
- v1 guard body_guard_pct 10: old field with no engine key.
- v1 conditional_mods (On the Beat, Bare Vessel, Sustained Note): the engine has no on-beat guard and these were not re-modelled; they are not arts.
- v1 ward shape: pass/drain shares retired; the Common Ward at this ws and we stands in.
- nine-temper-scripture art_speed_pct [kim]: engine reads art speed without hit context, so it applies to every art.
- nine-temper-scripture stack_duration_pct +4 [kim]: no engine stat.
- nine-seal-ledger art_speed_pct [seal], art_cost_pct [seal], x_soul [seal]: no hit context, applied to every art.
- nine-seal-ledger status_duration_pct +20 [curse]: no engine stat.

## Observations

The same-realm typical fight lasts 6.2 s against the 30-60 s band, far short; it ends 20-0 with the build on 71 % health, and the foe runs dry at 6.1 s. One realm up the fight is 11.5 s and lost 0-20 (both sides dry about 10 s), two realms up it is lost at 5.9 s with the build dry, and top-end foes kill it in 1-2 s. The guide's claims: a win at the same realm holds, the one-realm-up loss holds (the old file had the foe left on 59 %; the loss now is a long drain race rather than a 2 s burst), and "dies on the second beat" no longer holds because the fights run 6-11 s. The claims about the exact beat (1/2/3 s, 3 s boss fall) cannot be checked, since the arts are not beat-aligned and On the Beat is unmodelled. The `--without` tests are small: the main technique's passives move the fight by 0.5 s (6.2 vs 6.7) and the opening art by 1.3 s (6.2 vs 7.5), both wins either way. NEVER_FIRED: against top_end at ket_dan+0 and nguyen_anh+1, `shatter-edge-cleave` and `frozen-hour-seal` never fire (the fight ends in 2 s); at hoa_than+2 top_end `blood-quench-blade`, `sheathed-edge`, shatter-edge-cleave and frozen-hour-seal never fire. No art is NEVER_FIRED in the typical fights.
