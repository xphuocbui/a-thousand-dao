# The Grindstone Road (Ma Thạch Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Metal. Ordinary tag-scoped rows, 0 rule asks, no enabler, two rival lines, one build of 10 or more rows. Remove any one and the fight barely moves; remove five and it is lost.
> **Direction**: Every blade has an edge and a point. A 34-node road for a Qi Refining walker, forking at node 24. This build walks the Edge (crit, the size of the wound). The Point (accuracy and an opened ward) is proved beside it.
> **Realm span**: Qi Refining – Core Formation on this manual, defined at Qi Refining · **Power level**: ordinary · **Use**: player build, or any plain Metal pupil
> **Fit**: 12 Fits today · 13 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hits and the basic attack, on L1, L2, L3 and L5, with crit. No ticks, no plug-in, no preparation.
- **The enabler:** none.
- **The loop:** the mixed enemy's own three arts, renamed, so the stack is the only difference between the two fighters. The cheap cut fires every second, and the second art at 3 s.
- **The engine:** thần thức into needles. Four cheap needles lift L3 for every hit, the free basic attack included, and crit, L1, L2 and L5 multiply on top. Ordinary rows on five axes, none worth more than a tenth of a hit.
- **The sacrifice:** the ward kit, and any second plan. Ward 17 against the enemy's 31. It needs the enemy dead at 4 s.
- **The arc:** a plain road, so the same 34 nodes simply stop being most of a life. At Core they are a sixth of it.

## The Legend

Thiện walked the valley villages with a wheel on their back, sharpening what people brought out to the road. They had the root tested at thirty because a customer paid for it instead of paying for a sickle, and it was Metal, and not a good one. The elders at the pass gave them a primer and four needles, the sort used to mend sails, and told them cultivation would come slowly.

It did. What Thiện knew already was the only thing the primer really teaches: steel never improves by having something added to it. It improves by being worn away in the right place, a little, every day, by someone paying attention. They still stop in the villages. When a pupil asks whether the edge or the point is better, Thiện asks to see what they carry, turns it over in the light, and tells them honestly what it needs.

## How It Fights

Nothing about it looks special. Both fighters cut each second, and for two seconds the bars fall together. At 3 s the second art lands and the enemy's strike lands with it, and Thiện takes the worst blow of the fight. But the enemy has nothing left to cast with. A second later Thiện is standing on a fifth of their health, and the enemy is not standing.

**The signature moment:** at 3 s the enemy's pool reads 0 %. That one number is the sum of every row: the enemy cannot pay for the jab at 4 s, and the fight ends 17 points of health better for it (`variants/grindstone-mixed.fight.json --timeline`).

## The Stack

Sizes are the catalogue's where it has a row, and first guesses elsewhere. **Nodes** run in walking order: 34 nodes, 28 acupoints and 6 notables, 81.6 W, taken from the 38 points a typical Qi Refining life spends on attack and outside combat. There is no plain `attack_pct` at all. Sector rows scale with purity, so these sizes assume purity 50: 0.5 + purity / 100 (Meridian Map rule 4). ● means the key exists today. `Own` is health at the end of the fight, and `At 3 s` the enemy's health one second before it. Full fight: **21 % and 18 %**.

Rows marked `-w` are `--without "Row"` on `variants/grindstone-mixed.fight.json`, with no extra file. The others are `variants/grindstone-no-[name].fight.json`.

### Trunk, nodes 1 to 24 (both lines)

| Nodes | Type | Row | Each | Total | Form | Layer | Rung | Status | Removed by | Own | At 3 s |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1–3 | acupoint ×3 | Metal damage | +2 % | +6 | Increased | L1 | Multiplier | ○ | `-w` | 4 % | 23 % |
| 4 | notable | **Bright Steel (Minh Cương)** | +12 % Metal damage | +12 | Increased | L1 | Multiplier | ○ | `-w` | 4 % | 26 % |
| 5–7 | acupoint ×3 | Crit chance | +0.4 % | +1.2 | Increased | none | Crit | ● | `crit-chance` | 21 % | 21 % |
| 8–9 | acupoint ×2 | Crit damage | +1.5 % | +3 | Increased | none | Crit | ● | `crit-damage` | 21 % | 19 % |
| 10–12 | acupoint ×3 | Weapon attack | +1.5 % | +5.1 L3 | Increased | L3 | Multiplier | ● | `-w` | 21 % | 22 % |
| 13 | notable | **Good Steel (Hảo Cương)** | +10 % weapon attack | +11.4 L3 | Increased | L3 | Multiplier | ● | `-w` | 4 % | 24 % |
| 14–16 | acupoint ×3 | Artifact power | +0.9 % | +3.5 L3 | Increased | L3 | Multiplier | ● | `-w` | 21 % | 21 % |
| 17–19 | acupoint ×3 | Maximum linh lực | +1.2 % | +3.6 | Increased | none | Fuel | ● | `linh-luc` | 21 %, pool 2 % | 18 % |
| 20–22 | acupoint ×3 | Maximum health | +1 % | +3 | Increased | none | Survival | ● | `health` | 19 % | 18 % |
| 23 | notable | **Tough Grain (Kiên Văn)** | +6.5 % health | +6.5 | Increased | none | Survival | ● | `tough-grain` | 16 % | 18 % |
| 24 | acupoint | **Ore Vein (Khoáng Mạch)** | +1 to Metal arts per artifact equipped, 6 at most | +5 | Per | L2 | Multiplier | ○ | `-w` | 21 % | 22 % |

