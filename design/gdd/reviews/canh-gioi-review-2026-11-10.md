# Design Review: Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) — 2026-11-10

Report only. No GDD, registry, config or code file was edited. Review mode: lean (single session, no specialists). Workflow: standard. Autonomous run.
Re-review: yes. The prior verdict was NEEDS REVISION (2026-11-05, second independent review). Its blockers were fixed and no review has covered those fixes. The GDD itself has not changed since 2026-11-05 except two inline notes about the 2026-11-10 no-caps change (Formulas D line 791 and AC-CG-60 line 1910).

## Verdict: NEEDS REVISION

The structure and the arithmetic hold. I re-derived and reproduced:
- Formulas A: costs, realm totals and the FE level-25 example.
- Formulas C: baselines 0.1025 / 0.1075 / 0.0825 / 0.085, the edge rows, and the suppressed 0.0648 and 0.041.
- Formulas F: Δhd 13.2 / 11.9 / 11.4 / 9.2 and n_90 = 7 / 8 / 8 / 10.
- The Meridian Map's point totals 51 / 120 / 216 / 357 / 566 and the stage bonuses.
- The registry's gate, NPC, world-size and failure keys. I found no value conflicts.

What is stale is the pill-supply model. The 2026-11-10 "no caps" decision (Character Stats rule 14 curves, uncapped purity in Spiritual Roots, `max_plots` removed) was only half applied here. Several formulas and acceptance criteria still describe the 2026-11-04 ceilings, and the 0.30 / 0.70 calibration has not been re-run. The Combat revision #44, resistance in points, the redrawn Meridian tree and the graph Ways change nothing structural in this GDD, apart from the items listed below.

### Completeness (standard workflow)
- Required sections: 5 of 5 present (Overview, Detailed Design, Edge Cases, Dependencies, Acceptance Criteria). Formulas is also present, and it is required because the system defines numeric rules.
- Advisory: Player Fantasy has no heading (CG-16). Tuning Knobs is present.
- Extra sections present: Visual/Audio, Game Feel, UI Requirements, Cross-References and Open Questions.

### Dependency graph
- Exist: `linh-can.md`, `character-stats.md`, `cong-phap.md`, `kinh-mach-do.md`, `combat.md`, `combat-defence.md`, `effects.md`, `modifiers.md`, `dao.md`, `thien-kiep.md`, `quests.md`, `item-database.md`.
- No GDD yet (documented as provisional): Time & Turn, Spirit Herbs & Spirit Fields, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges (quick spec only), Market, Achievements, Balance Simulation Harness, Save/Load, World Generation, Living World Tick, Guidance Layer, Game UI.
- Stale statement: line 334 says Item DB has no GDD, but `item-database.md` exists (CG-12).
- Bidirectional: the Meridian Map, Character Stats, Spiritual Roots, Cultivation Techniques, Combat, Combat Defence, Effects, Modifiers and the Way all list Realms.

### Registry values
Searched the whole document for the registry entries this GDD owns (gate and failure keys, bands, bonuses, `stage_power_step`, `q_extras_ceiling_pp`, `failure_insight`, NPC and world keys) and for the shared Character Stats keys. No line contradicts a registry value. Two registry entries repeat the stale supply formula and ceilings (CG-14).

## Findings

### Blocking

**CG-01 — Lifespan rule still describes a ceiling (blocking)**
- **Location:** Rule 14 and its sub-bullet "Clamped bonus is kept"; rule 9 ("the lifespan bonus ceiling rises with it"); Edge Cases ("lifespan bonus sits above the ceiling"); UI Requirements (Lifespan, and the Advisor warning about years above the ceiling); Formulas D (line 809, "the lifespan ceiling bounds that"); AC-CG-61.
- **What is wrong:** Character Stats rule 14 and Formulas I (2026-11-10) replace the 15 % cap with a curve: `B_life = k_life · ln(1 + (pill_years + Σ⁺) / k_life) + Σ⁻`, with `k_life = 0.15 · L_realm`. This GDD still says "at most 15 % of the realm's base lifespan", a clamped bonus that is kept and counts again after a great breakthrough, a "clamp line … years held back" in the breakdown, and an Advisor warning that years "sit above the ceiling". Under the curve there is no clamp. Every year counts a little, and a realm change moves `k_life` and so the result.
- **Fix:** Rewrite rule 14 to quote the curve, and keep the "(realm base + bonus) × (1 + lifespan_pct ÷ 100)" form. Delete the clamped-bonus-is-kept bullet. Replace the clamp line with a "curve: raw +40 → +21.1" line. Change the Advisor warning to a diminishing-return notice ("this pill adds 2.1 years at your current stack"). Update rule 9, the Edge Case, the UI line and Formulas D line 809.

