# The Continent: candidate #11

**Chosen 2026-11-13** by the user from the 12 round-4 candidates (gallery: prototypes/continent-candidates). This is the
fixed world's starting point: it gets finished by hand, and every playthrough uses it (design/research/
fixed-world-decisions.md).

**Status:**
- **Regions:** drafted.
- **Great sects:** a proposal, awaiting the user's approval.
- **Still to do:** names, minor sects and places.

## Files

| File | What it is |
|---|---|
| `base/` | The continent as generated: seed 11, `tools/design/map/continent_gen.py` at commit 8db1e2b. It holds the index images (Travel & Map rule 1) and `meta.json`, with the legend and the map check. `detail.jpg` is the fine map drawn naturally, and `tiles.png` is the game grid. Hand edits go here from now on. |
| `regions.png` | Region index, 540 × 360: the value is the region id, 0 is sea. |
| `regions.json` | For each region: size, biome mix, height, climate, coast, rivers, lakes, volcanoes, hot springs, ore and ice tiles, and its neighbours with how natural each shared border is. Also the map check. |
| `regions_overview.jpg` | Region borders and numbers over the detail map. |
| `sects_proposal.json` | The great-sect proposal: input data, edited by hand (names, territories, colours). |
| `politics_proposal.json`, `politics_proposal.jpg` | Output: each proposal sect's seat tile and share of the land, and the map with territories tinted. |

**Rebuild:**

```
python -I tools/design/map/regions.py --seed 11 --regions 20 --out design/map/continent-11 \
    --detail design/map/continent-11/base/detail.jpg --sects design/map/continent-11/sects_proposal.json
```

It takes about 50 seconds, and the same input gives the same output.

`design/map/.gdignore` keeps Godot from importing these design files.

## How the regions were drawn

Travel & Map rule 23 asks for about 20 regions that follow the terrain. The tool works in four steps:

1. **Seeds spread over the land.** Twenty seeds are spread out (one on the south-west island). Each is then moved to the middle of its region eight times.
2. **Each region grows from its seed along the cheapest path.** Travel gets dearer with:
   - height and relief;
   - crossing a river (more for bigger rivers);
   - crossing a watershed (more between bigger catchments).

   So a region spreads over open lowland and stops at crests, rivers and divides.
3. **Mild weights keep sizes in range.**
4. **Tidy-up.** Borders are smoothed and stray patches merged into the region they touch most.

**Map check**:

| Measure | Value |
|---|---|
| Regions | 20 (19 on the main landmass, 1 island) |
| Size | mean 4,271 tiles (about 2.6 million km²); range 0.65–1.75× the mean |
| Land borders on crests, highland, rivers or lakes | 46 % |
| … counting watershed divides too | 69 % |
| Region edges that are crest, river, lake or coast | 87 % |

Rule 23 says ranges, rivers and coasts make at least 60 % of region borders.
- **Counting coast:** 87 %, so it's met.
- **Land borders only:** 46 %, or 69 % if watershed divides count.
- **Why the land-only figure is low:** the far north is a wide, flat forest. There, the lines follow low divides between river basins.

**Known rough spots to fix by hand:**
- Short straight runs between 13 and 14 and between 10 and 11.
- Region 10 has no natural land border at all (its neck is open grassland).

## The 20 regions

Working descriptions only. Names come later, in Hán-Việt.

| # | Working description | Tiles | Main land | Notes |
|---|---|---|---|---|
| 1 | Far north-west cape | 2,822 | Temperate forest 57, tundra 36 | Cold, coastal, no rivers |
| 2 | Western north forest | 5,021 | Temperate forest 79, tundra 13 | −1 °C mean, the coldest |
| 3 | North-east peninsula and the northern range | 4,378 | Forest 54, tundra 19, high mountain 13 | The only ice fields (30 tiles), 2 volcanoes |
| 4 | North-west hills | 3,353 | Forest 73, high mountain 18, karst | 3 volcanoes, 49 ore-vein tiles |
| 5 | West-central forest | 2,771 | Forest 84, karst 7 | Smallest region |
| 6 | The great northern river basin | 6,429 | Forest 88 | 277 river tiles, most of the continent's big rivers |
| 7 | Long-lake forest | 4,787 | Forest 80, high mountain 12 | 118 lake tiles, peaks to 4.6 km |
| 8 | North-east range and forest | 5,006 | Forest 64, high mountain 13, tundra 10 | 58 ore-vein tiles, 2 volcanoes |
| 9 | South-west island | 4,099 | Grassland 53, bamboo 20, jungle 18 | The one large island |
| 10 | West peninsula | 4,359 | Grassland 54, steppe 27 | Dry (511 mm); no natural land border |
| 11 | West-central badlands | 5,445 | Steppe 27, forest 25, grassland 15, high mountain 14 | 81 ore-vein tiles, 201 river tiles |
| 12 | South-central uplands | 3,359 | High mountain 39, steppe 22, badlands 7 | Peaks to 4.4 km |
| 13 | The central basin | 4,525 | Steppe 30, high mountain 20, highland 17 | Landlocked, driest (284 mm), 98 ore-vein tiles |
| 14 | Central range by the inland sea | 2,999 | High mountain 37, steppe 24 | Peaks to 4.7 km; big river |
| 15 | Storm range | 3,315 | High mountain 46, grassland 24 | Wet (1,162 mm), 127 ore-vein tiles |
| 16 | Eastern drylands | 7,462 | Steppe 36, grassland 29, high mountain 18, desert 9 | Largest region; highest peak (5.2 km) |
| 17 | South-west jungle coast | 5,528 | Grassland 50, jungle 15, steppe 13 | 24 °C, 999 mm |
| 18 | Southern peaks | 3,601 | High mountain 29, grassland 28, jungle 20 | Richest ore (282 vein tiles) |
| 19 | Rain-forest range | 3,043 | High mountain 32, bamboo 28 | Wettest (1,907 mm) |
| 20 | South-east volcano coast | 3,123 | Jungle 38, grassland 38 | 4 volcanoes, 6 hot springs, the longest coast |

