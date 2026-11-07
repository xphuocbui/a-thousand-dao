# Way of the Threshold (Hạm Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Sketched in**: `sheets/turned-away.md` · **Order**: critic wave 3, order 3
> **Shape**: 19 branch nodes (10 stat lines, 9 passives, 0 art) and 2 keystones · **Fit**: 10 Fits today · 8 Needs key · 3 Needs rule

**Identity:** Every gate that refused you left something in your body: stay at the door and let it break you stronger, or get through and bring the break with you.

**Requirement:** Fire and Earth at purity 25 (rule 5).

**`theme_stats`:** `khi_huyet_pct`, `body_guard_pct`, `pierce_pct`, `soul_res_pct`, `tam_ma_resist_pct`.

**Changed from the sketch:** nothing in the requirement or `theme_stats`. All four per-scar pieces from the sheet are kept, and the bar-loss passive now has a name.

## Branches

Stat lines are plain, stackable and sized at 8 W, a catalogue notable. Order is purchase order (rule 8).

### Knock (Khấu), 7 nodes

Attempts and what they teach. Plain pierce, because anyone stuck at a gate fights upward.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +3 `pierce_pct` | Stat | 8.0 | Fits today |
| 2 | **Light Knock (Khinh Khấu).** A failed great breakthrough takes 20 % of the bar, not 30 %, so a scar takes less time to refill | Passive T1 | 10.0 | Needs key |
| 3 | +3 `pierce_pct` | Stat | 8.0 | Fits today |
| 4 | **Known Gate (Thức Quan).** Reused. +5 pierce per Gate Scar, inside `pierce_cap` | Passive T2 | 18.0 | Needs key |
| 5 | +3 `pierce_pct` | Stat | 8.0 | Fits today |
| 6 | **Raw Scar (Tân Ngân).** Reused. +30 points to hits for 4 seasons after a failed great breakthrough, even in a blind fight | Passive T2 | 18.0 | Needs rule |
| 7 | **Worn Step (Mòn Bậc).** `failure_insight_cap` reads 6 pp, not 4. The extra counts under `q_extras_ceiling_pp` (rule 4). Empty under The Copyist's Error, which rolls nothing | Passive T1 | 10.0 | Needs key |

### Crack (Liệt), 6 nodes

What failure leaves in the body. Plain health and guard, with the catalogue's low-health row for anyone who lives down there.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +6.5 `khi_huyet_pct` | Stat | 7.8 | Fits today |
| 2 | +8 `body_guard_pct` | Stat | 8.0 | Fits today |
| 3 | **Thin Wall (Bạc Bích).** +12 `attack_pct` while below 50 % health. The catalogue's plain row. Second home: any low-health build | Passive T1 | 10.0 | Needs key |
| 4 | +6.5 `khi_huyet_pct` | Stat | 7.8 | Fits today |
| 5 | **Numb Soul (Ma Hồn).** Reused. +8 `soul_res_pct` per Gate Scar | Passive T2 | 18.0 | Needs key |
| 6 | **Set Bone (Tiếp Cốt).** A failed great breakthrough takes 30 % of vitality, not 40 % | Passive T1 | 10.0 | Needs key |

### Refusal (Cự), 6 nodes

What it is to be refused, and to refuse. Heart demon lines keep a cultivator under the 74 where a failed attempt cannot kill.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +5 `tam_ma_resist_pct` | Stat | 7.5 | Fits today |
| 2 | +8 `body_guard_pct` | Stat | 8.0 | Fits today |
| 3 | +5 `tam_ma_resist_pct` | Stat | 7.5 | Fits today |
| 4 | **Refused Force (Cự Lực).** Reused. +15 points to hits per health floor held this fight, L2 | Passive T2 | 18.0 | Needs key |
| 5 | +5 `tam_ma_resist_pct` | Stat | 7.5 | Fits today |
| 6 | **Returned Unopened (Nguyên Phong).** The first curse to reach you each fight has no effect and takes no slot. The caster still paid. Second home: any build that is cursed once and dies of it | Passive T2 | 18.0 | Needs key |

## Keystones

