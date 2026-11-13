# The Continent: candidate #11

**Chosen 2026-11-13** by the user from the 12 round-4 candidates (gallery: prototypes/continent-candidates). This is the
fixed world's starting point: it gets finished by hand, and every playthrough uses it (design/research/
fixed-world-decisions.md).

**Status:**
- **Layout:** v3. Sect territories are drawn first, then regions inside them.
- **Great sects and names:** a proposal, awaiting the user's approval.
- **Still to do:** region names, minor sects and places.

## Files

| File | What it is |
|---|---|
| `base/` | The continent as generated: seed 11, `tools/design/map/continent_gen.py` at commit 8db1e2b. It holds the index images (Travel & Map rule 1) and `meta.json`, with the legend and the map check. `detail.jpg` is the fine map drawn naturally, and `tiles.png` is the game grid. Hand edits go here from now on. |
| `sects_proposal.json` | Input, edited by hand. For each great sect: names, tier, element leanings, start tile and map colour. |
| `regions.png` | Region index, 540 × 360: the value is the region id, 0 is sea. |
| `regions.json` | For each region: its sect, size, shape, biome mix, height, climate, coast, rivers, lakes, volcanoes, hot springs, ore and ice tiles, and its neighbours with how natural each shared border is. Also the map check, including each territory's shape. |
| `regions_overview.jpg` | Region borders and numbers over the detail map. |
| `politics_proposal.json`, `politics_proposal.jpg` | Output: each sect's regions, seat tile, share of the land and shape, and the map with territories tinted. |

**Rebuild:**

```
python -I tools/design/map/regions.py --seed 11 --regions 20 --out design/map/continent-11 \
    --detail design/map/continent-11/base/detail.jpg --sects design/map/continent-11/sects_proposal.json
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

## The 20 regions

Working descriptions only. Names come later, in Hán-Việt.

| # | Sect | Working description | Tiles | Main land (share %) | Notes |
|---|---|---|---|---|---|
| 1 | Tùng Đào Cung | Long-lake north forest | 4,620 | Temperate forest 78, tundra 14 | The long lake (118 lake tiles); 1 °C mean |
| 2 | Thúy Vi Tông | North-west cape and volcanic isles | 4,729 | Temperate forest 71, tundra 17 | 4 volcanoes, 5 hot springs |
| 3 | Thúy Vi Tông | North-west hills | 5,169 | Temperate forest 68, high mountain 14, tundra 13 | 49 ore-vein tiles |
| 4 | Tùng Đào Cung | Inner north forest | 4,981 | Temperate forest 88, high mountain 8 | |
| 5 | Tùng Đào Cung | The great northern river basin | 4,362 | Temperate forest 85, tundra 7 | 213 river tiles |
| 6 | Thiên Xu Tông | Northern foothills of the central range | 4,573 | Temperate forest 60, high mountain 23 | Peaks to 4.7 km |
| 7 | Băng Tâm Các | North-east range and ice fields | 3,354 | Temperate forest 46, high mountain 33 | The only ice fields; the highest peak, 5.2 km |
| 8 | Băng Tâm Các | Eastern drylands | 3,452 | Steppe 44, desert 20, high mountain 15 | Driest region, 264 mm |
| 9 | Băng Tâm Các | North-east forest peninsula | 4,341 | Temperate forest 69, tundra 12 | 2 volcanoes |
| 10 | Lạc Hà Tông | South-west island | 4,099 | Grassland 53, bamboo 20, jungle 18 | The one large island |
| 11 | Lạc Hà Tông | West peninsula | 3,845 | Grassland 59, steppe 23 | Dry, 511 mm |
| 12 | Lạc Hà Tông | South-west steppe coast | 4,307 | Steppe 39, grassland 37, badlands 9 | 54 ore-vein tiles |
| 13 | Lạc Hà Tông | West-central river country | 2,928 | Temperate forest 36, grassland 25, steppe 20 | 169 river tiles |
| 14 | Thiên Xu Tông | The central basin | 5,082 | High mountain 27, steppe 26, highland 21 | Landlocked, 328 mm |
| 15 | Thiên Xu Tông | Central range by the inland sea | 4,110 | High mountain 46, steppe 20 | 235 ore-vein tiles |
| 16 | Phượng Minh Cung | Rain-forest range | 3,517 | High mountain 38, grassland 23, bamboo 16 | Wettest, 1,864 mm |
| 17 | Phượng Minh Cung | Grassland coast of the inland sea | 3,963 | Grassland 47, steppe 33 | 50 lake tiles |
| 18 | Thính Vũ Lâu | South jungle coast | 4,393 | Grassland 35, jungle 18, high mountain 12 | Peaks to 4.4 km |
| 19 | Thính Vũ Lâu | Southern peaks | 6,167 | High mountain 32, grassland 25, bamboo 18 | Richest ore (286 vein tiles); largest region |
| 20 | Phượng Minh Cung | South-east volcano coast | 3,433 | Grassland 41, jungle 35 | 3 volcanoes, 6 hot springs |

## Open for the user

1. Approve the territories and the sect names, or change any of them. To move a border, change a sect's start tile
   or tier, or name the regions you want swapped.
2. Names for the 20 regions (Hán-Việt).
3. Where the 15–25 minor sects sit.
4. Then the famous places (Travel & Map rule 6).
