# The Cheap Kit: Options Study
> Overnight analysis, 2026-11-07, for the user to read. Paper model. **Nothing here changes the game, and the user has made no decision.** Plug-ins: `rules/study_*.py`. Every number is a saved run in `scratch/kit-study/`: `results/summary.tsv` holds the table, and `run_study.py`, `run_grid.py`, `run_best.py`, `run_mirrors.py` and `run_cost.py` regenerate it.

**Answer: leave it alone for now, and decide before arts are authored or Formulas K is built.** The kit is real, and its owner pays almost nothing for it. But nothing live reads it, no option rescues a first line, and waiting costs nothing. If the user wants slow kits to matter, the curved lint (A2) is the one to take.

## Results
Each option applies to both sides, so the panel's enemies are repriced too. One setting is shown per option, from 20 run.

| Option | First lines rescued (wins) | Is today's kit still best? | 3 s+ kit ties the best | Best-kit wins | Named wins | What it breaks |
|---|---|---|---|---|---|---|
| Today | n/a (1,1,1,1) | Yes, 4 of 4 | 0 of 4 | 4,5,5,5 | 5,5,5,5 | |
| A1. Lint term below 1 s, −1.0 × (1 − cooldown) | 0 (1,2,1,1) | No. 1 s on three chassis, 0.5 s at cost 0.20 on Grindstone | 0 | 2,5,4,5 | 5,5,5,5 | Nothing new, and it fixes nothing new: its best kits win exactly what the known 1 s floor wins (2,5,4,5) |
| A2. Curved lint, (1 + 12 × cost) × cooldown^0.75 (my idea) | 0 (2,2,1,2) | No. 1.5 to 1.9 s on three, 0.5 s at cost 0.10 on Grindstone | 2 | 4,5,4,5 | 5,5,5,5 | Exotics gain: Already-Waited's Wall 9 s to 3 s, Seven Lamps' 20 s to 12 s. At exponent 1, one kit again (1.9 s on all four), and Rice Pestle loses the Wall |
| B. Cost floor, max(0.04, 0.06 / cooldown), buying no coefficient | 0 (1,2,1,2) | No. 1.5 to 1.9 s on three, 0.5 s at cost 0.20 on Grindstone | 1 | 2,4,4,5 | 5,5,5,5 | Weakens every chassis. At 0.12, ties 4 of 4 but Banked Well and Rice Pestle lose the Wall. **If the floor buys coefficient it backfires:** 0.5 s at cost 0.14 is best on two chassis and Pine Rain wins at 0.5 s |
| C. First firing at 1 + 0.5 × (cooldown − 1) | 0 (0,1,1,1) | Yes, 3 of 4 (0.5 s at cost 0.14 on Grindstone) | 0 | 4,5,4,5 | 5,5,5,5 | AC-CB-32, and rule 13's decision of 2026-11-06. Fierce Fire's first line loses its one win. At share 0, a 10 s kit is best on two chassis: a new one-volley kit |
| D. Limit of 3 firings a pulse per side | 0 (0,1,1,1) | No, but 0.5 to 0.75 s is still best on three | 2 | 1,4,4,5 | 5,5,5,5 | Weakens every chassis, and later slots starve: 3 of Scattered Sparks' 6 arts fire 0 times. At a limit of 2, AC-CB-32's 3 s art never fires |
| A2 + C together | 0 (3,2,2,2) | No. 3 s, 3 s, 1.5 s, 4 s | 4, best on 3 | 4,5,4,5 | 4,4,5,5 | Banked Well and Rice Pestle lose Pulse (enemy on 16 % and 21 %). Two rule changes, one against a user decision |

- **Order.** Lines: Fierce Fire, Evergreen, Grindstone, One Long Word. Named: Banked Well, Rice Pestle, Seven Lamps, Already-Waited. **Rescued** means the unchanged first line wins as many panel fights as the best kit on its own chassis.
- **Best-kit wins** is the best of 54 uniform legal kits per chassis (9 cooldowns, 6 costs) on the second line's rows, so the option cannot be beaten by re-picking a kit. At 3 s or more, Short Art reads as Patient Art, the same size. Every quoted kit re-ran with saved inputs, 0 mismatches.
- **Macro anchors and AC-CB-30 hold under all 20 settings.** FX-U draws at 25 s. FX-T draws at 8 s, firing at 1, 2 and 3 s. Typical mirrors at all five realms still end at 5 or 6 s and top-end mirrors at 1 s, because the fixture art is a 1 s art and every option pivots at 1 s. An option without that pivot would break them. **Breakthrough and population targets: not assessed.** No art record exists in `src`, `assets`, `tools` or `tests`, and the full fight is on hold, so nothing in them reads this lint.

