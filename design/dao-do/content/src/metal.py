# Metal (Kim) content on v5. Written by hand under design/dao-do/content-method.md. Notables in walk order (crown last).

# ================= C. Big pictures =================
BIG('c27 coin', [
    N('Dew Drop (Lộ Châu)', ('linh_luc_regen_pct', '', 4), ('linh_luc_regen_inc_pct', '', 4)),
    N('Cold Dawn (Hàn Hiểu)', ('linh_luc_regen_pct', '', 4), ('can_cot', '', 4)),
    N('Autumn Dew (Thu Lộ)', ('linh_luc_regen_pct', '', 5), ('linh_luc_pct', '', 3)),
])
BIG('c30 bell', [
    N('Bell Rim (Chung Duyên)', ('defense_pct', '', 4), ('block_rating', '', 4)),
    N('Golden Hum (Kim Âm)', ('defense_pct', '', 4), ('soul_res_pct', '', 4)),
    N('Golden Bell (Kim Chung Tráo)', ('defense_pct', '', 5), ('ward_efficiency_pct', '', 3)),
])
BIG('c20 coins', [
    N('Ore Vein (Khoáng Mạch)', ('refining_success', '', 4), ('can_cot', '', 4)),
    N('Copper Cash (Đồng Tiền)', ('refining_success', '', 4), ('artifact_power_pct', '', 4)),
])
BIG('c34 bow', [
    N('Taut String (Khẩn Huyền)', ('accuracy_pct', '', 4), ('attack_pct', 'kim', 4)),
    N('Arrow on the String (Tiễn Tại Huyền)', ('accuracy_pct', '', 4), ('crit_chance_pct', 'kim', 4)),
    N('Drawn Bow (Mãn Cung)', ('attack_pct', 'kim', 5), ('crit_damage_pct', 'kim', 3)),
])
BIG('c30 compass', [
    N('Lodestone (Từ Thạch)', ('co_duyen_pct', '', 4), ('stealth', '', 4)),
    N('Dowsing (Tầm Mạch)', ('co_duyen_pct', '', 4), ('travel_speed_pct', '', 4)),
    N('Hidden Cache (Tàng Bảo)', ('co_duyen_pct', '', 4), ('refining_success', '', 4)),
    N('Buried Vault (Kim Tàng Khố)', ('co_duyen_pct', '', 5), ('khi_van', '', 3)),
])
BIG('c34 trident', [
    N('Sword Heart (Kiếm Tâm)', ('attack_pct', 'sword', 4), ('crit_damage_pct', 'sword', 4)),
    N('Point of the Blade (Kiếm Phong)', ('crit_damage_pct', 'sword', 4), ('accuracy_pct', '', 4)),
    N('Sword Intent (Kiếm Ý)', ('attack_pct', 'sword', 5), ('crit_chance_pct', 'sword', 3)),
])
BIG('c20 gong', [
    N('Gong Stroke (Minh La)', ('soul_res_pct', '', 4), ('timer_resist_pct', '', 4)),
    N('Woken Mind (Tỉnh Tâm)', ('timer_resist_pct', '', 4), ('than_thuc_pct', '', 4)),
    N('Clear Gong (Thanh La)', ('soul_res_pct', '', 5), ('status_resist_pct', '', 3)),
])
BIG('c50 arcs', [
    N('Metal Skin (Kim Phu)', ('khi_huyet_pct', '', 4), ('linh_luc_pct', '', 4)),
    N('Vajra Bones (Kim Cương Cốt)', ('can_cot', '', 4), ('khi_huyet_pct', '', 4)),
    N('Iron Blood (Thiết Huyết)', ('khi_huyet_pct', '', 4), ('health_regen_inc_pct', '', 4)),
    N('Blood Commands Spirit (Huyết Ngự Linh)', ('khi_huyet_pct', '', 2), cap=('#4', 'T2'),
      alt=[('khi_huyet_pct', '', 5), ('linh_luc_pct', '', 3)], alt_name='Vajra Body (Kim Cương Thân)'),
])
BIG('c77 wheel', [
    N('Ten-Year Grinding (Thập Niên Ma Kiếm)', ('crit_chance_pct', '', 4), ('linh_luc_on_crit_pct', '', 4)),
    N('Keen Edge (Phong Nhuệ)', ('crit_chance_pct', '', 4), ('crit_damage_pct', '', 4)),
    N('Whetstone Wheel (Ma Thạch Luân)', ('linh_luc_on_crit_pct', '', 5), ('linh_luc_regen_pct', '', 3)),
])
BIG('c41 crown', [
    N('Stern Rule (Nghiêm Quy)', ('can_cot', '', 4), ('khi_huyet_pct', '', 4)),
    N('Measured Breath (Điều Tức)', ('can_cot', '', 4), ('linh_luc_regen_inc_pct', '', 4)),
    N('Iron Discipline (Thiết Luật)', ('can_cot', '', 5), ('status_resist_pct', '', 3)),
])
BIG('c73 ding', [
    N('Bronze Cauldron (Đồng Đỉnh)', ('refining_success', '', 4), ('artifact_power_pct', '', 4)),
    N('Forging Fire (Luyện Bảo Hỏa)', ('refining_success', '', 4), ('than_thuc_pct', '', 4)),
    N('Nurtured Treasure (Ôn Dưỡng)', ('artifact_power_pct', '', 4), ('element_affinity_pct', '', 4)),
    N('Treasure Nurtured Within (Dưỡng Bảo Nội Thể)', ('refining_success', '', 2), cap=('#3', 'T2'),
      pending=[('refine_grade_chance', '', 2)],
      alt=[('refining_success', '', 5), ('artifact_power_pct', '', 3)], alt_name='Spirit Furnace (Linh Lô)'),
])
BIG('c10 rack', [
    N('Sword Rack (Kiếm Giá)', ('attack_pct', 'sword', 4), ('artifact_attack_pct', '', 4)),
    N('Flying Sword (Phi Kiếm)', ('artifact_attack_pct', '', 4), ('art_speed_pct', 'sword', 4)),
    N('Sword Array (Kiếm Trận)', ('attack_pct', 'sword', 4), ('accuracy_pct', '', 4)),
    N('Twin Arms in Harmony (Song Khí Hợp Bích)', ('attack_pct', 'sword', 2), cap=('#1', 'T2'),
      alt=[('attack_pct', 'sword', 5), ('artifact_attack_pct', '', 3)], alt_name='Hundred Swords (Bách Kiếm)'),
])
BIG('c10 shield', [
    N('Shield Boss (Thuẫn Tâm)', ('block_rating', '', 4), ('artifact_defense_pct', '', 4)),
    N('Horse Stance (Mã Bộ)', ('block_rating', '', 4), ('khi_huyet_pct', '', 4)),
    N('Bronze Shield (Đồng Thuẫn)', ('block_rating', '', 5), ('resist_pct', 'physical', 3)),
])
BIG('c57 sawblade', [
    N('Bleak Autumn (Túc Sát)', ('crit_chance_pct', 'kim', 4), ('crit_damage_pct', 'kim', 4)),
    N('Autumn Wind (Thu Phong)', ('crit_chance_pct', 'kim', 4), ('art_speed_pct', 'kim', 4)),
    N('Autumn Scythe (Thu Sát Liêm)', ('crit_damage_pct', 'kim', 5), ('attack_pct', 'kim', 3)),
])
BIG('c10 hammer', [
    N('Armour Piercer (Xuyên Giáp)', ('resist_pen_pct', 'physical', 4), ('attack_pct', 'kim', 4)),
    N('Piercing Arrowhead (Xuyên Kim Tiễn)', ('resist_pen_pct', 'physical', 5), ('pierce_pct', '', 3)),
])
BIG('c10 sword', [
    N('Quick Blade (Khoái Kiếm)', ('art_speed_pct', 'sword', 4), ('attack_pct', 'sword,kim', 4)),
    N('Myriad Cuts (Vạn Trảm)', ('art_speed_pct', 'sword', 4), ('crit_chance_pct', 'sword', 4)),
    N('Ten Thousand Edges (Vạn Nhận)', ('art_speed_pct', 'sword', 5), ('crit_damage_pct', 'sword', 3)),
])
BIG('c903 pentagons R', [
    N('Red Gold (Xích Kim)', ('artifact_power_pct', '', 4), ('element_affinity_pct', '', 4)),
    N('Snow Silver (Tuyết Ngân)', ('artifact_power_pct', '', 4), ('artifact_defense_pct', '', 4)),
    N('Green Bronze (Thanh Đồng)', ('element_affinity_pct', '', 4), ('artifact_attack_pct', '', 4)),
    N('Five Metals (Ngũ Kim)', ('artifact_power_pct', '', 5), ('refining_success', '', 3)),
])
BIG('c903 linked rings', [
    N('Bronze Mirror (Đồng Kính)', ('than_thuc_pct', '', 4), ('artifact_attack_pct', '', 4)),
    N('Twin Reflection (Song Ảnh)', ('than_thuc_pct', '', 4), ('accuracy_pct', '', 4)),
    N('Nine Linked Rings (Cửu Liên Hoàn)', ('artifact_attack_pct', '', 4), ('artifact_power_pct', '', 4)),
    N('Mirror Sense (Kính Thức)', ('than_thuc_pct', '', 4), ('soul_res_pct', '', 4)),
    N('Bright Mirror (Minh Kính)', ('than_thuc_pct', '', 4), ('ngo_tinh', '', 4)),
    N('Split Thought (Phân Niệm)', ('artifact_attack_pct', '', 4), ('art_speed_pct', '', 4)),
    N('Divided Divine Sense (Thần Thức Phân Hóa)', ('than_thuc_pct', '', 2), cap=('#2', 'T2')),
])
BIG('c903 weiqi board', [
    N('Black Stone (Hắc Tử)', ('lifespan_pct', '', 4), ('ngo_tinh', '', 4)),
    N('White Stone (Bạch Tử)', ('ngo_tinh', '', 4), ('than_thuc_pct', '', 4)),
    N('Eye Space (Nhãn Vị)', ('lifespan_pct', '', 4), ('accuracy_pct', '', 4)),
    N('Ladder (Chinh Tử)', ('pierce_pct', '', 4), ('ngo_tinh', '', 4)),
    N('Ko Fight (Tranh Kiếp)', ('ngo_tinh', '', 4), ('tam_ma_resist_pct', '', 4)),
    N('Endgame (Thu Quan)', ('lifespan_pct', '', 4), ('cultivation_speed_pct', '', 4)),
    N('Rotten Axe Handle (Lạn Kha)', ('lifespan_pct', '', 5), ('tam_ma_resist_pct', '', 3)),
])

