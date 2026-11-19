# Fire w2 progress (window 2: every pair of cells sharing a wall road; brief design/dao-do/cells/review-brief.md)

Backup before the pass: out/fire-w2-bak.py (the ONLY undo: design/dao-do/cells/ is untracked in git).
Baseline (tag fire-w2a = fire-w1 final): fire cells 892 nodes / 3445 = 0.259; mix.py `fire pieces 177 small 108 (61%)
medium 42 (24%) big 27 (15%) nodes 1050` (without border cell 931's 20 small: 157 = 56/27/17 %); repeats 17; 9 notable
pairs < 1.5 (2 in locked 15, 7 at 1.33-1.46 as listed in the w1 file). 0 crossings, spacing base 4 only, 231 pieces pass.
Scratch: fire-w2-rpair.py (pair window render), fire-w2-pairs.sh <tag> a,b ... (clean + labelled), fire-w2-diff.py (per-cell diff).
Propagation: 29/37/62/74 are mirrors; pair() pieces live in two cells; live corona at the end of the file; flame_a/flame_c
regrown at the end; 37 sun, 29 wisp/sunrise overridden separately.

Pairs (51 sharing road nodes + rim): frozen both sides (look, "left"): 14|15 14|93 15|93 3|83 14|rim 15|rim.
Corner contacts (one shared road node, quick look): 18|62 18|92 14|92 37|63 37|93.
Open-question windows first: 47|105 56|105 56|rim 47|56 28|47 49|101 63|18, then the sweep.

| pair | weak | change |
|---|---|---|
| 47\|105 | 47's spark-hook half wedged between the wing's feathers and the eye (1.33 from feather f1), so feathers f1/f2 stayed one-link spikes; 1602 busy (hooks both sides + eye); 105's upper right empty | 47 half of spark_hooks deleted (105 keeps its half as a plain hook off 1602); wing feathers f1, f2 two nodes each, parallel to f0; new hook w_hook_1601 in 105 (wall frame round 1601, phi 82/72/56, rho 1.0/1.95/2.75) curling out towards the spoke, answering the 1602 hook across the trident's tine |
| 56\|105 | 1944 carried the crown (56) and 105's C Crook (a cross of sticks on the spoke); that Crook 1.46 from the 1567 hook | 105 C Crook removed; the trident keeps one small piece in each corner (hooks 1602/1601, hook 1567, D Crook 506) |
| 56\|rim | 1569 carried taiji_b, d_fork_1569 and the rim trefoil; the bottom wall of 56 three sticks in a row (C Crook, D Crook, fork) | d_fork_1569 removed; D Crook 1570 turned ang 10 -> 35 into the fork's place (also clears its 1.44 clump with taiji_a). Rim untouched. Density debt: 56 37 -> 33 |
| 47\|56 | nothing clearly weak (loop flame on 1604, crown on 1944, taiji_a on 1605 well spaced) | left |
| 28\|47 | corner by 1584 a little busy (wing stem, fork 1584, horizon sun) but spaced; sunrise horn 1.45 from lily petal | tried sunrise horns +-50 (1.41) and +-62 (0.85 spacing to the lily): reverted; left |
| 49\|101 | 101's spark star tip t4 1.39 from the 518 fork (corner too tight: six fork re-aims all < 1.25); 101's bottom (between star, split ring and the 1557 wall) empty | star turned 12 deg (a0 -92 -> -104; it now stands upright, clump gone); a Hairpin 'tight turn' off 1557 (ang 30) arching over the empty bottom between the star and the split ring (chosen by eye over Diamond cusped/round, which passed too; Tadpole, Ring, Arch, Spur, Crescent, Hook failed) |
| 18\|63 | 63's ring off 1555 1.38 from the halo tip, and back to back with 18's sun ring on the same node (look-alikes across the wall) | ring 1555 removed (tried ring re-aims -15/-5, a Hook/Tadpole/Diamond/Crescent/Hairpin/Arch at 1554/1555: clumps 0.2-1.04 with the corona tip or the ember; one Hook at 1554 passed but crammed three notables together by eye). Density debt: 63 40 -> 35 |
| 53\|101 | the split ring reads across the spoke; 101's new hairpin and 53's hairpin 1560 are the same family ~10 apart with the star and ring between | left |
| 101\|rim | the rim beyond 101 (and 105) is empty, but that is the rim's design | left (rim not touched) |
| 3\|62, 3\|63, 3\|119, 3\|120, 62\|63 | nothing clearly weak across these walls (3 sparse by design; the corona/halo mirror pair reads as one sun round 67) | left |
| 62\|119, 63\|120 | flicker / comet sit clear of the corona | left |
| 18\|28, 28\|70 | the crowded corner of four cells at 1586/1587: the sunrise (28) on 1586, three lily petals on 1587, 70's B Diamond on 1586 under the sunrise (five small shapes in ~5x5 units), while the spoke beside it is open | 70's B Diamond off 1586 (stem 1.2) taken out of the junction (re-hanging on spoke node 1940 impossible: not a road node); later (density row) a curled-stalk Tadpole on a 2.0 stem from 1586 hangs into 70's empty upper right instead |
| 29\|74 | the same corner mirrored at 1579/1580 (sunrise lens, lily petals, 74's B Tadpole on 1579) | 74's B Tadpole (stem 1.1) taken out of the junction; later replaced by a Hook 'bow in' on a 2.0 stem from 1579 (70's lantern mirrored here stood ring head to ring head with 49's torch across the spoke: rejected by eye; Diamond cusped/round/lop-sided and Fork failed spacing; Spur pair, Crescent passed but read as sticks) |
| 29\|62, 29\|119, 29\|49, 37\|74, 37\|92, 18\|70, 28\|63, 28\|120, 18\|37 | nothing clearly weak across the walls (1545: lens up / crescent down; 1544: flicker / spiral; 1552: fork / pinwheel; 1583: diamond / crook, each pair on opposite sides) | left |
| 56\|70 (and 14\|56) | 1606 carried 70's core Tadpole, 14's H Diamond and 56's Diamond: two near-twin Diamonds side by side (look-alikes, not quite mirrored) | 56's Diamond made the exact mirror of 14's H Diamond across the 14\|56 wall spoke (wall_pair 1606-1571): a split figure on the wall, 14 untouched |
| 47\|70, 49\|74, 53\|74 | (after the lantern / hook) nothing clearly weak | left |
| 70\|93, 74\|92, 92\|93, 14\|70, 14\|92, 15\|53, 15\|74, 15\|92, 18\|93, 37\|93, 37\|62, 37\|63, 49\|53, 18\|62, 18\|92, 53\|rim, 105\|rim | nothing clearly weak across these walls (1938: 93's locked ray fan and 70's embers back to back, spaced; 1559 fleur + rim trefoil a straight cord like 1569) | left |
| frozen: 14\|15, 14\|93, 15\|93, 3\|83, 14\|rim, 15\|rim | looked at | left |
| density | the decrowding cost 14 nodes | paid back in the empty patches the windows showed: 56's open spoke strip by 1944/1568 gets an outer orbit arc round taiji_b's own centre (rho 2.6, angles 100/118/137/155 round the spiral's centre, stem from 1944; +5); 70's empty upper right a curled-stalk Tadpole on a 2.0 stem from 1586 ("lantern"); 74 a Hook on a 2.0 stem from 1579 (70 and 74 differ in that one piece again) |

FINAL (tag fire-w2, render out/fire-w2.png): fire cells 892 nodes / 3445 = 0.259 (baseline 892, 0.259). Per changed cell:
47 38->37, 56 37->38, 63 40->35, 70 35->36, 74 36->35, 101 25->30, 105 25->25 (pieces moved). mix.py `fire pieces 176
small 107 (61%) medium 42 (24%) big 27 (15%) nodes 1050` (baseline 177: 108/42/27); without border cell 931's 20: 156 =
56/27/17 % (baseline 157 = 56/27/17 %). Repeats 17 (unchanged). 0 crossings, spacing = base 4 only, all 230 pieces R0-R4,
every node inside its cell, cells 14/15/93 unchanged; changed cells vs fire-w2a: 47 56 63 70 74 101 105 only (3, 83, 901,
borders untouched). Notable pairs < 1.5 in Fire: 9 -> 4 (2 in locked 15; the two 1.45 sunrise/lily pairs in 28/29 kept).
Split wall figures: one removed (spark hooks 47|105, only 105's half kept), one made (the 14|56 Diamonds on 1606).

Open for w3 (neighbourhoods):
- 63 by 1554 (where the 1555 ring was) is open; every small piece tried there crammed the corona tip / ember.
- 105: the left middle (where the 1944 C Crook was) is a little open; the trident is now ringed by four small pieces.
- 101 and 53 both hold a Hairpin (101's new one off 1557, 53's off 1560), ~10 apart.
- 70 holds two Tadpoles (the core from 1606, the lantern from 1586).
- 56's new orbit arc and 105's hook 1601 are short chains; judge them in the neighbourhood.
- 56's Diamond on 1606 now derives from cell14.py's H_diamond (wall_pair): it follows any change to cell 14.
- 28/29 sunrise horn vs lily petal 1.45 (horns +-50/+-62 tried, worse).
- The rim beyond 101 and 105 is empty (rim design, not touched).
