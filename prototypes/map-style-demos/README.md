# Map style demos (prototype)

**Hypothesis.** One of three candidate art styles for the Game UI world map (Travel & Map GDD,
`design/gdd/travel-map.md`, Visual/Audio; systems index #37) will read the GDD's map best: biomes at a glance, the
qi overlay, places, roads and rivers. Candidates the user named on 2026-11-10: **pixel/tile art**, a **painted
parchment map**, and **ink-wash (thủy mặc)**.

**Status:** in progress: rounds 1 and 2 done 2026-11-11, awaiting the user's pick. Throwaway: nothing here ships or is imported.

**Gallery:** https://claude.ai/artifact/2J6iSVCpfANPdPmoxjfE89 (private; also `gallery/index.html` locally).

## What is here

- `maps/build_maps.py` → `maps/maps.json`: three hand-authored demo maps on the GDD's grid model (28 × 18 cells,
  terrain chars, road and river paths, places), shared by every style so they compare like with like:
  - **A Thanh Vân**, a temperate continent (snow, mountains, a volcano, forest, swamp, jungle, desert, a lake);
  - **B Bích Hải**, an island chain;
  - **C Băng Nguyên**, a cold highland (glacier, tundra, two ranges, a valley lake, a swamp delta).
- `pixel/` (pxl, 16 × 16 tiles): `body.js` is the source, `gen.py` injects the maps into `pixel_sets.px.js`.
  Sets **p1 Spring** (seed 101), **p2 Autumn dusk** (202), **p3 Ash and jade** (303).
- `parchment/` (vex, vector): coasts are contour lines of a smoothed land field, with ripple lines, terrain symbols,
  inked rivers, dashed roads, icons, labels, cartouche and compass. Sets **c1 Sepia ink** (11), **c2 Coloured
  atlas** (22), **c3 Sect archive** (33, cinnabar seals, lined sea).
- `ink/` (vex): misty layered peaks, stippled forests, dry-brush coasts, blank-paper water, seals. Sets **k1 Pure
  ink** (7), **k2 Light colour / thiển giáng** (8), **k3 Moonlit indigo** (9).
- **Round 2** (`pixel/body2.js`, `parchment/make_round2.py`, `ink/make_round2.py`, each with a `gen2.py`):
  - pixel **p4 Glyph** (404, Dwarf Fortress / Qud-like glyphs on tinted cells), **p5 Warm cultivation** (505, foam
    shorelines, labels), **p6 Winter night** (606);
  - parchment **c4 Explorer's chart** (44, rhumb lines, junk boats, curved region names), **c5 Territory atlas** (55,
    sect territories as dotted borders with a legend), **c6 Engraved** (66, hatched relief, dense coastal contours);
  - ink **k4 Scroll** (17, vertical place names, sampans), **k5 Gold on night paper** (18), **k6 Splashed ink** (19).
- `gallery/round1|round2/<style>/`: every demo map (`*_map_A/B/C.png`, pixel maps upscaled ×3 through
  `pixel/upscale.vx.js`) and the tile, symbol and icon sheets; `gallery/make_index.py` writes `index.html`.

Notes from building: the pxl `--scale` flag does not enlarge exported scenes (upscale through vex `image(..., { pixel:
true })`); resvg panics on an exactly horizontal or vertical line inside an opacity group (offset the angle); Georgia
lacks Vietnamese glyphs (use Cambria, Constantia or Palatino Linotype).

## How to rebuild

```
python maps/build_maps.py
python pixel/gen.py     && node <pxl>/bin/pxl.js build pixel/pixel_sets.px.js --scale 3 --out pixel/out3x
python parchment/gen.py && node <vex>/bin/vex.js build parchment/parchment_sets.vx.js
python ink/gen.py       && node <vex>/bin/vex.js build ink/ink_sets.vx.js
# round 2: pixel/gen2.py, parchment/make_round2.py + gen2.py, ink/make_round2.py + gen2.py, then the *_sets2 files
```

`<pxl>` and `<vex>` are the pxl-pixel-art and vex-vector-art skill folders under `~/.claude/skills/`.

## Findings

To be filled in after the user looks at the gallery.
