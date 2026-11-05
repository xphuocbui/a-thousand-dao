# Review Log: Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)

Earlier review: a `/design-review` was requested in an earlier session, but its log was never
written to disk. No earlier entry could be reconstructed; the first entry below is the
first one on record.

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: The arithmetic reproduces everywhere checked: the Formula A cost tables, the stage starts, Formulas C–F and H, and AC-CG-02..09, 20, 29, 34, 39, 47, 49, 50 and 57. The registry has no value conflicts. The one blocker is a design gap: unlimited bare attempts, spaced to let heart demon decay, push total bare success far above the claimed 0.03 at the later gates and break the 0.30 / 0.70 targets.
Prior verdict resolved: First review on record
Findings:
- [BLOCKING] Formulas E/F, rules 8/10/11: S_bare ≤ 0.03 holds only for back-to-back failures; a grinder waiting about 15 years per failure keeps heart demon near 0 and reaches about 0.11 at CF and about 0.22 at NS; AC-CG-40 tests only base_chance ≤ 0.03 ÷ n_90
- [RECOMMENDED] Rule 18 (#23): its no-refill roll contradicts "cannot attempt before the bar is full", AC-CG-18 and AC-CG-27 (one season per attempt); no #22/#23 states in the state table
- [RECOMMENDED] Interactions / registry: ownership of great_breakthrough_bonus and the 15/25/35 shares is circular (registry says this GDD, this GDD says the Meridian Map, Meridian line 1522 says Realms); no parameter key, knob or AC; rule 9 hard-codes 35 %
- [RECOMMENDED] Rule 12: NPC stage-advance chance and fated_breakthrough_per_season have no keys or values; AC-CG-53 does not test them
- [RECOMMENDED] Formulas E: Deity Transformation baseline P_C depends on an unspecified enlightenment-event rate, missing from Open Questions; AC-CG-31 unverifiable
- [RECOMMENDED] Formulas C table: "+0.10 with each of the 2 starting talismans" reads as two talismans per attempt
- [RECOMMENDED] kinh-mach-do.md lines 173 and 395 still say "points per stage" (Meridian GDD fix)
- [RECOMMENDED] Edge Cases / AC-CG-57: a great-perfection save with a partial bar has no defined bar value
- [RECOMMENDED] Detailed Design intro says "Rules 1–15" while hooks 16–18 are cited as rules
Resolution (same day, user chose revise now):
- Bare attempts capped at `bare_attempt_cap` 3 per realm step (user's choice), reset only by a successful breakthrough, which bounds S_bare at about 0.012. Added to rule 11, Formulas E/F, Parameter keys, Tuning Knobs, UI, Save/Load and the registry. AC-CG-40 rewritten; AC-CG-40a (cap) and AC-CG-40b (patient-grinder bot) added. base_chance safe range is now ≤ 0.01.
- This GDD owns `great_breakthrough_bonus` and `pct_trung` / `pct_hau` / `pct_dai` (user's choice): Parameter keys, Tuning Knobs, AC-CG-58; rule 9 cites `pct_dai`.
- #23's extra roll resolves in the same season and is the one exception to the full-bar rule (user's choice): rule 18, the cannot-do list, a state-table row, AC-CG-18 and AC-CG-27.
- NPC values stated (stage chance 1 ÷ `npc_cultivation_seasons_per_stage` 12; `fated_breakthrough_per_season` 0.08, as built) in rule 12, Edge Cases and AC-CG-53.
- Open Question 10 added for the Deity Transformation baseline P_C.
- Talisman wording, migration partial bar (AC-CG-57) and the rules-numbering intro fixed.
- Not applied: the stale "points per stage" wording in kinh-mach-do.md.
- GDD status header set to In Review. Re-review pending in a fresh session.
The hashes below stamp the content as reviewed (before the revisions), so the re-review sees the revised GDD and registry as CHANGED.
Reviewed-Content-Hash: design/gdd/canh-gioi.md af0e0c230dcf4e2777c4871746fe931a0d8b55d0
Reviewed-Content-Hash: design/registry/entities.yaml 57b684f7a5d0e30d1a83314b4ed97bb43451179f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b312884ca296971fa555f47e71561ad5f81df2c2
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f

## Review — 2026-11-03 (second pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: The first review's blocker is resolved: the bare-attempt cap bounds S_bare at about 0.012, and the arithmetic reproduces everywhere checked (Formulas A–H, AC-CG-02..09, 13, 15, 20, 23–25, 29, 34–37, 39, 49, 50, 57). The revision introduced two specification contradictions around #23 and the "no cap" wording.
Prior verdict resolved: Yes (unbounded bare attempts)
Findings:
- [BLOCKING] Rule 18 / AC-CG-46 / AC-CG-49: #23's extra roll "needs the condition met" while the condition is "checked once"; the failure's +15 heart demon voids the Nascent Soul condition; whether a failed bare attempt enables #23 undefined
- [BLOCKING] Rule 11 / AC-CG-27 vs AC-CG-40a: "no cap on attempts" contradicts the bare-attempt cap
- [RECOMMENDED] Formulas E table: edge gift-pill column does not state its perk assumptions; NS→DT S = 0.302 assumes P_C = 1; CF→NS P_C unstated
- [RECOMMENDED] Tuning Knobs: Kim Tủy Quả min_age 150, ginseng min_age 40 and climb_total +30 % at NS/DT break the 0.30 ± 0.05 window or the half-lifespan ceiling
- [RECOMMENDED] Formula F / Overview / Game Feel: death by qi deviation is nearly unreachable; intent unstated, no AC
- [RECOMMENDED] Rule 11 / Edge Cases: stage loss (#5) effect on the bare-attempt count undefined
- [RECOMMENDED] AC-CG-34/40a/45: "FE bottleneck" vs "CF bottleneck" naming inconsistent
- [RECOMMENDED] kinh-mach-do.md lines 173 and 395 still say "points per stage"
- [RECOMMENDED] Registry: breakthrough_bare_chance note stale (0.03 / n_90); bare_attempt_cap missing status
- [RECOMMENDED] Open Questions ordered 10 before 9
Resolution (same day, user chose revise now):
- #23's extra roll inherits the failed pill attempt's condition result and follows only a failed pill attempt (user's choice): rule 18, Edge Cases, AC-CG-49.
- "No cap" now reads "no cap on pill attempts": rule 11, AC-CG-27; AC-CG-40a adds that a stage loss does not reset the count; stage loss edge case added (user's choice).
- Death by qi deviation kept as a rare tail risk (user's choice): Formula F, Game Feel, new AC-CG-36a (≤ 1 % of failures).
- Formulas E table headers and NS→DT / CF→NS P_C caveats added; knob ranges tightened (Kim Tủy Quả 80–130, ginseng 20–35, climb_total +8 % cap at NS/DT); AC bottleneck naming changed to gate notation; Open Questions reordered; registry note and status fixed.
- Not applied: the stale "points per stage" wording in kinh-mach-do.md (Meridian GDD fix).
- Systems index set to In Review. Re-review pending in a fresh session.
The GDD and registry are deliberately not stamped (revised after this review), so the next run treats them as changed.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b312884ca296971fa555f47e71561ad5f81df2c2
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f

## Review — 2026-11-03 (third pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Both blockers from the second pass are resolved (#23 follows only a failed pill attempt and inherits its condition; "no cap" now reads "no cap on pill attempts"). Formulas A–H and the sampled ACs reproduce, and the registry has no value conflicts. What remains is wording-level.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] States and Transitions row 215: says "an attempt failed"; rule 18, Edge Cases and AC-CG-49 limit #23 to a failed pill attempt
- [RECOMMENDED] Rule 17: #22 does not say "pill attempt only" (Edge Cases and AC-CG-48 do)
- [RECOMMENDED] Tuning Knobs: base_chance (≤ 0.01) and bare_attempt_cap (2–5) are bounded separately but the 0.03 limit is joint (cap 5 × 0.01 = 0.049); the two rows state the limit differently
- [RECOMMENDED] UI / Edge Cases: the bare-confirmation preview should say it uses one of the capped bare attempts and how many remain
- [RECOMMENDED] Open Questions: still ordered 8, 10, 9
- [RECOMMENDED] kinh-mach-do.md line 395 still says "points per stage and per breakthrough" (Meridian Map GDD fix, unapplied for the third time)
- [RECOMMENDED] Formulas C: the FE→CF, CF→NS and NS→DT baselines include a +0.10 talisman; state that assumption and its source (Open Question 3 covers only QR→FE)
Resolution: none applied; revisions deferred. Systems index set to Approved.
Reviewed-Content-Hash: design/gdd/canh-gioi.md 40960ba624b4eb39fa7e1ed30faefca73ee41bac
Reviewed-Content-Hash: design/registry/entities.yaml 787b3f3e6bcd8df02bb1ef57f1485ea261ae20ae
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b312884ca296971fa555f47e71561ad5f81df2c2
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f

## Cleanup — 2026-11-04 (no new review)
Applied the third pass's 7 recommended items and the cross-GDD review's warnings (`design/gdd/gdd-cross-review-2026-11-03.md`):
- #22 and #23 are pill-attempt only, in both GDDs and in the Meridian Map's E2 attempt model;
- the tree's 8 pp cap is referenced by its key `tree_breakthrough_cap` and applies only to the tree's share;
- base_chance and bare_attempt_cap now state one joint limit;
- the bare-attempt preview shows the bare attempts remaining;
- the Open Questions are reordered;
- the FE→CF+ talisman assumption is stated (Open Question 3);
- the bot policy for the 0.30 / 0.70 targets is stated (#22/#23 off, tree as played);
- the event contract is named on both sides;
- `breakthrough_bonus` is renamed to `great_breakthrough_bonus` in the Meridian Map;
- the #23-after-deviation chain is stated.

Not applied: a Player Fantasy section (advisory at the standard tier). Wording only; no values changed.

## Review — 2026-11-04 (fourth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: Formulas A–H, the D1 birth-mix calibration and the sampled ACs reproduce, and cross-review blockers C1 and D1 are resolved. Two blockers remained: the cultivation-rate formula was undefined and "plus" read as additive (cross-review C9), and Open Question 4 still held pre-recalibration plot-years (270 / 470 against 390 / 680). Both were fixed the same day, with the other cross-review warnings (C2, C3, C5–C8, C10, C13, C16, C17) and user decisions on the event contract (player only; Deity Transformation after the Tribulation), a season-start rate, and a +19 % QR climb_total cap.
Prior verdict resolved: Partly (C1 and D1 resolved; C9 and the warnings found open and fixed here)
Findings:
- [BLOCKING] Rule 3 / Formulas / AC-CG-07: no rate formula, "plus cultivation-speed bonuses" ambiguous; Formulas I added, multiplicative (fixed)
- [BLOCKING] Open Questions 4: NS and DT pill plot-years 270 / 470 contradicted Formulas D (390 / 680) (fixed)
- [RECOMMENDED] Interactions / Dependencies / Cross-References: stale "no GDD yet" text, missing linh-can and character-stats rows (fixed)
- [RECOMMENDED] Parameter keys: stage_power_step per realm against Character Stats' global key; vitality_floor and tam_ma_natural_decay owned twice (partly fixed; Open Question 11 for Character Stats)
- [RECOMMENDED] Tuning Knobs: climb_total range ignored five-element QR; joint failure_tam_ma_gain / nascent_tam_ma_max constraint missing (fixed)
- [RECOMMENDED] Rule 9 / Edge Cases: breakthrough_succeeded emitters and Deity Transformation timing undefined (fixed)
- [RECOMMENDED] Rule 3 / Edge Cases: curve factor across a stage-group boundary undefined; AC-CG-08a added (fixed)
- [RECOMMENDED] Registry: realm_step_success, breakthrough_success_targets and plot-years not updated for D1 (fixed)
- [RECOMMENDED] Formulas D: W for CF and NS not stated; the last two λ are calibration targets (noted)
- [RECOMMENDED] Small: rule 10 fused sentence, Open Question 6 cite, NS and DT stage groups, base-count wording (fixed)
- [ADVISORY] Player Fantasy section absent (not added; advisory at standard)

Note: the target GDD and design/registry/entities.yaml are deliberately not stamped below, because both were revised after this review; the next /design-review therefore runs in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md dc1b2fb3e6905722ccb342f4cac31d89d5a84fe0
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918

## Review — 2026-11-04 (fifth pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: Full re-review after the fourth pass's fixes. Level costs, attempt chances, supply and success, failure and heart-demon figures, the S_guard series, the migration mapping and the sampled ACs reproduce from the formulas and the registry; no registry conflicts; Spiritual Roots, Character Stats and the Meridian Map list Realms in return. Remaining items are bookkeeping (realm base rates not stated, stale systems-index text, missing cycle entries) and calibration the GDD already marks as bot-run work.
Prior verdict resolved: Yes (2 blockers fixed)
Findings:
- [RECOMMENDED] Formulas I / Parameter keys: realm base rates (10 / 25 / 60 / 150 / 400 in the built data) not stated, though the years-per-realm table depends on them
- [RECOMMENDED] Dependencies: "Systems index change (proposed for Phase 5)" is stale
- [RECOMMENDED] Dependencies: cycles list omits Realms-Character Stats and Realms-Meridian Map
- [RECOMMENDED] Player Fantasy section absent (advisory at standard)
- [RECOMMENDED] AC-CG-33a: "extend to FE and CF after the first run" is open-ended
- [RECOMMENDED] AC-CG-30 to 32 and 54 [Bot]: need per-life lambda and q logging in autoplay.gd
- [RECOMMENDED] Open Question 9: "thirty years" text conflicts with the earlier min_age 25
- [RECOMMENDED] Header status still reads "pending re-review"

Reviewed-Content-Hash: design/gdd/canh-gioi.md 943bb6c6bb9137d909d4cfd212cb7838bb63dcf5
Reviewed-Content-Hash: design/registry/entities.yaml e2cecf0f0cfa507b467ba301a020ac3cd2c8333c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md 3830e428a2190d178cc469a4e377bf4e688f4f68
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918
Reviewed-Content-Hash: assets/data/cultivation_realms.json f1e3a5e060225dab4335aa41029a6a83eadbfbfa

## Review — 2026-11-04 (sixth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: Re-review after the second cross-GDD fix commit and the third cross-GDD review (gdd-cross-review-2026-11-04c.md). Ladder, costs, odds, supply and the 25 owned registry values still reproduce. The three blockers all come from the G1 bonus-ceiling fix: rule 14 computed the lifespan cap without the Character Stats ceiling (B1), a free slot or equipment change could drop the cap below age and kill (NG4), and Formulas D had no term for `alchemy_success`. All three were revised in the same session with user decisions (warn-and-confirm, clamped bonus kept, explicit p_brew term); awaiting re-review.
Prior verdict resolved: Yes (fifth-pass recommendations partly; the new blockers are new)
Findings:
- [BLOCKING] Rule 14: lifespan cap omits the Character Stats lifespan ceiling (cross-review B1) — revised
- [BLOCKING] Rule 14 / Edge Cases: a slot, equipment or main-method change can lower the cap below age with no rule (cross-review NG4) — revised: warn and confirm (AC-CG-62)
- [BLOCKING] Formulas D: no `alchemy_success` term in p_brew though the text and AC-CG-60 rely on it — revised: explicit + alchemy_success/100
- [RECOMMENDED] Tuning Knobs / AC-CG-33a: stale "84 %" and "about 50" after count_gain — revised
- [RECOMMENDED] AC-CG-60: run order after AC-CG-30 — revised
- [RECOMMENDED] Rule 9 / Edge Cases: clamped lifespan at the realm step — revised (kept, re-evaluated; AC-CG-61, 63)
- [RECOMMENDED] Formulas A: "other rate factors 1.25" vs comp 1.225 x tech 0.91-0.98; single-root NS/DT at about 95 % of the ceiling — open
- [RECOMMENDED] Rule 13: crude floor pointer — revised
- [RECOMMENDED] Formulas I: speed_pct "0-about 40" understates five-element totals — open
- [RECOMMENDED] Interactions, Dependencies, Cross-References omit cong-phap.md — revised
- [RECOMMENDED] Fifth-pass carry-overs (base rates, stale index proposal, cycles list, OQ9) — open
Follow-ups outside this GDD: CS rule 13 and AC-CS-52 composed lifespan formula; cong-phap rule 12 pointer to the rule 14 confirmation; registry Formulas E expression.
Note: the canh-gioi hash below is the reviewed (pre-revision) version, so the next check reports CHANGED and runs a full re-review.

Reviewed-Content-Hash: design/gdd/canh-gioi.md c8134aee4af2417cb038527bf61f9c20027ad3a9
Reviewed-Content-Hash: design/registry/entities.yaml e27ff9a65587a587067037081bad5267662d2240
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 2ef1e7f9c5c352cbb51f321812bec83636f51e32
Reviewed-Content-Hash: design/gdd/cong-phap.md d7c65bdee00ca7475b888c8ad72ded32e1802f7b
Reviewed-Content-Hash: design/gdd/linh-can.md c374398023153060a9ebf19d835d2a7a055a9b83
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2484b6a22721d7a3ebae4f9c941fdd197a6ac0f7
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04c.md fde275795589d101ee9b1589da035d2c2f74b16b

## Review — 2026-11-04 (seventh pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Full re-review after the sixth-pass revisions. The three blockers (lifespan cap ceiling, confirm-before-fatal slot change, `alchemy_success` in p_brew) are resolved and consistent with Character Stats and Cultivation Techniques; AC-CG-29, 61 and 62 and the rule 9 / AC-CG-26 case were recomputed and match. All 25 owned registry values reproduce. Remaining items are edge-case completeness and documentation hygiene.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Edge Cases: involuntary lifespan loss (treasure destroyed or stolen, art unusable) has no explicit case (cross-review NG8)
- [RECOMMENDED] Dependencies: stale "Systems index change (proposed for Phase 5)" block; index row 8 already carries it
- [RECOMMENDED] Formulas I: speed_pct "0-about 40" understates five-element totals (N3)
- [RECOMMENDED] Formulas A: "other rate factors 1.25" vs comp 1.225 x tech 0.91-0.98 (I1)
- [RECOMMENDED] Registry: lifespan cap expression (rule 14) has no entry (W11)
- [RECOMMENDED] Open Question 9: ginseng text "thirty" to "forty years"
- [ADVISORY] Player Fantasy section absent (advisory at standard)
Follow-ups: AC-CG-62 clamped-bonus case; duplicate registry keys failure_khi_huyet_loss_pct / _frac.
Note: the Status header and systems-index row were set to Approved before this hash was taken.

Reviewed-Content-Hash: design/gdd/canh-gioi.md 862f0775bcfd3fa9f23ba42fac9e97626f2d07e1
Reviewed-Content-Hash: design/registry/entities.yaml 6c13ff12951f6e07a0026696ed94eea801d06d70
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md e777ab76a33ac9e2cc21bede7abbf4e9f8e1a989
Reviewed-Content-Hash: design/gdd/cong-phap.md 96f7b4ea16884a82b8d49b77affa1b8a7be4f35c
Reviewed-Content-Hash: design/gdd/linh-can.md c374398023153060a9ebf19d835d2a7a055a9b83
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2484b6a22721d7a3ebae4f9c941fdd197a6ac0f7
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md ff571453f374812f6f9f2e2a38eac45a38fb22ca
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04d.md f7ee9ab61ae60ad71faff3d9fd9949fb2facc9f3
Reviewed-Content-Hash: assets/data/cultivation_realms.json f1e3a5e060225dab4335aa41029a6a83eadbfbfa

## Cleanup — 2026-11-04 (no new review)
Applied after the seventh pass: the stale "Systems index change (proposed)" block is replaced by a pointer; the speed_pct bound no longer says "0-about 40"; the pacing note shows how the 1.25 rate factor relates to comprehension 1.225 x technique 0.91-0.98; a new Edge Case covers involuntary lifespan loss (cross-review NG8). No values changed. The lifespan cap expression is now in the registry (W11).

## Revision — 2026-11-04 (after cross-GDD review 04e, no new review)
Applied user decisions for the 04e blockers:
- F1: the CF pill needs three Kim Tuy Qua at min_age 50 (Y 170, calibration kept); new harvest-timing rule min_age <= W/2 at h = 1 (52 / 70 / 140 / 280 by gate), added to AC-CG-58 and OQ4; Tuning Knobs lever moves to the herb count; Formulas D names the four growth influences (Wood affinity, items, techniques, Spirit Fields knowledge under the herb_growth_pct ceiling); Open Question 12 added.
- W-C: #23 burn adds burn_cost to age (rule 18, AC-CG-61 case).
Registry breakthrough_pill_plot_years updated. Data files unchanged (implementation story: ngung_nguyen_dan qty 3 at min_age 50, herb text "fifty years"). Status set to In Review; a re-review decides Approved.

## Revision — 2026-11-04 (after cross-GDD review 04f, no new review)
Applied user decisions for the 04f blockers B2 and B3:
- B2: pill supply is now a discrete brew count B (exact packing of recipe herbs into plots), replacing the linear lambda; W is defined as the lifespan cap at entry minus the age at entry; the harvest-timing rule is replaced by the brew guarantee (a root-free life with 3 plots brews at least 2 at 0.85 W and 3 at W).
- B3: the targets are calibrated at best plot play.
- Lever: the odds lever was chosen over rationing supply. `pill_chance` is 0.06 at every gate, so the baseline q is 0.1225 everywhere, and the recipes are 2 herbs per pill (FE pill 2 ginseng at 40 + 10, CF pill 2 Kim Tuy Qua at 50 + 20, NS 2 at 100 + 40, DT 2 at 200 + 80). Mean S is 0.302 / 0.302 / 0.306 / 0.306; the edge needs 1.4-1.7 gift pills.
- Talisman: at most one per realm step (rule 8, Edge Case, AC-CG-22), no longer in the baseline.
- Character Stats ceilings lowered to 10 / 3 / 15 % so AC-CG-60 holds (0.44-0.46 with the talisman).
- C4 (lever wording), C5 (FE->CF row) and C6 (Dien Tho Dan, Open Question 14) folded in. Formulas C, D, E and H, Parameter keys, Tuning Knobs, AC-CG-19, 20, 22, 25, 29, 30, 32, 50, 58 and 60, and Open Questions 3, 4, 5, 9 and 12 updated. New Open Questions 13 (q extras at low odds), 14 and 15 (step pricing).
Registry realm_step_success, breakthrough_pill_chance, breakthrough_talisman_value, breakthrough_pill_plot_years and bonus_ceiling_target updated. Data files unchanged (implementation story, Open Question 9). Calibration figures are exact expectations from a scratch enumeration script, not a bot run. Status set to In Review; a re-review decides Approved.

## Review — 2026-11-04 (eighth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean; run by a subagent, read-only)
Blocking items: 2 | Recommended: 7
Summary: The 04f restructure (discrete brews B, W defined, best plot play, pill_chance 0.06 at every gate, one talisman per realm step) is coherent, and most Formulas C/D/E/H examples and AC fixtures reproduce. Two modelling errors: Formulas E ties the talisman to a brew rather than a held pill (rule 8), so it is worth +0.08, not +0.05, and the ceiling run is 0.46-0.48, at AC-CG-60's bound; and the calibration W of 280 / 560 at CF and NS contradicts the GDD's own years-per-realm table (W about 340-395 and 650-800), lifting those gates to about 0.38-0.43.
Prior verdict resolved: Partly (04f B1, B2, C2, C4-C6, I3, I4, I6, I7 resolved; B3 except field_plots; F2 partly; F7 deferred; I5 open)
Findings:
- [BLOCKING] Formulas E: talisman term tied to a brew, against rule 8; exact root-free 0.304 not 0.2754; +0.08 on the mean; ceiling run 0.463/0.465/0.479/0.479
- [BLOCKING] Formulas D/E: calibration W at CF and NS inconsistent with the climb table; derive W or report S over its distribution and resize the recipes
- [RECOMMENDED] Talisman spec: assignment control and default, panel line, saved per-step flag (AC-CG-56), #22 q_desp, #23, capability #13, gift pills
- [RECOMMENDED] Best play: B ignores ripening before death, brew time, climb and refill; B_remaining for the Advisor; plant order; NS/DT herb plantability; Dien Tho Dan bot policy
- [RECOMMENDED] Brew guarantee bound is 44/59/119/238, not 44/55/110/220
- [RECOMMENDED] AC-CG-60 omits field_plots (04f B3 residual)
- [RECOMMENDED] Summary lines 18-19 pre-04f framing
- [RECOMMENDED] To Truyen Linh Dien gives 4 brews at QR->FE, not 5
- [RECOMMENDED] Registry breakthrough_success_targets notes stale; revised dates (fixed 2026-11-04 after this review)
User decisions on the blockers (2026-11-04): talisman +5 instead of +10; model entry age, derive W and resize the recipes.
Note: the registry hash below was taken after the revised-date fix, made between the review and this entry.

Reviewed-Content-Hash: design/gdd/canh-gioi.md 95c39d0a40a5f6b40ac59bc8b1a88885f656acdc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/registry/entities.yaml 98f81534bc9142f93b105089d9d6424018851e12
Reviewed-Content-Hash: design/gdd/character-stats.md e5aa42a5613aa8a09e7ee8a827a0b7aae835a123
Reviewed-Content-Hash: design/gdd/linh-can.md 8ed898fd73f7e724822ed0420b16c758dea70bb7
Reviewed-Content-Hash: design/gdd/cong-phap.md 2d89c03010507a70394a12ea31c1e692bcdfa18f
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 8c00f8258e2d5d0e5f009be308d9abfe7b736899

## Revision — 2026-11-04 (after the eighth pass, no new review)
Applied the user decisions on the two eighth-pass blockers and the recommended items:
- Talisman: τ 0.10 → 0.05 (`pha_canh` 5). Formulas E now puts it on a held pill at an attempt (rule 8): F = [(1 − p)^B + k_τ ((1 − pq)^B − (1 − p)^B)] (1 − q)^G, k_τ = (1 − q − τ)/(1 − q). One talisman adds about +0.04 to a gate's mean. Formulas C, AC-CG-19/20/22/29, Tuning Knobs and Parameter keys updated.
- W from an entry-age model (Formulas D): age 16 at QR entry, climb years by element count from Spiritual Roots Formulas B, base lifespans, breakthrough herbs plantable from the realm's entry (now a rule), best-play planting with brew k ready at e + C_k/h, attempts at max(climb done, pill ready, previous + refill), refill from Formulas A scaled by the root's climb (guess), success per attempt q, entry age = first success. New counting rule: brew k counts only if its attempt could start a season before the cap even when every earlier pill failed. W percentiles p10/p50/p90: QR→FE 104 (all), FE→CF 94/120/145, CF→NS 310/345/384, NS→DT 539/641/755.
- Recipes resized to a birth-mix mean of 0.30 ± 0.01 at `pill_chance` 0.06, no talisman: FE pill 2 × 40 + 10 (unchanged), CF pill 2 × 42 + 18 (was 2 × 50 + 20), NS pill 2 × 130 + 40 (was 2 × 100 + 40), DT pill 2 × 230 + 80 (was 2 × 200 + 80). Qty 2 sufficed at every gate. The FE→CF companion moved from 20 to 18: at 20 the means were 0.311 (Kim Tủy Quả 40) and 0.281 (42), and 2 × 42 + 18 gives 0.299 and keeps root-free B 2 at the 10th-percentile W.
- Means 0.301 / 0.299 / 0.303 / 0.302. Per element count: QR→FE 0.26/0.31/0.36/0.41/0.47, FE→CF 0.25/0.31/0.37/0.42/0.47, CF→NS 0.26/0.31/0.36/0.41/0.46, NS→DT 0.25/0.31/0.37/0.43/0.49. Edge G (Đạo Cốt, the starting talisman at QR→FE) 1.47 / 1.33 / 1.58 / 1.43.
- Brew guarantee now checked at W p10 (B ≥ 2) and p50 (B ≥ 3) by exact packing: min_age bound 47 / 46 / 152 / 269.
- Ceiling run (herb 10, alchemy 3, lifespan +15 %, one 5 pp talisman, best plots, field_plots 0): 0.43 / 0.44 / 0.42 / 0.43, inside 0.45. field_plots breaks it (+1 plot 0.50–0.53, 12 plots 0.77–0.84), so it is added to Open Question 13, not capped.
- Talisman spec: preview toggle (default on for the step's first pill attempt), panel line, saved per-step flag (Interactions, AC-CG-56), #22 (q_desp from q without τ; checked against the Meridian Map's E2: lift up to 0.106, new Open Question 16), #23 (no talisman), #13 (a kept talisman still counts as used), gift pills.
- Best play: B_remaining for the Advisor, the bot's plant order, NS/DT herb plantability, Diên Thọ Đan not grown at gates (Open Question 14 stays open). Summary, Tổ Truyền (4 brews at QR→FE), AC-CG-50 fixture wording, λ_market renamed M_market, Formulas F wording, G as an expectation.
- Character Stats follow-ups folded in: the herb_growth_pct / alchemy_success row (rule 12 sources; penalties after the cap), the `bonus_ceiling_target` row, rule 14's lifespan wording.
The figures come from a scratch model with a fixed seed, not a bot run: `C:\Users\xphuo\AppData\Local\Temp\claude\bdbcbe8acdb1cd77\edc05a9b-3e5f-4a6c-8fb1-6a83755713a2\scratchpad\entry.js` (model) and `rev9.js` (results). Data files unchanged (implementation story, Open Question 9). Status set to In Review; a re-review decides Approved.

## Revision — 2026-11-04 (fields as a build, Time factor; no new review)
Applied user decisions made after the eighth-pass revision:
- Fields as a build (user decision). The 0.30 / 0.70 targets and `bonus_ceiling_target` 0.45 assume `field_plots` 0 (base 3 plus Earth's plots). Extra plots from any source (Spirit Farming, Tổ Truyền Linh Điền, the tree, items) are a deliberate build lever that can beat those odds (Pillar 3). Formulas D: new plot-policy bullet; the ceiling paragraph now carries the figures as a build (+1 plot on the ceiling run 0.50–0.53, +2 0.58–0.60, 12 plots 0.77–0.84, 12 plots with no other bonus 0.61–0.70). Formulas E: extra plots added to "what a life can add". AC-CG-30 and AC-CG-60 run at `field_plots` 0; AC-CG-60 says field builds are outside the ceiling target by design. Tuning Knobs `bonus_ceiling_target` row covers lives without extra plots. UI: the Advisor shows what one more plot would add (B and S with +1 plot). Open Question 13: the field_plots part answered; the q-extras part stays open.
- Time's herb-aging root factor: h = (1 + 0.008 · purity_wood) · (1 + herb_age_root_pct / 100) · max(0, 1 + herb_growth_pct / 100), with `herb_age_root_pct` 25 for a holder of the Time (Thời Gian) mutation, else 0. A root term like Wood's, not a sheet modifier and not under the herb growth ceiling. Formulas D formula line, variables table (new row), root-terms list and growth-influences list updated.
- Time figures (entry-age model, `timeX.js` / `timeCF.js` in the scratchpad): root-free at median W, B 3 → 4 at every gate, S 0.217–0.220 → 0.279–0.282; at the 10th-percentile W, B 2 → 3 at FE→CF and NS→DT (0.151 / 0.153 → 0.217 / 0.220), unchanged at CF→NS (3). Birth mix, Time gained at Core Formation: CF→NS 0.303 → 0.360, NS→DT 0.302 → 0.365 (held from Qi Refining: +0.070 / +0.078 / +0.062 / +0.064). Ceiling run with Time from CF: 0.424 → 0.499 at CF→NS, 0.432 → 0.512 at NS→DT, above `bonus_ceiling_target` because the factor is outside the ceilings. Time is not in the birth mix, so the baseline means and Formulas E's table are unchanged; Spiritual Roots owns its frequency.
- Open Question 16 answered (user decision): the Meridian Map's Formulas E2 uses (1 − q − τ) in the #22 guard term when a talisman is on the attempt, so the lift stays at δ_max. Rule 8's #22 sentence and AC-CG-22's #22 line now say q_desp is computed from the attempt's chance without τ using that guard, then τ is added.
- Status line updated. Data files unchanged. A re-review decides Approved.

## Cleanup — 2026-11-04 (cross-GDD review 04g fixes; no new review)
Applied the user-approved mechanical fixes from `gdd-cross-review-2026-11-04g.md`:
- S1 (blocking): Formulas D defines h = 0 (herb growth at −100 % or below): no herb ripens, T_k = ∞ and B = 0, no division performed. h's variable range now includes 0. New Edge Case (Supply group). AC-CG-29 adds `herb_growth_pct` −150 → h 0 → B 0.
- C3: "Growth pays in steps" now exempts the root terms (Wood's purity and Time's herb-aging factor) from the `herb_growth_pct` ceiling, not Wood alone.
- C4: the root-mutations bullet lists Life and Spirit Farming as granting `herb_growth_pct`; Time's old +100 % is dropped in the data pass (Spiritual Roots Open Question 1).
- C11: Formulas H's q_i row says an attempt made counts its q_pill including τ and a held pill counts without τ; leaving τ out keeps S_guard a lower bound.
- C14: the Dependencies row for the Meridian Map says rule 8 consumes Formulas E2's q_desp with τ_a.
- C16: AC-CG-22's #22 sub-bullet reads "the attempt's chance is q_desp + 0.05".
No values changed. Status line unchanged. Data files unchanged.

## Revision — 2026-11-04 (after cross-GDD review 04g; no new review)
Applied the user rulings on 04g F2, F11, F13, F14, F15, F16 and C5:
- F2 (accepted as partial): NS pill 4 × 60 + 10, DT pill 4 × 100 + 80 (were 2 × 130 + 40 and 2 × 230 + 80). Years at a full bar to the third attempt (root-free 3-element, median W): 50 / 47 / 234 / 431 → 50 / 47 / 184 / 371 (48 / 41 / 54 / 57 % of W). Shorter herbs cannot cut further while B is 3 at the median; a fourth brew would need `pill_chance` ≤ 0. Time & Turn owes a one-click "retreat until ripe" (Interactions, Dependencies, UI, new Open Question 18). Brew guarantee bounds 47 / 46 / 82 / 141 (qty 2 / 2 / 4 / 4).
- F13: failure insight, +2 pp per failed pill attempt in a step, cap 4 pp (`failure_insight_pp` 2, `failure_insight_cap` 4); resets on success; #23's extra roll counts as an attempt; bare attempts neither use nor add it (rules 8, 10, 18; Formulas C, E, H; Edge Cases; UI; AC-CG-64). `pill_chance` re-tuned to 0.04 / 0.045 / 0.02 / 0.0225; means 0.299 / 0.302 / 0.298 / 0.301. Per element count: QR→FE 0.25/0.30/0.36/0.42/0.49, FE→CF 0.25/0.31/0.38/0.44/0.50, CF→NS 0.24/0.31/0.38/0.44/0.50, NS→DT 0.23/0.32/0.38/0.45/0.52. Edge G 1.42 / 1.19 / 1.35 / 1.29.
- #23 guard (user decision): Meridian Map E2 q_retry = min(q, (δ_max − ι)/(1 − S)), ι the insight the roll's failure would add; without it the lift reached 0.1009 (CF→NS baseline) and 0.111 (q 0.30); with it 0.097 / 0.092. Formulas H, rule 18, AC-CG-52 (q_retry 0.1255), Open Question 17 (answered). E2's q includes insight, without τ; #22 is exact.
- F14: `q_extras_ceiling_pp` 10 on pill quality + comprehension + Dao heart + tree + item/event bonuses; destiny perks, talisman and insight outside (Formulas C, AC-CG-25, AC-CG-65). Fully built life, no edge: 0.519 / 0.541 / 0.547 / 0.542 (0.76–0.81 uncapped); edge + full build 0.826 / 0.854 / 0.858 / 0.852 (0.94–0.96 uncapped). Open Question 13 answered.
- Ceiling run 0.437 / 0.459 / 0.450 / 0.447, accepted inside AC-CG-60's ≤ 0.48 (user decision); Tuning Knobs and AC-CG-60 say so.
- C5 and F15: root factors (Time) and craft-mutation holders outside `bonus_ceiling_target`; AC-CG-60 runs with Awakening off. Holder ceiling runs: Pill Fire (alchemy 6) 0.450 / 0.473 / 0.464 / 0.461, Lava (alchemy 5) 0.446 / 0.469 / 0.460 / 0.456, Spirit Farming (herb 20) 0.456 / 0.495 / 0.483 / 0.478, with its +2 plots 0.624 / 0.672 / 0.655 / 0.642. Raises do not stack. Time from CF: 0.38 / 0.37 at CF→NS / NS→DT; 0.53 at the ceilings.
- F11: the tree gives no plots at launch values; plots come from mutations, perks, items and Spirit Fields; the bot's calibration runs take no plot node (Formulas D, E, AC-CG-30, AC-CG-60).
- F16: the Advisor's plant plan (Formulas D, UI, AC-CG-66, AC-CG-67): at FE→CF W 94 the plan brews 2 (S 0.140), K-K-C brews 0, C-K-K 1.
- Also updated: Summary, Formulas D W percentiles (94/116/144, 310/342/382, 540/645/767), Formulas E table and new builds table, Parameter keys, Tuning Knobs (new rows, `pill_chance`, talisman and recipe ranges), AC-CG-19/20/22/29/49/50/56/58, Open Questions 4, 5, 9, 15.
Figures from a fixed-seed scratch model (seed 20261104, 20,000 lives per element count), not a bot run, in `C:\Users\xphuo\AppData\Local\Temp\claude\bdbcbe8acdb1cd77\edc05a9b-3e5f-4a6c-8fb1-6a83755713a2\scratchpad\`: `entry2.js` (model), `rev10.js` / `rev10.out` (results), `fix10.js` / `fix10.out` (AC fixtures), `sens10.js` / `sens10.out` (tuning ranges), `g23.js` (#23 lift). Data files unchanged (Open Question 9). Status set to In Review; a re-review decides Approved.

## Revision — 2026-11-04 (Spiritual Roots redesign; no new review)
Aligned to the redesign: curve and Y_climb keyed by n_eff; Time's herb factor and the "What Time's factor does" paragraph removed; craft-mutation holder columns and notes removed from Formulas D and E; AC-CG-60 scope simplified. No target or ceiling value changed. The birth-mix means were computed before innate variants moved 4.3 % of lives up a curve row, so the bot run must re-check them (Spiritual Roots Open Question 1).

## Review — 2026-11-05 — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: XL
Specialists: none
Blocking items: 6 | Recommended: 11
Summary: Independent re-review by a fresh subagent, read-only, of the 110-level ladder and late-gate revision. Player targets hold in the model, and the ladder, costs and points recompute. Blockers were undefined suppression on #22 and #23, tests that contradicted the formulas, and a world headcount that needed an intake rule and edge selection. No bot or game run.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rules 8, 17, 18, Formulas H: heavenly suppression undefined for #22, #23 and a talisman on a #22 attempt
- [BLOCKING] Acceptance Criteria: AC-CG-20, 21, 31 and 47 contradict the formulas or keep 300-level numbers
- [BLOCKING] Formulas E, AC-CG-30: target is a birth-mix mean but the test measures arrivals
- [BLOCKING] Formulas C2: world headcount needs an intake rule that did not exist
- [BLOCKING] Formulas C2: NPC odds overshoot the headcount once edge selection is modelled
- [BLOCKING] Registry, Summary, Open Questions: stale late-gate targets
- [RECOMMENDED] Formulas D: brew guarantee should be 46 / 46 / 82 / 141
- [RECOMMENDED] Formulas E: post-suppression figures low
- [RECOMMENDED] AC-CG-69: windows and seed count
- [RECOMMENDED] Acceptance Criteria: arrival counts expensive at late gates
- [RECOMMENDED] Formulas E, Edge Cases: second starting talisman stated two ways
- [RECOMMENDED] Rule 7: "fewer kills" contradicts Character Stats
- [RECOMMENDED] Open Questions: "data not moved" partly false
- [RECOMMENDED] Game concept: layers 1–13
- [RECOMMENDED] Edge Cases, Saves: migration gaps
- [RECOMMENDED] States and Transitions: no stage-loss row
- [RECOMMENDED] Formulas E: S_bare omits suppression
Resolution: All blockers and the plain-error items were fixed after this review, on the user's instruction, and are NOT yet reviewed. User decisions: intake rule plus re-derived NPC odds, targets stay birth-mix means measured from a gate fixture. New from that work: `edge_full` 1.4, `npc_intake_per_year` 142. Left open: the second starting talisman and the save-migration gaps. The hashes below stamp the files as reviewed, before those fixes, so the next freshness check reports them changed.
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3dbcfde3cc903d285e7ed38d82683627be9c48b4
Reviewed-Content-Hash: design/registry/entities.yaml caa09b94e15419dcb851f36f77d27c89c876be4a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md 4c8abfb95124d01d27bf531dbb5ba14eeac020fb
Reviewed-Content-Hash: design/gdd/character-stats.md 7bf79075658e456d8919f4f22e29fd5484a98646
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 3957524a53436c15089fa33deaeb1a66ea085229
Reviewed-Content-Hash: design/gdd/game-concept.md 548ea01d5cd8dd7c3c864164389a3b388caff094
Reviewed-Content-Hash: design/gdd/systems-index.md 977b2a49f2ae746844dbe750346aa00e24fb00cd
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 749608cd590755a04ab1faed55f585aa16cbebbe
Reviewed-Content-Hash: assets/data/cultivation_realms.json af886e3b0d9dc33e04258d7de906fc71b6e27454

## Revision — 2026-11-05 (NPC odds and world size; no new review)
User decisions after the 2026-11-05 review: NPC arrival means of 1 in 8 / 12 / 15 / 20, player edge odds unchanged, world of 5,000 simulated cultivators, never fewer than 3,000 (was 25,000). `npc.gate_steps` re-derived with edge selection (base 0.12 / 0.075 / 0.05 / 0.0075, `edge_power` 6); `edge_full` and the `p_step_add` exception removed; intake 42.5 a year; Open Question 20 answered. Not yet reviewed.

## Review — 2026-11-05 (second independent review) — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: XL
Specialists: none
Blocking items: 5 | Recommended: 13
Summary: Fresh read-only review. The model reproduces the ladder, points, odds and builds, and the owner's targets are used consistently. Blockers were text and test fixes; none needed a rebalance.
Prior verdict resolved: Partly (bot tests still measured arrivals)
Findings:
- [BLOCKING] AC-CG-60, 40b, 36a: measured arrivals from birth instead of the gate fixture
- [BLOCKING] Meridian Map AC-KMD-50 and the quick spec: retired targets
- [BLOCKING] Rule 3, Formulas I: closed-door cultivation had no rule
- [BLOCKING] Rule 12: "never fewer than 3,000" was not enforced
- [BLOCKING] Registry breakthrough_guard omitted suppression
- [RECOMMENDED] Thirteen items: fixed except plant-plan force-harvest and committing the entry-age tables to the repo
Resolution: Fixed on the user's instruction and NOT yet reviewed. User decisions: closed-door added to the rules; skip another round and build. While building, a world simulation showed an intake set as a share of population drifts to about 6,300, so the world now replaces its dead up to `people.world_cultivators`. The hashes stamp the files as reviewed, before those fixes.
Reviewed-Content-Hash: design/gdd/canh-gioi.md 68261c1ab3ee96bfe30ff4f4f363abeaa6327290
Reviewed-Content-Hash: design/registry/entities.yaml c4290ef42c28e913206d3a13e72840596edd4ce4
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md 0c53e0c0e82c78907a9067fd8e0dc86c50a26626
Reviewed-Content-Hash: design/gdd/character-stats.md 55d9ae80692694927176c65f7603cb63f1cab407
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 8a3b40480be08d1afbaf0686522c57136fbb38ae
Reviewed-Content-Hash: design/gdd/game-concept.md 97d16997e271c1a187365e08392eab74f8ed60e2
Reviewed-Content-Hash: design/gdd/systems-index.md a623e273f1661fa40a9195582b36c8421d95c717
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md e5b628da56a83b2d49faefb5a4bd9ad9db8e494b
Reviewed-Content-Hash: assets/data/cultivation_realms.json af886e3b0d9dc33e04258d7de906fc71b6e27454
