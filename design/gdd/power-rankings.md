# Power Rankings

> **Status**: Approved 2026-11-14 (lean re-review of the ladder revision; the earlier reviews' blockers resolved). **Changed after approval, 2026-11-14 (user decision after the ADR-0003 threading spike):** rule 16 coarse-panels only Kết Đan and above and the player's starting place at load, capped by `worldgen_fight_budget`; the rest start Provisional; Open Questions 7 (resolved) and 9 (new). Calibration (ADR-0003 step 3) raised `rung_div` to 32 by the saturation guard's own remedy and rescaled the rung-counted knobs (Tuning Knobs). A re-review of these changes is recommended. The ladder revision (user decisions from measured fights: ladder panel, measured anchors, coarse panels at load; `design/research/power-rankings-measurements.md`) was re-reviewed and approved the same day. Decisions by the user in-session; specialists consulted in lean mode: `systems-designer` (Formulas), `qa-lead` (Acceptance Criteria). CD-GDD-ALIGN skipped (lean mode)
> **Author**: the user + Claude
> **Last Updated**: 2026-11-14 (ladder revision: Formulas A-C, E-G, Season budget; rules 3, 4, 16; Player Fantasy; Vấn Đỉnh Bảng)
> **Last Verified**: 2026-11-14
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given), Pillar 5 (A World That Remembers)

## Summary

