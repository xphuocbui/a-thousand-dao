# World Generation & History

> **Status**: Implemented 2026-11-20 (not yet design-reviewed). Every new game's world is built by WorldBuilder
> (`src/gameplay/world/world_builder.gd`) from the exported data (`assets/data/world_history.json` by
> `tools/design/world/export_world.py`, `assets/data/world_continent.json` by `tools/design/map/export_continent.py`);
> plan and evidence: `production/plans/continent-world.md`, `production/qa/evidence/continent-world/`.
> **Author**: user + Claude
> **Last Updated**: 2026-11-25 (world-depth amendment)
> **Last Verified**: 2026-11-20
> **Implements Pillar**: Pillar 5, A World That Remembers
> **Amended 2026-11-25** (user rulings, world-depth pass: `design/world/depth/DECISIONS-2026-11-25.md` groups 1, 2, 3,
> 4 and 10; proposal `design/world/depth/rules-proposals.md` R2-R4 and R8): **the fixed cast grows to about 1,900
> authored people in three depth tiers, every person has a birthplace, the random fill joins sects by admission, and
> sect seats sit on land that fits them** (Core Rules 3a, 5, 5a, 6, 6a, 8, 8a, 16, 16a; Formulas B, E, F, G). The
> amended parts are **designed, not built**: `export_world.py` does not yet read `design/world/depth/`, so their ACs
> (AC-WG-40 to AC-WG-56) cannot run until the depth export exists. **Group 11** (2026-11-25): the world floor
> `world_cultivators_min` rises from 3,000 to 5,000, the kind-to-tier list for the 264 new events is accepted, and the
> zero founder's arrays of two denser seats are intended (Formulas A, B, G; Open Questions 8, 9, 11). **Group 12**
> (2026-11-25): Băng Tâm's and Lạc Hà's arrays re-sized to +0.75 and +0.5 (Formula G), and a `hidden` chronicle kind
> keeps four secrets out of both public tiers until the player uncovers them (rule 3a; Open Questions 9, 11, 15).

## Summary

