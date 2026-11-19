# Metal review pass, window 3 (review-brief.md), progress

Window 3 = a cell and all its neighbours (cells sharing a wall road), other lands' cells across Metal's borders and the
border combos 912 (Earth, local -36) and 913 (Water, +36) included; rim 903 a neighbour (its large figures not
redesigned); hub 81 left alone.

Backup of the land file before the pass: out/metal-w3-bak.py; baseline map out/metal-w3-before-map.json, render
out/metal-w3-before.png (from the context map). Scratch: out/metal-w3-nbhd.py (neighbourhood viewer, axis down,
others dimmed, other lands' pieces blue-grey), out/metal-w3-nb.py (neighbour list), out/metal-w3-check.sh (Metal-only
check + notables + mix), out/metal-w3-ctx.sh (context map Earth + Water + Metal + borders + chaos + islands, audit and
cross-border notables), renders out/metal-w3-n<cell>.png.

Baseline: crossings 0, spacing only the base map's 4 "other link" nodes (Metal-only and context map), rules 222 pieces
all pass. Mix (metal): 154 pieces, small 77 (50%) medium 48 (31%) big 29 (19%), 997 nodes; 825 outside hub and rim.
Lowest other-piece notable gap 1.23 (58 tadpole 1719 - saw, 90/95 blade - crook). No slack: a swap keeps size class.

Order: mirror neighbourhoods back to back, inner to outer: 4; 61/68; 113/116; 20/34; 30/27; 41/50; 77/73; 90/95;
9/10; 58/57; 100/102.

## Windows
- 4 (with 61, 68, 113, 116, hub 81, Earth 2/80/114, Water 5/82/115): weak = the two flying swords, the start cell's
  only figures off the ring road, each a straight row of five ending in its notable (straight spikes, untouched by w1/w2).
  Changed: each blade one arc (circle through its first node and tip, sag 0.1, bowed towards the hub; bowing outward
  ran with the ring roads), so the pair curve in over the start figure. 5 -> 5 each. Open point (bead 1702): judged
  against coin W1 and the start ring: the -theta side carries lock + coin (two loops), the +theta side rings W5 + bead
  (two loops), crescents L/R mirrored; the bead balances the coin lightly. Kept.
- 61 / 68 (with 4, 20, 34, 30, 27, 113, 116; rendered as one axis-centred box): spades mirrored on 129, iron fan / bell,
  ingot / bagua, diamond 1709 / crook 1716. Weak = 68's crook, a three-node bent stick in the slot between its spade and
  the bagua. Changed: a hook (Hook bow out, ang -10, hand) curling up towards the spade; across the wall it answers 20's
  crescent from 1491, two commas turned against each other. Tried: crook bowed (barely reads), hook the other hand (1.28
  from the spade's notable). 3 -> 4. 61 left (its diamond over 34's pendant ring read as one pendant in w2).
- 113 / 116 (with 4, 30, 61 / 27, 68 and Earth 2, 23, 114 / Water 5, 26, 115; border spokes and their pieces judged
  together): the corners stay busy (B4 start cell beside them). Weak = 116's crescent on 1711, drawn straight, a long
  stick of four into the corner's middle. Changed: bow out (a curl). 113's crook 1704 tried bowed: it twins hook 1691
  beside it, left straight. Forks (w2 tried six variants) left. Across the borders: Earth's a114 wave and 113's fork,
  Water's Y115 hook and 116's fork sit clear of each other; nothing for the neighbours.
- 20 / 34 (with 61, 68, 27, 30, 73, 77, 90, 95; one axis-centred box): bows, whips and bowls mirrored, trident / gong, 34's pendant ring / 20's coins and crescent; 68's new hook and 20's crescent 1491 read as a turned pair, closed shapes on the -theta side of the axis (diamond, ring) against open ones on the +theta side. Nothing clearly weak. Left.
- 30 / 27 (with 34, 41, 61, 77, 113 / 20, 50, 68, 73, 116 and Earth 23, 48, 114 / Water 26, 42, 115): bells and fans
  mirrored, the compass the -theta corner's straight figure, the coin, spear and arrow on the +theta side; Water's
  whirlpool and raindrop across the border answer 27's coin and spear. Looked at 30's crook 253 (a bent stick by the
  compass) and the small gap in 27 at the mirror node on the Water spoke: tried the crook bowed / as a hook / crescent
  and mirrored into 27 for +1 small; hook and crescent fail spacing, the bowed crook barely changes 30 and in 27 stacks
  over the spear. Nothing clearly weak. Left.
