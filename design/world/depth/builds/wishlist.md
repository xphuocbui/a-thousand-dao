# Build wishlist: merged (2026-11-25)

Environment conditions (ground, terrain, biome, weather, place) removed by user ruling 2026-11-25; time and season
conditions likewise (2026-11-25).

**Not on the tree (user ruling 2026-11-25).** No wish adds Đạo Đồ nodes: the tree stays as it is. Every wish that was
homed on the tree now lives on an item, a set bonus or a technique (a lineage passive or an art) its requesters carry.
Tree nodes named under "Why" describe the tree as it stands.

> One list to author from: everything the world-depth build, set and review writers wanted so that a build works or is
> fun. Merged from the ten source files (full text: see the end). Proposals for your review. Nothing here is added to
> the tree, `effects.md`, the Modifier System, the items or the teaching list.

## At a glance

101 source entries merge into **88 entries** (ra-G2 and rb-30 removed), plus **d49** added from the 2026-11-25 rulings
(appended at the end of (d), out of n order): **89 entries**.

| Group | What it takes to author | Entries |
|---|---|---|
| (a) | Systemic rules that unlock many builds | 4 |
| (b) | Modifiers on existing stats (new scope, or placed on an item or technique) | 14 |
| (c) | New stat keys | 2 |
| (d) | Effects (and wards) | 48 |
| (e) | Techniques and arts | 10 |
| (f) | Items, item bases and sets | 6 |
| (g) | Other (quests, world state, tooling, teaching list) | 5 |

By kind (the first-named kind of a mixed entry): Effect 46, Modifier 16, Other 9, Art 9, Item 6, Technique 2, Ward 1.

Within each group, entries are ordered by how many builds they unlock (**n** = distinct person keys after the merge).
Key prefixes: `W1`-`W10` = targets-tx; `bt-` = targets-bt; `tl/` = targets-tl; `tp/` = targets-tp; `sets-bt-`,
`sets-tl/`, `sets-tp/`, `S1`-`S8` (sets-tx) = the set writers; `ra-` = review-a; `rb-` = review-b.

### The strongest ideas

1. **a1 Duel readings** (`ra-G1 + rb-01 + sets-bt-01 + sets-bt-04`): one fixed reading for "allies", "moves", "still",
   "knock back", "on a kill". It revives clauses in 54 builds.
2. **a3 Forewarned** (`rb-02`): one "I heard it coming" state, and each lineage answers it its own way.
3. **b2 Song scope** (`W8 + tp/grave-chorus + sets-tp/song-tag`): song damage on the music lineages' own passives
   and instruments.
4. **e1 Bronze Answers** (`rb-07`): a Metal peal for the ten Thính Vũ elders who have no Thunder.
5. **d1 Five Marks from Five Arts** (`rb-10`): the five plumage colours come from five kinds of art, one per palace hall.
6. **g1 Partial manuals** (`ra-G4`): a stalled canon has a place on the map where its missing layers are.
7. **d4 A File of One** (`ra-NT1`): delayed damage that heals can catch, which gives the geese file a solo meaning.
8. **d5 The Empty Mountain's Answer** (`ra-TV1`): wasted overflow healing falls on a rooted foe as Wood damage.
9. **d7 Voices from the Ground** (`rb-21`): the grave chorus grows as the foe bleeds and as companions fall.
10. **d18 Frost Answers the Blow** (`ra-BT1`): the still Keeper ripens Ice on whoever strikes her ward.
11. **g5 The Culm Stores for Years** (`rb-23`): a bloom stored across seasons, and a flowering the region remembers.

## Flags: rulings needed

- **rb-30 Thrown Coin: ruled no (2026-11-25), dropped (was d26).** Stones burn only as formation, crafting and abode
  fuel.
- **Luyện Khí sets (f4: `sets-tl/one-slot-pair + S8`): ruled (2026-11-25).** Keep 2-piece sets; the person wears one
  piece, and the set bonus switches on when they reach Trúc Cơ and gain a slot (a growth goal).
- **rb-04 touches `assets/data/sects_teaching.json`**, which the Formations session owns. Noted only; nobody here acts on it.
- **Caps against the no-caps default.** These entries state a cap: `ra-TV1` (30 %), `sets-tl/heal-store` (30 %),
  `ra-LH1` (40 %), `ra-LH2` (5 Debts), `ra-DQ1` (5), `ra-MV1` (10), `ra-BT1` (consumes 10), `ra-VH1` (6 s), `ra-ST1`
  (3 wards), `sets-tp/drunk` (3 stacks), `S2` (5 heat), `tl/geese-line` (by allies). Lift them, or keep them as the
  piece's bound.
- **New tree nodes: ruled not on the tree (2026-11-25).** The Đạo Đồ stays as it is. Every (b) placement wish and every
  tree home in (c) and (d) is re-homed below onto an item, a set bonus or a technique.
- **Two cultivators on one side.** `sets-tl/two-halves` (f2) needs two allies wearing halves in one fight; Combat does
  not support a side with more than one cultivator (Open Question 27).
- **Blocked or waiting.** `tl/geese-line` (d17) needs a1's ally reading.
  `ra-G4`, `sets-tl/lost-pieces`, `ra-TD2` wait on quests; `sets-tp/tan-hong-pair` waits on Tàn Hồng being placed.
- **Source facts that disagree.** W10 asks for a new `leech_khi_huyet_pct`, but `leech_health_pct` already exists (items,
  combat engine). `sets-tl/companion-thread` asks for a new `companion_khi_huyet_pct`, but `companion_health_pct`
  exists. W8 says a `song` tag exists, and sets-tp says it is new: some arts carry it, so tag the rest. The `seal`,
  `bow` and `palm` tags are to confirm.

---

## (a) Systemic rules that unlock many builds

