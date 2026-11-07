# Way of Keeping (Thủ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Sketched in**: `sheets/incense-vigil.md` · **Order**: critic wave 3, order 3
> **Shape**: 19 branch nodes (10 stat lines, 8 passives, 1 art) and 2 keystones · **Fit**: 10 Fits today · 8 Needs key · 3 Needs rule

**Identity:** You are the door: you hold what you stand in front of, and you choose whether nobody gets past or nobody gets out.

**Requirement:** Earth at purity 40 and a `body` technique (rule 5). An auxiliary body technique counts.

**`theme_stats`:** `body_guard_pct`, `khi_huyet_pct`, `linh_luc_regen_pct`, `soul_res_pct`, `lifespan_years`.

**Changed from the sketch:** nothing in the requirement or `theme_stats`. The Gate gains Long Watch so that the second keystone has something to hit with.

## Branches

Stat lines are plain, stackable and sized at 8 W, a catalogue notable. Order is purchase order (rule 8).

### The Gate (Môn), 7 nodes

Standing in the way. Plain guard and health, with a fork at the end: node 5 serves a keeper who hits, node 7 a keeper who does not.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +8 `body_guard_pct` | Stat | 8.0 | Fits today |
| 2 | +6.5 `khi_huyet_pct` | Stat | 7.8 | Fits today |
| 3 | **Home Side (Chủ Vị).** +12 `body_guard_pct` when the other side opened the fight (Combat rule 10's requesting side) | Passive T1 | 10.0 | Needs key |
| 4 | +8 `body_guard_pct` | Stat | 8.0 | Fits today |
| 5 | **Long Watch (Trường Canh).** +50 points to hits on L5 once the fight has run 20 s. Conditional, art and basic. Second home: any build that outlasts | Passive T2 | 18.0 | Needs key |
| 6 | +6.5 `khi_huyet_pct` | Stat | 7.8 | Fits today |
| 7 | **Turned Blade (Đảo Phong).** Reused. With no hit to deal, half your L1 and L3 points add to `body_guard_pct` | Passive T2 | 18.0 | Needs rule |

### The Held Breath (Bế Khí), 6 nodes

The sea kept still. Regeneration and soul resistance, the one thing that skips a keeper's guard.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +1 `linh_luc_regen_pct` | Stat | 8.0 | Fits today |
| 2 | +6 `soul_res_pct` | Stat | 8.0 | Fits today |
| 3 | **Stale Incense (Trần Hương).** Reused, for anyone without the Sutra. Curse, `c_art` 0, cost 0.04, 3 s: enemy art costs +50 % for 5 pulses | Art T1 | 10.0 | Needs key |
| 4 | **Slow Smoke (Hoãn Yên).** Your curse-tag arts run 1 s shorter, never under `cooldown_min` | Passive T1 | 10.0 | Needs key |
| 5 | +1 `linh_luc_regen_pct` | Stat | 8.0 | Fits today |
| 6 | **Stored Breath (Tàng Tức).** +20 `soul_res_pct` while your linh lực share is above 90 %. Second home: any build that does not spend | Passive T2 | 18.0 | Needs key |

### The Long Count (Trường Số), 6 nodes

What standing costs. Plain years, and the passives that read the bill.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +13 `lifespan_years` | Stat | 7.8 | Fits today |
| 2 | **First Hundred (Sơ Bách).** The first 100 % of the ledger left at a fight's end costs no years. Reads Years Owed, so it is empty without Slow Wound | Passive T1 | 10.0 | Needs key |
| 3 | +13 `lifespan_years` | Stat | 7.8 | Fits today |
| 4 | **Kept Count (Thủ Số).** A stalemate you did not open lowers heart demon by 2. A caller effect on Combat rule 14's result | Passive T1 | 10.0 | Needs key |
| 5 | +13 `lifespan_years` | Stat | 7.8 | Fits today |
| 6 | **Fair Measure (Công Lượng).** Reused. 25 % fewer years owed | Passive T2 | 18.0 | Needs key |

## Keystones

One question: when someone comes to your door, what does your standing there mean? The Vow makes a stall a win. The Lock makes a stall impossible. Combat rule 10 names the same side in both, the one who came.

### Incense Vow (Hương Thệ), reused: nobody gets past

T3 and +4 `body_guard_pct`, 34 W. **Needs rule** (Combat rule 14, Edge Cases, AC-CB-62).

- **Opens:** a stalemate counts as a win for you when the other side is the requesting side.
- **Closes:** your hits deal nothing, basic attack included. It cannot apply when you opened the fight. Stalemates still fail a tribulation (Thiên Kiếp rule 8).

### Locked Gate (Tỏa Môn), new: nobody gets out

T3 and +4 `body_guard_pct`, 34 W. **Needs rule** (Combat rule 10, Time limit and Escape). A gate also keeps people in.

- **Opens:** when the other side is the requesting side, `time_limit` reads ×2 (`locked_limit_mult`, 80 s), and while you stand their escape channels end with no roll.
- **Closes:** you can never slot an escape art, in any fight. A stalemate at the longer limit takes the failure branch for you.
- **Bound:** one constant, one multiplier, and only in a fight you did not open, so a fight still ends. Under rule 4 this is a Combat cap shift, not a Character Stats ceiling.
- **Breakdown line:** "Gate locked: limit 80 s, escape barred."
- **Second home:** any sect's inner gate, any tick or sustain build that needs more than 40 s. It is the natural answer to The Best Plan, which wins by a Fled result, whenever that build is the one who came.

## Rule Change Asked

**This tree asks for a change to dao.md rule 1, which allows one keystone.** It has two, and a character may own one. Both sit behind rule 8's gate, one whole branch and one node in each other branch. Buying either closes the other for that life, and rule 8 already says a bought node is never refunded.

The wording around rule 1 follows it: rule 8 and the state table (Mastered would mean every node but the closed keystone), rule 12 (a Đạo may carry two signatures), and N and `C_dao` in Formulas D1. Proposed reading of the lint: it runs once per keystone with the closed one left out, so 19 branch nodes and 2 keystones list 21 nodes, own 20 and still cost 60 points. Three branches of 7 and two keystones would list 23, so 7, 7, 7 is no longer legal. Until the user rules, this tree does not pass rule 1.

## Lint (Formulas D1), First Guess

V̄ = 2 × 3 × 2.07 = 12.42 W. Both keystones are T3 with the same 4 W line, 34 W, so each owner reads the same.

| Part | Measure | Band | Result |
|---|---|---|---|
| 1, owning Incense Vow | 235.0 W over 20 nodes, mean 11.75 | 11.18 to 13.66 | inside |
| 1, owning Locked Gate | 235.0 W over 20 nodes, mean 11.75 | 11.18 to 13.66 | inside |
| 1, as listed (both keystones) | 269.0 W over 21 nodes, mean 12.81 | 11.18 to 13.66 | inside |
| 2, The Gate | 77.6 W over 7 nodes, mean 11.09 | 9.94 to 14.90 | inside |
| 2, The Held Breath | 62.0 W over 6 nodes, mean 10.33 | 9.94 to 14.90 | inside |
| 2, The Long Count | 61.4 W over 6 nodes, mean 10.23 | 9.94 to 14.90 | inside |
| 3, R(The Gate) to Incense Vow | 127.4 W over 10 nodes, mean 12.74 | at least 11.18 | inside |
| 3, R(The Gate) to Locked Gate | 127.4 W over 10 nodes, mean 12.74 | at least 11.18 | inside |
| 3, R(The Held Breath) to Incense Vow | 111.8 W over 9 nodes, mean 12.42 | at least 11.18 | inside |
| 3, R(The Held Breath) to Locked Gate | 111.8 W over 9 nodes, mean 12.42 | at least 11.18 | inside |
| 3, R(The Long Count) to Incense Vow | 111.4 W over 9 nodes, mean 12.38 | at least 11.18 | inside |
| 3, R(The Long Count) to Locked Gate | 111.4 W over 9 nodes, mean 12.38 | at least 11.18 | inside |
| 4, `body_guard_pct` | 20.0 W | no limit | no headroom rule |
| 4, `khi_huyet_pct` | 15.6 W | no limit | no headroom rule |
| 4, `lifespan_years` | 23.4 W | at most 45.0 W | inside |
| 4, `linh_luc_regen_pct` | 16.0 W | no limit | no headroom rule |
| 4, `soul_res_pct` | 8.0 W | no limit | no headroom rule |

**Where the W comes from, owning one keystone:** 39.0 W on F1 weights (17 %), 44.0 W at catalogue sizes on keys with no F1 weight (19 %), 152.0 W as tier credits for passives, arts and the keystone (65 %). Only the first part is a price. The rest is a first guess.

**Where the credit under-reads.** Turned Blade is credited 18 W, and the Vigil's sheet shows it worth +112 `body_guard_pct`, which is 112 W at Combat's 1 W a point. Stored Breath is credited 18 W and is about 27 W while it is on. The lint cannot see either. These are observations about the lint, not reasons to shave the nodes: Turned Blade works only for a side that deals nothing.

## Who Takes This Tree

A first buy can only be a branch opener (rule 8), so the table also names what the build is heading for. Reasons come from the sheets. No build was re-run on these nodes.

| Build | Keystone | Why | First buy | Heading for |
|---|---|---|---|---|
| The Incense Vigil | Incense Vow | Home tree. Guard shrinks the ledger, and Turned Blade is +112 guard to a saint with no hits. Route R(The Gate), 10 nodes, 30 points | The Gate 1, +8 guard | Turned Blade, the Vow, then Fair Measure |
| The Corner | Locked Gate | Earth is high, and the sheet says the body must last 7 s of a stronger enemy's fists. It wins at home, where the enemy is usually the one who came, so Home Side is on and a burned-dry enemy cannot leave. It needs an auxiliary body technique it does not yet hold | The Gate 1, +8 guard | Home Side, then the Lock |
| The Receiving Hand | None | Same guard and health lines its Way sells, for a sect of unarmed gatekeepers. Only with Earth at 40, and only as a third Way | The Gate 1, +8 guard | Home Side |
| Drink the Lightning | None | White Silence is a soul wave and the sheet has no `soul_res_pct`. Its regeneration is already at `regen_cap`, so the forced first buy is wasted. Neither keystone helps: a stalemate fails a tribulation, and the monk opens that fight | The Held Breath 1, +1 regeneration, clipped | The Held Breath 2, +6 soul resistance |

**Wanted, barred:** The Lucky Fool (Void root) carries Years Owed and would want First Hundred and Fair Measure, and has no Earth. The Best Plan could qualify, but its sheet refuses any Way.

**Locked Gate has no home build tonight.** The Corner borrows it. A warden who outlasts and then finishes is an open seat, and Long Watch is the first node written for them.

## Rule Checks

- **Stat lines:** theme stats only.
- **Passives in one tree:** checked against every Đạo in the sheets. Someone Else's Problem stays in Chance, Terror in its hidden cluster, Still Sea and Iron Marrow in Unmoved Body.
- **No ceiling raise:** `lifespan_years` lines total +39 years, under Core Formation's 75. With the Sutra's +15 that is 54, still under. The ceiling is character-wide, so a second source can clamp it.
- **Name hidden:** guard, a home side, a long watch, smoke, a held breath, a count of years. It reads as someone posted at a door. Threshold's gates differ: there, you are the one outside.
- **Art node:** Stale Incense is designed under the 2026-11-07 decision and waits for the fight to be built, so the Held Breath is one node short until then.

## Not Tested

No fight was run for this tree. Locked Gate, Long Watch, Home Side and Stored Breath have no plug-in, and no number here comes from the calculator. The Vow's own results are in `sheets/incense-vigil.md`. Open: does Locked Gate's escape bar stop a talisman escape as well as an art? Written as both.
