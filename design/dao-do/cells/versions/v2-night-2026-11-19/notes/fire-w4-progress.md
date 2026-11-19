# Fire w4 progress (window 4: a cell, its neighbours and their neighbours, two rings of cells; six regions with overlap; brief design/dao-do/cells/review-brief.md)

Backup before the pass: out/fire-w4-bak.py (the ONLY undo: design/dao-do/cells/ is untracked in git).
Baseline (tag fire-w4a = fire-w3 final, unchanged): fire cells 898 nodes / 3445 = 0.261; mix.py `fire pieces 177 small
107 (60%) medium 43 (24%) big 27 (15%) nodes 1056`; repeats 17; notable pairs < 1.5: 4 (2 in locked 15, the 1.45
sunrise/lily in 28/29). 0 crossings, spacing = base 4 only, 231 pieces pass; x-map (with earth.py, wood.py) base 4 only.
Scratch: fire-w4-near.py (nearest other-cluster notable, every cluster), fire-w4-try.sh (one named FILL row via FIRE_EXTRA), fire-w4-loop.sh <tag> <region ...> (check + clumps + locked + diff vs fire-w4a + mix + x-map + region renders
out/<tag>-R<g>.png / -L.png from the x-map), fire-w4-crop.py (crop + scale a render), fire-w4-z.py (box by land polar).
Regions (scale: composition, not single pieces):
A inner: 3 62 63 119 120 18 37 (+ hub 83, Wood 1, Earth 2)
B middle left: 29 37 62 119 49 74 92 (+ Wood 25 39)
C middle right: 28 18 63 120 47 70 93 (+ Earth 24 40)
D outer left: 49 74 92 15 53 101 (+ Wood 39 107, rim)
E outer right: 47 70 93 14 56 105 (+ Earth 40 104, rim)
F rim with the outer band: 14 15 53 56 101 105 + rim 901 (-36..36)

