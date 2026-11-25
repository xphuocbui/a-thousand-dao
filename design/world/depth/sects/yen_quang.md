# Yên Quang Các (煙光閣), the Pavilion of the Hazy Light

> **Status**: World-depth pass, 2026-11-25. Proposal: nothing here is in game data. Rules: `../rules-proposals.md`
> R1-R8. People: `yen_quang.cast.json`; công pháp: `yen_quang.techniques.json`; items: `yen_quang.items.json`. Lord's
> page: `lac_ha.md`.

## 1. At a glance

| | |
|---|---|
| Kind | Minor sect, vassal of Lạc Hà Tông (loyalty 55), righteous (chính) |
| Leans | Wood, Earth (unchanged; the seat moved) |
| Lineage elements | Wood first, then Earth |
| Seat | **moved in 1187** from the steppe (place 537) to **Dã Tang Lâm**, the wild mulberry wood (place 423, Ngư Ca Xuyên), 3 tiles from Tang Ma Thành; the old seat is the **Dusk Field** |
| Head | Tào Mộ Tử, Trúc Cơ, head since 1150; the grand elder Diêm Tử Tô (Kết Đan) outranks him in realm |
| Size | about 35 alchemists and pickers; 10 named living, 2 dead |
| Way of life | alchemists who pick their herbs only in the hour of the evening glow, and make Lạc Hà's pills |

The pavilion is named for a line of Vương Bột's: the haze and light gather, and the evening hills turn purple (yên
quang ngưng nhi mộ sơn tử). Its founder took the first half of the line as her name and gave the second half to a
foundling who became its head. It is a young house, 135 years old, and its whole art comes from one hour of the day.

## 2. Land and seat

**Decision (R4): move the seat to Dã Tang Lâm (place 423); leans unchanged.** The old seat is steppe at Earth 41 %,
Fire 25 %, Wood 13 % (density 0.81). It fails Wood, the first lean. A re-lean to Earth and Fire would fit the furnace,
but it would make Lạc Hà's Placement Day untrue ("Wood and Earth children go to Yên Quang Các") and cut the pavilion
from the herbs it lives on. The candidates in its ground:

| Candidate | Land | Wood / Earth | Density | Verdict |
|---|---|---|---|---|
| Hãm Thạch Trấn (548), Bạch Cao Động (544) | karst ruin, cave | 36 / 21, 33 / 23 | 1.24, 0.93 | Nam Phố Đường's holdings |
| Cẩm Kê Nguyên (271) | grassland beast lair | 30 / 20 | 1.29 | in Nam Phố's province |
| Cuồng Trư Lâm (545), Quần Lang Lĩnh (552) | boar and wolf woods | 36-37 / 21 | 1.05-1.07 | beast lairs, far from any market |
| **Dã Tang Lâm (423)** | temperate forest, wild mulberry | **39 / 21** | **1.04** | **seat**: unheld, nearest (30 tiles), beside Tang Ma Thành |

**The story.** The founders put the pavilion on the steppe in 1065 because they were Lạc Hà's alchemists and Lạc Hà's
seat was on the steppe (V107). The herbs they picked at dusk grew in the steppe grass, and in 1065 the grass still held
Wood. It dried as the maples at Lạc Hà's seat dried. In the summer of 1131, when the last maple died (N-lac_ha-02), a
grass fire took the last bed of dusk-wormwood and the picker Hàn Thanh Cao with it. Every decade after that the Dusk
Field gave less, and the steppe-born children had Wood too thin for the inner gate. In 1185 Lạc Hà moved up the mountain
(N-lac_ha-05). Its Maple Hall began making the sect's own pills at Phong Ảnh Mạch, and the pavilion's best customer was
learning to grow its own. In 1187 Tào Mộ Tử moved the furnaces and beds to the wild mulberry wood that Lý Tang Ký had
found beside her home town (N-yen_quang-03). He carried the founder's furnace with its coals lit, so that the fire never
went out. The mulberry gives three medicines (leaf, root bark, and the mistletoe that grows on it), and the wood's Wood
is three times the steppe's.

**What the move costs (to do when approved).**
- **Chronicle.** V107 (1065) names place 537 as the founding place and stays true. Add N-yen_quang-01 to -03.
- **Art.** A painting and map symbol at place 423: low furnace-houses under old mulberry trees, a line of smoke going up
  at dusk. Place 537 keeps its painting as the **Dusk Field (Vãn Điền)**.
