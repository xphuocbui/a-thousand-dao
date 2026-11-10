# Confirming re-review: Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) — 2026-11-10

Report only. No GDD, registry, config or code file was edited. Review mode: lean (single session). Workflow: standard. Autonomous run.
Prior verdict: NEEDS REVISION (review of the same day). Scope: (a) each recorded answer and fix present and correct, (b) no new contradiction, (c) what still blocks approval.

## Verdict: NEEDS REVISION (1 blocking, 4 recommended, 5 minor, 1 decision)

The applied fixes are present and mostly correct. The lifespan curve in rules 9 and 14, the Edge Cases and AC-CG-61/62 is right, and I re-derived it:
- QR 18·ln(1 + 40/18) = 21.06, cap 141.06.
- FE 30·ln(1 + 40/30) = 25.42, cap 225.42.
- FE raw 25 gives 18.18 and cap 240.0.
- AC-CG-62 raw 15 gives 10.91 and cap 130.91.
- The dampened p_brew: at p_brew0 0.65, +3 gives 0.6602.
- AC-CG-68: 0.0648.

The D1–D5 answers are in place:
- D1: the AC-CG-60 reference stack, with the curve scales to be tuned.
- D2: build levers outside the target (line 787).
- D3: q_way sits outside X_q, under the 0.95 clamp.
- D4: the resistance factor on the gain, figures at resistance 0, and the factor above 1.33 edge case.
- D5: `q_pill = f · clamp(…)`, with Formulas E's q as the suppressed value.

Open Question 23 exists. Header dates are current, "knockout" is used in the Combat rows, and the registry's `lifespan_cap`, `bonus_curves` and deprecated `bonus_ceilings` entries are updated.

The fixes were applied unevenly. Applying D5 and the curves left one wrong acceptance-criterion value and a few stale ceiling and clamp descriptions behind.

Completeness: 5 of 5 required sections present, plus Formulas. Player Fantasy is absent, which is advisory at standard (unchanged from CG-16 of the earlier review). Dependency graph: unchanged from the earlier review, and every file the GDD names as existing still exists. Registry values: no line contradicts a registry value. Residual stale text is listed in CG-R05 and CG-R07.

## Findings

### Blocking

**CG-R01 — AC-CG-32 (Formulas D) example still uses the old additive `alchemy_success` (blocking)**
- **Location:** lines 1687–1688 (Formulas D acceptance bullet "Wood 40, Fire 86 with `alchemy_success` 3 at QR→FE").
- **What is wrong:** it expects p_brew = 0.895, which is the old `0.65 + 0.215 + 0.03`. Under the applied dampened formula (line 592) the value is `1 − (1 − 0.65 − 0.215)/1.03 = 0.869`. The next line says "`alchemy_success` 12 is clamped by Character Stats to 3 first, so the same". Character Stats no longer clamps it. A total of 12 gives `1 − 0.135/1.12 = 0.879`, and only a negative total floors at 0. The S figures in the following bullets (0.2079, 0.2128) use p_brew 0.65 and 0.64 with no `alchemy_success`, so they are unaffected.
- **Fix:** expect 0.869 (±0.001) for `alchemy_success` 3 and 0.879 for 12. Delete the "clamped to 3" sentence. Add a negative-total case (−5 gives the same as 0).

### Recommended

**CG-R02 — AC-CG-68 and the Formulas C output range still describe `q_min` after `f` (recommended)**
- **Location:** line 1960 ("whose scaled chance is below 0.01 is clamped to 0.01"); line 501 (Output Range "pill attempts 0.01–0.95").
- **What is wrong:** D5 moved the clamp before f, so a CF→NS pill attempt can be as low as 0.01 × 0.32 = 0.0032, and NS→DT as low as 0.002. Nothing is lifted to 0.01 any more. Line 501 also still says "about 0.02–0.06 at the last two gates", which is now only a typical value, not a floor. Edge Cases (line 1242) are correct.
- **Fix:** AC-CG-68: "a raw sum below 0.01 clamps to 0.01 first, then × f: 0.0032 at CF→NS and 0.002 at NS→DT". Output Range: "0.002–0.95; 0.01–0.95 at the first two gates".

**CG-R03 — The "Builds against the targets" heading still defines the ceiling run by the old ceilings (recommended)**
- **Location:** lines 904–913 (the heading and the "Ceiling run (AC-CG-60)" column).
- **What is wrong:** it reads "the three Character Stats ceilings 10 / 3 / 15 %" and gives 0.437 / 0.459 / 0.450 / 0.447 with no "provisional" mark. Line 783 and AC-CG-60 do mark these provisional. The table is what a reader finds first. The ceilings were replaced by curves and by the dampener (alchemy has no ceiling at all), and AC-CG-60 now defines the run as the reference stack.
- **Fix:** rename the column "Pre-curve ceiling run (provisional, Open Question 23)" and add "(2026-11-10: these were ceilings, now curves)" to the heading, or point the heading to the AC-CG-60 reference stack.

