# Plan: the game plays on continent 11 with its authored history

Status: DECIDED 2026-11-20. The user's answers to section 2:

1. **All of Travel & Map** this round, not only World Generation plus route travel.
2. **Build the fine-cell Formula C first**, not the tile estimate.
3. **Hand-author all 54 living cast builds** now, not generated stand-ins.
4. **Go anywhere with part seasons** (the recommendation).

The order is in section 5, which replaces section 4.
Design: `design/gdd/world-generation.md` (#27) and `design/gdd/travel-map.md` (#25); data in `design/map/continent-11/`
and `design/world/` (all approved 2026-11-14/15).

## 1. Where things stand

**Approved and ready:**
- the continent: 20 regions, 212 places, 196 routes, 7 teleport arrays, the 540 x 360 tile grid, already exported
  to `assets/data/world_continent.json` and loaded by `ContinentData` / `ContinentGrid`, though nothing in play reads
  them yet;
- the history layer: 15 promoted cities, 17 ruins, 28 hidden slots with 2-3 candidate tiles each, 80 tile secrets;
- 29 sects (7 great, 22 minor) with seats, lands, the authored start state and leaders;
- the cast: 72 people (54 alive: 2 Hóa Thần, 16 Nguyên Anh, 31 Kết Đan, 4 Trúc Cơ, 1 Luyện Khí), with traits and
  10 master ties;
- the history: 200 landmark events and 316 annals (text in Vietnamese), 14 extra records, 34 legendary items, and the
  territory history (6 eras, 37 land changes, 16 wars, 7 fallen sects, 6 grudges);
- the three origins with their home choices, matching the game's own three origins.

**Not authored:**
- **builds for the 54 living cast** (World Gen Open Question 4);
- **each place's qi (density, element shares) and danger.** Formula C's fine-cell build was never made; the map
  tools hold a tile estimate of it (`design/map/continent-11/README.md`, "Land density").

**In the game today:** `WorldGenerator` rolls a random world. It makes 6-8 regions of random places on a chain of
links worth 1-3 seasons each, random sects, and 1,200 years of random legends. About 20 call sites read its record
shapes (`places.links[{to, seasons}]`, `density`, `danger`, `market`, `bounties`, `type`, `region_id`, `sect_id`,
`sects.hq_place_id`, `founded_year`).

## 2. Decisions for the user

1. **Scope of this build.** Recommended: World Generation & History whole, plus travel along the route graph.
   Later: Travel & Map's tile layer (wilderness travel, terrain encounters, sight and search, clues, tile-secret
   finding, production, works, homes, flight and boats), plus the Sects redesign and Regional Economy.
2. **Place qi.** Recommended: export the map tools' Formula C tile estimate as each place's density, element shares
   and danger now, checked against Formula C's map targets; the fine-cell build replaces it later.
3. **Cast builds.** Recommended: generate each living cast member's build at their authored realm, sect, rank and
   elements, with a stable key per person, marked as stand-ins (the GDD's own fallback in Open Question 4).
4. **Travel time.** Routes are short: the 196 routes average a fraction of a season (a 9.7-tile trunk road is about
   0.2 seasons by Formula D), while the game charges whole seasons per link. Recommended: `travel <place>` goes to any
   reachable place along the quickest path, takes Formula D's time, and spends ceil(T) seasons with the last
   part-season cultivating (rule 12). The alternative, one whole season per hop, would make crossing the continent
   many times slower than Formula D.

## 3. How (if the recommendations are taken)

The seam: keep the World DB record shapes that the game already reads, and replace only the world's source.

1. **Export** (`tools/design/world/export_world.py`, the `export_game.py` pattern): `design/world/*.json` plus the
   continent layers go to `assets/data/world_history.json` (sects with start state, cast, chronicle and annals,
   records, legendary items, territory, hidden slots and tile secrets). `--check` runs the GDD's Checking list (ids
   resolve; nobody acts after death or below the realm's minimum age; no war before a founding; every slot has an
   origin event; one living leader per sect; `K_r <= T_r(3,000)`; F1 settle levels; loyalty above 30; candidate sets
   disjoint). `export_continent.py` also writes per-place density, element shares and danger (decision 2), the ruins
   and promoted cities, and the slot candidates. Runtime never reads `design/`.
2. **Builder** (`WorldBuilder`, replacing `WorldGenerator`'s three steps, in the GDD's nine-step order):
   - base: regions and places from `ContinentData`, in today's shapes, with a type map from the 14 place kinds to the
     game's place types; links from routes, carrying Formula D's time;
   - the 29 sects, then the chronicle and annals into the event log (canon `text_vi`, years 0-1,200);
   - the cast, then the seeded rolls (Formula C keyed picks into a hidden ledger table);
   - the random fill by Formulas A-B, with the join year by Formula D;
   - the named items (authored holders first, rule 20d for the rest), the Power Rankings start, and the player by
     origin (the sect seat, the market or the clan town, chosen from the approved lists).
