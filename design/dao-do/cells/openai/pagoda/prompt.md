# Design request: one region of a passive skill tree

You are designing node figures for one region of a large passive skill tree, in the style of Path of Exile 2's
passive tree, for a game about cultivating immortality (Chinese xianxia). The roads are already laid: a web of
"road" (travel) nodes and links. You add **pieces**: small graphs of nodes hung from road nodes. Your output is one
Python file that defines them. A compiler places them on the map; a checker tests the rules below; the art director
judges the result by eye.

## Coordinates
- One map frame for everything: +x to the right, +y DOWN (the attached images use exactly this frame; the ids printed
  next to the dots are the road node ids). Units: a small node is drawn about 0.45 across.
- Polar form used by the map: P(r, th) = (r * sin(th deg), r * cos(th deg)), th measured from the +y axis towards +x.

## What a piece is
- A dict entry `name: (nodes, links)`.
  - `nodes`: `{key: ((x, y), kind)}`, kind is `'small'` or `'notable'` (a notable is a big, important node).
  - `links`: list of `(a, b, arc)`. `a`, `b` are node keys of THIS piece or **integer road node ids**. `arc` is `None`
    for a straight link, or the `(x, y)` centre of a circle for a curved link (drawn as the short arc between the two
    ends round that centre).
- A piece hangs from road nodes only: one or two road nodes (int ids among its links). Pieces never link to each
  other, never to the "fixed" nodes listed in the data (start figures), and every node of a piece must be connected.

## Hard rules (checked automatically; a breach fails the design)
1. No dead-end small node: every leaf (degree-1 node) of a piece must be a notable.
2. From every road node a piece hangs from, at least two small nodes come before the first notable on any path
   (a notable may not be directly on a road node, nor one step in).
3. At least one notable per piece.
4. Spacing, measured from each of your nodes:
   - to any node of another piece or any road node: >= 0.9;
   - to any link of another piece or of the roads (other than links touching this node): >= 0.6;
   - to another node of the same piece: >= 0.7;
   - to a link of the same piece not touching this node: >= 0.45.
5. No link may cross any other link (yours, the roads', the neighbours'). Road links can only be "passed" at a road
   node: a curve that needs to go across a road ends at a road node of that road as one piece and continues from the
   same road node as a second piece.
6. Arc links: the centre must be equidistant from both ends (within 0.005). Compute centres, don't guess them.
7. Stay inside the region described below; keep clear of the neighbour pieces listed in the data.

## Style (the art director's verdicts on earlier work)
- Good: "orbit grammar", nodes on circles round a centre at even angular steps, links that are arcs round the
  figure's own centre; a ring bridging a gap inside two arcs on an outer orbit was called "tasteful"; figures that
  interlock round shared road nodes; figures mirrored across a road; a region roughly symmetric where its roads are.
- Bad: made-up sticks and straight spikes (a notable on the end of one straight link); freehand shapes not built on
  circles; pictures that read as illustrations ("too much eye candy"); the same figure repeated next to itself
  ("don't be repetitive, be creative"); notables of different pieces closer than about 1.5; crowded corners next to
  empty patches; many plain rings in a row.
- Mix piece sizes: many small pieces (1-5 nodes), some medium (6-8), a few big (9+).

## Output
Reply with ONE fenced ```python block, then at most five lines on the idea. The file:
- may import only `math` and `from celllib import road, roads` (`road(id)` returns the (x, y) of a road node,
  `roads()` the dict of all of them); no file access, no other imports, no printing;
- sets `THEME = 'earth'` and `CELLS = {902: {piece name: (nodes, links)}, ...}`; piece names in snake_case;
- computes positions with helper functions (circles, angles) rather than typing hundreds of numbers;
- you may run your own checks before answering; aim for zero rule breaches.

Format example (a different region, only to show the shape):
```python
import math
from celllib import road
THEME = 'border'
def Q(C, r, a):                     # point at radius r, angle a (degrees from +y towards +x) round C
    t = math.radians(a); return (C[0] + r * math.sin(t), C[1] + r * math.cos(t))
C = road(392)
arc = {f'n{i}': (Q(C, 2.2, a), k) for i, (a, k) in enumerate(zip((25, 58, 90, 122, 155),
       ('notable', 'small', 'small', 'small', 'notable')))}