**CG-02 — p_brew formula contradicts the new `alchemy_success` (blocking)**
- **Location:** Formulas D, the `p_brew` formula; the variable row "herb_growth_pct, alchemy_success" (line 647); the bullet "`alchemy_success` adds percentage points to brew success"; "What the ceilings achieve".
- **What is wrong:** Character Stats Formulas I now defines `fail' = fail ÷ (1 + total/100)`, so success approaches 100 % and `alchemy_success` is not added as points. This GDD still has `p_brew = clamp(p_brew0 + 0.0025·purity_fire + alchemy_success/100, 0.05, 0.95)` and the row "at most 3 pp, min(Σ positive, ceiling) + Σ negative". Same in the registry's `realm_step_success` expression.
- **Fix:** Define `p_brew = 1 − (1 − p_brew0 − 0.0025·purity_fire) ÷ (1 + alchemy_success/100)` (keeping the 0.05 / 0.95 clamp if wanted), or whatever Alchemy ends up owning. Rewrite the variable row to say the curve and the dampening. Re-derive the ceiling-run effect: at p_brew0 0.65, +3 gives 0.66, not 0.68.

**CG-03 — n_plots clamp and purity range contradict Character Stats and Spiritual Roots (blocking)**
- **Location:** Formulas D, `n_plots = clamp(3 + ⌊0.04·purity_earth⌋ + field_plots, 1, 12)`; the variable table rows `n_plots` ("1–12") and `purity_*` ("0, 10–100"); AC-CG-60 ("`max_plots` 12 gives 0.78–0.88"); line 939 ("12 plots").
- **What is wrong:** Character Stats Formulas G says `plots = max(1, …)` with no upper bound (`max_plots` removed 2026-11-10). Spiritual Roots rule 8a and Formulas H say purity is uncapped and may pass 100 through rare sources, so `⌊0.04·purity_earth⌋`, `1 + 0.008·purity_wood` and `0.0025·purity_fire` can all exceed their stated ranges. Formulas D line 791 already says `max_plots` was removed, so the same document contradicts itself.
- **Fix:** Use `max(1, 3 + ⌊0.04·purity_earth⌋ + field_plots)`. Change the n_plots range to "1+" and the purity range to "0, 10+". Rewrite the "12 plots" figures as "n plots" examples, and see decision D2.

**CG-04 — AC-CG-61 and AC-CG-60 expect values that no longer follow (blocking)**
- **Location:** AC-CG-61 (lines 1913–1917); AC-CG-60 (lines 1900–1912).
- **What is wrong:** AC-CG-61 expects the QR bonus `min(40, 18) = 18`, cap 138, "22 years held back", and the FE bonus 30, cap 230. Under the curve:
  - QR: 18·ln(1 + 40/18) = 21.06, cap 141.06.
  - FE: 30·ln(1 + 40/30) = 25.42, cap 225.42.
  - There is no "held back" line.

  AC-CG-60 says to push the three totals "to their Character Stats ceilings (10 / 3 / 15 %)" and expects "the clamp lines". Neither a ceiling nor a clamp exists any more. Its remedy ("lower the Character Stats `bonus_curves` scales") is right.
- **Fix:** Re-derive AC-CG-61 with the curve (QR 21.06 / 141.06, FE 25.42 / 225.42 at ±0.01). Rewrite AC-CG-60's loadout as "a stack of N raw points on each key" and say which stack is the reference. Replace "shows the clamp lines" with "shows the curve lines".

