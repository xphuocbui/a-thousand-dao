# Metal review pass, window 2 (review-brief.md), progress

Backup of the land file before the pass: out/metal-w2-bak.py; baseline map out/metal-w2-before-map.json, render
out/metal-w2-before.png. Scratch: out/metal-w2-pair.py (axis-down close-up of two cells, other cells dimmed, --names
--ids --px=), out/metal-w2-check.sh (check + notable report + mix), pair list out/metal-w2-pairs.txt, baseline pair
renders out/metal-w2-p<a>-<b>.png (stale after edits: re-render when a pair is reached).

Baseline: crossings 0, spacing only the base map's 4 "other link" nodes, rules 223 pieces all pass.
Mix (metal): 155 pieces, small 79 (51%) medium 47 (30%) big 29 (19%), 996 nodes. Floor: losing 2 smalls -> 49.7%.
Density outside hub and rim: 824 nodes. Lowest other-piece notable gap 1.23 (58 tadpole-saw, 90/95 blade-crook).

Pairs (44 wall pairs + 6 rim pairs), worked roughly inner to outer, mirror pairs together.

## Windows
- 4|61, 4|68: looked. Cell 4 sparse by design; the coin W1 on the -theta side unmatched (its mirror place is under 68's
  bell); the S of two crescents through 1700 reads as one stroke. Left at first; superseded below: a bead on 1702.
- 4|113, 4|116: looked. The inner corners are busy next to the empty start cell (B4: the start cell stays sparse).
  Left for now (fork in 113/116 is a stick in the corner's middle; revisit if density allows).
- 61|113, 68|116: looked; nothing clearly weak across the walls. Left.
- 61|68: spades mirrored on 129 (good); the two bells near-mirrors (61 hand bell 1694, 68 bell 1701). Left (68's bell
  is its centre figure; the pair reads as an echo).
- 20|68 + 20|34 (one change): cell 20's crook 1716 continued 68's crook through 1716 as one zigzag stick across the wall,
  and stood beside crescent 1491 as a second curl -> deleted. 20's lone crook on 1492 -> a bowl (Arch bow out) from
  1750 under the gong, answering 34's bowl on 1743 across the axis hex. 53 -> 52.
- 20|27, 20|95: looked (knives W3, gong over the moon on 1749 read well). Left.
- 30|113, 27|116: looked; the inner corners' notable clump (116: rings, hairpin, fork, crescent, plate). Tried the
  116 fork as a round diamond, curled tadpole, closed or bowed fork, round tadpole, bowed crook: two fail spacing, the
  rest no clearer. Left.
- 30|61: cell 61's hand bell (1694) a few units from 30's hung bell across the wall (and 68's bell: four bells in four
  neighbouring cells). Changed: hand bell -> an iron fan (thiết phiến) drawn fresh (handle of two, three ribs to a rim of
  five round the pivot, 20-degree steps, rim ends notable), ang 165 (175 hit the wall spoke's 1963 link). 7 -> 7.
  Piece key renamed CELLS[61]['iron fan'] (renders said "c61 bell").
- 27|68: 27's bell (mirror of 30's) and 68's bell (centre) across the spoke, three pieces between them and different
  sizes. Left.
- 34|61: the diamond on 1709 over 34's closed ring on 1709 reads as a pendant across the wall. Left.
- 30|34: W2 leaf blade on the spoke, 34's rounder bow/ring/whip vs 30's stick corner (compass, crook 253, spur pair).
  Fixed through 30|41 below.
- 30|41: 30's spur pair on 1521 and 41's crook on 1521 left one node as two sticks across the wall beside the compass.
  Changed: spur pair -> a round bead (Diamond round, ang 49; tried horseshoe/round ring: fail spacing on the spoke;
  round/curled tadpole pass but 41 has a tadpole on 1522). 5 -> 4. The compass stays as the corner's one straight
  figure (its sticks read on purpose once its neighbours are round).
- 41|100: 41's crown read as a twig: five notables on a long band, crowded by crescent 1752 and hairpin 1754. Changed:
  redrawn as a three-pointed crown (band of five 0.9 apart, side points from the band ends leaning out, the middle
  tallest; notables only the three points). 9 -> 9 nodes, notables 5 -> 3. Moving it nearer 1753 fails spacing.
- 41|58: crown up and the round tadpole down from 1753 read as one sceptre through the node. Left.
- 41|100 + 58|100: cell 100's side of the ring wall was three sticks (hairpin 1522, crooks 1751 and 1753; the 1753 crook
  lying along the wall, two crooks alike). Changed: both crooks -> one round ring from 1752 (ang 165, hand) into the
  cell's empty top middle (tried round/cusped/horseshoe ring, round tadpole, bowed spur pair; one fails spacing, the
  others sit 1.2-1.4 from the whip). Echoes 102's rings across the axis. 27 -> 26; smalls -1.
