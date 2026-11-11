# The Whetted Edge (Mài Phong Kiếm)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A new player's sword build: a flying sword art and a strong basic attack, crit as the thing to chase. Clear upgrades at each realm.
> **Direction**: A. The Whetted Edge (see Directions considered).
> **Realm span**: Luyện Khí (Qi Refining) to Kết Đan (Core Formation) · **Power level**: ordinary · **Use**: player
> **Fit**: 5 Fits today · 14 Needs key · 4 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: technique bonuses are combat keys outside `bonus_pool`; Identity test: the identity piece, Whetted Edge, is unmodelled; The fight: the engine is unmodelled, so the fight is observation only)

## Directions considered

Chosen: **A. The Whetted Edge (Mài Phong Kiếm).** A crit build on the Metal sword: every crit sharpens the blade, so a lucky streak feeds itself. It is the only reading that makes "crit as the thing to chase" a loop and not a stat, it is readable in one line, and it gives a new player an upgrade at every realm.

- **B. Thousand Returns (Vạn Hồi).** Many cheap quick arts (the Thousand Cuts keystone) and on-hit effects. Not picked: it needs the art lint and slot count of a later realm to feel good, and crit becomes a side stat.
- **C. The Patient Blade (Ẩn Phong Đạo).** One sheathed art that hits harder for each second it waited (Sheathed Blade). Not picked: nothing fires at t = 0 and a new player would watch a quiet screen; it is a good second build, not a first.

## The Spine

- **The channel:** art hit plus basic attack, both with crit. Uses L1 to L5 and the crit pair outside M. Crit chance cap 0.5 and crit multiplier cap 3.0 are the ceilings the build climbs toward and never reaches in this span.
- **The enabler:** none opened. The enabling Effect is Whetted Edge, carried by the main technique: each crit adds a Whet stack; each stack adds crit chance. It closes nothing outright, but its stacks lapse if no crit lands for 6 s, so a build that is evaded or blocked into small hits loses its engine.
- **The loop:** the basic attack and the quick art keep swinging; every crit gives a Whet stack and (through Flowing Water) trims the other arts' timers; Whet raises the next crit chance; the flying sword art lands the big hits; Sheathe and Breathe and linh lực on crit keep the pool.
- **The engine:** crit feeds crit. Chance is capped at 0.5, so the build runs on the spiral between the cap and the lapse timer.
- **The sacrifice:** defence. The technique carries no ward or body bonus and the build wears the Common Ward. It also lives on chance (Combat rule 15 wants chance as flavour), so its fights vary, and it refuses to fix that.
- **The arc:** Luyện Khí: a swordsman with a basic attack that hurts. Trúc Cơ: the flying sword art and Whetted Edge. Kết Đan: the sword rain and the first real use of Flowing Water; the crit cap comes into sight.

## The Legend

The Whetted Edge was written down by a sword-polisher at a sect's armoury (tông môn), not by a swordmaster. He never won a duel, but he could say, from the sound of a stone on steel, how sharp a blade was. He thought a sword that struck true once should be sharper for it, and he spent his life writing the rule down.

Beginners walk it because it is simple: hit, hit, hit true, and the sword rings. It teaches them what the system rewards. What it does to them is a gambler's habit: they swing for the ring, and they get careless when it does not come.

The sects that hold the stone-wall bodies hate it. A block does not care how sharp a sword is.

## How It Fights

The cultivator stands with a flying sword at their shoulder and lets the basic attack and a quick draw cut run on their own. Early crits are chance. By the third crit in six seconds the sword is "hot" and crit chance is up by several points; the long art, Returning Sword Light, tends to land on that streak. If no crit comes for 6 s the edge goes dull and they start again.

**Signature moment:** a six-crit chain where the log reads crit, crit, crit and the flying sword's cooldown has dropped to nothing, the fight over in half the usual time.

## Enabler

