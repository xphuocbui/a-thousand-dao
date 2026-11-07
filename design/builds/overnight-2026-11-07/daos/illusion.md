# Illusion (Huyễn Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. All W and sizes on new content are first guesses.
> **Brought up from:** the sketch in `sheets/understudy.md`. Illusion is in the catalogue of 22 and has no tree.

- **Requirement:** Water at purity 30.
- **`theme_stats`:** `evade_pct`, `than_thuc_pct`, `linh_luc_regen_pct`, `mi_luc`.
- **Identity:** what they struck was never you, or what struck them was never there.
- **Shape:** 21 nodes: branches of 6, 7 and 6, and two keystones, of which a character owns one. A character buys 20, so a full Way costs the default 60 points. 9 stat lines, 8 passives, 2 arts in the branches. With the name hidden, a player reads a playhouse: masks, a script, an audience.

## Branches

### The Mask (Diện)

The face they aim at. 6 nodes, 61.8 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +2.5 % `evade_pct` | Stat line | Plain line | 8 |
| 2 | **Costume Change (Cải Trang)** *(reused, Understudy)* | Art T2 | No hit, tag illusion, cost 0.06, cooldown 1 s. Adds 1 to your evade count, under `count_rate` and the thần thức ratio. Does nothing without a count. | 18 |
| 3 | +6 % `than_thuc_pct` | Stat line | Plain line | 7.8 |
| 4 | **Quick Change (Tốc Biến)** | Passive T1 | Arts with the illusion tag cost 15 % less. | 10 |
| 5 | +1 % `linh_luc_regen_pct` | Stat line | Plain line | 8 |
| 6 | **Painted Screen (Họa Bình)** *(reused, Understudy)* | Art T1 | No hit, tag illusion, cost 0.08, cooldown 2 s. As Costume Change. | 10 |

### The Script (Bản)

Knowing the next line. 7 nodes, 71.8 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1 % `linh_luc_regen_pct` | Stat line | Plain line | 8 |
| 2 | **Rehearsal (Diễn Tập)** *(reused, merged)* | Passive T2 | Foreseen fights only: you choose where each of your counts starts, up to what it holds. This is Dress Rehearsal and Rehearsal as one piece. | 18 |
| 3 | +6 % `than_thuc_pct` | Stat line | Plain line | 7.8 |
| 4 | **Cue (Nhập Tràng)** *(reused, Understudy)* | Passive T1 | A guard: true in an instant when a hit landed on a double or was evaded. The art fires in the follow-up instant. | 10 |
| 5 | +2.5 % `evade_pct` | Stat line | Plain line | 8 |
| 6 | **Prompt Book (Đề Từ)** | Passive T1 | Arts on the Cue guard cost 25 % less. | 10 |
| 7 | **Line Learned (Thục Từ)** | Passive T1 | Foreseen fights only: the enemy's slot order is shown at t = 0, and +15 points to arts (L4). | 10 |

### The House (Tọa)

The people watching. 6 nodes, 69.8 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1.6 `mi_luc` | Stat line | Plain line | 8 |
| 2 | **Encore (Tái Diễn)** *(reused, Understudy)* | Passive T2 | +10 points per hit evaded this fight, to +100 (L2, art and basic). | 18 |
| 3 | +1.6 `mi_luc` | Stat line | Plain line | 8 |
| 4 | **Full House (Mãn Tọa)** *(reused, Understudy)* | Passive T2 | On ground with the stage tag: +30 points (L4), and your count holds 4. | 18 |
| 5 | +6 % `than_thuc_pct` | Stat line | Plain line | 7.8 |
| 6 | **Held Audience (Nhiếp Tọa)** | Passive T1 | On ground with the stage tag: the enemy's accuracy −5. | 10 |

## Keystones

A character owns one. Each is T3 with a 3.9 W line, 33.9 W. Both read the thần thức ratio, so sight is the Way's whole stat. They are mirror images: in one their blows are not real, in the other yours are not.

### The Understudy (Thế Thân), reused: their blows are not real

- **Line:** +3 % `than_thuc_pct`.
- **Opens:** your evade is counted under When the Worst Has Passed (`chance.md`), with no need of that node. Each body or qi hit aimed at you adds `count_rate × p_evade × min(1, your thần thức ÷ theirs)`. When the count fills, the hit lands on the double: nothing dealt, nothing drained, no on-hit trigger, and their cost stays paid.
- **Closes:** all but one light artifact, of cost up to a quarter of your thần thức, and any ward gear.
- **Terms, kept as written:** Seen Through (Thức Phá): an attacker whose accuracy reaches your evade sees through the double, and the count neither fills nor pays for them. The Credit (Đầu Bài): a knockout won with a count standing is credited to the role, feeds no tally, and the world records the double.
- **Holds:** 2, or 4 under Full House.

### Painted Knife (Họa Đao), new: your blows are not real

- **Line:** +3 % `than_thuc_pct`.
- **Opens:** your body and qi hits skip ward and body guard and drain nothing, at size × 0.5 × `min(1, your thần thức ÷ theirs)`. Soul arts and ticks are untouched.
- **Closes:** the wound is only believed. When the fight ends, every point you dealt returns. A Down target wakes unhurt: no vitality lost, no death, no spoils, and no knockout for capability #9. You can win any fight this way, and you can never kill anyone.
- **Sees through:** a target with twice your thần thức or more takes nothing. A creature, puppet or formation with no thần thức reads as seeing through, since nothing there can believe.
- **Sizing:** 0.5 sits near a typical ward's pass of 0.45 (Combat anchors) with nothing paid by the target, so the blade gains most against ward-heavy enemies, and their pool is never touched. It is a first guess.

