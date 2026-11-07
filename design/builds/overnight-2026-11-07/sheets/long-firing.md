# The Long Firing (Trường Thiêu)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Earth: ordinary nodes, no enabler, 0 rule asks, two rival lines, remove one and little moves, remove five and it is lost.
> **Direction**: The body takes what the ward lets through, the ward is paid by the second, and two heavy stones do the rest. The road forks at the sector's borders: fired hard toward Fire, or loaded with ore toward Metal. This sheet walks the Kiln.
> **Realm span**: Foundation Establishment – Core Formation, defined at Core Formation · **Power level**: ordinary · **Use**: player path, or the guard at any pass
> **Fit**: 16 Fits today · 31 Needs key · 0 Needs rule
> **Checks**: 10 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward model)

## The Spine

- **The channel:** art hits of the body kind, plus the basic attack. A body hit leaks past their ward half as much again as a qi hit, so Earth does not wait for their pool.
- **The enabler:** none. The Stone Ward is a plain ward of a kind Combat rule 22 already allows, but the build stands on it, and it is shown below.
- **The loop:** pay the ward at every pulse. Drop a stone at t = 4, another at t = 5, and the first again at t = 8.
- **The engine:** a per-pulse ward costs the same whatever lands, so the pool lasts long enough for the stones. Then body guard, health and four layers of damage multiply on a fight that lasts just long enough.
- **The sacrifice:** speed, reach and the long fight. Nothing happens for 4 s, and a pool that pays 6.2 % a pulse has an end.
- **The arc:** at Foundation it stands to 8 s on 5 %. At Core it stands to the same 8 s on 15 %.

## The Legend

Ngô Sành kept the brick kiln below Lam Pass. A firing takes days, and the fire has to be fed at every watch: let it drop once, and the whole load cracks, however good the clay. They were not brave, and they have said so to anyone who asks. They learned one thing in that yard, which is that you do not fire a kiln by being strong. You do it by getting up again at the next watch.

The night the riders came down the pass, the people of the valley needed until morning to get their children over the ridge. Sành stood in the road with a kiln rake, shaking, and kept their breath going the way they kept the fire. Afterwards a passing teacher asked who had taught them that, and they could not answer, and cried. Pupils of that road still work a season at the kiln before they are shown anything else.

## How It Fights

For four seconds you have only your basic attack, and you lose 45 % of your health. Then Falling Lintel lands and takes a quarter of them off in one blow, because body hits go through. A second later Settling Wall takes another quarter. They are on 38 %, you are on 45 %, and your pool has paid every pulse without being asked twice.

**The signature moment:** at t = 7 you are on 19 %, and they are on 33 % with no linh lực. You have spent every pulse of this fight being hit. Then the first stone comes round again (`variants/long-firing-mixed.fight.json`, `--timeline`).

## The Stack

A walk across the Earth sector, 55 nodes, 47 acupoints and 8 notables, 120.4 W, a little over the quarter of Core's tree a typical life spends on attack. Sizes assume purity 50.

`Take` is acupoints + notables. `Without` is the whole row removed from `variants/long-firing-mixed.fight.json`: `--without "[id]"`, or the named file. It reads win time, own health, own linh lực, enemy health at t = 7. **The full fight is 8 s, 15 %, 37 %, 33 %.**

### The Earth road: both lines walk it

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 1 | Earth damage (Thổ Thương) | 9 + 1 | +2 / +12 | +30 | Increased | L1 | ○ catalogue | 10 s, 2 %, 21 %, 42 % |
| 2 | Body damage (Thể Thương) | 5 + 1 | +1.5 / +10 | +17.5 | Increased | L1 | ○ catalogue | 10 s, 2 %, 21 %, 41 % |
| 3 | **Settled Weight (Trầm Trọng)**: Earth arts with an authored cooldown of 3 s or more. Long Flight's key on another tag | 6 + 1 | +2 / +12 | +24 | More | L2 | ○ new | 9 s, 6 %, 33 %, 39 % |
| 4 | Maximum health (Khí Huyết) | 3 + 1 | +1 / +6.5 | +9.5 % | Increased | none | ● | `no-health`: 8 s, 10 %, 37 %, 33 % |
| 5 | Body guard (Hộ Thể) | 3 + 1 | +1.2 / +8 | +11.6 % | Increased | none | ● | `no-guard`: 8 s, 11 %, 37 %, 34 % |

