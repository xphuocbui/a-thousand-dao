# Đạo Đồ step A: one build idea per big picture on v5 (content-method.md §4.1). Written by hand.
# I(area, piece key, idea, lines, cap=(id, tier), effect=hint, pending=[...], note='')
#   idea: "<approved id> <Name (Hán-Việt)>" or "★ <Name (Hán-Việt)>" (new). lines: the 2-3 stat lines (stat, scope)
#   its nodes stack; the first two are the small nodes' A and B lines. effect: the rule part, drafted in step B/C.
#   A mirrored pair is named by either copy; a huge piece may carry two ideas (two I rows, same key).
# Rendered and checked by tools/design/dao_do_rework/content/ideas_report.py.

# ---------------- Fire (Hỏa): heart and soul (thần hồn); alchemy, blaze, true flame, phoenix ----------------
I('fire', 'c3 A_wing', 'F9 Ember Heart (Ẩn Hỏa Tâm)', [('tam_ma_resist_pct', ''), ('than_hon', ''), ('breakthrough_chance', '')])
I('fire', 'c62 corona', 'F10 Three-Legged Crow (Kim Ô)', [('art_speed_pct', 'hoa'), ('attack_pct', 'hoa')])
I('fire', 'c62 halo', 'F7 Ash Lotus (Hôi Liên)', [('resist_pct', 'fire'), ('health_regen_pct', '')])
I('fire', 'c120 comet', 'B2 Molten Core (Dung Hạch)', [('attack_pct', 'hoa'), ('defense_pct', '')])
I('fire', 'c119 flicker', 'B11 Campfire (Lửa Trại)', [('attack_pct', 'moc'), ('attack_pct', 'hoa')])
I('fire', 'c18 sun', 'F6 Sun Disc (Thái Dương Luân)', [('attack_pct', 'fire'), ('crit_chance_pct', 'fire')])
I('fire', 'c28 sunrise', 'F1 Nine-Turn Furnace (Cửu Chuyển Lô)', [('alchemy_success', ''), ('pill_effect_pct', '')],
  cap=('#10 Divided Furnace Flame', 'T1'), pending=['pill_quality_chance'])
I('fire', 'c28 spiral', 'F2 Strange Pill Gourd (Dị Đan Hồ Lô)', [('alchemy_success', ''), ('khi_van', '')],
  cap=('#11 Strange Pill Reborn', 'T2'))
I('fire', 'c28 wisp', '★ Toxin-Burning Fire (Luyện Độc Hỏa)', [('dan_doc_resist_pct', ''), ('dan_doc_decay', '')])
I('fire', 'c29 wisp', '★ Pill Pouch (Đan Nang)', [('pill_effect_pct', ''), ('cultivation_speed_pct', '')])
I('fire', 'c92 feather', '★ Rise From Ash (Dục Hỏa)', [('health_regen_pct', ''), ('healing_taken_pct', '')])
I('fire', 'c47 wing', '★ Burning Blade (Hỏa Nhận)', [('attack_pct', 'physical'), ('convert_pct', 'physical>fire')])
I('fire', 'c49 torch', '★ Soul-Burning Lamp (Phần Hồn Đăng)', [('x_soul', ''), ('than_hon', '')])
I('fire', 'c49 firework', '★ Smouldering Qi (Âm Hỏa)', [('linh_luc_on_hit_pct', 'hoa'), ('leech_linh_luc_pct', 'hoa')])
I('fire', 'c105 trident', 'F8 Volcano (Hỏa Sơn)', [('attack_pct', 'hoa,slow'), ('linh_luc_pct', '')],
  effect='costly Fire arts hit harder')
I('fire', 'c101 star', '★ Searing Will (Chước Ý)', [('resist_pen_pct', 'fire'), ('attack_pct', 'hoa')])
I('fire', 'c53 fleur', 'F5 Prairie Fire (Liệu Nguyên Hỏa)', [('stack_effect_pct', 'hoa,debuff'), ('stack_duration_pct', 'hoa,debuff')],
  effect='a finished Burn batch rekindles')
