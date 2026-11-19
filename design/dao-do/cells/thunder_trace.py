"""Thunder (932), traced by hand by Claude 2026-11-19 from the underlay idea the user picked, "thunder 3"
(design/dao-do/underlays/thunder/thunder-3.png; user: "that looks nothing like the underlay?").

The dots of thunder 3 were measured (tools/design/dao_do_rework/underlay/dots.py, links.py) and are used where they are; Claude read each
chain off the picture and chose the joins and kinds (cloud eyes and bolt tips = notables). Changes the rules force:
  - a figure hangs from at most two road nodes and never touches the start figure: bolts that spring from the start in
    the picture hang from the nearest pentagon or ring road node, the zigzags inside the inner pentagon (the start's own
    space) are left out, and the bottom bolt that meets three roads is split in two;
  - two smalls before the first notable from each road;
  - dots that sit too close to a road node are moved off it slightly.
Bolts are straight zigzags as drawn; cloud links follow the drawn line (each arc through the line's midpoint).
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
UD = os.path.join(HERE, '..', 'underlays', 'thunder')
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from celllib import road, roads  # noqa: E402
from trace_lib import Underlay, even_chain, thin  # noqa: E402
import swirl_lib as sw  # noqa: E402

THEME = 'island'
S, N = 'small', 'notable'
U = Underlay(os.path.join(UD, 'thunder-3.png'), -103.7, -33.7, 19.0, road)
DOT = {d['i']: tuple(d['px']) for d in json.load(open(os.path.join(UD, 'keep-thunder.json')))}


def a(x, y):            # from the 2x crops read by eye: show-th-a (offset 0), -b (300, 300), -c (1100, 400)
    return (x / 2, y / 2)


def b(x, y):
    return ((x + 300) / 2, (y + 300) / 2)


def c(x, y):
    return ((x + 1100) / 2, (y + 400) / 2)


def R(p, tol=0.7):
    """The road node at image pixel p."""
    q = U.to_map(p)
    rs = roads()
    j = min(rs, key=lambda k: math.dist(rs[k], q))
    assert math.dist(rs[j], q) < tol, (p, q, j, rs[j])
    return j


def d(i, kind=S, nudge=(0, 0)):
    p = DOT[i]
    return (f'd{i}', (p[0] + nudge[0], p[1] + nudge[1]), kind)


def g(name, p, kind=S):
    return (name, p, kind)


class Fig:
    def __init__(self):
        self.nodes, self.links = {}, []

    def out(self):
        return (self.nodes, self.links)


T = {}
ALL = None                      # straight links for bolts


def bolt(name, *chains):
    f = Fig()
    for ch in chains:
        U.chain(f, ch, straight=ALL_PAIRS(ch))
    T[name] = f.out()


def ALL_PAIRS(ch):
    keys = [e if isinstance(e, (int, str)) else e[0] for e in ch]
    return {(keys[i], keys[i + 1]) for i in range(len(keys) - 1)}


def cloud(name, *chains, direct=()):
    f = Fig()
    for ch in chains:
        even_chain(U, f, ch, direct=set(direct))
    thin(f)
    T[name] = f.out()


# --- upper outer cell: one cloud tangle hung from road 575 (top spiral) and road 582 (its lower tail) --------------
cloud('cloud_upper',
      [R(a(972, 350)), g('u0', (481, 121)), d(1), d(0), d(2), d(6, N), d(7), ('mid', S), d(4, N)],
      [d(3, 'small!'), 'd6'],
      [d(5, 'small!', nudge=(4, 6)), 'd3'],
      [d(14, 'small!'), d(8), 'd5'],
      [d(15, 'small!'), 'd14', d(18, N), d(22), d(19), d(11, 'small!'), d(9), ('mid', S), d(12, N)],
      ['d11', d(13), ('mid', S), d(10, N)],
      ['d18', g('e0', (232, 285)), g('e1', (215, 311)), g('e2', (187, 307)), d(28, N)],
      ['d15', d(26), d(34, 'small!'), d(47), ('mid', S), d(48, N)],
      [R(a(103, 722)), g('e3', (107.5, 320)), 'd34'], direct={('d3', 'd6')})
# --- lower outer cell: three clouds hung from the arc ---------------------------------------------------------------
cloud('cloud_583', [R(a(58, 1022)), d(81), d(69), g('t0', (106, 410)), d(67), d(79), g('t2', a(335, 1050)), d(106),
                    d(112, N)])
cloud('cloud_584', [R(a(103, 1322)), d(133), g('jn', (105, 592), 'small!'), d(124), d(130), d(142, N), d(160),
                    g('e4', (215, 723.5)), g('e5', (222.5, 747.5)), d(174, N)],
      ['jn', d(117), d(89), g('t1', (110, 471)), d(84, N)])
cloud('cloud_585', [R(a(240, 1593)), d(181, 'small!'), d(172), d(153), d(140), d(152, N)],
      ['d181', d(184, 'small!'), d(187, N)])

# --- the web cells: bolts ---------------------------------------------------------------------------------------------
bolt('bolt_a', [R(b(725, 400)), d(41), d(36), d(29, N), d(24), d(21), d(17, N)])
bolt('bolt_b', [R(b(470, 218)), g('g0', b(467, 240)), d(31), d(35), d(46), d(49, N), d(57), d(59), d(63), R(b(590, 537))],
     ['d57', d(52), d(51), d(42), d(43), d(38), g('g1', b(240, 302), N)])
bolt('bolt_c', [R(b(725, 400)), d(40), d(33), d(27, N), d(23), d(20), d(16), R(b(900, 183))])
bolt('bolt_d', [R(b(862, 537)), d(64), d(61), d(56), d(53), d(44, N), d(39), d(30, N)],
     ['d56', d(50), d(45), d(37, N), d(32), d(25), g('g2', b(1145, 232)), R(b(1163, 212))])
bolt('bolt_e', [R(b(1033, 625)), g('g11', (651, 466)), d(72), d(83), d(77, N), d(86), d(82), d(91, N)])
bolt('bolt_f', [R(b(945, 797)), d(109), d(113), d(101), d(94), d(85), d(75, N), d(73), d(70),
                d(68, N)],
     ['d101', d(105), d(92, N), d(102), d(90), d(93), g('g3', b(1370, 676)), R(b(1395, 668))])
bolt('bolt_g', [R(b(1238, 1162)), g('g4', b(1222, 1140)), d(157), d(155), d(144, N), d(147), d(137), d(141), d(134),
                d(131, N)])
bolt('bolt_h', [R(b(915, 985)), d(138), d(132), d(129, N), d(122), d(121), d(114), d(110, N)])
bolt('bolt_j', [R(b(727, 955)), d(146), d(151), d(161), d(164, N), d(173), d(177), d(180), d(183), g('g7', b(775, 1368)),
                R(b(778, 1395))],
     ['d173', d(167), d(170, N), d(176), g('g8', b(952, 1228), N)])
bolt('bolt_k', [R(b(505, 795)), d(104), d(98), d(108), d(116), d(107, N), d(111), d(103), g('g9', b(88, 777)), R(b(55, 777))],
     ['d108', g('g10', b(337, 750)), d(97), d(88), d(87, N), d(78), d(76, N)])
bolt('bolt_l', [R(b(290, 1235)), d(163), d(158), d(148), d(149, N), d(139), d(136), d(128), d(126), d(123, N)])
bolt('bolt_m', [R(b(535, 985)), g('g12', (428, 631)), d(135), d(127), d(125, N), d(120), d(115, N)])
bolt('bolt_n', [R(a(455, 1808)), d(190), d(189), d(188, N), d(186), d(185), d(182), d(179, N, nudge=(-2, 5))])
bolt('bolt_i', [R(b(727, 955)), d(145, nudge=(-4, 0)), d(150), d(159), d(162, N), d(168), d(171), d(166), d(169), d(175),
                d(178, N)])
bolt('bolt_start_top', [R(b(725, 400)), g('p0', (512, 364)), g('p1', (525, 382)), g('p2', (511, 396)),
                        g('p3', (529, 412), N), g('p4', (512, 429)), g('p5', (527, 451)), g('p6', (513, 479), N)])
bolt('bolt_start_left', [R((402, 548)), g('q0', (403, 512)), g('q1', (420, 521)), g('q2', (432, 511)),
                         g('q3', (447, 521), N)])

# --- outside, on the open side: spark curls ---------------------------------------------------------------------------
cloud('spark_upper', [R(c(597, 570)), d(65), d(60), ('mid', S), d(54, N)])
cloud('spark_upper2', [R(c(597, 570)), g('s0', c(650, 548)), g('s1', c(706, 500)), ('mid', S), d(74, N)])
cloud('spark_lower', [R(c(465, 798)), g('s2', c(547, 784)), d(118), ('mid', S), d(119, N)])
cloud('spark_lower2', [R(c(465, 798)), d(143), d(156), d(165), ('mid', S), d(154, N)])

# --- more, in the same language (user: "add more stuff, same theme") ------------------------------------------------
# beaded xiangyun clouds beyond the left arc and on the open side, and forked bolts striking out from the open side
TC = (-103.665, -33.683)
for name, rid, side, stem, n in (('arc_cloud_580', 580, 1, 1, 5), ('arc_cloud_582', 582, -1, 1, 5),
                                 ('arc_cloud_584', 584, 1, 1, 5), ('open_cloud_567', 567, -1, 2, 5)):
    f = Fig()
    xyf = (lambda f: (lambda k: road(k) if isinstance(k, int) else f.nodes[k][0]))(f)
    sw.cloud(f, xyf, rid, sw.ang(TC, road(rid)), side, stem, n, 'c')
    T[name] = f.out()
import thunder_ul  # noqa: E402
for name in ('out_bolt_569', 'out_bolt_573', 'out_spark_566'):
    T[name] = thunder_ul.thunder[name]

CELLS = {932: T}