- **Routes and province.** A new track 423 → 80 (Tang Ma Thành, 3 tiles), where the road east begins. Place 423 is in
  province `prov_p80`, Tang Ma's. The Dusk Field keeps its trunk routes to Hạc Đinh Thị (51) and Song Tỉnh Thôn (488).
- **Density.** 423 is 1.04 against the old 0.81. **Founder's array** (amended 2026-11-25, ruling group 2: every moved
  sect gets one): the **Ever-Lit Furnace (Trường Minh Lô)**, the founder's furnace that Tào Mộ Tử carried to the
  mulberry wood with its coals lit in 1187 (N-yen_quang-03). By World Generation Formula G it adds **0**
  (`seat_array_density` 0: the new seat is already denser than the old), so it is a named record with no density bonus
  yet. Whether it should carry one is the user's call (World Generation Open Question 11).
- **The old seat (537)** is the **Dusk Field**: the outer gate and the pickers walk the steppe there at sunset, beside
  Hà Quang Tuyền (536, the Spring of the Evening Glow, the pavilion's). The grand elder Diêm Tử Tô lives there beside the
  founder's grave and would not move.

**How the land shapes its people (R1).** Ngư Ca Xuyên's forests and river villages run Wood 30-43 % (Tang Ma, Phóng
Mộc, Sơn Trà, Hoa Khê), and its steppe belt runs Earth 32-47 % (Lô Địch, Than Đầu, the old seat). Wood-rooted
children are river and forest born, and they fill the inner gate. Earth-rooted children are steppe born, and they fill
the outer gate and the Dusk Field. Since 1187 the pavilion has drawn its inner disciples from the wood's own villages.
Its oldest people are still steppe-born, and you can tell them by the way they kneel.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 1065 | Vi Ngưng Yên and Diêm Tử Tô, Lạc Hà's alchemists, found the pavilion on the steppe below the seat | V107, **N-yen_quang-01** |
| 1080 | A newborn is left at the gate in the evening glow; Vi names him Tào Mộ Tử | |
| 1131 | The dry summer: a grass fire takes the last dusk-wormwood and Hàn Thanh Cao | N-lac_ha-02 |
| 1150 | The great drought thins the wormwood grown from Hàn Thanh Cao's seed; Vi dies in her breakthrough on Diêm's pill; Tào is head | **N-yen_quang-02** |
| 1174 | Ferry War: the pavilion's wound salves go to Tang Ma's bridge-weavers | A202 |
| 1185 | Lạc Hà moves up the mountain; its Maple Hall makes its own pills | N-lac_ha-05 |
| 1187 | The pavilion moves to the wild mulberry wood; the steppe becomes the Dusk Field | **N-yen_quang-03** |
| 1195 | Tào makes the veil and tincture Hình Lạc Nhạn wears into the miasma the next year | N-lac_ha-07 |

**New chronicle proposals:**
- **N-yen_quang-01** (1065, `sect_founded`): "Two of Lạc Hà's alchemists found Yên Quang Các on the steppe below its
  seat and swear to pick their herbs only in the hour of the evening glow."
- **N-yen_quang-02** (1150, `death`): "In the great drought, with the Dusk Field's wormwood thinned, Vi Ngưng
  Yên, founder of Yên Quang Các, dies in her breakthrough to Nguyên Anh;
  her Dao partner, who made her pill, refuses the headship and never lights a furnace again."
- **N-yen_quang-03** (1187, `seat_moved`): "Yên Quang Các carries its founder's furnace, still lit, from the steppe to
  the wild mulberry wood by Tang Ma Thành; the steppe becomes its Dusk Field."

## 4. Doctrine and customs

- **The hour of the glow.** A plant picked at sunset holds the day's warmth and the night's stillness together. The
  pavilion picks in that hour only, lights its furnaces at dusk and banks them at dawn. This is its lord's hour too, and
  Lạc Hà approves.
- **One in three.** Take one plant in three, and leave the root. Medicine is a debt to the land, and the pavilion pays
  it. Since 1131 it also keeps seed from every bed.
- **The maker tastes.** No pill leaves the pavilion until its maker has taken a quarter dose. Most of its alchemists are
  hard to poison, and the head is very hard to poison.