### The Edge (Nhận), nodes 25 to 34: the build

| Nodes | Type | Row | Each | Total | Form | Layer | Rung | Status | Removed by | Own | At 3 s |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | notable | **Deep Bite (Thâm Thực)** | +10 % crit damage | +10 | Increased | none | Crit | ● | `deep-bite` | 21 % | 21 % |
| 26 | notable | **Hair's Breadth (Phân Hào)** | +5 % crit chance with Metal | +5 | Increased | none | Crit | ○ | `hairs-breadth` | 21 % | 22 % |
| 27–28 | acupoint ×2 | Steady Thread (Ổn Tuyến), Metal tag | +2 while your linh lực is 50 % or above | +4 | Conditional | L5 | Multiplier | ○ reused | `-w` | 21 % | 22 % |
| 29 | notable | Steady Thread, Metal tag | +12, same condition | +12 | Conditional | L5 | Multiplier | ○ reused | `-w` | 4 % | 26 % |
| 30–31 | acupoint ×2 | **Honed Edge (Ma Lợi)** | +2 to Metal arts | +4 | More | L2 | Multiplier | ○ | `-w` | 21 % | 22 % |
| 32–34 | acupoint ×3 | Thinning Ward (Bạc Hộ) | +2 art damage while the enemy has under 50 % linh lực | +6 | Conditional | L1 | Reach | ○ reused | `-w` | 21 %, pool 5 % | 21 % |

### The Point (Tiêm), nodes 25 to 34: the rival

| Nodes | Type | Row | Each | Form | Layer | Rung | Status |
|---|---|---|---|---|---|---|---|
| 25–27 | acupoint ×3 | Accuracy | +0.5 % | Increased | none | Reach | ● |
| 28 | notable | **True Line (Chân Tuyến)** | +3 % accuracy | Increased | none | Reach | ● |
| 29–30 | acupoint ×2 | Sharpened Word | +2 % curse strength | Increased | none | Reach | ○ reused |
| 31 | notable | Full Weight | +12 % curse strength | Increased | none | Reach | ○ reused |
| 32–33 | acupoint ×2 | Set Jaw | +2 art damage while the target bears exactly one curse | More | L2 | Multiplier | ○ reused |
| 34 | notable | Single Grudge | +12, same condition | More | L2 | Multiplier | ○ reused |

### Spurs: on the map, on neither line

| Type | Row | Each | Form | Layer | Status | What it is for |
|---|---|---|---|---|---|---|
| acupoint, notable | Realm pierce, **Long Needle (Trường Châm)** | +0.5 %, +3 % | Increased | none | ● | Only upward, and thin: by Formulas H a notable adds 0.3 points of a hit one realm up, and 0.75 two up. It is a row for three realms and more |
| notable | **Cold Dew (Hàn Lộ)** | +0.6 % of maximum linh lực on a crit | Trigger | none | ○ catalogue | Metal generates Water. For a fast build with many crits. In no fight file |
| notable | **Felling Stroke (Phạt Mộc)** | +12 % Metal damage against a ward that carries Wood | Conditional | L1 | ○ | Metal overcomes Wood. In no fight file |
| notable | **Tempered (Tôi Hỏa)** | +12 % ward strength against Fire | Increased | none | ○ catalogue | Fire overcomes Metal. In no fight file |
| acupoint | Armour defence, Artifact thần thức cost | +1.5 %, −0.8 % | Increased | none | ● | For a road that buys a fifth needle or a real ward. In no fight file |

**Identity piece:** none, on purpose. `identity_id` is `null`.
**The unplanned use:** Thinning Ward was made for curses that thin a ward over time. Here it needs no curse: two plain cuts take the enemy under 50 %, and it turns on at 3 s. Its removal moves the enemy from 18 % to 21 % health and from 0 % to 2 % linh lực at 3 s, and nothing else, so it is one of the softest rows on the road.
**Empty rungs:** Base is the mixed enemy's kit, on purpose. Rate is empty: no speed row. Past the cap is empty because nothing reaches one. L4 is empty, so a blind fight is this same fight.