World Generation & History builds the world a new game starts in, once, before play. The continent, its 30 sects, its
places, a two-tier chronicle (about 150–250 landmark events and 300–500 annals, plus the world-depth pass's new
events, Core Rule 3a) and a fixed cast of about 1,900 authored people in three depth tiers (Core Rule 5, amended
2026-11-25; the old 60–100) are the same in every game. The ordinary cultivators (about 5,000) and the exact spots of hidden ruins, secret realms and
tile secrets are rolled from the game's seed. The player starts in a world with a learnable geography and a remembered
past, and replay variety comes from people and secrets, not from coastlines (Pillar 5, A World That Remembers).

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Data-Driven Config, Simulation Core, World Database, Time & Turn, Save/Load, Realms & Bottlenecks, Item Database, NPC Builds, Travel & Map, Sects & Missions, Spiritual Roots, Provinces; soft: NPC Traits`

## Overview

World Generation & History builds the world a new game begins in. Most of it is authored once and is the same in
every game: the continent with its 20 regions and about 230 places (30 cities and 17 ruins of the history among them), the 7 great sects and 22 minor sects with their lands
and seats, the famous sites and sacred features, and the history that led up to the starting year. A small part is
rolled from the game's seed, and it is the only part that differs between games:

- the ordinary cultivators (5,000 by default and never fewer; 2026-11-25: floor 5,000, was 3,000), generated to fit inside the authored history;
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

   **3a. The world-depth events join both tiers (new, 2026-11-25).** The sect and group pages of the world-depth pass
   write new events with ids `N-<sect or group key>-NN` (`design/world/depth/sects/<key>.md`,
   `design/world/depth/people/<group>.md`, each under "New chronicle proposals", with a year and a kind). The ruling
   called them "~150"; the pages define **264** with a year and a kind (counted 2026-11-25), in about 40 kinds. They
   are authored data like the rest of the chronicle (rule 2) and go in **at export, by kind** (user ruling 2026-11-25):
   - **landmark chronicle:** `seat_moved`, `array_laid`, `sect_founded`, `founding`, `headship`, `item_made`,
     `item_taken`, `item_lost`, `item_found`, `treasure`, `technique_made`, `seal_laid`, `seal_renewed` (a closed
     list: these 13 kinds and no others);
   - **annals:** every other kind except `hidden` (below) (`tale`, `death`, `custom`, `trade`, `rite`, `oath`, `beast`, `settlement`,
     `disaster`, `omen`, `hostage`, `discovery`, `departure`, `craft`, `loan`, `city_burned`, …);
   - **a page may override** the kind's tier with `tier: landmark | annal` on one event;
   - **`secret` is a flag, not a tier.** An event whose page kind is `secret` (5 of them, among them N-nam_pho-04 and
     N-thien_bao-03) goes to the annals with the rule-3 secret flag set and keeps its own kind if the page names one;
     an event the page marks "hidden" (about 40, such as N-thien_xu-04) is secret in whichever tier it lands.
   - **`hidden` is a kind, and it is in neither tier (new, 2026-11-25;** ruling group 12: "kept out of the public
     chronicle and annals until the player uncovers them (event or Codex)"). An event whose page **kind** is `hidden`
     (written `` (1162, `hidden`) `` on the page; 4 today: N-lang_dao-03, N-suong_tung-02, N-thai_chi-04,
     N-van_hac-03) is exported to the World Database's log with the rule-3 secret flag, but is **not** in the landmark
     chronicle or the annals, so no codex timeline, annals entry, rumour, NPC talk or chronicle count reads it. It is
     **uncovered** only by an Event Engine outcome that names its id, or by a Codex entry the player carries from a past
     life (Codex & Karmic Carryover). From then on it is shown in this game **in the annals** (or in the tier its page's
     `tier:` override names) with its secret flag cleared. That default tier is this GDD's reading of the ruling, which
     named no tier (Open Question 15). Three words, three meanings: **`secret`** as a page kind is a flag on an annals
     event; a page's **"hidden"** mark after a kind (`` (803, `tale`, hidden) ``) is the same secret flag in that
     kind's tier; the **`hidden` kind** keeps the event out of both tiers until uncovered.
   - Event years may be a span (`803-806`); the export dates a span by its first year and keeps the span in the facts.

   The kind-to-tier list above was this GDD's proposal for "by kind"; **the user accepted it 2026-11-25** (ruling
   group 11; Open Question 9). By it, 39 of the 264 go to the landmark chronicle and 221 to the annals; the other 4
   (N-lang_dao-03, N-suong_tung-02, N-thai_chi-04, N-van_hac-03), which had no kind, take the kind `hidden` (ruling
   group 12, 2026-11-25) and sit in neither tier until uncovered. **The tier
   sizes grow** (amended 2026-11-25): the landmark chronicle to about 150–280 events, the annals to about 300–800 (the
   approved 316, the provinces-v2 172 and about 220 new).
   **Rewordings** (approved 2026-11-25, applied at the re-export): C007 (Băng Tâm founded "at the desert's edge, facing
   the ice fields"), A190 (Lạc Hà's founder's maples, `sects/lac_ha.md` §2), the `soc_khi` legendary text (sealed alone
   in his cave in 702 by his last disciple), the Thiết Mã tally split in two halves (`thiet_ma_phu`, `sects/thien_xu.md`
   §3 and §10), Cô Hạc's maker (`co_hac` `made_by` Quách Lĩnh Thù, 760), A188's distance (the Tân Khẩu diggers' camp at
   the miasma's edge), and A087 kept true as written through N-thien_xu-04 (`design/world/depth/cross-sect.md` §6).
   The pass also adds one fallen sect, `lanh_huong` (Lãnh Hương Các, ruin place 1412, destroyed at Cô Thành in 724;
   `sects/bang_tam.md`), to `fallen_sects`.
4. **An event never names a rolled tile.** It names a place, a region, or a hidden **slot** (28 of them). Which tile
   the slot sits on is decided per game (rule 9). Any text about a hidden place, whether a rumour, a clue, a history
   line or a future LLM retelling, may say its region, never its tile, until it is discovered or revealed (Travel &
   Map rule 15).
5. **The fixed cast is about 1,900 authored people** (amended 2026-11-25; was 60–100, user decision 2026-11-15). The
   user (2026-11-24): "Don't stop at 100 cast, go 1000 2000"; ruling 2026-11-25: "keep ~1,900 authored people; the
   random fill supplies the rest below (mostly Luyện Khí)". The fixed world is fixed down to the inner disciples of
   every great sect and the named people of every minor sect and outside group. Each person is authored with a name,
   sex, birth year, sect and rank (or none), realm, tier (rule 5a), home place, **birthplace** (rule 5a), start
   location, NPC Traits (the v2 kinds, NPC Traits #42), parents and master, ties, and their fate in the chronicle. A
   dead person is a record only. A living one is a full person in the World Database. Dead people named only by the
   wider chronicle (rule 3) stay records outside the count (user decision 2026-11-15).

   The 18 old records the depth pass did not deepen (all dead, of fallen sects, such as `khuc_ho_gia` and
   `lieu_co_chu`) stay in the cast from the old files, so the fixed cast holds 1,889 + 18 = **1,907 records**; the
   export keeps them (rule 6a), since chronicle events name them.

   **The authored source** is `design/world/depth/sects/<key>[.<n>].cast.json` (50 sects) and
   `design/world/depth/people/<group>[.<n>].cast.json` (hermits and sages, demonic circles, market folk, clans, loose
   north, loose south), 125 files in the format of `design/world/depth/schema.md`. Counted 2026-11-25: **1,889 people,
   1,747 living** (142 dead); **tier A 171, tier B 369, tier C 1,349**; living by realm Luyện Khí 913, Trúc Cơ 632, Kết
   Đan 173, Nguyên Anh 27, Hóa Thần 2. The 106 people of the earlier cast (`cast_proposal.json`, `cast_v2.json`) are in
   it: 88 deepened in place (name, sex, realm, life and death unchanged, diffed against `world_history.json`); the
   other 18 are the undeepened records above. Each sect's realm quotas are in `design/world/depth/quotas.json`
   (great sects 3-4 Nguyên Anh, 12 Kết Đan, 45 Trúc Cơ, 55 Luyện Khí; minor sects 2 Kết Đan, 6 Trúc Cơ, 10 Luyện Khí,
   and 1 Nguyên Anh only in `cung_tinh`, `van_khoi` and `thien_bao`; the outside groups together 3 Nguyên Anh, 25 Kết
   Đan, 60 Trúc Cơ, 100 Luyện Khí; no new Hóa Thần) with world caps 27 / 180 / 670 / 1,000.

   **5a. Depth tiers and the birthplace (new, 2026-11-25).**

   | Tier | Who | Authored record |
   |---|---|---|
   | **A** | sect heads, Nguyên Anh, first elders, famous figures, key disciples | backstory 120-250 words, wants, secret, 6-12 traits (amended 2026-11-25, ruling group 12; over-band people are trimmed at export, NPC Traits rule 2a), ties, full build (rule 6), signature items (a set piece for every living tier A person) |
   | **B** | elders, Kết Đan, notable inner disciples, minor heads' circles | backstory 50-100 words, 5-8 traits, ties, full build (rule 6), 0-1 item |
   | **C** | inner and outer disciples, loose cultivators, clan members | 1-2 sentences, 4-6 traits, a tie, root, main method, a Đạo Đồ start and intent (rule 6) |

   The tier sets the record's depth only: every tier is a fixed person, the same in every game, and none is in the
   random pool. Every living authored person has a **birthplace** (a place id); their authored root already follows it
   (Linh Căn rule 2 is how the fill rolls; the cast's roots are written, not rolled). A dead record may leave it empty
   (21 do).
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

   **Builds by tier (amended 2026-11-25).**
   - **Tier A and B** have the full authored build above, Đạo Đồ targets included: 434 of the 435 living hand-picked
     (the one without is a Luyện Khí disciple with 2 points and nothing in reach, who takes the start's land). Each
     sect's `lineage.tree_route` (2-4 notables its members take early) is authored in its page.
   - **Tier C** (1,312 living) has an authored root, main method, gear, skills and a Đạo Đồ **start and intent**
     (a sentence, no node ids), but no targets. **BuildGenerator** allocates its tree from the start and the
     archetype, as for random people, with a stream keyed on the person's key alone (never the game seed), so a tier C
     tree is the same in every game like every other authored choice.
   - Every route is checked against the person's points, the Chaos gate and the capability realm
     (`tools/design/world/depth_tree.py`, run by `depth_check.py`).

   **6a. The depth export merges, never overwrites (new, 2026-11-25).** The export that folds `design/world/depth/`
   into `assets/data/world_history.json` **merges** into `cast_builds` by person key and never replaces the table:
   - the 48 original authored routes stay as written (they were restored after the depth pass; the 6 people whose
     start changed have new routes in the depth files);
   - a person in both sources keeps the depth file's build, except that an existing `cast_builds` route is kept for
     anyone whose depth record does not author one (this precedence is this GDD's proposal; the depth folder states
     only "merge, never overwrite");
   - a person in `cast_builds` and not in the depth files keeps their row;
   - the same holds for `people`: an old record the depth files do not hold (the 18 undeepened dead, rule 5) is kept
     as it is;
   - the four technique ids the depth writers replaced (`long_tuong_cong`, `kim_cang_the`, `loi_de_chan_kinh`,
     `am_anh_bi_thuat`) stay replaced by the lineage methods (ruling 2026-11-25, group 4; the `changed` notes stand).
   `export_world.py --check` refuses an export that would drop a `cast_builds` row (Edge Cases).
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
   below 5,000 (2026-11-25: floor 5,000, was 3,000), shares from Realms & Bottlenecks) minus the fixed cast's living members in that realm. A realm the
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

   **8a. Birthplace, root, then admission (new, 2026-11-25).** Every random cultivator is created with a
   **birthplace**, and its root is rolled from it (Linh Căn rule 2, Formulas A2 and D4) **before** admission decides
   where it may join. The ruling (2026-11-25, R2): a random member "joins a sect whose admission its root passes,
   preferring its own ground's sects; a root that passes none stays loose". The admission rule itself (which elements,
   at which purity, by rank) is Sects & Missions' (its R2 admission amendment, 2026-11-25; R3 no-lean sects admit any
   root). The fill runs in this order, every draw on a keyed stream (ADR-0002) keyed on the game seed and the
   candidate's index, so the fill does not depend on processing order beyond the order stated here:
   1. **Openings.** A sect's openings are its F17 target minus its **authored living members** (the authored cast
      counts toward the target); a sect whose authored members reach the target has none. Sects are taken in stable
      key order.
   2. **Candidate.** The next person of the shuffled fill (its realm already set by Formula B) is the candidate for
      the opening.
   3. **Birthplace** (Formula E): with chance `local_recruit` (0.75) a settled place in the **sect's own ground**,
      else a settled place anywhere on the continent, both weighted by Travel & Map Formula M's `settle_weight`. A
      sect's own ground is its territory for a great sect, and its lord's territory in the seat's region for a minor
      sect (the seat audit's ground, `design/world/depth/seat-audit.md`). **A Wind lineage** (an innate variant,
      Cửu Cao) draws from anywhere settled: it "recruits by the variant wherever it is born" (ruling 2026-11-25).
   4. **Root.** Rolled from the birthplace's province (Linh Căn rule 2).
   5. **Admission**, tested at the rank the candidate's realm gives (Sects rule 19: rank follows realm). If the root
      passes this sect, the candidate joins it.
   6. **Elsewhere.** If not, the candidate tries the other sects with openings left whose admission it passes:
      first the sects whose own ground holds its birthplace, then every other sect, nearest seat first (ties by
      sect key). It joins the first that passes; the opening it was drawn for takes the next candidate.
   7. **Loose.** A root that passes no sect with an opening stays **loose**, with its birthplace's region as its
      region, while loose places remain (N minus the sects' F17 targets minus the authored living people outside
      sects; Formula E). Once they are used up, a failing candidate
      is redrawn (the same person and realm, a new birthplace and root, the retry index in the key), up to
      `admit_tries` (8, a guess) for the opening; after that the opening stays empty and the last draw is kept as a
      loose person anyway, so every person of the fill exists and the world still holds exactly N.
   8. **The rest.** People of the fill left after the sects are loose. Each takes a region first (settled by Formula
      M, or wild ground, as above), then its **birthplace from that region** (a settled place of the region, Formula M
      weights), then its root; the wild pick by land match reads that root.

   A sect may so end **under its F17 target** at the start; that is not an error, and F17's intake closes the gap in
   play. The loose world then skews toward odd roots, "which is true of the genre" (R2). Where the members come from
   is measured, not authored: the fill's pass rates, the sects' shortfall and the loose count are a census check
   (AC-WG-49, ADVISORY), not targets.

   **Families** (user decision 2026-11-21). After the random cultivators are placed, a keyed `kin_share` (0.15, a
   guess) of them is given a parent: a living ordinary person of the same region, at least `parent_age_gap` (18)
   years older, with fewer than `children_max` (3) children. The child takes the parent's surname and `parent_id`;
   parent and child hold kin (NPC Relationships rule 8), and so do children of the same parent (siblings). A gia_toc
   player gets a living parent and 0-2 siblings in the clan town.
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
16. **A sect sits on land that fits it (new, 2026-11-25; R4, user 2026-11-24: "move seats").** Every one of the 50
    sects' seats passes the **seat fit test** (Formula F) on its final seat and leans, checked by `export_world.py
    --check` on the authored data (an export check, not a build step: the seats are authored, rule 2). Why: the world
    read as unconnected ("an Ice sect on badlands"); 37 of 50 seats failed the test before the pass.
    - **Innate variants are exempt** (ruling 2026-11-25, group 3). An innate variant (Wind) needs no element and its
      land cannot show it, so a Wind lineage's seat is tested on its **base-element leans only**, and the sect
      recruits by the variant wherever its people are born (rule 8a step 3). If the exempt variant is the first lean,
      the next lean moves up into first place and takes the first-lean bar (Formula F).
    - **No-lean sects** (`leans: []`, R3, ruling 2026-11-25) always fit. There are 11, all minor: `trac_anh` Trạc Anh
      Đài, `tam_kiem` Tầm Kiếm Đường, `van_khoi` Vân Khởi Quán, `nhan_tran` Nhạn Trận Môn, `xuyen_lam` Xuyên Lâm Môn,
      `thu_phan` Thu Phần Các, `vong_trieu` Vọng Triều Đường, `van_hac` Vạn Hác Viện, `tuan_tung` Tuần Tùng Đường,
      `chan_kim` Chân Kim Các, `muc_van` Mục Vân Trang. They admit any root (Sects), so their members' roots simply
      follow their birthplaces and the sect looks like its region.
    - **Great sects move their seat** inside their own ground; **minor sects** move or re-lean (their pages say which).
      The great sect seats (ruling 2026-11-25):

      | Sect | New seat (place) | Moved | The old seat becomes |
      |---|---|---|---|
      | Băng Tâm Các | Hồ Thiên Phái (214); the head's sanctum on Băng Bích Nhai (1393) | 470 | Cựu Các, the Desert Pavilion (3) |
      | Thúy Vi Tông | Cổ Dịch Trấn (1110) | 1001-1006 | Thúy Vi Nhai Đường, the Cliff Hall (1), a faction |
      | Thính Vũ Lâu | Thần Cổ Phong (874), **re-leans Metal/Water/Thunder → Metal/Thunder** | 1166-1170 | Thính Vũ Cựu Lâu, the Rain Tower (7) |
      | Lạc Hà Tông | Vân Kiều Trấn (558) | 1185 | Cựu Hà Viện, the Old Glow Court (4), the outer gate |
      | Phượng Minh Cung | Hỏa Ti Trấn (449), inside Phần Vũ's province, which becomes Phượng Minh's seat province (Provinces rule 2a) | 1162 | Ngô Đồng Đình, the Wutong Court (6) |
      | Thiên Xu Tông, Tùng Đào Cung | stay | | |

      Minor moves: Bình Thủy (18 → 302), Hàm Nguyệt (→ 260, re-leans Water), Hồng Đậu (27 → 263, re-leans Wood,
      Water), Lê Hoa Am (15 → 184, re-leans Ice, Metal), Lễ Tuyền (26 → 193), Minh Loan (527 → 519), Ngạo Tuyết (284 →
      1262, re-orders Metal, Wood), Yến Quang (537 → 423). The minor re-leans in place, and every move's story, old-seat
      afterlife and costs (seat painting, map symbol, routes, province seat record, place records and lines that name
      the old seat) are in each sect's page §2 (`design/world/depth/sects/<key>.md`; the pass index
      `design/world/depth/README.md`; the starting audit `design/world/depth/seat-audit.md`, generated by
      `tools/design/world/depth_seat_audit.py`). Each move is a dated `seat_moved` event (rule 3a).
    - **Result** (on the final seats and leans, 2026-11-25): **49 of 50 pass the test as first written; Cửu Cao Phái
      passes only by the Wind exemption** (Wood 31 % clears the first-lean bar). The figure is the depth pass's own
      count: the final-seat check is not yet wired into a tool (Open Question 12).

    **16a. Founder's arrays (new, 2026-11-25; ruling group 2).** A moved seat is often thinner in qi than the old one.
    A seat record carries `seat_array_density` (default 0), a density bonus **sized to bring the new seat near the old
    seat's density** (Formula G) and **written into its history** as the founder's or a later head's vein-raising work
    (an `array_laid` event, or the move event that names the array). It is **added to the seat's place density as
    Travel & Map defines it** (land density, kind bonus and whatever else that GDD stacks); this GDD does not define
    the sum (back-link owed). Formula G sizes the value on land density and kind bonus only. **Breaking the array is a hook**: the
    bonus goes to 0 and the seat thins to its bare density (each page names what else follows, such as Băng Tâm's
    volcano waking). Who can break it and how is the Event Engine's and the Living World Tick's; this GDD only authors
    the starting value. The proposed values are in Formula G's table. **Every moved sect has one** (ruling group 2,
    "each moved sect"; the seven minor pages that said "no founder's array" were updated 2026-11-25): Ngạo Tuyết's
    and Yến Quang's arrays are named records at 0, since their new seats are denser. The 0 is intended (2026-11-25,
    ruling group 11): the array keeps a moved seat near its old density, and a denser seat needs none.

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
| **Spiritual Roots** (#6) (new, 2026-11-25) | out / in | Out: each random person's birthplace (rule 8a). In: the root rolled from it (Linh Căn rule 2, Formulas A2, D4) | Linh Căn owns the roll; this GDD owns where the birthplace is drawn |
| **Provinces** (#48) (new, 2026-11-25) | in | The birthplace's province and its land qi (Linh Căn reads it); the seat provinces of the moved seats (Provinces rule 2a) | Provinces |
| **Sects & Missions** (#26), admission (new, 2026-11-25) | in | The admission test by rank (R2) and the no-lean sects (R3), applied by the fill (rule 8a); each sect's leans and lineage elements | Sects owns admission; this GDD owns the fill order |
| **Travel & Map** (#25), seats (new, 2026-11-25) | out | The final seat places, `seat_array_density` (rule 16a), which place density reads; Formula M's `settle_weight`, read for birthplaces | Travel & Map owns place density; this GDD owns the starting array values |

## Formulas

### A. Realm headcount targets

The realm_target formula is defined as:

`N = max(world_cultivators, world_cultivators_min)`
`raw_r = N × c_r / Σ c`
`T_r = ⌊raw_r⌋ + 1 if r is among the (N − Σ⌊raw⌋) realms with the largest raw_r − ⌊raw_r⌋ (ties to the lower realm), else ⌊raw_r⌋`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| world_cultivators | int | 5,000–8,000 (safe; 2026-11-25: floor 5,000, was 3,000–8,000) | data file (Realms, `people.world_cultivators`, 5,000) | Requested world size; a smaller value is raised to the floor |
| world_cultivators_min | int | 5,000 (2026-11-25: floor 5,000, was 3,000; ruling group 11, "the authored cast needs 4,947") | data file (Realms) | Floor for the world size |
| N | int | ≥ 5,000 | calculated | The world size actually built |
| c_r | float | > 0 | data file (`realm_start_share`) | Weight of realm r. Starts as Realms' solved headcounts at 5,000: 3,936 / 844 / 191 / 27 / 3 |
| T_r | int | 0–N | calculated | Target headcount of realm r |

**Output Range:** Σ T_r = N exactly. At 5,000 the targets are 3,935 / 844 / 191 / 27 / 3. At 3,000 (below the floor since
2026-11-25, so a fixture case with an injected floor only) they are 2,361 / 506 / 115 / 16 / 2. A zero or negative c_r is refused by Checking.
**Example:** N = 5,000. raw = 3,935.21 / 843.83 / 190.96 / 26.995 / 2.9994, so the floors sum to 4,996. The 4 largest
fractions (.9994, .995, .96, .83) each get +1: Hóa Thần 3, Nguyên Anh 27, Kết Đan 191, Trúc Cơ 844. Luyện Khí is 3,935.
**Note:** the data file today holds different weights (79.4 / 16.7 / 3.8 / 0.53 / 0.06). They give 3,951 Luyện Khí and
26 Nguyên Anh. Realms owns the targets, so the data must be replaced by the solved counts above.

### B. Random fill

The random_fill formula is defined as:

`F_r = T_r(N) − K_r`, where Checking requires **`N ≥ N_cast`** (amended 2026-11-25; the bound was `K_r ≤ T_r(N_min)`,
the targets at N = 3,000), and `N_cast` = the smallest N such that `K_r ≤ T_r(N')` for every realm r and every N'
from N to 8,000

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| K_r | int | 0–T_r(N) | calculated | Living fixed-cast members in realm r. Today 913 / 632 / 173 / 27 / 2 (rule 5) |
| T_r(N) | int | see A | calculated | Realm r's target at the world size N actually built |
| N_cast | int | calculated | calculated | The smallest world from which every larger world up to 8,000 holds the cast: **4,947** for today's cast (Nguyên Anh binds: T_NA reaches 27 there). None if no N up to 8,000 holds the cast, and Checking is Failed |
| F_r | int | ≥ 0 | calculated | Random cultivators generated in realm r |

**Output Range:** F_r ≥ 0, and Σ (K_r + F_r) = N exactly. **Why amended:** the old bound tested the cast against the
smallest world, and the ~1,900-person cast (rule 5) no longer fits it: at N = 3,000 the targets are 2,361 / 506 / 115
/ 16 / 2 against K = 913 / 632 / 173 / 27 / 2, so Trúc Cơ, Kết Đan and Nguyên Anh would all fail. Checking now names
`N_cast` in its report, and a world below it is Failed (Edge Cases). **Why a floor and not a per-N test:** Formula
A's largest-remainder rounding lets some smaller sizes hold the cast by luck (4,878 does, 4,923 and 4,946 do not), so
a floor gives one clear rule. **Answered 2026-11-25** (ruling group 11, Open Question 8): `world_cultivators_min`
rises to **5,000**, above `N_cast` 4,947, so every shipped world holds today's cast. The `N ≥ N_cast` test stays: it
fails a world only if the cast grows past what 5,000 holds, or if a data file lowers the floor.
**Example:** N = 5,000, T = 3,935 / 844 / 191 / 27 / 3 and K = 913 / 632 / 173 / 27 / 2. Then F = **3,022 / 212 / 18 /
0 / 1**, which is 3,253 random cultivators, so the world has 1,747 + 3,253 = 5,000. Nguyên Anh gets none: the cast
fills it. With the floor injected below 5,000 (a test fixture since 2026-11-25), at N = 4,946, T_NA = 26 < 27: N < N_cast, so Checking is Failed naming Nguyên Anh, K 27, T 26 and N_cast
4,947. At N = 4,878 the targets happen to hold the cast, but N < N_cast, so it is Failed too.

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
| a | int | uniform(age_min_by_realm[r], lifespan[r]); age_min 16 / 30 / 80 / 200 / 500 | calculated (NPC Builds), `age_max_lifespan_frac` 1.0 | The person's age at the start: evenly to the full lifespan, the spread a mature world settles into (age_shape_probe.gd, 400 years; user decision 2026-11-21; was 0.85 of lifespan, which left almost no deaths of age in the first decades and overshot the census) |
| fate0 | bool | per person | calculated | A person who starts at the last stage of their realm starts with that realm's breakthrough fate already rolled: fated with chance `q_start[r]`, else not (Realms Formulas C2's fate, rolled once per realm). Without it, everyone at a gate rolls fresh in the first season and the fated share all break through at once (a first-century wave; user decision 2026-11-21) |
| q_start | float | 0.005 / 0.002 / 0 / 0 | data file (`character_edges.json` `npc.fate_start_share`) | A mature gate crowd's fated share, Luyện Khí to Nguyên Anh (entry_age_probe.gd, 200 years) |
| f_s | int | ≤ Y0 | data file (authored sect) | The sect's founding year |
| k | int | 0 to F_r − 1 | calculated | The person's index within its realm's random fill |
| join_year | int | lo to Y0 | calculated | The year the person joined |

