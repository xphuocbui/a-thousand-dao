# The Evergreen Road (Trường Thanh Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Wood. Ordinary tag-scoped rows, 0 rule asks, no enabler, two rival lines, one build of 10 or more rows. Remove any one and the fight barely moves; remove five and it is lost.
> **Direction**: A tree grows upward or it spreads. A 75-node road for a Deity Transformation walker, forking at node 57. This build walks the Crown (out-last them in linh lực). The Bramble (ticks under the ward) is proved beside it.
> **Realm span**: Core Formation – Deity Transformation, defined at Deity Transformation · **Power level**: ordinary · **Use**: player build, or an old sect's standing elder
> **Fit**: 6 Fits today · 19 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hits and the basic attack. The Crown has no ticks.
- **The enabler:** none.
- **The loop:** the mixed enemy's own three arts, renamed. Spend, drink, and do not change anything while you are losing.
- **The engine:** the pool race. In this game whoever's linh lực reaches 0 first takes every later hit in full, so the health bar lies. Eleven rows make your pool bigger, cheaper, slower to drain and faster to refill, and your body last until it pays. Ten make your arts hit harder.
- **The sacrifice:** the first five seconds, and 117 W of plain attack. L1 stops at the soft cap.
- **The arc:** at Core the road is a third of a life. At Deity it is 75 of 566 points, and each point of L1 past 200 counts half, which is what pays for it.

## The Legend

Thanh keeps the old tea trees on Cold Ridge, as somebody always has. It is dry country. Every morning for longer than any record of the place, Thanh has carried water up to the highest terrace, a little at a time, because the trees cannot be watered more than they can drink. They reached Deity Transformation without ever being in a hurry, and it would be wrong to call that patience. It is closer to faith: that what is given a little every day does not run out, and that the thing in front of you will.

People climb the ridge to fight Thanh, because old cultivators are worth a name. Thanh sets down the water first. For five seconds the visitor is winning, and can see it, and Thanh can see it too, and does not change anything. Afterwards Thanh walks them down to the path if they can walk, and goes back to the terrace. There is still the top row to do.

## How It Fights

Thanh is behind on health at every second until the last: 88 to 90, 57 to 63, 34 to 36. Behind that bar the other race is already over. At 3 s Thanh's pool is 39 % and the enemy's 24 %. At 5 s it is 17 % and 0 %. With nothing left to pay the ward, the enemy takes the next instant in full and falls from 36 % to nothing.

**The signature moment:** at 5 s you are on 34 % and they are on 36 %, and the fight is decided. One second later it is over and you still have 29 % (`variants/evergreen-mixed.fight.json --timeline`).

## The Stack

Sizes are the catalogue's where it has a row, and first guesses elsewhere. **Nodes** run in walking order: 75 nodes, 61 acupoints and 14 notables, 185.2 W, paid by 117 W of plain attack (L1 176, not the typical's 293) and 68 W from outside combat. Wood damage then sits exactly on L1's soft cap of 200. Sector rows scale with purity, so these sizes assume purity 50: 0.5 + purity / 100 (Meridian Map rule 4). ● means the key exists today.

`Own` is health at the end of the fight, and `At 5 s` the enemy's health one second before it. Full fight: **29 % and 36 %**. Rows marked `-w` are `--without "Row"` on `variants/evergreen-mixed.fight.json`, with no extra file. The others are `variants/evergreen-no-[name].fight.json`.

### Trunk, nodes 1 to 57 (both lines)

