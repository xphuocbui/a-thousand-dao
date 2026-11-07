# The Level Ground (Bình Địa Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Wins before the fight: the formation master who chooses the ground. L4 and ground tags are the whole game, and a blind fight is the real danger. It should still do something visible in the opening seconds. Defined at Foundation Establishment or Deity Transformation."
> **Direction**: L4 stops at ×2.5, so stacking it cannot be the whole game. The stronger idea is to change what the other layers are worth. On this ground a law caps them for everyone, and only what was laid in the earth still counts.
> **Realm span**: Tested at Nascent Soul and Deity Transformation; earlier realms not run · **Power level**: top-end on laid ground, ordinary or dead without it · **Use**: player build, or the master of a sect's home mountain
> **Fit**: 2 Fits today · 13 Needs key · 8 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and Old Bund sits outside the art lint)

## The Spine

- **The channel:** art hits with the `formation` source tag, on L1 and L4, fired by a laid array and paid in linh lực.
- **The enabler:** Ground Law, which a laid formation carries. It opens one fight constant set by you, for both sides. It closes everything: with no ground laid, the law, the walls and five of seven slotted arts are gone.
- **The loop:** read the enemy, lay the right law, let them come. Five small channels open on the first pulse, and again at t = 4.
- **The engine:** two halves, and the law is only one. The top-end anchors sit on the hard caps of L2 to L5, and Level Ground caps those layers at the ordinary anchors, so a top-end's M falls from 324 to 12 (Taken Ground also holds its L4 to 20). The other half is the Bunds: Old Bund and Deep Bund add +2.05 past the art lint, so a laid art at cost 0.03 runs `c_art` 3.8 against a lint of 1.86. Take both Bunds away and the win at 4 s on 87 % becomes a loss at 20 s with the enemy on 51 % (`variants/level-ground-no-bunds.fight.json`). Take either one alone and nothing changes, because they are redundant at this size.
- **The sacrifice:** no answer to a blind fight, none to soul, none to an enemy who will not come. Once laid, the ground holds them: leave for long and the years reset.
- **The arc:** from a first bund around one paddy to two hundred years of standing water. The field gets stronger as the people who helped build it die.

## The Legend

A paddy has to be dead level or the water will not sit, and the families of the upper terraces have spent a thousand years on that one fact. Their oldest method is not a fighting art. It is how to stake a field so that water finds its height and nothing in the field stands above anything else. The first cultivator to walk it had been given the field as a wedding gift, and stayed.

The world holds perhaps three cultivators at Deity Transformation. One of them is an old farmer in a valley that no army has ever crossed, who has outlived five generations of their own children and buried each in the same ground, and has never once gone to see where the grandchildren settled. A letter comes, sometimes, from a child in danger far away. Two hundred years of standing water end the season the farmer leaves. It is a very quiet place. Sects send their best there to learn what their best is worth, and the gate is always open.

## How It Fights

An elder walks onto the terraces and feels three hundred years of perfect gear go flat. On the first pulse five channels open at once and the water comes from every side, none of it much. Three seconds later it comes again, into a ward with nothing left, and the fight is over.

**The signature moment:** a same-realm top-end who kills this cultivator in one second on open ground (dead at t = 1, enemy on 82 %, with `--without ground_law`) dies at 4 s on the laid ground with the master on 87 %.

**What the numbers turned around:**

1. **The great sluice was the wrong art.** The plan was one huge flood at t = 1, `c_art` 4.65 for a fifth of the pool. It did 4 % of the damage and cost the master their ward (`variants/level-ground-great-sluice.fight.json`: 83 % health and an empty pool, against 87 % and 6 %). Five channels at 0.03 do the job, because Old Bund adds the same flat coefficient to all of them. So the array became many small ditches, as a real field is.
2. **Level Ground does nothing to ordinary people.** The master at Nascent Soul beats a same-realm top-end in 4 s and loses to an ordinary Deity in 5 s (`variants/level-ground-nascent.fight.json`). It is a weapon against the excellent.
3. **The wrong law is death.** Deep Mud against the same top-end: dead at 3 s, enemy on 80 % (`variants/level-ground-mud.fight.json`).

## Enabler

**Ground Law (Địa Luật)**, carried by a formation in the Array Đạo's Field branch and laid before the fight.

- **Opens:** one law on this ground. A law moves listed Combat keys for the length of the fight, for both sides, within an authored range. One law to a ground.
- **Closes:** needs a foreseen fight, or an ambush on ground where the formation already stands. In a blind fight it does not exist, by rule 12, even at home.
- **Found:** the Field branch, after decades of formation work. Laying a law takes seasons and pays yearly upkeep like any formation.

