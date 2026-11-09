"""Water land (Thủy), whole-tree pass 2026-11-08 night. Axis 216°.

The start web follows the Metal pilot (Tide on Metal's side, Talismans on Wood's side, the Deep Abyss dome, a Soft
Water lane). The centre road climbs to the Ice start (decision 6: Ice starts on Water's road, out from Water's start):
a great snowflake with the Ice start at its hub, Ice's own district. Above it the Moon Pool (concentric rings) and a
pair of koi circling each other. Tide's figures run up Metal's side (whirlpool, wave), the talismans up Wood's side
(talisman slips, a seal window). The lightning road from Thunder runs just inside the rim; the Darkness island's
bridge comes down onto it on Metal's side.
Coordinates (u, v): v outward along Water's axis, u across, + toward Wood.
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Water Land (Thủy)"
START_NAME = "Water start (Thủy)"
START_KEY = "water"
AXIS = common.ELEM_AXIS["water"]
HALF_ANGLE = common.LAND_HALF
HALO_EXTRA = 3        # small hidden clusters added in the band's widest gaps (rule 6: about 75 in all)
RIM = common.RIM
MIN_SPACING = 0.6
ROAD_MOD = common.ROAD_KINDS["thuy"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "UNDERTOW": {"name": "Undertow (Ám Lưu) [proposal]", "rule": "Foes you push back are pulled toward you again a moment later.",
                 "closes": "You cannot be pushed, and cannot push"},
    "MIRROR": {"name": "Flowers in the Mirror (Kính Hoa Thủy Nguyệt) [proposal]", "rule": "Your talismans leave an echo that casts again at half power.", "closes": "You cannot carry more than three kinds of talisman"},
    "ABYSS": {"name": "Silence of the Abyss (Uyên Tĩnh) [proposal]", "rule": "Linh lực regeneration counts double while you have not attacked this pulse.", "closes": "Attack speed −25 %"},
    "FLOW": {"name": "Water Takes No Shape (Thủy Vô Thường Hình) [proposal]", "rule": "Your ward and your health are one pool: damage to either drains both evenly.",
             "closes": "Body shield is always zero"},
    "SLIP": {"name": "Thousand Slips (Thiên Phù) [proposal]", "rule": "Talismans you use are cast twice.",
             "closes": "Talismans cost twice as much to draw"},
    "GLACIER": {"name": "Ten-Thousand-Year Glacier (Vạn Niên Huyền Băng) [proposal]", "rule": "Your Ice arts freeze the foe's linh lực regeneration.",
                "closes": "Your own linh lực regeneration is halved"},
    "FROST": {"name": "Heart of Ice (Băng Tâm Quyết) [proposal]", "rule": "You cannot gain heart demon while your health is full.",
              "closes": "Healing received is halved"},
}
WEB = {"key": "water", "gate": "Gate of Water", "left": "tide", "right": "talisman", "elem": "water", "hubL": "Rising Tide (Triều Dâng)",
       "hubR": "Cinnabar Brush (Chu Sa Bút)", "top": "Deep Abyss (Thâm Uyên)", "low_theme": "tide", "low": "Soft Water (Nhu Thủy)",
       "cradle": ("insight", "health", "linh"), "keystone": "FLOW", "hub": (4.1, 22.6)}
CFG = {"left": "tide", "right": "talisman", "elem": "water", "elem2": "ice", "half": HALF_ANGLE, "road": "thuy", "lightning": False,
       "rings": [(-21, -12, 0, 12, 21), (-21, -11, 0, 11, 21), (-20, -10, 0, 10, 20), (-22, -10, 0, 10, 22)],
       "hub_to": (-12, 12), "centre_to": 0, "ring_r": common.LAND_RINGS["water"], "straight": (4,), "ring_dr": {(4, -10): 0.9, (4, 0): -1.4, (4, 10): 0.7, (3, -10): -1.0, (3, 10): 1.1},
       "ring_gaps": [(3, 0), (2, 11), (1, 0)], "dense": [(44.0, -8.0, 4.5), (62.0, 6.0, 4.5)], "landmark": {0: ("water", "concentric"), 1: ("ice", "flake")},
       "quiet": [(57.0, -6.5, 4.2, ("sealed", "Way of Talismans", "cultivation technique", "Sealed: Ink Pool (Mặc Trì)", "concentric")), (44.0, 7.5, 3.8, ("open", "Tide", "story moment", "Open: Drowned Pagoda (Trầm Tháp)", "pagoda"))],
       "outer_keys": [(1, 12, 45, "MIRROR", "talisman"), (4, 0, 180, "UNDERTOW", "tide")],
       "avenues": [(1, -12, 2, -11), (3, 10, 4, 10)], "spoke_gaps": ("w3",)}
DARK_A, DARK_GATE_R = -10, 74.8     # where the Darkness bridge lands (world 206°)
HALO_AVOID = [(-15.0, -5.0)]       # the bridge's corridor through the hidden band
HALO = [
    (1.0, "open", "Tide", "story moment", "Open: Moon-Drawn Sea (Nguyệt Triều Hải)", "concentric"),
    # either side of the Darkness bridge (2026-11-09: it now comes in square to the rim, leaving room here)
    (-4.6, "open", "Tide", "story moment", "Open: Sunken Bell (Trầm Chung)", "eye"),
    (-16.0, "sealed", "Divine Sense", "event", "Sealed: Night Ferry (Dạ Độ)", "fish"),
    (7, "sealed", "Divine Sense", "cultivation technique", "Sealed: Dragon King's Pearl (Long Vương Châu)", "eye"),
    (10.8, "sealed", "Way of Talismans", "item: a Meridian Seal", "Sealed: Heaven Script (Thiên Thư)", "window"),
    (20.5, "open", "Ice", "story moment", "Open: Frozen Sect (Băng Tông Di Chỉ)", "snowflake"),
    (23, "sealed", "Way of Talismans", "event", "Sealed: Drowned Library (Trầm Thư Các)", "seal"),

    (14.5, 'sealed', 'Heart State', 'cultivation technique', 'Sealed: Moon in the Well (Tỉnh Trung Nguyệt)', 'lotus'),
]


def build(T):
    P = T.P
    w = landkit.web(T, WEB)
    roads = landkit.land_roads(T, CFG, w)
    J = roads["J"]
    # the Darkness island's bridge comes in square to the rim (2026-11-09): a gate just inside the rim, straight out from
    # ring 4, with a clear corridor so the hidden band keeps room on both sides of the bridge
    dk = T.junction(P(DARK_GATE_R, DARK_A), road="thuy")
    T.road([J[4][DARK_A], dk], step=4.6, road="thuy", straight=True)
    T.port("dark", dk)
    T.reserved += [(P(r, DARK_A), 1.5) for r in (72.6, 74.8)]
    # ---- the Ice start: a great snowflake with the start at its hub ---------------------------------------------
    C = P(38.0, 0)
    T.cluster("Ice Flower (Băng Hoa)", "snowflake start", mastery=None)
    ice = T.node(C, "S", name="Ice start (Băng)", key="ice")
    T.end()
    arms = []
    T.cluster("Ice Flower (Băng Hoa)", "great snowflake", mastery=C)
    for k in range(6):
        a = 180 + 60 * k
        p1 = T.node(pens.circ(C, 1.3, [a])[0], "s", "ice")
        p2 = T.node(pens.circ(C, 2.6, [a])[0], "s", "ice")
        p3 = T.node(pens.circ(C, 3.9, [a])[0], "N" if k in (1, 3, 5) else "s", "ice")
        T.link(ice, p1); T.link(p1, p2); T.link(p2, p3)
        for s_ in (-1, 1):
            if k in (0, 3):
                continue
            tw = T.node(pens.circ(C, 3.2, [a + s_ * 22])[0], "s", "ice")
            T.link(p2, tw)
        arms.append((p1, p2, p3))
    T.end()
    landkit.keystone_spur(T, arms[2][2], 300, "GLACIER", "ice")
    T.link(J[1][0], arms[0][2])
    T.link(arms[3][2], J[2][0])
    # ---- the Moon Pool and the twin koi --------------------------------------------------------------------------
    landkit.figure_at(T, P(51.3, 0), "concentric", "water", k=1.45, names=["Dragon Pool (Long Đàm)", "Deep Abyss (Thâm Uyên)"],
                      name="Moon Pool (Nguyệt Trì)", enter=J[2][0], leave=J[3][0], form="moon pool (pass-through)")
    landkit.figure_at(T, P(64.3, -4.2), "fish", "water", k=1.3, ang=-25, names=["Ten Thousand Streams (Vạn Lưu)", "Black Water (Huyền Thủy)"],
                      name="Koi of the Deep", enter=J[3][0], form="koi")
    landkit.figure_at(T, P(64.3, 4.2), "fish", "water", k=1.3, ang=155, names=["Dragon Pool (Long Đàm)", "Deep Abyss (Thâm Uyên)"],
                      name="Koi of the Shallows", enter=J[4][0], form="koi")
    T.road([J[3][0], J[4][0]], step=4.0, road="thuy")
    # ---- Tide (left) and Talismans (right) -------------------------------------------------------------------------
    pens.place_in(T, P(37.6, -16.4), "spiral", "tide", k=1.25, names=["Returning Current (Hồi Lưu)", "Rising Tide (Triều Dâng)"], ang=-16, name="Whirlpool")
    pens.place_in(T, P(37.6, 16.4), "seal", "talisman", k=1.2, names=["Seal Script (Triện Văn)", "Cinnabar Brush (Chu Sa Bút)"], ang=16, name="Talisman Slip")
    # set piece: the Breaking Wave, with koi leaping from its crest
    landkit.constellation(T, P(51.6, -16.0), "wave", "tide", k=1.3, ang=-16, names=["Moon Draws the Sea (Nguyệt Dẫn Hải)", "Soft Water (Nhu Thủy)"],
                          name="Breaking Wave (Kinh Đào)", sats=[("fish", "water", ["Ten Thousand Streams (Vạn Lưu)"]), ("fish", "tide", ["Returning Current (Hồi Lưu)"])], sat_k=0.62)
    pens.place_in(T, P(51.6, 16.0), "window", "talisman", k=1.3, names=["Paper Army (Chỉ Binh)", "Heaven-Sealing Slip (Phong Thiên Phù)"], ang=16, name="Seal Window")
    pens.place_in(T, P(64.0, -15.0), "lens", "tide", k=1.3, names=["Rising Tide (Triều Dâng)", "Returning Current (Hồi Lưu)"], ang=-15, name="Tidal Lens")
    # set piece: a fan of talisman slips round the Great Talisman
    landkit.constellation(T, P(64.0, 15.0), "seal", "talisman", k=1.35, ang=15, names=["Heaven-Sealing Slip (Phong Thiên Phù)", "Seal Script (Triện Văn)"],
                          name="Great Talisman (Đại Phù)", sats=[("seal", "talisman", ["Paper Army (Chỉ Binh)"]), ("seal", "talisman", ["Cinnabar Brush (Chu Sa Bút)"])], sat_k=0.66)
    landkit.keystone_spur(T, J[3][-10], -35, "FROST", "ice")
    landkit.keystone_spur(T, J[3][10], 35, "SLIP", "talisman")
    landkit.land_finish(T, CFG, roads, HALO)
