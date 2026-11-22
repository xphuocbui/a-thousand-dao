# ADR-0003: Fight-Based Power Ratings

## Status
Accepted (2026-11-14, by the user). Drafted the same day by the assistant from the user's Power Rankings decisions.
Amended 2026-11-22 (decision 13, worker processes; user decision). Amended 2026-11-22 again: decision 13's batch-time
target accepted as measured (user decision).

## Date
2026-11-14

## Last Verified
2026-11-14 (decision 13 added 2026-11-22)

## Decision Makers
The user (the design decisions, in `design/gdd/power-rankings.md`), with the assistant drafting.

## Summary
Every fighter's power is measured by running real fights through the ADR-0001 engine: a ladder-panel base when its
build changes, an Elo offset learned from seasonal matchmaking and round robins, all seeded from keyed streams and
run off the main thread in a seasonal batch whose results are applied in a fixed order. This amends ADR-0001's
Migration Plan step 5, which planned a closed-form rating profile for the world tick and displayed power.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (4.7.1 installed) |
| **Domain** | Core (scripting, threading) |
| **Knowledge Risk** | MEDIUM: background work uses Godot's `WorkerThreadPool`, which is NOT SOURCEABLE: `docs/engine-reference/godot/` does not cover threading |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`; ADR-0001 (engine, timing); ADR-0002 (streams) |
| **Post-Cutoff APIs Used** | None knowingly; `WorkerThreadPool` exists since Godot 4.0 but its 4.7 behaviour is unverified here |
| **Verification Required** | (1) A spike: 1,000 fights on `WorkerThreadPool` tasks in a release export, results identical to a single-threaded run, no main-thread frame over 33 ms. (2) If (1) fails, the time-sliced fallback below |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (fights, `FighterCompiler`, `CombatService`), ADR-0002 (keyed streams, one draw per world fight) |
| **Enables** | Power Rankings implementation; removing `CombatPower.duel` |
| **Blocks** | ADR-0001 Migration Plan step 5 as written (its closed-form `RatingProfile` for display and world duels) |
| **Ordering Note** | Accept before Power Rankings stories start |

## Context

### Problem Statement
The world needs one power number per fighter and a way to decide NPC-against-NPC fights. ADR-0001 step 5 planned a
closed-form rating profile (Combat Formulas K). The user chose ratings measured from real fights instead (Power
Rankings GDD): builds count for what they do in fights, with no formula to maintain per mechanic.

### Current State
Fights run deterministically in GDScript at about 6 ms each (measured on a generated world, editor binary; the release
build is about 25 % faster). `CombatPower.duel` decides world fights from chiến lực. Measured costs: compile 0.5 ms a
fighter, panel 16 ms a fighter, a Nguyên Anh and Hóa Thần round robin 1.7 s.

### Constraints
- Determinism per seed (TR-sim-001): ratings must not depend on thread scheduling.
- ADR-0002: rating fights never draw from the session stream.
- A turn must never wait on rating work beyond the player's own panel (about 100 ms).
- Saves must resume ratings and the season's pending work exactly.

### Requirements
- About 10,000 fights a season in the background (Power Rankings Formulas, Season budget).
- A world fight costs microseconds and one session draw.

## Decision

1. **A `RatingService` owns ratings** (`src/gameplay/combat/ranking/`). Per fighter it stores `base`, `offset`,
   `n` (rated fights), `state` (Provisional, Rated, Stale, Gone) and the data version of its last panel, on the
   person record. It reads `assets/data/combat_rankings.json` through `GameData`.
2. **A seasonal batch.** At each season boundary the service builds the season's work list (Power Rankings Core
   Rules rule 14 order): compiles every fighter it needs on the main thread (compiling reads the World DB, which is
   not shared across threads), then hands the fights, with their compiled profiles and keyed seeds, to background
   tasks. Each task owns its own `CombatService`; compiled profiles and `GameData` are read-only once handed over.
3. **Results apply in a fixed order.** Finished fights are collected and applied on the main thread, ordered by the
   pair's fighter ids, so ratings never depend on which task finished first. Pairing reads start-of-season ratings;
   the fights read no ratings.
