# Way of Chance (Cơ Duyên Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. All W and sizes on new content are first guesses.
> **Brought up from:** the sketch in `sheets/lucky-fool.md`.

- **Requirement:** fortune 70, or a Void root at purity 30. The Void half fits dao.md rule 5. The fortune half does not, since rule 5 names elements, a variant or a technique kind. See Rule Changes Asked.
- **`theme_stats`:** `khi_van`, `evade_pct`, `status_resist_pct`.
- **Identity:** things go wrong near you, and you decide whether that is luck or arithmetic.
- **Shape:** 21 nodes: branches of 6, 7 and 6, and two keystones, of which a character owns one. A character buys 20, so a full Way costs the default 60 points. 7 stat lines, 9 passives, 3 arts in the branches. With the name hidden, a player reads a tree about rolls, near misses and leaving.

## The One Rule: When the Worst Has Passed (Bĩ Cực)

This replaces The Curtain, Called Blow and The Pot. Those three names are retired.

> **Name one chance of yours. It is never rolled again. Each time it would be rolled, add 0.85 of that chance to a count anyone can read. When the count reaches 1, the event happens on that occasion and the count falls by 1. The count holds at most 2, starts each fight at 0, and ends with the fight.**

- **The chance** is Formulas I's, after fortune and its cap. It can be a crit, an evade, a status, a trigger or a slip.
- **The price** is `count_rate` 0.85 (first guess): certainty costs 15 % of the rate. It applies to everything added to a count, so a bought add pays it too. The second price is that you name one chance, not all of them. Fixed Number, below, is the only way past that.
- **Rule 15:** a counted chance takes no draw, as a chance of 0 or 1 does today. The stream stays in order, because the other side's draws are unchanged.
- **Breakdown line:** "Evade count 1.34 of 2 (+0.34): hit evaded."
- **Who may grant it:** this node, The Understudy (evade only, below in `illusion.md`) and the Gilt Line capability (one chance). One rule in Combat, three doors to it, and only one of the doors is this passive, so rule 12 holds.

| Retired | What it becomes |
|---|---|
| The Curtain | The evade count, with The Understudy's own terms on top: the add is also multiplied by the thần thức ratio, and a filled count lands the hit on the double |
| Called Blow | The rule on one chance. Crit and evade together, as The Loud Sword has them, now need Fixed Number |
| The Pot | The rule on the slip chance. It no longer rolls beside the count: only the floor remains |
| Dress Rehearsal, Rehearsal | One piece, Rehearsal (Diễn Tập), in Illusion's Script |

### What the price does

These runs are of the existing `-mixed` files with every add scaled, and nothing retuned. The inputs are in `scratch/daos-b/`, built by `mk.py`, as `understudy-all95`, `lucky-fool-rate95`, `loud-sword-rate95` and so on for each rate. The Understudy scales evade and both masks. The Lucky Fool stands in by lowering the slip base, at the lead of 125 the critic measured. The Loud Sword scales every crit and evade source.

| Fight | Rate 1.00, today | 0.95 | 0.90 | 0.85 | 0.75 |
|---|---|---|---|---|---|
| Understudy, top-end, `--enemy top_end` | Wins at 7 s on 100 % | The same | The same | The same | Dead at 5 s, enemy on 77 % |
| Lucky Fool floor, `--enemy top_end` | Wins at 18 s on 15 %, 4 slips | Both at 0 at 22 s, scored to the enemy, 3 slips | The same | The same | Flees at 19 s, 3 slips |
| Loud Sword, `--gap 1` | Wins at 3 s on 31 % | Both at 0 at 3 s, scored to the enemy | The same | The same | The same |

- **The rate buys timing, not frequency.** A cut of 5 % already flips two builds, and 15 % changes nothing more. A hit or two moving is the whole of the counted edge, which matches what The Loud Sword's question suspected. For reference, the same Loud Sword fully rolled (`--without called_blow`) loses with the enemy on 44 %, so 0.85 lands between counted and rolled.
- **0.85 is the lowest tested rate The Understudy survives.** It costs that build nothing in this fight. Its real price is still the mask's, which has no lint.
- **Long Odds buys the fool back.** At 0.85 with Long Odds, a swing adds 0.169, and the floor wins at 18 s on 15 % with 4 slips (`scratch/daos-b/lucky-fool-rate85-longodds.fight.json`). A tree node paying back a rule's price is the intended shape.
- **The Lucky Fool's sweep stops applying.** Its 293 of 300 and 300 of 300 are counts with rolls beside them. Under one rule only the floor exists.

## Branches

### The Slip (Thất Thủ Mạch)

