"""Orbit snap (experiment 2026-11-17, user: "please just try all"): PoE's placement grammar applied to our authored
figures. PoE puts every node of a group on one of a few circles round the group's centre, at fixed angle slots, and
never turns a group (memory: poe-orbit-grammar, measured 2026-11-15).

Here: each figure's nodes snap to the nearest circle (PoE's radii ratios, scaled so PoE 1's median neighbour distance
is 1.2 of ours) and the nearest slot on it; links between two nodes on one circle become arcs of it. A placed figure
then turns only in 30-degree steps counted from its region's axis (layout.py --orbit), so every figure in a region
shares one angle lattice, and the land still mirrors about its axis. A figure the snap would break (nodes closer than
0.72, crossings, a cluster rule) keeps its drawing.

usage: python -I orbit.py      (prints which figures snap)
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import authored as A  # noqa: E402

SCALE = 1.2 / 173.0
RADII = [r * SCALE for r in (0, 82, 162, 251, 335, 493, 662, 846)]
STEP = {1: 30, 2: 15, 3: 15, 4: 15, 5: 10, 6: 5, 7: 5}
TURN = 30            # a placed figure turns in these steps from its region's axis


def snap(S):
    """Shape S with every node on a circle slot, or None when the snap breaks it."""
    T = A.Shape(S.name)
    ring = []
    for u, v, role in S.nodes:
        r = math.hypot(u, v)
        k = min(range(len(RADII)), key=lambda i: abs(RADII[i] - r))
        if k == 0:
            T.nodes.append((0.0, 0.0, role)); ring.append(0); continue
        th = math.degrees(math.atan2(u, v))
        th = round(th / STEP[k]) * STEP[k]
        T.nodes.append((round(RADII[k] * math.sin(math.radians(th)), 4), round(RADII[k] * math.cos(math.radians(th)), 4), role))
        ring.append(k)
    for i in range(len(T.nodes)):
        for j in range(i + 1, len(T.nodes)):
            if math.dist(T.nodes[i][:2], T.nodes[j][:2]) < 0.72:
                return None
    for a, b, _ in S.links:
        same = ring[a] == ring[b] and ring[a] > 0
        if same:
            ta = math.atan2(T.nodes[a][0], T.nodes[a][1]); tb = math.atan2(T.nodes[b][0], T.nodes[b][1])
            same = abs((ta - tb + math.pi) % (2 * math.pi) - math.pi) <= math.pi / 2 + 1e-9
        T.links.append((a, b, (0.0, 0.0) if same else None))
    if T.nodes[0][0] != 0 or T.nodes[0][1] != min(v for _, v, _ in T.nodes):
        return None
    probs = [p for p in A.check(T) if not p.startswith("notables")]
    return None if probs else T


def library(auth):
    """name -> snapped Shape for every figure of auth that survives the snap."""
    out = {}
    for name, S in auth.items():
        T = snap(S)
        if T is not None:
            out[name] = T
    return out


if __name__ == "__main__":
    ok = bad = 0
    for f in A.SHAPES:
        S = f(); T = snap(S)
        print("%-24s %s" % (S.name, "snaps" if T else "keeps its drawing"))
        ok += bool(T); bad += not T
    print("snap", ok, "keep", bad)
