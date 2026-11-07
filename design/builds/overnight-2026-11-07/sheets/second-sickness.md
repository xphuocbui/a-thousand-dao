# The Second Sickness (Kiêm Bệnh)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: The Plain Stack for Poison: ordinary nodes, no enabler, 0 rule asks, two rival lines on a 30-node path.
> **Direction**: One poison, then a choice of where the second sickness goes: into the blood or into the breath.
> **Realm span**: Foundation Establishment to Core Formation · **Power level**: ordinary · **Use**: player path, NPC poisoners
> **Fit**: 6 Fits today · 17 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the technique's bonus budget cannot read tagged keys)

## The Spine

- **The channel:** ticks, inside the ward, on L1 to L4. No crit, no L5.
- **The enabler:** none. Two ordinary arts and 30 nodes.
- **The loop:** two thin doses every 1.9 s until the pool is gone, then the sickness runs on without you.
- **The engine:** one status stops at 5 % of health a pulse and all ticks stop at 8 %, so the second status is worth 3 % a pulse that no amount of Poison damage can buy.
- **The sacrifice:** no crit, a cheap weapon, two art slots left empty, and no way to fight upward.
- **The arc:** at Foundation it barely survives its own clock. At Core the same path has room to spare, and the second sickness becomes a convenience.

## The Legend

Yên Thảo grew medicine on three plots above a hill town, and nursed their father through a fever that came with a wasting cough. Either one alone he would have thrown off. It was together that they took him, slowly, over one winter, and Yên Thảo sat beside him for all of it and learned exactly how a body fails when it has to fight in two places.

They took up cultivation late and without talent, because a man with a sword had begun collecting grain from the town and nobody else was going to stop him. They have never been good at fighting. They give a small dose, then another, and then they stand in front of the blows for as long as they can, frightened, saying they are sorry. The healers of the valley will not eat with them. Yên Thảo thinks that is fair.

## How It Fights

Thin Dose and Bone Steam land together every 1.9 s. Each is a weak hit that may leave a stack. For nine seconds the ward takes the blows while the pool falls. The last Bone Steam goes in at 7.6 s, the last Thin Dose at 9.5 s, and at 9 s the pool is dry. From there the two statuses run out on their own, and the last Bone Steam ticks for the final time at the 12 s pulse, which is the pulse that ends the fight. Ticks are 56 % of the health removed and the basic attack 32 %.

**Signature moment:** at 10 s you have no linh lực and no ward, you are on 19 % health and they are on 18 %. You have nothing left to cast. Two seconds later they fall down.

## The Stack

Read top to bottom as a walk across the Meridian Map. **Take** is what this build opens: `3 + 1` is three acupoints and one notable. **Size** is small / notable, from the catalogue where a row exists. Sizes on new rows are first guesses.

### The common road: 14 nodes, both lines

| # | Node | Take | Size | Total | Effect | Form | Layer | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Poison damage (Độc Thương) | 3 + 1 | +2.5 / +15 | +22.5 | Ticks with the poison tag. Bigger than row 2, narrower | Increased | L1 | ○ catalogue |
| 2 | Damage over time (Trì Thương) | 2 + 1 | +2 / +12 | +16 | Every over-time status, so it also feeds the second one | Increased | L1 | ○ catalogue |
| 3 | Status chance (Trúng Suất) | 3 + 1 | +1 / +6 | +9 | Base 50 % a dose becomes 59 % | Increased | none | ○ catalogue |
| 4 | Poison art cost (Tiết Dược) | 2 + 0 | −1 / −6 % | −2 % | The catalogue's "any one tag" cost row | Increased | none | ○ catalogue |
| 5 | Long Simmer (Cửu Tiên) | notable | +10 | +10 | Over-time statuses with an authored duration of 4 or more | More | L2 | ○ new |

### The fork: 16 nodes, choose one

**Into the Blood (Nhập Huyết)**, taken here. The second status is a health tick, so the road reaches for the 8 % ceiling and then spends itself on living.