# ================= D. Medium clusters and start figures =================
BONE = ('can_cot', ''); KIM = ('attack_pct', 'kim'); SW = ('attack_pct', 'sword'); CRK = ('crit_chance_pct', 'kim'); CDK = ('crit_damage_pct', 'kim')
ACC = ('accuracy_pct', ''); PENP = ('resist_pen_pct', 'physical'); PHY = ('attack_pct', 'physical'); HP = ('khi_huyet_pct', '')
BLK = ('block_rating', ''); WARD = ('defense_pct', ''); AP = ('artifact_power_pct', ''); AD = ('artifact_defense_pct', '')
REF = ('refining_success', ''); CRIT = ('crit_chance_pct', ''); CD = ('crit_damage_pct', ''); SPK = ('art_speed_pct', 'kim')
SPS = ('art_speed_pct', 'sword'); CRS = ('crit_chance_pct', 'sword'); LL = ('linh_luc_pct', ''); SOULR = ('soul_res_pct', '')
MED('base3', BONE, [n('Metal Marrow (Kim Tủy)', BONE, KIM), n('Steel Frame (Cương Khu)', BONE, HP), n('Fine Steel (Tinh Cương)', BONE, CRK),
                    n('Tempered Bone (Luyện Cốt)', BONE, BLK), n('Edge of Autumn (Thu Nhận)', BONE, SW), n('Metal Root (Kim Căn)', KIM, CRK, 5, 3)])
