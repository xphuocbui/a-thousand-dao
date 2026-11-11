# Art Library, Part B: Water, Ice, Wood, and Heal / Ward Roles

45 arts in `part-b.json` (16 common, 29 authored). `python -I tools/design/arts/lint_arts.py design/arts/part-b.json`: 0 findings.
Scaling is limitless; no art states a cap. Several guard thresholds and shield sizes are first guesses for the sim to tune.

## Water (Thủy): sustains

| Art | Role | Tier | What it does |
|---|---|---|---|
| Still Water Palm (Tĩnh Thủy Chưởng) | damage | common | A plain water palm strike. |
| Tide Pulse (Triều Xung) | stacks | common | Hits, gives you 3 Water stacks for 12 s. |
| Underground Spring (Ám Tuyền) | stacks | common | Hits, gives you 6 Water stacks for 10 s (the Water twin of Spring Sap). |
| Drawing Breath (Hấp Triều) | utility | common | Restores 7 % linh lực and gives 2 Water stacks for 15 s. |
| Still Pool Mending (Tĩnh Trì Hồi Khí) | heal | common | Heals at 90 % health or less, gives 3 Water stacks for 14 s. |
| Spring at the Well's Mouth (Tỉnh Khẩu Tuyền) | heal | authored | Heals at 70 % health or less and refunds its cost. |
| Ebb and Flow (Triều Tịch) | utility | authored | Heals a little; each time you are healed you gain 2 Water stacks (once a pulse). Healing feeds Water, Water feeds healing. |
| Water Curtain (Thủy Liêm Chướng) | ward | authored | Body shield of 12 % health, 3 Water stacks for 12 s. |
| Drowning Palm (Nịch Thủy Chưởng) | control | authored | Force palm, Qi Disruption x3; only while the foe's pool has water. |
| Lamp-Threading Needle (Xuyên Đăng Châm) | soul | authored | Soul hit that applies Slackened Soul x2. |
| Ninth-Weight Lance (Cửu Quân Thương) | soul | authored | The heaviest soul hit, 6.4 % of the soul bar. |

## Ice (Băng): locks costs

| Art | Role | Tier | What it does |
|---|---|---|---|
| Rime Needle (Sương Châm) | stacks | common | Quick cold hit, 8 Ice stacks for 5 s. |
| Frost Seal (Sương Ấn) | damage | common | Heavy cold seal strike. |
| Rime Brand (Băng Ấn) | stacks | common | Hit, 4 Ice stacks for 10 s. |
| Cold Ledger (Hàn Trướng) | stacks | common | No damage, 3 Ice stacks for 12 s. |
| Leaking Seal (Lậu Ấn) | curse | authored | Hit + Leaking Ward (drain wards bill +50 %); only while the foe's pool has water. |
| Undertow (Ám Lưu) | damage | authored | Waits until the foe's linh lực is dry (5 % or less), then strikes. |
| Frostbound Toll (Hàn Toán Tỏa) | utility | authored | Hit; at 20 or more Ice stacks on the foe it also lays Heavy Breath. The cost lock made literal. |
| Rime Mantle (Sương Giáp) | ward | authored | 12 % health shield; each hit taken lays 1 Ice stack on the attacker. |

## Wood (Mộc): heals and poisons

| Art | Role | Tier | What it does |
|---|---|---|---|
| Rot Seed (Hủ Chủng) | stacks | common | Quick hit, 4 Poison stacks for 10 s (thin, long batches). |
| Slow Rot (Hủ Hoa) | stacks | common | Hit, 2 Poison stacks for 20 s. |
| Venom Tithe (Độc Thuế) | stacks | common | Hit, 3 Poison stacks for 13 s, restores 2 % linh lực. |
| Vine Lash (Đằng Tiên) | damage | common | Plain wood whip strike. |
| Spring Sap (Xuân Dịch) | stacks | common | Hit, 6 Wood stacks for 10 s (health regeneration). |
| Weeping Sap (Khấp Dịch) | heal | common | Heals at 90 % health or less, 3 Wood stacks for 14 s. |
| Banyan Shade (Dung Âm) | heal | authored | Heals at 95 % or less and refunds its cost; overheal feeds Surplus Life. |
| Green Poultice (Thanh Cao) | heal | authored | Heals at 70 % or less, refunds cost, cleanses 1 debuff. |
| Shedding Bark (Thoát Bì) | ward | authored | While Stagnation is on you, cleanses 2 debuffs. |
| Withering Touch (Khô Thủ) | curse | authored | Hit, Withering (healing taken -50 %), 1 Poison stack for 12 s. |
| Venom-Drinking Root (Hấp Độc Căn) | utility | authored | Hit, 2 Poison stacks; each chaos tick you deal heals you 0.4 % of health (once a pulse). |
| Heartwood Spear (Tâm Mộc Thương) | damage | authored | Heavy spear; an extra chaos hit per 10 Poison stacks on the foe. |
| Bark Mantle (Bì Giáp) | ward | authored | 15 % health shield, 3 Wood stacks for 10 s. |

## Heal and ward roles of other elements

