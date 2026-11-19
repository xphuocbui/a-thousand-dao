"""Thunder (932): the lightning bolts, redrawn by Claude 2026-11-19 (user: "the lightning bolts looks weird, especially
the node placement... make it look a bit more pleasing, and there's more stuffs, meaning adding more bolts. Also
bolts could be done like the Rattled + Frazzled cluster or the Electrocuting Exposure + Coursing Energy cluster,
Electrocution + Conductive Embrace cluster or the Pure Power + Electric Amplification + Power Conduction from PoE 2").

PoE 2's lightning clusters (looked at in its tree data, which is never committed) share one grammar, followed here:
straight links only, a node at every corner of the zigzag and none between, segments about 1.2-1.4 long turning
sharply, and a bolt forking so that each prong ends in a notable. Five forms, each written once as corner points in
a bolt's own frame (forward along its direction, sideways across it) and placed by hand:
  - Y       (Rattled + Frazzled): a short zigzag that forks into two prongs, a notable at each tip;
  - chain   (Electrocuting Exposure + Coursing Energy): a long zigzag that forks late;
  - double  (Electrocution + Conductive Embrace): two zigzags side by side off one short stem;
  - tree    (Pure Power + Electric Amplification + Power Conduction): a trunk forking twice, three tips;
  - spark   (a short bolt for tight places).
The clouds of thunder_trace.py stay; its old bolts and sparks are gone (thunder_trace.py drops them).

Second direction, same day (user: "the bolts inside could be small like the current shape, just make it a bit less
dense and more structured and organized. The bolts outside could follow PoE2 patterns. And we could probably add the
cluster like the clouds ... + bolts underneath"): inside the island the bolts are small zigzags with a corner every
1.0 (zigY in each web cell, zig inside the pentagon); outside, on the open side, the PoE 2 forms; and storm clouds (two
scallops and curled ends) with three bolts striking underneath.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
from celllib import road  # noqa: E402
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from trace_lib import circum  # noqa: E402

THEME = 'island'
S, N = 'small', 'notable'
CENTRE = (-103.665, -33.683)              # the island's start (base-map node 551)

# forms: nodes {key: (forward, sideways, kind)} and chains through them ('D' is the road node it hangs from)
FORMS = {
    'Y': ({'s1': (1.3, 0.5, S), 'F': (2.5, -0.1, S),
           'a1': (3.3, 0.8, S), 'a2': (4.5, 0.4, S), 'A': (5.3, 1.3, N),
           'b1': (3.2, -1.1, S), 'b2': (4.4, -0.9, S), 'B': (5.0, -2.0, N)},
          [['D', 's1', 'F'], ['F', 'a1', 'a2', 'A'], ['F', 'b1', 'b2', 'B']]),
    'chain': ({'s1': (1.2, 0.6, S), 's2': (2.3, 0.0, S), 's3': (3.2, 0.9, S), 'F': (4.4, 0.5, S),
               'a1': (5.4, 1.2, S), 'a2': (6.4, 0.6, S), 'A': (7.3, 1.2, N),
               'b1': (5.0, -0.6, S), 'b2': (6.1, -0.9, S), 'B': (6.7, -1.9, N)},
              [['D', 's1', 's2', 's3', 'F'], ['F', 'a1', 'a2', 'A'], ['F', 'b1', 'b2', 'B']]),
    'double': ({'s0': (1.0, 0.0, S),
                'a1': (1.9, 0.9, S), 'a2': (2.9, 0.6, S), 'a3': (3.6, 1.6, S), 'A': (4.8, 1.5, N),
                'b1': (2.0, -0.8, S), 'b2': (2.9, -1.4, S), 'b3': (4.0, -1.0, S), 'B': (4.7, -2.0, N)},
               [['D', 's0'], ['s0', 'a1', 'a2', 'a3', 'A'], ['s0', 'b1', 'b2', 'b3', 'B']]),
    'tree': ({'s1': (1.2, 0.3, S), 's2': (2.2, -0.3, S), 'F1': (3.3, 0.2, S),
              'l1': (3.9, -0.9, S), 'l2': (5.0, -1.1, S), 'L': (5.6, -2.1, N),
              'm1': (4.5, 0.6, S), 'F2': (5.6, 0.2, S),
              'r1': (6.3, 1.1, S), 'r2': (7.4, 0.9, S), 'R': (8.0, 1.8, N),
              'c1': (6.6, -0.6, S), 'c2': (7.7, -0.3, S), 'C': (8.6, -0.9, N)},
             [['D', 's1', 's2', 'F1'], ['F1', 'l1', 'l2', 'L'], ['F1', 'm1', 'F2'], ['F2', 'r1', 'r2', 'R'],
              ['F2', 'c1', 'c2', 'C']]),
    'smallY': ({'s1': (1.0, 0.4, S), 'F': (1.9, -0.1, S),
                'a1': (2.6, 0.7, S), 'a2': (3.6, 0.5, S), 'A': (4.2, 1.3, N),
                'b1': (2.7, -0.8, S), 'b2': (3.6, -0.6, S), 'B': (4.1, -1.5, N)},
               [['D', 's1', 'F'], ['F', 'a1', 'a2', 'A'], ['F', 'b1', 'b2', 'B']]),
    'spark': ({'s1': (1.1, 0.5, S), 's2': (2.0, -0.1, S), 'T': (2.9, 0.5, N)},
              [['D', 's1', 's2', 'T']]),
    # inside the island: small bolts like the old ones, fewer nodes, a corner every 1.0
    'zig': ({'s1': (0.9, 0.45, S), 's2': (1.8, -0.1, S), 's3': (2.6, 0.5, S), 'T': (3.5, 0.0, N)},
            [['D', 's1', 's2', 's3', 'T']]),
    'zigY': ({'s1': (0.9, 0.4, S), 'F': (1.8, -0.1, S),
              'a1': (2.6, 0.55, S), 'a2': (3.5, 0.15, S), 'A': (4.3, 0.75, N),
              'b1': (2.5, -0.85, S), 'b2': (3.4, -0.7, S), 'B': (4.0, -1.45, N)},
             [['D', 's1', 'F'], ['F', 'a1', 'a2', 'A'], ['F', 'b1', 'b2', 'B']]),
    # inside the pentagon's corners: a straighter zigzag that clears the corner's two road sides
    'zigin': ({'s1': (1.1, 0.15, S), 's2': (1.8, -0.35, S), 'T': (2.6, 0.1, N)},
              [['D', 's1', 's2', 'T']]),
    # a cloud (user: "above make more cloud at the cloud part"): three lobes, the ends curled back
    'cloud': ({'s1': (1.0, 0.0, S), 'bc': (2.0, 0.0, S), 'bl': (2.2, -1.8, S), 'br': (2.2, 1.8, S),
               'ml': (3.5, -1.5, S), 't': (4.0, 0.0, N), 'mr': (3.5, 1.5, S),
               'cl': (1.6, -2.8, S), 'CL': (1.0, -2.0, N), 'cr': (1.6, 2.8, S), 'CR': (1.0, 2.0, N)},
              [['D', 's1', 'bc'], ['bl', 'cl', 'CL'], ['br', 'cr', 'CR']],
              [('bc', 'bl', (1.6, -0.9)), ('bc', 'br', (1.6, 0.9)), ('bl', 'ml', (3.0, -1.9)), ('ml', 't', (3.95, -0.8)),
               ('t', 'mr', (3.95, 0.8)), ('mr', 'br', (3.0, 1.9))]),
    # a storm cloud (two scallops bulging back towards its road, its ends curled) with three bolts underneath
    'storm': ({'s1': (1.0, 0.0, S), 'bc': (2.1, 0.0, S), 'bl': (2.1, -1.7, S), 'br': (2.1, 1.7, S),
               'cl': (1.3, -2.6, S), 'CL': (0.8, -1.7, N), 'cr': (1.3, 2.6, S), 'CR': (0.8, 1.7, N),
               'l1': (3.0, -1.3, S), 'l2': (3.9, -1.9, S), 'l3': (4.8, -1.4, S), 'LB': (5.6, -1.9, N),
               'm1': (3.1, 0.35, S), 'm2': (4.0, -0.15, S), 'm3': (5.0, 0.35, S), 'M': (6.0, 0.0, N),
               'r1': (3.0, 1.35, S), 'r2': (3.9, 1.95, S), 'r3': (4.7, 1.45, S), 'RB': (5.5, 1.95, N)},
              [['D', 's1', 'bc'], ['bl', 'cl', 'CL'], ['br', 'cr', 'CR'],
               ['bl', 'l1', 'l2', 'l3', 'LB'], ['bc', 'm1', 'm2', 'm3', 'M'], ['br', 'r1', 'r2', 'r3', 'RB']],
              [('bc', 'bl', (1.5, -0.85)), ('bc', 'br', (1.5, 0.85))]),
}


def long_stem(form, by=1.1):
    """A form moved out along its own axis by `by`, a second stem node added: it stands clear of the road it hangs
    from (a cloud's curled ends otherwise reach back to the road)."""
    pts, chains, *arcs = FORMS[form]
    moved = {k: (a + by, b, kd) if k != 's1' else (a, b, kd) for k, (a, b, kd) in pts.items()}
    first = chains[0]                                  # ['D', 's1', ...]
    moved['s0'] = (pts['s1'][0] * 0.5 + 0.55, 0.0, S)
    moved['s1'] = (pts['s1'][0] + by, pts['s1'][1], S)
    chains = [['D', 's0'] + first[1:]] + chains[1:]
    arcs = [[(u, v, (m[0] + by, m[1])) for u, v, m in arcs[0]]] if arcs else []
    return (moved, chains, *arcs)


def place(door, form, angle=None, scale=1.0, mirror=False, turn=0.0):
    """A form hung from road node `door`, pointing at `angle` (degrees, map frame: atan2 of x, y as P(r, th)), by
    default straight out from the island's centre, turned by `turn`; `mirror` flips it sideways."""
    D = road(door)
    if angle is None:
        angle = math.degrees(math.atan2(D[0] - CENTRE[0], D[1] - CENTRE[1]))
    t = math.radians(angle + turn)
    f = (math.sin(t), math.cos(t))
    sd = (f[1], -f[0]) if not mirror else (-f[1], f[0])
    pts, chains, *arcs = FORMS[form]
    at = lambda a, b: (D[0] + scale * (a * f[0] + b * sd[0]), D[1] + scale * (a * f[1] + b * sd[1]))
    nodes = {k: (at(a, b), kd) for k, (a, b, kd) in pts.items()}
    links = []
    for ch in chains:
        seq = [door if x == 'D' else x for x in ch]
        links += [(p, q, None) for p, q in zip(seq, seq[1:])]
    for u, v, mid in (arcs[0] if arcs else []):
        links.append((u, v, circum(nodes[u][0], at(*mid), nodes[v][0])))
    return nodes, links


def inward(door):
    D = road(door)
    return math.degrees(math.atan2(CENTRE[0] - D[0], CENTRE[1] - D[1]))


FORMS['cloud_far'] = long_stem('cloud')
FORMS['storm_far'] = long_stem('storm')


CELLS = {932: {
    # inside the island (user: "the bolts inside could be small like the current shape, just make it a bit less dense and
    # more structured and organized"): in each web cell the same small forked bolt out from the middle of the
    # pentagon's side; three small zigzags inside the pentagon
    'bolt_w1': place(559, 'zigY', scale=1.1),
    'bolt_w2': place(557, 'zigY', scale=1.1),
    'bolt_w3': place(555, 'zigY', scale=1.1),
    'bolt_w4': place(553, 'zigY', scale=1.1),
    'bolt_w5': place(561, 'zigY', scale=1.1),
    'zig_in_560': place(560, 'zigin', angle=inward(560)),
    'zig_in_556': place(556, 'zigin', angle=inward(556)),
    'zig_in_554': place(554, 'zigin', angle=inward(554)),
    # outside, on the open side (user: "the bolts outside could follow PoE2 patterns")
    'bolt_out_chain': place(574, 'chain', turn=12, mirror=True),     # Electrocuting Exposure + Coursing Energy
    'bolt_out_tree': place(571, 'tree', turn=-8),                    # Pure Power + Amplification + Conduction
    'bolt_out_double': place(572, 'double', turn=6),                 # Electrocution + Conductive Embrace
    'bolt_out_y': place(568, 'Y', turn=-28),                         # Rattled + Frazzled
    # storm clouds with bolts underneath (user: "the cluster like the clouds ... + bolts underneath")
    'storm_569': place(569, 'storm', turn=8),
    'storm_586': place(586, 'storm', turn=-6),
    # second pass (user: "More clusters and node needed in the thunderland, above make more cloud at the cloud part,
    # and below add more lightning bolts pattern"): two more clouds over the cloud cells, and more bolts below
    'cloud_579': place(579, 'cloud_far', turn=-6, scale=0.9),
    'cloud_581': place(581, 'cloud_far', turn=-16, scale=0.85),
    'bolt_down_tree': place(589, 'tree', angle=-14.0, scale=0.8),       # Pure Power + Amplification + Conduction
    'bolt_down_y': place(588, 'Y', angle=18.0, scale=0.7, mirror=True),          # Rattled + Frazzled
    'storm_566': place(566, 'storm_far', angle=-22.0, scale=0.9),
}}
