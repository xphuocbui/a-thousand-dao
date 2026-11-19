# Hub: the Chaos swirl (cell 79) on v5. Exact values (no purity multiplier, dao-do.md rule 4).
# Written by hand under content-method.md. Each arm: one notable, then the crown.

BIG('c79 swirl_arm_03', [
    n('Two Forms (Lưỡng Nghi)', ('cultivation_speed_pct', ''), ('ngo_tinh', '')),
    N('Twin Technique Cultivation (Song Tu Công Pháp)', ('cultivation_speed_pct', '', 2), cap=('#6', 'T2')),
])
BIG('c79 swirl_arm_08', [
    n('Newborn Heart (Xích Tử Tâm)', ('dao_tam', ''), ('than_hon', '')),
    n('Undivided Mind (Hỗn Nguyên Tâm)', ('dao_tam', ''), ('tam_ma_resist_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_02', [
    n('Primal Edge (Nguyên Phong)', ('attack_pct', 'chaos'), ('resist_pen_pct', 'chaos')),
    n('Chaos Edge (Hỗn Độn Phong)', ('attack_pct', 'chaos'), ('crit_chance_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_07', [
    n('Five Phases (Ngũ Hành)', ('element_affinity_pct', ''), ('art_speed_pct', '')),
    n('Five Phases Cycle (Ngũ Hành Luân Chuyển)', ('element_affinity_pct', ''), ('attack_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_05', [
    n('Yang Within Yin (Âm Trung Dương)', ('khi_huyet_pct', ''), ('linh_luc_pct', '')),
    n('Yin and Yang (Âm Dương)', ('linh_luc_regen_pct', ''), ('khi_huyet_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_10', [
    n('Origin Breath (Nguyên Tức)', ('health_regen_inc_pct', ''), ('linh_luc_regen_pct', '')),
    n('Return to Origin (Quy Nguyên)', ('health_regen_inc_pct', ''), ('healing_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_01', [
    n('Before Form (Tiên Hình)', ('attack_pct', ''), ('khi_huyet_pct', '')),
    n('Before Heaven (Tiên Thiên Bát Quái)', ('attack_pct', ''), ('resist_pct', ''), effect='Before Heaven (Tiên Thiên)'),
])
BIG('c79 swirl_arm_06', [
    n('Gift of Chaos (Hỗn Độn Thiên Phú)', ('khi_van', ''), ('can_cot', '')),
    N('Mutation Awakening (Biến Dị Khai Mở)', ('khi_van', '', 2), cap=('#24', 'T2')),
])
BIG('c79 swirl_arm_04', [
    n('Qi Source (Khí Nguyên)', ('linh_luc_pct', ''), ('linh_luc_regen_inc_pct', '')),
    n('Primordial Breath (Nguyên Khí)', ('linh_luc_pct', ''), ('reserve_eff_pct', ''), 5, 3),
])
BIG('c79 swirl_arm_09', [
    n('Hollow Footing (Hư Túc)', ('evade_pct', ''), ('accuracy_pct', '')),
    n('Void Step (Hư Bộ)', ('evade_pct', ''), ('escape_pct', ''), 5, 3),
])

# ================= D. The Chaos start's own figure =================
MED('base0', ('attack_pct', ''), [n('Chaos Seed (Hỗn Độn Chủng)', ('attack_pct', ''), ('resist_pct', '')),
                                  n('Primal Body (Nguyên Thân)', ('khi_huyet_pct', ''), ('linh_luc_pct', '')),
                                  n('Five Talents (Ngũ Tài)', ('dao_tam', ''), ('than_hon', '')),
                                  n('The Limitless (Vô Cực)', ('element_affinity_pct', ''), ('attack_pct', '')),
                                  n('Chaos Start (Hỗn Độn Khởi)', ('attack_pct', ''), ('khi_huyet_pct', ''))])
