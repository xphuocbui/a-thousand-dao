# Build wishlist: review-a (Băng Tâm, Thúy Vi, Tùng Đào, Lạc Hà, their vassals, the clans)

Proposals for the user's review (format: `README.md` here). This is a review for "working and fun", not a route
pass: it reads the lineages and the tier A and B builds against the fight as Combat describes it. Nothing here changes
a build, the tree, `effects.md` or the Modifier System. Numbers are starting values. Keys carry the `ra-` prefix so
they cannot collide with the bt-/tl- wishes. I did not repeat the 21 merged wishes in `wishlist.md`, the withdrawn
ones or the sets wishes (`wishlist-sets-*.md`). Where an entry touches one of them, it says what is new.

## Summary: the strongest ideas

Environment conditions (ground, terrain, biome, weather, place) removed by user ruling 2026-11-25; ra-G2 is deleted.

1. **ra-G1 Duel readings for ally, movement and kill words.** A fight is one cultivator plus companions, and allies
   are a future extension (Combat Open Question 27). The batch's arts say "allies in the field", "a foe who moves",
   "knock back" and "on a kill". The clauses built on those words die in a fight:
   - Geese Stance's shared damage and the ward every 3 s, which is the core of Nhạn Trận's canon;
   - The Long Ride's momentum, Mục Vân's core stance;
   - Lock the Road's "untargetable from outside" in Vụ Ẩn's mist;
   - the Night-Glow Cup's drink in Dạ Quang;
   - the ally half of every haze, rain and song field.

   One reading per word, written once, fixes all of them.
2. **ra-NT1 A file of one.** In a duel, Nhạn Trận spreads damage over time instead of over allies: part of each blow
   lands over the next few seconds, and a heal can catch it first. It is a new defensive shape, and it gives the file
   canon a solo meaning.
3. **ra-TV1 The Empty Mountain's answer.** Health overflow from the head's heals is stored and falls on a rooted foe as
   Wood damage. A man who passes every killing notable wins with the foe's own blows.
4. **ra-BT1 Frost Answers the Blow.** The Jade Vessel canon's concept says Ice ripens on whoever strikes into the
   frost ward, but no art does it. With that rule and a written release condition, the still Keeper becomes an
   engine, and the foe has to decide whether to keep hitting her.

Entry count: 21 (3 batch-wide, 8 for the great sects, 9 for the vassals, 1 for the clans).

---

## Batch-wide

### ra-G1. Duel readings (Đấu Giải)

- **Kind**: Other (a reading rule for authored arts: one fixed translation per word, written once and used by every
  depth art). It sits beside sets-bt-01 Stillness and sets-bt-04 Displacement, and review-b's rb-01 Moving adds two
  more readings to it.
- **Rule or line**: Read these words the same way everywhere:
  - **ally / allies** → you and your companions. An art that grants something to allies grants it to you in full, and
    to each companion at half. "While N allies stand" counts companions, and you count as one.
  - **a foe who moves, dodges or crosses** → the foe fires an art or a basic attack, or evades.
  - **while you do not move / stand still** → sets-bt-01's Still: you have cast no art for 2 s, or you hold a sitting
    or standing stance.
  - **knock back, drag, sweep, step out of reach** → the foe's next ready art is delayed 0.3 s (0.5 s for a heavy
    art). This applies until displacement exists (sets-bt-04), and it is the fallback that wish names.
  - **rooted for N s** → the foe's evade is 0 for N s and its next ready art is delayed N/2 s.
  - **every foe in reach / spreads to the nearest foe** → the foe and its companions. With no companion, the spread
    lands back on the same foe once, at half strength.
  - **on a kill / when it falls** → the first time this fight the foe drops to 25 % health or below.
  - **casts nothing (a held stance)** → the stance holds your ready arts until a written release condition (its ward
    reaches X % of your health, or the foe reaches N stacks). An auto-resolved fight needs that condition.
