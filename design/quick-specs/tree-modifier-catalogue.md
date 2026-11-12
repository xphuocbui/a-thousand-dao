# Tree Modifier Catalogue

> **Status**: Idea bank, 2026-11-06. Nothing here is committed, priced or balanced.
> **Purpose**: A list of candidate modifiers for the skill tree rework, which happens once all systems are implemented (Combat Open Question 22).
> **Scope**: Combat first. Cultivation, crafting and travel keys already exist in Character Stats and are not repeated here.

**Legend.** ● the stat key or capability already exists. ◐ designed in the Combat GDD, not yet in Character Stats. ○ a new idea that needs a key or a rule.

## Node modifiers

The everyday tree nodes: one stat and one number. Values are sized to the Meridian Map's node values, where a small acupoint is 1.2 W, a notable is 8 W and 1 W = +1 % attack. Damage, ward strength, linh lực, health, thần thức, artifact power and formation power follow the registry's `stat_power_weights`; every other number is a first guess, rounded for reading, until the bot measures it. A narrower modifier gets a bigger number, because it only helps some builds.

### Damage

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Damage (`attack_pct`) | +1.2 % | +8 % | ● |
| Art damage | +1.5 % | +10 % | ○ |
| Basic attack damage | +2 % | +12 % | ○ |
| Body damage, Qi damage | +1.5 % | +10 % | ○ |
| Sword, Palm, Seal or Beast damage | +2 % | +12 % | ○ |
| Fire, Water, Wood, Metal or Earth damage | +2 % | +12 % | ○ |
| Variant element damage (such as Lava) | +2.5 % | +15 % | ○ |
| Damage over time | +2 % | +12 % | ○ |
| Poison damage | +2.5 % | +15 % | ○ |
| Damage while above 50 % health | +2 % | +12 % | ○ |
| Damage while below 50 % health | +2 % | +12 % | ○ |
| Damage to an enemy with no linh lực | +2.5 % | +15 % | ○ |

### Critical hits and accuracy

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Crit chance (`crit_chance_pct`) | +0.4 % | +2.5 % | ● |
| Crit damage (`crit_damage_pct`) | +1.5 % | +10 % | ● |
| Crit chance with swords | +0.8 % | +5 % | ○ |
| Accuracy (`accuracy_pct`) | +0.5 % | +3 % | ● |
| Realm pierce (`pierce_pct`) | +0.5 % | +3 % | ● |

### Weapons and artifacts

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Artifact power (`artifact_power_pct`) | +0.9 % | +6 % | ● |
| Weapon attack (`artifact_attack_pct`, weapon role) | +1.5 % | +10 % | ● |
| Flying sword attack | +2 % | +12 % | ○ |
| Armour defence (`artifact_defense_pct`) | +1.5 % | +10 % | ● |
| Weapon efficiency: weapons occupy less thần thức | −1 % | −6 % | ○ |
| Artifact thần thức cost (`than_thuc_cost_pct`) | −0.8 % | −5 % | ● |
| Element affinity (`element_affinity_pct`) | +1.5 % | +10 % | ● |

### Speed

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Art speed (`art_speed_pct`) | +0.5 % | +3 % | ◐ |
| Sword art speed (or any one tag) | +1 % | +6 % | ○ |
| Basic attack speed | +1 % | +6 % | ○ |
| Companion attack speed | +1.5 % | +10 % | ○ |
| First firing comes sooner | −2 % | −12 % | ○ |

### Linh lực

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Maximum linh lực (`linh_luc_pct`) | +1.2 % | +8 % | ● |
| Linh lực regeneration (`linh_luc_regen_pct`), as a share of maximum per second | +0.15 % | +1 % | ● |
| Art cost (`art_cost_pct`) | −0.5 % | −3 % | ● |
| Fire art cost (or any one tag) | −1 % | −6 % | ○ |
| Linh lực regained on a crit, as a share of maximum | +0.1 % | +0.6 % | ○ |

### Ward

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Ward strength (`defense_pct`) | +1.2 % | +8 % | ● |
| Ward efficiency (`ward_efficiency_pct`) | +1.2 % | +8 % | ● |
| Ward strength against Fire (or any one element) | +2 % | +12 % | ○ |
| Ward strength against body hits, or qi hits | +1.5 % | +10 % | ○ |

### Body

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Maximum health (`khi_huyet_pct`) | +1 % | +6.5 % | ● |
| Body guard (`body_guard_pct`) | +1.2 % | +8 % | ● |
| Body guard against qi hits | +2 % | +12 % | ○ |
| Evade (`evade_pct`) | +0.4 % | +2.5 % | ● |

### Soul

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Thần thức (`than_thuc_pct`) | +0.9 % | +6 % | ● |
| Soul resistance (`soul_res_pct`) | +1 % | +6 % | ● |
| Soul attack damage (`x_soul`) | +1.5 % | +10 % | ○ |

