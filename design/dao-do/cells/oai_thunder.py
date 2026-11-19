import math
from celllib import road

THEME = 'island'


def step(point, heading, length):
    """Clockwise heading in degrees from +x in the map's y-down frame."""
    angle = math.radians(heading)
    return (point[0] + length * math.cos(angle),
            point[1] + length * math.sin(angle))


def bolt(anchor, *branches):
    """Each row is (parent index, heading, length); index 0 is the road."""
    positions = [road(anchor)]
    keys = [anchor]
    parents = {parent for parent, _, _ in branches}
    nodes, links = {}, []
    for i, (parent, heading, length) in enumerate(branches, 1):
        key = f'n{i}'
        point = step(positions[parent], heading, length)
        positions.append(point)
        keys.append(key)
        nodes[key] = (point, 'small' if i in parents else 'notable')
        links.append((keys[parent], key, None))
    return nodes, links


CELLS = {932: {
    # Pentagon: thread the narrow lane above the start's western arm,
    # then answer with a compact fork north of its eastern arm.
    'oai_inner_yin': bolt(552,
        (0, -11, 2.24), (1, -10, 1.25), (2, 73, 0.91),
    ),
    'oai_inner_yang': bolt(558,
        (0, 167, 1.20), (1, 105, 1.15), (2, 188, 1.20),
        (3, 242, 1.16), (4, 161, 1.19),
        (4, 303, 1.00), (6, 185, 1.20),
    ),

    # Northeast: a rim-fed fork and a short counterstrike beside the spoke.
    'oai_high_thunder_fan': bolt(573,
        (0, 110, 1.25), (1, 174, 1.26), (2, 236, 1.05),
        (3, 181, 1.28), (4, 133, 1.28),
        (5, 193, 1.24), (6, 132, 1.20), (7, 203, 1.19),
        (5, 231, 1.18), (9, 171, 1.26),
    ),
    'oai_jade_counterstrike': bolt(558,
        (0, -91, 1.24), (1, -24, 1.24), (2, -89, 1.20),
        (3, -20, 1.25), (4, -83, 1.18),
    ),

    # Northwest: two rim strikes and a short answer from the pentagon.
    'oai_sky_gate': bolt(576,
        (0, -7, 1.25), (1, 57, 1.25), (2, -9, 1.25),
        (3, 65, 1.20), (4, 135, 1.18),
        (3, -78, 1.15), (6, -153, 1.18),
    ),
    'oai_split_seal': bolt(577,
        (0, 54, 1.20), (1, -17, 1.24), (2, 101, 1.22),
        (3, 40, 1.25), (3, 155, 1.22),
    ),
    'oai_returning_spark': bolt(552,
        (0, 252, 1.25), (1, 182, 1.24), (2, 242, 1.20),
    ),

    # West: three staggered strikes around the old bolt.
    'oai_spoke_creeper': bolt(562,
        (0, 70, 1.25), (1, 3, 1.20), (2, 78, 1.19),
        (3, 10, 1.19), (4, 68, 1.12),
    ),
    'oai_forked_echo': bolt(563,
        (0, 2, 1.22), (1, -66, 1.21), (2, 6, 1.08),
        (3, -62, 1.15), (3, 120, 1.28),
    ),
    'oai_stone_cleaver': bolt(564,
        (0, 40, 1.23), (1, -30, 1.23), (2, 37, 1.20),
        (3, -30, 1.22), (4, -100, 1.19), (5, -30, 1.19),
        (3, 104, 1.17), (7, 172, 1.18),
    ),

    # East: a double strike above the old bolt and a three-tip tree below.
    'oai_twin_channels': bolt(558,
        (0, 8, 1.25), (1, 78, 1.19), (2, 2, 1.19),
        (3, -67, 1.20), (4, 5, 1.20),
        (3, 69, 1.19), (6, 1, 1.21),
    ),
    'oai_three_tribulations': bolt(570,
        (0, 150, 1.28), (1, 86, 1.15), (2, 151, 1.22),
        (3, 95, 1.21), (4, 154, 1.20), (4, 29, 1.19),
        (3, 207, 1.24), (7, 142, 1.20), (8, 213, 1.17),
    ),

    # South: one long discharge skirts the old tips and forks twice.
    'oai_rim_coursing_thunder': bolt(565,
        (0, -20, 1.52), (1, 2, 1.23), (2, -63, 1.19),
        (3, -3, 1.05), (4, 63, 1.10), (5, 9, 0.91),
        (6, 58, 1.12), (7, -6, 1.23), (8, 53, 1.16),
        (9, -10, 1.28), (10, -63, 1.26), (11, -8, 1.17),
        (12, -108, 1.20), (12, -46, 1.12),
        (4, -66, 1.19), (15, -2, 1.14), (16, -109, 1.14),
    ),
}}
