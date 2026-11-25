# Hộ Lâm Đường (護林堂), the Hall of the Forest Wardens

> **Status**: World-depth pass, 2026-11-25 (minor sect writer, Thúy Vi's vassals). Proposal: nothing here is in game
> data. Rules: `../rules-proposals.md` R1-R8. People: `ho_lam.cast.json`; công pháp: `ho_lam.techniques.json`; items:
> `ho_lam.items.json`. Lord's page: `thuy_vi.md`.

## 1. At a glance

| | |
|---|---|
| Kind | Minor sect, vassal of Thúy Vi Tông (loyalty 65), righteous (chính), founded 910 |
| Leans | Wood, Earth → **Wood, Water** (R4 re-lean: the seat holds Wood 48 %, Water 17 %, Earth 14 %) |
| Lineage elements | Wood first, then Water |
| Seat | **stays** at Hộ Lâm Đường (place 1105), a timber hall at the edge of the northern woods |
| Head | Lục Thanh Sam, Kết Đan, founder and head since 910 |
| Size | about 45 wardens, raftsmen and seedbed hands; 11 living named here |
| Way of life | forest wardens: they keep the northern woods, ask the spirit trees, and raft the wood to the lord's furnaces |

A long, low hall of unbarked logs at the forest's edge, with a hornet valley and a flying-squirrel wood in its keeping. It looks like a lumber camp, and it is one. Every green fire at Thúy Vi burns wood this hall cut, and every
log was asked first. Its wardens spend a night beside a spirit tree before they fell it, then send it down the river on the spring flood under a green banner, to season at the boom and go on to the lord in autumn. The hall has never sold a log to anyone but its lord, and it is one log short
this year.

## 2. Land and seat

**Decision (R4): stay, and re-lean Wood/Earth → Wood/Water.** The seat's Wood passes easily (48 %). Earth fails by one
point: 14 %, against 15 % and outside the seat's top two, which are Wood and Water. The audit offers six candidates. Cổ
Dịch Trấn (1110) is now the lord's seat. Thương Thúy Lâm (1109) is its herb terraces. Vọng Bắc Bảo (1123) is the fort
the lord left empty in 910 (V027), when it gave the wardens this hall instead. The rest are thin ruins or a bare peak.
Moving would put the wardens either inside their lord's house or out of the woods they keep. The Earth lean was never
theirs. It was copied from the lord's record in 910, along with the lord's outer primer. The hall's work has always
been the tree and the river, and the river has carried the wood since Đằng Bích Lưu brought the raft art in 960. The
record now says so.

**What the re-lean costs (to do when approved).**
- **Data.** `leans` in `world_continent.json` (minor_sects) and the start state become `["Wood", "Water"]`. Nothing
  moves: no art, route, province or density change.
- **People.** One Earth-rooted warden from before 1162 (Phú Hậu Thổ) keeps his place under an exception. The head's Earth
  is from his field years in the lord's outer gate, and his Wood passes the core rule.
- **Chronicle.** V028 stays true. Add N-ho_lam-01 to -04. The 1162 primer (N-ho_lam-04) is the in-world date of the
  re-lean.

**The ground.** The hall stands at 0.14 km in the temperate forest of Thanh Loan Lĩnh's north. The Valley of the Poison
Hornets (Độc Phong Cốc, 1104) and the Forest of the Flying Squirrels (Phi Thử Lâm, 1159) lie within its keeping. The
wardens' woods run east to the river villages of Thủy Ma Thôn (1106) and Tạo Chỉ Thôn (1108) and the raftsmen's village
of Phiệt Công Thôn (1099). They run south to the white-wax village of Bạch Lạp (1113), the Spring of Spirit Dew (Linh Lộ
Tuyền, 1117) and the Forest of First Light (Sơ Hiểu Lâm, 1112), where the Grandmother Fir stood. The brown bears of Tông Hùng Lâm (1107) are the wardens' oldest trouble. Poachers are the newest.

**How the land shapes its people (R1).** The forest villages round the hall (Bạch Lạp 48 %, Tử Tô 48 %, Hồ Đào 45 %,
Việt Quất 39 % Wood) breed Wood roots, and they fill the inner gate. The river villages (Thủy Ma 27 %, Tạo Chỉ 29 %,
Phiệt Công 26 %, Tân Cư 29 % Water) breed Wood-Water roots, the raftsmen. Earth roots are almost unknown here (11-17 %),
which is the other reason the old lean never fitted.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 861 | Lục Thanh Sam, a chandler's son of Bạch Lạp, enters Thúy Vi's outer gate | |
| 880 | He passes the First Leaf and asks to stay in the woods with the wardens | |
| 910 | With the Cold Ford home, Thúy Vi leaves Vọng Bắc Bảo empty and makes its wardens a hall | V027, V028 |
| 912 | The wardens take up the rite of asking as their own law | **N-ho_lam-01** |
| 960 | Đằng Bích Lưu brings the raft art from Thủy Ma Thôn; the wood goes down on the spring flood | |
| 990 | Sư Tuyết Tùng dies guarding a felled log from the brown bears | **N-ho_lam-02** |
| 1150 | The Grandmother Fir of Sơ Hiểu Lâm is felled for the Green Furnace on the night of Úy's breakthrough | N-thuy_vi-10, **N-ho_lam-03** |
| 1161-1162 | A spring flood takes half the year's rafts; Lục writes the hall's own primer | **N-ho_lam-04** |
| 1186 | A poacher of Tân Cư Thôn is caught felling a spirit tree and handed to Thúy Vi | |

**New chronicle proposals:**
- **N-ho_lam-01** (912, `custom`): "Hộ Lâm Đường's wardens swear the rite of asking as their first law: no spirit tree
  is felled until a warden has spent a night beside it."
- **N-ho_lam-02** (990, `death`): "The brown bears of Tông Hùng Lâm come for a felled spirit log, and the warden Sư
  Tuyết Tùng stands over it until he dies."
- **N-ho_lam-03** (1150, `tale`): "The Grandmother Fir of Sơ Hiểu Lâm, the greatest spirit tree in the northern woods,
  is felled after a night of asking and burned in the Green Furnace on the night Úy Thanh Diễm forms his Nascent Soul.
  The drought had dried the green wood of the northern woods, so only the Fir would do. The hall says the tree said
  yes." (The truth is in section 9.)
- **N-ho_lam-04** (1162, `custom`): "After the spring flood of 1161 takes half the rafts, Lục Thanh Sam writes the
  Raft-and-Root Primer for the hall's outer gate, in place of Thúy Vi's Seed and Soil Primer."

## 4. Doctrine and customs

- **Ask first.** The hall's one law is Thúy Vi's rite of asking, kept more strictly than Thúy Vi keeps it. A warden
  sits a night beside a spirit tree with a palm on its bark, and fells it at dawn only if it has answered. Wardens
  describe the answer differently, as a slowing, a warmth or a sound like breath. Every one of them says they know it
  when it comes. A tree that does not answer is left standing, and the hall finds another.
- **One stroke.** A tree that has said yes is felled in one stroke, by the head if he is there. A second stroke is a
  shame on the warden who needed it.
- **The tree goes to the fire it was asked for.** Wood is cut for a named furnace and goes nowhere else. Selling a
  log past the lord, or to a furnace it was not asked for, is the hall's worst crime after felling unasked.
- **The river carries it.** Logs go down on the spring flood, lashed into rafts and led by the green banner, to the seasoning boom at Tân Cư Thôn (1101). In autumn the Phiệt Công raftsmen take them the last stretch to the lord's stores. The
  raftsmen sing on the river, loudly, because Không Sơn's rule about quiet stops at the forest's edge.
- **Dress:** bark-brown wool coats, hornet-veil hats in summer, axes on the back. Raftsmen go barefoot.
- **Food:** forest food: mushrooms, nuts, smoked boar, spirit honey from the hornet valley's edge (taken at night, with
  smoke, by one man only).
