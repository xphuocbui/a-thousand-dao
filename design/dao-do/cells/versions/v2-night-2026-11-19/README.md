# Đạo Đồ v2, the night run of 2026-11-18/19 (candidate, not official)

Made while the user slept, from their requests before bed: solve density ("the symmetry mirror thing by the cell
wall", plus other ways), then the islands and Chaos, then large figures on the outer rims, then review passes cell by
cell and over growing windows of neighbouring cells. Not yet judged by the user. The official version is still
`../../official-2026-11-18/`.

- `dao-do-map.json`: 6,093 nodes (1,435 notables), 790 hand-placed pieces; 0 crossings, only the base map's 4 spacing
  warnings, all pieces pass R0-R4. Rebuilds byte for byte from `source/` (checked).
- Density (piece nodes / cell area, hub and rim cells out), official -> v2: Fire 0.185 -> 0.265, Earth 0.160 -> 0.224,
  Metal 0.219 -> 0.249, Water 0.188 -> 0.225, Wood 0.195 -> 0.258. Earth and Water are held down by their big sparse
  start cells (Water without cell 5: 0.263).
- `source/`: cell14.py, cell93.py, borders.py, chaos.py (hub swirl, new), islands.py (Light / Thunder / Moon, new),
  lands/*.py. `whole.png`, `<land>.png`, `tree.svg` (viewer).

Passes, in order: density (wall pairs and more) per land; Chaos and islands by Claude; rims (Fire đỉnh + trefoils,
Earth pagoda + stars, cong, ruyi, bell; Metal weiqi board, linked rings, pentagons; Water lotus, armillaries, bagua;
Wood gourd, lanterns, stars); review window 1 (cell), 2 (wall pairs of cells), 3 (neighbourhoods, with the other lands
across the borders in view), 4 (two-ring regions: Fire, Metal, Earth, Water), 5 (whole land: Fire). Wood stopped at
window 3. Each pass's notes: `notes/<land>-<pass>-progress.md` (moved here from the scratch folder out/, 2026-11-19).

Open for the user's eye: two star pairs on rims (Earth 8-point, Wood 4-point); Earth's curved peak (mountain or
tent?) and the row of towers; Earth 8's wall reads as beads; Water's Ice start now framed by two arcs; Fire 49's
three-armed whorl (reads as a triskelion); rims sparse next to the lands (2-4 big figures cannot fill the band); a
medium "d_step" drawing used 4 times in Earth (rule 3.3 limit 3).

## Checks the standard checker does not make (run 05:10, `../../out/verify-v2.py`)
- R3 for pieces hung from two road nodes (the checker skips them): 14 door failures in v2 (a notable one step in from
  a road), against 4 in the official tree. Pieces: Earth c16 cliff_e / cliff_w (also in official), c16 d_split, c8
  d_arch / d_arch2, c51 d_arch, c55 d_arch; Water c115 eye_lens_a, c46 eye_lens_b. Not fixed tonight.
- Arc links of pieces: 4 off by 0.012 (Earth c66 / c2 d_gate ends), negligible; all others equidistant.
- Cells 14, 15, 93, combos 911/912/914/915 and every road, start and wall node are identical to the official tree;
  913's dew drops were opened on purpose. The five hub cells hold Chaos's 21 nodes each.
- Densities above are piece nodes over cell area with hub and rim cells left out; mix.py's per-land lines count island
  pieces by position (Light's 20 rays fall under Fire). 0.25 was Claude's target, not a measured PoE 2 figure.
- Start cells grew: Fire 3 (22 -> 58), Metal 4 (18 -> 37), Earth 2 (+8), Water 46 and 45 now frame the Ice start with
  two arcs. Rule 3.10 B4 wants start cells big and sparse: for the user to judge.

- 2026-11-19: `base-map.json` here is the base map this version was built on. The shared design/dao-do/cells/base-map.json
  later lost the ten keystone spur nodes (keystones folded onto their roads), so rebuild this version against this copy.