I('fire', 'c901 trefoil_R', 'F3 Phoenix (Phượng Hoàng)', [('khi_huyet_pct', ''), ('healing_pct', '')],
  cap=('#5 Soul Leaves the Body', 'T3'))
I('fire', 'c901 ding_R', 'F4 Last Flare (Hồi Quang)', [('lifespan_pct', ''), ('breakthrough_chance', '')],
  cap=('#22 Last Radiance', 'T3'))

# ---------------- Earth (Thổ): faith and intent (đạo tâm); formations, mountain body, gravity ----------------
I('earth', 'c65 hill', 'B1 Kiln Hill (Diêu Sơn)', [('attack_pct', 'tho'), ('attack_pct', 'hoa')], effect='burning ground')
I('earth', 'c66 stairway', 'E10 Bedrock Root (Bàn Thạch Căn)', [('dao_tam', ''), ('tam_ma_resist_pct', ''), ('breakthrough_chance', '')])
I('earth', 'c36 terrace1', '★ Deep Soil (Thâm Thổ)', [('linh_luc_pct', ''), ('linh_luc_regen_pct', '')])
I('earth', 'c36 terrace2', '★ Five Grains (Ngũ Cốc)', [('khi_huyet_pct', ''), ('health_regen_inc_pct', '')])
I('earth', 'c36 terrace3', 'E7 Terraced Fields (Thê Điền)', [('herb_growth_pct', ''), ('can_cot', '')])
I('earth', 'c24 road', '★ Thick Earth (Hậu Thổ)', [('attack_pct', 'tho'), ('khi_huyet_pct', '')])
I('earth', 'c23 road', 'B3 Mother Lode (Mẫu Khoáng)', [('refining_success', ''), ('artifact_defense_pct', '')])
I('earth', 'c19 ridge', 'E5 Millstone (Thạch Ma)', [('attack_pct', 'tho'), ('crit_damage_pct', 'tho')], effect='hits slow the foe (Slowed Time)')
I('earth', 'c24 peak_outer', 'E3 Five Peaks (Ngũ Nhạc)', [('khi_huyet_pct', ''), ('block_rating', '')])
I('earth', 'c87 tower', 'E1 Nine Palaces (Cửu Cung Đồ)', [('formation_power_pct', ''), ('than_thuc_pct', '')],
  cap=('#15 Formation Within a Formation', 'T2'))
I('earth', 'c75 pyramid', 'E8 Array Eye (Trận Nhãn)', [('attack_pct', 'formation'), ('art_speed_pct', 'formation')])
I('earth', 'c40 keep', '★ Array Keeper (Thủ Trận)', [('defense_pct', ''), ('formation_power_pct', '')], pending=['formation_upkeep_pct'])
I('earth', 'c87 stone', '★ Stone Skin (Thạch Phu)', [('resist_pct', 'physical'), ('resist_pct', 'force')])
I('earth', 'c48 keep', '★ Bulwark (Kiên Lũy)', [('body_shield_pct', ''), ('khi_huyet_pct', '')], pending=['recharge_delay_pct'])
I('earth', 'c55 quarry', 'E9 Landslide (Sơn Băng)', [('attack_pct', 'slow'), ('pierce_pct', '')])
I('earth', 'c8 wall', 'E6 Rampart (Thành Tường)', [('defense_pct', ''), ('ward_efficiency_pct', '')])
I('earth', 'c51 cave', 'H2 Cave Gate (Động Môn)', [('formation_power_pct', ''), ('herb_growth_pct', '')],
  cap=('#14 Portable Cave Abode', 'T2'), note='moved from the hub (decision 2)')
I('earth', 'c902 bronze_bell_storey_east', 'E2 Black Tortoise (Huyền Quy)', [('cultivation_speed_pct', ''), ('lifespan_pct', '')],
  cap=('#7 Embryonic Breath', 'T2'))
