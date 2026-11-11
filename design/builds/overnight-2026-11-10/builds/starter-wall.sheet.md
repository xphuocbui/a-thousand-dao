# The Patient Wall (Nại Bích)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A new player's safe build: an Earth body cultivator that is very hard to kill, wins slowly, and teaches the player what wards, guard and regeneration do. Easy pieces, few ways to get it wrong.
> **Direction**: A. The Patient Wall (Nại Bích): a common ward and a body wall worn together, kept up by one guarded heal.
> **Realm span**: Qi Refining (Luyện Khí) to Core Formation (Kết Đan) · **Power level**: ordinary · **Use**: player
> **Fit**: 9 Fits today · 5 Needs key · 0 Needs rule
> **Checks**: 7 PASS · 1 FAIL (The fight: 65 s, just over the 30 to 60 s band) · 1 NOT ASSESSED (Scaling: no `m_static` printed). Parts of Budgets (thần thức) and Stack (the Per modifier) were not assessable

## Directions considered

**Chosen: A. The Patient Wall (Nại Bích).** Ward and body layers both filled, one heal art behind a health guard, Earth stacks as a small extra layer. It shows every defensive layer once and has almost no dials to set wrongly.

- **B. The Bare Mountain (Vô Hộ Sơn)**: a pure body cultivator on the No Ward keystone. Rejected: it removes the ward, and the build is meant to teach the ward.
- **C. The Echoing Wall (Phản Bích)**: a wall that returns part of the blocked damage (Thorned Skin, Mirror Ward). Rejected: it needs new rules, and a new player should not have to learn a counter-attack to survive.

## The Spine

- **The channel:** basic attack and one Earth palm art (art hit). Offence is deliberately small: L1 +90, L2 about +10, L3 to L5 empty, so M is about 2.1 against the Foundation typical 4.19.
- **The enabler:** none. A stack of what exists.
- **The loop:** the wall takes hits at low cost, the guarded heal tops it up whenever health is at or below 60 %, regeneration refills linh lực, and the palm and the basic attack wear the foe down until its linh lực and ward run out.
- **The engine:** wards, body layers and regeneration are paid from different pools. The ward spends linh lực, the body spends nothing, and the heal spends a little linh lực to restore health. The foe has to beat three layers at once.
- **The sacrifice:** speed and damage. It wins in about 65 s and loses to anyone a realm above, and it never ends a fight early.
- **The arc:** Qi Refining is a plain shield and a palm. Foundation adds the guarded heal. Core Formation adds the body technique tier and a home formation, so the wall holds longer, not harder.

## The Legend

Sect gatekeepers (tông môn) in the Earth-root valleys were not chosen for talent. They were chosen because they were still standing at dawn. The Patient Wall is what they taught each other: breathe, hold the line, mend when the body says so, and let the other side tire.

It does not make legends. Wall-walkers rarely win a duel with grace; they win because the other cultivator ran out of linh lực first. Elders call it the safe road, and mean it kindly and not kindly.

Fast sects hunt it for pills and for sport. A wall cannot flee, and a cultivator a realm above does not tire.

## How It Fights

The wall opens by setting its Earth stance, which gives stacks of Earth buff that shave physical damage. The palm lands every 3 s and leaves two Earth debuff stacks that dull the foe's accuracy. The basic attack runs the whole time. The heal waits behind its guard and fires when health falls to 60 %. The foe's ward drains, its linh lực empties around 48 s, and the wall finishes it with health to spare (71 % left at Foundation in the simulator).

**Signature moment:** the foe's ward breaks, and the wall is still at about 70 % health, with linh lực never dry.

## Enabler

None. See the guide's "Changes the game would need".

## The Stack

