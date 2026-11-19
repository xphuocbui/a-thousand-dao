# Đạo Đồ v5, the graph frozen for filling in the nodes (2026-11-19)

Saved by the user's word ("freeze it then we go to the next session"), after the Thunder and Water-rim rework that
unfroze v4. **This is the snapshot the content work keys to.** Not made official: the official version is still
`../../official-2026-11-18/` (the user said "freeze", not "make it official").

- `dao-do-map.json`: **8,038 nodes** (5,493 small, 1,759 notable, 24 keystones, 751 road, 11 starts), **867 pieces**;
  0 crossings, only the base map's 4 old spacing warnings, every piece passes R0-R4, every node reachable from the
  start. Built by `tools/design/dao_do_rework/cells/integrate.sh` at commit 82ef4e1 (two builds byte for byte
  identical: the build is deterministic).
- `base-map.json`: the base map it was built on (unchanged from v4). `source/`: the cell files compiled, the tracing
  libraries they import (`tools-underlay/`) and the measured data they read (`underlay-data/`); the pictures they read
  are in `design/dao-do/underlays/` at that commit. `tree.svg`: the viewer drawing (links in their pictures'
  colours). `whole.png`, `<land>.png`: renders. `SHA256SUMS`: checksums of everything here.

## Amendment 2026-11-19: Chaos land gate (user decision)

The only deliberate change after the freeze. Every node of the hub and Chaos regions, plus the six element pieces
reachable only through them (Fire ribbon clusters 9139 and 9140; Earth and Water clusters 9271, 9272, 9548 and 9549),
carries `"gate": "chaos"` (815 nodes; Đạo Đồ rules 3 and 4: gated nodes scale as Chaos land). Two Fire road nodes
(8998, 8999) were added for an hour the same day and removed again by the user's decision, so the graph itself is
unchanged by the gate: no id, position or edge changed. Checksums below were refreshed.

## Amendment 2026-11-19: nine keystones near the starts (user decision)

"Add more keystones please, but don't move anything else": nine keystone nodes were added by hand, each with one link
to an existing node, so every start has a keystone 6–10 points away (Đạo Đồ Formulas B). Nothing else moved and no
existing node's content changed (verified by rebuilding every area against the previous compile).

| Id | Name | Placed | Linked to |
|---|---|---|---|
| 8998-9002 | `c901`-`c905 keystone_start` | the centre of the hexagon on each element land's axis (Fire, Earth, Metal, Water, Wood) | the hexagon's inner node (1425, 1431, 1437, 1443, 1449) |
| 9003, 9004 | `c904 keystone_tide_a`, `_b` | a mirrored pair across Water's axis near the Water start | roads 1782, 1776 |
| 9005, 9006 | `c79 keystone_yang`, `_yin` | point-symmetric gaps in the Chaos swirl (gated with it) | arm nodes 8199, 8254 |
| 9007-9016 | `c901`-`c905 keystone_mid_a`, `_b` | a pair in open space either side of each element land's axis, 13–20 points from its start (second request the same day; 9011 is the user's spot, cell 27's corner by cells 26 and 116) | 1936, 1934; 3175, 3059; 1525, 1704; 5373, 5285; 1839, 6060 |

The map now has **8,057 nodes** (43 keystones, 817 gated). Ids 8998 and 8999 were used for an hour earlier that day by
two Fire road nodes that were removed; they now name keystones.

## What changed from v4 (`../v4-frozen-2026-11-19/`)

- **Thunder (cell 932)**: the traced bolts replaced (`thunder_bolts.py`; `thunder_trace.py` keeps its clouds and drops
  the small arc cloud at 580). Outside the web ring: bolts in the grammar of PoE 2's lightning clusters (Y, chain,
  double, tree), storm clouds with bolts underneath, two bigger clouds on the cloud side and two bolts below. Inside:
  small zigzag Ys at the spokes and straighter zigzags at the pentagon's corners, plus OpenAI's 16 small bolts across
  the five web cells and the pentagon (`oai_thunder.py`; the round is kept in `design/dao-do/underlays/openai-r3/`).
- **Water's rim (cell 904)**: three snowflakes added beside its lotus, bagua and armillaries: the ice flake (from road
  1815) and the plate flake (from 1321) in `water_rim.py`, OpenAI's barbed star (from 503) in `oai_water.py`. The
  waves, icicles and water drops tried there were removed by the user ("cell 904 is really bad please remove it").

## For the content work

Key node content on this map. The names of traced pieces' nodes (`c<cell> <piece> <key>`, keys such as `n_123` or
`v45`) come from the tracing and would change if a piece were re-traced, so content should be keyed on this snapshot's
node ids or names, or on a piece and a node's role in it, not regenerated keys. If the graph has to change after
content exists, change it here deliberately and carry the content across.
