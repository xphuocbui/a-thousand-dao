# The Brimming Hand (Mãn Tức Quyền), rebuilt on the library: a root-Earth brawler whose basic punch rides on a wall of body shields that burst back into hits

## Old piece → library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| No arts (wards only, Closed Hand Vow) | none one-to-one; five wall-and-fist arts instead | see below |
| Wall of shields held in art slots (Mountain Screen, Iron Shirt) | `bastion-reprisal` (body shield, bursts when it breaks) | mountain-heart-canon (4) |
| Same wall, fist form | `bulwark-knuckle` (body shield, Ram, Slam) | unbroken-flesh-canon (3) |
| Earth buff stacks from punching (Settled Dust) | `sinking-weight` (Earth stacks on the foe, Strata) | mountain-heart-canon (2) |
| Heavy punch, Stored Breath's payoff | `last-breath-fist` | unbroken-flesh-canon (5) |
| Earth engine finisher | `strata-hammer` | mountain-heart-canon (6) |
| Uncarved Stone Fist (body technique, invented) | `unbroken-flesh-canon` (body) | n/a |
| Generated Earth main method | `mountain-heart-canon` (tho main) | n/a |

## Techniques chosen and why

- **Main: `mountain-heart-canon`** (Profound, Earth). It is the only Earth main in the catalogue. The root has purity in `earth` (80), so it is usable. Its suite is shield, Earth stacks and Strata.
- **Auxiliary: `unbroken-flesh-canon`** (Yellow body, always usable). It is the fist-and-body suite and the nearest thing to the invented Uncarved Stone Fist. Its shield and Ram engine matches the shield breaks that `bastion-reprisal` pays off.
- **Not taken:** `marrow-tithe-strike` (pays health and writes Debt, off-concept) and `mountain-stance`. The stance slows the basic attack by 40 percent, and the engine would toggle it on cooldown. Five arts fit the five slots at Kết Đan and sit within the six at Nguyên Anh. All unlock at layer ≤ 6, so the realm allows them.
- The auxiliary slot not used: the second body technique `mountain-bone-body-art` would bring a second stance and push past the slots.

## What was lost

- **Stored Breath**, the identity: the banked overflow added to the next punch. It belonged to the invented Uncarved Stone Fist and has no library equivalent. The closest suite is the shield-and-burst wall. It was never an Effect in the old fight file, only an UNMODELLED line, so the old file did not measure it either.
- **Closed Hand Vow** (the enabler): it needs no damaging art slotted. The suite carries damaging arts, so the Vow is void. The ward kept from the old file already had it folded in.
- Quiet Channels, Settled Dust, Still Water, Unyielding Breath, Elemental Fist, Steady Breath, Full Sea, Bare Rack and the basic attack speed and flat-coefficient lines: none was ever in the old file's fields, so they stay unmodelled.
- "Never cast a single art": the build now casts five. Arts firing once each per fight cost linh lực the ward would have kept.

## Matchups (rows: foe tier and realm offset from the build's realm; 20 rolls)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, Nguyên Anh +0 | 9.0 | 20-0-0 | never | 8.6 | bulwark-ram 0.5 |
| typical, Hóa Thần +1 | 18.0 | 20-0-0 | never | 17.4 | bulwark-ram 1.4 |
| top_end, Nguyên Anh +0 | 6.4 | 0-20-0 | 6.1 | never | none |
| top_end, Hóa Thần +1 | 2.8 | 0-20-0 | 2.8 | never | none |
| Kết Đan file, typical +0 | 10.4 | 20-0-0 | never | 9.1 | bulwark-ram 0.6 |

## --without tests (typical, Nguyên Anh +0)

| Removed | Before | After |
|---|---|---|
| `tech:mountain-heart-canon` | 9.0 s, 20-0 | 9.0 s, 20-0 (NO_CHANGE at every row) |
| `bastion-reprisal` (identity piece) | 9.0 s, 20-0 | 10.7 s, 20-0; at Hóa Thần +1 18.0 → 26.7 s |

The technique's passives are all stats the engine has no stat for (body shield, Earth stack effect and duration), so removing them changes nothing. The arts stay, since they are carried as `lib` arts.

## UNMODELLED

- Closed Hand Vow: void with damaging arts slotted; the old file only folded it into the ward drain floor.
- Stored Breath, Quiet Channels, Settled Dust, Still Water, Unyielding Breath, Elemental Fist, Steady Breath, Full Sea, Bare Rack: never in the old file as Effects; Stored Breath belonged to the invented technique.
- `basic_speed_pct` and `basic_coef_add`: not in the old file's fields, not added.
- Layered wards: modelled as the old file's one drain ward; payloads, shields and per-hit wards are not modelled.
- `mountain-stance`: left out on purpose (basic attack slowed 40 percent).
- Technique passives `body_shield_pct`, `stack_effect_pct [tho]`, `stack_duration_pct [tho]`, `health_regen_inc_pct`, `khi_huyet_pct`: no engine stat, so they did not run.

## Observations

The typical foe dies in 9.0 s at Nguyên Anh, 10.4 s at Kết Đan and 18.0 s one realm up, all below the 30-60 s band; the typical foe goes dry at 8.6 s and the build never does. The top-end foe wins every roll, in 6.4 s at the same realm, and the build runs dry at 6.1 s; the old guide's claim of a Nguyên Anh race win against the top-end caster does not hold now, and neither does its claim of ending ordinary fights in one or two punches. That was without Stored Breath or the speed and coefficient lines, which the old file never carried, so the loss cannot be assigned to the library move alone. `bastion-reprisal` never fired against the top end at Nguyên Anh, and no art fired at Hóa Thần +1 (NEVER_FIRED for all five; the fight ends in 2.8 s). `bulwark-ram` is clipped 0.5 to 1.4 times per fight. Taking `bastion-reprisal` out lengthens the typical fight (9.0 to 10.7 s, 18.0 to 26.7 s), so it carries real damage; the main technique's passives carry none the engine can see.

LIB-DONE design/builds/engine-v2/bare-fist.md
