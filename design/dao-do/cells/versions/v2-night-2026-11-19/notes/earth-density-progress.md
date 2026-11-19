# Earth density pass (2026-11-18), progress

Brief: design/dao-do/cells/density-brief.md (+ coordinator update: wall pairs are one way among several: grow figures,
new pieces, axis pairs, pass-through arches, interlocks; mix them).
Land file: design/dao-do/cells/lands/earth.py; all new code appended at the END of the file (after the mirror_pieces
copies, so nothing is mirrored by accident); new piece names start with `d_`.

Baseline (tag earth-d0): 546 nodes in cells (620 with rim 902), density 546/3457 = 0.158; mix 102 pieces small 54%
medium 29% big 17%; spacing base only, 0 crossings, rules all pass.
Scratch tools: out/earth_dens.py (wall scan), out/earth_free.py (free-space render), out/earth_view.py (cells close-up,
comma list of cells).

## Done
- helpers appended: Wall (wall frame), put, arch (pass-through arch through two road nodes), contour (half hill
  round a road node), terrace_row.
- PAIR 66|2 ring 33.2, 1622-1621: city gate (arch of 5 + crown arc of 3, notable keystone), 8 a side.
- GROW 24 mountain road: outer ring arc of 6 from p0 (rho 3.0); 23 its own variant arc of 5 (two notables).
- GROW 36 terraces: terrace1 and terrace3 each get a parallel row of 5 tied at both ends (terrace bands).
- PAIR 36|78 ring 53.9, 1660-1661: split stone, lens 5+5 (sag 1.2).
- PAIR 51|104 spoke -28, 1638-1959: lens 5+5 (sag 1.2); PAIR 55|106 spoke +28, 1648-1960: lens 4+4 (sag 1.0).
- decided: no wall pairs on the 74.3 ring (brief excludes "the outer edge of the rim cells"; rim halves do not
  count anyway). Single-sided pieces hung from 74.3 nodes into the outer band are fine.
- tag earth-d3: cells (no rim) see check line; spacing base only, 0 crossings, rules pass.
- 182 one-sided arch candidates tested (out/earth-arch-cands.txt -> earth-arch-results.txt); 13 passed.
- ARCHES (one-sided pass-through, small): 65 1628-1629 (5), 87 1662-1663 (5), 89 1669-1670 (4), 75 1667-1668 (5),
  8 1679-1680 (5), 8 1677-1678 (4), 16 1687-1688 (4), 89 1688-1689 (4). (tag earth-d4)
- SMALL catalogue pieces (sweep out/earth_sweep.py lists passing placements; chosen by hand): d_s19 1636 Tadpole,
  d_s16 1656 Hook, d_s40 1658 Zigzag, d_s78 1674 Hook, d_s75 1685 Crescent, d_s55 1960 Diamond, d_s48 1682 Ring,
  d_s65 1626 Tadpole, d_s51 1639 Hook. (tag earth-d5)
- HUB 80: d_henge stone circle of 7 round an altar from 13 (8), d_s80 Crescent from 3 (4). (tag earth-d6)
- tag earth-d6: cells 699 nodes (0.202); mix 129 pieces small 61% medium 24% big 15% -> next additions MEDIUM.
- GROWN arches: 65 d_arch horns (crown of 3 over nodes 1-3, notables at both ends, 8); 8 d_arch left step (3 over
  nodes 0-2, 8). 55|106 lens redrawn as a stepped stone (arch of 4 + a step of 2 by 1960, 6 a side).
- 23 road arc notable q2 dropped (clumped with 23's hook). 16 arch off 1688 dropped (four figures on 1688); 16 gets
  a Hairpin switchback in the gorge from 1654.
- GROWN petals (interlock round 1659/1666): 78 outer arc of 4 (7), 75 outer arc of 3 (6), 48 outer arc of 2 (5).
- outer-ring arches (inner side of 74.3, single-sided): 16 1656-1655 crowned (8), 16 1653-1652 (4),
  55 1650-1649 (4), 51 1639-1640 (4).
- GROWN 36 terrace2: runs on two steps to th -16.6 (+2).
- tried and failed (spacing): lens/arch pairs on 1659-1660, 1666-1667, 1632-1633, 1625-1626, 1667-1668, 1673-1674,
  1683-1684, 1662-1663; contour hill pair round 1960; 19-side arches; 40 petal growth.
- cleanup: TRY line and unused contour helper removed; d_s comment says the angles came from the sweep.
- FINAL tag earth-dense: cells 741 nodes (0.214), +195; mix 133 pieces small 57% medium 28% big 15%; spacing base
  only, 0 crossings, rules all pass; also clean with borders.py compiled first. Render out/earth-dense.png.
