# Thúy Vi Tông (翠微宗), the Sect of the Emerald Haze

> **Status**: Sect writer pass, overnight 2026-11-24/25 (world-depth pass, Stage 2 smoke test). Proposal: nothing here
> is in game data. Rules it applies: `../rules-proposals.md` R1-R8. People: `thuy_vi.cast.json` (Nguyên Anh, Kết Đan,
> the dead), `thuy_vi.2.cast.json` (Trúc Cơ), `thuy_vi.3.cast.json` (Luyện Khí); công pháp: `thuy_vi.techniques.json`;
> items: `thuy_vi.items.json`.

## 1. At a glance

| | |
|---|---|
| Kind | Great sect, tier 2, righteous (chính), founded 500 |
| Lord / vassals | none / Hồng Lô Cốc, Vân Khởi Quán, Vụ Ẩn Môn, Hộ Lâm Đường |
| Leans | Wood, Earth (unchanged) |
| Lineage elements | Wood first, then Earth (R5) |
| Seat | **moves** from the Metal ridge (place 1, the founder's seat) to **Cổ Dịch Trấn** (place 1110, the Old Post Town), done in 1001-1006 |
| Head | Ngu Lam Sơn, Nguyên Anh, who never learned a killing art |
| Size | about 250 members: 70 living named here, the rest drawn under R1/R2 |
| Specialty | alchemy (đan sư): pills brewed over green spirit-wood fire, herbs, spirit fields |

The sect is green, slow and patient. It believes a person is grown, not forged, and it is suspicious of anything
quick, including talent. It is rich from pills and poor in fighters. It has lost one war and won one, both against Tùng
Đào over the same coast. Two hundred years ago it came down off its founder's mountain, and the old guard has not
forgiven it.

## 2. Land and seat

**Decision (R4): move the seat to Cổ Dịch Trấn (place 1110).** The founder's seat (place 1) sits on a high ridge at 1.54 km
whose strongest qi is Metal (38 %; Wood and Earth 20 % each). For a Wood sect that is the one land the Five Phases
forbid: Metal cuts Wood (kim khắc mộc). The sect's own ground is green from end to end. The northern forests of Thanh
Loan Lĩnh (region 3) run 40-56 % Wood, and the cape of Tuyết Hỏa Giác (region 2) has Wood forests inland and a Water
coast. All six of the audit's candidates fit. The constraints that separate them are density and dates.

| Candidate | Land | Wood | Earth | Density | Verdict |
|---|---|---|---|---|---|
| Cổ Dịch Trấn (1110), ruin, lived 520-980 | temperate forest, 0.29 km | 38 % | 18 % | 2.00 as a ruin; about 1.85 as a seat | **seat**: the densest Wood land on the ground, and it has a story |
| Vọng Bắc Bảo (1123), fort, 672-910 | temperate forest, 0.56 km | 26 % | 22 % | 1.63 | empty since 910 (V027); too thin for a great seat |
| Thương Thúy Lâm (1109), forest | temperate forest | 45 % | 15 % | 1.46 | **the Herb Gardens' terraces** (osmanthus, Hàn Mộc Tê) |
| Vân Gian Trấn (1130), ruin | high mountain | 26 % | 22 % | 1.37 | left to the avalanche's dead (V031) |
| Đồng Sơn Trấn (1056), Hoành Kiều Trấn (1160) | forest ruins | 32-33 % | 18-20 % | 1.15 | too thin |

**The story.** Phùng Yên Hà built on the ridge in 500 (C010) because from it she could see every hill Thôi Bất Kiến
had given her (C100). She planted a pine in the rock by the gate, and the sect lived there for five hundred years. Its
Wood disciples cultivated slowly on Metal ground. The sect made up for it with pills, which is how Thúy Vi became the
alchemy sect of the north. The founder died in 1000 at 640 (C173). Those who nursed her say she stiffened like bark
in her last century, a Wood root starved on Metal ground. Ngu Lam Sơn walked in the haze for a hundred days before his first order (A045). He ended the walk at the empty inns
of Cổ Dịch Trấn. The Lam Yên road had been moved east from that town in 975 because the forest took back a li of it
every spring (N-thuy_vi-01, giving V030 its cause), and its last inn had closed in 980. The town sat on a root-vein that
nobody had noticed, and its inn gardens had always grown too well. The green haze the sect is named for pools thickest
there. Ngu's first order was "We go down" (N-thuy_vi-02). The sect moved its halls in 1001-1006 (N-thuy_vi-03).
Quyền Thanh Lam carried the founder's terrace soil down in baskets. Úy Thanh Diễm carried the Green Furnace on his back,
still burning. Cù Thúy Bách would not come.

**What the move costs (to do when approved).**
- **Chronicle.** C010, A040, V029, A045 and C173 stay true as written: each is dated before the move or happens at
  place 1. Add N-thuy_vi-01 to -03 (975, 1000, 1001-1006).
- **Art.** Place 1's seat painting and prompts (`design/map/continent-11/art/places/prompt_1.md`, `stages/level_1_1.md`,
  `level_1_2.md`) become the Cliff Hall: the same terraces, half empty, a twisted pine growing sideways out of the rock
  by the gate. Place 1110 needs a new seat painting (wooden halls in deep forest, haze, no walls) and a great-seat map
  symbol.
- **Routes.** Place 1110 is off-road. Add a road from Lam Yên Thị (45) to 1110 (about 7 tiles) and tracks to Thương
  Thúy Lâm (1109) and Phục Linh Thôn (1111). The trunk from place 1 to Lam Yên Thị stays as the pilgrims' road to the
  Cliff Hall.
- **Province.** The seat record moves to `prov_r3_15`, the province of place 1110. Place 1 has no province recorded in
  `world_continent.json`; its neighbours (Quy Tịch Phong, 1486) are `prov_thuy_vi`.
