# Confirming re-review: Spiritual Roots (Linh Căn), 2026-11-10

Report only. No GDD, registry, config or code was edited. Mode: lean (no specialists), workflow standard, autonomous.
Re-review of the fixes recorded in `linh-can-review-2026-11-10.md` ("User answers and applied fixes").
Scope signal: L (producer should verify).

## Verdict: NEEDS REVISION

2 blocking, 5 recommended, 6 minor, 1 decision.

The six answers (D1 to D6) are all present in the rules and every new worked number recomputes. What is left is
residue: the fixes reached the rules but not every formula, acceptance criterion and UI line that restates them.
Two of those are testable statements that now contradict the rules (blocking). Nothing in the design itself needs to be
reopened. Completeness at standard: 5 of 5 required sections plus Formulas; Player Fantasy and Tuning Knobs present.

## (a) Recorded answers and fixes: present and correct?

| Item | Present | Note |
|---|---|---|
| D1 derived variant follows parents past 100 | rule 10 yes; Formulas E range note yes; **Formulas D2 formula no** | LC-R01 |
| D2 unowned-element purity counts except root counts | rule 8a, Edge Cases, AC-LC-53 yes; AC-LC-26 not updated | LC-R05 |
| D3 applier's purity for debuffs, holder's for buffs | rule 8a, Formulas H, AC-LC-55, registry, effects.md rule 9a all agree | ok |
| D4 variant lands' roads grant variant purity | rule 8a, rule 10, Edge Cases, AC-LC-56 yes; Meridian Map rule 4 and OQ 22 agree | ok |
| D5 labelled target block for Void and Blood | rule 9 block yes; registry `innate_chance` still the shipped values, consistent with the block | ok |
| D6 technique speed uncapped | rule 8, Formulas G; `cong-phap.md` lines 176, 380, 384, 562 widened to match | ok |
| LC-01 pill capped at 100, refused only when all owned ≥ 100; fruit +8 never refused | rule 13, Formulas F, States, Edge Cases, AC-LC-39/43/44, Item DB rule 12 and AC-ID-34 agree | ok |
| LC-02 | rule 9 block | ok |
| LC-03 | see D3 | ok |
| LC-04 the Way is designed | Dependencies, Interactions, Cross-References, OQ 9 yes; older prose still says undesigned | LC-R07 |
| LC-05 defined versus intended sources | rule 8a, OQ 14 | ok |
| LC-07 ceilings wording | rule 7, Formulas E | ok |
| LC-09 duplicate AC-ID, UI bullets under AC-LC-51, AC-LC-55/56 added | **only partly** | LC-R03 |
| LC-10 registry keys and AC-LC-19 | `stack_purity_factor` and `pair_share` in registry (lines 1329 to 1350) and AC-LC-19 | ok |
| LC-11 dependency rows | Effects, Modifier, Combat Damage Types rows present; Quick reference not updated | LC-R11 |
| LC-14 new edge cases | present (lines 858 to 869) | LC-R06 for the fruit case |
| LC-15 D1 clamp wording | **not applied** | LC-R04 |
| LC-16 status block | Last Updated and Last Verified yes; status line 3 no | LC-R08 |
| Recomputed numbers | Formulas H (1.172, 1.252, 1.15, 1.18, 1.06), AC-LC-52 (Thunder 54), AC-LC-43 (Thunder 27), AC-LC-40 (0.14448, 39), AC-LC-55 (1.24), AC-LC-56 (Wind 55; Thunder round(0.8 × √22400) = 120) all correct | ok |

## (b) Cross-document check

Registry: all values match. `stack_purity_factor` 0.002 and `pair_share` 0.5 are registered and referenced by effects.md.
Effects rule 9a, Meridian Map rules 4 and 20 and the edge cases at lines 687 to 698, Character Stats Formulas G
(purity "uncapped after rare raises"), Cultivation Techniques (`match` above 1.0), Dao (`dao_req_purity_min` 30) and
Item DB (fruit past 100, pill refused at all ≥ 100) agree with this GDD. The only cross-document conflicts are the two
blocking items, both against Meridian Map rule 20 (LC-R02) and rule 10 (LC-R01).

