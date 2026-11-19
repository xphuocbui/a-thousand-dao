import math
from celllib import road

THEME = 'water'


def q(c, r, a):
    """Point on a figure's orbit; angles run from +x toward +y."""
    a = math.radians(a)
    return (c[0] + r * math.cos(a), c[1] + r * math.sin(a))


class Piece:
    def __init__(self):
        self.nodes = {}
        self.links = []

    def node(self, key, xy, kind='small'):
        self.nodes[key] = (xy, kind)
        return key

    def xy(self, key):
        return road(key) if isinstance(key, int) else self.nodes[key][0]

    def link(self, a, b, centre=None):
        self.links.append((a, b, centre))

    def orbit(self, prefix, centre, radius, angles, notables=()):
        keys = []
        for i, a in enumerate(angles):
            key = self.node(prefix + str(i), q(centre, radius, a),
                            'notable' if a in notables else 'small')
            if keys:
                self.link(keys[-1], key, centre)
            keys.append(key)
        return keys

    def curve(self, prefix, a, b, sag, steps):
        """Divide a circular arc into equal steps. Sag is signed across its chord."""
        x, y = self.xy(a)
        X, Y = self.xy(b)
        dx, dy = X - x, Y - y
        d = math.hypot(dx, dy)
        h = (sag * sag - d * d / 4) / (2 * sag)
        cx = (x + X) / 2 - h * dy / d
        cy = (y + Y) / 2 + h * dx / d
        ux, uy = x - cx, y - cy
        vx, vy = X - cx, Y - cy
        radius = math.hypot(ux, uy)
        start = math.atan2(uy, ux)
        sweep = math.atan2(ux * vy - uy * vx, ux * vx + uy * vy)
        previous = a
        interior = []
        for i in range(1, steps):
            angle = start + sweep * i / steps
            key = self.node(prefix + str(i),
                            (cx + radius * math.cos(angle),
                             cy + radius * math.sin(angle)))
            self.link(previous, key, (cx, cy))
            interior.append(key)
            previous = key
        self.link(previous, b, (cx, cy))
        return interior

    def graph(self):
        return self.nodes, self.links


def curling_tide():
    p = Piece()
    c = (-72.5, -64.0)
    radius = 9.3
    back = p.orbit('swell_', c, radius, range(37, 278, 20), (197,))
    p.curve('approach_', 452, back[0], 1.8, 5)

    trough = p.orbit('undertow_', c, 6.4, range(77, 158, 20), (117,))
    p.link(back[2], trough[0])
    p.link(back[6], trough[-1])

    # The crest, hook and eye share a tangent at each handoff.
    hook_c = q(c, radius - 4.6, 277)
    hook = p.orbit('hook_', hook_c, 4.6, range(301, 398, 24))
    p.link(back[-1], hook[0], hook_c)
    eye_c = q(hook_c, 4.6 - 2.15, 397)
    eye = p.orbit('eye_', eye_c, 2.15, range(433, 542, 36), (541,))
    p.link(hook[-1], eye[0], eye_c)

    for i, root, r, entry, angles in (
        (0, back[10], 6.9, 210, (228.5, 247, 265.5, 284)),
        (1, back[11], 5.1, 231, (253, 275, 297, 319)),
    ):
        foam_c = q(p.xy(root), r, entry + 180)
        finger = p.orbit('foam_' + str(i) + '_', foam_c, r,
                         angles, (angles[-1],))
        p.link(root, finger[0], foam_c)
    return p.graph()


def hanging_eave():
    p = Piece()

    # Fix both ends in map coordinates on the east side of the 216-degree road.
    # One shallow circle supplies all six bays of the eave.
    west = p.node('lip_west', (-51.2, -79.2))
    east = p.node('lip_east', (-41.4, -79.2))
    ledge = [west] + p.curve('lip_', west, east, -0.86, 6) + [east]
    p.curve('feed_', 1321, west, -0.62, 3)

    # Each pendant takes two bays. Its sides bow inward to a common point.
    for i, xy in enumerate(((-49.42, -75.00),
                            (-46.18, -74.63),
                            (-43.15, -76.00))):
        tag = str(i)
        tip = p.node('tip_' + tag, xy, 'notable')
        p.curve('flank_w_' + tag + '_', ledge[2 * i], tip, -0.20, 2)
        p.curve('flank_e_' + tag + '_', ledge[2 * i + 2], tip, 0.20, 2)
    return p.graph()


def stellar_frost():
    p = Piece()
    c = (-40.45, -69.62)
    axes = tuple(145 + 60 * i for i in range(6))
    collar = p.orbit('collar_', c, 1.33, axes)
    p.link(collar[-1], collar[0], c)

    for i, a in enumerate(axes):
        tag = str(i)
        joint = p.node('joint_' + tag, q(c, 2.30, a))
        point = p.node('point_' + tag, q(c, 4.32, a), 'notable')
        p.link(collar[i], joint)
        p.link(joint, point)
        for label, sign in (('l', -1), ('r', 1)):
            stem = label + tag
            barb = p.node('barb_' + stem, q(c, 3.30, a + sign * 16))
            p.curve(stem + 'a_', joint, barb, sign * 0.10, 1)
            p.curve(stem + 'b_', barb, point, sign * 0.12, 1)
    p.curve('frostline_', 503, 'point_0', 0.28, 3)
    return p.graph()


def sector_plate():
    p = Piece()
    c = (-90.5, -51.7)
    corners = [p.node('corner_' + str(i), q(c, 4.4, 60 * i))
               for i in range(6)]
    collar = p.orbit('sector_', c, 2.04, range(30, 360, 60))
    p.link(collar[-1], collar[0], c)
    heart = p.node('heart', c, 'notable')
    for i in range(6):
        mid, = p.curve('facet_' + str(i) + '_', corners[i],
                       corners[(i + 1) % 6], -0.17, 2)
        p.link(mid, collar[i])
        p.link(collar[i], heart)
    p.curve('shelf_current_', 1815, corners[0], -0.55, 10)
    return p.graph()


def eddy_pearl():
    p = Piece()
    throat = p.node('throat', (-52.7, -62.25))
    pearl = p.node('pearl', (-57.05, -59.35), 'notable')
    p.curve('inlet_', 503, throat, 0.42, 2)
    p.curve('upper_', throat, pearl, 1.10, 2)
    p.curve('lower_', throat, pearl, -1.10, 2)
    return p.graph()


def rim_rime():
    p = Piece()
    sweep = p.orbit('rime_', road(675), 4.6, (168, 148, 128), (128,))
    p.link(675, sweep[0])
    return p.graph()


CELLS = {
    904: {
        # 2026-11-19: only the barbed star stays (user: "add the snowflake please"); the rest were removed
        'oai_stellar_frost': stellar_frost(),
    }
}
