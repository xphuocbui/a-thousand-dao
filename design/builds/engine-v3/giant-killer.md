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

## Fight results

`--matrix`, 20 seeds, file with layers `[200, 70, 54, 20, 10]` (budget revision below). The earlier over-budget numbers (layers `[200, 225, 250, 130, 100]`) are kept in the revision section.

| Matchup | Mean s | W-L-other |
|---|---|---|
| typical, same realm (ket_dan+0) | 3.2 | 20-0-0 |
| typical, nguyen_anh+1 | 5.8 | 20-0-0 |
| typical, hoa_than+2 | 8.1 | 0-20-0 |
| top_end, ket_dan+0 | 2.9 | 0-20-0 |
| top_end, nguyen_anh+1 | 1.4 | 0-20-0 |
| top_end, hoa_than+2 | 1.0 | 0-20-0 |

The `--without` tests of the old file (all NO_CHANGE, fights ended in 1 s) were not re-run; the fights are now long enough to see them, so they are worth repeating.

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
- Against the Heavens: the old file applied L5 100 at every gap; the budget revision cut L5 to 10, so the piece is now only a note.
- Stiff Neck, Through the Ceiling, Mountain Notches, Needle's Eye, Realm-Piercing affix: not in the game.
- Realm pierce and Physical penetration: no engine field.
- Golden Bell, Soul-Guarding Lamp, Clear Heart Ward: run as the typical Common Ward.
- Tortoise-Scale Shell and Bronze Peal wards: both cast or per-hit wards; the file keeps the typical Common Ward rather than guess whether either beats it.
- Whetstone Jade Pendant reserve art Keen Edge Aura: reserve arts are not run.
- Item plain modifiers the engine has no stat for (khi huyet, defence, health regeneration, linh lực, stack effect, stack duration, buff stack effect): no engine stat. Scoped art-speed modifiers apply to every art.
- Item modifiers were not added to `layers`; the engine's own item loader reads those it can.

## Budget revision (2026-11-13)

Rule: `layers` may claim at most 17 % at `ket_dan` of the gap between the typical and top-end enemy's layers (summed over L1-L5). The file claimed 88 %, so `OVER_BUDGET`.

**What changed in `layers`:** `[200, 225, 250, 130, 100]` -> `[200, 70, 54, 20, 10]` (claim now 17 %). L5 and L4 were cut to the typical enemy's own values (10 and 20) because the "Against the Heavens" piece is unmodelled and a punch-up identity needs the realm-gap piece the engine lacks anyway. L1 (200, the attack side a crit cleave needs most) was kept whole. The 46 points of the gap left over went to L2 (+30, 70) and L3 (+14, 54).

**Why:** the build's own techniques and items already run as Effects, so they were double counted by the large L2-L4 claims; `layers` should hold only what the Meridian Map and other named sources give, and this file names none beyond the old assumed numbers.

**How the fights moved (old -> new, mean time and wins, 20 seeds):**

| Matchup | Old | New |
|---|---|---|
| typical, ket_dan+0 | 1.0 s, 20 wins | 3.2 s, 20 wins |
| typical, nguyen_anh+1 | 1.9 s, 20 wins | 5.8 s, 20 wins |
| typical, hoa_than+2 | 4.4 s, 17 wins | 8.1 s, 0 wins |
| top_end, ket_dan+0 | 2.1 s, 0 wins | 2.9 s, 0 wins |
| top_end, nguyen_anh+1 | 1.6 s, 0 wins | 1.4 s, 0 wins |
| top_end, hoa_than+2 | 1.0 s, 0 wins | 1.0 s, 0 wins |

The same-realm typical fight is still 3.2 s, shorter than the 10-20 s the budget aims for; the pieces (crit 0.5 x2, art speed +50 %) carry it, not `layers`. Nothing else was changed.

## Observations (before the revision)

Gear changed the picture without touching any number: the one-realm-up fight dropped from 3.3 to 1.9 s and the two-realms-up typical foe went from 0-20 to 17-2-1, though fights stay at 1–4.4 s, far under the 30–60 s band. The `--without` tests at the same realm all show NO_CHANGE because the fight ends in 1 s, before the effects matter; the swap of the flying sword shows up at the higher gaps (Hundred-Edge Flight fired 1.0 and 3.1 times per fight at +1 and +2). Edge Returns the Breath and Iron Skin Renewed fired but changed nothing at that gap (Iron Skin Renewed was clipped 2.0 and 7.2 times per fight at +1 and +2). The top-end foe still wins every fight, so no item made the build degenerate against it, but the typical +2 win rate of 17 of 20 is high for a build the guide calls ordinary, and part of it comes from the old file's L5 +100 at every gap, not from the gear. Never fired: shatter-edge-cleave in every matchup, sundering-wedge in most rows, and sheathed-edge and Hundred-Edge Flight at the same realm. The Bronze Peal Bell and the Whetstone Jade Pendant did nothing the engine could show.
