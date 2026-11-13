# The Continent: candidate #11

**Chosen 2026-11-13** by the user from the 12 round-4 candidates (gallery: prototypes/continent-candidates). This is the
fixed world's starting point: it gets finished by hand, and every playthrough uses it (design/research/
fixed-world-decisions.md).

**Status:**
- **Layout:** v3. Sect territories are drawn first, then regions inside them.
- **Great sects and names:** a proposal, awaiting the user's approval.
- **Region names:** a proposal, awaiting the user's approval.
- **Still to do:** minor sects and places.

## Files

| File | What it is |
|---|---|
| `base/` | The continent as generated: seed 11, `tools/design/map/continent_gen.py` at commit 8db1e2b. It holds the index images (Travel & Map rule 1) and `meta.json`, with the legend and the map check. `detail.jpg` is the fine map drawn naturally, and `tiles.png` is the game grid. Hand edits go here from now on. |
| `sects_proposal.json` | Input, edited by hand. For each great sect: names, tier, element leanings, start tile and map colour. |
| `regions.png` | Region index, 540 × 360: the value is the region id, 0 is sea. |
| `regions.json` | For each region: its sect, size, shape, biome mix, height, climate, coast, rivers, lakes, volcanoes, hot springs, ore and ice tiles, and its neighbours with how natural each shared border is. Also the map check, including each territory's shape. |
| `region_names.json` | Input, edited by hand: each region's Hán-Việt name, Hán tự, meaning and the image behind it. |
| `regions_overview.jpg` | Region borders and numbers over the detail map. |
| `politics_proposal.json`, `politics_proposal.jpg` | Output: each sect's regions, seat tile, share of the land and shape, and the map with territories tinted. |

**Rebuild:**

```
python -I tools/design/map/regions.py --seed 11 --regions 20 --out design/map/continent-11 \
    --detail design/map/continent-11/base/detail.jpg --sects design/map/continent-11/sects_proposal.json \
    --names design/map/continent-11/region_names.json
```

It takes about 2 minutes, and the same input gives the same output.

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

## Great sects: proposal v3 (awaiting approval)

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

## The 20 regions (names: proposal, awaiting approval)

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

## Open for the user

1. Approve the territories and the sect names, or change any of them. To move a border, change a sect's start tile
   or tier, or name the regions you want swapped.
2. Approve the region names, or swap any of them.
3. Where the 15–25 minor sects sit.
4. Then the famous places (Travel & Map rule 6).
