# World Generation & History

> **Status**: Implemented 2026-11-20 (not yet design-reviewed). Every new game's world is built by WorldBuilder
> (`src/gameplay/world/world_builder.gd`) from the exported data (`assets/data/world_history.json` by
> `tools/design/world/export_world.py`, `assets/data/world_continent.json` by `tools/design/map/export_continent.py`);
> plan and evidence: `production/plans/continent-world.md`, `production/qa/evidence/continent-world/`.
> **Author**: user + Claude
> **Last Updated**: 2026-11-20
> **Last Verified**: 2026-11-20
> **Implements Pillar**: Pillar 5, A World That Remembers

## Summary

World Generation & History builds the world a new game starts in, once, before play. The continent, its 30 sects, its
places, a two-tier chronicle (about 150–250 landmark events and 300–500 annals) and a cast of 60–100 fixed characters (each with a fully authored build) are
the same in every game. The ordinary cultivators (about 5,000) and the exact spots of hidden ruins, secret realms and
tile secrets are rolled from the game's seed. The player starts in a world with a learnable geography and a remembered
past, and replay variety comes from people and secrets, not from coastlines (Pillar 5, A World That Remembers).

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Data-Driven Config, Simulation Core, World Database, Time & Turn, Save/Load, Realms & Bottlenecks, Item Database, NPC Builds, Travel & Map, Sects & Missions; soft: NPC Traits`

## Overview

World Generation & History builds the world a new game begins in. Most of it is authored once and is the same in
every game: the continent with its 20 regions and about 230 places (30 cities and 17 ruins of the history among them), the 7 great sects and 22 minor sects with their lands
and seats, the famous sites and sacred features, and the history that led up to the starting year. A small part is
rolled from the game's seed, and it is the only part that differs between games:

- the ordinary cultivators (about 5,000, never fewer than 3,000), generated to fit inside the authored history;
- the spot each hidden ruin, abode, secret realm and blessed land takes among its 2–3 hand-picked candidate tiles;
- the tile secrets;
- each resource site's reserve.

The player never operates this system. It runs once when a game starts, writes the World Database, and from then on
every other system reads its result: Travel & Map, Sects & Missions, Regional Economy, Power Rankings, NPC Traits,
Item Database and the Living World Tick.

The player meets it as a world that existed before they arrived. A famous dead cultivator's cave is really somewhere
out there, a war between sects is remembered by the people who fought in it, and the great cities are where the maps
say they are. The continent can be learned and its past can be known. Replay variety comes from the people and the
secrets, not from the coastlines. A hidden place moves each game, so a guide can't give it away.

Without this system the other systems have a map but no past, no population and no starting state.

## Detailed Design

### Core Rules

1. **The world is built in nine ordered steps.** Each step reads only what earlier steps wrote:
   1. the authored base (continent, regions, places, roads, sacred features);
   2. the sects (30, with leaders and starting state);
   3. the chronicle (authored history);
   4. the fixed cast (authored people);
   5. the seeded rolls (hidden spots, tile secrets, reserves);
   6. the random ordinary cultivators;
   7. the unique named items (Item Database rule 20d);
   8. the Power Rankings start (provisional ratings and the capped coarse panels, Power Rankings rule 16);
   9. the player, placed by origin.
2. **Authored data is data, never rolled.** The base, sects, chronicle and cast are read-only files in fixed formats.
   No step may change them. The same files and the same game seed always give the same World Database.
3. **The chronicle has two tiers** (user decision 2026-11-15, replacing the single 40–60 event chronicle).
   - The **landmark chronicle** is about 150–250 hand-written events: sect foundings, wars and falls, land changing
     hands (rule 15), cities founded and ruined, famous deaths, legendary items made, found or lost, and the origin of
     every secret realm, ruin, abode and blessed land.
   - The **annals** are about 300–500 lesser events, each tied to a region and often to a place: border skirmishes,
     disasters and beast tides, towns and markets founded, mines opened and worked out, duels and local tales.

   Every event in either tier has an id, a year before the start, a kind, its sects and people (by authored id), a
   place or region, and one line of canon text in Vietnamese, which is the text the player reads (rule 14).
   Landmarks fill the codex timeline and event cards; annals feed the codex entry of their region or place, rumours
   and NPC talk. Together the two tiers are the only world history. Nothing in either is generated.
   An event may be marked **secret** (user decision 2026-11-15): it is in the World Database's log, but hidden from
   the codex, rumours and NPC talk until the player discovers it.
4. **An event never names a rolled tile.** It names a place, a region, or a hidden **slot** (28 of them). Which tile
   the slot sits on is decided per game (rule 9). Any text about a hidden place, whether a rumour, a clue, a history
   line or a future LLM retelling, may say its region, never its tile, until it is discovered or revealed (Travel &
   Map rule 15).
5. **The fixed cast is 60–100 people** (user decision 2026-11-15). Each is authored with a name, sex, birth year, sect
   and rank (or none), realm, home place, start location, NPC Traits (4 kinds), parents and master, and their fate in
   the chronicle. Roughly: the 30 sect heads, then famous dead legends (records only), wanderers, elders and rivals. A
   dead person is a record only. A living one is a full person in the World Database. The 60–100 count covers the
   living cast and the core legends; dead people named only by the wider chronicle (rule 3) are records outside the
   count (user decision 2026-11-15).
6. **Every living fixed character has a fully authored build** (user decisions 2026-11-15 and 2026-11-20;
   `design/world/cast_builds.json`, exported into `world_history.json`):
   - root and variants, talents, archetype and stage;
   - the main method and up to two auxiliary techniques from the catalogue, with their layers;
   - gear: a named item, or an artifact base, grade and element;
   - the Đạo Đồ start and the targets taken in order (the points walk the shortest route to each, and any left go to
     the start's land);
   - craft skills.

   Every choice is authored. Only an artifact's affixes are rolled, from a stream keyed on the person alone, so the
   build is the same in every game. `export_world.py --check` refuses a build whose technique, item, base, grade, node
   or skill does not exist (Edge Cases). Their Power Rankings rating is not authored: it is measured like everyone
   else's. **Risk:** a Đạo Đồ change can move a target or a route, so the check is re-run after every tree export.
7. **Sect start state is authored in part.** Each of the 30 sects has a table row with its alignment, its four
   development levels (Holdings, Institutions, Military, Trade) and its treasury, and each minor sect also its
   starting loyalty, as Sects & Missions Open Question 9 deferred. The leader's traits come with the cast (rule 5).
   Every level must be at or below that GDD's F1 settle level (12 for a tier-1 sect, 9 for tier-2, 4 for a minor
   sect), and every loyalty above the break line of 30. **Dials are not authored** (user decision
   2026-11-15): at step 2 the engine sets each dial to its formula target (Sects rule 13). **Attitudes start at their
   F7 target, and the target includes authored grudges** (user decision 2026-11-15, replacing "no authored feud"). A
   grudge is a pair of sects, a value (guess: −5 to −30) and the landmark war or fall that left it; it is Sects F7's
   term `g` and fades toward 0 by `grudge_fade` (guess: 1) a year. No pact is authored. Checking reports every pair
   whose starting attitude is at or below the feud line (−40), so a feud at the start is always a choice. The table is data, in
   `design/world/sect_start_proposal.json`.
8. **The random cultivators fill the headcount left over.** For each realm, the target headcount (5,000 in all, never
   below 3,000, shares from Realms & Bottlenecks) minus the fixed cast's living members in that realm. A realm the
   cast already fills gets none. **Where they start** (user decision 2026-11-20):
   - each sect fills to Sects F17's target (0.9 × its F2 capacity, cap_base × (1 + i × Institutions)), with members
     drawn from the shuffled fill and ranked by realm (Sects rule 7), about 4,100 of 5,000;
   - the rest settle in settlements by Travel & Map Formula M's weights, at the share that brings everyone (sect
     members at their seats included) to npc_settled_share 0.85;
   - the remainder choose wild ground in a region (the top npc_wild_pick_top of its wild places by density × land
     match for their root).

   Each random cultivator gets a short generated personal history that fits inside the chronicle: no event before the
   person was born or old enough for their realm, none in a sect before its founding year (the join year is Formula
   D's), and a master only if that master was in the sect then and is of a higher realm (a member has one with
   master_share 0.3, a guess).
9. **Hidden spots are rolled once per game, per slot.** For each hidden slot and each tile secret, the seed picks one
   of its candidate tiles (2–3 hand-picked candidates). Each pick uses a keyed stream (ADR-0002), keyed on the game
   seed and the slot's stable id, so the picks do not depend on the order the slots are processed or on one another's
   draws. Two hidden places never take the same tile: Checking refuses any overlap between candidate sets, so no
   collision can happen. Each resource site's reserve is picked from its hand-set sizes the same way.

   **As built** (2026-11-20): each hidden slot becomes a World DB place at its rolled tile, marked hidden: seen by no
   one, in no view and in no travel list until found (Travel & Map rules 15–17), with its tile part's land qi and a
   name from its history (a dead cultivator's abode, a vanished sect's ruin). A hidden blessed land's layer 3 turns on
   when it is found. Each resource site's start reserve is rolled the same way (kind `reserve`, keyed on the site's
   continent id) from Travel & Map's hand-set sizes.
10. **The ledger of truth is saved and never shown.** The rolled spots and reserves are written to a per-game table.
    Clues (Travel & Map rule 16) read it. Nothing in the player's interface does. The ledger lives in the built world's
    own record (World DB table `world`, record `w_meta`, with the builder, data and map versions and the seed). The
    debug view of that record shows only its size.
11. **Every game starts on the same date,** the world's authored starting year of the Thiên Nguyên calendar. The
    chronicle covers 1,200 years (user decision 2026-11-15): year 0 is its first event and the starting year is 1,200.
    The old generator's 300 years was a placeholder. The span is authored, not rolled.
12. **The player is made last,** after the world exists. The player is never in the random pool. The origin sets the
    start place, from the approved origins list (30 sect seats, 10 cultivator markets, 7 clan towns), and the
    player's rule for their home region (Travel & Map rule 14).
13. **The save holds the world.** Generation runs once, at a new game, and the result is written to the save. Loading a
    save never regenerates; the seed is only a record. The terrain is not copied into the save: it is read from the
    versioned data files, and the save records the map version (user decision 2026-11-15). **The map version** is a
    hash of the terrain files (the tile grid and the land-qi layers, `world_continent.json` `map_version`, stamped by
    `export_continent.py`). The built world records it, and loading a save made on another map version is refused with
    both versions named (built 2026-11-20). Generation must finish inside the load budget in ADR-0003 decision 12
    (measured 2026-11-20: 9.8 s for 5,032 people against 30 s).
14. **Text stands alone; an LLM may retell it later.** Every player-facing text this system produces is authored or
    built from templates over World Database facts: the chronicle's lines, each random cultivator's personal history
    (sentence templates per history-event kind, in a data file this GDD owns) and the sect and place descriptions. No
    step calls an LLM (LLM features parked, user decision 2026-11-15). **The hook stays open:** every event and
    personal-history record keeps its facts (ids, year, kind, place) separate from its text, so a later LLM layer,
    when it is switched on, can retell the same facts in its own words. It may never add a fact, a number or a hidden
    tile (rule 4), and the template text is the fallback whenever the LLM is off or fails.
15. **Territory has a history** (user decision 2026-11-15). Land changes hands by region, or by a named part of a
    region, only at dated landmark events (a conquest, a fall, a gift, a vassal changing lord). Each such event lists
    the land it moves, from whom and to whom. A past year's map is worked out backwards from the approved year-1,200
    territories by undoing those changes in reverse order, so year 1,200 always gives the approved map. Land with no
    holder in a past year is wild. Cities and towns record a founding year, and a ruined city records its founding
    and ruin years and the event that ruined it.

### States and Transitions

| State | Meaning | Entered when | Leaves to |
|---|---|---|---|
| **Unbuilt** | No world exists for this game | A new game is requested | Checking |
| **Checking** | The authored files are validated before anything is built (Edge Cases lists every check) | Unbuilt | Building (all checks pass), Failed (any check fails) |
| **Building (step n)** | Steps 1–9 of Core Rule 1 run in order, in memory | Checking passes | Building (step n+1), Built (step 9 done), Failed (a step cannot finish), Unbuilt (the player cancels the load) |
| **Built** | The finished world is written to the save in one write | Step 9 done | Loaded (the game begins) |
| **Loaded** | The world lives in the World Database, saved and restored with the game. Authored layers are read-only. Everything after this is the Living World Tick's job | Built, or a save is loaded | (end of the game; a load never returns to Building) |
| **Failed** | Generation stopped with a named reason; nothing was saved | Checking or Building | Unbuilt (the player returns to the new-game screen) |

- **A world is saved whole or not at all.** Generation works in memory and writes the save only on reaching Built. A
  failure or a cancel leaves no half-made world behind.
- **There is no way back.** A built world is never regenerated or patched by this system. A change to authored data
  takes effect only in the next new game. An old save keeps the world it was built with, and the data version is
  recorded in the save (Edge Cases covers a save from an older data version).

### Interactions with Other Systems

| System | Direction | Data that flows | Owner of the interface |
|---|---|---|---|
| **Config** (#1), **Simulation Core** (#2) | in | The authored data files; keyed random streams (ADR-0002) | Config; this GDD for the keys |
| **Time & Turn** (#4) | in | The authored starting date, which every game uses | Time & Turn |
| **World Database** (#3) | out | Regions, places, sects, people, items, the chronicle (as events) and the Power Rankings table; plus the per-game ledger of rolled hidden spots and reserves | World Database for the tables; this GDD for what is written |
| **Save/Load** (#5) | out | The built world in one write, the game seed and the authored-data version | Save/Load |
| **Travel & Map** (#25) | out / in | In: the authored continent, the 28 hidden slots with their candidate tiles, the 80 tile secrets, and the site reserve sizes. Out: the rolled spot for each, in the ledger | Travel & Map owns candidate rules (rules 15, 28, 29); this GDD owns the roll |
| **Sects & Missions** (#26) | out / in | Out: the 30 sects, leaders, vassal ties and authored starting state (Core Rule 7). In: the F1 settle levels that cap that state | Sects & Missions owns F1; this GDD owns the starting table |
| **Realms & Bottlenecks** (#8) | in | `world_cultivators` and its minimum, realm shares, and the minimum age for each realm | Realms |
| **NPC Builds** (#24) | in | Builds for the random cultivators; the validator that checks every fixed character's authored build | NPC Builds |
| **NPC Traits** (#42) | in / out | Out: the fixed cast's authored traits, parents and masters. In: trait rolls for the random cultivators | NPC Traits owns the rolls; this GDD owns the authored values |
| **Item Database** (#13) | in / out | Out: where each unique named item starts (rule 20d). In: the item templates and their tiers | Item Database |
| **Power Rankings** (#44) | out | Every person created; provisional ratings, plus the capped coarse panels (rule 16, `worldgen_fight_budget`) | Power Rankings |
| **Regional Economy & Trade** (#43), **Trade Goods** (#45) | out | Site reserves and, at world build, the site yield tables Trade Goods builds once the world is fixed | Regional Economy; Trade Goods |
| **Living World Tick** (#28) | out | A Loaded world. The chronicle stays read-only; the tick appends new events to the same log after the start | Living World Tick |
| **LLM Game Master** (#29, parked) | out (optional, later) | The same facts and texts, to retell when it is switched on (Core Rule 14), with hidden tiles withheld (Core Rule 4); never required | LLM Game Master |
| **New-game screen** (Game UI #37) | out | Progress through the build steps, a named failure reason, and the origin choice list | Game UI |
| **NPC Relationships** (#46) | out | The fixed cast's authored ties (10 master ties, parents) become sư đồ and kin records at the start; generated kin and masters (`master_share`) likewise (`npc-relationships.md` rule 8, AC-NR-30) | NPC Relationships |

## Formulas

### A. Realm headcount targets

The realm_target formula is defined as:

`N = max(world_cultivators, world_cultivators_min)`
`raw_r = N × c_r / Σ c`
`T_r = ⌊raw_r⌋ + 1 if r is among the (N − Σ⌊raw⌋) realms with the largest raw_r − ⌊raw_r⌋ (ties to the lower realm), else ⌊raw_r⌋`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| world_cultivators | int | 3,000–8,000 (safe) | data file (Realms, `people.world_cultivators`, 5,000) | Requested world size |
| world_cultivators_min | int | 3,000 | data file (Realms) | Floor for the world size |
| N | int | ≥ 3,000 | calculated | The world size actually built |
| c_r | float | > 0 | data file (`realm_start_share`) | Weight of realm r. Starts as Realms' solved headcounts at 5,000: 3,936 / 844 / 191 / 27 / 3 |
| T_r | int | 0–N | calculated | Target headcount of realm r |

**Output Range:** Σ T_r = N exactly. At 5,000 the targets are 3,935 / 844 / 191 / 27 / 3. At 3,000 they are
2,361 / 506 / 115 / 16 / 2. A zero or negative c_r is refused by Checking.
**Example:** N = 5,000. raw = 3,935.21 / 843.83 / 190.96 / 26.995 / 2.9994, so the floors sum to 4,996. The 4 largest
fractions (.9994, .995, .96, .83) each get +1: Hóa Thần 3, Nguyên Anh 27, Kết Đan 191, Trúc Cơ 844. Luyện Khí is 3,935.
**Note:** the data file today holds different weights (79.4 / 16.7 / 3.8 / 0.53 / 0.06). They give 3,951 Luyện Khí and
26 Nguyên Anh. Realms owns the targets, so the data must be replaced by the solved counts above.

### B. Random fill

The random_fill formula is defined as:

`F_r = T_r − K_r`, where Checking requires `K_r ≤ T_r(N_min)` for every realm

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| K_r | int | 0–T_r(N_min) | calculated | Living fixed-cast members in realm r |
| T_r(N_min) | int | see A | calculated | Realm r's target at the smallest world, N = 3,000 |
| F_r | int | ≥ 0 | calculated | Random cultivators generated in realm r |

**Output Range:** F_r ≥ 0, and Σ (K_r + F_r) = N exactly. Checking enforces the bound against the smallest world,
because that is where the rare realms are tightest.
**Example:** N = 5,000 and the cast has K = 10 / 20 / 25 / 9 / 1. Then F = 3,925 / 824 / 166 / 18 / 2, which is 4,935
in all, so the world has 65 + 4,935 = 5,000. At N = 3,000 the same cast has T_Hóa Thần = 2 ≥ 1, so it is valid.

### C. Hidden-spot pick

The slot_pick formula is defined as:

`i = stable_hash(game_seed + ":" + kind + ":" + slot_id) mod n`, and the slot takes candidate `i` of its authored list

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| game_seed | string | any | calculated (Save/Load) | The seed chosen at the new game |
| kind | string | `slot`, `tile_secret`, `reserve` | constant | Keeps the three families from sharing keys |
| slot_id | string | stable | data file (authored) | A slot's id (e.g. R-1, S1-1) or a resource site's id |
| n | int | 2–4 | data file (authored) | Number of candidates (or reserve sizes). The data holds 2 or 3 |
| i | int | 0 to n−1 | calculated | The chosen candidate |

**Output Range:** i from 0 to n−1. n < 2 is refused by Checking, since 0 divides by zero and 1 is not a roll.
**Example:** with an illustrative hash of 1,234,567,891 and n = 3, the digit sum is 46 and 46 mod 3 = 1, so the slot
takes its second candidate.
**Order-free:** every pick depends only on the seed and its own id, never on another slot. The authored candidate sets
are pairwise disjoint (checked on the approved data), so two hidden places can never land on the same tile, and no
collision rule is needed.

### D. Join window of a random cultivator in a sect

The join_year formula is defined as:

`lo = max(Y0 − a + 16, f_s)`, then `join_year = lo + stable_hash(game_seed + ":join:" + realm + ":" + k) mod (Y0 − lo + 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| Y0 | int | authored | data file (chronicle) | The starting year |
| a | int | ≥ age_min_by_realm[r] (16 / 30 / 80 / 200 / 500) | calculated (NPC Builds) | The person's age at the start |
| f_s | int | ≤ Y0 | data file (authored sect) | The sect's founding year |
| k | int | 0 to F_r − 1 | calculated | The person's index within its realm's random fill |
| join_year | int | lo to Y0 | calculated | The year the person joined |

**Output Range:** lo ≤ Y0 always, because a ≥ 16 and f_s ≤ Y0, so the window is never empty. A person aged exactly 16
joins in Y0.
**Example:** a = 40 and f_s = Y0 − 150: lo = Y0 − 24, so the join year is one of 25 values from Y0 − 24 to Y0. At
a = 200 the window starts at the founding, Y0 − 150.

**Feedback loops:** none. Generation runs once and nothing it writes feeds back into itself. The world-generation
fight budget (`worldgen_fight_budget`) belongs to Power Rankings.

## Edge Cases

**Checking (any failure ends in Failed, names its cause, and saves nothing)**

- **If an authored file is missing, unreadable or fails its schema:** Failed, naming the file and the first bad field.
- **If a file's authored-data version differs from the version the generator expects:** Failed, naming both versions.
- **If a hidden slot or tile secret has fewer than 2 candidates, or two candidate sets share a tile:** Failed, naming
  the slots.
- **If any realm weight `c_r` is zero or negative:** Failed, naming the realm.
- **If the living cast has more people in a realm than that realm's target at N = 3,000 (`K_r > T_r(N_min)`):**
  Failed, naming the realm, K and T.
- **If a chronicle event, a cast record or a sect row names an id that does not exist** (person, sect, place, slot,
  item, parent or master): Failed, naming the event or record and the missing id.
- **If a person acts in an event after their death year, or before they were old enough for the realm they hold
  (`age_min_by_realm`):** Failed, naming the person and the event.
- **If a war or fall event comes before the founding year of either sect:** Failed, naming the event and sect.
- **If a hidden slot has no origin event in the chronicle, or an event names a slot that is not in the slot list:**
  Failed, naming it.
- **If a sect has no living leader in the cast, or has two:** Failed, naming the sect.
- **If a living cast member's authored build fails the NPC Builds validator** (a technique, art, item or Đạo Đồ
  node that no longer exists): Failed, naming the person and the missing id. This is the Core Rule 6 risk, and it
  will trigger whenever the tree changes.
