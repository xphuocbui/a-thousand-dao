# ADR-0008: Provinces as World Records and the Economy's Unit

## Status
Accepted (the user's decisions D1, D3, D4, D5, D6 and D7, 2026-11-24, and the same day's building decisions: one
catalogue, three added kinds, prices instead of caps, prebuilt density as land; the user approved writing this ADR).

## Date
2026-11-24

## Last Verified
2026-11-24 (Godot 4.7.1; read against `world_ticker.gd`, `game_session.gd` `load_dict`, `map_works.gd`, `sect_works.gd`,
`map_production.gd`, `assets/data/world_provinces.json`)

## Decision Makers
The user (D1, D3, D4, D5, D6, D7 in `production/plans/provinces-runtime.md`, and the building decisions, 2026-11-24),
with the assistant drafting.

## Summary
Provinces become live world records: a `provinces` table in WorldDB and in saves, every place linked to one province, and
a province step in the world tick that publishes the production contract per province. The economy keeps reading the
region contract until a shadow period proves the two agree, then switches. Province buildings replace layer-2 works as
the one catalogue of shared works; saves made before provinces are refused.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (installed 4.7.1) |
| **Domain** | Core simulation (world tick), Persistence (saves) |
| **Layer** | Gameplay / World |
| **Knowledge Risk** | LOW: plain `Dictionary` records in the existing WorldDB and `JSON` saves; no post-cutoff API |
| **Post-Cutoff APIs Used** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002 (random streams: any province roll keys on seed, province id and season); ADR-0006 (GameSession facade: the panel reads provinces through `GameQuery`, never the table directly) |
| **Enables** | Provinces plan Stages 2-9: building catalogue and states, site growth, sect building, population, access and the economy switch |

## Context