MED('base13', BONE, [n('Metal Seal (Kim Ấn)', BONE, KIM), n('Sword Spine (Kiếm Tích)', BONE, CRIT)])
MED('c4 lock W4', AD, [n('Golden Lock (Kim Tỏa)', AD, BONE)])
MED('c4 coin W1', REF, [n('Spirit Coin (Linh Tiền)', REF, ('co_duyen_pct', ''))])
MED('c61 coin W1', ('element_affinity_pct', ''), [n('Charm Coin (Yểm Thắng Tiền)', ('element_affinity_pct', ''), ('khi_van', ''))])
MED('c68 bell', WARD, [n('Ritual Bell (Pháp Linh)', WARD, SOULR), n('Dawn Toll (Hiểu Chung)', WARD, ('status_resist_pct', '')),
                       n('Great Bell Toll (Hồng Chung)', WARD, BLK)])
MED('c113 lock W4', BLK, [n('Binding Chain (Tỏa Liên)', BLK, HP)])
MED('c61 iron fan', SPK, [n('Iron Fan (Thiết Phiến)', SPK, ACC), n('Fan Edge (Phiến Phong)', SPK, KIM)])
MED('c61 spade', REF, [n('Spade Money (Bố Tệ)', REF, BONE), n('Bronze Spade (Đồng Sạn)', REF, AP)])
MED('c61 ingot', AP, [n('Silver Ingot (Ngân Đĩnh)', AP, REF), n('Horseshoe Gold (Mã Đề Kim)', AP, ('khi_van', '')), n('Treasury Seal (Khố Ấn)', AP, AD)])
MED('c68 bagua', SOULR, [n('Heaven Trigram (Càn Quái)', SOULR, BONE), n('Lake Trigram (Đoài Quái)', SOULR, ('than_thuc_pct', ''))])
MED('c116 plate', AD, [n('Heart-Guard Mirror (Hộ Tâm Kính)', AD, HP)])
MED('c34 d_arch_1709', CRS, [n('Sword Rainbow (Kiếm Hồng)', CRS, SW), n('Crossguard (Kiếm Cách)', CRS, BLK)])
MED('c27 spear', PHY, [n('Spear Thrust (Thứ Thương)', PHY, ACC), n('Long Spear (Trường Thương)', PHY, PENP)])
MED('c20 knives W3', CRK, [n('Throwing Knives (Phi Đao)', CRK, ACC)])
MED('c27 knives W3', CDK, [n('Twin Knives (Song Đao)', CDK, KIM)])
MED('c30 blade W2', KIM, [n('Hidden Edge (Tàng Phong)', KIM, ('stealth', '')), n('Sleeve Blade (Tụ Lý Đao)', KIM, CRIT)])
MED('c34 blade W2', SW, [n('Short Sword (Đoản Kiếm)', SW, SPS), n('Sword Shine (Kiếm Quang)', SW, ACC)])
MED('c34 whip', PENP, [n('Steel Whip (Cương Tiên)', PENP, KIM), n('Lashing (Tiên Kích)', PENP, CRIT)])
MED('c27 arrow', PENP, [n('Wolf-Tooth Arrow (Lang Nha Tiễn)', PENP, KIM), n('Barbed Arrow (Câu Tiễn)', PENP, CD), n('Fletching (Tiễn Vũ)', PENP, ACC)])
MED('c27 fan', LL, [n('Dew Fan (Lộ Phiến)', LL, ('linh_luc_regen_inc_pct', '')), n('Hundred-Folded Steel (Bách Luyện Cương)', LL, WARD), n('Feather Fan (Vũ Phiến)', LL, SPK)])
MED('c30 sickle', CRK, [n('Sickle Moon (Liêm Nguyệt)', CRK, ('co_duyen_pct', '')), n('Harvest Sickle (Thu Liêm)', CRK, CDK)])
MED('c95 moon', CD, [n('Moon Blade (Nguyệt Nhận)', CD, KIM), n('New Moon Cut (Tân Nguyệt Trảm)', CD, CRIT)])
MED('c90 moon', SPK, [n('Cold Gleam (Hàn Quang)', SPK, CRIT), n('Waning Moon (Tàn Nguyệt)', SPK, KIM)])
MED('c90 sabre', SW, [n('Ring Sabre (Hoàn Đao)', SW, HP), n('Sweeping Sabre (Hoành Đao)', SW, ('crit_damage_pct', 'sword'))])
MED('c50 hook swords', BONE, [n('Hook Swords (Câu Kiếm)', BONE, SW), n('Tiger-Head Hooks (Hổ Đầu Câu)', BONE, BLK)])
MED('c77 spear', CD, [n('Plum Blossom Spear (Mai Hoa Thương)', CD, ('linh_luc_on_crit_pct', ''))])
MED('c95 blade', KIM, [n('Out of the Scabbard (Xuất Sao)', KIM, CRK)])
MED('c10 blade', AD, [n('Hanging Blade (Huyền Kiếm)', AD, SW)])
MED('c58 star', CRIT, [n('Death Star (Sát Tinh)', CRIT, CDK), n('Flying Dart (Phi Tiêu)', CRIT, ACC), n('Autumn Star (Thu Tinh)', CRIT, KIM)])
MED('c9 chain', ACC, [n('Chained Swords (Liên Kiếm)', ACC, SW), n('Meteor Hammer (Lưu Tinh Chùy)', ACC, ('artifact_attack_pct', ''))])
MED('c9 chevron 2', CRS, [n('Wild Goose Formation (Nhạn Hành Trận)', CRS, SW), n('Arrowhead Array (Phong Thỉ Trận)', CRS, SPS)])
MED('c9 chevron 1', ('crit_damage_pct', 'sword'), [n('Crane Wing (Hạc Dực)', ('crit_damage_pct', 'sword'), SW),
                                                  n('Vanguard (Tiên Phong)', ('crit_damage_pct', 'sword'), ACC)])
