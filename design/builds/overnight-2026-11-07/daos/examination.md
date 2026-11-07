# The Way of the Examination (Khoa Cử Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. All W and sizes on new content are first guesses.
> **Seeds:** 61 (a doctrine for a thousand disciples) and 71 (comprehension as the damage stat). New. No sheet exists for it yet.

- **Requirement:** a main or body technique, and no element. Anyone who has learned a manual can walk it, which a doctrine needs. This fits rule 5 as a technique kind.
- **`theme_stats`:** `ngo_tinh`, `dao_tam`, `tam_ma_resist_pct`, `mission_income_pct`.
- **Identity:** you read until reading became a blade, and then you decide whether to be the best or to teach.
- **Shape:** 21 nodes: branches of 7, 6 and 6, and two keystones, of which a character owns one. A character buys 20, so a full Way costs the default 60 points. 9 stat lines, 8 passives, 2 arts in the branches. With the name hidden, a player reads a schoolroom and a posted list. It differs from the Way of Ink, which also holds `ngo_tinh`: Ink copies other people's work, and this sits the paper.

## How Comprehension Becomes Damage

Three plain steps, each usable alone.

1. **Clear Reading** is Dull Fortune's mirror. Dull Fortune pays for comprehension under 50. This pays for comprehension over it: at 100, +60 points on L2. At the clamp of 150, +120.
2. **The lead.** Set Question and Model Answer read how far your comprehension passes the target's. Every compiled side needs a `ngo_tinh`, and one with none reads the talent mean of 45.
3. **First on the List** replaces L1 outright. See below.

## Branches

### The Classics (Kinh Thư)

What has been read. 7 nodes, 75.5 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +2 `ngo_tinh` | Stat line | Plain line | 10 |
| 2 | **Clear Reading (Minh Duyệt)** | Passive T2 | +1.2 points to arts per point of comprehension above 50, to +120 (L2). Dull Fortune's mirror. | 18 |
| 3 | +5 % `tam_ma_resist_pct` | Stat line | Plain line | 7.5 |
| 4 | **Well-Thumbed (Thục Độc)** | Passive T1 | +2 points to your main technique's arts per layer it has reached, to +30 (L2). | 10 |
| 5 | +2 `ngo_tinh` | Stat line | Plain line | 10 |
| 6 | **Commentary (Chú Giải)** | Passive T1 | +8 points to arts per different enemy art seen this fight, to +40 (L5). | 10 |
| 7 | **Night Oil (Dạ Đăng)** | Passive T1 | `mastery_idle_frac` is 0.6 for your main technique, not 0.5. | 10 |

### The Paper (Quyển)

The fight as an examination. 6 nodes, 71.5 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +5 % `tam_ma_resist_pct` | Stat line | Plain line | 7.5 |
| 2 | **Set Question (Xuất Đề)** | Art T1 | No hit, cost 0.04, cooldown 2 s. A curse for 3 pulses: the target loses L2 points equal to half your comprehension lead, to −30, never below 0. | 10 |
| 3 | +2 `ngo_tinh` | Stat line | Plain line | 10 |
| 4 | **Long Essay (Trường Sách)** | Art T2 | Qi hit, c_art 2.7, cost 0.10, cooldown 3 s: exactly at the art lint. | 18 |
| 5 | +1.6 `dao_tam` | Stat line | Plain line | 8 |
| 6 | **Model Answer (Phạm Văn)** | Passive T2 | The first art you fire in a fight gains +1 point per point of comprehension lead, to +60 (L5). | 18 |

### The Posted List (Bảng)

Rank, office and pupils. 6 nodes, 62.4 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1.6 `dao_tam` | Stat line | Plain line | 8 |
| 2 | **Proctor's Eye (Giám Thí)** | Passive T1 | At t = 0 the Breakdown shows the enemy's comprehension and slot order. | 10 |
| 3 | +12 % `mission_income_pct` | Stat line | Plain line | 8.4 |
| 4 | **Open Lecture (Khai Giảng)** | Passive T1 | A season spent lecturing adds pupils: 5 × your comprehension ÷ 45, rounded down. A pupil is a number, not a person. Each pays 1 stone a year. Each year with no lecture, a tenth leave. | 10 |
| 5 | +1.6 `dao_tam` | Stat line | Plain line | 8 |
| 6 | **Listed Name (Đề Danh)** | Passive T2 | +40 points to hits while no living cultivator of your realm in the World Database has higher comprehension than you (L5). | 18 |

