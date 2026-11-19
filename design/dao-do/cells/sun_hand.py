"""The Sun's tree (inside the outer ring), hand-traced by Claude 2026-11-19 from the picked underlay (openai/underlay/sun/
inout-3.png; user: "1 please go", after the automatic trace lost the tree's character).

Claude read each branch system off the picture (gridded close-ups, openai/underlay/sun/grid-top.png and grid-bot.png):
its root, its forks and each branch's curl and eye, in order; the tracer follows the drawn line between those points
(trace_lib.even_chain) and spaces nodes evenly, about 0.8 apart, under the Sun's looser spacing (rules 3.2). Roots are
the road nodes nearest where the picture springs them (the picture also springs a branch from the inner ring between
road nodes; it starts from the nearest road node instead). The small suns become rings of five round a notable centre,
joined to the branch end beside them. Right half traced, mirrored by sun_trace.py.

Systems (right half): A from 525 (top); B from 524 sweeping down to 523; C from 523 to 522; D from 522 (the big curl,
the sun, the arm down and round); E the roots from 521 (bottom).
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, 'openai', 'underlay'))
from trace_lib import Underlay, even_chain, thin  # noqa: E402

S, N = 'small', 'notable'
UD = os.path.join(HERE, 'openai', 'underlay', 'sun')


class SunUnderlay(Underlay):
    """Lines in this picture are vermilion, orange and gold: any bright pixel off the roads is line."""

    def line_px(self, x, y):
        return max(self.px[x, y]) > 90 and (x, y) not in self.roadpx

    def clear(self, q, linked=()):
        """The Sun's spacing minima (0.62 from road and start nodes, 0.37 from road links), no further."""
        for _ in range(30):
            moved = False
            for i, r in self.rnodes:
                if i in linked:
                    continue
                d = math.dist(q, r)
                if d < 0.62:
                    f = (0.62 - d) / max(d, 1e-6); q = (q[0] + (q[0] - r[0]) * f, q[1] + (q[1] - r[1]) * f); moved = True
            for A, B in self.rsegs:
                vx, vy = B[0] - A[0], B[1] - A[1]; L2 = vx * vx + vy * vy
                t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2)) if L2 else 0.0
                P = (A[0] + t * vx, A[1] + t * vy); d = math.dist(q, P)
                if d < 0.37 and min(math.dist(q, A), math.dist(q, B)) > 0.05:
                    f = (0.37 - d) / max(d, 1e-6); q = (q[0] + (q[0] - P[0]) * f, q[1] + (q[1] - P[1]) * f); moved = True
            if q[0] < 0.31:
                q = (0.31, q[1]); moved = True
            if not moved:
                break
        return q


def T(x, y):                       # a point read off grid-top.png (3x crop from image (500, 190))
    return (500 + x / 3, 190 + y / 3)


def Bt(x, y):                      # a point read off grid-bot.png (3x crop from image (500, 510))
    return (500 + x / 3, 510 + y / 3)


class Fig:
    def __init__(self):
        self.nodes, self.links = {}, []


SUNS = {'s0': T(394, 190), 's1': T(637, 378), 's2': T(870, 855), 's3': Bt(620, 520)}