| Art | Role | Tier | What it does |
|---|---|---|---|
| Mending Breath (Hồi Khí Tức), Earth | heal | authored | Heals at 60 % or less, refunds cost. |
| Packed Earth Stance (Hậu Thổ Trụ Thế), Earth | ward | common | 4 Earth stacks for 15 s, no damage. |
| Stone-Skin Seal (Thạch Bì Ấn), Earth | ward | authored | 15 % health shield, 3 Earth stacks for 12 s. |
| Re-Temper (Hồi Tôi), Metal | heal | authored | Heals at 70 % or less, refunds cost, +10 L5 for 3 s. |
| Quench (Tôi Thiết), Metal | ward | authored | While Sealed Meridian is on you, cleanses 2 debuffs. |
| Lustral Bell (Tẩy Chung), Metal | ward | authored | Cleanses 3 of your debuffs, strips 10 foe stacks. |
| Hearth Mending (Noãn Dưỡng), Fire | heal | authored | Heals at 75 % or less; each heal gives 3 Fire stacks. |
| Cinder Cloak (Tẫn Y), Fire | ward | authored | 10 % health shield; hits taken lay Burn on the attacker. |
| Static Veil (Điện Mạc), Thunder | ward | authored | 10 % health shield; hits taken lay Thunder stacks on the attacker. |
| Gale Veil (Phong Mạc), Wind | ward | authored | 3 Wind stacks, +10 evade for 6 s. |
| Sweeping the Floor (Tảo Trường), Wind | ward | authored | While Silenced, cleanses 2 debuffs; carries no wind tag. |
| Bell of Waking (Tỉnh Hồn Chung), element-less | ward | authored | While Slackened Soul is on you, cleanses 2 debuffs. |
| Ash of the Effigy (Hình Nhân Tro), element-less | ward | authored | While Sealed Meridian is on you, cleanses 3 debuffs. |

## Merged staged ids

- hollow-palm, deep-well-seal -> still-water-palm
- still-pool-mending, still-tide -> still-pool-mending
- well-mouth-spring, lamp-light -> well-mouth-spring
- mountain-splitting-thought, heart-lamp-lance -> ninth-weight-lance
- undertow, dry-riverbed -> undertow
- rot-seed, green-censer, thorn-seed -> rot-seed (4 for 10 s is the most a stack batch may charge)
- rot-bloom -> slow-rot
- charcoal-poultice, paper-money-burning -> green-poultice
- clean-the-page -> shedding-bark; tan-phong -> sweeping-the-floor
- warm-stone -> mending-breath
- bearing-the-mountain -> packed-earth-stance (4 for 15 s)
- shut-the-armoury-door -> bell-of-waking

Not taken here (other element parts): thunder-needle, far-flash (Thunder); ember-rain, red-censer and the other Fire arts.
Staged arts left out as builds, not hooks: ember-brand and the other `-brand` arts except rime-brand, whistle-in, rouse, old-tree-sap, moss-fang-bite, bark-mantle's companion form, offering-cut, open-the-mirror, thorn-chorus, house-takes-all, deaf-verdict, silent-tally and the escape arts (lantern-out, paper-boat-crossing, homeward-step, sweepers-exit, lightning-step).

## Gaps filled

Water: plain damage, sustain identity (Ebb and Flow), ward (Water Curtain). Ice: plain damage (Frost Seal), cost-lock identity (Frostbound Toll), ward (Rime Mantle). Wood: plain damage, curse (Withering Touch), identity (Venom-Drinking Root), signature damage (Heartwood Spear), ward. Fire heal and ward, Thunder ward, Wind ward, Earth ward.

## Could not express in the schema

- **Numbers lowered to the lint:** staged Poison batches (10 for 14 s, 24 for 20 s, 16 for 24 s) and Earth 8 for 16 s are 2-4 times the 0.6 stack charge; I cut them. Leaking Seal's c_art is 1.08 (was 1.9) because Leaking Ward charges 0.15 a pulse.
- **Cost refund:** written as a `refund` action on `heal_restored`. I did not check that the engine passes the art's cost into that event, so the refund may do nothing until it does.
- **Tag filters:** every shield, refund and bonus Effect filters on a tag unique to its art. I did not check that the engine reads `filter.tags` on `art_fired` and `heal_restored`.
- **Soul arts:** soul_pct is capped by the lint at 0.0125 x lint, so Ninth-Weight Lance is 0.0643, not 0.0644.
- **Cleanse arts:** `cleanse` removes element debuff batches. The `curse`, `soul` and `seal` cleanse tags have no field, and a guard allows one condition, so "Slackened Soul or Silence" became one status each.
- **Conversions:** Dry Riverbed's 60 % Cold / 40 % Physical split and Iron Spark's conversion are not expressible; Dry Riverbed merged into Undertow without the Physical part.
- **Companions and summons:** Whistle In, Bark Mantle's companion shield, Old-Tree Sap, Rouse and Moss-Fang Bite need companion targets and a Down state. No `summon` art exists in this part.
- **Escape arts:** the engine does not model escape.
- **Lustral Bell's** 1.5 s telegraph is dropped.
- **Shields** are a flat share of health fired from `art_fired`; the ward-strength scaling of Combat Defence & Healing is not applied.
