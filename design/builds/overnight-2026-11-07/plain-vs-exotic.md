# Plain Rows Against Exotic Pieces
> Overnight analysis, 2026-11-07. Paper model. Each number is a saved run: `variants/[file]-[mixed|pulse|wall|evader|fast].fight.json` through `_tools/fight_x.py`. First lines are `panel.md`. Second lines change no sheet.

**Answer: yes, plain rows can beat the panel.** At the same W and realm, 3 of the 4 builds win 5 of 5, and Fierce Fire wins 4 of 5. Every line stays inside the art lint on the common ward.

| Build, realm, W | Line | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|---|
| Fierce Fire, Nascent Soul, 261.8 | First | W 5.0 | L 56 | L 91 | L 71 | L 90 | 1 |
| | Scattered Sparks (Tán Tinh) | W 1.5 | W 2.0 | L 83 | W 2.0 | W 1.0 | 4 |
| Evergreen, Deity, 361.2 | First | W 6.0 | L 27 | L 78 | L 39 | L 73 | 1 |
| | Pine Rain (Tùng Vũ) | W 1.0 | W 2.0 | W 8.0 | W 1.5 | W 1.0 | 5 |
| Grindstone, Qi Refining, 81.6 | First | W 4.0 | L 0 | L 82 | L 32 | L 59 | 1 |
| | Thin Shavings (Tế Tiết) | W 1.0 | W 1.5 | W 4.0 | W 1.5 | W 1.0 | 5 |
| One Long Word, Foundation, 76.8 path | First | W 7.0 | L 32 | L 89 | L 53 | L 83 | 1 |
| | Short Reply (Đoản Đáp) | W 1.5 | W 2.0 | W 6.0 | W 2.0 | W 1.0 | 5 |

W time, or L and the health the enemy kept. W counts 1.2 an acupoint, 8 a notable and 1 an L1 point, which reproduces the totals on the plain sheets. Files: `[slug]-second-way`. Each line keeps its acupoint and notable counts. Fierce Fire and Evergreen keep their trunks. Short Reply keeps Standing Word, drops the curse road, and moves 92 W from ward (`ws` and `we` 84 to 38) into L1 (5 to 97).
## What the winning change had in common
1. **One kit, four times.** Every line fills its slots with the cheapest legal art: cost 0.04, 0.5 s, `c_art` 1.355. First firing equals cooldown, so the first hit lands at 0.5 s and not at 3 s.
2. **Rows on empty layers.** Short Art (L2) is in all four, with Steady Breath (L5) in three. Thin Shavings and Short Reply also fill an empty L1. Fierce Fire's L1 is already at 185, so it has no such cheap step.
3. **Neither half works alone.** Kit with first rows (`-kit-only`) wins 1, 4, 4 and 1. Second rows with first kit (`-rows-only`) wins 1, 1, 2 and 2. Together: 4, 5, 5 and 5.
4. **Qi arts open the Wall.** Pine Rain with four qi and three body arts loses, Wall on 9 % (`evergreen-second-way-mixed-kinds`). All qi wins at 8 s.
5. **Not the curse.** Short Reply `--without standing_word` still wins the Wall, at 8 s on 22 %. The L1 move does it.

**The honest limit.** These are one build in four coats, so this shows the rows are strong enough, not that the paths feel different. Fierce Fire's Wall stays lost: its pool is dry at 2 s. The best Wall-only line found still ends with the Wall on 29 % (`fierce-fire-second-way-wall-best`). That is a search, not a proof.
## Plain best against exotic best, at equal W
W tally from the fight files, Nascent Soul, against the same five enemies. Already-Waited: L1 188, regeneration 8, ward 15, body guard 30, less 51 of health and linh lực it gave up. Cut Line: thần thức 333, `x_soul` 24, regeneration 16, linh lực 16, ward 15, less 47 of health.

| Line | W | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|---|
| Already-Waited, whole | 190 | W 2.0 | W 2.0 | W 9.0 | W 2.0 | W 1.0 | 5 |
| Already-Waited, priced pieces only (`already-waited-priced-only`) | 190 | L 78 | L 78 | L 89 | L 86 | L 91 | 0 |
| Scattered Sparks, cut to the same W (`-second-way-at-190`) | 190 | W 1.5 | L 9 | L 87 | L 29 | L 42 | 1 |
| Cut Line, whole | 357 | W 0.8 | W 0.8 | W 1.2 | W 0.8 | W 0.8 | 5 |
| Cut Line, benders removed (`cut-line-plain-rules`) | 357 | W 3.5 | W 3.5 | W 6.5 | W 3.5 | L 36 | 4 |
| Scattered Sparks, +96 W (`-second-way-plus96`) | 358 | W 1.5 | W 2.5 | W 6.0 | W 2.0 | W 1.0 | 5 |

