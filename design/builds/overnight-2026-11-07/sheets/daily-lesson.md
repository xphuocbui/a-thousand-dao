# The Daily Lesson (Nhật Khóa Kiếm)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 1, the Plain Stack for Sword: "the game, much like poe, is stacking modifiers on a concept." 16 or more ordinary modifiers, no enabler, 0 rule asks, one build on a real choice between two lines. Remove any one and the fight barely moves; remove five and it is lost.
> **Direction**: One trunk of plain sword nodes, then a fork: open the hand and fly the swords, or keep the hand on the sword and cut fast. This sheet walks the Flown Line and proves the Held Line beside it.
> **Realm span**: Qi Refining – Core Formation, defined at Foundation Establishment · **Power level**: ordinary · **Use**: player build, or the standard pupil of any plain sword school
> **Fit**: 8 Fits today · 35 Needs key · 0 Needs rule
> **Checks**: 10 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hits, on all five layers, from three flying swords that fire together. No ticks, no triggers, nothing strange.
- **The enabler:** none.
- **The loop:** stand for two seconds, then let all three swords go in one instant. If the enemy still stands, wait two more.
- **The engine:** five layers multiplied. 30 nodes give ×1.32, ×1.67, ×2.38, ×1.20 and ×1.20, with +6.6 % crit chance on top. No single row carries more than a sixth of the volley.
- **The sacrifice:** the ward kit. The 120 thần thức that would have carried a shield and a bell carries two more swords, so ward strength falls from 37.9 to 12.4. It also gives up speed, reach and fuel. Any fight that goes past the second volley is a bad one.
- **The arc:** at Qi Refining it is one sword and a habit. At Foundation the third sword arrives and the hand opens. At Core the same rows are simply longer.

## The Legend

The school at Stone Gate Pass (Thạch Quan) has one rule and no secret. Before breakfast every pupil goes out to the yard and does the lesson, the same forms in the same order, in whatever weather there is. The founder had an ordinary root, an ordinary manual and a bad knee, and spent a long life finding out that an ordinary root can be trusted if it is asked the same small thing every morning. Nobody there has been handed anything. Pupils who arrive looking for a hidden page are shown the yard.

In the fourth year each pupil comes to the same place, and the teacher says the only hard thing they will ever say: you may keep your hand on the sword, or you may open it. Some keep it, and grow quick, and spend themselves. Others open it, and stand for two long seconds with nothing between them and the blow, trusting what they made. Most are afraid the first time. The teachers do not promise that this will pass, because it does not. They say only that the swords have been told where to go every morning for years, and that they will go.

## How It Fights

For the first second almost nothing happens. The enemy strikes, the cultivator takes it on a thin ward and answers with a plain cut. At two seconds the three swords leave together, and each carries the whole stack. Nothing in the volley is clever. It is 30 small decisions arriving in one instant.

**The signature moment:** a same-realm rival stands on 94 % with 90 % of their linh lực, and one second later they are dead with the cultivator on 52 % health and 42 % linh lực. Their second and third arts never fire, which is why the single-art enemy gives the same result (`variants/daily-lesson-mixed.fight.json`, `variants/daily-lesson-one-art.fight.json`).

## The Stack

The node list for the Flown Line, in walking order: 30 nodes, 25 acupoints and 5 notables, 70 W. That is the quarter of Foundation's 120 points a typical life spends on attack, where it buys 62 W of plain `attack_pct`. Catalogue rows keep their catalogue sizes. Sizes on Long Flight, Steady Thread and Many Threads are first guesses at the catalogue's sword rate, and all three sit near the size of Sword damage. Home is the tree for every row.

`Without` is the single-removal file, `variants/daily-lesson-no-[slug]-mixed.fight.json`. Every one of the 11 still wins at t = 2 with 52 % health and 42 % linh lực. `Volley` is what the three swords deal, out of 348 with nothing removed.

