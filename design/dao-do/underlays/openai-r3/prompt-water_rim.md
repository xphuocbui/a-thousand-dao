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

## This region: Water's rim (cell 904), THEME = 'water'

Beyond the Water land's outer ring of roads (radius 74.3) lies its rim. The part you design is the band between radius
75.5 and 109.0 and polar angle 206.5 to 243.0 degrees (shaded in the image; P(r, th) as above). It is mostly empty:
keep clear of the pieces already there (grey: a lotus, the Water land's figures across the ring, water drops, keystones
and Thunder's bolts at its far side). The art director wants a few BIG clusters (9+ nodes each) here, on water and ice:
- WAVES in the manner of an Asian painted wave (Hokusai's Great Wave, Chinese wave patterns): a crest rising and
  curling over into a spiral eye, clawed fingers of foam on its lip, and/or the nested fish-scale arcs of seigaiha;
  built from arcs round their own centres;
- ICICLES (ice cones): an earlier attempt "looked weird"; design a cluster that reads clearly as icicles hanging from a
  ledge or an icy eave, elegant and built on the orbit grammar;
- SNOWFLAKES: hexagonal, six-fold symmetric, but each one different (plate, stellar dendrite, sector plate...).
Two to five big clusters in all, plus small ones to bind them if you like. Hang pieces ONLY from road nodes marked
free_to_hang_from = true (cyan in the image); a piece may hang from one or two of them; long stems are fine where the
space is far from a free node. Name every piece with the prefix 'oai_'. CELLS = {904: {...}}.

Region data (map units; +y down):
```json
{"cell":904,"theme":"water","region":"the band of the rim between radius 75.5 and 109.0 and polar angle 206.5 to 243.0 degrees","road_nodes [id,x,y,free_to_hang_from]":[[452,-49.374,-67.957,true],[503,-46.993,-64.68,true],[671,-40.365,-103.018,true],[672,-44.47,-101.314,true],[673,-48.503,-99.446,true],[675,-46.556,-95.455,true],[676,-44.61,-91.464,true],[677,-42.663,-87.472,false],[678,-40.716,-83.481,false],[1321,-52.313,-72.002,true],[1322,-55.252,-76.048,false],[1500,-40.734,-56.065,false],[1501,-43.672,-60.11,false],[1806,-40.792,-62.1,true],[1814,-51.613,-53.447,false],[1815,-49.233,-55.647,true],[1816,-46.456,-57.986,false]],"road_links [a,b,arc_centre_or_null]":[[503,452,null],[671,672,[0.0,0.0]],[672,673,[0.0,0.0]],[673,675,null],[675,676,null],[676,677,null],[677,678,null],[452,1321,null],[1321,1322,null],[1500,1501,null],[1501,503,null],[1806,1501,[0.0,0.0]],[1814,1815,[0.0,0.0]],[1815,1816,[0.0,0.0]],[1816,1501,[0.0,0.0]]],"fixed_nodes_never_link [id,x,y,kind]":[],"pieces_to_keep_clear nodes [x,y,kind,piece]":[[-42.07,-59.983,"small","c11 axis_ripple_a"],[-40.956,-59.521,"small","c11 axis_ripple_a"],[-40.344,-58.483,"small","c11 axis_ripple_a"],[-40.481,-57.284,"notable","c11 axis_ripple_a"],[-51.008,-50.459,"notable","c17 koi_a"],[-49.531,-51.793,"small","c17 koi_b"],[-47.969,-51.85,"small","c17 koi_b"],[-46.656,-51.001,"small","c17 koi_b"],[-47.542,-50.268,"small","c17 koi_b"],[-40.432,-51.577,"small","c17 lotus_petal"],[-40.166,-53.256,"small","c17 lotus_petal"],[-41.943,-52.677,"notable","c17 lotus_petal"],[-47.048,-56.469,"small","c17 meander"],[-47.393,-55.53,"small","c17 meander"],[-46.753,-54.762,"notable","c17 meander"],[-45.768,-54.932,"small","c17 meander"],[-44.782,-55.102,"small","c17 meander"],[-44.142,-54.334,"notable","c17 meander"],[-44.488,-53.396,"small","c17 meander"],[-44.833,-52.457,"small","c17 meander"],[-44.193,-51.689,"small","c17 meander"],[-43.207,-51.859,"notable","c17 meander"],[-51.398,-52.12,"small","c17 koi_current"],[-52.238,-50.892,"small","c17 koi_current"],[-44.047,-58.547,"small","c17 axis_ripple_b"],[-43.952,-57.345,"small","c17 axis_ripple_b"],[-43.153,-56.442,"small","c17 axis_ripple_b"],[-41.971,-56.202,"notable","c17 axis_ripple_b"],[-58.857,-52.995,"keystone","c904 keystone_hook"],[-59.543,-81.953,"notable","c904 lotus"],[-58.602,-80.659,"small","c904 lotus"],[-59.156,-78.274,"small","c904 lotus"],[-56.016,-77.099,"small","c904 lotus"],[-60.193,-80.492,"small","c904 lotus"],[-62.536,-79.779,"small","c904 lotus"],[-61.983,-76.472,"notable","c904 lotus"],[-61.134,-81.786,"small","c904 lotus"],[-62.923,-83.458,"small","c904 lotus"],[-65.51,-81.326,"notable","c904 lotus"],[-60.483,-83.248,"small","c904 lotus"],[-59.929,-85.633,"small","c904 lotus"],[-63.069,-86.808,"notable","c904 lotus"],[-58.892,-83.415,"small","c904 lotus"],[-56.549,-84.128,"small","c904 lotus"],[-57.102,-87.435,"notable","c904 lotus"],[-57.951,-82.121,"small","c904 lotus"],[-56.163,-80.448,"small","c904 lotus"],[-53.575,-82.581,"notable","c904 lotus"],[-45.284,-87.361,"small","c904 water_drops"],[-47.372,-87.613,"small","c904 water_drops"],[-48.651,-89.895,"small","c904 water_drops"],[-49.959,-88.003,"small","c904 water_drops"],[-50.251,-89.603,"notable","c904 water_drops"],[-51.636,-90.161,"small","c904 water_drops"],[-52.926,-91.337,"small","c904 water_drops"],[-53.341,-89.791,"small","c904 water_drops"],[-53.906,-90.772,"notable","c904 water_drops"],[-55.584,-91.781,"notable","c904 water_drops"],[-98.463,-50.803,"notable","c932 bolt_out_chain"]],"pieces_to_keep_clear links [[x,y],[x,y],arc_centre_or_null]":[[[-43.672,-60.11],[-42.07,-59.983],null],[[-42.07,-59.983],[-40.956,-59.521],[-42.203,-58.087]],[[-40.956,-59.521],[-40.344,-58.483],[-42.203,-58.087]],[[-40.344,-58.483],[-40.481,-57.284],[-42.203,-58.087]],[[-51.251,-49.135],[-51.008,-50.459],[-48.659,-49.343]],[[-51.613,-53.447],[-49.531,-51.793],null],[[-49.531,-51.793],[-47.969,-51.85],[-48.659,-49.343]],[[-47.969,-51.85],[-46.656,-51.001],[-48.659,-49.343]],[[-46.656,-51.001],[-46.068,-49.552],[-48.659,-49.343]],[[-47.969,-51.85],[-47.542,-50.268],[-46.02,-51.527]],[[-47.542,-50.268],[-46.068,-49.552],[-46.02,-51.527]],[[-38.782,-52.176],[-40.432,-51.577],[-39.969,-52.874]],[[-40.432,-51.577],[-41.943,-52.677],[-40.523,-53.04]],[[-38.782,-52.176],[-40.166,-53.256],[-40.127,-51.88]],[[-40.166,-53.256],[-41.943,-52.677],[-40.705,-51.893]],[[-46.456,-57.986],[-47.048,-56.469],null],[[-47.048,-56.469],[-47.393,-55.53],[-46.408,-55.701]],[[-47.393,-55.53],[-46.753,-54.762],[-46.408,-55.701]],[[-46.753,-54.762],[-45.768,-54.932],[-46.408,-55.701]],[[-45.768,-54.932],[-44.782,-55.102],[-45.128,-54.164]],[[-44.782,-55.102],[-44.142,-54.334],[-45.128,-54.164]],[[-44.142,-54.334],[-44.488,-53.396],[-45.128,-54.164]],[[-44.488,-53.396],[-44.833,-52.457],[-43.847,-52.627]],[[-44.833,-52.457],[-44.193,-51.689],[-43.847,-52.627]],[[-44.193,-51.689],[-43.207,-51.859],[-43.847,-52.627]],[[-51.613,-53.447],[-51.398,-52.12],null],[[-51.398,-52.12],[-52.238,-50.892],[-48.659,-49.343]],[[-52.238,-50.892],[-52.558,-49.439],[-48.659,-49.343]],[[-43.672,-60.11],[-44.047,-58.547],null],[[-44.047,-58.547],[-43.952,-57.345],[-42.203,-58.087]],[[-43.952,-57.345],[-43.153,-56.442],[-42.203,-58.087]],[[-43.153,-56.442],[-41.971,-56.202],[-42.203,-58.087]],[[-55.216,-49.716],[-58.857,-52.995],null],[[-55.252,-76.048],[-56.016,-77.099],null],[[-59.543,-81.953],[-60.193,-80.492],null],[[-59.543,-81.953],[-60.483,-83.248],null],[[-59.543,-81.953],[-57.951,-82.121],null],[[-58.602,-80.659],[-60.193,-80.492],[-59.543,-81.953]],[[-58.602,-80.659],[-59.156,-78.274],[-61.221,-80.01]],[[-59.156,-78.274],[-60.193,-80.492],[-57.497,-80.401]],[[-56.163,-80.448],[-56.016,-77.099],[-59.377,-78.63]],[[-56.016,-77.099],[-59.156,-78.274],[-56.433,-80.769]],[[-60.193,-80.492],[-61.134,-81.786],[-59.543,-81.953]],[[-60.193,-80.492],[-62.536,-79.779],[-62.065,-82.435]],[[-62.536,-79.779],[-61.134,-81.786],[-59.864,-79.406]],[[-59.156,-78.274],[-61.983,-76.472],[-62.338,-80.148]],[[-61.983,-76.472],[-62.536,-79.779],[-59.014,-78.668]],[[-61.134,-81.786],[-60.483,-83.248],[-59.543,-81.953]],[[-61.134,-81.786],[-62.923,-83.458],[-60.387,-84.378]],[[-62.923,-83.458],[-60.483,-83.248],[-61.91,-80.958]],[[-62.536,-79.779],[-65.51,-81.326],[-62.504,-83.472]],[[-65.51,-81.326],[-62.923,-83.458],[-62.123,-79.853]],[[-60.483,-83.248],[-58.892,-83.415],[-59.543,-81.953]],[[-60.483,-83.248],[-59.929,-85.633],[-57.865,-83.897]],[[-59.929,-85.633],[-58.892,-83.415],[-61.588,-83.506]],[[-62.923,-83.458],[-63.069,-86.808],[-59.708,-85.277]],[[-63.069,-86.808],[-59.929,-85.633],[-62.652,-83.138]],[[-58.892,-83.415],[-57.951,-82.121],[-59.543,-81.953]],[[-58.892,-83.415],[-56.549,-84.128],[-57.02,-81.472]],[[-56.549,-84.128],[-57.951,-82.121],[-59.221,-84.501]],[[-59.929,-85.633],[-57.102,-87.435],[-56.747,-83.759]],[[-57.102,-87.435],[-56.549,-84.128],[-60.072,-85.239]],[[-57.951,-82.121],[-58.602,-80.659],[-59.543,-81.953]],[[-57.951,-82.121],[-56.163,-80.448],[-58.699,-79.528]],[[-56.163,-80.448],[-58.602,-80.659],[-57.176,-82.949]],[[-56.549,-84.128],[-53.575,-82.581],[-56.582,-80.435]],[[-53.575,-82.581],[-56.163,-80.448],[-56.962,-84.054]],[[-42.663,-87.472],[-45.284,-87.361],null],[[-45.284,-87.361],[-47.372,-87.613],null],[[-47.372,-87.613],[-48.651,-89.895],null],[[-47.372,-87.613],[-49.959,-88.003],null],[[-48.651,-89.895],[-50.251,-89.603],[-49.305,-88.949]],[[-49.959,-88.003],[-50.251,-89.603],[-49.305,-88.949]],[[-51.636,-90.161],[-52.926,-91.337],null],[[-51.636,-90.161],[-53.341,-89.791],null],[[-52.926,-91.337],[-53.906,-90.772],[-53.133,-90.564]],[[-53.341,-89.791],[-53.906,-90.772],[-53.133,-90.564]],[[-50.251,-89.603],[-51.636,-90.161],null],[[-53.906,-90.772],[-55.584,-91.781],null],[[-99.154,-49.971],[-98.463,-50.803],null]]}
```