- **The dead:** a warden is buried at the foot of the last tree they asked. If that tree was felled, they are buried in
  its stump.
- **Taboos:** felling unasked; a second stroke; burning a spirit log for warmth; lying about an answer.
- **Outsiders:** treated as possible poachers until they have been in the woods a season.
- **How others see them:** honest, slow, rough, and the most loyal vassal Thúy Vi has. The lord's elders mostly forget
  them until the wood is late.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Outer gate | Raft-and-Root Primer (Phiệt Căn Quyết) | main, Yellow | Wood or Water | proposal (Lục Thanh Sam, 1162) |
| Inner gate and above | Verdant Cycle Scripture (Thanh Hoàn Kinh) | main, Profound | Wood | existing (`catalogue-wood.json`), by the lord's leave |
| Inner gate | Night Beside the Tree (Túc Thụ Quyết) | secret, Profound | Wood | proposal (the rite of asking) |
| Raft masters | Spring Flood Raft Art (Xuân Lũ Phiệt Pháp) | secret, Profound | Water | proposal (Đằng Bích Lưu, from Thủy Ma Thôn) |
| Before 1162 | Seed and Soil Primer (Chủng Thổ Quyết) | main, Yellow | Wood or Earth | Thúy Vi's; one old warden still runs on it |

**Why it fits.** The wardens' work is a tree and a river, and the lineage is the same. The inner gate learns the
lord's own Profound Wood scripture: the hall was the lord's warden corps before it was a sect, and the Verdant Cycle
(sow, root, mend, harvest) is a forester's method anyway. The night of asking is the hall's own, and so is the raft
art. Its weakness is fire: it has no Fire and fears it. Every warden knows what happened to Tùng Chi Trấn's
forest in one dry night in 1061 (V016). Members on the lineage: 10 of 11. One old warden (Phú Hậu Thổ) runs on
the lord's old primer under an exception.

