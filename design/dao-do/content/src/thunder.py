# Thunder island (Lôi) on v5. Written by hand under content-method.md. Notables in walk order (crown last).
LT = ('attack_pct', 'lightning'); LOI = ('attack_pct', 'loi'); RL = ('resist_pct', 'lightning'); HP = ('khi_huyet_pct', '')
CRIT = ('crit_chance_pct', ''); CD = ('crit_damage_pct', ''); QUICK = ('attack_pct', 'quick'); SPD = ('art_speed_pct', '')
PENL = ('resist_pen_pct', 'lightning'); ACC = ('accuracy_pct', '')

BIG('c932 bolt_down_tree', [
    n('Lightning Rod (Lôi Trượng)', RL, ('block_rating', '')), n('Lightning to Earth (Lôi Nhập Địa)', RL, HP),
    n('Grounding Rod (Tiếp Địa)', RL, ('status_resist_pct', ''), 5, 3),
])
BIG('c932 bolt_out_tree', [
    n('Splitting Sky (Liệt Không)', LT, ('crit_chance_pct', 'lightning')), n('Seeking Bolt (Tầm Lôi)', LT, ACC),
    n('Branching Bolt (Chi Lôi)', ('crit_chance_pct', 'lightning'), CD, 5, 3),
])
BIG('c932 storm_569', [
    n('War Drum (Chiến Cổ)', LT, QUICK), n('Drumroll (Cấp Cổ)', QUICK, SPD), n('Heaven Drum (Thiên Cổ)', LT, CRIT),
    n('Kui Drum (Quỳ Cổ)', ('attack_pct', 'lightning,quick'), ACC), n('Five Drums (Ngũ Lôi Cổ)', LT, ('crit_chance_pct', 'lightning'), 5, 3),
])
BIG('c932 bolt_out_double', [
    n('Flash and Roar (Điện Thiểm Lôi Minh)', CD, LOI), n('Twin Thunder (Song Lôi)', LOI, ACC, 5, 3),
])
BIG('c932 oai_three_tribulations', [
    n('Wind Tribulation (Phong Kiếp)', ('tam_ma_resist_pct', ''), HP), n('Fire Tribulation (Hỏa Kiếp)', HP, ('resist_pct', 'fire')),
    n('Thunder Tribulation (Lôi Kiếp)', ('tam_ma_resist_pct', ''), RL, 5, 3),
])
BIG('c932 open_cloud_567', [
    n('Thunderhead (Lôi Vân)', ('linh_luc_pct', ''), ('linh_luc_on_crit_pct', '')),
    n('Gathering Clouds (Tụ Vân)', ('linh_luc_pct', ''), ('linh_luc_regen_pct', ''), 5, 3),
])
BIG('c932 oai_rim_coursing_thunder', [
    n('Lingering Thunder (Dư Lôi)', ('stack_effect_pct', 'loi,debuff'), LOI), n('Static (Tĩnh Điện)', ('stack_duration_pct', 'loi,debuff'), CRIT),
    n('Coursing Thunder (Lôi Mạch)', ('stack_effect_pct', 'loi,debuff'), ('stack_duration_pct', 'loi,debuff'), 5, 3),
])
BIG('c932 oai_high_thunder_fan', [
    n('Hundred Bolts (Bách Lôi)', ACC, ('attack_pct', 'lightning,quick')),
    n('Thunder Fan (Lôi Phiến)', ('attack_pct', 'lightning,quick'), SPD, 5, 3),
])
BIG('c932 storm_566', [
    n('Sky-Breaking Blow (Phá Thiên Kích)', ('attack_pct', 'loi,slow'), CD), n('Thousand-Jin Swing (Thiên Cân)', ('attack_pct', 'slow'), HP),
    n('Thunderclap (Lôi Đình)', CD, ('pierce_pct', '')), n('Thunder Anvil (Lôi Châm)', ('attack_pct', 'loi,slow'), PENL),
    n("Heaven's Hammer (Thiên Phạt Chùy)", ('attack_pct', 'loi,slow'), ('pierce_pct', ''), effect="Heaven's Verdict (Thiên Phán)"),
])
BIG('c932 bolt_out_chain', [
    n('Flashing Feet (Điện Túc)', SPD, ('basic_speed_pct', '')),
    n('Thunder Step (Lôi Bộ)', SPD, ('evade_pct', ''), effect='First Thunder (Tiên Lôi)'),
])
BIG('c932 storm_586', [
    n('Lightning Whip (Lôi Tiên)', LOI, PENL), n('Storm Eye (Phong Nhãn)', LOI, ('crit_chance_pct', 'lightning')),
    n('Rolling Thunder (Cổn Lôi)', PENL, SPD), n('Purple Mansion (Tử Phủ)', LOI, ('than_hon', '')),
    n('Purple Storm (Tử Lôi Bạo)', LOI, CD, 5, 3),
])
BIG('c932 cloud_585', [
    n('Cloudburst (Sậu Vũ)', ('health_regen_pct', ''), ('linh_luc_regen_inc_pct', '')),
    n('Storm Rain (Bạo Vũ)', ('health_regen_pct', ''), ('healing_taken_pct', ''), 5, 3),
])
BIG('c932 cloud_upper', pat='BBA', nts=[
    n('Gathering Tribulation (Tụ Kiếp)', HP, ('lifespan_pct', '')), n('Dark Clouds (Hắc Vân)', HP, RL),
    n("Heaven's Test (Thiên Khảo)", ('breakthrough_chance', ''), HP), n('Nine Strikes (Cửu Kích)', RL, ('tam_ma_resist_pct', '')),
    n('Life After Tribulation (Kiếp Hậu Dư Sinh)', HP, ('health_regen_pct', '')), n('Thunder Marrow (Lôi Tủy)', ('lifespan_pct', ''), ('can_cot', '')),
    N('Burning Life to Break Through (Thiêu Thọ Phá Cảnh)', cap=('#23', 'T3')),
])
BIG('c932 cloud_584', [
    n('Cloud Soaring (Đằng Vân)', ('evade_pct', ''), ('escape_pct', '')), n('Cloud Veil (Vân Mạc)', ('evade_pct', ''), ('stealth', '')),
    n('Cloud Sea (Vân Hải)', ('evade_pct', ''), ('basic_speed_pct', ''), 5, 3),
])
BIG('c932 cloud_579', [
    n('Thunder Eye (Lôi Nhãn)', ('than_thuc_pct', ''), ('pierce_pct', '')), n('Far Sight (Thiên Lý Nhãn)', ('than_thuc_pct', ''), ACC),
    n("Thunder God's Gaze (Lôi Thần Mục)", ('pierce_pct', ''), ACC, 5, 3),
])
BIG('c932 cloud_583', [
    n("Heaven's Rumble (Thiên Lôi Minh)", ('x_soul', ''), ('soul_res_pct', '')),
])
BIG('c932 arc_cloud_584', [
    n('Ball Lightning (Lôi Cầu)', ('art_cost_pct', ''), ('reserve_eff_pct', '')), n('Arc Cloud (Hồ Vân)', ('art_cost_pct', ''), ('linh_luc_pct', ''), 5, 3),
])
BIG('c932 cloud_581', [
    n('Struck Bones (Lôi Kích Cốt)', ('can_cot', ''), RL), n('Scorched Skin (Tiêu Phu)', RL, HP),
    n('Tempered by Lightning (Lôi Luyện)', ('can_cot', ''), HP, 5, 3),
])
BIG('c932 arc_cloud_582', [
    n('Rainbow (Thải Hồng)', ('co_duyen_pct', ''), ('travel_speed_pct', '')),
    n('Clear Sky (Tình Không)', ('co_duyen_pct', ''), ('khi_van', ''), 5, 3),
])