- **If a sect's authored development level is above Sects' F1 settle level, or a vassal's start loyalty is at or
  below the break line of 30:** Failed, naming the sect, the field and both values.
- **If the cast has fewer than 60 or more than 100 people:** the Checking report shows a warning, and the build
  continues. The size is a design target, not a rule the data can break.

**Building**

- **If a realm's target is already filled by the cast (`F_r = 0`):** that realm gets no random cultivators. This is
  not an error.
- **If no one in a sect qualifies as a master for a random cultivator** (nobody there at that time, or nobody of a
  higher realm): the person has no master.
- **If a unique named item is authored as held by a cast member or in a chronicle event:** it starts there. Item
  Database rule 20d then places only the items still unplaced, so every unique named item has exactly one record
  (AC-ID-90). **Its random holders are drawn from the random cultivators only** (2026-11-20): the cast's gear is
  authored, so it is the same in every game.
- **If a famous site names no region** (the famous blessed lands name only their sect): its region is the one its tile
  lies in, read from the tile grid.
- **If two chronicle events share a year:** the log orders them by year, then by event id, ascending.
- **If a step throws, or generation runs past the load budget:** Failed, naming the step number. Nothing is saved.
- **If the player cancels while Building:** the half-built world is discarded and the game returns to Unbuilt. Nothing
  is saved.