I('earth', 'c902 earth_seal_terrace_east', 'E4 Yellow Springs (Hoàng Tuyền)', [('lifespan_pct', ''), ('qi_deviation_pct', '')])
I('earth', 'c902 cong_R', '★ Earth Veins (Địa Mạch)', [('cultivation_speed_pct', ''), ('dao_tam', ''), ('density_bonus', '')])
I('earth', 'c902 ruyi_R', '★ Ruyi (Như Ý)', [('khi_van', ''), ('mi_luc', '')])
I('earth', 'c902 star_R', '★ Heavy Star (Trọng Tinh)', [('resist_pen_pct', ''), ('ward_bill_pct', '')])
I('earth', 'c902 bell', '★ Temple Bell (Tự Chung)', [('soul_res_pct', ''), ('status_resist_pct', '')])

# ---------------- Metal (Kim): physique (căn cốt); sword, refining, autumn killing qi, body ----------------
I('metal', 'c10 rack', 'M1 Hundred-Sword Rack (Bách Kiếm Giá)', [('attack_pct', 'sword'), ('artifact_attack_pct', '')],
  cap=('#1 Twin Arms in Harmony', 'T2'))
I('metal', 'c73 ding', 'M2 Spirit Furnace (Linh Lô)', [('refining_success', ''), ('artifact_power_pct', '')],
  cap=('#3 Treasure Nurtured Within', 'T2'), pending=['refine_grade_chance'])
I('metal', 'c903 linked rings', 'M3 Divided Mirror (Phân Thần Kính)', [('than_thuc_pct', ''), ('artifact_attack_pct', '')],
  cap=('#2 Divided Divine Sense', 'T2'))
I('metal', 'c50 arcs', 'M4 Vajra Body (Kim Cương Thân)', [('khi_huyet_pct', ''), ('linh_luc_pct', '')],
  cap=('#4 Blood Commands Spirit', 'T2'))
I('metal', 'c57 sawblade', 'M5 Autumn Scythe (Thu Sát Liêm)', [('crit_chance_pct', 'kim'), ('crit_damage_pct', 'kim')])
I('metal', 'c10 sword', 'M6 Ten Thousand Edges (Vạn Nhận)', [('art_speed_pct', 'sword'), ('attack_pct', 'sword,kim')])
I('metal', 'c27 bell', 'M7 Golden Bell (Kim Chung Tráo)', [('defense_pct', ''), ('block_rating', '')])
I('metal', 'c20 coins', 'M8 Ore Vein (Khoáng Mạch)', [('refining_success', ''), ('can_cot', '')])
I('metal', 'c10 hammer', 'M9 Piercing Arrowhead (Xuyên Kim Tiễn)', [('resist_pen_pct', 'physical'), ('attack_pct', 'kim')])
I('metal', 'c73 wheel', 'M10 Whetstone Wheel (Ma Thạch Luân)', [('linh_luc_on_crit_pct', ''), ('crit_chance_pct', '')])
I('metal', 'c30 compass', 'B4 Buried Vault (Kim Tàng Khố)', [('co_duyen_pct', ''), ('stealth', '')])
I('metal', 'c27 coin', 'B6 Autumn Dew (Thu Lộ)', [('linh_luc_regen_pct', ''), ('linh_luc_regen_inc_pct', '')])
I('metal', 'c20 bow', '★ Drawn Bow (Mãn Cung)', [('accuracy_pct', ''), ('attack_pct', 'kim')])
I('metal', 'c34 trident', '★ Sword Intent (Kiếm Ý)', [('crit_damage_pct', 'sword'), ('attack_pct', 'sword')])
I('metal', 'c20 gong', '★ Clear Gong (Thanh La)', [('soul_res_pct', ''), ('timer_resist_pct', '')])
I('metal', 'c41 crown', '★ Iron Discipline (Thiết Luật)', [('can_cot', ''), ('khi_huyet_pct', '')])
I('metal', 'c10 shield', '★ Bronze Shield (Đồng Thuẫn)', [('block_rating', ''), ('artifact_defense_pct', '')])
I('metal', 'c903 pentagons R', '★ Five Metals (Ngũ Kim)', [('artifact_power_pct', ''), ('element_affinity_pct', '')])
I('metal', 'c903 weiqi board', '★ Rotten Axe Handle (Lạn Kha)', [('lifespan_pct', ''), ('ngo_tinh', '')], note='the woodcutter who watched immortals play weiqi while centuries passed')

