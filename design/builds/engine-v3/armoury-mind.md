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

Old = the engine-v2 file run again today (its guide figures of 1.4 s and 3.0 s are out of date: the same file now gives 2.4 s and 5.0 s).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 2.4 | 2.0 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 5.0 | 4.0 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 1.5 | 1.5 | 0-20-0 | 0-20-0 |

`--without` (geared, typical nguyen_anh+0):

- `--without item:metal-hundred-edge-flying-sword` (the item I judged most important): 2.0 s, 20-0, health 100 %. No change at all (dry foe 1.8 against 1.7).
- `--without eff:Edge Returns the Breath`: 2.0 s, 20-0, health 100 %. No change.

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

## Observations

Gear made the typical fights a fifth faster (2.4 to 2.0 s at nguyen_anh, 5.0 to 4.0 s one realm up) with no loss of health, but the top-end enemy still kills the build in 2.0 s and 1.5 s, unchanged. Every fight is far inside 3 to 5 seconds, nowhere near the 30–60 s band. Removing the flying sword or Edge Returns the Breath changed nothing at typical nguyen_anh+0, so the speed-up probably comes from the item modifiers and the swapped-in arts together; I did not isolate it further. No item made the build degenerate, as nothing in the fight lasted long enough to compound. The Hundred-Edge Flight art fires (1.0 a fight, 2.0 a fight one realm up) and its `hundred-edge-notch` Effect is clipped 5.8 times a fight. Fired nothing: Splitting Chop, Shatter Edge Cleave, Sundering Wedge and Blood Quench Blade at typical nguyen_anh+0 (Splitting Chop stayed unfired at every matchup); Edge Returns the Breath fired but changed no outcome; most item modifiers have no engine stat, so much of the gear is unmodelled.