- **Where it would live**: depth `schema.md` (the authoring rule) and Effects rule 5 (Readable quantities).
- **Fun**: the arts keep their voice ("allies in the haze heal") and still do something on the timeline.
- **Who needs it**: `muc_han_nhan`, `muc_tan_vu`, `dong_kien_luy`, `luong_thu_hang`, `ngo_bat_tan` (nhan_tran: Geese
  Stance, One Goose banner); `canh_truong_thien`, `thinh_kinh_han`, `lo_xuong_van`, `nhiep_ngoc_am`, `hach_anh_ha`
  (lac_ha: Geese Startled by the Cold, Geese in File, Coming Home at Dusk, Oars Together); `ngu_lam_son`,
  `thieu_thanh_dai`, `khong_duong_quy`, `du_tuc_doan`, `cu_thuy_bach` (thuy_vi: the haze field, Light on the Moss, A
  Seed for the Fallen); `bang_yen_toa`, `ham_thanh_dang`, `luyen_to_y` (vu_an: Lock the Road); `van_han_dang`,
  `khong_da_hanh` (suong_tung: the lanterns); `khau_muc_van`, `tan_thien_ly`, `du_bon_van` (muc_van: The Long Ride);
  `yen_boi_ngoc`, `tham_huong_nhi` (minh_loan: Carriage Bell, Hang the Bells); `hua_van_cung` (tuan_tung: Wolf Ring,
  The Leader First); `hang_da_boi`, `do_xich_linh` (da_quang: the Cup); `tong_toa_van` (van_khoi: Clouds Rise);
  `so_ngoc_ho`, `co_lang_suong` (bang_tam: Heart in the Jade Vessel); `luc_thanh_sam`, `dang_bich_luu` (ho_lam: Bark
  Closes, The Flood Takes It); `ha_thinh_tung` (van_hac: Ten Thousand Ravines).
- **Why**: Combat rule 1 makes a side one combatant plus attached companions, and Edge Cases say a side with more than
  one cultivator is not supported. Open Question 27 lists allies as a future extension, and the Way archived its ally
  facets (◇). There is no position model, so "moves", "reach" and "knock back" mean nothing to the engine. The
  Modifier System already prices `linh_luc_on_kill_pct` low for this reason: "a duel has one kill, at its end". Without
  one reading, each implementer guesses. The geese-line wish (`wishlist-targets-tl`) assumes allies exist, and this
  entry is why it cannot fire today.

### ra-G3. Lineage routes on the border (Môn Lộ Biên Giới)

