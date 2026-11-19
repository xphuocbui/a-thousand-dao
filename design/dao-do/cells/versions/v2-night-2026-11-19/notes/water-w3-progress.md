# Water w3 progress (brief: design/dao-do/cells/review-brief.md, WINDOW SIZE 3: a cell and all its neighbours)
Scratch: out/water_w2_chk.sh <tag> (check + mix + density), out/water_w3_hood.py <map> <cell> <out> [half] [--ids]
[--names] (the cell + every cell sharing >= 2 road nodes, other lands too, the rim for outer cells), out/water_w1_clumps.py
<map>. Border renders use out/water-w3-all-map.json (water + metal + wood + borders + chaos + islands, recompiled before
each border judgement: metal.py / wood.py are being edited in parallel). Backup of the start: out/water-w3-backup0.py.
Rim 904: neighbour only, its large figures not redesigned; hub 82 and the Ice start figure left alone.

Baseline water-w3-0 (= final w2): 0 crossings, base warnings only (other link <0.6 4 nodes), 202 pieces all pass.
Mix: 136 pieces, small 73 (54%) medium 44 (32%) big 19 (14%), 859 nodes; repeated drawings 3 (not mine).
Density (cells but 82, 904): 716 / 3202 = 0.224; without cell 5: 692 / 2644 = 0.262.
All-map (with metal, wood): 0 crossings, base warnings only; no notable pair < 1.5 across pieces touching Water.

## Neighbourhoods (20; cell: neighbours)
5: 45 46 82 115 118 me4 wo1 | 11: 17 59 76 91 904 | 17: 11 54 69 86 904 | 22: 32 38 45 69 86 | 26: 38 42 46 76 115 me27
32: 22 45 69 118 wo31 wo44 | 38: 22 26 46 76 91 | 42: 26 59 76 103 me50 | 45: 5 22 32 46 118 | 46: 5 26 38 45 115
54: 17 69 108 wo44 904 | 59: 11 42 76 103 904 | 69: 17 22 32 54 86 wo44 | 76: 11 26 38 42 59 91 | 86: 17 22 69 91
91: 11 38 76 86 | 103: 42 59 me102 904 (+ border combo 913) | 108: 54 wo44 wo109 904 (+ 914) | 115: 5 26 46 me116
118: 5 32 45 wo112. Corner-only pairs 11|86, 17|91, 22|91, 38|86 judged inside hoods 86 and 91.

