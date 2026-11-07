# Keystone Proof: Is the Two-Keystone Choice Real?

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Keystone sizes are first guesses. A paper model.
> **Order**: critic waves 4 and 5, order 4. Two of the seven second keystones, run in a fight for the first time.

**Answer.** Poison: yes, the choice is real, and each keystone wins fights the other cannot. Examination: only half. First on the List beats Peach and Plum in every duel a comprehension of 70 or more can fight, and Peach and Plum's other half, the pupils, repays little. So the ask is worth making, but First on the List needs a smaller number and Peach and Plum needs a reason in a fight.

**How it was run.** Each file is a saved variant, and no sheet was edited. `route` means the same Đạo nodes with no keystone, so a keystone is compared with what you would own without it. All files share the 27 to 30 points paid for the Way. Run from the repo root with `fight_x.py variants/[name].fight.json --gap [n]`. Plug-ins: `rules/lodged_poison.py`, `rules/first_on_list.py`. Enemy is the mixed enemy unless named.

## Way of Poison: Fever or Lodged Poison

**The sheet: The Thousand Scales,** a named taker, all ticks, Water in the root, and able to live long enough for a clock. It needs purity 30 and its wounds tagged poison, as `poison.md` says, and these files assume both. Route is R(The Dregs): +30 poison damage and Rot Deepens on the wounds, +3 art speed, paid for by −28 ward strength and efficiency. Fever is run at đan độc 40 (+60 art speed).

Cell: result, time, then own health, or the enemy's on a loss. `thousand-scales-key-[name]`.

| Gap | `route` | `fever40` | `lodged-closed` | `lodged-open` |
|---|---|---|---|---|
| 0 | Win 4 s, 90 % | **Win 3.1 s, 92 %** | Win 5 s, 88 % | Win 4 s, 90 % |
| 1 | Win 5 s | Win 5 s | Win 5 s | Win 5 s |
| 2 | Loss 3 s, enemy 35 % | Loss 2 s, enemy 45 % | **Both down at 6 s** | **Both down at 5 s** |
| 3 | Loss 1 s, enemy 93 % | Loss 1 s, enemy 93 % | **Loss 1 s, enemy 39 %** | **Loss 1 s, enemy 9 %** |
| 2, `--without parting_cut` | Loss, enemy 77 % | Loss, enemy 86 % | **Loss, enemy 61 %** | **Loss, enemy 45 %** |
| 3, `--without parting_cut` | Loss, enemy 99 % | Loss, enemy 99 % | Loss, enemy 92 % | Loss, enemy 92 % |
| Fast (`-fast`) | Win 3.9 s, 85 % | **Win 3 s, 87 %** | Win 5 s, 79 % | |
| Wall (`-wall`) | Win 5.8 s, 94 % | **Win 5 s, 94 %** | Win 6 s, 93 % | |

- **Real: same realm is Fever's, two realms up is Lodged Poison's.** Neither beats the other on both. One realm up they tie, each winning on under 1 % health, and the route alone already turned a double knockout (`thousand-scales-mixed --gap 1`) into that win, so the branch does more work there than either keystone.
- **The surprise is at gap 3.** A Foundation cultivator dies at t = 1 to a Deity Transformation enemy and takes it to 9 %. Parting Cut keeps the wounds running after death, and Lodged Poison makes them a share of the Deity's own body. Fever leaves it on 93 %. Parting Cut was not written for this.
- **Parting Cut is the gap 3 result, not the gap 2 one.** Take it away and Lodged Poison still leaves a realm-two enemy on 45 to 61 % where Fever leaves 86 %. Two realms up it is the better keystone with or without. Three up, it needs to go on ticking after death.
- **Second Sickness, with real hits on its poison arts, is harmed.** At Core `second-sickness-key-route` wins at 9 s on 31 %. `second-sickness-key-lodged` loses at 9 s with the enemy on 10 %. It also has no Water, so it could not walk this Way. Its thin doses were the hit that kept the fight moving.
- **Fever users cannot swap.** `tasters-fever-key-fever` wins at 1 s and a realm up at 3 s. `tasters-fever-key-lodged` wins at 9 s and loses a realm up with the enemy on 65 %. Every art on that sheet is poison-tagged, so all its hits go.
- **More Fever is not always better.** At đan độc 80, `fever80` wins the mirror at 3 s and turns the one-up win into a double knockout at 6 s. Toxicity's own price is outside the fight.