MED('c10 axe', PHY, [n('Battle Axe (Chiến Phủ)', PHY, CD), n('Mountain Cleave (Khai Sơn)', PHY, PENP)])
MED('c58 claw', CDK, [n('Eagle Claw (Ưng Trảo)', CDK, KIM), n('Tiger Claw (Hổ Trảo)', CDK, CRK), n('Sinew-Splitting (Phân Cân Thác Cốt)', CDK, PENP)])
MED('c102 ji', BLK, [n('Sky Halberd (Phương Thiên Kích)', BLK, PHY), n('Halberd Guard (Kích Vệ)', BLK, HP)])


# ================= E. Small clusters: one line each by hand (choice 1b); notables = line + a partner =================
LR = ('linh_luc_regen_pct', ''); SR = ('status_resist_pct', ''); EA = ('element_affinity_pct', ''); AA = ('artifact_attack_pct', '')
SM('c4 sword R', SW, [('Small Sword (Tiểu Kiếm)', BONE)])
SM('c4 crescent_L', CRK, [('Autumn Water Sword (Thu Thủy Kiếm)', KIM)])
SM('c4 d_bead_1702', BONE, [('Iron Shirt (Thiết Bố Sam)', HP)])
SM('c4 rings W5', AP, [('Qiankun Circle (Càn Khôn Quyển)', BONE)])
SM('c116 rings W5', AD, [('Warding Bracers (Hộ Uyển)', BLK)])
SM('c113 d_diamond_1518', CDK, [('Jade Carving (Trác Ngọc)', CRK)])
SM('c116 d_hairpin_1699', ACC, [('Embroidery Needle (Tú Hoa Châm)', KIM)])
SM('c113 d_hook_1691', BLK, [('Bronze Wall (Đồng Tường)', BONE)])
SM('c68 crescent_1700', WARD, [('Bell Tower (Chung Lâu)', SOULR)])
SM('c116 fork', KIM, [('Three-Pointed Blade (Tam Tiêm Đao)', CRK), ('Serpent Spear (Xà Mâu)', ACC)])
SM('c116 crescent', BONE, [('Marrow Washing (Tẩy Tủy)', HP)])
SM('c68 hook_1716', SOULR, [('Bronze Drum (Đồng Cổ)', WARD)])
SM('c113 crook', PHY, [('Bone-Breaker (Toái Cốt)', PENP)])
SM('c61 hook_1705', REF, [('Smelting (Dã Luyện)', BONE)])
SM('c61 diamond', AP, [('Treasure Pearl (Bảo Châu)', EA)])
SM('c68 diamond', ('than_thuc_pct', ''), [('Soul-Calming Jade (Định Hồn Ngọc)', SOULR)])
SM('c30 d_hook_1520', ('co_duyen_pct', ''), [('Taigong Fishing (Thái Công Điếu Ngư)', WARD)])
SM('c20 d_wave_1491', REF, [('Sifting Gold (Đào Kim)', ACC)])
SM('c30 d_crook_253', WARD, [('Golden Armour (Kim Giáp)', BLK)])
SM('c27 d_arch_1744', LR, [('Dew Drinking (Ẩm Lộ)', BONE), ('White Dew (Bạch Lộ)', LL)])
SM('c34 d_arch_1743', SW, [('Piercing the Willow (Xuyên Dương)', ACC), ('Sword Bow (Kiếm Cung)', CRS)])
SM('c20 d_arch_1750', SOULR, [('Chime Bells (Biên Chung)', ('timer_resist_pct', '')), ('Mine Gallery (Khoáng Động)', REF)])
SM('c30 d_bead_1521', ('stealth', ''), [('Sunken Pearl (Trầm Châu)', ('co_duyen_pct', ''))])
SM('c77 d_diamond_1741', CRIT, [('Sword Sparks (Kiếm Hoa)', ('linh_luc_on_crit_pct', ''))])
SM('c41 d_crook_1521', BONE, [('Precept Rod (Giới Xích)', HP)])
SM('c73 d_hairpin_1748', REF, [('Bellows (Phong Tương)', AP)])
SM('c50 d_hook_1526', HP, [('Bronze Skin, Iron Bones (Đồng Bì Thiết Cốt)', BONE)])
SM('c50 d_crescent_1746', LL, [('Spirit Marrow (Linh Tủy)', HP)])
SM('c73 crescent B', AP, [('Cauldron Ear (Đỉnh Nhĩ)', REF), ('Treasure Glow (Bảo Quang)', ('than_thuc_pct', ''))])
SM('c95 crescent B', CD, [('Frost Moon (Sương Nguyệt)', KIM), ('Snow Blade (Tuyết Nhận)', CRIT)])
SM('c95 crook', KIM, [('Chasing the Moon (Truy Nguyệt)', SPK)])
SM('c41 d_crescent_1752', SR, [('Proud Bones (Ngạo Cốt)', BONE)])
SM('c50 d_fork_1762', BONE, [('Body Refining (Luyện Thể)', HP), ('Bone Forging (Đoán Cốt)', BLK)])
SM('c50 hairpin_1764', ('health_regen_inc_pct', ''), [('Blood Spring (Huyết Tuyền)', HP)])
SM('c90 diamond', SPK, [('Willow-Leaf Sabre (Liễu Diệp Đao)', SW)])
SM('c41 d_hook_1522', HP, [('Golden Headband (Kim Cô)', BONE)])
SM('c41 d_hairpin_1754', BONE, [('Fasting Vows (Trai Giới)', SR)])
SM('c50 d_crook_1527', ('linh_luc_regen_inc_pct', ''), [('Lung Qi (Phế Khí)', HP)])
SM('c102 d_crook_1763', BLK, [('Reclining Moon Glaive (Yển Nguyệt Đao)', PHY)])
SM('c100 d_ring_1752', PHY, [('Sweeping Strike (Hoành Tảo)', BLK), ('Halberd Shot at the Gate (Viên Môn Xạ Kích)', ACC)])
SM('c102 d_ring_1761', BLK, [('Forest of Halberds (Kích Lâm)', HP), ('Deflection (Hóa Kình)', PHY)])
SM('c100 d_hairpin_1522', PENP, [('Armour Breaker (Phá Giáp)', PHY)])
SM('c58 d_tadpole_1753', CRK, [('Rice Reaping (Cát Hòa)', CDK)])
SM('c57 d tadpole 1763', CDK, [('Scythe Wind (Liêm Phong)', CRK)])
SM('c10 hairpin_1767', BLK, [('Shield Formation (Thuẫn Trận)', AD)])
SM('c102 whip', ACC, [('Nine-Section Whip (Cửu Tiết Tiên)', PHY)])
SM('c102 d_ring_1976', HP, [('Thousand-Catty Drop (Thiên Cân Trụy)', BLK), ('Sinew Changing (Dịch Cân)', BONE)])
SM('c100 crescent', CRIT, [('Moon-Fang Halberd (Nguyệt Nha Kích)', PHY)])
SM('c57 d_hairpin_1729', CRK, [('Frost Descent (Sương Giáng)', SPK)])
SM('c58 d hairpin 1719', SPK, [('Start of Autumn (Lập Thu)', CRK)])
SM('c102 d_hook_1728', PENP, [('Horse-Cutting Sabre (Trảm Mã Đao)', CD)])
SM('c10 d_hook_1734', SW, [('Sword Case (Kiếm Hạp)', AA)])
SM('c9 d_arch_1725', SPS, [('Swift Draw (Bạt Kiếm)', SW), ('Blade Rain (Kiếm Vũ)', CRS)])
SM('c58 d_crook_1718', CDK, [('Autumn Execution (Thu Quyết)', KIM)])
SM('c903 ring_1717', ('than_thuc_pct', ''), [('Demon-Revealing Mirror (Chiếu Yêu Kính)', AA)])
SM('c903 kite', ('lifespan_pct', ''), [('Watching the Game (Quan Kỳ)', ('ngo_tinh', ''))])
SM('c903 diamond_R', EA, [('Gold Essence (Kim Tinh)', AP)])
SM('c903 guard_R', AD, [('Shoulder Guard (Hộ Kiên)', BLK)])
SM('c903 great blade', SW, [('Great Blade (Đại Kiếm)', ('crit_damage_pct', 'sword'))])