| Law | What it moves | Against | Result |
|---|---|---|---|
| Level Ground (Bình Địa) | L2, L3, L5 count at most 40, 40, 10 | Stacked specialists | Same-realm top-end: win, 4 s on 87 % |
| Deep Mud (Thâm Nê) | `cooldown_min` 3 s | Art-speed rushers | Win, 4 s on 91 %, against 4 s on 77 % under Level Ground (`-rush-mud`, `-rush-level`) |
| Dry Season (Hạn Quý) | `regen_base` 0, added to Level Ground to test it | Regeneration | Added nothing here: same win, pool 0 % (`-dry`). Kept for NPC grounds |

## The Stack

Sizes on new modifiers are first guesses. Ladder for the formation art hit. The forced push cut the plain L4 stack and looked at the other layers instead, which is where Ground Law came from.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Old Bund (Cựu Đê) | +0.05 to the coefficient of arts with the `formation` source tag per 10 years the formation has stood, to +1.0 at 200 years | Flat base | art | none | ○ | Đạo | any standing formation, any sect's home array |
| Rate | Standing Water (Tích Thủy) | A formation's timer runs from the day it was laid: its arts first fire at the first pulse | Timing | art | none | ○ | Đạo | any talisman or trap source |
| Multiplier | Damage (`attack_pct`) | +240 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Formation power (`formation_power_pct`) | +150, on the formation's 60 points: L4 +150 | Increased | art | L4 | ● | Tree | **Catalogue row** |
| Multiplier | Known Ground (Thục Địa) | +25 points per ground tag at this place, if you have lived a full cycle of seasons there (`home`, `paddy`, `vein`: +75). The only part that survives a blind fight at home | Per | any | L4 | ○ | Sealed cluster | any hermit, Spirit Farming builds |
| Multiplier | New Rice Wine (Tân Mễ Tửu) | Pill, +30 points, foreseen only | More | any | L4 | ○ | Alchemy | anyone with a field |
| Reach | **Level Ground (Bình Địa)** | The law above. Reach by removing what they brought | Cap shift | any | none | ○ | Formation | any sect's gate, any boss arena |
| Reach | Taken Ground (Chiếm Địa) | A ground holds one formation: the other side's L4 counts at most 20 | Rule swap | any | L4 | ○ | Formation | any home-ground defender |
| Past the cap | Deep Bund (Thâm Đê) | L4 points past the cap add +0.01 each to formation arts' coefficient (+1.05 here) | Overflow | art | none | ○ | Sealed cluster | any preparation build |
| Survival | Field Walls (Điền Thành) | While your formation stands, `formation_power_pct` also counts as ward strength and efficiency (+150) | Redirect | any | none | ○ | Sealed cluster, capability | any formation user |
| Fuel | Untended Field (Hoang Điền) | Leave the ground for 5 years, or miss upkeep, and Old Bund resets to 0 | Trade | none | none | ○ | Đạo | any bound hermit |

**Identity piece:** Level Ground. Without the law the same fight is a loss at t = 1. It is half the engine: the Bunds are the other half (see The Spine).
**Empty rungs:** Crit is a sacrifice. L2 and L5 could still hold 40 and 10 under the law. They stay empty because nothing in this life was spent on them, which is why a blind master has so little.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | 240 | ×3.20 | Tree |
| L2 | 0 | ×1.00 | Sacrifice |
| L3 | 40 | ×1.40 | Ward and body pieces only: no weapon |
| L4 | 255 | ×2.50, 105 clipped | Array 150, Known Ground 75, New Rice Wine 30 |
| L5 | 0 | ×1.00 | Sacrifice |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth 60, Water 40 | Earth holds Water: a bund is the overcoming cycle, built by hand |
| Key talents | Comprehension, then Physique | Formation skill, and long years |
| The Way (Đạo) | Array, Field branch (below) | Ground Law and everything that reads a laid formation |

## Công Pháp

### Paddy Keeper's Canon (Thủ Điền Kinh) — main, Thiên giai

Half of it is a planting calendar, and the disciples who skip that half do not get the other half to work.

