"""Earth land (Thổ), whole-tree pass 2026-11-08 night. Axis 72°.

Earth has no centre road: its land is held by two avenues and big still figures, as a mountain range would be. The
start web follows the Metal pilot (Mountain body on Fire's side, Formations on Metal's side, the Thick Earth dome, a
Weight lane). Band 1 holds the Nine Palaces (a three-by-three array) between a shield and an array eye; band 2 the
Five Peaks (山) between twin peaks and the Nine Palaces; band 3 the Black Tortoise, the Altar of Earth (concentric
rings) and the Grand Array (bagua). The Darkness island's shadow road comes down beyond the rim on Metal's side.
Coordinates (u, v): v outward along Earth's axis, u across, + toward Metal.
"""
import importlib.util
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Earth Land (Thổ)"
START_NAME = "Earth start (Thổ)"
START_KEY = "earth"
AXIS = common.ELEM_AXIS["earth"]
HALF_ANGLE = common.LAND_HALF
HALO_EXTRA = 3        # small hidden clusters added in the band's widest gaps (rule 6: about 75 in all)
RIM = common.RIM
MIN_SPACING = 0.6
RIM_WAVE = []   # bays in the rim (judge round 6: vary the overhang)
ROAD_MOD = common.ROAD_KINDS["tho"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "QUAKE": {"name": "Earth Shaker (Địa Chấn) [proposal]", "rule": "Every third Earth art shakes the ground under every foe.", "closes": "Art speed −20 %"},
    "VEIL": {"name": "Array Within the Body (Thể Nội Trận) [proposal]", "rule": "Your strongest formation's power also wards you.", "closes": "Formations cost twice the upkeep"},
    "STILL": {"name": "Immovable (Bất Động) [proposal]", "rule": "You cannot be moved, slowed or stunned, and you take less damage while standing your ground.",
              "closes": "Evasion is always zero"},
    "ARRAY": {"name": "Formation Within a Formation (Trận Trung Trận) [effects.md]", "rule": "Your formations may exceed their maximum by 2 levels.", "closes": "Upkeep for those levels × 2"},
    "BACK": {"name": "Mountain's Back (Sơn Bối) [proposal]", "rule": "Block also stops arts and treasures.",
             "closes": "Art speed is halved"},
}
WEB = {"key": "earth", "gate": "Gate of Earth", "left": "mountain", "right": "formation", "elem": "earth", "hubL": "Bedrock (Bàn Thạch)",
       "hubR": "Array Eye (Trận Nhãn)", "top": "Thick Earth (Hậu Thổ)", "low_theme": "gravity", "low": "Rooted Feet (Trát Căn)",
       "cradle": ("heart", "lifespan", "ward"), "keystone": "STILL", "hub": (4.6, 22.2)}
CFG = {"left": "mountain", "right": "formation", "elem": "earth", "elem2": "gravity", "half": HALF_ANGLE, "road": "tho",
       "rings": [(-21, -7, 0, 7, 21), (-21, -13, 0, 13, 21), (-20, -7, 7, 20), (-22, -11, 0, 11, 22)],
       "hub_to": (-7, 7), "centre_to": 0, "ring_r": common.LAND_RINGS["earth"], "straight": (2,),
       "ring_gaps": [(3, -7), (1, 7)], "dense": [(45.0, 7.0, 4.5), (62.0, -6.0, 4.5)], "landmark": {0: ("earth", "drum"), 1: ("gravity", "concentric")},
       "quiet": [(58.0, 8.0, 4.2, ("sealed", "Way of Formations", "item: a Meridian Seal", "Sealed: Sunken Array (Trầm Trận)", "bagua")), (44.0, -6.5, 3.8, ("open", "Mountain body", "story moment", "Open: Hollow Mountain (Không Sơn)", "concentric"))],
       "outer_keys": [(1, -21, 45, "QUAKE", "earth"), (2, 13, 25, "VEIL", "formation")],
       "ring_dr": {(1, -7): 0.9, (1, 7): 0.9, (2, 0): 1.6, (2, -13): -0.5, (2, 13): -0.5, (3, -7): 1.2, (3, 7): 1.2, (4, -11): -1.2, (4, 0): 1.4, (4, 11): -0.8},
       "avenues": [(1, -7, 2, -13), (1, 7, 2, 13), (2, -13, 3, -7)], "spoke_gaps": ("e2",)}