- **Density.** Place 1110's land density is 1.75. The data adds a fixed amount by place kind (ruin +0.25, great seat
  +0.10), so as a seat it would read about 1.85 against the old seat's 1.94. Proposal: `seat_array_density` +0.1 from
  the **Spring Return array** Tất Hành Vụ laid over the root-vein in 1006, which brings the seat back to about 1.95. If
  the array is broken (a hook), the seat thins to 1.85 and the haze over it lifts.
- **Place records.** Place 1110: kind ruin → great_seat, named Thúy Vi Tông (the district keeps the name Cổ Dịch).
  Place 1: kind great_seat → sect hall, named **Thúy Vi Nhai Đường, the Cliff Hall**. Lam Yên Thị's note ("below Thúy Vi
  Tông's seat") becomes "between the two halls of Thúy Vi, in the haze that names it".
- **Old seat (place 1)** becomes the **Cliff Hall**. It keeps the founder's grave, the founder's pine, the life trees
  of every disciple who joined before 1006, and a teaching harsher than the slope's (`rock-splitting-root`). About
  thirty people live there under Cù Thúy Bách.

**How the land shapes its people (R1).** The forest villages of the north (Phục Linh, Bạch Lạp, Tử Tô, Hồ Đào:
45-48 % Wood) and the cape's inland woods (Tùng Nhung, Thằng Tác, Thiêu Thán: 49-56 %) breed Wood roots about twice as
often as an even land. Those villages fill the inner gate. The coast and the cape's grasslands (Hàn Tân, Yên Ba, Mục Ca,
Bạch Sa: 38-55 % Water) breed Water-Wood roots, so coast children enter the outer gate on their Wood and seldom rise.
Hướng Dạ Đăng did. The high ridges round the old seat (Bích Ngọc Khoáng, Quy Tịch Phong: up to 51 % Metal) breed Metal
roots, so the sect's own ridge children often fail its gate: Lã Trác Thạch, Đinh Lão Hòe, and the Metal streak in Cù
and Hoàn. Earth never passes 24 % anywhere on the ground. Earth roots are rare, and the Field Hall brings them in from
the Pivot's and Lạc Hà's cities (Phạm Thủ Điền, Mễ Điền Nhi, Lỗ Kiên). The sect therefore holds three peoples: the forest
born, who run it; the coast born, who guard it; and the ridge born, who remember it.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 180-460 | Bùi Lộc Trại founds Không Sơn Viện on the empty mountain; woodcutters are asked to sing more quietly; the jade is left unmined | C054, A033, A034, A035 |
| 460 | Thôi Bất Kiến masters Không Sơn and takes one student, Tống Tọa Vân | C094 |
| 500 | **The Gift of the Empty Mountain**: Thôi gives the hills, the White Cloud Whisk and his student to Phùng Yên Hà, who founds Thúy Vi on the ridge | C100, C010 |
| 505 | The green jade mine is opened; the sect's seal is cut from its first stone | A037 |
| 510 | The North Star Compact | C107 |
| 520 | Thôi dies in the empty academy; Phùng leaves it unlocked and unlooted | A038 |
| 540 | Tống Tọa Vân leaves to found Vân Khởi Quán, where the water ends; Âu Dương Thanh Lô fires the Green Furnace | C114 |
| 560-700 | The cape taken; Yên Ba Thành and Mục Ca Thành founded; the fire-jade chart sealed; Hồng Lô Cốc founded in a tundra valley on the cape's north coast | C115, A022, C120, A024, C139 |
| 668-672 | **Haze-and-Pine War**: Tùng Đào takes the Cold Ford without a writ; Hướng Đông Lâm dies on the quay; Chung Hoài Cực lets it stand | C135, C136, **N-thuy_vi-05** |
| 674-690 | The resin tax: Cold Ford fishers flee to the hills, Tân Cư Thôn founded, Lô Khẩu Trấn's quays lost to the marsh | A041, V024, V025 |
| 744 | Thôn Hải's pirates burn Lam Triều Các; Mẫn Triều Âm dies on the point | V010 |
| 781 | The pirates of Ẩn Loan vanish, leaving salt and a child; Ngu Lam Sơn carries her up the ridge | A026, **N-thuy_vi-04** |
| 901-905 | **Cold Ford War** under the Pivot's writ; Tân Hàn Chu goes through the ice in 904; the ford comes home; lamps on every boat | C165, C166, A044, **N-thuy_vi-06** |
| 910 | Vọng Bắc Bảo left empty; the forest wardens found Hộ Lâm Đường | V027, V028 |
| 932 | Bách Thảo Viện's fire cauldron bursts; Âu Dương Thanh Lô dies saving a child; the herb books come to the seat | V029 |
| 975-980 | The Lam Yên road is given up to the forest; Cổ Dịch Trấn empties | **N-thuy_vi-01**, V030 |
| 1000 | Phùng Yên Hà dies at 640; Ngu Lam Sơn walks a hundred days and orders the sect down | C173, A045, **N-thuy_vi-02** |
| 1001-1006 | **The going-down**: the sect moves to Cổ Dịch; Cù Thúy Bách stays; the old seat becomes the Cliff Hall | **N-thuy_vi-03** |
| 1048-1050 | Tất Hành Vụ teaches the Haze Walk to his sworn brother, who founds Vụ Ẩn Môn on the cape | **N-thuy_vi-07**, V015 |
| 1066 | Minh Kính Đường's head brings his tribulation down on the hall | V033 |
| 1101 | Thanh Nang Đường's healers go to Hồng Lô; Dư Tục Đoạn comes to Thúy Vi | V018 |
| 1150 | Úy Thanh Diễm forms his Nascent Soul over the Green Furnace | **N-thuy_vi-10** |
| 1166 | A baby is left at the Green Door in Lam Yên Thị | **N-thuy_vi-12** |
| 1172 | Six Tùng Đào patrolmen vanish on the river-mouth ice; Tùng Đào lists them as deserters | **N-thuy_vi-11** |
| 1180 | Peach petals come down a forest stream to Lăng Giác Thôn; Kê Lăng Hoa follows them and loses three days | A030, **N-thuy_vi-09** |
| 1195 | Ngu Lam Sơn plants the Heir's Garden; a traveller hears reading in empty Không Sơn Viện | **N-thuy_vi-08**, A048 |

