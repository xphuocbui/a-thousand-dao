# Metal consolidation progress (2026-11-18)

Baseline map: out/metal-c0-map.json (do not overwrite). Tools: out/metal-try.py (candidate tester), out/metal-rcell.py
(axis-down cell render with labels). Figure helper G() added to metal.py (orbit figures).

Baseline mix: metal pieces 189, small 172 (91%), medium 11 (6%), big 6 (3%), nodes 816, mean 4.3.
Repeated drawings baseline 6: blade x4 (combo A, protected), sawblade x2 (58/57 mirror twins).

Mirror snapshots: 73 <- 77, 57 <- 58, 102 <- 100, 116 <- 113 (taken at the mirror_pieces line; edit pairs together).

| cell | nodes before | floor 90% | ceiling 115% | done | after | what |
|---|---|---|---|---|---|---|
| 4 | 18 | 16 | 21 | left | same | inner cell kept small (gradient; mix target met) |
| 9 | 59 | 53 | 68 | yes | 55 | chain, chime rack (big), jian sword (big), axe |
| 10 | 59 | 53 | 68 | yes | 57 | 9 mirrored + meteor hammer (big) |
| 20 | 44 | 40 | 51 | yes | 43 | bow (big), whip mirrored from 34, gong |
| 27 | 46 | 41 | 53 | yes | 49 | bell+fan mirrored from 30, coin (big), spear |
| 30 | 48 | 43 | 55 | yes | 48 | bell (big), moon, fan |
| 34 | 35 | 32 | 40 | yes | 36 | bow (big), whip |
| 41 | 37 | 33 | 43 | yes | 36 | nested arcs (big) |
| 50 | 37 | 33 | 43 | yes | 35 | arcs mirrored from 41, spear |
| 57 | 38 | 34 | 44 | yes | 35 | 58 mirrored |
| 58 | 40 | 36 | 46 | yes | 38 | star, tiger claw |
| 61 | 28 | 26 | 32 | yes | 26 | hand bell, spade money |
| 68 | 30 | 27 | 35 | yes | 30 | spade mirrored, chain |
| 73 | 37 | 33 | 43 | yes | 34 | pinwheel mirrored, axe |
| 77 | 38 | 34 | 44 | yes | 36 | pinwheel (big), ding (big) |
| 81 | 14 | 13 | 16 | left | same | inner cell kept small (gradient; mix target met) |
| 90 | 36 | 33 | 41 | yes | 33 | moon, ring sabre |
| 95 | 37 | 34 | 43 | yes | 34 | sabre+crook mirrored, moon (3-node inner arc) |
| 100 | 28 | 26 | 32 | yes | 27 | whip kept (centre figure), ji halberd |
| 102 | 30 | 27 | 35 | yes | 33 | whip+fork mirrored, ji leaning the other way |
| 113 | 15 | 14 | 17 | left | same | inner cell kept small (gradient; mix target met) |
| 116 | 13 | 12 | 15 | left | same | inner cell kept small (gradient; mix target met) |
| 903 | 49 | 44 | 56 | yes | 53 | two gongs (mirrored) |

Budget: ~29 pair-merges into mediums, ~13 triple-merges into bigs; bigs toward the rim.

