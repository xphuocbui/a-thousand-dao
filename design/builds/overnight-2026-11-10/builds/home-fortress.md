# The Hearth Mountain (Trạch Sơn)

Never meet a guest on the road: fill every kind of preparation past its limit, turn the surplus into walls, and make every fight happen on your own mountain.

## Why it works

Every hit you deal is multiplied by five layers, and the fourth one, **preparation (L4)**, is fed only by what you did before the fight: a formation laid on the ground, a pill eaten, a coating on your hands, a talisman ready, and the ground itself. L4 is capped at +150 points, which multiplies your damage by **×2.5** (combat.md Formulas B). Most builds reach that cap with a pill and one formation and stop.

You don't stop. At home, with all five kinds of preparation, you bring about **310 points** to a layer that keeps 150. The key Effect, **Overbuilt Walls**, takes the roughly **160 points the cap throws away** and turns them into **+100 ward strength**. Ward strength multiplies every ward you have (combat-defence.md Formulas A: a ward's resistance × (1 + ward strength / 100)), and it also cuts what your wards cost you in linh lực.

Add the home formations (the Hộ Sơn mountain-guard array gives +112 ward strength at level 7) and Field Walls (+30), and at Nascent Soul (Nguyên Anh) your ward strength is about **407** at home against about **165** on the road. The ordinary Common Ward then stops **94.6 %** of a hit at home and **90.1 %** away, so you take about **half** the damage per hit at home.

Your damage multiplier at home is about **235**, close to the top-end mark of 256. Caught blind on the road, it falls to about **88**, with a quarter of your linh lực locked away. That is the deal: monstrous where you chose to fight, crippled where you didn't. So the whole build is about choosing where you fight.

## What to look for

In the order you'll find them.

1. **Spiritual root (linh căn): Earth (Thổ), ideally with Water (Thủy).** In the game. Earth purity cuts your formation upkeep (0.4 % per point of purity) and gives more spirit fields (linh điền) for pill herbs. Earth also powers the Earth buff stacks that dampen Physical damage. Water makes pill toxicity (đan độc) fade faster, so you can eat more fight pills a year. Aim for Earth purity 70 or more.
2. **Talents.** In the game. Soul (thần hồn) for divine sense (thần thức): you'll carry four artifacts and want extra ward slots. Comprehension (ngộ tính) for formation and alchemy skill, because a formation's level is capped at your formation skill + 1.
3. **A cave abode (động phủ) on a spirit vein, with a narrow approach.** In the game (travel-map.md rule 8: open one on any wilderness tile). Everything else is built here.
4. **The Hộ Sơn mountain-guard array (Hộ Sơn Trận).** In the game: +10 % ward strength per level at home, up to level 5.
5. **The Alarm Array (Cảnh Linh Trận).** Not in the game yet (staged: `alarm-array`). Wind-bells round your valley: a fight at home that would be blind becomes an ambush, so your standing arrays still count.
6. **The way of formations, Trận Đạo · Phong Thủy (Wind and Water).** The Way is in the game's catalogue; these nodes are not yet (staged: `tran-phap-overbuilt`, `phu-luc-primed`, `dong-phu-hearth`). Take its five facets: Arrays (Overbuilt Walls, Pressing Mountain, Laid Stone), Talismans (Talisman Sleeve, Primed Talismans), Ward Arrays (Field Walls), and Cave Dwelling (Host's Advantage, Five Preparations). A second Way, the Earth Way (Thổ Đạo · Bất Động Sơn), adds two Earth damage notables.
7. **The cultivation method (công pháp): Hearth-Mountain Scripture (Trạch Sơn Quyết).** Not in the game yet (staged: `hearth-mountain-scripture`). Main method, Earth, Earth grade (Địa giai), up to Nascent Soul. It teaches every art you use and holds four of the key Effects.
8. **Arts (thần thông).** Not in the game yet (staged: `stake-driving-seal`, `warm-stone`, `mountain-press-seal`, `landslide`, `homeward-step`). Three slow Earth seals that carry the `formation` tag, a heal, and an escape.
9. **Items.** The Nine Rods Array (staged: `nine-rods-array`), the Mountain-Root Pill (staged: `mountain-root-pill`), the Iron-Sand Hand Bath coating (staged: `iron-sand-hand-bath`), the Boundary-Stake Talisman (staged: `boundary-stake-talisman`), the Hot Spring Array (staged: `hot-spring-array`), and the Challenge Letter (staged: `challenge-letter`). None are in the game yet. A generated seal weapon (ấn) and shield are in the game.
10. **The enabler: the Threshold Flags (Môn Hạn Kỳ).** Not in the game yet (staged: `threshold-binding`). Four flags cut from the doorframe of the Scripture's founder. Plant them before a foreseen fight and your home arrays count on that ground. Found in a dead cultivator's sealed abode, or earned as the Cave Dwelling capstone of Trận Đạo.