**New chronicle proposals** (for `chronicle_proposal.json` once approved):
- **N-thuy_vi-01** (975, `road_moved`): "The road wardens of Lam Yên give up the road through Cổ Dịch Trấn: every
  spring the forest takes back a li of it, and the road is moved east."
- **N-thuy_vi-02** (1000, `tale`): "Ngu Lam Sơn ends his hundred days in the haze at the empty inns of Cổ Dịch Trấn,
  and gives his first order as head: 'We go down.'"
- **N-thuy_vi-03** (1001-1006, `seat_moved`): "Thúy Vi Tông carries its halls down from the founder's ridge to Cổ Dịch
  Trấn. Cù Thúy Bách stays with the founder's pine, and the old seat becomes the Cliff Hall."
- **N-thuy_vi-04** (781, `tale`): "Ngu Lam Sơn finds the child of Ẩn Loan cove eating kelp on the beach and carries her
  up to the ridge; the sect names her Diêm Hải Tảo, for the salt and the weed."
- **N-thuy_vi-05** (672, `death`): "Hướng Đông Lâm, Warden of the Cold Ford, will not leave the quay of Hàn Tân and dies
  beside his lamp; the fishers hide the lamp."
- **N-thuy_vi-06** (904, `death`): "Tân Hàn Chu takes forty disciples across the river-mouth ice at night under Tùng
  Đào's arrays; the ice breaks."
- **N-thuy_vi-07** (1048, `tale`): "Tất Hành Vụ teaches the Haze Walk to his sworn brother, a road guard of the cape."
- **N-thuy_vi-08** (1195, `custom`): "Ngu Lam Sơn plants three plots of the Heir's Garden and gives them to Thiệu Thanh
  Đài, Hoàn Cô Bách and Hướng Vãn Chu; he will judge them in 1205."
- **N-thuy_vi-09** (1180, `omen`): "Peach petals come down a forest stream to Lăng Giác Thôn in spring. A disciple
  follows them and comes back three days later with no memory of the three days."
- **N-thuy_vi-10** (1150, `breakthrough`): "Úy Thanh Diễm forms his Nascent Soul over the Green Furnace, which does not
  go out."
- **N-thuy_vi-11** (1172, `tale`): "Six of Tùng Đào's border patrol do not come back from the river-mouth ice of the
  Cold Ford; Tùng Đào lists them as deserters."
- **N-thuy_vi-12** (1166, `tale`): "On the Green Door Day a baby is left on the step of Thúy Vi's door in Lam Yên Thị,
  wrapped in green inner-gate silk."

## 4. Doctrine and customs

- **A person is grown, not forged.** The sect's one teaching. Growth takes seasons, and nothing that grows can be
  hurried without harm. The Five Phases give the teaching its edge: Metal cuts Wood, so the sect distrusts the forge,
  the blade and the quick talent. It worries about Kiển Viễn Chí more than it praises him.
- **The empty green wets the robe.** The sect's line is Vương Duy's: the mountain road had no rain, yet the empty
  green wet our clothes (sơn lộ nguyên vô vũ, không thúy thấp nhân y). Its robes are hemp dyed green-grey with
  haze-grown indigo, and the slope's robes are always damp at the hem. The Cliff Hall wears dry, undyed hemp. In any
  gathering you can tell the factions by their hems.
- **The life tree (bản mệnh thụ).** Every disciple plants a tree on the day they join. The outer gate's sixth layer is
  that tree's first spirit leaf. A disciple is buried at its root, sitting, facing uphill. A dying tree is an omen,
  and the Cliff Hall's steward makes the 200 km journey down to the new seat, about two weeks on foot, to tell its owner. The life trees of every disciple who joined
  before 1006 are on the ridge. That is the real reason the Cliff Hall cannot be emptied.
- **Herb names.** Foundlings and children raised in the sect are named from the herb book (Diêm Hải Tảo, Kiển Viễn
  Chí, Thường Độc Hoạt). The villages of the ground copied the custom long ago, so herb names are common there. Only
  the sect's foundlings have no other name.
- **The walking council (hành nghị).** Since Ngu's hundred days, nothing is decided sitting. Councils are held on a
  path, the head walking and the elders beside him. A quarrel that cannot be settled before the path ends goes round
  again. Visitors from the Pivot find it maddening.
- **Green fire only.** The furnaces burn spirit wood from Hộ Lâm Đường and nothing else. Burning dead wood at the seat
  is taboo ("dead wood smokes the haze"). Spirit wood is never felled without the rite of asking: a night spent beside
  the tree first.
- **No blade in the haze.** The sect carries poles, wood-axes, needles, fans and banners. A sword brought to the seat
  is carried wrapped. Its fighters are few and good at not being hit.
- **The Green Door Day (Thanh Môn Nhật).** Once a month the Healing House opens its door in Lam Yên Thị and treats
  anyone for nothing. Half the sect's recruits and one of its foundlings came through that door.
- **Food.** The sect eats what it grows, and nothing killed is cooked inside the haze. The coast eats fish, salted, at
  the Cold Ford Hall and the port house. The slope and the coast have joked about it for six hundred years.
- **Guests.** Tea on arrival, and "the haze keeps no guest past nine days": a guest leaves on the ninth day or asks to
  join.