### The Kiln Line (Diêu Mạch), toward Fire: walked here

Fire makes Earth. This line is what the kiln makes: a hard body, a paid ward, and blows that are worth most before anything has cracked.

| # | Node | Take | Each | Total | Form | Layer | Status | Without |
|---|---|---|---|---|---|---|---|---|
| 6 | **Unbroken Glaze (Toàn Dứu)**: Earth arts while your health is at 25 % or above | 8 + 2 | +2 / +12 | +40 | Conditional | L5 | ○ new | 10 s, 2 %, 21 %, 47 % |
| 7 | Damage while above 50 % health (Toàn Khu) | 2 + 0 | +2 / +12 | +4 | Conditional | L1 | ○ catalogue | 8 s, 15 %, 37 %, 34 % |
| 8 | **Fired Clay (Đào Thể)**: Earth arts, per 1 % of body guard you own | 3 + 0 | +0.1 / +0.6 | +3.5 | Per | L2 | ○ new | 8 s, 15 %, 37 %, 34 % |
| 9 | Thinning Ward (Bạc Hộ): art damage while the enemy has under 50 % linh lực | 2 + 0 | +2 | +4 | Conditional | L1 | ○ reused | 8 s, 15 %, 37 %, 33 % |
| 10 | Ward efficiency (Hộ Hiệu) | 4 + 1 | +1.2 / +8 | +12.8 | Increased | none | ● | `no-eff`: 8 s, 15 %, 32 %, 33 % |
| 11 | Ward strength (Hộ Lực) | 1 + 0 | +1.2 / +8 | +1.2 | Increased | none | ● | `no-ward`: 8 s, 14 %, 37 %, 33 % |
| 12 | Regeneration (Hồi Khí) | 1 + 0 | +0.15 / +1 | +0.15 % | Increased | none | ● | `regen_bonus_pct`: 8 s, 15 %, 36 %, 33 % |

**All 12 rows removed one at a time still win.** Row 1, 2 or 6 moves the win to 10 s on 2 %, which is the widest any row goes. Rows 11 and 12 are one acupoint each and move almost nothing alone. Thinning Ward was built for a curser and is taken here unplanned, for the moment their pool falls: without it the two Lintels deal 623 health, not 647.

### The Ore Line (Khoáng Mạch), toward Metal: the rival

Earth makes Metal. This line carries the mountain instead of being it: two seals, an armour, no ward gear, no body technique. It is saved whole as `ore-mixed`.

| # | Node | Take | Each | Total | Form | Layer | Status |
|---|---|---|---|---|---|---|---|
| 13 | Weapon attack (Khí Phong) | 8 + 1 | +1.5 / +10 | +22 % | Increased | L3 | ● |
| 14 | Armour defence (Giáp Hậu) | 4 + 1 | +1.5 / +10 | +16 % | Increased | none | ● |
| 15 | **Load-Bearing (Phụ Trọng)**: Earth arts, per artifact carried, at most 6 | 4 + 0 | +1 / +5 | +12 at three | Per | L2 | ○ new |
| 16 | **Worn Slope (Hao Pha)**: Earth arts, per 1 % of your health missing | 3 + 1 | +0.02 / +0.12 | up to +18 | Per | L2 | ○ new |
| 17 | Damage while below 50 % health (Sạt Lở) | 2 + 0 | +2 / +12 | +4 | Conditional | L1 | ○ catalogue |

### Beside the road

