"""Darkness island (Ám), whole-tree pass 2026-11-08 night: outside the circle opposite Light (decision 6).

An eclipse mandala on a graph of its own, joined to Water by a bridge, with the shadow road running along the outside
of the rim, beyond the hidden band, to Earth (Darkness combines Earth and Water).
Coordinates (u, v): v outward along 180°, u across, + toward Water.
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit, islands = _load("pens"), _load("common"), _load("landkit"), _load("islands")
landkit.use(pens, common)

TITLE = "Darkness Island (Ám)"
START_NAME = "Darkness start (Ám)"
START_KEY = "dark"
AXIS = 180
RIM = common.RIM
MIN_SPACING = 0.6
ARC_TOUCH_OK = True       # kit.fits: the shadow road's stops hang off its arc
ROAD_MOD = common.ROAD_KINDS["shadow"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "NIGHT": {"name": "Soul Leaves the Body (Linh Hồn Xuất Khiếu) [effects.md]", "rule": "Once per realm, a death in an event leaves you alive at 5 % vitality.", "closes": "You lose one stage"},
    "SWALLOW": {"name": "Swallowing the Moon (Thôn Nguyệt) [proposal]", "rule": "Your hits steal ward from the foe.",
                "closes": "Your own ward does not regenerate"},
}
C = (0.0, common.ISLAND_R)
# the bridge to Water (2026-11-09): it runs just outside the hidden band to BEND, then drops straight in, square to the
# rim, to BRIDGE_END above Water's gate (world 206°), so the band keeps room for hidden clusters on both sides
BRIDGE_A = 26.0
BEND = (round(86.4 * math.sin(math.radians(BRIDGE_A)), 2), round(86.4 * math.cos(math.radians(BRIDGE_A)), 2))
BRIDGE_END = (round(78.4 * math.sin(math.radians(BRIDGE_A)), 2), round(78.4 * math.cos(math.radians(BRIDGE_A)), 2))
SHADOW_R = 85.4
SHRINE_R, SHRINE_A = 93.0, -77.0     # the Shadow Shrine at the shadow road's eastern turn (world 103°), at the islands' radius


def _seg_d(p, a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    t = max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / (dx * dx + dy * dy)))
    return math.dist(p, (a[0] + t * dx, a[1] + t * dy))


def INSIDE(u, v, lim):
    if math.dist((u, v), C) < 15.5 or (math.dist((u, v), C) < 18.2 and v > C[1] - 3) or _seg_d((u, v), C, BEND) < 3.4 or _seg_d((u, v), BEND, BRIDGE_END) < 2.4:
        return True
    r, a = math.hypot(u, v), math.degrees(math.atan2(u, v))
    return (83.9 < r < 94.0 and -92 < a < -4) or (76.6 < r < 86 and -88 < a < -76) or (math.dist((u, v), (SHRINE_R * math.sin(math.radians(SHRINE_A)), SHRINE_R * math.cos(math.radians(SHRINE_A)))) < 13.0 and r > 83.9)


def build(T):
    P = T.P
    S, inner, outer = islands.mandala(T, pens, {"centre": C, "theme": "dark", "key": "dark", "name": "Darkness", "road": "shadow",
                                                 "inner": (10, 3.7), "inner_shift": (0.0, 1.15), "outer": (10, 6.2), "polygon": True, "inner_figs": ("V", "kite"),
                                                 "crown": {"span": (-42, 74), "n": 5, "figs": ["eclipse", "spiral", "eye"], "k": 0.66}})
    br = min(outer, key=lambda i: math.dist(T.pt(i), BEND))
    jbend = T.junction(BEND, road="shadow")
    brd = T.road([br, jbend], step=3.8, road="shadow", straight=True)
    jb = T.junction(BRIDGE_END, road="shadow")
    T.road([jbend, jb], step=4.0, road="shadow", straight=True)     # drawn before any figure, so figures keep clear of it
    islands.gate(T, pens, brd, "dark", ("eclipse", "lotus", "V"), others=("spiral", "drum", "V"))
    T.port("bridge", jb)
    # the shadow road along the outside of the rim, to Earth
    sl = min(outer, key=lambda i: math.dist(T.pt(i), P(SHADOW_R, -9)))
    a0 = T.junction(P(SHADOW_R, -9.5), road="shadow")
    T.link(sl, a0, kind="highway")
    # round 11 (Opus): a real outer arc that hugs the rim, just outside the hidden band, with destinations on it
    a1 = T.junction(P(SHADOW_R, SHRINE_A), road="shadow")
    sh = T.road([a0, a1], step=8.2, road="shadow", long=True)
    # judge round 17: the arc still read as tacked on, with a kink where it turned in to Earth, and the map had nothing on
    # its east side to balance the three islands. The Shadow Shrine (Ám Từ) now stands at that turn, at the islands'
    # radius: a satellite with a road ring, an inner court round a socket, a crown and a keystone (round 18: as a small
    # ring it read as a "stunted" fourth island). It is a waystation, not a start; the road turns in to Earth at its gate.
    sc = P(SHRINE_R, SHRINE_A)
    T.cluster("Shadow Shrine (Ám Từ)", "shrine", mastery=sc)
    court = [T.node(pens.circ(sc, 2.6, [SHRINE_A + 180 + 45 * q + 22.5])[0], "N" if q in (2, 6) else "s", "dark",
                    name={2: "Moonless Vigil (Vô Nguyệt Thủ)", 6: "Ancestral Shade (Tổ Ảnh)"}.get(q)) for q in range(8)]
    for x, y in zip(court, court[1:] + court[:1]):
        T.link(x, y, centre=sc)
    T.end()
    gate_ring = [T.junction(pens.circ(sc, 5.6, [SHRINE_A + 180 + 36 * q])[0], road="shadow") for q in range(10)]
    for x, y in zip(gate_ring, gate_ring[1:] + gate_ring[:1]):
        T.link(x, y, kind="highway")
    for q in (0, 2, 4, 6):
        o = min(gate_ring, key=lambda g: math.dist(T.pt(g), T.pt(court[q])))
        T.link(min(court, key=lambda c: math.dist(T.pt(c), T.pt(o))), o)
    gate = min(gate_ring, key=lambda g: math.dist(T.pt(g), T.pt(a1)))
    T.link(a1, gate, kind="highway")
    # the road turns in to Earth at the shrine's gate, so the shrine can be skipped (guide step 7)
    bend = [T.junction(P(r, a), road="shadow") for r, a in ((81.9, -81.2), (78.2, -85.0))]
    T.road([a1] + bend, step=8.2, road="shadow", straight=True)
    T.port("shadow", bend[-1])
    # the crown and the keystone, on the far side of the road ring
    crown_figs = [("eclipse", ["New Moon (Sóc Nguyệt)", "Night Blade (Dạ Nhận)"]), ("lotus", ["Swallowed Light (Thôn Quang)"]),
                  ("spiral", ["Shadow Step (Ảnh Bộ)"]), ("eye", ["Night Blade (Dạ Nhận)"]), ("hourglass", ["New Moon (Sóc Nguyệt)"])]
    kf = 0
    for q, g in enumerate(gate_ring):
        if g == gate or math.hypot(*T.pt(g)) < SHRINE_R - 2.0:
            continue      # the side facing the tree and the gate stay open
        a_ = pens.toward(T, g, (2 * T.pt(g)[0] - sc[0], 2 * T.pt(g)[1] - sc[1]))
        if q == 7:
            if landkit.keystone_spur(T, g, a_, "SWALLOW", "dark", n=2):
                continue
            T.fit_failures.pop()
        kind, names = crown_figs[kf % len(crown_figs)]
        kf += 1
        for kind_ in (kind, "lollipop", "V", "kite"):
            if pens.pict(T, g, a_, kind_, "dark", names=names, k=0.9, turns=(0, 10, -10, 22, -22)):
                break
            T.fit_failures.pop()
    figs = [("eclipse", ["New Moon (Sóc Nguyệt)", "Swallowed Light (Thôn Quang)"]), ("spiral", ["Shadow Step (Ảnh Bộ)", "Night Blade (Dạ Nhận)"]),
            ("lens", ["Night Blade (Dạ Nhận)", "New Moon (Sóc Nguyệt)"]), ("eye", ["Swallowed Light (Thôn Quang)"]), ("hourglass", ["Shadow Step (Ảnh Bộ)"]),
            ("concentric", ["New Moon (Sóc Nguyệt)", "Night Blade (Dạ Nhận)"]), ("bowtie", ["Shadow Step (Ảnh Bộ)"]), ("theta", ["Swallowed Light (Thôn Quang)"])]
    k = 0
    for j, o in enumerate(outer):
        if o in (br, sl):
            continue
        a = pens.toward(T, o, (2 * T.pt(o)[0] - C[0], 2 * T.pt(o)[1] - C[1]))
        if T.pt(o)[1] < C[1] - 2.0 and abs(T.pt(o)[0]) < 5.0:
            continue      # the side facing the tree stays open, so the island sits close without crowding the rim
        if j == 3:      # Swallowing the Moon moved to the Shadow Shrine (round 18)
            landkit.keystone_spur(T, o, a, "NIGHT", "dark")
            continue
        kind, names = figs[k % len(figs)]
        k += 1
        if not pens.pict(T, o, a, kind, "dark", names=names, k=0.82, turns=(0, 10, -10, 20, -20)):
            T.fit_failures.pop()
            pens.pict(T, o, a, "kite", "dark", names=names[:1], k=0.8)
    # (the shadow road stays bare: a long road of few nodes, as PoE's highways)
    # waypoints on the shadow road and the bridge: small eclipses hung outward (judge rounds 4-5: bare wires)
    # round 15: a string of night constellations, every other stop, the middle one a great waystation (the arc read as a
    # long bare tail with three beads on it)
    # round 18: five small stops read as debris; two larger ones, a third and two thirds of the way along
    stops = sh[1:-1]
    picks = [stops[len(stops) // 3], stops[2 * len(stops) // 3]]
    seq = ("concentric", "lotus")
    for j, i in enumerate(picks):
        big = True
        first = seq[j % len(seq)]
        done = False
        for kk in ((1.1,) if big else ()) + (0.95, 0.82, 0.68):
            for kind in (first, "eclipse", "spiral", "bowtie", "hourglass", "lollipop", "V", "kite"):
                if pens.pict(T, i, pens.out_angle(T, i), kind, "dark", k=kk, turns=(0, 10, -10, 20, -20, 35, -35)):
                    done = True
                    break
                T.fit_failures.pop()
            if done:
                break
