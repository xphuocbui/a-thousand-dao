# Provinces (Tỉnh / Châu)

> **Status**: Approved 2026-11-23 (lean design-review round 7, no blockers; full rounds 1-4 and lean round 6 revised the same day; F6 imports amendment by user decision included). Earlier: In Review — approved 2026-11-23 (lean design-review round 5), then Formula F6 amended the same day by user
> decision (usage counts goods brought in as well as shipped out); round 6 (lean) NEEDS REVISION, 1 blocker (F6 class
> set), revised the same day; re-review pending
> **Author**: user + Claude (/design-system)
> **Last Updated**: 2026-11-23 (design-review round 6 revisions)
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
at a local price that drifts toward its own surplus or shortage. So a shortage in a poorly connected valley shows there
first, in its local price, and a road built to it brings the valley back to the market price.

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

1. **Fixed provinces.** The continent has 705 provinces, generated from the authored map by
   `tools/design/map/provinces_v2.py` (rivers are barriers, so most rivers run on borders) and the same every game
   (`assets/map/continent_11_provinces.json`, with the tile-to-province index
   `assets/map/continent_11_province_ids.bin`). Each province has a stable key (`prov_<seat key>` or
   `prov_r<region>_<n>`). Each lies inside one region, and every place belongs to the province its tile is in
   (user decision 2026-11-24, provinces-v2).
   - A **settlement province** grows from one seat: a village, market, town, city or sect seat (468).
   - A **wilderness province** has no settlement (237).
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

   The panel (user decisions 2026-11-24): its spec is `design/ux/province-panel.md` (draft). **Development** is a
   display summary (built levels plus population units) that nothing reads. **Population** is shown as people, 1 unit
   = 1,000 mortals (`ui_hud.json` `greybox.mortals_per_unit`); the formulas stay in units. F6's prototype access
   figures were measured on the 273 provinces and are re-measured on the 705 (`measure_access.py`).

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
   province** to Regional Economy & Trade. The value it carries is `value_lt[v,k] = prod[v,k] · val[k]` (quantity times
   base value; Regional Economy & Trade applies `val` once, not again).

**Buildings and works**

7. **Slots** (user decision 2026-11-23: province building slots). A settlement province has building slots by its seat:
   village 2, market 3, town 3, minor seat 4, city 5, great seat 6. It gains one more per `slot_pop_step` of
   population. A wilderness province has `wild_slots` (1) for an outpost: a mine works, a hunting lodge or spirit fields (rule 8's names),
   worked from its neighbours.
8. **Building kinds** are data, each with levels from 1 up and **no highest level** (user decision 2026-11-24): each
   level costs more linh thạch, materials and build seasons than the last (Travel & Map Formula J), so a level is worth
   less per linh thạch the higher it goes, and builders stop when the next level does not pay. Each kind has a cost in
   linh thạch and materials, build seasons, upkeep and effects:
   - **Production:** spirit fields (herbs), mine works (ore), hunting lodge (beast parts), vein dressing (permanent,
     production on every site of the province; user decision 2026-11-24), workshop (a craft-capacity
     effect that Trade Goods reads; it adds no output class to `prod`, F4, OQ 2). A wilderness outpost is one of the
     first three.
   - **Site growth** (user decision 2026-11-24, provinces-v2). A new site starts at grade **minor**, a tenth of small
     (`site_grade_value.minor`). Each level of its province's matching production building (mine works for a mine,
     hunting lodge for a beast lair, spirit fields for a spirit vein or hot spring) above level 1 raises it one grade
     step (minor, small, medium, large), never above the grade its land density gives it (Travel & Map's
     `grade_by_density`).
   - **Logistics:** road, caravan post, river or harbour landing (needs a river or coast), storehouse (more stock kept,
     less spoilage).
   - **Society:** market hall (the shop's depth and margin), granary (population capacity, famine resistance), warding
     wall (raids and beast tides).
   - **Cultivation:** gathering array (upkept), spirit grove (permanent density) and qi channel (permanent push to one
     chosen element, one channel per element), all layer-2 works at the province's seat (Travel & Map rule 31; spirit
     grove and qi channel added by user decision 2026-11-24).
   - **Great projects** (`design/world/great_projects_proposal.md`): staged, 2–5 stages, one slot.
   - **Where a building acts** (user decision 2026-11-24): cultivation buildings act at the province's seat
     settlement. A production building acts on the province's sites of its kind (mine works on mines, hunting lodge on
     beast lairs, spirit fields on spirit veins and hot springs; vein dressing on every site). Logistics and society
     buildings act on the province.

   **Province buildings are the shared works** (Travel & Map rule 31's layer 2) for the places in the province, so
   there is one catalogue, not two. Permanent and upkept kinds keep that rule's meaning, but **unpaid upkeep follows
   this GDD's Unpaid and Ruined states, not Travel & Map Formula J's fade** (owed in Travel & Map, OQ 9). Track levels
   set the price, not a limit (rule 9): a standing building keeps its level if a track later falls.
9. **Who builds.**
   - **The holding great sect** builds province buildings the way layer-2 works are built today (Travel & Map rule 31:
     seasons and linh thạch, upkeep as `works_due` in Sects Formula F3). Its track levels stay sect-wide levels (Sects
     rule 8) and **set the price** of each building kind (user decision 2026-11-24, replacing the caps of 2026-11-23):
     a level up to the matching track's free level (Sects Formula F2) costs the Formula J price, and each level above
     it costs `track_surcharge` (×2) more again. Holdings prices production buildings and granaries, Trade logistics
     buildings and market halls, Military warding walls, and Institutions cultivation buildings and each stage of a
     great project ("pavilions" dropped, 2026-11-24). It picks provinces by expected return.
   - **A local lord** (minor sect) builds in its seat province.
   - **The player** funds a building through a sect or city mission now, and builds on their own ground later (as
     decided for great projects, 2026-11-23).
   - Nobody builds in a province of a sect at war with them.
10. **Starting buildings.** Settlement provinces start developed (Travel & Map rule 33): a set of buildings by seat
    kind, all at level 1 (user decision 2026-11-24, provinces-v2):

    | Seat | Starting buildings |
    |---|---|
    | Village | road |
    | Market | road, market hall |
    | Town | road, market hall, granary |
    | Minor sect seat | road, gathering array, warding wall |
    | City | road ×2, market hall ×2, granary, caravan post |
    | Great sect seat | road ×3, market hall ×2, granary ×2, caravan post ×2, gathering array ×2, warding wall |

    Every settlement province also starts with its main good's production building (spirit fields, mine works or a
    hunting lodge); a town, market or city on a coast or a river (6 river tiles or more) with a landing; a wilderness
    province with a mine, with mine works (its outpost). Where land and
    starting buildings leave a province below access `start_access_min`, it gets **old roads and porters**
    (`infra_old`, Formula F6): a flat infrastructure top-up fixed at world generation, part of the land, shown as its
    own line in the panel, using no slot and never ruined (user decision 2026-11-23).

    Every settlement also keeps **the ground's own works** (Travel & Map Formula M's `prebuilt_density`: village 0.10
    to sect seat 0.40) as part of its land: layer-2 upkept density shown as its own panel line, using no slot, never
    ruined and not billed (user decision 2026-11-24). It is not a building and is not migrated into one.

