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
THE MOON (Darkness island, cell id 933). An island off the top of the tree. Its roads form a crescent: an outer arc of radius 19 round (0, -109) (road nodes 590-610 roughly, tips 590 and 591 at the top) and an inner arc of radius about 15.9 round (0, -117.3) (road nodes 611-623 roughly); the crescent's hollow (towards -y, inside the inner arc) is open space. The Darkness start figure (fixed) sits at (0, -95.7) on a road from 617 down to 601. Roads leave sideways from 608 and 599 and down from 601 to 440 (440 is the end of another region; a neighbour figure hangs there). The island also owns a small separate road circle far away at about (107.8, -24.9), radius about 7.6 (road nodes 625-636): put a small moon-related figure in it too (inside that circle, hung from its road nodes). Region: the crescent band between the two arcs, the hollow inside the inner arc (up to about radius 14 round (0, -117.3)), a margin of about 3 outside the outer arc, and the side circle's inside. Art direction, the director's own words: 'the moon should have these celeste mystical curves you know'. Celestial, mystical, curved. Images: img-moon.png (the crescent) and img-moonside.png (the side circle).

- THEME = 'island'; cell id(s): 933; size: about 55-75 nodes, of which 6-10 in the side circle.

## Data (JSON)
```json
{"road_nodes [id,x,y]":[[590,15.2,-120.4],[591,-15.2,-120.4],[592,4.228,-90.476],[593,8.244,-91.882],[594,11.846,-94.145],[595,14.855,-97.154],[596,17.118,-100.756],[597,18.524,-104.772],[598,19.0,-109.0],[599,18.565,-113.044],[600,17.278,-116.903],[601,0.0,-90.0],[602,-4.228,-90.476],[603,-8.244,-91.882],[604,-11.846,-94.145],[605,-14.855,-97.154],[606,-17.118,-100.756],[607,-18.524,-104.772],[608,-19.0,-109.0],[609,-18.565,-113.044],[610,-17.278,-116.903],[611,3.945,-101.908],[612,7.633,-103.398],[613,10.824,-105.774],[614,13.309,-108.88],[615,14.926,-112.514],[616,15.571,-116.439],[617,0.0,-101.4],[618,-3.945,-101.908],[619,-7.633,-103.398],[620,-10.824,-105.774],[621,-13.309,-108.88],[622,-14.926,-112.514],[623,-15.571,-116.439],[625,115.213,-26.599],[626,113.366,-30.073],[627,110.03,-32.157],[628,106.098,-32.295],[629,102.625,-30.448],[630,100.54,-27.111],[631,100.403,-23.18],[632,102.249,-19.706],[633,105.586,-17.621],[634,109.517,-17.484],[635,112.991,-19.331],[636,115.076,-22.667],[637,23.435,-108.133],[638,27.83,-107.086],[662,104.445,-36.514],[664,95.764,-22.109],[667,-23.362,-108.149],[668,-27.687,-107.123]],"fixed_nodes_never_link [id,x,y,kind]":[[624,0.0,-95.7,"start"],[852,-2.561,-95.648,"notable"],[853,-1.992,-94.429,"small"],[854,-1.099,-93.744,"small"],[855,-0.0,-93.5,"notable"],[856,-1.17,-94.706,"small"],[857,-0.0,-94.5,"small"],[858,0.0,-96.9,"small"],[859,0.0,-98.1,"notable"],[860,2.561,-95.648,"notable"],[861,1.992,-94.429,"small"],[862,1.099,-93.744,"small"],[863,1.17,-94.706,"small"],[864,0.0,-99.1,"small"],[865,0.0,-92.5,"small"]],"road_links [a,b,arc_centre_or_null]":[[590,600,[0.0,-109.0]],[600,599,[0.0,-109.0]],[599,598,[0.0,-109.0]],[598,597,[0.0,-109.0]],[597,596,[0.0,-109.0]],[596,595,[0.0,-109.0]],[595,594,[0.0,-109.0]],[594,593,[0.0,-109.0]],[593,592,[0.0,-109.0]],[592,601,[0.0,-109.0]],[601,602,[0.0,-109.0]],[602,603,[0.0,-109.0]],[603,604,[0.0,-109.0]],[604,605,[0.0,-109.0]],[605,606,[0.0,-109.0]],[606,607,[0.0,-109.0]],[607,608,[0.0,-109.0]],[608,609,[0.0,-109.0]],[609,610,[0.0,-109.0]],[610,591,[0.0,-109.0]],[590,616,[0.0,-116.98]],[616,615,[0.0,-116.98]],[615,614,[0.0,-116.98]],[614,613,[0.0,-116.98]],[613,612,[0.0,-116.98]],[612,611,[0.0,-116.98]],[611,617,[0.0,-116.98]],[617,618,[0.0,-116.98]],[618,619,[0.0,-116.98]],[619,620,[0.0,-116.98]],[620,621,[0.0,-116.98]],[621,622,[0.0,-116.98]],[622,623,[0.0,-116.98]],[623,591,[0.0,-116.98]],[625,626,[107.808,-24.889]],[626,627,[107.808,-24.889]],[627,628,[107.808,-24.889]],[628,629,[107.808,-24.889]],[629,630,[107.808,-24.889]],[630,631,[107.808,-24.889]],[631,632,[107.808,-24.889]],[632,633,[107.808,-24.889]],[633,634,[107.808,-24.889]],[634,635,[107.808,-24.889]],[635,636,[107.808,-24.889]],[636,625,[107.808,-24.889]],[598,637,[0.0,0.0]],[637,638,[0.0,0.0]],[662,628,[0.0,0.0]],[631,664,null],[608,667,[0.0,0.0]],[667,668,[0.0,0.0]],[852,853,[0.0,-96.1]],[860,861,[0.0,-96.1]],[853,854,[0.0,-96.1]],[861,862,[0.0,-96.1]],[854,855,[0.0,-96.1]],[862,855,[0.0,-96.1]],[852,856,[0.0,-97.92]],[860,863,[0.0,-97.92]],[856,857,[0.0,-97.92]],[863,857,[0.0,-97.92]],[624,857,null],[624,858,null],[858,859,null],[859,864,null],[864,617,null],[855,865,null],[865,601,null]],"neighbour_pieces_keep_clear nodes [id,x,y,kind]":[[440,0.0,-84.0,"travel"],[601,0.0,-90.0,"travel"],[617,0.0,-101.4,"travel"],[624,0.0,-95.7,"start"],[852,-2.561,-95.648,"notable"],[853,-1.992,-94.429,"small"],[854,-1.099,-93.744,"small"],[855,-0.0,-93.5,"notable"],[856,-1.17,-94.706,"small"],[857,-0.0,-94.5,"small"],[858,0.0,-96.9,"small"],[859,0.0,-98.1,"notable"],[860,2.561,-95.648,"notable"],[861,1.992,-94.429,"small"],[862,1.099,-93.744,"small"],[863,1.17,-94.706,"small"],[864,0.0,-99.1,"small"],[865,0.0,-92.5,"small"],[6702,-0.953,-84.55,"small"],[6703,-1.286,-85.532,"small"],[6704,-1.45,-86.511,"notable"],[6705,0.953,-84.55,"small"],[6706,1.286,-85.532,"small"],[6707,1.45,-86.511,"notable"]],"neighbour_pieces_keep_clear links [a,b,arc_centre_or_null]":[[852,853,[0.0,-96.1]],[860,861,[0.0,-96.1]],[853,854,[0.0,-96.1]],[861,862,[0.0,-96.1]],[854,855,[0.0,-96.1]],[862,855,[0.0,-96.1]],[852,856,[0.0,-97.92]],[860,863,[0.0,-97.92]],[856,857,[0.0,-97.92]],[863,857,[0.0,-97.92]],[624,857,null],[624,858,null],[858,859,null],[859,864,null],[864,617,null],[855,865,null],[865,601,null],[440,6702,null],[6702,6703,null],[6703,6704,null],[440,6705,null],[6705,6706,null],[6706,6707,null]]}
```
