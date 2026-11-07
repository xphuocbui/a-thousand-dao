# The Seven Lamps (Thất Đăng)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Sustain: art cost, regeneration, ward efficiency and art speed as a tempo path any art build can dip into. Test rule 11's tension head on, in a long fight the build plans to out-last.
> **Direction**: The road forks into Slow Breath and Quick Breath. This sheet walks Slow Breath at Deity Transformation, because Qi Refining cannot buy a long fight (shown under Rule 11).
> **Realm span**: Core Formation – Deity Transformation, defined at Deity Transformation · **Power level**: strong · **Use**: player path, or the old keeper of any road
> **Fit**: 14 Fits today · 33 Needs key · 0 Needs rule
> **Checks**: 11 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward model)

## The Spine

- **The channel:** art hits of the qi kind, on all five layers, at an M under typical. Volume does the work: all seven slots, every 4 s.
- **The enabler:** none. The Stone Ward is a plain ward from The Long Firing, and the build stands on it, as shown below.
- **The loop:** each second the ward costs 4.7 % of the pool and the lamps 6.6 %, and 8 % comes back. Hits on the ward cost nothing. The pool needs to last only until the enemy's does not.
- **The engine:** three share rows meet on one line, income against upkeep and art cost, so pool size stops mattering. Then ward strength, body guard and health stretch the fight, and the late rows pay for every second they bought.
- **The sacrifice:** the first 8 s. A fast killer reaches you before the third volley.
- **The arc:** at Core it barely holds. At Deity everything on the road is long enough, and the plan works.

## The Legend

The road over Cold Pass has seven bends, and nobody should walk it at night, but people do: the sick going down to the doctor, someone sent for the midwife. When Tô Vân was young, a person they loved lost the road on the fifth bend and was found in the morning, a short way from help. It was nobody's fault. The next evening Tô Vân carried a jar of oil up the pass and lit a lamp at the first bend. In time there were seven.

It took them six centuries to reach Deity Transformation, because they would never go into seclusion for longer than a jar of oil lasts. They have no great art. When someone comes up the road meaning harm, they are frightened, and they do what they do every evening: they light the lamps in order, trim them, and wait. They believe that morning comes. So far it always has.

## How It Fights

Almost nothing happens for 11 s, and that is the plan. Against a boss with five times the pools, you stand on 49 % and they stand on 83 %. But they have spent themselves, and their pool is on 4 %.

**The signature moment:** t = 12. The same seven lamps as before land on a body with no ward. They fall from 83 % to 36 % in one instant, and you have changed nothing. At 16 s it is over, on 36 % (`variants/seven-lamps-boss.fight.json`, `--timeline`).

## The Stack

A walk of 198 nodes, 159 acupoints and 39 notables, 503 W. Cluster rows scale with purity (Meridian Map rule 4), so these sizes assume purity 50 on ground the root holds. Only road rows are exact, and a cluster in a sector the root lacks pays ×0.25, so the wheel's Water and Wood placement would need a Water or Wood root. That is the whole 293 W attack quarter of a Deity's tree plus 210 W of the half a typical life spends outside fights. Fifteen rows, and M stays under typical.

