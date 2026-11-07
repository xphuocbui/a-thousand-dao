# The Dew on the Blade (Phong Lộ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Metal and Water, crit: Hair's Breadth, Hàn Mang, Cold Dew. The critic calls crit at catalogue size a trap row. Find out if a whole border escapes it, or prove that it does not.
> **Direction**: It does, in one way. Crit is a poor damage row and a very good income row. Cold Dew is the only income past the regeneration cap, so a whole border pays for every slot, and that is the win.
> **Realm span**: Core Formation – Deity Transformation, defined at Nascent Soul · **Power level**: ordinary at Core, strong at Deity · **Use**: player path
> **Fit**: 3 Fits today · 13 Needs key · 0 Needs rule · 1 new piece
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward record)

## The Verdict

**Bought a row at a time, crit is a trap, at every length. Bought whole, it escapes at about 85 nodes.** Every road below was climbed the same way as the border, by the same search, with the crit rows locked out.

| Walk | Border | Road, same nodes | Reading |
|---|---|---|---|
| Core, 55 | 4 of 5, Wall L 67 % | 4 of 5, Wall L 72 %, and twice as fast on two | **Trap.** 24 nodes of crit buy nothing a road does not |
| Nascent, 85 | **5 of 5** | 4 of 5, Wall L 46 % | **Escape, barely.** The road is still faster on Pulse and healthier on the Evader |
| Deity, 108 | **5 of 5, Wall 6 s on 56 %** | 5 of 5 on four arts, Wall 11 s on 24 % | **Escape.** It beats The Banked Well in all five cells |

## The Spine

- **The channel:** art hits on L1, L2, L3 and L5, plus crit, with every slot full.
- **The enabler:** none. The 24 nodes of Hàn Mang and Cold Dew are the enabler.
- **The loop:** every art every 1.5 s. Each hit has a 44.6 % chance to hand back 2.3 % of the pool.
- **The engine:** a hit is worth about 1 % of the pool back, a fifth of what it cost. That is income from a source the 8 % `regen_cap` does not touch and a Closed Gate does not shut.
- **The sacrifice:** the first 16 nodes, which do almost nothing. Then the Pulse enemy, and health.
- **The arc:** a bad choice at Core, a close one at Nascent, the best road on the wheel at Deity.

## The Legend

Khương Lộ takes tea at dawn and considers everything else a delay. The water must be dew, and the dew must come off a clean blade, because steel left out in the cold gathers it sweeter than any leaf. They will explain this. They have explained it to judges, to an executioner, and at length to someone trying to kill them at the time.

Blades are therefore wanted, and many, and they are wanted wet. Khương Lộ cuts very fast and very happily, and every good stroke brings the cold down the edge and into a small silver cup worn at the belt. They have never lost a fight or finished a cup. Their students say the tea is not good. Nobody has told them.

## How It Fights

Six arts fire together every 1.5 s. Most fights end in one or two beats. The Dew shows on the long one: the pool falls from 90 % to 12 % by t = 5, then the arts keep firing on what comes back.

**The signature moment:** Deity, the Wall, seven arts. Its pool is 1 % at t = 5, its body 39 %. At t = 6 it is dead, and you are on 56 % with 3 % of the pool (`variants/blade-dew-deity-wall.fight.json --timeline`). Without Dew the same seven arts run dry and lose at 17 s (`deity-no-dew-wall`).

## The Stack

85 nodes at Nascent, Water and Metal at purity 50. No new rows. At Deity's 108 the first two rows stay and Crit damage grows to 12 + 4, ×2.28. The rest are in `blade-dew-deity-mixed`.

