# Fire consolidation progress (2026-11-18)

Baseline (fire-c0): `fire pieces 144 small 127 (88%) medium 11 (8%) big 6 (4%) nodes 649 mean 4.5`
Locked: cells 14, 93 (own files), 15 (mirror of 14), lily petals, keystones.
Scratch: out/fire-look.sh (check+mix), out/fire-rcell.py (close-up render; render_cell.py uses only ps[0] for holed cells).
New helpers in fire.py: figure(), along(), lens(); flame() takes a side tongue.

| cell | before | after | what |
|---|---|---|---|
| 18 | 33 | 35 | sparks wheel+crook+crescent+spur -> "hearth sun" (big 11, from 1555) + "falling ember" lens (med 6, from 1553); flame_b gets a side tongue (med 7); flame_c tongue tried and reverted (balance) |
| 37 | 33 | 35 | mirror of 18's flames and sun (twin); its sparks -> "flame drop" teardrop (med 6, from 1546) |
| 28 | 34 | 36 | B crook+E crook+C diamond -> "flame wisp" S (med 7, from 235); D spur -> "spark pinwheel" (med 8, from 1552); A hairpin -> "sunrise" half-sun crown (med 7, round 1586) |
| 29 | 32 | 34 | mirror of 28 (wisp, sunrise twins); pinwheel replaced by "flame crescent" (med 6, from 1545) |
| 70 | 30 | 33 | A hook + C crook -> "twin embers" (med 7, from 1938); heart hairpins redrawn as curls heart_L (med 6) / heart_R (med 7); core, lily, B diamond kept |
| 74 | 30 | 33 | mirror of 70 (B crescent variant kept) |
| 63 | 21 | 22 | A tadpole + C crook + E crook -> "sun halo" nested arcs round axis node 67 (big 9; combo with 62's mirror half); D crook -> "ember" Reuleaux triangle (med 6, from 1553) |
| 62 | 20 | 19 | mirror of 63 (halo closes round 67); a Crook from 1548 instead of the triangle |
| 47 | 24 | 25 | B crook + C crook -> "looping flame" (med 8, from 1604); A ring + D crook -> "phoenix eye" ring+pupil (med 7, from 1602) |
| 49 | 23 | 23 | A diamond + B crook + C crook -> "torch" (big 10, from 1594); D crook kept |
| 53 | 22 | 23 | A spur + B diamond -> "flame fleur" (med 8, from 1559); split ring half 5 -> 7 nodes (med) |
| 101 | 18 | 17 | A ring + B fork + C hook -> "spark star" five-point outline (big 10, from 517); split ring half 7 |
| 56 | 27 | 29 | A tadpole + B crook -> "flame crown" three peaks (med 7, from 1944); C crook kept, D crook added (texture) |
| 105 | 15 | 15 | unchanged (trident + 2 crooks; no room for a medium) |
| 92 | 22 | 25 | B crook + C hook -> "twin flame" (med 7, from 1598); A diamond -> "candle" stem + lens (med 7, from 1481) |
| 901 | 42 | 42 | G crook + B spur -> "fire wheel" (big 11, from 1561); E fork + F wheel -> "flame tree" (big 10, from 1569); C hook + D hook -> barbs on plume_L/R (med 7 each); A tadpole and keystones kept |
| 3 | 20 | 22 | hairpins -> two mirrored "flame wings" (med 6 each); spurs kept |
| 83 | 17 | 16 | wheel + both hooks -> "rising phoenix" (big 12, from 29); diamond kept |
| 119 | 12 | 13 | fork + crook -> "flicker" zigzag on two circles (med 8, from 1544); tadpole kept |
| 120 | 12 | 13 | hook + crook -> "comet" ring head + two streaks (med 8, from 1514); wheel kept |

Final (fire-final): `fire pieces 114 small 57 (50%) medium 42 (37%) big 15 (13%) nodes 672 mean 5.9`; 0 crossings, no new spacing warnings, all R0-R4 pass. Render out/fire-consolidated.png.