| # | Node | Each | Form | Status | Who wants it |
|---|---|---|---|---|---|
| 18 | Earth art cost (Tiết Thổ) | −1 / −6 | Increased | ○ catalogue | Either. It was on the walk until its removal run moved nothing, so its node went to row 10 |
| 19 | Body guard against qi hits (Nội Giáp) | +2 / +12 | Conditional | ○ catalogue | Kiln, against casters. Not run |
| 20 | Ward strength against Water (Khắc Thủy) | +2 / +12 | Conditional | ○ catalogue | Earth overcomes Water. Not run |
| 21 | Ward strength against Wood (Hộ Căn) | +2 / +12 | Conditional | ○ catalogue | What overcomes Earth. Not run |
| 22 | Status resistance (Kháng Độc) | +1 / +6 | Increased | ● | Kiln, against a poisoner. Not run |

That is 21 modifiers and 42 rows in `pieces/long-firing.json`, in Increased, More, Conditional and Per, with 0 rule asks.

**Identity piece:** the Stone Ward, the only piece here without which the rest cannot start. `--without ward` falls back to the default ward and loses at 5 s with the enemy on 70 %.

**Empty rungs:** crit is left at the typical 15 %, and rate and reach are sacrifices, as an evader shows. Past the cap is empty, and nothing here reaches one.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 | 47.5, up to 55.5 | ×1.48 to ×1.56 | Rows 1, 2, then 7 and 9 |
| L2 | 67.5 | ×1.67 | The Method 40, Settled Weight 24, Fired Clay 3.5 |
| L3 | 40 | ×1.40 | The typical weapon |
| L4 | 20 | ×1.20 | A pill. 0 in a blind fight |
| L5 | 40 | ×1.40 | Unbroken Glaze |
| M | | ×5.8 to ×6.1 | Typical at Core is ×5.48 |

## Remove Five

Same fight, whole rows, each file `variants/long-firing-[name].fight.json`.

| File | Removed | Result |
|---|---|---|
| `five-weight` | Earth, Body, Settled Weight, Glaze, Above half | **Lost** at 8 s, enemy on 53 % |
| `five-mixed` | Earth, Guard, Glaze, Efficiency, Thinning Ward | **Lost** at 9 s, enemy on 31 % |
| `five-spread` | Body, Health, Settled Weight, Efficiency, Fired Clay | **Lost** at 9 s, enemy on 29 % |
| `five-stand` | Health, Guard, Efficiency, Ward strength, Regeneration | **Still wins** at 8 s on 5 % |
| `five-gentle` | Health, Efficiency, Ward strength, Regeneration, Thinning Ward | **Still wins** at 8 s on 9 % |
| `no-path` | All 12 rows | Lost at 7 s, enemy on 65 % |

So the test holds for any five that touches the damage rows, and does not hold for the standing rows alone. The third stone ends the fight at t = 8 before their loss can show.

**What the test does not cover.** The kit. `common-ward`, the same person on the common drain ward, loses at 6 s with the enemy on 35 %: the ward has taken the whole pool by t = 5. `no-method`, with no body technique, loses at 6 s with the enemy on 44 %. These two carry more than any row.

## The Same 120 W Spent As Plain Attack

Same life, same kit, same stones, 120.4 W of `attack_pct` in L1. Each file `variants/long-firing-[name].fight.json`.

| Enemy | The stack | Plain attack |
|---|---|---|
| Mixed | Wins at 8 s on 15 % | `plain-mixed`: wins at 8 s on 11 % |
| One cheap art | `one-art`: wins at 8 s on 24 % | `plain-one-art`: wins at 8 s on 15 % |
| Heavy ward, `ws` 160 | `ward-160`: **wins** at 10 s on overkill | `plain-ward-160`: **loses** at 8 s, enemy on 18 % |
| Evader, 25 % | `evader-25`: **wins** at 10 s on 2 % | `plain-evader-25`: **loses** at 8 s, enemy on 3 % |
| Heavy ward, `ws` 120 | `ward`: wins at 10 s on 2 % | `plain-ward`: wins at 8 s on overkill |
| Fist, no arts | `fist`: wins at 10 s on 13 % | `plain-fist`: wins at 8 s on 22 % |
| Poisoner | `poison`: wins at 10 s on overkill | `plain-poison`: wins at 8 s on 12 % |