## Rule Changes Asked

1. **dao.md rule 1 allows one keystone. This tree has two.** The ask: a Đạo may hold one or two keystones, a character may own one, and buying either closes the other for that life. The lint runs once per keystone with the closed one left out, and `C_dao` counts the nodes a character can own. This tree also passes with both counted.
2. **Combat rule 15 and Formulas I:** the counted rule, as `chance.md` asks. Not a second ask.
3. **Painted Knife, Combat rule 14 and Formulas D:** a hit that skips ward and guard, and a result flag that returns believed damage to the loser.
4. **Inherited from the sketch:** a miss from outside `evade_cap` for the masks, Cue's guard in rule 13, and The Credit's result flag.

## Lint (Formulas D1), First Guess

Priced by Meridian Map F1: `than_thuc_pct` 1.3 W. `evade_pct` and `linh_luc_regen_pct` are not in F1, so they are priced from the catalogue's notable sizes at 8 W: +2.5 and +1. `mi_luc` has no weight anywhere, so it is a *guess* at 5 W, the other talents' price. Passives and arts use `credit(T)`, itself a *guess*, and every branch rests on unpriced modifiers, so all sums below are first guesses. V̄ 12.42.

| Part | Check | Sum | Band | Result |
|---|---|---|---|---|
| 1 | Whole tree, all 21 nodes listed | 271.2 W ÷ 21 = 12.91 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with The Understudy | 237.3 W ÷ 20 = 11.86 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with Painted Knife | 237.3 W ÷ 20 = 11.86 | 11.18 to 13.66 | pass |
| 2 | Branch The Mask | 61.8 W ÷ 6 = 10.30 | 9.94 to 14.90 | pass |
| 2 | Branch The Script | 71.8 W ÷ 7 = 10.26 | 9.94 to 14.90 | pass |
| 2 | Branch The House | 69.8 W ÷ 6 = 11.63 | 9.94 to 14.90 | pass |
| 3 | R(The Mask), The Understudy | 61.8 + 8 + 8 + 33.9 = 111.7 W ÷ 9 = 12.41 | at least 11.18 | pass |
| 3 | R(The Mask), Painted Knife | 61.8 + 8 + 8 + 33.9 = 111.7 W ÷ 9 = 12.41 | at least 11.18 | pass |
| 3 | R(The Script), The Understudy | 71.8 + 8 + 8 + 33.9 = 121.7 W ÷ 10 = 12.17 | at least 11.18 | pass |
| 3 | R(The Script), Painted Knife | 71.8 + 8 + 8 + 33.9 = 121.7 W ÷ 10 = 12.17 | at least 11.18 | pass |
| 3 | R(The House), The Understudy | 69.8 + 8 + 8 + 33.9 = 119.7 W ÷ 9 = 13.30 | at least 11.18 | pass |
| 3 | R(The House), Painted Knife | 69.8 + 8 + 8 + 33.9 = 119.7 W ÷ 9 = 13.30 | at least 11.18 | pass |
| 4 | Key headroom, branch lines | `evade_pct` 16 W, `than_thuc_pct` 23.4 W, `linh_luc_regen_pct` 16 W, `mi_luc` 16 W | No key here is a rule 14 ceiling key or `cultivation_speed_pct`, so none has a limit | pass |

## Who Takes This Tree

| Build | Keystone | Why | First node |
|---|---|---|---|
| The Understudy | The Understudy | It is the build. The critic's runs show Rehearsal is what it dies without | Script 1, +1 % regeneration, for Rehearsal at node 2 |
| The Brush Fee | Painted Knife | Metal and Water, soul strength first, and its copies are qi hits. It must reach Water 30, and it loses every kill, so it wins fights that leave the author alive to write more. That is the arc its sheet wanted | Mask 1, +2.5 % `evade_pct`, the cheapest route to the keystone |
| The Loud Sword | None | The House alone: Encore pays on a counted evade, and its stage already exists. It needs Water 30 beside Metal | House 1, +1.6 `mi_luc`, then Encore |

## Rule Checks

- **Stat lines** use only `theme_stats`. **No ceiling raises** and no root factors. The count's hold is not a Character Stats ceiling, and it is bounded at 2 or 4.
- **Passives in one tree:** none of the eight is in another Way, checked against the sheets and `daos/`. Chance holds the counted rule as a passive, and The Understudy here is a separate keystone that invokes it.
- **Dress Rehearsal and Rehearsal are one piece,** as the critic ordered, and it sets any count's start. The Loud Sword keeps it as a prepared item, which is not a tree.
- **Masks are in two homes:** this tree and the Libretto. Rule 12 binds trees only. The masks are priced T2 and T1 by feel. The critic found that a price of ×1.5 flips the fight and that nothing lints them. This tree does not solve that.
- **Art nodes** are designed, not added to data until the fight is built (system-roles.md).

## Not Tested

No fight was run on this tree. Painted Knife is unproven in every respect. The Understudy under `count_rate` is in `chance.md`: it holds at 0.85 against a top-end on a stage, foreseen, and the critic's limits on that claim stand.
