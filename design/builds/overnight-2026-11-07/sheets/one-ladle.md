# The One Ladle (Nhất Chước Quy)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Water: ordinary nodes, no enabler, 0 rule asks, two rival lines, remove one and little moves, remove five and it is lost.
> **Direction**: The linh lực pool is the damage stat. The road forks at the two borders of the Water sector: soft toward Wood, cold toward Metal. This sheet walks the soft line.
> **Realm span**: Foundation Establishment – Deity Transformation, defined at Deity Transformation · **Power level**: ordinary · **Use**: player path, or an NPC elder who has simply lasted
> **Fit**: 10 Fits today · 32 Needs key · 0 Needs rule
> **Checks**: 11 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hits of the qi kind, on all five layers. A qi hit makes their ward pay 1.5 times what a body hit does.
- **The enabler:** none.
- **The loop:** two arts at the lowest cost the game allows, every 1.5 s. They cost 4.7 % of the pool a second, and 5.2 % comes back. Only the ward spends more than comes in.
- **The engine:** every row that keeps the pool up is also a damage row, because Held Water and Unbroken Surface read the pool, and Spring Head reads the income. Their ward runs out first, and then the same small hits land almost whole.
- **The sacrifice:** speed and crit. A fast killer reaches you before the second pair of ladles matters.
- **The arc:** at Foundation it wins on overkill. By Deity the rows are long enough that income passes outgo, and it wins with half its health.

## The Legend

The drought in the Ash Hills outlasted everyone who remembered rain. One shrine still had a well, and its keeper, Cựu Minh, gave each person who climbed the steps one ladle a day: the sick, the magistrate, the children, the keeper. People wept at them and cursed them, and came back the next morning. Cựu Minh wept too, some nights, and took no more than anyone else. The well never failed, because nothing ever left it faster than it came in.

They are one of three Deities now, and they still keep that well. They have no theory of power. When they must fight they are afraid of waste, as they always were, so they give one ladle and then another, and they keep count of what came in today, and they trust that this has been enough before.

## How It Fights

For a second and a half only your basic attack lands. Then two thin hits, and two more, and their ward starts paying far more than it should. By t = 3 they stand on 61 % with an empty pool, and you stand on 55 % with 35 %. Everything after that is the same two ladles reaching a body with no ward.

**The signature moment:** at t = 4 they have nothing left to cast and you have not changed anything. You will not, because you never had a second plan (`variants/one-ladle-mixed.fight.json`, `--timeline`).

## The Stack

A walk across the Water sector, 110 nodes, 90 acupoints and 20 notables, 268 W. That is under the quarter of Deity's tree (293 W) that a typical life spends on attack. Sector rows scale with purity, so these sizes assume purity 50 (Meridian Map rule 21's 0.5 + purity/100).