| Step | Node | Kind | Each | Total | Form | Layer | Rung | Status | Without | Volley |
|---|---|---|---|---|---|---|---|---|---|---|
| 1–10 | **Sword damage** | acupoint ×10 | +2 % | +20 % | Increased | L1 | Multiplier | ○ | `sword-a` | 295 |
| 11 | **Sword damage** | notable | +12 % | +12 % | Increased | L1 | Multiplier | ○ | `sword-n` | 316 |
| 12–13 | **Crit chance with swords** | acupoint ×2 | +0.8 % | +1.6 % | Increased | none | Crit | ○ | `critch-a` | 344 |
| 14 | **Crit chance with swords** | notable | +5 % | +5 % | Increased | none | Crit | ○ | `critch-n` | 337 |
| | *The fork: from here the road is the Flown Line* | | | | | | | | | |
| 15–17 | **Flying sword attack** | acupoint ×3 | +2 % per sword | +7 points | Increased | L3 | Multiplier | ○ | `fly-a` | 338 |
| 18 | **Flying sword attack** | notable | +12 % per sword | +14 points | Increased | L3 | Multiplier | ○ | `fly-n` | 327 |
| 19–21 | **Long Flight (Trường Phi)**: sword arts with an authored cooldown of 2 s or more | acupoint ×3 | +2 | +6 | More | L2 | Multiplier | ○ | `long-a` | 335 |
| 22 | **Long Flight** | notable | +12 | +12 | More | L2 | Multiplier | ○ | `long-n` | 323 |
| 23–26 | **Steady Thread (Ổn Tuyến)**: sword arts while your linh lực is at 50 % or above | acupoint ×4 | +2 | +8 | Conditional | L5 | Multiplier | ○ | `steady-a` | 325 |
| 27 | **Steady Thread** | notable | +12 | +12 | Conditional | L5 | Multiplier | ○ | `steady-n` | 313 |
| 28–30 | **Many Threads (Đa Tuyến)**: sword arts, per flying sword equipped | acupoint ×3 | +1 per sword | +9 | Per | L2 | Multiplier | ○ | `threads-a` | 329 |

### The other road: the Held Line

The same 14 trunk nodes, then 16 of these. It is saved whole as `variants/daily-lesson-held-mixed.fight.json`.

| Node | Kind | Each | Total | Form | Layer | Rung | Status |
|---|---|---|---|---|---|---|---|
| **Sword art speed** | acupoint ×3 | +1 % | +3 % | Increased | none | Rate | ○ |
| **Sword art speed** | notable | +6 % | +6 % | Increased | none | Rate | ○ |
| **Short Edge (Đoản Phong)**: sword arts with an authored cooldown under 2 s | acupoint ×4 | +2 | +8 | More | L2 | Multiplier | ○ |
| **Short Edge** | notable | +12 | +12 | More | L2 | Multiplier | ○ |
| **Spent Breath (Khí Tận)**: sword arts while your linh lực is at 50 % or below | acupoint ×2 | +2 | +4 | Conditional | L5 | Multiplier | ○ |
| **Spent Breath** | notable | +12 | +12 | Conditional | L5 | Multiplier | ○ |
| **Many Forms (Đa Thức)**: sword arts, per sword art slotted | acupoint ×2 | +1 per art | +6 | Per | L2 | Multiplier | ○ |
| **Sword art cost** | acupoint ×2 | −1 % | −2 % | Increased | none | Fuel | ○ |

### Beside the road

Real rows that neither walk takes, for the next sword build. Small, then notable.

