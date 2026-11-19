# Fire (Hỏa) content on v5. Written by hand under design/dao-do/content-method.md.
# Big pictures take their idea and lines from ideas.py; notables are listed in walk order (crown last).
# Budgets in W: small nodes 1.2 (automatic), notables 8, capability notables f_tier * 8 (Formulas E).

FIRE = ('attack_pct', 'hoa')

# ================= C. Big pictures =================
BIG('c3 A_wing', [
    N('Banked Embers (Tàng Tẫn)', ('tam_ma_resist_pct', '', 4), ('than_hon', '', 4)),
    N('Steady Flame (Ổn Hỏa)', ('than_hon', '', 4), ('khi_huyet_pct', '', 4)),
    N('Ember Heart (Ẩn Hỏa Tâm)', ('tam_ma_resist_pct', '', 4), ('breakthrough_chance', '', 4)),
])
BIG('c62 corona', [
    N("Sun Crow's Wing (Ô Dực)", ('art_speed_pct', 'hoa', 5), ('attack_pct', 'hoa', 3)),
    N('Three-Legged Crow (Tam Túc Ô)', ('art_speed_pct', 'hoa', 4), ('accuracy_pct', '', 4)),
    N('Golden Feathers (Kim Vũ)', ('attack_pct', 'hoa', 4), ('crit_chance_pct', 'hoa', 4)),
    N('Crow Over the Sun (Kim Ô Việt Nhật)', ('art_speed_pct', 'hoa', 4), ('crit_damage_pct', 'hoa', 4)),
])
BIG('c62 halo', [
    N('Cinder Petals (Tẫn Biện)', ('resist_pct', 'fire', 4), ('khi_huyet_pct', '', 4)),
    N('Cool Ash (Lãnh Hôi)', ('health_regen_pct', '', 4), ('status_resist_pct', 'burn', 4)),
    N('Ash Lotus (Hôi Liên)', ('resist_pct', 'fire', 4), ('health_regen_pct', '', 4)),
])
BIG('c120 comet', [
    N('Molten Shell (Dung Xác)', ('defense_pct', '', 5), ('resist_pct', 'fire', 3)),
    N('Molten Core (Dung Hạch)', ('attack_pct', 'hoa', 5), ('defense_pct', '', 3)),
])
BIG('c119 flicker', [
    N('Dry Kindling (Can Sài)', ('attack_pct', 'moc', 4), ('attack_pct', 'hoa', 4)),
    N('Rising Sparks (Phi Hỏa)', ('attack_pct', 'hoa', 4), ('art_speed_pct', 'moc', 4)),
    N('Wood Feeds Fire (Mộc Sinh Hỏa)', ('attack_pct', 'moc,hoa', 5), ('khi_van', '', 3)),
])
BIG('c18 sun', [
    N('Noon Heat (Ngọ Nhiệt)', ('attack_pct', 'fire', 5), ('crit_chance_pct', 'fire', 3)),
    N('True Flame (Chân Hỏa)', ('attack_pct', 'fire', 4), ('resist_pen_pct', 'fire', 4)),
    N('Sun Disc (Thái Dương Luân)', ('crit_chance_pct', 'fire', 4), ('crit_damage_pct', 'hoa', 4)),
])
BIG('c28 spiral', [
    N('Odd Brew (Dị Luyện)', ('alchemy_success', '', 4), ('khi_van', '', 4)),
    N('Strange Pill Reborn (Dị Đan Hóa Sinh)', ('alchemy_success', '', 2), cap=('#11', 'T2'),
      alt=[('khi_van', '', 4), ('pill_effect_pct', '', 4)], alt_name='Lucky Mutation (Hạnh Biến)'),
])
BIG('c29 wisp', [
    N('Pill Pouch (Đan Nang)', ('pill_effect_pct', '', 5), ('cultivation_speed_pct', '', 3)),
    N('Ready Remedy (Bị Dược)', ('pill_effect_pct', '', 4), ('healing_pct', '', 4)),
])
BIG('c28 wisp', [
    N('Burnt Dross (Phần Tra)', ('dan_doc_decay', '', 4), ('dan_doc_resist_pct', '', 4)),
    N('Toxin-Burning Fire (Luyện Độc Hỏa)', ('dan_doc_resist_pct', '', 4), ('pill_effect_pct', '', 4)),
])
BIG('c28 sunrise', [
    N('Nine Turns (Cửu Chuyển)', ('alchemy_success', '', 5), ('pill_effect_pct', '', 3),
      pending=[('pill_quality_chance', '', 3)]),
    N('Furnace Fire (Lô Hỏa)', ('attack_pct', 'hoa', 4), ('alchemy_success', '', 4)),
    N('Divided Furnace Flame (Đan Hỏa Phân Lô)', ('alchemy_success', '', 4), cap=('#10', 'T1'),
      alt=[('alchemy_success', '', 5), ('pill_effect_pct', '', 3)], alt_name='Twin Furnace (Song Lô)'),
])
BIG('c92 feather', [
    N('Warm Ash (Ôn Hôi)', ('health_regen_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Rekindled (Tái Nhiên)', ('healing_taken_pct', '', 4), ('health_regen_pct', '', 4)),
    N('Phoenix Down (Phượng Nhung)', ('khi_huyet_pct', '', 4), ('healing_taken_pct', '', 4)),
    N('Second Breath (Hồi Khí)', ('health_regen_pct', '', 4), ('linh_luc_regen_inc_pct', '', 4)),
    N('Rise From Ash (Dục Hỏa)', ('health_regen_pct', '', 5), ('health_regen_inc_pct', '', 3)),
])
BIG('c49 torch', [
    N('Lamp Wick (Đăng Tâm)', ('x_soul', '', 4), ('than_hon', '', 4)),
    N('Soul-Burning Lamp (Phần Hồn Đăng)', ('x_soul', 'hoa', 5), ('soul_res_pct', '', 3)),
])
BIG('c47 wing', [
    N('Heated Steel (Xích Thiết)', ('attack_pct', 'physical', 4), ('convert_pct', 'physical>fire', 4)),
    N('Red Edge (Hồng Nhận)', ('convert_pct', 'physical>fire', 4), ('attack_pct', 'fire', 4)),
    N('Forge Arm (Đoán Tý)', ('attack_pct', 'physical', 4), ('crit_chance_pct', 'physical', 4)),
    N('Burning Blade (Hỏa Nhận)', ('convert_pct', 'physical>fire', 5), ('attack_pct', 'sword,hoa', 3)),
])
BIG('c49 firework', [
    N('Hidden Embers (Phục Hỏa)', ('linh_luc_on_hit_pct', 'hoa', 4), ('attack_pct', 'hoa', 4)),
    N('Smoke Swallowing (Thôn Yên)', ('leech_linh_luc_pct', 'hoa', 4), ('linh_luc_pct', '', 4)),
    N('Smouldering Qi (Âm Hỏa)', ('linh_luc_on_hit_pct', 'hoa', 4), ('leech_linh_luc_pct', 'hoa', 4)),
])
BIG('c105 trident', [
    N('Magma Chamber (Dung Thất)', ('linh_luc_pct', '', 4), ('attack_pct', 'hoa,slow', 4)),
    N('Pyroclast (Hỏa Tiết)', ('attack_pct', 'hoa,slow', 5), ('crit_damage_pct', 'hoa', 3)),
    N('Volcano (Hỏa Sơn)', ('linh_luc_pct', '', 4), ('attack_pct', 'fire', 4), effect='Eruption (Bộc Phát)'),
])
BIG('c101 star', [
    N('White Heat (Bạch Nhiệt)', ('resist_pen_pct', 'fire', 4), ('attack_pct', 'hoa', 4)),
    N('Will of Fire (Hỏa Ý)', ('attack_pct', 'hoa', 4), ('than_hon', '', 4)),
    N('Searing Will (Chước Ý)', ('resist_pen_pct', 'fire', 5), ('attack_pct', 'fire', 3)),
])
BIG('c53 fleur', [
    N('Sparks on Grass (Tinh Hỏa)', ('stack_effect_pct', 'hoa,debuff', 4), ('attack_pct', 'over_time', 4)),
    N('Long Burn (Cửu Thiêu)', ('stack_duration_pct', 'hoa,debuff', 4), ('stack_effect_pct', 'hoa,debuff', 4)),
    N('Prairie Fire (Liệu Nguyên Hỏa)', ('stack_effect_pct', 'hoa,debuff', 4), ('attack_pct', 'over_time,hoa', 4),
      effect='Wildfire (Dã Hỏa)'),
])
BIG('c901 trefoil_R', [
    N('Phoenix Plume (Phượng Linh)', ('khi_huyet_pct', '', 4), ('healing_pct', '', 4)),
    N('Crimson Tail (Xích Vĩ)', ('khi_huyet_pct', '', 5), ('resist_pct', 'fire', 3)),
    N('Rebirth Flame (Niết Bàn Hỏa)', ('healing_pct', '', 4), ('health_regen_pct', '', 4)),
    N('Burning Wings (Nhiên Dực)', ('attack_pct', 'hoa', 4), ('khi_huyet_pct', '', 4)),
    N('Phoenix Cry (Phượng Minh)', ('healing_pct', '', 5), ('soul_res_pct', '', 3)),
    N('Undying Ember (Bất Diệt Hỏa)', ('khi_huyet_pct', '', 4), ('healing_taken_pct', '', 4)),
    N('Five Virtues (Ngũ Đức)', ('healing_pct', '', 4), ('tam_ma_resist_pct', '', 4)),
    N('Soul Leaves the Body (Linh Hồn Xuất Khiếu)', cap=('#5', 'T3'),
      alt=[('khi_huyet_pct', '', 4), ('healing_pct', '', 4)], alt_name='Phoenix Rising (Phượng Thăng)'),
])
BIG('c901 ding_R', [
    N('Last Light (Tàn Quang)', ('lifespan_pct', '', 4), ('khi_huyet_pct', '', 4)),
    N('Long Candle (Trường Chúc)', ('lifespan_pct', '', 5), ('tam_ma_resist_pct', '', 3)),
    N('Flare (Hồi Hỏa)', ('breakthrough_chance', '', 4), ('than_hon', '', 4)),
    N('Last Radiance (Hồi Quang Phản Chiếu)', cap=('#22', 'T3'),
      alt=[('lifespan_pct', '', 4), ('healing_taken_pct', '', 4)], alt_name='Candle Flame (Chúc Diễm)'),
])


# ================= Loose small nodes (base map proposal nodes, no cluster): one line per mirrored pair =================
ONE([1931, 1932], ('than_hon', ''))
ONE([1933, 1935], ('attack_pct', 'hoa'))
ONE([1934, 1936], ('khi_huyet_pct', ''))
ONE([1939, 1940], ('crit_chance_pct', 'hoa'))
ONE([1941, 1942], ('than_hon', ''))

# ================= B. Keystones (effects in ../effects-draft.md) =================
KEY('c901 keystone_R', 'Burning Lifespan (Nhiên Thọ)', 'Burning Lifespan (Nhiên Thọ)',
    [('attack_pct', 'hoa', 25), ('khi_huyet_pct', '', 25)], closes='when it fires, 2 % of your realm base lifespan in years is burned, win or lose (starter record)')
KEY('c901 keystone_L', 'Ever-Burning Furnace (Vĩnh Nhiên Lô)', 'Ever-Burning Furnace (Vĩnh Nhiên Lô)',
    [('linh_luc_pct', '', 20), ('stack_effect_pct', 'hoa,debuff', 30)], closes='linh lực regeneration 0')
KEY('c901 keystone_rim_R', "Alchemist's Heart (Đan Tâm)", "Alchemist's Heart (Đan Tâm)",
    [('pill_effect_pct', '', 25), ('alchemy_success', '', 15), ('free_slots', 'pill', 10)], closes='pill toxicity fades half as fast')
KEY('c901 keystone_rim_L', 'Overheat (Quá Nhiệt)', 'Overheat (Quá Nhiệt)',
    [('art_speed_pct', 'hoa', 30), ('attack_pct', 'hoa', 20)], closes='art costs +35 %')

# ================= D. Medium clusters and start figures =================
# Theme line from the Fire pool (pools.md), supporting the cell's big picture without repeating its main line.
SOUL = ('than_hon', ''); HP = ('khi_huyet_pct', ''); RF = ('resist_pct', 'fire'); FT = ('attack_pct', 'fire')
CRH = ('crit_chance_pct', 'hoa'); CDH = ('crit_damage_pct', 'hoa'); SPH = ('art_speed_pct', 'hoa'); OT = ('attack_pct', 'over_time')
BSTK = ('stack_effect_pct', 'hoa,debuff'); BDUR = ('stack_duration_pct', 'hoa,debuff'); PENF = ('resist_pen_pct', 'fire')
TM = ('tam_ma_resist_pct', ''); LL = ('linh_luc_pct', ''); PHY = ('attack_pct', 'physical')
MED('base1', SOUL, [n('Fire Start (Hỏa Khởi)', SOUL, FIRE), n('First Spark (Toại Hỏa)', SOUL, SPH),
                    n('Warm Blood (Ôn Huyết)', SOUL, HP), n('Fire Root (Hỏa Căn)', FIRE, RF)])
MED('base11', SOUL, [n('Fire Seal (Hỏa Ấn)', SOUL, FIRE), n('Pillar of Flame (Hỏa Trụ)', SOUL, HP)])
MED('c3 flame_scroll', SOUL, [n('Scroll of Flame (Hỏa Quyển)', SOUL, TM)])
MED('c120 flame_eye', RF, [n('Ember Eye (Hỏa Nhãn)', RF, ('defense_pct', ''))])
MED('c119 flame_scroll', OT, [n('Kindling Scroll (Dẫn Hỏa Quyển)', OT, ('khi_van', ''))])
MED('c63 ember', CRH, [n('Ember Spark (Tẫn Tinh)', CRH, FIRE), n('Ember Ward (Tẫn Thuẫn)', CRH, RF)])
MED('c28 pinwheel', SOUL, [n('Furnace Heart (Lô Tâm)', SOUL, ('alchemy_success', '')), n('Turning Flame (Chuyển Hỏa)', SOUL, ('pill_effect_pct', '')),
                           n('Steady Hands (Ổn Thủ)', SOUL, ('dan_doc_decay', ''))])
MED('c29 crescent', HP, [n('Moon Embers (Nguyệt Tẫn)', HP, ('pill_effect_pct', '')), n('Night Brew (Dạ Luyện)', HP, ('alchemy_success', ''))])
MED('c37 drop', PENF, [n('Molten Drop (Dung Tích)', PENF, FT), n('Sun Drop (Nhật Tích)', PENF, ('crit_chance_pct', 'fire'))])
MED('c18 spark', FIRE, [n('Sunspark (Nhật Tinh Hỏa)', FIRE, CDH)])
MED('c18 flame_b', FIRE, [n('Kindling (Dẫn Hỏa)', FIRE, ('crit_chance_pct', '')), n('Ember Glow (Tẫn Quang)', FIRE, HP)])
MED('c18 flame_c', SPH, [n('Flare Lick (Diễm Thiệt)', SPH, FT), n('Tongue of Flame (Hỏa Thiệt)', SPH, HP)])
MED('c29 flame_crown', ('alchemy_success', ''), [n('Crown of the Furnace (Lô Quan)', ('alchemy_success', ''), SOUL),
                                                 n('Bright Furnace (Minh Lô)', ('alchemy_success', ''), ('pill_effect_pct', ''))])
MED('c28 horizon_sun', ('health_regen_pct', ''), [n('Clean Burn (Tịnh Nhiên)', ('health_regen_pct', ''), ('dan_doc_resist_pct', '')),
                                                   n('Horizon Heat (Thiên Tế Nhiệt)', ('health_regen_pct', ''), SOUL)])
MED('c47 horizon_sun', FIRE, [n('Forge Glow (Lô Quang)', FIRE, HP), n("Smith's Sun (Đoán Nhật)", FIRE, ('crit_chance_pct', 'physical'))])
MED('c49 flame_crown', LL, [n('Lamp Oil (Đăng Du)', LL, ('x_soul', '')), n('Crown of Smoke (Yên Quan)', LL, ('linh_luc_on_hit_pct', 'hoa'))])
MED('c92 candle', ('health_regen_inc_pct', ''), [n('Candle Warmth (Ôn Chúc)', ('health_regen_inc_pct', ''), HP)])
MED('c70 embers', BSTK, [n('Smouldering Embers (Ám Tẫn)', BSTK, OT), n('Ember Bed (Tẫn Sàng)', BSTK, RF)])
MED('c47 loop', ('crit_chance_pct', 'physical'), [n('Quench (Thối Hỏa)', ('crit_chance_pct', 'physical'), ('attack_pct', 'sword'))])
MED('c70 heart_R', SOUL, [n('Heart of Flame (Hỏa Tâm)', SOUL, TM)])
MED('c70 heart_L', HP, [n('Warm Heart (Ôn Tâm)', HP, ('health_regen_pct', ''))])
MED('c92 twin', HP, [n('Twin Flames (Song Diễm)', HP, ('healing_pct', '')), n('Paired Phoenixes (Song Phượng)', HP, ('health_regen_inc_pct', ''))])
MED('c47 eye', ('accuracy_pct', ''), [n("Smith's Eye (Tượng Nhãn)", ('accuracy_pct', ''), PHY)])
MED('c49 ember_petals', ('soul_res_pct', ''), [n('Fire Lotus Ward (Hỏa Liên Hộ)', ('soul_res_pct', ''), ('x_soul', ''))])
MED('c53 ember_petals', OT, [n('Drifting Ash (Phi Hôi)', OT, BDUR)])
MED('c56 crown', FIRE, [n('Fire Crown (Hỏa Miện)', FIRE, CDH), n('Burning Diadem (Nhiên Quan)', FIRE, LL), n('Crowned Flame (Quan Diễm)', FIRE, SOUL)])
MED('c14 arcL', ('art_cost_pct', 'hoa'), [n('Frugal Flame (Kiệm Hỏa)', ('art_cost_pct', 'hoa'), FIRE),
                                         n('Cool Draft (Lương Phong)', ('art_cost_pct', 'hoa'), ('linh_luc_regen_inc_pct', ''))])
MED('c56 taiji_a', RF, [n('Fire Taiji (Hỏa Thái Cực)', RF, HP), n('Water in Fire (Hỏa Trung Thủy)', RF, ('resist_pct', 'cold'))])
MED('c53 fireball', BDUR, [n('Fireball (Hỏa Cầu)', BDUR, FIRE), n('Rolling Fire (Cổn Hỏa)', BDUR, BSTK)])
MED('c105 w_orbit', CDH, [n('Lava Tide (Dung Triều)', CDH, ('attack_pct', 'hoa,slow')), n('Ash Fall (Hôi Vũ)', CDH, LL)])
MED('c14 ring', HP, [n('Fire Barrier (Hỏa Chướng)', HP, RF), n('Ember Moat (Tẫn Hào)', HP, FIRE)])
MED('c101 split_ring_L', CDH, [n('Split Flame (Phân Diễm)', CDH, SOUL), n('Seared (Chước Thương)', CDH, CRH)])
MED('c53 split_ring_R', OT, [n('Searing Brand (Lạc Ấn)', OT, BSTK), n('Long Smoulder (Trường Ám Hỏa)', OT, HP)])
MED('c14 arcR', SPH, [n('Flash Ignition (Thuấn Nhiên)', SPH, FIRE), n('Bursting Sparks (Bính Hỏa)', SPH, CRH)])
MED('c56 taiji_b', TM, [n('Fire Balance (Thủy Hỏa Tương Tế)', TM, SOUL), n('Calm Fire (Tĩnh Hỏa)', TM, HP)])

# ================= E. Small clusters: one line each by hand (choice 1b); notables = line + a partner =================
ALC = ('alchemy_success', ''); PILL = ('pill_effect_pct', ''); HR = ('health_regen_pct', ''); OH = ('linh_luc_on_hit_pct', 'hoa')
SM('c3 C_spur', SOUL, [('Soul Flame (Hồn Hỏa)', FIRE), ('Warm Meridians (Ôn Mạch)', HP)])
SM('c3 wall_spark_a1535', SOUL, [('Furnace Wall (Lô Bích)', HP)])
SM('c62 wall_spark_a1535', FIRE, [('Flint Spark (Thạch Hỏa)', CRH)])
SM('c63 wall_spark_a1541', RF, [('Heat Ward (Ngự Nhiệt)', HP)])
SM('c120 A_wheel', FIRE, [('Ember Armour (Tẫn Giáp)', ('defense_pct', ''))])
SM('c119 A_tadpole', OT, [('Incense Flame (Hương Hỏa)', ('khi_van', ''))])
SM('c62 d_tadpole_1547', SPH, [('Darting Flame (Thoán Hỏa)', FIRE)])
SM('c62 w_lens_1545', HR, [('Hot Spring (Ôn Tuyền)', RF)])
SM('c62 w5_hairpin_1549', CRH, [('Needle of Flame (Hỏa Châm)', FIRE)])
SM('c63 w5_hairpin_1556', SOUL, [('Clear Heart (Minh Tâm)', TM)])
SM('c63 d_fork_1552', FT, [('Fire Lance (Hỏa Mâu)', ('crit_chance_pct', 'fire')), ('Twin Tongues (Song Thiệt)', SPH)])
SM('c62 E_crook', HP, [('Fire-Tempered Body (Hỏa Luyện Thân)', RF)])
SM('c28 d_crook_1551', ALC, [('Watching the Fire (Khán Hỏa)', SOUL)])
SM('c29 d_arch_1543', PILL, [('Cinnabar Chamber (Đan Thất)', HP), ('Pill Cauldron (Đan Đỉnh)', ALC)])
SM('c18 d_hook_1556', FT, [('Scorching Sun (Liệt Nhật)', PENF)])
SM('c37 d_hook_1549', ('crit_chance_pct', 'fire'), [('Glint (Thiểm Quang)', FT)])
SM('c18 flame_a', FIRE, [('Small Flame (Vi Hỏa)', SOUL)])
SM('c28 lily_R', ('dan_doc_resist_pct', ''), [('Fire Lily (Hỏa Bách Hợp)', PILL)])
SM('c18 lily_L', PENF, [('Red Lotus Fire (Hồng Liên Hỏa)', FT)])
SM('c37 d_diamond_1583', CDH, [('Sunfire Pearl (Nhật Hỏa Châu)', ('crit_chance_pct', 'fire'))])
SM('c18 d_diamond_1590', SPH, [('Wild Blaze (Cuồng Diễm)', FT)])
SM('c28 w5_diamond_1516', SOUL, [('Furnace Spirit (Lô Linh)', ALC)])
SM('c29 w5_diamond_1511', HP, [('Jade Pill (Ngọc Đan)', PILL)])
SM('c70 d_crook_1588', BSTK, [('Clinging Embers (Phụ Tẫn)', OT)])
SM('c74 d_crook_1581', FIRE, [('Fire Poison (Hỏa Độc)', BSTK)])
SM('c92 d_crook_1583', HR, [('Phoenix Nest (Phượng Sào)', ('healing_taken_pct', ''))])
SM('c47 d_fork_1584', PHY, [('Forge Tongs (Đoán Kiềm)', ('convert_pct', 'physical>fire')), ('Hot Iron (Nhiệt Thiết)', ('crit_chance_pct', 'physical'))])
SM('c70 lily_D', RF, [('Ash Lily (Hôi Bách Hợp)', HP)])
SM('c93 ray1', FT, [('Dawn Light (Thần Quang)', ('crit_chance_pct', 'fire'))])
SM('c93 ray2', ('crit_chance_pct', 'fire'), [('Morning Glare (Triêu Huy)', FIRE)])
SM('c93 ray3', SOUL, [('Warm Sunlight (Ôn Dương)', HP)])
SM('c93 ray4', PENF, [('Burning Sunbeam (Chước Dương)', FT)])
SM('c93 ray5', SPH, [('Setting Sun (Tà Dương)', CDH)])
SM('c49 d_hook_1577', ('x_soul', ''), [('Lamp of the Heart (Tâm Đăng)', SOUL)])
SM('c70 w_lens_1586', HP, [('Ember Cocoon (Tẫn Kiển)', HR)])
SM('c93 H_hairpin', FIRE, [('Dawn Blaze (Hiểu Diễm)', SPH)])
SM('c74 B_hook', TM, [('Still Heart (Tĩnh Tâm)', SOUL)])
SM('c93 W_wheel', CRH, [('Sun Chariot (Nhật Xa)', FT)])
SM('c70 core', SOUL, [('Ember Core (Tẫn Hạch)', FIRE)])
SM('c93 T_tadpole', OH, [('Fire Sprite (Hỏa Linh)', FIRE)])
SM('c93 F_fork', FT, [('Solar Flare (Nhật Diễm)', CDH), ('Sun Lance (Nhật Mâu)', PENF)])
SM('c92 d_ring_1600', ('healing_taken_pct', ''), [('Ash Cloak (Hôi Bào)', HR), ('Ember Rebirth (Tẫn Sinh)', HP)])
SM('c49 D_crook', OH, [('Rising Smoke (Khinh Yên)', LL)])
SM('c14 B_crook', ('art_cost_pct', 'hoa'), [('Gentle Fire (Văn Hỏa)', FIRE)])
SM('c14 H_diamond', CDH, [('Fierce Fire (Vũ Hỏa)', CRH)])
SM('c56 d_diamond_1606', RF, [('Li Trigram (Ly Quái)', TM)])
SM('c105 w_hook_1601', LL, [('Magma Vein (Dung Mạch)', ('attack_pct', 'hoa,slow'))])
SM('c101 d_diamond_1592', PENF, [('Piercing Heat (Thấu Nhiệt)', SOUL)])
SM('c53 d_hook_1595', BDUR, [('Burning Fields (Phần Dã)', OT)])
SM('c14 A_ring', HP, [('Vermilion Guard (Chu Tước Hộ)', RF), ('Hearth God (Táo Quân)', HR)])
SM('c14 G_hook', FIRE, [('Striking Flame (Kích Hỏa)', CRH)])
SM('c15 K_spur', SOUL, [('Burning Resolve (Nhiên Chí)', FIRE), ('Steeled Heart (Kiên Tâm)', TM)])
SM('c14 K_crescent', SPH, [('Swift Blaze (Tật Diễm)', FIRE)])
SM('c14 C_tadpole', BSTK, [('Creeping Embers (Mạn Tẫn)', OT)])
SM('c14 I_fork', FT, [('Melting Heat (Dung Nhiệt)', PENF), ('Twin Suns (Song Nhật)', ('crit_chance_pct', 'fire'))])
SM('c14 E_crescent', RF, [('Fireproof Robe (Tị Hỏa Y)', HP)])
SM('c53 w_zigzag', OT, [('Serpent Fire (Xà Hỏa)', BSTK)])
SM('c15 E_hairpin', HP, [('Warm Jade (Ôn Ngọc)', HR)])
SM('c101 d_hairpin_1557', FIRE, [('White Flame (Bạch Diễm)', PENF)])
SM('c14 D_arch', SOUL, [('Flame Gate (Hỏa Môn)', FIRE), ('Crimson Palace (Giáng Cung)', HP)])
SM('c14 J_crook', CRH, [('Finger Flame (Chỉ Hỏa)', CDH)])
SM('c56 w_hairpin', FIRE, [('Kan and Li (Khảm Ly)', RF)])
SM('c56 C_crook', SOUL, [('Fire Descends (Hỏa Giáng)', ('dao_tam', ''))])
SM('c101 d_fork_518', PENF, [('Searing Thrust (Chước Thứ)', FT), ('White Gleam (Bạch Mang)', ('crit_chance_pct', 'fire'))])
SM('c105 D_crook', FIRE, [('Cinder Store (Tích Tẫn)', LL)])
SM('c56 w_petals_1568', HP, [('Lotus Heart (Liên Tâm)', TM)])
SM('c105 w_petals_1568', CDH, [('Lava Bloom (Dung Hoa)', ('attack_pct', 'hoa,slow'))])

# ---- start keystone (added 2026-11-19: user "add more keystones", in the hexagon on the land's axis, 9 points out) ----
KEY('c901 keystone_start', 'Fire Feeds Fire (Dĩ Hỏa Dưỡng Hỏa)', 'Fire Feeds Fire (Dĩ Hỏa Dưỡng Hỏa)',
    [('stack_effect_pct', 'hoa,debuff', 30), ('attack_pct', 'hoa', 20)], closes='arts of Water (Thủy) you slot deal 50 % less')