`Take` is acupoints + notables. `Without` is the whole row removed from `variants/one-ladle-mixed.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health, own linh lực, enemy health at t = 3. **The full fight is 4.5 s, 50 %, 28 %, 61 %.**

### The Water road: both lines walk it

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 1 | Water damage (Thủy Thương) | 14 + 2 | +2 / +12 | +52 | Increased | L1 | ○ catalogue | 6 s, 33 %, 12 %, 77 % |
| 2 | Maximum linh lực (Linh Hải) | 10 + 2 | +1.2 / +8 | +28 % | Increased | none | ● | `no-pool`: 4.5 s, 50 %, 19 %, 61 % |
| 3 | Ward strength (Hộ Lực) | 10 + 2 | +1.2 / +8 | +28 | Increased | none | ● | `no-ward`: 4.5 s, 42 %, 31 %, 61 % |
| 4 | Ward efficiency (Hộ Hiệu) | 10 + 2 | +1.2 / +8 | +28 | Increased | none | ● | `no-eff`: 4.5 s, 50 %, 17 %, 62 % |
| 5 | Regeneration (Hồi Khí) | 8 + 2 | +0.15 / +1 | +3.2 % | Increased | none | ● | `no-regen`: 6 s, 40 %, 4 %, 70 % |
| 6 | Water art cost (Tiết Thủy) | 6 + 1 | −1 / −6 | −12 % | Increased | none | ○ catalogue | `art_cost_pct`: 4.5 s, 50 %, 25 %, 61 % |
| 7 | **Unbroken Surface (Toàn Diện)**: Water arts while your linh lực is above 5 % | 6 + 2 | +2 / +12 | +36 | Conditional | L5 | ○ new | 6 s, 33 %, 12 %, 76 % |

### The Soaking Line (Thấm Mạch), toward Wood: walked here

Water feeds what grows, so this line keeps giving. Qi hits, the cheapest arts, and rows that read what you still hold.

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 8 | Qi damage (Khí Thương) | 10 + 1 | +1.5 / +10 | +25 | Increased | L1 | ○ catalogue | 6 s, 33 %, 12 %, 72 % |
| 9 | **Thin Stream (Tế Lưu)**: Water arts with an authored cost of 5 % or less | 8 + 2 | +2 / +12 | +40 | More | L2 | ○ new | 6 s, 33 %, 12 %, 73 % |
| 10 | **Held Water (Tàng Thủy)**: Water arts, per 1 % of linh lực you hold | 6 + 2 | +0.02 / +0.12 | up to +36 | Per | L2 | ○ new | 6 s, 33 %, 12 %, 72 % |
| 11 | **Spring Head (Tuyền Đầu)**: Water arts, per 1 % of regeneration you own | 2 + 1 | +0.5 / +3 | +20.8 at 5.2 % | Per | L2 | ○ new | 6 s, 40 %, 20 %, 71 % |
| 12 | Wasting (Hao Tổn): hits, per 1 % of the enemy's linh lực missing | 0 + 1 | notable +0.2 | up to +20 | Per | L2 | ○ reused | 6 s, 40 %, 20 %, 67 % |

**All 12 rows removed one at a time still win.** The worst case is one more pair of ladles, 1.5 s later, on 33 % health. Wasting was built for a poisoner's rival line and is taken here unplanned.

### The Cold Line (Hàn Mạch), toward Metal: the rival

Metal makes Water, so this line runs the other way: cold, hard and quick, at a higher price. To pay for it, the road's pool, ward strength, efficiency, regeneration and cost rows are cut to 6 + 1, 8 + 1, 6 + 1, 4 + 1 and 4 + 1. Saved whole as `cold-mixed`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 13 | Body damage (Thể Thương) | 10 + 1 | +1.5 / +10 | +25 | Increased | L1 | ○ catalogue |
| 14 | **Cold Edge (Hàn Phong)**: Water arts of the body kind | 14 + 3 | +2 / +12 | +64 | More | L2 | ○ new |
| 15 | Crit chance with Water (Hàn Mang) | 12 + 4 | +0.8 / +5 | +29.6 % | Increased | none | ○ catalogue shape |
| 16 | Crit damage (Bạo Thương) | 12 + 2 | +1.5 / +10 | +38 % | Increased | none | ● |
| 17 | Linh lực regained on a crit (Hồi Bạo) | 4 + 1 | +0.1 / +0.6 | +1 % | Trigger | none | ○ catalogue |

### Beside the road

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 18 | Ward strength against Fire (Khắc Hỏa) | +2 / +12 | Conditional | ○ catalogue | Water overcomes Fire. Either line, hunting Fire. Not run |
| 19 | Ward strength against Earth (Hộ Đê) | +2 / +12 | Conditional | ○ catalogue | What overcomes Water. Either line, meeting The Long Firing. Not run |
| 20 | Water art speed (Tấn Thủy) | +1 / +6 | Increased | ○ catalogue | Cold. On the Soaking Line it spends what the income cannot cover |

That is 20 modifiers and 38 rows in `pieces/one-ladle.json`, in Increased, More, Conditional, Per and Trigger, with 0 rule asks.

**Identity piece:** none, on purpose. The nearest thing is Thin Stream, because a Cold art at 6 % can never have it. `--without "Thin Stream"` on the fixture one up moves the win from 4.5 s to 6 s.

**Empty rungs:** crit is left at the typical 15 %, a sacrifice. Past the cap is empty: regeneration stops at 5.2 % of the 8 % cap, which is where a longer life would go.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | 77 | ×1.77 | Rows 1 and 8 |
| L2 | 101, up to 157 | ×2.01 to ×2.57 | The Rule 40, Thin Stream 40, Spring Head 20.8, then Held Water and Wasting, one falling as the other rises |
| L3 | 40 | ×1.40 | The typical weapon |
| L4 | 20 | ×1.20 | A pill. 0 in a blind fight |
| L5 | 36 | ×1.36 | Unbroken Surface |
| M | | ×8.1 to ×10.4 | Typical at Deity is ×8.96 |

## Remove Five

Same fight, whole rows, each file `variants/one-ladle-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-sustain` | Pool, ward strength, efficiency, regeneration, cost | **Lost** at 7 s, enemy on 20 % |
| `five-damage` | Water, Surface, Thin Stream, Held Water, Qi | **Lost** at 6 s, enemy on 76 % |
| `five-mixed` | Water, ward strength, regeneration, Held Water, Wasting | **Lost** at 7 s, enemy on 54 % |
| `five-gentle` | Cost, Held Water, Spring Head, Thin Stream, Wasting | **Still wins** at 8 s on 20 % |
| `no-path` | All 12 rows | Lost at 5 s, enemy on 88 % |

`five-gentle` keeps every ward row and both L1 rows. It wins with an empty pool, so the test does not hold for every five.

## The Same 268 W Spent As Plain Attack

Same life, same two ladles, 268 W of `attack_pct` in L1. This is the multiplying.

| Enemy | The stack | Plain attack |
|---|---|---|
| Mixed | `mixed`: wins at 4.5 s on 50 %, pool 28 % | `plain-mixed`: wins at 5 s on 24 %, pool 0 % |
| Wall, `n_body` 7 | `wall`: wins at 9 s on 24 % | `plain-wall`: **loses** at 7 s, enemy on 60 % |
| Evader, 30 % | `evader`: wins at 7.5 s on 27 % | `plain-evader`: **loses** at 5 s, enemy on 71 % |

Plain attack past 200 points is halved by the soft cap, and it leaves the ward as it found it.

## The Choice

| Enemy | Soaking Line, two arts at 4 % | Cold Line, three arts at 6 % |
|---|---|---|
| Mixed | Wins at 4.5 s on 50 %, pool 28 % | `cold-mixed`: wins at 3 s on 53 %, pool 10 % |
| Wall | Wins at 9 s on 24 % | `cold-wall`: **loses** at 8 s, enemy on 37 % |
| Evader | Wins at 7.5 s on 27 % | `cold-evader`: **loses** at 5 s, enemy on 37 % |
| Fast killer: L2 120, `n_body` 2.0 | `fast`: **loses** at 5 s, enemy on 15 % | `cold-fast`: **wins** at 3 s on overkill |
| Each other | `duel-cold`: Soaking wins at 6 s on 21 % | |

Plainly, the Soaking Line is better on most of this table. Cold finishes a fight sooner and is the only answer to a fast killer. What it cannot do is finish a long one. You cannot have both: Thin Stream needs arts at 5 % or less, and Cold Edge needs body hits, which burn their ward more slowly.

**Counter:** a fast killer, or a deep pool that does not run out (`deep`, `n_qi` 5: loses at 6 s, enemy on 20 %). The top end ends it at t = 1.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water, purity 50 | Sets the sector scale |
| Key talents | None | Nothing here reads a talent. Sense and fortune are not read, and enemy sense stays at the default |
| The rest of the tree | The typical life's ward, pools and health | Copied from the fixture, so the road is the only difference |
| The Way (Đạo) | None | Everything is on base-map ground |

## Công Pháp

### One Ladle Rule (Nhất Chước Quy) — main, Thiên giai

```json
{"id": "nhat_chuoc_quy", "name": "Nhất Chước Quy", "tier": 3, "tech_kind": "main", "names": ["thuy"], "layers": 15,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "so_chuoc", "unlock_layer": 2}, {"ability_id": "tai_chuoc", "unlock_layer": 5}],
 "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on Water arts, the typical anchor. **Budget:** 15/15 + 15/15 = 2.0 of 4.0.