Realms rule 9 clears every scar on a success, so a stalled life has one question: stay or pass? Cracked Perfection pays you to stay. Carried Crack lets you pass and keeps the per-scar nodes alive. Both read one count, Gate Scars, which is `gate_scars` in the Turned-Away sheet's New Concepts, and neither works until that exists.

### Cracked Perfection (Liệt Viên Mãn), reused: stay at the door

T3 and +1.5 `pierce_pct`, 34 W. **Needs rule** (Combat Formulas C, `stage_src` past 1.45 on damage only).

- **Opens:** +0.05 to `stage_mult` on damage per Gate Scar, past great perfection: 1.65 at 4 scars.
- **Closes:** nothing by itself. A success clears the scars, so passing a gate takes it all away.
- **Bound:** at most 12 scars count, so 2.05. The sheet's limit came from the Sutra's layers, and this keystone needs one of its own for a life with no Sutra. It moves no Character Stats ceiling and no root factor.

### Carried Crack (Đới Liệt), new: go through and take it with you

T3 and +1.5 `pierce_pct`, 34 W. **Needs rule** (Realms rule 9).

- **Opens:** on a successful great breakthrough, half your Gate Scars stay, rounded down, in place of none.
- **Closes:** each scar carried adds +5 heart demon on arrival. You give up any stage gain: scars pay only through the nodes that read them.
- **Bound:** halved at every gate, so the count shrinks unless you fail again. It touches no gate odds (rule 4). The Copyist's Error still fails every attempt, so a Turned-Away must swap the main method first, as the sheet already allows.
- **Breakdown line:** "Gate passed: 2 of 4 scars carried, heart demon +10."
- **Second home:** any life that stalled at a gate and then got through, which the difficulty targets make most lives that get anywhere. It also gives the sheet's perfect pill a third answer.

## Rule Change Asked

**This tree asks for a change to dao.md rule 1, which allows one keystone.** It has two, and a character may own one. Both sit behind rule 8's gate, one whole branch and one node in each other branch. Buying either closes the other for that life, and rule 8 already says a bought node is never refunded.

The wording around rule 1 follows it: rule 8 and the state table (Mastered would mean every node but the closed keystone), rule 12 (a Đạo may carry two signatures), and N and `C_dao` in Formulas D1. Proposed reading of the lint: it runs once per keystone with the closed one left out, so 19 branch nodes and 2 keystones list 21 nodes, own 20 and still cost 60 points. Three branches of 7 and two keystones would list 23, so 7, 7, 7 is no longer legal. Until the user rules, this tree does not pass rule 1.

## Lint (Formulas D1), First Guess

V̄ = 2 × 3 × 2.07 = 12.42 W. Both keystones are T3 with the same 4 W line, 34 W, so each owner reads the same.

| Part | Measure | Band | Result |
|---|---|---|---|
| 1, owning Cracked Perfection | 242.1 W over 20 nodes, mean 12.11 | 11.18 to 13.66 | inside |
| 1, owning Carried Crack | 242.1 W over 20 nodes, mean 12.11 | 11.18 to 13.66 | inside |
| 1, as listed (both keystones) | 276.1 W over 21 nodes, mean 13.15 | 11.18 to 13.66 | inside |
| 2, Knock | 80.0 W over 7 nodes, mean 11.43 | 9.94 to 14.90 | inside |
| 2, Crack | 61.6 W over 6 nodes, mean 10.27 | 9.94 to 14.90 | inside |
| 2, Refusal | 66.5 W over 6 nodes, mean 11.08 | 9.94 to 14.90 | inside |
| 3, R(Knock) to Cracked Perfection | 129.3 W over 10 nodes, mean 12.93 | at least 11.18 | inside |
| 3, R(Knock) to Carried Crack | 129.3 W over 10 nodes, mean 12.93 | at least 11.18 | inside |
| 3, R(Crack) to Cracked Perfection | 111.1 W over 9 nodes, mean 12.34 | at least 11.18 | inside |
| 3, R(Crack) to Carried Crack | 111.1 W over 9 nodes, mean 12.34 | at least 11.18 | inside |
| 3, R(Refusal) to Cracked Perfection | 116.3 W over 9 nodes, mean 12.92 | at least 11.18 | inside |
| 3, R(Refusal) to Carried Crack | 116.3 W over 9 nodes, mean 12.92 | at least 11.18 | inside |
| 4, `body_guard_pct` | 16.0 W | no limit | no headroom rule |
| 4, `khi_huyet_pct` | 15.6 W | no limit | no headroom rule |
| 4, `pierce_pct` | 28.0 W | no limit | no headroom rule |
| 4, `tam_ma_resist_pct` | 22.5 W | no limit | no headroom rule |