| Node | Small / notable | Form | Layer | Rung | Status | Which line wants it |
|---|---|---|---|---|---|---|
| **Crit damage** | +1.5 % / +10 % | Increased | none | Crit | ● | Either, once crit chance is high |
| **Accuracy** | +0.5 % / +3 % | Increased | none | Reach | ● | Either, against evaders |
| **Realm pierce** | +0.5 % / +3 % | Increased | none | Reach | ● | Either, fighting upward |
| **Ward strength** | +1.2 % / +8 % | Increased | none | Survival | ● | Flown, to buy back the kit |
| **Follow Through (Thuận Thế)**, per 1 % of the enemy's health missing | +0.02 / +0.12 | Per | L2 | Multiplier | ○ | Held, whose hits arrive in order |
| **Damage to an enemy with no linh lực** | +2.5 % / +15 % | Conditional | L1 | Reach | ○ | Flown, for the second volley |
| **Weapon efficiency** | −1 % / −6 % | Increased | none | Fuel | ○ | Flown, toward a fourth sword |
| **First firing comes sooner** | −2 % / −12 % | Timing | none | Rate | ○ | Flown. Not in any fight file |
| **Sword art cost** (notable) | −6 % | Increased | none | Fuel | ○ | Held |
| **Linh lực regained on a crit** | +0.1 % / +0.6 % | Trigger | none | Fuel | ○ | Held |

That makes 20 modifiers and 38 rows, across Increased, More, Conditional, Per, Trigger and Timing, with 0 rule asks and no enabler.

**Identity piece:** none, on purpose. The nearest thing is the fork, and `Steady Thread (notable)` stands in as the `--without` id, because its condition can never be true at the same moment as Spent Breath's, the Held Line's answer. `[C]` was taken on the stack: Sword art cost and Ward strength were on the Flown walk until their removal runs moved nothing, so they became damage nodes.

**Reused:** Full Title from The Loud Sword, as the technique's passive, and Whetstone Water in the foreseen fight.

**Empty rungs:** Rate is a sacrifice, as the Flown Line has no speed. Reach is a sacrifice, and an evader beats it. Past the cap is empty because nothing reaches a cap. Fuel is a sacrifice, because a volley every 2 s leaves 42 % in the main fight. Survival is the price named in the Spine.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 32 | ×1.32 | Sword damage. No plain `attack_pct` |
| L2 | 67 | ×1.67 | Full Title 40, Long Flight 18, Many Threads 9 |
| L3 | 138 | ×2.38 | Three swords 117, Flying sword attack 21 |
| L4 | 20 | ×1.20 | The enemy's own preparation, matched. 0 in a blind fight |
| L5 | 20 | ×1.20 | Steady Thread, while the pool holds |
| M | | ×7.56 | Typical at Foundation is ×4.19. Crit is 21.6 % at ×1.7 |

## The Test

All in `variants/daily-lesson-[name].fight.json`, against the mixed enemy at the same realm. The full fight wins at t = 2 on 52 %.

**Remove one:** see the Stack table. No row changes the time, the health or the linh lực. Only the volley moves, by 15 % at worst.

**Remove five:**

| File | Removed | Result |
|---|---|---|
| `five-notables-mixed` | All five notables | Loses at t = 4, enemy on 5 % |
| `five-acupoints-mixed` | One acupoint row of each kind: Sword, Crit, Fly, Long, Steady | Loses at t = 4 on overkill, both at 0 % |
| `five-fork-mixed` | Most of the fork: Fly and Long notables, both Steady rows, Many Threads | Loses at t = 4, enemy on 5 % |
| `five-trunk-mixed` | All four trunk rows and Fly acupoints | Loses at t = 4, enemy on 1 % |
| `five-worst-mixed` | Both Sword rows, Long notable, both Steady rows | Loses at t = 4, enemy on 15 % |
| `five-closest-mixed` | Both Crit rows, both Fly rows, Steady notable | Loses at t = 4 on overkill, both at 0 % |
| `five-narrow-mixed` | Crit acupoints, both Long rows, Steady acupoints, Many Threads | **Wins** at t = 4 on overkill, both at 0 % |
| `five-gentlest-mixed` | Both Crit rows, Fly and Long acupoints, Many Threads | **Wins** at t = 2 on 52 %, volley 295 |

