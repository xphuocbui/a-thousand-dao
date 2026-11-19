# Earth (Thổ) content on v5. Written by hand under design/dao-do/content-method.md. Notables in walk order (crown last).

# ================= C. Big pictures =================
BIG('c66 stairway', [
    N('Bedrock (Bàn Thạch)', ('dao_tam', '', 4), ('tam_ma_resist_pct', '', 4)),
    N('Bedrock Root (Bàn Thạch Căn)', ('dao_tam', '', 4), ('breakthrough_chance', '', 4)),
])
BIG('c65 hill', [
    N('Fired Clay (Đào Thổ)', ('attack_pct', 'tho', 4), ('resist_pct', 'fire', 4)),
    N('Kiln Mouth (Diêu Khẩu)', ('attack_pct', 'hoa', 4), ('attack_pct', 'tho', 4)),
    N('Kiln Hill (Diêu Sơn)', ('attack_pct', 'tho,hoa', 5), ('khi_huyet_pct', '', 3), effect='Burning Ground (Địa Hỏa)'),
])
BIG('c36 terrace1', [
    N('Loam (Thổ Nhưỡng)', ('linh_luc_pct', '', 4), ('dao_tam', '', 4)),
    N('Seeping Spring (Thấm Tuyền)', ('linh_luc_regen_pct', '', 4), ('linh_luc_pct', '', 4)),
    N('Earth Storehouse (Địa Khố)', ('linh_luc_pct', '', 4), ('reserve_eff_pct', '', 4)),
    N('Deep Soil (Thâm Thổ)', ('linh_luc_regen_pct', '', 5), ('linh_luc_regen_inc_pct', '', 3)),
])
BIG('c23 road', [
    N('Ore Seam (Khoáng Tầng)', ('refining_success', '', 4), ('co_duyen_pct', '', 4)),
    N("Smelter's Road (Dã Luyện Lộ)", ('refining_success', '', 4), ('artifact_defense_pct', '', 4)),
    N('Mother Lode (Mẫu Khoáng)', ('refining_success', '', 5), ('artifact_power_pct', '', 3)),
])
BIG('c24 road', [
    N('Rammed Earth (Trúc Thổ)', ('attack_pct', 'tho', 4), ('khi_huyet_pct', '', 4)),
    N('Road of Stones (Thạch Lộ)', ('attack_pct', 'tho', 4), ('block_rating', '', 4)),
    N('Thick Earth (Hậu Thổ)', ('attack_pct', 'tho', 5), ('resist_pct', 'physical', 3)),
])
BIG('c36 terrace2', [
    N('Five Grains (Ngũ Cốc)', ('khi_huyet_pct', '', 4), ('health_regen_inc_pct', '', 4)),
])
BIG('c19 ridge', [
    N('Crushed Stone (Toái Thạch)', ('attack_pct', 'tho', 4), ('crit_damage_pct', 'tho', 4)),
    N('Mountain Crashes Down (Thái Sơn Áp Đỉnh)', ('crit_damage_pct', 'tho', 4), ('khi_huyet_pct', '', 4)),
    N('Millstone (Thạch Ma)', ('attack_pct', 'tho,slow', 5), ('crit_damage_pct', 'tho', 3), effect='Grinding Weight (Trọng Ma)'),
])
BIG('c36 terrace3', [
    N('Paddy Fields (Thủy Điền)', ('herb_growth_pct', '', 4), ('can_cot', '', 4)),
    N('Irrigation (Dẫn Thủy)', ('herb_growth_pct', '', 4), ('cultivation_speed_pct', '', 4)),
    N("Tiller's Bones (Canh Phu Cốt)", ('can_cot', '', 4), ('khi_huyet_pct', '', 4)),
    N('Terraced Fields (Thê Điền)', ('herb_growth_pct', '', 5), ('dao_tam', '', 3)),
])
BIG('c24 peak_outer', [
    N('Five Peaks (Ngũ Nhạc)', ('khi_huyet_pct', '', 4), ('block_rating', '', 4)),
])
BIG('c87 stone', [
    N('Granite Skin (Cương Phu)', ('resist_pct', 'physical', 4), ('resist_pct', 'force', 4)),
    N('Stone Skin (Thạch Phu)', ('resist_pct', 'physical', 5), ('khi_huyet_pct', '', 3)),
])
BIG('c40 keep', [
    N('Gatehouse (Môn Lâu)', ('defense_pct', '', 4), ('formation_power_pct', '', 4)),
    N("Keeper's Watch (Thủ Vọng)", ('formation_power_pct', '', 4), ('than_thuc_pct', '', 4)),
    N('Array Keeper (Thủ Trận)', ('defense_pct', '', 4), ('ward_efficiency_pct', '', 4),
      pending=[('formation_upkeep_pct', '', 3)]),
])
BIG('c48 keep', [
    N('Stone Bailey (Thạch Lũy)', ('body_shield_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Iron Gate (Thiết Môn)', ('body_shield_pct', '', 4), ('block_rating', '', 4)),
    N('Bulwark (Kiên Lũy)', ('body_shield_pct', '', 5), ('resist_pct', 'force', 3), pending=[('recharge_delay_pct', '', 3)]),
])
BIG('c89 tower', [
    N('Nine Palaces (Cửu Cung)', ('formation_power_pct', '', 4), ('than_thuc_pct', '', 4)),
    N('Formation Within a Formation (Trận Trung Trận)', ('formation_power_pct', '', 2), cap=('#15', 'T2'),
      alt=[('formation_power_pct', '', 5), ('than_thuc_pct', '', 3)], alt_name='Palace Gate (Cung Môn)'),
])
BIG('c75 pyramid', [
    N('Array Lines (Trận Văn)', ('attack_pct', 'formation', 4), ('art_speed_pct', 'formation', 4)),
    N('Eye of the Array (Trận Nhãn)', ('attack_pct', 'formation', 5), ('accuracy_pct', '', 3)),
    N('Living Array (Hoạt Trận)', ('art_speed_pct', 'formation', 4), ('formation_power_pct', '', 4)),
])
BIG('c55 quarry', [
    N('Loose Scree (Sa Thạch)', ('attack_pct', 'slow', 4), ('pierce_pct', '', 4)),
    N('Falling Rock (Lạc Thạch)', ('attack_pct', 'slow', 4), ('crit_damage_pct', '', 4)),
    N('Landslide (Sơn Băng)', ('attack_pct', 'slow,tho', 5), ('pierce_pct', '', 3)),
])
BIG('c51 cave', [
    N('Cave Mouth (Động Khẩu)', ('formation_power_pct', '', 4), ('herb_growth_pct', '', 4)),
    N('Hidden Grotto (Ẩn Động)', ('herb_growth_pct', '', 4), ('cultivation_speed_pct', '', 4)),
    N('Portable Cave Abode (Động Phủ Tùy Thân)', ('formation_power_pct', '', 2), cap=('#14', 'T2')),
])
BIG('c8 wall', [
    N('Battlements (Nữ Tường)', ('defense_pct', '', 4), ('ward_efficiency_pct', '', 4)),
    N('Rampart (Thành Tường)', ('defense_pct', '', 5), ('block_rating', '', 3)),
])
BIG('c902 bell', [
    N('Valley Echo (Cốc Hưởng)', ('soul_res_pct', '', 4), ('status_resist_pct', '', 4)),
    N('Stone Drums (Thạch Cổ)', ('status_resist_pct', '', 4), ('tam_ma_resist_pct', '', 4)),
    N('Bronze Bell (Đồng Chung)', ('soul_res_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Temple Bell (Tự Chung)', ('soul_res_pct', '', 5), ('status_resist_pct', 'curse', 3)),
])
BIG('c902 earth_seal_terrace_east', [
    N('Sealed Earth (Phong Thổ)', ('lifespan_pct', '', 4), ('qi_deviation_pct', '', 4)),
    N('Yellow Springs (Hoàng Tuyền)', ('lifespan_pct', '', 5), ('tam_ma_resist_pct', '', 3)),
])
BIG('c902 cong_R', [
    N('Jade Cong (Ngọc Tông)', ('cultivation_speed_pct', '', 4), ('dao_tam', '', 4)),
    N('Square Earth (Địa Phương)', ('dao_tam', '', 4), ('khi_huyet_pct', '', 4)),
    N('Opened Vein (Khai Mạch)', ('cultivation_speed_pct', '', 4), ('linh_luc_regen_pct', '', 4)),
    N('Earth Veins (Địa Mạch)', ('density_bonus', '', 5.6), ('cultivation_speed_pct', '', 2.4)),
])
BIG('c902 ruyi_R', [
    N('Cloud Head (Vân Đầu)', ('khi_van', '', 4), ('mi_luc', '', 4)),
    N('As You Wish (Như Ý)', ('khi_van', '', 4), ('co_duyen_pct', '', 4)),
    N('Ruyi Sceptre (Như Ý Trượng)', ('mi_luc', '', 4), ('mission_income_pct', '', 4)),
])
BIG('c902 star_R', [
    N('Mountain-Crushing Finger (Toái Sơn Chỉ)', ('resist_pen_pct', '', 4), ('attack_pct', 'tho', 4)),
    N('Ward Breaker (Phá Chướng)', ('ward_bill_pct', '', 4), ('resist_pen_pct', '', 4)),
    N('Falling Star (Lạc Tinh)', ('attack_pct', 'slow', 4), ('ward_bill_pct', '', 4)),
    N('Gravity (Trọng Lực)', ('resist_pen_pct', 'physical', 4), ('khi_huyet_pct', '', 4)),
    N('Heavy Star (Trọng Tinh)', ('resist_pen_pct', '', 5), ('crit_damage_pct', 'tho', 3)),
])
BIG('c902 bronze_bell_storey_east', [
    N('Tortoise Slumber (Quy Miên)', ('cultivation_speed_pct', '', 4), ('lifespan_pct', '', 4)),
    N('Embryonic Breath (Thai Tức Quy Nguyên)', ('cultivation_speed_pct', '', 2), cap=('#7', 'T2'),
      alt=[('lifespan_pct', '', 4), ('khi_huyet_pct', '', 4)], alt_name='Black Tortoise (Huyền Quy)'),
])

# ================= D. Medium clusters and start figures =================
DT = ('dao_tam', ''); THO = ('attack_pct', 'tho'); HP = ('khi_huyet_pct', ''); BLK = ('block_rating', ''); RP = ('resist_pct', 'physical')
RFO = ('resist_pct', 'force'); WARD = ('defense_pct', ''); WEF = ('ward_efficiency_pct', ''); FP = ('formation_power_pct', '')
AF = ('attack_pct', 'formation'); TT = ('than_thuc_pct', ''); CDT = ('crit_damage_pct', 'tho'); TM = ('tam_ma_resist_pct', '')
PIER = ('pierce_pct', ''); TR = ('timer_resist_pct', ''); SR = ('status_resist_pct', ''); HRI = ('health_regen_inc_pct', '')
MED('base2', DT, [n('Earth Start (Thổ Khởi)', DT, THO), n('Solid Ground (Kiên Địa)', DT, HP), n('Unwavering Faith (Tín Niệm)', DT, TM),
                  n('Earth Root (Thổ Căn)', THO, BLK)])
MED('base12', DT, [n('Earth Seal (Thổ Ấn)', DT, THO), n('Sky-Bearing Pillar (Kình Thiên Trụ)', DT, HP)])
MED('c2 d_gate', BLK, [n('Earthen Gate (Thổ Môn)', BLK, HP)])
MED('c66 d_gate', TM, [n('Gate of Faith (Tín Môn)', TM, DT)])
MED('c114 cirque', HP, [n('Mountain Hollow (Sơn Cốc)', HP, RP), n('Blessed Basin (Phúc Địa)', HP, HRI)])
MED('c66 trail', TR, [n('Pilgrim Trail (Triều Sơn Lộ)', TR, DT), n('Steady Steps (Ổn Bộ)', TR, SR)])
MED('c65 d_arch', ('resist_pct', 'fire'), [n('Clay Furnace (Thổ Lô)', ('resist_pct', 'fire'), HP), n('Kiln Fire (Diêu Hỏa)', ('resist_pct', 'fire'), ('attack_pct', 'hoa'))])
MED('c19 fort', BLK, [n('Hill Fort (Sơn Trại)', BLK, THO), n('Stone City (Thạch Thành)', BLK, CDT)])
MED('c24 castle', RP, [n('Steadfast Citadel (Kiên Thành)', RP, THO), n('Gate Tower (Thành Lâu)', RP, BLK)])
MED('c23 gate', ('can_cot', ''), [n("Miner's Gate (Khoáng Môn)", ('can_cot', ''), ('refining_success', '')), n('Mountain Bones (Sơn Cốt)', ('can_cot', ''), BLK)])
MED('c75 peak_petal', FP, [n('Lotus Peak (Liên Hoa Phong)', FP, AF), n('Array Flag (Trận Kỳ)', FP, TT)])
MED('c78 peak_petal', TT, [n('Gazing Peak (Vọng Nhạc)', TT, FP), n('Climbing High (Đăng Cao)', TT, ('accuracy_pct', ''))])
MED('c75 bailey', WARD, [n('Barbican (Ủng Thành)', WARD, AF), n('Inner City (Nội Thành)', WARD, WEF)])
MED('c78 bailey', ('art_speed_pct', 'formation'), [n('Quicksand Array (Lưu Sa Trận)', ('art_speed_pct', 'formation'), AF),
                                                   n('Array Drill (Luyện Trận)', ('art_speed_pct', 'formation'), ('accuracy_pct', ''))])
MED('c89 terraces', DT, [n('Jade Stairs (Ngọc Giai)', DT, FP), n('Quiet Court (Tĩnh Đình)', DT, TM)])
MED('c48 terraces', BLK, [n('Earthworks (Thổ Lũy)', BLK, ('body_shield_pct', '')), n('Mountain Pass (Quan Ải)', BLK, HP)])
MED('c40 caldera', WEF, [n('Caldera (Hỏa Sơn Khẩu)', WEF, WARD), n('Crater Lake (Thiên Trì)', WEF, ('linh_luc_regen_pct', ''))])
MED('c8 d_arch', HP, [n('Arrow Tower (Tiễn Lâu)', HP, WARD), n('Beacon Tower (Phong Hỏa Đài)', HP, BLK)])
MED('c8 mesa', RFO, [n('Mesa (Cao Nguyên)', RFO, WARD), n('Altar of Earth (Địa Đàn)', RFO, HP)])
MED('c51 peak', ('herb_growth_pct', ''), [n('Medicine Mountain (Dược Sơn)', ('herb_growth_pct', ''), DT), n('Mountain Herbs (Sơn Thảo)', ('herb_growth_pct', ''), HRI)])
MED('c16 henge', THO, [n('Standing Stones (Lập Thạch)', THO, DT), n('Stone Sentinel Maze (Bát Trận Đồ)', THO, ('resist_pen_pct', '')), n('Stone Beam (Thạch Lương)', THO, HP)])
MED('c16 cliff_w', CDT, [n('Precipice (Tuyệt Bích)', CDT, THO), n('Sheer Drop (Huyền Nhai)', CDT, PIER), n('Stone Rain (Thạch Vũ)', CDT, ('attack_pct', 'slow'))])
MED('c16 cliff_e', PIER, [n('Cliff Face (Thạch Bích)', PIER, THO), n('Strange Crag (Kỳ Nham)', PIER, ('crit_chance_pct', '')), n('Mountain Splitter (Phách Sơn)', PIER, ('resist_pen_pct', ''))])
MED('c16 steps', TR, [n('Thousand Steps (Thiên Giai)', TR, HP), n('Long Climb (Phàn Sơn)', TR, SR)])
MED('c104 cairn', ('lifespan_pct', ''), [n('Cairn (Thạch Trủng)', ('lifespan_pct', ''), DT), n('Ancestral Shrine (Tổ Từ)', ('lifespan_pct', ''), TM)])
MED('c51 d_step', SR, [n('Stalactite (Thạch Nhũ)', SR, HP)])
MED('c104 d_step', HRI, [n('Wayside Pavilion (Trường Đình)', HRI, HP)])
MED('c16 d_arch', ('body_shield_pct', ''), [n('Stone Shield (Thạch Thuẫn)', ('body_shield_pct', ''), BLK)])
MED('c902 cloud_gate_roof_east', ('linh_luc_regen_pct', ''), [n('Cloud Gate (Vân Môn)', ('linh_luc_regen_pct', ''), DT),
                                                               n('Flying Eaves (Phi Diêm)', ('linh_luc_regen_pct', ''), ('cultivation_speed_pct', ''))])


# ================= E. Small clusters: one line each by hand (choice 1b); notables = line + a partner =================
HG = ('herb_growth_pct', ''); LR = ('linh_luc_regen_pct', ''); SLOW = ('attack_pct', 'slow'); LIFE = ('lifespan_pct', '')
BS = ('body_shield_pct', ''); CULT = ('cultivation_speed_pct', ''); BONE = ('can_cot', ''); REF = ('refining_success', '')
SM('c2 d2', DT, [('Root of Faith (Tín Căn)', HP)])
SM('c2 a2', THO, [('River Pebble (Noãn Thạch)', BLK)])
SM('c65 c65', ('resist_pct', 'fire'), [('Terracotta Warrior (Đào Dũng)', THO)])
SM('c114 a114', HP, [('Encircling Hills (Quần Sơn)', BLK)])
SM('c117 b117', BLK, [('Flying Peak (Phi Lai Phong)', HP)])
SM('c114 b114', THO, [('Rolling Boulder (Cổn Thạch)', CDT)])
SM('c66 e66', DT, [('Three Steps, One Bow (Tam Bộ Nhất Bái)', TM)])
SM('c65 d_s65', ('attack_pct', 'hoa'), [('Kiln Glow (Diêu Quang)', THO)])
SM('c66 dz66', TM, [('Unshaken Heart (Bất Động Tâm)', DT)])
SM('c117 c117', RP, [('Stubborn Stone (Ngoan Thạch)', HP)])
SM('c66 b66', TR, [('Forbearance (Kham Nhẫn)', DT)])
SM('c24 hook', THO, [('Mountain on the Back (Phụ Sơn)', HP)])
SM('c23 e24', REF, [('Raw Ore (Nguyên Khoáng)', BONE)])
SM('c23 crook', BLK, [('Winding Path (Khúc Kính)', RP)])
SM('c19 top19a', CDT, [('Crag Fang (Nham Nha)', THO)])
SM('c19 d_s19', SLOW, [('Heavy as a Mountain (Trọng Như Sơn)', HP)])
SM('c19 foot19', HP, [('Foothills (Sơn Cước)', BLK)])
SM('c19 mid19b', THO, [('Mountainside (Sơn Yêu)', PIER)])
SM('c36 foot36', HG, [('Well-Field (Tỉnh Điền)', BONE)])
SM('c23 crook2', BONE, [('Mine Shaft (Khoáng Tỉnh)', REF)])
SM('c23 peak_inner', HP, [('Central Peak (Trung Nhạc)', BLK), ('Stone Hut (Thạch Ốc)', RP)])
SM('c36 d_lens', LR, [('Hidden Spring (U Tuyền)', DT)])
SM('c78 d_lens', FP, [('Array Foundation (Trận Cơ)', TT)])
SM('c75 d_arch', AF, [('Array Gate (Trận Môn)', ('art_speed_pct', 'formation'))])
SM('c89 d_arch', TT, [('Palace Lantern (Cung Đăng)', FP)])
SM('c40 crook2', WARD, [('Garrison (Trấn Thủ)', WEF)])
SM('c48 dz48a', BS, [('Turtle Shell (Quy Giáp)', HP)])
SM('c40 peak_petal', FP, [('Guardian Array (Thủ Hộ Trận)', WARD), ('Night Watch (Dạ Tuần)', TT)])
SM('c48 peak_petal', BLK, [('Outer Bailey (Ngoại Quách)', BS)])
SM('c40 d_s40', WEF, [('Boundary Stone (Giới Thạch)', WARD)])
SM('c48 top48', HP, [('Rampart Crest (Lũy Đỉnh)', BS)])
SM('c40 crook', DT, [('Settled Heart (Định Tâm)', FP)])
SM('c75 d_s75', ('art_speed_pct', 'formation'), [('Moving Mountains (Di Sơn)', AF)])
SM('c78 d_s78', AF, [("Geomancer's Compass (La Bàn)", ('accuracy_pct', ''))])
SM('c87 foot', RP, [('Sunken Stance (Trầm Bộ)', RFO)])
SM('c75 fork', FP, [('Ley Point (Địa Huyệt)', DT)])
SM('c48 dz48b', RFO, [('Great Wall (Trường Thành)', BLK)])
SM('c89 d_split', DT, [('Scripture Pavilion (Tàng Kinh Các)', TT)])
SM('c16 d_split', PIER, [('Shattered Stele (Đoạn Bi)', THO)])
SM('c8 d_arch2', WARD, [('City Gate (Thành Môn)', BLK)])
SM('c8 c8', WEF, [('Wall Brick (Thành Chuyên)', WARD)])
SM('c51 dz51a', HG, [('Stone Moss (Thạch Đài)', HRI)])
SM('c16 e16', THO, [('Merit Stele (Công Đức Bi)', DT)])
SM('c104 dz104', LIFE, [('Longevity Rock (Thọ Thạch)', HP)])
SM('c8 a8', HP, [('City Defender (Thủ Thành)', WARD)])
SM('c106 dz106', TM, [('Tomb-Sweeping (Thanh Minh)', LIFE)])
SM('c16 f16', CDT, [('Flying Sand (Phi Sa Tẩu Thạch)', PIER)])
SM('c55 d_s55', SLOW, [('Stone Quarry (Thạch Trường)', PIER)])
SM('c106 a106', DT, [('Ancestral Reverence (Kính Tổ)', TM)])
SM('c51 d_s51', CULT, [('Secluded Dwelling (U Cư)', DT)])
SM('c104 a104', HRI, [('Mineral Spring (Khoáng Tuyền)', HP)])
SM('c16 d_g16', TR, [('Steady as Taishan (Ổn Như Thái Sơn)', BLK)])
SM('c8 f8', RFO, [('Bastion (Bảo Lũy)', HP)])
SM('c16 d_s16', SR, [('Warding Stone (Trấn Thạch)', HP)])
SM('c51 dz51b', FP, [('Grotto-Heaven Array (Động Thiên Trận)', HG)])
SM('c8 d8', BLK, [('Cornerstone (Cơ Thạch)', RP)])
SM('c55 a55', CDT, [('Chisel Strike (Tạc Thạch)', SLOW)])
SM('c51 d_arch', HRI, [('Herb Garden (Dược Viên)', HG)])
SM('c902 end_R', LIFE, [('Eave Tile (Ngõa Đương)', DT)])
SM('c902 jade_spire_east', CULT, [('Jade Spire (Ngọc Tháp)', LIFE)])
SM('c902 immortal_pearl', DT, [('Immortal Pearl (Tiên Châu)', LIFE)])


# ================= Loose small nodes (base map proposal nodes, no cluster): one line per mirrored pair =================
ONE([1947, 1948], ('dao_tam', ''))
ONE([1949, 1951], ('attack_pct', 'tho'))
ONE([1950, 1952], ('khi_huyet_pct', ''))
ONE([1955, 1956], ('block_rating', ''))
ONE([1957, 1958], ('dao_tam', ''))

# ================= B. Keystones =================
KEY('c902 keystone_e', 'No Ward (Vô Hộ)', 'No Ward (Vô Hộ)', [('khi_huyet_pct', '', 30), ('block_rating', '', 20)],
    closes='no ward of any kind')
KEY('c902 keystone_w', 'Open Sky (Không Thiên)', 'Open Sky (Không Thiên)', [('defense_pct', '', 30), ('ward_efficiency_pct', '', 20)],
    closes='artifact power -30 %')
KEY('c902 keystone_rim_R', 'Immovable Mountain (Bất Động Sơn)', 'Immovable Mountain (Bất Động Sơn)',
    [('attack_pct', 'slow', 15), ('khi_huyet_pct', '', 15), ('block_rating', '', 10), ('resist_pct', 'physical', 10)], closes='art speed modifiers do nothing')
KEY('c902 keystone_rim_L', 'Earth Vein Tap (Địa Mạch Dẫn)', 'Earth Vein Tap (Địa Mạch Dẫn)',
    [('formation_power_pct', '', 25), ('linh_luc_regen_inc_pct', '', 25)], closes='no linh lực regeneration while no formation of yours stands')
