# Travel & Map (Bản Đồ & Hành Trình)

> **Status**: Implemented 2026-11-20 (not yet design-reviewed; designed 2026-11-10, revised 2026-11-13 twice:
> `design/research/fixed-world-decisions.md`, `design/research/map-making-rules.md` section L). Built:
> - Formula C offline on the fine map (`tools/design/map/land_qi.py`);
> - places' qi, the element match and Formula B's layers (`LandQi`, `MapWorks`);
> - travel by tile with flight and Formula E encounters (`TravelGrid`);
> - map knowledge, clues, search and secrets (`MapKnowledge`, `Discovery`);
> - herb fit and wild herb grounds (`HerbFit`);
> - sites, production and reserves (`MapProduction`), realm cycles, hand-overs and scars (`MapChange`);
> - works, cave abodes, developed ground and residences.
>
> Not built: what waits for Regional Economy & Trade (#43) and the Sects redesign (#26), and the screens (Game UI #37).
> Plan, evidence and the acceptance-criteria audit: `production/plans/continent-world.md`,
> `production/qa/evidence/continent-world/` (04-ac-coverage.md).
> **Author**: user + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Implements Pillar**: Pillar 5 (A World That Remembers), Pillar 4 (Every Season Counts); touches Pillar 1 (Your Dao, Your Name) and Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Travel & Map is the one fixed continent the cultivator lives in, the same in every game: seas and islands on a grid
of 25 km tiles, each a natural mix of up to three of nineteen biomes, about 20 regions and 200–300 places, each with
its own qi density and element shares. The qi follows
the terrain: the heart of a jungle is richer in Wood than its edge, and the ground beside a lava flow is the most fiery.
Where you live and
travel matters to your build: matching ground cultivates faster, herbs grow only where they fit, and four layers (the
land, blessed lands and secrets, shared works, your own home works) decide what a place gives *you*. It also owns
travel, discovery by clues, resource sites and the seasonal production contract that the economy and sects build on.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `World Generation & History, Map build, World Database, Time & Turn, Spiritual Roots, Character Stats; soft: Realms & Bottlenecks, Sects & Missions, Formations, Event Engine, Regional Economy & Trade`

## Overview

Travel & Map is the world the cultivator lives in and moves through. It is one authored continent, the same in every
game, with its coasts, seas and island chains (user decision 2026-11-12). The land is stored as index images: a fine
map of cells about 6 km across (biome, elevation, water) under a grid of 25 km tiles (temperature, rainfall, and special
features such as lava flows, ice fields and ore veins). Each tile holds a natural mix of up to three biomes, read from
its cells, so a tile can be part steppe, part foothills with a river through it, and biomes change gradually where they
meet (user decision 2026-11-13). From these the map build computes the land's spiritual qi: the density (linh khí) and how much of each element (and variant)
the ground holds. The qi follows the terrain. The heart of a biome is purer than its edge, and features such as a lava
flow or an ice field push their element outward. On top of that terrain sit about 20 regions and 200–300 named places
(towns, markets, mountains, valleys, lakes, islands, spirit veins, mines, sect seats), the same sects and starting
borders in every game, and the hidden ruins, caves and secret realms that the world's history left behind, whose exact
spots are rolled each game from a few hand-picked candidates.

Places are the stops, joined by roads, rivers and sea lanes. Leaving the road means crossing wilderness tile by
tile, which is slower and more dangerous, and it is how a cultivator follows a clue to a hidden place.

Where you are matters to your build. A root cultivates faster on ground that matches its elements, a herb grows only
where its climate and element allow, and Core Formation needs a place dense enough in qi. Distance costs seasons
(Pillar 4), and every place, road and discovery is a recorded fact the world remembers (Pillar 5).

Each region produces resources: linh thạch from its mines, herbs, ores, beasts. It also needs some, and a sect
controls it. This GDD owns what the map produces and where. Market and Sects build prices, trade,
income and conflict on that contract.

The terrain is authored once and stays fixed. Anything that changes (mine output, a region's supply, who holds a
territory) is worked out per region once a season, so 5,000 cultivators stay cheap to simulate.

Without this system, a root's elements and a herb's needs would never meet the land, and the world would be a list of
names rather than a place.

## Detailed Design

### Core Rules

**The land**

1. **One fixed world.** The continent is authored once and is the same in every game (user decision 2026-11-12;
   `design/research/fixed-world-decisions.md`). It is a grid of tiles holding one continent, its coasts, the seas and
   island chains: 540 × 360 tiles of about 25 km, covering about 13,300 × 8,900 km (user decision 2026-11-13; the size
   is a data value). Under the tiles lies a **fine map** `fine_factor` (4) times finer, 2,160 × 1,440 cells of about
   6 km, so each tile holds 16 cells (user decision 2026-11-13). The land comes from authored index images:
   - per fine cell: biome, elevation, and water (sea, lake, river);
   - per tile: temperature, rainfall, and a feature layer (rule 4).

   When the map is built, each tile's mix (rule 2) and rules 3–4 are computed once from these images and stored with
   the map. A designer can correct any cell or tile by hand, and the correction is stored like any other value. A save
   stores the changes, not the land.
2. **Nineteen biomes.** Each biome has a base element profile, a base density, a base danger, its climate and, for most
   biomes, a **signature element**: the element its heart is purest in. Biomes whose character comes from a feature
   (volcano, glacier, miasma wasteland) are mild at their base and take their peaks from features (rule 4). A volcano
   is Fire 45, Earth 40, Metal 15, and its lava flows make the fiery ground. The profiles are first guesses, kept in
   data.

   | Biome | Hán-Việt | Leans toward | Signature |
   |---|---|---|---|
   | Temperate forest | rừng ôn đới | Wood, Water | Wood |
   | Bamboo forest | rừng trúc | Wood, Metal | Wood |
   | Jungle | rừng rậm nhiệt đới | Wood, Water, Fire | Wood |
   | Grassland | thảo nguyên | Wood, Earth | — |
   | Steppe | đồng cỏ khô | Earth, Metal | Earth |
   | Desert | sa mạc | Earth, Fire, Metal | Fire |
   | Salt flats | bãi muối | Metal, Water, Earth | Metal |
   | Badlands | đất cằn | Earth, Metal | Earth |
   | Swamp | đầm lầy | Water, Wood | Water |
   | Mangrove | rừng ngập mặn | Water, Wood | Water |
   | Highland | cao nguyên | Earth | Earth |
   | High mountain | núi cao | Metal, Earth | Metal |
   | Karst peaks | núi đá vôi | Earth, Metal, Water | Earth |
   | Volcano | hỏa sơn | Fire, Earth, Metal (mild; lava flows make the peaks) | — |
   | Tundra | đồng băng | Water, Earth | Water |
   | Glacier | băng nguyên | Water (mild; ice fields make the Ice) | — |
   | Miasma wasteland | tử địa | Earth; low density, high danger (its source makes the Darkness) | — |
   | Lake | hồ | Water, Wood (shores do the rest) | — |
   | Sea | biển | Water | — |

   Coast and Lake-and-river-valley are no longer biomes (user decision 2026-11-13): a tile that is part sea is a coast,
   and a river is a line through the tiles (rule 4), so the mix does their job.

   **A tile is a mix.** A tile's **mix** is the share of each biome among its 16 fine cells. A biome under 10 % of the
   tile (`mix_share_min`) is folded away, at most three are kept (`mix_parts_max`), and the kept shares are scaled back
   to 100 in whole percents. Each kept biome is a **part** of the tile; the cells of a folded biome count with the
   largest part. The **main biome** is the largest part and names the tile; a tile is **sea** when sea covers half of it
   or more. So a tile can read *Steppe 55 · Highland 30 · Grassland 15, with a river*. Where biomes meet, the fine map
   breaks one into groves, outcrops and clearings of the next, so border tiles are mixed and deep ones are pure (user
   decision 2026-11-13: up to three biomes a tile, each at least 10 %).

3. **Qi has two parts.** **Density** (linh khí) says how much qi the ground holds. The **element shares** say what
   kind it is: five base shares summing to 100. Qi is built on the fine map, cell by cell, in three steps (Formulas C),
   and each part of a tile reads the mean of its own cells:
   - **Depth:** the heart of a biome is purer than its edge. A cell's depth is its distance to the nearest cell whose
     biome has a different signature, or none. Jungle beside bamboo (both Wood) is therefore not an edge, while
     jungle beside grassland is. The deeper the cell, the more its signature element is pushed up, until full depth
     (about 550 km). In wild biomes, depth also raises density and danger: the deep jungle is richer and deadlier,
     and farther from any market.
   - **Blending:** each cell's shares are averaged with those around it (about 220 km), so biomes fade into each
     other. Outer jungle beside grassland carries some Earth.
   - **Features:** each feature pushes its elements, density and danger outward from its tiles, fading with distance
     (rule 4).

   After each step the five base shares are scaled back to 100. More Fire means a smaller share of every other
   element, so the shares say what kind of qi a tile has and density says how much (user decision 2026-11-13). The
   stat block shows each step's contribution as its own line (rule 7). Today's meaning of density is unchanged, so
   Realms' Core Formation rule still reads it (density at least `core_density_min` 1.4, about 18 % of places).
4. **Features.** Special terrain is painted in the feature layer or read from elevation and rainfall; rivers and lake
   shores come from the fine map. Each feature pushes from its tiles with a set strength and a reach in kilometres,
   kept in data:

   | Feature | Source | Pushes |
   |---|---|---|
   | Lava flow or vent | painted | Fire, some density |
   | Hot spring (ôn tuyền) | painted | Fire and Water, density |
   | Ice field or glacier core | painted | Ice, Water |
   | Snowline | elevation above a threshold | a little Ice |
   | Storm peaks | high elevation and high rainfall | Thunder |
   | High plateau | high and flat | Wind |
   | River or lake shore | the fine map's rivers and lakes | Water; Wood on the banks |
   | Ore vein (khoáng mạch) | painted | Metal |
   | Spirit vein (linh mạch) | painted | density |
   | Sacred summit | painted | Light |
   | Deep cave or karst core | painted | Darkness |
   | Miasma source (an old battlefield) | painted | Darkness, danger |

   **Variant qi** comes only from features and sits outside the 100. Variant features have a short reach, so each
   variant stays in at most 2 % of places (`variant_place_share_max`) and a variant root has only a few prized homes.

   **As built (2026-11-20):** the miasma wasteland is laid by the map tools as a feature over its tiles (density down,
   danger up, Earth and Darkness pushed), not as a biome of the fine map; the derived snowline, storm peaks and high
   plateau come from the map tools' own pass (`sacred.json`).
5. **The ground sets the cultivation rate.** Cultivating at a place multiplies the rate by the place's density, as it
   does today, and by an **element match**: how well the root's purities fit the place's shares and variants. Matching
   ground speeds cultivation **with no upper limit**, and mismatched ground slows it to ×0.8 at worst (user decision
   2026-11-13: the ceiling and the stack cap are removed, the floor is kept). Over the world the land match still
   averages about ×1.0 for every root, so Realms' calibration holds on average. A strong root on its best ground now
   rises well past the old ×1.3, so Realms re-runs its bot with this in place. The higher layers add to the match
   (rule 27), each within its own limit, with no cap on the total. The formula is in Formulas.

**Places**

6. **Named places sit on tiles.** About 200–300 places across about 20 regions (raised from 150–250, user decision 2026-11-15, for more cities and the ruined cities of the history). A place sits in one part of its tile
   (rule 2) and reads that part's terrain and qi, and its kind adds to it: a mountain place on a tile that is 30 % high
   mountain sits in the mountain part. The kinds:
   - **settlements:** city (thành), town (trấn), market (phường thị), village (thôn);
   - **wild sites:** mountain (sơn), valley (cốc), lake (hồ), forest (lâm), island (đảo);
   - **special sites:** spirit vein, mine (khoáng mạch), sect seat, secret realm (bí cảnh), ruin (di tích; a ruined city is a ruin with a former-city record, from World Generation's territory history) and cave
     abode (động phủ).

   A settlement lowers danger, and cities and markets have trade (towns and villages do not, as built).
7. **Every place shows its stat block** (Pillar 2): the tile's mix and the part the place sits in; climate (temperature and rainfall); density; element shares
   and any variant; danger; settlement size; resources and herb fit; owner (a sect or none); and features
   (river, coast, vein). Every value is stored, inspectable and recorded in the World Database.
8. **A cave abode can be opened anywhere on land.** On a wilderness tile that holds no place, a cultivator may open a
   cave abode. It becomes a new place with that tile's terrain, owned by its founder and recorded as a fact. The
   cultivator's home (where their fields and formations sit) is one place at a time. An abode left behind stays on the
   map as a place others can find. The price is the tile's danger and its distance from markets, and opening one
   takes one season and a small fee (Formulas M; user decision 2026-11-10). On a mixed tile the cultivator picks the
   part, and the abode reads that part. Who may object on owned land is for Sects (#26).

**Moving**

9. **Four kinds of route.** Roads join places. Rivers carry boats between river places. Sea lanes carry ships between
   ports (coastal settlements). The **wilderness** is everything else, crossed tile by tile. **As built
   (2026-11-20):** boats also cross lake tiles, so a place in a lake can be reached; open sea off the lanes is
   impassable.
10. **Speed is tiles per season.** Each mode has a speed, slowed by terrain: road about 54 tiles (about 1,300 km),
    wilderness about 18 (less in mountains, swamps and jungle), boats and ships faster along their lanes. A mixed tile
    slows by the share of each land part, and its water parts are walked around. **Flight** opens at Foundation
    Establishment on a flying artifact. It ignores terrain and roads, and it is faster at higher realms (about 135
    tiles a season and up). It drains linh lực per tile, so a flier may arrive with a low pool (**as built
    2026-11-20, user-accepted:** flight needs only the realm until flying artifacts exist in the item data, and the
    landing pool is reported, not yet carried into a fight). `travel_speed_pct` applies to
    every mode. The numbers are in Formulas.
11. **Teleport arrays** (truyền tống trận) join some great cities. Sects own them and charge a fee in linh thạch that
    grows with distance, and a jump takes 0.05 of a season. The owner decides who may use one (Sects #26). Capability
    #21 (Blink Mark) still works as today.
12. **Travel uses part of a season.** A trip's length is a fraction of a season. A short hop leaves the rest of the
    season free, and the cultivator can cultivate at the destination at a reduced rate (in Formulas). A long trip runs
    over several seasons and ages the character like any other. An encounter can interrupt a trip (**as built
    2026-11-20, user-accepted:** a trip draws at most one encounter and it is met on arrival, set where its stretch
    spent most of its time; the interruption waits for tile locations).
13. **Danger on the way.** Each stretch of travel can draw an encounter from the Event Engine. The chance depends on
    the tiles' danger and the mode: roads are safer, the wilderness is riskier, and flight avoids ground encounters but
    not everything. The biome filters which events can happen (a sandstorm needs a desert). On a mixed tile the
    encounter's biome is rolled by share, and a fight takes place on that part. A character who knows the tile's mix
    may **keep to one part**: the crossing then costs that part's terrain and danger, and its biome sets the encounter
    (user decision 2026-11-13).

**Knowing and finding**

14. **Each character knows part of the map.** The **overview map** is common knowledge: every character sees the whole
    continent's painted geography, the famous places, the great cities and the sect seats from the start. Its political
    borders are live for the major powers (the great sects, marked in data); minor holdings and seats show
    as the character last heard of them, refreshed by a visit, news or a map (user decision 2026-11-13). The
    **zoomed-in map** is personal. A cultivator starts knowing their home region (set by their origin), the main roads
    (the roads between cities) and the great cities (every city). Tiles near their path become known as they travel, in
    a wider band with more divine sense (thần thức), and places become known when visited or heard of. A known tile
    shows its main biome; its full mix shows once the character has crossed or stood on it, or read it on a map or
    jade slip. Bought maps, jade
    slips (ngọc giản) and sect libraries add more. NPCs know their own region, kept abstract. **Signposts** (as built
    2026-11-20): standing at a place makes the places its roads and lanes lead to known, so a road can be followed out
    of the home region.
15. **Hidden places are left by history, and their spots are rolled.** The world's authored history names the ruins,
    dead cultivators' cave abodes and secret realms it left behind (Pillar 5: a famous dead NPC's cave is really there).
    Each has 2–4 hand-picked candidate tiles in the wilderness, and at game start the seed picks one. The same history
    therefore lies in a different spot each game, and a guide can't give it away (user decision 2026-11-12). Tile
    secrets roll their spots the same way, and each resource site's reserve is picked from a few hand-set sizes. Famous
    places shown on the overview are fixed. A hidden place is not shown to anyone until it is discovered or revealed.
16. **Clues narrow the search.** A clue names a search area:
    - a **rumour** names a region;
    - a **jade slip** names a small area of tiles;
    - a **map** names the exact tile.

    A clue has a quality, and some clues are false. The engine records the truth and never shows it.
17. **Searching costs seasons.** In a named area, the cultivator searches off-road. Each season there is a chance to find
    the place, set by the area's size, the cultivator's divine sense and the clue's quality (in Formulas). An exact map
    costs only the journey and the danger at the site: arriving on its tile is a sure find (user decision 2026-11-10). A discovery is recorded in the World Database, and the place
    joins the finder's map.

**What the land gives**

18. **Herb fit is a score.** Every herb has an element, an ideal climate band (temperature and rainfall) and, for rarer
    herbs, a density need. At a place, each condition gives a factor from 0 to 1, and the **fit** is their product.
    Growth runs at the fit, up to a small bonus (about ×1.2) on ideal ground. Below a floor (about 0.2) the herb can't
    be planted. The screen shows the number, a word (excellent, good, fair, poor, unplantable) and a line per factor,
    so a poor fit says why. Spirit Fields read the fit of the field's place (its part), and wild herb grounds appear in
    parts where fit is 0.6 or more. A herb a cultivator gathers at a wild herb ground gets its age when gathered, by Trade Goods
    Formula K (most at `mature_years`, a seeded share older on dense, rarely reached ground; amended 2026-11-15); the
    commons' harvest that feeds the markets counts at `mature_years`. **As built (2026-11-20):** a wild place (peak,
    gorge, lake, island, forest, spirit vein, ruin, blessed land, secret realm, abode) holds the ground of every herb
    that fits it at 0.6 or more (`map_resources.json` `herb_ground`); exploring it gathers 1-2 units with a seasonal
    chance, aged by Formula K (access 0.5 until #43). The Advisor points a herb that cannot grow at home to the nearest
    known herb ground.
19. **About ten resource kinds**, kept in data: linh thạch, the five element ores, wild herbs (by element), beast
    materials and a few special goods. Each maps to Item Database materials and herbs.
20. **Resource sites** are places of the kinds mine (including linh thạch mines), spirit vein, herb ground and beast
    lair. A site has a **reserve**, a **base output** per season and a **recovery rate**. The land decides what a site
    yields: an ore site yields its part's top base element (a Fire ore vein sits on a volcano), and a linh thạch mine
    needs land density 1.0 or more and Earth + Metal shares of 50 or more. **As built (2026-11-20):** the mines and
    spirit veins are the sites (no herb-ground or beast-lair places are authored); the mines carry no authored grade,
    so a site's grade follows its land density (small below 1.2, medium below 1.5, large above), a guess in
    `map_resources.json`; a spirit vein yields linh thạch.
21. **Every place has a production value** per resource kind per season. It is the base output times five factors:
    - its reserve;
    - its workforce (settlement size and whether an owner works it);
    - demand (a higher price drives more extraction);
    - any scar;
    - its works (rule 31).

    The value is stored and shown in the stat block (Pillar 2). The formula is in Formulas.
22. **Reserves thin and slowly recover.** Extraction above a site's sustainable rate lowers its reserve, and its output
    falls with it. A rested site recovers slowly. A reserve never falls below a floor, so nothing is lost for good, but
    an over-worked mine becomes a story of its own.

**Regions and territory**

23. **About 20 regions**, each a named set of tiles and places. Regions follow the terrain: mountain ranges, rivers and
    coasts make at least 60 % of their borders.
24. **Only sects own land.** A sect's **territory** is the regions and sites it holds, and it acts as a country: its
    towns, its production and its taxes. How it taxes and spends belongs to Sects (#26). Every region belongs to a sect;
    there are no unowned regions (user decision 2026-11-14). Wilderness, the land away from roads and towns, still
    lies inside every territory. A loose cultivator owns only their cave abodes.
25. **The production contract.** Once a season the map adds up production by resource kind, for each region and each
    territory, and publishes it with the region's population. **Regional Economy & Trade** (a new system, designed
    next) turns that into market stock, prices and the flow of goods between markets. Until it exists, the Market
    works as built.

**How the map changes**

26. **Four kinds of change**, all worked out per place or per region once a season:
    - **Sites thin and recover** (rule 22).
    - **Secret realms on cycles:** some secret realms open every 40–120 seasons for 2–4 seasons, and rumours announce
      an opening 4 seasons ahead (data keys per realm; the numbers are guesses). The entrance never moves.
    - **Territory changes hands:** sect events (designed in Sects) can move a region or site to a new owner, and the map
      records it.
    - **Great battles scar the land:** an event above a threshold can permanently change a tile's density or element
      shares, such as a Fire crater or a dead vein. A scar is stored as a change to the terrain, and the World Database
      records it.

    The authored terrain never changes otherwise.

**The four layers of the land**

27. **A place's qi and production are a stack of four layers**, read from the bottom up for a given character:
    - **Layer 4, the land:** the authored biome and terrain, with its computed qi (rules 1–4). It never changes, except through a battle scar
      (rule 26).
    - **Layer 3, blessed lands and secrets** (rules 28–30): richer qi left by history.
    - **Layer 2, shared works** (rule 31): improvements that whoever holds the place has made, for everyone there.
    - **Layer 1, home works** (rule 32): a character's own improvements to their home, for themselves alone.

    Each layer adds to the one below, inside its own cap. The full stack has an overall cap on density (in Formulas).
    The element match has none (user decision 2026-11-13), only each layer's own limit. The stat block shows each
    layer as its own line (Pillar 2), so a cultivator
    always sees why a place is strong *for them*.

**Layer 3: blessed lands and secrets**

28. **Blessed lands** (phúc địa) are places whose qi is far richer than their biome. History leaves them: the old home of
    a Hóa Thần who has left the world, a dragon's lair, the grounds of a vanished sect. They come in two sizes:
    - **large:** 2–5 on the map, each 40–180 tiles (about 25,000–110,000 km²);
    - **small:** 10–30 on the map, one tile each, room for one cultivator.

    Their element match adds to the land's, with no cap on the total (user decision 2026-11-13). Most lean strongly
    toward one element or variant, and those strong in several elements are rarer. Some are famous and held by great
    sects, in the same place every game; others are hidden places whose spots are rolled from candidates each game
    (rule 15) and found by clues (rules 16–17). Once a blessed land is found, its layer 3 benefits everyone there.
29. **Tile secrets.** A tile may hide a small secret: a hidden spring (extra element match on that tile), a pocket vein,
    a rare herb patch or a buried cache. A secret is per-character knowledge. Only someone who has found it, or been
    told, gets its layer 3 benefit, and others on the same tile get nothing from it.
30. **Finding a secret.** When a cultivator arrives on a tile that holds a secret, there is a chance to find it, set by
    their divine sense and how well hidden it is. Searching the tile raises the chance (rule 17). A found secret is
    recorded in the World Database as the finder's knowledge, and it can be told, sold or traded as a clue.

**Layers 2 and 1: works on the land**

31. **Shared works (layer 2).** Whoever holds a place (a sect, an NPC or a player) can spend seasons and linh thạch or
    materials to raise its density, push its element shares toward a chosen element, or raise its production, for
    everyone there. There are two kinds:
    - **Permanent works** (spirit groves, qi channels) give small gains that never fade, up to a low cap per place, so the
      world grows somewhat richer over time but never by much.
    - **Upkept works** (a sect's gathering arrays, worked mines) give larger gains that fade back when their upkeep
      stops.
32. **Home works (layer 1).** A character's improvements to their own home benefit only that character, and only at their
    home: a personal gathering formation, a tended cave abode, a private field. They follow the same two kinds as layer 2,
    with their own caps. If the home is left, its home works stop counting for the character. An abandoned home's
    permanent works stay with the place, for whoever finds it. Today's home gathering formation (Tụ Linh Trận) becomes a
    layer 1 upkept work. Formations (#17) owns the formations; the map owns what they change on the land.

**Developed ground and where people live**

33. **Cities and sect grounds are developed, and most people live there.**
    - Settlements and sect seats start each game with layer 2 works already built (authored with the map), and their
      holders keep them up. A city holds more than a town, a town more than a village, and a sect seat the most. Settlements' natural density
      is low (0.6–1.1), so these works are what make a city a decent place to cultivate.
    - **Most NPCs live in settlements and sect grounds** (about 85 %, `npc_settled_share`; user decision 2026-11-10).
      Sect members live at their sect's seat, and the rest spread over settlements by weight (city 8, town 4, market 3,
      village 1). Cities therefore hold more people, more encounters with people and more demand than the wilderness.
    - **The few who live outside** (loose cultivators, hermits) **choose their ground**: each picks from the best spots
      for its own root in its region (the top quarter by stacked cultivation rate, `npc_wild_pick_top`), never at
      random. A hermit on a hidden blessed land is a story the world can tell.
    - **Higher realms live better** (user decision 2026-11-10). In a settlement or sect ground, residences come in
      **grades 1–5**: higher grades sit nearer the place's qi heart and carry better furnishing. Sects allocate grades to
      members by realm (and rank, which Sects #26 owns); in a city the grades are rented or sold, so the best go to those
      who can pay, and the top grades also require a minimum realm. A settlement's best grade depends on its kind
      (village 2, town 3, market and city 4, sect seat 5). Outside the cities, a higher-realm NPC chooses from a
      narrower, better band of its region's spots (Formulas M).
34. **Homes for rent or sale.** A city or a sect can rent out or sell residences on its developed ground. A rented or
    bought residence becomes the character's home, with the place's layers 4–2 and the residence's own furnishing (a
    fixed layer 1 home work that comes with it). Rent is paid each season; a purchase is paid once and the character
    owns the residence, still inside the settlement. **A settled home holds less qi than a cultivator's own developed
    base or a blessed land:** homes inside settlements and sect grounds have a lower density cap (1.8, against 3.0 for a
    self-built base in the wilderness). Their element match has no settled cap: it is as good as the land and works
    under it (user decision 2026-11-13). The character may add their own home works there, but the density cap still
    applies. The holder sets prices and who may rent (Sects #26
    for sect grounds).

### States and Transitions

**A place, as one character knows it** (each character has their own map, rule 14):

| State | Meaning | Becomes | When |
|---|---|---|---|
| Unknown | Not on the character's map | Heard of; Known | A rumour or clue names it; a map or jade slip shows it; the character passes within sight |
| Heard of | Name and region known, not its tile | Known | A better clue, a map, or a visit |
| Known | On the character's map, with its stat block as last seen | — | Its stat block refreshes on each visit |

A hidden place, including a hidden blessed land (rules 15 and 28), is Unknown to everyone until someone discovers it.

**A tile secret, per character:** **unknown** → **found** (arriving or searching wins the chance, rule 30) or **told**
(learned from another character or a clue). Either one grants its layer 3 benefit. It never returns to unknown.

**A secret realm on a cycle:**

| State | Becomes | When |
|---|---|---|
| Sealed | Announced | N seasons before its opening, rumours spread (an Event Engine event) |
| Announced | Open | The opening season arrives |
| Open | Sealed | After its open seasons; anyone still inside is handled by the secret realm's own rules (Event Engine) |

**A resource site** is a band read from its reserve, not a stored state: **rich** (reserve above 80 %), **worked** (30–80 %)
or **thinned** (below 30 %, output visibly lower). It moves between bands as the reserve changes each season.

**A work on the land (layers 1 and 2, rules 31–32):** **permanent works** only accumulate, up to their cap. **Upkept
works** are **upheld** while their upkeep is paid, then **fading** toward zero each season after the upkeep stops, until
they are gone or upheld again.

**A home:** **home** (the character's current home) → **left** (its home works stop counting for the character; its
permanent works stay with the place, which others can find or claim) → **ruin** (its founder died; it may become a hidden
place left by history, rule 15).

**A character on the map:**

| State | Becomes | When |
|---|---|---|
| At a place | Travelling; Searching | The character starts a trip, or starts a search in a named area |
| Travelling (by mode) | At a place; In an encounter | The route ends, or an encounter interrupts it |
| Searching | At a place; In an encounter | The site is found (it becomes a place), the character stops, or an encounter interrupts it |
| In an encounter | the state it interrupted | The event resolves (Event Engine, Combat) |

### Interactions with Other Systems

| System | Direction | What flows | Who owns it |
|---|---|---|---|
| Realms & Bottlenecks | out | A place's density for the cultivation rate and the Core Formation condition (`core_density_min`), read through the full layer stack the character sees (rule 27); the element match factor (rule 5) | This GDD (density, match, layers); Realms (the rate, the condition) |
| Spiritual Roots | in | The root's purities, owned and road-raised, for the element match | Spiritual Roots |
| Character Stats | in | `travel_speed_pct`; divine sense (thần thức) for sight range, search and secret-finding chance; realm for flight | Character Stats |
| Spirit Herbs & Fields | out | Herb fit at the field's place (rule 18), through the layer stack | This GDD (fit); Spirit Herbs (growth) |
| Regional Economy & Trade (#43), Market | out | Production by resource per region and territory, and population, once a season (rule 25) | This GDD (production); #43 (stock, prices, flow) |
| Sects & Missions | in / out | In: who owns which regions, sites and teleport arrays; sect works on their land (layer 2). Out: the territory's production and towns; sect seats and famous blessed lands as places | Sects (ownership changes, taxes, array access); this GDD (the land and its layers) |
| Formations (#17) | in / out | In: gathering formations and other works on layers 1 and 2. Out: the land's values the works start from | Formations (the formations); this GDD (the layer they change) |
| Event Engine | in / out | Out: tile danger, biome and mode, which filter travel encounters; clue and rumour items; secret realm openings. In: discoveries, scars and ownership changes from events | Event Engine (events); this GDD (what they read and change) |
| World Generation & History (#27) | in | The authored history, which names ruins, dead cultivators' abodes, secret realms, blessed lands and tile secrets with their candidate spots; each game's roll among them (rules 15, 28, 29); the random NPCs and their homes (rule 33) | World Generation & History (history, rolls, NPCs); this GDD (terrain, candidate rules) |
| World Database | out | Places, regions, discoveries, scars, ownership, homes, works on each place (layers 1 and 2), who knows each secret, each character's known map | World Database (storage) |
| Living World Tick | out / in | The seasonal update: reserves, secret realm cycles, upkept works fading; NPC positions kept per region | Living World Tick (the tick); this GDD (the rules it runs) |
| Time & Turn | in | Seasons and the fraction of a season a trip uses | Time & Turn |
| Combat | out | Encounters on the way; a flier's linh lực after the trip | Combat |
| Item Database | in / out | Maps, jade slips and told secrets as clue items; resources mapped to materials and herbs | Item Database |
| Quests | out | Places, arrival, travel time for its visit and deliver stages | Quests |
| Heavenly Tribulation | out | The place's ground tags (biome, element shares) | Heavenly Tribulation |
| Đạo Đồ capabilities | in | #8 (seasons spent travelling also cultivate) and #21 (Blink Mark) | Đạo Đồ / Effects |
| Debug Terminal, Game UI | out | The map display, stat blocks with each layer's line, the known map | UI |
| Save/Load | out | The seed for the per-game rolls (hidden-place spots, reserves, NPCs) and every change (scars, reserves, ownership, homes, works, secrets known, known maps), not the terrain | Save/Load |
| Map build and map check (new tool) | in | The index images (fine map and tiles) and hand corrections, turned into the stored map (each tile's mix, rule 2; Formulas C); the map targets report | Map build (tool); this GDD (the rules it computes) |

## Formulas

All keys live in new data files: `world_map.json` (land, match, travel, search, herbs), `map_resources.json`
(production, reserves) and `map_works.json` (works). Numbers marked *(guess)* have no source yet and are set by the
bot run (Open Questions). Proposed by `systems-designer` and `economy-designer`, 2026-11-10; the user decided the
match reward, the Core Formation share, linear herb growth and the realm-scaled teleport fee.

### A. Element match, land layer (rule 5)

The world_mean_share formula is defined as:

`mu_e = (1 / N_places) · Σ_places s_e / 100`, computed once when the map is built, for each base element and variant.

The land_match formula is defined as:

`M4 = max(M4_min, 1 + k · Σ_e q_e · (s_e / 100 − mu_e))` with `q_e = u_e · p_e / 100`

The sum runs over the 5 base elements and the 8 variants; a variant's `s_e` is its share outside the 100. There is no
upper bound (user decision 2026-11-13).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_e | int | 0 and up, uncapped | calculated (Spiritual Roots) | Purity of e: birth plus road-raised, owned or not |
| u_e | float | 1 or 0.5 | data file (`match_unowned_rate`) | 1 if the root owns e; 0.5 if its purity comes only from rare sources |
| q_e | float | 0 and up | calculated | The root's weight on e |
| s_e | float | 0–100 | calculated (Formulas C) | The place's land share of e; base shares sum to 100, variant shares are mostly 0 |
| mu_e | float | 0–1 | calculated (map constant) | Mean share over places; base values sum to 1 |
| k | float | 1.0 | data file (`match_gain`) | Gain |
| M4_min | float | 0.8 | data file (`match_land_min`) | Land-layer floor; the old ceiling `match_land_max` is removed |

**Output Range:** 0.8 and up, with no ceiling. At every place the base deviations `s_e/100 − mu_e` sum to 0 and each
averages 0 over the world, so **every root averages ×1.0 over the world before the floor**, whatever its element count.
The floor lifts that average slightly for strong roots, and the bot run measures by how much. A single-element root has
the highest peaks and lowest valleys; a dual root peaks on mixed land; a balanced five-element root gets ×1.0 on every
land (it still gains from layers 1–3, which are not centred). Players choose their ground, so a well-placed player
cultivates faster than the calibration's ×1.0; that is the reward for choosing ground (user decision 2026-11-10).
Without the ceiling, that reward now grows with purity, and Realms re-runs its bot with the match in (its Open
Question 23) against the NPC targets (1 in 8 / 12 / 15 / 20). A settled NPC's match averages about ×1.0; NPCs living
outside sit on chosen ground (rule 33) at higher values. The player still gains most from choosing ground, because the
player can search the whole world and NPCs only their region.

**Examples** (mu_e = 0.2 for each base element):
- The root Wood 40, Fire 86, Water 10 on a volcano away from any flow (Fire 45, Earth 40, Metal 15):
  0.86 × 0.25 + 0.40 × (−0.2) + 0.10 × (−0.2) = 0.115, so M4 = **1.115**. On its lava flow (Fire 66): 0.86 × 0.456
  − 0.08 − 0.02 = 0.292, so M4 = **1.292**.
- The same root on a lake shore (Water 60, Wood 40): 0.10 × 0.40 + 0.40 × 0.20 + 0.86 × (−0.2) = −0.052, so
  M4 = **0.948**.
- A pure Wood root in deep jungle (Wood 60): at purity 100, 1 + 1.0 × 0.40 = **1.40** (the old ceiling cut this to
  1.3); at purity 200, 1 + 2.0 × 0.40 = **1.80**.
- An Ice root at purity 50 on a glacier with Ice share 40: 1 + 0.5 × (0.40 − 0.01) = **1.195**.

### B. The four-layer stack (rule 27)

Every item on layers 3, 2 and 1 has a **density add** ΔD and **share pushes** Δs_t (points added to element t, not
renormalised: the ground grows richer and other elements are not reduced). Herb fit (G) reads the same pushed shares.

The stacked_density formula is defined as:

`D = min(D_cap, D4 + min(c3, ΔD3) + min(c2p, ΔD2p) + min(c2u, ΔD2u) + min(c1p, ΔD1p) + min(c1u, ΔD1u) + density_bonus)`

The stacked_match formula is defined as:

`M = max(M_min, M4 + Σ_{i ∈ {3,2,1}} min(m_i, k · Σ_t q_t · min(cs_i, Δs_{i,t}) / 100))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| D4 | float | 0.3–2.4 | calculated (C) | Land density, scars included |
| ΔD3; c3 | float | 0+; 1.0 | calculated; data file (`density_cap_l3`) | Blessed land or secret. Targets: large 0.5–1.0, small 0.3–0.6, secret 0.1–0.3 *(guess)* |
| ΔD2p, ΔD2u; c2p, c2u | float | 0+; 0.1, 0.5 | calculated; data file | Shared works, permanent and upkept |
| ΔD1p, ΔD1u; c1p, c1u | float | 0+; 0.1, 0.75 | calculated; data file | Home works; Tụ Linh Trận is ΔD1u (0.15 per level). Capability #15 raises c1u by 0.30 (its two extra levels) |
| density_bonus | float | 0+ | calculated (stat sheet) | The personal stat from the tree and items only, shown on its own line. Tụ Linh Trận no longer writes it: it counts once, as ΔD1u (re-ruled 2026-11-10); Realms' "place density plus `density_bonus`" reads the stacked density |
| D_cap | float | 3.0 | data file (`density_cap`) | Overall density cap |
| Δs_{i,t}; cs_i | float | 0–100; 80 / 30 / 30 | calculated; data file | Share push on layer i; within 30 on layers 2 and 1, permanent 10 and upkept 20 |
| m_i | float | 0.3 / 0.15 / 0.15 | data file (`match_cap_l3/l2/l1`) | Cap on each layer's match gain |
| M_min | float | 0.8 | data file (`match_stack_min`) | Stack floor. The old cap `match_stack_max` (×1.6) is removed (user decision 2026-11-13); the settled match cap is removed too; homes on settled ground keep only `settled_density_cap` (Formulas M) |

**Output Range:** density 0.3–3.0 (today a secret realm at 2.2 with Tụ Linh at level 5 already reaches 2.95); match 0.8
and up. The land has no ceiling, and layers 3–1 add at most 0.30 + 0.15 + 0.15 = 0.60 between them. A permanent
shared-works cap of 0.1 keeps Core Formation meaningful: if every place were improved to it, places at 1.4 rise from
18 % to at most 28 %.

**Example:** a valley at land density 1.30 fails Core Formation; a sect's upkept array (+0.30) and a level-2 Tụ Linh Trận
(+0.30) give D = **1.90**. The Fire 86 root on its lava flow (M4 1.292), with a small blessed land pushing Fire +40
(0.86 × 0.40 = 0.344, capped to +0.30) and an upkept home work pushing Fire +20 (0.172, capped to +0.15): **M = 1.742**,
which the old cap would have cut to 1.60.

### C. Land qi: depth, blending and features (rules 2–4)

Computed once when the map is built, cell by cell on the fine map (rule 1), in this order. Distances are steps to any
of the 8 neighbours. Every distance key is kept in kilometres and turned into steps by the cell size (`cell_km`, about
6.17 km on the shipped map), so the grid can change size without retuning.

The depth formula is defined as:

`t_i = clamp((d_i − 1) / (d_full − 1), 0, 1)`, where `d_i` is the distance from cell i to the nearest cell whose biome
has a different signature, or none. An edge cell has `d_i` = 1.

The own_profile formula is defined as:

`P_i = norm(P_b + t_i · σ_b · ê_sig)`, where `norm` scales the five base shares back to 100.

The blend formula is defined as:

`B_i = mean of P_j over the (2r + 1) × (2r + 1) window around i`, ignoring cells off the map. Sea and lake cells count,
so coasts and shores pick up Water.

The feature_push formula is defined as:

`fall_f(i) = max(0, 1 − δ_f(i) / R_f)` and `Δ_{i,e} = Σ_f A_{f,e} · fall_f(i)`, where `δ_f(i)` is the distance from
i to the nearest cell of feature f (a feature painted on a tile covers that tile's land cells; rivers and lake shores
are their fine cells).

Base shares: `s_i = norm(B_i + Δ_i)` over the five base elements. Variants: `v_{i,e} = Δ_{i,e}`, outside the 100 and
not scaled.

The land_density formula is defined as:

`D4_i = clamp(b_b + t_i · g_D,b + Σ_f a_f · fall_f(i) + o_kind, 0.3, 2.4)`

The land_danger formula is defined as:

`X_i = x_b + round(t_i · g_X,b + Σ_f x_f · fall_f(i))`, before a settlement lowers it (rule 6).

Overlapping features of the same kind add up: two lava flows side by side make hotter ground. A designer's hand
correction to a cell or tile replaces the computed value and shows in the stat block as its own line.

The part_values formula is defined as:

`V_p = mean of V_i over the cells i of part p`, for the shares, variants and density; danger is the mean rounded half up.
The cells of a folded biome count with the tile's largest part (rule 2).

The tile_values formula is defined as:

`V_t = Σ_p w_p · V_p / Σ_p w_p` over the tile's land parts p, with `w_p` the part's share. A place reads its own part's
`V_p` (rule 6); a crossing reads `V_t`, or `V_p` when the character keeps to one part (rule 13).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| d_i, d_full | int | 1 and up; 90 | calculated; data file (`depth_full_km` 555, turned into steps) | Depth in cells; full depth (about 550 km) |
| t_i | float | 0–1 | calculated | Depth fraction: 0 at the edge, 1 at full depth |
| P_b | float ×5 | 0–100, sums to 100 | data file (`world_map.json` biomes) | The biome's base profile (rule 2) |
| σ_b, ê_sig | float; — | 0–40, about 25 *(guess)*; — | data file | Signature push at full depth; the signature element. Biomes without a signature have no depth |
| r | int | 36 | data file (`blend_radius_km` 222, turned into steps) | Blend window radius (73 × 73 cells, about 450 km across) |
| A_{f,e}, R_f | float, km | 0–80, 111–888 km *(guess)* | data file (features) | A feature's push on element e at its own cells; its reach in kilometres |
| a_f, x_f | float, float | 0–0.9; 0–2 *(guess)* | data file (features) | A feature's density add and danger add at its own tiles. A spirit vein is a_f 0.3–0.9 with R_f 222 km, which keeps today's "neighbours get half" at about 110 km |
| b_b, x_b | float, int | 0.4–1.1; per biome | data file | Biome base density (the values below) and base danger |
| g_D,b, g_X,b | float | about +0.2; about +1 *(guess)* | data file | Density and danger added at full depth; 0 for biomes without a signature |
| o_kind | float | −0.2 to +0.8 | data file | Place-kind offset, set per kind to meet the targets below; 0 on wilderness tiles |
| snowline, storm, plateau | float | — | data file | Thresholds for the derived features: elevation for the snowline; elevation and rainfall for storm peaks; elevation and flatness for plateaus |

Biome base densities `b_b`: sea 0.5; miasma 0.4; desert, salt flats, badlands 0.6; steppe, tundra 0.7; grassland,
swamp, mangrove, glacier 0.8; temperate forest, lake, highland 0.9; jungle, bamboo, karst 1.0; high mountain, volcano
1.1 *(guess)*.

**Output Range:** base shares 0–100, summing to 100; variants 0 and up; density 0.3–2.4; danger the biome's range plus
depth and features.

**Map targets**, checked on the one map by the map check script instead of over 100 seeds:
- 15–21 % of places at density 1.4 or more (Core Formation; user decision 2026-11-10 to keep 18 %, which is 36–54
  places at 200–300 places);
- mean place density 1.05–1.20 (today 1.13);
- about 4 % of wilderness land tiles at 1.4 or more, mostly veins and the deep heart of rich biomes, so a cave abode
  opened at random is rarely a Core Formation spot;
- each base element's `mu_e` between 0.15 and 0.25;
- each variant in at most 2 % of places;
- every base element has at least 8 places where its share is 50 or more, spread over at least 3 regions *(guess)*,
  so no root's best land sits in one corner (user decision 2026-11-13: terrain-driven qi).

| Kind (of 200 places) | Share | Density band | Share at ≥ 1.4 |
|---|---|---|---|
| Settlements (4 kinds) | 40 % | 0.6–1.1 | 0 % |
| Mountain | 14 % | 1.0–1.5 | 20 % |
| Valley | 9 % | 1.1–1.6 | 40 % |
| Lake | 6 % | 1.0–1.4 | 0 % |
| Forest | 6 % | 0.9–1.45 | 10 % |
| Island | 5 % | 1.0–1.5 | 20 % |
| Mine | 6 % | 0.9–1.45 | 10 % |
| Spirit vein | 3 % | 1.4–2.0 | 100 % |
| Sect seat | 3 % | 1.2–1.8 | 67 % |
| Secret realm | 3 % | 1.5–2.2 | 100 % |
| Hidden ruin or abode | 5 % | 1.0–1.6 | 30 % |
| **Total** | 100 % | mean about 1.1 | **18.1 %** |

**Example:** bamboo forest (b 1.0, Wood 50 plus push 25, g_D +0.2). A valley place 600 km deep in it (t = 1): D4 = 1.0 +
0.2 + 0.25 = **1.45**, a Core Formation spot. With a spirit vein 111 km away (0.4 × 0.5 = +0.2): **1.65**. The same
valley at the bamboo's edge (t = 0): **1.25**, which fails Core Formation. The heart of a rich biome is where the Core
Formation ground is.

**As built (2026-11-20):** `tools/design/map/land_qi.py` computes Formula C on the 2,160 × 1,440 fine cells in about
7 s and stores each tile part's values (`assets/map/continent_11_qi.bin`) and each place's (`world_continent.json`).
The first guesses (`assets/data/world_map.json`) were tuned within each biome's "leans toward" and the `o_kind` offsets
fitted to the table: 19.0 % of places at 1.4 or more, mean place density 1.09, 4.0 % of wild land at 1.4 or more.
Missed (Open Question 14): Fire's world mean 0.144 (target 0.15–0.25), and few places reach a 50 share of one element
(Wood 5, Fire 3, Earth 1 against 8 in 3 regions), because the 222 km blend averages a region's biomes. Blessed lands
are not a row of the kind table (their richness is layer 3).

### D. Travel (rules 10–12)

The trip_time formula is defined as:

`T = Σ_tiles c_t / (v_mode · max(f_min, 1 + tsp / 100))`; wilderness `c_t = Σ_p w_p · c_p / Σ_p w_p` over the tile's land parts (water parts are walked around), or the `c_p` of the one part a character keeps to; road `c_t = 1 + r_share · (c_wild − 1)`, with `c_wild` the wilderness cost; boat, ship and flight `c_t = 1`

The leftover_cultivation formula is defined as:

`gain_last = rate_dest · (1 − u) · η` with `u = T − (ceil(T) − 1)`

The flight_drain formula is defined as:

`pool_arrive = pool_max · (1 − f_drain · tiles_flown_this_season / v_fly_eff)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_mode | float | road 54; wilderness 18; river 80 down / 45 up; sea 90; flight FE 135, CF 200, NS 290, DT 400 | data file (`speed_*`) | Tiles per season, 25 km tiles (the 111 km tiles' speeds × 4.5, rounded) *(river, sea and flight above FE: guess)* |
| c_p (c_biome) | float | 1.0–2.5 | data file | A part's cost, from its biome: grassland, steppe, salt flats 1.0; badlands 1.25; forest, bamboo, desert, tundra, highland 1.5; jungle, swamp, mangrove, karst, volcano, miasma 2.0; high mountain, glacier 2.5; lake and sea are walked around, and a sea tile is impassable on foot |
| w_p | float | 0.10–1 | calculated (rule 2) | A part's share of its tile |
| r_share | float | 0.25 | data file (`road_terrain_share`) | How much terrain slows a road |
| tsp | float | any | calculated (`travel_speed_pct`) | Every mode but teleport |
| f_min | float | 0.25 | data file (`travel_speed_floor`) | A negative tsp never stops travel |
| T | float | 0+ | calculated | Trip length in seasons |
| u | float | 0–1 | calculated | Share of the last season spent travelling |
| η | float | 1.0 | data file (`partial_season_efficiency`) | Rate for the leftover share |
| rate_dest | float | 0+ | calculated (Realms Formulas I) | The destination's rate, through its stack |
| f_drain | float | 0.6 | data file (`flight_drain_per_season`) | Share of the pool one full season of flight costs *(guess)* |
| v_fly_eff | float | 33.75+ | calculated | v_fly × max(f_min, 1 + tsp / 100) |

**Output Range:** T 0 and up (each full season ages the character); gain_last 0 to rate_dest; pool_arrive 0.4–1.0 of the
pool, assuming the pool refills at each season start (Open Questions). Today's fixed times still roughly hold: about
1–2 seasons across a region by road (about 90 tiles, 2,200 km), about 3 between regions.

**Example:** an FE cultivator with tsp +20: 36 grassland road tiles (36 / 64.8 = 0.556 s) plus 14 jungle wilderness
tiles (28 / 21.6 = 1.296 s) gives T = **1.852**; season 2 is 85.2 % travel, so it gains **14.8 %** of the valley's rate.
Flying the 50 tiles: 50 / 162 = 0.309 s; drain 0.6 × 50 / 162 = 0.185, landing at **81.5 %** of the pool.

**Example (a mixed tile):** a wilderness tile that is grassland 60, high mountain 40 costs 0.6 × 1.0 + 0.4 × 2.5 =
**1.6**. Keeping to the grassland part costs 1.0; keeping to the mountain costs 2.5. A tile that is grassland 56, sea 44
costs 1.0: the sea part is walked around.

### E. Encounters (rule 13)

The encounter_chance formula is defined as:

`P_stretch = 1 − exp(−Σ_tiles h[d_t] · m_mode · Δt_t)`

A stretch is the part of a trip inside one season, and it draws at most one encounter; the Event Engine picks it,
filtered by biome. On a mixed tile `h[d_t]` is `Σ_p w_p · h[d_p] / Σ_p w_p` over its land parts, and the encounter's
biome is rolled by share; a character keeping to one part uses that part's `h[d_p]` and biome (rule 13).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d_t, d_p | int | 1–4 | calculated (C) | A part's danger: its cells' mean, −1 in a settlement, minimum 1 |
| h[d] | float | 0.15 / 0.35 / 0.70 / 1.20 | data file (`hazard_per_season`) | Hazard per season of wilderness exposure *(guess)* |
| m_mode | float | wilderness and search 1.0; road 0.4; river 0.3; sea 0.5; flight 0.25 | data file (`mode_factor`) | Mode factor *(guess)* |
| Δt_t | float | 0+ | calculated (D) | Time on the tile, c_t / v_eff |

**Output Range:** 0 up to, never reaching, 1. A full wilderness season gives 14 / 30 / 50 / 70 % at danger 1–4; a road
season at danger 1 gives 5.8 %. Hazard is per unit of time, so speed lowers exposure.

**Example (the trip in D):** stretch 1: road 0.556 × 0.15 × 0.4 = 0.033, plus jungle (danger 2) 0.444 × 0.35 = 0.156,
so P = 1 − e^−0.189 = **17.2 %**; stretch 2: 0.852 × 0.35 = 0.298, so **25.8 %**. Flying instead:
0.25 × (36 × 0.15 + 14 × 0.35) / 162 = 0.0159, so **1.6 %**. A mixed tile with parts at danger 1 (60 %) and 3 (40 %)
has a hazard of 0.6 × 0.15 + 0.4 × 0.70 = **0.37** a season.

### F. Sight, search and secrets (rules 14, 17, 30)

The sense_radius formula is defined as: `r = min(r_max, round(r_k · sqrt(DS / DS_ref)))`

The detect formula is defined as: `p_detect = DS / (DS + H)`

The search_chance formula is defined as: `P_season = 1 − exp(−q · (v_wild_eff / c_area) · (2r + 1) · p_detect / A)`; a false clue gives 0, which the engine knows and never shows.

The tile_search formula is defined as: `P_tile = 1 − (1 − p_detect)^n_rolls`; arriving on a tile is one roll of `p_detect` (× `fly_detect_mult` when only flying over it).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| DS | float | 0 and up (45–6,525 typical) | calculated (Character Stats Formulas C) | Divine sense (thần thức) |
| DS_ref | float | 135 | data file (`sense_ref`) | FE at talent 45 |
| r_k, r_max | float, int | 4.4, 36 | data file | Sight and sweep radius in tiles; the same r widens the known band (rule 14). QR 3, FE 4, CF 8, NS 14, DT 31 (about 75–770 km); distance counts diagonals as 1 (Chebyshev) |
| H | float | 50–5,000 | data file, per secret or hidden place | How hidden: pocket vein 100, spring 300, sealed abode 1,000, Hóa Thần cache 3,000 *(guess)* |
| A | float | 1 and up | calculated | Area in tiles: rumour = region wilderness × `rumour_area_share` 0.20 (about 1,600); jade slip `jade_slip_area` 400 (about 500 km square); an exact map is a sure find on arrival, with no roll |
| q | float | 0.5–1.5 | data file, per clue | Clue quality |
| v_wild_eff, c_area | float | 18 × speed factor; 1–2.5 | calculated; data file | Search speed and the area's mean tile cost (D) |
| n_rolls | int | 3 | data file (`tile_search_rolls`) | Rolls for a season spent searching one tile |
| fly_detect_mult | float | 0.5 | data file | A flier passing over a tile *(guess)* |

**Output Range:** each chance is 0 up to, never reaching, 1, so the deepest caches stay hidden from the weak. The square
root compresses divine sense's ×100 range over the realms to about ×6 in radius.

**Example:** CF, DS 450 (r 8, a sweep of 18 × 17 = 306 tiles a season on cost-1 ground), H 300 (p_detect 0.6): with a
jade slip, 306 / 400 × 0.6 = 0.459, so **37 % a season**; from a rumour, 306 / 1,600 × 0.6 = 0.115, so **11 %**. The
same slip at FE (DS 135, p 0.31, r 4, tsp +20: a sweep of 21.6 × 9 = 194.4): 194.4 / 400 × 0.31 = 0.151, so **14 %**.
A spring on arrival at NS: 1,350 / 1,650 = **82 %**. An FE cultivator searching that tile for a season: 1 − 0.69³ =
**67 %**. The areas were rescaled with the tiles (2026-11-13) so these chances stay close to the 111 km tiles' 38 %,
11 % and 14 %.

### G. Herb fit (rule 18)

The herb_fit formula is defined as:

`fit = f_e · f_T · f_R · f_D`; `f_e = e_floor + (1 − e_floor) · min(1, s'_e / s_full)`; `f_T = clamp(1 − max(0, |T − T_i| − tol_T) / fall_T, 0, 1)`; `f_R` the same on rainfall; `f_D = min(1, D / D_need)²` (1 when D_need is 0)

The herb_growth formula is defined as: `growth = g_max · fit` when `fit ≥ plant_floor`; otherwise the herb cannot be planted (linear: user decision 2026-11-10).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s'_e | float | 0–100+ | calculated (B) | The place's share of the herb's element, layer pushes included |
| e_floor, s_full | float | 0.3; 40 (20 for a variant) | data file (`elem_floor`, `elem_full_share`) | A herb off its element still grows a little |
| T, R | float | 0–100 | calculated (land) | Temperature and rainfall indexes |
| T_i, R_i, tol, fall | float | per herb; tol 10–20, fall 30 | data file (new herb keys `temp_ideal`, `temp_tol`, `rain_ideal`, `rain_tol`) | The herb's ideal climate band |
| D, D_need | float | 0.3–3.0; by rarity 0 / 0 / 1.0 / 1.2 / 1.5 / 1.8 | calculated; data file (`density_need_by_rarity`) | Stacked density and the herb's need |
| g_max, plant_floor | float | 1.2, 0.2 | data file (`growth_max`, `plant_floor`) | Growth cap and planting floor |

**Output Range:** fit 0–1; growth ×0.24–1.2 (a fit of 0.833 is today's ×1.0). Labels (each band includes its lower bound):
excellent ≥ 0.8, good 0.6–0.8, fair 0.4–0.6, poor 0.2–0.4, unplantable below 0.2.

**Example:** Hỏa Linh Chi on a volcano (T_i 70, tol 15; R_i 40, tol 20; place Fire 60, T 80, R 20, D 1.1): every factor 1,
fit **1.0 (excellent)**, growth ×1.2. On a glacier: f_e 0.3, f_T 0, **unplantable** ("temperature 5, needs 55–85").
Thanh Tâm Liên in a temperate forest (Water 30; R 50 against R_i 70, tol 15): f_e 0.825, f_R 0.833, fit **0.69 (good)**,
growth ×0.83.

**As built (2026-11-20, user-approved calibration):** the climate indexes are centred on the continent (T 0 at −10 °C
and 100 at 40 °C; R 0 at 0 mm and 100 at 1,600 mm; `world_map.json` `climate_index`), `elem_full_share` is 25 (15 for a
variant) instead of 40 and 20, and the herbs' first-guess bands are wider (rarity 1–2 tolerate 25 either side, rarity
3–5 tolerate 20), so a common herb on an ordinary home grows about as before (fit 0.65–0.95) while matched ground still
pays up to ×1.2. A herb already planted keeps growing at g_max × fit below the plant floor. At the GDD's s_full 40 a
typical place (a fifth of the herb's element) gave f_e 0.65 and the first Foundation pill came about 1.5 times later.

### H. Production (rule 21)

The production formula is defined as:

`production[s,k] = round(base_output[s,k] · min(R_f · W_f · D_f · S_f · G_f, prod_mult_cap))`; `base_output[s,k] = site_grade_value[grade] · kind_value_mult[k] / unit_value[k]`

with `R_f` the reserve factor (I), `W_f = settle_w · owner_w`, `D_f = clamp(1 + demand_elasticity · (price_index − 1), demand_min, demand_max)`, `S_f = clamp(q_now / q_gen, 0, scar_max)` and `G_f = 1 + min(perm_prod, perm_prod_cap) + min(upkept_prod, upkept_prod_cap)`. `round` is half up with a 1e-6 tolerance (Character Stats' grid rule), so 9,103.4999… rounds to 9,104.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| site_grade_value | int | 2,500 / 10,000 / 40,000 (small / medium / large) | data file *(guess)* | Linh-thạch-equivalent output a season at all factors 1 |
| kind_value_mult | float | linh thạch 1.0; ores 0.5; herbs 0.4; beasts 0.4; special 0.2 | data file *(guess)* | Non-currency sites are worth less than mines |
| unit_value | int | 1–120 | data file (Item DB values) | Linh thạch 1 (the currency itself; the ore stays a by-product); ores 15–60; herb 10 *(guess)*; Yêu Đan 40; Lôi Kích Mộc 120 |
| settle_w | float | none 0.5, village 0.7, town / market 0.85, city 1.0 | data file *(guess)* | Labour near the site |
| owner_w | float | worked 1.0, rested 0.1, wild 0.5 | data file *(guess)* | A holder works it, rests it, or scavengers pick at it |
| price_index | float | > 0, **default 1.0** | calculated by Regional Economy & Trade (#43) | Hook: 1.0 until #43 exists, so D_f is 1 |
| demand_elasticity; demand_min, demand_max | float | 0.5; 0.75, 1.25 | data file *(guess)* | Price drives extraction, bounded |
| q_now / q_gen | float | ≥ 0 | calculated | Scar: density for linh thạch and herbs, the element share for ores, read on layers 4 and 2 (so a shared work can revive a dead vein); 1 for beasts and special goods |
| scar_max | float | 1.5 | data file *(guess)* | A favourable scar adds at most half |
| perm_prod, upkept_prod; caps | float | 0.03 / 0.10 per level; 0.15 / 0.50 | data file | Works (J) |
| prod_mult_cap | float | 2.0 | data file *(guess)* | Caps the product of the factors |

**Output Range:** 0 to 2 × base_output; 0 only when a scar kills the source.

**Example:** a medium linh thạch mine (10,000) near a town (W_f 0.85, worked), reserve 0.55 (R_f 0.85), D_f 1, S_f 1,
vein dressing level 2 and worked mine level 2 (G_f 1.26): 0.85 × 0.85 × 1.26 = 0.910, so **9,104 linh thạch** a season.

### I. Reserves (rule 22)

The reserve_factor formula is defined as:

`R_f = 1.0` if r ≥ 0.80; `0.70 + 0.30 · (r − 0.30) / 0.50` if 0.30 ≤ r < 0.80; `0.25 + 0.45 · (r − floor) / (0.30 − floor)` if r < 0.30

The reserve_update formula is defined as:

`reserve' = clamp(reserve − max(0, E − S) + recover_rate · reserve_max · max(0, 1 − E / S), reserve_floor · reserve_max, reserve_max)` with `E = production`, `S = sustain_frac · base_output`, `reserve_max = reserve_seasons · base_output`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| r | float | floor–1.0 | calculated | reserve / reserve_max; bands rich > 0.80, worked 0.30–0.80, thinned < 0.30 |
| reserve_floor | float | 0.10 | data file *(guess)* | Over-mining never takes it lower |
| sustain_frac | float | 0.70 | data file *(guess)* | Extraction at or below this does not thin the reserve |
| reserve_seasons | int | 60 | data file *(guess)* | Reserve size in seasons of base output |
| recover_rate | float | ores and linh thạch 0.01; herbs 0.04; beasts 0.03 | data file *(guess)* | Share of the max regained per fully rested season |
| reserve (start) | float | 0.85–1.0 of max | data file *(guess)* | History can start some sites thinned |

**Output Range:** R_f 0.25–1.0, continuous. Reserves settle where R_f · W_f = 0.70: a city-worked mine near r 0.30
(the worked/thinned edge), a town's near 0.50, villages and wild sites rich; high prices push city mines into thinned.

**Example:** the mine in H (reserve_max 600,000, reserve 330,000, S 7,000, E 9,104) drains 2,104 a season and settles
near r 0.28 after about 50 years (r 0.32 at 29 years; 0.279 at the limit). A wild mine at the floor (60,000; E 625) recovers 0.01 × 600,000 × 0.911 = **5,464** a
season: worked again in about 22 seasons, rich in about 75.

### J. Works on the land (rules 31–32)

| Layer | Kind | Work | Gain per level | Max | Cost of level L (linh thạch) | Seasons | Materials | Upkeep per level per season | Fade |
|---|---|---|---|---|---|---|---|---|---|
| 2 | permanent | Spirit grove (linh lâm) | density +0.02 | 5 (+0.10) | 2,000 · 2^(L−1) | L | L units, rarity ≥ 2 | — | never |
| 2 | permanent | Qi channel (dẫn linh cừ) | +2 share points to a chosen element | 5 (+10) | 2,000 · 2^(L−1) | L | L units of that element, rarity ≥ 2 | — | never |
| 2 | permanent | Vein dressing | production +3 % | 5 (+15 %) | 2,000 · 2^(L−1) | L | L units, rarity ≥ 2 | — | never |
| 2 | upkept | Sect gathering array (đại tụ linh trận) | density +0.10 | 5 (+0.50) | 3,000 · 2.5^(L−1) | 1 | L units, rarity ≥ 3 | 125 | −1 level per 2 unpaid seasons |
| 2 | upkept | Worked mine (khai khoáng) | production +10 % | 5 (+50 %) | 1,000 · 2^(L−1) | 1 | — | 3 % of the site's base value | −1 level per 2 unpaid seasons |
| 1 | permanent | Tended abode (dưỡng động phủ) | density +0.02 | 3 (+0.06) | 300 · 2^(L−1) | L | L units, rarity ≥ 2 | — | never; stays with the place if left |
| 1 | permanent | Private spring (linh tuyền) | +2 share points to a chosen element | 3 (+6) | 300 · 2^(L−1) | L | L units, rarity ≥ 2 | — | never |
| 1 | upkept | Tụ Linh Trận (built) | density +0.15 | 5 (+2 with capability #15) | 150 · 2.5^(L−1) | 1 | L units, rarity ≥ 2 | 2.5 (today 10 a year); the two capability #15 levels cost double, as built | −1 level per 4 unpaid seasons (today −1 a year) |
| 1 | upkept | Element-focusing array (tụ nguyên trận) | +4 share points to a chosen element | 5 (+20) | 200 · 2.5^(L−1) | 1 | L units of that element, rarity ≥ 2 | 3 | −1 level per 4 unpaid seasons |

All values but Tụ Linh Trận are *(guess)*.

The work_cost formula is defined as: `work_cost_lt(L) = cost_lt · cost_growth^(L−1)`; `work_materials(L) = materials_per_level · L`; `work_seasons(L) = seasons_per_level · L` for permanent works, 1 for upkept ones

The work_gain formula is defined as: `gain[layer, stat] = min(Σ per_level · level, layer_cap[layer, stat])` (the caps of B)

The upkeep formula is defined as: `upkeep_season = Σ_works level · upkeep_per_level_season · (1 − clamp(tho_purity · tho_upkeep_cut_per_purity, 0, 0.9)) + carry` (the Earth discount on layer 1 only; `carry` holds the fraction so seasonal billing matches today's yearly integer)

The fade formula is defined as: `level' = level − 1` on every `fade_seasons`-th consecutive unpaid season; the count resets on payment; an unpayable bill drops the costliest work per level first, as `formations.gd` does today

The element_push formula is defined as: Δs points added to the chosen element's share (B: not renormalised)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cost_lt, cost_growth | int, float | the table | data file (`map_works.json`; Tụ Linh in `crafting_formations.json`) | Build curve |
| per_level, layer_cap | float | the table; B | data file | Gain and cap |
| upkeep_per_level_season | float | 2.5–125 | data file | Tụ Linh: today's 10 a year ÷ 4 |
| fade_seasons | int | layer 1: 4; layer 2: 2 | data file | Layer 1 matches today; layer 2 *(guess)* |
| tho_upkeep_cut_per_purity | float | 0.004 | data file (built) | Earth root discount |

**Output Range:** layer 2 density +0.60 (0.10 permanent, 0.50 upkept); layer 1 +0.81, +1.11 with capability #15;
element push up to 36 points (layer 2 permanent 10; layer 1 permanent 6 and upkept 20); production up to +65 %. **World bound on permanent works:** at most +0.10 density per
place (+0.16 at a home) and +15 % production; maxing one place's layer 2 density costs 62,000 linh thạch and 15
seasons, and doing it everywhere about 25 years of the world's whole mine output, so in practice only sect seats and
famous sites get there.

**Example:** Tụ Linh Trận level 2 costs 375 linh thạch for +0.30 density; upkeep 5 a season (20 a year, as today), 3.5
with Earth 75. A home at 1.0 reaches 1.4 at level 3 (1.45), as today. A sect array to level 5 costs **193,313 linh thạch**
for +0.50 and 625 a season in upkeep: a sect seat at 1.0 reaches 1.5, enough for every member's Core Formation.

### K. Teleport fee (rule 11)

The teleport_fee formula is defined as:

`teleport_fee = round(linh_thach_max[realm] · min(fee_base_frac + fee_per_tile_frac · d, fee_frac_max) · owner_mult)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| linh_thach_max | int | 80 / 600 / 5,000 / 40,000 / 300,000 | data file (`events_budgets.json`) | The traveller's realm budget (realm-scaled: user decision 2026-11-10) |
| d | int | 0 to about 650 | calculated | Straight-line tiles between the arrays |
| fee_base_frac, fee_per_tile_frac, fee_frac_max | float | 0.05, 0.0005, 0.30 | data file *(guess)* | Fixed part, distance part (per 25 km tile), cap |
| owner_mult | float | 1.0 default; 0.5–3 | Sects (#26) | Member discount or outsider surcharge |

**Output Range:** 5–30 % of the realm's `linh_thach_max` (the cap binds past 500 tiles, about 12,300 km): 4–24 linh
thạch at Qi Refining, 15,000–90,000 at Deity Transformation.

**Example:** a Core Formation cultivator jumping 450 tiles pays 5,000 × 0.275 = **1,375** (about two seasons of mission
income, to save about 8 seasons on the road). A Qi Refining one jumping 180 tiles pays 80 × 0.14 = **11**.

### L. The seasonal production contract (rule 25)

The aggregation formula is defined as:

`qty[region,k] = Σ_{s in region} production[s,k]`; `value_lt = qty · unit_value[k]`; `territory[k]` sums the held regions' sites and any held sites outside them; each site counts once

**Region record** `map_production_region` (once a season, about 20 × 9 entries): `contract_version` (2; was 1 before Trade Goods, 2026-11-15), `season_index`,
`region_id`, `holder_id` (sect id, "" for wild), `pop_cultivators[5]` (heads by realm, from the Living World Tick),
`pop_settlement_weight` (city 8, town 4, market 3, village 1 *(guess)*), and `production` per kind: `qty`, `value_lt`,
`sites`, `reserve_mean` (weighted by base output), `bands` {rich, worked, thinned}, `top_rarity` (1–6),
`by_element` (herbs only), `demand_factor_used` (echoes D_f so #43 can audit its loop).
**`by_good`** (contract v2, amended 2026-11-15 by Trade Goods Open Question 14): per kind, each named good's part of
`value_lt`, split per site by Trade Goods Formula A (largest remainder, integer arithmetic) and summed over the
region's sites, so the parts sum to `value_lt` exactly and #43's supply is unchanged. Each site keeps **`rem[s,g]`**,
the value of each good below one whole unit (`V_g`), and adds it to the next season's part before units are counted,
so a rare good at a modest site yields a unit every few seasons instead of never (Trade Goods rule 6). `unit_value[k]`
is then only a value-to-count conversion for the kind.

**Territory record** `map_production_territory`: `contract_version`, `season_index`, `sect_id`, `region_ids[]`,
`extra_site_ids[]`, `pop_cultivators[5]`, `pop_settlement_weight`, `production` (as above), `works_upkeep_due_lt`
(layer 2 upkeep, for Sects). The World Database keeps the last 8 seasons *(guess)*.

**Scale check:** today's faucets (missions and stipends over 5,000 cultivators, a quarter of seasons worked *(guess)*)
create about 137,000 linh thạch a season. Seventeen linh thạch mines (10 small, 5 medium, 2 large *(guess)*) at typical
factors produce about **124,000 a season**, within 10 %. The mine scale holds only while today's wages hold; if #43
changes them, re-derive `site_grade_value`. Whether mine output adds money or replaces the mission faucet is #43's
decision (Open Questions).

### M. Developed ground, settled homes and where NPCs live (rules 33–34)

The prebuilt_works formula is defined as: `ΔD2u_start[place] = prebuilt_density[kind]`, in place at game start and upkept by the holder

The settled_caps formula is defined as: for a home inside a settlement or sect ground, `D ≤ settled_density_cap` (replacing D_cap of B). There is no settled match cap (user decision 2026-11-13)

The rent formula is defined as: `rent_season = round(linh_thach_max[realm] · rent_frac · quality)`; `price = rent_season · buy_seasons`; `quality = D_residence / core_density_min`

The npc_home formula is defined as: settled with probability `npc_settled_share` (sect members at their seat; others by `settle_weight`), at grade `min(realm_index + 1, max_grade[kind])` (`realm_index` 0 at Qi Refining); otherwise a random pick among the top `npc_wild_pick_top[realm]` of free tiles (an occupied small blessed land is not free) in the NPC's region ranked by `D · M` for its root

The abode_cost formula is defined as: `abode_cost = round(linh_thach_max[realm] · abode_cost_frac)`, `abode_cost_frac` 0.05 *(guess)*, and opening takes one season (rule 8; user decision 2026-11-10). Example: 250 linh thạch at Core Formation.

The furnishing formula is defined as: `ΔD1_furnish = furnish_per_grade · grade`, a fixed layer 1 work that comes with the residence, within the settled density cap

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| prebuilt_density | float | village 0.10, town 0.20, market 0.25, city 0.30, sect seat 0.40 | data file *(guess)* | Layer 2 upkept works at game start |
| settled_density_cap | float | 1.8 | data file *(guess)* | A settled home's density stays below an own base's (3.0) and a blessed land's. `settled_match_cap` (×1.3) is removed (user decision 2026-11-13) |
| linh_thach_max | int | 80 / 600 / 5,000 / 40,000 / 300,000 | data file (`events_budgets.json`) | The renter's realm budget |
| rent_frac, buy_seasons | float, int | 0.02, 40 | data file *(guess)* | Rent share and purchase multiple |
| D_residence | float | 0.6–1.8 | calculated (B) | The residence's stacked density |
| npc_settled_share | float | 0.85 | data file (user decision) | Share of NPCs living in settlements and sect grounds |
| settle_weight | int | city 8, town 4, market 3, village 1 | data file *(guess)* | How settled NPCs spread |
| npc_wild_pick_top | float | QR 0.25, FE 0.15, CF 0.08, NS 0.04, DT 0.02 | data file (0.25 user decision; the realm ladder a guess) | Outside NPCs pick among the best share of spots for their root in their region; narrower and better as realm rises |
| grade, max_grade | int | 1–5; village 2, town 3, market and city 4, sect seat 5 | calculated; data file *(guess)* | Residence grade; the best a place kind offers |
| furnish_per_grade | float | 0.05 | data file *(guess)* | Layer 1 density a residence's furnishing adds per grade |
| grade_realm_min | int | grade 4 Core Formation, grade 5 Nascent Soul | data file *(guess)* | Least realm to rent or buy the top grades |

**Output Range:** a settled home reaches at most density 1.8, and its match is as good as its land and works; rent 1.2–3.6 % of the realm budget a
season. A city at land density 1.0 sits at about 1.3 with its works, just short of Core Formation; a sect seat at 1.0
reaches 1.4, so members can form their Core there. High-realm NPCs now sit on better ground, so they cultivate faster
late in life; that shifts how many reach Nascent Soul and Hóa Thần (about 27 and 3), which Realms' bot re-run measures.

**Example:** a Core Formation renter of a courtyard at stacked density 1.54 (quality 1.1) pays 5,000 × 0.02 × 1.1 =
**110 a season**, or **4,400** to buy.

## Edge Cases

**Land and layers**
- **If a stacked value passes its cap** (density 3.0, the settled density cap, or any layer's own cap): it is clamped. The stat block
  shows the clamp as its own line, so the lost part is visible.
- **If a root has no element or variant the land holds** (an Ice root far from any glacier): its match is about ×1.0
  everywhere, not a penalty. The lows come only from high purity on land with none of its elements.
- **If a place's owner changes** (rule 26): its layer 2 permanent works stay with the land. Its upkept works pass to the
  new holder, who must pay the upkeep or let them fade.
- **If a character moves home:** the old home's works stop counting for them at once, and its upkept works stop being
  billed and start fading. Its permanent works stay with the place for whoever finds or claims it.
- **If two characters want a home on a small blessed land** (room for one): the second is refused while the first
  holds it. Large blessed lands have no such limit.
- **If the ground under a rented home changes hands** (a territory change, or the holder sells it): the renter keeps the
  home until the season ends; then the new holder's terms apply.
- **If a cave abode is opened inside a sect's territory:** it is allowed here. Whether the sect objects, taxes it or
  drives the owner off is for Sects (#26).
- **If a battle scar zeroes a vein** (scar factor 0): the vein produces nothing. The reserve floor protects only
  against over-mining, not scars. Resting cannot revive a dead vein; only a later event or a work that raises the
  density can.
- **If a site is mined at its reserve floor:** output stays at its floor rate (×0.25) and the reserve stays at the floor.
- **If a herb's place falls below its planting floor after planting** (a scar, or a fading work): the planted herb keeps
  growing at `1.2 × fit`, however small. Only new planting is refused, and nothing already planted is destroyed.

**Travel**
- **If no route exists for the character's modes** (an island with no port before Foundation Establishment, or a sea
  crossing on foot): the trip is refused, and the screen says what is missing (a port, a ship or flight).
- **If `travel_speed_pct` is very negative:** speed never drops below a quarter of base (`travel_speed_floor`).
- **If a character asks to keep to one part of a tile whose mix they don't know:** it is refused for that tile, which
  is crossed by its mix (rule 13).
- **If an encounter interrupts a trip:** the character stands on the tile reached. The time spent counts, and once the
  encounter resolves (unless it ends the trip: death, capture, flight back) the trip continues from there. A stretch
  draws at most one encounter.
- **If a flier meets an encounter mid-flight:** the fight reads the pool as it is at that tile, after the drain so far.
- **If the teleport array's owner refuses the character** (Sects decides who may use it): the jump is refused and the
  fee is not charged.
- **If a trip ends partway through a season:** the rest of that season cultivates at the destination's rate (Formulas
  D). Realms' season-start rate rule needs an exception for this (Open Questions).

**Knowing and finding**
- **If a clue is false:** searching its area never succeeds. The engine knows this and never shows it; the cultivator
  simply finds nothing, and can stop at any time.
- **If someone else has already discovered the hidden place:** it is no longer hidden from the world, but it is still
  Unknown to this character, and searching finds it as before (or anyone who knows can tell them).
- **If a tile holds a secret and a hidden place together:** each rolls separately on arrival and in searches.
- **If a character is inside a secret realm when it closes:** the secret realm's own rules decide (Event Engine). By
  default the character is thrown out to its entrance tile.
- **If a character is told a secret that is false:** it is recorded as told, and it gives nothing, because the tile
  holds no such secret.

**The map build**
- **If the map misses a target:** the map check lists each miss with the tiles and places behind it. It never changes
  the map itself; the designer repaints or retunes the data and builds again.
- **If an inhabited island has no port:** the map check lists it, and the designer adds one.
- **If a biome patch is too small to have a heart** (every cell within one step of an edge): all its cells are edge
  cells and get no signature push. That's correct: a lone grove isn't a deep forest.
- **If no biome reaches 10 % of a tile** (seven or more biomes among its 16 cells): the largest is kept alone, at 100.
  Ties are broken by the biome's order in rule 2.
- **If sea covers exactly half a tile:** it is a sea tile (rule 2).
- **If a repaint folds away the part a place sits in:** the place moves to the tile's largest part, and the map check
  lists it.
- **If a hand correction on a tile disagrees with its cells** (a tile set to Fire 80 whose cells compute otherwise): the
  correction wins for the tile and each of its parts, and the map check lists it.
- **If a feature is painted on unlikely ground** (a lava flow in tundra): its push applies as painted, and the map
  check lists it as unusual so it's a choice, not an accident.
- **If a hand correction sits on a tile whose computed value later changes** (the paint around it moved): the
  correction still wins, and the map check lists it so it can be reviewed.
- **If a battle scar hits a tile:** the scar adds on top of the computed land, so nothing is recomputed.

## Dependencies

**Upstream (this system needs these)**

| System | Type | Interface | State |
|---|---|---|---|
| World Generation & History (#27) | Hard | The authored history and the per-game rolls (hidden-place spots, reserves, random NPCs) | Built as a generator, no GDD; **provisional: to be reworked for the fixed world** |
| World Database (#3) | Hard | Storage for places, regions, discoveries, scars, ownership, homes, works, known maps and secrets | Built, no GDD |
| Time & Turn (#4) | Hard | Seasons, and the share of a season a trip uses | Built, no GDD; **provisional** (the leftover-season rule) |
| Config (#1), Sim Core (#2), Save/Load (#5) | Hard | `world_map.json`, `map_resources.json`, `map_works.json`; seeded streams for the per-game rolls; saving the seed and the changes | Built, no GDD |
| Spiritual Roots (#6) | Hard | Purities, owned and road-raised, for the element match | GDD in review; **no row for this system yet** |
| Character Stats (#7) | Hard | `travel_speed_pct`, divine sense, realm, `density_bonus` | GDD in review; lists this system |
| Sects & Missions (#26) | Soft | Who holds regions, sites and arrays; who may rent or use them; tax and conflict | GDD designed 2026-11-14 (`design/gdd/sects.md`), pending re-review |
| Formations (#17) | Soft | Gathering formations as works on layers 1 and 2 | Quick spec only |
| Event Engine (#23) | Soft | Encounters, clue items, secret realm openings, scars | Built, no GDD |

**Downstream (these need this system)**

| System | Type | Interface | State |
|---|---|---|---|
| Realms & Bottlenecks (#8) | Hard | Stacked density and match for the cultivation rate; the Core Formation density check; the leftover-season rate | GDD in review; lists this system (its rows need the layer stack and the match) |
| Spirit Herbs & Fields (#14) | Hard | Herb fit at the field's place | Built, no GDD |
| Regional Economy & Trade (#43) | Hard | The seasonal production contract; the demand hook (`price_index`) | GDD designed 2026-11-14 (`design/gdd/regional-economy-trade.md`), in review; it reads the contract and writes `price_index` per region (its local price). Trade Goods (#45, 2026-11-14) splits each site's `value_lt` among named goods (contract v2 `by_good`, Trade Goods Formula A); `unit_value[k]` becomes only a value-to-count conversion |
| Trade Goods (#45) | Soft | Reads site kinds, biomes, features, density and herb fit; adds the `by_good` split to the production contract (v2, Formula L), the per-site `rem[s,g]` carry and gathered herb ages (rule 18, its Formula K) | Approved 2026-11-15 (design-review 12; `design/gdd/trade-goods.md`); its Open Question 14 amendments applied here 2026-11-15 |
| Market (#20) | Soft | Market places; regional production until #43 replaces it | Built, no GDD |
| Living World Tick (#28), NPC Builds (#24) | Hard | NPC homes (settled share, graded residences, hermit picks), reserves, cycles, fading works | Built, no GDD |
| Combat (#21) | Soft | Encounters on the way; a flier's pool on arrival | Approved; **no row for this system yet** |
| Item Database (#13) | Soft | Maps, jade slips and told secrets as clue items; resources mapped to materials and herbs | GDD in review; **no row for this system yet** |
| Quests (#31) | Soft | Places, arrival, travel time | Approved; lists this system |
| Heavenly Tribulation (#22) | Soft | Ground tags (biome, element shares) | Approved for rules; lists this system |
| Đạo Đồ (#10) / Effects (#41) | Soft | Capabilities #8 (travel cultivates) and #21 (Blink Mark) act on travel | In review / approved; Đạo Đồ lists it |
| Debug Terminal (#36), Game UI (#37), Guidance (#35) | Soft | The map, stat blocks with each layer's line, the known map, herb fit lines | Terminal built |
| Balance Harness (#33) | Hard | Map targets on the one map; the Realms re-run with the uncapped match | Built, no GDD |
| Map build and map check (new tool) | Hard | Index images (fine map and tiles) to the stored map: tile mixes (rule 2) and Formulas C; map targets | Prototype generator: `tools/design/map/continent_gen.py` |

**Bidirectional check.** Realms, Character Stats, Quests, Heavenly Tribulation and the Đạo Đồ list this system.
**Spiritual Roots, Combat and the Item Database do not**, so a back-reference row is added to each when this GDD is
finished (with the user's approval). Realms' existing rows also need wording for the layer stack and the match.

## Visual/Audio Requirements

- **The terminal map, built first:** the tile grid drawn in characters, one glyph and colour per tile from its main
  biome (`^` mountains, `~` water, `,` grass, `"` jungle, `.` desert and so on), a mixed tile's glyph drawn dimmer, with
  named places as letters and roads as `=` or `-`. Only tiles the character knows are drawn; unknown land is blank. A
  legend lists the glyphs.
- **The Game UI map, later**, has two views (user decision 2026-11-13; `design/research/fixed-world-decisions.md`):
  - **Overview: an AI-generated painting** of the whole continent, about 3–4k px. It is guided by the index images so
    the coasts, ranges and rivers line up with the tiles, and generated late, once the geography settles; a plain
    render stands in until then. Only permanent landmarks are painted in. Political borders, cities, sects and
    markers are overlays, so territory changes show.
  - **Zoomed-in view: rendered.** A ground shader draws the land from the fine map's index images (about 6 km a
    cell), so coasts, rivers and biome patches have detail inside a tile: blended biome edges, hillshade, coast lines
    and a paper texture. Stamps (mountains, forests, towns, sites) are placed by rules from the
    same depth and feature fields as the qi, then hand-fixed. Deep jungle draws a denser, darker canopy and ground near
    lava glows, so good ground reads at a glance. There is no permanent grid; the tile under the cursor, routes and
    search areas show when needed. The knowledge mask applies only here: unknown land is blank paper.
  - The two views **crossfade** at the zoom threshold and share one palette and one paper texture.
  - The **style is open**, and the art bible decides it. The candidates (pixel or tile art, painted parchment,
    ink-wash) are demoed in `prototypes/map-style-demos`. A pixel style would draw the zoomed-in view with autotiles
    instead of a ground shader.
  - Whatever the style, each biome must read at a glance, and an optional **qi overlay** shows density (as mist or
    shading) and each element as a faint tint, so a Fire-rich region reads warm. A blessed land stands out in the
    overlay, and a tile secret never shows unless known.
  - The overview painting and any AI-made stamps are declared in Steam's pre-generated AI content disclosure.
- **Moments worth marking:** finding a hidden place or a secret (ink spreads outward from the tile in the zoomed-in
  view, with a short sound cue), a secret realm opening (a visible ripple, plus rumour text), and a battle scar (the
  tile's look changes for good).
- **Audio** follows the biome in the Game UI: wind on steppe and highland, rain in jungle, quiet in a blessed land.
  There's no audio in the terminal.

## Game Feel

- **Distance should feel real, never tedious.** One command plans and starts a trip, and the screen shows the route,
  its length in seasons, the danger along it and the encounter chance before the player commits. The player never
  walks tile by tile on a road; only off-road search and wilderness crossing go stretch by stretch.
- **Discovery should feel earned:** a clue narrows the search, the search takes visible seasons, and the find is a
  marked moment that is recorded in the world's history.
- **Choosing ground should feel like build-craft:** the stat block shows *your* match, *your* density and each layer's
  line, so moving a home is a decision with numbers behind it, like picking a node on the Đạo Đồ. The land has
  gradients: the heart of a biome and the ground beside a feature are stronger, and riskier, than the edge, so the best
  spot for a root is a specific place worth the journey.
- **Response targets:** the map view renders in under 100 ms; planning a route (pathfinding over the grid) returns in
  under 200 ms for any two points on the continent.

## UI Requirements

- **`map`:** the known map around the character at region zoom, and the overview at continent zoom (the whole
  continent, famous places, cities, sect seats, and borders: live for the major powers, as last heard for minor
  ones), each with its legend.
- **`place <name>`** (also `here`): the stat block (rule 7) with a line per layer (land, blessed land or secret, shared
  works, home works), the land line broken into its steps (the tile's mix and the place's part, depth, blending, each
  feature, any hand correction), the clamp line when a cap binds, and the character's own match and density.
- **`route <place>`** (or a tile): every route available with the character's modes, each with seasons, danger,
  encounter chance and teleport fee, and a confirm step before starting. On known mixed tiles the player may keep to
  one part (rule 13), and the route's numbers update.
- **`search`:** the active clue's area, the chance per season, and seasons spent so far. A false clue is never marked.
- **`fit <herb>`:** herb fit at the current place or the home, with each factor's line and the label.
- **`homes`:** residences for rent or sale in the current settlement, by grade, with price, rent, the realm needed and
  the stacked values each would give.
- **`works`:** the works on the home and on places the character holds, with level, upkeep, fade state and caps.
- **`region`:** the region's holder, production by resource (the contract record, rule 25) and reserve bands.
- **Debug only:** a view that shows the true map, hidden places and secrets, for testing.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Pillars 2, 4 and 5; the anti-pillar on world simulation (clarified when this GDD is finished); the visual identity ("Ink and Ledger" names ink-wash; the map style is now open, Visual/Audio). Its world-generation lines predate the fixed world and are still to be updated |
| `design/research/fixed-world-decisions.md` | The fixed world, the two-view map, what a character sees, terrain-driven qi and the removed match caps (user decisions 2026-11-12 and 2026-11-13) |
| `design/gdd/canh-gioi.md` | Formulas I (rate × density × match), the Core Formation condition (`core_density_min`), rule 3 (the season-start rate; the leftover-season exception), Open Question 23 (the recalibration) |
| `design/gdd/linh-can.md` | Rules 8 and 8a and Formulas G: purities, owned and road-raised; unowned purity counts at half weight in the match |
| `design/gdd/character-stats.md` | `travel_speed_pct`; divine sense (Formulas C); `density_bonus` (tree and items only) |
| `design/gdd/combat.md`, `combat-defence.md` | Encounters on the way; the linh lực pool a flier arrives with |
| `design/gdd/item-database.md` | Maps, jade slips and told secrets as clue items; material and herb values; the `linh_thach_max` ladder (`events_budgets.json`) |
| `design/gdd/quests.md`, `thien-kiep.md` | Travel time for visit stages; ground tags |
| `design/gdd/dao-do.md`, `effects.md` | Capabilities #8 (travel cultivates), #15 (formation levels) and #21 (Blink Mark) |
| `design/quick-specs/luyen-khi-and-tran-phap.md` | Tụ Linh Trận: cost, +0.15 per level, upkeep (kept, now a layer 1 upkept work) |
| `design/gdd/systems-index.md` | #43 Regional Economy & Trade (the contract's reader), #26 Sects, #17 Formations, #37 Game UI (art style open) |
| `assets/data/world_generation.json`, `crafting_formations.json`, `items_herbs.json` | Replaced travel keys; formation upkeep becomes seasonal; new herb climate keys |
| `src/gameplay/world/world_generator.gd`, `world_db.gd`, `src/gameplay/session/game_session.gd` (travel), `formations.gd`, `market.gd`, the terminal views | Code the rework touches |

## Acceptance Criteria

Drafted by `qa-lead`, 2026-11-10, after the user's rulings on the first draft. Nothing has run. Values marked *(guess)*
in Formulas are tested at their data-file values, so a retune changes the expected number, not the test. Every random
draw comes from a seeded stream: Logic tests inject rolls (FX-TM-RNG), and Harness tests run on the shipped map
(FX-TM-MAP), using the fixed seed list (FX-TM-SEEDS) for the per-game rolls. Default tolerance ±0.001 on floats; integers exact. `round` is half up with a 1e-6 tolerance.

Evidence: `tests/unit/travel_map/`, `tests/integration/travel_map/`, `production/qa/evidence/balance/` (harness runs),
`production/qa/evidence/debug-terminal/` (UI screenshots, retained), `production/qa/smoke-[date].md` (Config/Data).

**Fixtures.**

- **FX-TM-DATA:** the shipped `world_map.json`, `map_resources.json`, `map_works.json`, `crafting_formations.json` and
  `events_budgets.json` at the Formulas defaults.
- **FX-TM-MU:** injected world means: each base `mu_e` 0.20, `mu_Ice` 0.01, other variants 0. Hand-built maps use these
  instead of computing them.
- **FX-TM-MINI:** a hand-built small map using FX-TM-MU:
  - **VOL** volcano beside a lava flow: Fire 60, Earth 30, Metal 10; T 80, R 20; D4 1.10. It holds a small blessed land (ΔD3 0.40, Fire
    push +40).
  - **LAKE** lake shore: Water 60, Wood 40; D4 1.30.
  - **GLA** glacier: Water 100, Ice 40 (variant); T 5.
  - **FOR** temperate forest: Wood 70, Water 30; R 50, T inside Thanh Tâm Liên's band. A spring secret (H 300) sits on
    the next tile.
  - **TOWN** (on grassland): a road of 36 grassland tiles (danger 1) runs from it to a junction. From the junction, 14
    jungle wilderness tiles (danger 2) lead to LAKE.
  - **MIX**: a wilderness tile whose 16 cells are 9 grassland (danger 1), 4 high mountain (danger 3), 2 desert and 1
    jungle.
  - **CITY**, **MARKET**, **VILLAGE** and **SEAT** (sect seat), each at land density 1.00.
  - **ISL**: an island with a village and no port. Port auto-add is off in this fixture.
  - **WILD1**: an empty wilderness tile.
- **FX-TM-ROOT-F:** Wood 40, Fire 86, Water 10, all owned. **FX-TM-ROOT-ICE:** Ice 50, owned. **FX-TM-ROOT-5:** all five
  base elements at 40, owned. **FX-TM-ROOT-FU:** Fire 86 from rare sources only (`u` 0.5).
- **FX-TM-FE:** Foundation Establishment, `travel_speed_pct` +20, DS 135, has a flying artifact. **FX-TM-CF:** Core
  Formation, tsp 0, DS 450. **FX-TM-NS:** Nascent Soul, DS 1,350.
- **FX-TM-MINE:** a medium linh thạch mine (base 10,000) near a town (W_f 0.85), worked. Reserve 330,000 of 600,000.
  Vein dressing level 2, worked mine level 2. price_index 1.0, no scar.
- **FX-TM-WMINE:** the same grade of mine, wild, with no settlement (W_f 0.5 × 0.5). Reserve 60,000 (the floor).
- **FX-TM-HERB:** Hỏa Linh Chi (Fire; T 70 ±15; R 40 ±20; D_need 0). Thanh Tâm Liên (Water; T band containing FOR's T;
  R 70 ±15; D_need 0). An Ice herb (s_full 20).
- **FX-TM-REALM:** a secret realm with cycle 40 seasons, open 2 seasons, rumour lead 4 seasons.
- **FX-TM-SCAR:** a scripted Event Engine event above the scar threshold that sets one tile's density to 0 (a dead
  vein) or pushes Fire +30 (a crater).
- **FX-TM-RNG:** an injected roll stream. It returns scripted values in order and records every roll.
- **FX-TM-MAP:** the shipped map: its index images and hand corrections, built by the map build at the Formulas
  defaults.
- **FX-TM-GRID:** two hand-painted test grids at the Formulas defaults, built with `fine_factor` 1 and a cell of 111 km
  (so 555 km of depth is 5 steps, a 222 km blend is 2 and a 555 km reach is 5), with jungle Wood 50, Water 30, Fire 20 (push 25,
  g_D +0.2, g_X +1, base danger 2), grassland Wood 50, Earth 50 (no signature) and volcano Fire 45, Earth 40, Metal 15:
  - **G1**, 15 × 15: grassland, with a jungle block over rows and columns 2–12 whose column 12 is bamboo (signature
    Wood). Tiles are named (row, column).
  - **G2**, 11 × 11: all volcano, with one lava-flow tile at the centre (Fire +60, R 5) and one ice-field tile in a
    corner (Ice +40, R 2).
- **FX-TM-SEEDS:** 100 fixed game seeds for the per-game rolls (hidden-place spots, reserves, NPCs), stored as test
  data.
- **FX-TM-WORLD:** FX-TM-MAP with FX-TM-SEEDS[0] and 5,000 cultivators, after 40 seasons of the Living World Tick.

### Land and layers

- **AC-TM-01** [Logic] Rule 1. GIVEN FX-TM-MAP, WHEN the map is built twice in fresh processes, THEN both tile dumps are
  byte-identical: elevation, temperature, rainfall, each tile's mix and main biome, features, river flag, and each
  part's depth, density, danger, shares and variants.
- **AC-TM-02** [Config/Data] Rule 1. GIVEN fine images of 2,160 × 1,440 and `fine_factor` 4, THEN the grid has 540 × 360 =
  194,400 tiles of 16 cells. GIVEN fine images of 1,080 × 720 with no code change, THEN the grid has 48,600 tiles.
- **AC-TM-03** [Logic] Rule 1. GIVEN FX-TM-MAP, THEN the map check lists 0 river tiles lower than the next tile
  downstream, and every river ends at sea, a lake or the map edge.
- **AC-TM-04** [Config/Data] Rule 2. GIVEN FX-TM-DATA, THEN 19 biomes are listed, with no Coast and no Lake and river
  valley. Each has a base profile summing to 100, a base density, a danger of 1–4, a climate band, and a signature
  element or none, with its push and depth bonuses. The base densities equal Formulas C (sea 0.5 … volcano 1.1), and the volcano is Fire 45, Earth 40, Metal 15.
- **AC-TM-05** [Logic] Rule 3. GIVEN every tile and every part of FX-TM-MINI, FX-TM-GRID and FX-TM-MAP, THEN the base
  shares sum to 100. Variant shares sit outside the 100.
- **AC-TM-06** [Logic] Rule 4, Formula C. GIVEN G2, THEN the Fire share is **65.625** on the lava tile, **59.559** two
  tiles away and **45.000** five or more tiles away, and the base shares sum to 100 on every tile. Ice is 40 on the
  ice-field tile, 20 one tile away and 0 two tiles away, outside the 100.
- **AC-TM-07** [Harness] Rule 4. GIVEN FX-TM-MAP, THEN each variant appears only within reach of its own feature:
  - Ice near an ice field or above the snowline;
  - Thunder at storm peaks;
  - Wind on high plateaus;
  - Light at sacred summits;
  - Darkness at deep caves, karst cores or miasma sources.

  Each variant is in at most 2 % of places (`variant_place_share_max`).
- **AC-TM-139** [Logic] Rule 3, depth. GIVEN G1, THEN d is 6 and t 1.00 at (7,7), and d 1 and t 0 at (2,7). At (7,11),
  d is 2 and t 0.25, because the bamboo in column 12 shares jungle's signature and the grassland in column 13 does not.
- **AC-TM-140** [Logic] Formula C, own profile. GIVEN G1, THEN P at (7,7) is Wood 60, Water 24, Fire 16, and P at (2,7)
  is the jungle base (Wood 50, Water 30, Fire 20).
- **AC-TM-141** [Logic] Formula C, blending. GIVEN G1, THEN each tile's B equals the mean of P over its 5 × 5 window,
  computed independently. Earth is 0 at (7,7) and above 0 at (2,7), and Wood never falls from (2,7) to (7,7) along
  column 7.
- **AC-TM-142** [Logic] Formula C, density and danger. GIVEN G1's wilderness tiles, THEN D4 is 1.20 and danger 3 at
  (7,7), and D4 1.00 and danger 2 at (2,7).
- **AC-TM-143** [Logic] Rule 1, hand corrections. GIVEN a hand correction setting a tile to Fire 80, Earth 20, WHEN the
  map is rebuilt after the paint around it changes, THEN the tile still reads Fire 80, Earth 20, its stat block shows a
  "set by hand" line, and the map check lists the tile.
- **AC-TM-144** [Logic] Rule 3, stat block. GIVEN a G2 tile two steps from the lava flow, THEN its land line lists the
  biome profile, depth (none), blending and "Lava flow 2 tiles away: Fire +36" as separate lines.
- **AC-TM-146** [Logic] Rule 2, the mix. GIVEN MIX, THEN its mix is grassland 60, high mountain 27, desert 13 (jungle at
  6.25 % is folded into grassland), its main biome is grassland, and the shares sum to 100. GIVEN cells 6 / 4 / 3 / 3 of
  four biomes, THEN three are kept (the tie goes to the earlier biome in rule 2) as 46 / 31 / 23. GIVEN 8 sea and 8
  grassland cells, THEN the tile is sea; GIVEN 7 sea and 9 grassland, THEN it is a land tile, grassland 56, sea 44.
- **AC-TM-147** [Logic] Formula C, parts. GIVEN a tile whose grassland cells average D 0.80 and whose jungle cells average
  D 1.20, with mix grassland 60, jungle 40, THEN the parts read 0.80 and 1.20, the tile reads **0.96**, and a valley
  place in the jungle part reads 1.20 plus its kind's offset.
- **AC-TM-148** [Logic] Formula D, a mixed tile. GIVEN tsp 0, THEN wilderness on MIX's kept parts (grassland 60, high
  mountain 27, desert 13) costs 0.60 × 1.0 + 0.27 × 2.5 + 0.13 × 1.5 = **1.470** per tile; keeping to the grassland
  costs 1.0 and to the mountain 2.5. A tile of grassland 56, sea 44 costs 1.0.
- **AC-TM-149** [Logic] Formula E, rule 13, a mixed tile. GIVEN a tile with parts at danger 1 (60 %) and 3 (40 %), THEN
  its hazard is **0.370** a season. GIVEN FX-TM-RNG rolls of 0.59 and 0.61 for the encounter's biome, THEN they pick the
  first part and the second. A character keeping to the second part uses hazard 0.70 and its biome, with no roll.
- **AC-TM-150** [Harness] Rule 2, FX-TM-MAP. Every tile's mix has 1–3 parts, each at least 10 %, summing to 100; its
  main biome is its largest part, or sea when sea covers half its cells or more; each tile value equals the
  share-weighted mean of its land parts (Formula C); and every river cell of the fine map lies on a tile with the river
  flag.
- **AC-TM-08** [Logic] Formula A, rule 5. GIVEN FX-TM-ROOT-F, WHEN M4 is computed at VOL, THEN it is **1.244**.
- **AC-TM-09** [Logic] Formula A. GIVEN FX-TM-ROOT-F at LAKE, THEN M4 is **0.948**.
- **AC-TM-10** [Logic] Formula A. GIVEN FX-TM-ROOT-ICE at GLA, THEN M4 is **1.195**.
- **AC-TM-11** [Logic] Formula A, bounds. GIVEN an owned Fire 200 root, THEN M4 at VOL is **1.800** (no ceiling) and at
  LAKE is 0.800 (raw 0.6, the floor).
- **AC-TM-12** [Logic] Formula A, `u_e`. GIVEN FX-TM-ROOT-FU at VOL, THEN M4 is 1.172.
- **AC-TM-13** [Logic] Formula A. GIVEN FX-TM-ROOT-5, THEN M4 is 1.000 at every FX-TM-MINI place with no variant share.
- **AC-TM-14** [Logic] Edge (a root with none of the land's elements). GIVEN FX-TM-ROOT-ICE at VOL (Ice 0), THEN M4 is
  0.995, not a penalty down to the floor.
- **AC-TM-15** [Logic] Formula A, `mu_e`. GIVEN FX-TM-MAP, THEN each `mu_e` equals the mean of
  `s_e/100` over its places. The base `mu_e` sum to 1.000. A later scar does not change any `mu_e`.
- **AC-TM-16** [Harness] Rule 5. GIVEN FX-TM-MAP and 200 fixed random roots, THEN the mean M4 over all places is
  1.00–1.03 (the floor lifts it slightly; the bot run confirms the band).
- **AC-TM-17** [Logic] Formula B, density. GIVEN LAKE (1.30) with a sect upkept array (+0.30) and Tụ Linh Trận level 2
  (+0.30), THEN D is **1.90**.
- **AC-TM-18** [Logic] Formula B, match. GIVEN FX-TM-ROOT-F at VOL with the small blessed land (layer 3, Fire +40) and
  an element-focusing array (tụ nguyên trận) at level 5 on Fire (layer 1, +20), THEN:
  - layer 3 adds 0.300 (raw 0.344);
  - layer 1 adds 0.150 (raw 0.172);
  - M is **1.694**; no stack cap cuts it (user decision 2026-11-13).
- **AC-TM-19** [Logic] Formula B, layer caps. GIVEN each input over its cap, THEN only the cap counts:
  - ΔD3 1.5 counts 1.00;
  - ΔD2p 0.25 counts 0.10;
  - ΔD2u 0.8 counts 0.50;
  - ΔD1p 0.3 counts 0.10;
  - ΔD1u 0.9 counts 0.75, or 0.90 with capability #15 (cap 1.05).
- **AC-TM-20** [Logic] Formula B, D_cap. GIVEN a secret realm at 2.2 with Tụ Linh Trận level 5, THEN D is 2.95. With
  capability #15 at level 7, THEN D is 3.00, not 3.25.
- **AC-TM-21** [Logic] Formula B, no renormalising. GIVEN VOL with a level-5 qi channel on Fire, THEN the shares read
  Fire 70, Earth 30, Metal 10 (sum 110). Herb fit reads Fire 70.
- **AC-TM-22** [Logic] Formula B, M_min. GIVEN M4 0.800 and no pushes, THEN M is 0.800. GIVEN any pushes, M never falls
  below M4.
- **AC-TM-23** [Logic] Rule 27, per character. GIVEN two characters on the same tile, where only A has a home work
  there, THEN A's D includes ΔD1 and B's does not. Layers 4–2 are equal for both.

### Places

- **AC-TM-24** [Harness] Rule 6. GIVEN FX-TM-MAP, THEN the map has 200–300 places and 18–22 regions. Every place
  kind in rule 6 appears at least once.
- **AC-TM-25** [Logic] Rule 6, Formula E `d_t`. GIVEN a town on jungle (base danger 2), THEN its danger is 1. GIVEN a
  village on grassland (danger 1), THEN it stays 1.
- **AC-TM-26** [Logic] Rule 6. GIVEN CITY and MARKET, THEN each offers trade. GIVEN TOWN, VILLAGE and a wild site, THEN
  none offers trade.
- **AC-TM-27** [Logic] Rule 7. GIVEN VOL, WHEN its stat block is read back from the World Database, THEN it holds
  every field in this list, and each equals the built value:
  - the tile's mix and the place's part, temperature, rainfall, density;
  - shares and variants, danger;
  - settlement size, resources, herb fit;
  - owner, features;
  - the land line's steps: biome, depth, blending and each feature.
- **AC-TM-28** [Logic] Rule 8. GIVEN a character whose home is TOWN, WHEN they open a cave abode on WILD1, THEN:
  - a cave abode place exists on WILD1 with WILD1's terrain;
  - the character owns it, and it is their home;
  - a fact is recorded;
  - TOWN is no longer their home.
- **AC-TM-29** [Logic] Rule 8, Formula M `abode_cost`. Opening an abode takes 1 season. It costs 250 linh thạch at
  Core Formation, 30 at Foundation Establishment and 4 at Qi Refining. GIVEN less money than the cost, THEN the opening
  is refused and nothing is charged.
- **AC-TM-30** [Logic] Rule 8, Edge. Opening an abode is refused on a tile that holds a place, and on sea. It is
  allowed inside a sect's territory. An abode the character has left stays on the map as a place. GIVEN MIX, THEN the
  opening asks for a part, and an abode opened in the high mountain part reads that part's density and shares.

### Travel

- **AC-TM-31** [Logic] Rule 9. GIVEN FX-TM-MINI:
  - THEN a boat trip is offered only between river places;
  - a ship trip only between ports;
  - and no foot route crosses sea.
- **AC-TM-32** [Logic] Edge (no route). GIVEN a Qi Refining character at TOWN, WHEN a trip to ISL is asked for, THEN it
  is refused, and the message names the missing port, ship or flight. GIVEN FX-TM-FE, THEN the trip is offered by
  flight.
- **AC-TM-33** [Logic] Formula D, road cost. GIVEN tsp 0:
  - a road on jungle costs 1.25 per tile;
  - a road on high mountain costs 1.375;
  - wilderness on high mountain costs 2.5;
  - flight costs 1.0 on any biome.
- **AC-TM-34** [Logic] Rule 10, Formula D. GIVEN tsp 0:
  - 80 river tiles downstream take 1.000 season, and 45 upstream take 1.000;
  - 90 sea tiles take 1.000;
  - 135 flight tiles at FE take 1.000.

  Flight speed is 200 at Core Formation, 290 at Nascent Soul and 400 at Deity Transformation.
- **AC-TM-35** [Logic] Rule 10. Flight is refused below Foundation Establishment, and at Foundation Establishment
  without a flying artifact.
- **AC-TM-36** [Logic] Formula D. GIVEN FX-TM-FE from TOWN to LAKE (36 grassland road tiles, then 14 jungle wilderness
  tiles), THEN:
  - T is **1.852** (0.556 + 1.296);
  - u is 0.852;
  - gain_last is **0.148 × rate_dest**.
- **AC-TM-37** [Logic] Formula D, flight drain. GIVEN FX-TM-FE flying 50 tiles, THEN T is 0.309 and the pool arrives
  at **0.815** of max. Over 50 glacier tiles, T is the same.
- **AC-TM-38** [Logic] Formula D, `f_min`, Edge. GIVEN 54 grassland road tiles at tsp −75 and at tsp −90, THEN each trip
  takes **4.000** seasons.
- **AC-TM-39** [Integration] Rule 12, Time & Turn. GIVEN the trip in AC-TM-36, THEN:
  - two season ends pass;
  - the character ages two seasons;
  - season 2 credits 0.148 of LAKE's rate (η 1.0).

  GIVEN the 0.309 flight, THEN the same season credits 0.691 of the destination rate.
- **AC-TM-40** [Logic] Formula K, rule 11:
  - a Core Formation traveller over d 450 pays **1,375**;
  - Qi Refining over d 180 pays **11**;
  - Deity Transformation over d 0 pays **15,000**;
  - Core Formation over d 450 with owner_mult 0.5 pays 688;
  - Core Formation over d 500 pays 1,500, and over d 800 also pays **1,500** (the 0.30 cap).
- **AC-TM-41** [Logic] Rule 11. A teleport jump takes 0.05 of a season, whatever the distance. tsp does not change it.
- **AC-TM-42** [Logic] Rule 11, Edge. GIVEN an array whose owner refuses the character, THEN no jump happens and no fee
  is taken.
- **AC-TM-43** [Integration] Rule 11. GIVEN the map active, THEN the existing Blink Mark (capability #21) tests pass
  unchanged.

### Encounters

- **AC-TM-44** [Logic] Formula E. GIVEN the trip in AC-TM-36, THEN P is **0.172** for stretch 1 and **0.258** for
  stretch 2. GIVEN the same trip flown, P is **0.0158**.
- **AC-TM-45** [Logic] Formula E. GIVEN one full wilderness season, THEN P is 0.1393, 0.2953, 0.5034 or 0.6988 at
  danger 1–4. One road season at danger 1 gives 0.0582.
- **AC-TM-46** [Logic] Formula E. GIVEN FX-TM-RNG scripted to pass every roll, THEN each stretch draws exactly one
  encounter.
- **AC-TM-47** [Integration] Rule 13, Event Engine. GIVEN a desert stretch, THEN the candidate list includes the
  sandstorm. On glacier it does not. A flight stretch never offers a ground-tagged event.
- **AC-TM-48** [Logic] Edge (interruption). GIVEN an encounter scripted on tile 5 of 11, THEN:
  - the character stands on tile 5, and the time spent counts;
  - after a win the trip resumes from tile 5;
  - after death, capture or flight back it does not resume.
- **AC-TM-49** [Logic] Edge (flier mid-flight). GIVEN FX-TM-FE meeting an encounter on flight tile 25 of 50, THEN the
  fight reads a pool of 0.907.
- **AC-TM-50** [Harness] Formula E. GIVEN 10,000 seeded full wilderness seasons at danger 2, THEN the encounter rate is
  0.295 ±0.01.

### Knowing and finding

- **AC-TM-51** [Logic] Rule 14. GIVEN a newly created character, THEN their zoomed-in map shows their origin's home
  region, every city and every road between cities, and nothing else. Their overview shows the whole continent, the
  famous places, every city and every sect seat.
- **AC-TM-145** [Logic] Rule 14, politics. GIVEN a major power and a minor holder each losing a region while the
  character is far away, THEN the overview shows the major power's new border at once, and the minor holder's old
  border until the character visits, hears news or buys a map.
- **AC-TM-52** [Logic] Formula F, radius. GIVEN DS 45, 135, 450, 1,350 and 6,525, THEN r is 3, 4, 8, 14 and 31. GIVEN DS
  10,935, THEN r is 36 (raw 40; the r_max cap).
- **AC-TM-53** [Logic] Rule 14. GIVEN a 40-tile straight path in open land, THEN every tile within Chebyshev distance r
  of the path becomes known, diagonals included, and no tile at r + 1 does. At FE (r 4) that is a band 9 tiles wide;
  at Core Formation (r 8), 17 wide. Known tiles beside the path show their main biome only; the tiles the path
  crossed show their full mix.
- **AC-TM-54** [Logic] States (place knowledge):
  - a rumour turns Unknown into Heard of (region shown, tile not);
  - a visit turns it into Known;
  - when a Known place's density changes after the visit, the old value shows until the next visit.
- **AC-TM-55** [Logic] Rule 14. GIVEN an NPC, THEN its known area is its region, and no per-tile known map is stored for
  it.
- **AC-TM-56** [Logic] Rule 15, Edge. GIVEN a hidden ruin, THEN no character's map, listing or stat query shows it.
  After A discovers it, it is still Unknown to B, and B's search can still find it.
- **AC-TM-57** [Integration] Rule 15, World Generation & History. GIVEN FX-TM-SEEDS, THEN in every game each hidden ruin
  or abode sits on one of its 2–4 hand-picked candidate tiles and links to a history fact (a dead cultivator or a
  vanished sect), and that figure's recorded abode tile holds the place. The same seed always picks the same tile.
  Over the 100 seeds every candidate is picked at least once. Famous places never move.
- **AC-TM-58** [Logic] Rule 16, Formula F `A`. GIVEN a region with 8,000 wilderness tiles, THEN a rumour's area is 1,600
  and a jade slip's is 400.
- **AC-TM-59** [Logic] Formula F, search. GIVEN FX-TM-CF, H 300, q 1.0 and cost-1 ground, THEN:
  - p_detect is 0.600, and the sweep is 306 tiles a season;
  - a jade slip gives **0.368** a season, and a rumour **0.108**.

  GIVEN FX-TM-FE (tsp +20) with a slip, THEN p_detect is 0.310, the sweep is 194.4 and the chance is **0.140**.
- **AC-TM-60** [Logic] Rule 16, Edge (false clue). GIVEN a false clue, THEN P_season is 0 in each of 1,000 seasons. No
  screen or exported field shows that the clue is false.
- **AC-TM-61** [Logic] Rule 17. GIVEN an exact map, WHEN the character arrives on its tile, THEN the place is found that
  season, and FX-TM-RNG records 0 rolls for it.
- **AC-TM-62** [Logic] Rule 17. GIVEN a discovery, THEN the World Database records finder, place and season. The place
  is Known on the finder's map only.
- **AC-TM-63** [Logic] Formula F, detect:
  - FX-TM-NS arriving on the spring has p_detect **0.818**;
  - FX-TM-FE searching that tile for one season has **0.672** (3 rolls);
  - flying over at FE has 0.155.
- **AC-TM-64** [Logic] Rule 29. GIVEN A has found the spring next to FOR and B has not, THEN A's match on that tile
  includes the spring and B's does not. After A tells B, B's match includes it too.
- **AC-TM-65** [Logic] Rule 30, States. A found or told secret never returns to unknown: not after leaving the tile,
  and not after save and load.
- **AC-TM-66** [Logic] Edge. GIVEN a told false secret, THEN it is recorded as told and adds 0. GIVEN a tile holding a
  secret and a hidden place, THEN arrival makes two separate rolls (FX-TM-RNG logs 2).
- **AC-TM-67** [Integration] Rule 30, Item Database. GIVEN a found secret sold as a clue item, WHEN the buyer uses it,
  THEN the buyer's state is told.
- **AC-TM-68** [Harness] Formula F. GIVEN 10,000 seeded Nascent Soul arrivals on the spring, THEN the find rate is
  0.818 ±0.01.

### What the land gives

- **AC-TM-69** [Logic] Formula G, rule 18. GIVEN Hỏa Linh Chi at VOL, THEN fit is **1.000**, the word is excellent and
  growth is ×1.20.
- **AC-TM-70** [Logic] Formula G. GIVEN Hỏa Linh Chi at GLA, THEN f_e is 0.3, f_T is 0, it is **unplantable**, and the
  reason line reads "temperature 5, needs 55–85".
- **AC-TM-71** [Logic] Formula G. GIVEN Thanh Tâm Liên at FOR, THEN f_e is 0.825, f_R is 0.833, fit is **0.688**
  (good) and growth is ×0.825.
- **AC-TM-72** [Logic] Formula G, `f_D`:
  - D_need 1.5 at D 1.2 gives 0.640;
  - D_need 1.5 at D 1.8 gives 1.000;
  - D_need 0 gives 1.000.

  For a variant herb, Ice 10 against s_full 20 gives f_e 0.650.

  (AC-TM-69 to AC-TM-72 hold on FX-TM-HERB's values, the GDD's s_full 40 and the bands above; the shipped data use the
  calibrated values in Formula G's "As built" note, so a test of them sets the fixture's values.)
- **AC-TM-73** [Logic] Formula G, labels (each band includes its lower bound):
  - fit 0.800 is excellent, and 0.7999 is good;
  - 0.600 is good, and 0.400 is fair;
  - 0.200 is poor and plantable, and 0.1999 is unplantable.
- **AC-TM-74** [Logic] Edge. GIVEN a herb planted at fit 0.5 whose place then falls to fit 0.1, THEN it keeps growing
  at ×0.12 and nothing is destroyed. New planting there is refused.
- **AC-TM-75** [Integration] Spirit Fields, Formulas B and G. GIVEN Thanh Tâm Liên at FOR with a level-3 private spring
  on Water (+6), THEN Spirit Fields reads f_e 0.930, fit 0.775 and growth ×0.930.
- **AC-TM-76** [Harness] Rule 18. GIVEN FX-TM-MAP, THEN every wild herb ground's fit for its herb is at least 0.6.
- **AC-TM-77** [Config/Data] Rule 19. GIVEN `map_resources.json`, THEN it lists about ten kinds: linh thạch, five ores,
  herbs by element, beast materials and special goods. Every mapped id exists in the Item Database, and the validator
  reports 0 dangling ids.
- **AC-TM-78** [Logic] Rules 15 and 20. GIVEN every resource site in FX-TM-WORLD, THEN each has reserve, base output
  and recovery rate, and its max reserve is one of its hand-set sizes. The start reserve is 0.85–1.0 of max, unless a
  history fact marks it thinned.
- **AC-TM-79** [Harness] Rule 20. GIVEN FX-TM-MAP, THEN every ore site yields its tile's top base element. Every linh
  thạch mine sits on land density 1.0 or more with Earth + Metal of 50 or more.
- **AC-TM-80** [Logic] Formula H. GIVEN FX-TM-MINE, THEN:
  - R_f is 0.85, W_f 0.85, G_f 1.26;
  - the factor product is 0.910;
  - production is **9,104**. The raw 9,103.4999… rounds up under the 1e-6 rule.
- **AC-TM-81** [Logic] Formula H, clean cases. GIVEN the FX-TM-MINE mine with every factor at 1, THEN production is
  10,000. A medium ore site (unit_value 30) at every factor 1 gives 167 (base 166.67).
- **AC-TM-82** [Logic] Formula H, caps:
  - price_index 1.0 gives D_f 1.00, and 1.4 gives 1.20;
  - price_index 0.2 gives 0.75, and 2.0 gives 1.25;
  - with R 1, W 1, D_f 1.25, S_f 1.5 and G_f 1.65, the product is capped at 2.0, giving 20,000.
- **AC-TM-83** [Logic] Formula H, rule 21:
  - S_f is 1.5 for q_now/q_gen 2.0, and 0 for a dead vein, which produces 0;
  - owner_w for a rested site is 0.1;
  - the four settle_w values match the data file.
- **AC-TM-84** [Logic] Formula I, R_f:
  - r 1.00 gives 1.000, 0.80 gives 1.000, and 0.55 gives 0.850;
  - 0.30 gives 0.700, 0.20 gives 0.475, and 0.10 gives 0.250;
  - R_f is continuous at 0.30 and 0.80.
- **AC-TM-85** [Logic] Formula I. GIVEN FX-TM-MINE, THEN after one season the reserve is **327,896**.
- **AC-TM-86** [Logic] Formula I. GIVEN FX-TM-WMINE, THEN E is 625, and after one season the reserve is **65,464.3**
  (±0.1).
- **AC-TM-87** [Logic] Formula I, Edge:
  - extraction at E = S (7,000) leaves the reserve unchanged;
  - a site over-mined at the floor stays at 60,000, at R_f 0.25.
- **AC-TM-88** [Logic] States (site bands). r 0.81 is rich, r 0.80 and r 0.30 are worked, and r 0.29 is thinned.
- **AC-TM-89** [Harness] Formula I. GIVEN FX-TM-MINE with no other change, THEN r is:
  - 0.32 ±0.01 after 116 seasons (29 years);
  - 0.28 ±0.005 after 200 seasons (50 years);
  - 0.279 ±0.002 after 400 seasons.

### Regions and territory

- **AC-TM-90** [Harness] Rule 23. GIVEN FX-TM-MAP, THEN each region is one connected set of land tiles, and every
  place is in exactly one region. At least 60 % of each region's border edges lie on mountain, river
  or coast.
- **AC-TM-91** [Logic] Rule 24. GIVEN an attempt to give a region or site to a non-sect, THEN it is rejected. The only
  places a loose cultivator owns are cave abodes. A region may have no holder.
- **AC-TM-92** [Logic] Formula L. GIVEN one region holding FX-TM-MINE (9,104) and FX-TM-WMINE (625), THEN linh thạch qty
  is 9,729 and value_lt is 9,729. An ore output of 167 at unit 30 gives value_lt 5,010.
- **AC-TM-93** [Logic] Formula L. GIVEN a sect holding region R1 plus a listed extra site inside R1, THEN that site
  counts once. An extra site outside R1 is added once.
- **AC-TM-94** [Integration] Rule 25, production contract. GIVEN FX-TM-WORLD, WHEN one season passes:
  - THEN every region has one `map_production_region` record with `contract_version` 2, `season_index`, `region_id`,
    `holder_id` ("" for wild), `pop_cultivators[5]` and `pop_settlement_weight`;
  - per kind, it has `qty`, `value_lt`, `sites`, `reserve_mean`, `bands`, `top_rarity`, `by_element` (herbs only),
    `by_good` (summing to `value_lt` exactly) and `demand_factor_used`, which is 1.0;
  - every holding sect has one `map_production_territory` record, with `works_upkeep_due_lt`;
  - `pop_cultivators` sums to the Living World Tick's head count for the region.
- **AC-TM-95** [Integration] Rule 25. GIVEN 9 seasons run, THEN the World Database holds seasons 2–9 only. GIVEN the map
  active, THEN the existing Market tests pass unchanged.

### Change

- **AC-TM-96** [Logic] Rule 26, States (secret realm cycle). GIVEN FX-TM-REALM, THEN:
  - it is Sealed, turns Announced 4 seasons before opening (a rumour event), Open for 2 seasons, then Sealed;
  - the next opening is 40 seasons after the last;
  - the entrance tile is the same in every cycle.
- **AC-TM-97** [Config/Data] Rule 26. GIVEN FX-TM-DATA, THEN every cycling secret realm has a cycle of 40–120 seasons,
  2–4 open seasons and a 4-season rumour lead.
- **AC-TM-98** [Logic] Edge. GIVEN a character inside when the realm closes, THEN by default they are placed on the
  entrance tile.
- **AC-TM-99** [Logic] Rule 26, Edge (owner change). GIVEN a site changing owner:
  - THEN its layer 2 permanent works stay;
  - its upkept works pass to the new holder;
  - unpaid, they drop 1 level per 2 seasons;
  - an ownership fact is recorded.
- **AC-TM-100** [Logic] Edge (ground under a rented home changes hands). GIVEN a home rented on that ground, THEN the
  renter keeps it to the season's end, and the new holder's terms apply from the next season.
- **AC-TM-101** [Logic] Rule 26 (scar). GIVEN FX-TM-SCAR (crater), THEN that tile's density and shares change, and the
  change is stored as a terrain change. A World Database fact is recorded. A hash of every other tile is unchanged.
- **AC-TM-102** [Logic] Edge (dead vein), Formula H `S_f`. GIVEN a vein killed by FX-TM-SCAR, THEN it produces 0 for 40
  rested seasons. A Tụ Linh Trận at a home on that tile (layer 1) leaves it at 0. A level-1 spirit grove (layer 2)
  makes it produce more than 0.
- **AC-TM-103** [Integration] Save/Load. GIVEN FX-TM-WORLD with:
  - scars, ownership changes and homes;
  - works and found secrets;
  - known maps and thinned reserves;

  WHEN it is saved and reloaded, THEN:
  - the state dump is byte-identical;
  - the next 4 seasons match a run that never reloaded;
  - the save holds the seed and the changes, and no terrain array.

### Developed ground and homes

- **AC-TM-104** [Logic] Formula J, rule 32 (Tụ Linh Trận keeps today's numbers). Level 2 costs 375 for +0.30. Level 3
  costs 938. A home at 1.00 reaches 1.30 at level 2 and **1.45** at level 3.
- **AC-TM-105** [Logic] Formula J, upkeep:
  - Tụ Linh Trận level 2 bills 5 a season, **20 a year**;
  - with Earth 75 it bills 3.5 a season, as integers summing to 14 over 4 seasons (carry), which equals today's 14;
  - with capability #15 at level 7, levels 6 and 7 cost double: 22.5 a season, 90 a year.
- **AC-TM-106** [Logic] Formula J, fade:
  - a layer-1 work keeps its level through 3 unpaid seasons and drops 1 level on the 4th;
  - a payment resets the count;
  - a layer-2 work drops on every 2nd unpaid season;
  - an unpayable bill drops the costliest work per level first.
- **AC-TM-107** [Logic] Formula J. An element-focusing array:
  - adds +4 share points per level, to a chosen element;
  - level 6 is refused (without capability #15);
  - level 5 costs 7,813;
  - upkeep is 15 a season at level 5, with no Earth discount;
  - it drops 1 level per 4 unpaid seasons.
- **AC-TM-108** [Logic] Formula J. A sect array taken to level 5 costs **193,313** in total, with upkeep 625 a season.
  A sect seat at 1.00 reaches 1.50.
- **AC-TM-109** [Logic] Formula J. A spirit grove taken to level 5 costs 62,000 over 15 seasons for +0.10. Level 6 is
  refused. Another permanent density work adds nothing past c2p 0.10.
- **AC-TM-110** [Logic] Rule 31. GIVEN two characters at SEAT, THEN both get its layer 2 works.
- **AC-TM-111** [Logic] Rule 32, Edge (moving home). GIVEN a home with a tended abode and Tụ Linh Trận:
  - away from home, the owner gets 0 from them;
  - a visitor at the home gets 0;
  - after a move, the old home's Tụ Linh Trận stops billing and starts fading at once;
  - the tended abode's +0.06 stays with the place for the next claimant.
- **AC-TM-112** [Logic] States (home). A home becomes left after a move and a ruin on the founder's death. A ruin may
  enter the hidden-place pool.
- **AC-TM-113** [Logic] Rule 28, Edge (blessed land):
  - GIVEN a small blessed land held as a home, THEN a second claim is refused;
  - on a large blessed land a second claim is accepted;
  - once found, layer 3 applies to everyone there.
- **AC-TM-114** [Harness] Rule 28. GIVEN FX-TM-MAP, THEN the map has:
  - 2–5 large blessed lands of 40–180 tiles each;
  - 10–30 small ones of 1 tile.

  Every ΔD3 is within the Formula B targets.
- **AC-TM-115** [Logic] Formula M, prebuilt works. At land density 1.00, CITY stacks to 1.30 (Core Formation fails)
  and SEAT to **1.40** (passes). Village prebuilt is 0.10, town 0.20 and market 0.25.
- **AC-TM-116** [Logic] Formula M, settled cap, rule 34. GIVEN a city residence whose stack reaches D 2.10 and M 1.45,
  THEN it reads D 1.80 and M 1.45: only density is capped. The same stack at an own base in the wilderness reads 2.10
  and 1.45.
- **AC-TM-117** [Logic] Formula M, rent:
  - a Core Formation renter at D_residence 1.54 pays **110** a season, or **4,400** to buy;
  - Nascent Soul at 1.80 pays 1,029.
- **AC-TM-118** [Logic] Formula M, grade (realm_index 0 at Qi Refining):
  - a Nascent Soul NPC in a village gets grade 2;
  - Qi Refining in a city gets grade 1;
  - Deity Transformation at a sect seat gets grade 5;
  - a player at FE renting grade 4 is refused, and at Core Formation is accepted;
  - grade 5 needs Nascent Soul.
- **AC-TM-119** [Logic] Formula M, rule 34:
  - a grade 3 furnishing adds +0.15 on layer 1, inside the settled density cap;
  - rent bills each season;
  - a purchase bills once and is never billed again;
  - the owner's own home works still obey the settled density cap.
- **AC-TM-120** [Harness] Rule 33. GIVEN FX-TM-WORLD:
  - the settled share is 0.85 ±0.02;
  - every sect member lives at their seat;
  - non-sect settled NPCs per settlement follow the 8/4/3/1 weights within ±10 % relative per kind;
  - every NPC living outside sits in its region's top `npc_wild_pick_top[realm]` of free tiles by D · M for its root
    (100 % pass);
  - no NPC is placed on a small blessed land another character holds.
- **AC-TM-121** [Harness] Formula A, rule 33. GIVEN FX-TM-WORLD, THEN settled NPCs' mean M is 0.98–1.03, and NPCs living
  outside average above 1.10; the exact band is set by the bot run (Open Question 4).
- **AC-TM-122** [Integration] Realms. GIVEN FX-TM-ROOT-F at the AC-TM-18 stack with D 1.90, THEN Realms' rate there
  divided by its rate at D 1.0, M 1.0 is 1.90 × 1.694 = **3.219**.
- **AC-TM-123** [Integration] Realms (Core Formation check). GIVEN LAKE (1.30), THEN the Core Formation condition
  fails. GIVEN the AC-TM-17 stack (1.90), THEN it passes. The boundary works as follows:
  - D 1.400 passes, and 1.399 fails;
  - Tụ Linh Trận counts once, as ΔD1u: building level 3 raises `density_bonus` by 0, and raises D by 0.45, not 0.90;
  - `density_bonus` from the tree and items counts once.
- **AC-TM-124** [Harness] The Realms bot re-run with the match in holds the NPC targets: 1 in 8 / 12 / 15 / 20. Realms
  owns the numbers. This GDD blocks on the run.
- **AC-TM-125** [Integration] Quests and Heavenly Tribulation. A Quests `visit` stage's travel time equals Formula D's T
  for the same route. Tribulation reads the biome and stacked shares of the place where it happens.

### Map targets [Harness], FX-TM-MAP

- **AC-TM-126** Formula C:
  - the share of places at D ≥ 1.4 is 15–21 %;
  - mean place density is 1.05–1.20;
  - each base `mu_e` is 0.15–0.25;
  - each variant is in at most 2 % of places;
  - every base element has at least 8 places where its share is 50 or more, spread over at least 3 regions.
- **AC-TM-127** Formula C:
  - wilderness land tiles at D ≥ 1.4 are 3–5 %, and at least 70 % of them are veins, vein neighbours or tiles at full
    depth in a biome of base density 1.0 or more;
  - the worked example gives **1.45**, **1.65** beside a vein and **1.25** at the edge;
  - the clamps give 0.30 and 2.40.
- **AC-TM-128** Edge (the map build):
  - the map check lists 0 inhabited islands without a port;
  - every settlement reaches every other by some mode at FE;
  - a forced miss (target set to 50–60 %) makes the map check list the miss with the places behind it, and the built
    map is unchanged;
  - unusual features and stale hand corrections are listed, and the result is identical on a rerun.

### UI [UI], Debug Terminal, retained screenshots in `production/qa/evidence/debug-terminal/`

- **AC-TM-129** `map`. GIVEN a character with a Heard-of place and a hidden ruin nearby, THEN the screenshot shows the
  known map at region zoom and the overview at continent zoom, each with its legend. At region zoom, unknown tiles and
  the hidden ruin are not shown; the overview shows the whole continent, its famous places, cities and sect seats.
- **AC-TM-130** `place <name>` and `here`. GIVEN FX-TM-ROOT-F at VOL with the AC-TM-18 stack, THEN the screenshot
  shows:
  - every rule 7 field;
  - one line per layer (land, blessed land or secret, shared works, home works);
  - no clamp line, since no cap binds (the old −0.094 stack-cap line is gone);
  - the character's own D and M.

  `here` shows the same block. GIVEN the AC-TM-116 city residence, THEN a clamp line reads −0.30 on D, and there
  is no clamp line on M.
- **AC-TM-131** `route <place>`. GIVEN FX-TM-FE at TOWN, THEN the screenshot lists each route with seasons, danger,
  encounter chance and any teleport fee. Nothing starts before the confirm step. GIVEN ISL as the target for a Qi
  Refining character, THEN the refusal line is shown.
- **AC-TM-132** `search`. GIVEN an active jade slip, THEN the screenshot shows the area, the chance per season and the
  seasons spent. GIVEN a false clue, THEN the screen looks the same as for a true one.
- **AC-TM-133** `fit <herb>`. GIVEN Hỏa Linh Chi at GLA and Thanh Tâm Liên at FOR, THEN the screenshots show the fit,
  the label and one line per factor, including "temperature 5, needs 55–85".
- **AC-TM-134** `homes`. GIVEN CITY, THEN the screenshot lists residences by grade, with price, rent, the realm needed
  and the stacked values each would give.
- **AC-TM-135** `works`. GIVEN a home with Tụ Linh Trận unpaid for 2 seasons, THEN the screenshot shows its level,
  upkeep, the fade state (2 of 4 seasons) and its cap.
- **AC-TM-136** `region`. GIVEN FX-TM-WORLD, THEN the screenshot shows the holder, production per resource matching the
  contract record, and the reserve bands.
- **AC-TM-137** Debug true map. GIVEN the debug build, THEN the view shows hidden places and secrets. GIVEN a release
  build, THEN the command is not available.

### Performance [Harness], all numbers are PROPOSALS

- **AC-TM-138** On the reference PC (to be named), headless, with FX-TM-WORLD (540 × 360 tiles on a 2,160 × 1,440 fine
  map, about 250 places, 5,000 cultivators):
  - the map build (tile mixes and Formulas C over every fine cell, offline) takes ≤ 60 s;
  - the seasonal map update (reserves, cycles, fades, ownership, contract records, NPC home moves) has a mean ≤ 20 ms
    and p95 ≤ 50 ms over 400 seasons;
  - the stacked D · M for all 5,000 cultivators takes ≤ 10 ms a season;
  - one route query across the full grid takes ≤ 50 ms;
  - after 400 seasons the save's map delta is ≤ 500 KB, and a load including the stored map takes ≤ 3 s.

Blocked on other GDDs:
- AC-TM-39 waits on Realms (the leftover-season exception).
- AC-TM-124 waits on Realms (the bot re-run with the match).
- AC-TM-37 and AC-TM-49 wait on Combat (pool refill) for flights longer than one season.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Money supply: does mine output add to the mission and stipend faucets, or replace them?~~ **Answered 2026-11-14 (user decision, Regional Economy & Trade rule 5):** mine output **replaces** the mission faucet. Mines are the only source of new money; missions, stipends, tribute and taxes only move it between holders, and stone cultivation is the main sink. `site_grade_value` stays as is unless #43's harness run moves the money balance | — | — |
| 2 | Does the linh lực pool refill at each season start? Flight drain assumes so | Combat | Before the travel build |
| 3 | Realms' season-start rate rule needs an exception for the leftover share of a travel season | Realms | With its Open Question 23 |
| 4 | Realms' bot re-run with the match, settled and hermit NPCs and graded homes: do the player edge and the NPC targets (1 in 8 / 12 / 15 / 20; about 27 Nascent Soul, about 3 Hóa Thần) hold, now that the match has no ceiling and no stack cap? | Realms, Balance Harness | Before the map's numbers are approved |
| 5 | Scar threshold and size: which events may scar the land, and by how much | Event Engine (budgets) | Event Engine GDD |
| 6 | Capability #8 (travel seasons cultivate) under travel with leftover seasons | Đạo Đồ, Effects | Đạo Đồ content pass |
| 7 | Should `stealth` lower the encounter chance (a factor on `m_mode`)? | user | Before the travel build |
| 8 | ~~Each herb's climate band, and a pill-supply re-check with linear herb fit~~ **Answered in part 2026-11-20:** first-guess bands in `items_herbs.json` and the Formula G calibration (user-approved; Formula G "As built"); the pill re-check on the continent is in `production/qa/evidence/continent-world/05-balance.txt`: the rare-herb pills still limit the later gates, to tune later (user decision) | content, Spirit Herbs | Rare-herb pill tuning |
| 9 | ~~The move from today's region-and-place graph~~ **Done 2026-11-20:** places keep the graph's record shapes (links with Formula D times), so Market, Sects, Spirit Fields and Events run unchanged; travel and the balance bot use the tile path | programming | Done |
| 10 | The map build pipeline (index image formats, the map build and map check tools, how hand corrections and candidate spots are stored): a technical decision → becomes an ADR | technical-director | `/create-architecture` |
| 11 | The Game UI map's art style (pixel/tile, parchment, ink-wash) and the game concept's "Ink and Ledger". The two-view split (painted overview, rendered zoomed-in view) is decided | art-director, user | `/art-bible` |
| 12 | Every number marked *(guess)* is set by the bot run, map targets first. The signature pushes, feature strengths and reaches, and depth bonuses are set once the continent is painted | systems-designer, bot | Balance Harness run |
| 13 | ~~World Generation & History (#27) for the fixed world~~ **Done 2026-11-20:** see #27's Core Rules (implemented) | user, narrative-director | Done |
| 14 | Formula C's missed targets: Fire's world mean 0.144 and few places at a 50 share of one element, against the 222 km blend radius. Lower the target, shorten the blend, or raise the signature pushes? | user, systems-designer | Next map pass |
| 15 | A secret realm's density: its inside, set per realm, or its gate tile's land (the gates of Thiết Mã Cảnh and Vạn Cốt Trủng read the wasteland's 0.4; the kind offset +0.71 lifts them) | user | Before secret realms are entered |
| 16 | Two authored slot candidates sit on named caves (R-3 on Tàng Trập Động, S-10 on Huyền Minh Động), so an annal naming the cave points at the hidden place (World Generation AC-WG-06) | world-builder | History data pass |
