# The Brimming Tide (Mãn Triều)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A new player's mana build: a deep pool, a strong ward, arts that get stronger the fuller the pool. Teaches the linh lực economy.
> **Direction**: A, the Brimming Tide (keep the pool high and be paid for it). See "Directions considered".
> **Realm span**: Luyện Khí (Qi Refining) to Kết Đan (Core Formation) · **Power level**: ordinary · **Use**: player
> **Fit**: 6 Fits today · 9 Needs key · 5 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: no `pool_max` for the technique's keys; The fight: Brimming Cup is the engine and ran as a flat number)

## Directions considered

- **A. The Brimming Tide (Mãn Triều), chosen.** Pool kept near full by cheap arts and a refill art; damage is "more" per share of pool left, ward drain falls while the pool is high. Chosen because a starter build should teach the economy by rewarding the habit (do not overspend), and it is a stack of existing rules plus one reused Effect.
- **B. The Ebb Gambler (Lạc Triều), not picked.** Inverse: the emptier the pool, the harder the hit (Empty Vessel style). Not picked for a starter: it punishes the very habit a new player is learning, and it fits better as the rival that hunts this build.
- **C. The Drawn Well (Hấp Tỉnh), not picked.** Win by draining the enemy's pool into your own (a loop opener). Not picked: it teaches the enemy's economy, not the player's, and leans on drain Effects that do not exist yet.

## The Spine

- **The channel:** art hits (Water element), plus the ward as the second half of the pool. Layers L1 to L5 all used, ward layers W2 to W5 all used.
- **The enabler:** none. Brimming Cup (reused Effect) is the engine, but it opens no channel, so it is not an enabler.
- **The loop:** cast a cheap art every 3 s, a heavy one every 6 s, a refill art every 8 s; the ward drinks from the same pool; regeneration pays it all back, so the pool stays above about 80 %.
- **The engine:** Brimming Cup, "+2 % more for every 10 % of linh lực left" (up to +20 % at full), plus Still Water, which makes the ward cheaper while the pool is high. A full pool is damage and defence at once.
- **The sacrifice:** no crit worth the name, no reach (pierce), no burst. It cannot win in a first volley and does badly against a fast-burning or draining foe.
- **The arc:** Luyện Khí: learn to watch the bar. Trúc Cơ: Brimming Cup and the full loop. Kết Đan: the pool is deep enough that the ward is a wall and the refill art is a tempo choice.

## The Legend

Before the sects wrote down the Water canons, well-diggers in dry hill villages taught that a cistern kept full is worth three kept empty: the water pressure holds the walls. A failed-exam scholar copied that into breathing, and wrote the *Reading the Tide Canon* (Độc Triều Kinh): do not pour out what you cannot draw back.

Cultivators on this path are patient to the point of dullness. They are known to refuse a fight at less than full, and to walk away from a duel at 79 %. Over years the habit seeps into them: they cannot spend recklessly even when they should.

Burst fighters and drainers hate them. A Tide cultivator who is hit first and hard has nothing to be proud of, and a Drowning-facet (Chìm) cultivator turns the cistern into a hole.

## How It Fights

The Tide cultivator opens with the ward drinking a little and Tide Pulse every 3 s. The pool never drops far, because each art costs only 2 to 4 % of the pool and regeneration returns 3.5 % a second. Deep Well Seal lands every 6 s, and Drawing Breath every 8 s refills 7 % and puts two Water stacks on you, which push the pool up and regenerate it. The foe's pool runs dry around 20 s; the Tide's never does. The fight ends with the player standing at about a third of health.