## 6. Admission (R2 as the sect applies it)

- **Outer gate:** Wood or Water at 30, and the First Raft: ride one spirit log from the hall to the boom at Tân Cư Thôn
  without letting it touch a bank. Recruits come from the forest and river villages, plus one poacher's son.
- **Inner gate and above:** Wood at 45, and a first night beside a spirit tree. The tree has to answer, and the Listener
  has to agree that it did.
- **Exceptions kept:** Phú Hậu Thổ, an Earth root admitted in 1120 under the old lean, kept by the head's word.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The hall and the felling | seat, 1105 | Lục Thanh Sam |
| The rafts and the spring flood | the river; Thủy Ma Thôn (1106), the boom at Tân Cư Thôn (1101), Phiệt Công Thôn (1099) | Đằng Bích Lưu |
| The rite of asking (the Listener) | wherever a tree is to be felled | Mi Túc Thụ |
| The tallies | seat; the other end at Thúy Vi's spirit-wood stores | Lục Lưu Mộc |
| The hornet valley | Độc Phong Cốc (1104) | Nghệ Hoàng Phong |
| The eastern woods and the poacher watch | Việt Quất Thôn (1161), Tân Cư Thôn (1101) | Lại Hoành Chi |
| The seedbeds | seat | Phú Hậu Thổ |

## 8. Relations

- **Thúy Vi Tông (lord, loyalty 65):** the hall began as the lord's own wardens and has never stopped being them. Lục
  and the first elder Quyền Thanh Lam were outer disciples together. Every log goes to Phí Tùng Chi's stores at the
  seat, and the raftsman's son Sầm Ngưu Tất brings them down from the boom each autumn. Lục loads his rafts himself. The Green Furnace depends on
  this hall's wood, and the hall has never used that. In 1150 it felled the greatest tree in the north for Úy Thanh
  Diễm's breakthrough, and Úy has never been told what that night cost.
