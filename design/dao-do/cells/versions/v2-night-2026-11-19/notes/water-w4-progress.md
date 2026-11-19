# Water w4 progress (brief: design/dao-do/cells/review-brief.md, WINDOW SIZE 4: a cell, its neighbours and theirs)
Scratch: out/water_w2_chk.sh <tag> (check + mix + density), out/water_w4_region.py <map> <c1,c2,..> <out> [half]
[--ids] [--names] [--rim] (the listed cells + every cell sharing a wall with any of them, other lands included, axis
down), out/water_w1_clumps.py <map>. Border renders on out/water-w4-all-map.json (water + metal + wood + borders +
chaos + islands, recompiled before border judgements). Backup of the start: out/water-w4-backup0.py.
Hub 82, the Ice start figure and the rim 904's large figures left alone. Short pass (at most about five changes).

Baseline water-w4-0 (= final w3): 0 crossings, base warnings only (other link <0.6 4 nodes), 202 pieces all pass.
Mix: 136 pieces, small 73 (54%) medium 44 (32%) big 19 (14%), 860 nodes; repeated drawings 3 (not mine).
Density (cells but 82, 904): 717 / 3202 = 0.224; without cell 5: 693 / 2644 = 0.262.

## Regions (six, overlapping; renders out/water-w4-r-<region>.png)
- inner: 5 115 46 45 118 (+ 82, 22 26 32 38, me4 me116 wo1 wo112)
- midL: 26 38 46 76 91 (+ 5 11 22 42 45 59 86 115 me27) | midR: 32 22 45 69 86 (+ 5 17 38 46 54 91 118 wo31 wo44)
- outL: 42 76 59 103 11 (+ 17 26 38 91 me50 me102) | outR: 69 54 108 17 86 (+ 11 22 32 91 wo44 wo109)
- rim: 11 17 59 54 103 108 + 904 (+ 42 69 76 86 91 me102 wo44 wo109)

## First look (verdict per region, composition only)
- inner: 5 and 115 | 118 mirrored; 46 | 45 balance except at the Ice start: 45 has the frost ripple arc on its side,
  46's mirror slot (above 1788, between the ice crystal's icicle and 38's dewdrop) is empty -> the one-sided halo.
- midL vs midR: 38 is a run of closed loops (dewdrop, lily pad, falling drop, lotus bud, T_tadpole) while 22 across
  the axis hex is open figures (fountain dome, wave train, curl, crescent; only its lotus bud is closed). 26 | 32
  ring-heavier on the 26 side but handled in w3 (whirlpool now a spiral). Weakest: 38.
- outL: the loops round 1879 (42's bubble_s / bubble_m, the wave-scroll pair) with 103's teardrop near: known; the
  scroll pair is not touched again (14 variants in w3, mirrored into 54).
- outR: 69 / 54 / wo44 ring corner eased in w3 (turning wave); 108, 86 fine. Nothing clearly weak.
- rim: lotus four petals on the axis, 11's whirlpool + current | 17's koi + turning wave, the armillaries below 59 | 54;
  balanced. Nothing clearly weak inside Water.
- size gradient: inner band small rings (crystals r 1.0, icicles), middle 1-2.3, outer spirals and halo 2.5-6.3, rim
  armillaries: present, mild. No change.

## Changes
1. inner (45 / 46, the Ice start): the frost ripple mirrored across the axis into 46 (frost_ripple_m, rising from
   1788, via mirror_pieces), so the start sits between two arcs on its own circle (cell 14's grammar). Its slot held the
   ice crystal's icicle: tried the full mirror with the icicle trimmed to one node (T1: d1 0.84 from the ripple, crystal
   r2 0.41) or removed (T2: r2 0.41), both ripples cut to 4 nodes (T3-T6: crystal notables 0.98-1.19 from the ripple
   end); chosen: icicle dropped (8 -> 6) and the ring moved up beside 1776 to L(35.0, -9.2) (was L(35.75, -7.8)),
   notables r2, r3, answering 45's ring off 1782 (C1-C3, C6 hit the frost star's arm n0 at 0.53-0.92; C4 / C5 passed,
   C5 by eye with notables r2 r3 to keep 1.5 from n0 and f4). c46 32 -> 35. Judged on the inner and whole-land renders:
   it reads as one balanced figure; the lotus halo below is the same grammar at a larger scale (see unsure).
2. midL vs midR (38 | 22 across the axis hex): tried 38's round Tadpole off 1869 -> 22's Z22_1876 hook mirrored (H1,
   passed). REVERTED after a close look (out/water-w4-f-3822.png): the new hook and Y38_1868's crook stood side by side
   as two short stalks leaning the same way, each with a notable tip (w2 had rejected hooks at 1868 as stalks), and it
   overrode w3's "no ring-to-hook swaps" at the hex foot. T_tadpole kept.
3. 38: the falling drop's ring opened (r240 removed): the tail rises and curls back over itself, a breaking crest
   (8 -> 7). Tried D1 (curl over, open towards the tail) and D2 (curl the other way, open towards the lotus bud); D1
   by eye (follows the tail's line). 38 now: lily pad, dewdrop, lotus bud, T_tadpole closed (was five with the drop);
   crest, crook, horseshoe open. c38 47 -> 46.
- outL (1879): left. Every loop there is a centre figure (42's bubbles, 103's teardrop, 59's endless current) or the
  wave-scroll pair (14 variants in w3, mirrored into 54); no named candidate worth trying.
- outR, rim, size gradient: left (see first look).

## Final water-w4 (check_land.sh water-w4 water.py borders.py chaos.py islands.py, run directly)
0 crossings, spacing base warnings only (other link <0.6 4 nodes), 203 pieces all R0-R4 pass.
Mix: 137 pieces, small 74 (54%) medium 44 (32%) big 19 (14%), 862 nodes (was 136, 73/44/19, 860); repeated drawings 3
(none mine). Density (cells but 82, 904): 719 / 3202 = 0.225 (was 717, 0.224); without cell 5: 695 / 2644 = 0.263 (was
0.262). Cells: c38 47 -> 46 (0.275 -> 0.269), c46 32 -> 35 (0.239 -> 0.262); others same.
All-map (water + metal + wood + borders + chaos + islands, recompiled last): 0 crossings, base warnings only, 503 pieces
pass, no notable pair < 1.5 across pieces touching Water. Diff against out/water-w4-backup0.py: only changes 1 and 3.
water.py CRLF kept. Render: out/water-w4.png (from the all-map, Metal and Wood drawn); regions after:
out/water-w4-f-{inner,midL,midR}.png.

## Unsure
- The Ice start now sits in a frame of two arcs (its own nodes untouched; the arcs are pieces of 45 and 46), and the
  lotus halo (two arcs round 1499) is the same grammar again further down the axis, at a larger scale. It reads as a
  spine to me; the user may find it repetitive or too decorated round a start figure.
- 46's ice crystal is now a bare hexagonal ring (no icicle) with two adjacent notables, set opposite 45's ring off 1782:
  a near-twin of that ring (6 vs 5 nodes), and plain rings are on the brief's bad list.
- 38 still has four closed loops; only one opened this pass.

## For the neighbour
- Border combo 913: its dew drop is already open (borders.py, 2026-11-19 night); nothing further.
- Wood 44 pinwheel note from w3 still stands.