# ================= D. Medium clusters and start figure =================
MED('base9', LOI, [n('Spring Thunder (Xuân Lôi)', LOI, HP), n('Thunder Seed (Lôi Chủng)', LT, SPD), n('Storm Heart (Lôi Tâm)', RL, ('tam_ma_resist_pct', '')),
                   n('Thunder Root (Lôi Căn)', LOI, ('crit_chance_pct', 'lightning'), 5, 3)])
MED('c932 bolt_down_y', ('crit_chance_pct', 'lightning'), [n('Thunder Trident (Lôi Xoa)', ('crit_chance_pct', 'lightning'), CD), n('Falling Thunder (Lạc Lôi)', ('crit_chance_pct', 'lightning'), PENL)])
MED('c932 oai_twin_channels', ('linh_luc_regen_pct', ''), [n('Twin Channels (Song Mạch)', ('linh_luc_regen_pct', ''), SPD), n('Charged Path (Điện Lộ)', ('linh_luc_regen_pct', ''), LOI)])
MED('c932 bolt_out_y', ('crit_chance_pct', 'lightning'), [n('Bolt from the Blue (Tình Thiên Phích Lịch)', ('crit_chance_pct', 'lightning'), LT),
                                                         n('Divided Lightning (Phân Lôi)', ('crit_chance_pct', 'lightning'), CD)])
