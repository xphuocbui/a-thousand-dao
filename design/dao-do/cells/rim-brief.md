# Brief: large figures for one land's outer rim (Đạo Đồ v2, 2026-11-18 night)

You are improving ONE land's outer rim cell of the Đạo Đồ, a Path-of-Exile-2-like passive skill tree for a xianxia game:
the open band outside the outermost ring (r 74.3), cell 901 Fire, 902 Earth, 903 Metal, 904 Water, 905 Wood. Work
from the repo root `C:/Users/xphuo/IdeaProjects/my-game`, run Python with `python -I`. This brief is all the context
you get: read it fully, then the files it names.

## What the user asked (2026-11-18, before going to sleep)
"think of larger clusters for the outer most ring, clusters here are expected to be larger. I'm thinking things like a
tower, a đỉnh, a chess board, you know all that chinese mythology stuff, a lotus, a chinese flask ... I want you to
hand author a few more complicated shapes, it doesn't need to resemble anything, just some nicely designed graph here
and there should be good."

So the rim gets the tree's largest figures: 13 to about 28 nodes each, 2 to 4 of them per rim, replacing most of the
small and medium pieces there now (keep the two keystones and their hook figures, and the border combos are another
file, do not touch them). The rim's node count may grow; density there should end at least as high as the land's.

Your land's large figures:
- one mythology object, drawn as a graph (not a picture), usually on the land's axis and symmetric across it:
  Fire: a đỉnh, the alchemy cauldron (ding): a round belly on orbits, two handles, three legs; Earth: a tower, a pagoda
  of stacked tiers (arcs on concentric orbits round a point beyond the rim), a spire; Metal: a chess board (weiqi), a
  small lattice of nodes on a polar grid (rings x rays) with a few stones as notables, or a xiangqi river board;
  Water: a lotus, nested petal arcs opening outwards round one centre, a seed head; Wood: a gourd flask (hồ lô), two
  rings of different size joined at a waist, a stopper and a cord; plus anything else from Chinese myth that fits the
  land if you have room (a bagua, a luopan compass, a jade disc bi, a ruyi, a drum, a lantern, a pagoda bell);
- one or two abstract graphs, "nicely designed", resembling nothing: rosettes of interlocking arcs, nested polygons
  turned against each other, a ring of rings, a spiral of arcs, a lattice inside a circle, a star polygon drawn as an
  outline (never self-crossing). Often as a mirrored pair either side of the axis (PoE 2 mirrors about half).
All of them in orbit grammar: nodes on circles round a centre at even angular steps, links straight or arcs round the
figure's own centres (an arc link's centre must be equidistant from both ends). Notables at tips, focal points and
the figure's centre; a large figure carries about 25-30% notables. The approved reference for taste is cell 14
(`design/dao-do/cells/cell14.py`, a ring bridging the cell inside two arcs on an outer orbit, called "tasteful"); made-up
sticks and straight spikes (a notable on the end of one straight link) were rejected; "don't be repetitive, be
creative". No creatures.

## Hard rules (rulebook `design/dao-do/rules-2026-11-18.md` 3.2)
A figure hangs from road nodes only (int ids in its links), one or two of them (two = a pass-through); separate pieces
never link to each other, to a wall cluster (axis hexes, start figures) or to another piece. R2 no dead-end small node
(every leaf is a notable), R3 two small nodes before a chain's first notable, R4 at least one notable per piece;
spacing per node: another cluster's or a road's node 0.9, another cluster's or a road's link 0.6, own node 0.7, own link
0.45; no crossings. By eye: notables of different pieces about 1.5 apart; no accidental look-alike neighbours.

## Files and tools
- Your land file `design/dao-do/cells/lands/<land>.py` is the ONLY file you edit, and only its rim cell (90x). It
  defines `THEME` and `CELLS = {cell_id: PIECES}`; pieces are {name: (nodes {key: ((x, y), kind)}, links [(a, b, arc
  centre or None)])} with road nodes as int ids; kinds 'small', 'notable', 'keystone'. Its last lines set its hub cell
  to {} (the hub is drawn in `design/dao-do/cells/chaos.py`); leave those lines last. Remove a piece by deleting it from
  CELLS[90x] (e.g. `del CELLS[901]['name']` after it is built, or delete its block); add figures as explicit blocks.
- Library (do not edit): `tools/design/dao_do_rework/cells/celllib.py`: `L(r, th, land)` (land-local polar point, th
  degrees from your land's axis, + towards +theta), `road(id)`, `roads()`, `orbit(O, rho, ang)` (ang 0 = towards the
  tree centre, + = towards +theta), `direction`, `bow_centre`, `mirror_pieces(pieces, land)`, `wall_pair`,
  `reflect_line`.
- Find the rim's road nodes with `python -I tools/design/dao_do_rework/cells/render_box.py <map> <out.png> <cx> <cy>
  <half> [px] --ids` (a square window with road node ids; the rim of land at axis angle g is around
  (86 sin g, 86 cos g)) or by reading the map JSON (nodes with kind 'travel').
- Check after EVERY figure (from the repo root): `sh tools/design/dao_do_rework/cells/check_land.sh <land>-rim <files>`
  with files = (Fire: `design/dao-do/cells/cell14.py design/dao-do/cells/cell93.py`, then) your land file, then
  `design/dao-do/cells/borders.py design/dao-do/cells/islands.py` (so the border combos and islands are seen). The base
  map alone shows `other link <0.6 4 nodes`; anything more is yours. Use tags starting with your land.
- Look at every figure close up with render_box.py and judge by eye; checks passing is necessary, not sufficient.
- A test of candidate positions may only try candidates you name yourself; you choose among the passing ones by eye.

## Constraints
- Edit only your land file's rim cell; scratch files only under `design/dao-do/cells/out/` with names starting with
  your land. Do not touch other cells, other files, the library, git, memory or session files. No subagents.
- Keep `design/dao-do/cells/out/<land>-rim-progress.md`; if your context is compacted, re-read this brief and it.

## Finish with
The file passing (no new spacing warnings, 0 crossings, all pieces R0-R4), then a short report: what was removed, each
new figure (name, road nodes, nodes, notables, how it is built), the rim's node count before and after, a close-up
render `design/dao-do/cells/out/<land>-rim.png`, and anything you were unsure of.
