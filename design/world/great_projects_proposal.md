# Great projects (đại công trình): proposal

> **Status:** proposal, 2026-11-22 overnight (Claude, from the user's request: "think of a few great projects places
> can have, and have arts for each stage of the great project"). Not a GDD: it names the projects, their stages and
> their art; numbers and rules belong in a GDD revision (Travel & Map rule 31, Sects #26) once the user approves the
> idea. **For the user's review.**

## What a great project is

A **great project** is a named, staged **shared work** (Travel & Map rule 31, layer 2): the holder of a place (a sect,
a city, later the player) spends seasons and linh thạch or materials on it, and each finished stage changes the place
for everyone there **and changes how the place looks** (art bible Section 1, Principle 2: "only a place's own art
advances by stage"). Its effects use levers the game already has: density, element shares, production, development
levels, the residence grade cap, travel time, beast-tide defence. No new stat kinds.

- **Stages:** each project has **3 visible stages** after it is founded: *Foundations*, *Raised*, *Complete*. A fourth,
  *Renowned*, is reserved for the few that history or the player makes famous (a named array that held off a beast
  tide).
- **Who builds:** world NPC holders start projects in the living-world tick (Sects #26 investment already spends a
  treasury's surplus); the player can fund one through a sect or city mission, and later build one on their own
  ground.
- **Undone:** war or a beast tide can knock a project back a stage; an abandoned upkept project fades (rule 31's two
  kinds).

## The projects (by place kind)

| Project | Hán-Việt | Where | What it does (lever) | Kind | Stage looks: Foundations → Raised → Complete |
|---|---|---|---|---|---|
| Great gathering array | Tụ Linh Đại Trận | Sect seats; cities on a spirit vein | Density up at the place | Upkept | Survey stakes and nine foundation stones in a ring → stone pillars carved with array script → the pillars lit, faint qi lines joining them over the roofs |
| Vein canal | Linh Mạch Cừ | Towns and villages within reach of a spirit vein | Density and an element push (the vein's element) | Permanent | A trench cut from the vein → stone-lined channel with sluice gates → the channel glowing faintly, mist where it meets the town |
| Spirit field terraces | Linh Điền | Villages, towns; hill country | Herb production | Permanent | Marked slopes and first walls → terraced fields stepping up the hill → terraces green with spirit herbs, a small gathering stone at the top |
| Cloud ladder | Thiên Thê | Mountain sect seats; gorges and passes | Travel time through the place | Permanent | Anchors driven into the cliff → a stair and plank road climbing the face → a roofed sky bridge across the gap, lanterns along it |
| Trade quarter | Thương Hội Quán | Markets, cities | Production value and Trade level | Upkept | A cleared square and timber frames → covered halls and warehouses → a walled quarter with a tall guild hall and banners |
| Harbour works | Hải Đê | Ports | Sea-lane trade; storm safety | Permanent | Piles and a rubble mole → a stone breakwater and quays → a lighthouse pagoda at the breakwater's end |
| Warding wall | Hộ Thành Đại Trận | Border cities, towns near beast lairs or the miasma waste | Beast-tide and raid defence; Military level | Upkept | An earth rampart and stakes → stone walls with gate towers → the walls with ward talismans and a dome-shaped ward shimmer at dusk |
| Scripture pavilion | Tàng Kinh Các | Sect seats | Institutions level (manuals, teaching) | Permanent | A cleared terrace → a three-storey pavilion going up in scaffolding → a five-storey library pagoda with a brass roof finial |
| Great furnace | Đan Lô / Khí Phường | Seats and cities with an alchemy or forging craft; near lava vents | Craft quality and output (Alchemy, Artifact Refining) | Upkept | A stone platform and flue → a furnace hall with a tall chimney → the hall with a glowing furnace mouth and a column of coloured smoke |
| Sanctuary | Tĩnh Thất | Blessed lands, sacred summits (no rooflines; art bible Section 3) | Keeps the place's qi from being drained; residence grade cap | Permanent | A cleared path and marker stones → a small open pavilion beside the natural feature → the pavilion with a ring of stone lanterns, the feature itself untouched |

Ten projects cover every place kind that has a holder: a village can raise terraces or a vein canal, a town a trade
quarter or a warding wall, a city most of them, a sect seat its array, pavilion and furnace, a blessed land only a
sanctuary. Each place in the catalogue (`design/world/place_catalogue/`) lists 0-2 projects it would plausibly
undertake, from its land and history.

## Art (fits the near map)

Each place has its own miniature (the catalogue's `art_brief`). A project's stages are drawn **as separate small
sprites the engine places beside or around the place's miniature**, from the project's own anchor (the harbour mouth,
the cliff face, the hill slope), so one set of stage art serves every place that builds that project:

- **10 projects × 3 stages = 30 sprites**, painted in the near map's style (golden-hour relief, light from the top left),
  on a transparent ground, at the place miniature's scale.
- **Renowned** stages and sect-seat projects that history names get their own unique art later.
- A place's **levels** (village → town → city, a sect's development levels) are drawn as variants of its own miniature
  (the catalogue's `levels` lines), not as project sprites.

## Open questions for the user

1. Should the player be able to start a great project on their own ground (a cave abode's land), or only fund a
   holder's?
2. Do projects show on the far (paper) map too, as a small symbol, or only on the near map?
3. Is "Renowned" (a fourth stage won by history or deeds) wanted, or are three stages enough?
4. Which levers and how big: to be set in a GDD revision (Travel & Map rule 31, Sects #26), not here.