Every cultivator's fighting strength, measured by real fights: a ladder-panel rating when a build changes, refined
by same-realm matchmaking each season and by round robins at the top, shown as the one power number (replacing
chiến lực and `display_power`) and used to decide NPC-against-NPC fights in the living world.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Combat Defence & Healing, Realms, NPC Build Generation, Living World Tick`

## Overview

Power Rankings measures every cultivator's fighting strength by having them fight, and keeps the world's standings
from those fights. Each fighter (every NPC and the player) has one **power rating** on an Elo-style scale. It is
seeded by a **panel**: whenever a fighter's build changes, it fights a ladder of scaled copies of its realm's typical
fighter until it finds the rung it breaks even with, and the rating that best explains those results is its base. **Matchmaking** then
refines it: each season every NPC fights a few same-realm opponents of similar rating, and the results move a small
learned offset on top of the base, so a build that beats the panel but loses to real people (or the reverse) is
rated by what it actually does. The strongest tiers (Nguyên Anh and Hóa Thần) also play a **full round robin** each
season, so the very top of the world is ranked exactly. The rating converts to the one **power number** shown
everywhere (it replaces Combat Formulas K's `display_power` and today's chiến lực: an unbuilt character of a realm
shows about that realm's power base), and the world's NPC-against-NPC fights are decided from ratings instead of the
old duel roll. Players feel it directly: the number on a character sheet is earned in fights, a rival's rank moves
as they grow, and a strange build that works shows it. All fights run through the real fight engine
(ADR-0001), off the session's random stream (ADR-0002).

## Player Fantasy

**My name on the list, earned in fights.** Every cultivator in the world knows where they stand, and so does the
player. The power number on the character sheet is not a sum of stats: it is what this build has proved against real
fighters (Pillar 3, Power Is Built, Not Given). A strange build that should not work, but does, climbs; a build that
looks strong on paper and loses, falls.

**The world keeps score** (Pillar 5). A rival's rank moves as they grow; a sect elder sits at 3rd of 27 Nguyên Anh; a
name the player once beat is now above them. The strongest under heaven are a short list everyone can read, the
**Vấn Đỉnh Bảng** (the Summit-Asking List), and the player's own name can join it (Pillar 1, Your Dao, Your Name).

**What the player should feel:** pride when the number moves after something they did (a breakthrough, a new piece,
a won fight); curiosity about who is above them and why; never confusion about why it moved.

## Detailed Design

### Core Rules

1. **Who is rated.** Every living character the fight compiler can compile (Combat rule 2): every NPC, the player and
   spirit beasts. Beasts are rated (their power number is shown and read by their owners' power shares),
   panel-rated at their own realm, but never listed in a ranking and never matched.
2. **One rating per fighter.** A fighter's **rating** is `base + offset` on an Elo-style scale (Formulas A). `base`
   comes from the ladder panel (rule 4); `offset` is learned from fights against real opponents (rules 6-8).
3. **Anchors and ladders.** Each realm's typical reference fighter (Combat Formulas B, `combat_reference_fighters.json`)
   has a fixed rating `A_r` (Formulas A), so a realm's typical fighter rates the same in every world and every season.
   The anchors above Luyện Khí, the ladder rungs' ratings and `health_elo` are measured once per data version by the
   export tool (Formulas C) and stored with the data; a game never calibrates.
4. **The panel.** A fighter of realm r is panel-rated on realm r's **ladder**: copies of the realm's typical
   fighter scaled from ×1/256 to ×256 in strength, each with a calibrated rating. It searches the ladder for the rung
   it breaks even with, a few fights a rung on either side of the coin order (a warm search from its current rating
   after a build change at its own realm, a cold one from the realm's typical rung otherwise), and its `base` is the
   rating that best explains those results against the rungs' known ratings (Formulas B). A panel runs when the fighter is created and again
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
9. **Rankings.** A realm's ranking lists its rated NPCs and the player, ordered by rating. The top list,
   the **Vấn Đỉnh Bảng** (the Summit-Asking List, "the strongest under heaven"), is the round-robin realms' ranking. Provisional fighters are listed after the
   Rated and Stale ones, marked as provisional. Ties in rating break by more rated fights, then by age (older first), then by id.
10. **The power number.** A fighter's rating converts to the one **power number** the game shows and stores
    (Formulas E). It replaces chiến lực and Combat Formulas K's `display_power` wherever one number is shown or
    stored: character sheets, NPC records, beast power shares, and members ranked in a mass clash (the stored value is the
    rating; the number is derived from it on read, Formulas E).
11. **World fights.** An NPC-against-NPC fight in the Living World Tick (duel, feud, ambush) is decided by one roll
    from the two ratings (Formulas F), one draw from the session stream as the duel was. No fight runs. Each side's
    rating for the roll is lowered by its injury (Formulas F, `v`); the stored rating is not touched. Wars and
    great battles keep Combat's `rating_clash` (Combat Formulas K), with members ranked by power number.
12. **The player's fights.** An event fight the player takes runs the full fight (Combat; ADR-0001 step 4) and, when
    the opponent is rated, moves both offsets (rule 6). The event card's odds stay the fight engine's trial fights
    (ADR-0001 step 4), which read the actual matchup rather than the two ratings.
13. **Determinism and the session stream.** Every panel, matchmaking and round-robin fight is seeded from a keyed
    stream (ADR-0002 decision 4, ADR-0003 decision 4); none draws from the session stream. A **pair fight**
    (matchmaking, round robin, the player's event fights) is keyed on the game seed, the season, the two fighters' ids
    (sorted) and the fight's index among that pair's fights in the season. A **panel fight** has a rung, not a second
    fighter, so it is keyed on the game seed, the season, the fighter's id, the ladder's realm, the rung k and the
    fight's index among that fighter's panel fights against that rung in the season, counted across every panel the
    fighter runs that season (a coarse then a full panel, or a second build's panel). World-generation panels use
    season 0. So no two fights of a season share a seed. Pairing reads the ratings at the start of the season; the fights do not read ratings. A season's results
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
16. **World generation.** When a new game is created, the player's full panel and **coarse** panels (Formulas B: 2
    fights a probe, stopped at a 4-rung bracket) run while the game loads, outside any season budget, for: every
    generated NPC of Kết Đan and above, then the NPCs at the player's starting place, in that order (higher realm
    first, then by id), until `worldgen_fight_budget` fights have run (user decision 2026-11-14, after the
    threading spike). Those NPCs start **Stale** with their coarse base; every other generated NPC starts
    **Provisional** (rule 15). The strongest of the world and the player's neighbours are ordered from the first turn,
    and the season batch refines everyone else by rule 14's order.

### States and Transitions

The rating state of one fighter:

| State | Meaning | Enters from | Leaves to |
|---|---|---|---|
| Provisional | Rated by Formulas G only; shown marked | Created at world generation outside rule 16's load set; created during play; Rated or Stale (it breaks through to a new realm); loaded from an old save (Edge Cases) | Rated (its first panel at its realm runs), Gone (it dies) |
| Rated | `base` from a panel of its current build | Provisional, Stale (a panel runs) | Stale (its build changes, or a new data version), Provisional (a breakthrough), Gone (it dies) |
| Stale | Its build changed, or its base is a world-generation coarse panel; keeps its rating until the full panel | Rated (a build change of rule 5, or a new data version); created at world generation (rule 16) | Rated (the panel runs), Provisional (a breakthrough), Gone (it dies) |
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
`systems-designer` proposed the first formulas (lean review). **Revised 2026-11-14 (user) from measured fights**
(`design/research/power-rankings-measurements.md`): fights are sharp (×1.2 strength ≈ 250 Elo, ×2 always wins) and a
realm is about ×29 in typical-health terms, about 4,400 Elo. So ratings are true Elo with **measured** anchors, and a
panel searches a **ladder** of scaled typical fighters instead of fighting 3–4 fixed members. Values marked
*illustrative* are replaced by the calibration tool's measured values (Formulas C).

### A. Rating scale and anchors

The rating_scale formula is defined as:

`E(R_a, R_b) = 1 / (1 + 10^((R_b − R_a) / 400))` ; `A_0 = 1000` ; `A_r` (r ≥ 1) measured (Formulas C)

Ratings are standard Elo: 400 points are 10:1 odds. `A_r` is the rating of realm r's typical reference fighter
(Combat Formulas B), measured once per data version by searching realm r−1's ladder (Formulas C) and stored with the
data, so a realm's typical fighter rates the same in every world and every season. `realm_step_r = A_r − A_{r−1}`.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| r | int | 0–4 | Realms | Realm index |
| A_0 | int | 1000 | data file | Rating of Luyện Khí's typical fighter (the scale's origin) |
| A_r | float | measured; *illustrative* 1000 / 5400 / 9800 / 14200 / 18300 | calibration (Formulas C) | Rating of realm r's typical fighter |
| realm_step_r | float | about 4,400 (2026-11-14 data) | calculated | Gap between adjacent anchors; typical r+1 is about ×29 typical r in health terms |
| R_a, R_b | float | about −7,000 to 26,000 | calculated | The two fighters' ratings, `base + offset` |
| E | float | (0, 1) | calculated | a's expected score against b |

**Output Range:** E is strictly between 0 and 1, so it needs no clamp. Across a realm step E is above 0.9999: a lower
realm's typical fighter never beats a higher one's, as measured.
**Example:** R_a 1450 against R_b 1400: E = 1 / (1 + 10^(−0.125)) = **0.571**.

### B. Panel: the ladder search

**The ladder.** Realm r's ladder has rungs `k = −k_max … +k_max`. Rung k is realm r's typical fighter with its
offence and both pools multiplied by `2^(k / (2 · rung_div))`, so it is `f_k = 2^(k / rung_div)` times as strong
(damage × health). At `rung_div` 4 and `k_max` 32 the ladder runs from ×1/256 to ×256, about 240 Elo a rung (×1.19).
Each rung's rating `L_{r,k}` is calibrated (Formulas C); `L_{r,0} = A_r`.

**A probe** is `probe_fights` fights against one rung, half on each side of the coin order; the fighter wins the
probe when its score is above half.

**The search.** Start at rung `k_0`: the rung whose rating is nearest the fighter's current rating (a **warm**
search, for a Stale fighter at its own realm) or rung 0 (a **cold** search, for a new fighter or after a
breakthrough). Step `s_0` is `warm_step` (2) or `cold_step` (8). Probe `k_0`; move by the step in the direction of
the result (up after a win, down after a loss), doubling the step each move, until the result flips or the move
reaches ±`k_max` (the last probe is then at ±`k_max`). Then bisect the bracket between the last win and the last
loss until it is 1 rung wide (`coarse_bracket` rungs for a **coarse** search, which uses `coarse_probe_fights`).

**The base.** `base` is R* solving
`Σ_probes n_p · E(R*, L_{r,k_p}) + prior_games · E(R*, L_{r,k_0}) = Σ_probes S_p + prior_games · 0.5`
by bisection on `[L_{r,−k_max} − 2000, L_{r,k_max} + 2000]` (60 steps; the left side rises strictly in R, so the
root is unique and the result deterministic). The prior (one pseudo-game drawn against the start rung) gives a finite
answer when a fighter wins or loses every probe, off the end of the ladder.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| k_p, n_p, S_p | int, int, float | rung ±k_max; 2 or 4; 0–n_p | the search | Each probe's rung, fights and score (1 a win, 0.5 a draw or the time limit, 0 a loss) |
| L_{r,k} | float | A_r ± about 7,700 | Formulas C | Calibrated rung ratings |
| rung_div | int | 4 | data file | Rungs per doubling of strength |
| k_max | int | 32 | data file | Rungs either side of typical (×1/256 to ×256 at rung_div 4) |
| probe_fights / coarse_probe_fights | int | 4 / 2 | data file | Fights a probe |
| warm_step / cold_step | int | 2 / 8 | data file | First step of a warm or cold search |
| coarse_bracket | int | 4 | data file | Bracket width (rungs) at which a coarse search stops |
| prior_games | float | 1 | data file | Pseudo-games drawn against the start rung |
| base | float | about L_{r,−k_max} − 400 to L_{r,k_max} + 400 | calculated | The panel base rating |

**Output Range:** inside the ladder the base lands within about one rung of the break-even rung. Off the end it lands
a few hundred points beyond the end rung (about +340 for a clean sweep, test ladder). A warm search takes about 3–4
probes (12–16 fights), a cold one about 5–8 (20–32), a coarse one about 3–5 (6–10).
**Example** (*illustrative* Trúc Cơ ladder, A_1 5400, 240 a rung): a cold search scores 4/4 at rung 0, 0/4 at rung 8,
3/4 at rung 4, 1/4 at rung 6 and 2/4 at rung 5: bracket [4, 5], 20 fights, **base ≈ 6,559** (rung 4.83), power 1,830.

### C. Ladder calibration

The ladder_calibration formula is defined as:

`gap_{r,k} = 400 · log10(s' / (1 − s'))`, with `s' = (S + prior_games · 0.5) / (N + prior_games)` for rung k+1 against
rung k; `L_{r,k+1} = L_{r,k} + gap_{r,k}` and `L_{r,k−1} = L_{r,k} − gap_{r,k−1}` from `L_{r,0} = A_r`

