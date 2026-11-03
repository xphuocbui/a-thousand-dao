# Cross-GDD Review Report

Date: 2026-11-03
GDDs reviewed: 2 of 2 present (`canh-gioi.md`, `kinh-mach-do.md`)
Not read: none. `canh-gioi.md` was read in full; `kinh-mach-do.md` (141 KB) was read by section
(Player Fantasy, Interactions, Formulas A and E2, Dependencies, Tuning Knobs) plus targeted greps of
the capability catalogue and Acceptance Criteria.
Focus: full. Phases 2, 3 and 4 were run inline in the main session, not as parallel
`game-designer` subagents (the skill's default); this is disclosed here so the report is not read
as a subagent review.
Pillars: `game-concept.md` (5 pillars, 6 anti-pillars); `game-pillars.md` does not exist.
Coverage caveat: both GDDs are in the Progression layer. Checks against the other ~36 systems
cannot run until their GDDs exist.

## Consistency Issues

### Blocking
None.

### Warnings
1. **#23 / #22 are broader in the Meridian Map than in Realms.** `kinh-mach-do.md` line 340 says
   #23 triggers "after a failed breakthrough" and E2's attempt model does not separate pill from
   bare attempts. `canh-gioi.md` rule 18, AC-CG-49 and AC-CG-48 limit #23 and #22 to pill
   attempts. Fix: add "pill attempt" to catalogue rows #22/#23 and to E2.
2. **The tree's 8 pp cap has no parameter key in Realms.** The Meridian Map owns
   `tree_breakthrough_cap` (registry `tree_breakthrough_chance_cap`). Realms rule 8 hard-codes
   "capped at 8 pp" and AC-CG-25 clamps the sheet value again; neither Parameter keys nor Tuning
   Knobs list it. Risk: if the sheet's `breakthrough_chance` carries non-tree sources, Realms
   clamps items and events too.
3. **The event contract exists on one side only.** Realms rule 4, Interactions and AC-CG-51
   define `level_gained`, `stage_reached` and `breakthrough_succeeded` events. The Meridian Map
   defines `points_total(L)` as a pure function of the highest level reached and never mentions
   them. Results agree; nothing consumes the events.
4. **Key names drift.** `great_breakthrough_bonus` (Realms, registry) vs `breakthrough_bonus`
   (Meridian Tuning Knobs line 1522); "α shares" in Meridian Dependencies line 1446 vs
   `pct_trung` / `pct_hau` / `pct_dai`; the 0.95 ceiling appears as `q_max` (Meridian),
   `breakthrough.chance_max` and `guard.s_max` (Realms).
5. **Stale wording.** `kinh-mach-do.md` line 395, "points per stage and per breakthrough"
   (open since the first Realms review).

Verified consistent: reciprocal dependencies; hosts and descriptions of #5, #9, #22 and #23;
`burn_cost` 10 / 10 / 25 / 50 and the 5 % rule; point totals (86 at level 60, 51 at level 39,
566 at level 300); realm bands and t/h stage starts; the 15 / 25 / 35 shares and the 90 placeholder.

## Game Design Issues

### Blocking
None.

### Warnings
1. **The 0.30 / 0.70 targets are ambiguous about the tree and the capabilities.** Realms' tables
   assume a tree contribution of 0.02 (E = 0.0625) while the cap allows 0.08; a tree-maximising
   life gains about 0.06 on q (estimated +0.04 baseline S at CF→NS, +0.04 to +0.05 for the edge
   arm). The Meridian Map E2 states an intended edge ceiling of 0.80 with capabilities, while
   AC-CG-31 holds the edge arm to 0.65–0.75. Neither GDD says what the bot holds. Fix: state the
   bot policy in AC-CG-30/31, or widen the edge window.
2. **Realms has no Player Fantasy section.** Advisory at `standard`.

Checked, no issue: a single progression driver (levels) with the tree as the build layer; pillar
alignment and anti-pillars; source/sink balance of tu vi, points and pills; years per realm
against the half-lifespan ceiling.

## Cross-System Scenario Issues
Scenarios walked: 4 — several levels and a stage boundary in one season; a great breakthrough
success; #23 chained after a failed pill attempt; stage loss and re-climb.

### Blockers
None.

### Warnings
- **#23 chain** (Realms + Meridian Map + Character Stats): two failures in one season add +30
  heart demon and two qi-deviation rolls. Neither GDD states that a deviation-hit survivor at
  5 % vitality may still burn life and roll. Realms allows it by omission.

### Info
- Multi-level season: points are a pure function of the highest level, so no double pay.
- Great breakthrough: bonus minus the 35 % advance matches Realms rule 9.
- Stage loss: re-climbing pays nothing twice.
- #22 needs under 5 years left but an attempt needs a full bar; a slow root may never use it.

## GDDs Flagged for Revision
| GDD | Reason | Type | Priority |
|---|---|---|---|
| `kinh-mach-do.md` | #22/#23 text predates the pill/bare split; stale line 395; key names and "α shares" | Consistency | Warning |
| `canh-gioi.md` | The 8 pp cap and three duplicate ceilings; event contract; target-policy ambiguity; no Player Fantasy | Consistency / Design | Warning |

## Verdict: CONCERNS
Nothing blocks architecture. Eight warnings are worth resolving, chiefly the tree-versus-target
ambiguity and the one-sided event contract.

## Resolution (2026-11-04)
All 5 consistency warnings, game-design warning 1 and the #23 chain scenario are resolved in both GDDs (see `reviews/canh-gioi-review-log.md`, Cleanup 2026-11-04). Game-design warning 2 (no Player Fantasy in Realms) is left open: it is advisory at the standard tier.
