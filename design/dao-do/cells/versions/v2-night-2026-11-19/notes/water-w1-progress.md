# Water w1 progress (brief: design/dao-do/cells/review-brief.md, WINDOW SIZE 1, every cell but hub 82 and rim 904)
Scratch: out/water_w1_chk.sh <tag> (check + mix + density), out/water_w1_render.py <map> <cell> <out> [half] [--ids].
Baseline water-w1-0: 0 crossings, base warnings only (other link <0.6 4 nodes), 200 pieces all pass.
Mix (mix.py water, incl. rim): 134 pieces, small 71 (53%) medium 45 (34%) big 18 (13%), 857 nodes.
Density (cells but 82, 904): 714 / 3202 = 0.223; without cell 5: 690 / 2644 = 0.261.
Leave the Ice start figure alone.

## Windows
Baseline nodes per cell: c5 24, c11 55, c17 54, c22 44, c26 54, c32 44, c38 48, c42 28, c45 27, c46 33, c54 42, c59 36,
c69 32, c76 31, c86 39, c91 35, c103 29, c108 23, c115 18, c118 18.
Baseline notable pairs < 1.5 across pieces: c91/c86 splash k1 vs D_drop 1.29; c69 carp f1 vs Z69_1890 1.27; c54 tortoise
ff0 vs Y54_1890 1.45 (ff1 vs Z54_1811 1.52); c46 frost_star n0 vs ice_crystal r4 1.49; c45 icicle1 vs Z45_1782 1.26;
c38 T_tadpole n3 0.95 from Ice-start node 1445 (cluster 14); c22 Z22_1876 n3 1.40 from 1447 (cluster 14);
c108 vortex b2 vs K_kelp1 1.56.
Order: sources before mirrors (76 -> 69, 91 -> 86, 59 -> 54, 115 -> 118), then the rest.
Creature forms assigned: 69 carp -> braid (chain of lenses); 54 tortoise -> interlocking ripples (two rings sharing
two nodes); 17 seahorse -> meander; 22 shrimp -> curl; 59 starfish -> pearl in two orbit arcs.
- 76 (done): weak = the scallop (a shell of straight rays) and the eddy drawn in straight steps. Eddy links now arcs
  (curve(..., bow=0.1); mirrored into 69 too); scallop -> BRAID, three lens beads on an arc from 1882 (10 nodes, +1).
  69's mirror filter now leaves out 'braid'. Check water-w1-6 clean.
- 69 (done): weak = the leaping carp (a picture, five straight fin spikes). -> PEARL IN THE CURRENT, cell 14's grammar
  in one piece: ring of 4 (r 0.9) inside two arcs of 3 on r 2.3, tied radially, entered at the ring's foot from 1892;
  the four arc ends notables (10 nodes, same). Eddy rounder via 76. Check water-w1-9 clean.
- 91 (done, 86 follows): weak = the splash's drop notable on a straight stick in the cup, its rim notable k1 1.29 from
  D_drop's. Drop moved up into a sagging water surface (k0 - drop - k1, two arcs dipping inward; echoes the meniscus
  above): a FILLED CUP (8 nodes, same). D_drop turned -50 -> -45 (86: 50 -> 45): clump now 1.50. The WAVE trough and
  crest curls drawn with arcs (bow 0.1) instead of straight steps (76, 91 and their mirrors 69, 86). Check water-w1-14.
- 86 (looked, mirror of 91 + its own cusped D_drop): nothing further weak; left.
- 59 (done): weak = the starfish (a creature, hub with five spikes). -> ENDLESS CURRENT, a figure eight: loop of 5 (r 1.0)
  entered from 1880 touching a loop of 6 (r 1.2) at a notable node, slantwise down the cell (laid flat it made three
  rings in a row with the Tadpole), notables at the crossing and the big loop's far side (10 nodes, same). Check w1-17.
- 54 (done): weak = the Black Tortoise (a creature, head on a neck and four flipper spikes). -> MEETING RIPPLES, two
  equal circles (r 1.35, centres 1.6 apart, stacked down the cell) overlapping and sharing their two crossing nodes
  (notables), one node each inside the lens, four outside; entered from 1891; notables also at the lower circle's
  foot (12 nodes, same). Varied echo of 59's figure eight across the axis. Clumps with Y54/Z54 gone. Check w1-18.
- 17 (done): weak = the seahorse (a creature, straight snout and fin) and the koi eyes on straight sticks. Seahorse ->
  MEANDER from 1816, three half-circle bends (r 1.0, three links each on its own circle) swinging towards the koi and
  the axis, notables at two bends and the head (10, same). Koi: the eye is now the middle of an inner swag between the
  back nodes either side (a lens; small), the notable moved to the node before the head (6 each, same). Check w1-20.
