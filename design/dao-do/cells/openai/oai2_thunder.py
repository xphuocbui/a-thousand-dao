import math
from celllib import road

THEME = 'island'
CELLS = {932: {}}


def Q(c, r, a):
    # Clockwise from +x in the map's y-down frame.
    t = math.radians(a)
    return c[0] + r * math.cos(t), c[1] + r * math.sin(t)


def bearing(a, b):
    return math.degrees(math.atan2(b[1] - a[1], b[0] - a[0]))


def piece(name):
    p = ({}, [])
    CELLS[932][name] = p
    return p


def link(p, a, b, centre=None):
    p[1].append((a, b, centre))


def bead(p, key, centre, radius, angle, kind='small'):
    p[0][key] = (Q(centre, radius, angle), kind)


def orbit(p, keys, centre, radius, angles, notables=()):
    for key, angle in zip(keys, angles):
        bead(p, key, centre, radius, angle,
             'notable' if key in notables else 'small')
    for a, b in zip(keys, keys[1:]):
        link(p, a, b, centre)


def sweep(name, anchor, heading, radius, step, count):
    p = piece(name)
    quarter = 90 if step > 0 else -90
    centre = Q(road(anchor), radius, heading + quarter)
    start = heading - quarter
    keys = tuple(f's{i}' for i in range(count))
    angles = tuple(start + step * (i + 1) for i in range(count))
    orbit(p, keys, centre, radius, angles, (keys[-1],))
    link(p, anchor, keys[0], centre)


def fan(name, anchor, radius, heading, step):
    p = piece(name)
    keys = ('tip_l', 'left', 'root', 'right', 'tip_r')
    orbit(p, keys, road(anchor), radius,
          tuple(heading + i * step for i in range(-2, 3)),
          ('tip_l', 'tip_r'))
    link(p, anchor, 'root')


def circle_through(u, v, turn):
    half_chord = math.hypot(v[0] - u[0], v[1] - u[1]) / 2
    half_angle = math.radians(turn / 2)
    midpoint = ((u[0] + v[0]) / 2, (u[1] + v[1]) / 2)
    centre = Q(midpoint, half_chord / math.tan(half_angle),
               bearing(u, v) + 90)
    return centre, half_chord / abs(math.sin(half_angle)), bearing(centre, u)


def bow(name, a, b, turn, count):
    p = piece(name)
    c, r, start = circle_through(road(a), road(b), turn)
    keys = tuple(f'b{i}' for i in range(1, count + 1))
    angles = tuple(start + turn * i / (count + 1)
                   for i in range(1, count + 1))
    orbit(p, keys, c, r, angles)
    link(p, a, keys[0], c)
    link(p, keys[-1], b, c)
    return p, c, r, angles


def span(p, a, b, u, v, turn, edges, prefix):
    c, r, start = circle_through(u, v, turn)
    last = a
    for i in range(1, edges):
        key = f'{prefix}_{i}'
        bead(p, key, c, r, start + turn * i / edges)
        link(p, last, key, c)
        last = key
    link(p, last, b, c)


def discharge(name, a, b, knee, recoil, turns, tail_edges):
    # Each stroke flares away from its chord, recoils, then runs to the
    # next road vertex. The three spans are circular, including the recoil.
    p = piece(name)
    u, v = road(a), road(b)
    normal = bearing(u, v) + 90

    def offset(mark):
        t, distance = mark
        base = (u[0] + t * (v[0] - u[0]), u[1] + t * (v[1] - u[1]))
        return Q(base, distance, normal)

    k, r = offset(knee), offset(recoil)
    p[0]['knee'] = (k, 'notable')
    p[0]['recoil'] = (r, 'small')
    span(p, a, 'knee', u, k, turns[0], 3, 'lead')
    span(p, 'knee', 'recoil', k, r, turns[1], 1, 'fold')
    span(p, 'recoil', b, r, v, turns[2], tail_edges, 'tail')


# Upper outer cell: a closed seal inside two separated outer arcs.
p = piece('split_thunder_seal')
c = Q(road(577), 3.03, -90)
ring = tuple(f'r{i}' for i in range(8))
orbit(p, ring, c, 1.42, tuple(90 + i * 45 for i in range(8)))
link(p, 'r7', 'r0', c)
link(p, 577, 'r0')
for side, root, angle, step in (('west', 'r2', 180, 35),
                                ('east', 'r6', 360, -35)):
    foot, tip = side + '_foot', side + '_tip'
    orbit(p, (foot, tip), c, 2.60, (angle, angle + step), (tip,))
    link(p, root, foot)

sweep('gathering_charge', 587, -124, 3.10, 22, 4)
sweep('first_rumble', 578, 152, 3.80, -18, 3)

# Lower outer cell: a bridge with a second orbit through its middle.
p, c, r, angles = bow('returning_echo', 583, 584, 156, 5)
orbit(p, ('echo_in', 'echo', 'echo_out'), c, r + 1.25,
      angles[1:4], ('echo',))
link(p, 'b2', 'echo_in')
link(p, 'echo_out', 'b4')
fan('rainward_crown', 585, 2.38, -26, 25)

# The neighboring web cells answer each other across the 554–565 spoke.
axis = bearing(road(554), road(565))
sweep('yin_current', 554, 165, 4.20, 16, 4)
sweep('yang_current', 554, 2 * axis - 165, 4.20, -16, 4)

# One discharge crosses three web cells, handed off at road vertices.
discharge('seal_breaks', 577, 560,
          (0.43, 2.60), (0.40, 0.55), (28, -26, -26), 3)
discharge('heaven_splits', 560, 572,
          (0.48, -2.88), (0.42, -1.02), (-26, 26, 26), 3)
discharge('thunder_descends', 572, 570,
          (0.53, 2.57), (0.475, 0.40), (22, -24, -42), 4)

sweep('quiet_spark', 555, -73, 2.65, 25, 3)
sweep('parting_flash', 570, -34, 3.70, 19, 3)
