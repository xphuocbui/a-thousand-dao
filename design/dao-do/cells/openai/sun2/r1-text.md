```python
import math
from celllib import road

THEME = 'island'
SUN = (0.0, 112.0)


def polar(c, r, angle):
    t = math.radians(angle)
    return (c[0] + r * math.sin(t), c[1] + r * math.cos(t))


def local(axis, u, v):
    # u runs along the orbit; v runs outward from the Sun.
    return polar(polar(SUN, v, axis), u, axis + 90)


def bearing(c, p):
    return math.degrees(math.atan2(p[0] - c[0], p[1] - c[1]))


def normal(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    length = math.hypot(dx, dy)
    return -dy / length, dx / length, length


def bow(a, b, sag):
    # Circle through a and b with the given signed sagitta.
    nx, ny, length = normal(a, b)
    d = sag / 2 - length * length / (8 * sag)
    return ((a[0] + b[0]) / 2 + d * nx,
            (a[1] + b[1]) / 2 + d * ny)


def short_arc_point(c, a, b, fraction):
    start = bearing(c, a)
    sweep = (bearing(c, b) - start + 180) % 360 - 180
    return polar(c, math.hypot(a[0] - c[0], a[1] - c[1]),
                 start + fraction * sweep)


def vault(a, b, lift):
    # The increasing-angle sweep between these anchors faces outward.
    p, q = road(a), road(b)
    nx, ny, _ = normal(p, q)
    c = ((p[0] + q[0]) / 2 + lift * nx,
         (p[1] + q[1]) / 2 + lift * ny)
    r = math.hypot(p[0] - c[0], p[1] - c[1])
    start = bearing(c, p)
    sweep = (bearing(c, q) - start) % 360
    return c, r, start, sweep


class Figure:
    def __init__(self):
        self.nodes = {}
        self.links = []

    def node(self, key, point, notable=False):
        self.nodes[key] = (point, 'notable' if notable else 'small')
        return key

    def point(self, key):
        return self.nodes[key][0]

    def chain(self, keys, centre=None):
        self.links.extend((a, b, centre) for a, b in zip(keys, keys[1:]))

    def piece(self):
        return self.nodes, self.links


def inner_stamp(upper):
    f = Figure()
    axis, anchor = (135, 524) if upper else (45, 522)
    rim = f.node('rim', polar(SUN, 5.15, axis))
    f.chain([anchor, rim])
    for side in ((-1,) if upper else (-1, 1)):
        beads = [
            f.node(f'bead_{side}_{i}', polar(SUN, 5.15, axis + side * 13 * i),
                   notable=(i == 2))
            for i in (1, 2)
        ]
        f.chain([rim] + beads, SUN)
    return f.piece()


def suspended_mirror():
    f = Figure()
    axis = 45
    c = polar(SUN, 9.75, axis)
    ring = [
        f.node(f'mirror_{i}', polar(c, 1.9, axis + 45 * i),
               notable=(i in (0, 4)))
        for i in range(8)
    ]
    f.chain(ring + ring[:1], c)
    for side, anchor, socket in ((-1, 530, 7), (1, 533, 1)):
        rail = [
            f.node(f'rail_{side}_{i}', polar(SUN, 11.65, axis + side * offset))
            for i, offset in enumerate((27, 19.8, 12.6))
        ]
        f.chain([anchor, rail[0]])
        f.chain(rail, SUN)
        end = ring[socket]
        c_join = bow(f.point(rail[-1]), f.point(end), 0.10 * side)
        f.chain([rail[-1], end], c_join)
    return f.piece()


def casting_yoke():
    f = Figure()
    axis = 135
    root = f.node('root', polar(SUN, 8.0, axis))
    hub = f.node('hub', polar(SUN, 9.65, axis))
    f.chain([524, root, hub])
    for side in (-1, 1):
        arm = [
            f.node(f'arm_{side}_{i}', polar(SUN, 9.65, axis + side * offset))
            for i, offset in enumerate((10, 20))
        ]
        tip = f.node(f'tip_{side}', polar(SUN, 11.45, axis + side * 25.5),
                     notable=True)
        f.chain([hub] + arm, SUN)
        f.chain([arm[-1], tip],
                bow(f.point(arm[-1]), f.point(tip), -0.33 * side))
    return f.piece()


def split_corona():
    f = Figure()
    c, r, start, sweep = vault(530, 533, 0.30)
    shoulders = []
    for i, anchor in enumerate((530, 533)):
        arm = []
        for j, t in enumerate((0.13, 0.26, 0.40)):
            fraction = t if i == 0 else 1 - t
            arm.append(f.node(f'crown_{i}_{j}', polar(c, r, start + fraction * sweep),
                              notable=(j == 2)))
        f.chain([anchor] + arm, c)
        shoulders.append(arm[1])

    left, right = shoulders
    a, b = f.point(left), f.point(right)
    inset = bow(a, b, -1.30)
    beads = [
        f.node(f'inlay_{i}', short_arc_point(inset, a, b, i / 4),
               notable=(i == 2))
        for i in (1, 2, 3)
    ]
    f.chain([left] + beads + [right], inset)
    return f.piece()


def southern_crescent():
    f = Figure()
    c = polar(SUN, 18.9, 0)
    stem = f.node('stem', polar(SUN, 14.55, 0))
    heel = f.node('heel', polar(c, 2.8, 180))
    f.chain([529, stem, heel])
    for side in (-1, 1):
        arm = [
            f.node(f'lip_{side}_{i}', polar(c, 2.8, 180 + side * 26 * i),
                   notable=(i == 3))
            for i in (1, 2, 3)
        ]
        f.chain([heel] + arm, c)
    return f.piece()


def seamed_seal():
    f = Figure()
    axis = 90
    base_v, seam_v, tip_v, width = 15.67, 16.8, 18.65, 1.18
    mid = (base_v + tip_v) / 2
    half = (tip_v - base_v) / 2
    offset = (width**2 + (seam_v - mid)**2 - half**2) / (2 * width)

    stem = f.node('stem', local(axis, 0, 14.25))
    base = f.node('base', local(axis, 0, base_v))
    tip = f.node('finial', local(axis, 0, tip_v), notable=True)
    f.chain([534, stem, base])
    seam = []
    for side in (-1, 1):
        bead = f.node(f'seam_{side}', local(axis, side * width, seam_v))
        f.chain([base, bead, tip], local(axis, side * offset, mid))
        seam.append(bead)
    f.chain(seam, SUN)
    return f.piece()


def upper_arcade():
    f = Figure()
    c, r, start, sweep = vault(535, 536, 1.56)
    beads = [
        f.node(f'arch_{i}', polar(c, r, start + sweep * i / 6),
               notable=(i == 3))
        for i in range(1, 6)
    ]
    f.chain([535] + beads + [536], c)
    return f.piece()


def gate_flare():
    f = Figure()
    tangent = 162 + 90
    r = 4.4
    c = polar(road(538), -r, tangent)
    beads = [
        f.node(f'flare_{i}', polar(c, r, tangent - 25 * i), notable=(i == 4))
        for i in range(1, 5)
    ]
    f.chain([538] + beads, c)
    return f.piece()


def reflect(piece):
    def point(p):
        return -p[0], p[1]

    def endpoint(key):
        if not isinstance(key, int):
            return key
        base, count = (521, 8) if key < 529 else (529, 20)
        return base + (base - key) % count

    nodes, links = piece
    return (
        {key: (point(p), kind) for key, (p, kind) in nodes.items()},
        [(endpoint(a), endpoint(b), None if c is None else point(c))
         for a, b, c in links],
    )


pieces = {'southern_crescent': southern_crescent()}
for name, piece in (
    ('inner_stamp', inner_stamp(False)),
    ('inner_glint', inner_stamp(True)),
    ('suspended_mirror', suspended_mirror()),
    ('casting_yoke', casting_yoke()),
    ('split_corona', split_corona()),
    ('seamed_seal', seamed_seal()),
    ('upper_arcade', upper_arcade()),
    ('gate_flare', gate_flare()),
):
    pieces[name + '_east'] = piece
    pieces[name + '_west'] = reflect(piece)

CELLS = {931: pieces}
```

The 114-node layout takes its cues from a cast bronze sun mirror. The suspended mirrors and split crowns share road anchors across the lower rim, while the upper arcs peel away from the entrance to leave the keystones clear.