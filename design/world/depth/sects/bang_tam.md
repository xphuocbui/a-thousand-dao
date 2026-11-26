# Băng Tâm Các (冰心閣), the Pavilion of the Ice Heart

> **Status**: Pilot, overnight 2026-11-24/25 (world-depth pass). Proposal: nothing here is in game data. Rules it
> applies: `../rules-proposals.md` R1-R8. People: `bang_tam.cast.json`; công pháp: `bang_tam.techniques.json`;
> items: `bang_tam.items.json`.

## 1. At a glance

| | |
|---|---|
| Kind | Great sect, tier 2, righteous (chính) |
| Lord / vassals | none / Lê Hoa Am, Trạc Anh Đài, Dạ Quang Môn, Trấn Sa Đường, Lãnh Giang Phái, Tầm Kiếm Đường |
| Leans | Water, Ice (unchanged) |
| Lineage elements | Ice first, then Water (R5) |
| Seat | **moves** from the desert edge (place 3, badlands) to **Hồ Thiên Phái** (place 214, tundra, Ngọc Hồ Sơn) |
| Head | Sở Ngọc Hồ, Nguyên Anh, Keeper of the Vessel |
| Size | about 150-200 members: ~70 named, the rest drawn under R1/R2 |
| Specialty | sword cultivators (kiếm tu) and array keepers |

The Pavilion is cold, patient and proud. It believes a heart that does not waver cannot be beaten, and it raises its
disciples to show nothing. It lost two wars it chose and won two it should not have. Its people are mostly born on
ice or brought to it young: in the inner gate there is no one whose qi does not freeze.

## 2. Land and seat

**Decision (R4): move the seat to Hồ Thiên Phái (place 214).** The current seat sits on badlands at the desert edge
(10 % Water, no Ice; density 1.63), which makes no sense for an Ice sect. Its own ground holds the ice it is named
for: Ngọc Hồ Sơn (region 7: glacier, tundra, high mountain) and Hàn Sương Châu (region 9: tundra coast).

| Candidate | Land | Water | Ice | Density | Verdict |
|---|---|---|---|---|---|
| Hồ Thiên Phái (214), ruin | tundra, 0 km | 61 % | 22 | 1.02 | **seat**: fits, and it has a story |
| Băng Bích Nhai (1393), peak | glacier | 66 % | 40 | 0.77 | **the head's sanctum** (Ice is strongest here; too thin and cold for a sect) |
| Băng Trụ Phong / Phong Tuyết Đỉnh | glacier | 67 % | 40 | 0.77 | the grand elder's seclusion peaks |
| Hàn Giao Chử (239), beast lair | tundra | 59 % | 14 | 1.00 | beast hall, guest alchemist, outer gate |

**The story.** The founder Tần Ngưng Sương reached the north-east in 440 and could not yet take the ice: Ngọc Hồ Sơn
still steamed where Chúc Long Sơn had buried Hồ Thiên Phái fifteen years before, and no bird sang there (A100). She
built a first pavilion at the desert's edge and made its well cold enough to keep ice all summer (A114). In 470, when
the Pavilion claimed the empty ice (C095), she moved the sect onto Hồ Thiên's ruin. She laid the **Jade Vessel Array**
into the ice over the buried vent, so the fire below and the cold above feed one well of qi. That is why a tundra
ruin holds a great sect's density. The array is also a lid on a volcano. It has held for 730 years. Chúc Long Sơn
rumbled for the first time in 774 years in 1199 (A111).

**What the move costs (to do when approved).**
- Chronicle: C007's "among the ice fields" becomes "at the desert's edge, facing the ice fields". Add N-bang_tam-01
  (470, the move) and N-bang_tam-02 (470, the Jade Vessel Array laid).
- Art: a seat painting and map symbol at place 214. The old seat keeps its painting as the Desert Pavilion.
- Routes and province: seat record to place 214's province. Place 214 lies on an island of the ice archipelago, so the
  seat is reached by a sea lane from Băng Khổng Thôn (1346), the nearest coastal village with a road, and a track to Hàn Giao Chử (239) on the island (user ruling
  2026-11-26; there is no land road from Hòe Âm Trấn or Trường Vân Thành).
- Density: place 214 is 1.02 as a ruin, which includes the ruin's +0.25; as the seat it takes the great seat's +0.10
  instead, so 0.77 + 0.10 = 0.87. `seat_array_density` **+0.75** from the Jade Vessel Array (re-sized 2026-11-25 by
  World Generation Formula G, ruling group 12; it was +0.6), so the seat reads 1.62 against the old seat's 1.63. If
  the array is broken (a hook), the density falls to 0.87 and the volcano wakes.