| Layer | Points at Qi Refining | Multiplier | Sources |
|---|---|---|---|
| L1 | 18, then 24 (arts) · 0 (basic) | ×1.18 to ×1.24 | Metal damage, Bright Steel, Thinning Ward |
| L2 | 29 (arts) · 0 (basic) | ×1.29 | Grindstone Primer 20, Ore Vein 5 from five pieces (Earth generates Metal), Honed Edge 4 |
| L3 | 134.4 | ×2.34 | Four needles 114.4, Weapon attack, Good Steel, Artifact power |
| L4 | 0 | ×1.00 | No preparation |
| L5 | 16 (arts), while the pool holds | ×1.16 | Steady Thread |

Crit: arts 21.2 % at ×1.83, worth ×1.18. Basic 16.2 %. On arts, M 4.14 at t = 1 against the typical 3.27.

## The New Test

Against the mixed enemy, equal realm: **wins at 4 s on 21 %.** All files are `variants/grindstone-[name].fight.json`.

**Remove one: 17 of 17 rows still win at 4 s.** See the Stack. Eleven rows leave the health where it was. Four (Metal damage, Bright Steel, Good Steel, Steady Thread notable) leave the enemy 3 to 7 % linh lực at 3 s, which pays for one more jab, so the win comes on 4 % health. That is the largest move any row makes, and it is a real one: 17 points, always from that one jab.

| Remove together | File | Result |
|---|---|---|
| Five notables: Bright Steel, Good Steel, Deep Bite, Hair's Breadth, Steady Thread | `five-notables` | **Loses at 5 s, enemy on 9 %** |
| Five rows of the trunk's damage: Metal damage, Bright Steel, Weapon attack, Good Steel, Artifact power | `five-trunk` | **Loses at 5 s, enemy on 12 %** |
| Five spread across rungs: Metal damage, Steady Thread, Honed Edge, Hair's Breadth, Tough Grain | `five-spread` | **Loses at 4 s on overkill, both at 0 %** |
| Five sets of acupoints: Metal damage, Crit chance, Weapon attack, Artifact power, Honed Edge | `five-acupoints` | Wins at 4 s on 4 % |
| Five soft rows: Crit chance, Crit damage, Artifact power, Maximum linh lực, Maximum health | `five-kept` | Wins at 4 s on 19 % |
| All 34 nodes, the typical's plain attack back in their place | `no-path` | **Loses at 4 s, enemy on 17 %** |

**Not every five is lost.** Rows of acupoints are worth little alone, and five of them cost only the same jab.

## The Choice

Node 24 is the fork. Both lines cost 10 nodes, and the Point swaps Long Draw for Seam Thrust, which opens the enemy's ward for 2 pulses.

| Enemy | The Edge | The Point |
|---|---|---|
| Mixed | **Wins at 4 s on 21 %** (`mixed`) | Wins at 4 s on overkill, both at 0 % (`point-mixed`) |
| Evader, 15 % | Loses at 5 s, enemy on 1 % (`evader`) | **Wins at 4 s on overkill, both at 0 %** (`point-evader`) |
| Wall: ward 150, twice the pool, one jab | Wins at 7 s on 47 % (`wall`) | **Wins at 6 s on 55 %** (`point-wall`) |
| Each other | **Wins at 4 s on overkill, both at 0 %** (`duel-point`) | |

The Edge is healthier against an ordinary rival. The Point reaches what stands behind something. Neither is safe.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal, purity 50 | Sets the sector scale. Purity is not a fight input, but the row sizes above assume it |
| Key talents | Thần hồn 45, the typical | Thần thức 45, exactly four needles and a shirt. That is the only source of sense. Fortune and heart demon are not read |
| The rest of the tree | The typical's ward, linh lực and health shares | Pools copy the typical, then the rows |
| The Way (Đạo) | None | |

## Công Pháp

### Grindstone Primer (Ma Thạch Thiên) — main, Huyền giai

One page on the edge, one on the point, and forty on keeping your wheel true.

