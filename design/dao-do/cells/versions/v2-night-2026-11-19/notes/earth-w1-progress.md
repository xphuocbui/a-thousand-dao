# Earth review pass, window 1 (2026-11-18/19), progress

Brief: design/dao-do/cells/review-brief.md, WINDOW SIZE = 1, every Earth cell except hub 80 and rim 902.
Backup of the land file before this pass: out/earth-w1-bak.py. Density script: out/earth-w1-dens.py.
Close-up renders: out/earth_view.py <map> <cell> <out.png> [px] (piece names + road ids).

Baseline (tag earth-w1): spacing base only, 0 crossings, rules 208 pieces all pass.
Cells (no 80/902) 717 nodes / 3336.4 = 0.2149. Mix (earth incl. rim): 135 pieces, small 56% medium 23% big 21%.

## Windows done
- 78: weak = the bailey drawn as a square wave (merlons/walk on two radii). Changed: new helper bailey(); the bailey is
  now one smooth arc of 7 on an orbit rho 4.5 round the pyramid's centre, arc links round it, notables m3/m6 (same node
  count). Pyramid left (reads as a stepped peak; rectilinear, see unsure). tag earth-w1a clean.
- 75: same fix (its own bailey call, 6 nodes, mirrored). Its plain arch 1668-1667 left: it now runs into the bailey
  through 1667 as one S curve (interlock on a shared road node) and there is no room for a stand-off figure there.