**Whetted Edge (Mài Phong)**, an Effect carried by the main technique's layer-4 ability. Opens: crit gives a Whet stack (max 8, each 6 s on its own timer, +2 pp crit chance each, +16 pp at full). Closes: stacks lapse when crit stops; the technique gives no defensive bonus. Where a player finds it: the Plain Iron Sword Manual (Phác Thiết Kiếm Quyết), a tier 2 starter technique, sold or found in any armoury. Needs rule (effects.md, a self-stack status keyed to a crit event).

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Basic attack coefficient add (`basic_coef_add`) | +0.25 at Trúc Cơ, +0.5 at Kết Đan to the basic attack's coefficient | Flat base | basic | none | ○ (staged: basic-coef-add-key) | Technique, tree notable | bare-fist |
| 1 Base | Flying sword attack | +12 % weapon attack on a flying sword (notable) | Increased | art, basic | L3 | ○ catalogue | Artifact, tree | any sword build |
| 2 Rate | Sword art speed | +6 % on sword arts (notable) | Increased | art | L2/art speed | ○ catalogue | Tree | any sword build |
| 2 Rate | Flowing Water (Lưu Thủy) | A crit shortens your other arts' timers by 0.5 s | Trigger | art | none | ○ catalogue keystone | Đạo (Kiếm Ý) | any crit build |
| 3 Multiplier | Sword damage | +12 % sword damage (notable) | Increased | art, basic | L1 | ○ catalogue | Tree | any sword build |
| 3 Multiplier | Drawn Steel (Xuất Thiết) | +12 pts more on arts with the sword form | More | art | L2 | ○ new | Technique layer bonus | Kiếm Đạo builds, armoury builds |
| 3 Multiplier | Whetstone Oil coating | +15 to +20 pts prepared sword damage | More | art, basic | L4 | ○ new item | Coating | Iron-Sand Hand Bath builds |
| 3 Multiplier | Hot Edge (Nhiệt Phong) | +10 pts more hit damage while you crit in the last 3 s | Conditional | art, basic | L5 | ○ new | Kiếm Đạo notable | any crit build |
| 4 Crit | Crit chance with swords | +5 pp (notable) | Increased | art, basic | outside M | ○ catalogue | Tree, Kiếm Ý | any sword build |
| 4 Crit | Crit chance (basic) | +12 pp (family notable) | Increased | basic | outside M | ◐ designed in modifiers.md | Tree | bare-fist |
| 4 Crit | Crit damage | +10 pp of multiplier (notable) | Increased | art, basic | outside M | ● | Tree, gear | any crit build |
| 5 Reach | none | the sword hits like any art; no pierce needed inside one realm | | | | | | sacrifice |
| 6 Past the cap | Edge Spills Over (Phong Dật) | Crit chance above `crit_chance_cap` becomes crit damage at 1 pp of multiplier per 2 pp | Overflow | art, basic | outside M | ○ new | Kiếm Ý keystone | any crit build |
| 7 Fuel | Linh lực regained on a crit | +0.6 % of maximum (notable) | Trigger | any | none | ○ catalogue | Tree | any crit build |
| 7 Fuel | Sheathe and Breathe | art restoring 6 % of linh lực | n/a | art | n/a | ○ new art | Technique | sustain builds |
| 8 Survival | none | Common Ward and body of an ordinary cultivator | | | | | | sacrifice |
| 9 Identity | Whetted Edge (Mài Phong) | crit gives Whet stacks, +2 pp crit chance each | Per | art, basic | outside M | ○ new Effect | Technique ability | signature |
| 9 Identity | Elemental Fist (Ngũ Hành Quyền) | The basic attack carries Metal's tags | Redirect | basic | none | ○ catalogue keystone | Đạo | bare-fist |

**Identity piece:** Whetted Edge. Without it the build is a sword with 15 % crit. With it, crit is a loop. Whetted Edge is a signature piece; its sibling pieces are all reused or have a second home.
**Empty rungs:** rung 5 (reach) and rung 8 (survival) are sacrifices. Rung 6 is empty until the player gets the keystone, far past this span's chance cap, and is a deliberate top-end upgrade.

| Layer | Points at Trúc Cơ | Multiplier | Sources |
|---|---|---|---|
| L1 | 58 | ×1.58 | attack_pct 18, Sword damage nodes 14, Kiếm Ý line 8, technique 8, tree 10 |
| L2 | 40 (+10 on sword arts) | ×1.40 (×1.50 on arts) | technique 12, Drawn Steel 12 on arts, Kiếm Đạo lines 8, tree 8 |
| L3 | 40 | ×1.40 | Wren-Feather Flying Sword (Phi Kiếm base 30 attack), flying sword attack |
| L4 | 20 | ×1.20 | Whetstone Oil 10, Clear-Edge Pill 10 |
| L5 | 10 | ×1.10 | Hot Edge while a crit is recent |

