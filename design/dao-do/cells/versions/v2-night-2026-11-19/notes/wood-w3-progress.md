# Wood window-3 pass (2026-11-19) - progress
Baseline (tag wood-w3-0 = end of w2): density 913 / 3604 = 0.253; mix 158 pieces, small 82 (52%), medium 48 (30%), big 28
(18%); spacing base only; 0 crossings; 233 pieces all pass; 25 notable pairs < 1.5 (closest 1.28). Per cell: 1 17, 12 57,
13 58, 21 54, 25 54, 31 48, 35 56, 39 47, 43 30, 44 37, 52 41, 60 48, 64 39, 67 39, 71 41, 72 44, 88 33, 94 37, 107 32,
109 32, 111 24, 112 24, 905 134. Backup out/wood-w3-bak0.py. Full map with Fire and Water lands (for border windows):
out/wood-w3-full-map.json (audit: base spacing only, 0 crossings).
Scratch: out/wood-w3-step.sh (check + mix + density + close notables), wood-w3-nb.py (neighbourhood render, cell numbers),
wood-w3-try.sh (wood.py + an override snippet -> check + crops), snippets wood-w3-s*.py.
Windows = each cell with every cell sharing >= 2 road nodes (Fire / Water cells on the borders, 905 rim as a neighbour).

