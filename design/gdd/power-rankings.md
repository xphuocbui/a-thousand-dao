# Power Rankings

> **Status**: Approved 2026-11-14 (lean re-review; the first review's 5 blockers resolved). Decisions by the user in-session; specialists consulted in lean mode: `systems-designer` (Formulas), `qa-lead` (Acceptance Criteria). CD-GDD-ALIGN skipped (lean mode)
> **Author**: the user + Claude
> **Last Updated**: 2026-11-14 (design-review revision: 5 blockers resolved)
> **Last Verified**: 2026-11-14
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given), Pillar 5 (A World That Remembers)

## Summary

Every cultivator's fighting strength, measured by real fights: a reference-panel rating when a build changes, refined
by same-realm matchmaking each season and by round robins at the top, shown as the one power number (replacing
chiến lực and `display_power`) and used to decide NPC-against-NPC fights in the living world.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Combat Defence & Healing, Realms, NPC Build Generation, Living World Tick`

## Overview

Power Rankings measures every cultivator's fighting strength by having them fight, and keeps the world's standings
from those fights. Each fighter (every NPC and the player) has one **power rating** on an Elo-style scale. It is
seeded by a **reference panel**: whenever a fighter's build changes, it fights the fixed reference fighters of its
realm and the realms beside it, and the rating that best explains those results is its base. **Matchmaking** then
refines it: each season every NPC fights a few same-realm opponents of similar rating, and the results move a small
learned offset on top of the base, so a build that beats the panel but loses to real people (or the reverse) is
rated by what it actually does. The strongest tiers (Nguyên Anh and Hóa Thần) also play a **full round robin** each
season, so the very top of the world is ranked exactly. The rating converts to the one **power number** shown
everywhere (it replaces Combat Formulas K's `display_power` and today's chiến lực: an unbuilt character of a realm
shows about that realm's power base), and the world's NPC-against-NPC fights are decided from ratings instead of the
old duel roll. Players feel it directly: the number on a character sheet is earned in fights, a rival's rank moves
as they grow, and a strange build that works shows it. All fights run through the real fight engine
(ADR-0001), off the session's random stream (ADR-0002).

## Detailed Design

### Core Rules

1. **Who is rated.** Every living character the fight compiler can compile (Combat rule 2): every NPC, the player and
   spirit beasts. Beasts are rated (their power number is shown and read by their owners' power shares),
   panel-rated at their own realm, but never listed in a ranking and never matched.
2. **One rating per fighter.** A fighter's **rating** is `base + offset` on an Elo-style scale (Formulas A). `base`
   comes from the reference panel (rule 4); `offset` is learned from fights against real opponents (rules 6-8).
3. **Anchors.** Each realm's typical reference fighter (Combat Formulas B, `combat_reference_fighters.json`) has a
   fixed rating `A_r` (Formulas A), so a realm's typical fighter rates the same in every world and every season. The
   other panel members' ratings are calibrated once per data version by fights against their realm's typical fighter
   (Formulas C) and stored with the data.
4. **The reference panel.** A fighter of realm r is panel-rated against: the typical fighter of realm r, the top-end
   fighter of realm r, and the typical fighters of realms r-1 and r+1 where they exist. It fights each member
   `panel_fights` times, on either side of the coin order, and its `base` is the rating that best explains those
   results against the members' known ratings (Formulas B). A panel runs when the fighter is created and again
   whenever its build changes (rule 5).
5. **What changes a build.** A stage change; a technique learned, slotted, unslotted or raised a layer; an
   item equipped or removed; a Kinh Mạch Đồ point spent; a capability gained; a change to talents or linh căn. The
   fighter's state becomes Stale (States below) and it keeps its current rating until the new panel runs. A
   breakthrough to a new realm is not a Stale change: the fighter becomes Provisional at its new realm (Formulas G,
   Edge Cases).
6. **Learned offset.** Every fight that runs between two fighters (matchmaking, round robin, the player's event
   fights) moves both fighters' `offset` by the Elo update (Formulas D), whatever their state; a world fight's rating
   roll (rule 11) moves none. `offset` stays within ±`offset_cap`. `offset_keep` applies once, when a panel replaces
   `base` (including the first panel after a breakthrough or a data change); until then the offset is carried
   unchanged. So what a fighter proved against people outlasts a build change but fades.
7. **Matchmaking.** Each season every NPC of realm r fights `match_fights[r]` matchmaking fights (1 at Luyện Khí, 2
   at Trúc Cơ and Kết Đan, none at Nguyên Anh and Hóa Thần, whose round robin covers them) against NPCs of its own realm near its rating.
   Pairing, for each of the realm's `match_fights[r]` rounds: sort the realm's living NPCs (Rated, Stale and
   Provisional alike) by their rating at the start of the season, highest first, ties by id; walk the list in
   order; each NPC not yet paired this round is paired with one still-unpaired NPC within `match_window` places,
   chosen by a keyed draw (rule 13) on the game seed, the season, the realm and the round. Each fight counts for
   both sides. The player never fights matchmaking fights: the player's offset moves only through the player's
   own fights.
8. **Round robins.** Each season, every rated NPC of Nguyên Anh and Hóa Thần fights every other rated NPC of those
   two realms once. Once a year, every rated Kết Đan NPC is due to fight every other rated Kết Đan NPC once; the year's pairs
   are dealt evenly across its seasons, and each season's slice is played in a keyed-shuffle order (rule 13, keyed on the game seed, the year and the season) so that when the budget truncates a season, which pairs drop does not depend on id. The Kết Đan round robin is best effort: it is the lowest-priority work (rule 14), and in a season whose panels use the whole panel share only about a third of its slice plays (Season budget). Here and throughout this GDD, a **rated** NPC is any living NPC with a
   rating, whatever its state (Rated, Stale or Provisional), as in rule 7. Round-robin fights update offsets as matchmaking fights do.
9. **Rankings.** A realm's ranking lists its rated NPCs and the player, ordered by rating. The top list
   ("the strongest under heaven") is the round-robin realms' ranking. Provisional fighters are listed after the
   Rated and Stale ones, marked as provisional. Ties in rating break by more rated fights, then by age (older first), then by id.
10. **The power number.** A fighter's rating converts to the one **power number** the game shows and stores
    (Formulas E). It replaces chiến lực and Combat Formulas K's `display_power` wherever one number is shown or
    stored: character sheets, NPC records, beast power shares, and members ranked in a mass clash.
11. **World fights.** An NPC-against-NPC fight in the Living World Tick (duel, feud, ambush) is decided by one roll
    from the two ratings (Formulas F), one draw from the session stream as the duel was. No fight runs. Each side's
    rating for the roll is lowered by its injury (Formulas F, `v`); the stored rating is not touched. Wars and
    great battles keep Combat's `rating_clash` (Combat Formulas K), with members ranked by power number.
12. **The player's fights.** An event fight the player takes runs the full fight (Combat; ADR-0001 step 4) and, when
    the opponent is rated, moves both offsets (rule 6). The event card's odds stay the fight engine's trial fights
    (ADR-0001 step 4), which read the actual matchup rather than the two ratings.
13. **Determinism and the session stream.** Every panel, matchmaking and round-robin fight is seeded from a keyed
    stream on the game seed, the season, the two fighters' ids (sorted) and the fight's index among that pair's
    fights in the season, counted across panels, matchmaking and round robins (ADR-0002 decision 4, ADR-0003
    decision 4), so no two fights of a season share a seed; none draws from the session stream. Pairing reads the ratings at the start of the season; the fights do not read ratings. A season's results
    are applied after the batch in one fixed order: first every panel result, by fighter id (each sets `base`, then applies `offset_keep` to `offset` and `n` once); then every pair fight, by the sorted pair ids and the fight index. Each pair update reads both fighters' rating and `n` as they stand at that point in the order (Formulas D), so the outcome never depends on which fight finished first and a fighter's panel and same-season fights always combine the same way.
14. **Scheduling.** Rating work runs in the background through the season, in this order: the player's panel;
    panels of Stale and Provisional fighters (higher realm first, then those in the player's current region, then by
    id); the Nguyên Anh and Hóa Thần round robin; matchmaking; the Kết Đan round robin's pairs for the season. At
    most `season_fight_budget` fights run in a season, and panels may use at most `panel_budget_share` of it: panels
    beyond that share wait for the next season, and share the panels leave unused goes to the round robins and
    matchmaking. When a season ends with work left, unfinished panels carry to the next season and that season's
    unplayed matchmaking and round-robin fights are dropped.
15. **Provisional ratings.** A fighter without a panel of its current realm (an NPC created during play, until its
    panel runs in the season batch; a fighter that has just broken through to a new realm; every fighter of an old
    save) takes a **provisional rating**: its realm's anchor moved by its stage (Formulas G). It is shown as
    provisional until its first panel at that realm runs.
16. **World generation.** When a new game is created, every generated NPC's panel runs while the game loads, outside
    any season budget (about 64,000 fights; Season budget), so a new world starts with every NPC Rated.

### States and Transitions

The rating state of one fighter:

| State | Meaning | Enters from | Leaves to |
|---|---|---|---|
| Provisional | Rated by Formulas G only; shown marked | Created during play; Rated or Stale (it breaks through to a new realm); loaded from an old save (Edge Cases) | Rated (its first panel at its realm runs), Gone (it dies) |
| Rated | `base` from a panel of its current build | Provisional, Stale (a panel runs); created at world generation (rule 16) | Stale (its build changes, or a new data version), Provisional (a breakthrough), Gone (it dies) |
| Stale | Its build changed; keeps its last rating until the new panel | Rated (a build change of rule 5, or a new data version) | Rated (the panel runs), Provisional (a breakthrough), Gone (it dies) |
| Gone | Dead or removed; no longer fights or ranks | Rated, Stale, Provisional | none (its last rating stays on its record for the chronicle) |

A build change or a new data version leaves a Provisional fighter Provisional: its pending panel already compiles
the current build against the current data. A Provisional or Stale fighter may still be matched and fought: a world fight reads its current rating, and a
matchmaking or round-robin fight updates its offset as usual.

### Interactions with Other Systems

| System | Direction | What flows | Interface owner |
|---|---|---|---|
| Combat | in | `FighterCompiler.compile`, `CombatService` fights, the reference fighters, `rating_clash` for wars | Combat |
| Realms | in | Realm and stage (anchors, provisional ratings, the panel's realms), power base `B_p` | Realms |
| Character Stats, Cultivation Techniques, Item Database, Kinh Mạch Đồ | in | Build-change signals (rule 5) | each system raises; Power Rankings listens |
| NPC Build Generation | in | New NPCs (Provisional) | NPC Build Generation |
| Living World Tick | in / out | In: the season hook that runs the batch, deaths. Out: world-fight outcomes (rule 11) | Living World Tick asks, Power Rankings answers |
| Event Engine | in / out | In: the player's rated fights (rule 12). Out: power numbers for enemy choice and text | Event Engine |
| Sects & Missions | out | Ratings and power numbers for ranks, leaders and wars | Sects reads |
| Game UI, Debug Terminal | out | Power number, rating state, rankings | UI reads |
| Save / Load | in / out | Each fighter's base, offset, state, rated-fight count and the data version of its panel; the season's pending work | Session saves |

## Formulas

All constants are data (`assets/data/combat_rankings.json`); ratings and offsets are floats stored to 0.1.
`systems-designer` proposed these formulas (lean review); the user's choices in Detailed Design set their scope.

### A. Rating scale and anchors

The rating_scale formula is defined as:

`A_r = A_0 + realm_step · r` ; `E(R_a, R_b) = 1 / (1 + 10^((R_b − R_a) / 400))`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| r | int | 0–4 | Realms | Realm index |
| A_0 | int | 1000 | data file | Rating of Luyện Khí's typical fighter |
| realm_step | int | 400 | data file | Rating gap between adjacent realm anchors: 10:1 odds, matching the 10× power base per realm |
| A_r | int | 1000–2600 | calculated | Fixed rating of realm r's typical reference fighter |
| R_a, R_b | float | 0–3600 | calculated | The two fighters' ratings, `base + offset` |
| E | float | (0, 1) | calculated | a's expected score against b |

**Output Range:** anchors 1000 / 1400 / 1800 / 2200 / 2600; E is strictly between 0 and 1 (0.909 across one realm
step), so it needs no clamp.
**Example:** R_a 1450 against R_b 1400: E = 1 / (1 + 10^(−0.125)) = **0.571**.

### B. Panel base rating

The panel_base formula is defined as:

`base = clamp(R*, A_r − 800, A_r + 800)`, where R* solves
`Σ_i panel_fights · E(R*, R_i) + prior_games · E(R*, A_r) = Σ_i S_i + prior_games · 0.5`

Solved by bisection on `[A_r − 800, A_r + 800]` (24 steps; the left side rises strictly in R, so there is one root,
and bisection is deterministic where Newton overshoots in the flat tails). The **prior** (2 pseudo-games drawn
against the fighter's own realm anchor) gives a finite answer when a fighter wins or loses every panel fight, and
washes out against 12–16 real fights; the ±800 clamp is only a safety bracket.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| R_i | float | 1000–3400 | Formulas A, C | Known rating of panel member i (3 or 4 members) |
| panel_fights | int | 4 | data file | Fights against each member, 2 on each side of the coin order |
| S_i | float | 0–4 | the fights | Score against member i: 1 a win, 0.5 a draw or the time limit, 0 a loss |
| prior_games | float | 2 | data file | Pseudo-games pulling toward the realm anchor |
| A_r | int | 1000–2600 | Formulas A | The fighter's realm anchor |
| base | float | A_r ± 800 | calculated | The panel base rating |

**Output Range:** `A_r − 800` to `A_r + 800` (200–3400 overall). A clean sweep lands a few hundred above the
realm-up member; a clean loss a few hundred below the realm-down member.
**Example:** a Trúc Cơ fighter against members rated 1000 (Luyện Khí typical), 1400 (typical), 1550 (top-end) and
1800 (Kết Đan typical) scores 4, 3, 1 and 0 of 4. The left side is 8.88 at R = 1440 against a right side of 9.00,
with a slope of 0.0177 per point, so **base ≈ 1447**.

### C. Panel member calibration

The member_calibration formula is defined as:

`top_end_r = clamp(A_r + 400 · log10(s' / (1 − s')), A_r, A_r + 800)`, with `s' = (S + prior_games · 0.5) / (N + prior_games)`

