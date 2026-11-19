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


def bow(name, a, b, sweep_angle, count, notables=()):
    # A positive sweep bows to the negative-angle side of the chord.
    p = piece(name)
    u, v = road(a), road(b)
    heading = bearing(u, v)
    half_chord = math.hypot(v[0] - u[0], v[1] - u[1]) / 2
    half_angle = math.radians(sweep_angle / 2)
    midpoint = ((u[0] + v[0]) / 2, (u[1] + v[1]) / 2)
    centre = Q(midpoint, half_chord / math.tan(half_angle), heading + 90)
    radius = half_chord / math.sin(half_angle)
    start = bearing(centre, u)
    keys = tuple(f'b{i}' for i in range(1, count + 1))
    angles = tuple(start + sweep_angle * i / (count + 1)
                   for i in range(1, count + 1))
    orbit(p, keys, centre, radius, angles, notables)
    link(p, a, keys[0], centre)
    link(p, keys[-1], b, centre)
    return p, centre, radius, angles


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
fan('listening_to_thunder', 561, 2.75, -126, 25)

# A broad northeast discharge with a short return on the outer orbit.
p, c, r, angles = bow('violet_heaven', 560, 572, 64, 5, ('b3',))
orbit(p, ('cloud', 'flash'), c, r + 1.23,
      (angles[2], angles[1]), ('flash',))
link(p, 'b3', 'cloud')

# Two curling paths share a radial joint on the inside of the east fork.
p = piece('divided_lightning')
c = road(570)
orbit(p, ('root', 'joint', 'coil', 'inward_flash'), c, 2.20,
      (184, 212, 240, 268), ('inward_flash',))
orbit(p, ('rim', 'return', 'outward_flash'), c, 3.55,
      (212, 184, 156), ('outward_flash',))
link(p, 570, 'root')
link(p, 'joint', 'rim')

sweep('quiet_spark', 555, -73, 2.65, 25, 3)
sweep('parting_flash', 570, -34, 3.70, 19, 3)