# ================= Loose small nodes (base map proposal nodes, no cluster): one line per mirrored pair =================
ONE([1963, 1964], ('can_cot', ''))
ONE([1965, 1967], ('attack_pct', 'kim'))
ONE([1966, 1968], ('khi_huyet_pct', ''))
ONE([1971, 1972], ('crit_chance_pct', 'kim'))
ONE([1973, 1974], ('can_cot', ''))

# ================= B. Keystones =================
KEY('c903 keystone +12', 'Called Blow (Báo Chiêu)', 'Called Blow (Báo Chiêu)',
    [('crit_damage_pct', '', 25), ('art_speed_pct', '', 25)], closes='crit chance cap 0.50 -> 0.35')
KEY('c903 keystone -12', 'Ten Thousand Swords Return (Vạn Kiếm Quy Tông)', 'Ten Thousand Swords Return (Vạn Kiếm Quy Tông)',
    [('attack_pct', 'sword', 25), ('artifact_attack_pct', '', 25)], closes='only arts with the sword form tag may be slotted; wards -30 %')
KEY('c903 keystone_rim_L', 'Unyielding Breath (Bất Khuất)', 'Unyielding Breath (Bất Khuất)',
    [('can_cot', '', 25), ('block_rating', '', 25)], closes='maximum health -15 %')
KEY('c903 keystone_rim_R', 'Autumn Harvest (Thu Hoạch)', 'Autumn Harvest (Thu Hoạch)',
    [('linh_luc_on_crit_pct', '', 30), ('crit_chance_pct', '', 20)], closes='linh lực regeneration 0')

# ---- start keystone (added 2026-11-19) ----
KEY('c903 keystone_start', 'Keen Edge (Lợi Phong)', 'Keen Edge (Lợi Phong)',
    [('pierce_pct', '', 25), ('crit_damage_pct', '', 25)], closes='your own block rating counts nothing')