## Keystones

A character owns one. Each is T3 with a 4 W line, 34 W. The choice is the old one for anyone who reads: be the best, or pass it on.

### First on the List (Bảng Thủ), new: the scholar

- **Line:** +0.8 `ngo_tinh`.
- **Opens:** your L1 is 2 points per point of comprehension, and nothing else. Combat's soft start and `cap_1` still apply. Comprehension 100 gives x1 200, ×3.00. The clamp of 150 gives x1 300, read as 250, ×3.50.
- **Closes:** `attack_pct` and every Increased damage line no longer count, so W already spent on them is lost. And **Clever Harm (Thông Họa):** −1 `khi_van` per point of comprehension above 50, to −40. This is the second half of Dull Fortune's mirror: the dull are lucky, and the clever are not.
- **What it does to a life:** at Core Formation, comprehension 100 matches a top-end's L1 (45 % of 447 W, about ×3.00) and leaves all that W free for health and ward. By Deity Transformation a top-end's L1 reads about ×4.64 (45 % of 1,172 W), and the scholar still has ×3.00 to ×3.50. So it peaks early and is overtaken: the prodigy who was ahead of everyone at forty.

### Peach and Plum (Đào Lý), new: the teacher

*Đào lý mãn thiên hạ:* peach and plum across the world, a teacher's students.

- **Line:** +0.8 `ngo_tinh`.
- **Opens:** once a life you write the Text, and it records your comprehension then as the Standard, S. Any disciple or sect member holding this Way reads `max(own, S)` in this tree. You gain +1 point to hits per 20 living pupils, to +50 at 1,000 (L4). It was taught, not coated, so a blind fight keeps it.
- **Closes:** S never moves. Within this tree you read S too, however much you learn after. Pupils need Open Lecture's seasons, or a tenth leave each year.
- **NPCs:** rule 11 gives an NPC a multiplier, not a tree, so reading S needs a line there: an NPC holding this Way under a Text multiplies its Way effect by `1 + (S − 45) ÷ 400`. S 100 gives ×1.14, the same shape as `comp_strength` at half its slope.

## The Doctrine Test

A thing taught to a thousand must work for the median pupil, so I checked the tree at comprehension 45, the talent mean.

- **Without a Text:** Clear Reading pays 0 and every lead is 0. Well-Thumbed, Commentary, Long Essay and the stat lines all work, and Listed Name is out of reach. That is a modest, ordinary Way, and most of its nodes are plain.
- **With a Text at S 100:** the same pupil reads 100, so Clear Reading pays +60 and leads open. That is the doctrine: the gift lives in the Text and not in the pupil.
- **The gap:** NPCs hold a Đạo only from Core Formation, so a thousand Foundation pupils hold no Way at all, and the Text reaches them only as the teacher's +50. Whether a Text may reach below Core is the main question here for the user. As written, the thousand are a number on the teacher's sheet, and only the Core disciples are the doctrine in fact.

## Rule Changes Asked

1. **dao.md rule 1 allows one keystone. This tree has two.** The ask: a Đạo may hold one or two keystones, a character may own one, and buying either closes the other for that life. The lint runs once per keystone with the closed one left out, and `C_dao` counts the nodes a character can own. This tree also passes with both counted.
2. **First on the List, Combat Formulas B:** a keystone may set x1 from a talent, read at compile. No read during a fight is needed.
3. **Peach and Plum, dao.md rule 11:** the NPC line above. Pupils are a new per-character count. The master and disciple ties in Quests rule 16 can carry the named few.

Everything else needs a key at most: `ngo_tinh` on a compiled profile, a Per on it, and the World Database read for Listed Name.

## Lint (Formulas D1), First Guess

Priced by Meridian Map F1: `ngo_tinh` 5 W, `tam_ma_resist_pct` 1.5 W, `mission_income_pct` 0.7 W. `dao_tam` has no weight anywhere, so it is a *guess* at 5 W, the other talents' price. Passives and arts use `credit(T)`, itself a *guess*, and every branch rests on unpriced modifiers, so all sums below are first guesses. V̄ 12.42.

