"""The centre hub (Đan Điền), whole-tree pass 2026-11-08: a Taiji with the Chaos start at its heart.

Primordial Chaos (Hỗn Độn) may start here (decision 6). The hub is a Taiji: a ring of ten split by the S of two
half-circles, the start at the S's middle, the two eyes as notables. Five dantian roads leave the ring toward the five
blend zones (36°, 108°, ...), so the centre reaches every pair of neighbours; the five ring points that face the
element lands each carry a universal figure (life, lifespan, heart, comprehension, linh lực) that points at that land's
near keystone across the gap. Hub roads pay a talent of the player's choice (PoE 2's pick-one travel nodes).
Drawn in Fire's frame (axis 0): (u, v) with v up toward Fire.
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Centre Hub (Đan Điền)"
START_NAME = "Chaos start (Hỗn Độn)"
START_KEY = "chaos"
AXIS = 0
RIM = 76
MIN_SPACING = 0.6
ROAD_MOD = [("any_talent", "", 1.0)]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "WUJI": {"name": "Return to Wuji (Phản Bổn Quy Vô Cực) [proposal]", "rule": "Every element counts as your own for element affinity.",
             "closes": "No identity (district) node gives more than half"},
    # 2026-11-15, the Chaos land (user: comparable and stronger). Placeholders for the content pass
    "CYCLE": {"name": "Five Phases Turn (Ngũ Hành Luân Chuyển) [proposal]", "rule": "Each art you use counts as the element that the last one generates.",
              "closes": "Your single strongest element gives no bonus"},
    "VOID": {"name": "Primordial Void (Hồng Mông) [proposal]", "rule": "Every element land you hold a notable in raises all your element damage.",
             "closes": "Element purity counts for half"},
    "SEED": {"name": "Seed of Chaos (Hỗn Độn Chủng) [proposal]", "rule": "Your breakthrough guard also covers the next realm.",
             "closes": "Cultivation speed −20 %"},
}
# the Chaos land (2026-11-15): a dantian ring road and five dantian roads out to the push edge; every road node
# dressed, the holes filled, the figures keep all their notables (stronger per point, fewer points than a land)
CFG = {"left": "chaos", "right": "chaos", "elem": "chaos", "half": 180, "airy_r": 0, "rich": True,
       "hole_rmin": 4.6, "centre_sparse": 0.0}
RING_R = 10.6
SPOKE_R = (6.0, RING_R, 14.6, common.HUB_R - 1.0)


def INSIDE(u, v, lim):
    return math.hypot(u, v) <= min(lim["rmax"], common.HUB_R)


def build(T):
    P = T.P
    S = T.node((0, 0), "S", key="chaos")
    R0 = 3.4
    T.cluster("Taiji (Thái Cực)", "taiji", mastery=None)
    angs = [36 * k for k in range(10)]
    ring = [T.node(P(R0, a), "N" if a in (72, 288) else "s", "chaos",
                   name={72: "Taiji Turns (Thái Cực Chuyển)", 288: "Wuji (Vô Cực)"}.get(a)) for a in angs]
    for a, b in zip(ring, ring[1:] + ring[:1]):
        T.link(a, b, centre=(0, 0))
    cu, cd = (0, R0 / 2), (0, -R0 / 2)
    su = T.node((R0 / 2, R0 / 2), "s", "chaos")
    sd = T.node((-R0 / 2, -R0 / 2), "s", "chaos")
    T.link(ring[0], su, centre=cu); T.link(su, S, centre=cu); T.link(S, sd, centre=cd); T.link(sd, ring[5], centre=cd)
    e1 = T.node((-0.55, R0 / 2), "N", "chaos", name="Before Heaven (Tiên Thiên)")
    T.link(e1, ring[9]); T.link(e1, ring[0])
    T.end()
    e2 = T.node((0.55, -R0 / 2), "N", "chaos", name="Five in One (Ngũ Hành Quy Nhất)")
    T.cur = T.nodes[ring[0]]["cluster"]
    T.nodes[e2]["cluster"] = T.cur; T.clusters[T.cur]["nodes"].append(e2)
    T.end()
    T.link(e2, ring[4]); T.link(e2, ring[5])
    # five dantian roads out to the blend zones, crossing the dantian ring road (2026-11-15: out to the push edge)
    spokes, ringj = {}, {}
    for a, key in ((36, "fe"), (108, "em"), (180, "mw"), (252, "ww"), (324, "wf")):
        js = [T.junction(P(r, a), road="hub") for r in SPOKE_R]
        T.link(ring[a // 36], js[0], kind="highway")
        for x, y in zip(js, js[1:]):
            T.link(x, y, kind="highway")
        T.port("s" + key, js[-1])
        spokes[key] = (js[0], js[-1])
        ringj[a] = js[1]
        for s_ in (-24, 24):
            ringj[a + s_] = T.junction(P(RING_R, a + s_), road="hub")
    ra = sorted(ringj)
    for x, y in zip(ra, ra[1:] + ra[:1]):
        T.link(ringj[x], ringj[y], centre=(0, 0), kind="highway")
    # three Chaos keystones on spurs off the land axes (the land cradles point down the axes; keystones crowding the
    # centre are an open complaint, Meridian GDD Open Question 20), pointing out toward the push edge
    for key, choices in (("CYCLE", (60, 12)), ("VOID", (204, 156, 228, 132)), ("SEED", (300, 348))):
        n0 = len(T.fit_failures)
        for a in choices:
            if landkit.keystone_spur(T, ringj[a], a, key, "chaos"):
                del T.fit_failures[n0:]
                break
    # a universal figure facing each element land (toward its near keystone)
    faces = ((0, "heart", "lotus", ["Bright Mirror Heart (Minh Kính Tâm)", "Still Heart (Tĩnh Tâm)", "Unmoved Mind (Bất Động Tâm)"]),
             (72, "lifespan", "gourd2", ["Crane's Age (Hạc Thọ)", "Long Years (Trường Thọ)"]),
             (144, "health", "theta", ["Unbroken Marrow (Tủy Bất Đoạn)", "Root of Life (Sinh Căn)"]),
             (216, "insight", "concentric", ["Listening to the Rain (Thính Vũ)", "Sudden Insight (Đốn Ngộ)"]),
             (288, "linh", "spoked", ["Endless Spring (Tuyền Bất Tận)", "Full Sea of Qi (Khí Hải)"]))
    for a, th, fig, names in faces:
        for f in (fig, "lotus", "gourd2", "totem", "hourglass", "lollipop", "kite"):
            if pens.pict(T, ring[a // 36], a, f, th, names=names, k=0.74, gap=0.9, turns=(0, 8, -8, 16, -16, 24, -24), shrink=(1.0, 0.92, 0.85)):
                break
            T.fit_failures.pop()
    # the Chaos land: every road node of the ring and the dantian roads dressed, then the open spaces filled
    roads = [i for i, n in enumerate(T.nodes) if n["kind"] == "travel"]
    landkit.dress_roads(T, sorted(roads, key=lambda i: math.hypot(*T.pt(i))), CFG, per=2, inner_r=0, outer_r=99)
    landkit.fill_holes(T, CFG, clr=2.0, rounds=2)
