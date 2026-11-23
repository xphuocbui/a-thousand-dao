# Art bible drafts: Section 6 (Environment Design Language) and 8.8 (map and place art standards)

> **Status:** draft, 2026-11-23 overnight (Claude, under the art lens, from what the night's map and place art
> established). **Not in the art bible yet:** each section goes in only with the user's approval (the `/art-bible`
> rule). Section 5 (characters) is not drafted.

## Section 6. Environment Design Language (draft)

**One land, painted once.** The continent is authored and the same every life (fixed world), so its terrain is painted
once, as two layers registered to the 540 × 360 grid (Section 1, Principle 2):
- **Far layer (paper campaign map):** warm parchment, ink coastlines with a soft coloured wash, pale sea with sparse
  brushed waves, mountains as rows of small painted peaks, forests as clusters of round tree symbols, washes for grass,
  desert and dry hills. One painting; region tints, borders and names are engine overlays (7.14).
- **Near layer (painted relief):** a hand-painted scale model seen straight down: individual tree crowns, folded ridges
  with snow, glinting rivers, golden-hour light from the top left. 12 px per tile. No settlements, roads or text: the
  land only.

**Places are built into the land, not stamped on it.** Each named place is painted into its own patch of the near layer,
so its base follows the slope, shore and river that are there, and its light and scale match the land. Shape grammar by
kind (Section 3): villages low clusters of grey or thatch roofs with gardens; towns inside a modest wall or palisade;
markets around a big open square of awnings; cities a rectangular wall with gate towers, dense roofs and suburbs along
the roads; sect seats vertical, stacked pagoda roofs and terraces climbing a slope, the tallest outline in their land;
ruins broken and roofless, no smoke; natural sites (peaks, veins, lakes, groves, vents) lead with the feature and carry
at most a shrine or a ring of stones.

**Architecture and culture.** One civilisation of cultivators: timber halls on stone bases, grey-tile roofs with curved
eaves, red-lacquered halls only for sects and the rich, brass and bronze for fittings and bells, white-walled lanes in the
south, wind-scoured stone in the north and the high ranges. A sect's architecture follows its element leanings and
craft (a forge sect's chimneys, a water sect's bridges), never a theme park.

**Every place has one signature** (Section 1, Principle 2; the place catalogue): one visual element no other place
shares (a nine-tier bell terrace, a spiral white path, smoke rising out of firs). The art brief names it; the painting
makes it the tallest or brightest thing in the patch.

**Texture philosophy.** Painted, not PBR: soft brushwork at map scale, real light (one sun, top left, warm), colour
from the biome, never from a theme. The world's colour stays below the build's (Principle 3): no saturated element
colours in the land except where the world itself glows (a spirit vein, a lava vent), and those are small.

**Growth is visible.** A place's development levels and its great projects' stages are painted from its own painting,
changing only what the level or stage adds (a furnace hall, a second wall ring, an array of lit pillars), so a place
visibly grows in the same spot and the same light. The land under it never changes (Principle 2); world-state changes
(borders, control, war) are overlays.

**Environmental storytelling.** The catalogue's look and lore decide what the painting shows: a burned quarter that was
never rebuilt, a drowned jetty, the dry stream bed where a river once ran. Secrets (hidden places, tile secrets) are
never painted until found.

## 8.8 Map and place art standards (draft)

| Asset | Made as | Size | Notes |
|---|---|---|---|
| Guide render | `tools/asset-pipeline/map/guide.py` | 2160 × 1440 (4 px/tile) | biome colours, hill shade, rivers, sea by depth; the input to every map painting |
| Near layer | 35 overlapping crops painted over the guide, colour-matched, feather-stitched (`paint_tiles.py`), open sea calmed (`sea_fix.py`) | 6480 × 4320 (12 px/tile), JPEG q90 | imported VRAM-compressed with mipmaps (~19 MB VRAM) |
| Far layer | one painting of the whole guide (`prompts/far.md`), high quality | 1536 × 1024 (2.84 px/tile) | lossless, mipmaps; checked by overlaying the true coastline |
| Place art | each place painted into its own 40 × 22.5-tile patch of the near layer (`place_art.py`); a soft-edged circle cut out, fitted to what was painted and capped at 55 % of the distance to the next place | 2× the near layer (24 px/tile), RGBA PNG | `assets/map/places/manifest.json`: tile and size in tiles; drawn for known places only |
| Stage art | levels and great-project stages painted from the place's own painting (`place_stages.py`), cut with the base patch | as place art | `assets/map/places/stages/manifest.json` |

- **Masters and prompts** are kept beside the scripts (`design/map/continent-11/art/`, `tools/asset-pipeline/map/prompts/`)
  with each call's meta file (model, quality, prompt, usage); everything regenerates from the scripts.
- **Model:** gpt-image-2, medium for crops and places (high for the single far painting); about $0.053 per medium image.
- **Never baked:** text, labels, borders, markers, region names, player or NPC figures.
- **Memory:** near layer ~19 MB VRAM, far layer ~6 MB, place sprites loaded on first draw (~254 × ~0.6 MB worst case if
  all are seen; budget to confirm in `project.yaml` when performance budgets are set).