## Log
- 30: crook 1704 + ring 1705 + crook 1706 -> hung_bell(1705) 11; crescent 1738 + crook 1737 -> moon(1738) 7; fork 1739 + hook 1740 -> blade_fan(1739) 8.
- 27: crescent 1712 + hook 1713 -> mirrored bell; diamond 1746 + hook 1747 -> mirrored fan; crook 1711 + crook 1710 + hook 1525 -> coin(1711) 12; fork 272 + hairpin 273 -> lens spear(273) 7.
- check metal-c2: clean (base 4 only), rules pass. Mix 87/8/5.
- 34: diamond 1707 + crook 1708 -> bow2(1707) 9; fork 1740 + arch 1741 -> spiral whip(1741) 8.
- 20: spur 1714 + crescent 1713 -> bow2(1714) 9 (twin of 34's); hook 1747 + fork 1748 -> mirrored whip; spur 1749 + diamond 1750 -> gong(1749) 8.
- check metal-c3: clean, rules pass. Mix 83/10/6.
- 41: crook 1737 + fork 1738 + hook 1739 -> nested(1738) 10. (claw tried at 1737/1752: no room, kept the small pieces.)
- 50: crook 1745 + diamond 1744 + hook 1746 -> mirrored arcs; hooks 1762 + 1761 -> lens spear(1762) 7.
- check metal-c4: clean, rules pass. Mix 81/11/8. Remaining cells must merge harder (keep ~4-5 small in 9/10).
- 77: diamond 1739 + diamond 1740 + crook 1754 -> pinwheel(1740) 11; crescent 1756 + fork 1757 + diamond 1758 -> ding(1757) 10.
- 73: mirror of 77 minus ding (crescent B, spear, wheel); kite 1767 + ring 1747 -> axe(1767) 7.
- check metal-c5: clean. Mix 78/12/10. Too many bigs vs mediums: prefer mediums from here.
- 90: kite 1742 + crook 1741 -> moon(1742) 7; spur pairs 1743 + 1492 -> ring_sabre(1743) 8.
- 95: crescent 1750 + tadpoles 1492, 1493 -> mirrored sabre + mirrored crook; fork 1749 + diamond 1748 -> moon(1749) 8.
- check metal-c6: clean. Mix 75/15/10, nodes 805. Outer cells should grow, mostly mediums.
- 9: fork 1756 + hook 1757 -> chain_links(1757) 8; zigzag 1758 + crook 1759 + hairpin 1760 -> chime_rack(1759) 10; ring 1495 + spur 1726 + crook 1496 -> lens sword(1726, n=3) 9; diamond 1721 -> axe(1722) 7.
- 10: all small pieces merged; 9's four mirrored; meteor(1735) 10 in place of the chevrons. 10 has no small piece left (no room; checked each).
- NOTE: metal-try.py rules line must be read (I grepped it out once; the sword R3 failure was caught by check_land; fixed with notables T, L2, R2).
- check metal-c7: clean, all pass. Mix 67/19/14, nodes 799. From here: mediums only (pairs -> 7-8 nodes), grow outer cells.
- 58: crook 1755 + tadpole 1754 + crook 1756 -> star(1755) 8; fork 1720 + crook 1721 -> claw(1720) 8. 57 = full mirror of 58 (hook 1765, ring 1764, crooks 1766/1731 merged).
- 100: whip 508 + crook 1717 -> ji(1717) 7 (a bell at 1752 had no room between hairpin 1522 and crook 1753). 102 = full mirror of 100 (whip 511 + diamond 1727 merged).
- check metal-c8: clean. Mix 61/24/15, nodes 791. Left: 903 (14 small), 61/68, 113/116, 4, 81: mediums only.
- 903: fork 1720 + crook 1722 -> gong(1721) outward 8, mirrored at 1731 (spur 1730 merged). Great-sword composition, keystones, crescent, kite, hook, crook kept.
- 61: hook 1693 + crook 1694 -> small_bell(1694) 7; fork 129 + crook 1695 + crook 105 -> spade(129) 8. 68: kite 129 + crook 105 -> mirrored spade; fork 1700 + hook 1702 -> chain_links(1700) 8.
- 4, 81, 113, 116 left as they were (inner; rule 3.3 gradient keeps smalls near the centre; mix already at target).
- FINAL metal-final: crossings 0, spacing base 4 only, 134 pieces all pass R0-R4. Mix 54/30/16, nodes 793 (816 before). Render out/metal-consolidated.png.
- REVISION after review: the whip is 100/102's centre figure, restored. ji(1717, ang 25) now takes crook 1717 + hairpin 1975; 102 mirrors whip and fork, ji(1727, ang -10) takes diamond 1727 (ring 1976 kept).
- lens(): arc centres now on the E-T bisector (cells 27 and 50 spears were off by 0.02-0.06).
- FINAL metal-final: clean, 135 pieces all pass. Mix 55/30/16, nodes 798.
