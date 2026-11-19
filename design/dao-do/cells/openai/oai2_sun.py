import math
from celllib import road

THEME = 'island'
CELLS = {931: {}}
O = (0.0, 112.0)


def Q(c, r, angle):
    t = math.radians(angle)
    return (c[0] + r * math.sin(t), c[1] + r * math.cos(t))


def heading(anchor):
    x, y = road(anchor)
    return math.degrees(math.atan2(x - O[0], y - O[1]))


def ray_point(anchor, radius, sideways=0.0):
    t = heading(anchor)
    return Q(Q(O, radius, t), sideways, t + 90.0)


def bow_center(a, b, rise):
    # Signed sagitta, measured along the perpendicular to the chord.
    dx, dy = b[0] - a[0], b[1] - a[1]
    length = math.hypot(dx, dy)
    offset = (rise * rise - length * length / 4.0) / (2.0 * rise)
    return ((a[0] + b[0]) / 2.0 - offset * dy / length,
            (a[1] + b[1]) / 2.0 + offset * dx / length)


class Piece:
    def __init__(self, name):
        self.nodes = {}
        self.links = []
        CELLS[931][name] = (self.nodes, self.links)

    def point(self, key, xy, kind='small'):
        self.nodes[key] = (xy, kind)

    def xy(self, key):
        return road(key) if isinstance(key, int) else self.nodes[key][0]

    def chain(self, *keys, center=None):
        self.links.extend((a, b, center) for a, b in zip(keys, keys[1:]))

    def divide_arc(self, a, b, center, marks):
        ax, ay = self.xy(a)
        bx, by = self.xy(b)
        cx, cy = center
        start = math.atan2(ay - cy, ax - cx)
        end = math.atan2(by - cy, bx - cx)
        turn = (end - start + math.pi) % (2.0 * math.pi) - math.pi
        r = math.hypot(ax - cx, ay - cy)
        keys = [a]
        for i, kind in enumerate(marks, 1):
            t = start + turn * i / (len(marks) + 1)
            key = '{}_{}_{}'.format(a, b, i)
            self.point(key, (cx + r * math.cos(t), cy + r * math.sin(t)), kind)
            keys.append(key)
        self.chain(*keys, b, center=center)

    def bow(self, a, b, rise, marks=()):
        self.divide_arc(a, b, bow_center(self.xy(a), self.xy(b), rise), marks)


def needle(name, anchor, radius, sweep, rise):
    p = Piece(name)
    p.point('tip', Q(O, radius, heading(anchor) + sweep), 'notable')
    p.bow(anchor, 'tip', rise, ('small', 'small'))


def split_ray(name, anchor, root_radius, tip_radius, width, rise, jointed):
    p = Piece(name)
    p.point('foot', ray_point(anchor, 14.24))
    p.point('split', ray_point(anchor, root_radius))
    p.chain(anchor, 'foot', 'split')
    for side, key in ((-1, 'left_tip'), (1, 'right_tip')):
        p.point(key, ray_point(anchor, tip_radius, side * width), 'notable')
        p.bow('split', key, side * rise, ('small',) if jointed else ())


def lentil(name, anchor):
    p = Piece(name)
    p.point('foot', ray_point(anchor, 14.25))
    p.point('tip', ray_point(anchor, 17.95), 'notable')
    p.chain(anchor, 'foot')
    # Reversing the endpoints flips the bow and gives its nodes distinct keys.
    p.bow('foot', 'tip', 1.06, ('small', 'small'))
    p.bow('tip', 'foot', 1.06, ('small', 'small'))


def relay(name, inner, outer):
    # Arrive at the outer road on a radial tangent, in line with its next ray.
    a, b = road(inner), road(outer)
    tx, ty = Q((0.0, 0.0), 1.0, heading(outer) + 90.0)
    dx, dy = a[0] - b[0], a[1] - b[1]
    k = (dx * dx + dy * dy) / (2.0 * (dx * tx + dy * ty))
    center = (b[0] + k * tx, b[1] + k * ty)
    Piece(name).divide_arc(
        inner, outer, center, ('small', 'small', 'notable', 'small', 'small')
    )


def dawn_fan(name, anchor, mirror):
    p = Piece(name)
    t = heading(anchor)
    p.point('heel', Q(O, 7.62, t))
    p.point('split', Q(O, 8.72, t))
    p.chain(anchor, 'heel', 'split')

    # The middle ray leads; the two shorter rays end on a shared orbit.
    p.point('crest', Q(O, 11.88, t), 'notable')
    p.bow('split', 'crest', 0.10 * mirror, ('small', 'small'))
    for side, key in ((-1, 'left_tip'), (1, 'right_tip')):
        p.point(key, Q(O, 11.50, t + side * 11.5), 'notable')
        p.bow('split', key, -side * 0.28, ('small',))


split_ray('noon', 529, 15.60, 17.88, 1.26, 0.22, False)

for suffix, mirror, inner, outer, high, lens, early, flank, late in (
    ('east',  1, 522, 531, 524, 537, 533, 534, 535),
    ('west', -1, 528, 547, 526, 541, 545, 544, 543),
):
    relay('golden_meridian_' + suffix, inner, outer)
    split_ray('sunburst_' + suffix, outer, 15.42, 17.82, 1.38, 0.16, True)
    dawn_fan('dawn_fan_' + suffix, high, mirror)
    lentil('sealed_flame_' + suffix, lens)
    needle('lower_glint_' + suffix, early, 17.15, -4.6 * mirror, -0.23 * mirror)
    needle('long_glint_' + suffix, flank, 18.05, 0.0, 0.48 * mirror)
    needle('upper_glint_' + suffix, late, 17.15, 4.6 * mirror, 0.23 * mirror)

needle('sky_glint_east', 538, 16.80, -4.0, -0.22)
needle('sky_glint_west', 540, 16.80, 4.0, 0.22)
