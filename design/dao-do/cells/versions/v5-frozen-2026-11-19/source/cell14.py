"""Cell 14 (Fire, outer band r 64.3-74.3, theta 0-17 from the Fire axis), placed by hand. Approved by the user
2026-11-18 after 8 passes ("yup works"). Road nodes on the walls (id: r, theta):
  top ring 64.3:    1482 axis, 1610 3, 1609 6, 1608 11, 1607 14, 1606 17
  bottom ring 74.3: 1484 axis, 1576 2.7, 1575 5.5, 1574 8, 1573 12, 1572 14.5, 1571 17
  axis: 1483 (r 69.3); right spoke theta 17: 1606, 1942 (spoke midpoint, not a hub), 1571
Centre figure: "heart flame", a ring bridging the cell inside two arcs on an outer orbit. Used here only.
"""
import math

from celllib import fill

CELL, THEME = 14, 'fire'

# --- the combo: a ring bridging the cell top to bottom (1608 -> 1574) inside two arcs on an outer orbit ---------------
A, B = (12.27, 63.12), (10.34, 73.58)                     # road nodes 1608 and 1574
C = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
L = math.dist(A, B)
d = ((B[0] - A[0]) / L, (B[1] - A[1]) / L)
e = (d[1], -d[0])
if e[0] < 0:
    e = (-e[0], -e[1])


def ring(phi, rr=1.9):              # phi 0 = towards 1608, + = towards +theta
    p = math.radians(phi)
    return (C[0] - rr * d[0] * math.cos(p) + rr * e[0] * math.sin(p), C[1] - rr * d[1] * math.cos(p) + rr * e[1] * math.sin(p))


def outer(phi):
    return ring(phi, 3.5)


ROAD = {1482: (0.0, 64.3), 1483: (0.0, 69.3), 1484: (0.0, 74.3), 1610: (3.37, 64.21), 1609: (6.72, 63.95),
        1607: (15.56, 62.39), 1606: (18.8, 61.49), 1576: (3.5, 74.22), 1575: (7.12, 73.96), 1573: (15.45, 72.68),
        1572: (18.6, 71.93), 1571: (21.72, 71.05)}

PIECES = {
    'ring': ({f'r{p}': (ring(p), 'notable' if p in (90, 270) else 'small') for p in range(0, 360, 45)},
             [(1608, 'r0', None), ('r180', 1574, None)] +
             [(f'r{p}', f'r{(p + 45) % 360}', C) for p in range(0, 360, 45)]),
    'arcL': ({f'o{p}': (outer(p), 'notable' if p in (340, 200) else 'small') for p in (340, 325, 310, 280, 250, 220, 200)},
             [(1609, 'o310', None), ('o310', 'o325', C), ('o325', 'o340', C), ('o310', 'o280', C), ('o280', 'o250', C),
              ('o250', 'o220', C), ('o220', 'o200', C)]),
    'arcR': ({f'o{p}': (outer(p), 'notable' if p in (20, 160) else 'small') for p in (20, 35, 50, 80, 110, 140, 160)},
             [(1607, 'o50', None), ('o50', 'o35', C), ('o35', 'o20', C), ('o50', 'o80', C), ('o80', 'o110', C),
              ('o110', 'o140', C), ('o140', 'o160', C)]),
}

FILL = [  # (name, road, family, style, stem, ang, turn, hand)  -- ang 0 = up (towards the tree centre), 180 = down
    ('A ring',     1610, 'Ring', 'round', 1.3, 180, 0, False),
    ('B crook',    1610, 'Crook', 'bow out', 1.2, 235, 0, True),
    ('C tadpole',  1483, 'Tadpole', 'round', 1.2, 90, 0, False),
    ('D arch',     1576, 'Arch', 'bow out', 1.3, 0, 0, False),
    ('G hook',     1609, 'Hook', 'bow in', 1.2, 205, 0, True),
    ('H diamond',  1606, 'Diamond', 'round', 1.3, 228, 0, False),
    ('I fork',     1572, 'Fork', 'bow out', 2.0, -20, 0, False),
    ('K crescent', 1607, 'Crescent', 'bow out', 1.3, 175, 0, False),
    ('E crescent', 1575, 'Crescent', 'bow out', 1.2, 0, 0, False),
    ('J crook',    1571, 'Crook', 'bow in', 1.2, -40, 0, False),
]
fill(PIECES, ROAD, FILL)
