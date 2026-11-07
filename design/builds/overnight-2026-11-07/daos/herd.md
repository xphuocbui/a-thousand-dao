# Way of the Herd (Mục Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. All W and sizes on new content are first guesses.
> **Brought up from:** the sketch in `sheets/herd-child.md`.

- **Requirement:** Earth at purity 30.
- **`theme_stats`:** `khi_huyet_pct`, `linh_luc_regen_pct`, `art_speed_pct`, `body_guard_pct`.
- **Identity:** you keep an animal, and one day you find out what that meant.
- **Shape:** 21 nodes: branches of 6, 7 and 6, and two keystones, of which a character owns one. A character buys 20, so a full Way costs the default 60 points. 9 stat lines and 10 passives in the branches, and no art nodes, as the sketch has it. With the name hidden, a player reads rope, song, feed and stock.

## Branches

### The Rope (Lãm)

What ties the animal to the hand. 6 nodes, 70 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +3 % `art_speed_pct` | Stat line | Plain line | 8 |
| 2 | **Bonded Spirit (Linh Khế)** *(reused, Herd-Child)* | Passive T2 | The companion's timer carries your art speed, stopping at `cooldown_min`. | 18 |
| 3 | +8 % `body_guard_pct` | Stat line | Plain line | 8 |
| 4 | **Heavy Yoke (Trọng Ách)** | Passive T1 | +15 to companion hits (L1). | 10 |
| 5 | +3 % `art_speed_pct` | Stat line | Plain line | 8 |
| 6 | **Cornered (Khốn Đấu)** *(reused, Already-Waited and Herd-Child)* | Passive T2 | +50 points to companion hits while your health share is below the enemy's; an owner on the ground always counts (L5). | 18 |

### The Song (Ca)

Calling across a field. 7 nodes, 71.8 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1 % `linh_luc_regen_pct` | Stat line | Plain line | 8 |
| 2 | **Carried Note (Đới Âm)** *(reused, Herd-Child)* | Passive T2 | Tag modifiers on an art you fired this instant also apply to your companion's hit in that instant. | 18 |
| 3 | +6.5 % `khi_huyet_pct` | Stat line | Plain line | 7.8 |
| 4 | **Home Tune (Hương Khúc)** | Passive T1 | +15 points to arts with the song form (L2). | 10 |
| 5 | +1 % `linh_luc_regen_pct` | Stat line | Plain line | 8 |
| 6 | **Evening Call (Vãn Hô)** | Passive T1 | A song art that fires in the same instant as your companion's hit costs 25 % less. | 10 |
| 7 | **Goad (Thúc)** | Passive T1 | Your companion's first hit of a fight comes at half its timer. | 10 |

### The Field (Điền)

Feed, years and keeping stock. 6 nodes, 69.6 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +6.5 % `khi_huyet_pct` | Stat line | Plain line | 7.8 |
| 2 | **Full Trough (Mãn Tào)** *(reused, Herd-Child)* | Passive T2 | +20 points to companion hits per doubling of the year's feed above what is due, to +40. It was eaten, so a blind fight keeps it (L4). | 18 |
| 3 | +8 % `body_guard_pct` | Stat line | Plain line | 8 |
| 4 | **Given Years (Tặng Niên), companion grade** *(reused, Herd-Child)* | Passive T2 | +1.5 points to companion hits per 1 % of your realm's base lifespan given to the beast, to +45 (L2). | 18 |
| 5 | +6.5 % `khi_huyet_pct` | Stat line | Plain line | 7.8 |
| 6 | **Good Stock (Lương Chủng)** | Passive T1 | A beast born in your keeping starts at +10 loyalty and eats 25 % less. | 10 |

## Keystones

A character owns one. Each is T3 with a 4 W line, 34 W. Both ask what the animal is to you, and the two answers cannot both be true.

### Stands Over You (Hộ Chủ), reused: the animal stays

- **Line:** +4 % `body_guard_pct`.
- **Opens:** when you go Down, your companion stays, on its own health and guard, with no ward, and the fight goes on until it falls. It needs loyalty 60 or more.
- **Closes:** a beast at 0 in the Stand is dead for good, and nothing in the game brings it back.

### The Knife at Year's End (Tuế Mạt Đao), new: the animal was always stock

- **Line:** +4 % `body_guard_pct`.
- **Opens:** at the defeat check, if you would go Down with your companion alive, it dies in your place. You stand at 40 % of maximum health, with +40 points to hits (L5) for the rest of the fight. This takes seed 64, a beast sacrificed mid-fight.
- **Closes:** that beast is gone for good. Every beast you own afterward reads 20 lower on loyalty, because they know.
- **What it does to a life:** with this keystone, the Field becomes a farm. You raise calves on Good Stock to carry into fights, and each is a second life that costs a year of feed. Nothing in the rules makes that feel good, and that is the point of it.

## Rule Changes Asked