**The gap is not in the plain rows.** At 190 W plain beats Already-Waited's priced pieces, 1 win to 0. At 357 W plain ties Cut Line's five wins and beats it with its benders removed. What is left against the whole Cut Line is speed: 6.0 s against 1.2 s on the Wall.

**Unpriced share.** Already-Waited: 193 of its 461 peak damage points (42 %) have no W price (capability +42, Cornered +50, In Step +50, Heart Demon's Blade +51), and its timer rule has no number at all. Measured by wins, all 5 of 5 are unpriced. Cut Line: its W is priced, but its damage is not. M is 1.00 and soul arts have no lint. Its rules add one win and cut 3.5 s to 0.8 s, and the other four wins come from unlinted arts. The Wall also shows the ward model is unpriced: Vinegar Cloth wins 5 of 5 at Fierce Fire's own W (`-second-way-cloth`, Wall 18 s on 6 %).
## Recommendation
**The exotic pieces are underpriced. The plain rows are not too weak.** The first lines lost because they copied the enemy's slow kit, left layers empty, and sometimes parked W on the ward, not because the rows are small. Do not raise plain rows. Price rule pieces, soul arts and ward models first, and decide whether the cheap 0.5 s art is meant to be the best art in the game.

**What would change this answer:**
- **A slower floor.** With a 1 s floor (`-second-way-cd1`), the lines win 2, 5, 4 and 5. Fierce Fire falls to 2, so its case rests on that art.
- **Row placement.** Sustain's named rows at ×0.25, a sector the root lacks (`-second-way-offground`), give 1, 4, 4 and 4. If Short Art cannot sit on every root's ground, Fierce Fire's plain rows are too weak, and the Wall goes for all four.
- **Real play.** If players cannot find this kit, plain paths are weak in practice. And every enemy here dies to early hits, so an enemy that punishes cheap volleys could reverse the result. The panel needs one.
- **Already seen:** The Seven Lamps at the legal 0.10 still wins 5 of 5 at the same times. It is plain rows, but on a Stone Ward and 503 W.

## Addendum: is the cheap kit dominant? (orchestrator, 06:55)

The report above says the panel needs an enemy that punishes cheap volleys. `_tools/thorn_test.py` runs one: the Mixed enemy with `rules/thorn_skin.py`, which charges a fixed amount for every hit that lands, whatever its size. It reverses the expectation. **The kit wins every run, and the slow lines are the ones that die.**

| Thorns per hit (fight units) | Slow first lines | Kit second lines |
|---|---|---|
| 0.25 | 4 of 4 win, on 0 to 22 % health | 4 of 4 win, on 70 to 88 % health |
| 0.5 | 3 of 4 win, on 0 to 15 % health | 4 of 4 win, on 56 to 80 % health |
| 1.0 | 2 of 4 win, on 0 to 1 % health | 4 of 4 win, on 29 to 65 % health |

The kit ends the fight in 1 to 1.5 s, so it pays few thorns. A fast kill beats the punishment for being fast.

**Why, from the lint.** Formulas C prices cooldown linearly, so going from 1 s to 0.5 s costs only 0.125 of coefficient. At cost 0.04 a 0.5 s art gives 2.71 coefficient a second, a 1 s art 1.48, a 3 s art 0.66 and a 6 s art 0.46, while fights last seconds and the pool rarely binds. A 1 s floor does not fix this: the `-second-way-cd1` lines still win 2, 5, 4 and 5.

**So there may be a dominant kit.** On this evidence, the cheapest short art filling every slot beats every slow kit in the plain tree. The paths then differ in rows, not in play. This is the campaign's most important design question for the user, and nothing has been changed for it. Limits: a paper model, one test enemy, and thorns are a test device rather than a proposal.

## Correction to the Addendum (orchestrator, 07:40)

The Addendum above overstated this. `kit-hunt.md` tested it properly: **the kit is dominant only on the common drain ward.** Plain builds with slow arts beat all three kit lines at equal W and realm, with 0 rule asks, once a per-hit or per-pulse ward exists, and the results form a cycle rather than a ranking. The ward decides it: `--without ward` loses all three hunts. On the common drain ward with cooldowns of 1 s or more, 0 of 8,000 random lines per realm won, so that part of the worry stands. The three wards used are overnight records, not game data, so the answer rests on Combat Open Question 18, the ward spell catalogue. `kit-options.md` recommends leaving the lint alone for now.