```json
{"id": "ma_thach_thien", "name": "Ma Thạch Thiên", "tier": 1, "tech_kind": "main",
 "names": ["kim"], "layers": 9, "bonuses": [],
 "abilities": [{"ability_id": "plain_cut", "unlock_layer": 1}, {"ability_id": "long_draw", "unlock_layer": 3},
               {"ability_id": "seam_thrust", "unlock_layer": 3}, {"ability_id": "full_cleave", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

Passive: +20 points to Metal arts, under the typical's 40. **Fit:** Needs key.

## Arts

| Art | Layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Plain Cut (Bình Trảm) | 1 | body, Metal, hit | 1.4 | 0.05 | 1 s | none | Needs key |
| Long Draw (Trường Tha) | 3 | qi, Metal, hit | 2.2 | 0.08 | 3 s | none | Needs key |
| Full Cleave (Toàn Phách) | 6 | body, Metal, hit | 3.6 | 0.12 | 6 s | own linh lực 30 % or above | Needs key |
| Seam Thrust (Tầm Phùng Thích) | 3 | body, Metal, hit, curse | 1.8 | 0.06 | 2 s | none | Needs key |

The first three are the mixed enemy's jab, strike and heavy, number for number. Seam Thrust's curse is `pass_raise` 0.40 for 2 pulses, ×1.16 on the Point. Full Cleave never fires here, because the fight ends first.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Four mending needles | Artifact, weapon | `cham`, Hạ phẩm, tier 0 | Attack 28.6 each, 10 thần thức each, so L3 114.4 | Fits today |
| One mail shirt | Artifact, ward | `giap`, Hạ phẩm, tier 0 | Defence 39, 5 thần thức, so ws and we 17.0 with the typical's 5.3 | Fits today |

The same 45 thần thức, 5 of 6 pieces. The typical's L3 40 and ward 31 are about one sword, one shield and one shirt.

## Matchups

| Enemy | Result | Input |
|---|---|---|
| Mixed typical, equal | Wins at 4 s on 21 % | `mixed` |
| One cheap art, equal | Wins at 4 s on 22 % | `jab` |
| Foreseen, no home ground | The same fight: nothing is prepared and no ground is read | `mixed` |
| Mixed, one realm up | Loses at 2 s, enemy on 89 % | `mixed --gap 1` |
| Mixed top-end, equal | Loses at 1 s, enemy on 94 % | `mixed --enemy top_end` |
| Second realm, Core: same 34 nodes, typical attack share kept, gear at tier | Wins at 3 s on 34 % | `core-mixed` |
| Third realm, Deity: same, on a later manual | Wins at 4 s on 33 % | `deity-mixed` |

**Counter:** a same-realm evader, or a ward of 100 or more. **Metal does not beat Wood by right:** the cycle touches a fight only through `pass_tag`. The Evergreen Road, on 75 nodes to these 34, wins that Deity duel at 7 s on overkill, both at 0 % (`variants/evergreen-duel-grindstone.fight.json`).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | No bonuses on the Primer. All arts within lint. 3 of 3 slots. 45 of 45 thần thức, 5 of 6 pieces. 34 of 51 points |
| Validity | PASS | Real bases, grades and tier. Huyền giai reaches Core; the Deity row names a later manual |
| Stack | PASS | Forms: Increased, More, Conditional, Per. Empty rungs named. L4 empty, stated |
| New test | PASS | 17 of 17 rows still win. Three saved fives and `no-path` lose, and two saved fives that still win are shown |
| Scaling | PASS | M 4.14 against typical 3.27, top-end 103. Ordinary, as stated |
| The fight | PASS | No cap hit. Full Cleave never fires, stated |
| Reuse | PASS | Steady Thread and Thinning Ward proved in the main fight. Every row has a second home in `pieces/grindstone.json` |
| Counterplay | PASS | Evader, heavy ward |

## Fight Results

Input: `sheets/grindstone.fight.json`, 0 plug-ins. A paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Cap hits |
|---|---|---|---|---|
| typical | 0 | Wins on 27 % | 3 s | none |
| typical | 1 | Loses, enemy on 89 % | 2 s | none |
| typical | 2 | Loses, enemy on 99 % | 1 s | none |
| top_end | 0, 1, 2 | Loses, enemy on 94 %, 99 %, 100 % | 1 s | none |

**Unmodelled:** Hair's Breadth does not reach the basic attack, so `basic.c` is lowered to take out what the calculator's single crit would give it. `Weapon attack` and `Artifact power` are stated in L3 points at this kit, and their removal runs treat them as additive.

## Questions for the User

1. Realm pierce at catalogue sizes is worth 0.3 % of a hit one realm up. Is it meant to matter only three realms up?
2. Four Hạ phẩm needles give L3 114 for 40 thần thức. No armour line came close to that per point of sense, so the fork here is edge and point, not blade and mail. Is that gap intended?
3. The Five Phases touch a fight only through `pass_tag`. Should a road have overcoming rows before that is settled?

## Also Considered

- **Blade against Mail:** five mail shirts for 25 thần thức instead of needles. It lost to the blade in every shape tried, so it became a question.
- **One art and a bare rack:** a single cut with Bare Rack on two empty slots. Good, but a player who owns three arts would slot them, so the sheet stopped pretending otherwise.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Metal damage, Bright Steel, Hair's Breadth, Honed Edge, Felling Stroke, Tempered | Needs key | One key shape that names a tag, as the catalogue already asks |
| Ore Vein, Cold Dew | Needs key | A count of equipped pieces at compile, and the catalogue's crit refund |
| Grindstone Primer, four arts | Needs key | Technique passive and art records |
