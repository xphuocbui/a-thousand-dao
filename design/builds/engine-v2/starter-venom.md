# The Quiet Vine (Tĩnh Đằng Độc Kinh) — rebuilt from the library

Lay poison in thorn batches, keep yourself topped up with Wood healing, and let the enemy lose the race you refuse to run.

Fight files: `builds/starter-venom.fight.json` (Foundation, Trúc Cơ, the defining realm) and `builds/starter-venom.ket-dan.fight.json` (Core Formation, Kết Đan). The old `starter-venom.cleanser.fight.json` was an enemy variant at the same realm, not another realm, so it has no v2 file.

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Thorn Seed (10 Poison stacks, 14 s, cooldown 3 s) | `thorn-rain` (6 thorns, 1 Poison stack each for 6 s, crit thorns lay 1 more) | rotting-canopy-canon (1) |
| Rot Bloom (24 stacks, 20 s) | `blight-canker` (2 Poison stacks for 8 s and 3 Stagnation; Stagnation feeds on Chaos ticks) | rotting-canopy-canon (2) |
| Weeping Sap (heal + Wood stacks) | `second-spring` (heal when at 95 % health or less; three Springs echo the last art) | verdant-cycle-scripture (4) |
| (Foundation has no fourth old art) | `harvest-bloom` (2 Poison stacks; at 12 Poison it harvests them as Chaos hits and a heal) | verdant-cycle-scripture (6) |
| Venom Tithe (Core Formation) | `thornling-grove` (Poison, a Thornling that strikes with Chaos and seeds Poison) | rotting-canopy-canon (6) |
| Quiet Vine Sutra (secret technique) | `rotting-canopy-canon` | secret |
| Thanh Mộc Địa Quyết (main technique) | `verdant-cycle-scripture` | main |

Kept from the old file unchanged: realm, `layers` [60,0,25,15,0] at Foundation and [80,0,40,20,0] at Core Formation, speed, cost, regeneration and healing fields, n_body, n_qi, enemy. Purity: wood 50 (see the loss list).

## Techniques chosen and why

- **verdant-cycle-scripture** (Profound main, Wood). It carries the heal (`second-spring`) and the harvest (`harvest-bloom`), which stands in for the long batch: it pays out the Poison stacks that the other suite lays.
- **rotting-canopy-canon** (Earth secret, Wood). It is the poison suite itself: `thorn-rain`, `blight-canker` and `thornling-grove`, all of which lay Poison. Its Chaos ticks and Stagnation engine reward stacking Poison, which is what the guide's layers L1 and L3 and the sustain feed.
- Both name only `moc`; wood purity makes both usable. Four slots at Foundation (3 + 1), five at Core Formation, all filled. `bloodroot-pact` (health-pay) was left out; the heal slot matters more to this build's sustain claim. At Foundation `thornling-grove` and `harvest-bloom` compete for the last slot: `harvest-bloom` won because the Poison is already laid by two arts.

## What was lost in the move

- **Rot Bloom's 24-stack, 20 s batch.** No library art lays a batch that size. `blight-canker` (8 s) and `thorn-rain` (6 s) are short; the batch-stacking identity is now many short batches.
- **L2 points on the poison arts** (old `x` [0,45,0,0,0] and [0,55,0,0,0]: the Rot Deepens / Long Roots pieces of Quiet Vine Sutra). They belonged to the invented arts and were removed. The same goes for Patient Venom's folded cap.
- **Weeping Sap's Wood stacks** (regeneration buff). `second-spring` is a plain heal with an echo; the Wood regeneration stack is lost.
- **Venom Tithe's linh lực refund.** No library art returns linh lực on a Poison hit.
- **Purity.** The old file carried none; the guide says "Wood, middling purity". Wood 50 was written so the Wood techniques are usable. That is a read of the guide, not a copied number.
- Technique passives with no engine stat (stack_effect, stack_duration, status_duration for Wood; health regeneration; health-pay) print as UNMODELLED and are not run.

## Results (typical foe = same-realm typical unless stated)

