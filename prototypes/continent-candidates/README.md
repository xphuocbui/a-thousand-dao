# Continent Candidates (prototype)

> PROTOTYPE - NOT FOR PRODUCTION. Throwaway: nothing here ships or is imported.

**Hypothesis:** a generator that follows real geography (plates, rain shadows, rivers from rain, climate by
latitude and height) gives a continent that looks like a real map and holds every biome naturally, good enough to
pick one and finish it by hand as the game's fixed world.

**Status:** in progress (2026-11-13): 12 candidates generated at 540 × 360 tiles (about 25 km a tile; the user
asked for the same world size on a grid about 20 times finer than the first 120 × 80 round), awaiting the user's
pick.

**How to run:**

```
python -I tools/design/map/continent_gen.py --seeds 1-12 --out prototypes/continent-candidates
```

The generator lives in `tools/design/map/continent_gen.py`; its rules, with sources, are in
`design/research/map-making-rules.md`. About 40 seconds per seed at 540 × 360, pure Python plus Pillow. The grid
size is a parameter (`tiles_w`, `tiles_h`); distances scale with it.

**Round 2 (2026-11-13):** the user found round 1 unrealistic (blob outlines, straight ranges, rivers that did not
carve the land, too many round lakes, latitude-stripe climate, flat rendering). The generator was rebuilt on the
round 2 rules (R36–R60): land grown from ~330 small regions and drowned by a rising sea, plates grown from the same
regions, an uplift map carved by the stream power law (implicit Braun–Willett solver, 48 steps), climate-driven
basins (wet ones drain, dry ones keep salt flats, rifts keep lakes), two-season climate with continentality, and
multi-light rendering. Round 1's candidates were replaced.

**Round 3 (2026-11-13):** the user found round 2's coasts too rough ("a bit too in and out"): the rising sea had
drowned every valley. Rules R61–R65 add wave smoothing that varies along the coast (soft, low shores straightened
over about 75 km; hilly coasts keep capes; cold, hilly coasts keep fjords; small islands untouched), a gentle wobble
so filled bays are not circles, a preview coast drawn between tile centres, and the shore measure in the map check.
Shore tiles fell by about 40 % (seed 5: 7,336 to 4,264). Round 2's candidates were replaced.

**Round 4 (2026-11-13):** the user wants a tile to hold several kinds of land at once. Rules R66–R70: the land is
refined onto a fine map 4 times finer (2,160 × 1,440 cells of about 6 km), biome borders break into natural patches
there, rivers become smooth lines, and each tile's mix (up to 3 biomes, each at least 10 %) is read from its 16 cells.
About 20 % of land tiles are mixed; every candidate now holds every generated biome. Coast and Lake-and-river-valley
are no longer biomes; Lake is. Still about 40 seconds a continent; the 12 run in parallel.

**Each `cand-NN/` holds:**

- `detail.jpg` (2,160 × 1,440, the fine map drawn naturally) and `preview.png` (half size);
- `tiles.png`: the actual 540 × 360 game grid, each tile coloured by its mix, with rivers (blue), lava (red), hot
  springs (orange) and ore veins (darkened) marked;
- the index images Travel & Map rule 1 asks for. Per fine cell: `fine_biome.png` (palette, ids in `meta.json`),
  `fine_elevation.png` (16-bit, metres + 10,000), `fine_water.png` (bits: 1 sea, 2 lake, 4 river). Per tile:
  `biome.png` (main biome), `mix_biome.png` and `mix_share.png` (RGB: up to 3 biome ids and their shares in %),
  `elevation.png`, `temperature.png` (8-bit, (°C + 50) × 2), `rainfall.png` (16-bit, mm) and `features.png`
  (16-bit feature bits);
- `meta.json`: the seed, every parameter, the legend and the map check (land share, biome shares, missing biomes,
  rivers, lakes, volcanoes, islands).

**Known limits:**

- The miasma wasteland, spirit veins, sacred summits, deep caves and miasma sources are never generated; they are
  authored (rules R27, R29).
- The candidate folders (about 47 MB) are not committed: any seed is rebuilt exactly by the command above.
- At 25 km a tile, each tile is one point of terrain rather than an average, so high peaks read colder than in
  the 120 × 80 round and more of them are glacier.

## Findings

(to be filled in when the user picks)
