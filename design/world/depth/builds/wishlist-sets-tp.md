# Wishlist: sets-tp (personal sets for Thính Vũ, Phượng Minh, their vassals and the demonic group)

Things the personal sets in this batch wanted and could not use, so each set took the closest existing rule for now.
Proposals for the user's review. Nothing here is added to `effects.md`, the Modifier System, the tree or the items.

## charm

- **Name**: Charmed (Mê Hoặc)
- **Kind**: Effect (a new curse).
- **Rule or line**: For 2 s the target casts no art at the one who charmed it, and its basic attacks miss. It is broken
  by any hit from the charmer, and the same target cannot be charmed again for 10 s.
- **Where it would live**: Effects System status catalogue (curse). Used by the set bonus Tea at the Manor
  (`hd-tea-at-the-manor`) and by the Fan of the Gracious Door (`hd-gracious-door-fan`).
- **Fun**: the guest at the gracious door stops fighting for a breath, and the poison keeps working while they smile.
- **Who needs it**: `nghe_hong_dau`, `lieu_da_thai` (Hồng Đậu Trang).
- **Why**: There is no charm in the status catalogue. The set uses Heavy Breath and paused Poison timers instead,
  which slow the foe but do not make the charm of the manor felt.

## drunk

- **Name**: Drunk (Túy)
- **Kind**: Effect (a new curse).
- **Rule or line**: Stacks to 3. Each stack gives 10 % longer art timers and a 10 % chance that an art fires at
  nothing. At 3 stacks the target also takes 10 % more Water damage.
- **Where it would live**: Effects System status catalogue. Used by the set bonus Half Lake (`ltp-hundred-jars`) and the
  Sweet Spring Wine Rite (`sweet-spring-wine-rite`, Lễ Tuyền lineage).
- **Fun**: the cellar master offers you a cup before the fight and wins it by making you miss.
- **Who needs it**: `nhac_thuan_nhuong` (Lễ Tuyền Phái).
- **Why**: The set uses Slowed Time plus an accuracy loss. Slowed Time is Thời Đạo's curse, and it reads as time
  bending, not wine.

## sleep

- **Name**: Sleep (Hôn Thụy)
- **Kind**: Effect (a new curse).
- **Rule or line**: For 3 s the target's art timers stop. The first hit it takes wakes it, and that hit deals 20 % less
  damage. It cannot be reapplied for 6 s.
- **Where it would live**: Effects System status catalogue, and the Night Moth curses in the Darkness land of the Đạo Đồ.
  Used by the set bonus A Breath That Costs No One (`dm-u-lan-keeper`).
- **Fun**: a Darkness that does not kill: the keeper of U Lan puts the foe to sleep and walks away.
- **Who needs it**: `sao_an_lan` (demonic group), and the Shade Orchid Breathing (`shade-orchid-breath`) she teaches.
- **Why**: Her build note says she dims and sleeps the foe. The closest curses are Withering and Slowed Time, so the set
  uses those.

## staff-base

- **Name**: Staff (Trượng)
- **Kind**: Item (a new base).
- **Rule or line**: A physical weapon base, attack about 30, defence 10, tags [staff, physical], with a common art like
  "a sweeping blow that strikes twice". Optionally a Boots/Sandals body base for footwork builds.
- **Where it would live**: `design/items/bases.json`.
- **Fun**: the Gate's guides fight with a bamboo staff and straw sandals, as the founder's song says.
- **Who needs it**: `uc_diep_thanh`, `phi_thoa_y` and every Calm-Wind Staff Canon user (Xuyên Lâm Môn).
- **Why**: The founder's Bamboo Staff sits on the lôi trượng (lightning rod) base, which is a utility piece. The Road
  Mother learns a staff canon and wears no staff at all. With sandals, the founder's pair could grow into a trio,
  staff, sandals and cape, without breaking its story.

## tan-hong-pair

- **Name**: Lạc Anh's Twin Swords (Lạc Anh Song Kiếm)
- **Kind**: Item (a set waiting on a piece).
- **Rule or line**: When Tàn Hồng is placed (slot V-1), make it a set with Phi Hồng (`hd-phi-hong`). 2 pieces:
  Phi Hồng's sealed art wakes, and each sword art lays Poison as if it were a Wood art.
- **Where it would live**: `hong_dau.items.json` (or wherever Tàn Hồng is placed), as a set bonus.
- **Fun**: the heir of Lạc Anh draws both swords for the first time in a thousand years.
- **Who needs it**: `nghe_hong_dau` (Hồng Đậu Trang).
- **Why**: Phi Hồng is half of a pair. Its other half is not an item yet, so the mistress's personal set leaves Phi
  Hồng out and waits.

## song-tag

- **Name**: Song (Ca) form tag
- **Kind**: Modifier (a new scope tag `song`, for arts played on a zither, pipe, drum or bell).
- **Rule or line**: Tag the zither, pipe and drum arts and the soul-song lineage arts `song`, so that modifiers like
  `x_soul 4 [song]` and `art_speed_pct 8 [song]` can be scoped to music.
- **Where it would live**: the tag registry; the bases note on `cam` already asks for a [music] form tag.
- **Fun**: a funeral drum and a zither in one set that make each other faster.
- **Who needs it**: `lien_thieu_nghi`, `chuc_hieu_nghi` (Phượng Minh); `co_ky_am`, `ly_han_bich` (Thu Phần);
  `ham_tan_chung` (demonic group).
- **Why**: Their sets scope soul damage to [soul] or leave it unscoped. That also feeds soul arts that are not songs.
  The grave-chorus wish in `wishlist-targets-tp.md` uses the same tag.

## light-pipe-art

- **Name**: Dawn Call (Thần Khiếu)
- **Kind**: Art (on the pipe, for a Light root).
- **Rule or line**: A soul art played on a pipe that deals Light damage. Every third cast lays Exposed. It needs a
  Light variant in the root.
- **Where it would live**: an art on the Dawn-Call Pipe (`pm-dawn-call-pipe`), or a Light branch of the Red Sun
  Scripture.
- **Fun**: the only Light in the palace finds a way to play it.
- **Who needs it**: `chuc_hieu_nghi` (Phượng Minh Cung).
- **Why**: Her set adds Exposed to every fifth soul art on the pipe as a stand-in. Phượng Minh's lineage has no Light
  art, and she cannot read the Light she has.
