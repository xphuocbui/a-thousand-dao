# Metal review pass, window 4 (review-brief.md), progress

Window 4 = a cell, its neighbours and their neighbours (two rings), about six regions with overlap, judged for
composition: axis balance, rhythm and spacing of the big figures, size gradient, runs of one shape kind, empty patches
and crowded corners. Hub 81 left; rim 903's large figures not redesigned; neighbours' border cells in the renders.

Backup of the land file before the pass: out/metal-w4-bak.py; baseline map out/metal-w4-before-map.json, notables
out/metal-w4-before-nots.txt, render out/metal-w4-before.png (context map). Scratch: out/metal-w4-check.sh (Metal-only
check + notables + mix), out/metal-w4-ctx.sh (context map Earth + Water + Metal + borders + chaos + islands),
out/metal-w4-try.py (candidate trial), out/metal-w4-reg.py (two-ring region lists), out/metal-w4-nbhd.py (viewer, copy
of w3's), renders out/metal-w4-r<k>.png.

Baseline: crossings 0, spacing only the base map's 4 "other link" nodes (Metal-only and context map), rules 222 pieces
all pass. Mix (metal): 154 pieces, small 77 (50%) medium 48 (31%) big 29 (19%), 1000 nodes. Zero headroom: swap like
for like. Lowest other-piece notable gap 1.23 (90/95 blade - crook, the crossguard).

Regions (two rings round the centre; Metal cells listed):
- R1 inner band, centre 4: 4, 61, 68, 113, 116 / 20, 27, 30, 34 (+ Earth 2, 23, 114, Water 5, 26, 115).
- R2 middle band left, centre 30: 30, 34, 41, 61, 77, 113 / 4, 9, 20, 58, 68, 90, 95, 100 (+ Earth 23, 48, 106, 114).
- R3 middle band right, centre 27: mirror of R2 (+ Water 26, 42, 103, 115).
- R4 outer band left, centre 77: 77, 9, 30, 34, 41, 58, 90 / 10, 20, 61, 68, 95, 100, 113.
- R5 outer band right, centre 73: mirror of R4.
- R6 rim with the outer band, centre 9 + 10: 57, 58, 73, 77, 90, 95 / 100, 102, ... and 903.

## Coordinator's note (from Earth's w3): "41's hexagon beside 48's keep"
The hexagon across the border from Earth 48's keep is not a Metal piece: its vertices (1468, 1469, 1470, ...) are
unnamed base-map nodes (three checked by id: 1468, 1469, 1470), the Earth-Metal border wall cluster (no file of mine; mix lists no hexagon in 41). Metal's
nearest polygon loop there is 41's kite (Tadpole kite) on 1522, under the hex. For Earth: the keep faces a fixed hex,
so if the two polygons side by side read badly, the keep is the movable one.

## Windows
- R1 inner band (4; axis-centred box 0,36,23 and 0,44,13): spades, plates, forks, lock/rings W4/W5 mirrored; the start
  cell sparse (B4); the inner corners busy (accepted in w1-w3). Weak = 68's hook 1716 and 20's crescent 1491, two
  near-equal curls stacked right of the axis, both bowing the same way (w3 open point). Changed the family of one:
  20's crescent -> a wave (Zigzag wave, 1.0, 140, hand; a wavy kris) from 1491 into the slot between the axis and the
  coins. Tried: fork bow out / straight (a stick with two berries), spur pair bow out (reads as a curl again), horseshoe
  and curled tadpole (fail spacing), the slot left empty (a void beside the axis where 34's ring stands on the left).
  The hook stays, answering 61's diamond pendant. 4 -> 5 nodes.
- R5 outer band right (73; boxes 16,58,17 and, from the final map, 24,64,15 = out/metal-w4-r5d.png): wheels, spears, dings, crescent B mirrored with R4. Weak =
  10's quiet patch between the meteor hammer's chain and the shield (w3 open point). New road node 1734 (outer ring,
  under the patch; 1735/1731/1766 were tried before): a hook (Hook bow out, 1.0, 40) rises and curls under the shield,
  an inner echo of the hammer chain's arc. Tried at 1734: crescents, hooks, forks, tadpole, spur pairs, arch at 0-45
  degrees: all but this hook and two crooks fail spacing or sit 0.4-1.15 from the hammer. +4 nodes, +1 small.
  102 and the right loop field (final map): 57's tadpole 1763 (sceptre with 50's hook swords on the same node), 102's
  ring 1976 and the sawblade form a loop triangle over the rim's four linked rings. Tried 102's ring 1976 open (hook,
  crescent, hairpin both hands, spur pair, arch, at 100): all fail spacing (0.5-0.75 from the ji or the hook 1728).
  So the right keeps more loops than the left: decided by eye to leave it (102 is wedged between ji, whip and hook;
  the rim's linked rings are fixed). For a later pass: the 1976 ring is the one loop to open if 102 is ever re-laid.
- R2 middle band left (30; boxes -17,48,19 and -35,52,8): the kite on 1522 (see the coordinator's note) and the top of
  a run of four loops (kite, 100's ring 1752, 58's tadpole 1753, sawblade). Changed: kite -> hook (Hook bow out, 1.2,
  49) curling from under the hex towards 41's crescent 1752 (2.04 clear). Tried: spur pair (1.46 from the hex notable),
  wave (1.34), hook other hand (1.25 from the hex), round / curled tadpole (still loops), horseshoe and arch (spacing).
  5 -> 4 nodes.
- R4 outer band left (77; boxes -16,58,17, -24,64,15, -31,59,8): the diagonal 100 ring 1752 -> 58 tadpole 1753 ->
  sawblade (w3 open point). 58's tadpole kept (w2: with 41's crown up from 1753 it reads as one sceptre). Changed:
  100's ring -> horseshoe (Ring horseshoe (open), 1.2, 150, hand), an open small bell, echoing 102's horseshoe 1761.
  Tried: horseshoe at 165 (gap barely shows), at 180 other hand (1.2 from the whip), arch (1.26 from the whip), spur pair,
  curled tadpole. 5 -> 5. 57's tadpole 1763 is a frozen mirror of 58's: unchanged, so the right side keeps
  102 horseshoe 1761 / ring 1976 / 57 tadpole / sawblade, the left now horseshoe / tadpole / sawblade.
After these four: crossings 0, spacing base 4 only, rules 223 pass; mix 155 pieces, small 78 (50.3%), 1004 nodes.
- R3 middle band right (27; boxes 17,48,19 and 19,50,17): bells, fans, wheels, spears, dings, arcs mirrored with R2;
  50's curls (hook 1526, crescent 1746, hairpin 1764, hook swords) answer 41's (arcs, crescent 1752, new hook 1522,
  hairpin 1754); the big figures (bow, bell, coin, arcs, wheel, ding, gong) spread evenly. Nothing clearly weak. Left.
- R6 rim with the outer band (9 + 10; boxes -17,75,14 and 17,75,14, and the whole-band 0,73,38): racks, swords, axes,
  combo A mirrored; the rim's pentagons, weiqi board and linked rings meet the outer cells cleanly; the new hook on
  1734 and the rim's pentagon R read as one figure through the node. The 90/95 crossguard (w3 open point, 1.23 from
  the blades): tried mirrored crescent bow out (both hands, -80), hook bow out -75, crook bow out -60, crook bow in -90:
  0.27-1.08 from the sabres or no better. Left, fourth pass: it stays the land's closest notable pair.
- Size gradient (new criterion): inner 4/61/68/113/116 small and medium, 20/27/30/34 at r48 carry 2-3 big each, 90/95
  at r59 (beside the axis) none (moons, sabres, diamonds, the combo A blades), 9/10 at r69 big again; 100/102 at r69
  no big (small cells, 97 units²). The light 90/95 row between the big 20/34 and 9/10 is visible in the axis-centred
  render (out/metal-w4-mid.png); a merge into a big would take the mix under 50% (78/155 now: one small spare).
  Not changed (unsure).

## Done (window 4, six regions + axis-centred looks)
Final (Metal-only check per the brief): crossings 0, spacing only the base map's 4 "other link" nodes, rules 223 pieces
all pass. Context map (Earth + Water + Metal + borders + chaos + islands): crossings 0, spacing only the base 4.
Mix (metal): 155 pieces, small 78 (50.3%) medium 48 (31%) big 29 (19%), 1004 nodes (was 154, 77 (50%)/48/29, 1000).
Density outside hub and rim: 832 nodes / 3336.4 = 0.249 (was 828, 0.248).
Notables: report unchanged against the baseline (no new pair under 1.5; lowest 1.23 the crossguard).
Changed: 4 changes in 4 regions: 20 crescent 1491 -> wave (R1); 10 new hook on 1734 (R5); 41 kite 1522 -> hook (R2);
100 ring 1752 -> horseshoe (R4). Left: R3, R6 (crossguard tried again).
For the neighbour (Earth): the hexagon beside 48's keep is the Earth-Metal border wall cluster (base map), not a Metal
piece; if two polygons side by side read badly there, the keep is the one that can change. Metal's kite under the hex
is now an open hook. Water: nothing new.
Render: out/metal-w4.png (whole land, context map); before: out/metal-w4-before.png.

## After-look (advisor)
- Context map rerun in full from the final land file: crossings 0, spacing base 4 only; cross-border notables report
  shows nothing new under 1.5 (41 and 100 are Earth-border cells).
- 41 / 100 from the final map (out/metal-w4-r4e.png): the hook on 1522 runs across under the hex and curls down, the
  crescent 1752 rises beside it: different orientation and size, not twins; 100's horseshoe reads as a small open bell.
  Kept.
- 68 hook / 20 wave, before and after in one axis-centred box (out/metal-w4-r1cmp.png): the two ")" curls are now a
  ")" over a wave; clearly less alike, but still two open strokes with one notable each stacked right of the axis.
  Reduced, not closed (unsure). Not tried this pass: a non-stroke family on 1716 itself.
