# Provinces in the running game: plan (2026-11-24)

**Status:** PLAN. Stage 0 done 2026-11-24: ADR-0008 accepted (`docs/architecture/adr-0008-provinces-as-world-records.md`)
and D1, D3–D7 answered (table below). Nothing of Stages 1–9 is built yet.

**Asked:** the user asked for "a plan for 2": provinces in the running game. Its records, buildings, population and
production become live, and the approved site growth ("grows through buildings") sits on top.

**Design:** the Provinces GDD (`design/gdd/provinces.md`, approved, with the 2026-11-24 deltas) and Regional Economy &
Trade (`design/gdd/regional-economy-trade.md`, approved revision #43).

## Where things stand

- **Data only:** provinces are data today. `assets/data/world_provinces.json` holds 705 records, but its stats are a
  one-off bake. `tools/design/map/province_stats_v2.py` computes them from a seed-7 dump with Provinces F1–F6, and its
  numbers (starting buildings, capacity and infrastructure per building, slots) are constants in that Python file. The
  panel (`ProvinceWindow`, `GameQuery.province`) shows this bake, and nothing in the game changes it.
- **The economy's unit is the region.**
  - `MapProduction.season` publishes `production_value` per region.
  - `WorldEconomy` reads it, with access by distance (`_hub_distance`).
  - The approved designs want the province instead, with access from infrastructure (F6, RE&T Formula A).
- **"Works" are per place.**
  - Layer-2 works are built and kept up per place: `MapWorks` (`assets/data/map_works.json`) and `SectWorks`, called
    from `WorldMoney.season`.
  - Provinces rule 8 says province buildings **are** those works, one catalogue. Running both would count a site gain
    twice (Provinces OQ 9).
- **Tick order (measured).** `WorldTicker.tick` runs `MapProduction.season`, then `WorldEconomy.season`, then
  `WorldMoney.season` (which holds the sects' works upkeep and building), then `SectPolitics.season`. Provinces rule 13
  wants the province step after the Sects tick and before the economy, but here the sects spend after the economy.
- **Sites that can grow (measured).** The 175 kept new sites start at grade minor. Their land caps them:
  - 145 sit on small land, so they can grow only one step (minor to small);
  - 20 on medium land, 10 on large.
  - 83 lie in wilderness provinces, which mostly have no matching building (a wilderness province starts with mine
    works only if it has a mine).
- **Saves.**
  - A save with another `map_version` is refused (`GameSession.load_dict`).
  - The provinces-v2 merge did not change `map_version` (the grid and qi files are unchanged), so a save made before
    the merge still loads, with the old 254-place world.
  - A new `provinces` table needs either a migration on load (as `Ties.migrate` does) or a refusal of older saves.
- **Budget.** A season costs about 459 ms (census at 5,000 cultivators, 2026-11-24 baseline). AC-PV-24 gives the
  province step 5 ms *(guess)*.

## Stages

Each stage is one or two sessions, closes the named ACs, and ends with a measurement against the baseline (census
seeds 7, 101 and 202; `world_sim` seeds 11–13; the season time). Files marked **shared** are also edited by the
UI-windows session; coordinate before touching them.

### Stage 0: decisions and one ADR (done 2026-11-24)

- **ADR-0008, "Provinces as world records and the economy's unit":**
  - the `provinces` table in WorldDB and in saves (migration or refusal);
  - the place-to-province link;
  - the tick insertion point (decision D1);
  - the contract switch from regions to provinces, with a shadow period (Stage 1) before the switch (Stage 6).
- **User decisions D1–D8** (below). Stages 2, 3 and 6 wait on them.

### Stage 1: live province records, in shadow

**Done 2026-11-24 (uncommitted at writing):** `src/gameplay/world/provinces.gd` (table `provinces`, ids `v<n>`; every
place's `province_id`, the 5 lakes by nearest land tile; F1 goods fixed at the first season, F2 routes fixed at build,
F4 production, F5 slots), `assets/data/provinces.json` (knobs, `provinces_version` 1), the hook in
`MapProduction.season` (the same values by province), the step in `WorldTicker.tick` and `WorldBuilder.generate`,
saves without `provinces_version` refused, `GameQuery.province` overlaying the live values. Tests
`tests/unit/world/provinces_test.gd` (8). Full suite 1042/0; the shadow census is identical to the Formula H run on
seeds 7, 101, 202. **D8 measured:** the step averages 4.96 ms a season (worst 7.35 ms), so AC-PV-24's 5 ms holds.
The Python bake stays as it is (the panel's fallback for buildings, infrastructure and access until Stages 2 and 6);
the planned split of `world_provinces.json` into shape and start stats was not needed.
**Found:** 15 border places (mostly mines and peaks) lie in a province of a neighbouring region, so province and region
sums agree only continent-wide. **Owed before Stage 6:** decide whether those places follow their province's region.

- **Build:** WorldBuilder builds a `provinces` table from the static shape (split `world_provinces.json` into shape
  and start stats). Every place record gets its `province_id`. Today only the new places carry a province key; the
  authored ones are listed in `provinces.json`, and 5 places sit in none.
- **Formulas:** F1 (potential, main good), F2 (wilderness share by border), F4 (production) and F5 (slots) move to
  GDScript (`src/gameplay/world/provinces.gd`, knobs in `assets/data/provinces.json`).
- **Tick:** a province step runs each season and publishes the per-province contract beside the region one, which
  the economy still reads.
- **Python tool:** `province_stats_v2.py` stays only as a seed-7 parity fixture, so F1–F6 have one live copy.
- **Panel:** `GameQuery.province` (**shared**) reads the live record.
- **Exit:**
  - a property test: the provinces' production sums to the regions' totals every season;
  - census and sim unchanged (shadow);
  - the province step's time measured (OQ 5).
- **ACs:** PV-01 (counts 705 / 468 / 237; GDD text to update), PV-02, PV-03, PV-04, PV-08, PV-11–PV-14, PV-17,
  PV-22, PV-24.

### Stage 2: the building catalogue, states and starting buildings (the risky stage)

**Built 2026-11-24 (under the user's delegation):** `assets/data/province_buildings.json` (every kind from the
catalogue spec; `live` false for kinds whose effect comes in a later stage: logistics, society and the sect halls are
placed for slots but not billed, ordered or projected) and `src/gameplay/world/province_buildings.gd`. The province is
the record of truth; each season `ProvinceBuildings.project` writes every live building's effective level as a Travel
& Map work (`by: "province"`) at the places it acts on, so Formula B, match and `G_f` read it unchanged and a player's
own abode works are left alone (user, 2026-11-24: keep them as today). States: building (an upgrade counts at the built
level), active, unpaid (upkept 0, permanent kept), ruined after `ruin_seasons` 4. `SectWorks` now orders province
buildings (same value-per-stone rule, same saving) and pays their upkeep in D3's order. No migration was needed: a new
world has no place works and older saves are refused (`provinces_version` 2). Panel: `GameQuery.province` lists the
live buildings (the window still shows level pips only; states are a Stage 8 item for the UI session).

- **Catalogue:** the building catalogue becomes data, `assets/data/province_buildings.json` (kinds, levels 1–5, cost,
  build seasons, upkeep, effects, the track that caps each kind). It is drafted from `map_works.json` and the Python
  constants (D2).
- **States:** the state machine from the GDD's States table: Planned, Under construction, Active, Unpaid, Ruined and
  Cancelled, with `ruin_seasons`.
- **Starting buildings:** placed at world generation by rule 10's table (approved 2026-11-24), plus the main good's
  building, landings and wilderness mine works.
- **Migration to one catalogue:**
  - Each place's layer-2 works, and its `prebuilt` density, become buildings of its province (D6).
  - Formula B's layer-2 density at a seat reads the province's buildings (gathering arrays).
  - `SectWorks` builds through the province (Stage 4).
  - `MapWorks.production_gain` stays the single site gain (OQ 9).
- **Exit:**
  - the census is unchanged within noise (density feeds cultivation);
  - no double counting (a property test over a site's gains);
  - old works are gone from the place records.
- **ACs:** PV-05, PV-06, PV-07, PV-10, PV-20, PV-28, PV-30, PV-31.

### Stage 3: site growth (approved rule 8 bullet)

**Built 2026-11-24** (`ProvinceBuildings.grow_sites`, committed 30913185): a minor site stands a grade higher a level
above 1, up to its land's grade, keeping its reserve fraction (D5a), and follows its building down. Wilderness sites
grow once a holder orders the outpost (D5b: sects can now order buildings in the wilderness slot). **Found:** with
sects raising mine works, site growth roughly doubles stone minting over 100 years (money +60-95 %, growth still
+0.7-0.9 % a year) - for the user at the Stage 6 stop. Lore starting levels (user request) apply to every group but
production, which starts at 1.

- **Rule:** a kept site's grade rises one step for each level of its province's matching building above level 1,
  capped by its land grade (`grade_by_density`). Most sites reach small at level 2 and stop there.
- **Open (D5):** what happens to the reserve on a step up, and what the 83 wilderness sites with no building do.
- **Exit:** a unit test over the step table; the sim shows mine output rising only as buildings rise.
- **ACs:** a new AC owed in the GDD (the rule 8 bullet has none yet).

### Stage 4: sects build province buildings

**Built 2026-11-24** (b3844431): halls live with their hooks (stat sheet rows, Talismans' sheet term, market crafted
success per region, technique tier, breakthrough step, intake); sects value halls by members and repair ruins at half
price. Hóa Thần 5-8 in the census against 4-6 before (the chamber; Stage 9 knob).

- **Who builds:**
  - The holding great sect orders buildings by expected return, within its track caps (rule 9, D4).
  - A local lord builds in its seat province.
  - Upkeep is paid as `works_due` in `WorldMoney` (rule 9); this replaces `SectWorks.build_best` per place.
- **Exit:** a sim on three seeds (the money band, the works spending against the baseline, sect wars and treasuries);
  the province step plus building stays inside its budget.
- **ACs:** PV-05 (with a sect), PV-06 and PV-28 (live).

### Stage 5: population (F3, once a year)

**Built 2026-11-24** (5232e7f0): F3 yearly with workforce following P / P0 (settlement output and W_set read it);
granaries live. 200 years: dips to x0.85-0.93, recovers to x1.08-1.15, never above capacity.

- **Rule:** growth toward capacity while fed and safe, famine below `famine_cover`, war and beast tides; granaries
  raise capacity.
- **Economy:** population feeds the settlement demand weight `W_set` (RE&T Formula C) and building staff (OQ 8).
- **Exit:** the yearly step is stable over 200 years (no collapse, no runaway); the cultivator census is untouched
  (mortals only).
- **ACs:** PV-15.

### Stage 6: access and the economy's switch to provinces

**Built 2026-11-24, uncommitted at writing:** F6 in `Provinces._access` (infra0, road and river tiles, `infra_old`
fixed at the first season for the 0.5 floor, logistics buildings live; usage against `D_loc` = the region's demand
shared by population); the 15 border places follow their province's region and holder (user decision); the economy
reads province production x access x the region's safety (`economy_reads_provinces`, false restores the old
reading); sects value logistics by the access rise. F6's constants needed no rescale (live province production:
median ~130-160, p90 ~1,500-2,000, max ~13-17k). Owed: local prices drifting below access 1 (revised L1).

- **F6:** infrastructure (land, logistics buildings, `infra_old`), usage (exports above `D_loc` plus imports, from
  last season's `D_loc`) and access.
- **Switch:** `WorldEconomy` reads production times access per province (RE&T revised A, B and L1) instead of region
  `production_value` and `_hub_distance`. Local prices drift below access 1.
- **Exit:**
  - the full sim on three seeds against the baseline: the money band, prices against their 0.9–1.15 band, the share
    of provinces under 0.5 access;
  - the RE&T harness checks named in its OQ 19.
- **ACs:** PV-18, PV-18b, PV-19, PV-21, PV-23, PV-29, and the RE&T ACs that read access.

### Stage 7: modifiers, events and states

**Built 2026-11-24** (5fcbad47): modifiers (stat, scope, inc or more, seasons, source) in F4, F6 and F3; blight, raid
and beast tide from a seeded stream with walls softening raids and tides; the four states; news lines. Spirit-stone
sites never grow (user decision): money back to ~5.4M at 100 years.

- **Modifiers:** province modifiers in the Modifier grammar, each with a source and a duration, one panel line each
  (rule 12).
- **Events:** event hooks (blight, raid, beast tide) and the Normal, Under-connected, Struck and War-touched states;
  news lines.
- **ACs:** PV-09.

### Stage 8: the player and the panel

**Built 2026-11-24/25** (82563ca8; done in this session at the user's request): `fund_building`, `province_orders`,
the live panel (building states, orders with Fund, states, modifier sources, live access line), the map modes on live
numbers; screenshots in `production/qa/evidence/provinces-runtime/stage8/`. **Owed:** AC-PV-27's 20-season playtest
(the user's), player trade between provinces at province prices (needs revised L1's local prices).

- **Player:** the player funds a building through a sect or city mission (rule 9) and trades between provinces
  (RE&T rule 16).
- **Map:** the province map modes (Development, Goods) read live records, and the panel shows building states and
  modifiers.
- **Files:** `map_screen.gd` and `game_query.gd` (**shared**).
- **Exit:** screenshots of the panel and map modes; a 20-season playtest (PV-27).
- **ACs:** PV-10, PV-25, PV-26, PV-27.

### Stage 9: balance and tidy

**2026-11-25:** chamber 0.005 a level, beast lairs two levels a grade step; GDD deltas written (Provinces AC-PV-01,
rule 13's lag, OQ 3 and 4, rule 10's lore levels, stone sites, shocks; Canh-gioi rule 12's Formula H back-link).

- **Balance:** a balance pass on every *(guess)* number (OQ 1) on seed 7, then three seeds.
- **GDD text:** update AC-PV-01 to 705 / 468 / 237 and close OQ 3 and OQ 4 (both answered 2026-11-24), each as a
  delta for the user's approval.

## Decisions owed by the user

| # | Decision | Recommendation | Answer (user, 2026-11-24) |
|---|---|---|---|
| D1 | **Tick order.** Rule 13 puts the province step after the Sects tick, but in code the sects spend after the economy. Reorder the tick, or run the province step before the economy and let sect orders and upkeep take effect the next season (a one-season lag). | The one-season lag, and amend rule 13. Reordering moves money flows that are already tuned. | One-season lag; rule 13 amended later as a delta. |
| D2 | **Building catalogue numbers** (OQ 2): cost, build seasons, upkeep and output per level. | Claude drafts them from `map_works.json` and the Python constants; the user approves the table. | Open: Claude drafts the table. |
| D3 | **Staff and upkeep priority** (OQ 8): staff pooled across a province's buildings or per building; which unpaid buildings go first. | Pooled staff; production buildings kept up first. | Pooled staff; production buildings paid first. |
| D4 | **Cap mapping** (OQ 10): "pavilions" (name the kind or drop it); granary under Holdings and great-project stages under Institutions (both provisional). | Drop "pavilions"; keep the two provisional mappings. | Pavilions dropped; and **no caps at all**: tracks price levels (×2 per level above `free_level = ⌈T/2⌉`), buildings and abode works have no highest level (GDDs amended). |
| D5 | **Site-growth gaps:** (a) on a step up, does the reserve keep its fraction of the new max; (b) the 83 kept sites in wilderness provinces have no matching building: start them with an outpost, let the holder build one (wilderness slot 1), or leave them minor. | (a) keep the fraction; (b) the holder may build the outpost, nothing at the start. | (a) keep the fraction; (b) the holder may build the outpost, nothing at the start. |
| D6 | **Migrating existing works:** today's per-place layer-2 works and `prebuilt` density become province buildings one to one, keeping their gains. | Yes, one to one. A census check guards it. | One to one for works; **prebuilt density is not migrated** but stays a land line (Provinces rule 10). Spirit grove, qi channel and vein dressing are their own kinds (rule 8). |
| D7 | **Old saves:** migrate (build the provinces table, and the 1,240 new places, on load) or refuse saves made before provinces (bump the data version). | Refuse. The game is a prototype, and a migration of the whole world is costly to keep. | Refuse old saves. |
| D8 | **Season budget** (OQ 5): AC-PV-24's 5 ms. | Measure in Stage 1, then set. | Measured 2026-11-24: 4.96 ms mean, 7.35 ms worst; keep 5 ms. |

## Also decided 2026-11-24 (outside the stages)

- No mortal/cultivator split: one building catalogue; abodes stay their own system (Cave Abode).
- `D_cap` and `prod_mult_cap` removed; the layer-2 effect caps removed; `settled_density_cap` kept for villages, towns,
  markets and cities only. Built so far: `D_cap` and layer-2 density caps (code); the rest is owed to Stage 2 (see
  `production/session-state/active.md`).
- Living World Tick Formula H built (NPC stage speed by root and the stacked density of their seat or home), so
  province cultivation buildings speed NPC members. Open: the densest sect shrinks (trace, then recruit weighting by
  seat appeal, Sects F17).
- Gap 2 + 5 next: sect halls per craft (and a scripture pavilion) in the Cultivation group, replacing the generic
  workshop, once crafting and sect hooks are checked.

## Risks

- **Stage 2 touches cultivation.** Formula B density at seats comes from layer-2 works, so a wrong migration moves
  every NPC's cultivation rate. The census baseline is the guard.
- **Stage 6 is the biggest balance change** (the economy's unit and access). Prices already sit outside their band
  for ore, special goods and pills in the baseline, so judge by the change, not by the band.
- **Shared files:** `game_query.gd` and `map_screen.gd` with the UI-windows session.

## Note for this session: the world-depth seat moves (2026-11-26, done by the world-depth work)

The provinces session was not running, so the user ruled that the world-depth work makes the provinces changes the
seat moves need (`design/world/depth/DECISIONS-2026-11-26.md`, Stage 2; Provinces rule 2a, extended 2026-11-26).
- `tools/design/map/province_stats_v2.py`: `sect_hall` ranks like a town (seat rank, base slots, infra0, starting
  buildings); a moved seat's province takes it as its seat place (`seat_place_of`, moved seats only); a moved seat
  in no province (Lễ Tuyền's lake, 193) takes its nearest land tile's province.
- `ProvinceBuildings.payer`: a great seat at the province's seat place makes that great sect the payer (as a minor
  seat already did), for Phượng Minh in `prov_phan_vu`.
- `place_start` needed no change: it already reads the seat province from the sect's seat place.
- Data: `sect_hall` added beside `town` in `provinces.json` (base_slots, infra0) and `province_buildings.json` (start,
  landing_seats).
- **Fixed (user ruling 2026-11-26, its own commit):** 12 provinces held an unmoved minor seat that was not their seat
  place (prov_p146, p151, p46, p66, p82, p92, r14_12, r1_22, r20_3, r2_24, r3_13, r6_3), so that minor sect was not its
  province's payer and its seat-kind buildings acted at the village, town or nowhere. `seat_place_of` now seats every
  sect-seat province at its seat (a moved seat first); test `test_every_minor_seat_province_is_seated_at_and_paid_by_its_sect_rule_9`.