| Nodes | Type | Row | Each | Total | Form | Layer | Rung | Status | Removed by | Own | At 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1–6 | acupoint ×6 | Wood damage | +2 % | +12 | Increased | L1 | Multiplier | ○ | `-w` | 29 % | 43 % |
| 7 | notable | **Green Heart (Thanh Tâm)** | +12 % Wood damage | +12 | Increased | L1 | Multiplier | ○ | `-w` | 29 % | 43 % |
| 8–13 | acupoint ×6 | Linh lực regeneration | +0.15 % a second | +0.9 | Increased | none | Fuel | ● | `regeneration` | 29 %, pool 1 % | 40 % |
| 14 | notable | **Deep Drink (Thâm Ẩm)** | +1 % a second | +1 | Increased | none | Fuel | ● | `deep-drink` | 29 %, pool 1 % | 41 % |
| 15–17 | acupoint ×3 | Wood art cost | −1 % | −3 | Increased | none | Fuel | ○ | `art-cost` | 29 %, pool 4 % | 36 % |
| 18 | notable | **Thin Leaf (Bạc Diệp)** | −6 % Wood art cost | −6 | Increased | none | Fuel | ○ | `thin-leaf` | 29 %, pool 3 % | 36 % |
| 19–30 | acupoint ×12 | Maximum health | +1 % | +12 | Increased | none | Survival | ● | `health` | 20 % | 36 % |
| 31 | notable | **Old Bark (Lão Bì)** | +6.5 % health | +6.5 | Increased | none | Survival | ● | `old-bark` | 25 % | 36 % |
| 32–43 | acupoint ×12 | Maximum linh lực | +1.2 % | +14.4 | Increased | none | Fuel | ● | `linh-luc` | 21 %, pool 0 % | 36 % |
| 44 | notable | **Full Trunk (Mãn Thân)** | +8 % linh lực | +8 | Increased | none | Fuel | ● | see below | | |
| 45–56 | acupoint ×12 | Ward efficiency | +1.2 % | +14.4 | Increased | none | Survival | ● | `ward-efficiency` | 29 %, pool 0 % | 36 % |
| 57 | notable | **Slow Sap (Hoãn Dịch)** | +8 % ward efficiency | +8 | Increased | none | Survival | ● | see below | | |

### The Crown (Thụ Quan), nodes 58 to 75: the build

| Nodes | Type | Row | Each | Total | Form | Layer | Rung | Status | Removed by | Own | At 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 58 | notable | Full Trunk, a second time | +8 % linh lực | +16 with node 44 | Increased | none | Fuel | ● | `full-trunk`, both | 18 %, pool 0 % | 36 % |
| 59 | notable | Slow Sap, a second time | +8 % ward efficiency | +16 with node 57 | Increased | none | Survival | ● | `slow-sap`, both | 28 %, pool 0 % | 36 % |
| 60 | notable | **Spring Vein (Tuyền Mạch)** | +1 % regeneration a second | +1 | Increased | none | Fuel | ● | `spring-vein` | 29 %, pool 1 % | 41 % |
| 61 | notable | **Sap Rise (Dịch Thăng)** | +4 to Wood arts per 1 % of regeneration bonus | +11.6, 24 at most | Per | L2 | Multiplier | ○ | `-w` | 29 % | 48 % |
| 62–64 | acupoint ×3 | **Living Wood (Hoạt Mộc)** | +2 to Wood arts | +6 | More | L2 | Multiplier | ○ | `-w` | 29 % | 43 % |
| 65 | notable | Living Wood | +12 to Wood arts | +12 | More | L2 | Multiplier | ○ | `-w` | 29 % | 48 % |
| 66–68 | acupoint ×3 | Sustained Note (Dư Âm) | +0.2 to arts per second of the fight | +0.6 a second | Per | L2 | Multiplier | ○ reused | `-w` | 29 % | 38 % |
| 69 | notable | Sustained Note | +1 a second, to the `time_limit` | +1 a second | Per | L2 | Multiplier | ○ reused | `-w` | 29 % | 40 % |
| 70–73 | acupoint ×4 | Steady Thread (Ổn Tuyến), Wood tag | +2 while your linh lực is 50 % or above | +8 | Conditional | L5 | Multiplier | ○ reused | `-w` | 29 % | 45 % |
| 74 | notable | Steady Thread, Wood tag | +12, same condition | +12 | Conditional | L5 | Multiplier | ○ reused | `-w` | 29 % | 47 % |
| 75 | notable | **Late Leaf (Vãn Diệp)** | +12 to Wood arts after the fourth second | +12 | Conditional | L5 | Multiplier | ○ | `-w` | 29 % | 41 % |