### Problem Statement
The approved Provinces GDD (and Regional Economy & Trade revision #43) make the province the economy's unit, the holder
of buildings and population, and the source of access. In the running game provinces are a one-off bake that nothing
updates, the economy reads per-region totals with access by distance, and shared works live on places.

### Current State
- `assets/data/world_provinces.json`: 705 provinces (468 settlement, 237 wilderness) listing 1,489 of the 1,494 places;
  stats baked once by `tools/design/map/province_stats_v2.py` (seed 7). Shown by `ProvinceWindow` / `GameQuery.province`.
- The 5 places in no province are the lakes 190-194 (Hạo Nguyệt, Phiến Băng, Tinh Lạc, Triêu Hà, Tàn Hà Hồ); lakes can
  hold herb grounds, so their output would fall outside every province.
- Tick (`WorldTicker.tick`): `MapProduction.season` → `WorldEconomy.season` → `WorldMoney.season` (sect works upkeep and
  building, `SectWorks`) → `SectPolitics.season` → `MapChange.season`.
- Layer-2 works on `place.qi.layer2` and `place.qi.prebuilt` (`MapWorks`, `SectWorks`).
- `GameSession.load_dict` refuses a save whose `map_version` differs (the hash of the grid and qi files).

### Constraints
- The cultivation census (seeds 7, 101, 202) and `world_sim` (seeds 11-13) baselines in
  `production/qa/evidence/provinces-v2-merge/` must not move in the shadow stage.
- A season costs about 459 ms; the province step's budget is measured in Stage 1 (D8).
- `game_query.gd` and `map_screen.gd` are shared with the UI-windows session.

### Requirements
- One live copy of Provinces F1, F2, F4, F5 (later F3, F6) in GDScript, knobs in data.
- No double counting of a site's gain between buildings and works (Provinces OQ 9).
- Deterministic: same seed, same provinces.

## Decision

1. **Data split.** `world_provinces.json` keeps the static shape (id, key, region, kind, seat, tiles, land shares, river,
   road and coast facts, place list, names and lore). Start stats are no longer read from it; knobs go to
   `assets/data/provinces.json`.
2. **The table.** WorldBuilder builds a `provinces` table in WorldDB from the shape: `{id, key, region, kind, seat_place,
   places, potential, main_good, secondary_goods, population, production, slots, buildings: [], modifiers: [],
   access}`. It is saved and loaded with the rest of WorldDB.
3. **Place link.** Every place record gets `province_id`. A lake (or any place a later map leaves outside) takes the
   province of its nearest land tile, lowest province id on a tie, fixed at world generation.
4. **Tick (D1: one-season lag).** `Provinces.season(gd, db, year, season)` runs after `MapProduction.season` and before
   `WorldEconomy.season`. It reads only what is written earlier in the tick or last season, so sect orders and upkeep
   (paid in `WorldMoney`, after the economy) act at the next season's province step. Provinces rule 13 is amended to
   say so (a GDD delta for the user).
5. **Shadow, then switch.** Stage 1 publishes `production` per province beside the region contract; `WorldEconomy`
   keeps reading regions. In shadow no buildings exist, so F4's building term is 0. The shadow check is: the sum of
   province production equals the continent total of place output every season, and, before F2's wilderness shares,
   each region's provinces sum to that region's total (wilderness shares may cross region borders, so the per-region
   identity holds only without them). The economy reads provinces from Stage 6.
6. **One catalogue (D6: one to one).** In Stage 2 each place's `qi.layer2` works become buildings of its province at
   the same level and with the same gains, and are removed from the place: a worked mine becomes the production
   building matching its site (mine works, hunting lodge, spirit fields), a sect array a gathering array, and spirit
   grove, qi channel and vein dressing their own kinds (Provinces rule 8, amended 2026-11-24). Cultivation buildings act
   at the province's seat, production buildings on the province's sites of their kind. `qi.prebuilt` is **not**
   migrated: it stays on each settlement as part of the land ("the ground's own works", Provinces rule 10, no slot,
   never ruined). Formula B's layer-2 density at a seat reads the province's cultivation buildings plus the place's
   prebuilt; `MapWorks.production_gain` stays the single site gain. Layer-1 home works (Cave Abode) stay on the place.
7. **Staff and upkeep (D3).** A province's population is one pooled workforce shared by its buildings; when upkeep falls
   short, production buildings are paid first, then logistics, society, cultivation and great projects (lowest
   building id first within a group).
8. **Prices, not caps (D4, amended by the user 2026-11-24).** Buildings have no highest level and no layer-2 effect
   caps; cost growth per level is the bound. Each kind's track prices it: levels up to `free_level = ⌈T / 2⌉` cost the
   Formula J price, each level above costs `track_surcharge` (×2) more again. Holdings prices production buildings and
   granaries, Trade logistics and market halls, Military warding walls, Institutions cultivation buildings and each
   great-project stage. "Pavilions" is dropped. Abode works follow the same rule with the abode's grade as the price
   (Cave Abode F3). `D_cap` and `prod_mult_cap` are removed; `settled_density_cap` (1.8) stays, for homes in villages,
   towns, markets and cities only (sect grounds have none). Census 2026-11-24: with the caps off, sects built no level
   above 5 in 200 years, because a level is paid from one season's budget; Stage 4's builder must save toward a level
   over several seasons for the uncapped rule to take effect.
9. **Site growth (D5).** On a grade step the reserve keeps its fraction of the new maximum; a wilderness site with no
   matching building grows only after its holder builds the matching outpost in the wilderness slot. Nothing is placed
   at the start.
10. **Old saves (D7: refuse).** Save meta gains `provinces_version` (`provinces.json`'s `schema_version`). A save
    without it, or with another value, is refused by `load_dict` with the existing "cannot be loaded" message.

### Key Interfaces
- `Provinces.build(gd, db)`: world generation, after places.
- `Provinces.season(gd, db, year, season) -> Array` (news lines).
- `Provinces.of_place(db, place_id) -> Dictionary`.
- `GameQuery.province(id)` reads the live record (shared file, coordinated).

### Implementation Guidelines
- `src/gameplay/world/provinces.gd` (static functions, `class_name Provinces`), tests in `tests/unit/world/`.
- `province_stats_v2.py` stays only as a seed-7 parity fixture for F1, F2, F4, F5.

## Alternatives Considered

### Alternative 1: Reorder the tick (sects spend before the economy)
Matches rule 13 as written. Rejected (D1): it moves money flows already tuned against the baseline.

### Alternative 2: Migrate old saves
Build the table and the 1,240 new places into an old save on load, as `Ties.migrate` does for ties. Rejected (D7): a
whole-world migration is costly to keep working, and the game is a prototype.

### Alternative 3: Keep works on places beside province buildings
Two catalogues. Rejected by Provinces rule 8 (one catalogue) and OQ 9 (double counting).

### Alternative 4: Switch the economy at once
No shadow period. Rejected: the economy switch (Stage 6) is the biggest balance change, and the shadow proves the
province sums before anything reads them.

## Consequences

### Positive
- One live copy of the province formulas; the panel shows the game's own numbers.
- Buildings, population and access have a home record for Stages 2-8.

### Negative
- Sect building lands one season late (D1).
- Every save made before this change stops loading (D7).
- A bigger save: about 705 records.

### Neutral
- The region contract stays until Stage 6.

## Risks
- **Stage 2 moves cultivation** if the works migration is wrong (seat density). Guard: the census baseline.
- **Shared files** (`game_query.gd`, `map_screen.gd`): coordinate with the UI-windows session.

## GDD Requirements Addressed

| GDD | Requirement | How |
|-----|-------------|-----|
| `design/gdd/provinces.md` | Rules 1-3 (province records, place link), 6 (production), 13 (tick order) | Decisions 2-5 (rule 13 amended for the lag) |
| `design/gdd/provinces.md` | Rule 8 (one catalogue), rule 9 (caps), OQ 9, OQ 10 | Decisions 6, 8 |
| `design/gdd/provinces.md` | F4 staff, OQ 8 | Decision 7 |
| `design/gdd/provinces.md` | Rule 8 site growth bullet | Decision 9 |
| `design/gdd/regional-economy-trade.md` | Production contract per province, access (Formula A) | Decision 5 (shadow, then Stage 6) |
| `design/gdd/travel-map.md` | Rule 25 (contract), rule 31 (layer-2 works = province buildings) | Decisions 5, 6 |

## Performance Implications
One pass over 705 provinces and 1,494 places a season; measured in Stage 1 against the 459 ms season and AC-PV-24's
5 ms guess (D8).

## Migration Plan
Saves: refused (decision 10). Data: `qi.layer2` and `qi.prebuilt` move to province buildings at world generation in
Stage 2 (decision 6).

## Validation Criteria
- Stage 1: the shadow identities of decision 5 as a property test over seeds; census and sim unchanged; the step timed.
- A save without `provinces_version` is refused (unit test).
- Every place has a `province_id`; the 5 lakes get their nearest land province (unit test).

## Related
`production/plans/provinces-runtime.md`; `design/gdd/provinces.md`; `design/gdd/regional-economy-trade.md`;
ADR-0002; ADR-0006.