**Signature moment:** at the 22 s mark the foe is dry and swinging with only a basic attack; the player's bar has not moved below 80 % all fight and the Brimming Cup line in the Breakdown reads "+19 % more, 96 % pool".

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Tide Pulse, Deep Well Seal | c_art 2.0 and 3.1 inside the art lint, Water tag | n/a | art hit | n/a | ○ arts | Công pháp | any Water build |
| 2 Rate | Art speed (`art_speed_pct`) | +5 % total; a deliberate small number | Increased | art | n/a | ◐ | Tree | any |
| 3 L1 | Water damage + damage (`attack_pct`) | +60 points | Increased | art, basic | L1 | ○ rows | Tree, Thủy Đạo | any Water build |
| 3 L2 | Canon passive: Water arts +40 more | +40 points | More | art | L2 | ○ | Công pháp | any Water build |
| 3 L3 | Water affix on a weapon | +20 points | Increased | art | L3 | ● | Artifact | any |
| 3 L4 | Still Pool Array + Clear-Spring Pill | +20 points | More | art | L4 | ○ | Formation, pill | any pool-based build |
| 3 L5, identity | Brimming Cup (reused) | +2 % per 10 % of pool left, up to +20 | Per | art | L5 | ○ | Canon ability | any ward build |
| 4 Crit | none | crit 5 %, mult 1.5 | n/a | n/a | n/a | n/a | n/a | n/a |
| 5 Reach | none | no pierce, no shred | n/a | n/a | n/a | n/a | n/a | n/a |
| 6 Past the cap | Spill Shield (reused) | regeneration over a full pool becomes a ward shield, up to 20 % of max | Overflow | ward | none | ○ | Tide-Bound Gourd | any regen build |
| 7 Fuel | Max linh lực, regeneration, tag art cost | pool x1.3, +1.5 pp regen, art cost -12 % | Increased | n/a | none | ● ○ | Tree, Uyên facet | any |
| 8 Survival | Still Water (new) | ward drain falls (ward efficiency +15) while pool at or above 80 % | Conditional | ward | W5 | ○ | Thủy Đạo Triều facet | any pool ward build |
| 8 Survival | Ward layers W2 to W5 | 50 / 40 / 30 / 20 points | More | ward | W2 to W5 | ● ○ | Tree, robe, array | any ward build |
| 9 Identity (top-end) | Depth Is Shield (new, Borrow) | 1 point of ward strength per 5 % of max linh lực above the realm base | Borrow | ward | W2 | ○ | Thủy Đạo Uyên keystone | any deep-pool build |

**Identity piece:** Brimming Cup. Without it the build is a plain Water caster with a fat pool; with it, the habit of keeping the pool high is the damage.
**Empty rungs:** crit and reach, both a sacrifice. Rate is small on purpose: art speed shortens cooldowns and drains the pool faster, which works against the engine.

Forms: Increased, More, Per, Conditional, Overflow, Borrow (top-end only), Cost cut: six.

| Layer | Points at Trúc Cơ | Multiplier | Sources |
|---|---|---|---|
| L1 | 60 | x1.60 | Tree, Water damage, Thủy Đạo lines |
| L2 | 40 | x1.40 | Canon passive |
| L3 | 20 | x1.20 | Weapon affix |
| L4 | 20 | x1.20 | Array, pill |
| L5 | 16 | x1.16 | Brimming Cup, haircut from +20 |
| M | | 3.74 | Typical 4.19 (hand-multiplied; below typical offence on purpose, defence is above) |

Ward layers W2 to W5: 50 / 40 / 30 / 20, against the typical 40 / 40 / 20 / 10 in the file's example; ws_base 40, ward efficiency 55.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water (Thủy), middling purity (about 60) | Water stacks add pool and regeneration, so the root is the economy; purity 60 is enough for the Canon's Water-only arts |
| Key talents | Deep Spirit (pool size), Calm Breath (regeneration); Comprehension for the Canon | The two stats the engine reads |
| The Way (Đạo) | Thủy Đạo (Nhược Thủy), the Uyên (Depths: linh lực) and Triều (Tides) facets | Uyên lines for pool and regeneration, Triều for Still Water. The facets are catalogued in dao.md; the specific nodes are proposals |

## Công Pháp

### Reading the Tide Canon (Độc Triều Kinh) — main, tier 2

"Do not pour out what you cannot draw back." Reaches Kết Đan.

```json
{"id": "doc-trieu-kinh", "name": "Độc Triều Kinh", "tier": 2, "tech_kind": "main",
 "names": ["thuy"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_pct", "value": 16}, {"stat": "linh_luc_regen_pct", "value": 0.5}],
 "abilities": [{"ability_id": "tide-pulse", "unlock_layer": 1},
               {"ability_id": "deep-well-seal", "unlock_layer": 3},
               {"ability_id": "drawing-breath", "unlock_layer": 5},
               {"ability_id": "brimming-cup", "unlock_layer": 7}],
 "seal_clusters": ["mãn-trì"], "origin": "authored"}
```

**Fit:** Needs key (abilities) · **Budget:** NOT ASSESSED. `linh_luc_pct` has no `pool_max` figure on this run; tier 2 budget is 2.0 and the two bonuses are small.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Tide Pulse (Triều Xung) | Canon layer 1 | qi, Water, hit, gives 1 Water buff stack 12 s | 2.0 | 3 % | 3 s | none | Needs key |
| Deep Well Seal (Thâm Tỉnh Ấn) | Canon layer 3 | qi, Water, seal, hit | 3.1 | 4 % | 6 s | none | Needs key |
| Drawing Breath (Hấp Triều) | Canon layer 5 | qi, Water, hit, restores 7 % pool, 2 Water buff stacks 15 s | 0.8 | 2 % | 8 s | none | Needs key |

