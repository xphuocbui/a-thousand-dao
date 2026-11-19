"""Thunder (932), hand-placed by Claude 2026-11-19 after the underlay idea "thunder 3" (design/dao-do/underlays/thunder-3.png; user: "Thunder 3 is good ... please manually add more both inside and outside the figures").

  - the five web cells (between the inner pentagon round the start and the outer ring): in each, a main bolt striking
    out from the pentagon's mid node along the cell's axis, forked, and a second bolt striking in from the outer ring
    on the other side; lightning is drawn as an even zigzag (each vertex alternately left and right of the stroke), the
    one place straight links are the point;
  - the two outer cells under the arc: auspicious clouds (xiangyun), double curls rising from one stem, as true
    spiral arcs;
  - outside, on the open side: clouds, sparks and short bolts hung outwards from the outer ring.
Positions are given in polar form round the island centre C: (r, a), a = degrees from +y towards +x.
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design',
                                'dao_do_rework', 'cells'))
from celllib import road  # noqa: E402

THEME = 'island'
C = (-103.665, -33.683)
S, N = 'small', 'notable'


def D(a):
    t = math.radians(a)
    return (math.sin(t), math.cos(t))


def Q(c, r, a):
    d = D(a)
    return (c[0] + r * d[0], c[1] + r * d[1])


def P(r, a):
    return Q(C, r, a)


def ang(c, p):
    return math.degrees(math.atan2(p[0] - c[0], p[1] - c[1]))


class Fig:
    def __init__(self):
        self.nodes, self.links = {}, []

    def xy(self, k):
        return road(k) if isinstance(k, int) else self.nodes[k][0]

    def path(self, start, pts, kinds, pre):
        """Straight links through the given polar points (r, a)."""
        prev = start
        for i, ((r, a), k) in enumerate(zip(pts, kinds)):
            key = f'{pre}{i}'
            self.nodes[key] = (P(r, a), k)
            self.links.append((prev, key, None))
            prev = key
        return prev

    def turtle(self, start, heading, side, steps, kinds, pre):
        p, h, prev = self.xy(start), heading, start
        for i, ((L, th), kind) in enumerate(zip(steps, kinds)):
            q = Q(p, L, h + side * th / 2)
            c = None
            if th > 0.5:
                R = L / (2 * math.sin(math.radians(th) / 2))
                c = Q(p, R, h + side * 90)
            key = f'{pre}{i}'
            self.nodes[key] = (q, kind)
            self.links.append((prev, key, c))
            p, h, prev = q, h + side * th, key
        return prev

    def zig(self, start, heading, n, step, amp, first, kinds, pre, bend=0.0):
        """A lightning stroke: n vertices at even steps along a line (turning `bend` degrees a step), each offset amp
        alternately to one side and the other (first = +1 or -1), straight links."""
        p0, h, prev = self.xy(start), heading, start
        base = p0
        for i, k in enumerate(kinds[:n]):
            base = Q(base, step, h)
            side = first if i % 2 == 0 else -first
            key = f'{pre}{i}'
            self.nodes[key] = (Q(base, amp, h + 90 * side), k)
            self.links.append((prev, key, None))
            prev = key
            h += bend
        return prev

    def out(self):
        return (self.nodes, self.links)


thunder = {}

# --- the web cells: (axis, pentagon mid node, fork side, second bolt's outer node) ------------------------------------
WEB = ((-72, 553, 1, 563), (0, 555, 1, 566), (72, 557, 1, 569), (144, 559, -1, 574), (-144, 561, -1, 577))
for a, mid, fs, sb in WEB:
    f = Fig()
    f.zig(mid, a, 6, 0.85, 0.42, fs, (S, S, S, S, S, N), 'z')
    f.zig('z2', a + fs * 38, 3, 0.85, 0.38, -fs, (S, S, N), 'f')
    thunder[f'bolt{a}'] = f.out()
    a0 = ang(C, road(sb))
    s = 1 if ((a0 - a + 180) % 360 - 180) > 0 else -1          # which side of the axis the second bolt is on
    f = Fig()
    f.zig(sb, a0 + 180 + s * 10, 3, 0.85, 0.4, -s, (S, S, N), 'z')
    thunder[f'strike{a}'] = f.out()

# --- the outer cells: clouds -----------------------------------------------------------------------------------------
CURL = [(1.3, 0), (1.25, 25), (1.15, 45), (1.0, 65), (0.9, 80), (0.8, 85)]


def cloud(name, rid, heading, side, stem=1, n=6):
    """A xiangyun: a stem, then two curls parting from its end and turning away from each other."""
    f = Fig()
    k = f.turtle(rid, heading, side, [(1.3, 0)] * stem, (S,) * stem, 's')
    f.turtle(k, heading - 45, -1, CURL[:n], (S,) * (n - 1) + (N,), 'a')
    f.turtle(k, heading + 45, 1, CURL[:n - 1], (S,) * (n - 2) + (N,), 'b')
    thunder[name] = f.out()


cloud('cloud_579', 579, ang(road(579), C) + 10, 1, n=5)
cloud('cloud_581', 581, ang(road(581), C) - 5, -1)
cloud('cloud_583', 583, ang(road(583), C) + 8, 1, n=5)
cloud('cloud_585', 585, ang(road(585), C) - 8, -1, n=4)


def bolt(name, rid, heading, n, fork_at=None, fs=1, first=1):
    f = Fig()
    f.zig(rid, heading, n, 0.85, 0.42, first, (S,) * (n - 1) + (N,), 'z')
    if fork_at is not None:
        f.zig(f'z{fork_at}', heading + fs * 38, 3, 0.85, 0.38, -fs, (S, S, N), 'f')
    thunder[name] = f.out()


def out_dir(rid):
    return ang(C, road(rid))


# --- outside, on the open side (the tree is beyond a ~ 60-100, more than 22 out) ------------------------------------
cloud('out_cloud_567', 567, out_dir(567), 1, stem=2, n=5)
bolt('out_bolt_569', 569, out_dir(569) - 6, 5, fork_at=1, fs=-1)
cloud('out_cloud_571', 571, out_dir(571) + 4, 1, stem=1, n=5)
bolt('out_bolt_573', 573, out_dir(573), 5, fork_at=2, fs=1)
bolt('out_spark_566', 566, out_dir(566) - 4, 3)
# --- outside, beyond the left arc ---------------------------------------------------------------------------------
cloud('arc_cloud_580', 580, out_dir(580), 1, stem=1, n=5)
cloud('arc_cloud_582', 582, out_dir(582), 1, stem=1, n=5)
cloud('arc_cloud_584', 584, out_dir(584), 1, stem=1, n=5)

CELLS = {932: thunder}