4. **Keyed seeds.** A rating fight's seed is `RngUtils.stable_hash("rank:<game seed>:<season>:<id a>:<id b>")` with
   the ids sorted, plus the fight's index within the pair (ADR-0002 decision 4). *Amended 2026-11-14 (design review):*
   a panel fight has a ladder rung instead of a second fighter, so its seed is
   `RngUtils.stable_hash("rankp:<game seed>:<season>:<fighter id>:<realm>:<rung k>")` plus the fight's index among that
   fighter's panel fights against that rung in the season (across all its panels that season); world-generation panels
   use season 0. Only world fights draw from the
   session stream, one draw each.
5. **The player's panel is synchronous** at the end of the action that changed the player's build (about 100 ms, on
   the action's thread, once per build); everything else is background work. Amended 2026-11-22 by ADR-0006 decision 1
   (reads never change the world); it was "when the player opens a Stale power number".
6. **Calibration is data.** Ladder rung ratings (Power Rankings Formulas C) are computed by a Godot
   tool script once per data version (a hash of the combat data files) and stored in `combat_rankings.json`, so a
   game never calibrates at load. A data version mismatch at load marks every fighter Stale.
7. **A feature flag** (`combat_rankings.json` `enabled`). Off, the power number is chiến lực and world fights use
   `CombatPower.duel`. `CombatPower.duel` is removed once the flag has been on and signed off in play.
8. **Wars keep `rating_clash`** (Combat Formulas K) with members ranked by the new power number; the closed-form
   profile survives only for mass clashes.

9. **Amendment (2026-11-14, design review of Power Rankings): panels at world generation** (*superseded by decision
   12: coarse panels at load*). A new game's
   world-generation panels (about 64,000 fights for 5,000 NPCs, Power Rankings rule 16) run while the game loads,
   outside any season budget, on the same background tasks, so a new world starts with every NPC Rated.
10. **Amendment: `panel_budget_share`** (default 0.5, safe range 0.3-0.7) caps the share of `season_fight_budget`
    panels may use in a season; unused share goes to round robins and matchmaking (Power Rankings rule 14).
11. **Amendment: injury in world fights.** A world fight's roll rating is lowered by
    `400*log10(max(v, injured_power_floor))` (Power Rankings Formulas F); the stored rating is untouched.
    *Superseded by decision 12:* the factor is the measured `health_elo` (about 3,000), not 400.
12. **Amendment (2026-11-14, from measured fights): ladder panels and measured anchors.** Fights are sharp (×1.2
    strength is about 250 Elo; a realm is about ×29 in typical-health terms, about 4,400 Elo), so a fixed 3-4 member
    panel cannot resolve NPCs that spread about 3,000 Elo within a realm (`design/research/power-rankings-measurements.md`).
    - **Panels search a ladder** of the realm's typical fighter scaled from ×1/256 to ×256 (65 rungs, about 240 Elo
      each) and solve the base over the probed rungs (Power Rankings Formulas B): about 12-16 fights warm, 20-32
      cold. The top-end member is gone.
    - **Calibration (decision 6) now stores** the anchors above Luyện Khí (measured, not 400 apart), every rung's
      rating and `health_elo`, computed by the export tool once per data version (about 128,000 reference fights,
      about 40 s on `fight.py`); a saturation guard fails calibration when adjacent rungs are too far apart.
    - **World generation (supersedes decision 9):** the player's full panel and coarse panels (2 fights a probe,
      stopped at a 4-rung bracket) run at load for the NPCs of Kết Đan and above, then those at the player's starting
      place, capped at `worldgen_fight_budget` (8,000 fights, about 40 s); they start Stale, every other NPC
      Provisional, and the season batch refines them (*amended 2026-11-14 after the spike: a coarse panel per NPC,
      about 50,000 fights, measured about 4 minutes at load*).
    - **Fight cost (measured by the spike, release export):** 12.3 ms a real NPC fight single-threaded, about
      ×2.5 on 16 cores through `WorkerThreadPool`, about 200 fights a second
      (`production/qa/evidence/combat-port/rating-spike-2026-11-14.md`).
      Budgets are counted in fights, so the design holds; only wall time per season changes.