`Without` is the whole row removed from `variants/seven-lamps-boss.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health, own linh lực, enemy health at t = 11. **The full fight is 16 s, 36 %, 30 %, 83 %.**

### The Tempo road: both lines walk it

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 1 | Linh lực regeneration (Hồi Khí) | 2 + 4 | +0.15 / +1 | +4.3 % | Increased | none | ● | `no-regen`: 16 s, 36 %, 12 %, 85 % |
| 2 | Art cost (Tiết Khí) | 12 + 0 | −0.5 / −3 | −6 % | Increased | none | ● | `art_cost_pct`: 16 s, 36 %, 23 %, 83 % |
| 3 | Ward efficiency (Hộ Hiệu) | 4 + 3 | +1.2 / +8 | +28.8 | Increased | none | ● | `no-eff`: 16 s, 36 %, 20 %, 83 % |
| 4 | Ward strength (Hộ Lực) | 24 + 7 | +1.2 / +8 | +84.8 | Increased | none | ● | `no-ws`: 16 s, 18 %, 30 %, 83 % |
| 5 | Ward strength against body hits (Hộ Thể) | 50 + 6 | +1.5 / +10 | +135 | Conditional | none | ○ catalogue | `no-wsb`: 16 s, 8 %, 30 %, 83 % |
| 6 | Maximum health (Khí Huyết) | 24 + 3 | +1 / +6.5 | +43.5 % | Increased | none | ● | `no-hp`: 16 s, 1 %, 30 %, 83 % |
| 7 | Body guard (Hộ Thân) | 20 + 4 | +1.2 / +8 | +56 | Increased | none | ● | `guard`: 16 s, 30 %, 30 %, 83 % |
| 8 | Art damage (Pháp Thương) | 4 + 3 | +1.5 / +10 | +36 | Increased | L1 | ○ catalogue | 20 s, 24 %, 17 %, 87 % |
| 9 | Damage to an enemy with no linh lực (Tận Khí) | 4 + 1 | +2.5 / +15 | +25 | Conditional | L1 | ○ catalogue | `No linh luc`: 20 s, 28 %, 17 %, 84 % |
| 10 | Wasting (Hao Tổn): hits, per 1 % of the enemy's linh lực missing | 0 + 1 | notable +0.2 | up to +20 | Per | L2 | ○ reused | 20 s, 28 %, 17 %, 85 % |

### Slow Breath (Hoãn Tức): walked here

Long arts, income, and rows that pay late.

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 11 | **Spared Breath (Dư Tức)**: regeneration, per 10 ward efficiency you own | 8 + 2 | +0.02 / +0.12 | +4.5 % at 113 | Per | none | ○ new | `no-keel`: 16 s, 36 %, 9 %, 85 % |
| 12 | **Deep Breath (Thâm Tức)**: arts, per 1 % regeneration you own | 0 + 1 | +0.3 / +2 | +16 at 8 % | Per | L2 | ○ new | 16 s, 34 %, 30 %, 85 % |
| 13 | **Patient Art (Nại Pháp)**: arts with an authored cooldown of 3 s or more | 2 + 1 | +1.5 / +10 | +13 | More | L2 | ○ new | 19 s, 29 %, 40 %, 85 % |
| 14 | **Late Hour (Vãn Thời)**: arts after the tenth second | 2 + 2 | +2 / +12 | +28 | Conditional | L5 | ○ new | 20 s, 28 %, 17 %, 83 % |
| 15 | **Steady Breath (Bình Tức)**: arts while your linh lực is at 50 % or above | 3 + 1 | +1.5 / +10 | +14.5 | Conditional | L5 | ○ new | 16 s, 34 %, 30 %, 85 % |

**All 15 rows removed one at a time still win.** Ten leave the time at 16 s and five add one volley. At the legal upkeep the two income rows no longer cost any time. The fight's length is steady, its margin is not: rows 4, 5 and 6 spend it, health most of all, down to 1 %. Rows 1 and 11 hold each other up: together they reach 8.8 % against a 6 % bonus cap, and the 2.8 % clipped is why either can leave.

### Quick Breath (Cấp Tức): the rival

Four short arts in place of seven long ones. Rows 11 to 15 are given up, and their W buys these. Saved whole as `quick-*`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 16 | Art speed (Tấn Pháp) | 8 + 4 | +0.5 / +3 | +16 | Increased | none | ◐ catalogue |
| 17 | **Short Art (Đoản Pháp)**: arts with an authored cooldown under 2 s | 6 + 1 | +1.5 / +10 | +19 | More | L2 | ○ new |
| 18 | **Quickened (Tấn Thế)**: arts, per 1 % art speed you own | 0 + 1 | +0.1 / +0.6 | +9.6 at 16 % | Per | L2 | ○ new |
| 19 | **Running Low (Cạn Khí)**: arts while your linh lực is at 50 % or below | 2 + 1 | +1.5 / +10 | +13 | Conditional | L5 | ○ new |

### Beside the road

All not run. Any build may take them.

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 20 | Linh lực regained on a crit (Hồi Bạo) | +0.1 / +0.6 | Trigger | ○ catalogue | Quick Breath, with crit |
| 21 | Ward strength against qi hits (Hộ Khí) | +1.5 / +10 | Conditional | ○ catalogue | Either line, hunted by qi arts |
| 22 | First firing comes sooner (Tiên Phát) | −2 / −12 | Timing | ○ catalogue | Quick Breath |
| 23 | Status resistance (Kháng Tà) | +1 / +6 | Increased | ● | Either line. A curse lasts longer in a long fight |

That is 22 modifiers plus Wasting, 44 rows in `pieces/seven-lamps.json`, with 0 rule asks.

**Identity piece:** none, on purpose. The nearest thing is the Stone Ward: `--without ward` on `sheets/seven-lamps.fight.json` turns a win at 4 s into a loss with the enemy on 5 %.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | 36, then 61 | ×1.36 to ×1.61 | Rows 8 and 9 |
| L2 | 69, up to 89 | ×1.69 to ×1.89 | The method 40, rows 12, 13, 10 |
| L3 | 40 | ×1.40 | The typical weapon |
| L4 | 20 | ×1.20 | A pill. 0 in a blind fight |
| L5 | 14.5, then 28 | ×1.15 to ×1.28 | Rows 15 and 14 |
| M | | ×4.4 to ×6.5 | Typical at Deity is ×8.96 |

## Remove Five

Same fight, whole rows, each file `variants/seven-lamps-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-income` | Regeneration, Spared Breath, cost, efficiency, Deep Breath | **Lost** at 15 s, enemy on 81 % |
| `five-guard` | Ward strength, against body, health, body guard, Steady Breath | **Lost** at 6 s, enemy on 93 % |
| `five-damage` | Art damage, no linh lực, Late Hour, Patient Art, Wasting | **Lost** at 31 s, enemy on 10 % |
| `five-mixed` | Regeneration, ward strength, health, Art damage, Late Hour | **Lost** at 9 s, enemy on 89 % |
| `five-gentle` | Cost, body guard, Wasting, Deep Breath, Steady Breath | **Still wins** at 20 s on 16 % |

The test does not hold for every five. `five-gentle` removes rows that are each a second line of support, and it costs one volley.

## Rule 11, Head On

*"A long fight favours the build that brought sustain, and a burst build must win before its own spending drops its guard."*

The burst twin spends the same 503 W as `attack_pct`, on the common ward, with four arts at the lint's ceiling at 25 % and 1 s (`burst-*`). The other columns are this sheet's two lines. All are the mixed enemy with deeper pools.

| Enemy | Slow Breath | Quick Breath | Burst twin |
|---|---|---|---|
| ×1 | `mixed`: wins at 8 s on 74 % | `quick-mixed`: wins at 5.2 s on 81 % | `burst-mixed`: wins at 1 s on 52 %, pool 0 % |
| ×2 | `x2`: wins at 8 s on 62 % | `quick-x2`: wins at 7.8 s on 74 %, pool 15 % | `burst-x2`: **loses** at 3 s, enemy on 36 % |
| ×5 | `boss`: wins at 16 s on 36 % | `quick-boss`: **loses** at 38 s, enemy on 34 % | `burst-boss`: **loses** at 3 s, enemy on 75 % |

The first half of the rule holds: the deeper the enemy, the more sustain matters. The second half depends on W. Here is the direct duel, on the same share of the tree at each realm.

| Realm | Path W | Duel with the burst twin |
|---|---|---|
| Qi Refining | 48 | `qi-refining-duel`: burst wins at 5 s on 24 % |
| Core Formation | 188 | `core-duel`: lamps win at 4 s on 6 % |
| Deity | 503 | `duel-burst`: lamps win at 4 s on 64 % |

So rule 11 has a floor, somewhere below Core. At Qi Refining 48 W buys no long fight: three lamps lose to the mixed enemy at 7 s with it on 44 % (`qi-refining`). By Deity the burst twin does not get to race at all, because attack past 200 points is halved and ward strength is not. This gives Open Question 14 a first answer, and that answer is stronger than the rule asks for.

Three other limits showed up.

- **The ward model is the whole difference.** Same rows on the common drain ward: dead at 6 s, enemy on 93 % (`common-ward`). A drain ward pays per blow, and ward strength makes it pay more.
- **An unpriced number decides it.** At upkeep 0.20, twice Combat's legal top of 0.10 and so a stress test and not a ward, it loses at 18 s with the enemy on 11 % (`upkeep-20`).
- **Nothing heals.** Linh lực can be balanced and health cannot, so "long" ends at 16 to 24 s for a winner. The longest fight here is a loss.

## The Same 503 W As Plain Attack

Same seven lamps, same Stone Ward, 503 W of `attack_pct` and no rows: `plain-boss` **loses** at 6 s with the enemy on 79 %.

## The Choice

| Enemy | Slow Breath, seven arts at 4 s | Quick Breath, four arts at 1.5 s |
|---|---|---|
| Mixed | Wins at 8 s on 74 % | Wins at 5.2 s on 81 % |
| ×5 boss | Wins at 16 s on 36 % | **Loses** at 38 s, enemy on 34 % |
| Killer: L2 230, L3 100, L4 40, L5 20 | `killer`: **loses** at 7 s, enemy on 7 % | `quick-killer`: **wins** at 5.2 s on 20 % |
| Each other | `duel-quick`: Slow wins at 24 s on 44 % | |

Quick finishes ordinary fights sooner and is the only answer to a hard hitter. Slow is the only one that ends a deep fight. You cannot have both: Patient Art needs 3 s or more, Short Art under 2 s, and seven slots of Quick cost more each second than any income allows.

**Counter:** a killer (above), or a top-end, which ends it at t = 1.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire, purity 50 | Sets the cluster scale. Purity is not a fight input, but the row sizes assume it |
| Key talents | None | Sense and fortune are not read, and enemy sense stays at the default |
| The rest of the tree | The typical life's pools and base ward | Copied from the fixture |
| The Way (Đạo) | None | Everything is on the Map |

## Công Pháp

### Low Flame Method (Vi Hỏa Quyết) — main, Thiên giai

```json
{"id": "vi_hoa_quyet", "name": "Vi Hỏa Quyết", "tier": 3, "tech_kind": "main", "names": ["hoa"], "layers": 15,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "so_dang", "unlock_layer": 2}, {"ability_id": "nhi_dang", "unlock_layer": 4},
               {"ability_id": "tam_dang", "unlock_layer": 6}, {"ability_id": "tu_dang", "unlock_layer": 8},
               {"ability_id": "ngu_dang", "unlock_layer": 10}, {"ability_id": "luc_dang", "unlock_layer": 12},
               {"ability_id": "that_dang", "unlock_layer": 14}],
 "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on Fire arts, the typical anchor. **Budget:** 15/15 + 15/15 = 2.0 of 4.0.

