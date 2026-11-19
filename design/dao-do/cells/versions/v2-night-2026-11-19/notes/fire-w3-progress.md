# Fire w3 progress (window 3: a cell and all its wall neighbours, one neighbourhood at a time; brief design/dao-do/cells/review-brief.md)

Backup before the pass: out/fire-w3-bak.py (the ONLY undo: design/dao-do/cells/ is untracked in git).
Baseline (tag fire-w3a = fire-w2 final): fire cells 892 nodes / 3445 = 0.259; mix.py `fire pieces 176 small 107 (61%)
medium 42 (24%) big 27 (15%) nodes 1050`; repeats 17; notable pairs < 1.5: 4 (2 in locked 15, the 1.45 sunrise/lily in
28/29). 0 crossings, spacing = base 4 only, 230 pieces pass. Cross-border map fire-w3x (fire + earth.py + wood.py, for
looking only): 0 crossings, spacing base 4 only (no Fire piece too close to Earth/Wood).
Scratch: fire-w3-loop.sh <tag> <cell ...> (check + clumps + locked check + diff vs fire-w3a + mix + hood renders),
fire-w3-hood.sh <tag> <cell ...> (hood = cell + wall neighbours; border hoods add Earth/Wood cells and the rim box out to
r 90 with the border combo), fire-w3-rhood.py.
Hoods (neighbours): 3: 62 63 83 119 120 w1 e2 | 14*: 15 56 70 92 93 rim | 15*: 14 53 74 92 93 rim | 18: 28 37 62 63 70 92
93 | 37: 18 29 62 63 74 92 93 | 28: 18 47 63 70 120 e24 | 29: 37 49 62 74 119 w25 | 47: 28 56 70 105 e40 | 49: 29 53 74
101 w39 | 53: 15 49 74 101 rim | 56: 14 47 70 105 rim | 62: 3 18 29 37 63 119 | 63: 3 18 28 37 62 120 | 70: 14 18 28 47 56
93 | 74: 15 29 37 49 53 92 | 92: 14 15 18 37 74 93 | 93*: 14 15 18 37 70 92 | 101: 49 53 w39 w107 rim+915 | 105: 47 56 e40
e104 rim+911 | 119: 3 29 62 w1 w25 w111 | 120: 3 28 63 e2 e24 e117   (* locked centre: judged, not edited; 83 hub left)

