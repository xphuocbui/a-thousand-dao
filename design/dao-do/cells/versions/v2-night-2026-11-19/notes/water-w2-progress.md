# Water w2 progress (brief: design/dao-do/cells/review-brief.md, WINDOW SIZE 2: every pair of cells sharing a wall road)
Scratch: out/water_w2_chk.sh <tag> (check + mix + density), out/water_w2_pair.py <map> <cellA> <cellB> <out> [half]
[--ids] [--names] (cell 904 = the rim), out/water_w1_clumps.py <map> (notable pairs < 1.5 across pieces).
Rim 904: look only, its large figures not redesigned; hub 82 and the Ice start figure left alone.
Baseline water-w2-0 (= final w1): 0 crossings, base warnings only (other link <0.6 4 nodes), 200 pieces all pass.
Mix: 134 pieces, small 71 (53%) medium 44 (33%) big 19 (14%), 858 nodes; repeated drawings 3 (not mine).
Density (cells but 82, 904): 715 / 3202 = 0.223; without cell 5: 691 / 2644 = 0.261.
Per cell: c5 24, c11 55, c17 54, c22 44, c26 53, c32 44, c38 48, c42 29, c45 27, c46 33, c54 42, c59 36, c69 32, c76 32,
c86 39, c91 35, c103 29, c108 23, c115 18, c118 18.

## Windows (46): 40 wall pairs + 6 rim pairs. Corner-only (one shared node, for window 3): 11|86, 17|91, 22|91, 38|86.
Order (sources before mirrors): 59|76, 54|69, 42|76, 42|59, 76|91, 69|86, 86|91, 11|91, 17|86, 11|76, 17|69, 11|59,
17|54, 11|17, 26|76, 32|69, 38|76, 22|69, 38|91, 22|86, 26|38, 22|32, 22|38, 26|42, 42|103, 59|103, 54|108, 45|46,
22|45, 32|45, 45|118, 38|46, 26|46, 46|115, 26|115, 32|118, 5|45, 5|46, 5|115, 5|118, 904|11, 904|17, 904|59, 904|54,
904|103, 904|108.

## Done
- 59|76 (done): weak = the joint at 1880 ring-heavy; Z76_1880 a ring of 4 in 76's corner beside the endless current's top
  loop, 76's lower-left patch (between spoke -23 and the braid, under the eddy) empty. Z76_1880 Diamond -> Crescent bow
  out (stem 1.6, ang 35, hand), an open arc rising into the patch, answering 42's seaweed across the spoke (4, same).
  Catalogue candidates tested alone (Hook s-curve / bow in, Hairpin, Zigzag, Crescent); the seaweed mirrored across the
  spoke was tried and hit the eddy. Check water-w2-1 clean.
- 54|69 (done): Z69_1890 (the same ring by 1890, next to 54's meeting ripples and 69's pearl) -> Crescent bow out
  (stem 1.3, ang -30): 76's mirror (1.6, -35) hit the pearl's r90. With 54's wave_scroll_m it now flows through 1890.
  Check w2-2 clean.
