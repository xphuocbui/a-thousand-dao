# auth-mod: group (b), Modifiers on existing stats

These are unpriced proposals in `auth-mod.json`. Each line below names the piece, what it does and who carries it. A
line wires only the gap: where a requester's piece already has the line, it is left alone.

## Entries

- **b1 Maple Hall Road (Phong Đường Lộ).** Carries Lạc Hà's route notables (Solid Ground, Gate of Faith, Blessed Basin)
  as a passive: đạo tâm, health, breakthrough and regeneration, each stat taken once at one notable's size. It goes on
  the Sunset Cloud Canon, Fishing Boats Sing at Dusk, and the Evening Dust Primer at half size.
- **b1 Green Ring Road (Thúy Luân Lộ).** Carries Growth Rings and New Leaf on the Emerald Haze Canon, and the Seed and
  Soil Primer at half size.
- **b1 shared methods (needs a ruling).** The same lines on Mountain Heart Canon and Verdant Cycle Scripture, for Sai
  Thanh Phong and Phạm Thủ Điền. The wiring pass skips this entry until it is ruled on.
- **b1 Clear Gong in the Score (Thanh La Nhập Phổ).** Soul and status resistance on the Ten Thousand Ravines Zither
  Canon (Vạn Hác).
- **b1 Warden's Road (Tuần Lộ).** Health, căn cốt and regeneration on the Pine Warden's Staff and Bow Canon
  (trang_thiet_cuoc).
- **b1 The File's Road (Nhạn Hàng Lộ).** Earth damage, block and health on the Wild Geese Formation Canon (Water-start
  geese).
- **b2 Song tag (Ca).** A new form tag. It goes on string-cut (replacing `music`) and the cam base, the bell arts, and
  the Thu Phần, Shao, Vạn Hác and Lạc Hà song arts.
- **b2 Grave Chorus (Quỷ Xướng Hợp Thanh).** `x_soul [song]` with soul resistance on the Canon of the Autumn Graves,
  `x_soul` and speed `[song]` on the Shao Remnant Score, and `x_soul [song]` on the Hollow Bell Canon.
- **b2 Played Together (Hợp Tấu).** The instruments' soul speed becomes song speed: Phượng Minh's zither and pipe, Thu
  Phần's drum and zither, the cracked bell. The rites drum and the Autumn Graves bell gain a song speed line.
- **b2 Between the Notes (Âm Gian).** A new flute for Gián Thu Địch: song damage and speed, soul resistance.
- **b2 Strings in the Blades (Huyền Tàng Nhận).** A new zither for Bạch Vọng Ngôn: Force song damage, kept clear of the
  Pivot's ban on mind songs.
- **b3 Quench Mark (Thối Ấn).** Metal debuff stack effect and duration. It goes on the Star-Quench, True Gold and Singing
  Luan Bell canons and the Nine-Cycle Mercury Art (Hỏa Cái's Metal art). The fume censer's thần thức line becomes a
  duration line, which keeps it within its grade budget.
- **b4 Painted Leaf (Họa Diệp).** Talisman damage and speed on the Southern Shore Cloud Canon, and the Mulberry Ink
  Primer at half. The Lantern-Maker's Brush gains a damage line. The `talisman` tag goes on Nam Phố's untagged
  talisman arts.
- **b4 Scribe's Reed Brush (Lô Bút).** A new grade-1 brush for Tạ Quy Yến (base null until f1).
- **b5 Miasma Lungs (Chướng Phế).** The Miasma Veil and Cinnabar robes trade their general status resistance for twice
  as much poison resistance. Quý Thủ Lũy gets a new Miasma-Root Charm, and the True Gold Canon (Phùng Xích Kim) gets a
  passive.
- **b6 Rain-Chain Conductor (Vũ Liên Dẫn Lôi).** Metal and Thunder damage, Lightning resistance and căn cốt on the
  Thunder in the Rain Canon. The Thunder half goes on the Rain-Chain Sword Scripture. Chu Trì Âm gets a new Tower sword.
- **b7 Weighed Foe (Quyền Trọng).** Earth debuff stack effect on the Heavenly Pivot and Bowing Stars canons and the
  Armillary Ring.
- **b8 Seal Script (Ấn Văn).** Mostly in the data already (see "Already covered"). Seal speed goes on the Weight of
  the Heavenly Balance; seal damage on the copyist and digger 2-piece bonuses.
- **b9 Hundred Echoes (Bách Hưởng).** The `palm` tag goes on the scripture's two fist arts. The scripture gains palm
  speed and keeps its physical speed, which Thính Vũ uses. The Roosting Geese Beads' damage is rescoped to `[palm]`.
- **b10 Pine Warden's Draw (Tùng Vệ Mãn Cung).** A new `bow` tag. Bow damage and crit damage on the Pine Warden canon,
  and the Wolf-Winter Bow's damage is rescoped to `[bow]`.
- **b11 Opened Veins (Khai Mạch).** Bleed duration and Bleed damage on the Night-Glow Blood Sabre Canon (hang_luu_hoa),
  and the `bleed` tag on Crescent of Red Sand.
- **b12 Snare-Wire Coins (Liệp Sách Tiền).** A new item for Sầm Vân Nương: curse effect, accuracy and Metal damage.
- **b13 Stone Wardens (Thạch Vệ).** Companion power and speed on the Dao Quang war flag (Ngũ Trấn Bắc). Summoned wardens
  are companions (Effects R31), and the flag's `[companion]` damage already reaches them.
- **b14 Blood Drinker (Ẩm Huyết).** Already present: the Lynx-Bone Axe has `leech_health_pct 30`.

## Refused parts

- **b11.** `stack_effect_pct` and `stack_duration_pct` scoped `[bleed]` break modifiers.md rule 8: those stats target
  element stacks, and Bleed is a status. Status duration and damage scoped `[bleed]` carry the idea instead.
- **b13, two parts.** Companion health does nothing while companions cannot be targeted (combat rule 19). A construct
  scope cannot be added: `companion_power_pct` has target "none", and no construct tag exists.

## Already covered

- **b8.** The `seal` tag is already in the vocabulary and on 33 arts. The Nine Seal Ledger already scopes damage and
  speed to `[seal]`.
- **b14.** The Lynx-Bone Axe already carries the leech.
- **b3, b4, b7.** Many named items already carry the lines (tht-river-tongs, the Minh Loan bells, hc-nine-cycle-gourd,
  np-dawn-cloud-brush, tx-heavenly-weight, mf-golden-valley-seal). They are left alone.

## For the reviewer

- **b1 can double up.** A holder of two methods of one lineage, or one who also walks the route, gets the route values
  twice. Chu Hồng Diệp holds both the Sunset Cloud Canon and Fishing Boats Sing at Dusk. A "counts once per lineage"
  rule, or a `lineage.route_passive` field, would fix it.
- **b1 shared methods.** Mountain Heart Canon and Verdant Cycle Scripture are shared catalogue methods, so lines on them
  reach outsiders. That entry is marked `needs-ruling`.
- **b2 rescope cost.** Rescoping the instruments to `[song]` takes the speed off soul arts that are not songs, such as
  Hám Tán Chung's Lamp-Oil Lance.
- **Vocabulary.** `song` and `bow` need a modifiers.md rule-9 amendment before their scopes validate.
- **Engine checks.** Does a Bleed tick match `attack_pct [bleed]` by its status tags? Does a summon's fixed coefficient
  read the companion power share?
- **Not wired.** The Night Rain Regalia's holders are not b6 requesters. The canopy furnace is Earth, so Mercury reaches
  La Tử Vi through the Mercury Art instead.
