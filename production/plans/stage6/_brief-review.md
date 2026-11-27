# Stage 6 checkpoint review: the brief for one owner (headless job)

You review, and then fix, one owner's Stage 6 record pass: `<OWNER>` in the prompt. Another headless job wrote it.
Review it unanchored: verify its claims yourself, never trust its review file. Nobody answers questions, and decisions
are auto-accepted: take your recommended option, thought through against the design rules, and log it.

## Read
- The staged records `design/stage6-staging/<OWNER>/`:
  - `techniques/catalogue-sect-<OWNER>.json`, `arts/part-sect-<OWNER>.json`;
  - `items/catalogue-sect-<OWNER>.json`, `items/sets-<OWNER>.json`;
  - `effects/<OWNER>.effects.json`, `pending.json`.
- The owner's depth text, which is the source of truth: `design/world/depth/sects/<OWNER>.*` (or `people/<OWNER>.*`),
  `<OWNER>.md`.
- The record job's account: `production/plans/stage6/<OWNER>-review.md` and `<OWNER>.done`.
- The rules:
  - `production/plans/stage6/_brief-record.md` (its design rules and lessons checklist);
  - `design/world/depth/DECISIONS-2026-11-25.md` and `DECISIONS-2026-11-26.md`;
  - `tools/design/combat_sim/FIGHT-INPUT.md` (above all "Built in world-depth Stage 6" and "Traps found in Stage 6").
- A finished, user-approved example: `design/arts/part-sect-bang_tam.json`, `design/world/depth/effects/bang_tam.effects.json`
  and `production/plans/stage6/bang_tam-review.md`.

## Check, in this priority
1. **Engine records that do not do what their rule text says.** For example: the wrong event; a counter armed and spent
   on the same hit; an `always` record with a record-level filter; a stance set but not defined; two stances in one
   build with no combined stance; scope in the wrong place; numbers that contradict the rule. Verify by reading and by
   running `python -I tools/design/combat_sim/sect_fight.py <OWNER> --seeds 5` and `--gap 1` (DEPTH_STAGE is set for
   you): it prints each holder's art fires and each Effect with and without it, plus its runs.
2. **Unfaithfulness to the depth text or a person's story, or a breach of the rulings or design rules, that the job did
   not log.** The rules: no environment conditions, no spatial fight, scale without caps, Effects unpriced.
3. **Each word in `pending.json`:** build it, or use an existing word that keeps the intent (as "freeze" became
   `stop_clock`), or leave the Effect `not_run` with a reason. A new word must be worth building in two engines for
   builds that will really use it. A whole new element or a large system is rarely worth it for one record with no
   holder.
4. **Stand-in picks:** the order is the lineage method by rank, else the person's note, else a new technique of the
   owner. Each pick must fit the person's root.

## Fix
- **Apply every MUST-FIX and SHOULD finding** in the staged files and in the owner's depth files, with small edits. Then
  re-run the three linters on the staged files and `sect_fight.py`.
- **Record your decision on each pending word** in `pending.json`: add `"decision": "build"`,
  `"decision": "use <word>"` (and rewrite the records to use it, moving them out of `pending.json` into the staged
  files) or `"decision": "not_run"` (mark the Effect `not_run` with its reason in the staged Effects file).
- Write ONLY: `design/stage6-staging/<OWNER>/`, the owner's own depth files, and `production/plans/stage6/<OWNER>-checkpoint.md`.
  Never run git, Godot or an exporter.

## Finish
- `production/plans/stage6/<OWNER>-checkpoint.md`:
  - a ranked list of findings (file, record id, what was wrong, the fix applied, MUST-FIX, SHOULD or NIT);
  - the decision on each pending word;
  - the holder table after the fixes.

  End it with the line `CHECKPOINT DONE`.
- `production/plans/stage6/<OWNER>.reviewed` as one JSON object:
  `{"owner", "minutes", "must_fix": n, "should": n, "fixed": n, "words": {"<name>": "build|use X|not_run"}, "open": [...]}`.
