# Border lines on v5 (dao-do.md rule 4: a border cluster's Dao marks use the average of its two lands' multipliers).
# The Wind start's figure (base7, Water-Wood), the four border emblems (base16-19) and the five border combos (cells
# 911-915, each a figure split across the border road showing the generating cycle). Written by hand.
PHONG = ('attack_pct', 'phong'); EV = ('evade_pct', ''); SPD = ('art_speed_pct', ''); ESC = ('escape_pct', '')
HOA = ('attack_pct', 'hoa'); THO = ('attack_pct', 'tho'); KIM = ('attack_pct', 'kim'); THUY = ('attack_pct', 'thuy'); MOC = ('attack_pct', 'moc')
SOUL = ('than_hon', ''); DT = ('dao_tam', ''); BONE = ('can_cot', ''); NGO = ('ngo_tinh', ''); KV = ('khi_van', ''); HP = ('khi_huyet_pct', '')

# ---- start figure and emblems (medium-style) ----
MED('base7', PHONG, [n('Wind Start (Phong Khởi)', PHONG, EV), n('Light Feet (Khinh Túc)', EV, SPD), n('Drifting (Phiêu Bồng)', ('travel_speed_pct', ''), ESC),
                     n('Wind Edge (Phong Nhận)', PHONG, ('crit_chance_pct', '')), n('Open Sky Breath (Thái Hư Tức)', SPD, ('linh_luc_regen_pct', '')),
                     n('Wind Rider (Kỵ Phong)', EV, ESC), n('Wind Root (Phong Căn)', PHONG, SPD, 5, 3)])
MED('base16', MOC, [n('Wood and Fire (Mộc Hỏa)', MOC, HOA), n('Kindled Wood (Nhiên Mộc)', KV, SOUL)])
MED('base17', HOA, [n('Fire and Earth (Hỏa Thổ)', HOA, THO), n('Ash Soil (Hôi Thổ)', SOUL, DT)])
MED('base18', THO, [n('Earth and Metal (Thổ Kim)', THO, KIM), n('Ore Bed (Khoáng Sàng)', DT, BONE)])
MED('base19', KIM, [n('Metal and Water (Kim Thủy)', KIM, THUY), n('Cold Steel (Hàn Thiết)', BONE, NGO)])

# ---- border combos (small clusters; the a and b halves lean to different stats of the same pair of lands) ----
SM('c911 crater_in_a', THO, [('Crater Floor (Hỏa Khẩu Để)', HOA), ('Ash Rim (Hôi Duyên)', DT)])
SM('c911 crater_in_b', HOA, [('Lava Lake (Dung Nham Hồ)', THO), ('Smoke Rim (Yên Duyên)', SOUL)])
SM('c911 crater_out_a', ('resist_pct', 'fire'), [('Outer Crater (Ngoại Hỏa Khẩu)', HP)])
SM('c911 crater_out_b', HP, [('Crater Wall (Hỏa Khẩu Bích)', ('block_rating', ''))])
SM('c912 crystal_a', BONE, [('Crystal Seed (Tinh Chủng)', DT)])
SM('c912 crystal_b', ('artifact_power_pct', ''), [('Crystal Spire (Tinh Phong)', ('refining_success', ''))])
SM('c913 dew_a', ('linh_luc_regen_pct', ''), [('Dew on Steel (Thiết Thượng Lộ)', BONE)])
SM('c913 dew_b', NGO, [('Metal Dew (Kim Lộ)', ('linh_luc_regen_inc_pct', ''))])
SM('c913 falling_a', ('linh_luc_pct', ''), [('Falling Dew (Lạc Lộ)', NGO)])
SM('c913 falling_b', THUY, [('Cold Drop (Hàn Tích)', KIM)])
SM('c914 reed_short_a', ('health_regen_pct', ''), [('Reed Shoot (Vi Nha)', NGO)])
SM('c914 reed_short_b', KV, [('Reed Root (Vi Căn)', ('linh_luc_regen_pct', ''))])
SM('c914 reed_tall_a', EV, [('Swaying Reeds (Diêu Vi)', MOC), ('Bending Reed (Khúc Vi)', ('health_regen_inc_pct', ''))])
SM('c914 reed_tall_b', MOC, [('Reed Spear (Vi Thương)', THUY), ('Marsh Reed (Trạch Vi)', KV)])
SM('c915 flame_a', HOA, [('Torch Flame (Cự Hỏa)', KV)])
SM('c915 flame_b', MOC, [('Pine Torch (Tùng Cự)', HOA)])
SM('c915 flicker_a', SOUL, [('Torch Shadows (Cự Ảnh)', ('health_regen_pct', ''))])
SM('c915 flicker_b', KV, [('Resin Spark (Chi Hỏa)', ('art_speed_pct', 'hoa'))])
