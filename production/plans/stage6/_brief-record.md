# Stage 6 record pass: the brief for one owner (headless job)

You run world-depth Stage 6 for one owner (a sect or an outside group): `<OWNER>` in the prompt. You are one of up
to three jobs running at once. Another job runs afterwards: the **serial step** builds new engine words and moves your
staged files into place. **Decisions are auto-accepted** (user, 2026-11-26): where Băng Tâm's pass asked the user, you
take the option you would recommend, after thinking it through against the design rules below, and you log it in
your review file with the reason. Nobody answers questions; never wait for one.

## Read first, in this order
1. Your progress file `production/plans/stage6/<OWNER>.md`, if it exists. **You may be resuming**: do the first
   unchecked step, and redo nothing that is checked.
2. `production/plans/world-depth-implementation.md`, Stage 6 "The per-sect method" and the standing rulings under step 4.
3. The worked example: `production/plans/stage6/bang_tam.md` and `bang_tam-review.md`, and Băng Tâm's files:
   - `design/techniques/catalogue-sect-bang_tam.json`
   - `design/arts/part-sect-bang_tam.json`
   - `design/items/catalogue-sect-bang_tam.json`
   - `design/items/sets-bang_tam.json`
   - `design/world/depth/effects/bang_tam.effects.json`

   Copy their form exactly.
4. `tools/design/combat_sim/FIGHT-INPUT.md`: the whole vocabulary, and above all "Built in world-depth Stage 6" and
   "Traps found in Stage 6".
5. `design/world/depth/DECISIONS-2026-11-25.md` and `DECISIONS-2026-11-26.md`: the user's rulings. They bind you.
6. Your owner's depth files: `design/world/depth/sects/<OWNER>.*` (or `people/<OWNER>.*`), `<OWNER>.md`, and
   `design/world/depth/schema.md`.

Then run `python -I tools/design/world/depth_gap.py --sect <OWNER>`, and `--list <section>` for each open section.

## What you write (ONLY these paths; anything else halts the run)
Your staging folder `design/stage6-staging/<OWNER>/` mirrors `design/`:
- `techniques/catalogue-sect-<OWNER>.json`: your techniques in catalogue form (bonuses by the tier's `bonus_count`,
  passives, abilities with unlock layers, all suite arts by layer 6, `owner`, `rank`, `concept`, `lore`). If
  `design/techniques/catalogue-sect-<OWNER>.json` already exists (an earlier early promotion), keep its records and add
  yours.
- `arts/part-sect-<OWNER>.json`: every new art, in full art-record form, `group` = its technique.
- `items/catalogue-sect-<OWNER>.json`: the items, with the depth modifiers as given. Also, on every record:
  - `sources: ["npc"]` and `unique: true`;
  - Effects by their plain English name;
  - weapons, armour and shields with
    `exception: "world-depth signature item: its base's common art or ward until an authored one is ruled (review R6)"`.
- `items/sets-<OWNER>.json`: the sets; a full-set bonus has `effect` (its name) and `rule`.
- `effects/<OWNER>.effects.json`: `{"_doc", "source": "world-depth:<OWNER>", "effects": {name: {rule, records,
  counters?, approx?}}}`, one entry per item, set, technique and passive-art Effect.
- `pending.json`: records that need an engine word the engine lacks (below).
- `foreign/<OTHER>/techniques/catalogue-sect-<OTHER>.json` (and `arts/part-sect-<OTHER>.json`): only for an early
  promotion of another owner's method that one of your people needs (standing rule: a pass may only ADD to another
  owner's file; the serial step merges it by id).

Your own depth files (in place):
- the art ids in `<OWNER>.techniques.json` (`"id": ...` before `"new"`), plus any new technique you add for
  stand-ins;
- the stand-in picks in the cast files;
- `beasts` on beast owners.

Edit them with small text inserts, never a reformat.

Your notes: `production/plans/stage6/<OWNER>.md` (progress, resumable) and `production/plans/stage6/<OWNER>-review.md`.