### The Bramble (Kinh Tùng), nodes 58 to 75: the rival

Each art carries Thorn (Thích): `c_tick` 0.15, 3 pulses, chance 0.60, a body tick. Their hits fall to `c_art` 1.0, 1.7 and 3.0 to pay for it.

| Nodes | Type | Row | Each | Form | Layer | Rung | Status |
|---|---|---|---|---|---|---|---|
| 58–61 | acupoint ×4 | Wood art speed | +1 % | Increased | none | Rate | ○ |
| 62 | notable | **Quick Shoot (Tấn Manh)** | +6 % Wood art speed | Increased | none | Rate | ○ |
| 63–65 | acupoint ×3 | Status chance | +1 % | Increased | none | Base | ○ reused |
| 66 | notable | **Catching Thorn (Câu Thích)** | +6 % status chance | Increased | none | Base | ○ |
| 67–70 | acupoint ×4 | Damage over time | +2 % | Increased | L1 | Multiplier | ○ reused |
| 71 | notable | **Deep Thorn (Thâm Thích)** | +12 to Wood over-time statuses | More | L2 | Multiplier | ○ |
| 72 | notable | Stoked (Thiêm Sài), Wood tag | +3 to arts per stack on the enemy | Per | L2 | Multiplier | ○ reused |
| 73–75 | acupoint ×3 | Maximum health | +1 % | Increased | none | Survival | ● |

### Spurs: on the map, on neither line

None of these is in a fight file.

| Type | Row | Each | Form | Layer | Status | What it is for |
|---|---|---|---|---|---|---|
| notable | **Kindling (Dẫn Nhiên)** | +12 % Fire damage while the enemy carries a Wood status | Conditional | L1 | ○ | Wood generates Fire. Reaches from the Bramble to the Two Heats |
| notable | **Cracked Stone (Liệt Thạch)** | +12 % Wood damage against a ward that carries Earth | Conditional | L1 | ○ | Wood overcomes Earth |
| notable | **Green Wall (Thanh Bích)** | +12 % ward strength against Metal | Increased | none | ○ catalogue | Metal overcomes Wood |

**Identity piece:** none, on purpose. `identity_id` is `null`.
**The unplanned use:** Sustained Note was written for a long carry, and Steady Thread for a sword school's full pool. Here one takes over as the other ends: Steady Thread falls off at about 3 s when the pool drops under 50 %, and Late Leaf and Sustained Note are rising by then. Removing all of them is what `five-damage` shows.
**Regeneration here means linh lực.** No rule heals health in a fight, and this sheet asks for none.
**Empty rungs:** Crit is left at the typical's 15 % at ×1.7. Reach and Past the cap are empty. Old Bough never fires in the main fight, because its guard needs a pool of 30 % at 6 s, and the pool is already 17 % at 5 s. L4 is empty, so a blind fight is this same fight.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | 200 (arts), 176 (basic) | ×3.00, ×2.76 | Plain attack 176, Wood damage, Green Heart |
| L2 | 49.6, plus 1.6 a second (arts) | ×1.50 at t = 0, ×1.59 at 6 s | Canon 20, Living Wood 18, Sap Rise 11.6, Sustained Note |
| L3 | 40 | ×1.40 | The typical's gear |
| L4 | 0 | ×1.00 | No preparation |
| L5 | 20 while the pool holds, then 12 after 4 s (arts) | ×1.20, then ×1.12 | Steady Thread, Late Leaf. The pool is under 50 % before Late Leaf opens, so they never add |

Regeneration 4.9 % a second against the enemy's 2 %. Pool +30.4 %, efficiency 114.5 against 84.1. On arts, M 7.62 at t = 1 against the typical 8.96: it is the weaker fighter at the start, on purpose.

## The New Test

