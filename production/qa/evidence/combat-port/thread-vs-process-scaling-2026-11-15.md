# Fight throughput: threads against processes — 2026-11-15 (overnight)

Power Rankings Open Question 9 (thread scaling) and ADR-0003 Risks. Release export (preset "Windows Combat Bench"),
16 logical cores, real generated NPC fighters (300 compiled, same-realm seeded fights), log off.

## 1. Two engine-level attempts found nothing to gain

| Engine | Single-threaded | 16 threads (1,000 fights) |
|---|---|---|
| Committed (`046dc4d`) | 12.07 / 12.09 ms a fight | ×2.46 / ×2.47 (4.90 s) |
| Integer mod keys (`ModKey` ids, an id-indexed always-on table, a per-fighter "possible key" early out, timed and banked mods by id) | 11.97 / 11.99 ms | ×2.36 / ×2.39 (5.05 s) |

Parity with the Python sim held (12/12 parity cases), but the change bought about 1 % single-threaded and nothing on
threads, so it was **reverted** (kept in the night's notes only). A timer-instrumented profile had put about 40 % of
a fight in `m()` (1.44 million mod look-ups in 300 fights, 885,000 of them for keys the fighter can never have); the
A/B shows the timers' own overhead inflated the small, frequent calls. That profile is not to be trusted for
ranking hot spots.

A third attempt ran the season batch's certain pair fights (budget less the panel share) alongside its panel waves
instead of after them. Release terminal, same commands with and without it: a 5-year closed-door 145 s against
145 s, `cul 4` 102 s against 102 s. No gain, so it was reverted as well.

## 2. The limit is not shared data

| Spike mode (`--rating-spike --fights=1000`) | 16 threads |
|---|---|
| One task per fight, shared profiles and constants | ×2.47 |
| One task per core (`--chunked`) | ×2.44 |
| One task per core, private profile copies (`--private`) | ×2.42 |
| One task per core, private profiles **and** private deep-copied combat constants (`--private-k`, new) | ×2.42 |

Nothing a fight reads is the contention. With the spike's earlier probe (allocating Arrays and Dictionaries scales
×2.1–2.5, RefCounted objects ×0.4–0.6, arithmetic ×9.4) the likely limit is engine-wide inside one process: the
memory allocator and the object registry every thread shares (inferred; Godot's internals are NOT SOURCEABLE from
`docs/engine-reference/`).

## 3. Processes scale almost linearly

`--fight-rate` (new, `tests/performance/combat/fight_rate_probe.gd`): 300 fights in one thread, as separate
processes started together.

| Processes at once | ms a fight in each | Total throughput against one process |
|---|---|---|
| 1 | 12.56 | ×1 |
| 8 | 13.04–14.00 (mean 13.6) | **×7.4** |
| 16 | 13.59–19.43 (mean 16.8) | **×12.0** |

Against ×2.45 for 16 threads in one process. A 10,000-fight season batch is about 49 s on threads today; spread over
16 worker processes it would be about 10–15 s plus the cost of handing work over (not measured).

## 3b. End to end with worker processes (experiment)

`--process-probe` (new, `tests/performance/combat/process_workers_probe.gd`; not part of the game): the coordinator
compiles 300 real NPCs, writes their build files and 3,000 seeded fights to a job file, starts N copies of the release
binary as workers (each loads the game data, rebuilds the fighters from the build files and runs its share), waits for
them and compares every result with the same fights run in one thread on the original profiles.

| Setup | 3,000 fights | Against one thread |
|---|---|---|
| One thread | 36.0 s (12.0 ms a fight) | ×1 |
| 16 threads in one process (spike rate) | ~14.7 s | ×2.45 |
| 8 worker processes, start to last exit | 6.10 s (fights alone 5.32 s) | ×5.9 (×6.8) |
| 16 worker processes, start to last exit | 5.48 s (fights alone 4.34 s) | ×6.6 (×8.3) |

Every result identical (3,000 of 3,000). A worker starts and loads in about 0.1 s. For a 10,000-fight season that is
about 18 s against 49 s on threads.

**A requirement found on the way:** the work must travel in Godot's binary Variant format (`store_var`), not JSON. With
JSON, 1,652 of 3,000 results differed: Godot's JSON float parse is not correctly rounded even at full precision
(3.8798222222222227 comes back 3.8798222222222223), so a fighter rebuilt from a JSON build file is not bit-identical
(`block`, `n_qi`, `n_body`, layer points). The same parse is behind the stored ratings that needed re-snapping after a
load (AC-PR-48).

## 4. Fix to the measurements

With Power Rankings on in the shipped data, the spike's `new_game` started a background season batch that shared the
CPU with the measured fights (readings of 21–24 ms a fight) and held the process open at exit. The spike now turns
ratings off and shuts the session down; all figures above are from the fixed spike.

## Options (a decision for the user; an ADR-0003 amendment)

1. **Worker processes for rating batches** (and world-generation panels): the game starts N copies of its own
   binary as headless fight workers; the main process sends build files and seeds, workers compile and fight, and
   return scores; results apply in the same fixed order, so determinism holds. Desktop only (consoles and mobile do
   not allow child processes); needs packaging care. Expected ×4–5 over threads.
2. **A native fight core** (GDExtension, C++): the hot loop outside GDScript. Large, and parity must be rebuilt.
3. **Accept** today's throughput (about 36 s of background work a season).