## The enabling Effects

- **Overbuilt Walls (Lũy Thặng)**, the identity. The preparation points past L4's cap (150) that reach your slot-1 art become ward strength: +1 per 1.5 points clipped, up to +100. It counts what is ready before the fight (formations, pills, coatings, ground), not talismans. **Why you need it:** without it every point past 150 is wasted. With it, over-preparing is your defence.
- **Threshold Binding (Trấn Môn)**, on the Threshold Flags, the enabler. Planted before a foreseen fight, your home-only formations count there and the ground counts as your abode. **The price:** in any fight where none of your formations count (an ambush or blind fight away from home), 25 % of your linh lực is locked away and does nothing. **Why you need it:** at Nascent Soul you have to leave the valley sometimes. The flags take the valley with you, as long as you chose the fight.
- **Five Preparations (Ngũ Bị).** +10 % more damage (L5) for each kind of preparation that counts: formation, pill, coating, talisman, ground. Up to +50. **Why you need it:** two items reach the L4 cap; five kinds reach this. It is what makes the talisman and the coating worth carrying at home, where L4 is already full.
- **Host's Advantage (Chủ Lợi).** +30 more damage (L5) while you fight on your own ground (home, or under the flags).
- **Field Walls (Điền Thành)**, in the game's Effects design. Half your formation power also counts as ward strength.
- **Formation Within a Formation (Trận Trung Trận)**, in the game's Effects design, a keystone. Your formations may go 2 levels past their maximum; those levels cost double upkeep. Earth's upkeep cut pays for it.
- **Primed Talismans (Phù Dĩ Khai).** In a foreseen fight your talismans first fire at 0.5 s, so the Boundary-Stake is up before anything else happens.
- **Talisman Sleeve (Phù Tụ)**, in the game's Effects design. One talisman with a guard takes no art slot.
- **Pressing Mountain (Áp Sơn).** At the first pulse and every 4 pulses after, your laid formation lays Sundered on the enemy (−150 Physical resistance), so your Physical seals land on an open ward.
- **Taken Ground (Chiếm Địa).** Where your formation counts, the enemy's preparation (L4) counts at most +20. A rival preparation build has to fight you on your terms.

## Modifiers to stack

In priority order.