Formulas B with one opponent (the realm's typical fighter) has this closed form. It runs once per data version and
the results are stored with the data (Core Rules rule 3).

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| N | int | 200 | data file (`calibration_fights`) | Fights against the realm's typical fighter, 100 on each side |
| S | float | 0–N | the fights | The top-end fighter's score |
| prior_games | float | 2 | data file | The same prior as Formulas B |
| s' | float | (0, 1) | calculated | The prior-shrunk score share |
| top_end_r | float | A_r to A_r + 800 | calculated | The top-end member's stored rating |

**Output Range:** `A_r` to `A_r + 800` (a top-end fighter is at least typical). 1,000 fights once, about 6 s.
**Example:** realm 2, 150 wins and 10 draws in 200: s' = 156 / 202 = 0.772, so top_end_2 = 1800 + 212 = **2012**.

### D. Offset update

The offset_update formula is defined as:

`offset_a ← clamp(offset_a + K(n_a) · (s_a − E(R_a, R_b)), −offset_cap, +offset_cap)`, with
`K(n) = max(K_min, K_0 / (1 + n / n_half))`, R and n read as they stand when this fight is applied in the season's fixed order (Core Rules rule 13), both sides' values taken before either is updated by this fight; after each applied fight `n ← n + 1` for both sides; on a new panel,
`offset ← offset · offset_keep` and `n ← floor(n · offset_keep)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| s_a | float | 0, 0.5, 1 | the fight | a's result (a draw or the time limit is 0.5) |
| n_a | int | ≥ 0 | state | a's rated fights (panel fights do not count) |
| K_0 | int | 48 | data file | K for a fighter with no rated fights |
| n_half | int | 10 | data file | Rated fights at which K halves |
| K_min | int | 16 | data file | K floor, reached at 20 rated fights |
| offset_cap | int | 200 | data file | Largest offset: half a realm step, a ×3.2 power factor, never enough to overturn a realm |
| offset_keep | float | 0.5 | data file | Share of the offset and of n a new panel keeps |

**Output Range:** offset −200 to +200; one fight moves it at most 48.
**Example:** a (R 1450, n 4, K = 48 / 1.4 = 34.3) loses to b (R 1400, n 14, K = 48 / 2.4 = 20): E_a = 0.571, so
offset_a −19.6 and offset_b +11.4.

### E. Power number

The power_number formula is defined as:

`power = max(1, round_3sf(B_p[0] · 10^((R − A_0) / realm_step)))`

The stored value is the rating; the power number is computed on read and shown to 3 significant figures with
thousands separators. A realm's typical fighter shows exactly that realm's power base `B_p[r]`.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| R | float | 0–3600 | Formulas B, D, G | The fighter's rating |
| B_p[0] | int | 100 | Character Stats (`power_base`) | Luyện Khí's power base |
| A_0, realm_step | int | 1000, 400 | Formulas A | Scale constants |
| power | int | 1–316,000,000 | calculated | The shown power number |

**Output Range:** 1 (floor) to about 316 million (R 3600). Typical fighters show 100 / 1,000 / 10,000 / 100,000 /
1,000,000.
**Example:** R 1447: 100 · 10^1.1175 = 1,311, shown as **1,310**.

### F. World fight

The world_fight formula is defined as:

`R_roll = R + 400 · log10(max(v, v_c))` for each side; `P(A) = clamp(E(R_roll_a, R_roll_b) + (eff_khi_van_A − eff_khi_van_B) · khi_van_per_point, p_min, p_max)`

A wins when one draw from the session stream is below P(A). World fights have no draws.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| R_a, R_b | float | 0–3600 | Formulas B, D, G | The two ratings |
| eff_khi_van | float | as the duel | Character Stats | Effective khí vận of each side |
| v | float | 0.05–1 | Combat Formulas K (vitality fraction) | A side's current vitality as a share of full; 1 when uninjured |
| v_c | float | 0.4 | data file (`combat_rules.json` duel `injured_power_floor`) | Floor on v: at most −159 rating for the roll (400·log10 0.4) |
| khi_van_per_point | float | 0.001 | data file (`combat_rules.json` duel) | Win chance per point of khí vận |
| p_min, p_max | float | 0.02, 0.98 | data file (`combat_rules.json` duel `min_win_chance`, `max_win_chance`) | Clamp: a Hóa Thần still loses to a Luyện Khí 2 % of the time |

**Output Range:** 0.02–0.98.
**Example:** R 1450 against 1400 with +10 khí vận, both uninjured: 0.571 + 0.010 = **0.581**. With A at v 0.5:
R_roll_a = 1450 − 120 = 1330, E = 0.4 + 0.010, so P(A) = **0.410** (E = 0.4000 before khí vận).

### G. Provisional rating

The provisional_rating formula is defined as:

`R_prov = A_r + stage_step · stage`

A stage raises both damage and pools by its multiplier (1.00 / 1.15 / 1.30 / 1.45), so strength grows roughly with
its square: `400 · log10(m²)` gives 49 / 91 / 129, which 45 per stage matches within 6 (stage 3 rates 135).

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| A_r | int | 1000–2600 | Formulas A | The realm anchor |
| stage | int | 0–3 | Realms | Stage within the realm |
| stage_step | int | 45 | data file | Rating per stage |
| R_prov | int | 1000–2735 | calculated | The provisional rating (no offset) |

**Output Range:** 1000–2735. A provisional fighter's rating is `R_prov + offset` (its offset carried unchanged);
the first panel replaces `R_prov` with `base` and then applies `offset_keep`.
**Example:** Trúc Cơ stage 2: 1400 + 90 = **1490**, power 1,680.

### Season budget

| Value | Default | Note |
|---|---|---|
| match_fights | [1, 2, 2, 0, 0] | By realm; Nguyên Anh and Hóa Thần are covered by their round robin |
| match_window | 5 | Places either side in the realm's rating order |
| season_fight_budget | 10,000 | About 60 s of background compute at 6 ms a fight |
| panel_budget_share | 0.5 | Largest share of the season budget panels may use (Core Rules rule 14); safe range 0.3–0.7 |

The population, from `world_generation.json` realm weights for a 5,000-cultivator world: about 3,945 Luyện Khí,
835 Trúc Cơ, 190 Kết Đan, 27 Nguyên Anh and 3 Hóa Thần. At 4 seasons a year: matchmaking (3,945 + 1,670 + 380) / 2 ≈
**3,000** fights; the Nguyên Anh and Hóa Thần round robin C(30, 2) = **435**; the Kết Đan yearly round robin
C(190, 2) / 4 ≈ **4,490** a season. That is about 7,925 fights of non-panel work.

**Panels.** A panel is 12 fights (Luyện Khí and Hóa Thần, 3 members) or 16 (4 members). At the default share,
panels get up to 5,000 fights a season, about **350 panels**: room for about 7 % of NPCs to change build each
season. That rate is an assumption to be measured (Open Question 5). In a season that uses the whole panel share,
the other 5,000 fights cover the top round robin and matchmaking first, then about 1,565 of the season's 4,490
Kết Đan pairs; the rest drop (rule 14). In a quieter season the unused panel share completes the season's Kết Đan slice. Because the slice is shuffled (rule 8), a truncated season leaves a random, not id-ordered, share of pairs unplayed.

**World generation** (rule 16): about 3,945 × 12 + 1,052 × 16 + 3 × 12 ≈ **64,000** panel fights, about 6.5 minutes
on one worker or about 50 s on 8, run once while a new game loads.

## Edge Cases

- **If a fighter breaks through to a new realm**: it becomes Provisional at the new realm (Formulas G), its offset
  carried unchanged until its panel against the new realm runs (which then applies `offset_keep` once), and is
  shown as provisional until then. Keeping the
  old rating would leave a new Trúc Cơ cultivator rated as a Luyện Khí one for a season.
- **If a fighter's build changes several times in one season**: it gets one panel, for the build it has when the
  panel runs.
- **If the player opens their power number while Stale**: the player's panel runs then (about 100 ms, outside the
  season budget), at most once per build.
- **If a fighter wins or loses every panel fight**: the prior (Formulas B) gives a finite rating a few hundred
  points beyond the strongest or weakest member; the ±800 bracket is never the answer in practice.
- **If a fight ends at the time limit or in a draw**: it scores 0.5 for both sides in panels and offsets. World
  fights (Formulas F) have no draws.
- **If a fighter cannot compile** (the compiler refuses an art or field): it keeps its current rating and state, the
  refusal is logged with the fighter's id, and its panel is retried the next season. It never blocks the batch.
- **If a realm has fewer than 2 rated NPCs** (any state, Core Rules rule 8): it has no matchmaking or round robin that season; its fighters keep
  their panel rating and offset.
- **If matchmaking leaves an NPC unpaired** (an odd count, or every neighbour within `match_window` already used):
  the window widens by `match_window` once; if still unpaired, the NPC sits out that season's pass.
- **If the same pair would meet twice in one season's matchmaking**: that candidate is struck from the draw and the
  NPC redraws among its other unpaired candidates in the window; if none is left it follows the widening rule above.
  Round robins pair each pair exactly once.
- **If the player's own panel or event fight applies mid-season**: it applies at once, not in the batch's fixed
  order (rule 13). The order is still deterministic, because it follows the player's play order from the same save.
- **If beasts are counted**: they add panels to the demand figures of Season budget (one per beast, 12 fights at its
  realm) and are rated at world generation like NPCs; their count is data and small beside the NPC population.
- **If a fighter dies with fights pending**: its pending fights are dropped; results already applied stand. Its
  last rating stays on its record (Gone).
- **If a fighter has a panel and pair fights in the same season**: panels apply first, then pair fights (Core Rules rule 13), so the new `offset_keep` halving never discounts that season's fresh results.
- **If the season ends with rating work left**: unfinished panels carry to the next season; that season's unplayed
  matchmaking and round-robin fights are dropped (Core Rules rule 14). The Kết Đan round robin's undealt pairs are
  dropped at the year's end, not carried.
- **If the reference fighters or the combat data change** (a new data version): the panel members are recalibrated
  (Formulas C), every Rated fighter becomes Stale with its offset carried (Provisional fighters stay Provisional), and the panels spread over the following
  seasons by the usual order (each applying `offset_keep` once).
- **If an old save has no ratings**: every living fighter loads as Provisional.
- **If a world fight pairs an injured fighter**: its roll rating drops by `400·log10(max(v, v_c))` (Formulas F), at
  most 159 points; its stored rating, offset and rank do not change, so an injury never moves a ranking.
- **If a world fight pairs a Provisional fighter**: it uses the provisional rating; no offset moves (offsets move only
  from fights that run).
- **If two fighters have the same rating**: rankings break the tie by more rated fights, then older, then id (Core
  Rules rule 9).
- **If Power Rankings is switched off** (its own flag, Dependencies): the power number shown is chiến lực, world
  fights use the duel, and no rating work runs; ratings already stored stay in the save untouched.
- **If the player picks weak opponents to raise their offset**: each win against a much weaker rated fighter moves
  the offset by almost nothing (E near 1), and the offset is capped at ±200, so farming cannot move the power number
  more than ×3.2.

## Dependencies

| System | Kind | What it supplies or takes | Status |
|---|---|---|---|
| Combat (#21) | Hard, upstream | The fight engine, `FighterCompiler.compile`, `CombatService`, the reference fighters; `rating_clash` for wars | Approved; engine built (ADR-0001). Formulas K's `display_power` is replaced by this GDD's power number (user decision 2026-11-14), and rule 17's "individual NPC duels run the full fight" by Core Rules rule 11's rating roll for world fights. **Combat amended 2026-11-14** (combat.md rule 17, Formulas K, AC-CB-65) |
| Combat Defence & Healing (#21a) | Hard, upstream | The defence the compiled fighters carry | Approved; built |
| Realms & Bottlenecks (#8) | Hard, upstream | Realm, stage, `power_base` | In review |
| Character Stats, Cultivation Techniques, Item Database, Kinh Mạch Đồ | Hard, upstream | The build every panel compiles, and the build-change signals of Core Rules rule 5 | Approved or in review; built |
| NPC Build Generation (#24) | Hard, upstream | New NPCs (Provisional) | Built; no GDD |
| Living World Tick (#28) | Hard, both ways | Calls the season batch and asks for world-fight outcomes (Core Rules rules 11, 14) | Built (abstract); no GDD |
| Event Engine (#23) | Soft, both ways | Sends the player's rated fights; reads power numbers | Built; no GDD |
| Sects & Missions (#26) | Soft, downstream | Reads ratings and power numbers for ranks, leaders and wars | Approved |
| Game UI (#37), Debug Terminal (#36) | Soft, downstream | Show the power number, rating state and rankings | Terminal built; Game UI not started |
| Save / Load | Hard, both ways | Stores each fighter's rating fields and the season's pending work | Built |
| ADR-0001, ADR-0002 | Constraint | Fights through `CombatService`; keyed streams for every rating fight | Accepted |

**Feature flag.** Power Rankings ships behind its own flag (`combat_rankings.json` `enabled`, off until signed off in
play), separate from `combat_rules.json` `fight_engine`. Off, the power number is chiến lực and world fights use the
duel (Edge Cases).

**Bidirectional notes** (2026-11-14 revision): added to Combat (rule 17, Formulas K, AC-CB-65), the registry
(`rating_clash`, `display_power`, new formula and constant entries), ADR-0003 (decisions 9-11), Realms and Sects.
Still owed: Living World Tick (no GDD yet; name this system when it is written).

## Tuning Knobs

All in `combat_rankings.json` unless noted. Ranges are starting points to be confirmed by the first measured data pass.

| Knob | Default | Safe range | Affects |
|---|---|---|---|
| `realm_step` | 400 | 300–500 | Odds across a realm; ties to the 10× power base (Open Question 2) |
| `stage_step` | 45 | 30–60 | Provisional rating per stage |
| `panel_fights` | 4 | 2–8 | Panel accuracy against compute (12–16 fights a panel) |
| `prior_games` | 2 | 1–4 | Pull of a panel toward its anchor; finite result on a sweep |
| `calibration_fights` | 200 | 100–400 | Top-end member accuracy, once per data version |
| `K_0` / `K_min` / `n_half` | 48 / 16 / 10 | K 8–64; n_half 5–20 | How fast offsets move and settle |
| `offset_cap` | 200 | 100–300 | How far real fights can move a rating from its panel base |
| `offset_keep` | 0.5 | 0.25–0.75 | How much a fighter's earned offset survives a build change |
| `match_fights` / `match_window` | [1,2,2,0,0] / 5 | window 3–10 | Matchmaking volume and pair closeness |
| `season_fight_budget` | 10,000 | 5,000–20,000 | Background compute per season |
| `panel_budget_share` | 0.5 | 0.3–0.7 | Panels against round robins in a season |
| `duel.injured_power_floor` (`combat_rules.json`) | 0.4 | 0.2–0.6 | Largest injury penalty on a world-fight roll |

## Visual/Audio Requirements

`art-director` not consulted (lean mode: rankings are read as numbers and lists, not visual events). Review manually
before production.

- **Rank changes are news, not effects.** A rise into or out of a realm's top 10, or into the strongest-under-heaven
  list, is a world-news line (Living World Tick's news) with the old and new rank. No VFX.
- **Provisional is visible.** A provisional rating shows its power number in a muted style with a "~" or
  "(provisional)" mark, never as an exact figure.
- **Audio:** a single soft cue when the player's own rank changes by a whole place in the realm top 10 or enters the
  top list; no sound for NPC changes. Owned by the Audio system when it is designed.

## Game Feel

- **Earned, not given.** The power number moves after the player does something (a breakthrough, a new piece, a won
  fight), and the change is shown at that moment, with the old number, as the stat-sheet deltas already do.
- **No waiting.** Rating work never blocks a turn: the player's own panel is the only synchronous run during play (about 100 ms),
  the world-generation panels run once while a new game loads (rule 16), and everything else runs in the background through the season.
- **Stable at rest.** A fighter whose build did not change moves only by its offset, at most 48 points a fight and
  ±200 in all, so a number does not jitter from season to season without a cause.

## UI Requirements

- **Character sheet and NPC cards:** the power number (Formulas E) where chiến lực is shown today, with the state
  (provisional, stale) and the realm rank ("12th of 819 Trúc Cơ").
- **Rankings screen** (debug terminal command first, `rankings [realm]`): a realm's ranking, the player's place
  highlighted, each row name, sect, stage, power number and rated-fight count; and the strongest-under-heaven list.
- **Explain:** `explain power` breaks the number into panel base, offset and the last fights that moved the offset.
- **Event cards** keep showing the trial-fight odds (ADR-0001 step 4), not a rating estimate.

## Cross-References

| This document references | Section there | What | Use here |
|---|---|---|---|
| `design/gdd/combat.md` | Rule 2, Formulas B, Formulas K | The compiler, the reference fighters, `rating_clash`, `display_power` | Panels and fights; `display_power` replaced by Formulas E |
| `design/gdd/combat-defence.md` | Formulas A0–G | Defence in compiled fighters | Read through the compiler |
| `design/gdd/canh-gioi.md` | Formulas (stage multiplier), rule 20 | Realm, stage, `power_base` | Anchors, provisional ratings, the power number |
| `design/gdd/character-stats.md` | Formulas C, `power_base` | Pools, `B_p` | Formulas E's scale |
| `design/gdd/cong-phap.md` | Rules 6, 17, 19 | Technique slots and NPC techniques | Build changes; what panels compile |
| `design/gdd/item-database.md` | Rules 11, 21 | Equipping and what pieces give | Build changes |
| `design/gdd/sects.md` | Ranks, leaders, wars | Readers of ratings | Downstream |
| `docs/architecture/adr-0001-combat-engine-in-godot.md` | Decision 5, Migration Plan step 5 | `CombatService`, the rating profile | Amended by this GDD's ADR |
| `docs/architecture/adr-0002-random-streams.md` | Decisions 3, 4 | One draw per world fight; keyed streams | Core Rules rules 11, 13 |

## Acceptance Criteria

Drafted with `qa-lead` (lean review). [Logic] criteria run in GdUnit4 with fixed seeds and the default
`combat_rankings.json`; fights are stubbed with scripted results where a criterion tests arithmetic, not the engine.
Ratings compare within ±0.05 (the stored 0.1).

**Core Rules**

- **AC-PR-01** [Logic] Rule 1. **GIVEN** NPCs, the player and a spirit beast, **WHEN** ratings start and a season runs, **THEN** all three have a rating and a power number; the beast is in no ranking and no pair.
- **AC-PR-02** [Logic] Rule 2. **GIVEN** base 1447.0 and offset 11.4, **WHEN** the rating is read, **THEN** it is 1458.4, with base and offset stored separately to 0.1.
- **AC-PR-03** [Logic] Rule 3, Formulas A. **GIVEN** two worlds with different seeds read in seasons 1 and 9, **WHEN** each realm's typical fighter's rating is read, **THEN** it is 1000 / 1400 / 1800 / 2200 / 2600 in every case.
- **AC-PR-04** [Logic] Rule 3. **GIVEN** top-end ratings already calibrated for the data version, **WHEN** a game loads and runs a season, **THEN** calibration runs 0 fights and the stored ratings are used.
- **AC-PR-05** [Logic] Rule 4. **GIVEN** fighters at Luyện Khí, Trúc Cơ and Hóa Thần, **WHEN** panels are built, **THEN** Trúc Cơ has 4 members (Luyện Khí typical, Trúc Cơ typical and top-end, Kết Đan typical) and the other two have 3.
- **AC-PR-06** [Logic] Rule 4. **GIVEN** a Trúc Cơ fighter, **WHEN** its panel runs, **THEN** it fights each member exactly 4 times, 2 on each side of the coin order: 16 fights, none counted in n.
- **AC-PR-07** [Logic] Rule 5 (parametrised over its causes other than a breakthrough, which is AC-PR-37). **GIVEN** a Rated fighter at R, **WHEN** any build change of rule 5 happens, **THEN** it is Stale and still rated R until a panel runs.
- **AC-PR-08** [Logic] Rule 5. **GIVEN** a Rated fighter, **WHEN** it ages a season, travels or gains khí vận, **THEN** it stays Rated and no panel is queued.
- **AC-PR-09** [Logic] Rule 6, Formulas D. **GIVEN** offset +195, n 0, E 0.5, **WHEN** it wins a rated fight, **THEN** its offset is +200.0 (not +219); the mirror gives −200.0.
- **AC-PR-10** [Logic] Rule 6. **GIVEN** offset +40.0 and n 15, **WHEN** a new panel replaces its base, **THEN** its offset is +20.0 and n is 7.
- **AC-PR-11** [Logic] Rule 7. **GIVEN** a seeded world with at least 20 NPCs in each realm, **WHEN** a season's matchmaking runs, **THEN** each NPC is in at most 1 / 2 / 2 / 0 / 0 matchmaking fights by realm, every pair is same-realm, and both sides' offsets update.
- **AC-PR-12** [Logic] Rule 7. **GIVEN** the same world, **WHEN** pairs form, **THEN** every pair is within 5 places in the start-of-season rating order, or within 10 when widened (AC-PR-36).
- **AC-PR-13** [Logic] Rule 7. **GIVEN** a Trúc Cơ player mid-ranking, **WHEN** 4 seasons of matchmaking run, **THEN** the player is in no pair and the player's offset and n are unchanged.
- **AC-PR-14** [Logic] Rule 8. **GIVEN** 28 rated Nguyên Anh and Hóa Thần NPCs, **WHEN** a season runs, **THEN** exactly 378 round-robin fights run, every pair once.
- **AC-PR-15** [Logic] Rule 8. **GIVEN** 200 Kết Đan NPCs unchanged for a year and an ample budget, **WHEN** its 4 seasons run, **THEN** 19,900 pairs run, each once, 4,975 a season; **AND GIVEN** a budget that truncates each season's slice to 35 %, **THEN** the played pairs follow the keyed shuffle (identical for the same seed) and over 20 seeds no NPC id band plays fewer than 25 % or more than 45 % of its pairs.
- **AC-PR-16** [Logic] Rule 9. **GIVEN** NPCs all at 1500.0 (n 10, age 50, id 7), (n 10, age 80, id 9), (n 12, age 30, id 3) and a Provisional NPC at 1600, **WHEN** the ranking is built, **THEN** the order is id 3, id 9, id 7, then the Provisional NPC, marked.
- **AC-PR-17** [Logic] Rule 9. **GIVEN** a realm with a Gone NPC and the player, **WHEN** its ranking is built, **THEN** the player is listed, the Gone NPC is not, and the top list is exactly the Nguyên Anh and Hóa Thần ranking.
- **AC-PR-18** [Integration] Rule 10. **GIVEN** the flag on and a fighter at R 1447, **WHEN** the character sheet, the NPC record, the owner's beast power share and a mass-clash member ranking read power, **THEN** all read 1,310 and none reads chiến lực.
- **AC-PR-19** [Logic] Rule 11. **GIVEN** NPCs at 1450 and 1400 with +10 khí vận for A, **WHEN** the world tick resolves their duel, **THEN** 0 fights run, the session stream advances exactly 1 draw, and a draw of 0.580 gives A, 0.582 gives B.
- **AC-PR-20** [Integration] Rule 11. **GIVEN** a sect war, **WHEN** it resolves, **THEN** it uses `rating_clash` with members ordered by power number.
- **AC-PR-21** [Integration] Rule 12. **GIVEN** the player (R 1450, n 4) against a rated NPC (R 1400, n 14), **WHEN** the player takes the event fight and loses, **THEN** a full fight ran, the player's offset moves −19.6 and the NPC's +11.4, and both n rise by 1.
- **AC-PR-22** [Integration] Rule 12. **GIVEN** an event card for a fixed matchup, **WHEN** the opponent's offset changes by +150 with builds unchanged, **THEN** the card's odds are unchanged (trial fights, not E).
- **AC-PR-23** [Logic] Rule 13. **GIVEN** game seed X, season S and fighters a and b, **WHEN** their fight is seeded with a and b in either order, **THEN** the seed and the result are identical; **AND GIVEN** a Trúc Cơ panel's 4 fights against one member, and a Kết Đan pair that meets in matchmaking and its round robin in the same season, **THEN** every one of those fights has a distinct seed.
- **AC-PR-24** [Logic] Rule 14. **GIVEN** a queue with the player's Stale panel, a Stale Hóa Thần panel, a Provisional Luyện Khí panel, the Nguyên Anh and Hóa Thần round robin, matchmaking and Kết Đan round-robin pairs, **WHEN** the batch runs, **THEN** they run in exactly that order.
- **AC-PR-25** [Logic] Rule 14. **GIVEN** `season_fight_budget` 200 and `panel_budget_share` 0.5 in test data and more work than that, **WHEN** a season runs, **THEN** exactly 200 fights run (the player's on-open panel, AC-PR-39, excluded), of which at most 100 are panel fights; **AND GIVEN** only 40 panel fights queued, **THEN** the other 160 are round-robin and matchmaking fights.
- **AC-PR-26** [Logic] Rules 15, 16. **GIVEN** a new game's world generation (test world of 50 NPCs), **WHEN** loading finishes, **THEN** every generated NPC is Rated, its panel ran, and the first season's budget count is 0; **AND GIVEN** a Trúc Cơ stage-2 NPC created during play, **WHEN** its rating is read before its panel runs, **THEN** it is Provisional at 1490.

**Formulas**

- **AC-PR-27** [Logic] A. **GIVEN** 1450 and 1400, **WHEN** E is computed, **THEN** E = 0.571 (±0.001), E(a,b) + E(b,a) = 1, and one realm step gives 0.909.
- **AC-PR-28** [Logic] B. **GIVEN** members 1000 / 1400 / 1550 / 1800, scores 4 / 3 / 1 / 0 of 4 and A_r 1400, **WHEN** the base is solved, **THEN** it is 1447 ± 1, bit-identical across two runs.
- **AC-PR-29** [Logic] B. **GIVEN** the same panel with 16 of 16 and 0 of 16, **WHEN** solved, **THEN** 1800 < base < 2200 and 600 < base < 1000, both finite.
- **AC-PR-30** [Logic] C. **GIVEN** realm 2 with 150 wins and 10 draws in 200, **WHEN** calibrated, **THEN** s' = 0.772 and top_end_2 = 2012 ± 1; with S = 0 it clamps to 1800.
- **AC-PR-31** [Logic] D. **GIVEN** a (1450, n 4) loses to b (1400, n 14), **WHEN** offsets update, **THEN** K_a = 34.3, K_b = 20.0, offset_a −19.6, offset_b +11.4.
- **AC-PR-32** [Logic] D. **GIVEN** n = 0 / 10 / 20 / 40, **WHEN** K is computed, **THEN** it is 48 / 24 / 16 / 16.
- **AC-PR-33** [Logic] E. **GIVEN** R = 1447 / 1000 / 1400 / 1800 / 2200 / 2600 / 0 / 3600, **WHEN** the power number is computed, **THEN** it is 1,310 / 100 / 1,000 / 10,000 / 100,000 / 1,000,000 / 1 / 316,000,000.
- **AC-PR-34** [Logic] F. **GIVEN** 1450 against 1400 with +10 khí vận, then 2600 against 1000, then 1000 against 2600, **WHEN** P(A) is computed, **THEN** it is 0.581 / 0.98 / 0.02.
- **AC-PR-34a** [Logic] F. **GIVEN** A (1450, v 0.5) against B (1400, v 1), no khí vận, **WHEN** P(A) is computed, **THEN** it is 0.400 (±0.001); **AND GIVEN** v 0.05 and v 0.4 on one side, **THEN** both use v_c 0.4 (−159); stored rating, offset and rank are unchanged after the fight.
- **AC-PR-54** [Integration] B, Open Question 1. **GIVEN** a generated 5,000-NPC world after world-generation panels, **WHEN** panel bases are read per realm, **THEN** in each realm the 10th-to-90th percentile spread of `base` is at least 150 points and fewer than 40 % of the realm's NPCs share one 25-point bin; the flag stays off until this passes.
- **AC-PR-35** [Logic] G. **GIVEN** Trúc Cơ stage 2, Luyện Khí stage 0 and Hóa Thần stage 3, **WHEN** R_prov is computed, **THEN** it is 1490 (power 1,680) / 1000 / 2735.

**Edge Cases**

- **AC-PR-36** [Logic] **GIVEN** an odd count in a realm and a forced case with every neighbour within 5 used, **WHEN** pairing runs, **THEN** the window widens once to 10, an NPC still unpaired sits out, and no pair repeats in the season.
- **AC-PR-37** [Logic] **GIVEN** a Rated Luyện Khí stage-3 NPC with offset +40, **WHEN** it breaks through to Trúc Cơ stage 0, **THEN** it is Provisional at 1400 + 40 = 1440, shown provisional; **WHEN** its Trúc Cơ panel then runs, **THEN** its offset becomes +20.
- **AC-PR-38** [Logic] **GIVEN** 3 build changes in one season, **WHEN** the batch runs, **THEN** exactly 1 panel runs, compiled from the final build.
- **AC-PR-39** [Integration] **GIVEN** the player Stale, **WHEN** the power number is opened twice with no build change between, **THEN** 1 synchronous panel runs on the first open, none on the second, and the season budget count is unchanged.
- **AC-PR-40** [Logic] **GIVEN** a panel fight and a rated fight that each end at the time limit, **WHEN** scored, **THEN** each is 0.5 for both sides.
- **AC-PR-41** [Logic] **GIVEN** the compiler refuses fighter X, **WHEN** the batch runs, **THEN** it completes, X's state and rating are unchanged, the log names X's id, and X's panel is queued next season.
- **AC-PR-42** [Logic] **GIVEN** a realm with 1 rated NPC, **WHEN** a season runs, **THEN** that realm has 0 matchmaking and round-robin fights and the NPC's rating is unchanged.
- **AC-PR-43** [Logic] **GIVEN** an NPC with pending fights and one already applied, **WHEN** it dies mid-season, **THEN** its pending fights drop, the applied result stands, and it is Gone with its last rating kept, absent from rankings.
- **AC-PR-44** [Logic] **GIVEN** budget 50 and a queue of panels, round-robin and matchmaking work, **WHEN** the season ends, **THEN** unfinished panels head the next queue, unplayed matchmaking and round-robin fights drop, and at the year's end undealt Kết Đan pairs drop.
- **AC-PR-45** [Logic] **GIVEN** Rated and Provisional fighters and a changed data version, **WHEN** the game loads, **THEN** the members are recalibrated, every Rated fighter is Stale with its offset carried and every Provisional fighter stays Provisional; each panel then applies `offset_keep` once, in the AC-PR-24 order.
- **AC-PR-46** [Logic] **GIVEN** a Provisional NPC at 1490 in a world fight, **WHEN** it resolves, **THEN** P uses 1490 and no offset or n changes on either side.
- **AC-PR-47** [Logic] **GIVEN** a fighter (1800, n 0) beating a rated 1000 opponent, **WHEN** offsets update, **THEN** its offset moves +0.5 (E 0.990), and 1,000 such wins never exceed +200.

**Cross-system**

- **AC-PR-48** [Integration] **GIVEN** fighters with base, offset, state, n, panel data version and pending season work, **WHEN** the game saves and reloads, **THEN** every field matches and the next season's ratings equal those of a run that never saved.
- **AC-PR-49** [Integration] **GIVEN** an old save with no rating fields, **WHEN** it loads, **THEN** every living fighter is Provisional at R_prov.
- **AC-PR-50** [Integration] **GIVEN** `combat_rankings.json` `enabled` false and a save with stored ratings, **WHEN** a season runs, the sheet shows power and a world fight resolves, **THEN** the sheet shows chiến lực, the world fight uses the duel with 1 session draw, rating code runs 0 fights, and the stored ratings save back byte-identical.

**Performance and determinism**

- **AC-PR-51** [Performance] **GIVEN** a 5,000-NPC world at the default budget, **WHEN** a season batch runs, **THEN** at most 10,000 fights run, all off the main thread, no main-thread frame exceeds 33 ms, and the player's synchronous panel completes within 200 ms; **AND GIVEN** a new 5,000-NPC world on 8 workers, **THEN** the world-generation panels complete within 90 s.
- **AC-PR-53** [Logic] Rule 13, Formulas D. **GIVEN** a fighter with a Stale panel and a matchmaking fight in the same season, **WHEN** the batch applies, **THEN** the panel applies first (offset ×0.5, n halved), then the fight updates the halved offset with K read from the halved n, in every run and worker count.
- **AC-PR-52** [Logic] **GIVEN** seed X and season S, **WHEN** the batch runs twice with 1 worker and twice with 8 (once with forced random completion delays), **THEN** every fighter's base, offset, n and state are bit-identical across all four runs, and the session stream advances only by world-fight draws, 1 each.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Calibration: generated NPCs sit far from the typical fighter (median win share against it 0.00 at Luyện Khí, 0.90 at Trúc Cơ, 1.00 above; `design/research/fighter-compiler-questions.md`). Tune NPC generation, move "typical" toward the population, or both; measure with the first ratings | user + systems-designer | Before the flag is switched on |
| 2 | Does `realm_step` 400 (10:1 per realm, by definition) match fights? If typical fighters of adjacent realms beat each other more than 99 % of the time, the realm-beside panel members carry little information. Measure in the first data pass | systems-designer | Implementation |
| 3 | If a top-end fighter beats its realm's typical fighter more than 99 % of the time, Formulas C saturates at +800; calibrate it against the realm-up typical fighter instead | systems-designer | Implementation |
| 4 | The strongest-under-heaven list needs an in-world name (Hán-Việt first, as Way and sect names are) that is not a known novel's | writer | Content pass |
| 5 | Measure how many builds change a season. The default panel share fits about 7 % of NPCs; in a season that fills it, most of the Kết Đan round robin drops. If that is common, spread the round robin over two years, raise the budget or change the share | systems-designer | After the first measured seasons |
| 6 | Which world events read ranks (challenges for a top-10 place, sect recruitment of high-ranked rogues, rivalries) is for the Living World Tick and Sects to design | world-builder | With the Living World Tick GDD |
