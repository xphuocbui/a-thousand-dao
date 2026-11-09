"""Metal land (Kim), the pilot region of the Kinh Mạch Đồ rework (2026-11-08), version 6: drawn by hand.

Drawn with the pens in regions/pens.py; nothing is generated. The layout follows the original Kinh Mạch Đồ: roads run
out from the start like spokes and around the tree like rings, and the clusters sit in the spaces between them. The
grammar is PoE's, as measured in design/research/passive-tree-study.md (findings 23-29 and the cluster shape audit):
- the start opens into a twin-hub web; each band holds a group of constellations that reach each other;
- a road joins a cluster at the cluster's nearest node; a cluster may hold several notables, with small nodes before
  each;
- road nodes are few and carry two or three clusters each, one of them big; small clusters are PoE 2's figures
  (kites, bends, zigzags, crosses, stars, hearts, hourglasses, eyes, swords), not crescents;
- clusters grow toward the rim.
v6 (after the user's review of v5: "still not packed tightly enough"; road nodes should carry several clusters) puts
fewer nodes on every road and dresses each one by hand with two or three figures.
Coordinates are (u, v): v outward along Metal's axis, u across, + toward Water. One unit is one ordinary link.
"""
import importlib.util
import math
import os

_sp = importlib.util.spec_from_file_location("pens", os.path.join(os.path.dirname(os.path.abspath(__file__)), "pens.py"))
_pens = importlib.util.module_from_spec(_sp)
_sp.loader.exec_module(_pens)
rad, circ, place, walk = _pens.rad, _pens.circ, _pens.place, _pens.walk
arcp, lolli, fork, diam, leaf, span = _pens.arcp, _pens.lolli, _pens.fork, _pens.diam, _pens.leaf, _pens.span
pict, dress, out_angle, nearest, toward, place_in = _pens.pict, _pens.dress, _pens.out_angle, _pens.nearest, _pens.toward, _pens.place_in

_sc = importlib.util.spec_from_file_location("common", os.path.join(os.path.dirname(os.path.abspath(__file__)), "common.py"))
common = importlib.util.module_from_spec(_sc)
_sc.loader.exec_module(common)
_sl = importlib.util.spec_from_file_location("landkit", os.path.join(os.path.dirname(os.path.abspath(__file__)), "landkit.py"))
landkit = importlib.util.module_from_spec(_sl)
_sl.loader.exec_module(landkit)
landkit.use(_pens, common)

TITLE = "Metal Land (Kim)"
START_KEY = "metal"
ROAD_KINDS = common.ROAD_KINDS
START_NAME = "Metal start (Kim)"
AXIS, HALF_ANGLE, RIM = 144, 23, 76
ROAD_JITTER = 0.0     # the approved pilot keeps its even road spacing
HALO_EXTRA = 0        # and its hidden band as drawn
NAME_ROTATE = False   # and its names
MIN_SPACING = 0.6
RIM_WAVE = []   # bays in the rim (judge round 6: vary the overhang)
ROAD_MOD = [("can_cot", "", 1.0)]   # proposal: Metal's roads give root bone, as PoE's travel nodes give attributes
ROADS = {}                          # named road-node lists, kept for the dressing pass


