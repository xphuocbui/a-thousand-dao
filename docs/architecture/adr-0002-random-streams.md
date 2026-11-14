# ADR-0002: Random Streams

## Status
Proposed (drafted overnight 2026-11-14 by the assistant for the user's review; not accepted)

## Date
2026-11-14

## Last Verified
2026-11-14

## Decision Makers
The user (to accept or change), with the assistant drafting. Required ADR 3 of architecture.md ("Random-stream
policy"), needed before ADR-0001 step 4 wires fights into the session.

## Summary
Every random draw in gameplay comes from a seeded `RandomNumberGenerator` passed in by its caller, never from Godot's
global random functions. One session stream drives a life; anything whose draws must not depend on what happened
before it uses a keyed stream seeded from a stable key, and a fight takes exactly one draw from the session stream
as its own seed. This records what the code already does and makes it binding.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (4.7.1 installed) |
| **Domain** | Core (scripting) |
| **Knowledge Risk** | LOW for `RandomNumberGenerator` (unchanged since 4.0 in the engine reference); see Risks for `hash()` |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `breaking-changes.md` (no RNG changes listed for 4.4-4.7) |
| **Post-Cutoff APIs Used** | None |
| **Verification Required** | (1) A save and reload resumes the session stream exactly (already a save/load AC). (2) `hash(String)` gives the same value across 4.7.x patch releases and platforms, or keyed streams use a hash we own (see Risks) |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0001 (fights take a seed from their caller) |
| **Enables** | ADR-0001 step 4 (`CombatService` draws a fight seed from the session stream) |
| **Blocks** | Nothing new; it constrains every system that draws |
| **Ordering Note** | Write before any new system adds its own randomness |

## Context

### Problem Statement
Pillar 2 and TR-sim-001 require that the same seed and the same actions give the same life, and the balance harness and
every parity test depend on it. Fights (ADR-0001) make many draws whose number depends on the fight; if they drew from
the session stream directly, any rule change inside a fight would shift every later event of the life.

### Current State
A survey of `src/` (2026-11-14) found no global random calls (`randi()`, `randf()`, `randomize()`, `Array.shuffle()`,
`pick_random()`); every draw goes through a `RandomNumberGenerator` instance:
- `GameSession.rng`: the session stream, seeded at `new_game`, saved as `rng_seed` and `rng_state` strings, restored by
  `load_dict`; passed to world generation, the world tick, events, cultivation and crafting.
- Keyed streams: `Market` seeds a local generator with `hash("<par>:<element>")`; `MeridianGenerator` seeds one with the
  config seed and one per variant with `hash("variant:" + id) ^ seed`.
- `Fight` (ADR-0001) seeds its own generator from the request's seed.

### Constraints
- Determinism per seed (TR-sim-001); saves must resume the same stream (TR-save-001).
- Tests use fixed seeds and scripted generators (`ScriptedRng`), so every draw site must take its generator as an
  argument (coding standards: dependency injection).

### Requirements
- A fight's internal draws must not shift the session stream by a variable amount.
- Values that must not depend on call order (a market's base prices, map variants) must be reproducible from a key.
- The LLM is not deterministic: its outputs that matter are stored, not regenerated (Quests already does this).

## Decision
1. **The session stream.** `GameSession` owns one `RandomNumberGenerator` for a life. It is seeded at `new_game` from the
   game seed and saved and restored with its state (as strings, so no float rounding). Systems receive it as an
   argument; none keeps a reference to it.
2. **No global random.** Gameplay code (`src/gameplay`, `src/core`) never calls Godot's global random functions,
   including `randomize()`, `Array.shuffle()` and `Array.pick_random()`. Frontends (the debug terminal) may use their own
   generators for presentation only.
3. **Derived seeds for self-contained runs.** A run that makes a variable number of draws on its own state (a fight)
   takes exactly one draw from the session stream as its seed (`fight_seed = session_rng.randi()`) and draws only from
   its own generator. Its internal changes never move the session stream.
4. **Keyed streams for order-free values.** A value that must be the same whenever and however often it is asked for is
   drawn from a generator seeded from a stable key (`seed = stable_hash(key) ^ game_seed`), created where it is used.
5. **Stored, not regenerated.** Nondeterministic outputs (LLM text and plans) that later play depends on are stored in
   the save.

### Architecture Diagram
```
new_game(seed) ──► session rng ──► world gen, tick, events, cultivation, crafts (passed as an argument)
                        │
                        └─ randi() ──► fight_seed ──► Fight's own rng (any number of draws)
key + game seed ──► stable_hash ──► keyed rng (market prices, map variants): same value every time
```

### Key Interfaces
```gdscript
# The caller derives the seed; the fight never sees the session stream.
var request := FightRequest.new()
request.seed = session.rng.randi()
```

### Implementation Guidelines
- A function that draws takes a `RandomNumberGenerator` parameter; tests pass a seeded or scripted one.
- A run with its own generator takes one draw from its caller for its seed, never more.
- Keyed streams use a hash the project owns (see Risks) and include the game seed.
- A review rejects a global random call in `src/gameplay` or `src/core` (a lint can grep for them).

## Alternatives Considered

### Alternative 1: Everything on the session stream
- **Description**: Fights and every other system draw from the session stream directly.
- **Pros**: One stream, nothing to derive.
- **Cons**: A change to any fight rule shifts every later draw of the life, so old seeds and regression baselines break
  with every combat change.
- **Rejection Reason**: Combat changes often; lives must stay comparable across them.

### Alternative 2: A named stream per system
- **Description**: World, events, crafts and fights each keep their own saved stream.
- **Pros**: Each system's draws are isolated from the others.
- **Cons**: More state to save; seeding several streams from one seed needs its own derivation; no current need.
- **Rejection Reason**: Derived seeds give fights the isolation they need; other systems can follow if one needs it.

## Consequences

### Positive
- Fights can change without moving the rest of a life; replays and regression baselines stay meaningful.
- Order-free values stay stable however the code that asks for them evolves.

### Negative
- One more rule to check in review (no global random).

### Neutral
- Records existing practice; no code changes are required to comply today.

## Risks
- **`hash(String)` stability.** Keyed streams today use Godot's `hash()`. The engine reference does not say whether its
  value is stable across engine versions or platforms (NOT SOURCEABLE from `docs/engine-reference`). If it changes in an
  engine upgrade, market base prices and map variants would change for existing saves. Mitigation (proposed): a small
  project-owned string hash (for example FNV-1a in `RngUtils`) for keyed streams, with a test pinning known values.
- **A system that keeps the session generator** (a back-reference) could draw at unexpected times. Mitigation: pass it
  as an argument only.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| All (TR-sim-001) | The same seed and actions give the same life | One saved session stream; no global random |
| combat.md, ADR-0001 | A fight is seeded by its caller and does not touch the session | Derived fight seed (decision 3) |
| quests.md (TR-quests-001) | A stored quest brief is fixed | Stored, not regenerated (decision 5) |
| canh-gioi.md, linh-can.md and others (TR-save-001) | Save/load round trips | The stream is saved and restored with its state |

## Performance Implications
None measurable: one `randi()` per fight; keyed streams are created where needed.

## Migration Plan
1. Accept this ADR.
2. (If the Risk is accepted) replace `hash()` in keyed streams with a project-owned hash, in one change with a save
   version note, since it changes existing keyed values.
3. ADR-0001 step 4: `CombatService` derives `fight_seed` from the session stream.

## Validation Criteria
- A grep finds no global random call in `src/gameplay` or `src/core`.
- A save/load round trip resumes the session stream (the next draws match).
- Two lives with the same seed and actions are identical, including their fights.

## Related
- `docs/architecture/architecture.md` (Required ADR 3), ADR-0001, `src/core/random/rng_utils.gd`,
  `src/gameplay/session/game_session.gd`, `src/gameplay/economy/market.gd`, `src/gameplay/meridian/meridian_generator.gd`