Against the mixed enemy, equal realm: **wins at 6 s on 29 %.** All files are `variants/evergreen-[name].fight.json`.

**Remove one: 21 of 21 rows still win at 6 s.** See the Stack, where `full-trunk` and `slow-sap` take out both copies. The largest move is 11 points of health, from Full Trunk. Damage rows do not touch your health at all and only move the enemy's bar: they make the last second harder, not the race. Regeneration rows also lower Sap Rise, and that is in their files.

| Remove together | File | Result |
|---|---|---|
| Five pool rows: Maximum linh lực, Full Trunk, Ward efficiency, Slow Sap, Spring Vein | `five-pool` | **Loses at 6 s, enemy on 49 %** |
| Five damage rows: Green Heart, Living Wood, Sustained Note, Steady Thread (all notables), Sap Rise | `five-damage` | **Loses at 6 s, enemy on 2 %** |
| Five of the trunk: Regeneration, Deep Drink, Maximum health, Old Bark, Wood art cost | `five-trunk` | Wins at 7 s on overkill, both at 0 % |
| Four acupoint rows and one notable: Wood damage, Living Wood, Sustained Note, Steady Thread, Late Leaf | `five-kept` | Wins at 6 s on 21 % |
| All 75 nodes, plain attack back to 293 | `no-road` | **Loses at 5 s, enemy on 57 %** |

**Not every five is lost.** The pool rows are the cliff: take five of them and it does not matter that your arts are unchanged, since the enemy still stands on 49 %. Damage rows are a slope. And five trunk rows survive only on overkill, with both fighters down.

## The Choice

Node 57 is the fork, and each line costs 18 nodes. The Crown wins the race with people. The Bramble goes under the ward, and is the only one that beats a mountain: Wood overcomes Earth by getting in, and that comes out of the numbers, not the theme.

| Enemy | The Crown | The Bramble |
|---|---|---|
| Mixed | **Wins at 6 s on 29 %** (`mixed`) | Loses at 6 s, enemy on 31 % (`bramble-mixed`) |
| The Mountain: five times the pool, twice the health, ward 300, no arts | Loses at 32 s, enemy on 14 % (`mountain`) | **Wins at 23 s on 52 %** (`bramble-mountain`) |
| Each other | **Wins at 6 s on 44 %** (`duel-bramble`) | |

Against the Mountain the Crown's linh lực reaches 1 % at 20 s, and from then on it is losing a long, slow fight it was built for, because every hit it lands goes into a ward it cannot empty.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood, purity 50 | Sets the sector scale. Purity is not a fight input, but the row sizes above assume it |
| Key talents | The typical's | Sense stays at 1.0 on both sides, and fortune and heart demon are not read |
| The rest of the tree | The typical's ward strength and health | Ward strength 84.1 is unchanged. Efficiency comes from the road |
| The Way (Đạo) | None | |

## Công Pháp

### Evergreen Canon (Trường Thanh Kinh) — main, Thiên giai

It opens with how much water a young tree can take, and it never really moves on from that.

```json
{"id": "truong_thanh_kinh", "name": "Trường Thanh Kinh", "tier": 3, "tech_kind": "main",
 "names": ["moc"], "layers": 15, "bonuses": [],
 "abilities": [{"ability_id": "new_shoot", "unlock_layer": 1}, {"ability_id": "long_root", "unlock_layer": 5},
               {"ability_id": "old_bough", "unlock_layer": 10}],
 "seal_clusters": [], "origin": "authored"}
```

Passive: +20 points to Wood arts, under the typical's 40. **Fit:** Needs key.

## Arts

| Art | Layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| New Shoot (Tân Manh) | 1 | body, Wood, hit | 1.4 | 0.05 | 1 s | none | Needs key |
| Long Root (Trường Căn) | 5 | qi, Wood, hit | 2.2 | 0.08 | 3 s | none | Needs key |
| Old Bough (Lão Chi) | 10 | body, Wood, hit | 3.6 | 0.12 | 6 s | own linh lực 30 % or above | Needs key |

