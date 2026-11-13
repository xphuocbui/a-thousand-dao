# Combat port step 1: timing spike (2026-11-13)

ADR-0001 risk "Performance of the GDScript hot loop" and validation criterion "a fight resolves in under 50 ms in a
headless export build". Engine: slice 1 of the GDScript port (`src/gameplay/combat/fight/`): the timeline, arts
with costs, cooldowns and charges, heal and restore arts, basic attacks, companions, hit damage and the defence path's
resistance, drain bill and block. No Effects, stacks, statuses, crits or evades yet.

## Method
- `tests/performance/combat/combat_bench.gd`: 5 fight shapes, 200 fights each (seeds 0-199), the coin order, log
  off, 10 warm-up fights per shape, wall time per fight with `Time.get_ticks_usec()`.
- Release export: preset "Windows Combat Bench" (local `export_presets.cfg`, custom feature `combat_bench`, which
  makes `run/main_scene.combat_bench` the start scene), Godot 4.7.1 official release template, Windows x86_64,
  run as `build/bench/combat_bench.exe --headless -- --runs=200`.
- Editor binary for comparison: `godot --headless --path . res://tests/performance/combat/combat_bench.tscn`.
- Same machine, one run each.

## Results

Release export build (the number the ADR judges):

| Shape | Fight (s) | Events | Mean ms | p50 ms | p95 ms | Max ms | µs/event |
|---|---|---|---|---|---|---|---|
| mirror_qr: typical mirror, realm 0, 3 arts each | 39.0 | 314 | 0.638 | 0.614 | 0.802 | 1.117 | 2.03 |
| mirror_top: the same mirror at realm 4 | 66.0 | 642 | 1.186 | 1.141 | 1.493 | 1.728 | 1.85 |
| stall: heavy wards and regeneration, ends in fatigue | 67.0 | 328 | 0.613 | 0.598 | 0.695 | 1.080 | 1.87 |
| hazards: health costs, heals, restores, splits | 14.7 | 201 | 0.483 | 0.465 | 0.587 | 0.825 | 2.40 |
| art_heavy: 8 arts with 4-way splits and charges plus a companion, each side | 29.8 | 2015 | 4.301 | 4.144 | 5.521 | 6.764 | 2.13 |

Editor binary (debug), for comparison: p95 1.105 / 2.115 / 1.018 / 0.710 / 7.039 ms. The release build is about
25 % faster.

All shapes are within budget, and the worst p95 (5.5 ms) leaves about 9x headroom.

## What this does and does not show
- One event (a pulse, an art firing or a hit) costs about 2 µs in the release build. At 50 ms, the art-heavy shape
  could afford about 25 µs per event, so the later slices can make each event roughly 10x more expensive before
  the budget is at risk.
- **This is a lower bound.** The Effect interpreter runs on every event and is the ADR's real risk. Re-run this
  bench after the Effect slice (Migration Plan step 2, fourth slice), with a many-Effect shape added; the
  GDExtension fallback for the Effect runner stays closed unless that run misses.
- Determinism: the parity suite shows the same profiles and seed give the same rows (`combat_parity_test.gd`).
- The coin order's average mirror lasts 39 s at realm 0 (target 30-60 s) and 66 s at realm 4 with these arts; the
  realm-4 shape was built for timing, not balanced.

Raw output: the `BENCH_JSON` line printed by each run.

## Re-run after slice 2 (defence path, wards, crits, evades), 2026-11-13

Same machine and method, release export rebuilt. Two shapes added: `wards` (every extra ward model, pieced shields,
body shield, conversion; from `t2_wards_exact`) and `crit_mirror` (crits, evades and a cast evade ward; from
`t2_crit_evade_mirror`).

| Shape | Fight (s) | Events | Mean ms | p50 ms | p95 ms | Max ms | µs/event |
|---|---|---|---|---|---|---|---|
| mirror_qr | 38.9 | 302 | 0.830 | 0.814 | 0.931 | 1.417 | 2.75 |
| mirror_top | 66.0 | 644 | 1.583 | 1.558 | 1.701 | 2.077 | 2.46 |
| stall | 67.0 | 328 | 0.814 | 0.785 | 0.930 | 1.227 | 2.48 |
| hazards | 14.7 | 201 | 0.635 | 0.617 | 0.733 | 0.864 | 3.16 |
| art_heavy | 29.7 | 2246 | 5.925 | 5.675 | 7.434 | 8.080 | 2.64 |
| wards | 58.7 | 435 | 2.385 | 2.373 | 2.648 | 3.961 | 5.48 |
| crit_mirror | 37.4 | 321 | 0.934 | 0.925 | 1.079 | 1.510 | 2.91 |

Worst p95 7.4 ms of 50. The per-event cost rose about 30 % with slice 2 (two rolls per hit, ward checks), and is
about 5.5 µs where every ward model is in play. Still a lower bound until the Effect slice.

## Re-run after slice 3 (element stacks, statuses, curses, soul), 2026-11-13

Two shapes added: `stacks` (every element's stacks, ticks, purity, cleansing; from `t3_stacks_exact`) and
`statuses` (every status and curse; from `t3_statuses_exact`).

The first slice-3 build doubled the per-event cost everywhere (about 5.3 µs) and put `stacks` at 33.5 µs per event,
p95 23.5 ms: every read of a stack-driven stat walked all batches and rebuilt each batch's stack power with string
formatting. Two exact fixes (profiles never change in a fight, so the values are identical, and parity stayed exact):
each batch's stack power is computed once at the grant, and per-stat sums are cached until the stacks change; status
numbers moved to typed fields, with early returns when a side has no stacks or statuses. After them:

| Shape | Fight (s) | Events | Mean ms | p50 ms | p95 ms | Max ms | µs/event |
|---|---|---|---|---|---|---|---|
| mirror_qr | 38.9 | 302 | 1.577 | 1.313 | 2.106 | 13.763 | 5.22 |
| mirror_top | 66.0 | 644 | 2.433 | 2.315 | 3.026 | 5.747 | 3.78 |
| stall | 67.0 | 328 | 1.209 | 1.170 | 1.337 | 2.796 | 3.69 |
| hazards | 14.7 | 201 | 0.929 | 0.877 | 1.195 | 2.774 | 4.62 |
| art_heavy | 29.7 | 2246 | 8.601 | 8.249 | 10.782 | 13.103 | 3.83 |
| wards | 58.7 | 435 | 3.170 | 3.156 | 3.409 | 6.063 | 7.29 |
| crit_mirror | 37.4 | 321 | 1.323 | 1.310 | 1.518 | 4.060 | 4.12 |
| stacks | 40.6 | 542 | 4.951 | 4.878 | 5.299 | 8.134 | 9.13 |
| statuses | 22.2 | 320 | 1.563 | 1.523 | 1.698 | 3.742 | 4.88 |

Worst p95 10.8 ms of 50 (`art_heavy`). The `mirror_qr` max of 13.8 ms is a single outlier (its p95 is 2.1 ms). The
per-event cost is about 3.7-4.6 µs against slice 2's 2.5-2.9: slice 3 adds a dozen stat reads per hit. The Effect
slice runs on every event, so its re-run decides whether the hot path needs more than this.