CELLS = {911: {'crater': (arc, [(392, 'n2', None), ('n2', 'n1', C), ('n1', 'n0', C), ('n2', 'n3', C), ('n3', 'n4', C)])}}
```
(Road node 392 is the arc's centre and the entry; n2 and n1 are the two smalls before the notable n0.)

## Your region
THE PAGODA (tower), on the outer rim of the Earth land, cell id 902, THEME = 'earth'. The Earth land's axis is the
straight road from the outer ring node 1490 (radius 74.3 from the tree centre) outwards through road nodes 501 (r 79.95),
404 (r 84), 1227 (r 89) to its end 1228 (r 94). That road is the pagoda's MAST. In land polar form a point is
E(r, th) = (r * sin(72 + th deg), r * cos(72 + th deg)): th = 0 is the mast, +th one side, -th the other; "up" the
pagoda is outwards (larger r). Mirror across the mast: reflect a point across the line through (0, 0) at 72 degrees,
i.e. with u = (sin 72, cos 72): p' = 2 (p . u) u - p. The design must be mirrored across the mast (the two halves are
separate pieces hung from mast road nodes, because pieces may not cross the road); you may also add pieces whose
nodes lie on the mast's far end beyond 1228 (a finial).
Region: r from about 75.5 (just clear of the outer ring road, which runs along r 74.3 through 1490, 1656 at th +2.7 and
1646 at th -2.7) to about 99; |th| up to about 7 near r 80 and narrower further out; keep clear of the pieces already
around it (listed as other nodes; a hook and an octagram cluster sit at about th +-9 to +-12 near the ring).
Earlier versions the art director rejected: (1) a ladder of straight wedge-shaped eaves hanging from a slanted wall,
"looks a bit bad" (it read as a comb / saw); (2) a stack of three thin upturned arcs from the mast nodes (no body, read
as arcs, not a tower). Wanted: a pagoda you can recognise at a glance in node-graph grammar, not an illustration:
tiered roofs with upturned eaves narrowing towards the top, a body between the tiers (walls, doors, balconies,
built on circles and even steps), a spire with a finial at the top (beyond 1228). Mirrored, orbit grammar, notables
at the eave tips and other meaningful points.
- size: about 50-80 nodes in all. Images: img-empty.png (the empty area with road ids, map frame: +x right, +y down;
  the mast runs from upper left to lower right), img-old.png (rejected version 1), img-claude.png (rejected version 2).

## Data (JSON)
```json
{"road_nodes [id,x,y]":[[404,79.889,25.957],[501,76.037,24.706],[1227,84.644,27.503],[1228,89.399,29.048],[1490,70.663,22.96],[1644,66.78,32.571],[1645,68.138,29.627],[1646,69.503,26.263],[1654,73.171,12.902],[1655,72.539,16.081],[1656,71.667,19.606]],"other_nodes_keep_clear [id,x,y,kind] (pieces and keystones already there)":[[3503,67.207,29.994,"small"],[3504,66.549,30.983,"small"],[3505,65.484,31.462,"small"],[3508,68.534,26.51,"small"],[3509,67.319,26.416,"small"],[3528,70.629,13.985,"notable"],[3529,71.846,12.927,"small"],[3564,70.531,20.128,"small"],[3565,69.757,20.992,"small"],[3568,72.214,12.099,"small"],[3569,71.903,10.951,"small"],[3573,71.105,19.052,"small"],[3574,70.813,18.32,"small"],[3575,70.841,17.531,"small"],[3576,71.184,16.821,"small"],[3577,71.784,16.309,"small"],[3578,69.975,18.465,"small"],[3579,70.016,17.327,"notable"],[3580,70.511,16.302,"small"],[3802,74.426,13.122,"small"],[3803,75.697,13.043,"small"],[3804,76.915,12.67,"small"],[3805,76.512,13.526,"small"],[3806,76.101,12.187,"small"],[3807,78.013,12.022,"small"],[3811,80.884,12.513,"small"],[3812,79.815,13.27,"notable"],[3813,67.925,33.13,"small"],[3814,68.907,33.942,"small"],[3815,69.673,34.96,"small"],[3816,69.849,34.03,"small"],[3817,68.731,34.872,"small"],[3818,70.18,36.128,"small"],[3822,72.791,37.419,"small"],[3823,72.371,36.178,"notable"]],"all_links_in_area [a,b,arc_centre_or_null]":[[501,404,null],[404,1227,null],[1227,1228,null],[1489,1490,null],[1490,501,null],[1643,1644,[0.0,0.0]],[1644,1645,[0.0,0.0]],[1645,1646,[0.0,0.0]],[1646,1490,[0.0,0.0]],[1653,1654,[0.0,0.0]],[1654,1655,[0.0,0.0]],[1655,1656,[0.0,0.0]],[1656,1490,[0.0,0.0]],[1645,3503,null],[3503,3504,[66.128,29.989]],[3504,3505,[65.653,30.415]],[3505,3506,[65.489,30.383]],[1646,3508,null],[3508,3509,[67.976,25.825]],[3509,3510,[66.523,26.06]],[3529,1654,null],[3527,3528,null],[3528,3529,null],[1656,3564,null],[3564,3565,[70.799,21.147]],[3565,3566,[69.376,21.981]],[1654,3568,null],[3568,3569,null],[3569,3570,[71.177,10.877]],[1656,3573,[72.702,17.992]],[3573,3574,[72.702,17.992]],[3574,3575,[72.702,17.992]],[3575,3576,[72.702,17.992]],[3576,3577,[72.702,17.992]],[3577,1655,[72.702,17.992]],[3574,3578,null],[3576,3580,null],[3578,3579,[72.702,17.992]],[3579,3580,[72.702,17.992]],[1654,3802,[74.728,7.71]],[3802,3803,[74.728,7.71]],[3804,3807,[74.728,7.71]],[3803,3805,[76.47,12.667]],[3805,3804,[76.064,12.791]],[3803,3806,[76.548,12.921]],[3806,3804,[76.142,13.046]],[3807,3808,[78.731,11.187]],[3810,3811,[82.227,12.205]],[3811,3812,[81.258,14.175]],[3812,3807,[78.979,12.551]],[1644,3813,[64.988,37.687]],[3813,3814,[64.988,37.687]],[3815,3818,[64.988,37.687]],[3814,3816,[69.311,34.7]],[3816,3815,[69.056,34.361]],[3814,3817,[69.524,34.541]],[3817,3815,[69.269,34.201]],[3818,3819,[70.271,37.227]],[3821,3822,[73.697,38.458]],[3822,3823,[74.07,36.295]],[3823,3818,[71.273,36.269]]],"link_endpoints_outside_area [id,x,y,kind]":[[1489,65.908,21.415,"travel"],[1643,64.346,37.15,"travel"],[1653,73.893,7.766,"travel"],[3506,64.495,30.804,"small"],[3510,66.206,26.872,"small"],[3527,69.667,13.164,"small"],[3566,68.617,21.241,"small"],[3570,71.046,10.159,"small"],[3808,79.26,10.22,"notable"],[3810,81.062,11.468,"notable"],[3819,70.13,38.32,"notable"],[3821,72.322,38.37,"notable"]]}
```
