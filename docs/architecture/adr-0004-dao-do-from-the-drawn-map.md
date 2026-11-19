# ADR-0004: Đạo Đồ from the Drawn Map

## Status
Accepted (2026-11-19, by the user). Drafted the same day by the assistant from the user's four decisions at the start
of the loader session (`production/plans/dao-do-v5-loader.md`). The Ice start's figure scales as Water land (it is
counted in Water's region), the Wind start's figure by Wind (AC-KMD-15).

## Date
2026-11-19

## Last Verified
2026-11-19

## Decision Makers
The user (the four decisions below and every Đạo Đồ rule in `design/gdd/dao-do.md`), with the assistant drafting.

## Summary
The game stops generating its passive tree and loads the hand-drawn v5 map with its filled content from one exported
data file. Purity becomes a float with no cap, road purity is kept apart from the owned elements, scoped tree
modifiers reach the fight with their scopes, and the tree's keystone and crown Effects run in the fight engine (both
engines, extended where the vocabulary lacks a primitive). The generator, the hidden clusters, the unseal flow and the
variant sectors are retired, and old saves are migrated once.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (4.7.1 installed) |
| **Domain** | Core (data loading), Gameplay |
| **Knowledge Risk** | LOW: `FileAccess`, `JSON` and `Dictionary` only, as every other data file |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`; ADR-0001 (fight engine, build files); ADR-0002 (streams) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | Load time of the 8,057-node file and the NPC allocator budget (AC-KMD-54) measured headless |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (the fight engine and `BuildFileCompiler`, which the tree Effects extend in both engines with parity), ADR-0002 (the NPC allocator's random term is drawn from the NPC's stream) |
| **Enables** | Builds on the designed tree; the Power Rankings calibration re-run; the side trees |
| **Blocks** | Nothing |
| **Ordering Note** | Accept before the loader cut-over commit |

## Context

### Problem Statement
The tree the game builds (`DaoDoGenerator`, about 1,300 nodes, hidden clusters, variant sectors) is not the tree that
was designed. The designed tree (the v5 frozen map, 8,057 nodes, and its content, 7,295 Dao marks) exists only in
`design/`, which the game never reads.

### Constraints
- Rule 19: from this baseline every Dao mark keeps its id and position forever; content is append-only.
- The game reads `assets/data/` only.
- `design/gdd/*` and the registry are edited by a parallel session.
- The fight engine has two implementations (`tools/design/combat_sim/fight.py`, the design tool, and
  `src/gameplay/combat/fight/`, the game) kept in parity.

## Decision

1. **One export file.** `tools/design/dao_do_rework/content/export_game.py` writes `assets/data/dao_do_map.json` from
   the v5 map and `design/dao-do/content/*.json`: every node with its id, position, kind (`start`, `road`, `small`,
   `notable`, `keystone`), name, gate, its scaling area (an element, a border pair, a variant, the Chaos land, or exact),
   a road's granted elements (shares of `road_purity`, which stays a data knob), its modifiers `{stat, value, w,
   scope}`, pending lines, capability, Effect and closing; the edges; the starts by element or variant. Its `--check`
   compares counts and areas with the GDD and runs the drawing checks (AC-KMD-60). Map and content hashes are carried
   into the file. `assets/data/dao_do_tree.json` keeps only the rule constants that still apply.
2. **Float, uncapped purity.** `LinhCan` purities become floats with no 100 cap (shown rounded). Birth draws and the
   Tẩy Tủy Đan still stop at 100, as the GDD says. Purity granted by roads is stored apart (`road`, by element or
   variant) and added on read, so a road never makes the root own an element; derived variants read their parents'
   full purity. Saves migrate (ints read as floats; no road purity).
3. **Effects run, extending the runtime.** Each tree Effect gets an engine form in a data file of the same shape as
   `combat_effects.json` (records, `static`, `not_run`), loaded by a build-file field naming the Character's held tree
   Effects, in both engines. A primitive the vocabulary lacks is added in one commit per primitive: `engine.py` /
   `fight.py`, the GDScript engine, `combat_engine.json` and a parity case. An Effect whose host system does not exist
   (spirit fields, seasons, pills, talisman stock) loads as **Pending**: shown, adding nothing, listed in a report.
   Each numeric closing goes through one channel only (a `static` line of its Effect).
4. **Scoped modifiers keep their scopes.** The stat sheet holds scoped lines apart from its totals; the fighter build
   file receives them with their scopes, as item affixes are.
5. **The cut-over** replaces `DaoDoTree.generate` with `DaoDoTree.load`, keeps the query API (`node`, `neighbors`,
   `accessible`, `frontier`, `can_allocate`, `path_to`, `node_value`, `node_scale`, `collect_mods`, `describe_mods`,
   `size`), removes `ROOT_ID` (a Character holds its start), and retires the generator, hidden clusters, unseals,
   variant sectors and their data, views and tests in the same change, since none of them has data on the new map.
6. **Save migration** keys on a map-baseline marker in the save (`tree_baseline: "v5"`), never on "id not in the map"
   (both baselines start at id 0): an old save's open Dao marks are refunded as points and a start is chosen.

### Key Interfaces
- `DaoDoTree.load(gd) -> DaoDoTree`; `starts_for(lc) -> Array`; `npc_start(lc) -> int`; `gate_open(lc) -> bool`;
  `open_node(c, id, gd)` (applies road purity and capabilities); the existing query API above.
- `LinhCan.purity(id) -> float` (owned + road), `LinhCan.add_road_purity(id, amount)`.
- `StatSheet.add_mod(source, stat, value, kind, scope)`, `StatSheet.scoped_lines() -> Array`.
- Build-file field `tree_effects: [name]` (both engines).

## Alternatives Considered

### Alternative 1: read `design/` at run time
Rejected: the game never reads `design/`, and the content files are an authoring format (W columns, ideas, twins).

### Alternative 2: integer purity with a fractional road counter
Rejected by the user: the GDD requires fractional, uncapped purity.

### Alternative 3: load uncompilable Effects as Pending without extending the engine
Rejected by the user for combat Effects; kept only for Effects whose host system does not exist.

## Consequences

### Positive
- The game plays the designed tree; tree builds can be tested in fights.
- The tree's Effects become part of the shared engine vocabulary.

### Negative
- A large change across purity, the sheet, the allocator, the terminal and saves.
- Two engines to extend for each new primitive.

### Neutral
- NPC power changes with the new tree; the Power Rankings calibration is re-run afterwards.

## Risks
- **Performance:** 8,057 nodes against 1,300; the allocator runs for 5,000 world NPCs (AC-KMD-54).
- **Float ripple:** many systems read purity as an int.
- **Effects coverage:** some Effects stay Pending until their host systems exist.

## GDD Requirements Addressed
`design/gdd/dao-do.md` rules 1, 3, 4, 5, 16-20 and its Known gaps; `design/gdd/linh-can.md` rules 8, 8a, 10, 12;
`design/gdd/effects.md` "Đạo Đồ Effects (content pass, 2026-11-19)".

## Migration Plan
The steps and acceptance criteria are `production/plans/dao-do-v5-loader.md`, with the plan's steps 2-3 and the
retirement in step 13 merged into the cut-over (decision 5), and step 8 (Effects) last, as its own series.

## Validation Criteria
The plan's acceptance criteria pass; the suite is green after every commit; a session transcript on the v5 map is kept
in `production/qa/evidence/dao-do-v5-loader/`.

## Related
ADR-0001, ADR-0002, ADR-0003; `design/dao-do/cells/versions/v5-frozen-2026-11-19/README.md`;
`design/dao-do/content-decisions.md`.
