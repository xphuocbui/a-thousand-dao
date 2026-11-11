# The Hearth Mountain (Trạch Sơn)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses; every other number is read from the GDDs and data files on this run.
> **Seed**: "Fill L4 to its cap: formations, talismans, pills, coatings and home ground before the fight. Monstrous when it chooses the fight, crippled in a blind one. What the player does to force fights onto their ground."
> **Direction**: The Hearth Mountain: an Earth formation master who fills L4 from all five kinds of preparation, spends the surplus past the cap as walls, and spends a life making sure every fight happens at home (chosen by the session under the run's override, not by the user).
> **Realm span**: Kết Đan to Nguyên Anh (defined at Nguyên Anh) · **Power level**: top-end · **Use**: player
> **Fit**: 10 Fits today (4 new, 6 already in the GDDs or data) · 15 Needs key · 5 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (The fight, and the identity test inside Stack: no simulator this run, user decision 2026-11-11)

## Directions considered

**Chosen: The Hearth Mountain (Trạch Sơn).** Home ground as a fortress. L4 at its cap from five kinds, an Overflow that turns the clipped surplus into ward strength (sustain is king), and a set of life tools (Alarm Array, Challenge Letter, Threshold Flags) whose only job is to make the fight a foreseen one on the build's own ground. It is the strongest min-max reading: it fills an anchor layer, gives the surplus a use, and keeps the seed's price (a blind fight away from home is a real collapse).

- **The Travelling Array (Hành Trận).** Array flags and sleeved talismans carry the preparation everywhere, so an ambush counts as prepared. Not picked: it turns "crippled in a blind one" into "a little weaker", and the home ground stops mattering.
- **The Usurper's Ground (Đoạt Địa).** The surprise reading: fight at the enemy's home and take their formation's L4 for yourself. Not picked: it is a counter to preparation, not a top-end stack. One piece of it stays: Taken Ground, as the home's answer to a rival preparer.

## The Spine

- **The channel:** art hits. Slow Earth formation seals (Physical, tags `tho`, `seal`, `formation`) that use every layer, L1 to L5. L4 sits at its hard cap of 150 (×2.5, combat.md Formulas B), L2 reaches its cap of 300 with a second Way, and L5 sits near its cap of 100.
- **The enabler:** Threshold Binding (Trấn Môn), on the Threshold Flags. It opens home formations on any foreseen ground. It closes 25 % of maximum linh lực, reserved for nothing, in every fight where no formation of the owner's counts.
- **The loop:** before the fight: lay the array, eat the pill, coat the hands, slot the talisman, stand on owned ground. In the fight: the talisman fires at 0.5 s, the array lays Sundered at the first pulse, the seals fall into an open ward every 2, 4 and 6 s, and the walls hold whatever comes back.
- **The engine:** L4 can only reach ×2.5, and a fully prepared home brings about 310 points to it. **Overbuilt Walls** turns the 160 points the cap would throw away into +100 ward strength, which multiplies every ward's resistance and cuts every drain bill. So stacking preparation past the cap stops being waste and becomes the build's defence.
- **The sacrifice:** the blind fight away from home. There it keeps one talisman's L4, loses the walls and a quarter of its linh lực, and runs. The build refuses to fix this; it fixes where it fights instead.
- **The arc:** at Kết Đan, a cultivator who wins only the fights they planned, and plans every fight. At Nguyên Anh, a mountain that anyone who climbs arrives at tired, and a pair of flags that let the mountain travel.

## The Legend

The Hearth-Mountain Scripture is not a fighting manual. It is a household book: how many jars of pickled root to keep under the floor, how deep to drive the boundary stakes, which wind-bells to hang where the path narrows. Its author was a hermit nobody remembers by name, whose valley three sects tried to take in one century and none took. The book says nothing about fighting. It says: "Never meet a guest on the road."

Those who walk it now are hoarders and householders. They buy every pill twice and drink neither until they must; they spend more on formation upkeep than on their own robes. Sect elders send their disciples to them to learn patience. The disciples come back saying the old one never left the valley and never lost, and also never once came to their aid.

It does something to the person. Every year spent laying the array is a year tied to it, and a master who has lived in one valley for three centuries is not quite whole anywhere else. Assassins of the Night Walker paths (Ám Đạo) know this. They do not climb the mountain. They wait on the road to the market town.

## How It Fights

At home, or under its flags, the fight starts before the enemy arrives. The pill is eaten, the coating is on, the Nine Rods are planted, and the Hộ Sơn array has stood for decades. At 0.5 s the boundary-stake talisman fires. At the first pulse the ground presses Sundered onto the enemy. At 2 s the first small seal falls, at 4 s the landslide, at 6 s the mountain-press seal, each at L4 ×2.5 and L5 ×1.9. Every hit the enemy throws back meets wards running at about four times their base strength. The enemy runs dry, or dies, or both. On the road, caught blind, the same cultivator has a quarter of their linh lực locked away, walls of ordinary strength, one talisman, and a Homeward Step.

**The signature moment:** a rival who has hunted the build for a decade finally finds it at home. The wind-bells of the Alarm Array ring, so the fight is an ambush, not blind. Taken Ground holds the rival's own pill and flags to +20. The rival's opening volley lands on wards stopping about 95 %, and the mountain-press seal answers at ×2.5 preparation.

## Enabler

**Threshold Binding (Trấn Môn)**, carried by the **Threshold Flags (Môn Hạn Kỳ)**: four flags (base `ky`: attack 15, defence 15, thần thức 20) cut from the doorframe of the Scripture's founder. A player finds them in a sealed dead cultivator's abode (travel-map.md rule 15 leaves such places in history) or earns them as the Trận Đạo capstone of the Động Phủ facet, the second host.

- **Opens:** planted before a foreseen fight, the flags make that ground the owner's abode for the fight. Every formation that applies only at home (`applies: home` in `crafting_formations.json`: Hộ Sơn Trận today, the Hot Spring and Alarm arrays here) counts there, and the ground carries the owner's `own_abode` tag (Host's Advantage reads it).
- **Closes:** in any fight in which no formation of the owner's counts (an ambush away from home, or any blind fight away from home), 25 % of maximum linh lực is reserved and does nothing (Effects action "reserve linh lực"; combat.md rule 3: linh lực starts at `qi_max · (1 − Σ reserved)`). A quarter of the pool, and so a quarter of the drain ward's capacity, stays bound to a home it cannot reach.
- **Fit:** Needs rule (combat.md rule 12; Combat reading the `applies` field); Needs key (`own_abode`).

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1. Base | Art coefficients at the lint | Mountain-Press Seal 4.65, Landslide 1.91, Stake-Driving Seal 1.97 (Combat Formulas C lint) | — | art hit | none | ○ | Technique arts | — |
| 2. Rate | Primed Talismans (Phù Dĩ Khai) | In a foreseen fight, your talismans first fire at `cooldown_min` | Timing (Effect) | talisman | none | ○ | Trận Đạo Phù Lục; technique L6 | first-volley, talisman openers |
| 2. Rate | Art speed (`art_speed_pct`) | Small amounts from the tree; the seals stay slow on purpose | Increased | art hit | none | ◐ | Tree | every art build |
| 3. L1 | Damage (`attack_pct`), and `attack_pct` [formation] | About +300 in total at Nguyên Anh (soft cap past 200: counts 250) | Increased | art hit | L1 | ● / ◐ | Tree, Way | every build |
| 3. L2 | Laid Stone (Lũy Thạch) | +60 [formation] on the technique, +40 on each of 3 Trận Pháp notables | More | art hit | L2 | ○ | Technique L2; Trận Đạo | array casters |
| 3. L2 | Tolled Seal (Chung Ấn) | +40 [seal] | More | art hit | L2 | ○ (content ledger) | Trận Đạo Trận Pháp notable | Ninth Bell, any seal build |
| 3. L3 | Seal weapon and flags | Generated `an` seal (Cực phẩm, Nguyên Anh tier), `artifact_attack_pct` affixes; the flags add a little | Gear | art hit | L3 | ● | Artifacts | every build |
| 3. L4 | Nine Rods Array, Ringing Ground | +80 on art hits from a formation, × formation power | More | art hit, prepared | L4 | ○ (staging) | Formation | first-volley, dry-well, bare-fist, curse-engine, triple-convert |
| 3. L4 | Mountain-Root Pill (Sơn Căn Đan) | +60 [tho] × `pill_potency` | More | art hit, prepared | L4 | ○ | Pill | Earth builds |
| 3. L4 | Iron-Sand Hand Bath | +25 (common) to +50 (fine) on Physical hits [basic, art] | More | art hit, prepared | L4 | ○ (staging) | Coating | bare-fist, any thể tu |
| 3. L4 | Boundary-Stake Talisman (Giới Trụ Phù) | +40 [formation] for the rest of the fight once it fires, × talisman power | More | art hit | L4 | ○ | Talisman | formation-art builds |
| 3. L4 | Landing Ground (Độ Khẩu Địa) | +40 on a place where you owe seasons; a ground tag, kept blind | More | any hit | L4 | ○ (2026-11-07) | Ground | already-waited, hermits |
| 3. L4 | Formation power (`formation_power_pct`) | About +60: multiplies every formation's output (`formations.gd`: power = 1 + total / 100) | Increased | preparation | none | ● | Tree, Way, cluster | every formation user |
| 3. L4 | Pill effect (`pill_effect_pct`) | About +30: multiplies `pill_potency` (character-stats.md Formulas D) | Increased | preparation | none | ● | Tree, cluster | every pill user |
| 3. L5 | Five Preparations (Ngũ Bị) | +10 for each kind that counts (formation, pill, coating, talisman, ground), cap +50 | Per (Effect) | art hit | L5 | ○ | Technique L9; Trận Đạo Động Phủ | any preparation build |
| 3. L5 | Host's Advantage (Chủ Lợi) | +30 while the ground carries your `own_abode` tag | Conditional (Effect) | art hit | L5 | ○ | Trận Đạo Động Phủ | home-ground Ways, bosses |
| 3. L5 | Steady Breath (Bình Tức) | +12 while your linh lực is at 50 % or above, scope [formation] | Conditional (Effect) | art hit | L5 | ◐ (Effects GDD) | Technique host or item | sword, ward casters |
| 4. Crit | Crit chance and damage | Tree and Way, toward the top-end 50 % at ×2 | Increased | art hit | outside M | ● | Tree | every build |
| 5. Reach | Pressing Mountain (Áp Sơn) | First pulse and every 4th after: the laid formation places Sundered (Physical) | Trigger (Effect) | reach | none | ○ | Trận Đạo Trận Pháp | curse-engine, triple-convert |
| 5. Reach | Taken Ground (Chiếm Địa) | Where your formation counts, the enemy's L4 counts at most +20 | Rule swap (Effect) | enemy's L4 | L4 | ○ (2026-11-07) | Alarm Array | level-ground, sect arrays |
| 6. Past the cap | **Overbuilt Walls (Lũy Thặng)** | L4 points your prepared sources bring to slot 1 past 150 → +1 ward strength per 1.5 points, cap +100 | Overflow (Effect) | defence | none | ○ | Trận Đạo Trận Pháp `major`; technique L12 | every build past L4's cap |
| 6. Past the cap | Formation Within a Formation (Trận Trung Trận) | Your formations may exceed their maximum by 2 levels; those levels cost double upkeep | Cap shift (keystone) | preparation | none | ◐ (Effects GDD) | Meridian Map keystone | every formation user |
| 7. Fuel | Hot Spring Array (Ôn Tuyền Trận) | Linh lực and health regeneration on its ground | Formation | sustain | none | ○ (staging) | Home formation | unkillable, Hot Spring |
| 7. Fuel | Warm Stone (heal art), `linh_luc_regen_pct` | Refunding heal at 70 % health; tree regeneration | Art; Increased | sustain | none | ○ / ● | Technique; tree | every sustain build |
| 8. Survival | Hộ Sơn Trận | `defense_pct` +10 a level at home, level 7 with the keystone, × formation power | Formation stat | defence | none | ● (in the game) | Home formation | every abode owner |
| 8. Survival | Field Walls (Điền Thành) | Half your formation power also counts as ward strength | Conversion (Effect) | defence | none | ◐ (Effects GDD) | Trận Đạo Hộ Trận `major` | every formation user |
| 8. Survival | Landslide's Earth buff stacks | 4 stacks for 10 s per firing: Physical damage taken 1.1 % dampened each, × purity factor | Stacks | defence | none | ◐ (Effects rule 9a) | Art | every Earth build |
| 8. Survival | Homeward Step, Alarm Array, Challenge Letter | Escape in the loadout; home is never blind; a hunter becomes an appointment | Escape; rule | survival | none | ○ | Technique; formation; talisman | every abode owner |
| 9. Identity | **Overbuilt Walls** | (above) | Overflow | defence | none | ○ | | |

**Identity piece:** Overbuilt Walls. Five kinds of preparation reach L4's cap with room to spare; without it, every point past 150 is waste and the build is one more "pill plus Nine Rods" kit (three builds of this run already hit 150 that way). With it, the surplus becomes the walls that make a home fight a slow death for the visitor. Removing it should cost the build a quarter of its ward strength at home (+100 of +407; see the totals below), let about a quarter more damage through, and leave its damage unchanged. The identity test that would show this on the timeline is NOT ASSESSED: no simulator this run (user decision 2026-11-11).

**Empty rungs:** none empty. Rung 4 is ordinary crit, which is a choice: the old certainty tool for slow arts (Measured Stroke, 20 s or more) is out of reach since #44 limits cooldowns to 12 s. Rung 2 is deliberately thin: the seals are slow, and the talismans' first firing is the build's only speed.

**Forms used:** Increased, More, Per, Conditional, Trigger, Timing, Overflow, Conversion, Rule swap, Cap shift (ten).

### Layer totals at Nguyên Anh (first guesses; anchors from combat.md Formulas B)

| Layer | Foreseen at home | Blind, away from home | Sources |
|---|---|---|---|
| L1 | +300 → 250 after the soft cap → ×3.50 | ×3.50 | Tree and Way W (top-end share 45 % of 739 W, some spent on formation power) |
| L2 | +60 +40 +120 +80 = 300 (cap) → ×4.00 | ×4.00 | Laid Stone (technique, 3 Way notables), Tolled Seal, two Thổ Đạo +40 [tho] notables from a second Way |
| L3 | +250 → ×3.50 (top-end gear); ×3.0 with a Thượng phẩm seal | ×3.50 | Seal weapon, flags |
| L4 | about 360 offered, 150 kept → ×2.50 | +48 (the slotted talisman only) → ×1.48 | Nine Rods 128, pill 93.6, bath 50, talisman 48, ground 40 |
| L5 | 50 + 30 + 12 = 92 → ×1.92 | 10 + 12 = 22 → ×1.22 (Steady Breath only while the pool holds 50 %) | Five Preparations, Host's Advantage, Steady Breath |
| **M** | **3.50 × 4.00 × 3.50 × 2.50 × 1.92 = 235** | **3.50 × 4.00 × 3.50 × 1.48 × 1.22 = 88** | Top-end anchor 256; typical 7.37 |

| Ward strength (`ws`) | Foreseen at home | Foreseen away, under the flags | Blind, away from home |
|---|---|---|---|
| Technique `defense_pct` | 15 | 15 | 15 |
| Tree and Way | 60 | 60 | 60 |
| Gear (100 × 0.30 × a_w, a_w about 3) | 90 | 90 | 90 |
| Hộ Sơn Trận, level 7 × 1.6 | 112 | 112 | 0 |
| Field Walls (0.5 × 60) | 30 | 30 | 0 |
| Overbuilt Walls | 100 (161.6 clipped / 1.5, capped) | 81 (121.6 / 1.5) | 0 |
| **Total** | **407** | **388** | **165** |
| Common Ward's 342.5 points become | 1,737 points: stops 94.6 %, lets 5.4 % through | 1,671: stops 94.4 % | 908: stops 90.1 %, lets 9.9 % through |

Resistance from combat-defence.md Formulas A: `R = R_w · (1 + ws/100)`, share stopped `R / (100 + R)`. Drain bills fall as `1 / (1 + ws/100)` (Formulas C). So blind and away, the build takes about 1.8 times the damage per hit it takes at home, pays bigger bills from a pool a quarter smaller, and deals about 2.7 times less.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth-led dual root, Earth (Thổ) and Water (Thủy), Earth purity 70 or more | Earth cuts formation upkeep by 0.4 % per purity point (`tho_upkeep_cut_per_purity` 0.004: 28 % at 70) and its root role is more field plots (herbs for pills). Earth purity powers the Earth buff stacks (×(1 + 0.002 × P)). Water speeds toxicity decay (`k_w · purity_water`, character-stats.md Formulas D), so more pills a year stay at full potency. A single Earth root works; the Water half is for pill volume |
| Key talents | Thần hồn (soul) for thần thức (four artifacts and ward slots); Ngộ tính for formation and alchemy skill | Formation level is capped at skill + 1 (`luyen-khi-and-tran-phap.md`), and the seal weapon alone binds 900 thần thức at Nguyên Anh |
| The Way (Đạo) | **Trận Đạo · Phong Thủy** (#65, no requirement): Trận Pháp (Overbuilt Walls, Pressing Mountain, Laid Stone ×3, Tolled Seal), Hộ Trận (Field Walls, `defense_pct`, `formation_power_pct`, `soul_res_pct`), Phù Lục (Talisman Sleeve, Primed Talismans), Động Phủ (Host's Advantage, Five Preparations, capstone Threshold Binding). Second Way: **Thổ Đạo · Bất Động Sơn** (#19): Trần Bích and Bàn Căn lines, two +40 [tho] L2 notables | Trận Đạo's facets are this build's five systems, already named in dao.md § Catalogue. Thổ Đạo takes L2 to its cap |

## Công Pháp

### Hearth-Mountain Scripture (Trạch Sơn Quyết) — main, Địa giai (tier 2)

A household manual: how to keep a mountain so that whoever climbs it arrives tired.

```json
{"id": "trach_son_quyet", "name": "Trạch Sơn Quyết", "tier": 2, "tech_kind": "main",
 "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "defense_pct", "value": 15},
             {"stat": "linh_luc_pct", "value": 20},
             {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "stake_driving_seal", "unlock_layer": 1},
               {"ability_id": "warm_stone", "unlock_layer": 3},
               {"ability_id": "mountain_press_seal", "unlock_layer": 5},
               {"ability_id": "landslide", "unlock_layer": 7},
               {"ability_id": "homeward_step", "unlock_layer": 10}],
 "passives_proposed": [{"layer": 2, "id": "laid_stone", "damage_more": 60, "scope": ["formation"], "layer_of_m": "L2"},
                       {"layer": 6, "effect": "primed_talismans"},
                       {"layer": 9, "effect": "five_preparations"},
                       {"layer": 12, "effect": "overbuilt_walls"}],
 "seal_clusters": ["quan_nhu_ba"], "origin": "authored"}
```

**Fit:** Needs key (combat passives and ability records have no field in `items_cong_phap.json`; `passives_proposed` is not a real field) · **Budget:** 15/15 + 20/20 + 15/15 = **3.0 of 3** (Địa giai `bonus_budget` 3); each line 1.0 ≤ `bonus_single_cap` 1.5. `max_realm` `nguyen_anh` covers the span. There is no Thiên giai copy, so the build stops at Nguyên Anh as specified; past it, the shipped Hậu Thổ Thiên Kinh (`thien_tho`) carries an Earth root on without the passives.

**Auxiliary (2 slots):** Long Tượng Công (`long_tuong_cong`, body, Địa giai, in the game) for health, and a free slot. A body technique names no element, so harmony is neutral.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Stake-Driving Seal (Đả Trụ Ấn) | Scripture, L1 | Physical hit; tho, physical, seal, formation, art, cheap | 1.97 | 0.03 | 2 s | — | Needs key |
| Warm Stone (Ôn Thạch) | Scripture, L3 | Heal; tho, heal, art | c_heal 4.13 | 0.05 | 4 s | own health ≤ 70 % | Needs key |
| Mountain-Press Seal (Áp Sơn Ấn) | Scripture, L5 | Physical hit; tho, physical, seal, formation, art, costly, slow | 4.65 | 0.10 | 6 s | — | Needs key |
| Landslide (Băng Nham) | Scripture, L7 | Physical hit; tho, physical, formation, art | 1.91 | 0.06 | 4 s | — | Needs key |
| Homeward Step (Quy Sơn Bộ) | Scripture, L10 | Escape; tho, escape, art | — | 0.05 | 4 s | own health ≤ 30 % | Needs key |
| Boundary-Stake Talisman (Giới Trụ Phù) | Talisman, stock 1 | Buff; tho, talisman, art | — | 0.02 | 2 s (0.5 s first, Primed) | fight time ≥ 0.5 s | Needs key |

Lint: `1 + 24 · cost + 0.25 · (cooldown − 1)` (Combat Formulas C, as this run's other sheets read it): 0.03 / 2 s → 1.97; 0.10 / 6 s → 4.65; 0.06 / 4 s → 3.19, times (1 − 0.40) for Landslide's buff charge (4 Earth stacks × 10 s × 0.010, effects.md Formulas D) → 1.91. Heal lint 1.4 × 2.95 = 4.13.

- **Stake-Driving Seal.** Effect: a Physical hit. Description: a bronze stake driven into a seal-mark on the ground, where the visitor stands.
- **Warm Stone.** Effect: heals `U × 4.13 × 4` (1,652 at Nguyên Anh) and refunds its cost when it heals (combat-defence.md rule 16). Description: the hearthstone under the bed, warm all winter.
- **Mountain-Press Seal.** Effect: a Physical hit; slot 1, the art whose L4 Overbuilt Walls reads. Description: the seal of the house pressed down with the weight of the hill behind it.
- **Landslide.** Effect: a Physical hit; grants its owner 4 Earth buff stacks for 10 s. Fired every 4 s, about 10 stacks stand: Physical damage taken dampened about 11 %, × 1.14 at Earth purity 70. Description: the terrace wall let go, on purpose.
- **Homeward Step.** Effect: escape (Combat Formulas I). Description: every path in the world bends a little toward one door.
- **Boundary-Stake Talisman.** Effect: when it fires, L4 +40 on [formation] hits for the rest of the fight (× talisman power). Under Talisman Sleeve it takes no slot. Description: grave-boundary paper nailed into the ground at the edge of the fight.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Mountain-Press Seal, Landslide, Stake-Driving Seal, Warm Stone, Boundary-Stake Talisman | Common Ward and Mountain Screen in ward slots (2 at Kết Đan) | No escape yet (layer 10). The talisman takes a slot until the sleeve |
| Nguyên Anh | 6 | Mountain-Press Seal, Landslide, Stake-Driving Seal, Warm Stone, Homeward Step, a ward in the art slot (Golden Bell or Soul-Guarding Lamp); talisman sleeved | 3 ward slots (`ward_slots_by_realm`) plus thần thức: Common Ward, Mountain Screen, Soul-Guarding Lamp | Talisman Sleeve frees the sixth slot for a second soul answer |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Threshold Flags (Môn Hạn Kỳ) | Named artifact, utility | `ky`, Cực phẩm, Kết Đan or Nguyên Anh tier | The enabler (Threshold Binding): home formations count on any foreseen ground | Needs rule |
| Seal weapon (generated) | Artifact, weapon | `an` (attack 40), Thượng or Cực phẩm, Nguyên Anh tier | L3; affixes `artifact_attack_pct`, `formation_power_pct` if rolled | Fits today |
| Armour and shield (generated) | Artifacts, ward gear and body gear | `giap`, `thuan` | Ward strength through `a_w` (shield), body defence (armour) | Fits today |
| Hộ Sơn Trận | Formation, home | In the game (`crafting_formations.json`: `defense_pct` +10 a level, max 5, `applies: home`) | Survival: +112 ward strength at level 7 with Formation Within a Formation and +60 formation power | Fits today (as a sheet stat; Combat reading it needs the `own_abode` rule) |
| Nine Rods Array (Cửu Can Trận) | Formation | Staging (first-volley) | L4 +80 × 1.6 = 128 on every art; laid at home it is a standing formation, so it counts in an ambush there | Needs key |
| Hot Spring Array (Ôn Tuyền Trận) | Formation, home | Staging (unkillable; by-root triple-fire-earth-water) | Fuel: linh lực and health regeneration on its ground | Needs key |
| Alarm Array (Cảnh Linh Trận) | Formation, home | New, levels 1–3 | A blind fight at the abode becomes an ambush; carries Taken Ground | Needs rule |
| Mountain-Root Pill (Sơn Căn Đan) | Pill | New | L4 +60 [tho] × potency: quality 2 (×1.5), `pill_effect_pct` +30 (×1.3), toxicity 20 (×0.8) → +93.6 | Needs key |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | Coating | Staging (bare-fist; 2026-11-07 receiving-hand) | L4 +50 at fine grade on Physical hits | Needs key |
| Boundary-Stake Talisman (Giới Trụ Phù) | Talisman | New | L4 +48 once fired; the only L4 a blind fight away keeps; one of the five kinds | Needs key |
| Challenge Letter (Chiến Thiếp) | Talisman, life use | New | A hunter or rival's next fight becomes foreseen, at home, within a season | Needs rule |

The Threshold Flags were cut from the founder's doorframe by the last disciple, the year the valley's vein ran dry and the house had to be left; the first time she planted them on a strange hillside, the valley's arrays stood up around her.

**Thần thức at Nguyên Anh** (`than_thuc_cost = base × 30`, item-database.md): flags 600, seal 900, shield 450, armour 150 = **2,100**, against a reference of 1,350 (talent 45, stage 1.00). So the build needs about 1.56 × the reference: talent near 60 at a late stage, or `than_thuc_pct` around +30. Four of the six equip slots.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Formation Within a Formation (keystone, capability #15) | +2 formation levels; those levels' upkeep × 2 | Hộ Sơn Trận to level 7; Earth's upkeep cut pays the double upkeep | Fits today |
| 2 | Formation power (`formation_power_pct`) notables | +8 each | Multiplies Nine Rods, Hộ Sơn, Hot Spring and Field Walls at once | Fits today |
| 3 | Damage (`attack_pct`), `attack_pct` [formation] | +8 / +12 notables | L1 | Fits today / ◐ |
| 4 | Pill effect (`pill_effect_pct`) | +8 notables | Pill potency | Fits today |
| 5 | Ward strength, ward efficiency | +8 notables | Walls and bills | Fits today |
| 6 | Pill toxicity resistance (`dan_doc_resist_pct`) | — | Keeps `P_dd` near 1 | Fits today |
| 7 | Talisman stock, Talisman power | rare / +12 | A second Boundary-Stake; its L4 | Pending keys |

### Hidden cluster idea: Quartermaster's Ledger (Quân Nhu Bạ)

Theme: preparation kept like a household (stores, arrays, pills), wider than this build. Earth affinity. Sealed: the Hearth-Mountain Scripture lists it in `seal_clusters`. Nine acupoints. Smalls: `formation_power_pct` +1.2 (×2), `pill_effect_pct` +1.2 (×2), `dan_doc_resist_pct` +2 (×2, first guess), `formation_upkeep_pct` −8. Notables: `formation_power_pct` +8, and farthest, Talisman stock +1 (the tree catalogue's rare one-off). No capability. An idea for the tree rework, not data.

## Đạo

No new Way. The build names **Trận Đạo · Phong Thủy** (#65 in dao.md § Catalogue; no requirement; facets Trận Pháp, Linh Mạch, Phù Lục, Hộ Trận, Động Phủ) and the nodes it wants, within the facet slot table (dao.md rule 10: at most 1 `major` and 2 `minor` a facet):

| Facet | `major` | `minor` | Stat notables and lines |
|---|---|---|---|
| Trận Pháp (Arrays) | Overbuilt Walls | Pressing Mountain | Laid Stone +40 [formation] ×3; Tolled Seal +40 [seal]; `formation_power_pct`, `attack_pct` [formation] |
| Phù Lục (Talismans) | Talisman Sleeve (existing) | Primed Talismans | talisman power, `talisman_ink_pct` |
| Hộ Trận (Ward Arrays) | Field Walls (existing) | — | `defense_pct`, `formation_power_pct`, `soul_res_pct` |
| Động Phủ (home ground) | Host's Advantage | Five Preparations | `formation_upkeep_pct`, `defense_pct`; capstone Threshold Binding (second host) |

The graph is not drawn and this session did not read `design/dao-ways/` (task rule).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan, early | Three items reach L4's cap at home (Nine Rods 104, pill 75, ground 40 at formation power +30): ×2.5 on every seal, Hộ Sơn at level 5 (+65 ward strength) | The Scripture to layer 7, the Alarm Array (level 1) | The cave is chosen for its vein and its narrow path; the first upkeep bill is paid with the stipend |
| Kết Đan, late | Five Preparations at layer 9: +50 L5 at home. Fights away are planned or avoided | Boundary-Stake Talisman, Iron-Sand Hand Bath, the first Challenge Letter | A rival is called to the valley and does not come. The refusal goes into the World Database |
| Kết Đan → Nguyên Anh | The tribulation is fought at home: Foreseen by rule, ground tags of the place plus `tribulation`, the laid formations count (thien-kiep.md rule 5) | — | The breakthrough no one else would risk on the road |
| Nguyên Anh | The full machine: M about 235 at home, ward strength about 407. Overbuilt Walls at layer 12, Formation Within a Formation, the Threshold Flags | Flags, Homeward Step, Talisman Sleeve | The master leaves the valley for the first time in a century, with the valley in a bag |

## Matchups

Read from the rules, not simulated (no simulator this run, user decision 2026-11-11). Enemy kinds from Combat rule 18.

| Enemy | Result at home | Result blind, away | Why |
|---|---|---|---|
| Physical/Force hitter | wins | loses or flees | Walls stop 94.6 % at home, Earth stacks dampen Physical; away, 9.9 % gets through and the pool is 25 % short |
| Elemental hitter (Fire, Cold, Lightning, Light) | wins | even | Ward strength scales every ward; Earth stacks do not help |
| Chaos dealer | wins | even | Chaos passes body shields, not resistance; the build's defence is ward resistance |
| High Physical resistance (150+ points) | even to wins | loses | Pressing Mountain's Sundered (−150 a stack) opens it at home; nothing does away |
| Linh lực drainer (Qi Disruption, soul) | even | loses | A dry pool drops every ward (combat.md rule 23). Hot Spring regeneration helps at home; away, a quarter is already gone |
| Soul-piercer | even | loses | Soul hits skip resistance; the answer is a soul ward in the sixth slot and Hộ Trận's `soul_res_pct` |
| Healer | wins | even | Sustain is king: the longer fight favours the walls; fatigue hits both equally |
| A rival preparation build at your home | wins | — | Taken Ground holds their L4 to +20 |
| **At the rival's home** | — | loses | Their Taken Ground or array holds yours; never accept a fight on someone else's mountain |

**Counter:** the Night Walker assassin (Ám Đạo Thích Khách: first strike, crit) who never climbs the mountain and waits on the road. A blind fight away from home strips L4 to one talisman, L5 to 22, ward strength from 407 to 165, and reserves a quarter of the pool; the build's only answer is Homeward Step at 30 % health. A second counter is the patient rival who refuses every Challenge Letter and lets the build's errands bring it out.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Scripture 3.0 of 3, each line 1.0 ≤ 1.5. Arts at or under the lint (1.97, 4.65, 3.19 × 0.60; heal 1.4 × 2.95). Slots: 5 at Kết Đan, 6 at Nguyên Anh, used in full with the talisman sleeved. Artifacts 4 of `equip.max_slots` 6; thần thức 2,100 at Nguyên Anh, stated as a requirement (about 1.56 × the reference) |
| Validity | PASS | Element `tho`; tier 2 (`dia`, `max_realm` `nguyen_anh`) reaches the span; bases `ky`, `an`, `giap`, `thuan` exist; Hộ Sơn Trận, Long Tượng Công and Hậu Thổ Thiên Kinh exist in data; the aux body technique names no element (neutral harmony); realm ids `ket_dan`, `nguyen_anh` |
| Stack | PASS (identity test NOT ASSESSED) | Every rung filled; rung 4 is plain crit by choice. Ten forms. Channel fit: no L5 on ticks, the L4 pieces are scoped to tags the seals carry ([formation], [tho], Physical). Layer totals above. **Identity test: NOT ASSESSED** (no simulator this run, user decision 2026-11-11). By the formulas, removing Overbuilt Walls takes ward strength at home from 407 to 307, so the Common Ward stops 93.3 % instead of 94.6 % (6.7 % through instead of 5.4 %, about a quarter more damage taken, and drain bills up by the same factor of 5.07 / 4.07), and leaves damage unchanged |
| Scaling | PASS | M about 235 at home at Nguyên Anh, against the top-end anchor 256 (92 %) and typical 7.37. INFO: ward strength 407 at home is well above what gear and W give a top-end build (about 165 here), so its fight power in a chosen fight is above the top-end anchor; not pulled back. Blind away, M about 88 against a top-end peer's 102 (the anchor without L4): the seed's "crippled" |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11): no fight input was written and nothing was run. The engine is explained from the formulas above |
| Reuse | PASS | Reused: Nine Rods Array, Iron-Sand Hand Bath, Hot Spring Array (staging), Tolled Seal (content ledger), Taken Ground and Landing Ground (2026-11-07, staged with credit), six existing Effects and Hộ Sơn Trận. Every new piece names a second home; no signature pieces |
| NPC use | PASS | Every new Effect can be `npc: true`: a sect guardian on its mountain is the archetype (Alarm Array, Taken Ground, Host's Advantage). Breakdown lines: "Overbuilt Walls: 161.6 L4 clipped → ward strength +100 (cap)"; "Five Preparations: 5 kinds → L5 +50"; "Threshold Binding: no formation counts → 25 % linh lực reserved" |
| Counterplay | PASS | The Ám Đạo assassin on the road (blind fight away), the drainer, and the rival who refuses the letter |
| Originality | PASS | Names and lore are original (Hearth-Mountain, Threshold Flags, Quartermaster's Ledger). Formation flags, wind-bells and challenge letters are generic xianxia objects, not lifted from any work |

## Fight Results

NOT ASSESSED. No simulator this run (user decision 2026-11-11): no `.fight.json` was written and `fight_calc.py` was not run. Every number in this sheet is read from the GDD formulas, with first-guess sizes on new pieces.

**Unmodelled (the whole fight):** the timeline, the order of the first instants (talisman at 0.5 s, Sundered at 1 s), drain-bill totals over a fight, Hot Spring regeneration against the spend of three seals, and every matchup above.

## New Concepts

- **`own_abode` ground tag.** Rule: combat.md rule 12 and the Event Engine's fight request. Bounds: one owner per place; the flags stamp it only in a foreseen fight. Breakdown: "Ground: own abode". Serves: this build; sect guardians; Hoàng Đạo (Long Ỷ) and Thần Đạo (Miếu) home-ground facets; a boss in its lair. Question: should a sect seat count as the abode of every member, or only of the elder who holds its array?
- **Raising a fight's situation.** Rule: combat.md rule 12; the Event Engine. Bounds: one step per source, owner's side only, never to foreseen from a formation. Breakdown: "Alarm Array: blind → ambush". Serves: every abode owner; Hiệp Đạo duels (the Challenge Letter). Question: may the Challenge Letter be refused without cost to the refuser's reputation?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Overbuilt Walls | Needs rule | effects.md rule 5: a layer's total before its cap, read at compile |
| Threshold Binding (Threshold Flags) | Needs rule; Needs key | combat.md rule 12: home formations count under the flags; Combat reads `applies`; ground tag `own_abode` |
| Taken Ground | Needs rule | combat.md rule 12, Formulas B: one side's L4 limited by the other's formation |
| Alarm Array | Needs rule | combat.md rule 12: a formation may raise the situation at its ground |
| Challenge Letter | Needs rule | Event Engine (#23, no GDD): a fight request whose place and situation the player sets |
| Host's Advantage | Needs key | ground tag `own_abode` |
| Mountain-Root Pill, Iron-Sand Hand Bath, Boundary-Stake Talisman | Needs key | a fight payload on pill, coating and talisman records |
| Nine Rods Array, Hot Spring Array | Needs key | combat formation records read by Combat |
| Landing Ground | Needs key | ground tag from seasons spent at a place |
| Hearth-Mountain Scripture and its five arts | Needs key | ability and passive fields in `items_cong_phap.json`; art records |
| Tolled Seal | Needs key | its record (content ledger) |
| Quartermaster's Ledger | Needs key | Talisman stock, `formation_upkeep_pct` (Pending) |
| Laid Stone, Five Preparations, Primed Talismans, Pressing Mountain | Fits today | records only |
