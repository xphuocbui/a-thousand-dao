# ADR-0003 spike: rating fights on WorkerThreadPool (2026-11-14)

ADR-0003 Engine Compatibility, Verification Required (1): 1,000 fights on `WorkerThreadPool` tasks in a release export,
results identical to a single-threaded run, no main-thread frame over 33 ms.

**Verdict: PASS** for (1). Throughput misses the world-generation target of ADR-0003 decision 12 (see Findings).

## Setup
- `tests/performance/combat/rating_spike.gd`, run through the bench scene in the release export (preset "Windows
  Combat Bench"): `build/bench/combat_bench.exe --headless -- --rating-spike --fights=1000 [--private]`, output
  redirected to a file (the release export has no console wrapper).
- A generated world (seed 4242, 5,001 people); 300 real NPC fighters compiled on the main thread with
  `FighterCompiler.compile` and their Kinh Mạch Đồ sheets; 1,000 same-realm fights with keyed seeds.
- The same fights run single-threaded, then as a `WorkerThreadPool.add_group_task` started on the first idle frame
  while the main loop keeps running; every result (time, winner, time-out, both sides' end health and damage dealt)
  compared field for field.
- Machine: 16 logical cores (`OS.get_processor_count()`), Godot 4.7.1 release export template.

## Results (release export)

| Mode | Single-threaded | WorkerThreadPool | Speed-up | Mismatched | Frame gap p99 / max |
|---|---|---|---|---|---|
| One task per fight, profiles shared | 13,020 ms (13.0 ms a fight) | 4,996 ms | ×2.61 | 0 | 6.92 / 7.05 ms |
| One task per core, private profile copies | 12,914 ms | 5,120 ms | ×2.52 | 0 | 6.92 / 6.92 ms |

World generation 8.0 s; compile 0.93 ms a fighter. The editor binary gave the same picture (×2.2–2.4, 15 ms a fight).

## Findings
1. **Deterministic and safe.** No result differs between the threaded and single-threaded runs, with profiles shared
   across workers or not, so ADR-0003 decisions 2–4 hold as designed; compiled profiles and `GameData` are read-only
   during fights (no writes to profiles or static state in the engine, checked by search).
2. **The main thread stays free.** No frame gap above 7.1 ms while the batch runs (an earlier 140 ms reading was the
   measurement starting before `_ready` returned, fixed by starting on the first idle frame).
3. **Real fights cost 13 ms**, about twice the 6 ms ADR-0003's Context assumed (generated NPCs now carry 2–7 arts,
   wards and Effects). Budgets are counted in fights, so the design holds; wall time per season doubles
   (10,000 fights ≈ 50 s at the measured threaded rate, in the background).
4. **Threads scale poorly: ×2.5–2.6 on 16 cores**, the same with private profile copies, so the limit is not
   contention on shared profiles. The likely cause is an engine-wide lock every fight takes, such as the global
   object registry each RefCounted allocation goes through (fights allocate many small objects). NOT SOURCEABLE from
   `docs/engine-reference/godot/` (it does not cover threading or ObjectDB); to be confirmed with a profiler.
5. **World generation misses its target:** 50,000 coarse-panel fights at the measured rate take about **250 s**
   against ADR-0003 decision 12's 120 s.

## Follow-ups
- Profile one worker against several to find the lock; if it is per-object allocation, pool or reuse the fight's
  small objects (batches, statuses, log rows) and re-measure.
- If scaling cannot reach the target: a longer first load, fewer coarse-panel fights at load (2 a probe → 1), or
  coarse panels spread over the first seasons (the GDD's earlier provisional design).