**CG-05 — The gate calibration was not re-run, and this GDD has no open question for it (blocking)**
- **Location:** Formulas D ("Calibration loadout and bonus ceilings", "Fields are a build"); Formulas E ("Builds against the targets" table); Tuning Knobs (`bonus_ceiling_target`); the Open Questions table. Character Stats Open Question 8, `dao.md` rule 4 and the Meridian Map review (D6) all refer to "Realms' recalibration open question". None exists here.
- **What is wrong:** The ceiling-run figures (0.44 / 0.46 / 0.45 / 0.45), "+1 plot 0.52 / 0.55", "12 plots 0.78–0.88" and the claim that `bonus_ceiling_target` 0.45 holds were all computed with hard ceilings and at most 12 plots. Character Stats says the 12-plot run was already about 0.78–0.88 against a 0.30 target. Under curves with no cap, and with Dao Effects allowed past the q-extras ceiling (CG-07), none of these figures is verified.
- **Fix:**
  - Add Open Question 23: "Re-run the entry-age model and AC-CG-30 / 60 under the 2026-11-10 curves, uncapped purity and plots and the Way's Effects. Owner: systems-designer / Balance Harness. Blocks the bonus_ceiling_target figures."
  - Mark every figure in the "ceiling run", "fully built" and "field build" rows as "provisional, pre-curves" until it is re-run.
  - See decision D1.

### Recommended

**CG-06 — Heart demon resistance is missing from the failure rule**
- **Location:** Rule 10; Formulas F; Tuning Knobs (`failure_tam_ma_gain`, `nascent_tam_ma_max`); Formulas G (the NS row: "one failure (+15) still allows the next attempt").
- **What is wrong:** Character Stats rule line 123 says every heart demon gain is multiplied by the resistance factor (`tam_ma_resist_pct`, factor clamped 0.1–2.0). This GDD gives a flat +15. Δhd, n_90 and the NS condition ("one failure still allows the next") are only true at resistance 0. At the factor's maximum of 2.0 one failure gives 30, which already breaks the ≤ 20 condition. A penalised character fails the NS condition after one failure.
- **Fix:** Say "the gain is `failure_tam_ma_gain` × the resistance factor". State that Formulas F's n_90 is at resistance 0. Add an Edge Case for a factor above 1.33 at the NS gate. See D4.

**CG-07 — Dao Effects that move breakthrough odds are not in rule 8, Formulas C or Dependencies**
- **Location:** Rule 8 (q extras and "outside that ceiling"); Formulas C (X_q row); Dependencies row 39.
- **What is wrong:** `dao.md` rule 4 (user decision 2026-11-10, D-05) lets Effects that change breakthrough or heart-demon odds go beyond the q-extras ceiling. They must carry a bot fixture (AC-DAO-29), and the Realms calibration is re-run with them. This GDD still says "the Way adds no ceiling raise or root factor … if one is ever added this calibration must be re-run", and lists only a Dao node's `breakthrough_chance` stat line under X_q.
- **Fix:** In rule 8 and Formulas C list "Way Effects (`dao.md` rule 4)" as a source outside X_q (still under the 0.95 clamp). Update Dependencies row 39. See D3.

**CG-08 — Where `f` and the clamp apply differs between Formulas C and E**
- **Location:** Formulas C (`q_pill = clamp(f·(…), q_min, q_max)`); Formulas E (`q_j = min(q_max, q + f·min(j·ι_pp, ι_cap) + f·τ·[…])`); "Every other figure in Formulas D and E is before heavenly suppression".
- **What is wrong:** Formulas E adds `f` only to the insight and the talisman, so `q` must already be suppressed. The text says it is the pre-suppression baseline. The E formula only works if `q` is the suppressed first-attempt chance, and the tables use f = 1. Also, `q_min` 0.01 is applied after `f` in C, so a bare-minimum pill at NS→DT (0.0225 × 0.2 = 0.0045) is lifted to 0.01 (2.2×). E has no lower clamp.
- **Fix:** State "q in Formulas E is the suppressed baseline (f × the C sum)" and apply `q_min` in E too, or move `f` outside the clamp. See D5.

