# Metal rim (cell 903) large figures -- progress (rim-brief.md)

Baseline (tag metal-rim0): rim 903 = 53 nodes; crossings 0; spacing only base 4 "other link"; rules all pass.
Keep: great blade (1275), guard L/R (1274), diamond L/R (502) = the great sword; keystone -12 / +12.
Remove candidates: hook 1725, crook 1735, crescent 1717, kite 1728, gong L 1721, gong R 1731 (gong = reused helper).
Viewer: out/metal_rimview.py (land frame, outward down, -theta left). Grid every 2 r, 5 deg.
Space: Darkness island road 592-597 at th +27..33 r 90-106; border road 416-1410-1411 at th -35 r 84-94.

## Plan / done
- Removed: hook 1725, crook 1735, gong L 1721, gong R 1731 (crescent 1717 and kite 1728 kept near the seams).
- R1 weiqi board, th -22, pass-through 1720/1719, 25 nodes / 7 stones. check: clean.
- R2 linked rings, th +20, entry 1730, 29 nodes / 7 notables. First try failed R3 (centre notable on spoke to entry):
  centre made small, notables moved to r2/r4/r6. check: clean.
- R3 trefoil R (th +7.6, entry 1734) + mirror L (1724), 16 nodes / 4 notables each. check: clean.
- Final (tag metal-rim): c903 53 -> 116; crossings 0; spacing base 4 only; rules 202 all pass. Render out/metal-rim.png
  (file frame) and out/metal-rim-landframe.png (land frame).
- Coordinator 2026-11-18: Fire 901 also drew a trefoil, so R3 trefoil R/L replaced by turned pentagons R/L (1734 /
  1724, 15 nodes / 4 notables each: outer pentagon with edge-middle nodes, inner pentagon turned 36 deg strutted out
  to them, all straight). A first try with three nested pentagons and zigzag bands read as a dense web: dropped.
  Check: clean, 202 pieces pass; c903 116 -> 114. Renders redone.
