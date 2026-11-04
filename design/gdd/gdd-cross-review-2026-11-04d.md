# Cross-GDD Review Report (fourth pass)

Date: 2026-11-04 (fourth review today; re-run after the uncommitted fix pass for `gdd-cross-review-2026-11-04c.md`; supersedes it for current status)
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none wholly. Partial-section coverage is listed under Coverage.
Focus: full (consistency, design theory and scenarios), scoped to what changed since the prior review
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)
Pillars: `game-concept.md` (5 pillars, 6 anti-pillars); `game-pillars.md` does not exist.
Entity registry: present (1,123 lines); its lifespan and ceiling entries were checked.

**Method disclosure.** `review-scope.sh` reports CHANGED = canh-gioi, character-stats and cong-phap, and DEPS pulls in linh-can and kinh-mach-do, so all five are in scope. The change since the 04c review is small: about 120 lines, almost all in canh-gioi rule 14 and its ACs. The three prior passes already ran full design-holism passes on the unchanged text. This pass therefore ran inline, with no sub-agents. That deviates from the skill's parallel-agent contract.

What this pass did:
- It verified every changed line against the other four GDDs and the registry.
- It walked the new rules through the two lifespan scenarios.
- It re-checked each carried warning by grep against the current text.

Carried design-theory findings are restated with their current status. They were not re-derived.

---

## Status of the prior review's blockers

| ID | Status | Evidence |
|---|---|---|
| B1: the lifespan cap omits the ceiling | FIXED | canh-gioi rule 14 (183–187) reads CS's ceilinged bonus; CS rule 13 (172–174) states the composed formula; AC-CS-52 adds a clamped case ((200 + 30) × 1.10 = 253, checked); AC-CG-61 (QR 18 / FE 30 / 247.5, checked); registry `bonus_ceilings` agrees |
| NG4: a free slot change kills | FIXED for player-made changes | canh-gioi rule 14 bullet (warn and confirm), the Dead row in States, an Edge Case, AC-CG-62 and AC-CG-63; cong-phap rule 12 points to it. The numbers check out (QR 120 + 15 = 135 → 120 at age 130). The residual for involuntary loss is NG8 |

## Status of the prior review's warnings and info