- 30|77, 34|77, 34|90, 41|77: looked (stacked pairs through 1742 trident/moon and 1743 bowl/sabre read well; 77's
  quiet middle). Left.
- 27|50 (open question 2): the leaf spearheads in 27 (273) and 50 (1762) are the same drawing, eight units apart in
  this window: they read as a repeat. Changed: 50's spear -> a small round bead on 1762 first, then (see 50|102) a
  two-pronged fork with bowed prongs (Fork bow out, ang 10, hand). 27's spear kept.
- 50|57: 57's straight hairpin on 1763 next to 50's hairpin on 1764, one each side of the wall (two of the land's
  four hairpins). Changed: 58's round tadpole on 1753 mirrored into 57 on 1763 (57 already mirrors 58). 50 40 -> 37,
  57 35 -> 35.
- 50|73: 50's crescent 1746 and hairpin 1764 both run along the spoke wall; re-aimed the crescent (165-200, both
  hands): all fail spacing on the spoke's wall-node links or against 73's wheel. Left (w1's placement).
- 50|102: the bead first put on 1762 sat across the wall from 102's straight ring 1761 (and near 57's new tadpole): a
  row of loops. Changed to a two-pronged fork with bowed prongs (Fork bow out, ang 10, hand). 102's crook 1763 lies
  along the wall (a stick) but the cell is reviewed and dense; left.
- 57|102: 57's sawblade and 102's round ring 1976 kiss at 1976 (rings in a row). Tried 102's ring as an open
  horseshoe (4 angles): no clearer, notables 1.3-1.45 from the ji/hook. Left.
- 27|73, 20|73, 73|95, 77|90, 58|77, 9|77 (ding over chain through 1757): looked; stacked pairs read well. Left.
- 9|77, 9|58, 9|10 (open question 3): the chevrons read as two sticks on 3.8-unit poles beside the round chain, rack
  and bowl. Changed: redrawn on circles (each arm one arc bowed out through apex, middle node and notable tip, sag
  0.1), the pole broken by a node one unit behind the apex, apexes 0.3 further out. 10 -> 12 nodes.
- 10|73, 10|57, 10|95, 9|90, 9|10: looked (mirrored 9|10 composition, stacked hairpin/ding on 1767). Left. The band
  along the 10|57 spoke is a little empty; every small piece tried there (1731, 1766 both sides) fails spacing.
- Mix fell to 76/153 (49.7%) once the chevrons became 7-node mediums and the land was 4 nodes short. Tried smalls on
  41 1739, 77 1756, 10 1731, 57 1766, 10 1766, 68 1702: all fail spacing. Changed: 4|61 against 4|68: a small round bead
  on a stalk (Tadpole round, ang 5) rises from 1702 into the start cell, answering the coin W1 on the -theta side
  (the coin's own mirror place is under 68's bell). +5; the start cell stays sparse (41 nodes / 558).
- 903|100: the rim's straight crescent on 1717 ran on from 100's ji as one stick across the ring. Changed: a small round
  ring at the node (Diamond round, ang 180), read as the ji's pommel (tried bowed/inward crescents: twins of 100's
  crescent on 509; round tadpole: a stalk continuing the stick; arch: a fifth bowl). Rim large figures untouched.
- 903|58, 903|9, 903|10, 903|57, 903|102: looked; the rim's large figures meet the inner cells cleanly. Left.

## Done (window 2, 50 pairs)
Final: crossings 0, spacing only the base map's 4 "other link" nodes, rules 222 pieces all pass.
Mix (metal): 154 pieces, small 77 (50%) medium 48 (31%) big 29 (19%), 997 nodes (was 155, 79/47/29, 996).
Density outside hub and rim: 825 nodes / 3336.4 = 0.247 (was 824).
Lowest other-piece notable gap still 1.23 (58 tadpole 1719 - saw, 90/95 blade - crook); 41's crown 5 -> 3 notables.
Render: out/metal-w2.png. After-looks: full-res (1000 px) clean renders of 58|100, 20|95, 9|58, 61|113, 4|68, 50|73
(all hold up; 58|100 has 100's new ring on 1752 four units from 58's tadpole on 1753, a mild loop echo, kept);
20|34, 30|41, 41|58, 41|77, 41|100, 50|57, 50|102, 903|100, 9|77 viewed at 900 px or as crops after their edits;
20|68, 61|68, 27|50, 57|73, 4|61 only on a 600 px contact sheet.
Without the cell-4 bead (placed after six other spots failed, to recover count and mix): 820 nodes, small 76/153
(49.7%). With it: 825, 77/154 (50.0%): no headroom left for pass 3.