# ---------------- Water (Thủy): wisdom (ngộ tính); talismans, tide, deep water, ice ----------------
I('water', 'c38 lily_pad', 'W4 Snow Lotus (Tuyết Liên)', [('stack_duration_pct', 'bang,debuff'), ('attack_pct', 'bang')])
I('water', 'c76 braid', 'W1 Brush and Inkstone (Bút Nghiên)', [('attack_pct', 'talisman'), ('art_speed_pct', 'talisman')],
  cap=('#13 Endless Talismans', 'T2'), pending=['talisman_power_pct'])
I('water', 'c42 seaweed', 'W8 Paper Army (Chỉ Binh Trận)', [('companion_power_pct', ''), ('companion_health_pct', '')],
  pending=['talisman_power_pct'])
I('water', 'c69 pearl', 'W7 Black Abyss (Huyền Uyên)', [('linh_luc_pct', ''), ('reserve_eff_pct', '')])
I('water', 'c54 meeting_ripples', 'W10 Carp at the Dragon Gate (Lý Ngư Khiêu Long Môn)', [('breakthrough_chance', ''), ('ngo_tinh', '')])
I('water', 'c17 meander', 'W2 Dreaming River (Mộng Hà)', [('cultivation_speed_pct', ''), ('travel_speed_pct', '')],
  cap=('#8 Dao in Dreams', 'T2'), pending=['cultivation_speed_pct[travelling]'])
I('water', 'c17 turning_wave', 'W3 Moon over the Tide (Nguyệt Triều)', [('stack_effect_pct', 'thuy,buff'), ('linh_luc_regen_pct', '')],
  effect='tide: damage rises and falls in a cycle')
I('water', 'c904 ice_flake', 'W5 Icicle Crown (Băng Quan)', [('crit_chance_pct', 'cold'), ('defense_pct', '')])
I('water', 'c11 whirlpool', 'W6 Whirlpool (Tuyền Qua)', [('leech_linh_luc_pct', ''), ('linh_luc_on_hit_pct', '')])
I('water', 'c26 raindrop', 'W9 Rain Curtain (Vũ Liêm)', [('attack_pct', 'quick'), ('healing_pct', '')])
I('water', 'c11 pond', 'B5 Mirror Lake (Kính Hồ)', [('soul_res_pct', ''), ('ngo_tinh', '')], effect='counter-attack')
I('water', 'c32 moon_halo', 'B7 Rain on Bamboo (Vũ Trúc)', [('health_regen_inc_pct', ''), ('healing_taken_pct', '')])
I('water', 'c32 lotus', 'B9 Compass Rose (La Bàn)', [('travel_speed_pct', ''), ('escape_pct', '')],
  cap=('#21 Blink Mark', 'T2'))
I('water', 'c26 waterwheel', '★ Mill Race (Thủy Xa)', [('art_speed_pct', 'thuy'), ('art_cost_pct', 'thuy')])
I('water', 'c22 wave_train', '★ Rolling Waves (Liên Ba)', [('attack_pct', 'thuy'), ('resist_pen_pct', 'cold')])
I('water', 'c59 endless', '★ Endless Knot (Vô Tận Kết)', [('curse_effect_pct', ''), ('status_duration_pct', 'curse')])
I('water', 'c904 armillary_L', '★ Star Chart (Tinh Đồ)', [('ngo_tinh', ''), ('travel_speed_pct', '')])
I('water', 'c904 oai_stellar_frost', '★ Frost Star (Sương Tinh)', [('stack_effect_pct', 'bang,debuff'), ('attack_pct', 'cold')])
I('water', 'c904 bagua', '★ Water Trigram (Khảm Quái)', [('evade_pct', ''), ('stealth', '')])
I('water', 'c904 plate_flake', '★ Frost Plate (Sương Giáp)', [('resist_pct', 'cold'), ('khi_huyet_pct', '')])
I('water', 'c904 lotus', '★ Still Lake Lotus (Tĩnh Liên)', [('lifespan_pct', ''), ('tam_ma_resist_pct', '')])

