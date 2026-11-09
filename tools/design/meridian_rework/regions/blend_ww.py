"""Water–Wood blend zone (252°) and Wind's land, whole-tree pass 2026-11-08 night.

Water nourishes Wood, so the inner blend is spring rain (clouds, vines). Its outer half is Wind's land (decision 6:
Wind starts between Water and Wood, near the rim): the Wind start sits on ring 4 with a great folding fan opening
inward beneath it and auspicious clouds at its sides. Just above it the Thunder island's bridge lands on a junction from
which the two lightning roads leave: toward Water and Metal, and toward Wood and Fire (decision 6, zoning draft 3).
"""
import importlib.util
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Water–Wood Blend and Wind Land (Phong)"
START_NAME = "Wind start (Phong)"
START_KEY = "wind"
AXIS = common.BLEND_AXIS["ww"]
HALF_ANGLE = common.BLEND_HALF
RIM = common.RIM
MIN_SPACING = 0.6
HALO_AVOID = [(-5.0, 5.0)]     # the Thunder island's bridge
ROAD_MOD = common.ROAD_KINDS["thuy"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "MONSOON": {"name": "Monsoon Heart (Quý Phong Tâm) [proposal]", "rule": "Every third art you cast costs no linh lực.",
                "closes": "Your arts cost 20 % more"},
    "GALE": {"name": "Riding the Gale (Thừa Phong) [proposal]", "rule": "Every evasion you make speeds your next art.",
             "closes": "Ward strength halved"},
}
CFG = {"left": "rain", "right": "wind", "elem": "wind", "elem2": "rain", "half": HALF_ANGLE, "road": "wind", "rings": 3, "bulge": (1.2, -1.0, -0.8, 0.6),
       "wobble": (0, -1.8, 2.0, 0.0, 0), "keys": [("ring2", 1, 30, "MONSOON", "rain")]}
HALO = [(-10.2, "open", "Wind", "story moment", "Open: Cave of the Four Winds (Tứ Phong Động)", "lens"),
    (6.5, 'sealed', 'Wind', 'event', 'Sealed: Cloud Sea Pavilion (Vân Hải Các)', 'concentric'),
        (-5.2, 'open', 'Spirit Fields', 'story moment', 'Open: Rain Terrace (Vũ Điền)', 'cloud'),
        (9.5, 'sealed', 'Wind', 'item: a Meridian Seal', 'Sealed: Gale Gate (Phong Môn)', 'spiral'),]


def build(T):
    P = T.P
    roads = landkit.blend_roads(T, CFG)
    # ---- ring 4 runs through the Wind start ------------------------------------------------------------------------
    S = T.node(P(69.4, 0), "S", key="wind")
    jm, jp = T.junction(P(common.LAND_RINGS["water"][3], -10.6), road="wind"), T.junction(P(common.LAND_RINGS["wood"][3], 10.6), road="wind")
    r4 = T.road([jm, S], step=4.6, road="wind", straight=True) + T.road([S, jp], step=4.6, road="wind", straight=True)[1:]
    T.edge_port(jm, "r4-"); T.edge_port(jp, "r4+")
    roads["ring4"] = r4
    # the Thunder island's bridge lands beside the Wind start; lightning reaches Wind only (2026-11-09: the lightning
    # roads that ran inside the rim to Fire and to Metal were removed)
    LT = T.junction(P(common.LIGHTNING_R + 0.6, 0), road="lightning")
    T.link(S, LT, kind="highway")
    T.port("thunder", LT)
    # ---- Wind's start web: a great fan opening inward, clouds at its sides -----------------------------------------
    fan = pens.pict(T, S, 180, "whirl", "wind", k=1.2, names=["Eye of the Storm (Phong Nhãn)", "Gale Blade (Cuồng Phong Đao)", "Wind Walker (Ngự Phong)"],
                    name="Whirlwind (Toàn Phong)", turns=(0, 8, -8, 16, -16), shrink=(1.0, 0.92, 0.85))
    if not fan:
        T.fit_failures.pop()
        fan = pens.pict(T, S, 180, "fan", "wind", k=1.75, names=["Wind Walker (Ngự Phong)", "Eye of the Storm (Phong Nhãn)"], name="Wind Fan (Phong Phiến)",
                        turns=(0, 6, -6), shrink=(1.0, 0.92, 0.85))
    if fan:
        J3c = roads["ring3"][len(roads["ring3"]) // 2]
        T.attach(J3c, fan)
    for a, nm in ((-60, "Leaving No Trace (Vô Ảnh)"), (60, "Gale Blade (Cuồng Phong Đao)")):
        pens.dress(T, S, [("cloud", "wind", a, 0.9, [nm, "Wind Walker (Ngự Phong)"]), ("kite", "wind", a, 0.8, [nm])])
    j3 = roads["ring3"][0]
    landkit.keystone_spur(T, j3, 30, "GALE", "wind")
    # ---- the rain below -------------------------------------------------------------------------------------------
    pens.place_in(T, P(37.6, -4.0), "cloud", "rain", k=1.2, names=["Rain on Bamboo (Vũ Trúc)", "Mist Valley (Vụ Cốc)"], ang=0, name="Rain Cloud")
    pens.place_in(T, P(51.0, 4.8), "vine", "rain", k=1.15, names=["Mist Valley (Vụ Cốc)", "Rain on Bamboo (Vũ Trúc)"], ang=0, name="Bamboo After Rain")
    landkit.blend_finish(T, CFG, roads, HALO)
