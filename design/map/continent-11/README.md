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
| `sects_proposal.json` | The great-sect proposal: input data, edited by hand. |
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

## Great sects: proposal (awaiting approval)

Sects are the only powers. There are no mortal kingdoms (Travel & Map rule 24; the user confirmed this on 2026-11-13).

The proposal has **7 great sects** in 2 tiers, plus **5 wild regions**. The 15–25 minor sects are placed in a later step.

| Sect (working name) | Tier | Leans | Regions (seat first) | Land share | Why here |
|---|---|---|---|---|---|
| Central Range sect | 1 | Metal, Earth | 14, 13 | 8.8 % | It holds the crossroads between north, south and east. Both its regions are rich in ore. Its land is small, but every route crosses it. |
| Northern Forest sect | 1 | Wood, Water | 6, 7 | 13.1 % | The great river basin and the long lake: the purest Wood land, with the most rivers. |
| Southern Peaks sect | 1 | Metal, Wood, Fire | 18, 12, 17 | 14.6 % | The richest ore on the continent, with jungle and a warm coast behind it. |
| Storm Range sect | 2 | Metal, Water, Thunder | 15, 19 | 7.4 % | The wettest high mountains: the natural home for authored storm peaks. |
| North-east Ice sect | 2 | Water, Ice | 3, 8 | 11.0 % | The only ice fields, and a northern range with ore. |
| Western Hills sect | 2 | Earth, Wood | 4, 5, 2 | 13.0 % | Karst, volcanoes and ore in the hills, with cold forest behind. |
| Volcano Coast sect | 2 | Fire, Wood | 20 | 3.7 % | The most volcanoes and hot springs. Small, but the purest Fire ground. |
| **Wild** | — | — | 1, 9, 10, 11, 16 | 28.3 % | See below |

**Why these numbers:**
- **Tier 1 has 3 sects** to match the ~3 Hóa Thần (difficulty targets): each tier-1 sect would have one at its head.
- **The ~27 Nguyên Anh** leave each great sect 2–3, and the rest are loose or demonic cultivators.

**Why each wild region stays wild:**
- **1, far north-west cape:** cold and poor.
- **9, south-west island:** cut off by sea, a place for hidden sects and secret realms.
- **10, west peninsula:** no natural border to hold.
- **11, west-central badlands:** ore-rich and sitting between all three tier-1 sects, so it is contested ground and a natural flashpoint.
- **16, eastern drylands:** the largest and highest region, far from every seat.

**Seats** are picked by the tool for now: high ground well inside the seat region. Each seat's tile is in `politics_proposal.json`. Hand-placed sacred summits or spirit veins (rules R27 and R29) can move them.

**Open for the user:**
1. Approve, move or change the sects and their regions.
2. Names for the regions and sects.
3. Where the 15–25 minor sects sit.
4. Then the famous places (Travel & Map rule 6).
