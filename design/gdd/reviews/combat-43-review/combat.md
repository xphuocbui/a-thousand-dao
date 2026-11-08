## Design Review: Combat (`design/gdd/combat.md`)

**Mode and path.** Lean review, workflow `standard`, autonomous. It is a re-review: the prior verdict was APPROVED on 2026-11-06 (ninth pass), before the revision. The freshness check showed `combat.md`, the registry and the stamped GDDs all CHANGED, so I did a full review. No specialists ran (lean). Nothing was written. I skipped the Phase 5 widgets, the review-log append and the systems-index update, because the run is read-only.

**Completeness: 7/7 required sections present.** Player Fantasy is absent. It is advisory at `standard`, and the Overview carries the intent.

**Dependency graph.** All listed GDDs exist: combat-defence, combat-damage-types, modifiers, effects, character-stats, canh-gioi, cong-phap, kinh-mach-do, dao, item-database, thien-kiep and quests. The provisional systems have no GDD and are marked provisional. The two quick specs the doc cites also exist.

**Registry values.** The whole-document search printed many lines. The active keys all match: `health_units` 16 (12–26), `qi_units` 26, `time_limit` 40, `cooldown_min` 0.5, `pierce_cap` 0.75, `dot_pulse_cap` 0.08, `dot_pool_cap` 0.05, `regen_cap` 0.08, `rating_kappa` 14, `kappa_mass` 4, `creature_mult` 1.1, the soul keys, `layer_caps` and `overkill_epsilon`. Typical Qi Refining ehp is 297.8 in both. The conflicts are all registry-side, not combat.md-side (CB-06).

## Verdict: NEEDS REVISION

Rules 1–24, the sub-system pointers and the D1–D19 and C1–C4 decisions are applied correctly. No stale term survives in a live rule. Every pointer to an AC-CD, AC-DT, AC-MD or AC-EF criterion resolves to a real criterion. I recomputed every formula, example and AC number I could. All of them check out except the ones listed below. The one blocker is the FX-T mirror: it ends at 6.000 s on my hand run, not 7.7 s ±10 %. The other findings are provenance gaps in the Formulas K example, an unspecified trigger event list and order, one half-applied decision (D13), unnamed data keys, a stale registry, one impossible test and small rounding nits.

## Required before implementation

**CB-01 — BLOCKING — DECISION.**
- **Location:** AC-CB-30 (line 1251), Formulas B (line 569), Game Feel (line 1128), and AC-CD-46 in Combat Defence & Healing.
- **Problem:** AC-CB-30 says the FX-T mirror end time "is the one value a hand cannot work out" and "must fall within AC-CD-46's 7.7 s ±10 %" (6.93–8.47 s). I worked it by hand from the AC's own fixture and it ends at 6.000 s, outside that band. Formulas B says "ends at 8 s" and Game Feel says "about 8 seconds". Those two are stale too.
- **Working.** FX-T has health 109.87 and linh lực 172.74. The art does D 41.30 and the basic attack does D 20.65. Each side has the Common Ward (r 0.654, drain rate 0.95858) and block 0.946.

| t | Pool before hits | Art hit dealt | Basic hit dealt | Health after |
|---|---|---|---|---|
| 1 | 172.74 − 25.91 = 146.83 | 13.34 | 6.20 | 90.33 |
| 2 | 111.45 − 25.91 = 85.53 | 13.34 | 6.20 | 70.78 |
| 3 | 50.16 − 25.91 = 24.25 | 15.05 | 19.70 | 36.03 |
| 4 | 3.455 | none (art cannot pay) | 16.10 | 19.93 |
| 5 | 3.455 | none | 16.10 | 3.83 |
| 6 | 3.455 | none | 16.10 | −12.27, Down |

  - t=3: the art bill 25.89 exceeds the 24.25 pool, so 6.3 % of the prevented 27.01 leaks, which gives dealt 15.05. The pool is then 0, so the basic hit meets no ward and deals 20.65 − 0.946 = 19.70.
  - t=4–6: the basic bill is 12.946 against a pool of 3.455. The paid fraction is 0.2669, so 0.7331 × 13.505 = 9.90 leaks, which gives 7.145 + 9.90 − 0.946 = 16.10.
  - Both sides are identical, so the fight is a draw at t = 6.000 s. The closed form in Formulas K gives 7.69 s because it averages the rotation (Off 36.51, art uptime about 0.4). The FX-T mirror front-loads its art (it fires at t=1, 2 and 3 only).
