# Province Panel

> **Status:** DRAFT, 2026-11-23 night (branch `provinces-v2`), written unattended for the user's review; not approved.
> **User request:** "Design a panel for provinces, learn from eu4 or eu5, they did that pretty well, use the unique place
> catalogue images for the province if it has it."
> **Inventory source:** Provinces GDD rule 3 (`design/gdd/provinces.md`): land, resources, population, production,
> buildings and works, infrastructure and access, modifiers, local price.
> **Built:** `src/ui/windows/province_panel.gd` (greybox), data `assets/data/world_provinces.json`.

## Purpose

The province is the economy's smallest unit. The panel answers, in this order, what a Paradox player reads first:
**what is this place and who holds it**, then **how big and how developed it is**, then **what it makes and how well it
reaches its market**, then **what is built here and what touches it**. It is display only (UI rule: never owns game
state).

## What we take from EU4 and EU5

| From | Pattern | Here |
|---|---|---|
| EU4 province view | Header with the owner, then development as the headline number | Name, Chinese name and gloss, holder and region in one line; development in the stat strip |
| EU4 | One trade good, shown as an icon and a name | The main good (Provinces F1) in the strip; secondary goods in Economy |
| EU4 | A grid of building slots, filled and empty | Works tab: buildings with level pips, then the empty slots (F5) |
| EU4 | Modifiers listed, each with its source | Modifiers tab, one line per modifier and source (rule 12, Pillar 2) |
| EU5 location panel | Tabs for overview, buildings, population, trade | Five tabs: Overview, Places, Economy, Works, Modifiers |
| EU5 | Population and its capacity as the first number | Population / capacity first in the strip (F3) |
| EU5 | Market access as a named number with its parts | Access % in the strip; Economy lists infrastructure against usage, and the old-roads top-up as its own line (F6) |

What we do not take: estates and pop types (mortals are one number here, cultivators are people records), and
development buttons (no one spends to raise a stat directly; buildings do it).

## Layout (Z6, the left panel zone, as the other panels)

```
┌───────────────────────────────────────────┐
│ Bình Thủy                               × │  name (heading)
│ 萍水 · Duckweed and Water                  │  name_han · gloss
│ Minor sect seat · in Cô Vụ Đảo · held by Lạc Hà Tông │
│        [ the seat's painting ]            │  place catalogue art, else the first place with art; hidden if none
│ Population  Development  Access   Main good│
│ 3.4 / 4.1   7            50 %     Common herbs │  each with a tooltip naming its formula
│ [Overview][Places][Economy][Works][Modifiers] │
│ …tab body (scrolls)…                      │
└───────────────────────────────────────────┘
```

## Tabs

- **Overview:** the province's lore; its land mix (biome shares), tiles and height range; river and coast; the local
  lord (a minor sect seated here), if any.
- **Places:** every place in the province: existing places (a line that opens that place's panel), new places marked
  *new*, a proposed minor sect marked *proposed sect*.
- **Economy:** settlement: production a season per good, with what came from the neighbouring wilds as its own figure;
  the secondary goods; infrastructure against usage, and the old roads and porters line. Wilderness: its own output
  and the share passed to each gathering neighbour (F2).
- **Works:** buildings standing / slots, each building with five level pips; the empty slots; road and river tiles.
- **Modifiers:** one line per modifier with its source; "No modifiers ..." when none.

## On the map (built alongside the panel)

- **Province names:** each province's name is drawn in small ink capitals at its innermost tile. They fade in from 6
  to 9 px per tile and out by 24 px, where the place labels take over (`province_names_px`, `province_name_font`).
- **Hover:** at region zoom, hovering open land names the province.
- **The new places:** from 14 px per tile, settlements and mines show with their symbol and other places as small ink
  diamonds, with names from 22 px. Hovering one gives its name, gloss and kind.
- **Map modes** (open question 4, built for review): **Development** tints provinces from pale to deep red, and
  **Goods** by main good (herbs green, ore slate, beast parts brown, specialties violet; wilderness paler). Both sit in
  the Z4 bar beside Terrain and replace the political tint while on.
- **Picture fallback:** a province with no painted place shows its own piece of the painted map: a 20 × 11 tile
  region of the 3× tile (`province_art_tiles`).

## Opening and closing

- A left click on open land (no place, no bubble under the cursor) opens the province there. The map's tile index
  (`assets/map/continent_11_province_ids.bin`) answers which province.
- `Esc` or × closes it; focus returns to the map. It closes the place and Places panels when it opens (one Z6 panel at a
  time).
- Gamepad and keyboard: owed. The panel's tabs take focus, but no button opens the province under the map cursor yet.

## Accessibility

- Every number has a tooltip, so none is colour alone.
- The text goes through `tr()`.
- There is no motion, so nothing depends on reduced motion.

## Open questions for the user

1. **Development:** EU-style, should it be a real stat? The draft uses a display index: built levels plus population
   units.
2. **Population units:** the draft shows the GDD's settlement units (3.4). Should it show people instead, for example
   1 unit = 1,000 mortals?
3. **Local price per good:** should it go in Economy once Regional Economy & Trade writes it? (Rule 3; not in the data
   yet.)
4. **Province map modes:** Development and Goods are built for review. Keep them, add Access, or change the colours?