So the test does not hold for every five. Both of those wins keep the two Sword rows and the Steady notable, the three heaviest rows on the path.

**The edge is two rows wide in the worst case.** `pair-sword-mixed` (both Sword rows) and `pair-steady-mixed` (Sword acupoints and Steady notable) already lose at t = 4 on overkill. `pair-spread-mixed` (Fly and Long notables) still wins at t = 2 with volley 304. Each losing pair is 11 nodes, more than a third of the path.

**What the test does not cover.** It holds for the 30 nodes, not the kit the enemy also carries. `no-full-title-mixed` loses at t = 4 on overkill, and `two-swords-mixed` loses at t = 4 with the enemy on 25 %. `no-path-mixed`, the same person with no nodes at all, loses at t = 4 with the enemy on 30 %.

### The same 30 nodes spent another way

Same swords, same arts. This is where the multiplying shows.

| File | The 30 nodes | Volley | Against the mixed enemy | Against the heavy ward (`ws` 100) |
|---|---|---|---|---|
| `plain-attack-mixed` | 70 W of plain `attack_pct` | 274 | Wins at t = 2 on 52 % | `plain-attack-ward-mixed`: loses at t = 4, enemy on 14 % |
| `one-row-mixed` | All in Sword damage | 338 | Wins at t = 2 on 52 % | `one-row-ward-mixed`: loses at t = 4, enemy on 13 % |
| `mixed` | The stack above | 348 | Wins at t = 2 on 52 % | `ward-mixed`: loses at t = 4, enemy under 1 % |
| `damage-only-mixed` | The stack, Crit traded for Steady and Long | 399 | Wins at t = 2 on 52 % | `damage-only-ward-mixed`: wins at t = 4 on 10 % |

A row in an empty layer pays best. The plain crit rows pay least at this size, and a player who wants only the volley should walk `damage-only-mixed`. Crit stays here because a sword path with no crit is a poorer road to keep walking, not because it wins this fight.

## The Choice

| Enemy | Flown Line | Held Line, cost 0.06 | Held Line, cost 0.08 |
|---|---|---|---|
| Mixed | `mixed`: wins at t = 2 on 52 %, pool 42 % | `held-mixed`: wins at 2.75 s on 61 %, pool 19 % | `held-dear-mixed`: wins at t = 2 on 61 %, pool 25 % |
| Wall: 2.5 × health | `wall-mixed`: **wins** at t = 4 on 32 % | `held-wall-mixed`: loses at 7 s, enemy on 12 % | `held-dear-wall-mixed`: loses at 6 s, enemy on 19 % |
| Heavy ward: `ws` 100 | `ward-mixed`: loses at t = 4, enemy under 1 % | `held-ward-mixed`: **wins** at t = 4 on 23 % | `held-dear-ward-mixed`: **wins** at 2.75 s on 61 % |
| Evader: 25 % | `evader-mixed`: loses at t = 4, enemy on 2 % | `held-evader-mixed`: loses at t = 3, enemy on 1 % | `held-dear-evader-mixed`: **wins** at 2.75 s on 61 % |
| Flown against Held | | `duel-held`: Flown **wins** at t = 2 on overkill, both at 0 % | `duel-held-dear`: Held **wins** at 1.83 s, still on 94 % |

The Flown Line strips the pool in one blow, so an enemy with a great deal of health is left with only a basic attack (`wall-mixed`: their linh lực is 0 at t = 2). The Held Line keeps its ward kit, so it lives long enough to wear down a thick ward, and it has nothing left for a wall. Paying more for the Held arts makes it the better duellist, and the wall still beats it. The lines also want opposite pools: Steady Thread above 50 %, Spent Breath below it. Walking both fails quietly. `straddle-mixed` trades Long Flight and Many Threads for speed: the volley comes at 1.79 s but deals 292 and falls short, and the win waits for the basic attack at t = 2.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal, purity 50 | Sets the sector scale. Purity is not a fight input, but the row sizes assume it: 0.5 + purity / 100 (Meridian Map rule 4) |
| Key talents | Thần hồn 60 | Thần thức 180 at Foundation and 600 at Core, exactly three swords at each. This is the only source of sense in the build. Fortune is not read |
| The rest of the tree | The typical life's ward, linh lực and health | Pools and ward points copy the typical enemy, so the stack is the only difference. `n_body` 1.277, `n_qi` 1.19 |
| The Way (Đạo) | Sword, any | None of the engine lives here |

