# The Rice Pestle (Mễ Xử Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Body: 14 or more ordinary rows for a thể tu, two rival lines, one build of 10 or more, remove one and little moves, remove five and it is lost.
> **Direction**: A body has two ways to be strong, and every rice-pounder knows them: be the mortar, which takes the blow, or be the pestle, which has weight behind it. This sheet walks the Pestle.
> **Realm span**: Nascent Soul – Deity Transformation, defined at Deity Transformation · **Power level**: ordinary · **Use**: player path, or any plain elder of a body sect
> **Fit**: 12 Fits today · 32 Needs key · 0 Needs rule
> **Checks**: 11 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** body hits: the basic attack and two arts, on all five layers.
- **The enabler:** none.
- **The loop:** a stroke every second, a heavier one every third, and the free fist. Both arts are paid in health, so the linh lực stays in the ward.
- **The engine:** a health row is counted four times: in the pool, in the guard (Formulas D's slope), in Mass Behind the Blow, and in how long you can stand on the low side of Reopened. No one of these is much.
- **The sacrifice:** soul. Nothing here stops a soul art, and the blood cost means you start hurting yourself at t = 1.
- **The arc:** at Nascent Soul the stack is only a little better than plain attack. At Deity plain attack has met the soft cap, and the same habit of spreading is worth a second and 19 points of health.

## The Legend

In the hill villages rice is pounded at night so it can be eaten in the morning. Thương Mộc did the pounding for one household from the age of seven, and then for four, because a neighbour's back went and someone had to. Their root was poor. The sect that tested them was kind about it. They went home, because the rice was not done.

They never found a technique. A travelling doctor saw their arms and wrote down a few plain exercises, and they did those between strokes for a very long time. They are a Deity now and they still lift the same way, from the back, breathing out. It hurts, and they stopped treating that as a warning long ago. When a fight goes badly the stroke gets heavier, and not from anger. A tired body stops holding anything back, and they know from long experience that the morning comes anyway.

## How It Fights

Two seconds of trading: you lose a tenth of your health a second, your own blood included, and they lose a sixth. At t = 3 the Lifted Pestle lands with Reopened awake, their linh lực falls from 56 % to 3 %, and their health from 69 % to 34 %. One more second finishes it. You have 59 % of your health and 23 % of your linh lực, and the ward never went dry.

**The signature moment:** nothing. No art deals half the damage in a way you could point to: the stroke 50 %, the fist 36 %, the heavy art 14 % (`variants/rice-pestle-mixed.fight.json --timeline`). That is the honest look of a Plain Stack.

## The Stack

131 nodes, 111 acupoints and 20 notables, 293.2 W: the exact quarter of Deity's tree a typical life spends on attack. Sector rows assume purity 50. Maximum health needs little walking of its own, because one road node in two carries it and roads pay the same on every root (Meridian Map rule 21). So that row asks nothing of your linh căn.

`Take` is acupoints + notables. `Without` is the whole row removed from `variants/rice-pestle-mixed.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health, enemy health at t = 3. **The full fight is 4 s, 59 %, 34 %.**

### The Road: both lines walk it

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 1 | Body damage (Thể Thương) | 18 + 3 | +1.5 / +10 | +57 | Increased | L1 | ○ catalogue | 5 s, 45 %, 52 % |
| 2 | Art damage (Pháp Thương) | 10 + 3 | +1.5 / +10 | +45 | Increased | L1 | ○ catalogue | 5 s, 50 %, 44 % |
| 3 | Basic attack damage (Bình Kích) | 16 + 3 | +2 / +12 | +68 | Increased | L1 | ○ catalogue | 4 s, 55 %, 39 % |
| 4 | Crit chance on body hits (Thể Bạo Suất) | 6 + 1 | +0.8 / +5 | +9.8 % | Increased | none | ○ tag swap | `no-crit-chance`: 4 s, 55 %, 38 % |
| 5 | Crit damage (Bạo Thương) | 5 + 1 | +1.5 / +10 | +17.5 % | Increased | none | ● | `no-crit-damage`: 4 s, 55 %, 36 % |
| 6 | Body guard (Hộ Thể) | 6 + 1 | +1.2 / +8 | +15.2 % | Increased | none | ● | `no-guard`: 4 s, 57 %, 33 % |
| 7 | **Blood Stroke (Huyết Kích)**: arts paid in health | 5 + 1 | +2 / +12 | +22 | More | L2 | ○ new | 4 s, 55 %, 38 % |
| 8 | Thinning Ward (Bạc Hộ): art damage while the enemy has under 50 % linh lực | 3 + 0 | +2 / +12 | +6 | Conditional | L1 | ○ reused | 4 s, 55 %, 35 % |

### The Pestle Line (Xử Mạch): walked here

Weight, and what weight does when it is hurt.

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 9 | Maximum health (Khí Huyết), road and line together | 30 + 4 | +1 / +6.5 | +56 % | Increased | none | ● | `no-health`: 4 s, 48 %, 40 % |
| 10 | **Mass Behind the Blow (Trọng Thể)**: body hits, per 1 % of `khi_huyet_pct` you own, read at compile | 8 + 2 | +0.02 / +0.12 | +61 at 153.6 % owned | Per | L2 | ○ new | 5 s, 45 %, 53 % |
| 11 | Reopened (Tái Liệt): hits, per 1 % of health missing | 4 + 1 | +0.1 / +0.6 | +1 a point, +30 at 70 % health | Per | L5 | ○ reused | 5 s, 50 %, 43 % |

**All 11 rows removed one at a time still win.** The widest move is one second and 14 points of health. Reopened was built for Turned Away's gate scars and is taken here unplanned. Row 6 costs 2 points of health and speeds the kill, because a softer body wakes Reopened sooner.

### The Mortar Line (Cữu Mạch): the rival

Road row 9 stops at 10 + 1 (+16.5 %), and the walk goes to hardness instead: 294 W, saved whole as `mortar-mixed`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 12 | Body guard, on past row 6 | 14 + 3 in all | +1.2 / +8 | +40.8 % | Increased | none | ● |
| 13 | Armour defence (Giáp Hậu), on a plain Giáp, `a_b` 0.85 before it | 4 + 2 | +1.5 / +10 | +26 % | Increased | none | ● |
| 14 | **Hard Knuckle (Ngạnh Quyền)**: body hits, per 1 % of `body_guard_pct` you own. Fired Clay's key on a wider tag, so half its size | 8 + 2 | +0.05 / +0.3 | +41 | Per | L2 | ○ new |
| 15 | **Unmoved (Bất Động)**: body hits while your health is at 50 % or above. Unbroken Glaze's key on a wider tag | 6 + 1 | +2 / +12 | +24 | Conditional | L5 | ○ new |

### Beside the road

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 16 | Damage while below 50 % health (Sạt Lở) | +2 / +12 | Conditional | ○ catalogue | It was on the walk until its run moved nothing: this Pestle wins above 50 % |
| 17 | Body guard against qi hits (Nội Giáp) | +2 / +12 | Conditional | ○ catalogue | Mortar, against casters. Not run |
| 18 | Basic attack speed (Tốc Kích) | +1 / +6 | Increased | ○ catalogue | Any fist. Not run: `basic_cooldown` is one constant in the calculator |
| 19 | Evade (Thiểm Tị) | +0.4 / +2.5 | Increased | ● | A lighter body. Not run |
| 20 | Status resistance (Kháng Độc), Curse duration on you (Đoản Chú) | +1 / +6, −2 / −12 | Increased | ●, ○ | Mortar, whose guard a shred curse halves. Not run |

That is 20 modifiers and 40 rows in `pieces/rice-pestle.json`, in Increased, More, Conditional and Per, with 0 rule asks.

**Identity piece:** none, on purpose. **Empty rungs:** past the cap is empty, and nothing reaches one.

### How they multiply

| Term | Typical at Deity | The Pestle | Rows |
|---|---|---|---|
| L1, art / fist | ×3.47, soft-capped | ×2.08 / ×2.25 | 1, 2, 3, 8 |
| L2, art / fist | ×1.40 | ×2.23 / ×2.01 | Method, 7, 10 |
| L3, L4 | ×1.40, ×1.20 | the same | Knuckle Wraps, a pill |
| L5 | ×1.10 | ×1.00 to ×1.41, rising | 11 |
| M, art | 8.96 | 7.8 at full health, 10.2 at 70 % | |
| Crit, on average | ×1.11 | ×1.22 | 4, 5 |
| What a body hit leaves after guard | ×0.85 | ×0.47 | 6, 9, the Frame's `t_b` 2 |
| Health | `n_body` 2.62 | 3.18 | 9 |

## Remove Five

Same fight, whole rows, each file `variants/rice-pestle-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-fists` | Body, Art, Basic, Crit chance, Blood Stroke | **Lost** at 6 s, enemy on 11 % |
| `five-weight` | Art, Mass, Reopened, Health, Crit chance | **Lost** at 6 s, enemy on 12 % |
| `five-cross` | Body, Basic, Mass, Reopened, Blood Stroke | **Lost** at 6 s, enemy on 53 % |
| `five-gentle` | Crit chance, Crit damage, Thinning Ward, Blood Stroke, Body guard | **Still wins** at 5 s on 48 % |
| `no-path` | All 11 | Lost at 6 s, enemy on 68 % |

`five-gentle` removes the five smallest rows and keeps every L1 row, Mass and Reopened, so the test does not hold for every five.

## The Same 293 W Spent As Plain Attack

Same life, arts and kit, 293.2 W of `attack_pct` in L1. The stack buys the first 100 or so points of L1 and then goes elsewhere. Plain attack climbs past 200, where each point counts half.

| Enemy | The stack | Plain attack |
|---|---|---|
| Mixed | `mixed`: 4 s on 59 % | `plain-mixed`: 5 s on 40 % |
| Caster, all qi | `caster`: 4 s on 35 % | `plain-caster`: 5 s on 9 % |
| Fast killer: L2 120 | `fast`: 4 s on 21 % | `plain-fast`: **loses** at 4 s, enemy on 23 % |
| Mixed, Nascent Soul, 186.8 W | `ns-mixed`: 4 s on 44 % | `ns-plain`: 4 s on 37 % |

## The Choice

Node for node the two lines cost the same (293.2 W, 294 W), and no walk of this size reaches both sets of notables.

| Enemy | Pestle | Mortar |
|---|---|---|
| Mixed | 4 s on 59 % | `mortar-mixed`: 4 s on 58 % |
| Fast killer | `fast`: 4 s on 21 % | `mortar-fast`: 4 s on 10 % |
| Fast killer, L2 160 | `fast-hard`: **wins** at 4 s on overkill | `mortar-fast-hard`: **loses** at 4 s on overkill |
| Caster | `caster`: 4 s on 35 % | `mortar-caster`: 4 s on 38 % |
| One big art: L2 120, `n_body` 3.2 | `burst`: 5 s on 48 % | `mortar-burst`: 5 s on 52 % |

So Mortar keeps a few more points in a fair fight, and Pestle wins the fight you were going to lose. Unmoved goes out at 50 %, exactly when Reopened is worth most. **Hardness buys a Pestle nothing here:** with an armour (`armour`) it is still 4 s on 59 %, with 13 % of its linh lực against 23 %.

**This fork rests on one first guess.** With Unmoved at +40 (8 + 2 nodes, 304.4 W), Mortar passes Pestle in both fights tried: `mortar-unmoved-40` 4 s on 62 %, `mortar-unmoved-40-fast` 4 s on 28 %. A flat row in an empty L5 is worth more than it looks.

**Counter:** a soul art walks past all of this. In a duel at Nascent Soul with The Third Look (`ns-duel-look`, Pestle listed first) the Pestle falls at 3 s with the Look on 26 %. Listed second, in `third-look-duel-pestle`, the Pestle wins on overkill at 3 s. A dying side still acts, and the side resolving second reads the wound the first dealt. The top end ends it at t = 1.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any, purity 50 where a sector row is walked | Roads pay the same on every root |
| Key talents | None | Sense and fortune are not read. Neither side has a soul art, except in the duel, where sense is 61.3, derived on The Third Look's sheet |
| The rest of the tree | The typical life's ward, pool and health | Copied from the fixture, so the path is the only difference |
| The Way (Đạo) | None | |

## Công Pháp

### Pounding Rule (Đảo Quy) — main, Thiên giai

```json
{"id": "dao_quy", "name": "Đảo Quy", "tier": 3, "tech_kind": "main", "names": [], "layers": 15,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}, {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "pounding_stroke", "unlock_layer": 2}, {"ability_id": "lifted_pestle", "unlock_layer": 5}],
 "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on body hits, the typical anchor. **Budget:** 2.0 of 4.0, the same two lines as One Ladle Rule. **Long Day Frame (Trường Nhật Thể)**, body, Thiên giai: `t_b` 2 at full mastery, a first guess.

