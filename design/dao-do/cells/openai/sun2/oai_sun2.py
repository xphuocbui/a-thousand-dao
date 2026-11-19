import math
from celllib import road

THEME = 'island'
SUN = (0.0, 112.0)


def polar(c, r, angle):
    t = math.radians(angle)
    return (c[0] + r * math.sin(t), c[1] + r * math.cos(t))


def bearing(c, p):
    return math.degrees(math.atan2(p[0] - c[0], p[1] - c[1]))


def local(axis, u, v):
    # v is radial; u points in the direction of the wheel's turn.
    return polar(polar(SUN, v, axis), u, axis + 90)


def bow(p, q, sag):
    dx, dy = q[0] - p[0], q[1] - p[1]
    length = math.hypot(dx, dy)
    offset = sag / 2 - length * length / (8 * sag)
    return ((p[0] + q[0]) / 2 - offset * dy / length,
            (p[1] + q[1]) / 2 + offset * dx / length)


def inner(angle):
    return 521 + (angle // 45) % 8


def outer(angle):
    return 529 + (angle // 18) % 20


class Figure:
    def __init__(self):
        self.nodes = {}
        self.links = []

    def node(self, key, point, notable=False):
        self.nodes[key] = (point, 'notable' if notable else 'small')
        return key

    def point(self, key):
        return road(key) if isinstance(key, int) else self.nodes[key][0]

    def arc(self, a, b, sag, fractions, prefix, notable_at=()):
        p, q = self.point(a), self.point(b)
        c = bow(p, q, sag)
        start = bearing(c, p)
        sweep = (bearing(c, q) - start + 180) % 360 - 180
        radius = math.hypot(p[0] - c[0], p[1] - c[1])
        beads = [
            self.node(f'{prefix}_{i}', polar(c, radius, start + t * sweep),
                      notable=(i in notable_at))
            for i, t in enumerate(fractions)
        ]
        keys = [a] + beads + [b]
        self.links.extend((p, q, c) for p, q in zip(keys, keys[1:]))
        return beads

    def piece(self):
        return self.nodes, self.links


def core_ember(axis):
    # The inner end of the longer swept spoke, inside the road ring.
    f = Figure()
    ember = f.node('ember', polar(SUN, 4.35, axis + 17), notable=True)
    f.arc(ember, inner(axis + 45), 0.18, (0.31, 0.63), 'bead')
    return f.piece()


def swept_spoke(axis, diagonal):
    f = Figure()
    if diagonal:
        # Leave a little extra room at the two road joins.
        steps = tuple(0.15 + 0.70 * i / 6 for i in range(7))
        f.arc(inner(axis + 45), outer(axis + 90), 1.15,
              steps, 'vane', notable_at=(3,))
    else:
        f.arc(inner(axis), outer(axis + 36), 1.20,
              tuple(i / 6 for i in range(1, 6)), 'vane', notable_at=(2,))
    return f.piece()


def corona_tooth(start, end, great):
    f = Figure()
    a, b = outer(start), outer(end)
    width = end - start
    end_axis = bearing(SUN, road(b))
    tip_radius, lead = (19.0, 6.0) if great else (17.2, 3.5)
    tip = f.node('flame_tip', polar(SUN, tip_radius, end_axis - lead),
                 notable=True)

    if great:
        # Two curved faces meet at an acute point. The inset vein
        # follows the turn without closing off the space under the tip.
        face = f.arc(a, tip, 2.15 if width == 54 else 1.65,
                     tuple(i / 7 for i in range(1, 7)), 'leading_face')
        f.arc(b, tip, 1.35, (0.25, 0.50, 0.75), 'trailing_face')
        inset_u = -4.0 - (width - 36) / 30
        ember = f.node('vein_ember', local(end_axis, inset_u, 16.65),
                       notable=True)
        f.arc(face[2], ember, -0.30, (0.50,), 'vein')
    else:
        f.arc(a, tip, 1.40 if width == 36 else 0.74,
              (1 / 3, 2 / 3), 'leading_face')
        f.arc(b, tip, 0.86, (1 / 3, 2 / 3), 'trailing_face')
    return f.piece()


pieces = {}
for quadrant, axis in enumerate(range(0, 360, 90)):
    pieces[f'core_ember_{quadrant}'] = core_ember(axis)
    pieces[f'short_vane_{quadrant}'] = swept_spoke(axis, False)
    pieces[f'long_vane_{quadrant}'] = swept_spoke(axis, True)

# Adjacent flames share their roots. The interval from 162 to 198
# stays open for the entrance spoke and its keystones.
for start, end, great in (
    (0, 36, False), (36, 90, True),
    (90, 126, False), (126, 162, True),
    (198, 216, False), (216, 270, True),
    (270, 306, False), (306, 360, True),
):
    rank = 'great' if great else 'lesser'
    pieces[f'{rank}_flame_{start:03d}'] = corona_tooth(start, end, great)

CELLS = {931: pieces}
