# Poison (Độc Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Sketched in**: `sheets/tasters-fever.md` · **Order**: critic wave 3, order 3
> **Shape**: 19 branch nodes (9 stat lines, 9 passives, 1 art) and 2 keystones · **Fit**: 4 Fits today · 14 Needs key · 3 Needs rule

**Identity:** A dose is a decision about whose body it goes in: yours, for the fever, or theirs, for the rot.

**Requirement:** Water at purity 30, or Cinnabar (rule 5).

**`theme_stats`:** `art_speed_pct`, `status_resist_pct`, `dan_doc_resist_pct`, `poison_damage_pct` (new key, the catalogue's ○ Poison damage row, Increased on the poison tag, L1).

**Changed from the sketch:** two things. **Requirement:** was Fire and Water at purity 30, or Cinnabar. Only The Taster's Fever and The Kept Hearth met it, so no poisoner with a tick could reach the second keystone. Water alone keeps Cinnabar and lets in Great Tonic and any Water tick build. The Taster's Fever still qualifies. **`theme_stats`:** `pierce_pct` is out and `poison_damage_pct` is in, because pierce is a line any Đạo could hold (rule 12). The sheet's pierce comes from the tree, so nothing depends on it.

## Branches

Stat lines are plain, stackable and sized at 8 W, a catalogue notable. Order is purchase order (rule 8).

### The Tongue (Thiệt), 7 nodes

Reading a dose. It opens on status resistance, not toxicity resistance, because a Taster is forced to buy the opener and `dan_doc_resist_pct` slows their reload.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +6 `status_resist_pct` | Stat | 8.0 | Fits today |
| 2 | +5 `dan_doc_resist_pct` | Stat | 8.0 | Fits today |
| 3 | **Measured Dose (Định Lượng).** Your poison-tag statuses last 1 pulse longer. Second home: any tick build | Passive T1 | 10.0 | Needs key |
| 4 | +6 `status_resist_pct` | Stat | 8.0 | Fits today |
| 5 | **Inured Flesh (Quán Độc).** Reused. +0.3 `status_resist_pct` per đan độc | Passive T1 | 10.0 | Needs key |
| 6 | +15 `poison_damage_pct` | Stat | 8.0 | Needs key |
| 7 | **Bitter Measure (Khổ Lượng).** Reused. +1.5 points per đan độc on the poison tag, L2 | Passive T2 | 18.0 | Needs key |

### The Fever (Nhiệt), 6 nodes

The heat of a sick body. Plain art speed, a way to stay sick, and Overheat at the end. The three lines give +9, which Overheat turns into L5 past the floor: the sheet's +20 would be +29 of a +30 limit, by arithmetic and not by a run.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +3 `art_speed_pct` | Stat | 8.0 | Needs key |
| 2 | +3 `art_speed_pct` | Stat | 8.0 | Needs key |
| 3 | **Running Hot (Phát Nhiệt).** +8 art speed on the poison tag. The catalogue's one-tag row, a little over notable size | Passive T1 | 10.0 | Needs key |
| 4 | **Kept Warm (Ôn Tồn).** −1 `dan_doc_decay`: natural decay stops, and Water purity still washes you. A cost for anyone else, which is why it is a passive and not a line | Passive T1 | 10.0 | Fits today |
| 5 | +3 `art_speed_pct` | Stat | 8.0 | Needs key |
| 6 | **Overheat (Quá Nhiệt).** Reused. Art speed that `cooldown_min` clips becomes L5 points, 1 for 1, up to +30 | Passive T2 | 18.0 | Needs rule |

### The Dregs (Tra), 6 nodes

What is left in the cup. Plain poison damage and the things an alchemist throws away.

| # | Node | Kind | W | Fit |
|---|---|---|---|---|
| 1 | +15 `poison_damage_pct` | Stat | 8.0 | Needs key |
| 2 | **Sweepings (Tảo Tra).** A failed brew leaves Dregs (Đan Tra), toxicity 20, no effect | Passive T1 | 10.0 | Needs key |
| 3 | +15 `poison_damage_pct` | Stat | 8.0 | Needs key |
| 4 | **First Taste (Sơ Thí).** Reused, for anyone without the Canon. Qi hit, `c_art` 1.0, cost 0.05, 1 s, applies Bile, `c_tick` 0.3, 4 pulses. Paid in đan độc under Bitter Tithe. Within the art lint (limit 1.60) | Art T1 | 10.0 | Needs key |
| 5 | **Rot Deepens (Thi Độc Thâm).** Reused at a lesser grade: +40 points to ticks with the poison tag, L2. Burial Shroud's technique holds +180. If Death's Burial branch lists it as a node, one must give way | Passive T2 | 18.0 | Needs key |
| 6 | **Bitter Pearl (Khổ Châu).** Reused. Each 10 toxicity the clamp at 100 clips adds a grain for life, to 20. A grain counts as 1 đan độc for Per modifiers | Passive T2 | 18.0 | Needs rule |

## Keystones

Both read the same tree. Fever says the poison is in you, so it needs your toxicity and turns it into rate. Lodged Poison says the poison is in them, so it needs nothing of yours and reads their body. Owning one makes half the other's nodes idle, which is the choice.

### Fever (Độc Nhiệt), reused: the poison is in you

T3 and +7.5 `poison_damage_pct`, 34 W. **Needs key.**

- **Opens:** +1.5 `art_speed_pct` per point of đan độc, read at compile.
- **Closes:** reads 0 while `dan_doc_no_penalty` is held. High toxicity keeps its usual price: slower cultivation and weak pills.

### Lodged Poison (Ký Độc), new: the poison is in them

T3 and +7.5 `poison_damage_pct`, 34 W. **Needs rule** (Combat Formulas F). A poison is as strong as the body that carries it.

- **Opens:** a poison-tag tick you apply reads the target's `U` and stage in place of yours, with `supp` at 1. Your L1 to L4 still apply, so the plain lines stack.
- **Closes:** your poison-tag arts deal no hit damage, and only their status lands. A weak target gets a weak poison.
- **Bound:** `dot_pool_cap` and `dot_pulse_cap` do not move, so no target loses more than 8 % of maximum health a pulse from ticks, and it is still a clock of 12.5 s or more. Body guard, cleanses and status resistance all still apply.
- **Breakdown line:** "Bile, lodged: reads the target."
- **Second home:** any poison NPC set to fight above its realm, and the Poison stack in critic order 1.

## Rule Change Asked

**This tree asks for a change to dao.md rule 1, which allows one keystone.** It has two, and a character may own one. Both sit behind rule 8's gate, one whole branch and one node in each other branch. Buying either closes the other for that life, and rule 8 already says a bought node is never refunded.

The wording around rule 1 follows it: rule 8 and the state table (Mastered would mean every node but the closed keystone), rule 12 (a Đạo may carry two signatures), and N and `C_dao` in Formulas D1. Proposed reading of the lint: it runs once per keystone with the closed one left out, so 19 branch nodes and 2 keystones list 21 nodes, own 20 and still cost 60 points. Three branches of 7 and two keystones would list 23, so 7, 7, 7 is no longer legal. Until the user rules, this tree does not pass rule 1.

## Lint (Formulas D1), First Guess

V̄ = 2 × 3 × 2.07 = 12.42 W. Both keystones are T3 with the same 4 W line, 34 W, so each owner reads the same.

| Part | Measure | Band | Result |
|---|---|---|---|
| 1, owning Fever | 238.0 W over 20 nodes, mean 11.90 | 11.18 to 13.66 | inside |
| 1, owning Lodged Poison | 238.0 W over 20 nodes, mean 11.90 | 11.18 to 13.66 | inside |
| 1, as listed (both keystones) | 272.0 W over 21 nodes, mean 12.95 | 11.18 to 13.66 | inside |
| 2, The Tongue | 70.0 W over 7 nodes, mean 10.00 | 9.94 to 14.90 | inside |
| 2, The Fever | 62.0 W over 6 nodes, mean 10.33 | 9.94 to 14.90 | inside |
| 2, The Dregs | 72.0 W over 6 nodes, mean 12.00 | 9.94 to 14.90 | inside |
| 3, R(The Tongue) to Fever | 120.0 W over 10 nodes, mean 12.00 | at least 11.18 | inside |
| 3, R(The Tongue) to Lodged Poison | 120.0 W over 10 nodes, mean 12.00 | at least 11.18 | inside |
| 3, R(The Fever) to Fever | 112.0 W over 9 nodes, mean 12.44 | at least 11.18 | inside |
| 3, R(The Fever) to Lodged Poison | 112.0 W over 9 nodes, mean 12.44 | at least 11.18 | inside |
| 3, R(The Dregs) to Fever | 122.0 W over 9 nodes, mean 13.56 | at least 11.18 | inside |
| 3, R(The Dregs) to Lodged Poison | 122.0 W over 9 nodes, mean 13.56 | at least 11.18 | inside |
| 4, `art_speed_pct` | 24.0 W | no limit | no headroom rule |
| 4, `dan_doc_resist_pct` | 8.0 W | no limit | no headroom rule |
| 4, `poison_damage_pct` | 28.0 W | no limit | no headroom rule |
| 4, `status_resist_pct` | 16.0 W | no limit | no headroom rule |

**Where the W comes from, owning one keystone:** 8.0 W on F1 weights (3 %), 68.0 W at catalogue sizes on keys with no F1 weight (29 %), 162.0 W as tier credits for passives, arts and the keystone (68 %). Only the first part is a price. The rest is a first guess.

**Where the credit under-reads.** Per-toxicity passives are credited by tier, but at the sheet's đan độc 80 they deliver far more. Fever is +120 art speed, 320 W at catalogue size, against a 30 W credit. Bitter Measure is +120 points on one tag, about 64 W against 18. Inured Flesh is +24 resistance, 32 W against 10. Each is paid for outside the tree, by cultivation and pills, and the lint sees none of that. An observation, not a reason to shave them.

## Who Takes This Tree

A first buy can only be a branch opener (rule 8), so the table also names what the build is heading for. Reasons come from the sheets. No build was re-run on these nodes.

| Build | Keystone | Why | First buy | Heading for |
|---|---|---|---|---|
| The Taster's Fever | Fever | Home tree. The sheet's Foundation row wants Fever and Bitter Measure, and R(The Tongue) gives both plus Inured Flesh in 10 nodes, 30 points. Its full want adds Overheat and Bitter Pearl | The Tongue 1, +6 status resistance | Bitter Measure, Fever, then Overheat |
| The Great Tonic | None | Its ledger row says the Canon has no answer to poison. The Tongue is that answer, and Water is already there, if it reaches purity 30 | The Tongue 1, +6 status resistance | Inured Flesh |
| The Thousand Scales | None yet | Ticks are the whole build and Water is in the root, but it is happy at any purity, and its fight file carries no poison tag, so this tree's lines read nothing on its wounds. It needs purity 30 and its wounds retagged | The Dregs 1, +15 poison damage | Measured Dose |

**Wanted, barred:** The Stand-In keeps Water out on purpose, and its Fever is a curse on a technique, so it needs nothing here. The Wedding Furnace has no Water.

**Lodged Poison has no build tonight.** Burial Shroud is not a taker: its tick already reaches the cap, and it dies to hits, not to a weak clock. The keystone is written for the plain Poison stack in order 1, and `poison_damage_pct`, Measured Dose and Rot Deepens are the nodes that stack would use.

## Rule Checks

- **Stat lines:** theme stats only.
- **Passives in one tree: one conflict.** Overheat is in this tree and in Array's Host branch (`sheets/remnant-host.md`). Rule 12 forbids it. Poison keeps it: it began here and reads as heat, and an array does not. Host must find another home, such as a cluster notable. The cost is small either way: `--without speed_overflow` moves Remnant Host's typical one-up win from 1.0 s to 1.5 s and Taster's from 2.5 s to 3.0 s (`sheets/remnant-host.fight.json`, `sheets/tasters-fever.fight.json`, `--matrix`). Spillover stays in Destruction and Death, not here.
- **No ceiling raise:** no ceilinged key is touched. `art_speed_pct` still has to reach Character Stats (Combat Open Question 21). Kept Warm uses an existing key at a negative value.
- **Name hidden:** dose, tongue, dregs, a sick heat, what a failed brew leaves. It reads as poison with nothing else in the frame.
- **Art node:** First Taste waits for the fight to be built. Measured Dose lengthens a status past the record the status lint reads, so Bile runs 1.5 against a 1.2 limit. The lint does not see it.

## Not Tested

No fight was run for this tree. Lodged Poison, Measured Dose, Running Hot and the lesser Rot Deepens have no plug-in, and the only calculator numbers here are the two Overheat removals above. Whether Lodged Poison reaches the caps against a realm above is unknown until a build is written for it.
