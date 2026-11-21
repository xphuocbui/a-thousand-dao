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

(filled in as the build meets them)

## Progress

(filled in per phase)
