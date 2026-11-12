# Named items: General

> Generated from `catalogue-general.json` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`
> rules 11, 20, 21 and Formulas I. Budget per grade: 12.8 W per affix the grade allows (lint passes up to ×1.25).

| Item | Base · slot | Grade (rarity) | Gives | Plain W |
|---|---|---|---|---|
| **Wayfarer's Ring (Hành Lữ Giới)** | Nhẫn · ring slot | Hạ (Low) (2) | modifiers only | 12.4 of 12.8 |
| **Pilgrim's Flying Sword (Hành Hương Phi Kiếm)** | Phi Kiếm · weapon slot | Hạ (Low) (2) | art: Wayfarer's Cut | 12.4 of 12.8 |
| **Stitchwind Needles (Phùng Phong Châm)** | Châm · weapon slot | Trung (Middle) (3) | art: Threading Rain; Effect: Echo | 26.4 of 25.6 |
| **Bulwark of the Road (Lộ Trình Thuẫn)** | Thuẫn · extra slot (ward gear) | Trung (Middle) (3) | ward: Bulwark Light | 24.8 of 25.6 |
| **Seeker's Pendant (Tầm Đạo Bội)** | Ngọc Bội · necklace slot | Trung (Middle) (3) | reserve: Seeker's Aura | 20.9 of 25.6 |
| **Hundred-Patch Armour (Bách Nạp Giáp)** | Giáp · armour slot | Thượng (High) (4) | ward: Hundred-Patch Ward; Effect: Final Clause | 38.3 of 38.3 |
| **Five-Phase Flag (Ngũ Hành Kỳ)** | Kỳ · extra slot (utility) | Thượng (High) (4) | Effect: Wheel in the Flag (new) | 35.1 of 38.3 |
| **Talisman-Bearer's Ring (Phù Sứ Giới)** | Nhẫn · ring slot | Thượng (High) (4) | Effect: Paid in Advance | 30.9 of 38.3 |
| **Heaven-Purchasing Coin (Mãi Thiên Tiền)** | Tiền Tiêu · weapon slot | Cực (Peak) (5, unique) | art: Last Coin Flick; Effect: Seal of Full Payment | 44.2 of 51.1 |
| **Mirror of the Second Seat (Nhị Tòa Kính)** | Kính · extra slot (utility) | Cực (Peak) (5, unique) | Effect: Cold Feet | 42.2 of 51.1 |

## Wayfarer's Ring (Hành Lữ Giới)

*Nhẫn (Ring), ring slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting, quest and sect rewards*

> A copper ring worn smooth by travelling cultivators who never stayed long enough to join a sect.

**Build use.** Any build: a little fortune and faster cultivation for the long road before the build comes together.

**Modifiers:** +1 fortune (khí vận) · 5.0 W; +2 % cultivation speed (tu luyện) · 4.4 W; +5 % maximum health (khí huyết) · 3.0 W


## Pilgrim's Flying Sword (Hành Hương Phi Kiếm)

*Phi Kiếm (Flying Sword), weapon slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting, NPC holders*

> The cheap blade sold at every sect gate to disciples sent on their first pilgrimage.

**Build use.** Any build's first weapon: an element-less quick cut that holds a slot until the build's own arts arrive.

**Art: Wayfarer's Cut (Hành Lữ Trảm)** (damage, standalone, c 1.97, cost 0.030, cooldown 2 s). A plain quick Physical cut that carries no element, so it never fights a build's own.

**Modifiers:** +6 % damage [art] · 4.8 W; +6 % art speed · 3.6 W; +4 % maximum linh lực · 4.0 W


## Stitchwind Needles (Phùng Phong Châm)

*Châm (Needle), weapon slot · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> A tailor's needles tempered until they sing; the tailor sewed up wounds and then opened a few.

**Build use.** Quick-art and crit builds: Echo makes each needle volley strike twice, and the desperate throw pays when the fight turns.

**Art: Threading Rain (Xuyên Châm Vũ)** (damage, engine, c 1.60, cost 0.025, cooldown 1.5 s). A cheap, quick Physical volley. With half your health gone it threads a second pass, 1.6 times as hard.

**Effect: Echo** (effects.md). When one of your arts lands a hit, it has a 25 % chance to strike again for free.

**Modifiers:** +10 % art speed [quick] · 4.0 W; +12 % damage [art] · 9.6 W; +3 % crit chance · 3.0 W; +10 % accuracy · 5.0 W; +6 % linh lực regeneration, increased · 4.8 W


## Bulwark of the Road (Lộ Trình Thuẫn)

*Thuẫn (Shield), extra slot (ward gear) · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> A caravan guard's shield dented by a hundred bandit blades and never once pierced.

**Build use.** Art-speed and talisman builds that lean on a cast shield: the Golden Light Shield, stronger and cheaper to keep up.

**Ward: Bulwark Light (Lộ Thuẫn Quang)**: shield σ 0.1125; cast 0.030; cast, cooldown 4 s, up 3 s. Price check from Golden Light Shield (Kim Quang Thuẫn). The starter shield at 1.25 times its shield and its cast cost, so the price check is unchanged (3.750 of 3.813)

**Modifiers:** +8 % ward strength · 8.0 W; +6 % ward efficiency · 6.0 W; +8 % maximum health (khí huyết) · 4.8 W; +10 % status resistance · 4.0 W; +4 % cast ward duration · 2.0 W


## Seeker's Pendant (Tầm Đạo Bội)

*Ngọc Bội (Necklace (jade pendant)), necklace slot · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> Jade from the road to a hidden sect; it grows warm when the right turning is near.

**Build use.** Fortune and escape builds: steady fortune, a surer getaway, and an aura that helps against curses.

**Reserve art: Seeker's Aura (Tầm Đạo Quang)** (reserves 10 % of maximum linh lực). While reserved, you resist statuses better and your escape is likelier.

**Modifiers:** +1 fortune (khí vận) · 5.0 W; +4 % thần thức · 5.2 W; +2 % cultivation speed (tu luyện) · 4.4 W; +2 % evade [escape] · 1.5 W; +6 % linh lực regeneration, increased · 4.8 W


## Hundred-Patch Armour (Bách Nạp Giáp)

*Giáp (Armour), armour slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards, NPC holders*

> Every hole in it was mended with a scrap from a different sect's robe; no single art knows how to read it.

**Build use.** Any build that wants to outlast: the Common Ward made stronger, and Final Clause fires the longest art free as the wearer goes Down.

**Ward: Hundred-Patch Ward (Bách Nạp Hộ Thể)**: all 411 points; drain 0.394; standing. Price check from Common Ward (Hộ Thể Chân Khí). The starter ward at 1.2 times its payload and its drain, so the price check is unchanged (3.049 of 3.050)

**Effect: Final Clause** (effects.md). Once a fight, as you go Down, your longest-cooldown art fires at no cost.

**Modifiers:** +14 % maximum health (khí huyết) · 8.4 W; +10 % ward strength · 10.0 W; +12 % healing taken · 6.0 W; +100 points resistance, all · 4.0 W; +20 % health regeneration, increased · 6.0 W; +3 % thần thức · 3.9 W


## Five-Phase Flag (Ngũ Hành Kỳ)

*Kỳ (Flag), extra slot (utility) · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards*

> A banner with five pennants, one per phase; refined with one material of each element, it is never quite finished.

**Build use.** The Wheel of Generation, The Overcomer, The Primordial Sage: a flag with five element slots, each element held lifting every art.

**Effect (new): Wheel in the Flag (Ngũ Hành Tụ Kỳ)** (Scaling, minor). Your arts deal 5 % more for each element whose buff stacks you hold, up to five elements. *Payload:* damage more, 5 % per element held.

**Modifiers:** +10 % damage [art] · 8.0 W; +12 % stack effect · 6.0 W; +15 % stack duration · 6.0 W; +4 % thần thức · 5.2 W; +6 % maximum linh lực · 6.0 W; +3 % element affinity · 3.9 W


## Talisman-Bearer's Ring (Phù Sứ Giới)

*Nhẫn (Ring), ring slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, NPC holders*

> A silver ring engraved with a talisman-writers' guild seal; the guild pays its debts in paper, and so does the wearer.

**Build use.** Talisman builds: Paid in Advance, so every talisman fires free of linh lực, faster and harder.

**Effect: Paid in Advance** (effects.md). Your talismans cost no linh lực when they fire.

**Modifiers:** +12 % damage [talisman] · 8.0 W; +15 % art speed [talisman] · 6.0 W; +8 % maximum linh lực · 8.0 W; +1 fortune (khí vận) · 5.0 W; +3 % thần thức · 3.9 W


## Heaven-Purchasing Coin (Mãi Thiên Tiền)

*Tiền Tiêu (Coin), weapon slot · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms, quest and sect rewards*

> The first spirit stone ever cut, they say, and the one that bought a sect its mountain.

**Build use.** Spirit-stone builds: Seal of Full Payment pays arts and wards in carried stones, and the coin flies heaviest at the brink.

**Art: Last Coin Flick (Tuyệt Tiền Kích)** (damage, engine, c 2.00, cost 0.030, cooldown 2.5 s). A flicked coin: a quick Physical hit. With 40 % of your health gone it is the last coin in the purse, and flies four times as hard.

**Effect: Seal of Full Payment** (effects.md). Your arts and wards are paid in carried spirit stones.

**Modifiers:** +24 % damage [art] · 19.2 W; +5 % crit chance · 5.0 W; +30 % crit damage · 9.0 W; +10 % art speed · 6.0 W; +1 fortune (khí vận) · 5.0 W

**Placed at world start:** A Nascent Soul merchant-cultivator who deals in spirit stones; otherwise Lost in a buried merchant vault


## Mirror of the Second Seat (Nhị Tòa Kính)

*Kính (Mirror), extra slot (utility) · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms, quest and sect rewards*

> It shows its holder seated twice, once in the hall and once in the heaven above, and lets both hold a treasure.

**Build use.** Every build: one extra artifact slot, plus Cold Feet for the first escape; the classic piece a build hunts for.

**Effect: Cold Feet** (effects.md). Your escape art's first firing comes at cooldown_min.

**Modifiers:** +1 artifact_slots · 25.0 W; +1 fortune (khí vận) · 5.0 W; +6 % thần thức · 7.8 W; +2 % cultivation speed (tu luyện) · 4.4 W

**Placed at world start:** The elder of a sect's treasure hall at Core Formation or above; otherwise Lost in a collapsed sect vault

