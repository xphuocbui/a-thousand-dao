# Acceptance-criteria coverage: Travel & Map and World Generation on continent 11

Audit 2026-11-20, read-only (this file is its only output). Sources: `design/gdd/travel-map.md` (Acceptance
Criteria, 150 AC-TM), `design/gdd/world-generation.md` (39 AC-WG), `production/plans/continent-world.md` sections 5-7,
the code in `src/gameplay/world/`, `src/gameplay/session/game_session.gd`, `src/gameplay/cultivation/cultivation_rules.gd`,
`src/gameplay/crafting/herb_field.gd`, `src/debug_terminal/`, the offline tools in `tools/design/map/` and
`tools/design/world/`, and the shipped data in `assets/data/`.

**How to read the classes.**
- **COVERED**: a test asserts the criterion's headline clause or number. Clauses it leaves unasserted are named.
- **BUILT, UNTESTED**: the code does it, but no test asserts the headline. This includes tests that re-derive the
  formula from the shipped data instead of asserting the GDD's number, and offline Python checks with no test.
- **PARTIAL**: part of the behaviour is built; the gap names what is missing.
- **NOT BUILT**: nothing implements it; the system it waits on is named where there is one.
- **CONTRADICTED**: the build does what the criterion forbids, or uses other numbers. Deliberate choices from the
  plan's section 7 are still classed here and tagged with that section.

**Limits of this audit.**
- The tests were read, not run. The GDD's evidence folders `tests/unit/travel_map/` and `tests/integration/travel_map/`
  do not exist; the tests are in `tests/unit/world/`. The fixtures FX-TM-MINI, FX-TM-GRID, FX-TM-MU, FX-TM-RNG and FX-TM-SEEDS
  do not exist, so every hand-built-map criterion is at best BUILT, UNTESTED.
- Two read-only runs were made: `python -I tools/design/world/check_chronicle.py` (2 findings, quoted under
  Contradictions) and `tests/performance/world/worldbuild_probe.gd` (17.5 s; 272 places, 41 sects, 516 events, 5,000
  alive [3935, 844, 191, 27, 3], 4,091 in sects, ledger 131, year 1,200).
- The working copy moved during the audit: at 14:34 the other session changed `assets/data/world_history.json` (54 cast
  builds exported), `assets/data/world_generation.json` and `tools/design/world/export_world.py`, and added
  `tests/performance/world/cast_power_probe.gd` (+ `.uid`). It then added `GameSession.place_density` and edited
  `tools/balance/autoplay.gd`, which do not change any row. Rows describe HEAD's code plus that working copy; only AC-WG-08
  depends on the change. This audit wrote nothing else.
- `[UI]` rows need retained screenshots in `production/qa/evidence/debug-terminal/`. None exists for these commands;
  only the text transcripts 01 and 03 in this folder. `[Harness]` rows need runs that have not been made.

## Summary

| GDD | Criteria | COVERED | BUILT, UNTESTED | PARTIAL | NOT BUILT | CONTRADICTED |
|---|---|---|---|---|---|---|
| Travel & Map (AC-TM) | 150 | 27 | 49 | 34 | 24 | 16 |
| World Generation (AC-WG) | 39 | 8 | 15 | 7 | 4 | 5 |

Of the 150 Travel & Map criteria, 18 are `[Harness]` or performance items and 9 are `[UI]` items. None of the `[UI]`
items has a screenshot. The only harness numbers come from `land_qi.py`'s map check (`design/map/continent-11/land_qi.json`)
and the world-build timings.

## Travel & Map (design/gdd/travel-map.md)

