# Place catalogue (proposal, 2026-11-22 overnight)

**Why:** the user (2026-11-22): every town, blessed land and unique location should look unique, with a description of
how it looks, some lore, and its own art, so the world feels lively; places whose history is thin get lore first, even
ones without special locations; art for a place's levels and for the stages of its great projects (art bible
Section 1, Principle 2: no generic places).

**Status:** proposal, written overnight by world-builder agents from the recorded world (inputs in `_inputs/`), merged
and checked by Claude; **the user reviews it in the morning**. Not yet exported to `assets/data/`.

**Inputs** (`_inputs/`, built by `tools/design/world/place_packs.py`): `world_brief.json` (start year 1200, the great
sects, the six eras, the 200 landmark events) and `pack_NN.json` (four regions each: the region's name, image, holder,
land, famous sites, fallen sects; every place with its kind, land, name and allusion, the events that mention it, the
sect seated there, its residents).

## Output format (`pack_NN.json`)

```json
{"places": [
  {"id": 41, "name": "Lai Nghi Thành",
   "look": "2-3 sentences: what a traveller sees arriving, with one signature visual element no other place has.",
   "lore": "2-4 sentences: who lives here, what it is known for, a custom or legend; agrees with every recorded event.",
   "special": true,
   "history": "special places only: 5-8 sentences in year order, built on the recorded events, filling gaps plausibly.",
   "art_brief": "One paragraph for the image model: the place as a small painted miniature on the map (see Art).",
   "levels": ["what it looks like one development level up", "and two levels up"],
   "projects": ["great-project kinds this place would plausibly take on (see great_projects_proposal.md)"]}
]}
```

`levels` is for settlements and sect seats only (village, town, city, market, great and minor seats); `projects` is
optional (0-2).

## Writing rules

- **English, with Hán-Việt terms** in parentheses on first use (sect (tông môn), spirit vein (linh mạch)); names of
  places, sects and people stay Hán-Việt exactly as in the pack.
- **The record wins.** Never contradict an event, a founding year, a holder or a person in the pack. Cite nothing new as
  fact about named people. Unnamed locals (an old ferryman, the well-keeper's daughter) are fine. Secret events
  (`"secret": true`) may only be hinted at as rumour, never stated.
- **No new numbers that the game would use:** no prices, realm claims, populations, distances, stats. Years only from
  the record ("since the city was founded in 530"); otherwise "a century ago", "in the Age of First Gates".
- **Original world:** genre conventions of cultivation fiction are welcome; never characters, places, sects, plots or
  signature items of Phàm Nhân Tu Tiên or any other work.
- **Realistic geography:** the look follows the place's real land (biome, elevation, coast, river, port, the region's
  image). No themed zones; a desert town looks like a desert town of this world.
- **Unique:** every place gets one signature element (a tower, a bridge, a dyed-cloth market, a split boulder, a
  shrine to a drowned general) that no other place in the catalogue shares. Villages are small but still specific.
- **Tone:** grounded and vivid, like a good travel journal from a world of cultivators; short, concrete sentences.

## Art (for `art_brief`)

The near map (art bible Sections 1-3, 6 to come) is a golden-hour painted relief seen from above at an angle, like a
hand-painted scale model; each place is a **small painted miniature** on it, placed by the engine on the place's tile.
The brief describes: the miniature at a glance (footprint, the tallest or signature element), materials and roof
colours, what of the land sits at its base (a dock, terraces, a cave mouth), the light (warm, from the top left), and
what to avoid (no text, no people larger than specks, nothing outside the place's footprint). Shape language
(Section 3): villages and towns are low clusters of grey-tile roofs, towns inside rectangular walls; sect seats are
vertical (stacked pagoda roofs and terraces climbing a slope, the tallest outline in their land); ruins are broken
verticals; blessed lands and natural sites lead with a natural feature and no roofline.