The stack wins two fights plain attack loses, and loses none it wins, but it is often slower. An empty L1 is the best first purchase in the game, and the margin here is much thinner than Water's.

## The Choice

| Enemy | Kiln Line | Ore Line |
|---|---|---|
| Mixed | Wins at 8 s on 15 % | `ore-mixed`: wins at 5 s on 17 % |
| Evader, 15 % | `evader`: **wins** at 10 s on 2 % | `ore-evader`: **loses** at 7 s, enemy on 9 % |
| Heavy ward, `ws` 120 | `ward`: **wins** at 10 s on 2 % | `ore-ward`: **loses** at 7 s, enemy on 23 % |
| Poisoner: one art, c_tick 0.3 | `poison`: **wins** at 10 s on overkill | `ore-poison`: wins at 8 s on overkill |
| Armoured: `a_b` 2 | `armoured`: wins at 11 s on 3 % | `ore-armoured`: wins at 8 s on overkill |
| Wall: `n_body` 2.8 | `wall`: wins at 12 s on overkill | `ore-wall`: wins at 8 s on overkill |
| Each other | `duel-ore`: Kiln wins at 11 s on 4 % | |

Ore hits as if the mountain had fallen, and it dies as soon as anything goes wrong: it needs its stones to land, on time, and it wears no ward gear. Kiln is the one that gets up at the next watch. You cannot have both, since Glaze and Above-half want you whole while Worn Slope and Below-half want you hurt, and the gear budget goes one way. Ore's kit also wants about 650 thần thức at Core, a first estimate from the bases, and not run.

**At the legal upkeep this fork is thin.** Kiln now wins every fight on this table, and Ore wins nothing that Kiln loses. Ore's only claim is speed, 2 to 4 s sooner where it wins at all. At the 12.5 % this sheet first used, which Combat does not allow, armour and the wall beat Kiln and the fork looked real. The rework should re-think the Ore Line (`wheel.md`).

**Counter:** a real fortress, or a fast killer. The panel's Wall beats it at 16 s and keeps 84 % of its health (`panel-wall`), and the panel's Fast beats it at 4 s and keeps 49 % (`panel-fast`). The armoured enemy and the wall above no longer do, though both fights end close: 3 % and overkill. Anything one realm up kills it before the first stone: `mixed --gap 1` loses at 3 s, enemy on 98 %.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth, purity 50 | Sets the sector scale |
| Key talents | None. Ore needs Thần hồn for its kit | Sense and fortune are not read, and enemy sense stays at the default |
| The rest of the tree | The typical life's pools and ward points | Copied from the fixture. `n_body` 1.73, `n_qi` 1.46 |
| The Way (Đạo) | None | Way of Keeping would suit it, and no node is needed |

## Công Pháp

### Long Firing Method (Trường Thiêu Công) — main, Huyền giai

