# Brief: a personal item set for every tier A person (world-depth pass, items stage)

The user asked that the main cast "should have their own item set at least". Today 159 living tier A people hold
244 signature items, but most hold one item, and only 29 hold a piece of a set. Give **every living tier A person in
your batch** a personal **set** (rules-proposals R7) that fits their build and story.

## Read first

- `design/world/depth/rules-proposals.md` R7 (signature items and sets), `schema.md` (items and sets format).
- A good existing example: `design/world/depth/sects/bang_tam.items.json` (the Ice Heart Regalia, the Plum pair).
- `design/items/catalogue-<family>.json` for modifier keys and sizes by grade (grade 3-4 for elders and heads,
  grade 2-3 for younger tier A), and `design/items/bases.json` for base ids.
- For each person: their record (build, gear, items, traits, backstory, `tree.targets_note`) and their sect page's
  section 10 (treasures and sets).

## Do

For each living tier A person in your batch:

1. **Set size.** Gear slots are `1 + realm index` (max 3), so the set must fit what they can wear: 3 pieces for Kết
   Đan and above, 2 for Trúc Cơ, 2 for Luyện Khí (worn with no other gear).
   - If they already hold set pieces, complete or extend that set instead of starting a new one.
   - If they hold one signature item, build the set around it: it becomes a piece.
   - A sect head's set may be the sect's regalia, split across holders as R7 allows, but each head still has
     pieces they wear themselves.
2. **New items** follow `design/items` schema: `id` with your sect's existing item prefix, `name` as
   "English (Hán-Việt)", `family`, `kind`, `base`, `grade`, `modifiers`, `effects`, `lore`, `build_use`, `holder`,
   `made_by`, `made_year`, `set`, and `status: "proposal"`. Modifier keys must be ones `design/items/` uses. Keep
   sizes like the catalogue's for the grade.
3. **The set** gets an `id`, `name`, `pieces`, and `bonuses`:
   - 2 pieces: plain Modifiers, about half an item's budget;
   - the full set: a short hand-written **Effect** rule that makes their build's idea sharper;
   - a `story`: who made it, why it is whole or split.
   The Effect must fit the person's build, Đạo Đồ route and lineage arts, so read `targets_note`.
4. **Wear it.** Put the set's pieces in the person's `build.gear` as `{named: id}`. Replace plain gear pieces first and
   keep `1 + realm index` pieces. Add the ids to their `items` list.
5. If a set needs a mechanic that doesn't exist (a new stat or a new kind of rule), write it down in
   `design/world/depth/builds/wishlist-sets-<batch>.md`, in the format of `builds/README.md`. Use the closest
   existing lines for now.

Write the items and sets into your sects' and groups' existing `*.items.json` files, or create `people/<group>.items.json`
if a group has none. Change cast files only in `build.gear` and `items`. Use a Python script for JSON edits
(`json.dump(..., ensure_ascii=False, indent=1)`), and prefix scratchpad files with your batch name.

## Rules

- Touch only your batch's files. Do not touch `README.md`, game data, GDDs or code. Do not commit. Do not run Godot.
- Item ids must be unique in the world; the checker flags duplicates.
- Run `python -I tools/design/world/depth_check.py` until your files are clean.
- Report briefly (under 200 words): sets made, new items, people still without a set and why, wishlist count, and
  the checker's final lines.