## Findings

### Blocking

**LC-R01 (blocking) Formulas D2 still clamps a derived variant's purity at 100.**
- Location: Formulas D2 formula line, `purity_v = clamp(round(…), 1, 100)` (line 596); the D2 `purity_e` row ("10–100").
- Wrong: rule 10, Formulas D2's own Output Range, Formulas E and AC-LC-56 (Thunder 120 on Fire 160, Metal 140) say there is no upper clamp. The formula is the part a programmer implements, so it would clamp to 100 and fail AC-LC-56.
- Fix: `purity_v = max(1, round(…))` for derived variants; give `purity_e` the range "10 and up, uncapped" in D1 and D2.

**LC-R02 (blocking) Hidden variant sectors are still specified in AC-LC-33 and UI Requirements.**
- Location: AC-LC-33 (lines 1341 to 1347): "While a variant is unowned, its sector is not drawn, a spend into it is refused, and the reported map size excludes it", "visible at once", "refunds nothing", "with every host closed… refused", AC-KMD-71; UI Requirements "Meridian Map" bullet (line 1081): "An unowned variant's sector is not drawn and not hinted".
- Wrong: rule 12 and Meridian Map rule 20 say variant lands are open to everyone, the hidden sectors are retired (rules 6 to 15 of the Map; its edge case line 697). A test written from AC-LC-33 fails the correct build.
- Fix: rewrite AC-LC-33 to the land contract: a variant land is visible and walkable to everyone; its acupoints scale by 0.5 + purity ÷ 100, or 0.25 at purity 0; a root holding the variant may pick its start at birth; a variant forming mid-life changes the scale and not the start; an NPC owning a variant may take its start. Make the UI bullet say the map shows every land. Drop the AC-KMD-71 reference unless that AC still exists.

### Recommended

**LC-R03 (recommended) The LC-09 fix is half applied.**
- Location: lines 1417 to 1427. AC-LC-51 holds three bullets, but the four UI bullets ("Provisional … `explain` for Thunder", "`explain rate`", the Linh Căn Quả preview) still sit under AC-LC-56; the order is AC-LC-54, 53, 55, 56.
- Fix: move those bullets under AC-LC-51 (Open Question 12 already refers to "AC-LC-51's two provisional bullets"), and order the criteria 53, 54, 55, 56.

**LC-R04 (recommended) LC-15 and the purity ranges were not updated.**
- Location: Formulas D1 `chaos_factor` row (line 556) "the `min(1, …)` clamp matters only for this variant"; D1 and D2 `purity_e` "10–100"; rule 1 (line 101) "integer purity of 10–100" and Overview (line 37) "each with a purity from 10 to 100".
- Wrong: with purity past 100 a convergence (two parents at 130 give 1.01) can reach the clamp, and an owned element can exceed 100.
- Fix: say "binds for Primordial Chaos at birth, and for any variant on road-raised purities"; say "10 to 100 at birth; rare sources raise it past 100 (rule 8a)" in rule 1, the Overview and the D1/D2 tables.

**LC-R05 (recommended) AC-LC-26 "An absent element contributes 0" contradicts D2.**
- Location: AC-LC-26 (line 1283). Under D2 an element not owned but raised by roads contributes its roles, scale and technique use.
- Fix: "An element with no purity (not owned and no road purity) contributes 0; with road purity it contributes by that purity (AC-LC-53)."

**LC-R06 (recommended) The fruit-onto-a-road-raised-element rule lives only in one Edge Case.**
- Location: Edge Cases line 863 ("max(its road purity, the 20–35 draw)"); rule 13 Linh Căn Quả, Formulas F (`purity_new ~ U{20..35}`), and AC-LC-40 say nothing of it; no AC covers it.
- Fix: state it in rule 13 and Formulas F and add an AC (unowned Metal at road purity 40; fruit draws 28; Metal becomes 40, still one purity draw). See decision D1.

