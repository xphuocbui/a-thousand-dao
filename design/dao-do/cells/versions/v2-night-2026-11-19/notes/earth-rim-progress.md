# Earth rim (cell 902) progress — rim-brief.md

Baseline (check earth-rim0): c902 = 74 nodes; base warnings only `other link <0.6 4 nodes`; rules all pass.
Before: stair, valley, keystone_w/e, terraces, spur, gate, caldera, peak, stones (henge), boulder, r7 (Ring off 1227),
dz902a (Diamond off 1644).
Land density (cells 2..117 excl. rim, 717 nodes / 3457) = 0.207.

Viewer: `python -I design/dao-do/cells/out/earth_rimview.py <map> <png> r th half [px] [--ids] [--names]` (land frame,
axis down).

Plan: pagoda on the axis split by the axis road (halves hang 1656/1646 -> 1227, finial off 1228); an abstract mirrored
pair beyond the keystones (th +-20); maybe a second pair further out.

## Log
- Removed from CELLS[902]: stair, valley, terraces, spur, gate, caldera, peak, stones (henge), boulder, r7 (Ring off
  1227), dz902a (Diamond off 1644, line in the consolidation block). rim_stair/rim_valley defs deleted. Backup:
  out/earth-rim-bak.py (before), out/earth-rim-v1.py (pagoda step 5.5 / thick 1.4 variant).
- Kept: keystone_w, keystone_e (on hook roads 1961/1962).
- New (RIM FIGURES block at the end of earth.py, before the hub-80 lines):
  pagoda_R/L (20 each, 1656/1646 -> 1227, four orbit roofs round PO=E(100,0)), finial (6, off 1228),
  star_R/L (eight-pointed star outline + inner square, 20 each, 1649/1639), cong_R/L (square round a circle, 16 each,
  1651/1641), ruyi_R/L (heart-head sceptre, 9 each, 1654/1644), bell (9, off 1637, tilted 160).
- Parent note: Fire has a trefoil rosette, Metal a ring of rings and a polar board: avoided (well-field lattice and
  the three-lobed ruyi head dropped; the land already has spirals (cells 23/24), so the rim spiral was dropped too).
- Final check earth-rim: 0 crossings, base warnings only, rules all pass. c902 74 -> 147.
- Advisor pass 2: pagoda top hip got a small node T (R3 from 1227 now T, U4, E4); pagoda roofs step 5.0 / thick 1.6;
  ruyi grew a lozenge plaque on the handle (11 nodes, notables k1/k3/k5); bell grew a second band (12 nodes);
  small gap pieces: eave_R/L (Crook off 1655/1645), end_R (Hook off 1648), each chosen among named candidates
  (out/earth_cand.sh) by notable distance and eye.
- FINAL (tag earth-rim): 0 crossings, base warnings only, rules all pass. c902 74 -> 166. In-band density
  126/641 = 0.197 to r 82, 141/817 = 0.173 to r 84 (land 0.207): short by ~7-28 nodes; nothing more fits by eye.
  Renders: out/earth-rim.png (render_box frame 70 23.5 44), out/earth-rim-landframe.png (axis up, outward up).
