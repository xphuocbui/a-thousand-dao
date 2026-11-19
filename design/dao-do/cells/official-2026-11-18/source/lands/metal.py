"""Metal (axis 144): swords and the sword formation (kiếm trận). Every cell placed by hand, 2026-11-18 (Metal fork).

Figure helper F(): a figure is drawn round a centre C in local units, u = towards the tree centre, v = towards +theta,
turned `rot` degrees (from inward towards +theta) and mirrored with `flip`. Every number below is chosen by hand.
Combos across cells:
  A "sword formation" junction: four guarded blades from road node 1494 (axis x ring 64.3) into cells 90, 95, 9, 10.
  B "split crescent": two crescent blades facing across the spoke at road node 1969 (cells 77 | 90), mirrored at 1970
    (cells 73 | 95), reading as one ring threaded on the spoke.
Consolidation pass 2026-11-18 (consolidate-brief.md): groups of small catalogue pieces merged into medium and big orbit
figures (helpers G() and the figure functions after it); each cell's block says what replaced what.
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
CELLS[30].update({'bell': hung_bell(1705), 'moon': moon(1738, ang=30, R1=1.8), 'fan': blade_fan(1739)})


# Cell 27 (theta 18..36): centre figure an arrowhead flying inward, a long straight shaft and a notable tip with two
# barbs; catalogue pieces round it.
def arrow(rid):
    pts = {'s1': (1.1, 0.0, 's'), 's2': (2.2, 0.0, 's'), 's3': (3.3, 0.0, 's'), 'tip': (4.5, 0.0, 'N'),
           'bL': (3.7, -0.95, 'N'), 'bR': (3.7, 0.95, 'N')}
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
            [(f'v{a}', f't{a}', None) for a in (330, 90, 210)]
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
# crossguard of two crooks on the road node below it and a pair of diamonds lower down; pieces hang outward from the
# ring road nodes; the keystones sit alone just past the two hook ends.
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
    ('hook',       1725, 'Hook', 'straight', 1.2, 180, 0, True),
    ('crook',      1735, 'Crook', 'straight', 1.2, 180, 0, False),
    ('crescent',   1717, 'Crescent', 'straight', 1.2, 180, 0, False),
    ('kite',       1728, 'Tadpole', 'kite', 1.2, 180, 0, False),
])
# consolidation: fork 1720 + crook 1722 -> a gong hung outward from 1721, mirrored at 1731 in place of the spur 1730.
CELLS[903]['gong L'] = gong(1721, ang=180)
CELLS[903]['gong R'] = mirror_pieces({'g': CELLS[903]['gong L']}, THEME)['g']


# ---------------------------------------------------------------------------------------------------------------------
# Density pass (target about 0.25-0.32 nodes per unit², rules 3.10 C6): catalogue pieces on road nodes that carried
# nothing, families in an order I chose per cell, the direction towards the cell centre or 25 degrees either side, the
# first of my candidates that passed the checks with everything else (out/metal-dense.py); then reviewed by eye.
fill_rows(CELLS[20], [
    ('d crook 1491', 1491, 'Crook', 'straight', 1.2, 128, 0, False),
    ('d crook 1492', 1492, 'Crook', 'straight', 1.2, 47, 0, True),
])
fill_rows(CELLS[34], [
    ('d arch 1709', 1709, 'Arch', 'straight', 1.2, -170, 0, False),
    ('d arch 1743', 1743, 'Arch', 'straight', 1.2, -12, 0, False),
])
fill_rows(CELLS[30], [
    ('d spur pair 1520', 1520, 'Spur pair', 'straight', 1.2, 127, 0, False),
    ('d crook 253', 253, 'Crook', 'straight', 1.2, 101, 0, True),
    ('d spur pair 1521', 1521, 'Spur pair', 'straight', 1.2, 49, 0, False),
])
fill_rows(CELLS[27], [
    ('d arch 1744', 1744, 'Arch', 'straight', 1.2, -11, 0, False),
])
fill_rows(CELLS[41], [
    ('d crook 1521', 1521, 'Crook', 'straight', 1.2, 127, 0, False),
    ('d tadpole 1522', 1522, 'Tadpole', 'kite', 1.2, 49, 0, False),
    ('d diamond 1752', 1752, 'Diamond', 'cusped', 1.2, -12, 0, False),
    ('d hairpin 1754', 1754, 'Hairpin', 'straight', 1.2, -51, 0, True),
])
fill_rows(CELLS[50], [
    ('d hook 1526', 1526, 'Hook', 'straight', 1.2, -149, 0, False),
    ('d crook 1527', 1527, 'Crook', 'straight', 1.2, -51, 0, False),
])
fill_rows(CELLS[77], [
    ('d diamond 1741', 1741, 'Diamond', 'cusped', 1.2, -128, 0, False),
])
fill_rows(CELLS[73], [
    ('d hairpin 1748', 1748, 'Hairpin', 'straight', 1.2, 128, 0, True),
])
fill_rows(CELLS[58], [
    ('d tadpole 1753', 1753, 'Tadpole', 'kite', 1.2, 125, 0, False),
    ('d crook 1718', 1718, 'Crook', 'straight', 1.2, 51, 0, False),
    ('d tadpole 1719', 1719, 'Tadpole', 'kite', 1.2, 45, 0, False),
])
fill_rows(CELLS[57], [
    ('d hairpin 1763', 1763, 'Hairpin', 'straight', 1.2, -125, 0, True),
    ('d hairpin 1729', 1729, 'Hairpin', 'straight', 1.2, -45, 0, False),
])
fill_rows(CELLS[100], [
    ('d hairpin 1522', 1522, 'Hairpin', 'straight', 1.2, 136, 0, False),
    ('d crook 1751', 1751, 'Crook', 'straight', 1.2, 160, 0, False),
    ('d crook 1753', 1753, 'Crook', 'straight', 1.2, -136, 0, False),
])
fill_rows(CELLS[102], [
    ('d crook 1763', 1763, 'Crook', 'straight', 1.2, 136, 0, False),
    ('d ring 1761', 1761, 'Ring', 'straight', 1.2, -185, 0, False),
    ('d ring 1976', 1976, 'Ring', 'straight', 1.2, 89, 0, False),
    ('d hook 1728', 1728, 'Hook', 'straight', 1.2, 44, 0, False),
])
fill_rows(CELLS[9], [
    ('d hairpin 1725', 1725, 'Hairpin', 'straight', 1.2, -35, 0, False),
])
fill_rows(CELLS[113], [
    ('d diamond 1518', 1518, 'Diamond', 'cusped', 1.2, 134, 0, False),
    ('d diamond 1691', 1691, 'Diamond', 'cusped', 1.2, 142, 0, False),
])
fill_rows(CELLS[116], [
    ('d hairpin 1699', 1699, 'Hairpin', 'straight', 1.2, 134, 0, False),
])
