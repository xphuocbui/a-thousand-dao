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
- sets `THEME = '<given below>'` and `CELLS = {<cell id>: {piece name: (nodes, links)}, ...}`;
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
CHAOS (the hub at the centre of the whole tree; cell ids 79 wood, 80 earth, 81 metal, 82 water, 83 fire). Five lands surround it; land axes (th in the polar form): fire 0, earth 72, metal 144, water 216, wood 288. The hub's roads: an inner ring of radius 4.2 round the Chaos start figure (fixed, at the origin), an outer ring of radius 14.5, and five straight spokes from the inner to the outer ring along the borders between lands (th = 36, 108, 180, 252, 324), each with a middle road node at radius about 9.35. The five hub cells are the five wedges between the spokes, between the two rings; each piece must lie inside one wedge (polygons in the data) and is listed under that wedge's cell id. Beyond the outer ring are the lands (other pieces, see neighbours): stay inside radius 14.5. A curve may cross a spoke only at its middle road node or at a ring node, split into two pieces there (rule 5). Art direction, the director's own words: 'For chaos it should be swirls into the center'. Swirling, turning, drawn in towards the centre; the hub should read as one figure across the five wedges (rotating one wedge's design by 72 degrees is fine, P(r, th) makes that easy). Images: img-chaos.png.

- THEME = 'chaos'; cell id(s): 79, 80, 81, 82, 83; size: about 80-120 nodes in all, spread over the five cells.