| # | Node | Take | Size | Total | Effect | Form | Layer | Status |
|---|---|---|---|---|---|---|---|---|
| 6 | Status duration (Trì Cửu) | 1 + 1 | +2 / +12 % | +14 % | Rounds to the nearest pulse: 4 becomes 5, so the last dose outlives the pool | Increased | none | ○ catalogue |
| 7 | Complication (Biến Chứng) | notable | +12 | +12 | An over-time status applied to a target already carrying another. Read at application, so slot order matters | Conditional | L2 | ○ new |
| 8 | Sick Body (Bệnh Thể) | notable | +2 per stack | up to +20 | Hits, per status stack on the enemy. Stacks past the cap still count here | Per | L2 | ○ new |
| 9 | Body guard (Hộ Thể) | 0 + 1 | +1.2 / +8 | +8 | `body_guard_pct` | Increased | none | ● |
| 10 | Maximum health (Khí Huyết) | 2 + 1 | +1 / +6.5 | +8.5 | `khi_huyet_pct` | Increased | none | ● |
| 11 | Ward strength (Hộ Lực) | 1 + 1 | +1.2 / +8 | +9.2 | `defense_pct` | Increased | none | ● |
| 12 | Ward efficiency (Hộ Hiệu) | 2 + 0 | +1.2 / +8 | +2.4 | `ward_efficiency_pct` | Increased | none | ● |
| 13 | Maximum linh lực (Linh Hải) | 2 + 0 | +1.2 / +8 | +2.4 | `linh_luc_pct` | Increased | none | ● |
| 14 | Regeneration (Hồi Khí) | 2 + 0 | +0.15 / +1 | +0.3 | `linh_luc_regen_pct` | Increased | none | ● |

**Into the Breath (Nhập Khí)**, the rival. The second status burns linh lực on its own cap, so the road stops their ward and their arts, then finishes with hits. Saved as `variants/second-sickness-breath-mixed.fight.json`.

| # | Node | Take | Size | Total | Effect | Form | Layer | Status |
|---|---|---|---|---|---|---|---|---|
| 15 | Burn damage (Thiêu Khí) | 3 + 1 | +2.5 / +15 | +22.5 | Qi burn statuses | Increased | L1 | ○ new |
| 16 | Basic attack damage (Bình Kích) | 2 + 1 | +2 / +12 | +16 | The basic attack | Increased | L1 | ○ catalogue |
| 17 | Damage to an enemy with no linh lực (Khô Hải) | 1 + 1 | +2.5 / +15 | +17.5 | Hits, while they are below 5 % of their pool | Conditional | L1 | ○ catalogue |
| 18 | Bare Vessel (Lộ Đỉnh) | notable | +25 | +25 | Reused. The notable grade, above the roads' other Conditional notables: see the note under Matchups | Conditional | L5 | ○ reused |
| 19 | Wasting (Hao Tổn) | notable | +0.2 per 1 % | up to +20 | Hits, per 1 % of the enemy's linh lực missing | Per | L2 | ○ new |
| | Rows 10, 14, 11 | 2 + 0, 2 + 0, 1 + 0 | | | The rival keeps only 5 survival nodes | | | |

### Off the path

| # | Node | Size | Effect | Form | Layer | Status |
|---|---|---|---|---|---|---|
| 20 | Held Acres (Tích Điền) | +7 per plot, 3 plots | +21 on over-time statuses. Reused from The Corner, taken here unplanned, carried by a garden and not by a node | Per | L2 | ○ reused |
| 21 | Corpse-Wax Coating (Thi Lạp) | +20 | Foreseen fights only. Reused from The Burial Shroud | More | L4 | ○ reused |
| 22 | Poison art speed (Tốc Dược) | +1 / +6 | The catalogue's "any one tag" speed row. On the road, not taken: the cooldown already lands before the pulse | Increased | none | ○ catalogue |

**The first small choice.** Poison damage is +15 and Damage over time +12, and only the second reaches Bone Steam or the burn. It is the fork in miniature, met on the first day.

