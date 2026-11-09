"""Shared geometry, themes and road kinds for the whole Kinh Mạch Đồ (2026-11-08 night, whole-tree pass).

Every land is drawn in its own frame (see kit.py); these numbers keep the lands' rings and ports lined up so that
build_tree.py can join them. Theme banks hold placeholder content: names and plain modifiers priced by kit.STATS.
Content is not final (the user asked for the layout first).
"""

# ---- geometry (zoning plan draft 4, Metal pilot) -----------------------------------------------------------------
ELEM_AXIS = {"fire": 0, "earth": 72, "metal": 144, "water": 216, "wood": 288}
BLEND_AXIS = {"fe": 36, "em": 108, "mw": 180, "ww": 252, "wf": 324}
LAND_HALF, BLEND_HALF = 23, 12.4
START_R = 17.0
RINGS = [30.5, 44.5, 58.5, 70.0]
# each land keeps its own ring radii, so the rings never line up into one dartboard (whole-tree review, 2026-11-09);
# the blend zones carry each ring from one neighbour's radius to the other's on a bent, straight-sided road
LAND_RINGS = {"metal": [30.5, 44.5, 58.5, 70.0], "fire": [31.6, 45.6, 59.2, 70.6], "earth": [29.4, 43.2, 57.4, 69.0],
              "water": [31.0, 45.2, 58.0, 69.6], "wood": [29.8, 43.8, 59.4, 69.4]}
BLEND_LANDS = {"fe": ("fire", "earth"), "em": ("earth", "metal"), "mw": ("metal", "water"), "ww": ("water", "wood"), "wf": ("wood", "fire")}
RIM = 76.0
HALO = (77.0, 83.0)          # the hidden band beyond the rim: sealed and open clusters (Kinh Mạch Đồ rules 6-13)
LIGHTNING_R = 73.6           # the lightning roads run just inside the rim through Wood and Water (zoning draft 3)
HUB_R = 9.9                  # the centre hub (Đan Điền) is drawn inside this radius
ISLAND_R = 93.0              # Light, Darkness and Thunder islands sit outside the circle at this radius

# ---- talents on the roads (open point 4, provisional) -------------------------------------------------------------
# PoE's travel nodes pay attributes. Ours pay innate talents (Character Stats: ngộ tính, căn cốt, thần hồn, khí vận,
# đạo tâm, mị lực), one per element by the five-phase organs and virtues: Metal = lungs and the corporeal soul ->
# physique; Water = wisdom -> comprehension; Fire = the heart that houses the spirit -> soul strength; Earth = faith
# and intent -> Dao heart; Wood = growth and spring -> fortune. Charm sits on the pick-one roads of the centre.
ROAD_KINDS = {
    "kim": {"name": "Metal road (Kim mạch)", "mod": [("can_cot", "", 1.0)]},
    "thuy": {"name": "Water road (Thủy mạch)", "mod": [("ngo_tinh_t", "", 1.0)]},
    "hoa": {"name": "Fire road (Hỏa mạch)", "mod": [("than_hon", "", 1.0)]},
    "tho": {"name": "Earth road (Thổ mạch)", "mod": [("dao_tam", "", 1.0)]},
    "moc": {"name": "Wood road (Mộc mạch)", "mod": [("khi_van", "", 1.0)]},
    "hub": {"name": "Dantian road (Đan Điền mạch)", "mod": [("any_talent", "", 1.0)]},
    "ring": {"name": "Ring road (Hoàn mạch)", "mod": [("any_talent", "", 1.0)]},
    "lightning": {"name": "Lightning road (Lôi lộ)", "mod": [("than_hon", "", 0.5), ("can_cot", "", 0.5)]},
    "shadow": {"name": "Shadow road (Ám lộ)", "mod": [("dao_tam", "", 0.5), ("ngo_tinh_t", "", 0.5)]},
    "light": {"name": "Radiant road (Quang lộ)", "mod": [("than_hon", "", 0.5), ("mi_luc", "", 0.5)]},
    "wind": {"name": "Wind road (Phong lộ)", "mod": [("khi_van", "", 0.5), ("ngo_tinh_t", "", 0.5)]},
}
BLEND_ROAD = {"fe": "hoa", "em": "tho", "mw": "kim", "ww": "thuy", "wf": "moc"}


def T_(label, kind, small_name, small, notables):
    return {"label": label, "kind": kind, "small_name": small_name, "small": small, "notables": notables}