- **Hồng Lô Cốc:** wants wood for its Satchel Hall and has asked three times. Lục sends it nothing past the lord, so
  Hồng Lô buys from the Furnace Hall's surplus at the lord's price. Lại Hoành Chi thinks this is foolish.
- **Phượng Minh Cung:** buys spirit wood from Thúy Vi, and in 1199 one Phượng Minh buyer bought a log from Lại Hoành Chi
  directly at Lam Yên Thị.
- **Vụ Ẩn Môn, Vân Khởi Quán:** distant and friendly.
- **The poachers of the north woods:** the hall's enemy. Some are from Tùng Đào's side of the border, and Thúy Vi's Hall
  of Rules judges the ones the wardens catch.

## 9. Inside the sect

- **The tree that did not answer.** In 1150 Lục sat the night beside the Grandmother Fir with Mi Túc Thụ, and the tree
  gave no answer. Úy Thanh Diễm's breakthrough was set for that night, the drought had dried the green wood of the
  north, and no other tree was great enough. Lục felled it at dawn and told the hall it had said yes. No spirit seedling
  has come up in Sơ Hiểu Lâm since. He wears a disc of its heartwood at his throat. Mi has never said what she heard
  that night. She goes back to the forest every spring to look for seedlings, and she has found none.
- **The log and the poacher.** Lại Hoành Chi sold a spirit log past the lord to a Phượng Minh buyer at Lam Yên Thị in
  1199, and it was not his first. In 1186 the poacher of Tân Cư Thôn was felling for him. When Phí Tùng Chi began
  counting stumps, Lại handed his own feller to the lord's Hall of Rules, took the reward for the catch, and sold the
  log anyway. The buyer now wants ten more. This spring Lại means to cut the second loose from the rafts at the boom
  and cart it the fifty days to Lam Yên Thị himself.
- **The head's son.** Lục Lưu Mộc is 190 and never formed a core. He is the first in the hall to be dying of age while
  both his parents live. Đằng Bích Lưu is looking for a pill and has written to Hồng Lô, which surprised everyone.
- **The poacher's son.** Bỉnh Thiết Phủ was four in 1186, and he sat on his father's log in the cart when Lại drove it
  away. Lục took the boy in and gave him an axe. This spring Bỉnh has asked to ride the rafts to the boom, and he
  means to follow the second log all the way to Lam Yên Thị and watch it sold.

## 10. Treasures and sets

- **The Asking Axe (Vấn Thụ Phủ)**, the head's felling axe since 910, one stroke per tree.
- **Heart of First Light (Sơ Hiểu Tâm Mộc)**, heartwood of the Grandmother Fir, at the head's throat since 1150.
- **Banner of the Lead Raft (Đầu Phiệt Kỳ)**, flown at the front of every spring flood since 960.
- **First Light (Sơ Hiểu Tam Kiện)**, Lục Thanh Sam: the Asking Axe, Heart of First Light, White-Wax Warden's Robe.
  Full set: each axe stroke roots him for 6 s, regenerating, and foes who hit him gain Wood stacks.
- Details in `ho_lam.items.json`.

