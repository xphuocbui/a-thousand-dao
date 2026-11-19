# Darkness island (Ám) and the Shadow Shrine on v5. KILL is a drain line (linh lực leech): fights are duels (Combat rule 1), so no on-kill stat. Written by hand under content-method.md. Notables in walk order.
CH = ('attack_pct', 'chaos'); SOUL = ('x_soul', ''); TM = ('tam_ma_resist_pct', ''); QD = ('qi_deviation_pct', '')
CULT = ('cultivation_speed_pct', ''); KILL = ('leech_linh_luc_pct', ''); HIDE = ('stealth', ''); ESC = ('escape_pct', '')
EV = ('evade_pct', ''); CRIT = ('crit_chance_pct', ''); HP = ('khi_huyet_pct', ''); DT = ('dao_tam', '')

BIG('c933 long_spiral_l', [
    n('Shadow Trail (Ảnh Tích)', EV, ESC), n('Shadow Steps (Ảnh Bộ)', EV, ('art_speed_pct', ''), 5, 3),
])
BIG('c933 full_moon', [
    n('Moonless Night (Vô Nguyệt Dạ)', EV, ('crit_damage_pct', '')), n('Waning Moon Slash (Tàn Nguyệt Trảm)', CRIT, ('crit_damage_pct', '')),
    n('New Moon (Sóc Nguyệt)', CRIT, EV, 5, 3, effect='Dark of the Moon (Sóc Ám)'),
])
BIG('c933 horn_and_s_l', [
    n('Moth Wings (Nga Sí)', ('curse_effect_pct', ''), ('art_cost_pct', 'curse')), n('Illusory Eyes (Huyễn Nhãn)', ('curse_effect_pct', ''), EV),
    n('Dust of Wings (Sí Phấn)', ('art_cost_pct', 'curse'), ('status_duration_pct', 'curse')),
    n('Night Moth (Dạ Nga)', ('curse_effect_pct', ''), ('linh_luc_on_hit_pct', ''), 5, 3),
])
# The Shadow Shrine's eclipse: two ideas, S1 Heart Demon Altar (ma đạo offence) and S2 Incense Smoke (heart control).
BIG('c933 shrine_eclipse', pat='AB', nts=[
    n('Shrine Gate (Từ Môn)', CH, TM), n('Black Incense (Hắc Hương)', TM, QD), n('Demon Whisper (Ma Ngữ)', SOUL, CH),
    n('Calm Smoke (Tĩnh Yên)', TM, EV), n('Eclipse Edge (Thực Biên)', CH, CRIT), n('Offering (Tế Phẩm)', HP, TM),
    n('Demonic Path (Ma Đạo)', CH, ('than_hon', '')), n('Censer (Hương Lô)', QD, ('linh_luc_regen_inc_pct', '')),
    n('Soul Lantern (Hồn Đăng)', SOUL, ('soul_res_pct', '')), n('Curling Smoke (Niểu Yên)', TM, ('ngo_tinh', '')),
    n('Demon Eye (Ma Nhãn)', CRIT, SOUL), n('Smoke Veil (Yên Mạc)', HIDE, TM), n('Shadow Altar (Ảnh Đài)', CH, HP),
    n('Prayer Beads (Niệm Châu)', QD, ('than_hon', '')), n('Blood Rite (Huyết Tế)', CH, ('linh_luc_on_hit_pct', '')),
    n('Sandalwood (Đàn Hương)', TM, ('health_regen_inc_pct', '')), n('Black Sun (Hắc Nhật)', CH, ('resist_pen_pct', 'chaos')),
    n('Quiet Heart (Tĩnh Tâm)', TM, ('soul_res_pct', '')), n('Demon Mark (Ma Ấn)', SOUL, ('curse_effect_pct', '')),
    n('Ash Altar (Hôi Đài)', QD, HP), n('Umbra (Bản Ảnh)', CH, EV), n('Coiled Incense (Bàn Hương)', TM, ('linh_luc_pct', '')),
    n('Hungry Shade (Ngạ Ảnh)', SOUL, ('linh_luc_on_hit_pct', '')), n('Temple Silence (Tự Tĩnh)', ('status_resist_pct', ''), TM),
    n('Corona of Night (Dạ Miện)', CH, ('crit_damage_pct', '')), n('Smoke Mirror (Yên Kính)', QD, ('ngo_tinh', '')),
    n('Soul-Hooking Art (Câu Hồn)', SOUL, ('accuracy_pct', '')), n('Joss Paper (Minh Chỉ)', TM, ('than_hon', '')),
    n('Penumbra (Bán Ảnh)', CH, ('art_speed_pct', '')), n("Monk's Calm (Thiền Định)", TM, ('linh_luc_regen_inc_pct', '')),
    n('Heart Demon Rising (Tâm Ma Khởi)', SOUL, ('than_hon', '')), n('Last Incense (Tàn Hương)', QD, ('curse_effect_pct', '')),
    n('Eclipse (Nhật Thực)', CH, ('curse_effect_pct', ''), 5, 3), n('Incense Smoke (Hương Yên)', TM, SOUL, 5, 3),
    N('Heart Demon Turned to Strength (Tâm Ma Hóa Lực)', ('attack_pct', 'chaos', 2), cap=('#25', 'T2')),
])
# The Moon's lotus: two ideas, K1 Devouring Maw (drain) and K2 Veiled Cowl (concealment).
BIG('c933 moon_lotus', pat='AB', nts=[
    n('Moon Root (Nguyệt Căn)', CULT, HIDE), n('Night Lotus (Dạ Liên)', HIDE, ESC), n('Devouring Mouth (Phệ Khẩu)', KILL, CULT),
    n('Hidden Petal (Ẩn Biện)', HIDE, EV), n('Essence Thief (Thâu Tinh)', CULT, ('than_hon', '')), n('Hood (Đấu Bồng)', ESC, ('travel_speed_pct', '')),
    n('Hunger (Cơ Ngạ)', KILL, CH), n('Silent Step (Tĩnh Bộ)', HIDE, ('travel_speed_pct', '')),
    n('Draining Palm (Hấp Chưởng)', ('attack_pct', 'palm'), ('linh_luc_on_hit_pct', 'palm')), n('Veil of Night (Dạ Sa)', ESC, EV),
    n('Moon Drinker (Ẩm Nguyệt)', CULT, ('linh_luc_regen_pct', '')), n('Held Breath (Bế Tức)', HIDE, TM),
    n('Feast (Thịnh Yến)', KILL, HP), n('Shadow Bloom (Ảnh Hoa)', HIDE, CRIT), n('Marrow Draw (Hấp Tủy)', CULT, ('can_cot', '')),
    n('Unseen (Vô Hình)', ESC, CRIT, 5, 3), n('Dream Lotus (Mộng Liên)', CULT, ('ngo_tinh', '')),
    n('False Face (Giả Diện)', HIDE, ('mi_luc', '')), n('Gnawing (Phệ Giảo)', KILL, ('linh_luc_pct', '')),
    n('Moonlight Hide (Nguyệt Ẩn)', EV, ('soul_res_pct', '')), n('Bottomless (Vô Để)', KILL, ('linh_luc_regen_pct', '')), n("Cowl's Shadow (Mạo Ảnh)", HIDE, ('soul_res_pct', '')),
    n('Lunar Lotus (Nguyệt Liên)', CULT, ('lifespan_pct', ''), 5, 3),
    N('Concealed Breath (Liễm Tức Ẩn Thân)', ('stealth', '', 2), cap=('#20', 'T2')),
    N('Great Essence-Draining Art (Hấp Tinh Đại Pháp)', ('cultivation_speed_pct', '', 2), cap=('#9', 'T2')),
])


