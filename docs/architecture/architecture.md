# Ten Thousand Daos — Master Architecture

## Document Status
- Version: 1
- Last Updated: 2026-11-13
- Engine: Godot 4.7.1 (installed; `docs/engine-reference/godot/VERSION.md` pins the 4.7 line), GDScript
- GDDs Covered (15): `linh-can`, `character-stats`, `canh-gioi`, `cong-phap`, `kinh-mach-do`, `item-database`,
  `combat`, `combat-defence`, `combat-damage-types`, `modifiers`, `effects`, `dao`, `thien-kiep`, `quests`,
  `travel-map`; plus the Technical Considerations of `game-concept.md`. Not scanned as GDDs: `systems-index.md`
  (used for the layer map), `gdd-cross-review-2026-11-05.md` (a review record).
- ADRs Referenced: ADR-0001 (Accepted, amended 2026-11-13: the order two sides act in at the same moment is a coin
  from the fight's seeded stream, with a fixed order for exact parity tests only)
- TR registry: empty. Every requirement ID below is **provisional** until `/architecture-review` registers it.
- TD-ARCHITECTURE: 2026-11-13 — skipped — Lean mode
- LP-FEASIBILITY: 2026-11-13 — skipped — Lean mode

## Engine Knowledge Gap Summary
The model's training data covers Godot to about 4.3; 4.5, 4.6 and 4.7 are post-cutoff.

| Risk | Domain | What matters for this game |
|---|---|---|
| HIGH | GDScript 4.7 | An override of a typed-return method inherits the type and needs an explicit `return`; writing one element of a packed array no longer calls the property's setter (our fields are plain `var`s, so this was read from `breaking-changes.md`, not tested) |
| HIGH | UI 4.6–4.7 | Mouse/touch focus is separate from keyboard/gamepad focus; `Control.offset_transform_*`; `RichTextLabel` image units. The Game UI is not built, so none of this is exercised yet |
| HIGH | Core resources 4.5 | `duplicate_deep()` exists; `deprecated-apis.md` says to use it for nested copies. The code has 14 `Array`/`Dictionary` `.duplicate(true)` calls whose 4.7 behaviour is **NEEDS VERIFICATION** |
| MEDIUM | Rendering | `CanvasItem` lines are thinner in 4.7 (matters for the ink-wash look); D3D12 is the default on Windows since 4.6; Shader Baker |
| MEDIUM | Input | Mouse and keyboard report `DEVICE_ID_MOUSE` / `DEVICE_ID_KEYBOARD`, not `0` |
| MEDIUM | Audio | `area_mask` defaults to 0; Full Vision only |
| LOW / unused | Physics, Navigation, multiplayer Networking | No system uses them |
| **NOT SOURCEABLE** | `HTTPClient` / `HTTPRequest` / threads | `LlmClient` uses a blocking `HTTPClient` loop. No file in `docs/engine-reference` covers it, so nothing here is asserted about it beyond what the code does today |

The 4.7 release used for the timing spike is `4.7.1.stable.official.a13da4feb` with the official release export
template (`production/qa/evidence/combat-port/timing-spike-2026-11-13.md`).

## System Layer Map
Platform (Godot, Windows) is the engine and OS, not code we write. Within our code:

| Layer | Systems | Owns exclusively |
|---|---|---|
| **Foundation** | #1 Config, #2 Sim Core (seeded RNG, `Breakdown`), #3 World DB, #4 Time & Turn, #5 Save/Load, LLM transport (`LlmClient`) | Data files, random streams, the one record of the world, saved state, the network call |
| **Core (rules kernel)** | #6 Spiritual Roots, #7 Character Stats (stat sheet), #40 Modifiers, #41 Effects, #8 Realms, #13 Item DB, #9 Cultivation Techniques | The stat sheet and every number that is summed |
| **Feature** | #14 Herbs, #15 Alchemy, #16–19 Refining / Formations / Talismans / Beasts, #10 Meridian Map, #11 Edges, #24 NPC Builds, #27 World Gen, #25 Travel & Map, #20 Market, #26 Sects, #21 / #21a / #21b Combat (ADR-0001), #22 Tribulation, #23 Event Engine, #28 Living World, #39 The Way, #43 Regional Economy, #31 Quests, #42 NPC Traits | Each system's own rules and records |
| **Application facade** (top of Feature) | `GameSession` | The turn loop, the pending event, the save/load API |
| **Presentation** | #29 LLM Game Master and #30 Dialogue (narration only), #35 Guidance, #36 Debug Terminal, #37 Game UI, #38 Audio, #34 Localization, #32 Achievements, #12 Codex | Text, screens, sound |
| **Tooling** (outside the shipped game) | #33 Balance Harness, the Python combat sim, the parity suite, the map build tool | Design-time measurement |

Three judgement calls:
1. Modifiers (#40) and Effects (#41) sit in **Core**, not Feature as the systems index lists them. Nearly every
   system reads them and the stat sheet cannot be built without them. Combat depends on Core; nothing in Core
   depends on Combat.
2. The LLM Game Master is Presentation, but **bounded**: the Event Engine and its budgets (Feature) decide what can
   happen; the LLM only narrates and proposes events inside them (Pillar 2).
3. The Balance Harness is **Tooling**: it calls `GameSession` headlessly like any frontend.

## Module Ownership
Dependencies point down only. Gameplay code is plain `RefCounted` logic: no `Node`, scene, autoload or thread (the
terminal entry point is a `SceneTree` script).

```
Presentation:  Debug Terminal   Game UI   Guidance   LLM Narrator   Audio   Localization
                    \             |          |           |             /
                     v            v          v           v            v
Application:                    GameSession (one method per action)
                                     |
Feature:  Event Engine  Combat  Travel/Map  Crafts  World Gen  Living World  Quests ...
                \          \        |          /         /          /
                 v          v       v         v         v          v
Core:           Character Stats <- Modifiers <- Effects <- Realms, Roots, Item DB, Techniques
                                     |
Foundation:  Config   Sim Core(RNG)   World DB   Time   Save/Load   LLM transport
```

**Foundation**

| Module | Owns | Exposes | Consumes | Engine APIs (risk) |
|---|---|---|---|---|
| Config (`GameData`, `DataRegistry`) | The 30 JSON files in `assets/data`, validated at load | Typed accessors (`gd.combat()`, `gd.realm(i)`, `gd.file(id)`) | — | `FileAccess`, `DirAccess`, `JSON` (LOW; numbers arrive as floats) |
| Sim Core (`RngUtils`, `Breakdown`) | Seeded streams; the explainable-number record | `Breakdown`, helpers | — | `RandomNumberGenerator` (LOW); `Breakdown` uses `.duplicate(true)` (NEEDS VERIFICATION) |
| World DB | All people, places, items, events, tables | `add`, `get_record`, `find`, `log_event`, `to_dict` | Config | Signals only (LOW) |
| Time & Turn | The season clock held by `GameSession` | `season_index`, `clock_label` | Config | none |
| Save/Load (`SaveStore`) | Slots under `user://saves`; `SAVE_VERSION` 3 (reads 1 and 3) | `write`, `read`, `list_slots` | World DB, session state | `FileAccess`, `ProjectSettings` (LOW) |
| LLM transport (`LlmClient`) | The HTTP exchange and its latency average | `chat(messages, json_mode)` | Config | `HTTPClient`, a blocking poll loop: **NOT SOURCEABLE** |

**Core (rules kernel)**

| Module | Owns | Exposes | Consumes |
|---|---|---|---|
| Character Stats (`StatSheet`) | The sum of every stat and where it came from | `total(key)`, `has_flag(key)`, `effective(id, c)` | Roots, Modifiers, every provider through one interface |
| Modifiers (#40) | The catalogue of stats, scopes and operations | Modifier records and prices | Config |
| Effects (#41) | The Effect record format and the status catalogue | Records only (ADR-0001 puts the fight interpreter in Combat) | Modifiers |
| Roots, Realms, Item DB, Techniques | Their records and ladders | Stat providers | Config, World DB |

**Feature (where ownership is easy to get wrong)**

| Module | Owns | Must not |
|---|---|---|
| Combat engine (`Fight`, `DefencePath`, the Effect runner, `RatingProfile`) | The timeline, fighters' fight state, the defence path | Touch World DB, the session or scenes; mutate a profile; apply life costs (the caller applies them) |
| `FighterCompiler` (Combat's adapter) | Turning a Character into an immutable `FighterProfile` | Write to World DB; it may read `Character` and `WorldDB` **read-only** (ADR-0001) |
| Event Engine | Templates, budgets, the validator, the resolver | Let the LLM set a number outside a budget |
| World Gen, Living World | The per-game rolls on the fixed world; the seasonal tick | Run full fights for NPC-against-NPC duels (rating profile only) |
| Crafts, Herbs, Market | Their own stock and recipes | Read Combat; they expose a read-only combat contribution only |

**Application facade: `GameSession`.** It owns the clock, the player, the pending event and one
`RandomNumberGenerator` stream, and exposes one method per player action returning `{ok, lines, …}`. No other module
holds a back-pointer to it.

**Presentation**

| Module | Owns | Consumes |
|---|---|---|
| LLM Game Master / `Narrator` | Prompts and narration only | Event Engine output; never changes state |
| Guidance (`Advisor`, `StateSnapshot`) | Read-only views of state | `GameSession` |
| Debug Terminal | Text I/O (a `SceneTree` script, not a scene) | The `GameSession` API; it is exempt from the frontend rule (see API Boundaries) |
| Game UI (not built) | Scenes and themes | The same API as the terminal, under the frontend rule |

## Data Flow
This game has no frame loop. The equivalents are turn-based; none of them crosses a thread boundary today.

**1. The turn path.**
```
Frontend ── command / button ─► GameSession.<action>(args)        synchronous call
                                   │ _guard(): game exists? life over? event pending?
                                   ▼
                            _pass_season(mode)   Core: stat sheet → rates (CultivationRules, CongPhap)
                                   │             Feature: herbs grow, WorldTicker.tick(rng, year, season)
                                   │             Foundation: season/year clock, yearly upkeep
                                   ▼
                            maybe an event: Narrator.generate_event → LLM first, template fallback;
                                   │         EventValidator clamps it to the budgets
Frontend ◄── {ok, lines, ...} ◄────┘
```
A *shipped* frontend never reads or writes `db` or `player` directly; it uses the facade's return values plus
`StateSnapshot` / `Advisor`.

**2. Events and signals.** Systems communicate by return value and by one collected-notices array that the next
action's output drains. There are four signals (`life_ended`, `breakthrough_succeeded`, two in `WorldDB`). Signals
are only for telling a presentation layer something happened; gameplay rules never depend on a listener, so a
headless run cannot differ from a UI run. A fight (once ADR-0001 is wired in): the Event Engine builds a
`FightRequest`, `CombatService.resolve` compiles both fighters and runs one `Fight` seeded with `rng.randi()` from
the session stream, and returns a `FightResult`; the caller applies `life_costs`. A fight therefore consumes exactly
one value from the session stream.

**3. Save / load.**
```
GameSession.to_dict() → { version 3, seed, rng_seed, rng_state (strings), year, season, player_id, db.to_dict(),
                          pending_event/meta, life_over, epitaph, cheated, edge, co_duyen_used }
SaveStore.write(slot, dict) → user://saves/<slot>
load: SaveStore.read → GameSession.load_dict(d): version check (reads 1 and 3), WorldDB.from_dict, per-record
      migrations, _wire() rebuilds every service, Character.from_dict(player record)
```
`GameSession` decides what is saved, `WorldDB` serialises its tables, `SaveStore` only writes files. RNG state is
stored as a string to avoid float precision loss. Cached state is never saved: compiled `FighterProfile`s are
dropped on load and rebuilt. The fixed-world decision (2026-11-12) moves the map, sects and history out of the save,
and `item-database.md` AC-ID-68 already requires a version above 3: that is `SAVE_VERSION` 4 (ADR list, item 1).

**4. Initialisation order.**
```
1. GameData.load_from()  → reads every JSON in assets/data (including combat_engine.json) → validated
2. LlmService(gd)        → provider config; mock or real client
3. MeridianTree.generate(gd)
4. GameSession._init     → holds gd, llm, tree
5. new_game(seed, spec)  → rng.seed → WorldGenerator.generate → db → _wire() → player → place → sync_player
   load_dict(d)          → the same wiring, state from the save
```
Services need `db`, so they exist only after `new_game` or `load_dict`. Two follow-ups: `CombatConstants.load_file()`
reads its JSON directly with `FileAccess`, but Config is the only reader, so it should be built from
`gd.file("combat_engine")` when combat is integrated; and the one blocking call, `LlmClient.chat`, freezes the caller
for the whole round trip, which is acceptable in a terminal and not in a Godot UI (ADR list, item 8).

## API Boundaries
Engine types in these interfaces are `RefCounted`, `RandomNumberGenerator`, `Signal`, `Dictionary`, `Array` and
`Packed*Array`. No `Node` or `Resource` crosses a boundary, and no `Dictionary[K, V]` is used (not covered by the
engine reference).

**1. `GameSession`, the application facade**
```gdscript
# One method per player action. Returns {ok: bool, lines: Array[String], ...}. Never throws, never prints.
func new_game(seed_v: int, spec: Dictionary) -> Dictionary
func cultivate(seasons: int) -> Dictionary      # also closed_door, travel, craft, equip, breakthrough, choose ...
func to_dict() -> Dictionary                    # version-stamped; load_dict(d) -> {ok, lines}
signal life_ended(summary: Dictionary)          # presentation hints only
signal breakthrough_succeeded(realm_index: int)
```
- Callers: one action at a time; a pending event blocks time-passing actions; `new_game` or `load_dict` first.
- Guarantees: a failed action returns `ok: false` and leaves state unchanged; every time-passing action goes through
  `_pass_season`; the same seed and action sequence give the same life.
- **Frontend rule.** A *shipped* frontend (the Game UI) uses only these methods plus `StateSnapshot` / `Advisor`
  reads. The **debug terminal is exempt**: it is a debug and cheat tool, and it reads `session.player` and
  `session.db` about 113 times today and writes `session.player.tree_visibility` directly
  (`terminal_app.gd:775`). The terminal does not set the standard for the Game UI. (User decision 2026-11-13: the
  terminal is not required to be refactored.)

**2. `GameData` (Config)** — `func file(file_id: String) -> Dictionary`; typed accessors per system. Data is
read-only after load; a malformed file stops the load with the file named.

**3. `StatSheet` (Core)** — `total(stat) -> float`, `has_flag(stat) -> bool`, `effective(thien_phu_id, c) -> float`.
Every provider (Meridian Map, Way, techniques, items, edges) contributes through one provider interface; no system
reads another's records to compute a stat. Every total comes with its `Breakdown`.

**4. Event Engine** — `Narrator.generate_event(ctx, rng, template_id) -> Dictionary`,
`EventValidator.normalize(raw, ctx, rng, source) -> Dictionary`, `EventResolver.resolve(c, sheet, rng, event, index)
-> Dictionary`. An LLM-proposed event passes `normalize` before it exists, which clamps every number to its budget
and drops unknown effects; narration cannot change an outcome, and invented numbers fall back to the template.

**5. `LlmService`** — `use(feature) -> bool`, `json_call(system_prompt, payload) -> Dictionary`,
`text_call(system_prompt, user_text) -> Dictionary`. It always returns, with an error field on failure, and callers
always have the template fallback. The call blocks today; the signature must stay stable if it becomes
asynchronous, and the async form needs its own ADR.

**6. Combat (ADR-0001)** — `CombatService.resolve(FightRequest) -> FightResult`: pure, synchronous and seeded; the
caller applies `life_costs`. Details are in the ADR.

**7. `SaveStore`** — `write(slot, data) -> int` (error code) and `read(slot) -> Variant`. It stores opaque data and
never interprets it.

## ADR Audit

| ADR | Engine compat | Version | GDD linkage | Conflicts | Valid |
|---|---|---|---|---|---|
| ADR-0001 Combat engine in Godot | ✅ | ✅ (4.7, 4.7.1 installed) | ✅ (nine GDD rows) | ⚠️ one wording point, resolved: the pure engine must not touch World DB, while `FighterCompiler` may read it read-only (the ADR already says this) | ✅ |

Possible update, not yet made: add the step 1 timing result to ADR-0001 (worst p95 5.5 ms of 50 in a release export
build, slice 1 only; the post-Effect-slice bench is still required).

**Technical Requirements Baseline** (provisional IDs, system-contract level; the 1,110 acceptance-criteria rows in
the 15 GDDs are traced story by story by `/architecture-review`). `combat-damage-types.md` and `modifiers.md`
produced no performance, determinism or persistence lines in the scan and contribute only data-shape requirements.

| Req ID | Source | Requirement | Domain | ADR coverage |
|---|---|---|---|---|
| TR-sim-001 | combat, linh-can, character-stats, item-database, effects (AC-EF-02) | Everything is deterministic from the seed | Core | ADR-0001 (fights only) |
| TR-sim-002 | effects, quests | A counted chance consumes no random draw; sampling tests use fixed seed lists | Core | gap |
| TR-save-001 | canh-gioi, character-stats, cong-phap, item-database, kinh-mach-do, linh-can | A save/load round trip is deep-equal for every record kind | Save/Load | gap |
| TR-save-002 | canh-gioi, item-database | Save versions: 1 migrates, 2 is refused, 3 loads; version above 3 required | Save/Load | gap |
| TR-save-003 | travel-map | Saving stores the seed and the changes; map and authored history come from data | Save/Load | gap |
| TR-combat-001 | combat:394, ADR-0001 | No clock, no engine nodes, no global state; headless | Core | ADR-0001 |
| TR-combat-002 | ADR-0001 | One full fight under 50 ms in a headless export build | Performance | ADR-0001 |
| TR-combat-003 | combat Formulas K | NPC and mass fights use the rating profile | Performance | ADR-0001 |
| TR-effects-001 | effects, ADR-0001 | Effects are validated JSON records | Core | ADR-0001 |
| TR-modifiers-001 | modifiers, character-stats | Every stat total comes from one provider interface with a `Breakdown` | Core | gap (combat part by ADR-0001) |
| TR-items-001 | item-database | About 200,000 items at 5,000 cultivators | Performance | gap |
| TR-world-001 | canh-gioi, item-database, travel-map | 5,000 cultivators (never under 3,000), per-region work once a season | Performance | gap |
| TR-meridian-001 | kinh-mach-do | NPC allocation at most 50 ms at 566 points, 5 ms at 120 | Performance | gap |
| TR-dao-001 | dao | 94 Ways, each a graph of about 150 nodes | Core | gap |
| TR-travel-001 | travel-map | One authored tile continent from index images, stored by a build tool | Core / Rendering | gap |
| TR-quests-001 | quests | A stored quest brief is fixed; the LLM plan is saved, not regenerated | Save/Load | gap |
| TR-llm-001 | concept, `LlmClient` | The LLM acts inside engine budgets; the template fallback always works | Core | gap |
| TR-llm-002 | concept | Structured-output reliability; no UI blocking during a call | Networking | gap (NOT SOURCEABLE) |
| TR-ui-001 | concept, ui module | 2D ink-wash UI; Vietnamese, Chinese and English; accessibility | UI | gap |
| TR-realms-001 | canh-gioi | The realm ladder is a data contract owned by Realms | Core | gap |
| TR-stats-001 | systems-index | Character Stats' provider interface is the single stability point (about 20 dependents) | Core | gap |

Coverage: 6 of 20 covered (all by ADR-0001; shared rows counted only for their combat part), 14 gaps.

## Required ADRs
**Must decide before the next work that builds on it**
1. Save format and migration policy (`SAVE_VERSION` 4): TR-save-001, 002, 003, TR-quests-001
2. `GameSession` facade as the API boundary, including the frontend rule and the terminal exemption
3. Random-stream policy: one session stream, derived streams for fights, world generation and NPC allocation, no
   global random: TR-sim-001, 002. **Written: ADR-0002, Accepted 2026-11-14.**
4. Stat sheet and provider interface: TR-modifiers-001, TR-stats-001, TR-realms-001

**Should decide before its system is built**
5. Data loading and validation (`GameData`, JSON float-to-int, schema versions, `CombatConstants` through
   `GameData`), before the combat integration story
6. World scale and simulation budget: TR-world-001, TR-items-001, TR-meridian-001, TR-combat-003, before ADR-0001
   step 5
7. Fixed-world map pipeline: TR-travel-001, TR-dao-001, before the Travel & Map rework
8. LLM transport and async calls: TR-llm-001, 002, before the Game UI or real-model testing; **needs a spike against
   real Godot 4.7 behaviour first, since the engine reference does not cover it**
9. Game UI framework, localization and accessibility: TR-ui-001, after the art bible
10. Combat presentation (fight log and UI), after ADR-0001 step 4

**Can defer to implementation**
- A verification test for `.duplicate(true)` against `duplicate_deep()` on 4.7
- The GDExtension fallback for the Effect runner, only if the post-Effect-slice bench misses 50 ms
- Audio (Full Vision; needs the Game UI first)

## Architecture Principles
1. **The simulation is headless and deterministic; every frontend is a client.** The same seed and the same actions
   give the same life (TR-sim-001). Nothing under `GameSession` knows whether a terminal or a Godot UI is attached.
2. **Every number is data and every number explains itself.** Values come from `assets/data` through `GameData`,
   and every total carries a `Breakdown` (Pillar 2).
3. **Dependencies point down, and cross-system rules go through one provider interface.** No system computes
   another system's stat by reading its records, and all player actions enter through `GameSession`.
4. **The LLM proposes; the engine disposes.** Events are clamped to budgets by the validator, narration cannot change
   an outcome, and a template fallback always exists.
5. **Full fights are rare, and the world is cheap.** Player fights use the full engine; NPC-against-NPC and mass
   fights use the rating profile (ADR-0001). Post-cutoff engine behaviour is verified by a test or a measurement,
   never by memory.

## Open Questions
- **Async LLM calls:** `HTTPRequest` on the main thread versus a worker thread. NOT SOURCEABLE from the engine
  reference. Closed by ADR 8, after a spike.
- **`duplicate(true)` versus `duplicate_deep()` on 4.7:** the 14 existing uses are unverified. Closed by the deferred
  verification test.
- **What leaves the save in version 4:** exactly which fixed-world data moves to authored files, and the version 3
  migration. Closed by ADR 1.
- **How long the debug terminal keeps its raw-access exemption:** until the Game UI ships, or permanently. Closed by
  ADR 2.
- **Platforms beyond Windows:** the only export preset is Windows; the concept mentions Steam but records no platform
  decision. Closed before the first release checklist.
- **Typed `Dictionary[K, V]`:** not covered by the engine reference, so unused. Revisit if the compiled-profile code
  wants it.