```json
{"id": "thu_dien_kinh", "name": "Thủ Điền Kinh", "tier": 3, "tech_kind": "main",
 "names": ["tho", "thuy"], "layers": 15,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15},
             {"stat": "herb_growth_pct", "value": 25}],
 "abilities": [{"ability_id": "headrace", "unlock_layer": 2}, {"ability_id": "furrow", "unlock_layer": 5},
               {"ability_id": "ditch", "unlock_layer": 8}, {"ability_id": "seep", "unlock_layer": 11},
               {"ability_id": "rising_water", "unlock_layer": 14}],
 "seal_clusters": ["bund_and_channel"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 1 + 1 + 1 = 3.0 against Thiên's 4.0, three bonuses as the tier's `bonus_count`

## Arts

All are paid in linh lực on the common drain ward. An art marked laid is dead without the formation. Slot order is saved, so whatever sits in those slots in a blind fight is an empty hand. Keeping fewer laid arts is the only insurance, and it has a price.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Rising Water (Thăng Thủy) | Technique, laid | qi, water, formation | 2.45 | 0.08 | 3 s | none | Needs key |
| Ditch (Điền Câu) | Technique, laid, 2, 5, 8, 11 | four forms: body and water, qi and water, body and earth, qi and earth; formation | 1.75 | 0.03 | 3 s | none | Needs key |
| Hoe Stroke (Sừ Kích) | Way art | body, earth | 2.45 | 0.08 | 3 s | none | Needs key |
| Walk Home (Quy Gia) | Escape art | escape | 0 | 0.10 | 5 s | own health below 30 % | Needs key |

**Effect:** the laid arts are plain hits, each +2.05 to its coefficient from Old Bund and Deep Bund, firing first at the first pulse. Ditch is one art in four forms, each slotted on its own, and the file's ids `headrace`, `furrow`, `ditch` and `seep` are those forms. **Description:** water let into a field one gate at a time. Hoe Stroke is the only thing that still works in a blind fight, and Walk Home is the plan.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Nascent Soul | 6 | As below, without Walk Home | Common drain | `variants/level-ground-nascent.fight.json`, 100 years stood |
| Deity Transformation | 7 | Ditch (body, water), Rising Water, Ditch (qi, water), Ditch (body, earth), Ditch (qi, earth), Hoe Stroke, Walk Home | Common drain | The defined build, 200 years stood |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Thousand-Furrow Killing Array (Thiên Lũng Sát Trận) | **Offensive formation** | Level 5, below | Sets the formation tag on the five laid arts and gives L4 60 before formation power. The first array whose product is a hit | Needs rule |
| Level Ground Array (Bình Địa Trận) | Formation | Level 1 to 5, below | Carries the law | Needs key |
| New Rice Wine (Tân Mễ Tửu) | Pill | Alchemy, from your own field | +30 L4 | Needs key |
| Any `thuan`, `giap`, `chuong` | Artifacts, ward and body | Best available | No weapon at all: the law would cap it. Gear ward strength is only 120, so a blind master is thin | Fits today |

Formation records, in the shape of `crafting_formations.json`:

```json
{"id": "thien_lung", "name": "Thiên Lũng Sát Trận", "stat": "x4_points", "per_level": 12.0, "applies": "laid", "max_level": 5,
 "cost_lt": 400, "cost_growth": 2.5, "materials_per_level": 2, "material_rarity": 3, "upkeep_lt_per_level": 30,
 "grants_tag": "formation", "desc": "Channels cut into the ground itself: arts with the formation tag fire from it."}
{"id": "binh_dia", "name": "Bình Địa Trận", "stat": "ground_law", "law": "level_ground", "applies": "laid", "max_level": 5,
 "cost_lt": 600, "cost_growth": 2.5, "materials_per_level": 2, "material_rarity": 3, "upkeep_lt_per_level": 40,
 "desc": "Stakes and bunds that set one height for everything inside them."}
