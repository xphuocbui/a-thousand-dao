# Brief: wiring the authored wishes (world-depth pass, phase B)

Phase A authors wrote the wishlist's content into `design/world/depth/builds/authored/*.json`. Each entry holds a
`record` and a `wire` list of where it goes. The duel readings are in `builds/duel-readings.md`, whose section 3 lists
87 content rewordings. You are the **only** writer now: apply everything, consistently.

## Do

1. **Read first:**
   - `DECISIONS-2026-11-25.md` (the rulings);
   - `builds/duel-readings.md` (sections 1 and 3);
   - every `builds/authored/*.json` and its `.md`.
2. **Conflicts.** Before writing, collect every `wire` target. Where two entries write the same field of the same item
   or technique, merge them (keep both lines if they stack sensibly) or pick the one that fits the person's build, and
   note the choice.
3. **Apply each wire:**
   - `add` appends to the field;
   - `replace` swaps the named line or record;
   - `new` creates the item or technique record in the owning sect's or group's `*.items.json` / `*.techniques.json`.
     Use the record's own id, then wear or learn it where the entry says (`build.gear` `{named: id}` within
     `1 + realm index` pieces, `build.main` or `build.aux` with at most 2 aux, `items` lists).
   - Tags such as `song`, `palm` and `bow` on arts go into the art records' `tags`.
4. **Apply the duel-readings rewordings** of section 3: change the listed rule texts to the new wording.
5. **Mark** each changed record with `"authored": "<wish key>"` (items, techniques, art records) so the user can find
   what came from the wishlist.
6. **Edit carefully.**
   - These JSON files are hand-formatted, so edit by careful substring replacement or targeted insertion of text
     values. Never rewrite a whole file with `json.dump`.
   - For new records, insert them before the closing bracket of the `items` / `techniques` / `sets` array, in the
     file's style.
   - Validate each file parses after editing.
7. **Check.** Run `python -I tools/design/world/depth_check.py` until it shows no findings. It now knows proposal
   techniques in `sects/` and `people/` and the game's catalogue.
8. **Write `builds/authored/WIRED.md`:** per entry, what was applied where; conflicts and how you resolved them; any
   wire you could not apply and why. Mark `builds/wishlist.md` entries as authored (add "AUTHORED: see
   authored/<file>" to each).

## Rules

Touch only `design/world/depth/`. Do not touch `README.md` or `SUMMARY-2026-11-25.md` (the orchestrator updates them),
game data, GDDs or code. Do not commit. Do not run Godot. Prefix scratchpad files with `wire-`. Report briefly (under
200 words): entries applied, conflicts resolved, rewordings applied, wires skipped, checker's final lines.
