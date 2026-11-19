"""Cell 93 (Fire, middle band r 53.9-64.3, theta 0-11 from the Fire axis), placed by hand. Right above cell 14; shares
its bottom road nodes 1610, 1609, 1608 with cell 14's top. Road nodes on the walls (id: r, theta):
  top ring 53.9:    1480 axis, 1590 3.6, 1589 7.3, 1588 11
  bottom ring 64.3: 1482 axis, 1610 3, 1609 6, 1608 11
  axis: 1481 (r 59.1); right spoke theta 11: 1588, 1938 (r 59.1), 1608
Centre figure: "rising sun", five rays fanning from road node 1938 on the right spoke towards the axis, each curving
the same way and ending in a notable, the five tips a crown. Its own figure (cell 14 has the ring between arcs).
"""
from celllib import orbit, fill

CELL, THEME = 93, 'fire'

ROAD = {1480: (0.0, 53.9), 1481: (0.0, 59.1), 1482: (0.0, 64.3), 1590: (3.38, 53.79), 1589: (6.85, 53.46),
        1588: (10.28, 52.91), 1610: (3.37, 64.21), 1609: (6.72, 63.95), 1608: (12.27, 63.12), 1938: (11.28, 58.01)}

SUN = ROAD[1938]
RAYS = (-25, -57.5, -90, -122.5, -155)        # ray directions from 1938 (0 = up, -90 = towards the axis)
TWIST = 7                                     # each step out turns 7 degrees upward: the rays swirl

PIECES = {}
for k, a in enumerate(RAYS):
    nodes = {'s1': (orbit(SUN, 1.8, a), 'small'), 's2': (orbit(SUN, 3.0, a + TWIST), 'small'),
             'tip': (orbit(SUN, 4.2, a + 2 * TWIST), 'notable')}
    PIECES[f'ray{k + 1}'] = (nodes, [(1938, 's1', None), ('s1', 's2', None), ('s2', 'tip', None)])

FILL = [  # (name, road, family, style, stem, ang, turn, hand)  -- ang 0 = up (towards the tree centre), 180 = down
    ('W wheel',    1481, 'Wheel', 'spoke', 1.2, 95, 0, False),
    ('H hairpin',  1590, 'Hairpin', 'bow out', 1.2, 180, 0, False),
    ('F fork',     1610, 'Fork', 'closed', 1.0, -10, 0, False),
    ('T tadpole',  1609, 'Tadpole', 'cusped', 1.0, -15, 0, False),
]
fill(PIECES, ROAD, FILL)
