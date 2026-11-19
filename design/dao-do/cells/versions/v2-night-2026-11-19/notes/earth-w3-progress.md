# Earth review pass, window 3 (2026-11-19), progress

Brief: design/dao-do/cells/review-brief.md, WINDOW SIZE = 3: a cell and all its neighbours (2+ shared road nodes),
sliding over the land; rim 902 as a neighbour (large figures not redesigned), hub 80 left alone. Border cells (24, 40,
104, 117 with Fire; 23, 48, 106, 114 with Metal; 2 both) rendered with the other land's cells and the border combos
(911 crater by 392/507, 912 crystal by 510/416); only earth.py edited.
Backup of the land file before this pass: out/earth-w3-bak.py.
Render map with Fire + Metal: out/earth-w3-full-map.json (recompile after every edit). Window renders:
python -I out/earth-w3-win.py <map> <cell> <out.png> [px] [margin] [LBL].

Baseline (tag earth-w3-0, Earth-only file list): spacing base only (other link <0.6 4 nodes), 0 crossings, rules 207
pieces all pass. Cells (no 80/902) 722 nodes / 3336.4 = 0.2164. Mix 134 pieces, small 71 (53%), medium 34 (25%),
big 29 (22%); repeated drawings 17. Per cell: 2:24 8:55 16:54 19:38 23:47 24:48 36:42 40:30 48:34 51:40 55:33 65:36
66:34 75:34 78:33 87:30 89:32 104:24 106:22 114:16 117:16 902:166.

Windows (21): 2 65 66 117 114 36 19 24 23 87 89 78 75 40 48 8 16 51 55 104 106.

Open points from w2: 8 wall (four straight diamonds on a line); 19 pointed ridge; 65 opened hill beside 24's spiral;
48|55 two square loops; 16 cliffs freehand zigzags; 1688/1689 four figures each.

## Windows done
- 2 (with Fire 3, Metal 4): left (start cell, sparse by rule 3.10 B4).
- 24 (with Fire 28) / 117 / 65: weak = a row of round loops across the border: Fire's spiral and wisp ring, 24's
  castle (a crumpled octagon of straight links), 24's spiral, 65's hill, 117's cirque. Changed: 24's castle -> the
  mirror of 23's mountain gate (a double arch open into the cell; 23|24 now mirror exactly). Tried a peak_fan off 235
  (two placements): read as a stick hand. Same 8 nodes. tag earth-w3a.
- 40 / 48 (with Fire 47, Metal 41): weak = the keep notable on one straight link from the inner wall middle (a spike
  into the courtyard), in both keeps. Changed keep(): the keep notable at the courtyard centre on a cross wall ml-mr
  (inner and outer ward). Tried: hung from tl/tr (a tight triangle of three notables); tm-keep-bm (fails R3, the gate
  node straight to a notable). Same nodes. tag earth-w3b.
- 8: open point "four straight diamonds on a line": tried the wall bowing outwards (0.07 with four towers, 0.09 with
  three): collides with d8 and still beads -> reverted; wall left (third drawing, see unsure). The empty strip under the
  wall's east half: added f8, a Crescent off 1646 (-35), curling back towards d8's Hairpin (a pair of horns). Tried
  there: Crescent/Tadpole at 0/10 (clash with tower o17), Crook (repeats c8), Diamond (echoes the towers). 8: 55 -> 59.
- 89 / 16 / 75 (open point 1688/1689 four figures each): changed: 75's fork Crook moved off 1688 to the free 1687
  (Crook swept 1.3, -35), curling into 75's corner beside the spoke; 1688 now carries three (split halves, east cliff).
  Tried at 1687: 0, -20, 15 (spacing with the pyramid / spoke). 1689 left (89's foot is the mirror of 87's at 1679,
  the split halves and the west cliff are the canyon mouth). tag earth-w3d.
