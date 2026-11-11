# The Red Hearth Ladder (Xích Lô Môn Giai Thê)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: The standard build a mid-sized Fire sect teaches its disciples, realm by realm: what an ordinary NPC of that sect carries at each realm, so the world's 5,000 cultivators are built from it. Ordinary power, coherent, beatable.
> **Direction**: The Burn Hearth Curriculum (below, "Directions considered")
> **Realm span**: Luyện Khí – Kết Đan · **Power level**: ordinary · **Use**: NPC or sect archetype
> **Fit**: 4 Fits today · 9 Needs key · 2 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the technique budget needs `pool_max` for its two bonus keys, which `bonus_pool` does not hold)

## Directions considered

**Chosen: The Burn Hearth Curriculum (Chân Hỏa Giáo Trình).** For an NPC archetype the strongest answer is the plainest coherent kit: a Burn-stack Fire sect whose sustain comes from the Burn itself, with each realm adding exactly one rung (arts, then pill, then array). It is the only direction that works as a template the generator can copy 5,000 times: every piece is short, readable in a Breakdown, and the identity piece (Embers Feed the Hearth) is the thing a player learns to break.

Not picked:
- **The Forge-Disciple (Luyện Khí Đệ Tử):** a sect of flying-sword weapon smiths, damage in L3 gear. Rejected: it makes the average NPC an item race and a rare artifact becomes the build, which is the opposite of "ordinary".
- **The Ash Ledger (Tro Trướng):** a sect that pays lifespan and heart demon for burst. Rejected: dark-path power is not ordinary, and a world of 5,000 of them would break the macro targets.
- **The Warding Pyre (Hộ Hỏa Đàn):** a Fire ward-and-body sect that lasts rather than kills. Rejected for the standard build: needs ward-model rules that do not exist, and fights run long, which is fine only as a rare variant (the guide lists it as an upgrade path).

## The Spine

- **The channel:** Burn ticks (Fire debuff stacks, `c_tick` 0.019 per stack, no cap, no crit, meets resistance) plus two cheap Fire art hits that apply the stacks. L1 to L4 matter; L5 only on the Fire art hits through Kindled Wound.
- **The enabler:** none. A sect curriculum is a stack of what exists.
- **The loop:** a fast cheap art (Kindle Palm) lays 2 Burn stacks every 2 s, a slower art (Red Lotus Ring) lays 3 and hits harder, and each Burn tick feeds linh lực back.
- **The engine:** Embers Feed the Hearth (identity): a share of each Burn tick returns as linh lực, so the more Burn on the target the longer the disciple can keep casting. The closing cost: direct Fire hits deal 15 % less, so the disciple wins by stacks, not by a single blow.
- **The sacrifice:** no crit, no pierce, no burst, no soul defence, no cleanse. It wins slow fights and loses fast ones.
- **The arc:** Qi Refining one art and a primer (a spark), Foundation a second art, a pill and Đạo nodes (a hearth), Core Formation a third art and the sect's array (a furnace). Each realm adds one rung and nothing changes shape.

## The Legend

The Red Hearth Sect (Xích Lô Môn) began as a charcoal-burners' guild that taught its apprentices one rule: never let the fire go out. Its founder, an old kiln-keeper, could not afford strong techniques, so the sect built its teaching on keeping a small fire alive cheaply for a long time.

Every disciple learns the same ladder: breath first, then the palm, then the ring, then the lance. A gifted one is promoted faster and a dull one stays on the first rung for years, but nobody learns a different path. The sect is mid-sized and respectable, and its outer disciples fill the world's inns and guard posts.

Water and Wood sects, who can put out a fire or smother it, regard Red Hearth as a nuisance. Cleansing healers hate it, because the Burn never stops arriving.

## How It Fights

The disciple opens with Kindle Palm, which lays Burn quickly, then adds Red Lotus Ring when its timer is up. The enemy's ward drains against the hits while the Burn ticks past it, and every tick gives the disciple a little linh lực back, so the pool that usually runs dry first stays full. The fight is a slow squeeze: about 30 s at Foundation.