`A_{r+1}` is the base of a Formulas B search of realm r+1's typical fighter on realm r's ladder at
`calibration_probe_fights` a probe. `health_elo = gap_h / log10(1.2)`, where gap_h is the gap (same closed form) of
realm r's typical fighter with health ×1.2 against the unscaled one, averaged over the realms. The export tool runs
all of it once per data version and stores the results with the data (Core Rules rule 3; ADR-0003 decision 6).
**Saturation guard:** when any adjacent-rung share s' is above 0.99 (or below 0.01), the rungs are too far apart to
measure; calibration fails and names the realm and rungs, and `rung_div` is raised before the data ships.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| N | int | 400 | data file (`calibration_fights`) | Fights for one rung gap, half on each side |
| S | float | 0–N | the fights | The upper rung's score |
| prior_games | float | 1 | data file | The same prior as Formulas B |
| s' | float | (0, 1) | calculated | The prior-shrunk share |
| gap_{r,k} | float | about 200–280 | calculated | Elo between adjacent rungs |
| calibration_probe_fights | int | 40 | data file | Fights a probe when measuring an anchor |
| health_elo | float | about 3,000 | calculated | Elo per tenfold of health (Formulas F) |

**Measured 2026-11-14** (`combat_rankings.json`, `rung_div` 32, `k_max` 192): rung gaps near typical 110–144 Elo;
anchors 1,000 / 14,195 / 29,506 / 46,842 / 61,627 (realm steps 13,000–17,000 Elo, far above the illustrative 4,400:
fights are sharper than the health-only measurement suggested); `health_elo` 3,134. The ladder ends carry little
information (gaps as small as 3.5 Elo at realm 4's far end, where fights stall), well outside where NPCs sit. A
calibration run is about 770,000 `fight.py` fights, 36 minutes. The illustrative numbers in this section's and
Formulas A, B, E, G's examples keep the test ladder (240 a rung).
**In a generated world** (measured run 2026-11-14, `production/qa/evidence/combat-port/ratings-world-2026-11-14.md`):
the typical fighter is not the realm median. After 4 years, median NPC strength is ×0.65 / ×1.14 / ×2.65 / ×3.6 /
×5.3 typical by realm, so realm medians show power 68 / 1,100 / 23,100 / 306,000 / 5.1 M; realms never overlap.
**Kept as is (user decision 2026-11-14):** the anchors stay the typical fighters' ratings (Combat Formulas B, the
difficulty targets); revisit when the Kinh Mạch Đồ and designed builds change where NPCs sit.
**Output Range:** each gap positive and finite while the guard holds. 5 realms × 64 gaps × 400 fights ≈ 128,000
fights, about 40 s on `fight.py` (0.3 ms a reference fight) or about 220 s on 8 Godot workers (13.7 ms a fight,
Open Question 7).
**Example:** rung k+1 scores 300 wins and 20 draws in 400 against rung k: s' = 310.5 / 401 = 0.7743, so
gap = 400 · log10(310.5 / 90.5 = 3.431) = **214.2**.

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
| offset_cap | int | 200 | data file | Largest offset: under one rung (×1.2 strength), never enough to overturn a realm (about 4,400) |
| offset_keep | float | 0.5 | data file | Share of the offset and of n a new panel keeps |

**Output Range:** offset −200 to +200; one fight moves it at most 48.
**Example:** a (R 1450, n 4, K = 48 / 1.4 = 34.3) loses to b (R 1400, n 14, K = 48 / 2.4 = 20): E_a = 0.571, so
offset_a −19.6 and offset_b +11.4.

### E. Power number

The power_number formula is defined as:

`power = max(1, round_int(round_3sf(B_p[r*] · 10^((R − A_{r*}) / (A_{r*+1} − A_{r*})))))`, where r* is the largest r ≤ 3 with
`A_r ≤ R`, or 0 when R < A_0

The power number is log-linear between the anchors: a realm's typical fighter shows exactly that realm's power base
`B_p[r]`, and each realm's anchor gap is one tenfold of power, as the power bases are. Below `A_0` the Luyện Khí
segment's slope continues; above `A_4` the Nguyên Anh to Hóa Thần slope continues. The stored value is the rating;
the power number is computed on read and shown to 3 significant figures (whole numbers below 100: 59.25 shows as 59) with thousands separators.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| R | float | about −7,000 to 26,000 | Formulas B, D, G | The fighter's rating |
| B_p[r] | int | 100 / 1,000 / 10,000 / 100,000 / 1,000,000 | Character Stats (`power_base`) | Each realm's power base |
| A_r | float | Formulas A | calibration | The anchors |
| power | int | 1 upward | calculated | The shown power number |