What goes wrong for them. 6 nodes, 72 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1.6 `khi_van` | Stat line | Plain line | 8 |
| 2 | **Ill Omen (Hung Triệu)** *(reused, Lucky Fool)* | Art T2 | No hit, cost 0.03, cooldown 2 s. A curse: the target's fortune −15 for 3 pulses, stacking to −45. | 18 |
| 3 | +2.5 % `evade_pct` | Stat line | Plain line | 8 |
| 4 | **Near Thing (Hào Ly)** | Passive T1 | Each hit evaded lowers that attacker's crit chance by 2 points for the fight, to −10. | 10 |
| 5 | **After You (Nhượng Tiên)** *(reused, Lucky Fool, effect new)* | Art T1 | No hit, cost 0, cooldown 1 s. Every chance against the enemy's next art gains +0.02. | 10 |
| 6 | **Worse Luck (Họa Vô Đơn Chí)** | Passive T2 | After a chance goes against a target (a crit, a status, a slip), each later chance against them gains +0.03 for the fight, to +0.15. | 18 |

### The Count (Số Mạch)

What a run of bad luck is worth. 7 nodes, 72 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +1.6 `khi_van` | Stat line | Plain line | 8 |
| 2 | **Long Odds (Viễn Toán)** | Passive T1 | A chance under 0.20 gains +0.02, added after `count_rate` when the chance is counted. | 10 |
| 3 | +6 % `status_resist_pct` | Stat line | Plain line | 8 |
| 4 | **When the Worst Has Passed (Bĩ Cực)** *(reused, merged)* | Passive T2 | The one rule, above. Name one chance. | 18 |
| 5 | **Banked Luck (Tích Phúc)** | Passive T1 | Your count holds 3. | 10 |
| 6 | +1.6 `khi_van` | Stat line | Plain line | 8 |
| 7 | **The Answer (Hoàn Chiêu)** *(reused, Loud Sword, widened)* | Passive T1 | When a count fills, +0.25 to another count of yours, or +0.10 to the same one if you hold only one. | 10 |

### The Road Out (Thoát Mạch)

Not being there. 6 nodes, 72 W.

| # | Node | Kind | Effect | W |
|---|---|---|---|---|
| 1 | +2.5 % `evade_pct` | Stat line | Plain line | 8 |
| 2 | **Wrong Turn (Mê Lộ)** *(reused, Lucky Fool)* | Art T1 | Escape art, `e_art` 0.55, cost 0.10, cooldown 3 s, guard own health below 30 %. | 10 |
| 3 | +6 % `status_resist_pct` | Stat line | Plain line | 8 |
| 4 | **Someone Else's Problem (Giá Họa)** *(reused, Lucky Fool)* | Passive T2 | On a knockout win, the loser pays your Years Owed. | 18 |
| 5 | **Folded Corner (Chiết Giác)** *(reused, Best Plan)* | Passive T1 | The first failed roll of a fight puts its talisman back in stock. | 10 |
| 6 | **Never Home (Bất Tại Gia)** | Passive T2 | After a Fled result, the one you fled cannot open a fight with you for 4 seasons. | 18 |

## Keystones

A character owns one. Each is T3 with a 4 W line, 34 W. No cap moves. Slip uses your luck against theirs. Fixed Number gives up luck altogether.

### Slip of the Hand (Thất Thủ), reused: your luck against theirs

- **Line:** +0.8 `khi_van`.
- **Opens:** every art that would hit, on either side, first rolls `0.05 + (other's fortune − caster's fortune) × 0.001`. On a slip it resolves on its caster: same size, same M, their own ward and guard, no suppression, at most 30 % of their maximum health. Basic attacks, ticks and arts with no hit do not roll.
- **Closes:** your own hitting arts roll too. It is taken by people who have none.
- **With the rule:** name the slip chance, and a fool has a floor. The 30 % clip stands until the campaign's merged self-hit replaces it (critic order 5).

### Fixed Number (Định Số), new: no luck at all

- **Line:** +1.25 % `evade_pct`.
- **Opens:** every chance you own is counted, each on its own count, with nothing named. `count_rate` still applies.
- **Closes:** your fortune reads 0 in a fight. Any enemy's fortune is then a straight lead against you: at enemy fortune 50, every chance loses 0.05 before the rate. You keep your fortune everywhere outside a fight.
- **Why it is a real choice:** Slip wants fortune as high as it goes. Fixed Number throws it away. A player with fortune 130 who buys this has made a statement about their life.

## Rule Changes Asked