BASE_THEMES = {
    "start": T_("Start", "start", "", [], []),
    "road": T_("Travel node", "road", "", [], []),
    "exit": T_("Leads elsewhere", "exit", "", [], []),
    "keystone": T_("Keystone", "keystone", "Path to a keystone", [("khi_huyet_pct", "", 1.0)], []),
    # universal themes (decision 10): scattered unevenly, near every start
    "health": T_("Health (Khí Huyết)", "universal", "Vitality", [("khi_huyet_pct", "", 1.0)],
                 [("Thick Blood (Huyết Hậu)", [("khi_huyet_pct", "", .7), ("health_regen_pct", "", .3)]),
                  ("Enduring Body (Nhẫn Thân)", [("khi_huyet_pct", "", .5), ("resist_pct", "", .5)]),
                  ("Vital Qi (Sinh Khí)", [("khi_huyet_pct", "", .6), ("body_shield_pct", "", .4)]),
                  ("Root of Life (Sinh Căn)", [("khi_huyet_pct", "", 1.0)]),
                  ("Blood Like Mercury (Huyết Như Thủy Ngân)", [("khi_huyet_pct", "", .5), ("health_regen_pct", "", .5)]),
                  ("Unbroken Marrow (Tủy Bất Đoạn)", [("khi_huyet_pct", "", .6), ("status_resist_pct", "", .4)])]),
    "linh": T_("Linh lực", "universal", "Spiritual power", [("linh_luc_pct", "", 1.0)],
               [("Deep Dantian (Thâm Đan)", [("linh_luc_pct", "", .7), ("linh_luc_regen_pct", "", .3)]),
                ("Flowing Qi (Lưu Khí)", [("linh_luc_pct", "", .5), ("art_cost_pct", "", .5)]),
                ("Full Sea of Qi (Khí Hải)", [("linh_luc_pct", "", 1.0)]),
                ("Still Pool (Tĩnh Trì)", [("linh_luc_pct", "", .5), ("ward_efficiency_pct", "", .5)]),
                ("Endless Spring (Tuyền Bất Tận)", [("linh_luc_regen_pct", "", .7), ("linh_luc_pct", "", .3)]),
                ("Breath of the Void (Hư Tức)", [("linh_luc_regen_pct", "", .5), ("art_cost_pct", "", .5)])]),
    "sense": T_("Thần thức", "universal", "Divine sense", [("than_thuc_pct", "", 1.0)],
                [("Spirit Sense (Linh Giác)", [("than_thuc_pct", "", .6), ("soul_res_pct", "", .4)]),
                 ("Sea of Consciousness (Thức Hải)", [("than_thuc_pct", "", 1.0)]),
                 ("Clear Eyes (Minh Mục)", [("than_thuc_pct", "", .5), ("accuracy_pct", "", .5)]),
                 ("Thousand-League Gaze (Thiên Lý Nhãn)", [("than_thuc_pct", "", .6), ("accuracy_pct", "", .4)]),
                 ("Spirit Net (Linh Võng)", [("than_thuc_pct", "", .7), ("soul_res_pct", "", .3)]),
                 ("Inner Eye (Nội Nhãn)", [("than_thuc_pct", "", .5), ("accuracy_pct", "", .5)]),
                 ("Listening to the Wind (Thính Phong)", [("than_thuc_pct", "", .6), ("soul_res_pct", "", .4)])]),
    "ward": T_("Ward (Hộ Thể)", "universal", "Guarding qi", [("defense_pct", "", 1.0)],
               [("Layered Guard (Trùng Hộ)", [("defense_pct", "", .6), ("ward_efficiency_pct", "", .4)]),
                ("Steady Ward (Ổn Hộ)", [("ward_efficiency_pct", "", .6), ("resist_pct", "", .4)]),
                ("Bright Shell (Quang Xác)", [("defense_pct", "", .5), ("status_resist_pct", "", .5)]),
                ("Golden Bell (Kim Chung Tráo)", [("defense_pct", "", .7), ("block_rating", "", .3)]),
                ("Turtle Shell (Quy Giáp)", [("defense_pct", "", .6), ("block_rating", "", .4)]),
                ("Iron Cloth Robe (Thiết Bố Sam)", [("defense_pct", "", .7), ("resist_pct", "", .3)]),
                ("Mist Veil (Vụ Sa)", [("ward_efficiency_pct", "", .6), ("status_resist_pct", "", .4)])]),
    "crit": T_("Crit (offence)", "universal", "Keen eye", [("crit_chance_pct", "", 1.0)],
               [("Fatal Point (Tử Huyệt)", [("crit_chance_pct", "", .5), ("crit_damage_pct", "", .5)]),
                ("Seeking the Flaw (Tầm Khuyết)", [("crit_chance_pct", "", .6), ("accuracy_pct", "", .4)]),
                ("Heavy Blow (Trọng Kích)", [("crit_damage_pct", "", .7), ("attack_pct", "", .3)]),
                ("One Thought, One Kill (Nhất Niệm Sát)", [("crit_chance_pct", "", .4), ("attack_pct", "", .6)]),
                ("Through the Seam (Xuyên Phùng)", [("crit_chance_pct", "", .6), ("accuracy_pct", "", .4)]),
                ("Breaking Point (Phá Điểm)", [("crit_damage_pct", "", .6), ("crit_chance_pct", "", .4)]),
                ("Hawk's Eye (Ưng Nhãn)", [("accuracy_pct", "", .5), ("crit_chance_pct", "", .5)])]),
    "lifespan": T_("Lifespan (Thọ Nguyên)", "universal", "Long breath", [("lifespan_pct", "", 1.0)],
                   [("Long Years (Trường Thọ)", [("lifespan_pct", "", 1.0)]),
                    ("Late Autumn (Thu Muộn)", [("lifespan_pct", "", .6), ("cultivation_speed_pct", "", .4)]),
                    ("Crane's Age (Hạc Thọ)", [("lifespan_pct", "", .7), ("health_regen_pct", "", .3)]),
                    ("Pine and Cypress (Tùng Bách)", [("lifespan_pct", "", .7), ("health_regen_pct", "", .3)]),
                    ("Turtle Breath (Quy Tức)", [("lifespan_pct", "", .6), ("cultivation_speed_pct", "", .4)]),
                    ("Ever-Burning Lamp (Trường Minh Đăng)", [("lifespan_pct", "", .8), ("health_regen_pct", "", .2)]),
                    ("Springs and Autumns (Xuân Thu)", [("lifespan_pct", "", .5), ("cultivation_speed_pct", "", .5)])]),
    "heart": T_("Heart (Tâm Cảnh)", "universal", "Calm heart", [("tam_ma_resist_pct", "", 1.0)],
                [("Still Heart (Tĩnh Tâm)", [("tam_ma_resist_pct", "", .7), ("status_resist_pct", "", .3)]),
                 ("Unmoved Mind (Bất Động Tâm)", [("tam_ma_resist_pct", "", .5), ("soul_res_pct", "", .5)]),
                 ("Bright Mirror Heart (Minh Kính Tâm)", [("tam_ma_resist_pct", "", .6), ("ngo_tinh", "", .4)]),
                 ("Lotus from the Mud (Xuất Nê Liên)", [("tam_ma_resist_pct", "", .6), ("status_resist_pct", "", .4)]),
                 ("Empty Boat (Hư Chu)", [("tam_ma_resist_pct", "", .5), ("soul_res_pct", "", .5)]),
                 ("Heart Like Still Water (Tâm Như Chỉ Thủy)", [("tam_ma_resist_pct", "", .8), ("ngo_tinh", "", .2)])]),
    "insight": T_("Comprehension (Ngộ Đạo)", "universal", "Glimmer of insight", [("ngo_tinh", "", 1.0)],
                  [("Sudden Insight (Đốn Ngộ)", [("ngo_tinh", "", .6), ("breakthrough_chance", "", .4)]),
                   ("Reading the Dao (Quan Đạo)", [("ngo_tinh", "", .5), ("cultivation_speed_pct", "", .5)]),
                   ("Listening to the Rain (Thính Vũ)", [("ngo_tinh", "", .7), ("tam_ma_resist_pct", "", .3)]),
                   ("Moon in the Water (Thủy Nguyệt)", [("ngo_tinh", "", .6), ("tam_ma_resist_pct", "", .4)]),
                   ("Ten Thousand Scrolls (Vạn Quyển)", [("ngo_tinh", "", .5), ("cultivation_speed_pct", "", .5)]),
                   ("The Lamp Passed On (Truyền Đăng)", [("ngo_tinh", "", .6), ("breakthrough_chance", "", .4)])]),
}