**Output Range:** 1 (floor) upward. Typical fighters show 100 / 1,000 / 10,000 / 100,000 / 1,000,000.
**Example** (*illustrative* anchors): R 6,500 lies between A_1 5400 and A_2 9800: 1000 · 10^(1100 / 4400) = 1,778,
shown as **1,780**.

### F. World fight

The world_fight formula is defined as:

`R_roll = R + health_elo · log10(max(v, v_c))` for each side; `P(A) = clamp(E(R_roll_a, R_roll_b) + (eff_khi_van_A − eff_khi_van_B) · khi_van_per_point, p_min, p_max)`

A wins when one draw from the session stream is below P(A). World fights have no draws.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| R_a, R_b | float | Formulas A | Formulas B, D, G | The two ratings |
| eff_khi_van | float | as the duel | Character Stats | Effective khí vận of each side |
| v | float | 0.05–1 | Combat Formulas K (vitality fraction) | A side's current vitality as a share of full; 1 when uninjured |
| v_c | float | 0.4 | data file (`combat_rules.json` duel `injured_power_floor`) | Floor on v: at most −1,194 rating for the roll (3,000 · log10 0.4) |
| health_elo | float | about 3,000 | Formulas C | Elo per tenfold of health, measured |
| khi_van_per_point | float | 0.001 | data file (`combat_rules.json` duel) | Win chance per point of khí vận |
| p_min, p_max | float | 0.02, 0.98 | data file (`combat_rules.json` duel `min_win_chance`, `max_win_chance`) | Clamp: a Hóa Thần still loses to a Luyện Khí 2 % of the time |

**Output Range:** 0.02–0.98. Injury matters as it does in fights: at v 0.5 a fighter loses about 903 points for the
roll, so against an equal opponent it is at the 0.02 floor (measured: ×1.5 health wins 97 % of fights).
**Example:** R 1450 against 1400 with +10 khí vận, both uninjured: 0.571 + 0.010 = **0.581**. With A at v 0.9 and
no khí vận: R_roll_a = 1450 − 137.3 = 1312.7, so P(A) = **0.377**.

### G. Provisional rating

The provisional_rating formula is defined as:

`R_prov = L_r(stage_mult[stage]²)`: realm r's ladder read at strength `f = stage_mult²`, interpolated between rungs
(rung `k = rung_div · log2 f`)

A stage multiplies both damage and pools (1.00 / 1.15 / 1.30 / 1.45), so its fighter is about `stage_mult²` times
as strong as the realm's typical (stage-0) fighter: rungs 0 / 1.62 / 3.03 / 4.29 at `rung_div` 4.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| r, stage | int | 0–4, 0–3 | Realms | The fighter's realm and stage |
| stage_mult | float | 1.00–1.45 | Realms (`stage_multiplier`) | The stage multiplier |
| L_r(f) | float | Formulas C | calculated | Ladder rating at strength f, linear in k between rungs |
| R_prov | float | A_r to about A_r + 1,030 | calculated | The provisional rating (no offset) |

**Output Range:** `A_r` (stage 0) to about `A_r + 1,030` (stage 3, test ladder). A provisional fighter's rating is
`R_prov + offset` (its offset carried unchanged); the first panel replaces `R_prov` with `base` and then applies
`offset_keep`.
**Example** (*illustrative* Trúc Cơ ladder, A_1 5400, 240 a rung): stage 2 is rung 3.03: 5400 + 727 = **6,127**,
power 1,460.

### Season budget

| Value | Default | Note |
|---|---|---|
| match_fights | [1, 2, 2, 0, 0] | By realm; Nguyên Anh and Hóa Thần are covered by their round robin |
| match_window | 5 | Places either side in the realm's rating order |
| season_fight_budget | 10,000 | About 140 s of background compute at the 13.7 ms a fight measured in Godot (2026-11-14 probe, Open Question 7) |
| panel_budget_share | 0.5 | Largest share of the season budget panels may use (Core Rules rule 14); safe range 0.3–0.7 |

The population, from `world_generation.json` realm weights for a 5,000-cultivator world: about 3,945 Luyện Khí,
835 Trúc Cơ, 190 Kết Đan, 27 Nguyên Anh and 3 Hóa Thần. At 4 seasons a year: matchmaking (3,945 + 1,670 + 380) / 2 ≈
**3,000** fights; the Nguyên Anh and Hóa Thần round robin C(30, 2) = **435**; the Kết Đan yearly round robin
C(190, 2) / 4 ≈ **4,490** a season. That is about 7,925 fights of non-panel work.

**Panels.** Measured over 10 years of a generated world (2026-11-14), 2.3–6.4 % of NPCs change build a season
(mean 3.85 %, about 190), 95 % of them by a stage change and the rest by a breakthrough; the world tick gives NPCs no
new techniques or items yet. About 180 warm panels (16 fights) and 10 cold ones (32) are about 3,200 fights, inside
the 5,000-fight panel share. In a season that uses the whole panel share, the other 5,000 fights cover the top round
robin and matchmaking first, then about 1,565 of the season's 4,490 Kết Đan pairs; the rest drop (rule 14). In a
quieter season the unused panel share completes the season's Kết Đan slice. Because the slice is shuffled (rule 8), a
truncated season leaves a random, not id-ordered, share of pairs unplayed.

**World generation** (rule 16): coarse searches for the NPCs of Kết Đan and above (about 230, about 2,300 fights) and
then the NPCs at the player's starting place, capped at `worldgen_fight_budget` (8,000 fights): about **40 s** at the
measured rate (12.3 ms a fight single-threaded, about ×2.5 on threads, about 200 fights a second; ADR-0003 spike,
`production/qa/evidence/combat-port/rating-spike-2026-11-14.md`). A coarse search of every NPC (about 50,000
fights) would take about 4 minutes at that rate, which is why the load set is limited. The other NPCs start
Provisional and refine by panels in the background, higher realms first: about 80,000 fights. Build-change panels share the
same queue, and an NPC refined once can go Stale again, so the drain is not 16 seasons: if the 3,200 fights a season
of build-change demand were additive it would leave about 1,800 of the 5,000-fight share and take about 44 seasons
(11 years), with the Luyện Khí refinement last. Which it is, is Open Question 7's measurement.
**Measured 2026-11-14** (4 years of a 5,177-person world, release build, 16 cores): a full 10,000-fight season takes
31–47 s on threads; the panel share is full every season (about 170 panels, about 29 fights each) and the queue
shrinks by about 100 a season, so Trúc Cơ is refined by season 9 and Luyện Khí needs about 8–10 years more; about
half the planned pair fights drop each season, nearly all from the Kết Đan slice. **Accepted for now (user decision
2026-11-14):** the defaults stay; revisit with Open Question 9.