# ---------------- Wood (Mộc): fortune (khí vận); spirit fields, beasts, green dragon, growth; Wind cells 43-44 ----------------
I('wood', 'c21 seed', 'D9 Spring Sprout (Xuân Nha)', [('khi_van', ''), ('co_duyen_pct', '')])
I('wood', 'c94 tulip', 'D1 Hundred-Herb Garden (Bách Thảo Viên)', [('herb_growth_pct', ''), ('healing_pct', '')],
  cap=('#12 Hundred Herbs Kept Alive', 'T2'))
I('wood', 'c60 rings', 'D8 Lingzhi Ring (Linh Chi Hoàn)', [('pill_effect_pct', ''), ('lifespan_pct', '')])
I('wood', 'c39 bough', 'D6 Thorn Hedge (Kinh Cức)', [('block_rating', ''), ('resist_pct', 'physical')], effect='thorns: reflect damage')
I('wood', 'c72 vine', 'D10 Binding Vine (Đằng La)', [('status_duration_pct', ''), ('attack_pct', 'moc,over_time')])
I('wood', 'c31 bamboo2', 'D7 Bamboo Grove (Trúc Lâm)', [('art_speed_pct', 'moc'), ('evade_pct', '')])
I('wood', 'c12 tree', 'D5 World Tree (Kiến Mộc)', [('health_regen_pct', ''), ('khi_huyet_pct', '')])
I('wood', 'c109 frond', 'D4 Green Dragon (Thanh Long)', [('attack_pct', 'moc'), ('resist_pen_pct', '')])
I('wood', 'c905 star_w', 'D2 Wolf Pack (Lang Quần)', [('companion_power_pct', ''), ('companion_speed_pct', '')],
  cap=('#16 Ten Thousand Beasts, One Heart', 'T2'), pending=['taming_chance'])
I('wood', 'c905 lantern_e', 'D3 Beast-Soul Totem (Thú Hồn Đồ Đằng)', [('companion_health_pct', ''), ('attack_pct', 'companion')],
  cap=('#17 Beast Soul Union', 'T2'))
I('wood', 'c44 pinwheel', 'B8 Wind Fan (Phong Phiến)', [('attack_pct', 'phong'), ('evade_pct', '')])
I('wood', 'c39 youngfir', 'B10 Wutong Perch (Ngô Đồng Thê)', [('stack_duration_pct', 'hoa,debuff'), ('attack_pct', 'moc')])
I('wood', 'c64 tendrils', '★ Tender Shoots (Nộn Chi)', [('cultivation_speed_pct', ''), ('health_regen_inc_pct', '')])
I('wood', 'c31 fir', '★ Evergreen (Thường Thanh)', [('status_resist_pct', ''), ('timer_resist_pct', '')])
I('wood', 'c31 pinecone', '★ Pine Strength (Tùng Lực)', [('can_cot', ''), ('status_resist_pct', 'poison')])
I('wood', 'c25 morningglory', '★ Morning Glory (Khiên Ngưu)', [('attack_pct', 'poison'), ('stack_effect_pct', 'moc,debuff')])
I('wood', 'c35 wreath', '★ Laurel Wreath (Nguyệt Quế)', [('mi_luc', ''), ('mission_income_pct', '')])
I('wood', 'c31 bamboo1', '★ Bamboo Joints (Trúc Tiết)', [('basic_speed_pct', ''), ('crit_chance_pct', 'moc')])
I('wood', 'c31 bamboo3', '★ Hollow Bamboo (Không Trúc)', [('art_cost_pct', 'moc'), ('linh_luc_regen_inc_pct', '')])
I('wood', 'c44 cloud', '★ Riding the Wind (Ngự Phong)', [('art_speed_pct', ''), ('escape_pct', '')])
I('wood', 'c43 streaks', '★ Raging Gale (Cuồng Phong)', [('attack_pct', 'phong,quick'), ('crit_chance_pct', '')])
I('wood', 'c12 maple', '★ Autumn Maple (Đan Diệp)', [('crit_damage_pct', 'moc'), ('attack_pct', 'over_time')])
I('wood', 'c905 holo', '★ Gourd of Ten Thousand Years (Vạn Niên Hồ Lô)', [('lifespan_pct', ''), ('dan_doc_resist_pct', '')])

