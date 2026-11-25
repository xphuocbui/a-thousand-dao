# Wishlist: sets-tl (personal item sets for Tùng Đào, Lạc Hà and their vassals)

What the personal sets of this batch (`_brief-cast-sets.md`) wanted and could not find. Each set uses the closest
existing lines for now. Proposals for the user's review; nothing is added to the item catalogue, `effects.md`, the
Modifier System or the tree.

## sets-tl/bow-and-staff-bases

- **Name**: Bow (Cung) and Staff (Côn)
- **Kind**: Item (two new item bases)
- **Rule or line**: a Bow base (weapon, Physical, `tags: [physical]`, a common art like `pinning-arrow`) and a Staff
  base (weapon, Physical, heavier and slower, a common sweep art), with the same fields as `design/items/bases.json`.
- **Where it would live**: `design/items/bases.json`, then the blade or body catalogue.
- **Fun**: the warden holds the road with the staff all night and shoots the pack's leader at dawn; two weapons, one
  canon.
- **Who needs it**: `hua_van_cung` (tuan_tung), and every warden of Tuần Tùng Đường whose canon is "staff and bow".
- **Why**: the Wolf-Winter Bow (`ttg-wolf-winter-bow`) is written with `base: null` because no bow base exists, and the
  wardens' staff has no base at all, so the Three Nights set pairs the bow with a coat instead of a staff.

## sets-tl/one-slot-pair

- **Name**: Carried Pair (Đới Song)
- **Kind**: Other (Item DB set rule)
- **Rule or line**: a Luyện Khí holder (one gear slot) who wears one piece of a two-piece personal set and carries the
  other gets the set's 2-piece bonus at half strength; the full bonus comes when they reach Trúc Cơ and can wear both.
- **Where it would live**: the R7 set rule.
- **Fun**: a prodigy's set grows into itself at her foundation, which is a moment the player can watch for.
- **Who needs it**: `to_mo_van` (lac_ha), Prize and Brush (`lh-prize-and-brush`).
- **Why**: the brief asks for a two-piece set for Luyện Khí people, but a Luyện Khí person wears one piece (`1 + realm
  index`) and the checker wants exactly one. She wears the Crane Shoal Seal and holds the Evening-Glow Brush.

## sets-tl/heal-store

- **Name**: Banked Healing (Tàng Liệu)
- **Kind**: Effect (an engine: two pieces that feed each other)
- **Rule or line**: healing you would grant is stored instead, up to a cap (30 % of maximum health); a trigger you
  choose spends the whole store at once on every ally. The store is a new resource the fight screen must show.
- **Where it would live**: the full-set Effect of The Dusk Field (`yq-dusk-field`), which now writes the rule by hand;
  later perhaps a Wood keystone beside Sun and Rain.
- **Fun**: a whole fight of held-back mending, then one wave that stands the line back up.
- **Who needs it**: `diem_tu_to` (yen_quang).
- **Why**: the Cold Furnace's own Effect doubles heal-over-time for 10 s; the Gathered Haze canon "holds the haze all
  night". Nothing in the rules stores healing as a quantity, so the set Effect has to invent it.

## sets-tl/companion-thread

- **Name**: One Thread of Wind (Nhất Tuyến Phong)
- **Kind**: Effect, plus a Modifier: `companion_khi_huyet_pct` (new stat, unscoped)
- **Rule or line**: the holder and a bonded companion share one thread: damage either takes is split between them, and
  joint strikes heal both. The modifier gives the companion more health.
- **Where it would live**: a Mục Vân technique (a herd-call secret art) or a Wind-land notable; the set now has only
  the joint-strike heal.
- **Fun**: the horse lord and his horse as one fighter: he keeps it alive by standing in front of it, and it him.
- **Who needs it**: `khau_muc_van` (muc_van), Horse Lord of the Plain (`mv-horse-lord`); his secret (Đạp Vân failing)
  wants a rule where the horse's health is his to guard.
- **Why**: Pack Hunt (Packmate Collar) and the Cloud-Herding Lance raise companion damage only; there is no companion
  health stat and no damage-sharing rule with a beast.

