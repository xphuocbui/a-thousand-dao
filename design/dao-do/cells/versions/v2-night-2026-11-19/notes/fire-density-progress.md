# Fire density progress (2026-11-18, brief design/dao-do/cells/density-brief.md + user update: any good means, mixed)

Baseline fire-d0: 630 nodes / 3445 = 0.183; mix `small 57 (50%) medium 42 (37%) big 15 (13%)` (incl. rim 901).
Locked: cells 14, 15, 93 (no halves, no changes). 3 (start) and 83 (hub) stay sparse. Rim 901 not counted, skipped.
Scratch: out/fire-dloop.sh <tag> (check + named problems + in-cell/density + mix), out/fire-dspot.py, out/fire-dcheck.py,
out/fire-rcell.py (close-up render, --grid --labels).
All new work sits in the "DENSITY PASS" section of lands/fire.py, before the FIRE_EXTRA block.

| step | what | cells | nodes |
|---|---|---|---|
| d1 | pair "horizon sun" at 1585 (wall 1585-1584, ring 53.9): stem + 5-node arc round 1585, ends notables | 28 + 47 | +6 +6 |
| d2 | pair "flame crown" at 1578 (wall 1578-1577): stem, bowed zigzag on two circles, end peaks notables (varied twin of the sun) | 29 + 49 | +8 +8 |
| d2 | pair "flame eye" at 1537 (wall 1537-1538, ring 33.2): lens standing on the road node, tip notable | 120 + 3 | +6 +6 |
| d2 | pair "flame scroll" at 1531 (wall 1531-1532): curl spiralling in to a notable heart (varied twin of the eye) | 119 + 3 | +6 +6 |
| d3 | DENSE_SMALL: 27 small family pieces (Crook, Hook, Ring, Tadpole, Diamond, Fork, Arch, Hairpin, Spur pair) in the gaps; names d_<family>_<road>; 18/37 hook and 70/74 crook land-mirrored | 18 28 29 37 47 49 53 56 62 63 70 74 92 101 105 | +105 |

After d3 (fire-d3): 795 nodes / 3445 = 0.231; mix small 87 (57%) medium 50 (33%) big 15 (10%); checks clean (base 4 only).
| d4 | pair "ember petals" at 1593 (wall 1593-1594, ring 64.3): one-interior lens leaning to 1594 | 49 + 53 | +4 +4 |
| d4 | grown: hearth flame_c side lick (18, mirrored 37) +2 +2; sunrise second flame 28 +2, 29 different +2; corona arc 5 -> 9 nodes (63, mirrored 62) +4 +4 | 18 37 28 29 62 63 | +18 |
| d4 | tried two Crooks in hub cell 83: crowded the phoenix wing tips (notable clump) - removed | 83 | 0 |
| d5 | pair "spark hooks" at 1602 (wall 1602-1603): 3-node hook | 47 + 105 | +3 +3 |
| d5 | grown: flame_a (18, mirrored 37) +2 +2. DENSE_SMALL_2: 1569 crook (56), 311 crook (29), 1551 crook (28) | | +13 |
| d5 | removed for clumps/spacing: 105 ring from 1601, 105 crook from 505, 105 hook 1567, 101 hook/crook 1591, 28 hook 1584 | | |

After d5 (fire-d5): 833 nodes / 3445 = 0.242; checks clean.
| d6 | declumped notables (<1.15 apart): 1545 hook, 1549 fork -> crook, flame_crown tip, 1600 ring, 1550 tadpole, 1588/1581 crooks, 1555 ring | | 0 |
| d7 | pairs "wall sparks" across ring 33.2: at 1541 two curls (3 + 4 nodes) either side of the corona entry, mirrored into 3; at 1535 the land mirror of the 3-node curl plus a different 3-node curl | 63 + 3, 62 + 3 | +7 +7, +6 +6 |
| d7 | DENSE_SMALL_3: crooks at 1601 (105), 1592 (101), 1586 (47) | | +9 |
| d8 | mix rebalance: ember petals 4 -> 6 nodes (two interior a side); 1555 and 1600 rings take a notable pupil (5 -> 6) | 49 53 63 92 | +6 |

FINAL (fire-d8, render out/fire-dense.png): 867 nodes / 3445 = 0.252 (target 861 reached);
`fire pieces 167 small 96 (57%) medium 52 (31%) big 19 (11%) nodes 909 mean 5.4`; 0 crossings, spacing = base 4 only,
all 167 pieces R0-R4, every node inside its labelled cell, cells 14/15/93 identical to fire-d0.
| d9 | BUG FIX: name collisions had silently dropped two pieces (cell 3's mirror half of the 1541 spark, one 1592 crook in 101). Pair names now carry the road id; pair() and the fill loops assert unique names. grow() bows now refer to the piece centroid | 3 101 | +6 |
| d10 | variety: 12 of 21 family Crooks swapped (each swap tried alone by out/fire-swaptry.py, chosen by eye): Diamond cusped 1592, 311; Crescent 1557, 1545; Fork 518, 1552, 1569, 1584; Hook 1567, 1558, 1577; Zigzag 1549. 62 corona variants tried (tips, 8 nodes): collide; kept mirrored | | +13 |

FINAL (fire-d10, render out/fire-dense.png): 886 nodes / 3445 = 0.257 (target 861);
`fire pieces 169 small 98 (58%) medium 52 (31%) big 19 (11%) nodes 928 mean 5.5`; 0 crossings, spacing = base 4 only,
all 169 pieces R0-R4, every node inside its labelled cell, cells 14/15/93 identical to fire-d0.
