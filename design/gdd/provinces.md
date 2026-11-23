# Provinces (Tỉnh / Châu)

> **Status**: In Design
> **Author**: user + Claude (/design-system)
> **Last Updated**: 2026-11-23
> **Last Verified**: 2026-11-23
> **Implements Pillar**: Pillar 2 (the numbers are visible) and the fixed, living world (design/gdd/game-concept.md)
> **Creative Director Review (CD-GDD-ALIGN)**: CONCERNS (accepted) 2026-11-23 — anti-pillar scale stated in rule 13;
> Pillar 3 for the player waits on their own ground (Open Question 6); no Player Fantasy at the standard tier

## Summary

The continent's 273 fixed provinces are the economy's smallest unit: each keeps a full record of its resources and main
good, its living mortal population, what it produced, its building slots and buildings, its infrastructure and market
access, and every modifier with its source. Regional Economy & Trade reads them Victoria 3 style: one price per
great-sect market, a local price only where access is below 100 %, so roads and works become the levers that move
prices, and the player reads every reason in the province panel.

> **Quick reference** — Layer: `Foundation` (for the economy) · Priority: `MVP` · Key deps: `Travel & Map, Sects & Missions, Regional Economy & Trade`

## Overview

The continent is divided into **provinces**: 273 pieces of land, each the country around one settlement or a stretch of
empty wilderness. They are generated from the authored map, so they are the same every game
(`tools/design/map/provinces.py`). Each province lies inside one region, and therefore belongs to that region's great
sect. It is the smallest unit the world's economy keeps books for.

Every province is a full record:
- **Its resources:** what its land, mines, herb grounds and lairs can yield.
- **Its mortal population:** the people who live and work there.
- **Its production:** what it actually made this season.
- **Its buildings and works:** fields, worked mines, roads, caravan posts and gathering arrays.
- **Its infrastructure and market access:** how well it reaches its sect's market.
- **Its modifiers:** works, scars, events and policy, each shown as its own line.

A wilderness province has land and resources but no people; its yield is gathered by the settlement provinces next to
it.

Regional Economy & Trade reads provinces in the manner of Victoria 3. Each great sect's territory is one market with one
price per good. A province with full market access buys and sells at that price. A remote or under-built province trades
at a local price that drifts toward its own surplus or shortage. So a famine in a poorly connected valley is felt there
first, and a road built to it brings the valley back to the market price.

**What the player sees and does:**
- **On the map:** provinces show as faint borders when zoomed in, and each opens its own panel.
- **In a province's panel:** what it makes and needs, its access and why, its prices, and every bonus with its source
  (Pillar 2).
- **What the player can do:** carry goods from a glut to a shortage, and later fund or build the works that raise a
  province's output or its access.

Without provinces the economy can only see 20 regions, and the land's variety never reaches a price.

## Detailed Design

### Core Rules

**What a province is**

1. **Fixed provinces.** The continent has 273 provinces, generated from the authored map and the same every game
   (`assets/map/continent_11_provinces.json`). The game asset ships a tile-to-province index (today only in
   `design/map/continent-11/provinces/province_ids.png`; to be added to the asset). Each province lies inside one
   region, and every place belongs to the province its tile is in.
   - A **settlement province** grows from one seat: a village, market, town, city or sect seat (141).
   - A **wilderness province** has no settlement (132).
2. **Holder.** A province belongs to its region's great sect, because a region is held whole (Sects rule 3). A minor
   sect whose seat lies in a province is that province's **local lord**: it builds there and draws its income from it,
   inside the great sect's territory. War moves regions, and their provinces move with them.

**The record**

3. **A province is a full record**, shown in its panel:
   - **Land:** tiles, biome mix, features and qi, read from the map.
   - **Resources** (rule 4).
   - **Mortal population** (rule 5).
   - **Production** (rule 6).
   - **Buildings and works** (rules 7–10).
   - **Infrastructure, usage and market access** (rule 11).
   - **Modifiers** (rule 12).
   - **Local price** per good, written by Regional Economy & Trade.

   A wilderness province has land, resources and buildings, and no people.

**Resources**

4. **Derived, with a named main good** (user decision 2026-11-23). A province's **potential** per good class is the sum
   of three things:
   - what its places can yield: sites' base output and its settlements' fields and diggings (Travel & Map rules 20–21);
   - for a settlement province, its share of the neighbouring wilderness;
   - what its buildings add.

   Its **main good** is the class with the largest potential value, and up to two **secondary goods** follow if each is
   at least `secondary_share` of the main. The goods are fixed at world generation and shown as icons on the map and
   panel, like Paradox's trade goods. A data table may override a province's goods by hand. Potential is what the land
   can give; production is what it gives this season.

