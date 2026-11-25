# Brief: author place prompts (world-depth art, 2026-11-25)

You write one painting prompt for every place in your batch, for a Godot cultivation (tu tiên) grand-strategy game.
The user has approved the method after a pilot. Each place becomes its own picture, painted later at low quality,
1536x864, as the banner of the place's window.

## Read first
- `design/world/depth/art/README.md`, especially "Places v2" and the **scale rule**.
- The place style block (`PLACE_STYLE` in `tools/asset-pipeline/portraits/paint_authored.py`), which is sent before
  every place prompt.
- `design/world/depth/art/places/pilot.json`, for the format and level of detail only. Do not copy its phrasing.
- `pilot-review/214-v2-vs-v3.jpg` shows the scale the user approved for a great sect.

## The user's direction, in their words
- "These are literally the political entities of a nation."
- "Think about the sizing of the place first, not everything is as big as sect headquarters."
- "Have the characteristics of the place still: don't just paint a city, really paint a sect."
- "Imagine the scale if people have magic."
- "Really detail the prompt."

## For each place (facts in `design/world/depth/art/_inputs/places.json`, ids in `_inputs/batches.json`)
1. **Look at its map crop** (`crop`, an image covering about 1,000 x 560 km around the place) and read its facts:
   the kind, biome, elevation, coast and river, the nearest places with distances, qi, the owner, the catalogue's
   look, lore and history, the depth pages' lines, and `seat_of`. Describe the land that the map really paints: an
   island stays an island.
2. **Decide its size first**, and write it in a `size` field. Give its dimensions, its people, its building count,
   and why.
   - **A great sect's seat:** a domain kilometres across, housing thousands, with hundreds of buildings.
   - **A minor sect:** a walled settlement of dozens to about a hundred buildings, scaled to its members and age (a
     young 40-person hall is smaller than a 600-year-old house).
   - **A city:** tens of thousands of roofs, walls and districts.
   - **A town:** a thousand or more.
   - **A village:** all its few dozen houses and fields.
   - **A ruin:** what it was, now broken.
   - **A natural site** (peak, lake, vein, lair, spring, forest, gorge): the feature at its true size, with at most a
     shrine or a camp.
3. **Give it its own character.** What makes this sect or town this one and no other:
   - for a sect, its gate, practice grounds, scripture halls, its craft (forges, herb terraces, bird lofts, bell
     towers, rice terraces), its doctrine's look, and its history on the land;
   - for a town or city, its trade, its people and its ruler;
   - a moved seat as it is now; an old seat as what the page says it became.
4. Write `where`, `imagined` (one moment, not sent) and `subject`. The subject is a precise description of about
   250-350 words:
   - setting and land;
   - the place at its decided size, laid out with counts and materials;
   - the signature elements;
   - life at scale;
   - light and season.

## Write
One file per chunk of about 20 places: `design/world/depth/art/places/<batch>/<nn>.json`, shaped like `pilot.json`
(`{"places": [...]}`). Each entry has these fields:
- `id`;
- `name`;
- `kind` (what it is painted as);
- `size`;
- `where`;
- `imagined`;
- `subject`.

Skip place 214 (done in the pilot); places 239 and 376 are redone.

## Rules
- **Top-down aerial view**, at true scale, never a miniature.
- **No text,** no flags with symbols, no borders or markers; people appear only as tiny figures for scale.
- **No weather or terrain in game rules:** this is art only.
- No names, characters or images from existing novels, dramas or games.

## Finish
Validate that each file parses. After each chunk, append one line to `design/world/depth/art/_progress.md`:
`<batch> chunk <nn> done <count>`. Touch only your batch's files and the progress file. Do not commit. Report in under
100 words.