- **No pill for oneself.** Since 1150 a pill for one's own breakthrough must be made by someone else. The rule is meant
  as mercy. It has left the best picker waiting on a grand elder who will not light a furnace.
- **Herb names.** An inner disciple takes the name of the first herb they picked at dusk: Tử Tô, Đương Quy, Bạch Chỉ,
  Tang Ký, Cam Thảo, Ích Mẫu. Outer disciples keep their birth names. The head is the one exception: the founder named
  him from the line.
- **Dress.** Smoke-grey robes with the sleeves tied, a straw cape for the field and an herb pouch. Pickers kneel so often
  that their knees are patched in leather.
- **Food.** Mulberry-leaf tea, millet, hemp-seed cakes from Tang Ma. They eat nothing bitter on picking days, because
  it dulls the tongue.
- **The dead.** Buried under a mulberry at the new seat, or in the Dusk Field beside the founder for the old ones,
  with a seed of whatever they first picked.
- **Taboos:** picking at noon; selling an untasted pill; making one's own breakthrough pill; pulling an herb up by the
  root.
- **Outsiders** are patients first. The pavilion treats anyone who walks in at dusk, and charges by Lạc Hà's posted
  prices.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Outer gate | Dusk Gathering Primer (Vãn Thái Quyết) | main, Yellow | Wood or Earth | proposal |
| Inner gate and above | Verdant Cycle Scripture (Thanh Hoàn Kinh) | main, Profound | Wood | existing (`catalogue-wood.json`) |
| Inner secret | Evening Haze Furnace Art (Yên Quang Lô Pháp) | secret, Profound | Wood + Earth | proposal |
| Elders | Gathered Haze Canon (Ngưng Yên Kinh) | secret, Earth | Wood + Earth | proposal, the founder's |
| Body | none | | | |

**Why it fits.** The founders bought the Verdant Cycle at Hạc Đinh Thị in 1065 because it teaches the body to be a
plant: sow, root, mend in the shade, harvest. Nothing in the catalogue suits pickers better. The pavilion's own arts
grew round it. The primer is the dusk picker's breath, Wood from the herb and Earth from the soil it grew in. The
furnace art breathes the pill's vapour out as a healing haze. The founder's canon gathers healing and lets it go at
once. All of it is sustain, the pavilion's whole way of fighting (memory: sustain is king). Lạc Hà hires its pills
here rather than admit alchemists off its root.

## 6. Admission

- **Outer gate:** Wood or Earth at 30 or more. Steppe children come to the Dusk Field and forest children to the
  wood. Placement Day sends Lạc Hà's Wood-and-Earth failures (Mai Tiểu Ngải, 1199).
- **Inner gate and above:** Wood at 45 or more. The test is to pick one plant in three for a season of sunsets and
  leave every root.
