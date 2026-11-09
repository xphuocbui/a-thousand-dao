"""Earth–Metal blend zone (108°): earth bears metal, so the land between them is ore: a mother-lode coin, a stone tortoise, a vein array.

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

TITLE = "Earth–Metal Blend (Thổ Kim)"
START_NAME = ""
AXIS = common.BLEND_AXIS["em"]
HALF_ANGLE = common.BLEND_HALF
RIM = common.RIM
MIN_SPACING = 0.6
RIM_WAVE = [(-3, -4.0, 2.6)]   # bays in the rim (judge round 6: vary the overhang)
ROAD_MOD = common.ROAD_KINDS[common.BLEND_ROAD["em"]]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {"LODE": {"name": "Mother Lode (Mẫu Khoáng) [proposal]", "rule": "Each magic treasure you carry adds 4 % defence.", "closes": "You carry at most three magic treasures"},
             "VEIN": {"name": "Vein Reader (Độc Mạch) [proposal]", "rule": "A rule from both neighbours (to be written).", "closes": "(to be written)"}}
CFG = {"left": "earth", "right": "metal", "elem": "ore", "elem2": "gravity", "half": HALF_ANGLE,
       "keys": [("ring3", 1, -30, "VEIN", "ore"), ("ring4", 1, 30, "LODE", "ore")], "road": common.BLEND_ROAD["em"], "wobble": (0, -2.0, 2.4, -1.6, 0)}
HALO = [(9.5, "sealed", "Artifact Refining", "item: a Meridian Seal", "Sealed: Mother Vein (Mẫu Mạch)", "coin"),
        (6, "open", "Formations", "story moment", "Open: Iron Mountain Gate (Thiết Sơn Môn)", "window"),
        (-4.5, 'open', 'Artifact Refining', 'story moment', 'Open: Lost Mine (Thất Khoáng)', 'star'),
        (1.5, 'sealed', 'Mountain body', 'event', 'Sealed: Stone Giant (Thạch Cự Nhân)', 'shield')]


def build(T):
    roads = landkit.blend_roads(T, CFG)
    centrepiece(T, roads)
    landkit.blend_finish(T, CFG, roads, HALO)


def centrepiece(T, roads):
    P = T.P
    pens.place_in(T, P(51.0, -5.6), "coin", "ore", k=1.15, names=["Mother Lode (Mẫu Khoáng)", "Buried Gold (Kim Tàng)", "Mother Lode (Mẫu Khoáng)"], ang=0, name="Mother Lode")
    pens.place_in(T, P(52.0, 5.6), "turtle", "mountain", k=1.0, ang=0, name="Stone Tortoise")
    pens.place_in(T, P(37.6, 4.0), "bagua", "formation", k=0.95, ang=0, name="Vein Array")
    pens.place_in(T, P(64.5, -3.0), "anchor", "gravity", k=1.2, ang=0, name="Weight of the Mountain")