1. **Formation power (`formation_power_pct`)**: multiplies every formation's output at once: the Nine Rods' L4, the Hộ Sơn ward strength, the Hot Spring's regeneration, and through Field Walls your ward strength again. Aim for about +60. There is no cap, but once L4 is full and Overbuilt Walls sits at +100, more only feeds the Hộ Sơn array and Field Walls.
2. **L4 points from all five kinds**: fill the cap first (150), then keep going until Overbuilt Walls reaches +100, which is about 300 points of prepared L4 on your main seal. **Stop there.** Past that, the only reason to add a kind is Five Preparations (+10 per kind, up to 5 kinds).
3. **Pill effect (`pill_effect_pct`) and pill quality**: the pill's L4 is `60 × (1 + 0.25 × quality) × (1 + pill effect / 100) × (1 − toxicity / 100)`. About +30 pill effect and quality 2 give +93.6.
4. **Toxicity control (`dan_doc_resist_pct`, `dan_doc_decay`, Water purity)**: toxicity lowers the pill's potency point for point (at 50 toxicity it is half a pill). Keep toxicity under about 20.
5. **L2 "more" damage with the [formation], [seal] and [tho] tags**: Laid Stone, Tolled Seal and the Earth Way's notables. **Stop at +300**, the hard cap.
6. **Damage increased (`attack_pct`, `attack_pct` [formation])**: L1. Each point past +200 counts half (soft cap), and the hard cap is 400.
7. **Ward strength (`defense_pct`)**: you get most of it from formations; tree nodes top it up. There is no cap, and each point is worth a little less than the one before.
8. **Linh lực regeneration and ward efficiency**: your seals cost 0.03, 0.06 and 0.10 of your pool. With the Hot Spring Array at home you can afford them; away you can't.
9. **Thần thức (`than_thuc_pct`)**: four artifacts bind about 2,100 at Nascent Soul, about 1.56 times the reference. Stop once they fit, unless you want a third or fourth ward slot.
10. **Crit chance and damage**: ordinary. Fill what the tree gives you.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Threshold Flags | Threshold Binding (enabler) | Your home arrays count on any foreseen ground; costs 25 % linh lực in unprepared fights | Named artifact (sealed dead cultivator's abode); Trận Đạo Cave Dwelling capstone | Staged: `threshold-binding` | core |
| Overbuilt Walls | Overflow Effect | Up to +100 ward strength from preparation past the L4 cap | Trận Đạo Arrays facet (major); Hearth-Mountain Scripture layer 12 | Staged: `overbuilt-walls` | core |
| Hearth-Mountain Scripture | Công pháp: 3 seals, heal, escape; Laid Stone, Five Preparations, Primed Talismans | The whole art kit and four Effects | Main method, Địa giai, Earth | Staged: `hearth-mountain-scripture` | core |
| Nine Rods Array | L4 +80 (Ringing Ground) × formation power | The biggest single L4 source; counts in an ambush when laid at home | Formation | Staged: `nine-rods-array` | core |
| Hộ Sơn Trận to level 7 | `defense_pct` +10 per level at home | +112 ward strength with formation power +60 | Home formation; levels 6–7 need Formation Within a Formation | In the game (levels 6–7 need the keystone, in the Effects design) | core |
| Formation Within a Formation | Keystone: +2 formation levels, double upkeep for them | Hộ Sơn and Nine Rods past their maximum | Meridian Map keystone (capability #15) | In the Effects design | core |
| Formation power | `formation_power_pct` +8 notables | Multiplies every array you own | Tree notables; Trận Đạo Arrays and Ward Arrays lines; Quartermaster's Ledger cluster | In the game (key live); cluster staged: `quartermaster-cluster` | core |
| Mountain-Root Pill | L4 +60 [tho] × pill potency | +75 to +94 L4 before every chosen fight | Pill (alchemy, Earth herbs) | Staged: `mountain-root-pill` | core |
| Five Preparations | Per Effect: L5 +10 per kind, cap +50 | Up to +50 % more damage at home | Scripture layer 9; Trận Đạo Cave Dwelling | Staged: `five-preparations` | strong |
| Host's Advantage | Conditional Effect: L5 +30 | More damage on your own ground or under the flags | Trận Đạo Cave Dwelling facet (major) | Staged: `hosts-advantage` | strong |
| Field Walls | Conversion Effect: half formation power → ward strength | About +30 ward strength | Trận Đạo Ward Arrays facet; a formation | In the Effects design | strong |
| Alarm Array | Formation: blind → ambush at home; carries Taken Ground | Nobody catches you unready at home; rival preparation held to +20 | Home formation | Staged: `alarm-array`, `taken-ground` | strong |
| Iron-Sand Hand Bath | Coating: L4 +25 to +50 on Physical hits | One more kind for Five Preparations; more surplus for the walls | Coating (crafted) | Staged: `iron-sand-hand-bath` | strong |
| Laid Stone and Tolled Seal | L2 `damage_more` [formation] +60/+40, [seal] +40 | L2 toward its 300 cap | Scripture layer 2; Trận Đạo Arrays notables | Staged: `laid-stone`; Tolled Seal in the content ledger | strong |
| Pill effect and toxicity resistance | `pill_effect_pct`, `dan_doc_resist_pct`, `dan_doc_decay` | Keeps every pill at full strength | Tree, Quartermaster's Ledger cluster, Water purity | In the game (keys live); cluster staged | strong |
| Pressing Mountain | Trigger Effect: Sundered from the ground | −150 Physical resistance on the enemy at the first pulse and every 4 after | Trận Đạo Arrays facet (minor) | Staged: `pressing-mountain` | strong |
| Hot Spring Array | Formation: linh lực and health regeneration | Pays for the seals in a long home fight | Home formation | Staged: `hot-spring-array` | strong |
| Boundary-Stake Talisman | L4 +40 [formation] for the rest of the fight | A kind for Five Preparations at home; your only L4 when blind on the road | Talisman (crafted) | Staged: `boundary-stake-talisman` | nice |
| Talisman Sleeve and Primed Talismans | Rule changes: a talisman takes no slot; talismans first fire at 0.5 s | Frees your sixth slot for a soul ward; talisman up at once | Trận Đạo Talismans facet | Talisman Sleeve in the Effects design; Primed staged: `primed-talismans` | nice |
| Challenge Letter | Life talisman: a hunter's or rival's next fight is foreseen, at your abode | Turns being hunted into an appointment | Talisman (crafted, life use) | Staged: `challenge-letter` | nice |
| Landing Ground | Ground tag: L4 +40 where you have spent seasons | L4 even in a blind fight at home | Seasons spent at your abode | Staged: `landing-ground` | nice |
| Seal weapon (ấn), Cực phẩm, Nascent Soul tier | L3 gear; `artifact_attack_pct` affixes | L3 toward the top-end ×3.5 | Generated artifact | In the game | nice |

## Realm by realm

- **Core Formation (Kết Đan), early.** Open the cave abode, raise Hộ Sơn to level 5, lay the Nine Rods at home and brew the first Mountain-Root Pills. Three items (Nine Rods about 104, pill about 75, ground 40) already fill L4 at home: ×2.5 on every seal. Hang the Alarm Array as soon as you can.
- **Core Formation, late.** The Scripture reaches layer 9: Five Preparations. Add the coating and the Boundary-Stake Talisman for the extra kinds. Send your first Challenge Letter to whoever hunts you. You have no escape art yet, so do not travel unprepared.
- **The tribulation into Nascent Soul.** Fight it at home. A tribulation is always foreseen, its ground is the place of the attempt plus the tag `tribulation`, and a laid formation counts (thien-kiep.md rule 5). It is the one great fight of your life you get to set up completely.
- **Nascent Soul (Nguyên Anh).** The machine is complete: Overbuilt Walls (layer 12), Formation Within a Formation (Hộ Sơn at 7), the Threshold Flags, Homeward Step, Talisman Sleeve. About 235 damage multiplier and 407 ward strength at home. Now you can leave the valley, as long as you plant the flags before every fight you choose.
- **Past Nascent Soul.** The Scripture stops here (it is Earth grade). The shipped Hậu Thổ Thiên Kinh carries an Earth root on, without the Scripture's Effects; the Way's nodes and the flags stay.

## How it plays

**Loadout at Nascent Soul (6 art slots), in slot order:**

1. Mountain-Press Seal: the big hit, every 6 s. It must be slot 1: Overbuilt Walls reads its L4.
2. Landslide: every 4 s; gives you Earth stacks that dampen Physical damage.
3. Stake-Driving Seal: every 2 s, cheap.
4. Warm Stone: heals when you're at 70 % health or below, and refunds itself.
5. Homeward Step: escape at 30 % health. Your only answer to a blind fight.
6. A ward in the art slot: Golden Bell, or a second soul ward against a soul-piercer.

The Boundary-Stake Talisman rides in the Talisman Sleeve, taking no slot. Ward slots (3 at Nascent Soul, more with high thần thức): Common Ward, Mountain Screen, Soul-Guarding Lamp.

**Before every chosen fight:** lay or plant (Nine Rods at home, the flags away), eat the Mountain-Root Pill, coat your hands, check the talisman is slotted. Five kinds, five lines in your opening Breakdown.

**The signature moment:** a rival who has hunted you for a decade finally finds you at home. The wind-bells ring, so it is an ambush, not a blind fight. Taken Ground holds their own pill and flags to +20. Their opening volley breaks on wards stopping 95 % of it, and the Mountain-Press Seal answers at ×2.5.

## What beats it

- **The assassin on the road** (Night Walker paths, Ám Đạo: first strike, crit). Caught blind away from home you keep one talisman's L4, ward strength drops from about 407 to 165, and a quarter of your linh lực is locked. **Adapt:** travel rarely and never unprepared; keep Homeward Step slotted; with Earth and Water you may converge the Darkness variant (Ám), whose stealth helps you avoid being found at all.
- **The drainer** (Qi Disruption, soul arts that take linh lực). With no linh lực, every ward drops (combat.md rule 23). **Adapt:** the Hot Spring Array and ward efficiency at home; on the road, refuse the fight.
- **The soul-piercer.** Soul hits skip resistance, so your walls don't matter. **Adapt:** the Soul-Guarding Lamp in a ward slot, a second soul ward in the sixth art slot, and the `soul_res_pct` lines of the Ward Arrays facet.
- **The rival at their own home.** Their array or their Taken Ground holds your L4 down. **Adapt:** never accept a fight on someone else's mountain. Send the Challenge Letter instead.
- **The patient rival** who refuses every letter and waits for you to travel. **Adapt:** the World Database records each refusal; let reputation do the work, and plant the flags when you must go.
- **High Physical resistance.** **Adapt:** Pressing Mountain's Sundered at home opens it. Away, you lack an answer.

## Not in the game yet

Every staged piece this build needs, by its staging ID in `design/builds/overnight-2026-11-10/staging-catalogue.md`:

- **Enabler:** `threshold-binding` (the Threshold Flags).
- **Effects:** `overbuilt-walls`, `five-preparations`, `primed-talismans`, `hosts-advantage`, `pressing-mountain`, `taken-ground`.
- **Modifier:** `laid-stone`.
- **Cultivation method and arts:** `hearth-mountain-scripture`; `stake-driving-seal`, `warm-stone`, `mountain-press-seal`, `landslide`, `homeward-step`.
- **Items:** `mountain-root-pill`, `boundary-stake-talisman`, `alarm-array`, `challenge-letter`, `landing-ground`; reused from other builds: `nine-rods-array`, `iron-sand-hand-bath`, `hot-spring-array`; Tolled Seal (content ledger).
- **Way nodes:** `tran-phap-overbuilt`, `phu-luc-primed`, `dong-phu-hearth`.
- **Concepts and keys:** `own-abode-ground-tag`, `situation-step`, `layer-total-readable`, `preparation-fight-payload`, `quartermaster-cluster`.

Already in the game or its design: Hộ Sơn Trận, the Earth and Water roots, `formation_power_pct`, `pill_effect_pct`, `dan_doc_resist_pct`, `defense_pct`, Field Walls, Formation Within a Formation, Talisman Sleeve, Steady Breath, Long Tượng Công, the generated seal, shield and armour.

## Changes the game would need

1. **An `own_abode` ground tag, and home-only formations read by Combat.** Combat GDD (`design/gdd/combat.md`) rule 12 and the Event Engine's fight request: when a fight happens at a cave abode, its owner's side gets the ground tag `own_abode`, and Combat counts that side's formations marked `applies: home` in `crafting_formations.json`. An Effect (the Threshold Flags) may stamp the tag in a foreseen fight.
2. **A source may raise a fight's situation one step.** Combat GDD rule 12 and the Event Engine (#23, no GDD yet): a home formation (Alarm Array) turns blind into ambush at its ground; a life talisman (Challenge Letter) makes a named rival's next fight foreseen at your abode. One step, your side only.
3. **A layer's total before its cap, readable at compile.** Effects GDD (`design/gdd/effects.md`) rule 5: so Overbuilt Walls can turn the L4 surplus into ward strength fixed for the fight.
4. **A fight payload for pills, coatings and talismans.** Combat GDD rule 12, the Item Database GDD (`design/gdd/item-database.md`) and the Alchemy and Talismans quick specs: each record carries its L4 or stat payload, what scales it (pill potency, talisman power, coating quality) and which situations allow it.
5. **Say how many formations count on one ground, and whose.** Combat GDD rule 12 says "a formation laid on the ground": at your own abode every standing home formation should count, away you lay one, and both sides' count unless an Effect (Taken Ground) says otherwise.