- **Fix, options:**
  - **A (recommended).** Make AC-CB-30's FX-T half a Logic test that asserts 6.000 s as a draw, with the table above as the worked trace. Keep 7.7 s ±10 % as the target for the typical rotation (Formulas K and AC-CB-54). Change AC-CD-46's FX-T line to say "typical rotation (Formulas K)", not the FX-T fixture. Change "ends at 8 s" in Formulas B and "about 8 seconds" in Game Feel to match. This needs one edit in the approved Combat Defence & Healing GDD.
  - **B.** Re-tune the FX-T fixture so that its mirror lands in 6.93–8.47 s. For example, give the art a longer cooldown. This changes many fixture numbers.
  - **C.** Keep the test as a harness-only measurement and widen the band to include 6.0 s. This leaves the mismatch between the closed form and the full fight undocumented.

## Recommended revisions

**CB-02 — RECOMMENDED — DECISION.**
- **Location:** Formulas K, Example (lines 891–897), and AC-CB-49.
- **Problem:** The example gives "Off 36.51 … net spend 6.91" with no inputs. The two figures do not come from the same rotation.
  - Off 36.51 equals 6.30957 × 3.272808 × 1.6 × 1.105. That is the Formulas B Typical anchor (mean coefficient 1.6, 15 % crits at ×1.7, crit_EV 1.105). The FX-T fixture says "no chance fields".
  - Net spend 6.91 equals 25.911 × 0.4 − 3.455, which is art uptime 0.4. By the formula `c_rate = 1.0 + 2.0 × uptime`, uptime 0.4 gives c_rate 1.8, not 1.6. D_late 22.82 equals 20.65 × 1.105.
- **Working for a consistent uptime of 0.3 (c_rate 1.6).**
  - Net spend = 25.911 × 0.3 − 3.455 = 4.32.
  - t_w = 172.74 / (36.51 × 0.627 + 4.32) = 6.35.
  - Health lost = 6.35 × 36.51 × 0.32009 = 74.2, so 35.7 health is left.
  - T0 = 6.35 + 35.7 / 22.23 = 7.95 s.
  - That is still inside 7.7 ± 10 %.
- **Fix, options:**
  - **A (recommended).** State the inputs (Typical anchor, uptime 0.3). Restate net spend 4.32, t_w 6.35, T0 7.95, and update AC-CB-49 to match.
  - **B.** Keep 6.91 and say it comes from uptime 0.4. Then Off must be recomputed for c_rate 1.8, which changes the 36.5 D_ref used in Combat Defence & Healing Formulas G.
  - **C.** Keep the numbers and label Off and net spend as independent calibration inputs. This is the weakest option, because a reader still cannot recompute them.

**CB-03 — RECOMMENDED — DECISION.**
- **Location:** Core Rules, rule 9 (lines 138–142), rule 10 (line 174), and AC-CB-43.
- **Problem:** Rule 9 says "Triggers resolve in a fixed order". It never states that order. Rules 10, 13 and the Edge Cases all cite "the fixed order of rule 9". The Effects System now relies on Combat for "the trigger order". Rule 9's event list also has only six events (on hit, on being hit, a pool below a threshold, a pulse, a status applied, an art fired). Effects rule 5 lets Effects read more: crits, evades, kills, a shield breaks, a named cap clips, ward payments made against your hits, the Down step. AC-CB-43 tests "each event in rule 9".
- **Fix, options:**
  - **A (recommended).** Give the order in one sentence: by event time, then the requesting side first, then the carrying slot order, then record id. List the full event vocabulary as Effects rule 5 lists it, and say which events are trigger events and which are read-only.
  - **B.** Say the event list is the Effects System's (rule 5) and keep only the order here.

