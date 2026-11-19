"""The Moon (933), traced by hand by Claude 2026-11-19 from the underlay idea the user picked, "moon 2"
(design/dao-do/underlays/moon/moon-2.png; user: "that looks nothing like the underlay?").

The dots of moon 2 were measured (tools/design/dao_do_rework/underlay/dots.py) and are used where they are; Claude chose which dots chain
into which piece, the kinds (big gold dots = notables), and the few changes the rules force:
  - a figure hangs from at most two road nodes, so the horn scroll's lower loop ends on its own notable instead of
    running into the great S;
  - pieces may not touch the start figure, so the long spiral that springs from the start in moon 2 springs from a
    node just outside it, on the stem rising from outer road 593;
  - two smalls before the first notable: one node added on the drawn line where moon 2 has too few;
  - the tiny floating ring at the top of the hollow has no road to hang from and is left out.
Links follow the drawn line (each arc through the line's midpoint). The right half is traced and mirrored, so the
island is exactly symmetric. Outside the crescent, the outer spirals and tip curls of the first hand version stay
(user: "add more both inside and outside"). The side circle, the Shadow Shrine, is shrine_trace.py's.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from celllib import road  # noqa: E402
from trace_lib import Underlay, even_chain, thin  # noqa: E402
import swirl_lib as sw  # noqa: E402
import moon_ul  # noqa: E402

THEME = 'island'
S, N = 'small', 'notable'
U = Underlay(os.path.join(HERE, '..', 'underlays', 'moon', 'moon-2.png'), 0.0, -103.0, 21.0, road)


class Fig:
    def __init__(self):
        self.nodes, self.links = {}, []

    def out(self):
        thin(self)
        return (self.nodes, self.links)


def d(k, p, kind=S):
    return (k, p, kind)


right = {}

# the horn scroll and the great S, one piece as drawn (hung from inner roads 616 and 612): from 616 down the horn to a
# gold node, a curl in to an eye, a loop out and down into the S's waist; the S from 612 through its waist and down
# towards outer road 594. Only change: the S stops one dot short of 594 (its last 1.3 units), since a piece may hang
# from two roads at most.
f = Fig()
even_chain(U, f, [616, d('a', (916.5, 233.0)), d('b', (914.5, 296.0)), d('c', (881.7, 341.9)), d('k', (874.8, 404.1), N),
            d('eye', (835.2, 453.7), N)])
even_chain(U, f, ['k', d('l', (922.3, 450.7)), d('lt', (897.9, 524.3)), d('w', (818.9, 543.3), 'small!')])
even_chain(U, f, [612, d('s1', (779.2, 503.2)), 'w', d('s3', (825.3, 620.1), N), d('s4', (796.8, 696.0), N)])
right['horn_and_s'] = f.out()

# the hollow curl: from inner road 613 up into the hollow and over into an eye
f = Fig()
even_chain(U, f, [613, d('h1', (793.4, 401.8)), d('h2', (802.7, 353.3)), d('eye', (755.8, 339.7), N)])
right['hollow_curl'] = f.out()

# the long spiral: in moon 2 two lines spring from the start's notable; here they spring from the point just outside
# it where the two lines still run together (pieces may not touch the start): one down to outer road 593, one round
# the inside of the S into an eye
f = Fig()
even_chain(U, f, [593, d('t1', (642.5, 789.0)), d('t2', (596.5, 762.0), 'small!'), d('j', (586.0, 712.5), 'small!'), d('t3', (643.5, 745.5), 'small!'),
            d('t4', (700.2, 721.6)), d('t5', (741.8, 649.8), N), d('t6', (726.9, 570.7)), d('eye', (636.6, 603.2), N)],
           direct={('t2', 'j'), ('j', 't3')})
right['long_spiral'] = f.out()

# --- more, in the same language (user: "add more stuff, same theme"): beaded swirls -----------------------------------
O = (0.0, -109.0)                         # the outer arc's centre
xy = lambda f: (lambda k: road(k) if isinstance(k, int) else f.nodes[k][0])
for name, rid, side, n in (('outer_swirl_595', 595, -1, 7), ('outer_swirl_597', 597, -1, 6),
                           ('outer_swirl_600', 600, 1, 6)):
    f = Fig()
    sw.swirl(f, xy(f), rid, sw.ang(O, road(rid)), side, n, 'o')
    right[name] = f.out()
f = Fig()
sw.swirl(f, xy(f), 590, 165, 1, 5, 't')                # a curl rising off the horn's tip
right['tip_swirl'] = f.out()
f = Fig()
sw.swirl(f, xy(f), 616, 235, 1, 8, 'q', tight=0.8)     # a great swirl across the upper hollow
right['hollow_swirl'] = f.out()

moon = {}
for name, pc in right.items():
    moon[name + '_r'] = pc
    moon[name + '_l'] = moon_ul.mirror(pc)

# the full moon over the start: a ring held on a stem from inner road 617, two swirls parting from the stem like a lyre
f = Fig()
H = (0.0, -107.2)
f.nodes['s0'] = ((0.0, -102.75), S)
f.nodes['s1'] = ((0.0, -104.15), S)
f.links += [(617, 's0', None), ('s0', 's1', None)]
ring = []
for i in range(8):
    k = f'm{i}'
    f.nodes[k] = (sw.Q(H, 1.55, i * 45), N if i == 4 else S)
    ring.append(k)
f.links += [(ring[i], ring[(i + 1) % 8], H) for i in range(8)] + [('s1', 'm0', None)]
xyf = xy(f)
sw.swirl(f, xyf, 's0', 222, 1, 5, 'la', tight=1.15)
sw.swirl(f, xyf, 's0', 138, -1, 5, 'ra', tight=1.15)
moon['full_moon'] = f.out()

# the side circle (the Shadow Shrine) is traced in shrine_trace.py (2026-11-19); its old waxing moon is gone

CELLS = {933: moon}