## First look (wide renders out/water-w3-h<cell>.png; verdicts to be confirmed on close crops)
- 103/59/42: four loops round 1879 (42's bubble_s, bubble_m, the wave-scroll pair), 59's endless and 103's teardrop and
  moon close by: the most loop-heavy joint. Z103_512 a diamond on a stick by the border.
- 17/69/54 (+wo44): 17's gourd (two rings), 69's pearl, 54's meeting ripples and wave_scroll_m, wood 44's pinwheel: a
  triangle of ring figures round the 1892 corner.
- 118: the spoke arch lies along spoke 23 (a wall-glued half lens without a partner).
- 45/46: the frost ripple (an arc round the Ice start's centre) reads as a one-sided halo of the start.
- 38: lily pad, falling drop, lotus bud, dewdrop, T_tadpole: loop-heavy.
- 26: whirlpool (reads as a closed ring), raindrop ring, waterwheel ring in a triangle.
- 76/91 at 1867, 69/86 at 1874, 38 at 1868: the 3-node crooks are short sticks.
- 91/86/11/17 (lotus, halo, meniscus, trough pairs), 22, 32, 108, 115, 5: no clear weakness at the wide look.

## Windows done
- 103 (+ 42, 59, me102, 913; parent note from Metal's pass: most closed loops round Metal 102 are 103's teardrop, the kite
  on 512, the crescent moon, plus 913's dew drops; open one, like for like in size): Z103_512 cusped Tadpole (a kite on
  a stick by the border) -> Hairpin bow out (1.2, 55, hand): an open U curling up into the corner (5 nodes, small,
  same; Z108_515's family across the axis). Tried by hand: Arch bow out (sat along the border spoke or crossed the
  outer ring), Hairpin bow in / Hook s-curve / Hairpin at 85-100 (crossed or lay along the ring road), Hook bow out (a
  twin of C_crescent). Check water-w3-1 clean; all-map 0 crossings, base warnings, no clumps.
- 59 / 103 / 42 at 1879 (four loops): the wave-scroll pair reshaped six ways in out/water-w3-try{A,B,S1..S8}.py: a
  longer outer arc with one step in (A), a spiral curl (B) both still read as loops; an S of two half circles (S1-S8)
  crossed or lay along the r 64.3 ring, or shrank to a squiggle in the small sector. The scroll stays; the bubbles are
  42's centre figure. Left (see open points).
- 17 / 69 / 54 (+ wo44): weak = the triangle of ring figures round the 1892 corner (17's gourd, two plain rings stacked;
  69's pearl; 54's meeting ripples). Gourd -> TURNING WAVE (piece renamed turning_wave): an outer arc of 7 (r 2.5, 36-
  degree steps) from 1893 round the spoke side and the cell's foot, stepping in to an inner arc of 5 (r 1.35) running
  back round the same centre L(68.1, 13.9); open on the koi side, fills the cell's lower half that the gourd left
  (11 -> 12 nodes, c17 54 -> 55). Tried r 2.0 / 1.0 at four centres (sat high, left the foot empty). Check water-w3-2
  clean; all-map clean, no clumps. Note: the land file lost its CRLF line endings in an edit; restore at the end.
- 118 / 45 / 32 (spoke arch): tried the true wall pair across spoke 23 (pair 118 | 45 'eye_lens23', sag 1.3-1.7,
  mirroring 115 | 46), out/water-w3-try{E1..E9,F1..F4}.py: the 45 half runs into icicle2 and the winged crystal's
  +theta cap; moving icicle2 (1780 at -155..-170, stem 1.1-1.3) and dropping the cap gave one passing variant (E8,
  sag 1.3) in which icicle2's tip notable sits against the lens crown (a clump), and moving icicle2 to 1782 in place
  of the Z45_1782 ring hit icicle1 and the frost ripple. Without the 45 half the 118 strip (about 3 units between
  the spoke and the channel) takes nothing else: left, as the axis echo of 115's lens half.
- 45 / 46 / 5 (frost ripple): close crop on the Ice start: the arc round the start's centre does read as a one-sided
  halo. Re-centred inside 45 (same 5 nodes, out/water-w3-try{R1..R7}.py): R1/R2 notable clumps, R3/R5/R7 too near
  the r 41.7 road; R6 passed but its arc bends in towards the start's spokes and pairs with Z45_1794's crescent into a
  "( )" frame. Left as the w2 design (a ripple spreading from the start, 2.0 from its nearest notable).
- 26 / 38 / 42 / 46 / 76 / 115 / me27: weak = 26's whirlpool reading as a closed ring (a third ring beside the
  raindrop and the waterwheel). Radius now steps 1.85 -> 0.45 over a little under a turn (same 7 nodes): reads as a
  spiral with its eye inside. Tried three step-downs (W1-W3), W1 chosen. Check water-w3-3 clean; all-map clean.
- 76 / 91 at 1867, 69 / 86 at 1874, 38 at 1868 (3-node crooks): close crop: Z91_1867 and Y38_1868 read as small curls;
  Z76_1867 nearly straight. An arc round the crest's own circle (r 4.4 round C1) fits on the 76 / 69 side but on the
  91 / 86 side it meets the meniscus (about 0.55), which would break the mirrored pair; left.
- Corners: 1499 (11|86, 17|91 via the lotus) reads as one flower, four petals; axis x r 53.9 (22|91, 38|86): 38's
  T_tadpole ring | 22's open hook either side of the hex foot, the D_drop pair below: left (no ring-to-hook swaps).
- 11 (close, half 9): Z11_1884's crook is a stub under the top road. An arc on the current's own orbit (r 4.5 round
  the whirlpool, so the whirlpool would sit inside two arcs) was tried (K1-K4): within 12 degrees of the top it is
  under 0.6 from the ring road, and the passing span (-36..-12) hugs the road (a wall-glued arc); left.
- 5 (close, half 11): start cell, sparse by design; crescents and ripple hooks mirrored; left.
- 22, 32, 86, 91, 108 (+ 914), 115 (+ me116), 54 (after the turning wave): nothing clearly weak at window 3; left.
  (Re-read at half 10 on the final all-map: 17, 54, 103, 108, 22, 32, 38, 46, 91, 115, 118.)
- 59 / 54 over the rim armillaries (904): left: the rim is not redesigned and the ripple is 59's / 54's centre figure.
- Sameness of the w2 crescents / crooks / hooks: no further ring-to-hook swaps made; the one new open piece
  (Z103_512, a Hairpin) sits under 103's C_crescent, a mild second open curl there.
- Unresolved: the frost ripple's one-sided halo reading (tested, not fixed); the turning wave reuses cell 5's ripple
  hook construction (outer arc stepping in to an inner arc back), far apart in the land.

## Final water-w3 (check_land.sh water-w3 water.py borders.py chaos.py islands.py, unfiltered)
0 crossings, spacing base warnings only (other link <0.6 4 nodes), 202 pieces all R0-R4 pass.
Mix: 136 pieces, small 73 (54%) medium 44 (32%) big 19 (14%), 860 nodes (was 859); repeated drawings 3 (none mine).
Density (cells but 82, 904): 717 / 3202 = 0.224 (was 716); without cell 5: 693 / 2644 = 0.262 (same).
Cells: c17 54 -> 55; others same. All-map (water + metal + wood + borders + chaos + islands, recompiled last after the
whirlpool change): 0 crossings, base warnings only, no notable pair < 1.5 across pieces touching Water.
Changes: Z103_512 (kite -> open hairpin), 17 gourd -> turning wave, 26 whirlpool -> a true spiral. Line endings of
water.py restored to CRLF. Render: out/water-w3.png.

## For the neighbour
- Metal 102 (by 103): Metal has opened d ring 1761 (horseshoe); d ring 1976 is still a round ring by the border.
- Border combo 913 (borders.py, neither land's file): its two dew drops are closed teardrops right under 103's
  teardrop; one of them opened (a falling drop on a curved tail, like 913 falling_a) would lighten that seam.
- Wood 44 (by 69 / 54): its pinwheel ring and cloud loop sit beside 69's pearl and 54's meeting ripples; with 17's gourd
  gone, an open figure for the pinwheel would end the ring cluster round 1890.