**Identity piece:** none, on purpose. The nearest thing is Bone Steam, the art at the fork: `--without bone_steam` on the home fight loses at 12 s with the enemy on 23 %.
**Empty rungs:** crit, a sacrifice, since ticks cannot use it. L5, a sacrifice on this line. Past the cap is filled by rows 6, 8 and 9 to 14, with no cap shift and no overflow.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | Poison 48.5, Bone Steam 26, hits 10 | ×1.49, ×1.26, ×1.10 | General 10, rows 1 and 2 |
| L2 | Poison 31, Bone Steam 43, hits up to 20 | ×1.31, ×1.43, up to ×1.20 | Rows 5, 7, 8 and 20 |
| L3 | 20 | ×1.20 | A cheap weapon. The money went on the ward |
| L4 | 0 | ×1.00 | Empty in a blind fight. Row 21 when foreseen |
| L5 | 0 | ×1.00 | Ticks cannot use it |

## The New Test

Home fight: `variants/second-sickness-mixed.fight.json`, the mixed enemy at the same realm: **a win at 12 s on 10 % health, with the enemy on 18 % at t = 10.** A row is removed whole, every node of it, which is harder than losing one node. Each file below is `variants/second-sickness-[name].fight.json`. Enemy at t = 10 comes from `--timeline`.

**Remove any one: all 15 still win.**

| Removed | File | Result | Own health left | Enemy at t = 10 |
|---|---|---|---|---|
| Nothing | `mixed` | Win, 12 s | 10 % | 18 % |
| Poison damage | `no-poison` | Win, 13 s | 6 % | 21 % |
| Damage over time | `no-dot` | Win, 13 s | 6 % | 23 % |
| Status chance | `no-chance` | Win, 14 s | 2 % | 25 % |
| Poison art cost | `no-cost` | Win, 12 s | 7 % | 18 % |
| Long Simmer | `no-simmer` | Win, 13 s | 6 % | 21 % |
| Held Acres | `no-acres` | Win, 13 s | 6 % | 25 % |
| Status duration | `no-duration` | Win, 13 s | 6 % | 18 % |
| Complication | `no-complication` | Win, 12 s | 10 % | 20 % |
| Sick Body | `no-sick` | Win, 13 s | 6 % | 21 % |
| Body guard | `no-guard` | Win, 12 s | 9 % | 18 % |
| Maximum linh lực | `no-pool` | Win, 12 s | 4 % | 18 % |
| Maximum health | `no-health` | Win, 12 s | 4 % | 18 % |
| Ward strength | `no-ward` | Win, 12 s | 10 % (18 %, not 21 %, at t = 9) | 18 % |
| Ward efficiency | `no-eff` | Win, 12 s | 6 % | 18 % |
| Regeneration | `no-regen` | Win, 13 s | 8 % | 21 % |

No row is dead, and none helps when removed. Status chance is the widest move: it costs 2 s and 8 points of health, and it is still a win.

**Remove five: 5 of 6 saved sets lose.**

| Removed | File | Result |
|---|---|---|
| Poison, Over time, Chance, Simmer, Acres | `five-damage` | Loss at 15 s, enemy on 14 % |
| Guard, Pool, Health, Ward strength, Regeneration | `five-survival` | Loss at 12 s, enemy on 2 % |
| Poison, Chance, Pool, Health, Sick Body | `five-mixed` | Loss at 10 s, enemy on 26 % |
| Duration, Complication, Sick Body, Guard, Efficiency | `five-line` | Loss at 10 s, enemy on 18 % |
| Poison, Over time, Chance, Cost, Simmer | `five-trunk` | Loss at 14 s, enemy on 10 % |
| The five gentlest singles: Complication, Ward strength, Guard, Cost, Efficiency | `five-gentlest` | **Still a win, 12 s on 1 % health** |

So the test does not pass cleanly: the five gentlest rows survive by one point. In my scratch scans, tunings that made them lose also let one single row take the win down to nothing, so I kept the singles safe and left this exception standing.

**This is a tuned point.** The base stats were chosen by a scan so that no row is dead and every single removal wins, and the thin margin is what makes the test bite. Moving health and ward a little keeps the shape: `nudge-weak` wins on 8 %, `nudge-strong` on 13 %. A stronger character would have room to lose five rows, and would prove less.

## Why the Pieces Multiply

