# Hồng Lô Cốc (紅爐谷), the Valley of the Red Furnace

> **Status**: World-depth pass, 2026-11-25 (minor sect writer, Thúy Vi's vassals). Proposal: nothing here is in game
> data. Rules: `../rules-proposals.md` R1-R8. People: `hong_lo.cast.json`; công pháp: `hong_lo.techniques.json`;
> items: `hong_lo.items.json`. Lord's page: `thuy_vi.md`.

## 1. At a glance

| | |
|---|---|
| Kind | Minor sect, vassal of Thúy Vi Tông (loyalty 65), righteous (chính), founded 650 |
| Leans | Fire, Wood → **Fire, Water** (R4 re-lean: the valley holds Fire 47 %, Water 30 %, Wood 5 %) |
| Lineage elements | Fire first, then Water |
| Seat | **stays** at Hồng Lô Cốc (place 9), a tundra valley on the cape's north coast, on a volcano's flank |
| Head | Đồng Hồng Lô, Kết Đan, head since 930 |
| Size | about 60 people: alchemists, furnace-men, cooks, boat crews and the Satchel Hall's healers; 11 living named here |
| Way of life | alchemy over volcanic fire, cooled with snow; boats to the isles for ash and fire jade |

The valley smells of sulphur and whale broth. Snow lies on its rim all year, and the floor is warm enough to walk
barefoot. In the middle stands the Red Furnace, a clay-and-copper kiln as tall as three men, and copper sleeves of
snow-melt are wrapped round it. It has not cooled since 930. Thúy Vi brews slowly over green wood. Hồng Lô brews fast
over volcano fire and keeps it honest with snow, two batches in a season where the lord brews one. Its pills are red,
strong and a little harsh. Fighters buy them, healers do not, and the two furnaces have argued about it for 550 years.

## 2. Land and seat

**Decision (R4): stay, and re-lean Fire/Wood → Fire/Water.** The seat's Fire passes easily (47 %, first lean). Wood
fails at 5 %, and no place on the sect's ground holds both. The volcanic places (Kê Quan Khoáng 264, Hắc Diệu Khoáng
1077, Lưu Hỏa Khẩu 1080, Hỏa Ngọc Mạch 210) run 45-48 % Fire with 4-7 % Wood. The forests of the cape run 40-56 % Wood
with 9-11 % Fire. A move to the forest would trade away the fire, and the fire is the reason the sect exists. The
valley's second element is the snow: Water at 30 %, and up to 49 % at the island hot spring of Hồ Tâm Thang (247)
to the south. The Wood lean was the founders' inheritance. They were Thúy Vi alchemists who brought Fire-Wood roots with
them. The valley has bred Fire-Water children for five centuries, and the furnace has run on snow since 930. The record
now says so.

**What the re-lean costs (to do when approved).**
- **Data.** `leans` in `world_continent.json` (minor_sects) and the sect's start state become `["Fire", "Water"]`; the
  lineage (`hong_lo.techniques.json`) lists Fire, then Water. No art, route, province or density changes: nothing moves.
