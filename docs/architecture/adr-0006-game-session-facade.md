# ADR-0006: GameSession Facade and Frontend Rule

## Status
Proposed

## Date
2026-11-22

## Last Verified
2026-11-22

## Decision Makers
The user (the facade and the terminal exemption, 2026-11-13; "query module", "one job, nothing read meanwhile",
"pure peek, refresh in actions", "events in the result" and "revise all", 2026-11-22), with the assistant drafting;
reviewed by godot-specialist (one blocking issue, resolved by decision 6) and technical-director (TD-ADR: CONCERNS;
both blocking concerns resolved by decisions 1 and 7, the rest folded in).

## Summary
Every frontend (the debug terminal, the Game UI) talks to the headless simulation through `GameSession`, but the rule
for what a shipped frontend may read existed only as a paragraph, the greybox reads around it, some "reads" write the
world, and actions now run on a worker thread that no rule covers. This ADR fixes the boundary: actions, jobs and
read-only methods on `GameSession`; every other read through a read-only query module (`GameQuery`) that returns
copies; reads that never change the world; one job at a time off the main thread with nothing read meanwhile; events
in each action's result; and the debug terminal still exempt.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (installed 4.7.1) |
| **Domain** | Core (scripting architecture; threading) |
| **Layer** | Presentation (the application facade and the Guidance reads, `docs/architecture/architecture.md` Module Ownership) |
| **Knowledge Risk** | LOW for the facade (plain `RefCounted` GDScript); MEDIUM for the threading rule: the engine reference has nothing on `Thread`, `Mutex`, `call_deferred` or signals across threads (godot-specialist grep, 2026-11-22) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md`, `deprecated-apis.md`, `current-best-practices.md` |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (1) `RefCounted` session objects made on the main thread and used by one worker thread at a time are safe: NOT SOURCEABLE; the one-job rule is what guarantees single access. (2) A GDScript runtime error inside a job's Callable makes `BackgroundCall.finish()` return `null`: NOT SOURCEABLE; **checked 2026-11-22 on 4.7.1** (a probe script hit an invalid key inside the job: `finish()` returned `Nil`), and the frontend treats any non-Dictionary result as a failed action. (3) `Dictionary.duplicate(true)` gives a deep copy of nested Dictionaries and Arrays on 4.7 (the master architecture's deferred `.duplicate(true)` vs `duplicate_deep()` check, moved here because `GameQuery` relies on it): NOT SOURCEABLE; the `GameQuery` copy test mutates a nested value. |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0002 (random streams: one session stream; Accepted). ADR-0003 decision 13 (the background rating batch works on its own snapshot; Accepted). ADR-0005 (the tooltip layer's `busy` guard, one of the read paths decision 5 relies on; Proposed). ADR-0005 and this ADR depend on each other: 0005's greybox exemption ends here, and this ADR's "nothing read during a job" relies on 0005's guard for tooltips; they can be Accepted together. |
| **Enables** | Required ADR #9 (Game UI framework). Every window spec (person, sect, trade, abode) builds on `GameQuery`. |
| **Blocks** | The real windows of the Game UI (#37): they must not be built on direct reads. |
| **Ordering Note** | Migration Plan order: the power-read fix and the deferred-safety test come before the greybox migration. |

## Context

### Problem Statement
`docs/architecture/architecture.md` (API Boundaries 1, Data Flow 1) says a shipped frontend uses only `GameSession`'s
methods plus `StateSnapshot` / `Advisor`, and that the debug terminal is exempt. That is no longer enough:
1. The Game UI greybox reads around it: `session.db` 29 times, `session.player` 25, `session.knowledge`,
   `session.market`, `session.items`, `session.pending_event`, `session.year`, `session.season`, and it borrows
   `TerminalViews` (survey 2026-11-22). Its tooltips run under a named exemption in ADR-0005.
2. A record from `WorldDB.get_record` is the live Dictionary, so a UI that reads it can change the world by accident;
   `Advisor.best_pill()` returns one today.
3. **Some reads write.** `player_power()` calls `sync_player()` (a `db.put`) and `RatingService.refresh_person()`
   (which creates or changes rating records), and on a stale rating runs a rating panel of fights on the caller's
   thread; `power_of_person()` writes through `refresh_person`; `StateSnapshot.take()` calls `player_power()`, and the
   greybox calls it on every refresh. So redrawing the HUD changes the world and can stall the screen, and a game
   played in the UI can drift from a headless run with the same seed (technical-director review, 2026-11-22).
4. Actions now run on a worker thread (`src/ui/turn/background_call.gd`). The architecture still says "none of them
   crosses a thread boundary today", nothing says what a frontend may do while a season resolves, and the session's
   two signals fire partway through an action.

### Constraints
- The simulation is headless and deterministic (Architecture Principle 1; TR-sim-001).
- Gameplay code is plain `RefCounted` logic, with no `Node` or autoload (Module Ownership).
- The debug terminal is not required to be refactored (user decision 2026-11-13).
- The UI must never block the game thread (`.claude/rules/ui-code.md`).

### Requirements
- One place defines what a shipped frontend may call and read, and it can be checked mechanically.
- Reads return copies and never change the world.
- Reads are headless-testable, like `StateSnapshot` and `Advisor`.
- A season resolves without freezing the screen, and nothing races it.

## Decision

**1. Reads never change the world.** A read (a `GameSession` read method, `StateSnapshot`, `Advisor`, `GameQuery`)
leaves `GameSession.to_dict()` and the session random stream's state exactly as they were. In particular the power
reads become **pure peeks**: `player_power()` and `power_of_person(id)` show the stored rating (a stale or provisional
one is marked `?`) and never sync, refresh or run a panel. The sync, `refresh_person` and the player's panel move
**inside actions**: at the end of any action that can change the player's build or realm (equip, unequip, learn,
use_item, tree_allocate, set_slot, breakthrough …) and in `_pass_season`, so they run on the job thread and the same
actions give the same world.

**2. `GameSession` has three kinds of method,** each doc comment saying which:
- **Actions** (`## Action.`), one per player action (`cultivate`, `travel`, `choose`, `buy` …): return
  `{ok: bool, lines: Array[String], events: Array, …}`, never throw, never print; `ok: false` leaves state unchanged;
  every time-passing action goes through `_pass_season`.
