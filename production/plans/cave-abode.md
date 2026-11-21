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

Answered by the user 2026-11-21 (one by one):

1. **GDD status:** set to Approved (round 5, no blockers) to match the index.
2. **Old saves:** grandfathered. An old abode loads at the lowest grade that holds all its works (`CaveAbode.grade_to_hold`, up to 5 and the realm's top grade); residences keep their grade, the starting room is grade 1.
3. **Dormancy choice:** `abode sleep <work> [<dormant work>]`, a swap allowed only while a work is dormant (`CaveAbode.sleep`); the default stays the latest built.
4. **NPC Ruins:** rare and capped. A dead loose cultivator at grade 3+ (`ruin_min_grade`) leaves a Ruin place within 6 tiles (`ruin_search_radius`); at most 40 (`ruin_cap`), and the oldest is reused (`CaveAbode.npc_ruins`, world record `w_abode_npcs`). GDD Edge Cases bullet added.
5. **Tụ Linh power:** formation power lifts the cap. Travel & Map Formula B now has `c1u_eff = (c1u + 0.30 with Capability #15) × (1 + formation_power_pct / 100)`, and Cave Abode's loop check is reworded (GDD edits approved).
6. **Lost lease:** keep the free grade-1 room; GDD Edge Cases bullet added.
7. **Open ACs stay open and tracked here:**

| AC | Waits on | Pick up when |
|---|---|---|
| AC-CA-05 (a field in a slot bills upkeep, stops when dormant) | Spirit Fields #14 as home works | fields are built as layer-1 works |
| AC-CA-18 (a dormant Tụ Linh fails `seat_density` 1.5) | player-founded sects (Sects rule 29) | sect founding is built |
| AC-CA-21 (the abode screen screenshot) | Game UI #37 | the abode screen is built; the terminal `abode` block stands in |

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
- Review fixes (after an outside read): a sect member starting at the seat is housed by the sect, not a starting room
  (an older save's starting room at the seat becomes the sect's); dormant arrays owe no Formations upkeep and never
  lapse, and an array over the ceiling is billed at it (Formations rule 14); a former owner may reclaim their own
  Left abode (rule 11, "anyone"); a lost lease keeps a grade-1 room (decision 8); the bot's ceiling check uses each
  array's own maximum; the stat block shows each work's gain, the ceiling and the clamp lines (AC-CA-15); a debug
  `debug material <id> [n]`. Tests: cave_abode_session_test.gd (the whole flow through GameSession with a save,
  the sect seat, the lost lease, AC-CA-16's exact ledger entries, the NPC aggregate in real books). Evidence:
  production/qa/evidence/cave-abode/.
- Census with NPC abodes (0bf23209, which also carries Relationships and Formations; year 1600, 400 years):
  seed 11 3,852 / 867 / 232 / 44 / 5 (post-fix baseline 3,911 / 840 / 208 / 36 / 5); seed 23 3,861 / 892 / 214 /
  30 / 3 (baseline 3,920 / 803 / 232 / 38 / 7). Moves both ways by seed: no clear effect of the burn_abode
  aggregate on the headcount. Not retuned.
- ape7 (144 lives, seeds 1001-1048, 0bf23209, which also carries Relationships and Formations since ape6's
  7fd9a354): 66 / 54 / 21 / 22 % against ape6's 68 / 51 / 25 / 10 and targets 70 / 71 / 33 / 23. Within noise at
  every gate (Hóa Thần: 9 lives). A 12-life check with the home now in autoplay's row: 7 lives buy a grade-3 town
  residence (3 of 4 slots; its ceiling 5 is every array's maximum), 4 sect lives are housed at grades 2-5, 1 poor life
  stays in the grade-1 room. The bot never opens a cave abode of its own, so ape7 does not exercise abode raises.
