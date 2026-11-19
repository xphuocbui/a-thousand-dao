# Brief: fill one land of the Đạo Đồ, cell by cell (2026-11-18)

> Moved to the repo 2026-11-18 after the five land fills: the tools now live in `tools/design/dao_do_rework/cells/`
> and the data in `design/dao-do/cells/` (`base-map.json` = the old `prop/v8-map.json`, `cells.json` = `cells-v8.json`).
> The scratchpad paths below are historical.

The user said: "Keep it similar to poe2, now go. Do the whole tree please." Five forks fill the five lands in
parallel; the parent integrates. You fill ONE land (named in your prompt). Everything below the roads is yours to place,
by hand, cell by cell. Roads are fixed: never add, move or remove a road node or road link.

## What "good" means (the user's own verdicts this session)
- Cell 14 (Fire, `cell14.py`) is the approved reference: "yup works". Its centre figure (a ring bridging the cell between
  two arcs on an outer orbit) was called "tasteful". Made-up sticks, forks and arches glued to the wall were "so bad".
- Cell 93 (`cell93.py`, a fan of five swirled rays from the right spoke node) is the second example (shown, not yet judged).
- "don't be repetitive, be creative": every cell its own centre figure, place and family mix. Never re-use cell 14's or
  93's figure, and never stamp one composition across cells in your land.
- Mirroring like PoE 2 (user: "keep it similar to poe2"): PoE 2 mirrors about half its cluster nodes across a class
  area's axis. So of your land's mirror pairs (see the inventory), mirror about HALF with `mirror_pieces()` and change
  one or two small pieces in the copy; give the other half their own compositions.
- The eye decides; checks passing is necessary, not sufficient. Render, look, fix what looks off, look again.

## Combos across cells (user, mid-run: "some combos that require multiple cells to make, is there a way")
Design 2-3 per land. No piece may cross a road, so a multi-cell combo is several pieces in neighbouring cells that read
as ONE figure, drawn on circles round one shared centre:
- **Junction figure:** centred on a road node where roads meet (a ring crossing a spoke or the axis), with arms or
  petals in the 3-4 cells round it, all hung from that node or its neighbours: a flower or star the roads pass through.
- **Split figure:** two halves facing each other across the road two cells share (a ring cut by the ring road, wings
  on either side of a spoke), hung from the same or neighbouring road nodes on each side.
- **Echo:** one figure answered by a related one in the next cell along a band (a wave that continues across a spoke).
Put each combo's pieces in the cells they sit in (pieces are per cell) and say in comments and in your report which
pieces form which combo. Combos across a land border are left to the parent. The cell's own composition still counts:
a cell holding half a combo builds around it.

## Rules (read them): `design/dao-do/rules-2026-11-18.md`
- 3.2 hard rules: R2 no dead-end small node (a leaf is a notable), R3 two small nodes before a chain's first notable,
  R4 a notable per cluster; spacing per node: other cluster/road node 0.9, other link 0.6, own node 0.7, own link 0.45;
  no crossings. Keystones: alone, one link, to a road node.
- 3.10 B4 (start cells big and sparse), B10-B13 (capacity; contents hang ONLY from road nodes, never from a wall
  cluster such as the axis hexes or a start figure; some cells are one hub figure), and all of 3.10 C (how a cell is filled).
- 3.3/3.4/3.5/3.6 (tiers, how a small piece varies, twins far apart, no blobs: separate pieces never link to each other).

## Your land's character (subtle, in the shapes, not pictures)
- Fire: flames, sparks, sun and phoenix sweep: rising forks, fans, crowns, upward flicks.
- Earth: mountains, terraces, a gate or castle: stacked arches, stepped chains, terraced half-rings, square-ish loops.
- Metal: swords and the sword formation (kiếm trận): straight rays, chevrons, crossed blades, long straight chains
  ending in a notable "hilt", sharp fans.
- Water: waves, ripples, a lotus, whirlpools: S-curves, spirals, concentric ripple arcs, petal lenses.
- Wood: branches, leaves, vines: branching trees (forks of forks), leaf lenses, tendril spirals, alternating side shoots.
Centre figures are built on circles round one centre (orbit grammar, 3.10 C1) and may be bigger pictures (9+ nodes).