**Output Range:** lo ≤ Y0 always, because a ≥ 16 and f_s ≤ Y0, so the window is never empty. A person aged exactly 16
joins in Y0.
**Example:** a = 40 and f_s = Y0 − 150: lo = Y0 − 24, so the join year is one of 25 values from Y0 − 24 to Y0. At
a = 200 the window starts at the founding, Y0 − 150.

### E. Birthplace draw and loose places (new, 2026-11-25)

The birthplace formula is defined as:

`own = (u_g < local_recruit)` (always false for a Wind lineage), `P(p) = settle_weight(p) / Σ_{q ∈ G} settle_weight(q)`
for each settled place p of `G` = the sect's own ground if `own`, else the whole continent (a loose person: its
region), `u_g` and the place pick on the stream keyed `game_seed + ":birth:" + k + ":" + try`

`L = N − Σ_s target_s − K_out` (loose places for rule 8a step 7)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| local_recruit | float | 0–1 (safe 0.5–0.9) | data file (`world_generation.json`, new) | Share of a sect's random members born on its own ground (R1 proposal 0.75, ruling 2026-11-25) |
| u_g | float | [0, 1) | calculated (keyed stream) | The ground draw |
| settle_weight(p) | float | ≥ 0 | Travel & Map Formula M | How likely a settled place is to house a person; reused as the birth weight |
| G | set | ≥ 1 place | calculated | The places the birthplace is drawn from |
| k, try | int | ≥ 0 | calculated | The candidate's index in the fill and its retry index (rule 8a step 7) |
| target_s | int | ≥ 0 | Sects F17 (0.9 × capacity) | Sect s's member target |
| K_out | int | ≥ 0 | calculated | Authored living people outside sects: **188** today |
| L | int | can be < 0 | calculated | Loose places for failed candidates; L ≤ 0 means none |