1. **dao.md rule 1 allows one keystone. This tree has two.** The ask: a Đạo may hold one or two keystones, a character may own one, and buying either closes the other for that life. Rule 8's gate is unchanged. The lint runs once per keystone with the closed one left out, and `C_dao` counts the nodes a character can own. This tree also passes with both counted.
2. **dao.md rule 5 has no talent requirement.** The ask: a talent at a minimum. If refused, the requirement is Void alone, and The Lucky Fool keeps it while Best Plan and The Loud Sword lose it.
3. **Combat rule 15 and Formulas I:** the one rule above, with `count_rate` and `count_hold`. This answers the critic's rule discovery 2.
4. **Inherited from the sketch:** Slip's redirect (rules 9 and 15), and Someone Else's Problem (rule 14).

## Lint (Formulas D1), First Guess

Priced by Meridian Map F1: `khi_van` 5 W. `evade_pct` and `status_resist_pct` are not in F1, so they are priced from the catalogue's notable sizes at 8 W: +2.5 is 3.2 W a point, +6 is 1.33 W a point. Passives and arts use `credit(T)`, which is itself a *guess*, and every branch rests on unpriced modifiers, so all sums below are first guesses. V̄ 12.42.

| Part | Check | Sum | Band | Result |
|---|---|---|---|---|
| 1 | Whole tree, all 21 nodes listed | 284 W ÷ 21 = 13.52 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with Slip of the Hand | 250 W ÷ 20 = 12.50 | 11.18 to 13.66 | pass |
| 1 | As bought, 20 nodes, with Fixed Number | 250 W ÷ 20 = 12.50 | 11.18 to 13.66 | pass |
| 2 | Branch The Slip | 72 W ÷ 6 = 12.00 | 9.94 to 14.90 | pass |
| 2 | Branch The Count | 72 W ÷ 7 = 10.29 | 9.94 to 14.90 | pass |
| 2 | Branch The Road Out | 72 W ÷ 6 = 12.00 | 9.94 to 14.90 | pass |
| 3 | R(The Slip), Slip of the Hand | 72 + 8 + 8 + 34 = 122 W ÷ 9 = 13.56 | at least 11.18 | pass |
| 3 | R(The Slip), Fixed Number | 72 + 8 + 8 + 34 = 122 W ÷ 9 = 13.56 | at least 11.18 | pass |
| 3 | R(The Count), Slip of the Hand | 72 + 8 + 8 + 34 = 122 W ÷ 10 = 12.20 | at least 11.18 | pass |
| 3 | R(The Count), Fixed Number | 72 + 8 + 8 + 34 = 122 W ÷ 10 = 12.20 | at least 11.18 | pass |
| 3 | R(The Road Out), Slip of the Hand | 72 + 8 + 8 + 34 = 122 W ÷ 9 = 13.56 | at least 11.18 | pass |
| 3 | R(The Road Out), Fixed Number | 72 + 8 + 8 + 34 = 122 W ÷ 9 = 13.56 | at least 11.18 | pass |
| 4 | Key headroom, branch lines | `khi_van` 24 W, `evade_pct` 16 W, `status_resist_pct` 16 W | No key here is a rule 14 ceiling key or `cultivation_speed_pct`, so none has a limit | pass |

## Who Takes This Tree

| Build | Keystone | Why | First node |
|---|---|---|---|
| The Lucky Fool | Slip of the Hand | It is the build. Void root meets the requirement | Count 1, +1.6 `khi_van`, walking to Long Odds and the rule by node 4 |
| The Loud Sword | Fixed Number | It needs two counts, and only this gives them. Its chances come from presence, not fortune, though an enemy's lead will still cut them. It must meet the requirement: its sheet names no fortune, and its root is Metal | Count 1, then the rule, then The Answer, which it already relies on |
| The Best Plan | None | Fortune is its first talent, and its Way is free. It wants The Road Out for Never Home and Someone Else's Problem. Its technique already gives it Folded Corner, so that node is thin for it | Road Out 1, +2.5 % `evade_pct`, then Wrong Turn |

## Rule Checks

- **Stat lines** use only `theme_stats`. **No ceiling raises** and no root factors. `khi_van` is not a rule 14 key, and the Way's +5.6 at most is under the talent clamp.
- **Passives in one tree:** none of the nine is in another Way, checked against the sheets and `daos/`.
- **Patronage is not here, against the sketch.** It is a Way of Ink node (`sheets/brush-fee.md`, Ledger branch), so rule 12 bars it. The Lucky Fool needs it (293 falls to 33 without it) and must take it from elsewhere. Rule 12 binds trees only, so the plain fix is an ability on the Recruit's Drill Manual. I have not touched that sheet. After You's old job was only to be Patronage's slot, so it now has its own small effect and can still serve as that slot.
- **Art nodes** are designed, not added to data until the fight is built (system-roles.md). No-hit arts have no lint, the critic's rule discovery 1.

## Not Tested

No fight was run on this tree or its nodes, only the rate table above. Near Thing, Worse Luck, After You's new effect, Banked Luck, The Answer as widened, Never Home and Fixed Number are unproven sizes.