Foundation file, `--matrix`, 20 fights each; "Clipped" lists the notable ones at typical same realm only.

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, truc_co (same realm) | 30.9 | 20-0-0 | never | 22.0 | canker-spread 167.0, canker-wither 151.4, trig_budget 0.9 |
| typical, ket_dan (+1) | 7.9 | 0-20-0 | 6.8 | never | canker-spread 13.0 |
| typical, nguyen_anh (+2) | 3.5 | 0-20-0 | 2.7 | never | none |
| top_end, truc_co | 1.6 | 0-20-0 | 1.6 | never | none |
| top_end, ket_dan | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end, nguyen_anh | 1.0 | 0-20-0 | 1.0 | never | none |
| Core Formation file: typical, ket_dan (same realm, no matrix) | 19.6 | 20-0-0 | never | 15.1 | canker-spread 150.4, canker-wither 124.5, grove-seed 1.8, trig_budget 0.7 |

Health left at the end of the same-realm typical fights: 99 % at Foundation, 100 % at Core Formation.

## The two --without tests (typical, same realm)

| Removed | Before | After |
|---|---|---|
| `tech:verdant-cycle-scripture` (main technique passives) | 30.9 s, 20-0, foe dry 22.0, 99 % health left | 31.1 s, 20-0, foe dry 22.4. Changed by 0.2 s: almost nothing, because most passives have no engine stat. |
| `thorn-rain` (identity art, `--without`) | 30.9 s, 20-0, you dry never, foe dry 22.0, 99 % | 62.4 s, 20-0, you dry 29.2, foe dry 32.5, 80 % health left |

Removing the opening art doubles the fight and puts the build dry on linh lực; it still wins. The identity piece holds. The main technique's passives are barely measurable in this engine; its value here is the two arts it carries, which remain in the file when only its passives are removed.

## UNMODELLED

- Root Drinks the Rot leech: a tree keystone Effect, staged only, never written in the old file.
- Patient Venom per-stack effect: needs a Per modifier on tick stack count; not an engine stat.
- Sap Rises healing from stacks beyond the table: staged only, not in the old file.
- Moss-Ledger cleanse-immunity window: the engine has no such timing rule.
- Spillover: an upgrade (Venom Facet), not part of this build's file.
- Purity wood 50 from the guide's "middling purity": the old file carried no purity.
- technique verdant-cycle-scripture passives stack_effect_pct, stack_duration_pct, health_regen_inc_pct: no engine stat, not run.
- technique verdant-cycle-scripture and rotting-canopy-canon art_speed_pct scoped to Wood: the engine applies it to every art.
- technique rotting-canopy-canon passives stack_effect_pct, stack_duration_pct, status_duration_pct [curse], art_cost_health_pct: no engine stat, not run.

## Observations

Same-realm typical fights last 30.9 s at Foundation (inside the 30-60 s band, near its low edge) and 19.6 s at Core Formation (below the band), with the build winning 20 of 20 and finishing near full health in both. The guide claimed about 38 s at Foundation and about 24 s at Core Formation; the rebuild is about 7 s and 4 s shorter, and the guide's "about 76 % health" is now 99 %, so the safety net is stronger than claimed. It never ran dry on linh lực (guide: never ran dry, holds). "Nothing happens fast" is still true at Foundation, though the foe runs dry first (22.0 s). The guide's dependence on a long batch is not reproduced, because no library art lays one; the guide's claim that losing the opening poison art makes the fight about a minute does hold (62.4 s without `thorn-rain`). Against a foe a realm above or a top-end rush the build loses 20 of 20 in under 8 s, as the guide says ("avoid"). The cleanser claim was not re-tested: no cleanser file was written. No art of the same-realm files is NEVER_FIRED; at +2 and top_end every art is NEVER_FIRED because the fight ends before the first firing. `canker-spread` and `canker-wither` clip heavily (about 150 to 167 per fight): `blight-canker`'s Stagnation spreading is limited by its caps, and that is where this build's poison engine runs hardest.
