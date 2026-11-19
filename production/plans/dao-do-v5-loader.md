# Plan: put the designed Đạo Đồ (v5) into the game

Prepared 2026-11-19 at the end of the content session, for the next session. The user's word: "let's do it in the next
session, please prepare for it". Start that session with: **"build the Đạo Đồ map loader from the plan"**.

## Why

The game still builds the old generated tree (`src/gameplay/dao_do/dao_do_generator.gd`, about 1,300 nodes, hidden
clusters, variant sectors, `assets/data/dao_do_tree.json`). The tree we designed (the v5 frozen map plus its filled
content) exists only in design files and the viewer artifact. This work makes the game load and play the designed tree,
with all the rules decided for it, and retires the generator.

## Read first (in this order)

1. `production/session-state/active.md`, the last entries (2026-11-19 late).
2. `design/gdd/dao-do.md`: rules 1-5, 16-20 and **Known gaps in the build** (the gap list), Formulas A2, B, E, F, the
   Acceptance Criteria named below. Read by section (Grep `^#`), the file is large.
3. `design/gdd/linh-can.md` rules 8, 8a, 10, 12 (purity, road purity, parent purity, parents' lands).
4. `design/gdd/effects.md` section "Đạo Đồ Effects (content pass, 2026-11-19)" (33 keystone records, 12 crown Effects, 5
   starter keystone variants) and the starter catalogue.
5. `design/dao-do/content-decisions.md` (#1-33) for the calls already made.
6. `design/dao-do/cells/versions/v5-frozen-2026-11-19/README.md` (the map and its two amendments).
7. Code: `src/gameplay/dao_do/dao_do_tree.gd` (the API every caller uses), `build/build_generator.gd` (NPC allocator),
   `session/game_session.gd` (allocation, unseal events), `character/character_factory.gd`, `character/stat_sheet.gd`,
   `world/world_generator.gd`, `debug_terminal/terminal_views.gd` (the `tree` views), `combat/fight/effect_*.gd` and
   `assets/data/combat_effects.json` (the Effect runtime the keystones must use).

## What exists (facts checked 2026-11-19)

- **Map data:** `design/dao-do/cells/versions/v5-frozen-2026-11-19/dao-do-map.json`: 8,057 nodes (751 road, 5,493 small,
  1,759 notable, 43 keystones, 11 starts), 906 clusters, edges with optional `arc`. Node fields: `id x y kind region
  cluster name theme` and `gate: "chaos"` on 817 nodes. Regions: five lands, `border*`/`blend*` lines, `hub`, `chaos`,
  `island` with `light`/`thunder`/`darkness` start figures.
- **Content:** `design/dao-do/content/<area>.json` (15 areas), keyed by node id: `kind piece name mods [[key, scope, W,
  value]] pending cap effect closes`. Compiled by `tools/design/dao_do_rework/content/build.py <areas> --all`
  (**name the areas**: with no argument it builds nothing). Road nodes carry no content: rule 4 sets them (land road
  +0.5 own element, border road +0.25 each neighbour, hub road +0.5 each of the five).
- **Callers of `DaoDoTree`:** `GameSession` (`tree`, allocate, path, unseal flow), `BuildGenerator` (NPC greedy
  allocator, `_roll_unseals`), `CharacterFactory` (`tree_nodes = [ROOT_ID]`), `StatSheet.build` (`collect_mods`),
  `WorldGenerator`, terminal views, test fixtures and four performance probes.
- **Character state:** `tree_nodes`, `tree_points`, `capabilities`, `unsealed`, `discovered`, `open_unseals`,
  `tree_visibility` (saved in `character.gd` to_dict/from_dict).
- **Purity is an int** in `LinhCan.elements` and clamped 10/1-100 in several places. Road purity is fractional (0.5,
  0.25; AC-KMD-102 uses Fire 30.5) and uncapped (linh-can.md rule 8, since 2026-11-10). Both are a change of type.
- **Effects runtime:** the fight engine compiles records like `assets/data/combat_effects.json`
  (`on`/`do`/`mod`/`static`, 54 records). Tree Effects need records in that vocabulary; some are not combat
  (Spirit Garden: field growth; Sun That Never Sets: đạo tâm per season; Alchemist's Heart: pills) and belong to other
  systems.
- **Suite:** 466 GdUnit cases green at commit 365c4e3. Run:
  `"C:/Godot/Godot_v4.7.1-stable_win64_console.exe" --headless -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests --ignoreHeadlessMode`
  (about 3 minutes).

## Decisions to confirm with the user at the start (recommendations first)

1. **Game data file:** export the map and content into one game file, `assets/data/dao_do_map.json`, with a script in
   `tools/design/dao_do_rework/content/` (the game never reads `design/`). Recommended.
2. **Fractional, uncapped purity:** change `LinhCan` purities to floats with no 100 cap (display rounded), migrate saves.
   The GDD already requires both; this is the largest ripple (techniques, stacks, terminal, tests).
3. **Effects not yet runnable:** Effects the fight vocabulary can express are compiled; the rest load as **Pending**
   (shown, adding nothing) and are listed, rather than blocking the loader. Recommended.
4. **ADR-0004 "Đạo Đồ from the drawn map"** (rigor `standard` asks ADRs for critical decisions; this replaces a
   subsystem, its data format and the save shape). Recommended, short.

## Steps (each one commit, tests first, suite green before the next)

| # | Step | Done when (ACs) |
|---|---|---|
| 0 | ADR-0004; confirm the four decisions | ADR accepted |
| 1 | **Export** `dao_do_map.json` from the v5 map + content (nodes with final values, edges, starts, gate, keystone records, capability ids, road grants); a check script compares counts to the map | counts 8,057 / 43 / 817; AC-KMD-60 drawing checks pass on the export |
| 2 | **Loader**: `DaoDoTree.load(gd)` replaces `generate`, keeping the API (`node`, `neighbors`, `accessible`, `frontier`, `can_allocate`, `path_to`, `node_value`, `node_scale`, `collect_mods`, `describe_mods`, `size`) | AC-KMD-13, -14 |
| 3 | **Starts** (rule 3): pick any start the root holds; NPC picks its strongest element, cycle tie-break; `tree_nodes` holds the start id, not `ROOT_ID` | AC-KMD-96 |
| 4 | **Scaling** (rule 4): land marks 0.5 + purity/100 (0.25 + p/100 unowned), border marks the average, variant lands by the variant's purity, the Chaos land by Chaos purity or, for a gate passer without Chaos, its weakest element at the owned rate; keystones, hub and roads exact; parents' lands (already in `_element_scale`) | AC-KMD-15, -16, AC-LC-34, -58 |
| 5 | **Float, uncapped purity** and **road purity**: opening a road raises purity (land 0.5, border 0.25 each, hub 0.5 each of five, islands their variant); variants recompute | AC-KMD-97, AC-LC-56 |
| 6 | **Chaos land gate**: no open, no path, no frontier through `gate: chaos` unless Chaos or all five base elements > 30 | AC-KMD-102 |
| 7 | **Capabilities**: the 25 capability notables, `cap_realm_min` Core Formation, incompatibilities | AC-KMD-40 to -44, -100 |
| 8 | **Keystones and Effects**: plain side through the sheet; Effects compiled into the fight engine where expressible, the rest Pending and listed; closings as statics | effects.md records load; a list of Pending Effects |
| 9 | **Breakthrough curve** `k·ln(1+Σ/k)` on the summed tree breakthrough | AC-KMD-59 |
| 10 | **NPC allocator** on v5: greedy by kind scores and archetype focus, respects the gate; performance | AC-KMD-18, -54, -55 |
| 11 | **Saves** (rule 19): old generated-map saves load with 0 open Dao marks, points refunded, a start chosen | AC-KMD-51, -52, -98 |
| 12 | **Terminal views**: `tree`, `tree node`, `tree alloc/go/targets` on v5 (regions, gate, keystones); remove unseal and hidden-cluster views | AC-KMD-56, -57; a session transcript in `production/qa/evidence/dao-do-v5-loader/` |
| 13 | **Retire** the generator, unseal flow, variant sectors and their data and tests; update the four perf probes | no reference to `DaoDoGenerator`; suite green |
| 14 | Close the GDD's Known gaps; update `active.md` and the memory | — |

## Risks to watch

- **Performance:** 8,057 nodes against the old 1,300; the NPC allocator runs for 5,000 world NPCs (AC-KMD-54 budget).
- **Float purity ripple:** many systems read purity as an int; change it in one step with its tests.
- **Effects coverage:** expect a sizeable Pending list; report it, do not invent runtime rules.
- **A parallel session** edits `design/gdd/*` and the registry: commit only your own paths (`git commit -- <paths>`).
- **Godot exits 139** after a scripted session that generates two worlds; it predates this work
  (`production/qa/evidence/linh-can-parent-purity/README.md`). A session with one world is a cleaner evidence run.
- **Balance:** today's Thunder/Ice/Chaos changes and the full tree content change NPC power; the calibration in
  active.md (median NPC win share by realm) needs a re-run afterwards.
