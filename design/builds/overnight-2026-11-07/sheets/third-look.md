# The Third Look (Tam Thị)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Soul: 14 or more ordinary rows, two rival lines, one build of 10 or more, `realm_sense` for results, and a stated source for the enemy's thần thức.
> **Direction**: Soul has no layers, so the question was what stacking even means here. The answer: a share is a product of three things and a cap, so a soul path stacks *reach*, how much guarding it can look through, not damage. The road forks at what to do once they are looked at: stay in the tower, or walk down.
> **Realm span**: Core Formation – Nascent Soul, defined at Nascent Soul · **Power level**: ordinary, against an enemy who spent nothing on soul · **Use**: player path, or a sect's quiet watch-elder
> **Fit**: 18 Fits today · 23 Needs key · 0 Needs rule
> **Checks**: 10 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: soul arts have no lint)

## The Spine

- **The channel:** one soul art, Combat rule 24 and Formulas E2. No ward, guard or evade meets it. Layers do nothing for it.
- **The enabler:** none. One plug-in, `soul_x`, because the calculator has no Conditional or Per on `x_soul`.
- **The loop:** look, once a second, until the pool cannot pay. That is three looks.
- **The engine:** `share = size × (1 + x_soul) × rho²`, stopped at 30 %. Three small buckets multiply, and each look also takes 30 % of their linh lực, so their arts stop and their ward goes.
- **The sacrifice:** the look is all there is, and it is one ratio. An enemy who moves a tenth of their tree into thần thức takes the fight away.
- **The arc:** at Core it barely gets there, 5 s on 12 %. By Nascent Soul the third look lands with the enemy on 2 %.

## The Legend

The Ridge Tower stands over three dry valleys, and someone has to sit in it through the burning months. Khánh Lan took the post young, because nobody else wanted it. The work is looking. You look at a smoke once to see it, a second time to be sure, and a third time to know how far it has gone and who lives near it. Then you take a wet sack and walk down, because nobody else is coming.

Forty summers of that made a soul no teacher had trained. They do not call it an art. When someone comes up the road to harm the valley, they look at that person as they would look at smoke, carefully and without hatred, three times. Then they walk down the steps. They are frightened every year that this is the year they looked away.

## How It Fights

At t = 1 they lose 32 % of their health and 37 % of their linh lực. At t = 2 the same. At t = 3 you have paid for your last look, your pool is empty, you stand on 40 %, and they stand on 2 % with nothing left. You walk over and hit them.

**The signature moment:** the last 2 % is a fist. The look cannot be paid a fourth time, and without the bare hand the fight is lost with the enemy on 10 % (`variants/third-look-no-hand.fight.json`). The build is named for that.

## Where The Enemy's Thần Thức Comes From

Earlier sheets used 57 and 85, derived from nothing. Character Stats Formulas C and the Meridian Map give a real figure. Every life walks roads, a typical life spends 45 % of its points there (Formulas, `h_r`), one road node in four is `than_thuc_pct` (`road_stats`), and each is +0.9 %. Nobody has to choose to have a soul.

| Who | Talent (thần hồn) | Roads | Rows | Sense before `M_ts` |
|---|---|---|---|---|
| Typical, Nascent Soul | 45, `roll.mean` | 357 × 0.45 ÷ 4 × 0.9 = +36.1 % | 0 | **61.3** |
| Top-end, Nascent Soul | 61, the floor of Upper, an assumption | +36.1 % | 0 | **83.0** |
| Typical, Core and Deity | 45 | +21.9 %, +57.3 % | 0 | 54.8, 70.8 |
| You | 60, the top of Middle | +36.1 % | +16.8 % | **91.8** |

So rho is 1.50 at equal realm, from a talent the mean life lacks. `talent-50` loses at 7 s on overkill and `talent-45` at 5 s with the enemy on 23 %. Stage is 1.00 throughout. One realm up, `realm_sense` multiplies by `M_ts` and keeps the base of 61.3, which flatters the build a little: `mixed --gap 1` loses at 2 s with the enemy on 93 %.