# ================= D. Medium clusters and start figure =================
MED('base10', EV, [n('Darkness Start (Ám Khởi)', EV, CH), n('Shadow Seed (Ảnh Chủng)', EV, HIDE), n('Night Eye (Dạ Nhãn)', CRIT, CH),
                   n('Dark Root (Ám Căn)', CH, ('crit_damage_pct', ''), 5, 3)])
MED('c933 outer_swirl_595_l', HIDE, [n('Night Mist (Dạ Vụ)', HIDE, EV)])
MED('c933 outer_swirl_597_l', ('crit_damage_pct', ''), [n('Night Blade (Dạ Nhận)', ('crit_damage_pct', ''), CRIT)])
MED('c933 hollow_curl_l', SOUL, [n('Wandering Soul (Du Hồn)', SOUL, ('soul_res_pct', ''))])
MED('c933 hollow_swirl_l', ('soul_res_pct', ''), [n('Soul Ward (Hộ Hồn)', ('soul_res_pct', ''), SOUL)])
MED('c933 outer_swirl_600_l', TM, [n('Moon Veil (Nguyệt Sa)', TM, ESC)])


# ================= E. Small clusters =================
SM('c933 tip_swirl_l', CRIT, [('Night Assassin (Dạ Thích)', EV)])

KEY('c933 keystone_pendant', 'Hidden Moon (Ẩn Nguyệt)', 'Hidden Moon (Ẩn Nguyệt)',
    [('evade_pct', '', 25), ('stealth', '', 25)], closes='block and body shield count nothing; maximum health -20 %')