**Mortal population**

5. **Living, and slow** (user decision 2026-11-23).
   - **Start:** a settlement province begins with the mortal population of its settlements (size weight × livability,
     Travel & Map rule 21).
   - **Wilderness** has none.
   - **Growth:** once a year, population moves toward the province's **capacity** (its livability and its fields and
     granaries). It grows while the province is fed (its staple goods, herbs and beast parts, are not short) and safe.
   - **Decline:** it falls with famine (staple cover below `famine_cover`), war touching it, or a beast tide.
   - **Who counts:** mortals only. Cultivators are people records, counted by the Living World Tick.
   - **Effects:** population sets the workforce for settlement output and buildings, and the province's settlement
     demand (Regional Economy & Trade Formula C's `W_set`).

**Production**

6. **What it made this season** is the sum of three parts, times its production modifiers (rule 12) per good kind:
   - its places' output (Travel & Map Formulas H, H2);
   - for a settlement province, its share of each neighbouring wilderness province's output, divided by shared border
     length (user decision 2026-11-23);
   - its buildings' output.

   The production contract (Travel & Map rule 25) publishes production, potential, population and access **per
   province** to Regional Economy & Trade.

**Buildings and works**

7. **Slots** (user decision 2026-11-23: province building slots). A settlement province has building slots by its seat:
   village 2, market 3, town 3, minor seat 4, city 5, great seat 6. It gains one more per `slot_pop_step` of
   population. A wilderness province has `wild_slots` (1) for an outpost: a mine works, a hunting camp or a herb garden,
   worked from its neighbours.
8. **Building kinds** are data, each with levels 1–5, a cost in linh thạch and materials, build seasons, upkeep and
   effects:
   - **Production:** spirit fields (herbs), mine works (ore), hunting lodge (beast parts), workshop (crafted goods).
   - **Logistics:** road, caravan post, river or harbour landing (needs a river or coast), storehouse (more stock kept,
     less spoilage).
   - **Society:** market hall (the shop's depth and margin), granary (population capacity, famine resistance), warding
     wall (raids and beast tides).
   - **Cultivation:** gathering array (layer-2 density at the province's seat, Travel & Map rule 31).
   - **Great projects** (`design/world/great_projects_proposal.md`): staged, 2–5 stages, one slot.

   **Province buildings are the shared works** (Travel & Map rule 31's layer 2) for the places in the province, so
   there is one catalogue, not two. Permanent and upkept kinds keep that rule's meaning.
9. **Who builds.**
   - **The holding great sect** builds province buildings the way layer-2 works are built today (Travel & Map rule 31:
     seasons and linh thạch, upkeep as `works_due` in Sects Formula F3). Its track levels stay sect-wide levels (Sects
     rule 8) and **cap** the level of each building kind: Holdings caps production buildings (as it already gates
     works, Sects Formula F2), Trade caps logistics and market halls, Military caps warding walls, Institutions caps
     gathering arrays and pavilions (user decision 2026-11-23). It picks provinces by expected return.
   - **A local lord** (minor sect) builds in its seat province.
   - **The player** funds a building through a sect or city mission now, and builds on their own ground later (as
     decided for great projects, 2026-11-23).
   - Nobody builds in a province of a sect at war with them.
10. **Starting buildings.** Settlement provinces start developed (Travel & Map rule 33): a set of buildings by seat
    kind, authored with the map. A great seat starts with the most, a village with a field and a road. Where land and
    starting buildings leave a province below access `start_access_min`, it gets **old roads and porters**
    (`infra_old`, Formula F6): a flat infrastructure top-up fixed at world generation, part of the land, shown as its
    own line in the panel, using no slot and never ruined (user decision 2026-11-23).

**Infrastructure and market access**

11. **Victoria 3's rule** (user decision 2026-11-23):
    - **Infrastructure:** a province's infrastructure comes from its land (road tiles, a navigable river, a coast with a
      landing) and its logistics buildings.
    - **Usage:** the base value of goods it ships to its market.
    - **Access** = infrastructure ÷ usage, at most 1.

    At access 1 the province trades at its market's price. Below 1, only that share of its output reaches the market,
    and its local price drifts toward its own balance (Regional Economy & Trade, revised Formulas A and L1). A big
    producer with few roads is under-connected, so building a road raises its access.

**Modifiers**

12. **Province modifiers** are plain numbers on province stats, in the Modifier System's grammar (increased or more
    percentages, or flat amounts, scoped by tag). The stats include production per good kind, infrastructure,
    population growth and capacity, upkeep, demand and spoilage.
    - Each modifier has a **source** (a building, a blessed land, a scar, an event such as a blight, a sect policy, a
      war) and a duration. It is shown as its own line in the panel (Pillar 2).
    - Anything with a rule beyond a number is an Effect (Effects System).

**The season**

13. **Order inside the world tick:** the province step runs at the end of S6 (Living World Tick), after Travel & Map's
    season update and before Regional Economy & Trade (S7), so after the Sects tick (S5):
    1. buildings advance (construction, upkeep paid or missed);
    2. population updates (once a year, at the first season);
    3. production;
    4. infrastructure, usage and access;
    5. the contract is published.

    A province reads only values written earlier in the tick. It is one abstract step per province, at the scale the
    anti-pillar allows (per region or per place): there is no per-tile, per-person or per-item trade simulation.
14. **The player** sees every province's record and prices (the map's Province panel and a province map mode). They can
    carry goods between provinces and fund buildings. They cannot build in a province they do not hold, cannot move its
    population, and cannot change its goods.

### States and Transitions

| Thing | States | Moves |
|---|---|---|
| Building | Planned → Under construction → Active; Active → Unpaid (upkeep missed: its effect stops, a permanent work keeps its gains) → Active (paid again) or Ruined (`ruin_seasons` unpaid, or destroyed by war or a beast tide) → Under construction (repair) | Built by its holder; one level at a time |
| Population | Growing (fed, safe, below capacity) · Stable (at capacity) · Declining (famine, war, beast tide) | Checked once a year |
| Province | Normal · Under-connected (access below `strained_access`) · Struck (an event modifier active: blight, raid, tide) · War-touched | Each season, from its record; several may hold at once |

### Interactions with Other Systems

| System | In | Out |
|---|---|---|
| Travel & Map (#25) | Tiles, places, sites and their outputs, livability, roads, rivers, coasts, layers | Production contract per province; province buildings as layer-2 works |
| Regional Economy & Trade (#43) | Local price per good | Production, potential, population, access per province |
| Sects & Missions (#26) | Holder, local lord, track levels (building caps), treasury, war state | Building results, province income base |
| Living World Tick (#28) | The season order | Population changes, struck states for news |
| Event Engine (#23) | Shocks (blight, raid, tide) as province modifiers | Famine, under-connection and completed works as event hooks |
| Modifier System, Effects System | The grammar for province modifiers | — |
| Game UI | — | Province panel, province map mode, province borders |

## Formulas

Every number marked *(guess)* is a starting value for the balance pass, measured on seed 7 where noted
(`prototypes/province-economy/measure_access.py`).

### F1. Potential and the main good (rule 4)

The potential formula is defined as:

`pot[v,k] = Σ_{p ∈ v} base[p,k] + Σ_{w ∈ wild nb(v)} share[w,v] · pot[w,k] + Σ_{b ∈ v} out[b,k]` ·
`main[v] = argmax_k pot[v,k] · val[k]` · `secondary = the next two classes with pot · val ≥ secondary_share · main value`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base[p,k] | float | ≥ 0 | Travel & Map H, H2 at reserve 1 and demand factor 1 | What place p can yield of class k a season |
| share[w,v] | float | 0–1 | F2 | Settlement province v's share of wilderness province w |
| out[b,k] | float | ≥ 0 | building data | A building's output at its level |
| val[k] | float | > 0 | Item Database base value | Value of a unit of class k |
| secondary_share | float | 0.35 | data file *(guess)* | How large a second good must be to be named |

**Output Range:** ≥ 0. A province with nothing yields no main good: its panel says "no goods to speak of" and the map
shows no icon.
**Example:** herbs 900, ore 300, beast parts 400 (equal value): main herbs; beast parts are named (0.44 of 900 ≥ 0.35),
ore is not (0.33).

### F2. Wilderness share (rule 6)

The wild_share formula is defined as:

`share[w,v] = border[w,v] / Σ_{v' ∈ settle nb(w)} border[w,v']`. A wilderness province with no settlement neighbour
passes its whole output to its wilderness neighbours by the same rule, up to `wild_hops` steps; what is still unplaced
after that is not gathered.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| border[w,v] | int | ≥ 1 | provinces data | Tiles of border between the two |
| wild_hops | int | 6 | data file | How far wild output travels to find gatherers |

**Output Range:** the shares of one wilderness province sum to 1 (or 0 past `wild_hops`).
**Example:** a forest borders a town on 30 tiles and a village on 10: the town gathers 0.75 of it, the village 0.25.

### F3. Mortal population (rule 5), once a year

The population formula is defined as:

`P0[v] = Σ_{s ∈ settlements of v} P_set[s]` · `C[v] = P0 · (1 + cap0 + Σ cap_b)` ·
fed and safe: `P' = P + g · P · (1 − P / C)` · famine: `P' = P · (1 − f_fam · (1 − cover_st / famine_cover))` ·
war touching it: `P' ×= (1 − f_war)` · then `P' = clamp(P', pop_floor · P0, max(C, P · (1 − f_fam)))` (a fallen
capacity lowers population by at most `f_fam` a year)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_set[s] | float | ≥ 0 | Travel & Map H2 (size weight × livability) | A settlement's mortal population, in settlement-weight units |
| cap0 | float | 0.2 | data file *(guess)* | Room to grow at the start, so provinces grow a little in peace |
| cap_b | float | 0.05 per level (granary), 0.03 per level (spirit fields) | building data *(guess)* | Capacity from buildings |
| g | float | 0.03 | data file *(guess)* | Growth a year toward capacity (about 1 % at three quarters full) |
| cover_st | float | ≥ 0 | Regional Economy & Trade E: last year's mean cover of herbs and beast parts at the province's local price | How fed it was |
| famine_cover | float | 0.6 | data file *(guess)* | Below this the province starves |
| f_fam | float | 0.2 | data file *(guess)* | Loss a year at total famine |
| f_war | float | 0.05 | data file *(guess)* | Loss a year while war touches it |
| pop_floor | float | 0.3 | data file *(guess)* | A province never empties |

**Output Range:** `pop_floor · P0` to `C`. It never grows past capacity, so growth comes from buildings, not time
alone.
**Example:** P0 10, P 10, C 12, fed: +0.03 · 10 · (1 − 10/12) = **+0.05 a year**; a famine at cover 0.3:
−0.2 · 0.5 = **−10 %**.

### F4. Production (rule 6)

The province_production formula is defined as:

`prod[v,k] = (Σ_{p ∈ v} out_H[p,k] + Σ_w share[w,v] · prod_wild[w,k] + Σ_b out[b,k] · staff[b]) · (1 + Σ inc[v,k]) ·
Π (1 + more[v,k])`, clamped at 0 · `staff[b] = min(1, P / (staff_lvl · level_b))` (a wilderness outpost uses the staff of
the province that gathers it)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| out_H[p,k] | float | ≥ 0 | Travel & Map H, H2 (this season: reserve, workforce, demand, scar) | Place output |
| inc, more | float | about −0.8 to +1 | province modifiers (rule 12) | Increased (summed) and more (multiplied) production by kind |
| staff_lvl | float | 1.0 population unit per level | data file *(guess)* | People a building level needs to run fully |

**Output Range:** ≥ 0, no upper bound (a giant mine is a giant). A blight (inc −0.7 on herbs) cuts that province's
herbs to 30 %.
**Example:** places 400 herbs, a forest's share 150, spirit fields level 2 at 120 with full staff:
(400 + 150 + 120) · (1 − 0.7) = **201** during the blight.

### F5. Slots (rule 7)

The slots formula is defined as:

`slots[v] = base_slots[seat] + floor(P / slot_pop_step)` (settlement) · `slots[w] = wild_slots` (wilderness)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_slots | int | village 2, market 3, town 3, minor seat 4, city 5, great seat 6 | data file (rule 7) | By seat kind |
| slot_pop_step | float | 8 population units | data file *(guess)* | A big city (P about 16) gets 2 more |
| wild_slots | int | 1 | data file | One outpost in the wilderness |

**Output Range:** 1 to about 9. Slots never fall below the buildings standing: a shrinking province keeps its
buildings and builds no new ones.

### F6. Infrastructure, usage and market access (rule 11)

The market_access formula is defined as:

`infra[v] = infra0[seat] + i_road · road[v] + i_river · min(river[v], river_cap) + infra_old[v] + Σ_b infra[b]` ·
`infra_old[v] = max(0, start_access_min · usage_0[v] − (infra0 + i_road · road + i_river · min(river, river_cap) + Σ_b infra[b])_0)`
(fixed at world generation) ·
`usage[v] = Σ_k max(0, prod[v,k] − D_loc[v,k]) · val[k] · P[m,k]` · `acc[v] = 1 if usage ≤ infra, else infra / usage`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| infra0 | float | village 100, market 200, town 200, minor seat 300, city 400, great seat 600 | data file *(guess)* | Trails and porters every settlement has |
| road[v] | int | 0–67 (median 13, seed 7) | map (ROAD tiles in the province) | Built roads on the land |
| i_road | float | 40 per road tile | data file *(guess)* | A median province (13 roads: 520) carries its median 470 of output |
| river[v], river_cap | int | 0–63 (median 6); 20 | map (river tiles) | A navigable river carries goods cheaply, up to a cap |
| i_river | float | 25 per river tile | data file *(guess)* | Up to 500 from a river |
| infra[b] | float | road +200 per level, caravan post +400, landing +500 (needs a river or coast) | building data *(guess)* | Logistics buildings |
| D_loc[v,k] | float | ≥ 0 | Regional Economy & Trade C (the province's own demand) | What it eats itself is not shipped |
| P[m,k] | float | 0.5–3 | Regional Economy & Trade E (last season) | Shipped value at market prices |
| start_access_min | float | 0.5 | data file *(guess)* | No province starts below this (rule 10) |
| infra_old[v], usage_0[v] | float | ≥ 0 | calculated once at world generation | Old roads and porters: the flat top-up that lifts a province to `start_access_min` against its starting usage; part of the land, uses no slot, cannot be ruined (rule 10) |

**Output Range:** 0 to 1. Zero usage gives 1. A province with output but no way to carry it would get 0, but `infra0`
is never 0, so every settlement province ships something.
**Measured (seed 7, `measure_access.py`; usage taken as the whole production value, the worst case):** the median
settlement province makes 470 and has 13 road tiles: infrastructure 100 + 520 = 620, **access 1**. From land alone, 105
of 141 settlement provinces reach access 1 and 122 reach 0.5. The largest producer (province 11, a minor seat: 15,161
of output, 11 road tiles, no river or coast) has 300 + 440 = 740 from its land, and even road 5 + caravan post 5
(+3,000) reaches only 3,740: **access 0.25**. Six seat provinces (ids 11, 10, 9, 5, 4, 2) cannot reach 0.5 with
buildings alone (best 0.25–0.49).
**Start:** so the start floor is met by `infra_old`, a flat top-up on the land (user decision 2026-11-23), not by
buildings: those six start at exactly 0.5, and their holders' roads, posts and landings lift them toward 0.7–0.9. Every
other province gets `infra_old` 0.

### Feedback loops

- **Growth loop:** population → slots (F5) → buildings → capacity (F3's `cap_b`) → population. Intended (a province
  develops); damped by F3's logistic term, `slot_pop_step`, and every building's linh thạch cost, upkeep and staff.
- **Access loop:** access → shipped goods → the holder's income → roads and posts → access. Intended (roads pay);
  damped by building costs and slots, the track caps (rule 9), and usage rising with output, so a growing producer
  needs ever more infrastructure for the same access.

## Edge Cases

- **If a province has no places and no wilderness feeding it** (a 7-tile islet): potential and production are 0, it has
  no main good, and it still shows on the map with its land.
- **If a wilderness province finds no settlement province within `wild_hops`** (an island chain with no village): its
  output is **ungathered**. It reaches no market, and its panel says so. A settlement founded nearby later gathers it
  from the next season.
- **If a settlement province has population 0** (its settlements' livability is 0): its buildings run at staff 0 and
  produce nothing, and its slots are its base slots. Its places' own sites still produce, since a mine is worked by its
  holder (Travel & Map rule 21).
- **If capacity C is 0** (P0 0, a settlement whose livability is 0): population stays 0 and no growth term is computed
  (no 0/0).
- **If population is at `pop_floor` and the famine goes on:** it stays at the floor. The province never empties.
- **If capacity falls below the population** (a granary ruined): population falls toward the new capacity by at most
  `f_fam` a year, never all at once.
- **If usage is 0:** access is 1.
- **If infrastructure is far above usage:** access is 1. There is no bonus above 1.
- **If population falls below what the standing buildings need for slots:** the buildings stay, nothing new can be
  built, and staff falls with population (F4's `staff`).
- **If a region changes holder (war):** its provinces' buildings stay with the land, and the new holder pays their
  upkeep from the next season. Buildings the old holder had under construction stop: what was paid is lost and the
  plan is cancelled. A minor sect that was local lord follows Sects' rules for vassals of a conquered region.
- **If the player has funded a building and the province then changes holder:** the building is finished for the new
  holder, and the player's mission counts as done. The land keeps what was built.
- **If two classes tie for the main good:** the one first in class order wins (herb, ore, beast, special; a raw kind's
  bands low to high).
- **If a blight strikes a wilderness province:** its output falls, and so does every settlement province's share of it.
- **If a gathering array would push a place past Travel & Map's layer-2 cap:** the cap holds, and the building's extra
  levels add nothing to that place. The panel shows the cap.
- **If two modifiers act on one stat:** the Modifier System's grammar applies. Increased values add, more values
  multiply, flats come first.
- **Until Regional Economy & Trade is revised:** the old region contract is still published, as the sum of each
  region's provinces, so nothing that reads regions breaks.

## Dependencies

**Upstream (Provinces reads these)**

| System | Hard or soft | What it gives |
|---|---|---|
| Travel & Map (#25) | Hard | Tiles, biomes, features, qi; places and sites with their outputs (Formulas H, H2); settlements' livability and size weights (rule 21); road, river and coast tiles; layer-2 caps (rule 31) |
| Sects & Missions (#26) | Hard | Region holder (rule 3), minor sects' seats (local lord), track levels as building caps (rule 8, F2), treasury for works and `works_due` (F3), war state |
| Living World Tick (#28) | Hard | The season order the province step runs in (rule 13) |
| World DB (#3) | Hard | Save and load of the province record: buildings, population, modifiers |
| Item Database | Hard | Base value per good class (`val[k]`) |
| Modifier System, Effects System | Hard | The grammar for province modifiers (rule 12) |
| Regional Economy & Trade (#43) | Soft (one season late) | Last season's market price `P[m,k]`, the province's own demand `D_loc`, and staple cover; before the first season, base prices |
| Event Engine (#23) | Soft | Shocks as province modifiers (blight, raid, beast tide) |
| Spirit Herbs (#14) | Soft, through Travel & Map | Herb site outputs by element |

**Downstream (these read Provinces)**

| System | Hard or soft | What it reads |
|---|---|---|
| Regional Economy & Trade (#43) | Hard | Production, potential, population, access per province (the contract, rule 6); until its revision, the region sums (Edge Cases) |
| Sects & Missions (#26) | Soft | Province income base and building results for investment choices; buildings funded by missions |
| Market (#20) | Soft | Market hall level, for the shop's depth and margin |
| Event Engine (#23) | Soft | Famine, under-connection and finished works as event hooks |
| Living World Tick (#28) | Soft | Population changes and struck states, for news |
| Great projects (`design/world/great_projects_proposal.md`) | Soft | A province slot for each staged project |
| Game UI (HUD, map) | Soft | Province panel, province map mode, borders |

**Not a dependency:** Cave Abode (#47). Home works stay on the player's place (Travel & Map rule 32); they are not
province buildings and use no slot.

**Amendments made 2026-11-23** (user: "just finish this"): Travel & Map rules 21, 25, 31, 33 and systems-index row 47;
Regional Economy & Trade rules 3, 6, 7, 11, 16, 20, the units note and Formula A (access = Provinces F6 times the kept
safety term); Sects rule 9; Living World Tick S6. Still open: Event Engine (shocks as province modifiers; no change
needed to its rules yet). The list as it was planned:
- Travel & Map (approved): rule 21 (mortal population is now living, Formula F3 here, not fixed); rule 25 (the
  contract per province); rule 31 (layer-2 shared works become province buildings); rule 33 (starting development
  includes `infra_old`); and systems-index row 47's note that layer-2 works stay in Travel & Map;
- Regional Economy & Trade: rule 1 and Formulas A, C and L1, in the planned revision (A's distance access is replaced
  by F6 here);
- Sects & Missions (approved): rule 9 and Formula F2 (track levels cap province building levels, rule 9 here);
  Formula F3's `works_due` now counts province buildings;
- Living World Tick: the province step at the end of S6, and its share of `T_map`;
- Event Engine: shocks as province modifiers.
- Market (#20) has no GDD; the market hall's effect is set when the shop is designed.

## Cross-References

| Document | What this GDD uses from it | Where |
|---|---|---|
| `travel-map.md` | Formulas H, H2 (place output); rules 20–21 (sites, settlement output and population, size weight × livability); rule 25 (the production contract, now per province); rule 31 (layer-2 works = province buildings; caps); rule 32 (home works stay on the place); rule 33 (developed ground at start) | Rules 4–6, 8, 10; F1, F3, F4 |
| `regional-economy-trade.md` | Rule 1 (one market per great sect); Formula C (`W_set`, province demand `D_loc`); E (price, staple cover); A and L1 (access and local price, to be revised against F6) | Rules 5, 11; F3, F6 |
| `sects.md` | Rule 3 (regions held whole); rule 8 and Formula F2 (track levels; Holdings gates works); Formula F3 (`works_due`, the treasury); vassals of a conquered region | Rules 2, 9; Edge Cases |
| `living-world-tick.md` | Season order (the province step after Sects, before the economy) | Rule 13 |
| `event-engine.md` | Shocks and hooks | Rule 12; Interactions |
| `modifiers.md` | Increased, more and flat grammar; tag scope | Rule 12; Edge Cases |
| `effects.md` | Anything with a rule beyond a number | Rule 12 |
| `item-database.md` | Base value per good class | F1, F6 |
| `spirit-herbs.md` | Herb site outputs by element | Through F4 |
| `world-generation.md` | Places and settlements the provinces are built from | Rule 1 |
| `design/world/great_projects_proposal.md` | Staged projects, 2–5 stages, one slot | Rule 8 |
| `prototypes/province-economy/README.md` | Evidence for the Victoria 3 pick and the seed-7 measurements | F6 |

No GDD yet: World Database (#3) and Market (#20), referenced by system number.

## Acceptance Criteria

`[A]` = automated unit or integration test (`tests/unit/provinces/`), `[S]` = retained screenshot in
`production/qa/evidence/`, `[P]` = playtest.

**Rules**

- **AC-PV-01** `[A]` **GIVEN** the continent loaded, **WHEN** provinces are built, **THEN** there are 273 of them (141
  settlement, 132 wilderness), every land tile has exactly one, and none crosses a region border.
- **AC-PV-02** `[A]` **GIVEN** seeds 7 and 11, **WHEN** both worlds are built, **THEN** province ids, borders and seats
  are identical.
- **AC-PV-03** `[A]` **GIVEN** a region held by sect X with a minor sect seated in province v, **WHEN** the record is
  read, **THEN** v's holder is X and its local lord is that minor sect; **WHEN** the region changes holder by war,
  **THEN** all its provinces change holder that season.
- **AC-PV-04** `[A]` **GIVEN** any province, **WHEN** its record is read, **THEN** it has land, potential per class,
  main good (or none), population, production, buildings, infrastructure, usage, access, modifiers and local prices; a
  wilderness record has population 0.
- **AC-PV-05** `[A]` **GIVEN** a province with a building under construction, **WHEN** a season passes, **THEN**
  construction advances, upkeep is paid or the building goes Unpaid, and after `ruin_seasons` unpaid it is Ruined.
- **AC-PV-06** `[A]` **GIVEN** sect X at war with sect Y, **WHEN** X tries to build in a province held by Y, **THEN** it
  is refused.
- **AC-PV-07** `[A]` **GIVEN** a world freshly built, **WHEN** starting buildings are placed, **THEN** every settlement
  province has its seat kind's set and every province's access is ≥ `start_access_min`; on seed 7 provinces 11, 10, 9,
  5, 4 and 2 have `infra_old` > 0 and start at access 0.5 (±0.001), and every other province has `infra_old` 0.
- **AC-PV-08** `[A]` **GIVEN** the world tick, **WHEN** a season runs, **THEN** the province step runs at the end of S6, after Travel & Map's update and
  before Regional Economy & Trade, and population changes only in the year's first season.
- **AC-PV-09** `[A]` **GIVEN** a province with a blight modifier (herbs inc −0.7, 4 seasons), **WHEN** the panel is
  read, **THEN** the modifier is listed with its source and seasons left, and it is gone after 4 seasons.
- **AC-PV-10** `[A]` **GIVEN** the player not holding province v, **WHEN** they try to build in v, **THEN** it is
  refused; funding a building there through a mission is accepted.

**Formulas**

- **AC-PV-11** `[A]` F1: **GIVEN** potential herbs 900, beast parts 400, ore 300 (equal value), **WHEN** goods are
  named, **THEN** main herbs, secondary beast parts, ore not named; **GIVEN** all potential 0, **THEN** no main good.
- **AC-PV-12** `[A]` F1 tie: **GIVEN** herbs and ore equal, **WHEN** named, **THEN** herbs (class order).
- **AC-PV-13** `[A]` F2: **GIVEN** a forest bordering a town on 30 tiles and a village on 10, **WHEN** shares are
  computed, **THEN** 0.75 and 0.25; for every wilderness province the shares sum to 1, or to 0 when ungathered.
- **AC-PV-14** `[A]` F2: **GIVEN** a wilderness province with no settlement province within `wild_hops`, **WHEN** a
  season runs, **THEN** its output reaches no market and its panel shows "ungathered".
- **AC-PV-15** `[A]` F3: **GIVEN** P 10, C 12, fed and safe, **WHEN** the year turns, **THEN** P = 10.05 (±0.001);
  **GIVEN** cover 0.3, **THEN** P falls 10 %; **GIVEN** P at `pop_floor · P0` in famine, **THEN** P stays there;
  **GIVEN** P at C, **THEN** P does not grow.
- **AC-PV-16** `[A]` F4: **GIVEN** places 400 herbs, a wild share of 150 and spirit fields giving 120 at full staff,
  under a blight inc −0.7, **WHEN** production runs, **THEN** herbs are 201; **GIVEN** population 0, **THEN** the fields
  add 0.
- **AC-PV-17** `[A]` F5: **GIVEN** a city with P 16, **WHEN** slots are computed, **THEN** 7; **GIVEN** population
  falling below the buildings standing, **THEN** no building is removed and none can be added.
- **AC-PV-18** `[A]` F6: **GIVEN** a village with 13 road tiles, no river, shipping 470, **WHEN** access is computed,
  **THEN** infrastructure 620 and access 1; **GIVEN** usage 0, **THEN** access 1; **GIVEN** infrastructure 1,240 and
  usage 15,500, **THEN** access 0.08.
- **AC-PV-19** `[A]` F6: **GIVEN** a road level 1 built in a province at access 0.5, **WHEN** the next season runs,
  **THEN** infrastructure rises by 200 and access by 200 / usage.

**Edge cases and cross-system**

- **AC-PV-20** `[A]` **GIVEN** a region whose holder changes with a building half paid, **WHEN** the season runs,
  **THEN** the building is cancelled; **GIVEN** a player-funded building, **THEN** it is finished for the new holder and
  the mission is done.
- **AC-PV-21** `[A]` **GIVEN** the economy not yet revised, **WHEN** Regional Economy & Trade reads the contract,
  **THEN** each region's published values equal the exact sum of its provinces' values (nothing added or lost in the
  aggregation). Drops when the economy revision lands.
- **AC-PV-22** `[A]` integration: **GIVEN** seed 7 after 8 seasons, **WHEN** totals are read, **THEN** goods are
  conserved: production = market supply + local consumption + spoilage + stock change, within 0.1 %.
- **AC-PV-23** `[A]` integration: **GIVEN** a province below access 1 with a staple shortage, **WHEN** the season runs,
  **THEN** its local price is above the market price, and after a road raises its access to 1 its local price equals
  the market price.
- **AC-PV-24** `[A]` performance: **GIVEN** seed 7, **WHEN** the province step runs, **THEN** it takes under 5 ms a
  season on the dev PC (release export), inside S6's `T_map` budget of 20 ms (Living World Tick). *(guess)*
- **AC-PV-25** `[S]` **GIVEN** the map zoomed in past `province_full_fit`, **WHEN** a province is clicked, **THEN** its
  panel opens with every record line from AC-PV-04 and each modifier with its source.
- **AC-PV-26** `[S]` **GIVEN** the province map mode, **WHEN** it is shown, **THEN** each province shows its main good's
  icon and access is readable without colour alone.
- **AC-PV-27** `[P]` **GIVEN** a 20-season playtest, **WHEN** the player looks for a trade, **THEN** they can name at
  least one under-connected province with a price gap worth a trip, from the panel alone.

Rule 14's "cannot change its goods" has no player action to test and has no criterion.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Every *(guess)* number (F3 growth and famine, F5 `slot_pop_step`, F6 infrastructure points, `start_access_min`) needs a balance pass on seed 7 once the province step runs in the engine | Claude, user approves | Regional Economy & Trade revision |
| 2 | Building catalogue: costs, build seasons, upkeep and output per level for each kind in rule 8 (data, not GDD) | Claude, proposal; user | Before the province step is built |
| 3 | Starting buildings per seat kind (rule 10): authored per province or a set by seat kind plus F6's logistics top-up | User | Before the province step is built |
| 4 | Province names: generated from the seat place's name ("X county") or authored for all 273, wilderness included | User | Before the province panel |
| 5 | The season budget for the province step (AC-PV-24's 5 ms inside `T_map` is a guess) | Claude | Regional Economy & Trade revision |
| 6 | Whether the player's own ground (later) can hold province buildings, or only home works (Travel & Map rule 32) | User | When player holdings are designed |
| 7 | Does a struck or famine province raise the event odds for bandits, migration and sect missions (Event Engine hooks named, weights not set) | Claude | Event Engine content pass |
