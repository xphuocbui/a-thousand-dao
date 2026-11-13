# The Armoury Mind (Tàng Binh Thức), geared

Hang seven treasures on one mind: gear fills the layer, and the weapon count strikes, walls and counts. Realm: Nascent Soul (nguyen_anh). Fight file: `builds/armoury-mind.fight.json`.

## Loadout

Build `divine_sense` is absent (1.0) and no chosen item gives than_thuc_pct, so the extra limit is 45 × 1.0 × 1.0 = 45.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm) `metal-hundred-edge-flying-sword` | 3 | Its art counts as a Hundred-Blades Canon art, lays Metal stacks and breaks them; swapped in for Called Blade (`flying-blade-retinue`) |
| Armour | Tortoise-Scale Armour (Quy Lân Giáp) `metal-tortoise-scale-armour` | 3 | Physical resist, block, health and its Iron Skin Renewed, which the build already runs |
| Ring | Ring of the Returning Edge (Phong Hồi Giới) `metal-ring-of-returning-edge` | 3 | Physical crit, crit damage; Edge Returns the Breath feeds linh lực from crits |
| Ring | Iron Temper Ring (Thiết Thối Giới) `metal-iron-temper-ring` | 1 | A little Physical crit and Metal buff strength |
| Necklace | Whetstone Jade Pendant (Thạch Mài Ngọc Bội) `metal-whetstone-jade-pendant` | 2 | Linh lực, regeneration, healing; its Keen Edge Aura reserve boosts Metal stacks |
| Extra | Woodsplitter Axe (Phách Mộc Phủ) `metal-woodsplitter-axe` | 2 | Another weapon on the rack: a heavy chop that cashes in Metal stacks (swapped in for Sheathed Edge). TT 25 |
| Extra | Blood-Seasoned Whetstone (Huyết Tẩm Ma Thạch) `metal-blood-seasoned-whetstone` | 4 unique | Health, leech and block for the bleeding rack. TT 15 |

Extra thần thức total: 25 + 15 = **40 of 45**. Two extra slots left empty; the Sword-Nest Flag (TT 20) would pass 45 and its "non-sword arts deal 15 % less" cuts against the rack.

## Before and after

Old = the engine-v2 file run again today (its guide figures of 1.4 s and 3.0 s are out of date: the same file now gives 2.4 s and 5.0 s). Geared = the within-budget layers (see "Budget revision (2026-11-13)"); the over-budget geared run gave 1.5 / 3.2 / 2.4 / 1.5 s.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 2.4 | 3.7 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 5.0 | 5.6 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 2.0 | 2.4 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 1.5 | 1.5 | 0-20-0 | 0-20-0 |

`--without` (geared, typical nguyen_anh+0):

- These two `--without` results were measured before the budget revision (2.0 s, 20-0, no change each) and were not re-run: `--without item:metal-hundred-edge-flying-sword` and `--without eff:Edge Returns the Breath`.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Hundred-Edge Flight art | Quick Metal stack layer, empowered break with a Canon partner | Item sources: event, craft, quest, npc | In the catalogue | High |
| Ring | Edge Returns the Breath | Linh lực on Physical crit | Event, npc | In the catalogue | Medium |
| Extra | Marked Prey (axe) | Reward for Bleed plus Metal stacks | Event, craft, npc | In the catalogue (not run) | Medium |
| Armour | A drain ward above ws 83 | Wall for the layers to stand behind | Craft | Missing as a drain ward; the Tortoise-Scale Shell is a cast ward | Medium |
| Extra | Count-the-weapons Effect | Garrison Mind strikes per equipped weapon | Item or Way | Missing | High |
| Extra | Heal and soul cleanse piece | Re-Temper and Shut the Armoury Door were lost in v2 | Item | Missing | Low |

## Missing pieces