| # | Row | Take | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|
| 1 | **Crit chance with Water (Hàn Mang)** | 12 + 4 | +29.6 %, so 44.6 % | Increased | none | ○ reused |
| 2 | **Linh lực on a crit (Hồi Bạo), Cold Dew (Hàn Lộ)** | 5 + 3 | +2.3 % | Trigger | none | ○ reused |
| 3 | Crit damage (Bạo Thương) | 4 + 0 | +6 %, so ×1.76 | Increased | none | ● |
| 4 | Water damage (Thủy Thương) | 14 + 2 | +52 | Increased | L1 | ○ reused |
| 5 | Thin Stream (Tế Lưu) | 8 + 2 | +40 | More | L2 | ○ reused |
| 6 | Short Art (Đoản Pháp) | 8 + 1 | +22 | More | L2 | ○ reused |
| 7 | Spring Head (Tuyền Đầu) | 2 + 1 | +16.6 at 4.15 % | Per | L2 | ○ reused |
| 8 | Wasting (Hao Tổn) | 0 + 1 | up to +20 | Per | L2 | ○ reused |
| 9 | Unbroken Surface (Toàn Diện) | 6 + 2 | +36 | Conditional | L5 | ○ reused. Both sides of every comparison may buy it |
| 10 | Regeneration (Hồi Khí) | 1 + 2 | +2.15 | Increased | none | ● |
| 11 | Water art cost (Tiết Thủy) | 4 + 1 | −10 % | Increased | none | ○ reused |
| 12 | Body damage, Water art speed | 1 + 0 each | +1.5, +1 | Increased | L1, none | ○ reused |

**Hair's Breadth (Phân Hào): 0 nodes.** Ring Step ends in Water, so Hàn Mang reaches every art and Hair's Breadth reaches two. Splitting the 16 nodes across both tags loses the Wall on 38 % (`both-tags-*`). A two-tag border buys chance twice, unless it picks the side the conversion ends on. So this border has one crit row, as the wheel's fold says.

**Identity piece:** Cold Dew. `--without "Cold Dew"` on `blade-dew-deity-wall` loses at 17 s, Wall on 14 %.
**Empty rungs:** L4 in a blind fight, and health: 0 rows.

| Layer | Points at Nascent | Multiplier | Sources |
|---|---|---|---|
| L1 | 52 to 53.5 | ×1.52 | Rows 4, 12 |
| L2 | Ladles about 139, needles about 99 | ×2.4, ×2.0 | Rule 40, rows 5 to 8 |
| L3, L4 | 40, 20 | ×1.40, ×1.20 | The typical weapon and a pill |
| L5 | 36 | ×1.36 | Row 9 |
| Crit | 44.6 % at ×1.76 | ×1.34 | Typical is ×1.105. Arts only: `basic.c` takes it back from the fist |

## Foundation and Arts

Water and Metal, purity 50 each. One Ladle Rule as main. Pools and ward points are the typical's. Six of 6 slots at Nascent, seven of 7 at Deity with Long Draw.

**Whetstone Dew Page (Lộ Ma Thiên), new:** a page on leaving a blade out overnight. Art generates main, so harmony is ×1.00, on no bonuses.

```json
{"id": "lo_ma_thien", "name": "Lộ Ma Thiên", "tier": 1, "tech_kind": "secret", "names": ["kim", "thuy"], "layers": 9,
 "bonuses": [], "abilities": [{"ability_id": "plain_cut", "unlock_layer": 2}, {"ability_id": "long_draw", "unlock_layer": 5}],
 "seal_clusters": [], "origin": "authored"}
```

Passive: Ring Step, all of a Metal hit to Water, one step.

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|---|
| First, Second Ladle (Sơ, Tái Chước) | One Ladle Rule | qi, Water | 1.60 | 0.04 | 1.5 s | Reused |
| Cold Needle, Cold Rain, Cold Draught (Hàn Châm, Hàn Vũ, Hàn Ẩm) | One Ladle Rule | body, Water | 1.84 | 0.06 | 1.5 s | Reused |
| Plain Cut (Bình Trảm) | The Page | body, Metal, Water by Ring Step | 1.4 | 0.05 | 1 s | Reused |
| Long Draw (Trường Tha), Deity | The Page | qi, Metal, Water by Ring Step | 2.2 | 0.08 | 3 s | Reused |

**Stone Ward (Thạch Hộ):** reused, common pass, `upkeep_share` 0.10, typical ward points. See below for how little it carries.

