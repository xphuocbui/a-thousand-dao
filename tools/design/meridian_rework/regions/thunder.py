"""Thunder island (Lôi), whole-tree pass 2026-11-08 night: outside the circle opposite Earth, beyond Wind (decision 6).

The thunder god's drum ring: the Thunder start at the centre, a ring of drums, lightning bolts hung outward, two
keystones, and a bridge straight down to the Wind start, where the two lightning roads to Fire and Metal begin.
Thunder starts only here (user decision 2026-11-08).
Coordinates (u, v): v outward along 252°.
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit, islands = _load("pens"), _load("common"), _load("landkit"), _load("islands")
landkit.use(pens, common)

TITLE = "Thunder Island (Lôi)"
START_NAME = "Thunder start (Lôi)"
START_KEY = "thunder"
AXIS = 252
RIM = common.RIM
MIN_SPACING = 0.6
ARC_TOUCH_OK = True       # kit.fits: figures hang off the island's arcs
ROAD_MOD = common.ROAD_KINDS["lightning"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "WRATH": {"name": "Glass Meridians (Lưu Ly Kinh Mạch) [effects.md]", "rule": "Your arts run far faster (art speed +40), on a fragile body.", "closes": "Maximum health −25 %; your body shields hold half"},
    "TRIB": {"name": "Tribulation Body (Lôi Kiếp Thể) [proposal]", "rule": "Thunder tribulations temper you: survive one for a lasting bonus.",
             "closes": "Tribulations strike twice as hard"},
}
C = (0.0, common.ISLAND_R)


def INSIDE(u, v, lim):
    return math.dist((u, v), C) < 15.5 or (math.dist((u, v), C) < 18.2 and v > C[1] - 3) or (abs(u) < 2.2 and 75.0 < v < 85) or (abs(u) < 5.2 and 84.2 < v < 87)


def build(T):
    S, inner, outer = islands.mandala(T, pens, {"centre": C, "theme": "thunder", "key": "thunder", "name": "Thunder", "road": "lightning",
                                                 "inner": (10, 3.5), "inner_star": 1.05, "outer": (12, 6.4), "jag": 0.75, "inner_figs": ("bolt", "V", "kite"),
                                                 "crown": {"span": (-72, 72), "n": 7, "figs": ["bolt", "drum", "bolt", "star"], "k": 0.66}})
    bot = min(outer, key=lambda i: T.pt(i)[1])
    jb = T.junction((0.0, 78.2), road="lightning")
    br_ = T.road([bot, jb], step=3.6, road="lightning")
    islands.gate(T, pens, br_, "thunder", ("V", "bolt", "drum"), k=0.6)
    T.port("bridge", jb)
    figs = [("drum", ["Five Thunders (Ngũ Lôi)", "Heaven's Wrath (Thiên Phạt)"]), ("bolt", ["Thunderclap Step (Lôi Bộ)", "Heaven's Wrath (Thiên Phạt)"]),
            ("star", ["Five Thunders (Ngũ Lôi)", "Tribulation Tempered (Kiếp Luyện)", "Heaven's Wrath (Thiên Phạt)"]), ("bolt", ["Tribulation Tempered (Kiếp Luyện)", "Five Thunders (Ngũ Lôi)"]),
            ("xcross", ["Heaven's Wrath (Thiên Phạt)", "Thunderclap Step (Lôi Bộ)"]), ("bolt", ["Five Thunders (Ngũ Lôi)", "Thunderclap Step (Lôi Bộ)"]),
            ("spoked", ["Tribulation Tempered (Kiếp Luyện)"]), ("bolt", ["Heaven's Wrath (Thiên Phạt)", "Five Thunders (Ngũ Lôi)"])]
    k = 0
    for j, o in enumerate(outer):
        if o == bot:
            continue
        a = pens.toward(T, o, (2 * T.pt(o)[0] - C[0], 2 * T.pt(o)[1] - C[1]))
        if T.pt(o)[1] < C[1] - 2.0 and abs(T.pt(o)[0]) < 5.0:
            continue      # the side facing the tree stays open, so the island sits close without crowding the rim
        if j in (3, 9):
            landkit.keystone_spur(T, o, a, "WRATH" if j == 3 else "TRIB", "thunder")
            continue
        kind, names = figs[k % len(figs)]
        k += 1
        if not pens.pict(T, o, a, kind, "thunder", names=names, k=0.82, turns=(0, 10, -10, 20, -20), mirror=bool(k % 2)):
            T.fit_failures.pop()
            pens.pict(T, o, a, "kite", "thunder", names=names[:1], k=0.8)
