"""Light island (Quang), whole-tree pass 2026-11-08 night: outside the circle beyond Fire (decision 6).

A sun mandala on a graph of its own: the Light start at its centre, an inner ring, a road ring with the variant's
figures hung outward like rays, two keystones, and a bridge straight down to Fire's apex.
Coordinates (u, v): v outward along 0°, the island centred at v = ISLAND_R.
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit, islands = _load("pens"), _load("common"), _load("landkit"), _load("islands")
landkit.use(pens, common)

TITLE = "Light Island (Quang)"
START_NAME = "Light start (Quang)"
START_KEY = "light"
AXIS = 0
RIM = common.RIM
MIN_SPACING = 0.6
ARC_TOUCH_OK = True       # kit.fits: figures hang off the island's arcs
ROAD_MOD = common.ROAD_KINDS["light"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "DAWN": {"name": "Unsetting Sun (Bất Lạc Nhật) [proposal]", "rule": "Heart demon cannot rise above 30.",
             "closes": "Darkness-art nodes give nothing"},
    "HALO": {"name": "Buddha's Halo (Phật Quang Phổ Chiếu) [proposal]", "rule": "Your healing also heals your spirit beasts and allies.",
             "closes": "Crit chance cap 0.50 → 0.25"},
}
C = (0.0, common.ISLAND_R)


def INSIDE(u, v, lim):
    return math.dist((u, v), C) < 15.5 or (math.dist((u, v), C) < 18.2 and v > C[1] - 3) or (-1.2 < u < 3.4 and 75.0 < v < 85) or (abs(u) < 5.2 and 84.2 < v < 87)


def build(T):
    S, inner, outer = islands.mandala(T, pens, {"centre": C, "theme": "light", "key": "light", "name": "Light", "road": "light",
                                                 "inner": (6, 2.6), "outer": (12, 6.4), "inner_figs": ("arrow", "kite"),
                                                 "crown": {"span": (-72, 72), "n": 7, "figs": ["sun", "lotus", "spoked"], "k": 0.62}})
    bot = min(outer, key=lambda i: T.pt(i)[1])
    jb = T.junction((0.0, 78.6), road="light")
    br_ = T.road([bot, jb], step=3.6, road="light")
    islands.gate(T, pens, br_, "light", ("lotus", "sun", "V"))
    T.port("bridge", jb)
    figs = [("sun", ["Dawn (Bình Minh)", "Halo (Phật Quang)", "Piercing Ray (Xuyên Quang)"]), ("lotus", ["Halo (Phật Quang)", "Unclouded (Vô Ế)", "Dawn (Bình Minh)"]),
            ("spoked", ["Unclouded (Vô Ế)"]), ("pagoda", ["Dawn (Bình Minh)"]), ("eye", ["Piercing Ray (Xuyên Quang)"]),
            ("lens", ["Halo (Phật Quang)", "Dawn (Bình Minh)"]), ("hourglass", ["Unclouded (Vô Ế)"]), ("theta", ["Piercing Ray (Xuyên Quang)", "Halo (Phật Quang)"])]
    k = 0
    for j, o in enumerate(outer):
        if o == bot:
            continue
        a = pens.toward(T, o, (2 * T.pt(o)[0] - C[0], 2 * T.pt(o)[1] - C[1]))
        if T.pt(o)[1] < C[1] - 2.0 and abs(T.pt(o)[0]) < 5.0:
            continue      # the side facing the tree stays open, so the island sits close without crowding the rim
        if j in (3, 9):
            landkit.keystone_spur(T, o, a, "DAWN" if j == 3 else "HALO", "light")
            continue
        kind, names = figs[k % len(figs)]
        k += 1
        if not pens.pict(T, o, a, kind, "light", names=names, k=0.82, turns=(0, 10, -10, 20, -20)):
            T.fit_failures.pop()
            pens.pict(T, o, a, "kite", "light", names=names[:1], k=0.8)
