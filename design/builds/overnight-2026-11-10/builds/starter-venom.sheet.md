# The Quiet Vine (Tĩnh Đằng Độc Kinh)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A new player's poison build: apply, wait, outlast. Teaches ticks, element stacks and cleansing (tick caps are retired). Has a regeneration safety net.
> **Direction**: A, "The Quiet Vine" (see Directions considered)
> **Realm span**: Qi Refining (Luyện Khí) to Core Formation (Kết Đan) · **Power level**: ordinary · **Use**: player (starter)
> **Fit**: mostly Needs key (arts, technique, pill, Đạo lines); Needs rule: Patient Venom, Seeds Left Behind, Root Drinks the Rot; Fits today: root, main technique, weapon and vest
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the technique's bonus budget, because its combat passives are not in `bonus_pool`; arts, slots and artifacts did pass)

## Directions considered

Chosen: **A. The Quiet Vine (Tĩnh Đằng)**: Wood Poison stacks laid in a few big, long batches, with the build's own regeneration carrying it through the wait. It is the one that teaches all three lessons (ticks, element stacks, cleansing) with ordinary pieces and one visible counter, which is what a starter needs.

Not picked:
- **B. The Thorn Hide (Kinh Bì Độc)**: poison only through Thorns (attackers gain Poison when they hit you), a body-first build. Needs a new reactive Effect and teaches nothing until the player is already being hit, so it is a poor first lesson.
- **C. The Grave Garden (Mộ Viên)**: a standing Corpse Rot from t = 0 with a linh lực reservation. It is the Burial Shroud's engine, needs an enabler, and a starter should not start with a reservation.
- **D. The Hollow Sting (Không Độc)**: Poison plus Spillover to starve the enemy's ward. Strong, but it is an anti-ward specialist, not a first poison build. It stays as an upgrade.

## The Spine