- 22 (done): weak = the shrimp (a creature, three straight spikes), the fountain's top jet on a straight stick, the
  swell lying along its ring as one straight bar. Shrimp -> WAVE CURL (the C grown to 6 round its centre, its end
  winding in on two arcs to a notable eye; 8, same); fountain top j3 now on the circle round j2 through the side jets,
  arcs l1-j3-r1 (a dome; 7, same); swell links bowed alternately (a small wave). Z22_1876 left at ang 5 (1.40 from the
  axis hex's notable 1447; ang 9-14 hit the swell, 0 went to 1.05). Left: the lotus bud's leaf on a straight link
  (third change already spent here). Check w1-23.
- 26 (done): weak = waterwheel paddles (two straight spikes), the clam's pearl on a straight stick, the small
  whirlpool in straight steps; the cell is full of rings. Paddles -> a FLUME, an arc of 2 on an outer orbit bridging
  rim nodes r45 and r135 (11, same; buckets on both sides hit the raindrop); pearl removed and the clam left an open
  shell (closing it over the pearl made one more ring) (8 -> 7); whirlpool links bowed 0.16. Cell 54 -> 53. Check w1-27.
- 45 (done): weak = winged-crystal spikes (two notables on straight links), icicle1 tip 1.26 from Z45_1782's notable,
  an empty patch in the lower middle. Wings -> pointed caps bridging two rim nodes each (8, same); Z45_1782 n2 made
  small; new Y45_1795 Arch (bow out, from 1795, tested alone, +5). Cell 27 -> 32. Check w1-29.
- 46 (done): weak = the frost star's three straight spikes and the ice crystal's straight two-link icicle. Each frost
  arm now bends on one circle through the hub (a turning frost whirl; n0 turned 132 -> 137 to keep 1.5 from the
  crystal); the icicle bends on one circle. The lotus bloom does not crowd the Ice start (about 3.8 from its nearest
  notable); left. Counts same. Check w1-31.
- 42 (done): weak = four rings in a row (bubble_s, the Z42 Diamond, bubble_m, bubble_l), the seaweed frond as a
  straight two-link spike, an open patch by the seaweed top. Z42_1877 Diamond -> Crescent bow out (tested alone,
  1.64 to the nearest notable; 4, same); frond now three nodes curling up into the patch on arcs (+1). 28 -> 29.
  1865 has no room (every hanging candidate from it failed). Check w1-32.
- 108 (done): weak = the drip hook ending in a straight stick back into the cell, four tips bunched in the middle.
  Drip hook's last node now curls on (1.2, 190) with bowed links (bow 0.15); kelp2 turned 6 -> 16 (its tip was 0.94
  from the new curl end). Vortex b2 vs kelp1 1.56 (unchanged, >= 1.5); growing the vortex (VS 1.3) hit the spoke road
  and brought kelp1 to 1.27, reverted. Counts same. Check w1-35.
- 103 (looked): teardrop, crescent moon, wave scroll, crescent and tadpole all on circles, balanced; nothing clearly
  weak; left.
- 11 (done): weak = the whirlpool (the centre figure) stepping in straight segments. Its links are now arcs (bow 0.1).
  Rest (pond, current, lotus petal, crescents) fine; counts same. Check w1-36.
- 32 (done): weak = the reflection hung from 1871 on a straight stem of 4.3 across the cell. Turned over into a bowl
  cupping up towards the moon (round L(49.6, 26.8), same radius and angles), stem now about 1.8 (7, same). A deeper
  bowl (centre r 49.3) hit the lotus. Check w1-38.
- 38 (done): weak = T_tadpole's notable 0.95 from the axis hex's notable 1445 (the worst clump in the land), the lily
  pad's bud on a straight stick. Tadpole turned 5 -> -10 (tested alone; 1.83 to the nearest notable); the bud is now
  the middle of an inner swag p1 - bud - p3 (a vein; 10, same). Check w1-39.
- 5 (looked, the Water start cell): crescents from the hub ring and the mirrored ripple hooks are on circles and
  even; the cell is sparse by design (start cell, light touch); nothing clearly weak; left.
- 115, 118 (looked): channel S, eye-lens half / spoke arch, small Ring; balanced, nothing clearly weak; left.
- (end) koi_current's first notable moved n2 -> n3 (n2 sat 1.34 from koi_a's new notable n3).

## Late edits (after an advisor review)
- 76 braid lens width 0.75 -> 0.55 (at 0.75 the beads read as three rings in a row); joint look at 76 | 59 | 42 round
  1880: still ring-heavy across those walls (Z76_1880 ring, 59's figure eight, 42's bubbles) - for window 2.
- 45: the Y45_1795 Arch dropped (it lay along the bottom road beside Z45_1794, a wall-glued arch); 45 back to 27.
- 69 and 17 re-rendered after the crest bow and the koi_current change: fine.
- Header comments that described removed figures corrected; dead CARP / _lens / O76s / SC / O59s / STAR removed.

## Final water-w1 (check_land.sh water-w1 ..., unfiltered)
0 crossings, spacing base warnings only (other link <0.6 4 nodes), 200 pieces all R0-R4 pass.
Mix (mix.py water, incl. rim): 134 pieces, small 71 (53%) medium 44 (33%) big 19 (14%), 858 nodes (was 134, 71/45/18,
857). Repeated drawings: 3, same as the baseline (c82 armOut, the rim armillary pair; none mine).
Density (cells but 82, 904): 715 / 3202 = 0.223 (was 714, 0.223); without cell 5: 691 / 2644 = 0.261 (same).
Cell changes: c26 54 -> 53, c42 28 -> 29, c76 31 -> 32; all others same.
Notable pairs < 1.5 across pieces left: c22 Z22_1876 n3 1.40 from the axis hex's notable 1447 (angles 0-14 tried).
Near the line: 108 vortex b2 - kelp1 1.56, 46 lotus t30 - icicle d2 1.53, 91/86 cup k1 - D_drop 1.50.
Render: out/water-w1.png.