## Edge Cases

- **If a fighter breaks through to a new realm**: it becomes Provisional at the new realm (Formulas G), its offset
  carried unchanged until its panel against the new realm runs (which then applies `offset_keep` once), and is
  shown as provisional until then. Keeping the
  old rating would leave a new Trúc Cơ cultivator rated as a Luyện Khí one for a season.
- **If a fighter's build changes several times in one season**: it gets one panel, for the build it has when the
  panel runs.
- **If the player opens their power number while Stale**: the player's panel runs then (about 100 ms, outside the
  season budget), at most once per build.
- **If a fighter runs off the end of its ladder** (wins at rung +`k_max` or loses at −`k_max`): the prior
  (Formulas B) gives a finite rating a few hundred points beyond the end rung, and the panel logs the fighter's id.
  It is ranked correctly against everyone inside the ladder; two fighters both beyond the same end are ordered by
  their offsets. The 2026-11-14 probe found no generated NPC beyond ×64 of its realm's typical fighter.
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
- **If beasts are counted**: they add panels to the demand figures of Season budget (one per beast, a coarse panel of 6–10 fights at its
  realm at world generation, then a warm panel of 12–16 when its build changes) and are rated at world generation like NPCs; their count is data and small beside the NPC population.
- **If a fighter dies with fights pending**: its pending fights are dropped; results already applied stand. Its
  last rating stays on its record (Gone).
- **If a fighter has a panel and pair fights in the same season**: panels apply first, then pair fights (Core Rules rule 13), so the new `offset_keep` halving never discounts that season's fresh results.
- **If the season ends with rating work left**: unfinished panels carry to the next season; that season's unplayed
  matchmaking and round-robin fights are dropped (Core Rules rule 14). The Kết Đan round robin's undealt pairs are
  dropped at the year's end, not carried.
- **If the reference fighters or the combat data change** (a new data version): the shipped data carries new
  anchors and ladders (Formulas C), every Rated fighter becomes Stale with its offset carried (Provisional fighters stay Provisional), and the panels spread over the following
  seasons by the usual order (each applying `offset_keep` once).
- **If an old save has no ratings**: every living fighter loads as Provisional.
- **If a world fight pairs an injured fighter**: its roll rating drops by `health_elo·log10(max(v, v_c))` (Formulas F), at
  most about 1,194 points; its stored rating, offset and rank do not change, so an injury never moves a ranking.
- **If a world fight pairs a Provisional fighter**: it uses the provisional rating; no offset moves (offsets move only
  from fights that run).
- **If two fighters have the same rating**: rankings break the tie by more rated fights, then older, then id (Core
  Rules rule 9).
- **If Power Rankings is switched off** (its own flag, Dependencies): the power number shown is chiến lực, world
  fights use the duel, and no rating work runs; ratings already stored stay in the save untouched.
- **If the player picks weak opponents to raise their offset**: each win against a much weaker rated fighter moves
  the offset by almost nothing (E near 1), and the offset is capped at ±200, so farming cannot move the power number
  more than about ×1.11 (`10^(200/4400)`, inside a realm).

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
| `rung_div` | 32 | 24–64 | Rungs per doubling of strength (about 120 Elo a rung at 32, measured); raise if the saturation guard fires. *Raised from 4 on 2026-11-14 by the guard: at 4 adjacent rungs won 96–100 %, because a rung scales linh lực too and linh lực decides sustain fights* |
| `k_max` | 192 | 192–384 | Ladder reach `2^(k_max / rung_div)` either side: ×1/256 to ×256 at rung_div 32. Keep `k_max / rung_div ≥ 6` (×64, the widest NPC the 2026-11-14 probe found); AC-PR-56 checks it |
| `probe_fights` / `coarse_probe_fights` | 4 / 2 | 2–8 / 2–4 | Panel accuracy against compute |
| `warm_step` / `cold_step` | 16 / 64 | 8–32 / 32–128 | First step of a search; fewer probes when the guess is good (scaled with `rung_div`: the same strength steps as 2 / 8 at rung_div 4) |
| `coarse_bracket` | 32 | 16–64 | Where a world-generation coarse search stops; world-generation load time (scaled with `rung_div`) |
| `worldgen_fight_budget` | 8,000 | 2,000–20,000 | Coarse-panel fights at a new game's load (rule 16): about 40 s at 200 fights a second; higher orders more of the world at load and lengthens it |
| `prior_games` | 1 | 0.5–2 | Finite result off the ladder end; pull toward the start rung |
| `calibration_fights` / `calibration_probe_fights` | 400 / 40 | 200–800 / 20–80 | Rung-gap and anchor accuracy, once per data version |
| `health_elo` | measured (about 3,000) | not tuned | Injury on a world-fight roll; written by calibration (Formulas C) |
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

