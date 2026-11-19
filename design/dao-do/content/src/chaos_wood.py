# Start motif, Wood (cell 1): Chaos mixing into Wood's first cell. Exact values (hub region). Written by hand.
MOC = ('attack_pct', 'moc'); CH = ('attack_pct', 'chaos'); KV = ('khi_van', ''); HRI = ('health_regen_inc_pct', '')
BIG('c1 vines_1', [
    n('Purple Vine (Tử Đằng)', MOC, CH), n('Twisted Root (Khúc Căn)', CH, ('khi_huyet_pct', '')),
    n('Leaf Blade (Diệp Nhận)', MOC, ('crit_chance_pct', 'moc')), n('Thorned Vine (Thích Đằng)', MOC, ('block_rating', '')),
    n('Rotting Wood (Hủ Mộc)', CH, ('attack_pct', 'poison')), n('Living Sap (Thụ Dịch)', MOC, HRI), n('Creeping Chaos (Hỗn Mạn)', CH, ('status_duration_pct', '')),
    n('Green Lash (Thanh Tiên)', MOC, ('art_speed_pct', 'moc')), n('Corpse Fungus (Thi Khuẩn)', CH, ('stack_effect_pct', 'moc,debuff')),
    n('Iron Roots (Thiết Căn)', MOC, ('timer_resist_pct', '')), n('Bramble Coil (Kinh Triền)', MOC, ('resist_pen_pct', '')),
    n('Dark Sap (Hắc Dịch)', CH, ('linh_luc_on_hit_pct', 'moc')), n('Overgrowth (Mạn Sinh)', MOC, KV),
    n('Rooted Chaos (Hỗn Căn)', CH, ('can_cot', '')), n('Chaos Root (Hỗn Mộc)', MOC, ('resist_pen_pct', 'chaos'), 5, 3),
])
BIG('c1 vines_2', [
    n('Leaf Bud (Diệp Nha)', KV, HRI), n('Lucky Clover (Cát Tường Thảo)', KV, ('co_duyen_pct', '')),
    n('Green Breath (Thanh Khí)', HRI, ('linh_luc_regen_inc_pct', '')), n('Dewy Leaf (Lộ Diệp)', KV, ('herb_growth_pct', '')),
    n('Unfurling (Thư Diệp)', HRI, ('cultivation_speed_pct', '')), n('Leaf Shade (Diệp Ảnh)', KV, ('evade_pct', '')),
    n('Sunlit Leaf (Dương Diệp)', HRI, ('khi_huyet_pct', '')), n('Four Leaves (Tứ Diệp)', KV, ('mi_luc', '')),
    n('Fresh Green (Tân Lục)', HRI, ('healing_pct', '')), n('Leaf Litter (Hủ Diệp)', KV, ('khi_huyet_pct', '')),
    n('Green Vein (Diệp Mạch)', HRI, ('health_regen_pct', '')), n('Spring Wind (Xuân Phong)', KV, ('travel_speed_pct', '')),
    n('First Leaf (Sơ Diệp)', KV, ('healing_pct', ''), 5, 3),
])