**a1. Duel readings (Đấu Giải), with Moving (Hành), Stillness (Tĩnh), Displacement and Unmoved (Bất Động)** · Other (reading
rules) · `ra-G1 + rb-01 + sets-bt-01 + sets-bt-04` · **n 54**
- AUTHORED: see duel-readings.md (section 3 wired; see authored/WIRED.md)
- Rule: one fixed reading per word, written once. **Ally** = you and your companions (you in full, each companion at
  half; you count as one). **A foe who moves, dodges or crosses** = it fires an art or attack, or evades. **Still** = no
  art cast for 2 s, or a sitting or standing stance held; it ends on an attack art or a push (rb-01 words it "no evade,
  no movement art for 2 s": pick one). **Moving** = a step, dash or footwork art or stance is up, and 1 s after each
  evade. **Knock back, drag, sweep** = the foe's next art is delayed 0.3 s (0.5 s heavy), and a knock-back taken ends
  the taker's Still for 2 s (the step out, so The Pivot Does Not Turn and Fixed Pole can be billed). **Rooted N s** = evade 0 and
  next art delayed N/2 s. **Every foe in reach** = the foe and its companions; with none, half again on the same foe.
  **On a kill** = the foe's first drop to 25 %. **Casts nothing** = a held stance needs a written release condition.
  sets-bt-04's real push, pull and Unmoved is the alternative to the delay reading; without it, "cannot be moved"
  clauses become block or damage-taken lines.
- Lives: depth `schema.md`, Effects rule 5, the combat rules for Still and Displacement.
- Who: muc_han_nhan, muc_tan_vu, dong_kien_luy, luong_thu_hang, ngo_bat_tan (nhan_tran); canh_truong_thien,
  thinh_kinh_han, lo_xuong_van, nhiep_ngoc_am, hach_anh_ha (lac_ha); ngu_lam_son, thieu_thanh_dai, khong_duong_quy,
  du_tuc_doan, cu_thuy_bach (thuy_vi); bang_yen_toa, ham_thanh_dang, luyen_to_y (vu_an); van_han_dang, khong_da_hanh
  (suong_tung); khau_muc_van, tan_thien_ly, du_bon_van (muc_van); yen_boi_ngoc, tham_huong_nhi (minh_loan);
  hua_van_cung (tuan_tung); hang_da_boi, do_xich_linh (da_quang); tong_toa_van (van_khoi); so_ngoc_ho, co_lang_suong,
  tiet_han_mai, lieu_ngu_ca (bang_tam); luc_thanh_sam, dang_bich_luu (ho_lam); ha_thinh_tung (van_hac); lu_doc_dieu,
  bo_toa_tuyet (lanh_giang); tieu_thua_am, on_trong_luong (clans); manh_tinh_chi (le_hoa); uc_diep_thanh, phi_thoa_y,
  ky_khinh_ma, nghiem_quy_khu (xuyen_lam); thang_vo_ta, lam_khe_ngon (phat_y); doan_ngoc_hanh, do_tinh_ha,
  phuong_truc_ngon (thien_xu); tham_bac_than, to_tinh_nghi (cung_tinh); ung_hac_minh (cuu_cao); than_van_cam (chuc_ha).
- Why: a fight is one cultivator plus companions, no positions, no allies. Clauses built on these words never fire
  (Geese Stance, The Long Ride, Lock the Road, the Night-Glow Cup, every ally field), and seven sets each define
  "waiting" their own way. Note: Ngạo Tuyết's Lone Branch ("no ally near") becomes always on; price it so.
- Fun: arts keep their voice and still act on the timeline; the stance duel (the planted Pivot against the circling staff).

**a3. Forewarned (Tiên Giác)** · Other (shared state) plus one Effect per lineage · `rb-02` · **n 10**
- Rule: Forewarned = you know the foe's next art (its timer). Thính Vũ cuts it (counter-hit), Vũ Linh goes first, Củng
  Tinh and Vọng Triều ward it, the Hall of Echoes evades.
- Lives: the combat rules; each technique's answer as written.
- Who: manh_da_vu, ung_thinh_thien, nhiep_vo_thanh, lu_tan_ha (thinh_vu); an_thanh_linh, thieu_van_linh (vu_linh);
  tham_bac_than (cung_tinh); on_thu_dang, kien_muc_hai (vong_trieu); doan_thuong_hai (hermits-sages).
- Why: six methods and four items say "sees the next art coming" six ways; neighbours would play alike.
- Fun: one moment, four answers.

**a4. Protect a charge (Bảo Tiêu), and the client can be struck (Khách Khả Kích)** · Other (fight state and request
flag) · `S7 + rb-14` · **n 9**
- Rule: a fight may mark one ally as your charge, made a protected companion with its own health that the foe's arts
  target. Effects read "while you protect your charge" and "if your charge leaves alive"; if it falls, the contract
  fails even when the fight is won.
- Lives: the Event Engine fight request (beside `no_heal`) and Combat's companion rules.
- Who: lam_khe_ngon, khuc_liet_duong, au_duong_kien, thang_vo_ta (phat_y); kim_tich_phuc (market-folk);
  ho_dien_liet, thu_phieu_binh (loose-north); loc_bat_quy, yen_hoi_do (loose-south).
- Why: the Contract Seal and Paid in Full name a hirer, and Noon Guard turns blows aimed at an ally; nothing is aimed.
- Fun: the best build keeps the merchant standing.

**a5. Banked charges (Tích)** · Effect (shared rule) · `sets-bt-02` · **n 3**
- Rule: an Effect banks a charge on a timer or trigger, up to a bound, and spends all at once for a payoff that scales
  with the count.
- Lives: the combat rules; first users are Sit as Thôi Sat, Outlast the Drought, Pillar in the Flood.
- Who: tong_toa_van (van_khoi); luc_thuong_lam, on_trong_luong (clans).
- Why: the Sitting Cloud Canon banks Clouds for itself only; stack lines do not cover stored payoffs. One rule would also
  carry d5, d10, d11, d12, d19, d41, d43 and e5 (each a store spent at once).
- Fun: a visible counter that fills while you hold out and empties in one burst.

## (b) Modifiers on existing stats (new scope, or placed on an item or technique)

**b1. Lineage routes on the border (Môn Lộ Biên Giới)** · Modifier (the route notables' values, on a lineage passive) · `ra-G3` · **n 13**
- AUTHORED: see authored/auth-mod.json (the shared-method half waits on a ruling; see authored/WIRED.md)
- Rule: a two-land lineage's methods carry the values of its 2-3 route notables as a lineage passive, so a disciple
  on the far start has them without the detour (model: Pine Strength's values). Values to copy: Lạc Hà (Solid Ground,
  Gate of Faith, Blessed Basin), Thúy Vi (Growth Rings, New Leaf, Paddy Fields for the Earth half), Vạn Hác (Clear
  Gong), Tuần Tùng's warden route, Nhạn Trận's file route.
- Lives: the methods they hold: Drifting Sunset Cloud True Canon, Mountain Heart Canon and Evening Dust Primer (Lạc
  Hà); Emerald Haze True Canon, Verdant Cycle Scripture and Seed and Soil Primer (Thúy Vi); Ten Thousand Ravines Zither
  Canon (Vạn Hác); Pine Warden's Staff and Bow Canon (Tuần Tùng); Wild Geese Formation Canon (Nhạn Trận).
- Who: me_dien_nhi, pham_thu_dien, quyen_thanh_lam (thuy_vi); sai_thanh_phong, nhiep_ngoc_am, chu_hong_diep,
  giang_vong_pham, ta_quy_yen (lac_ha); ha_thinh_tung, khuong_lac_huyen (van_hac); trang_thiet_cuoc (tuan_tung);
  dong_kien_luy, muc_tan_vu (nhan_tran).
- Why: a Luyện Khí on the far start cannot reach the route; for others it is a 40-point detour.

**b2. Song scope: Between the Notes (Âm Gian), Grave Chorus (Quỷ Xướng Hợp Thanh), Song tag (Ca)** · Modifier
(`attack_pct`, `x_soul`, `art_speed_pct` scoped `[song]`) · `W8 + tp/grave-chorus + sets-tp/song-tag` · **n 10**
- AUTHORED: see authored/auth-mod.json
- Rule: +6 % `attack_pct [song]` with soul resistance; `x_soul 5 [song], soul_res_pct 6.6`; tag every zither, pipe, drum, bell and soul-song art `song` (some already are; the `cam` base note asks
  for a music tag).
- Lives: passives on the methods they hold: Canon of the Autumn Graves (Thu Phần), Shao Remnant Score (Phượng Minh),
  Hollow Bell Canon (Chúc Dư Âm, Hám Tán Chung); for Gián Thu Địch, Bạch Vọng Ngôn and Chúc Hiểu Nghi, the instruments
  they carry (the `cam` base; the Bell of the Autumn Graves `tp-autumn-grave-bell` for the Pavilion).
- Who: gian_thu_dich (hermits-sages); bach_vong_ngon (thien_xu); chuc_du_am (loose-south); bao_thu_xuong,
  tham_tho_bich, co_ky_am, ly_han_bich (thu_phan); lien_thieu_nghi, chuc_hieu_nghi (phuong_minh); ham_tan_chung (demonic).
- Why: `x_soul` lives only in Fire, Thunder and Darkness; nothing a music build carries gives soul damage.
- Fun: a funeral drum and a zither in one set that make each other faster.

**b3. Metal debuff stacks: Quench Mark (Thối Ấn), Ringing Bronze (Minh Đồng)** · Modifier (`stack_effect_pct`,
`stack_duration_pct [kim/debuff]`) · `W2 + tl/metal-stacks` · **n 8**
- AUTHORED: see authored/auth-mod.json
- Rule: Binding Vine's values (+16-20 % effect, +20-25 % duration of Metal debuff stacks) as a lineage passive or on
  an item.
- Lives: lineage passives on the Star-Quench Canon (Thời Tinh), the True Gold Canon (Chân Kim), the Singing Luan
  Bell Canon (Minh Loan) and the Canopy Furnace Canon (Hỏa Cái); Hỏa Cái's furnaces (`hc-canopy-furnace`,
  `hc-fume-censer`).
- Who: bang_lanh_toi (thoi_tinh); la_tu_vi, uy_dan_duong, thieu_ngan_hong (hoa_cai); phung_xich_kim (chan_kim);
  yen_boi_ngoc, nguy_tram_am, tham_huong_nhi (minh_loan).
- Why: Wood, Fire, Water, Ice and Thunder have debuff-stack lines; Metal has none. See also d30 (rb-13), d43 (S2).

**b4. Painted Leaf (Họa Diệp)** · Modifier (`attack_pct`, `art_speed_pct [talisman]`, new placement) · `tl/wood-talisman` · **n 5**
- AUTHORED: see authored/auth-mod.json
- Rule: Brush and Inkstone's values (6 % talisman damage, 10 % talisman speed), with `status_duration_pct`.
- Lives: a lineage passive on the Southern Shore Cloud Canon and the Mulberry Ink Primer (Nam Phố); the brushes
  `np-dawn-cloud-brush` and `st-lantern-maker-brush`, and f1's brush base (Tạ Quy Yến's carrier).
- Who: chau_phi_van, ninh_hoa_van, ly_khe_thu (nam_pho); ta_quy_yen (lac_ha); van_han_dang (suong_tung).
- Why: every talisman notable is in Water, 40+ from the Wood start.