**CB-04 — RECOMMENDED — SAFE.**
- **Location:** Formulas F variables table (`duration` and `c_tick` rows, lines 688–690), and AC-CB-57 (line 1305).
- **Problem:** D13 says standing statuses are bound by the tick caps, the caster's upkeep and `c_tick ≤ 0.15`. Combat keeps only "exempt". Effects System, Status Catalogue (line 291) states `c_tick ≤ 0.15`.
- **Fix:** In Formulas F add "a standing status: `c_tick ≤ 0.15`, bounded by upkeep and the tick caps". In AC-CB-57 add: "a standing status at `c_tick` 0.15 passes, at 0.16 it fails".

**CB-05 — RECOMMENDED — SAFE.**
- **Location:** UI Requirements (lines 1148–1149), Formulas F (qi burn cap, line 699), Formulas K (`reference_type_mix`), Tuning Knobs (lines 1076–1097), Parameter keys.
- **Problem:** Three values are called data keys but never named or listed.
  - D16 says the Advisor threshold of 1.25 × `health_max` is "a data knob". The knob has no name.
  - The "5 % of `qi_max`" qi burn cap is a bare number here. Effects names it `qi_burn_cap`, range 3–10 %.
  - `reference_type_mix` (D7) is in no Tuning Knobs row.
- **Fix:** Name the Advisor key (for example `advisor_min_ehp_ratio` = 1.25) and add it to Parameter keys and Tuning Knobs. Write `qi_burn_cap` in Formulas F and add it to Tuning Knobs. Add `reference_type_mix` to Tuning Knobs.

**CB-06 — RECOMMENDED — SAFE.**
- **Location:** `design/registry/entities.yaml`, lines 548–597, 628–647, 2353–2360 and 662–663, 682–683.
- **Problem:** Three active entries are still in the pre-revision model.
  - `combat_hit_damage` expression ends in `dealt_j = max(1, leak_j*(1 - m*guard_share_kind))`, its variables list `m_kind`, and its notes say "ward, body guard, floor".
  - `rating_clash` still uses `pass`, `drain` and `f`.
  - `combat_pool_max` has `qi_start = qi_max`. That ignores reservation and D6 (`qi_use = qi_max · (1 − Σ reserved)`).
  - `slots_by_realm` notes say "the autocast ward" (now "wards in ward slots").
  - The two "Kept active until the Combat revision (#43)" comments are stale.
  - The Combat keys `basic_coef`, `art_coef_per_cost`, `art_coef_per_cooldown`, `crit_*`, `evade_cap`, `l1_soft_*`, `c_comp_cap`, `trig_*`, `regen_base` and `mass_*`, plus the new `reference_type_mix`, are unregistered. This matters least.
- **Fix:** Rewrite the three expressions to Formulas C, K and A as they stand now. Update the two notes and comments. Register `reference_type_mix` and the new keys from CB-05.

**CB-07 — RECOMMENDED — SAFE.**
- **Location:** AC-CB-40 (line 1269).
- **Problem:** "GIVEN Slackened Soul at 3 stacks, THEN soul resistance falls by 30 pp, not 45". The Effects catalogue says Slackened Soul "Stacks to 2", so 3 stacks cannot exist and the test cannot run.
- **Fix:** Write: "GIVEN Slackened Soul at its 2-stack cap, THEN soul resistance falls by 30 pp. GIVEN a test record with the stack cap raised to 3, THEN it still falls by 30 pp, not 45 (`curse_soul_shred_max`)."