| ID | Class | Evidence or gap |
|---|---|---|
| AC-TM-01 | BUILT, UNTESTED | land_qi.py is deterministic numpy over fixed images; no test builds it twice and compares dumps |
| AC-TM-02 | COVERED | continent_data_test::test_the_grid_loads_every_layer_at_the_continents_size asserts 540 x 360; land_qi.py derives tiles as W / fine_factor; the 1,080 x 720 case is not tested |
| AC-TM-03 | BUILT, UNTESTED | continent_gen.py check() reports rivers_uphill (offline observation); "every river ends at sea, a lake or the edge" is not checked; no test |
| AC-TM-04 | PARTIAL | world_map.json land.biomes: 19 biomes, profiles sum 100, b_b equal Formula C, danger 1-4, volcano 45/40/15, signature + sigma; no climate band field; no Config check |
| AC-TM-05 | COVERED | land_qi_test::test_every_place_has_built_qi_in_range asserts every place's base shares sum to 100 (+/-0.5), variants kept apart; FX-TM-MINI / FX-TM-GRID do not exist, tiles not checked |
| AC-TM-06 | BUILT, UNTESTED | land_qi.py Land.features/finish implement the feature fall-off; no G2 fixture (and the shipped sigma is 40, the fixture's 25) |
| AC-TM-07 | CONTRADICTED | [Harness] variants come only from feature pushes, but land_qi.json check: Thunder (loi) 2.02 % and Ice (bang) 2.16 % of places, over the 2 % cap |
| AC-TM-08 | BUILT, UNTESTED | land_qi_test::test_land_match_follows_formula_a re-derives Formula A with the shipped mu for this root; 1.244 at FX-TM-MU is not asserted (mu cannot be injected) |
| AC-TM-09 | BUILT, UNTESTED | LandQi.land_match; 0.948 at LAKE not asserted |
| AC-TM-10 | BUILT, UNTESTED | LandQi.land_match loops over mu's keys, variants included, so an Ice root reads Ice share; 1.195 not asserted |
| AC-TM-11 | COVERED | land_qi_test::test_land_match_has_no_ceiling_and_a_floor asserts purity 200 passes x2 (no ceiling) and mismatched ground stops at match_land_min 0.8 |
| AC-TM-12 | BUILT, UNTESTED | land_qi_test::test_road_purity_counts_at_the_unowned_rate re-derives u = 0.5 for road purity; 1.172 at VOL not asserted |
| AC-TM-13 | BUILT, UNTESTED | by construction (shares sum 100, base mu sum 1); not asserted |
| AC-TM-14 | BUILT, UNTESTED | LandQi.land_match on a root with no land element; 0.995 not asserted |
| AC-TM-15 | COVERED | land_qi_test::test_world_means_of_the_base_elements_sum_to_one asserts base mu sum 1.000; mu is a file constant so a scar cannot move it; the per-element mean is not recomputed |
| AC-TM-16 | NOT BUILT | [Harness] no 200-root run over the map; no dependency, only the harness is missing |
| AC-TM-17 | BUILT, UNTESTED | LandQi.stacked_density adds layer-2 sect_array (qi.layer2) and Tụ Linh (density_bonus); the 1.90 stack is not tested |
| AC-TM-18 | BUILT, UNTESTED | LandQi.land_match caps layer 3 at match_cap_l3 0.3 and MapWorks.match_gain caps layer 1 at 0.15, no stack cap; 1.694 not tested |
| AC-TM-19 | PARTIAL | caps c3 1.0, c2p 0.1, c2u 0.5, c1p 0.1, c1u 0.75 applied (LandQi, MapWorks.density); capability #15 raising c1u to 1.05 is not built; Tụ Linh bypasses c1u (density_bonus); untested |
| AC-TM-20 | COVERED | map_works_test::test_settlements_start_developed_and_homes_there_are_capped asserts a peak at 2.4 + 1.0 reads D_cap 3.0; the capability #15 case is untested |
| AC-TM-21 | PARTIAL | share pushes are not renormalised in the match, but HerbFit adds only layer-3 pushes, so a level-5 qi channel leaves herb fit at Fire 60; the stat block shows unpushed shares |
| AC-TM-22 | COVERED | land_qi_test::test_land_match_has_no_ceiling_and_a_floor asserts M 0.8 with no pushes; pushes are added after the floor and are never negative |
| AC-TM-23 | BUILT, UNTESTED | qi.layer1 is keyed by person id (MapWorks.density); no two-character test |
| AC-TM-24 | COVERED | [Harness] continent_data_test::test_the_approved_counts asserts 230 places (272 in a built world with history sites) and 20 regions; "every place kind appears" not asserted |
| AC-TM-25 | BUILT, UNTESTED | land_qi.py place_values applies the settlement row's danger_cut 1, never below 1; untested |
| AC-TM-26 | BUILT, UNTESTED | world_generation.json continent.kinds sets market true for city and market only; untested |
| AC-TM-27 | PARTIAL | place records hold qi (part, shares, variants, land density), climate, density, danger, holder, site; tile mix, settlement size, herb fit, features and land-line steps are not stored or shown |
| AC-TM-28 | COVERED | map_works_test::test_a_cave_abode_on_open_wilderness_becomes_home asserts the abode place on the tile, home, owner and map; the abode_opened fact is logged but not asserted |
| AC-TM-29 | BUILT, UNTESTED | map_works_test::test_a_cave_abode_on_open_wilderness_becomes_home re-derives round(linh_thach_max x 0.05) at Qi Refining; 250 / 30 / 4 and the refusal with too little money not asserted; opening takes the walk plus 1 season |
| AC-TM-30 | CONTRADICTED | open_abode refuses a tile with a place or an impassable tile, but a pure sea-lane (or all-lake) tile is passable and its part loop skips every part, leaving part 0, the sea part, so an abode opens at sea (derived from code); sect territory allowed; on MIX it picks the best part unless [part] is given |
| AC-TM-31 | PARTIAL | TravelGrid modes: boats on any river or lake tile, ships only on sea-lane tiles, off-lane sea impassable; boats are a path mode, not a trip offered between river places; untested |
| AC-TM-32 | PARTIAL | travel answers "cannot be reached" (or falls back to links); the message never names a missing port, ship or flight, and flight is not offered unprompted |
| AC-TM-33 | BUILT, UNTESTED | road c_t = 1 + 0.25 (c_wild - 1) gives 1.25 / 1.375, wilderness 2.5, flight 1.0 (TravelGrid._build); travel_grid_test only bounds wilderness c_t |
| AC-TM-34 | COVERED | continent_data_test::test_trip_time_is_formula_d asserts 90 sea tiles = 1.000; travel_grid_test::test_flight_ignores_terrain_and_opens_at_foundation asserts FE 135 and DT 400; river 80/45 and CF 200 / NS 290 not asserted |
| AC-TM-35 | CONTRADICTED | flight opens by realm alone (TravelGrid.flight_speed; plan section 7.7), so FE flies without a flying artifact; QR refusal is tested |
| AC-TM-36 | COVERED | continent_data_test::test_trip_time_is_formula_d asserts 36 road tiles at tsp +20 = 0.556; travel_test::test_a_trip_spends_whole_seasons_and_the_last_ones_share asserts 1.852 -> 2 seasons, u 0.852; the 1.296 jungle part and gain_last not asserted |
| AC-TM-37 | BUILT, UNTESTED | game_session.travel prints the landing pool 1 - 0.6 x tiles / v_eff (0.815 for 50 tiles at FE +20); it is not applied to a fight; untested |
| AC-TM-38 | COVERED | continent_data_test::test_trip_time_is_formula_d asserts 54 road tiles at tsp -90 = 4.000; travel_test::test_speed_divides_the_trip_and_the_floor_holds asserts the floor; tsp -75 not asserted |
| AC-TM-39 | BUILT, UNTESTED | travel runs ceil(T) seasons (each ages) and credits rate x (1 - u) x eta; travel_test only asserts one season passes and tu vi rises on a short hop; waits on Realms |
| AC-TM-40 | BUILT, UNTESTED | GameSession.teleport_fee implements Formula K; travel_test re-derives the fee at Qi Refining for one array pair; none of the five GDD values asserted; owner_mult fixed 1.0 |
| AC-TM-41 | BUILT, UNTESTED | teleport_fee returns jump_seasons 0.05 whatever the distance or tsp; the jump runs one _pass_season and cultivates 0.95 of it; 0.05 not asserted |
| AC-TM-42 | NOT BUILT | no array owner or refusal; owner_mult is a constant; waits on Sects redesign #26 |
| AC-TM-43 | BUILT, UNTESTED | GameSession.blink exists, but tests/ has no Blink Mark test to pass unchanged |
| AC-TM-44 | BUILT, UNTESTED | TravelGrid.stretches computes each stretch's P with mode factors (flight 0.25); the road + jungle trip and its flight not tested |
| AC-TM-45 | COVERED | travel_grid_test::test_encounter_chance_per_season_is_formula_e asserts a danger-1 road season 0.058 and a danger-2 wilderness season 0.295; danger 1, 3, 4 wilderness not |
| AC-TM-46 | CONTRADICTED | game_session.travel keeps only the first passing stretch (encounter.is_empty() guard): at most one encounter per trip, not one per stretch |
| AC-TM-47 | PARTIAL | the encounter's Event Engine place type comes from the stretch's main biome (travel_rules encounter_place_type, mostly "son"); no sandstorm-by-biome filter, no ground tag dropped in flight |
| AC-TM-48 | CONTRADICTED | the encounter is met after arrival at the destination (plan section 7.6), so the character never stands on tile 5 and nothing resumes |
| AC-TM-49 | NOT BUILT | no mid-flight encounter and no pool carried into a fight; waits on Combat (pool refill) |
| AC-TM-50 | NOT BUILT | [Harness] no 10,000-season run; only the formula unit test (AC-TM-45); no dependency |
| AC-TM-51 | COVERED | discovery_test::test_the_player_starts_knowing_the_overview_and_the_home_region asserts cities, seats and home region known, hidden places unknown; "nothing else" not asserted, and signposts add the start's linked places (plan section 7.6) |
| AC-TM-52 | COVERED | discovery_test::test_sight_grows_with_divine_sense_as_formula_f_says asserts r 4 at 135, 8 at 450, 36 at the cap; 45 / 1,350 / 6,525 not |
| AC-TM-53 | BUILT, UNTESTED | MapKnowledge.reveal_path marks a Chebyshev square of r and a crossed bit; discovery_test::test_a_trip_reveals_tiles_and_places_along_the_way only asserts the count grows and the arrival tile is crossed |
| AC-TM-54 | PARTIAL | a place is known or not (MapKnowledge.places); a rumour is a clue naming a region, not a Heard-of place; no stale density after a visit |
| AC-TM-55 | BUILT, UNTESTED | only the player carries MapKnowledge, so no NPC has a per-tile map; an NPC's region knowledge is not modelled either |
| AC-TM-56 | COVERED | discovery_test::test_the_player_starts_knowing_the_overview_and_the_home_region asserts hidden places unknown, test_an_unknown_place_cannot_be_travelled_to the refusal; no second character's knowledge exists to test B; `db show <id>` still prints a hidden place's name and density |
| AC-TM-57 | BUILT, UNTESTED | world_builder_test::test_hidden_places_sit_on_their_rolled_tiles... and test_hidden_spots_are_keyed_on_seed_and_slot_alone assert the rolled candidate and a same-seed repeat for one seed; the 100-seed coverage and history-fact / abode-tile links not asserted |
| AC-TM-58 | BUILT, UNTESTED | Discovery.search_chance uses region wilderness x 0.20 and jade_slip_area 400; the areas are not asserted |
| AC-TM-59 | COVERED | discovery_test::test_formula_f_search_chance_matches_the_example asserts the CF jade slip at 0.37 +/-0.01 (GDD 0.368); rumour 0.108 and FE 0.140 not |
| AC-TM-60 | CONTRADICTED | a false clue's P is 0 (asserted in discovery_test), but Discovery.search prints "without luck (0% a season)" for it, so it is told apart whenever a true clue would show a visible chance (a CF rumour shows about 11 %) |
| AC-TM-61 | COVERED | discovery_test::test_an_exact_map_finds_the_place_on_arrival_and_a_blessed_land_turns_on asserts the sure find; check_path short-circuits the roll, roll count not asserted |
| AC-TM-62 | COVERED | same test asserts a "discovery" event on the place; Discovery.discover logs finder and season (not asserted) |
| AC-TM-63 | PARTIAL | arrival p_detect = DS / (DS + H) and flying x0.5 built (Discovery.check_path); a season's 3-roll tile search is not built (tile_search_rolls unused); untested |
| AC-TM-64 | NOT BUILT | a found tile secret only pays a cache (Discovery.discover); nothing enters the finder's match, and telling does not exist; no dependency |
| AC-TM-65 | BUILT, UNTESTED | knowledge.found is saved (MapKnowledge.to_dict); discovery_test::test_knowledge_survives_a_save asserts tiles, clues and places, not found |
| AC-TM-66 | PARTIAL | each slot on a tile rolls separately (check_path loops the ledger); told secrets do not exist |
| AC-TM-67 | NOT BUILT | no clue items; needs Item Database clue items, which the item data does not have yet |
| AC-TM-68 | NOT BUILT | [Harness] no 10,000-arrival run; no dependency |
| AC-TM-69 | COVERED | herb_fit_test::test_hoa_linh_chi_on_a_volcano_is_excellent asserts fit 1.000, excellent, x1.20 |
| AC-TM-70 | COVERED | herb_fit_test::test_hoa_linh_chi_on_a_glacier_cannot_be_planted asserts unplantable and a line starting "temperature 5"; the shipped line reads "temperature 5 (ideal 70 +/- 25)", not "needs 55-85" (data note in Contradictions) |
| AC-TM-71 | CONTRADICTED | elem_full_share is 25 (GDD 40) and Thanh Tâm Liên's rain_tol 25 (GDD 15): f_e 1.000, fit 0.833 excellent, not 0.825 / 0.688 good; the test overrides the band and re-derives f_e from data (plan section 7.12) |
| AC-TM-72 | CONTRADICTED | f_D 0.640 / 1.000 match, but elem_full_share_variant is 15 (GDD 20): Ice 10 gives f_e 0.767, not 0.650 |
| AC-TM-73 | BUILT, UNTESTED | HerbFit.label with items_herbs.json labels (lower bound included); no boundary test |
| AC-TM-74 | CONTRADICTED | HerbFit.fit returns growth 0 below plant_floor, so HerbField.grow stops a planted herb at fit 0.1 instead of x0.12 |
| AC-TM-75 | PARTIAL | HerbField reads HerbFit at home, but HerbFit adds only layer-3 pushes; a private spring (layer 1) is ignored, so 0.930 cannot result |
| AC-TM-76 | NOT BUILT | [Harness] no wild herb grounds: map_resources.json site_kinds are mine and spirit_vein only; no dependency |
| AC-TM-77 | PARTIAL | map_resources.json covers linh thạch and 5 ores; no herbs, beast materials or special goods; no dangling-id validator |
| AC-TM-78 | PARTIAL | MapProduction.init_site: reserve, base output, recovery by kind, start 0.85-1.0 by keyed roll; no history-thinned starts; max = 60 x base, not a hand-set size; map_production_test only asserts reserve <= max |
| AC-TM-79 | BUILT, UNTESTED | [Harness] MapProduction.site_resource: ore = top base element, linh thạch at land density >= 1.0 and Earth + Metal >= 50 (veins always); no map-wide check |
| AC-TM-80 | COVERED | map_production_test::test_the_gdd_mine_produces_9104_a_season |
| AC-TM-81 | BUILT, UNTESTED | init_site gives 10,000 x 0.5 / 30 = 166.67 -> 167 at factor 1; untested |
| AC-TM-82 | BUILT, UNTESTED | MapProduction.production clamps D_f to 0.75-1.25 and caps the product at 2.0; price_index fixed 1.0 until #43; untested |
| AC-TM-83 | PARTIAL | S_f is a stored scar factor (MapChange.scar multiplies 1 + delta density, cap 1.5), not q_now / q_gen; rested 0.1 and settle_w in data; untested |
| AC-TM-84 | COVERED | map_production_test::test_reserve_factor_follows_formula_i asserts r 0.9 -> 1.0, 0.55 -> 0.85, 0.10 -> 0.25; 0.30 / 0.20 and continuity not |
| AC-TM-85 | COVERED | map_production_test::test_over_mining_thins_and_rest_recovers asserts 330,000 - 2,104 = 327,896 |
| AC-TM-86 | COVERED | same test asserts 60,000 + 0.01 x 600,000 x (1 - 625 / 7,000) = 65,464.3 |
| AC-TM-87 | BUILT, UNTESTED | MapProduction.next_reserve leaves the reserve unchanged at E = S and clamps at the floor; untested |
| AC-TM-88 | NOT BUILT | no rich / worked / thinned band labels anywhere (the stat block shows a reserve percent); no dependency |
| AC-TM-89 | NOT BUILT | [Harness] no long run of FX-TM-MINE; no dependency |
| AC-TM-90 | BUILT, UNTESTED | [Harness] tools/design/map/regions.py reports the natural border share (offline); connectivity and 60 % per region are not asserted anywhere |
| AC-TM-91 | PARTIAL | loose cultivators own only abodes (owner_id), regions may be unheld, but MapChange.transfer accepts any id as holder (no sect check) |
| AC-TM-92 | PARTIAL | MapProduction.season sums qty per region and resource; value_lt is never computed |
| AC-TM-93 | BUILT, UNTESTED | territory totals count each site once by its place's territory field; untested |
| AC-TM-94 | PARTIAL | region records get production {resource: units} and a head count by location; no contract_version, season_index, holder_id, pop_cultivators[5], settlement weight, value_lt, bands, top_rarity, by_element, by_good, demand_factor_used; no territory record (only w_meta.territory_production); map_production_test asserts production > 0 |
| AC-TM-95 | PARTIAL | each season overwrites the region record (no 8-season history); nothing consumes production, so the Market is untouched |
| AC-TM-96 | COVERED | map_change_test::test_a_cycled_realm_is_open_for_its_seasons_and_rumoured_ahead (open 3 of 40, rumour ahead, realm_opened recorded) and test_the_timing_differs_by_game_and_the_gate_does_not_move; the rumour is a news line, not an event record |
| AC-TM-97 | BUILT, UNTESTED | world_history.json famous realms cycle 120/4, 60/3, 80/2 seasons with a 4-season lead, inside the bands; no Config check |
| AC-TM-98 | NOT BUILT | no "inside the realm" state; explore only refuses a sealed gate; no dependency |
| AC-TM-99 | PARTIAL | MapChange.transfer moves the holder (works stay on qi; upkept ones pass via MapWorks.holds) and logs a fact; only the player pays upkeep, so a sect's unpaid works never fade |
| AC-TM-100 | NOT BUILT | no rent terms by holder; waits on Sects redesign #26 (holder policy) |
| AC-TM-101 | PARTIAL | MapChange.scar changes a place's density and shares (renormalised) and logs it (map_change_test::test_a_scar_changes_the_land_for_good); no tile-level terrain change, no hash of other tiles |
| AC-TM-102 | PARTIAL | a scar of -1 density sets site.scar 0 and output 0; no 40-season rest rule; S_f ignores layer 2, so a spirit grove cannot revive it |
| AC-TM-103 | PARTIAL | the save is the whole World DB + knowledge + seed, no grid (game_session_flow_test::test_save_load_round_trip asserts player, year, items, rng); no byte-identical dump or 4-season replay test; not "seed plus changes" |
| AC-TM-104 | BUILT, UNTESTED | crafting_formations.json tu_linh 150 x 2.5^(L-1), +0.15 a level (375, 938); refinery_formations_test asserts the paid cost equals build_cost, not 375 / 938 |
| AC-TM-105 | PARTIAL | Tụ Linh upkeep is billed yearly (10 a level, Formations.pay_upkeep), not 2.5 a season; MapWorks.upkeep uses ceil with no carry; the capability #15 double cost is not found |
| AC-TM-106 | PARTIAL | MapWorks.upkeep fades per fade_seasons (4 or 2) and resets on payment; Tụ Linh fades yearly; no costliest-first drop; untested |
| AC-TM-107 | CONTRADICTED | +4 points, max 5, 7,813 and 15 a season are built, but MapWorks.upkeep applies the Earth cut to every layer-1 upkept work, focus array included |
| AC-TM-108 | BUILT, UNTESTED | map_works_test::test_formula_j_costs_grow_by_level asserts the level-5 cost 3,000 x 2.5^4 only; the 193,313 total, 625 upkeep and seat 1.50 not asserted |
| AC-TM-109 | BUILT, UNTESTED | same test asserts spirit grove level 1 2,000, level 3 8,000 in 3 seasons; the 62,000 / 15-season total, max 5 and the c2p cap not asserted |
| AC-TM-110 | BUILT, UNTESTED | layer 2 (qi.layer2, prebuilt) applies to anyone at the place; untested |
| AC-TM-111 | CONTRADICTED | Tụ Linh lives in the character's formations and applies at the current home_id, so it moves with them; layer-1 works are keyed by founder id, so a next claimant gets no tended abode |
| AC-TM-112 | NOT BUILT | no left or ruin home state; an abode stays as a plain place; no dependency |
| AC-TM-113 | PARTIAL | a found blessed land's layer 3 applies to everyone (discovery_test); a blessed land cannot be claimed as a home at all (open_abode refuses a tile with a place) |
| AC-TM-114 | BUILT, UNTESTED | [Harness] data: 5 large (3 famous of 110-120 tiles, 2 hidden of 90), 20 small of 1 tile, dD3 0.7-0.8 and 0.4-0.5, inside the targets; no harness check |
| AC-TM-115 | COVERED | map_works_test::test_settlements_start_developed_and_homes_there_are_capped asserts a city's prebuilt 0.30; seat 0.40, village, town and market (data) not asserted |
| AC-TM-116 | COVERED | same test asserts a settled home capped at 1.80 and wild ground at D_cap 3.0; M has no cap in code |
| AC-TM-117 | BUILT, UNTESTED | MapWorks.rent = round(lt_max x 0.02 x D / 1.4) gives 110 / 4,400 / 1,029; map_works_test only asserts a rent above 0 and its billing |
| AC-TM-118 | PARTIAL | grade_realm_min enforced for the player (map_works_test asserts grade 4 refused below Kết Đan); sect members get min(realm + 1, max); random NPCs get no grade |
| AC-TM-119 | CONTRADICTED | MapWorks.density adds the furnishing to l1p before min(c1p 0.10, ...), so grade 3 adds 0.10, not 0.15; rent billing each season is asserted (map_works_test) |
| AC-TM-120 | CONTRADICTED | [Harness] this audit's probe: 4,091 of 5,000 in sects (living at seats) and 85 % of the rest settled, about 0.97 settled, not 0.85; WorldBuilder._wild_home picks among wild-kind places, not free tiles |
| AC-TM-121 | NOT BUILT | [Harness] no NPC match measurement; no dependency |
| AC-TM-122 | BUILT, UNTESTED | CultivationRules.rate_per_season multiplies stacked D by stacked M; land_qi_test::test_a_place_without_qi_leaves_the_rate_unchanged asserts rate x land match only |
| AC-TM-123 | CONTRADICTED | the CF check reads stacked D (local_density, 1e-6 tolerance), but Tụ Linh stays on density_bonus (plan section 7.10), so building level 3 raises density_bonus by 0.45 |
| AC-TM-124 | NOT BUILT | [Harness] Realms bot re-run with the match not done; nothing in the evidence folder; Realms owns the run |
| AC-TM-125 | NOT BUILT | no Quests visit stage or Heavenly Tribulation reading the place; waits on Quests and Heavenly Tribulation |
| AC-TM-126 | CONTRADICTED | [Harness] density targets met (19.0 % at 1.4+, mean 1.09), but mu_hoa 0.144; 50+ share places Wood 5, Fire 3, Earth 1 (1 region); Thunder 2.02 %, Ice 2.16 % (plan section 7.1) |
| AC-TM-127 | PARTIAL | [Harness] wild land at 1.4+ is 4.0 % (land_qi.json check) and clamps 0.3 / 2.4 exist; the 70 % veins-or-heart share and the 1.45 / 1.65 / 1.25 example not checked |
| AC-TM-128 | PARTIAL | [Harness] places.py check lists inhabited islands without a port; continent_data_test::test_every_settlement_but_two_off_road_minor_seats_reaches_every_other_ac_tm_128 pins two road-less minor seats (reachable on foot or by flight); no forced-miss or rerun check |
| AC-TM-129 | PARTIAL | [UI] `map` lists known places by region as text (hidden and unknown left out); no region or continent zoom, legend or overview; no screenshot |
| AC-TM-130 | PARTIAL | [UI] no `place <name>`; `here` prints a stat block (land part, shares, climate, layer 3, "Density for you" with layer lines, land match); not every rule 7 field; transcript 03 only, no screenshot |
| AC-TM-131 | NOT BUILT | [UI] no `route` command; `travel` starts at once with no confirm step; no dependency (debug terminal) |
| AC-TM-132 | PARTIAL | [UI] `search` and `clues` exist; no area or seasons spent; a false clue shows "0% a season" |
| AC-TM-133 | NOT BUILT | [UI] no `fit` command; HerbFit's lines appear only in a plant refusal; no dependency |
| AC-TM-134 | NOT BUILT | [UI] no `homes`; only `residence rent <grade>` / `residence buy <grade>`; no dependency |
| AC-TM-135 | PARTIAL | [UI] `work` lists level/max and the next cost; no upkeep or fade state |
| AC-TM-136 | NOT BUILT | [UI] no `region` view of production and reserve bands; no dependency |
| AC-TM-137 | NOT BUILT | [UI] no debug true-map view of hidden places and secrets; no dependency |
| AC-TM-138 | PARTIAL | [Harness/perf] map build 6.4 s offline (land_qi.json timing); world build 9.8 s (evidence 02) and 17.5 s (this audit's probe); seasonal update, D x M for 5,000, route query, save delta and load not measured |
| AC-TM-139 | BUILT, UNTESTED | Land.depth (chamfer distance by signature) implements it; no G1 fixture or test |
| AC-TM-140 | BUILT, UNTESTED | Land.profile implements P = norm(P_b + t sigma e_sig); no fixture or test |
| AC-TM-141 | BUILT, UNTESTED | Land.blend (summed-area box mean, sea and lake counted); no fixture or test |
| AC-TM-142 | BUILT, UNTESTED | Land.finish (D4, danger round half up); no fixture or test |
| AC-TM-143 | NOT BUILT | no hand-correction input in land_qi.py, no "set by hand" stat line, no map-check listing; no dependency |
| AC-TM-144 | NOT BUILT | the stat block (terminal_views.gd stat_block) shows final shares and density only; the biome/depth/blend/feature steps are not stored per place; no dependency |
| AC-TM-145 | NOT BUILT | no per-character border knowledge; region holders are only data; partly waits on Sects redesign #26 (territory changing in play) |
| AC-TM-146 | BUILT, UNTESTED | the mix fold (mix_share_min 0.10) and sea-at-half rule live in continent_gen.py, which made the approved mix images; tie rule unverified; no test |
| AC-TM-147 | BUILT, UNTESTED | part values are cell means (Land.parts), tile values share-weighted (ContinentGrid.tile_qi); land_qi_test only asserts tile density > 0 |
| AC-TM-148 | PARTIAL | TravelGrid._wild_cost share-weights land parts and drops sea parts (1.470 for MIX); "keeping to one part" is not built; untested |
| AC-TM-149 | CONTRADICTED | TravelGrid._tile_danger rounds the share-weighted danger (60 % d1 + 40 % d3 = 1.8 -> 2, h 0.35) instead of 0.370; the encounter biome is the stretch's longest-time tile, not rolled by share |
| AC-TM-150 | BUILT, UNTESTED | [Harness] continent_data_test::test_land_tiles_have_shares_summing_to_100_and_values_in_range samples every 7th tile for a mix sum of 100 only; parts >= 10 %, main biome, tile values and river flags not checked |

## World Generation & History (design/gdd/world-generation.md)

| ID | Class | Evidence or gap |
|---|---|---|
| AC-WG-01 | PARTIAL | WorldBuilder.generate runs base, sects, history, cast, rolls, sites, random fill, named items in order; steps 8-9 run in GameSession.new_game; no per-step start/end log |
| AC-WG-02 | CONTRADICTED | keyed rolls and per-person cast streams are seed-independent, but _step_named_items picks holders from all living people (cast included) with the game rng, so cast gear differs by seed; no byte-identical dump test |
| AC-WG-03 | BUILT, UNTESTED | world_builder_test spot-checks counts, sect treasury/alignment, C001 text, cast name/realm/age/root; no hash comparison (place records also gain climate and prebuilt fields) |
| AC-WG-04 | BUILT, UNTESTED | check_chronicle.py (run read-only for this audit) counts 200 landmarks / 316 annals and checks ids, years, people, places, text; Config/Data, no test |
| AC-WG-05 | COVERED | world_builder_test::test_the_chronicle_and_annals_are_the_event_log_in_order asserts the log size equals both tiers, year order, authored flag, C001's text |
| AC-WG-06 | CONTRADICTED | annal A280 carries tile [318, 256], candidate 1 of slot R-3; check_chronicle.py also reports S-10's candidate on Huyền Minh Động; rumours name the region only (Discovery.rumour) |
| AC-WG-07 | BUILT, UNTESTED | world_history.json: 86 people (54 alive), 30 living heads; export_world.py warns outside 60-100; no test |
| AC-WG-08 | BUILT, UNTESTED | CastBuilds.make loads a build as written (cast_builds_test, two tests); the 54 DRAFT builds (design/world/cast_builds.json, awaiting the user's review, plan step B3) were exported into the working copy's world_history.json at 14:34 today by the other session, uncommitted; HEAD ships none, so all 54 are stand-ins there; no fight-sheet-under-two-seeds test |
| AC-WG-09 | BUILT, UNTESTED | export_world.py cast_builds() errs "(person): Đạo Đồ node N does not exist" and writes nothing (offline); no runtime Checking state; no test |
| AC-WG-10 | BUILT, UNTESTED | export_world.py sects() checks F1 settle levels and loyalty above 30; world_builder_test asserts 30 active sects; no dial in the data |
| AC-WG-11 | COVERED | world_builder_test::test_realm_headcounts_meet_formula_a_exactly asserts realm_targets(5,000) exactly and cast + F_r per realm on the 80-person test world; the 5,000-person build itself is only this audit's probe (5,000 alive [3935, 844, 191, 27, 3]), not a test |
| AC-WG-12 | PARTIAL | [Bot] world_builder_test::test_random_members_join_inside_the_history checks one seed (join >= founding, >= age 16, master of a higher realm); random cultivators get no personal history events; no 30-seed bot run |
| AC-WG-13 | BUILT, UNTESTED | slot_pick is keyed on seed + slot; world_builder_test checks one seed and that another seed moves some; no 100-seed coverage or shared-tile check (export_world.py refuses shared candidates offline) |
| AC-WG-14 | COVERED | world_builder_test::test_hidden_spots_are_keyed_on_seed_and_slot_alone recomputes every pick in a fresh builder (order-free by key) |
| AC-WG-15 | CONTRADICTED | the ledger has 131 rows (28 slots + 80 secrets + 23 sites; test asserts slots + secrets), but each hidden place's record in `places` keeps its rolled tile (views do not print it), and `db show w_meta` prints the whole ledger as JSON (TerminalViews.show default branch) |
| AC-WG-16 | COVERED | world_builder_test::test_the_world_builds_with_no_errors_at_the_authored_start_year asserts 1,200 (one seed; start_year is data) |
| AC-WG-17 | CONTRADICTED | origin homes are honoured (travel_test::test_each_origin_starts_at_one_of_its_approved_homes; continent_data_test 30/10/7), but new_game adds the player before ratings.worldgen (step 8), not after it; N + 1 not asserted |
| AC-WG-18 | BUILT, UNTESTED | load_dict never calls a builder; seed and data_version are saved (w_meta); game_session_flow_test::test_save_load_round_trip asserts neither |
| AC-WG-19 | NOT BUILT | no runtime Checking/Failed state: new_game push_errors builder errors and returns ok; only export_world.py --check fails before writing; no dependency |
| AC-WG-20 | NOT BUILT | no cancel; the build is synchronous; needs the new-game screen (Game UI #37) |
| AC-WG-21 | COVERED | world_builder_test::test_realm_headcounts_meet_formula_a_exactly asserts 5,000 -> 3935/844/191/27/3 and 3,000 -> 2361/506/115/16/2; N = 0 -> 3,000 and the 8,000 sum not asserted |
| AC-WG-22 | PARTIAL | export_world.py errs "a realm weight is zero or negative" without naming the realm; runtime has no check |
| AC-WG-23 | PARTIAL | runtime F_r = max(T_r - K_r, 0) (no error when K > T); export_world.py errs on K_r > T_r(3,000) offline; untested |
| AC-WG-24 | BUILT, UNTESTED | slot_pick = stable_hash % n (a hash cannot be injected); export_world.py refuses fewer than 2 candidates offline; untested |
| AC-WG-25 | COVERED | world_builder_test::test_random_members_join_inside_the_history asserts every join year in [max(born + 16, founding), 1,200]; WorldBuilder._join gives Y0 at a = 16 and Y0 - 24..Y0 at a = 40 |
| AC-WG-26 | BUILT, UNTESTED | the 12 Checking cases exist offline in export_world.py (the zero-weight one unnamed); none has a failing-file test; the cast-size warning exists |
| AC-WG-27 | BUILT, UNTESTED | _step_named_items makes one record per unique template; no authored holders are placed (legendary items wait for Effects); no continent test |
| AC-WG-28 | BUILT, UNTESTED | export orders events by year then id; world_builder_test asserts year order only |
| AC-WG-29 | PARTIAL | discovery_test::test_a_save_from_another_map_version_is_refused asserts refusal naming the map version; data_version is saved but never compared; older readable saves untested |
| AC-WG-30 | COVERED | rating_session_test::test_world_generation_rates_the_player_and_the_load_set_ac_pr_26 on the continent (80 people, budget 120): every NPC Stale or Provisional, the player Rated; 8,000 at 5,000 not run |
| AC-WG-31 | PARTIAL | world_builder_test::test_the_thirty_sects_start_as_authored_with_their_leaders asserts a living tong_chu per sect; no runtime Sects F1 check (Sects redesign #26) |
| AC-WG-32 | COVERED | world_builder_test::test_hidden_places_sit_on_their_rolled_tiles_and_blessed_lands_give_layer_3 and test_hidden_spots_are_keyed_on_seed_and_slot_alone assert each hidden place at its ledger tile = an authored candidate |
| AC-WG-33 | BUILT, UNTESTED | tools/balance/world_census.gd runs on the continent; no census result in production/qa/evidence/continent-world (files 01-03 only), though plan section 7 says it is there |
| AC-WG-34 | BUILT, UNTESTED | [Performance] tests/performance/dao_do/worldgen_perf.gd PASS 9.8 s (evidence 02; this audit's probe 17.5 s) with ratings off, so step 8's fights are not timed; not a release build |
| AC-WG-35 | NOT BUILT | [UI] needs Game UI #37 |
| AC-WG-36 | PARTIAL | the builder makes no LLM call and every chronicle line has text_vi; random cultivators have no templated personal history, and many sects and places have no description; untested |
| AC-WG-37 | BUILT, UNTESTED | check_chronicle.py replays the land changes from year 0 (no territory finding this run); runtime never replays; no test |
| AC-WG-38 | NOT BUILT | no grudges or F7 attitudes at runtime; waits on Sects redesign #26; export_world.py only validates the grudges' sect ids |
| AC-WG-39 | CONTRADICTED | WorldBuilder logs C097 and C182 with data.secret but nothing reads the flag: `history <n>` / `legends <n>` prints them before discovery (n large enough to reach years 485 and 1100; the default shows the last 25) |

## Most important gaps (for playing on the continent)

1. **Encounters on the way are thin** (AC-TM-46, 47, 48). A trip draws at most one encounter, met after arrival, picked by a
   coarse place type (mostly "son"). Long crossings carry far less risk than Formula E says, and the terrain barely shows.
2. **NPCs live in the wrong places, and nobody has measured the effect** (AC-TM-120, AC-TM-124, AC-WG-33). About 97 %
   settle (target 85 %), the rest pick wild places rather than tiles, and no census or Realms bot run on the continent is in
   the evidence. The NPC realm targets (1 in 8 / 12 / 15 / 20) are unmeasured with the land match in.
3. **Hidden things leak** (AC-WG-39, AC-WG-06, AC-WG-15, AC-TM-60). `history <n>` prints the secret events C097 and C182,
   annal A280 names a tile that is a candidate of slot R-3, `db show w_meta` prints the whole ledger, and a false clue shows
   "0% a season".
4. **Little to find out in the land** (AC-TM-64, 76, 77, 63, 113). Tile secrets pay a cache and add nothing to the match.
   There are no herb grounds, no beast or special-goods sites and no tile search, and blessed lands cannot be claimed as
   homes.
5. **No way to plan in the terminal** (AC-TM-129 to 137). There is no `route` with a confirm step, no `fit`, `homes`,
   `region`, true map or zoomed map, and no screenshots. `travel` commits at once.
6. **The cast's builds are not in the committed game** (AC-WG-08). HEAD's `world_history.json` has no `cast_builds`, so all
   54 living cast members, the 30 sect heads included, are keyed stand-ins. The other session exported the 54 DRAFT builds
   into the working copy at 14:34 today (uncommitted, awaiting the user's review, plan step B3).
7. **Herb growth was retuned away from the GDD** (AC-TM-71, 72, 74). s_full is 25 and 15, tolerances are 25, and a herb
   whose ground falls below the floor stops growing. A GDD update or a revert is needed before balance work.
8. **Home works do not stay with homes, and abodes can open at sea** (AC-TM-111, 119, 123, 105, 30). Tụ Linh Trận moves
   with the character and is billed yearly on `density_bonus`, a residence's furnishing is cut to 0.10 by c1p, and a next
   claimant inherits nothing. A sea-lane tile passes `open_abode`'s checks.
9. **No load-time Checking** (AC-WG-19, 20, 22, 26). A bad data file only `push_error`s and the game starts. The Checking
   list exists only offline in `export_world.py --check`, with no failing-file tests.
10. **The production contract is a stub** (AC-TM-92, 94, 95). Each season gives units per region and a head count only: no
   value, bands, holder, by-realm population or history. Nothing consumes it until Regional Economy #43.

## Contradictions

Each entry gives the criterion's wording, then what the build does.

- **AC-TM-07 / AC-TM-126 (variants).** GDD: "Each variant is in at most 2 % of places". Build (`design/map/continent-11/land_qi.json` check): "variant loi at 0.020 of places" (0.0202) and "variant bang at 0.022 of places" (0.0216).
- **AC-TM-126 (elements; plan section 7.1).** GDD: "each base `mu_e` is 0.15–0.25; every base element has at least 8 places where its share is 50 or more, spread over at least 3 regions". Build: "mu_hoa 0.144 outside [0.15, 0.25]"; places at 50+: Wood 5.0, Fire 3.0, Earth 1.0 (in 1 region).
- **AC-TM-35 (plan section 7.7).** GDD: "Flight is refused ... at Foundation Establishment without a flying artifact." Build: `TravelGrid.flight_speed` reads the realm only; the plan says "Flight needs only the realm (no flying artifact exists in the item data yet)".
- **AC-TM-46.** GDD: "each stretch draws exactly one encounter". Build: `GameSession.travel` keeps the first passing stretch (`if encounter.is_empty() and i < stretches.size() and rng.randf() < ...`), so a trip has at most one encounter.
- **AC-TM-48 (plan section 7.6).** GDD: "the character stands on tile 5, and the time spent counts; after a win the trip resumes from tile 5". Build: "an encounter is met on arrival, not mid-trip": the player is moved to the destination before `_road_encounter` runs.
- **AC-TM-149.** GDD: "a tile with parts at danger 1 (60 %) and 3 (40 %) ... its hazard is 0.370 a season", and the biome is rolled by share. Build: `TravelGrid._tile_danger` rounds the share-weighted danger (1.8 to 2), giving h 0.35. The encounter's biome is the main biome of the tile where the stretch spent most time, with no roll.
- **AC-TM-60.** GDD: "No screen or exported field shows that the clue is false." Build: `Discovery.search` prints "You search for ... without luck (%.0f%% a season)". A false clue always shows "0%", while a true clue shows its chance (a CF rumour about 11 %), so the two can be told apart whenever the true chance would be visible.
- **AC-TM-30 (derived from code, not run).** GDD: "Opening an abode is refused on a tile that holds a place, and on sea." Build: `open_abode` refuses only `not tg.passable(t)` or a tile with a place. A sea-lane tile is passable (mode sea), every part is skipped as sea, `best` stays 0, and `grid.part_qi(x, y, 0)` returns the sea part, so the abode opens. An all-lake tile (mode river) takes the same path.
- **AC-TM-71 (plan section 7.12).** GDD: "f_e is 0.825, f_R is 0.833, fit is 0.688 (good)". Build: `items_herbs.json` fit `elem_full_share` 25 (GDD 40) gives f_e 1.000 for Water 30, so fit is 0.833 (excellent). Thanh Tâm Liên ships `rain_tol` 25 (GDD 15); the test overrides it to 15.
- **AC-TM-72.** GDD: "Ice 10 against s_full 20 gives f_e 0.650". Build: `elem_full_share_variant` 15 gives f_e 0.767.
- **AC-TM-74.** GDD: "it keeps growing at ×0.12 and nothing is destroyed". Build: `HerbFit.fit` returns `growth` 0 when fit is below `plant_floor`, and `HerbField.grow` multiplies by it, so the herb stops growing.
- **AC-TM-107.** GDD: "upkeep is 15 a season at level 5, with no Earth discount". Build: `MapWorks.upkeep` multiplies every layer-1 upkept bill by (1 − cut), the focus array included. The GDD disagrees with itself here: Formula J's upkeep line says "the Earth discount on layer 1 only", and the focus array is layer 1.
- **AC-TM-111.** GDD: "after a move, the old home's Tụ Linh Trận stops billing and starts fading at once; the tended abode's +0.06 stays with the place for the next claimant". Build: Tụ Linh is `c.formations` with `applies: home`, so it follows the character's `home_id`. Layer-1 works are stored under `qi.layer1[<founder id>]`, so no later claimant reads them.
- **AC-TM-119.** GDD: "a grade 3 furnishing adds +0.15 on layer 1". Build: `MapWorks.density` adds `furnish_per_grade × grade` to `l1p`, then takes `min(c1p 0.1, l1p)`, so grade 3 adds 0.10.
- **AC-TM-120.** GDD: "the settled share is 0.85 ±0.02 ... every NPC living outside sits in its region's top `npc_wild_pick_top[realm]` of free tiles". Build: the probe puts 4,091 of 5,000 in sects at their seats, and `npc_settled_share` 0.85 applies only to the other 909, which gives about 0.97. `WorldBuilder._wild_home` picks among wild-kind places, not free tiles. Derived from the code and the probe; the share itself was not measured.
- **AC-TM-123 (plan section 7.10).** GDD: "Tụ Linh Trận counts once, as ΔD1u: building level 3 raises `density_bonus` by 0". Build: `crafting_formations.json` `tu_linh` has `"stat": "density_bonus"` (counted once, but through `density_bonus`); plan: "Tụ Linh Trận stays on density_bonus (counted once) until Formations #17 moves it to layer 1".
- **AC-WG-02.** GDD: "WHEN the seed differs, THEN only the ledger, the random cultivators and the reserves differ." Build: `WorldBuilder._step_named_items` picks each unique item's holder with the game `rng` from every living person, cast included, so cast members' gear changes with the seed. The GDD's list may simply be missing step 7.
- **AC-WG-06.** GDD: "GIVEN the chronicle, THEN no event contains the tile of a hidden slot." Build: annal A280 (Tàng Trập Động) has `"tile": [318, 256]`, which is candidate 1 of slot R-3. `check_chronicle.py` reports "hidden slot R-3 candidate [318, 256] is 0.0 tiles from Tàng Trập Động" and "hidden slot S-10 candidate [470, 129] is 0.0 tiles from Huyền Minh Động".
- **AC-WG-15.** GDD: "no player-facing table contains a ledger tile". Build: every hidden slot is a `places` record that keeps its rolled tile (`hidden: true`; the views do not print the tile). `db show w_meta` in the debug terminal, which does not set the cheat flag, prints the `w_meta` record and its whole ledger as JSON (the default branch of `TerminalViews.show`). Plan section 7 lists "hidden places as hidden World DB places" as a GDD follow-up.
- **AC-WG-17.** GDD: "is created after step 8". Build: `GameSession.new_game` adds the player (`db.add("people", ...)`, `_place_player`) before `ratings.worldgen(seed_value, player, ...)`, which is step 8. Power Rankings rates the player's panel there, so the order may be deliberate.
- **AC-WG-39.** GDD: "WHEN the codex, rumours and NPC talk are built before the player discovers it, THEN none of them shows the event or its text". Build: C097 and C182 carry `"secret": true` into `data`, but nothing in `src/` reads the flag, and `history <n>` / `legends <n>` (`terminal_app.gd`) prints every pre-start event. The default shows the last 25, so a larger n is needed to reach years 485 and 1100.

**Data differences in rows not classed CONTRADICTED.**
- **AC-TM-70.** The shipped Hỏa Linh Chi has `temp_tol` 25 and `rain_tol` 25; the GDD's example and FX-TM-HERB have 15 and 20. The reason line reads "temperature 5 (ideal 70 +/- 25) -> x0.00", not "temperature 5, needs 55–85".
- **AC-TM-06 / FX-TM-GRID.** The fixture's jungle signature push is 25; the shipped `sigma` is 40 for every signature biome, so the G1/G2 numbers would not hold on shipped data even with a fixture. FX-TM-GRID sets its own values, so this is not a contradiction.