# ---------------- Light island (Quang): the Sun and the Fusang tree ----------------
I('light', 'c931 tree_B_l', 'L1 Armillary Sphere (Hồn Thiên Nghi)', [('ngo_tinh', ''), ('than_thuc_pct', ''), ('khi_van', '')],
  cap=('#18 Reading Heaven\'s Secrets', 'T2'))
I('light', 'c931 tree_CD_l', 'L2 Fortune Coin (Khí Vận Tiền)', [('khi_van', ''), ('mission_income_pct', '')],
  cap=('#19 Child of Fortune', 'T1'))
I('light', 'c931 tree_A_l', 'L3 Buddha\'s Halo (Phật Quang)', [('healing_pct', ''), ('status_resist_pct', 'curse')])
I('light', 'c931 flames_090_l', 'L4 Dawn (Bình Minh)', [('attack_pct', 'light'), ('resist_pen_pct', 'light')],
  effect='hits lay the foe bare (Exposed)')
I('light', 'c931 tree_E_l', '★ Rising Sun (Húc Nhật)', [('cultivation_speed_pct', ''), ('khi_huyet_pct', '')])
I('light', 'c931 flames_144_l', '★ Corona (Nhật Miện)', [('crit_damage_pct', ''), ('attack_pct', 'light')])
I('light', 'c931 flames_126_l', '★ Sunfire (Nhật Hỏa)', [('attack_pct', 'fire'), ('attack_pct', 'light')])
I('light', 'c931 flames_108_l', '★ Noon Glare (Chính Ngọ)', [('accuracy_pct', ''), ('crit_chance_pct', '')])
I('light', 'c931 flames_054_l', '★ Sun Shield (Nhật Thuẫn)', [('resist_pct', 'light'), ('defense_pct', '')])
I('light', 'c931 flames_036_l', '★ Long Day (Trường Nhật)', [('status_duration_pct', ''), ('linh_luc_regen_inc_pct', '')])
I('light', 'c931 flames_018_l', '★ Solar Wind (Nhật Phong)', [('art_speed_pct', ''), ('linh_luc_pct', '')])

# ---------------- Thunder island (Lôi) ----------------
I('thunder', 'c932 cloud_upper', 'T1 Tribulation Cloud (Kiếp Vân)', [('breakthrough_chance', ''), ('khi_huyet_pct', ''), ('lifespan_pct', '')],
  cap=('#23 Burning Life to Break Through', 'T3'))
I('thunder', 'c932 storm_569', 'T2 Five Drums (Ngũ Lôi Cổ)', [('attack_pct', 'lightning'), ('attack_pct', 'quick')])
I('thunder', 'c932 bolt_out_chain', 'T3 Thunder Step (Lôi Bộ)', [('art_speed_pct', ''), ('basic_speed_pct', '')],
  effect='first strike')
I('thunder', 'c932 storm_566', 'T4 Heaven\'s Hammer (Thiên Phạt Chùy)', [('attack_pct', 'loi,slow'), ('crit_damage_pct', '')],
  effect='burst')
