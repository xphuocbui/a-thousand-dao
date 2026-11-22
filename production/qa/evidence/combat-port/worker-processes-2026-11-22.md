# Rating batches in worker processes — 2026-11-22

ADR-0003 decision 13 (worker processes) and Power Rankings rule 13 (one season late), both user decisions of
2026-11-22. Development PC (16 logical cores), Godot 4.7.1 console binary running the project (not a release export),
shipped data, ratings on, LLM off, seed 7. Probes: `lag_probe.gd` and `batch_probe.gd` (scratch scripts, not
committed: they time `GameSession.cultivate(1)` and one planned `SeasonBatch`).

## One season batch (the first after world generation: 1,251 fighters queued for panels)

| Run | Wall time | Notes |
|---|---|---|
| Threads (`WorkerThreadPool`) | 116.4 s | the shipped behaviour before today |
| 12 worker processes, contiguous slices, a new process set per wave | 73.3 s | 9 waves (8 panel waves, 1 pair wave); the top-realm round robin sat in one worker |
| Tasks dealt round robin | 60.5 s | pair wave 29.6 s → 20.6 s |
| Workers started once per batch, every wave reused | **49.4 s** | per-wave start-up (about 1.5 s) gone; fighters compiled once per worker |

What is left is built into rule 14: each panel wave lasts as long as its longest panel (a sequential, adaptive search
that cannot be split), and the waves are sequential because admission depends on fights used. The pair fights
(5,032) take 18 s on 12 workers.

## End turn (cultivate one season), ratings on

| Turn | Threads, same season (before) | Threads, one season late | Workers, one season late, one batch at a time |
|---|---|---|---|
| New game | 40-49 s | 49 s | **34 s** |
| Season 1, pressed at once | 105 s | 2.9 s | 2.9 s |
| Season 2, pressed at once | — | 168 s | 47 s |
| Season 3, pressed at once | — | 56 s | 48 s |
| Season 4, pressed at once | — | 176 s | 31 s |
| After a 30 s pause | — | 2.6 s | **2.7 s** |
| After a 30 s pause | — | 51 s | **2.8 s** |

With about half a minute spent on each season, End turn takes about 3 s (the season itself). Pressing through
seasons with no pause still waits 30-48 s a season: one batch costs about 45 s of work.

## Correctness

- `tests/unit/ranking/rating_workers_test.gd`: a full season batch in 4 worker processes gives exactly the results of
  the same batch on threads (every panel result, rung count and pair score); a forced failure (every worker killed)
  falls back to threads with the same results.
- `tests/unit/ranking/rating_session_test.gd` reads the shipped worker setting, so its season, reload (AC-PR-48) and
  background-versus-blocking (AC-PR-52) tests now run through worker processes and still match exactly; the reload
  test also checks that the unapplied previous batch is saved.
- The ranking group: 45 of 45 pass.

## Found on the way (fixed)

- With one season late, two batches are in flight: they shared one pool and their workers collided. Each batch now has
  its own pool, and a lock lets one batch at a time use workers (two sets of 12 workers on 16 cores only slowed each
  other).
- A RefCounted pool calling its own method while being freed raised an error at exit; its cleanup is inline now. A
  process that quits without freeing its pool leaves its folder under `user://rating_workers/`; a new pool sweeps
  folders over an hour old (not newer ones: parallel test processes may be using theirs).

## Not verified

- A release export: the `-s` script entry and `OS.create_process` in an exported build (ADR-0003 decision 13, NOT
  SOURCEABLE; the 2026-11-15 spike saw them work with the release preset).
