# ADR-0001: The Combat Engine in Godot

## Status
Accepted

## Date
2026-11-13

## Last Verified
2026-11-13

## Decision Makers
The user (decisions: source of truth, Effect format, parity strictness, layer), with the assistant drafting.

## Summary
Player fights in the game are a one-roll chiến lực duel, while the designed combat (arts, wards, element stacks,
statuses, Effects, items) exists only in the Python design sim. This ADR ports the sim's engine to GDScript as the
canonical fight engine, compiles fighters from a Character, reads Effects as the same JSON records the sim uses, keeps
the sim as a mirrored design tool guarded by a shared parity suite, and leaves NPC-against-NPC and mass fights to the
Combat GDD's rating profile (Formulas K).

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (4.7.1 installed) |
| **Domain** | Core (scripting: pure GDScript logic, no scene, physics, rendering or UI) |
| **Layer** | Core |
| **Knowledge Risk** | HIGH (4.5–4.7 are past the LLM cutoff; `docs/engine-reference/godot/VERSION.md`) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md` (no module reference covers scripting) |
| **Post-Cutoff APIs Used** | None required. The engine uses GDScript 2.0 features this codebase already compiles (static typing, `RefCounted`, typed arrays, lambdas, `RandomNumberGenerator`). It must respect 4.7's "an override inherits its typed return" rule |
| **Verification Required** | (1) Determinism: one seeded `RandomNumberGenerator` per fight reproduces a fight exactly in Godot. (2) Performance: a full fight resolves within the budget below in a headless export build, not only in the editor |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None (no earlier ADR exists) |
| **Enables** | A later ADR for the combat presentation (fight log and UI), and one for Event Engine fight requests if that interface needs more than this ADR fixes |
| **Blocks** | Any epic or story that makes fights read arts, wards, Effects or item stats in the game |
| **Ordering Note** | The fighter compiler needs Meridian Map stats through the stat sheet only (Combat GDD: the Map reaches Combat only as stat modifiers), so the parked Meridian Map does not block it |

## Context

### Problem Statement
`CombatPower.duel` turns two chiến lực totals into one win chance and rolls once. Everything the combat GDDs
designed (Combat, Combat Defence & Healing, Combat Damage Types, Effects, the Modifier System's combat keys) runs only
in `tools/design/combat_sim/engine.py` (about 1,600 lines, 49 mechanism tests, a regression check and a selftest).
In the game, items' arts, wards and Effects, techniques' arts, scoped modifiers and the Thiết Bích affix are stored but
do nothing, and builds matter only through a total. The content library (171 named items, 34 techniques, the arts
families, 54 library Effects) is being balanced against the sim, so the game must run the same rules.

### Constraints
- GDScript only (the project's language); no GDExtension or embedded Python.
- Data-driven: every number from `assets/data` (coding standards).
- Testable without scenes: the engine is `RefCounted` logic, unit-tested with GdUnit4.
- Deterministic per seed within Godot (tests must be repeatable).
- The Python and Godot random streams differ, so seed-for-seed equality across the two is not available.

### Requirements
- Run the Combat GDD's timeline: pulses, arts on cooldowns and linh lực costs, basic attacks, companions.
- Run Combat Defence & Healing's path per hit part: avoid, evade, resistance with drain bills, extra wards (drain,
  per hit, reserved, cast), block, shields, body shield, health; healing and regeneration; fatigue; the Down step.
- Run element stacks as batches, the Status Catalogue's statuses and curses, and the Effects System's records
  (events, conditions, scaling, limits, held payloads, actions, readables).
- Build each fighter from a Character: realm and stage, the stat sheet (Meridian Map, Way, techniques' passives,
  items' modifiers), slotted arts (techniques, worn items' arts and common arts), wards (main, extra, armour's own
  slot), item and technique Effects, reserve arts.
- Serve the Event Engine's fight request and return a result with life costs for the caller to apply.
- Leave NPC-against-NPC and mass fights to the rating profile (Combat Formulas K).
- A full one-on-one fight resolves in under 50 ms in a headless build.

## Decision

Port the sim engine to GDScript as **the canonical fight engine**. The Python sim stays as the fast design tool and
**mirrors** the game engine; a **parity suite** keeps the two agreeing.

1. **Engine (`src/gameplay/combat/fight/`).** A `Fight` runs two `FighterState`s from two `FighterProfile`s on a
   millisecond timeline, as `engine.py` does: the pulse loop, the defence path, stacks and statuses, the Effect
   interpreter and the Down step, each in its own class. It holds no reference to scenes, nodes, the session or the
   World DB; it reads only its profiles, the combat data files and its seeded `RandomNumberGenerator`.
2. **Fighters are compiled.** `FighterCompiler.compile(c, gd, db, tree)` turns a Character into an immutable
   `FighterProfile`: offence layers and keys from the stat sheet, slotted arts in slot order, wards with their slots,
   Effects (from items, techniques, arts and the Way), counters, states, reserve shares. An enemy without a Character
   (a creature, a tribulation wave, the typical or top-end reference) is a profile built from data. Profiles are
   cached on the character and rebuilt when its build changes.
3. **Effects are data, in one format.** The engine interprets the sim's Effect records unchanged: `on`, `filter`,
   `if`, `scale`, `limit`, `chance`, `held`, `do` with the sim's actions and readables. `effects_library.json` moves to
   `assets/data/combat_effects.json` and both engines read it; art and technique Effects stay in their records. At
   load the game compiles each record into a typed `EffectDef` (event, action and mod-key enums, `StringName` keys,
   `Array[EffectDef]` indexed by event), so the fight loop never reads raw JSON. The loader rejects unknown events,
   actions, mod keys, dtypes, elements and readables, as the sim does.
4. **Parity, exact and statistical.** A shared fixture set (`tests/parity/fixtures/*.json`: two profiles and a
   seed count) is run by both engines. Chance-free fixtures (no crit, evade, chance Effect or status chance) must match
   exactly: event by event, final health and linh lực within 1e-6. Chancy fixtures must match over 1,000 seeds: mean
   fight time within 5 % and win share within 0.05 (amended 2026-11-13, user decision: at 200 seeds the sampling noise
   between two independent runs of an even fight is about ±0.05, so a correct port would fail about a third of the
   time; at 1,000 it is about ±0.022). The sim's 49 mechanism tests become GdUnit tests with the same
   names and numbers. Any rule change lands in both engines in the same change, and the parity suite must pass.
5. **Callers.** The Event Engine's combat check, and any player duel, call `CombatService.resolve(request)`, which
   compiles both fighters, runs one `Fight` on the session's seeded stream and returns a `FightResult`.
   `CombatPower.duel` stays only behind a feature flag until the port is complete, then is removed.
6. **The world stays cheap.** NPC-against-NPC duels and mass battles in the world tick use the rating profile
   (Combat Formulas K), not the full engine: closed-form, computed from the same `FighterProfile`, cached. Its
   `display_power` replaces the chiến lực total wherever one number is shown. The Formulas K agreement test (rating
   against full fights) runs in the balance harness.

### Architecture Diagram

```
Character ──► FighterCompiler ──► FighterProfile (immutable, cached)
 (sheet, techniques, items,              │                     │
  Way, Meridian Map via sheet)           │                     └──► RatingProfile (Formulas K) ─► world tick, mass battles,
                                         ▼                                                         display_power
Event Engine / player action ──► CombatService.resolve(request)
                                         │
                                         ▼
                      Fight (timeline) ─► DefencePath ─► Stacks/Statuses ─► EffectRunner (JSON records)
                                         │
                                         ▼
                      FightResult (winner, time, log, life costs) ──► caller applies costs

Python sim (tools/design/combat_sim) ◄─── parity suite (tests/parity) ───► GDScript engine
          design rounds, sweeps                shared fixtures, exact + statistical
```

### Key Interfaces

```gdscript
class_name FighterCompiler extends RefCounted
static func compile(c: Character, gd: GameData, db: WorldDB, tree: MeridianTree) -> FighterProfile
static func from_data(profile_id: String, realm: int, gd: GameData) -> FighterProfile   # creatures, waves, references

class_name CombatService extends RefCounted
func resolve(request: FightRequest) -> FightResult

class_name FightRequest extends RefCounted
enum Situation { FORESEEN, AMBUSH, BLIND }   # Combat GDD, Event Engine row
var a: FighterProfile
var b: FighterProfile
var situation: Situation = Situation.FORESEEN
var ground_tags: Array[StringName] = []     # built with assign() from JSON, never assigned an untyped Array
var no_heal: bool = false
var start_health_share: float = 1.0        # Combat rule 1: starting shares (Heavenly Tribulation waves)
var start_qi_share: float = 1.0            # of usable linh lực; 1.0 = the usual full start
var seed: int                               # derived by the caller: fight_seed = session_rng.randi()
var log_enabled: bool = false               # the timeline log costs time; on for the terminal and replays

class_name FightResult extends RefCounted      # the result of Combat AC-CB-06
enum Winner { A, B, DRAW }
enum Ending { KNOCKOUT, DRAW, FLIGHT }      # FLIGHT once escape is ported (the sim defers escape today)
var winner: Winner
var ending: Ending
var seconds: float
var a_end: FighterEnd                       # typed: end health, linh lực, `wound` (NONE, GRAVE, MORTAL), resources spent
var b_end: FighterEnd
var deciding_layer: int = -1                # Combat AC-CB-06; -1 for a soul win, a draw or a flight
var life_costs: Array[LifeCost] = []        # costs and gains that outlive the fight, for the caller to apply
var log: Array[FightLogRow] = []            # empty unless log_enabled

class_name RatingProfile extends RefCounted
static func of(p: FighterProfile, gd: GameData) -> RatingProfile
static func clash(a: RatingProfile, b: RatingProfile, gd: GameData, rng: RandomNumberGenerator) -> Dictionary
```

### Implementation Guidelines
- The engine **must** be `RefCounted` logic with no Node, scene, autoload, session or World DB reference; inputs are
  profiles, data and an RNG.
- Every number **must** come from `assets/data` (combat files) or the profile; constants mirrored in the sim **must**
  have one source, the data file, which the sim reads too.
- A fight **must** use exactly one `RandomNumberGenerator`, seeded from `FightRequest.seed` (the caller derives it
  from the session stream with `randi()`); the engine **must never** call the global random functions, including
  `Array.shuffle()`, `pick_random()` and the global `randi_range()`. A chance roll is always drawn when its event
  fires, then compared, so a skipped condition never shifts the stream.
- Time **must** be integer milliseconds in both engines. At each moment both sides act, which side goes first **must**
  be a coin drawn from the fight's own random stream (in the sim, its separate order stream), at each pulse and each
  action step; within a side, arts run in slot order. Both engines **must** also offer a fixed order (side A before
  side B), used only by the exact parity fixtures, since the two engines' random streams differ. (Amended 2026-11-13,
  user decision: a fixed A-first order decided an exact mirror for A every time; the coin flip gave 70 / 70 / 60 draws
  over 200 seeds.)
- A `FightLogRow` **must** be built only when `log_enabled` is true.
- A `FighterProfile` is shared and cached, so a `Fight` **must** copy into its `FighterState` everything it changes;
  it **must never** mutate the profile.
- The Effect interpreter **must** cap recursion (events raised by Effects) at the Combat GDD's trigger depth; a stack
  overflow in a headless build kills the process.
- Classes **must** pass dependencies through constructors or indices, never back-pointers between `Fight` and its
  parts (cyclic RefCounted references leak and cyclic `class_name` references fail to parse).
- CI and every headless test run **must** run `godot --headless --import` first, so new `class_name`s are cached.
- Effect records **must** be validated at load; an unknown event, action, mod key, dtype, element or readable **must**
  stop the load, never silently match nothing.
- A rule change **must** land in both engines in the same change, with its mechanism test in both, and the parity
  suite **must** pass.
- The world tick **must never** run the full engine for NPC-against-NPC fights; it uses the rating profile.
- Typed variables and typed arrays **must** be used in the hot loop (GDScript compiler optimisations), and overrides
  with typed returns **must** return explicitly (Godot 4.7).

## Alternatives Considered

### Alternative 1: GDExtension (C++) engine, or embedded Python
- **Description**: Write the engine in C++ as a GDExtension, or call the existing Python sim from the game.
- **Pros**: Faster; the Python route reuses the sim as is.
- **Cons**: Leaves the project's GDScript stack and toolchain; a native build per platform; embedding Python is not
  supported by Godot and complicates export.
- **Rejection Reason**: Fights are a few milliseconds in Python, so speed is not expected to be the constraint; one
  language keeps the code testable and maintainable by the existing pipeline. Reopened for the Effect runner alone if
  the first story's timing misses the budget.

### Alternative 2: Keep a one-roll duel, computed from the rating profile
- **Description**: Never run full fights; every fight is Formulas K's closed-form clash.
- **Pros**: Cheapest; already designed for the world tick.
- **Cons**: Statuses, Effects, triggers, held payloads and engines (multi-step arts) do not exist in a closed form; the
  player's build would matter only through averages; no fight log.
- **Rejection Reason**: The game's identity is builds made of Effects and engines; they need the real timeline. The
  rating profile is kept for the world, where cost matters.

### Alternative 3: Effects as GDScript classes
- **Description**: Each Effect is a script class instead of a JSON record.
- **Pros**: Type-checked, faster to run.
- **Cons**: Every Effect is written twice (sim and game) and can drift; content authors cannot add Effects as data.
- **Rejection Reason**: User decision 2026-11-13: one JSON format for both engines.

## Consequences

### Positive
- Items, techniques, arts and Effects act in the game as designed; builds matter in play.
- The design sim and the game cannot silently disagree: the parity suite fails first.
- Content authors keep writing Effects as data for both engines.
- `display_power` replaces the chiến lực total with a number grounded in the real fight model.

### Negative
- Two engines to maintain until (or unless) the sim is retired; every rule change is a two-place change.
- A large port (about 1,600 lines of Python, 49 mechanism tests) before the game benefits.
- Chancy fights cannot be compared seed for seed across engines, only statistically.

## Risks
- **Porting hazards for exact parity.** Python's `round()` rounds halves to even and GDScript's away from zero; `//` and
  `%` differ on negative operands; GDScript `int / int` truncates where Python's `/` does not; Godot's JSON parser
  returns every number as a float, so counts and ids need `int()`. Mitigation: the port avoids rounding in the fight
  loop, casts every division explicitly, and the chance-free fixtures include negative values, halves and integer
  data so each hazard has a test.
- **Parity drift** (a rule changed in one engine only). Mitigation: the parity suite in CI; the guideline that rule
  changes land in both.
- **Performance of the GDScript hot loop** (Effects run on every event; dictionary-heavy GDScript can be many times
  slower than Python). Mitigation: Effects compiled to typed `EffectDef`s indexed by event, typed state, the log off
  by default; the first story measures in a headless **export** build (the editor and debug builds are much slower)
  across several fight shapes (a 30–60 s mirror, a long stall, a many-Effect build), judging the p95, not the mean.
  Fallback if the budget is missed: move only the Effect runner to a GDExtension (Alternative 1, reopened for that
  part only).
- **The fighter compiler guesses** where game data is thin (no art system for some sources yet, the parked Meridian
  Map). Mitigation: the compiler reports what it could not compile, like the sim's UNMODELLED lines, never silently.
- **Godot 4.7 specifics** past the LLM cutoff. Mitigation: plain GDScript the codebase already uses; verify
  determinism and timing in a headless export early. Typed dictionaries (`Dictionary[K, V]`) are not covered by the
  engine reference docs, so the design prefers typed RefCounted objects for fixed-shape data.
- **GDScript has no immutable objects.** A cached profile mutated by a fight would corrupt the next one. Mitigation: the
  copy-into-state guideline, and a parity fixture that runs the same profiles twice and compares.
- **Engine validation** (godot-specialist, 2026-11-13): no blocking issues; the notes above came from it. Its points on
  GDScript speed, PCG32 determinism and the class cache come from general knowledge, not the reference docs, and the
  first story verifies them.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| combat.md | The timeline, arts, costs and cooldowns (Formulas A, A2, C, E), realm suppression (H), evade (I), companions (J) | Ported into `Fight`, with the sim's tests as parity tests |
| combat.md | Rating profile and display_power for mass and world fights (Formulas K) | `RatingProfile` from the same compiled profile; the world tick uses it |
| combat.md | Event Engine row and rule 1: a fight request with the situation, ground tags, `no_heal` and optional starting shares; AC-CB-06: the result (winner, ending, time, end health, linh lực and wound, resources spent, deciding layer, costs and gains, log), returned synchronously without touching the character or the world clock | `FightRequest` / `FightResult` via `CombatService.resolve`, whose fields follow AC-CB-06 one for one |
| combat-defence.md | The defence path per hit part, ward payments and slots, shields, block, healing, fatigue | Ported into `DefencePath` and the ward model; armour's own ward slot in the compiler |
| combat-damage-types.md | Damage types, conversion, which shields each type passes | Ported with the defence path; Effects filter by final type |
| effects.md | Effect records, the Status Catalogue, the Down step, counted chance | `EffectRunner` interprets the shared JSON records; statuses and the Down step ported |
| modifiers.md | Combat stat keys, scopes, more and increased | Read from the stat sheet by the compiler; scoped keys become scoped Effect mods |
| item-database.md | Rules 11 and 21: worn pieces' arts, wards, Effects and reserve arts | The compiler reads `EquipSlots` and each piece's arts, wards, Effects and reserve arts |
| character-stats.md | The combat keys and the pools | The compiler reads them from the stat sheet |

## Performance Implications
- **CPU**: one fight is about 2–4 ms in the Python sim; the budget for GDScript is under 50 ms per one-on-one fight
  in a headless build. Fights are rare events (player encounters), never per frame. World fights use the closed-form
  rating profile.
- **Memory**: one fight holds two fighter states and a log; negligible. Compiled profiles are cached per character.
- **Load Time**: Effect records are validated and indexed once at data load.
- **Network**: None.

## Migration Plan
1. The parity harness first: fixture format, a Python exporter, the GdUnit runner, and the timing check.
2. Port in slices, each with its mechanism tests and parity fixtures: the timeline and basic damage; the defence path
   and wards; stacks, statuses and curses; the Effect interpreter; multi-step arts and empowers.
3. `FighterCompiler` from a Character, reporting what it cannot compile.
4. `CombatService` behind a flag in the Event Engine's combat check; the debug terminal prints the fight log.
5. `RatingProfile` for the world tick and `display_power` on screens; then remove `CombatPower.duel`.

## Validation Criteria
- All 49 ported mechanism tests pass in GdUnit with the sim's numbers.
- Every chance-free parity fixture matches exactly; every chancy fixture matches within 5 % mean time and 0.05 win
  share over 1,000 seeds.
- A fight resolves in under 50 ms in a headless export build.
- The typical mirror lasts 30–60 s at every realm in the Godot engine, as in the sim.
- The Formulas K agreement test passes against the Godot engine.

**Status 2026-11-14 (Migration Plan step 2 done):** every engine slice is ported (commits 4e7c0f7 to the slice-5 commit).
- Mechanism tests: 44 of the sim's 49 are ported with the same numbers and pass; the other 5 (t_parse_ward,
  t_armour_ward_slot, t_static_lines, t_layer_budget, t_field_budget) test fight.py's build-file loader and move with
  step 3, the FighterCompiler.
- Parity: every chance-free fixture matches event by event within 1e-6; every chancy fixture matches over 1,000 seeds
  (the sim's reference over 10,000).
- Performance: worst p95 23.4 ms of 50 in a headless release export (production/qa/evidence/combat-port/).
- The typical mirror lasts 34.6, 38.4, 43.8, 52.4 and 59.6 s at realms 0-4 in the Godot engine (sim: 34.7, 38.3, 43.8,
  52.2, 59.8); realm 4 sits at the top of the target.
- The Formulas K agreement test waits for step 5 (the rating profile).

**Status 2026-11-14 (steps 3 and 4):**
- Step 3 done: `FighterCompiler.compile(c, gd, db, sheet, report, errors)` with the realm's typical layers (user
  decision 2026-11-14, until the Meridian Map), from `assets/data/combat_library.json` and `combat_engine.json`
  CHARACTER_MODS. Its build-file step (`BuildFileCompiler`, a port of fight.py's `expand_library()` and `to_build()`)
  matches fight.py on 58 cases holding every named item and every art (`tests/parity/compile_parity_test.gd`); that
  covers the 5 build-file mechanism tests' ground (ward parsing, armour ward slots, static lines) except the layer and
  field budgets, which are designer observations and stay in fight.py.
- Step 4: `CombatService` runs an event's combat check when `combat_rules.json` `fight_engine.enabled` is on (off in
  the shipped data); the seed is one `randi()` from the session stream (ADR-0002); a side that cannot compile falls
  back to the duel. A draw or the time limit fails the check. The debug terminal's fight log is not done yet.
- Engine fixes found by the compile (both engines, fixture `t7_fixes_exact`): a step's own `hp_cost`; the Down step's
  events (`down` at step 2, `refused` after a refusal; refusals read their conditions); `strip`'s tie order; stacking
  None statuses ignore a recast.

## Related
- `design/gdd/combat.md`, `combat-defence.md`, `combat-damage-types.md`, `effects.md`, `modifiers.md`,
  `item-database.md`, `character-stats.md`
- `tools/design/combat_sim/` (the sim: `engine.py`, `fight.py`, `effects_library.json`, `FIGHT-INPUT.md`)