## Công Pháp

### Daily Lesson Canon (Nhật Khóa Kiếm Điển) — main, Huyền giai

Forty pages of the same morning, and a note that the knee will ache.

```json
{"id": "nhat_khoa_kiem_dien", "name": "Nhật Khóa Kiếm Điển", "tier": 1, "tech_kind": "main",
 "names": ["kim"], "layers": 9,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "than_thich", "unlock_layer": 2},
               {"ability_id": "thuong_lieu", "unlock_layer": 4},
               {"ability_id": "ha_phach", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

Full Title is its passive, the same new key The Loud Sword uses. **Fit:** Needs key · **Budget:** 10/15 = 0.67 of 2.0, under the 1.5 single cap. Its L2 of 40 equals the typical anchor.

## Arts

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Let Fly (Phóng Kiếm), one per sword | `phi_kiem` active effect | body, sword, hit, artifact | 2.33 | 0.09 | 2 s | none | Needs key |
| Morning Thrust (Thần Thích) | Canon, 2 | body, sword, hit | 1.72 | 0.06 | 1 s | none | Needs key |
| Rising Cut (Thượng Liêu) | Canon, 4 | body, sword, hit | 1.72 | 0.06 | 1 s | none | Needs key |
| Falling Cut (Hạ Phách) | Canon, 6 | body, sword, hit | 1.72 | 0.06 | 1 s | none | Needs key |

**Effect:** a hit each, all at the lint's ceiling. The three cuts belong to the Held Line. **Description:** the lesson, done on a morning that counts.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Morning Thrust, Rising Cut | Common ward | The trunk only. The fork is not yet reached |
| Foundation Establishment | 4 | Let Fly ×3 | Common ward, no ward gear | One slot stays empty |
| Core Formation | 5 | Let Fly ×3 | Common ward, no ward gear | Same three swords, at the Core tier |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Three plain flying swords | Artifact, weapon | `phi_kiem`, Hạ phẩm, tier 1 | Attack 390 each, so L3 117, for 60 thần thức each. Mortal smiths could nearly make them. Each has a Let Fly active | Needs key |
| Whetstone Water | Coating | Reused | +40 in L4, foreseen fights only. Volley 486 | Needs key |

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | Two cuts and a habit | The trunk | Up before light, in the yard |
| Foundation Establishment | Two seconds, then everything | The fork, the third sword | The hand opens, and it is frightening |
| Core Formation | The same, at 54 nodes | Rows ×1.8, a quarter of 216 points | It is still frightening |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm (`daily-lesson-mixed`) | Wins at t = 2 on 52 % | One volley ends it |
| One cheap art (`daily-lesson-one-art`) | Wins at t = 2 on 52 %, the same numbers | The enemy's other arts never fired |
| Foreseen, no home ground (`daily-lesson-foreseen-mixed`) | Wins at t = 2 on 52 %, volley 486 | Whetstone Water in place of the plain +20 |
| Blind (`daily-lesson-blind-mixed`) | Wins at t = 3 on 9 %, pool 0 % | L4 gone. The volley falls short and the basic attack finishes it |
| Mixed, one up (`daily-lesson-mixed`, `--gap 1`) | Loses at t = 2, enemy on 70 % | An ordinary path does not fight upward |
| Second realm, Core (`daily-lesson-core-mixed`) | Wins at t = 2 on 56 % | The same rows at ×1.8. `core-no-sword-n-mixed` wins the same. `core-five-worst-mixed` loses at t = 4, enemy on 29 % |
| Held Line at cost 0.08 (`daily-lesson-duel-held-dear`) | Loses at 1.83 s, the Held fighter on 94 % | Two rounds land before the swords leave |

**Counter:** any fast sword with a good ward, or a same-realm evader or heavy ward (rule 18). The first kills the cultivator in the two seconds they stand open. The others survive the first volley and the Flown Line has no second answer.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Canon 0.67 of 2.0. Art lint within on all arts. Slots 3 of 4. Three swords, 180 of 180 thần thức, 3 of 6 pieces |
| Validity | PASS | `phi_kiem` tier 1 grade 1 is attack 390 and cost 60, from `items_artifacts.json`. Huyền giai reaches Core, the span claimed |
| Stack | PASS | Four forms in the walk. Every empty rung named. Layers stated |
| Plain Stack test | PASS | 11 of 11 rows barely move the fight. Six of eight saved fives lose, and the two that win are shown. It does not hold for the kit, which is stated |
| Scaling | PASS | M 7.56 against typical 4.19, top-end 148. Ordinary, and it should be |
| The fight | PASS | No cap hit. Every art fires. Steady Thread is on for the volley, proved by `no-steady-n-mixed` |
| Reuse | PASS | Full Title, proved in the main fight by `no-full-title-mixed`. Whetstone Water. Every row has a second home in `pieces/daily-lesson.json` |
| NPC use | PASS | Every row is a plain number on a tag, and a good default for a generated pupil |
| Counterplay | PASS | Fast swords, evaders, heavy wards, all saved above |
| Originality | PASS | No borrowed names. Ngự Kiếm and Trì Kiếm are plain words |

## Fight Results

Input: `sheets/daily-lesson.fight.json`. Observations from `fight_x.py`, a paper model with expected values for chance, not the game. No plug-ins.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 40 % | 2 s | never | none |
| typical | 1 | Loss, enemy on 70 % | 2 s | 2 s | none |
| typical | 2 | Loss, enemy on 100 % | 1 s | 1 s | none |
| top_end | 0 | Loss, enemy on 99 % | 1 s | 1 s | none |
| top_end | 1 | Loss, enemy on 100 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 100 % | 1 s | 1 s | none |

**Unmodelled:** the basic attack has no sword tag, so its `c` is lowered to 0.96 to take out the sword-only crit chance the calculator would otherwise give it. Thần thức is costed here, not in the fight. Weapon efficiency and First firing comes sooner are in no fight file.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| A tag key for modifiers | Needs key | One key shape naming a tag, as the catalogue already asks. Covers every ○ row with a tag |
| Cooldown tags | Needs key | Long Flight and Short Edge read the authored cooldown, so arts need a `heavy` or `quick` tag set at authoring |
| A count at compile | Needs key | Many Threads and Many Forms read equipped swords and slotted arts |
| Own-pool condition on a modifier | Needs key | Steady Thread and Spent Breath use rule 13's guard vocabulary on a modifier |
| Let Fly | Needs key | An active effect on the `phi_kiem` base. Rule 13 already allows an artifact's active effect |

## Questions For The User

1. Should fast arts stay this cheap? First firing equals cooldown, so three 1 s arts at cost 0.08 kill the Flown Line at 1.83 s, and their only price is the wall.
2. Is three Hạ phẩm swords in place of a ward kit meant to be this good? The same 180 thần thức takes L3 from 40 to 117.
3. On the Beat would suit the Flown Line, whose cooldowns land on pulses, but its row is Needs rule, so it is left out. Does firing on a pulse need a new guard word?

## Also Considered

- **Fast against heavy alone:** one set of arts with two cooldown lines and no gear choice. Dropped, because the pool and the kit make a harder choice.
- **The Hilt School:** the basic attack as a sword, stacking Basic attack damage and speed. Dropped, because no art means no fork.