| Part | Check | Sum | Band | Result |
|---|---|---|---|---|
| 1 | Whole tree, all 21 nodes listed | 277.4 W ÷ 21 = 13.21 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with First on the List | 243.4 W ÷ 20 = 12.17 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with Peach and Plum | 243.4 W ÷ 20 = 12.17 | 11.18 to 13.66 | pass |
| 2 | Branch The Classics | 75.5 W ÷ 7 = 10.79 | 9.94 to 14.90 | pass |
| 2 | Branch The Paper | 71.5 W ÷ 6 = 11.92 | 9.94 to 14.90 | pass |
| 2 | Branch The Posted List | 62.4 W ÷ 6 = 10.40 | 9.94 to 14.90 | pass |
| 3 | R(The Classics), First on the List | 75.5 + 7.5 + 8 + 34 = 125 W ÷ 10 = 12.50 | at least 11.18 | pass |
| 3 | R(The Classics), Peach and Plum | 75.5 + 7.5 + 8 + 34 = 125 W ÷ 10 = 12.50 | at least 11.18 | pass |
| 3 | R(The Paper), First on the List | 71.5 + 10 + 8 + 34 = 123.5 W ÷ 9 = 13.72 | at least 11.18 | pass |
| 3 | R(The Paper), Peach and Plum | 71.5 + 10 + 8 + 34 = 123.5 W ÷ 9 = 13.72 | at least 11.18 | pass |
| 3 | R(The Posted List), First on the List | 62.4 + 10 + 7.5 + 34 = 113.9 W ÷ 9 = 12.66 | at least 11.18 | pass |
| 3 | R(The Posted List), Peach and Plum | 62.4 + 10 + 7.5 + 34 = 113.9 W ÷ 9 = 12.66 | at least 11.18 | pass |
| 4 | Key headroom, branch lines | `ngo_tinh` 30 W, `tam_ma_resist_pct` 15 W, `dao_tam` 24 W, `mission_income_pct` 8.4 W | No key here is a rule 14 ceiling key or `cultivation_speed_pct`, so none has a limit | pass |

## Who Takes This Tree

| Build | Keystone | Why | First node |
|---|---|---|---|
| The Level Ground | First on the List | Comprehension is its first talent. Its own law caps L2, L3 and L5 for both sides and leaves L1 alone, so an L1 that costs no W is the one layer nobody on that ground can match. Fortune means little to someone who fights at home | Classics 1, +2 `ngo_tinh`, then Clear Reading only as far as the 40 its law allows |
| The Long Carry | Peach and Plum | It is already one doctrine for a thousand roots, and its disciples sit at comprehension 20. The founder needs the comprehension. The disciples do not | Posted List 1, +1.6 `dao_tam`, for Open Lecture at node 4 |
| The Wedding Furnace | None | Comprehension is a key talent, and its Way is free. It wants The Classics for Clear Reading on its courses, and it stops short of First on the List, whose price would ruin the fortune its alchemy crits read | Classics 1, then Clear Reading |
| The Kept Hearth | None | Comprehension is its key talent, and it has a second glimpse to spend. The Classics only | Classics 1, then Clear Reading |

The Lucky Fool can never take this: comprehension 10, on purpose. No campaign build yet rests on First on the List alone. The scholar the order names still wants a sheet.

## Rule Checks

- **Stat lines** use only `theme_stats`. **No ceiling raises:** Night Oil moves a mastery share, and First on the List stays under `cap_1`.
- **Rule 4 has a gap this tree leans on.** `ngo_tinh` is not a rate key, so the D1 lint gives it no limit, yet it feeds Character Stats' `comp`, and so cultivation speed. The full +6.8 here moves `comp` from 1.225 to 1.259, about +2.8 %, inside the 10 % `dao_rate_cap_pct` by a wide margin. It also adds 0.34 pp through `k_n` on pill attempts, and the +4.8 `dao_tam` adds 0.12 pp through `k_d`. Both count under the q-extras ceiling. AC-DAO-10 should cover them.
- **Passives in one tree:** none of the eight is in another Way, checked against the sheets and `daos/`. All are new, which is why this tree holds no reused names beyond the Dull Fortune it mirrors.
- **Long Essay** sits exactly at the art lint: `art_lint_max(0.10, 3)` is 2.70.
- **Art nodes** are designed, not added to data until the fight is built (system-roles.md). Set Question has no hit, so no lint.

## Not Tested

No fight was run on this tree. All sizes are unproven, the ×2 of First on the List above all. The 1,000-pupil figure is untested against any rating. `rules/mass_rating.py` is there when someone proves it.