**Never write:** `assets/`, `src/`, `tests/`, `tools/`, `design/gdd/`, the committed `design/arts|techniques|items`
files, or any other owner's depth files.

## The steps (tick each in your progress file as you finish it)
1. **Verify first.** Make a mechanic table: each technique, art, item and set rule, and whether the engine has it,
   needs a word, or needs a ruling (`FIGHT-INPUT.md`).
2. **Techniques and arts** (staged).
3. **Effects** (staged).
4. **Items and sets** (staged).
5. **Stand-ins.**
   - The order: the lineage method by rank, else the method the person's note names, else a new technique for the
     owner (as Băng Tâm's `warm-hearth-breath`).
   - A method owned by another owner and not yet promoted goes under `foreign/` as above. Log it.
6. **Beasts:** the owner's `beasts` field.
7. **Holder check.** With `DEPTH_STAGE=design/stage6-staging/<OWNER>`:
   - lint your staged files: `python -I tools/design/arts/lint_techniques.py <file>`, `lint_arts.py <file>` and
     `tools/design/items/lint_items.py <file>`. 0 findings, besides `ART_MISSING` for arts that are only in
     `pending.json`;
   - run `python -I tools/design/combat_sim/sect_fight.py <OWNER>` and `--gap 1`. Every art must fire, and every
     Effect must run on its real holders; a 0 needs a reason in the review. Fix what the table shows (the traps);
     never accept "it lints" as proof.
8. **Review file.**
   - Each record's depth text beside its engine form, and every deviation.
   - The auto-accepted decisions, with reasons.
   - The pending words.
   - The holder table.
9. **Finish.**
   - Write the line `RECORD PASS DONE` at the end of your progress file.
   - Write the file `production/plans/stage6/<OWNER>.done` containing one line: the counts of what you wrote.

## Pending words (when the engine lacks something)
Do not edit the engine. Write `design/stage6-staging/<OWNER>/pending.json`:

```json
{"words": [{"name": "...", "kind": "action|event|readable|mod|status|field", "spec": "what it does, exactly",
            "gdd_text": "the Effects GDD rule 5/6 line you propose", "used_by": ["record ids"]}],
 "arts": [<full art records that use a pending word>],
 "effects": {"<Effect name>": {<full entry>}}}
```

Keep those records OUT of your staged files, because the linters and engine would refuse them. Prefer an existing word
whenever it keeps the intent, as Băng Tâm's "freeze" became `stop_clock` 1 s. A new word must be worth it for builds.

## The design rules (from the user's memory; they bind every decision)
- **Builds are the game:** a concept with modifiers stacked on it, sometimes an enabler. Every record serves builds.
  The strongest arts reach full power only through an engine the build feeds.
- **Modifier vs Effect:** a Modifier is a plain number on a stat, tag-scoped; anything with a rule is an Effect.
  Effects are hand-designed and **unpriced**: there is no W price, so ignore the "W of" notes.
- **Scale without caps:** a cost, decay or upkeep bounds a piece, never an "at most N".
- **No environment conditions:** no terrain, weather, place or time of day in a fight rule. Rewrite it to the fighter's
  own state and keep the image as lore. **No spatial fight:** one side against one side, so "walks into", "inside the
  seal" and "at range" become Field, Composed and Pressing readings (Combat rule 25), as in Băng Tâm.
- **Sustain is king:** fights last 30 to 60 s, with many sustain sources and burst all-in rare.
- **Be faithful** to the depth text and the person's story. Where you must deviate, log it.
- **Standing rulings (Băng Tâm):**
  - "formation" and "diagram laid" mean the Field stance (`field_up`);
  - a formation's strength is the stance ward;
  - "freeze" is `stop_clock` 1 s;
  - signature items are unique and use their base's common art;
  - an art defines every stance its records set;
  - two stances in one build need a combined stance.

## Practicalities
- Python is `python -I`. Never run git (the runner commits after its gate checks your paths), Godot, or any
  exporter.
- Write English with Hán-Việt terms as the depth files do (e.g. sect (tông môn)); names in Hán-Việt first.
- Keep the progress file current after each step: you may be cut off and resumed in a fresh session.
