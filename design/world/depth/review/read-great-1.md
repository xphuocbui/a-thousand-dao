# Content review: read-great-1 (bang_tam, thuy_vi, tung_dao, lac_ha)

Reader: read-great-1, 2026-11-25. Read whole: the four sect pages. Read: every tier A person (37 living, 5 dead
founders and elders). Sampled: about 10 B and 10-13 C per sect across `.cast`, `.2`, `.3`, `.4`. Checked by script
(scratchpad, counts below): all 483 people in the four sects for traits, ties, gates, master ages and gear; all
four items files for terrain, time and cap conditions.

## Verdict

This slice answers the user's first complaint. Every living member of the four sects passes their sect's gate element
(0 failures in 461), three seats move onto fitting land with a story, and the pages explain where each root comes
from. Tier A is good: about 176 words each, specific, often tied across sects, each with its own gear. The weak
parts are below tier A and in the shape of the stories. Tier B has no wants or secrets (0 of 63), and tier C has no
appearance (0 of 361). The four pages run the pilot's skeleton with the names changed. Nearly every secret has the
same shape. Nobody is cruel. And there are about ten continuity errors that a player would catch.

## The weakest items, worst first

### 1. The four pages are the pilot's skeleton with new names (must-fix)

Where: section 9 of `bang_tam.md`, `thuy_vi.md`, `tung_dao.md`, `lac_ha.md`; the founders' and elders' cast records.

What is wrong: the same beats come back in every sect, and some come back with the same numbers.
- The founder founds at 140 (Tần, Phùng, Nhan) or at 130 (Kỳ). That is 4 of 4.
- The grand elder stays on the founder's high ground out of loyalty to the founder. Cố Lăng Sương and Cù Thúy Bách
  are **both born in 560**, both were the founder's senior disciple for about 400 years, and both stepped away at a
  succession around 1000-1010.
- Both founders hid the truth from their two heirs: Tần "told neither"; Ngu and Cù keep "one secret, kept twice".
- An unnamed heir, with the sect split by geography (seat against coast, slope against ridge, Shade against Root,
  mountain against plain). That is 4 of 4, and Lạc Hà repeats the pilot's words ("has named no one").
- An elder on a lifespan clock: Tiết 440 and Phó 480; Uông 198 and Diêm with about 80 years left; Hồ 400 and Cận
  440; Bồ 480. That is seven people in four sects, and **Tiết and Cận are both born in 760**.
- A set piece lost or held apart: the red plum, the Seed Gourd, the Kình Nha sabre, the quay lantern, the Lone Duck
  Ring, Thanh Sương.

Fix: keep one of each beat per two sects, and give the other sect something its own doctrine makes.
- **Founding ages:** Phùng founds Thúy Vi at **60**, a painter's daughter who walked in young and impatient, which
  sharpens the slow-growth doctrine she wrote later. Nhan Cô Vụ founds at **410**, a loose cultivator who has given up
  climbing and "sits down to watch the sun go down". Kỳ stays at 130 and Tần at 140.
- **Grand elders:** move Cù Thúy Bách's birth to **610**. Change "Phùng took her in 576, the first disciple she ever
  took" to "the first ridge child to survive three winters in the founder's school". As written, the founder takes
  her first disciple 76 years after founding a sect.
- **Clocks:** take the clock off Hồ Tùng Nguyệt and Cận Tùng Hàn. Hồ's century is not urgent anyway: make her
  "late Kết Đan, healthy" and let her spying be for the canon alone. Cận's fear is already about the songs dying, not
  about his own death. Move Cận's birth to 820 and remove `waning_years`.
- **Lạc Hà heir:** cut the "The heir" bullet in §9. Use the debt instead. To repay Thiên Bảo, the head means to sell
  thirty outer disciples' Placement Day contracts to Thiên Bảo Trai in one lot. Hách Ánh Hà is negotiating the price,
  and Tô Bình Chu must sign the placements, including his own son Tô Hiểu Chu's. This is a merchant sect's crisis, not
  the pilot's.

### 2. Founders die of "old age" 200-400 years before the Nguyên Anh cap (must-fix)