def build(T):
    P = T.P
    S = T.node((0, 17), "S")

    # ---- the ring road through the start, to the neighbouring starts ------------------------------------------
    jl, jr = T.junction(P(17, -20)), T.junction(P(17, 20))
    ringL = T.road([S, jl], step=2.8)
    ringR = T.road([S, jr], step=2.8)
    T.exit(jl, P(17, -25.5), "Ring road to the Earth start", "12–15 points to the Earth start.", port="r0-")
    T.exit(jr, P(17, 25.5), "Ring road to the Water start", "12–15 points to the Water start.", port="r0+")

    # ---- the Gate of Metal: PoE 2's twin-hub start web --------------------------------------------------------
    T.cluster("Gate of Metal", "twin-hub web", mastery=(0, 23.7))
    hubL = T.node((-4.3, 22.4), "N", "sword", name="Sword Heart (Kiếm Tâm)")
    hubR = T.node((4.3, 22.4), "N", "refining", name="Furnace Hand (Lô Thủ)")
    T.chain(S, hubL, "ssss", "sword", bend=0.55)
    T.chain(S, hubR, "ssss", "refining", bend=-0.55)
    c = (0, 21.63)
    dome = T.run(hubL, circ(c, 4.37, [-53, -27, 0, 27, 53]), "ssNss", "metal", names=[None, None, "Autumn Killing Qi (Thu Sát Khí)"], centre=c)
    T.link(dome[-1], hubR, centre=c)
    c2 = (0, 28.3)
    low = T.run(hubL, [(-2.15, 21.33), (0, 21.0), (2.15, 21.33)], "sNs", "health", names=[None, "Vital Qi (Sinh Khí)"], centre=c2)
    T.link(low[-1], hubR, centre=c2)
    T.end()
    ntop = dome[2]
    # under the start: a cradle between the two ring-road nodes, with Called Blow (the near keystone) below it
    T.cluster("Cradle", "cradle")
    a1 = T.run(ringL[1], [(-2.95, 15.45), (-2.3, 14.35)], "ss", "lifespan")
    n1 = T.node((-1.25, 13.6), "N", "lifespan", name="Long Years (Trường Thọ)")
    T.link(a1[-1], n1)
    a2 = T.run(ringR[1], [(2.95, 15.45), (2.3, 14.35)], "ss", "heart")
    n2 = T.node((1.25, 13.6), "N", "heart", name="Still Heart (Tĩnh Tâm)")
    T.link(a2[-1], n2)
    mid = T.node((0, 13.2), "s", "health")
    T.link(n1, mid, bend=-0.15)
    T.link(mid, n2, bend=-0.15)
    T.end()
    T.cluster("Called Blow spur", "keystone spur")
    sp = T.run(mid, [(0, 12.0)], "s", "keystone")
    T.link(sp[-1], T.node((0, 10.7), "K", key="CALLED"))
    T.end()

    # ---- roads out of the web ------------------------------------------------------------------------------------
    JW1, JL1, JC1, JR1, JE1 = (T.junction(P(30.5, a)) for a in (-21, -14, 0, 13, 21))
    jsw = T.junction((-5.4, 23.65))
    jfg = T.junction((5.4, 23.65))
    swordRd = T.road([hubL, jsw, JL1], step=4.0)
    forgeRd = T.road([hubR, jfg, JR1], step=4.0)
    centreRd = T.road([ntop, JC1], step=2.4)
    ring1 = T.road([JW1, JL1, JC1, JR1, JE1], step=4.5)
    T.exit(JW1, P(30.5, -25), "To the Earth–Metal blend zone", "Earth and Metal themes mix beyond here.", port="r1-")
    T.exit(JE1, P(30.5, 25), "To the Metal–Water blend zone", "Metal and Water themes mix beyond here.", port="r1+")

    # ---- band 1 (r 31-44): Sword Bridge, Metal Wheel, Furnace Gourd -------------------------------------------
    JW2, JM2L, JC2, JM2R, JE2 = (T.junction(P(44.5, a)) for a in (-21, -13, 0, 8, 21))
    T.cluster("Sword Bridge", "three-lane bridge")
    A = T.node(P(33.4, -14.5), "N", "sword", name="Sword Qi Crosses (Kiếm Khí Tung Hoành)")
    B = T.node(P(41.4, -14), "N", "sword", name="Unsheathed (Xuất Vỏ)")
    lane_out = T.chain(A, B, "ssNss", "body", bend=2.3, names=[None, None, "Cast Iron Frame (Thiết Khung)"])
    lane_mid = T.chain(A, B, "ssNss", "crit", names=[None, None, "Heavy Blow (Trọng Kích)"])
    lane_in = T.chain(A, B, "ssNss", "sword", bend=-2.3, names=[None, None, "Thousand Edges (Thiên Phong)"])
    T.end()
    T.road([JL1, A], step=3.0)
    T.road([B, JM2L], step=3.0)
    wc, wr = (0, 37.0), 3.0
    T.cluster("Metal Wheel", "great wheel", mastery=wc)
    angs = [180 + 30 * j for j in range(12)]
    roles = {300: "N", 60: "N"}
    wheel = [T.node(p, roles.get(a % 360, "s"), "metal") for p, a in zip(circ(wc, wr, angs), angs)]
    for x, y in zip(wheel, wheel[1:] + wheel[:1]):
        T.link(x, y, centre=wc)
    wbot, wleft, wtop, wright = wheel[0], wheel[3], wheel[6], wheel[9]
    conn = T.node((-4.95, 36.9), "s", "metal")
    T.link(conn, wleft)
    T.end()
    T.attach(conn, lane_in)
    T.road([JC1, wbot], step=2.4)
    cU = T.road([wtop, JC2], step=2.4)
    L = place(P(35.2, 11), 11)
    T.cluster("Furnace Gourd", "gourd", mastery=L(0, 2.0))
    F = T.node(L(0, 0), "N", "refining", name="Tempered Ore (Tôi Khoáng)")
    low_r = {288: ("N", "refining", "Spirit Etching (Khắc Linh)"), 72: ("N", "ward", "Steady Ward (Ổn Hộ)")}
    lower = [F]
    for a_ in [180 + 36 * j for j in range(1, 10)]:
        a_ %= 360
        ro, th_, nm = low_r.get(a_, ("s", "refining", None))
        lower.append(T.node(L(2.0 * math.sin(rad(a_)), 2.0 + 2.0 * math.cos(rad(a_))), ro, th_, name=nm))
    c1 = L(0, 2.0)
    for x, y in zip(lower, lower[1:] + lower[:1]):
        T.link(x, y, centre=c1)
    waist = lower[5]
    c2 = L(0, 5.6)
    upper = [waist]
    for a_ in [180 + 45 * j for j in range(1, 8)]:
        a_ %= 360
        ro = "N" if a_ == 0 else "s"
        upper.append(T.node(L(1.6 * math.sin(rad(a_)), 5.6 + 1.6 * math.cos(rad(a_))), ro, "refining" if ro == "N" else "sense",
                            name="Life-Bound Treasure (Bản Mệnh Pháp Bảo)" if ro == "N" else None))
    for x, y in zip(upper, upper[1:] + upper[:1]):
        T.link(x, y, centre=c2)
    mouth = upper[4]
    T.end()
    T.cluster("Metal Wheel east link", "connector")
    cE = T.node(((T.pt(wright)[0] + T.pt(lower[2])[0]) / 2, (T.pt(wright)[1] + T.pt(lower[2])[1]) / 2), "s", "metal")
    T.end()
    T.nodes[cE]["cluster"] = T.nodes[wright]["cluster"]
    T.clusters[T.nodes[wright]["cluster"]]["nodes"].append(cE)
    T.link(wright, cE)
    T.attach(cE, lower)
    T.road([JR1, F], step=5.0)
    T.road([mouth, JM2R], step=3.0)
    wSp = T.road([JW1, JW2], step=4.7)
    eSp = T.road([JE1, JE2], step=4.7)
    ring2 = T.road([JW2, JM2L, JC2, JM2R, JE2], step=4.7)
    T.exit(JW2, P(44.5, -25), "To the Earth–Metal blend zone", "Earth and Metal themes mix beyond here.", port="r2-")
    T.exit(JE2, P(44.5, 25), "To the Metal–Water blend zone", "Metal and Water themes mix beyond here.", port="r2+")
    T.attach(nearest(T, wSp[1:-1], lane_out[2]), lane_out)     # the edge road touches the bridge's outer lane
    eg = nearest(T, eSp[1:-1], lower[7])
    T.cluster("Gourd east link", "connector")
    cG = T.node(((T.pt(eg)[0] + T.pt(lower[7])[0]) / 2, (T.pt(eg)[1] + T.pt(lower[7])[1]) / 2), "s", "refining")
    T.end()
    T.link(eg, cG)
    T.attach(cG, lower)

    # ---- band 2 (r 45-57): Sword Crown, Metal Lattice, Forge Twin Zigzag, joined to each other -------------------
    k_ = 1.35
    L = place(P(47.4, -13), -4)
    Q = lambda x, y: L(x * k_, y * k_)
    T.cluster("Sword Crown", "crown")
    cE_ = T.node(Q(0, 0), "s", "sword")
    cF = T.node(Q(0, 1.3), "s", "sword")
    l1 = T.node(Q(-1.3, 2.1), "s", "sword")
    NL = T.node(Q(-2.3, 3.4), "N", "sword", name="One Cut (Nhất Trảm)")
    m1 = T.node(Q(0, 2.6), "s", "sword")
    NM = T.node(Q(0, 3.95), "N", "sword", name="Severing Light (Đoạn Quang)")
    r1 = T.node(Q(1.3, 2.1), "s", "crit")
    NR = T.node(Q(2.3, 3.4), "N", "crit", name="Fatal Point (Tử Huyệt)")
    rimL = T.node(Q(-1.15, 3.45), "s", "sword")
    rimR = T.node(Q(1.15, 3.45), "s", "crit")
    for a_, b_ in ((cE_, cF), (cF, l1), (l1, NL), (cF, m1), (m1, NM), (cF, r1), (r1, NR)):
        T.link(a_, b_)
    for a_, b_ in ((NL, rimL), (rimL, NM), (NM, rimR), (rimR, NR)):
        T.link(a_, b_, bend=-0.15)
    T.end()
    T.link(JM2L, cE_)
    L = place((0, 49.0), 0)
    T.cluster("Metal Lattice", "twin-hub lattice")
    H1 = T.node(L(-3.2, 0), "N", "metal", name="Piercing Gold (Xuyên Kim)")
    H2 = T.node(L(3.2, 0), "N", "metal", name="Metal Bones (Kim Cốt)")
    lens_lo = T.chain(H1, H2, "sss", "metal", bend=-1.3)
    lens_hi = T.chain(H1, H2, "sNs", "metal", bend=1.4, names=[None, "White Gold Edge (Bạch Kim Phong)"])
    T.end()
    leafNW = leaf(T, H1, -35, "crit", length=3.6, width=0.95, names=["Heavy Blow (Trọng Kích)"], name="Lattice leaf north-west")
    leafNE = leaf(T, H2, 35, "ward", length=3.6, width=0.95, names=["Bright Shell (Quang Xác)"], name="Lattice leaf north-east")
    leafSW = leaf(T, H1, -142, "health", length=3.0, width=0.85, names=["Vital Qi (Sinh Khí)"], name="Lattice leaf south-west")
    leafSE = leaf(T, H2, 142, "body", length=3.0, width=0.85, names=["Hard as Iron (Cương Ngạnh)"], name="Lattice leaf south-east")
    T.link(JC2, lens_lo[1])
    lat_top = lens_hi[1]
    kz = 1.2
    L0 = place(P(47.7, 12.3), 12.3)
    L = lambda x, y: L0(x * kz, y * kz)
    T.cluster("Forge Twin Zigzag", "shared zigzag")
    xs = [-3.3, -2.2, -1.1, 0, 1.1, 2.2, 3.3]
    ys = [0.6, -0.2, 0.6, -0.2, 0.6, -0.2, 0.6]
    zn = ["Spirit Etching (Khắc Linh)", None, None, None, None, None, "Refined Edge (Tinh Phong)"]
    zig = [T.node(L(x, y), r_, "refining", name=n_) for x, y, r_, n_ in zip(xs, ys, "NsssssN", zn)]
    for x, y in zip(zig, zig[1:]):
        T.link(x, y)
    rc = L(0, 2.65)
    ring_ = [T.node(L(1.15 * math.sin(rad(a_)), 2.65 + 1.15 * math.cos(rad(a_))), "N" if a_ == 0 else "s", "sense" if a_ == 0 else "linh",
                    name="Sea of Consciousness (Thức Hải)" if a_ == 0 else None) for a_ in (216, 288, 0, 72, 144)]
    for x, y in zip(ring_, ring_[1:] + ring_[:1]):
        T.link(x, y, centre=rc)
    T.link(zig[2], ring_[0]); T.link(zig[4], ring_[4])
    T.clusters[T.cur]["mastery"] = rc
    T.end()
    T.link(nearest(T, ring2, zig[3]), zig[3])
    span(T, NR, leafNW[0], "ss", "crit", bend=-0.3, name="Crown-Lattice span")
    T.cluster("Lattice-Zigzag link", "connector")
    pa, pb = T.pt(leafSE[0]), T.pt(zig[0])
    mz = T.node(((pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2), "s", "refining")
    T.end()
    T.attach(mz, leafSE)
    T.attach(mz, zig)
    JW3, JN3, JC3, JS3, JE3 = (T.junction(P(58.5, a)) for a in (-20, -10, 0, 10, 20))
    ws2 = T.road([JW2, JW3], step=4.7)
    es2 = T.road([JE2, JE3], step=4.7)
    wf = nearest(T, ws2[1:-1], NL)
    T.cluster("Crown west foot", "connector")
    cw = T.node(((T.pt(wf)[0] + T.pt(NL)[0]) / 2, (T.pt(wf)[1] + T.pt(NL)[1]) / 2), "s", "sword")
    T.end()
    T.link(wf, cw); T.attach(cw, [NL, rimL, l1])
    ef = nearest(T, es2[1:-1], zig[6])
    T.cluster("Zigzag east foot", "connector")
    ce = T.node(((T.pt(ef)[0] + T.pt(zig[6])[0]) / 2, (T.pt(ef)[1] + T.pt(zig[6])[1]) / 2), "s", "refining")
    T.end()
    T.link(ef, ce); T.attach(ce, zig)

    # ---- band 3 (r 58-67): the rim -----------------------------------------------------------------------------
    cTop = T.road([lat_top, JC3], step=3.9)
    ring3 = T.road([JW3, JN3, JC3, JS3, JE3], step=5.0)
    T.exit(JW3, P(58.5, -25), "To the Earth–Metal blend zone", "Earth and Metal themes mix beyond here.", port="r3-")
    T.exit(JE3, P(58.5, 25), "To the Metal–Water blend zone", "Metal and Water themes mix beyond here.", port="r3+")
    gI = (-10.3, 54.6)
    T.cluster("Iron Body ring", "ring", mastery=gI)
    ia = [36 * j for j in range(10)]
    iron = [T.node(circ(gI, 1.9, [a_])[0], "N" if a_ in (108, 252) else "s", "body",
                   name={108: "Iron Spine (Thiết Cốt)", 252: "Cast Iron Frame (Thiết Khung)"}.get(a_)) for a_ in ia]
    for x, y in zip(iron, iron[1:] + iron[:1]):
        T.link(x, y, centre=gI)
    T.end()
    T.link(JN3, iron[0])
    T.link(iron[5], NM)
    T.cluster("Spirit Treasure trident", "trident")
    t0 = T.run(JS3, [(10.05, 56.35), (9.95, 55.15)], "ss", "refining")
    tl = T.run(t0[-1], [(8.85, 54.45), (8.05, 53.45)], "sN", "refining", names=[None, "Life-Bound Treasure (Bản Mệnh Pháp Bảo)"])
    tr = T.run(t0[-1], [(11.05, 54.45), (11.85, 53.45)], "sN", "sense", names=[None, "Clear Eyes (Minh Mục)"])
    tm = T.run(t0[-1], [(10.25, 53.95), (10.6, 52.75)], "ss", "refining")
    T.end()
    T.attach(tm[-1], ring_)
    gC = P(59.2, -18.3)
    T.cluster("Sword Tomb", "dome", mastery=gC)
    da = [-78, -52, -26, 0, 26, 52, 78]
    dome_ = [T.node(circ(gC, 2.4, [-18.3 + a_])[0], "N" if j in (2, 4) else "s", "sword",
                    name={2: "Thousand Edges (Thiên Phong)", 4: "Sword Heart (Kiếm Tâm)"}.get(j)) for j, a_ in enumerate(da)]
    for x, y in zip(dome_, dome_[1:]):
        T.link(x, y, centre=gC)
    crest = T.run(dome_[3], [P(62.75, -18.3), P(63.95, -18.3)], "sN", "sword", names=[None, "Unsheathed (Xuất Vỏ)"])
    T.end()
    T.attach(JW3, dome_[:2])
    T.attach(nearest(T, ring3[1:3], dome_[-1]), dome_[-2:])
    T.cluster("No Ward spur", "keystone spur")
    sp = T.run(JN3, walk(T.pt(JN3), -14, 2, 6, 1.25), "ss", "body")
    T.link(sp[-1], T.node(walk(T.pt(sp[-1]), -2, 1, 0, 1.4)[0], "K", key="NOWARD"))
    T.end()
    T.cluster("Heart Demon's Blade spur", "keystone spur")
    sp = T.run(JS3, walk(T.pt(JS3), 14, 2, -6, 1.25), "ss", "heart")
    T.link(sp[-1], T.node(walk(T.pt(sp[-1]), 2, 1, 0, 1.4)[0], "K", key="HDB"))
    T.end()
    T.cluster("Metal Summit", "summit")
    e0 = T.run(JC3, [(0, 59.7)], "s", "metal")[0]
    shL = T.run(e0, [(-1.1, 60.55), (-1.7, 61.7)], "sN", "metal", names=[None, "Autumn Killing Qi (Thu Sát Khí)"])
    shR = T.run(e0, [(1.1, 60.55), (1.7, 61.7)], "sN", "metal", names=[None, "White Gold Edge (Bạch Kim Phong)"])
    upL = T.run(shL[-1], [(-1.0, 62.75)], "s", "metal")[0]
    upR = T.run(shR[-1], [(1.0, 62.75)], "s", "metal")[0]
    apex = T.node((0, 63.45), "N", "metal", name="Metal Bones (Kim Cốt)")
    T.link(upL, apex); T.link(upR, apex)
    T.end()
    # the summit bypass (open point 2, 2026-11-08 night): a short road on the summit's Water side
    bp = [T.junction((2.75, 61.2)), T.junction((3.0, 64.7)), T.junction((2.0, 67.9))]
    T.road([JC3] + bp, step=4.0)
    ROADS["bypass"] = bp
    T.cluster("Forge Anvil", "rectangle")
    angs_ = (12.3, 14.0, 15.7, 17.4, 19.1)   # set in from the Water edge, leaving room for the edge highway
    inner = [T.node(P(61.0, a_), "s", "refining") for a_ in angs_]
    outer = []
    for j, a_ in enumerate(angs_):
        nm = {1: "Furnace Hand (Lô Thủ)", 3: "Tempered Ore (Tôi Khoáng)"}.get(j)
        outer.append(T.node(P(63.4, a_), "N" if nm else "s", "refining", name=nm))
    for row in (inner, outer):
        for x, y in zip(row, row[1:]):
            T.link(x, y, centre=(0.0, 0.0))
    for j in (0, 2, 4):
        T.link(inner[j], outer[j])
    T.end()
    T.attach(nearest(T, ring3[-3:-1], inner[1]), inner)
    T.attach(JE3, inner)

    # ---- the fourth ring (r 70) and band 4 ---------------------------------------------------------------------
    JW4, JN4, JC4, JS4, JE4 = (T.junction(P(70, a)) for a in (-22, -11, 0, 11, 21))
    Jx = T.junction(P(61, -22.3))
    ws3 = T.road([JW3, Jx, JW4], step=4.5)
    T.attach(Jx, dome_)
    cTop2 = T.road([apex, JC4], step=3.3)
    T.link(ROADS["bypass"][-1], JC4, kind="highway")
    eTop = T.road([JE3, JE4], step=4.2)     # the Water-edge highway: the anvil can be skipped
    T.attach(nearest(T, eTop[1:-1], outer[4]), outer)
    ring4 = T.road([JW4, JN4, JC4, JS4, JE4], step=5.0)
    T.exit(JW4, P(70, -24.5), "To the Earth–Metal blend zone", "Earth and Metal themes mix beyond here.", port="r4-")
    T.exit(JE4, P(72, 26), "Ring road on to the lightning road", "Ring 4 meets the lightning road from Thunder in the Metal–Water blend zone.", port="r4+")
    T.cluster("Blade Pinwheel", "pinwheel", mastery=(-7.6, 65.4))
    hub = T.node((-7.6, 65.4), "s", "sword")
    arms = []
    for a0, th_, nm in ((20, "crit", "Fatal Point (Tử Huyệt)"), (140, "sword", "One Cut (Nhất Trảm)"), (260, "sword", "Edge Follows Will (Kiếm Tùy Ý)")):
        pts = walk(T.pt(hub), a0, 3, -48, 1.15)
        arms.append(T.run(hub, pts, "ssN", th_, names=[None, None, nm]))
    T.end()
    allarm = [i for arm in arms for i in arm]
    T.attach(min(ring4, key=lambda r: min(math.dist(T.pt(r), T.pt(i)) for i in allarm)), allarm)
    T.cluster("Furnace Square", "square", mastery=(7.6, 65.4))
    sq_pts = [(-1.4, 1.4), (0, 1.4), (1.4, 1.4), (1.4, 0), (1.4, -1.4), (0, -1.4), (-1.4, -1.4), (-1.4, 0)]
    sq_roles = {6: ("N", "refining", "Ore Sense (Thức Khoáng)"), 4: ("N", "ward", "Steady Ward (Ổn Hộ)")}
    sq = []
    for j, (x, y) in enumerate(sq_pts):
        ro, th_, nm = sq_roles.get(j, ("s", "refining", None))
        sq.append(T.node((7.6 + x, 65.4 + y), ro, th_, name=nm))
    for x, y in zip(sq, sq[1:] + sq[:1]):
        T.link(x, y)
    T.end()
    T.attach(min(ring4, key=lambda r: min(math.dist(T.pt(r), T.pt(i)) for i in sq)), sq)
    pict(T, JN4, -11, "sword", "sword", k=1.2, roles="ssNsssN", names=["Unsheathed (Xuất Vỏ)", "Sword Heart (Kiếm Tâm)"], name="Sword Peak")
    lolli(T, JS4, 11, "refining", k=6, r=1.1, notables=(2, 4), names=["Furnace Hand (Lô Thủ)", "Spirit Etching (Khắc Linh)"], name="Furnace Peak")
    lolli(T, JC4, 0, "metal", k=7, r=1.3, notables=(3,), stem=2, names=["Autumn Killing Qi (Thu Sát Khí)"], name="Metal Apex")

    ROADS.update(ringL=ringL, ringR=ringR, swordRd=swordRd, forgeRd=forgeRd, centreRd=centreRd, ring1=ring1, wSp=wSp, eSp=eSp,
                 ring2=ring2, cU=cU, ws2=ws2, es2=es2, cTop=cTop, ring3=ring3, ws3=ws3, cTop2=cTop2, eTop=eTop, ring4=ring4)
    dressing(T)
    landkit.dress_roads(T, ROADS["bypass"], {"left": "sword", "right": "refining", "elem": "metal", "elem2": "body"})
    landkit.halo(T, HALO)


def dressing(T):
    """Every road node gets its clusters here, chosen by hand: shape, theme and direction. Inner road nodes carry two
    small figures; outer ones a big figure and a small companion (PoE 2: clusters grow outward, and a small cluster
    sits beside a big one). Angles: o(i) points straight out from the tree centre, o(i, 180) straight in, o(i, 90)
    along the ring toward Water."""
    R_ = ROADS
    o = lambda i, d=0: out_angle(T, i, d)
    r1, r2, r3, r4 = R_["ring1"], R_["ring2"], R_["ring3"], R_["ring4"]
    jl, jr = R_["ringL"][2], R_["ringR"][2]
    # -- the start and its roads (inner third: small figures, two per node)
    dress(T, jl, [("V", "sense", o(jl, 180), 0.85, ["Spirit Sense (Linh Giác)"]), ("kite", "sense", o(jl, 180), 0.85, ["Spirit Sense (Linh Giác)"])],
          ("V", "crit", o(jl, -35), 0.7, ["Heavy Blow (Trọng Kích)", "Fatal Point (Tử Huyệt)"]))
    dress(T, jr, [("arrow", "insight", o(jr, 180), 0.85, ["Reading the Dao (Quan Đạo)"]), ("kite", "insight", o(jr, 180), 0.85, ["Reading the Dao (Quan Đạo)"])],
          ("hex", "ward", o(jr, 35), 0.7, ["Bright Shell (Quang Xác)"]))
    sw, fg = R_["swordRd"], R_["forgeRd"]
    dress(T, sw[1], ("lollipop", "crit", -120, 0.9, ["Fatal Point (Tử Huyệt)"]),
          [("bowtie", "health", -70, 0.75, ["Vital Qi (Sinh Khí)"]), ("kite", "health", -70, 0.75, ["Vital Qi (Sinh Khí)"])])
    dress(T, fg[1], ("wheel", "linh", 120, 0.8, ["Deep Dantian (Thâm Đan)", "Full Sea of Qi (Khí Hải)"]),
          [("lollipop", "body", 70, 0.75, ["Gold Skin (Kim Bì)"]), ("kite", "body", 70, 0.75, ["Gold Skin (Kim Bì)"])])
    dress(T, sw[2], ("hourglass", "lifespan", -95, 0.8, ["Long Years (Trường Thọ)", "Late Autumn (Thu Muộn)"]),
          [("spoked", "heart", -150, 0.75, ["Still Heart (Tĩnh Tâm)"], {"mirror": True}), ("kite", "heart", -150, 0.75, ["Still Heart (Tĩnh Tâm)"], {"mirror": True}), ("kite", "heart", -35, 0.75, ["Still Heart (Tĩnh Tâm)"])])
    dress(T, fg[2], [("tristar", "heart", 95, 0.75, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]), ("heart", "heart", 95, 0.75, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"])],
          [("cup", "lifespan", 150, 0.75, ["Late Autumn (Thu Muộn)"]), ("kite", "lifespan", 150, 0.75, ["Late Autumn (Thu Muộn)"]), ("kite", "lifespan", 35, 0.75, ["Late Autumn (Thu Muộn)"])])
    c = R_["centreRd"][1]
    dress(T, c, [("anchor", "insight", -100, 0.8, ["Sudden Insight (Đốn Ngộ)"], {"mirror": True}), ("kite", "insight", -100, 0.8, ["Sudden Insight (Đốn Ngộ)"], {"mirror": True})],
          ("hex", "ward", 100, 0.75, ["Layered Guard (Trùng Hộ)"]))
    # -- the first ring
    dress(T, r1[0], [("window", "health", o(r1[0], 180), 0.85, ["Enduring Body (Nhẫn Thân)"]), ("kite", "health", o(r1[0], 180), 0.85, ["Enduring Body (Nhẫn Thân)"]), ("kite", "health", o(r1[0], 120), 0.75, ["Enduring Body (Nhẫn Thân)"])],
          ("tristar", "sense", o(r1[0], 40), 0.75, ["Clear Eyes (Minh Mục)", "Spirit Sense (Linh Giác)"]))
    dress(T, r1[2], ("trident", "linh", o(r1[2], 10), 0.65, ["Still Pool (Tĩnh Trì)", "Flowing Qi (Lưu Khí)", "Deep Dantian (Thâm Đan)"]),
          [("trident", "heart", o(r1[2], 160), 0.7, ["Unmoved Mind (Bất Động Tâm)"]), ("kite", "heart", o(r1[2], 160), 0.7, ["Unmoved Mind (Bất Động Tâm)"]), ("kite", "heart", o(r1[2], 130), 0.7, ["Unmoved Mind (Bất Động Tâm)"], {"mirror": True})])
    dress(T, r1[4], [("hourglass", "lifespan", o(r1[4], -10), 0.7, ["Late Autumn (Thu Muộn)", "Long Years (Trường Thọ)"]),
                     ("spoked", "lifespan", o(r1[4], -10), 0.66, ["Late Autumn (Thu Muộn)", "Long Years (Trường Thọ)"]),
                     ("hourglass", "lifespan", o(r1[4], -10), 0.7, ["Late Autumn (Thu Muộn)"]), ("kite", "lifespan", o(r1[4], -10), 0.7, ["Late Autumn (Thu Muộn)"])],
          [("eye", "crit", o(r1[4], 200), 0.7, ["Seeking the Flaw (Tầm Khuyết)"]), ("kite", "crit", o(r1[4], 200), 0.7, ["Seeking the Flaw (Tầm Khuyết)"])])
    dress(T, r1[6], [("V", "body", o(r1[6], 180), 0.85, ["Hard as Iron (Cương Ngạnh)"]), ("kite", "body", o(r1[6], 180), 0.85, ["Hard as Iron (Cương Ngạnh)"]), ("kite", "body", o(r1[6], -120), 0.75, ["Hard as Iron (Cương Ngạnh)"])],
          [("anchor", "insight", o(r1[6], -40), 0.75, ["Sudden Insight (Đốn Ngộ)", "Reading the Dao (Quan Đạo)"]), ("kite", "insight", o(r1[6], -70), 0.75, ["Sudden Insight (Đốn Ngộ)"], {"mirror": True})])
    # -- the edge roads of band 1
    w, e = R_["wSp"], R_["eSp"]
    dress(T, w[1], [("arrow", "health", o(w[1], 85), 0.85, ["Root of Life (Sinh Căn)"]), ("kite", "health", o(w[1], 85), 0.85, ["Root of Life (Sinh Căn)"]), ("kite", "health", o(w[1], 110), 0.75, ["Root of Life (Sinh Căn)"])],
          [("bowtie", "crit", o(w[1], 160), 0.7, ["Heavy Blow (Trọng Kích)"]), ("kite", "crit", o(w[1], 160), 0.7, ["Heavy Blow (Trọng Kích)"]), ("kite", "crit", o(w[1], 150), 0.7, ["Heavy Blow (Trọng Kích)"])])
    dress(T, w[2], ("hex", "sense", o(w[2], 45), 0.8, ["Clear Eyes (Minh Mục)"]))
    dress(T, e[1], [("lollipop", "crit", o(e[1], -85), 0.85, ["Seeking the Flaw (Tầm Khuyết)"]), ("kite", "crit", o(e[1], -85), 0.85, ["Seeking the Flaw (Tầm Khuyết)"])],
          [("spoked", "ward", o(e[1], -160), 0.7, ["Steady Ward (Ổn Hộ)"], {"mirror": True}), ("kite", "ward", o(e[1], -160), 0.7, ["Steady Ward (Ổn Hộ)"], {"mirror": True})])
    dress(T, e[2], ("hex", "insight", o(e[2], -45), 0.8, ["Reading the Dao (Quan Đạo)"], {"mirror": True}))
    # -- the second ring
    dress(T, r2[0], [("tristar", "heart", o(r2[0], 55), 0.8, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]), ("heart", "heart", o(r2[0], 55), 0.8, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]), ("kite", "heart", o(r2[0], 55), 0.75, ["Still Heart (Tĩnh Tâm)"])],
          [("cup", "lifespan", o(r2[0], 130), 0.75, ["Long Years (Trường Thọ)"]), ("kite", "lifespan", o(r2[0], 130), 0.75, ["Long Years (Trường Thọ)"])])
    dress(T, r2[2], ("xcross", "crit", o(r2[2], 0), 0.75, ["Heavy Blow (Trọng Kích)", "Fatal Point (Tử Huyệt)"]),
          [("eye", "sense", o(r2[2], 180), 0.7, ["Spirit Sense (Linh Giác)"]), ("kite", "sense", o(r2[2], 180), 0.7, ["Spirit Sense (Linh Giác)"])])
    cu = R_["cU"][1]
    dress(T, cu, [("anchor", "heart", -90, 0.75, ["Unmoved Mind (Bất Động Tâm)"], {"mirror": True}), ("kite", "heart", -90, 0.75, ["Unmoved Mind (Bất Động Tâm)"], {"mirror": True})],
          [("window", "ward", 90, 0.7, ["Layered Guard (Trùng Hộ)"]), ("kite", "ward", 90, 0.7, ["Layered Guard (Trùng Hộ)"])])
    dress(T, r2[4], [("hex", "ward", o(r2[4], 160), 0.7, ["Bright Shell (Quang Xác)"]), ("kite", "ward", o(r2[4], 160), 0.7, ["Bright Shell (Quang Xác)"])],
          [("trident", "linh", o(r2[4], -30), 0.7, ["Flowing Qi (Lưu Khí)"]), ("kite", "linh", o(r2[4], -30), 0.7, ["Flowing Qi (Lưu Khí)"])])
    dress(T, r2[5], ("V", "crit", o(r2[5], 165), 0.75, ["Seeking the Flaw (Tầm Khuyết)", "Heavy Blow (Trọng Kích)"]))
    dress(T, r2[6], [("hourglass", "lifespan", o(r2[6], -55), 0.8, ["Late Autumn (Thu Muộn)", "Long Years (Trường Thọ)"]), ("kite", "lifespan", o(r2[6], -100), 0.75, ["Late Autumn (Thu Muộn)"], {"mirror": True})],
          [("hourglass", "insight", o(r2[6], -130), 0.75, ["Sudden Insight (Đốn Ngộ)"]), ("kite", "insight", o(r2[6], -130), 0.75, ["Sudden Insight (Đốn Ngộ)"])])
    # -- the edge roads of band 2
    w2, e2 = R_["ws2"], R_["es2"]
    dress(T, w2[1], ("lollipop", "lifespan", o(w2[1], 60), 0.9, ["Long Years (Trường Thọ)"]),
          [("eye", "body", o(w2[1], 125), 0.7, ["Iron Spine (Thiết Cốt)"]), ("kite", "body", o(w2[1], 125), 0.7, ["Iron Spine (Thiết Cốt)"])])
    dress(T, w2[2], ("heart", "heart", o(w2[2], 70), 0.8, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]))
    dress(T, e2[1], ("lollipop", "crit", o(e2[1], -60), 0.9, ["Seeking the Flaw (Tầm Khuyết)"]))
    dress(T, e2[2], ("hourglass", "lifespan", o(e2[2], -55), 0.85, ["Late Autumn (Thu Muộn)", "Long Years (Trường Thọ)"]),
          [("V", "sense", o(e2[2], -115), 0.7, ["Clear Eyes (Minh Mục)"]), ("kite", "sense", o(e2[2], -115), 0.7, ["Clear Eyes (Minh Mục)"])])
    ct = R_["cTop"][1]
    dress(T, ct, ("eye", "sense", -95, 0.75, ["Spirit Sense (Linh Giác)"]),
          [("arrow", "linh", 95, 0.85, ["Still Pool (Tĩnh Trì)"]), ("kite", "linh", 95, 0.85, ["Still Pool (Tĩnh Trì)"])])
    # -- the third ring
    dress(T, r3[1], [("bowtie", "health", o(r3[1], 175), 0.8, ["Thick Blood (Huyết Hậu)"]), ("kite", "health", o(r3[1], 175), 0.8, ["Thick Blood (Huyết Hậu)"])],
          [("lollipop", "lifespan", o(r3[1], 5), 0.85, ["Long Years (Trường Thọ)"]), ("kite", "lifespan", o(r3[1], 5), 0.75, ["Long Years (Trường Thọ)"])])
    dress(T, r3[3], [("lollipop", "health", o(r3[3], 175), 0.85, ["Enduring Body (Nhẫn Thân)"], {"mirror": True}), ("kite", "health", o(r3[3], 175), 0.85, ["Enduring Body (Nhẫn Thân)"], {"mirror": True})],
          [("lens", "insight", o(r3[3], -5), 0.85, ["Sudden Insight (Đốn Ngộ)", "Reading the Dao (Quan Đạo)"]),
                     ("theta", "insight", o(r3[3], -5), 0.8, ["Reading the Dao (Quan Đạo)", "Sudden Insight (Đốn Ngộ)"]),
                     ("anchor", "insight", o(r3[3], -5), 0.8, ["Sudden Insight (Đốn Ngộ)", "Reading the Dao (Quan Đạo)"]),
                     ("spoked", "insight", o(r3[3], -5), 0.7, ["Sudden Insight (Đốn Ngộ)"]), ("kite", "insight", o(r3[3], -5), 0.7, ["Sudden Insight (Đốn Ngộ)"])])
    dress(T, r3[5], [("bowtie", "ward", o(r3[5], 185), 0.95, ["Layered Guard (Trùng Hộ)", "Steady Ward (Ổn Hộ)"]),
                     ("hex", "ward", o(r3[5], 185), 0.85, ["Layered Guard (Trùng Hộ)"]), ("kite", "ward", o(r3[5], 185), 0.75, ["Layered Guard (Trùng Hộ)"])],
          [("tristar", "heart", o(r3[5], 5), 0.8, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]), ("heart", "heart", o(r3[5], 5), 0.8, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"])])
    dress(T, r3[7], ("hex", "linh", o(r3[7], 185), 0.8, ["Still Pool (Tĩnh Trì)"]))
    w3 = R_["ws3"]
    dress(T, w3[2], [("cup", "heart", o(w3[2], 70), 0.8, ["Unmoved Mind (Bất Động Tâm)"]), ("kite", "heart", o(w3[2], 70), 0.8, ["Unmoved Mind (Bất Động Tâm)"])],
          [("V", "sword", o(w3[2], 15), 0.75, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"]), ("kite", "sword", o(w3[2], 40), 0.75, ["Edge Follows Will (Kiếm Tùy Ý)"])])
    c2_ = R_["cTop2"][1]
    dress(T, c2_, ("hex", "linh", -95, 0.85, ["Deep Dantian (Thâm Đan)"], {"mirror": True}),
          ("cross", "health", 95, 0.7, ["Root of Life (Sinh Căn)", "Thick Blood (Huyết Hậu)", "Vital Qi (Sinh Khí)"]))
    et = R_["eTop"][1]
    dress(T, et, [("eye", "sense", -100, 0.7, ["Spirit Sense (Linh Giác)"]), ("kite", "sense", -100, 0.7, ["Spirit Sense (Linh Giác)"])])
    # -- the fourth ring: big figures outward, small companions beside them or hanging inward
    dress(T, r4[0], ("cross", "health", o(r4[0], 40), 0.8, ["Vital Qi (Sinh Khí)", "Root of Life (Sinh Căn)", "Thick Blood (Huyết Hậu)"]))
    dress(T, r4[1], [("sword", "sword", o(r4[1], 168), 0.72, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)"], {"name": "Sword over the tomb"}),
                     ("anchor", "sword", o(r4[1], 160), 0.75, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)"]), ("kite", "sword", o(r4[1], 160), 0.75, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)"])],
          [("wheel", "sword", o(r4[1], 0), 0.95, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"]),
           ("spoked", "sword", o(r4[1], 0), 0.9, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"]),
           ("V", "sword", o(r4[1], 0), 0.9, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"])])
    dress(T, r4[2], ("xcross", "crit", o(r4[2], -5), 1.0, ["Heavy Blow (Trọng Kích)", "Fatal Point (Tử Huyệt)"]),
          [("snowflake", "body", o(r4[2], 180), 1.0, ["Iron Spine (Thiết Cốt)", "Hard as Iron (Cương Ngạnh)"]),
           ("theta", "body", o(r4[2], 180), 0.9, ["Hard as Iron (Cương Ngạnh)", "Iron Spine (Thiết Cốt)"]),
           ("totem", "body", o(r4[2], 180), 0.85, ["Hard as Iron (Cương Ngạnh)", "Iron Spine (Thiết Cốt)"])])
    dress(T, r4[3], [("concentric", "sword", o(r4[3], 180), 0.95, ["Thousand Edges (Thiên Phong)", "Sword Heart (Kiếm Tâm)"]),
                     ("theta", "sword", o(r4[3], 180), 0.9, ["Thousand Edges (Thiên Phong)", "Sword Heart (Kiếm Tâm)"]),
                     ("hex", "sword", o(r4[3], 180), 0.85, ["Thousand Edges (Thiên Phong)"])])
    dress(T, r4[4], ("hourglass", "lifespan", o(r4[4], 0), 1.15, ["Long Years (Trường Thọ)", "Late Autumn (Thu Muộn)"]),
          [("window", "ward", o(r4[4], 60), 0.7, ["Steady Ward (Ổn Hộ)"]), ("kite", "ward", o(r4[4], 60), 0.7, ["Steady Ward (Ổn Hộ)"]), ("kite", "ward", o(r4[4], -60), 0.7, ["Steady Ward (Ổn Hộ)"])])
    dress(T, r4[5], ("star", "insight", o(r4[5], 0), 1.0, ["Reading the Dao (Quan Đạo)", "Sudden Insight (Đốn Ngộ)", "Reading the Dao (Quan Đạo)"]),
          ("hex", "linh", o(r4[5], 180), 0.75, ["Flowing Qi (Lưu Khí)"]))
    dress(T, r4[7], ("heart", "heart", o(r4[7], 0), 1.05, ["Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]),
          [("trident", "health", o(r4[7], 180), 0.75, ["Enduring Body (Nhẫn Thân)"]), ("kite", "health", o(r4[7], 180), 0.75, ["Enduring Body (Nhẫn Thân)"]), ("kite", "health", o(r4[7], 60), 0.7, ["Enduring Body (Nhẫn Thân)"])])
    dress(T, r4[8], ("trident", "linh", o(r4[8], 0), 1.0, ["Full Sea of Qi (Khí Hải)", "Deep Dantian (Thâm Đan)", "Still Pool (Tĩnh Trì)"]),
          [("hourglass", "sense", o(r4[8], -60), 0.7, ["Clear Eyes (Minh Mục)"]), ("kite", "sense", o(r4[8], -60), 0.7, ["Clear Eyes (Minh Mục)"]), ("kite", "sense", o(r4[8], 60), 0.7, ["Clear Eyes (Minh Mục)"])])
    dress(T, r4[10], ("coin", "refining", o(r4[10], 0), 1.0, ["Tempered Ore (Tôi Khoáng)", "Autumn Killing Qi (Thu Sát Khí)", "White Gold Edge (Bạch Kim Phong)"],
                      {"themes": {9: "metal", 11: "metal"}}),
          ("arrow", "refining", o(r4[10], 180), 0.9, ["Life-Bound Treasure (Bản Mệnh Pháp Bảo)"]))
    dress(T, r4[11], ("hex", "ward", o(r4[11], 0), 1.0, ["Bright Shell (Quang Xác)"]))
    dress(T, r4[9], [("concentric", "refining", o(r4[9], 180), 0.95, ["Spirit Etching (Khắc Linh)", "Refined Edge (Tinh Phong)"]),
                     ("theta", "refining", o(r4[9], 180), 0.9, ["Spirit Etching (Khắc Linh)", "Refined Edge (Tinh Phong)"]),
                     ("hex", "refining", o(r4[9], 180), 0.85, ["Spirit Etching (Khắc Linh)"])])
    dress(T, r4[8], [("spoked", "sense", o(r4[8], 55), 0.8, ["Sea of Consciousness (Thức Hải)", "Clear Eyes (Minh Mục)"]), ("kite", "sense", o(r4[8], 55), 0.7, ["Clear Eyes (Minh Mục)"])])
    dress(T, r4[5], [("window", "metal", o(r4[5], -55), 0.8, ["White Gold Edge (Bạch Kim Phong)", "Piercing Gold (Xuyên Kim)"]), ("kite", "metal", o(r4[5], -55), 0.7, ["Piercing Gold (Xuyên Kim)"])])
    dress(T, r3[1], [("bowtie", "body", o(r3[1], 60), 0.85, ["Gold Skin (Kim Bì)", "Cast Iron Frame (Thiết Khung)"]), ("kite", "body", o(r3[1], 60), 0.7, ["Gold Skin (Kim Bì)"])])
    dress(T, r3[7], [("bowtie", "refining", o(r3[7], -60), 0.85, ["Ore Sense (Thức Khoáng)", "Furnace Hand (Lô Thủ)"]), ("kite", "refining", o(r3[7], -60), 0.7, ["Ore Sense (Thức Khoáng)"])])

    # ---- the open spaces the empty-space map found (tools/design/meridian_rework/holes.py): each gets a symmetric
    # figure drawn in the middle of it, joined by its nearest node to the nearest road node
    def fill(centre, figs):
        for kd, th, kk, nm, a_ in figs:
            if place_in(T, centre, kd, th, k=kk, names=nm, ang=a_ if a_ is not None else math.degrees(math.atan2(*centre))):
                return
    fill((-15.0, 62.5), [("snowflake", "body", 1.0, ["Iron Spine (Thiết Cốt)", "Hard as Iron (Cương Ngạnh)"], None),
                         ("theta", "body", 1.0, ["Hard as Iron (Cương Ngạnh)", "Iron Spine (Thiết Cốt)"], None)])
    fill((13.0, 65.0), [("concentric", "refining", 0.95, ["Spirit Etching (Khắc Linh)", "Refined Edge (Tinh Phong)"], None),
                        ("theta", "refining", 0.9, ["Spirit Etching (Khắc Linh)", "Refined Edge (Tinh Phong)"], None),
                        ("hex", "refining", 0.9, ["Spirit Etching (Khắc Linh)"], None)])
    fill((-5.0, 61.5), [("lens", "insight", 0.9, ["Sudden Insight (Đốn Ngộ)", "Reading the Dao (Quan Đạo)"], None),
                        ("theta", "insight", 0.85, ["Reading the Dao (Quan Đạo)", "Sudden Insight (Đốn Ngộ)"], None),
                        ("spoked", "insight", 0.85, ["Reading the Dao (Quan Đạo)", "Sudden Insight (Đốn Ngộ)"], None)])
    fill((-25.0, 68.5), [("wheel", "sword", 0.9, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"], None),
                         ("spoked", "sword", 0.85, ["Edge Follows Will (Kiếm Tùy Ý)", "One Cut (Nhất Trảm)"], None),
                         ("eye", "sword", 0.85, ["Edge Follows Will (Kiếm Tùy Ý)"], None), ("kite", "sword", 0.85, ["Edge Follows Will (Kiếm Tùy Ý)"], None)])
    fill((5.5, 55.5), [("bowtie", "ward", 0.9, ["Layered Guard (Trùng Hộ)", "Steady Ward (Ổn Hộ)"], 90),
                       ("hex", "ward", 0.85, ["Layered Guard (Trùng Hộ)"], None)])
    fill((8.0, 72.5), [("spoked", "sense", 0.8, ["Sea of Consciousness (Thức Hải)", "Clear Eyes (Minh Mục)"], None),
                       ("V", "sense", 0.75, ["Clear Eyes (Minh Mục)"], None), ("kite", "sense", 0.75, ["Clear Eyes (Minh Mục)"], None)])
    fill((4.0, 33.0), [("arrow", "lifespan", 0.75, ["Late Autumn (Thu Muộn)"], None), ("kite", "lifespan", 0.75, ["Late Autumn (Thu Muộn)"], None)])
    fill((-5.0, 39.5), [("bowtie", "crit", 0.75, ["Fatal Point (Tử Huyệt)"], None), ("kite", "crit", 0.75, ["Fatal Point (Tử Huyệt)"], None)])
    fill((14.0, 51.5), [("hex", "sense", 0.8, ["Spirit Sense (Linh Giác)"], None), ("kite", "sense", 0.75, ["Spirit Sense (Linh Giác)"], None)])
    fill((-15.3, 71.5), [("lollipop", "crit", 0.8, ["Seeking the Flaw (Tầm Khuyết)"], None), ("kite", "crit", 0.8, ["Seeking the Flaw (Tầm Khuyết)"], None)])
    fill((23.5, 70.0), [("spoked", "ward", 0.8, ["Steady Ward (Ổn Hộ)"], None), ("kite", "ward", 0.8, ["Steady Ward (Ổn Hộ)"], None)])
    fill((3.5, 63.5), [("tristar", "heart", 0.7, ["Still Heart (Tĩnh Tâm)"], None), ("kite", "heart", 0.7, ["Still Heart (Tĩnh Tâm)"], None)])
    fill((-12.0, 65.5), [("hex", "crit", 0.85, ["Fatal Point (Tử Huyệt)"], None), ("kite", "crit", 0.8, ["Fatal Point (Tử Huyệt)"], None)])
    fill((-13.0, 59.5), [("cup", "body", 0.7, ["Gold Skin (Kim Bì)"], None), ("kite", "body", 0.7, ["Gold Skin (Kim Bì)"], None)])
    # second pass at a tighter clearance (1.6 units)
    fill((-19.0, 64.0), [("theta", "sword", 0.9, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)", "Edge Follows Will (Kiếm Tùy Ý)"], None),
                         ("hex", "sword", 0.9, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)"], None), ("kite", "sword", 0.8, ["Sword Qi Crosses (Kiếm Khí Tung Hoành)"], None)])
    fill((4.0, 40.5), [("anchor", "linh", 0.7, ["Full Sea of Qi (Khí Hải)"], None), ("kite", "linh", 0.7, ["Full Sea of Qi (Khí Hải)"], None)])
    fill((7.5, 51.0), [("window", "metal", 0.7, ["Piercing Gold (Xuyên Kim)"], None), ("kite", "metal", 0.7, ["Piercing Gold (Xuyên Kim)"], None)])
    fill((9.0, 31.5), [("trident", "ward", 0.7, ["Bright Shell (Quang Xác)"], None), ("kite", "ward", 0.7, ["Bright Shell (Quang Xác)"], None)])
    fill((-8.5, 60.5), [("hourglass", "lifespan", 0.7, ["Late Autumn (Thu Muộn)"], None), ("kite", "lifespan", 0.7, ["Late Autumn (Thu Muộn)"], None)])
    fill((8.5, 61.5), [("eye", "heart", 0.7, ["Unmoved Mind (Bất Động Tâm)"], None), ("kite", "heart", 0.7, ["Unmoved Mind (Bất Động Tâm)"], None)])
    fill((17.0, 71.5), [("hex", "refining", 0.8, ["Ore Sense (Thức Khoáng)"], None), ("kite", "refining", 0.7, ["Ore Sense (Thức Khoáng)"], None)])
    fill((-7.5, 41.5), [("V", "sword", 0.7, ["One Cut (Nhất Trảm)"], None), ("kite", "sword", 0.7, ["One Cut (Nhất Trảm)"], None)])
    fill((-13.0, 46.5), [("arrow", "health", 0.7, ["Thick Blood (Huyết Hậu)"], None), ("kite", "health", 0.7, ["Thick Blood (Huyết Hậu)"], None)])
    fill((-6.0, 54.0), [("bowtie", "crit", 0.7, ["Heavy Blow (Trọng Kích)"], None), ("kite", "crit", 0.7, ["Heavy Blow (Trọng Kích)"], None)])

KEYSTONES = {
    "CALLED": {"name": "Called Blow (Báo Chiêu) [effects.md]", "rule": "Your crit chance is counted on a visible meter, not rolled.", "closes": "Crit chance cap 0.50 → 0.35"},
    "NOWARD": {"name": "No Ward (Vô Hộ) [effects.md]", "rule": "You can never use a ward, and your body hardens instead: +25 pp body shield, regaining 2 % of health after each pulse in which no hit reached your health.", "closes": "No ward of any kind, including the default ward and soul wards"},
    "HDB": {"name": "Heart Demon's Blade (Tâm Ma Nhập Đao) [effects.md]", "rule": "Your hits deal more for every point of heart demon above 30 (L5 +1 each, up to +40).", "closes": "Qi deviation chance × 2; every fight you win reports +1 heart demon"},
}

_METAL_THEMES = {
    "start": {"label": "Start", "kind": "start", "small_name": "", "small": [], "notables": []},
    "road": {"label": "Travel node", "kind": "road", "small_name": "", "small": [], "notables": []},
    "exit": {"label": "Leads elsewhere", "kind": "exit", "small_name": "", "small": [], "notables": []},
    "keystone": {"label": "Keystone", "kind": "keystone", "small_name": "Path to a keystone", "small": [("khi_huyet_pct", "", 1.0)], "notables": []},
    "sword": {"label": "Sword intent (Kiếm Ý)", "kind": "identity", "small_name": "Sword intent", "small": [("attack_pct", "sword", 1.0)],
              "notables": [("Sword Heart (Kiếm Tâm)", [("attack_pct", "sword", .5), ("crit_chance_pct", "sword", .5)]),
                           ("Thousand Edges (Thiên Phong)", [("attack_pct", "sword", .6), ("art_speed_pct", "sword", .4)]),
                           ("Unsheathed (Xuất Vỏ)", [("crit_damage_pct", "sword", .6), ("attack_pct", "sword", .4)]),
                           ("Edge Follows Will (Kiếm Tùy Ý)", [("art_cost_pct", "sword", .5), ("art_speed_pct", "sword", .5)]),
                           ("Severing Light (Đoạn Quang)", [("resist_pen_pct", "physical", .5), ("attack_pct", "sword", .5)]),
                           ("Flying Sword (Phi Kiếm)", [("artifact_attack_pct", "weapon", .5), ("attack_pct", "sword", .5)]),
                           ("One Cut (Nhất Trảm)", [("crit_damage_pct", "sword", .5), ("accuracy_pct", "", .5)]),
                           ("Sword Qi Crosses (Kiếm Khí Tung Hoành)", [("attack_pct", "sword", .7), ("pierce_pct", "", .3)])]},
    "refining": {"label": "Refining (Luyện Khí)", "kind": "identity", "small_name": "Refiner's touch", "small": [("artifact_power_pct", "", 1.0)],
                 "notables": [("Furnace Hand (Lô Thủ)", [("refining_success", "", .6), ("artifact_power_pct", "", .4)]),
                              ("Tempered Ore (Tôi Khoáng)", [("artifact_power_pct", "", .6), ("refine_grade_chance", "", .4)]),
                              ("Spirit Etching (Khắc Linh)", [("artifact_attack_pct", "weapon", .5), ("than_thuc_cost_pct", "", .5)]),
                              ("Life-Bound Treasure (Bản Mệnh Pháp Bảo)", [("artifact_power_pct", "", .5), ("than_thuc_pct", "", .5)]),
                              ("Refined Edge (Tinh Phong)", [("artifact_attack_pct", "weapon", .6), ("attack_pct", "sword", .4)]),
                              ("Ore Sense (Thức Khoáng)", [("refining_success", "", .5), ("than_thuc_pct", "", .5)])]},
    "metal": {"label": "Metal element (Kim)", "kind": "element", "small_name": "Metal qi", "small": [("attack_pct", "kim", 1.0)],
              "notables": [("Autumn Killing Qi (Thu Sát Khí)", [("attack_pct", "kim", .6), ("crit_chance_pct", "kim", .4)]),
                           ("Piercing Gold (Xuyên Kim)", [("resist_pen_pct", "physical", .5), ("attack_pct", "kim", .5)]),
                           ("Metal Bones (Kim Cốt)", [("attack_pct", "kim", .5), ("element_affinity_pct", "", .5)]),
                           ("White Gold Edge (Bạch Kim Phong)", [("attack_pct", "kim", .6), ("art_speed_pct", "kim", .4)])]},
    "body": {"label": "Iron body (Metal defence)", "kind": "element", "small_name": "Iron skin", "small": [("block_rating", "", 1.0)],
             "notables": [("Gold Skin (Kim Bì)", [("body_shield_pct", "", .5), ("resist_pct", "physical", .5)]),
                          ("Iron Spine (Thiết Cốt)", [("block_rating", "", .5), ("khi_huyet_pct", "", .5)]),
                          ("Cast Iron Frame (Thiết Khung)", [("resist_pct", "physical", .6), ("block_rating", "", .4)]),
                          ("Hard as Iron (Cương Ngạnh)", [("body_shield_pct", "", .6), ("health_regen_pct", "", .4)])]},
    "health": {"label": "Health (Khí Huyết)", "kind": "universal", "small_name": "Vitality", "small": [("khi_huyet_pct", "", 1.0)],
               "notables": [("Thick Blood (Huyết Hậu)", [("khi_huyet_pct", "", .7), ("health_regen_pct", "", .3)]),
                            ("Enduring Body (Nhẫn Thân)", [("khi_huyet_pct", "", .5), ("resist_pct", "", .5)]),
                            ("Vital Qi (Sinh Khí)", [("khi_huyet_pct", "", .6), ("body_shield_pct", "", .4)]),
                            ("Root of Life (Sinh Căn)", [("khi_huyet_pct", "", 1.0)])]},
    "linh": {"label": "Linh lực", "kind": "universal", "small_name": "Spiritual power", "small": [("linh_luc_pct", "", 1.0)],
             "notables": [("Deep Dantian (Thâm Đan)", [("linh_luc_pct", "", .7), ("linh_luc_regen_pct", "", .3)]),
                          ("Flowing Qi (Lưu Khí)", [("linh_luc_pct", "", .5), ("art_cost_pct", "", .5)]),
                          ("Full Sea of Qi (Khí Hải)", [("linh_luc_pct", "", 1.0)]),
                          ("Still Pool (Tĩnh Trì)", [("linh_luc_pct", "", .5), ("ward_efficiency_pct", "", .5)])]},
    "sense": {"label": "Thần thức", "kind": "universal", "small_name": "Divine sense", "small": [("than_thuc_pct", "", 1.0)],
              "notables": [("Spirit Sense (Linh Giác)", [("than_thuc_pct", "", .6), ("soul_res_pct", "", .4)]),
                           ("Sea of Consciousness (Thức Hải)", [("than_thuc_pct", "", 1.0)]),
                           ("Clear Eyes (Minh Mục)", [("than_thuc_pct", "", .5), ("accuracy_pct", "", .5)])]},
    "ward": {"label": "Ward (Hộ Thể)", "kind": "universal", "small_name": "Guarding qi", "small": [("defense_pct", "", 1.0)],
             "notables": [("Layered Guard (Trùng Hộ)", [("defense_pct", "", .6), ("ward_efficiency_pct", "", .4)]),
                          ("Steady Ward (Ổn Hộ)", [("ward_efficiency_pct", "", .6), ("resist_pct", "", .4)]),
                          ("Bright Shell (Quang Xác)", [("defense_pct", "", .5), ("status_resist_pct", "", .5)])]},
    "crit": {"label": "Crit (offence)", "kind": "universal", "small_name": "Keen eye", "small": [("crit_chance_pct", "", 1.0)],
             "notables": [("Fatal Point (Tử Huyệt)", [("crit_chance_pct", "", .5), ("crit_damage_pct", "", .5)]),
                          ("Seeking the Flaw (Tầm Khuyết)", [("crit_chance_pct", "", .6), ("accuracy_pct", "", .4)]),
                          ("Heavy Blow (Trọng Kích)", [("crit_damage_pct", "", .7), ("attack_pct", "", .3)])]},
    "lifespan": {"label": "Lifespan (Thọ Nguyên)", "kind": "universal", "small_name": "Long breath", "small": [("lifespan_pct", "", 1.0)],
                 "notables": [("Long Years (Trường Thọ)", [("lifespan_pct", "", 1.0)]),
                              ("Late Autumn (Thu Muộn)", [("lifespan_pct", "", .6), ("cultivation_speed_pct", "", .4)])]},
    "heart": {"label": "Heart (Tâm Cảnh)", "kind": "universal", "small_name": "Calm heart", "small": [("tam_ma_resist_pct", "", 1.0)],
              "notables": [("Still Heart (Tĩnh Tâm)", [("tam_ma_resist_pct", "", .7), ("status_resist_pct", "", .3)]),
                           ("Unmoved Mind (Bất Động Tâm)", [("tam_ma_resist_pct", "", .5), ("soul_res_pct", "", .5)])]},
    "insight": {"label": "Comprehension (Ngộ Đạo)", "kind": "universal", "small_name": "Glimmer of insight", "small": [("ngo_tinh", "", 1.0)],
                "notables": [("Sudden Insight (Đốn Ngộ)", [("ngo_tinh", "", .6), ("breakthrough_chance", "", .4)]),
                             ("Reading the Dao (Quan Đạo)", [("ngo_tinh", "", .5), ("cultivation_speed_pct", "", .5)])]},
}

THEMES = {**common.THEMES, **_METAL_THEMES}

# the hidden band beyond Metal's rim: sealed clusters (authored) and open ones (written by the story); Kinh Mạch Đồ
# rules 6-13. Angle off the axis, kind, theme, condition, name, figure.
HALO = [
    (-19, "sealed", "Artifact Refining", "item: a Meridian Seal", "Sealed: Ancestral Forge (Tổ Lô)", "drum"),
    (-15.3, "open", "Sword intent", "story moment", "Open: Sword Grave Echo (Kiếm Trủng Dư Âm)", "lens"),
    (-1, "sealed", "Divine Sense", "cultivation technique", "Sealed: Heaven-Piercing Gaze (Xuyên Thiên Nhãn)", "eye"),
    (9.5, "sealed", "Longevity", "event", "Sealed: Golden Crane Rest (Kim Hạc Tê)", "gourd2"),
    (13.2, "open", "Artifact Refining", "story moment", "Open: Wandering Smith (Du Tượng)", "concentric"),
    (21, "sealed", "Heart State", "item: a Meridian Seal", "Sealed: Iron Heart Vow (Thiết Tâm Thệ)", "pagoda"),

    (-8.5, 'sealed', 'Sword intent', 'event', 'Sealed: Sword Tomb of the Ancients (Cổ Kiếm Trủng)', 'theta'),
]
