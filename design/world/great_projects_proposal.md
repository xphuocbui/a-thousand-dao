# Great projects (đại công trình): proposal

> **Status:** proposal, 2026-11-22 overnight (Claude, from the user's request: "think of a few great projects places
> can have, and have arts for each stage of the great project"). Not a GDD: it names the projects, their stages and
> their art; numbers and rules belong in a GDD revision (Travel & Map rule 31, Sects #26) once the user approves the
> idea. **Direction approved by the user 2026-11-23** (answers at the end); rules and numbers handed to the GDD session.

## What a great project is

A **great project** is a named, staged **shared work** (Travel & Map rule 31, layer 2): the holder of a place (a sect,
a city, later the player) spends seasons and linh thạch or materials on it, and each finished stage changes the place
for everyone there **and changes how the place looks** (art bible Section 1, Principle 2: "only a place's own art
advances by stage"). Its effects use levers the game already has: density, element shares, production, development
levels, the residence grade cap, travel time, beast-tide defence. No new stat kinds.

- **Stages (user, 2026-11-23): the count depends on the project.** Most have 3 or 4; 2 and 5 are rarer. A project's
  stages are a list in the data, so a project can gain a stage later without touching the others (room for growth).
  Today: 5 for the gathering array; 4 for the cloud ladder, trade quarter, harbour works and warding wall; 3 for the vein
  canal, spirit terraces, scripture pavilion and great furnace; 2 for the sanctuary (it must leave its feature
  untouched).
- **Who builds (user, 2026-11-23):** world NPC holders start projects in the living-world tick (Sects #26 investment
  already spends a treasury's surplus); the player **funds** one through a sect or city mission first, and **builds on
  their own ground later**, once cave abode land is bigger.
- **On the far map (user, 2026-11-23):** a small inked symbol beside the place name once a project is complete; the
  painted stages are near-map art.
- **Undone:** war or a beast tide can knock a project back a stage; an abandoned upkept project fades (rule 31's two
  kinds).

## The projects (by place kind)

| Project | Hán-Việt | Where | What it does (lever) | Kind | Stages: how each looks, in order |
|---|---|---|---|---|---|
| Great gathering array | Tụ Linh Đại Trận | Sect seats; cities on a spirit vein | Density up at the place | Upkept | Survey stakes and nine foundation stones in a ring → stone pillars carved with array script → the pillars lit, faint qi lines joining them over the roofs → a second, outer ring of pillars, the lines drawing one array figure over the place → the figure glowing on the ground, a soft pillar of light at its centre, clouds drawn into a slow spiral (5) |
| Vein canal | Linh Mạch Cừ | Towns and villages within reach of a spirit vein | Density and an element push (the vein's element) | Permanent | A trench cut from the vein → stone-lined channel with sluice gates → the channel glowing faintly, mist where it meets the town (3) |
| Spirit field terraces | Linh Điền | Villages, towns; hill country | Herb production | Permanent | Marked slopes and first walls → terraced fields stepping up the hill → terraces green with spirit herbs, a small gathering stone at the top (3) |
| Cloud ladder | Thiên Thê | Mountain sect seats; gorges and passes | Travel time through the place | Permanent | Anchors driven into the cliff → a stair and plank road climbing the face → a roofed sky bridge across the gap, lanterns along it → a second bridge and a lantern-lit waystation halfway up the cliff (4) |
| Trade quarter | Thương Hội Quán | Markets, cities | Production value and Trade level | Upkept | A cleared square and timber frames → covered halls and warehouses → a walled quarter with a tall guild hall and banners → the quarter grown past its walls: a second guild hall, caravan yards, warehouse rows (4) |
| Harbour works | Hải Đê | Ports | Sea-lane trade; storm safety | Permanent | Piles and a rubble mole → a stone breakwater and quays → a lighthouse pagoda at the breakwater's end → a second breakwater closing a full basin, dry docks and a customs hall (4) |
| Warding wall | Hộ Thành Đại Trận | Border cities, towns near beast lairs or the miasma waste | Beast-tide and raid defence; Military level | Upkept | An earth rampart and stakes → stone walls with gate towers → the walls with ward talismans and a dome-shaped ward shimmer at dusk → a second, outer wall with watchtowers, the dome bright and banded with script (4) |
| Scripture pavilion | Tàng Kinh Các | Sect seats | Institutions level (manuals, teaching) | Permanent | A cleared terrace → a three-storey pavilion going up in scaffolding → a five-storey library pagoda with a brass roof finial (3) |
| Great furnace | Đan Lô / Khí Phường | Seats and cities with an alchemy or forging craft; near lava vents | Craft quality and output (Alchemy, Artifact Refining) | Upkept | A stone platform and flue → a furnace hall with a tall chimney → the hall with a glowing furnace mouth and a column of coloured smoke (3) |
| Sanctuary | Tĩnh Thất | Blessed lands, sacred summits (no rooflines; art bible Section 3) | Keeps the place's qi from being drained; residence grade cap | Permanent | A cleared path and marker stones → a small open pavilion with a ring of stone lanterns beside the feature, the feature itself untouched (2) |

Ten projects cover every place kind that has a holder: a village can raise terraces or a vein canal, a town a trade
quarter or a warding wall, a city most of them, a sect seat its array, pavilion and furnace, a blessed land only a
sanctuary. Each place in the catalogue (`design/world/place_catalogue/`) lists 0-2 projects it would plausibly
undertake, from its land and history.

## Art (fits the near map)

Each place has its own painting on the near map (the catalogue's `art_brief`, `tools/asset-pipeline/map/place_art.py`).
A project's stage is painted **from that place's own painting** with only the stage's change, and each stage from the
one before it (`tools/asset-pipeline/map/place_stages.py`), so the place visibly grows instead of being redrawn; the
engine swaps the stage sprite for the place's sprite on its tile.

- **Done (2026-11-22/23):** each of the 10 projects at one example place that lists it, all its stages (35 images).
- **Later:** stages for every other place that builds a project (painted the same way, when the place starts it).
- **Far map:** one small inked symbol per project kind, drawn by the engine beside the place name.
- A place's **levels** (village → town → city, a sect's development levels) are drawn as variants of its own miniature
  (the catalogue's `levels` lines), not as project sprites.

## Answered (user, 2026-11-23)

1. Player's own ground: **both**: fund a holder's project first, build on own ground later.
2. Far map: **a small symbol** once complete.
3. Stage count: **per project**, mostly 3-4, rarer 2 and 5, room to grow (replaces the fixed 3 + Renowned).
4. Levers and sizes: **handed to the GDD session** (Travel & Map rule 31, Sects #26); see
   `production/plans/handoff-great-projects.md`.
