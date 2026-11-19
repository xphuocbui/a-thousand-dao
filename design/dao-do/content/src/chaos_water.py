# Start motif, Water (cell 5): Chaos mixing into Water's first cell. Exact values (hub region). Written by hand.
THUY = ('attack_pct', 'thuy'); CH = ('attack_pct', 'chaos'); NGO = ('ngo_tinh', ''); LR = ('linh_luc_regen_pct', '')
BIG('c5 waves_3', [n('Ripples (Liên Y)', ('evade_pct', ''), ('linh_luc_pct', ''))])
BIG('c5 waves_1', [
    n('Purple Tide (Tử Triều)', THUY, CH), n('Dark Current (Hắc Lưu)', CH, ('resist_pen_pct', 'chaos')), n('Leading Wave (Tiền Lãng)', THUY, NGO),
    n('Spray (Phi Mạt)', THUY, ('art_speed_pct', 'thuy')), n('Murky Waters (Trọc Thủy)', CH, LR),
    n('Crest (Lãng Đầu)', THUY, ('crit_chance_pct', 'thuy')), n('Riptide (Cuồng Lưu)', THUY, ('resist_pen_pct', 'cold')),
    n('Deep Swirl (Thâm Toàn)', CH, ('linh_luc_pct', '')), n('Tide Pull (Khiên Triều)', THUY, ('leech_linh_luc_pct', 'thuy')),
    n('Chaos Tide (Hỗn Triều)', THUY, ('resist_pen_pct', 'chaos'), 5, 3),
])
BIG('c5 waves_2', [
    n('Spring Source (Tuyền Nguyên)', NGO, LR), n('Mind-Washing Water (Tẩy Tâm Thủy)', NGO, ('tam_ma_resist_pct', '')),
    n('Cool Water (Lương Thủy)', LR, ('health_regen_pct', '')), n('Dragon Well (Long Tỉnh)', NGO, ('cultivation_speed_pct', '')),
    n('Pure Stream (Thanh Khê)', LR, ('linh_luc_pct', '')), n('Reflecting Pool (Chiếu Trì)', NGO, ('soul_res_pct', '')),
    n('Bubbling Spring (Dũng Tuyền)', LR, ('linh_luc_regen_inc_pct', '')), n('Clear Spring (Thanh Tuyền)', NGO, ('linh_luc_regen_inc_pct', ''), 5, 3),
])