| Art | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| First Ladle (Sơ Chước) | qi, Water, hit | 1.60 | 0.04 | 1.5 s | Needs key |
| Second Ladle (Tái Chước) | qi, Water, hit | 1.60 | 0.04 | 1.5 s | Needs key |
| Cold Needle (Hàn Châm), Cold Rain (Hàn Vũ), Cold Draught (Hàn Ẩm), Cold Line | body, Water, hit | 1.84 | 0.06 | 1.5 s | Needs key |

**Effect:** a hit, at the lint's ceiling. **Description:** enough for today.

**Items:** the typical weapon (L3 40), the typical ward kit on the common ward, an attack pill (L4 20). All Fit today. Two of seven slots are used, and the others stay empty.

## Progression

| Realm | Plays like | Result | Story beat |
|---|---|---|---|
| Foundation, 31 nodes, 78 W | Two ladles on a short rope | `foundation-mixed`: wins at 6 s on overkill. `foundation-five` (the damage five) loses at 6 s, enemy on 12 % | The first dry year |
| Deity, 110 nodes | Income passes outgo | Wins at 4.5 s on 50 % | They still climb down to the well themselves |

## Matchups

| Enemy | Result |
|---|---|
| Mixed, same realm (`mixed`) | Wins at 4.5 s on 50 %. A foreseen fight with no home ground |
| One cheap art (`one-art`) | Wins at 4.5 s on 51 %, pool 40 % |
| Blind (`blind`) | Wins at 6 s on 33 % |
| One up, at Foundation (`foundation-mixed --gap 1`) | Loses at 2 s, enemy on 95 % |

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | 2.0 of 4.0. Both arts at the lint's ceiling. Slots 2 of 7 |
| Validity | PASS | `hoa_than`, Thiên giai reaches it. Cost 0.04 is Formulas E's floor |
| Stack | PASS | Four forms in the walk, every empty rung named, layers stated |
| Plain Stack test | PASS | 12 of 12 single rows still win. 3 of 4 saved fives lose, and the one that wins is shown |
| Against plain attack | PASS | The stack wins two fights plain attack loses, at the same W |
| Scaling | PASS | M 8.1 to 10.4 against 8.96 |
| The fight | PASS | Both arts fire on time, own pool never dry, no cap hit |
| Reuse | PASS | Wasting, proved in the main fight. Every row has a second home in `pieces/one-ladle.json` |
| NPC use | PASS | Plain numbers on tags, each one Breakdown line |
| Counterplay | PASS | Fast killer, deep pool |
| Originality | PASS | Plain words |

