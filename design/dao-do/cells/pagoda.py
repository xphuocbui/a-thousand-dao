import math
from celllib import road

THEME = 'earth'

# Work in (span, height), with height increasing outward along the mast.
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
    """Join existing endpoints on a circle with evenly spaced beads."""
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


def roof(figure, anchor, radius, pitch, reach, count, tip_pitch):
    """A broad roof orbit meets a tighter, tangent eave orbit."""
    start = math.radians(-pitch)
    end = math.radians(reach)
    step = (end - start) / count
    c = (-radius * math.sin(start),
         HEIGHT[anchor] + radius * math.cos(start))
    flat_count = count - 2
    last = anchor
    for i in range(1, flat_count + 1):
        key = f'tile_{i}'
        put(figure, key, orbit(c, radius, start + i * step - math.pi / 2))
        figure[1].append((last, key, c))
        last = key

    # Keep the original tier width while steepening the last two links.
    turn = start + flat_count * step
    finish = math.radians(tip_pitch)
    lip_r = radius * (math.sin(end) - math.sin(turn)) / (
        math.sin(finish) - math.sin(turn))
    h, z = point(figure, last)
    lip_c = (h - lip_r * math.sin(turn), z + lip_r * math.cos(turn))
    for i in (1, 2):
        key = f'tile_{flat_count + i}'
        angle = turn + i * (finish - turn) / 2
        put(figure, key, orbit(lip_c, lip_r, angle - math.pi / 2), i == 2)
        figure[1].append((last, key, lip_c))
        last = key


terrace = ({}, [])
roof(terrace, 501, 7.2, 40, 32, 6, 65)
put(terrace, 'foot', (4.4, HEIGHT[1490] + 1.88))
sweep(terrace, 1490, 'foot', -74, ('sill_inner', 'sill_outer'))
sweep(terrace, 'foot', 'tile_3', 52, ('seal_pillar',))
sweep(terrace, 'sill_outer', 'tile_2', -60, ('inset_pier',))
put(terrace, 'seal_pillar', point(terrace, 'seal_pillar'), True)

# A balcony sill and two uprights frame the middle storey.
gallery = ({}, [])
roof(gallery, 404, 6.3, 38, 26, 5, 61)
put(gallery, 'balcony_corner', (3.89, HEIGHT[501] - 0.27))
sweep(gallery, 501, 'balcony_corner', -36, ('balcony_step', 'balcony_sill'))
sweep(gallery, 'balcony_corner', 'tile_3', 24,
      ('outer_column', 'bronze_capital'))
sweep(gallery, 'balcony_sill', 'tile_2', -24, ('inner_column', 'transom'))
put(gallery, 'bronze_capital', point(gallery, 'bronze_capital'), True)

# The upper wall tapers from its sill into a tall, narrow doorway.
cloud_gate = ({}, [])
roof(cloud_gate, 1227, 4.9, 37, 23, 4, 59)
put(cloud_gate, 'foot', (3.15, HEIGHT[404] + 0.13))
sweep(cloud_gate, 404, 'foot', -28, ('threshold',))
sweep(cloud_gate, 'foot', 'tile_2', 28, ('jade_jamb',))
sweep(cloud_gate, 'threshold', 'tile_2', -44, ('inner_arch',))
put(cloud_gate, 'jade_jamb', point(cloud_gate, 'jade_jamb'), True)

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
                # Keep the centre on the exact bisector of a rounded road point.
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
    ('bronze_bell_storey', gallery),
    ('cloud_gate_roof', cloud_gate),
    ('jade_spire', spire),
):
    for suffix, side in (('east', 1), ('west', -1)):
        CELLS[902][f'{name}_{suffix}'] = place(figure, side)

CELLS[902]['immortal_pearl'] = place(pearl, 1)