## Great sects: proposal v2 (awaiting approval)

Sects are the only powers. There are no mortal kingdoms (Travel & Map rule 24, confirmed by the user 2026-11-13) and no
wild regions: every region belongs to a great sect (user decision 2026-11-14). Wilderness, the land away from roads
and towns, still lies inside each territory.

There are **7 great sects** in 2 tiers. The 15–25 minor sects come later and sit inside these territories.

**Names** are Hán-Việt and lean romantic and poetic (user request 2026-11-14), with the English meaning alongside.
- **Suffixes vary:** tông (sect), cung (palace), các (pavilion), lâu (tower). A palace or tower name sounds just as
  grand as a sect name.
- **Not taken from known novels:** none are the well-known sect names of existing xianxia or wuxia novels.

| Sect | Hán tự | Meaning | Tier | Leans | Regions (seat first) | Land |
|---|---|---|---|---|---|---|
| **Thiên Xu Tông** | 天樞宗 | Sect of the Heavenly Pivot. Thiên Xu is the first star of the Northern Dipper, the pivot the sky turns on: the sect at the crossroads of the continent. | 1 | Metal, Earth | 14, 13, 11 | 15.2 % |
| **Tùng Đào Cung** | 松濤宮 | Palace of the Pine Waves: wind in endless pine forest that sounds like surf. | 1 | Wood, Water | 6, 7, 2 | 19.0 % |
| **Lạc Hà Tông** | 落霞宗 | Sect of the Drifting Sunset Clouds, after Vương Bột's line *lạc hà dữ cô vụ tề phi*: "sunset clouds fly with a lone wild duck". | 1 | Metal, Wood, Fire | 18, 12, 17, 9 | 19.4 % |
| **Thính Vũ Lâu** | 聽雨樓 | Tower Where One Listens to the Rain: on the wettest mountains, where storms roll in from the sea. | 2 | Metal, Water, Thunder | 15, 19 | 7.4 % |
| **Băng Tâm Các** | 冰心閣 | Pavilion of the Ice Heart, after Vương Xương Linh's *nhất phiến băng tâm tại ngọc hồ*: "a heart of ice in a jade vessel", meaning purity. | 2 | Water, Ice | 3, 8 | 11.0 % |
| **Thúy Vi Tông** | 翠微宗 | Sect of the Emerald Haze: the blue-green mist on distant hills. | 2 | Earth, Wood | 4, 5, 1, 10 | 15.6 % |
| **Phượng Minh Cung** | 鳳鳴宮 | Palace of the Phoenix's Call: the fire bird of the south, on the volcano coast and the red drylands. | 2 | Fire, Wood | 20, 16 | 12.4 % |

**Where the five former wild regions went:**

| Region | Now held by | Why |
|---|---|---|
| 1, far north-west cape | Thúy Vi Tông | It borders the sect's seat region. |
| 10, west peninsula | Thúy Vi Tông | Reached through the north-west hills. It is dry grassland, and its open neck is the sect's weak border. |
| 11, west-central badlands | Thiên Xu Tông | Ore-rich. It touches all three tier-1 sects, so it is still the most contested region. |
| 16, eastern drylands | Phượng Minh Cung | Desert's signature element is Fire. It makes the small volcano sect a real power. |
| 9, south-west island | Lạc Hà Tông | Across the strait from its jungle coast (17). |

**Why these numbers:**
- **Tier 1 has 3 sects** to match the ~3 Hóa Thần (difficulty targets): each would have one at its head. The tier-1
  sects hold 54 % of the land.
- **The ~27 Nguyên Anh** leave each great sect 2–3, and the rest are loose or demonic cultivators.

**Seats** are picked by the tool for now: high ground well inside the seat region. Each seat's tile is in
`politics_proposal.json`. Hand-placed sacred summits or spirit veins (rules R27 and R29) can move them.

**Open for the user:**
1. Approve the territories and the names, or swap any of them.
2. Names for the 20 regions (Hán-Việt).
3. Where the 15–25 minor sects sit.
4. Then the famous places (Travel & Map rule 6).