**Infrastructure and market access**

11. **Victoria 3's rule** (user decision 2026-11-23):
    - **Infrastructure:** a province's infrastructure comes from its land (road tiles, a navigable river, a coast with a
      landing) and its logistics buildings.
    - **Usage:** the load the province puts on its roads, in base value (not the market price), per good: what it
      ships out (production above its own demand `D_loc`) **plus what it must bring in** (its demand above its
      production; user decision 2026-11-23, so a cut-off valley short of food is under-connected and its famine shows
      in its local price, Overview). `D_loc` only sets this load; Regional Economy & Trade B still takes the whole
      output into the market's supply times access.
    - **Access** = infrastructure ÷ usage, at most 1. This value (`acc[v]`, F6; Regional Economy & Trade's `inf_v`) is
      what Provinces publishes. Regional Economy & Trade A multiplies it by its safety term to give its own `acc_v`,
      which B and L1 use.

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

    The rule 6 and F4 stats the contract carries are those of step 3; step 4's access uses them and last season's
    `D_loc`.

    A province reads only values written earlier in the tick. It is one abstract step per province, at the scale the
    anti-pillar allows (per region or per place): there is no per-tile, per-person or per-item trade simulation.
14. **The player** sees every province's record and prices (the map's Province panel and a province map mode). They can
    carry goods between provinces (the player trade of Regional Economy & Trade rule 16) and fund buildings. They cannot build in a province they do not hold, cannot move its
    population, and cannot change its goods.

### States and Transitions

| Thing | States | Moves |
|---|---|---|
| Building | Planned (the holder's accepted order, once slot, cap and funds checks pass) → Under construction (when the first season's cost is paid) → Active; Active level n → Under construction (upgrade; it keeps working at level n) → Active level n+1; Under construction → Cancelled (holder changed by war, or funds stopped: what was paid is lost, and an upgrade falls back to its built level; except a player-funded building, which the new holder finishes, Edge Cases); Active → Unpaid (upkeep missed: its effect stops, a permanent work keeps its gains) → Active (paid again) or Ruined (`ruin_seasons` = 3 *(guess)* seasons unpaid in a row, or destroyed by war or a beast tide) → Under construction (repair) | Built by its holder; one level at a time. Cost is paid evenly over the build seasons; upkeep each season by the holder (the local lord for its own buildings), as `works_due` in the Sects tick (S5); step 1 of rule 13 only advances states |
| Population | Growing (fed, safe, below capacity) · Stable (at capacity) · Declining (famine, war, beast tide) | Checked once a year |
| Province | Normal · Under-connected (access below `strained_access` = 0.7 *(guess)*) · Struck (an event modifier active: blight, raid, tide) · War-touched | Each season, from its record; several may hold at once |

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