### Statuses

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Status resistance (`status_resist_pct`) | +1 % | +6 % | ● |
| Status chance | +1 % | +6 % | ○ |
| Status duration | +2 % | +12 % | ○ |
| Curse duration on you | −2 % | −12 % | ○ |

### Escape, companions and preparation

| Modifier | Small | Notable | Status |
|---|---|---|---|
| Escape chance | +1 % | +6 % | ○ |
| Companion damage | +2 % | +12 % | ○ |
| Formation power (`formation_power_pct`) | +1.2 % | +8 % | ● |
| Talisman power | +2 % | +12 % | ○ |
| Pill effect in a fight (`pill_effect_pct`) | +1 % | +6 % | ● |

### Rare one-offs

Too strong to be a repeatable number, so each is a notable at most, or its own node.

| Modifier | Status | Effect |
|---|---|---|
| Art slot (`bonus_slots`) | ◐ | +1 art carried. Slots are uncapped, so keep these rare |
| Talisman stock | ○ | +1 use of a slotted talisman |
| Talisman sleeve | ○ | One talisman takes no art slot |
| Magic treasure slot | ● capability #2 | One more artifact equipped |
| Trigger limit (`trig_cap`) | ○ | +1 firing between pulses |
| Status stack cap | ○ | +1 stack |
| Conversion share | ○ | Converts more of a hit to another tag |
| Shorter `soul_lockout`, `escape_channel` | ○ | −0.1 s each |
| Talisman not consumed | ● capability #13 | A used talisman may survive |

## Rule-benders (keystones)

These change how a build plays instead of adding a number, which suits "build within the rules, never a stat race". All are ○. Names are working titles.

### Tempo and the timeline

| Name | Effect | Build it makes |
|---|---|---|
| Five Phases Cycle (Ngũ Hành Tương Sinh) | Arts firing in generating order (Wood, Fire, Earth, Metal, Water) each gain a stacking bonus; breaking the order resets it | Slot order and cooldowns become a puzzle |
| First Move (Tiên Thủ) | Your first art of the fight costs no linh lực | Alpha strike |
| Late Bloom (Hậu Phát) | Art speed rises for every 5 s the fight lasts | Sustain build that outlasts bursts |
| Sheathed Blade (Ẩn Phong) | An art that waited ready hits harder for each second it waited | Guarded, patient arts |
| Heavy Hand (Trọng Thủ) | Arts with a cooldown of 5 s or more deal more; arts under 2 s deal less | Few big hits |
| Thousand Cuts (Thiên Đao) | The reverse: fast arts deal more, slow arts deal less | Many small hits, on-hit effects |
| Flowing Water (Lưu Thủy) | A crit shortens your other arts' timers by 0.5 s | Crit chains |
| Echo (Hồi Âm) | An art has a chance to fire again at half power. Counts as a trigger, so the trigger budget applies | Combo |

### Linh lực and wards

| Name | Effect | Build it makes |
|---|---|---|
| Blood Casting (Huyết Tế) | Arts cost health when linh lực runs out | Never stops casting, kills itself if careless |
| Full Sea (Mãn Hải) | Bonus damage while linh lực stays above 80 % | Rewards efficient, cheap arts |
| Empty Vessel (Không Khí) | The less linh lực you have, the harder you hit | Deliberately burns out |
| Mirror Ward (Kính Hộ) | A share of blocked damage is stored and released with your next hit | Defence that attacks |
| Shattering Ward (Toái Hộ) | When your linh lực hits 0, the ward bursts for a free hit | Turns a loss of guard into a payoff |
| Spirit Severing (Đoạn Linh) | Your hits also burn the enemy's linh lực | Beats ward builds by starving them |
| Twin Wards (Song Hộ) | A second ward stays up at half strength; breaks "one ward at a time" | Layered resistance |

### Body and survival

| Name | Effect | Build it makes |
|---|---|---|
| No Ward (Vô Hộ) | You can never use a ward, but gain a large body guard | Pure thể tu |
| Iron Marrow (Thiết Tủy) | Body guard rises as health falls | Gets harder to finish |
| Thorned Skin (Kinh Bì) | Part of the damage body guard stops is returned to the attacker | Punishes fast hitters |
| Last Stand (Bối Thủy) | Big art speed bonus below 30 % health | Comeback build |
| Unyielding Breath (Bất Khuất) | Once per fight, a killing blow leaves you at 1 health | Reliable escape window |
| Wounded Beast (Thương Thú) | Low vitality before the fight raises damage instead of only hurting you | Fights on while injured |

### Slots and loadout