- 65: weak = the flat-bar pagoda frame (bars, and a second pagoda beside the rim's). Changed: new helper hill(); a
  hill seen from above, two contour rings bridging 1615-1627 (outer ring of 8 rho 2.35, inner ring of 4 turned 45,
  rungs on one diagonal, the summit joined on the other), notables r6 + summit (13 nodes, was 10). The Hook off 1614
  had no room beside it (clumps/spacing at every angle tried) -> a Diamond off 1614; the d_s65 Tadpole ring -> a Crook
  (too many small rings in a row on that side). Cell 65 nodes 35 -> 36. tag earth-w1d clean.
- 66: weak = the right-angled stairway (a square wave). Changed: stairway() redrawn as a stair bent on an orbit round
  E(41, 26): outer rail of 5 hung from 1634 and 1620, inner rail of 5, five treads on the rays (ladder()), notables on
  the inner ends of treads 1 and 3 (10 nodes, was 9). The gate half and trail mirror left. tag earth-w1e clean.
- 8: weak = the battlement (a 22-node merlon square wave, a comb) and the thin mesa; wall w7 / mesa i0 clump 1.44.
  Changed: great_wall() replaces battlement(): five half circles end to end on r 70.4 from th -13 to -1.3, bulging in
  and out in turn, three nodes each at 45-degree steps round its own centre, foot to 1642, last junction to 1489,
  notables on crests 1 and 3 (22 nodes, same). Mesa lower arc rho 4.9 -> 4.5 (angles +-16): a deeper flat-topped
  hill. Clump gone. Unsure: the winding wall may read as a wave (Water's language). tag earth-w1g clean.
- 16: weak = the crooked terrace ladder (rungs fanning round a centre only 6 units away). Changed: its centre moved to
  E(69.5, 24.5), rails rho 12.0/10.8, rungs 8 degrees apart (-99.5..-75.5): parallel rungs, the ladder upright beside
  the 1686-1651 spoke (8 nodes, same). Tried: the two zigzag cliffs as arcs (sagitta 1.0, bowing apart): read as two
  bland strings and clashed with the gorge switchback; reverted, cliffs left (freehand, see unsure). tag earth-w1h.
- 36: weak = the clump terrace3 t0 / split-stone crest (1.45). Changed: terrace3 moved 0.6 degrees west (th -15.8..-8.6,
  its second row follows). Left: the three rice terraces (flat bars/boxes on arcs round the tree centre; re-centring
  them on the 65 hill was weighed: too little visible curvature over their short chords). tag earth-w1i clean.
- 48: weak = the notable clump at the keep's inner corner (keep tr with top48 0.97 and dz48a 1.02) and foot48/d_s48
  (1.49). Changed: the keep's tr corner small, its mr (wall middle) notable instead; foot48 stem 1.0 -> 1.2. Tried and
  failed: d_s48 turned (345, 60), as a Crescent or Crook; foot48 at -25/5. The 1681/1682 corner stays busy (the ring
  sits in the hook's curl). tag earth-w1j clean.
- 40: weak = two clumps: keep tl / crook2 (1.02), crook / the border hex notable (1.12). Changed: crook2 turned 150 ->
  125, crook turned 10 -> 30. Keep (a skewed square loop) left. tag earth-w1k clean.
- 104: weak = cairn cap / dz104 Hairpin clump (1.31). Changed: the Hairpin's curl flipped (hand True). Cairn left.
- 106: weak = cairn cap / a106 Hook clump (1.47). Changed: a106 turned -70 -> -55 (130/160 put it across the border
  spoke, out of the cell: rejected). The empty strip by the border spoke left (a fan was tried there before).
  tag earth-w1m: no clumps left in Earth.
- 87: weak = the plain arch 1662-1663 glued under the ring above the tower roof. Tried stand-off replacements off
  1662/1663 (Crescent, Tadpole, Crook, Hairpin): none fits the strip between ring, stone and roof. Left; tower, stone
  and foot left.
- 89: weak = its arch 1669-1670 was a look-alike shrunk copy of 87's. Changed: now the true mirror of 87's (five
  stones, sag 1.3), a split pair across the axis framing the gateway. Tried a "twin peaks" figure (two arcs meeting at
  a lifted saddle notable) in place of the arch 1688-1689: clashes with the foot Diamond at every turn tried; dropped.
- arches elsewhere (looked at with their cells): 8 d_arch2 1677-1678 four -> three stones (twin peaks did not fit:
  chord too short); 16 d_arch2 five flatter and 51/55 three deep both failed spacing/clumps -> left as they were.
  Plain four-stone arches left: 89 1688-1689, 16 1653-1652, 51 1639-1640 / 55 1650-1649 (a mirrored pair).
  tag earth-w1n clean.
- 51: weak = the cave's treasure notable on the end of one straight link from v3 (a spike). Changed: the gem moved up
  under the roof (orbit 0.9 towards the entry side) and hung from both roof nodes v3 and v5, a small hanging triangle.
  Peak fan, arch, lens half, Diamond, Hook, Hairpin left. tag earth-w1o clean.
- 55: left. Weakest is the quarry (two straight-link squares joined at the corners, rectilinear; it also half-echoes
  the rim's cong below it), but it is the cell's named figure and reads as a pit; see unsure.
- 19: weak = the ridge, a 13-node zigzag of straight links (freehand sticks). Changed: ridge() redrawn as three hills
  end to end between valley nodes (52.2,4.4) (48.6,8.3) (48.6,13.3) (52.2,16.6), each an arc bulging inward (bow 0.4 /
  0.46 / 0.4 of its chord) with three nodes at even steps round its own centre, crests notable, the middle tallest;
  feet on 1670 and 1667 (13 nodes, same). The Crescent top19a turned 180 -> 195 (clumped with the middle crest, 1.34).
  The Crescent in the left hill and the Diamond in the right valley now sit inside the curves. tag earth-w1p clean.
- 24: left (spiral mountain road on its orbit, castle on two orbits, the terraced peak round 1659; nothing clearly weak).
- 23: left (mirror of 24's road with its own outer arc, the mountain gate off 254; nothing clearly weak).
- 117 and 114: weak = the cirques' peaks, each a notable on the end of one straight link off a ring node (spikes).
  Changed: cirque() puts each peak on rho 2.0 between ring nodes k and k+1, joined to both (a tooth on the ring).
  117 keeps peaks (1, 3). 114: (1, 2) put a peak against the Hook a114, (0, 3) against the Tadpole, (0, 1) read as a
  cat's ears, (4, 0) crowded the entry -> (1, 4), on the diagonal. Same node counts. tag earth-w1q clean.
- 2: left (the start cell, sparse by design B4: two Diamonds, two Crescents, the city gate's far half).
- cleanup: unused rampart() removed (pagoda() and battlement() replaced in place); 8's great wall gets a step node
  before 1489 (its last link was 2.6 long; also keeps cell 8 at 54 nodes after its arch went to three stones).

- 51|104 (lens halves): the 36|78 and 51|104 split stones were one drawing (lens 5+5, sag 1.2). Changed 51|104 (36|78
  left, it holds the terrace3 fix): tried a 4+4 lens (cells drop a node each), a 6+6 lens sag 1.5/1.35 (road link
  spacing), a step at the 1638 end (spacing) -> the mirror of 55|106's stepped stone (arch of 4 + a step of 2 by 1959),
  piece d_step; d_s51's Hook curl flipped (clumped with it, 1.25). 51 and 104 +1 node each.
- 65/66 trail (the only switchback()): looked at on purpose, left: an outer arc, an inner arc and a summit on one
  centre, mirrored across the axis from 102; the two short stems at 102 make the pair read as twin scrolls, not a
  square wave.
- 8 looked at again after its last two edits (three-stone arch, step node before 1489): fine.

## Final (tag earth-w1)
Spacing base only (other link <0.6 4 nodes), 0 crossings, rules 208 pieces all pass, no Earth notable clumps < 1.5.
Cells (no 80/902) 722 nodes / 3336.4 = 0.2164 (was 717, 0.2149); no cell below its baseline count (65, 66, 89, 51,
104 +1 each). Mix 135 pieces, small 73 (54%), medium 33 (24%), big 29 (21%) (was 75 / 31 / 29: the 51|104
halves became medium). Render out/earth-w1.png.