- **Exceptions:** none. The grand elder Diêm Tử Tô outranks the head in realm and holds the rank of grand elder
  (thái thượng) by his own wish.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The Pavilion (head's furnace, the beds, the inner gate) | Dã Tang Lâm, 423 | Tào Mộ Tử |
| The Furnace House | 423 | Sầm Bạch Chỉ |
| The Mulberry Wood (mistletoe, leaf, bark) and the Tang Ma trade | 423, 80 | Lý Tang Ký |
| The Dusk Field (old seat; the outer gate, the founder's grave) | 537, with Hà Quang Tuyền (536) | Diêm Tử Tô, grand elder; Văn Đương Quy |

## 8. Relations

- **Lạc Hà Tông (lord, loyalty 55):** the founders were its alchemists, and the pavilion makes its pills (`lac_ha.md`
  section 5). Since 1185 Lạc Hà's Maple Hall under Chử Hồng Diệp has made pills of its own, so the pavilion now sells to
  a lord that is learning not to need it, and loyalty has slipped. Chử is Diêm Tử Tô's friend from the same camellia
  village and Tào's rival in the market, and this spring she sent Diêm a breakthrough recipe to check. The Maple Hall's
  terrace keeper Bạc Hy Vân is Lý Tang Ký's rival.
- **Hình Lạc Nhạn** (Lạc Hà's walker in the miasma): her veil and tincture are Tào's. She pays in miasma-root, and
  Khổng Ích Mẫu carries the year's doses up to the Watch, three months each way.
- **Lạc Đan Thanh** (loose, the pill-seller of Vật Hoa Thị, A186): sold the founder the herb she added to her last
  pill. Diêm has never asked him why.
- **Nam Phố Đường** (fellow vassal, talisman scribes): holds the karst ruins next to the pavilion's old candidates. The
  two exchange salves for talismans.
- **Thúy Vi Tông:** Lạc Hà's rival in the western herb market. Lý Tang Ký sells to it through a buyer in Tang Ma
  Thành, and the head does not know.
- **Tang Ma Thành** (Lạc Hà's hemp city): three tiles away. Its rope-weavers buy the pavilion's wound salves and gave it
  an orphan.

## 9. Inside the sect

- **The lord's Maple Hall.** Lạc Hà is learning to make its own pills. Since 1185 **Chử Hồng Diệp**'s Maple Hall has
  made its everyday pills, and this spring she sent Diêm Tử Tô a breakthrough recipe in her letter and asked him to
  check it. She built it from the pill book Vi and Diêm left in Lạc Hà's library when they founded the pavilion, with a
  dusk herb from Lạc Đan Thanh's stall added, and it is very like Vi's last pill. If Diêm checks it, the lord will
  need its vassal for nothing. If he will not, he must say why.
- **Pills for Thúy Vi.** **Lý Tang Ký** sells crates of the pavilion's pills to a Thúy Vi buyer in Tang Ma Thành,
  under Lạc Hà's posted price, which Lạc Hà would call treachery. To fill the crates she has cut the wound salve the
  pavilion sells Tang Ma's rope-walkers, and the weavers hurt on the walks this season go without. Cố Tằm Nhi carries
  her letters to the buyer unopened.
- **The antidote.** **Tào Mộ Tử** wants to make the one thing the Maple Hall cannot: the miasma antidote. He takes his
  fee for Hình Lạc Nhạn's tincture in miasma-root, and the strength she asked for is for a thousand paces of the grey,
  not three hundred. Now he is testing the antidote on himself, a dose a week. Thái Tri Mẫu weighs each dose. This
  year Tào has kept **Khổng Ích Mẫu** home from her yearly carry to the Watch to keep the count of doses and fits in
  the tasting book, and the year's tincture waits in the store.
- **The cold furnace.** **Diêm Tử Tô** made the pill Vi died on and has not lit a furnace since. He refused the
  headship in 1150 out of grief, and the pavilion made Tào head. Văn Đương Quy is ready for Kết Đan and will take a
  pill from no one but him. In 1187 Diêm found that Vi changed her recipe the night before, with an herb from Lạc Đan
  Thanh's stall. Lạc kept a ledger of what she asked for, and his price for telling Diêm is one pill brewed in the
  Cold Furnace, for himself.
- **The tune on the Dusk Field.** Trang Vãn Thảo hums a tune from Lô Địch Thôn that her grandmother told her never to
  play at dusk. Lạc Hà's choir leader has asked her what it is.

## 10. Treasures and sets

- **Furnace of the Evening Glow (Mộ Quang Lô)**: the founder's clay furnace, carried lit from the steppe in 1187. The
  head's.
- **The Cold Furnace (Lãnh Lô)**: the bronze furnace in which Diêm made Vi's last pill. Unlit since 1150. Diêm's.
- **Gourd of the Last Light (Tàn Quang Hồ Lô)**: keeps a dusk-picked herb fresh for a year. Văn Đương Quy's.
- **The founder's notes**: Vi's recipes, with the change of 1150 in her hand. With Diêm.
- Personal sets (cast-sets pass, 2026-11-25):
  - **Evening Glow (Mộ Quang Song Bảo)**, Tào Mộ Tử's pair: the Furnace of the Evening Glow and the Gourd of the Purple
    Haze; early heals last longer, late ones also clear poison.
  - **The Dusk Field (Mộ Điền Tam Bảo)**, Diêm Tử Tô's three: the Cold Furnace, the Camellia Seed Pendant and the Robe
    of the Dusk Field; healing is stored in the unlit furnace and restored to him at once when it lights itself at 40 % health.

## 11. Roster

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| tao_mo_tu | Tào Mộ Tử | tông chủ | Trúc Cơ | A | Wood 56, Earth 48 | head; moved the pavilion; made the tincture |
| diem_tu_to | Diêm Tử Tô | thái thượng | Kết Đan | A | Wood 62, Earth 46 | grand elder and co-founder; the cold furnace |
| van_duong_quy | Văn Đương Quy | nội môn | Trúc Cơ | B | Wood 54, Earth 40 | the best picker; waits for her pill |
| ly_tang_ky | Lý Tang Ký | nội môn | Trúc Cơ | B | Wood 52, Earth 32 | keeper of the mulberry wood; the trade |
| sam_bach_chi | Sầm Bạch Chỉ | nội môn | Trúc Cơ | C | Wood 46, Fire 30, Earth 28 | furnace keeper |
| khong_ich_mau | Khổng Ích Mẫu | nội môn | Luyện Khí | C | Wood 48, Water 30 | carries the tincture to the Watch |
| phung_cam_thao | Phùng Cam Thảo | nội môn | Luyện Khí | C | Wood 46, Earth 30 | at the bellows |
| trang_van_thao | Trang Vãn Thảo | ngoại môn | Luyện Khí | C | Earth 42, Wood 30 | picker who hums |
| mai_tieu_ngai | Mai Tiểu Ngải | ngoại môn | Luyện Khí | C | Wood 40, Earth 34 | placed from Lạc Hà |
| tien_tieu_dong | Tiền Tiểu Đồng | ngoại môn | Luyện Khí | C | Wood 36, Earth 34 | Tang Ma orphan |
| vi_ngung_yen | Vi Ngưng Yên | founder (dead 1150) | Kết Đan | B | | founder; died in her breakthrough |
| han_thanh_cao | Hàn Thanh Cao | nội môn (dead 1131) | Trúc Cơ | C | | died in the steppe fire of 1131 |

## 12. Story hooks

1. **A furnace for Văn Đương Quy.** Văn's breakthrough cannot wait much longer. The player can persuade Diêm to light
   the Cold Furnace, pay Lạc Đan Thanh's price for what Vi asked for, or carry Tào's pill to Văn and lie about who made
   it. (Diêm Tử Tô, Văn Đương Quy, Tào Mộ Tử, Lạc Đan Thanh; places 537, 50.)
2. **The herb from the stall.** Lạc Đan Thanh will tell Diêm what Vi asked for in 1150, for one pill brewed in the Cold
   Furnace. To pay it, Diêm must light the furnace he has kept cold for fifty years, for the man he blames. (Diêm, Lạc
   Đan Thanh, Vi Ngưng Yên; places 537, 50.)
3. **A thousand paces.** Khổng Ích Mẫu brings the player the tasting book: the head's fits are worse each week, and the
   year's tincture is still in the store, waiting for her. It is for Hình Lạc Nhạn's walk back into the grey with Nhạn
   Trận Môn's ten. (Khổng Ích Mẫu, Tào, Hình Lạc Nhạn, Mục Tân Vũ, Cảnh Trường Thiên; places 423, 223.)
4. **The antidote.** Tào needs more miasma-root than the Watch can pass him. The Pivot's Quý Thủ Lũy grows it on the
   other side of the grey (`lac_ha.md` hook 12). (Tào, Quý Thủ Lũy, Hình Trọng Sơn; place 223.)
5. **Pills for Thúy Vi.** Lý Tang Ký sells a crate of the pavilion's pills to a Thúy Vi buyer in Tang Ma Thành, and
   Lạc Hà's Counting House hears of it before the head does, from the rope-walkers who went without salve. (Lý Tang Ký,
   Tào, Tông Thủ Tín, Úy Thanh Diễm; place 80.)
6. **The Maple Hall's recipe.** Chử Hồng Diệp sends Diêm a recipe in her spring letter and asks him to check it. It is
   very like Vi's last pill. (Chử Hồng Diệp, Diêm, Bạc Hy Vân; places 556, 537.)
7. **The tune at dusk.** Trang Vãn Thảo hums her grandmother's tune on the Dusk Field and the steppe answers. It may be
   the tune Lô Địch Thôn stopped playing in 803 (V103). (Trang Vãn Thảo, Hồng Vãn Tình, Văn Đương Quy; places 537,
   538.)
8. **The last bed of wormwood.** A dry summer threatens the Dusk Field as it did in 1131 and 1150. The pickers must
   decide whether to carry Hàn Thanh Cao's wormwood into the mulberry wood, where it may not take. (Văn Đương Quy, Mai
   Tiểu Ngải, Diêm, Tào; places 537, 423.)