- **Ramp:** chance × Poison × Over time × Simmer × Acres sets how fast stacks reach the cap. The pulse cap clipped only 3 times in the home fight, so the stack sits just under it, and each of these rows is worth about a second.
- **Lasting:** pool × efficiency × regeneration × art cost sets when you go dry. Health × guard × ward strength sets what the last seconds cost.
- **A second late costs about 4 points of health** (12 s on 10 %, 13 s on 6 %). So a damage row and a survival row trade in the same coin, which is why five from any mix usually lose.
- **A dose at 1.9 s lands before the pulse.** At 2.0 s it lands just after and ticks a second later: `on-beat` wins at 13 s on 6 %, with the enemy on 26 % at t = 10. That is what one authored tenth of a second costs.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood and Earth, any ordinary purity | Earth for plots, Wood for herbs. Nothing here needs purity |
| Key talents | None | The point is that nobody special can walk it |
| The Way (Đạo) | None | Way of Poison would suit it, but no node is needed |

Sense and fortune are not used. Enemy sense stays at the default 1.0.

## Arts

All from one ordinary tier 2 secret technique, Two-Column Materia (Lưỡng Lan Bản Thảo), with no bonuses. 2 of 4 slots are used.

| Art | Kind, tags | c_art | Cost | Cooldown | Applies | Fit |
|---|---|---|---|---|---|---|
| Thin Dose (Bạc Tễ) | Qi, hit, poison | 0.8 | 0.04 | 1.9 s | Poison: body tick, c_tick 0.15, 4 pulses, 50 % a stack | Needs key |
| Bone Steam (Cốt Chưng) | Qi, hit, over time | 0.8 | 0.04 | 1.9 s | Bone-steam heat: qi tick, no poison tag, the same numbers | Needs key |
| Wasting Thirst (Tiêu Khát) | Qi, hit, over time | 0.8 | 0.04 | 1.9 s | Thirst: qi burn, the same numbers. Replaces Bone Steam on the rival line | Needs key |

**Description:** a medicine given at the wrong hour.

## Tree and Clusters

The road is ordinary base-map ground. Sick Meridians (Bệnh Mạch), already in the catalogue, is the natural sealed home for rows 1, 2 and 5. At catalogue W the 27 priced nodes cost 80 W, and rows 5, 7 and 8 are unpriced (Open Question 5). The rest of the character costs about 149 W, for 229 of 248 W at Foundation. Ward gear of 4 units carries most of the ward.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation | A 12 s race won by a few points | The fork | The grain collector falls down outside the mill |
| Core | A 13 s fight on 29 % health (`core-mixed`, guessed stats) | More of the same rows | Other towns start to send for them, and they wish they would not |

At Core, `core-mixed --without bone_steam` still wins at 16 s on 16 %, so the second sickness is no longer needed there. Those stats are my guess at how 199 more W gets spent.

## Matchups

The fork is a choice only if each line wins something the other loses. Same base stats, 30 nodes each.

| Enemy | Into the Blood | Into the Breath | Files |
|---|---|---|---|
| Mixed | Win 12 s, 10 % left | Win 11.4 s, 22 % left | `mixed`, `breath-mixed` |
| One cheap art (jab) | Win 12 s, 20 % left | Win 11.4 s, 23 % left | `jab`, `breath-jab` |
| Heavy caster, two dear arts | **Loss 9 s, enemy on 30 %** | **Win 12 s, 22 % left** | `heavy`, `breath-heavy` |
| Cleanser, clears 2 statuses every 4 s | **Loss 16 s, enemy on 14 %** | **Win 12 s, 15 % left** | `cleanse`, `breath-cleanse` |
| Fist, no arts, basic attack 2.2 | **Win 12 s, 27 % left** | **Loss 14 s, double knockout on overkill** | `fist`, `breath-fist` |
| Deep sea, pool n 2.2 | Loss 9 s, enemy on 31 % | Loss 9 s, enemy on 43 % | `deep`, `breath-deep` |
| Ward wall, ws 250, pool n 2.4 | Loss 9 s, enemy on 51 % | Loss 9 s, enemy on 67 % | `wall`, `breath-wall` |
| Heavy body guard | Loss 15 s, enemy on 54 % | Loss 16 s, enemy on 35 % | `guarded`, `breath-guarded` |
| Mixed, one realm up | Loss 4 s, enemy on 94 % | not run | `mixed --gap 1` |

