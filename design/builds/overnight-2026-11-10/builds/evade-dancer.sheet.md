# Drifting Wind Dancer (Phiêu Phong Vũ Giả)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: Evade to evade_cap and make evading do something: every evaded hit pays linh lực, stacks a buff or triggers a counter. Hits never land; ticks and soul are its nightmare and it must have an answer for one of them.
> **Direction**: A. The Paying Miss (Tị Hồi): evade is the engine, not a defence stat. Chosen by the build session (see Directions considered).
> **Realm span**: Trúc Cơ to Nguyên Anh (defining realm Nguyên Anh) · **Power level**: top-end · **Use**: player · **Root**: Wind (phong)
> **Fit**: 4 Fits today · 14 Needs key · 8 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 4 NOT ASSESSED (Budgets: evade is not in `bonus_pool` and the technique tier's `max_realm` was not read; Validity: same tier check; Identity test: the engine Effect is not modelled; The fight: the engine is unmodelled, so only the nearest approximation ran)

## Directions considered

Chosen: **A. The Paying Miss (Tị Hồi).** Every evaded hit pays three things at once: linh lực, a Wind stack (art speed) and a counter toward a free riposte. It is the only reading where evade stops being a passive percentage and becomes the loop, and it uses a channel nobody else touches (the evade roll). It is a stack of existing evade and Wind pieces plus one enabler Effect.

Not picked:
- **B. The Riposte Blade (Báo Chiêu Khách).** Every evade fires a free counter hit. Weaker: trigger hits can never be main damage (`trig_budget`, no crit, no L5), so the dancer would be a slow build with a bonus.
- **C. The Hollow Reed (Không Thân).** Counted evade (Effects rule 12): evade becomes a meter, every full meter is a perfect dodge and the rest are plain hits. Deterministic and clever, but it removes the "hits never land" feel that the seed asks for and gives nothing back per evade.
- **D. The Wind Wall (Phong Bích).** Evade feeds a ward (evaded hits recharge a shield). Safe but passive, and it competes with the ward layers for the same job.

## The Spine

- **The channel:** art hits with the Wind tag (elem hits), plus a small trigger channel (the Reply). Layers L1 to L5 all used; the build's hits take every layer, the trigger takes none of L5. Defence: evade at `evade_cap` (0.40), with ward and body layers W2–W5, B2–B5 filled because evade alone stops only 40 % of hits.
- **The enabler:** Unstruck Body (Bất Xúc Thân), a divine ability on Reed-Shadow Scripture. Opens: an evaded hit now fires the "hit evaded" event, which the Effects Evade Pays, Reply and Carried Off listen to. Closes: soul resistance is 0 from every source and no soul ward can be carried.
- **The loop:** the foe swings; 40 % of hits are avoided; each avoided hit pays 1 % of maximum linh lực, adds a Wind stack for 8 s and moves the Reply counter; Wind stacks push art speed toward `cooldown_min`; fast arts spend the linh lực the misses paid for.
- **The engine:** a miss is income. Because evade is capped, Surplus Breeze turns evade points above the cap into art speed, so the build never wastes a point of evade it stacked to be sure of reaching the cap.
- **The sacrifice:** soul. With soul resistance forced to 0, any soul art lands at full strength, and evade never meets a soul hit. The build refuses to fix this; its answer to ticks is the one it has chosen.
- **The arc:** Trúc Cơ: a dodger with a small linh lực refund. Kết Đan: Wind stacks make it fast. Nguyên Anh: art speed pinned at the floor, riposte every few misses, elemental ticks blown off as it dodges.

## The Legend

The Reed-Shadow school began with the ferrymen of the Hollow Marsh (Hư Trạch), who learned that a reed which bends does not break and a reed which does not stand is never cut. A ferryman named Lô Ảnh, the last of them, outlived a flood, a famine and a sect's hunting party without being struck once, and wrote that "a blow that finds nothing is a gift you were owed". His scripture works because the body stops being where the blow arrives; it fails because the mind goes with it. Every dancer who has finished the scripture speaks of the same hole: a cold place in the head where the soul should be armoured.

Walkers of this path are wanderers, couriers and sect (tông môn) scouts who must cross hostile ground. Thần thức cultivators hunt them for sport, since nothing the dancer wears can stop a thought.

## How It Fights

The dancer stands in the ring and does not seem to move. Against an equal-realm foe, two hits in five find nothing, and every miss feeds the dancer: a breath of linh lực, a gust of speed, a count toward a free cut. The foe's burning and poison stacks are blown off one by one with each miss. After ten or twelve seconds the dancer's arts fire at the half-second floor, and the foe is cut down by a flurry that began with its own swings.

**Signature moment:** the Gale Crown (Cuồng Phong Quán) fires with ten Wind stacks on the dancer, every other art is already pinned at the floor, and the foe's last Burn stack drops off in the same breath.

## Enabler

**Unstruck Body (Bất Xúc Thân)**, divine ability at layer 6 of Reed-Shadow Scripture (Lô Ảnh Kinh). Opens the hit-evaded event and gives the dancer three Effects (Evade Pays, Reply, Carried Off). Closes soul resistance (forced to 0) and soul wards. Found by finishing the scripture's sixth layer, whose seal condition is "survive a fight in which the foe landed no hit"; rare, the stack is not.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Wind damage | +12 % Wind damage (notable); small +2 % | Increased | art | L1 | ○ (catalogue element-damage row) | tree | any Wind build |
| 1 Base | Wind-Fed Edge (Phong Dưỡng Nhận) | +2 % more Wind art damage per Wind stack on you, up to 10 stacks (+20 %) | Per | art | L2 | ○ | technique bonus | any Wind-stack build |
| 2 Rate | Art speed | +3 % notable, +0.5 % small | Increased | all arts | none | ◐ | tree, Đạo | any fast build |
| 2 Rate | First firing comes sooner | −12 % notable | Timing | art | none | ○ (catalogue) | cluster | first-strike builds |
| 3 Multiplier | Gear L3, Crosswind Array L4, Rhythm of the Miss L5 | see layer table | Conditional | art | L3, L4, L5 | ○ | items, formation | any evade build |
| 3 Multiplier | Rhythm of the Miss (Hụt Tiết) | +25 % more hit damage for 2 s after an evade | Conditional | art | L5 | ○ | cluster notable | any dodge or counter build |
| 4 Certainty | Crit chance and crit damage | +2.5 % and +10 % notables; crit 0.2 / 2.0 in the fight | Increased | art | outside M | ● | tree | any crit build |
| 5 Reach | Veiled Aim (Mạc Chuẩn) | the foe's accuracy −4 pp (small), −10 pp (formation) | Flat base | all | none | ○ | formation, Đạo | any evade or ward build |
| 6 Past the cap | Surplus Breeze (Dư Phong) | each evade point above `evade_cap` after accuracy gives +0.5 % art speed, up to +20 % | Overflow | art | none | ○ | Đạo notable | any evade or crit-over-cap build |
| 6 Past the cap | Trigger limit | +1 firing between pulses (Reply rate) | Cap shift | trigger | none | ○ (catalogue) | cluster | any trigger build |
| 7 Fuel | Linh lực regeneration, art cost, Evade Pays | regen +1 % notable, cost −3 % notable, 1 % of maximum per evade (Effect) | Increased, Trigger | all | none | ● and Effect | tree, enabler | any sustain build |
| 8 Survival | Evade | +2.5 % notable, +0.4 % small; target 55–65 pp to hold the cap against accuracy | Increased | defence | none | ● | tree, items, pill | any evader |
| 8 Survival | Ward and body layers | W2–W5 and B2–B5 near caps | More | defence | W/B | ● | technique, items | any top-end build |
| 8 Survival | Carried Off | an evaded hit removes 1 debuff stack batch of yours, once per pulse | Trigger | tick answer | none | Effect | enabler | any evader |
| 9 Identity | Evade Pays | see Effects below | Trigger | all | none | Effect | enabler | signature |

**Identity piece:** Evade Pays (Tị Hồi). Remove it and evade is a defence stat; with it every miss is income. Signature (no second home yet). Its three halves (linh lực, stack, counter) each have second homes as plain modifiers.
**Empty rungs:** none empty. Rung 5 is thin (accuracy-down only) and is a deliberate gap: the dancer does not pierce. Soul is a sacrifice, named above.

| Layer | Points at Nguyên Anh | Multiplier | Sources |
|---|---|---|---|
| L1 | 400 (counts 300 past the +200 knee) | ×4.0 | Wind damage notables, attack_pct, Đạo Gale and Drift lines |
| L2 | 300 (260 untagged + 40 on the art) | ×4.0 | Reed-Shadow Scripture, Wind-Fed Edge at 10 stacks (+20), arts |
| L3 | 250 | ×3.5 | Cicada-Wing Sash and a weapon, named affixes |
| L4 | 150 | ×2.5 | Crosswind Array, Clear-Breeze Pill, talisman |
| L5 | 100 | ×2.0 | Rhythm of the Miss, Bare-vessel-type "while" lines |
| Ward W2–W5 | 300 / 250 / 150 / 100 | at cap | technique, gear, formation |
| Body B2–B5 | 250 / 200 / 150 / 80 | near cap | technique, gear |

All layers filled. M is about 280 against the top-end anchor 256 for Nguyên Anh: `INFO`, above the anchor, not pulled back. The simulator reads L5 as always on; the real Rhythm of the Miss is on only for 2 s after an evade.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wind (phong), purity 80 or higher | Wind stacks and the Phong Đạo need it |
| Key talents | Agility and Comprehension | Agility feeds `evade_pct`; Comprehension speeds the scripture's layers |
| The Way (Đạo) | Phong Đạo (Thanh Phong): Drift (Phiêu) and Gale (Cuồng Phong) branches | Drift holds evade and Wind stacks; Gale holds art speed |

## Công Pháp

### Reed-Shadow Scripture (Lô Ảnh Kinh): main, tier 3

A ferryman's book that teaches the body to be elsewhere.

```json
{"id": "lo_anh_kinh", "name": "Lô Ảnh Kinh", "tier": 3, "tech_kind": "main",
 "names": ["phong"], "layers": 12,
 "bonuses": [{"stat": "evade_pct", "value": 8}, {"stat": "linh_luc_regen_pct", "value": 6},
             {"stat": "art_speed_pct", "value": 8}],
 "abilities": [{"ability_id": "bat_xuc_than", "unlock_layer": 6}],
 "seal_clusters": ["lo_phieu"], "origin": "authored"}
```

**Fit:** Needs key (a Wind-Fed Edge bonus line; `bat_xuc_than` is an authored ability) · **Budget:** NOT ASSESSED (evade is not a `bonus_pool` key; the tier's `max_realm` was not read).

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Reed-Cutting Breeze (Tước Phong Nhận) | Scripture, layer 1 | elem, wind, cut | 1.9 | 0.03 | 2 s | none | Needs key |
| Hollow Step (Hư Bộ) | Scripture, layer 3 | elem, wind, step | 0.6 | 0.02 | 3 s | none | Needs key |
| Falling Leaf (Điệp Lạc) | Scripture, layer 5 | elem, wind, cut | 2.9 | 0.05 | 4 s | none | Needs key |
| Scatter Gale (Tán Phong) | Phong Đạo, Drift Facet | elem, wind, cleanse | 0 | 0.03 | 6 s | none | Needs key |
| Gale Crown (Cuồng Phong Quán) | Scripture, layer 9 | elem, wind, crown | 4.6 | 0.08 | 8 s | none | Needs key |

All inside the art lint (c ≤ 1 × (1 + 24 × cost) + 0.25 × (cooldown − 1)): the simulator printed no `lint_over`.

- **Reed-Cutting Breeze.** Effect: a Wind hit that adds 1 Wind buff stack for 8 s. Description: the cheapest cut in the scripture, thrown on the way out of a bow.
- **Hollow Step.** Effect: a weak Wind hit that adds 2 Wind stacks for 8 s and restores 2 % of maximum linh lực. Description: the dancer steps into where the foe's blow was going to land.
- **Falling Leaf.** Effect: a heavier Wind hit with 1 Wind stack. Description: a leaf comes down in a straight line when the air allows it.
- **Scatter Gale.** Effect: cleanse 2 debuff stack batches from you. Description: the answer to ticks on demand, for when evading is not enough.
- **Gale Crown.** Effect: the big Wind hit with 3 Wind stacks for 10 s. Description: all the wind the dancer has gathered, released as one ring.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Tước Phong Nhận, Hư Bộ, Điệp Lạc | Common Ward | Evade ~15 pp; Evade Pays not unlocked (layer 6) |
| Kết Đan | 5 | Tước Phong Nhận, Hư Bộ, Điệp Lạc, Tán Phong | Drain ward, strength moderate | Unstruck Body unlocked at layer 6; Wind stacks start to bite |
| Nguyên Anh | 6 | Tước Phong Nhận, Hư Bộ, Điệp Lạc, Tán Phong, Cuồng Phong Quán (+1 free) | Drain ward, W2–W5 near caps | Evade at cap; art speed near the floor; sixth slot for a talisman |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Cicada-Wing Sash (Thiền Dực Đới) | Artifact, utility | new base (`giap`-like, light), high grade | evade +10 pp, art speed, Gale affixes; L3 | Needs key |
| Clear-Breeze Pill (Thanh Phong Đan) | Pill, preparation | pill, mid grade | +6 pp evade for the fight; L4 | Needs key |
| Crosswind Array (Giao Phong Trận) | Formation, preparation | formation, mid grade | foe accuracy −10 pp, evade +8 pp, L4 and ground tags | Needs key |
| Gale affixes: Tật, Hồi Khí, Hấp Huyết | Affix set on a weapon | generated | art speed, regen, leech | Reused (staged by another build) |

History: the Sash was woven from the shed wings of a cicada that, the story goes, spent seventeen years in the ground to leave one summer behind.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Evade (`evade_pct`) small and notable acupoints | +0.4 / +2.5 pp | to reach 55–65 pp | Fits today |
| 2 | Wind damage notables | +12 % | L1 | Needs key |
| 3 | Art speed notables | +3 % | rate | Fits today (◐) |
| 4 | Linh lực regeneration and art cost | +1 % / −3 % | fuel | Fits today |
| 5 | Crit chance and crit damage | +2.5 % / +10 % | certainty | Fits today |
| 6 | Reed Drift cluster | see below | holds the rest | Needs key |

### Hidden cluster idea: Reed Drift (Lô Phiêu)

Theme: Heart State (Điều Tức)-adjacent movement; element affinity Wind; sealed, seal condition "a fight survived with no hit landed" (also the Scripture's `seal_clusters` entry). Size 8 acupoints, one notable per `huyet_per_notable`. Small acupoints: evade, art speed, first firing sooner, status duration (Wind stacks last longer). Notables: Rhythm of the Miss (Hụt Tiết) and Wind-Fed Edge (Phong Dưỡng Nhận). No capability. An idea for the tree rework, not data.

## Đạo

Existing: Phong Đạo (Thanh Phong), Wind. Nodes wanted: Drift (Phiêu: evade, Wind stacks) lines and a notable **Surplus Breeze**; Gale (Cuồng Phong: art speed) lines; the art **Scatter Gale** on the Drift Facet. No new Way proposed. Reused: the Gale Facet (staged by another build).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A dodger with a short Wind stack | Scripture layer 1, Tước Phong Nhận | the first fight with no wound |
| Kết Đan | Fast, with refunds | Unstruck Body (layer 6), Evade Pays | the cold place in the head appears |
| Nguyên Anh | Pinned at the floor, riposting | Gale Crown, Surplus Breeze | soul pressure from thần thức cultivators starts to matter |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical foe, same realm | wins | one volley (observed 1.3 s at Nguyên Anh with all layers filled) |
| Typical foe, one realm up | wins | 1.8 s observed; the realm step adds +2 pp evade |
| Top-end foe, same realm | even | 13 wins, 6 losses, 1 draw at Nguyên Anh (9.3 s); the evade engine is unmodelled, so this is the floor |
| Top-end foe, one realm up | loses | the realm gap is 0.5 suppression |
| Thần thức cultivator with a soul art | loses | soul resistance is 0, evade and wards do nothing |
| Chaos-poison stacker | even | Carried Off removes 1 batch per pulse, Scatter Gale 2 per 6 s; a fast stacker still wins |
| Measured Stroke user (arts of 20 s or more) | loses their one hit | those arts cannot be evaded; the build lives on |

**Counter:** a soul-art cultivator (thần thức cultivator) walks through every layer. Also: stacks laid faster than the dancer can cleanse, an Earth or Thunder accuracy-stack user (their accuracy stacks shave the evade cap), and anyone who burns linh lực directly (Qi Disruption), since the build runs on a pool.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | technique bonuses use `evade_pct`, not in `bonus_pool`; art lint passed (no `lint_over`); slots 5 of 6 at Nguyên Anh; artifacts not counted |
| Validity | NOT ASSESSED | element `phong` and realms `ket_dan`, `nguyen_anh` real; the tier-3 `max_realm` was not read |
| Stack | PASS | all rungs filled or named; forms: Increased, More, Per, Overflow, Conditional, Cap shift, Trigger, Timing, Flat base; layer totals stated |
| Identity test | NOT ASSESSED | Evade Pays is unmodelled. Proxy `--without hu-bo`: Nguyên Anh top-end foe changed (9.3 → 10.8 s, wins 13 → 12); Kết Đan changed in 3 of 6 matchups. The proxy is Hollow Step, not the Effect |
| Scaling | PASS | M about 280 against the top-end 256: INFO, above the anchor |
| The fight | NOT ASSESSED | the engine (evade pays, riposte, Carried Off) is not in the simulator; the fight ran its nearest approximation |
| Reuse | PASS | 7 pieces reused (3 staged, 4 catalogue); 1 signature (Evade Pays) |
| NPC use | PASS | every modifier is a plain number or a tag-keyed Effect; no player input |
| Counterplay | PASS | thần thức cultivator with a soul art; Measured Stroke; accuracy stacks |
| Originality | PASS | all names are new |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/evade-dancer.fight.json` (Nguyên Anh) and `evade-dancer.ket-dan.fight.json` (Kết Đan). Observations from `fight.py` on the combat simulator, 20 fixed seeds, not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| Nguyên Anh: typical | 0 | 20 / 0 / 0 | 1.3 s | never | Hư Bộ, Điệp Lạc, Tán Phong, Cuồng Phong Quán (the foe dies first) | none |
| Nguyên Anh: typical | +1 | 20 / 0 / 0 | 1.8 s | never | same four | none |
| Nguyên Anh: top_end | 0 | 13 / 6 / 1 | 9.3 s | never | none | none |
| Nguyên Anh: top_end | +1 | 0 / 20 / 0 | 5.1 s | 4.7 s | none | none |
| Kết Đan: typical | 0 | 20 / 0 / 0 | 5.0 s | never | none | none |
| Kết Đan: typical | +1 | 20 / 0 / 0 | 10.5 s | never | none | none |
| Kết Đan: typical | +2 | 0 / 20 / 0 | 6.9 s | 5.7 s | none | none |
| Kết Đan: top_end | 0 | 0 / 20 / 0 | 2.6 s | 2.2 s | Tán Phong | none |
| Kết Đan: top_end | +1 | 0 / 20 / 0 | 1.5 s | 1.5 s | Tán Phong | none |

Notes: a first try had L2 over its cap (340 against 300); the layers were reduced to 260 plus 40 on the art. The Nguyên Anh top-end fight is shorter than the 35 s top-end mirror anchor, since the engine is unmodelled and the simulator gives no credit for the evade income. The Kết Đan fights at 5 s against a typical foe are quick because the file's layers sit above typical (INFO).

**Identity test** (`--without hu-bo`, proxy only): Nguyên Anh top_end +0 changed (9.3 → 10.8 s, wins 13 → 12), other Nguyên Anh matchups NO_CHANGE; Kết Đan typical +0, +1 and +2 changed (5.0 → 5.3 s, 10.5 → 13.2 s, 6.9 → 7.5 s), top_end NO_CHANGE.

**Unmodelled** (`model_note` and `UNMODELLED` lines): not modelled by the simulator: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape; enemies are exact at Qi Refining and fitted at Nguyên Anh. The file's own list: evaded hit pays linh lực (modelled as +regen and Hollow Step's restore); evaded hit adds Wind stack (modelled by art buff stacks); evaded hit fires riposte (trigger); Carried Off (modelled by Scatter Gale); a cap shift on evade. Also: Rhythm of the Miss (a condition) read as always on; Surplus Breeze (overflow) not modelled; the evade cap's accuracy subtraction is the simulator's, with the build's accuracy and evade as stated.

## New Concepts

**Hit-evaded event.** Rule needed: Combat Formulas I (evaded hit "fires no on-hit trigger", combat.md near line 660) and Effects rule 9 (events). An evaded hit fires a "hit evaded" event, readable by Effects, rate-bounded by `trig_budget` and `trigger_depth`. Bound: at most one event per hit. Breakdown line: "Evaded 12 of 30 hits: +12 % linh lực, 8 Wind stacks, 3 Replies." Serves: Reed-Shadow Dancer and any block, ward-recharge or counter build. Question for the user: should an evade fire on-hit triggers of the attacker?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Hit-evaded event, Evade Pays, Reply, Carried Off | Needs rule | combat.md Formulas I, effects.md rules 9 and 12 |
| Evade-over-cap readable (for Surplus Breeze) | Needs rule | combat.md Formulas I: report points clipped by `evade_cap` |
| Since-last-evade condition (Rhythm of the Miss) | Needs rule | effects.md conditions |
| Wind-Fed Edge, Wind damage, Veiled Aim | Needs key | a Wind-stack read, an element-damage key for Wind, a foe-accuracy key |
| Arts, technique, Cicada-Wing Sash, pill, formation, cluster | Needs key | records; no data file reads them |
