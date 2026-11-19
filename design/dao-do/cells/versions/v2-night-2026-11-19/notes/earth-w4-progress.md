# Earth review pass, window 4 (2026-11-19), progress

Brief: design/dao-do/cells/review-brief.md, WINDOW SIZE = 4: a cell, its neighbours and their neighbours (two rings),
one region at a time, six regions with overlap; composition, not single pieces. Hub 80 left, rim 902's large figures
not redesigned. Neighbouring lands' border cells in the renders (Fire + Earth + Metal map); only earth.py edited.
Backup of the land file before this pass: out/earth-w4-bak.py.
Try / check: sh out/earth-w4-try.sh <tag> [<old> <new> ...] (substitutions on a copy, Earth-only check, then the
Fire+Earth+Metal map out/<tag>-full-map.json, clumps, density). Region renders: python -I out/earth-w4-win.py <map>
<c[,c2] | =a,b,c> <out.png> [px] [margin] [LBL] (two-ring window round c, or an explicit cell list).

Baseline (tag earth-w4-0, = w3 final): spacing base only (other link <0.6 4 nodes), 0 crossings, rules 208 pieces all
pass. Cells (no 80/902) 726 nodes / 3336.4 = 0.2176. Mix 135 pieces, small 72 (53%), medium 34 (25%), big 29 (21%);
repeated drawings 17. Per cell: 2:24 8:59 16:54 19:38 23:47 24:48 36:42 40:30 48:34 51:40 55:33 65:36 66:34 75:34
78:33 87:30 89:32 104:24 106:22 114:16 117:16 902:166.

Regions (cell lists rendered): inner =2,65,66,114,117,24,36,19,23; middle left two-ring of 78; middle right two-ring
of 75; outer left =51,40,78,104,8,87,24,36; outer right =55,48,75,106,16,89,23,19; rim =8,16,51,55 with margin 11.

Open points from w3 (task): middle band pyramid-tower-tower-pyramid (vary at least one, same node count); 23 gate
beside its switchback; 51's three round loops on the 1674 spoke; 8 wall beads on a line; 48|55 two square loops.

## Regions done
- (note) the Fire+Earth+Metal map shows a clump in Fire c47 (eye r45, 1.20) and, at times, one Fire/Metal own-link
  warning while those passes run; not Earth's (the Earth-only check is the pass/fail).
- Middle band (two-ring of 78 and of 75; row 40 keep, 78 pyramid, 87 tower, 89 tower, 75 pyramid, 48 keep: six
  rectilinear figures across the band). Changed: new spire() (a lone peak, apex notable, flanks curving in on arcs
  bowing -0.12 of their chord towards the figure, 2 nodes each, foot notables, a ground line of three on an arc round
  the tree centre, hung from 1676 by its middle): 78's pyramid -> spire (10 nodes, same), 75 carries its mirror.
  Row now keep, peak, tower, tower, peak, keep. Tried bow -0.2: flank nodes crowd at the apex (own node 0.45). The
  towers (combo A on the axis) left. tag earth-w4c.