| hood | weak | change |
|---|---|---|
| 105 (47 56 e40 e104 rim 911) | the trident ringed by four three-node sticks (hooks 1602, 1601, 1567, Crook 506), its left middle open (w2 open item) | hooks 1602 (spark_hooks) and 1567 removed; `w_orbit`: an outer orbit arc round the trident's own centre U on its open left side (rho 3.7, six nodes at 22-deg steps -40..-150, notables at -84 and the end), hung from 1602 at its top end; tried rho 3.2 first (hugged the psi, left the bottom empty). The emptied bottom-left corner: a round Diamond off 1568 (named candidates at 1568: Ring round 40/55, Ring cusped, Tadpole, Diamond cusped failed spacing or a clump; Diamond round passed). Earth side across the border (104's cairn, 911 crater) reads apart: nothing for the neighbour |
| 56 (14 47 70 105 rim) | 56's w2 orbit arc off 1944 read as a bead stick glued along the 1944-1568 wall (taiji_b's inner turns 1.4 inside it), and now stood next to 105's orbit arc (repeat across the wall) | orbit arc removed; 105's 1568 Diamond mirrored into 56 across the 1944-1568 wall (`wall_pair`): a split figure at the wall foot, answering 56's 1606 Diamond pair with 14 in the opposite corner. Left: the two bottom Crooks (1571 bow out, 1570 bow in) are alike but spaced; noted, not changed |
| 70 (14 18 28 47 56 93) | 70's w2 lantern (curled-stalk Tadpole on a 2.0 stem from 1586) stood its ring head 3 units from 47's loop flame ring across the 1586-1604 spoke (two ring-on-a-stalk figures side by side) and was 70's second Tadpole (w2 open item) | catalogue pieces on the same stem first (Crescent bow in, Crescent bow out mirrored, Spur pair passed; Arch bow out/uneven crossed the spoke, Fork closed spacing, Zigzag wave 0.76 from heart_R); the Spur pair was taken, then at a half-5 zoom read as a forked stick (w2 had found the same at 1579): replaced by `w_lens_1586`, a flame lens (two arcs to a notable tip, as 62's lens by 1545) on a stem from 1586, hanging point down into the upper right; it answers 28's sunrise lens standing on 1586 above the ring. Three named lens placements, all passed after moving the stem node off the spoke; the first chosen by eye. 74 untouched (its Hook stays). 70 now holds one Tadpole |
| 47 (28 56 70 105 e40) | after the 70 change nothing clearly weak (wing, eye, loop flame spaced; the border hexagon and Earth 40's keep across the border read apart) | left |
| 74 (15 29 37 49 53 92) | looked at on the baseline map back to back with 70, then again on the final map (after 53's ring): nothing clearly weak; its B Hook and 70's lens differ | left |
| 53 (15 49 74 101 rim; re-opened on the final map) | three Hairpins in one hood (53's off 1560, 101's off 1557, locked 15's E): 53's and 101's the same arch ~10 apart, 53's crowding the fireball's tail on 1560 (w2 open item) | 53's Hairpin -> a cusped Ring on the same stem/angle (`d_ring_1560`, a spark falling off the fireball; named: Tadpole round, Diamond round, Ring cusped, Spur pair, Tadpole curled stalk passed at 1560; Tadpole/Ring at 1561 failed spacing). Chosen by eye: the round Diamond and the curled Tadpole stacked a second plain ring under the fireball, the Spur pair repeated 70's and 15's spurs |
| 101 (49 53 w39 w107 rim 915) | after 53: its Hairpin is now the only one in the bottom row; star, split ring, fork, diamond spaced; Wood 107's frond and the 915 torch read apart; the rim beyond 101 empty by the rim's design | left |
| 63 (3 18 28 37 62 120) | the open patch under the halo tip by 1554-1556 (w2 open item: ring 1555 removed; small pieces at 1554/1555 crammed the corona tip or the ember); looked at with 62 back to back: 62 holds a round Diamond off 1549 in the mirror spot, 63 nothing, so the halo pair stood lop-sided | 62's d_diamond_1549 mirrored into 63 (on 1556, `mirror_pieces`): a land twin again; it sits under the halo tip (notables 1.9 apart), beside, not back to back with, 18's sun ring on 1555. 63 35 -> 39 |
| 62 (3 18 29 37 63 119) | judged from close zooms of 62 and 63 side by side (the hood render was not opened separately) and in hood 18: nothing else clearly weak | left |
| 18, 37 (hood 18 opened; 37's own hood not rendered separately: it is the same picture with 29/74 for 28/70, both seen in hoods 29 and 74) | rich and mirrored about the axis (the hearth suns differ by one ray); nothing clearly weak | left |
| 28 (18 47 63 70 120 e24) | inside Fire nothing clearly weak. Across the border: Earth 24's "road" spiral (round road node ~1624, notable "road top") stands ~7 units from 28's big spiral, two big spirals facing each other across the 36-deg border (look-alike neighbours). 28's spiral is the cell's named figure (and mirrored in 29): not changed | left; see "for the neighbour" |
| 29 (37 49 62 74 119 w25) | nothing clearly weak; Wood 25's ring and ginkgo by 311/312 read apart from 29's wisp | left |
| 49 (29 53 74 101 w39) | nothing clearly weak; the catherine wheel (49) and 101's spark star are both five-fold but one is spokes to a circle, one a star outline, ~6 apart across the ring: noted, not changed | left |
| 92 (14 15 18 37 74 93) | nothing clearly weak (quill, twin flame, candle, ring 1600 spaced; 93's ray fan across the axis differs by design) | left |
| 119, 120 (3, 29/28, 62/63, Wood 1 25 111 / Earth 2 24 117; hood 120 opened, 119 judged from a close zoom and hoods 29 and 3) | 120's comet tails read as two long parallel lines (arcs round the tree centre, w1), but they are the comet's named figure on orbit grammar; 119's flicker and scroll spaced; Earth 117's cirque and Wood 111's crescent leaves read apart | left |
| 3 (62 63 83 119 120 w1 e2) | sparse by design, like Wood 1 and Earth 2 beside it; the wings, spur pairs and wall pairs balanced | left |
| 14*, 15*, 93* (locked centres) | hoods 14, 15, 93 opened on the final map (15: 53's new ring beside 15's J crook / I fork, spaced; 93: 70's lens by the spoke); nothing to change in the unlocked neighbours. 56's two Diamond pairs (1606 with 14, 1568 with 105) sit in opposite corners: see unsure | left |

For the neighbour:
- Earth 24 (cell at Earth local -27, by the Fire border at global 36): its "road" spiral faces Fire 28's big spiral across the border, ~7 units apart; two big spirals side by side read as look-alikes. If Earth changes anything there, a non-spiral figure would separate them. (No spacing hits across either border: the fire+earth+wood map shows only the base 4.)
- Wood side (101, 49, 29, 119 against Wood 107, 39, 25, 111): nothing.

FINAL (tag fire-w3, render out/fire-w3.png): fire cells 898 nodes / 3445 = 0.261 (baseline 892, 0.259). Changed cells vs
fire-w3a: 53 41->41, 56 38->37, 63 35->39, 70 36->36, 105 25->28 (3, 14, 15, 74, 93, 83, 901, borders untouched; locked
14/15/93 unchanged). mix.py `fire pieces 177 small 107 (60%) medium 43 (24%) big 27 (15%) nodes 1056` (baseline 176:
107/42/27 = 61/24/15 %); without border cell 931's 20 small: 157 = 87/43/27 = 55/27/17 % (baseline 156 = 87/42/27 =
56/27/17 %). Repeats 17 (unchanged). 0 crossings, spacing = base 4 only (also with Earth and Wood compiled in), all 231
pieces R0-R4, every node inside its cell. Notable pairs < 1.5: 4 (unchanged: 2 in locked 15, the 28/29 sunrise/lily 1.45).

Unsure:
- Small rings added this pass: round Diamonds in 105 (1568), 56 (its wall mirror) and 63 (62's twin), and a cusped Ring
  under 53's fireball ring on the same node 1560. 56 now carries a Diamond wall pair in two opposite corners (1606 with
  14, 1568 with 105) round the two taiji spirals: it reads as a framed composition to me, but it is four small rings in
  one cell, close to "many plain rings in a row" / "a figure repeated nearby". 53's cusped ring below the fireball's
  round head is a second closed loop on that node.
- earth.py and wood.py were being edited during the run (other sessions): the border looks and the Earth 24 note are a
  snapshot of those files at about 02:30.
