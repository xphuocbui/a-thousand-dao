"""Metal (axis 144): swords and the sword formation (kiếm trận). Every cell placed by hand, 2026-11-18 (Metal fork).

Figure helper F(): a figure is drawn round a centre C in local units, u = towards the tree centre, v = towards +theta,
turned `rot` degrees (from inward towards +theta) and mirrored with `flip`. Every number below is chosen by hand.
Combos across cells:
  A "sword formation" junction: four guarded blades from road node 1494 (axis x ring 64.3) into cells 90, 95, 9, 10.
  B "split crescent": two crescent blades facing across the spoke at road node 1969 (cells 77 | 90), mirrored at 1970
    (cells 73 | 95), reading as one ring threaded on the spoke.
Consolidation pass 2026-11-18 (consolidate-brief.md): groups of small catalogue pieces merged into medium and big orbit
figures (helpers G() and the figure functions after it); each cell's block says what replaced what.
Density pass v2 2026-11-18 (density-brief.md), at the end of the file: five wall pairs mirrored across a cell wall
(W1-W5), an in-cell pass-through (A1), two pairs mirrored across the land axis (N1, N2) and three grown figures (G1-G3).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from celllib import L, road, frame, fill_rows, mirror_pieces, bow_centre, orbit, direction  # noqa: E402

THEME = 'metal'
KIND = {'s': 'small', 'N': 'notable', 'K': 'keystone'}


def pt(r, th):
    return L(r, th, THEME)


def F(C, pts, links, rot=0.0, flip=False):
    """pts {key: (u, v, kind)}; links [(a, b, arc)] with a/b a key or a road id, arc None, 'C' (the figure centre),
    a (u, v) local point, or ('bow', b) for a catalogue-style bow."""
    i, t = frame(C)
    a = math.radians(rot)

    def X(u, v):
        if flip:
            v = -v
        uu, vv = u * math.cos(a) - v * math.sin(a), u * math.sin(a) + v * math.cos(a)
        return (C[0] + uu * i[0] + vv * t[0], C[1] + uu * i[1] + vv * t[1])
    nodes = {k: (X(u, v), KIND[kd]) for k, (u, v, kd) in pts.items()}
    cen = (sum(p[0] for p, _ in nodes.values()) / len(nodes), sum(p[1] for p, _ in nodes.values()) / len(nodes))
    xy = lambda q: road(q) if isinstance(q, int) else nodes[q][0]
    out = []
    for p, q, arc in links:
        if arc is None:
            c = None
        elif arc == 'C':
            c = C
        elif isinstance(arc, tuple) and arc and arc[0] == 'bow':
            c = bow_centre(xy(p), xy(q), arc[1], cen)
        else:
            c = X(*arc)
        out.append((p, q, c))
    return nodes, out


def G(C, pts, links):
    """Orbit figure (consolidation pass, 2026-11-18): pts {key: (rho, ang, kind)} on circles round the centre C, ang in
    degrees (0 = towards the tree centre, + = towards +theta), or {key: ((x, y), kind)}; links [(a, b, arc)] with a/b a
    key or a road id, arc None (straight), 'C' (round C: both ends on one circle round C) or an (x, y) centre."""
    nodes = {k: ((orbit(C, v[0], v[1]), KIND[v[2]]) if len(v) == 3 else (v[0], KIND[v[1]])) for k, v in pts.items()}
    return nodes, [(a, b, C if arc == 'C' else arc) for a, b, arc in links]


def ray(rid, ang, dists, kinds, side=0.0):
    """A straight chain from road node rid: nodes at the given distances along `ang` (local frame at the road node),
    offset `side` units sideways; kinds a string of s/N."""
    R = road(rid)
    pts = {f'n{k}': (d * math.cos(math.radians(ang)), d * math.sin(math.radians(ang)) + side, kd)
           for k, (d, kd) in enumerate(zip(dists, kinds))}
    links = [(rid, 'n0', None)] + [(f'n{k}', f'n{k + 1}', None) for k in range(len(dists) - 1)]
    return F(R, pts, links)


# --- consolidation pass (2026-11-18): medium and big orbit figures that replace groups of small pieces --------------
def hung_bell(rid, drop=2.7, rd=1.5, lip=(2.1, 115, 2.6, 138)):
    """A bronze bell hanging outward from road node rid: a dome arc round C (top, +-45, +-90), the sides flaring
    straight to two lip notables, a clapper notable inside the mouth. 11 nodes."""
    C = orbit(road(rid), drop, 180)
    pts = {'top': (rd, 0, 's'), 'c1': (0.45, 0, 's'), 'cN': (0.95, 180, 'N')}
    links = [(rid, 'top', None), ('top', 'c1', None), ('c1', 'cN', None)]
    for sd, nm in ((1, 'R'), (-1, 'L')):
        pts[nm + '45'] = (rd, sd * 45, 's'); pts[nm + '90'] = (rd, sd * 90, 's')
        pts[nm + 'f'] = (lip[0], sd * lip[1], 's'); pts[nm + 'N'] = (lip[2], sd * lip[3], 'N')
        links += [('top', nm + '45', 'C'), (nm + '45', nm + '90', 'C'), (nm + '90', nm + 'f', None), (nm + 'f', nm + 'N', None)]
    return G(C, pts, links)


def blade_fan(rid, ang=0, hub=2.0, spread=42, r1=1.1, r2=2.1, rib=True):
    """A folding fan of three blades from road node rid along `ang`: stem, hub, three spokes at even steps between two
    orbits round the hub with notable tips; `rib` arcs the inner orbit (the fan's rib). 8 nodes."""
    R = road(rid)
    H = orbit(R, hub, ang)
    pts = {'s0': (orbit(R, 1.1, ang), 's'), 'h': (H, 's')}
    links = [(rid, 's0', None), ('s0', 'h', None)]
    for a in (-spread, 0, spread):
        pts[f'i{a}'] = (orbit(H, r1, ang + a), 's'); pts[f'o{a}'] = (orbit(H, r2, ang + a), 'N')
        links += [('h', f'i{a}', None), (f'i{a}', f'o{a}', None)]
    if rib:
        links += [(f'i{-spread}', 'i0', H), ('i0', f'i{spread}', H)]
    return G(H, pts, links)


def moon(rid, ang=0, R1=2.0, tip=68, back=1.3, outer=(125, 180, 235), inner=(140, 220)):
    """A crescent-moon blade from road node rid, its back towards the road and its horns along `ang`: an outer arc
    round C1 (entered at its back) and an inner arc round C2, both through the two notable horns."""
    C1 = orbit(road(rid), 1.0 + R1, ang)
    t = math.radians(tip); tu, tv = R1 * math.cos(t), R1 * math.sin(t)
    k = R1 - back
    dd = (tu * tu + tv * tv - k * k) / (2 * tu + 2 * k)          # inner circle through the horns, `back` thick
    C2, R2 = orbit(C1, dd, ang), dd + k
    nodes, _ = G(C1, {'tA': (R1, ang + tip, 'N'), 'tB': (R1, ang - tip, 'N'),
                      **{f'o{a}': (R1, ang + a, 's') for a in outer}}, [])
    nodes.update({f'i{a}': (orbit(C2, R2, ang + a), 'small') for a in inner})
    oo = ['tA'] + [f'o{a}' for a in outer] + ['tB']
    ii = ['tA'] + [f'i{a}' for a in inner] + ['tB']
    links = [(rid, f'o{outer[len(outer) // 2]}', None)] + [(p, q, C1) for p, q in zip(oo, oo[1:])] + \
            [(p, q, C2) for p, q in zip(ii, ii[1:])]
    return nodes, links


def coin(rid, drop=2.7, ro=1.5, ri=0.65, nots=(90, 180, 270), ang=0):
    """A square-holed cash coin hanging from road node rid (tilted `ang` from straight outward): a ring of eight round
    C, an inner square of four joined to the ring's diagonal nodes. 12 nodes."""
    C = orbit(road(rid), drop, 180 + ang)
    pts = {f'o{a}': (ro, ang + a, 'N' if a in nots else 's') for a in range(0, 360, 45)}
    pts.update({f'i{a}': (ri, ang + a, 's') for a in (45, 135, 225, 315)})
    links = [(rid, 'o0', None)] + [(f'o{a}', f'o{(a + 45) % 360}', 'C') for a in range(0, 360, 45)]
    links += [(f'i{a}', f'i{(a + 90) % 360}', None) for a in (45, 135, 225, 315)] +              [(f'o{a}', f'i{a}', None) for a in (45, 135, 225, 315)]
    return G(C, pts, links)


def lens(rid, ang=0, stem=1.1, length=4.0, h=1.1, n=2, rib=True, nots=('T',)):
    """A leaf-bladed spearhead from road node rid along `ang`: two arcs (n nodes each) from a near tip E to a far
    notable tip T, each arc round a centre on the far side of the blade's line; `rib` E-M-T down the middle."""
    R = road(rid)
    E, T = orbit(R, stem, ang), orbit(R, stem + length, ang)
    M = ((E[0] + T[0]) / 2, (E[1] + T[1]) / 2)
    Lr = math.dist(E, T)
    Rr = (Lr * Lr / 4 + h * h) / (2 * h)
    nv = (-(T[1] - E[1]) / Lr, (T[0] - E[0]) / Lr)            # unit normal of E-T: arc centres on its bisector
    pts = {'E': (E, 's'), 'T': (T, 'N')}
    links = [(rid, 'E', None)]
    for sd, nm in ((1, 'R'), (-1, 'L')):
        D = direction(M, ang - sd * 90)
        k = 1 if nv[0] * D[0] + nv[1] * D[1] > 0 else -1
        Oc = (M[0] + k * nv[0] * (Rr - h), M[1] + k * nv[1] * (Rr - h))
        a0 = math.atan2(E[1] - Oc[1], E[0] - Oc[0]); a1 = math.atan2(T[1] - Oc[1], T[0] - Oc[0])
        da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
        prev = 'E'
        for k in range(1, n + 1):
            a = a0 + da * k / (n + 1)
            pts[f'{nm}{k}'] = ((Oc[0] + Rr * math.cos(a), Oc[1] + Rr * math.sin(a)), 'N' if f'{nm}{k}' in nots else 's')
            links.append((prev, f'{nm}{k}', Oc)); prev = f'{nm}{k}'
        links.append((prev, 'T', Oc))
    if rib:
        pts['M'] = (M, 'N' if 'M' in nots else 's'); links += [('E', 'M', None), ('M', 'T', None)]
    return G(M, pts, links)


def bow2(rid, ang=0, rho=2.0, tip=62, pull=0.9, head=1.2):
    """A drawn bow loosing an arrow along `ang`: the string pulled back to a nock node next to the road, two string
    nodes to the notable tips, the bow's arc round C through the grip, the arrowhead notable beyond the grip. 9 nodes."""
    R = road(rid)
    C = orbit(R, 1.1 + pull + rho * math.cos(math.radians(tip)), ang)
    nk, tA, tB = orbit(R, 1.1, ang), orbit(C, rho, ang + tip), orbit(C, rho, ang - tip)
    mid = lambda p, q: ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
    pts = {'nock': (nk, 's'), 'tA': (tA, 'N'), 'tB': (tB, 'N'), 'sA': (mid(nk, tA), 's'), 'sB': (mid(nk, tB), 's'),
           'a1': (orbit(C, rho, ang + tip / 2), 's'), 'grip': (orbit(C, rho, ang), 's'),
           'a2': (orbit(C, rho, ang - tip / 2), 's'), 'head': (orbit(C, rho + head, ang), 'N')}
    links = [(rid, 'nock', None), ('nock', 'sA', None), ('sA', 'tA', None), ('nock', 'sB', None), ('sB', 'tB', None),
             ('tA', 'a1', 'C'), ('a1', 'grip', 'C'), ('grip', 'a2', 'C'), ('a2', 'tB', 'C'), ('grip', 'head', None)]
    return G(C, pts, links)


def spiral(rid, ang=0, r0=2.4, r1=0.7, n=8, step=50, hand=1, nots=(4,)):
    """A coiled chain whip: n nodes on a spiral round C, the outer end next to the road, the inner end a notable."""
    C = orbit(road(rid), 1.1 + r0, ang)
    pts = {f's{k}': (r0 + (r1 - r0) * k / (n - 1), ang + 180 + hand * step * k, 'N' if (k == n - 1 or k in nots) else 's')
           for k in range(n)}
    return G(C, pts, [(rid, 's0', None)] + [(f's{k}', f's{k + 1}', None) for k in range(n - 1)])


def gong(rid, ang=0, rho=1.45, stem=1.0, n=6, nots=(2, 4)):
    """A bronze gong (or mirror) on a stem from road node rid: a ring of n round C with two notables on its rim and a
    notable boss at its heart, hung from the ring's far node. n + 2 nodes."""
    R = road(rid)
    C = orbit(R, stem + 1.0 + rho, ang)
    pts = {'s0': (orbit(R, stem, ang), 's'), 'boss': (C, 'N')}
    pts.update({f'r{k}': (rho, ang + 180 + 360 * k / n, 'N' if k in nots else 's') for k in range(n)})
    links = [(rid, 's0', None), ('s0', 'r0', None)] + [(f'r{k}', f'r{(k + 1) % n}', 'C') for k in range(n)] +             [(f'r{n // 2}', 'boss', None)]
    return G(C, pts, links)


def nested(rid, ang=0, stem=1.1, R1=2.3, R2=1.3, outer=(0, 40, 80, -40, -80), inner=(0, 55, -55)):
    """Nested arcs (a double crescent blade): two concentric arcs round C on orbits R1 and R2, entered at the back of
    the outer arc, a radial link between the two middles, the four arc ends notable."""
    C = orbit(road(rid), stem + R1, ang)
    pts = {f'o{a}': (R1, ang + 180 + a, 'N' if a in (max(outer), min(outer)) else 's') for a in outer}
    pts.update({f'i{a}': (R2, ang + 180 + a, 'N' if a in (max(inner), min(inner)) else 's') for a in inner})
    so, si = sorted(outer), sorted(inner)
    links = [(rid, 'o0', None), ('o0', 'i0', None)] + [(f'o{p}', f'o{q}', 'C') for p, q in zip(so, so[1:])] +             [(f'i{p}', f'i{q}', 'C') for p, q in zip(si, si[1:])]
    return G(C, pts, links)


def pinwheel(rid, ang=0, stem=1.1, rho=0.9, b1=(1.75, 38), b2=(2.5, 70), hand=1, blades=(1, 2, 3)):
    """Flying-sword wheel: a ring of four round C entered from a stem, curved blades swept the same way (hand) from
    three ring nodes, each a small node and a notable tip. 11 nodes."""
    R = road(rid)
    C = orbit(R, stem + 1.0 + rho, ang)
    pts = {'s0': (orbit(R, stem, ang), 's')}
    links = [(rid, 's0', None), ('s0', 'r0', None)]
    for k in range(4):
        a = ang + 180 + 90 * k
        pts[f'r{k}'] = (rho, a, 's')
        links.append((f'r{k}', f'r{(k + 1) % 4}', 'C'))
        if k in blades:
            pts[f'b{k}'] = (b1[0], a + hand * b1[1], 's'); pts[f'n{k}'] = (b2[0], a + hand * b2[1], 'N')
            links += [(f'r{k}', f'b{k}', None), (f'b{k}', f'n{k}', None)]
    return G(C, pts, links)


def ding(rid, ang=0, stem=1.1, rho=1.3, ear=(1.95, 114), leg=1.0):
    """A bronze ding cauldron standing on road node rid, entered up its middle leg: a bowl arc round C (bottom, +-45,
    +-90), two ears rising past the rim and two legs under the bowl, all four notable. 10 nodes."""
    R = road(rid)
    C = orbit(R, stem + 1.0 + rho, ang)
    bot = ang + 180
    pts = {'s0': (orbit(R, stem, ang), 's'), 'b0': (rho, bot, 's')}
    links = [(rid, 's0', None), ('s0', 'b0', None)]
    for sd, nm in ((1, 'R'), (-1, 'L')):
        pts[nm + '45'] = (rho, bot + sd * 45, 's'); pts[nm + '90'] = (rho, bot + sd * 90, 's')
        pts[nm + 'ear'] = (ear[0], bot + sd * ear[1], 'N')
        pts[nm + 'leg'] = (orbit(orbit(C, rho, bot + sd * 45), leg, ang + 180), 'N')
        links += [('b0', nm + '45', 'C'), (nm + '45', nm + '90', 'C'), (nm + '90', nm + 'ear', None), (nm + '45', nm + 'leg', None)]
    return G(C, pts, links)


def axe(rid, ang=0, stem=1.1, hub=2.1, R=2.2, half=56, nots=('a1', 'a3')):
    """A yue battle-axe: haft stem to a hub, two straight cheeks to the ends of an edge arc of five round the hub,
    notables on the edge. 7 nodes."""
    Rd = road(rid)
    H = orbit(Rd, hub, ang)
    angs = {'eL': -half, 'a1': -half / 2, 'a2': 0, 'a3': half / 2, 'eR': half}
    pts = {'s0': (orbit(Rd, stem, ang), 's'), 'h': (H, 's')}
    pts.update({k: (orbit(H, R, ang + a), 'N' if k in nots else 's') for k, a in angs.items()})
    links = [(rid, 's0', None), ('s0', 'h', None), ('h', 'eL', None), ('h', 'eR', None),
             ('eL', 'a1', 'C'), ('a1', 'a2', 'C'), ('a2', 'a3', 'C'), ('a3', 'eR', 'C')]
    return G(H, pts, links)


def ring_sabre(rid, ang=0, stem=1.1, rho=0.75, blade=(0.95, 0.95, 0.95), curve=8, ring_not=2):
    """A ring-pommel sabre (huandao) from road node rid: a stem into a ring of four round P (the pommel, a notable at
    its far side), then a blade whose segments curve progressively (`curve` degrees) to a notable tip. 8 nodes."""
    R = road(rid)
    P = orbit(R, stem + 0.9 + rho, ang)
    pts = {'s0': (orbit(R, stem, ang), 's')}
    for k in range(4):
        pts[f'r{k}'] = (orbit(P, rho, ang + 180 + 90 * k), 'N' if k == ring_not else 's')
    prev, at = 'r2', orbit(P, rho, ang)
    links = [(rid, 's0', None), ('s0', 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 4}', P) for k in range(4)]
    for j, L in enumerate(blade):
        at = orbit(at, L, ang + curve * (1 + 1.5 * j))
        key = 'tip' if j == len(blade) - 1 else f'b{j}'
        pts[key] = (at, 'N' if key == 'tip' else 's')
        links.append((prev, key, None)); prev = key
    return G(P, pts, links)


def chain_links(rid, ang=0, stem=1.1, rho=0.75, gap=0.95, nots=('b1', 'b3')):
    """Two chain links along `ang`: ring A (four round A) entered at its near node, ring B (four round B) hung from
    A's far node, notables on B's sides. 8 nodes."""
    R = road(rid)
    A = orbit(R, stem + rho, ang)
    B = orbit(orbit(A, rho, ang), gap + rho, ang)
    pts = {}
    for k in range(4):
        pts[f'a{k}'] = (orbit(A, rho, ang + 180 + 90 * k), 's')
        pts[f'b{k}'] = (orbit(B, rho, ang + 180 + 90 * k), 'N' if f'b{k}' in nots else 's')
    links = [(rid, 'a0', None), ('a2', 'b0', None)] + [(f'a{k}', f'a{(k + 1) % 4}', A) for k in range(4)] + \
            [(f'b{k}', f'b{(k + 1) % 4}', B) for k in range(4)]
    return G(A, pts, links)


def chime_rack(rid, ang=0, stem=1.1, R1=2.4, beam=(-60, -30, 0, 30, 60), hang=(-30, 30), drop=(0.95, 1.9)):
    """A bianzhong chime rack: a stem to the middle of a beam arc round C (bowed towards the road), the beam ends
    notable, and two small bells (a node and a notable) hanging straight along `ang` from two beam nodes. 10 nodes."""
    R = road(rid)
    s0 = orbit(R, stem, ang)
    C = orbit(s0, 1.0 + R1, ang)
    pts = {'s0': (s0, 's')}
    pts.update({f'm{a}': (orbit(C, R1, ang + 180 + a), 'N' if a in (min(beam), max(beam)) else 's') for a in beam})
    links = [(rid, 's0', None), ('s0', 'm0', None)] + [(f'm{p}', f'm{q}', 'C') for p, q in zip(beam, beam[1:])]
    for a in hang:
        bp = orbit(C, R1, ang + 180 + a)
        pts[f'h{a}'] = (orbit(bp, drop[0], ang), 's'); pts[f'n{a}'] = (orbit(bp, drop[1], ang), 'N')
        links += [(f'm{a}', f'h{a}', None), (f'h{a}', f'n{a}', None)]
    return G(C, pts, links)


def meteor(rid, ang=0, swing=90, chainR=4.0, n=4, step=14, ring=0.85, k=5, spike=0.9):
    """A meteor hammer: a chain of n nodes on an arc round O (the road node on the same circle) leaving along `ang`,
    then a ring of k round H continuing the chain's line, a notable on the ring and a notable spike. n + k + 1 nodes."""
    R = road(rid)
    O = orbit(R, chainR, ang + swing)
    a0 = math.atan2(R[1] - O[1], R[0] - O[0])
    D0 = direction(R, ang)
    t = (O[0] + chainR * math.cos(a0 + math.radians(step)), O[1] + chainR * math.sin(a0 + math.radians(step)))
    sgn = 1 if (t[0] - R[0]) * D0[0] + (t[1] - R[1]) * D0[1] >= 0 else -1
    pts, links, prev = {}, [], rid
    for j in range(1, n + 1):
        a = a0 + sgn * math.radians(step) * j
        pts[f'c{j}'] = ((O[0] + chainR * math.cos(a), O[1] + chainR * math.sin(a)), 's')
        links.append((prev, f'c{j}', O if prev != rid else None)); prev = f'c{j}'
    end = pts[prev][0]
    a_end = a0 + sgn * math.radians(step) * n
    tx, ty = -math.sin(a_end) * sgn, math.cos(a_end) * sgn
    H = (end[0] + tx * (0.9 + ring), end[1] + ty * (0.9 + ring))
    e0 = math.atan2(end[1] - H[1], end[0] - H[0])
    for i in range(k):
        a = e0 + math.radians(360 * i / k)
        pts[f'r{i}'] = ((H[0] + ring * math.cos(a), H[1] + ring * math.sin(a)), 'N' if i == k // 2 + 1 else 's')
    links += [(prev, 'r0', None)] + [(f'r{i}', f'r{(i + 1) % k}', H) for i in range(k)]
    sp = pts[f'r{k // 2}'][0]
    pts['sp'] = ((H[0] + (sp[0] - H[0]) / ring * (ring + spike), H[1] + (sp[1] - H[1]) / ring * (ring + spike)), 'N')
    links.append((f'r{k // 2}', 'sp', None))
    return G(H, pts, links)


def star(rid, ang=0, stem=1.1, ro=1.5, ri=0.75, nots=(1, 2, 3), rot=0):
    """A four-point throwing star: a ring of eight round C alternating between tips (orbit ro) and waist nodes (ri),
    entered at the tip next to the road, the other three tips notable. 8 nodes."""
    C = orbit(road(rid), stem + ro, ang)
    pts = {f'p{k}': (ro if k % 2 == 0 else ri, ang + 180 + rot + 45 * k, 'N' if k % 2 == 0 and k // 2 in nots else 's')
           for k in range(8)}
    return G(C, pts, [(rid, 'p0', None)] + [(f'p{k}', f'p{(k + 1) % 8}', None) for k in range(8)])


def claw(rid, ang=0, stem=1.1, hub=2.1, spread=40, L1=1.15, L2=2.1, curl=15, hand=1):
    """A white-tiger claw: a stem to the palm (hub), three claws at even steps round it, each a node and a notable
    curled the same way (`curl` degrees), the claws' links bowed. 8 nodes."""
    R = road(rid)
    H = orbit(R, hub, ang)
    pts = {'s0': (orbit(R, stem, ang), 's'), 'h': (H, 's')}
    links = [(rid, 's0', None), ('s0', 'h', None)]
    for a in (-spread, 0, spread):
        p1, p2 = orbit(H, L1, ang + a), orbit(H, L2, ang + a + hand * curl)
        pts[f'c{a}'] = (p1, 's'); pts[f'n{a}'] = (p2, 'N')
        links += [('h', f'c{a}', None), (f'c{a}', f'n{a}', bow_centre(p1, p2, 0.12 * hand, H))]
    return G(H, pts, links)


def ji(rid, ang=0, stem=1.1, seg=1.05, side=-1, crescent=1.5, angs=(90, 120, 148)):
    """A ji halberd: a shaft of three nodes to a notable spear tip, and from the second shaft node a crescent side
    blade, an arc of three round that node ending in a notable. 7 nodes."""
    R = road(rid)
    p = [orbit(R, stem + seg * k, ang) for k in range(4)]
    pts = {'s0': (p[0], 's'), 's1': (p[1], 's'), 's2': (p[2], 's'), 'tip': (p[3], 'N')}
    pts.update({f'c{j}': (orbit(p[1], crescent, ang + side * a), 'N' if j == 2 else 's') for j, a in enumerate(angs)})
    links = [(rid, 's0', None), ('s0', 's1', None), ('s1', 's2', None), ('s2', 'tip', None),
             ('s1', 'c0', None), ('c0', 'c1', p[1]), ('c1', 'c2', p[1])]
    return G(p[1], pts, links)


def small_bell(rid, ang=0, stem=1.1, rho=1.5, dome=(0, 55, 110), clap=(0.4, 1.05)):
    """A hand bell (bo) from road node rid: a dome arc round C (top, +-55, and the notable rims at +-110) and a clapper
    notable hanging inside from the top. 7 nodes."""
    C = orbit(road(rid), stem + rho, ang)
    top = ang + 180
    pts = {'d0': (rho, top, 's'), 'c1': (clap[0], ang, 's'), 'cN': (clap[1], ang, 'N')}
    links = [(rid, 'd0', None), ('d0', 'c1', None), ('c1', 'cN', None)]
    for sd, nm in ((1, 'R'), (-1, 'L')):
        pts[nm + '1'] = (rho, top + sd * dome[1], 's'); pts[nm + '2'] = (rho, top + sd * dome[2], 'N')
        links += [('d0', nm + '1', 'C'), (nm + '1', nm + '2', 'C')]
    return G(C, pts, links)


def spade(rid, ang=0, stem=1.1, neck=1.0, sh=(1.2, 55), ft=(1.5, 145), crotch=0.6, eye=True):
    """Spade money (bu): a stem and neck from road node rid, two shoulders and two notable feet on circles round the
    body centre B, the feet joined through an arched crotch node, and a notable eye in the body. 8 nodes."""
    R = road(rid)
    n1 = orbit(R, stem + neck, ang)
    B = orbit(n1, sh[0] * math.cos(math.radians(sh[1])) + 0.6, ang)
    pts = {'s0': (orbit(R, stem, ang), 's'), 'n1': (n1, 's'), 'cr': (orbit(B, crotch, ang), 's')}
    for sd, nm in ((1, 'R'), (-1, 'L')):
        pts['s' + nm] = (orbit(B, sh[0], ang + 180 + sd * sh[1]), 's')
        pts['f' + nm] = (orbit(B, ft[0], ang + 180 + sd * ft[1]), 'N')
    links = [(rid, 's0', None), ('s0', 'n1', None), ('n1', 'sL', None), ('n1', 'sR', None), ('sL', 'fL', None),
             ('sR', 'fR', None), ('fL', 'cr', None), ('cr', 'fR', None)]
    if eye:
        pts['eye'] = (orbit(B, 0.35, ang + 180), 'N'); links.append(('cr', 'eye', None))
    return G(B, pts, links)


CELLS = {}

# ---------------------------------------------------------------------------------------------------------------------
# Cell 81, hub cell (r 4.2-14.5, theta -36..36), inner: a few small pieces. A straight trident (Fork) points from the
# Metal road node on the hub ring at the Chaos centre; two Crooks flank it; a small Diamond rises from the inner ring.
CELLS[81] = fill_rows({}, [
    ('trident',   17, 'Fork', 'straight', 1.2, 0, 0, False),
    ('crook L',   16, 'Crook', 'straight', 1.1, 15, 0, True),
    ('crook R',   18, 'Crook', 'straight', 1.1, -15, 0, False),
    ('diamond',    5, 'Diamond', 'straight', 1.2, 180, 0, False),
])

# ---------------------------------------------------------------------------------------------------------------------
# Cell 4, the Metal start cell (558 units², start figure on the axis at r 22-31): big and sparse (B4). Two flying swords
# leave the border roads and point at the start from either side; two crescents hang from the start ring.
CELLS[4] = {
    'sword L': ray(256, 90, (1.3, 2.45, 3.6, 4.75, 5.9), 'ssssN'),
    'sword R': ray(275, -90, (1.3, 2.45, 3.6, 4.75, 5.9), 'ssssN'),
}
fill_rows(CELLS[4], [
    ('crescent L', 1694, 'Crescent', 'bow in', 1.2, 0, 0, False),
    ('crescent R', 1700, 'Crescent', 'bow in', 1.2, 0, 0, True),
])


# ---------------------------------------------------------------------------------------------------------------------
# Combo A, "sword formation": four guarded blades leave road node 1494 (axis x ring 64.3) on the diagonals, one into
# each of the four cells round the junction (90 and 95 inside the ring, 9 and 10 outside it). Each blade: a small node,
# a diamond guard, two blade nodes and a notable tip; together a four-bladed star the two roads pass through.
def blade(ang):
    a = math.radians(ang)
    e = (math.cos(a), math.sin(a)); p = (-math.sin(a), math.cos(a))
    at = lambda d, s=0.0: (d * e[0] + s * p[0], d * e[1] + s * p[1])
    pts = {'s1': (*at(1.4), 's'), 'gA': (*at(2.15, 0.8), 's'), 'gB': (*at(2.15, -0.8), 's'), 's2': (*at(2.9), 's'),
           's3': (*at(4.1), 's'), 'tip': (*at(5.3), 'N')}
    links = [(1494, 's1', None), ('s1', 'gA', None), ('s1', 'gB', None), ('gA', 's2', None), ('gB', 's2', None),
             ('s2', 's3', None), ('s3', 'tip', None)]
    return F(road(1494), pts, links)


# Combo B, "split crescent": a crescent blade on each side of a spoke, both on one circle round the spoke's road node,
# so the two halves read as one ring threaded on the spoke (gaps where the spoke passes). side +1 = towards +theta.
def crescent_half(rid, side, rho=2.3):
    angs = (35, 60, 90, 120, 145)
    pts = {f'k{a}': (rho * math.cos(math.radians(side * a)), rho * math.sin(math.radians(side * a)),
                     'N' if a in (35, 145) else 's') for a in angs}
    links = [(rid, 'k90', None)] + [(f'k{p}', f'k{q}', 'C') for p, q in zip(angs, angs[1:])]
    return F(road(rid), pts, links)


# ---------------------------------------------------------------------------------------------------------------------
# Cell 90 (middle band, theta -11..0): a blade of combo A in its lower-right corner, the +theta half of combo B on its
# left spoke; between them (consolidated) a crescent moon and a ring-pommel sabre from the inner road, a diamond from
# below, a crook off the axis.
CELLS[90] = {'blade': blade(-45), 'crescent B': crescent_half(1969, +1)}
fill_rows(CELLS[90], [
    ('diamond', 1759, 'Diamond', 'straight', 1.1, 0, 0, False),
    ('crook',   1493, 'Crook', 'straight', 1.2, -90, 0, True),
])
# consolidation: kite 1742 + crook 1741 -> a crescent moon from 1742; spur pairs 1743 + 1492 -> a ring-pommel sabre
# from 1743 (both medium).
CELLS[90].update({'moon': moon(1742, ang=172, R1=1.6, tip=55, back=1.1), 'sabre': ring_sabre(1743, ang=182, stem=1.5)})

# Cell 95 (middle band, theta 0..11): the mirror blade of combo A and the -theta half of the mirrored combo B on 1970;
# cell 90's sabre and crook mirrored, a moon of its own from the inner road, a hook from below.
CELLS[95] = {'blade': blade(45), 'crescent B': crescent_half(1970, -1)}
fill_rows(CELLS[95], [
    ('hook',     1769, 'Hook', 'straight', 1.1, 10, 0, True),
])
# consolidation: cell 90's sabre and crook mirrored (crescent 1750, tadpoles 1492 and 1493 merged); fork 1749 +
# diamond 1748 -> a crescent moon from 1749, cell 90's with a three-node inner arc.
CELLS[95].update(mirror_pieces({'sabre': CELLS[90]['sabre'], 'crook': CELLS[90]['crook']}, THEME))
CELLS[95]['moon'] = moon(1749, ang=188, R1=1.6, tip=55, back=1.1, inner=(135, 180, 225))
# Review pass w1 (2026-11-19): the hook on 1769 was a straight zigzag stick in the middle of the cell; cell 90's diamond
# mirrored in its place, so 90 and 95 answer each other across the axis. 34 -> 34.
del CELLS[95]['hook']
CELLS[95].update(mirror_pieces({'diamond': CELLS[90]['diamond']}, THEME))


# ---------------------------------------------------------------------------------------------------------------------
# Cell 9 (outer band, theta -17..0): a combo A blade from the top-right corner; centre figure a deliberate pair of
# chevrons, "»", flying towards the junction, each hung from the outer ring road; catalogue pieces round them.
def chevron(apex, rid):
    pts = {'a': (0.0, 0.0, 's'), 'u1': (0.9, -0.9, 's'), 'uN': (1.8, -1.8, 'N'), 'd1': (-0.9, -0.9, 's'), 'dN': (-1.8, -1.8, 'N')}
    links = [(rid, 'a', None), ('a', 'u1', None), ('u1', 'uN', None), ('a', 'd1', None), ('d1', 'dN', None)]
    return F(apex, pts, links)


CELLS[9] = {'blade': blade(-135), 'chevron 1': chevron(pt(70.5, -8.0), 1724), 'chevron 2': chevron(pt(70.5, -11.6), 1723)}
# consolidation: fork 1756 + hook 1757 -> two chain links from 1757 (medium); zigzag 1758 + crook 1759 + hairpin 1760
# -> a chime rack from 1759 (big); ring 1495 + spur 1726 + crook 1496 -> a long jian blade from 1726 (big); diamond
# 1721 -> an axe from 1722 (medium). Cell 10 mirrors all four.
CELLS[9].update({'chain': chain_links(1757, ang=195), 'rack': chime_rack(1759, ang=180),
                 'sword': lens(1726, ang=10, length=5.0, h=0.85, n=3, nots=('T', 'L2', 'R2')),
                 'axe': axe(1722, ang=-10, half=50, R=2.0)})


# Cell 10 (outer band, theta 0..17): a combo A blade from the top-left corner; centre figure a hex shield: six straight
# sides, two notables on its far vertices and a notable at its heart on a spoke; catalogue pieces round it.
def hex_shield(C, rid, rho=1.4):
    pts = {f'h{k}': (rho * math.cos(math.radians(180 + 60 * k)), rho * math.sin(math.radians(180 + 60 * k)),
                     'N' if k in (2, 4) else 's') for k in range(6)}
    pts['heart'] = (0.0, 0.0, 'N')
    links = [(rid, 'h0', None)] + [(f'h{k}', f'h{(k + 1) % 6}', None) for k in range(6)] + [('h3', 'heart', None)]
    return F(C, pts, links)


CELLS[10] = {'blade': blade(135), 'shield': hex_shield(pt(69.6, 11.0), 1733)}
# consolidation: cell 9's chain, rack, sword and axe mirrored (fork 1767, crescent 1769, hairpin 1731, crook 1735,
# kite 1495, fork 1734, crook 1766, the wheels 1770, 1768, 1736 and crook 1496 merged); in place of the chevrons a
# meteor hammer swinging from 1735 (big).
CELLS[10].update(mirror_pieces({k: CELLS[9][k] for k in ('chain', 'rack', 'sword', 'axe')}, THEME))
CELLS[10]['hammer'] = meteor(1735, ang=0, swing=90, step=14, chainR=4.0)


# ---------------------------------------------------------------------------------------------------------------------
# Cell 61 (inner band, theta -23..0), sparse: centre figure an ingot (yuanbao), a hull bowed outward with two raised
# ears and a dome, hung from the outer ring road; catalogue pieces round it.
def ingot(C, rid):
    pts = {'m': (-0.9, 0.0, 's'), 'l': (-0.6, -1.3, 's'), 'r': (-0.6, 1.3, 's'), 'eL': (0.5, -2.2, 'N'),
           'eR': (0.5, 2.2, 'N'), 'd': (0.5, 0.0, 's'), 'dN': (1.4, 0.0, 'N')}
    links = [(rid, 'm', None), ('m', 'l', ('bow', 0.15)), ('m', 'r', ('bow', 0.15)), ('l', 'eL', None), ('r', 'eR', None),
             ('m', 'd', None), ('d', 'dN', None)]
    return F(C, pts, links)


CELLS[61] = {'ingot': ingot(pt(38.6, -12.6), 1707)}
fill_rows(CELLS[61], [
    ('diamond', 1709, 'Diamond', 'straight', 1.1, 0, 0, False),
])
# consolidation: hook 1693 + crook 1694 -> a hand bell from 1694; fork 129 + crook 1695 + crook 105 -> spade money
# lying from the axis node 129 (both medium).
CELLS[61].update({'bell': small_bell(1694, ang=175), 'spade': spade(129, ang=-80)})
# Review pass w1: the spade's eye notable sat on a stalk inside its outline, crowding it; the spade is drawn a little
# larger without the eye, its two feet the notables and the crotch a notch between them (cell 68 mirrors it). 8 -> 7.
CELLS[61]['spade'] = spade(129, ang=-80, sh=(1.3, 55), ft=(1.7, 145), crotch=0.75, eye=False)
# and a hook arcs from the corner node 1705 into the empty patch under the bell, left of the ingot (+4).
fill_rows(CELLS[61], [('hook 1705', 1705, 'Hook', 'bow out', 1.2, 40, 0, False)])


# Cell 68 (inner band, theta 0..23), sparse: centre figure a bell hung from the start ring road: a dome of two arcs
# with notables at its rim and a clapper notable inside it; catalogue pieces round it.
def bell(C, rid):
    q = lambda phi: (-1.6 + 1.6 * math.cos(math.radians(phi)), 1.6 * math.sin(math.radians(phi)))
    pts = {'a': (0.0, 0.0, 's'), 'aL': (*q(-50), 's'), 'rimL': (*q(-90), 'N'), 'aR': (*q(50), 's'), 'rimR': (*q(90), 'N'),
           'c1': (-0.8, 0.0, 's'), 'cN': (-1.75, 0.0, 'N')}
    links = [(rid, 'a', None), ('a', 'aL', (-1.6, 0.0)), ('aL', 'rimL', (-1.6, 0.0)), ('a', 'aR', (-1.6, 0.0)),
             ('aR', 'rimR', (-1.6, 0.0)), ('a', 'c1', None), ('c1', 'cN', None)]
    return F(C, pts, links)


CELLS[68] = {'bell': bell(pt(34.6, 14.0), 1701)}
fill_rows(CELLS[68], [
    ('crook',   1716, 'Crook', 'straight', 1.1, 0, 0, True),
    ('diamond', 1713, 'Diamond', 'straight', 1.1, 0, 0, False),
])
# consolidation: kite 129 + crook 105 -> cell 61's spade, mirrored; fork 1700 + hook 1702 -> two chain links from 1700
# (in place of 61's hand bell, as this cell's centre figure is already a bell).
CELLS[68].update(mirror_pieces({'spade': CELLS[61]['spade']}, THEME))
CELLS[68]['chain'] = chain_links(1700, ang=180)


# Cells 113 / 116 (inner corners, 72 units²): a mirrored pair (PoE 2-style), 116 with one piece changed.
CELLS[113] = fill_rows({}, [
    ('fork',  1519, 'Fork', 'straight', 1.2, 90, 0, False),
    ('crook', 1704, 'Crook', 'straight', 1.1, 0, 0, False),
])
CELLS[116] = mirror_pieces({'fork': CELLS[113]['fork']}, THEME)
fill_rows(CELLS[116], [('crescent', 1711, 'Crescent', 'straight', 1.1, 0, 0, True)])


# ---------------------------------------------------------------------------------------------------------------------
# Cell 20 (theta 0..18 beside the axis hex): centre figure a string of two square-holed coins hanging from the inner
# ring road; catalogue pieces round it (the hex is a wall, nothing hangs from it).
def coins(rid):
    pts = {'s0': (-1.1, 0.0, 's'), 'a1': (-2.0, 0.0, 's'), 'u1': (-2.8, 0.8, 's'), 'd1': (-2.8, -0.8, 's'), 'b1': (-3.6, 0.0, 'N'),
           'a2': (-4.5, 0.0, 's'), 'u2': (-5.3, 0.8, 's'), 'd2': (-5.3, -0.8, 's'), 'b2': (-6.1, 0.0, 'N')}
    links = [(rid, 's0', None), ('s0', 'a1', None), ('a1', 'u1', None), ('a1', 'd1', None), ('u1', 'b1', None), ('d1', 'b1', None),
             ('b1', 'a2', None), ('a2', 'u2', None), ('a2', 'd2', None), ('u2', 'b2', None), ('d2', 'b2', None)]
    return F(road(rid), pts, links)


CELLS[20] = {'coins': coins(1715)}
fill_rows(CELLS[20], [
    ('crook',    1716, 'Crook', 'straight', 1.1, 170, 0, False),
])
# consolidation: spur pair 1714 + crescent 1713 -> a drawn bow from 1714 (big, twin of cell 34's); hook 1747 + fork
# 1748 -> the coiled whip mirrored from cell 34; spur pair 1749 + diamond 1750 -> a gong from 1749 (medium).
CELLS[20].update(mirror_pieces({'whip': spiral(1741, ang=-20)}, THEME))
CELLS[20].update({'bow': bow2(1714, ang=172, rho=2.1, tip=60), 'gong': gong(1749, ang=10)})
# Review pass w1: the gong's two rim notables beside its boss read as a face; it is a ring of eight now, the rim
# notables at its two sides level with the boss (2.0 clear).
CELLS[20]['gong'] = gong(1749, ang=10, rho=1.6, n=8, nots=(2, 6))


# Cell 34 (theta -18..0 beside the axis hex): centre figure a trident rising from the outer ring road, its middle prong
# the longest; catalogue pieces round it.
def trident(rid):
    pts = {'s1': (1.1, 0.0, 's'), 's2': (2.2, 0.0, 's'), 's3': (3.3, 0.0, 's'), 'pm1': (4.4, 0.0, 's'), 'pmN': (5.5, 0.0, 'N'),
           'pl1': (3.9, -0.95, 's'), 'plN': (4.8, -1.4, 'N'), 'pr1': (3.9, 0.95, 's'), 'prN': (4.8, 1.4, 'N')}
    links = [(rid, 's1', None), ('s1', 's2', None), ('s2', 's3', None), ('s3', 'pm1', None), ('pm1', 'pmN', None),
             ('s3', 'pl1', None), ('pl1', 'plN', None), ('s3', 'pr1', None), ('pr1', 'prN', None)]
    return F(road(rid), pts, links)


CELLS[34] = {'trident': trident(1742)}
# consolidation: diamond 1707 + crook 1708 -> a drawn bow from 1707 (big); fork 1740 + arch 1741 -> a coiled whip
# from 1741 (medium).
CELLS[34].update({'bow': bow2(1707, ang=160, rho=2.2, tip=58), 'whip': spiral(1741, ang=-20)})


# Cell 30 (theta -36..-18): centre figure a compass cross, a notable hub with four straight arms, entered along its
# -theta arm from the border road; catalogue pieces round it.
def compass(C, rid, a=1.2):
    pts = {'c': (0.0, 0.0, 'N'), 'w1': (0.0, -a, 's'), 'w2': (0.0, -2 * a, 's')}
    for k, (du, dv) in {'n': (1, 0), 's': (-1, 0), 'e': (0, 1)}.items():
        pts[k + '1'] = (du * a, dv * a, 's')
        pts[k + 'N'] = (2 * du * a, 2 * dv * a, 'N')
    links = [(rid, 'w2', None), ('w2', 'w1', None), ('w1', 'c', None)] + \
            [x for k in 'nse' for x in (('c', k + '1', None), (k + '1', k + 'N', None))]
    return F(C, pts, links)


CELLS[30] = {'compass': compass(pt(47.7, -30.5), 254)}
# consolidation: crook 1704 + ring 1705 + crook 1706 -> a hung bell from 1705 (big); crescent 1738 + crook 1737 -> a
# crescent moon from 1738 (medium); fork 1739 + hook 1740 -> a blade fan from 1739 (medium).
CELLS[30].update({'bell': hung_bell(1705), 'fan': blade_fan(1739)})


# Review pass w1 (2026-11-19): the crescent moon on 1738 was the land's third moon and read as a twin of cell 41's nested
# arcs just across the wall; in its place a sickle (liêm đao), drawn here only: a handle of two nodes from 1738, then
# the blade, an open arc of five round a centre beside the handle's end at even 40-degree steps, curling over to the
# +theta side; notables on the arc's crown and at its tip. 7 nodes.
def sickle(rid, ah=10, hd=1, rb=1.6, step=40, n=5, nots=(2, 5)):
    R = road(rid)
    s0, s1 = orbit(R, 1.1, ah), orbit(R, 2.1, ah)
    K = orbit(s1, rb, ah + 90 * hd)
    pts = {'s0': (s0, 'small'), 's1': (s1, 'small')}
    keys = ['s1']
    for k in range(1, n + 1):
        pts[f'a{k}'] = (orbit(K, rb, ah - 90 * hd + hd * step * k), 'notable' if k in nots else 'small')
        keys.append(f'a{k}')
    return pts, [(rid, 's0', None), ('s0', 's1', None)] + [(p, q, K) for p, q in zip(keys, keys[1:])]


CELLS[30]['sickle'] = sickle(1738)


# Cell 27 (theta 18..36): centre figure an arrowhead flying inward, a long straight shaft and a notable tip with two
# barbs; catalogue pieces round it.
def arrow(rid):
    pts = {'s1': (1.1, 0.0, 's'), 's2': (2.2, 0.0, 's'), 's3': (3.3, 0.0, 's'), 'tip': (4.5, 0.0, 'N'),
           'bL': (3.45, -1.2, 'N'), 'bR': (3.45, 1.2, 'N')}    # review w1: barbs swept wider (tip to barb 1.24 -> 1.59)
    links = [(rid, 's1', None), ('s1', 's2', None), ('s2', 's3', None), ('s3', 'tip', None), ('tip', 'bL', None),
             ('tip', 'bR', None)]
    return F(road(rid), pts, links)


CELLS[27] = {'arrow': arrow(1745)}
# consolidation: the bell (crescent 1712 + hook 1713) and the fan (diamond 1746 + hook 1747) mirror cell 30's; crook
# 1711 + crook 1710 + hook 1525 -> a cash coin from 1711 (big); fork 272 + hairpin 273 -> a spearhead from 273 (medium).
CELLS[27].update(mirror_pieces({'bell': CELLS[30]['bell'], 'fan': CELLS[30]['fan']}, THEME))
CELLS[27].update({'coin': coin(1711, drop=2.7, ang=-20), 'spear': lens(273, ang=-65, length=3.6, h=0.95, nots=('T', 'M'))})


# ---------------------------------------------------------------------------------------------------------------------
# Cells 77 / 73 (middle band, theta -23..-11 and 11..23): a mirrored pair. 77 holds the -theta half of combo B on its
# right spoke (1969) and a spear with a diamond head rising from the outer ring road; 73 is its mirror (combo B's half
# on 1970 comes with it), the ding replaced by an axe.
def spear(rid):
    pts = {'s1': (1.1, 0.0, 's'), 's2': (2.2, 0.0, 's'), 's3': (3.3, 0.0, 's'), 'hA': (4.1, -0.65, 's'), 'hB': (4.1, 0.65, 's'),
           'tip': (4.95, 0.0, 'N')}
    links = [(rid, 's1', None), ('s1', 's2', None), ('s2', 's3', None), ('s3', 'hA', None), ('s3', 'hB', None),
             ('hA', 'tip', None), ('hB', 'tip', None)]
    return F(road(rid), pts, links)


CELLS[77] = {'crescent B': crescent_half(1969, -1), 'spear': spear(1755)}
# consolidation: diamond 1739 + diamond 1740 + crook 1754 -> a flying-sword pinwheel from 1740 (big); crescent 1756 +
# fork 1757 + diamond 1758 -> a ding cauldron standing on 1757 (big). 73 mirrors all but the ding; in its place an
# axe from 1767 (kite 1767 + ring 1747 merged).
CELLS[77].update({'wheel': pinwheel(1740, ang=210, hand=-1), 'ding': ding(1757, ang=-25)})
CELLS[73] = mirror_pieces({k: v for k, v in CELLS[77].items() if k != 'ding'}, THEME)
CELLS[73]['axe'] = axe(1767, ang=25)
# Review pass w1 (2026-11-19): that axe was the land's third (9 and 10 hold the mirrored pair, cell 10's just across the
# wall below it). 77's ding mirrored in its place fits the spacing now, so 73 mirrors 77 whole. 34 -> 37.
del CELLS[73]['axe']
CELLS[73].update(mirror_pieces({'ding': CELLS[77]['ding']}, THEME))


# Cell 41 (theta -36..-23, beside the Earth-Metal border cluster): centre figure a crown of blades, a straight band of
# five with notables at its ends and three spikes, the middle one tallest, entered from the outer ring road.
def crown(C, rid):
    pts = {f'b{k}': (0.0, 1.2 * (k - 2), 'N' if k in (0, 4) else 's') for k in range(5)}
    pts.update({'p1': (1.1, -1.4, 'N'), 'p3': (1.1, 1.4, 'N'), 'p2a': (1.1, 0.0, 's'), 'p2N': (2.2, 0.0, 'N')})
    links = [(rid, 'b2', None)] + [(f'b{k}', f'b{k + 1}', None) for k in range(4)] + \
            [('b1', 'p1', None), ('b3', 'p3', None), ('b2', 'p2a', None), ('p2a', 'p2N', None)]
    return F(C, pts, links)


CELLS[41] = {'crown': crown(pt(61.0, -28.3), 1753)}
# consolidation: crook 1737 + fork 1738 + hook 1739 -> nested arcs (a double crescent) from 1738 (big).
CELLS[41]['arcs'] = nested(1738, ang=170, R1=2.4, R2=1.4, outer=(0, 33, 66, 99, -33, -66, -99))


# Cell 50 (theta 23..36, beside the Metal-Water border cluster): centre figure twin hook swords, an S of two curved
# hooks leaving one hilt node in opposite directions, entered from the outer ring road.
def hook_swords(C, rid):
    pts = {'m': (0.0, 0.0, 's'), 'l1': (0.35, -1.1, 's'), 'l2': (1.25, -1.75, 's'), 'lN': (2.2, -1.25, 'N'),
           'r1': (-0.35, 1.1, 's'), 'r2': (-1.25, 1.75, 's'), 'rN': (-2.2, 1.25, 'N')}
    links = [(rid, 'm', None), ('m', 'l1', ('bow', 0.12)), ('l1', 'l2', ('bow', 0.12)), ('l2', 'lN', ('bow', 0.15)),
             ('m', 'r1', ('bow', 0.12)), ('r1', 'r2', ('bow', 0.12)), ('r2', 'rN', ('bow', 0.15))]
    return F(C, pts, links)


CELLS[50] = {'hook swords': hook_swords(pt(60.6, 28.4), 1763)}
fill_rows(CELLS[50], [
    ('fork',    1764, 'Fork', 'straight', 1.1, 40, 0, False),
])
# consolidation: crook 1745 + diamond 1744 + hook 1746 -> cell 41's nested arcs, mirrored; hooks 1762 + 1761 -> a
# spearhead from 1762 (medium).
CELLS[50].update(mirror_pieces({'arcs': CELLS[41]['arcs']}, THEME))
CELLS[50]['spear'] = lens(1762, ang=25, length=3.6, h=0.95, nots=('T', 'M'))


# Cells 58 / 57 (outer band, theta -28..-17 and 17..28): a mirrored pair. Centre figure a sawblade, a ring of six with
# three slanted teeth, entered from the spoke road node 1975, with a throwing star and a tiger claw; 57 mirrors all three.
def sawblade(C, rid, rho=1.5):
    vx = lambda a: (rho * math.cos(math.radians(a)), rho * math.sin(math.radians(a)))
    pts = {f'v{a}': (*vx(a), 's') for a in (30, 90, 150, 210, 270, 330)}
    for a in (330, 90, 210):
        b = math.radians(a + 22)
        pts[f't{a}'] = (2.6 * math.cos(b), 2.6 * math.sin(b), 'N')
    order = (270, 330, 30, 90, 150, 210)
    links = [(rid, 'v270', None)] + [(f'v{p}', f'v{q}', 'C') for p, q in zip(order, order[1:] + order[:1])] + \
            [(f'v{a}', f't{a}', ('bow', 0.2)) for a in (330, 90, 210)]      # review w1: teeth hooked, one way round
    return F(C, pts, links)


CELLS[58] = {'sawblade': sawblade(pt(69.3, -24.0), 1975)}
# consolidation: crook 1755 + tadpole 1754 + crook 1756 -> a four-point throwing star from 1755; fork 1720 + crook 1721
# -> a tiger claw from 1720 (both medium). 57 mirrors all three (hook 1765, ring 1764, crooks 1766 and 1731 merged).
CELLS[58].update({'star': star(1755, ang=180), 'claw': claw(1720, ang=0)})
CELLS[57] = mirror_pieces(CELLS[58], THEME)


# Cells 100 / 102 (outer corners, theta -36..-28 and 28..36): a mirrored pair. A chain whip (straight zigzag) cracks
# out of the border road into the cell; a fork and a ji halberd round it. 102 mirrors all three.
CELLS[100] = fill_rows({}, [
    ('whip',  508, 'Zigzag', 'straight', 1.2, 90, 0, False),
    ('fork', 1752, 'Fork', 'straight', 1.1, 180, 0, False),
])
# consolidation: crook 1717 + hairpin 1975 -> a ji halberd from 1717 leaning towards the cell (medium). 102 mirrors
# the whip and the fork; its diamond 1727 becomes a ji leaning the other way (the mirrored one meets the hook 1728).
CELLS[102] = mirror_pieces(CELLS[100], THEME)
CELLS[100]['ji'] = ji(1717, ang=25, side=-1)
CELLS[102]['ji'] = ji(1727, ang=-10, side=1)


# ---------------------------------------------------------------------------------------------------------------------
# Cell 903, Metal's rim (outside ring 74.3, local theta -33..33) and its two keystones. The axis road runs out to its
# open end (r 94) towards the Darkness crescent: a great sword is drawn on it, a blade leaving the road end, a
# crossguard of two crooks on the road node below it and a pair of diamonds lower down; the keystones sit alone just
# past the two hook ends. Rim pass 2026-11-18: three large figures hung outward from the ring beside the sword (R1-R3
# below), with a crescent and a kite kept near the two seams.
CELLS[903] = {
    'great blade': ray(1275, 180, (1.3, 2.5, 3.7, 4.9, 6.1), 'ssssN'),
    'keystone -12': ({'k': (pt(81.8, -12.3), 'keystone')}, [(1977, 'k', None)]),
    'keystone +12': ({'k': (pt(81.8, 12.3), 'keystone')}, [(1978, 'k', None)]),
}
fill_rows(CELLS[903], [
    ('guard L',    1274, 'Crook', 'straight', 1.2, -90, 0, False),
    ('guard R',    1274, 'Crook', 'straight', 1.2, 90, 0, True),
    ('diamond L',   502, 'Diamond', 'straight', 1.2, -90, 0, False),
    ('diamond R',   502, 'Diamond', 'straight', 1.2, 90, 0, False),
    ('crescent',   1717, 'Crescent', 'straight', 1.2, 180, 0, False),
    ('kite',       1728, 'Tadpole', 'kite', 1.2, 180, 0, False),
])
# Rim pass 2026-11-18 (rim-brief.md): the rim's largest figures, drawn here once each and never reused. They replace the
# hook 1725, the crook 1735 and the two gongs 1721 / 1731; the sword and the keystones stay.


# R1 weiqi board (cờ vây, vi kỳ): a 5 x 5 lattice on a polar grid round a centre O well inside the ring, so the board fans
# gently outward; rows are arcs round O, files straight rays. Stones (notables) on the four star points, the centre
# point and two far corners, never on neighbouring points. It hangs by its two near corners from 1720 and 1719 (a
# pass-through, the board slung between two ring nodes).
def weiqi903(O, R0=16.0, gap=1.85, step=5.4, stones=((1, 1), (1, 3), (3, 1), (3, 3), (2, 2), (4, 0), (4, 4))):
    pts = {f'p{i}{j}': (R0 + i * gap, 180 + (j - 2) * step, 'N' if (i, j) in stones else 's')
           for i in range(5) for j in range(5)}
    links = [(1720, 'p00', None), ('p04', 1719, None)]
    links += [(f'p{i}{j}', f'p{i}{j + 1}', 'C') for i in range(5) for j in range(4)]
    links += [(f'p{i}{j}', f'p{i + 1}{j}', None) for i in range(4) for j in range(5)]
    return G(O, pts, links)


CELLS[903]['weiqi board'] = weiqi903(pt(60.3, -22.0))


# R2 linked rings (cửu liên hoàn, the linked-rings puzzle): a ring of eight round Q with four smaller rings of six on its
# diagonals, each sharing one node with it, and a centre node on four spokes to the ring's cardinal nodes. Notables:
# the four satellites' far points and the ring's three other cardinal nodes. One entry, the ring's near node, from 1730.
def rings903(Q, a=1.8, b=1.15):
    def at(c, rho, ang):                       # every angle in Q's frame, so the satellites line up exactly
        D = direction(Q, ang)
        return (c[0] + rho * D[0], c[1] + rho * D[1])
    nodes = {f'r{k}': (at(Q, a, 45 * k), 'notable' if k in (2, 4, 6) else 'small') for k in range(8)}
    nodes['c'] = (Q, 'small')
    links = [(1730, 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 8}', Q) for k in range(8)]
    links += [('c', f'r{k}', None) for k in (0, 2, 4, 6)]
    for s in (1, 3, 5, 7):
        S = at(Q, a + b, 45 * s)
        keys = [f'r{s}'] + [f's{s}{m}' for m in range(1, 6)]
        for m in range(1, 6):
            nodes[f's{s}{m}'] = (at(S, b, 45 * s + 180 + 60 * m), 'notable' if m == 3 else 'small')
        links += [(keys[m], keys[(m + 1) % 6], S) for m in range(6)]
    return nodes, links


CELLS[903]['linked rings'] = rings903(pt(79.6, 20.0))


# R3 turned pentagons (a pair mirrored across the axis): an outer pentagon with a node at each edge's middle, and
# inside it a smaller pentagon turned 36 degrees, so each of its vertices faces an outer edge and is strutted straight
# out to that edge's middle. All links straight. The outer near vertex is the entry; its other four vertices, the
# tips, are the notables.
def pentagons903(O, rid, R=3.8, r=1.9):
    nodes = {}
    for j in range(5):
        nodes[f'v{j}'] = (orbit(O, R, 72 * j), 'notable' if j else 'small')
        nodes[f'm{j}'] = (orbit(O, R * math.cos(math.radians(36)), 36 + 72 * j), 'small')
        nodes[f'i{j}'] = (orbit(O, r, 36 + 72 * j), 'small')
    links = [(rid, 'v0', None)]
    for j in range(5):
        links += [(f'v{j}', f'm{j}', None), (f'm{j}', f'v{(j + 1) % 5}', None), (f'm{j}', f'i{j}', None),
                  (f'i{j}', f'i{(j + 1) % 5}', None)]
    return nodes, links


CELLS[903]['pentagons R'] = pentagons903(pt(79.5, 7.6), 1734)
CELLS[903]['pentagons L'] = mirror_pieces({'p': CELLS[903]['pentagons R']}, THEME)['p']


# ---------------------------------------------------------------------------------------------------------------------
# Density pass (target about 0.25-0.32 nodes per unit², rules 3.10 C6): catalogue pieces on road nodes that carried
# nothing, families in an order I chose per cell, the direction towards the cell centre or 25 degrees either side, the
# first of my candidates that passed the checks with everything else (out/metal-dense.py); then reviewed by eye.
fill_rows(CELLS[20], [
    ('d crescent 1491', 1491, 'Crescent', 'bow out', 1.2, 145, 0, True),  # review w1: was a crook, twin of crook 1716
    ('d crook 1492', 1492, 'Crook', 'straight', 1.2, 47, 0, True),
])
fill_rows(CELLS[34], [
    ('d arch 1709', 1709, 'Arch', 'straight', 1.2, -170, 0, False),
    ('d arch 1743', 1743, 'Arch', 'bow out', 1.2, -12, 0, False),   # review w1: a bowl, not a second fan by the trident
])
fill_rows(CELLS[30], [
    ('d hook 1520', 1520, 'Hook', 'bow out', 1.2, 130, 0, True),  # review w1: was a spur pair 1.06 from the compass; open, not a loop
    ('d crook 253', 253, 'Crook', 'straight', 1.2, 101, 0, True),
    ('d spur pair 1521', 1521, 'Spur pair', 'straight', 1.2, 49, 0, False),
])
fill_rows(CELLS[27], [
    ('d arch 1744', 1744, 'Arch', 'bow out', 1.2, -11, 0, False),   # review w1: curved, no second V beside the arrow
])
fill_rows(CELLS[41], [
    ('d crook 1521', 1521, 'Crook', 'straight', 1.2, 127, 0, False),
    ('d tadpole 1522', 1522, 'Tadpole', 'kite', 1.2, 49, 0, False),
    ('d crescent 1752', 1752, 'Crescent', 'bow out', 1.2, -12, 0, False),  # review w1: was a diamond 1.16 from the crown
    ('d hairpin 1754', 1754, 'Hairpin', 'straight', 1.2, -51, 0, True),
])
fill_rows(CELLS[50], [
    ('d hook 1526', 1526, 'Hook', 'straight', 1.2, -149, 0, False),
    ('d crook 1527', 1527, 'Crook', 'straight', 1.2, -51, 0, False),
])
# Review pass w1, cell 50: an empty patch on its -theta side under the arcs, a lone fork at its foot. The fork becomes a
# hairpin curling up out of 1764 and a crescent bows down from 1746 to meet it (+5 nodes, the four cell 102 gave up).
del CELLS[50]['fork']
fill_rows(CELLS[50], [
    ('hairpin 1764',  1764, 'Hairpin', 'bow out', 1.2, 35, 0, True),
    ('d crescent 1746', 1746, 'Crescent', 'bow out', 1.2, 150, 0, True),
])
fill_rows(CELLS[77], [
    ('d diamond 1741', 1741, 'Diamond', 'cusped', 1.2, -128, 0, False),
])
fill_rows(CELLS[73], [
    ('d hairpin 1748', 1748, 'Hairpin', 'straight', 1.2, 128, 0, True),
])
fill_rows(CELLS[58], [
    ('d tadpole 1753', 1753, 'Tadpole', 'round', 1.2, 140, 0, False),   # review w1: was kite at 125, 0.94 from a tooth
    ('d crook 1718', 1718, 'Crook', 'straight', 1.2, 51, 0, False),
    ('d tadpole 1719', 1719, 'Tadpole', 'kite', 1.2, 45, 0, False),
])
fill_rows(CELLS[57], [
    ('d hairpin 1763', 1763, 'Hairpin', 'straight', 1.2, -125, 0, True),
    ('d hairpin 1729', 1729, 'Hairpin', 'bow out', 1.2, -45, 0, True),  # review w1: curls off the saw (was 1.13 from a tooth)
])
fill_rows(CELLS[100], [
    ('d hairpin 1522', 1522, 'Hairpin', 'straight', 1.2, 136, 0, False),
    ('d crook 1751', 1751, 'Crook', 'straight', 1.2, 160, 0, False),
    ('d crook 1753', 1753, 'Crook', 'straight', 1.2, -136, 0, False),
])
# Review pass w1, cell 100: four sticks clumped at the top (fork and crook notables 1.07 apart) beside an empty corner.
# The fork moves to that corner as a crescent curving from 509, and the whip waves (cell 102's, mirrored).
del CELLS[100]['fork']
fill_rows(CELLS[100], [
    ('whip',       508, 'Zigzag', 'wave', 1.2, 80, 0, False),
    ('crescent',   509, 'Crescent', 'bow out', 1.2, 40, 0, False),
])
fill_rows(CELLS[102], [
    ('d crook 1763', 1763, 'Crook', 'straight', 1.2, 136, 0, False),
    ('d ring 1761', 1761, 'Ring', 'straight', 1.2, -185, 0, False),
    ('d ring 1976', 1976, 'Ring', 'round', 1.2, 100, 0, False),
    ('d hook 1728', 1728, 'Hook', 'straight', 1.2, 44, 0, False),
])
# Review pass w1 (review-brief.md, 2026-11-19), cell 102: the middle was a clump of nine notables. The fork mirrored from
# 100 is dropped, the whip waves and leans off the ji (notables 1.06 -> 1.8 apart), and the ring on 1976 is drawn round
# so it no longer repeats the straight pentagon on 1761.
del CELLS[102]['fork']
CELLS[102]['whip'] = fill_rows({}, [('whip', 511, 'Zigzag', 'wave', 1.2, -80, 0, True)])['whip']
fill_rows(CELLS[9], [
    ('d arch 1725', 1725, 'Arch', 'bow out', 1.2, -20, 0, False),   # review w1: was a straight hairpin, a stick; a bowl under the rack
])
fill_rows(CELLS[113], [
    ('d diamond 1518', 1518, 'Diamond', 'cusped', 1.2, 134, 0, False),
    ('d hook 1691', 1691, 'Hook', 'bow out', 1.2, 160, 0, True),    # review w1: was a cusped diamond, twin of 1518's
])
fill_rows(CELLS[116], [
    ('d hairpin 1699', 1699, 'Hairpin', 'bow out', 1.2, 134, 0, False),   # review w1: curved (was straight, a stick)
])


# ---------------------------------------------------------------------------------------------------------------------
# Density pass v2 (design/dao-do/cells/density-brief.md, 2026-11-18): figures split by a wall road, one half each side,
# the second half the mirror of the first across the wall (celllib.wall_pair), mixed with grown figures, new pieces and
# pairs mirrored across the land axis. Each figure is drawn fresh here, never with the helpers above.
from celllib import wall_pair  # noqa: E402


def WF(wa, wb, at, towards, pts, links):
    """A half figure in a wall frame: x along the wall from road node wa towards wb, y across it towards the point
    `towards` (inside the half's cell), the origin at `at` (a road node id or an (x, y) point). pts {key: (x, y, kind)};
    links [(a, b, arc)] with a/b a key or a road id, arc None (straight) or an (x, y) centre in the same frame."""
    A, B = road(wa), road(wb)
    O = road(at) if isinstance(at, int) else at
    L0 = math.dist(A, B)
    ex = ((B[0] - A[0]) / L0, (B[1] - A[1]) / L0)
    ey = (-ex[1], ex[0])
    if (towards[0] - O[0]) * ey[0] + (towards[1] - O[1]) * ey[1] < 0:
        ey = (-ey[0], -ey[1])
    X = lambda x, y: (O[0] + x * ex[0] + y * ey[0], O[1] + x * ex[1] + y * ey[1])
    nodes = {k: (X(x, y), KIND[kd]) for k, (x, y, kd) in pts.items()}
    return nodes, [(a, b, X(*c) if c else None) for a, b, c in links]


def on_circle(c, R, angs, kinds, pre):
    """Frame points on a circle of radius R round the frame point c at the given angles (degrees from +x towards +y)."""
    return {f'{pre}{i}': (c[0] + R * math.cos(math.radians(a)), c[1] + R * math.sin(math.radians(a)), k)
            for i, (a, k) in enumerate(zip(angs, kinds))}


def bend(P, Q, sag, n):
    """Frame helper: the centre of the circle through frame points P and Q whose arc bulges `sag` x chord to the left of
    P->Q (negative: to the right), and n points at even steps on that arc between them."""
    mx, my = (P[0] + Q[0]) / 2, (P[1] + Q[1]) / 2
    dx, dy = Q[0] - P[0], Q[1] - P[1]
    Lc = math.hypot(dx, dy)
    nx, ny = -dy / Lc, dx / Lc
    h = sag * Lc
    R = (Lc * Lc / 4 + h * h) / (2 * abs(h))
    c = (mx + nx * (h - math.copysign(R, h)), my + ny * (h - math.copysign(R, h)))
    a0 = math.atan2(P[1] - c[1], P[0] - c[0]); a1 = math.atan2(Q[1] - c[1], Q[0] - c[0])
    da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
    return c, [(c[0] + R * math.cos(a0 + da * k / (n + 1)), c[1] + R * math.sin(a0 + da * k / (n + 1))) for k in range(1, n + 1)]


# W1, cells 4 | 61, ring 33.2 between 1695 and 1696: a cash coin strung on the ring road (coins were carried on cords).
# Each half: a rim of five round the chord's midpoint (radius 2.0, 30-degree steps), entered from both road nodes, its
# top a notable; two hole nodes on the same rays (radius 0.95), the half of the coin's hole, joined to the rim's 60-degree nodes. 7 + 7 nodes.
def strung_coin():
    M = ((road(1695)[0] + road(1696)[0]) / 2, (road(1695)[1] + road(1696)[1]) / 2)
    c = (0, 0)
    pts = on_circle(c, 2.0, (150, 120, 90, 60, 30), 'ssNss', 'o')
    pts.update(on_circle(c, 0.95, (120, 60), 'ss', 'h'))
    links = [(1695, 'o0', None), ('o0', 'o1', c), ('o1', 'o2', c), ('o2', 'o3', c), ('o3', 'o4', c), ('o4', 1696, None),
             ('o1', 'h0', None), ('h0', 'h1', None), ('h1', 'o3', None)]
    return WF(1695, 1696, M, pt(37, -11), pts, links)


_h, _o = wall_pair({'coin W1': strung_coin()}, 1695, 1696)
CELLS[61].update(_h); CELLS[4].update(_o)


# W2, cells 34 | 30, the spoke at -18 from 1740: a willow-leaf blade whose spine is the road. Each half: one edge arc of
# seven at even steps round a centre beyond the road (radius 5.21, 1.65 wide), from a node beside 1740 to the notable
# tip short of 1965, a second notable past the peak; the wall node 1966 sits at the blade's heart. 7 + 7 nodes.
def leaf_blade():
    c = (4.0, -3.56)
    angs = [125.2 - 11.37 * k for k in range(7)]
    pts = on_circle(c, 5.21, angs, 'ssssNsN', 'e')
    links = [(1740, 'e0', None)] + [(f'e{k}', f'e{k + 1}', c) for k in range(6)]
    return WF(1740, 1706, 1740, pt(48, -12), pts, links)


_h, _o = wall_pair({'blade W2': leaf_blade()}, 1740, 1706)
CELLS[34].update(_h); CELLS[30].update(_o)


# W3, cells 27 | 20, the spoke at +18 from 1747: a pair of knife coins (đao tệ, bronze knife money) standing back to
# back on the road, like a lyre. Each half: the blade, an arc of four from a node beside 1747 bowed away from the road,
# into the coin's ring head, a ring of four round its own centre with its far node a notable. 7 + 7 nodes.
def knife_coin():
    S, K, r = (1.0, 0.75), (5.4, 1.4), 0.75
    head = on_circle(K, r, (180, 90, 0, -90), 'ssNs', 'k')          # k0 left (the blade's end), k1 top, k2 far, k3 bottom
    cb, (b1, b2) = bend(S, (head['k0'][0], head['k0'][1]), 0.07, 2)
    pts = {'s0': (*S, 's'), 'b1': (*b1, 's'), 'b2': (*b2, 's'), **head}
    links = [(1747, 's0', None), ('s0', 'b1', cb), ('b1', 'b2', cb), ('b2', 'k0', cb)] +             [(f'k{q}', f'k{(q + 1) % 4}', K) for q in range(4)]
    return WF(1747, 1713, 1747, pt(47, 26), pts, links)


_h, _o = wall_pair({'knives W3': knife_coin()}, 1747, 1713)
CELLS[27].update(_h); CELLS[20].update(_o)


# N1, cell 81 (hub, the sparsest cell after the start cell), a pair mirrored across the land axis: a row of armour
# scales (lamellae) hung from the border road node 32 (and 33): nodes on the circle r 9.6 round the tree centre every
# 8.5 degrees, scallop peaks on r 8.5 between them (towards the hub), each scale an arc through its peak.
def scale_row(rid=32):
    keys = [('a0', 9.6, -30, 's'), ('p1', 8.5, -25.75, 's'), ('a1', 9.6, -21.5, 'N'), ('p2', 8.5, -17.25, 's'),
            ('a2', 9.6, -13, 'N')]
    nodes = {k: (pt(r, th), KIND[kd]) for k, r, th, kd in keys}

    def centre3(p, q, s):              # circle through three points
        ax, ay = p; bx, by = q; cx, cy = s
        d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
        ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
        uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
        return (ux, uy)
    xy = lambda k: nodes[k][0]
    c1 = centre3(xy('a0'), xy('p1'), xy('a1')); c2 = centre3(xy('a1'), xy('p2'), xy('a2'))
    return nodes, [(rid, 'a0', None), ('a0', 'p1', c1), ('p1', 'a1', c1), ('a1', 'p2', c2), ('p2', 'a2', c2)]


CELLS[81]['scales L'] = scale_row(32)
CELLS[81]['scales R'] = mirror_pieces({'s': CELLS[81]['scales L']}, THEME)['s']


# G1, cell 10, grown: the hex shield gets an outer rim over its top, an arc of five on the orbit 2.4 round the shield's
# centre (-50..50 degrees from inward, 25-degree steps) between its two notable vertices h2 and h4. +5 nodes.
def grow_shield(piece, C):
    nodes, links = piece
    nodes = dict(nodes); links = list(links)
    angs = (-50, -25, 0, 25, 50)
    for a in angs:
        nodes[f'c{a}'] = (orbit(C, 2.4, a), 'small')
    links += [('h2', 'c-50', None), ('c50', 'h4', None)] + [(f'c{p}', f'c{q}', C) for p, q in zip(angs, angs[1:])]
    return nodes, links


CELLS[10]['shield'] = grow_shield(CELLS[10]['shield'], pt(69.6, 11.0))
# Review pass w1 (2026-11-19), cell 10: the land's densest cell had no small piece and three closed rings beside the
# shield (the chain's two, the hammer's). The chain gives way to a hairpin curling down out of 1767 (8 -> 5 nodes).
del CELLS[10]['chain']
fill_rows(CELLS[10], [('hairpin 1767', 1767, 'Hairpin', 'bow out', 1.2, 165, 0, True)])


# W4, cells 113 | 4, ring 33.2 at 1692: a silver longevity lock (trường mệnh tỏa). Each half: the shackle, an arc
# round its centre from the top node beside 1692 down both sides to the body's corners, and the body below them, two
# arcs bowed outward meeting at the notable tip. 6 + 6 nodes.
def longevity_lock():
    K, R = (0.35, 2.0), 0.75
    at = lambda a: (K[0] + R * math.cos(math.radians(a)), K[1] + R * math.sin(math.radians(a)))
    k0, cL, cR, tip = at(-90), at(170), at(10), (0.35, 3.9)
    bl, (bL,) = bend(cL, tip, 0.1, 1)
    br, (bR,) = bend(cR, tip, -0.1, 1)
    pts = {'k0': (*k0, 's'), 'cL': (*cL, 's'), 'cR': (*cR, 's'), 'bL': (*bL, 's'), 'bR': (*bR, 's'), 'tip': (*tip, 'N')}
    links = [(1692, 'k0', None), ('k0', 'cL', K), ('k0', 'cR', K), ('cL', 'bL', bl), ('bL', 'tip', bl),
             ('cR', 'bR', br), ('bR', 'tip', br)]
    return WF(1692, 1693, 1692, pt(37, -29), pts, links)


_h, _o = wall_pair({'lock W4': longevity_lock()}, 1692, 1693)
CELLS[113].update(_h); CELLS[4].update(_o)


# W5, cells 116 | 4, ring 33.2 at 1697: twin rings (càn khôn quyển) kissing at the road node, a figure eight the ring
# road runs through. Each half: a ring of five round a centre 1.05 from 1697 (straight across the wall), the road node
# itself the ring's sixth point (75 then 52.5-degree steps from it), the far node a notable. 5 + 5 nodes.
def twin_ring():
    K = (0.0, 1.05)
    R = 1.05
    pts = on_circle(K, R, (-15, 37.5, 90, 142.5, 195), 'ssNss', 'r')
    links = [(1697, 'r0', K)] + [(f'r{k}', f'r{k + 1}', K) for k in range(4)] + [('r4', 1697, K)]
    return WF(1697, 1523, 1697, pt(37, 30), pts, links)


_h, _o = wall_pair({'rings W5': twin_ring()}, 1697, 1523)
CELLS[116].update(_h); CELLS[4].update(_o)


# A1, cell 68, an in-cell pass-through: a bagua mirror (bronze, eight-sided) standing on the inner ring road between
# 1715 and 1714, in the empty middle of the cell under its bell. Eight nodes on the circle 1.6 round a centre 2.3 above
# the chord's midpoint, at 22.5 + 45k degrees so a flat side faces the road, joined by straight sides; the two lower
# corners hang from the two road nodes, the two side corners above the middle are notable. 8 nodes.
def bagua():
    A, B = road(1715), road(1714)
    M = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
    angs = (-112.5, -67.5, -22.5, 22.5, 67.5, 112.5, 157.5, 202.5)
    pts = on_circle((0, 2.3), 1.6, angs, 'sssNsssN', 'g')
    pts['g7'] = (pts['g7'][0], pts['g7'][1], 's'); pts['g6'] = (pts['g6'][0], pts['g6'][1], 'N')
    links = [(1715, 'g0', None), ('g1', 1714, None)] + [(f'g{k}', f'g{(k + 1) % 8}', None) for k in range(8)]
    return WF(1715, 1714, M, pt(38, 10), pts, links)


CELLS[68]['bagua'] = bagua()
# Review pass w1 (2026-11-19), cell 68: five closed loops in one cell, and its two chain links the land's third copy
# (cells 9 and 10 hold the mirrored pair). The chain gives way to a crescent bowing out of 1700 beside the bell (an
# open arc), and the bagua mirror's eight sides are arcs round its own centre (a round bronze mirror on the road, no
# straight sides). 37 -> 33.
_bn, _bl = CELLS[68]['bagua']
_bc = (sum(p[0] for p, _ in _bn.values()) / len(_bn), sum(p[1] for p, _ in _bn.values()) / len(_bn))
CELLS[68]['bagua'] = (_bn, [(a, b, None if isinstance(a, int) or isinstance(b, int) else _bc) for a, b, _ in _bl])
del CELLS[68]['chain']
fill_rows(CELLS[68], [('crescent 1700', 1700, 'Crescent', 'bow out', 1.2, 170, 0, True)])


# G2, cell 81, grown: the diamond under the hub gets a setting, an arc of five on the orbit 1.8 round the diamond's
# centre (90..270 degrees, round its far side, 45-degree steps), joined radially to the diamond's two side nodes; the
# diamond's tip turns small and the setting's two 135-degree nodes are its notables. +5.
def grow_diamond(piece, C):
    nodes, links = piece
    nodes = dict(nodes); links = list(links)
    angs = (90, 135, 180, 225, 270)
    for a in angs:
        nodes[f'h{a}'] = (orbit(C, 1.8, a), 'notable' if a in (135, 225) else 'small')
    nodes['n3'] = (nodes['n3'][0], 'small')            # its notable moves out onto the setting
    near = lambda a: min(('n1', 'n2'), key=lambda k: math.dist(nodes[k][0], nodes[f'h{a}'][0]))
    links += [(near(90), 'h90', None), ('h270', near(270), None)] + [(f'h{p}', f'h{q}', C) for p, q in zip(angs, angs[1:])]
    return nodes, links


CELLS[81]['diamond'] = grow_diamond(CELLS[81]['diamond'], pt(6.25, 0))


# G3, cell 34, grown: the arch on 1709 closes into a hanging ring (a pendant ring of the sword's tassel), an arc of three
# round its own centre from one notable end of the arch to the other, bowed outward into the empty middle of the cell
# between the bow, the trident and the axis hex. +3 nodes.
def close_arch(piece, a, b, depth, n=3):
    nodes, links = piece
    nodes = dict(nodes); links = list(links)
    P, Q = nodes[a][0], nodes[b][0]
    M = ((P[0] + Q[0]) / 2, (P[1] + Q[1]) / 2)
    out = direction(M, 180)                                      # outward, away from the tree centre
    T = (M[0] + depth * out[0], M[1] + depth * out[1])           # the arc's lowest point
    # the circle through P, T and Q
    (ax, ay), (bx, by), (cx, cy) = P, T, Q
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    C = (ux, uy); R = math.dist(C, P)
    a0 = math.atan2(P[1] - uy, P[0] - ux); a1 = math.atan2(Q[1] - uy, Q[0] - ux); at = math.atan2(T[1] - uy, T[0] - ux)
    da = (a1 - a0) % (2 * math.pi)
    if (at - a0) % (2 * math.pi) > da:                           # go round through T
        da -= 2 * math.pi
    keys = [a] + [f'z{k}' for k in range(n)] + [b]
    for k in range(n):
        t = a0 + da * (k + 1) / (n + 1)
        nodes[f'z{k}'] = ((ux + R * math.cos(t), uy + R * math.sin(t)), 'small')
    links += [(p, q, C) for p, q in zip(keys, keys[1:])]
    return nodes, links


CELLS[34]['d_arch_1709'] = close_arch(CELLS[34]['d_arch_1709'], 'n2', 'n4', 2.4)


# N2, cells 116 and 113, a pair mirrored across the land axis: a curved breastplate (hộ tâm kính's frame) hung from the
# ring node 1710 (and 1703) into the cell's empty corner. Two concentric arcs round the road node itself, three nodes
# each at -35, 0, 35 degrees about the direction `ang` (radii 1.3 and 2.2), joined at their ends; the outer middle
# node a notable. 6 nodes each.
def plate(rid=1710, ang=20):
    R0 = road(rid)
    pts = {}
    for nm, rho in (('i', 1.3), ('o', 2.2)):
        for k, a in enumerate((-35, 0, 35)):
            pts[f'{nm}{k}'] = (rho, ang + a, 'N' if (nm, k) == ('o', 1) else 's')
    links = [(rid, 'i1', None), ('i1', 'i0', R0), ('i1', 'i2', R0), ('i0', 'o0', None), ('i2', 'o2', None),
             ('o0', 'o1', R0), ('o1', 'o2', R0)]
    return G(R0, pts, links)


CELLS[116]['plate'] = plate()
CELLS[113]['plate'] = mirror_pieces({'p': CELLS[116]['plate']}, THEME)['p']


# ---------------------------------------------------------------------------------------------------------------------
# Review pass w2 (review-brief.md, window 2, 2026-11-19): pairs of cells sharing a wall road, judged as one picture.
# 20 | 34 | 68: cell 20's crook 1716 ran on from cell 68's crook through 1716 as one zigzag stick across the wall, and
# stood beside the crescent 1491 as a second curl; it goes. Its lone crook on the axis node 1492 becomes a bowl from
# 1750 under the gong, answering cell 34's bowl on 1743 across the axis hex. 53 -> 52.
del CELLS[20]['crook']
del CELLS[20]['d_crook_1492']
fill_rows(CELLS[20], [('d arch 1750', 1750, 'Arch', 'bow out', 1.2, -15, 0, True)])


# 30 | 61: cell 61's hand bell on 1694 sat a few units from cell 30's hung bell across the wall (and next to 68's bell,
# the land's fourth bell in four neighbouring cells). In its place an iron fan (thiết phiến), drawn here only: a handle
# of two from 1694, three ribs from the pivot to a rim of five on one circle round the pivot at even 20-degree steps,
# the rim's two ends notable. 7 nodes, as the bell.
def iron_fan(rid, ang=0, stem=1.0, R=2.0, spread=100, piv=1.0):
    S = orbit(road(rid), stem, ang)
    P = orbit(S, piv, ang)
    pts = {'s0': (S, 'small'), 'p': (P, 'small')}
    for k in (-2, -1, 0, 1, 2):
        pts[f'r{k}'] = (orbit(P, R, ang + spread * k / 4), 'notable' if k in (-2, 2) else 'small')
    links = [(rid, 's0', None), ('s0', 'p', None), ('p', 'r-2', None), ('p', 'r0', None), ('p', 'r2', None)]
    links += [(f'r{k}', f'r{k + 1}', P) for k in (-2, -1, 0, 1)]
    return pts, links


del CELLS[61]['bell']
CELLS[61]['iron fan'] = iron_fan(1694, ang=165, R=1.8, spread=80)

# 30 | 41: cell 30's spur pair on 1521 and cell 41's crook on 1521 left the node as two sticks across the wall, beside the
# compass's straight arms. The spur pair becomes a small round bead (Diamond, round), so the compass is the corner's one
# straight figure. 5 -> 4.
del CELLS[30]['d_spur_pair_1521']
fill_rows(CELLS[30], [('d bead 1521', 1521, 'Diamond', 'round', 1.2, 49, 0, False)])


# 41 | 100 (and 30 | 41): cell 41's crown read as a twig of sticks, five notables on a long band crowded by the crescent
# 1752 and the hairpin 1754. Redrawn as a three-pointed crown: a shorter band of five, the two side points rising
# from its ends and leaning out, the middle point the tallest; only the three points notable. 9 -> 9.
def crown3(C, rid, w=0.9, side=(1.2, 1.9), mid=2.5):
    pts = {f'b{k}': (0.0, w * (k - 2), 's') for k in range(5)}
    pts.update({'p0': (side[0], -side[1], 'N'), 'p4': (side[0], side[1], 'N'), 'p2a': (mid / 2, 0.0, 's'),
                'p2N': (mid, 0.0, 'N')})
    links = [(rid, 'b2', None)] + [(f'b{k}', f'b{k + 1}', None) for k in range(4)] + \
            [('b0', 'p0', None), ('b4', 'p4', None), ('b2', 'p2a', None), ('p2a', 'p2N', None)]
    return F(C, pts, links)


CELLS[41]['crown'] = crown3(pt(61.0, -28.3), 1753)

# 41 | 100 and 58 | 100: cell 100's side of the ring wall was three sticks under 41's row of small pieces (hairpin 1522,
# crooks 1751 and 1753, the 1753 crook lying along the wall, two crooks alike in one small cell). Both crooks give way to
# one round ring from 1752 into the cell's empty top middle (it echoes cell 102's rings across the axis). 27 -> 26.
del CELLS[100]['d_crook_1751']
del CELLS[100]['d_crook_1753']
fill_rows(CELLS[100], [('d ring 1752', 1752, 'Ring', 'round', 1.2, 165, 0, True)])

# 27 | 50: cell 50's spearhead on 1762 was the same drawing as cell 27's on 273 one cell away (lens, same numbers); it
# gives way to a small two-pronged fork with bowed prongs (a round bead there made a row of loops with cell 102's two
# rings and 57's new tadpole). 50 | 57: cell 57's straight hairpin on 1763 sat beside cell 50's hairpin on 1764 on the
# same wall; cell 58's round tadpole on 1753 is mirrored in its place (57 mirrors 58 across the axis). 40 -> 37.
del CELLS[50]['spear']
fill_rows(CELLS[50], [('d fork 1762', 1762, 'Fork', 'bow out', 1.2, 10, 0, True)])
del CELLS[57]['d_hairpin_1763']
CELLS[57].update(mirror_pieces({'d tadpole 1763': CELLS[58]['d_tadpole_1753']}, THEME))


# 9 | 77, 9 | 58, 9 | 10: cell 9's chevrons (its centre figure, "»" flying at the junction) read as two sticks on long
# poles beside the round chain, rack and bowl. Redrawn on circles: each arm one arc bowed outward (a circle through the
# apex and the notable tip, its middle node on the arc), the pole broken by a node a unit behind the apex. 10 -> 12.
def chevron3(apex, rid, a=0.95, sag=0.1):
    pts = {'m': (-1.0, 0.0, 's'), 'a': (0.0, 0.0, 's')}
    links = [(rid, 'm', None), ('m', 'a', None)]
    for nm, su in (('u', 1), ('d', -1)):
        Q = (su * 2 * a, -2 * a)
        c, (p1,) = bend((0.0, 0.0), Q, su * sag, 1)
        pts[nm + '1'] = (*p1, 's')
        pts[nm + 'N'] = (*Q, 'N')
        links += [('a', nm + '1', c), (nm + '1', nm + 'N', c)]
    return F(apex, pts, links)


CELLS[9]['chevron 1'] = chevron3(pt(70.8, -8.0), 1724)
CELLS[9]['chevron 2'] = chevron3(pt(70.8, -11.6), 1723)

# 4 | 61 against 4 | 68: the start cell's -theta side carries the strung coin W1 on the ring, its +theta side nothing (the
# coin's mirror place is under cell 68's bell). A small round bead on a stalk rises from 1702 to answer it lightly; the
# cell stays sparse. +5.
fill_rows(CELLS[4], [('d bead 1702', 1702, 'Tadpole', 'round', 1.2, 5, 0, False)])

# 903 | 100: the rim's straight crescent on 1717 ran on from cell 100's ji through 1717 as one stick across the ring. It
# becomes a small round ring at the node (Diamond, round), read as the ji's pommel ring. The rim's large figures stay.
del CELLS[903]['crescent']
fill_rows(CELLS[903], [('ring 1717', 1717, 'Diamond', 'round', 1.2, 180, 0, False)])


# ---------------------------------------------------------------------------------------------------------------------
# Review pass w3 (review-brief.md, window 3, 2026-11-19): a cell and all its neighbours, judged as one picture.
# Cell 4 with 61, 68, 113, 116 and the hub: the two flying swords were the start cell's only figures off the ring road,
# each a straight row of five ending in its notable (straight spikes). Each sword's blade is now one arc (a circle
# through its first node and its tip, sag 0.17 of the chord, bowed towards the hub; 0.1 still read straight), so the pair curve in over the start
# figure like two sabres; same nodes, same tips. 5 -> 5 each.
def curved_sword(rid, ang, sag, dists=(1.3, 5.9)):
    n, _ = ray(rid, ang, dists, 'sN')
    P, Q = n['n0'][0], n['n1'][0]
    c, mids = bend(P, Q, sag, 3)
    pts = {'n0': (P, 'small'), 'n1': (mids[0], 'small'), 'n2': (mids[1], 'small'), 'n3': (mids[2], 'small'),
           'n4': (Q, 'notable')}
    return pts, [(rid, 'n0', None)] + [(f'n{k}', f'n{k + 1}', c) for k in range(4)]


CELLS[4]['sword L'] = curved_sword(256, 90, -0.17)
CELLS[4]['sword R'] = curved_sword(275, -90, 0.17)


# 61 / 68 with 4, 20, 34: cell 68's crook on 1716 was a three-node bent stick in the slot between its spade and the bagua,
# below them nothing round. It becomes a hook curling up and over towards the spade (Hook, bow out), and across the wall
# it answers cell 20's crescent from the axis node 1491, the two commas turned against each other. 3 -> 4.
del CELLS[68]['crook']
fill_rows(CELLS[68], [('hook 1716', 1716, 'Hook', 'bow out', 1.1, -10, 0, True)])


# 113 / 116 with 4, 27, 30, 68 and Earth 23/114, Water 26/115: cell 116's crescent on 1711 was drawn straight, a long
# stick of four from the wall to a notable in the corner's middle. Drawn bow out, a curl like the corner's other small
# pieces (cell 113's crook on 1704 was tried bowed too: it then twins the hook 1691 beside it, so it stays). 4 -> 4.
fill_rows(CELLS[116], [('crescent', 1711, 'Crescent', 'bow out', 1.1, 0, 0, True)])


# 41 / 50 with 30, 58, 77, 100 and Earth 23, 48, 106 (open point from w2): the crown's two side points were notables on
# one straight link from the band's ends (straight spikes). Each side point is now a curved horn of two links, one arc
# round its own centre from the band's end out and curling in towards the middle point (a small node on the arc, the
# notable at its tip, 1.5 above the band; taller horns came 1.16 from the arcs' end notable); the band and the tall
# middle point stay. 9 -> 11 (big).
def circle3(p, q, s):              # centre of the circle through three points
    (ax, ay), (bx, by), (cx, cy) = p, q, s
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def crown4(C, rid, w=0.9, horn=((0.8, 2.05), (1.5, 1.75)), mid=2.6):
    pts = {f'b{k}': (0.0, w * (k - 2), 's') for k in range(5)}
    links = [(rid, 'b2', None)] + [(f'b{k}', f'b{k + 1}', None) for k in range(4)]
    for sgn, b, nm in ((-1, 'b0', 'L'), (1, 'b4', 'R')):
        P, A, T = (0.0, sgn * 2 * w), (horn[0][0], sgn * horn[0][1]), (horn[1][0], sgn * horn[1][1])
        c = circle3(P, A, T)
        pts['a' + nm] = (*A, 's')
        pts['p' + nm] = (*T, 'N')
        links += [(b, 'a' + nm, c), ('a' + nm, 'p' + nm, c)]
    pts.update({'p2a': (mid / 2, 0.0, 's'), 'p2N': (mid, 0.0, 'N')})
    links += [('b2', 'p2a', None), ('p2a', 'p2N', None)]
    return F(C, pts, links)


CELLS[41]['crown'] = crown4(pt(61.0, -28.3), 1753)


# 50 with 27, 57, 73, 102 and Water 26, 42, 103: the hook on the Water spoke node 1526 was drawn straight, a zigzag
# stick down beside the border hex. Drawn bow out: one smooth curve along the hex's side. 4 -> 4.
fill_rows(CELLS[50], [('d hook 1526', 1526, 'Hook', 'bow out', 1.2, -149, 0, False)])


# 90 / 95 with 9, 10, 20, 34, 73, 77: the two crooks on the axis node 1493 read as one crossguard over the four blades,
# but as a bent bar of straight sticks. Drawn bow out: the guard's quillons curl at their ends. Re-aiming them to clear
# the blade and sabre tips (1.23 and 1.3) puts them 0.97 from the sabres, so the aim stays. 3 -> 3 each.
fill_rows(CELLS[90], [('crook', 1493, 'Crook', 'bow out', 1.2, -90, 0, True)])
CELLS[95].update(mirror_pieces({'crook': CELLS[90]['crook']}, THEME))


# 58 / 57 with 9, 41, 77, 100 / 10, 50, 73, 102 and the rim: cell 58 held four closed loops in a row down its -theta
# side (100's ring 1752 above them, then the tadpole 1753, the sawblade, the kite on 1719 1.23 from a saw tooth, the
# land's closest notables). The kite gives way to cell 57's open hairpin curl on 1729, mirrored (57 mirrors 58 across
# the axis), so the pair now match there too. 5 -> 5.
del CELLS[58]['d_tadpole_1719']
CELLS[58].update(mirror_pieces({'d hairpin 1719': CELLS[57]['d_hairpin_1729']}, THEME))


# 102 / 100 with 50, 57 / 41, 58, the rim and Water 42, 103 / Earth 48, 106, the border combos 913 / 912: the Water
# border round cell 102 is a field of closed loops (102's rings 1761 and 1976, 57's tadpole 1763, the rim's kite,
# Water's teardrop, kite and crescent moon, the dew drops of 913). Cell 102's straight pentagon ring on 1761 opens into a
# horseshoe (Ring, horseshoe (open)), and its crook on 1763, a bent stick from the junction, is drawn bow out (a curl;
# the other hand ran on into the whip as one wave, a crescent lay along the spoke). 5 -> 5, 3 -> 3.
fill_rows(CELLS[102], [('d ring 1761', 1761, 'Ring', 'horseshoe (open)', 1.2, -185, 0, False)])
fill_rows(CELLS[102], [('d crook 1763', 1763, 'Crook', 'bow out', 1.2, 136, 0, False)])


# ---------------------------------------------------------------------------------------------------------------------
# Review pass w4 (2026-11-19): regions of two rings of cells, judged for composition.
# Inner band (4 with 61, 68, 113, 116 / 20, 27, 30, 34): 68's hook on 1716 and 20's crescent on the axis node 1491 were
# two near-equal curls stacked beside the axis, both bowing the same way. The crescent becomes a wave (Zigzag wave, a
# wavy kris blade) from 1491 into the slot between the axis and the coins; the hook stays and answers 61's diamond
# pendant across the axis. 4 -> 5.
del CELLS[20]['d_crescent_1491']
fill_rows(CELLS[20], [('d wave 1491', 1491, 'Zigzag', 'wave', 1.0, 140, 0, True)])
# Outer band right (73 with 10, 20, 27, 50, 57, 95): cell 10's quiet patch between the meteor hammer's chain and the
# shield, above the outer ring node 1734 (1735, 1731 and 1766 tried in w2/w3). A hook rises from 1734 and curls under
# the shield, an inner echo of the hammer chain's arc. +4 nodes, +1 small.
fill_rows(CELLS[10], [('d hook 1734', 1734, 'Hook', 'bow out', 1.0, 40, 0, False)])
# Middle band left (30 with 34, 41, 61, 77, 113 and Earth 23, 48, 106): 41's kite on 1522 was a small polygon loop under
# the Earth-Metal border hex (a wall cluster), with Earth 48's square keep beyond it, and the top of a run of four loops
# down the -theta side (kite, 100's ring 1752, 58's tadpole 1753, the sawblade). It opens into a hook (Hook bow out)
# leaving 1522 under the hex and curling over towards the crescent on 1752 (2.0 clear; spur pair, wave and the other
# hand came 1.25-1.46 from the hex's or the crescent's notables). 5 -> 4.
del CELLS[41]['d_tadpole_1522']
fill_rows(CELLS[41], [('d hook 1522', 1522, 'Hook', 'bow out', 1.2, 49, 0, False)])
# Outer band left (77 with 9, 30, 34, 41, 58, 90 / 100 and the rim): the diagonal of loops 100's ring 1752 -> 58's
# tadpole 1753 -> the sawblade (w3 open point). 58's tadpole stays (with 41's crown up from the same node it reads as one
# sceptre); 100's ring opens into a horseshoe turned so its gap faces outward, a small open bell (Ring, horseshoe
# (open), ang 150; at 165 the gap barely shows), answering 102's horseshoe on 1761 across the axis. 5 -> 5.
del CELLS[100]['d_ring_1752']
fill_rows(CELLS[100], [('d ring 1752', 1752, 'Ring', 'horseshoe (open)', 1.2, 150, 0, True)])


# Hub cell 81 belongs to Chaos (swirls into the centre, user 2026-11-18): drawn in design/dao-do/cells/chaos.py.
CELLS[81] = {}
