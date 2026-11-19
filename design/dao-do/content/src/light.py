# Light island (Quang): the Sun and the Fusang tree, on v5. Written by hand under content-method.md.
# n(name, line, line, W, W) = a notable of two modifiers (default 4 + 4 W). Notables in walk order (crown last).
NGO = ('ngo_tinh', ''); TT = ('than_thuc_pct', ''); KV = ('khi_van', ''); HP = ('khi_huyet_pct', '')
HEAL = ('healing_pct', ''); CLEANSE = ('status_resist_pct', 'curse'); WARD = ('defense_pct', '')
LIGHT = ('attack_pct', 'light'); CRIT = ('crit_chance_pct', ''); CD = ('crit_damage_pct', '')
CULT = ('cultivation_speed_pct', ''); MI = ('mission_income_pct', '')

BIG('c931 tree_B_r', [
    n('Celestial Sphere (Thiên Cầu)', NGO, TT), n('Ecliptic (Hoàng Đạo)', NGO, KV),
    n('Fusang Bough (Phù Tang Chi)', TT, HP), n('Star Gauge (Tinh Quỹ)', NGO, ('accuracy_pct', '')),
    n("Heaven's Clock (Thiên Khắc)", KV, CULT), n('Sun Path (Nhật Đạo)', TT, ('soul_res_pct', ''), 5, 3),
    N("Reading Heaven's Secrets (Thiên Cơ Diễn Toán)", ('ngo_tinh', '', 2), cap=('#18', 'T2'),
      alt=[('ngo_tinh', '', 5), ('khi_van', '', 3)], alt_name='Armillary Sphere (Hồn Thiên Nghi)'),
])
BIG('c931 tree_A_r', [
    n('Hot Spring Valley (Thang Cốc)', HEAL, CLEANSE), n('Golden Light Mantra (Kim Quang Chú)', HEAL, WARD),
    n('Gentle Yang (Dương Hòa)', ('healing_taken_pct', ''), HEAL), n('Cleansing Light (Tịnh Quang)', CLEANSE, ('status_resist_pct', 'poison')),
    n('Sun Halo (Nhật Vựng)', WARD, ('soul_res_pct', '')), n('Xihe Bathes the Suns (Hi Hòa Dục Nhật)', HEAL, HP, 5, 3),
])
BIG('c931 tree_CD_r', [
    n('Brother Square Hole (Khổng Phương Huynh)', KV, MI), n('Lucky Day (Cát Nhật)', KV, ('co_duyen_pct', '')),
    n("Merchant's Luck (Thương Vận)", MI, ('mi_luc', '')), n('Fusang Fruit (Phù Tang Quả)', KV, ('lifespan_pct', '')),
    N('Child of Fortune (Khí Vận Chi Tử)', ('khi_van', '', 4), cap=('#19', 'T1'),
      alt=[('khi_van', '', 5), ('mission_income_pct', '', 3)], alt_name="Heaven's Favourite (Thiên Sủng)"),
])
BIG('c931 tree_E_r', [
    n('Morning Qi (Triêu Khí)', CULT, HP), n('Sunrise Bough (Húc Chi)', HP, ('health_regen_pct', '')),
    n('Yang Fire (Dương Hỏa)', CULT, ('than_hon', '')), n('Bathing in Light (Dục Quang)', HP, ('healing_taken_pct', '')),
    n('Rising Sun (Húc Nhật)', CULT, ('health_regen_inc_pct', ''), 5, 3),
])
BIG('c931 flames_144_r', [
    n('Corona Flare (Nhật Mang)', CD, LIGHT), n('Ten Suns (Thập Nhật)', LIGHT, ('crit_chance_pct', 'light')),
    n('Corona (Nhật Miện)', CD, ('crit_chance_pct', 'light'), 5, 3),
])
BIG('c931 flames_126_r', [
    n('Solar Flame (Nhật Viêm)', ('attack_pct', 'fire'), LIGHT), n('Sunfire (Nhật Hỏa)', LIGHT, ('resist_pen_pct', 'fire'), 5, 3),
])
BIG('c931 flames_108_r', [
    n('Dazzling Glare (Nhật Diệu)', ('accuracy_pct', ''), CRIT), n('Noon Glare (Chính Ngọ)', CRIT, CD, 5, 3),
])
BIG('c931 flames_090_r', [
    n('First Light (Sơ Quang)', LIGHT, ('crit_chance_pct', 'light')),
    N('Dawn (Bình Minh)', ('attack_pct', 'light', 4), ('resist_pen_pct', 'light', 4), effect='Daybreak (Phá Hiểu)',
      alt=[('attack_pct', 'light', 5), ('accuracy_pct', '', 3)], alt_name='Daystar (Khải Minh)'),
])
BIG('c931 flames_054_r', [
    n('Pure Yang Ward (Thuần Dương Tráo)', ('resist_pct', 'light'), WARD), n('Sun Shield (Nhật Thuẫn)', WARD, HEAL, 5, 3),
])
BIG('c931 flames_036_r', [
    n('Lingering Light (Dư Quang)', ('status_duration_pct', ''), ('linh_luc_regen_inc_pct', '')),
    n('Long Day (Trường Nhật)', ('status_duration_pct', ''), CLEANSE, 5, 3),
])
BIG('c931 flames_018_r', [
    n('Solar Breeze (Dương Phong)', ('art_speed_pct', ''), ('linh_luc_pct', '')),
    n('Solar Wind (Nhật Phong)', ('art_speed_pct', ''), ('linh_luc_regen_inc_pct', ''), 5, 3),
])


# ================= D. Medium clusters and start figure =================
MED('base8', LIGHT, [n('Morning Ray (Thần Hi)', LIGHT, HEAL), n('Sun Essence (Nhật Tinh)', LIGHT, CULT), n('Radiance (Quang Huy)', LIGHT, CRIT),
                     n('Warm Sun (Noãn Dương)', HEAL, HP), n('Clear Sight (Minh Thị)', ('accuracy_pct', ''), LIGHT),
                     n('Light Veil (Quang Mạc)', WARD, ('resist_pct', 'light')), n('Golden Glow (Kim Huy)', KV, HEAL),
                     n('Light Root (Quang Căn)', LIGHT, CD, 5, 3)])
MED('c931 flames_072_l', ('crit_chance_pct', 'light'), [n('Sun Tongue (Nhật Thiệt)', ('crit_chance_pct', 'light'), LIGHT)])
MED('c931 flames_000', ('resist_pen_pct', 'light'), [n('Zenith (Thiên Đỉnh)', ('resist_pen_pct', 'light'), ('crit_chance_pct', 'light'))])


# ================= E. Small clusters =================
SM('c931 flames_162_l', CRIT, [('Flame Point (Diễm Phong)', LIGHT)])
SM('c931 tree_D_arm_l', HEAL, [('Fusang Leaf (Phù Tang Diệp)', CULT)])

KEY('c931 keystone_gate_R', "Heaven's Eye (Thiên Nhãn)", "Heaven's Eye (Thiên Nhãn)",
    [('crit_chance_pct', '', 25), ('attack_pct', 'light', 25)], closes='ward strength -30 %')
KEY('c931 keystone_gate_L', 'Sun That Never Sets (Bất Lạc Nhật)', 'Sun That Never Sets (Bất Lạc Nhật)',
    [('cultivation_speed_pct', '', 30), ('lifespan_pct', '', 20)], closes='no stealth; Concealed Breath cannot be held; heart-demon resistance -30 %')