- **Old seat (place 3)** becomes **Cựu Các, the Desert Pavilion**: the sect's outer hall for the desert and the
  caravan road, where Ôn Sa Ngọc keeps the Pavilion's trade and its desert recruits. It still has the founder's cold well.

**How the land shapes its people (R1).** Born on the ice of Ngọc Hồ Sơn or the frost coast, a child is about twice as
likely to be Water-rooted, and Ice land (variant 14-40) makes an Ice transmutation up to five times likelier. The
desert and steppe of Cô Yên Mạc (region 8: 5-15 % Water) breed Earth, Fire and Metal roots. Its Water-rooted children
come from the oases (Ngư Đàm Thôn), and they are the Desert Pavilion's recruits. The Pavilion's ground therefore holds two peoples: ice-born and
desert-born. The sect's quiet prejudice is that only the first are truly its own.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 210 | Khúc Hồ Già founds Hồ Thiên Phái on the ice below Chúc Long Sơn; forges the sword Phi Tuyết (230) | C058, C061 |
| 425 | Chúc Long Sơn erupts under the ice and buries Hồ Thiên with its founder | C090 |
| 440 | Tần Ngưng Sương founds Băng Tâm Các at the desert's edge, facing the ice | C007, A114 |
| 470 | The Pavilion claims Ngọc Hồ Sơn, moves onto Hồ Thiên's ruin, lays the Jade Vessel Array | C095, **N-bang_tam-01, -02** |
| 492-498 | **War of the Frost Coast**: Hàn Giang Môn falls with its last head Liễu Cô Chu; the frost coast is taken; Sóc Phương Thành's people moved to Liên Giang | C098, C099, V076-V078 |
| 510 | The North Star Compact: the last land-grabs end | C107 |
| 722-728 | **Desert Road War** with Phượng Minh Cung: Cô Thành holds two years, the plum-blossom swordsmen of Lãnh Hương Các ride to break the siege and none return; Cô Thành falls; the Pivot imposes a truce | C142-C144, A118, V071 |
| 724 | **N-bang_tam-03**: one child of the Lãnh Hương riders, the four-year-old Phó Ám Hương, is carried into the Pavilion with his father's red-ink sword manual | new |
| 760 | The Ice Soul vein Băng Phách Mạch is opened, and Hồi Lan Thành is founded after the war | A106, C150 |
| 940-944 | **Long Lake War** with Tùng Đào over Hạo Nguyệt Hồ; Đỗ Tinh Hà arbitrates; a grudge stays (−5) | C170, C171, A013 |
| 1010 | Tần Ngưng Sương dies at 710; **Sở Ngọc Hồ**, not the senior disciple Cố Lăng Sương, becomes Keeper of the Vessel | C175 |
| 1010 | **N-bang_tam-04**: Cố Lăng Sương goes up Băng Bích Nhai the same winter and does not come down | new |
| 1090 | Sở Ngọc Hồ, Đỗ Tinh Hà and Thôi Khinh Hồng kill the ma đạo master Mặc Huyết Sinh; his disciple Triệu Huyết Y escapes | C024 |
| 1119-1121 | **Taming of Dạ Quang**: Hạng Dạ Bôi kneels; his son is kept at the Pavilion as surety | C184, C185, **N-bang_tam-05** |
| 1188 | The Tinh Tủy Mạch petition is rejected by the Pivot; Sở Ngọc Hồ shuts herself in the ice hall for a year | C195, A125, V070 |
| 1199 | Chúc Long Sơn rumbles under the ice | A111 |

**New chronicle proposals** (for `chronicle_proposal.json` once approved):
- **N-bang_tam-01** (470, `seat_moved`): "Băng Tâm Các leaves its desert pavilion and raises its halls on the ruin of
  Hồ Thiên Phái, on the ice the fire mountain buried."
- **N-bang_tam-02** (470, `array_laid`): "Tần Ngưng Sương lays the Jade Vessel Array into the ice over the buried
  vent; the steam stops, and the birds come back to Ngọc Hồ Sơn."
- **N-bang_tam-03** (724, `tale`): "A four-year-old boy is carried out of the ruin of Cô Thành wrapped in his dead
  father's cape, a red-ink sword manual sewn into the lining: the last of Lãnh Hương Các."