**b5. Miasma Lungs (Chướng Phế)** · Modifier (`status_resist_pct [poison]`, new placement) · `W5` · **n 4**
- AUTHORED: see authored/auth-mod.json
- Rule: +20 % poison resistance with health. Lives: items they carry: `ls-miasma-veil-robe` (Khâu Bạch Thủ),
  `hc-cinnabar-robe` (Uy Đan Dương), a new miasma-root charm for Quý Thủ Lũy, who grows the root; a passive on the True
  Gold Canon for Phùng Xích Kim.
- Who: quy_thu_luy (thien_xu), uy_dan_duong (hoa_cai), phung_xich_kim (chan_kim), khau_bach_thu (loose-south).
- Why: the only poison resistance is Pine Strength, 44 from Earth.

**b6. Rain-Chain Conductor (Vũ Liên Dẫn Lôi)** · Modifier (`attack_pct [kim]` + `[loi]`; `resist_pct [lightning]`)
· `tp/rain-chain-conductor` · **n 4**
- AUTHORED: see authored/auth-mod.json
- Rule: the pair's values (`attack_pct 6[kim], 6[loi]` / `resist_pct 150[lightning], can_cot 1.33`) as a lineage
  passive; optionally a Fire-Thunder twin.
- Lives: a lineage passive on the Rain-Chain Sword Scripture and the Canon of the Thunder Heard in the Rain (Thính Vũ); the Night Rain Regalia's set bonus
  (`tvl-night-rain-regalia`); for Chu Trì Âm (Phượng Minh), an item.
- Who: thach_lien_hoan, dam_van_chung, ninh_tich_dang (thinh_vu); chu_tri_am (phuong_minh).
- Why: the Tower's canon is Metal first, then Thunder, but the nearest Thunder notable is 46-48 from the Metal start.
  Pairs with e1 (rb-07) for the Thunderless.

**b7. Weighed Foe (Quyền Trọng)** · Modifier (`stack_effect_pct [tho/debuff]`) · `W1` · **n 3**
- AUTHORED: see authored/auth-mod.json
- Rule: +16 % effect of Earth debuff stacks (Weights). Lives: lineage passives on the Heavenly Pivot True Canon
  (Thiên Xu) and the Bowing Stars Canon (Củng Tinh); the Pivot, abbey and Quản set pieces (`tx-heavenly-weight`,
  `ct-armillary-ring`, `mf-golden-valley-seal`).
- Who: phuong_truc_ngon (thien_xu), to_tinh_nghi (cung_tinh), quan_phuc_thu (market-folk); the whole Pivot and Củng
  Tinh lineage, and the Pivot, abbey and Quản sets lean on it.
- Why: nothing touches Earth stacks.

**b8. Seal Script (Ấn Văn)** · Modifier (`attack_pct`, `art_speed_pct [seal]`) · `W4` · **n 3**
- AUTHORED: see authored/auth-mod.json
- Rule: +6 % damage, +10 % speed of seal arts; needs a `seal` tag on seal arts (tag to confirm).
- Lives: a passive on the Nine Seal Ledger; the seals they carry (`tx-heavenly-weight`, `tx-compact-inkstone`; the `an`
  base) and the archive, copyist and digger set pieces. Who: phuong_truc_ngon, su_ngung_mac, trong_khac_ky (thien_xu).
- Why: nothing scales a seal; the archive, copyist and digger set pieces also want it.

**b9. Hundred Echoes (Bách Hưởng)** · Modifier (`attack_pct`, `art_speed_pct [palm]`, new placement) · `bt-08` · **n 2**
- AUTHORED: see authored/auth-mod.json (b9 not wired: its tags and catalogue lines sit outside the depth files; see authored/WIRED.md)
- Lives: a passive on the Hundred Echo Palm Scripture, which both hold; f1's fist-wrap base; `ta-goose-bone-beads`
  (Phi Nhẫn Tâm). Who: phi_nhan_tam (trac_anh), nong_bach_thach (van_khoi).
- Why: the only palm node, Draining Palm (7583), is in Darkness.

**b10. Pine Warden's Draw (Tùng Vệ Mãn Cung)** · Modifier (`attack_pct 7.5 [bow]`, `crit_damage_pct 15 [bow]`) · `ra-TT1` · **n 2**
- AUTHORED: see authored/auth-mod.json
- Lives: `ttg-wolf-winter-bow` and f1's bow base; a lineage passive on the Pine Warden's Staff and Bow Canon. Who: hua_van_cung, diem_lac_nhan (tuan_tung).
- Why: Drawn Bow scopes to `[kim]`; no node scopes `[bow]` (tag to confirm). Pairs with f1's bow base.

**b11. Opened Veins (Khai Mạch)** · Modifier (new scope `[bleed]` on stack effect / duration) · `bt-06` · **n 1**
- AUTHORED: see authored/auth-mod.json
- Lives: a lineage passive on the Night-Glow Blood Sabre Canon, or a sabre item. Who: hang_luu_hoa (da_quang).
- Why: stack lines exist for element debuffs only; the sabre's bleed has none.

