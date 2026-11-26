# Vân Khởi Quán (雲起觀), the Abbey Where the Clouds Rise

> **Status**: World-depth pass, 2026-11-25 (minor sect writer, Thúy Vi's vassals). Proposal: nothing here is in game
> data. Rules: `../rules-proposals.md` R1-R8. People: `van_khoi.cast.json`; công pháp: `van_khoi.techniques.json`;
> items: `van_khoi.items.json`. Lord's page: `thuy_vi.md`.

## 1. At a glance

| | |
|---|---|
| Kind | Minor sect, vassal of Thúy Vi Tông (loyalty 65), righteous (chính), founded 540 |
| Leans | Earth, Wood → **none** (R3: an abbey that takes anyone with a Dao heart) |
| Lineage elements | none: element-free walking, sitting, soul and seal methods |
| Seat | **stays** at Vân Khởi Quán (place 10), high on the Metal heights above Thúy Vi's old ridge |
| Head | Tống Tọa Vân, Nguyên Anh, abbot and founder, 780 years old |
| Size | about 40 monks, novices and lay brothers; 12 living named here |
| Way of life | a Daoist abbey (đạo quán) of hermits and teachers; a school for the mountain's turned-away children |

A wooden abbey with mica windows on a bare grey shoulder of mountain at 0.88 km, under the peak where the water ends. It owns almost nothing. It has a school, a mine that is running out, a bell, and the oldest abbot in the
north. Each morning the monks walk up one of the hill streams until it stops, then sit and watch the clouds come up off the slopes
below. They take anyone who can sit. They are mostly the children Thúy Vi's gate turned away, and they keep a promise
to a dead man that their lord does not know about.

## 2. Land and seat

**Decision (R3/R4): stay, and become no-lean.** The seat's qi is Metal 48 %, Wood 17 %, Earth 15 %, and the abbey's
heights are all alike: Vân Mẫu Khoáng (166) 47 % Metal, Thủy Cùng Phong (1492) 38 %, Hàm Vân Phong (1136) 40 %. The old
lean of Earth then Wood fails, because Earth is nowhere near 25 % on Thúy Vi's ground and never passes 24 %. The audit
has no candidate. Moving to the forest would put the abbey in its lord's lap at Cổ Dịch Trấn (1110) or on its herb
terraces (1109), and would take it away from the water's end, which is the reason it is here. A Metal re-lean would fit
the rock and turn away the abbot, whose root is Earth and Wood. The abbey's method never ran on an element anyway. It
runs on sitting still, and Tống Tọa Vân taught it to anyone who climbed. The rules now say so. Nothing moves.

**What it costs.** Data only: `leans` becomes `[]` in `world_continent.json` (minor_sects) and the start state, and
the lineage lists no elements. The abbot's build changes from the generated `dia_moc` to the abbey's own canon. The place,
art, routes, province and density stay as they are (the seat is on the road, density 1.70).

**How the land shapes its people (R1).** In a no-lean abbey roots matter only to each monk's own Đạo Đồ start. The
heights breed Metal (the mica and inkstone miners' children: Văn Nhân Hưởng, Thông Vân Thạch, Thọ U Hoàng). The pine
villages below breed Metal-Earth (Tùng Yên Thôn 1143: Wood 32 %, Metal 24 %). Bách Diệp Trấn's school sends Water
roots. Thúy Vi's turned-away children bring the rest: Metal from the old ridge (Kha Thủy Cùng, Cừ Tùng Gian) and Earth
from the lime villages (Nông Bạch Thạch). The abbey is where the ridge's children go when the slope says no. Recruits
are chosen by **Dao heart** (đạo tâm): a child is walked to the water's end and left to sit, and the abbey takes those
who are still there at dusk.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 190 | Không Sơn Viện asks the woodcutters below to sing more quietly; Tiều Ca Trấn is founded | A033 |
| 429 | A woodcutter's boy, Tống Tọa Vân, carries wood up to the academy and stays to sweep | **N-van_khoi-01** |
| 460 | Thôi Bất Kiến takes him as his only disciple | C094 |
| 488-499 | Bão Nhất Quán's spring dries; its last abbot comes to Không Sơn as a guest and teaches Tống the Rule | V022 |
| 500 | The Gift of the Empty Mountain: Tống is given to Phùng Yên Hà with the hills and the whisk | C100 |
| 520 | Thôi dies; Tống promises him the mountain will keep its voices; the first reading | A038, **N-van_khoi-02** |
| 540 | Tống walks up the stream until the water ends and founds Vân Khởi Quán where he sits | C114 |
| 560 | The mica mine is opened; the monks say the stone is cloud made solid | A039 |
| 830 | Thúy Vi seals the stone gate on the ridge; the readers find the crack behind it | A043, **N-van_khoi-03** |
| 1019 | The prior Mâu Hành Đáo dies in the second slide at Vân Gian Trấn | V031, **N-van_khoi-04** |
| 1080 | The mica runs thin; "clouds, too, pass" | A046 |
| 1151 | Nông Bạch Thạch, turned away by Thúy Vi's inner gate, walks up; the school takes its first Thúy Vi rejects in numbers | **N-van_khoi-05** |
| 1180 | Văn Nhân Hưởng becomes the Reader | **N-van_khoi-06** |
| 1195 | A traveller in the empty academy hears someone reading aloud | A048 |

**New chronicle proposals:**
- **N-van_khoi-01** (429, `tale`): "A woodcutter's boy of Tiều Ca Trấn carries a load of wood up to Không Sơn Viện and
  does not come down; the academy sets him to sweeping."
- **N-van_khoi-02** (520, `custom`): "On the night Thôi Bất Kiến dies, his student reads aloud in the empty academy until
  dawn, and promises that the mountain will keep its voices."
- **N-van_khoi-03** (830, `tale`): "The year Thúy Vi seals the stone gate on the ridge, the abbey's reader finds another
  way in, through the haze."
- **N-van_khoi-04** (1019, `death`): "Mâu Hành Đáo, prior of Vân Khởi Quán, comes down to dig at Vân Gian Trấn and is
  taken by the second slide."
- **N-van_khoi-05** (1151, `custom`): "Vân Khởi Quán's prior says the abbey will take any child Thúy Vi's gate turns
  away, if they can sit until dusk."
- **N-van_khoi-06** (1180, `custom`): "The abbot gives the bell of the empty hall to a mica-miner's daughter."

## 4. Doctrine and customs

- **Walk to where the water ends, then sit.** The abbey's teaching is the founder's name and Vương Duy's couplet: walk
  until the water ends, then sit and watch the clouds rise. Effort is for walking. When there is nowhere further to go,
  you stop, and what comes up comes up by itself. The abbey does not chase anything: a fleeing foe, a lost talent, a
  departed disciple.
- **Nothing is owned.** Tống Tọa Vân was given away with a whisk and a range of hills, and he took the lesson that a
  person can be given and still belong to himself. The abbey keeps no treasury beyond its mica and its lamp oil. It
  owns no land (the heights are Thúy Vi's) and no one inside it owns more than a robe and a bowl.
- **Dao names from the poet.** Each monk who passes the walk takes a two-word name from a line of Vương Duy, the poet
  of the empty mountain: Thủy Cùng, Xuân Giản, Bạch Thạch, U Hoàng, Nhân Hưởng. The novices are called by their village
  names until then.
- **Dress:** grey hemp, patched at the knees from sitting on rock. The Reader alone carries a bell.
- **The school.** The abbey teaches letters, counting and sitting to any child who climbs, and keeps a school at Bách
  Diệp Trấn (58) under Không Sơn's cypresses. The stillest children are sent up the mountain. It is the only school in
  the north that charges nothing, and the merchants of Yên Ba pay it anyway to take their restless sons.
- **The dead:** burned on Thủy Cùng Phong at dawn on a day of rising cloud. Their ash goes up with it and is not kept.
- **The reading.** Once a year, on the night Thôi Bất Kiến died, the Reader goes to Không Sơn Viện and reads aloud
  until dawn. Inside the abbey it is spoken of as "keeping the voices" and nothing more.
- **Taboos:** pursuit; owning; speaking loudly on the peak (from Không Sơn, as at Thúy Vi); cutting mica that has not
  been counted.
- **Outsiders:** anyone may climb, sit and eat millet. A guest who stays past dusk is asked whether they mean to stay.
- **How others see them:** gentle, poor and a little absurd. Thúy Vi treats the abbey as its elder brother in spirit and
  its home for misfits. Nobody thinks of it as dangerous, though its abbot is one of the oldest cultivators in the north.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Novices (outer) | Walking to Where the Water Ends (Hành Đáo Thủy Cùng Quyết) | main, Yellow | none | proposal |
| Monks (inner) and above | Sit and Watch the Clouds Rise (Tọa Khán Vân Khởi Kinh) | main, Earth | none (soul) | proposal, the abbot's |
| Monks | Hundred Echo Palm Scripture (Bách Hưởng Chưởng Kinh) | body / secret, Profound | none | existing (`catalogue-body.json`) |
| Elders | Cloud Mother Seal (Vân Mẫu Ấn) | secret, Profound | none (seal) | proposal |
| Not taught | Empty Mountain Sutra (Không Sơn Kinh) | Heaven | Earth + Wood | Thúy Vi's head secret; the abbot holds its first nine layers from Thôi |

**Why it fits.** A walk, a sitting and a seal need no element, which is why a Metal-rooted miner's daughter and an
Earth-rooted lime-burner's son can sit side by side. The palm scripture is the abbey's only fighting art. Its hundred
echoes are the abbey's joke on Không Sơn's poem: no one is seen, but voices are heard. The abbot says his canon is the
Empty Mountain Sutra with the mountain taken out. That is close to true, and it is why the sutra itself is never taught.
**Catalogue gap:** every soul, song and seal technique in `design/techniques/catalogue-soul-song-seal.json` carries an
element, so an element-free soul abbey needs proposals. R3 names soul and seal as no-lean families. Members on the
lineage: 12 of 12.

## 6. Admission (R3)

- **Any root.** The abbey recruits by Dao heart (đạo tâm). A child who climbs is walked up the stream to its source and
  left there to sit, and taken if still sitting at dusk. The abbey's school at Bách Diệp and Thúy Vi's turned-away
  children send most of the novices.
- **Monks:** the walk's sixth layer, and a Dao name.
- **Exceptions:** none needed. The abbey takes Thúy Vi's Earth-only outer disciples (lord page §6) and the ridge's
  Metal children as a matter of course.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The abbot's sitting and the reading | seat, 10; Thủy Cùng Phong (1492) | Tống Tọa Vân |
| The school and the novices (prior, giám viện) | seat; school at Bách Diệp Trấn (58) | Kha Thủy Cùng; Trang Thanh Tuyền at the school |
| The mica and the seals | seat; Vân Mẫu Khoáng (166) | Lãnh Xuân Giản |
| The walk | the stream to Thủy Cùng Phong | Nông Bạch Thạch |
| The Reader | Không Sơn Viện (213), once a year | Văn Nhân Hưởng |
| The kitchen | seat | Cừ Tùng Gian |
| The Peak of Sitting Alone | Độc Tọa Phong (1139) | Thọ U Hoàng, alone |

## 8. Relations

- **Thúy Vi Tông (lord, loyalty 65):** the abbey's elder brother and its lord, and an older bond than either name.
  Tống was given to Phùng Yên Hà in 500 and served Thúy Vi for forty years before he asked to go and watch the clouds.
  Ngu Lam Sơn walks with him on Thủy Cùng Phong, and Thường Độc Hoạt, Ngu's oldest disciple, lives beside the abbey and
  guides the Reader. The abbey takes the children Thúy Vi turns away. Phạm Thủ Điền of the outer gate sends some of them
  himself, and Cù Thúy Bách walked the prior up in person in 917. The lord does not know that its head's secret
  sutra is read aloud every year by the abbey's Reader. If it learns, it will have to decide whether a promise to the
  dead master who gave it the hills outweighs a secret it was given with them.
- **The Cliff Hall:** close. The ridge's servants' children (Kha, Cừ) come up to the abbey, and the Cliff Hall's cook
  writes to his nephew in the abbey kitchen about salt.
- **Hồng Lô Cốc, Vụ Ẩn Môn, Hộ Lâm Đường:** distant and friendly. The abbey's school takes a few of their children.
- **The merchants of Yên Ba Thành (30):** pay the school to take their restless sons, including a cousin of Thúy Vi's
  port-house clerk Thẩm Tịnh Sa.
- **Không Sơn Viện (fallen 500):** the abbey's root and its secret. Bão Nhất Quán (fallen 488, ruin 1157) is its Rule.

## 9. Inside the sect

- **The reading.** The abbot has kept it for 680 years. The prior Kha Thủy Cùng thinks it should end with him, because
  it puts the abbey at Thúy Vi's mercy. The Reader wants to read it once in daylight with Thúy Vi's leave. The youngest
  novice, Ba Xuân Sơn, has guessed where the Reader goes.
- **What the Reader has done.** Văn Nhân Hưởng has written down the nine layers the abbot holds, which no one outside Thúy Vi has done since Thôi, and
  has scarred a meridian trying to cultivate its first layers on a Metal root. The written copy is the most valuable
  thing in the north that nobody is looking for.
- **The succession.** The abbot has about 220 years left and no heir. The prior is a teacher, not a sitter, and the
  Reader is too restless. Tống says the heir will be whoever sits longest. Nobody knows whether he is joking.
- **The mica.** Lãnh Xuân Giản will not say how much clear mica is left. Thông Vân Thạch thinks he has found a new seam,
  and she has told him to keep digging and tell no one.
- **The letters.** Nông Bạch Thạch writes to Mễ Điền Nhi in Thúy Vi's outer gate every year. If she comes, the Heir's
  Garden loses its fourth plot.

## 10. Treasures and sets

- **Ninth Vigil Heart-Lamp (Cửu Canh Tâm Đăng)**, the catalogue's soul lamp, the abbot's: "the abbot of a Soul sect's
  mountain temple."
- **Robe of the Rising Clouds (Vân Khởi Bào)**, the grey robe Tống walked out of Thúy Vi in, in 540.
- **Cloud Mother Mirror (Vân Mẫu Kính)**, the last clear mica, cut in 1080.
- **Bell of the Empty Hall (Không Đường Linh)**, Không Sơn's hand bell, rung at the academy's door before each reading.
- **The Reader's copy** of the Empty Mountain Sutra: not an item, a hook.
- **The Empty Mountain (Không Sơn Tam Kiện)**, Tống Tọa Vân: Robe of the Rising Clouds, Censer of the Empty Mountain,
  Hundred-Echo Seal. Full set: seconds spent Composed bank Clouds; at 5, the next hit on him is answered by a free
  hundred-echo palm. The Heart-Lamp stays lit on the altar, unworn.
- **The Reader's Pair (Độc Giả Song Kiện)**, Văn Nhân Hưởng: Bell of the Empty Hall, Reader's Mica Robe. Full set: soul
  arts after the bell last longer, and every third casts the next one at once.
- Details in `van_khoi.items.json`.

## 11. Roster (12 living, 2 dead: tier A 2, B 4, C 8)

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| tong_toa_van | Tống Tọa Vân | tông chủ | Nguyên Anh | A | Earth 76, Wood 72 | Abbot and founder; the empty mountain's last student |
| van_nhan_huong | Văn Nhân Hưởng | nội môn | Trúc Cơ | A | Metal 58, Water 34 | The Reader |
| kha_thuy_cung | Kha Thủy Cùng | trưởng lão | Kết Đan | B | Metal 60, Earth 36, Wood 22 | Prior; the school |
| lanh_xuan_gian | Lãnh Xuân Giản | trưởng lão | Kết Đan | B | Earth 52, Metal 50 | Keeper of the mica and the seal |
| nong_bach_thach | Nông Bạch Thạch | nội môn | Trúc Cơ | B | Earth 54, Wood 28 | Teaches the walk; Thúy Vi's reject |
| trang_thanh_tuyen | Trang Thanh Tuyền | chấp sự | Trúc Cơ | C | Water 50, Wood 34 | Schoolmistress at Bách Diệp |
| tho_u_hoang | Thọ U Hoàng | nội môn | Trúc Cơ | C | Metal 48, Earth 40 | Hermit of the Peak of Sitting Alone |
| ho_kinh_dieu | Hỗ Kinh Điểu | ngoại môn | Luyện Khí | C | Water 48, Wood 30 | Merchant's son |
| lao_hong_diep | Lao Hồng Diệp | ngoại môn | Luyện Khí | C | Water 52, Earth 30 | Sells red leaves |
| thong_van_thach | Thông Vân Thạch | ngoại môn | Luyện Khí | C | Metal 56, Earth 26 | Digs the mica |
| cu_tung_gian | Cừ Tùng Gian | nội môn | Luyện Khí | C | Metal 50, Wood 30 | Cook; a ridge child |
| ba_xuan_son | Ba Xuân Sơn | ngoại môn | Luyện Khí | C | Earth 44, Metal 36 | Youngest novice |
| mau_hanh_dao | Mâu Hành Đáo | trưởng lão (dead) | Kết Đan | B | | First prior; died at Vân Gian Trấn, 1019 |
| cong_thu_nhat | Cống Thủ Nhất | last abbot of Bão Nhất Quán (dead) | Kết Đan | C | | Taught Tống the Rule |

## 12. Story hooks

1. **The voices on the empty mountain.** Thúy Vi's Hall of Rules hears that the ghost of Không Sơn Viện is a vassal's
   monk reading the head's secret sutra. Nhạc Chính Hành wants a judgement, and Ngu Lam Sơn wants to ask his friend
   first. The player is asked to find the reader, catch her, or warn her. (Văn Nhân Hưởng, Tống Tọa Vân, Thường Độc
   Hoạt, Nhạc Chính Hành, Ngu Lam Sơn; places 213, 10, 1110.)
2. **The written copy.** Văn Nhân Hưởng's copy of the Empty Mountain Sutra's first nine layers exists, and the cape would kill for it. A
   thief, a Tùng Đào spy or a novice could take it, or the Reader could give it to Thúy Vi to end the secret. (Văn Nhân
   Hưởng, Ba Xuân Sơn, Hồ Tùng Nguyệt; places 10, 213.)
3. **The scarred meridian.** The Reader's meridian scar worsens. Only a healer who knows what she has been cultivating
   can help, and telling one ends the secret. (Văn Nhân Hưởng, Giải Bách Bộ or Dư Tục Đoạn, Tống Tọa Vân.)
4. **The next Reader.** Ba Xuân Sơn follows the Reader through the haze on the night of the reading and gets lost in
   it. (Ba Xuân Sơn, Văn Nhân Hưởng, Thường Độc Hoạt; places 1492, 213.)
5. **Who sits longest.** The abbot announces a sitting on Thủy Cùng Phong to choose his heir. The prior, the Reader, the
   hermit and the Earth-only teacher all climb, and so do some who were never invited. (Tống Tọa Vân, Kha Thủy Cùng,
   Văn Nhân Hưởng, Thọ U Hoàng, Nông Bạch Thạch; place 1492.)
6. **The new seam.** Thông Vân Thạch's seam is real and runs under Thúy Vi's green jade mine. Clear mica would save the
   abbey's seals, and digging for it would wake the jade-cutters' old claims. (Thông Vân Thạch, Lãnh Xuân Giản, Lã Trác
   Thạch; places 166, 165.)
7. **The fourth plot leaves.** Mễ Điền Nhi finally answers Nông Bạch Thạch's letter. If she comes up the mountain, the
   Heir's Garden loses its strangest plot, and Thúy Vi loses its chance at an Earth way. (Nông Bạch Thạch, Mễ Điền Nhi,
   Phạm Thủ Điền; places 10, 1110.)
8. **The restless son.** Hỗ Kinh Điểu runs away from the school to Yên Ba with a story about a ghost who reads. His
   cousin at the port house believes him. (Hỗ Kinh Điểu, Thẩm Tịnh Sa, Trang Thanh Tuyền; places 58, 30.)
9. **The prior's grave.** Mâu Hành Đáo was never found after the second slide at Vân Gian Trấn. Nhạc Chính Hành, who
   dug beside her, has never visited the abbey. (Kha Thủy Cùng, Nhạc Chính Hành; place 1130.)