**Output Range:** a settled place of G (never wild ground: people are born where people live). If G has no settled
place or every weight is 0, the draw falls back to the whole continent (Edge Cases). L is about 700 at N = 5,000.
**Example:** N = 5,000, Σ target ≈ 4,100 (rule 8's estimate), K_out = 188: L ≈ 712. A Băng Tâm opening draws u_g =
0.62 < 0.75, so the birthplace comes from its own ground; if that ground's settled places weigh 4 / 3 / 1, they are
picked with chance 0.50 / 0.375 / 0.125. The authored living in sects (1,559) count toward the targets, so the sects
have about 2,541 openings for the 3,253 random people of Formula B's example, and if every opening fills, 712 are
loose, exactly L.

### F. Seat fit test (new, 2026-11-25)

The seat_fit formula is defined as:

With `ℓ` = the sect's leans in order with innate variants removed, `fit = (ℓ = []) OR` every `ℓ_i` passes, where:
- `ℓ_0` a base element b: `s_b ≥ lean_first OR b = top1`;
- `ℓ_i` (i ≥ 1) a base element b: `s_b ≥ lean_other OR b ∈ {top1, top2}`;
- any `ℓ_i` a derived variant v: `q_v ≥ lean_variant` (a variant in first place takes only this bar).

This is `fit()` in `tools/design/world/depth_seat_audit.py`, plus the removal of innate variants (ruling 2026-11-25).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| leans | list | 0-3 elements | authored sect | The sect's leans in order; a sect authored with `leans: []` is no-lean (R3) |
| ℓ | list | 0-3 elements | calculated | The leans with innate variants (Wind) removed (rule 16). A Wind-only sect's ℓ is empty and it fits |
| s_b | float | 0–100 % | Travel & Map (`place.qi.shares`) | Base element b's share of the seat place's qi |
| top1, top2 | element | base elements | calculated | The seat place's two strongest base elements (base shares only; variants never rank) |
| q_v | int | 0–100 | Travel & Map (`place.qi.variants`) | The seat place's variant qi for v |
| lean_first | float | 25 % | data / check constant | Bar for the first lean |
| lean_other | float | 15 % | data / check constant | Bar for the other base leans |
| lean_variant | int | 5 | data / check constant | Bar for a derived variant lean |

**Output Range:** true or false per sect; a no-lean sect is always true. **Example:** Thính Vũ at Thần Cổ Phong (874),
leans Metal/Thunder: Metal 45 % ≥ 25 and Thunder 40 ≥ 5, so it fits; with its old Water lean it fails (no place in its
ground holds all three). Cửu Cao (Wind/Wood) at its seat (14): Wind is removed, Wood becomes ℓ_0 at 31 % ≥ 25, so
it fits; without the exemption, Wind's 0 variant qi fails it. Lê Hoa Am (Ice/Metal) at 184: Ice 10 ≥ 5, and Metal,
now ℓ_1, at 44 % ≥ 15, so it fits.

### G. Founder's array size (new, 2026-11-25)

The seat_array formula is defined as:

`d_seat = d_land + kind_bonus(seat kind)`, `seat_array_density ≈ max(0, d_old − d_seat)`, rounded to 0.05 and authored
per seat (the formula sizes the value; the data holds it)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| d_land | float | ≥ 0 | Travel & Map (map export) | The new seat place's land density |
| kind_bonus | float | great seat +0.10 (a ruin is +0.25) | data file (Travel & Map) | The fixed density bonus by place kind; a moved seat takes the seat kind's, not its old kind's |
| d_old | float | ≥ 0 | Travel & Map | The old seat's density as a seat |
| seat_array_density | float | 0 – 0.75 (authored) | authored seat record | The founder's array; 0 when the new seat is as dense as the old |

**Output Range:** 0 when the new seat is denser (Ngạo Tuyết, Yến Quang). **That 0 is intended** (ruling group 11,
2026-11-25): the array exists to keep a moved seat near its old density, and a seat that moved to denser land needs
none, so neither gets a bonus on top. The proposed values (`design/world/depth/sects/<key>.md` §2):

| Sect | New seat | d_seat | Array (name) | Seat with array | Old seat |
|---|---|---|---|---|---|
| Thúy Vi | 1110 | 1.75 + 0.10 = 1.85 | +0.10 (Spring Return array, 1006) | 1.95 | 1.94 |
| Thính Vũ | 874 | 1.90 + 0.10 = 2.00 | +0.35 (Iron Rain array, Thiết Vũ Trận) | 2.35 | 2.36 |
| Phượng Minh | 449 | 1.35 + 0.10 = 1.45 | +0.65 (Nest Array, 592) | 2.10 | 2.11 |
| Băng Tâm | 214 | 1.02 − 0.25 (ruin) = 0.77 + 0.10 = 0.87 | +0.75 (Jade Vessel Array, 470; re-sized 2026-11-25) | 1.62 | 1.63 |
| Lạc Hà | 558 | 1.36 − 0.25 (ruin) = 1.11 + 0.10 = 1.21 | +0.5 (Cloud Bridge Array, 1180-1184; re-sized 2026-11-25) | 1.71 | 1.72 |
| Minh Loan (minor) | 519 | 0.56 | +0.2 (Hundred-Bell Eaves, a little under half hung) | 0.76 | 0.80 |
| Bình Thủy (minor) | 302 | 1.01 | +0.30 (Slack-Water Weirs) | 1.31 | 1.31 |
| Hàm Nguyệt (minor) | 260 | 1.37 | +0.05 (Sunken Disc) | 1.42 | 1.41 |
| Hồng Đậu (minor) | 263 | 1.10 | +0.40 (Red Trellis) | 1.50 | 1.50 |
| Lê Hoa Am (minor) | 184 | 1.23 | +0.40 (Pear-Frost Ring) | 1.63 | 1.63 |
| Lễ Tuyền (minor) | 193 | 1.22 | +0.10 (Dawn Cloud Mirror) | 1.32 | 1.33 |
| Ngạo Tuyết (minor) | 1262 | 1.36 | 0 (Tiger-Stripe Ring, a named record) | 1.36 | 1.10 |
| Yến Quang (minor) | 423 | 1.04 | 0 (Ever-Lit Furnace, a named record) | 1.04 | 0.81 |

*(Minor rows added 2026-11-25 from the pages' own densities, as the Minh Loan row is; each page's §2 names the array
and its history.)*

**Example:** Phượng Minh: d_seat = 1.35 + 0.10 = 1.45; d_old − d_seat = 2.11 − 1.45 = 0.66, rounded to 0.65; the seat
reads 2.10. **Re-sized 2026-11-25** (ruling group 12, Open Question 11): the Băng Tâm and Lạc Hà pages had sized
their arrays (+0.6, +0.3) from the seat audit's density, which for a ruin includes the ruin's +0.25. A moved seat takes
the seat kind's +0.10 instead, so Băng Tâm: d_seat = 0.77 + 0.10 = 0.87, 1.63 − 0.87 = 0.76 → **+0.75**, reads 1.62;
Lạc Hà: d_seat = 1.11 + 0.10 = 1.21, 1.72 − 1.21 = 0.51 → **+0.5**, reads 1.71. Lạc Hà's page also designs an outer
ring (+0.1, half paid, Quách's hook): it is **not** in the +0.5, and if a later event completes it the seat reads 1.81,
0.09 above its old seat. That is the hook's reward, not part of the sizing.

**Feedback loops:** none. Generation runs once and nothing it writes feeds back into itself. The world-generation
fight budget (`worldgen_fight_budget`) belongs to Power Rankings.

## Edge Cases

**Checking (any failure ends in Failed, names its cause, and saves nothing)**

- **If an authored file is missing, unreadable or fails its schema:** Failed, naming the file and the first bad field.
- **If a file's authored-data version differs from the version the generator expects:** Failed, naming both versions.
- **If a hidden slot or tile secret has fewer than 2 candidates, or two candidate sets share a tile:** Failed, naming
  the slots.
- **If any realm weight `c_r` is zero or negative:** Failed, naming the realm.
- **If the living cast has more people in a realm than that realm's target (`K_r > T_r(N)`; amended 2026-11-25, was
  `T_r(N_min)` at N = 3,000), that is, if `N < N_cast` (Formula B):** Failed, naming `N_cast`, and every realm where
  K > T with K and T. With today's cast `N_cast` is 4,947. Since 2026-11-25 the floor is 5,000 (ruling group 11,
  Open Question 8), so a `world_cultivators` below 5,000 is raised to 5,000 and passes; Failed now happens only if
  the cast grows past what the built N holds, or a data file lowers `world_cultivators_min` below `N_cast`.
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
- **If the cast has fewer than 1,500 or more than 2,100 people** (amended 2026-11-25; was 60–100; the band is a guess
  around the authored 1,889): the Checking report shows a warning, and the build continues. The size is a design
  target, not a rule the data can break.