**Signature moment:** at 15 to 20 s the enemy's pool is at a fifth, the disciple's is still above half, and a third Red Lotus Ring lands on a target already carrying a dozen stacks.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Burn stacks | 2 to 4 stacks per cast, `c_tick` 0.019 per stack | none | tick | none | ● | Arts | any Fire build |
| 2 Rate | Art speed (Fire tag) | +2 / +4 / +6 % art speed | Increased | art | none | ○ tree row | Tree acupoints | Ninth Bell, any fast-art build |
| 2 Rate | First firing comes sooner | −4 to −8 % to the first art's wait | Timing | art | none | ○ tree row | Tree acupoints | any opener |
| 3 Mult L1 | Fire damage, Damage over time | +2 % small nodes, 26 to 55 points by realm | Increased | tick, art | L1 | ○ tree rows | Tree acupoints | any Fire or poison build |
| 3 Mult L2 | Deep Heat (Nhiệt Thâm) | +0.4 % more Burn tick damage per Burn stack on the target, up to 20 stacks | Per | tick | L2 | ○ new | Công pháp Canon, cluster notable | Wildfire (Wood-Fire) builds, any Burn build |
| 3 Mult L2 | Technique "more" on Fire arts | +20 points L2 from the Canon at layers | More | art | L2 | ○ | Công pháp | any Fire technique |
| 3 Mult L3 | Ember Rod, Hạ-phẩm robe | 40 points gear | Flat gear | art, tick | L3 | ● / ○ | Artifacts | any Fire build |
| 3 Mult L4 | Hearth-Warming Pill, Gathering Flame Array | 20 points of preparation | Flat | art, tick | L4 | ○ | Pills, formations | any Fire build |
| 3 Mult L5 | Kindled Wound (existing Effect) | Fire parts +15 more vs a target bearing your Burn | Conditional | art | L5 | ● Effects Starter | Đạo / công pháp | any Fire art build |
| 4 Crit | none | ticks never crit | n/a | n/a | n/a | n/a | n/a | sacrifice |
| 5 Reach | none | no pierce, no shred | n/a | n/a | n/a | n/a | n/a | sacrifice |
| 6 Past cap | none | Burn has no cap since #44 | n/a | n/a | n/a | n/a | n/a | not needed |
| 7 Fuel | Embers Feed the Hearth | each Burn tick restores linh lực; direct Fire hits −15 % | Trigger + Trade | tick | none | ○ staged | Cluster keystone | Wildfire, Two Clocks, starter-flame |
| 7 Fuel | Fire art cost, regeneration | −3 to −4 % art cost, +0.2 to +0.5 pp regen | Increased | any | none | ○ / ● | Tree, Primer | any art build |
| 8 Survival | Common Ward, Red Hearth Robe | the realm's typical ward, robe adds a little health | none | defence | W2–W5 | ● | Wards, artifacts | any NPC |
| 9 Identity | Embers Feed the Hearth | see above | Trigger + Trade | tick | none | ○ | Cluster keystone | see above |

**Identity piece:** Embers Feed the Hearth. Removing it (`--without keystones.k_burn`) cuts Foundation wins from 11 to 4 of 20 and Core Formation from 12 to 6.
**Empty rungs:** crit, reach (pierce, shred, accuracy) are sacrifices. Past-the-cap is not a gap: Burn has no cap.

| Layer | Points at Foundation / Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 26.5 / 55 | ×1.27 / ×1.55 | tree Fire and DoT nodes, Đạo Chân Hỏa nodes |
| L2 | 40 | ×1.4 | Canon "more" on Fire arts and Deep Heat |
| L3 | 40 | ×1.4 | Ember Rod, robe |
| L4 | 20 | ×1.2 | pill, array |
| L5 | 0 on the layers, +15 on Fire arts | ×1.15 on arts | Kindled Wound; empty for ticks (L5 only touches hits) |

The disciple is below the typical L1 anchor (the typical Foundation L1 is about 62 points) and pays for it with sustain. That is deliberate: an ordinary sect disciple is a sustain build with a thin tree.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire, purity 70 / 80 / 85 by realm; no variant | Fire-tag cost and damage nodes are cheap; purity feeds the Canon's speed |
| Key talents | Comprehension (technique speed), a plain Physique | A sect disciple is made by the curriculum, not by a gift |
| The Way (Đạo) | Hỏa Đạo (Phần Thiên), Chân Hỏa branch, a few nodes from Foundation | Fire's Burn facet; the Đạo exists in the catalogue (dao.md), the node list is not checked here |

## Công Pháp

### Kindling Breath Primer (Khơi Hỏa Sơ Quyết) — main, Hoàng tier

Reused from staging (starter-flame): the first thing every outer disciple is taught. Fits today (one data row). Max realm Foundation, so it carries the disciple through Qi Refining and Foundation.

### Red Hearth True Canon (Xích Lô Chân Kinh) — main, Huyền tier

The inner-disciple canon, "the fire that is only ever kept, never thrown".