## Why no option rescues a first line
1. **They do not lose to the kit.** They lose on rows and ward. The kit on first rows wins only 1, 4, 4 and 1 (`-kit-only`). The options take from the kit and add little to these lines.
2. **The rule binds enemies too.** Under C, the Mixed enemy's heavy arts also arrive sooner, and Fierce Fire's first line drops from W 5.0 to L 30. Under D its four-art volley is split, and it falls to L 5.
3. **Slow kits have two faults.** Typical mirrors end at 5 to 6 s, so a 6 s art fires once at most. A2 repairs the rate, C repairs the lateness, and only the pair puts a 3 s kit on top.

## Does the kit cost its owner something else?
Mostly not, so "it pays elsewhere" does not hold up.
- **Pool and depth: no.** Same rows, against a 1 s kit and two 3 s kits, on Mixed at ×1 to ×8 pools, one realm up, and three fights in a row: kit ahead 21 of 24, tied 1, within 2 points 1, behind 1 (`results/cost-readout.txt`). The chain is a test device: Combat has no such rule.
- **Slots: a little.** It fills 6 of 6 and 7 of 7, leaving no room for a curse, status or soul art. Yet Short Reply keeps Standing Word and still wins 5.
- **One real counter: a per-pulse ward.** Pine Rain is dry by 1.5 to 2.5 s and loses to Banked Well (enemy on 7 %) and Seven Lamps (36 %, at 503 W against 361.2), though it beats Rice Pestle in 1.0 s. Slow Evergreen does worse in all three, with the enemy on 64 %, 72 % and 47 %.
- **A narrower problem than it looks.** On the same rows, 1 s kits match its wins on Evergreen, and 1.9 s kits on One Long Word. The real divide is under 2 s against 3 s and over.

## What each option costs in rules text
- **A1:** one term in Formulas C's lint, one key, AC-CB-57's 1.355 case, and `c_art`'s floor of 1.2, since this art lands at 0.855.
- **A2:** rewrite the lint and the `art_coef_per_cooldown` row, one key, AC-CB-57's 5.00, 11.25 and 1.355 cases, the calculator's lint check, and the same 1.2 floor (0.88 here).
- **B:** a floor line in Formulas E, one key, a surcharge clause in Formulas C's lint, and new AC-CB-57 cases. The clause is not optional.
- **C:** rule 13's first-firing sentence, one key, Formulas A2's "fire nothing before 3 s" paragraph, and AC-CB-32. It also shrinks the catalogue's first-firing row.
- **D:** a new rule and key, a slot-priority sentence, a ruling on which arts count, a term in Formulas K's `c_rate`, and new ACs. Slots past the limit (Open Question 22) and art speed (Open Question 21) lose value.

## Recommendation
**Leave it alone for now.** No macro number moves under any option, so this is a variety question, and the user has said strong builds are fine while the macro holds. It is not a reason to rebalance tonight.

**Decide before Formulas K is built.** Its `c_rate` reads `c_art / cooldown`, so at full uptime a seven-slot kit rates 19.97 against 5.62 for 3 s arts, and that would reach `display_power`.

**If the user wants slow kits to matter, take A2 alone.** It removes today's kit on 4 of 4 chassis, keeps all four named builds at 5 of 5, and costs one formula. Price Already-Waited's timer rule first, because A2 pays more for a wait that rule deletes. Add C only if a 3 s kit must be *best*, not just level, since that reverses a user decision. Avoid A1 (it is the 1 s floor again), C alone, D, and B without its clause.

**Limits.** Uniform kits only, no mixed ones. Five enemies, a paper model, one strength per row. All these lints read the authored cooldown, so art speed may walk round them: not run, and unpriced (Open Question 21). `panel.md`'s Banked Well row is stale: it predates the sheet by 41 s. Its saved variants give Pulse 5.0 and Wall 14.0, which this study uses.