- **If a living cast member has no birthplace, or a birthplace that is not a place** (new, 2026-11-25): Failed, naming
  the person. A dead record may have none (21 do).
- **If a sect has a living person who fails its admission** (Sects, R2) **with no named exception** (guest elder,
  staff, hired craft, root changed after joining, hostage or political marriage; new, 2026-11-25): Failed, naming the
  person and the sect. A no-lean sect has no such failure.

**Export checks (`export_world.py --check`, on the authored data; new, 2026-11-25)**

- **If a sect's final seat fails Formula F** (an innate variant exempt, a no-lean sect always passing): the export
  is refused, naming the sect, the seat and the failing lean.
- **If the depth export would drop or overwrite a `cast_builds` row** it does not author (rule 6a): refused, naming
  the person.
- **If an `N-` event has no year or no kind:** refused, naming the event (0 today, rule 3a; the
  4 that had none took the kind `hidden`, 2026-11-25). A kind not named in rule 3a's landmark list goes to the annals
  by default, except `hidden`, which goes to neither tier until uncovered.
- **If the player uncovers a `hidden` event twice** (an event outcome and a Codex entry, or two outcomes): the second
  changes nothing; the event stays in the annals once.
- **If a `hidden` event's page also sets `tier:`:** the override names the tier it joins **when uncovered**; it is
  still in neither tier before.
- **If an `N-` event's id is defined twice** (in two pages, or twice in one): refused, naming both places.
- **If a tier C person's tree start is an element or variant they do not own:** refused, naming the person.

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
- **If two chronicle events share a year:** the log orders them by year, then by event id, ascending. In string order
  an `N-` id sorts after the `A` and `C` ids of the same year and before the `V` ids.
- **If a random candidate's root passes no sect with an opening** (rule 8a, new 2026-11-25): it stays loose in its
  birthplace's region while loose places remain (Formula E's L); after that it is redrawn, up to `admit_tries`, and
  then the opening stays empty and the last draw is loose. Not an error.