```json
{"id": "red_hearth_true_canon", "name": "Xích Lô Chân Kinh", "tier": 1, "tech_kind": "main",
 "names": ["hoa"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_regen_pct", "value": 0.6}, {"stat": "damage_over_time_pct", "value": 8}],
 "abilities": [{"ability_id": "kindle_palm", "unlock_layer": 1}, {"ability_id": "red_lotus_ring", "unlock_layer": 3},
               {"ability_id": "cinder_lance", "unlock_layer": 7}, {"ability_id": "hearth_banner", "unlock_layer": 9}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key (abilities are empty in every shipped template; `damage_over_time_pct` is a catalogue ○). **Budget:** NOT ASSESSED: the bonus keys are not in `bonus_pool`, so Σ value / pool_max cannot be computed. Tier `max_realm` is `ket_dan` (data), so the span is reached; two small bonuses sit well inside the Huyền budget of 2.0 on any reading.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Kindle Palm (Dẫn Hỏa Chưởng) | Primer / Canon L1 | qi, fire, palm, burn | 1.4 | 0.02 | 2 s | none | Needs key |
| Red Lotus Ring (Xích Liên Ấn) | Canon L3 | qi, fire, seal, burn | 2.9 | 0.04 | 5 s | none | Needs key |
| Cinder Lance (Tẫn Hỏa Thương) | Canon L7 | qi, fire, burn | 3.4 | 0.05 | 7 s | none | Needs key |
| Hearth Banner (Lô Kỳ) | Canon L9 | buff, fire | 0 | 0.03 | 12 s | none | Needs key |

Lint: 1.4 ≤ 1.73 (0.02, 2 s), 2.9 ≤ 2.96 (0.04, 5 s), 3.4 ≤ 3.70 (0.05, 7 s). All PASS.

- **Kindle Palm.** Effect: a Fire hit, 2 Burn stacks for 8 s. *The first thing a charcoal apprentice learns: to wake a dead fire.*
- **Red Lotus Ring.** Effect: a Fire hit, 3 Burn stacks for 10 s and 2 Fire buff stacks for 12 s on the caster. *A ring of coals laid under the enemy's feet.*
- **Cinder Lance.** Effect: a Fire hit, 4 Burn stacks for 10 s. *What remains when a hearth burns down: a hot, narrow thing.*
- **Hearth Banner.** Effect: no damage, 3 Fire buff stacks for 20 s (+1.2 % damage dealt each). *A rag on a pole, kept in the sect hall.*

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Kindle Palm, Red Lotus Ring, (empty) | Common Ward | a spark: primer, plain robe |
| Foundation | 4 | Kindle Palm, Red Lotus Ring, (Hearth Banner for senior), (empty) | Common Ward | Ember Rod, Hearth-Warming Pill, Đạo nodes |
| Core Formation | 5 | Kindle Palm, Red Lotus Ring, Cinder Lance, (Hearth Banner), (empty) | Common Ward | Canon, sect array, Hạ-phẩm robe |

Empty slots are real: the sect teaches few arts and leaves room for a talisman or one the disciple finds.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Ember Rod (Xích Lô Trượng) | artifact, weapon | per staging (Fire affixes), Hạ phẩm, realm-matched | L3 gear points; Fire element affinity | Needs key (Fire affixes) |
| Red Hearth Robe (Xích Lô Môn Phục) | artifact, body | `giap`, Phàm to Hạ phẩm, realm-matched; affixes Hộ Thân, Fire affinity | survival rung; the sect uniform | Fits today |
| Hearth-Warming Pill (Noãn Lô Đan) | pill | n/a | L4 preparation points, taken before a fight | Needs key |
| Gathering Flame Array (Tụ Hỏa Trận) | formation | n/a | L4 ground; the sect hall's array, in force only at home | Needs key |

*History:* the robe is dyed with kiln soot; a disciple who loses it loses their standing as well as their armour.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Fire damage, Damage over time | +2 % small, +12 % notable | L1 | Needs key |
| 2 | Fire art cost | −1 % small, −6 % notable | fuel | Needs key |
| 3 | Linh lực regeneration | +0.15 % small | fuel | Fits today |
| 4 | Art speed (Fire tag) | +1 % small | rate | Needs key |
| 5 | Embers Feed the Hearth (keystone) | 25 % of tick damage as linh lực; Fire hits −15 % | identity | Needs rule |

### Hidden cluster idea: Hearth Keeper's Line (Lô Thủ Mạch)

Theme: Fire, an open cluster in the Fire land. Seven acupoints: three small Fire-damage/DoT points, two Fire art cost, one regeneration, then a notable (Deep Heat) and the keystone Embers Feed the Hearth farthest from the entry. No capability. An idea for the tree rework, not data.

## Đạo

Hỏa Đạo (Phần Thiên), Chân Hỏa (Burn) branch. A few small nodes from Foundation; nothing new proposed. The catalogue lists the branch; the node data was not read for this build.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | two cheap arts, slow squeeze | Primer, Kindle Palm, Red Lotus Ring | outer disciple; sweeps the sect hall |
| Foundation | same loop, more sustain | Ember Rod, pill, Đạo nodes, Banner | picked for a patrol; first real fights |
| Core Formation | three arts, fuller pool | Canon, Cinder Lance, array | elder track; teaches the next intake |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Same-realm typical cultivator | even | 11-9 at Foundation, 12-7 at Core Formation |
| Cleanser or healer | loses | strips Burn stacks; Withering is not needed |
| Heavy ward drain build | even | ward blocks the arts, the Burn ticks past it |
| Thể tu with a big body shield | loses | Burn wears the shield down only slowly |
| Anyone a realm above | loses | suppression; 0-20 in the matrix |
| Stagnation curser | loses | halves regeneration and so the Embers loop |

**Counter:** a cleanser, a Stagnation curse, or a first-volley burst that finishes the fight before stacks matter.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | art lint PASS on all four arts; technique budget needs `pool_max` for `linh_luc_regen_pct` and `damage_over_time_pct`, not in `bonus_pool` |
| Validity | PASS | fire element, `truc_co`, `ket_dan`, Huyền `max_realm` ket_dan, Hoàng reaches truc_co; no aux technique |
| Stack | PASS | 7 forms (Increased, More, Per, Conditional, Trigger, Trade, Timing); identity test changed 11 to 4 and 12 to 6; L5 empty for ticks stated |
| Scaling | PASS | L1 below typical anchor by design; no layer above the typical anchors. INFO: L3 40 and L4 20 are carried as typical points |
| The fight | PASS | Foundation 29.2 s 11-9; Qi Refining 32.3 s 19-1; Core Formation 20.8 s 12-7-1. INFO: Core Formation is under the 30–60 s band (the fitted enemy). Unmodelled pieces listed below |
| Reuse | PASS | 5 staged pieces and 5 tree rows reused; 8 new, none signature except Deep Heat's second home is shared |
| NPC use | PASS | every piece is a data row the generator can pick by realm; one line each explains it in a Breakdown |
| Counterplay | PASS | cleanser, Stagnation, a realm above, big body shield |
| Originality | PASS | names original; Burn-stack structure is the game's own |

## Fight Results

Input: `sect-ladder.fight.json` (Foundation), `sect-ladder.luyen-khi.fight.json`, `sect-ladder.ket-dan.fight.json`. Observations from `fight.py` on the combat simulator, 20 fixed seeds.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Qi Refining | 0 | 19 / 1 / 0 | 32.3 s | 25.6 s | none | none |
| typical, Foundation | 0 | 11 / 9 / 0 | 29.2 s | 19.8 s | none | none |
| typical, Core Formation | 0 | 12 / 7 / 1 | 20.8 s | 16.5 s | none | none |
| typical, one realm up (all) | +1 | 0 / 20 / 0 | 4 to 8 s | 3 to 7 s | red-lotus-ring, cinder-lance at +2 | none |
| top_end (all) | 0 | 0 / 20 / 0 | 1.0 to 2.0 s | about 1 s | most arts | none |

**Identity test** (`--without keystones.k_burn`): `identity typical+0 changed` at all three realms: Qi Refining 19 to 14 wins, Foundation 11 to 4, Core Formation 12 to 6. NO_CHANGE elsewhere (realm-up and top-end fights end before the loop matters).

**Unmodelled:** Kindled Wound is applied unconditionally on the damage arts (true value lower early); Embers Feed the Hearth is approximated by `k_burn` and its 15 % direct-hit cost is folded into the art coefficients; Deep Heat, Hearth Banner, the pill and array, the Đạo nodes and the robe's affixes are carried by typical points or not run. Simulator `model_note`: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield and escape are not modelled.

## New Concepts

**Sect curriculum (Môn Quy Giáo Trình).** A sect record listing, per realm, the technique, arts, artifact base, pill, array and Đạo nodes its disciples carry, plus a talent grade (laggard, plain, gifted) that moves a disciple a rung along the ladder. The NPC generator reads it to build a sect's members, so 5,000 cultivators come from a few dozen records. Rule needed: NPC Builds (#24) and Sects & Missions (#26), neither has a GDD yet. Bounds: one record per sect, one technique per realm; Breakdown line: "Red Hearth curriculum, Foundation, plain grade". Serves any sect archetype (the other starter builds' sects) and rogue-cultivator generation. Question for the user: should a curriculum be authored data or derived from a sect's elements?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Deep Heat | Needs key | a Per-form stat on tick damage, scoped burn, with a stack cap |
| Red Hearth True Canon, four arts | Needs key | technique abilities (empty today), art records |
| Ember Rod, Hearth-Warming Pill, Gathering Flame Array | Needs key | Fire affixes; a pill's fight payload; a combat formation |
| Embers Feed the Hearth | Needs rule | an Effect on the tick event, action "restore linh lực" (Effects rule 6) |
| Sect curriculum | Needs rule | NPC Builds (#24) and Sects & Missions (#26) |
| Hearth Keeper's Line | cluster idea | tree rework |
