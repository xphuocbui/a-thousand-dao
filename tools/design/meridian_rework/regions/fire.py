"""Fire land (Hỏa), whole-tree pass 2026-11-08 night. Axis 0° (the top of the tree).

The start web follows the Metal pilot (twin hubs: Blaze on Wood's side, Alchemy on Earth's side; the True Flame dome;
a Rebirth lane). The centre road is a chain of pass-through constellations, each with roads beside it: the Sun Wheel
(band 1), the Fire Lotus (band 2) and the Vermilion Bird (band 3), whose head reaches the apex where the Light island's
bridge comes in. Blaze's figures run up the left (flame tongues, a burning star, wildfire); Alchemy's up the right (the
pill cauldron, the nine-turn spiral, the elixir gourd).
Coordinates (u, v): v outward along Fire's axis, u across, + toward Earth.
"""
import importlib.util
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Fire Land (Hỏa)"
START_NAME = "Fire start (Hỏa)"
START_KEY = "fire"
AXIS = common.ELEM_AXIS["fire"]
HALF_ANGLE = common.LAND_HALF
HALO_EXTRA = 3        # small hidden clusters added in the band's widest gaps (rule 6: about 75 in all)
HALO_AVOID = [(-5.0, 5.0)]     # the Light island's bridge
RIM = common.RIM
MIN_SPACING = 0.6
RIM_WAVE = [(-12, -4.5, 3.2), (14, -3.5, 2.6), (3, 1.0, 3.0)]   # bays in the rim (judge round 6: vary the overhang)
ROAD_MOD = common.ROAD_KINDS["hoa"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "SOLAR": {"name": "Great Sun Body (Đại Nhật Thân) [proposal]", "rule": "Your Fire arts never miss at full health.", "closes": "Below half health, Fire arts cost double"},
    "PYRE": {"name": "Cinnabar Furnace Body (Chu Sa Lô Thể) [proposal]", "rule": "Pills you eat also burn the foe.", "closes": "Pill effects last half as long"},
    "EMBER": {"name": "Burning Lifespan (Nhiên Thọ) [effects.md]", "rule": "Once a fight, when your health first falls to 30 % or below, you burn years for 5 s of fury (L5 +40 on all hits, art speed +30).", "closes": "When it fires, the result reports 2 % of your realm's base lifespan in years lost, win or lose"},
    "ASH": {"name": "Unyielding Breath (Bất Khuất) [effects.md]", "rule": "Once a fight, a blow that would put you Down leaves you at 1 health.", "closes": "Maximum health −15 %"},
    "PILL": {"name": "Living Furnace (Thân Vi Lô) [proposal]", "rule": "Your body is your cauldron: pills you brew are taken at once for more effect.",
             "closes": "Brewed pills cannot be stored or sold"},
}
WEB = {"key": "fire", "gate": "Gate of Fire", "left": "blaze", "right": "alchemy", "elem": "fire", "hubL": "Wildfire (Dã Hỏa)",
       "hubR": "Pill Heart (Đan Tâm)", "top": "True Flame (Chân Hỏa)", "low_theme": "phoenix", "low": "Rise From Ash (Dục Hỏa)",
       "cradle": ("lifespan", "heart", "health"), "keystone": "EMBER"}
CFG = {"left": "blaze", "right": "alchemy", "elem": "fire", "elem2": "phoenix", "half": HALF_ANGLE, "road": "hoa",
       "rings": [(-21, -12, 0, 12, 21), (-21, -10, 0, 13, 21), (-20, -12, 0, 12, 20), (-22, -8, 0, 8, 22)],
       "hub_to": (-12, 12), "centre_to": None, "ring_r": common.LAND_RINGS["fire"], "straight": (4,), "ring_dr": {(4, -8): -1.3, (4, 0): 1.1, (4, 8): -0.9, (3, 0): 1.2},
       "ring_gaps": [(2, 13), (2, -21), (3, 12), (1, -12)], "dense": [(44.0, -8.5, 4.5), (64.0, 8.0, 4.5)], "landmark": {0: ("fire", "sun"), 1: ("phoenix", "lotus")},
       "quiet": [(57.5, -7.0, 4.2, ("sealed", "Way of Alchemy", "event", "Sealed: Cinnabar Grotto (Chu Sa Động)", "gourd2")), (43.5, 7.5, 3.8, ("open", "Blaze", "story moment", "Open: Ember Field (Dư Tẫn Nguyên)", "lens"))],
       "outer_keys": [(2, -10, -45, "SOLAR", "fire"), (4, -22, 160, "PYRE", "blaze")],
       "avenues": [(1, 12, 2, 13), (2, -10, 3, -12), (3, -12, 4, -8)], "spoke_gaps": ("w2", "e3")}
HALO = [
    (-20.5, "sealed", "Way of Alchemy", "item: a Meridian Seal", "Sealed: Furnace of the First Flame (Sơ Hỏa Lô)", "drum"),
    (-16.8, "open", "Blaze", "story moment", "Open: Burning Plains (Hỏa Nguyên)", "concentric"),
    (-7.0, "sealed", "Heart State", "event", "Sealed: Lamp Before the Buddha (Phật Tiền Đăng)", "lotus"),
    (9.0, "sealed", "Longevity", "cultivation technique", "Sealed: Phoenix Nirvana (Phượng Hoàng Niết Bàn)", "gourd2"),
    (12.6, "open", "Way of Alchemy", "story moment", "Open: Lost Recipe (Thất Truyền Đan Phương)", "theta"),
    (21, "sealed", "Divine Sense", "item: a Meridian Seal", "Sealed: Eye of the Sun (Thái Dương Nhãn)", "eye"),

]


