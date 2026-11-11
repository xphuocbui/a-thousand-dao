# The Brimming Hand (Mãn Tức Quyền)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Never cast an art. The basic attack is the only free, guaranteed channel and art speed never touches it, so the whole linh lực pool is ward. Stack basic_coef and the basic attack's cooldown, and make the slots that would hold arts do something else."
> **Direction**: The Brimming Hand: the breath a full pool would waste becomes weight in the next punch; wards fill the art slots (chosen by the session under the run's override).
> **Realm span**: Luyện Khí to Hóa Thần · **Power level**: top-end (from Nguyên Anh; above typical but below the top-end anchor before it) · **Use**: player
> **Root**: Earth (Thổ), single, high purity
> **Fit** (16 new pieces): 5 Fits today · 8 Needs key · 3 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: the technique's passives and Effects are outside `bonus_pool`, so only its stat lines can be checked; The fight: `fight_calc.py` reports CONSTANT_DRIFT on 31 of 60 constants and runs the retired ward model, and the paper model `bare-fist.sim.py` could not be run in the unattended session, so the fight rests on hand-worked numbers)

## Directions considered

- **The Brimming Hand (Mãn Tức Quyền)** (chosen). Lenses: *spend the overflow* and *turn a rule into a promise*. The basic attack is the only channel; the regeneration a full pool cannot hold is banked into the next punch; wards fill the art slots. It is the strongest for a min-max seed because it finds a second use for the one resource this build has in surplus (regeneration it never spends) and makes ward strength and ward efficiency count as damage.
- **The Hundred Stances Unmade (Bách Thế Quy Phác)**. Art slots hold "stances" that rewrite the basic attack (convert it, add a hit, apply a status), a support-gem system for the fist.
  Not picked: it needs a new kind of slot piece that every system must learn, and the seed already works with what the game has (wards in art slots).
- **The Mortal's Duel (Phàm Nhân Quyết Đấu)**. The surprise reading: burn the enemy's linh lực until both sides have only the basic attack, then win the fistfight you built for.
  Not picked: it overlaps the Dry Well (dry-well) and depends on the enemy's pool size, so the fist is the payoff, not the build.

## The Spine

- **The channel:** the basic attack (Physical; tags physical, hit, art, basic; plus [earth] through Elemental Fist). It uses L1 to L5 and crit. Caps that matter: L5 100 (the build reaches 42–62), crit 0.50 and ×3.0, `cooldown_min` 0.5 s on basic speed (new rule), Stored Breath's own +1.2.
- **The enabler:** Closed Hand Vow (Bế Thủ Thệ): with no damaging art slotted, ward efficiency +100. It opens a ward that costs a third less to run and a pool that is never spent on casting; it closes every damaging art, damaging talisman and cast ward.
- **The loop:** wards are up from t = 0. The fist strikes every 0.5–1 s. Each pulse, the regeneration a full pool cannot hold is banked and the next punch spends it.
- **The engine:** Stored Breath (Tàng Tức) turns overflow into coefficient. Only a full pool overflows, so every point a ward bills is a point the fist loses. Ward strength and ward efficiency, which cut drain bills, become damage; regeneration becomes damage. Defence and offence drink from the same breath.
- **The sacrifice:** no arts at all: no burst, no curse, no heal art, no cleanse art, no escape unless it takes a slot. L5 stays half empty (no "while" Effect fits a build that never casts, beyond a full pool's). One damage type, Physical, so a Physical-warded foe takes it worse.
- **The arc:** at Luyện Khí it is a mortal's fist behind a good ward: it wins slowly (about 30 s against a typical cultivator) and the ward eats most of the overflow. At Kết Đan the vow and the auras arrive and it crushes ordinary fights in two punches, but a top-end caster still outraces it. From Nguyên Anh the ward is cheap enough that the breath brims every pulse, the fist strikes first (0.667 s) and it races the top-end anchor and wins. At Hóa Thần its damage per second matches the top-end anchor at no cost.

## The Legend

On the Grey Pass road the porters' guild carried salt and stone for the sects, and the sects forbade them spells. Their founder, a quarryman who learned to cultivate by listening at a sect's wall, turned that ban into a way: a breath let out is a load set down. His porters never cast. They held their qi in, behind a ward, and when it overfilled they let it out through the fist.

The sects called it mortal boxing and laughed until a porter held the pass alone against a raiding party for a day and a night, never once raising a spell, and walked down with every raider's teeth in a bag. The founder himself died on that road years later, facing a drinking-sect that pulled the qi out of his meridians faster than he could breathe it in. His ward fell with nothing spent, and his fist, empty of breath, could not finish them. The guild still teaches that death in its first lesson.

Today the Uncarved Stone Fist (Phác Thạch Quyền) passes from porter to porter, and a Thiên giai copy is said to lie under the old guildhall's millstone. Art-sects hunt its users for shaming them; drinking-sects hunt them because they are the one prey that never runs dry on its own.

## How It Fights

The cultivator stands still behind three or four layered wards and punches. Nothing fires at t = 0; the first punch comes at 0.667 s at Nguyên Anh, before most arts. Each pulse, if the ward paid little, the pool brims and the overflow becomes the weight of the next punch. Against ordinary enemies the first or second punch ends it. Against a top-end caster, the shields soak the first volley, the second punch carries the banked breath, and the third lands with Steady Breath back on.

**Signature moment:** a top-end caster's first art lands on a wall of shields, and a breath later a single bare punch, heavier for everything the cultivator did not spend, ends the fight. The Breakdown reads: "Stored Breath +0.95 → basic coefficient 3.15".

## Enabler

**Closed Hand Vow (Bế Thủ Thệ)**: Effect, tier `enabler`. *While you have no damaging art slotted, your ward efficiency is +100.* Reads: slots and loadout (compile). Payload: `ward_efficiency_pct` +100. Closes: you cannot slot damaging arts, damaging talismans or cast wards (enforce a closing rule at compile). Escape arts, non-damaging utility and standing wards stay legal.

- **Where:** the Uncarved Stone Fist, Huyền layer 9 and Thiên layer 12 (a technique is a listed enabler host). It would also fit a Thể Đạo capstone.
- **Opens:** at Nguyên Anh, ward efficiency 200 → 300 cuts the Common Ward's drain rate from 0.0364 to 0.0273 and the duel loadout's reservation from 0.106 to 0.085 of the pool.
- **Closes:** the whole art game. It is all-or-nothing for the NPC generator: a "fist sect" archetype takes it or does not.
- **Fit:** Fits today.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Heavy Knuckle (Trọng Quyền) | +X to the basic attack's coefficient (`basic_coef_add`; small +0.04, notable +0.25, technique +0.3/+0.6, Đạo notable +0.5) | Flat base | basic | none | ○ | Technique, Thể Đạo Không Thủ, knuckle rings, cluster | starter-blade, martial NPCs |
| 1 Base | **Stored Breath (Tàng Tức)** | Overflow banks +0.10 coefficient per 1 % of maximum linh lực, spent by the next basic attack that lands; cap +1.2 | Overflow | basic | none | ○ | Technique (Huyền L5, Thiên L8); Thể Đạo Không Thủ major | unkillable, Guide Hound-type owners, full-pool ward casters |
| 2 Rate | Basic attack speed (Khoái Quyền) | `basic_speed_pct` divides `basic_cooldown`, floor 0.5 s; +20 technique, +15 per Đạo notable, +15 rings, +12 cluster | Increased (timing) | basic | none | ◐ (Modifier System row Pending) | Technique, Thể Đạo, rings, cluster | starter-blade, per-hit-ward breakers |
| 3 L1 | Basic attack damage (Bình Kích); `attack_pct` [earth] via Elemental Fist; `attack_pct` | +2 % / +12 % [basic]; [earth] and untagged rows | Increased | basic | L1 | ○ / ● | Tree, Thổ Đạo | any fist build |
| 3 L2 | Worn Knuckles (Chai Quyền) | `damage_more` [basic]: technique +40 (Huyền) / +80 (Thiên), Đạo notables +40 each | More | basic | L2 | ○ (Fits today) | Technique, Thể Đạo Không Thủ | starter-blade |
| 3 L3 | Weapon artifacts | Artifact attack against the realm base | Flat | any | L3 | ● | Quarry-Master's Knuckle Rings, a generated `an` seal | every build |
| 3 L4 | Iron-Sand Hand Bath; Stone-Marrow Pill; Ringing Ground (Nine Rods Array) | +25–50 [basic, art] body hits; +60 [basic]; +80 [art] (the basic attack carries `art`) | More | basic | L4 | ○ (reused, new, reused) | Coating, pill, formation | any thể tu; starter-blade; first-volley, dry-well |
| 3 L5 | Steady Breath [basic]; Full Sea (Mãn Hải); Bare Rack | +12 at ≥ 50 % linh lực; +30 at ≥ 80 %; +5 per empty art slot, cap +20 | Conditional, Conditional, Per | basic | L5 | ● / ○ / ● | Rings; tree keystone; tree or Way | sword, ward casters; cheap-art builds; companions |
| 4 Crit | Crit chance and damage | To 0.45–0.50 and ×2.1–2.3 | Increased | basic | none | ● | Tree, gear | every hit build |
| 5 Reach | `resist_pen_pct` [physical]; `accuracy_pct` | −60 points at Nguyên Anh; accuracy against evaders | Flat | basic | none | ◐ | Tree, Thổ Đạo | every Physical build |
| 6 Past the cap | Still Water | The same overflow heals at half (it reads the overflow whole, as Stored Breath does) | Overflow | survival | none | ● | Tree or Way | ward casters, healers |
| 7 Fuel (flow) | `linh_luc_regen_pct`; Quiet Channels (Tĩnh Mạch); `ward_efficiency_pct`; Closed Hand Vow | Regeneration (log curve); +0.5 pp per art slot with no art, cap +3; cheaper bills; +100 we | Increased, Per, Increased, Conditional | flow → Stored Breath | none | ● / ○ / ● / ○ | Tree, cluster, gear, technique | unkillable, pacifist |
| 8 Survival | Wards in art slots; Settled Dust (Lắng Trần); Unyielding Breath | Layered wards; +1 Earth buff stack for 4 s per landed punch; refuse Down once (−15 % health) | Rule (existing), Trigger, Keystone | survival | none | ● / ○ / ● | Slots; Thổ Đạo Trần Bích, rings; tree | ward casters; starter-wall; body builds |
| 9 Identity | Stored Breath | (above) | Overflow | basic | none | ○ | | |

**Identity piece:** Stored Breath. Without it the build is a strong fist behind good wards; with it, every point of ward strength, ward efficiency and regeneration is also fist, and the build's defence and offence become one stack. Hand-worked at Nguyên Anh it is +0.95 coefficient each pulse when nothing is billed (+29 % to the basic attack's damage per second) and it moves the kill against the top-end anchor from 2.0 s to 1.33 s in about half the rolls. `fight_calc.py --without stored_breath_approx` lowers the build's damage by 24 % (typical) to 39 % (top-end) but flips no result, because both sides die inside the first two seconds on that tool's retired model.

**Empty rungs:** none. Two are thin by choice: **L5** (42–62 of 100: only what a full pool and empty slots give, a sacrifice of never casting) and **reach** (one damage type: Physical; conversion notables from the Modifier System are the patch, not a fix).

### Layer totals at Nguyên Anh (foreseen fight, duel loadout)

| Layer | Points | Multiplier | Sources |
|---|---|---|---|
| L1 | 300 raw (250 after the soft cap) | ×3.50 | Tree W (`attack_pct`), Bình Kích [basic], [earth] rows, Thiên technique `attack_pct` 9 |
| L2 | 280 | ×3.80 | Worn Knuckles: technique +80, Không Thủ notables 3 × 40; Thổ Đạo [earth] notables 2 × 40 |
| L3 | 250 (cap) | ×3.50 | Quarry-Master's Knuckle Rings and one generated `an` seal |
| L4 | 150 (cap; 190 offered) | ×2.50 | Iron-Sand Hand Bath +50, Stone-Marrow Pill +60, Nine Rods Array +80. Ambush: 110 (×2.10). Blind: 0 |
| L5 | 62 / 32 / 20 | ×1.62 / 1.32 / 1.20 | Full pool (Steady 12 + Full Sea 30 + Bare Rack 20 with four empty slots) / pool 50–80 % / below 50 % |
| **M** | | **188.6** full pool; 153.8; 139.7 | Top-end anchor 256, typical 7.37. Blind duel: 75.4 |

Base: coefficient 2.2 (1.0 + technique 0.6 + Không Thủ notable 0.5 + tree 0.1) plus Stored Breath's bank; cooldown 0.667 s (+50 %); crit 0.45 × 2.1.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth (Thổ), single element, purity 80 or more | Elemental Fist gives the punch [earth], so Earth L1 and L2 lines apply; Earth buff stacks (Settled Dust) dampen Physical damage taken at ×(1 + 0.002 × purity); the Hậu Thổ methods are Earth. Variant: Earth-Metal, for Metal's +1.2 % Physical damage dealt per buff stack |
| Key talents | Physique (căn cốt) high; Comprehension (ngộ tính) good; Divine sense (thần thức) fair | Physique: health, block +0.1 per point, body technique strength. Comprehension: technique mastery (the passives live deep in the technique). Thần thức: 1.75 × the realm's reference gives the extra ward slot the build fills with Soul-Guarding Lamp |
| The Way (Đạo) | Thể Đạo (the Undying Body), Không Thủ facet (Bare Hands); second glimpse Thổ Đạo (Unmoving Mountain), Trần Bích and Sơn Thể facets | Không Thủ holds Heavy Knuckle and basic speed notables, Worn Knuckles, Quiet Channels and Stored Breath. Trần Bích holds Settled Dust; Sơn Thể adds block |

## Công Pháp

### Main: Hậu Thổ Địa Quyết → Hậu Thổ Thiên Kinh (in the game)

The Earth main methods (`dia_tho`, tier 2 to Nguyên Anh; `thien_tho`, tier 3 to Hóa Thần). Before Foundation Establishment, any generated Earth Huyền main (for example a "Bàn Thạch Quyết"). Their bonuses (`linh_luc_pct`, `defense_pct`, `tam_ma_resist_pct`) all feed the ward. Their empty `abilities` list costs this build nothing: it casts no art. **Fit:** Fits today.

### Uncarved Stone Fist (Phác Thạch Quyền) — body, Huyền giai; Thiên giai copy Phác Thạch Quyền Kinh

"A breath let out is a load set down."

```json
{"id": "phac_thach_quyen", "name": "Phác Thạch Quyền", "tier": 1, "tech_kind": "body",
 "names": [], "layers": 9,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "defense_pct", "value": 10}],
 "abilities": [], "seal_clusters": ["porters_shoulder"], "origin": "authored"}
{"id": "phac_thach_quyen_kinh", "name": "Phác Thạch Quyền Kinh", "tier": 3, "tech_kind": "body",
 "names": [], "layers": 15,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "defense_pct", "value": 15},
             {"stat": "linh_luc_pct", "value": 20}, {"stat": "attack_pct", "value": 9}],
 "abilities": [], "seal_clusters": ["porters_shoulder"], "origin": "authored"}
```

Passives (no field in `items_cong_phap.json` yet): Huyền L1 Heavy Knuckle +0.3, L5 Stored Breath, L7 Worn Knuckles +40, L9 Closed Hand Vow. Thiên L1 Heavy Knuckle +0.6, L4 Worn Knuckles +80, L6 `basic_speed_pct` +20, L8 Stored Breath, L12 Closed Hand Vow. **It teaches no art.**

**Fit:** Needs key · **Budget:** Huyền 15/15 + 10/15 = 1.67 of 2; Thiên 1.0 + 1.0 + 1.0 + 0.6 = 3.6 of 4; every line ≤ 1.5. Passives and Effects are outside `bonus_pool`: NOT ASSESSED.

### Second auxiliary: Kim Cang Thể (Huyền, to Kết Đan) → Long Tượng Công (Địa, to Nguyên Anh) (in the game)

Health and ward strength, then health and damage. At Hóa Thần the slot is open (no Thiên giai body or Metal secret art exists yet).

## Arts

None, by design and by vow. The art slots hold wards (below). An escape art is legal under Closed Hand Vow but costs a slot and linh lực; the build carries none and relies on Unyielding Breath.

## Loadout by Realm

Art slots by realm 3 / 4 / 5 / 6 / 7; free ward slots 1 / 1 / 2 / 3 / 4, plus 1 from thần thức from Nguyên Anh. Reservation is after reservation efficiency and ward efficiency (combat-defence.md Formulas C).

| Realm | Ward slots | Art slots (in order) | Reserved | Note |
|---|---|---|---|---|
| Luyện Khí | Common Ward | Mountain Screen, Thousand-Layer Cloud, empty | 0.09 | The fist and a good ward. Bills eat most of the overflow |
| Trúc Cơ | Common Ward | Mountain Screen, Thousand-Layer Cloud, Clear Heart Ward, empty | 0.17 | Closed Hand Vow arrives (Huyền layer 9); Steady Breath on the rings |
| Kết Đan | Common Ward, Qi-Scattering Robe | Mountain Screen, Thousand-Layer Cloud, Iron Shirt, Clear Heart Ward, Soul-Guarding Lamp | 0.41 | Road loadout: every art slot is a ward; Quiet Channels at +2.5 pp |
| Nguyên Anh (road) | Common Ward, Qi-Scattering Robe, Fire-Shunning Veil, Soul-Guarding Lamp | Mountain Screen, Thousand-Layer Cloud, Iron Shirt, Clear Heart Ward, empty, empty | 0.29 | Saved blind loadout. Block 461 points per hit, evade 0.31 |
| Nguyên Anh (duel) | same | Mountain Screen, Thousand-Layer Cloud, empty × 4 | 0.085 | Foreseen fight against a known top-end foe: pool as ward, Bare Rack +20 |
| Hóa Thần | Common Ward, Qi-Scattering Robe, Fire-Shunning Veil, Soul-Guarding Lamp, Clear Heart Ward | Mountain Screen, Thousand-Layer Cloud, Iron Shirt, empty × 4 | 0.21 | Clear Heart moves to a ward slot; Bare Rack at its cap |

Every ward named is in combat-defence.md Formulas H and passes its price check there.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Quarry-Master's Knuckle Rings (Thạch Tượng Quyền Hoàn) | Named artifact, weapon | New base `quyen_hoan` (attack 35, defence 5, thần thức 10), Cực phẩm, by realm | `basic_coef_add` +0.3, `basic_speed_pct` +15, `artifact_attack_pct` +30; carries Steady Breath [basic] and Settled Dust. Cheap in thần thức, which goes to ward gear | Needs key |
| A generated seal (`an`) | Artifact, weapon | Existing base, Thượng–Cực phẩm | Second weapon for L3 | Fits today |
| Two ward-gear pieces (`thuan` shield, `chuong` bell) | Artifacts, ward gear | Existing bases | Artifact defence feeds ws and we (gear term 0.30 × a_w), which cut drain bills: here that is damage too | Fits today |
| Body armour (`giap`, body_gear) | Artifact, body | Existing base | Block 12 per a_b and a body shield 0.60 per a_b | Fits today |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | Coating | Prepared | L4 +25 to +50 [basic, art] on body hits | Needs key |
| Stone-Marrow Pill (Thạch Tủy Đan) | Pill | Prepared (foreseen, ambush) | L4 +60 [basic] for one fight; toxicity | Needs key |
| Nine Rods Array (Cửu Can Trận) | Formation | Prepared (foreseen) | Ringing Ground L4 +80 on [art] hits; the basic attack carries `art` | Needs key |

The knuckle rings' history: four iron rings worn smooth by a quarry master who split stone by hand for sixty years and never learned a spell; his widow sold them to the guild for the price of one coffin.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | `linh_luc_regen_pct` nodes | +0.15 small, +1 notable | Flow is fist: every pp of regeneration is up to +0.1 coefficient a pulse, on a log curve | Fits today |
| 2 | `ward_efficiency_pct`, `defense_pct` | +1.2 / +8 | Cheaper bills = more overflow, and a stronger ward | Fits today |
| 3 | Porter's Shoulder (Phu Kiên) cluster | below | Seals with the technique | Needs key |
| 4 | Basic attack damage (Bình Kích), `attack_pct` | +2 / +12 [basic]; +1.2 / +8 | L1 | Needs key / Fits today |
| 5 | Full Sea (Mãn Hải) keystone | L5 +30 [basic] while linh lực ≥ 80 % of usable | The full-pool L5 | Needs key |
| 6 | Unyielding Breath keystone | Refuse Down once; −15 % health | One more punch in a race | Fits today |
| 7 | Crit chance and damage; `resist_pen_pct` [physical]; health | catalogue | Hits and reach | Fits today |
| 8 | Bare Rack | L5 +5 per empty art slot, cap +20 | Only once the ward is enough (Nguyên Anh duel, Hóa Thần) | Fits today |

### Hidden cluster idea: Porter's Shoulder (Phu Kiên)

Theme: the breath you do not spend (wider than one build: ward casters and companion owners who cast little read it too). Earth affinity. Sealed: Uncarved Stone Fist lists it in `seal_clusters`. Eight acupoints. Smalls: `basic_coef_add` +0.04 (×2), `linh_luc_regen_pct` +0.15 (×2), `attack_pct` [basic] +2, `ward_efficiency_pct` +1.2. Notables: `basic_speed_pct` +12 and, farthest, Quiet Channels. No capability. An idea for the tree rework, not data.

## Đạo

No new Đạo. Pieces wanted from two in the catalogue (dao.md § Catalogue; this session did not read `design/dao-ways/`):

- **Thể Đạo, Không Thủ (Bare Hands):** stat-line notables `basic_coef_add` +0.5 (×2) and `basic_speed_pct` +15 (×2) (both need the keys in the Way's `theme_stats`); `attack_pct` [basic] smalls; Worn Knuckles ×3; Quiet Channels as a `minor`; Stored Breath as the facet's `major`. Ngọc Tủy (Jade Marrow) for health regeneration.
- **Thổ Đạo, Trần Bích (Dust Wall) and Sơn Thể (Mountain Body):** Settled Dust as a `minor`; `block_rating`, `resist_pct` [physical] and `attack_pct` [earth] lines.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Luyện Khí | A slow, safe brawler: beats a typical cultivator in about 30 s with half its health left | Huyền Uncarved Stone Fist (Heavy Knuckle, Stored Breath at layer 5), Common Ward, two shields | A porter's apprentice, barred from spells |
| Trúc Cơ | Faster, safer | Closed Hand Vow; knuckle rings; Thể Đạo glimpse | Takes the vow: never to cast |
| Kết Đan | Ends ordinary fights in two punches (about 1.5 s); still loses the race to a top-end caster | Iron Shirt and every art slot a ward; basic speed +30 | Holds a pass alone |
| Nguyên Anh | Strikes first (0.667 s), soaks the volley, wins the race against the top-end anchor | Thiên copy (the millstone inheritance), Full Sea, duel loadout | Hunted by art-sects for shaming them |
| Hóa Thần | Damage per second at 0.96 of the top-end anchor, at no cost, behind five ward slots | Bare Rack at cap, basic speed +70 | Faces a drinking-sect, as the founder did |

## Matchups

Hand-worked from the GDD formulas (combat.md A, A2, B, C, E; combat-defence.md A, A2, B, C) at Nguyên Anh, duel loadout unless named. Expected values over crit; not a simulation.

| Enemy | Result | Why |
|---|---|---|
| Typical (any type) | Wins in 0.667 s (one punch) | Punch 1 deals about 6,900 after their 557-point ward and breaks it (bill 4,290 against a 2,738 pool), so the unpaid share lands too. Their hits stay under its block and shields |
| Top-end anchor, Physical art caster | Wins at 1.33 s (about half the rolls) or 2.0 s | Shields (4,766) soak the 1.0 s and 1.25 s hits; punch 2 carries Stored Breath (+0.95); three punches total 11,150 against their 8,320 health. Ends with about a third of its health |
| Top-end, Fire caster | Wins, more easily | Fire-Shunning Veil adds 900 Fire points at ws 200 |
| Thể tu (block, body shield, Physical resistance) | Wins in one or two punches | A punch is far larger than its block; its default ward breaks on the first |
| Physical wall (rule 18: +300 Physical points) | Wins, slower | About −15 % damage at top end; trivial at typical tier |
| Drainer (Qi Disruption), ordinary or top-end | Wins the race | It kills before the second drain batch lands (first drain art at 1.875 s) |
| A drainer boss or any long fight against Qi Disruption | Even to losing | The burn outruns regeneration (about 2,580 a pulse after Force resistance against 322 regenerated), so no overflow and soon no ward |
| Evade build at the cap (0.40) | Even | Two punches in five miss; the bank waits for the next that lands. Answer: accuracy |
| Soul piercer | Even | Soul skips every ward. Soul-Guarding Lamp in the fourth ward slot |
| Top-end caster at Kết Đan | Loses | At Kết Đan its damage per second is 0.24 of the top-end anchor's; the build blooms late |

**Counter:** a drinking-sect: a high-pool foe that carries Qi Disruption (Combat rule 18's "drains linh lực hard") and is built to last. It burns the pool faster than the build breathes, so Stored Breath never fires and the ward falls with nothing spent, exactly as the founder died. The build's answers are partial: Qi-Scattering Robe (Force resistance applies to Qi Disruption), Clear Heart Ward's cleanse (a quarter of every debuff batch each pulse), and killing it before the second batch.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique stat lines pass: Huyền 1.67 of 2, Thiên 3.6 of 4, each ≤ 1.5. Slots: art slots used ≤ 3/4/5/6/7, ward slots ≤ 1/1/2/3(+1)/4(+1); reservation ≤ 0.41 (cap 0.9); artifacts 6 of 6. No arts, so no art lint applies. **Not assessed:** the technique's passives and its three Effects are outside `bonus_pool`, which is the only budget the GDD defines |
| Validity | PASS | `dia_tho`, `thien_tho`, `kim_cang_the`, `long_tuong_cong` exist; Huyền `max_realm` ket_dan, Thiên hoa_than reach the span; body techniques name no element, so harmony is neutral; every ward is in combat-defence.md Formulas H; bases `an`, `thuan`, `chuong`, `giap` exist; `quyen_hoan` is new (Needs key) |
| Stack | PASS | Nine rungs filled; L5 and reach thin by choice. Forms: Flat base, Overflow, Increased, More, Conditional, Per, Trigger, Rule change, Keystone. Nothing targets a layer the basic attack lacks (L5 applies to hits). Identity test: hand-worked, removing Stored Breath moves the kill against the top-end anchor from 1.33 s to 2.0 s and cuts the fist's damage per second by 22 % with a full pool; in `fight_calc.py` it lowers damage by 24–39 % but flips no result |
| Scaling | PASS | M with a full pool 188.6 at Nguyên Anh (top-end anchor 256, typical 7.37); damage per second 4.25 coefficient × 188.6 × crit 1.495 = 1,198 U against the anchor caster's 1,659 (0.72), at no cost and with 4,766 of shields; Hóa Thần 0.96. **INFO:** at Kết Đan 0.24 and at Luyện Khí about typical: below the top-end anchor before Nguyên Anh, as the arc says |
| The fight | NOT ASSESSED | `fight_calc.py --selftest` passes but prints CONSTANT_DRIFT on 31 of 60 constants and models the retired ward (pass and drain shares, body guard), a fixed 1 s basic attack and no overflow. Its matrix: wins against typical at Nguyên Anh (1.0 s) and Kết Đan (1.0 s), loses to top_end at both (t = 1.0 s, a double knockout lost on overkill at Nguyên Anh). The paper model `bare-fist.sim.py` (on the canonical #44 simulator) is written but could not be run: the unattended session had no approval to run a new script. The results above are hand-worked |
| Reuse | PASS | Reused: Nine Rods Array (staging), Full Sea and Bình Kích (tree catalogue), Iron-Sand Hand Bath (2026-11-07 ledger), Steady Breath, Bare Rack, Elemental Fist, Still Water, Unyielding Breath (effects.md), nine catalogue wards, four techniques in the game. Every new piece names a second home; one signature (the named knuckle rings) |
| NPC use | PASS | Every new Effect reads compile values or a hit or overflow event and needs no input; Closed Hand Vow is one all-or-nothing choice for a fist-sect archetype. Breakdown lines: "Stored Breath +0.95 → basic coefficient 3.15"; "Closed Hand Vow: ward efficiency +100"; "Quiet Channels +3 pp regeneration (6 slots)" |
| Counterplay | PASS | Drainer with a big pool (Qi Disruption, Combat rule 18); evade at the cap; soul piercer; a top-end caster before Nguyên Anh |
| Originality | PASS | Names checked against known novels and games: none taken. The porters' guild, Grey Pass and the founder are invented; "uncarved stone" borrows a general Daoist image, not a work |

## Fight Results

Input: `bare-fist.fight.json` (Nguyên Anh) and `bare-fist.ket-dan.fight.json` (Kết Đan). Observations from `fight_calc.py`, a paper model on drifted constants and the retired ward model, so they are recorded, not trusted.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical, Nguyên Anh | 0 | win | 1.0 s | never | none |
| typical, Hóa Thần | 1, 2 | win | 1.0 s | never | none |
| top_end, Nguyên Anh | 0 | loss (double knockout, lost on overkill) | 1.0 s | 1.0 s | none |
| top_end, Hóa Thần | 1, 2 | loss | 1.0 s | 1.0 s | none |
| typical, Kết Đan | 0, 1 | win | 1.0 s, 3.0 s | never | none |
| typical, Hóa Thần (from Kết Đan) | 2 | loss | 1.0 s | 1.0 s | none |
| top_end, Kết Đan | 0, 1, 2 | loss | 1.0 s | 1.0 s | none |

`--without stored_breath_approx` at Nguyên Anh: same results; damage to typical 45,043 → 34,240, to top_end 24,982 → 15,244.

**Hand-worked race at Nguyên Anh, against the top-end anchor** (Physical caster, art speed +60, crit 0.5 × 2.0, resistance 1,500, health 8,320):

| t (s) | Event | Bare fist | Enemy |
|---|---|---|---|
| 0.667 | Punch 1 (coefficient 2.2, M 188.6) | | −2,647 (crit −5,611); ward bill 822 |
| 1.000 | Pulse: overflow 322 → bank +0.95. Their basic attack | Shields −1,762 (crit −3,524); bill 526 | |
| 1.250 | Their quick art (1.77) | Shields −3,167 (crit −6,334); bill 920; pool about 900 of 3,067 | |
| 1.333 | Punch 2 (coefficient 3.15, M 139.7 with the pool under 50 %) | | −2,816 (crit −5,965); total about 8,200: dead in about half the rolls |
| 2.000 | Punch 3 (coefficient 2.2); their basic attack | about 2,900 health left | dead (total about 11,150) |

**Unmodelled** (by `fight_calc.py`): Stored Breath (approximated as L5 +40 while full), basic speed, layered wards and their block, evade, shields and reservation, Closed Hand Vow, Quiet Channels, Settled Dust, Still Water, Unyielding Breath, Elemental Fist. The hand-worked race models all of them except Still Water and Quiet Channels' log-curve detail.

## New Concepts

None beyond keys and one Effects timing (below). The build's slot idea (wards in art slots) is already a rule (combat-defence.md rule 5).

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| `basic_coef_add` (Heavy Knuckle) | Needs key | Stat List row (op F, target basic attack); combat.md Formulas C to read `basic_coef + Σ basic_coef_add` for the basic attack only, never the art lint |
| `basic_speed_pct` (Basic attack speed) | Needs rule | combat.md rule 13 and Formulas A2: `basic_cooldown` divided by it, floor `cooldown_min`; companion unchanged; the Modifier System's Pending row gets the key |
| Stored Breath | Needs key, Needs rule | `basic_coef_add` as payload; effects.md rule 8: a payload held until the owner's next named event |
| Linh lực shares against the usable maximum | Needs rule (clarification) | effects.md rule 5 and combat.md rule 13 guards: read against `qi_max · (1 − Σ reserved)` |
| Uncarved Stone Fist | Needs key | Combat passives and Effects on technique records (no field yet) |
| Quarry-Master's Knuckle Rings; base `quyen_hoan` | Needs key | A new artifact base |
| Stone-Marrow Pill; Iron-Sand Hand Bath; Nine Rods Array | Needs key | Fight payloads for pills, coatings and combat formations |
| Full Sea | Needs key | Tree catalogue keystone given a size: L5 +30 [basic or any hit] while linh lực ≥ 80 % |
| Thể Đạo Không Thủ, Thổ Đạo Trần Bích pieces; Porter's Shoulder | Needs key | Keys in the Way's `theme_stats`; a cluster idea for the tree rework |
