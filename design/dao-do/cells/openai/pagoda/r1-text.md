```python
import math
from celllib import road

THEME = 'earth'

# Work in (span, height): height runs out along the mast.
AXIS = math.radians(72)
U = (math.sin(AXIS), math.cos(AXIS))
V = (U[1], -U[0])
HEIGHT = {i: sum(a * b for a, b in zip(road(i), U))
          for i in (1490, 501, 404, 1227, 1228)}


def point(figure, key):
    if isinstance(key, int):
        return (0.0, HEIGHT[key])
    return figure[0][key][0]


def put(figure, key, p, notable=False):
    figure[0][key] = (p, 'notable' if notable else 'small')


def orbit(c, r, angle):
    return (c[0] + r * math.cos(angle), c[1] + r * math.sin(angle))


def sweep(figure, a, b, degrees, beads):
    """Join two existing endpoints on a circle with evenly spaced beads."""
    p, q = point(figure, a), point(figure, b)
    dx, dy = q[0] - p[0], q[1] - p[1]
    angle = math.radians(degrees)
    t = 0.5 / math.tan(angle / 2)
    c = ((p[0] + q[0]) / 2 - dy * t, (p[1] + q[1]) / 2 + dx * t)
    r = math.hypot(p[0] - c[0], p[1] - c[1])
    start = math.atan2(p[1] - c[1], p[0] - c[0])
    last = a
    for i, key in enumerate(beads, 1):
        put(figure, key, orbit(c, r, start + angle * i / (len(beads) + 1)))
        figure[1].append((last, key, c))
        last = key
    figure[1].append((last, b, c))


def roof(figure, anchor, radius, pitch, lift, count):
    """One pitched roof orbit: descend from the mast, then turn up at the lip."""
    start = math.radians(-90 - pitch)
    step = math.radians(pitch + lift) / count
    c = (-radius * math.cos(start), HEIGHT[anchor] - radius * math.sin(start))
    last = anchor
    for i in range(1, count + 1):
        key = f'tile_{i}'
        put(figure, key, orbit(c, radius, start + i * step), i == count)
        figure[1].append((last, key, c))
        last = key


terrace = ({}, [])
roof(terrace, 501, 7.2, 40, 32, 6)
put(terrace, 'foot', (4.4, HEIGHT[1490] + 1.88))
sweep(terrace, 1490, 'foot', -74, ('sill_inner', 'sill_outer'))
sweep(terrace, 'foot', 'tile_3', 52, ('seal_pillar',))
sweep(terrace, 'sill_outer', 'tile_2', -60, ('inset_pier',))
put(terrace, 'seal_pillar', point(terrace, 'seal_pillar'), True)

# A low balcony tucked between the first two roof orbits.
gallery = ({}, [])
c = (2.95, HEIGHT[501] + 0.91)
for i in range(6):
    put(gallery, f'bell_{i}', orbit(c, 1.05, math.radians(-150 + 60 * i)), i == 3)
    gallery[1].append((f'bell_{i}', f'bell_{(i + 1) % 6}', c))
sweep(gallery, 501, 'bell_0', -16, ('balcony_step',))

middle_eave = ({}, [])
roof(middle_eave, 404, 6.3, 38, 26, 5)

# The top storey has a narrow arched opening cut into its supporting wall.
cloud_gate = ({}, [])
roof(cloud_gate, 1227, 4.9, 37, 23, 4)
sweep(cloud_gate, 404, 'tile_2', 63, ('jamb', 'pier', 'lintel'))
sweep(cloud_gate, 'jamb', 'lintel', -100, ('inner_arch',))
put(cloud_gate, 'lintel', point(cloud_gate, 'lintel'), True)

spire = ({}, [])
put(spire, 'shoulder', (2.0, HEIGHT[1227] + 1.72), True)
sweep(spire, 1227, 'shoulder', 60, ('collar', 'lower_flank'))
sweep(spire, 'shoulder', 1228, 88, ('upper_flank', 'neck'))

pearl = ({}, [])
top = HEIGHT[1228]
put(pearl, 'stem', (0.0, top + 1.10))
c = (0.0, top + 3.34)
rim = ('socket', 'right_facet', 'pearl_tip', 'left_facet')
for i, key in enumerate(rim):
    put(pearl, key, orbit(c, 1.22, math.radians(-90 + 90 * i)), i == 2)
    pearl[1].append((key, rim[(i + 1) % 4], c))
pearl[1].extend(((1228, 'stem', None), ('stem', 'socket', None)))


def place(figure, side):
    def world(p):
        h, z = p
        return (z * U[0] + side * h * V[0], z * U[1] + side * h * V[1])

    nodes = {k: (world(p), kind) for k, (p, kind) in figure[0].items()}
    links = []
    for a, b, c in figure[1]:
        if c is not None:
            c = world(c)
            if isinstance(a, int) or isinstance(b, int):
                # Preserve the exact bisector even if a road point was rounded.
                p = road(a) if isinstance(a, int) else nodes[a][0]
                q = road(b) if isinstance(b, int) else nodes[b][0]
                dx, dy = q[0] - p[0], q[1] - p[1]
                mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
                t = ((mx - c[0]) * dx + (my - c[1]) * dy) / (dx * dx + dy * dy)
                c = (c[0] + t * dx, c[1] + t * dy)
        links.append((a, b, c))
    return nodes, links


CELLS = {902: {}}
for name, figure in (
    ('earth_seal_terrace', terrace),
    ('bronze_bell_gallery', gallery),
    ('folded_tile_eave', middle_eave),
    ('cloud_gate_roof', cloud_gate),
    ('jade_spire', spire),
):
    for suffix, side in (('east', 1), ('west', -1)):
        CELLS[902][f'{name}_{suffix}'] = place(figure, side)

CELLS[902]['immortal_pearl'] = place(pearl, 1)
```

Three narrowing roofs turn up at their notable tips. A double-bay plinth, a round bell balcony, and an arched upper gate fill the spaces between them; the mirrored spire closes around the mast beneath a single pearl finial.