# Start motif, Metal (cell 4): Chaos mixing into Metal's first cell. Exact values (hub region). Written by hand.
KIM = ('attack_pct', 'kim'); CH = ('attack_pct', 'chaos'); CRIT = ('crit_chance_pct', ''); BONE = ('can_cot', '')
BIG('c4 blades_1', [
    n('Purple Steel (Tử Cương)', KIM, CH), n('Void Edge (Hư Nhận)', CH, CRIT), n('First Cut (Sơ Trảm)', KIM, ('accuracy_pct', '')),
    n('Chaos Temper (Hỗn Luyện)', KIM, ('resist_pen_pct', 'chaos')), n('Sword Hum (Kiếm Minh)', KIM, ('soul_res_pct', '')),
    n('Shadow Blade (Ảnh Nhận)', CH, ('art_speed_pct', 'kim')), n('Blood-Drinking Blade (Ẩm Huyết Đao)', KIM, ('linh_luc_on_hit_pct', 'kim')),
    n('Chaos Blade (Hỗn Nhận)', KIM, ('crit_damage_pct', 'kim'), 5, 3),
])
BIG('c4 blades_2', [
    n('Sword Bones (Kiếm Cốt)', CRIT, BONE), n('Hard Bones (Ngạnh Cốt)', BONE, ('khi_huyet_pct', '')), n('Honed (Lệ Phong)', CRIT, ('resist_pen_pct', 'physical')),
    n('Resolute (Cương Nghị)', BONE, ('status_resist_pct', '')), n('Cold Edge (Hàn Phong)', ('crit_chance_pct', 'kim'), BONE),
    n('Steel Breath (Cương Khí)', BONE, ('linh_luc_regen_inc_pct', '')), n('Edge Revealed (Phong Mang Sơ Lộ)', CRIT, ('crit_damage_pct', ''), 5, 3),
])
BIG('c4 blades_3', [
    n('Whetstone Grit (Lệ Thạch)', ('accuracy_pct', ''), ('attack_pct', 'physical')),
    n('True Aim (Thần Chuẩn)', ('accuracy_pct', ''), ('crit_chance_pct', 'physical')),
    n('Clean Cut (Nhất Đao Lưỡng Đoạn)', ('attack_pct', 'physical'), ('resist_pen_pct', 'physical')),
    n('Whetted (Lợi Nhận)', ('attack_pct', 'physical'), ('crit_damage_pct', ''), 5, 3),
])
BIG('c4 blades_5', [n('Blade Breath (Kiếm Khí)', ('art_speed_pct', 'kim'), ('linh_luc_pct', ''))])

MED('c4 blades_4', ('crit_damage_pct', ''), [n('Severing Blade (Đoạn Nhận)', ('crit_damage_pct', ''), KIM), n('Purple Edge (Tử Phong)', ('crit_damage_pct', ''), CH)])