| Art | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| First Lamp to Seventh Lamp (Sơ Đăng to Thất Đăng) | qi, Fire, hit | 2.23 | 0.04 | 4 s | Needs key |
| Quick Lamp (Khoái Đăng), Quick Breath only, four | qi, Fire, hit | 1.605 | 0.04 | 1.5 s | Needs key |

**Effect:** a hit, at the lint's ceiling. **Description:** trim it, light it, go on to the next.

**Items:** the typical weapon (L3 40), an attack pill (L4 20), and the **Stone Ward (Thạch Hộ)** from The Long Firing, per-pulse, upkeep 0.10, the top of Combat's range (Formulas D), pass 0.54 and 0.36. All seven slots are used.

## Progression

| Realm | Plays like | Result | Story beat |
|---|---|---|---|
| Core, 188 W | Five lamps, barely holding | Beats the burst twin on 6 % | The first winter they did not lose a traveller |
| Deity, 503 W | The long fight is real | Wins at 16 s on 36 % | They still carry the oil up themselves |

## Matchups

| Enemy | Result |
|---|---|
| Mixed, same realm (`mixed`) | Wins at 8 s on 74 %. A foreseen fight with no home ground |
| One cheap art, ×5 (`one-art`) | Wins at 20 s on 37 %. It keeps its ward longer, so the fight takes a fifth volley |
| Top-end (`sheets/seven-lamps.fight.json`) | Loses at 1 s, enemy on 100 % |

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Method 2.0 of 4.0, every art at the lint's ceiling, slots 7 of 7. Nothing prices a ward model, and this build stands on one |
| Validity | PASS | `hoa_than`, Thiên giai reaches it. Cost 0.04 is Formulas E's floor. Bonus regeneration clips at 6 % |
| Stack | PASS | Four forms in the walk, Per included, all layers stated |
| Plain Stack test | PASS | 15 of 15 single rows still win. 4 of 5 saved fives lose, and the one that wins is shown. Health leaves 1 %, which is not "barely moves", and the sheet says so |
| Against plain attack | PASS | Wins a fight plain attack loses at the same W |
| Rule 11 | PASS | Tested at three depths and three realms. The result is a question for the user |
| Scaling | PASS | M 4.4 to 6.5 against 8.96 |
| The fight | PASS | No plug-ins, no cap hit. Every lamp fires on time in the defining fight |
| Reuse | PASS | Stone Ward and Wasting, both proved in the main fight |
| NPC use | PASS | Plain numbers, each one Breakdown line |
| Counterplay | PASS | Killer, top-end |
| Originality | PASS | Plain words |

