"""Wood land (Mộc), whole-tree pass 2026-11-08 night. Axis 288°.

The start web follows the Metal pilot (Spirit fields on Water's side, Beasts on Fire's side, the Green Dragon dome, a
Growth lane). The centre road grows like a plant: the World Tree in band 1 (hung off ring 1), the Twin Vines climbing
through band 2, and the Ancient Canopy, a great wheel with branches, in band 3. Fields run up Water's side (terraces,
an herb flower, a spirit-spring lotus), beasts up Fire's side (a paw print, an antler, a den). The lightning road from
Thunder runs just inside the rim on its way to Fire.
Coordinates (u, v): v outward along Wood's axis, u across, + toward Fire.
"""
import importlib.util
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens, common, landkit = _load("pens"), _load("common"), _load("landkit")
landkit.use(pens, common)

TITLE = "Wood Land (Mộc)"
START_NAME = "Wood start (Mộc)"
START_KEY = "wood"
AXIS = common.ELEM_AXIS["wood"]
HALF_ANGLE = common.LAND_HALF
HALO_EXTRA = 3        # small hidden clusters added in the band's widest gaps (rule 6: about 75 in all)
RIM = common.RIM
MIN_SPACING = 0.6
ROAD_MOD = common.ROAD_KINDS["moc"]["mod"]
ROAD_KINDS = common.ROAD_KINDS
THEMES = common.THEMES
KEYSTONES = {
    "SEED": {"name": "A Seed Waits (Chủng Tử Đãi Thời) [proposal]", "rule": "Unspent points grow: every ten levels, one becomes two.", "closes": "You cannot spend points in the realm you earn them"},
    "THORN": {"name": "Thorned Skin (Kinh Bì) [proposal]", "rule": "Foes that strike you take Wood damage back.", "closes": "Block rating is zero"},
    "ROOT": {"name": "Deep Roots (Thâm Căn) [proposal]", "rule": "Health regeneration is doubled while you have not moved this fight.",
             "closes": "Travel speed −30 %"},
    "PACK": {"name": "Beast Soul Union (Thú Hồn Hợp Thể) [effects.md]", "rule": "Your strongest companion's power share counts double.", "closes": "−1 art slot; only one companion fights with you"},
    "HARVEST": {"name": "Eternal Spring (Vạn Cổ Trường Xuân) [proposal]", "rule": "Herbs in your fields never wither.",
                "closes": "Field plots grow at half speed"},
}
WEB = {"key": "wood", "gate": "Gate of Wood", "left": "field", "right": "beast", "elem": "wood", "hubL": "Green Thumb (Lục Thủ)",
       "hubR": "Pack Leader (Đầu Đàn)", "top": "Green Dragon (Thanh Long)", "low_theme": "growth", "low": "Sap of Life (Sinh Dịch)",
       "cradle": ("lifespan", "insight", "health"), "keystone": "ROOT", "hub": (4.4, 22.3)}
CFG = {"left": "field", "right": "beast", "elem": "wood", "elem2": "growth", "half": HALF_ANGLE, "road": "moc", "lightning": False,
       "rings": [(-21, -13, 0, 13, 21), (-21, -9, 0, 9, 21), (-20, -12, 0, 12, 20), (-22, -9, 0, 9, 22)],
       "hub_to": (-13, 13), "centre_to": 0, "ring_r": common.LAND_RINGS["wood"], "straight": (2, 4),
       "ring_gaps": [(3, -20), (1, 0), (2, 9)], "dense": [(45.0, 6.5, 4.5), (62.0, -7.0, 4.5)], "landmark": {0: ("wood", "lotus"), 1: ("growth", "sun")},
       "quiet": [(57.0, 6.5, 4.2, ("sealed", "Beast Taming", "event", "Sealed: Spirit Deer Glade (Linh Lộc Cốc)", "lotus")), (44.0, -6.0, 3.8, ("open", "Spirit Fields", "story moment", "Open: Wild Herb Valley (Dã Thảo Cốc)", "lens"))],
       "outer_keys": [(2, 0, 50, "SEED", "growth"), (1, 13, 45, "THORN", "beast")],
       "ring_dr": {(2, 0): 1.3, (2, -9): -0.6, (2, 9): -0.6, (4, -9): 0.9, (4, 0): 0.9, (4, 9): 1.0, (3, 0): -1.1},
       "avenues": [(1, -13, 2, -9), (2, 9, 3, 12), (3, -12, 4, -9)], "spoke_gaps": ("e1",)}