## Data (JSON)
```json
{"road_nodes [id,x,y]":[[1,0.0,4.2],[2,2.469,3.398],[3,3.994,1.298],[4,3.994,-1.298],[5,2.469,-3.398],[6,0.0,-4.2],[7,-2.469,-3.398],[8,-3.994,-1.298],[9,-3.994,1.298],[10,-2.469,3.398],[11,8.523,11.731],[12,11.731,8.523],[13,13.79,4.481],[14,14.5,0.0],[15,13.79,-4.481],[16,11.731,-8.523],[17,8.523,-11.731],[18,4.481,-13.79],[19,0.0,-14.5],[20,-4.481,-13.79],[21,-8.523,-11.731],[22,-11.731,-8.523],[23,-13.79,-4.481],[24,-14.5,-0.0],[25,-13.79,4.481],[26,-11.731,8.523],[27,-8.523,11.731],[28,-4.481,13.79],[29,-0.0,14.5],[30,4.481,13.79],[31,5.496,7.565],[32,8.892,-2.889],[33,0.0,-9.35],[34,-8.892,-2.889],[35,-5.496,7.565],[236,11.227,15.453],[255,18.165,-5.902],[274,0.0,-19.1],[293,-18.165,-5.902],[313,-11.227,15.453]],"fixed_nodes_never_link [id,x,y,kind]":[[0,0,0,"start"],[680,0.0,2.95,"notable"],[681,2.806,0.912,"notable"],[682,1.734,-2.387,"notable"],[683,0.705,0.971,"small"],[684,1.141,-0.371,"small"],[685,0.0,-1.2,"small"],[686,-2.806,0.912,"notable"],[687,-1.734,-2.387,"notable"],[688,-0.705,0.971,"small"],[689,-1.141,-0.371,"small"]],"road_links [a,b,arc_centre_or_null]":[[1,2,[0,0]],[2,3,[0,0]],[3,4,[0,0]],[4,5,[0,0]],[5,6,[0,0]],[6,7,[0,0]],[7,8,[0,0]],[8,9,[0,0]],[9,10,[0,0]],[10,1,[0,0]],[11,12,[0,0]],[12,13,[0,0]],[13,14,[0,0]],[14,15,[0,0]],[15,16,[0,0]],[16,17,[0,0]],[17,18,[0,0]],[18,19,[0,0]],[19,20,[0,0]],[20,21,[0,0]],[21,22,[0,0]],[22,23,[0,0]],[23,24,[0,0]],[24,25,[0,0]],[25,26,[0,0]],[26,27,[0,0]],[27,28,[0,0]],[28,29,[0,0]],[29,30,[0,0]],[30,11,[0,0]],[2,31,null],[31,11,null],[4,32,null],[32,15,null],[6,33,null],[33,19,null],[8,34,null],[34,23,null],[10,35,null],[35,27,null],[11,236,null],[15,255,null],[19,274,null],[23,293,null],[27,313,null],[680,683,null],[680,688,null],[681,683,null],[686,688,null],[681,684,null],[686,689,null],[682,684,null],[687,689,null],[682,685,null],[687,685,null],[0,683,null],[0,688,null],[0,684,null],[0,689,null],[0,685,null],[680,1,null],[681,3,null],[686,9,null],[682,5,null],[687,7,null]],"neighbour_pieces_keep_clear nodes [id,x,y,kind]":[[12,11.731,8.523,"travel"],[14,14.5,0.0,"travel"],[20,-4.481,-13.79,"travel"],[22,-11.731,-8.523,"travel"],[28,-4.481,13.79,"travel"],[30,4.481,13.79,"travel"],[2834,-4.25,15.463,"small"],[2835,-5.688,16.507,"small"],[2849,4.25,15.463,"small"],[2850,5.688,16.507,"small"],[3708,12.864,9.346,"small"],[3709,13.567,10.342,"small"],[3710,14.629,10.906,"small"],[3711,15.808,10.723,"notable"],[3712,15.9,-0.0,"small"],[3713,17.055,-0.392,"small"],[5531,-4.989,-14.987,"small"],[5532,-5.079,-16.203,"small"],[5533,-5.699,-17.233,"small"],[5535,-12.712,-9.376,"small"],[5536,-13.841,-9.838,"small"],[5537,-14.63,-10.745,"small"],[5538,-14.716,-11.935,"notable"]],"neighbour_pieces_keep_clear links [a,b,arc_centre_or_null]":[[28,2834,null],[2834,2835,[0.0,22.824]],[30,2849,null],[2849,2850,[0.0,22.824]],[12,3708,null],[3708,3709,[14.193,9.153]],[3709,3710,[14.653,9.582]],[3710,3711,[15.039,9.658]],[14,3712,null],[3712,3713,[16.862,0.938]],[20,5531,null],[5531,5532,[-6.228,-15.506]],[5532,5533,[-6.401,-16.11]],[22,5535,null],[5535,5536,[-12.823,-10.715]],[5536,5537,[-13.344,-11.066]],[5537,5538,[-13.505,-11.425]]],"hub_cells {id: {land, polygon}}":{"79":{"land":"hub","polygon":[[-3.99,-1.3],[-4.19,-0.33],[-4.15,0.66],[-3.88,1.61],[-3.4,2.47],[-2.73,3.19],[-8.52,11.73],[-9.24,11.17],[-9.93,10.57],[-10.57,9.93],[-11.17,9.24],[-11.73,8.52],[-12.24,7.77],[-12.71,6.99],[-13.12,6.17],[-13.48,5.34],[-13.79,4.48],[-14.04,3.61],[-14.24,2.72],[-14.39,1.82],[-14.47,0.91],[-14.5,-0.0],[-14.47,-0.91],[-14.39,-1.82],[-14.24,-2.72],[-14.04,-3.61],[-13.79,-4.48]]},"80":{"land":"hub","polygon":[[2.47,3.4],[3.19,2.73],[3.74,1.91],[4.08,0.98],[4.2,-0.0],[4.08,-0.98],[13.79,-4.48],[14.04,-3.61],[14.24,-2.72],[14.39,-1.82],[14.47,-0.91],[14.5,0.0],[14.47,0.91],[14.39,1.82],[14.24,2.72],[14.04,3.61],[13.79,4.48],[13.48,5.34],[13.12,6.17],[12.71,6.99],[12.24,7.77],[11.73,8.52],[11.17,9.24],[10.57,9.93],[9.93,10.57],[9.24,11.17],[8.52,11.73]]},"81":{"land":"hub","polygon":[[3.99,-1.3],[3.58,-2.19],[2.97,-2.97],[2.19,-3.58],[1.3,-3.99],[0.33,-4.19],[0.0,-14.5],[0.91,-14.47],[1.82,-14.39],[2.72,-14.24],[3.61,-14.04],[4.48,-13.79],[5.34,-13.48],[6.17,-13.12],[6.99,-12.71],[7.77,-12.24],[8.52,-11.73],[9.24,-11.17],[9.93,-10.57],[10.57,-9.93],[11.17,-9.24],[11.73,-8.52],[12.24,-7.77],[12.71,-6.99],[13.12,-6.17],[13.48,-5.34],[13.79,-4.48]]},"82":{"land":"hub","polygon":[[0.0,-4.2],[-0.98,-4.08],[-1.91,-3.74],[-2.73,-3.19],[-3.4,-2.47],[-3.88,-1.61],[-13.79,-4.48],[-13.48,-5.34],[-13.12,-6.17],[-12.71,-6.99],[-12.24,-7.77],[-11.73,-8.52],[-11.17,-9.24],[-10.57,-9.93],[-9.93,-10.57],[-9.24,-11.17],[-8.52,-11.73],[-7.77,-12.24],[-6.99,-12.71],[-6.17,-13.12],[-5.34,-13.48],[-4.48,-13.79],[-3.61,-14.04],[-2.72,-14.24],[-1.82,-14.39],[-0.91,-14.47],[0.0,-14.5]]},"83":{"land":"hub","polygon":[[0.0,4.2],[0.98,4.08],[1.91,3.74],[5.5,7.57],[8.02,12.08],[7.25,12.56],[6.45,12.99],[5.62,13.37],[4.77,13.69],[3.9,13.97],[3.01,14.18],[2.12,14.34],[1.21,14.45],[0.3,14.5],[-0.61,14.49],[-1.52,14.42],[-2.42,14.3],[-3.31,14.12],[-4.19,13.88],[-5.05,13.59],[-5.9,13.25],[-6.72,12.85],[-7.51,12.4],[-8.28,11.91],[-2.47,3.4],[-1.61,3.88],[-0.66,4.15]]}}}
```