**Seeds and saves**

- **If the player starts a new game again hoping for closer hidden places:** allowed. Every new game restarts the
  life from zero, so a re-roll costs the whole start, and this GDD does not block it.
- **If the same seed is used after the authored data changed:** the world can differ, because the seed is only a
  record (Core Rule 13). The save records the data version.
- **If a save's data version is older than the game's:** the save loads with the world it holds and is never rebuilt
  or patched. If the game can no longer read that version, loading is refused with the version named. It is never
  silently upgraded.

## Dependencies

**This system needs (upstream)**

| System | Strength | What it supplies | Named back in that GDD? |
|---|---|---|---|
| Data-Driven Config (#1) | Hard | The authored data files and their loader | no GDD |
| Deterministic Simulation Core (#2) | Hard | Keyed streams (ADR-0002) | no GDD |
| World Database (#3) | Hard | The tables written (Interactions) | no GDD |
| Time & Turn (#4) | Hard | The calendar that the starting year sits in | no GDD |
| Save/Load (#5) | Hard | The one-write save and the data version | no GDD |
| Realms & Bottlenecks (#8) | Hard | World size, realm targets and minimum ages | yes (Realms' integration table) |
| Item Database (#13) | Hard | Unique named item templates and placement rule 20d | yes (hard) |
| NPC Builds (#24) | Hard | Random builds and the validator that checks fixed ones | no GDD |
| Travel & Map (#25) | Hard | The authored base, the slots, candidate rules and secrets | yes (hard) |
| Sects & Missions (#26) | Hard | The sect formats and the F1 settle cap on start state | yes (hard) |
| NPC Traits (#42) | Soft | The trait catalogue and the rolls for random people | yes (soft) |

**Depends on this system (downstream)**

| System | Strength | What it takes | Named in that GDD? |
|---|---|---|---|
| Travel & Map (#25) | Hard | The rolled hidden spots, tile secrets and reserves | yes |
| Sects & Missions (#26) | Hard | The authored sects, leaders and starting state | yes |
| Realms & Bottlenecks (#8) | Soft | The starting realm shares and world size | yes |
| NPC Traits (#42) | Soft | The fixed cast's traits, parents and masters | yes |
| Item Database (#13) | Hard | Where each unique named item starts | yes |
| Power Rankings (#44) | Soft | Every person created, for provisional ratings and coarse panels | yes (row added 2026-11-15) |
| Regional Economy & Trade (#43) | Hard | Site reserves | yes (row added 2026-11-15) |
| Trade Goods (#45) | Hard | The fixed world, for the yield tables built at world build | yes (row added 2026-11-15) |
| Event Engine (#23) | Soft | The fixed cast, history's hidden places and the chronicle as story anchors; authored stories started at world generation (Event Engine rule 12) | yes (row added 2026-11-15) |
| Living World Tick (#28) | Hard | A Loaded world and the chronicle | no GDD |
| LLM Game Master (#29, parked) | Soft, optional | The same facts and texts, to retell later (Core Rule 14); never required | no GDD |
| Game UI (#37) | Soft | Build progress, failure reasons and the origin list | no GDD |
| NPC Relationships (#46) | Soft | The cast's authored ties | yes (2026-11-20) |

**Rows added in other GDDs (2026-11-15):** Power Rankings, Regional Economy & Trade and Trade Goods each now list #27
in their Dependencies.

## Visual/Audio Requirements

This system has no effects of its own. The only thing the player sees is the **new-game build screen**.

- **Visual:** the screen shows the painted overview of the continent, which every character already knows (Fixed
  World decision 2026-11-13). Progress through the nine steps is drawn on it. Step 2 tints the seven great sects'
  territories. **No hidden place, slot or ledger tile is ever drawn**, since that would give away Core Rules 4 and 10.
  Only permanent landmarks show, and borders and sects are overlays, as in the map's art direction. Its style follows
  the map style, which is still to be picked from `prototypes/map-style-demos` (art bible pending).
- **Audio:** no dedicated audio. A single short cue when the world reaches Built is for Audio (#38) to define.

`art-director` not consulted: Lean mode. Review manually before production.

📌 **Asset Spec:** Visual/Audio requirements are defined. After the art bible is approved, run
`/asset-spec system:world-generation`.

## Game Feel

The player does not operate this system, so the feel targets are about the wait. Both numbers below are guesses to be
playtested:

- The build screen never goes more than **2 s** without visible progress, and every one of the nine steps shows its
  own progress.
- Cancel takes effect within **1 s** and returns to the new-game screen with nothing saved.
- The screen keeps animating throughout (the build must not freeze the main thread).

## UI Requirements

- **Origin list** (new-game screen): the 47 choices in three groups (sect disciple: 30 seats, loose cultivator: 10
  markets, clan heir: 7 towns). Each shows its place, region and sect or clan. The numbers it implies are visible
  (Pillar 2).
- **Build progress:** the nine steps in plain words, the current step marked, a running count of people made, and a
  Cancel button.
- **Failure screen:** the cause in plain words (file or step), with a **Copy report** button giving the full Checking
  message. A warning, such as the cast-size warning, appears only in the debug terminal and the log, not to the
  player.
- **Seed:** an optional seed field on the new-game screen (blank = random); the seed shows on the pause screen and in
  the save list, so it can be shared (user decision 2026-11-15).
- **Not shown anywhere:** the seed's ledger, and any hidden tile.

📌 **UX Flag, World Generation & History:** this system has UI requirements. In Pre-Production, run `/ux-design` for
the new-game screen **before** writing epics.

## Cross-References

| This GDD says | Source | Where it is used |
|---|---|---|
| Sect start state deferred here; F1 settle levels cap it | `sects.md` Open Question 9, F1 | Core Rule 7, AC-WG-10, AC-WG-31 |
| Hidden places, secrets, home regions, per-game rolls | `travel-map.md` rules 14–16, 28, 29, 33; Open Question 13 | Core Rules 4, 9, 10, 12; AC-WG-13, AC-WG-32 |
| World size, headcounts, minimum ages | `canh-gioi.md` Formulas C2, `people.world_cultivators`, AC-CG-69 | Formulas A, B, D; AC-WG-21, AC-WG-33 |
| Unique named items are placed once | `item-database.md` rule 20d, AC-ID-90 | Core Rule 1 step 7, AC-WG-27 |
| Provisional ratings and the capped coarse panels | `power-rankings.md` rule 16, `worldgen_fight_budget` | Core Rule 1 step 8, AC-WG-30 |
| Authored people's traits, parents and masters | `npc-traits.md` interaction rows | Core Rule 5 |
| Yield tables built at world build | `trade-goods.md` | Interactions |
| Keyed streams; the load budget | ADR-0002; ADR-0003 decision 12 | Formulas C, D; Core Rule 13; AC-WG-34 |
| The fixed world's decisions and the authored map | `design/research/fixed-world-decisions.md`, `design/map/continent-11/` | Overview, Core Rules 1–5, 9 |
| `world_headcount_targets` | `design/registry/entities.yaml` (owner Realms) | Formula A |
| The authored cast: 72 people, 4 vanished sects, 10 master ties, the 30 sects' founding years | `design/world/cast_proposal.json` (approved 2026-11-15) | Core Rules 5, 6, 7; Formula B; AC-WG-07 |
| The authored chronicle: 195 landmark events (one origin event for each of the 28 hidden slots among them) and 312 annals | `design/world/chronicle_proposal.json`, `design/world/annals_proposal.json` (approved 2026-11-15) | Core Rules 3, 4, 11; AC-WG-04, AC-WG-05 |
| The territory history: 6 eras, every land change, 16 wars, 7 more fallen sects, grudges | `design/world/territory_history_proposal.json` (approved 2026-11-15) | Core Rules 7, 15; AC-WG-37, AC-WG-38 |
| Dead records named only by the wider chronicle (14) and the legendary items as lore (34) | `design/world/records_proposal.json`, `design/world/legendary_items_proposal.json` (approved 2026-11-15) | Core Rule 5; Item Database rule 20d |
| The history's places: 15 promoted cities, every city's founding year, 17 fixed ruins, the named parts | `design/map/continent-11/history_places_proposal.json` and `tools/design/map/history_places.py` (approved 2026-11-15) | Core Rule 15; Travel & Map rule 6 |
| The 30 sects' start states: alignment, four levels, treasury, loyalty | `design/world/sect_start_proposal.json` (approved 2026-11-15) | Core Rule 7; AC-WG-10 |
| Traits for the 51 living cast members: 3 personality, 1 calling, 5 fate-given | `design/world/leader_traits_proposal.json` (approved 2026-11-15) | Core Rule 5; NPC Traits #42 |

**Still to change in other files:** the Sects Open Question 9 and Travel & Map Open Question 13 should point here now
that the authoring pass is done. Done 2026-11-15: the #27 Dependencies rows in Power Rankings, Regional Economy &
Trade and Trade Goods, and the `realm_distribution` weights in `assets/data/world_generation.json`.

## Acceptance Criteria

**Core Rules**

- **AC-WG-01** [Integration] Rule 1. GIVEN a new game, WHEN generation runs, THEN the log shows steps 1–9 start and
  end in order, and no step reads a table that a later step writes.
- **AC-WG-02** [Logic] Rule 2. GIVEN the same authored files and seed, WHEN a world is built twice in separate runs,
  THEN the two World Database dumps are byte-identical. WHEN the seed differs, THEN only the ledger, the random
  cultivators and the reserves differ.
- **AC-WG-03** [Logic] Rule 2. GIVEN any built world, WHEN the regions, places, sects, chronicle and cast tables are
  hashed and compared with the authored files, THEN there are zero differences.
- **AC-WG-04** [Config/Data] Rule 3. GIVEN the chronicle files, THEN the landmark file holds 150–250 events and the
  annals file 300–500, each with an id, a year before the start, a kind, ids that exist, a place or region and one
  line of text.
- **AC-WG-05** [Integration] Rule 3. GIVEN a built world, THEN the event log holds exactly the events of both tiers
  (same ids, years and text) and no other event dated before the start.
- **AC-WG-06** [Logic] Rule 4. GIVEN the chronicle, THEN no event contains the tile of a hidden slot. GIVEN a built
  world, WHEN any text about an undiscovered hidden place is built (a template rumour or clue, or an LLM fact packet
  when it is on), THEN it names the region and no tile.
- **AC-WG-07** [Config/Data] Rule 5. GIVEN the cast file, THEN it has 60–100 records (a warning outside that range),
  every living record has every field, and it includes the 30 sect heads.
- **AC-WG-08** [Integration] Rule 6. GIVEN each living cast member, WHEN the authored build is run through the NPC
  Builds validator, THEN it passes. WHEN a fight sheet is built from it under two different game seeds, THEN the two
  sheets are identical.
- **AC-WG-09** [Logic] Rule 6. GIVEN a cast build that names a Đạo Đồ node that does not exist, WHEN Checking
  runs, THEN the state is Failed, the message names the person and the node, and nothing is saved.
- **AC-WG-10** [Config/Data] Rule 7. GIVEN the sect start-state table, THEN it has 30 rows, every development level
  is at or below Sects' F1 settle level (12, 9 or 4 by tier), every minor sect's loyalty is above 30, and the table
  holds no dial or attitude.
- **AC-WG-11** [Logic] Rule 8. GIVEN N = 5,000 and a cast of 65, THEN every realm's count equals its target and the
  world has exactly 5,000 living cultivators.
- **AC-WG-12** [Bot] Rule 8. GIVEN 30 fixed seeds built through step 7, THEN across all random cultivators there are
  zero violations of: an event before age 16, an event before the person's sect was founded, or a master who was not
  in that sect at that year or who is not of a higher realm.
- **AC-WG-13** [Logic] Rule 9. GIVEN 100 fixed seeds, THEN every picked tile is one of its slot's candidates, no two
  hidden places share a tile, and every candidate of every slot is picked at least once.
- **AC-WG-14** [Logic] Rule 9. GIVEN the slot list processed in reverse order, THEN every pick is unchanged.
- **AC-WG-15** [Integration] Rule 10. GIVEN a built world, THEN the ledger has one row for each of the 28 slots, 80
  tile secrets and each resource site, and no player-facing table contains a ledger tile.
- **AC-WG-16** [Integration] Rule 11. GIVEN 5 different seeds, THEN the starting date is the authored date in all 5.
- **AC-WG-17** [Integration] Rule 12. GIVEN each of the 47 origin choices (30 sect seats, 10 markets, 7 clan towns),
  WHEN the player is made, THEN the player starts at that origin's place, is not in the random pool (the world holds
  N + 1 people) and is created after step 8.
- **AC-WG-18** [Integration] Rule 13. GIVEN a saved new game, WHEN it is loaded, THEN the generator is called 0 times
  and the loaded world equals the saved one. The save holds the seed and the data version.

**States**

- **AC-WG-19** [Logic] GIVEN a failure forced at step 5, THEN the state is Failed, no save file exists and the message
  names step 5.
- **AC-WG-20** [Integration] GIVEN a cancel during step 3, THEN no save is written and the state is Unbuilt.

**Formulas**

- **AC-WG-21** [Logic] Formula A. GIVEN weights 3,936 / 844 / 191 / 27 / 3, THEN N = 5,000 gives 3,935 / 844 / 191 /
  27 / 3 and N = 3,000 gives 2,361 / 506 / 115 / 16 / 2. A `world_cultivators` of 0 builds N = 3,000. The targets sum
  to N at N = 3,000, 5,000 and 8,000.
- **AC-WG-22** [Logic] Formula A. GIVEN any weight at 0, THEN Checking is Failed and names the realm.
- **AC-WG-23** [Logic] Formula B. GIVEN K = 10 / 20 / 25 / 9 / 1 at N = 5,000, THEN F = 3,925 / 824 / 166 / 18 / 2.
  GIVEN 3 Hóa Thần in the cast, THEN Checking is Failed (the target at N = 3,000 is 2). GIVEN K_r = T_r, THEN F_r = 0
  and there is no error.
- **AC-WG-24** [Logic] Formula C. GIVEN n = 0 or 1, THEN Checking is Failed. GIVEN an injected hash of 1,234,567,891
  and n = 3, THEN the pick is candidate index 1.
- **AC-WG-25** [Logic] Formula D. GIVEN a = 16, THEN the join year is Y0. GIVEN a = 40 and f_s = Y0 − 150, THEN every
  join year over 1,000 samples lies in Y0 − 24 to Y0.

**Edge Cases**

- **AC-WG-26** [Logic] Edge Cases (Checking). GIVEN, for each of the 12 failing Checking cases, a minimal data file
  that breaks only that rule, THEN generation ends Failed with a message that names the stated cause, and no save is
  written. Each case was seen to fail before it was counted as covered. For the cast-size case, GIVEN a cast of 59 or
  101, THEN the Checking report shows a warning and the build continues.
- **AC-WG-27** [Logic] Edge Cases (Building). GIVEN a unique named item authored as held by a cast member, THEN the
  world holds exactly one record of every unique named template (extends AC-ID-90).
- **AC-WG-28** [Logic] Edge Cases (Building). GIVEN two chronicle events in one year, THEN the log orders them by
  event id ascending.
- **AC-WG-29** [Integration] Edge Cases (Seeds and saves). GIVEN a save whose data version the game can no longer
  read, THEN loading is refused and names the version. GIVEN a readable older version, THEN it loads unchanged.

**Across systems**

- **AC-WG-30** [Integration] Power Rankings. GIVEN a built world, THEN every living person has a rating row, the
  fights run at build stay within `worldgen_fight_budget` (8,000), and the people outside the load set are
  Provisional or Stale as Power Rankings rule 16 says.
- **AC-WG-31** [Integration] Sects & Missions. GIVEN a built world, THEN each of the 30 sects has exactly one living
  head and Sects' F1 check passes on the start state.
- **AC-WG-32** [Integration] Travel & Map. GIVEN a built world, THEN each rolled hidden spot equals one of the
  authored candidates, so it satisfies Travel & Map's ground rules for its kind.
- **AC-WG-33** [Integration] Realms. GIVEN a built world, THEN Realms' AC-CG-69 census check passes.
- **AC-WG-34** [Integration] Performance. GIVEN a release build on the reference machine, WHEN a 5,000-cultivator
  world is built, THEN generation finishes within ADR-0003 decision 12's load target (120 s at the time of writing).
  Test runs for AC-WG-12 and AC-WG-13 build through step 7 only, so they skip the fights.
- **AC-WG-35** [UI] Game UI. GIVEN the new-game screen, THEN it shows the build step and, on failure, the named
  cause. This needs a retained screenshot in `production/qa/evidence/`, and it cannot be tested until Game UI (#37)
  is built.
- **AC-WG-36** [Integration] Rule 14. GIVEN the LLM switched off, WHEN a world is built and its history and people are
  shown, THEN every chronicle line, personal history and sect and place description has text, and generation makes
  zero LLM calls.
- **AC-WG-37** [Logic] Rule 15. GIVEN the landmark chronicle, WHEN the territory changes are undone back to any year,
  THEN every tile has at most one holder (a region and a named part of it may differ), no land is held by a sect
  before its founding year or after its fall, every vanished sect's ruin-slot candidates lie on land it or its lord
  held while it lived,
  and replaying the changes forward from year 0 gives exactly the approved year-1,200 territories.
- **AC-WG-38** [Logic] Rule 7, grudges. GIVEN a grudge of −20 between two sects, WHEN the world is built, THEN that
  pair's F7 target includes −20; after 5 years at `grudge_fade` 1 it includes −15, and after 20 years 0. GIVEN no
  grudge, THEN the pair starts at its plain F7 target.
- **AC-WG-39** [Integration] Rule 3, secret events. GIVEN a built world with a secret event (C097), WHEN the codex,
  rumours and NPC talk are built before the player discovers it, THEN none of them shows the event or its text; WHEN
  it is discovered, THEN it shows like any other event.

**Gaps found:** there is no criterion for whether the world *feels* learnable and remembered; that is a playtest
question, not a test. AC-WG-34 and AC-WG-35 cannot run today: no 5,000-person fixed-world build exists yet, and Game
UI is not built.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Who are the 30–70 cast members besides the 29 sect heads: names, roles, realms, home places?~~ **Answered 2026-11-15:** the roster is drafted and approved in `design/world/cast_proposal.json`: 69 people (51 living: 14 Nguyên Anh, 30 Kết Đan, 4 Trúc Cơ, 1 Luyện Khí, 2 Hóa Thần; 18 dead records), plus 4 vanished sects and 10 master ties. **Traits for all 51 living are approved 2026-11-15** in `design/world/leader_traits_proposal.json` (3 personality traits from 3 sets and 1 calling each; 5 people also hold a fate-given trait). **Still open:** the fully authored builds for the 51 living (Core Rule 6; Open Question 4) | user, world-builder | Roster and traits answered; builds open |
| 2 | ~~How long is the chronicle in years, and what is the starting year?~~ **Answered 2026-11-15:** 1,200 years, starting year 1,200 (Core Rule 11). The 7 great sects are founded 700–1,100 years ago and the three-sect battlefield war about 400 years back. **The chronicle itself is drafted and approved 2026-11-15** in `design/world/chronicle_proposal.json`: 42 events, with one origin event for each of the 28 hidden slots | user, world-builder | Answered |
| 3 | ~~The 29 sects' starting levels, dials, attitudes, treasuries, alignments and leaders' traits, under F1's settle levels~~ **Answered in part 2026-11-15:** alignments, levels, treasuries and loyalty are approved in `design/world/sect_start_proposal.json` (Thính Vũ Lâu is ma đạo; Xuyên Lâm Môn and Dạ Quang Môn start at loyalty 40); dials and attitudes start at their formula targets, not authored (Core Rule 7). **The 29 leaders' traits are approved too** (3 personality traits from 3 sets and 1 calling each), in `design/world/leader_traits_proposal.json`. Known weaknesses: Military uses wars only, and the treasuries are guesses until Sects' balance run (AC-SM-42) | user, systems-designer | Leaders' traits open |
| 4 | ~~When are the 60–100 hand-built cast builds written, given that the Đạo Đồ shape is parked?~~ **Answered 2026-11-20:** all 54 living builds are hand-authored on the v5 Đạo Đồ (`design/world/cast_builds.json`; review sheet `design/world/cast-builds.md`, awaiting the user's review) | user | Answered |
| 5 | ~~Can the player see, type or share a seed?~~ **Answered 2026-11-15:** the seed shows on the pause screen and in the save list, and the new-game screen has an optional seed field (blank = random). Re-rolling stays allowed (Edge Cases) | user, ux-designer | Answered |
| 6 | ~~Does the save copy the continent's terrain, or read it from files at runtime?~~ **Answered 2026-11-15:** terrain stays in the versioned data files and is not copied; each save records the map version, and a save made on another map version is refused with both versions named (Edge Cases, Seeds and saves). Map hand edits land between releases | user, technical-director | Answered |
| 7 | ~~Replace the old `realm_distribution` weights with Realms' solved counts~~ **Done 2026-11-15:** `assets/data/world_generation.json` now holds 3,936 / 844 / 191 / 27 / 3. The census at seed 101 starts at 3,877 / 896 / 200 / 25 / 2 (the generator still rolls realms at random; Formula A's exact targets come with the rework). AC-CG-69's 2,000-year run was not re-run | gameplay-programmer | Done; AC-CG-69 re-run open |
