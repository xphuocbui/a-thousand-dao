# ADR-0009: The World-Depth Export

## Status
Accepted (the user, 2026-11-26). Based on the user's rulings of 2026-11-25, groups 1-14, and 2026-11-26: everything
goes into the game, no stand-ins at the end; D3 2026-11-26: records are promoted sect by sect; 2026-11-26: saves are
refused on a version number, not the content hash.

## Date
2026-11-26

## Last Verified
2026-11-26 (Godot 4.7.1; read against `tools/design/world/export_world.py`, `src/gameplay/world/cast_builds.gd`,
`world_builder.gd`, `game_session.gd` `load_dict`, `tools/design/items/export_named.py`, `export_techniques.py`,
`tools/design/combat_sim/export_combat_library.py` and `fight.py` `_library`, `assets/data/combat_effects.json`)

## Decision Makers
The user (rulings in `design/world/depth/DECISIONS-2026-11-25.md` and `DECISIONS-2026-11-26.md`, D3 2026-11-26), with
the assistant drafting.

## Summary
The world-depth content (`design/world/depth/`) reaches the game by two routes. People, builds, ties, beasts and dated
events go through `export_world.py` into `world_history.json`, which replaces the old 106-person cast with the 1,891
authored people plus the 18 fallen-sect people only the old cast has. Techniques, arts, items, sets and Effects are
promoted, sect by sect, into the design catalogues the existing exporters already read, so the game gains no second
record exporter. A new `world_data_version` integer refuses saves made on the old cast.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (installed 4.7.1) |
| **Domain** | Data pipeline (design tools), World generation, Persistence (saves) |
| **Layer** | Tools / Gameplay-World |
| **Knowledge Risk** | LOW: Python design tools and plain `Dictionary` / `JSON` data; no post-cutoff API |
| **Post-Cutoff APIs Used** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (one combat engine, `fight.py` as the source of `combat_library.json`; parity); ADR-0002 (random streams: a cast build's rolls key on the person); ADR-0004 (Đạo Đồ from the drawn map: route targets are its node ids); ADR-0006 (GameSession facade: `load_dict` refusals); ADR-0008 (the province records the moved seats link to, and the version-refusal precedent) |
| **Enables** | World-depth plan Stages 1-8 (`production/plans/world-depth-implementation.md`) |

## Context

### Problem Statement
The world-depth pass wrote 1,891 people, 180 techniques with 331 new arts, 490 items in 166 sets, about 340 Effects,
21 named beasts, about 264 dated events and 435 Đạo Đồ routes as design proposals. None of it is in the game. The user
ruled on 2026-11-26 that all of it goes in, and that generated stand-in techniques are not an end state.

### Current State (measured 2026-11-26)
- `export_world.py` reads only the top-level `design/world/*.json` (the 72-person `cast_proposal`, the records, the
  chronicle and annals, `cast_builds.json`) and writes `assets/data/world_history.json`: 106 people, 74 living, 54
  authored builds, 688 events.
- **The file is ahead of its sources.** A fresh export differs from the committed file in two events: A225 (the Phất Y
  founding, no poem) and C023 (Lôi Vô Danh dies of the miasma). Both user-approved texts were edited in
  `assets/data` only, so the next export would revert them.
- `data_version` is a 16-character hash of the top-level `design/world/*.json` files and the map inputs. It is written
  into the save's `w_meta` but never compared on load; `load_dict` refuses only on `map_version` and
  `provinces_version`. Nothing under `design/world/depth/` feeds the hash.
- `cast_builds()` fails the export on any technique, named item, base, talent or Đạo Đồ node the game data lacks, so
  record exporters must run before `export_world.py`.
- `CastBuilds._learn` drops an unknown technique id with no message.
- Of the 106 old people, 88 are in the depth cast and 18 are not (the dead founders and last heads of fallen sects).
  All 54 old builds' people are in the depth cast, and every one of them carries its own depth build with tree
  targets: 18 equal the old targets, 36 were changed in the depth pass. 15 keep the old main technique.
- Depth builds: 1,748 living, all with a build; 435 with hand-picked tree targets; 184 with a stand-in main.
- The catalogue exporters discover files by glob: `design/techniques/catalogue-*.json` (`export_techniques.py`,
  `fight.py`), `design/items/catalogue-*.json` (`export_named.py`, `fight.py`), `design/arts/family-*.json` and
  `part-*.json` (`fight.py` → `export_combat_library.py`).
- `assets/data/combat_effects.json` (109 Effects, keyed by plain English name) is hand-maintained, except the Đạo Đồ
  Effects that `tree_effects.py` writes. Items name their Effects by that key.
- Depth Effect names: 332 distinct. 2 equal an existing key (`Blood Casting`, `Still Water`); 4 names are shared by
  more than one item (`Know the Way Out` ×4, `Paid in Full` ×3, `Second Spring` ×2, `The Empty Mountain's Answer`
  ×2), three of them with one shared id.
- Sets, named beasts and the `N-` events have no route into the game.

### Constraints
- Another session edits `design/gdd/*`; the formations session owns `formations.md`; the provinces session owns the
  provinces runtime. Commits stage only this work's paths.
- Every fight feature and Effect lands in both engines with parity green (ADR-0001).
- Effects are hand-designed and unpriced.
- The game runs with no LLM: everything is authored data.

### Requirements
- One source per record kind, one exporter per game file.
- Every authored id survives to the game or is reported; nothing is dropped silently.
- Deterministic: the same seed builds the same world.
- A save made on the old cast is refused, not migrated.

## Decision

1. **Two routes.**
   - **World content** (people, builds, ties, beasts, events, lineages, seats) stays in `design/world/depth/` and is
     read there by `export_world.py`, which writes `world_history.json`.
   - **Records** (techniques, arts, items, sets, Effects) are promoted out of the depth files into the design
     catalogues and reach the game through the exporters that already exist. After promotion the catalogue is the
     source; the depth file keeps the id only.
2. **Where each record kind goes** (all picked up by the existing globs unless marked new):

   | Kind | Promoted into | Game file | Writer |
   |---|---|---|---|
   | Techniques | `design/techniques/catalogue-sect-<key>.json` | `items_cong_phap.json` | `export_techniques.py` |
   | Arts (new) | `design/arts/part-sect-<key>.json` | `combat_library.json` | `fight.py` library → `export_combat_library.py` |
   | Items | `design/items/catalogue-sect-<key>.json` | `items_named.json`, `combat_library.json` | `export_named.py`, `export_combat_library.py` |
   | Sets (new) | `design/items/sets-<key>.json` | `items_sets.json` (new) | `export_named.py`, extended |
   | Effects | `assets/data/combat_effects.json` directly, `source: "world-depth:<key>"` | same | hand-written, as today |
   | Beasts (new) | stay in `**/*.beasts.json` | `world_history.json` `beasts` | `export_world.py` |
   | Events (new) | `design/world/depth/events/<key>.events.json` (structured from the `sects/*.md` prose) | `world_history.json` `events` | `export_world.py` |

   Outside groups use their group name in place of `<key>`.
3. **Effect keys.** Effects stay keyed by their plain English name, as the item and technique records already
   reference them. The gap report lists the 2 names equal to an existing key and the 4 shared names; each is either
   confirmed as a reference to the one Effect or renamed, with the user. A new Effect never overwrites an existing
   key.
4. **Promotion order (D3): by sect.** One sect's techniques, arts, Effects, items, sets and beasts, then its export,
   then the next sect. Băng Tâm Các is first (Stage 7). Engine features a later sect needs arrive with that sect,
   after the Stage 5 base set.
5. **The cast merge.** `export_world.py` builds the people from the depth cast files, plus the 18 old people the depth
   cast lacks (from `cast_proposal` and `records_proposal`, unchanged). For a person in both, **the depth record wins
   on every field it carries**; old fields it lacks are kept. Builds come from the depth person's `build`, `root`,
   `thien_phu` and `stage`, mapped into the existing `cast_builds` shape (`tree.intent` and notes stay design-only).
   `design/world/cast_builds.json` is retired as a source once Stage 7 lands; "keep the authored targets" means the
   depth targets, which already include all 54 old builds.
   - Tier C people carry no `thien_phu`; the builder rolls them from the person's keyed stream (ADR-0002).
   - `CAST_SIZE` (60-100) becomes the authored-cast check of World Generation rule 16.
   - `changed` notes are not exported.
6. **Sources first.** Before the first depth export, A225 and C023 are written into their source
   (`chronicle_proposal.json`), and a fresh export must equal the committed `world_history.json` apart from
   `data_version`. From then on `assets/data/world_history.json` is never edited by hand.
7. **Exporters run in order.** Record exporters, then `export_world.py`. A cast build that names an id no game file
   has fails the export, as now.
8. **Stand-ins while stages land.** A person whose wanted technique is not yet promoted gets the generated stand-in
   `<hoang|huyen|dia|thien>_<element>` written explicitly in the build, with the wanted id beside it
   (`"main": {"tech": "huyen_bang", "wants": "<id>"}`). The gap report counts every `wants`. A lineage member never
   gets a silent stand-in (Sects AC-SM-64). `CastBuilds._learn` warns on an unknown id instead of dropping it. The plan
   is done when no build carries `wants`.
9. **The world data version.** `world_history.json` gains `world_data_version`, an integer, set to 1 by the first
   depth export and raised only on a break an old save cannot hold (people removed or re-keyed, record ids removed).
   The save meta records it, and `load_dict` refuses a save whose value differs, with the existing "cannot be loaded"
   message, as ADR-0008 does for provinces. The content hash `data_version` stays as a recorded observation and now
   also hashes `design/world/depth/`.
10. **The gap report** (`tools/design/world/depth_gap.py`, observations only) is the done test for the whole plan: zero
    `wants`, zero ids missing from the game files, zero unread modifier keys, zero Effects without an engine record,
    zero engine words the records use and the engine lacks.

### Key Interfaces
- `python -I tools/design/world/export_world.py [--check] [--sect <key>]`: `--sect` exports one sect's depth content
  beside the old cast for Stage 7; without it, every sect.
- `world_history.json`: adds `world_data_version` (int), `beasts` (list), and the `wants` field in `cast_builds`.
- `items_sets.json`: `{_doc, sets: [{id, name, pieces, bonuses: [{pieces, modifiers} | {pieces, effect}]}]}`.
- `WorldBuilder` reads `beasts` and builds each as a people record with `owner_id` (`creatures_linh_thu.json` rules).
- `GameSession.load_dict`: one more refusal on `world_data_version`.

### Implementation Guidelines
- `export_world.py` grows a depth reader; the old top-level reader stays for the 18 fallen-sect people and the
  chronicle.
- The tie mapping (25 kinds to the game's kinds) and the trait trim are applied in the export, not in the depth files.
- Tests: an export round-trip check (sources → file, no hand edits); a unit test that a save with another
  `world_data_version` is refused; a unit test that `_learn` reports an unknown id.

## Alternatives Considered

### Alternative 1: A second exporter that reads records straight from `design/world/depth/`
No promotion step. Rejected: two sources for techniques, items and arts, and two exporters that would have to agree;
the linters and `fight.py` read only the catalogues.

### Alternative 2: Promote by kind (all techniques, then all items)
Rejected by the user (D3): no sect works end to end until the last batch, so pipeline problems show up late.

### Alternative 3: Refuse saves on the content hash `data_version`
Rejected: every promotion batch changes the hash, so every development save would stop loading after each batch.

### Alternative 4: Migrate old saves onto the new cast
Rejected: re-keying 88 people and replacing 1,800 more inside a saved world is costly to keep working, and the game is
a prototype (ADR-0008 Alternative 2, same reasoning).

## Consequences

### Positive
- One source and one exporter per game file; the linters and `fight.py` see the depth records like any others.
- The game's cast becomes the reviewed one, and every dropped id is reported.

### Negative
- Every save made before the first depth export stops loading.
- `world_history.json` grows from 106 people to about 1,909, and world build time grows with 1,748 authored builds
  (measured in Stages 7 and 8).
- Promotion copies records out of the depth files; the depth file and the catalogue can drift until the promoted
  fields are removed from the depth file.

### Neutral
- `cast_builds.json` and `cast_proposal.json` remain in the repo, for the 18 fallen-sect people and history.

## Risks
- **Load time** with 1,748 authored builds. Guard: Stage 7 measures one sect, Stage 8 budgets the whole.
- **Effect name clashes** (decision 3). Guard: the gap report lists them; a new key never overwrites.
- **Shared GDD files.** Guard: stage only this work's hunks.

## GDD Requirements Addressed

| GDD | Requirement | How |
|-----|-------------|-----|
| `design/gdd/world-generation.md` | Rules 3a, 5, 5a, 6, 6a, 16, 16a (the authored cast at scale), Core Rule 13 (versioned data) | Decisions 5, 9 |
| `design/gdd/sects.md` | Rule 20b (lineage), AC-SM-64 (no silent stand-in for a lineage member) | Decisions 1, 8 |
| `design/gdd/item-database.md` | Rules 20f, 20g, 22 (item sets), Formulas J | Decision 2 (sets route) |
| `design/gdd/effects.md` | Rules 17-19 | Decisions 2, 3 |
| `design/gdd/npc-relationships.md` | Tie kinds and caps, rule 5's authored exception | Implementation Guidelines (tie mapping) |

## Performance Implications
World build time with 1,748 authored builds is unmeasured; Stage 7 measures one sect.

## Migration Plan
Saves: refused (decision 9). Data: the sources are fixed first (decision 6), then sect by sect (decision 4).

## Validation Criteria
- A fresh export equals the committed `world_history.json` before the first depth export (decision 6).
- A save with another `world_data_version` is refused (unit test).
- An unknown technique id is reported, not dropped (unit test).
- The gap report shows zero for Băng Tâm Các after Stage 7, and zero everywhere after Stage 8.

## Related
`production/plans/world-depth-implementation.md`; `design/world/depth/README.md`, `schema.md`,
`DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`; ADR-0001, ADR-0002, ADR-0004, ADR-0006, ADR-0008.