- 41 (with 30, 58, 77, 100 and Earth 23, 48, 106, 912): weak = the crown's side points, notables on one straight link
  from the band's ends (w2 open point). Changed: each side point a curved horn, two links on one arc round its own
  centre from the band's end out and curling in towards the tall middle point (small node on the arc, notable tip).
  Horns 2.0 tall came 1.16 from the arcs' end notable o-99 (caught later, at window 10); shortened to 1.5 tall
  (tip (1.5, 1.75)): clears 1.5. 9 -> 11 (big stays big). Loops in the window: 100's ring
  1752, 58's tadpole 1753 and sawblade run in a diagonal row below the crown (judged in 58 / 100).
- 50 (with 27, 57, 73, 102 and Water 26, 42, 103, 913): the hook swords, arcs, crescent 1746 and hairpin 1764 read as
  curves; Water's bubbles across the border are round loops, 50's border side open strokes (good contrast). Weak = the
  hook on the Water spoke node 1526, drawn straight, a zigzag stick by the border hex. Changed: bow out (one smooth
  curve along the hex's side; an s-curve tried, wavier; the other hand fails spacing). 4 -> 4.
- 77 / 73 (with 9, 30, 34, 41, 58, 90 / 10, 20, 27, 50, 57, 95): wheels, spears, dings and split crescents mirrored;
  77's cusped diamond 1741 against 73's angular hairpin 1748 (bowing the hairpin would twin 10's curled hairpin 1767
  just below it). The quiet patches beside the spears balance the busy walls. Nothing clearly weak. Left.
- 90 / 95 (with 9, 10, 20, 34, 73, 77; one axis-centred box): mirrored whole (moons, sabres, blades of combo A,
  diamonds). Weak = the crooks on 1493, the crossguard over the blades, a bent bar of straight sticks. Changed: both
  bow out (mirrored), the guard's quillons curl at their ends. Re-aimed at -70 to clear the blade/sabre tips: 0.97 from
  the sabres; straight at -70 the same. Clump stays 1.23 (as w1). 3 -> 3 each.
- 9 / 10 (with 58, 77, 90 / 57, 73, 95 and the rim 903): racks, swords, axes and combo A blades mirrored; 9's chevrons,
  chain and bowl against 10's shield, hammer and hairpin. 10 has a quiet patch between its sword and the hammer's
  chain (about 2.8 units across); tried a small from the hammer's node 1735 (crescent, hook, hairpin, zigzag, crook,
  both hands): all 0.1-1.1 from the sword's notables or fail spacing. The rim's pentagons and diamonds meet the
  swords cleanly. Nothing else clearly weak. Left.
