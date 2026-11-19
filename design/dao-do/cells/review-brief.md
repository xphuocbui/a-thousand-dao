# Brief: review and improve one land by eye, in windows of cells (Đạo Đồ v2, 2026-11-18 night)

You are improving ONE land of the Đạo Đồ, a Path-of-Exile-2-like passive skill tree for a xianxia game. The land is
filled, consolidated into medium and big figures, and made denser; your job is a quality pass by eye. Work from the
repo root `C:/Users/xphuo/IdeaProjects/my-game`, run Python with `python -I`. This brief is all the context you get:
read it fully, then the files it names.

## The pass you are running: WINDOW SIZE = given in your task message
The user (2026-11-18): "please do another round of cell by cell improvements. Then ... continue to look at multiple
nearby cells at a time, one by one, so a bit more convolution is involved and see if you can improve anything ... for
each pass have another convolution layer".
- Window 1: one cell at a time, every cell of your land (rim and hub excluded unless your task says otherwise).
- Window 2: every pair of cells that share a wall road, one pair at a time: judge the two as one picture.
- Window 3 or more: a cell and all its neighbours (cells sharing a wall), one neighbourhood at a time, sliding over
  the land; judge the group as one picture (how figures across walls answer each other, rhythm, balance, empty
  patches, crowding, the land's symmetry across its axis).
For each window: render it close up, look, decide what is weakest, fix that (one to three changes), check, look again.
If nothing in a window is clearly weak, leave it and say so; do not change things for the sake of change.

## What to look for (the user's verdicts this session)
- Bad: made-up sticks and straight spikes (a notable on the end of one straight link); wall-glued arches; freehand
  figures that are not built on circles; creatures and pictures that read as illustrations ("too much eye candy");
  a figure repeated nearby ("don't be repetitive, be creative"); notable clumps (notables of different pieces closer
  than about 1.5); accidental look-alike neighbours; crowded corners next to empty patches; many plain rings in a row.
- Good: orbit grammar (nodes on circles round a centre at even angular steps, arcs round the figure's own centre);
  the approved cell 14 (`design/dao-do/cells/cell14.py`: a ring bridging the cell inside two arcs on an outer orbit,
  "tasteful"); figures that interlock round shared road nodes; split figures mirrored across a wall road; the land
  about half mirrored across its axis; each land's character subtly in its shapes (Fire flames, sun, phoenix; Earth
  mountains, terraces, gates; Metal blades, bells, coins; Water waves, ripples, lotus, whirlpools; Wood branches,
  leaves, vines, ferns; Wind cells 43/44 currents, gusts).
- Keep: density at least where it is now (piece nodes / cell area, `mix.py`), the size mix about 50-58% small pieces
  by count, every centre figure the cell is named for unless it is clearly weak.

## Hard rules (rulebook `design/dao-do/rules-2026-11-18.md` 3.2)
A figure hangs from road nodes only (int ids in its links), one or two of them; separate pieces never link to each
other, to a wall cluster (axis hexes, start figures) or to another piece. R2 no dead-end small node, R3 two small
nodes before a chain's first notable, R4 at least one notable per piece; spacing per node: another cluster's or a
road's node 0.9, another cluster's or a road's link 0.6, own node 0.7, own link 0.45; no crossings; an arc link's
centre equidistant from both ends.

## Files and tools
- Your land file `design/dao-do/cells/lands/<land>.py` is the ONLY file you edit (not its last lines, which set the hub
  cell to {}: the hub is `design/dao-do/cells/chaos.py`). Pieces are {name: (nodes {key: ((x, y), kind)}, links [(a, b,
  arc centre or None)])} with road nodes as int ids. Library (do not edit): `tools/design/dao_do_rework/cells/
  celllib.py` (`L`, `road`, `roads`, `orbit`, `direction`, `bow_centre`, `place`, `fill_rows`, `mirror_pieces`,
  `wall_pair`, `reflect_line`). Cell data: `design/dao-do/cells/inventory.json` (cells, areas, wall road nodes,
  mirror partners; cells sharing road nodes are neighbours).
- Check after every change: `sh tools/design/dao_do_rework/cells/check_land.sh <land>-w<k> <files>` with files =
  (Fire: `design/dao-do/cells/cell14.py design/dao-do/cells/cell93.py`, then) your land file, then
  `design/dao-do/cells/borders.py design/dao-do/cells/chaos.py design/dao-do/cells/islands.py`. The base map alone
  shows `other link <0.6 4 nodes`; anything more is yours. Tags start with your land.
- Renders: `python -I tools/design/dao_do_rework/cells/render_box.py <map> <out.png> <cx> <cy> <half> [px] [--ids]`
  (a square window, Fire at the bottom; use the cells' centroids from inventory.json: x = r sin(g), y = r cos(g) with g
  = land axis + th) and `render_land.py <map> <land> <out.png> 11` (whole land, axis down). Judge by eye.
- Mix and density: `python -I tools/design/dao_do_rework/cells/mix.py <map> <land> --cells`.
- A test of candidate positions may only try candidates you name yourself; you choose among the passing ones by eye.

## Constraints
- Edit only your land file; scratch files only under `design/dao-do/cells/out/` with names starting with your land.
  Do not touch cell14.py, cell93.py, borders.py, chaos.py, islands.py, other lands, the library, git, memory or
  session files. No subagents. Fire: cells 14, 15 and 93 are off-limits. Leave start figures and axis hexes alone.
- Keep `design/dao-do/cells/out/<land>-w<k>-progress.md` (windows done, what changed); if your context is compacted,
  re-read this brief and that file before continuing.

## Finish with
The land file passing (no new spacing warnings, 0 crossings, all pieces R0-R4), then a short report: windows looked
at, per window what was weak and what you changed (or "left"), density and mix before and after, the final render
`design/dao-do/cells/out/<land>-w<k>.png`, and anything you were unsure of.