I('thunder', 'c932 bolt_down_tree', '★ Grounding Rod (Tiếp Địa)', [('resist_pct', 'lightning'), ('status_resist_pct', '')])
I('thunder', 'c932 oai_three_tribulations', '★ Three Tribulations (Tam Kiếp)', [('tam_ma_resist_pct', ''), ('khi_huyet_pct', '')])
I('thunder', 'c932 bolt_out_tree', '★ Branching Bolt (Chi Lôi)', [('attack_pct', 'lightning'), ('crit_chance_pct', 'lightning')])
I('thunder', 'c932 bolt_out_double', '★ Twin Thunder (Song Lôi)', [('crit_damage_pct', ''), ('attack_pct', 'loi')])
I('thunder', 'c932 open_cloud_567', '★ Gathering Clouds (Tụ Vân)', [('linh_luc_pct', ''), ('linh_luc_on_crit_pct', '')])
I('thunder', 'c932 oai_rim_coursing_thunder', '★ Coursing Thunder (Lôi Mạch)', [('stack_effect_pct', 'loi,debuff'), ('stack_duration_pct', 'loi,debuff')])
I('thunder', 'c932 oai_high_thunder_fan', '★ Thunder Fan (Lôi Phiến)', [('accuracy_pct', ''), ('attack_pct', 'lightning,quick')])
I('thunder', 'c932 storm_586', '★ Purple Storm (Tử Lôi Bạo)', [('attack_pct', 'loi'), ('resist_pen_pct', 'lightning')])
I('thunder', 'c932 cloud_585', '★ Storm Rain (Bạo Vũ)', [('health_regen_pct', ''), ('linh_luc_regen_inc_pct', '')])
I('thunder', 'c932 cloud_584', '★ Cloud Sea (Vân Hải)', [('evade_pct', ''), ('escape_pct', '')])
I('thunder', 'c932 cloud_579', '★ Thunder God\'s Gaze (Lôi Thần Mục)', [('than_thuc_pct', ''), ('pierce_pct', '')])
I('thunder', 'c932 cloud_583', '★ Heaven\'s Rumble (Thiên Lôi Minh)', [('x_soul', ''), ('soul_res_pct', '')])
I('thunder', 'c932 arc_cloud_584', '★ Arc Cloud (Hồ Vân)', [('art_cost_pct', ''), ('reserve_eff_pct', '')])
I('thunder', 'c932 cloud_581', '★ Tempered by Lightning (Lôi Luyện)', [('can_cot', ''), ('resist_pct', 'lightning')])
I('thunder', 'c932 arc_cloud_582', '★ Clear Sky (Tình Không)', [('co_duyen_pct', ''), ('travel_speed_pct', '')])

# ---------------- Darkness island (Ám) and the Shadow Shrine ----------------
I('darkness', 'c933 moon_lotus', 'K1 Devouring Maw (Hấp Tinh Khẩu)', [('cultivation_speed_pct', ''), ('leech_linh_luc_pct', '')],
  cap=('#9 Great Essence-Draining Art', 'T2'))
I('darkness', 'c933 moon_lotus', 'K2 Veiled Cowl (Liễm Tức Sa)', [('stealth', ''), ('escape_pct', '')],
  cap=('#20 Concealed Breath', 'T2'))
I('darkness', 'c933 full_moon', 'K3 New Moon (Sóc Nguyệt)', [('evade_pct', ''), ('crit_chance_pct', '')], effect='crit from evasion')
I('darkness', 'c933 long_spiral_l', 'K4 Shadow Steps (Ảnh Bộ)', [('evade_pct', ''), ('art_speed_pct', '')])
I('darkness', 'c933 horn_and_s_l', 'K5 Night Moth (Dạ Nga)', [('curse_effect_pct', ''), ('art_cost_pct', 'curse')])
I('darkness', 'c933 shrine_eclipse', 'S1 Heart Demon Altar (Tâm Ma Đài)', [('attack_pct', 'chaos'), ('x_soul', '')],
  cap=('#25 Heart Demon Turned to Strength', 'T2'))
I('darkness', 'c933 shrine_eclipse', 'S2 Incense Smoke (Hương Yên)', [('tam_ma_resist_pct', ''), ('qi_deviation_pct', '')])

# ---------------- Hub: the Chaos swirl (exact values, no purity multiplier) ----------------
I('hub', 'c79 swirl_arm_01', 'H4 Before Heaven (Tiên Thiên Bát Quái)', [('attack_pct', ''), ('resist_pct', '')],
  effect='bonuses grow with the number of elements owned')
I('hub', 'c79 swirl_arm_02', '★ Chaos Edge (Hỗn Độn Phong)', [('attack_pct', 'chaos'), ('resist_pen_pct', 'chaos')])
I('hub', 'c79 swirl_arm_03', 'H1 Twin Rings (Song Hoàn)', [('cultivation_speed_pct', ''), ('ngo_tinh', '')],
  cap=('#6 Twin Technique Cultivation', 'T2'))
I('hub', 'c79 swirl_arm_04', '★ Primordial Breath (Nguyên Khí)', [('linh_luc_pct', ''), ('linh_luc_regen_inc_pct', '')])
I('hub', 'c79 swirl_arm_05', '★ Yin and Yang (Âm Dương)', [('khi_huyet_pct', ''), ('linh_luc_regen_pct', '')])
I('hub', 'c79 swirl_arm_06', 'H3 Sixth Point (Biến Dị Chi Môn)', [('khi_van', ''), ('can_cot', '')],
  cap=('#24 Mutation Awakening', 'T2'))