Kết Đan raises L1 to 85 and sword-art L2 to +12; L3 35 reads lower than 40 because the weapon base is a Trúc Cơ piece (see Items). Typical anchors: Trúc Cơ M 4.19, Kết Đan M 5.48 (fight.py --numbers).

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal (Kim), middling purity (about 60 to 70) | Metal tags are the sword's tags; the Metal stacks on Notch the Foe (phys_taken) are free. Middling purity keeps it ordinary |
| Key talents | Divine sense (thần thức) for the flying sword, then Fortune for crit flavour | A flying sword costs thần thức (Phi Kiếm 20); the unused thần thức is the cap on swords |
| The Way (Đạo) | Kiếm Đạo (Sword), Kiếm Ý facet: crit, pierce lines; Phi Kiếm facet | Both exist in dao.md; the facets hold Flowing Water, Edge Spills Over and Hot Edge |

## Công Pháp

### Plain Iron Sword Manual (Phác Thiết Kiếm Quyết) — main, tier 2

A sword-polisher's notes, bought for a handful of stones. Reaches Kết Đan (tier 2 `max_realm`).

```json
{"id": "phac-thiet-kiem-quyet", "name": "Phác Thiết Kiếm Quyết", "tier": 2, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 8}, {"stat": "linh_luc_pct", "value": 6}],
 "abilities": [{"ability_id": "whetted-edge", "unlock_layer": 4},
               {"ability_id": "drawn-steel", "unlock_layer": 7}],
 "seal_clusters": ["whetstone-row"], "origin": "authored"}
```

**Fit:** Needs key (abilities; none ship today; `layers` copied from the example in content-formats and to be checked against tier 2) · **Budget:** NOT ASSESSED for the combat abilities; the two plain bonuses are small and inside `bonus_single_cap` by inspection, but `pool_max` was not read.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Returning Sword Light (Hồi Quang Kiếm) | technique, layer 1 | qi, Metal, sword, flying | 2.0 | 0.04 | 3 s | none | Needs key |
| Quick Draw Cut (Tật Xuất Kiếm Trảm) | technique, layer 1 | qi, Metal, sword, quick | 1.0 | 0.02 | 1.5 s | none | Needs key |
| Notch the Foe (Khắc Ngân) | technique, layer 3 | qi, Metal, sword | 0.6 | 0.02 | 5 s | none | Needs key |
| Ten Thousand Returns (Vạn Hồi Kiếm Vũ) | technique, layer 10 | qi, Metal, sword, flying, slow | 4.2 | 0.08 | 8 s | none | Needs key |
| Sheathe and Breathe (Thu Kiếm Điều Tức) | technique, layer 9 | qi, restore | 0.3 | 0.02 | 8 s | none | Needs key |

Art lint check (c ≤ 1 × (1 + 24 × cost) + 0.25 × (cooldown − 1)): Returning 2.0 ≤ 2.46; Quick Draw 1.0 ≤ 1.61; Notch 0.6 ≤ 2.48; Ten Thousand 4.2 ≤ 4.67; Sheathe 0.3 ≤ 2.48. The loader printed no `lint_over`.