| Name | Effect | Build it makes |
|---|---|---|
| Focused Mind (Nhất Tâm) | One fewer art slot, but more damage on the rest | Specialist |
| Empty Hand (Không Thủ) | Every empty art slot strengthens the basic attack | Martial, zero-art build |
| One Root (Đồng Căn) | A bonus if every slotted art shares one element | Pure element |
| Head of the Line (Tiên Phong) | Your first slot deals much more, your last slot less | Slot order matters more |
| Elemental Fist (Ngũ Hành Quyền) | The basic attack carries your main element's tags | Basic attack benefits from element bonuses |

### Soul and realm

| Name | Effect | Build it makes |
|---|---|---|
| Against the Heavens (Nghịch Thiên) | More damage for each realm your enemy is above you | The vượt cấp specialist |
| Soul Pressure (Thần Uy) | With a soul twice the enemy's, its first arts fire later | Intimidation |
| Soul Wound (Thương Hồn) | Soul hits briefly lower the enemy's art speed | Soul as control, not damage |
| Seeing Eye (Động Sát) | Reveals more of the enemy's profile while preparing (Combat Open Question 4) | Information as power |

### Fortune, companions and preparation

| Name | Effect | Build it makes |
|---|---|---|
| Heaven's Favour (Thiên Quyến) | Once per fight, reroll a failed escape | Fortune build |
| Bonded Spirit (Linh Khế) | The companion's hits carry your art speed and your statuses | Beast master |
| Standing Array (Thường Trận) | Your formation also counts in blind fights | Always-prepared formation master |
| Home Ground (Địa Lợi) | Ground tags always count in your favour | Chooses where to fight |

### Dark paths

Big power with a real cost outside the fight, so the choice carries into the rest of a life. Combat only reports these; the caller applies the cost (rule 14).

| Name | Effect | Cost |
|---|---|---|
| Heart Demon's Blade (Tâm Ma Nhập Đao) | Damage rises with your heart demon (tâm ma) | Raises the qi deviation chance |
| Burning Lifespan (Nhiên Thọ) | Once per fight, a large surge of power when health is low | Years of lifespan |
| Glass Meridians (Lưu Ly Kinh Mạch) | Large art speed bonus | Less health and body guard |

## Forged by builds

Added by the build sessions. Who uses each piece is in `design/builds/content-ledger.md`. All are ○, and sizes are first guesses from the pilot builds.

### Modifiers

| Modifier | Form | Effect | Layer |
|---|---|---|---|
| Spillover (Dật Độc) | Overflow | Tick damage a cap clips burns the target's linh lực, within the qi burn cap | none |
| Bare Vessel (Lộ Đỉnh) | Conditional | More hit damage while the enemy has under 5 % linh lực | L5 |
| Rot Deepens (Thi Độc Thâm) | More | More tick damage with the poison tag | L2 |
| Corpse-Wax Coating (Thi Lạp) | More | Prepared tick damage | L4 |
| On the Beat (Hợp Tiết) | Conditional | More damage on an art that fires in the same millisecond as a pulse | L5 |
| Sustained Note (Dư Âm) | Per | More art damage per second of the fight, up to a cap | L2 |
| Tolled Seal (Chung Ấn) | More | More damage on arts with the seal form | L2 |
| Ringing Ground (Hưởng Địa) | More | Prepared art damage from a formation | L4 |

### Enablers

An enabler opens a channel, a rule or a resource, and closes something in exchange. It lives on a named artifact, technique, keystone or Đạo.

| Name | Kind | Opens | Closes |
|---|---|---|---|
| Grave-Silk Shroud (Liệm Thi Y) | New channel | A permanent tick from t = 0 with no slot | 25 % of maximum linh lực reserved |

### Cluster ideas

For the tree rework. Sealed clusters a player can plan a life around. Details are in each build's sheet.

| Name | Theme | Holds |
|---|---|---|
| Sick Meridians (Bệnh Mạch) | Way of Alchemy | Tick stack, Bare Vessel |
| Measured Breath (Điều Tức) | Heart State | Art speed, regeneration, On the Beat |

## To settle in the rework

- **Pricing.** Combat rule 5 says W fills only layer L1. Node modifiers such as "+2 % sword damage" are tagged "increased" bonuses, which L1 accepts, so W can price them. "More" bonuses in L2 to L5 and most keystones are priced separately (Combat Open Question 5).
- **New keys.** Every ○ row needs a stat key, and tagged rows need one key shape that names a tag rather than a key per tag.
- **Limits.** Art slots are uncapped, so repeatable slot nodes would make the count unbounded and work against Pillar 2. Keep them rare and one-off.
- **Rule changes.** Twin Wards, Unyielding Breath, Lifesteal and the Dark paths each need a rule in the Combat GDD, not only a key.
- **Same rules for NPCs.** NPC Builds use the same profile, so every keystone must be something the generator can use and the player can read in a Breakdown.
- **Determinism.** Chance effects use the fight's seeded stream, and chance-free builds must stay deterministic (Combat rule 15).