- **People.** Wood-rooted members fall outside the lineage. The Satchel Hall's healers (Giải Bách Bộ, Cúc Xa Tiền)
  keep their place as a hired craft under an R2 exception. The head keeps his Wood, which is his parents' Thúy Vi
  blood, and his Fire passes the core rule. Viên Chước and Dương Lô (Băng Tâm's people now) already have exceptions there.
- **Chronicle.** A024 and A028 stay true. Add N-hong_lo-01 to -06 (below). The 1151 opening of the gate (N-hong_lo-04)
  is the in-world date of the re-lean.

**The ground.** The seat sits at 0.3 km on the north coast of Tuyết Hỏa Giác, between the snowfields and the sea. It is
off the roads, so everything comes and goes by boat or by the mist roads south. The valley lies on the northern skirts of a volcano
whose summit is the Cockscomb Mine (Kê Quan Khoáng, 264, danger 4), and the valley's vent is one of its roots. South of
the mine is the island spring of Hồ Tâm Thang (247), where the elders go to soak out a bad brew. Kình Cốt Đường's ruin
(1092), the whale hunters' old hall, stands far up the coast to the north-west. Hàn Tân Thành (31) and the Cold Ford
lie east along the coast. The obsidian of Hắc Diệu Khoáng (1077)
and the lava vent of Lưu Hỏa Khẩu (1080) lie far down the cape, and the ash boats sail there in a smoking year. The
volcanic isles are out at sea, and the fire-jade island of Hỏa Ngọc Mạch (210) is the farthest of them.

**How the land shapes its people (R1).** The valley is the only place on the cape that breeds Fire. Children born in
it, to furnace-men and cooks, carry Fire with Water beside it (Tần Tuyết Thán, Ôn Noãn Tuyết, Ngụy Đan Chu), and they
fill the furnace hall. That makes the furnace hall something like a family. The coast villages of the cape's north
shore (Bồ Diệp 1030, Hải Đới 1042, Man Ngư 1054: Water 36-40 %, Wood 30-32 %, Fire 8-10 %) breed
Water-Wood roots. Their children come in through the kitchens on their Water and go to the snow jackets or the boats.
The crews' families have lived at Bồ Diệp Thôn since 885. Wood roots come only from the forest, which is why the
Satchel Hall's healers are the only green in the valley.

## 3. History

| Year | Event | Ids |
|---|---|---|
| 565 | Thúy Vi charts the fire-jade island far out at sea and seals the chart | A022 |
| 640 | The fire cultivator Cung Hỏa Vân vanishes among the cape's volcanic vents | C013 |
| 650 | Tiết Thừa Hỏa brings a coal from the isles in a jade box and founds Hồng Lô Cốc on the valley's vent | A024 |
| 672-905 | The Cold Ford in Tùng Đào's hands east along the coast: the valley is a frontier furnace for 233 years | C136, C166 |
| 884-885 | Kình Cốt Đường's head goes after a spirit whale and is lost; the crews bring their boats to the valley | V013, **N-hong_lo-01** |
| 902 | The furnace brews the Cold Ford War's wound pills for no fee | **N-hong_lo-02** |
| 929 | The island coal dies in a blizzard; the founder goes down into the vent and does not come up | **N-hong_lo-03** |
| 930-939 | Đồng Hồng Lô becomes master and keeps the furnace lit nine years on snow-cooled vent fire | A028 |
| 1101 | Thanh Nang Đường's last head dies in seclusion; Giải Bách Bộ brings the healers to the valley | V018 |
| 1150 | Viên Chước goes to Băng Tâm | **N-hong_lo-05** |
| 1151 | The gate opens to Water roots; Tần Tuyết Thán writes the Snow Hearth Primer | **N-hong_lo-04** |
| 1185 | The isles smoke for a month; the boats go out for the ash before the rain | A031 |
| 1188 | Viên Chước comes back to buy ash and buys the cook's son out of the kitchens | **N-hong_lo-06** |

**New chronicle proposals:**
- **N-hong_lo-01** (885, `settlement`): "Kình Cốt Đường's whale crews bring their boats into Hồng Lô's cove and settle
  their families at Bồ Diệp Thôn."
- **N-hong_lo-02** (902, `tale`): "Hồng Lô Cốc's furnace brews the wound pills for Thúy Vi's march on the Cold Ford, and
  its master takes no fee."
- **N-hong_lo-03** (929, `death`): "When the island coal dies in a blizzard, Tiết Thừa Hỏa goes down into the vent below
  the Cockscomb Mine to bring up fire, and does not come up."
- **N-hong_lo-04** (1151, `custom`): "Đồng Hồng Lô opens Hồng Lô's gate to Water roots, and the first elder writes the
  Snow Hearth Primer for them in one winter."
- **N-hong_lo-05** (1150, `tale`): "Băng Tâm Các buys away Hồng Lô's best student, Viên Chước, to brew outside its
  Array." (The public version. The truth is in section 9.)
- **N-hong_lo-06** (1188, `tale`): "Viên Chước comes back to Hồng Lô to buy ash, and buys the head cook's son out of
  the kitchens."

## 4. Doctrine and customs

- **Fire is quick; water keeps it honest.** The sect's teaching is the hexagram Ký Tế (既濟), water above fire, the
  pot finished. Volcano fire is strong enough to brew anything and strong enough to ruin it. Snow-melt in the jackets
  holds the flame at the edge, and the whole craft is in knowing where the edge is. Thúy Vi teaches that a person is
  grown. Hồng Lô says a person is cooked, and the timing is everything.
- **The kitchen is the first furnace.** Every disciple, a head's son or a fisher's boy, starts in the kitchens, banking
  coals and skimming broth, and learns heat before letters. The head cook outranks an outer disciple at his own fire.
  That is how Viên Chước, Ngụy Đan Chu and Dương Lô all began.
- **The furnace eats, so we eat.** The valley eats whale, seal and char from the boats, and keeps a pot of broth on the
  furnace mouth day and night. Thúy Vi's rule that nothing killed is cooked inside the haze is a standing joke here.
- **Snow in the morning, fire at night.** Every disciple rolls in the snow pits at dawn and soaks in the vent-warmed
  pools at the valley's foot at dusk. Coming to council warm in winter is fined, because it means you stayed in bed.
- **Speak before you quench.** Water is never poured on a living fire without a word to it first. A furnace-man who
  forgets loses a month's pay. The founder's last words, shouted down the vent, are said to have been an apology.
- **Dress:** red-brown felt and seal-skin boots, forearms bare in the hall, burn scars worn openly. The boat crews wear
  oiled seal-skin. The Satchel Hall wears green satchels across the chest, the only green in the valley.
- **The dead:** the furnace hall gives its dead to the vent on the first night of snow. The crews give theirs to the
  sea off Kình Cốt Đường's point. The valley has no graves, and the two halls have never agreed which way is better.
- **Taboos:** letting the furnace cool; selling a one-season pill as a two-season one; carrying dead wood into the
  Satchel Hall; dice. The last was banned in 1150, and the head has never said why.
- **Outsiders:** welcome if they bring something to burn. A guest without a gift of fuel sleeps in the snow house.
- **How others see them:** hot, loud and quick, with pills that work fast and taste of smoke. Thúy Vi calls them harsh.
  The valley calls Thúy Vi's pills bread.

## 5. Lineage (công pháp)

| Rank | Method | Kind | Element | Source |
|---|---|---|---|---|
| Outer gate | Snow Hearth Primer (Tuyết Táo Quyết) | main, Yellow | Fire or Water | proposal (Tần Tuyết Thán, 1151) |
| Inner gate and above | Red Sun Scripture (Xích Nhật Kinh) | main, Profound | Fire | existing (`design/techniques/catalogue-fire.json`) |
| Boat crews (outer, by leave) | Whale Road Harpoon (Kình Lộ Tiêu Pháp) | secret, Profound | Water | proposal (Kình Cốt Đường's art, V013) |
| Elders | Water Over Fire Canon (Ký Tế Lô Kinh) | secret, Earth | Fire + Water | proposal, the sect's alchemy |
| Satchel Hall (exception) | Thanh Nang Đường's healing method | outside | Wood | generated stand-in `huyen_moc` |

**Why it fits.** The founder brought only fire, and for 280 years the sect taught the Red Sun Scripture to Fire roots
and nothing else. The valley kept breeding Water beside the Fire, and the coast bred Water alone. The snow jackets made
the water part of the craft in 930, and the Water Over Fire Canon made it a method. The Snow Hearth Primer of 1151 let
the coast in at the outer gate. The inner door is still Fire, because the Red Sun Scripture is still the main method, and
the crews notice. The sect has no Wood method. Its herbs come from the Satchel Hall and Thúy Vi's spirit wood, and its
weakness is the same as its lord's in reverse: it holds a wild fire easily, and it cannot grow the herbs it brews.
Members on the lineage: 9 of 11. Two keep the Satchel method under exception (Giải Bách Bộ, Cúc Xa Tiền).

## 6. Admission (R2 as the sect applies it)

- **Outer gate:** Fire or Water at 30, tested by the Winter Coal: a child is given one coal at the first snow and must
  keep it alive in a snowbank until the thaw by breath alone. Most recruits come in through the kitchens. The crews' children come from Bồ Diệp Thôn every spring.
- **Inner gate and above:** Fire at 45. A Fire root who has kept the Winter Coal and holds 45 walks through the furnace
  hall's door. A Water root stays in the outer gate for life, at the jackets or in the boats. Nghiêu Vọng Kình has been
  an outer disciple for a hundred years.
- **Exceptions kept:** the Satchel Hall (a hired craft of healers, Wood roots, since 1101) and the kitchen servants
  (tạp dịch). The head renews the Satchel Hall's place every spring, and says each time that he always will.

## 7. Ranks and halls

| Hall | Place | Head |
|---|---|---|
| The Red Furnace and the furnace hall | seat, 9 | Đồng Hồng Lô |
| The snow jackets, the books and the ash ledger | seat | Tần Tuyết Thán, first elder |
| The vent and the night watch | seat, the vent under 264 | Phòng Tẫn Thủ, steward |
| The kitchens | seat | Dương Bát Oản, head cook |
| The boats (ash, fire jade, whale) | the valley's cove; families at Bồ Diệp Thôn (1030) | Nghiêu Vọng Kình |
| The Satchel Hall (healers and herbs) | seat | Giải Bách Bộ, steward under exception |
| The hot pools; the elders' retreat | seat; Hồ Tâm Thang (247) | the outer gate, by turns |

## 8. Relations

- **Thúy Vi Tông (lord, loyalty 65):** the other furnace, and a rival inside the house. Red fire against green.
  Úy Thanh Diễm and Đồng Hồng Lô trade volcano ash for spirit wood and argue about fire every season. Neither has ever
  eaten the other's pills. Đồng overpays Lô Dã Hương for her marten pups, because the Satchel Hall cannot find herbs
  without them and because she is the one Thúy Vi elder who has never called his pills harsh. The healers' quarrel of 1101 is
  still alive: Dư Tục Đoạn went to Thúy Vi, Giải Bách Bộ came here, and they meet once a year at the Green Door. The
  sect wants one thing from its lord that it has never been given back: the fire-jade chart sealed in 565 (A022), which
  the founder was lent once.
- **Băng Tâm Các:** Viên Chước, Hồng Lô's best student, brews for Băng Tâm at Hàn Giao Chử, and the cook's son Dương Lô
  tends his furnace. In public Đồng calls it theft by Sở Ngọc Hồ. Băng Tâm buys red pills through Viên and pays well.
- **Tùng Đào Cung:** for 233 years the Cold Ford was Tùng Đào's, east along the coast (C136-C166). The valley brewed the
  wound pills that took it back in 902 (N-hong_lo-02). Tùng Đào's patrol boats still come too close to the cove.
- **Hộ Lâm Đường:** the Satchel Hall burns spirit wood, and that wood reaches the valley only through Úy's surplus,
  because Lục Thanh Sam will sell to no one but the lord. Hồng Lô has asked him three times.
- **Vụ Ẩn Môn:** the ash carts go south on the mist roads, and Bàng Yên Tỏa's guards are paid in pills.
- **Cung Hỏa Vân (dead, abode A-4):** the founder came to the vents looking for his fire (C013). Her journal is in the
  furnace hall, and nobody since has read its last pages closely.

## 9. Inside the sect

- **Water Over Fire.** Đồng carries the Nine-Year Ember and Tần carries the Snow-Melt Gourd. The valley says the next
  head is whoever wears both, which would make the set whole. Tần is the canon's author and the crews' elder. Ngụy Đan
  Chu is the head's true disciple and the old Red Sun way. Đồng will not name an heir until he has tried for Nguyên Anh,
  and at 440 he has about sixty years left.
- **The ledger.** In 1150 Viên Chước lost the sect's year of ash money at the gaming tables of Hàn Tân Thành. Đồng sold
  his contract to Sở Ngọc Hồ to cover it and called it theft. That week the ash ledger shows a payment from Băng Tâm, and
  Tần keeps the ledger. Dice were banned the same year. That night the ember on the head's belt went out for the first
  time, and the vent warden Phòng Tẫn Thủ relit it before dawn without asking.
- **The inner door.** The gate opened to Water in 1151, but the furnace hall's door did not. The crews want a Water
  root made an inner disciple. Tần wants it too, and she knows it would need a new main method. Ngụy says that would be
  the end of the Red Furnace.
- **The Satchel Hall's place.** Under the re-lean the healers are a hired craft, not members. Giải Bách Bộ has
  about sixty years left and one apprentice. If the head's renewal ever fails, Dư Tục Đoạn
  has a door open for them at Thúy Vi's Healing House.
- **The vow.** Nghiêu Vọng Kình has sworn to find the spirit whale that took his great-grandfather in 884. Spirit
  whales live a long time.

## 10. Treasures and sets

- **Water Over Fire (Thủy Hỏa Ký Tế)**, now three: the Nine-Year Ember (the head's censer, a coal from the Red Furnace
  carried since 930), the Coal-Carrier's Ring (the founder's gift to Đồng, 772) and the Snow-Melt Gourd (Tần's, 1151).
  Split between the head and the first elder, and the valley reads the succession in it. Full set: Burn holds while
  you heal, and each heal turns a Burn stack into steam.
- **Snow Hearth (Tuyết Lô Song Bảo)**, Tần Tuyết Thán (worn beside the Snow-Melt Gourd): the First Snow Jacket, Steam
  Censer. Full set: pills act a second sooner, and steam arts heal her for each Burn stack they spend.
- **The Whale Road Spear**, Kình Cốt Đường's harpoon of spirit-whale rib, the boat captain's since 885.
- **The Red Furnace** itself, uncooled since 930, and the founder's jade box, empty, on its shelf.
- **Sought:** the fire-jade chart (A022, sealed by Thúy Vi); the last pages of the founder's journal; Cao Đan Hà's
  Purple Smoke Furnace (`tu_yen_lo`, abode A-2), which Đồng wants as much as Úy does.
- Details in `hong_lo.items.json`. The head also carries the catalogue's Furnace-Mouth Gourd.

## 11. Roster (11 living, 3 dead: tier A 2, B 4, C 8)

| Key | Name | Rank | Realm | Tier | Root | Role |
|---|---|---|---|---|---|---|
| dong_hong_lo | Đồng Hồng Lô | tông chủ | Kết Đan | A | Fire 84, Wood 58 | Head; the furnace that never cools |
| tan_tuyet_than | Tần Tuyết Thán | trưởng lão | Kết Đan | A | Fire 62, Water 60 | First elder; the snow jackets and the books |
| nguy_dan_chu | Ngụy Đan Chu | chân truyền | Trúc Cơ | B | Fire 72, Water 30 | The head's true disciple; the old Red Sun way |
| giai_bach_bo | Giải Bách Bộ | chấp sự | Trúc Cơ | B | Wood 60, Water 38 | Satchel Hall (R2 exception) |
| nghieu_vong_kinh | Nghiêu Vọng Kình | ngoại môn | Trúc Cơ | B | Water 64, Fire 32 | Captain of the boats |
| phong_tan_thu | Phòng Tẫn Thủ | chấp sự | Trúc Cơ | C | Fire 60, Water 40 | Vent warden; the night watch |
| duong_bat_oan | Dương Bát Oản | tạp dịch | Luyện Khí | C | Fire 38, Water 30 | Head cook; Dương Lô's father (R2 exception) |
| nghieu_lang_hoa | Nghiêu Lãng Hoa | ngoại môn | Luyện Khí | C | Water 56, Fire 30 | Rows the second boat |
| lai_tieu_than | Lại Tiểu Thán | ngoại môn | Luyện Khí | C | Water 50, Fire 22 | Newest outer disciple |
| on_noan_tuyet | Ôn Noãn Tuyết | nội môn | Luyện Khí | C | Fire 56, Water 46 | Tần's disciple; two batches a season |
| cuc_xa_tien | Cúc Xa Tiền | ngoại môn | Luyện Khí | C | Wood 48, Water 30 | Satchel Hall apprentice (R2 exception) |
| tiet_thua_hoa | Tiết Thừa Hỏa | founder (dead) | Kết Đan | B | | Founder; went down into the vent in 929 |
| nghieu_pha_lang | Nghiêu Phá Lãng | last head of Kình Cốt Đường (dead) | Trúc Cơ | C | | Lost on the whale road in 884 |
| thai_bach_thuoc | Thai Bạch Thược | last head of Thanh Nang Đường (dead) | Kết Đan | C | | Died in seclusion in 1101 |

Kept from elsewhere: **Viên Chước** (`vien_chuoc`) and **Dương Lô** (`duong_lo`) are Băng Tâm's people now
(`bang_tam.cast.json`, `bang_tam.2.cast.json`). Both were born in the valley.

## 12. Story hooks

1. **Who wears both.** Đồng tries for Nguyên Anh over the Red Furnace. If he fails, the Nine-Year Ember goes to
   whoever he named, and the valley has not been told who that is. Tần, Ngụy and the crews each ask the player to carry
   word, a pill or a vote. (Đồng Hồng Lô, Tần Tuyết Thán, Ngụy Đan Chu, Nghiêu Vọng Kình; place 9.)
2. **The 1150 ledger.** A page of the ash ledger shows a Băng Tâm payment the week Viên left. Whoever holds it can
   shame the head, buy Tần the succession, or give Viên his name back. Viên would pay for it, and so would Sở Ngọc Hồ.
   (Tần Tuyết Thán, Đồng Hồng Lô, Viên Chước, Sở Ngọc Hồ; places 9, 31, 239.)
3. **The whale road.** A spirit whale is sighted off Kình Cốt Đường's point for the first time since 884. Nghiêu Vọng
   Kình takes both boats out, against the head's order, and needs a harpoon hand. (Nghiêu Vọng Kình, Nghiêu Lãng Hoa;
   places 1092, 1030.)
4. **The sealed chart.** Nghiêu Lãng Hoa wants to sail to the fire-jade island, and Diêm Hải Tảo of Thúy Vi's port house
   wants a crew she can trust. The chart has been sealed since 565, and Thúy Vi has never said why. (Nghiêu Lãng Hoa,
   Diêm Hải Tảo, Đồng Hồng Lô; places 9, 30, 210.)
5. **The founder's journal.** Its last pages, about Cung Hỏa Vân's fire and the vents, point toward a hidden abode on
   the cape. Ngụy Đan Chu wants the old fire for the old way. (Ngụy Đan Chu, Tiết Thừa Hỏa's journal; abode A-4, places
   264, 1080.)
6. **The isles smoke again.** The volcanic isles begin to smoke as they did in 1185 (A031). The ash is worth a year's
   pills, it has to be gathered before the rain, and this time the sea is boiling. (Nghiêu Vọng Kình, Tần Tuyết Thán,
   Lại Tiểu Thán; the isles, place 210.)
7. **The Purple Smoke Furnace.** Đồng and Úy Thanh Diễm both want Cao Đan Hà's furnace from her abode (A-2), each to brew a
   Nascent Soul pill. Úy has his. Đồng has sixty years. (Đồng Hồng Lô, Úy Thanh Diễm; abode A-2.)
8. **The Satchel Hall's door.** A rumour that the re-lean ends the healers' place sends Dư Tục Đoạn to the valley with
   an offer from Thúy Vi's Healing House. Giải Bách Bộ has to choose between the valley that took her in and her method's
   survival. (Giải Bách Bộ, Cúc Xa Tiền, Dư Tục Đoạn; places 9, 45.)
9. **A letter for the cook.** Dương Bát Oản has had one letter from his son in twelve years. He asks a traveller going to
   Hàn Giao Chử to take broth, which will freeze, and a question, which will not. (Dương Bát Oản, Dương Lô, Viên Chước;
   places 9, 239.)
10. **Wood from the north.** A Hộ Lâm warden offers to sell the Satchel Hall spirit wood past the lord, cheaply. The
    healers need it, and Lục Thanh Sam would never allow it. (Giải Bách Bộ, Lại Hoành Chi, Lục Thanh Sam; places 9, 1105.)
