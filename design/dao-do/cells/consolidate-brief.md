# Brief: consolidate one land's pieces into medium and big figures (Đạo Đồ, 2026-11-18)

You are improving ONE land of the Đạo Đồ (a Path-of-Exile-2-like passive skill tree for a xianxia game). The land is
already filled; your job is a consolidation pass. Work from the repo root `C:/Users/xphuo/IdeaProjects/my-game`.
Run Python with `python -I`. This brief is all the context you get; read it fully, then the files it names.

## Why (measured, user agreed "Do 1 please")
Next to PoE 2 at the same scale, our tree reads as a sprinkle of tiny pieces: 81-91% of each land's pieces are small
(1-5 nodes), 3-12% big. PoE 2's mix is about 50% small, 33% medium (6-8), 14% big (9+), with bigger pieces that lock
into each other round shared road nodes. Notables are NOT the problem (PoE 2 25.9% of cluster nodes, ours 29%).
Image: `design/dao-do/cells/out/` has renders; PoE 2 vs ours side by side is in the artifact the parent showed.

## The job
In every cell of your land, replace groups of 2-3 small pieces that hang from the same or neighbouring road nodes with
ONE medium (6-8 nodes) or big (9-12) figure, so that the land ends near:
- pieces: about 50-55% small, 30% medium, 14% big (check with `mix.py`, below);
- nodes: each cell keeps at least 90% of its current node count, and may grow up to about 15% (PoE 2 is denser);
- the cell's existing centre figure and multi-cell combo pieces stay (you may enlarge a small combo piece).
You may also grow one small piece into a medium figure where there is room, instead of merging.

## How a medium or big figure is drawn (the user's verdicts this session; follow them)
- Built on circles round one centre (orbit grammar): rings, arcs, wheels, fans, spirals, lenses, nested arcs; nodes at
  even angular steps; links straight or as arcs round the figure's own centre (an arc link's centre must be equidistant
  from both ends). The approved reference is cell 14 (`design/dao-do/cells/cell14.py`): its centre combo, a ring of 8
  bridging the cell between two arcs on an outer orbit, was called "tasteful"; made-up sticks and wall-glued arches
  were "so bad".
- Every figure is its own drawing: "don't be repetitive, be creative". A medium drawing appears at most 3 times in the
  whole tree, a big one once (a mirrored twin across your land's axis is fine, as PoE 2 mirrors about half).
- Your land's character, subtly in the shapes: Fire flames, sparks, sun, phoenix; Earth mountains, terraces, gates,
  castles; Metal swords, blades, the sword formation, coins and bells; Water waves, ripples, lotus, whirlpools; Wood
  branches, leaves, vines, ferns (Wood also holds the two Wind cells 43 and 44: currents, gusts, swirls).
- A figure hangs from road nodes only (ints in the links), usually one, sometimes two (a pass-through). Separate
  pieces never link to each other. Never link to a wall cluster (the axis hexes, start figures) or to another piece.
- Hard rules (rulebook `design/dao-do/rules-2026-11-18.md` 3.2): R2 no dead-end small node (every leaf is a
  notable), R3 two small nodes before a chain's first notable, R4 at least one notable; spacing per node: another
  cluster's or a road's node 0.9, another cluster's or a road's link 0.6, own node 0.7, own link 0.45; no crossings.
  By eye: notables of different pieces about 1.5 apart (no clumps); no accidental look-alike neighbours.
- Medium figures carry 1-3 notables, big ones 2-5. Keep notables at the figure's tips and focal points.

## Files and tools
- Your land file: `design/dao-do/cells/lands/<land>.py` (the ONLY file you edit). It defines `THEME` and
  `CELLS = {cell_id: PIECES}`; pieces are {name: (nodes {key: ((x, y), kind)}, links [(a, b, arc centre or None)])}
  with road nodes as int ids; kinds 'small', 'notable', 'keystone'. FILL rows `(name, road, family, style, stem, ang,
  turn, hand)` go through `fill_rows()`; the families are in `design/dao-do/families/families-draft-2026-11-18.json`
  (+ 'Wheel'). Remove a small piece by deleting its row or block; add a figure as an explicit block.
- Library (do not edit): `tools/design/dao_do_rework/cells/celllib.py`: `L(r, th, land)` land-local polar point
  (th degrees from your land's axis, + towards +theta), `road(id)`, `orbit(O, rho, ang)` (ang 0 = towards the tree
  centre, + = towards +theta), `direction`, `bow_centre`, `place`, `fill_rows`, `mirror_pieces(pieces, land)`.
- Cell data: `design/dao-do/cells/inventory.json` (per land: each cell's id, area, band, centroid, wall road nodes with
  ids and land-local r/th, mirror partner).
- Check after EVERY cell (from the repo root):
  `sh tools/design/dao_do_rework/cells/check_land.sh <land>-c <files>` with files = your land file (Fire: first
  `design/dao-do/cells/cell14.py design/dao-do/cells/cell93.py`, then `lands/fire.py`). The base map alone shows
  `other link <0.6 4 nodes` (outside every cell); anything above that is yours. It writes
  `design/dao-do/cells/out/<tag>-map.json`. Use tags starting with your land name only.
- Size mix: `python -I tools/design/dao_do_rework/cells/mix.py design/dao-do/cells/out/<tag>-map.json <land> --cells`.
- Renders: `python -I tools/design/dao_do_rework/cells/render_land.py <map> <land> <out.png> 11` (land turned axis
  down; `--ids` writes cell ids) and `python -I tools/design/dao_do_rework/cells/render_cell.py <map>
  design/dao-do/cells/cells.json <cell id> <out prefix> 5 0.8` (one cell close up, writes `<prefix>-ref.png`). Look at
  the renders with your image-reading tool; judge by eye. Checks passing is necessary, not sufficient.
- A test of candidate positions may only try candidates you name yourself; you choose among the passing ones by eye.

## Constraints
- Edit only `design/dao-do/cells/lands/<land>.py`; write scratch files only under `design/dao-do/cells/out/` with
  names starting with your land. Do not touch cell14.py, cell93.py, borders.py, other lands, the library, the repo's
  other files, git, memory or session files. No subagents. Fire: keep cell 15 as the varied mirror of cell 14.
- Keep `design/dao-do/cells/out/<land>-consolidate-progress.md` (cells done, what replaced what); if your context is
  compacted, re-read this brief and that file before continuing.

## Finish with
The land file passing (no new spacing warnings, 0 crossings, all pieces R0-R4), then a short report: the mix before and
after (mix.py lines), per cell one line (what was merged into which figure, nodes before/after), the final render path
`design/dao-do/cells/out/<land>-consolidated.png`, and anything you were unsure of.