- **N-bang_tam-04** (1010, `hermit`): "Passed over for the Vessel, Cố Lăng Sương climbs Băng Bích Nhai the winter her
  master dies and closes the cave behind her."
- **N-bang_tam-05** (1121, `hostage`): "Hạng Dạ Bôi's son Hạng Minh Sa, twenty-one, is sent to Băng Tâm Các as surety
  for his father's knee."

## 4. Doctrine and customs

- **The Ice Heart.** The sect's one teaching: a feeling allowed to cloud the heart clouds the qi. Feeling is not
  forbidden. It is expected to freeze clear. A disciple who weeps is not punished; one who acts in anger is.
  Outsiders call them heartless, and the Pavilion does not argue.
- **Silence before speech.** At any council the youngest speaks first and the head last. Interrupting is the gravest
  rudeness in the Pavilion. Visitors from the warm south find meetings unbearably slow.
- **White and pale blue.** Disciples wear undyed white; inner disciples add a pale-blue sash, elders a sash of frost
  silk that is cold to the touch. Only the Keeper wears the jade vessel at the belt.
- **The Frost Test.** Each winter's solstice night, every outer disciple at the sixth layer of the Clear Frost
  Breathing Primer sits on the frozen mere of Hàn Giao Chử until dawn, where the ice holds a little Ice of its own (14).
  Those in whom Ice answers walk up to the inner gate at the seat when the spring opens the road, nine days. The rest
  go back to the outer gate on the mere's shore and may sit again next year. Three failures and they are offered the
  Desert Pavilion, a vassal, or the road.
- **Phiến Băng Hồ.** The glass-clear lake of the frost coast (place 191) is the Pavilion's pilgrimage. Its frost-coast
  disciples sit on it in winter to see their own hearts (A140), and an elder of the seat walks to it once in a life,
  some two hundred days each way.
- **No fire in the halls.** No open flame is lit inside the seat, because of the Array and the volcano under it. Pills
  are brewed in the guest alchemist's hall at Hàn Giao Chử, some 140 km from the seat, and carried in. Tea is made with water warmed by qi.
- **The dead go to the ice.** The Pavilion buries its dead in the glacier above the seat, standing, facing south.
  Every head lies there except Tần, who lies under the seat inside her array.
- **Taboos:** striking a fellow disciple in anger; speaking of the volcano to outsiders; copying the Snow Plum
  manual in black ink.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Outer gate | Clear Frost Breathing Primer (Thanh Sương Thổ Nạp Quyết) | main, Yellow | Water | proposal |
| Inner gate | Winter Toll Canon (Đông Toán Kinh) | main, Profound | Ice | existing (`design/techniques/catalogue-ice.json`) |
| True disciples, elders | Jade Vessel Ice-Heart Canon (Ngọc Hồ Băng Tâm Kinh) | main, Earth | Ice + Water | proposal, the founder's |
| Inner gate secret | Snow Plum Sword Method (Tuyết Mai Kiếm Quyết) | secret, Profound | Ice | proposal (from Lãnh Hương Các) |
| Elders' secret | Frost Lotus Array Canon (Sương Liên Trận Kinh) | secret, Earth | Ice + Earth | proposal |
| Keeper | Stilled Hour Sutra (Tĩnh Thời Kinh) | secret, Heaven | Ice | existing |

**Why it fits:** the outer gate trains the Water root every Ice root starts from, and the Frost Test is the only door
inward. The elders' array method needs Earth beside Ice, which is why the array keepers (Tiết Hàn Mai) are
Water-Earth with Ice. Every method is cold, so the sect cannot brew its own pills or forge its own swords. It hires a
Fire alchemist (Viên Chước) and buys its blades from Trấn Sa Đường's forges. That dependence is the sect's weakness.

## 6. Admission (R2 as the Pavilion applies it)

- **Outer gate:** Water at purity 30 or more, or Ice at all. Recruiters walk the frost-coast villages, the ice
  hamlets of Ngọc Hồ Sơn and the desert oases every spring. The Desert Pavilion takes the oasis children.
- **Inner gate and above:** Ice. No exceptions in the lineage. Ten generations of outer disciples have sat the Frost Test.
- **Exceptions kept:** the guest alchemist (khách khanh), Dạ Quang's hostage, and the servants of the seat (mortals).
  A disciple whose Ice fades through injury keeps their rank, and the sect does not speak of it.
