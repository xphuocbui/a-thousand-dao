# Map-Making Rules for the Continent (2026-11-13)

Status: research notes and rules, written before the continent generator (`tools/design/map/continent_gen.py`).
The generator implements these rules, and its code cites them by number (R1, R2, …).

The user's direction (2026-11-13): the continent should look like a real map, with mountain ranges, jungles, ponds
and a coastline, and **nothing special** about it. Where the qi, danger and good ground end up follows from the
terrain rules in Travel & Map (depth, blending, features), not from a designed layout. So these rules describe
believable physical geography only. Anything that breaks them (a miasma wasteland, a sacred summit) is authored
later, on purpose and with a reason.

## Sources

Read for these rules (2026-11-13):

- Lauren Davis, "10 rules for making better fantasy maps", Gizmodo (2015):
  https://gizmodo.com/10-rules-for-making-better-fantasy-maps-1680429159
- "Top 10 Mistakes of Fantasy Map Making", Inkwell Ideas (2026):
  https://inkwellideas.com/2026/05/top-10-mistakes-of-fantasy-map-making/
- Tomas Pueyo, "The Rain Shadow Effect", Uncharted Territories:
  https://unchartedterritories.tomaspueyo.com/p/the-rain-shadow-effect
- "An Apple Pie from Scratch, Part VIb: Climate: Biomes and Climate Zones", Worldbuilding Pasta (2020), read in
  part: https://worldbuildingpasta.blogspot.com/2020/05/an-apple-pie-from-scratch-part-vib.html
- Amit Patel (Red Blob Games), mapgen4 and its posts on elevation and rainfall:
  https://www.redblobgames.com/maps/mapgen4/ ·
  http://simblob.blogspot.com/2018/08/mapgen4-elevation.html ·
  http://simblob.blogspot.com/2018/09/mapgen4-rainfall.html
- Amit Patel, "Rivers" (draft): https://www.redblobgames.com/maps/rivers/
- rlguy, FantasyMapGenerator (an implementation of Martin O'Leary's "Generating fantasy maps"):
  https://github.com/rlguy/FantasyMapGenerator
- Search results that summarised further guides (Pathfinder's world-building rules, Worldbuilding Stack Exchange,
  Red Blob's "Labels on Maps", "Mapmaking principles", Here Dragons Abound). These are secondhand and only back
  rules that a source above also states.

Martin O'Leary's own notes (mewo2.com/notes/terrain) returned 404 and the Codidact coastline question refused
automated access, so neither was read directly.

## Scale

The map spans from about 76°N at the top edge to just past the equator (4°S) at the bottom, so it runs from high
Arctic to tropics. The whole map is about 13,300 × 8,900 km and the continent covers about 44 % of it, roughly
50 million km² (Asia-sized, about five times China). That is big enough for real continental interiors, rain
shadows and climate belts to appear.

**Grid (user decision 2026-11-13): 540 × 360 tiles, about 25 km a tile,** about 20 times the GDD's first 120 × 80.
The generator works on one cell per tile. Every distance in its rules is written in **reference cells** (about
37 km, from the 360-cell-wide grid it was first tuned on) and scales with the grid, so the same seed gives the same
geography at any resolution; only the detail changes. Travel & Map's per-tile numbers (travel speeds, sight radius,
search areas, depth and feature reaches) were set for 110 km tiles and need rescaling to the new tile size.

## A. Shape and coast

