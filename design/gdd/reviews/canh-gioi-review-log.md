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
