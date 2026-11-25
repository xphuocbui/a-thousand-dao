# Brief: polish the flagged art prompts (2026-11-25)

The prompt writers expanded short prompts by bolting sentences on, so many prompts now repeat themselves, carry
"Further detail:" blocks, or break the user's rules. The user chose to polish every flagged prompt before painting.
Your list is in `design/world/depth/art/_polish-list.json`: each key, its file and its flags (from
`tools/design/world/art_prompt_check.py`). Polish only the entries whose file is in your folders.

## Read first
- `design/world/depth/art/README.md`: the method, the clothing rule, the scale rule for places, and the lessons.
- The user's own words:
  - "really imagine it first, then describe it really specifically";
  - "they are cultivators, so naturally they are not poor";
  - "rags only for specific characters (a madman)".

## For each flagged prompt
1. Re-read the person's cast record (find it by key under `design/world/depth/`), or the place's facts in
   `_inputs/places.json`, along with the `imagined` moment.
2. **Rewrite `subject` as one coherent picture.** Do not patch it. Keep the labelled parts in order and fold every
   good detail in once, in the part where it belongs:
   - The moment, Face, Hair, Body, Clothing, Hands and objects, Background, Light, Expression for portraits;
   - setting, the place at its size, the signature elements, life, light for places.

   Rules for the rewrite:
   - Delete repeats.
   - Delete every bolted-on "X detail:" or "Further detail:" block, keeping any good detail in it.
   - Replace short stubby lines with real, specific description.
   - Length: portraits 200-300 words, places 250-350.
   - Keep the lead (the most important thing first), the person, the moment and every true fact.
3. **Clothing.** Cultivators wear fine, clean, well-fitted clothes. Remove "patched", "ragged", "frayed", "torn",
   "darned", "threadbare" and "worn thin" unless the record clearly calls for it: a madman, a beggar-sage, a penitent,
   a prisoner, or a mortal. If it does, keep it and say why in the Clothing part. Practical wear on tools or boots is
   fine.
4. **Expression:** describe the face's expression in words a painter can use ("a tight, satisfied half-smile"), not a
   list of trait names.
5. No writing in the picture, and no names or images from existing novels, dramas or games.

## Places only (folder q7)
Also write the two missing places, **239 Hàn Giao Chử** and **376 Tuần Tùng Đường**, into a new file
`design/world/depth/art/places/l1/07.json` in the same format. Use the brief `_brief-places.md` and the pilot's
`places/pilot.json` entries for these two as the starting idea. Apply the scale rule and look at their map crops.

## Finish
- Rewrite each file in place, keeping its other entries untouched.
- Validate each file.
- Run `python -I tools/design/world/art_prompt_check.py` and keep going until your entries show no `clothes`,
  `label`, `repeat`, `stubby`, `text` or `short` flags. `traits` alone may stay.
- Append `<q> <file> polished <n>` to `design/world/depth/art/_progress.md` after each file.
- Touch only your folders. Do not commit. Report in under 100 words: counts fixed, and any clothing kept on purpose
  and why.