13. **Amendment (2026-11-22, user decision): rating batches run in worker processes.** A season batch's fights
    (panels and pair fights) run in N worker processes started from the game's own binary: headless copies that load
    the game data, rebuild the fighters from build files and run their share. `WorkerThreadPool` threads stay the
    fallback.
    - **Why:** inside one process threads cap at about ×2.5 on 16 cores; processes scale almost linearly (×6.6 measured
      end to end, `production/qa/evidence/combat-port/thread-vs-process-scaling-2026-11-15.md`). A 10,000-fight batch
      drops from about 49 s to about 18 s, which lets Power Rankings rule 13 (one season late, 2026-11-22) hide the wait
      at Civ-style turn speed (measured on threads 2026-11-22: back-to-back End turns waited 56-176 s).
    - **Hand-over:** in Godot's binary Variant format only (`store_var` / `get_var` through files under `user://`),
      never JSON: its float parse is not correctly rounded and broke 1,652 of 3,000 results in the spike.
    - **Determinism:** results come back and apply in rule 13's fixed order, so ratings are identical to a threaded or
      single-threaded run; a parity test proves it for a full season batch. Workers read the game data from disk, so
      the coordinator sends a hash of the fight data it holds and a worker whose data differs refuses its share.
    - **Failure:** a worker that crashes, times out (`rating_worker_timeout`) or returns bad data has its share run on
      threads instead; the results are the same, only slower.
    - **Knobs** (`combat_rating_workers.json`, not `combat_rankings.json`: that file is rewritten by the calibration
      exporter and its `data_version` hashes its knobs, so a worker setting there would mark every fighter Stale):
      `rating_workers` (worker count; -1 means the core count minus 2, capped at `rating_workers_max` 12; 0 means threads
      only) and `rating_worker_timeout`.
    - **Platforms:** desktop only; where child processes are not allowed (consoles, mobile) or the knob is 0, threads.
    - **Not sourceable:** that `-s` script entry and `OS.create_process` behave the same in an exported release build is
      NOT SOURCEABLE from `docs/engine-reference/godot/`; the 2026-11-15 spike observed it with the release preset, and
      a release-export check is part of validation.
    - **Validation:** (1) a full season batch gives results identical to threads; (2) a 10,000-fight batch within 20 s
      on the development PC; (3) back-to-back End turns measured with ratings on; (4) a forced worker failure falls back
      cleanly.
    - **Validation results (2026-11-22, `production/qa/evidence/combat-port/worker-processes-2026-11-22.md`):**
      (1) and (4) pass (`tests/unit/ranking/rating_workers_test.gd`). (2) **not met:** the first season's 10,000-fight
      batch takes 49 s on 12 workers (116 s on threads); the rest is built into rule 14 (each panel wave lasts as long as
      its longest panel, and the waves are sequential). (3) measured: with about 30 s spent on a season, End turn takes
      about 3 s; pressing through seasons with no pause waits 30-48 s a season. Release export not yet checked.
    - **Target accepted as measured (user decision 2026-11-22):** validation (2) now reads "about 50 s for a
      10,000-fight batch on 12 workers on the development PC". The wait shows only when ending turns back to back;
      after a normal pause End turn takes about 3 s (greybox 2026-11-22: 2.7 / 49 / 49 / 32 s back to back). Revisit
      with the release-export check, or if playtests show players pressing through seasons.
    - **As built:** workers start once per batch and serve all its waves (start-up was about 1.5 s a wave); tasks are
      dealt round robin; each batch has its own pool sharing one data snapshot (the coordinator's data in memory,
      `DataRegistry.files()`, so in-memory changes reach the workers and no data hash is needed); one batch at a time
      uses workers.

### Fallback if `WorkerThreadPool` does not verify
Run the batch time-sliced on the main thread: a fixed number of fights per frame (about 2 at 6 ms within a 16.7 ms
frame) spread across the season. The result is identical (same order of application, same seeds); only wall time
grows.

