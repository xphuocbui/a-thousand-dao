# Giant Killer (Sơn Hạ Châm, The Needle Under the Mountain), geared

A Metal–Earth Kết Đan (Core Formation, `ket_dan`) that tempers Metal arts and stacks Metal debuffs to break them in one heavy cleave; ordinary against equals on paper, a punch-up build in intent.

## Loadout

Build `divine_sense` absent (1.0) and no `than_thuc_pct`, so the extra-slot limit is 45 thần thức (TT).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm) `metal-hundred-edge-flying-sword` | 3 | Its art Hundred-Edge Flight is a Hundred-Blades Canon art (the build's aux technique): a quick hit that lays Metal debuff stacks and breaks them at 6. Replaces flying-blade-retinue in art slot 4. |
| Armour | Tortoise-Scale Armour (Quy Lân Giáp) `metal-tortoise-scale-armour` | 3 | Physical resistance, block, health and regeneration for the body side, plus Iron Skin Renewed (body shield on each Physical art). |
| Ring 1 | Ring of the Returning Edge (Phong Hồi Giới) `metal-ring-of-returning-edge` | 3 | Physical crit chance and damage; Edge Returns the Breath gives linh lực back on each Physical crit, which suits a crit build. |
| Ring 2 | Iron Temper Ring (Thiết Thối Giới) `metal-iron-temper-ring` | 1 | Crit and a Metal buff-stack bonus; the only other Metal ring that was not a unique. |
| Necklace | Whetstone Jade Pendant (Thạch Mài Ngọc Bội) `metal-whetstone-jade-pendant` | 2 | Reserve art Keen Edge Aura (Metal debuff stacks stronger, Metal arts faster); linh lực and regeneration. |
| Extra 1 | Bronze Peal Bell (Đồng Chung Hộ) `metal-bronze-peal-bell` | 2 | Ward gear for boss and heavy-hitter fights. **TT 25.** |
| Extra 2–4 | empty | — | Nothing else in the catalogue served the build without breaking the limit or the concept. |

**Total thần thức: 25 of 45.**

## Before and after

`--matrix`, 20 seeds. Old = `engine-v2` file re-run today; geared = `engine-v3` file.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, same realm (ket_dan+0) | 1.2 | 1.0 | 20-0-0 | 20-0-0 |
| typical, nguyen_anh+1 | 3.3 | 1.9 | 20-0-0 | 20-0-0 |
| typical, hoa_than+2 | 4.0 | 4.4 | 0-20-0 | 17-2-1 |
| top_end, ket_dan+0 | 2.0 | 2.1 | 0-20-0 | 0-20-0 |
| top_end, nguyen_anh+1 | 1.0 | 1.6 | 0-20-0 | 0-20-0 |
| top_end, hoa_than+2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

`--without` (geared file, typical same realm, ket_dan+0):

| Removed | Before | After |
|---|---|---|
| `item:metal-hundred-edge-flying-sword` | 1.0 s, 20-0-0 | 1.0 s, 20-0-0 (NO_CHANGE) |
| `eff:Edge Returns the Breath` | 1.0 s, 20-0-0 | 1.0 s, 20-0-0 (NO_CHANGE) |
| `eff:Iron Skin Renewed` | 1.0 s, 20-0-0 | 1.0 s, 20-0-0 (NO_CHANGE) |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Marked Prey (Blade Thousand-Cut Sword) | More damage per different own status on the target | Unique, blade family | In the catalogue (`blade-thousand-cut-sword`, grade 4 unique); the build lays few distinct statuses | Low |
| Extra | Seal of Full Payment (Heaven-Minted Coin) | Arts paid in stones, Gold Rain art | Unique, metal family; holder a Gold-root elder | In the catalogue (`metal-heaven-minted-coin`); its closing rule is not expressible in the engine | Low |
| Extra | Blood Casting + Whetstone Vow (Blood-Seasoned Whetstone) | Health pays shortfalls at half price, leech | Unique, metal family | In the catalogue (`metal-blood-seasoned-whetstone`); leans toward the Blood on the Whetstone build | Low |
| Ring | Realm-gap crit or damage | Damage that rises against a higher realm | — | Missing | High |
| Any | Physical penetration / realm pierce | Skips resistance at the cap | — | Missing | High |
| Weapon or ring | Stack-break trigger that fires on Metal stack count | The 6-stack cleave actually firing | Metal family | Missing | Medium |

## Missing pieces

- A realm-gap damage ring (the identity "half a realm" piece): the metal family should own it.
- Physical penetration or realm pierce as a modifier or Effect: the metal family (or general).
- An item that raises the Metal stack applied per hit, so a 6-stack break is reached before the fight ends: the metal family.
- A drain-ward armour for Metal: the metal family (the two item wards here are cast wards).

## UNMODELLED

- Half a Realm: no library art, technique or item does it; the engine has no fight-unit shift.
- Against the Heavens: L5 +100 applied at every gap; no realm-gap readable.
- Stiff Neck, Through the Ceiling, Mountain Notches, Needle's Eye, Realm-Piercing affix: not in the game.
- Realm pierce and Physical penetration: no engine field.
- Golden Bell, Soul-Guarding Lamp, Clear Heart Ward: run as the typical Common Ward.
- Tortoise-Scale Shell and Bronze Peal wards: both cast or per-hit wards; the file keeps the typical Common Ward rather than guess whether either beats it.
- Whetstone Jade Pendant reserve art Keen Edge Aura: reserve arts are not run.
- Item plain modifiers the engine has no stat for (khi huyet, defence, health regeneration, linh lực, stack effect, stack duration, buff stack effect): no engine stat. Scoped art-speed modifiers apply to every art.
- Item modifiers were not added to `layers`; the engine's own item loader reads those it can.

## Observations

Gear changed the picture without touching any number: the one-realm-up fight dropped from 3.3 to 1.9 s and the two-realms-up typical foe went from 0-20 to 17-2-1, though fights stay at 1–4.4 s, far under the 30–60 s band. The `--without` tests at the same realm all show NO_CHANGE because the fight ends in 1 s, before the effects matter; the swap of the flying sword shows up at the higher gaps (Hundred-Edge Flight fired 1.0 and 3.1 times per fight at +1 and +2). Edge Returns the Breath and Iron Skin Renewed fired but changed nothing at that gap (Iron Skin Renewed was clipped 2.0 and 7.2 times per fight at +1 and +2). The top-end foe still wins every fight, so no item made the build degenerate against it, but the typical +2 win rate of 17 of 20 is high for a build the guide calls ordinary, and part of it comes from the old file's L5 +100 at every gap, not from the gear. Never fired: shatter-edge-cleave in every matchup, sundering-wedge in most rows, and sheathed-edge and Hundred-Edge Flight at the same realm. The Bronze Peal Bell and the Whetstone Jade Pendant did nothing the engine could show.