def build(road):
    U = SunUnderlay(os.path.join(UD, 'inout-3.png'), 0.0, 112.0, 21.0, road)
    w = lambda name, p: (name, p, S)              # a waypoint on the drawn line
    f = lambda name, p: (name, p, 'small!')       # a fork, kept as a node
    e = lambda name, p: (name, p, N)              # an eye or tip, a notable
    ch = lambda fig, keys: even_chain(U, fig, keys, step=0.8)
    pieces = {}

    # A, from 525 (top): the trunk rises and curls over to an eye; four branches off it
    A = Fig()
    ch(A, [525, w('a0', T(175, 470)), w('a1', T(168, 420)), f('F1', T(180, 372)), w('a2', T(215, 345)),
           f('F2', T(245, 322)), f('F3', T(300, 312)), w('a3', T(335, 308)), f('F4', T(380, 318)), w('a4', T(415, 345)),
           w('a5', T(427, 395)), w('a6', T(415, 450)), w('a7', T(385, 470)), e('aE', T(345, 435))])
    ch(A, ['F1', w('b0', T(183, 300)), w('b1', T(175, 262)), w('b2', T(148, 225)), w('b3', T(108, 226)),
           w('b4', T(88, 256)), e('bE', T(124, 272))])
    ch(A, ['F2', w('c0', T(236, 285)), w('c1', T(215, 218)), w('c2', T(178, 186)), w('c3', T(136, 140)),
           w('c4', T(130, 98)), w('c5', T(160, 76)), e('cE', T(176, 110))])
    ch(A, ['F3', w('d0', T(318, 268)), w('d1', T(330, 230)), w('d2', T(310, 185)), w('d3', T(272, 160)),
           w('d4', T(252, 122)), w('d5', T(275, 100)), e('dE', T(296, 124))])
    ch(A, ['F3', w('g0', T(352, 272)), e('gE', T(383, 244))])                                      # to the sun s0
    ch(A, ['F4', w('h0', T(432, 325)), w('h1', T(472, 330)), w('h2', T(520, 322)), w('h3', T(556, 292)),
           w('h4', T(552, 252)), w('h5', T(522, 240)), e('hE', T(512, 262))])
    pieces['tree_A'] = A

    # B, from 524 sweeping round to 523: branches up into a curl, out to the right, to the sun s1, and two below
    B = Fig()
    ch(B, [524, w('a0', T(432, 610)), w('a1', T(470, 582)), f('G1', T(505, 566)), w('a2', T(575, 555)),
           w('a3', T(640, 580)), w('a4', T(672, 632)), w('a5', T(664, 692)), w('a6', T(632, 745)), f('G4', T(610, 820)),
           f('G5', T(612, 865)), w('a7', T(625, 920)), 523])
    ch(B, ['G1', f('G2', T(560, 520)), w('b0', T(556, 488)), w('b1', T(566, 437)), w('b2', T(545, 402)),
           w('b3', T(508, 400)), e('bE', T(507, 430))])
    ch(B, ['G2', f('G3', T(645, 515)), f('G6', T(700, 520)), w('c1', T(760, 532)), w('c2', T(800, 575)),
           e('cE', T(766, 600))])
    ch(B, ['G3', w('d0', T(626, 478)), e('dE', T(632, 432))])                                     # to the sun s1
    ch(B, ['G6', w('k1', T(745, 508)), w('k2', T(765, 470)), w('k3', T(742, 440)),
           e('kE', T(715, 463))])
    ch(B, ['G4', w('m0', T(575, 772)), e('mE', T(556, 708))])
    ch(B, ['G5', w('n0', T(655, 855)), f('n1', T(718, 830)), w('n2', T(760, 790)), w('n3', T(765, 740)),
           w('n4', T(752, 702)), w('n5', T(792, 660)), w('n6', T(850, 658)), e('nE', T(830, 690))])
    ch(B, ['n1', e('pE', T(812, 858))])                                                           # to the sun s2
    pieces['tree_B'] = B

    # C, from 523 down and round to 522, curls off its shoulder
    C = Fig()
    ch(C, [523, w('a0', Bt(570, 40)), w('a1', Bt(615, 85)), f('H1', Bt(620, 145)), w('a2', Bt(595, 205)),
           w('a3', Bt(540, 262)), w('a4', Bt(485, 315)), f('J', Bt(432, 342)), 522])
    ch(C, ['H1', f('H2', Bt(655, 180)), w('b0', Bt(720, 170)), w('b1', Bt(770, 140)), w('b2', Bt(790, 62)),
           w('b3', Bt(842, 62)), e('bE', Bt(876, 96))])
    ch(C, ['H2', w('c0', Bt(626, 215)), e('cE', Bt(658, 256))])

    # D, forking off C just before 522: out to the right into the big curl, a branch to the sun s3, a hook up; and the
    # arm down and round (it ends a curl early: in the picture it runs 0.35 beside the roots)
    D = C
    ch(D, ['J', f('I1', Bt(470, 370)), w('a1', Bt(560, 385)), f('I2', Bt(605, 415)),
           w('a2', Bt(652, 432)), w('a3', Bt(712, 438)), w('a4', Bt(782, 424)), w('a5', Bt(836, 370)),
           w('a6', Bt(850, 300)), w('a7', Bt(822, 246)), w('a8', Bt(775, 236)), e('aE', Bt(772, 282))])
    ch(D, ['I2', e('sE', Bt(618, 462))])                                                          # to the sun s3
    ch(D, ['I2', w('h0', Bt(650, 405)), w('h1', Bt(680, 372)), e('hE', Bt(626, 318))])
    Darm = Fig()
    ch(Darm, [522, w('r0', Bt(365, 395)), w('r1', Bt(350, 445)), w('r2', Bt(310, 475)), w('r3', Bt(258, 480)),
           w('r4', Bt(222, 508)), e('rE', Bt(214, 548))])
    pieces['tree_CD'] = D
    pieces['tree_D_arm'] = Darm

    # E, the roots from 521 (bottom of the inner ring)
    E = Fig()
    ch(E, [521, w('a0', Bt(122, 492)), w('a1', Bt(132, 540)), f('K1', Bt(180, 585)), f('a2', Bt(258, 600)),
           f('K2', Bt(360, 600)), f('K3', Bt(440, 605)), w('a3', Bt(500, 590)), w('a4', Bt(560, 600)),
           w('a5', Bt(610, 625)), w('a6', Bt(635, 665)), e('aE', Bt(598, 672))])
    ch(E, ['K1', w('b0', Bt(205, 650)), e('bE', Bt(182, 700))])
    ch(E, ['a2', w('c0', Bt(300, 642)), w('c1', Bt(335, 690)), w('c2', Bt(335, 760)), w('c3', Bt(305, 805)),
           w('c4', Bt(248, 815)), w('c5', Bt(215, 776)), w('c6', Bt(155, 776)), e('cE', Bt(168, 830))])
    ch(E, ['K2', w('d0', Bt(410, 620)), w('d1', Bt(446, 646)), w('d2', Bt(465, 705)), w('d3', Bt(440, 758)),
           e('dE', Bt(396, 726))])
    ch(E, ['K3', w('k0', Bt(500, 640)), w('k1', Bt(526, 690)), e('kE', Bt(520, 744))])
    pieces['tree_E'] = E

    # the small suns: a ring of five round a notable centre, joined to the branch end nearest it
    for sk, sp in SUNS.items():
        Cs = U.to_map(sp)
        d, name, k = min((math.dist(q, Cs), nm, kk) for nm, fg in pieces.items() for kk, (q, kd) in fg.nodes.items())
        fg = pieces[name]
        if d < 1.2:                                  # the branch end lands on the ring: the node before it joins instead
            prev = [l for l in fg.links if k in l[:2]]
            j = [y for l in prev for y in l[:2] if y != k][0]
            fg.links = [l for l in fg.links if k not in l[:2]]
            del fg.nodes[k]
            k = j
        a0 = math.degrees(math.atan2(fg.nodes[k][0][0] - Cs[0], fg.nodes[k][0][1] - Cs[1]))
        ring = []
        for i in range(5):
            t = math.radians(a0 + 72 * i); rk = f'{sk}_{i}'
            fg.nodes[rk] = ((Cs[0] + 0.65 * math.sin(t), Cs[1] + 0.65 * math.cos(t)), S); ring.append(rk)
        fg.links += [(ring[i], ring[(i + 1) % 5], Cs) for i in range(5)]
        fg.nodes[f'{sk}_c'] = (Cs, N)
        fg.links.append((ring[2], f'{sk}_c', None))
        if fg.nodes[k][1] == N:
            fg.nodes[k] = (fg.nodes[k][0], S)
        fg.links.append((k, ring[0], None))
    out = {}
    for nm, fg in pieces.items():
        thin(fg, gap=0.55)
        out[nm] = (fg.nodes, fg.links)
    return out