| region | weak | change |
|---|---|---|
| E (47 70 93 14 56 105, Earth 40 104, rim) | (1) the outer band ran six closed loops in a row: 14's H Diamond, 56's 1606 Diamond (its wall mirror), taiji_a, taiji_b, 56's 1568 Diamond and 105's (the w3 wall pair); (2) 56's two bottom Crooks (1571, 1570) alike, beside 14's J Crook on 1571; (3) coordinator note from Earth w3: 47 by the Earth border showed three polygon loops side by side, 47's phoenix eye (a closed ring of six), the border's wall hexagon (cluster 17, base map: not Fire's, not editable) and Earth 40's square keep | (1) the 1568 Diamond pair -> `w_petals_1568`, a V of two slim flame petals (lens, one node a side) opening up the 1944-1568 wall, 105's half drawn, 56's its wall mirror (`pair`); first drawn like 1593's ember petals, which mix.py counted as a 4x repeat (17 -> 21): made shorter/slimmer. The 1606 pair stays (it derives from locked 14). (2) 56's D Crook -> `w_hairpin_1570`, a Hairpin 'tight turn' curling over towards taiji_b; named at 1570: Hairpin tight turn ang 10 / 50, Hairpin bow out, Hook s-curve ang 20 / 40 / 30 mirrored, Hook bow out, Arch bow out, Crescent bow out / bow in, Zigzag wave; passing: Hairpin ang 50, Hook s-curve ang 40, Hook bow out (the two Hooks read as a second stick by the C Crook). C Crook kept as the wall answer to 14's. (3) 47's eye opened into a half ring on its circle (rho 1.3, 36-deg steps 180..0 from the 1602 entry round the wing side), the pupil (its only notable, as before) hanging inside from the inner node, its mouth towards the hexagon and keep: an open curve between two polygons. First tried a crescent ending in a notable at 45 deg: 1.20 from the hexagon's notable 1463 (the clump script only sees named pieces; measured with fire-w4-near.py, which checks every cluster): replaced. |
| D (49 74 92 15 53 101, Wood 39 107, rim) | (1) w3 open point: 49's catherine wheel (five spokes) and 101's spark star (five points) ~6 apart, two five-fold radial figures in one corner; (2) 53's cusped ring under the fireball's round head on 1560 (two closed loops on one node, in the ring-heavy outer band) | (1) `whorl49`: the wheel -> a three-armed whorl on the same hub, stem and circle (rho 1.7): spokes at 120-deg steps (a0 -18, so the stem from 1592 at orbit angle -158 enters through a gap), each arm running on through a middle node to a notable 80 deg on (12 -> 11 nodes). 101's star (named figure) untouched, now the only five-fold figure. (2) d_ring_1560 -> `w_zigzag_1560` (Zigzag wave, a flame lick beside the fireball's tail); named: Crescent bow out / bow in, Hook s-curve, Zigzag wave, Arch bow out, Fork bow out, all passed; chosen by eye from a sheet (Crescents echoed the tail's curve, a Hook would be 53's second, Arch and Fork read as sticks). |
| A (3 62 63 119 120 18 37, hub 83, Wood 1, Earth 2) | w3 open point: 120's comet tails two concentric arcs 1.16 apart, equal length (two long parallel lines). Else: cell 3 empty inside the wings by design (start cell, 3.10 B4); the 62/63 sun band and the hearth row dense small pieces, mirrored; 119/120 differ but balance | `comet120_w4`: each tail on its own circle (bow 0.04, bulging outward as before), the inner one dipping in to its 1514 hang, the outer one lifting out and ending shorter (notable): the tail splays from 1.2 at the head to ~2.5 at the ends. Node count unchanged (10). Rest left |
| B (29 37 62 119 49 74 92, Wood 25 39) | after the 49 whorl nothing clearly weak: 29's spiral and wisp spaced, the flame crown / horizon pair, 62's lens; Wood 39's big leaf and fir fan and the border hex read apart from 29's diamond and 49's hook | left |
| C (28 18 63 120 47 70 93, Earth 24 40) | after the comet and the 47 eye nothing clearly weak inside Fire; Earth 24's "road" spiral still faces 28's big spiral across the border (w3 note, still holds on today's earth.py) | left; see "for the neighbour" |
| F (outer band 14 15 53 56 101 105 + rim 901) | the outer band ring-heavy (split ring, fireball, 53's ring, 14/15's rings, the 56 Diamonds); the rim trefoils and đỉnh by design, not redesigned | the two ring removals above (53's 1560 ring, the 1568 Diamond pair) thin the run; rim, keystones, hub 83 untouched |
| land (fire-w4.png) | mirror tally: 3, 62/63, 18/37, 28/29, 70/74, 14/15 mirrored; 47/49, 53/56, 101/105, 92/93, 119/120 differ (about half). Size gradient mostly fixed by named figures (the inner band's corona/halo, 3's wings are big near the centre); not changed | left |

For the neighbour:
- Earth 40 (keep) / Earth's border cells: the polygon run by 47 was the wall hexagon (cluster 17 on the 36-deg border spoke, base map) between Fire 47's eye and Earth 40's keep. Fire's eye is now an open crescent; the hexagon itself is a base-map wall cluster neither land edits. If Earth wants the run broken further, its keep is the remaining polygon.
- Earth 24: its "road" spiral still faces Fire 28's big spiral across the border (~7 apart, look-alikes); a non-spiral figure on Earth's side would separate them (w3 note, unchanged).
- Wood side (101, 49, 29, 119 against Wood 107, 39, 25, 111): nothing.

FINAL (tag fire-w4, render out/fire-w4.png from the x-map with earth.py and wood.py): fire cells 899 nodes / 3445 = 0.261
(baseline 898, 0.261). Changed cells vs fire-w4a: 47 37->37, 49 42->41, 53 41->41, 56 37->39, 105 28->28, 120 21->21
(3, 14, 15, 93, 83, 901, borders untouched; locked 14/15/93 unchanged). mix.py `fire pieces 177 small 107 (60%) medium 43
(24%) big 27 (15%) nodes 1057` (baseline identical counts, 1056 nodes); without border cell 931's 20 small: 157 =
87/43/27 = 55/27/17 %. Repeats 17 (unchanged). 0 crossings, spacing = base 4 only (also with Earth and Wood compiled
in), all 231 pieces R0-R4, every node inside its cell. Notable pairs < 1.5: 4 (unchanged: 2 in locked 15, 28/29 1.45); every new or moved notable measured against all clusters
(named, unnamed wall clusters, Earth/Wood) in the x-map: nearest 1.78 (53's zigzag tip to its own cell's 1595 hook).

Unsure:
- 47's half-ring eye is small (rho 1.3); a larger arc was not tried (by estimate the feather tips and the hexagon leave
  little room).
- The three-armed whorl in 49 reads as a triskelion; the w1 note chose five arms to avoid a hooked cross, three arms
  avoid that too, but it is a change to 49's named figure's look (same hub, circle and stem).
- 1568's petal V and 1593's ember petals are the same family of shape (smaller here) ~50 units apart on opposite sides.
- earth.py / wood.py may still be edited by other sessions: the border looks are a snapshot of this run.