**CG-13 — Numbers that assumed the old ceiling of 10**
- **Location:** Formulas D line 962 ("+40 % herb growth clamps to the ceiling of 10; at 40 it would give 6"); Parameter keys line 1162 (`to_truyen_linh_dien` 40 "counts under the ceiling of 10"); Tuning Knobs (`bonus_ceiling_target` row).
- **What is wrong:** Under the curve +40 % gives 10·ln(1 + 40/10) = 16.1, not 10. The "3 to 4 brews" claim and the 0.52–0.55 edge-plus-field figures were derived at 10.
- **Fix:** Re-derive after CG-05, or mark provisional.

**CG-14 — Registry carries the same stale formula and ceilings (cross-document, for the sweep)**
- **Location:** `design/registry/entities.yaml`: `bonus_ceilings` (line 2256: 10 / 3 / 0.15, "min(sum, ceiling)"); `realm_step_success` expression (n_plots clamp 12, `alchemy_success/100`); `bonus_ceiling_target` notes.
- **What is wrong:** `bonus_ceilings` is owned by Character Stats and still holds the old ceilings; Character Stats now calls them `bonus_curves` and `lifespan_frac`. `herb_age_root_pct` is correctly deprecated, but it still lists this GDD in `referenced_by`.
- **Fix:** Update after CG-01 to CG-05. I did not edit the registry.

### Minor and mechanical

