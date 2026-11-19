# Water density v2 progress (brief: design/dao-do/cells/density-brief.md, item 6 widened by the user: any good means)

Water-specific (coordinator): leave the Ice start figure and its cells' (45, 46) existing pieces alone; new pairs keep
to waves, ripples, lotus, whirlpools, currents (no more creatures).

Baseline `water-d0` (lands/water.py as found): 109 pieces, small 57 (52%) medium 37 (34%) big 15 (14%), 659 nodes
with the rim (cell 904: 44) -> 615 cell nodes / 3323 u2 = 0.185. Target 831 (+216).
Nodes per cell: c5 24, c11 51, c17 40, c22 39, c26 32, c32 34, c38 40, c42 28, c45 27, c46 20, c54 32, c59 30, c69 32,
c76 31, c82 14, c86 39, c91 35, c103 23, c108 23, c115 8, c118 13, c904 44.
Base map warning to ignore: other link <0.6 4 nodes (outside Water).

Notes: spoke midpoints (1979-1984, 1987-1990) are not travel nodes (no hanging, no wall_pair ends). Cell at th
+23..+36 of the middle band is the Wind start's, not Water's. Medium drawing max 3 copies, big 1 (mix.py): a pair of
medium halves plus an exact axis twin = 4, so twins are varied.

## Additions (new section "Density v2" at the end of lands/water.py)
- P1 eye_lens 115|46 spoke -23 (1773-1785): lens of two arches round spoke node 1979, 5+5 (c115 13, c46 25).
- P2 wave_scroll 59|103 spoke -28 (1879-1991): curl of 4 + inner 2 with eye, 6+6.
- N1 moon_halo c32: two concentric arcs round the moon's centre (4.3 / 3.0) from 1792, 8.
- N2 lotus_bloom c46: top-view lotus (pod of 4 + 4 lens petals) from 1787, 8. c46 now 33 (enough; Ice cell).
Check after each: water-d3 clean (0 crossings, base warnings only, rules pass).
- N3 wave_scroll_m c54: 59's scroll half mirrored across the land axis (hung from 1889), 6.
- N4 koi_current c17: arc of 6 on radius 3.9 round the koi centre from 1814 (11's current, varied), 6.
- P3 axis_ripple 11|17 axis road 1500-1501: ring of 8 split by the axis road, 4+4 from 1501.
- N5 whirlpool c26: spiral of 7 from 273. N6 reflection c26: arc of 5 hung at its middle from 1865 (32's, varied).
- N7 raindrop c26: ring of 6 from 1784 + arc of 5 (r 2.0) + arc of 4 (r 3.0), 15; replaces T_tadpole off 272 (-5).
- G1 wave_train c22 grows a swell: arc of 5 on r 48.5 hung from trough a1 (+5).
- N8 spoke_arch c118: the 115 eye-lens half echoed, varied (crown notable), pass-through 1779-1792, 5.
- F1 crumbs (catalogue, tested alone, named by hand): Y17_1812 Diamond, Y54_1890 Crescent, Y38_1868 Diamond,
  Y42_1865 Crook, Y76_1883 Crook, Y108_514 Crook, Y45_1795 Crescent, Y11_1806 Diamond (+29).
State water-d7: 734 cell nodes (+119), clean. Mix before crumbs: 51/36/13.
- (d8-d9) Y82_33 + mirror Y82_34 (hub corners), moon_halo inner arc 3 -> 5 (now big), Y32_1872 Crescent, Y115_1783
  Ring (118's Ring off 1790 varied), Y42_1526 Crook. Hub ripple pairs on ring 14.5 (82|5) tried and REMOVED (cramped,
  notables clumped).
- (d10-d13, advisor review) Dropped the 3-node Crooks Y42_1865, Y42_1526, Y76_1883, Y108_514 (sticks) and Y45_1795
  (look-alike of Z45_1794, in an Ice cell); Y32_1872 dropped (crowded c32 T_tadpole). Y82 Rings -> Diamonds off 33/34
  (ang 80, nearest notable 1.7). Y54_1890 -> Crescent bow out (1.45 to tortoise). 115 eye-lens half a3 made small
  (was 1.1 from channel b2). Swell row shifted (y 5.3 + 1.333 k). c26 reflection centre th -23.3 -> -23.6.
  New lotus_bud c38 off 1867 (petal, 4).
FINAL water-dense: 740 cell nodes (615 -> 740, +125), 0.185 -> 0.223 /u2; without the Water start cell 5:
716 / 2765 = 0.259. Mix 70/43/17 = 54/33/13 %. Checks clean (0 crossings, base warnings only, 130 pieces R0-R4 pass).
Per cell: c5 24, c11 59, c17 54, c22 44, c26 54, c32 44, c38 48, c42 28, c45 27, c46 33, c54 42, c59 36, c69 32,
c76 31, c82 22, c86 39, c91 35, c103 29, c108 23, c115 18, c118 18 (c904 44, not counted).
- (final look pass) Y11_1806 Diamond dropped (three notables bunched between current, Z11_1500 and axis ripple).
FINAL (supersedes the line above) water-dense: 736 cell nodes (+121), 0.222 /u2; without cell 5: 712 / 2765 = 0.258.
Mix 69/43/17 = 53/33/13 % (mix.py's 780 nodes include the rim's 44). c11 55; all other cells as listed above.