| Art | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| Pounding Stroke (Đảo Kích) | body, hit | 1.60 | 2.5 % health | 1 s | Needs key |
| Lifted Pestle (Cử Xử) | body, hit | 2.46 | 4 % health | 3 s | Needs key |

**Effect:** a hit, at the lint's ceiling. **Description:** from the back, breathing out.

**Items:** Knuckle Wraps (L3 40, reused), the typical ward kit, an attack pill (L4 20). All Fit today but the wraps.

## Matchups

| Enemy | Result |
|---|---|
| Mixed, same realm (`mixed`) | Wins at 4 s on 59 %. A foreseen fight with no home ground |
| One cheap art (`one-art`) | Wins at 4 s on 60 %, pool 39 % |
| Arts paid in linh lực instead, 0.05 and 0.08 (`qi-paid`) | Wins at 4 s on 55 %, pool 0 %, against 23 % |
| One up, at Nascent Soul (`ns-mixed --gap 1`) | Loses at 3 s, enemy on 82 % |
| Mixed top-end (`mixed --enemy top_end`) | Loses at 1 s, enemy on 98 % |

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | 2.0 of 4.0. Both arts at the lint's ceiling. Slots 2 of 7 |
| Validity | PASS | `hoa_than`, Thiên giai reaches it. `body_cost_share` is an existing art field |
| Stack | PASS | Four forms on the walk, rungs and layers stated |
| Plain Stack test | PASS | 11 of 11 single rows still win. 3 of 4 saved fives lose, and the one that wins is shown |
| Against plain attack | PASS | Better in all four fights at the same W, and one plain attack loses |
| Scaling | PASS | M 7.8 to 10.2 against 8.96 |
| The fight | PASS | Both arts fire on time, the pool never dries, no cap hit |
| Reuse | PASS | Reopened, unplanned, proved in the main fight. Every row has a second home |
| NPC use | PASS | Plain numbers on tags, each one Breakdown line |
| Counterplay | PASS | Soul, and the top end |
| Originality | PASS | Plain words |