Sizes on new modifiers are first guesses. Nothing past L1 has a W price yet (Combat Open Question 5).

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Long Tượng Công body bonuses | +15 % health, +10 % damage (data) | Increased | any | L1 | ● | Technique | any thể tu |
| 3 Multiplier | Damage (`attack_pct`) nodes | +90 % total from tree and technique | Increased | any | L1 | ● | Tree | any build |
| 3 Multiplier | Sustained Note (Dư Âm), reused | More art damage per second of fight, up to a cap; here +10 on the palm | Per | art | L2 | ○ | Art | Ninth Bell |
| 3 Multiplier | Stone Does Not Hurry (Thạch Bất Cấp), new | +1 % more basic attack damage per 5 s of fight, up to +12 % | Per | basic | L2 | ○ | Technique | any Late Bloom build |
| 3 Multiplier | Ward layers W2 to W4 | 50 / 47 / 20 | More | ward | W2, W3, W4 | ● | Technique, artifact | any ward build |
| 3 Multiplier | Body layers B2 to B4 | 50 / 47 / 20 | More | body | B2, B3, B4 | ● | Technique, armour | any thể tu |
| 4 Crit | none | no crit; the palm and basic attack are steady | | | | | | sacrifice |
| 5 Reach | Earth debuff stacks on the foe | accuracy down (Effects D) | Conditional | art | none | ● | Art | any Earth build |
| 6 Cap | none | nothing in the build reaches a cap | | | | | | sacrifice |
| 7 Fuel | Linh lực regeneration | +2.5 pp a pulse | Increased | any | none | ● | Tree, technique | any sustain build |
| 7 Fuel | Art cost | −10 % | Increased | any | none | ● | Tree | any build |
| 8 Survival | Health regeneration | +1.5 pp a pulse | Increased | body | none | ● | Tree | any thể tu |
| 8 Survival | Healing | +20 % to the heal | Increased | heal | none | ● | Tree | any healer |
| 8 Survival | Iron Skin Renewed (Thiết Bì Phục), reused | Firing a Physical-part art refills 2 % of body shield | Trigger | body | none | ● | Effect | Thể tu Physical builds |
| 9 Identity | Packed Earth stacks (Trần Bích) | 8 Earth buff stacks for 16 s, each less physical damage taken (0.011 each) | Per | defence | none | ● | Art | Earth builds |

**Identity piece:** Packed Earth Stance (Hậu Thổ Trụ Thế): the Earth stack wall. The simulator measures a small effect (see Fight Results), so the build's weight is really in its filled defence layers. The player-facing identity is "everything defends, nothing is missing".
**Empty rungs:** Rate (sacrifice: it is slow), Crit (sacrifice), Reach beyond Earth debuffs (sacrifice), Past the cap (sacrifice, nothing nears a cap), L3 to L5 offence (sacrifice; a new player does not need preparation to survive).

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 90 | ×1.9 | `attack_pct`, Long Tượng Công 10, Earth palm nodes |
| L2 | about 10 | ×1.1 | Stone Does Not Hurry (basic), Sustained Note (palm) |
| L3 | 0 | ×1 | empty: no weapon, thần thức goes to the shield and armour |
| L4 | 0 | ×1 | empty: preparation is optional, see Items |
| L5 | 0 | ×1 | empty: no conditions to hold |
| W2 to W4 | 50 / 47 / 20 | above typical | Hậu Thổ Địa Quyết, Hộ Sơn Trận at home, Thuẫn |
| B2 to B4 | 50 / 47 / 20 | above typical | Long Tượng Công, armour (Giáp), body nodes |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth (Thổ) single root, purity about 50 (middling) | Earth gives the Earth stacks and the Hậu Thổ techniques. Purity is not needed above middling |
| Key talents | Physique, then Comprehension | Physique feeds the body layers; the build needs little else |
| The Way (Đạo) | Thổ Đạo (Unmoving Mountain): Sơn Thể (block) first, then Trần Bích (Earth stacks) | Both facets exist. No new Đạo is proposed |

## Công Pháp

### Hậu Thổ Địa Quyết (dia_tho) — main, tier 2

The first thing every Earth-root disciple is handed.

