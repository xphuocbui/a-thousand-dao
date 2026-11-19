"""The rim pagoda (tower) of Earth, cell 902, hand-placed by Claude 2026-11-19 (user: "the tower cluster it looks a bit
bad"): the axis road is the mast; at each of its road nodes a tier of eaves sweeps out either side, mirrored, each
sagging a little from the mast and sweeping up into an upturned tip (notable), narrowing towards the spire; a low
plinth curve at its foot; the old finial ring beyond the spire's end."""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lands'))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design',
                                'dao_do_rework', 'cells'))
from celllib import road, mirror_pieces  # noqa: E402
import earth  # noqa: E402
from earth import E, rim_finial  # noqa: E402

THEME = 'earth'
CELLS = {902: {}}
# plinth curve on the ring at its foot; the finial ring beyond the spire's end stays.
def _circum(a, b, c):
    ax, ay = a; bx, by = b; cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


_AX = E(1.0, 0.0)                                   # outward along the mast
_LT = (_AX[1], -_AX[0]) if E(1.0, 1.0)[0] * _AX[1] - E(1.0, 1.0)[1] * _AX[0] > 0 else (-_AX[1], _AX[0])   # towards +th


def eave(rid, w, sag, lift, n=4, kinds=None):
    """One eave, right half: from mast road node rid out to half-width w, sagging `sag` below the mast node at its
    middle and lifting `lift` above it at the tip (v = -4 sag s (1 - s) + lift s^4 along s = 0..1), n nodes at even s,
    the tip a notable; arcs through the curve's midpoints."""
    M = road(rid)
    P = lambda s: (M[0] + w * s * _LT[0] + (-4 * sag * s * (1 - s) + lift * s ** 4) * _AX[0],
                   M[1] + w * s * _LT[1] + (-4 * sag * s * (1 - s) + lift * s ** 4) * _AX[1])
    kinds = kinds or ['small'] * (n - 1) + ['notable']
    ss = [(i + 1) / n for i in range(n)]
    pts = {f'e{i}': (P(t), k) for i, (t, k) in enumerate(zip(ss, kinds))}
    keys = [rid] + list(pts)
    tt = [0.0] + ss
    links = [(keys[i], keys[i + 1], _circum(P(tt[i]), P((tt[i] + tt[i + 1]) / 2), P(tt[i + 1]))) for i in range(n)]
    return pts, links


for _name, _rid, _w, _sag, _lift, _n in (('tier1', 501, 6.4, 0.9, 1.5, 5), ('tier2', 404, 4.9, 0.75, 1.3, 4),
                                         ('tier3', 1227, 3.5, 0.6, 1.1, 3)):
    _pc = eave(_rid, _w, _sag, _lift, _n, ['small'] * (_n - 1) + ['notable'] if _n > 3 else ['small', 'small', 'notable'])
    CELLS[902][_name + '_R'] = _pc
    CELLS[902][_name + '_L'] = mirror_pieces({'p': _pc}, 'earth')['p']
_pc = eave(1490, 3.0, -0.35, 1.3, 3)                 # the plinth: a low mound either side of the mast's foot
CELLS[902]['plinth_R'] = _pc
CELLS[902]['plinth_L'] = mirror_pieces({'p': _pc}, 'earth')['p']
CELLS[902]['finial'] = rim_finial()
