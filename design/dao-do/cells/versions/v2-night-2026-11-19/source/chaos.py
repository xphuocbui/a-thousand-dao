"""Chaos (Hon Don), the hub: swirls into the centre (user 2026-11-18: "For chaos it should be swirls into the center").
Hand-placed by Claude 2026-11-18 night. Replaces the land files' pieces in the five hub cells 79-83 (each land file ends
with CELLS[<hub>] = {} pointing here).

Five spiral arms, one per land, the same drawing turned 72 degrees each time, so the hub reads as one pinwheel turning
into the Chaos start. Arm j ends at the inner ring (r 4.2) on land j's axis and starts on the ring r 14.5 on the next land's
axis, 72 degrees round; on the way it crosses the border spoke at that spoke's middle road node (r 9.35), so it is split there
into two pieces, one in each wedge (the road node is a pass-through, as the border combos and wall pairs do):
  armOut (in land j+1's hub cell): ring r 14.5 at local 0 -> middle node of the spoke at local -36, 7 nodes;
  armIn  (in land j's hub cell):   middle node of the spoke at local +36 -> inner ring at local 0, 5 nodes.
One spiral carries both halves: r = 14.5 (4.2 / 14.5)**t, angle = 72 (1 - g(t)) past the axis, g quadratic and set so
the spiral passes the spoke node exactly and leaves the outer ring at a slant. Two eddies per wedge fill the corners the arms leave: small curls winding the
same way, one from the ring r 14.5 at local +18, one from the inner ring at local -36, ending in a notable eye.
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design',
                                'dao_do_rework', 'cells'))
from celllib import AXIS, L, road, roads  # noqa: E402

THEME = 'chaos'
HUB = {'wood': 79, 'earth': 80, 'metal': 81, 'water': 82, 'fire': 83}
NEXT = {'fire': 'earth', 'earth': 'metal', 'metal': 'water', 'water': 'wood', 'wood': 'fire'}   # +72 degrees


def near(p, tol=0.3):
    R = roads()
    j = min(R, key=lambda k: math.dist(R[k], p))
    assert math.dist(R[j], p) < tol, (p, R[j])
    return j


def circum(a, b, c):
    ax, ay = a
    bx, by = b
    cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def curve_piece(P, t0, t1, n, kinds, start_id, end_id=None):
    """n nodes at even t between t0 and t1 (exclusive) of curve P, hung from start_id (and end_id); arc links round the
    circle through each link's ends and the curve point halfway between them."""
    ts = [t0 + (t1 - t0) * (i + 1) / (n + 1) for i in range(n)]
    if end_id is None:
        ts = [t0 + (t1 - t0) * (i + 1) / n for i in range(n)]
    nodes = {f'n{i}': (P(t), k) for i, (t, k) in enumerate(zip(ts, kinds))}
    tt = [t0] + ts + ([t1] if end_id is not None else [])
    keys = [start_id] + list(nodes) + ([end_id] if end_id is not None else [])
    links = [(keys[i], keys[i + 1], circum(P(tt[i]), P((tt[i] + tt[i + 1]) / 2), P(tt[i + 1]))) for i in range(len(keys) - 1)]
    return nodes, links


R0, R1, RM = 14.5, 4.2, None
CELLS = {c: {} for c in HUB.values()}
for land, cell in HUB.items():
    up = NEXT[land]
    o_start = near(L(R0, 0, up))                     # ring r 14.5 on the next land's axis = this axis + 72
    i_end = near(L(R1, 0, land))
    mid = near(L(9.35, 36, land), tol=0.6)           # middle node of the spoke between land and the next land
    rm = math.dist((0, 0), road(mid))
    tm = math.log(rm / R0) / math.log(R1 / R0)
    am = math.degrees(math.atan2(*road(mid))) - AXIS[land]
    am = (am + 180) % 360 - 180                       # about +36
    gm = 1 - am / 72                                  # share of the turn done at the spoke node
    al = (gm - tm * tm) / (tm - tm * tm)              # g(t) = al t + (1 - al) t^2: g(0)=0, g(1)=1, g(tm)=gm

    def P(t, land=land, al=al):
        return L(R0 * (R1 / R0) ** t, 72 * (1 - (al * t + (1 - al) * t * t)), land)

    CELLS[HUB[up]]['armOut'] = curve_piece(P, 0.0, tm, 7, ('small', 'small', 'notable', 'small', 'notable', 'small',
                                                          'small'), o_start, mid)
    CELLS[cell]['armIn'] = curve_piece(P, tm, 1.0, 5, ('small', 'small', 'notable', 'small', 'small'), mid, i_end)


def eddy(land, rid, ce_r, ce_a, rhos, step, sense):
    """A curl round a local centre: nodes on shrinking radii, stepping `step` degrees each in the given sense, from the
    direction of the road node; the last (the eye) a notable."""
    C = L(ce_r, ce_a, land)
    A = road(rid)
    phi0 = math.degrees(math.atan2(A[0] - C[0], A[1] - C[1]))
    rho0 = math.dist(A, C)

    def P(t):                                          # t in [0, len(rhos)]
        i = min(int(t), len(rhos) - 1)
        r_a = rho0 if t < 1 else rhos[i - 1] if i >= 1 else rho0
        f = t - int(t)
        ra = ([rho0] + list(rhos))[min(int(t), len(rhos))]
        rb = ([rho0] + list(rhos))[min(int(t) + 1, len(rhos))]
        rho = ra + (rb - ra) * f
        ph = math.radians(phi0 + sense * step * t)
        return (C[0] + rho * math.sin(ph), C[1] + rho * math.cos(ph))

    n = len(rhos)
    kinds = ['small'] * (n - 1) + ['notable']
    nodes = {f'n{i}': (P(i + 1), k) for i, k in enumerate(kinds)}
    keys = [rid] + list(nodes)
    links = [(keys[i], keys[i + 1], circum(P(i), P(i + 0.5), P(i + 1))) for i in range(n)]
    return nodes, links


for land, cell in HUB.items():
    CELLS[cell]['eddyA'] = eddy(land, near(L(R0, 18, land)), 11.6, 13, (2.15, 1.95, 1.7, 1.4, 1.05), 52, -1)
    CELLS[cell]['eddyB'] = eddy(land, near(L(R1, -36, land)), 6.9, -22, (2.1, 1.9, 1.6, 1.25), 55, -1)
