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
