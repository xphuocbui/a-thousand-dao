# Stage 6 serial step: the brief for one wave (headless job)

You are the serial step after a wave of record jobs. The prompt names the wave's tag `<TAG>` and its owners. You run
alone: no other job is writing. **Decisions are auto-accepted** (user, 2026-11-26): take the recommended option,
thought through against the design rules in `production/plans/stage6/_brief-record.md`, and log it.

## Read first
1. `production/plans/stage6/_serial-<TAG>.md`, if it exists: you may be resuming.
2. The wave owners' `production/plans/stage6/<owner>.md` and `<owner>-review.md`, and each
   `design/stage6-staging/<owner>/pending.json`.
3. How Băng Tâm's words were built: `production/plans/stage6/bang_tam.md` (step 5) and commits c14985d9, a108d9f3,
   bceada72, 75da41b2 and 978ab58c (`git show --stat <sha>`; reading git is fine, writing is not).
4. `tools/design/combat_sim/FIGHT-INPUT.md`.

## What you do
1. **List the wave's pending words.** Merge duplicates across owners, and prefer an existing word where one keeps the
   intent (then rewrite the record to use it).
2. **For each word, in both engines with parity:**
   - Python: `tools/design/combat_sim/engine.py` (and `fight.py` when the loader needs it);
   - GDScript: `src/gameplay/combat/fight/` (`fight.gd`, `defence_path.gd`, `effect_runner.gd`, `effect_compiler.gd`,
     `fighter_state.gd`);
   - the vocabulary in `assets/data/combat_engine.json`;
   - a Python test in `tools/design/combat_sim/test_engine.py` and a GdUnit twin in
     `tests/unit/combat/fight_depth_test.gd`. Watch each fail before the fix;
   - one chance-free parity fixture per wave, `tests/parity/fixtures/t<NN>_<tag>_exact.json`, registered in
     `tests/parity/combat_parity_test.gd`'s list. Run `parity_export.py --quick` to write its expected file;
   - the GDD line in `design/gdd/effects.md` rule 5 or 6 (auto-accepted). Add only your own lines; never touch
     another session's text;
   - a line in `tools/design/combat_sim/FIGHT-INPUT.md`.
3. **Move each owner's pending records** into its staged files (`design/stage6-staging/<owner>/...`), then delete
   `pending.json`. Then re-run, with `DEPTH_STAGE` set:
   - `python -I tools/design/combat_sim/sect_fight.py <owner>`;
   - the three linters on the staged files.

   Fix what they show.
4. **Run the targeted checks:** `python -I tools/design/combat_sim/test_engine.py` (0 failed), and the GdUnit combat
   and parity groups:

   ```
   C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 \
       res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/combat --ignoreHeadlessMode
   ```

   Also the same with `res://tests/parity`.
5. **Write `production/plans/stage6/_serial-<TAG>.md`:**
   - the words built, the GDD lines, the tests and the fixture;
   - the records moved;
   - the auto-accepted decisions.

   End it with `SERIAL DONE`, then write `production/plans/stage6/_serial-<TAG>.done`.

The runner's gate then merges the staged files into `design/` (`stage6_merge.py`), exports the library and the compile
cases, runs the checks again, and commits. **Never run git, `stage6_merge.py` or an exporter yourself.** Never touch:
- the "Formation teaching" bullet in `design/gdd/sects.md`;
- `design/gdd/formations.md`;
- the provinces runtime code.