**CG-09 — Rule 16 and the Combat rows still say "defeat"**
- **Location:** Rule 16 (#9 "defeating a cultivator"); the Interactions Combat row ("defeats reported"); Dependencies row 21.
- **What is wrong:** Combat rule 14 and its Open Question 12 (closed 2026-11-06) make it a knockout of a cultivator, and say Realms should be reworded.
- **Fix:** Use "knockout" in those three places.

**CG-10 — Combat row omits the realm gap and the tribulation result**
- **Location:** The Interactions Combat row; Dependencies row 21.
- **What is wrong:** Combat reads `power_base`, `stage_mult` and the realm gap `g` from Realms, and reports "the result for a tribulation".
- **Fix:** Add both to the data column. The Combat Defence ward-slot row already exists.

**CG-11 — Spiritual Roots rows omit the purity input**
- **Location:** The Interactions Spiritual Roots row; Dependencies row 6.
- **What is wrong:** Both list `n_eff` and the curve factor, but pill supply (Formulas D) also reads the purities of Earth, Wood and Fire.
- **Fix:** Add per-element purity to both rows.

**CG-12 — Stale status statements**
- **Location:** Header (lines 3–7); line 334.
- **What is wrong:** The status line says "In Review (2026-11-05 …)", and Last Updated is 2026-11-05 although the file was edited 2026-11-10 (Formulas D line 791, AC-CG-60 line 1910). The "Last Verified 2026-11-04" date is also old. Line 334 says Item DB has no GDD, but `item-database.md` exists.
- **Fix:** Update the header after the revision and fix line 334.

**CG-15 — The redrawn tree's assumptions were not confirmed**
- **Location:** Formulas D ("the tree gives no plots at its launch values"); Rule 8 (tree 8 pp).
- **What is wrong:** `design/research/meridian-tree-overnight.md` and `meridian-land-authoring.md` contain no mention of `field_plots`, `breakthrough_chance`, `herb_growth_pct` or lifespan acupoints. I could not confirm that the hand-drawn tree holds no plot node and keeps breakthrough nodes inside 8 pp.
- **Fix:** Have the Meridian Map's owner confirm in AC-CG-60's run.

**CG-16 — Player Fantasy has no section (advisory at standard)**
- **Location:** Whole document.
- **What is wrong:** The intent sits in the Overview and Game Feel.
- **Fix:** Optional: add a short Player Fantasy section for the bottleneck as a wall that preparation gets past.

**CG-17 — History clutter**
- **Location:** The document is about 158 KB; its rules carry many "changed 2026-11-04, review 04f / 04g" notes.
- **What is wrong:** They read as a changelog and bury the rules.
- **Fix:** Move the history to the review log when the revision is applied.

## Mechanical fixes (one sweep)
1. Rule 9, rule 14, the Edge Case and the UI lifespan line: describe the curve (CG-01).
2. Formulas D: p_brew formula and the `herb_growth_pct` / `alchemy_success` row (CG-02); n_plots clamp, ranges and "12 plots" (CG-03); line 809 and 962 (CG-01, CG-13).
3. Parameter keys line 1162 and Tuning Knobs `bonus_ceiling_target`: wording and figures (CG-13).
4. AC-CG-60 and AC-CG-61: loadout wording and expected values (CG-04).
5. Rule 16, the Interactions Combat row and Dependencies row 21: "knockout", realm gap, tribulation result (CG-09, CG-10).
6. Interactions and Dependencies Spiritual Roots rows: add purity (CG-11).
7. Header status, Last Updated and line 334 (CG-12).
8. Open Questions 12 and 15: drop "ceiling of 10" wording and update for the curves.
9. Registry, Character Stats' owner: `bonus_ceilings`, the `realm_step_success` expression and `bonus_ceiling_target` notes (CG-14).
10. Combat and Character Stats: reword "defeat" and "kill" to "knockout" (their own follow-up).

## Decisions needed

Each is a one-line question with my recommended answer first.

- **D1 — How should the pill-supply bonuses be calibrated under the no-caps curves (CG-05)?** Recommend: keep the 0.30 / 0.70 targets and tune the `bonus_curves` scales until the ceiling run is ≤ 0.48 (AC-CG-60), as the AC already says. Alternatives: restore a hard cap for the three pill-supply keys only, or accept that a stacked build passes 0.48 and widen the target.
- **D2 — Does purity past 100 and unbounded `field_plots` sit outside `bonus_ceiling_target` (CG-03)?** Recommend: yes, treat both as deliberate build levers like fields, report their gate odds in the builds table, and note that B stays bounded by W and the attempt timing. Alternatives: bound `n_plots` and the purity terms inside Realms' own B calculation only, or restore `max_plots`.
- **D3 — Do Way Effects on breakthrough odds sit outside X_q (CG-07)?** Recommend: yes, as `dao.md` rule 4 says, still under the 0.95 clamp, each with a bot fixture. Alternative: count them inside X_q and drop the dao.md exception.
- **D4 — Does heart demon resistance reduce the failure gain (CG-06)?** Recommend: yes, as Character Stats says, with n_90 stated at resistance 0 and an Edge Case for a factor above 1.33 at the NS gate. Alternative: make the +15 fixed so the NS gate stays predictable.
- **D5 — Where does `f` sit relative to the clamp (CG-08)?** Recommend: apply `q_min` and `q_max` before `f` in C, and say `q` in E is the suppressed value. Alternative: keep the clamp after `f` (lifts the weakest last-gate pill from 0.0045 to 0.01) and say so.
- **Open from the earlier review (unchanged):** Open Question 21 says the Overview calls Nascent Soul "the top sect leaders" while `leader_realm_min` is Core Formation. Recommend softening the Overview to "among the sect leaders". Alternative: raise `leader_realm_min` to Nascent Soul only if the sect count is about 27 or fewer.

## Scope signal
XL (rough; producer should verify before sprint planning). Five hard dependencies, seven formula blocks (A, B, C, C2, D, E, F, H, I), several new keys, and a bot-run calibration that has to be redone.

## Verification limits
- I read the whole GDD except about 400 lines of acceptance criteria, which I checked only where they restate ceilings, plots and purity. I did not re-check the arithmetic of AC-CG-01 to 59 beyond the examples already listed.
- I did not read `game-concept.md` or the narrative files this run.
- Cross-document facts come from Character Stats, Spiritual Roots, the Meridian Map, the Way, Combat, Effects, Modifiers and the registry as they stand today.
- The simulation scripts and the entry-age model were not run, so the odds tables stay unverified (CG-05).