I('hub', 'c79 swirl_arm_07', '★ Five Phases Cycle (Ngũ Hành Luân Chuyển)', [('element_affinity_pct', ''), ('art_speed_pct', '')])
I('hub', 'c79 swirl_arm_08', '★ Undivided Mind (Hỗn Nguyên Tâm)', [('dao_tam', ''), ('than_hon', '')])
I('hub', 'c79 swirl_arm_09', '★ Void Step (Hư Bộ)', [('evade_pct', ''), ('accuracy_pct', '')])
I('hub', 'c79 swirl_arm_10', '★ Return to Origin (Quy Nguyên)', [('health_regen_inc_pct', ''), ('linh_luc_regen_pct', '')])

# ---------------- Start motifs: Chaos mixing into each land's first cell (cells 1-5; exact values) ----------------
I('chaos-fire', 'c3 flames_1', '★ Chaos Flame (Hỗn Độn Hỏa)', [('attack_pct', 'hoa'), ('attack_pct', 'chaos')])
I('chaos-fire', 'c3 flames_2', '★ Hearth (Táo Hỏa)', [('than_hon', ''), ('khi_huyet_pct', '')])
I('chaos-fire', 'c3 flames_3', '★ Spark of Origin (Nguyên Hỏa Tinh)', [('art_speed_pct', 'hoa'), ('linh_luc_pct', '')])
I('chaos-earth', 'c2 ridges_1', '★ Chaos Ground (Hỗn Thổ)', [('attack_pct', 'tho'), ('attack_pct', 'chaos')])
I('chaos-earth', 'c2 ridges_2', '★ First Foothold (Lập Túc)', [('dao_tam', ''), ('khi_huyet_pct', '')])
I('chaos-earth', 'c2 ridges_3', '★ Ridge Line (Sơn Tích)', [('block_rating', ''), ('resist_pct', '')])
I('chaos-earth', 'c2 ridges_4', '★ Steady Ground (Ổn Địa)', [('timer_resist_pct', ''), ('khi_huyet_pct', '')])
I('chaos-earth', 'c2 ridges_5', '★ Hill Spring (Sơn Tuyền)', [('health_regen_pct', ''), ('linh_luc_regen_pct', '')])
I('chaos-earth', 'c2 ridges_6', '★ Cliff Hold (Thủ Nhai)', [('resist_pct', ''), ('art_cost_pct', '')])
I('chaos-metal', 'c4 blades_1', '★ Chaos Blade (Hỗn Kim)', [('attack_pct', 'kim'), ('attack_pct', 'chaos')])
I('chaos-metal', 'c4 blades_2', '★ Edge Revealed (Phong Mang Sơ Lộ)', [('crit_chance_pct', ''), ('can_cot', '')])
I('chaos-metal', 'c4 blades_3', '★ Whetted (Đã Mài)', [('accuracy_pct', ''), ('attack_pct', 'physical')])
I('chaos-metal', 'c4 blades_5', '★ Blade Breath (Kiếm Khí)', [('art_speed_pct', 'kim'), ('linh_luc_pct', '')])
I('chaos-water', 'c5 waves_1', '★ Chaos Tide (Hỗn Triều)', [('attack_pct', 'thuy'), ('attack_pct', 'chaos')])
I('chaos-water', 'c5 waves_2', '★ Clear Spring (Thanh Tuyền)', [('ngo_tinh', ''), ('linh_luc_regen_pct', '')])
I('chaos-water', 'c5 waves_3', '★ Ripples (Liên Y)', [('evade_pct', ''), ('linh_luc_pct', '')])
I('chaos-wood', 'c1 vines_1', '★ Chaos Root (Hỗn Mộc)', [('attack_pct', 'moc'), ('attack_pct', 'chaos')])
I('chaos-wood', 'c1 vines_2', '★ First Leaf (Sơ Diệp)', [('khi_van', ''), ('health_regen_inc_pct', '')])