- 58 / 57 (with 9, 41, 77, 100 / 10, 50, 73, 102 and the rim's weiqi board and linked rings): weak = a row of closed
  loops down 58's -theta side (100's ring 1752, tadpole 1753, sawblade, the kite on 1719, which sat 1.23 from a saw
  tooth, the land's closest notables). Changed: the kite gives way to 57's open hairpin curl on 1729, mirrored (the
  mirror node of 1729 is 1719), so 58 and 57 now match there too (all but 58's crook 1718). Loops in 58 4 -> 3; the
  1.23 clump gone. 5 -> 5 (small for small). 57 left: its loops (tadpole 1763, sawblade, star) sit over the rim's
  linked rings, but the rim's large figures stay and the hairpin curl breaks the row.
- 102 (with 50, 57, the rim and Water 42, 103 and the dew combo 913): the Water border is a field of closed loops
  (102's rings 1761 and 1976, 57's tadpole 1763, the rim's kite, Water's teardrop, kite and crescent moon, 913's two
  dew drops). Weak = 102's straight pentagon ring on 1761, one more closed loop. Changed: opened into a horseshoe
  (Ring, horseshoe (open); arch, spur pair and hairpin tried: the arch reads as a second curl beside the whip, the others
  fail spacing or come 1.15-1.49 from the whip). Open point (crook 1763): in this window it leaves the junction
  between two walls into the cell, not along a wall; drawn bow out (a curl; the other hand ran on into the whip as
  one wave, a crescent lay along the spoke). 5 -> 5, 3 -> 3.
- 100 (with 41, 58, the rim and Earth 48, 106 and the crystal 912): hairpin 1522, ring 1752, whip, crescent 509, ji
  with the rim's pommel ring; Earth's cairn and a106 and the crystal's facets sit clear across the border. Nothing
  clearly weak. Left. Nothing for the neighbours.

## After-look (advisor)
- 4: the swords at sag 0.1 still read as straight strokes in the whole-land render; sag raised to 0.17 (0.25 too
  hooked): now clearly two curved blades framing the start. Passes.
- 41: the short-horn crown re-rendered in its neighbourhood (out/metal-w3-f41.png): reads as a crown with curled ends.
- 68 | 20: the new hook on 1716 and 20's crescent on 1491 are near-equal curls about three units apart, turned 180
  degrees about a point on the wall (out/metal-w3-f68b.png). Read as a turned pair, kept; unsure (w2 removed a curl on
  1716 for standing beside that crescent). Piece key renamed CELLS[68]['hook 1716'].
- 68 | 116 curls (crescent 1700, hairpin 1699, crescent 1711): three curls across one wall, of different sizes and turns;
  kept.

## Done (window 3, 21 neighbourhoods; mirror pairs back to back)
Final (Metal-only check per the brief): crossings 0, spacing only the base map's 4 "other link" nodes, rules 222 pieces
all pass. Context map (Earth + Water + Metal + borders + chaos + islands, recompiled before each border window and the
final render): crossings 0, spacing only the base 4.
Mix (metal): 154 pieces, small 77 (50%) medium 48 (31%) big 29 (19%), 1000 nodes (was the same mix, 997 nodes).
Density outside hub and rim: 828 nodes / 3336.4 = 0.248 (was 825, 0.247).
Lowest other-piece notable gap now 1.23 only at 90/95 (blade - crook, the crossguard; unchanged); the 58 tadpole-saw
1.23 is gone; no new pair under 1.5 (notable report diffed against the baseline).
Changed: 11 pieces in 9 changes (8 windows): 4 two swords curved; 68 crook -> hook; 116 crescent bow out; 41 crown
horns; 50 hook 1526 bow out; 90/95 crossguard bow out (two crooks); 58 kite 1719 -> 57's hairpin mirrored; 102 ring
1761 -> horseshoe and crook 1763 bow out.
Left: 20/34, 30/27, 77/73, 9/10, 100 (and 61, 113 within their pairs).
Loops: 58's row down its -theta side 4 -> 3 loops (the kite gone); the diagonal 100 ring 1752 -> 58 tadpole 1753 ->
sawblade still stands (three loops, kept: each a different size, the hairpin curl now ends it). 102's two rings -> one
ring and a horseshoe.
912/913 were in frame only for 100 and 102 (the inner border cells' windows are too far from r 79-84).
For the neighbour (Water): the border round cell 102 is mostly Water 103's closed loops (teardrop, kite on 512,
crescent moon) and the dew combo 913's two drops; Metal opened its ring 1761. If Water reviews 103, one of its loops
could open (e.g. the teardrop or the kite on 512). Earth: nothing.
Unsure: 68's hook beside 20's crescent (above); 102's crook 1763: I judged it leaving the junction between two walls
into the cell rather than lying along a wall (w2 and the task said along the wall), so it was bowed in place, not moved.
Render: out/metal-w3.png (whole land, context map); before: out/metal-w3-before.png.