```

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Formation power (`formation_power_pct`) | +150 | L4 and, through Field Walls, the ward | Fits today |
| 2 | Bund and Channel (below) | size 10 | Known Ground, Deep Bund, Field Walls | Needs key |
| 3 | Damage (`attack_pct`) | +240 | L1 is the one layer the law leaves alone | Fits today |

### Hidden cluster idea: Bund and Channel (Điền Thủy Mạch)

Theme: formations and the land they sit on, wider than this build. Earth affinity. Outer, sealed by a technique (Paddy Keeper's Canon lists it). Size 10: small acupoints of Formation power and Herb growth, a notable for Known Ground, a notable for Deep Bund, and Field Walls as the capability at the far end. An idea for the tree rework, not data.

## Đạo

**Array, Field branch (Trận Đạo, Điền Mạch).** A branch for the existing Array Đạo, beside the Host branch. Signature nodes: Old Bund (passive), Standing Water (passive), Untended Field (passive, the price of the others), Hoe Stroke (art), and Ground Law as the branch's end. With the name hidden, a player reads a farmer who has never lost at home.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation to Core | Not run. A small field, Known Ground only | Ditch, first bund | A wedding gift |
| Nascent Soul | Beats its own top-end, loses to anyone ordinary one up | 100 years stood, Level Ground | The first grave in the field |
| Deity Transformation | No one above it. Beats the top-end of the realm at home | 200 years stood, seven slots | The letter from far away |

## Matchups

The mixed enemy's arts unless stated, at Deity Transformation, same realm. Run with `--enemy top_end` or `--enemy typical`.

| Enemy | Situation, law | Result | File |
|---|---|---|---|
| Typical | Foreseen, Level Ground | Win at 1 s on 99 %: one volley on the first pulse | `variants/level-ground-mixed.fight.json` |
| Top-end | Foreseen, Level Ground | Win at 4 s on 87 % | same |
| Top-end | Foreseen, no law | Dead at 1 s, enemy on 82 % | same, `--without ground_law` |
| Top-end | Foreseen, Deep Mud (wrong law) | Dead at 3 s, enemy on 80 % | `variants/level-ground-mud.fight.json` |
| Top-end | Ambush at home, standing formation, no pill | Win at 4 s on 87 % | `variants/level-ground-ambush.fight.json` |
| Typical | **Blind, away** | Win at 22 s on 21 %: one art and a fist | `variants/level-ground-blind.fight.json` |
| Top-end | **Blind, away** | Dead at 1 s, enemy on 100 % | same |
| Typical | Blind at home (ground tags only) | Win at 9 s on 76 % | `variants/level-ground-blind-home.fight.json` |
| Top-end | Blind at home | Dead at 1 s, enemy on 99 % | same |
| Art-speed rusher (L2 to L5 ordinary, top-end body) | Deep Mud | Win at 4 s on 91 % | `variants/level-ground-rush-mud.fight.json` |
| Same rusher | Level Ground | Win at 4 s on 77 % | `variants/level-ground-rush-level.fight.json` |
| Top-end body with the Thousand Scales' wounds | Level Ground | Win at 4 s on 63 % | `variants/level-ground-rival.fight.json` |
| Soul assassin, thần thức ×2.5, top-end body | Level Ground | Dead at 3 s, enemy on 76 % | `variants/level-ground-soul.fight.json` |
| Top-end with pools ×1.5 (a boss) | Level Ground | Loses at 19 s, enemy on 10 % | `variants/level-ground-boss.fight.json` |

**Counter:** a soul assassin, because layers mean nothing to soul. Only Level Ground is saved against it; no law on the list touches `soul_cap`. Or never set foot there: a hunter strikes on the road, and the master is a thin old farmer with one art and a fist. Rule 12 is the real enemy.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 3.0 of 4.0. Slots 7 of 7. Arts within the lint as authored, but Old Bund and Deep Bund add +2.05 after it, and no rule says whether a Flat base counts. Thần thức not totalled |
| Validity | PASS | Real elements, tier, bases. Thiên giai reaches `hoa_than`. `formation_power_pct` is a real key |
| Stack | PASS | Ten forms: Flat base, Timing, Increased, Per, More, Cap shift, Overflow, Redirect, Rule swap, Trade. L2, L5 stated empty. `--without ground_law` flips the fight |
| Scaling | PASS | `m_static` 11.20 against typical 8.96 and top-end 325. It meets top-end only by lowering top-end. Noted as INFO: beating a same-realm top-end at 87 % is strong, and it needs a foreseen fight on laid ground |
| The fight | PASS | The loop happens at t = 1 and t = 4. The only cap hit is `layer_4_over_cap`, which Deep Bund spends |
| Reuse | PASS | `formation_power_pct`, Array Đạo, common ward. No coating: nothing here is a fifth renamed L4. Second homes are wide: any gate, boss arena or home array |
| NPC use | PASS | A sect's home ground is the obvious NPC use. The generator needs only the law's id. Each is one Breakdown line |
| Counterplay | PASS | Soul, a blind strike, a boss-sized pool, refusing to come |
| Originality | PASS | Terraced farming is common life, and no name comes from an existing work |

## Fight Results

Input: `sheets/level-ground.fight.json`. Rule: `laid_ground`. Observations from `fight_x.py`, a paper model with expected values for chance, not the game. Deity Transformation is the last realm, so matrix gaps 1 and 2 only add suppression against the same realm and mean little. The real one-up test is the Nascent Soul file.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical (fixture) | 0 | Win, 98 % | 1 s | never | `layer_4_over_cap` |
| top_end (fixture) | 0 | Win, 91 % | 4 s | never | `layer_4_over_cap` |
| mixed typical | 0 | Win, 99 % | 1 s | never | `layer_4_over_cap` |
| mixed top_end | 0 | Win, 87 % | 4 s | never | `layer_4_over_cap` |
| Nascent mixed typical | 0 | Win, 98 % | 1 s | never | `layer_4_over_cap` |
| Nascent mixed typical | 1 | Loss, enemy 64 % | 5 s | 3 s | `layer_4_over_cap` |
| Nascent mixed top_end | 0 | Win, 84 % | 4 s | 4 s | `layer_4_over_cap` |
| Nascent mixed top_end | 1 | Loss, enemy 95 % | 3 s | 3 s | `layer_4_over_cap` |

**Identity runs** (`variants/level-ground-mixed.fight.json --enemy top_end`): `--without ground_law`: dead at 1 s. `--without field_walls`: win at 11 s on 9 %. `--without standing_water`: win at 6 s on 75 %.

**Flat base test** (`variants/level-ground-boss.fight.json --enemy top_end`): enemy left on 10 %. `--without old_bund`: enemy left on 66 %. `--without deep_bund`: enemy left on 66 %. Against an ordinary top-end neither Bund shows alone, because they are redundant: `variants/level-ground-mixed.fight.json --enemy top_end` stays a win at 4 s on 87 % with either one removed. Remove both (`variants/level-ground-no-bunds.fight.json`) and it is a loss at 20 s with the enemy on 51 %. So the Bunds are half the engine, not a boss-only margin.

**Unmodelled:** Walk Home pays its cost and never rolls. Upkeep, laying time and Untended Field are outside the fight.

## New Concepts

**Ground Law (Địa Luật).** A laid formation may carry one law: listed Combat keys moved for the length of one fight, for both sides, within an authored range.

- **Rule:** Combat rule 12, with a list in Formations. Combat owns which keys may move and the range of each.
- **Bounds:** one law to a ground. Only keys on the list. Blind fights have none.
- **Breakdown line:** "Level Ground: L2 capped at 40 (lost 260)."
- **Other builds it serves:** any sect's gate array, any boss arena or secret realm that wants its own rules, and Heavenly Tribulation preparation, whose rule 5 already counts a laid formation.
- **NPCs:** yes. A law is an id on a place, and a sect's mountain gets character for free.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Ground Law, Level Ground, Deep Mud, Dry Season | Needs rule | Combat rule 12: a law on the ground. A list of movable keys |
| Taken Ground | Needs rule | Combat rule 12: one formation to a ground, and whose counts |
| Formation arts | Needs rule | Combat rule 13 lists art sources, and a formation is not among them |
| Standing Water | Needs rule | Combat rule 13: "every art starts on its full cooldown" has one exception |
| Deep Bund | Needs rule | Formulas B: a use for clipped L4 |
| Old Bund, Known Ground, Field Walls, Untended Field | Needs key | New keys: a formation's age, ground tag count, a redirect |
| Thousand-Furrow Killing Array, Level Ground Array, New Rice Wine, Paddy Keeper's Canon, four arts, Bund and Channel, Field branch | Needs key | Content records |

**Questions for the user:**

1. Rule 12 says a blind fight holds only the loadout, so a standing formation is down even at home, in the middle of it. Is that the intent? It is what makes this build's danger real, but it means a sect's mountain array does nothing against a sudden attack.
2. Does a Flat base count against the art lint? Old Bund is worth far more on a cheap art than a dear one, which is what turned the great sluice into five small channels. Today nothing stops it, and the answer decides this build: the Bunds are half its engine.
3. Heavenly Tribulation rule 5 counts a laid formation. Does a Ground Law bind a tribulation boss? If yes, Level Ground may be the best tribulation answer in the game, and it may need an exception.
4. Open Question 4 matters here more than anywhere: this build is only as good as what it can see before the fight.

## Also Considered

- **The Great Sluice:** one flood at the first pulse with all of L4 behind it. Tested, and it lost to five ditches (`variants/level-ground-great-sluice.fight.json`). Kept as a variant.
- **Grave Siting:** a geomancer who chooses where you will be buried, with ground tags that curse the enemy by element. Strong theme, but it reads as curses rather than ground, and leans on a funeral theme already used.
- **Second Bund:** a keystone allowing two laws on one ground. Early runs wanted it. Once the cheap arts came in, a second law added nothing, and Dry Season hurt the master's own regeneration, so it was cut.
