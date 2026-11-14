# The Continent: candidate #11

**Chosen 2026-11-13** by the user from the 12 round-4 candidates (gallery: prototypes/continent-candidates). This is the
fixed world's starting point: it gets finished by hand, and every playthrough uses it (design/research/
fixed-world-decisions.md).

**Status:**
- **Layout:** v3. Sect territories are drawn first, then regions inside them.
- **Approved by the user on 2026-11-14:** the great sects, their names and territories, the region names, and
  the 22 minor sects with their seats.
- **Places, roads and arrays:** 204 places, a proposal, awaiting the user's approval (2026-11-14).
- **Still to do:**
  - town and village names;
  - sacred features, secret spots and history sites.

## Files

| File | What it is |
|---|---|
| `base/` | The continent as generated: seed 11, `tools/design/map/continent_gen.py` at commit 8db1e2b. It holds the index images (Travel & Map rule 1) and `meta.json`, with the legend and the map check. `detail.jpg` is the fine map drawn naturally, and `tiles.png` is the game grid. Hand edits go here from now on. |
| `sects_proposal.json` | Input, edited by hand; approved 2026-11-14 (the `_proposal` file names stay, so the tools' commands keep working). For each great sect: names, tier, element leanings, start tile and map colour. |
| `regions.png` | Region index, 540 × 360: the value is the region id, 0 is sea. |
| `regions.json` | For each region: its sect, size, shape, biome mix, height, climate, coast, rivers, lakes, volcanoes, hot springs, ore and ice tiles, and its neighbours with how natural each shared border is. Also the map check, including each territory's shape. |
| `region_names.json` | Input, edited by hand: each region's Hán-Việt name, Hán tự, meaning and the image behind it. |
| `regions_overview.jpg` | Region borders and numbers over the detail map. |
| `politics_proposal.json`, `politics_proposal.jpg` | Output: each sect's regions, seat tile, share of the land and shape, and the map with territories tinted. |
| `minor_sects_proposal.json` | Input, edited by hand. For each minor sect: names, lord, region, alignment, element leanings, craft, and the land its seat looks for. |
| `places_proposal.json`, `place_names.json` | Input, edited by hand: how many places of each kind, cities per sect, which seats get a market; and the names of the cities, markets and famous sites, by kind and tile. |
| `places.json`, `roads.png`, `places.jpg` | Output of `tools/design/map/places.py`: every place with its tile, region, holder, land, port and river flags and names; the sea lanes; the road index image (1 road, 2 trunk road, 3 sea lane); the map. |
| `minor_sects.json`, `minor_sects.jpg` | Output of `tools/design/map/minor_sects.py`: each minor seat's tile, its land, which wants it met, its distance to its lord's seat and to another sect's land; the politics map with the minor seats. |

**Rebuild:**

```
python -I tools/design/map/regions.py --seed 11 --regions 20 --out design/map/continent-11 \
    --detail design/map/continent-11/base/detail.jpg --sects design/map/continent-11/sects_proposal.json \
    --names design/map/continent-11/region_names.json
```

It takes about 2 minutes, and the same input gives the same output. Then place the minor sects (a few seconds; it
reads the saved images, so run it again after any rebuild):

```
python -I tools/design/map/minor_sects.py --map design/map/continent-11 \
    --sects design/map/continent-11/minor_sects_proposal.json
python -I tools/design/map/places.py --map design/map/continent-11
```

`design/map/.gdignore` keeps Godot from importing these design files.

## How the layout is drawn (v3, 2026-11-14)

The user found v2's sect lands "a bit too long". v2 had drawn 20 regions first and then handed them out to sects, so a
sect got whatever chain of regions was free. Three tier-1 sects were 2.7 to 3.3 times as long as they were wide.

v3 works top-down:

1. **Territories first.** Each great sect grows from its start tile over a terrain cost:
   - height and relief;
   - crossing a river (more for bigger rivers);
   - crossing a watershed (more between bigger catchments);
   - plus a flat cost on every step, so cheap lowland is not crossed for free.

   Seeds move to their territory's centre over 14 passes. They stay within 28 tiles (about 700 km) of the start,
   so each sect keeps its land. Per-sect weights pull sizes toward the tier shares: tier 1 is 1.2 and tier 2 is 0.85.
2. **Then regions inside each territory.** 20 in all, by land share, at least 2 a territory. They are grown the same
   way and kept inside their territory.
3. **Seats.** For each sect, the tool picks high ground well inside its territory, never glacier.

**Map check**:

| Measure | v2 | v3 |
|---|---|---|
| Territory elongation (long axis / short axis; 1 is round) | 1.34–3.28 | **1.07–1.74** |
| Territory hull fill (area / convex outline; coasts lower it) | 0.43–0.75 | 0.47–0.89 |
| Region size, against the mean of 4,271 tiles | 0.65–1.75× | 0.69–1.44× |
| Region edges that are crest, river, lake or coast | 87 % | 84 % |
| Land borders on crest, highland, river or lake | 46 % | 40 % |
| … counting watershed divides too | 69 % | 64 % |

Rule 23 asks for 60 %:
- **Counting coast:** 84 %, so it's met.
- **Land borders only:** 40 %, or 64 % if watershed divides count. Compact shapes cost a little here, because the far
  north is flat forest with few features to follow.

**Known rough spots to fix by hand:**
- A straight run on the Thúy Vi / Tùng Đào border near the north coast.
- Region 11 (the west peninsula) has almost no natural land border.

## Great sects (v3, approved 2026-11-14)

Sects are the only powers. There are no mortal kingdoms (Travel & Map rule 24, confirmed 2026-11-13) and no wild regions:
every region belongs to a great sect (user decision 2026-11-14). Wilderness, the land away from roads and towns, still
lies inside each territory. The 15–25 minor sects come later and sit inside these territories.

**Names** are Hán-Việt and lean romantic and poetic (user request 2026-11-14), with the English meaning alongside.
- **Suffixes vary:** tông (sect), cung (palace), các (pavilion), lâu (tower).
- **Not taken from known novels:** none are the well-known sect names of existing xianxia or wuxia novels.

| Sect | Hán tự | Meaning | Tier | Leans | Regions | Land | Shape |
|---|---|---|---|---|---|---|---|
| **Thiên Xu Tông** | 天樞宗 | Sect of the Heavenly Pivot. Thiên Xu is the first star of the Northern Dipper, the pivot the sky turns on. | 1 | Metal, Earth | 6, 14, 15 | 16.1 % | 1.25 |
| **Tùng Đào Cung** | 松濤宮 | Palace of the Pine Waves: wind in endless pine forest that sounds like surf. | 1 | Wood, Water | 1, 4, 5 | 16.3 % | 1.69 |
| **Lạc Hà Tông** | 落霞宗 | Sect of the Drifting Sunset Clouds, after Vương Bột's line *lạc hà dữ cô vụ tề phi*. The sunset is in the west, and so is the sect. | 1 | Earth, Wood | 10, 11, 12, 13 | 17.8 % | 1.63 |
| **Thính Vũ Lâu** | 聽雨樓 | Tower Where One Listens to the Rain. | 2 | Metal, Water, Thunder | 18, 19 | 12.4 % | 1.74 |
| **Băng Tâm Các** | 冰心閣 | Pavilion of the Ice Heart, after Vương Xương Linh's line *nhất phiến băng tâm tại ngọc hồ*. | 2 | Water, Ice | 7, 8, 9 | 13.0 % | 1.20 |
| **Thúy Vi Tông** | 翠微宗 | Sect of the Emerald Haze: the blue-green mist on distant hills. | 2 | Wood, Earth | 2, 3 | 11.6 % | 1.54 |
| **Phượng Minh Cung** | 鳳鳴宮 | Palace of the Phoenix's Call: the fire bird of the south. | 2 | Fire, Wood | 16, 17, 20 | 12.8 % | 1.07 |

**What each one holds:**
- **Thiên Xu Tông:** the heart of the continent. The central basin and the central range by the inland sea give it
  the richest ore of any sect (362 vein tiles) and the peaks to 4.7 km. Every route between north, south and east
  crosses it.
- **Tùng Đào Cung:** the northern forest. That means the great river basin, the long lake (118 lake tiles) and the inner
  forest: 84 % forest, the purest Wood land.
- **Lạc Hà Tông:** the west. It holds the dry west peninsula, the river country of the west-centre, the south-west
  steppe coast and the south-west island across the strait. It is warm, open and has the longest coast but one.
- **Thính Vũ Lâu:** the south. It holds the southern peaks, with the richest single region for ore (286 vein tiles),
  and the jungle coast below them. The rain comes off the sea onto these mountains.
- **Băng Tâm Các:** the north-east. It holds the only ice fields (30 tiles), the highest peak (5.2 km), the north-east
  forest peninsula and the dry eastern steppe behind the range.
- **Thúy Vi Tông:** the north-west. It holds the hills with karst and ore, and the cape with its volcanic isles
  (5 volcanoes and 5 hot springs).
- **Phượng Minh Cung:** the south-east. It holds the volcano coast (6 hot springs), the rain-forest range (the wettest
  land, 1,864 mm) and the grassland coast of the inland sea. It wraps around the gulf.

**Changes from v2:**
- **Lạc Hà Tông** moved west, to match its sunset name and to fill the west.
- **Thính Vũ Lâu** took the southern peaks.
- **Phượng Minh Cung** kept the volcanoes. It lost the eastern drylands to Băng Tâm Các.
- **Element leanings** follow each sect's new land.

**Why these numbers:**
- **Tier 1 has 3 sects** to match the ~3 Hóa Thần (difficulty targets): each would have one at its head. The tier-1
  sects hold 50 % of the land.
- **The ~27 Nguyên Anh** leave each great sect 2–3, and the rest are loose or demonic cultivators.

**Seats** are picked by the tool, and their tiles are in `politics_proposal.json`. Hand-placed sacred summits or spirit
veins (rules R27 and R29) can move them.

## The 20 regions (names approved 2026-11-14)

Names are Hán-Việt and lean romantic, in the same style as the sects (user request 2026-11-14). Each sect's regions
share a theme:
- **Thiên Xu Tông's** are stars of the Northern Dipper, like its own name.
- **Lạc Hà Tông's** come from Vương Bột's *Đằng Vương Các Tự*, the same text as its name.
- **Phượng Minh Cung's** come from the phoenix: the Kinh Thi ode and the Sơn Hải Kinh.
- **Băng Tâm Các's** follow its poem and the north-east's cold.
- **Thính Vũ Lâu's** follow rain and thunder.
- **Tùng Đào Cung's** follow the northern pines and waters.
- **Thúy Vi Tông's** follow its misty hills.

The last word names the land:
- **Water and coast:** Lâm (forest), Giác (cape), Hải (sea, here a sea of pines), Châu (land by the water),
  Đảo (island), Loan (bay).
- **Rivers and plains:** Xuyên (river land), Nguyên (plain), Mạc (desert).
- **High ground:** Lĩnh (ridge), Sơn (mountains).

Names live in `region_names.json`, keyed by the region ids in `regions.png`.

| # | Name | Hán tự | Meaning | Sect | Tiles | Main land (share %) | Why |
|---|---|---|---|---|---|---|---|
| 1 | **Lãnh Nguyệt Lâm** | 冷月林 | Forest of the Cold Moon | Tùng Đào Cung | 4,620 | Temperate forest 78, tundra 14, swamp 5 | The long lake under the northern moon |
| 2 | **Tuyết Hỏa Giác** | 雪火角 | Cape of Snow and Fire | Thúy Vi Tông | 4,729 | Temperate forest 71, tundra 17, swamp 4 | A cold cape with volcanic isles and hot springs |
| 3 | **Thanh Loan Lĩnh** | 青巒嶺 | Ridges of the Blue Peaks | Thúy Vi Tông | 5,169 | Temperate forest 68, high mountain 14, tundra 13 | The hills whose haze names Thúy Vi Tông |
| 4 | **Thâm Tùng Hải** | 深松海 | Deep Sea of Pines | Tùng Đào Cung | 4,981 | Temperate forest 88, high mountain 8, tundra 1 | Pine forest as wide as a sea |
| 5 | **Cửu Khúc Xuyên** | 九曲川 | Land of the Nine-Bend River | Tùng Đào Cung | 4,362 | Temperate forest 85, tundra 7, swamp 5 | The great northern river basin |
| 6 | **Dao Quang Lĩnh** | 瑤光嶺 | Ridge of the Jade Light | Thiên Xu Tông | 4,573 | Temperate forest 60, high mountain 23, steppe 9 | Dao Quang (Alkaid), a star of the Northern Dipper like Thiên Xu |
| 7 | **Ngọc Hồ Sơn** | 玉壺山 | Mountains of the Jade Vessel | Băng Tâm Các | 3,354 | Temperate forest 46, high mountain 33, tundra 9 | Băng tâm tại ngọc hồ: the ice heart sits in the jade vessel |
| 8 | **Cô Yên Mạc** | 孤煙漠 | Desert of the Lone Smoke | Băng Tâm Các | 3,452 | Steppe 44, desert 20, high mountain 15 | Vương Duy: đại mạc cô yên trực, a lone column of smoke over the great desert |
| 9 | **Hàn Sương Châu** | 寒霜洲 | Land of Cold Frost | Băng Tâm Các | 4,341 | Temperate forest 69, tundra 12, high mountain 9 | The north-east forest peninsula |
| 10 | **Cô Vụ Đảo** | 孤鶩島 | Isle of the Lone Wild Duck | Lạc Hà Tông | 4,099 | Grassland 53, bamboo forest 20, jungle 18 | Vương Bột: lạc hà dữ cô vụ tề phi, the same line as Lạc Hà Tông |
| 11 | **Trường Thiên Nguyên** | 長天原 | Plain of the Endless Sky | Lạc Hà Tông | 3,845 | Grassland 59, steppe 23, temperate forest 17 | Vương Bột: thu thủy cộng trường thiên nhất sắc |
| 12 | **Thu Thủy Loan** | 秋水灣 | Bay of Autumn Water | Lạc Hà Tông | 4,307 | Steppe 39, grassland 37, badlands 9 | The same line: autumn water one colour with the endless sky |
| 13 | **Ngư Ca Xuyên** | 漁歌川 | River Land of the Fishermen's Songs | Lạc Hà Tông | 2,928 | Temperate forest 36, grassland 25, steppe 20 | Vương Bột: ngư chu xướng vãn, fishing boats singing at dusk |
| 14 | **Thiên Tuyền Nguyên** | 天璇原 | Plain of the Heavenly Jade Wheel | Thiên Xu Tông | 5,082 | High mountain 27, steppe 26, highland 21 | Thiên Tuyền (Merak), the Dipper star beside Thiên Xu |
| 15 | **Ngọc Hành Sơn** | 玉衡山 | Mountains of the Jade Balance | Thiên Xu Tông | 4,110 | High mountain 46, steppe 20, grassland 15 | Ngọc Hành (Alioth), a star of the Northern Dipper |
| 16 | **Thê Ngô Lĩnh** | 棲梧嶺 | Ridge Where the Phoenix Roosts | Phượng Minh Cung | 3,517 | High mountain 38, grassland 23, bamboo forest 16 | The phoenix rests only in the wutong tree (ngô đồng) |
| 17 | **Triêu Dương Nguyên** | 朝陽原 | Plain of the Morning Sun | Phượng Minh Cung | 3,963 | Grassland 47, steppe 33, high mountain 11 | Kinh Thi: the phoenix calls, the wutong grows facing the morning sun |
| 18 | **Tiêu Vũ Lâm** | 蕉雨林 | Forest of Rain on Banana Leaves | Thính Vũ Lâu | 4,393 | Grassland 35, jungle 18, high mountain 12 | Rain on banana leaves, a classic image of listening to rain |
| 19 | **Kinh Trập Sơn** | 驚蟄山 | Mountains of the Waking Thunder | Thính Vũ Lâu | 6,167 | High mountain 32, grassland 25, bamboo forest 18 | Kinh Trập: the solar term when spring thunder wakes sleeping creatures |
| 20 | **Đan Huyệt Châu** | 丹穴洲 | Coast of the Vermilion Caves | Phượng Minh Cung | 3,433 | Grassland 41, jungle 35, steppe 9 | Sơn Hải Kinh: the phoenix is born on Mount Đan Huyệt; here the caves are volcanic vents |

Names were checked against the design files. Three first picks clashed with notables in the parked Meridian tree data
(Kính Hồ, Xuân Lôi, Ngô Đồng) and were replaced.

## Minor sects (approved 2026-11-14)

Sects & Missions (approved 2026-11-14) sets the frame:
- **Vassals:** 15–25 minor sects (tiểu tông môn), each a vassal of the great sect whose land it sits in. A vassal
  pays tribute, sends levies and holds sites, never a whole region (Sects rules 1–7).
- **Owner of the details:** the starting size, leaders, levels and alignment belong to World Generation & History
  (#27, Sects open question 9).

This list names and places them.

**How many: 22.**
- 4 under each tier-1 sect and 2–3 under each tier-2 sect.
- Every region has at least one.
- 22 leaves room under the 25 cap for sects that players and NPCs found (Sects rules 29–30).

**Names** follow the great sects' style:
- **Hán-Việt and romantic,** each from a line of classical poetry or prose.
- **Humbler suffixes than the great sects':** Môn (gate), Phái (school), Cốc (valley), Trang (manor),
  Quán (abbey), Viện (academy), Trai (studio), Đường (hall), Am (hermitage), Đài (terrace), Viên (garden).
- **Some echo their lord:**
  - Củng Tinh Quán's stars bow to the Heavenly Pivot.
  - Lãng Đào Môn's waves answer Tùng Đào's pine waves.
  - Phượng Minh's three vassals are the phoenix's bamboo seed, sweet spring and fire.
- **Checked against the design files.** Four first picks clashed with Đạo Ways or arts and were replaced:
  Tàng Phong, Dục Hỏa, Độc Điếu and Trầm Bích.
- **Not famous novel sects.**

**Alignment** is a first guess so the names can carry it:
- **15 chính đạo.**
- **5 trung lập:** the traders, herders, fishers and the fire-tempering hall.
- **2 ma đạo:**
  - **Hồng Đậu Trang:** poisoners in the southern jungle.
  - **Dạ Quang Môn:** blood sabres in the eastern desert.

  Both pay tribute to lords who would rather not look closely. That is a ready source of feuds and rebellions
  (Sects rule 6).

**Seats** are placed by `minor_sects.py`:
- **Fit to the sect:** each seat is the tile in its region that best fits the land the sect wants (the forge on
  ore by a river, the hermitage by the ice fields, the alchemists by the volcanoes).
- **Spacing:** at least 14 tiles from any other seat, and at least 4 from another sect's land.
- **Not under a region label.**
- **Not on a small islet,** except Hồng Lô Cốc, whose region's volcanoes are all on its islets.
- **Hand placement:** a seat can be placed by hand with `"tile"`.

**Map check:**
- Every seat met its first want; 83 % of all wants were met.
- The closest two seats are 18.4 tiles apart.

Three seats sit near a border, by the lie of the land:
- **Thối Tinh Môn** (4 tiles from Băng Tâm Các);
- **Hồng Đậu Trang** (4 tiles from Lạc Hà Tông);
- **Xuyên Lâm Môn** (5 tiles from Phượng Minh Cung).

Those are the vassals a neighbour could court (Sects rule 6).

| # | Name | Hán tự | Meaning | Lord | Region | Alignment | Leans | Craft |
|---|---|---|---|---|---|---|---|---|
| 1 | **Thối Tinh Môn** | 淬星門 | Gate of the Quenched Stars | Thiên Xu Tông | 15 Ngọc Hành Sơn | chính đạo | Metal, Fire | weapon forging (luyện khí) from star iron |
| 2 | **Phất Y Cốc** | 拂衣谷 | Valley of the Brushed Sleeve | Thiên Xu Tông | 15 Ngọc Hành Sơn | chính đạo | Metal, Wind | sword cultivation; wandering swordsmen for hire |
| 3 | **Củng Tinh Quán** | 拱星觀 | Abbey of the Bowing Stars | Thiên Xu Tông | 14 Thiên Tuyền Nguyên | chính đạo | Earth, Metal | formations (trận pháp) and star divination |
| 4 | **Cửu Cao Phái** | 九皋派 | School of the Nine Marshes | Thiên Xu Tông | 6 Dao Quang Lĩnh | chính đạo | Wind, Wood | spirit beasts: crane riders and beast tamers |
| 5 | **Hàm Nguyệt Trang** | 含月莊 | Manor That Holds the Moon | Tùng Đào Cung | 1 Lãnh Nguyệt Lâm | chính đạo | Water, Ice | water arts; spirit fish and lake pearls |
| 6 | **Vạn Hác Viện** | 萬壑院 | Academy of the Ten Thousand Ravines | Tùng Đào Cung | 4 Thâm Tùng Hải | chính đạo | Wood, Wind | sound cultivation: the zither (cầm) and its arts |
| 7 | **Thải Chi Cốc** | 採芝谷 | Valley of the Lingzhi Pickers | Tùng Đào Cung | 5 Cửu Khúc Xuyên | chính đạo | Wood, Water | herb fields and alchemy (luyện đan) |
| 8 | **Lãng Đào Môn** | 浪淘門 | Gate of the Washing Waves | Tùng Đào Cung | 5 Cửu Khúc Xuyên | chính đạo | Water, Wood | river fleets, ferries and river trade |
| 9 | **Bình Thủy Môn** | 萍水門 | Gate of Duckweed and Water | Lạc Hà Tông | 10 Cô Vụ Đảo | trung lập | Water, Wood | sea trade, ships and the strait crossing |
| 10 | **Mục Vân Trang** | 牧雲莊 | Manor of the Cloud Herders | Lạc Hà Tông | 11 Trường Thiên Nguyên | trung lập | Wind, Earth | spirit horses and herd beasts of the open plain |
| 11 | **Thiên Bảo Trai** | 天寶齋 | Studio of Heaven's Treasures | Lạc Hà Tông | 12 Thu Thủy Loan | trung lập | Metal, Earth | artifact refining and a treasure market |
| 12 | **Nam Phố Đường** | 南浦堂 | Hall of the Southern Shore | Lạc Hà Tông | 13 Ngư Ca Xuyên | chính đạo | Wood, Water | talismans (phù lục) and scribes |
| 13 | **Xuyên Lâm Môn** | 穿林門 | Gate Through the Forest | Thính Vũ Lâu | 19 Kinh Trập Sơn | chính đạo | Thunder, Wood | staff and footwork; guides through the rain forest |
| 14 | **Hồng Đậu Trang** | 紅豆莊 | Manor of the Red Beans | Thính Vũ Lâu | 18 Tiêu Vũ Lâm | ma đạo | Poison, Wood | poisons and charms behind a gracious door |
| 15 | **Lê Hoa Am** | 梨花庵 | Hermitage of the Pear Blossom | Băng Tâm Các | 7 Ngọc Hồ Sơn | chính đạo | Ice, Water | ice cultivation; a hermitage near the ice fields |
| 16 | **Trạc Anh Đài** | 濯纓臺 | Terrace Where the Hat Strings Are Washed | Băng Tâm Các | 9 Hàn Sương Châu | trung lập | Water, Ice | fishers and sea hunters of the frost coast |
| 17 | **Dạ Quang Môn** | 夜光門 | Gate of the Night-Glowing Cup | Băng Tâm Các | 8 Cô Yên Mạc | ma đạo | Fire, Metal | blood sabres and caravan raiding in the desert |
| 18 | **Hồng Lô Cốc** | 紅爐谷 | Valley of the Red Furnace | Thúy Vi Tông | 2 Tuyết Hỏa Giác | chính đạo | Fire, Wood | alchemy over volcanic fire |
| 19 | **Vân Khởi Quán** | 雲起觀 | Abbey Where the Clouds Rise | Thúy Vi Tông | 3 Thanh Loan Lĩnh | chính đạo | Earth, Wood | a Daoist abbey of mountain hermits and teachers |
| 20 | **Trúc Thực Viên** | 竹實園 | Garden of the Bamboo Seed | Phượng Minh Cung | 16 Thê Ngô Lĩnh | chính đạo | Wood, Fire | spirit farming: spirit grain and beast feed |
| 21 | **Lễ Tuyền Phái** | 醴泉派 | School of the Sweet Spring | Phượng Minh Cung | 17 Triêu Dương Nguyên | chính đạo | Water, Wood | healing, spirit wine and the lake springs |
| 22 | **Phần Vũ Đường** | 焚羽堂 | Hall of the Burning Feathers | Phượng Minh Cung | 20 Đan Huyệt Châu | trung lập | Fire, Earth | body tempering in the volcanic vents |

The line each name comes from is in `minor_sects_proposal.json` (`note`).

## Places, roads and arrays: proposal (awaiting approval)

Travel & Map rule 6 asks for 150–250 named places of the kinds it lists. Rules 9–11 add roads, rivers, sea lanes and
teleport arrays, and AC-TM-128 asks that every settlement can reach every other and that no inhabited island lacks a
port. This pass places **204**:

| Kind | Count | How it is placed |
|---|---|---|
| Great sect seats, minor sect seats | 7, 22 | Approved above |
| City (thành) | 15 | At most one a region. Count per sect set by hand: 3 for Lạc Hà Tông, 2 for each of the others. Each takes the most livable tile in its region: river mouths, coasts and mild lowland. All 15 are river ports, and 14 are sea ports. |
| Cultivator market (phường thị) | 10 | Beside each great seat (7) and beside the three trading vassals: Thiên Bảo Trai, Bình Thủy Môn and Lãng Đào Môn |
| Town (trấn), village (thôn) | 40, 70 | By livable land per region, at least 1 town and 2 villages in each. **Unnamed for now.** |
| Mine (khoáng mạch) | 16 | On the biggest ore-vein clusters, one more per 40 ore tiles. Thiên Xu Tông holds 7, as befits the richest ore. |
| Famous wild sites | 24 | The 7 highest isolated summits, the 2 biggest volcanoes, 5 biggest lakes, 5 biggest empty islands, 3 deepest forests and 2 deepest river gorges |

**Livability** of a tile:
- **The biome's base:** grassland is best; glacier and volcano are worst.
- **Climate:** mild temperature and enough rain.
- **The lie of the land:** lower and flatter is better.
- **Water:** a river (more where rivers gather), a coast, a lakeshore, and most of all a river mouth.

**Holders** (Sects rules 1–3):
- **Vassals' sites:** a town, village or mine within 10 tiles of a minor sect's seat belongs to that vassal. A vassal
  with none takes its nearest one, so all 22 vassals hold at least one site.
- **The great sects' sites:** cities, markets and every other settlement and mine.
- **No holder:** the wild sites.

**Roads and lanes:**
- **Trunk roads** join cities, markets and great seats. They are drawn as a spanning tree, plus links where the tree
  makes a detour of more than 1.8 times. They follow the cheapest ground over relief, height, swamp and jungle and avoid
  needless river crossings, and they merge where they can.
- **Branch roads:** every town, village, minor seat and mine takes one to the nearest road.
- **Sea lanes** hug the coast:
  - cities, markets and island towns each link to their nearest two ports;
  - every inhabited island links to another landmass.
- **Rivers:** 72 settlements sit on a river and serve as river ports.

**Teleport arrays:** 7, one in the best-placed city of each great sect. Each is owned by that sect. Fees and access
follow Formula K and Sects rule 19a.

**Map check:**

| Measure | Result |
|---|---|
| Places | 204 (rule 6 asks 150–250) |
| Settlements cut off from the rest (by road or lane) | none |
| Inhabited islands without a port | none |
| Roads | 68,400 km, of which trunk 31,500 km |
| Sea lanes, ports | 17, 80 |
| Settlements a region | 3 (the ice mountains of Ngọc Hồ Sơn) to 10 (the warm island Cô Vụ Đảo) |

**Names** follow the region names. They are Hán-Việt and romantic, each from a line of poetry or myth, and themed by
the sect whose land they are in:
- **Thiên Xu's land:** stars.
- **Lạc Hà's:** Vương Bột.
- **Phượng Minh's:** the phoenix.
- **Băng Tâm's:** Vương Xương Linh's frontier.
- **Thính Vũ's:** rain.

The last word says the kind: Thành city, Thị market, Phong peak, Sơn mountain, Hồ lake, Đảo island, Lâm forest,
Hạp gorge.

All of them were checked against the design files, and five first picks that clashed were replaced. The names are in
`place_names.json`, with the line each comes from (`note`).

| Kind | Name | Hán tự | Meaning | Region | Land of | Note |
|---|---|---|---|---|---|---|
| City | **Yên Ba Thành** | 煙波城 | City of the Misty Waves | 2 Tuyết Hỏa Giác | Thúy Vi Tông | teleport array |
| City | **Hàn Tân Thành** | 寒津城 | City of the Cold Ford | 3 Thanh Loan Lĩnh | Thúy Vi Tông |  |
| City | **Tùng Gian Thành** | 松間城 | City Among the Pines | 4 Thâm Tùng Hải | Tùng Đào Cung | teleport array |
| City | **Đào Thanh Thành** | 濤聲城 | City of the Wave Sound | 5 Cửu Khúc Xuyên | Tùng Đào Cung |  |
| City | **Khai Dương Thành** | 開陽城 | City Opening to the Sun | 6 Dao Quang Lĩnh | Thiên Xu Tông |  |
| City | **Trường Vân Thành** | 長雲城 | City of the Long Clouds | 8 Cô Yên Mạc | Băng Tâm Các | teleport array |
| City | **Liên Giang Thành** | 連江城 | City Where the Rain Meets the River | 9 Hàn Sương Châu | Băng Tâm Các |  |
| City | **Đàm Ảnh Thành** | 潭影城 | City of the Pool's Reflections | 10 Cô Vụ Đảo | Lạc Hà Tông |  |
| City | **Nhạn Thanh Thành** | 雁聲城 | City of the Wild Geese's Cry | 11 Trường Thiên Nguyên | Lạc Hà Tông |  |
| City | **Tử Điện Thành** | 紫電城 | City of the Purple Lightning | 12 Thu Thủy Loan | Lạc Hà Tông | teleport array |
| City | **Tinh Hán Thành** | 星漢城 | City of the Star River | 15 Ngọc Hành Sơn | Thiên Xu Tông | teleport array |
| City | **Lai Nghi Thành** | 來儀城 | City Where the Phoenix Comes | 17 Triêu Dương Nguyên | Phượng Minh Cung | teleport array |
| City | **Thu Trì Thành** | 秋池城 | City of the Autumn Pools | 18 Tiêu Vũ Lâm | Thính Vũ Lâu | teleport array |
| City | **Không Mông Thành** | 空濛城 | City of the Hazy Rain | 19 Kinh Trập Sơn | Thính Vũ Lâu |  |
| City | **Ngũ Thải Thành** | 五采城 | City of the Five Colours | 20 Đan Huyệt Châu | Phượng Minh Cung |  |
| Market | **Lam Yên Thị** | 嵐煙市 | Market of the Mountain Mist | 3 Thanh Loan Lĩnh | Thúy Vi Tông | beside Thúy Vi Tông |
| Market | **Tùng Hạ Thị** | 松下市 | Market Beneath the Pines | 4 Thâm Tùng Hải | Tùng Đào Cung | beside Tùng Đào Cung |
| Market | **Đào Sa Thị** | 淘沙市 | Market of the Washed Sands | 5 Cửu Khúc Xuyên | Tùng Đào Cung | beside Lãng Đào Môn |
| Market | **Tống Khách Thị** | 送客市 | Market of Farewells | 9 Hàn Sương Châu | Băng Tâm Các | beside Băng Tâm Các |
| Market | **Tương Phùng Thị** | 相逢市 | Market of Chance Meetings | 10 Cô Vụ Đảo | Lạc Hà Tông | beside Bình Thủy Môn |
| Market | **Vật Hoa Thị** | 物華市 | Market of the Land's Riches | 12 Thu Thủy Loan | Lạc Hà Tông | beside Thiên Bảo Trai |
| Market | **Hạc Đinh Thị** | 鶴汀市 | Market of the Crane Shoal | 13 Ngư Ca Xuyên | Lạc Hà Tông | beside Lạc Hà Tông |
| Market | **Thiên Quyền Thị** | 天權市 | Market of the Heavenly Balance | 14 Thiên Tuyền Nguyên | Thiên Xu Tông | beside Thiên Xu Tông |
| Market | **Thiều Âm Thị** | 韶音市 | Market of the Shao Music | 16 Thê Ngô Lĩnh | Phượng Minh Cung | beside Phượng Minh Cung |
| Market | **Hạnh Hoa Thị** | 杏花市 | Market of the Apricot Blossom | 19 Kinh Trập Sơn | Thính Vũ Lâu | beside Thính Vũ Lâu |
| Peak | **Phụ Tinh Phong** | 輔星峰 | Peak of the Companion Star | 6 Dao Quang Lĩnh | Thiên Xu Tông | 4.28 km |
| Peak | **Trích Tinh Phong** | 摘星峰 | Peak Where One Picks the Stars | 6 Dao Quang Lĩnh | Thiên Xu Tông | 4.72 km |
| Peak | **Hồi Lộ Phong** | 迴路峰 | Peak of the Winding Road | 7 Ngọc Hồ Sơn | Băng Tâm Các | 3.51 km |
| Peak | **Lăng Tuyệt Phong** | 凌絕峰 | Peak Above All | 7 Ngọc Hồ Sơn | Băng Tâm Các | 5.24 km |
| Peak | **Thanh Ải Phong** | 青靄峰 | Peak of the Blue Haze | 15 Ngọc Hành Sơn | Thiên Xu Tông | 3.07 km |
| Peak | **Cùng Mục Phong** | 窮目峰 | Peak of the Farthest Sight | 15 Ngọc Hành Sơn | Thiên Xu Tông | 2.62 km |
| Peak | **Liệt Khuyết Phong** | 列缺峰 | Peak of the Lightning Rift | 19 Kinh Trập Sơn | Thính Vũ Lâu | 4.0 km |
| Volcano | **Chúc Long Sơn** | 燭龍山 | Mountain of the Torch Dragon | 7 Ngọc Hồ Sơn | Băng Tâm Các | 1.35 km |
| Volcano | **Sương Diễm Sơn** | 霜焰山 | Mountain of Frost and Flame | 9 Hàn Sương Châu | Băng Tâm Các | 1.16 km |
| Lake | **Hạo Nguyệt Hồ** | 皓月湖 | Lake of the Bright Moon | 1 Lãnh Nguyệt Lâm | Tùng Đào Cung | 118 tiles |
| Lake | **Phiến Băng Hồ** | 片冰湖 | Lake of the Piece of Ice | 9 Hàn Sương Châu | Băng Tâm Các | 11 tiles |
| Lake | **Tinh Lạc Hồ** | 星落湖 | Lake Where the Stars Fall | 14 Thiên Tuyền Nguyên | Thiên Xu Tông | 18 tiles |
| Lake | **Triêu Hà Hồ** | 朝霞湖 | Lake of the Dawn Clouds | 17 Triêu Dương Nguyên | Phượng Minh Cung | 50 tiles |
| Lake | **Tàn Hà Hồ** | 殘荷湖 | Lake of the Last Lotus | 18 Tiêu Vũ Lâm | Thính Vũ Lâu | 9 tiles |
| Island | **Phù Chử Đảo** | 鳧渚島 | Isle of the Wild Ducks | 11 Trường Thiên Nguyên | Lạc Hà Tông | 59 tiles |
| Island | **Tịch Chiếu Đảo** | 夕照島 | Isle of the Evening Glow | 11 Trường Thiên Nguyên | Lạc Hà Tông | 78 tiles |
| Island | **Tương Phi Đảo** | 湘妃島 | Isle of the Xiang Consorts | 16 Thê Ngô Lĩnh | Phượng Minh Cung | 51 tiles |
| Island | **Dục Nhật Đảo** | 浴日島 | Isle Where the Sun Bathes | 20 Đan Huyệt Châu | Phượng Minh Cung | 50 tiles |
| Island | **Đồ Nam Đảo** | 圖南島 | Isle of the Southward Flight | 20 Đan Huyệt Châu | Phượng Minh Cung | 117 tiles |
| Forest | **Phản Cảnh Lâm** | 返景林 | Forest of the Returning Light | 1 Lãnh Nguyệt Lâm | Tùng Đào Cung |  |
| Forest | **Vô Tung Lâm** | 無蹤林 | Forest Without Tracks | 9 Hàn Sương Châu | Băng Tâm Các |  |
| Forest | **Đả Diệp Lâm** | 打葉林 | Forest of the Beaten Leaves | 19 Kinh Trập Sơn | Thính Vũ Lâu |  |
| Gorge | **Viên Đề Hạp** | 猿啼峽 | Gorge of the Crying Gibbons | 8 Cô Yên Mạc | Băng Tâm Các |  |
| Gorge | **Vạn Trùng Hạp** | 萬重峽 | Gorge of Ten Thousand Mountains | 15 Ngọc Hành Sơn | Thiên Xu Tông |  |

**Not in this pass:**
- **Town and village names:** 110 of them, for a later naming pass.
- **Four of rule 6's kinds:**
  - **spirit vein, secret realm and ruin:** they come with the hand-placed sacred features (spirit veins, sacred
    summits, storm peaks, the miasma wasteland) and the authored history (#27);
  - **cave abode:** opened in play.

  Until they exist, AC-TM-24 ("every kind at least once") is not yet met.
- **The famous blessed lands** (rule 28): they also come with the history.

## Open for the user

1. **Approve the places, roads and arrays**, or change any of them:
   - **names:** swap any in `place_names.json`;
   - **a city or a famous site:** move it by giving its name a new tile;
   - **how many cities a sect has:** change `cities_by_sect`.
2. **Then:** town and village names, the sacred features and the history sites.
3. The known rough spots above, by hand.

To change anything approved later:
- **A border:** change a sect's start tile or tier.
- **A minor seat:** add `"tile": [x, y]` or change its wants.
- **A minor sect's lord:** change its `lord` and `region`.
