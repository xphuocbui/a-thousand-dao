"""The Shadow Shrine (Ám Từ, the road circle 625-636 off the Moon island, cell 933), hand-traced by Claude 2026-11-19
from the pictures the user picked: "the eclipse with moonphases 2 for the shrine, the directly above it extend it with
another shadow lotus 1" (openai/underlay/shrine/eclipse-2.png and lotus-1.png). It replaces the waxing moon the Moon
file used to put here.

Claude read every line's waypoints off gridded close-ups (picture pixels); the tracer follows the drawn line between
them (trace_lib.even_chain) and spaces nodes about 0.62 apart. Circles (the eclipse, the phase moons) are laid exactly
round their measured centres. The Shrine uses the Sun's looser spacing (user 2026-11-19, rules 3.2). The right half is
traced and mirrored; the ring is about 2 degrees off a mirror, so mirrored doors take the nearest road node.

The eclipse is one piece, as the picture is one web: the dark disc's ring, the new crescent on its stem above, the
full moon on its stem below, five phases a side chained to each other and to the ring, a swirl beside each chain, and
the veil bands round the edge. Changes the rules force: the web hangs from roads 626 and 629 by a short stem into the
first crescent (the picture floats); the bands join the web (top: a crescent tip to the inner band; sides: the middle
of the band to the half moon; bottom: the full moon to the inner band), since as separate pieces they sit closer to
the phases than two pieces may; and the two top bands are joined at their ends.

The lotus first stood above the Shrine's circle; moved 2026-11-19 (user: "move the lotus to directly above the
crescent moon", "In the Moon's cup") into the Moon island's crescent, rising above its full moon, at 0.85 scale;
its bottom leaves' tips root straight out along the cup to inner-arc roads 615 and 622. Node spacing along the lines
was widened the same day (user: "the node frequency along the new lines are a bit too high"): about 0.85 apart
in the eclipse, 0.9 in the lotus, then 30% sparser again (1.45 and 1.55: their forks, tips and rings stay, so the step widens more); the dark disc keeps only the nodes its lines leave from, the phase moons 4 or 5.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, 'openai', 'underlay'))
from celllib import road  # noqa: E402
from trace_lib import even_chain  # noqa: E402
from trace_fine import Fig, Fine, ring, link, mirror, thin_at  # noqa: E402

THEME = 'island'
S, N = 'small', 'notable'
UD = os.path.join(HERE, 'openai', 'underlay', 'shrine')
AXIS = 107.808                                      # the ring's centre (mean of road nodes 625-636)


def w(k, p):
    return (k, p, S)


def f(k, p):
    return (k, p, 'small!')


def e(k, p):
    return (k, p, N)


def eclipse():
    U = Fine(os.path.join(UD, 'eclipse-2.png'), 107.8, -24.9, 10.0, road, axis=AXIS)
    F = Fig()
    ch = lambda keys, step=1.45, direct=(): even_chain(U, F, keys, step=step, direct=direct)   # user: fewer nodes, then 30% sparser

    def on_axis(fn):                                  # a chain along the axis: no clamp
        U.clamp = False
        fn()
        U.clamp = True

    # the dark disc: a ring round (512, 496), r 150 px, nodes where the chains and swirls leave it
    R = ring(U, F, 'R', (512, 496), 150, [0, 18.9, 30, 59, 90, 122, 161, 180], [N, S, S, S, N, S, S, N], closed=False)
    R0, R19, R30, R59, R90, R122, R161, R180 = R

    # the new crescent above, a cup of two arcs, on its stem from the ring's top
    F.nodes['cupO'] = (U.to_map((512, 255)), S)
    F.nodes['cupI'] = (U.to_map((512, 228)), S)
    F.nodes['st1'] = (U.to_map((512, 300)), S)
    F.links += [('cupO', 'st1', None), ('st1', R0, None)]
    ch([f('tip', (553, 199)), w('o1', (555, 216)), w('o2', (547, 237)), w('o3', (532, 250)), 'cupO'])
    F.links.append(('tip', 'cupI', _arc(U, (553, 199), (531, 231), (512, 228))))      # inner arc: too thin for nodes

    # the full moon below, on its stem from the ring's bottom
    FM = ring(U, F, 'FM', (512, 763), 47, [0, 90, 180], [S, S, N], closed=False)
    F.links += [(R180, FM[0], None)]

    # phase 1, the waxing crescent (upper right): tips, outer arc (where the door stem and the chain to phase 2
    # leave it) and inner arc
    ch([e('P1t', (657, 222)), w('a', (687, 230)), w('b', (697, 244)), f('P1d', (700, 264)), f('P1n', (692, 282)),
        w('c', (677, 293)), w('d', (656, 294)), f('P1l', (638, 286))])
    F.links.append(('P1t', 'P1l', _arc(U, (657, 222), (671, 257), (638, 286))))       # inner arc, one link
    ch([626, 'P1d'], direct=((626, 'P1d'),))
    # the chain from the new crescent past phase 1's lower tip to the ring
    ch(['tip', w('a', (567, 228)), w('b', (591, 231)), w('c', (615, 240)), w('d', (634, 253)), 'P1l'])
    ch(['P1l', w('a', (641, 308)), w('b', (627, 326)), w('c', (607, 341)), R30])

    # phase 2, the crescent at the right: tips, outer arc (its notable at the far side), inner arc
    ch(['P1n', w('a', (699, 289)), w('b', (716, 301)), w('c', (732, 318)), f('P2t', (739, 332))])
    ch(['P2t', w('a', (757, 329)), w('b', (780, 337)), w('c', (794, 353)), e('P2e', (797, 374)), w('d', (789, 392)),
        f('P2n', (777, 403)), w('g', (754, 407)), f('P2l', (732, 398))])
    F.nodes['P2i'] = (U.to_map((764, 366)), S)                                          # inner arc: one held node
    F.links += [('P2t', 'P2i', _arc(U, (739, 332), (760, 345), (764, 366))),
                ('P2i', 'P2l', _arc(U, (764, 366), (754, 386), (732, 398)))]
    ch([R59, w('a', (648, 415)), w('b', (668, 409)), w('c', (690, 411)), w('d', (710, 402)), 'P2l'])

    # phase 3, the half moon at the right: a circle with its terminator
    P3 = ring(U, F, 'P3a', (790, 496), 36, [0, 90, 180, 270], [S, N, S, S])
    F.links.append((P3[0], P3[2], _arc(U, (790, 460), (797, 496), (790, 532))))
    ch(['P2n', w('a', (786, 430)), P3[0]])
    ch([R90, w('a', (690, 492)), w('b', (712, 501)), w('c', (736, 503)), P3[3]])

    # phase 4, gibbous (lower right): a circle with its terminator
    P4 = ring(U, F, 'P4a', (755, 627), 40, [15, 105, 199, 278], [S, N, S, S])
    F.links.append((P4[0], P4[2], _arc(U, (765, 588), (764, 630), (742, 665))))
    ch([P3[2], w('a', (785, 560)), w('b', (775, 581)), P4[0]])
    ch([R122, w('a', (652, 596)), w('b', (674, 612)), w('c', (700, 620)), P4[3]])

    # phase 5, gibbous (below): a circle with its terminator
    P5 = ring(U, F, 'P5a', (664, 724), 40, [0, 90, 180, 225, 270], [S, S, N, S, S])
    F.links.append((P5[0], P5[2], _arc(U, (664, 684), (676, 724), (664, 764))))
    ch([P4[2], w('a', (731, 686)), w('b', (714, 703)), P5[1]])
    ch([R161, w('a', (559, 661)), w('b', (571, 682)), w('c', (595, 695)), w('d', (618, 713)), P5[4]])
    ch([FM[1], w('a', (575, 763)), w('b', (596, 760)), P5[3]])

    # the swirls, one beside each chain, each curling in to an eye
    ch([R19, w('a', (561, 340)), w('b', (554, 327)), w('c', (568, 312)), w('d', (589, 300)), w('g', (600, 287)),
        w('h', (603, 275)), w('i', (597, 264)), w('j', (582, 262)), w('k', (570, 270)), e('S1e', (576, 281))])
    ch([R59, w('a', (644, 404)), w('b', (637, 393)), w('c', (644, 378)), w('d', (666, 369)), w('g', (684, 356)),
        w('h', (684, 333)), w('i', (667, 324)), w('j', (657, 332)), e('S2e', (662, 339))])
    ch([R90, w('a', (669, 487)), w('b', (685, 472)), w('c', (708, 470)), w('d', (728, 449)), w('g', (717, 432)),
        e('S3e', (705, 442))])
    ch([R122, w('a', (655, 572)), w('b', (680, 568)), w('c', (705, 567)), w('d', (721, 550)), w('g', (714, 528)),
        e('S4e', (697, 541))])
    ch([R161, w('a', (577, 654)), w('b', (601, 663)), w('c', (627, 666)), w('d', (649, 648)), w('g', (640, 627)),
        e('S5e', (629, 638))])

    # the veil bands. Top: an outer band and an inner one, joined at their ends; the crescent's tip holds the inner
    on_axis(lambda: (F.nodes.update({'T1a': (U.to_map((512, 142)), S), 'T2a': (U.to_map((512, 170)), S)})))
    # (the two run 0.45 apart, so their nodes are held staggered, one band's between the other's)
    ch(['T1a', f('T1c', (575, 162)), f('T1e', (669, 180))], step=9)
    ch(['T2a', f('T2f', (551, 175)), f('T2e', (626, 199))], step=9)
    link(F, 'T2e', 'T1e')
    link(F, 'T2f', 'tip')
    # sides: two bands, joined at their middles, the inner middle held by the half moon
    ch([e('B1s', (788, 277)), w('a', (811, 296)), w('b', (827, 316)), w('c', (832, 342)), w('d', (826, 370)),
        w('g', (822, 392)), w('h', (830, 427)), w('i', (850, 460)), f('B1m', (855, 498)), w('j', (853, 535)),
        w('k', (832, 570)), w('l', (825, 615)), w('m', (832, 648)), w('n', (829, 678)), w('o', (816, 702)),
        e('B1e', (799, 717))])
    ch([e('B2s', (844, 398)), w('a', (856, 424)), w('b', (869, 447)), w('c', (879, 472)), f('B2m', (881, 498)),
        w('d', (879, 525)), w('g', (870, 550)), w('h', (857, 571)), e('B2e', (844, 596))])
    link(F, 'B1m', 'B2m')
    link(F, 'B1m', P3[1])
    # bottom: two bands meeting at the right and rising to an end; the full moon holds the inner one
    on_axis(lambda: (F.nodes.update({'L1a': (U.to_map((512, 848)), S), 'L2a': (U.to_map((512, 874)), S)})))
    ch(['L1a', w('a', (556, 832)), w('b', (583, 811)), w('c', (614, 801)), w('d', (650, 810)), f('LJ', (679, 822))])
    ch(['L2a', w('a', (552, 865)), w('b', (583, 847)), w('c', (614, 832)), w('d', (648, 824)), 'LJ'])
    ch(['LJ', w('a', (702, 788)), w('b', (728, 778)), e('Le', (755, 778))])
    link(F, FM[2], 'L1a')

    thin_at(F, road, 0.5, 0.3)
    return mirror(F, AXIS, road)


LOTUS_AXIS, LOTUS_Y, LOTUS_HALF = 0.0, -115.53, 8.5      # in the Moon's cup, at 0.85 scale (user 2026-11-19)


def lotus():
    """The shadow lotus in the Moon's cup: lotus-1.png at 0.85 of the Shrine's scale, its axis on the Moon's (x 0) and
    its stem base 2 above the full moon; its two bottom leaf tips root out to roads 615 and 622, which hold it. The
    picture's own gold circle is not a road here."""
    U = Fine(os.path.join(UD, 'lotus-1.png'), LOTUS_AXIS, LOTUS_Y, LOTUS_HALF, road, axis=LOTUS_AXIS, gold_is_road=True)
    F = Fig()
    ch = lambda keys, step=1.55, direct=(): even_chain(U, F, keys, step=step, direct=direct)    # user: fewer nodes, then 30% sparser
    for k, y, kd in (('s798', 798, N), ('s719', 719, S), ('s683', 683, S),
                     ('s661', 661, N), ('s590', 590, S), ('ob', 557, S), ('ax2', 218, S),
                     ('apex', 161, N)):
        F.nodes[k] = (U.to_map((512, y)), kd)
    F.links += [(a, b, None) for a, b in (('s798', 's719'), ('s719', 's683'),
                                          ('s683', 's661'), ('s661', 's590'), ('s590', 'ob'), ('apex', 'ax2'))]
    # the top petal: its outer edge from the apex down to the second petal's inner edge; its inner edge from below the
    # apex down to the moon's upper tip, joined on the way by the second petal's inner edge and the white petal's
    ch(['apex', w('a', (532, 191)), w('b', (554, 215)), w('c', (577, 242)), w('d', (596, 276)), w('g', (606, 314)),
        f('J2', (606, 340))])
    ch([e('P2t', (705, 284)), w('a', (675, 301)), w('b', (647, 315)), w('c', (620, 329)), 'J2', w('d', (592, 351)),
        f('Jt', (571, 372))])
    ch(['ax2', w('a', (532, 275)), w('b', (552, 301)), w('c', (566, 331)), 'Jt', f('Jw', (566, 410))])
    ch([e('W1t', (635, 370)), w('a', (617, 386)), w('b', (597, 396)), 'Jw'])
    # the second petal's outer edge down to the second white petal; the third petal's upper edge into it
    ch(['P2t', w('a', (698, 320)), w('b', (702, 352)), w('c', (703, 387)), f('J3', (693, 421)), w('d', (674, 452)),
        f('J4', (650, 475))])
    ch([e('P3t', (821, 395)), w('a', (787, 396)), w('b', (757, 398)), w('c', (729, 406)), 'J3'])
    # the white petals: the first's outer edge to the moon's lower tip, the second's upper edge into it
    ch(['W1t', w('a', (636, 406)), w('b', (637, 436)), w('c', (627, 462)), f('J10', (608, 488)), f('Lt', (578, 518))])
    ch([e('W2t', (725, 472)), w('a', (687, 474)), 'J4', 'J10'])
    # the second white petal's lower edge to the stem; the third petal's lower edge and the fourth's upper edge meet
    # and join it; the small pink petal rises off it (white edge) and off the stem (pink edge)
    ch(['W2t', w('a', (703, 495)), w('b', (684, 519)), f('J5', (661, 543)), w('c', (629, 556)), w('d', (600, 561)),
        f('J8', (562, 567)), 's590'], direct=(('J8', 's590'),))
    ch(['P3t', w('a', (802, 424)), w('b', (792, 457)), w('c', (781, 491)), w('d', (764, 517)), w('g', (736, 540)),
        f('J6', (704, 556))])
    ch([e('P4t', (837, 585)), w('a', (790, 561)), w('b', (760, 551)), 'J6', 'J5'])
    ch(['s661', w('a', (526, 636)), w('b', (543, 600)), 'J8', w('c', (595, 576)), w('d', (616, 593)), w('g', (638, 612)),
        w('h', (667, 620)), e('P5t', (696, 617))])
    ch(['s661', w('a', (532, 627)), f('J7', (558, 615)), w('b', (602, 618)), w('c', (636, 626)), 'P5t'])
    ch(['P4t', w('a', (792, 605)), w('b', (766, 630)), w('c', (740, 651)), w('d', (708, 666)), w('g', (673, 676)),
        w('h', (635, 674)), w('i', (597, 658)), 'J7'])
    ch(['s798', w('a', (526, 760)), w('b', (539, 719)), w('c', (555, 695)), w('d', (567, 666)), w('g', (569, 640)), 'J7'])
    # the bottom leaf off the stem, its upper edge curling in, a spiral off its lower edge
    ch(['s798', w('a', (534, 827)), f('J9', (583, 846)), w('b', (650, 843)), w('c', (686, 827)), w('d', (720, 803)),
        w('g', (743, 781)), w('h', (762, 756)), w('i', (778, 731)), e('BLt', (797, 692))])
    ch(['BLt', w('a', (770, 708)), w('b', (746, 715)), w('c', (717, 716)), w('d', (685, 711)), w('g', (653, 705)),
        w('h', (617, 705)), w('i', (589, 715)), w('j', (564, 740)), w('k', (557, 772)),
        e('BLe', (575, 808))])          # the curl ends a little short (0.85 scale: it ran into J9)
    # the roots: the bottom leaf's tip straight out along the cup to inner-arc road 615 (mirrored: 622)
    ch(['BLt', 615], direct=(('BLt', 615),))
    ch(['J9', w('a', (618, 836)), w('b', (643, 818)), w('c', (660, 794)), w('d', (663, 770)), w('g', (654, 748)),
        w('h', (636, 737)), w('i', (616, 736)), w('j', (599, 747)), w('k', (595, 766)), e('SPe', (617, 774))])
    # the outer frame: a curl at the top sweeping round the petal tips (the picture floats it; it joins the second
    # petal's tip)
    ch([e('Fe', (662, 228)), w('a', (647, 249)), w('b', (630, 241)), w('c', (623, 222)), w('d', (631, 202)),
        w('g', (650, 190)), w('h', (677, 190)), w('i', (701, 205)), w('j', (716, 232)), w('k', (723, 261)),
        f('Fj', (738, 281)), w('l', (767, 296)), w('m', (796, 310)), w('n', (821, 332)), w('o', (841, 360)),
        w('p', (854, 392)), w('q', (853, 428)), w('r', (841, 467)), w('s', (830, 499)), e('Fz', (832, 530))])
    link(F, 'Fj', 'P2t')
    thin_at(F, road, 0.5, 0.3)
    M = mirror(F, LOTUS_AXIS, road)
    # the crescent moon at the heart (not mirrored: it opens to the right). The lines that reach the moon's tips on the
    # right reach its outer arc on the left.
    U.clamp = False
    even_chain(U, M, [f('Mu', (540, 447)), f('Mo1', (512, 438)), f('Mo2', (484, 451)), f('Mo3', (463, 476)),
                      f('Mo4', (458, 505)), f('Mo5', (469, 536)), f('Mo6', (490, 552)), 'ob', f('Mo7', (533, 556)),
                      f('Ml', (555, 537))], step=9)
    M.nodes['Mi'] = (U.to_map((489, 494)), S)
    M.links += [('Mu', 'Mi', _arc(U, (540, 447), (504, 469), (489, 494))), ('Mi', 'Ml', _arc(U, (489, 494), (507, 524), (555, 537)))]
    # the chains that ended at the moon's tips: on the right they end at Jw / Lt beside the tips; join them
    del M.nodes["Lt'"]
    M.links = [l for l in M.links if "Lt'" not in l[:2]]
    M.links += [('Jw', 'Mu', None), ('Lt', 'Ml', None), ("Jw'", 'Mo2', None), ("J10'", 'Mo4', None)]
    return M


def _arc(U, a, m, b):
    from trace_lib import circum
    return circum(U.to_map(a), U.to_map(m), U.to_map(b))


shrine = {}
E = eclipse()
shrine['shrine_eclipse'] = (E.nodes, E.links)
Lo = lotus()
shrine['moon_lotus'] = (Lo.nodes, Lo.links)

CELLS = {933: shrine}