- **Men and women** are both taken. The Keepers have all been women, by custom rather than rule, and Thẩm Hàn Giang
  means to be the first man.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The Vessel Hall (the head's court) | seat, 214 | Sở Ngọc Hồ |
| The Array Hall (keeps the Jade Vessel Array) | under the seat | Tiết Hàn Mai, first elder |
| The Plum Sword Hall (inner-gate sword) | seat | Phó Ám Hương |
| The Hall of Cold Law (discipline, the frost-coast towns, the vassals' suits) | seat and Liên Giang Thành | Thẩm Hàn Giang |
| The Ice Soul Vein watch | Băng Phách Mạch (209) | Kha Tĩnh Ba, steward |
| The Beast Hall (ice beasts, the sect's mounts) | Hàn Giao Chử (239) | Lam Tuyết Điêu |
| The guest alchemist's hall | Hàn Giao Chử, outside the array | Viên Chước, guest elder |
| The Desert Pavilion (outer affairs, caravans, desert recruits) | old seat, 3 | Ôn Sa Ngọc |
| The outer gate (the Frost Test on the frozen mere) | Hàn Giao Chử (239), outside the array | Đỗ Sương Nhi, steward |
| Envoys (the Pivot, the vassals) | travels | Ngụy Thanh Hàn |
| Grand elder in seclusion | Băng Bích Nhai (1393) | Cố Lăng Sương |

## 8. Relations

- **Thiên Xu Tông (the Pivot):** obedient and cold. The Pavilion owes the Pivot two arbitrations (728, 944) and
  resents both. The 1188 rejection of its claim to Tinh Tủy Mạch was a public humiliation (Ngụy Thanh Hàn wrote the
  petition; Doãn Ngọc Hành refused it).
- **Phượng Minh Cung:** the old enemy of the Desert Road War. Fire and ice. The caravan road has been quiet since
  1060 (A262), but Phó Ám Hương has never forgiven it.
- **Tùng Đào Cung:** a cool grudge (−5) from the Long Lake War. Sở Ngọc Hồ respects Thôi Khinh Hồng since they killed
  Mặc Huyết Sinh together.
- **Vassals:** Lê Hoa Am (a sister in spirit: ice nuns), Trạc Anh Đài and Lãnh Giang Phái (the frost-coast fishers,
  who remember Hàn Giang), Tầm Kiếm Đường (the men Lê Hoa Am turned away), Trấn Sa Đường (caravan guards and the
  Pavilion's smiths), and **Dạ Quang Môn**, the beaten desert raiders, whose loyalty is low and whose head's son
  lives at the seat as a hostage.

## 9. Inside the sect

- **The succession.** Sở Ngọc Hồ is at the middle of her Nguyên Anh life and has named no heir. Two candidates:
  her first disciple **Khương Lưu Ly** (Kết Đan, ice-born, the old Pavilion) and **Thẩm Hàn Giang** (Nguyên Anh, the
  frost-coast fisher's son who rose through the Hall of Cold Law, and who would be the first male Keeper). The
  frost-coast towns back Thẩm; the elders of the seat back Khương.
- **The case at Hòe Âm.** Tầm Kiếm Đường has sued to cross above Lê Hoa Am's gate, and Thẩm has taken the suit into
  his Hall of Cold Law. He is riding five months south to hear it at Hòe Âm Trấn this autumn, because a ruling for the
  lodge would put the massif's men behind him. Khương's party backs the nuns and has asked the Keeper to read the
  ruling before it is posted. The Keepers have all been women, by custom, and the seat hears a ruling that a women's
  vow cannot close a mountain as a ruling on the Vessel.
- **The pill.** Two old Kết Đan elders, **Tiết Hàn Mai** (440) and **Phó Ám Hương** (480), both near the end of their
  lifespans, need a Nguyên Anh breakthrough pill the sect can afford once in a generation. Tiết is the only one who
  knows the whole Array; Phó is the last of Lãnh Hương. Whoever gets the pill lives. Whoever doesn't, dies.
- **The grand elder on the peak.** Cố Lăng Sương, passed over in 1010, has not come down in 190 years. The sect says
  she resents it. In truth she went up because the founder's last instruction was to watch the volcano from above.
  She has felt it waking for twenty years and has told no one.
- **The hostage.** Hạng Minh Sa has lived at the seat since he was 21. He is Fire-Metal in an Ice sect, outside the
  lineage. He has been taught nothing and has watched everything for 79 years.
- **The dark ink.** The head's second disciple **Cung Mặc Sương** carries a Darkness variant beside her Ice, and she
  hides it. Triệu Huyết Y, the escaped disciple of the ma đạo master her own master killed, has found her.

## 10. Treasures and sets

- **Ice Heart Regalia (Băng Tâm Tam Bảo)**, a set of three: the Jade Vessel of the Ice Heart (the head), the Clear-
  Heart Mirror (the first elder) and the Pavilion's Frost Seal (the head). The set is whole only when the Keeper
  holds the Mirror as well. Tần held all three; Sở Ngọc Hồ has never asked Tiết Hàn Mai for the Mirror.
- **The Red and White Plums (Hồng Bạch Song Mai)**, now a set of three from Lãnh Hương Các: the white sword and his
  father's cape (Phó Ám Hương) and the red sword, lost at Cô Thành. A hook: Phượng Minh took it. Full set: Snow Plum
  cuts alternate swords, every fifth petal lands twice, and crits add an Ice stack.
- **Glacier Vigil (Băng Bích Thủ Tịch)**, Cố Lăng Sương: Frost Lotus Banner, Glacier Bastion Plate, Seal of the Last
  Order. Full set: while her diagram is laid and she is Still, the ward grows each second with no ceiling, and stillness past ten seconds costs her linh lực; when the foe breaks it, the foe gains 4 Ice stacks and is Rooted.
- **Ice-Fisher's Three (Băng Ngư Tam Kiện)**, Thẩm Hàn Giang: Ice-Hole Blade, Seal-Oil Coat, Gourd of Coast Wine. Full
  set: a second wind below half health and five Snow Plum cuts with an extra Ice stack.
- **Keeper of the Lid (Thủ Cái Song Bảo)**, Tiết Hàn Mai (worn beside the Regalia's Mirror): Seal of the Hundred and
  Eight Nodes, Locust-Wood Lid. Full set: her formation mends itself and banks Earth guard; at 10 it cannot break for 3 s.
- **Clear Glaze (Lưu Ly Tam Bảo)**, Khương Lưu Ly: Glazed Frost, Frost Star Ring, Ink-Frost Robe. Full set: at 5 Ice
  stacks the next cut is a sure crit that ignores the ward.
- **Step for Step (Bộ Bộ Tương Tùy)**, Sở Hàn Y: Snow Step, the Winter Robe. Full set: while her ward holds, her Ice
  stacks last twice as long.
- **Black and White Stones (Hắc Bạch Tử)**, Cung Mặc Sương: Ice Knot Needle, Black-Backed Mirror. Full set: a fourth
  Ice stack also curses, and her curses count as Ice debuffs.
- **Fisher's Heirs (Ngư Gia Song Kiện)**, Liễu Ngư Ca: Fisher's Sword, River Ice Gourd. Full set: after 2 s Still, the
  wearer regenerates health and linh lực and loads 2 Ice stacks on the next cut.
- **Phi Tuyết**, Khúc Hồ Già's sword of ice that never melts (C061, legendary item `phi_tuyet`, unheld). It is under the
  ice of place 214, beneath the Array. Digging for it would mean breaking the lid.
- Personal items in `bang_tam.items.json`.

## 11. Roster (pilot: tiers A and B; tier C to follow)

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| so_ngoc_ho | Sở Ngọc Hồ | tông chủ | Nguyên Anh | A | Water 86, Ice 84 | Keeper of the Vessel |
| co_lang_suong | Cố Lăng Sương | thái thượng | Nguyên Anh | A | Water 90, Ice 88 | grand elder on Băng Bích Nhai |
| tham_han_giang | Thẩm Hàn Giang | trưởng lão | Nguyên Anh | A | Water 78, Ice 70, Wood 34 | master of the Hall of Cold Law |
| tiet_han_mai | Tiết Hàn Mai | trưởng lão | Kết Đan | A | Water 72, Earth 50, Ice 54 | first elder, Array keeper |
| pho_am_huong | Phó Ám Hương | trưởng lão | Kết Đan | A | Water 66, Metal 48, Ice 60 | Plum Sword Hall, last of Lãnh Hương |
| khuong_luu_ly | Khương Lưu Ly | chân truyền | Kết Đan | A | Water 80, Ice 76 | the head's first disciple, heir candidate |
| on_sa_ngoc | Ôn Sa Ngọc | trưởng lão | Kết Đan | B | Water 58, Earth 44, Ice 40 | keeper of the Desert Pavilion |
| kha_tinh_ba | Kha Tĩnh Ba | chấp sự | Kết Đan | B | Water 64, Metal 36, Ice 48 | warden of the Ice Soul vein |
| lam_tuyet_dieu | Lam Tuyết Điêu | trưởng lão | Kết Đan | B | Water 62, Wood 40, Ice 46 | Beast Hall |
| nguy_thanh_han | Ngụy Thanh Hàn | trưởng lão | Kết Đan | B | Water 60, Metal 38, Ice 44 | envoy |
| vien_chuoc | Viên Chước | khách khanh | Kết Đan | B | Fire 74, Wood 52 | guest alchemist (R2 exception) |
| so_han_y | Sở Hàn Y | nội môn | Trúc Cơ | A | Water 70, Ice 66 | the head's disciple |
| cung_mac_suong | Cung Mặc Sương | nội môn | Trúc Cơ | A | Water 68, Earth 40, Ice 58, Darkness 30 | the head's second disciple |
| lieu_ngu_ca | Liễu Ngư Ca | nội môn | Trúc Cơ | A | Water 72, Ice 50 | Thẩm's disciple, Hàn Giang's hidden heir |
| ha_lang_han | Hạ Lăng Hàn | chân truyền | Trúc Cơ | B | Water 64, Metal 32, Ice 58 | Phó's last disciple |
| hang_minh_sa | Hạng Minh Sa | (hostage) | Trúc Cơ | B | Fire 62, Metal 55 | Dạ Quang's surety (R2 exception) |
| do_suong_nhi | Đỗ Sương Nhi | chấp sự | Trúc Cơ | B | Water 60, Ice 42 | master of the outer gate |
| ho_tieu_dam | Hồ Tiểu Đàm | ngoại môn | Luyện Khí | B | Water 48, Earth 30 | an oasis girl who failed the Frost Test twice |
| tan_ngung_suong | Tần Ngưng Sương | founder (dead) | Nguyên Anh | A | | founder, lies under the seat |
| pho_thanh_mai | Phó Thanh Mai | (dead) | Kết Đan | B | | Lãnh Hương rider, died at Cô Thành |

## 12. Story hooks

1. **The lid cracks.** Chúc Long Sơn wakes under the Array (A111). Tiết Hàn Mai is the only one who can mend it and
   is dying; Cố Lăng Sương knows; the sect must choose between the pill for Tiết and the pill for Phó. (Tiết, Phó,
   Cố, Sở; place 214.)
2. **The heir.** Sở Ngọc Hồ names no heir; the frost coast and the seat take sides; a duel, a poisoning or a death
   in the vein decides. (Thẩm, Khương, Liễu Ngư Ca, Kha Tĩnh Ba.)
3. **Hàn Giang's heir.** Liễu Ngư Ca carries the last Hàn Giang ice-hole manual and his blood; Lãnh Giang Phái and
   Trạc Anh Đài would rise for him. (Liễu Ngư Ca, Đoàn Thanh Lãng, Thẩm.)
4. **The dark ink.** Triệu Huyết Y courts Cung Mặc Sương with the method her Darkness needs; the player may find
   them, expose her, or help her. (Cung, Triệu Huyết Y, Sở.)
5. **Phi Tuyết under the ice.** A treasure hunter, or the player, learns that Khúc Hồ Già's sword lies under the seat;
   to dig is to break the Array. (place 214; Cố.)
6. **The red plum.** The lost red sword of the Plum pair turns up in Phượng Minh Cung's treasury; Phó Ám Hương, dying,
   wants it back before he goes. (Phó, Hạ Lăng Hàn, Hoa Triêu Dương.)
7. **The hostage comes of age.** Hạng Dạ Bôi is old; Dạ Quang wants its heir home; Băng Tâm will not let him go.
   (Hạng Minh Sa, Hạng Dạ Bôi, Ôn Sa Ngọc.)
8. **The Frost Test.** The player, Water-rooted without Ice, sits the test on the frozen mere of Hàn Giao Chử. (Đỗ
   Sương Nhi, Hồ Tiểu Đàm; place 239.)
9. **The Mirror.** The Regalia is whole only in one pair of hands; Tiết Hàn Mai's death will decide who holds the
   Mirror. (Sở, Tiết, Khương.)
10. **The vein petition again.** Ngụy Thanh Hàn wants to redeem 1188 with a new claim, this time with proof the Pivot
    cannot refuse. (Ngụy, Doãn Ngọc Hành.)