## 11. Roster (11 living, 1 dead: tier A 1, B 4, C 7)

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| luc_thanh_sam | Lục Thanh Sam | tông chủ | Kết Đan | A | Wood 68, Water 42, Earth 30 | Founder and head |
| dang_bich_luu | Đằng Bích Lưu | trưởng lão | Kết Đan | B | Water 58, Wood 52 | Raft master; the head's Dao partner |
| lai_hoanh_chi | Lại Hoành Chi | nội môn | Trúc Cơ | B | Wood 62, Water 36 | Eastern woods; sold a log |
| mi_tuc_thu | Mi Túc Thụ | chấp sự | Trúc Cơ | B | Wood 64, Water 34 | The Listener |
| nghe_hoang_phong | Nghệ Hoàng Phong | nội môn | Trúc Cơ | C | Wood 56, Water 30 | Hornet keeper |
| luc_luu_moc | Lục Lưu Mộc | chấp sự | Trúc Cơ | C | Wood 54, Water 48 | Tally keeper; the head's son |
| luc_tieu_sam | Lục Tiểu Sam | nội môn | Luyện Khí | C | Wood 58, Water 34 | The head's granddaughter |
| binh_thiet_phu | Bỉnh Thiết Phủ | ngoại môn | Luyện Khí | C | Water 46, Wood 32 | A poacher's son |
| phu_hau_tho | Phú Hậu Thổ | ngoại môn | Luyện Khí | C | Earth 50, Wood 26 | Seedbeds; old Earth root (R2 exception) |
| tac_ha_thang | Tác Hà Thằng | ngoại môn | Luyện Khí | C | Water 52, Wood 36 | Raftsman |
| truc_linh_lo | Trúc Linh Lộ | ngoại môn | Luyện Khí | C | Wood 50, Water 28 | Gathers spirit dew |
| su_tuyet_tung | Sư Tuyết Tùng | trưởng lão (dead) | Trúc Cơ | B | | Co-founder; died 990 |

## 12. Story hooks

1. **A seedling in First Light.** Lục Tiểu Sam finds one spirit seedling in Sơ Hiểu Lâm, the first in fifty years. Mi
   Túc Thụ knows what it would mean, and Lục is afraid to go and look. (Lục Tiểu Sam, Mi Túc Thụ, Lục Thanh Sam; place
   1112.)
2. **What Mi heard.** Thúy Vi asks the hall for a great tree again, for a breakthrough in the Green Furnace, and Lục
   must sit the asking with Mi Túc Thụ beside him. She has told him she will say what she hears out loud this time, in
   front of the hall, and the player may be the one sent to bring Úy Thanh Diễm to hear it. (Mi Túc Thụ, Lục Thanh
   Sam, Úy Thanh Diễm; places 1105, 1110.)
3. **The second log.** Lại Hoành Chi's Phượng Minh buyer wants ten more logs, and Hồng Lô's Satchel Hall would take
   five. In autumn Phí Tùng Chi counts the rafts against the spring list and finds one short, and Lại says the flood
   took it at the boom. (Lại Hoành Chi, Phí Tùng Chi, Giải Bách Bộ, Lục Thanh Sam; places 45, 1105, 9.)
4. **The spring flood.** The flood comes early and high. The lead raft carries the wood for the lord's spring brewing,
   Đằng Bích Lưu is on it, and the boom at Tân Cư Thôn is under water. (Đằng Bích Lưu, Tác Hà Thằng, Sầm Ngưu Tất; places 1101, 1099, 1110.)
5. **The bears come down.** The brown bears of Tông Hùng Lâm, which killed Sư Tuyết Tùng in 990, come out of the hills
   after a felled log for the first time in two centuries. (Lục Thanh Sam, Nghệ Hoàng Phong, Bỉnh Thiết Phủ; places
   1107, 1105.)
6. **The poacher's son.** Bỉnh Thiết Phủ follows Lại Hoành Chi's cart from the boom to Lam Yên Thị and watches the
   second log sold. He can avenge his father, carry what he saw to the Hall of Rules that took his father, or become
   the next man to break the hall's law. (Bỉnh Thiết Phủ, Lại Hoành Chi, Nhạc Chính Hành; places 1101, 45.)
7. **A pill for the tally keeper.** Đằng Bích Lưu asks Hồng Lô for a pill to give her son another century. Đồng Hồng Lô
   asks for wood past the lord in payment. (Đằng Bích Lưu, Lục Lưu Mộc, Đồng Hồng Lô, Lục Thanh Sam; places 1105, 9.)
8. **Poachers from across the border.** A Tùng Đào poaching crew is felling spirit trees unasked on the northern edge of
   the woods, and the hornets have gone quiet. (Lại Hoành Chi, Nghệ Hoàng Phong; places 1104, 1161.)