These are the mixed enemy's jab, strike and heavy, number for number, so the two fighters differ only in the road. On the Bramble each has a thorned form, as stated above. **Three of 7 slots:** a plain character with one technique.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Common kit | Weapon and ward pieces | The typical's | L3 40, ws 84.1 | Fits today |

## Matchups

| Enemy | Result | Input |
|---|---|---|
| Mixed typical, equal | Wins at 6 s on 29 % | `mixed` |
| One cheap art, equal | Wins at 6 s on 37 % | `jab` |
| Foreseen, no home ground | The same fight: nothing is prepared and no ground is read | `mixed` |
| Mixed top-end, equal | Loses at 1 s, enemy on 99 % | `mixed --enemy top_end` |
| Second realm, Core: same 75 nodes, typical attack share kept | Wins at 5 s on 23 % | `core-mixed` |
| The Grindstone Road at Deity, 34 nodes to these 75 | Wins at 7 s on overkill, both at 0 % | `duel-grindstone` |

Deity Transformation is the top of the realm list, so there is no real one-up fight here. `mixed --gap 1` runs the same enemy with suppression on your hits, and is not a realm test.

**Counter:** anything that kills before 6 s, and any pool it cannot race. It also has no answer to a ward it cannot empty, as the Mountain shows. Metal should beat it, and an ordinary Metal road on under half the nodes comes within one instant of doing so.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | No bonuses on the Canon. All arts within lint. 3 of 7 slots. 75 of 566 points |
| Validity | PASS | Thiên giai reaches Deity. Real keys and realm |
| Stack | PASS | Forms: Increased, More, Conditional, Per. Empty rungs named. L4 empty, stated |
| New test | PASS | 21 of 21 rows still win. `five-pool`, `five-damage` and `no-road` lose. Two saved fives that do not are shown |
| Scaling | PASS | M 7.62 against typical 8.96, top-end 325. Below the anchor at t = 1 and still wins. Ordinary, as stated |
| The fight | PASS | No cap hit in the main fight. Old Bough never fires, stated |
| Reuse | PASS | Sustained Note and Steady Thread proved in the main fight. Every row has a second home in `pieces/evergreen.json` |
| Counterplay | PASS | The Mountain, and any fast killer |

## Fight Results

Input: `sheets/evergreen.fight.json`, 0 plug-ins. A paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Cap hits |
|---|---|---|---|---|
| typical | 0 | Wins on 42 % | 6 s | none |
| typical | 1, 2 | The same Deity enemy, with suppression on your hits: wins on 42 %, 32 % | 6 s | none |
| top_end | 0, 1, 2 | Loses, enemy on 99 % | 1 s | none |

**Unmodelled:** Status duration is not on the Bramble, because whole pulses leave it with nothing to do. Status chance ignores `status_resist_pct`, since the calculator has no resist.

## Questions for the User

1. Fast arts still beat slow ones at the art lint. A slow forest of seven cheap arts lost to quick thorns everywhere it was tried, so both roads here use the enemy's kit. Is a slow Wood kit meant to be a real option?
2. No rule heals health in a fight. Is linh lực regeneration the intended meaning of Wood, or does the road want a rule later?
3. Should L1's soft cap make 40 % of a Deity attack share a poor buy? It is the only reason this road can pay for itself.

## Also Considered

- **Roots against Crown:** a line of qi burn to starve the enemy. Its cap of 5 % a pulse is small beside what hits and their own spending do, so the Crown beat it everywhere. The Bramble replaced it.
- **A seven-art canopy:** every slot full of slow, cheap arts, spending exactly what it drinks. Beautiful, and it lost.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Wood damage, Wood art cost, Wood art speed and named notables | Needs key | One key shape that names a tag |
| Sap Rise | Needs key | A read of the regeneration bonus at compile |
| Late Leaf | Needs key | A modifier condition on fight time. `time_above` is a guard word already |
| Evergreen Canon, 3 arts, Thorn | Needs key | Technique passive, art records, a status record |
