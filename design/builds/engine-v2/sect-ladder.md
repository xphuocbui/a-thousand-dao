# The Red Hearth Ladder (Xích Lô Môn Giai Thê), rebuilt on the library

A plain Fire-sect disciple who keeps a small fire alive for a long time: Burn that never stops, a pool that never empties.

Files: `builds/sect-ladder.fight.json` (Foundation, truc_co), `builds/sect-ladder.luyen-khi.fight.json`, `builds/sect-ladder.ket-dan.fight.json`.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Kindle Palm (2 Burn stacks, 2 s cooldown) | Flint Volley (`flint-volley`): 3 charges, each a Fire hit laying 2 Burn stacks | red-sun-scripture (2) |
| Red Lotus Ring (big Burn batch) | Furnace Heart (`furnace-heart`): Fire hits build Heat, the vent cashes up to 60 Burn into free hits | red-sun-scripture (4) |
| Cinder Lance (4 stacks, Core Formation) | Twin Flame Echo (`twin-flame-echo`): every Fire art counts a flame; at 3 the bloom echoes the last art | red-sun-scripture (6) |
| Hearth Banner (Fire buff art, never run) | Brazier Form (`brazier-form`): stance, +15 % damage, Burn mends you | red-sun-scripture (1) |
| Kindled Wound (Effect, Đạo) | kept as Effect `kindled-wound` (L5 +15 while the foe bears a Fire stack) | none |
| Embers Feed the Hearth (keystone) | kept as `k_burn 0.3` | none |
| Red Hearth True Canon (the old công pháp) | Red Sun Scripture (Xích Nhật Kinh, Profound main, hoa) | main |

## Techniques chosen and why

One technique: `red-sun-scripture`, a Profound main with passives art_speed +10 and damage more +3 (both Fire), cost -8 % (Fire) and stack effect +8. It is the only fire suite whose four arts all sit at layers 1, 2, 4 and 6, so it fills all four Foundation slots and unlocks exactly what Foundation allows. Its arts feed on Burn stacks and Fire hits, which is the thing the rest of the build (`k_burn`, Kindled Wound, the Fire purity) already provides. Ashen Phoenix Canon (Heat Haze, Ash Rebirth, Blood-Fed Pyre) was the second candidate, since Burn ticks gather Ash, but it would have needed arts beyond the 4 slots at Foundation and a health cost the guide never asked for. No auxiliary technique was taken: every extra art would exceed the slots (4 at truc_co, 5 at ket_dan). Fire purity 70 to 85 covers `hoa` at every realm. Cultivators at luyen_khi get layers up to 3: only Brazier Form and Flint Volley, in 3 slots with one empty.

## What was lost

- Kindle Palm, Red Lotus Ring, Cinder Lance and Hearth Banner were invented arts with fixed Burn numbers (2, 3, 4 stacks per cast, cheap 2-5 % costs). The library has no pure slow-Burn laying trio; Flint Volley is the nearest and Furnace Heart cashes Burn out rather than building it, a different identity (burst from stacks, not endless ticking).
- The old arts carried an unconditional L5 +15 (Kindled Wound) as an art override. With no overrides allowed, it became a conditional Effect on a Fire debuff read, which may count differently from "your Burn". Not checked beyond the run.
- Embers Feed the Hearth's closing cost (direct Fire hits 15 % less) was already only folded into the old coefficients; it is still not modelled.
- Hearth Banner is gone; Brazier Form is a stance, not a 3-stack buff.
- Ket Dan keeps the same four arts (Red Sun has none beyond layer 6), so the 5th slot is empty and Cinder Lance has no replacement.

## Results

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical truc_co+0 | 20.5 | 20-0-0 | 17.9 | 13.2 | brazier-warm 47.0, heat-build 6.0, trig_budget 1.4, brazier-thorns 1.0 |
| typical ket_dan+1 | 7.9 | 0-20-0 | 6.1 | never | brazier-warm 2.9, brazier-thorns 0.9 |
| typical nguyen_anh+2 | 3.5 | 0-20-0 | 2.7 | never | none |
| top_end truc_co+0 | 1.6 | 0-20-0 | 1.6 | never | none |
| top_end ket_dan+1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end nguyen_anh+2 | 1.0 | 0-20-0 | 1.0 | never | none |
| other realm: luyen_khi typical +0 | 40.6 | 0-20-0 | 27.7 | 31.4 | brazier-warm 102.7, brazier-thorns 1.1 |
| other realm: ket_dan typical +0 | 21.1 | 16-3-1 | 15.8 | 13.6 | brazier-warm 40.0, heat-build 2.2, trig_budget 1.3, brazier-thorns 1.0 |

## --without tests (typical truc_co+0, same realm)

| Test | Before | After |
|---|---|---|
| `--without tech:red-sun-scripture` | 20.5 s, 20-0-0, dry you 17.9, foe 13.2 | 20.2 s, 20-0-0, dry you 19.2, foe 12.3 (changed little) |
| `--without kindled-wound` (identity piece) | 20.5 s, 20-0-0, health left 53 % | 24.5 s, 19-0-1, health left 35 % |

The technique's passives barely matter in this model (two of its four passives are not run), so the suite's worth is in its arts, which stay when only the passive effect is removed. Kindled Wound is the piece that moves the fight.

## UNMODELLED

- Embers Feed the Hearth closing cost (direct Fire hits 15 % less): the engine has no hook for a conditional penalty tied to the keystone; the keystone itself is `k_burn 0.3`.
- Hearth-Warming Pill, Gathering Flame Array, Ember Rod: items and preparation, carried by the typical L3 and L4 points.
- Hoa Đạo Chân Hỏa nodes and the sect tree cluster: sit inside the typical L1 and L2 points.
- Deep Heat: never in the old file; its Per modifier is not expressed here either.
- red-sun-scripture `art_speed_pct` [fire] and `art_cost_pct` [fire]: the engine reads them without hit context, so they apply to every art.
- red-sun-scripture `stack_effect_pct +8` and `stack_duration_pct +4`: no engine stat, not run.
- Qi Refining file: no ward gear, pill or array at that realm; the typical L3 and L4 anchor slightly flatters the build.

## Observations

At the build's own realm against a typical foe the fight lasts 20.5 s with 20 wins, below the 30 to 60 s band; at ket_dan the same four arts last 21.1 s with 16 wins and 3 losses, still short, and at luyen_khi two arts last 40.6 s but lose all 20. The old guide claimed about 11 wins in 20 at Foundation (29 s) and 12 in 20 at Core Formation (21 s); the rebuild wins more often at Foundation (20 of 20, but 8 s faster) and at Core Formation (16 of 20, same length). The claim that the pool never empties holds only partly: you run dry at 17.9 s in 20.5 s fights, so the pool empties near the end, and the foe goes dry first at 13.2 s. Against a realm above and top end the build dies in 1 to 8 s, as the guide warned. Removing Kindled Wound lengthens the fight by 4 s and cuts health left from 53 % to 35 %, so the Effect carries more than the technique. NEVER_FIRED: flint-volley at ket_dan+1 and nguyen_anh+2, brazier-form at nguyen_anh+2, and all four arts against top_end foes (dead before the first firing). brazier-warm is clipped 47 times a fight at truc_co, so its Burn-mends-you mend is mostly overflow by the engine's budget.
