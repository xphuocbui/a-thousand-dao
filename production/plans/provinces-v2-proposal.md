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
| Ridges | (same generator) | **Not achieved.** Ridge crest tiles on a province border: 16.9 % (old) → 25.6 % (new), but any land tile is on a border 12.5 % → 23.2 % of the time, so a crest is 1.35× as likely as chance in the old cut and only 1.1× in the new. Rivers are 2.05×. See decision 8 |
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

1. **DECIDED (user, 2026-11-24): (a) and (b) together.** About one province in four keeps a real economic site, and
   the kept sites start at a tenth of today's small grade and grow; the rest are places with no site. World place
   output ×1.46; a demand and price pass follows the merge.
   **Follow-ups (user, 2026-11-24):** read as one province in four (~176 sites, about ×1.51), not one site in four
   (~110, the table's ×1.46). The kept sites **grow through buildings**: each level of the province's matching building
   (mine works, hunting lodge, spirit fields) raises the site a step (a Provinces GDD delta, for the user's approval).
   **Roads:** only new settlements join the road network; new wild places stay off it, reached across the wild.
   **Claude's choices in the merge (for review):**
   - Inside each region's quarter, provinces whose site lore has it worked are kept first, so the kept mix is 81 mines,
     42 beast lairs, 37 spirit veins, 13 hot springs, 1 lava vent and 1 lightning wood.
   - A no_site place gets no herb site either. The new peaks, forests, lakes, gorges and ruins keep herb sites, at
     grade minor.
   - Holders follow Provinces rule 2: a sect seated in the province is its local lord, else the nearest authored lord.

   **The economy cannot take the new sites as they are.** At the same output as existing sites of their kind, the
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
2. **DECIDED (user, 2026-11-24): keep 705.** **705 provinces instead of 273.** This changes the Provinces GDD rule 1 (count; 141/132 split → 468 settlement after the new villages, 237 wilderness) and the
   prototype measurements in F6. The economy reads provinces only on paper so far, so no code breaks (survey: no system in
   `src/gameplay` reads provinces).
3. **DECIDED (user, 2026-11-24): merge now, on the branch,** in one pass with the decision-1 site rule, the tests,
   the census and the demand and price pass; the user reviews before main. **New places are a proposal file, not yet world data.** `world_continent.json` still has 254 places. Merging the
   1,240 into it would change world generation, travel, discovery and tests (`continent_data_test.gd` asserts 254 places,
   23 minor sects, 181 settled). Recommended: merge after decision 1, in one pass with the census and the parallel suite.
4. **DECIDED (user, 2026-11-24): add all 20 as small real sects,** their members taken from the existing
   5,000-cultivator total (world size and difficulty targets unchanged). **20 proposed minor sects** (one per region), each with key, alignment, leans, craft and founding year in its
   region's lore file. Sects rule and world generation count sects (30 active today), so they stay proposals.
5. **DECIDED (user, 2026-11-24): accept as drafted** (START_BUILDINGS in `province_stats_v2.py`, plus the main
   good's building and a landing); goes into Provinces rule 10, shown to the user first. **Starting buildings by seat kind** (rule 10 says "authored with the map"; the draft sets: a village gets a road; a
   great seat gets three roads, two market halls, two granaries, two caravan posts, two gathering arrays and a warding
   wall; plus the main good's production building). Are these right?
6. **DECIDED (user, 2026-11-24): development stays a display summary** (nothing reads it); **population is shown
   as people, 1 unit = 1,000 mortals** (display only; the game computes in units). **Development** as a display index (built levels plus population units), and **population units** shown as the
   GDD's settlement units: keep both, or show people (1 unit = 1,000 mortals?).
7. **DECIDED (user, 2026-11-24): add all** to `world_history.json` in the merge pass. **New history:** the writers added small facts (new ruins with dates and causes, a few disasters, one more Thôn Hải
   raid in 744). The writers' reports list them, and none contradicts the annals as far as they checked. Worth a read
   before merging into `world_history.json`. The new facts are only in the lore files for now.

8. **DECIDED (user, 2026-11-24): keep as is.** No re-cut; ridges stay a known gap. **Ridges.** Borders now follow rivers (a river tile is twice as likely as chance to be on a border), but not ridges
   (1.1×, against 1.35× in the old cut). Costly climbing makes a mountain range its own province with borders at its
   feet, and crossing a crest must cost the same both ways for a border to sit on it. Tried on the same seeds
   (`FINAL_UP` / `FINAL_DOWN` in `provinces_v2.py`):

   | Final growth | Crests on a border | Rivers on a border | Provinces |
   |---|---|---|---|
   | as built (up 0.012, down 0.002) | 25.6 % | 47.6 % | 705 |
   | up 0.03 | 24.3 % | 47.4 % | 699 |
   | up 0.06 | 22.3 % | 48.3 % | 686 |
   | up = down = 0.012 | 27.8 % | 45.7 % | 713 |
   | up = down = 0.025 | 28.9 % | 43.9 % | 701 |

   The equal-cost runs help a little (about 1.25× chance), but they change the province count. The new places and
   lore are keyed to the provinces as built, so a re-cut means re-planning the slots (the lore for settlement
   provinces survives through their keys). Recommended: decide whether ridges matter enough for a re-cut. If yes,
   re-cut once with equal costs, then re-plan, and the writers re-fit only the wilderness provinces that changed.

## GDD deltas this would need (not applied)

- **Provinces rule 1:** 273 → 705; the generator `provinces_v2.py` (rivers and ridges as barriers, stable keys); the tile
  index ships as `assets/map/continent_11_province_ids.bin`.
- **Provinces rule 3 / UI:** the panel spec `design/ux/province-panel.md`.
- **Provinces rule 10:** the starting-building table.
- **Travel & Map:** the new place kinds and counts, once merged.
- **Regional Economy & Trade:** re-measure F6's access figures, `measure_access.py`, with the new shapes.

## The merge (2026-11-24, decision 3)

Done on the branch, at the source, so a re-export keeps it:

- **World data:**
  - `places_v2_merge.py` writes `design/map/continent-11/provinces_v2_places.json`. `export_continent.py` appends it
    after every earlier layer: 1,494 places (ids 255+; the 254 authored records are byte-identical) and 43 minor sects.
  - `export_world.py` reads `sect_start_v2.json`, `cast_v2.json` (20 heads) and `annals_v2.json` (172 annals): 50
    sects, 74 living cast members, 688 events.
- **Sites:**
  - 175 kept (one province in four, worked lore first) at grade minor (`map_resources.json` `site_grade_value.minor`
    250); 271 with `no_site`.
  - 17 unkept site lores were re-fitted as not worked today (applied by Claude from a writer's draft). Thiết Tú Trì was
    left as it is, because its kept neighbour mine has miners.
- **Routes:**
  - New settlements within 4 tiles of a road join it.
  - Every other new settlement or mine gets a **track**, a footpath walked at the wilderness speed (a new route kind): 376
    tracks.
  - 17 new settlements are on landmasses with no network.
- **Formula C:** the new places weigh 0 in Formula C's targets and mu, so the world means are unchanged.
- **Map UI:**
  - The separate new-places layer is gone: the new places are ordinary known places now.
  - The panel shows population as people.

**Measured** (`production/qa/evidence/provinces-v2-merge/`, the baseline against the merged world, same seeds; after the
herb-site and track fixes):

| | Baseline | Merged |
|---|---|---|
| **World place output a season (decision 1's measure; seed-7 dump)** | 267,517 | **319,216 (×1.19)**: new places 36,412, authored places +15,287 (new settlements near them raise their worked share) |
| Linh thạch mined at season 0 (seed-7 dump) | 124,560 | 170,739: authored spirit veins +31,680 (the same neighbour effect), new veins +14,499 |
| Non-mine production at season 0 (AC-TM-152 guess 250,000) | in band | 319,216 (×1.28) |
| Census, year 200, seed 101 (Luyện Khí / Trúc Cơ / Kết Đan / Nguyên Anh / Hóa Thần) | 3901 / 808 / 242 / 45 / 4 | 3770 / 933 / 258 / 33 / 6 |
| Census, year 200, seed 7 | 3856 / 844 / 259 / 37 / 4 | 3806 / 885 / 269 / 36 / 4 |
| Census, year 200, seed 202 | (not run) | 3784 / 911 / 258 / 43 / 4 |
| **Sect wars over the century, declared / won (sim seed 11)** | 16 / 13 | **50 / 48** |
| Thiên Xu Tông's vassals in 1300 | 4 | **34** |
| Mines minted a season, first decade (sim seed 11) | 139,421 | 201,324 (+44 %) |
| The same, year 1300 | 148,540 | 162,010 (+9 %) |
| Money growth, first decade (band −2 % to +5 %) | +2.6 % a year | +4.1 % a year |
| Money in the world, 1300 | 5.25 M | 5.60 M |
| World mean prices, 1300 (herb / ore / beast / special / pill) | 1.16 / 1.48 / 1.19 / 1.95 / 1.81 | 1.12 / 1.39 / 1.20 / 1.84 / 1.78 |
| Minor sects, start → 1300 | 23 → 30 | 43 → 57 |
| Minor sects restless at the start | 7 of 23 | 17 of 43 |

Notes:

- **The early mint:**
  - It comes mostly from the **authored** spirit veins: a new village or town within `settle_reach` raises their
    `settle_w`.
  - The new minor veins add little (180 a season each).
  - The reserves then settle near the old world, and money growth stays inside the band.
- **Sect politics (the largest change):**
  - The 20 small new sects (levels 1–2) are easy war targets: three times the wars, and a Thiên Xu snowball to 34
    vassals in one seed.
  - This needs the user's call: stronger starting levels, protection (for example, a truce while under the lord's
    shield), fewer new sects, or accept it. Check more seeds first.
- **Prices:** the merged world's prices are as close to the band as the baseline's or closer. The drift outside 0.9–1.15
  (ore, special, pill) is in the baseline too.
- **The census:** Trúc Cơ runs 5–15 % above the baseline at year 200 on every seed. Nguyên Anh (33–43) and Hóa Thần
  (3–6, against a target of about 3) move by a few between seeds, as the baseline does.
- **New sects:** twice as many new sects are founded over the century (14 against 7), on the many new peaks and places.
- **The demand and price pass:**
  - Recommended scope: the neighbour effect, for example new settlements not raising the `settle_w` of authored sites,
    or the authored veins' grade; not the minor sites.
  - It is not run yet: it is the user's call.
- **Restless sects:** 10 of the new sects are trung lập under a chính đạo lord, at loyalty 55 by sect_start's rule.

## Before pushing this branch

**DONE (2026-11-24, user: "convert them to LFS").** The branch's 23 commits were rewritten with git plumbing so the 23
screenshots in `production/qa/evidence/province-panel/` and the 5 previews in `design/map/continent-11/provinces-v2/`
are LFS pointers, and every rewritten commit's `.gitattributes` carries both rules. The branch's own blobs went from
about 131 MB to 23 MB; `git lfs fsck` is OK; trees are unchanged otherwise. The old head is kept as
`provinces-v2-pre-lfs` (1304e65f). The trial folders are still on disk: deleting them was blocked by permissions, so
the user deletes them.

Before (kept for the record):

- **About 87 MB of screenshots in `production/qa/evidence/province-panel/` went into the branch history as plain PNG
  files, not LFS.** The LFS rule for that folder was only added at the end, so new ones go to LFS. Two tries with `git
  lfs migrate import` (`--include-ref=refs/heads/provinces-v2 --exclude-ref=refs/heads/main`) exited 0 but rewrote
  nothing, while `git lfs migrate info` with the same refs and `--include="production/qa/evidence/province-panel/**"`
  does list the 23 files. Convert them, or drop or shrink the screenshots, before the first push.
- **Untracked trial folders** `design/map/continent-11/provinces-v2-up*` and `-sym*` (the ridge trials) are not
  committed; delete them or keep them for comparison.

## Still owed

- Gamepad and keyboard opening of the province panel.
- A province map mode.
- The local price line.
- The panel's picture for provinces with no painted place is a crop of the painted map. A painted scene per province
  would need image generation, which needs the user's go.