## sets-tl/paint-back

- **Name**: The Sky of a Moment Ago (Tiền Khắc Thiên), for the holder
- **Kind**: Effect (new rule kind: a short record of recent losses)
- **Rule or line**: the fight keeps a 3 s record of the health and linh lực the holder lost; once a fight a trigger
  restores it.
- **Where it would live**: the full-set Effect of The Idle Cloud (`nv-idle-cloud`), written by hand now; the
  old-reflection-art lineage could give it as an art.
- **Fun**: the painter is cut down, and the brush paints the last three seconds out of the pool.
- **Who needs it**: `diep_to_quyen` (nhan_van).
- **Why**: no rule reads "what happened in the last few seconds"; the nearest are death-saves (the Grown Red Pearl, Last
  Blossom), which stop a blow instead of undoing one.

## sets-tl/two-halves

- **Name**: The Whole Couplet (Toàn Liên)
- **Kind**: Art, plus a set rule (sets that answer across holders)
- **Rule or line**: when the Dawn Half (`np-dawn-half`) and the Dusk Half (`np-dusk-half`) are both worn whole by two
  allies in one fight, either may cast the whole Painted Beams talisman: dawn binds and seeds, dusk washes and heals,
  in one sheet. The same rule could pair The Crossing and Slack Water (`bth-the-crossing`, `bth-slack-water`) for the
  Bình Thủy lovers.
- **Where it would live**: an art in `painted-beams-dawn-flight` (nam_pho), unlocked by the two sets; the R7 set rule
  for "answering sets".
- **Fun**: the hall-mistress and her rival must stand together to paint the founders' talisman; succession becomes a
  fight-screen question.
- **Who needs it**: `chau_phi_van`, `kha_trieu_phi` (nam_pho); `bui_phieu_binh`, `luong_bach_tan` (binh_thuy).
- **Why**: R7 sets only count pieces one person wears. The founders' art is written in two halves, and Châu "wants to
  paint the whole Painted Beams talisman once".

## sets-tl/lost-pieces

- **Name**: Bring It Home (Quy Bảo)
- **Kind**: Other (quest hook for set pieces held by no one)
- **Rule or line**: a set piece with `holder: null` and a `where` becomes a findable quest target; returning it to a
  holder of the rest of the set completes the set and moves the holder's opinion of the finder.
- **Where it would live**: the quest/missions system (Thiên Kiếp rewards wait on it too).
- **Fun**: completing a person's set by your own hand is a gift no stone can buy.
- **Who needs it**: `nhiep_co_tan` (the Cold Ford lantern, `td-ford-governor-lantern`, under Hàn Tân's quay stones);
  `to_van_chieu` (Thanh Sương, `lh-thanh-suong`, on Chiết Kích Nguyên; and the Lone Duck Ring in Thiên Bảo Trai's vault).
- **Why**: two sets in this batch are whole only with a lost piece; nothing yet says how a lost piece is found.

## Existing wishes these sets lean on

- `targets-tl/geese-line`: What Came Off the Field (`lh-off-the-field`, `canh_truong_thien`) and Out of the Grey
  (`nt-out-of-the-grey`, `muc_han_nhan`) write share-the-damage rules by hand in their full-set Effects.
- `targets-tl/debt-stone`: Nails of Đào Sa (`lh-nails-of-dao-sa`, `lu_tan_chu`) and Debt and Wall (`lh-debt-and-wall`,
  `tram_tich_duong`) carry the reprisal idea in set Effects.
- `targets-tl/metal-stacks`: Pendant and Bell (`ml-pendant-and-bell`, `yen_boi_ngoc`) and Bridge Bells
  (`ml-bridge-bells`, `tham_huong_nhi`) lay Metal stacks by ringing.
- `targets-tl/wood-talisman`: The Dawn Half (`np-dawn-half`, `chau_phi_van`) and Lamp and Brush (`st-lamp-and-brush`,
  `van_han_dang`) use Wood talisman lines that the tree does not have yet.
