# Brief: make one land denser with figures mirrored across cell walls (Đạo Đồ v2, 2026-11-18)

You are improving ONE land of the Đạo Đồ, a Path-of-Exile-2-like passive skill tree for a xianxia game. The current tree
was saved as the official version (`design/dao-do/cells/official-2026-11-18/`, never edit it); you work on the working
copy to make version 2. Work from the repo root `C:/Users/xphuo/IdeaProjects/my-game`, run Python with `python -I`.
This brief is all the context you get: read it fully, then the files it names.

## Why
Next to PoE 2 at the same scale our tree is too sparse. The user asked to fix density "cell by cell" with "the symmetry
mirror thing by the cell wall": a figure split by a wall road, one half in each of the two cells the wall separates,
the second half the mirror image of the first across the wall, so the road runs through one symmetric figure (PoE 2
does this a lot, and our five border combos in `design/dao-do/cells/borders.py` are the model: read them).

Density now (piece nodes / cell area, rims excluded) and the target of 0.25 per unit²:

| land | area | nodes now | density | target nodes (0.25) |
|---|---|---|---|---|
| fire | 3445 | 630 | 0.183 | 861 (+231) |
| earth | 3457 | 546 | 0.158 | 864 (+318) |
| metal | 3457 | 745 | 0.215 | 864 (+119) |
| water | 3323 | 615 | 0.185 | 831 (+216) |
| wood | 3604 | 689 | 0.191 | 901 (+212) |

Spread the gain over the land's cells (sparse cells gain most); no per-cell cap this time. If spacing rules stop you
short of the target, stop there and report it; never break a rule to get there.

## The job: wall pairs, cell by cell
1. Pick a wall road between two cells of YOUR land: a spoke segment (radial road) or a ring segment (between two
   consecutive road nodes on a ring). Not the land's border roads at local +-36 degrees (other land / borders.py), not
   the outer edge of the rim cells, never through an axis hex or a start figure.
2. Draw a half figure on one side, hung from road nodes lying ON that wall (one or two of them; two makes a pass-through
   arch), built in orbit grammar: arcs, rings, fans, lenses on circles round one centre, nodes at even angular steps,
   arc links round the figure's own centre (an arc link's centre must be equidistant from both ends). Then
   `half, other = wall_pair({name: (nodes, links)}, wa, wb)` (in `celllib`, wa and wb = two road nodes on the wall line)
   gives its exact mirror across the wall; put `half` in the cell on its side and `other` in the cell across.
   Road ids in the links map to the road node at the mirrored spot (nodes on the wall map to themselves).
3. Each half is its own cluster and must pass the rules on its own. Halves of 5-8 nodes are best (a pair of 10-16 reads
   as one big figure); never two halves that touch or link each other.
4. Keep the land's symmetry: the land is about half mirrored across its axis (`mirror_pieces(pieces, land)`), so a wall
   pair at local +th usually gets a twin pair at -th, but vary about half of them (PoE 2 mirrors about half).
5. Every pair is its own drawing: "don't be repetitive, be creative". Your land's character, subtly: Fire flames,
   sparks, sun, phoenix; Earth mountains, terraces, gates, castles; Metal blades, bells, coins, the sword formation;
   Water waves, ripples, lotus, whirlpools; Wood branches, leaves, vines, ferns (Wood also holds the Wind cells 43 and
   44: currents, gusts, swirls). Avoid creatures and straight spikes (a notable on the end of one straight link): the
   user rejected "made-up sticks". The approved reference is cell 14 (`design/dao-do/cells/cell14.py`): a ring
   bridging the cell inside two arcs on an outer orbit, called "tasteful".
6. Wall pairs are ONE way, not the only one (user, 2026-11-18: "the wall pair is just a way, there are more ways").
   Use whatever makes each cell denser and better: grow existing figures (more nodes on their orbits, an extra outer
   arc, a nested ring), add new pieces in empty space, pairs mirrored across the land axis, pass-through arches between
   two road nodes of one wall, figures that interlock round a shared road node, filling gaps between figures. Mix the
   ways so the land does not read as one trick repeated.