1. **dao.md rule 1 allows one keystone. This tree has two.** The ask: a Đạo may hold one or two keystones, a character may own one, and buying either closes the other for that life. The lint runs once per keystone with the closed one left out, and `C_dao` counts the nodes a character can own. This tree also passes with both counted.
2. **The Knife, Combat rule 14 and the defeat check:** a companion's death may stand in for Down. It reads no beast health, so it does not reopen targeting.
3. **Inherited from the sketch:** Stands Over You (rules 14 and 19, reopening targeting for this keystone alone), Bonded Spirit and Carried Note (a companion reading this instant's art), Given Years (Spirit Beasts, Realms rule 14).

## Lint (Formulas D1), First Guess

Priced by Meridian Map F1: `khi_huyet_pct` 1.2 W. `art_speed_pct`, `linh_luc_regen_pct` and `body_guard_pct` are not in F1, so they are priced from the catalogue's notable sizes at 8 W: +3, +1 and +8. Combat Open Question 21 says art speed still has no agreed price. Passives use `credit(T)`, itself a *guess*, and every branch rests on unpriced modifiers, so all sums below are first guesses. V̄ 12.42.

| Part | Check | Sum | Band | Result |
|---|---|---|---|---|
| 1 | Whole tree, all 21 nodes listed | 279.4 W ÷ 21 = 13.30 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with Stands Over You | 245.4 W ÷ 20 = 12.27 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with The Knife at Year's End | 245.4 W ÷ 20 = 12.27 | 11.18 to 13.66 | pass |
| 2 | Branch The Rope | 70 W ÷ 6 = 11.67 | 9.94 to 14.90 | pass |
| 2 | Branch The Song | 71.8 W ÷ 7 = 10.26 | 9.94 to 14.90 | pass |
| 2 | Branch The Field | 69.6 W ÷ 6 = 11.60 | 9.94 to 14.90 | pass |
| 3 | R(The Rope), Stands Over You | 70 + 8 + 7.8 + 34 = 119.8 W ÷ 9 = 13.31 | at least 11.18 | pass |
| 3 | R(The Rope), The Knife at Year's End | 70 + 8 + 7.8 + 34 = 119.8 W ÷ 9 = 13.31 | at least 11.18 | pass |
| 3 | R(The Song), Stands Over You | 71.8 + 8 + 7.8 + 34 = 121.6 W ÷ 10 = 12.16 | at least 11.18 | pass |
| 3 | R(The Song), The Knife at Year's End | 71.8 + 8 + 7.8 + 34 = 121.6 W ÷ 10 = 12.16 | at least 11.18 | pass |
| 3 | R(The Field), Stands Over You | 69.6 + 8 + 8 + 34 = 119.6 W ÷ 9 = 13.29 | at least 11.18 | pass |
| 3 | R(The Field), The Knife at Year's End | 69.6 + 8 + 8 + 34 = 119.6 W ÷ 9 = 13.29 | at least 11.18 | pass |
| 4 | Key headroom, branch lines | `art_speed_pct` 16 W, `body_guard_pct` 16 W, `linh_luc_regen_pct` 16 W, `khi_huyet_pct` 23.4 W | No key here is a rule 14 ceiling key or `cultivation_speed_pct`, so none has a limit | pass |

## Who Takes This Tree

| Build | Keystone | Why | First node |
|---|---|---|---|
| The Herd-Child | Stands Over You | It is the build: one realm up, a win at 4.8 s becomes a loss at 3 s without it | Rope 1, +3 % `art_speed_pct`, then Bonded Spirit |
| The Corner | The Knife at Year's End | Earth at high purity, a free Way, and a body that must last 7 s of a stronger enemy's fists. It has no beast today, so it must keep a calf. Its land can feed one | Field 1, +6.5 % `khi_huyet_pct`, then along the route of one node each |
| The Not-Yet-Full | The Knife at Year's End | Earth, and it takes any Way. A second life in wave two suits someone who eats everything, though this tree has none of the art nodes its sheet looks for, so it comes only for the knife | Field 1, +6.5 % `khi_huyet_pct` |
| The Given Years | None | Fire and Earth near 50, and its Way is free. It wants The Field alone, for the companion grade of its own modifier and a family animal | Field 1, then Full Trough, then Given Years at node 4 |

## Rule Checks

- **Stat lines** use only `theme_stats`. **No ceiling raises** and no root factors. Given Years spends lifespan and raises nothing.
- **Passives in one tree:** none of the ten is in another Way, checked against the sheets and `daos/`. Cornered's other home is the Cold Landing cluster, and Given Years' other grade sits in The Given Years' own stack. Neither is a tree.
- **Fights as Itself, Broad Back and In Step** stay in the Old Yoke cluster, so the Herd-Child still spreads across two systems.
- **One companion stays one companion.** Neither keystone adds a source.

## Not Tested

No fight was run on this tree. The Knife's 40 %, +40 and −20 are unproven, as are Heavy Yoke, Home Tune, Evening Call, Goad and Good Stock.