- **Jobs** (`## Job.`): `new_game`, `load_dict`, `to_dict` and `shutdown`. They do not take a turn but can be long, so
  they follow the one-job rule like actions. `to_dict` finishes the in-flight rating batch before it saves (up to
  about 50 s pressed back to back, ADR-0003), so saving runs off the main thread.
- **Read methods** (`## Read-only.`): `clock_label`, `season_index`, `has_pending_event`, `teleport_fee`, `clue_lines`,
  `abode_lines`, `work_lines`, `array_lines`, `ratings_on`, `player_power`, `power_of_person`, `death_lines`,
  `place_density`, `tree_starts`, `talisman_available`, `local_density`, `sheet`. `sheet()` builds a fresh `StatSheet`
  on each call (a frontend may read it, and must not keep one across a job); because it is rebuilt each time, a
  screen calls it once per refresh, not per readout.
- Methods that are neither are **internal** and a frontend never calls them: `start_event`, `meet`, `sync_player`,
  `event_context`, `migrate_tree_record`, `prune_removed_tree_nodes`. `sect_status()` uses the action shape for a read;
  it is split into a read method `sect_lines()` (Migration Plan).

**3. `GameQuery` holds every other read.** A new module beside `StateSnapshot` and `Advisor` in the Guidance layer
(`src/gameplay/session/game_query.gd`): static functions that take the session and return **deep copies** built for
the purpose, never a `WorldDB` record or a live service object. It is the one place a frontend's reads meet `db`,
`player` and the services, and it grows by need, screen by screen. It starts with what the greybox reads today:

| Function | Returns |
|---|---|
| `clock(s)` | year, season, season index, label |
| `player(s)` | id, name, location_id, home_id, realm_label |
| `here(s)` | the player's place: the record's fields copied, plus region_name, holder_name, land_match, here |
| `place(s, id)` / `known_places(s)` | the same shape for one known place / every known place |
| `people_met_at(s, place_id)` | people the player has met there: id, name, realm_label, line |
| `route_seasons(s, dest_id)` | the travel time by the game's own route (TravelGrid, roads as fallback), -1 for none |
| `has_clues(s)` | whether there are clue search areas to show |
| `pending_event(s)` | a copy of the pending event (title, text, choices) or `{}` |
| `market_lines(s, place_id)` | the market's goods there as display lines (stand-in until the trade window) |
| `breakdown(s, what)` | `{total, lines}` of a derived number: `"rate"`, `"lifespan"` |
| `level_requirement(s)` / `travel_factor(s)` | the cultivation bar's full mark; the player's travel speed factor |
| `place_lines(s, id)` / `sheet_lines(s)` | display lines for the stand-in panels (from the terminal's views), removed when their windows are designed |

`StateSnapshot` and `Advisor` follow the same rules: `Advisor.best_pill()` returns a copy. `Advisor.choice_odds()`
runs keyed trial fights (their own seeded stream, the session stream untouched) on the caller's thread; it is allowed
as a read and its cost is noted (Performance Implications).

**4. The frontend rule.** A shipped frontend (the Game UI, `src/ui/`) calls `GameSession` actions, jobs and read
methods, and reads through `StateSnapshot`, `Advisor` and `GameQuery`, nothing else: no other session member, no
`WorldDB` or service object, and none of the debug terminal's code (`TerminalViews`, `TerminalIO`). A scan test
(`tests/integration/ui/ui_frontend_rule_test.gd`) checks every `session.<member>` in `src/ui/` against the allowlist
of decision 2's actions, jobs and read methods, and fails on the terminal's names.

**5. The terminal exemption stays.** The debug terminal (`src/debug_terminal/`) is a debug and cheat tool: it may read
and write the session's members directly, and it does not set the standard for the Game UI (user decision
2026-11-13).

