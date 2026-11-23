# Provinces v2: proposal and decisions (branch `provinces-v2`, 2026-11-23 night)

Written unattended for the user's morning review. Nothing here changes the approved GDDs: the Provinces GDD (#48) and
Regional Economy & Trade (#43) stay as approved, and this file lists the changes they would need.

## What the user asked

1. "Smaller provinces, and province shapes that follow rivers and ridges. And for each province, we should add cities,
   sects, mines, ruin, some sort of special location ... Also add new lore so the world feels more lively and please
   make sure that the place fits the province, place, sects, country, lore ... make sure each province has production,
   development, works, population stats."
2. "Design a panel for provinces, learn from eu4 or eu5 ... use the unique place catalogue images."
3. Then keep improving the map until morning.

## What is built (all on the branch, committed there; nothing pushed, nothing on main)

| Part | Where | Result |
|---|---|---|
| Shapes | `tools/design/map/provinces_v2.py`, `design/map/continent-11/provinces-v2/`, `assets/map/continent_11_provinces.json`, `continent_11_province_ids.bin` | 273 → **705** provinces (median 253 → 107 tiles); drawn river tiles on a province border 13 % → 48 % (`province_metrics.py`); stable keys |
| Places | `tools/design/map/places_v2.py`, `design/world/provinces-v2/slots.json` | **1,245** new place slots from the land |
| Lore | `design/world/provinces-v2/lore/region_*.json`, checked by `places_v2_check.py` | names (Hán-Việt + 漢字 + gloss) and lore for every province and new place, written per great sect's territory |
| Stats | `tools/design/map/province_stats_v2.py` → `assets/data/world_provinces.json` | population, capacity, production by good, main and secondary goods, buildings, slots, infrastructure, usage, access, development, per province |
| Panel | `src/ui/windows/province_panel.gd`, `design/ux/province-panel.md` (draft) | EU4/EU5-style; click open land; tests in `tests/unit/ui/ui_province_panel_test.gd` |

## Also built during the night (the loop on the map)

- **Province names** on the map at mid zoom, a **province hover**, and **the new places drawn at close zoom** with
  their own hover.
- **Development and Goods map modes**, and a **map picture for every province** in the panel.
- **The lore is complete and checked:** `places_v2_check.py` reports 0 errors and 1 warning. Across the regions, 104
  names used twice were renamed by the writers, and 8 by hand. A land-fit audit, `places_v2_fit.py`, flagged 11
  entries; all were read and are fine (for example, a net-maker that sells to lake fishers).
- **The authored isles stay unsettled.** The new villages planned on Phù Chử, Tịch Chiếu, Đồ Nam, Dục Nhật and the
  isle near them were removed, and their provinces rewritten as unsettled isles. The hermit Mạc Quy Khư stays on Dục
  Nhật Đảo, as canon has him.

## Notes from the writers worth a look

- A few new peaks stand higher than the peak canon calls the highest of its range: r15_1 at 4.60 km, r15_2 at 4.52 km
  and r6_26 at 4.59 km. They are written as shoulders of the massif, with no "highest" claim. Some lake slots sit
  beside canon lakes and are written as separate small lakes.
- **Biggest new history facts** (all before 1200, none contradicting the annals as far as the writers checked):
  - an eruption in 352 that buried Hạ Lôi Thành near the Tower;
  - more Thôn Hải raids between 744 and 779;
  - several new disasters (1012, 1019, 1033, 1102, 1148, 1151);
  - ruins tied to the Desert Road War, the Frost Coast war and Cửu Thiều's fall.

  The full list is gathered in `design/world/provinces-v2/new_history_facts.md`.

## Decisions for the user (most important first)

1. **The economy cannot take the new sites as they are.** At the same output as existing sites of their kind, the
   new places add about **3.9 times** the world's current place output (existing 267,517 a season; new 1,053,919), so the
   world would make 4.9 times what it makes now. Nearly
   all of it is the 440 new economic sites: 119 mines, 150 spirit veins, 126 beast lairs and 45 hot springs, each near
   2,000 a season. The economy is calibrated to the current world. Options:
   - (a) **Most new specials are flavour places with no site:** peaks, forests, lakes, gorges and ruins, plus only one
     in four provinces getting an economic site. This is the recommended option.
   - (b) New sites start small and grow (a new "minor" site grade, about a tenth of today's small).
   - (c) Keep them all and re-balance demand, prices and the census around a richer world.

   Measured with each kind's median output from the seed-7 dump:

   | Option | New output a season | World place output |
   |---|---|---|
   | As planned (all sites at full) | +1,053,919 | ×4.94 |
   | (a) one in four sites kept | +323,200 | ×2.21 |
   | (b) all sites at a tenth | +194,878 | ×1.73 |
   | (a) and (b) together | +121,806 | ×1.46 |
   | No new sites at all (villages, peaks, ruins, forests only) | +99,428 | ×1.37 |

   So even the smallest merge raises the world's output by about a third, mostly from the new villages; any merge
   needs a demand and price pass. Until decided, the stats compute the sites at full output, which is why about half
   the settlement provinces start at the 0.5 access floor.
2. **705 provinces instead of 273.** This changes the Provinces GDD rule 1 (count; 141/132 split → 468 settlement after the new villages, 237 wilderness) and the
   prototype measurements in F6. The economy reads provinces only on paper so far, so no code breaks (survey: no system in
   `src/gameplay` reads provinces).
3. **New places are a proposal file, not yet world data.** `world_continent.json` still has 254 places. Merging the
   1,240 into it would change world generation, travel, discovery and tests (`continent_data_test.gd` asserts 254 places,
   23 minor sects, 181 settled). Recommended: merge after decision 1, in one pass with the census and the parallel suite.
4. **20 proposed minor sects** (one per region), each with key, alignment, leans, craft and founding year in its
   region's lore file. Sects rule and world generation count sects (30 active today), so they stay proposals.
5. **Starting buildings by seat kind** (rule 10 says "authored with the map"; the draft sets: a village gets a road; a
   great seat gets three roads, two market halls, two granaries, two caravan posts, two gathering arrays and a warding
   wall; plus the main good's production building). Are these right?
6. **Development** as a display index (built levels plus population units), and **population units** shown as the
   GDD's settlement units: keep both, or show people (1 unit = 1,000 mortals?).
7. **New history:** the writers added small facts (new ruins with dates and causes, a few disasters, one more Thôn Hải
   raid in 744). The writers' reports list them, and none contradicts the annals as far as they checked. Worth a read
   before merging into `world_history.json`. The new facts are only in the lore files for now.

## GDD deltas this would need (not applied)

- **Provinces rule 1:** 273 → 705; the generator `provinces_v2.py` (rivers and ridges as barriers, stable keys); the tile
  index ships as `assets/map/continent_11_province_ids.bin`.
- **Provinces rule 3 / UI:** the panel spec `design/ux/province-panel.md`.
- **Provinces rule 10:** the starting-building table.
- **Travel & Map:** the new place kinds and counts, once merged.
- **Regional Economy & Trade:** re-measure F6's access figures, `measure_access.py`, with the new shapes.

## Still owed

- Gamepad and keyboard opening of the province panel.
- A province map mode.
- The local price line.
- The panel's picture for provinces with no painted place is a crop of the painted map. A painted scene per province
  would need image generation, which needs the user's go.
