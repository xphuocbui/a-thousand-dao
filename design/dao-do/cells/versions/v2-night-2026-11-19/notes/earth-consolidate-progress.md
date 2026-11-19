# Earth consolidation progress (brief: design/dao-do/cells/consolidate-brief.md)

Baseline (tag earth-c0, untouched lands/earth.py):
- mix: `earth pieces 114 small 92 (81%) medium 8 (7%) big 14 (12%) nodes 587 mean 5.1`
- repeated drawings over the 3.3 limit: 8, all mirrored twins (peak_outer 23/24, keep 40/48, pyramid 75/78, tower 87/89)
- nodes per cell: c2 16, c8 38, c16 31, c19 34, c23 39, c24 39, c36 25, c40 23, c48 28, c51 27, c55 19, c65 21,
  c66 27, c75 20, c78 21, c80 12, c87 25, c89 23, c104 18, c106 16, c114 13, c117 17, c902 55
- spacing baseline: `other link <0.6 4 nodes` (base map), crossings 0, rules all pass

Plan: mirror sources first (24/23, 78/75, 104/106, 87/89, 40/48), then 8/16, 51/55, 19, 36, 65/66, 117/114, 902.
Cells 2 (start, rule 3.10 B4 big and sparse) and 80 (hub) left as they are.
Scratch viewer: out/earth_view.py <map> <cell> <png> (land frame, road ids, piece names + node counts).

## Cells done
- 24 (39 -> 42): Ring 1625 + Zigzag 1624 -> big "mountain road" spiral (10, from 1624); kite Tadpole 235 grown -> medium
  castle (star-fort ring of 8, from 235); crook 234 turned to ang 45.
- 23 (39 -> 42): mirrors 24 except the castle; its Wheel 254 grown -> medium mountain gate (double arch of 8).
- 78 (21 -> 20): Hook 1661 + Crescent 1678 -> medium bailey (crenellated wall of 7 on an orbit round the pyramid, 1660).
  (A lens "standing stone" in the left strip was tried and dropped: too cramped, long stem.)
- 75 (20 -> 22): mirror of 78 with a 6-node bailey (keeps the fork 1688 clear).
- 104, 106: kept as they were; a terrace fan (hub + two nested arcs, 8) was tried from 1671 and 1672 and does not fit
  beside the cairn.
- 87 (25 -> 25): Zigzag 1662 + Tadpole 1953 -> big standing stone (lens of 10, tips notable, from 1953); foot Diamond
  turned to ang -10.
- 89 (23 -> 23): Hook 1669 + Crescent 1954 -> medium hillside terraces (terrace_fan of 8 from 1954, facing the tower).
- helper functions moved to the top of earth.py (on/run/ks/spiral/castle/mountain_gate/lens/rampart/terrace_fan).
- 40 (23 -> 25): Tadpole dz40b 1674 grown -> medium caldera (rim of 6 round a vent notable, 7).
- 48: kept (a mountain pass "gorge" of 7 from 1684 was tried; too tight between spoke and keep, R3 at the door).
- 8 (38 -> 38): Crescent 1677 + Fork 1679 -> medium mesa (terrace band of two flat arcs, 8, from 1678).
- 16 (31 -> 30): Tadpole 1489 + Arch 1690 -> medium henge (7 stones round an altar notable, 8, from 1489);
  Crook 1686 + Hook 1652 -> medium terrace steps (ladder of 4 rungs bent on an orbit, 8, from 1652).
- 51 (27 -> 26): Crescent 1959 + Hook 1673 -> medium peak (summit hub, base arc of 5, two ridges; 7, from 1959).
- 55: kept (the quarry fills the cell).
- 19 (34 -> 33): Ring 1634 + Hook 1633 -> medium hill fort (castle of 8 on smaller orbits, gate on 1634).
- 36: kept (a switchback trail of 8 from 1663 was tried in the strip by the axis hex: too small to read, notables
  clumped; the left strip is held by three terrace-end notables).
- 65 (21 -> 22): Crook 1616 + Diamond 102 -> medium switchback trail (outer arc of 5, inner arc of 2 back, summit
  notable; 8, from the axis node 102).
- 66 (27 -> 25): Ring 1622 + Crescent 102 -> the mirror of 65's trail; Ring 1636 -> Diamond turned clear of it.
- 117 (17 -> 16): Fork 1612 + Crescent 1611 -> medium cirque (ring of 5 with two peak notables, 7, from 1612).
- 114 (13 -> 16): Crook 1617 -> its own cirque (peaks on the east side, 7, from 1618); Hairpin 1519 -> Hook.
- 902 rim (55 -> 56): Hook 1639 + Spur pair 1638 -> terraces (terrace_fan 8, rho 1.4/2.7, from 1639); Fork 1641 ->
  spur of three ridges (7); Crescent 1650 + Hook 1648 -> mountain gate (8, rho 2.2/1.15, from 1649); Tadpole 501 +
  Crook 404 -> caldera beside the axis road (7, from 501).
- 902 rim (-> 74): Hook 1652 grown -> peak (7); new: ring of six stones round an altar off 1637 (7), fallen stone
  (lying lens of 8) off 1651. 48 henge from 1665 tried and dropped (collides with the keep).
- mix now: earth pieces 100 small 53 (53%) medium 30 (30%) big 17 (17%) nodes 613
- final touches: rim caldera rim notable dropped (it clumped with the vent), rho 1.45; top-ups: Crook e16 off 1690
  (16: 30 -> 33), old Crescent a8 back on 1677 (8: 38 -> 42); unused gorge helper deleted; stale headers fixed.
- FINAL (tag earth-consolidated): earth pieces 102 small 55 (54%) medium 30 (29%) big 17 (17%) nodes 620 mean 6.1;
  crossings 0, spacing = base only, rules all pass (also clean with borders.py compiled first).
