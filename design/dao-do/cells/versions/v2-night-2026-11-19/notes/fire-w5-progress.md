# Fire w5 progress (window 5: the whole land as one picture, with the Earth and Wood halves, borders 911/915, hub, rim 901 and the Light island; brief design/dao-do/cells/review-brief.md)

Backup before the pass: out/fire-w5-bak.py (the ONLY undo).
Baseline (tag fire-w5a = fire-w4 final, unchanged): fire cells 899 nodes / 3445 = 0.261; mix.py `fire pieces 177 small 107
(60%) medium 43 (24%) big 27 (15%) nodes 1057`; repeats 17; notable pairs < 1.5: 4 (2 in locked 15, 28/29 1.45). 0 crossings,
spacing = base 4 only, 231 pieces pass; x-map (earth.py, wood.py) base 4 only.
Renders: out/fire-w5a-W.png (the whole window, box 0 58 70), fire-w5a-Z.png (land close, box 0 52 42), fire-w5a-hlD.png
(Diamond-family pieces in red). Scratch: fire-w5-loop.sh (= w4 loop, diff vs fire-w5a), fire-w5-hl.py (highlight render).

## Land-scale read (fire-w5a)
- Density: even across Fire (cells 0.26-0.33, cell 3 empty by design). Earth's border cells sparser (40 0.213, 117 0.222),
  Wood's denser (39 0.323, 107 0.331, 111 0.332): not Fire's to fix.
- Shape family: the small Diamond is stamped over the land: 8 fill Diamonds (62/63 1549/1556, 18 1590, 37 1583, 28/29
  1516/1511, 101 1592, 56 1606 = locked 14's H wall mirror) beside the 6 lily petals (Diamond family, the named flame
  lily combo) and locked 14/15's H Diamonds: tiny rhombi evenly sprinkled, the 28/29 ones on the Earth/Wood seams next
  to Earth's polygons.
- Symmetry: about half mirrored (w4 tally), reads well round the axis.
- Seams: 28/24 spiral twin gone (Earth 24 now a switchback).

| change | weak | what |
|---|---|---|
| 1 (62/63, inner band by the halo/corona) | the round fill Diamonds 1549/1556, two of the eight stamped rhombi, in the inner band's sun pair | `w5_hairpin_1549` / `_1556` (land twins, mirror_pieces): Hairpin 'tight turn' (stem 1.0, ang -40, hand True) curling up and away from the corona, a flame lick running on through the road node into 37's/18's hook below. Named at 1549: Hairpin tight turn hand False / True, Hook s-curve, Tadpole curled stalk, Zigzag wave; only the hand-True Hairpin passed (notable 1.94 from the corona tip). |
| 2 (28/29, the Earth/Wood seams, 1516/1511) | 28's cusped Diamond sits right under Earth 24's cusped four-point star across the 36-deg spoke (a look-alike on the seam; re-checked on today's earth.py, fire-w5-seamE.png) | `w5_diamond_1511` / `_1516` (twins): the same Diamond, same stem and angle, in its 'round' style, a small round ember bead instead of a second cusped star. No other family fits the pocket: 36 named rows (24 as twins, 12 for 28 alone: Zigzag wave, Hairpin tight turn / bow out, Hook s-curve / bow in, Spur pair, Tadpole curled stalk / kite, several angles, stems 0.8-1.0) all failed spacing or notables < 1.5. Then named Diamond round and lop-sided: both passed, round chosen by eye (fire-w5t-29Dround-E.png vs -29Dlop-E.png). |
| 18/37 (axis pockets, 1590/1583) | the twin Diamonds either side of the axis hex stem | left: Hairpin tight turn ang -30 passed spacing but its notable sits 1.38 from the axis hex (cl 11); the passing Tadpole curled stalk is a loop again; in these 2.5-unit pockets the compact Diamond pair reads clean |
| 101 (1592) | the isolated Diamond under 49's whorl | left: five named rows (Hook s-curve / bow out, Zigzag wave x2, Spur pair), none pass |

FINAL (tag fire-w5, render out/fire-w5.png = render_box 0 56 80 2400 on fire-w5-x-map.json, with Earth, Wood, borders, hub,
rim, Light island; close view fire-w5-Z.png): fire cells 901 nodes / 3445 = 0.262 (baseline 899, 0.261). Changed vs
fire-w5a: c62 42->43, c63 39->40, c28 56->56, c29 57->57 (c913 16->14 is borders.py, edited by another session at 04:34, not Fire's). mix.py
`fire pieces 177 small 107 (60%) medium 43 (24%) big 27 (15%) nodes 1059` (baseline the same counts, 1057); without island cell 931's 20 small: 157 = 87/43/27 = 55/27/17 %. Repeats 17
(unchanged). 0 crossings, spacing = base 4 only (also on the x-map with earth.py, wood.py), all 231 pieces R0-R4, nothing
outside its cell; notable pairs < 1.5: 4 (unchanged). Fill Diamonds 8 -> 6 (and 28/29's now round, not cusped). Locked 14/15/93, hub, rim untouched.

For the neighbour:
- Earth 24: its four-point star stands over Fire 28's small Diamond at 1516 across the 36-deg spoke; Fire's is now
  round (Fire could not move it: the pocket takes nothing else). The 28/24 spiral twin is gone (Earth's switchback),
  confirmed on the fire-w5 x-map (earth.py as of 04:52).
- Densities on the fire-w5 x-map: Earth's Fire-side cells are sparser (40 0.213, 117 0.222, 36 0.239, 104 0.248) than
  Fire's (0.26-0.33) and Wood's (0.28-0.33).