## The Stack

70 nodes, 56 acupoints and 14 notables, 179.2 W, under the quarter of Nascent Soul's tree a typical life spends on attack. Sector rows assume purity 50.

`Without` is the whole row removed from `variants/third-look-mixed.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health. **The full fight is 4 s on 30 %.** `At the edge` is the same removal from `hold-sense`, the fight the build only just wins, 10 s on 0 %. It reads how the fight ends.

### The Inner Road: both lines walk it

| # | Node | Take | Each | Total | Form | Bucket | Status | Without | At the edge |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Thần thức (Thần Thức) | 12 + 1 | +0.9 / +6 | +16.8 % | Increased | rho, squared | ● | `no-sense`: 4 s, 30 % | `hold-no-sense`: Lost at 7 s, enemy on 22 % |
| 2 | Soul attack damage (Hồn Thương), road and line together | 10 + 3 | +1.5 / +10 | +45 | Increased | x_soul | ○ catalogue | 4 s, 30 % | Lost at 6 s, enemy on 29 % |
| 3 | Soul art cost (Tiết Thần) | 4 + 1 | −1 / −6 | −10 % | Increased | fuel | ○ tag row | `art_cost_pct`: 4 s, 22 % | Lost at 9 s, enemy on 1 % |
| 4 | Regeneration (Hồi Khí) | 4 + 1 | +0.15 / +1 | +1.6 % | Increased | fuel | ● | `regen_bonus_pct`: 4 s, 20 % | Lost at 8 s, enemy on 3 % |
| 5 | Maximum health (Khí Huyết) | 6 + 1 | +1 / +6.5 | +12.5 % | Increased | time | ● | `no-health`: 4 s, 25 % | not saved |
| 6 | Ward efficiency (Hộ Hiệu), road and line together | 6 + 2 | +1.2 / +8 | +23.2 | Increased | time | ● | `no-ward-efficiency`: 4 s, 11 % | not saved |

### The Tower Line (Vọng Lâu Mạch): walked here

Stay where you can see. Nothing here touches a hit.

| # | Node | Take | Each | Total | Form | Bucket | Status | Without | At the edge |
|---|---|---|---|---|---|---|---|---|---|
| 7 | **Fine Point (Tiêm Điểm)**: `soul_pct` on soul arts. Outside `x_soul`, so a multiplier of its own | 4 + 2 | +2 / +12 | +32 % | More | size | ○ new | `no-point`: 5 s, 17 % | not saved |
| 8 | **Empty Room (Không Thất)**: `x_soul` per empty art slot | 3 + 1 | +0.5 / +3 | +22.5 at 5 empty | Per | x_soul | ○ new | 4 s, 30 % | Lost at 10 s, enemy on 12 % |
| 9 | **Clear Head (Thanh Tỉnh)**: `x_soul` while your linh lực is at 30 % or above | 3 + 1 | +2.5 / +15 | +22.5 | Conditional | x_soul | ○ new | 4 s, 30 % | Lost at 10 s, enemy on 7 % |
| 10 | **Failing Lamp (Tàn Đăng)**: `x_soul` per 1 % of the enemy's linh lực missing | 4 + 1 | +0.02 / +0.12 | up to +20 | Per | x_soul | ○ new | 4 s, 30 % | Lost at 10 s, enemy on 3 % |

**All 10 rows removed one at a time still win.** The widest moves are Ward efficiency, 19 points of health, and Fine Point, one second and 13. Empty Room exists because `soul_lockout` makes a second soul art almost worthless, so a soul path leaves slots open anyway. The Per reads what the rule already gave you.

**Against an unguarded enemy half these rows show no move at all, and that is the point.** The first look's raw share is 0.0924 × 1.90 × 2.24 = 0.39, and the cap is 0.30. Rows 1, 2, 8, 9 and 10 sit past the cap. They are not dead: read the last column. In the fight at the edge, each one alone is the whole result.

### The Walk-Down Line (Hạ Sơn Mạch): the rival

Look, then go and use your hands. The road's Soul damage stops at 4 + 1 (+16) and Ward efficiency at 6 + 1. 184.4 W, with Stamping Foot, Beating Branch and +40 L2 on hits, saved whole as `down-mixed`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 11 | Damage (Công Lực), `attack_pct` | 18 + 4 | +1.2 / +8 | +53.6 | Increased | L1 | ● |
| 12 | Basic attack damage (Bình Kích) | 6 + 1 | +2 / +12 | +24 | Increased | L1 | ○ catalogue |
| 13 | Damage to an enemy with no linh lực (Khô Hải) | 3 + 1 | +2.5 / +15 | +22.5 | Conditional | L1 | ○ catalogue |
| 14 | Wasting (Hao Tổn): hits, per 1 % of the enemy's linh lực missing | 4 + 1 | +0.03 / +0.2 | +0.32 a point | Per | L2 | ○ reused |

In `down-watchful`, without Wasting the win falls from 4 s on 26 % to 7 s on 6 %, and it is the rival's best row after Damage. Wasting came from a poisoner's line and is used here unplanned, but only on the rival, not in the main fight.

### Beside the road

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 15 | Soul resistance (Kháng Hồn) | +1 / +6 | Increased | ● | Anyone at all. 100 % halves rho, so it quarters a share. Not run |
| 16 | Realm pierce (Xuyên Cảnh) | +0.5 / +3 | Increased | ● | Tower, one realm up, since a share takes suppression. Not run |
| 17 | Artifact thần thức cost (Khinh Khí) | −0.8 / −5 | Increased | ● | Walk-Down, which carries more. Not run |
| 18 | Status resistance (Kháng Độc) | +1 / +6 | Increased | ● | Either. Not run |
| 19 | Shorter `soul_lockout` | −0.1 s | one-off | ○ catalogue | Tower's best notable, and the first thing to price. Not run |

That is 19 modifiers and 37 rows in `pieces/third-look.json`, in Increased, More, Conditional and Per, with 0 rule asks.

**Identity piece:** none, on purpose. **Empty rungs:** every layer is empty by rule. L3 40 and L4 20 are the typical's kit and serve only the fist, which turns out to matter.

### What a stackable soul path is

| Bucket | Worth here | Reads | Stops at |
|---|---|---|---|
| Size | 0.07 × 1.32 | Fine Point | the art record |
| `x_soul` | ×1.90, more as their pool falls | rows 2, 8, 9, 10 | nothing |
| rho² | ×2.24 | row 1, your talent, their sense | below 0.25, zero |
| Share | 0.39, clipped to 0.30 | | `soul_cap` |
| Rate | 1 look a second | | `soul_lockout` |
| Number of looks | 3, then the pool is gone | rows 3, 4 | |
| Time to take them | 3 s standing | rows 5, 6 | |

A soul fight is a staircase. Past 30 % a look is a look, three looks are 90 %, and rows above the cap buy nothing you can see. Below it, each step down costs a whole look you probably cannot pay for. So a row's worth is measured against the guard of whoever you fear, not against the fight in front of you. Stacking soul means stacking reach.

**The cliff, stated.** Enemy sense is moved up by a typical who takes the W out of attack at 1.33 W per 1 %.

| Enemy sense | Paid | Result | File |
|---|---|---|---|
| 61.3 | nothing | 4 s on 30 % | `mixed` |
| 86.4 | +55.8 %, 74 W, 10 % of its tree | Wins at 10 s, on 0 % | `hold-sense` |
| 87.0 | +57.2 %, 76 W | **Loses** at 11 s on overkill | `flip-sense` |
| 91.9, equal souls | +68.1 %, 91 W | **Loses** at 14 s, enemy on 6 % | `watchful` |

## Remove Five

Same fight, whole rows, each file `variants/third-look-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-look` | Sense, Soul damage, Fine Point, Clear Head, Empty Room | **Lost** at 5 s, enemy on 52 % |
| `five-keep` | Cost, Regeneration, Health, Ward efficiency, Empty Room | **Lost** at 4 s on overkill |
| `five-cross` | Sense, Soul damage, Cost, Ward efficiency, Clear Head | **Lost** at 4 s, enemy on 30 % |
| `five-gentle` | Empty Room, Failing Lamp, Health, Regeneration, Cost | **Still wins** at 4 s on 6 % |
| `no-path` | All 10 | Lost at 4 s, enemy on 56 % |

`five-gentle` keeps every row that holds the look at the cap and Ward efficiency, so not every five is lost.

**One stat instead:** the same 180 W as 150 acupoints of thần thức alone (`plain-sense`, +135 %) looks further than this build ever will and still **loses** at 4 s on overkill, because nothing paid for the three seconds.

## The Choice

| Enemy | Tower | Walk-Down |
|---|---|---|
| Mixed | `mixed`: 4 s on 30 % | `down-mixed`: 3 s on 4 % |
| The Wall: ward 150, double pool | `wall`: 4 s on 92 % | `down-wall`: 4 s on 91 % |
| A thể tu: `t_b` 3, `a_b` 2, guard +60 %, `n_body` 3.0 | `thick`: 4 s on 53 % | `down-thick`: 11 s on overkill |
| Evader, 30 % | `evader`: **loses** at 7 s on overkill | `down-evader`: 3 s on 4 % |
| Watchful, equal souls | `watchful`: **loses** at 14 s, enemy on 6 % | `down-watchful`: 4 s on 26 % |

Tower keeps more of itself and does not care how thick the enemy is. Walk-Down wins sooner and thinner, and soul defence hardly touches it. Tower's fall to an evader is a surprise: soul cannot be evaded, but the last few points are a fist, and that can.

**Against a soul striker** (`needle`, one 0.05 soul art in their kit): wins at 4 s on 47 %. Their rho is 0.67, so your thần thức takes a 5 % art down to 2.2 %. The same row attacks and defends.

**Against The Rice Pestle at Nascent Soul** (`duel-pestle`, Look listed first): both fall at 3 s and the Look loses on overkill. Listed second (`rice-pestle-ns-duel-look`) the Look wins with 26 % left. Whoever resolves second wins, in both directions.

**Counter:** thần thức, for a tenth of a tree, or an evader. The top end ends it at t = 1 with the enemy on 78 %.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any, purity 50 where a sector row is walked | Nothing reads purity |
| Key talents | Soul strength (thần hồn) 60 | It enters squared. 50 is not enough (`talent-50`) |
| Sense and fortune | Sense as derived above. Fortune not read | |
| The rest of the tree | The typical life's ward, pool and health | Copied from the fixture |
| The Way (Đạo) | None | |

## Công Pháp

### Watch Rule (Vọng Quy) — main, Địa giai

```json
{"id": "vong_quy", "name": "Vọng Quy", "tier": 2, "tech_kind": "main", "names": [], "layers": 12,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "the_look", "unlock_layer": 3}],
 "seal_clusters": [], "origin": "authored"}
