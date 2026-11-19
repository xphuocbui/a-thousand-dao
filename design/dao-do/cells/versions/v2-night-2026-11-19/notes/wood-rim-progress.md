# Wood rim (cell 905) progress, brief design/dao-do/cells/rim-brief.md

Baseline `wood-rim0`: c905 76 nodes. Checks: crossings 0, base warning other link <0.6 4 nodes only, 215 pieces pass.
Backup: out/wood-rim-bak.py. Viewer: `python -I design/dao-do/cells/out/wood_rimview.py <map> <png> r th half [px] [--ids]`
(land frame, axis down).
Before: lingzhi + twin (1847/1857), gourd + twin (1850/1860), peach (1372), stalk_leaf1-3 (504/476/1371, combo C),
rim_bigleaf (1845), rim_tree (1855), keystone_w/e (2009/2010), leaf_rim (1853-1854 wall half), gust_rim (1843-1844).
Space: th -33..33 past r 74.3; c914 th -38..-33 r 79-87, c915 th 33..39 r 83-91; Thunder island th -45..-27 from r 99.5.
Wood land already has: pinwheel gust (cell 44), growth rings (60), many curls/spirals, leaf whorl (35).

Plan: remove lingzhi, gourd (+twins), peach, bigleaf, tree. Keep keystones, wall halves, stalk leaves (vine of the gourd).
New: HO LO gourd on the axis from 1372 (one cord, stopper), LANTERN pair from 1851/1861, abstract FOUR-POINT STAR pair
(concave arc sides, inner ring) from 1846/1856.

## Log
- rim1: lingzhi, gourd mediums + twins, peach, rim_bigleaf, rim_tree removed (c905 76 -> 22). Combo C comment now
  "gourd vine". Checks clean (208 pieces).
- rim2-8: HO LO off 1372: lid arc of 5 round the neck (notable ends), neck ring 6, waist knot notable, body ring 10,
  highlight arc inside (216->324, orbit 1.95 at 270: an open lune; 1.75 read as a straight cut, 2.15 a sliver), one cord
  on an outer orbit from the knot to a tassel. 28 nodes, 7 notables. Tried: tangent-ish snowman (rings 1.2/2.3), radial
  highlight box (clumsy). Checks clean. c905 50.
- rim9-10: LANTERN pair off 1861 / 1851 (mirror_pieces): hanger, caps of 3, side ribs of 5 bowing out (notables at the
  widest), centre rib with the light notable, jade bead (ring of 4) below. A split two-tip tassel read as legs (stick
  figure), replaced by the bead. 18 nodes, 4 notables each. Checks clean. c905 90.
- rim11-12: FOUR-POINT STAR pair off 1856 / 1846 (mirror): tips r 4.6, inner corners r 2.3, sides arcs bowing in
  (bow 0.1; 0.35 pulled the mids onto the ring and crossed), inner ring of 8, cross of spokes to a centre notable.
  Entered at the tip (no stem node: a stem node at 1.3 sat on the tip). Ridges tip->ring dropped (triple lines). 21
  nodes, 6 notables each. Checks clean. c905 132.
- rim13: stars enlarged (tips 5.0, corners 2.5) and moved out one stem node (centre r ~81.7). Lantern bottom-cap knot
  made a notable (20 nodes, 5 N; the earlier "18" was a miscount).
- FINAL wood-rim: c905 76 -> 134. holo 28 (7 N), lantern_e/w 20 (5 N) each, star_e/w 22 (6 N) each, kept: stalk
  leaves x3 (12), keystones (2), leaf_rim + gust_rim halves (8). Checks (wood + borders + islands, and all lands):
  0 crossings, base warnings only, all pieces pass. Nearest Thunder/Wind-start node: star_w 19.8, lantern_w 38.6.
  Renders: out/wood-rim.png (whole rim), out/wood-rim-centre.png.
  Density: land 905 piece nodes / 3468 = 0.26; rim band r 74.3-90 th +-33: 106 / 1486 = 0.07 (cannot match the land
  with 2-4 large figures hung from the ring; Earth 147, Metal 114, Fire 86, Water 78 nodes for comparison).
- Close-ups after the final changes (out/wood-rim-starE/W.png, wood-rim-lanE/W.png): no slivers where the star sides meet
  the ring, lantern base clear. out/wood-rim.png re-rendered tighter (r 90, half 34); wide view now out/wood-rim-wide.png.
  Band density r 74.3-90, th +-33 (same measure for every rim): c901 0.058, c902 0.108, c903 0.073, c904 0.032, c905 0.071.
  Earth still has star_R/L (octagram + inner square, earth.py l.930): two rims now carry a mirrored star-outline pair.
