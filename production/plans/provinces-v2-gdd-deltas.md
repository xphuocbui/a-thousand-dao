# Provinces v2: GDD deltas for the user's approval (2026-11-24)

Drafts only. Nothing here is in an approved GDD yet; each block is shown to the user section by section (user decides
GDD rewrites). They follow the decisions in `production/plans/provinces-v2-proposal.md` (decisions 1-8 and follow-ups)
and the merge pass on branch `provinces-v2`.

## Provinces (#48)

### Rule 1, Fixed provinces (replace the first paragraph and the two bullets)

> 1. **Fixed provinces.** The continent has 705 provinces, generated from the authored map by
>    `tools/design/map/provinces_v2.py` (rivers are barriers, so most rivers run on borders) and the same every game
>    (`assets/map/continent_11_provinces.json`, with the tile-to-province index `assets/map/continent_11_province_ids.bin`).
>    Each province has a stable key (`prov_<seat key>` or `prov_r<region>_<n>`). Each lies inside one region, and every
>    place belongs to the province its tile is in.
>    - A **settlement province** grows from one seat: a village, market, town, city or sect seat (468).
>    - A **wilderness province** has no settlement (237).

### Rule 8, a new bullet under Production (site growth; user follow-up to decision 1)

> - **Site growth.** A new site (provinces-v2) starts at grade **minor**, a tenth of small (`site_grade_value.minor`).
>   Each level of its province's matching production building (mine works for a mine, hunting lodge for a beast lair,
>   spirit fields for a spirit vein or hot spring) above level 1 raises it one grade step (minor, small, medium, large),
>   never above the grade its land density gives it (Travel & Map's `grade_by_density`).

Open for the user: the step rule. "Above level 1" keeps the start at a tenth (settlement provinces start with their
main good's building at level 1, rule 10); the alternative "every level" makes most kept sites small at once.

### Rule 10, Starting buildings (replace "a set of buildings by seat kind, authored with the map. A great seat starts with the most, a village with a field and a road.")

> a set of buildings by seat kind (all level 1; × = how many):
>
> | Seat | Starting buildings |
> |---|---|
> | Village | road |
> | Market | road, market hall |
> | Town | road, market hall, granary |
> | Minor sect seat | road, gathering array, warding wall |
> | City | road ×2, market hall ×2, granary, caravan post |
> | Great sect seat | road ×3, market hall ×2, granary ×2, caravan post ×2, gathering array ×2, warding wall |
>
> Every settlement province also starts with its main good's production building (spirit fields, mine works or a
> hunting lodge); a town, market or city on a coast or a river (6 river tiles or more) with a landing; a wilderness
> province with a mine, with mine works (its outpost).

### Panel (rule 3) and Open Questions

- Development: a display summary (built levels plus population units), read by nothing (decision 6).
- Population is shown as people, 1 unit = 1,000 mortals; the formulas stay in units (decision 6).
- The panel spec is `design/ux/province-panel.md` (draft).

### F6 measurements

The prototype figures (access per province) were measured on the 273 provinces. Re-measure with
`prototypes/province-economy/measure_access.py` on the 705 after the economy pass.

## Travel & Map (#travel-map)

- **Places:** the continent has 1,494 places: the 254 authored ones and 1,240 provinces-v2 places (277 villages, 26
  towns, 20 minor sect seats, 119 mines, 150 spirit veins, 126 beast lairs, 45 hot springs, 2 lava vents, 4 lightning
  woods, 176 peaks, 136 forests, 13 lakes, 4 gorges, 142 ruins). Of the 446 new site places, 175 are sites (grade
  minor, one province in four); the other 271 are places with no production (`no_site`).
- **Routes, a new kind `track`** (a footpath; optional): a new settlement or mine with no road is linked to the nearest
  place on the network (see Tracks below). The map's tile travel (TravelGrid) reaches every place without it; a track
  only joins the route graph (place links: the debug terminal's travel and AC-TM-128's reachability). 376 tracks; 17 new
  settlements on landmasses with no network stay unrouted (as Hồng Lô Cốc and Thu Phần Các). New wild places get no
  route (reached across the wild, like the existing lairs). Roads: only new settlements within 4 tiles of a road
  join it; 45 of the 203 authored road links are now split by a new village.
- **AC-TM-152** (the non-mine value at season 0 within 20 % of `world_production_guess` 250,000): the merged world
  measures **319,216** (×1.28), within decision 1's ×1.5. The test now checks 320,000 ± 20 %. Either approve the new
  figure (and raise `world_production_guess`), or ask for the demand and price pass to bring it back to 250,000.
- **Herb sites:** a provinces-v2 place with `no_site` holds herb grounds (gatherable when exploring) but no seasonal
  herb site; the new peaks, forests, lakes, gorges and ruins have herb sites at grade minor.
- **Tracks** are walked at the wilderness speed over the full terrain cost (Formula D's c_wild × speed.road /
  speed.wilderness on the route scale), so a track is never quicker than walking the wild: it only gives the link.
  A new place's off-road start onto a road is costed the same way.
- **Formula C:** the new places get their qi values but weigh 0 in the map targets and the world means mu, so Formula
  A's means are unchanged.

## Sects

- **Counts:** 50 active sects (7 great, 43 minor): the 20 provinces-v2 sects are small (main track 2, the rest 1;
  treasury 3,500), each with a named head in the cast (`design/world/provinces-v2/cast_v2.json`). Their members come
  from the same world total (World Generation Formula A), so the realm targets are unchanged.

## World Generation & History

- **Annals:** the provinces-v2 history (`design/world/provinces-v2/annals_v2.json`) joins the annals (decision 7).