HALO = [
    (-20, "sealed", "Heart State", "event", "Sealed: Stone Buddha's Patience (Thạch Phật Nhẫn)", "lotus"),
    (-16.3, "sealed", "Way of Formations", "item: a Meridian Seal", "Sealed: Heaven-Locking Array (Tỏa Thiên Trận)", "bagua"),
    (1, "open", "Mountain body", "story moment", "Open: Sleeping Mountain God (Thụy Sơn Thần)", "concentric"),
    (4.7, "sealed", "Longevity", "cultivation technique", "Sealed: Thousand-Year Tortoise (Thiên Niên Quy)", "gourd2"),
    (10.5, "open", "Way of Formations", "story moment", "Open: Ruined Array Hall (Phế Trận Điện)", "window"),

    (-5.8, 'sealed', 'Longevity', 'event', 'Sealed: Stone Crane (Thạch Hạc)', 'gourd2'),
]


def build(T):
    P = T.P
    w = landkit.web(T, WEB)
    roads = landkit.land_roads(T, CFG, w)
    J = roads["J"]
    # ---- centre: the Nine Palaces, the Five Peaks, the Altar of Earth --------------------------------------------
    pal = landkit.figure_at(T, P(37.4, 0), "window", "formation", k=1.4, ang=45, names=["Nine Palaces (Cửu Cung)", "Grand Array Heart (Đại Trận Tâm)"],
                            name="Nine Palaces (Cửu Cung)", enter=J[1][0], form="nine palaces")
    T.attach(J[2][0], pal)
    landkit.figure_at(T, P(51.3, 0), "shan", "earth", k=1.55, names=["Landslide (Sơn Băng)", "Thick Earth (Hậu Thổ)", "Yellow Springs (Hoàng Tuyền)"],
                      name="Five Peaks (Ngũ Nhạc)", enter=J[2][0], form="山 (pass-through)")
    altar = landkit.figure_at(T, P(64.3, 0), "concentric", "earth", k=1.35, names=["Loess Plain (Hoàng Thổ)", "Thick Earth (Hậu Thổ)"],
                              name="Altar of Earth (Xã Tắc Đàn)", enter=J[4][0], form="altar")
    # ---- Mountain body (left) and Formations (right) ---------------------------------------------------------------
    pens.place_in(T, P(37.6, -16.4), "shield", "mountain", k=1.3, names=["Immovable Mountain (Bất Động Sơn)", "Bedrock (Bàn Thạch)"], ang=-16, name="Stone Shield")
    pens.place_in(T, P(37.6, 16.4), "eye", "formation", k=1.2, names=["Array Eye (Trận Nhãn)"], ang=16, name="Array Eye")
    # set piece: the Twin Peaks, 山 with shields at its feet like foothill forts
    landkit.constellation(T, P(51.6, -16.0), "shan", "mountain", k=1.15, ang=-16, names=["Mountain Bears the Sky (Sơn Kháng Thiên)", "Bedrock (Bàn Thạch)", "Immovable Mountain (Bất Động Sơn)"],
                          name="Twin Peaks (Song Phong)", sats=[("shield", "mountain", ["Black Tortoise Shell (Huyền Quy Giáp)"]), ("kite", "gravity", ["Rooted Feet (Trát Căn)"])], sat_k=0.66)
    pens.place_in(T, P(51.6, 16.0), "theta", "formation", k=1.3, names=["Layered Arrays (Trùng Trận)", "Eight Gates (Bát Môn)"], ang=16, name="Locked Gate")
    pens.place_in(T, P(64.6, -14.6), "turtle", "mountain", k=1.35, names=["Black Tortoise Shell (Huyền Quy Giáp)", "Bedrock (Bàn Thạch)", "Mountain Bears the Sky (Sơn Kháng Thiên)"], ang=-15, name="Black Tortoise (Huyền Vũ)")
    # set piece: the Grand Array, a bagua disc with array flags planted at its spurs
    landkit.constellation(T, P(64.6, 14.6), "bagua", "formation", k=1.3, ang=15, names=["Eight Gates (Bát Môn)", "Nine Palaces (Cửu Cung)", "Grand Array Heart (Đại Trận Tâm)"],
                          name="Grand Array (Đại Trận)", sats=[("arrow", "formation", ["Array Eye (Trận Nhãn)"]), ("arrow", "formation", ["Layered Arrays (Trùng Trận)"]),
                                                             ("kite", "ward", ["Golden Bell (Kim Chung Tráo)"])], sat_k=0.68)
    landkit.keystone_spur(T, J[3][-7], -30, "BACK", "mountain")
    landkit.keystone_spur(T, J[3][7], 30, "ARRAY", "formation")
    # the shadow road from the Darkness island comes down here
    # (round 11: a separate port junction beside ring 4 read as a doubled road; the shadow road now lands on ring 4)
    T.port("shadow", J[4][22])
    T.reserved += [(P(72.6, 21.2), 1.9), (P(75.4, 21.8), 1.6)]    # the shadow road's last leg comes in here
    landkit.land_finish(T, CFG, roads, HALO)