**LC-R07 (recommended) Older prose still calls the Way undesigned.**
- Location: Summary line 28 ("a new system"); Overview lines 60 to 64 ("designed on its own. This GDD defines only the contract it expects from that system"); rule 16 ("seeds for the Way's own design, not commitments… re-pointed when the Way is designed"); Edge Cases lines 938 to 940 ("Until the Way is designed").
- Fix: past tense and a pointer to `dao.md` (approved; the relocated mutations are its Ways and facets).

### Minor

- **LC-R08** Status line 3 still reads "2026-11-05: independent review findings applied; cross-GDD review CONCERNS". Update with the 2026-11-10 fixes. The systems index row carries the same stale status.
- **LC-R09** Player Fantasy lines 79 to 80 read "Wind,\nWind simply arrives" (a stutter left by the LC-12 edit). Make it "Wind simply arrives".
- **LC-R10** Tuning Knobs rows `stack_purity_factor` and `pair_share` (lines 1032 to 1033) have five cells in a four-column table (LC-18 still open). Merge the last two cells.
- **LC-R11** Quick reference key deps (line 30) lacks Effects and Modifier System; Visual/Audio Requirements (line 1058) still says a variant's "Meridian sector revealing itself".
- **LC-R12** Tuning Knobs `variant_purity_factor` ("at 1.0 a derived variant can reach purity 100") and `variant_power_band_apex` ("a derived Chaos cannot reach (max 80, 46.9 W)") are true only for the birth range. Add "at birth purities" or point to Open Question 15.
- **LC-R13** effects.md rule 9a names enemies, beasts and tribulations for `stack_purity` 0; this GDD says an NPC cultivator uses its root. Add "an NPC cultivator uses its root" there (flag for the Effects owner).

## Findings that need a user decision

- **D1.** When a Linh Căn Quả adds an element the roads already raised, should the purity be max(road purity, 20–35 draw)? Recommended: yes, as the GDD already writes it (Edge Cases line 863), because the player loses nothing. Alternatives: the draw replaces the road purity (breaks "purity never falls", rule 14), or the draw adds to it (a free +20–35 on top).

## Mechanical fixes (one sweep)

1. Formulas D2 formula: drop the upper clamp; `purity_e` ranges in D1 and D2 (LC-R01, LC-R04).
2. AC-LC-33 and the UI Meridian Map bullet rewritten to open variant lands (LC-R02).
3. Move the four UI bullets under AC-LC-51; order AC-LC-53 and 54 (LC-R03).
4. D1 `chaos_factor` row clamp sentence; rule 1 and Overview purity range (LC-R04).
5. AC-LC-26 last sentence (LC-R05).
6. Past tense for the Way in Summary, Overview, rule 16 and the Edge Case (LC-R07).
7. Status line 3, Player Fantasy stutter, Tuning Knobs cells, Quick reference deps, Visual/Audio sector line, two Tuning Knobs notes (LC-R08 to LC-R12).
8. After D1: rule 13, Formulas F and one AC for the fruit onto a road-raised element (LC-R06).

## Still blocking approval

LC-R01 and LC-R02 only. Both are wording and test fixes; no number or rule changes. Void and Blood stay pre-archive by decision D5
(LC-12, LC-17, LC-19 of the earlier review), and remain open until the code pass.

RESULT: verdict=NEEDS REVISION blocking=2 recommended=5 minor=6 decisions=1

## User answers and applied fixes (2026-11-10, same session)

- D1: fruit onto a road-raised element takes max(road purity, draw) (rule 13, Formulas F, AC-LC-57).
- Cross-GDD answers the same day: a technique may name an unowned element from purity 10 (`tech_foreign_purity_min`, Cultivation Techniques rule 8; rule 8 here); an unowned element's land scales by 0.25 + purity ÷ 100 (rule 8, Formulas G, AC-LC-53 now 0.55).
- Applied: LC-R01 to LC-R12 as listed; LC-R13 in effects.md rule 9a.
