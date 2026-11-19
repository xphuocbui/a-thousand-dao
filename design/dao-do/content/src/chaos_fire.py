# Start motif, Fire (cell 3): Chaos mixing into Fire's first cell. Exact values (hub region). Written by hand.
HOA = ('attack_pct', 'hoa'); CH = ('attack_pct', 'chaos'); SPD = ('art_speed_pct', 'hoa'); LL = ('linh_luc_pct', '')
SOUL = ('than_hon', ''); HP = ('khi_huyet_pct', '')
BIG('c3 flames_1', [
    n('Purple Flame (Tử Diễm)', HOA, CH), n('Chaos Spark (Hỗn Tinh)', CH, ('crit_chance_pct', '')), n('First Fire (Sơ Hỏa)', HOA, SOUL),
    n('Mixed Flame (Tạp Diễm)', HOA, ('resist_pen_pct', 'chaos')), n('Leaping Flame (Khiêu Diễm)', HOA, SPD),
    n('Void Fire (Hư Hỏa)', CH, LL), n('Heat Haze (Dương Diễm)', HOA, ('evade_pct', '')), n('Twisting Fire (Triền Hỏa)', CH, HP),
    n('Smoke and Flame (Yên Hỏa)', ('attack_pct', 'over_time,hoa'), CH), n('Chaos Flame (Hỗn Độn Hỏa)', HOA, ('crit_damage_pct', 'hoa'), 5, 3),
])
BIG('c3 flames_3', [
    n('Kindle (Điểm Hỏa)', SPD, LL), n('Quick Flame (Tốc Hỏa)', SPD, ('accuracy_pct', '')),
    n('Spark Store (Tích Tinh)', LL, ('linh_luc_regen_pct', '')), n('Bright Spark (Diệu Tinh)', SPD, ('crit_chance_pct', 'hoa')),
    n('Spark of Origin (Nguyên Hỏa Tinh)', SPD, ('art_cost_pct', 'hoa'), 5, 3),
])
BIG('c3 flames_2', [
    n('Hearthstone (Táo Thạch)', SOUL, HP), n('Home Fire (Gia Hỏa)', HP, ('health_regen_pct', '')),
    n('Inner Warmth (Nội Ôn)', SOUL, ('tam_ma_resist_pct', '')), n('Embers Kept (Lưu Tẫn)', HP, ('resist_pct', 'fire')),
    n('Glowing Coals (Xích Thán)', SOUL, HOA), n('Family Altar (Gia Đàn)', SOUL, ('soul_res_pct', '')), n('Hearth (Táo Hỏa)', SOUL, ('health_regen_pct', ''), 5, 3),
])