Where: `bang_tam.cast.json` `tan_ngung_suong` (cause "old age at 710"); `lac_ha.cast.json` `nhan_co_vu` ("old age
at 790"); `thuy_vi.cast.json` `phung_yen_ha` ("old age at 640").

What is wrong: the Nguyên Anh lifespan cap is 1,000 (`canh-gioi.md` rule 14). Living Nguyên Anh in the same files are
older than these founders were: Đàm Tùng Lại is 680 "with three centuries left", and Cố and Cù are both 640. Kỳ Tùng
Ẩn (620) is explained by Thôi's secret: a cracked core from 508. Phùng's page explains her death (the Metal ground),
but her `cause` field does not.

Fix:
- Tần: cause → "spent her lifespan into the Jade Vessel Array as its last node (1010)". This is also why she lies
  inside it, and why the Array is weakening now.
- Nhan Cô Vụ: cause → "lifespan burned by the rot array of 802, which drew on its maker; died on Tịch Chiếu Đảo at
  790". This ties his death to the secret he already carries.
- Phùng: cause → "lifespan worn down on Metal ground (the ridge); died at 640".

### 3. Kỳ Tùng Ẩn "spent his first century alone" and took a disciple at 26 (must-fix)

Where: `tung_dao.cast.json` `ky_tung_an` (born 70) and `thoi_khinh_hong` (born 80; "at sixteen she followed a
hermit", which is the year 96).

What is wrong: Kỳ is 26 when Thôi follows him, so his first century was not spent alone. Their master gap is 10
years, the smallest of any master pair in the slice.

Fix: Kỳ born **−40** in the Wild Age, so he founds the sect in 200 at **240** and dies in 690 at **730**. That still
fits the wound story. Then "At sixteen she followed a hermit who had already listened to the pines for a hundred and
thirty years."

### 4. Tiết Hàn Mai lays the Array's last nodes in the year she is born (must-fix)

Where: `bang_tam.cast.json` `tiet_han_mai` (born 760; "In 760 she and Cố Lăng Sương laid the Array's last nodes"),
and the tie note in `co_lang_suong` ("they laid the Array's last nodes together in 760").

Fix: both texts → "In **820** she and Cố Lăng Sương laid the Array's last nodes, sixty years after the Ice Soul vein
was opened (A106)." Leave her age (440) alone; the pill story depends on it.

### 5. Liễu Ngư Ca's "hidden" line has been carrying the conquered head's surname for 700 years (must-fix)

Where: `bang_tam.cast.json` `lieu_ngu_ca` and the `lieu_co_chu` tie ("seven generations back").

What is wrong: the Pavilion took the coast from Liễu Cô Chu in 498, and his line has been "secretly" called Liễu in
the conquered town ever since. Also, seven generations in 700 years is 100 years a generation for a family of mortal
fishers.

Fix: "...they are the line of Liễu Cô Chu, who took their mothers' surname, Liễu, back only in his grandmother's
time, when no one alive at the seat remembered what it meant". Change the tie to "his ancestor, Hàn Giang's last head
(twenty-six generations back)". Better still: rename him **Mạnh Ngư Ca** and keep Liễu as the secret. His sister
`lieu_thoa_nhi` and cousin `lieu_tieu_giang` then need the same change.

### 6. A living man is "under the ice" (must-fix)

Where: `tung_dao.2.cast.json` `xa_trong_son`, tie to `lo_thanh_xuyen`: "his tent-mate, under the ice". The reverse
tie, in `lo_thanh_xuyen`, reads "under the ice with him".

What is wrong: Xa Trọng Sơn is the seventh man, the one who stayed behind with fever. A back-link copied the dead
man's note onto the living one.

Fix: `xa_trong_son` → `lo_thanh_xuyen`: "his tent-mate; he lent him his coat for the ice and kept the fever".
`lo_thanh_xuyen` → `xa_trong_son`: "his tent-mate, left behind with a fever".

### 7. Hướng Dạ Đăng's living son is called "late" (must-fix)

Where: `thuy_vi.cast.json` `huong_da_dang`, tie to `huong_tieu_lam`: "his late son, who would rather fish".

What is wrong: Hướng Tiểu Lâm is a living outer disciple. "Late son" reads as dead.

Fix: "his younger son, born late, who would rather fish than fight".

### 8. Tier B people have no wants and no secrets; tier C people have no faces (should-fix)

Where: all B records in the slice (0 of 63 with `wants` or `secret`) and all C records (0 of 361 with `appearance`;
43 C with no `gloss`, mostly in `tung_dao.2`/`.3`).

What is wrong: the B tier holds the people the hooks run on: Xa Trọng Sơn, Lộ Thu Hà, Tề Tử Tô, Khang Tẩy Kim,
Nhiếp Ngọc Âm, Tất Hành Vụ, Bồ Tàn Chiếu. Their wants and secrets are buried in the prose, where no system can read
them. The first consumer of `opens` is dialogue (DECISIONS group 5), so empty fields mean silent people.

Fix: lift each B's want and secret out of their backstory. Examples:
- `xa_trong_son`: wants "to be sober once on the dusk his tent-mate's name is sung"; secret "he heard the order read
  and saw whose seal it carried".
- `te_tu_to`: wants "a wound pill that rots the wound before it closes it"; secret "Kiển Viễn Chí is her son, and she
  reads the Rotting Canopy Canon".
- `bo_tan_chieu`: wants "to choose who rows him"; secret "he saw Cảnh come home with the body and without the
  sword".

For C, one line of appearance each is enough.

### 9. Almost every tier A secret is "X hides Y from Z" (should-fix)

Where: the `secret` fields of the 33 living tier A people.

What is wrong: about 30 of the 33 are "he has told no one", "she does not know he knows" or "has never said".
Only a few secrets are an act in progress: Vi Thanh Âm writing the canon, Thẩm's two tax books, Trầm buying the
debt, Quách paying the outer ring. Some are not secrets of the holder at all. Đàm Thanh Giang's secret is "he does not
know what lies under the ice".

Fix: turn the weakest into acts.
- `dam_thanh_giang`: "Since 1190 he has brewed the Coiled Root Hall's winter wound pills one grade weak, so that no
  patrol he heals can hold out a night on the river-mouth ice."
- `so_han_y`: "She has followed the Keeper and Tiết Hàn Mai under the seat for three winters and learned eleven of
  the 108 nodes by touch, more than anyone alive but Tiết." This also answers Tiết's want for "a disciple careful
  enough".
- `to_mo_van`: "The lines she learned tell the reader to pay. Each new moon since 1195 she has cut her palm on the
  gallery carving, and her 'perfect' foundation is the stone's doing." This feeds hook 5 ("someone has been
  paying").

### 10. Nobody is cruel, and the dark deeds carry kind traits (should-fix)

Where: traits across the slice. Cruel appears 0 times in 483 people, Callous 7 (six of them C, plus one dead
governor), Faithless 1. Specific mismatches:
- `can_tung_han` is "Diligent, Stubborn, Honest", and he listened to forty people drown for an hour without opening
  the array.
- `nhan_co_vu` is "Reclusive, Patient, Generous", and he buried a rot array that killed ten thousand.
- `canh_truong_thien` is "Diligent, Just, Peaceable", and he has lied to the sect for 397 years.

Also, flaws keep turning out to be hidden virtue:
- Trầm's greed is a plan to tear up the notes.
- Cố's "bitterness" is obedience.
- Thiệu planted moss to lose on purpose.
- Phù Liên Kiều the spy is "learning to be honest with himself".

Fix:
- Cận: Honest → **Callous**.
- Nhan Cô Vụ: Generous → **Ruthless**, or **Callous** if no Ruthless row exists.
- Cảnh: Peaceable → **Craven**, or Deceitful.
- Let at least one A in each sect keep a flaw with no redemption behind it. Example: drop the last sentence of
  Trầm's secret ("He means to tear the notes up..."), so the reader cannot tell whether he means to save the sect or
  own it.

### 11. Ties are mostly "friend", often blank, and often copied from the other person's role (should-fix)

Where: the slice has 1,923 ties.
- friend: 702 (37 %)
- master and disciple: 667 (35 %)
- lover: 5, spouse: 4, dao_partner: 6, feud: 1
- blank notes: 330
- at least 84 notes that are just the target's role string (e.g. `ta_ngan_suong` → `hoa_tuyet_nghi`: "Tạ Ngân
  Sương's disciple", a note about herself)
- 45 people with the same target listed twice

Wrong kinds:
- `pho_am_huong` → `nhiep_tan_sa` is `creditor` for his father's killer; should be `feud`.
- `lo_xuong_van` → `chau_phi_van` is `enemy` for the woman whose talismans he used.
- `dinh_lao_hoe` → `cu_tung_gian` is `niece_nephew`, but the note says "his mother's brother".
- `lo_xuong_van` calls his own grandson "her son, his disciple".

Fix: one pass over the back-link waves (`.4` files and the ties they appended). Write each note from the holder's
side, collapse duplicate targets, and replace role-string notes with one fact about the pair. In 461 living people
there are only 4 marriages. Add families where the stories already imply them, e.g. Hướng Dạ Đăng's drowned wife
(1180) as a dead `spouse`, and Cảnh and Bồ Tàn Chiếu as sworn brothers of 803.

### 12. Sở Ngọc Hồ is a sword cultivator with no sword (should-fix)

Where: `bang_tam.cast.json` `so_ngoc_ho` build (`archetype: kiem_tu`; gear is the vessel, a seal and a ring).
Others in the slice:
- `thuy_vi.cast.json` `quyen_thanh_lam` is `dan_su`, but his intent is "Earth guard and body shield" and his aux is
  the Mountain Bone Body Art.
- `lac_ha.cast.json` `vuu_chuoc_kim` is `phap_tu`, with a hammer and an iron-hide body art.

Fix:
- Sở Ngọc Hồ → `tran_su` or `phap_tu`. Her note already describes a ward stance, not cuts. Or give her the founder's
  sword and make the Vessel her off-hand.
- Quyền → `the_tu`.
- Vưu → `the_tu`.

### 13. Two retired v1 fates are still on record (should-fix)

Where: `lac_ha.3.cast.json` `to_mo_van` (`fate_given: Wise-born`, no talent); `thuy_vi.2.cast.json` `kien_vien_chi`
(`Heaven-favoured`).

What is wrong: `npc-traits-catalogue.md` retires both (Wise-born → `quick_minded` 3, Heaven-favoured → `lucky` 3;
ruling group 5).

Fix: `to_mo_van` talent `[{quick_minded, 3}]`, fate `[]`. `kien_vien_chi` add `{lucky, 3}` and clear the fate. He
already has quick_minded 3.

### 14. Name collisions and a wrong vassal name (should-fix)

- **Lãnh Hương Các** (Băng Tâm's fallen plum-sword house, V071) and **Lãnh Hương Viện** (Tùng Đào's incense academy,
  V004) share a name in the chronicle. No page notices. Fix by connecting them, not renaming: Lãnh Hương Viện was the
  plum riders' sister house, where their families made the incense the riders burned before battle. Lịch Hương Trầm's
  grandmother was Phó Thanh Mai's cousin. Add a tie `pho_am_huong` ↔ `lich_huong_tram` (`cousin`: "the only kin he
  has left; she sends a plum-scented stick on the day Cô Thành fell"). That turns a collision into a link between
  two grudge-bound sects.
- Lạc Hà's cast calls the vassal **"Nhạn Văn"** 7 times (`lac_ha.cast.json` ties of `hach_anh_ha`, `lan_vien_pham`,
  and three more; `lac_ha.2.cast.json` 4 ties). The data and the page say **Nhàn Vân Quán**. Replace all.
- There are two plum-blossom sword lineages in neighbouring northern sects: Băng Tâm's Snow Plum and Tùng Đào's vassal
  Ngạo Tuyết Phái, "the plum sword". Make Ngạo Tuyết's art something else (an ice-cliff spear, given its name), or say
  it is a Lãnh Hương offshoot.
- Both hired Fire craftsmen are named **Chước (灼)**: Viên Chước (Băng Tâm) and Vưu Chước Kim (Lạc Hà). Rename Vưu to
  **Vưu Đoán Kim (鍛金, "forges gold")**.

### 15. Lạc Hà moves its Earth seat onto ground where Metal outweighs Earth (should-fix)

Where: `lac_ha.md` §2. The new seat (558) is Earth 26, Wood 21, **Metal 27**; the old seat is Earth 45.

What is wrong: the sect's inner gate is Earth 45, and children born at the new seat will lean Metal. The page says so
("breeds Earth and Metal") but never weighs it against Hào Trư Lĩnh (Earth 29, Wood 30). It passes R4 only because
Earth is in the top two.

Fix: add one sentence to the move's rationale: "The mountain breeds Metal, so the inner gate will still be filled from
the steppe; the head accepts that, because the canon needs Wood more than the children need Earth, and because the
gallery is here." Or record the Hào Trư Lĩnh comparison and why the strait rules it out.

### 16. Smaller continuity errors (should-fix)

- `tung_dao.cast.json` `dam_tung_lai` → `ngu_lam_son`: "who took the Cold Ford back from him in 905". Ngu was a Kết
  Đan pill-carrier then, and Phùng took the ford back. Fix: "Thúy Vi's head since 1000, whose founder took the
  Cold Ford back from him in 905; he sends tea".
- `bang_tam.cast.json` `khuong_luu_ly`: "She has waited 250 years for her master to name her". Her master became head
  in 1010, 190 years ago. Fix: "190 years".
- `tung_dao.cast.json` `dich_kinh_lam`: "was told the order came from the head". But Xa Trọng Sơn heard Địch *read*
  the order aloud, under the Root Hall's seal. Fix: "He read the order aloud by the reed-camp fire and did not look
  at the seal; he has started to look now."
- `thuy_vi.cast.json` `uy_thanh_diem`: "four centuries of tasting pills". He started in 900, so fix to "three
  centuries".

### 17. Thin wording in the pilot itself (nice-to-have)

- `pho_am_huong`: "and so will Tiết Hàn Mai" should be "and neither will Tiết Hàn Mai".
- `khuong_luu_ly`: "She took half of a single element and drove it to the bottom; the only thing in her root is Water
  and Ice" should be "Her root is Water and Ice and nothing else, and she has driven both to the bottom."
- `pho_thanh_mai`: "sewed the Snow Plum manual into his son's cape", but his son's record says it was the father's own
  cape. Pick "his own cape".
- `lieu_ngu_ca` has `lifestyle: qin_player` while his look says he sings fishermen's songs badly. Make it `singer`, or
  `drinker` like his master.

### 18. Name glosses lean on famous lines (nice-to-have)

- `thoi_khinh_hong` is 崔**輕**鴻, but the gloss cites 翩若**驚**鴻 (Lạc Thần Phú). Her own art is 驚鴻步, so the name
  and the quote disagree. Make the gloss "Light as a wild goose" and drop the quote, or rename her **Kinh Hồng**.
- `thieu_lang_ba`'s gloss cites "lăng ba vi bộ". The line is Cao Zhi's, but players know it as Kim Dung's martial art.
  Cut the citation from the gloss.
- Tùng Đào takes three names from the one fu: Khinh Hồng, Lăng Ba, and the Kinh Hồng Du Long set. Lạc Hà takes five
  from the one line of Vương Bột: Cô Vụ, Tề Phi, Trường Thiên, Thu Thủy, and Tử Điện / Thanh Sương. That works once
  per sect, but it reads as a pattern once you notice it.

### 19. One image claimed by four people (nice-to-have)

Where: Lữ Tẫn Chu fishing nails at Đào Sa. Four people fished the nails with him: Lô Xướng Vãn in the event, plus
`mao_dinh_lang`, `thach_thap_dinh` and `dang_hoanh_giang` in later ties.

Fix: keep Lô Xướng Vãn and one boy (`thach_thap_dinh`). Re-note the other two, e.g. Đặng Hoành Giang → "the River Hall
man who rowed the Đào Sa orphans across to Lạc Hà's side and has wondered since".

## Patterns across the slice (counts)

- **Gates hold:** 0 of 461 living members fail their sect's gate element (Ice for Băng Tâm's inner ranks; Wood 45 for
  Thúy Vi and Tùng Đào; Earth 45 for Lạc Hà), with exceptions recorded. The user's root complaint is answered here.