## Windows
- 67 (+1, 31, 35, 64, 112; and 64 by mirror): open points "four loops in a row" and "four curls".
  Fork first (it is in both): tried (s1) "umbrella pine", a canopy arc of 7 round a centre on the stem line: crowds the
  seedling, node clash; (s2) "husk", a cradle arc of 6 on an orbit round the seedling's head from 1833: passes, but with its
  long straight stem it reads as a goblet under the seedling (two goblets with 64); (s4) the fork's curls rolled the other
  way: clashes with the seedling. None better than the tendril fork -> fork kept.
  218 pair: tried Hairpin bow out (both hands; still copies the fork's curled arms), Spur pair (sticks), and a hand figure
  "parted seed" (an arc of four on an orbit round a centre on the axis below 218, open end a notable; mirrored, a seed coat
  parted by the axis). Took the parted seed: the row is now ring, parted seed, wheel. Tag wood-w3-1 (density 913, mix same).
- 35 (+21, 31, 67, 72, 94): open points "wreath leaves read as pairs of notables" and "'35 fork' lies in 31".
  Wreath: tried the ends flaring into a leaf (s6a/b: hits lyreL, reads as a flask), ribbons from the lower flanks (s6c/d:
  single straight spikes, the left one by the whorl's notable), leaves swept up along the ring (s6e/f: spikes, clump with
  the whorl), the ring inside two outer-orbit arcs (s6g/h: clash with the lyre, pairs again), an open ring of nine with
  notables at ends + flanks (s6i/j: flank notable 1.30 from the whorl's leaf / R3 fail). Took s6k: an open ring of nine,
  notables at its two ends and its foot (the knot where the stem ties on); no spikes, no pairs; 11 nodes as before.
  '35 fork' row moved to c31 as '31 fork' (same geometry; per-cell counts 35 56 -> 52, 31 48 -> 52: a relabel).
  Tag wood-w3-2: density 913, mix unchanged, close pairs 24.
  1832 (the 35 vine squiggle beside lyreL): tried Crescent bow out, Hook bow in, Diamond, Arch, Tadpole kite, Spur pair at 1832 (sheet out/wood-w3-t7-sheet.png): the strip between the wall 1832-1900 and lyreL is too thin, all hug the wall (link warnings) or clash; the vine left.
- 88 (+13, 21, 71, 94): open point "the 88 strip by 2002 is empty". Holes (wood-dz --holes 88): clear 1.79 at r 59.8 th
  9.3 and 1.55 at r 61.6 th 9.5, the strip between the fiddlehead and the wall 2002-1928. 71's cut stem holds the other side
  of 2002, so no wall pair there. The crook at 1908 (3 nodes, just above the strip) -> "hanging leaf": a stalk of two
  bending off 1908 and a long lens (3.6 x 1.15) hanging down the strip towards the tulip (tried a longer 4.2 x 1.3: road
  spacing warning). Tag wood-w3-3: density 915 (88 33 -> 35), close pairs 23.
  Tulip blade / almond (1.28, also in 94 by mirror): blade angles (152,134) 1.23, (156,136) 1.24, (150,124) 1.37,
  (148,120) 1.49, (148,118) 1.56, (146,116) 1.64 - from 120 down the blade tip sits by the cup's rim notable and reads as a
  fourth prong of the cup; kept (152,128) and accept the pair.
- 21 (+25, 35, 64, 71, 88): looked whether the new open wreath (35), the axis hex and 21's seed ring read as a row of rings
  (crop 35-hex-21): acorn and seed ring flank the hex, the wreath sits further out; left.
- 25 (+21, 39, 64, 71, 111, Fire 29): the Fork at 1838 was a second Y beside the binary tree's bottom twig fork (two Ys
  side by side). Tried Crescent bow out (notable 1.37 from the twig), Hook bow out mirror-handed, Hairpin, Arch, Crescent
  bow in, Diamond cusped (sheet out/wood-w3-t10-sheet.png) -> Hook bow out (hand), an arc facing the tree's trunk, notable
  1.60 from the twig. Fire side (29's big ring, the curl at 311) clear of the ginkgo at 312; nothing for the neighbour.
  Tag wood-w3-4 (density 915).
- 31 (+35, 43, 67, 72, 112, Water 32): crowded top-right corner (pine cone, fir, bamboo3) beside an empty strip along the
  Water border (holes clear 1.67 / 1.66 at r 47.2 th -33.7 / -31.2). bamboo1 grown one joint taller (5 nodes) with a second
  drooping leaf at joint 3 towards the border (tried also 5 without it, and the leaf at joint 4). Water 32's pieces at
  1870 / 1871 stay clear across the border road; nothing for the neighbour. Tag wood-w3-5.
- 39 (+25, 52, 71, 107, Fire 49): notables clump round the big leaf's tip (bigleaf b2 / bough lens 1.39, the bough's twig).
  Tried the bough's twig on the other side (v-22, three angles): clashes with the big leaf's tip (0.48-0.83). Left. The
  cusped Tadpole at 1512 (a small 4-point star) faces Fire 49's big 5-point star across the border road, ~5 apart: mild,
  left. For the neighbour (Fire): none needed.
- 43 (+31, 44, 60, 72, 109): left (open space beside the Wind start figure; gusts and streaks read as currents).
- 44 (+43, Water 32, 54, 69, 108), from Water's note: four round figures meet at 1890 (44's pinwheel ring and cloud,
  Water 69's pearl, 54's ripples). The pinwheel's closed ring of six -> an open vortex (a shrinking orbit 1.3 -> 0.6 from the
  stem's entry to a notable eye; tails as before; same 11 nodes). Tried radii 1.25 -> 0.75 too (b); a is more open. Checked
  on the full map with Fire and Water (base spacing only). Tag wood-w3-6.
- 52 (+13, 39, 71, 107): round leaf, cherry rings, tendril and blossom ring are four round figures. Tried the blossom as a
  crescent leaf (three placements): too thin (own-node spacing), worse. Left.
- 60 (+12, 43, 72, 109): left (leaf V, growth rings, crozier, dandelion read clean).
- 72 (+12, 31, 35, 43, 60, 94) and 71 by mirror: left.
- 109 (+43, 60, Water 108) and 107 by mirror: frond tip / crook2 at 514 (1.33). Tried crook2 at 130 / 150 / 90 / 70 (both
  bows): 130 clears 109 but in the mirror 107 puts the crook's notable 1.13 from the rim leaf; by eye the gain in 109 is
  tiny. Left. Water 108's curls and Wood's eddies meet across the border road as currents; nothing for the neighbour.