- **Returning Sword Light.** Effect: a hit. The flying sword goes out and returns along the same line; one hit, crit-capable. **Description:** the sword remembers where it was.
- **Quick Draw Cut.** Effect: a fast, cheap hit with the `quick` tag; the main source of crit rolls. **Description:** the hand is quicker than the thought.
- **Notch the Foe.** Effect: a hit plus 3 Metal debuff stacks for 8 s (more physical damage taken, 0.018 a stack). **Description:** a nick the next stroke finds.
- **Ten Thousand Returns.** Effect: a slow big hit. **Description:** the sword goes out once and comes back a thousand times.
- **Sheathe and Breathe.** Effect: restores 6 % of maximum linh lực. **Description:** the sword rests, the breath catches up.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Luyện Khí | 3 | Returning Sword Light, Quick Draw Cut, Notch the Foe | Common Ward | basic attack carries the first fights |
| Trúc Cơ | 4 | the same three, plus a free slot for a defensive talisman | Common Ward | Whetted Edge unlocks; the fight file runs this loadout |
| Kết Đan | 5 | Quick Draw, Returning, Notch, Ten Thousand Returns, Sheathe and Breathe | Common Ward | the sword rain and the pool refill |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Wren-Feather Flying Sword (Yến Vũ Phi Kiếm) | artifact, weapon | `phi_kiem` (attack 30, thần thức 20), good grade, Trúc Cơ | L3 gear; a named piece rolling flying sword attack and crit chance with swords. History: ground out of an armoury's cast-off blades | Fits today for the base; Needs key for the sword-scoped affixes |
| Whetstone Oil (Ma Du) | coating, preparation | coating | L4 prepared sword damage; fills the preparation layer a blind fight would drop | Needs key (a coating's fight payload) |
| Clear-Edge Pill (Minh Phong Đan) | pill, preparation | pill | L4 and a few points of crit chance for the fight | Needs key (a pill's fight payload) |

A Kết Đan upgrade is a better base than `phi_kiem` (the Wren-Feather is good enough through Trúc Cơ); that is why L3 reads lower at Kết Đan.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Crit chance with swords | +0.8 % small, +5 % notable | the crit goal | Needs key |
| 2 | Sword damage | +2 % small, +12 % notable | L1 | Needs key |
| 3 | Basic attack damage | +2 % small, +12 % notable | the strong basic attack | Needs key |
| 4 | Crit damage | +1.5 % small, +10 % notable | multiplier | Fits today |
| 5 | Flying sword attack | +2 % small, +12 % notable | L3 | Needs key |
| 6 | Flowing Water | keystone | the engine's timer loop | Needs rule |
| 7 | Linh lực regained on a crit | +0.1 % small, +0.6 % notable | fuel | Needs key |

### Hidden cluster idea: Whetstone Row (Ma Thạch Hàng)

Theme: Armoury craft (the sword-polisher's trade); Metal affinity; sealed, seal condition the Plain Iron Sword Manual (`seal_clusters`). Size 7 acupoints and one notable. Small acupoints: sword crit chance, basic attack damage, sword art speed. The notable at the far end is Hot Edge. No capability. Wider than this build: any Metal or weapon build wants it.

## Đạo

Kiếm Đạo (existing, dao.md Catalogue, Way 52): Kiếm Ý facet (crit, pierce) and Phi Kiếm facet. Nodes wanted: Kiếm Ý crit lines (chance, damage), Phi Kiếm weapon lines, and three staged notables: Flowing Water (a reuse), Edge Spills Over (keystone, the top-end piece) and Elemental Fist for the basic attack. No new Đạo.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Luyện Khí | basic attack and Quick Draw; crit is a rare ring | the manual, a plain flying sword, Quick Draw, Returning | the polisher's notes in a cheap book |
| Trúc Cơ | Whetted Edge turns on; streaks of crits | Whetted Edge, Notch the Foe, Whetstone Oil, Wren-Feather | the first time the blade rings |
| Kết Đan | five arts; Flowing Water chains arts; the crit cap in sight | Ten Thousand Returns, Sheathe and Breathe, Flowing Water, Hot Edge | the sword now keeps its own count |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical same realm | wins, mostly | 16-4 at Trúc Cơ, 14-6 at Kết Đan in the simulator |
| One realm above | loses | no pierce; the edge does not make up a realm |
| Body-block cultivator (thể tu) | loses | flat block per hit eats the small hits and Whet lapses |
| Evasive wind duelist | even to loses | evaded hits give no crits, Whet lapses |
| Ward-heavy caster | even | slow fights give Whet time, but the pool runs dry |

**Counter:** a thể tu with high block: a Quick Draw hit of c 1.0 loses a flat block per hit and the build has no tick or pierce. The adaptation is Ten Thousand Returns and Notch (phys taken) plus body-damage nodes, or a cleanse-free tick from another Đạo.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | arts inside the lint (no `lint_over`), slots 3/4/5 within `slots_by_realm`, one artifact within `equip.max_slots`; technique combat bonuses are outside `bonus_pool`, so its budget cannot be checked |
| Validity | PASS | `phi_kiem` exists; tier 2 reaches Kết Đan; Metal is a real element; no aux technique so no harmony to check |
| Stack | PASS | 18 rows over rungs 1 to 9; forms: Increased, More, Flat base, Conditional, Trigger, Overflow, Per, Redirect (8); identity piece present; layers L1 to L5 each filled |
| Identity test | NOT ASSESSED | Whetted Edge cannot be removed in the simulator. A proxy run `--without returning-sword-light` changed the fight (below), which shows the flying sword art matters, not that Whetted Edge does |
| Scaling | PASS | layers sit at the typical anchor, crit above it; INFO: wins 16-4 and 14-6 against the typical, on the strong side of the 0.70 edge at Trúc Cơ |
| The fight | NOT ASSESSED | the engine (Whetted Edge, Flowing Water) is unmodelled; observation only |
| Reuse | PASS | 10 reused pieces; 1 signature (Whetted Edge) |
| NPC use | PASS | every modifier is a plain number or an Effect with no player input; the generator can roll crit chance and Whet |
| Counterplay | PASS | thể tu block build, evasive wind duelist |
| Originality | PASS | the names are original: Whetted Edge, Drawn Steel, Hot Edge; no known novel or game name used |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/starter-blade.fight.json` (Trúc Cơ) and `starter-blade.ket-dan.fight.json` (Kết Đan). Observations from `fight.py` on the combat simulator, 20 fixed seeds, not the game. Whetted Edge is modelled as a steady average added to crit chance (Trúc Cơ 0.15 chance, 1.7 multiplier; Kết Đan 0.18 chance, 1.7 multiplier).

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Trúc Cơ | 0 | 16 / 4 / 0 | 27.1 s | 16.9 s | none | none |
| typical, Trúc Cơ | 1 | 0 / 20 / 0 | 7.9 s | 6.0 s | none | none |
| typical, Trúc Cơ | 2 | 0 / 20 / 0 | 3.6 s | 2.7 s | Notch the Foe | none |
| top_end, Trúc Cơ | 0 | 0 / 20 / 0 | 1.6 s | 1.6 s | Returning, Notch | none |
| typical, Kết Đan | 0 | 14 / 6 / 0 | 20.3 s | 14.6 s | none | none |
| typical, Kết Đan | 1 | 0 / 20 / 0 | 6.4 s | 5.1 s | Ten Thousand Returns, Sheathe and Breathe | none |
| typical, Kết Đan | 2 | 0 / 20 / 0 | 3.2 s | 2.7 s | several | none |

The same-realm fights run 20 to 27 s, under the 30 s a typical build is meant to last; the build ends them early and dry-at 14 to 17 s means the pool is the next limit. `NEVER_FIRED` appears only where the fight ends within the first seconds against a stronger foe.

**Identity test** (`--without returning-sword-light`, the proxy, not the identity piece): Trúc Cơ typical+0 changed (27.1 to 34.3 s, 16 to 6 wins), +1 changed slightly, others NO_CHANGE; Kết Đan typical+0 changed (20.3 to 26.4 s, 14 to 6 wins).

**Unmodelled:** Whetted Edge (averaged into crit chance); Flowing Water timer cut; linh lực regained on a crit; `basic_coef_add` (no field in the file); Hot Edge's recent-crit condition (its L5 is held at a steady 10 points); the simulator's `model_note`: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape.

## New Concepts

None. The two rule changes are suggestions (see `starter-blade.suggestions.md`): a crit event with self-stacks, and Overflow on the crit-chance cap.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Whetted Edge | Needs rule | effects.md: a self-stack status keyed to "you crit", per-stack timers, max 8 |
| Edge Spills Over | Needs rule | combat.md rule 8: crit chance past `crit_chance_cap` becomes crit damage, bounded by `crit_mult_cap` |
| Hot Edge | Needs rule | an event "you crit in the last 3 s" readable as an L5 condition |
| Flowing Water | Needs rule | combat.md: a crit shortens other arts' timers (catalogue keystone, reused) |
| Drawn Steel | Needs key | L2 more on sword-form arts |
| `basic_coef_add` | Needs key | modifiers.md Stat List (staged by bare-fist) |
| Sword crit, flying sword attack, sword art speed, sword damage | Needs key | tag-scoped keys (tree catalogue rows) |
| Five arts, the manual | Needs key | art records, technique abilities |
| Wren-Feather, Whetstone Oil, Clear-Edge Pill | Needs key | named affixes, coating and pill fight payloads |