- Middle/outer right (48|55 "two square loops", plus Metal's hexagon beside 48): changed 48's keep (40's mirror) ->
  tulou(), a round earth house: a ring of ten round an ancestral hall notable joined to the two wall nodes either
  side of the far one, gate on 1683, notables w2/w8 (w7 clumped with top48, 1.43); dz48a Ring -> Diamond cusped (a
  ring stacked on the tulou read as "o O"; Hairpin 130-170, Hook, Crook, Crescent, Tadpole off 1665 failed spacing).
  48: 34 -> 35. tag earth-w4i.
- Outer left (40, 51, 104, 78, 8 with Fire 47/105): weak = the three round loops stacked on the 1674 spoke (40's
  caldera, 51's dz51a Diamond, 51's cave), the w3 open point. Changed the untried lever, 40's caldera: now a
  terrace_fan off 1674 (hub on orbit 1.5 at -45, arcs centred on -45, notables o0/o3) rising towards the keep; the
  stack reads wedge, diamond, cave. Tried -38 (road link 0.45), -30 (crossings). 40: 30 -> 31. tag earth-w4k.
- Inner right / middle right (23 with 66, 114, 19, 48 and Metal 30/41 in frame): weak = 23's gate (nested arcs)
  beside its switchback (nested arcs), the w3 open point. Changed: the gate -> a standing stone off 254, lens 3 + 3
  (h 0.85), tips on orbit 2.2 round a centre 3.0 from 254 at -95, leaning -20 with the spoke; 8 nodes, same. Tried
  the stone upright (0/180: spacing 0.85) and leaning +20 (spacing). No castle (19's fort is next door), no cirque
  (114's is above). tag earth-w4m.
- Inner band / middle band (inner region; free-space map out/earth_free.py over the land): the largest Earth patches
  were in 24 and 23 in the open side of the switchback roads (between road, castle / stone and the 1657-1658 corner).
  Changed: e24, a Crescent off 1624 (bow in, 205) into 24's patch; 23 carries its mirror (off 1631) because 24's
  fill rows are mirrored into 23. Tried there: Hairpin 210 (fills more, but a third Hairpin nearby once 66 got one),
  Crook 205/210 (a stick), Hook 205; off 1657 (Crescent/Hook/Crook 20-25): crossings with 23's stone. 23: 47 -> 51,
  24: 48 -> 52.
- 66 (patch between the knoll trail and the stairway, above 1635): changed: e66, a Hairpin off 1635 (bow out, 15).
  Tried Crescent 15/10 and Hook 15 (clumped with the trail's o4, 1.20/1.31), Crook 15 (reads as a stick), Crescent
  / Hook off 1634. 66: 34 -> 39. tag earth-w4q.
- 19 (the ridge's hollow under the middle and east peaks, the patch w3 found no road node to reach): an extra piece
  off 1668 (Crescent 40/45, Hook 35/40, with foot19 turned -10) fails spacing; changed foot19 itself: Diamond ->
  Hairpin (bow out 1.2, 15) winding up from 1668 into the hollow. Tried Tadpole 1.3 / 15 (a ring on a stick). 19:
  38 -> 39. tag earth-w4s.
- Outer right / rim (16, 55, 75, 89, 902 in frame): patch = the strip between 16's east cliff and the steps under
  1687. Changed: f16, a Crescent off 1687 (bow in, 195), a third curved strand in the canyon. Tried: Crescent 200
  hand flipped (clump with cliff_e c1, 1.19), Hook 195 (1.36), Hairpin tight turn (spacing), Crook swept (shorter, a
  stick). 16: 54 -> 58. tag earth-w4u.
- Rim with the outer band (8, 16, 51, 55, 104, 106 and 902): 8's wall left (the open point "beads on a line"): three
  drawings were tried in w1-w3 and every one keeps one line across the cell with small things on it; neither a
  fourth drawing on the same skeleton nor a skeleton change (the wall split into fewer, larger figures) was tried. Rim figures (pagoda, stars, congs, ruyi, bell) not redesigned; the
  rim is mirrored across the axis except the bell off 1637 (left) against the end_R Hook off 1648 (right), as before.

## Final (tag earth-w4; also the brief's check on the land file itself, tag earth-w4chk)
Spacing base only (other link <0.6 4 nodes), 0 crossings, rules 212 pieces all pass, no Earth notable clumps < 1.5;
on the Fire+Earth+Metal map (out/earth-w4-full-map.json) also base only, 0 crossings, no clumps.
Cells (no 80/902) 746 nodes / 3336.4 = 0.2236 (was 726, 0.2176). Per cell: 16 54 -> 58, 19 38 -> 39, 23 47 -> 51,
24 48 -> 52, 40 30 -> 31, 48 34 -> 35, 66 34 -> 39; every other cell the same.
Mix 139 pieces, small 76 (55%), medium 34 (24%), big 29 (21%) (was 135: 72 / 34 / 29); repeated drawings 15 (was
17: the two keeps no longer repeat). Render out/earth-w4.png.
Unused helpers kept in the file (inert): pyramid(), mountain_gate(), caldera().

## Unsure
- 8: the wall is still beads on a line (left this pass, see the rim region above).
- The spire flanks at bow -0.12 are a gentle curve; -0.2 crowds the apex. Whether the curved peak reads as a
  mountain rather than a tent is for the user's eye.
- 23 lost its mountain gate (now a standing stone); the land's gates are now the 66|2 city gate and the axis towers.
- Hairpins now stand in 19 (foot19), 66 (e66), 51 and 104; 19's and 66's are about 11 units apart across the 41.7
  ring.
- 40 terrace fan is the third terrace_fan drawing in the land (89, 48, 40), none adjacent.

## For the neighbour
- Metal 41 / 30: 48's square keep (beside Metal's hexagon loop) is now a round tulou, so the "two polygon loops
  side by side" note from w3 holds only for Fire 47 / Earth 40 now. 23's border piece by 254 is a standing stone
  (lens) instead of the double-arch gate.
- Fire 47: 40's caldera ring off 1674 is now a terrace wedge; 40's keep (square) still faces Fire 47's hexagon.

## Composition (w4 judgements)
- Axis balance: left cells (117 65 24 36 40 78 87 104 51 8) 363 nodes, right (114 66 23 19 48 75 89 106 55 16) 359
  (was 358 / 344). Still mirrored pairs: 87|89 towers, 78|75 peaks + baileys, 24|23 switchback roads + the new
  crescents, 117|114 cirques, 104|106 cairns, 51|104 / 55|106 stepped stones, 65|66 trails, the rim. Now unmirrored:
  40 keep / 48 tulou, 24 castle / 23 stone (and as before 65/66, 36/19, 8/16, 51/55 centre figures).
- Size gradient: small catalogue pieces and small rings in the inner band, medium figures (switchbacks, terraces,
  ridge) in the 41.7-53.9 band, the big named figures (peaks, towers, keep, tulou) in 53.9-64.3, the wall, canyon,
  cave and quarry in the outer band, the rim's large figures beyond: holds.
- Runs: the row of six rectilinear figures across 53.9-64.3 is now keep, peak, tower, tower, peak, tulou; the
  three-loop column on 1674 is wedge, diamond, cave; no row of plain rings found. Looked for new look-alikes: 19's
  ridge over 75's peak (different flanks and scale, inside its bailey: kept); 48's tulou and 16's henge (both a ring
  round a centre joined to two far nodes, about 25 units apart: kept, unsure); 40's fan and the 1659 petals (spoke
  and keep between them: kept).
- Piece keys that now hold other figures: 78/75 'pyramid' (spire), 48 'keep' (tulou), 40 'caldera' (terrace fan),
  23 'gate' (standing stone); mix.py prints the old names.
