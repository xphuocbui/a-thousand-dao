# Named items: Soul Song Seal

> Generated from `catalogue-soul-song-seal.json` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`
> rules 11, 20, 21 and Formulas I. Budget per grade: 12.8 W per affix the grade allows (lint passes up to ×1.25).

| Item | Base · slot | Grade (rarity) | Gives | Plain W |
|---|---|---|---|---|
| **Rain-Listening Zither (Thính Vũ Cầm)** | Cầm · weapon slot | Hạ (Low) (2) | art: Raindrop Pluck | 10.4 of 12.8 |
| **Quiet Mind Ring (Tĩnh Tâm Giới)** | Nhẫn · ring slot | Hạ (Low) (2) | modifiers only | 11.1 of 12.8 |
| **Muffled Temple Bell (Ám Chung)** | Chuông · extra slot (ward gear) | Trung (Middle) (3) | ward: Muffled Bell Ward | 21.3 of 25.6 |
| **Sandalwood Censer (Đàn Hương Lô)** | Hương Lô · extra slot (utility) | Trung (Middle) (3) | Effect: Marked Prey; reserve: Incense Haze | 21.4 of 25.6 |
| **Waking-Soul Jade (Tỉnh Hồn Bội)** | Ngọc Bội · necklace slot | Trung (Middle) (3) | modifiers only | 20.8 of 25.6 |
| **Ledger Seal (Lục Ấn)** | Ấn · weapon slot | Thượng (High) (4) | art: Ledger Stamp | 31.2 of 38.3 |
| **Mourning Robe (Tang Y)** | Đạo Bào · armour slot | Thượng (High) (4) | ward: Mourning Veil; Effect: Final Clause | 35.0 of 38.3 |
| **Echoing Ring (Hồi Âm Giới)** | Nhẫn · ring slot | Thượng (High) (4) | Effect: Echo | 31.0 of 38.3 |
| **Thousand-String Zither (Thiên Huyền Cầm)** | Cầm · weapon slot | Cực (Peak) (5, unique) | art: Thousand-String Dirge; Effect: Plucked Time (new) | 41.8 of 51.1 |
| **Ninth Vigil Heart-Lamp (Cửu Canh Tâm Đăng)** | Đăng · extra slot (utility) | Cực (Peak) (5, unique) | Effect: Lamp-Lit Reading (new); reserve: Vigil Light | 45.8 of 51.1 |

## Rain-Listening Zither (Thính Vũ Cầm)

*Cầm (Zither), weapon slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting, quest and sect rewards*

> A short zither with a cracked soundboard, played by blind street-singers who listen to rain on roofs.

**Build use.** The Zither Player's first instrument: a cheap, quick soul note that also feeds Tolls to the Tolling Bell Requiem.

**Art: Raindrop Pluck (Vũ Lạc Huyền)** (soul, standalone, c 0.00, cost 0.040, cooldown 3 s). One light note that strikes the foe's soul. Each soul hit you land adds a Toll (once a pulse), so it feeds the Tolling Bell Requiem from any hand.

**Modifiers:** +5 soul attack damage · 4.0 W; +8 % art speed [soul] · 3.8 W; +2 % thần thức · 2.6 W


## Quiet Mind Ring (Tĩnh Tâm Giới)

*Nhẫn (Ring), ring slot · grade Hạ (Low), rarity 2, repeatable · from events and secret realms, crafting*

> A plain jade band that the novice monks of a meditation hall wear to still their thoughts.

**Build use.** Any soul build's early ring: more thần thức and soul damage, and a pool that refills between notes.

**Modifiers:** +3 % thần thức · 3.9 W; +3 soul attack damage · 2.4 W; +6 % linh lực regeneration, increased · 4.8 W


## Muffled Temple Bell (Ám Chung)

*Chuông (Bell), extra slot (ward gear) · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> A temple bell stuffed with felt so that it only hums; it was hung in the halls where soul-singers practised.

**Build use.** Anyone facing soul builds or slow heavy hitters: soul resistance on top of a bell ward.

**Ward: Muffled Bell Ward (Ám Chung Tráo)**: all 120 points; per hit 0.042; standing. Price check from Golden Bell (Kim Chung Tráo). The starter bell at 1.2 times its payload and its per-hit payment, so the price check is unchanged (3.019 of 3.050)

**Modifiers:** +20 % soul resistance · 12.0 W; +5 % ward strength · 5.0 W; +5 % maximum health (khí huyết) · 3.0 W; +1 % thần thức · 1.3 W


## Sandalwood Censer (Đàn Hương Lô)

*Hương Lô (Censer), extra slot (utility) · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> A bronze bowl of sandalwood ash; the smoke seems to cling to whoever is thinking hardest.

**Build use.** The Incense Burner: Marked Prey rewards every different status laid on the foe, and the haze keeps statuses and soul hits stronger for a little linh lực.

**Effect: Marked Prey** (effects.md). Your hits deal more for each different status of yours on the target.

**Reserve art: Incense Haze (Hương Yên Vụ)** (reserves 10 % of maximum linh lực). While reserved, your soul hits are 4 % stronger and your statuses on the foe last 8 % longer.

**Modifiers:** +4 % thần thức · 5.2 W; +8 soul attack damage · 6.4 W; +12 % status duration · 4.8 W; +5 % maximum linh lực · 5.0 W


## Waking-Soul Jade (Tỉnh Hồn Bội)

*Ngọc Bội (Necklace (jade pendant)), necklace slot · grade Trung (Middle), rarity 3, repeatable · from events and secret realms, crafting, NPC holders*

> Pale jade that warms when its wearer is sung to; sect healers lend it to patients who cannot wake.

**Build use.** The Zither Player and anyone who plays Thorn Lullaby: more healing taken in, which the Lullaby's thorns turn into soul strikes.

**Modifiers:** +10 % healing · 5.0 W; +6 soul attack damage · 4.8 W; +20 % health regeneration, increased · 6.0 W; +8 % art speed [soul] · 3.8 W; +2 % maximum health (khí huyết) · 1.2 W


## Ledger Seal (Lục Ấn)

*Ấn (Seal), weapon slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards, NPC holders*

> The magistrate's seal of a vanished dynasty's ledger-hall, where every debt of the dead was stamped.

**Build use.** The Ledger Keeper (Nine Seal Ledger builds): a fourth seal art the suite's Seal counter and Snare, Hour and Brand all count, and it gets the Slackened Soul the Bell canon lays.

**Art: Ledger Stamp (Lục Ấn Áp)** (control, engine, c 2.40, cost 0.050, cooldown 5 s). Counts as a Nine Seal Ledger art. A slow, heavy seal stamp that adds a Seal. With 2 Seals and either an Exposed foe, a Slackened Soul foe, or another ledger seal fired the same pulse, the stamp is entered in the ledger: 2.8 times as hard, it spends 2 Seals and exposes the foe.

**Modifiers:** +18 % damage [seal] · 12.0 W; +10 % art speed [seal] · 4.0 W; +6 soul attack damage · 4.8 W; +12 % status duration · 4.8 W; +2 % thần thức · 2.6 W; +3 % maximum linh lực · 3.0 W


## Mourning Robe (Tang Y)

*Đạo Bào (Robe), armour slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, crafting, quest and sect rewards, NPC holders*

> White hemp worn by the singers who mourned for a living; it turns aside sound and the blows that carry it.

**Build use.** The Zither Player and Bell canon builds: Final Clause fires the longest-cooldown art free as you go Down, often a Death Knell, and the veil covers Force.

**Ward: Mourning Veil (Tang Sa)**: Force 275 points; drain 0.33; standing. Price check from Qi-Scattering Robe (Tán Khí Bào). The starter robe at 1.25 times its payload and its drain, so the price check is unchanged (3.788 of 3.813)

**Effect: Final Clause** (effects.md). Once a fight, as you go Down, your longest-cooldown art fires at no cost.

**Modifiers:** +30 % soul resistance · 18.0 W; +8 % maximum health (khí huyết) · 4.8 W; +4 % thần thức · 5.2 W; +5 % linh lực regeneration, increased · 4.0 W; +6 % healing taken · 3.0 W


## Echoing Ring (Hồi Âm Giới)

*Nhẫn (Ring), ring slot · grade Thượng (High), rarity 4, repeatable · from events and secret realms, NPC holders*

> A silver ring hollow as a flute; a note struck near it comes back a breath later.

**Build use.** Soul-note builds: Echo makes a quarter of every soul hit strike again, and each strike adds a Toll.

**Effect: Echo** (effects.md). When one of your arts lands a hit, it has a 25 % chance to strike again for free.

**Modifiers:** +12 soul attack damage · 9.6 W; +12 % art speed [soul] · 5.8 W; +4 % thần thức · 5.2 W; +8 % linh lực regeneration, increased · 6.4 W; +10 % status duration · 4.0 W


## Thousand-String Zither (Thiên Huyền Cầm)

*Cầm (Zither), weapon slot · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms*

> A zither of a thousand strings that was played by a court musician until the court listened to nothing else.

**Build use.** The Zither Player's keystone: every song art delays the foe, and the Dirge turns each fed chord into a Bell Peal's worth of soul strikes, at the price of weaker non-song arts.

**Art: Thousand-String Dirge (Thiên Huyền Điếu)** (soul, engine, c 0.00, cost 0.050, cooldown 3 s). Counts as a Hollow Bell Canon art. A soul strike on the foe. Every song art you fire adds a Chord. With 3 Chords and either a Slackened Soul foe or another canon art fired the same pulse, the strings answer in chorus: a heavy extra soul strike that spends 3 Chords and adds 2 Tolls to the Bell. The next, with 6 Chords and either 2 Slackened Soul on the foe or you at 40 % health or less, spends 6 Chords for another and slackens the foe's soul.

**Effect (new): Plucked Time (Huyền Trì)** (Enablers, enabler). When one of your song arts lands a soul hit, the enemy's next ready art is delayed by 0.4 s, at most once a second. *Payload:* Delay of the enemy's next ready art. *Closes:* Your arts that are neither soul nor song deal 15 % less.

**Modifiers:** +14 soul attack damage · 11.2 W; +12 % art speed [soul] · 5.8 W; +6 % thần thức · 7.8 W; +8 % maximum linh lực · 8.0 W; +10 % healing · 5.0 W; +10 % status duration · 4.0 W

**Placed at world start:** An elder of a Soul sect at Nascent Soul or above; otherwise Lost under the silted lake of a drowned music hall


## Ninth Vigil Heart-Lamp (Cửu Canh Tâm Đăng)

*Đăng (Lantern), extra slot (utility) · grade Cực (Peak), rarity 5, **unique** · from NPC holders, events and secret realms, quest and sect rewards*

> Nine monks kept this lamp alight through nine night-watches, and each one was found sitting before it, smiling.

**Build use.** Soul builds against high soul resistance (their stated weakness): Lamp-Lit Reading strips the foe's resistance for every status laid, and the vigil light covers the wearer's own.

**Effect (new): Lamp-Lit Reading (Đăng Chiếu)** (Enablers, enabler). Each different status of yours on the target lowers its soul resistance by 3 points, to at most 5 statuses. *Payload:* Soul resistance reduction on the target. *Closes:* Your own soul resistance is 15 points lower.

**Reserve art: Vigil Light (Thủ Canh Quang)** (reserves 15 % of maximum linh lực). While reserved, your soul resistance is 15 points higher and your thần thức 3 % higher.

**Modifiers:** +10 soul attack damage · 8.0 W; +30 % soul resistance · 18.0 W; +6 % thần thức · 7.8 W; +10 % linh lực regeneration, increased · 8.0 W; +10 % status duration · 4.0 W

**Placed at world start:** The abbot of a Soul sect's mountain temple; otherwise Lost in a collapsed meditation cave