- 111 (+1, 25, 64, Fire 119), 112 (+1, 31, 67, Water 118), 12 (rim: lanterns,
  gourd vine leaves): looked, left. (107, 71, 94, 1, 13, 64: see the review follow-ups.)
FINAL (tag wood-w3): density 918 / 3604 = 0.255 (from 913); per cell all >= baseline (31 48 -> 55, 35 56 -> 52 is the '35
fork' relabel (-4; 52 = 56 - 4), 88 33 -> 35, rest equal); mix 158 pieces, small 82 (52%), medium 47 (30%), big 29 (18%)
(from 82/48/28: bamboo1 grew from medium to big); spacing base only; 0 crossings; 233 pieces all pass; full map with Fire and
Water: base spacing only, 0 crossings; notable pairs under 1.5: 23 (from 25; closest 1.28, tulip blade / almond, accepted).
Render out/wood-w3.png. Backups out/wood-w3-bak0..7.py (bak7 = final). Note: c913 (borders.py) went 16 -> 14 during the
pass: not this land's edit (another session).
## Review follow-ups (final map, out/wood-w3-full-map.json)
- 107, 71, 94, 1, 13, 64 rendered and looked at on the final full map (out/wood-w3-f107-71.png, f94-1, f13-64): 107 beside
  Fire 101's star across 1512-517 (no notable pair across a Wood border under 2.0 except 25 ring / Fire 29 arch 1.76); 71
  with 21 / 25 / 39 (hanging leaf across 2002 from the cut stem); 94 under the new wreath; 1 sparse (B4); 13 beside the new
  hanging leaf; 64's parted seed twin. All left.
- Border combos (render_border.py, out/wood-w3-borders-wood.png): 914 reeds (252) and 915 torch (324) sit at r 79-90 on the
  border roads; Wood's gust_rim (1843) and leaf_rim (1853) by the outer ring stay clear of them; left.
- 44 vortex re-cropped on the full map centred on 1890 (out/wood-w3-z1890.png): the vortex now reads open, the seam as
  currents beside Water 69 / 54. bamboo1's new leaf on the full map: ~1.7 from the border road, Water 32's pieces clear
  (out/wood-w3-zAB.png, right). 25 hook re-rendered (zAB left): an arc, apart from the tree's twig fork.
- Ring check (out/wood-w3-zrings.png, r 43 th -4 half 13): parted seed over the hex reads open; the new open wreath (35) and
  21's seed ring now read as a look-alike pair across the hex (open ring vs closed ring with a shoot). Kept, listed unsure
  (the eared wreath is in out/wood-w3-bak1.py).
## Open points from w2: status
- Four loops in a row (64-67): resolved (218 tadpoles -> parted seed; row is ring, parted seed, wheel).
- Four curls (35-67): unresolved; fork kept (umbrella, husk, reversed curls tried), 35 vine kept (6 families tried).
- Wreath pairs of notables (35): resolved geometrically (open ring of nine, notables at ends and knot); the leaves are gone.
- '35 fork' in 31: fixed (row moved to c31 as '31 fork').
- 88 strip by 2002: filled (hanging leaf from 1908).
- 25 notable pairs < 1.5: now 23; both drops are side effects (wreath w315 / 35 vine; fiddlehead / crook2 at 1908); the
  closest (tulip blade / almond 1.28, x2 by mirror) accepted after six blade angles.
## For the neighbour
- Fire, Water: none. Wood's cells sit clear of 914 / 915 and of the border cells' notables.
- Noted: c913 (borders.py) went 16 -> 14 nodes during this pass; not this land's edit.
## Unsure
- The open wreath (35) vs 21's seed ring across the hex (look-alike pair), and the wreath without leaves.
- The hanging leaf in 88 runs about 1 unit beside the wall 1908-2002 (a leaf, but close to the wall).
- 52's four round figures (round leaf, cherries, tendril, blossom) and 39's notable clump round the big leaf's tip: left.
