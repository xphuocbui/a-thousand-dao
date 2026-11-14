# The Continent: candidate #11

**Chosen 2026-11-13** by the user from the 12 round-4 candidates (gallery: prototypes/continent-candidates). This is the
fixed world's starting point: it gets finished by hand, and every playthrough uses it (design/research/
fixed-world-decisions.md).

**Status:**
- **Layout:** v3. Sect territories are drawn first, then regions inside them.
- **Approved by the user on 2026-11-14:** the great sects, their names and territories, the region names, and
  the 22 minor sects with their seats.
- **Places, roads and arrays:** 204 places, approved by the user 2026-11-14.
- **Town and village names:** approved by the user 2026-11-14.
- **Sacred features:** spirit veins, sacred summits, deep caves and the miasma wasteland, approved by the user
  2026-11-14.
- **History sites:** famous secret realms, a ruin and blessed lands, plus candidate spots for the hidden ones,
  approved by the user 2026-11-14.
- **Mine names and origin home regions:** a proposal, awaiting the user's approval.
- **Still to do:**
  - the history itself (#27), which names the hidden slots;
  - the map's art style.

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
| `sacred_proposal.json` | Input, edited by hand: vein strengths and lengths, reaches, the derived features' thresholds, the wasteland's centre, and the names by kind and tile. |
| `sacred.json`, `sacred.png`, `sacred.jpg` | Output of `tools/design/map/sacred.py`: every vein with its tiles, the summits, caves, wasteland and source, the derived features' tiles, the new places and the map check. `sacred.png` is a 16-bit tile image with `base/features.png`'s authored bits (spirit vein 128, sacred summit 256, deep cave 512, miasma source 1024) and 2048 for a wasteland tile. |
| `history_proposal.json` | Input, edited by hand: the famous secret realms, ruin and blessed lands with names, anchors and data; the hidden slots by kind, count and element; the tile secrets per region; the rules for candidate ground. |
| `history.json`, `history.jpg` | Output of `tools/design/map/history.py`: the famous sites with tiles (and each large blessed land's tiles), every hidden slot with its candidate tiles, the tile secrets, and the map check. |
| `origins_proposal.json` | The home regions for each origin, and the seven clans with their towns. Written by hand. |
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
python -I tools/design/map/sacred.py --map design/map/continent-11
python -I tools/design/map/history.py --map design/map/continent-11
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

## Places, roads and arrays (approved 2026-11-14)

Travel & Map rule 6 asks for 150–250 named places of the kinds it lists. Rules 9–11 add roads, rivers, sea lanes and
teleport arrays, and AC-TM-128 asks that every settlement can reach every other and that no inhabited island lacks a
port. This pass places **204**:

| Kind | Count | How it is placed |
|---|---|---|
| Great sect seats, minor sect seats | 7, 22 | Approved above |
| City (thành) | 15 | At most one a region. Count per sect set by hand: 3 for Lạc Hà Tông, 2 for each of the others. Each takes the most livable tile in its region: river mouths, coasts and mild lowland. All 15 are river ports, and 14 are sea ports. |
| Cultivator market (phường thị) | 10 | Beside each great seat (7) and beside the three trading vassals: Thiên Bảo Trai, Bình Thủy Môn and Lãng Đào Môn |
| Town (trấn), village (thôn) | 40, 70 | By livable land per region, at least 1 town and 2 villages in each. Named from a pool, below. |
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

**Town and village names** (approved 2026-11-14):
- **The pool:** 170 short Hán-Việt names, written by hand, each with its Hán tự and meaning. They are humbler than
  the famous names: Triều Âm (Tide Song), Liễu Ngạn (Willow Bank), Đạo Hương (Rice Scent), Tiều Ca (Woodcutters'
  Song), Đà Linh (Camel Bells).
- **Grouped by land:** coast, river, lake, forest, bamboo, jungle, grassland, steppe, desert, cold and hills.
- **Kind word:** Trấn for a town, Thôn for a village.
- **Fit to the tile:** each place takes a name that fits its own tile (its water, hills, cold or biome), from the
  fitting group with the most names left.
- **Checked:**
  - every name is used once;
  - every name was checked against the design files, and 14 that clashed were replaced;
  - only one village took a name from a neighbouring group (Mã Minh, "Neighing Horses", on grassland).
- **Where they live:** the pool is in `place_names.json` (`pool`). To rename one place, add it by kind and tile like
  the cities.

| Region | Towns (Trấn) | Villages (Thôn) |
|---|---|---|
| 1 Lãnh Nguyệt Lâm | Quy Điểu (Homing Birds) | Tuyết Lộc (Snow Deer), Hàn Yên (Cold Smoke), Noãn Ốc (Warm Houses) |
| 2 Tuyết Hỏa Giác | Mục Ca (Herders' Song), Bạch Sa (White Sands) | Mạch Lãng (Wheat Waves), Phong Phàm (Wind in the Sails), Hòa Thử (Grain and Millet), Ẩn Loan (Hidden Cove) |
| 3 Thanh Loan Lĩnh | Bách Diệp (Cypress Leaf), Tiều Ca (Woodcutters' Song) | Ô Đề (Crows' Cry), Lâm Tuyền (Woods and Springs), Thu Diệp (Autumn Leaves) |
| 4 Thâm Tùng Hải | Lộc Minh (Deer Call), Cổ Độ (Old Ferry) | Bạch Hoa (White Birch), Thanh Tùng (Green Pine), Tùng Phong (Pine Wind) |
| 5 Cửu Khúc Xuyên | Hà Bạn (Riverside), Lâm Hạ (Under the Trees) | Tuyết Ốc (Snow Houses), Hàn Mai (Winter Plum), Bạch Lang (White Wolf) |
| 6 Dao Quang Lĩnh | Bích Khê (Jade Brook), Thanh Bách (Green Cypress) | Ba Quang (Glinting Waves), Hạc Quy (Crane's Return), Lộc Uyển (Deer Park) |
| 7 Ngọc Hồ Sơn | Hòe Âm (Locust Shade) | Đỗ Quyên (Azalea), Hoàng Oanh (Oriole) |
| 8 Cô Yên Mạc | Hồi Lan (Turning Waves) | Ngư Đàm (Fish Pool), Liên Đường (Lotus Pond), Mã Minh (Neighing Horses) |
| 9 Hàn Sương Châu | Mộc Lan (Magnolia), Kê Minh (Cockcrow) | Tiều Lộ (Woodcutters' Path), Lâm Ẩn (Hidden in the Woods), Lô Hoa (Reed Flowers) |
| 10 Cô Vụ Đảo | Xích Ngạn (Red Shore), Hải Yến (Sea Swallow), Triều Âm (Tide Song) | Bối Sa (Shell Sands), Lãng Thạch (Wave Rock), Dương Liễu (Willows), Tình Sa (Sunlit Sands), Nguyệt Loan (Moon Cove) |
| 11 Trường Thiên Nguyên | Thanh Điền (Green Fields), Thảo Đường (Grass Pond), Ngư Lương (Fish Weir) | Điền Viên (Fields and Gardens), Yến Quy (Swallows' Return), Chu Tân (Boat Ford), Lô Cảng (Reed Harbour), Diêm Điền (Salt Pans) |
| 12 Thu Thủy Loan | Liễu Ngạn (Willow Bank), Hòa Phong (Gentle Breeze), Ngũ Cốc (Five Grains) | Khê Thanh (Brook Sound), Khê Đầu (Brook Head), Hải Môn (Sea Gate), Tân Khẩu (Harbour Mouth) |
| 13 Ngư Ca Xuyên | Phong Lâm (Maple Wood), Tang Ma (Mulberry and Hemp) | Hoa Khê (Flower Brook), Ngân Than (Silver Shoal), Phương Thảo (Fragrant Grass), Thủy Khẩu (Water's Mouth) |
| 14 Thiên Tuyền Nguyên | Thạch Kiều (Stone Bridge) | Mộc Hương (Wood Scent), Thụ Âm (Tree Shade) |
| 15 Ngọc Hành Sơn | Song Kiều (Twin Bridges) | Thủy Đối (Water Mill), Thanh Mạch (Green Wheat), Châu Bạng (Pearl Oyster) |
| 16 Thê Ngô Lĩnh | Mạch Điền (Wheat Fields), Thanh Khê (Clear Brook) | Đào Khê (Peach Brook), Hà Loan (River Bend), Bích Lãng (Jade Waves) |
| 17 Triêu Dương Nguyên | Hoàng Vân (Yellow Clouds of Grain), Đạo Hương (Rice Scent), Lục Dã (Green Meadows) | Thủy Điền (Paddy Fields), Âu Lộ (Gulls and Herons), Ngân Hạnh (Ginkgo), Lý Hoa (Plum Blossom), Hoàng Ngưu (Yellow Ox) |
| 18 Tiêu Vũ Lâm | Bình Dã (Open Plain), Xuân Thảo (Spring Grass) | Kiều Bạn (Bridgeside), Bình Độ (Calm Ferry), Hoa Điền (Flower Fields), Yên Kiều (Misty Bridge) |
| 19 Kinh Trập Sơn | Lãng Hoa (Spray Flowers), Vọng Hải (Sea Watch), Phong Đăng (Rich Harvest) | Ương Ca (Planting Song), Song Khê (Twin Brooks), Thượng Độ (Upper Ferry), Hà Châu (River Isle) |
| 20 Đan Huyệt Châu | Thạch Cơ (Stone Jetty), Tang Điền (Mulberry Fields) | Cúc Viên (Chrysanthemum Garden), Tang Âm (Mulberry Shade), Hồ Tâm (Lake Heart), Lô Châu (Reed Isle) |

**Not in this pass:**
- **Three of rule 6's kinds:**
  - **secret realm and ruin:** they come with the authored history (#27);
  - **cave abode:** opened in play.

  The spirit veins are placed with the sacred features, below.

  Until they exist, AC-TM-24 ("every kind at least once") is not yet met.
- **The famous blessed lands** (rule 28): they also come with the history.

## Sacred features (approved 2026-11-14)

The authored features of Travel & Map rule 4, which the generator never makes (map-making rules R27, R29), and the
three it derives from the terrain (R30). `tools/design/map/sacred.py` lays them from `sacred_proposal.json`.

**What it lays:**

| Feature | Pushes | How many | Where |
|---|---|---|---|
| Spirit vein (linh mạch) | density | 36 veins, 326 tiles | A **great vein** (19 tiles, +0.9 density) along the ridge under each great seat; a **small vein** (5 tiles, +0.4) under each minor seat; one **famous wild vein** (13 tiles, +0.7) in each great sect's land. Reach 222 km. |
| Sacred summit | Light | 3 | Lăng Tuyệt Phong and Trích Tinh Phong (the two highest peaks), and **Cao Cương Phong**, the highest free summit in the south and west, a new peak place. |
| Deep cave | Darkness | 3 | In rugged ground with no place within reach (111 km): one near Dạ Quang Môn, the others spread over the other sects. |
| Miasma wasteland (tử địa) and its source | Darkness, danger | 299 tiles | One old battlefield, set by hand: the scorched badlands where Thiên Xu Tông, Lạc Hà Tông and Thính Vũ Lâu meet. Its tiles become the miasma biome. |
| Snowline (derived) | a little Ice | 29 tiles | Land at 4.3 km or higher; reach 62 km. |
| Storm peaks (derived) | Thunder | 51 tiles | Land at 2.5 km or higher with 3,000 mm of rain or more. |
| High plateau (derived) | Wind | 26 tiles | Land at 2.0 km or higher, with relief under 0.3 km, in patches of 12 tiles or more. |

**How a vein is drawn:** from its seat (or its wild spot) it follows the ridge both ways. Each step goes onto the
highest dry tile, turning at most 45 degrees. A wild vein takes the richest wild ground in its sect's land: at least
30 tiles from a great seat, 12 from a minor seat and 8 from any place, between 0.6 and 3.8 km up, with a bonus within
14 tiles of another sect's border. Veins are what sects fight over, so six of the seven sit near a border.

**Great veins** (under the seats):

| Name | Hán tự | Meaning | Region | Seat | Tiles | Land density* | The line behind it |
|---|---|---|---|---|---|---|---|
| **Thanh Lam Mạch** | 青嵐脈 | Vein of the Green Haze | 3 | Thúy Vi Tông | 19 | 1.8 | Under Thúy Vi Tông. Lam is the mountain haze; thúy vi is the green of a hillside seen through it. |
| **Phục Linh Mạch** | 茯苓脈 | Poria Vein | 4 | Tùng Đào Cung | 19 | 1.84 | Under Tùng Đào Cung. Poria grows on old pine roots and was said to be pine sap a thousand years under the earth. |
| **Hàn Quang Mạch** | 寒光脈 | Vein of Cold Light | 8 | Băng Tâm Các | 19 | 1.51 | Under Băng Tâm Các. The cold light of Vương Xương Linh's ice heart in its jade pot (nhất phiến băng tâm tại ngọc hồ). |
| **Dung Kim Mạch** | 熔金脈 | Vein of Molten Gold | 13 | Lạc Hà Tông | 19 | 1.61 | Under Lạc Hà Tông. Lý Thanh Chiếu: lạc nhật dung kim, the setting sun melting into gold. |
| **Tử Vi Mạch** | 紫微脈 | Vein of the Pole Star | 14 | Thiên Xu Tông | 19 | 2.0 | Under Thiên Xu Tông. Tử Vi is the enclosure of the pole star, which the Dipper circles. |
| **Lãm Huy Mạch** | 覽輝脈 | Vein of the Beheld Radiance | 16 | Phượng Minh Cung | 19 | 2.01 | Under Phượng Minh Cung. Giả Nghị: the phoenix soars a thousand fathoms and comes down only where it sees the radiance of virtue. |
| **Tế Vũ Mạch** | 細雨脈 | Vein of Fine Rain | 18 | Thính Vũ Lâu | 19 | 2.4 | Under Thính Vũ Lâu. Đỗ Phủ's good rain slips in with the night wind and moistens all things without a sound. |

**Famous wild veins** (each a new spirit vein place, held by its great sect):

| Name | Hán tự | Meaning | Region | Land of | Tiles | Land density* | Note |
|---|---|---|---|---|---|---|---|
| **Tinh Tủy Mạch** | 星髓脈 | Star Marrow Vein | 6 | Thiên Xu Tông | 13 | 1.86 | A wild vein high in Dao Quang Lĩnh, near Trích Tinh Phong, 4 tiles from Băng Tâm's border. |
| **Thương Tùng Mạch** | 蒼松脈 | Vein of the Grey Pines | 4 | Tùng Đào Cung | 13 | 1.83 | A wild vein under the old pine sea, 4 tiles from Thiên Xu's border. |
| **Trường Hà Mạch** | 長河脈 | Vein of the Long River | 12 | Lạc Hà Tông | 13 | 1.81 | Vương Duy: trường hà lạc nhật viên, the long river and the round setting sun. On the border with Thính Vũ. |
| **Kinh Lôi Mạch** | 驚雷脈 | Vein of the Startling Thunder | 19 | Thính Vũ Lâu | 13 | 1.84 | In Kinh Trập Sơn, the mountains of the thunder that wakes the sleepers; within reach of the storm peaks, so it carries Thunder. 5 tiles from Thiên Xu's border. |
| **Băng Phách Mạch** | 冰魄脈 | Vein of the Ice Soul | 7 | Băng Tâm Các | 13 | 1.84 | Băng phách, the ice soul, is an old name for the moon. Under the ice mountains of Ngọc Hồ Sơn, within reach of the storm peaks. |
| **Hỏa Ngọc Mạch** | 火玉脈 | Fire Jade Vein | 2 | Thúy Vi Tông | 7 | 2.06 | Under a volcano on an island off Tuyết Hỏa Giác, far out in the western sea, where Lạc Hà's waters begin. |
| **Đan Sơn Mạch** | 丹山脈 | Vein of the Cinnabar Mountain | 16 | Phượng Minh Cung | 13 | 1.82 | Sơn Hải Kinh's cinnabar mountain is where the phoenix is born. 3 tiles from Thiên Xu's border. |

**The other named features:**

| Kind | Name | Hán tự | Meaning | Tile | Note |
|---|---|---|---|---|---|
| Sacred summit (new peak) | **Cao Cương Phong** | 高岡峰 | Peak of the High Ridge | [400, 296], 2.56 km | Kinh Thi: phượng hoàng minh hĩ, vu bỉ cao cương, the phoenix sings on that high ridge. A sacred summit (Light). |
| Deep cave | **Cửu U Động** | 九幽洞 | Cave of the Nine Depths | [398, 167] | A shaft into the dark under Ngọc Hành Sơn, a few days' ride from Dạ Quang Môn. |
| Deep cave | **Tàng Trập Động** | 藏蟄洞 | Cave of the Sleepers | [318, 256] | Where the creatures of Kinh Trập Sơn sleep until the spring thunder wakes them. |
| Deep cave | **Huyền Minh Động** | 玄冥洞 | Cave of the Dark North | [470, 129] | Huyền Minh is the god of winter and the dark north. A lava tube under a dead volcano of Hàn Sương Châu. |
| Miasma wasteland | **Chiết Kích Nguyên** | 折戟原 | Plain of Broken Halberds | around [244, 211] | Đỗ Mục: chiết kích trầm sa thiết vị tiêu, a broken halberd sunk in the sand, its iron not yet worn away. Who fought here is for the history (#27). |
| Its source | **Vạn Cốt Trủng** | 萬骨冢 | Barrow of Ten Thousand Bones | [244, 211] | Tào Tùng: nhất tướng công thành vạn cốt khô, one general's glory, ten thousand bones dried. |

*Land density is the tool's estimate of Formula C on tiles: biome base, depth into the biome, and feature pushes. It
leaves out the place-kind offset and the prebuilt works, which add to every seat (AC-TM-115: a seat on land at 1.00
reaches 1.40).

**Map check** (the tool reports; it does not judge):
- **Places:** 212, inside rule 6's 150–250 (204 before, plus 7 spirit veins and 1 peak).
- **Wild land at density 1.4 or more:** 3.6 % of wilderness tiles (AC-TM-127
  wants 3–5 %). 99 % of them are near a vein or deep in a rich biome
  (it wants at least 70 %).
- **Variants** (AC-TM-07: each in at most 2 % of places, so at most 4):
  - Ice: 4 (Chúc Long Sơn, Thính Vũ Lâu, Trích Tinh Phong, Lăng Tuyệt Phong);
  - Thunder: 4 (Cùng Mục Phong, Kinh Lôi Mạch, Băng Phách Mạch, Cao Cương Phong);
  - Light: 3 (Trích Tinh Phong, Lăng Tuyệt Phong, Cao Cương Phong);
  - Darkness: 2 (Tiều Ca Trấn, Thu Diệp Thôn);
  - Wind: 0 (none).
- **Spirit vein places:** land density 1.81–2.06
  (Formula C's band is 1.4–2.0).
- **Great seats:** 1.51–2.4 on land
  alone. Minor seats average 1.3, which the prebuilt works lift past 1.4.
- **The wasteland:** 299 tiles, no place inside, 0 road tiles.

**Rough spots:**
- **Hỏa Ngọc Mạch** reads 2.06, just over the vein band, because it sits on a volcano with hot springs. A spirit-vein
  place offset of −0.1 would fix it.
- **Thính Vũ Lâu's seat** hits the 2.40 clamp: a great vein, deep jungle and a hot spring together.
- **The north-east is crowded:** two sacred summits, two wild veins and a deep cave sit within 25 tiles. That is where
  the highest mountains are.
- **No Wind place:** the high plateaus are small and empty. Wind roots will have to open a cave abode there.
- **No deep cave near Hồng Đậu Trang:** its jungle is flat lowland, so there is nowhere for a deep cave.

**Not yet:**
- **Hidden things:** pocket veins and other tile secrets, the secret realms, ruins and blessed lands come from the
  history (#27) as candidate spots.
- **The battle:** who fought on Chiết Kích Nguyên is for #27 too.
- **The full build:** the fine-cell build (Formula C) will read `sacred.png` and replace these estimates.

## History sites (approved 2026-11-14)

`tools/design/map/history.py` lays the ground the history leaves behind (Travel & Map rules 15, 26, 28–30), from
`history_proposal.json`. There are two kinds of site:
- **Famous sites** are the same every game and shown on the overview.
- **Hidden slots** are ground for the history (#27). Each slot has 2–3 candidate tiles in the wilderness, and each
  game's seed picks one. The history names the slot and links it to a fact, such as a dead cultivator or a vanished
  sect. Candidates of one slot sit within 45 tiles of each other, so the story's geography holds, and at least 6
  apart, so a guide can't give the spot away.

**Famous sites:**

| Kind | Name | Hán tự | Meaning | Where | Held by; data | The line behind it |
|---|---|---|---|---|---|---|
| Secret realm | **Thiết Mã Cảnh** | 鐵馬境 | Realm of the Armoured Horses | Thiên Tuyền Nguyên, [244, 206] | Thiên Xu Tông; opens every 120 seasons for 4 | Lục Du: thiết mã băng hà nhập mộng lai, armoured horses and frozen rivers come into my dreams. Its gate opens inside Chiết Kích Nguyên, near the barrow; whose war it holds is for the history (#27). |
| Secret realm | **Phù Tang Cảnh** | 扶桑境 | Realm of the Sunrise Mulberry | Đan Huyệt Châu, [466, 338] | Phượng Minh Cung; opens every 60 seasons for 3 | Sơn Hải Kinh: in the hot valley stands the Phù Tang tree, where the ten suns bathe. Its gate is on the island Dục Nhật Đảo, where the sun bathes. |
| Secret realm | **Đào Nguyên Cảnh** | 桃源境 | Realm of the Peach Blossom Spring | Tuyết Hỏa Giác, [108, 146] | Thúy Vi Tông; opens every 80 seasons for 2 | Đào Uyên Minh: a fisherman follows a stream of peach petals through a cave into a hidden valley, and can never find it again. Its gate is a cave by a forest stream. |
| Ruin | **Cố Lũy** | 故壘 | The Old Ramparts | Thiên Tuyền Nguyên, [254, 199] | Thiên Xu Tông | Tô Thức: cố lũy tây biên, nhân đạo thị Tam Quốc Chu lang Xích Bích, west of the old ramparts, they say, is where the Three Kingdoms fought. Fallen walls on the edge of Chiết Kích Nguyên; whose they were is for the history (#27). |
| Large blessed land | **Bắc Thần Phúc Địa** | 北辰福地 | Blessed Land of the North Star | 120 tiles round Thiên Xu Tông | Metal, ΔD3 +0.8 | Luận Ngữ: like the North Star, which keeps its place while all the stars turn toward it. Around Thiên Xu Tông's seat. |
| Large blessed land | **Thiên Xích Phúc Địa** | 千尺福地 | Blessed Land of the Thousand-Foot Pines | 110 tiles round Tùng Đào Cung | Wood, ΔD3 +0.8 | Đỗ Phủ: thanh tùng hận bất cao thiên xích, I only regret the green pine is not a thousand feet tall. Around Tùng Đào Cung's seat. |
| Large blessed land | **Địa Linh Phúc Địa** | 地靈福地 | Blessed Land Where the Earth Is Alive | 110 tiles round Lạc Hà Tông | Earth, ΔD3 +0.8 | Vương Bột, Đằng Vương Các Tự (the text Lạc Hà is named from): nhân kiệt địa linh, great men where the earth is alive with spirit. Around Lạc Hà Tông's seat. |
| Small blessed land | **Tuyền Cơ Đài** | 璇璣臺 | Terrace of the Armillary | [280, 177], by Thiên Xu Tông | Earth, ΔD3 +0.5 | Tuyền cơ, the bowl of the Dipper and the armillary that tracks it. The sect head's retreat. |
| Small blessed land | **Thạch Thượng Tuyền** | 石上泉 | Spring Over the Stones | [237, 118], by Tùng Đào Cung | Water, ΔD3 +0.5 | Vương Duy: minh nguyệt tùng gian chiếu, thanh tuyền thạch thượng lưu; the city Tùng Gian took the first half. The sect head's retreat. |
| Small blessed land | **Châu Liêm Đình** | 珠簾亭 | Pavilion of the Pearl Blinds | [200, 205], by Lạc Hà Tông | Wood, ΔD3 +0.5 | Vương Bột: châu liêm mộ quyển Tây Sơn vũ, at dusk the pearl blinds roll up on the rain over the western hills. The sect head's retreat. |
| Small blessed land | **Văn Lôi Đài** | 聞雷臺 | Terrace Where Thunder Is Heard | [254, 251], by Thính Vũ Lâu | Thunder, ΔD3 +0.5 | Where the rain the tower listens to turns to thunder. The sect head's retreat. |
| Small blessed land | **Tố Tâm Động** | 素心洞 | Cave of the Plain Heart | [456, 136], by Băng Tâm Các | Ice, ΔD3 +0.5 | The ice heart in its jade pot, kept plain. The sect head's retreat. |
| Small blessed land | **Hoành Thúy Đình** | 橫翠亭 | Pavilion Across the Green | [147, 88], by Thúy Vi Tông | Wood, ΔD3 +0.5 | Lý Bạch: thương thương hoành thúy vi, grey-green, the emerald haze lies across the hills. The sect head's retreat. |
| Small blessed land | **Bích Ngô Đình** | 碧梧亭 | Pavilion of the Green Wutong | [365, 252], by Phượng Minh Cung | Fire, ΔD3 +0.5 | Đỗ Phủ: bích ngô thê lão phượng hoàng chi, on the green wutong the old phoenix perches. The sect head's retreat. |

- **The three tier-1 sects** each sit inside a large blessed land of 110–120 tiles. Those 3 hold ~3 Hóa Thần.
- **Each great sect** keeps a one-tile retreat for its head, 2–7 tiles from its seat, leaning to one of its elements.
- **The secret realms** follow rule 26: a 4-season rumour lead, and the sect whose land holds the gate sets the quota
  (Sects rule 19a).

**Hidden slots:**

| Kind | Slots | Candidate spots | Elements |
|---|---|---|---|
| Secret realm | 3 | 9 | — |
| Ruin of a vanished sect | 4 | 12 | — |
| Dead cultivator's cave abode | 6 | 18 | — |
| Large blessed land | 2 | 5 | Water, Fire |
| Small blessed land | 13 | 37 | Metal, Metal, Earth, Water, Fire, Wind, Wind, Light, Light, Darkness, Darkness, Ice, Thunder |
| Tile secret (spring, pocket vein, herb patch, cache) | 80 (4 per region) | 240 | — |

**How the candidates are chosen:**
- **Abodes:** rugged, rich ground, because a cultivator picks a strong spot.
- **Ruins:** open, watered ground, the old grounds of a sect.
- **Secret realms:** strange ground, near the dark, storms, ice, fire or on an islet.
- **Blessed lands:** ground that suits their element: forest for Wood, volcanoes for Fire, high summits for Light.
  A large one must have room for its whole area (90 tiles), with no place inside.
- **Tile secrets:** each by its kind. A spring goes by water or warm ground, a pocket vein by a ridge or a vein, a herb
  patch on rich forest, and a cache a few days from a settlement.
- **Thin slots:** where good ground runs out, the tool relaxes the fit and the gaps step by step, and records it
  (11 slots: A-3, A-4, A-5, A-6, L-2, S-8, S-9, S-10, S-11, S-13, S1-1).

**Map check:**
- **Places:** 229, counting one spot per hidden slot, inside rule 6's 150–250.
- **Secret realms:** 6 (2.6 %); Formula C's table has 3 %.
- **Ruins and abodes:** 11 (4.8 %); the table has 5 %.
- **Blessed lands:** 5 large and 20 small, inside rule 28's 2–5 and 10–30.
  - Their elements cover all ten: Darkness 2, Earth 3, Fire 3, Ice 2, Light 2, Metal 3, Thunder 2, Water 3, Wind 2, Wood 3. Every variant
    root has at least two homes worth finding.
  - Areas are 90–120 tiles, inside AC-TM-114's 40–180.
- **Every candidate** is dry land with no place on it.

**Rough spots:**
- **Secret realm density.** Formula C wants a secret realm place at 1.5–2.2, but the gate tiles read
  0.4–1.85. Thiết Mã Cảnh's gate stands in the
  wasteland, at 0.4. The realm's density should be its inside, set per realm, not its gate's. Travel & Map needs to say
  so (an open question).
- **Too many rich candidates.** 53 % of ruin and abode candidates read
  1.4 or more, against the table's 30 %. Every candidate is capped at 1.6. The place-kind offset can bring the share
  down.
- **Variants on hidden places.** The variant check (at most 2 % of places) covers the fixed places only. Thiết Mã
  Cảnh's gate adds a third Darkness place. A hidden spot that lands near a feature can add one more each game.
- **Clustered slots.** The cold north-east and the southern mountains hold many slots, because that is where Light,
  Thunder and Darkness ground is.

## Mine names and origins: proposal (awaiting approval)

**Mine names.** The 16 mines (khoáng mạch) are named for the stone and the land, themed like their holders. The name
is only a name. What a mine yields comes from its land (Travel & Map rule 20), and four names were changed so none
reads as an item material (Tinh Thiết, Xích Đồng, Lôi Tinh, Hàn Thiết).

| Name | Hán tự | Meaning | Region | Held by | Note |
|---|---|---|---|---|---|
| **Bích Ngọc Khoáng** | 碧玉礦 | Green Jade Mine | 3 Thanh Loan Lĩnh | Hồng Lô Cốc | Green stone from the green hills of Thúy Vi. |
| **Vân Mẫu Khoáng** | 雲母礦 | Mica Mine | 3 Thanh Loan Lĩnh | Vân Khởi Quán | Mica, 'mother of clouds', for Vân Khởi Quán, the abbey of rising clouds. |
| **Thạch Lục Khoáng** | 石綠礦 | Malachite Mine | 4 Thâm Tùng Hải | Vạn Hác Viện | Malachite, the green of the pine sea, dug under the trees. |
| **Băng Lăng Khoáng** | 冰稜礦 | Icicle Mine | 9 Hàn Sương Châu | Băng Tâm Các | Shafts hung with ice in the frost land of Hàn Sương Châu. |
| **Xích Kim Khoáng** | 赤金礦 | Red Gold Mine | 12 Thu Thủy Loan | Thiên Bảo Trai | Gold the colour of Lạc Hà's sunset, for Thiên Bảo Trai's treasure market. |
| **Thần Sa Khoáng** | 辰砂礦 | Cinnabar Mine | 14 Thiên Tuyền Nguyên | Thiên Xu Tông | Cinnabar from the red badlands, the alchemists' first stone. |
| **Lưu Hoàng Khoáng** | 硫黃礦 | Sulphur Mine | 14 Thiên Tuyền Nguyên | Thiên Xu Tông | Yellow sulphur crusts in the badlands near the wasteland. |
| **Vẫn Tinh Khoáng** | 隕星礦 | Fallen Star Mine | 14 Thiên Tuyền Nguyên | Củng Tinh Quán | Iron from a star that fell on the high plain, for Củng Tinh Quán, whose stars bow to the Pivot. |
| **Thiên Ngoại Khoáng** | 天外礦 | Mine of the Iron from Beyond the Sky | 15 Ngọc Hành Sơn | Thối Tinh Môn | Thối Tinh Môn forges star iron, and says this is where it comes from. |
| **Huyền Thiết Khoáng** | 玄鐵礦 | Black Iron Mine | 15 Ngọc Hành Sơn | Thiên Xu Tông | Dark heavy iron under Ngọc Hành Sơn. |
| **Can Tương Khoáng** | 干將礦 | Gan Jiang's Mine | 15 Ngọc Hành Sơn | Phất Y Cốc | Can Tương, the swordsmith of legend; Phất Y Cốc's swords are forged from its ore. |
| **Bạch Ngân Khoáng** | 白銀礦 | Silver Mine | 15 Ngọc Hành Sơn | Thiên Xu Tông | Silver below the cinnabar mountain of Đan Sơn Mạch. |
| **Kinh Điện Khoáng** | 驚電礦 | Startling Lightning Mine | 19 Kinh Trập Sơn | Thính Vũ Lâu | In Kinh Trập Sơn, where the storms strike the ore. |
| **Tử Kim Khoáng** | 紫金礦 | Purple Gold Mine | 19 Kinh Trập Sơn | Thính Vũ Lâu | Purple-gold ore, the colour of storm light. |
| **Vũ Hoa Khoáng** | 雨花礦 | Rain Flower Mine | 19 Kinh Trập Sơn | Thính Vũ Lâu | Rain-flower pebbles, said to be flowers that fell as rain while a master preached; the richest ground of the sixteen (land density 1.87). In Thính Vũ's land of rain. |
| **Đan Thạch Khoáng** | 丹石礦 | Red Stone Mine | 20 Đan Huyệt Châu | Phượng Minh Cung | Red stone from the phoenix's cinnabar land, Đan Huyệt Châu. |

**Origins and home regions.** These cover the three origins the game already has (`assets/data/character_attributes.json`). The
fixed-world decision says each origin has a few home regions. A character starts knowing its home region, the main
roads and every city (Travel & Map rule 14).

| Origin | Home region | Starts | Choices |
|---|---|---|---|
| Đệ tử tông môn (sect disciple) | The region of the chosen sect's seat | At the seat, as an outer disciple | Any of the 29 sects, 7 great and 22 minor, which between them cover all 20 regions |
| Tán tu (loose cultivator) | A region with a cultivator market, where loose cultivators gather | At the market | 10 regions: 3 Thanh Loan Lĩnh (Lam Yên Thị), 4 Thâm Tùng Hải (Tùng Hạ Thị), 5 Cửu Khúc Xuyên (Đào Sa Thị), 9 Hàn Sương Châu (Tống Khách Thị), 10 Cô Vụ Đảo (Tương Phùng Thị), 12 Thu Thủy Loan (Vật Hoa Thị), 13 Ngư Ca Xuyên (Hạc Đinh Thị), 14 Thiên Tuyền Nguyên (Thiên Quyền Thị), 16 Thê Ngô Lĩnh (Thiều Âm Thị), 19 Kinh Trập Sơn (Hạnh Hoa Thị) |
| Con cháu gia tộc (clan heir) | The region of the clan's town | In the clan's town, with its field already growing | 7 clans, one in each great sect's land, below |

**The seven clans (gia tộc).** Households of cultivators living in a town under its sect. They are not powers (Sects
rule 1). Each sits in one of the most livable towns of its lord's land.

| Clan | Hán tự | Town | Region | Lord | Note |
|---|---|---|---|---|---|
| **Tạ gia** | 謝家 | Phong Lâm Trấn | 13 Ngư Ca Xuyên | Lạc Hà Tông | Lưu Vũ Tích: cựu thời Vương Tạ đường tiền yến, phi nhập tầm thường bách tính gia, the swallows of the old Vương and Tạ halls now nest in common homes. A great house fallen to a small clan, and the Vương clan's old rival. |
| **Vương gia** | 王家 | Đạo Hương Trấn | 17 Triêu Dương Nguyên | Phượng Minh Cung | The other house of the same line. Far from the Tạ now, in Phượng Minh's rice plain. |
| **Thẩm gia** | 沈家 | Bạch Sa Trấn | 2 Tuyết Hỏa Giác | Thúy Vi Tông | A coast clan of the white sands, on Thúy Vi's far west shore. |
| **Lục gia** | 陸家 | Phong Đăng Trấn | 19 Kinh Trập Sơn | Thính Vũ Lâu | A farming clan of good harvests under Thính Vũ's rain. |
| **Ôn gia** | 溫家 | Song Kiều Trấn | 15 Ngọc Hành Sơn | Thiên Xu Tông | A clan of the twin bridges on Thiên Xu's river road. |
| **Lâm gia** | 林家 | Lộc Minh Trấn | 4 Thâm Tùng Hải | Tùng Đào Cung | A clan of the deer-call forest under Tùng Đào's pines. |
| **Tiêu gia** | 蕭家 | Hòe Âm Trấn | 7 Ngọc Hồ Sơn | Băng Tâm Các | A clan in the locust shade of the cold north, under Lê Hoa Am. |

#27 may add origins (a demonic cultivator's apprentice, a mortal's child) and more clans.

## Open for the user

1. **Approve the mine names and the origins**, or swap any name, clan or home region.
2. **Next:** World Generation & History (#27) for the fixed world: the authored history, which names the hidden
   slots and fills in the wasteland's war, the ruin and the dead whose abodes these are. It is a GDD
   (`/design-system`), section by section with you.
3. **The map's art style**, from the style demos (prototypes, 2026-11-11), for the art bible.
4. The known rough spots above, by hand.

To change the places later:
- **Names:** swap any in `place_names.json`.
- **A city or a famous site:** move it by giving its name a new tile.
- **How many cities a sect has:** change `cities_by_sect`.

To change anything approved later:
- **A border:** change a sect's start tile or tier.
- **A minor seat:** add `"tile": [x, y]` or change its wants.
- **A minor sect's lord:** change its `lord` and `region`.
