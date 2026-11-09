"""Fire–Earth blend zone (36°): fire makes earth, so the land between them is molten: a volcano of flame and 山, an earth furnace, lava themes, and each neighbour's themes on its own side.

Drawn with the blend skeleton in landkit.py (dantian road from the hub, an arch carrying the inner ring road, four ring
roads and a wandering centre avenue), a hand-placed centrepiece, then dressing, hole fill and the hidden band.
"""
import importlib.util
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Fire–Earth Blend (Hỏa Thổ)"
START_NAME = ""
AXIS = common.BLEND_AXIS["fe"]
HALF_ANGLE = common.BLEND_HALF
RIM = common.RIM
MIN_SPACING = 0.6
RIM_WAVE = [(4, -4.5, 2.8)]   # bays in the rim (judge round 6: vary the overhang)
ROAD_MOD = common.ROAD_KINDS[common.BLEND_ROAD["fe"]]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {"KILN": {"name": "Earthen Kiln (Thổ Diêu) [proposal]", "rule": "Your burning also slows the foe it burns.", "closes": "Your burning deals 30 % less damage"},
             "WUJI": {"name": "Return to Wuji (Phản Bổn Quy Vô Cực) [proposal]", "rule": "Every element counts as your own for element affinity.", "closes": "No identity (district) node gives more than half"}, "MAGMA": {"name": "Molten Core (Dung Tâm) [proposal]", "rule": "A rule from both neighbours (to be written).", "closes": "(to be written)"}}
CFG = {"left": "fire", "right": "earth", "elem": "lava", "elem2": "alchemy", "half": HALF_ANGLE,
       "keys": [("ring3", 1, -30, "MAGMA", "lava"), ("spoke", 2, 80, "WUJI", "chaos", 3), ("ring4", 1, 30, "KILN", "lava")], "braid": 0.0, "avenue_to": 2, "road": common.BLEND_ROAD["fe"]}
HALO = [(-8, "sealed", "Way of Alchemy", "event", "Sealed: Volcano Pill Hall (Hỏa Sơn Đan Các)", "concentric"),
        (2, "open", "Formations", "story moment", "Open: Buried Kiln Array (Địa Lò Trận)", "bagua"),
        (9, "sealed", "Longevity", "cultivation technique", "Sealed: Ash Tortoise (Hôi Quy)", "lens"),
    (5.5, 'open', 'Way of Alchemy', 'story moment', 'Open: Lava Spring (Dung Tuyền)', 'lotus'),
        (-3.5, 'sealed', 'Formations', 'event', 'Sealed: Ash Altar (Hôi Đàn)', 'shan'),]


def build(T):
    roads = landkit.blend_roads(T, CFG)
    centrepiece(T, roads)
    landkit.blend_finish(T, CFG, roads, HALO)


def centrepiece(T, roads):
    P = T.P
    pens.place_in(T, P(51.0, -5.4), "flame", "lava", k=1.3, names=["Volcano Heart (Hỏa Sơn Tâm)", "Kiln Fired (Lò Nung)"], ang=0, name="Volcano Flame")
    pens.place_in(T, P(51.0, 5.6), "shan", "lava", k=1.15, names=["Kiln Fired (Lò Nung)", "Volcano Heart (Hỏa Sơn Tâm)", "Kiln Fired (Lò Nung)"], ang=0, name="Fire Mountain (Hỏa Diệm Sơn)")
    pens.place_in(T, P(37.6, -4.0), "cauldron", "alchemy", k=1.0, ang=0, name="Earth Furnace (Địa Lô)")
    pens.place_in(T, P(64.5, 3.0), "sun", "fire", k=1.05, ang=0, name="Burning Sky")
