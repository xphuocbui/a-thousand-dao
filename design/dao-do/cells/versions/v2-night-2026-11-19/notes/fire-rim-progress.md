# Fire rim progress (cell 901, brief design/dao-do/cells/rim-brief.md, 2026-11-18 night)

Baseline fire-rim0: c901 = 42 nodes, 7 pieces (plume_L/R 7+7 off 500, keystone_L/R 1+1 off 1945/1946, wheel 11 off
1561, tree 10 off 1569, A_tadpole 5 off 1558); checks clean (base 4 only), 225 pieces all pass.
Hang points: ring r 74.3 nodes 1557 (th -32) .. 1567 (th 32), every 2.5-4 deg; axis 500 (r 79.05), 380 (r 84);
550 (r 89) / 549 (r 94) are Light's road (do not hang). Keystone stubs 1945/1946 (r 79.2, th -+12).
Neighbours: border combos 911/915 at th +-33.4..38.6, r 80-91; Light rays nearest at r 96, th +-3.
Plan: remove plumes, wheel, tree, tadpole; keep keystones. New: đỉnh on the axis (two halves 500<->380, belly
semicircle round 500 with 380 its bottom, lip, ears, side legs; road 380-550 = middle leg), then an abstract pair.

| step | what | c901 nodes | checks |
|---|---|---|---|
| rim1 | removed plume_L/R, wheel, tree, A_tadpole (35 nodes); added ding_R/L (14 each) | 30 | clean |
| rim2 | ding: band (inner arc round 500 at 3.3 from l2), legs 1-interior lens | 32 | clean |
| rim3-5 | trefoil_R: three rings r 3.3 round centres 2.4 out, crossings shared, centre notable on 3 spokes, side mids; tried 2-up/1-down at th 24 off 1569 (hugged the ring), then 1-up at th 20 off 1570; trefoil_L = mirror | 86 | clean |
| rim6 | trefoil centre F(81.6, 22), top lobe aimed at 1569 (tilt), so it sits mid-way keystone..border; band cut to 2 nodes | 86 | clean |
Hull density: ding 28 / 93 = 0.30, trefoil 28 / 80.5 = 0.35 (land 0.257); band r 74.3-86.7 x 66 deg = 1150 u2 -> 0.075.
| rim8 | FINAL: trefoil notables 6 -> 8 (L1_-66.4, L2_66.4, lower lobes' upper shoulders); left trefoil hangs off 1559 (mirror of 1569; comment fixed) | 86 | clean (base 4 only, 0 crossings, 224 pieces pass) |
Final render: design/dao-do/cells/out/fire-rim.png (centre (0, 82), half 42). Backup of the pre-pass file: out/fire-rim-bak.py.