### Architecture Diagram
```
season boundary ─► RatingService.plan(season)  (main thread: work list, pairing from start-of-season ratings,
                                                 compile profiles, keyed seeds)
                        │
                        ▼
              background tasks: CombatService.resolve(request) ─► results
                        │
                        ▼
              RatingService.apply(results)      (main thread, ordered by pair ids: panels → base, fights → offsets)

world tick duel ─► RatingService.world_fight(a, b, session_rng)  (Formulas F, one draw)
```

### Key Interfaces
```gdscript
var rs := RatingService.new(gd, db, builds)
rs.mark_stale(person_id)                         # a build change (Power Rankings rule 5)
var plan: RatingPlan = rs.plan(game_seed, season)
var results: Array = rs.run(plan)                # background; or time-sliced
rs.apply(plan, results)
var p: int = rs.power_number(person_id)          # Formulas E
var a_wins: bool = rs.world_fight(a_id, b_id, session.rng)
```

## Alternatives Considered

### Alternative 1: ADR-0001 step 5 as written (closed-form RatingProfile)
- **Description**: Combat Formulas K's `display_power` and `rating_clash` from a compiled profile, no fights.
- **Pros**: Microseconds, no background work.
- **Cons**: Every mechanic needs a closed-form term; Effects, engines and synergies are approximated or missed, so
  the shown power drifts from what fights do.
- **Rejection Reason**: The user chose fight-based ratings (Power Rankings GDD).

### Alternative 2: A full round robin of every fighter
- **Description**: Every pair fights each season.
- **Pros**: Exact rankings.
- **Cons**: About 12.5 million fights a season, about 17 hours.
- **Rejection Reason**: Cost.

## Consequences

### Positive
- The shown power is what fights produce; builds count without per-mechanic formulas.
- World fights become cheaper than the duel's power compute.

### Negative
- About a minute of background compute a season; a save holds the season's pending work.
- Provisional ratings at world generation until panels run.

### Neutral
- The closed-form profile stays for mass clashes only.

## Risks
- **`WorkerThreadPool` unverified (NOT SOURCEABLE).** *Verified 2026-11-14:* the spike passed (identical results,
  main-thread gaps under 7.1 ms).
- **Thread scaling.** GDScript threads scale only about ×2.5 here: string, StringName and dictionary reference traffic
  and allocations serialise cores, and the fight engine is string-keyed (probe in the spike evidence). Mitigation:
  budgets are counted in fights and the load set is capped; an integer-keyed hot loop is Power Rankings Open
  Question 9.
- **Budget starvation** (the Kết Đan yearly round robin uses about 60 % of a season's budget). Mitigation: Power
  Rankings Open Question 5.
- **Calibration out of date** after a combat data change. Mitigation: the data version hash marks fighters Stale.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| power-rankings.md | Rules 4, 7, 8, 14: panels, matchmaking, round robins in a season budget | The seasonal batch (decisions 2, 3) |
| power-rankings.md | Rule 13: determinism, no session draws | Keyed seeds, fixed application order (decisions 3, 4) |
| power-rankings.md | Rule 10: one power number | `RatingService.power_number` (Formulas E) |
| power-rankings.md | Rule 11: world fights | `RatingService.world_fight`, one session draw |
| combat.md | Formulas K (`display_power`) | Replaced by the power number; `rating_clash` kept for wars |

## Performance Implications
- **CPU**: about 10,000 fights a season (about 60 s on one core, less across worker threads), off the main thread.
- **Memory**: compiled profiles for a season's fighters (a few MB at 5,000 fighters).
- **Load Time**: none (calibration is data).

## Migration Plan
1. Accept this ADR (done 2026-11-14); amend ADR-0001's Migration Plan step 5 to point here (done).
2. The `WorkerThreadPool` spike.
3. `RatingService` with panels and provisional ratings, behind the flag.
4. Matchmaking, round robins, the season batch and saves.
5. The power number on screens and records; world fights by rating; sign off; remove `CombatPower.duel`.

## Validation Criteria
- Power Rankings AC-PR-51 (performance) and AC-PR-52 (determinism) pass.
- The spike in Engine Compatibility passes, or the fallback is in place.

## Related
- `design/gdd/power-rankings.md`, `design/gdd/combat.md` (Formulas K), ADR-0001, ADR-0002,
  `design/research/fighter-compiler-questions.md`