```json
{"id": "dia_tho", "name": "Hậu Thổ Địa Quyết", "tier": 2, "tech_kind": "main",
 "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "tam_ma_resist_pct", "value": 8}],
 "abilities": [{"ability_id": "packed-earth-stance", "unlock_layer": 1},
               {"ability_id": "tremor-palm", "unlock_layer": 3},
               {"ability_id": "mending-breath", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** the record exists in `items_cong_phap.json` with an empty `abilities` list; the three abilities are new content (Needs key). **Budget:** 12/20 + 8/15 = 1.13 against the tier 2 budget of 2. Within. Tier 2 reaches Core Formation.

### Long Tượng Công (long_tuong_cong) — body, tier 2

```json
{"id": "long_tuong_cong", "name": "Long Tượng Công", "tier": 2, "tech_kind": "body",
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "attack_pct", "value": 10}]}
```

**Fit:** exists. **Budget:** 15/15 + 10/15 = 1.67 against 2. Within. The tier 1 body technique Kim Cang Thể reaches only Foundation and would be over its own budget by the same arithmetic, so the build starts on Long Tượng Công.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Packed Earth Stance (Hậu Thổ Trụ Thế) | Hậu Thổ Địa Quyết, 1 | body, Earth, buff | 0.6 | 0.03 | 8 s | none | Needs key |
| Tremor Palm (Chấn Thổ Chưởng) | Hậu Thổ Địa Quyết, 3 | body, Earth, Palm, hit, debuff | 1.8 | 0.04 | 3 s | none | Needs key |
| Mending Breath (Hồi Khí Tức) | Hậu Thổ Địa Quyết, 6 | qi, Earth, heal | 0 (c_heal 4.0) | 0.05 | 6 s | own health at or below 60 % | Needs key |

**Packed Earth Stance.** Effect: gives yourself 8 Earth buff stacks for 16 s. Each stack cuts physical damage taken (0.011). A Physical part triggers Iron Skin Renewed. Description: the disciple plants a foot and the ground answers.
**Tremor Palm.** Effect: a hit, plus 2 Earth debuff stacks for 8 s on the foe (accuracy down, 0.012 each). Description: a flat palm to the earth and the foe's footing goes.
**Mending Breath.** Effect: restores health and refunds the linh lực paid when it lands. Guard: own health at or below 60 %. Description: three slow breaths; the flesh remembers its shape.

Lint check (the loader printed no `lint_over` and no `range` for any of the three): Stance 0.6 ≤ 3.47, Palm 1.8 ≤ 2.46, heal 4.0 against its heal lint of 1.4 × 3.45 = 4.83.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining (Luyện Khí) | 3 | Tremor Palm, Packed Earth Stance, empty | Common Ward | Learn the ward; the stance is a bonus |
| Foundation (Trúc Cơ) | 4 | Stance, Palm, Mending Breath, empty | Common Ward + Thuẫn | The guarded heal arrives |
| Core Formation (Kết Đan) | 5 | Stance, Palm, Mending Breath, Kim Cương Phù talisman, empty | Common Ward + Thuẫn | A talisman for blind fights |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Plain Shield (Thuẫn) | Artifact, ward role | `thuan`, Hạ or Trung, Foundation | Defence 35 base, feeds the ward layer W3; affix Kiên | Fits today |
| Hard-Worn Plate (Giáp) | Artifact, body role | `giap`, Hạ or Trung, Foundation | Defence 30, feeds body layer B3; affix Hộ Thân (+5 to 15 % health) | Fits today |
| Hộ Sơn Trận | Formation | `ho_son`, level 1 to 3 | +10 % defence per level at home only; preparation | Fits today |
| Kim Cương Phù | Talisman | `kim_cuong`, 1 stock | +40 % defence for one fight; takes an art slot | Fits today |
| Hot Spring Array, Stone-Marrow Pill | Formation, pill | staged earlier | Regeneration and body upgrades at the top of the build | Reused (staged) |

Shield and armour keep to the rule that an item's defence feeds the ward or the body, never both (item-database rule 11).

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Maximum health (`khi_huyet_pct`) | +1 % small, +6.5 % notable | The bar that ends the fight | Fits today |
| 2 | Linh lực regeneration | +0.15 % small, +1 % notable | Keeps ward and heal alive | Fits today |
| 3 | Ward strength, ward efficiency | +1.2 / +8 % | Strengthens the ward layers | Fits today |
| 4 | Body guard | +1.2 / +8 % | Body layer | Fits today |
| 5 | Art cost | −0.5 / −3 % | Cheap arts, longer fights | Fits today |
| 6 | Iron Marrow (Thiết Tủy), keystone | Body guard rises as health falls | Late-fight comeback | Needs rule (catalogue) |

### Hidden cluster idea: Settled Earth (Định Thổ)

Theme: Earth Đạo and body. Element: Earth. Sealed. Seal condition: a body technique equipped. Size 8 acupoints: small points of health, linh lực regeneration and Earth stack duration; a notable of Stone Does Not Hurry on the outer edge. No capability. An idea for the tree rework, not data.

## Đạo

Thổ Đạo (Unmoving Mountain), existing: Sơn Thể and Trần Bích facets. No new Đạo.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | Shield, palm, basic attack | Tremor Palm | The gatekeeper's first night |
| Foundation | Adds a guarded heal | Mending Breath, Thuẫn | The first time the wall nearly fell and mended |
| Core Formation | Longer holds, a talisman | Kim Cương Phù, Hộ Sơn Trận | The wall stands in a place that is its own |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical cultivator, same realm | wins slowly | 20-0, 65 s, 71 % health left |
| One realm above | loses | 0-20, 13.7 s: suppression and a larger pool |
| Top-end builds | loses | 0-20 in 2 s |
| Burst sword cultivator (kiếm tu) | wins if the wall holds | The wall shrugs small hits; one big hit above the ward is the danger |
| Soul attacker | loses | Soul ignores the ward and body layers |
| Cleanser or curse caster (Withering, Stagnation) | even or loses | Curses cut regeneration, which is the build's fuel |

**Counter:** a soul-art cultivator, because soul damage passes ward and body (combat-model: Soul ignores the multiplier game). The player's answer is a soul-resistance node or Tĩnh Tâm armour affix, both listed in the guide.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Hậu Thổ Địa Quyết 1.13 ≤ 2, Long Tượng Công 1.67 ≤ 2, three arts inside the art lint, slots 3 / 4 / 5 used within `slots_by_realm`. Artifacts: 2 (Thuẫn 15 + Giáp 5 thần thức) against `equip.max_slots` 6; the thần thức pool was not read, so the thần thức part is NOT ASSESSED |
| Validity | PASS | Real ids: `dia_tho` (tier 2, max_realm ket_dan), `long_tuong_cong`, `thuan`, `giap`, `ho_son`, `kim_cuong`, Earth. Aux harmony: a body technique names no element, so it harmonises |
| Stack | PASS | Nine rungs: six filled, three named sacrifices; five forms (Increased, More, Per, Conditional, Trigger); identity piece named; layer totals stated. Identity test: `--without packed-earth-stance` shows `changed` at +0 Foundation (65.2 to 65.3 s) and at +1 (13.7 to 12.5 s), `NO_CHANGE` at Core Formation +0. A weak pass. The Per modifier is unmodelled, so its part is NOT ASSESSED |
| Scaling | NOT ASSESSED | `fight.py` printed no `m_static`. By hand, M is about 2.1 against typical 4.19, with defence layers above typical, and the matrix wins 20-0 against typical. Not a formal check |
| The fight | FAIL | Typical same-realm fight is 65 s (Foundation) and 66 s (Core Formation), a little over the 30 to 60 s band. Extra offence and art speed barely moved it, so it was left slow, as the seed asks. Guard, Iron Skin Renewed, formation and talisman are unmodelled, and no engine piece is unmodelled, so the loop is tested. No `cap_hit`, no `lint_over`; no `NEVER_FIRED` against a typical foe of the same realm |
| Reuse | PASS | Reuses Sustained Note, Iron Skin Renewed, Hot Spring Array, Stone-Marrow Pill, Thổ Đạo and 8 catalogue rows. One new modifier (Stone Does Not Hurry), second home Late Bloom builds; no signature pieces |
| NPC use | PASS | Every piece is a stat, a data item or a plain art; the generator can roll them and a Breakdown line explains each |
| Counterplay | PASS | Soul attackers, a realm above, curse casters |
| Originality | PASS | No names from a novel or game; techniques come from the repo's own data |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/starter-wall.fight.json` (and `starter-wall.ket-dan.fight.json` for Core Formation). Observations from `fight.py` on the combat simulator, 20 fixed seeds.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Foundation | 0 | 20 / 0 / 0 | 65.2 s | never | none | none |
| typical, Foundation | +1 | 0 / 20 / 0 | 13.7 s | 8.1 s | none | none |
| typical, Foundation | +2 | 0 / 20 / 0 | 4.0 s | 3.2 s | stance, heal | none |
| top_end, Foundation | 0 | 0 / 20 / 0 | 2.0 s | 1.6 s | all | none |
| typical, Core Formation | 0 | 20 / 0 / 0 | 66.0 s | 28.1 s | none | none |
| typical, Core Formation | +1 | 0 / 20 / 0 | 8.7 s | 6.1 s | not listed | none |

Foe linh lực is dry at 48 s (Foundation) and 50 s (Core Formation); the build's own is dry never at Foundation, and at 28 s at Core Formation.

**Identity test** (`--without packed-earth-stance`): Foundation `changed` at +0 and +1, `NO_CHANGE` at +2 and top-end; Core Formation `NO_CHANGE` at +0, `changed` at +1.

**Unmodelled:** Mending Breath's guard (the simulator fires it on cooldown), Iron Skin Renewed, Hộ Sơn Trận and Kim Cương Phù, Stone Does Not Hurry, and the block, resistance and ward as nearest numbers (a drain ward). The simulator `model_note` also lists soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield and escape as not modelled.

## New Concepts

None.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Packed Earth Stance, Tremor Palm, Mending Breath | Needs key | Art records on `dia_tho` (its `abilities` list is empty today); heal-art guard uses Combat rule 13's vocabulary |
| Stone Does Not Hurry | Needs key | A stat key for "basic attack more per 5 s of fight, capped" |
| Sustained Note | Needs key | Reused from the Ninth Bell ledger rows |
| Basic attack damage, Body guard against qi hits | Needs key | Catalogue rows with ○ status |
| Iron Marrow | Needs rule | Existing catalogue keystone, optional upgrade |