**CB-08 — RECOMMENDED — DECISION.**
- **Location:** Core Rules, rule 6 (line 113), rules 2 and 18.
- **Problem:** Rule 6 says the full tag vocabulary is Modifier System rule 9. That table has a `foe` family (cultivator, creature) marked "Pending until Combat stamps them", with owner "Combat rules 2, 18". Combat does not stamp them and does not say they are deferred.
- **Fix, options:**
  - **A.** Compile stamps `cultivator` or `creature` on each profile and defines which side's tags a `foe` scope reads.
  - **B (recommended).** Say in rule 6 that foe tags stay Pending until the content needs them, and tell the Modifier System.

## Nice to have

**CB-09 — NIT — SAFE.** Formulas J, Example (line 842) says "D = 6.31 × 0.4 × 3.27 = 8.25". Exact: 6.30957 × 0.4 × 3.272808 = 8.260, which is 8.26 and matches AC-CB-45. Change 8.25 to 8.26. The dealt figure 1.91 is unchanged.

**CB-10 — NIT — SAFE.** Fixtures (line 1196) says "M 3.27279". Exact: 1.265 × 1.4 × 1.4 × 1.2 × 1.1 = 3.272808, so 3.27281. It is inside the ±0.01 tolerance. Change it for tidiness.

**CB-11 — NIT — SAFE.**
- The header Status line (line 3) still says "ward pass clamp" in its history. Add "(since retired)" or reword it.
- `Last Verified` (line 7) still reads 2026-11-06 after the 2026-11-08 revision.

## Settled decisions checked

All applied correctly, and none reopened.
- **D1–D4:** the Combat D stub and moved keys, role tags `ward_gear` and `body_gear`, the soul shield term in E2, and mixed Soul hits rejected.
- **D5–D12:** derived tags (AC-CB-82), starting shares on the usable pool (AC-CB-78: 27.47, 86.37, 48.95), the `reference_type_mix` rating, the four coverage groups, no `trig_ward_*`, Down step before overkill, tick penetration snapshot (AC-CB-80: 3.74), and Slackened Soul −15 pp capped at −30 pp.
- **D13:** the standing-status duration exemption applied; the `c_tick ≤ 0.15` bound is missing (CB-04).
- **D14–D19:** both ways of paying in health, pointers to AC-CD and AC-DT, the Advisor threshold (1.03 × and 3.47 × recompute; the unnamed knob is CB-05), effect-family cleanse tags, the `defence` section, and recharge computed on read.
- **C1–C4:** FX-U mirror draw at 25.000 s (recomputed). The `health_units` limit (26 passes, 27 fails; recomputed). The 2-D C2 fixture. Rule 18's 0.60 resistance threshold. The basic attack carries only `basic`.
- **Stale terms:** body guard, threat kind, ward pass and drain, `ward_art_duration` and `trig_ward_*` appear only in retirement notes and negative ACs, plus the one history phrase in CB-11.
- **Recomputed and correct:**
  - U values and the pool maxima (109.87 / 172.74, 25.24 / 41.01, 32,152.1 / 52,247.2, creature, boss).
  - M anchors (3.27 to 8.96 typical, 103.4 to 324.6 top-end) and the L1 soft-cap points.
  - Formulas C examples (41.30, 13.34, 27.96, 40.35, 23.35, 11.56, 146).
  - Soul, evade, escape and suppression examples; all poison and tick numbers, the 38.84 and 38.87 curse checks; the trigger numbers (9.39, 2.30, 6.67, 1.58).
  - Lint thresholds, the forces and κ figures (19 / 14, R 1.84, P 0.920, 0.792, 0.928), AC-CB-31 (36.75), AC-CB-34 (7 and 4 shots) and the thể tu AC-CB-74 numbers (23.34, 35.73).
  - Formulas K's t_w 5.80, t_h 9.40, 67.75 / 42.12 left and T0 7.69 do recompute from the stated inputs. The problem in CB-02 is the inputs, not the arithmetic.

**Scope signal:** XL. There are five or more dependencies, many formulas, and the build is on hold. The producer should verify before sprint planning.

**Counts:** blocking 1 / recommended 7 / nit 3; safe 7 / decision 4