- **R1. The land's shape comes from geology, not from the page.** No straight edges, no continent filling the
  rectangle; open sea runs all the way round the map edge (Gizmodo #6, "break out of the rectangle").
- **R2. One main landmass with islands.** About 40–48 % of the map is land, most of it one continent. Islands come
  from causes: volcanic arcs offshore, ranges running into the sea, and fragments near the coast. A few tiny islands
  look good; many look messy, so specks below a minimum size are removed (O'Leary via search results; rule R7 for
  chains).
- **R3. Coastlines are irregular at every scale**, with bays, capes and peninsulas. They are smoother along low
  plains and rougher where mountains meet the sea.
- **R4. Sheltered bays exist**, because they are where ports and great cities grow (Pathfinder, via search
  results).

## B. Mountains

- **R5. Mountains form in ranges, in lines, where tectonic plates meet.** Never an isolated range on a flat plain
  without a cause: its rivers would not make sense (Inkwell #1; search results).
- **R6. Range types follow plate boundaries:**
  - two continents colliding: the highest ranges, with a high plateau behind them;
  - ocean against continent: a coastal range with a line of volcanoes inland from the coast;
  - ocean against ocean: a volcanic island arc;
  - a continent pulling apart: a rift valley with lakes and volcanoes;
  - old boundaries: low, worn ranges (old mountains are eroded hills).
- **R7. A range is many peaks, not one smooth ridge.** Peaks come from distance fields around scattered points, and
  noise only adds coarse shapes and light texture. Fractal noise alone did not look like hand-drawn maps, and ridge
  noise only got part of the way (mapgen4 elevation post).
- **R8. Ranges that run into the sea become island chains** (search results).
- **R9. Volcanoes stand in lines** along ocean–continent and ocean–ocean boundaries and in rifts.

## C. Climate

- **R10. Temperature falls with latitude and with height.** It drops steadily from the equator to the pole and by
  about 4.5–6.5 °C per km of height (Worldbuilding Pasta gives −4.46 °C per km; the common figure is 6.5). The
  generator uses 6 °C per km. Inland areas are colder than coasts at high latitudes, because the sea moderates
  coastal climate.
- **R11. Prevailing winds depend on latitude:** from the east between 0° and 30° (trade winds), from the west
  between 30° and 60° (westerlies), and from the east again beyond 60° (polar easterlies) (Pueyo; Worldbuilding
  Pasta). Plan the wind before placing deserts and forests (Inkwell #2).
- **R12. Wet and dry belts:** a rainy equator (rainforest within about 10°), dry subtropics (deserts mostly between
  15° and 30°), wet mid-latitudes (wettest about 45–60° on western coasts), and dry polar air (Worldbuilding Pasta;
  Inkwell #1).
- **R13. Rain shadows.** Moist air rising over a range rains on the windward side and arrives dry on the lee side.
  More than 1 km of relief gives real mountain rain, and more than 2 km can make a rain-shadow desert. The wet side
  flips between the trade-wind and westerly belts (Pueyo; Worldbuilding Pasta).
- **R14. Rain fades inland.** From a coast the wind blows onto, forest gives way to steppe and then desert over
  about 2,000–3,000 km; from a coast the wind blows away from, after about 1,000 km. Subtropical west coasts under
  the trade winds are dry, which gives coastal deserts (Worldbuilding Pasta).
- **R15. Moisture must not leak through ranges in straight lines.** Carrying it along exact rows made green strips
  through deserts, so rain is smoothed sideways after it is computed (mapgen4 rainfall post).

## D. Water

- **R16. Water flows downhill.** A river never runs uphill or crosses a ridge (Inkwell #1; search results).
- **R17. Rivers join going downstream and do not split**, except in deltas at their mouths (Inkwell #3; Red Blob
  "Rivers": one outflow per cell).
- **R18. Every river ends** in the sea, in a lake, or in a dry inland basin. No river runs from coast to coast,
  which would make that land an island (search results).
- **R19. Rivers come from rain.** Big rivers drain wet basins; dry lands have few small rivers, but a river fed by
  wet mountains can cross a desert (mapgen4 rainfall post; Gizmodo #3). Only the larger flows are drawn (mapgen4).
- **R20. Lakes sit in basins:** rifts, hollows behind ranges, and the hummocky ground of the cold north. In a dry
  closed basin the water evaporates and leaves a salt flat.
- **R21. Water shapes the land.** The height map is eroded by flow and slope, so rivers cut valleys
  (O'Leary's method, as implemented by rlguy). Depressions are filled first so every point drains (Planchon–Darboux
  filling in that implementation; the generator uses the equivalent priority-flood method).

## E. Biomes

- **R22. Climate decides the biome.** Temperature and rainfall pick the biome, as in the Whittaker and Köppen
  schemes (Worldbuilding Pasta; search results: hot and dry gives desert, hot and wet gives jungle).
- **R23. Biomes change gradually:** desert to steppe to grassland to forest as rain rises. Sharp changes happen only
  at mountains and coasts (Art of World Building, via search results).
- **R24. Our 20 biomes from climate** (annual mean temperature T in °C, annual rain P in mm; the generator's first
  values, tuned by looking at the results):

  | Climate | P < dry | dry … semi | semi … moist | moist … wet | wetter |
  |---|---|---|---|---|---|
  | T ≤ −10 | glacier | glacier | glacier | glacier | glacier |
  | −10 < T ≤ −3 | tundra | tundra | tundra | tundra | tundra |
  | −3 < T ≤ 4 | steppe (< 250) | temperate forest (boreal) | temperate forest | temperate forest | temperate forest |
  | 4 < T ≤ 12 | desert (< 250) | steppe (250–450) | grassland (450–750) | temperate forest (> 750) | — |
  | 12 < T ≤ 19 | desert (< 250) | steppe (250–500) | grassland (500–900) | temperate forest (900–1,400) | bamboo forest (> 1,400) |
  | T > 19 | desert (< 300) | steppe (300–650) | grassland, savanna (650–1,300) | bamboo forest (1,300–1,900) | jungle (> 1,900) |

- **R25. Height overrides climate.** High and rugged ground (above about 2.5 km, or above about 1.2 km with
  steep relief) is high mountain; high and flat ground (about 1.2–2.5 km) is highland; very cold peaks are glacier.
- **R26. Special land comes from its own cause:**
  - **mangrove:** low, hot, wet tropical shores;
  - **swamp:** low, flat, wet ground, mostly along big rivers and lakes;
  - **salt flats:** the floors of dry closed basins (R20);
  - **badlands:** dry, rugged mid-height ground;
  - **karst peaks:** warm, wet hill country, in patches where the rock is limestone;
  - **volcano:** the cones around volcanic vents (R9);
  - **coast:** the shore tiles of plains and grasslands;
  - **lake and river valley:** the floodplains of big rivers and the shores of lakes.
- **R27. The miasma wasteland is never generated.** It has no natural cause; it comes from history and is
  authored.

## F. Features (the feature layer)

- **R28. Generated, because they have physical causes:** lava flows and vents (on volcanoes), hot springs (near
  volcanoes), ice fields (the cores of glaciers), rivers and lakes, ore veins (in mountain ranges, more in old
  ones), and karst cores (the hearts of karst country).
- **R29. Not generated:** spirit veins, sacred summits, deep caves beyond karst cores, and miasma sources. These
  are authored later, where history or the design wants them.
- **R30. Derived when the map is built,** not painted: the snowline, storm peaks and high plateaus (Travel & Map
  Formulas C thresholds).

## G. The look

- **R31. Keep layers separate:** coastline, mountains, rivers and text (search results). Here that means separate
  index images per layer.
- **R32. Draw only the larger rivers;** small streams clutter the map (mapgen4).
- **R33. Colour carries the map,** and thinner, smaller marks make a map feel bigger ("Mapmaking principles", via
  search results). This matters for the overview painting and the zoomed-in view.
- **R34. Rivers look too regular on a square grid.** Red Blob's fix is an irregular mesh; ours is the finer
  3 × 3 grid with noisy terrain, which bends rivers enough at this scale.

## H. Exceptions

- **R35. Break a rule only with a reason.** Magical regions feel special because the rest of the world is
  realistic (search results). The generator never breaks rules; authored exceptions come later.

## I. The map check (observations, not verdicts)

For each candidate the generator reports, and never "fixes" on its own:

- land share and the main landmass's share of the land;
- each biome's tile count and share, and which biomes are missing (miasma is expected to be missing);
- rivers reaching the sea, lakes, salt flats, volcanoes and islands;
- R16 and R17 checks: rivers running uphill or splitting (both should be 0 by construction).

## J. Round 2: realism (2026-11-13)

The first generator's continents read as generated, not real. The user and I named six giveaways: blob outlines,
simple straight ranges, rivers that do not carve the land, too many round lakes, climate in latitude stripes, and
flat rendering. The user chose to fix the generator (rather than start from real Earth terrain). Round 2 rules,
from a second research pass, replace or sharpen the rules above where they say so.

**Sources (round 2):**

- Jan Dijkstra (Frozen Fractal), "Around The World" devlog: Part 1 Continents, Part 2 Plate tectonics, Part 3
  Hotspots and erosion, Part 8 Seasons, Part 9 Climates, Part 10 Fixing the climate, Part 23 Hydraulic erosion,
  Part 26 Biomes: https://frozenfractal.com/blog/2023/11/2/around-the-world-1-continents/ and the series.
- Cordonnier, Braun, Cani, Benes, Galin, Peytavie and Guérin, "Large Scale Terrain Generation from Tectonic Uplift
  and Fluvial Erosion", Computer Graphics Forum 35(2), 2016: https://hal.archives-ouvertes.fr/hal-01262376 (abstract
  and citation only; the PDF exceeded the fetch limit).
- Richard Barnes, "Accelerating a Landscape Evolution Model with Parallelism" (2018), which re-implements Braun and
  Willett's 2013 implicit O(n) stream power solver: https://ar5iv.labs.arxiv.org/html/1803.02977
- Landlab stream power component (default m = 0.5, n = 1):
  https://landlab.readthedocs.io/en/v2.9.1/_modules/landlab/components/stream_power/stream_power.html
- Cael and Seekell, "The size-distribution of Earth's lakes" (2016):
  https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4937396/
- Douglass and Fish, "That's a Relief", Cartographic Perspectives 100:
  https://cartographicperspectives.org/index.php/journal/article/download/1727/2093?inline=1
- Not read (refused or unreadable): Tom Patterson's shadedrelief.com (403), Jenny and Hurni's Swiss-style shading
  PDF (no extractable text).

### J1. Outline (replaces R1–R3's method)

- **R36. Build land from many small regions.** Scatter a few hundred Voronoi regions, warp the lookup so their
  edges are not straight, then grow the continent from one region by adding neighbouring regions at random until
  the land quota is met. One convex region per continent is always a blob; many small regions give indents,
  peninsulas and gulfs (Frozen Fractal 1).
- **R37. Keep the accidents.** Warping leaves enclosed pockets of sea inside the land; keep them as inland seas
  (Frozen Fractal 1).
- **R38. Flood the shelves.** Build the land a little too big, then raise the sea until the target land share is
  left. Low coasts drown into bays, shelves and straits, and high coasts stay as capes (Frozen Fractal 3).
- **R39. Coast steepness varies.** Near the shore, land is lowered over a noisy distance: short gives cliffs,
  long gives gentle plains (Frozen Fractal 3).
- **R40. One great continent, a few large islands.** About 85 % of the land in the main mass; the rest in one or
  two large islands and a few chains (the user's Pangaea with islands).

### J2. Mountains (sharpens R5–R9)

- **R41. Plates are grown from the same regions,** so plate boundaries follow region edges and curve and wander
  instead of running straight (Frozen Fractal 2).
- **R42. Boundary types:** continent–continent collision builds the highest ranges (a plateau where one side
  slides under); continent–ocean builds a trench, then a volcanic arc and range on the land side; ocean–ocean
  builds an island arc; continents pulling apart make a rift valley. Sliding (transform) boundaries are left out
  (Frozen Fractal 2).
- **R43. Noise on width and height:** a range's width and height vary along its length; smooth ranges look fake
  (Frozen Fractal 2).
- **R44. Hotspot chains:** a fixed hotspot under a moving plate leaves a line of volcanic islands along the
  plate's motion (Frozen Fractal 3).

### J3. Land carved by water (replaces R21's method)

- **R45. Tectonics gives uplift, water gives shape.** The tectonic step makes an uplift map, not a finished height
  map. The stream power law then carves it: each step, land rises by U × dt and erodes by K × A^m × S^n, where A is
  the area draining through a cell (weighted by rain) and S its slope; m = 0.5, n = 1 (Landlab defaults). Ridges
  and tree-shaped valleys emerge on their own (Cordonnier et al. 2016).
- **R46. The implicit solver:** each cell's receiver is its steepest downhill neighbour; cells are processed from
  the sea upward so a receiver is always updated first, with h_new = (h + U·dt + F·h_receiver) / (1 + F) and
  F = K·dt·A^m / distance (distance √2 times longer on diagonals) (Braun and Willett 2013, via Barnes 2018).
- **R47. Pits drain through lakes:** before each step, hollows are filled (priority flood) so water routes across
  them; the filled part is lake (Barnes 2018).
- **R48. Steady state:** uplift balances erosion after enough steps; plains with little uplift settle low and flat,
  ranges stay high with steep, valley-cut flanks. Big rivers end with gentle gradients.
- **R49. Hillslopes:** a light slope limit (thermal erosion) keeps single cells from spiking (Frozen Fractal 3).

### J4. Lakes (sharpens R20)

- **R50. Lake sizes follow a power law:** many small lakes, few big ones (exponent about 2.1 for lake areas, Cael
  and Seekell 2016). A continent has a handful of great lakes, not dozens.
- **R51. Lakes have causes:** rifts and tectonic basins (long, deep), the scoured lowlands of the cold north (many
  small lakes), and closed basins in dry land (salt lakes and salt flats). Plains elsewhere drain through rivers.

### J5. Climate in seasons (replaces the single annual pass of R10–R14)

- **R52. Two seasons, January and July,** with temperature and rain computed for each (Frozen Fractal 8).
- **R53. Continentality:** trace the wind back to the sea; inland cells have larger seasonal swings, so continental
  interiors get hot summers and bitter winters while coasts stay mild (Frozen Fractal 9).
- **R54. The rain belts move with the seasons:** the equatorial rain belt shifts toward the summer pole, giving
  wet summers and dry winters (monsoon and savanna) in the tropics (Frozen Fractal 9).
- **R55. Biomes from warmest month, coldest month and wetness:** wetness is rain divided by evaporative demand
  (P/PET), as in BIOME1 (Prentice et al. 1992, via Frozen Fractal 26). Köppen classes do not map cleanly onto
  biomes, so the biome table works from these inputs directly (Frozen Fractal 26).
- **R56. Biome borders are warped** with noise so they never run along latitude lines; steep slopes show bare rock
  (Frozen Fractal 26).

### J6. Rendering (replaces R33's single-light preview)

- **R57. Multi-directional hillshade,** main light from about 337.5° (north-north-west), with a few weaker lights
  around it; it reads landforms more clearly than one light (Douglass and Fish).
- **R58. Natural colours over elevation bands:** colours that look like land cover read as most realistic;
  elevation colour bands as least realistic (Douglass and Fish). Biome colours blend softly at their edges.
- **R59. The sea is shaded only by depth** from the coast outward (shelf, slope, deep); no plate structure shows.
- **R60. Rivers widen downstream** with the square root of their flow, and taper at their sources.

## K. Round 3: coasts (2026-11-13)

The user found round 2's coasts too rough, "a bit too in and out". The cause: R38's rising sea drowned every
eroded valley, so every coast became a branching drowned-valley coast, a shape real coasts have only in a few
places.

**Sources (round 3):**

- Mandelbrot, "How Long Is the Coast of Britain?" (Science, 1967), from Richardson's measurements: coast fractal
  dimension about 1.02 for South Africa (among the smoothest), 1.13 for Australia, 1.25 for Britain's west coast
  (among the roughest); Norway's fjord coast is often given as about 1.52, not traced to Richardson's data:
  https://gauss.math.yale.edu/public_html/People/frame/Fractals/Panorama/Nature/Coastlines/CoastlinesMandelbrot.html
  and https://pmc.ncbi.nlm.nih.gov/articles/PMC7973742
- Coastal straightening: waves cut headlands back and longshore drift fills the bays, until the coast is a run of
  smooth beach curves; where the rock varies in hardness, the hard headlands stay as capes:
  https://digfir-published.macmillanusa.com/understandingearth7e/understandingearth7e_ch20_4.html and
  van Rijn, "Coastal erosion and control" (2011): https://www.leovanrijn-sediment.com/papers/Coastalerosion2012.pdf

**Rules:**

- **R61. Coast roughness varies, and most of it is low.** Most coasts are smooth (dimension near 1.0–1.15); rough
  ones (about 1.25) are local; fjord coasts are the rare extreme. A continent mixes long smooth stretches with a
  few rough ones, chosen by a slow regional field, not by tile-level noise.
- **R62. Waves straighten soft coasts.** Low coasts of soft rock get capes cut back and bays filled to smooth
  curves; inlets narrower than the smoothing reach (about 75 km on the softest coasts) close up and only wide gulfs
  stay. Hilly, hard-rock coasts resist and keep their capes and drowned valleys.
- **R63. Fjords need ice and relief.** Deep branching inlets are kept only on hilly coasts in the high latitudes
  (about 46–56° and poleward) that ice-age glaciers carved. Small islands keep their shape: waves do not reshape
  them at this scale.
- **R64. Draw the coast as a curve.** The preview interpolates the coast between tile centres, so the shore never
  shows tile stair-steps; the tile grid itself is unchanged.
- **R65. Measure it.** The map check reports the number of shore tiles (land tiles touching the sea), as an
  observation; round 2 had 4,500–7,400, round 3 has 3,300–4,800. It also reports a box-counting dimension over
  1–16 tiles, but on a 25 km grid that reads 0.93–0.97, below the 1.0 a line must have, so it is not comparable
  with Richardson's numbers. Use the shore count.

## L. Round 4: mixed tiles (2026-11-13)

The user wants a tile to hold several kinds of land at once ("a bit of mountain, a bit of desert or grassland ...
together with some river"), so tiles feel natural, especially where biomes meet. Decided with the user the same
day (all four recommendations taken): a fine map 4 times finer than the tiles; up to 3 biomes per tile, each at
least 10 %; Coast and Lake-and-river-valley dropped as biomes (sea, lake and river shares and lines do their job);
fights rolled by share, with a player who knows the tile able to keep to one part.

- **R66. A fine map under the tiles.** The land is generated at fine_factor = 4 cells per tile side (2,160 × 1,440
  cells of about 6 km under 540 × 360 tiles). The fine map is the true land: the zoomed-in view draws it, and the
  tiles are read from it. The coarse run sets the large shapes (coast, ranges, rivers, climate); a fine pass adds
  the detail, so the two never disagree on anything larger than a tile.
- **R67. Detail inside a tile.** Coast and lake shores are interpolated between tile centres and bent by smooth
  noise (stronger on rough, R61 coasts). Height gains relief inside a tile, more in mountains than on plains, and
  temperature follows it by the lapse rate (R10). Near biome borders, wetness, temperature and relief vary in patches
  tens of kilometres across, so one biome breaks into groves, outcrops and clearings of the next instead of meeting
  it along a line (an ecotone). The patch noise stays coarser than one fine cell, or the map looks dithered.
- **R68. A tile's mix.** A tile's mix is the share of each biome among its 16 fine cells. Biomes under 10 % are
  folded away, at most 3 are kept, and the kept shares are scaled back to 100 (whole percents, largest remainder).
  The main biome is the largest share; a tile is sea when sea covers half of it or more.
- **R69. Rivers are lines, not shares.** Rivers are drawn as smooth curves through the coarse network (a
  Catmull-Rom spline with a gentle, smooth bend) and widen with flow. A tile records that a river crosses it; lakes
  are a biome share like any other.
- **R70. Measure it.** The map check reports land tiles with 1, 2 and 3 biomes, the mean share of the main biome,
  and how many tiles hold each biome as any part. Round 4: about 20 % of land tiles mixed, main biome about 94 % on
  average; every candidate now holds every generated biome somewhere.
