```python
import math
from celllib import road

THEME = 'chaos'


def polar(r, a):
    t = math.radians(a)
    return r * math.sin(t), r * math.cos(t)


def centre(a, b, turn):
    """Centre for the signed polar turn from a to b."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    k = 0.5 / math.tan(math.radians(turn) / 2)
    return (a[0] + b[0]) / 2 + k * dy, (a[1] + b[1]) / 2 - k * dx


def swing(c, p, angle):
    t = math.radians(angle)
    s, q = math.sin(t), math.cos(t)
    x, y = p[0] - c[0], p[1] - c[1]
    return c[0] + q * x + s * y, c[1] + q * y - s * x


def lay_arc(nodes, links, start, point, c, turn, stations, prefix,
            notables=(), end=None):
    previous = start
    keys = []
    for i, f in enumerate(stations, 1):
        key = f'{prefix}{i}'
        kind = 'notable' if i in notables else 'small'
        nodes[key] = swing(c, point, turn * f), kind
        links.append((previous, key, c))
        previous = key
        keys.append(key)
    if end is not None:
        links.append((previous, end, c))
    return keys


def outer_current(rim, spoke):
    nodes, links = {}, []
    a, b = road(rim), road(spoke)
    c = centre(a, b, 50)
    # A slightly longer first step lets the shallow arc clear the rim.
    stations = [0.14 + 0.86 * i / 7 for i in range(7)]
    spine = lay_arc(nodes, links, rim, a, c, 50, stations, 's',
                     notables=(4,), end=spoke)

    # A counter-arc closes the eye on the inward side of the sweep.
    u, v = spine[2], spine[5]
    p, q = nodes[u][0], nodes[v][0]
    chord = math.hypot(q[0] - p[0], q[1] - p[1])
    turn = -math.degrees(4 * math.atan(2 * 1.04 / chord))
    lay_arc(nodes, links, u, p, centre(p, q, turn), turn,
            (1 / 3, 2 / 3), 'e', notables=(2,), end=v)
    return nodes, links


def inward_current(spoke, root):
    nodes, links = {}, []
    a, b = road(spoke), road(root)
    lay_arc(nodes, links, spoke, a, centre(a, b, 95), 95,
            [i / 7 for i in range(1, 7)], 'n', notables=(3,), end=root)
    return nodes, links


def eddy(anchor, radius, phase, step):
    nodes, links = {}, []
    a = road(anchor)
    bearing = math.degrees(math.atan2(a[0], a[1]))
    dx, dy = polar(radius, bearing + phase)
    c = a[0] - dx, a[1] - dy
    lay_arc(nodes, links, anchor, a, c, step, (1, 2, 3),
            'n', notables=(3,))
    return nodes, links


# cell, inner axis, entering spoke, leaving spoke, leading rim, trailing rim
WEDGES = (
    (79, 9, 34, 35, 24, 26),
    (80, 3, 31, 32, 12, 14),
    (81, 5, 32, 33, 16, 18),
    (82, 7, 33, 34, 20, 22),
    (83, 1, 35, 31, 28, 30),
)

CELLS = {}
for cell, root, inlet, outlet, lead, trail in WEDGES:
    CELLS[cell] = {
        'Eye of the Primordial Current': outer_current(lead, outlet),
        'Descent to the Lower Dantian': inward_current(inlet, root),
        'Reflux at the Meridian': eddy(inlet, 1.95, 161, -38),
        'Turning Breath': eddy(root, 2.85, 142, -25),
        'Rimward Exhalation': eddy(trail, 2.90, 22, 25),
    }
```

Five rim sweeps hand off to inward arcs at shared spoke nodes, so the hub reads as one spiral. A narrow lens opens inside each sweep, while three smaller eddies fill the gaps without competing with the inward flow.