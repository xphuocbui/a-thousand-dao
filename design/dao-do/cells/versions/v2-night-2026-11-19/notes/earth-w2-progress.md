# Earth review pass, window 2 (2026-11-19), progress

Brief: design/dao-do/cells/review-brief.md, WINDOW SIZE = 2: every pair of Earth cells sharing a wall road (2+ shared
road nodes), rim 902 pairs included (rim large figures not redesigned), hub 80 left alone.
Backup of the land file before this pass: out/earth-w2-bak.py. Baseline map: out/earth-w2-0-map.json.
Check: sh out/earth-w1-chk.sh <tag> <cells> (check_land + clumps + density + close-up renders).
Pair renders: LBL=0/1 python -I out/earth-w1-view.py <map> <a,b> <out.png> 28 [margin].

Baseline: spacing base only (other link <0.6 4 nodes), 0 crossings, rules 208 pieces all pass.
Cells (no 80/902) 722 nodes / 3336.4 = 0.2164. Mix 135 pieces, small 73 (54%), medium 33 (24%), big 29 (21%);
repeated drawings over the limit 17. Small floor 50% = 68 of 135.
Per cell: 2:24 8:54 16:54 19:38 23:47 24:48 36:42 40:30 48:35 51:40 55:33 65:36 66:34 75:34 78:33 87:30 89:32
104:24 106:22 114:16 117:16 902:166.

Windows (50): 2|65 2|66 2|114 2|117 8|16 8|51 8|78 8|87 8|902 16|55 16|75 16|89 16|902 19|23 19|36 19|66 19|75
19|89 23|48 23|66 23|75 23|114 24|36 24|40 24|65 24|78 24|117 36|65 36|78 36|87 40|51 40|78 40|104 48|55 48|75
48|106 51|78 51|104 51|902 55|75 55|106 55|902 65|66 65|117 66|114 75|89 78|87 87|89 104|902 106|902.
Skipped as corners (one shared road node, no wall): 8|89 16|87 19|65 19|87 36|66 36|89.

Open questions from w1: 8 wall vs 19 ridge (wave / clouds); plain wall-glued arches (four four-stone); 65 hill ring
echoing cell 14; rectilinear centres; busy corner 1681/1682.

## Windows done
- 8 (all its windows; open question "wall vs ridge"): weak = the great wall's half circles bulging in and out in turn,
  the same drawing as Water's wave train (water.py cell 22). Changed: great_wall() redrawn: one gentle arc (bow 0.055
  towards the centre) from E(72.3,-13.9) off 1642 to E(69.7,-1.2) on to 1489, 17 nodes at even steps round its
  centre, four square watchtowers across it (wall node -> corners on rho -+ 0.8 at that step), notables on the outer
  corners of towers 2 and 4. 23 nodes, same. tag earth-w2b. (Checked: memory's rejected "beads" = path nodes on roads,
  not this.)
- 16 cliffs (8|16): tried the two zigzags on two orbits round the steps' centre E(69.5, 24.5) at even steps: still
  sticks, now a mechanical saw, and collided with d_g16 and d_arch2 -> reverted, cliffs left (unsure).