**One flaw to fix.** "Your poison-tag arts deal no hit" is avoidable: `lodged-open` tags the wounds and leaves the strokes untagged, so it keeps every hit and every Thin Bleed trigger. That is the same as `route` in a mirror and better at gap 2 and 3, so the keystone costs nothing. `lodged-closed` tags the strokes, loses a second in a mirror, and falls from 9 % to 39 %. The rule should read "arts that apply a lodged tick deal no hit", or tags should pass from a status to its art.

**Both at once (`thousand-scales-key-both`):** 5 s, 88 %, and both down at 6 s, no better than `lodged-closed`. With no hits, speed buys little. So exclusivity barely binds here: the keystones already pull apart.

## Way of the Examination: First on the List or Peach and Plum

**The sheet: The Long Carry at Core,** the named taker of Peach and Plum, with W in L1 to give back (`long-carry-core`, 4 s on 34 %, L1 85). Route is R(The Classics) with Clear Reading read at the stated comprehension. The 62 W of the Way comes out of L1 and defence in `route` and Peach and Plum. First on the List pays it out of its dead L1, and the last 23 W goes to health. Clever Harm is shown as lost crit, at Formulas I's 0.001 a point. Commentary is left out of all files.

Cell: time, own health. One realm up, in brackets: the enemy's health when you die. `long-carry-key-[name]`.

| Comprehension | `route-c` | `first-c` | `peach-c..-p100` | `peach-c..-p1000` |
|---|---|---|---|---|
| 45 | Loss, enemy 4 % (96) | Win 4 s, 42 % (89) | Win 4 s, under 1 % (95) | Win 3 s, 35 % (94) |
| 70 | Win 4 s, under 1 % (95) | **Win 3 s, 48 % (84)** | Win 4 s, 23 % (95) | Win 3 s, 35 % (93) |
| 100 | Win 3 s, 35 % (94) | **Win 3 s, 66 % (76)** | Win 3 s, 35 % (94) | Win 3 s, 47 % (91) |
| 150 | Win 3 s, 35 % (93) | **Win 2 s, 72 % (64)** | Win 3 s, 35 % (92) | Win 3 s, 57 % (89) |

- **In a duel it is not a choice.** At comprehension 100, a thousand pupils are worth 12 points of health and a hundred are worth none. First on the List is worth 31. Only at 45, with a thousand pupils, does Peach and Plum win anything, one second, on less health.
- **The price does not bite the median student.** Clever Harm starts above 50. `first-c50` costs no fortune at all and still wins at 4 s on 42 %, better than the 34 % on the sheet with all its W in L1. Twice a talent of 45 is 90, and a typical Core life buys L1 112 for a quarter of its tree. The ×2 hands that quarter back.
- **×1.5 looks right, as a first guess.** `first-c100-s15` keeps 3 s on 66 %, the same as ×2. `first-c45-s15` falls to 4 s on 31 %, just under the sheet's 34 %. So the scholar keeps the keystone, and the dull student no longer profits. `-s10` is too far: 5 s on 17 % at 45.
- **The pupils repay less than the text promises.** A comprehension 20 disciple holding this Way loses with no Text (`pupil-no-text`, enemy on 4 %), and wins at 3 s on 35 % reading S 100 (`pupil-text`). That looks large, but the same disciple with no Way at all is `long-carry-core`, 4 s on 34 %. So the Text mostly repays the 30 points the Way cost them.
- **The named taker needs neither.** The Level Ground wins in 4 s on 93 % on `route`, 95 % with First on the List and 93 % with Peach and Plum, whose L4 sits over the cap at 255 and adds exactly nothing. Blind, all three die at t = 1 with the top-end enemy on 99 %. `level-ground-key-[route, first, peach]` and `-blind`, against `top_end`. The Way's taker table oversells First on the List here.
- **Exclusivity binds here.** `long-carry-key-both` wins in 2 s on 72 %, better than either, so a rim keystone that is not exclusive would be taken twice.

## What This Means for the Ask

| | Poison | Examination |
|---|---|---|
| Does each keystone win a fight the other cannot? | Yes | No, at comprehension 70 or more |
| Does each serve a different kind of life? | Yes: same realm or upward | Yes on paper: self or sect, and the sect half is thin |
| Would a non-exclusive rim keystone do? | Probably, they barely stack | No, they stack |
| Fix first | Close the tag loophole | First on the List to ×1.5. Peach and Plum needs a fight reason, or the game needs to score a sect |

**This is 2 of 7.** Slip or Fixed Number and the animal keystones are still unrun, so this supports the ask and does not settle it. Fever at đan độc 40 is a chosen level. The Thousand Scales needs a purity and a retag it does not have today. Clever Harm's −40 fortune is shown only as crit, and it reaches every chance roll and escape, so First on the List's price is a little under-read here. Nothing here tests NPCs.
