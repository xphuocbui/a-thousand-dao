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
THE SUN (Light island, cell id 931). An island off the bottom of the tree, centre (0, 112). Its roads: an inner ring of radius about 6.5 (road nodes 522-528) round the Light start figure (fixed, in the middle), an outer ring of radius 13 (road nodes 529-548, every 18 degrees), and four spokes (straight roads) along the axes; the spoke going UP (towards -y) leads to the rest of the tree. Region: everything within radius about 18.5 of (0, 112), except near the up-going spoke above the outer ring, where other pieces of the tree sit (see neighbours). Art direction, the director's own words: 'Light should be simple, just do light rays going out'. Make it read as a sun: radiance outwards, calm and clear, built on the island's circles. Images: img-sun.png.

- THEME = 'island'; cell id(s): 931; size: about 60-80 nodes.

## Data (JSON)
```json
{"road_nodes [id,x,y]":[[521,0.0,118.5],[522,4.596,116.596],[523,6.5,112.0],[524,4.596,107.404],[525,0.0,105.5],[526,-4.596,107.404],[527,-6.5,112.0],[528,-4.596,116.596],[529,0.0,125.0],[530,4.017,124.364],[531,7.641,122.517],[532,10.517,119.641],[533,12.364,116.017],[534,13.0,112.0],[535,12.364,107.983],[536,10.517,104.359],[537,7.641,101.483],[538,4.017,99.636],[539,0.0,99.0],[540,-4.017,99.636],[541,-7.641,101.483],[542,-10.517,104.359],[543,-12.364,107.983],[544,-13.0,112.0],[545,-12.364,116.017],[546,-10.517,119.641],[547,-7.641,122.517],[548,-4.017,124.364],[549,0.0,94.0],[550,0.0,89.0]],"fixed_nodes_never_link [id,x,y,kind]":[[520,0.0,112.0,"start"],[815,0.0,114.0,"small"],[816,0.0,115.2,"small"],[817,0.0,116.4,"notable"],[818,1.414,113.414,"small"],[819,2.369,114.369,"notable"],[820,2.0,112.0,"small"],[821,3.2,112.0,"small"],[822,4.4,112.0,"notable"],[823,1.414,110.586,"small"],[824,2.369,109.631,"notable"],[825,0.0,110.0,"small"],[826,0.0,108.8,"small"],[827,0.0,107.6,"notable"],[828,-1.414,113.414,"small"],[829,-2.369,114.369,"notable"],[830,-2.0,112.0,"small"],[831,-3.2,112.0,"small"],[832,-4.4,112.0,"notable"],[833,-1.414,110.586,"small"],[834,-2.369,109.631,"notable"],[835,0.0,117.4,"small"],[836,5.4,112.0,"small"],[837,-5.4,112.0,"small"],[838,0.0,106.6,"small"]],"road_links [a,b,arc_centre_or_null]":[[521,522,[0.0,112.0]],[522,523,[0.0,112.0]],[523,524,[0.0,112.0]],[524,525,[0.0,112.0]],[525,526,[0.0,112.0]],[526,527,[0.0,112.0]],[527,528,[0.0,112.0]],[528,521,[0.0,112.0]],[529,530,[0.0,112.0]],[530,531,[0.0,112.0]],[531,532,[0.0,112.0]],[532,533,[0.0,112.0]],[533,534,[0.0,112.0]],[534,535,[0.0,112.0]],[535,536,[0.0,112.0]],[536,537,[0.0,112.0]],[537,538,[0.0,112.0]],[538,539,[0.0,112.0]],[539,540,[0.0,112.0]],[540,541,[0.0,112.0]],[541,542,[0.0,112.0]],[542,543,[0.0,112.0]],[543,544,[0.0,112.0]],[544,545,[0.0,112.0]],[545,546,[0.0,112.0]],[546,547,[0.0,112.0]],[547,548,[0.0,112.0]],[548,529,[0.0,112.0]],[521,529,null],[523,534,null],[525,539,null],[527,544,null],[539,549,null],[549,550,null],[520,815,null],[815,816,null],[816,817,null],[818,819,null],[828,829,null],[520,820,null],[520,830,null],[820,821,null],[830,831,null],[821,822,null],[831,832,null],[823,824,null],[833,834,null],[520,825,null],[825,826,null],[826,827,null],[815,818,[0.0,112.0]],[815,828,[0.0,112.0]],[818,820,[0.0,112.0]],[828,830,[0.0,112.0]],[820,823,[0.0,112.0]],[830,833,[0.0,112.0]],[823,825,[0.0,112.0]],[833,825,[0.0,112.0]],[817,835,null],[835,521,null],[822,836,null],[836,523,null],[832,837,null],[837,527,null],[827,838,null],[838,525,null]],"neighbour_pieces_keep_clear nodes [id,x,y,kind]":[[520,0.0,112.0,"start"],[521,0.0,118.5,"travel"],[523,6.5,112.0,"travel"],[525,0.0,105.5,"travel"],[527,-6.5,112.0,"travel"],[815,0.0,114.0,"small"],[816,0.0,115.2,"small"],[817,0.0,116.4,"notable"],[818,1.414,113.414,"small"],[819,2.369,114.369,"notable"],[820,2.0,112.0,"small"],[821,3.2,112.0,"small"],[822,4.4,112.0,"notable"],[823,1.414,110.586,"small"],[824,2.369,109.631,"notable"],[825,0.0,110.0,"small"],[826,0.0,108.8,"small"],[827,0.0,107.6,"notable"],[828,-1.414,113.414,"small"],[829,-2.369,114.369,"notable"],[830,-2.0,112.0,"small"],[831,-3.2,112.0,"small"],[832,-4.4,112.0,"notable"],[833,-1.414,110.586,"small"],[834,-2.369,109.631,"notable"],[835,0.0,117.4,"small"],[836,5.4,112.0,"small"],[837,-5.4,112.0,"small"],[838,0.0,106.6,"small"]],"neighbour_pieces_keep_clear links [a,b,arc_centre_or_null]":[[520,815,null],[815,816,null],[816,817,null],[818,819,null],[828,829,null],[520,820,null],[520,830,null],[820,821,null],[830,831,null],[821,822,null],[831,832,null],[823,824,null],[833,834,null],[520,825,null],[825,826,null],[826,827,null],[815,818,[0.0,112.0]],[815,828,[0.0,112.0]],[818,820,[0.0,112.0]],[828,830,[0.0,112.0]],[820,823,[0.0,112.0]],[830,833,[0.0,112.0]],[823,825,[0.0,112.0]],[833,825,[0.0,112.0]],[817,835,null],[835,521,null],[822,836,null],[836,523,null],[832,837,null],[837,527,null],[827,838,null],[838,525,null]]}
```
