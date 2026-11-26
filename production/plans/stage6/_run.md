# The parallel Stage 6 run (world-depth, the other sects)

User 2026-11-26: after Băng Tâm Các, the other sects run as headless sessions on Opus with Fable as the advisor
(`advisorModel` in the user settings), three at once, with decisions auto-accepted.

## How it runs
- **Driver:** `tools/headless/run_jobs.py production/plans/stage6/_jobs.json production/session-logs/stage6-run --lanes 3`.
  Logs go to `production/session-logs/stage6-run/` (`jobs.md`, transcripts, `*-after.md`, and `HALT` when it
  stopped).
- **Job list:** `python -I tools/headless/stage6_jobs.py [--waves A-B]` writes `production/plans/stage6/_jobs.json`.
  - Waves of three: one large owner with two small ones; the sects first, the outside groups last.
  - After each wave, a serial job (a barrier).
- **Record job** (`_brief-record.md`): it writes only its staging folder `design/stage6-staging/<owner>/`, its own
  depth files and its notes. Its tools read the staging through `DEPTH_STAGE`, and no shared glob reads it.
- **Gate after each record job** (`tools/headless/stage6_gate.py record <owner>`):
  - only allowed paths are dirty;
  - `RECORD PASS DONE` is in the progress file;
  - the staged files lint clean;
  - `sect_fight.py` refuses no holder.

  Then it commits the owner's paths.
- **Serial job** (`_brief-serial.md`): it builds the wave's pending engine words in both engines, with tests, a
  parity fixture and the GDD lines, and moves the pending records into staging.
- **Gate after the serial job** (`stage6_gate.py serial <tag> <owners>`):
  - `stage6_merge.py`: moves the staged files into `design/`, merges the Effects, then checks unique ids, the lints,
    `depth_check` and the gap report;
  - the library and compile-case exports, `parity --quick` and `test_engine`;
  - the GdUnit combat and parity groups.

  Then it commits what changed since the job's snapshot.
- **Halts:**
  - a failed gate;
  - an unexpected dirty path;
  - a usage limit lasting past 10 waits of 30 min.

  Fix the cause, delete `HALT`, and rerun the same command. Finished jobs are skipped (their `.done` file exists).
- **Stage 8 after the last wave:** `export_world.py --sect all`, the census and the world build time.

## Status
- 2026-11-26: tools ready.
  - The probe job confirmed that a headless job can write to staging, run python with `DEPTH_STAGE`, and use the
    advisor.
  - The pilot is wave 1 (lac_ha, tran_sa, tam_kiem). Its records get read against the depth text before the rest.
