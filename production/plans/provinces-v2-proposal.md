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

## Decisions for the user (most important first)

1. **The economy cannot take the new sites as they are.** At the same output as existing sites of their kind, the
   new places add about **3.9 times** the world's current place output (existing 267,517 a season; new 1,054,462). Nearly
   all of it is the 440 new economic sites: 119 mines, 150 spirit veins, 126 beast lairs and 45 hot springs, each near
   2,000 a season. The economy is calibrated to the current world. Options:
   - (a) **Most new specials are flavour places with no site:** peaks, forests, lakes, gorges and ruins, plus only one
     in four provinces getting an economic site. This is the recommended option.
   - (b) New sites start small and grow (a new "minor" site grade, about a tenth of today's small).
   - (c) Keep them all and re-balance demand, prices and the census around a richer world.
   Until decided, the stats compute them at full output. That is why about half the settlement provinces start at the
   0.5 access floor.
2. **705 provinces instead of 273.** This changes the Provinces GDD rule 1 (count; 141/132 split → 473 settlement after the new villages, 232 wilderness) and the
   prototype measurements in F6. The economy reads provinces only on paper so far, so no code breaks (survey: no system in
   `src/gameplay` reads provinces).
3. **New places are a proposal file, not yet world data.** `world_continent.json` still has 254 places. Merging the
   1,245 into it would change world generation, travel, discovery and tests (`continent_data_test.gd` asserts 254 places,
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
- The panel's art fallback for provinces with no painted place: today the panel shows no picture. A painted landscape
  per province would need image generation, which needs the user's go.