- **Rank changes are news, not effects.** A rise into or out of a realm's top 10, or into the Vấn Đỉnh Bảng
  (the top list), is a world-news line (Living World Tick's news) with the old and new rank. No VFX.
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
  (provisional, stale) and the realm rank ("12th of 835 Trúc Cơ").
- **Rankings screen** (debug terminal command first, `rankings [realm]`): a realm's ranking, the player's place
  highlighted, each row name, sect, stage, power number and rated-fight count; and the Vấn Đỉnh Bảng (the top list).
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
- **AC-PR-03** [Logic] Rule 3, Formulas A. **GIVEN** test calibration data (anchors 1000 / 5400 / 9800 / 14200 / 18300, 240 a rung) and two worlds with different seeds read in seasons 1 and 9, **WHEN** each realm's typical fighter's rating is read, **THEN** it is the stored anchor in every case.
- **AC-PR-04** [Logic] Rule 3. **GIVEN** anchors, ladders and `health_elo` stored for the data version, **WHEN** a game loads and runs a season, **THEN** calibration runs 0 fights and the stored values are used.
- **AC-PR-05** [Logic] Rule 4. **GIVEN** fighters at Luyện Khí, Trúc Cơ and Hóa Thần, **WHEN** their panels run, **THEN** every probe is a rung of the fighter's own realm's ladder, within ±32, and rung k's fighter is that realm's typical fighter with offence and both pools ×2^(k/8).
- **AC-PR-06** [Logic] Rule 4, Formulas B. **GIVEN** a scripted fighter that wins every probe at rung 4 or below and loses above, **WHEN** a cold panel runs, **THEN** it probes rungs 0, 8, 4, 6, 5 in that order, 4 fights each with 2 on each side of the coin order (20 fights, none counted in n), ending at bracket [4, 5]; **WHEN** a warm panel runs from rung 3, **THEN** it probes 3, 5, 4 (12 fights); **WHEN** a coarse panel runs cold, **THEN** it probes 0, 8, 4 at 2 fights each (6 fights).
- **AC-PR-07** [Logic] Rule 5 (parametrised over its causes other than a breakthrough, which is AC-PR-37). **GIVEN** a Rated fighter at R, **WHEN** any build change of rule 5 happens, **THEN** it is Stale and still rated R until a panel runs.
- **AC-PR-08** [Logic] Rule 5. **GIVEN** a Rated fighter, **WHEN** it ages a season, travels or gains khí vận, **THEN** it stays Rated and no panel is queued.
- **AC-PR-09** [Logic] Rule 6, Formulas D. **GIVEN** offset +195, n 0, E 0.5, **WHEN** it wins a rated fight, **THEN** its offset is +200.0 (not +219); the mirror gives −200.0.
- **AC-PR-10** [Logic] Rule 6. **GIVEN** offset +40.0 and n 15, **WHEN** a new panel replaces its base, **THEN** its offset is +20.0 and n is 7.
- **AC-PR-11** [Logic] Rule 7. **GIVEN** a seeded world with at least 20 NPCs in each realm, **WHEN** a season's matchmaking runs, **THEN** each NPC is in at most 1 / 2 / 2 / 0 / 0 matchmaking fights by realm, every pair is same-realm, and both sides' offsets update.
- **AC-PR-12** [Logic] Rule 7. **GIVEN** the same world, **WHEN** pairs form, **THEN** every pair is within 5 places in the start-of-season rating order, or within 10 when widened (AC-PR-36).
- **AC-PR-13** [Logic] Rule 7. **GIVEN** a Trúc Cơ player mid-ranking, **WHEN** 4 seasons of matchmaking run, **THEN** the player is in no pair and the player's offset and n are unchanged.
- **AC-PR-14** [Logic] Rule 8. **GIVEN** 28 rated Nguyên Anh and Hóa Thần NPCs, **WHEN** a season runs, **THEN** exactly 378 round-robin fights run, every pair once.
- **AC-PR-15** [Logic] Rule 8. **GIVEN** 200 Kết Đan NPCs unchanged for a year and an ample budget, **WHEN** its 4 seasons run, **THEN** 19,900 pairs run, each once, 4,975 a season; **AND GIVEN** a budget that truncates each season's slice to 35 %, **THEN** the played pairs follow the keyed shuffle (identical for the same seed) and over 20 seeds no id band (a tenth of the realm's NPCs in id order) plays fewer than 25 % or more than 45 % of its pairs.
- **AC-PR-16** [Logic] Rule 9. **GIVEN** NPCs all at 1500.0 (n 10, age 50, id 7), (n 10, age 80, id 9), (n 12, age 30, id 3) and a Provisional NPC at 1600, **WHEN** the ranking is built, **THEN** the order is id 3, id 9, id 7, then the Provisional NPC, marked.
- **AC-PR-17** [Logic] Rule 9. **GIVEN** a realm with a Gone NPC and the player, **WHEN** its ranking is built, **THEN** the player is listed, the Gone NPC is not, and the top list is exactly the Nguyên Anh and Hóa Thần ranking.
- **AC-PR-18** [Integration] Rule 10. **GIVEN** the flag on, the test anchors and a fighter at R 6,500, **WHEN** the character sheet, the NPC record, the owner's beast power share and a mass-clash member ranking read power, **THEN** all read 1,780 and none reads chiến lực.
- **AC-PR-19** [Logic] Rule 11. **GIVEN** NPCs at 1450 and 1400 with +10 khí vận for A, **WHEN** the world tick resolves their duel, **THEN** 0 fights run, the session stream advances exactly 1 draw, and a draw of 0.580 gives A, 0.582 gives B.
- **AC-PR-20** [Integration] Rule 11. **GIVEN** a sect war, **WHEN** it resolves, **THEN** it uses `rating_clash` with members ordered by power number.
- **AC-PR-21** [Integration] Rule 12. **GIVEN** the player (R 1450, n 4) against a rated NPC (R 1400, n 14), **WHEN** the player takes the event fight and loses, **THEN** a full fight ran, the player's offset moves −19.6 and the NPC's +11.4, and both n rise by 1.
- **AC-PR-22** [Integration] Rule 12. **GIVEN** an event card for a fixed matchup, **WHEN** the opponent's offset changes by +150 with builds unchanged, **THEN** the card's odds are unchanged (trial fights, not E).
- **AC-PR-23** [Logic] Rule 13. **GIVEN** game seed X, season S and fighters a and b, **WHEN** their fight is seeded with a and b in either order, **THEN** the seed and the result are identical; **AND GIVEN** a Trúc Cơ panel probe's 4 fights against one rung, and a Kết Đan pair that meets in matchmaking and its round robin in the same season, **THEN** every one of those fights has a distinct seed; **AND GIVEN** a fighter whose coarse panel and later full panel both probe rung 4 in one season (or a player whose panel runs for two builds in one season), **THEN** the fights against that rung carry indexes 0, 1, 2, … in run order and no two share a seed; a world-generation panel's seeds use season 0.
- **AC-PR-24** [Logic] Rule 14. **GIVEN** a queue with the player's Stale panel, a Stale Hóa Thần panel, a Provisional Luyện Khí panel, the Nguyên Anh and Hóa Thần round robin, matchmaking and Kết Đan round-robin pairs, **WHEN** the batch runs, **THEN** they run in exactly that order.
- **AC-PR-25** [Logic] Rule 14. **GIVEN** `season_fight_budget` 200 and `panel_budget_share` 0.5 in test data and more work than that, **WHEN** a season runs, **THEN** exactly 200 fights run (the player's on-open panel, AC-PR-39, excluded), of which at most 100 are panel fights; **AND GIVEN** only 40 panel fights queued, **THEN** the other 160 are round-robin and matchmaking fights.
- **AC-PR-26** [Logic] Rules 15, 16. **GIVEN** a new game's world generation (test world of 50 NPCs), **WHEN** loading finishes, **THEN** the player is Rated from a full panel, every generated NPC of Kết Đan and above, then those at the player's starting place, is Stale with a coarse base until `worldgen_fight_budget` (set to 60 in the test data) is spent, every other generated NPC is Provisional, the first season's budget count is 0, and the first season's queue holds their full panels in rule 14's order; **AND GIVEN** a Trúc Cơ stage-2 NPC created during play, **WHEN** its rating is read before its panel runs, **THEN** it is Provisional at 6,127 (test ladder).

**Formulas**

- **AC-PR-27** [Logic] A. **GIVEN** 1450 and 1400, **WHEN** E is computed, **THEN** E = 0.571 (±0.001), E(a,b) + E(b,a) = 1, a 400-point gap gives 0.909, and one realm step (about 4,400) gives above 0.9999.
- **AC-PR-28** [Logic] B. **GIVEN** the test Trúc Cơ ladder (A_1 5400, 240 a rung), start rung 0 and probes at rungs 0 / 8 / 4 / 6 / 5 scoring 4 / 0 / 3 / 1 / 2 of 4, **WHEN** the base is solved, **THEN** it is 6,559 ± 1, bit-identical across two runs.
- **AC-PR-29** [Logic] B. **GIVEN** the same ladder and a cold search that wins every probe (rungs 0, 8, 24, 32, each scoring 4 of 4), and its mirror that loses every probe (0, −8, −24, −32), **WHEN** solved, **THEN** the bases are 13,418 ± 1 (L_32 13,080 + 338) and −2,618 ± 1, both finite, and the fighter's id is logged.
- **AC-PR-30** [Logic] C. **GIVEN** rung k+1 scoring 300 wins and 20 draws in 400 against rung k, **WHEN** the gap is calibrated, **THEN** s' = 0.7743 and the gap is 214.2 ± 0.1; **AND GIVEN** a gap whose share is 398.5 of 400, **THEN** calibration fails and names the realm and the rungs.
- **AC-PR-31** [Logic] D. **GIVEN** a (1450, n 4) loses to b (1400, n 14), **WHEN** offsets update, **THEN** K_a = 34.3, K_b = 20.0, offset_a −19.6, offset_b +11.4.
- **AC-PR-32** [Logic] D. **GIVEN** n = 0 / 10 / 20 / 40, **WHEN** K is computed, **THEN** it is 48 / 24 / 16 / 16.
- **AC-PR-33** [Logic] E. **GIVEN** the test anchors and R = 6,500 / 1000 / 5400 / 9800 / 14200 / 18300 / 0 / 25,000 / −20,000, **WHEN** the power number is computed, **THEN** it is 1,780 / 100 / 1,000 / 10,000 / 100,000 / 1,000,000 / 59 / 43,100,000 / 1.
- **AC-PR-34** [Logic] F. **GIVEN** 1450 against 1400 with +10 khí vận, then 2600 against 1000, then 1000 against 2600, **WHEN** P(A) is computed, **THEN** it is 0.581 / 0.98 / 0.02.
- **AC-PR-34a** [Logic] F. **GIVEN** `health_elo` 3,000 and A (1450, v 0.9) against B (1400, v 1), no khí vận, **WHEN** P(A) is computed, **THEN** it is 0.377 (±0.001); with A at v 0.5 it is 0.02 (the floor); **AND GIVEN** v 0.05 and v 0.4 on one side, **THEN** both use v_c 0.4 (−1,194); stored rating, offset and rank are unchanged after the fight.
- **AC-PR-54** [Integration] B. **GIVEN** a generated 5,000-NPC world after world-generation coarse panels and one year of refinement, **WHEN** bases are read per realm, **THEN** in each realm with at least 20 NPCs the 10th-to-90th percentile spread of `base` is at least 1,000 points (the 2026-11-14 probe measured ×10 to ×23 in typical-health terms) and no 240-point bin holds more than 25 % of the realm's NPCs; the flag stays off until this passes.
- **AC-PR-56** [Logic] B, Tuning Knobs. **GIVEN** `combat_rankings.json` with `k_max / rung_div` below 6, **WHEN** the data loads, **THEN** it is refused with the knob names logged; **AND GIVEN** the default 32 / 4, **THEN** it loads and the ladder reaches ×256.
- **AC-PR-55** [Integration] B. **GIVEN** 50 sampled NPCs with a cold full panel, **WHEN** each takes a warm panel from its rating and, separately, a coarse one, **THEN** the warm base is within ×1.19 strength of the cold base (`rung_div / 4` rungs: 8 at 32) for at least 90 % and the coarse base within ×1.68 (`3 · rung_div / 4` rungs: 24 at 32) for at least 85 % (Open Question 8). *Rescaled 2026-11-14 (user decision) from the rung counts written at `rung_div` 4; coarse's bar lowered from 90 % because a coarse base only orders a new world until its full panel runs. Measured: warm 100 %, coarse 88 %.*
- **AC-PR-35** [Logic] G. **GIVEN** the test ladders and Trúc Cơ stage 2, Luyện Khí stage 0 and Hóa Thần stage 3, **WHEN** R_prov is computed, **THEN** it is 6,127 (power 1,460) / 1000 / 19,329.

**Edge Cases**

- **AC-PR-36** [Logic] **GIVEN** an odd count in a realm and a forced case with every neighbour within 5 used, **WHEN** pairing runs, **THEN** the window widens once to 10, an NPC still unpaired sits out, and no pair repeats in the season.
- **AC-PR-37** [Logic] **GIVEN** a Rated Luyện Khí stage-3 NPC with offset +40, **WHEN** it breaks through to Trúc Cơ stage 0, **THEN** it is Provisional at 5400 + 40 = 5,440 (test anchors), shown provisional; **WHEN** its Trúc Cơ panel then runs, it is a cold search, **THEN** its offset becomes +20.
- **AC-PR-38** [Logic] **GIVEN** 3 build changes in one season, **WHEN** the batch runs, **THEN** exactly 1 panel runs, compiled from the final build.
- **AC-PR-39** [Integration] **GIVEN** the player Stale, **WHEN** the power number is opened twice with no build change between, **THEN** 1 synchronous panel runs on the first open, none on the second, and the season budget count is unchanged.
- **AC-PR-40** [Logic] **GIVEN** a panel fight and a rated fight that each end at the time limit, **WHEN** scored, **THEN** each is 0.5 for both sides.
- **AC-PR-41** [Logic] **GIVEN** the compiler refuses fighter X, **WHEN** the batch runs, **THEN** it completes, X's state and rating are unchanged, the log names X's id, and X's panel is queued next season.
- **AC-PR-42** [Logic] **GIVEN** a realm with 1 rated NPC, **WHEN** a season runs, **THEN** that realm has 0 matchmaking and round-robin fights and the NPC's rating is unchanged.
- **AC-PR-43** [Logic] **GIVEN** an NPC with pending fights and one already applied, **WHEN** it dies mid-season, **THEN** its pending fights drop, the applied result stands, and it is Gone with its last rating kept, absent from rankings.
- **AC-PR-44** [Logic] **GIVEN** budget 50 and a queue of panels, round-robin and matchmaking work, **WHEN** the season ends, **THEN** unfinished panels head the next queue, unplayed matchmaking and round-robin fights drop, and at the year's end undealt Kết Đan pairs drop.
- **AC-PR-45** [Logic] **GIVEN** Rated and Provisional fighters and a changed data version, **WHEN** the game loads, **THEN** the new anchors and ladders are read (0 calibration fights in the game), every Rated fighter is Stale with its offset carried and every Provisional fighter stays Provisional; each panel then applies `offset_keep` once, in the AC-PR-24 order.
- **AC-PR-46** [Logic] **GIVEN** a Provisional NPC at 6,127 in a world fight, **WHEN** it resolves, **THEN** P uses 6,127 and no offset or n changes on either side.
- **AC-PR-47** [Logic] **GIVEN** a fighter (1800, n 0) beating a rated 1000 opponent, **WHEN** offsets update, **THEN** its offset moves +0.5 (E 0.990), and 1,000 such wins never exceed +200.

**Cross-system**

- **AC-PR-48** [Integration] **GIVEN** fighters with base, offset, state, n, panel data version and pending season work, **WHEN** the game saves and reloads, **THEN** every field matches and the next season's ratings equal those of a run that never saved.
- **AC-PR-49** [Integration] **GIVEN** an old save with no rating fields, **WHEN** it loads, **THEN** every living fighter is Provisional at R_prov.
- **AC-PR-50** [Integration] **GIVEN** `combat_rankings.json` `enabled` false and a save with stored ratings, **WHEN** a season runs, the sheet shows power and a world fight resolves, **THEN** the sheet shows chiến lực, the world fight uses the duel with 1 session draw, rating code runs 0 fights, and the stored ratings save back byte-identical.

**Performance and determinism**

- **AC-PR-51** [Performance] **GIVEN** a 5,000-NPC world at the default budget, **WHEN** a season batch runs, **THEN** at most 10,000 fights run, all off the main thread, no main-thread frame exceeds 33 ms, and the player's synchronous panel completes within 200 ms; **AND GIVEN** a new 5,000-NPC world on 8 workers, **THEN** the world-generation coarse panels complete within 120 s (Open Question 7).
- **AC-PR-53** [Logic] Rule 13, Formulas D. **GIVEN** a fighter with a Stale panel and a matchmaking fight in the same season, **WHEN** the batch applies, **THEN** the panel applies first (offset ×0.5, n halved), then the fight updates the halved offset with K read from the halved n, in every run and worker count.
- **AC-PR-52** [Logic] **GIVEN** seed X and season S, **WHEN** the batch runs twice with 1 worker and twice with 8 (once with forced random completion delays), **THEN** every fighter's base, offset, n and state are bit-identical across all four runs, and the session stream advances only by world-fight draws, 1 each.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Calibration: generated NPCs sit far from the typical fighter~~ **Resolved 2026-11-14 (user):** the ladder panel rates NPCs wherever they sit, so Power Rankings does not need NPCs near typical. The measured spread (`design/research/power-rankings-measurements.md`: Luyện Khí median ×0.26, Kết Đan median ×8.5 of typical) goes to the NPC substance and difficulty-target work as an input | user | Done |
| 2 | ~~Does `realm_step` 400 match fights?~~ **Resolved 2026-11-14 (user):** no; a realm is about 4,400 Elo (typical r+1 ≈ ×29 typical r). Anchors are measured (Formulas A, C) | systems-designer | Done |
| 3 | ~~Top-end member saturates~~ **Resolved 2026-11-14 (user):** confirmed (top-end beats even ×256 typical); the top-end member is gone, replaced by the ladder, with a saturation guard on rung gaps (Formulas C) | systems-designer | Done |
| 4 | ~~The strongest-under-heaven list needs an in-world name~~ **Resolved 2026-11-14 (user):** Vấn Đỉnh Bảng (問鼎榜, the Summit-Asking List), rule 9 | writer | Done |
| 5 | ~~How many builds change a season?~~ **Measured 2026-11-14:** 2.3–6.4 % (mean 3.85 %), 95 % stage changes; fits the panel share. **Re-measure** once the world tick gives NPCs techniques and items, which it does not yet | systems-designer | When NPC acquisition is built |
| 7 | ~~Fight cost~~ **Measured 2026-11-14 (ADR-0003 spike, release export):** a real NPC fight is 12.3 ms single-threaded; `WorkerThreadPool` gives only about ×2.5 on 16 cores (string, StringName and dictionary reference traffic serialises GDScript threads). Resolved by limiting rule 16's load set (`worldgen_fight_budget`) | systems-designer | Done |
| 9 | Thread scaling: an integer-keyed hot loop (modifier keys, statuses and hit contexts as integers and typed objects instead of string-keyed dictionaries) would speed fights single-threaded and on threads. Revisit once rankings run end to end, if measured season or load times call for it | lead-programmer | After the first playable rankings |
| 8 | ~~Is a warm search as accurate as a cold one, and a coarse one good enough to order a new world?~~ **Resolved 2026-11-14 (user):** measured on 50 NPCs, warm within ×1.19 of cold 100 %, coarse within ×1.68 88 %; AC-PR-55 rescaled to strength, coarse at 85 %; no knob change | systems-designer | Done |
| 6 | Which world events read ranks (challenges for a top-10 place, sect recruitment of high-ranked rogues, rivalries) is for the Living World Tick and Sects to design | world-builder | With the Living World Tick GDD |