**CG-R04 — Open Question 21 was answered but is still listed as open (recommended)**
- **Location:** line 2013; the Overview (line 60) already carries the answer.
- **What is wrong:** it says "Still open: the Overview's top sect leaders are Nascent Soul, but `leader_realm_min` is Core Formation". The user answered it (Nascent Soul leads great sects, Core Formation may lead lesser sects, `leader_realm_min` stays), and the Overview says so.
- **Fix:** strike the question as "Answered 2026-11-10", keep a one-line note that sect tiers come with the Sects system.

**CG-R05 — Registry notes still say "ceilinged bonus" (recommended, cross-document)**
- **Location:** `design/registry/entities.yaml` line 509 (`lifespan_cap` notes: "Character Stats supplies the ceilinged bonus … counts under the ceiling"); the `realm_step_success` notes and `bonus_ceiling_target` notes should be re-read in the same sweep.
- **What is wrong:** the expression on line 508 was updated but its notes were not.
- **Fix:** "curved bonus … counts through the curve". Registry owner's sweep.

### Minor and mechanical

- **CG-R06** — Spiritual Roots rows still omit purity (the partly-applied CG-11). The Interactions row (line 341) and the Dependencies row (line 1331) list `n_eff` and the curve factor only. Add "per-element purity of Earth, Wood and Fire (uncapped), for plots, growth and brew success".
- **CG-R07** — Stale words: line 282 "the defeat" and line 1783 "A defeat in FE early stage" → "knockout"; line 297 "the lifespan ceiling cannot absorb it" → "the lifespan curve cannot absorb it"; Open Question 12 (line 2004) "would bypass the ceiling" → "would bypass the curve".
- **CG-R08** — The Tuning Knobs row for `bonus_ceiling_target` and the Parameter keys line (`to_truyen_linh_dien`) were not re-read in full, because the search output omitted those long lines. Confirm they carry no "ceiling of 10" figures (the earlier CG-13).
- **CG-R09** — Open Question 15 (line 2007) and Edge Cases still use the "ceiling" word for X_q. That one is a real ceiling (`q_extras_ceiling_pp`), so no change is needed. Noted only so it is not mistaken for a stale one.
- **CG-R10** — Status line (line 3) is accurate for now. After the revision, update it from "NEEDS REVISION, 5 blocking" to the new state.

## Mechanical fixes (one sweep)
1. CG-R01: the p_brew example values and the clamped-to-3 sentence.
2. CG-R02: AC-CG-68 line 1960, Output Range line 501.
3. CG-R03: heading and column label at lines 904–908.
4. CG-R04: Open Question 21.
5. CG-R05: registry notes (owner's sweep).
6. CG-R06, CG-R07, CG-R08, CG-R10.

## Decisions needed
- **CG-D1 — Does the "ceiling run" figure set stay in the GDD until Open Question 23 is run, or is it removed?** Recommend: keep, marked provisional (CG-R03). Alternatives: delete the table until the re-run, or re-derive it now with the curves in a scratch model.

## Summary of the status of the earlier items
CG-01 resolved (verified). CG-02 resolved in the formula, with one stale AC (CG-R01). CG-03 resolved. CG-04 resolved for AC-CG-60/61/62. CG-05 resolved (Open Question 23; marks partly missing, CG-R03). CG-06 to CG-10 resolved. CG-11 partial (CG-R06). CG-12 and CG-13 resolved apart from CG-R08. CG-14 resolved apart from the notes (CG-R05). CG-15 to CG-17 untouched (they were advisory). D5 resolved in the formulas but not in AC-CG-68 (CG-R02). Open Question 21 answered but not closed (CG-R04).

## Verification limits
I read the GDD by section and with targeted searches. I did not re-run the simulations, so every odds table stays provisional (Open Question 23). Character Stats, Spiritual Roots, the Way, Combat and the registry were checked only through searches on the keys above.

## User answers and applied fixes (2026-11-10, same session)

- CG-D1: the old ceiling-run table stays, marked provisional until Open Question 23.
- Applied: CG-R01 (0.869 / 0.879 / floor case), CG-R02, CG-R03, CG-R04 (Open Question 21 answered), CG-R05 (registry `lifespan_cap` notes and `realm_step_success` n_plots), CG-R06, CG-R07, CG-R08 (the `bonus_ceiling_target` knob row), CG-R10.
