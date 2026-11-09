"""Wood–Fire blend zone (324°): wood feeds fire: the wutong tree the phoenix perches on. The lightning road from Thunder comes in from Wood's side and ends on ring 4 here.

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

TITLE = "Wood–Fire Blend (Mộc Hỏa)"
START_NAME = ""
AXIS = common.BLEND_AXIS["wf"]
HALF_ANGLE = common.BLEND_HALF
RIM = common.RIM
MIN_SPACING = 0.6
ROAD_JITTER = 0.0     # a jittered stop beside the Fire port put a vine on the join (round 26)
ROAD_MOD = common.ROAD_KINDS[common.BLEND_ROAD["wf"]]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {"WILDFIRE": {"name": "Wildfire Seed (Dã Hỏa Chủng) [proposal]", "rule": "When your burning ends on a foe, it spreads to the nearest other foe.", "closes": "Your burning lasts half as long"},
             "KINDLE": {"name": "Burning Wood (Phần Mộc) [proposal]", "rule": "A rule from both neighbours (to be written).", "closes": "(to be written)"}}
CFG = {"left": "wood", "right": "fire", "elem": "kindling", "elem2": "growth", "half": HALF_ANGLE,
       "keys": [("ring3", 1, -30, "KINDLE", "kindling"), ("ring4", 1, -30, "WILDFIRE", "kindling")], "braid": 0.0, "avenue_to": 2, "road": common.BLEND_ROAD["wf"], "wobble": (0, -1.6, 2.0, -2.2, 0)}
HALO = [(7, "sealed", "Spirit Fields", "item: a Meridian Seal", "Sealed: Wutong Grove (Ngô Đồng Lâm)", "lotus"),
    (-6, 'sealed', 'Longevity', 'item: a Meridian Seal', 'Sealed: Phoenix Feather (Phượng Vũ)', 'gourd2'),
    (2.5, 'open', 'Spirit Fields', 'story moment', 'Open: Burnt Orchard (Tiêu Viên)', 'lens'),
        (9.0, 'sealed', 'Way of Alchemy', 'event', 'Sealed: Ember Grove (Dư Hỏa Lâm)', 'flame'),]


def build(T):
    roads = landkit.blend_roads(T, CFG)
    centrepiece(T, roads)
    landkit.blend_finish(T, CFG, roads, HALO)


def centrepiece(T, roads):
    P = T.P
    pens.place_in(T, P(51.0, -5.6), "tree", "kindling", k=1.3, names=["Phoenix Perch (Phượng Thê)", "Wood Feeds Fire (Mộc Sinh Hỏa)"], ang=0, name="Wutong Tree (Ngô Đồng)")
    pens.place_in(T, P(51.5, 5.8), "phoenix", "phoenix", k=1.0, ang=0, name="Phoenix Alights")
    pens.place_in(T, P(37.6, -4.0), "vine", "growth", k=1.0, ang=0, name="Climbing Vine")