## Fight Results

Input: `sheets/seven-lamps.fight.json`. Observations from `fight_x.py`, a paper model with expected values. No plug-ins.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0, 1 | Win | 4 s | 81 % | none |
| Typical | 2 | Win | 8 s | 74 % | none. No realm exists above Deity, so gaps here are the same enemy with suppression |
| Top-end | 0 to 2 | Loss, enemy on 100 % | 1 s | 0 | none |

**Unmodelled:** element on a hit. Ward strength against body hits is written by lowering `pass.body`. Spared Breath and Deep Breath are written as compile-time numbers. Rows 20 to 23 are not run.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Authored cooldown, own pool, elapsed time as conditions | Needs key | Rows 13 to 15, 17, 19. Same shapes as Settled Weight and Steady Thread |
| Regeneration and art speed read at compile | Needs key | Rows 11, 12, 18 |
| Art damage, kind-scoped ward strength | Needs key | The catalogue's key shape |
| The method and its arts | Needs key | Content |

## Questions

1. Should ward strength have a soft start, as L1 does? At equal W the lamps beat the burst twin in a duel at Core and Deity. Open Question 14 asked for sustain to win long fights, and here it wins short ones too.
2. What should a per-pulse ward cost? Upkeep 0.10, the legal top, wins, a stress test at 0.20 loses, and the drain ward is not close.
3. Nothing heals in a fight, so health is the only clock on an out-laster. Is that the intended end of rule 11?

## Also Considered

- **The Qi Refining vigil:** the same road at the first realm. Dropped, because 48 W cannot buy a long fight; kept as the floor of rule 11.
- **The deep pool on a drain ward:** bigger pool, more income. Dropped, because a drain ward spends faster than any income at this realm.