- **The channel:** Tick (Poison, Chaos, `c_tick` 0.019 per stack). Uses L1 to L4; L5 is empty on purpose (L5 touches only hits). Poison has no stack cap, no duration cap and no tick cap (all retired in #44); it skips evade and block, passes every shield by default, and is cut only by Chaos and all-resistance. Each batch has its own timer.
- **The enabler:** none. A stack of what exists, plus one new art family.
- **The loop:** Thorn Seed lays a batch every 3 s, Rot Bloom lays a big 20 s batch every 6 s, Weeping Sap heals and feeds regeneration every 7 s. Then wait while the stacks tick.
- **The engine:** Long, large batches overlap. Each stack is a separate timer, so the tick total climbs for the first ~20 s, and the build's regeneration (Weeping Sap, Watched Rot, Hot Spring Array) keeps linh lực and health up until it does. Dropping Rot Bloom turned a 38 s win into a 63 s grind at Foundation (identity test).
- **The sacrifice:** burst. The first 10 s do almost nothing, and a cleanser erases the whole plan. The build refuses to fix either: it answers a cleanser with Seeds Left Behind and by changing the plan, not by adding hit damage.
- **The arc:** Luyện Khí: two arts and a lesson (stacks and waiting). Trúc Cơ: Rot Bloom, the big batch. Kết Đan: Venom Tithe, Patient Venom, and Spillover or Withering as the player's first real choice.

## The Legend

Rice-paddy herbalists of the lowland villages kept a bitter vine, the quiet vine, that grew along drainage ditches and killed pests slowly: a dose on a leaf, nothing for days, then a dead field of weevils. A cultivating herbalist's daughter found the dose could be given to a man. Her sutra never grew fast, and that was its point: it asked only that you stay alive long enough.

Those who walk it now are patient, thin and slightly yellow about the eyes; they eat their own antidotes. Their enemies are cleansers, the pill-and-talisman sects who rinse a body in an instant, and healers, who see no reason to be afraid of a slow enemy.

## How It Fights

The build opens by planting: a seed of 10 Poison stacks, then a bloom of 24, then a sip of sap. For the first ten seconds the enemy hardly notices. By twenty, thirty or so stacks tick every pulse, nearly all of them fresh, and the enemy's ward and health fall together while the player's own regeneration holds the line. **Signature moment:** the enemy's health bar starts moving on its own, the player has not cast an art for four seconds, and their linh lực is higher than it was.

## Enabler

None. A starter should not need one.

## The Stack

Sizes on new modifiers are first guesses. Existing catalogue rows are reused by name.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Batch size | Thorn Seed 10, Rot Bloom 24 stacks (30 at Kết Đan); 0.019 per stack | art stacks | tick | none | ● stacks / ○ arts | Quiet Vine Sutra arts | any element-stack build |
| 2 Rate | Status duration (catalogue, +12 % notable) | Poison batches last longer; Rot Bloom's 20 s is the deep end | Increased | tick | none | ○ | Tree | any DoT or curse build |
| 3 L1 | Poison damage, Damage over time (catalogue) | +15 % and +12 % notables plus small nodes, about 60 points at Trúc Cơ | Increased | tick | L1 | ○ | Tree | Burial Shroud |
| 3 L2 | Rot Deepens (Thi Độc Thâm, ledger) | More tick damage with the poison tag, +20 | More | tick | L2 | ○ | Quiet Vine Sutra passive | Burial Shroud |
| 3 L2 | Patient Venom (Nhẫn Độc) | +1 % more poison tick per 4 Poison stacks on the target, cap +25; from Kết Đan | Per | tick | L2 | ○ | Đạo Mộc node | any stack builder |
| 3 L3 | Gear | Bitter-Thorn Needle (weapon) and Mossback Vest, 25 points at Trúc Cơ | Increased | any | L3 | ● | Items | everyone |
| 3 L4 | Bitterroot Pill (new), Corpse-Wax Coating (reused) | Prepared poison tick, 9 + 6 points | More | tick | L4 | ○ | Pill, coating | Burial Shroud |
| 3 L5 | none | Ticks never use L5 | n/a | n/a | n/a | n/a | n/a | sacrifice |
| 4 Certainty | none | Ticks never crit, evade or block | n/a | n/a | n/a | n/a | n/a | sacrifice |
| 5 Reach | Poison skips shields by default | Chaos damage; only Chaos or all-resistance cut it | n/a | tick | none | ● | Status Catalogue | any Poison build |
| 6 Past the cap | Spillover (reused, upgrade) | Ticks also burn linh lực | Overflow | tick | none | ○ | Đạo Venom Facet | Burial Shroud |
| 7 Fuel | Watched Rot (Quan Hủ) | +0.3 pp linh lực regeneration while the target bears 15+ Poison stacks | Conditional | any | none | ○ | Đạo Mộc node | any stack builder |
| 7 Fuel | Linh lực regeneration, art cost (catalogue) | Notables on the tree; Hot Spring Array on the ground | Increased | any | none | ● | Tree, formation | everyone |
| 8 Survival | Weeping Sap, Sap Rises, Root Drinks the Rot (reused) | Heal plus Wood stacks; stacks add healing; leech from poisoned targets | Trigger | any | none | ○ | Arts, Effects | Unkillable |
| 9 Identity | Rot Bloom and its long batch | One 24-stack, 20 s batch: the plan's centre | Timing | tick | none | ○ | Quiet Vine Sutra | signature (art); the batch rule serves any stack builder |

**Identity piece:** Rot Bloom (Hủ Hoa) with Long Roots, the long-batch passive. Without it the fight at Trúc Cơ goes from 38.3 s to 63.4 s, and the build's own pool runs dry (dry at 33.9 s).
**Empty rungs:** L5 and crit: sacrifices of the channel (ticks cannot use them). All others filled. Forms used: Increased, More, Per, Conditional, Trigger, Timing, Overflow.

| Layer | Points at Trúc Cơ | Multiplier | Sources |
|---|---|---|---|
| L1 | 60 | ×1.60 | Tree: damage, Poison damage, DoT |
| L2 | 45 (on poison arts) | ×1.45 | Rot Deepens 20, technique 25 |
| L3 | 25 | ×1.25 | Needle, vest |
| L4 | 15 | ×1.15 | Pill 9, coating 6 |
| L5 | 0 | ×1.00 | empty by channel |

Kết Đan: L1 80, L2 55 (Patient Venom adds up to +25 once the target has 100 stacks; the file folds in 10), L3 40, L4 20.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood, middling purity (about 50 to 65): ● | Wood's debuff is Poison, and its buff is health regeneration |
| Key talents | Comprehension (ngộ tính) for the technique's layers; vitality for the safety net | The build is slow to start and must live while it waits |
| The Way (Đạo) | Wood (Mộc): a Quiet Vine branch with Patient Venom and Watched Rot; Venom Facet (Nọc) for Spillover | Where the rule-benders live |
| Main technique | Thanh Mộc Địa Quyết (`dia_moc`, tier 2, ●): linh lực +12, heart-demon resistance +8 | Exists, reaches Kết Đan |

## Công Pháp

### Quiet Vine Sutra (Tĩnh Đằng Kinh): secret, tier 2

The herbalist's daughter's notes, copied out by three generations of ditch-diggers.

```json
{"id": "tinh_dang", "name": "Tĩnh Đằng Kinh", "tier": 2, "tech_kind": "secret",
 "names": ["moc"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 6}, {"stat": "khi_huyet_pct", "value": 6}],
 "abilities": [{"ability_id": "thorn-seed", "unlock_layer": 1}, {"ability_id": "weeping-sap", "unlock_layer": 3},
               {"ability_id": "rot-bloom", "unlock_layer": 5}, {"ability_id": "venom-tithe", "unlock_layer": 9},
               {"ability_id": "seeds-left-behind", "unlock_layer": 12}],
 "seal_clusters": [], "origin": "authored"}
```

Passives (first guesses): Rot Deepens +20 L2 on the poison tag; Long Roots, poison batches you lay last 20 % longer (this is the Status duration piece, put on the technique).
**Fit:** Needs key · **Budget:** NOT ASSESSED for the combat passives (not in `bonus_pool`); the two stat bonuses are small against a tier-2 budget of 2, with `pool_max` not read here.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Thorn Seed (Thích Chủng) | Sutra, 1 | Qi, wood, poison, over_time | 0.5 | 0.03 | 3 s | none | Needs key |
| Weeping Sap (Khấp Dịch) | Sutra, 3 | Heal, wood | heal 0.9 | 0.04 | 7 s | none | Needs key |
| Rot Bloom (Hủ Hoa) | Sutra, 5 | Qi, wood, poison | 0.4 | 0.05 | 6 s | none | Needs key |
| Venom Tithe (Độc Thuế) | Sutra, 9 | Qi, wood, poison | 0.3 | 0.04 | 8 s | none | Needs key |

- **Thorn Seed:** a small hit plus 10 Poison stacks for 14 s (12 at Kết Đan). *A burr pressed into the ankle.*
- **Weeping Sap:** heals 0.9 of the heal coefficient and grants 3 Wood buff stacks for 14 s (4 at Kết Đan), each adding health regeneration. *The vine bleeds for you.*
- **Rot Bloom:** a small hit plus 24 Poison stacks for 20 s (30 at Kết Đan). *The slow flower.*
- **Venom Tithe:** a small hit plus 16 Poison stacks for 24 s; restores 2 % of linh lực. *Rent paid in breath.*

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Luyện Khí | 3 | Thorn Seed, Weeping Sap | Common Ward | Not simulated. Lesson: stacks and waiting |
| Trúc Cơ | 4 | Thorn Seed, Rot Bloom, Weeping Sap | Common Ward | One slot free for a pill-fed talisman or a curse |
| Kết Đan | 5 | Thorn Seed, Rot Bloom, Weeping Sap, Venom Tithe | Common Ward | One slot free: Withering or a cleanse-bait art |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Bitter-Thorn Needle (Khổ Thích Châm) | Artifact, weapon | `cham`, thượng phẩm, Foundation | L3 attack; Wood element-affinity and Liệt affixes. *A paddy-worker's needle, dipped so often it stained* | Fits today |
| Mossback Vest (Đài Bối Giáp) | Artifact, body | `giap`, trung phẩm | Hộ Thân health; keeps the vest from costing thần thức | Fits today |
| Bitterroot Pill (Khổ Căn Đan) | Pill | Preparation, L4 | Prepared poison tick, +9 L4 for the fight | Needs key |
| Corpse-Wax Coating (Thi Lạp) | Coating | Preparation, L4 | Reused: +6 L4 on ticks | Needs key |
| Hot Spring Array (Ôn Tuyền Trận) | Formation | Preparation, ground | Reused: regeneration on its ground; the safety net at home | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Poison damage | +15 % notable | L1 | Needs key |
| 2 | Linh lực regeneration | +1 % notable | Safety net | ● |
| 3 | Status duration | +12 % notable | Longer batches | Needs key |
| 4 | Damage over time | +12 % notable | L1 | Needs key |
| 5 | Root Drinks the Rot | keystone | Leech from poisoned targets | Needs rule |

### Hidden cluster idea: Bitter Sap Row (Khổ Dịch)

Theme: Wood poison, a system the game has. Wood affinity, sealed, seal condition: carrying a Wood technique at layer 3. Size 7 acupoints: smalls of Poison damage and Status duration; one notable, Watched Rot; no capability. Wider than this build: any poison or curse build can walk it.

## Đạo

An existing Way, Wood (Mộc), with a Quiet Vine branch: Patient Venom (Per), Watched Rot (Conditional), and the Growth facet's regeneration lines; Spillover on the Venom Facet (Nọc) as an upgrade. Stat lines use only Wood's `theme_stats`. Stage: `moc-tinh-dang-lines`.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Luyện Khí | Plant, heal, wait | Thorn Seed, Weeping Sap | The first ditch of dead weevils |
| Trúc Cơ | A 20 s plan: Rot Bloom lays the long batch | Rot Bloom, pill and coating | First cleanser, first dead-end |
| Kết Đan | Plan plus a choice: Spillover, Withering or Seeds Left Behind | Venom Tithe, Patient Venom, Seeds Left Behind | Bitter yellow eyes |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical same realm | Wins | Stacks outgrow its ward; 38 s at Trúc Cơ, 24 s at Kết Đan |
| Cleanser (ward cleanses 25 % of each batch a pulse) | Loses (0 to 19, 1 draw at Trúc Cơ) | Batches never reach their timers; Seeds Left Behind and Spillover are the answers |
| Chaos-resistant body / thể tu | Slow | Resistance cuts Chaos |
| Top-end, or one realm above | Loses | Dead in the first volleys |

**Counter:** a cleanser, healer, or high Chaos resistance. Adapt by baiting the cleanse with a cheap Thorn Seed, then dropping Rot Bloom after its pulse; a Withering curse on a healer.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the art lint (no `lint_over`), slots 3/4/5 used 2/3/4, artifacts within `equip.max_slots`; the technique's bonus budget not checked (combat passives not in `bonus_pool`) |
| Validity | PASS | `dia_moc` tier 2 reaches Kết Đan; the new secret technique is tier 2 (max_realm `ket_dan`); both name Wood (harmony); Wood's debuff is Poison |
| Stack | PASS | Ladder filled, L5 and crit named as sacrifices; 7 forms; identity `--without rot-bloom` changed the fight at both realms |
| Scaling | PASS (INFO) | By hand from the layers (not script output): Trúc Cơ L1 to L4 product 3.34 against 3.81 typical without L5 (−12 %); Kết Đan 4.69 against 4.98 (−6 %). Slightly low on static, and tick damage is uncapped; wins 20-0 |
| The fight | PASS | See Fight Results; INFO: Kết Đan 24.3 s, under the 30 to 60 s band, not pulled back |
| Reuse | PASS | 15 pieces reused; signature: one (Rot Bloom the art) |
| NPC use | PASS | Patient Venom reads the target's stack count, no player input; Watched Rot reads the same; both fit a one-line Breakdown |
| Counterplay | PASS | Measured: a cleansing ward beats it 0-19 |
| Originality | PASS | Names are original; Poison, stacks and cleanse are this game's own |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/starter-venom.fight.json` (Trúc Cơ), `starter-venom.ket-dan.fight.json` (Kết Đan), `starter-venom.cleanser.fight.json`. Observations from `fight.py` on the combat simulator, 20 fixed seeds, not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Trúc Cơ | 0 | 20 / 0 / 0 | 38.3 s | never (foe dry 26.6) | none | none |
| typical, Trúc Cơ | +1 (Kết Đan foe) | 0 / 20 / 0 | about 8 s | 6.6 s | none | none |
| cleanser, Trúc Cơ | 0 | 0 / 19 / 1 | 43.6 s | 27.6 s | none | none |
| typical, Kết Đan | 0 | 20 / 0 / 0 | 24.3 s | never (foe dry 20.0) | none | none |
| typical, Kết Đan | +1 | 0 / 20 / 0 | 6.9 s | 5.6 s | none | none |
| top_end, any | 0 | 0 / 20 / 0 | 1.0 to 1.6 s | 1.0 s | all (dead before the first cooldown) | none |

**Identity test** (`--without "rot-bloom"`): Trúc Cơ typical 38.3 → 63.4 s, wins 20 → 20, health left 76 % → 44 %. Kết Đan typical 24.3 → 32.8 s. Changed in both.

**Unmodelled:** the simulator's `model_note`: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape. This build's own: Root Drinks the Rot (leech), Patient Venom (its cap is folded into the L2 points on the poison arts), Sap Rises (stack healing beyond the simulator's Wood table), Seeds Left Behind and the cleanse-immunity window, Spillover. None is the engine; all are upgrades or the answer to a counter, so the fight check stands. Luyện Khí was not simulated.

## New Concepts

None new. Reuses `cleansed-stacks-event` (staged earlier). One readable is proposed: the target's Poison stack count (`poison-stack-count-readable`), see suggestions.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Patient Venom | Needs rule | modifiers.md: Per form reads a target stack count at each tick |
| Watched Rot | Needs key | A condition "target has 15+ Poison stacks" on a regeneration modifier |
| Seeds Left Behind | Needs rule | effects.md rule 9a: a trigger on the cleansed-stacks event |
| Quiet Vine Sutra, four arts | Needs key | Technique and art records |
| Bitterroot Pill | Needs key | A pill's fight payload at L4 |
| Corpse-Wax Coating, Hot Spring Array, Root Drinks the Rot, Sap Rises, Spillover | reused | Already staged or in the tree catalogue |
| Bitter Sap Row cluster, Wood Quiet Vine branch | Needs key | Cluster idea and Đạo lines |