ELEMENT_THEMES = {
    # ---- Metal (Kim): copied from the Metal pilot (regions/metal.py) so neighbours can use them ----
    "sword": {"label": "Sword intent (Kiếm Ý)", "kind": "identity", "small_name": "Sword intent", "small": [("attack_pct", "sword", 1.0)],
              "notables": [("Sword Heart (Kiếm Tâm)", [("attack_pct", "sword", .5), ("crit_chance_pct", "sword", .5)]),
                           ("Thousand Edges (Thiên Phong)", [("attack_pct", "sword", .6), ("art_speed_pct", "sword", .4)]),
                           ("Unsheathed (Xuất Vỏ)", [("crit_damage_pct", "sword", .6), ("attack_pct", "sword", .4)]),
                           ("Edge Follows Will (Kiếm Tùy Ý)", [("art_cost_pct", "sword", .5), ("art_speed_pct", "sword", .5)]),
                           ("Severing Light (Đoạn Quang)", [("resist_pen_pct", "physical", .5), ("attack_pct", "sword", .5)]),
                           ("Flying Sword (Phi Kiếm)", [("artifact_attack_pct", "weapon", .5), ("attack_pct", "sword", .5)]),
                           ("One Cut (Nhất Trảm)", [("crit_damage_pct", "sword", .5), ("accuracy_pct", "", .5)]),
                           ("Sword Qi Crosses (Kiếm Khí Tung Hoành)", [("attack_pct", "sword", .7), ("pierce_pct", "", .3)])]},
    "refining": {"label": "Refining (Luyện Khí)", "kind": "identity", "small_name": "Refiner's touch", "small": [("artifact_power_pct", "", 1.0)],
                 "notables": [("Furnace Hand (Lô Thủ)", [("refining_success", "", .6), ("artifact_power_pct", "", .4)]),
                              ("Tempered Ore (Tôi Khoáng)", [("artifact_power_pct", "", .6), ("refine_grade_chance", "", .4)]),
                              ("Spirit Etching (Khắc Linh)", [("artifact_attack_pct", "weapon", .5), ("than_thuc_cost_pct", "", .5)]),
                              ("Life-Bound Treasure (Bản Mệnh Pháp Bảo)", [("artifact_power_pct", "", .5), ("than_thuc_pct", "", .5)]),
                              ("Refined Edge (Tinh Phong)", [("artifact_attack_pct", "weapon", .6), ("attack_pct", "sword", .4)]),
                              ("Ore Sense (Thức Khoáng)", [("refining_success", "", .5), ("than_thuc_pct", "", .5)])]},
    "metal": {"label": "Metal element (Kim)", "kind": "element", "small_name": "Metal qi", "small": [("attack_pct", "kim", 1.0)],
              "notables": [("Autumn Killing Qi (Thu Sát Khí)", [("attack_pct", "kim", .6), ("crit_chance_pct", "kim", .4)]),
                           ("Piercing Gold (Xuyên Kim)", [("resist_pen_pct", "physical", .5), ("attack_pct", "kim", .5)]),
                           ("Metal Bones (Kim Cốt)", [("attack_pct", "kim", .5), ("element_affinity_pct", "", .5)]),
                           ("White Gold Edge (Bạch Kim Phong)", [("attack_pct", "kim", .6), ("art_speed_pct", "kim", .4)])]},
    "body": {"label": "Iron body (Metal defence)", "kind": "element", "small_name": "Iron skin", "small": [("block_rating", "", 1.0)],
             "notables": [("Gold Skin (Kim Bì)", [("body_shield_pct", "", .5), ("resist_pct", "physical", .5)]),
                          ("Iron Spine (Thiết Cốt)", [("block_rating", "", .5), ("khi_huyet_pct", "", .5)]),
                          ("Cast Iron Frame (Thiết Khung)", [("resist_pct", "physical", .6), ("block_rating", "", .4)]),
                          ("Hard as Iron (Cương Ngạnh)", [("body_shield_pct", "", .6), ("health_regen_pct", "", .4)])]},
    # ---- Fire (Hỏa): alchemy and blaze, the element, phoenix rebirth (sustain) ----
    "alchemy": T_("Alchemy (Đan Đạo)", "identity", "Furnace sense", [("alchemy_success", "", 1.0)],
                  [("Pill Heart (Đan Tâm)", [("alchemy_success", "", .6), ("pill_quality", "", .4)]),
                   ("Nine Turns (Cửu Chuyển)", [("pill_quality", "", .7), ("alchemy_success", "", .3)]),
                   ("Fire Control (Khống Hỏa)", [("alchemy_success", "", .5), ("dot_pct", "hoa", .5)]),
                   ("Medicine King's Hand (Dược Vương Thủ)", [("alchemy_success", "", .5), ("heal_pct", "", .5)]),
                   ("Elixir Field (Đan Điền Dưỡng)", [("pill_quality", "", .5), ("lifespan_pct", "", .5)])]),
    "blaze": T_("Blaze (Liệt Diễm)", "identity", "Smoulder", [("dot_pct", "hoa", 1.0)],
                [("Spreading Flames (Liệu Nguyên)", [("dot_pct", "hoa", .7), ("art_speed_pct", "hoa", .3)]),
                 ("Ash Remains (Tro Tàn)", [("dot_pct", "hoa", .5), ("attack_pct", "hoa", .5)]),
                 ("Searing Will (Chước Ý)", [("dot_pct", "hoa", .6), ("resist_pen_pct", "fire", .4)]),
                 ("Wildfire (Dã Hỏa)", [("dot_pct", "hoa", .5), ("art_cost_pct", "hoa", .5)])]),
    "fire": T_("Fire element (Hỏa)", "element", "Fire qi", [("attack_pct", "hoa", 1.0)],
               [("True Flame (Chân Hỏa)", [("attack_pct", "hoa", .6), ("crit_chance_pct", "hoa", .4)]),
                ("Sun Essence (Thái Dương Tinh)", [("attack_pct", "hoa", .5), ("element_affinity_pct", "", .5)]),
                ("Burning Heaven (Phần Thiên)", [("attack_pct", "hoa", .5), ("resist_pen_pct", "fire", .5)]),
                ("Vermilion Wing (Chu Dực)", [("attack_pct", "hoa", .6), ("art_speed_pct", "hoa", .4)])]),
    "phoenix": T_("Rebirth (Niết Bàn)", "element", "Ember of life", [("health_regen_pct", "", 1.0)],
                  [("Rise From Ash (Dục Hỏa)", [("health_regen_pct", "", .6), ("khi_huyet_pct", "", .4)]),
                   ("Phoenix Blood (Phượng Huyết)", [("heal_pct", "", .6), ("health_regen_pct", "", .4)]),
                   ("Undying Ember (Bất Diệt Tro)", [("health_regen_pct", "", .5), ("resist_pct", "fire", .5)])]),
    # ---- Earth (Thổ): formations and mountain body, the element, gravity ----
    "formation": T_("Formations (Trận Đạo)", "identity", "Array line", [("formation_power_pct", "", 1.0)],
                    [("Array Eye (Trận Nhãn)", [("formation_power_pct", "", .6), ("than_thuc_pct", "", .4)]),
                     ("Nine Palaces (Cửu Cung)", [("formation_power_pct", "", .7), ("defense_pct", "", .3)]),
                     ("Layered Arrays (Trùng Trận)", [("formation_power_pct", "", .5), ("ward_efficiency_pct", "", .5)]),
                     ("Eight Gates (Bát Môn)", [("formation_power_pct", "", .5), ("evade_pct", "", .5)]),
                     ("Grand Array Heart (Đại Trận Tâm)", [("formation_power_pct", "", 1.0)])]),
    "mountain": T_("Mountain body (Sơn Nhạc)", "identity", "Stone skin", [("block_rating", "", 1.0)],
                   [("Immovable Mountain (Bất Động Sơn)", [("block_rating", "", .5), ("resist_pct", "physical", .5)]),
                    ("Black Tortoise Shell (Huyền Quy Giáp)", [("body_shield_pct", "", .6), ("block_rating", "", .4)]),
                    ("Bedrock (Bàn Thạch)", [("khi_huyet_pct", "", .5), ("block_rating", "", .5)]),
                    ("Mountain Bears the Sky (Sơn Kháng Thiên)", [("body_shield_pct", "", .5), ("status_resist_pct", "", .5)])]),
    "earth": T_("Earth element (Thổ)", "element", "Earth qi", [("attack_pct", "tho", 1.0)],
                [("Thick Earth (Hậu Thổ)", [("attack_pct", "tho", .5), ("khi_huyet_pct", "", .5)]),
                 ("Yellow Springs (Hoàng Tuyền)", [("attack_pct", "tho", .6), ("crit_damage_pct", "tho", .4)]),
                 ("Landslide (Sơn Băng)", [("attack_pct", "tho", .6), ("resist_pen_pct", "physical", .4)]),
                 ("Loess Plain (Hoàng Thổ)", [("attack_pct", "tho", .5), ("element_affinity_pct", "", .5)])]),
    "gravity": T_("Weight (Trọng Lực)", "element", "Heavy qi", [("status_resist_pct", "", 1.0)],
                  [("Thousand Jin (Thiên Cân)", [("status_resist_pct", "", .5), ("attack_pct", "tho", .5)]),
                   ("Rooted Feet (Trát Căn)", [("status_resist_pct", "", .6), ("block_rating", "", .4)]),
                   ("Crushing Weight (Áp Đỉnh)", [("attack_pct", "tho", .6), ("status_resist_pct", "", .4)])]),
    # ---- Water (Thủy): talismans and tide (sustain), the element, ice (variant district) ----
    "talisman": T_("Talismans (Phù Đạo)", "identity", "Brush stroke", [("talisman_power_pct", "", 1.0)],
                   [("Cinnabar Brush (Chu Sa Bút)", [("talisman_power_pct", "", .6), ("than_thuc_pct", "", .4)]),
                    ("Seal Script (Triện Văn)", [("talisman_power_pct", "", .7), ("art_speed_pct", "", .3)]),
                    ("Paper Army (Chỉ Binh)", [("talisman_power_pct", "", .5), ("attack_pct", "talisman", .5)]),
                    ("Heaven-Sealing Slip (Phong Thiên Phù)", [("talisman_power_pct", "", .5), ("defense_pct", "", .5)])]),
    "tide": T_("Tide (Triều Tịch)", "identity", "Ebb and flow", [("linh_luc_regen_pct", "", 1.0)],
               [("Rising Tide (Triều Dâng)", [("linh_luc_regen_pct", "", .6), ("heal_pct", "", .4)]),
                ("Soft Water (Nhu Thủy)", [("heal_pct", "", .6), ("ward_efficiency_pct", "", .4)]),
                ("Moon Draws the Sea (Nguyệt Dẫn Hải)", [("linh_luc_regen_pct", "", .5), ("linh_luc_pct", "", .5)]),
                ("Returning Current (Hồi Lưu)", [("heal_pct", "", .5), ("linh_luc_regen_pct", "", .5)])]),
    "water": T_("Water element (Thủy)", "element", "Water qi", [("attack_pct", "thuy", 1.0)],
                [("Deep Abyss (Thâm Uyên)", [("attack_pct", "thuy", .6), ("crit_damage_pct", "thuy", .4)]),
                 ("Black Water (Huyền Thủy)", [("attack_pct", "thuy", .5), ("resist_pen_pct", "cold", .5)]),
                 ("Ten Thousand Streams (Vạn Lưu)", [("attack_pct", "thuy", .6), ("art_speed_pct", "thuy", .4)]),
                 ("Dragon Pool (Long Đàm)", [("attack_pct", "thuy", .5), ("element_affinity_pct", "", .5)])]),
    "ice": T_("Ice (Băng)", "variant", "Frost", [("attack_pct", "bang", 1.0)],
              [("Frozen Heart (Băng Tâm)", [("attack_pct", "bang", .5), ("tam_ma_resist_pct", "", .5)]),
               ("Glacier (Băng Xuyên)", [("attack_pct", "bang", .6), ("resist_pen_pct", "cold", .4)]),
               ("Snow Lotus (Tuyết Liên)", [("attack_pct", "bang", .5), ("health_regen_pct", "", .5)]),
               ("Frost Armour (Sương Giáp)", [("body_shield_pct", "", .6), ("resist_pct", "cold", .4)])]),
    # ---- Wood (Mộc): fields and beasts, the element, growth (sustain) ----
    "field": T_("Spirit fields (Linh Điền)", "identity", "Tilled qi", [("herb_growth_pct", "", 1.0)],
                [("Green Thumb (Lục Thủ)", [("herb_growth_pct", "", .7), ("alchemy_success", "", .3)]),
                 ("Fertile Plot (Phì Điền)", [("herb_growth_pct", "", 1.0)]),
                 ("Hundred Herbs (Bách Thảo)", [("herb_growth_pct", "", .5), ("lifespan_pct", "", .5)]),
                 ("Rain at the Right Time (Mưa Thuận)", [("herb_growth_pct", "", .6), ("khi_van", "", .4)])]),
    "beast": T_("Beasts (Ngự Thú)", "identity", "Beast bond", [("beast_power_pct", "", 1.0)],
                [("Pack Leader (Đầu Đàn)", [("beast_power_pct", "", .6), ("attack_pct", "beast", .4)]),
                 ("Blood Pact (Huyết Khế)", [("beast_power_pct", "", .5), ("khi_huyet_pct", "", .5)]),
                 ("Wild Heart (Dã Tâm)", [("beast_power_pct", "", .7), ("crit_chance_pct", "", .3)]),
                 ("Spirit Tamer (Ngự Linh)", [("beast_power_pct", "", .5), ("than_thuc_pct", "", .5)])]),
    "wood": T_("Wood element (Mộc)", "element", "Wood qi", [("attack_pct", "moc", 1.0)],
               [("Green Dragon (Thanh Long)", [("attack_pct", "moc", .6), ("crit_chance_pct", "moc", .4)]),
                ("Thorn Forest (Kinh Lâm)", [("attack_pct", "moc", .5), ("dot_pct", "", .5)]),
                ("Ancient Root (Cổ Căn)", [("attack_pct", "moc", .5), ("element_affinity_pct", "", .5)]),
                ("Spring Thunder Wakes (Xuân Lôi)", [("attack_pct", "moc", .6), ("art_speed_pct", "moc", .4)])]),
    "growth": T_("Growth (Sinh Cơ)", "element", "Green life", [("health_regen_pct", "", 1.0)],
                 [("Endless Spring (Sinh Sinh Bất Tức)", [("health_regen_pct", "", .7), ("heal_pct", "", .3)]),
                  ("Sap of Life (Sinh Dịch)", [("heal_pct", "", .6), ("khi_huyet_pct", "", .4)]),
                  ("Evergreen (Thường Xanh)", [("health_regen_pct", "", .5), ("lifespan_pct", "", .5)])]),
    # ---- blend zones: the generating pairs meet ----
    "lava": T_("Molten earth (Dung Nham)", "blend", "Magma", [("dot_pct", "hoa", .5), ("attack_pct", "tho", .5)],
               [("Volcano Heart (Hỏa Sơn Tâm)", [("attack_pct", "tho", .5), ("dot_pct", "hoa", .5)]),
                ("Kiln Fired (Lò Nung)", [("block_rating", "", .5), ("resist_pct", "fire", .5)])]),
    "ore": T_("Ore veins (Khoáng Mạch)", "blend", "Vein of ore", [("artifact_power_pct", "", .5), ("block_rating", "", .5)],
              [("Mother Lode (Mẫu Khoáng)", [("artifact_power_pct", "", .6), ("can_cot", "", .4)]),
               ("Buried Gold (Kim Tàng)", [("attack_pct", "kim", .5), ("block_rating", "", .5)])]),
    "dew": T_("Cold dew (Hàn Lộ)", "blend", "Dewdrop", [("linh_luc_regen_pct", "", .5), ("attack_pct", "kim", .5)],
              [("Mirror Lake (Kính Hồ)", [("ward_efficiency_pct", "", .5), ("linh_luc_regen_pct", "", .5)]),
               ("Autumn Dew (Thu Lộ)", [("attack_pct", "thuy", .5), ("attack_pct", "kim", .5)])]),
    "rain": T_("Spring rain (Xuân Vũ)", "blend", "Raindrop", [("health_regen_pct", "", .5), ("linh_luc_regen_pct", "", .5)],
               [("Rain on Bamboo (Vũ Trúc)", [("health_regen_pct", "", .5), ("herb_growth_pct", "", .5)]),
                ("Mist Valley (Vụ Cốc)", [("evade_pct", "", .5), ("linh_luc_regen_pct", "", .5)])]),
    "kindling": T_("Kindling (Ngô Đồng)", "blend", "Wutong leaf", [("attack_pct", "hoa", .5), ("health_regen_pct", "", .5)],
                   [("Phoenix Perch (Phượng Thê)", [("attack_pct", "hoa", .5), ("heal_pct", "", .5)]),
                    ("Wood Feeds Fire (Mộc Sinh Hỏa)", [("attack_pct", "moc", .5), ("attack_pct", "hoa", .5)])]),
    # ---- variant roots (decision 6): their own lands and islands ----
    "wind": T_("Wind (Phong)", "variant", "Gust", [("travel_speed_pct", "", .5), ("evade_pct", "", .5)],
               [("Wind Walker (Ngự Phong)", [("travel_speed_pct", "", .6), ("evade_pct", "", .4)]),
                ("Gale Blade (Cuồng Phong Đao)", [("attack_pct", "phong", .6), ("art_speed_pct", "phong", .4)]),
                ("Leaving No Trace (Vô Ảnh)", [("evade_pct", "", .5), ("stealth_pct", "", .5)]),
                ("Eye of the Storm (Phong Nhãn)", [("evade_pct", "", .5), ("attack_pct", "phong", .5)])]),
    "thunder": T_("Thunder (Lôi)", "variant", "Static", [("attack_pct", "loi", 1.0)],
                  [("Heaven's Wrath (Thiên Phạt)", [("attack_pct", "loi", .6), ("crit_damage_pct", "loi", .4)]),
                   ("Five Thunders (Ngũ Lôi)", [("attack_pct", "loi", .5), ("resist_pen_pct", "lightning", .5)]),
                   ("Thunderclap Step (Lôi Bộ)", [("art_speed_pct", "loi", .6), ("evade_pct", "", .4)]),
                   ("Tribulation Tempered (Kiếp Luyện)", [("resist_pct", "lightning", .5), ("khi_huyet_pct", "", .5)])]),
    "light": T_("Light (Quang)", "variant", "Radiance", [("tam_ma_resist_pct", "", .5), ("attack_pct", "quang", .5)],
                [("Dawn (Bình Minh)", [("attack_pct", "quang", .5), ("tam_ma_resist_pct", "", .5)]),
                 ("Halo (Phật Quang)", [("tam_ma_resist_pct", "", .6), ("heal_pct", "", .4)]),
                 ("Piercing Ray (Xuyên Quang)", [("attack_pct", "quang", .6), ("accuracy_pct", "", .4)]),
                 ("Unclouded (Vô Ế)", [("tam_ma_resist_pct", "", .5), ("than_thuc_pct", "", .5)])]),
    "dark": T_("Darkness (Ám)", "variant", "Shade", [("stealth_pct", "", .5), ("attack_pct", "am", .5)],
               [("New Moon (Sóc Nguyệt)", [("stealth_pct", "", .6), ("attack_pct", "am", .4)]),
                ("Shadow Step (Ảnh Bộ)", [("stealth_pct", "", .5), ("evade_pct", "", .5)]),
                ("Night Blade (Dạ Nhận)", [("attack_pct", "am", .6), ("crit_chance_pct", "am", .4)]),
                ("Swallowed Light (Thôn Quang)", [("attack_pct", "am", .5), ("soul_res_pct", "", .5)])]),
    "chaos": T_("Primordial Chaos (Hỗn Độn)", "variant", "Hồng mông qi", [("cultivation_speed_pct", "", .5), ("element_affinity_pct", "", .5)],
                [("Before Heaven (Tiên Thiên)", [("cultivation_speed_pct", "", .6), ("breakthrough_chance", "", .4)]),
                 ("Five in One (Ngũ Hành Quy Nhất)", [("element_affinity_pct", "", 1.0)]),
                 ("Wuji (Vô Cực)", [("cultivation_speed_pct", "", .5), ("element_affinity_pct", "", .5)]),
                 ("Taiji Turns (Thái Cực Chuyển)", [("element_affinity_pct", "", .5), ("ward_efficiency_pct", "", .5)])]),
}

# hidden clusters (sealed / open), Kinh Mạch Đồ rules 6-13; themes are systems the game already has
HIDDEN_THEMES = {
    "secret": T_("Hidden cluster", "hidden", "Sealed meridian", [("than_thuc_pct", "", 1.0)],
                 [("Sealed notable (content authored later)", [("than_thuc_pct", "", 1.0)])]),
}

THEMES = {**BASE_THEMES, **ELEMENT_THEMES, **HIDDEN_THEMES}

ELEMENT_OF_THEME = {
    "sword": "metal", "refining": "metal", "metal": "metal", "body": "metal",
    "alchemy": "fire", "blaze": "fire", "fire": "fire", "phoenix": "fire",
    "formation": "earth", "mountain": "earth", "earth": "earth", "gravity": "earth",
    "talisman": "water", "tide": "water", "water": "water", "ice": "water",
    "field": "wood", "beast": "wood", "wood": "wood", "growth": "wood",
}
