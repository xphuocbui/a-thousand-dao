"""Fire land on the A2 road layout: the fill test (user 2026-11-15: "fill fire first as a test").

The roads come from tools/design/dao_do_rework/skeleton/sketch_a2.py (variant A2, the mandala chain): Fire's three
star figures on its axis, its side roads to the two blend zones, the rim. The neighbouring roads are drawn too, for
context, so figures keep clear of them. Figures are hung and holes filled with the land toolkit as in the other lands,
inside Fire's own 36 degrees only, with Fire's themes (Blaze on the left, Alchemy on the right, Fire and Phoenix in the
middle). The question this answers: does the road shape still read once the clusters are on it?

Build: python -I tools/design/dao_do_rework/build_region.py fire_a2 <out_dir>
"""
import importlib.util
import math
import os
import sys

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)
sys.path.insert(0, os.path.join(os.path.dirname(_d), "skeleton"))
sys.path.insert(0, os.path.dirname(_d))
import sketch as SK  # noqa: E402
import sketch_a2  # noqa: E402

TITLE = "Fire Land on the A2 roads (fill test)"
START_NAME = "Fire start (Hỏa)"
START_KEY = "fire"
AXIS = 0
RIM = SK.RIM + 0.8          # the kit keeps figures 0.8 inside RIM
R_IN = SK.CENTRE_R
MIN_SPACING = 0.6
ROAD_MOD = common.ROAD_KINDS["hoa"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {}
HALF = 18.0                 # Fire's own share: half-way to each blend axis
CONTEXT = 44.0              # neighbouring roads drawn for context, out to this many degrees
CFG = {"left": "blaze", "right": "alchemy", "elem": "fire", "elem2": "phoenix", "half": HALF, "road": "hoa"}


def _ang(u, v):
    return math.degrees(math.atan2(u, v))


# The emblems' insides stay clear (the islands keep their shape because their rings are open inside and their figures
# hang outward). (centre v, radius) of Fire's three stars in sketch_a2; FIRE_A2_CLEAR=0 builds without the clearing.
EMBLEMS = [(SK.START_R, 5.8), (48.0, 8.0), (69.5, 6.4)]
CLEAR = os.environ.get("FIRE_A2_CLEAR", "1") == "1"


def INSIDE(u, v, lim):
    """Figures stay inside Fire's own wedge, between the Chaos centre and the rim, and out of the emblems."""
    r = math.hypot(u, v)
    if CLEAR and any(math.dist((u, v), (0.0, cv)) < rr * 0.98 for cv, rr in EMBLEMS):
        return False
    return abs(_ang(u, v)) <= HALF and SK.CENTRE_R + 0.5 < r < SK.RIM - 0.3


def build(T):
    g, _ = sketch_a2.variant_a2()
    keep = [n for n in g.nodes if n["kind"] in ("travel", "start") and abs(_ang(n["x"], n["y"])) <= CONTEXT
            and SK.CENTRE_R - 6.0 < math.hypot(n["x"], n["y"]) <= SK.RIM + 0.5]
    m = {}
    for n in keep:
        if n["kind"] == "start":
            m[n["id"]] = T.node((n["x"], n["y"]), "S", key="fire" if n["region"] == "fire" else None)
        else:
            m[n["id"]] = T.junction((n["x"], n["y"]), road="hoa" if n["region"] == "fire" else None)
    for e in g.edges:
        if e["a"] in m and e["b"] in m:
            T.link(m[e["a"]], m[e["b"]], centre=tuple(e["arc"]) if e.get("arc") else None)
    fire_roads = [m[n["id"]] for n in keep if n["region"] == "fire" and n["kind"] == "travel" and abs(_ang(n["x"], n["y"])) <= HALF]
    cfg = dict(CFG, within=lambda u, v: INSIDE(u, v, None))
    landkit.dress_roads(T, sorted(fire_roads, key=lambda i: math.hypot(*T.pt(i))), cfg, per=2)
    landkit.fill_holes(T, cfg, clr=float(os.environ.get("FIRE_A2_CLR", "2.0")), rounds=int(os.environ.get("FIRE_A2_ROUNDS", "2")))
