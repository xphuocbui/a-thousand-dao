# ADR-0003: Fight-Based Power Ratings

## Status
Proposed (drafted 2026-11-14 by the assistant from the user's Power Rankings decisions; for the user to accept)

## Date
2026-11-14

## Last Verified
2026-11-14

## Decision Makers
The user (the design decisions, in `design/gdd/power-rankings.md`), with the assistant drafting.

## Summary
Every fighter's power is measured by running real fights through the ADR-0001 engine: a reference-panel base when its
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
   the ids sorted, plus the fight's index within the pair (ADR-0002 decision 4). Only world fights draw from the
   session stream, one draw each.
5. **The player's panel is synchronous** when the player opens a Stale power number (about 100 ms); everything else is
   background work.
6. **Calibration is data.** Non-anchor panel members' ratings (Power Rankings Formulas C) are computed by a Godot
   tool script once per data version (a hash of the combat data files) and stored in `combat_rankings.json`, so a
   game never calibrates at load. A data version mismatch at load marks every fighter Stale.
7. **A feature flag** (`combat_rankings.json` `enabled`). Off, the power number is chiến lực and world fights use
   `CombatPower.duel`. `CombatPower.duel` is removed once the flag has been on and signed off in play.
8. **Wars keep `rating_clash`** (Combat Formulas K) with members ranked by the new power number; the closed-form
   profile survives only for mass clashes.

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
- **`WorkerThreadPool` unverified (NOT SOURCEABLE).** Mitigation: the spike in Engine Compatibility, and the
  time-sliced fallback.
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
1. Accept this ADR; amend ADR-0001's Migration Plan step 5 to point here.
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
