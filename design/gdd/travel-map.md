# Travel & Map (Bản Đồ & Hành Trình)

> **Status**: Designed (pending review; design-system 2026-11-10, lean mode: CD-GDD-ALIGN skipped, specialists consulted for Formulas and Acceptance Criteria)
> **Author**: user + Claude
> **Last Updated**: 2026-11-10
> **Last Verified**: 2026-11-10
> **Implements Pillar**: Pillar 5 (A World That Remembers), Pillar 4 (Every Season Counts); touches Pillar 1 (Your Dao, Your Name) and Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Travel & Map is the generated world the cultivator lives in: one continent with seas and islands on a tile grid,
twenty biomes, about 20 regions and 150–250 places, each with its own qi density and element shares. Where you live and
travel matters to your build: matching ground cultivates faster, herbs grow only where they fit, and four layers (the
land, blessed lands and secrets, shared works, your own home works) decide what a place gives *you*. It also owns
travel, discovery by clues, resource sites and the seasonal production contract that the economy and sects build on.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `World Generation, World Database, Time & Turn, Spiritual Roots, Character Stats; soft: Realms & Bottlenecks, Sects & Missions, Formations, Event Engine, Regional Economy & Trade`

## Overview

Travel & Map is the world the cultivator lives in and moves through. At world creation the game generates one
continent with its coasts, seas and island chains, the way Dwarf Fortress does. The generator lays out a grid of
tiles, and from each tile's elevation, temperature and rainfall it derives a biome (jungle, desert, volcano, swamp,
glacier and the rest), rivers, and the land's spiritual qi: the density (linh khí) and how much of each element (and
variant) the ground holds. On top of that terrain sit about 20 regions and 150–250 named places (towns, markets,
mountains, valleys, lakes, islands, spirit veins, mines, sect seats, and the hidden ruins, caves and secret realms
that the world's history left behind).

Places are the stops, joined by roads, rivers and sea lanes. Leaving the road means crossing wilderness tile by
tile, which is slower and more dangerous, and it is how a cultivator follows a clue to a hidden place.

Where you are matters to your build. A root cultivates faster on ground that matches its elements, a herb grows only
where its climate and element allow, and Core Formation needs a place dense enough in qi. Distance costs seasons
(Pillar 4), and every place, road and discovery is a recorded fact the world remembers (Pillar 5).

Each region produces resources: linh thạch from its mines, herbs, ores, beasts. It also needs some, and a sect, a
kingdom or nobody controls it. This GDD owns what the map produces and where. Market and Sects build prices, trade,
income and conflict on that contract.

The terrain is generated once and stays fixed. Anything that changes (mine output, a region's supply, who holds a
territory) is worked out per region once a season, so 5,000 cultivators stay cheap to simulate.

Without this system, a root's elements and a herb's needs would never meet the land, and the world would be a list of
names rather than a place.

## Detailed Design

### Core Rules

**The land**

1. **One generated world.** At world creation the generator builds a grid of tiles (the size is a data value, about
   120 × 80) holding one continent, its coasts, the seas and island chains. Each tile gets an elevation, a temperature
   and a rainfall, and from them a biome. Rivers run downhill from the rainfall. The grid comes from the world seed and
   never changes, so a save stores the seed and the changes, not the terrain.
2. **Twenty biomes.** Each biome has a base element profile, a base density, a base danger and its climate. The
   profiles below are first guesses, kept in data.

   | Biome | Hán-Việt | Leans toward |
   |---|---|---|
   | Temperate forest | rừng ôn đới | Wood, Water |
   | Bamboo forest | rừng trúc | Wood, Metal |
   | Jungle | rừng rậm nhiệt đới | Wood, Water, Fire |
   | Grassland | thảo nguyên | Wood, Earth |
   | Steppe | đồng cỏ khô | Earth, Metal (Wind) |
   | Desert | sa mạc | Earth, Fire, Metal |
   | Salt flats | bãi muối | Metal, Water, Earth |
   | Badlands | đất cằn | Earth, Metal |
   | Swamp | đầm lầy | Water, Wood (Darkness) |
   | Mangrove | rừng ngập mặn | Water, Wood |
   | Highland | cao nguyên | Earth (Wind) |
   | High mountain | núi cao | Metal, Earth (Thunder on storm peaks) |
   | Karst peaks | núi đá vôi | Earth, Metal, Water |
   | Volcano | hỏa sơn | Fire, Earth, Metal |
   | Tundra | đồng băng | Water, Earth (Ice) |
   | Glacier | băng nguyên | Water (Ice) |
   | Miasma wasteland | tử địa | Darkness, Earth; low density, high danger |
   | Coast | bờ biển | Water, Earth (Wind) |
   | Lake and river valley | thung lũng sông hồ | Water, Wood |
   | Sea | biển | Water |

3. **Qi has two parts.** **Density** (linh khí) says how much qi the ground holds. The **element shares** say what kind
   it is, five base shares summing to 100 (a volcano might be Fire 60, Earth 30, Metal 10). A tile starts from its
   biome's profile and density, and local features shift both: a spirit vein (linh mạch) raises density, and a
   lava vent pushes Fire up. Today's meaning of density is unchanged, so Realms' Core Formation rule still reads it
   (density at least `core_density_min` 1.4, about 18 % of places).
4. **Variant qi in special terrain.** A few features carry a variant share as well: Ice on glaciers and tundra, Thunder
   on storm peaks, Wind on high plateaus and steppe, Light on sacred summits, Darkness in deep caves and miasma.
   These features are rare (each variant in at most 2 % of places, `variant_place_share_max`), so a variant root has
   only a few prized homes.
5. **The ground sets the cultivation rate.** Cultivating at a place multiplies the rate by the place's density, as it
   does today, and by an **element match**: how well the root's purities fit the place's shares and variants. Matching
   ground speeds cultivation and mismatched ground slows it, within a bounded range (about ×0.8 to ×1.3) for the land
   itself that averages about ×1.0 over the world, so Realms' calibration holds; the higher layers can lift it
   further, up to the stack's cap (rule 27). The formula is in Formulas.

**Places**

6. **Named places sit on tiles.** About 150–250 places across about 20 regions. A place reads its tile's terrain, and its
   kind adds to it. The kinds:
   - **settlements:** city (thành), town (trấn), market (phường thị), village (thôn);
   - **wild sites:** mountain (sơn), valley (cốc), lake (hồ), forest (lâm), island (đảo);
   - **special sites:** spirit vein, mine (khoáng mạch), sect seat, secret realm (bí cảnh), ruin (di tích) and cave
     abode (động phủ).

   A settlement lowers danger, and cities and markets have trade (towns and villages do not, as built).
7. **Every place shows its stat block** (Pillar 2): biome; climate (temperature and rainfall); density; element shares
   and any variant; danger; settlement size; resources and herb fit; owner (a sect, a kingdom or none); and features
   (river, coast, vein). Every value is stored, inspectable and recorded in the World Database.
8. **A cave abode can be opened anywhere on land.** On a wilderness tile that holds no place, a cultivator may open a
   cave abode. It becomes a new place with that tile's terrain, owned by its founder and recorded as a fact. The
   cultivator's home (where their fields and formations sit) is one place at a time. An abode left behind stays on the
   map as a place others can find. The price is the tile's danger and its distance from markets, and opening one
   takes one season and a small fee (Formulas M; user decision 2026-11-10). Who may object on owned land is for Sects (#26).

**Moving**

9. **Four kinds of route.** Roads join places. Rivers carry boats between river places. Sea lanes carry ships between
   ports (coastal settlements). The **wilderness** is everything else, crossed tile by tile.
10. **Speed is tiles per season.** Each mode has a speed, slowed by terrain: road about 12, wilderness about 4 (less in
    mountains, swamps and jungle), boats and ships faster along their lanes. **Flight** opens at Foundation
    Establishment on a flying artifact. It ignores terrain and roads, and it is faster at higher realms (about 30 tiles
    a season and up). It drains linh lực per tile, so a flier may arrive with a low pool. `travel_speed_pct` applies to
    every mode. The numbers are in Formulas.
11. **Teleport arrays** (truyền tống trận) join some great cities. Sects own them and charge a fee in linh thạch that
    grows with distance, and a jump takes 0.05 of a season. The owner decides who may use one (Sects #26). Capability
    #21 (Blink Mark) still works as today.
12. **Travel uses part of a season.** A trip's length is a fraction of a season. A short hop leaves the rest of the
    season free, and the cultivator can cultivate at the destination at a reduced rate (in Formulas). A long trip runs
    over several seasons and ages the character like any other. An encounter can interrupt a trip.
13. **Danger on the way.** Each stretch of travel can draw an encounter from the Event Engine. The chance depends on
    the tiles' danger and the mode: roads are safer, the wilderness is riskier, and flight avoids ground encounters but
    not everything. The biome filters which events can happen (a sandstorm needs a desert).

**Knowing and finding**

14. **Each character knows part of the map.** A cultivator starts knowing their birth region, the main roads (the roads between
    cities) and the great cities (every city). Tiles near their path become known as they travel, in a wider band with more divine sense (thần
    thức), and places become known when visited or heard of. Bought maps, jade slips (ngọc giản) and sect libraries
    add more. NPCs know their own region, kept abstract.
15. **Hidden places are left by history.** World generation places ruins, dead cultivators' cave abodes and secret
    realms on wilderness tiles, from the world's own history (Pillar 5: a famous dead NPC's cave is really there). A
    hidden place is not shown to anyone until it is discovered or revealed.
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
    so a poor fit says why. Spirit Fields read the fit of the field's place, and wild herb grounds appear where fit is
    0.6 or more.
19. **About ten resource kinds**, kept in data: linh thạch, the five element ores, wild herbs (by element), beast
    materials and a few special goods. Each maps to Item Database materials and herbs.
20. **Resource sites** are places of the kinds mine (including linh thạch mines), spirit vein, herb ground and beast
    lair. A site has a **reserve**, a **base output** per season and a **recovery rate**. The land decides what a site
    yields: an ore site yields its tile's top base element (a Fire ore vein sits on a volcano), and a linh thạch mine
    needs land density 1.0 or more and Earth + Metal shares of 50 or more.
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
    towns, its production and its taxes. How it taxes and spends belongs to Sects (#26). Some regions belong to no one
    (wild lands). A loose cultivator owns only their cave abodes.
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

    The generated terrain never changes otherwise.

**The four layers of the land**

27. **A place's qi and production are a stack of four layers**, read from the bottom up for a given character:
    - **Layer 4, the land:** the generated biome and terrain (rules 1–4). It never changes, except through a battle scar
      (rule 26).
    - **Layer 3, blessed lands and secrets** (rules 28–30): richer qi left by history.
    - **Layer 2, shared works** (rule 31): improvements that whoever holds the place has made, for everyone there.
    - **Layer 1, home works** (rule 32): a character's own improvements to their home, for themselves alone.

    Each layer adds to the one below, inside its own cap. The full stack has an overall cap on the element match (about
    ×1.6) and on density (in Formulas). The stat block shows each layer as its own line (Pillar 2), so a cultivator
    always sees why a place is strong *for them*.

**Layer 3: blessed lands and secrets**

28. **Blessed lands** (phúc địa) are places whose qi is far richer than their biome. History leaves them: the old home of
    a Hóa Thần who has left the world, a dragon's lair, the grounds of a vanished sect. They come in two sizes:
    - **large:** 2–5 per world, each 2–9 tiles;
    - **small:** 10–30 per world, one tile each, room for one cultivator.

    Their element match may go past ×1.3, up to the stack's cap. Most lean strongly toward one element or variant, and
    those strong in several elements are rarer. Some are famous and held by great sects; others are hidden places found
    by clues (rules 15–17). Once a blessed land is found, its layer 3 benefits everyone there.
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
    - World generation gives settlements and sect seats layer 2 works already built, and their holders keep them up. A
      city holds more than a town, a town more than a village, and a sect seat the most. Settlements' natural density
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
    owns the residence, still inside the settlement. **A settled home is never as good as a cultivator's own developed
    base or a blessed land:** homes inside settlements and sect grounds have their own lower caps (density 1.8, match
    ×1.3), below a self-built base in the wilderness (density 3.0, match ×1.6) and the blessed lands. The character may
    add their own home works there, but the settled caps still apply. The holder sets prices and who may rent (Sects #26
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
| World Generation (#27) | in | The world's history, which places ruins, dead cultivators' abodes, secret realms, blessed lands and tile secrets (rules 15, 28, 29) | World Generation (history); this GDD (terrain, placement rules) |
| World Database | out | Places, regions, discoveries, scars, ownership, homes, works on each place (layers 1 and 2), who knows each secret, each character's known map | World Database (storage) |
| Living World Tick | out / in | The seasonal update: reserves, secret realm cycles, upkept works fading; NPC positions kept per region | Living World Tick (the tick); this GDD (the rules it runs) |
| Time & Turn | in | Seasons and the fraction of a season a trip uses | Time & Turn |
| Combat | out | Encounters on the way; a flier's linh lực after the trip | Combat |
| Item Database | in / out | Maps, jade slips and told secrets as clue items; resources mapped to materials and herbs | Item Database |
| Quests | out | Places, arrival, travel time for its visit and deliver stages | Quests |
| Heavenly Tribulation | out | The place's ground tags (biome, element shares) | Heavenly Tribulation |
| Meridian Map capabilities | in | #8 (seasons spent travelling also cultivate) and #21 (Blink Mark) | Meridian Map / Effects |
| Debug Terminal, Game UI | out | The map display, stat blocks with each layer's line, the known map | UI |
| Save/Load | out | The seed and every change (scars, reserves, ownership, homes, works, secrets known, known maps), not the terrain | Save/Load |

## Formulas

All keys live in new data files: `world_map.json` (land, match, travel, search, herbs), `map_resources.json`
(production, reserves) and `map_works.json` (works). Numbers marked *(guess)* have no source yet and are set by the
bot run (Open Questions). Proposed by `systems-designer` and `economy-designer`, 2026-11-10; the user decided the
match reward, the Core Formation share, linear herb growth and the realm-scaled teleport fee.

### A. Element match, land layer (rule 5)

The world_mean_share formula is defined as:

`mu_e = (1 / N_places) · Σ_places s_e / 100`, computed once at world generation for each base element and variant.

The land_match formula is defined as:

`M4 = clamp(1 + k · Σ_e q_e · (s_e / 100 − mu_e), M4_min, M4_max)` with `q_e = u_e · p_e / 100`

The sum runs over the 5 base elements and the 8 variants; a variant's `s_e` is its share outside the 100.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_e | int | 0 and up, uncapped | calculated (Spiritual Roots) | Purity of e: birth plus road-raised, owned or not |
| u_e | float | 1 or 0.5 | data file (`match_unowned_rate`) | 1 if the root owns e; 0.5 if its purity comes only from rare sources |
| q_e | float | 0 and up | calculated | The root's weight on e |
| s_e | float | 0–100 | calculated (land generation) | The place's land share of e; base shares sum to 100, variant shares are mostly 0 |
| mu_e | float | 0–1 | calculated (world constant) | World mean share over places; base values sum to 1 |
| k | float | 1.0 | data file (`match_gain`) | Gain |
| M4_min, M4_max | float | 0.8, 1.3 | data file (`match_land_min`, `match_land_max`) | Land-layer bounds |

**Output Range:** 0.8 to 1.3. At every place the base deviations `s_e/100 − mu_e` sum to 0 and each averages 0 over the
world, so **every root averages ×1.0 over the world before the clamp**, whatever its element count; the clamp's bias is
about −0.01 at purity 100. A single-element root has the highest peaks and lowest valleys; a dual root peaks on mixed
land; a balanced five-element root gets ×1.0 on every land (it still gains from layers 1–3, which are not centred).
Players choose their ground, so a well-placed player cultivates faster than the calibration's ×1.0; that is the reward
for choosing ground (user decision 2026-11-10). A settled NPC's match averages about ×1.0, since cities sit wherever the
land put them; the NPCs who live outside sit on chosen ground (rule 33) at about ×1.15–1.25. The NPC average therefore
rises a few percent above ×1.0, and Realms re-runs its bot with the match in (its Open Question 23) against the NPC
targets (1 in 8 / 12 / 15 / 20). The player still gains most from choosing ground, because the player can search the
whole world and NPCs only their region.

**Example:** the root Wood 40, Fire 86, Water 10 (mu_e = 0.2 each). On a volcano (Fire 60, Earth 30, Metal 10):
0.86 × 0.40 + 0.40 × (−0.2) + 0.10 × (−0.2) = 0.244, so M4 = **1.244**. In a lake valley (Water 60, Wood 40):
0.10 × 0.40 + 0.40 × 0.20 + 0.86 × (−0.2) = −0.052, so M4 = **0.948**. An Ice root at purity 50 on a glacier with Ice
share 40: 1 + 0.5 × (0.40 − 0.01) = **1.195**.

### B. The four-layer stack (rule 27)

Every item on layers 3, 2 and 1 has a **density add** ΔD and **share pushes** Δs_t (points added to element t, not
renormalised: the ground grows richer and other elements are not reduced). Herb fit (G) reads the same pushed shares.

The stacked_density formula is defined as:

`D = min(D_cap, D4 + min(c3, ΔD3) + min(c2p, ΔD2p) + min(c2u, ΔD2u) + min(c1p, ΔD1p) + min(c1u, ΔD1u) + density_bonus)`

The stacked_match formula is defined as:

`M = clamp(M4 + Σ_{i ∈ {3,2,1}} min(m_i, k · Σ_t q_t · min(cs_i, Δs_{i,t}) / 100), M_min, M_cap)`

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
| M_min, M_cap | float | 0.8, 1.6 | data file (`match_stack_min/max`) | Stack bounds |

**Output Range:** density 0.3–3.0 (today a secret realm at 2.2 with Tụ Linh at level 5 already reaches 2.95); match 0.8–1.6
(the layer caps sum to 1.9, so 1.6 binds only when every layer stacks). A permanent shared-works cap of 0.1 keeps Core
Formation meaningful: if every place were improved to it, places at 1.4 rise from 18 % to at most 28 %.

**Example:** a valley at land density 1.30 fails Core Formation; a sect's upkept array (+0.30) and a level-2 Tụ Linh Trận
(+0.30) give D = **1.90**. The Fire 86 root on the volcano (M4 1.244), with a small blessed land pushing Fire +40
(0.86 × 0.40 = 0.344, capped to +0.30) and an upkept home work pushing Fire +20 (0.172, capped to +0.15): 1.694, capped
to **M = 1.60**.

### C. Land density generation (rules 2–4)

The place_density formula is defined as:

`D4 = clamp(b_biome + o_kind + a_vein + n, 0.3, 2.4)` with `n ~ U(−j, j)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b_biome | float | 0.4–1.1 | data file | Biome base: sea 0.5; miasma 0.4; desert, salt flats, badlands 0.6; steppe, tundra 0.7; grassland, coast, swamp, mangrove, glacier 0.8; temperate forest, lake valley, highland 0.9; jungle, bamboo, karst 1.0; high mountain, volcano 1.1 *(guess)* |
| o_kind | float | −0.2 to +0.8 | data file | Place-kind offset, tuned by the generator to the targets below |
| a_vein | float | 0 or 0.3–0.9 | data file | A spirit vein on the tile; neighbouring tiles get half |
| j | float | 0.15 | data file | Noise |

**Output Range:** 0.3–2.4. **Generation targets, checked over 100 seeds:** 15–21 % of places at density 1.4 or more
(Core Formation; user decision 2026-11-10 to keep 18 %, which is 27–45 places at 150–250 places); mean place density
1.05–1.20 (today 1.13); about 4 % of wilderness land tiles at 1.4 or more, mostly veins and their neighbours, so a cave
abode opened at random is rarely a Core Formation spot; each base element's mu_e between 0.15 and 0.25.

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

**Example:** a valley on bamboo forest (1.0), o_kind +0.25, no vein, n = +0.10: D4 = **1.35**. Beside a vein (+0.3,
halved to +0.15): **1.50**.

### D. Travel (rules 10–12)

The trip_time formula is defined as:

`T = Σ_tiles c_t / (v_mode · max(f_min, 1 + tsp / 100))`; wilderness `c_t = c_biome`; road `c_t = 1 + r_share · (c_biome − 1)`; boat, ship and flight `c_t = 1`

The leftover_cultivation formula is defined as:

`gain_last = rate_dest · (1 − u) · η` with `u = T − (ceil(T) − 1)`

The flight_drain formula is defined as:

`pool_arrive = pool_max · (1 − f_drain · tiles_flown_this_season / v_fly_eff)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_mode | float | road 12; wilderness 4; river 18 down / 10 up; sea 20; flight FE 30, CF 45, NS 65, DT 90 | data file (`speed_*`) | Tiles per season *(river, sea and flight above FE: guess)* |
| c_biome | float | 1.0–2.5 | data file | Grassland, steppe, coast, lake valley, salt flats 1.0; badlands 1.25; forest, bamboo, desert, tundra, highland 1.5; jungle, swamp, mangrove, karst, volcano, miasma 2.0; high mountain, glacier 2.5; sea impassable on foot |
| r_share | float | 0.25 | data file (`road_terrain_share`) | How much terrain slows a road |
| tsp | float | any | calculated (`travel_speed_pct`) | Every mode but teleport |
| f_min | float | 0.25 | data file (`travel_speed_floor`) | A negative tsp never stops travel |
| T | float | 0+ | calculated | Trip length in seasons |
| u | float | 0–1 | calculated | Share of the last season spent travelling |
| η | float | 1.0 | data file (`partial_season_efficiency`) | Rate for the leftover share |
| rate_dest | float | 0+ | calculated (Realms Formulas I) | The destination's rate, through its stack |
| f_drain | float | 0.6 | data file (`flight_drain_per_season`) | Share of the pool one full season of flight costs *(guess)* |
| v_fly_eff | float | 7.5+ | calculated | v_fly × max(f_min, 1 + tsp / 100) |

**Output Range:** T 0 and up (each full season ages the character); gain_last 0 to rate_dest; pool_arrive 0.4–1.0 of the
pool, assuming the pool refills at each season start (Open Questions). Today's fixed times still roughly hold: about 1
season across a 20-tile region by road, about 3 between regions.

**Example:** an FE cultivator with tsp +20: 8 grassland road tiles (8 / 14.4 = 0.556 s) plus 3 jungle wilderness tiles
(6 / 4.8 = 1.25 s) gives T = **1.806**; season 2 is 80.6 % travel, so it gains **19.4 %** of the valley's rate. Flying the
11 tiles: 11 / 36 = 0.306 s; drain 0.6 × 11 / 36 = 0.183, landing at **81.7 %** of the pool.

### E. Encounters (rule 13)

The encounter_chance formula is defined as:

`P_stretch = 1 − exp(−Σ_tiles h[d_t] · m_mode · Δt_t)`

A stretch is the part of a trip inside one season, and it draws at most one encounter; the Event Engine picks it,
filtered by biome.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d_t | int | 1–4 | calculated | Tile danger: biome base, −1 in a settlement, minimum 1 |
| h[d] | float | 0.15 / 0.35 / 0.70 / 1.20 | data file (`hazard_per_season`) | Hazard per season of wilderness exposure *(guess)* |
| m_mode | float | wilderness and search 1.0; road 0.4; river 0.3; sea 0.5; flight 0.25 | data file (`mode_factor`) | Mode factor *(guess)* |
| Δt_t | float | 0+ | calculated (D) | Time on the tile, c_t / v_eff |

**Output Range:** 0 up to, never reaching, 1. A full wilderness season gives 14 / 30 / 50 / 70 % at danger 1–4; a road
season at danger 1 gives 5.8 %. Hazard is per unit of time, so speed lowers exposure.

**Example (the trip in D):** stretch 1: road 0.556 × 0.15 × 0.4 = 0.033, plus jungle (danger 2) 0.444 × 0.35 = 0.156,
so P = 1 − e^−0.189 = **17.2 %**; stretch 2: 0.806 × 0.35 = 0.282, so **24.6 %**. Flying instead:
0.25 × (8 × 0.15 + 3 × 0.35) / 36 = 0.0156, so **1.5 %**.

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
| r_k, r_max | float, int | 1.0, 8 | data file | Sight and sweep radius; the same r widens the known band (rule 14). QR 1, FE 1, CF 2, NS 3, DT 7; distance counts diagonals as 1 (Chebyshev) |
| H | float | 50–5,000 | data file, per secret or hidden place | How hidden: pocket vein 100, spring 300, sealed abode 1,000, Hóa Thần cache 3,000 *(guess)* |
| A | float | 1 and up | calculated | Area in tiles: rumour = region wilderness × `rumour_area_share` 0.25 (about 100); jade slip `jade_slip_area` 25; an exact map is a sure find on arrival, with no roll |
| q | float | 0.5–1.5 | data file, per clue | Clue quality |
| v_wild_eff, c_area | float | 4 × speed factor; 1–2.5 | calculated; data file | Search speed and the area's mean biome cost |
| n_rolls | int | 3 | data file (`tile_search_rolls`) | Rolls for a season spent searching one tile |
| fly_detect_mult | float | 0.5 | data file | A flier passing over a tile *(guess)* |

**Output Range:** each chance is 0 up to, never reaching, 1, so the deepest caches stay hidden from the weak. The square
root compresses divine sense's ×100 range over the realms to about ×6 in radius.

**Example:** CF, DS 450 (r 2, a sweep of 20 tiles a season on cost-1 ground), H 300 (p_detect 0.6): with a jade slip,
20 / 25 × 0.6 = 0.48, so **38 % a season**; from a rumour, 20 / 100 × 0.6, so **11 %**. The same slip at FE (DS 135,
p 0.31, r 1): 12 / 25 × 0.31 = 0.149, so **14 %**. A spring on arrival at NS: 1,350 / 1,650 = **82 %**. An FE
cultivator searching that tile for a season: 1 − 0.69³ = **67 %**.

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
| d | int | 0 to about 144 | calculated | Straight-line tiles between the arrays |
| fee_base_frac, fee_per_tile_frac, fee_frac_max | float | 0.05, 0.002, 0.30 | data file *(guess)* | Fixed part, distance part, cap |
| owner_mult | float | 1.0 default; 0.5–3 | Sects (#26) | Member discount or outsider surcharge |

**Output Range:** 5–30 % of the realm's `linh_thach_max` (the cap binds past 125 tiles): 4–24 linh thạch at Qi
Refining, 15,000–90,000 at Deity Transformation.

**Example:** a Core Formation cultivator jumping 100 tiles pays 5,000 × 0.25 = **1,250** (about two seasons of mission
income, to save about 8 seasons on the road). A Qi Refining one jumping 40 tiles pays **10**.

### L. The seasonal production contract (rule 25)

The aggregation formula is defined as:

`qty[region,k] = Σ_{s in region} production[s,k]`; `value_lt = qty · unit_value[k]`; `territory[k]` sums the held regions' sites and any held sites outside them; each site counts once

**Region record** `map_production_region` (once a season, about 20 × 9 entries): `contract_version` (1), `season_index`,
`region_id`, `holder_id` (sect id, "" for wild), `pop_cultivators[5]` (heads by realm, from the Living World Tick),
`pop_settlement_weight` (city 8, town 4, market 3, village 1 *(guess)*), and `production` per kind: `qty`, `value_lt`,
`sites`, `reserve_mean` (weighted by base output), `bands` {rich, worked, thinned}, `top_rarity` (1–6),
`by_element` (herbs only), `demand_factor_used` (echoes D_f so #43 can audit its loop).

**Territory record** `map_production_territory`: `contract_version`, `season_index`, `sect_id`, `region_ids[]`,
`extra_site_ids[]`, `pop_cultivators[5]`, `pop_settlement_weight`, `production` (as above), `works_upkeep_due_lt`
(layer 2 upkeep, for Sects). The World Database keeps the last 8 seasons *(guess)*.

**Scale check:** today's faucets (missions and stipends over 5,000 cultivators, a quarter of seasons worked *(guess)*)
create about 137,000 linh thạch a season. Seventeen linh thạch mines (10 small, 5 medium, 2 large *(guess)*) at typical
factors produce about **124,000 a season**, within 10 %. The mine scale holds only while today's wages hold; if #43
changes them, re-derive `site_grade_value`. Whether mine output adds money or replaces the mission faucet is #43's
decision (Open Questions).

### M. Developed ground, settled homes and where NPCs live (rules 33–34)

The prebuilt_works formula is defined as: `ΔD2u_start[place] = prebuilt_density[kind]`, built at generation and upkept by the holder

The settled_caps formula is defined as: for a home inside a settlement or sect ground, `D ≤ settled_density_cap` and `M ≤ settled_match_cap` (replacing D_cap and M_cap of B)

The rent formula is defined as: `rent_season = round(linh_thach_max[realm] · rent_frac · quality)`; `price = rent_season · buy_seasons`; `quality = D_residence / core_density_min`

The npc_home formula is defined as: settled with probability `npc_settled_share` (sect members at their seat; others by `settle_weight`), at grade `min(realm_index + 1, max_grade[kind])` (`realm_index` 0 at Qi Refining); otherwise a random pick among the top `npc_wild_pick_top[realm]` of free tiles (an occupied small blessed land is not free) in the NPC's region ranked by `D · M` for its root

The abode_cost formula is defined as: `abode_cost = round(linh_thach_max[realm] · abode_cost_frac)`, `abode_cost_frac` 0.05 *(guess)*, and opening takes one season (rule 8; user decision 2026-11-10). Example: 250 linh thạch at Core Formation.

The furnishing formula is defined as: `ΔD1_furnish = furnish_per_grade · grade`, a fixed layer 1 work that comes with the residence, within the settled caps

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| prebuilt_density | float | village 0.10, town 0.20, market 0.25, city 0.30, sect seat 0.40 | data file *(guess)* | Layer 2 upkept works at generation |
| settled_density_cap, settled_match_cap | float | 1.8, 1.3 | data file *(guess)* | A settled home is never as good as an own base (3.0, ×1.6) or a blessed land |
| linh_thach_max | int | 80 / 600 / 5,000 / 40,000 / 300,000 | data file (`events_budgets.json`) | The renter's realm budget |
| rent_frac, buy_seasons | float, int | 0.02, 40 | data file *(guess)* | Rent share and purchase multiple |
| D_residence | float | 0.6–1.8 | calculated (B) | The residence's stacked density |
| npc_settled_share | float | 0.85 | data file (user decision) | Share of NPCs living in settlements and sect grounds |
| settle_weight | int | city 8, town 4, market 3, village 1 | data file *(guess)* | How settled NPCs spread |
| npc_wild_pick_top | float | QR 0.25, FE 0.15, CF 0.08, NS 0.04, DT 0.02 | data file (0.25 user decision; the realm ladder a guess) | Outside NPCs pick among the best share of spots for their root in their region; narrower and better as realm rises |
| grade, max_grade | int | 1–5; village 2, town 3, market and city 4, sect seat 5 | calculated; data file *(guess)* | Residence grade; the best a place kind offers |
| furnish_per_grade | float | 0.05 | data file *(guess)* | Layer 1 density a residence's furnishing adds per grade |
| grade_realm_min | int | grade 4 Core Formation, grade 5 Nascent Soul | data file *(guess)* | Least realm to rent or buy the top grades |

**Output Range:** a settled home reaches at most density 1.8 and match ×1.3; rent 1.2–3.6 % of the realm budget a
season. A city at land density 1.0 sits at about 1.3 with its works, just short of Core Formation; a sect seat at 1.0
reaches 1.4, so members can form their Core there. High-realm NPCs now sit on better ground, so they cultivate faster
late in life; that shifts how many reach Nascent Soul and Hóa Thần (about 27 and 3), which Realms' bot re-run measures.

**Example:** a Core Formation renter of a courtyard at stacked density 1.54 (quality 1.1) pays 5,000 × 0.02 × 1.1 =
**110 a season**, or **4,400** to buy.

## Edge Cases

**Land and layers**
- **If a stacked value passes its cap** (density 3.0, match ×1.6, or any layer's own cap): it is clamped. The stat block
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

**Generation**
- **If a generated world misses its targets** (Core Formation share outside 15–21 %, mean density outside 1.05–1.20,
  or a base element's mean share outside 0.15–0.25): the generator retries with the next sub-seed, up to 10
  tries. It then keeps the closest world (the smallest summed relative miss over the targets) and logs the miss.
- **If an inhabited island has no port:** the generator adds one to its largest settlement, so every island is reachable
  by ship.

## Dependencies

**Upstream (this system needs these)**

| System | Type | Interface | State |
|---|---|---|---|
| World Generation & History (#27) | Hard | The world seed and history, which place ruins, abodes, secret realms, blessed lands and tile secrets | Built, no GDD; **provisional** |
| World Database (#3) | Hard | Storage for places, regions, discoveries, scars, ownership, homes, works, known maps and secrets | Built, no GDD |
| Time & Turn (#4) | Hard | Seasons, and the share of a season a trip uses | Built, no GDD; **provisional** (the leftover-season rule) |
| Config (#1), Sim Core (#2), Save/Load (#5) | Hard | `world_map.json`, `map_resources.json`, `map_works.json`; seeded streams; saving the seed and the changes | Built, no GDD |
| Spiritual Roots (#6) | Hard | Purities, owned and road-raised, for the element match | GDD in review; **no row for this system yet** |
| Character Stats (#7) | Hard | `travel_speed_pct`, divine sense, realm, `density_bonus` | GDD in review; lists this system |
| Sects & Missions (#26) | Soft | Who holds regions, sites and arrays; who may rent or use them; tax and conflict | Built (thin), no GDD; **provisional** |
| Formations (#17) | Soft | Gathering formations as works on layers 1 and 2 | Quick spec only |
| Event Engine (#23) | Soft | Encounters, clue items, secret realm openings, scars | Built, no GDD |

**Downstream (these need this system)**

| System | Type | Interface | State |
|---|---|---|---|
| Realms & Bottlenecks (#8) | Hard | Stacked density and match for the cultivation rate; the Core Formation density check; the leftover-season rate | GDD in review; lists this system (its rows need the layer stack and the match) |
| Spirit Herbs & Fields (#14) | Hard | Herb fit at the field's place | Built, no GDD |
| Regional Economy & Trade (#43) | Hard | The seasonal production contract; the demand hook (`price_index`) | Not started |
| Market (#20) | Soft | Market places; regional production until #43 replaces it | Built, no GDD |
| Living World Tick (#28), NPC Builds (#24) | Hard | NPC homes (settled share, graded residences, hermit picks), reserves, cycles, fading works | Built, no GDD |
| Combat (#21) | Soft | Encounters on the way; a flier's pool on arrival | Approved; **no row for this system yet** |
| Item Database (#13) | Soft | Maps, jade slips and told secrets as clue items; resources mapped to materials and herbs | GDD in review; **no row for this system yet** |
| Quests (#31) | Soft | Places, arrival, travel time | Approved; lists this system |
| Heavenly Tribulation (#22) | Soft | Ground tags (biome, element shares) | Approved for rules; lists this system |
| Meridian Map (#10) / Effects (#41) | Soft | Capabilities #8 (travel cultivates) and #21 (Blink Mark) act on travel | In review / approved; Meridian lists it |
| Debug Terminal (#36), Game UI (#37), Guidance (#35) | Soft | The map, stat blocks with each layer's line, the known map, herb fit lines | Terminal built |
| Balance Harness (#33) | Hard | Generation targets over seeds; the Realms re-run with the match | Built, no GDD |

**Bidirectional check.** Realms, Character Stats, Quests, Heavenly Tribulation and the Meridian Map list this system.
**Spiritual Roots, Combat and the Item Database do not**, so a back-reference row is added to each when this GDD is
finished (with the user's approval). Realms' existing rows also need wording for the layer stack and the match.

## Visual/Audio Requirements

- **The terminal map, built first:** the tile grid drawn in characters, one glyph and colour per biome (`^` mountains,
  `~` water, `,` grass, `"` jungle, `.` desert and so on), with named places as letters and roads as `=` or `-`. Only
  tiles the character knows are drawn; unknown land is blank. A legend lists the glyphs.
- **The Game UI map, later**, in the game's chosen visual identity. The style is **open**, and the art bible decides it.
  Candidates the user wants weighed (2026-11-10):
  - **pixel or tile art**, grid-native and closest to Dwarf Fortress (*Dwarf Fortress*'s Steam tiles, *Caves of Qud*,
    *Amazing Cultivation Simulator*);
  - **a painted parchment map** (*Crusader Kings III* zoomed out, *Battle Brothers*);
  - **ink-wash** (*Okami*, *Tale of Immortal*'s world map).

  Whatever the style, each biome must read at a glance, and an optional **qi overlay** shows density (as mist or
  shading) and each element as a faint tint, so a Fire-rich region reads warm. A blessed land stands out in the
  overlay, and a tile secret never shows unless known.
- **Moments worth marking:** finding a hidden place or a secret (a mark appears on the map, with a short sound cue), a
  secret realm opening (a visible ripple, plus rumour text), and a battle scar (the tile's look changes for good).
- **Audio** follows the biome in the Game UI: wind on steppe and highland, rain in jungle, quiet in a blessed land.
  There's no audio in the terminal.

## Game Feel

- **Distance should feel real, never tedious.** One command plans and starts a trip, and the screen shows the route,
  its length in seasons, the danger along it and the encounter chance before the player commits. The player never
  walks tile by tile on a road; only off-road search and wilderness crossing go stretch by stretch.
- **Discovery should feel earned:** a clue narrows the search, the search takes visible seasons, and the find is a
  marked moment that is recorded in the world's history.
- **Choosing ground should feel like build-craft:** the stat block shows *your* match, *your* density and each layer's
  line, so moving a home is a decision with numbers behind it, like picking a node on the Meridian Map.
- **Response targets:** the map view renders in under 100 ms; planning a route (pathfinding over the grid) returns in
  under 200 ms for any two points on the continent.

## UI Requirements

- **`map`:** the known map around the character, with zoom levels (region, continent) and the legend.
- **`place <name>`** (also `here`): the stat block (rule 7) with a line per layer (land, blessed land or secret, shared
  works, home works), the clamp line when a cap binds, and the character's own match and density.
- **`route <place>`** (or a tile): every route available with the character's modes, each with seasons, danger,
  encounter chance and teleport fee, and a confirm step before starting.
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
| `design/gdd/game-concept.md` | Pillars 2, 4 and 5; the anti-pillar on world simulation (clarified when this GDD is finished); the visual identity ("Ink and Ledger" names ink-wash; the map style is now open, Visual/Audio) |
| `design/gdd/canh-gioi.md` | Formulas I (rate × density × match), the Core Formation condition (`core_density_min`), rule 3 (the season-start rate; the leftover-season exception), Open Question 23 (the recalibration) |
| `design/gdd/linh-can.md` | Rules 8 and 8a and Formulas G: purities, owned and road-raised; unowned purity counts at half weight in the match |
| `design/gdd/character-stats.md` | `travel_speed_pct`; divine sense (Formulas C); `density_bonus` (tree and items only) |
| `design/gdd/combat.md`, `combat-defence.md` | Encounters on the way; the linh lực pool a flier arrives with |
| `design/gdd/item-database.md` | Maps, jade slips and told secrets as clue items; material and herb values; the `linh_thach_max` ladder (`events_budgets.json`) |
| `design/gdd/quests.md`, `thien-kiep.md` | Travel time for visit stages; ground tags |
| `design/gdd/kinh-mach-do.md`, `effects.md` | Capabilities #8 (travel cultivates), #15 (formation levels) and #21 (Blink Mark) |
| `design/quick-specs/luyen-khi-and-tran-phap.md` | Tụ Linh Trận: cost, +0.15 per level, upkeep (kept, now a layer 1 upkept work) |
| `design/gdd/systems-index.md` | #43 Regional Economy & Trade (the contract's reader), #26 Sects, #17 Formations, #37 Game UI (art style open) |
| `assets/data/world_generation.json`, `crafting_formations.json`, `items_herbs.json` | Replaced travel keys; formation upkeep becomes seasonal; new herb climate keys |
| `src/gameplay/world/world_generator.gd`, `world_db.gd`, `src/gameplay/session/game_session.gd` (travel), `formations.gd`, `market.gd`, the terminal views | Code the rework touches |

## Acceptance Criteria

Drafted by `qa-lead`, 2026-11-10, after the user's rulings on the first draft. Nothing has run. Values marked *(guess)*
in Formulas are tested at their data-file values, so a retune changes the expected number, not the test. Every random
draw comes from a seeded stream: Logic tests inject rolls (FX-TM-RNG), Harness tests use the fixed seed list
(FX-TM-SEEDS). Default tolerance ±0.001 on floats; integers exact. `round` is half up with a 1e-6 tolerance.

Evidence: `tests/unit/travel_map/`, `tests/integration/travel_map/`, `production/qa/evidence/balance/` (harness runs),
`production/qa/evidence/debug-terminal/` (UI screenshots, retained), `production/qa/smoke-[date].md` (Config/Data).

**Fixtures.**

- **FX-TM-DATA:** the shipped `world_map.json`, `map_resources.json`, `map_works.json`, `crafting_formations.json` and
  `events_budgets.json` at the Formulas defaults.
- **FX-TM-MU:** injected world means: each base `mu_e` 0.20, `mu_Ice` 0.01, other variants 0. Hand-built maps use these
  instead of computing them.
- **FX-TM-MINI:** a hand-built small map using FX-TM-MU:
  - **VOL** volcano: Fire 60, Earth 30, Metal 10; T 80, R 20; D4 1.10. It holds a small blessed land (ΔD3 0.40, Fire
    push +40).
  - **LAKE** lake valley: Water 60, Wood 40; D4 1.30.
  - **GLA** glacier: Water 100, Ice 40 (variant); T 5.
  - **FOR** temperate forest: Wood 70, Water 30; R 50, T inside Thanh Tâm Liên's band. A spring secret (H 300) sits on
    the next tile.
  - **TOWN** (on grassland): a road of 8 grassland tiles (danger 1) runs from it to a junction. From the junction, 3
    jungle wilderness tiles (danger 2) lead to LAKE.
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
- **FX-TM-SEEDS:** 100 fixed world seeds, stored as test data.
- **FX-TM-WORLD:** FX-TM-SEEDS[0] at full size with 5,000 cultivators, after 40 seasons of the Living World Tick on a
  fixed seed.

### Land and layers

- **AC-TM-01** [Logic] Rule 1. GIVEN FX-TM-SEEDS[0], WHEN the world is generated twice in fresh processes, THEN both
  tile dumps are byte-identical: elevation, temperature, rainfall, biome, river flag, density and shares.
- **AC-TM-02** [Config/Data] Rule 1. GIVEN `world_map.json` set to 120 × 80, THEN the grid has 9,600 tiles. GIVEN it set
  to 60 × 40 with no code change, THEN the grid has 2,400 tiles.
- **AC-TM-03** [Logic] Rule 1. GIVEN any FX-TM-SEEDS world, THEN no river tile is lower than the next tile downstream.
  Every river ends at sea, a lake or the map edge.
- **AC-TM-04** [Config/Data] Rule 2. GIVEN FX-TM-DATA, THEN 20 biomes are listed. Each has a base profile summing to
  100, a base density, a danger of 1–4 and a climate band. The base densities equal Formulas C (sea 0.5 … volcano 1.1).
- **AC-TM-05** [Logic] Rule 3. GIVEN every tile of FX-TM-MINI and of FX-TM-SEEDS[0], THEN the base shares sum to 100.
  Variant shares sit outside the 100.
- **AC-TM-06** [Logic] Rule 3. GIVEN a volcano tile with a lava vent and the same tile without one, THEN the vent tile's
  Fire share is higher, and both base sets still sum to 100.
- **AC-TM-07** [Harness] Rule 4. GIVEN FX-TM-SEEDS, THEN each variant appears only on its own terrain:
  - Ice on glacier or tundra;
  - Thunder on storm peaks;
  - Wind on highland, steppe or coast;
  - Light on sacred summits;
  - Darkness in deep caves, miasma or swamp.

  In every world, each variant is in at most 2 % of places (`variant_place_share_max`).
- **AC-TM-08** [Logic] Formula A, rule 5. GIVEN FX-TM-ROOT-F, WHEN M4 is computed at VOL, THEN it is **1.244**.
- **AC-TM-09** [Logic] Formula A. GIVEN FX-TM-ROOT-F at LAKE, THEN M4 is **0.948**.
- **AC-TM-10** [Logic] Formula A. GIVEN FX-TM-ROOT-ICE at GLA, THEN M4 is **1.195**.
- **AC-TM-11** [Logic] Formula A, bounds. GIVEN an owned Fire 200 root, THEN M4 at VOL is 1.300 (raw 1.8) and at LAKE
  is 0.800 (raw 0.6).
- **AC-TM-12** [Logic] Formula A, `u_e`. GIVEN FX-TM-ROOT-FU at VOL, THEN M4 is 1.172.
- **AC-TM-13** [Logic] Formula A. GIVEN FX-TM-ROOT-5, THEN M4 is 1.000 at every FX-TM-MINI place with no variant share.
- **AC-TM-14** [Logic] Edge (a root with none of the land's elements). GIVEN FX-TM-ROOT-ICE at VOL (Ice 0), THEN M4 is
  0.995, not a penalty down to the clamp.
- **AC-TM-15** [Logic] Formula A, `mu_e`. GIVEN a world from FX-TM-SEEDS[0], THEN each `mu_e` equals the mean of
  `s_e/100` over its places. The base `mu_e` sum to 1.000. A later scar does not change any `mu_e`.
- **AC-TM-16** [Harness] Rule 5. GIVEN FX-TM-SEEDS and 200 fixed random roots per seed, THEN the mean M4 over all places
  is 0.98–1.01.
- **AC-TM-17** [Logic] Formula B, density. GIVEN LAKE (1.30) with a sect upkept array (+0.30) and Tụ Linh Trận level 2
  (+0.30), THEN D is **1.90**.
- **AC-TM-18** [Logic] Formula B, match. GIVEN FX-TM-ROOT-F at VOL with the small blessed land (layer 3, Fire +40) and
  an element-focusing array (tụ nguyên trận) at level 5 on Fire (layer 1, +20), THEN:
  - layer 3 adds 0.300 (raw 0.344);
  - layer 1 adds 0.150 (raw 0.172);
  - the raw sum is 1.694;
  - M is **1.600**.
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

- **AC-TM-24** [Harness] Rule 6. GIVEN FX-TM-SEEDS, THEN every world has 150–250 places and 18–22 regions. Every place
  kind in rule 6 appears at least once.
- **AC-TM-25** [Logic] Rule 6, Formula E `d_t`. GIVEN a town on jungle (base danger 2), THEN its danger is 1. GIVEN a
  village on grassland (danger 1), THEN it stays 1.
- **AC-TM-26** [Logic] Rule 6. GIVEN CITY and MARKET, THEN each offers trade. GIVEN TOWN, VILLAGE and a wild site, THEN
  none offers trade.
- **AC-TM-27** [Logic] Rule 7. GIVEN VOL, WHEN its stat block is read back from the World Database, THEN it holds
  every field in this list, and each equals the generated value:
  - biome, temperature, rainfall, density;
  - shares and variants, danger;
  - settlement size, resources, herb fit;
  - owner, features.
- **AC-TM-28** [Logic] Rule 8. GIVEN a character whose home is TOWN, WHEN they open a cave abode on WILD1, THEN:
  - a cave abode place exists on WILD1 with WILD1's terrain;
  - the character owns it, and it is their home;
  - a fact is recorded;
  - TOWN is no longer their home.
- **AC-TM-29** [Logic] Rule 8, Formula M `abode_cost`. Opening an abode takes 1 season. It costs 250 linh thạch at
  Core Formation, 30 at Foundation Establishment and 4 at Qi Refining. GIVEN less money than the cost, THEN the opening
  is refused and nothing is charged.
- **AC-TM-30** [Logic] Rule 8, Edge. Opening an abode is refused on a tile that holds a place, and on sea. It is
  allowed inside a sect's territory. An abode the character has left stays on the map as a place.

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
  - 18 river tiles downstream take 1.000 season, and 10 upstream take 1.000;
  - 20 sea tiles take 1.000;
  - 30 flight tiles at FE take 1.000.

  Flight speed is 45 at Core Formation, 65 at Nascent Soul and 90 at Deity Transformation.
- **AC-TM-35** [Logic] Rule 10. Flight is refused below Foundation Establishment, and at Foundation Establishment
  without a flying artifact.
- **AC-TM-36** [Logic] Formula D. GIVEN FX-TM-FE from TOWN to LAKE (8 grassland road tiles, then 3 jungle wilderness
  tiles), THEN:
  - T is **1.806** (0.556 + 1.250);
  - u is 0.806;
  - gain_last is **0.194 × rate_dest**.
- **AC-TM-37** [Logic] Formula D, flight drain. GIVEN FX-TM-FE flying 11 tiles, THEN T is 0.306 and the pool arrives
  at **0.817** of max. Over 11 glacier tiles, T is the same.
- **AC-TM-38** [Logic] Formula D, `f_min`, Edge. GIVEN 12 grassland road tiles at tsp −75 and at tsp −90, THEN each trip
  takes **4.000** seasons.
- **AC-TM-39** [Integration] Rule 12, Time & Turn. GIVEN the trip in AC-TM-36, THEN:
  - two season ends pass;
  - the character ages two seasons;
  - season 2 credits 0.194 of LAKE's rate (η 1.0).

  GIVEN the 0.306 flight, THEN the same season credits 0.694 of the destination rate.
- **AC-TM-40** [Logic] Formula K, rule 11:
  - a Core Formation traveller over d 100 pays **1,250**;
  - Qi Refining over d 40 pays **10**;
  - Deity Transformation over d 0 pays **15,000**;
  - Core Formation over d 100 with owner_mult 0.5 pays 625;
  - Core Formation over d 125 pays 1,500, and over d 200 also pays **1,500** (the 0.30 cap).
- **AC-TM-41** [Logic] Rule 11. A teleport jump takes 0.05 of a season, whatever the distance. tsp does not change it.
- **AC-TM-42** [Logic] Rule 11, Edge. GIVEN an array whose owner refuses the character, THEN no jump happens and no fee
  is taken.
- **AC-TM-43** [Integration] Rule 11. GIVEN the map active, THEN the existing Blink Mark (capability #21) tests pass
  unchanged.

### Encounters

- **AC-TM-44** [Logic] Formula E. GIVEN the trip in AC-TM-36, THEN P is **0.172** for stretch 1 and **0.246** for
  stretch 2. GIVEN the same trip flown, P is **0.0155**.
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
- **AC-TM-49** [Logic] Edge (flier mid-flight). GIVEN FX-TM-FE meeting an encounter on flight tile 5 of 11, THEN the
  fight reads a pool of 0.917.
- **AC-TM-50** [Harness] Formula E. GIVEN 10,000 seeded full wilderness seasons at danger 2, THEN the encounter rate is
  0.295 ±0.01.

### Knowing and finding

- **AC-TM-51** [Logic] Rule 14. GIVEN a newly created character, THEN their map shows their birth region, every city and
  every road between cities, and nothing else.
- **AC-TM-52** [Logic] Formula F, radius. GIVEN DS 45, 135, 450, 1,350 and 6,525, THEN r is 1, 1, 2, 3 and 7. GIVEN DS
  10,935, THEN r is 8 (raw 9; the r_max cap).
- **AC-TM-53** [Logic] Rule 14. GIVEN a 10-tile straight path in open land, THEN every tile within Chebyshev distance r
  of the path becomes known, diagonals included, and no tile at r + 1 does. At FE (r 1) that is a band 3 tiles wide;
  at Core Formation (r 2), 5 wide.
- **AC-TM-54** [Logic] States (place knowledge):
  - a rumour turns Unknown into Heard of (region shown, tile not);
  - a visit turns it into Known;
  - when a Known place's density changes after the visit, the old value shows until the next visit.
- **AC-TM-55** [Logic] Rule 14. GIVEN an NPC, THEN its known area is its region, and no per-tile known map is stored for
  it.
- **AC-TM-56** [Logic] Rule 15, Edge. GIVEN a hidden ruin, THEN no character's map, listing or stat query shows it.
  After A discovers it, it is still Unknown to B, and B's search can still find it.
- **AC-TM-57** [Integration] Rule 15, World Generation. GIVEN FX-TM-SEEDS[0], THEN every hidden ruin or abode sits on a
  wilderness tile and links to a history fact (a dead cultivator or a vanished sect). That figure's recorded abode
  tile holds the place.
- **AC-TM-58** [Logic] Rule 16, Formula F `A`. GIVEN a region with 400 wilderness tiles, THEN a rumour's area is 100 and
  a jade slip's is 25.
- **AC-TM-59** [Logic] Formula F, search. GIVEN FX-TM-CF, H 300, q 1.0 and cost-1 ground, THEN:
  - p_detect is 0.600, and the sweep is 20 tiles a season;
  - a jade slip gives **0.381** a season, and a rumour **0.113**.

  GIVEN FX-TM-FE with a slip, THEN p_detect is 0.310 and the chance is **0.138**.
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
- **AC-TM-73** [Logic] Formula G, labels (each band includes its lower bound):
  - fit 0.800 is excellent, and 0.7999 is good;
  - 0.600 is good, and 0.400 is fair;
  - 0.200 is poor and plantable, and 0.1999 is unplantable.
- **AC-TM-74** [Logic] Edge. GIVEN a herb planted at fit 0.5 whose place then falls to fit 0.1, THEN it keeps growing
  at ×0.12 and nothing is destroyed. New planting there is refused.
- **AC-TM-75** [Integration] Spirit Fields, Formulas B and G. GIVEN Thanh Tâm Liên at FOR with a level-3 private spring
  on Water (+6), THEN Spirit Fields reads f_e 0.930, fit 0.775 and growth ×0.930.
- **AC-TM-76** [Harness] Rule 18. GIVEN FX-TM-SEEDS, THEN every wild herb ground's fit for its herb is at least 0.6.
- **AC-TM-77** [Config/Data] Rule 19. GIVEN `map_resources.json`, THEN it lists about ten kinds: linh thạch, five ores,
  herbs by element, beast materials and special goods. Every mapped id exists in the Item Database, and the validator
  reports 0 dangling ids.
- **AC-TM-78** [Logic] Rule 20. GIVEN every resource site in FX-TM-SEEDS[0], THEN each has reserve, base output and
  recovery rate. The start reserve is 0.85–1.0 of max, unless a history fact marks it thinned.
- **AC-TM-79** [Harness] Rule 20. GIVEN FX-TM-SEEDS, THEN every ore site yields its tile's top base element. Every linh
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

- **AC-TM-90** [Harness] Rule 23. GIVEN FX-TM-SEEDS, THEN each region is one connected set of land tiles, and every
  place is in exactly one region. In every world, at least 60 % of each region's border edges lie on mountain, river
  or coast.
- **AC-TM-91** [Logic] Rule 24. GIVEN an attempt to give a region or site to a non-sect, THEN it is rejected. The only
  places a loose cultivator owns are cave abodes. A region may have no holder.
- **AC-TM-92** [Logic] Formula L. GIVEN one region holding FX-TM-MINE (9,104) and FX-TM-WMINE (625), THEN linh thạch qty
  is 9,729 and value_lt is 9,729. An ore output of 167 at unit 30 gives value_lt 5,010.
- **AC-TM-93** [Logic] Formula L. GIVEN a sect holding region R1 plus a listed extra site inside R1, THEN that site
  counts once. An extra site outside R1 is added once.
- **AC-TM-94** [Integration] Rule 25, production contract. GIVEN FX-TM-WORLD, WHEN one season passes:
  - THEN every region has one `map_production_region` record with `contract_version` 1, `season_index`, `region_id`,
    `holder_id` ("" for wild), `pop_cultivators[5]` and `pop_settlement_weight`;
  - per kind, it has `qty`, `value_lt`, `sites`, `reserve_mean`, `bands`, `top_rarity`, `by_element` (herbs only) and
    `demand_factor_used`, which is 1.0;
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
  - the save holds the seed, sub-seed and changes, and no terrain array.

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
- **AC-TM-114** [Harness] Rule 28. GIVEN FX-TM-SEEDS, THEN every world has:
  - 2–5 large blessed lands of 2–9 tiles each;
  - 10–30 small ones of 1 tile.

  Every ΔD3 is within the Formula B targets.
- **AC-TM-115** [Logic] Formula M, prebuilt works. At land density 1.00, CITY stacks to 1.30 (Core Formation fails)
  and SEAT to **1.40** (passes). Village prebuilt is 0.10, town 0.20 and market 0.25.
- **AC-TM-116** [Logic] Formula M, settled caps, rule 34. GIVEN a city residence whose stack reaches D 2.10 and M 1.45,
  THEN it reads 1.80 and 1.30. The same stack at an own base in the wilderness reads 2.10 and 1.45.
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
  - a grade 3 furnishing adds +0.15 on layer 1, inside the settled caps;
  - rent bills each season;
  - a purchase bills once and is never billed again;
  - the owner's own home works still obey the settled caps.
- **AC-TM-120** [Harness] Rule 33. GIVEN FX-TM-WORLD:
  - the settled share is 0.85 ±0.02;
  - every sect member lives at their seat;
  - non-sect settled NPCs per settlement follow the 8/4/3/1 weights within ±10 % relative per kind;
  - every NPC living outside sits in its region's top `npc_wild_pick_top[realm]` of free tiles by D · M for its root
    (100 % pass);
  - no NPC is placed on a small blessed land another character holds.
- **AC-TM-121** [Harness] Formula A, rule 33. GIVEN FX-TM-WORLD, THEN settled NPCs' mean M is 0.98–1.02, and NPCs living
  outside average 1.15–1.25.
- **AC-TM-122** [Integration] Realms. GIVEN FX-TM-ROOT-F at the AC-TM-18 stack with D 1.90, THEN Realms' rate there
  divided by its rate at D 1.0, M 1.0 is 1.90 × 1.60 = **3.040**.
- **AC-TM-123** [Integration] Realms (Core Formation check). GIVEN LAKE (1.30), THEN the Core Formation condition
  fails. GIVEN the AC-TM-17 stack (1.90), THEN it passes. The boundary works as follows:
  - D 1.400 passes, and 1.399 fails;
  - Tụ Linh Trận counts once, as ΔD1u: building level 3 raises `density_bonus` by 0, and raises D by 0.45, not 0.90;
  - `density_bonus` from the tree and items counts once.
- **AC-TM-124** [Harness] The Realms bot re-run with the match in holds the NPC targets: 1 in 8 / 12 / 15 / 20. Realms
  owns the numbers. This GDD blocks on the run.
- **AC-TM-125** [Integration] Quests and Heavenly Tribulation. A Quests `visit` stage's travel time equals Formula D's T
  for the same route. Tribulation reads the biome and stacked shares of the place where it happens.

### Generation targets [Harness], FX-TM-SEEDS (100 seeds)

- **AC-TM-126** Formula C:
  - the share of places at D ≥ 1.4 is 15–21 % in at least 98 of 100 worlds, and every miss is logged;
  - the mean over the seeds is 17–19 %;
  - mean place density is 1.05–1.20 per world;
  - each base `mu_e` is 0.15–0.25 per world.
- **AC-TM-127** Formula C:
  - wilderness land tiles at D ≥ 1.4 average 3–5 %, and at least 70 % of them are veins or vein neighbours;
  - over 10,000 draws on a fixed seed, `n` stays inside ±0.15 with mean 0 ±0.005;
  - the worked example gives **1.35**, and **1.50** beside a vein;
  - the clamps give 0.30 and 2.40.
- **AC-TM-128** Edge (generation):
  - every inhabited island has a port, in 100 % of worlds;
  - every settlement reaches every other by some mode at FE;
  - a forced miss (target set to 50–60 %) makes the generator try 10 times, keep the world with the smallest summed
    relative miss, and log it;
  - the result is identical on a rerun.

### UI [UI], Debug Terminal, retained screenshots in `production/qa/evidence/debug-terminal/`

- **AC-TM-129** `map`. GIVEN a character with a Heard-of place and a hidden ruin nearby, THEN the screenshot shows the
  known map at region and continent zoom with its legend. Unknown tiles and the hidden ruin are not shown.
- **AC-TM-130** `place <name>` and `here`. GIVEN FX-TM-ROOT-F at VOL with the AC-TM-18 stack, THEN the screenshot
  shows:
  - every rule 7 field;
  - one line per layer (land, blessed land or secret, shared works, home works);
  - a clamp line of −0.094;
  - the character's own D and M.

  `here` shows the same block.
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

- **AC-TM-138** On the reference PC (to be named), headless, with FX-TM-WORLD (120 × 80, about 250 places, 5,000
  cultivators):
  - one generation attempt takes ≤ 1 s, and the worst case with 10 tries ≤ 10 s;
  - the seasonal map update (reserves, cycles, fades, ownership, contract records, NPC home moves) has a mean ≤ 20 ms
    and p95 ≤ 50 ms over 400 seasons;
  - the stacked D · M for all 5,000 cultivators takes ≤ 10 ms a season;
  - one route query across the full grid takes ≤ 20 ms;
  - after 400 seasons the save's map delta is ≤ 500 KB, and a load including regeneration takes ≤ 3 s.

Blocked on other GDDs:
- AC-TM-39 waits on Realms (the leftover-season exception).
- AC-TM-124 waits on Realms (the bot re-run with the match).
- AC-TM-37 and AC-TM-49 wait on Combat (pool refill) for flights longer than one season.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Money supply: does mine output add to the mission and stipend faucets, or replace them? If it adds, the supply roughly doubles | economy-designer, #43 | Regional Economy & Trade design |
| 2 | Does the linh lực pool refill at each season start? Flight drain assumes so | Combat | Before the travel build |
| 3 | Realms' season-start rate rule needs an exception for the leftover share of a travel season | Realms | With its Open Question 23 |
| 4 | Realms' bot re-run with the match, settled and hermit NPCs and graded homes: do the player edge and the NPC targets (1 in 8 / 12 / 15 / 20; about 27 Nascent Soul, about 3 Hóa Thần) hold? | Realms, Balance Harness | Before the map's numbers are approved |
| 5 | Scar threshold and size: which events may scar the land, and by how much | Event Engine (budgets) | Event Engine GDD |
| 6 | Capability #8 (travel seasons cultivate) under travel with leftover seasons | Meridian Map, Effects | Meridian content pass |
| 7 | Should `stealth` lower the encounter chance (a factor on `m_mode`)? | user | Before the travel build |
| 8 | Each herb's climate band (`temp_ideal`, `rain_ideal` and tolerances), and a pill-supply re-check with linear herb fit | content, Spirit Herbs | Content pass |
| 9 | The move from today's region-and-place graph: Market, Sects, Spirit Fields, Events and the balance bots that rely on it | programming | Architecture / code pass |
| 10 | Generation method (noise, rivers, region partition, place siting): a technical decision → becomes an ADR | technical-director | `/create-architecture` |
| 11 | The Game UI map's art style (pixel/tile, parchment, ink-wash) and the game concept's "Ink and Ledger" | art-director, user | `/art-bible` |
| 12 | Every number marked *(guess)* is set by the bot run, generation targets first | systems-designer, bot | Balance Harness run |