- An Effect that counts equipped weapon-base pieces and hits or walls per piece (the build's own identity); the metal family should own it.
- A Metal armour whose ward is a standing drain ward at the Nascent Soul size; the metal family.
- A metal ring or necklace with a soul-defence modifier to stand in for the Thinned Mind close; the general family.

## UNMODELLED

- Edge Past the Rack (L3 surplus to penetration): no layer-total readable or penetration mod key.
- Thinned Mind close: no engine action to thin soul defence.
- Steady Breath is scoped to Metal arts in the guide; here it lifts L5 for every hit.
- Piece-count reads are fixed numbers (4 weapons, +40, 2 ward pieces): Effects cannot read pieces owned.
- Marked Prey (axe): I did not read its rule, so it is not written as an engine Effect.
- Whetstone Vow and Blood Casting (Blood-Seasoned Whetstone): rules not read, not written.
- Tortoise-Scale Shell: a cast Physical ward (105.3 points), not a drain ward; the build's ward is kept.
- Keen Edge Aura and Whetstone Hum reserve arts: the reserve and grants are not run.
- Item modifiers with no engine stat (khi_huyet_pct, defense_pct, health_regen_inc_pct, linh_luc_pct, stack_effect_pct, stack_duration_pct, art_cost_health_pct); item art_speed_pct scoped to sword, kim or slow applies to every art.
- Iron Skin Renewed on the armour: the build already runs it as `iron-skin-renewed`, so no second copy was written.

## Budget revision (2026-11-13)

What changed in `layers`: `[266, 265, 250, 130, 0]` became `[150, 150, 120, 0, 0]`. The claimed share of the typical-to-top-end gap fell from 75 % to 23 %, which is the nguyen_anh budget.

Why: the techniques' passives and the items' modifiers already run as Effects (`tech:*`, `item:*`), so the old file counted the gear twice by also writing it into `layers`. `layers` now holds only what the Meridian Map and other named sources give: a mid-sized base in the first three layers. The fourth layer (130) was cut first because the concept (many weapons, walls and strikes) needs it least, and the gear already lifts the fifth layer through the `full-rack`, `opened-seams` and `steady-breath` Effects. The Effects, techniques, items and arts are unchanged.

How the fights moved (old over-budget file -> new, mean time and wins of 20):

| Matchup | Old | New |
|---|---|---|
| typical nguyen_anh+0 | 1.5 s, 20 wins | 3.7 s, 20 wins |
| typical hoa_than+1 | 3.2 s, 20 wins | 5.6 s, 20 wins |
| top_end nguyen_anh+0 | 2.4 s, 0 wins | 2.4 s, 0 wins |
| top_end hoa_than+1 | 1.5 s, 0 wins | 1.5 s, 0 wins |

Arts that never fired against a typical same-realm foe before now fire (Sundering Wedge, Splitting Chop, Blood Quench Blade); only Shatter Edge Cleave stays unfired at nguyen_anh.

## Observations

With layers inside the budget the typical fights take 3.7 s at nguyen_anh and 5.6 s one realm up (health left 97 % and 93 %), and the top-end enemy still kills the build in 2.4 s and 1.5 s. Every fight is still far inside the 30–60 s band, and well under the 10–20 s a build at its budget should need against a typical foe; the rest of the gap is the pieces listed under "Missing pieces". Removing the flying sword or Edge Returns the Breath changed nothing at typical nguyen_anh+0, so the speed-up probably comes from the item modifiers and the swapped-in arts together; I did not isolate it further. No item made the build degenerate, as nothing in the fight lasted long enough to compound. The Hundred-Edge Flight art fires (2.0 a fight, 4.0 a fight one realm up) and its `hundred-edge-notch` Effect is clipped about 3 times a fight at typical nguyen_anh+0. Fired nothing at typical nguyen_anh+0: Shatter Edge Cleave only (it fires once a fight one realm up); Edge Returns the Breath fired but changed no outcome; most item modifiers have no engine stat, so much of the gear is unmodelled.