**Where the W comes from, owning one keystone:** 38.1 W on F1 weights (16 %), 44.0 W at catalogue sizes on keys with no F1 weight (18 %), 160.0 W as tier credits for passives, arts and the keystone (66 %). Only the first part is a price. The rest is a first guess.

**Where the credit under-reads.** Per-scar passives are credited by tier and scale past it. At 4 scars Known Gate is +20 pierce, about 53 W against 18, and Numb Soul is +32, about 43 W against 18. Each scar costs +15 heart demon, 40 % of vitality and a slice of the bar, all outside the tree, and the lint sees none of that. An observation, not a reason to shave them. Cracked Perfection touches a factor F1 has no weight for, so its credit is a label.

## Who Takes This Tree

A first buy can only be a branch opener (rule 8), so the table also names what the build is heading for. Reasons come from the sheets. No build was re-run on these nodes.

| Build | Keystone | Why | First buy | Heading for |
|---|---|---|---|---|
| The Turned-Away | Cracked Perfection | Home tree. It wants Known Gate, Raw Scar, Numb Soul and Refused Force. With the keystone that is all of Knock, 5 of Crack and 4 of Refusal, 17 nodes, 51 points. Pierce also fits a build that is always behind | Knock 1, +3 pierce | Known Gate, Raw Scar, the keystone |
| The Given Years | None | Fire and Earth at about 50, and its Way slot is free. Paid in Seasons burns a season per 20 % of maximum health, so more health means fewer seasons a blow. Its sheet would still rather spend the glimpse on the family | Crack 1, +6.5 health | Crack 4, +6.5 health |
| The Kept Hearth | Carried Crack | Its root meets the requirement at purity 30, and its sheet says everything arrives late. A judgement, not a run: a slow life fails gates, and this one keeps climbing, so scars are worth carrying. It loses one up, so it wants pierce | Knock 1, +3 pierce | Known Gate, Worn Step, Carried Crack |

**Wanted, barred:** The Not-Yet-Full ("Qi Refining to Core Formation, for ever") and The Thousand Scales (ends at the Nascent Soul gate) are lives that stop at a door, and neither has Fire and Earth.

**Question for the user:** rule 5 cannot read a failure count. Allowing three Gate Scars as a requirement, as Waster Heap's seal does, would open this Way to anyone a gate has beaten. Is that wanted?

## Rule Checks

- **Stat lines:** theme stats only.
- **Passives in one tree:** checked against every Đạo in the sheets. Reopened stays in Waster Heap.
- **No ceiling raise:** Worn Step counts under the q-extras ceiling, as rule 4 requires, and Light Knock and Set Bone change a penalty, not a rate. AC-DAO-10 should still test Light Knock, because a shorter refill is time saved at a gate.
- **Name hidden:** knocking, a worn step, a set bone, a thing returned unopened. It reads as someone outside a door. Keeping's gates differ: there, you are the door.
- **Art nodes:** none. This Way is a life, and the arts stay on the Sutra.
- **Naming:** Turned Away's Bế Môn still collides with Closed Gate, as the critic said. Suggested: Cự Môn. It sits on the Sutra, not this tree, so this file leaves it alone.

## Not Tested

No fight was run for this tree. Carried Crack, Thin Wall, Returned Unopened, Worn Step, Light Knock and Set Bone have no plug-in. Cracked Perfection's results are in `sheets/turned-away.md`. The +5 heart demon a scar is a first guess with no calibration against the 74 line.