- 19 (sparse, 0.20): no patch a road node can reach (the ridge's flanks and the fort spread the cell evenly); left.
  The pointed ridge (open point) reads as a three-peak range in the window; left.
- 114 (sparse): tried a piece off the free 1632 into the column beside the cirque: Crescent 0/-20/15/25, Hairpin
  -10/20, Crook -15/15: all hit the 1619-1632 spoke or b114; left.
- 51 (with 40, 78, 104): weak = three round loops stacked on the 1674 spoke: 40's caldera, 51's dz51a Diamond, 51's
  cave. Tried dz51a as Crescent (180 bow in, 0.85, 140/170/220 bow out), Hook (150, 210), Crook (145, 175, 185):
  every one clashes with the cave roof or the peak fan; left (unsure).
- 24 again, parent note from Fire's w3 pass (24's spiral faces Fire 28's big spiral ~7 units away across the border):
  changed mountain_road(): the spiral (9 + top) and its grown outer arc (6) became a switchback road: an outer arc of
  six from 1624 (a0 -21, sweep 225), a rung at the turn, a middle arc of five walked back, a second rung, an inner arc
  of four (sweep 180), the summit notable; arcs round the old summit, notables at the two turns and the summit, the
  open side towards the border and the new gate (16 nodes, same). 23 = its mirror with an inner arc of three (15,
  same). Tried the other way round (sweep -225, open towards 1626): nested arcs beside the gate's nested arcs, the
  same drawing twice; kept the one facing the gate. tag earth-w3e.
- 24 once more (window 24 whole, after the road change): the gate beside the switchback made two nested-arc figures
  side by side (with the terraced peak a third). Tried the castle back with the new road: a polygon between Fire's
  wisp ring and the road's arcs reads more varied -> the castle restored (the gate try above is undone; 23 keeps its
  own gate). Tidy: unused spiral() removed, stale comments fixed.
- 87 (rendered from the final map, cell 8 changed): left; 8's new f8 and d8 read as a pair under the wall.

- Swept and left (nothing clearly weak, or a named / mirrored figure already tried): 2, 65 (hill: twin peaks and gap 4
  tried in w2; the spiral beside it is gone now), 66, 117, 36 (terraces), 87 / 89 (towers), 78 / 75 (pyramids; the
  middle band reads pyramid-tower-tower-pyramid, four rectilinear named figures in a row, see unsure), 16 (cliffs:
  arcs and orbits tried in w1/w2), 55 / 48 (quarry and keep: pit spiral, round rim, castle tried in w2), 104 / 106
  (cairns, crater 911 and crystal 912 in frame; the 106 strip tried in w2).

## Final (tag earth-w3)
Spacing base only (other link <0.6 4 nodes), 0 crossings, rules 208 pieces all pass, no Earth notable clumps < 1.5;
on the Fire+Earth+Metal map (out/earth-w3-full-map.json) also base only, 0 crossings, no clumps.
Cells (no 80/902) 726 nodes / 3336.4 = 0.2176 (was 722, 0.2164); 8 55 -> 59, every other cell the same.
Mix 135 pieces, small 72 (53%), medium 34 (25%), big 29 (21%) (was 134: 71 / 34 / 29); repeated drawings 17 (same).
Render out/earth-w3.png.

## Unsure
- 23: its gate (nested arcs) beside its switchback road (nested arcs) is the same pairing that was rejected in 24;
  23's gate predates this pass and is its named border piece, left.
- 40/48 keep cross wall: a barred square now stands beside 55's square-in-square quarry, so the 48|55 "two square
  loops" point is not better; in 48 the keep notable and the mr wall-middle notable sit on one link.
- 51: the caldera / dz51a Diamond / cave stack on the 1674 spoke (no non-ring piece fits).
- 8: the wall is still beads on a line (three drawings so far; the outward bow failed).
- the middle band pyramid-tower-tower-pyramid: four rectilinear named figures in a row.
- 75 was seen inside the windows 23, 89 and 16 (its own window render was not read separately).

## For the neighbour
- Fire 47 (and Metal 41, its mirror side): the hexagon loop stands right across the border from Earth's keep in 40
  (and 48): two polygon loops side by side. If Fire / Metal revisit those cells, a non-polygon figure there would
  answer the keep better. Earth's keeps are the 40/48 named figures (kept, spike fixed this pass).
- Fire 28: its spiral no longer has a spiral twin across the border (24's road is now a switchback, opening towards
  the border); its wisp ring sits beside 24's castle as before; nothing needed.

