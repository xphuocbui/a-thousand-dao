"""Chaos, the hub, redesigned 2026-11-19: a purple swirl turning in towards the middle, after the picture the user picked
for it ("the spin swirl isn't as good as replace 1 swirls. Do that": design/dao-do/underlays/chaos/replace-1.png; the element
motifs outside the hub are chaos_elements.py).

Road change (user: "Remove the spokes"): the hub's five spokes (base-map nodes 31-35 and their ten links) are gone, so
the five hub cells 79-83 are one; the pieces are filed under cell 79. With no spokes, the swirl is the way through.

Second pass, same day (user: "some of the swirls in the chaos land are not connected, please let it flow more
naturally, the way it is connecting to the circle line is weird too"). The traced arms ended loose or met the rings
with a kink, so the swirl is the picture's swirl regularised: its arms turn as the picture's do (measured on the
traced arms: about 80 degrees from the rim to the inner ring, the same hand), here 90 so that each arm runs exactly
from an outer-ring node to an inner-ring node. Ten main arms, each a logarithmic spiral through its two road nodes (so
it meets each ring along the curve, not with a kink), from the outer nodes at 18 + 36k degrees in to the inner nodes
90 degrees on; and ten tributaries, one between each pair of main arms, starting just inside the rim and running in
more steeply until their main arm sweeps into them (at about 30 degrees, a third of the way in), as streams join a whirlpool (a piece holds at most two
roads, so a tributary cannot reach a ring of its own). Each main arm and its tributary is a piece: 20 lines as in
the picture, every one part of the flow. Nodes about 1.8 apart (user: fewer nodes, then 30% sparser); one notable a little in from the
rim on each main arm, and the tributary's head.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from celllib import road  # noqa: E402
from trace_lib import circum  # noqa: E402

THEME = 'chaos'
S, N = 'small', 'notable'
R_OUT, R_IN = 14.5, 4.2
TURN = -90.0                      # degrees from the rim in to the inner ring (the picture's hand)
STEP = 1.8                        # node spacing (user 2026-11-19: 30% sparser again, was 1.25)
R_MERGE, R_HEAD = 9.3, 13.6       # where a tributary joins its main arm; where it starts
B = math.log(R_OUT / R_IN) / math.radians(abs(TURN))
OUTER = {round((36 + 18 * (i - 11)) % 360): i for i in range(11, 31)}      # outer ring: angle -> road id
INNER = {round(36 * (i - 1)) % 360: i for i in range(1, 11)}               # inner ring


def P(r, a):
    t = math.radians(a)
    return (r * math.sin(t), r * math.cos(t))


def main_angle(a0, r):
    """The main arm from the rim at angle a0: its angle at radius r."""
    return a0 + TURN * math.log(R_OUT / r) / math.log(R_OUT / R_IN)


def arc_link(A, B_, M):
    c = circum(A, M, B_)
    return c if c is not None and math.dist(c, A) < 60 else None


pieces = {}
for k in range(10):
    a0 = (18 + 36 * k) % 360
    outer, inner = OUTER[a0], INNER[round(a0 + TURN) % 360]
    length = (R_OUT - R_IN) * math.sqrt(1 + 1 / B ** 2)
    n = max(4, round(length / STEP))
    radii = [R_OUT + (R_IN - R_OUT) * j / n for j in range(n + 1)]
    nodes, links, keys = {}, [], []
    for j, r in enumerate(radii[1:-1], 1):
        nodes[f'm{j}'] = (P(r, main_angle(a0, r)), S)
        keys.append(f'm{j}')
    chain = [outer] + keys + [inner]
    xy = lambda x: road(x) if isinstance(x, int) else nodes[x][0]
    for j in range(len(chain) - 1):
        rm = (radii[j] + radii[j + 1]) / 2
        links.append((chain[j], chain[j + 1], arc_link(xy(chain[j]), xy(chain[j + 1]), P(rm, main_angle(a0, rm)))))
    nodes[keys[2]] = (nodes[keys[2]][0], N)                    # a little in from the rim, after two smalls
    # the tributary: from just inside the rim, halfway to the next arm ahead, running in more steeply until its main
    # arm sweeps into it (they meet at about 30 degrees, its last link 1.6 long so the nodes beside the join keep apart)
    jm = min(range(len(keys)), key=lambda j: abs(radii[j + 1] - R_MERGE))
    r1, a1 = radii[jm + 1], main_angle(a0, radii[jm + 1])
    r0, a0t = R_HEAD, main_angle(a0 - 18, R_HEAD)
    ang_t = lambda r: a0t + (a1 - a0t) * math.log(r0 / r) / math.log(r0 / r1)
    r_last = r1 + 1.45
    tn = max(1, round((r0 - r_last) / STEP))
    trad = [r0 + (r_last - r0) * j / tn for j in range(tn + 1)] + [r1]
    tk = []
    for j, r in enumerate(trad[:-1]):
        nodes[f't{j}'] = (P(r, ang_t(r)), N if j == 0 else S)
        tk.append(f't{j}')
    tk.append(keys[jm])
    for j in range(len(tk) - 1):
        rm = (trad[j] + trad[j + 1]) / 2
        links.append((tk[j], tk[j + 1], arc_link(nodes[tk[j]][0], nodes[tk[j + 1]][0], P(rm, ang_t(rm)))))
    pieces[f'swirl_arm_{k + 1:02d}'] = (nodes, links)

CELLS = {79: pieces}