```json
{"id": "truong_thieu_cong", "name": "Trường Thiêu Công", "tier": 1, "tech_kind": "main", "names": ["tho"], "layers": 9,
 "bonuses": [{"stat": "tam_ma_resist_pct", "value": 15}],
 "abilities": [{"ability_id": "lac_mi", "unlock_layer": 3}, {"ability_id": "tram_bich", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on Earth arts, the typical anchor. **Budget:** 15/15 = 1.0 of 2.0.

### Packed Clay Method (Hãng Thổ Công) — body, Huyền giai

`t_b` 2 at full mastery, a first guess, in an auxiliary slot. A season at the kiln, then the same again.

| Art | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| Falling Lintel (Lạc Mi) | body, Earth, hit | 2.71 | 0.08 | 4 s | Needs key |
| Settling Wall (Trầm Bích) | body, Earth, hit | 2.96 | 0.08 | 5 s | Needs key |

**Effect:** a hit, at the lint's ceiling. **Description:** it was always going to come down.

## Ward

**Stone Ward (Thạch Hộ).** Per-pulse model (Combat rule 22). Common pass 0.54 body, 0.36 qi. Upkeep 10 % of maximum linh lực a pulse, the top of Combat's 0 to 0.10, reduced by ward efficiency: 6.2 % at `we` 60.7. No drain, so a blow costs it nothing. **Fit:** Needs key, as data. **Description:** feed it at every watch.

**Items:** the typical weapon (L3 40), the typical ward gear on the Stone Ward, an attack pill (L4 20). The Ore Line swaps these for one `an` seal at Hạ phẩm and one at Trung phẩm (L3 120) and one `giap` armour (`a_b` 0.85, the same gear budget).

## Progression

| Realm | Plays like | Result | Story beat |
|---|---|---|---|
| Foundation, 31 nodes, 71 W | The same stones, barely | `foundation-mixed`: wins at 8 s on 5 %. `foundation-five` loses at 9 s, enemy on 31 % | The first load that does not crack |
| Core, 55 nodes | The same, with a little left | Wins at 8 s on 15 % | The night at the pass |

**Blind** (`blind`): wins at 10 s on 2 %. **One cheap art** (`one-art`): wins at 8 s on 24 %. The home fight is foreseen, with no home ground.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Method 1.0 of 2.0, arts at the lint's ceiling, slots 2 of 5. Nothing prices the Stone Ward, and thần thức for Ore is not run |
| Validity | PASS | `ket_dan`, Huyền giai reaches it. `t_b` 2 inside 0 to 5. `upkeep_share` 0.10, the top of Formulas D's 0 to 0.10. Rule 22 allows a per-pulse ward as data |
| Stack | PASS | Four forms in the walk, every empty rung named, layers stated |
| Plain Stack test | PASS | 12 of 12 single rows still win. 3 of 5 saved fives lose, and the two that win are shown. It does not hold for the kit, which is stated |
| Against plain attack | PASS | Wins two fights plain attack loses, and loses none it wins. Narrowly, and stated |
| Scaling | PASS | M 5.8 to 6.1 against 5.48 |
| The fight | PASS | Both stones fire on time, ward paid to the end, no cap hit |
| Reuse | PASS | Thinning Ward, proved in the main fight: Lintel 623 health without it, 647 with it |
| NPC use | PASS | Plain numbers on tags, each one Breakdown line |
| Counterplay | PASS | The panel's Wall, a fast killer, one realm up |
| Originality | PASS | Plain words |

## Fight Results

Input: `sheets/long-firing.fight.json`. Observations from `fight_x.py`, a paper model with expected values. No plug-ins.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical | 0 | Win | 5 s | 41 % | none |
| Typical | 1 | Loss, enemy on 98 % | 3 s | 0 | none |
| Typical | 2 | Loss, enemy on 100 % | 1 s | 0 | none |
| Top-end | 0 to 2 | Loss, enemy on 99 to 100 % | 1 s | 0 | none |

**Unmodelled:** rows 19 to 22, and element on a hit. Thần thức is costed here, not in the fight.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Tag key for modifiers | Needs key | The catalogue's one key shape. Rows 1, 18 |
| Own-health and cooldown conditions | Needs key | Rows 3, 6, 7, 16, 17 |
| Body guard and artifact count read at compile | Needs key | Rows 8, 15 |
| Stone Ward | Needs key | A ward record: `upkeep_share` |
| Two techniques, two arts | Needs key | Content, with an Earth tag on arts |

## Questions

1. Nothing prices a ward model. A Stone Ward at 10 % costs 6.2 % a pulse here, and the common ward in the same fight is empty by t = 5. Is that the intended gap between them?
2. The same W as plain attack comes close to this stack. Are health and body guard sized too low for their W, or is an empty L1 simply where a first 100 W belongs?
3. What `t_b` does a Huyền giai body technique give? It decides this build more than any row does.
4. Should the Ore Line get something Kiln cannot do? At the legal upkeep it has only speed.

## Also Considered

- **Above and below half health as the fork:** two catalogue rows that exclude each other. Dropped as the main fork because it repeats the Sword path's pool pair, and kept inside the lines.
- **Earth on the common ward, with more linh lực:** dropped, because every point of pool went to the ward and the third stone never came.