- **Taboos:** felling a spirit tree without asking; burning dead wood; using the Haze Walk to strike unseen; the
  Rotting Canopy Canon (`rotting-canopy-canon`, sealed in the Furnace Hall's shelf); speaking loudly on the slope.
  The last is inherited from Không Sơn, whose woodcutters were asked to sing more quietly (A033).
- **How others see them:** rich, soft and slow. The sect does not mind the first two words.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Outer gate | Seed and Soil Primer (Chủng Thổ Quyết) | main, Yellow | Wood or Earth | proposal |
| Inner gate | Verdant Cycle Scripture (Thanh Hoàn Kinh) | main, Profound | Wood | existing (`design/techniques/catalogue-wood.json`) |
| True disciples, elders | Emerald Haze True Canon (Thúy Vi Chân Kinh) | main, Earth | Wood + Earth | proposal, the founder's |
| Inner gate secret | Haze Walk (Vụ Bộ) | secret, Profound | Wood | proposal (the art of V015) |
| Inner gate secret, Cliff Hall only | Rock-Splitting Root (Liệt Thạch Căn Quyết) | secret, Profound | Wood | proposal, Cù Thúy Bách's |
| Elders' secret | Green Furnace Canon (Thanh Lô Kinh) | secret, Earth | Wood + Earth | proposal, the sect's alchemy |
| Head | Empty Mountain Sutra (Không Sơn Kinh) | secret, Heaven | Earth + Wood | proposal, Không Sơn's gift (C100) |
| Body (Field Hall) | Mountain Bone Body Art (Sơn Cốt Thể Thuật) | body, Yellow | none | existing |
| Forbidden | Rotting Canopy Canon (Hủ Quan Điển) | secret, Earth | Wood | existing; studied in secret by Tề Tử Tô |

**Why it fits.** Every method runs on Wood, and the outer gate's primer also takes Earth, because a seed needs soil.
The land gives the sect Wood in plenty and almost no Earth. So the lineage's Earth half lives in the outer gate and the
Field Hall, and the inner gate is Wood. The founder's canon, like every method, cultivates faster on land that matches it, and on the
Metal ridge it was slow. That is the quiet argument for the move. The sect has no Fire.
Its alchemy feeds Wood into a clay furnace until the flame burns green (Wood begets Fire), which makes it depend on Hộ
Lâm Đường's spirit wood. It cannot hold a wild fire: green flame failed at Bách Thảo Viện in 932 (V029). It has no
Metal either, so it hires a jade-cutter to refine for it (Lã Trác Thạch). Those two gaps are its weaknesses.
Members on the lineage: 66 of 70. Four use outside methods with reasons: Quản Ảnh Hồ (Minh Kính Đường's mirror method),
Ngải Thanh Hao (Thanh Nang Đường's healing method), the guest refiner and the Cliff Hall's cook.

## 6. Admission (R2 as the sect applies it)

- **Outer gate:** Wood or Earth at purity 30 or more. Recruiters walk the forest villages at the autumn harvest. The
  Green Door brings in the rest. Coast children enter on their Wood. Earth children come from far away, because the
  ground breeds none.
- **Inner gate and above:** Wood at 45, tested by the First Leaf. When an outer disciple's life tree puts out its first
  spirit leaf and their Wood holds 45, they walk up the slope to the inner gate. Earth-only disciples stay in the outer
  gate and the Field Hall for life. Phạm Thủ Điền tells them so, kindly. A few go to Vân Khởi Quán.
- **Exceptions kept:** the guest refiner (khách khanh, Metal-Earth), the servants of the Cliff Hall (tạp dịch), and two
  holders of outside methods from fallen halls of the sect's own ground (Quản Ảnh Hồ, Ngải Thanh Hao). The Hall of Rules
  renews their exceptions every decade.
- **The Cliff Hall** admits only from the inner gate, by Cù Thúy Bách's leave, and teaches the Rock-Splitting Root only
  on the ridge.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The Haze Hall (the head's court; the walking council) | seat, 1110 | Ngu Lam Sơn |
| The Cliff Hall (the old seat; founder's grave, pine and old life trees) | old seat, 1 | Cù Thúy Bách, grand elder; Bao Nham Tỉnh, steward |
| The Furnace Hall (green fire, pills) | seat | Úy Thanh Diễm |
| The Field Hall (spirit fields, grain) and the outer gate | seat and its fields | Quyền Thanh Lam, first elder; Phạm Thủ Điền, outer gate |
| The Herb Gardens and Bách Thảo Viện's books | seat; terraces at Thương Thúy Lâm (1109) | Khổng Đương Quy |
| The Array Hall (Lotus Throne, Spring Return, Turtle Shell, Furnace of Heaven and Earth) | seat | Tất Hành Vụ |
| The Hall of Rules | seat | Nhạc Chính Hành |
| The Cold Ford Hall (the Tùng Đào border, the fishers) | Hàn Tân Thành (31) | Hướng Dạ Đăng |
| The port house (pill ships, the cape coast) | Yên Ba Thành (30) | Diêm Hải Tảo |
| The Marten Yard (herb-finding martens) | Ngân Điêu Đài (1048) | Lô Dã Hương |
| The Healing House, the Green Door and the pill shop | Lam Yên Thị (45) | Dư Tục Đoạn; shop: Đậu Tam Thất |
| The spirit-wood stores | seat | Phí Tùng Chi |
| The jade mine and refinery (guest) | Bích Ngọc Khoáng (165) | Lã Trác Thạch |
| The spirit cattle | Mục Ca Thành (56) | Uông Mục Địch |
| Envoys (the Pivot, the vassals, the border) | travels | Biện Vãn Tình |

## 8. Relations

- **Thiên Xu Tông (the Pivot):** grateful and wary. Chung Hoài Cực let Tùng Đào's unlicensed conquest of the Cold Ford
  stand in 672 (C136), the Compact's first crack. Đỗ Tinh Hà gave the writ that took it back in 901 (C165). The sect
  trusts the Pivot's present head, Doãn Ngọc Hành, as far as its envoy can see him.
- **Tùng Đào Cung:** the old enemy, grudge −5 (Cold Ford). Wood against Wood: pines against haze. Đàm Tùng Lại held the
  ford for Tùng Đào as its head from 900 and lost it in 905 (C166). The coast says Thôi Khinh Hồng retired in 900 so as
  not to fight the war she could see coming. Hồ Tùng Nguyệt keeps the border talks civil with Biện Vãn Tình, and she
  also pays a spy in the outer gate. At the 1190 talks Hướng Dạ Đăng quoted the Listening Pine Primer's fourth line to
  her across the table, a line he learned on the Hàn Tân quay as a boy; since 905 the Cold Ford Hall has written down
  the pines' songs from the Cold Ford families, and they sit on the open shelves. The head's disciple Đàm Thanh Giang
  meets Hướng Vãn Chu on the river-mouth ice.
- **Phượng Minh Cung:** Fire and Wood. Phượng Minh buys spirit wood and pills and sells nothing the sect needs.
  Courteous.
- **Lạc Hà Tông:** Earth and Wood, a rival in the herb markets of the west. The loose alchemist Lạc Đan Thanh copies
  Thúy Vi's pill seals in Vật Hoa Thị and holds the only map of the Peach Spring.
- **Băng Tâm Các:** distant. Hồng Lô Cốc's best student, Viên Chước, was bought away by Băng Tâm in 1144. Đồng Hồng Lô
  still mentions it.
- **Vassals:** **Hồng Lô Cốc** (Đồng Hồng Lô) brews over volcano fire in a tundra valley on the cape's north coast (place 9): the sect's other furnace, and its
  rival inside the house. It took in the whale hunters of Kình Cốt Đường (V013) and the healers of Thanh Nang Đường
  (V018). **Vân Khởi Quán** (Tống Tọa Vân) is the empty mountain's last student and the sect's elder brother in spirit,
  an abbey of teachers on the Metal heights where the water ends. **Vụ Ẩn Môn** (Bàng Yên Tỏa) lays mist on the
  cape's roads with the Haze Walk, which the elders still argue it stole. **Hộ Lâm Đường** (Lục Thanh Sam) was
  founded by the sect's own forest wardens in 910 (V028) and sends the spirit wood every green fire depends on.

## 9. Inside the sect

- **The Heir's Garden.** Ngu Lam Sơn means to step down. He will not name an heir by fighting or by vote. In 1195 he
  gave three disciples a plot each and will judge the gardens in 1205 (N-thuy_vi-08).
  **Thiệu Thanh Đài**, his own disciple, has planted moss, so that she will lose. **Hoàn Cô Bách**, the Cliff Hall's
  champion, has rooted a cypress in a crack of the ridge, where nothing grows, and it lives. **Hướng Vãn Chu** of the
  Cold Ford is growing spirit rice in the salt marsh. Her father says it is a granary for war, and she says it is
  bread. A fourth plot nobody gave exists: the Earth-rooted outer disciple **Mễ Điền Nhi** has dug it and sown nothing,
  and three spirit grasses have come up in it on their own.
- **One secret, kept twice.** Ngu read the founder's pulse in her last year. Cù nursed her last century and watched her
  stiffen like bark. Each believes the ridge's Metal wore Phùng's life down, and each believes the other does not know. Ngu moved the
  sect for it and has let Cù think he moved it for the vein. Cù will not say it, because it would mean the move was
  right. Quyền Thanh Lam buried three baskets of the ridge's soil under the new hall at Cù's request, and Ngu does not
  know that either.
- **The hawk and the head.** Hướng Dạ Đăng wants the border pushed to Lô Khẩu marsh. Ngu will not give him a war, and
  Biện Vãn Tình undoes his winters. Nhạc Chính Hành suspects the six patrolmen under the ice (1172), and he will judge
  them if he finds proof.
- **The heretic in the Furnace Hall.** Tề Tử Tô, the Furnace Hall's best brewer of wound pills, reads the forbidden
  Rotting Canopy Canon at night. She is also the foundling Kiển Viễn Chí's mother, and he has found the sewing ledger.
- **The Tùng Đào man.** Phù Liên Kiều came to the outer gate in 1194 on Hồ Tùng Nguyệt's money to learn the Haze Walk,
  she says; her letters ask for a list of what the open shelves hold of the pines' canon. The sect locks nothing, and
  that is making him harder to keep honest with himself.
- **The founder's last blood.** Âu Dương Tân Di is kept on the ridge as a relic and wants to go down. If she does, the
  Cliff Hall loses its strongest claim.

## 10. Treasures and sets

- **Emerald Haze Regalia (Thúy Vi Tam Bảo)**, a set of three: the Seal of the Emerald Haze and the Robe of the Empty
  Green, both held by the head, and the Founder's Seed Gourd, held by the grand elder on the ridge. The Regalia has not
  been whole since 1006. Cù will give up the gourd only if the sect comes back up the mountain, or to the heir she
  chooses.
- **Field and Garden (Điền Viên Tam Kiện)**, now three: Quyền Thanh Lam's Well-Field Seal and Lime-Kiln Jacket and
  Khổng Đương Quy's Gourd of a Hundred Herbs. Each spring at the planting, whoever finished sowing first is handed the
  other's piece. Full set: heals over time grant Earth guard, and at 5 guard stacks health regeneration doubles.
- **Personal sets** (one line each; full set in brackets):
  - **Evening Ferry (Vãn Độ)**, Hướng Vãn Chu: Evening Punt-Pole, Salt-Marsh Rain Cape [roots last longer per 3 Wood stacks].
  - **Far Ambition (Viễn Chí)**, Kiển Viễn Chí: Foundling's Cloth, Polygala Needle [a pill fires the next needle at once, double stacks, stronger heals].
  - **Pine on the Cliff (Nhai Tùng)**, Cù Thúy Bách (worn beside the Seed Gourd): Cliff Pine Bark, Rock-Splitting Root Axe [blocks lay Wood stacks that feed the root split].
  - **Green Fire (Thanh Hỏa Tam Kiện)**, Úy Thanh Diễm: the Green Furnace, Pulse-Reading Needle, Charcoal-Clamp Robe [spent Wood stacks rekindle once as Burn].
  - **Cold Ford Watch (Hàn Tân Canh)**, Hướng Dạ Đăng: Lamp of the Cold Ford Quay, Spear of the Quay, Winter Quay Coat [rooted foes lose concealment and take growing Wood damage].
  - **The Salt Chest (Diêm Rương Tam Kiện)**, Diêm Hải Tảo: Brass Lock of the Salt Chest, Cove Wind Fan, Salt-Crusted Deck Robe [once a fight, low linh lực refills by half with a haze ward].
  - **Poria Under Pine (Tùng Hạ Phục Linh)**, Thiệu Thanh Đài: Green Moss Mirror, Poria Gourd, Weeping Willow Robe [once a fight, a heal below a quarter of her health adds a Wood ward].
  - **Cliff Hall Champion (Nhai Đường Tam Kiện)**, Hoàn Cô Bách: Lone Cypress Banner, Ridge Jade Buckler, Metal-Wind Coat [hits on a cracked guard stack pierce until the block breaks].
- **The White Cloud Whisk (Bạch Vân Phất Trần)**, Không Sơn's Wind treasure (legendary `bach_van_phat_tran`), held by
  the head. No head has held Wind to wake it fully.
- **The Green Furnace**, fired in 540 and never cold since 932. **The Lamp of the Cold Ford Quay**, found unbroken in
  905. **The Brass Lock of the Salt Chest**, which has no keyhole.
- **Sought:** Cao Đan Hà's Purple Smoke Furnace (`tu_yen_lo`, abode A-2), which Úy wants. Ô Kình Hải's sabre Kình Nha
  (`kinh_nha`, place 217), which Diêm wants. The Peach Spring Painting (`dao_nguyen_do`, held by Lạc Đan Thanh), which
  the port house wants.
- Personal items in `thuy_vi.items.json`.

## 11. Roster (70 living, 6 dead: tier A 11, B 22, C 43)

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| ngu_lam_son | Ngu Lam Sơn | tông chủ | Nguyên Anh | A | Wood 82, Earth 68 | Head; brought the sect down off the ridge |
| cu_thuy_bach | Cù Thúy Bách | thái thượng | Nguyên Anh | A | Wood 74, Earth 50, Metal 40 | Grand elder; keeper of the Cliff Hall |
| uy_thanh_diem | Úy Thanh Diễm | trưởng lão | Nguyên Anh | A | Wood 78, Fire 52 | Furnace Master |
| quyen_thanh_lam | Quyền Thanh Lam | trưởng lão | Kết Đan | A | Earth 70, Wood 62 | First elder; the Field Hall |
| huong_da_dang | Hướng Dạ Đăng | trưởng lão | Kết Đan | A | Water 64, Wood 56 | Warden of the Cold Ford Hall |
| diem_hai_tao | Diêm Hải Tảo | trưởng lão | Kết Đan | A | Water 66, Wood 48 | Keeper of the port house; the pirates' child |
| thieu_thanh_dai | Thiệu Thanh Đài | chân truyền | Kết Đan | A | Wood 80, Earth 42 | The head's disciple; first plot (moss) |
| hoan_co_bach | Hoàn Cô Bách | chân truyền | Kết Đan | A | Wood 66, Metal 42, Earth 34 | Cliff Hall champion; second plot (cypress) |
| tat_hanh_vu | Tất Hành Vụ | trưởng lão | Kết Đan | B | Wood 62, Water 44 | Array Hall; taught the Haze Walk away |
| khong_duong_quy | Khổng Đương Quy | trưởng lão | Kết Đan | B | Wood 72, Water 34 | Herb Gardens and the Bách Thảo books |
| nhac_chinh_hanh | Nhạc Chính Hành | trưởng lão | Kết Đan | B | Wood 54, Earth 46, Metal 30 | Hall of Rules, "the Avalanche" |
| lo_da_huong | Lô Dã Hương | trưởng lão | Kết Đan | B | Wood 76, Water 28 | Marten Yard |
| bien_van_tinh | Biện Vãn Tình | trưởng lão | Kết Đan | B | Wood 64, Water 40 | Envoy |
| la_trac_thach | Lã Trác Thạch | khách khanh | Kết Đan | B | Metal 72, Earth 44 | Guest refiner and jade-cutter (R2 exception) |
| du_tuc_doan | Dư Tục Đoạn | trưởng lão | Kết Đan | B | Wood 58, Water 42 | Healing House; the Green Door |
| huong_van_chu | Hướng Vãn Chu | chân truyền | Trúc Cơ | A | Water 58, Wood 54 | Cold Ford true disciple; third plot (salt rice) |
| kien_vien_chi | Kiển Viễn Chí | nội môn | Trúc Cơ | A | Wood 78, Earth 50 | Foundling prodigy |
| pham_thu_dien | Phạm Thủ Điền | chấp sự | Trúc Cơ | B | Earth 56, Wood 46 | Master of the outer gate |
| quyen_tieu_mach | Quyền Tiểu Mạch | nội môn | Trúc Cơ | B | Wood 60, Earth 48 | Seed vault; the first elder's daughter |
| bao_nham_tinh | Bao Nham Tỉnh | chấp sự | Trúc Cơ | B | Wood 50, Metal 38, Earth 30 | Steward of the Cliff Hall |
| quan_anh_ho | Quản Ảnh Hồ | nội môn | Trúc Cơ | B | Water 60, Wood 46 | Last of Minh Kính Đường (outside method) |
| uong_muc_dich | Uông Mục Địch | nội môn | Trúc Cơ | B | Water 56, Wood 48 | Spirit cattle; 198, his last spring |
| tham_tinh_sa | Thẩm Tịnh Sa | chấp sự | Trúc Cơ | B | Water 62, Wood 45 | Port house books; the Thẩm of Bạch Sa |
| te_tu_to | Tề Tử Tô | chân truyền | Trúc Cơ | B | Wood 66, Fire 34 | Senior alchemist; the heretic |
| au_duong_tan_di | Âu Dương Tân Di | nội môn | Trúc Cơ | B | Wood 72, Earth 40 | The founder's last blood |
| thang_ha_kho | Thang Hạ Khô | nội môn | Trúc Cơ | C | Wood 52, Metal 36 | Cliff Hall fighter |
| tien_ban_ha | Tiền Bán Hạ | nội môn | Trúc Cơ | C | Wood 58, Earth 30 | Keeper of the Green Door list |
| han_moc_te | Hàn Mộc Tê | nội môn | Trúc Cơ | C | Wood 64, Earth 32 | Osmanthus terraces; copyist |
| canh_bo_anh | Cảnh Bồ Anh | nội môn | Trúc Cơ | C | Wood 52, Earth 38 | Field Hall |
| vo_han_lo | Võ Hàn Lô | nội môn | Trúc Cơ | C | Wood 50, Water 40 | Cold Ford fighter on ice |
| nham_lieu_ngan | Nhâm Liễu Ngạn | nội môn | Trúc Cơ | C | Water 54, Wood 46 | Ferry disciple; carries letters |
| bach_hop_hoan | Bạch Hợp Hoan | nội môn | Trúc Cơ | C | Wood 62, Water 26 | Marten Yard |
| phi_tung_chi | Phí Tùng Chi | chấp sự | Trúc Cơ | C | Wood 56, Fire 30 | Spirit-wood stores |
| duong_tich_chieu | Đường Tịch Chiếu | nội môn | Trúc Cơ | C | Wood 48, Water 44 | The envoy's letter-writer |
| khang_thach_tuyen | Khang Thạch Tuyền | nội môn | Trúc Cơ | C | Wood 54, Water 38 | Array runner |
| tuan_van_mau | Tuân Vân Mẫu | nội môn | Trúc Cơ | C | Wood 46, Metal 40 | Mica-grinder |
| ngai_thanh_hao | Ngải Thanh Hao | nội môn | Trúc Cơ | C | Wood 54, Water 36 | Healing House (Thanh Nang method) |
| thi_tra_yen | Thi Trà Yên | nội môn | Trúc Cơ | C | Wood 58, Water 30 | Spirit tea |
| banh_lap_mai | Bành Lạp Mai | nội môn | Trúc Cơ | C | Wood 60, Earth 30 | Cliff Hall |
| dong_ho_dao | Đổng Hồ Đào | nội môn | Trúc Cơ | C | Wood 56, Earth 36 | Field Hall |
| liem_truc_anh | Liêm Trúc Ảnh | nội môn | Trúc Cơ | C | Wood 50, Earth 40 | Clerk of the Hall of Rules |
| ke_lang_hoa | Kê Lăng Hoa | nội môn | Trúc Cơ | C | Water 50, Wood 48 | Followed the peach petals |
| tat_que_lac | Tất Quế Lạc | nội môn | Trúc Cơ | C | Wood 56, Water 34 | Array Hall; Tất's granddaughter |
| dau_tam_that | Đậu Tam Thất | chấp sự | Trúc Cơ | C | Wood 46, Metal 30 | Pill shop |
| thuong_doc_hoat | Thường Độc Hoạt | nội môn | Trúc Cơ | C | Wood 60, Earth 44 | Hermit on Thủy Cùng Phong |
| me_dien_nhi | Mễ Điền Nhi | ngoại môn | Luyện Khí | B | Earth 58, Wood 34 | The fourth plot |
| phu_lien_kieu | Phù Liên Kiều | ngoại môn | Luyện Khí | B | Wood 52, Water 34 | Tùng Đào's man |
| huong_tieu_lam | Hướng Tiểu Lâm | ngoại môn | Luyện Khí | C | Water 56, Wood 38 | The warden's son |
| cam_le_chau | Cam Lệ Châu | ngoại môn | Luyện Khí | C | Water 60, Wood 36 | Wants to kill sea eagles |
| dinh_lao_hoe | Đinh Lão Hòe | tạp dịch | Luyện Khí | C | Metal 34, Wood 22 | Cliff Hall cook (R2 exception) |
| uong_tieu_nguu | Uông Tiểu Ngưu | ngoại môn | Luyện Khí | C | Water 52, Wood 32 | Herder boy |
| trinh_ma_thang | Trịnh Ma Thằng | ngoại môn | Luyện Khí | C | Wood 50, Earth 30 | Rope-maker |
| le_dan_tat | Lê Đan Tất | ngoại môn | Luyện Khí | C | Wood 48, Earth 32 | Lacquers the pill boxes |
| truong_mac_than | Trương Mặc Thán | nội môn | Luyện Khí | C | Wood 58, Fire 30 | Furnace fire-tender |
| vuong_phuc_linh | Vương Phục Linh | nội môn | Luyện Khí | C | Wood 56, Earth 40 | Thiệu's second disciple |
| khau_hai_doi | Khâu Hải Đới | ngoại môn | Luyện Khí | C | Water 54, Wood 36 | Port house runner |
| nguyen_man_diep | Nguyễn Mãn Diệp | ngoại môn | Luyện Khí | C | Wood 46, Water 30 | Brought a jar of resin |
| lo_kien | Lỗ Kiên | ngoại môn | Luyện Khí | C | Earth 44, Wood 38 | Terrace walls |
| sam_nguu_tat | Sầm Ngưu Tất | ngoại môn | Luyện Khí | C | Wood 44, Water 34 | Spirit-wood raftsman |
| lieu_tieu_do | Liêu Tiểu Độ | ngoại môn | Luyện Khí | C | Wood 48, Water 30 | Newest outer disciple |
| doi_hoa_mach | Đới Hoa Mạch | ngoại môn | Luyện Khí | C | Wood 42, Earth 34 | Field worker |
| trac_bach_truat | Trác Bạch Truật | nội môn | Luyện Khí | C | Wood 60, Earth 36 | Copyist; finds the missing recipes |
| chuong_da_mat | Chương Dã Mật | ngoại môn | Luyện Khí | C | Wood 50, Water 30 | Spirit bees |
| phong_han_nha | Phong Hàn Nha | ngoại môn | Luyện Khí | C | Wood 52, Water 28 | Keeps crows |
| tich_thu_diep | Tịch Thu Diệp | ngoại môn | Luyện Khí | C | Water 44, Earth 36 | Reads to the field workers |
| van_tieu_ca | Vạn Tiều Ca | ngoại môn | Luyện Khí | C | Water 48, Wood 34 | Sings quietly |
| ung_lam_tuyen | Ứng Lâm Tuyền | ngoại môn | Luyện Khí | C | Water 50, Wood 38 | Carries the spring water |
| thoi_hai_thuy | Thời Hải Thúy | nội môn | Luyện Khí | C | Wood 54, Water 46 | Diêm's youngest disciple |
| khuat_phong_pham | Khuất Phong Phàm | ngoại môn | Luyện Khí | C | Water 54, Wood 32 | Reads the weather |
| co_dong_du | Cổ Đồng Du | ngoại môn | Luyện Khí | C | Wood 50, Earth 30 | Oils the halls |
| phung_yen_ha | Phùng Yên Hà | founder (dead) | Nguyên Anh | A | | Founder; lies under her pine on the ridge |
| au_duong_thanh_lo | Âu Dương Thanh Lô | trưởng lão (dead) | Kết Đan | B | | First Furnace Master; died 932 |
| huong_dong_lam | Hướng Đông Lâm | trưởng lão (dead) | Kết Đan | B | | First Warden of the Cold Ford; died 672 |
| tan_han_chu | Tân Hàn Chu | trưởng lão (dead) | Kết Đan | B | | Led the boats; went through the ice 904 |
| gian_chieu_thanh | Giản Chiếu Thanh | trưởng lão (dead) | Kết Đan | B | | Head of Minh Kính Đường; died 1066 |
| man_trieu_am | Mẫn Triều Âm | trưởng lão (dead) | Kết Đan | B | | Keeper of Lam Triều Các; died 744 |

## 12. Story hooks

1. **The Heir's Garden (1205).** Four plots: moss, a cypress in the rock, salt-marsh rice, and soil nobody sowed.
   The player can tend, sabotage or carry word for any of them, and Ngu judges in 1205. (Thiệu Thanh Đài, Hoàn Cô Bách,
   Hướng Vãn Chu, Mễ Điền Nhi, Kiển Viễn Chí; places 1110, 1, Lô Khẩu Trấn 355.)
2. **One secret, kept twice.** Whoever learns that both Ngu and Cù know why the founder died early can heal the Ridge
   or break it. The soil under the new hall is the proof that Cù never wanted the sect cut off from the ridge. (Ngu Lam
   Sơn, Cù Thúy Bách, Quyền Thanh Lam; places 1, 1110.)
3. **What the thaw brings up.** A warm spring could bring the six Tùng Đào patrolmen up out of the river-mouth ice. Đàm
   Thanh Giang, who has brewed the Coiled Root Hall's winter wound pills one grade weak since 1190 so that no patrol can
   hold the river-mouth ice for a night, is asking where they went; Nhạc Chính Hành wants proof, and Hướng Vãn Chu has
   to choose between her father and her lover. (Hướng Dạ Đăng, Võ Hàn Lô, Nhạc Chính Hành, Hướng Vãn Chu, Đàm Thanh
   Giang; place 31.)
4. **The silk ledger.** Kiển Viễn Chí learns his mother is Tề Tử Tô. Then he learns what she reads at night. Trương
   Mặc Thán has seen the book. Exposing her ends her, and keeping quiet makes him her accomplice. (Kiển, Tề, Trương,
   Úy Thanh Diễm; places 1110, 45.)
5. **The pirate's daughter sails.** Diêm Hải Tảo has about eighty years and a pirate's chart. She wants the sabre
   Kình Nha from the ruin of Thôn Hải Môn and a crew she can trust. (Diêm Hải Tảo, Thời Hải Thúy, Khuất Phong Phàm, Kim
   Vạn Lý; places 30, 217.)
6. **The Peach Spring opens.** Đào Nguyên Cảnh lies in Thúy Vi's land on the cape and opens on its twenty-year cycle,
   and 1200 is an opening year (A030, N-thuy_vi-09). The only map is Lạc Đan Thanh's, and the one disciple who found the
   way in cannot remember it. (Kê Lăng Hoa, Diêm Hải Tảo, Úy Thanh Diễm, Lạc Đan Thanh; places 57, 1073, the Peach
   Spring's cave by a forest stream.)
7. **Cao Đan Hà's last pill.** Úy Thanh Diễm wants the Purple Smoke Furnace from her abode (slot A-2) to brew the pill
   that killed her correctly: a pill to carry a Nguyên Anh through the Hóa Thần tribulation. He has not decided whom it
   is for. (Úy, Ngu Lam Sơn, Cù Thúy Bách; abode A-2.)
8. **The man in the outer gate.** Phù Liên Kiều has the warden's son's friendship and the envoy's trust. Hồ Tùng
   Nguyệt wants the shelf list by winter. (Phù Liên Kiều, Hướng Tiểu Lâm, Biện Vãn Tình, Hồ Tùng Nguyệt; places 1110,
   31.)
9. **Gift or theft.** The elders move to demand a tithe from Vụ Ẩn Môn for the Haze Walk. Tất Hành Vụ would rather die
   than see his sworn brother's school pay for his gift. Nhạc Chính Hành has kept the tithe off the table since 1190,
   because Vụ Ẩn's head sells him a page each new moon on what passes under the mist, and this time he must vote. (Tất
   Hành Vụ, Tất Quế Lạc, Bàng Yên Tỏa, Nhạc Chính Hành; places 1110, 1063.)
10. **The herder's last spring.** Uông Mục Địch, 198, tries for Kết Đan on the cape with the spirit herd listening.
    The last time a flute played to spirit cattle at a breakthrough, they trampled Địch Thanh Viện (V014). (Uông Mục
    Địch, Uông Tiểu Ngưu, Tất Hành Vụ; places 56, 391.)
11. **The reader in the empty academy.** Someone has been reading the Empty Mountain Sutra aloud in Không Sơn Viện
    (A048), behind the gate the sect sealed in 830 (A043). Thường Độc Hoạt and the abbot Tống Tọa Vân know who it is
    and will not say. (Thường Độc Hoạt, Tống Tọa Vân, Ngu Lam Sơn; places 213, 1492.)
12. **Soil without seed.** Mễ Điền Nhi's plot grows spirit grass from soil alone, which points to an Earth way the
    lineage ignores. If her root changes, the outer gate's oldest rule changes with it. (Mễ Điền Nhi, Phạm Thủ Điền,
    Quyền Thanh Lam; place 1110.)