3. **Travel:** quickest-path travel with Formula D and partial seasons (decision 4); `map` and the debug views read
   the continent.
4. **Saves:** a new game builds the new world. An old save keeps the random world it holds: the record shapes are
   unchanged, so it still plays. The save records the map and data versions (Core Rule 13).
5. **Checks after the cut-over** (blocking):
   - census at 5,000 people;
   - autoplay lives against 70/71/33/23 % (place density and travel time both move the arrival age);
   - fight lengths;
   - world generation within 30 s;
   - the suite green, with seeded world fixtures fixed rather than loosened;
   - a debug-terminal run kept as evidence.
6. **Not touched:** `design/gdd/*` (the parallel session's files; changes needed there are listed for the user).
   Commits name their own paths only.

## 4. Steps (one commit each, suite green at each)

1. Per-place qi and danger in `export_continent.py`, with its map-target check.
2. `export_world.py` with `--check`, and `world_history.json`.
3. `WorldBuilder` steps 1-4 (base, sects, history, cast), with tests.
4. Steps 5-6 (seeded rolls and ledger, random fill), with tests.
5. Steps 7-9 (named items, rankings start, player by origin); switch the new game over to the builder.
6. Quickest-path travel with partial seasons; debug views.
7. Balance and performance checks; evidence; GDD follow-ups listed.

## 5. Order for the decided scope (one commit each, suite green at each)

**Phase A: the land (Travel & Map Formula C, rules 1-5)**
- A1. `tools/design/map/land_qi.py`: Formula C on the fine map (2,160 x 1,440 cells from `base/fine_*.png`, the
  tile feature layer, and `sacred.json`'s veins, summits, caves and miasma). Depth by chamfer distance, blending by a
  box mean over a summed-area table, feature pushes by distance. Per tile part: the five base shares, the variants,
  density and danger. Parameters (P_b, sigma_b, g_D, g_X, x_b, A_f,e, R_f, a_f, x_f, o_kind, the derived-feature
  thresholds) go in a new data file `assets/data/world_map.json`, as the GDD's first guesses. o_kind is set to meet
  Formula C's map targets, and `--check` reports those targets (observations).
- A2. Export the per-part qi as a binary layer beside the grid (`ContinentGrid` reads it) and the per-place values
  into `world_continent.json`, including the ruins, promoted cities and slot places.
- A3. The game reads them: the stat block (rule 7); Formula A element match into the cultivation rate (rule 5); the
  four-layer stack (Formula B, rule 27) as far as its layers exist.

**Phase B: the world (World Generation & History, all nine steps)**
- B1. `tools/design/world/export_world.py` plus `--check`, writing `assets/data/world_history.json`.
- B2. `WorldBuilder` steps 1-4 (base, sects, chronicle and annals, cast).
- B3. **The 54 cast builds, hand-authored** in the NPC Build Generation format and run through its validator (the
  techniques, arts, gear and Đạo Đồ nodes for each person, in batches by sect). Reviewed by the user once all are
  written, as with the tree content.
- B4. Steps 5-6: the seeded rolls into the hidden ledger, and the random fill (Formulas A-D).
- B5. Steps 7-9: named items, the Power Rankings start, the player by origin. The new game switches to the builder.

**Phase C: moving and knowing (Travel & Map rules 9-17, 28-30)**
- C1. Route travel: quickest path, Formula D, part seasons and leftover cultivation (rule 12), and teleport arrays
  with Formula K's fee (rule 11).
- C2. Wilderness travel across tiles, rivers and boats, sea lanes, and flight with its drain.
- C3. Encounters on the way (Formula E, rule 13), through the Event Engine.
- C4. Knowing the map: each character's known tiles, and sight (rule 14).
- C5. Hidden places, clues and search (rules 15-17, Formula F); blessed lands (rule 28); tile secrets and finding
  them (rules 29-30).

**Phase D: what the land gives (rules 18-26, 31-34)**
- D1. Herb fit (Formula G) and resource sites (rules 19-20).
- D2. Production (Formula H), reserves (Formula I), and the seasonal production contract (Formula L) at its
  hand-off to Regional Economy.
- D3. Regions and territory (rules 23-24), and change (rule 26).
- D4. Works on the land (Formula J, rules 31-32), cave abodes anywhere (rule 8).
- D5. Developed ground, homes for rent or sale, and where NPCs live (Formula M, rules 33-34).

**Phase E: checks.** The census; autoplay lives against 70/71/33/23 %; fight lengths; world generation within
30 s; Travel & Map's acceptance criteria and map targets; debug-terminal evidence; the list of GDD follow-ups for the
user.

Systems the map only hands off to (the Sects redesign, Regional Economy & Trade, Trade Goods) stay out of scope.
Where Travel & Map needs them, it writes to the hand-off point named in its Interactions table.