MED('c932 bolt_w2', PENL, [n('Thunder Net (Lôi Võng)', PENL, SPD), n('Thunder Thread (Lôi Ti)', PENL, LOI)])
MED('c932 oai_inner_yang', HP, [n('Inner Yang (Nội Dương)', HP, RL), n('Yang Thunder (Dương Lôi)', HP, LOI)])
MED('c932 bolt_w1', ('basic_speed_pct', ''), [n('Swift Thunder (Tấn Lôi)', ('basic_speed_pct', ''), LT), n('Flicker Strike (Thiểm Kích)', ('basic_speed_pct', ''), ACC)])
MED('c932 oai_stone_cleaver', ('pierce_pct', ''), [n('Stone Cleaver (Phách Thạch)', ('pierce_pct', ''), ('attack_pct', 'loi,slow')), n('Split Boulder (Khai Nham)', ('pierce_pct', ''), CD)])
MED('c932 oai_sky_gate', ('linh_luc_on_crit_pct', ''), [n('Sky Gate (Thiên Môn)', ('linh_luc_on_crit_pct', ''), SPD), n('Open Heavens (Khai Thiên)', ('linh_luc_on_crit_pct', ''), LT)])
MED('c932 bolt_w5', ('crit_chance_pct', 'lightning'), [n('Lightning Dodge (Tị Lôi)', ('crit_chance_pct', 'lightning'), ('evade_pct', '')), n('Flash Step (Thiểm Bộ)', ('crit_chance_pct', 'lightning'), SPD)])


# ================= E. Small clusters =================
SM('c932 oai_jade_counterstrike', RL, [('Jade Counterstrike (Ngọc Phản Kích)', ('block_rating', ''))])
SM('c932 zig_in_556', LT, [('Hidden Bolt (Ám Lôi)', ('crit_chance_pct', 'lightning'))])
SM('c932 zig_in_554', LOI, [('Lightning Serpent (Lôi Xà)', SPD)])
SM('c932 oai_inner_yin', HP, [('Inner Yin (Nội Âm)', ('tam_ma_resist_pct', ''))])
SM('c932 oai_returning_spark', ('linh_luc_on_crit_pct', ''), [('Returning Spark (Hồi Điện)', CRIT)])
SM('c932 oai_spoke_creeper', ACC, [('Wandering Spark (Du Điện)', LT)])
SM('c932 oai_split_seal', CD, [('Shattered Seal (Toái Ấn)', LOI), ('Seal Breaker (Phá Ấn)', ('pierce_pct', ''))])

KEY('c932 keystone_tip', 'Glass Meridians (Lưu Ly Kinh Mạch)', 'Glass Meridians (Lưu Ly Kinh Mạch)',
    [('attack_pct', 'lightning', 25), ('art_speed_pct', '', 25)], closes='maximum health -25 %; body shields hold half')