Lint check: Tide Pulse limit 1 x (1 + 24 x 0.03) + 0.25 x 2 = 2.22, used 2.0. Deep Well Seal 1 + 0.96 + 1.25 = 3.21, used 3.1. Drawing Breath 1 + 0.48 + 1.75 = 3.23, used 0.8 (the rest is the restore). `fight.py` printed no `lint_over` and no `range`.

- **Tide Pulse. Effect:** a Water hit that also gives one Water buff stack. **Description:** A ripple that leaves a little more water behind it.
- **Deep Well Seal. Effect:** a seal-form Water hit; carries the Canon's L2 "more". **Description:** A palm that drops a stone into the cistern.
- **Drawing Breath. Effect:** a small Water hit, restores 7 % of maximum linh lực, gives two Water stacks. **Description:** Draw in what the tide gave back.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Luyện Khí | 3 | Tide Pulse, Drawing Breath | Common Ward | Learn the bar; Deep Well Seal not yet unlocked. Not run on the simulator |
| Trúc Cơ | 4 | Tide Pulse, Deep Well Seal, Drawing Breath, spare | Drain ward, strong | Defining realm; spare slot takes Gathering Tide (reused) |
| Kết Đan | 5 | the three, Gathering Tide, spare | Drain ward, strong | Pool deep enough that Still Water holds nearly all fight |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Deep Cistern Robe (Thâm Trì Bào) | Artifact, ward | armour base, any, tier by realm | Ward strength and max linh lực affixes: W3 of 40 | Fits today |
| Water-affix weapon | Artifact, weapon | any weapon base, Water affix | L3 of 20 | Fits today |
| Tide-Bound Gourd (Hệ Triều Hồ Lô) | Artifact, utility, named | new base, signature | Carries Spill Shield: regeneration over a full pool becomes a ward shield. History: a village well-keeper's gourd, never emptied in forty years | Needs key |
| Still Pool Array (Tĩnh Trì Trận) | Formation | new | Prepared: Water arts +, ward W4 of 30 | Needs key |
| Clear-Spring Pill (Thanh Tuyền Đan) | Pill | new | Prepared: raises max linh lực for the fight | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Maximum linh lực (`linh_luc_pct`) | +1.2 % small, +8 % notable | The deep pool | Fits today |
| 2 | Linh lực regeneration (`linh_luc_regen_pct`) | +0.15 % / +1 % | Keeps the pool full | Fits today |
| 3 | Ward strength (`defense_pct`), ward efficiency | +1.2 % / +8 % each | The strong ward | Fits today |
| 4 | Water damage | +2 % / +12 % | L1 | Needs key |
| 5 | Water art cost | -1 % / -6 % | Cheaper arts | Needs key |
| 6 | Full Sea (reused keystone) | bonus while pool above 80 % | A second payoff for the same habit | Needs rule |

### Hidden cluster idea: Full Cistern (Mãn Trì)

Theme: Water Way (Thủy Đạo), the Depths (Uyên). Water affinity, sealed, 8 acupoints, sealed by the Reading the Tide Canon (`seal_clusters`). Small acupoints: max linh lực, regeneration, ward efficiency. Two notables: Still Water and a pool notable of +8 %. No capability. An idea for the tree rework, not data.

## Đạo

Thủy Đạo (Nhược Thủy), existing Way. Nodes that matter: the Uyên facet stat lines (pool, regeneration), the Triều facet's Brimming Cup-linked notable and Still Water, and one Uyên keystone, Depth Is Shield (new, Borrow). No new Way needed.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Luyện Khí | Two arts and a ward; the bar is the lesson | Tide Pulse, Drawing Breath | The first duel lost by overspending |
| Trúc Cơ | Full loop, Brimming Cup lit | Deep Well Seal, Cup, robe | Refusing a fight at 79 % |
| Kết Đan | The ward is a wall; Spill Shield turns surplus into shield | Gourd, Gathering Tide, Depth Is Shield | The first foe who simply will not tire |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical same realm | wins (20 to 0) | Foe runs dry first at about 22 s |
| Burst opener (top-end) | loses | Dies in 1 to 2 s; no ward fast enough |
| Linh lực drainer (Chìm facet) | loses | The pool is the engine and it is attacked |
| Higher realm, one up | loses | 11.5 s at Trúc Cơ, 8.0 s at Kết Đan; pool never reaches Cup range |
| Body cultivator (thể tu) | even | Body block and resistance ignore the ward, and wins take the fatigue clock |