**b12. Hunter's Snare (Liệp Sách)** · Modifier (`curse_effect_pct` +10 % with accuracy) · `W7` · **n 1**
- AUTHORED: see authored/auth-mod.json
- Lives: an item (a snare, or a bow on f1's bow base). Who: sam_van_nuong (loose-south). Why: curses live in Water, Wood, Darkness.

**b13. Stone Wardens (Thạch Vệ)** · Modifier (`companion_power_pct`, `companion_health_pct`, optionally construct-scoped)
· `W9` · **n 1**
- AUTHORED: see authored/auth-mod.json (not wired: the companion keys are not yet in the item catalogue; see authored/WIRED.md)
- Lives: `tx-dao-quang-war-flag` or `tx-seventh-star-drum`, or a passive on the Boundary Stele Array Canon. Who: ngu_tran_bac (thien_xu). Why: companion pieces are paper puppets and beasts.

**b14. Blood Drinker (Ẩm Huyết)** · Modifier (health leech, 2-3 %) · `W10` · **n 1**
- AUTHORED: see authored/auth-mod.json (already covered by the Lynx-Bone Axe)
- Rule: use the existing `leech_health_pct` (W10 asked for a new key). Lives: `ln-lynx-bone-axe`; items already
  carry the key. Who: khau_thien_tu (loose-north). Why: the tree has only linh lực leech, and his gear none.

## (c) New stat keys

**c1. Lingering Green (Lưu Thúy)** · Modifier, new `buff_duration_pct` · `bt-01` · **n 2**
- Rule: buffs you grant to yourself and allies last X % longer. Lives: `tv-weeping-willow-robe` and a passive on the
  Emerald Haze True Canon or the Rock-Splitting Root.
- Who: thieu_thanh_dai, au_duong_tan_di (thuy_vi). Why: nothing lengthens a buff you grant.

**c2. Blinding Mist (Mê Vụ)** · Modifier, new `accuracy_loss_effect_pct` · `bt-03` · **n 1**
- Rule: accuracy loss you inflict is X % stronger. Lives: `va-mist-lock-lantern` and a passive on the Mist-Lock
  Array Canon; for Thúy Vi, the Haze Walk.
- Who: ham_thanh_dang (vu_an); also Thúy Vi's Haze on the Path users. Why: the only accuracy stat is your own.

## (d) Effects (and wards)

**d1. Five Marks from Five Arts (Ngũ Văn Ngũ Pháp)** · Effect (rule change) · `rb-10` · **n 10**
- AUTHORED: see authored/auth-eff-1.json
- Rule: Five-Colour Plumage colours come from five kinds of art: Fire main art, fan art, song art, heal or Wood art, ward.
  A held colour does not count again. Fire-only builds fill it by repeats (one per 2 Fire arts) at half the song.
- Lives: Five-Virtue Phoenix Canon. Who: hoa_trieu_duong, trinh_hi_quang, nhiep_tan_sa, vu_ngo_dong, tang_ke_ti,
  lien_thieu_nghi, dien_phong_nien, lo_van_khanh, su_hoanh_duc, thich_hong_linh (phuong_minh).
- Why: as written it is a count to five. Fun: a five-part chord; the five halls meet in one fighter.

**d2. Lost on the Road (Mê Lộ), and Know the Way Out (Thức Lộ)** · Effect plus an Event Engine question · `ra-VA1 + rb-32` · **n 10**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each foe art that misses you in your mist gives it a Lost stack; at 5, your escape fires at `cooldown_min` and
  cannot fail. Each failed escape adds to the next chance, no cap. Open: for guard or escort requests, a flight could
  count as success (today it takes the failure branch, AC-CB-62).
- Lives: Mist-Lock Array Canon or `va-mist-lock-lantern`; for the other escapers, an item each carries.
- Who: bang_yen_toa, ham_thanh_dang, luyen_to_y (vu_an); khau_bach_thu, bien_am_pham (loose-south); mau_tri_vien,
  phong_bach_ke (thien_xu); hua_thanh_diem (thinh_vu); hoang_phu_duyen (market-folk); nham_do_han (loose-north).
- Why: these builds fight only to leave, and escape is one flat roll. Fun: kill him fast or watch him go.

**d3. Red Sky at Evening (Hà Hồng)** · Effect and tuning · `ra-LH1` · **n 9**
- AUTHORED: see authored/auth-eff-1.json
- Rule: The Glow Deepens counts 1 extra s per 2 % health lost and caps at 60 s (+4 % per 6 s); Last Light may fire
  before 10 s at 10 Earth stacks. Three Nights on the Road takes the same clock.
- Who: to_van_chieu, tram_tich_duong, canh_truong_thien, hach_anh_ha, hinh_trong_son, quach_tiep_van, tong_thu_tin
  (lac_ha); hua_van_cung, trang_thiet_cuoc (tuan_tung).
- Why: fights run 30-60 s and the Glow needs 100 s. Fun: a rush brings Lạc Hà's dusk sooner.

**d4. A File of One (Nhất Nhân Thành Hàng)** · Effect · `ra-NT1` · **n 7**
- AUTHORED: see authored/auth-eff-1.json
- Rule: in Geese Stance with no ally, 40 % of each hit lands over the next 4 s, and healing pays it first. One Breath
  Down the File, alone, halves debuff stacks laid on you and doubles their duration.
- Lives: Geese Stance, One Breath Down the File. Who: muc_han_nhan, muc_tan_vu, dong_kien_luy, luong_thu_hang,
  ngo_bat_tan (nhan_tran); canh_truong_thien, thinh_kinh_han (lac_ha).
- Why: a new reason beside d17; no Effect delays damage taken. Fun: burst becomes a slope your heals can catch.

**d5. The Empty Mountain's Answer (Không Sơn Đáp)** · Effect · `ra-TV1` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: overflow healing is stored as Green (to 30 % max health); on a rooted foe or one with 5 Wood stacks it falls as
  Wood damage, once per 3 s.
- Lives: Empty Mountain Sutra, or `tv-green-moss-mirror`. Who: ngu_lam_son, thieu_thanh_dai, khong_duong_quy,
  du_tuc_doan (thuy_vi); nghiem_linh_chi (thai_chi); diem_tu_to (yen_quang).
- Why: the head's sutra has no killing art. Beside d41 (which spends stored heals on allies). Fun: the harder the foe
  hits, the more spills back.

**d6. Answering Wave (Ứng Đào)** · Effect · `ra-TD1` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each art heal lays 1 Wood stack on the foe per 1 % max health restored (max 4 a pulse) and gives you 1 Water stack.
- Lives: Pine Wave True Canon (layer 4), or the Pine Regalia's set bonus (`td-pine-regalia`). Who: dam_tung_lai, du_tinh_luu, ho_tung_nguyet,
  thoi_khinh_hong, vi_thanh_am, tu_tich_coc (tung_dao).
- Why: the existing versions last 8 s, need the regalia, or break if moved. Fun: the foe must burst him before the roots close.

**d7. Voices from the Ground (Địa Thanh)** · Effect (rule change) · `rb-21` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: the chorus gains a voice per 20 % of foe health lost and per companion or summon fallen on either side. Lift
  the 8-voice cap. (The ground voices and their autumn doubling are gone with the 2026-11-25
  rulings.)
- Lives: Canon of the Autumn Graves; the Bell's Toll for the Dead.
- Who: ly_han_bich, bao_thu_xuong, co_ky_am, tham_tho_bich, on_tich_nhai (thu_phan); ham_tan_chung (demonic).
- Why: voices come only from deaths, and a duel has one. Fun: the chorus swells as the foe bleeds, even in a duel.

**d8. The Pole Draws from the Vein (Xu Cực Dẫn Mạch)** · Effect · `rb-05` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: while Still, each pulse regenerates linh lực per 3 Weights on the foe, no cap; stepping out cuts it.
- Lives: Heavenly Pivot True Canon (middle layers). Who: doan_ngoc_hanh, phuong_truc_ngon, su_ngung_mac,
  thien_thua_cu, dang_quan_binh, trong_khac_ky (thien_xu).
- Why: a costly stand-still method with no sustain of its own. Fun: a Pivot that gets cheaper the longer it holds.

**d9. When the Handle Loses Count (Thất Số)** · Effect (definition) · `rb-06` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: the Dipper Handle loses count on a non-Metal art, or two arts within 1 s, before the seventh star; it restarts
  from the first star after 3 s Still (not "for the rest of the fight").
- Lives: Dipper Handle Canon. Who: nhiem_thua_nghiep, hoang_phu_tich, cuu_bat_ngu, mac_kinh_trap, doan_hi_hoa
  (thien_xu); loc_bat_quy (loose-south).
- Why: "rushing" is undefined and the penalty is harsh enough that generators avoid the canon. Fun: the rushing
  disciple plays worse than his master, and learns.

**d10. Not a Drop Spilled (Bất Lậu Nhất Trích)** · Effect · `rb-09` · **n 6**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each second with no art fills a bronze cup (faster linh lực regeneration per cup, no cap); the next art spends
  them for more damage.
- Lives: Rain-Chain Sword Scripture. Who: ton_tuyet_bich, dam_van_chung, diep_an_thu, boc_thu_chung, tao_mac_toan,
  co_da_lan (thinh_vu).
- Why: below the head the lineage has no linh lực source. Fun: three seconds of nothing, one cut that paid for itself.

**d11. Debt Stone (Trái Thạch)** · Effect · `tl/debt-stone` · **n 6**
- AUTHORED: see authored/auth-eff-1.json (not wired: it lives on a catalogue technique; see authored/WIRED.md)
- Rule: damage you take is written as debt; at 20 % max health, your next hit adds a share (say 25 %) and clears it.
- Lives: a passive on the Ruin Ledger Scripture or the Mountain Heart Canon, or the set bonuses of Nails of Đào Sa and
  Debt and Wall. Who: lu_tan_chu, tang_van_tieu, phuong_toan_ngoc,
  tong_thu_tin, tu_binh_hanh, tram_tich_duong (lac_ha).
- Why: Earth has no reprisal piece; sets Nails of Đào Sa and Debt and Wall write it by hand. See d12.

**d12. Written in the Ledger (Ký Trướng)** · Effect · `ra-LH2` · **n 5**
- AUTHORED: see authored/auth-eff-1.json (not wired: it lives on a catalogue technique; see authored/WIRED.md)
- Rule: each hit taking 4 %+ of max health writes a Debt on the attacker (to 5); each counts as one more status for the
  Ruin Ledger's arts, and Gathered Ruin Verdict spends them (+15 % each).
- Lives: Ruin Ledger Scripture (layer 3). Who: tram_tich_duong, tong_thu_tin, tu_binh_hanh, tang_van_tieu,
  phuong_toan_ngoc (lac_ha).
- Why: a new reason beside d11: the scripture they hold reads their defence, not the tree. Fun: the clerk takes the
  blows; the Verdict reads them out.

**d13. The Cliff Splits (Nhai Liệt)** · Effect · `ra-TV2` · **n 5**
- AUTHORED: see authored/auth-eff-1.json
- Rule: at 6 Wood stacks from Root in the Crack the foe is Sundered 4 s; holding Pine Against the Wind, the stance
  releases as one Physical Wood hit.
- Lives: Rock-Splitting Root (layer 3). Who: cu_thuy_bach, hoan_co_bach, nhac_chinh_hanh, bao_nham_tinh,
  au_duong_tan_di (thuy_vi).
- Why: the Cliff Hall plays like Tùng Đào. Fun: crack, then lean.

**d14. The Ninth Verse, sung for oneself (Đệ Cửu Khúc)** · Effect (duel reading) · `ra-LH3` · **n 5**
- AUTHORED: see authored/auth-eff-1.json
- Rule: once a fight at 25 % health or below: 10 s of 10 % less damage, no delays, 1 %/s healing. Over a fallen
  companion it works as written.
- Lives: The Ninth Verse (Fishing Boats Sing at Dusk). Who: lo_xuong_van, bo_tan_chieu, nhiep_ngoc_am, hach_anh_ha,
  lan_vien_pham (lac_ha).
- Why: "sung over a fallen ally" never fires. Fun: the song sect's last stand.

**d15. Laid Ward on the Next Stroke (Phù Đãi Chiêu)** · Ward · `ra-ST1` · **n 5**
- AUTHORED: see authored/auth-eff-1.json
- Rule: a laid ward fires when the foe next fires an art: roots (a1), Wood damage, burns out; up to three; free in a
  foreseen fight's preparation. Same reading for Hang the Bells.
- Lives: Laid Ward (Frost Pine Ward Canon). Who: van_han_dang, nhac_hoa_bi, khong_da_hanh (suong_tung); tham_huong_nhi,
  yen_boi_ngoc (minh_loan).
- Why: nothing laid fires on the foe's action. Fun: traps that turn the foe's tempo; preparation pays.

**d16. The Twelve Hours (Thập Nhị Thời)** · Effect · `rb-15` · **n 5**
- AUTHORED: see authored/auth-eff-1.json
- Rule: an hour = 5 s of fight; each ring is strongest in its hour; rings from 3 different hours turn the armillary
  (all refresh), each further hour adds damage and slow, no cap.
- Lives: Armillary Array Canon. Who: tham_bac_than, to_tinh_nghi, pho_cuong_dau, sam_lac_thiet (cung_tinh);
  ve_van_co (market-folk).
- Why: the abbey otherwise plays as the Pivot again. Fun: a clock the foe watches close.

**d17. Geese Line (Nhạn Hàng)** · Effect · `tl/geese-line` · **n 4** · *blocked on a1's ally reading*
- AUTHORED: see authored/auth-eff-1.json
- Rule: with allies beside you, you take 15 % of each ally's damage and gain block per ally standing.
- Lives: the Wild Geese Formation Canon, Autumn Water and the Long Sky, and for Trang Thiết Cước the Pine Warden's
  Staff and Bow Canon; `nt-first-file-banner`. Who: canh_truong_thien,
  thinh_kinh_han (lac_ha); muc_han_nhan (nhan_tran); trang_thiet_cuoc (tuan_tung).
- Why: no piece looks at allies; sets What Came Off the Field and Out of the Grey write it by hand. Solo form: d4.

**d18. Frost Answers the Blow (Sương Ứng)** · Effect · `ra-BT1` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: in Heart in the Jade Vessel, each hit the frost ward absorbs lays 1 Ice stack (2 above half ward). It releases
  when the ward reaches 25 % of your max health or the foe carries 10 Ice stacks; the Cold hit gains 4 % per stack and consumes up to 10.
- Lives: Jade Vessel Ice-Heart Canon (layer 6) or Rime Lotus. Who: so_ngoc_ho, co_lang_suong, tiet_han_mai, on_sa_ngoc
  (bang_tam).
- Why: the canon's concept says it; no art does. Fun: the foe must decide whether to keep hitting her.

**d19. The Cup Fills (Bôi Mãn)** · Effect · `ra-DQ1` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each 5 % max health paid for arts or dealt as Bleed fills the Night-Glow Cup by 1 (to 5); at 5 the next art is
  free and heals 20 % of the health paid. A kill still fills it at once.
- Lives: Wine in the Night-Glow Cup; `dq-night-glow-cup`. Who: hang_da_boi, do_xich_linh, hang_luu_hoa, o_liet_phong
  (da_quang).
- Why: the signature drink fires only on a kill, at the duel's end. Fun: pay, fill, drink.

**d20. The Long Ride on the timeline (Trường Khu)** · Effect (reading) · `ra-MV1` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: momentum +1 each second you or your companion land a hit (to 10), halved by a single hit of 5 %+ max health.
- Lives: The Long Ride. Who: khau_muc_van, tan_thien_ly, du_bon_van, khau_thanh_thao (muc_van).
- Why: the canon has no step art, so even a1's Moving never counts it. Fun: keep the horse running.

**d21. The Army Fights, the Marshal Waits (Quân Chiến Soái Đãi)** · Effect · `rb-03` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: hits by your summons, flying edges and formations do not break Momentum or The Called Blow's wait, and add
  Momentum while you wait. "If it kills, halve the wait" becomes "if it breaks a ward or a summon".
- Lives: Army-Breaker Spear (last layers) or `tx-dao-quang-war-flag`. Who: do_tinh_ha, ngu_tran_bac, nhiep_minh_tien,
  cuu_bat_ngu (thien_xu).
- Why: the main canon and the spear fight each other as written. Fun: the army grinds, one thrust lands. With g3.

**d22. Stars on the Foe (Tinh Tại Địch)** · Effect (rule change) · `rb-19` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each Seven-Star Talisman paints its star on the target; a cleanse wipes them unless painted under The Rain Does
  Not Take It; the seventh star on one foe detonates.
- Lives: Painted Dipper Canon. Who: ky_ngan_chuc, lac_to_binh, han_thuy_mac, lang_mac_khanh (hoa_tinh).
- Why: counted on the thrower, the Pivot bloc's four sevens play alike. Makes d35's item half optional.

**d23. The Long Road (Trường Lộ)** · Effect · `rb-20` · **n 4** · *needs a1's Moving*
- AUTHORED: see authored/auth-eff-1.json
- Rule: while Moving, arts cost less linh lực, more per Walk Slowly stack.
- Lives: Straw Sandal Step Primer (last layer) into the Calm-Wind Staff Canon. Who: uc_diep_thanh, phi_thoa_y,
  ky_khinh_ma, dinh_van_do (xuyen_lam).
- Why: no linh lực source of its own. Fun: the guide gets cheaper the longer the fight runs.

**d24. Water Wears the Stone (Thủy Tích Thạch Xuyên)** · Effect · `rb-22` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: each heal you receive drips a Wood hit on the foe, growing with your Wood buff stacks, max 3 a pulse.
- Lives: Canon of the Good Rain (Moistens Without a Sound). Who: duong_hao_vu, thoi_tri_tiet, luc_dao_hoa, la_tiem_da
  (coc_vu).
- Why: the abbey deals nothing and fatigue makes outlasting a loss. Fun: the abbess never strikes, and the foe wears away.

**d25. The Lamp Flares (Đăng Bùng)** · Effect · `rb-26` · **n 4**
- AUTHORED: see authored/auth-eff-1.json
- Rule: a ward seal that burns out flares: a free hit and a short slow, growing with the blows it turned. Last Lamp
  Vigil becomes a choice (wall or fuse).
- Lives: Lamp-Ward Seal Canon. Who: on_thu_dang, chan_dinh_lan, kien_muc_hai, le_bach_diem (vong_trieu).
- Why: the damage half beside d27. Fun: lamps going out one by one, each with a crack of light.

**d27. Lamp-Ward (Thủ Đăng)** · Effect, Modifier fallback · `tp/lamp-ward` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: ward seals turn 1 more blow, +1 per 3 seals held. Fallback: `ward_efficiency_pct 4, than_thuc_pct 3` on
  `vtd-unsleeping-lamp`.
- Lives: the Lamp-Ward Seal Canon, or `vtd-unsleeping-lamp`. Who: on_thu_dang, kien_muc_hai, le_bach_diem (vong_trieu).
- Why: Water's only ward efficiency is in the Ice crown (d 38).

**d28. The Earned Rest (Đắc Hưu)** · Effect · `ra-VH1` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: when the Marching Dirge's finale ends a march, The Held Rest lasts 0.5 s per Measure spent (to 6 s) and foe
  arts cost 20 % more meanwhile.
- Lives: The Monk's Rest. Who: ha_thinh_tung, quan_tich_am, cu_dong_moc (van_hac).
- Why: a fixed 2 s rest with no defined end. Fun: play, rest, play.

**d29. Return to the Scabbard (Quy Sao)** · Effect · `rb-08` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: after 3 s without striking a foe, it counts as unstruck: first-hit and No Second Cut pieces re-arm.
- Lives: Rain-Chain Sword Scripture or the Drawn-Out Edge Canon. Who: co_da_lan, ton_tuyet_bich (thinh_vu);
  thang_vo_ta (phat_y).
- Why: one-cut builds peak in the first second of a 60 s fight. Fun: cut, step back, sheathe, wait, cut.

**d30. Brittle from Its Own Blow (Tự Kích Tự Thúy)** · Effect · `rb-13` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: each foe hit you block gives it a Quench mark; Quench on a burning foe spends every 3 burns for 1 more mark.
- Lives: Star-Quench Canon or the River Tongs. Who: bang_lanh_toi, cat_luu_quang, dinh_hoa_lan (thoi_tinh).
- Why: "a foe's own blows make it brittle" has no piece. Beside b3 (scaling) and d43 (own blade).

**d31. True Gold Does Not Fear the Furnace (Chân Kim Bất Phạ Hỏa)** · Effect · `rb-17` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: each buff or ward share you strip returns linh lực and adds a Part the Dross stack.
- Lives: True Gold Canon. Who: tuong_bach_luyen, phung_xich_kim, tuong_ngoc_can (chan_kim).
- Why: the payoff for d38's strip. Fun: a hard counter to buffers, weak against a plain brawler.

**d32. The crane king, and a crane for the rider without one (Thanh Điền / Hạc Linh)** · Other (spirit-beast
companion) and Effect · `S6 + rb-16` · **n 3**
- AUTHORED: see authored/auth-eff-2.json
- Rule: the crane king fights beside its rider (Wind strikes, takes `attack_pct [companion]`, answers each evade);
  each crane hit gives the rider a Wind buff stack; with no beast out, Crane Descends calls a short-lived crane spirit.
- Lives: Crane Bond Rite; the spirit-beast system. Who: ung_hac_minh, cu_van_ly, tong_phi_thu (cuu_cao).
- Why: the Green Field Bell calls the king once; other riders' art does nothing without a beast. Fun: she dodges, the
  crane strikes.

**d33. Bitter Medicine (Khổ Dược)** · Effect · `ra-TC1` · **n 2**
- AUTHORED: see authored/auth-eff-2.json
- Rule: under 10 Poison stacks on you, each tick heals half its damage instead; at 10+ it hurts.
- Lives: Hundred Herbs Tasting (layer 3). Who: nghiem_linh_chi, lu_niem_ha (thai_chi).
- Why: the concept turns poison into cure; its art only cleanses. Fun: a poisoner must pile it on.

**d34. Charmed (Mê Hoặc)** · Effect (new curse) · `sets-tp/charm` · **n 2**
- AUTHORED: see authored/auth-eff-2.json
- Rule: 2 s: casts no art at the charmer and basic attacks miss; broken by the charmer's hit; 10 s immunity.
- Lives: the status catalogue; Tea at the Manor, Fan of the Gracious Door. Who: nghe_hong_dau, lieu_da_thai (hong_dau).
- Why: no charm exists. Fun: the guest stops fighting for a breath while the poison works.

**d35. Rainfast Ink (Vũ Bất Thoát)** · Effect · `W6` · **n 2**
- AUTHORED: see authored/auth-eff-2.json
- Rule: your debuff stacks and talisman marks cannot be cleansed.
- Lives: Rain-Fast Ink Art (met there, per rb-19), or optionally a Hoa Tinh brush. Who: han_thuy_mac,
  ky_ngan_chuc (hoa_tinh). Why: stack-duration nodes (Snow Lotus) lengthen marks but do not stop a cleanse. See d22.

**d36. Birds Pay Court to the Phoenix (Bách Điểu Triều Phượng)** · Effect · `rb-12` · **n 2**
- AUTHORED: see authored/auth-eff-2.json
- Rule: each spirit-bird hit lays the next plumage colour you lack (once a pulse); each full plumage heals your companions.
- Lives: a Wutong Court passive on the Five-Virtue Phoenix Canon. Who: vu_ngo_dong, an_thuy_vu (phuong_minh).
- Why: nothing joins birds to plumage. Fun: the birds paint, the phoenix sings it off.

**d37. When the Thread Breaks (Đoạn Ti)** · Effect · `rb-27` · **n 2**
- AUTHORED: see authored/auth-eff-2.json
- Rule: a thread breaks when the bound foe fires a heavy art or is pushed (recoil: lose linh lực); held full length, it
  ties a Knot that Fire in the Thread sets alight.
- Lives: Unbroken Thread Canon. Who: than_van_cam, tang_mong_kien (chuc_ha). Why: the risk is named but never defined.

**d38. Assay (Thí Kim)** · Effect · `W3` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: once per art firing, a hit on a buffed foe removes its oldest buff stack.
- Lives: True Gold Canon / Hundred Refinings Art, or `ck-hallmark-seal`.
- Who: tuong_bach_luyen (chan_kim); the Tried and Stamped set leans on it. Why: nothing strips buffs. Payoff: d31.

**d39. Drunk (Túy)** · Effect (new curse) · `sets-tp/drunk` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: stacks to 3; each +10 % art timers and 10 % chance an art fires at nothing; at 3, +10 % Water damage taken.
- Lives: the status catalogue; Half Lake, Sweet Spring Wine Rite. Who: nhac_thuan_nhuong (le_tuyen).
- Why: the set borrows Slowed Time, and three Lễ Tuyền pieces (Last Cup, Sealed Cask, Open the Cask) define drunk three
  ways; all should lay this one status. Fun: he offers you a cup and wins by making you miss.

**d40. Sleep (Hôn Thụy)** · Effect (new curse) · `sets-tp/sleep` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: 3 s: art timers stop; the first hit wakes it and deals 20 % less; 6 s before reapplying.
- Lives: the status catalogue and the Night Moth curses (Darkness). Who: sao_an_lan (demonic); Shade Orchid Breathing.
- Why: her build dims and sleeps the foe; Withering and Slowed Time stand in. Fun: a Darkness that does not kill.

**d41. Banked Healing (Tàng Liệu)** · Effect (engine) · `sets-tl/heal-store` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: healing you would grant is stored (to 30 % max health) and spent at once on every ally on a trigger; the fight
  screen shows the store.
- Lives: The Dusk Field set; later the Gathered Haze Canon. Who: diem_tu_to (yen_quang).
- Why: nothing stores healing as a quantity; the Cold Furnace only doubles heal-over-time for 10 s. Fun: one wave that stands the line back up. Uses a5; beside d5.

**d42. One Thread of Wind (Nhất Tuyến Phong)** · Effect plus Modifier · `sets-tl/companion-thread` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: holder and bonded companion share damage taken; joint strikes heal both; companion health via the existing
  `companion_health_pct` (the source asked for a new key).
- Lives: a Mục Vân herd-call art, or `mv-dap-van-bridle-ring`. Who: khau_muc_van (muc_van).
- Why: Pack Hunt and the Cloud-Herding Lance raise companion damage only; nothing shares damage with a beast. Fun: the horse lord and his horse as one.

**d43. Heat the Edge (Tôi Phong)** · Other (engine) · `S2` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: each Fire art heats your sword a step (to 5, +4 % pierce to Metal sword arts each); at 5 the next sword art
  quenches as a certain crit that counts as a Thunder strike.
- Lives: `tht-fallen-star-forge` (written); ideally a Star-Quench art. Who: cat_luu_quang (thoi_tinh).
- Why: art counters exist, but none lets one element charge a weapon another spends. Fun: fan the blade red, quench it in a foe.

**d44. The Sky of a Moment Ago (Tiền Khắc Thiên)** · Effect (new rule kind) · `sets-tl/paint-back` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: a 3 s record of health and linh lực lost; once a fight a trigger restores it.
- Lives: The Idle Cloud set; the old-reflection-art lineage. Who: diep_to_quyen (nhan_van).
- Why: no rule reads the last few seconds; death-saves stop a blow, they do not undo one. Fun: the brush paints the last three seconds out of the pool.

**d45. A formation that walks (Trận Tùy Thân)** · Effect (new rule kind) · `S3` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: your standing formation follows you. Lives: `mf-carried-array`; a diagram modifier in Formations #17.
- Who: ve_van_co (market-folk). Why: formations are fixed; the Loom of Letters Seal moves one once, a teleport, not a
  walking wall. Fun: he walks into a fight already inside his own walls.

**d46. Array within an array (Hoàn Trung Hoàn)** · Effect · `S4` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: an array laid on a foe inside your array forms a second ring: no leaving either, both rings' damage each second.
- Lives: `ct-armillary-rings` or Formation Within a Formation. Who: to_tinh_nghi (cung_tinh).
- Why: Formation Within a Formation adds damage only; nothing nests one array's hold in another's.

**d47. Time stopped for everyone but you (Tiền Thế)** · Effect (new rule kind) · `S5` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: 2 s in which every foe's clock stops (no arts, movement or stack decay) while yours runs.
- Lives: `hs-what-the-old-man-kept`; the Stilled Hour Sutra's top art. Who: mac_quy_khu (hermits-sages).
- Why: the Băng Tâm regalia stills time for you alone; no rule freezes the foes. Fun: the oldest man alive steps out of time.

**d48. Thaw (Giải Băng)** · Effect · `rb-31` · **n 1**
- AUTHORED: see authored/auth-eff-2.json
- Rule: each Fire hit strips one Ice stack from you, heals a little and adds a Fire stack to your next hit.
- Lives: Scorch Fist Primer or the Thawing Brazier. Who: du_chuc_nhi (loose-north).
- Why: her Fire primer reads nothing of the Ice laid on her. Fun: the colder they make her,
  the hotter she hits.

**d49. The Wind Lifts the Mist (Phong Khởi Vụ Tán)** · Effect (a counter) · `vu_an.md` (ruling 2026-11-25) · **n 10**
- AUTHORED: see authored/auth-eff-2.json
- Rule: a foe's Wind art lifts any mist you lay (the mist field ends). Open: whether a Lantern-Stone holding the field
  breaks too, whether one Wind art lifts one mist or all, and whether The Gate Is Not There's fold counts as mist.
- Lives: Mist-Lock Array Canon, Road Mist Primer, Gate Hidden in Mist. Who: bang_yen_toa, trieu_ngu_lang,
  ham_thanh_dang, luyen_to_y, thai_van_xa, khuyet_lac_vu, ham_tieu_vu, tap_xuan_tra, mao_dao_bi, ky_that_lo (vu_an);
  the fill members in `vu_an.5.cast.json` hold the same methods.
- Why: the page names Wind as the sect's weakness, and no rule makes it true, so the mist has no counter. Kept by
  user ruling 2026-11-25. Fun: a matchup the player can read: bring a Wind art to the cape roads, or lose the way.

## (e) Techniques and arts

**e1. Bronze Answers (Đồng Ứng)** · Art · `rb-07` · **n 10**
- AUTHORED: see authored/auth-tech.json
- Rule: the Metal twin of Answering Peal, open only to roots without Thunder: each crit and counter-cut adds a Peal; at
  3, the next Metal crit fires your last Metal art again at 60 %.
- Lives: Canon of the Thunder Heard in the Rain. Who: co_da_lan, manh_da_vu, quan_vu_thanh, phuong_doan_vu,
  nhiep_vo_thanh, kieu_man_lau, tuong_lau_thanh, lu_tan_ha, hua_thanh_diem, ung_thinh_thien (thinh_vu).
- Why: ten of fifteen holders are locked out of two of three arts. Fun: the storm without the lightning. Pairs with b6.

**e2. Pill Smoke (Đan Yên)** · Art · `rb-18` · **n 7**
- AUTHORED: see authored/auth-tech.json
- Rule: burns a prepared pill in the censer: half its effect for you, a damage cloud on the foe by grade and element; a
  failed pill still smokes.
- Lives: Canopy Furnace Canon; the hermit Purple Smoke Furnace Canon. Who: la_tu_vi, uy_dan_duong (hoa_cai);
  ke_chu_sa (phuong_minh); o_thiem_tu (thinh_vu); khuyet_van_ha (hermits-sages); lac_dan_thanh (market-folk);
  phung_xich_kim (chan_kim).
- Why: the censer base has no common art. Fun: a failed batch is ammunition.

**e3. Into the Vent (Nhập Huyệt)** · Art · `rb-24` · **n 4**
- AUTHORED: see authored/auth-tech.json
- Rule: lays your own burns on you; each burn tick from any source becomes heat; healing up while you burn.
- Lives: Burning Feather Body Canon. Who: hung_phan_vu, tao_tan_kien, trang_hoi_y, doi_liet_cuong (phan_vu).
- Why: against a foe with no Fire the engine never starts. Fun: he sets himself on fire to get started.

**e4. The Next Movement, and Playing Past the Break (Tấu Tiếp / Tục Phổ)** · Art (counted) and Effect · `rb-11` · **n 4**
- AUTHORED: see authored/auth-tech.json
- Rule: each firing plays the next movement with its own small rule (Nine Shao 1-8, Remnant Score 1-7; another song
  between restarts it). Once a fight, after the seventh, a thần hồn and khí vận roll for the eighth: its effect, or a
  soul backlash. Dawn Clouds ends only when a hit gets past ward or shield.
- Lives: Nine Shao Phoenix Advent, Shao Remnant Score. Who: hoa_trieu_duong, lien_thieu_nghi, lo_van_khanh,
  chuc_hieu_nghi (phuong_minh).
- Why: movements are named but missing. Fun: a piece the foe hears coming; the eighth note is a gamble.

**e5. Landing the Fish (Thu Tuyến)** · Art · `ra-LG1` · **n 3**
- AUTHORED: see authored/auth-tech.json
- Rule: Line Through the Ice and A Bite on the Line bank drained linh lực as a Catch; Landing the Fish spends it as a
  Water hit of 3x the Catch, doubled under 20 % foe linh lực.
- Lives: Lone Line Sitting Canon (layer 6). Who: lu_doc_dieu, bo_toa_tuyet, su_pha_bang (lanh_giang).
- Why: the canon drains but has no payoff. Fun: a patient drain, one pull. With f3 (the rod).

**e6. The Fifteenth Layer (Đệ Thập Ngũ Tầng)** · Technique layer (quest) · `ra-TD2` · **n 3**
- AUTHORED: see authored/auth-tech.json
- Rule: when you go Down, banked waves keep firing 6 s; if the foe goes Down then, it is a draw.
- Lives: Pine Wave True Canon, layer 15, by quest (Hall of Voices or the founder's pine). Who: dam_tung_lai,
  thoi_khinh_hong, vi_thanh_am (tung_dao).
- Why: Final Clause fires one art as you go Down; the page says this layer exists, never chanted. Fun: the foe must survive the head's last breath.

**e7. Drink Within a Breath (Nhất Tức Ẩm)** · Art · `rb-29` · **n 2**
- AUTHORED: see authored/auth-tech.json
- Rule: 1 s after each crit, health leeched is also paid as linh lực.
- Lives: `black-wind-blood-sabre` (`people/demonic.techniques.json`). Who: khoai_thiet_ung (demonic); do_liet_co (loose-south).
- Why: the concept turns blood into linh lực, but the method has only borrowed arts; the Black Wind Sabre item gives no
  linh lực. Fun: every crit is a drink.

**e8. Move the Sickness (Di Bệnh)** · Art · `rb-28` · **n 1**
- AUTHORED: see authored/auth-tech.json
- Rule: moves your oldest debuff, status or curse stacks onto the foe as yours; at layer 9 also a wound share.
- Lives: Withered Branch Method. Who: duong_kho_chi (demonic).
- Why: it carries only borrowed arts, so it plays as a plain poisoner. Fun: everything laid on the heretic comes back.

**e9. Black Ice (Hắc Băng Quyết)** · Technique (found or stolen manual) · `sets-bt-05` · **n 1**
- AUTHORED: see authored/auth-tech.json
- Rule: an Earth-tier Ice-Darkness method: your Ice stacks also count as curses, and a frozen, cursed foe takes Darkness
  damage when the freeze ends. Cheap stand-in (review-a note): an item `convert_pct` Cold → Chaos line.
- Who: cung_mac_suong (bang_tam). Why: her Darkness half has no method that feeds it. Fun: frost that turns black when nobody is watching.

**e10. Dawn Call (Thần Khiếu)** · Art (Light, on a pipe) · `sets-tp/light-pipe-art` · **n 1**
- AUTHORED: see authored/auth-tech.json
- Rule: a soul art on a pipe dealing Light damage; every third cast lays Exposed.
- Lives: `pm-dawn-call-pipe` or a Light branch of the Red Sun Scripture. Who: chuc_hieu_nghi (phuong_minh).
- Why: Phượng Minh has no Light art; her set adds Exposed every fifth soul art as a stand-in. Fun: the only Light in
  the palace finds a way to play it.

## (f) Items, item bases and sets

**f1. Missing weapon bases: bow, staff, spear, hook, brush, fist wrap (Cung, Côn / Trượng, Thương, Câu, Bút, Quyền
Sáo)** · Item bases · `sets-tl/bow-and-staff-bases + sets-tp/staff-base + S1` (+ rb Thiên Xu note) · **n 12**
- Rule: Bow (Physical, a common art like `pinning-arrow`); Staff (attack ~30, defence 10, `[staff, physical]`, a
  two-strike sweep); spear (reach, pierce); hook (pulls, crit on a pulled foe); brush (talisman speed); fist wrap
  (body fist arts). Optional Boots/Sandals body base.
- Lives: `design/items/bases.json`. Who: hua_van_cung and Tuần Tùng's wardens; uc_diep_thanh, phi_thoa_y and every
  Calm-Wind Staff user (xuyen_lam); do_tinh_ha, ngu_tran_bac, cuu_bat_ngu, nhiep_minh_tien (thien_xu); an_thu_son,
  sam_van_nuong, do_liet_co (loose-south); ky_ngan_chuc (hoa_tinh); du_chuc_nhi (loose-north).
- Why: the Wolf-Winter Bow and Army-Breaker Spear have `base: null`; spears and hooks sit on `phi_kiem`. Fun: the
  warden holds the road with the staff all night and shoots the leader at dawn.

**f2. The Whole Couplet (Toàn Liên): sets that answer across holders** · Art plus set rule · `sets-tl/two-halves` ·
**n 4** · *needs two cultivators on one side (unsupported)*
- Rule: when the Dawn Half and the Dusk Half are worn whole by two allies in one fight, either may cast the whole
  Painted Beams talisman; same rule for The Crossing and Slack Water.
- Lives: an art in `painted-beams-dawn-flight`; the R7 set rule. Who: chau_phi_van, kha_trieu_phi (nam_pho);
  bui_phieu_binh, luong_bach_tan (binh_thuy).
- Why: R7 sets count only one person's pieces, and the founders' art is written in two halves. Fun: rivals must stand together to paint the founders' talisman.

**f3. Fishing rod (Cần Câu)** · Item base with a line rule · `sets-bt-03` · **n 3**
- Rule: its art hooks a foe; a hooked foe cannot leave reach and can be dragged in (interrupting its art); needle-like
  modifiers plus status duration.
- Lives: bases; the Ice Hook (`lg-ice-hook`), Liễu Thoa Lạp's lost rod. Who: lu_doc_dieu (lanh_giang), lieu_ngu_ca
  (bang_tam), doan_thanh_lang (trac_anh, on a harpoon).
- Why: no base carries a line, so the hook sits on a needle. Fun: hook, wait, pull. Drag reads as a1's knock back.

**f4. Luyện Khí sets: Carried Pair (Đới Song) / Song Hỏa** · Set rule · `sets-tl/one-slot-pair + S8` · **n 2** ·
*ruled 2026-11-25*
- Rule: keep 2-piece sets. The Luyện Khí wears one piece, and the set bonus switches on when they reach Trúc Cơ and
  gain a slot (a growth goal).
- Lives: the R7 set rule. Who: to_mo_van (lac_ha); du_chuc_nhi (loose-north).
- Why: a Luyện Khí wears one piece and the checker wants exactly one. Fun: a prodigy's set grows into itself at her foundation.

**f5. Moulted Feathers as Fan Inlays (Thoái Vũ Khảm)** · Item (material kind and inlay rule) · `rb-25` · **n 2**
- Rule: each bird beast drops its own feather; inlaid in a fan it adds a small rule (crane: evade; luan: heal on burn;
  vent bird: longer burn). The Hundred-Feather Fan counts distinct kinds, no cap. Also an inlay sink for linh thạch.
- Lives: materials and crafting inlays. Who: ta_thanh_loan, ta_thanh_thuoc (bach_vu); the Phượng Minh fans.
- Why: the passive counts feather kinds, but none exist, so it reads item grade. Fun: chase the one missing moult.

**f6. Lạc Anh's Twin Swords (Lạc Anh Song Kiếm)** · Set waiting on a piece · `sets-tp/tan-hong-pair` · **n 1**
- Rule: once Tàn Hồng is placed (slot V-1), pair it with Phi Hồng: Phi Hồng's sealed art wakes, and sword arts lay
  Poison as if Wood.
- Lives: `hong_dau.items.json`. Who: nghe_hong_dau (hong_dau).
- Why: Tàn Hồng is not an item yet, so her set leaves Phi Hồng out. Fun: both swords drawn for the first time in a thousand years.

## (g) Other

**g1. Partial manuals (Tàn Quyển)** · Item kind plus quest hooks · `ra-G4` · **n 12** · *waits on quests*
- Rule: a manual naming a technique and a layer range caps cultivation; finding the rest raises the cap. Written gaps:
  Lone Line Sitting Canon at 8, Painted Beams' dusk half, Returning Swallow Breath
  at 9, Hàm Nguyệt's Kiều frost.
- Lives: Item Database (beside Cultivation Techniques rule 4), sect story hooks, Quests.
- Who: lu_doc_dieu, bo_toa_tuyet (lanh_giang); lieu_ngu_ca, tham_han_giang (bang_tam); luong_bach_tan, bui_phieu_binh
  (binh_thuy); kha_trieu_phi, chau_phi_van (nam_pho); ta_cuu_duong, ta_tri_xuan (clans); kieu_nguyet_chau,
  lam_ham_suong (ham_nguyet).
- Why: manuals teach whole techniques; nothing ends a written stall. Fun: a build with a destination on the map.
  Technique-side twin of g4.

**g2. Family methods as a build's main (Gia Truyền Công Pháp)** · Tooling · `ra-CL1` · **n 9**
- Rule: let `depth_check.py` read `people/*.techniques.json`; point clan builds at their own methods (Locust Shade,
  Twin Span Pillar, Returning Swallow, Seed Store, Reeling Thread).
- Who: tieu_thua_am, tieu_thu_dao, tieu_thu_tuyen, on_thuc_ha, on_the_hoanh, ta_cuu_duong, ta_tri_xuan, luc_ke_dien,
  doi_hau_cam (clans).
- Why: clan people carry generic stand-ins, and each house plays like any cultivator of its element.

**g3. Teach the Pivot its diagrams (Truyền Bổn Trận)** · Teaching list · `rb-04` · **n 6** · *file owned by the
Formations session: note only*
- Rule: Seven Stars (`that_tinh`) to Thiên Xu at elder; Army-Breaker Wedge (`pha_quan`) to the Dao Quang Hall at elder;
  Seven-String Zither (`cam_am`) to Phượng Minh's Hall of Rites.
- Lives: `assets/data/sects_teaching.json`. Who: doan_ngoc_hanh, thien_thua_cu, ngu_tran_bac, nhiep_minh_tien
  (thien_xu); lien_thieu_nghi, lo_van_khanh (phuong_minh).
- Why: the Pivot is named for the Dipper and holds Phá Quân's spear, yet the list gives both diagrams to others.

**g4. Bring It Home (Quy Bảo)** · Quest hook · `sets-tl/lost-pieces` · **n 2** · *waits on quests*
- Rule: a set piece with `holder: null` and a `where` becomes a quest target; returning it completes the set and moves
  the holder's opinion of the finder.
- Lives: the quest system. Who: nhiep_co_tan (the Cold Ford lantern); to_van_chieu (Thanh Sương; the Lone Duck Ring).
- Why: two sets are whole only with a lost piece, and nothing says how one is found. Fun: completing a person's set by your own hand is a gift no stone can buy.

**g5. The Culm Stores for Years (Tàng Tiết Kinh Niên)** · World state plus Effect · `rb-23` · **n 2**
- Rule: each season without flowering adds a bloom layer on the character record, no cap; The Flowering spends all in
  one fight; afterwards Wood arts are sealed for a season and an old holder pays a life cost. Store the Culm stays the
  in-fight trickle.
- Lives: the Sixty-Year Flower. Who: ninh_truc_thuc, man_tiet_thanh (truc_thuc).
- Why: the art says years, but the stance gains a layer every few seconds. Fun: Ninh Trúc Thực has stored 160 years (~640 seasons); when he flowers, the region remembers.

---

## Sources (full text)

All in `design/world/depth/builds/`:
- `wishlist-targets-bt.md` (bt-01, 03, 06, 08; bt-02, 04, 05, 07, 09 withdrawn), `wishlist-targets-tl.md`,
  `wishlist-targets-tp.md`, `wishlist-targets-tx.md` (W1-W10): the Đạo Đồ route wishes.
- `wishlist-sets-bt.md`, `wishlist-sets-tl.md`, `wishlist-sets-tp.md`, `wishlist-sets-tx.md` (S1-S8): the personal-set
  wishes, with the set keys that lean on each target wish.
- `wishlist-review-a.md` (ra-) and `wishlist-review-b.md` (rb-): the "working and fun" reviews, with their own top-five
  lists. review-a's closing notes (archetype against arts, "drops the anchor", the vassals with no entry) and review-b's
  "reviewed, no entry" lineages (Hồng Đậu, Vũ Linh, Lễ Tuyền, the hermits) are not wishes and are not repeated here.
- Format and scope: `README.md`.
