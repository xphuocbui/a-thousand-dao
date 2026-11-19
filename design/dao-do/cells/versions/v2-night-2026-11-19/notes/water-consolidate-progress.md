# Water consolidation progress (brief: design/dao-do/cells/consolidate-brief.md)

Baseline `water-c0` (pre-consolidate copy: out/pre-consolidate/water.py):
`water pieces 145 small 130 (90%) medium 12 (8%) big 3 (2%) nodes 664 mean 4.6`; repeated: wave crest/trough sig x4.
Nodes per cell: c5 26, c11 51, c17 42, c22 39, c26 34, c32 36, c38 41, c42 27, c45 27, c46 20, c54 31, c59 29, c69 34,
c76 31, c82 14, c86 36, c91 36, c103 25, c108 22, c115 8, c118 14, c904 41.
90% floors: c5 24, c11 46, c17 38, c22 35, c26 31, c32 33, c38 37, c42 25, c45 25, c46 18, c54 28, c59 27, c69 31,
c76 28, c82 13, c86 33, c91 33, c103 23, c108 20, c115 8, c118 13, c904 37.

Target ~120 pieces: ~63 small / 36 medium / 17 big. Light touch (no bigs): 5, 82, 45, 46, 115, 118.
Mirrors: c86<-c91, c69<-c76, c54<-c59, c118<-c115 (built by mirror_pieces; Z.. rows not mirrored).

## Roster (ideas, one drawing each)
- 91/86: tide pool (ring of 7 + inner notable) from 1868/1869; undertow arc (fan of two nested arcs) from 1885
- 76/69: breaker (nested crest arcs) from 1880/1881; foam ring
- 59/54: (ripple exists) + spray fan
- 11: whirlpool exists; lotus-bud fan from 1802/1803; ripple pair from 1805/1806
- 17: koi exist; ... 
- 22: fountain exists; 26 clam; 32 moon; 38 lily pad; 42 bubbles; 103 teardrop; 108 kelp; 904 jellyfish

## Cells done
- 91 (36->35): wave_trough lengthened 6->7 (differs from crest now); Ring 1869 + Hairpin 1868 -> MENISCUS (8, swag
  bridging 1868-1869 + inner arc); Crook 1885 + Spur pair Z91_1884 -> SPLASH CUP (8, bowl from 1885, bowed rim spikes,
  drop notable); D_drop turned to ang -50.
- 86 (36->39): mirror of 91 (meniscus, splash, trough 7); Wheel 1876 removed; Tadpole 1498 -> Diamond cusped ang 50.
- 76 (31->31): Tadpole 1866 + Crescent Z76_1865 -> EDDY (8, spiral from 1866); Fork 1881 + Diamond Z76_1882 ->
  SCALLOP (9, hinge off 1882, 3 rays, bumped edge of 5).
- 69 (34->32): mirror takes crest + eddy (from 1873); Tadpole Z69_1872 removed (eddy's place); Spur pair 1891 +
  Hairpin Z69_1892 -> LEAPING CARP (10, lens body from 1892, forked tail, dorsal + pectoral fins).
- 59 (29->30): ripple_outer 5->7 (medium); Hook 1880 + Crook 1881 + Crescent Z59_1879 -> STARFISH (10, five curved
  arms round a hub off 1880, a whirling star).
- 54 (31->32): mirror takes the ripple + Tadpole only; Diamond 1891 + Hairpin Z54_1889 -> BLACK TORTOISE (12, shell
  ring of 6 from 1891, neck + head, four flippers); Z54_1811 turned to ang 38.
- 11 (51->51): Ring 1883 + Ring Z11_1803 -> POND (12, ring of 8 off 1883 + inner ring of 4, one radial link); Fork
  1806 + Ring Z11_1805 -> CURRENT (7, arc on an outer orbit round the whirlpool centre, from 1805).
- 17 (42->40): Tadpole 1816 + Ring Z17_1815 -> SEAHORSE (10, tail curl gripping 1816, body arc, snout, dorsal fin);
  Diamond 1893 + Diamond Z17_1892 + Arch 1812 -> WATER GOURD (11, ring of 4 from 1893 over a ring of 7, neck link).
- 22 (39->39): Hairpin Z22_1794 + Crescent Z22_1796 -> WAVE TRAIN (10, four humps on r 46.3, stem from 1794); Ring
  1795 -> LOTUS BUD (6, lens bud + leaf); Hook 1874 + Hairpin Z22_1873 -> SHRIMP (8, C of 5 from 1874, tail fan,
  feeler); C_crescent turned to ang 215.
- 26 (34->32): Crook 1784 + Tadpole Z26_1785 + Hairpin 1786 -> WATERWHEEL (11, ring of 8 from 1785, diameter spokes
  to a notable hub, two paddles).
- 32 (36->34): reflection 5->7 (radius 2.5, medium); Hook 291 + Crescent Z32_292 (seam) + Ring Z32_1870 -> LOTUS in
  side view (9, stem from 1870, lens centre petal + two outward petals).
- 38 (41->40): Crook 1787 + Ring Z38_1788 -> DEWDROP LENS (8, lens + pearl on a stem from 1788); Hook 1866 + Ring
  Z38_1867 -> FALLING DROP (8, ring of 6 on a curved tail of two from 1866).
- 42 (27->28): bubble_m 5->6 (medium); Crook 1865 + Tadpole Z42_1880 -> SEAWEED (8, wavy strand of 6 from 1880, a
  two-node frond).
- 103 (25->23): Tadpole 1798 + Ring Z103_1991 -> CRESCENT MOON (8, closed crescent hung by its back from 1991).
  Seam pieces (C_crescent 511, Z103_512) left as they are.
- 108 (22->23): Ring 1888 + Crook Z108_1889 + Crescent Z108_1992 -> TAIJI VORTEX (7, S of two spiral arms through a
  notable eye, from 1888); new DRIP HOOK (6, arc from 1887 down the open right side). Kelps kept.
- 904 rim (41->44): Hairpin 1800 + Tadpole 1798 -> GREAT WAVE (11, spiral curl from 1800, two foam claws); Fork
  1810 + Crescent 1808 -> WATER DRAGON (10, S of two half-circles from 1810, notable head + two horns).
- 5 start (26->24): Ring 1772 + Hook Z5_1775 -> DOUBLE RIPPLE HOOK (8, outer arc of 4 from 1774 stepping in to an
  inner arc of 4); mirrored twin from 1780 replaces Tadpole 1778 + Hook Z5_1781. 4 pieces (B4 big and sparse).
- 82 hub (14->14): Diamond 7 + Crescent Z82_21 -> SEED DROP (8, lens on the axis bridging 7 and 21).
- 46 (20->20): Tadpole Z46_1776 + Crook 1788 -> ICE CRYSTAL (8, hexagon from 1776 + icicle of two). Ice start untouched.
- 45 (27->27): closed Fork 1793 + Diamond Z45_1792 -> WINGED CRYSTAL (8, hexagon from 1793 + two side spikes).
- 115 (8->8): Ring 1784 + Crook 1771 -> WATER CHANNEL (8, S of two half-circles bridging 1771-1784).
- 118 (14->13): mirror of 115 (channel 1777-1791); Crescent off 1777 removed; Z118_1790 ring kept.

## Final (water-final)
`water pieces 109 small 57 (52%) medium 37 (34%) big 15 (14%) nodes 659 mean 6.0`; repeats over 3.3: 0.
Crossings 0, spacing = base warnings only, rules 109 pieces all pass. Render: out/water-consolidated.png.