**Counter:** a pool-burning foe (a Chìm-facet Vụ Đạo cultivator with qi burn ticks) or a thể tu who ignores the ward and outlasts it. The player counters by carrying a cleanse, or switching Drawing Breath for Gathering Tide to refill faster.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique bonuses on `linh_luc_pct` and `linh_luc_regen_pct`; no `pool_max` on this run. Slots 3 of 4 and 3 of 5, artifacts within `equip.max_slots` |
| Validity | PASS | Realms `truc_co`, `ket_dan` accepted by the loader; tier 2 reaches Core Formation (layers 9, max_realm CF); element Water; no aux art |
| Stack | PASS | Six forms, identity piece present; crit and reach named as sacrifices; all layers L1 to L5 and W2 to W5 filled. Identity test ran on Drawing Breath only, not on Brimming Cup |
| Scaling | PASS (INFO) | Hand-multiplied M 3.74 at Trúc Cơ and 4.79 at Kết Đan against typical 4.19 and 5.48; ward layers above typical |
| The fight | NOT ASSESSED | The loop runs (pool never dry, 20 to 0), but Brimming Cup is the engine and ran as a flat +16 in L5 |
| Reuse | PASS | 9 pieces reused; 2 new modifiers, one of them `Borrow` is a top-end upgrade; signature pieces: Tide-Bound Gourd |
| NPC use | PASS | Every piece is a stat, a pool-share condition, or a Water art; the generator can roll them and a Breakdown line can read "+19 % more, 96 % pool" |
| Counterplay | PASS | Chìm-facet drainer; thể tu; burst opener; one-realm-up foe |
| Originality | PASS | Names are plain images (cistern, tide, gourd); no novel or game names |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/starter-tide.fight.json` (Trúc Cơ) and `starter-tide.ket-dan.fight.json`. Observations from `fight.py` on the combat simulator, 20 fixed seeds, not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Trúc Cơ | 0 | 20 / 0 / 0 | 30.8 s | never | none | none |
| typical, Trúc Cơ | +1 | 0 / 20 / 0 | 11.5 s | 10.9 s | none | none |
| typical, Trúc Cơ | +2 | 0 / 20 / 0 | 4.0 s | 4.0 s | Deep Well Seal, Drawing Breath | none |
| top_end, Trúc Cơ | 0 to +2 | 0 / 20 / 0 | 2.0, 1.0, 1.0 s | 2.0, 1.0, 1.0 s | all arts | none |
| typical, Kết Đan | 0 | 20 / 0 / 0 | 26.3 s | never | none | none |
| typical, Kết Đan | +1 | 0 / 20 / 0 | 8.0 s | 8.0 s | none | none |
| typical, Kết Đan | +2 | 0 / 20 / 0 | 4.0 s | 3.7 s | Deep Well Seal, Drawing Breath | none |
| top_end, Kết Đan | 0 to +2 | 0 / 20 / 0 | 1.6, 1.0, 1.0 s | same | all arts | none |

The foe ran dry at 21.7 s (Trúc Cơ) and 18.5 s (Kết Đan). Health left in the wins: 37 % and 29 %. The Kết Đan fight is a little short of 30 s; the build's offence is under typical, so the faster win comes from a stronger realm-scaled opening, not extra damage (noted, not changed).

**Identity test** (`--without drawing-breath`): Trúc Cơ typical +0 changed (30.8 to 34.0 s, health left 37 to 32 %), +1 changed (11.5 to 11.2 s); other matchups NO_CHANGE. Kết Đan typical +0 changed (26.3 to 28.3 s, health left 29 to 24 %); others NO_CHANGE. So the refill art matters in the fight the build is meant to win. Brimming Cup itself was not removable.

**Unmodelled:** Brimming Cup (flat +16 in L5, real value +2 % per 10 % of pool, up to +20); Still Water (ward drain fixed, no pool condition); Spill Shield (overflow into a shield); the robe, weapon, array, pill and gourd are folded into layer numbers; the 4th and 5th slot arts; simulator `model_note`: enemies exact at Qi Refining and fitted at truc_co (Combat Formulas B: re-derive); not modelled: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape. The Luyện Khí realm was not run.

## New Concepts

None beyond staged keys. Two readable conditions are needed: the pool share on a ward drain (Still Water), and the pool above full (Spill Shield). Both are in `starter-tide.suggestions.md`.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Brimming Cup (reused) | Needs rule | Effect reading own pool share into L5 `damage_more` |
| Spill Shield (reused) | Needs rule | Overflow event on regeneration, action "raise a ward shield" |
| Still Water | Needs rule | Ward efficiency conditional on pool share (Combat Defence & Healing Formulas A) |
| Depth Is Shield | Needs rule | Borrow: max linh lực counts toward ward strength |
| Tide arts, Canon abilities | Needs key | Art records and ability entries |
| Gourd, array, pill | Needs key | A base, a formation record, a pill fight payload |
| Water damage, Water art cost | Needs key | Tag-scoped tree rows |