- **Kind**: Đạo Đồ piece (a second copy of a lineage's route notables, same lines, at its other land).
- **Rule or line**: when a two-land lineage's route sits deep in one land, add a twin of its two or three route
  notables on the border between its lands, or close to the far start (about 15-20 points). Tùng Đào's Pine Strength
  is the model, at 19 from Wood and 23 from Water. Candidates:
  - Lạc Hà's Solid Ground, Gate of Faith and Blessed Basin: 19 from Earth, 43 from Wood, 48 from Water.
  - Thúy Vi's Growth Rings and New Leaf: Wood-only, so "the Earth half has nowhere to go".
  - Vạn Hác's Clear Gong: Metal 24, Wind 37, Wood 47.
  - Tuần Tùng's warden route: Wood 19, Metal 41.
  - Nhạn Trận's file route: Earth 25, Water 55.
- **Where it would live**: Đạo Đồ, beside Paddy Fields (3302) for Thúy Vi's Earth twin, and on the Wood-Earth border
  for Lạc Hà's Maple Hall.
- **Fun**: the lineage's first notables become something every disciple shares, whatever their root.
- **Who needs it**: `me_dien_nhi`, `pham_thu_dien`, `quyen_thanh_lam` (thuy_vi); `sai_thanh_phong`, `nhiep_ngoc_am`,
  `chu_hong_diep`, `giang_vong_pham`, `ta_quy_yen` (lac_ha); `ha_thinh_tung`, `khuong_lac_huyen` (van_hac);
  `trang_thiet_cuoc` (tuan_tung); `dong_kien_luy`, `muc_tan_vu` (nhan_tran).
- **Why**: route cost is not the only problem, since a person's points far exceed the route. But a Luyện Khí on the
  far start cannot reach it at all (`ta_quy_yen`, `me_dien_nhi`). For everyone else the shared opening is a 40-point
  detour that pushes their own ideas out. The lineages are written as two-land methods, and their routes should be
  too.

### ra-G4. Partial manuals (Tàn Quyển)

- **Kind**: Item (a manual that carries only some layers of a technique) plus quest hooks.
- **Rule or line**: a partial manual names a technique and a layer range. A holder who has only it can cultivate no
  higher. Finding the rest raises the cap, and with it the build. The pages already write these gaps:
  - Lãnh Giang's Lone Line Sitting Canon stalls at layer 8, because the true method needs Ice. Hàn Giang Môn's own
    layers are the missing part, and Băng Tâm's `lieu_ngu_ca` is that school's hidden heir.
  - Bình Thủy holds all twelve layers of the Still Moon Tide; its first elder teaches the third-layer turn wrong to the head's heirs (binh_thuy §9).
  - Nam Phố's dusk half of Painted Beams has been in fragments since 1060.
  - The Tạ's Returning Swallow Breath stops at the ninth layer. Its second half is believed to be in the old hall.
  - Hàm Nguyệt's Kiều frost has had no teacher since 748.
- **Where it would live**: Item Database (a partial-manual kind beside the manual of Cultivation Techniques rule 4),
  the sects' story hooks and Quests.
- **Fun**: a build with a destination. The stalled canon has a place on the map where its next layers are, and the
  person who brings them home fights differently afterwards.
- **Who needs it**: `lu_doc_dieu`, `bo_toa_tuyet` (lanh_giang); `lieu_ngu_ca`, `tham_han_giang` (bang_tam);
  `luong_bach_tan`, `bui_phieu_binh` (binh_thuy); `kha_trieu_phi`, `chau_phi_van` (nam_pho); `ta_cuu_duong`,
  `ta_tri_xuan` (clans); `kieu_nguyet_chau`, `lam_ham_suong` (ham_nguyet).
- **Why**: manuals exist, and reading one teaches the technique (Cultivation Techniques rule 4). I found no rule for a
  manual that carries only some layers, so the pages' stalled and half-lost canons have no item that ends the stall.
  This is the technique-side twin of sets-tl/lost-pieces, which handles lost set items such as Thanh Sương and the
  Cold Ford lantern.

---

## Băng Tâm Các

### ra-BT1. Frost Answers the Blow (Sương Ứng)

- **Kind**: Effect.
- **Rule or line**: while you hold Heart in the Jade Vessel, each hit your frost ward absorbs lays 1 Ice stack on the
  striker, or 2 while the ward is above half. The stance releases itself when the ward reaches 25 % of your maximum
  health or the foe carries 10 Ice stacks. The release's Cold hit deals 4 % more for each Ice stack on the foe and
  consumes up to 10.
- **Where it would live**: a passive of the Jade Vessel Ice-Heart Canon (layer 6), or the Rime Lotus art.
- **Fun**: the still Keeper ripens the foe on its own blows. The foe has to decide whether to keep hitting her.
- **Who needs it**: `so_ngoc_ho`, `co_lang_suong`, `tiet_han_mai`, `on_sa_ngoc` (bang_tam).
- **Why**: the canon's concept says "Ice stacks that ripen on any foe who strikes into them", but none of its arts do
  that. Heart in the Jade Vessel only grows and releases the ward, Rime Lotus lays stacks when cast, and the Vessel's
  Ice in the Vessel only regrows the ward. Stone Answers and Thorns return damage, but they lay no Ice and feed no
  release. The release condition is ra-G1's "casts nothing" reading made concrete. sets-bt-01 Stillness defines when
  she is still, not what the stillness pays.

## Thúy Vi Tông

### ra-TV1. The Empty Mountain's Answer (Không Sơn Đáp)

- **Kind**: Effect.
- **Rule or line**: health overflow from your heals (healing lost to a full pool) is stored as Green, up to 30 % of
  your maximum health. When the foe is rooted, or carries 5 Wood stacks, the store falls on it as Wood damage, at most
  once per 3 s, and empties.
- **Where it would live**: a passive of the Empty Mountain Sutra (the head's secret), or a Wood-Earth keystone.
- **Fun**: the man who never strikes first still wins. The harder the foe hits, the more he heals, and the more spills
  back.
- **Who needs it**: `ngu_lam_son` (thuy_vi); also the healers `thieu_thanh_dai`, `khong_duong_quy`, `du_tuc_doan`; the
  neighbours `nghiem_linh_chi` (thai_chi) and `diem_tu_to` (yen_quang).
- **Why**:
  - The sutra "has no killing art", and the head's route "passes every killing notable by", so the build has no way to
    end a fight.
  - Gorged (hits deal more per 1 % healed) needs his own hits.
  - Still Water turns linh lực overflow into health, not health into damage.
  - Returning Light stores damage only as healing.
  - sets-tl/heal-store banks healing and spends it on allies. This entry turns waste into damage.
  - Health overflow is already a readable event (Effects rule 5).

### ra-TV2. The Cliff Splits (Nhai Liệt)

- **Kind**: Effect.
- **Rule or line**: once a foe carries 6 Wood stacks from Root in the Crack, it is Sundered (Physical) for 4 s. If you
  hold Pine Against the Wind at that moment, the stance releases its stored growth as one Physical Wood hit, and the
  count resets.
- **Where it would live**: a passive of Rock-Splitting Root (layer 3).
- **Fun**: crack, then lean. The Cliff Hall plays unlike its pine neighbours in Tùng Đào: they wear a foe down with
  waves, and the Cliff Hall splits it.
- **Who needs it**: `cu_thuy_bach`, `hoan_co_bach`, `nhac_chinh_hanh`, `bao_nham_tinh`, `au_duong_tan_di` (thuy_vi).
- **Why**: Root in the Crack lowers defence per stack and Pine Against the Wind grows the next art, but nothing joins
  them. Sundered exists as a status. The Cliff Hall and Tùng Đào both take Pine Strength (6169-6170) and Thorn Hedge,
  so as built the two lineages play alike.

## Tùng Đào Cung

### ra-TD1. Answering Wave (Ứng Đào)

- **Kind**: Effect.
- **Rule or line**: when you restore health with an art, the foe gains 1 Wood stack for each 1 % of your maximum health
  restored (at most 4 a pulse), and you gain 1 Water stack.
- **Where it would live**: a passive of the Pine Wave True Canon (layer 4), or a notable inside the Pine Strength
  idea.
- **Fun**: "a fight against its holder grows harder the longer it lasts" becomes literal. Each heal pushes the foe
  toward Strangling Vines' 5-stack root, so the foe must burst him before the roots close.
- **Who needs it**: `dam_tung_lai`, `du_tinh_luu`, `ho_tung_nguyet`, `thoi_khinh_hong`, `vi_thanh_am`, `tu_tich_coc`
  (tung_dao).
- **Why**:
  - Ten Thousand Pines Answer does this for only 8 s and resets "if the holder is moved".
  - The Pine Waves Regalia's The Sea Answers sends a Wood stack every 3 s while standing still, but only the head holds
    the regalia, and it breaks "if you are moved".
  - Phoenix Mend is the Fire version and lays Burn.
  - Water Begets Wood converts your own buff stacks and puts nothing on the foe.

  This entry keys the canon's pressure to healing, which every holder does, rather than to a regalia or to standing
  still.

### ra-TD2. The Fifteenth Layer (Đệ Thập Ngũ Tầng)

- **Kind**: Technique (the canon's unspoken top layer, found by quest).
- **Rule or line**: when you go Down, your banked waves (Gathering Wave and the canon's waves) keep firing for 6 s as
  free Water and Wood hits. If the foe goes Down in that window, the fight ends as a double knockout (a draw), not a
  loss.
- **Where it would live**: the Pine Wave True Canon, layer 15. It is recoverable only by quest, in the Hall of Voices
  or at the founder's pine.
- **Fun**: the foe has to survive the head's last breath, and a loss can still turn into a draw.
- **Who needs it**: `dam_tung_lai`, `thoi_khinh_hong`, `vi_thanh_am` (tung_dao).
- **Why**: Final Clause fires one art as you go Down. Nothing lets a build keep fighting after Down, and the page says
  this layer exists and was never chanted. Combat already allows a double knockout.

## Lạc Hà Tông

### ra-LH1. Red Sky at Evening (Hà Hồng)

- **Kind**: Effect, and a tuning note.
- **Rule or line**: The Glow Deepens counts 1 extra second for each 2 % of maximum health you lose, and its 40 % cap
  arrives at 60 s (+4 % per 6 s, not per 10 s). Last Light on the Field may be cast before the 10th second once the
  foe carries 10 Earth stacks.
- **Where it would live**: The Glow Deepens (the Sunset canon's passive). Three Nights on the Road takes the same
  clock.
- **Fun**: a rush against Lạc Hà feeds its clock. The sect fears a rush, and a rush now brings its dusk sooner.
- **Who needs it**: `to_van_chieu`, `tram_tich_duong`, `canh_truong_thien`, `hach_anh_ha`, `hinh_trong_son`,
  `quach_tiep_van`, `tong_thu_tin` (lac_ha); `hua_van_cung`, `trang_thiet_cuoc` (tuan_tung, Three Nights on the Road).
- **Why**: fights run 30-60 s (economy revision #44). At +4 % per 10 s the Glow gives +12-24 % in a normal fight and
  needs 100 s to cap. Second Night begins "after the first minute", when most fights are over. Colour of the Hour
  (the head's robe) is the only other late-fight piece, and it also counts plain seconds.

### ra-LH2. Written in the Ledger (Ký Trướng)

- **Kind**: Effect.
- **Rule or line**: each hit that takes 4 % or more of your maximum health writes one Debt on the attacker, at most 5,
  lasting the fight. A Debt does nothing on its own. It counts as one more different status for the Ruin Ledger's
  arts. Gathered Ruin Verdict spends every Debt and deals 15 % more for each.
- **Where it would live**: a passive of the Ruin Ledger Scripture as Lạc Hà teaches it (layer 3), at the Counting House
  and the Hall of Scales.
- **Fun**: the clerk's turn. He takes the blows, the ledger fills, and the Verdict reads it out.
- **Who needs it**: `tram_tich_duong`, `tong_thu_tin`, `tu_binh_hanh`, `tang_van_tieu`, `phuong_toan_ngoc` (lac_ha).
- **Why**: this is a new reason beside debt-stone.
  - The Ruin Ledger Scripture counts what its holder lays: Fray for each stack batch landed, and different statuses
    for Ripening Curse and the Verdict. The Sunset cloud's Earth stacks feed it, so it works as an offence engine.
  - What it never reads is the blows its holders take. Their intents say "let the foe write the debt, then call it",
    and their routes take plain defence.
  - The reprisal pieces they can reach are Mountain Stance and Bastion Reprisal (the inner gate's Mountain Heart
    Canon). Those answer at once and in Physical, and of these five only `phuong_toan_ngoc` runs that canon.
  - The Vô Định Tally calls the debt once per fight, for one man.
  - Debt-stone stores damage on the tree. This entry lets the scripture they already hold read their defence.

### ra-LH3. The Ninth Verse, sung for oneself (Đệ Cửu Khúc)

- **Kind**: Effect (a duel reading of an existing art).
- **Rule or line**: once a fight, the first time you fall to 25 % health or below, the Ninth Verse sings itself. For
  10 s you take 10 % less damage, cannot be delayed, and heal 1 % a second. Sung over a fallen companion, it works as
  written.
- **Where it would live**: The Ninth Verse (Fishing Boats Sing at Dusk).
- **Fun**: the song sect's last stand. The verse sung only over the dead is sung over the singer.
- **Who needs it**: `lo_xuong_van`, `bo_tan_chieu`, `nhiep_ngoc_am`, `hach_anh_ha`, `lan_vien_pham` (lac_ha).
- **Why**: "sung over a fallen ally" never fires in a one-fighter fight (ra-G1). Unyielding Breath and Nirvana are the
  closest once-a-fight saves, and neither is a song.

---

## Vassals

### Dạ Quang Môn: ra-DQ1. The Cup Fills (Bôi Mãn)

- **Kind**: Effect.
- **Rule or line**: each 5 % of maximum health you pay for arts, or deal as Bleed, fills the Night-Glow Cup by 1 (to
  5). At 5, your next art is free and heals you for 20 % of the health paid since the last fill. A kill still fills
  the Cup at once, as written.
- **Where it would live**: Wine in the Night-Glow Cup (the canon's art) and the `dq-night-glow-cup` item's Drink After
  the Raid.
- **Fun**: pay, fill, drink. The blood sabre gets a rhythm inside the fight.
- **Who needs it**: `hang_da_boi`, `do_xich_linh`, `hang_luu_hoa`, `o_liet_phong` (da_quang).
- **Why**: the sect can sustain. Its leech (the Cup's 20 %, the Debt Ledger Blade, the Tearing Force Rites) and
  Bloodletting Rite repay a cut. But the canon's signature moment, the drink from the cup, fires only on a kill in both
  the art and the item, and a duel ends at the kill. Debt of Stone gives Earth stacks for health paid, and Whetstone
  Vow halves health costs. Neither makes paying in blood build toward anything.

### Lãnh Giang Phái: ra-LG1. Landing the Fish (Thu Tuyến)

- **Kind**: Art.
- **Rule or line**: Line Through the Ice (and the Ice Hook's A Bite on the Line) bank the linh lực they drain as a
  Catch. Landing the Fish spends the Catch as one Water hit worth 3 times the Catch, doubled if the foe's linh lực is
  below 20 %.
- **Where it would live**: a third art of the Lone Line Sitting Canon (layer 6).
- **Fun**: a patient drain, then one pull on the line.
- **Who needs it**: `lu_doc_dieu`, `bo_toa_tuyet`, `su_pha_bang` (lanh_giang).
- **Why**: the canon drains and sits but has no payoff of its own. Its damage comes from the Undertow Litany beside it
  (Drag of the Deep). "He waits for the foe to tire", but fatigue grows on both sides, so a dry foe is not a beaten
  one. Water Table and Spillover move linh lực without turning a drained pool into damage. sets-bt-03 (the fishing
  rod) gives the line a drag. This entry gives it the catch.

### Vụ Ẩn Môn: ra-VA1. Lost on the Road (Mê Lộ)

- **Kind**: Effect, plus an open question for the Event Engine.
- **Rule or line**: each foe art that misses you while your mist field holds gives the foe a Lost stack. At 5 Lost,
  your escape art fires at `cooldown_min` and cannot fail. Open: today a flight takes the request's failure branch
  (AC-CB-62). For a guard or escort request, a flight from your own mist could count as success.
- **Where it would live**: a passive of the Mist-Lock Array Canon, or the `va-mist-lock-lantern`. The open half goes to
  the Event Engine's request outcomes.
- **Fun**: the goal of the fight changes. The mist-walker wins by being gone, which the sect's rule ("never strikes
  from the mist") already implies.
- **Who needs it**: `bang_yen_toa`, `ham_thanh_dang`, `luyen_to_y` (vu_an).
- **Why**: the head "has not won a fight in fifty years". The builds have evasion and concealment and no way to end a
  fight. Beneath Notice and Cold Feet make escape likelier or sooner, but they do not read misses. This is a new reason
  beside bt-03 (accuracy loss), which makes the mist stronger but still gives it no end.

### Vạn Hác Viện: ra-VH1. The Earned Rest (Đắc Hưu)

- **Kind**: Effect.
- **Rule or line**: when the Marching Dirge's finale ends a march, The Held Rest lasts 0.5 s per Measure spent (at most
  6 s), and the foe's arts cost 20 % more while it lasts.
- **Where it would live**: a passive of The Monk's Rest.
- **Fun**: play, rest, play. A long march ended at the right moment buys a long silence.
- **Who needs it**: `ha_thinh_tung`, `quan_tich_am`, `cu_dong_moc` (van_hac).
- **Why**: The Held Rest is a fixed 2 s "after the song ends", and an auto-resolved fight never says when that is.
  `cu_dong_moc`'s Stringless Zither already makes the song after a silence free. Plucked Time delays an art on a
  song's soul hit. Nothing ties the length of the rest to the march before it. This is a new reason beside W8 (song
  damage), which scales the notes, not the silence.

### Thải Chi Cốc: ra-TC1. Bitter Medicine (Khổ Dược)

- **Kind**: Effect.
- **Rule or line**: while you carry fewer than 10 Poison stacks, each Poison tick on you restores health equal to half
  its damage, after resistance, instead of dealing it. At 10 or more stacks the ticks hurt as usual.
- **Where it would live**: a passive of Hundred Herbs Tasting (layer 3).
- **Fun**: poison builds bounce off the valley, up to a point. A poisoner has to pile it on to break through.
- **Who needs it**: `nghiem_linh_chi`, `lu_niem_ha` (thai_chi).
- **Why**: the technique's concept says the holder "can turn a poison on her back into a cure", but its only art
  cleanses and resists (Taste and Name). Withering turns healing into damage, the reverse. W5 (Miasma Lungs) is
  resistance only.

### Tuần Tùng Đường: ra-TT1. Pine Warden's Draw (Tùng Vệ Mãn Cung)

- **Kind**: Modifier, existing stats with a new scope and placement: `attack_pct [bow]` 7.5 and
  `crit_damage_pct [bow]` 15. Scope by the arts' `bow` tag.
- **Rule or line**: 2-3 notables at Drawn Bow's values, scoped to bow arts and not to an element.
- **Where it would live**: a small Wood-land idea beside the warden route (6281, 6312).
- **Who needs it**: `hua_van_cung`, `diem_lac_nhan` (tuan_tung).
- **Why**: Drawn Bow (4207-4259) scopes its damage and crit to `[kim]`. Only its unscoped accuracy reaches the
  element-free Pinning Arrow and Nocked Arrow. The head crosses 41 points into Metal for those lines, and no node on
  the tree scopes `[bow]`. sets-tl/bow-and-staff-bases adds the item bases. This adds the tree support. W7 (Hunter's
  Snare) is a Metal curse line, not bow damage.

### Sương Tùng Các: ra-ST1. Laid Ward on the Next Stroke (Phù Đãi Chiêu)

- **Kind**: Ward.
- **Rule or line**: a laid ward fires the next time the foe fires an art, not "when it crosses". It roots the foe
  (ra-G1: evade 0, next art delayed), deals Wood damage, and burns out. Up to three can be laid. In a foreseen fight,
  preparation lays them at no cost.
- **Where it would live**: Laid Ward (Frost Pine Ward Canon). The same reading serves Minh Loan's Hang the Bells.
- **Fun**: traps that turn the foe's tempo against it. Preparation pays (Pillar 4).
- **Who needs it**: `van_han_dang`, `nhac_hoa_bi`, `khong_da_hanh` (suong_tung); `tham_huong_nhi`, `yen_boi_ngoc`
  (minh_loan).
- **Why**: Combat's wards are standing shields, and Shattering Ward bursts when your own shield breaks. Talismans can
  carry a guard (Talisman Sleeve), but nothing laid on the ground fires on the foe's action. "A foe who crosses" has
  no position to cross. This is a new reason beside the wood-talisman wish, which scales talismans but does not give a
  ward its trigger.

### Mục Vân Trang: ra-MV1. The Long Ride on the timeline (Trường Khu)

- **Kind**: Effect (a reading of an existing art).
- **Rule or line**: momentum builds by 1 each second in which you or your companion land a hit (to 10), and halves
  when a single hit takes 5 % or more of your maximum health. Run With the Herd spends it as written.
- **Where it would live**: The Long Ride (Cloud-Herding Body Canon).
- **Fun**: keep the horse running. Pressure keeps momentum, and a big blow breaks your stride.
- **Who needs it**: `khau_muc_van`, `tan_thien_ly`, `du_bon_van`, `khau_thanh_thao` (muc_van).
- **Why**: "each second the holder keeps moving" never counts on a timeline with no positions. rb-01's Moving reading
  (a step art or stance up) would count it, but the Cloud-Herding canon has no step art, so the core stance still
  never gains a stack. Pack Hunt and Beast Soul Union are the closest companion pieces, and neither builds momentum.
  sets-tl/companion-thread shares damage with the horse but does not count the ride.

### Nhạn Trận Môn: ra-NT1. A File of One (Nhất Nhân Thành Hàng)

- **Kind**: Effect.
- **Rule or line**: while you hold Geese Stance with no ally, 40 % of each hit you take does not land at once. It lands
  evenly over the next 4 s as untyped health loss, and healing taken in that time is spent on it first. One Breath
  Down the File, held alone, halves the stacks of each debuff laid on you and doubles their duration.
- **Where it would live**: Geese Stance and One Breath Down the File (Wild Geese Formation Canon and Walking Out of the
  Grey).
- **Fun**: a new defensive shape. Burst becomes a slope your heals can catch, and a companion or a regeneration build
  makes it shine.
- **Who needs it**: `muc_han_nhan`, `muc_tan_vu`, `dong_kien_luy`, `luong_thu_hang`, `ngo_bat_tan` (nhan_tran);
  `canh_truong_thien`, `thinh_kinh_han` (lac_ha, who carry Geese Stance into Autumn Water and the Long Sky).
- **Why**: this is a new reason beside geese-line. That wish, the One Goose banner and the Out of the Grey set all
  share damage with allies, and a fight has none (ra-G1). Trading the Point still cuts damage, but the stance itself
  does nothing alone, and the canon says "alone, a disciple of the gate is ordinary". No Effect delays damage taken:
  R26 stores dealt damage on a target, which is offence.

## The clans

### ra-CL1. Let the family methods be a build's main (Gia Truyền Công Pháp)

- **Kind**: Other (tooling), so that the clan techniques reach the fight.
- **Rule or line**: let `depth_check.py` read `people/*.techniques.json` as well as `sects/*.techniques.json`. Then
  point the clan builds at their own methods: Locust Shade Breathing, Twin Span Pillar Method, Returning Swallow
  Breath, Seed Store Method and Reeling Thread Breath.
- **Where it would live**: `tools/design/world/depth_check.py`, then the clan cast files.
- **Fun**: a family style shows in the fight. The Ôn's Pillar in the Current blocks three hits, the Lục's Opened
  Granary is a late surge, and a Tạ's swallow-darts come back.
- **Who needs it**: `tieu_thua_am`, `tieu_thu_dao`, `tieu_thu_tuyen`, `on_thuc_ha`, `on_the_hoanh`, `ta_cuu_duong`,
  `ta_tri_xuan`, `luc_ke_dien`, `doi_hau_cam` (clans).
- **Why**: `clans.md` section 9 says the checker reads techniques only from `sects/`. So these people carry
  `hoang_/huyen_<element>` stand-ins, and the clan's arts never reach a fight. Each house then plays like a generic
  cultivator of its element.

---

## Notes (not wishes)

- **Archetype against arts.** `so_ngoc_ho` is `kiem_tu` but carries no sword art or sword item. Her canon is a ward
  method, and her gear is a vessel, a seal and a ring. `kha_tinh_ba` is `the_tu`, but Băng Tâm has no body method
  (`body: null`), and he runs the Winter Toll Canon. Worth checking whether the archetype drives anything (AI
  weighting, power profile) before these are left as they are.
- **"Drops the anchor"** (`lo_xuong_van`, `hinh_trong_son`, `bo_tan_chieu`) reads as Sinking Weight, the Sunset canon's
  art they all hold: Earth stacks, a heavier hit, and art delays. That needs no new art.
- **Cung Mặc Sương's black edge** is covered by sets-bt-05 Black Ice. If that method is far off, a plain `convert_pct`
  Cold → Chaos line on an item would be the cheap stand-in. The tree has no Ice-Darkness border to put it on.
- **Vassals with no entry.** Lê Hoa Am, Trạc Anh Đài, Trấn Sa Đường, Tầm Kiếm Đường, Hồng Lô Cốc, Vân Khởi Quán,
  Hộ Lâm Đường, Hàm Nguyệt Trang, Lãng Đào Môn, Ngạo Tuyết Phái, Bình Thủy Môn, Thiên Bảo Trai, Nam Phố Đường, Nhàn
  Vân Quán, Minh Loan Các and Yên Quang Các each have an engine that feeds itself. Examples: the Sealed Cold seals,
  Hồng Lô's coal and steam, the Asking Blade's marks, Hammer Price, Nacre and Pearl, Nine Bends, Lone Branch, Old
  Reflection, and The Haze Gathers. Their open points are ra-G1 to ra-G4, or wishes already made (bt-06, bt-08,
  metal-stacks, wood-talisman, sets-tl/two-halves, sets-tl/paint-back). Ngạo Tuyết's Lone Branch Sword ("while no ally
  is near") is the one ally clause in the batch that a duel makes always true. That is fine, but it should be priced
  as always on.