def build(T):
    P = T.P
    w = landkit.web(T, WEB)
    roads = landkit.land_roads(T, CFG, w)
    J = roads["J"]
    # ---- the centre road: Sun Wheel, Fire Lotus, Vermilion Bird -------------------------------------------------
    sun = landkit.wheel(T, P(37.2, 0), 3.1, 12, "fire", notables=(3, 9), names=["Sun Essence (Thái Dương Tinh)", "Burning Heaven (Phần Thiên)"],
                        name="Sun Wheel", themes={0: "fire", 6: "fire"})
    T.road([w["top"], J[1][0]], step=2.6, road="hoa")
    T.road([J[1][0], sun[0]], step=3.0, road="hoa")
    T.road([sun[6], J[2][0]], step=3.0, road="hoa")
    T.cur = T.nodes[sun[0]]["cluster"]
    for j in (2, 4, 8, 10):
        a = 180 + 30 * j
        T.run(sun[j], [pens.circ(P(37.2, 0), 4.4, [a])[0]], "N" if j in (2, 10) else "s", "fire",
              names=["Vermilion Wing (Chu Dực)"] if j in (2, 10) else None)
    T.end()
    landkit.figure_at(T, P(51.2, 0), "lotus", "fire", k=1.35, names=["True Flame (Chân Hỏa)", "Sun Essence (Thái Dương Tinh)", "Vermilion Wing (Chu Dực)"],
                      name="Fire Lotus", enter=J[2][0], leave=J[3][0], form="lotus (pass-through)")
    bird = landkit.figure_at(T, P(64.6, 0), "phoenix", "phoenix", k=1.45, names=["Phoenix Blood (Phượng Huyết)", "Rise From Ash (Dục Hỏa)", "Undying Ember (Bất Diệt Tro)"],
                             name="Vermilion Bird (Chu Tước)", enter=J[3][0], leave=J[4][0], form="phoenix (pass-through)")
    apex = T.junction(P(74.4, 0), road="hoa")
    T.link(J[4][0], apex, kind="highway")
    T.port("light", apex)
    # ---- Blaze (left) and Alchemy (right) ------------------------------------------------------------------------
    pens.place_in(T, P(37.6, -16.6), "flame", "blaze", k=1.25, names=["Spreading Flames (Liệu Nguyên)", "Searing Will (Chước Ý)"], ang=-16, name="Flame Tongues")
    pens.place_in(T, P(37.6, 16.6), "cauldron", "alchemy", k=1.15, names=["Nine Turns (Cửu Chuyển)", "Fire Control (Khống Hỏa)", "Pill Heart (Đan Tâm)"], ang=16, name="Pill Cauldron (Đan Lô)")
    # set piece: the Wildfire Star, a burning star with flame tongues licking from its points
    landkit.constellation(T, P(51.6, -15.8), "star", "blaze", k=1.2, ang=-16, names=["Ash Remains (Tro Tàn)", "Wildfire (Dã Hỏa)", "Searing Will (Chước Ý)"],
                          name="Wildfire Star (Dã Hỏa Tinh)", sats=[("flame", "blaze", ["Spreading Flames (Liệu Nguyên)"]), ("flame", "fire", ["True Flame (Chân Hỏa)"])], sat_k=0.62)
    pens.place_in(T, P(51.6, 16.0), "spiral", "alchemy", k=1.25, names=["Nine Turns (Cửu Chuyển)", "Elixir Field (Đan Điền Dưỡng)"], ang=16, name="Nine-Turn Spiral (Cửu Chuyển)")
    pens.place_in(T, P(64.8, -15.2), "flame", "blaze", k=1.45, names=["Wildfire (Dã Hỏa)", "Spreading Flames (Liệu Nguyên)"], ang=-15, name="Wildfire")
    # set piece: the Alchemist's Hall, a great cauldron with elixir gourds and herb flowers hung round it
    landkit.constellation(T, P(64.6, 15.2), "cauldron", "alchemy", k=1.3, ang=15, names=["Nine Turns (Cửu Chuyển)", "Medicine King's Hand (Dược Vương Thủ)", "Pill Heart (Đan Tâm)"],
                          name="Alchemist's Hall (Đan Các)", sats=[("hourglass", "alchemy", ["Elixir Field (Đan Điền Dưỡng)"]), ("rosette", "alchemy", ["Fire Control (Khống Hỏa)"]),
                                                                 ("lollipop", "lifespan", ["Crane's Age (Hạc Thọ)"])])
    # keystones out in the land: two dead-end spurs off ring 3
    landkit.keystone_spur(T, J[3][-12], 25, "ASH", "phoenix")
    landkit.keystone_spur(T, J[3][12], 40, "PILL", "alchemy")
    landkit.land_finish(T, CFG, roads, HALO)