**6. Threading.** A frontend runs **at most one action or job at a time**, off the main thread (`BackgroundCall`), so
the screen keeps drawing. **While it runs, the frontend reads nothing from the session**: no read method, no Guidance
read, no `StatSheet` it kept from before; the HUD turns inert (hud.md, The turn) and the tooltip layer's `busy` guard
is on (ADR-0005). A result that is not a Dictionary is a failed action (Verification Required 2). The job's owner calls
`BackgroundCall.finish()` before it is freed (on `NOTIFICATION_PREDELETE` and the window's close request). ADR-0003's
background rating batch is not a session job: it works on its own snapshot (ADR-0003 decision 13).

**7. Events travel in the result.** What a frontend reacts to (a breakthrough, the end of a life, later others) is in
the action's result as `events: [{kind, …}]`, and the frontend acts on it after the job ends. The session's signals
(`life_ended`, `breakthrough_succeeded`) stay for the debug terminal and tests, fire partway through the action on the
job's thread, and **a shipped frontend does not connect to them**.

### Architecture Diagram
```
 Game UI (src/ui)                                    Debug terminal (exempt)
   │  actions / jobs, one at a time (BackgroundCall)     │ anything
   │     └─ result {ok, lines, events}                   │
   │  read methods ── only while no job runs             │
   │  StateSnapshot / Advisor / GameQuery (deep copies)  │
   v                                                     v
 GameSession  (clock, player, pending event, session RNG)
   │  actions: rules + sync / rating refresh at the end
   v
 Feature systems → Core → Foundation (WorldDB, GameData …)   ← reads look here, never write
```

### Key Interfaces
```gdscript
# GameSession: actions (## Action.)
func cultivate(seasons: int) -> Dictionary          # {ok, lines, events, ...}; also travel, choose, buy, equip ...
# GameSession: jobs (## Job.) — one at a time, off the main thread
func new_game(seed_v: int, spec: Dictionary) -> Dictionary
func load_dict(d: Dictionary) -> Dictionary
func to_dict() -> Dictionary                        # finishes the in-flight rating batch first
func shutdown() -> void
# GameSession: read methods (## Read-only.) — never change to_dict() or the RNG state
func has_pending_event() -> bool
func clock_label() -> String
func player_power() -> Dictionary                   # a peek: the stored rating, "?" when stale or provisional
func sheet() -> StatSheet                           # fresh per call; never kept across a job
# Signals: terminal and tests only; a shipped frontend reads result.events instead
signal life_ended(summary: Dictionary)
signal breakthrough_succeeded(realm_index: int)

# GameQuery (src/gameplay/session/game_query.gd): static, read-only, deep copies
static func clock(s: GameSession) -> Dictionary
static func player(s: GameSession) -> Dictionary
static func here(s: GameSession) -> Dictionary
static func place(s: GameSession, place_id: String) -> Dictionary
static func known_places(s: GameSession) -> Array
static func people_met_at(s: GameSession, place_id: String) -> Array
static func route_seasons(s: GameSession, dest_id: String) -> float
static func has_clues(s: GameSession) -> bool
static func pending_event(s: GameSession) -> Dictionary
static func market_lines(s: GameSession, place_id: String) -> Array
static func breakdown(s: GameSession, what: String) -> Dictionary   # {total, lines}
static func level_requirement(s: GameSession) -> float
static func travel_factor(s: GameSession) -> float
static func place_lines(s: GameSession, place_id: String) -> Array
static func sheet_lines(s: GameSession) -> Array

# GameSession: running an action for a frontend (## Job.)
func run(action: Callable) -> Dictionary            # the action's result plus events: [{kind, ...}]
func sect_lines() -> Array                          # ## Read-only. (the read half of sect_status)
```

### Implementation Guidelines
- A read (read method, `StateSnapshot`, `Advisor`, `GameQuery`) **must never** change state: `to_dict()` and the
  session RNG state are identical before and after it (`tests/unit/session/session_reads_test.gd` checks every read).
- A read **must never** run fights on the session stream or a rating panel; keyed trial fights on their own stream are
  allowed.
- Rating sync and refresh **must** happen inside actions (after a build or realm change, and in `_pass_season`).
- A shipped frontend **must** reach the simulation only through decision 2's allowlisted methods and the Guidance
  reads; it **must never** name another session member, a `WorldDB` or service object, `TerminalViews` or
  `TerminalIO`.
- `GameQuery`, `StateSnapshot` and `Advisor` **must** return deep copies, never a `WorldDB` record or live object.
- A new read a screen needs **must** be added to `GameQuery` with a unit test, not read in the screen.
- Every `GameSession` method **must** carry `## Action.`, `## Job.` or `## Read-only.`, or be internal; a method that
  both reads for the UI and acts is split.
- A frontend **must** run at most one action or job at a time and **must not** read anything from the session while
  it runs; it **must** treat a non-Dictionary result as a failure and call `finish()` before freeing the job.
- A shipped frontend **must not** connect to session signals; it acts on `result.events`.
- Gameplay code **must never** reference a frontend, a `Node` or a scene.
- The debug terminal is exempt from all of the above except the last.

## Alternatives Considered

### Alternative 1: Read methods on `GameSession` itself
- **Description**: Add every read the UI needs as a facade method (`session.known_places()`, `session.person(id)` …).
- **Pros**: One object to learn; reads sit beside the actions.
- **Cons**: The facade, already 2,000+ lines, grows by dozens of methods that are not actions; harder to test views
  alone.
- **Rejection Reason**: The Guidance layer (`StateSnapshot`, `Advisor`) already proves the pattern of read-only
  modules beside the facade; `GameQuery` follows it.

### Alternative 2: Direct reads by convention, no writes
- **Description**: Let the UI read `session.db` and `session.player` freely and ban only writes.
- **Pros**: No new code; the greybox already works this way.
- **Cons**: `get_record` returns the live Dictionary; the UI couples to the DB schema; "no writes" cannot be checked.
- **Rejection Reason**: It cannot be enforced and fails the copies requirement.

### Alternative 3: Actions on the main thread
- **Description**: Run each action on the main thread after showing "The world turns…" (the hud.md build note).
- **Pros**: No threading rule; signals arrive on the main thread.
- **Cons**: The screen freezes for the whole season: seconds, and tens of seconds with rating fights (ADR-0003).
- **Rejection Reason**: The UI must never block the game thread.

### Alternative 4: Power reads as actions
- **Description**: Keep `player_power()` as it is and class it an action, run as a job.
- **Pros**: No change to the rating code.
- **Cons**: The HUD needs a job just to show a number, and showing it still changes the world, so UI and headless
  runs still drift.
- **Rejection Reason**: Reads must not change the world (decision 1; user choice "pure peek").

### Alternative 5: Deferred signal handlers that store and wait
- **Description**: Keep the signals; the UI connects with `CONNECT_DEFERRED`, and its handlers only store the payload
  and act after `finish()`.
- **Pros**: No change to action results.
- **Cons**: Delivery order of deferred calls across threads is NOT SOURCEABLE; two channels for one fact.
- **Rejection Reason**: Events in the result are ordered with the result by construction (user choice).

## Consequences

### Positive
- One documented, mechanically checked boundary for every frontend; the terminal keeps its freedom.
- A game played in the UI gives the same world as a headless run with the same actions (reads never write).
- The UI cannot change the world by accident: it never holds a live record.
- The screen keeps drawing during a season, and nothing races the simulation.

### Negative
- Every new screen needs its reads added to `GameQuery` first.
- Copies cost allocation; screens cache large lists between turns.
- The power shown can lag a build change until the next action refreshes it (marked `?`).
- The rating refresh moves into several actions (a change to `game_session.gd`), and the greybox must be migrated.

## Risks
- **`GameQuery` becomes a dumping ground.** Mitigation: functions return data, not display text, except the named
  stand-in line functions, which are removed when their windows are designed.
- **A read slips in during a job** (a timer, a tooltip, a deferred call). Mitigation: the HUD's inert state, the
  tooltip layer's `busy` guard, and the scan test.
- **A missed refresh point** leaves the shown power stale after some build change. Mitigation: the read-only test
  plus a test per build-changing action that the rating record is refreshed by the action.
- **`Advisor.choice_odds()` is costly on the main thread** (24 trial fights per option). Mitigation: computed once
  when the card opens and cached for the card's life.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `design/ux/hud.md` (Game UI #37) | The turn: "While a season resolves" the HUD is inert and the screen keeps drawing | Decision 6 |
| `design/ux/hud.md` | Readouts, tooltips and windows show live state | Read methods and `GameQuery`, as deep copies |
| `design/gdd/power-rankings.md` | The shown power number; provisional ratings marked | `player_power()` as a peek, `?` when stale or provisional; refresh inside actions |
| `docs/architecture/architecture.md` TR-sim-001 | The same seed and actions give the same life | Decision 1 (reads never write), checked by the read-only test |
| `docs/architecture/architecture.md` API Boundaries 1 | The frontend rule and the terminal exemption | Decisions 4 and 5, checked by the allowlist scan |

## Performance Implications
- **CPU**: Copies on each read: negligible for one record, a few milliseconds for every known place (about 100 in a
  life); screens cache lists between turns. `sheet()` is rebuilt per call, so a screen calls it once per refresh.
  `Advisor.choice_odds()` runs its trial fights once per card. The HUD no longer runs rating panels on refresh.
- **Memory**: Short-lived copies only.
- **Load Time**: None.
- **Network**: None.

## Migration Plan
1. **Power reads first:** make `player_power()` / `power_of_person()` pure peeks; move the sync, `refresh_person` and
   the player's panel into the build-changing actions and `_pass_season`; add
   `tests/unit/session/session_reads_test.gd` (every read leaves `to_dict()` and the RNG state unchanged; watch it
   fail on today's `player_power` first).
2. **Thread safety tests:** a `BackgroundCall` test that a runtime error inside the Callable gives a non-Dictionary
   result, before any frontend relies on it.
3. Add `events` to action results (`breakthrough`, `life_ended`); mark every `GameSession` method `## Action.`,
   `## Job.` or `## Read-only.`; split `sect_status()` into `sect_lines()`; make `Advisor.best_pill()` return a copy.
4. Add `GameQuery` with the functions above and unit tests (copies checked by mutating a nested value).
5. Move the greybox (`src/ui/`) to the allowlist and Guidance reads; drop `TerminalViews` / `TerminalIO` from it; run
   saving and loading as jobs.
6. Add the allowlist scan `tests/integration/ui/ui_frontend_rule_test.gd`; watch it fail on a planted `session.db`.
7. Update ADR-0005 (its greybox exemption ends) and `docs/architecture/architecture.md` (Data Flow 1's "none of them
   crosses a thread boundary today" → decision 6; API Boundaries 1 → this ADR).

## Implementation Notes (2026-11-22)
- Built: the power reads are peeks (`RatingService.peek_person`); the sync, refresh and player panel run at the end
  of the build-changing actions (`_sync_and_rate`: use_item, equip, nurture, unequip, learn, set_slot, breakthrough,
  tree_allocate, tree_choose_start, choose, join_sect, promote, leave_sect); `GameSession.run(action)` hands back
  `events`; every public method carries its mark; `sect_lines()`; `Advisor.best_pill()` copies; `GameQuery`; the
  greybox migrated (`TurnController.after_turn(result, here_id)`); the allowlist scan (seen failing on a planted
  `session.db`); `tests/unit/session/session_reads_test.gd` (seen failing on the old `player_power`).
- Not yet done: the UI-driven against headless replay comparison (Validation Criteria 4).

## Validation Criteria
- `tests/unit/session/session_reads_test.gd` passes (and was seen failing on the old `player_power`).
- `tests/integration/ui/ui_frontend_rule_test.gd` passes on `src/ui/` and fails on a planted member read.
- `GameQuery` unit tests prove deep copies (a nested change leaves the `WorldDB` record unchanged).
- A UI-driven and a headless run of the same seed and actions give the same `to_dict()` (the greybox demo's actions
  replayed headless).
- The greybox demo passes its real-input checks at 1280×720 and 1920×1080 after the migration.

## Related
- `docs/architecture/architecture.md` (Module Ownership, Data Flow 1–2, API Boundaries 1, Required ADRs #2)
- ADR-0002 (random streams), ADR-0003 (background rating batch), ADR-0005 (tooltip layer; its exemption)
- `design/ux/hud.md` (The turn), `src/ui/turn/background_call.gd`, `src/gameplay/session/`
