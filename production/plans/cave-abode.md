# Plan: building Cave Abode & Home Works (Động Phủ, #47)

Started 2026-11-21 evening at the user's request ("please implement also the cave abode system"). GDD
`design/gdd/cave-abode.md`, approved by the review loop (ed4d61b0; the index says Approved, the GDD header still says
"In Review": reported, not edited), read at blob `5e99d243`.

## The user's decisions for this build (2026-11-21)

1. **A starting home with no residence** (an origin's home town) counts as a **free grade-1 residence** of that town:
   2 slots, works up to level 3, the residence's furnishing, no rent, until the player opens an abode or rents better.
2. **Tụ Linh Trận joins layer 1's upkept density** (Travel & Map rule 32; AC-CA-08): it no longer adds through the
   stat sheet's `density_bonus`, and it shares the `c1u` cap (0.75; +0.30 where Capability #15 applies). It is the only
   upkept density work in layer 1 today, so its level 5 (0.75) is not clamped.

## Scope (from the GDD)

- No new works: the catalogue beyond the seven known works is the user's (Open Question 2); no field work (Spirit
  Herbs & Fields #14 has no GDD). Every existing work takes 1 slot.
- One home accessor (kind, grade, slots, ceiling) and one effective-level function (dormancy, min(level, ceiling,
  skill cap)), read by density, match, upkeep, Formations.add_mods and the stat block.
- The home record lives on the place (`place.abode`), never on the people record (`sync_player` rewrites it).
- Money: grade raises, grade upkeep and claims are `burn_abode` (cause `abode`); the opening fee keeps its booking;
  standing arrays stay `burn_formation`.

## Phases (one commit each)

1. Formulas and data (F1-F5 as pure functions; `assets/data/cave_abode.json`); no observable change.
2. Player rules: the home accessor, slots and the ceiling on MapWorks and Formations builds, Tụ Linh into layer 1,
   raising the grade, grade upkeep and falls, dormancy, the stat block; the starting home as a grade-1 residence;
   the bot and the Advisor taught to raise the grade; ape7 on ape6's seeds (reported, not retuned).
3. Leaving, claiming, a dead owner's abode a Ruin (AC-CA-01, 12, 13, 17).
4. NPC abodes: grade, upkeep and raises from purses, a keyed roll, booked as one `burn_abode` aggregate; NPC ruin
   places deferred (one per dead hermit would grow the places table without bound).

## Decisions for the user

1. **The GDD header says In Review, the systems index says Approved.** Which is right (the other session owns both).
2. **Old saves.** A loaded save's self-built abode gets a grade-1 record and any other home becomes the free
   grade-1 residence; works and arrays above its limits count at the ceiling or go dormant (Tụ Linh 5 counts at 3).
   Alternative: grandfather an old save's abode at the grade its works need.
3. **Dormancy picks the latest built** (rule 9's default); the player cannot yet choose which work sleeps.
4. **NPC Ruins are not placed.** A dead hermit's abode is not made a claimable place (it would grow the places
   table without bound); the player's own abode does become a Ruin on death.
5. **Tụ Linh's power scaling.** `formation_power_pct` still multiplies Tụ Linh's density before the layer-1 cap
   (c1u 0.75, +0.3 with Capability #15), so power past the cap is wasted. Intended, or should power raise the cap?
6. **AC-CA-21 (screenshot of the abode block)** waits for Game UI (#37); the terminal `abode` command prints it.
7. **Fields (#14)** are not built, so the field-slot rules have nothing to hold yet.

## Progress

- Phase 1 (9cdb370a): F1-F5 and data.
- Phase 2: `CaveAbode` home record (home_rec, eff_level, reconcile, can_raise, raise, season, lines); MapWorks
  density, match, upkeep and build read it; Tụ Linh moved from `density_bonus` to layer-1 `home_array_density`
  (each layer-1 cap separately, clamp lines printed); Formations.can_build checks slots and the ceiling, add_mods
  counts dormancy, the ceiling and the skill cap; the starting home is a free grade-1 residence; residences keep
  their order and dormancy when their grade changes; terminal `abode`, `abode raise`; the bot raises a full home and
  the Advisor suggests it. Tests: cave_abode_home_test.gd (AC-CA-02/03/04/06/07/08/10/11/19).
- Phase 3: leave (an abode Left at its grade, a residence returned, arrays left behind fade on the abode clock,
  works stay and stop counting), claim (F4 fee as burn_abode, grade_after, works pass), Ruin on the player's death;
  terminal `abode claim`. Tests: cave_abode_leave_test.gd (AC-CA-01/12/13/17).
- Phase 4: `CaveAbode.npc_season` from WorldTicker after the sect politics step: loose cultivators' grade, raise
  and upkeep from their own purses, the keyed roll, one `burn_many(..., "abode")`. Tests: cave_abode_npc_test.gd
  (AC-CA-14).