- 42|76 (looked): seaweed | new crescent | eddy across spoke -23 read well; nothing else clearly weak; left.
- 42|59 (done): weak = 59's top row three loops in a row (wave_scroll_a, T_tadpole, endless). T_tadpole -> T_crescent,
  Crescent bow in off 1991 (1.1, 90): an open arc over the ripple (4, -1); mirrored into 54 by the filter (54 -1).
  A sprig from the free 1881 down 59's right strip was tested (Hook, Zigzag, Crescent, Crook, Hairpin; passing ones
  hung as sticks) and not added. Left: four loops round 1879 (42's bubble_s, bubble_m, the wave-scroll pair) - bubbles
  are 42's centre figure; for 59|103 / window 3. Check w2-3 clean (c59 36 -> 35, c54 42 -> 41).
- 76|91 + 86|91 (done together, 86 follows 91 by the mirror): weak = the filled cup, a closed bucket on a ~3-unit
  straight stem from 1885, a second U stacked under the meniscus (w1's open question). -> LOTUS HALO: an arc of 7 on
  an outer orbit round the lotus centre 1499 (r 6.3, ang -78..-30) rising from 1885 over the petals; with 86's mirror
  the flower sits inside two arcs (cell 14's grammar at the combo's scale). 8 -> 7 nodes each (c91 35 -> 34, c86 39 ->
  38). Tried: r 5.6 (0.64 from D_drop); a second concentric arc of 4 at r 7.4 tied radially (read as a ladder, two
  notables side by side at the top, and made both halos 'repeated big drawings'), dropped. Check w2-4 clean.
  Left for 38|76 / 38|91: the twin round Diamonds either side of spoke -11 at 1867 (Z76_1867, Z91_1867).
- 69|86 (looked): the halo mirrored reads well round the lotus; Z86_1894 (the crescent under the trough) reaches to 1.5 of the halo foot but reads as a small wave; removing it emptied the corner, the passing alternatives were 3-node Crooks; left. Twin round Diamonds at 1874 (Z86_1874 | Z69_1874), as at 1867: for the 38 / 22 windows.
- 11|91 (looked): 11's current ends just under 1885 where the halo rises, so the current runs on into the halo across the road (reads as one flow); Z11_1884's crook is a stub but not crowding; nothing clearly weak; left.
- 17|86 (looked): at 1895 the halo's foot meets Z17_1895's crook (it carries the halo's line on across the road, as 11's current does at 1885); koi_a's head 1.6 from the crook's notable, mild; left.
- 11|76 (looked): braid foot at 1882 over the pond at 1883; nothing clearly weak; left.
- 17|69 (done): weak = rings bunched at the 1892 corner (17's gourd, two rings, with Y17_1812's round Diamond just under
  it; 69's pearl; 54's meeting ripples). Y17_1812 Diamond -> Crescent bow in (1.1, 40): with 54's Z54_1811 it makes
  a V across spoke 17 (4, same). Z54_1811 mirrored exactly across the spoke hit the gourd (0.73). Check w2-5 clean.
- 11|59 (looked): Z59_1801's hook and Z11_1801's small ring share the 1801 corner; the ring is compact and the corner
  has no room for an open figure (Z59_1801 mirrored across the spoke: 0.73 from the crescent; only a 3-node Crook
  passed); left.
- 17|54 (looked): the new V at 1811 (Y17_1812 | Z54_1811) reads well; nothing clearly weak; left.
- 11|17 (looked): the lower petals between 11's current and 17's meander, the axis ripple below; Z11_1500's crescent lies over the ripple's left half like a lid with no partner on 17's side, but is not crowding (2.6 to the petal tip); left.
- 26|76 (looked with 38|76): see 26|38 for the 1866 twin rings.
- 38|76 + 38|91 (done): weak = seven small loops in a row along r 53.9 from 1866 to 1869 (26's D_diamond, 38's falling
  drop, lotus bud, the twin round Diamonds Z76_1867 | Z91_1867, Y38_1868, 38's Tadpole). Z76_1867 and Z91_1867 ->
  Crook swept (1.5, -120 / 135, both hand): a pair curling away from spoke -11 at 1867 (4 -> 3 each; open Crescents /
  Hooks found no room). Y38_1868 Diamond -> Crook swept (1.0, 10, hand), a short curl between the lily pad and the
  Tadpole (4 -> 3; the passing Hooks stood as stalks). Checks w2-6, w2-7 clean.
- 22|86 (done): the twin round Diamonds at 1874 (Z86_1874 | Z69_1874) -> the 1867 crook pair mirrored (Crook swept
  1.5, -135 / 120, hand False; 4 -> 3 each); Z22_1876 cusped Tadpole (1.40 from the axis hex's 1447, w1's open
  question) -> Hook bow in (1.1, 0): an open curl between the hex and the fountain, 1.56 to the nearest notable (5 ->
  4). Mirror of 38's Tadpole fix (Tadpole round 1.1, +10, hand) tried first: hit the fountain. Checks w2-8, w2-9 clean;
  no notable pair under 1.5 left in the land.
- 22|69 (looked): 22's curl over the new crook at 1874, 69's eddy from 1873; nothing clearly weak; left.
- 26|38 (done): weak = twin small rings either side of spoke -18 at 1866 (26's D_diamond, 38's falling drop ring).
  D_diamond -> D_hook, Hook bow in (1.1, -40): with the drop's curved tail it opens a V at 1866 (4, same). Check w2-10.
- 32|69 (looked): 32's cusped Tadpole off 1873 stands on a short stalk but has room; 69's eddy below; left.
- 22|32 (looked): wave train + swell, fountain, curl | moon, halo, reflection; nothing clearly weak; left.
- 22|38 (looked, across the axis hex): the two sides balance (38's Tadpole + new crook | 22's new hook + fountain);
  left.
- 26|42 (looked): 42's open patch right of bubble_l under the reflection is small and 1865 has no room (w1); left.
- 42|103 + 59|103 (looked): 103's C_crescent and 59's new T_crescent are two similar arcs off successive spoke
  midpoints (511, 1991), mildly alike; Hook / Hairpin variants of T_crescent from 1991 rendered nearly the same; left.
  Z103_512 (a cusped Tadpole on a stem in 103's corner) mild; left.
- 54|108 (looked): kelps, vortex, drip hook | 54's crescent cup, wave scroll, the T_crescent mirror; left.
- 45|46 (done): weak = 45's empty patch between the Ice start and Z45_1794's crescent (w1's open question). New
  frost_ripple: an arc of 5 round the Ice start's own centre (r 5.0, ang 100..48) rising from 1795, beside the
  crescent: two ripples spreading from the start, answering 46's bloom and crystal without copying them (+5; c45 27 ->
  32). Catalogue pieces off 1795 (Arch, horseshoe, Hairpin, Hook) hugged 1795 or paralleled the crescent as a twin
  hook. First try at ang 110 sat 0.58 from the r 41.7 road; started at 100. 2.0 to the start's nearest notable. w2-11.
- 22|45 (looked): frost ripple up from 1795 | 22's lotus bud down from it; crescent | wave train at 1794; left.
- 32|45 (looked): winged crystal | 32's crook and moon halo; left.
- 45|118 (looked): 118's spoke arch lies along spoke 23 (wall-glued-ish, the axis echo of 115's lens half); bowing it
  out (sag 2.3 / 2.8) hit the channel (0.77 / 0.36) and 45's side has no room for its partner; left.
- 38|46 (done): weak = a row of loops at 1788-1789 (38's dewdrop lens, Z38_1789's round Ring beside it, 46's crystal and
  bloom above). Z38_1789 Ring round -> Ring horseshoe (open) (same 5 nodes, opened towards the road; an Arch bow out
  lay parallel to the road, rejected). Check w2-12.
- 26|46 (done): weak = 46 ring-heavy at 1786 (Z46_1786's round Ring between the eye lens and the bloom, the crystal,
  26's waterwheel below). Z46_1786 -> Hook s-curve (1.1, 30, hand), an S rising towards the frost star; with
  Z38_1786's hook it runs on through 1786 (5 -> 4; a second horseshoe would repeat 38's). Check w2-13.
- 46|115 (looked): the eye lens across spoke -23 | the channel's S; left.
- 26|115 (done): weak = Y115_1783's Ring right over 26's raindrop ring across r 41.7 (look-alike rings stacked, the
  waterwheel beside). Y115_1783 -> Hairpin bow in (1.0, -15, hand), a hook curling towards spoke -36 (5, same; a Hook
  s-curve paralleled the channel's S). Check w2-14.
- 32|118 (done): Z118_1790's Ring (the source Y115_1783 echoed) -> the new hairpin mirrored (Hairpin bow in 1.0, 15),
  so 115 | 118 stay mirrored; it was one of three loops at 1790-1791 with 32's cusped Diamond and the moon. Check
  w2-15.
- 5|45, 5|46, 5|115, 5|118 (looked): the start cell is sparse by design (light touch, w1); 45's icicles and the
  ring off 1782 hang from the shared ring road, 115/118's channels below; nothing clearly weak; left.
- 904|59, 904|54 (looked): the rim's armillary pair hangs from 1800 / 1810 right under 59's / 54's ripple (two
  concentric-arc figures meeting at one node); the rim is not redesigned and the ripple is 59's centre figure; left.
- 904|11, 904|17, 904|103, 904|108 (looked): the rim below these cells holds only the connector roads and the
  keystones; nothing on the inner side clearly weak; left.

## Density recovery and re-look (after an advisor review)
- Re-looked on the final map, full size: 38|76, 38|91 (the r 53.9 row now: lens, crook pair, a short crook, one ring;
  open curls, not sticks in a row), 76|91, 69|86, 11|91, 17|86, 22|86, 26|76, 26|46, 45|46, 54|108, 904|108, 5|46,
  5|118 (the last two had been rendered but not read before). Nothing new clearly weak.
- Lotus halo: tried 8 nodes at 7-degree steps for density; in 76|91 it read as a bead string, back to 7 (8 degrees).
- 59 T_crescent -> Hairpin bow in (1.1, 95, hand): a wave line hooking up at its end, no longer a twin of 103's
  C_crescent off 511 (+1; 54's mirror +1). Crook swept also passed; the Hairpin chosen by eye.
- 108's empty border corner by kelp2: new Z108_515 Hairpin bow out (1.2, -45), a wave curling up (+5; c108 23 ->
  28). Z103_512 mirrored (a cusped Tadpole on a stem) was tried first and read as a stick with a diamond; dropped.
- Z11_1886 (a Crook off the free 1886) tried and not kept: wedged between the current and the lower petal.

## Final water-w2 (check_land.sh water-w2 water.py borders.py chaos.py islands.py, unfiltered)
0 crossings, spacing base warnings only (other link <0.6 4 nodes), 202 pieces all R0-R4 pass; no notable pair under
1.5 across pieces (Z22_1876's 1.40 gone). Mix: 136 pieces, small 73 (54%) medium 44 (32%) big 19 (14%), 859 nodes
(was 134, 71/44/19, 858). Repeated drawings 3, same as the baseline (none mine).
Density (cells but 82, 904): 716 / 3202 = 0.224 (was 715, 0.223); without cell 5: 692 / 2644 = 0.262 (was 691).
Cells: c22 44->43, c38 48->47, c45 27->32, c46 33->32, c69 32->31, c76 32->31, c86 39->37, c91 35->33, c108 23->28;
others same (c54 42, c59 36 net same).
Render: out/water-w2.png.