## Density (reported targets, the eye decides)
- outer band (64.3-74.3) and middle band (53.9-64.3): about 0.28-0.32 nodes per unit² (cell 14: 63 in 206).
- 41.7-53.9 band: about 0.25; inner band (33.2-41.7): about 0.2, more small pieces, fewer big.
- start cell (558 units², your land's start figure inside): big and sparse, 2-4 pieces hung from its road nodes.
- hub cell (121 units², inside the Taiji ring, facing your land): 2-4 small pieces.
- cells beside the axis hex cluster (r 48) or the border cluster (r 59): the hex is a wall, not a hub; leave it alone.

## The outer band (rim) of your slice
Beyond the outer ring (r 74.3), within land-local theta -33..33 (the rim has no wall between lands; keep clear of the
seams): hang about 6-10 clusters outward from ring-74.3 road nodes, from the open hook ends (travel nodes at r 79.2,
local theta about -12 and +12) and from the open axis road ends (r 94) (PoE 2 keeps 15-18% of clusters outside its
outermost wall), including one or two bigger figures. Add your land's 2 keystones, kind 'keystone', each alone with one
link to a road node: at about r 81.8 just past each hook end (Fire's saved spots are L(81.8, -12.3) and L(81.8, 12.3)
linked to the hook ends; the other lands' saved spots in `prop/v8-map.json` `keystones` are stale, use the same
pattern). Water has no -12 hook (its Darkness connector is there): hang its second keystone from another open road end
or a ring-74.3 node. Put the rim pieces and keystones in CELLS under cell id 900 + {fire 1, earth 2, metal 3,
water 4, wood 5}. Islands (Light, Darkness, Thunder, Shadow Shrine) and the land start figures are left as they are.

## Tools (session scratchpad, folder `cellfill/`; absolute path
`C:/Users/xphuo/AppData/Local/Temp/claude/bdbcbe8acdb1cd77/812d5746-c962-4b76-a241-0df69c5cbc10/scratchpad/cellfill/`)
- `inventory.json`: per land, every cell: id, area, band, centroid (r, th land-local), wall road nodes
  [{id, r, th}], other walls, mirror partner.
- `celllib.py` (DO NOT EDIT; shared): `L(r, th, land)` land-local polar point, `road(id)`, `orbit(O, rho, ang)`,
  `direction`, `place(road, xy, family, style, stem, ang, turn, hand)`, `fill_rows(pieces, rows)`,
  `mirror_pieces(pieces, land)`, `mirror_road(id, land)`, `bow_centre`, the catalogue `FAM` (families from
  `design/dao-do/families/families-draft-2026-11-18.json` plus 'Wheel'). Angles: ang 0 = towards the tree centre,
  + = towards +theta. Pieces format: {name: (nodes {key: ((x, y), kind)}, links [(a, b, arc centre or None)])}, road
  nodes as int ids; kinds 'small', 'notable', 'keystone'. Arc links: the centre must be equidistant from both ends.
- Your land file `lands/<land>.py`: defines `THEME = '<land>'` and `CELLS = {cell_id: PIECES, ...}`. Write it so each
  cell is its own clearly commented block (centre figure first, then FILL rows), hand-chosen numbers only.
- `check_land.sh <tag> <files...>`: compile onto the base map, audit, cluster rules, nodes per cell. The base map alone
  shows `other link <0.6 4 nodes` (outside every cell): anything above that is yours. Use a tag starting with your
  land name (temp files are per tag). Example: `sh cellfill/check_land.sh fire-a cellfill/cell14.py cellfill/cell93.py cellfill/lands/fire.py`
- `render_land.py <map> <land> <out.png> [px/unit] [--ids]`: the land turned axis-down, cell ids in empty cells.
- `render_cell.py <map> cells-v8.json <cell id> <out prefix> 5 0.8` (writes <prefix>-ref.png): one cell close up
  (`cells-v8.json` is in the scratchpad root).
- `sweep.py` exists but shares temp names; copy it under a name with your land in it if you need it.
- PoE 2 reference cell at the same scale: `cellfill/poe2-c10.png`; PoE 2 small drawings:
  `design/dao-do/underlay/progress/poe2-small-copies-2026-11-18.png`; the catalogue sheet:
  `design/dao-do/families/sheet-2026-11-18.png`.
- Run Python with `python -I`. Work from the repo root `C:/Users/xphuo/IdeaProjects/my-game`.

## How to work
- Cell by cell. Run `check_land.sh` after EVERY cell (not at the end) and fix before moving on; render often.
- Keep `cellfill/out/<land>-progress.md`: cells done, figure used, mirrored-from, open doubts. After any context
  compaction, re-read this BRIEF and your progress file before continuing.
- A sweep may only test candidates you name yourself (families, directions, stems you chose); it never chooses a
  placement for you. You choose among the passing ones by eye. Everything stays hand-placed.
- Angles were fixed in celllib on 2026-11-18 (before you started): ang + is towards +theta everywhere, in every land.

## Constraints
- Write ONLY `cellfill/lands/<land>.py` and files under `cellfill/out/` whose names start with your land. Do not edit
  celllib.py, check tools, other lands' files, cell14.py / cell93.py, the repo, memory or session-state files.
  No artifacts, no commits, no subagents.
- Fire only: cells 14 and 93 are done (`cell14.py`, `cell93.py`); always compile them before `lands/fire.py`.

## Finish with
Your land file passing: no new spacing warnings, 0 crossings, all pieces pass R0-R4, every cell filled. Then a short
report: per cell one line (centre figure or composition, mirrored-from if any, node count); the final check output; the
paths of the land render (`cellfill/out/<land>-final.png`, with `--ids` off) and anything you were unsure of.