7. Keep the size mix near the current one (about 54% small, 31% medium, 15% big by pieces; `mix.py`); halves count as
   pieces, so prefer halves of 6-8 nodes.

## Hard rules (rulebook `design/dao-do/rules-2026-11-18.md` 3.2)
R2 no dead-end small node (every leaf is a notable), R3 two small nodes before a chain's first notable, R4 at least one
notable per piece; spacing per node: another cluster's or a road's node 0.9, another cluster's or a road's link 0.6, own
node 0.7, own link 0.45; no crossings. By eye: notables of different pieces about 1.5 apart (no clumps); no accidental
look-alike neighbours. A figure hangs from road nodes only (ints in the links); separate pieces never link to each
other, to a wall cluster (axis hexes, start figures) or to another piece.

## Files and tools
- Your land file `design/dao-do/cells/lands/<land>.py` is the ONLY file you edit. It defines `THEME` and
  `CELLS = {cell_id: PIECES}`; pieces are {name: (nodes {key: ((x, y), kind)}, links [(a, b, arc centre or None)])}
  with road nodes as int ids; kinds 'small', 'notable', 'keystone'. Add each half to its cell's dict, e.g.
  `CELLS[18].update(half); CELLS[37].update(other)` (piece names unique within a cell).
- Library (do not edit): `tools/design/dao_do_rework/cells/celllib.py`: `wall_pair`, `reflect_line`, `L(r, th, land)`
  (land-local polar point, th degrees from your land's axis, + towards +theta), `road(id)`, `orbit(O, rho, ang)` (ang 0
  = towards the tree centre, + = towards +theta), `direction`, `bow_centre`, `place`, `fill_rows`, `mirror_pieces`.
- Cell data: `design/dao-do/cells/inventory.json` (per land: each cell's id, area, band, centroid r/th, wall road nodes
  with ids and land-local r/th, mirror partner). Two cells share a wall where they share road nodes.
- Check after EVERY pair (from the repo root): `sh tools/design/dao_do_rework/cells/check_land.sh <land>-d <files>` with
  files = your land file (Fire: first `design/dao-do/cells/cell14.py design/dao-do/cells/cell93.py`, then
  `design/dao-do/cells/lands/fire.py`). The base map alone shows `other link <0.6 4 nodes`; anything more is yours.
  It writes `design/dao-do/cells/out/<tag>-map.json` and prints nodes per cell. Use tags starting with your land.
- Size mix: `python -I tools/design/dao_do_rework/cells/mix.py design/dao-do/cells/out/<tag>-map.json <land> --cells`.
- Renders: `python -I tools/design/dao_do_rework/cells/render_land.py <map> <land> <out.png> 11 [--ids]` (land turned
  axis down) and `python -I tools/design/dao_do_rework/cells/render_cell.py <map> design/dao-do/cells/cells.json
  <cell> <prefix> 5 0.8` (crops to the cell's first polygon only; for a wall pair, crop both cells yourself if needed).
  Look at renders with your image-reading tool and judge by eye; checks passing is necessary, not sufficient.
- A test of candidate positions may only try candidates you name yourself; you choose among the passing ones by eye.

## Constraints
- Edit only your land file; scratch files only under `design/dao-do/cells/out/` with names starting with your land.
  Do not touch cell14.py, cell93.py, borders.py, other lands, the library, the official folder, git, memory or session
  files. No subagents. Fire: leave cells 14, 15 and 93 exactly as they are (no halves in them). Leave start figures,
  axis hexes and their cells' character alone (start cells stay big and sparse; a wall pair on their outer walls is ok).
- Keep `design/dao-do/cells/out/<land>-density-progress.md` (walls done, what went where, nodes per cell); if your
  context is compacted, re-read this brief and that file before continuing.

## Finish with
The land file passing (no new spacing warnings, 0 crossings, all pieces R0-R4), then a short report: density before and
after (nodes and per unit²), the mix line from mix.py, one line per wall pair (wall road ids, cells, figure, nodes),
other additions, the final render `design/dao-do/cells/out/<land>-dense.png`, and anything you were unsure of.
