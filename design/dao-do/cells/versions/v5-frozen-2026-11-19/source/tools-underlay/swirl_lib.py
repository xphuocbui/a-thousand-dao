"""Beaded swirls in the traced islands' language (hand-placed figures; this only does the geometry): a turtle walks
from a start at even steps, turning a little more each step, so the line tightens into a spiral and ends on an eye.
Every link is a true circle arc (centre equidistant from both ends by construction). Angles: a = degrees from +y
towards +x."""
import math


def D(a):
    t = math.radians(a)
    return (math.sin(t), math.cos(t))


def Q(c, r, a):
    d = D(a)
    return (c[0] + r * d[0], c[1] + r * d[1])


def ang(c, p):
    return math.degrees(math.atan2(p[0] - c[0], p[1] - c[1]))


def spiral(n, tight=1.0, step=1.15):
    """Steps for an n-node swirl: chords shrinking from `step`, turns growing to a curl; `tight` scales the turns."""
    out = []
    for i in range(n):
        f = i / max(1, n - 1)
        out.append((step * (1 - 0.25 * f), tight * (6 + 70 * f ** 1.3)))
    return out


def walk(fig, xy_of, start, heading, side, steps, kinds, pre):
    p, h, prev = xy_of(start), heading, start
    for i, ((L, th), kind) in enumerate(zip(steps, kinds)):
        q = Q(p, L, h + side * th / 2)
        c = None
        if th > 0.5:
            R = L / (2 * math.sin(math.radians(th) / 2))
            c = Q(p, R, h + side * 90)
        key = f'{pre}{i}'
        fig.nodes[key] = (q, kind)
        fig.links.append((prev, key, c))
        p, h, prev = q, h + side * th, key
    return prev, h


def swirl(fig, xy_of, start, heading, side, n, pre, tight=1.0, step=1.15, eye='notable'):
    """One swirl of n nodes from start (a road id or a node key), its last node the eye."""
    kinds = ['small'] * (n - 1) + [eye]
    return walk(fig, xy_of, start, heading, side, spiral(n, tight, step), kinds, pre)


def cloud(fig, xy_of, start, heading, side, stem, n, pre, part=50, tight=1.0):
    """A xiangyun: a stem of `stem` gently curving nodes, then two swirls parting from its end and curling away from
    each other (one of n nodes, one of n - 1)."""
    k, h = walk(fig, xy_of, start, heading, side, [(1.15, 8)] * stem, ['small'] * stem, pre + 's')
    swirl(fig, xy_of, k, h - side * part, -side, n, pre + 'a', tight)
    swirl(fig, xy_of, k, h + side * part, side, n - 1, pre + 'b', tight)