## Matchups

Each cell: result, time, own health. L gives the health the enemy kept. Files are `variants/blade-dew-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|
| **Core, 55, five arts** (`core-*`) | W 3 s, 63 % | W 3 s, 63 % | L 67 % | W 3 s, 63 % | W 3 s, 46 % | 4 |
| Core road (`core-road-*`) | W 1.5 s, 83 % | W 3 s, 66 % | L 72 % | W 3 s, 66 % | W 1.5 s, 58 % | 4 |
| **Nascent, 85, six arts** (`mixed` … `fast`) | W 1.5 s, 82 % | W 3 s, 65 % | **W 8 s, 0 %** | W 3 s, 65 % | W 1.5 s, 56 % | **5** |
| Nascent, four arts (`four-arts-*`) | W 3 s, 65 % | W 3 s, 65 % | **W 8.9 s, 27 %** | W 3 s, 65 % | W 3 s, 48 % | **5** |
| Nascent road, six arts (`road-*`) | W 1.5 s, 82 % | W 2 s, 82 % | L 46 % | W 3 s, 75 % | W 1.5 s, 56 % | 4 |
| Nascent road, five, four (`road-five-*`, `road-four-*`) | | | L 43 %, L 58 % | | | 4, 4 |
| **Deity, 108, seven arts** (`deity-*`) | W 2 s, 87 % | W 2.9 s, 74 % | **W 6 s, 56 %** | W 2.9 s, 74 % | W 1.5 s, 67 % | **5** |
| Deity road, seven arts (`deity-road7-*`) | W 1.5 s, 86 % | W 3 s, 72 % | L 35 % | W 3 s, 72 % | W 1.5 s, 64 % | 4 |
| Deity road, four arts (`deity-road4-*`) | W 3 s, 72 % | W 4.5 s, 35 % | W 11 s, 24 % | W 4.5 s, 60 % | W 3 s, 59 % | 5 |
| The Banked Well (`banked-well-*`, its own files) | W 3 s, 57 % | W 5 s, 34 % | W 14 s, 22 % | W 4.5 s, 53 % | W 3 s, 48 % | 5 |
| Parent: Cold Line, Deity (`cold-deity-*`) | W 3 s, 53 % | L 10 % | L 75 % | L 42 % | L 56 % | 1 |
| Parent: Cold Line on Stone (`cold-deity-stone-*`) | W 3 s, 53 % | W 4.5 s, 40 % | L 69 % | W 4.5 s, 40 % | W 3 s, 21 % | 4 |
| Parent: the Edge, carried to Nascent (`edge-*`, `edge-stone-*`) | L 67 %, L 52 % | L 67 %, L 52 % | L 91 %, L 90 % | L 79 %, L 69 % | L 89 %, L 83 % | 0, 0 |

**What neither parent can do:** the Wall. The Cold Line also has crit, 35 nodes of it at 3 arts, and never gets near. Slots are the difference, not chance.

**The six-art Wall at Nascent is a dead heat:** both fall at t = 8, and the overkill rule gives it to you. On real rolls that goes either way. **The line of play is to take two arts off** (`four-arts-*`: 27 %). A road walker has no such option: it loses the Wall at four, five and six.

**A row at a time.** Starting from the Nascent road and buying into crit. This is what a player actually does, and why the critic was right.

| Nodes moved | File | Pulse | Evader | Wall |
|---|---|---|---|---|
| 0 | `road-*` | W 2 s, 82 % | W 3 s, 75 % | L 46 % |
| 8 of Hàn Mang | `ramp8-*` | W 2 s, 82 % | W 3 s, 75 % | L 35 % |
| 16 of Hàn Mang | `ramp16-*` | **W 3 s, 65 %** | **W 3 s, 65 %** | L 39 % |
| 24 with Dew | `ramp24-*` | W 3 s, 65 % | W 3 s, 65 % | L 25 % |
| The road rebuilt around it | main file | W 3 s, 65 % | W 3 s, 65 % | **W** |

Every step but the first costs something, and no step wins a fight. **The trap is real, and it is a trap of order.**

**Which part does it?** On the Wall.

| Taken out, nodes kept | Nascent | Deity |
|---|---|---|
| Nothing | W 8 s, 0 % | W 6 s, 56 % |
| Cold Dew, nodes idle (`no-dew-wall`, `deity-no-dew-wall`) | L 57 % | L 14 % |
| Dew's nodes to Regeneration, or at the cap, to health (`dew-to-regen-wall`, `deity-dew-to-health-wall`) | L 14 % | L 8 % |
| Chance to Steady Thread and Qi damage (`no-chance-wall`, `deity-no-chance-wall`) | L 64 % | L 22 % |
| Half the chance (`both-tags-wall`, `deity-half-chance-wall`) | L 38 % | W 13 s, 18 % |
| Crit damage (`deity-no-crit-damage-wall`) | | W 8 s, 45 % |
| **Common drain ward** (`common-*`, `deity-common-*`) | 4 of 5, L 32 % | 5 of 5, W 10 s, 0 % |

- **Below the cap, Dew is only a slightly better Regeneration.** Above it, nothing else can be bought, and that is the escape.
- **The chance is what the Dew needs.** Neither wins alone. Crit damage joins last, and earns its place only with the chance already paid.
- **The ward carries little.** The common ward loses one cell at Nascent and none at Deity. This is the one border that does not lean on the Stone Ward. The Fast enemy and the Pulse enemy are untouched.

**Counter, found by running it:**

- **A Closed Gate on the Wall, Deity:** it does not shut Dew, and that is not enough. L 29 % at 9 s (`deity-gate-wall`), against L 61 % for the road on four arts and L 58 % on seven.
- **A Stone Ward of their own:** the Wall holds on 56 % (`deity-stone-wall`). At Nascent, Fast on one beats you at 2.5 s with 6 % left (`stone-fast`). At Deity you win on 20 % (`deity-stone-fast`).
- **Evasion barely helps them:** 60 % evade still dies at 2.9 s (`deity-evader-60`). **Top-end:** dead at t = 1.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Page has no bonuses, arts within the lint, 6 of 6 slots. Nothing prices a ward record |
| Validity | PASS | Harmony checked. Chance 44.6 % under the 50 % cap, ×1.76 under ×3.0. Regeneration at Deity 5.8, under the cap |
| Stack | PASS | Increased, More, Per, Conditional, Trigger. L1, L2, L3, L5 filled |
| Scaling | PASS | INFO: above typical once crit is counted |
| The fight | PASS | 5 of 5 at Nascent and Deity. `cap_hit trig_cap_reached` once on the Deity Wall: Cold Dew is a trigger, and six a pulse is the most it pays |
| Reuse | PASS | 1 new technique. Cold Dew runs at last, as a Grindstone spur nobody took |
| NPC use | PASS | Plain rows |
| Counterplay | PASS | A per-pulse ward |
| Originality | PASS | Tea |

**Matrix:** `sheets/blade-dew.fight.json --matrix`: typical gap 0 wins at 1.5 s, gaps 1 and 2 lose at 2 s, top-end at 1 s. **Unmodelled:** crit is an expected value. A 1.5 s fight in play turns on two or three rolls, and the calculator cannot show that. Rule 15 wants chance to stay a flavour, and this is the most chance-led road on the wheel. Ward strength against one element, fortune and thought are not read.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Whetstone Dew Page (Lộ Ma Thiên) | Needs key | A secret technique holding Plain Cut and Long Draw, with one Ring Step |

## Questions

1. Is income past `regen_cap` meant to exist? Cold Dew is a plain catalogue row, and it is the whole of this escape. If it should count against the cap, the critic's trap stands at every length.
2. Crit pays only after 16 nodes, and a row-at-a-time walker never reaches it. Should the tree say so, or is finding it the game?

## Also Considered

- **Both tags, Hair's Breadth and Hàn Mang equally:** shown above. It is the build a player would try first.
- **A pure Metal border on Grindstone Primer:** Plain Cut alone is too few hits a beat for Dew.