- **If a sect ends under its F17 target at the start:** not an error. The Checking report counts the shortfall per
  sect, and F17's intake closes it in play.
- **If the fill runs out of random people before every opening is filled** (the authored cast and the failed
  candidates used the pool): the remaining openings stay empty, and the report says how many.
- **If a sect's own ground has no settled place, or every settle weight there is 0:** the birthplace draw uses the
  whole continent (Formula E). For a minor sect whose lord holds no land in the seat's region, the own ground is the
  seat's province.
- **If the birthplace is on water or in no province:** Linh Căn's rule for it applies (nearest land province, else
  even land).
- **If an authored person's tier is missing:** the person is tier C (the shortest record), and the export check
  reports it.
- **If a founder's array is broken in play** (rule 16a): the seat's `seat_array_density` goes to 0 and its density
  loses that bonus. World Generation never rebuilds it; restoring it is a story for the Event Engine.
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
| Spiritual Roots (#6) (new, 2026-11-25) | Hard | The birth roll from a birthplace (Linh Căn rule 2, Formulas A2, D4), run by the fill (rule 8a) | yes (Linh Căn Interactions and Dependencies, 2026-11-25) |
| Provinces (#48) (new, 2026-11-25) | Hard | Each birthplace's province and land qi; the moved seats' seat provinces (rule 2a) | yes (Provinces rule 2a names "World Generation, seats on fitting land") |
| Sects & Missions (#26), admission (new, 2026-11-25) | Hard | The admission test by rank (R2), the no-lean rule (R3), leans and lineage elements, read by the fill (rule 8a) and Checking | owed (Sects' R2 amendment) |
| Travel & Map (#25), Formula M (new, 2026-11-25) | Hard | `settle_weight`, reused as the birth weight (Formula E); place qi shares and variants for the seat fit test (Formula F); land density and kind bonus (Formula G) | owed |
| NPC Builds (#24), BuildGenerator (new, 2026-11-25) | Hard | Tier C trees from an authored start, keyed on the person (rule 6) | no GDD |

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
| Event Engine (#23) | Soft | The fixed cast, history's hidden places and the chronicle as story anchors; authored stories started at world generation (Event Engine rule 12); *(2026-11-25)* an outcome that uncovers a `hidden` event by id (rule 3a) | yes (row added 2026-11-15) |
| Living World Tick (#28) | Hard | A Loaded world and the chronicle | no GDD |
| LLM Game Master (#29, parked) | Soft, optional | The same facts and texts, to retell later (Core Rule 14); never required | no GDD |
| Game UI (#37) | Soft | Build progress, failure reasons and the origin list | no GDD |
| NPC Relationships (#46) | Soft | The cast's authored ties | yes (2026-11-20) |
| Codex & Karmic Carryover (#12) | Soft | Stable authored ids, hidden places' candidate sites and origins, read by the Codex (never this game's rolled site); *(2026-11-25)* a carried Codex entry that uncovers a `hidden` event (rule 3a) | yes (2026-11-21) |
| Travel & Map (#25), place density (new, 2026-11-25) | Hard | The final seats and each seat's `seat_array_density` (rule 16a), added to place density | owed (back-link) |
| Sects & Missions (#26), membership (new, 2026-11-25) | Hard | Random members who passed its admission, each with a birthplace; a sect possibly under its F17 target at the start (rule 8a) | owed (back-link) |
| Event Engine (#23), Living World Tick (#28) (new, 2026-11-25) | Soft | The founder's arrays as hooks (breaking one sets it to 0, rule 16a); the ~260 `N-` events as story anchors | owed (Event Engine); no GDD (Tick) |
| Spiritual Roots (#6) (new, 2026-11-25) | Soft | The birthplace of each person created (rule 8a) | yes |

**Rows added in other GDDs (2026-11-15):** Power Rankings, Regional Economy & Trade and Trade Goods each now list #27
in their Dependencies.

**Back-links written 2026-11-25** (world-depth rulings, `design/world/depth/DECISIONS-2026-11-25.md`):
- **Item Database** (#13, rules 20f, 20g, 22; Formulas J1–J3): sets are sized to the cast build's gear list (`1 +
  realm index` pieces, at most `artifacts_max` 3); signature items start with their authored holders; the export
  check refuses a cast gear list of the wrong length. Item DB becomes a two-way dependency (it already read rule 20d).
- **Sects & Missions** (#26, rules 3a, 19b, 20b–20d; F20–F22): the fill draws members under Sects' admission test
  and `recruit_by` (rule 8a); seats and `seat_array_density` match Sects F22; the cast's titles are Sects rule 19b's.
- **NPC Traits** (#42, F4b, rule 2a): the fill rolls the v2 kinds, reading this GDD's upbringing leans `m_birth`,
  `m_family` and the birthplace kind; the authored cast's v2 trait sets (1,889 people) are this GDD's content (NPC
  Traits Open Questions 14, 21).

## Tuning Knobs

Added 2026-11-25 with the world-depth amendment; it lists the knobs this GDD owns. Realm targets and world size are
Realms' (Formula A), F17 targets are Sects', settle weights are Travel & Map's.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `local_recruit` (new) | 0.75 | 0.5–0.9 | Share of a sect's random members born on its own ground (Formula E). Higher: sects look more like their land and pass admission more often; lower: sects look like the continent. Above 0.9 a small ground repeats the same few villages |
| `admit_tries` (new, guess) | 8 | 3–20 | Redraws for an opening once loose places are used up (rule 8a step 7). Higher: fewer empty openings, slower fill; lower: sects start further under target |
| `seat_array_density` (new, per seat, authored) | Formula G table | 0 – (d_old − d_seat) | A moved seat's density. Above the gap the move would make the seat denser than the old one, which the ruling did not ask for |
| `lean_first` / `lean_other` / `lean_variant` (new, export-check constants) | 25 % / 15 % / 5 | ±5 points | How strictly seats must fit their leans (Formula F). Raising them fails seats that pass today; the seat moves were authored against these values |
| cast-size warning band (amended) | 1,500–2,100 people | — | Only the Checking warning (Edge Cases) |
| `master_share`, `kin_share`, `parent_age_gap`, `children_max` (existing) | 0.3, 0.15, 18, 3 | as rule 8 | Masters and families of the random fill |

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
| The provinces-v2 history and sects (user decisions 2026-11-24): 172 annals (the end of each of the 142 new ruins, the founding of the 20 new sects, 10 other dated facts), the 20 new sect heads in the cast, the 20 sects' start states | `design/world/provinces-v2/annals_v2.json`, `cast_v2.json`, `sect_start_v2.json`, read by `export_world.py` beside the approved proposals | Core Rules 3, 5, 7 |
| Traits for the 51 living cast members: 3 personality, 1 calling, 5 fate-given | `design/world/leader_traits_proposal.json` (approved 2026-11-15) | Core Rule 5; NPC Traits #42 |
| The world-depth rulings (2026-11-25) and the rules as proposed (R1-R8) | `design/world/depth/DECISIONS-2026-11-25.md`, `rules-proposals.md`, `SUMMARY-2026-11-25.md` | Core Rules 3a, 5, 5a, 6, 6a, 8a, 16, 16a |
| The authored cast: 1,889 people (1,747 living; tiers A 171, B 369, C 1,349) in 125 files, and the realm quotas | `design/world/depth/sects/*.cast.json`, `design/world/depth/people/*.cast.json`, `quotas.json`, `schema.md` (check: `python -I tools/design/world/depth_check.py`) | Core Rules 5, 5a, 6; Formula B; AC-WG-40, -41 |
| The new events (`N-<key>-NN`, 264 with year and kind), the old-seat afterlives, the seat moves and re-leans, the founder's arrays | `design/world/depth/sects/<key>.md` §2-3, `people/<group>.md`; `README.md`; `seat-audit.md` | Core Rules 3a, 16, 16a; Formulas F, G |
| The approved rewordings (C007, A190, `soc_khi`, the Thiết Mã tally, `co_hac`, A188, A087) and the cross-sect threads | `design/world/depth/cross-sect.md` §6, the sect pages | Core Rule 3a |
| Tier A and B builds, lineage tree routes, the route checker | the cast files' `build`, `tools/design/world/depth_tree.py` | Core Rules 6, 6a |
| Roots from the birthplace | `linh-can.md` rule 2, Formulas A2, D4 (amended 2026-11-25) | Core Rule 8a; Formula E |
| Seat provinces of moved seats | `provinces.md` rule 2a (amended 2026-11-25) | Core Rule 16 |

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
- **AC-WG-04** [Config/Data] Rule 3. GIVEN the chronicle files, THEN the landmark file holds 150–280 events and the
  annals file 300–800 (amended 2026-11-25 for rule 3a; were 150–250 and 300–500), each with an id, a year before the start, a kind, ids that exist, a place or region and one
  line of text.
- **AC-WG-05** [Integration] Rule 3. GIVEN a built world, THEN the event log holds exactly the events of both tiers
  (same ids, years and text) and no other event dated before the start.
- **AC-WG-06** [Logic] Rule 4. GIVEN the chronicle, THEN no event contains the tile of a hidden slot. GIVEN a built
  world, WHEN any text about an undiscovered hidden place is built (a template rumour or clue, or an LLM fact packet
  when it is on), THEN it names the region and no tile.
- **AC-WG-07** [Config/Data] Rule 5 (amended 2026-11-25). GIVEN the cast files, THEN they hold 1,500–2,100 records
  (a warning outside that range; was 60–100), every living record has every field, and they include every sect's
  head (50 sects).
- **AC-WG-08** [Integration] Rule 6. GIVEN each living cast member, WHEN the authored build is run through the NPC
  Builds validator, THEN it passes. WHEN a fight sheet is built from it under two different game seeds, THEN the two
  sheets are identical.
- **AC-WG-09** [Logic] Rule 6. GIVEN a cast build that names a Đạo Đồ node that does not exist, WHEN Checking
  runs, THEN the state is Failed, the message names the person and the node, and nothing is saved.
- **AC-WG-10** [Config/Data] Rule 7. GIVEN the sect start-state table, THEN it has 30 rows, every development level
  is at or below Sects' F1 settle level (12, 9 or 4 by tier), every minor sect's loyalty is above 30, and the table
  holds no dial or attitude.
- **AC-WG-11** [Logic] Rule 8 (amended 2026-11-25). GIVEN N = 5,000 and the authored cast (1,747 living), THEN every
  realm's count equals its target and the world has exactly 5,000 living cultivators.
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
  27 / 3 and N = 3,000 (a fixture with the floor injected at 3,000) gives 2,361 / 506 / 115 / 16 / 2. With the
  shipped floor, a `world_cultivators` of 0 or 3,000 builds N = 5,000 (amended 2026-11-25: floor 5,000, was 3,000).
  The targets sum to N at N = 3,000, 5,000 and 8,000.
- **AC-WG-22** [Logic] Formula A. GIVEN any weight at 0, THEN Checking is Failed and names the realm.
- **AC-WG-23** [Logic] Formula B (amended 2026-11-25: the bound is the built N). GIVEN K = 10 / 20 / 25 / 9 / 1 at
  N = 5,000, THEN F = 3,925 / 824 / 166 / 18 / 2. GIVEN 4 Hóa Thần in the cast at N = 5,000, THEN Checking is Failed
  (the target is 3); GIVEN 3 Hóa Thần at N = 3,000 (floor injected at 3,000; below the shipped floor since
  2026-11-25), THEN Failed (the target is 2). GIVEN K_r = T_r, THEN F_r = 0 and
  there is no error. The authored cast's case is AC-WG-41.
- **AC-WG-24** [Logic] Formula C. GIVEN n = 0 or 1, THEN Checking is Failed. GIVEN an injected hash of 1,234,567,891
  and n = 3, THEN the pick is candidate index 1.
- **AC-WG-25** [Logic] Formula D. GIVEN a = 16, THEN the join year is Y0. GIVEN a = 40 and f_s = Y0 − 150, THEN every
  join year over 1,000 samples lies in Y0 − 24 to Y0.

**Edge Cases**

- **AC-WG-26** [Logic] Edge Cases (Checking). GIVEN, for each of the 14 failing Checking cases (12, plus the
  birthplace and admission cases of 2026-11-25), a minimal data file that breaks only that rule, THEN generation ends
  Failed with a message that names the stated cause, and no save is written. Each case was seen to fail before it was
  counted as covered. For the cast-size case, GIVEN a cast of 1,499 or 2,101 (amended 2026-11-25; was 59 or 101),
  THEN the Checking report shows a warning and the build continues. GIVEN, for each of the 5 export checks, a
  minimal file that breaks it, THEN `export_world.py --check` refuses it naming the cause.
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

**World depth (new, 2026-11-25).** Gate marks: BLOCKING unless ADVISORY is named. None can run until the depth export
exists (header).

- **AC-WG-40** [Config/Data · BLOCKING] Rule 5. GIVEN the depth cast files, WHEN `depth_check.py` runs, THEN it
  counts 1,500–2,100 people (1,889 at amendment), every record has a tier A, B or C, every living record a birthplace
  that is a place, and every living realm count is within `quotas.json`'s world caps (27 / 180 / 670 / 1,000 below Hóa
  Thần, no new Hóa Thần).
- **AC-WG-41** [Logic · BLOCKING] Formula B. GIVEN weights 3,936 / 844 / 191 / 27 / 3 and K = 913 / 632 / 173 / 27 / 2,
  THEN N = 5,000 gives F = 3,022 / 212 / 18 / 0 / 1 (3,253 in all) and N_cast = 4,947; every N from 4,947 to 8,000
  passes; with the shipped floor 5,000 (2026-11-25), `world_cultivators` 3,000 builds N = 5,000 and passes. With the
  floor injected below 5,000 (fixture cases): GIVEN N = 4,878, THEN Checking is Failed naming N_cast (though its targets hold the cast); GIVEN N = 4,946, THEN Checking
  is Failed naming Nguyên Anh, K 27, T 26; GIVEN N = 3,000, THEN it is Failed naming Trúc Cơ, Kết Đan and Nguyên Anh.
- **AC-WG-42** [Logic · BLOCKING] Rule 8a, birthplace before admission. GIVEN a fill run with a spy on the birth roll,
  THEN for every random person the birthplace is set before the root is rolled and the root before any admission test;
  and the root equals Linh Căn's roll for that birthplace's province and stream.
- **AC-WG-43** [Logic · BLOCKING] Formula E. GIVEN an injected u_g of 0.74 and `local_recruit` 0.75, THEN the
  birthplace is in the sect's own ground; GIVEN 0.75, THEN it is drawn from the continent; GIVEN a Wind-lineage sect
  and u_g 0.10, THEN from the continent. GIVEN 10,000 draws on a ground of weights 4 / 3 / 1, THEN the shares are
  0.50 / 0.375 / 0.125 within ±0.02.
- **AC-WG-44** [Logic · BLOCKING] Rule 8a, admission. GIVEN a built world, THEN every random sect member's root passes
  that sect's admission at the rank its realm gives (Sects R2), and no random member of a no-lean sect was refused for
  its root.
- **AC-WG-45** [Logic · BLOCKING] Rule 8a steps 6-7. GIVEN a candidate born on sect X's ground whose root fails sect A
  and passes X and Y (Y not on that ground), THEN it joins X. GIVEN a root that passes no sect and L > 0, THEN it is
  loose with its birthplace's region; GIVEN L = 0, THEN it is redrawn, and after `admit_tries` redraws the opening is
  empty, the report counts it, and the last draw exists as a loose person (the world still holds exactly N).
- **AC-WG-46** [Logic · BLOCKING] Rule 8a, determinism. GIVEN the same seed, THEN two fills give identical birthplaces,
  roots and sect choices; GIVEN the sects listed in reverse in memory, THEN the result is unchanged (stable key order).
- **AC-WG-47** [Logic · BLOCKING] Rule 8a step 8. GIVEN a loose person placed in region R, THEN its birthplace is a
  settled place in R.
- **AC-WG-48** [Integration · BLOCKING] Rule 5. GIVEN a built world, THEN its living cast equals the depth files'
  living records (keys, realms, sects, birthplaces) and none of them is in the random pool.
- **AC-WG-49** [Integration · ADVISORY] Rule 8a, census. GIVEN 10 seeds at N = 5,000, THEN the report shows, per sect,
  the random members, the shortfall under its F17 target and the share born on its own ground (expected near 0.75 for
  sects that fill, none for Wind lineages), plus the loose count. The values are recorded, not judged; a world-wide
  shortfall above 10 % of openings is raised to the user.
- **AC-WG-50** [Config/Data · BLOCKING] Rule 16, Formula F. GIVEN the final seats and leans, WHEN the export check
  runs, THEN all 50 sects pass (Cửu Cao by the Wind exemption), the 11 no-lean sects have `leans: []`, and Thính Vũ's
  leans are Metal/Thunder. GIVEN Thính Vũ with leans Metal/Water/Thunder at 874, THEN the check refuses it naming Water.
- **AC-WG-51** [Logic · BLOCKING] Formula F. GIVEN leans Wind/Wood at a seat with Wood 31 % and Wind 0, THEN fit;
  GIVEN leans Water/Ice at Water 10 %, top element not Water, Ice 0, THEN not fit (Băng Tâm's old seat); GIVEN leans
  [], THEN fit.
- **AC-WG-52** [Integration · BLOCKING] Rule 16a. GIVEN a built world, THEN Phượng Minh's seat (449) reads exactly
  0.65 more density than the same place with `seat_array_density` 0, and Thúy Vi's (1110) 0.10 more; WHEN Phượng
  Minh's array is broken, THEN the difference is 0. Every seat with a non-zero array has the event that lays it in its
  history (an `array_laid` event or the move event that names the array).
- **AC-WG-53** [Config/Data · BLOCKING] Rule 3a. GIVEN the depth pages, WHEN the export runs, THEN every `N-` event
  with a year and kind (264 at amendment) other than `hidden` is in exactly one tier by the rule-3a list or its `tier`
  override, every "hidden" or `secret` event is secret, the 4 events of kind `hidden` are in the log with the secret
  flag and in neither tier (amended 2026-11-25, ruling group 12), and the rewordings (C007, A190, `soc_khi`, the tally split, `co_hac`, A188) are
  in the exported text. `lanh_huong` is in `fallen_sects`.
- **AC-WG-54** [Logic · BLOCKING] Rule 6a. GIVEN `world_history.json` with its 54 `cast_builds` rows, WHEN the depth
  export runs, THEN every one of the 54 keys still has a row, the 48 original routes are byte-identical to the
  restored ones, and an export that would delete a row is refused naming the person.
- **AC-WG-55** [Logic · BLOCKING] Rule 6, tier C. GIVEN a tier C person, WHEN two worlds are built with different game
  seeds, THEN the person's Đạo Đồ allocation is identical and starts at the authored start.
- **AC-WG-56** [Integration · BLOCKING] Rule 3a, the `hidden` kind (new, 2026-11-25). GIVEN a built world, THEN
  N-lang_dao-03 is in the World Database's log and absent from the codex timeline, the region's annals entry, every
  rumour and NPC line, and the tier counts. WHEN an Event Engine outcome names N-lang_dao-03 (or the player's Codex
  carries it from a past life), THEN it appears in the annals with its secret flag cleared, and a second uncovering
  changes nothing.

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
| 8 | ~~**World size against the cast (new, 2026-11-25).**~~ **Answered 2026-11-25** (ruling group 11): option (a), the floor `world_cultivators_min` rises to **5,000** ("the authored cast needs 4,947"); Formula A, B and Edge Cases amended. **Still open:** `assets/data/world_generation.json` `people.world_cultivators_min` must change from 3,000 to 5,000 (gameplay-programmer; not this GDD's file). The question as asked: The ~1,900 authored people need a world of at least `N_cast` = 4,947 (Nguyên Anh binds: 27 authored of 27 at 5,000; Formula B), but Realms' floor `world_cultivators_min` is 3,000 (memory: "world of 5,000, min 3,000"). Options: (a) raise the floor to 5,000; (b) keep 3,000 and thin the authored Nguyên Anh, Kết Đan and Trúc Cơ until the cast fits 3,000 (16 / 115 / 506); (c) let a small world drop tier C people, which breaks rule 2. Until answered, a world below 4,947 fails Checking | user, Realms (systems-designer) | Before the depth export |
| 9 | ~~**Chronicle tiers by kind (new, 2026-11-25).**~~ **Answered 2026-11-25** (ruling group 11): the kind-to-tier list in rule 3a (13 landmark kinds, the rest annals, a per-event `tier` override) is accepted for the 264 events. **Fully answered 2026-11-25** (ruling group 12): the 4 kindless events take a new kind, `hidden`, kept out of both public tiers until the player uncovers them by an event or the Codex (rule 3a). The question as asked: The ruling says the `N-` events join "the chronicle and annals at export, by kind", without a list. Rule 3a proposes one (about 40 landmarks, 220 annals) and a per-event `tier` override. Confirm the list, and give the 4 kindless events a kind | user, narrative-director | Answered |
| 10 | **Few rare-realm places left for the fill (new, 2026-11-25).** The authored living take Trúc Cơ 632 of 844, Kết Đan 173 of 191 and all 27 Nguyên Anh, so the random fill rolls only 212 / 18 / 0 there (Formula B). Keep it, or thin the authored Trúc Cơ (the morning summary's open decision)? And measure the fill under admission (AC-WG-49): if candidates fail often, sects start under their F17 targets and the loose world is the leftovers | user; systems-designer for the census | After the depth export's first census |
| 11 | **Founder's arrays for the minor moves and two sizings (new, 2026-11-25).** The ruling gives "each moved sect" an array, but the pages of seven moved minor sects (Bình Thủy, Hàm Nguyệt, Hồng Đậu, Lê Hoa, Lễ Tuyền, Ngạo Tuyết, Yến Quang) say "no founder's array", each with a story; two of them (Ngạo Tuyết, Yến Quang) move to denser land and need none by Formula G. **Answered 2026-11-25** (the ruling overrides the pages): all seven pages now name an array sized by Formula G (Formula G table); Ngạo Tuyết's and Yến Quang's are named records at 0. ~~Should those two carry a small bonus anyway?~~ **Answered 2026-11-25** (ruling group 11): no; the 0 is intended, since the array keeps a moved seat near its old density and a denser seat needs none (Formula G). ~~Băng Tâm's +0.6 and Lạc Hà's +0.3 may be sized from a ruin's density: re-size to about +0.75 and +0.5, or keep?~~ **Answered 2026-11-25** (ruling group 12): re-sized by Formula G to **+0.75** and **+0.5** (Formula G table; the pages' §2 updated) | user | Answered |
| 12 | **The final-seat check has no tool (new, 2026-11-25).** "49 of 50 pass, Cửu Cao by the exemption" is the depth pass's count; `depth_seat_audit.py` audits the old seats. Add Formula F on the final seats and leans, with the Wind exemption, to `depth_check.py` and to `export_world.py --check` (AC-WG-50) | tools-programmer | With the depth export |
| 13 | **Code and engine effects of this amendment (new, 2026-11-25).** (a) `export_world.py` must read `design/world/depth/` and merge into `cast_builds` (rule 6a); (b) WorldBuilder's fill must run rule 8a (birthplace, Linh Căn's land roll, Sects' admission); (c) `BuildGenerator.create_person` takes the caller's rng: tier C trees need a stream keyed on the person's key alone (rule 6), so the tree allocation needs its own keyed rng; (d) place density must add `seat_array_density` (Travel & Map); (e) the seat moves change place records (kinds, names, notes), routes, map symbols and seat paintings for 5 great seats and the minor moves (art cost, `design/world/depth/sects/<key>.md` §2) | gameplay-programmer, tools-programmer, art-director | With the depth export |
| 14 | **Stale counts elsewhere in this GDD (new, 2026-11-25).** The Overview, rule 7, rule 12, the UI origin list and AC-WG-10, -17, -31 still say 30 sects (7 great, 22 minor) and 47 origins; the world has 50 sects since provinces-v2 (2026-11-24), and five great seats have moved (an origin at a moved seat starts at the new seat); the NPC Relationships Interactions row still says "10 master ties". Not rewritten in this pass (out of its scope) | user, at the end-of-design review | The one review pass |
| 15 | **Where an uncovered `hidden` event shows (new, 2026-11-25).** Ruling group 12 keeps `hidden` events out of the public chronicle and annals "until the player uncovers them (event or Codex)" but names no tier for after. Rule 3a reads it as the annals (or the page's `tier:` override), shown from the uncovering on, in this game only. Confirm, or show uncovered secrets on the codex timeline as landmarks. Also owed: the Event Engine outcome that uncovers an event by id, and the Codex entry kind that carries one across lives | user; Event Engine, Codex & Karmic Carryover | AC-WG-56 |
