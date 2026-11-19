# Wood (Mộc) content on v5, with the Wind cells 43-44. Written by hand under design/dao-do/content-method.md.
# Notables in walk order (crown last).

# ================= C. Big pictures =================
BIG('c64 tendrils', [
    N('New Growth (Tân Sinh)', ('cultivation_speed_pct', '', 4), ('health_regen_inc_pct', '', 4)),
    N('Tender Shoots (Nộn Chi)', ('cultivation_speed_pct', '', 5), ('khi_van', '', 3)),
])
BIG('c31 fir', [
    N('Fir Needles (Sam Châm)', ('status_resist_pct', '', 4), ('timer_resist_pct', '', 4)),
    N('Winter Green (Đông Thanh)', ('status_resist_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Upright Trunk (Trực Can)', ('timer_resist_pct', '', 4), ('block_rating', '', 4)),
    N('Evergreen (Thường Thanh)', ('status_resist_pct', '', 5), ('health_regen_pct', '', 3)),
])
BIG('c31 pinecone', [
    N('Pine Bark (Tùng Bì)', ('can_cot', '', 4), ('status_resist_pct', 'poison', 4)),
    N('Pine Needle Tea (Tùng Châm Trà)', ('status_resist_pct', 'poison', 4), ('health_regen_inc_pct', '', 4)),
    N('Pine Strength (Tùng Lực)', ('can_cot', '', 5), ('khi_huyet_pct', '', 3)),
])
BIG('c25 morningglory', [
    N('Poison Bloom (Độc Hoa)', ('attack_pct', 'poison', 4), ('stack_effect_pct', 'moc,debuff', 4)),
    N('Black Seeds (Hắc Sửu)', ('stack_effect_pct', 'moc,debuff', 4), ('stack_duration_pct', 'moc,debuff', 4)),
    N('Morning Glory (Khiên Ngưu)', ('attack_pct', 'poison', 5), ('attack_pct', 'over_time', 3)),
])
BIG('c35 wreath', [
    N('Laurel Leaf (Nguyệt Quế Diệp)', ('mi_luc', '', 4), ('mission_income_pct', '', 4)),
    N("Victor's Crown (Quế Miện)", ('mi_luc', '', 4), ('khi_van', '', 4)),
    N('Laurel Wreath (Nguyệt Quế Hoàn)', ('mission_income_pct', '', 5), ('khi_van', '', 3)),
])
BIG('c31 bamboo1', [
    N('Bamboo Joint (Trúc Tiết)', ('basic_speed_pct', '', 4), ('crit_chance_pct', 'moc', 4)),
    N('Bamboo Staff (Trúc Trượng)', ('basic_speed_pct', '', 4), ('accuracy_pct', '', 4)),
    N('Green Bamboo Strike (Thanh Trúc Kích)', ('crit_chance_pct', 'moc', 5), ('crit_damage_pct', 'moc', 3)),
])
BIG('c21 seed', [
    N('First Sprout (Sơ Nha)', ('khi_van', '', 4), ('co_duyen_pct', '', 4)),
    N('Two Leaves (Song Diệp)', ('khi_van', '', 4), ('cultivation_speed_pct', '', 4)),
    N('Spring Sprout (Xuân Nha)', ('khi_van', '', 5), ('herb_growth_pct', '', 3)),
])
BIG('c31 bamboo2', [
    N('Swaying Bamboo (Diêu Trúc)', ('art_speed_pct', 'moc', 4), ('evade_pct', '', 4)),
    N('Grove Shade (Trúc Ấm)', ('evade_pct', '', 4), ('stealth', '', 4)),
    N('Bamboo Grove (Trúc Lâm)', ('art_speed_pct', 'moc', 5), ('accuracy_pct', '', 3)),
])
BIG('c31 bamboo3', [
    N('Hollow Heart (Hư Tâm)', ('art_cost_pct', 'moc', 4), ('linh_luc_regen_inc_pct', '', 4)),
    N('Bamboo Flute (Trúc Địch)', ('linh_luc_regen_inc_pct', '', 4), ('soul_res_pct', '', 4)),
    N('Hollow Bamboo (Không Trúc)', ('art_cost_pct', 'moc', 5), ('linh_luc_pct', '', 3)),
])
BIG('c44 cloud', [
    N('Cloud Step (Vân Bộ)', ('art_speed_pct', '', 4), ('escape_pct', '', 4)),
    N('Riding the Wind (Ngự Phong)', ('art_speed_pct', '', 5), ('travel_speed_pct', '', 3)),
])
BIG('c39 youngfir', [
    N('Wutong Perch (Ngô Đồng Thê)', ('stack_duration_pct', 'hoa,debuff', 4), ('attack_pct', 'moc', 4)),
])
BIG('c72 vine', [
    N('Creeping Vine (Mạn Đằng)', ('status_duration_pct', '', 4), ('attack_pct', 'moc,over_time', 4)),
    N('Strangler Vine (Giảo Đằng)', ('attack_pct', 'moc,over_time', 4), ('curse_effect_pct', '', 4)),
    N('Clinging Tendril (Triền Đằng)', ('status_duration_pct', '', 4), ('timer_resist_pct', '', 4)),
    N('Binding Vine (Đằng La)', ('status_duration_pct', '', 5), ('curse_effect_pct', '', 3)),
])
BIG('c44 pinwheel', [
    N('Folding Fan (Chiết Phiến)', ('attack_pct', 'phong', 4), ('evade_pct', '', 4)),
    N('Fan Wind Blade (Phiến Phong Nhận)', ('attack_pct', 'phong', 4), ('art_speed_pct', '', 4)),
    N('Wind Fan (Phong Phiến)', ('attack_pct', 'phong', 5), ('crit_chance_pct', '', 3)),
])
BIG('c94 tulip', [
    N('Herb Plot (Dược Điền)', ('herb_growth_pct', '', 4), ('healing_pct', '', 4)),
    N('Healing Herbs (Dược Thảo)', ('healing_pct', '', 4), ('pill_effect_pct', '', 4)),
    N('Gardener (Viên Đinh)', ('herb_growth_pct', '', 4), ('khi_van', '', 4)),
    N('Hundred Herbs Kept Alive (Bách Thảo Tàng Linh)', ('herb_growth_pct', '', 2), cap=('#12', 'T2'),
      alt=[('herb_growth_pct', '', 5), ('healing_pct', '', 3)], alt_name='Hundred-Herb Garden (Bách Thảo Viên)'),
])
BIG('c39 bough', [
    N('Brambles (Kinh Tùng)', ('block_rating', '', 4), ('khi_huyet_pct', '', 4)),
    N('Thorn Hedge (Kinh Cức)', ('block_rating', '', 5), ('resist_pct', 'physical', 3), effect='Thorns (Đảo Thích)'),
])
BIG('c43 streaks', [
    N('Sudden Gust (Đột Phong)', ('attack_pct', 'phong,quick', 4), ('crit_chance_pct', '', 4)),
    N('Whistling Wind (Phong Khiếu)', ('crit_chance_pct', '', 4), ('art_speed_pct', '', 4)),
    N('Raging Gale (Cuồng Phong)', ('attack_pct', 'phong,quick', 5), ('crit_damage_pct', '', 3)),
])
BIG('c12 maple', [
    N('Red Leaves (Hồng Diệp)', ('crit_damage_pct', 'moc', 4), ('attack_pct', 'over_time', 4)),
    N('Falling Leaves (Lạc Diệp)', ('attack_pct', 'over_time', 4), ('attack_pct', 'moc', 4)),
    N('Autumn Maple (Đan Diệp)', ('crit_damage_pct', 'moc', 5), ('crit_chance_pct', 'moc', 3)),
])
BIG('c60 rings', [
    N('Lingzhi Cap (Linh Chi)', ('pill_effect_pct', '', 4), ('lifespan_pct', '', 4)),
    N('Fairy Ring (Tiên Khuẩn Hoàn)', ('lifespan_pct', '', 4), ('khi_van', '', 4)),
    N('Lingzhi Ring (Linh Chi Hoàn)', ('pill_effect_pct', '', 5), ('dan_doc_resist_pct', '', 3)),
])
BIG('c109 frond', [
    N('Dragon Scales (Long Lân)', ('attack_pct', 'moc', 4), ('resist_pen_pct', '', 4)),
    N('Dragon Coil (Long Bàn)', ('attack_pct', 'moc', 4), ('khi_huyet_pct', '', 4)),
    N('Azure Claw (Thanh Trảo)', ('resist_pen_pct', '', 4), ('crit_chance_pct', 'moc', 4)),
    N('Green Dragon (Thanh Long)', ('attack_pct', 'moc', 5), ('crit_damage_pct', 'moc', 3)),
])
BIG('c12 tree', [
    N('Deep Roots (Thâm Căn)', ('health_regen_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Spreading Canopy (Quảng Ấm)', ('khi_huyet_pct', '', 4), ('healing_pct', '', 4)),
    N('World Tree (Kiến Mộc)', ('health_regen_pct', '', 5), ('health_regen_inc_pct', '', 3)),
])
BIG('c905 lantern_e', [
    N('Spirit Lantern (Linh Đăng)', ('companion_health_pct', '', 4), ('attack_pct', 'companion', 4)),
    N('Carved Faces (Khắc Diện)', ('attack_pct', 'companion', 4), ('companion_speed_pct', '', 4)),
    N('Ancestor Beast (Tổ Thú)', ('companion_health_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Totem Pole (Đồ Đằng Trụ)', ('attack_pct', 'companion', 4), ('companion_power_pct', '', 4)),
    N('Beast Soul Union (Thú Hồn Hợp Thể)', ('companion_health_pct', '', 2), cap=('#17', 'T2'),
      alt=[('attack_pct', 'companion', 5), ('companion_health_pct', '', 3)], alt_name='Beast-Soul Totem (Thú Hồn Đồ Đằng)'),
])
BIG('c905 star_w', [
    N('Pack Howl (Lang Hống)', ('companion_power_pct', '', 4), ('companion_speed_pct', '', 4)),
    N('Wolf King (Lang Vương)', ('companion_power_pct', '', 4), ('attack_pct', 'companion', 4)),
    N('Running Wolves (Bôn Lang)', ('companion_speed_pct', '', 4), ('travel_speed_pct', '', 4)),
    N('Hunting Ground (Liệp Trường)', ('companion_power_pct', '', 4), ('co_duyen_pct', '', 4), pending=[('taming_chance', '', 3)]),
    N('Howling at the Moon (Khiếu Nguyệt)', ('companion_speed_pct', '', 4), ('companion_health_pct', '', 4)),
    N('Ten Thousand Beasts, One Heart (Vạn Thú Đồng Tâm)', ('companion_power_pct', '', 2), cap=('#16', 'T2'),
      alt=[('companion_power_pct', '', 5), ('companion_speed_pct', '', 3)], alt_name='Wolf Pack (Lang Quần)'),
])
BIG('c905 holo', [
    N('Gourd Neck (Hồ Lô Cảnh)', ('lifespan_pct', '', 4), ('dan_doc_resist_pct', '', 4)),
    N('Elixir Store (Dược Tàng)', ('dan_doc_resist_pct', '', 4), ('pill_effect_pct', '', 4)),
    N('Vine Gourd (Đằng Hồ Lô)', ('lifespan_pct', '', 4), ('khi_van', '', 4)),
    N('Ten Thousand Years (Vạn Niên)', ('lifespan_pct', '', 4), ('can_cot', '', 4)),
    N('Sealed Stopper (Tắc Khẩu)', ('dan_doc_decay', '', 4), ('lifespan_pct', '', 4)),
    N('Calabash Spirit (Hồ Lô Tinh)', ('khi_van', '', 4), ('health_regen_inc_pct', '', 4)),
    N('Gourd of Ten Thousand Years (Vạn Niên Hồ Lô)', ('lifespan_pct', '', 5), ('khi_huyet_pct', '', 3)),
])

# ================= D. Medium clusters and start figures =================
KV = ('khi_van', ''); MOC = ('attack_pct', 'moc'); HR = ('health_regen_pct', ''); HRI = ('health_regen_inc_pct', ''); HP = ('khi_huyet_pct', '')
POI = ('attack_pct', 'poison'); WST = ('stack_effect_pct', 'moc,debuff'); WDUR = ('stack_duration_pct', 'moc,debuff'); OT = ('attack_pct', 'over_time')
CRM = ('crit_chance_pct', 'moc'); SPM = ('art_speed_pct', 'moc'); EV = ('evade_pct', ''); HEAL = ('healing_pct', ''); BLK = ('block_rating', '')
CULT = ('cultivation_speed_pct', ''); HG = ('herb_growth_pct', ''); CD = ('co_duyen_pct', ''); SD = ('status_duration_pct', '')
MED('base6', KV, [n('Wood Start (Mộc Khởi)', KV, MOC), n('Green Root (Thanh Căn)', KV, HR), n('Lucky Sprout (Cát Nha)', KV, CD),
                  n('Rising Sap (Thăng Dịch)', KV, HP), n('Young Branch (Ấu Chi)', KV, SPM), n('Forest Floor (Lâm Địa)', KV, HG),
                  n('Wood Grain (Mộc Văn)', MOC, BLK), n('Wood Root (Mộc Căn)', MOC, HR, 5, 3)])
MED('base15', KV, [n('Wood Seal (Mộc Ấn)', KV, MOC), n('Axis Tree (Trục Mộc)', KV, HR)])
MED('c67 67_ring', HR, [n('Growth Rings (Niên Luân)', HR, KV), n('Spring Shoots (Xuân Duẩn)', HR, CULT), n('Green Grove (Thanh Lâm)', HR, HP)])
MED('c64 64_wheel', MOC, [n('Whirling Leaves (Toàn Diệp)', MOC, SPM), n('Return of Spring (Xuân Hồi)', MOC, KV)])
MED('c112 112_arch', KV, [n('Hidden Glade (U Cốc)', KV, EV), n('Vine Trellis (Đằng Giá)', KV, HRI), n('Green Gate (Thanh Môn)', KV, ('mi_luc', ''))])
MED('c64 seedling', HP, [n('Seedling (Ấu Miêu)', HP, HR), n('Strong Sapling (Tráng Miêu)', HP, ('can_cot', ''))])
MED('c111 crescentleaf', POI, [n('Venom Leaf (Độc Diệp)', POI, MOC), n('Bitter Leaf (Khổ Diệp)', POI, WST)])
MED('c111 curl', WST, [n('Withering (Điêu Linh)', WST, OT), n('Deep Rot (Hủ Bại)', WST, WDUR)])
MED('c112 berries', HEAL, [n('Spirit Berries (Linh Quả)', HEAL, HP), n('Vermilion Fruit (Chu Quả)', HEAL, HR), n('Bitter Berries (Khổ Quả)', HEAL, POI)])
MED('c21 21_arch', CULT, [n('Insects Awaken (Kinh Trập)', CULT, KV), n('Spring Rain (Xuân Vũ)', CULT, HRI), n('New Leaf (Tân Diệp)', CULT, HG)])
MED('c25 25_ring', OT, [n('Poison Ivy (Độc Đằng)', OT, POI), n('Slow Venom (Mạn Độc)', OT, WDUR), n('Jungle Miasma (Chướng Khí)', OT, SD)])
MED('c35 acorn', KV, [n('Acorn (Tượng Thực)', KV, ('can_cot', '')), n('Oak Seed (Tượng Tử)', KV, HP), n("Squirrel's Store (Tùng Thử Tàng)", KV, CD)])
MED('c21 weep2', HRI, [n('Weeping Willow (Thùy Liễu)', HRI, HEAL), n('Willow Tears (Liễu Lệ)', HRI, ('tam_ma_resist_pct', ''))])
MED('c21 weep1', EV, [n('Willow Dance (Liễu Vũ)', EV, SPM), n('Bending Willow (Khúc Liễu)', EV, ('timer_resist_pct', ''))])
MED('c25 tree2', MOC, [n('Poison Tree (Độc Thụ)', MOC, POI), n('Gnarled Trunk (Lão Can)', MOC, HP), n('Thorn Bark (Thích Bì)', MOC, BLK),
                       n('Black Forest (Hắc Lâm)', MOC, CRM)])
MED('c25 fan', CRM, [n('Plantain Fan (Ba Tiêu Phiến)', CRM, MOC), n('Flying Leaves (Phi Diệp)', CRM, SPM), n('Razor Leaf (Lợi Diệp)', CRM, ('crit_damage_pct', 'moc'))])
MED('c25 ginkgo', ('lifespan_pct', ''), [n('Ginkgo (Bạch Quả)', ('lifespan_pct', ''), ('ngo_tinh', '')), n('Living Fossil (Hoạt Hóa Thạch)', ('lifespan_pct', ''), HP)])
MED('c35 whorl', CD, [n('Lucky Star (Cát Tinh)', CD, KV), n('Peach Blossom Luck (Đào Hoa Vận)', CD, ('mi_luc', '')), n('Chance Encounter (Kỳ Ngộ)', CD, ('travel_speed_pct', ''))])
MED('c21 willowleaf', ('healing_taken_pct', ''), [n('Willow Leaf (Liễu Diệp)', ('healing_taken_pct', ''), HR)])
MED('c72 72_crook', ('timer_resist_pct', ''), [n('Taking Root (Trát Căn)', ('timer_resist_pct', ''), SD), n('Hooked Thorn (Câu Thích)', ('timer_resist_pct', ''), MOC)])
MED('c39 ivy', HP, [n('Ivy (Thường Xuân)', HP, BLK), n('Ivy Wall (Đằng Tường)', HP, ('resist_pct', 'physical')), n('Clinging Ivy (Phụ Đằng)', HP, HR)])
MED('c72 72_tadpole', ('curse_effect_pct', ''), [n('Cursed Vine (Chú Đằng)', ('curse_effect_pct', ''), SD), n('Entwining (Triền Nhiễu)', ('curse_effect_pct', ''), MOC)])
MED('c94 bud', HG, [n('Flower in Bud (Hàm Bao)', HG, KV)])
MED('c88 fiddlehead', ('pill_effect_pct', ''), [n('Fiddlehead (Quyết Nha)', ('pill_effect_pct', ''), HG)])
MED('c39 bigleaf', ('attack_pct', 'hoa'), [n('Broad Leaf (Khoan Diệp)', ('attack_pct', 'hoa'), ('stack_duration_pct', 'hoa,debuff')),
                                         n('Dry Leaf (Khô Diệp)', ('attack_pct', 'hoa'), OT),
                                         n('Kindling Leaf (Dẫn Hỏa Diệp)', ('attack_pct', 'hoa'), MOC)])
MED('c94 samara', HEAL, [n('Samara (Sí Quả)', HEAL, HG), n('Winged Seed (Phi Chủng)', HEAL, ('travel_speed_pct', ''))])
MED('c71 cutstem', SD, [n('Pruning (Tiễn Chi)', SD, ('attack_pct', 'moc,over_time')), n('Grafting (Giá Tiếp)', SD, HRI)])
MED('c39 39_crescent2', ('resist_pct', 'physical'), [n('Leaf Shield (Diệp Thuẫn)', ('resist_pct', 'physical'), BLK), n('Thorn Armour (Kinh Giáp)', ('resist_pct', 'physical'), HP)])
MED('c109 109_crook', CRM, [n('Dragon Tail Lash (Long Vĩ Tiên)', CRM, MOC), n('Dragon Whisker (Long Tu)', CRM, ('resist_pen_pct', ''))])
MED('c52 cherries', HP, [n('Cherries (Anh Đào)', HP, HEAL), n('Twin Cherries (Song Anh Đào)', HP, KV)])
MED('c52 roundleaf', HR, [n('Lotus Pad (Hà Diệp)', HR, HP), n('Lotus Dew (Hà Lộ)', HR, ('healing_taken_pct', ''))])
MED('c60 dandelion', ('dan_doc_resist_pct', ''), [n('Dandelion (Bồ Công Anh)', ('dan_doc_resist_pct', ''), ('travel_speed_pct', '')),
                                                  n('Detox Brew (Giải Độc Thang)', ('dan_doc_resist_pct', ''), ('pill_effect_pct', ''))])
MED('c52 tendril', ('companion_health_pct', ''), [n('Beast-Taming Vine (Ngự Thú Đằng)', ('companion_health_pct', ''), ('companion_power_pct', ''))])
MED('c60 crozier', HG, [n('Curled Fern (Quyển Quyết)', HG, ('pill_effect_pct', '')), n('Unfolding Fern (Quyết Khai)', HG, ('lifespan_pct', ''))])
MED('c52 blossom', ('mi_luc', ''), [n('Peony (Mẫu Đơn)', ('mi_luc', ''), KV), n('Plum Blossom (Mai Hoa)', ('mi_luc', ''), ('tam_ma_resist_pct', ''))])
MED('c13 acorn', HP, [n('Oak Grove (Tượng Lâm)', HP, HR), n('Oak Heart (Tượng Tâm)', HP, BLK), n('Ancient Tree (Cổ Thụ)', HP, ('lifespan_pct', ''))])
MED('c13 sprout', HRI, [n('Root Sprout (Căn Nha)', HRI, HR)])


# ================= E. Small clusters: one line each by hand (choice 1b); notables = line + a partner =================
PHONG = ('attack_pct', 'phong'); CP = ('companion_power_pct', ''); CH = ('companion_health_pct', ''); LIFE = ('lifespan_pct', '')
SM('c1 1_fork', MOC, [('Divining Twig (Chiêm Chi)', KV), ('Green Sprig (Thanh Chi)', HR)])
SM('c1 1_spur', KV, [('Fortune Charm (Phúc Phù)', CD), ('Green Thorn (Thanh Thích)', MOC)])
SM('c1 rootL', HR, [('Taproot (Chủ Căn)', HP)])
SM('c67 splitleaf', CULT, [('Dew Gathering (Thái Lộ)', KV)])
SM('c112 splitleaf', HRI, [('Spirit Spring (Linh Tuyền)', HR)])
SM('c64 parted', KV, [('Forest Path (Lâm Kính)', CULT)])
SM('c111 risingleaf', POI, [('Venom Surge (Độc Dũng)', WST)])
SM('c64 risingleaf', HP, [('Climbing Vine (Phan Đằng)', HRI)])
SM('c21 21_hairpin', CD, [('Red Thread (Hồng Tuyến)', KV)])
SM('c25 25_hook', WST, [('Serpent Fang (Xà Nha)', POI)])
SM('c35 lyreR', ('mi_luc', ''), [('Zither Song (Cầm Âm)', KV)])
SM('c35 lyreL', ('mission_income_pct', ''), [('Zither String (Cầm Huyền)', ('mi_luc', ''))])
SM('c35 35_vine', KV, [('Garland (Hoa Hoàn)', ('mission_income_pct', ''))])
SM('c31 31_tadpole', ('status_resist_pct', ''), [('Pine Resin (Tùng Chi)', ('timer_resist_pct', ''))])
SM('c21 21_crescent', KV, [('Seedling Field (Miêu Điền)', HRI)])
SM('c31 31_fork', SPM, [('Bamboo Dart (Trúc Tiêu)', EV), ('Bamboo Spear (Trúc Thương)', CRM)])
SM('c25 curl', POI, [('Poison Mist (Độc Vụ)', OT)])
SM('c35 pod', KV, [('Seed Pod (Tử Giáp)', ('can_cot', ''))])
SM('c35 seedB_up', CD, [('Drifting Seed (Phiêu Chủng)', ('travel_speed_pct', '')), ('Seed of Fortune (Phúc Chủng)', KV)])
SM('c94 seedB_low', HG, [('Spirit Seed (Linh Chủng)', HEAL), ('Herb Seed (Dược Chủng)', ('pill_effect_pct', ''))])
SM('c43 43_wave', PHONG, [('Wind Wave (Phong Lãng)', ('crit_chance_pct', ''))])
SM('c44 44_crescent', EV, [('Wind Sickle (Phong Liêm)', PHONG)])
SM('c71 71_spur', SD, [('Leech Vine (Hấp Huyết Đằng)', ('attack_pct', 'moc,over_time')), ('Snare (La Võng)', ('curse_effect_pct', ''))])
SM('c44 44_wave', ('art_speed_pct', ''), [('Breeze (Vi Phong)', EV)])
SM('c88 hangleaf', HEAL, [('Hanging Leaf (Thùy Diệp)', HG)])
SM('c43 gust2', ('crit_chance_pct', ''), [('Returning Wind (Hồi Phong)', PHONG)])
SM('c43 gust1', PHONG, [('Rising Wind (Khởi Phong)', ('art_speed_pct', ''))])
SM('c72 72_crescent', ('timer_resist_pct', ''), [('Vine Lock (Đằng Tỏa)', SD)])
SM('c44 44_hook', ('escape_pct', ''), [('Wind Escape (Phong Độn)', EV)])
SM('c71 71_hook', ('attack_pct', 'moc,over_time'), [('Strangling Grip (Giảo Sát)', SD)])
SM('c44 44_hook2', PHONG, [('Whirlwind (Toàn Phong)', EV)])
SM('c39 39_tadpole', ('stack_duration_pct', 'hoa,debuff'), [('Wutong Seed (Ngô Đồng Tử)', MOC)])
SM('c43 43_hairpin', EV, [('Wind Needle (Phong Châm)', ('crit_chance_pct', ''))])
SM('c71 72_diamond', ('curse_effect_pct', ''), [('Witch Knot (Chú Kết)', SD)])
SM('c94 cloverA94', KV, [('Spirit Grass (Linh Thảo)', HG)])
SM('c88 cloverA88', HG, [('Wild Ginseng (Dã Nhân Sâm)', KV)])
SM('c72 72_crook2', MOC, [('Whipping Vine (Đằng Tiên)', SD)])
SM('c94 almond', ('pill_effect_pct', ''), [('Almond (Hạnh Nhân)', HG)])
SM('c13 almond', HP, [('Bitter Almond (Khổ Hạnh Nhân)', HR)])
SM('c13 cloverA13', HR, [('Mossy Stone (Đài Thạch)', KV)])
SM('c13 13_seed', ('crit_damage_pct', 'moc'), [('Rosary Pea (Tương Tư Đậu)', OT)])
SM('c12 12_crescent', OT, [('Autumn Frost (Thu Sương)', ('crit_damage_pct', 'moc'))])
SM('c60 60_tadpole', ('pill_effect_pct', ''), [('Caterpillar Fungus (Trùng Thảo)', LIFE)])
SM('c107 splitleaf', MOC, [('Dragon Leaf (Long Diệp)', ('resist_pen_pct', ''))])
SM('c52 splitleaf', HP, [('Orchard (Quả Viên)', HEAL)])
SM('c109 eddy', CRM, [('Green Dragon Pearl (Thanh Long Châu)', MOC)])
SM('c60 eddy', LIFE, [('Spore Cloud (Bào Tử Vân)', ('dan_doc_resist_pct', ''))])
SM('c13 13_ring', HR, [('Hundred Years (Bách Niên)', LIFE), ('Old Bark (Lão Bì)', HP)])
SM('c107 109_crook2', ('resist_pen_pct', ''), [('Dragon Talon (Long Trảo)', MOC)])
SM('c60 leafR', ('dan_doc_resist_pct', ''), [('Mushroom Cap (Khuẩn Cái)', ('pill_effect_pct', ''))])
SM('c60 leafL', LIFE, [('Spirit Mushroom (Linh Khuẩn)', KV)])
SM('c13 13_crook', HRI, [('Coiled Roots (Bàn Căn)', HR)])
SM('c109 109_crescent', MOC, [('Scale Blade (Lân Nhận)', CRM)])
SM('c52 52_hook2', HEAL, [('Ripe Fruit (Thục Quả)', HP)])
SM('c13 13_diamond', KV, [('Tree Spirit (Mộc Linh)', HP)])
SM('c107 107_crook', ('attack_pct', 'moc'), [('Coiling Serpent (Bàn Xà)', HP)])
SM('c60 60_crook2', HG, [('Mushroom Grove (Khuẩn Lâm)', ('pill_effect_pct', ''))])
SM('c109 gust', ('art_speed_pct', 'moc'), [("Dragon's Breath (Long Tức)", MOC)])
SM('c107 leaf', HP, [('Dragon Vein (Long Mạch)', MOC)])
SM('c905 leaf_rim', CP, [('Beast Den (Thú Huyệt)', CH)])
SM('c905 stalk_leaf1', CH, [('Beast Pen (Thú Lan)', CP)])
SM('c905 stalk_leaf2', ('attack_pct', 'companion'), [('Beast Claw (Thú Trảo)', ('companion_speed_pct', ''))])
SM('c905 stalk_leaf3', ('companion_speed_pct', ''), [('Swift Hound (Tấn Khuyển)', CP)])


# ================= Loose small nodes (base map proposal nodes, no cluster): one line per mirrored pair =================
ONE([1995, 1996], ('khi_van', ''))
ONE([1997, 1999], ('attack_pct', 'moc'))
ONE([1998, 2000], ('khi_huyet_pct', ''))
ONE([2003, 2004], ('health_regen_pct', ''))
ONE([2005, 2006], ('khi_van', ''))

# ================= B. Keystones =================
KEY('c905 keystone_e', 'Bare Rack (Không Giá)', 'Bare Rack (Không Giá)',
    [('companion_power_pct', '', 25), ('basic_speed_pct', '', 25)], closes='maximum health -15 %')
KEY('c905 keystone_w', 'Spirit Garden (Linh Viên)', 'Spirit Garden (Linh Viên)',
    [('herb_growth_pct', '', 30), ('field_plots', '', 20)], closes='at most one spirit beast')
KEY('c905 keystone_rim_R', 'Ten Thousand Poisons (Vạn Độc)', 'Ten Thousand Poisons (Vạn Độc)',
    [('stack_effect_pct', 'moc,debuff', 25), ('attack_pct', 'poison', 25)], closes='hit damage -25 %')
KEY('c905 keystone_rim_L', 'Sun and Rain (Nhật Vũ)', 'Sun and Rain (Nhật Vũ)',
    [('health_regen_inc_pct', '', 25), ('linh_luc_regen_inc_pct', '', 25)], closes='maximum linh lực -30 %')

# ---- start keystone (added 2026-11-19) ----
KEY('c905 keystone_start', 'Ageless Pine (Vạn Niên Tùng)', 'Ageless Pine (Vạn Niên Tùng)',
    [('health_regen_pct', '', 25), ('khi_huyet_pct', '', 25)], closes='Fire resistance −25 % (`resist_pct` [fire] −25)')

# ---- mid-land keystones (added 2026-11-19) ----
KEY('c905 keystone_mid_a', 'Strangling Vines (Đằng Triền)', 'Strangling Vines (Đằng Triền)',
    [('stack_effect_pct', 'moc,debuff', 30), ('attack_pct', 'moc', 20)], closes='art speed −15 % (`art_speed_pct` −15)')
KEY('c905 keystone_mid_b', 'Wood Begets Fire (Mộc Sinh Hỏa)', 'Wood Begets Fire (Mộc Sinh Hỏa)',
    [('attack_pct', 'hoa', 25), ('health_regen_pct', '', 25)], closes='arts of Metal (Kim) you slot deal 50 % less')
