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

## Overnight run, 2026-11-27 (user: one sect at a time, until 08:00; checkpoints 1-4)
The orchestrating session runs one owner at a time, no parallel lanes. Thiên Xu Tông first, then the owners in
`stage6_jobs.py`'s wave order. For each owner:
1. Commit `_jobs.json`, then run the record job: `stage6_jobs.py --only <o> --tag <o> --part record` and
   `run_jobs.py ... --lanes 1 --until 2026-11-27T08:00`.
2. **Checkpoint review.** A fresh reviewer agent (Opus, not anchored on the orchestrator) reads the staged records
   against the depth text, the rulings and the design rules, and runs `sect_fight.py` itself. The orchestrator fixes
   the findings in staging (or the brief, for a flaw every job would repeat) and commits them.
3. Run the serial job: `--part serial`. Then the orchestrator checks the new engine words and the gate's tests.
4. Update the morning report `production/plans/stage6/_report-overnight.md`: per owner, what was built, what the
   review found and fixed, the decisions taken for the user, anything that needs the user, and the time.

No job starts after 08:00. On a HALT: read it, fix the cause, delete HALT, and rerun the same command.

## Overnight status (2026-11-27 00:50, written as the orchestrator's usage limit ran out)
- Thiên Xu's record job FINISHED its work (40 min; `thien_xu.done`, `thien_xu.md`, `thien_xu-review.md`; staging in
  `design/stage6-staging/thien_xu/`; its own depth files edited). NOT committed yet.
- The record gate HALTED: the three lints are 0 findings, but `sect_fight.py` printed a REFUSED holder (log
  `production/session-logs/stage6-run/s6-thien_xu-after.md`, line 75; the refused line is cut by the log's 4,000-char
  tail, so rerun `DEPTH_STAGE=design/stage6-staging/thien_xu python -I tools/design/combat_sim/sect_fight.py thien_xu
  --seeds 5 | grep REFUSED` to see which holder and why). Also seen: "Sentence Stands" NEVER_RAN on phuong_truc_ngon.
- NEXT: fix the refused build (likely a staged record the engine refuses), delete `production/session-logs/stage6-run/HALT`,
  run `python -I tools/headless/stage6_gate.py record thien_xu` (it commits), then the checkpoint review, then
  `--part serial`.

## From 2026-11-27 08:40 (user): one owner at a time, the review through the driver, serial steps in batches
- **No subagents** (the user: they cost a lot of tokens); the checkpoint review is a driver job
  (`_brief-review.md`, which writes `<owner>-checkpoint.md` and `<owner>.reviewed`, and applies its fixes in
  staging).
- **Batches of five owners** (`stage6_jobs.py --batch N` or `--only ... --tag bNN`). Each owner runs its record job,
  then its review job, each followed by the record gate (which commits). Then one serial step builds the batch's
  pending words marked "build", merges the batch into `design/`, and runs the checks and commits.
- **Measured on Thiên Xu:** the record job takes 39 min; the gate 1-2 min.
- **Batch 1 (b01):** thien_xu (record done; its review first), lac_ha, thuy_vi, phuong_minh, thinh_vu.
- **Launch:** `python -I tools/headless/run_jobs.py production/plans/stage6/_jobs.json production/session-logs/stage6-run --lanes 1`.
  The orchestrating session checks each batch when the run ends, then generates and launches the next.