- 19 (open question "wall vs ridge"): weak = the three round hills read as clouds (equal round bumps on one side).
  Changed: ridge() = three pointed peaks: crest notable straight above the middle of its valley line (0.4 / 0.64 / 0.4
  of the chord), each flank an arc bowing out 0.08 of its chord with one node at its middle. Same 13 nodes.
  mid19b Crescent 0 -> 15 degrees (clumped with the west peak's crest, 1.36). tag earth-w2g.
- 65 (open question "hill echoes cell 14"): weak = the hill's outer contour, a closed ring of eight bridging 1615-1627
  through its diameter (cell 14's signature). Tried twin_peaks (two overlapping lobes with a pass): read as a pair of
  spectacles / an owl face, dropped. Tried the outer contour opened at the bottom (gap 4): a pendant on a string.
  Changed: hill(gap=0): the outer contour opened into a C at its top node, the horns r1 / r7 notables, r0 now a
  funnel node from 1615 into the inner ring (i0, i3); r6 back to small. Same 13 nodes. tag earth-w2f.
- 48|55 (keep beside quarry, two square loops; quarry also echoes the rim cong): three tries, none kept: quarry as an
  open pit with a switchback haul road down three benches (quarry_pit: read as a polygonal spiral, a whirlpool, and
  emptied half of 55); the quarry's outer rim round (round without, square within: a Metal cash coin); 48's keep as a
  castle (sparse, clumped with top48/dz48a). Left (unsure).
- 48|106 (busy corner 1681/1682): weak = the Hook off 1681 with the Ring off 1682 in its curl, three notables bunched.
  Changed: both replaced by one terrace fan off 1682 (orbit 1.5 at 35 degrees, notables o1/o2, not 89's o0/o3), 8
  nodes; 1681 free. 48: 35 -> 34 nodes. Mix small 71 (53%), repeated 17. tag earth-w2i.
- 16|89 (arches): weak = 89's plain four-stone arch glued under the ring at 1688-1689. Changed: a split stone, the
  same arch (sag 1.07) mirrored across the ring into the head of 16's canyon between the cliffs (piece d_split in
  89 and 16). 16: 54 -> 58 nodes. tag earth-w2j. Tried first: gable() (a pointed gate, two flank arcs meeting at a
  notable crest) for 89 and 16's arches: read the same as the arches, spacing with 89's foot/terraces -> not used.
- 51/55 arches (1639-1640, 1650-1649, a mirrored pair): tried gable() h 1.2 / 1.5: small tents, no better, crest
  clumped with 51's cave (1.17) -> left.
- 16 (16|902, 16|75): weak = the plain four-stone arch glued at 1653-1652, tying the east cliff's foot to the steps'
  foot. Changed: removed (16 back to 54). To hold density, the great wall got one more wall node (n 18, 8: 54 -> 55).
- 106 (48|106, 106|902): the empty strip by 1681/1522/508 looked at: a Crescent / Diamond off the freed 1681 clashes
  with a106 at every named angle -> left.
- Swept and left (nothing clearly weak, or a mirrored / named figure): 2|65 2|66 2|114 2|117 8|51 8|78 8|87 8|902
  16|55 19|23 19|36 19|66 19|75 19|89 23|48 23|66 23|75 23|114 24|36 24|40 24|65 24|78 24|117 36|65 36|78 36|87
  40|51 40|78 40|104 48|75 51|78 51|104 51|902 55|75 55|106 55|902 65|66 65|117 66|114 75|89 78|87 87|89 104|902.

- 8 again (8|16 from the final map): with n 18 the wall had five plain nodes before 1489 against one at the start;
  towers moved to (2, 7, 12, 17), notables on towers 2 and 4 (o7, o17): even ends. gable() removed (unused).
- 16|89 again: 1688 and 1689 now carry four figures each (cliff, split halves, 75's fork / 89's foot); no rule limits
  figures per road node (rules 3.11 / 3.20: road nodes are hubs; 1660 carries five); by eye it reads as the canyon's
  mouth, kept (unsure).
- Re-read from the final map: 87|89 75|89 8|87 8|51 19|66 19|89 36|65 65|117 23|48; nothing new. 87's standing stone
  and the new split lens sit on opposite sides of the towers, not read as a repeat.

## Final (tag earth-w2)
Spacing base only (other link <0.6 4 nodes), 0 crossings, rules 207 pieces all pass, no Earth notable clumps < 1.5.
Cells (no 80/902) 722 nodes / 3336.4 = 0.2164 (same). Per cell changes: 8 54 -> 55, 48 35 -> 34; others same.
Mix 134 pieces, small 71 (53%), medium 34 (25%), big 29 (22%) (was 135: 73 / 33 / 29); repeated drawings 17 (same).
Render out/earth-w2.png.
