# Named items: Ice

> Generated from `catalogue-ice.json` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`
> rules 11, 20, 21 and Formulas I. Budget per grade: 12.8 W per affix the grade allows (lint passes up to ×1.25).

| Item | Base · slot | Grade (rarity) | Gives | Plain W |
|---|---|---|---|---|
| **Hoarfrost Needle (Sương Châm)** | Châm · weapon slot | Hạ (Low) (2) | art: Hoarfrost Prick | 11.8 of 12.8 |
| **Rimed Band (Sương Giới)** | Nhẫn · ring slot | Hạ (Low) (2) | modifiers only | 10.8 of 12.8 |
| **Hoarfrost Fan (Sương Phiến)** | Phiến · weapon slot | Trung (Middle) (3) | art: Frost-Tithe Gust; Effect: Rime Lock | 21.3 of 25.6 |
| **Sleeping Marrow Pendant (Miên Tủy Bội)** | Ngọc Bội · necklace slot | Trung (Middle) (3) | reserve: Winter Sleep Aura | 22.6 of 25.6 |
| **Hoarfrost Tide Shield (Sương Triều Thuẫn)** | Thuẫn · extra slot (ward gear) | Trung (Middle) (3) | ward: Hoarfrost Tide | 24.6 of 25.6 |
| **Winter Toll Seal (Đông Toán Ấn)** | Ấn · weapon slot | Thượng (High) (4) | art: Toll Stamp | 35.4 of 38.3 |
| **Glacier Plate (Băng Xuyên Giáp)** | Giáp · armour slot | Thượng (High) (4) | ward: Glacier Shell; Effect: Shattering Ward | 35.5 of 38.3 |
| **Black Ledger Mirror (Huyền Trướng Kính)** | Kính · extra slot (utility) | Thượng (High) (4) | Effect: Toll Taker (new); reserve: Cold Ledger Aura | 34.0 of 38.3 |
| **Deep Freeze Ring (Thâm Đống Giới)** | Nhẫn · ring slot | Cực (Peak) (5, unique) | Effect: Deep Freeze (new) | 45.0 of 51.1 |
| **Moonrime Flying Sword (Nguyệt Sương Phi Kiếm)** | Phi Kiếm · weapon slot | Cực (Peak) (5, unique) | art: Moon Stills the Tide | 45.1 of 51.1 |

## Hoarfrost Needle (Sương Châm)

*Châm (Needle), weapon slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting, quest and sect rewards*

> A silver needle that never loses its frost; acupuncturists of the northern sects use it to numb.

**Build use.** The Frozen Treasury's first weapon: a fast, cheap Ice-stack source, so the foe's art costs begin to climb at once.

**Art: Hoarfrost Prick (Sương Châm Thích)** (damage, standalone, c 1.40, cost 0.020, cooldown 1.5 s). A needle of frost: a quick Cold hit that lays 1 Ice stack for 8 s.

**Modifiers:** +10 % damage [cold] · 6.7 W; +8 % art speed [cold] · 3.2 W; +12 % stack duration [bang, debuff] · 1.9 W


## Rimed Band (Sương Giới)

*Nhẫn (Ring), ring slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting*

> A ring of pale jade that is always coated with a thin rime.

**Build use.** The Frozen Treasury and The Frost Lock: each Ice stack bites harder, and a little health and linh lực flow for the early fights.

**Modifiers:** +20 % stack effect [bang, debuff] · 4.0 W; +6 % maximum health (khí huyết) · 3.6 W; +4 % linh lực regeneration, increased · 3.2 W


## Hoarfrost Fan (Sương Phiến)

*Phiến (Fan), weapon slot · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> Cranes' feathers frozen in a spring of the northern peaks, then bound to a bamboo frame.

**Build use.** The Frozen Treasury: a fast stacker whose gust turns a pile of Ice into a delay, and Rime Lock stalls the foe's best art at 10 stacks.

**Art: Frost-Tithe Gust (Sương Thuế Phong)** (damage, engine, c 1.65, cost 0.030, cooldown 3 s). A cold gust that lays 2 Ice stacks for 8 s. With 8 Ice stacks on the foe it eats 4 of them, hits twice as hard and delays the foe's slowest art by 0.5 s.

**Effect: Rime Lock** (effects.md). When your Ice stacks on a target reach 10, that target's art with the least time left is delayed by 1 s.

**Modifiers:** +14 % damage [cold] · 9.3 W; +10 % art speed [cold] · 4.0 W; +25 % stack duration [bang, debuff] · 4.0 W; +20 % stack effect [bang, debuff] · 4.0 W


## Sleeping Marrow Pendant (Miên Tủy Bội)

*Ngọc Bội (Necklace (jade pendant)), necklace slot · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> Blue-white jade that holds a thread of the cold that stills a hibernating beast's blood.

**Build use.** The Ice Physician: pills that would poison anyone else sit easy in the blood, and the pendant turns the extra healing into a steady mend.

**Reserve art: Winter Sleep Aura (Đông Miên Quang)** (reserves 10 % of maximum linh lực). While reserved, healing taken is 10 % higher and health regeneration is 15 % increased.

**Modifiers:** +10 % pill toxicity resistance (đan độc) · 16.0 W; +6 % healing · 3.0 W; +6 % maximum health (khí huyết) · 3.6 W


## Hoarfrost Tide Shield (Sương Triều Thuẫn)

*Thuẫn (Shield), extra slot (ward gear) · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> A round shield of blue ice that sweats cold water; the blows run off it like a tide.

**Build use.** The Frozen Treasury and The Ice Physician: a light ward for slow fights where the foe's few heavy hits matter and linh lực is kept for arts.

**Ward: Hoarfrost Tide (Sương Triều Tráo)**: all 75 points; per hit 0.03375; standing. Price check from Surging Tide (Triều Thủy Tráo). The starter ward at 1.25 times its payload and its per-hit payment, so the price check is unchanged (2.935 of 3.050)

**Modifiers:** +10 % ward strength · 10.0 W; +6 % maximum health (khí huyết) · 3.6 W; +5 % ward efficiency · 5.0 W; +10 % status resistance · 4.0 W; +4 % healing · 2.0 W


## Winter Toll Seal (Đông Toán Ấn)

*Ấn (Seal), weapon slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards*

> The seal the toll-keepers of the Winter Toll lineage stamped on every pass that crossed their frozen river.

**Build use.** The Frozen Treasury and The Frost Lock with the Winter Toll Canon: another canon art that builds the shared Frost, so Shatter Palm and the thaw break fire sooner.

**Art: Toll Stamp (Toán Ấn Áp)** (damage, engine, c 2.20, cost 0.050, cooldown 6 s). Counts as a Winter Toll Canon art. A slow cold seal that lays 3 Ice stacks for 8 s and adds a Frost. With 10 Ice stacks on the foe, and either 2 Frost or another Winter Toll art fired in the last 3 s, it eats 5 stacks and 2 Frost and falls two and a half times as hard.

**Modifiers:** +16 % damage [cold] · 10.7 W; +10 % art speed [cold] · 4.0 W; +30 % stack duration [bang, debuff] · 4.8 W; +12 % maximum linh lực · 12.0 W; +3 % thần thức · 3.9 W


## Glacier Plate (Băng Xuyên Giáp)

*Giáp (Armour), armour slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards*

> Plates cut from a glacier's heart and sewn onto hide; they crack loudly, and the crack hurts.

**Build use.** The Shattering Mantle builds of the Stilled Hour Sutra: every shield that breaks bursts against the foe, and the ward comes back every 4 s.

**Ward: Glacier Shell (Băng Xuyên Xác)**: shield σ 0.126; cast 0.0336; cast, cooldown 4 s, up 3 s. Price check from Golden Light Shield (Kim Quang Thuẫn). The starter shield at 1.4 times its shield and its cast cost, so the price check is unchanged (3.750 of 3.813)

**Effect: Shattering Ward** (effects.md). When one of your shields breaks, it bursts against the enemy.

**Modifiers:** +12 % ward strength · 12.0 W; +12 % maximum health (khí huyết) · 7.2 W; +20 % status resistance · 8.0 W; +10 % body shield · 5.1 W; +120 points resistance, all [cold] · 3.2 W


## Black Ledger Mirror (Huyền Trướng Kính)

*Kính (Mirror), extra slot (utility) · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, NPC holders*

> A mirror of black ice in which a moneylender's ledger can be read backwards; whoever is reflected pays more.

**Build use.** The Frozen Treasury: the foe's inflated costs also refill the cultivator, so a long fight against an expensive foe feeds the Ice build.

**Effect (new): Toll Taker (Thu Thuế Giả)** (Trigger, minor). When the enemy pays art cost that your Ice stacks added, you restore linh lực equal to 10 % of that extra cost. *Payload:* Linh lực restored to you.

**Reserve art: Cold Ledger Aura (Hàn Trướng Quang)** (reserves 15 % of maximum linh lực). While reserved, your Ice debuff stacks last 25 % longer.

**Modifiers:** +35 % stack duration [bang, debuff] · 5.6 W; +30 % stack effect [bang, debuff] · 6.0 W; +12 % art speed [cold] · 4.8 W; +12 % linh lực regeneration, increased · 9.6 W; +8 % maximum linh lực · 8.0 W


## Deep Freeze Ring (Thâm Đống Giới)

*Nhẫn (Ring), ring slot · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms, quest and sect rewards*

> A band of ice that has not thawed since the first winter, and in whose depth every year of cold can be seen.

**Build use.** The Frost Lock's keystone piece: Rime Lock stops being a one-time delay and becomes a lock at every 10 stacks, so the foe's slowest art never lands.

**Effect (new): Deep Freeze (Thâm Đống)** (Enablers, enabler). Each time your Ice stacks on a target cross a multiple of 10, that target's art with the least time left is delayed by 1 s, once every 2 pulses. *Payload:* A 1 s delay on the target's art with the least time left. *Closes:* Your arts cost 10 % more linh lực.

**Modifiers:** +1 stacks per grant [bang, debuff] · 4.0 W; +12 % art speed [cold] · 4.8 W; +25 % stack duration [bang, debuff] · 4.0 W; +18 % damage [bang] · 9.0 W; +15 % linh lực regeneration, increased · 12.0 W; +10 % maximum health (khí huyết) · 6.0 W; +4 % thần thức · 5.2 W

**Placed at world start:** A Nascent Soul Ice cultivator of a northern sect; otherwise Lost under a frozen lake


## Moonrime Flying Sword (Nguyệt Sương Phi Kiếm)

*Phi Kiếm (Flying Sword), weapon slot · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms*

> A sword forged on the longest night of a winter that lasted three years, so that its light is the moon's.

**Build use.** The Frost Lock with the Stilled Hour Sutra: a sutra sword that stops time for a whole pulse when Volley and Instant have set the table.

**Art: Moon Stills the Tide (Nguyệt Đình Triều)** (damage, engine, c 1.10, cost 0.040, cooldown 5 s). Counts as a Stilled Hour Sutra art. A cold sword stroke that lays 2 Ice stacks for 8 s and 1 Slowed Time. With 10 Ice stacks on the foe, and either 2 Slowed Time or two Sutra arts fired this pulse, the moon stills the tide: it eats 6 stacks, hits three and a half times as hard, delays the foe's slowest art by 0.5 s and lays a further Slowed Time for 5 s.

**Modifiers:** +22 % damage [cold] · 14.7 W; +14 % art speed [cold] · 5.6 W; +30 % stack duration [bang, debuff] · 4.8 W; +10 % realm pierce · 10.0 W; +10 % maximum linh lực · 10.0 W

**Placed at world start:** An elder of a northern sword sect at Core Formation or above; otherwise Lost in a snow-buried sword tomb