**Plainly, Into the Breath is the better line on most of this table.** It wins two fights Blood loses, and Blood wins one back. Ticks are 56 % of Blood's health damage and 26 % of Breath's, so Breath is really a hit build opened by poison. This sheet builds Blood because it is the Poison path as asked, not because it is stronger.

**Bare Vessel's grades, stated plainly.** One modifier, four sizes tonight: +2.5 as an acupoint, +25 as a notable here, +30 lesser grade and +80 greater grade on techniques and sealed clusters. The roads' other Conditional notables are +10 to +15, so +25 is out of line. It is not what makes Breath good. Run at +15, every Breath fight above ends the same (each file `breath-[enemy]-bv15`), and the only change is that `breath-guarded-bv15` loses with the enemy on 39 %, not 35 %. The number stays here because that bar moves, and the rework can take +15.

I expected the ward wall to favour Blood outright, since ticks ignore wards. It does not: both die at 9 s, and Blood only gets further.

**Counter:** any enemy that does not run out. The home win leans on the mixed enemy going dry, and `deep` shows the same build dead at 9 s against a bigger pool. A heavy body guard or a cleanser also beats it.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Art lint within for all three (0.80 against 1.70). Slots 2 of 4. Status lint 0.6 within 2.04. The technique has no bonuses, and tagged keys sit outside `bonus_pool` |
| Validity | PASS | Realm `truc_co`, ward at the top-end anchor's pass and drain, c_tick 0.15 at the bottom of its range, duration 5 inside 2 to 6 |
| Stack | PASS | 15 rows in the build across Increased, More, Conditional and Per. L5 and crit named as sacrifices |
| Scaling | PASS | INFO: `m_static` 1.32 against a typical 4.19, on purpose. Tick M is 2.33 on Poison |
| The fight | PASS | Home win, the loop happens, pulse cap clipped 3 times, own dry at 9 s |
| Reuse | PASS | Held Acres used unplanned and proved (`no-acres`: 13 s on 6 %). Bare Vessel, Corpse-Wax Coating and Sick Meridians reused |
| NPC use | PASS | Every row is a number a generator can buy |
| Counterplay | PASS | Cleanser, heavy caster, deep pool, heavy guard |
| Originality | PASS | Names are ordinary medical terms |

## Fight Results

Input: `sheets/second-sickness.fight.json`. Observations from `fight_x.py`, a paper model with expected values, not the game.

| Enemy | Gap | Result | Time | Own left | Cap hits |
|---|---|---|---|---|---|
| Typical fixture | 0 | Win | 11 s | 42 % | pulse cap 2 |
| Typical fixture | 1 | Loss, enemy on 94 % | 4 s | 0 | |
| Typical fixture | 2 | Loss, enemy on 99 % | 2 s | 0 | |
| Top-end | 0, 1, 2 | Loss | 1 s | 0 | |
| Mixed, home | 0 | Win | 12 s | 10 % | pulse cap 3 |
| Mixed, foreseen with Corpse-Wax, no ground (`foreseen`) | 0 | Win, enemy on 12 % at t = 10 | 12 s | 10 % | |
| Slots swapped, Bone Steam first (`slot-swap`) | 0 | Win, enemy on 20 % at t = 10 | 12 s | 10 % | |

**Unmodelled:** the enemy's `status_resist_pct`, which would make Status chance worth more. Stacks are expected fractions. Status duration is rounded by hand before it goes in the file.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Rows 1 to 8, 15 to 17, 19, 22 | Needs key | Tagged modifier keys (catalogue, To settle). Status duration needs a stated rounding: nearest pulse |
| Three arts, one technique | Needs key | The arts catalogue |

## Questions

- Into the Breath wins most of the table. Is that a fair price for needing the enemy to have a pool, and should Bare Vessel on a notable be +15 anyway, since that changes no result but one lost fight's bar?
- Should a percentage on a whole-number duration round to the nearest pulse? It makes +14 % worth a whole pulse on a duration of 4.

## Also Considered

- **One Deep Sickness (Đơn Phương):** one status and no second art, a 20-pulse clock. It cannot outlive the enemy here: see `no-second`, a loss at 12 s with the enemy on 23 %.
- **Three statuses:** nothing past the 8 % ceiling, and a third art spends the ward.