`pot[v,k] = Σ_{p ∈ v} base[p,k] + Σ_{w ∈ wild nb(v)} share[w,v] · pot[w,k] + Σ_{b ∈ v} out[b,k]` (where `pot[w,k]` of a
wilderness province includes what reaches it from farther wilderness, by F2's matrix; `out[b,k]` as in F4) ·
`main[v] = argmax_k pot[v,k] · val[k]` if that largest value is above 0, else none (`k` is an Item Database good class) ·
`secondary = the next two classes with pot · val ≥ secondary_share · main value`,
only when the main value is above 0 · `main` and `secondary` are computed once at world generation, with the starting
buildings (rule 4); `pot` itself is live · for a wilderness province `pot[w,k]` = its own `base` and building output plus the
inflow `Σ share[w',w] · pot[w',k]` from wilderness at `d[w]+1` (the same recursion as F4's `prod_wild`, without modifiers)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base[p,k] | float | ≥ 0 | Travel & Map H, H2 at reserve 1 and demand factor 1 | What place p can yield of class k a season |
| share[w,v] | float | 0–1 | F2 | Settlement province v's share of wilderness province w |
| out[b,k] | float | ≥ 0 | building data | A building's output at its level, in Item Database raw classes only (a workshop has none; spirit-stone veins are not a class and stay outside `prod`, usage and access, Regional Economy & Trade I reads them as before), only the part not tied to a site: a production building's gain on its place's site is counted once, through `G_f` inside Travel & Map's Formula H (`out_H`) |
| val[k] | float | > 0 | Item Database base value | Value of a unit of class k |
| secondary_share | float | 0.35 | data file *(guess)* | How large a second good must be to be named |

**Output Range:** ≥ 0. A province with nothing yields no main good: its panel says "no goods to speak of" and the map
shows no icon.
**Example:** herbs 900, ore 300, beast parts 400 (equal value): main herbs; beast parts are named (0.44 of 900 ≥ 0.35),
ore is not (0.33).

### F2. Wilderness share (rule 6)

The wild_share formula is defined as:

`d[w]` = the number of province steps from wilderness province w to the nearest settlement province (breadth-first, 1 =
a settlement neighbour); `share[w,v] = border[w,v] / Σ_{v' ∈ nb(w), d[v'] = d[w]−1} border[w,v']` for each neighbour v
at distance d[w]−1 (a settlement province has d 0). Output only moves toward a settlement, so it cannot cycle. If
`d[w] > wild_hops` the output is not gathered. The matrix is computed once at world generation and does not change when
a region changes holder. A wilderness province's output is counted only in its gatherers' production; its own record
shows it as "passed on" (one hop at a time, each hop's receiver passes it on by its own shares).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| border[w,v] | int | ≥ 1 | provinces data | Tiles of border between the two |
| wild_hops | int | 6 | data file | How far wild output travels to find gatherers |
| d[w] | int | 1–∞ | provinces data, breadth-first | Steps from a wilderness province to the nearest settlement province |

**Output Range:** the shares of one wilderness province sum to 1 over its next-hop neighbours (or 0 past `wild_hops`); the
total reaching settlement provinces equals its output.
**Example:** a forest borders a town on 30 tiles and a village on 10: the town gathers 0.75 of it, the village 0.25.

### F3. Mortal population (rule 5), once a year

The population formula is defined as:

`P0[v] = Σ_{s ∈ settlements of v} P_set[s]` · `C[v] = P0 · (1 + cap0 + Σ cap_b)` ·
**fed** = `cover_st ≥ famine_cover` (fed if neither herbs nor beast parts trade in its market); **safe** = at the
yearly step, its region is not at war in Sects' war state and it has no active tide modifier (both read once, at the
step; no history is kept). Base: fed and safe:
`P' = P + g · P · (1 − P / C)` (0 when C = 0) · not fed (famine): `P' = P · (1 − f_fam · (1 − cover_st / famine_cover))` ·
fed but not safe: `P' = P` · then, if war or a tide touched it: `P' ×= (1 − f_war)` · then
`P' = clamp(P', pop_floor · P0, max(C, P · (1 − f_fam)))`. Above capacity, population falls toward C by `f_fam` of P a
year until it reaches C (so P 20, C 12, fed gives 16); it never grows past C.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P, P0, C | float | ≥ 0 | this formula | Population now, at the start, and capacity (not the market price `P[m,k]`, which no longer appears in Provinces) |
| P_set[s] | float | ≥ 0 | Travel & Map H2 (size weight × livability) | A settlement's mortal population, in settlement-weight units |
| cap0 | float | 0.2 | data file *(guess)* | Room to grow at the start, so provinces grow a little in peace |
| cap_b | float | 0.05 per level (granary), 0.03 per level (spirit fields) | building data *(guess)* | Capacity from buildings |
| g | float | 0.03 | data file *(guess)* | Growth a year toward capacity (about 0.56 % of C at three quarters full, 0.75 % of C at its peak, half full) |
| cover_st | float | ≥ 0 | Regional Economy & Trade E: last season's mean cover `c[m,k]` of herbs and beast parts in the province's market, read at the yearly step (the raw market cover; access does not enter it, see OQ 8) | How fed it was |
| famine_cover | float | 0.6, > 0 | data file *(guess)* | Below this the province starves (a divisor, so never 0) |
| f_fam | float | 0.2 | data file *(guess)* | Loss a year at total famine |
| f_war | float | 0.05 | data file *(guess)* | Loss a year while war or a beast tide touches it (one knob for both) |
| pop_floor | float | 0.3 | data file *(guess)* | A province never empties |

**Output Range:** `pop_floor · P0` up to `max(C, P · (1 − f_fam))`: growth never takes it past capacity, and above
capacity it only falls (by `f_fam` of P a year, whatever the logistic term gives; war adds nothing to an over-full
province, P 20, C 12 gives 16 in peace and in war). So growth comes from buildings, not time alone.
**Example:** P0 10, P 10, C 12, fed: +0.03 · 10 · (1 − 10/12) = **+0.05 a year**; a famine at cover 0.3:
−0.2 · 0.5 = **−10 %**.

### F4. Production (rule 6)

The province_production formula is defined as:

`prod[v,k] = (Σ_{p ∈ v} out_H[p,k] + Σ_w share[w,v] · prod_wild[w,k] + Σ_b out[b,k] · staff[b]) · max(0, 1 + Σ inc[v,k]) ·
Π max(0, 1 + more[v,k])`, clamped at 0 · `staff[b] = min(1, P / (staff_lvl · level_b))`, 0 if `level_b` = 0 · `level_b` is the
**effective level**: the built level while the building is Active, and 0 while it is Planned, Under construction (a
first build or a repair), Unpaid or Ruined. **While an Active building is being upgraded, `level_b` stays at its built
level until the new level turns Active** (an upgrade never lowers infrastructure, capacity or output; a Cancelled upgrade
keeps the built level); a permanent work (Travel & Map rule 31) keeps its gains while Unpaid. `out[b]`, `staff[b]`, `infra[b]`
(F6) and `cap_b` (F3) all read it · a wilderness outpost uses the staff of the settlement province reached by following
the largest `share` hop (lowest province id on a tie) from its wilderness province until a settlement province is met
(staff 0 if none is reached within `wild_hops`) ·
`prod_wild[w,k] = own[w,k] · max(0, 1 + Σ inc[w,k]) · Π max(0, 1 + more[w,k]) + Σ_{w' wild, d[w'] = d[w]+1} share[w',w] ·
prod_wild[w',k]`, evaluated from the largest `d` down, only for `d ≤ wild_hops`; `own[w,k]` is the wilderness
province's own output (its places and outpost). A wilderness province adds nothing to region sums on its own: its
output is counted only in its gatherers' `prod`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| out_H[p,k] | float | ≥ 0 | Travel & Map H, H2 (this season: reserve, workforce, demand, scar) | Place output |
| inc, more | float | about −0.8 to +1 | province modifiers (rule 12) | Increased (summed) and more (multiplied) production by kind |
| staff_lvl | float | 1.0 population unit per level, > 0 (a divisor) | data file *(guess)* | People a building level needs to run fully |
| level_b | int | 0 and up (no highest level, rule 8) | building state | A building's effective level (0 while a first build or repair is under construction, or while Unpaid or Ruined; the built level during an upgrade) |
| own[w,k] | float | ≥ 0 | places and outposts of wilderness province w | Its own output, before its own modifiers and before what reaches it from farther wilderness |
| prod_wild[w,k] | float | ≥ 0 | this formula | What w passes on: its own output with w's own modifiers (a blight on w cuts only its own output, not what passes through), plus what reaches it from farther wilderness; the gatherer's modifiers apply to the share on arrival |

**Output Range:** ≥ 0, no upper bound (a giant mine is a giant). A blight (inc −0.7 on herbs) cuts that province's
herbs to 30 %.
**Example:** places 400 herbs, a forest's share 150, spirit fields level 2 at 120 with full staff:
(400 + 150 + 120) · (1 − 0.7) = **201** during the blight.

### F5. Slots (rule 7)

The slots formula is defined as:

`slots[v] = max(base_slots[seat] + floor(P / slot_pop_step), buildings standing)` (settlement; `seat` = the settlement the
province grows from, rule 1, which also sets `infra0`) · `slots[w] = wild_slots` (wilderness)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_slots | int | village 2, market 3, town 3, minor seat 4, city 5, great seat 6 | data file (rule 7) | By seat kind |
| slot_pop_step | float | 8 population units | data file *(guess)* | A big city (P about 16) gets 2 more |
| wild_slots | int | 1 | data file | One outpost in the wilderness |

**Output Range:** wilderness 1; settlement from its base (2 for a village) upward in steps of 1 per `slot_pop_step`,
with no cap. "Buildings standing" counts every building in any state except Cancelled (Planned, Under construction,
Active, Unpaid, Ruined all occupy a slot). Slots never fall below the buildings standing: a shrinking province keeps
its buildings and builds no new ones.

### F6. Infrastructure, usage and market access (rule 11)

The market_access formula is defined as:

`infra[v] = infra0[seat] + i_road · road[v] + i_river · min(river[v], river_cap) + infra_old[v] + Σ_b infra[b]` ·
`infra_old[v] = max(0, start_access_min · usage_0[v] − (infra0 + i_road · road + i_river · min(river, river_cap) + Σ_b infra[b])_0)`
(fixed at world generation) ·
`usage[v] = Σ_k |prod[v,k] · val[k] − D_loc[v,k]|` (`k` runs over the raw classes only, as Regional Economy & Trade's `D_loc` and L1 do; crafted classes are not in usage, since Provinces make none; goods shipped out plus goods brought in, user decision
2026-11-23; base value, no market price: rule 11; `prod` and `D_loc` are the
values the step has when it runs, `D_loc` last season's and 0 before the first economy tick, in base value like Regional Economy & Trade L1's `D_r`; `D_loc` lowers the load only, it does not remove goods from what RET B takes in) · `acc[v] = 1 if usage ≤ infra, else infra / usage` · a
wilderness province has no infrastructure and no access (its output is gathered, F2)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| infra0 | float | village 100, market 200, town 200, minor seat 300, city 400, great seat 600 | data file *(guess)* | Trails and porters every settlement has |
| road[v] | int | 0–67 (median 13, seed 7) | map (ROAD tiles in the province) | Built roads on the land |
| i_road | float | 40 per road tile | data file *(guess)* | A median province (13 roads: 520) carries its median 470 of output |
| river[v], river_cap | int | 0–63 (median 6); 20 | map (river tiles) | A navigable river carries goods cheaply, up to a cap |
| i_river | float | 25 per river tile | data file *(guess)* | Up to 500 from a river |
| infra[b] | float | road +200 per level, caravan post +400 per level, landing +500 per level (needs a river or coast); read at the effective `level_b` (F4) | building data *(guess)* | Logistics buildings |
| D_loc[v,k] | float | ≥ 0 | Regional Economy & Trade C and L1 (the province's own demand, last season's value, in base value) | What it eats itself is not shipped |
| start_access_min | float | 0.5 | data file *(guess)* | No province starts below this (rule 10) |
| infra_old[v], usage_0[v] | float | ≥ 0 | calculated once at world generation | Old roads and porters: the flat top-up that lifts a province to `start_access_min` against its starting usage; part of the land, uses no slot, cannot be ruined (rule 10). `usage_0` is `usage` at world generation with `D_loc` = 0 (the whole production value, as measured below) |

**Imports example:** a valley makes no herbs but needs 2,000 (base value) and is balanced in every other class: usage
2,000; with infrastructure 1,000, access **0.5**, so its herb price rises above the market price until a road lifts its
infrastructure to 2,000.
**Output Range:** 0 to 1. Zero usage gives 1. A province with output but no way to carry it would get 0, but `infra0`
is never 0, so every settlement province ships something.
**Measured (seed 7, `measure_access.py`; usage taken as the whole production value, i.e. `D_loc` 0 and no imports, the start state; once imports count, usage can exceed this for a province short of goods, so the script needs a re-measure, OQ 1):** the median
settlement province makes 470 and has 13 road tiles: infrastructure 100 + 520 = 620, **access 1**. From land alone, 105
of 141 settlement provinces reach access 1 and 122 reach 0.5. The largest producer (province 11, a minor seat: 15,161
of output, 11 road tiles, no river or coast) has 300 + 440 = 740 from its land, and even road 5 + caravan post 5
(+3,000) reaches only 3,740: **access 0.25**. Six seat provinces (ids 11, 10, 9, 5, 4, 2) cannot reach 0.5 with
buildings alone (best 0.25–0.49).
**Start:** `start_access_min` holds at world generation, before any modifier. The floor is met by `infra_old`, a flat top-up on the land (user decision 2026-11-23), not by
buildings: those six start at exactly 0.5, and their holders' roads, posts and landings lift them toward 0.7–0.9. Every
other province gets `infra_old` 0.

### Feedback loops

- **Growth loop:** population → slots (F5) → buildings → capacity (F3's `cap_b`) → population. Intended (a province
  develops); damped by F3's logistic term, `slot_pop_step`, and every building's linh thạch cost, upkeep and staff.
- **Access loop:** access → shipped goods → the holder's income → roads and posts → access. Intended (roads pay);
  damped by building costs and slots, the track caps (rule 9), and usage rising with output, so a growing producer
  needs ever more infrastructure for the same access. It also runs downward: low access, less income, unpaid roads,
  lower access (`ruin_seasons` bounds it). The six `infra_old` provinces are the trap case.

## Edge Cases

- **If a province has no places and no wilderness feeding it** (a 7-tile islet): potential and production are 0, it has
  no main good, and it still shows on the map with its land.
- **If a wilderness province finds no settlement province within `wild_hops`** (an island chain with no village): its
  output is **ungathered**. It reaches no market, and its panel says so (it is outside the conservation sum, AC-PV-22).
- **If a settlement province has population 0** (its settlements' livability is 0): its buildings run at staff 0 and
  produce nothing, and its slots are its base slots. Its places' own sites still produce, since a mine is worked by its
  holder (Travel & Map rule 21).
- **If capacity C is 0** (P0 0, a settlement whose livability is 0): population stays 0 and no growth term is computed
  (no 0/0).
- **If population is at `pop_floor` and the famine goes on:** it stays at the floor. The province never empties.
- **If capacity falls below the population** (a granary ruined): population falls toward the new capacity by `f_fam` of P a
  year (F3), never all at once.
- **If a poorly connected province is short of a good** (it brings goods in): usage counts the shortfall, so its access
  falls below 1 and its local price for that good rises above the market price even in peace (F6, AC-PV-18b); a road
  that lifts infrastructure to usage brings it back to the market price.
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
- **If a blight strikes a wilderness province:** its own output falls (F4's `prod_wild` applies its modifiers to its
  own output, not to what passes through it), and so does every settlement province's share of it.
- **If a gathering array would push a place past Travel & Map's layer-2 cap:** the cap holds, and the building's extra
  levels add nothing to that place. The panel shows the cap.
- **If two modifiers act on one stat:** the Modifier System's grammar applies. Increased values add, more values
  multiply, flats come first.
- **While Regional Economy & Trade's Formulas C and L1 still await their amendment (OQ 9):** the old region contract is
  still published, as the sum of each region's provinces, so nothing that reads regions breaks.

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
| Regional Economy & Trade (#43) | Soft (one season late) | Last season's own demand `D_loc` (base value) and the market's staple cover; before the first season, zero demand and full cover (the price itself no longer enters Provinces) |
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
`production/qa/evidence/`, `[P]` = playtest. Each `[A]` test sets every *(guess)* knob it uses (`ruin_seasons`,
`secondary_share`, `g`, `f_fam`, `f_war`, `pop_floor`, `famine_cover`, `base_slots`, `slot_pop_step`, `infra0`,
`i_road`, building `infra[b]`) in its fixture; the numbers below are for those fixture values.

**Rules**

- **AC-PV-01** `[A]` **GIVEN** the continent loaded, **WHEN** provinces are built, **THEN** there are 273 of them (141
  settlement, 132 wilderness), every land tile has exactly one, and none crosses a region border.
- **AC-PV-02** `[A]` **GIVEN** the world built twice with seed 7 and once with seed 11, **WHEN** the three are compared,
  **THEN** province ids, borders and seats are identical.
- **AC-PV-03** `[A]` **GIVEN** a region held by sect X with a minor sect seated in province v, **WHEN** the record is
  read, **THEN** v's holder is X and its local lord is that minor sect; **WHEN** the region changes holder by war,
  **THEN** all its provinces change holder that season.
- **AC-PV-04** `[A]` **GIVEN** a settlement province, **WHEN** its record is read, **THEN** it has land, potential per
  class, main good (or none), population, production, buildings, infrastructure, usage, access, modifiers and local
  prices; **GIVEN** a wilderness province, **THEN** it has land, potential, buildings, modifiers and its output shown as
  "passed on", population 0, and no infrastructure, usage, access or local price.
- **AC-PV-05** `[A]` **GIVEN** a province with a building under construction, **WHEN** a season passes, **THEN**
  construction advances; **GIVEN** an Active building and `ruin_seasons` 3 (fixture), **THEN** upkeep missed in ticks 1
  and 2 gives Unpaid after each, a payment in tick 2 returns it to Active and resets the count, and a miss in ticks
  1, 2 and 3 in a row gives Ruined at tick 3; **WHEN** a Ruined building is repaired, **THEN** it is Under construction;
  **GIVEN** an Active road level 4 ordered to level 5, **THEN** its `infra[b]` stays at level 4's value until level 5
  turns Active, and if the upgrade is Cancelled it stays level 4.
- **AC-PV-06** `[A]` **GIVEN** sect X at war with sect Y, **WHEN** X tries to build in a province held by Y, **THEN** it
  is refused.
- **AC-PV-07** `[A]` **GIVEN** a world freshly built, **WHEN** starting buildings are placed, **THEN** every settlement
  province has its seat kind's set and every settlement province's access, computed with `usage_0`, is ≥
  `start_access_min` − 0.001; **GIVEN** a fixture whose land and starting buildings give access 0.3, **THEN** `infra_old` is
  `0.5 · usage_0 − infra` and access is 0.5 (±0.001), and a province already at 0.5 or more has `infra_old` 0.
  (Seed 7's expected `infra_old` provinces, 11, 10, 9, 5, 4 and 2, are a note until Open Question 3 fixes the
  starting buildings; they are not asserted here.)
- **AC-PV-08** `[A]` **GIVEN** the world tick, **WHEN** a season runs, **THEN** the province step runs at the end of S6, after Travel & Map's update and
  before Regional Economy & Trade, and population changes only in the year's first season.
- **AC-PV-09** `[A]` **GIVEN** a province with a blight modifier (herbs inc −0.7, 4 seasons), **WHEN** the panel is
  read, **THEN** the modifier is listed with its source and seasons left, which read 4, 3, 2, 1 when read after step 5 of four consecutive ticks, and
  it is absent after the fifth tick's step 5.
- **AC-PV-10** `[A]` **GIVEN** the player not holding province v, **WHEN** they try to build in v, **THEN** it is
  refused; funding a building there through a mission is accepted.

**Formulas**

- **AC-PV-11** `[A]` F1: **GIVEN** potential herbs 900, beast parts 400, ore 300 (equal value), **WHEN** goods are
  named, **THEN** main herbs, secondary beast parts, ore not named; **GIVEN** all potential 0, **THEN** no main good.
- **AC-PV-12** `[A]` F1 tie: **GIVEN** herbs and ore with equal `pot · val` (both above 0), **WHEN** named, **THEN** herbs (class order).
- **AC-PV-13** `[A]` F2: **GIVEN** a forest bordering a town on 30 tiles and a village on 10, **WHEN** shares are
  computed, **THEN** 0.75 and 0.25; for every wilderness province the shares sum to 1, or to 0 when ungathered;
  **GIVEN** a wilderness province w two steps from a town through wilderness province u, **THEN** all of w's output
  goes to u, none goes back, and u passes it to the town (no cycle, counted once in the town's production).
- **AC-PV-14** `[A]` F2: **GIVEN** wilderness provinces at d = 6 and d = 7 (`wild_hops` 6), **WHEN** a season runs, **THEN**
  d 6 is gathered and d 7 reaches no market and its panel shows "ungathered"; **GIVEN** a d = 1 forest (output 50)
  bordering one town, and a d = 2 forest (output 100) bordering only that forest, **THEN** the town's wild share is
  150; a blight on the d = 2 forest only (inc −0.7) cuts its own 100 to 30, so the share is 80; **GIVEN** an outpost in
  the d = 2 forest, **THEN** its staff is `min(1, P_town / (staff_lvl · level))` with the town's population (P_town 10, level 2,
  `staff_lvl` 1: staff 1; P_town 1: staff 0.5); **GIVEN**
  an outpost in a wilderness province with no settlement within `wild_hops`, **THEN** its staff is 0.
- **AC-PV-15** `[A]` F3 (P0 = 10 in every case): **GIVEN** P 10, C 12, fed and safe, **WHEN** the year turns, **THEN** P = 10.05 (±0.001);
  **GIVEN** cover 0.3, **THEN** P falls 10 %; **GIVEN** P at `pop_floor · P0` in famine, **THEN** P stays there;
  **GIVEN** P at C, **THEN** P does not grow; **GIVEN** P 20, C 12, fed, **THEN** P = 16 (falls by at most `f_fam`);
  **GIVEN** fed but a war touching the province (P 10, C 12), **THEN** P = 9.5 (no growth when not safe, then × 0.95; ±0.001); **GIVEN** famine and war together (P 10,
  C 12, cover 0.3), **THEN** P = 10 · 0.9 · 0.95 = 8.55 (above the floor 3); **GIVEN** C 0, **THEN** P stays 0 and no
  division happens.
- **AC-PV-16** `[A]` F4: **GIVEN** places 400 herbs, a wild share of 150 and spirit fields giving 120 at full staff,
  under a blight inc −0.7, **WHEN** production runs, **THEN** herbs are 201; **GIVEN** population 0, **THEN** the fields
  add 0; **GIVEN** two blights (inc −0.7 and −0.5) on one province, **THEN** `max(0, 1 + Σ inc)` gives 0 and production
  is 0, never negative (the same on a wilderness province's `prod_wild`); **GIVEN** a building that is Unpaid,
  **THEN** its `out[b]`, `infra[b]` and `cap_b` are 0 (a permanent work keeps its gains), and after it is paid again
  they return.
- **AC-PV-17** `[A]` F5: **GIVEN** a city with P 16, **WHEN** slots are computed, **THEN** 7; **GIVEN** a city with 7
  buildings standing and P 8 (the formula gives 6), **THEN** slots = 7, no building is removed and none can be added.
- **AC-PV-18** `[A]` F6: **GIVEN** a village with 13 road tiles, no river, shipping 470, **WHEN** access is computed,
  **THEN** infrastructure 620 and access 1; **GIVEN** usage 0, **THEN** access 1; **GIVEN** infrastructure 1,240 and
  usage 15,500, **THEN** access 0.08.
- **AC-PV-18b** `[A]` F6, imports (user decision 2026-11-23): **GIVEN** a province with herb production 0, herb
  `D_loc` 2,000, every other class balanced and infrastructure 1,000, **WHEN** access is computed, **THEN** usage 2,000
  and access 0.5; **GIVEN** infrastructure 2,000, **THEN** access 1.
- **AC-PV-19** `[A]` F6: **GIVEN** usage 1,000 and infrastructure 500 (access 0.5), **WHEN** a road level 1 turns Active
  (its last build season completes in step 1 of rule 13), **THEN** that same tick's step 4 gives infrastructure 700 and access 0.7; **GIVEN** infrastructure 900 before the
  road, **THEN** access 1 (capped).
- **AC-PV-28** `[A]` Rule 9: **GIVEN** a sect with Holdings level 2, **WHEN** it orders a level-3 spirit fields,
  **THEN** it is refused; a level-2 order is accepted; the same cap applies to a granary (Holdings) and to a great
  project stage (Institutions).
- **AC-PV-29** `[A]` Rule 11: **GIVEN** peace (safety term 1), `D_loc` 0, `h_f` 1, no shock, F6 access 0.5 and usage
  1,000, **WHEN** the season runs, **THEN** the value reaching the market is 500.
- **AC-PV-30** `[A]` F6/rule 8: **GIVEN** a landing ordered in a province with neither river nor coast, **THEN** it is
  refused; **GIVEN** 30 river tiles with `river_cap` 20, **THEN** the river term counts 20; **GIVEN** a wilderness
  province with an outpost, **THEN** a second building there is refused (`wild_slots` 1).
- **AC-PV-31** `[A]` Rule 9: **GIVEN** a sect with Trade level 2 and Military level 2, **WHEN** it orders a level-3
  road (or market hall) and a level-3 warding wall, **THEN** both are refused; level-2 orders are accepted.

**Edge cases and cross-system**

- **AC-PV-20** `[A]` **GIVEN** a region whose holder changes with a building half paid, **WHEN** the season runs,
  **THEN** the building is cancelled; **GIVEN** a player-funded building, **THEN** it is finished for the new holder and
  the mission is done.
- **AC-PV-21** `[A]` **GIVEN** the economy not yet revised, **WHEN** Regional Economy & Trade reads the contract,
  **THEN** each region's published production, potential and population equal the exact sum of its provinces' values
  (nothing added or lost in the aggregation, within 1e-6 relative; wilderness output is counted only through its
  gatherers; access is a ratio and is not summed). Drops when the economy revision
  lands.
- **AC-PV-22** `[A]` integration: **GIVEN** seed 7 after 8 seasons in peace with no modifiers, **WHEN** totals are read
  per good class, **THEN** (a) the sum of every gathered wilderness province's `own` output equals the sum, over
  settlement provinces, of their wild-share terms (conservation of F2's chain, within 0.1 %; ungathered output is outside
  the sum); and (b) the supply Regional Economy & Trade B reads for each province (read from its published values, not
  recomputed) equals `acc_v · Σ prod · val` for that season, with `acc_v` taken that season (`D_loc` is nonzero after
  season 1). A province's own consumption is drawn from market stock as demand and is not a term here; the `(1 − acc_v)`
  share is lost in carriage; terms Regional Economy & Trade adds after supply (`(1 − h_f)` share, `shockS`, Imp/Exp) are
  its own to test.
- **AC-PV-23** `[A]` integration *(fixture-dependent, OQ 9)*: **GIVEN** a province below access 1 with a staple shortage, **WHEN** the season runs,
  **THEN** its local price is above the market price, and after a road raises its access to 1 its local price is
  within the tolerance of Regional Economy & Trade's Formulas A and L1 of the market price within the number of seasons
  they set (fixture values taken from those formulas when the economy revision lands, OQ 9; the price drifts, it does
  not jump).
- **AC-PV-24** `[A]` performance: **GIVEN** seed 7, **WHEN** the province step runs, **THEN** it takes under 5 ms a
  season on the dev PC (release export), inside S6's `T_map` budget of 20 ms (Living World Tick). *(guess)*
- **AC-PV-25** `[S]` **GIVEN** the map zoomed in past `province_full_fit` (defined in `design/ux/hud.md`), **WHEN** a province is clicked, **THEN** its
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
| 2 | Building catalogue: costs, build seasons, upkeep and output per level for each kind in rule 8 (data, not GDD); the workshop is a craft-capacity effect read by Trade Goods, not an output class | Claude, proposal; user | Before the province step is built |
| 3 | Starting buildings per seat kind (rule 10): authored per province or a set by seat kind plus F6's logistics top-up | User | Before the province step is built |
| 4 | Province names: generated from the seat place's name ("X county") or authored for all 273, wilderness included | User | Before the province panel |
| 5 | The season budget for the province step (AC-PV-24's 5 ms inside `T_map` is a guess) | Claude | Regional Economy & Trade revision |
| 6 | Whether the player's own ground (later) can hold province buildings, or only home works (Travel & Map rule 32) | User | When player holdings are designed |
| 7 | Does a struck or famine province raise the event odds for bandits, migration and sect missions (Event Engine hooks named, weights not set) | Claude | Event Engine content pass |
| 8 | New rules the 2026-11-23 review raised and the design does not yet decide: staff pooled across a province's buildings (at P 10–16 and many levels, per-building staff may starve); upkeep priority (logistics first) and a grace after a holder change; one building per kind per province; slot priority between a local lord and the great sect; whether access limits imports; where building costs go; carry arbitrage out of under-connected provinces; whether access limits how fed a province is (`cover_st` times `acc`); rule 12 stats with no formula term yet (infrastructure, growth, capacity); per-settlement population for places in a multi-settlement province (`P_set · P / P0`); the `(1 − acc)` share of output is destroyed, where Victoria 3 keeps it in the local market (L1's `bal_r` uses the full `value_lt`); who pays the unpaid remainder of a player-funded building after a holder change (AC-PV-20); staff is per building, not pooled, so population does not bound total output | User, with the balance pass | Regional Economy & Trade revision |
| 9 | Owed in Travel & Map: say that a province building's site gain counts once, in `G_f` of Formula H (F4's `out[b]` is the non-site part only); owed in Travel & Map: layer-2 works under province buildings follow Provinces' Unpaid and Ruined states, not Formula J's fade (rule 31, Formula J, AC-TM-106); owed in Regional Economy & Trade: `D_loc` (base value) and the staple cover (`cover_st` = the market's mean `c[m,k]` of herbs and beast parts, F3, read at the yearly step) are last season's values; the contract's `value_lt` is `prod · val`, and Provinces' `acc[v]` is RET's `inf_v` (RET A's `acc_v` adds the safety term; AC-PV-22 and 29 are written against `acc_v` in peace); the `(1 − acc)` share of production is lost in carriage (AC-PV-22); Formulas A and L1 name the price tolerance and seasons for AC-PV-23; owed in Regional Economy & Trade (user decision 2026-11-23, imports count in usage): rule 16's note, the Formula L1 asymmetry and example lines and the poor-region famine edge case still say a province short of a good, with no surplus, trades at P in peace; they become: it is under-connected, has access below 1 and its local price is above P in peace (RET A's `inf_v` uses F6's usage with imports) | Claude | Next amendment of those GDDs |
| 10 | Rule 9 mapping gaps the 2026-11-23 round 2 found: *(partly answered 2026-11-24: "pavilions" dropped; granary under Holdings and great-project stages under Institutions kept; tracks now price levels instead of capping them, rule 9)* which tracks cap a local lord (assumed: the minor sect's own); two minor seats in one province (assumed: the sect on the seat settlement, else the lowest sect id) | User | Before the province step is built |