```

**Budget:** 15/15 + 15/15 = 2.0 of 3.0.

| Art | Kind | Size | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| The Look (Ngưng Thị) | soul | `soul_pct` 0.07 | 0.126 | 1 s | Needs key |
| Stamping Foot (Đạp Hỏa), Walk-Down | body, hit | c_art 1.60 | 0.05 | 1 s | Needs key |
| Beating Branch (Phác Chi), Walk-Down | qi, hit | c_art 2.46 | 0.08 | 3 s | Needs key |

**Description:** once to see it, once to be sure, once to know who lives near it.

**Items:** the typical weapon (L3 40), the typical ward kit, an attack pill (L4 20). One of six slots used.

## Progression

| Realm | Plays like | Result | Story beat |
|---|---|---|---|
| Core, 44 nodes, 107.2 W | Three looks, then a long walk | `core-mixed`: wins at 5 s on 12 % | The first summer alone in the tower |
| Nascent Soul, 70 nodes | Three looks past the cap | Wins at 4 s on 30 % | The valley no longer asks who is up there |

## Matchups

| Enemy | Result |
|---|---|
| Mixed, same realm (`mixed`) | Wins at 4 s on 30 %. A foreseen fight with no home ground |
| One cheap art (`one-art`) | Wins at 4 s on 44 %, pool 12 %, and the look is paid a fourth time |
| One up (`mixed --gap 1`) | Loses at 2 s, enemy on 93 % |

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Soul arts have no lint. Cost 0.126 follows The Cut Line's 1.8 cost per `soul_pct`. Technique 2.0 of 3.0, slots 1 of 6 |
| Validity | PASS | `nguyen_anh`, Địa giai reaches it. `soul_pct` 0.07 is inside Formulas E2's 0.03 to 0.08 |
| Stack | PASS | Four forms on the walk, buckets stated |
| Plain Stack test | PASS | 10 of 10 single rows still win. 3 of 4 saved fives lose, and the one that wins is shown |
| Against one stat | PASS | The same W in thần thức alone loses |
| Scaling | PASS | Layers do not apply. Stated power holds only against an unguarded enemy, as the cliff table shows |
| The fight | PASS | Three looks on time, the fourth blocked by an empty pool, no cap note from the calculator |
| Reuse | PASS | Catalogue rows throughout. Wasting is used unplanned on the rival only, proved in `down-watchful` |
| NPC use | PASS | Plain numbers, each one Breakdown line |
| Counterplay | PASS | Thần thức, evade |
| Originality | PASS | Plain words. A fire tower is nobody's |

## Fight Results

Input: `sheets/third-look.fight.json`. Rules `realm_sense` and `soul_x`. Observations from `fight_x.py`, a paper model with expected values.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0 | Win | 4 s | 45 % | none noted. `soul_cap` is not reported by the calculator |
| Typical | 1, 2 | Loss, enemy on 93 %, 94 % | 2 s | 0 | |
| Top-end | 0 | Loss, enemy on 78 % | 1 s | 0 | |
| Top-end | 1, 2 | Loss, enemy on 98 % | 1 s | 0 | |

**Unmodelled:** rows 15 to 19 are not run. The one-up enemy keeps the Nascent Soul base.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| `x_soul` as a tree key, with conditions | Needs key | Rows 2, 8, 9, 10. `rules/soul_x.py` shows the shape: the calculator's own guards and scales, read at a soul art |
| A key on `soul_pct` | Needs key | Row 7 |
| Soul tag on art cost | Needs key | Row 3 |
| The Rule and its arts | Needs key | Content |

## Questions

1. Should reference enemies carry a soul profile? The road formula gives one for free, and it answers Open Question 16's first half: 54.8, 61.3, 70.8 for a typical life.
2. Is `soul_cap` meant to hide rows? A player who removes four rows and sees nothing change has no way to learn what they were for. A Breakdown line showing the raw share would fix that.
3. An enemy's whole soul defence costs about 10 % of its tree, and nothing tells a typical NPC to buy it. Should the generator?

## Also Considered

- **The Long Look:** a cheap art paid from income, with `x_soul` per second of the fight. Dropped as the rival: it dies at 5 s to 7 s, because the look that saves the pool does not stop their arts soon enough.
- **Keen against Deep,** `x_soul` against thần thức. Not a real fork: a product wants both.
