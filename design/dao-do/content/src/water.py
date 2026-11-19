# Water (Thủy) content on v5. Written by hand under design/dao-do/content-method.md. Notables in walk order (crown last).

# ================= C. Big pictures =================
BIG('c26 raindrop', [
    N('Drizzle (Tế Vũ)', ('attack_pct', 'quick', 4), ('healing_pct', '', 4)),
    N('Water Needles (Thủy Châm)', ('attack_pct', 'quick', 4), ('art_speed_pct', 'thuy', 4)),
    N('Rain Curtain (Vũ Liêm)', ('attack_pct', 'quick,thuy', 5), ('healing_pct', '', 3)),
])
BIG('c26 waterwheel', [
    N('Mill Race (Thủy Xa)', ('art_speed_pct', 'thuy', 4), ('art_cost_pct', 'thuy', 4)),
    N('Turning Paddles (Chuyển Trạo)', ('art_speed_pct', 'thuy', 4), ('linh_luc_regen_inc_pct', '', 4)),
    N('Ceaseless Wheel (Bất Tức Luân)', ('art_cost_pct', 'thuy', 5), ('linh_luc_pct', '', 3)),
])
BIG('c32 moon_halo', [
    N('Nourishing Rain (Cam Lâm)', ('health_regen_inc_pct', '', 4), ('healing_taken_pct', '', 4)),
    N('Moon Dew (Nguyệt Lộ)', ('healing_taken_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Rain on Bamboo (Vũ Trúc)', ('health_regen_inc_pct', '', 5), ('health_regen_pct', '', 3)),
])
BIG('c22 wave_train', [
    N('Swell (Dũng Lãng)', ('attack_pct', 'thuy', 4), ('resist_pen_pct', 'cold', 4)),
    N('Breaker (Phách Lãng)', ('attack_pct', 'thuy', 4), ('crit_chance_pct', 'thuy', 4)),
    N('Undertow (Hồi Lưu)', ('resist_pen_pct', 'cold', 4), ('attack_pct', 'cold', 4)),
    N('Rolling Waves (Liên Ba)', ('attack_pct', 'thuy', 5), ('crit_damage_pct', 'thuy', 3)),
])
BIG('c38 lily_pad', [
    N('Frost Bloom (Sương Hoa)', ('stack_duration_pct', 'bang,debuff', 4), ('attack_pct', 'bang', 4)),
    N('Chill (Hàn Khí)', ('attack_pct', 'bang', 4), ('attack_pct', 'cold', 4)),
    N('Snow Lotus (Tuyết Liên)', ('stack_duration_pct', 'bang,debuff', 5), ('stack_effect_pct', 'bang,debuff', 3)),
])
BIG('c32 lotus', [
    N('Cardinal Points (Tứ Phương)', ('travel_speed_pct', '', 4), ('escape_pct', '', 4)),
    N('Wind Rose (Phong Bàn)', ('travel_speed_pct', '', 4), ('co_duyen_pct', '', 4)),
    N('Blink Mark (Thuấn Di Ấn)', ('travel_speed_pct', '', 2), cap=('#21', 'T2')),
])
BIG('c42 seaweed', [
    N('Paper Puppets (Chỉ Nhân)', ('companion_power_pct', '', 4), ('companion_health_pct', '', 4)),
    N('Paper Army (Chỉ Binh Trận)', ('companion_power_pct', '', 5), ('attack_pct', 'companion', 3),
      pending=[('talisman_power_pct', '', 3)]),
])
BIG('c76 braid', [
    N('Ink Stick (Mặc Đĩnh)', ('attack_pct', 'talisman', 4), ('art_speed_pct', 'talisman', 4)),
    N('Long Brush (Trường Bút)', ('attack_pct', 'talisman', 4), ('than_thuc_pct', '', 4), pending=[('talisman_power_pct', '', 3)]),
    N('Endless Talismans (Phù Lục Bất Tận)', ('attack_pct', 'talisman', 2), cap=('#13', 'T2')),
])
BIG('c69 pearl', [
    N('Deep Pearl (Thâm Châu)', ('linh_luc_pct', '', 4), ('reserve_eff_pct', '', 4)),
    N('Dark Water (Hắc Thủy)', ('linh_luc_pct', '', 4), ('linh_luc_regen_pct', '', 4)),
    N('Heavy Water (Trọng Thủy)', ('reserve_eff_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Black Abyss (Huyền Uyên)', ('linh_luc_pct', '', 5), ('linh_luc_regen_inc_pct', '', 3)),
])
BIG('c54 meeting_ripples', pat='BBA', nts=[
    N('Carp Scales (Lý Lân)', ('ngo_tinh', '', 4), ('khi_huyet_pct', '', 4)),
    N('Against the Current (Nghịch Lưu)', ('ngo_tinh', '', 4), ('cultivation_speed_pct', '', 4)),
    N('Leaping Fish (Ngư Dược)', ('breakthrough_chance', '', 4), ('ngo_tinh', '', 4)),
    N('Carp at the Dragon Gate (Lý Ngư Khiêu Long Môn)', ('ngo_tinh', '', 5), ('tam_ma_resist_pct', '', 3)),
])
BIG('c11 pond', [
    N('Still Pond (Tĩnh Đường)', ('soul_res_pct', '', 4), ('ngo_tinh', '', 4)),
    N('Reflected Moon (Thủy Nguyệt)', ('ngo_tinh', '', 4), ('evade_pct', '', 4)),
    N('Mirror Lake (Kính Hồ)', ('soul_res_pct', '', 4), ('evade_pct', '', 4), effect='Reflection (Phản Chiếu)'),
])
BIG('c59 endless', [
    N('Tangled Current (Loạn Lưu)', ('curse_effect_pct', '', 4), ('status_duration_pct', 'curse', 4)),
    N('Knotted Cord (Kết Thằng)', ('status_duration_pct', 'curse', 4), ('art_speed_pct', 'curse', 4)),
    N('Endless Knot (Vô Tận Kết)', ('curse_effect_pct', '', 5), ('art_speed_pct', 'curse', 3)),
])
BIG('c17 turning_wave', [
    N('Rising Tide (Trướng Triều)', ('stack_effect_pct', 'thuy,buff', 4), ('linh_luc_regen_pct', '', 4)),
    N('Ebb Tide (Thoái Triều)', ('linh_luc_regen_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Moon over the Tide (Nguyệt Triều)', ('stack_effect_pct', 'thuy,buff', 4), ('attack_pct', 'thuy', 4),
      effect='Tide (Thủy Triều)'),
])
BIG('c11 whirlpool', [
    N('Eddy (Hồi Toàn)', ('leech_linh_luc_pct', '', 4), ('linh_luc_on_hit_pct', '', 4)),
    N('Whirlpool (Tuyền Qua)', ('leech_linh_luc_pct', '', 5), ('linh_luc_on_hit_pct', 'thuy', 3)),
])
BIG('c17 meander', [
    N('River Bend (Hà Khúc)', ('cultivation_speed_pct', '', 4), ('travel_speed_pct', '', 4)),
    N('Drifting Boat (Phiêu Chu)', ('travel_speed_pct', '', 4), ('ngo_tinh', '', 4),
      pending=[('cultivation_speed_pct', 'travelling', 3)]),
    N('Dao in Dreams (Mộng Trung Ngộ Đạo)', ('cultivation_speed_pct', '', 2), cap=('#8', 'T2')),
])
BIG('c904 armillary_L', [
    N('Celestial Ring (Thiên Hoàn)', ('ngo_tinh', '', 4), ('travel_speed_pct', '', 4)),
    N('Pole Star (Bắc Thần)', ('ngo_tinh', '', 4), ('accuracy_pct', '', 4)),
    N('Star Path (Tinh Lộ)', ('travel_speed_pct', '', 4), ('co_duyen_pct', '', 4)),
    N('Lunar Mansion (Nguyệt Túc)', ('ngo_tinh', '', 4), ('than_thuc_pct', '', 4)),
    N('Night Sky (Dạ Không)', ('ngo_tinh', '', 4), ('escape_pct', '', 4)),
    N('Star Chart (Tinh Đồ)', ('ngo_tinh', '', 5), ('cultivation_speed_pct', '', 3)),
])
BIG('c904 oai_stellar_frost', [
    N('Hoarfrost (Ngưng Sương)', ('stack_effect_pct', 'bang,debuff', 4), ('attack_pct', 'cold', 4)),
    N('Frost Thorn (Sương Thứ)', ('attack_pct', 'cold', 4), ('crit_damage_pct', 'thuy', 4)),
    N('Cold Snap (Hàn Lưu)', ('stack_effect_pct', 'bang,debuff', 4), ('stack_duration_pct', 'bang,debuff', 4)),
    N('Rime (Băng Sương)', ('attack_pct', 'cold', 4), ('resist_pct', 'cold', 4)),
    N('Winter Star (Đông Tinh)', ('attack_pct', 'bang', 4), ('crit_chance_pct', 'cold', 4)),
    N('Frost Star (Sương Tinh)', ('stack_effect_pct', 'bang,debuff', 5), ('resist_pen_pct', 'cold', 3)),
])
BIG('c904 ice_flake', [
    N('Icicle (Băng Trụ)', ('crit_chance_pct', 'cold', 4), ('defense_pct', '', 4)),
    N('Ice Shell (Băng Xác)', ('defense_pct', '', 4), ('resist_pct', 'cold', 4)),
    N('Shattered Ice (Toái Băng)', ('crit_chance_pct', 'cold', 4), ('attack_pct', 'cold', 4)),
    N('Frozen Ward (Băng Hộ)', ('defense_pct', '', 4), ('ward_efficiency_pct', '', 4)),
    N('Clear Ice (Thanh Băng)', ('crit_chance_pct', 'cold', 4), ('crit_damage_pct', '', 4)),
    N('Icicle Crown (Băng Quan)', ('crit_chance_pct', 'cold', 5), ('ward_efficiency_pct', '', 3)),
])
BIG('c904 bagua', [
    N('Double Abyss (Tập Khảm)', ('evade_pct', '', 4), ('stealth', '', 4)),
    N('Yielding Water (Nhu Thủy)', ('evade_pct', '', 4), ('escape_pct', '', 4)),
    N('Hidden Current (Ám Lưu)', ('stealth', '', 4), ('art_speed_pct', '', 4)),
    N('Water Trigram (Khảm Quái)', ('evade_pct', '', 5), ('art_speed_pct', 'thuy', 3)),
])
BIG('c904 plate_flake', [
    N('Plate Ice (Băng Phiến)', ('resist_pct', 'cold', 4), ('khi_huyet_pct', '', 4)),
    N('Window Frost (Song Sương)', ('resist_pct', 'cold', 4), ('defense_pct', '', 4)),
    N('Glacier (Băng Hà)', ('khi_huyet_pct', '', 4), ('block_rating', '', 4)),
    N('Cold Iron (Băng Thiết)', ('resist_pct', 'cold', 4), ('resist_pct', 'physical', 4)),
    N('Ice-Jade Skin (Băng Cơ)', ('khi_huyet_pct', '', 4), ('health_regen_pct', '', 4)),
    N('Frost Plate (Sương Giáp)', ('resist_pct', 'cold', 5), ('block_rating', '', 3)),
])
BIG('c904 lotus', [
    N('Rising from Mud (Xuất Nê)', ('lifespan_pct', '', 4), ('tam_ma_resist_pct', '', 4)),
    N('Lotus Seed (Liên Tử)', ('lifespan_pct', '', 4), ('ngo_tinh', '', 4)),
    N('Still Water Heart (Tĩnh Thủy Tâm)', ('tam_ma_resist_pct', '', 4), ('soul_res_pct', '', 4)),
    N('Lotus Canopy (Hà Cái)', ('lifespan_pct', '', 4), ('health_regen_inc_pct', '', 4)),
    N('Pure Bloom (Thanh Liên)', ('tam_ma_resist_pct', '', 4), ('qi_deviation_pct', '', 4)),
    N('Still Lake Lotus (Tĩnh Liên)', ('lifespan_pct', '', 5), ('healing_pct', '', 3)),
])

# ================= D. Medium clusters and start figures (base4 Water start, base5 Ice start) =================
NGO = ('ngo_tinh', ''); THUY = ('attack_pct', 'thuy'); LL = ('linh_luc_pct', ''); LR = ('linh_luc_regen_pct', ''); COLD = ('attack_pct', 'cold')
BANG = ('attack_pct', 'bang'); RC = ('resist_pct', 'cold'); CRC = ('crit_chance_pct', 'cold'); IST = ('stack_effect_pct', 'bang,debuff')
SPT = ('art_speed_pct', 'thuy'); CRT = ('crit_chance_pct', 'thuy'); EV = ('evade_pct', ''); HP = ('khi_huyet_pct', ''); HEAL = ('healing_pct', '')
HRI = ('health_regen_inc_pct', ''); LEECH = ('leech_linh_luc_pct', ''); TT = ('than_thuc_pct', ''); CULT = ('cultivation_speed_pct', '')
MED('base4', NGO, [n('Wellspring (Thủy Nguyên)', NGO, THUY), n('Calm Pool (Tĩnh Trì)', NGO, LL), n('Flowing Thought (Lưu Tư)', NGO, LR),
                   n('Water Root (Thủy Căn)', THUY, LL)])
MED('base5', BANG, [n('First Frost (Sơ Sương)', BANG, NGO), n('Frost Seed (Sương Chủng)', BANG, IST), n('Cold Root (Hàn Căn)', RC, BANG),
                    n('Still Ice (Tĩnh Băng)', NGO, RC), n('Frost Breath (Sương Tức)', COLD, LL), n('Ice Root (Băng Căn)', BANG, CRC, 5, 3)])
MED('base14', NGO, [n('Water Seal (Thủy Ấn)', NGO, THUY), n('Heart Spring (Tâm Tuyền)', NGO, LR)])
MED('c5 ripple_hook_m', LL, [n('Lingering Ripples (Dư Ba)', LL, NGO), n('Water Ring Step (Thủy Hoàn Bộ)', LL, EV)])
MED('c46 ice_crystal', BANG, [n('Ice Crystal (Băng Tinh)', BANG, RC), n('Clear Frost (Thanh Sương)', BANG, CRC)])
MED('c46 frost_star', COLD, [n('Six-Petalled Snow (Lục Xuất Hoa)', COLD, IST), n('Bone-Piercing Cold (Hàn Triệt Cốt)', COLD, ('resist_pen_pct', 'cold')),
                             n('North Wind (Bắc Phong)', COLD, LL)])
MED('c118 channel', ('art_cost_pct', 'thuy'), [n('Spirit Canal (Linh Cừ)', ('art_cost_pct', 'thuy'), LR), n('Grand Canal (Vận Hà)', ('art_cost_pct', 'thuy'), ('travel_speed_pct', ''))])
MED('c45 winged_crystal', CRC, [n('Ice Feather (Băng Vũ)', CRC, BANG), n('Snow Crane (Tuyết Hạc)', CRC, EV)])
MED('c46 lotus_bloom', RC, [n('Ice Lotus (Băng Liên)', RC, HP), n('Winter Plum (Hàn Mai)', RC, ('defense_pct', '')), n('Cold Fragrance (Hàn Hương)', RC, NGO)])
MED('c38 dewdrop', LR, [n('Dewdrop (Lộ Tích)', LR, COLD), n('Morning Dew (Triêu Lộ)', LR, NGO)])
MED('c32 moon', HEAL, [n('Full Moon (Mãn Nguyệt)', HEAL, NGO), n('Moonlit Rain (Nguyệt Vũ)', HEAL, HP)])
MED('c26 clam', EV, [n('Clam Shell (Bạng Xác)', EV, ('defense_pct', '')), n('Hidden Pearl (Ẩn Châu)', EV, NGO)])
MED('c26 whirlpool', LEECH, [n('Whirling Palm (Toàn Chưởng)', LEECH, THUY), n('Spinning Water (Toàn Thủy)', LEECH, SPT)])
MED('c38 falling_drop', IST, [n('Falling Frost (Lạc Sương)', IST, COLD), n('Hailstones (Băng Bạc)', IST, BANG)])
MED('c32 reflection', ('escape_pct', ''), [n('Water Reflection (Thủy Ảnh)', ('escape_pct', ''), NGO),
                                           n('Flower in the Mirror (Kính Hoa)', ('escape_pct', ''), ('soul_res_pct', ''))])
MED('c22 fountain', CRT, [n('Geyser (Phún Tuyền)', CRT, THUY), n('Water Arrow (Thủy Tiễn)', CRT, SPT), n('Water Pillar (Thủy Trụ)', CRT, ('crit_damage_pct', 'thuy'))])
MED('c22 curl', SPT, [n('Curling Wave (Quyển Lãng)', SPT, THUY), n('Sea Foam (Hải Mạt)', SPT, EV), n('Whitecap (Bạch Lãng)', SPT, CRT)])
MED('c86 meniscus', ('reserve_eff_pct', ''), [n('Brimming Cup (Mãn Bôi)', ('reserve_eff_pct', ''), LL), n('Water Film (Thủy Mô)', ('reserve_eff_pct', ''), ('defense_pct', ''))])
MED('c76 eddy', TT, [n('Ink Pool (Mặc Trì)', TT, ('attack_pct', 'talisman')), n('Cursive Script (Thảo Thư)', TT, ('art_speed_pct', 'talisman'))])
MED('c42 bubble_l', ('companion_speed_pct', ''), [n('Paper Boat (Chỉ Thuyền)', ('companion_speed_pct', ''), ('companion_power_pct', ''))])
MED('c69 wave_crest', ('linh_luc_regen_inc_pct', ''), [n('Abyssal Spring (Uyên Tuyền)', ('linh_luc_regen_inc_pct', ''), LL)])
MED('c86 wave_trough', HRI, [n('Lull (Lãng Tĩnh)', HRI, HP)])
MED('c42 bubble_m', ('attack_pct', 'companion'), [n('Paper Crane (Chỉ Hạc)', ('attack_pct', 'companion'), ('companion_speed_pct', '')),
                                                 n('Paper Guard (Chỉ Vệ)', ('attack_pct', 'companion'), ('companion_health_pct', ''))])
MED('c86 halo', ('soul_res_pct', ''), [n('Water Halo (Thủy Quang)', ('soul_res_pct', ''), NGO), n('Pale Moonlight (Đạm Nguyệt)', ('soul_res_pct', ''), ('defense_pct', ''))])
MED('c54 wave_scroll_m', CULT, [n('Water Classic (Thủy Kinh)', CULT, NGO), n('Climbing the Falls (Đăng Bộc)', CULT, HP)])
MED('c103 wave_scroll_b', THUY, [n('Raging Tide (Nộ Triều)', THUY, ('crit_damage_pct', 'thuy')), n('Ink Wave (Mặc Lãng)', THUY, ('attack_pct', 'talisman'))])
MED('c59 wave_scroll_a', ('art_speed_pct', 'curse'), [n('Binding Spell (Phược Chú)', ('art_speed_pct', 'curse'), ('curse_effect_pct', '')),
                                                     n('Water Shackles (Thủy Tỏa)', ('art_speed_pct', 'curse'), ('status_duration_pct', 'curse'))])
MED('c108 vortex', ('linh_luc_on_hit_pct', 'thuy'), [n('Black Vortex (Hắc Toàn)', ('linh_luc_on_hit_pct', 'thuy'), THUY),
                                                    n('Water Siphon (Hấp Thủy)', ('linh_luc_on_hit_pct', 'thuy'), LEECH)])
MED('c108 drip_hook', HEAL, [n('Water Wears Stone (Tích Thủy Xuyên Thạch)', HEAL, LR), n('Water Clock (Lậu Khắc)', HEAL, HRI)])
MED('c11 current', EV, [n('Rapids (Cấp Lưu)', EV, LEECH), n('Fish Through the Net (Lậu Võng Ngư)', EV, ('escape_pct', ''))])
MED('c17 koi_b', NGO, [n('Koi (Cẩm Lý)', NGO, ('khi_van', '')), n('Golden Koi (Kim Lý)', NGO, ('co_duyen_pct', ''))])
MED('c17 koi_a', LR, [n('Joy of the Fish (Ngư Lạc)', LR, NGO), n('Red Koi (Hồng Lý)', LR, HP)])
MED('c103 teardrop', ('healing_taken_pct', ''), [n('Mermaid Tears (Giao Lệ)', ('healing_taken_pct', ''), HRI)])
MED('c103 crescent_moon', CRC, [n('Ice Sickle (Băng Liêm)', CRC, COLD), n('Cold Moon (Hàn Nguyệt)', CRC, RC)])
MED('c17 koi_current', EV, [n('Koi Current (Lý Lưu)', EV, ('travel_speed_pct', '')), n('River Spirit (Hà Linh)', EV, NGO)])
MED('c54 ripple_outer', ('tam_ma_resist_pct', ''), [n('Settled Silt (Trầm Sa)', ('tam_ma_resist_pct', ''), NGO),
                                                    n('Heart Like Water (Tâm Như Thủy)', ('tam_ma_resist_pct', ''), ('dao_tam', ''))])


# ================= E. Small clusters: one line each by hand (choice 1b); notables = line + a partner =================
RES = ('reserve_eff_pct', ''); SOULR = ('soul_res_pct', ''); TM = ('tam_ma_resist_pct', ''); OHT = ('linh_luc_on_hit_pct', 'thuy')
SM('c5 C_crescent1', NGO, [('Pebble in the Pond (Đầu Thạch)', LL)])
SM('c45 Z45_1782', COLD, [('Frost Crack (Băng Liệt)', CRC)])
SM('c45 I_icicle1', CRC, [('Ice Needle (Băng Châm)', COLD)])
SM('c45 I_icicle2', BANG, [('Frozen Falls (Băng Bộc)', RC)])
SM('c118 spoke_arch', ('art_cost_pct', 'thuy'), [('Rainbow Bridge (Hồng Kiều)', LR)])
SM('c115 eye_lens_a', NGO, [('Water Eye (Thủy Nhãn)', TT)])
SM('c46 eye_lens_b', RC, [('Ice Pupil (Băng Đồng)', HP), ('Ice Mirror (Băng Kính)', ('defense_pct', ''))])
SM('c45 frost_ripple', IST, [('Creeping Frost (Sương Mạn)', COLD), ('Ice Ring Seal (Băng Hoàn Ấn)', BANG)])
SM('c46 frost_ripple_m', COLD, [('Cold Wave (Hàn Ba)', ('resist_pen_pct', 'cold')), ('Frozen Lake (Băng Hồ)', CRC)])
SM('c45 Z45_1794', LL, [('Ice House (Băng Thất)', NGO)])
SM('c115 Y115_1783', LR, [('Twin Streams (Song Khê)', SPT)])
SM('c118 Z118_1790', THUY, [('Nine Bends (Cửu Khúc)', ('art_cost_pct', 'thuy'))])
SM('c46 Z46_1786', CRC, [('Frost Glint (Sương Quang)', BANG)])
SM('c32 C_crook', HEAL, [('Timely Rain (Thời Vũ)', HRI)])
SM('c32 Z32_1790', ('travel_speed_pct', ''), [('Misty Rain (Yên Vũ)', ('escape_pct', ''))])
SM('c38 Z38_1786', BANG, [('Blizzard (Bạo Tuyết)', IST)])
SM('c22 lotus_bud', THUY, [('Sleeping Lotus (Thụy Liên)', NGO), ('Wave Flowers (Lãng Hoa)', CRT)])
SM('c22 C_crescent', ('resist_pen_pct', 'cold'), [('Frost Blade (Sương Nhận)', THUY)])
SM('c38 Z38_1789', RC, [('Snowdrift (Tích Tuyết)', HP), ('Frost Shield (Hàn Thuẫn)', ('defense_pct', ''))])
SM('c38 T_tadpole', COLD, [('Ice Lance (Băng Thương)', CRC)])
SM('c22 Z22_1876', SPT, [('Racing Waves (Bôn Lãng)', THUY)])
SM('c26 Z26_1863', EV, [('Dry in the Rain (Vũ Bất Triêm)', SPT)])
SM('c26 D_hook', ('art_cost_pct', 'thuy'), [('Dragon-Spine Pump (Long Cốt Xa)', LR)])
SM('c38 Y38_1868', NGO, [('Winter Pond (Hàn Đường)', BANG)])
SM('c32 T_tadpole', HRI, [('Sweet Dew (Cam Lộ)', HEAL)])
SM('c26 reflection', HEAL, [('Rain Mirror (Vũ Kính)', NGO), ('Puddle (Thủy Oa)', EV)])
SM('c38 lotus_bud', ('linh_luc_regen_inc_pct', ''), [('Snow Bud (Tuyết Nhụy)', BANG)])
SM('c69 Z69_1874', RES, [('Sunken Depths (Trầm Uyên)', LL)])
SM('c76 Z76_1867', ('attack_pct', 'talisman'), [('Ink Trace (Mặc Ngân)', TT)])
SM('c91 Z91_1867', SOULR, [('Pale Ink (Đạm Mặc)', NGO)])
SM('c86 Z86_1874', LL, [('Thick Ink (Nùng Mặc)', RES)])
SM('c86 D_drop', HRI, [('Willow-Branch Water (Dương Chi Thủy)', HEAL)])
SM('c76 Z76_1880', ('art_speed_pct', 'talisman'), [('Running Script (Hành Thư)', ('attack_pct', 'talisman'))])
SM('c42 Z42_1877', ('companion_power_pct', ''), [('Paper Horse (Chỉ Mã)', ('companion_speed_pct', ''))])
SM('c69 Z69_1890', LL, [('Black Pool (Hắc Đàm)', ('linh_luc_regen_inc_pct', ''))])
SM('c42 bubble_s', ('companion_health_pct', ''), [('Bubble Shield (Phao Thuẫn)', ('companion_power_pct', ''))])
SM('c86 lotus_petal', NGO, [('Lotus Petal (Liên Biện)', SOULR)])
SM('c86 Z86_1894', EV, [('Walking on Water (Đạp Thủy)', RES)])
SM('c17 Z17_1895', LR, [('Riding the Tide (Thừa Triều)', THUY)])
SM('c11 Z11_1884', LEECH, [('Whirling Step (Toàn Bộ)', EV)])
SM('c17 lotus_petal', CULT, [('River Lotus (Hà Liên)', NGO)])
SM('c54 Y54_1890', NGO, [('Golden Scales (Kim Lân)', HP)])
SM('c103 C_crescent', CRC, [('Snow Moon (Tuyết Nguyệt)', RC)])
SM('c11 Z11_1500', SOULR, [('Lakeside Pavilion (Hồ Đình)', NGO)])
SM('c54 T_crescent', TM, [("Yu's Gate (Vũ Môn)", NGO)])
SM('c108 K_kelp2', HEAL, [('Sea Kelp (Hải Tảo)', HRI)])
SM('c11 C_crescent', EV, [('Mirage (Thận Lâu)', SOULR)])
SM('c108 K_kelp1', OHT, [('Clinging Weed (Triền Tảo)', THUY)])
SM('c17 axis_ripple_b', ('travel_speed_pct', ''), [('Ferry Crossing (Độ Khẩu)', CULT)])
SM('c11 axis_ripple_a', THUY, [('Whale Drinks (Kình Ẩm)', LEECH)])
SM('c54 Z54_1811', CULT, [('Rowing Upstream (Nghịch Thủy Hành Chu)', NGO)])
SM('c17 Y17_1812', ('linh_luc_regen_inc_pct', ''), [('Estuary (Hà Khẩu)', LR)])
SM('c108 Z108_515', ('curse_effect_pct', ''), [('Drifting Duckweed (Phù Bình)', ('status_duration_pct', 'curse'))])
SM('c59 Z59_1801', ('status_duration_pct', 'curse'), [('Thousand Knots (Thiên Kết)', ('curse_effect_pct', ''))])
SM('c103 Z103_512', RC, [('Frozen Tears (Băng Lệ)', HRI)])
SM('c11 Z11_1801', NGO, [('Lone Angler (Độc Điếu)', TM)])
SM('c54 ripple_inner', LR, [('Ancient Well (Cổ Tỉnh)', NGO)])


# ================= Loose small nodes (base map proposal nodes, no cluster): one line per mirrored pair =================
ONE([1979, 1980], ('ngo_tinh', ''))
ONE([1981, 1983], ('attack_pct', 'thuy'))
ONE([1982, 1984], ('khi_huyet_pct', ''))
ONE([1987, 1988], ('linh_luc_pct', ''))
ONE([1989, 1990], ('ngo_tinh', ''))

# ================= B. Keystones =================
KEY('c904 keystone_dark', 'Still Water (Tĩnh Thủy)', 'Still Water (Tĩnh Thủy)',
    [('linh_luc_pct', '', 30), ('linh_luc_regen_pct', '', 20)], closes='healing taken from other sources -50 %')
KEY('c904 keystone_hook', 'Flowing Water (Lưu Thủy)', 'Flowing Water (Lưu Thủy)',
    [('art_speed_pct', 'thuy', 25), ('crit_chance_pct', 'thuy', 25)], closes='art costs +40 %')
KEY('c904 keystone_rim_L', 'Thousand Talismans (Thiên Phù)', 'Thousand Talismans (Thiên Phù)',
    [('attack_pct', 'talisman', 30), ('art_speed_pct', 'talisman', 20)],
    closes="arts that are not talismans deal 30 % less; pending: talisman stock +2 once Talismans defines it")
KEY('c904 keystone_rim_R', 'Boundless Sea (Vô Biên Hải)', 'Boundless Sea (Vô Biên Hải)',
    [('linh_luc_pct', '', 30), ('leech_linh_luc_pct', '', 20)], closes='linh lực no longer regenerates on its own and linh lực on hit gives nothing')

# ---- start keystones (added 2026-11-19): the hexagon (6 points from the Ice start) and the tide pair by the Water start ----
KEY('c904 keystone_start', 'Frost Seal (Băng Phong)', 'Frost Seal (Băng Phong)',
    [('stack_effect_pct', 'bang,debuff', 30), ('resist_pen_pct', 'cold', 20)], closes='arts of Fire (Hỏa) you slot deal 50 % less')
KEY('c904 keystone_tide_a', 'Rising Tide (Triều Dâng)', 'Rising Tide (Triều Dâng)',
    [('linh_luc_pct', '', 25), ('linh_luc_regen_pct', '', 25)], closes='while your linh lực is below half, your Water buff stacks do nothing')
KEY('c904 keystone_tide_b', 'Ebb Tide (Triều Rút)', 'Ebb Tide (Triều Rút)',
    [('attack_pct', 'thuy', 25), ('art_speed_pct', 'thuy', 25)], closes='maximum linh lực −15 %')