HALO = [
    (-20.5, "sealed", "Spirit Fields", "item: a Meridian Seal", "Sealed: Garden of a Hundred Herbs (Bách Thảo Viên)", "lotus"),
    (-16.8, "open", "Spirit Fields", "story moment", "Open: Abandoned Medicine Valley (Phế Dược Cốc)", "window"),
    (-5, "sealed", "Longevity", "cultivation technique", "Sealed: Ten-Thousand-Year Tree (Vạn Niên Thụ)", "gourd2"),
    (8.5, "sealed", "Beast Taming", "event", "Sealed: Qilin's Den (Kỳ Lân Huyệt)", "drum"),
    (12.3, "open", "Beast Taming", "story moment", "Open: Beast Tide (Thú Triều)", "concentric"),
    (21, "sealed", "Heart State", "item: a Meridian Seal", "Sealed: Zen of the Bamboo (Trúc Thiền)", "pagoda"),

    (1.8, 'sealed', 'Spirit Fields', 'item: a Meridian Seal', 'Sealed: Seed Vault (Chủng Khố)', 'concentric'),
]


def build(T):
    P = T.P
    w = landkit.web(T, WEB)
    roads = landkit.land_roads(T, CFG, w)
    J = roads["J"]
    # ---- centre: World Tree, Twin Vines, Ancient Canopy ------------------------------------------------------------
    pens.pict(T, J[1][0], 0, "tree", "wood", k=1.45, names=["Ancient Root (Cổ Căn)", "Green Dragon (Thanh Long)"], name="World Tree (Kiến Mộc)", fit=False)
    landkit.figure_at(T, P(51.3, 0), "vine", "growth", k=1.4, names=["Endless Spring (Sinh Sinh Bất Tức)", "Sap of Life (Sinh Dịch)"],
                      name="Twin Vines", enter=J[2][0], leave=J[3][0], form="vines (pass-through)")
    can = landkit.wheel(T, P(64.4, 0), 3.2, 14, "wood", notables=(4, 10), names=["Thorn Forest (Kinh Lâm)", "Spring Thunder Wakes (Xuân Lôi)"],
                        name="Ancient Canopy", form="great wheel")
    T.road([J[3][0], can[0]], step=3.0, road="moc")
    T.road([can[7], J[4][0]], step=3.0, road="moc")
    T.cur = T.nodes[can[0]]["cluster"]
    for j in (2, 5, 9, 12):
        a = 180 + 360 * j / 14
        T.run(can[j], [pens.circ(P(64.4, 0), 4.5, [a])[0]], "N" if j in (5, 9) else "s", "growth",
              names=["Evergreen (Thường Xanh)"] if j in (5, 9) else None)
    T.end()
    # ---- Fields (left) and Beasts (right) --------------------------------------------------------------------------
    pens.place_in(T, P(37.6, -16.4), "terrace", "field", k=1.25, names=["Fertile Plot (Phì Điền)", "Green Thumb (Lục Thủ)"], ang=-16, name="Rice Terraces")
    pens.place_in(T, P(37.6, 16.4), "paw", "beast", k=1.3, names=["Wild Heart (Dã Tâm)", "Pack Leader (Đầu Đàn)"], ang=16, name="Paw Print")
    # set piece: the Herb Garden, a great lotus with small herb flowers planted round it
    landkit.constellation(T, P(51.6, -16.0), "lotus", "field", k=1.15, ang=-16, names=["Hundred Herbs (Bách Thảo)", "Rain at the Right Time (Mưa Thuận)", "Green Thumb (Lục Thủ)"],
                          name="Herb Garden (Dược Viên)", sats=[("rosette", "field", ["Fertile Plot (Phì Điền)"]), ("rosette", "growth", ["Sap of Life (Sinh Dịch)"])], sat_k=0.62)
    pens.place_in(T, P(51.6, 16.0), "antler", "beast", k=1.45, names=["Spirit Tamer (Ngự Linh)", "Blood Pact (Huyết Khế)"], ang=16, name="Spirit Deer Antler")
    pens.place_in(T, P(64.0, -15.0), "lotus", "field", k=1.3, names=["Green Thumb (Lục Thủ)", "Fertile Plot (Phì Điền)", "Hundred Herbs (Bách Thảo)"], ang=-15, name="Spirit Spring Lotus")
    # set piece: the Beast Den, a great paw print with a stag's antlers and a smaller track beside it
    landkit.constellation(T, P(64.0, 15.0), "paw", "beast", k=1.5, ang=15, names=["Pack Leader (Đầu Đàn)", "Wild Heart (Dã Tâm)"],
                          name="Beast Den (Thú Huyệt)", sats=[("antler", "beast", ["Spirit Tamer (Ngự Linh)", "Blood Pact (Huyết Khế)"]), ("antler", "beast", ["Blood Pact (Huyết Khế)", "Wild Heart (Dã Tâm)"]),
                                                            ("paw", "beast", ["Pack Leader (Đầu Đàn)"])], sat_k=0.7)
    landkit.keystone_spur(T, J[3][-12], -35, "HARVEST", "field")
    landkit.keystone_spur(T, J[3][12], 35, "PACK", "beast")
    landkit.land_finish(T, CFG, roads, HALO)