## Fight Results

Input: `sheets/one-ladle.fight.json`. Observations from `fight_x.py`, a paper model with expected values. No plug-ins.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0 | Win | 4.5 s | 49 % | none |
| Typical | 1, 2 | Win, on 49 % and 38 % | 4.5 s, 6 s | | none. No realm exists above Deity, so these rows are the same enemy with suppression, not a higher one |
| Top-end | 0 to 2 | Loss, enemy on 100 % | 1 s | 0 | none |

**Unmodelled:** element on a hit, so rows 18 and 19 are not run. Held Water is written as +36 less 0.36 per 1 % of linh lực missing, which is the same thing.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Tag key for modifiers | Needs key | The catalogue's one key shape. Rows 1, 6, 8, 13, 15, 20 |
| Own-pool and authored-cost conditions | Needs key | Rows 7, 9, 10. Same shapes as Steady Thread and Small Word |
| Regeneration read at compile | Needs key | Row 11 |
| The Rule and its arts | Needs key | Content, with a Water tag on arts |

## Questions

1. Should every element's road fork at its two sector borders, mother on one side and child on the other? The Map already lays sectors in generating order, so no path of this size reaches both. It would give all five elements a rival pair for free.
2. Cost 0.04 at a short cooldown is the strongest art shape I found, against both fixtures and the mixed enemy. Is the art lint meant to pay the cheapest art this well?

## Also Considered

- **The Reservoir and the Spring:** capital against income, on one pool. Dropped, because costs are shares of maximum, so a bigger pool only ever buys ward, and the ward's leak kills before the pool does.
- **Downstream into ticks:** Water feeding a Wood status. Dropped as the rival, because ticks need a fight twice this long and the ward does not buy it.