| ID | Status | Evidence |
|---|---|---|
| W1 stale `climb_total` rationale, AC-CG-33a | FIXED | canh-gioi Tuning Knobs and AC-CG-33a now say about 44 years (73 %) |
| W2 `g` on a root change | OPEN | cong-phap rule 8 still treats a root change as a guard only; Linh Căn Quả payoff and linh-can OQ9 unchanged |
| W3 cong-phap stale figures | OPEN | 396 "+16 % in QR and FE"; OQ5 (row 5) "about 3 % of five-element lives" vs OQ1 and registry "about 6 %" |
| W4 mutation lifespan vs the ceiling | HALF FIXED | Rule 14 and CS Formulas I now count "every `lifespan_years`", so mutations are capped (CS rule 14's exemption list names no lifespan term). linh-can Formulas E still prices Time at +200 years (463) and Life at +10. Its own note at 465 calls for a retune. See W10 |
| W5 clamped lifespan | FIXED | rule 14 "Clamped bonus is kept", rule 9, Edge Case, AC-CG-61 and AC-CG-63, Advisor warning |
| W6 calibration run order | FIXED | AC-CG-60 "run AC-CG-30 first" |
| W7 rule 18 duties | OPEN | not touched |
| W8 AC-LC-23/38 "runs at" | OPEN | linh-can 805, 890 |
| W9 ownership and registry gaps | OPEN | not touched |
| I1 "other rate factors 1.25" | OPEN | linh-can 333, canh-gioi 313 and 326 |
| I4 `alchemy_success` missing from `p_brew` | FIXED | canh-gioi Formulas D, the parameter table, the 3.89 example, the AC and the registry expression |
| I6 CS rule 14 heading | FIXED | "Caps. The first is per source" |
| C2 stale "no GDD yet" | PARTIAL | canh-gioi fixed; CS 260 and 711 still say only Realms and the Meridian Map have GDDs |
| C3 Cross-References rows | PARTIAL | canh-gioi now has a cong-phap row. CS and linh-can still have none, and KMD lists no sibling GDD |
| N1 crude floor | FIXED | canh-gioi rule 13 |
| N3 `speed_pct` "0–about 40" | OPEN | canh-gioi 632 |
| N14 CS "power 1.0" | OPEN | CS 365 and 731 vs rule 11's 0.5 with no main method |
| N15 canh-gioi omits cong-phap | FIXED | Interactions, Dependencies and Cross-References |
| N19 index out of date | OPEN | index "Last Updated 2026-11-03"; line 28 "there are no GDDs" |
| Others: C4, C6–C8, N2, N7–N9, N11, N13, N16–N18, I2, I3, I5, I7 | OPEN, unchanged | no fix touched them |

---

## Consistency Issues

### Blocking
None.

### Warnings

⚠️ **W10. Spiritual Roots still prices lifespan mutations as uncapped years (W4 residual).**
- Under rule 14 a Time mutation's +200 years delivers at most 18 / 30 / 75 / 150 / 300 by realm, and less once pills, treasures and techniques share the ceiling.
- linh-can Formulas E prices Time at W 590 and Life at W 52 from the full years (2.5 W per year).
- Options:
  - (a) reprice at the delivered value;
  - (b) move mutation lifespan to `lifespan_pct` with its own price (linh-can 465 already proposes this; `lifespan_pct` is uncapped, D7);
  - (c) exempt the root's own lifespan from the ceiling, as with the root's other terms. That changes CS rule 14 and canh-gioi rule 14.

⚠️ **W11. The lifespan cap formula is not in the registry.** `bonus_ceilings` is registered, but the cap expression (rule 14) and its owner are not. CS rule 13, canh-gioi rule 14, AC-CS-52 and AC-CG-61 all compose it. It is a short entry: owner canh-gioi, inputs `L_realm`, the lifespan bonus and `lifespan_pct`.

⚠️ **W12. Rule 14's confirmation creates obligations for systems without a GDD.** The rule names "equipment" changes and treasure lifespan. Item DB (#2) and the equipment UI have no GDD, so nothing yet owns the preview for unequipping. Add a pending-obligation note to the Item DB row of the systems index, next to W7's notes for #3, #20, #26 and #27.

Carried: W2, W3, W7, W8, W9 and the Info items above.

---

## Game Design Issues

### Blocking
None.

### Warnings

⚠️ **NG8. An involuntary loss of lifespan bonus still kills without a preview (NG4 residual).**
- Rule 14's confirmation covers slot, equipment and main-method changes made by the player.
- The cap can also fall without a player action:
  - a treasure destroyed or stolen (Combat, Item DB, Event Engine; no GDDs yet);
  - loss of #6, which empties the second slot (cong-phap Edge Case 647; KMD currently has no path that removes a capability, so this is a guard);
  - a root change that unslots a technique (cong-phap rule 8; a guard, since no root change removes an element).
- Today the general clause applies: at age ≥ cap the character dies. That is defined behaviour, so this is not a blocker. But it is a death the player could neither see nor refuse. The only live path (losing a treasure) belongs to systems not yet written.
- Options:
  - (a) accept it, and add an Edge Case saying so plus a chronicle line naming the cause;
  - (b) a grace rule: an involuntary drop cannot put the cap below age + 1 season, so the player gets one season to restore it;
  - (c) leave it to the Item DB and Combat GDDs, recorded as an obligation (W12).

ℹ️ **NG9 (Info). Kept bonus makes the lifespan ceiling the norm for planners.** Clamped years are kept and count again at each great breakthrough. A player who stockpiles early lifespan pills enters every realm at the ceiling, so the ceiling acts as a flat +15 % of the realm's base lifespan. AC-CG-60 already calibrates odds with all three bonuses at their ceilings, so breakthrough odds are unaffected. It only matters if lifespan pills were meant to be a per-realm sink. Confirm when the Alchemy and Item DB pricing is written.

**Carried open (not re-derived):** G2, G3, G5 (single roots near the NS and DT ceilings; I1's "1.25" hinge is unchanged), G6, G7 (its NG4 death trap is now guarded), G9 (speed channel), G10/D11 (attention budget, about 6 active systems, no owner), NG1 (only the strongest-element main meets the years table), NG6 (clamped lines still priced at full value, a visibility gap partly closed by the new clamp line and Advisor warning), NG7 (which life "3 in 10" describes), P3 residuals.

### Pillar and fantasy summary (3f, 3g)
No change from the 04c review, except:
- **Pillar 2 (Power Is Built):** better. The lifespan clamp is now a visible line with the years held back.
- **Pillar 4 (time pressure):** better. A menu action can no longer kill silently. The remaining silent path is NG8.

Pillar 1 / NG1 and G2, Pillar 3 / G3, the "fixed classes" anti-pillar and the fantasy conflicts are unchanged.

---

## Cross-System Scenario Issues

Scenarios walked: 3
1. S1: a QR player at age 130 unslots an art giving +15 lifespan, declines, then confirms. Systems: Cultivation Techniques, Character Stats, Realms.
2. S2: a QR player with 40 stored lifespan bonus (18 counted) breaks through to FE, then to CF. Systems: Character Stats, Realms, Alchemy.
3. S3: an FE player with a lifespan treasure loses it to an event while near the cap. Systems: Event Engine, Item DB, Character Stats, Realms.

### Blockers
None.

### Warnings
- ⚠️ **S3** (Event Engine, Item DB, CS, Realms): the treasure is gone. CS recomputes the bonus and Realms' general clause kills at the next age check. No preview or chronicle cause is defined. See NG8.

### Info
- ℹ️ **S1:** the walk-through is clean.
  - Preview, then decline: nothing changes and no RNG is drawn.
  - Confirm: death before cultivation, logged.
  - At age 110 the change goes through without a prompt.
  - A main-method switch that lowers harmony follows the same path.
- ℹ️ **S2:** the walk-through is clean.
  - QR shows 18 counted and 22 held back. At FE it counts 30 (cap 230); at CF it counts 40 (cap 540), matching rule 9, the Edge Case, AC-CG-61 and the canh-gioi success AC.
  - A pill whose years only partly exceed the ceiling gets no Advisor warning, since the warning covers only "all above". That is acceptable, because the clamp line shows it.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| linh-can.md | W10 lifespan mutation pricing; carried W2, W8, G5, I1, I2 | Consistency + Design | Warning |
| cong-phap.md | carried W2, W3, W7, NG1, NG6, P3, G2, G3, G7 | Consistency + Design | Warning |
| character-stats.md | carried C2 (260, 711), C3 (no cong-phap or linh-can row), N14, N7, N9 | Consistency | Warning |
| canh-gioi.md | NG8 Edge Case for involuntary loss; carried N3, I1 | Design | Warning |
| kinh-mach-do.md | carried C3, W9, N2, N8, I7 | Consistency | Warning |
| systems-index.md (not a GDD) | N19; W12 Item DB obligation; W7 obligations on #3, #20, #26, #27; rows 7 and 9 still cite 04c blockers that are now fixed | Consistency | Warning |

---

## Verdict: CONCERNS

There are no blocking issues. Both 04c blockers are fixed and their numbers reproduce:
- **B1:** the lifespan cap now reads the ceilinged bonus in canh-gioi, Character Stats and the registry.
- **NG4:** a player-made change that would end the life now needs confirmation.

The remaining items are warnings. Most were carried from earlier passes, and three are new:
- W10: linh-can mutation pricing;
- W11: the registry entry for the cap formula;
- W12: the Item DB obligation;
- NG8: involuntary loss, a design call.

Architecture can proceed on these GDDs. The warnings are best cleared in a cleanup pass before `/create-architecture`. canh-gioi is still "In Review" and needs its re-review (`/design-review design/gdd/canh-gioi.md`) before it returns to Approved.

### Coverage
- **Read in full this pass:**
  - the whole uncommitted diff (canh-gioi, CS, cong-phap, review log, systems index, registry);
  - CS rules 13–14, Formulas I lines and AC-CS-52 and AC-CS-54;
  - cong-phap rules 8, 11 and 12 and the Edge Cases at 640–650;
  - the registry lifespan and `bonus_ceilings` entries;
  - the Cross-References lists of CS, linh-can and KMD.
- **Grep-checked:** every carried warning listed with a line number above.
- **NOT ASSESSED this pass:** these were carried from 04c, and no fix touched their text:
  - N8;
  - G6 and the KMD #6 section;
  - the CS and canh-gioi ACs in full against the other GDDs (2f);
  - the Linh Căn Quả preview;
  - the KMD base-notable values for `herb_growth_pct` and `lifespan_years`.
- **Partial:** G5, NG7 and P4 are still unsimulated estimates, as in 04c.
