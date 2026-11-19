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
THUNDER (Thunder island, cell id 932). An island at the left of the tree, centre (-103.665, -33.683). Its roads: the Thunder start figure (fixed) in the middle inside a small pentagon of road nodes (551-562), a pentagonal web of road cells round it (road nodes 553-577), an outer arc on the left (west) side (road nodes 578-586) closing two outer cells, and the open east side, where a road leaves from 570 through 588 to the tree. Region: inside the web cells and the two outer cells between the web and the outer arc, plus a margin of about 3 beyond the web on the open east side (keep clear of the road 570-588). Art direction, the director's own words: 'and lightning, I'm not so sure how'. Your call: storm, lightning, thunder in a way that still follows the style rules (no straight spikes; zigzags are acceptable only if they read as designed, built on a rhythm). Images: img-thunder.png.

- THEME = 'island'; cell id(s): 932; size: about 45-65 nodes.

## Data (JSON)
```json
{"road_nodes [id,x,y]":[[464,-79.889,-25.957],[552,-109.371,-35.537],[553,-107.774,-32.348],[554,-107.192,-28.829],[555,-103.665,-29.363],[556,-100.138,-28.829],[557,-99.557,-32.348],[558,-97.959,-35.537],[559,-101.126,-37.178],[560,-103.665,-39.683],[561,-106.204,-37.178],[562,-113.651,-36.928],[563,-116.127,-32.702],[564,-113.021,-28.916],[565,-111.783,-24.178],[566,-106.91,-23.697],[567,-102.684,-21.221],[568,-98.898,-24.327],[569,-94.16,-25.565],[570,-93.679,-30.438],[571,-91.204,-34.664],[572,-94.31,-38.45],[573,-95.547,-43.188],[574,-100.42,-43.669],[575,-104.646,-46.144],[576,-108.432,-43.038],[577,-113.17,-41.801],[578,-103.665,-51.683],[579,-109.227,-50.802],[580,-114.245,-48.245],[581,-118.227,-44.263],[582,-120.784,-39.245],[583,-121.665,-33.683],[584,-120.784,-28.121],[585,-118.227,-23.103],[586,-114.245,-19.121],[587,-117.218,-38.087],[588,-89.082,-28.944],[589,-84.486,-27.451]],"fixed_nodes_never_link [id,x,y,kind]":[[551,-103.665,-33.683,"start"],[839,-105.187,-34.177,"small"],[840,-105.312,-33.283,"small"],[841,-105.125,-32.4,"small"],[842,-106.185,-34.502,"small"],[843,-107.184,-34.826,"notable"],[844,-106.327,-32.287,"notable"],[845,-102.429,-33.281,"small"],[846,-101.192,-32.88,"notable"],[847,-104.763,-34.975,"small"],[848,-104.092,-35.579,"small"],[849,-104.998,-36.377,"notable"],[850,-108.135,-35.135,"small"],[851,-100.375,-32.614,"small"]],"road_links [a,b,arc_centre_or_null]":[[552,553,null],[553,554,null],[554,555,null],[555,556,null],[556,557,null],[557,558,null],[558,559,null],[559,560,null],[560,561,null],[561,552,null],[562,563,null],[563,564,null],[564,565,null],[565,566,null],[566,567,null],[567,568,null],[568,569,null],[569,570,null],[570,571,null],[571,572,null],[572,573,null],[573,574,null],[574,575,null],[575,576,null],[576,577,null],[577,562,null],[552,562,null],[554,565,null],[556,568,null],[558,572,null],[560,575,null],[578,579,[-103.665,-33.683]],[579,580,[-103.665,-33.683]],[580,581,[-103.665,-33.683]],[581,582,[-103.665,-33.683]],[582,583,[-103.665,-33.683]],[583,584,[-103.665,-33.683]],[584,585,[-103.665,-33.683]],[585,586,[-103.665,-33.683]],[575,578,null],[562,587,null],[587,582,null],[565,586,null],[570,588,null],[588,589,null],[589,464,null],[551,840,null],[551,847,null],[839,840,[-102.714,-33.374]],[839,847,[-102.714,-33.374]],[840,841,[-102.714,-33.374]],[847,848,[-102.714,-33.374]],[839,842,null],[842,843,null],[841,844,null],[848,849,null],[551,845,null],[845,846,null],[843,850,null],[850,552,null],[844,553,null],[849,561,null],[846,851,null],[851,557,null]],"neighbour_pieces_keep_clear nodes [id,x,y,kind]":[[551,-103.665,-33.683,"start"],[552,-109.371,-35.537,"travel"],[553,-107.774,-32.348,"travel"],[557,-99.557,-32.348,"travel"],[561,-106.204,-37.178,"travel"],[839,-105.187,-34.177,"small"],[840,-105.312,-33.283,"small"],[841,-105.125,-32.4,"small"],[842,-106.185,-34.502,"small"],[843,-107.184,-34.826,"notable"],[844,-106.327,-32.287,"notable"],[845,-102.429,-33.281,"small"],[846,-101.192,-32.88,"notable"],[847,-104.763,-34.975,"small"],[848,-104.092,-35.579,"small"],[849,-104.998,-36.377,"notable"],[850,-108.135,-35.135,"small"],[851,-100.375,-32.614,"small"],[6714,-79.847,-24.758,"small"],[6715,-80.71,-23.702,"small"],[6716,-82.105,-23.12,"small"],[6717,-83.671,-23.002,"notable"],[6718,-79.889,-22.657,"notable"],[6720,-79.227,-28.265,"small"],[6721,-80.014,-29.556,"small"],[6722,-81.212,-30.572,"notable"]],"neighbour_pieces_keep_clear links [a,b,arc_centre_or_null]":[[551,840,null],[551,847,null],[839,840,[-102.714,-33.374]],[839,847,[-102.714,-33.374]],[840,841,[-102.714,-33.374]],[847,848,[-102.714,-33.374]],[839,842,null],[842,843,null],[841,844,null],[848,849,null],[551,845,null],[845,846,null],[843,850,null],[850,552,null],[844,553,null],[849,561,null],[846,851,null],[851,557,null],[6714,6715,null],[6715,6716,null],[6716,6717,null],[6715,6718,null],[6720,6721,null],[6721,6722,null]]}
```
