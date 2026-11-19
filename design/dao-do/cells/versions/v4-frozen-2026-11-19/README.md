# Đạo Đồ v4, the graph frozen for filling in the nodes (2026-11-19)

Saved by the user's word ("freeze the graph as a snapshot please"), at the end of the graph-making stage
(`design/dao-do/method.md`), so that node content can be written against a graph that will not move. Not made
official: the official version is still `../../official-2026-11-18/` (the user said "freeze", not "make it official").

- `dao-do-map.json`: **7,840 nodes** (5,340 small, 1,714 notable, 24 keystones, 751 road, 11 starts), **856 pieces**;
  0 crossings, only the base map's 4 old spacing warnings, every piece passes R0-R4, every node reachable from the
  start. Built by `tools/design/dao_do_rework/cells/integrate.sh` at commit ad3c6d6 (two builds byte for byte
  identical: the build is deterministic).
- `base-map.json`: the base map it was built on (the hub's spokes 31-35 removed). `source/`: the cell files compiled,
  the tracing libraries they import (`tools-underlay/`) and the measured data they read (`underlay-data/`); the
  pictures they read are in `design/dao-do/underlays/` at that commit. `tree.svg`: the viewer drawing (links in their
  pictures' colours). `whole.png`, `<land>.png`: renders. `SHA256SUMS`: checksums of everything here.

## What changed from v3 (`../v3-islands-2026-11-19/`)

- **Shadow Shrine** (the road circle 625-636 off the Moon): traced from Eclipse 2 (`shrine_trace.py`); its old waxing
  moon removed from `moon_trace.py`.
- **Shadow Lotus** (Lotus 1): in the Moon island's crescent cup above the full moon, rooted out to roads 615 and 622.
  The Shrine and the lotus use the Sun's looser spacing (rules 3.2 exception).
- **Chaos**: the hub's five spokes removed (user-approved road change); a purple swirl, ten log-spiral arms from the
  outer ring into the inner ring and ten tributaries (`chaos_swirl.py`, after Replace 1); the five element motifs in
  each land's first cell round the figures already there (`chaos_elements.py`, from Add beside 1). OpenAI's old Chaos
  is gone. Metal's and Water's dead hub-cell code removed.
- **Pagoda**: now `pagoda.py` (OpenAI's design, unchanged).
- Node spacing on the new lines widened twice at the user's request ("too dense", "30% sparser").
- Link colours from the pictures (`colour_links.py`, display only).

## For the content work

Key node content on this map. The names of traced pieces' nodes (`c<cell> <piece> <key>`, keys such as `n_123` or
`v45`) come from the tracing and would change if a piece were re-traced, so content should be keyed on this snapshot's
node ids or names, or on a piece and a node's role in it, not regenerated keys. If the graph has to change after
content exists, change it here deliberately and carry the content across.

Open on the graph: Thunder (932) waits for new picture directions (its four unused ideas are in
`design/dao-do/underlays/ideas-2026-11-19/`).
