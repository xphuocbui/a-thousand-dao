"""Metal–Water blend zone (180°): metal gathers water, as dew on cold iron: a mirror lake and twin moons in the water. The lightning road from Thunder comes in from Water's side and ends on ring 4 here; the Darkness island's bridge passes just beyond the rim.

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

TITLE = "Metal–Water Blend (Kim Thủy)"
START_NAME = ""
AXIS = common.BLEND_AXIS["mw"]
HALF_ANGLE = common.BLEND_HALF
RIM = common.RIM
MIN_SPACING = 0.6
ROAD_MOD = common.ROAD_KINDS[common.BLEND_ROAD["mw"]]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {"FROSTEDGE": {"name": "Frost on the Blade (Sương Nhận) [proposal]", "rule": "Your weapon hits chill the foe; chilled foes take double critical damage.", "closes": "Your critical chance is halved"},
             "DEW": {"name": "Cold Dew Heart (Hàn Lộ Tâm) [proposal]", "rule": "A rule from both neighbours (to be written).", "closes": "(to be written)"}}
CFG = {"left": "metal", "right": "water", "elem": "dew", "elem2": "tide", "half": HALF_ANGLE,
       "keys": [("ring3", 1, -30, "DEW", "dew"), ("ring4", 1, 30, "FROSTEDGE", "dew")], "braid": -3.0, "avenue_to": 2, "road": common.BLEND_ROAD["mw"], "wobble": (0, 2.0, -2.2, 2.0, 0)}
HALO = [(-8, "sealed", "Divine Sense", "event", "Sealed: Bright Mirror Lake (Minh Kính Hồ)", "concentric"),
    (5.5, 'sealed', 'Heart State', 'event', 'Sealed: Frost Bell (Sương Chung)', 'pagoda'),
        (-2.0, 'open', 'Tide', 'story moment', 'Open: Mist Ferry (Vụ Độ)', 'fish'),]


def build(T):
    roads = landkit.blend_roads(T, CFG)
    centrepiece(T, roads)
    landkit.blend_finish(T, CFG, roads, HALO)


def centrepiece(T, roads):
    P = T.P
    pens.place_in(T, P(51.0, -5.6), "lens", "dew", k=1.2, names=["Mirror Lake (Kính Hồ)", "Autumn Dew (Thu Lộ)"], ang=0, name="Mirror Lake")
    pens.place_in(T, P(51.5, 5.8), "eclipse", "dew", k=1.25, names=["Autumn Dew (Thu Lộ)", "Mirror Lake (Kính Hồ)"], ang=0, name="Twin Moons in the Water")
    pens.place_in(T, P(37.6, 4.0), "spiral", "tide", k=1.0, ang=0, name="Cold Current")