- **Rulings hold:** 0 terrain, weather, place or time-of-day conditions in the four items files' Effects and set
  rules. The one seasonal rule (`td-pine-heart-censer`, cultivation that season) is allowed. Lạc Hà's dusk practice is
  marked as custom, not rule.
- **Pilot beats:**
  - Founder founding at 130-140: 4 of 4.
  - Geography-split succession: 4 of 4.
  - Elder on a lifespan clock: 7 people in 4 sects.
  - "Last of a fallen house or line": 8 people (Phó, Liễu, Quản Ảnh Hồ, Âu Dương Tân Di, Dư Tục Đoạn, Bạc Hải Âm,
    Dụ Tĩnh Lưu, Giang Vọng Phàm).
  - A forbidden or demonic art in secret: 4 of 4 (Cung and Triệu Huyết Y, Tề Tử Tô's canon, Khang Tẩy Kim's debt to
    Triệu, the head's blood-debt gallery).
  - Hired guest craftsman to cover the element gap: 3 of 4. Tùng Đào refuses guests on doctrine, which is good.
  - Regalia of three with a piece held apart: 3 of 4.
  - A lost piece to recover: 4 of 4.
- **Same template phrases:** "The sect's one teaching" in all four doctrine sections; "the ground holds two or three
  peoples" in all four §2; "quiet prejudice" twice.
- **Secrets:** about 30 of 33 living tier A are a withheld fact; about 4 are an act in progress.
- **Traits:** top Diligent 124, Brave 109, Gregarious 101, Honest 98; Cruel 0, Faithless 1, Arbitrary 1, Callous 7.
  Tier A with any dark trait: about 10 of 42.
- **Depth by tier:**
  - A: about 176-word stories, 11.4 ties each, wants and secrets present.
  - B: about 83 words, 7.4 ties, no wants or secrets.
  - C: about 31 words, 2.6 ties, no appearance.
- **Ties:** 37 % friend, 17 % blank, at least 84 role-string notes, 45 duplicate targets, 4 marriages in 461 living
  people.
- **Voice tics** are lower here than in the global counts ("has never" 29, "has not" 39, "for forty years" 8 in 483).
  The registers do differ: Lạc Hà prices and counts, Tùng Đào listens and chants, Thúy Vi grows. But the sentence
  shape is the same everywhere: short declaratives ending in a withheld truth.

## The best items (a short reading list)

1. **The six under the ice.** Spread across `thuy_vi.cast.json` `huong_da_dang`, `thuy_vi.2` `huong_van_chu`,
   `tung_dao.cast.json` `nhiep_co_tan`, `tung_dao.2` `nhiep_van_dao` and `xa_trong_son`, and `lo_thu_ha`, and both §9s.
   Two boys from two doors apart on one quay in 881 end up commanding the opposite banks. One sent six men onto the
   ice without leave; the other drowned them. A mother sings a forbidden name each night, and the lovers meet over the
   bodies. It is cross-sect, harsh, and cited to events. This is the world being connected.
2. **Vi Thanh Âm writing the unwritten canon** (`tung_dao.cast.json`, `tung_dao.md` §4 and §9). The secret is an act.
   It comes straight out of the sect's doctrine (khẩu truyền) and its own chronicle loss (N-tung_dao-05). The heir
   commits the sect's gravest taboo to save it.
3. **Cảnh Trường Thiên and the rot array** (`lac_ha.cast.json` `canh_truong_thien`, `nhan_co_vu`, `lac_ha.md` §9).
   Lạc Hà poisoned its own field, the war elder dropped the sword and ran, the empty scabbard is his set piece, and the
   only witness has twenty years left. The history is dark and the items carry it.
4. **Lữ Tẫn Chu** (`lac_ha.2.cast.json`). He was raised by the man who burned his father's boat, he grinds his needles
   from the nails, and he has just learned that the order was the head's. His build, items and set all come out of the
   story (fix item 19).
5. **Thúy Vi's land logic** (`thuy_vi.md` §2 and §9; `cu_thuy_bach`, `hoan_co_bach`, `la_trac_thach`). Metal ground
   starves a Wood founder. The ridge breeds Metal-streaked children who become the Cliff Hall. The champion is secretly
   afraid of the haze. Roots, land and story all answer one another. This is the user's first complaint answered
   properly.