## Fight Results

Input: `sheets/rice-pestle.fight.json`. Observations from `fight_x.py`, a paper model with expected values. No plug-ins, except `soul_x` in the duel.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0, 1, 2 | Win | 3 s, 4 s, 5 s | 64 %, 59 %, 54 % | none. No realm exists above Deity, so gaps 1 and 2 are the same enemy with suppression |
| Top-end | 0 to 2 | Loss, enemy on 98 % | 1 s | 0 | none |

**Unmodelled:** crit rows also lift the basic attack, because the calculator holds one crit for a side. Rows 17 to 20 are not run.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Tag key for modifiers | Needs key | The catalogue's one key shape. Rows 1 to 4, 7, 8 |
| Owned-stat, own-health conditions | Needs key | Rows 10, 11, 14, 15. Same shapes as Fired Clay, Reopened and Unbroken Glaze |
| The Rule, the Frame and their arts | Needs key | Content |

## Questions

1. Should Unmoved stay at +24? The rival line turns on this number.
2. The lint counts `body_cost_share` at twice `cost_share`. Here 2.5 % health buys what 5 % linh lực buys, and it leaves 23 points of pool in the ward for 4 points of health (`qi-paid`). Is that the intended rate for a thể tu?
3. Who resolves first in an instant decides this duel in both directions. It joins Understudy and Best Plan's ambusher under one open ruling.

## Also Considered

- **The Bare Fist:** no arts at all, every slot empty. One blow a second was too little to carry the budget, and one cheap art was worth more than any row. Dropped as the build, with no number kept.
- **Above and below 50 % as the fork:** The Long Firing already walks those rows.
