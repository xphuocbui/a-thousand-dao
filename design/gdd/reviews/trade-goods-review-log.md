# Trade Goods (#45) — Review Log

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 8 | Recommended: 12
Summary: The structure holds and every worked example recomputes, but the formulas broke at their edges: whole-unit floors reset rare goods every season, the D_min plan floor forced tier-6 plans of about 54,000 in empty markets, the scarcity factor jumped at a world share of 0, and the "loop gain 0.105" stability claim ignored the stock carry-over. Holding herbs to age them created value from nothing (about 3–6 × AC-TG-34's limit), and one herb class spanning values 2–3,000 let a single rare sale move every herb's price. All eight were revised in the same session (user decisions: harvested herbs do not age, wild sites give an age mix; raw classes by rarity band; world-share floor; cover damping term).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas A, B, C: whole-unit floors reset rare goods each season; rarity 5–6 never reach Source. Revised: rule 6 remainder carry, B keeps sub-unit value, C uses V_g / 4.
- [BLOCKING] Formulas E, F: p̂ = max(plan, D_min) forced huge plans and a cliff at plan_ref 0; line 486 contradicted line 507. Revised: plan floor φ_p · plan_ref; D_min for price cover only.
- [BLOCKING] Rule 10, Formula J: holding herbs to age them earned 3–6 × the limit; revised recipes needed herbs shelves never sell. Revised: harvested age fixed (user); new Formula K wild age mix.
- [BLOCKING] Rule 8: one herb class spanned V 2–3,000. Revised: rule 8a raw classes by rarity band (8 classes).
- [BLOCKING] Formula D: jump at wsh_g = 0; post-normalisation tail about 3. Revised: wsh_min 0.005 floor, ranges restated; the about 2.66 tail is left to η (Open Question 15).
- [BLOCKING] Formula F: the 0.105 loop-gain stability claim was invalid (second-order loop). Revised: cover damping term λ_c 0.5; claim removed; AC-TG-36 glut check.
- [BLOCKING] Formulas F, G: input fill and craft_in were per class, not per good. Revised: a[c,g], per-good fill, craft draw cd into B.
- [BLOCKING] Acceptance Criteria: misclassified and compound ACs, no AC for rule 16a or the UI panels, no Harness gate level, AC-14 rounding unstated; Dependencies line 573 contradicted its table. Revised: AC-01b, 14b, 22b, 30b/c, 32b/c, 43–50; gate levels; line 573 fixed.
- [RECOMMENDED] Player Fantasy and Tuning Knobs sections absent (advisory at standard).
- [RECOMMENDED] Formula C: hysteresis at the N = 3 / 4 boundary so the specialty label does not flip each season.
- [RECOMMENDED] Formula H: ω_t is 0/0 with no heads; give a fallback split.
- [RECOMMENDED] Formula I: an untagged argmax winner is undefined; potency ties need fixed point.
- [RECOMMENDED] Formula J: bm_raw applied to crafted inputs; Σ V·q = 0 divides by zero; μ ≥ 1 unenforced.
- [RECOMMENDED] Open Question 10: NPC workshops take inputs in kind while the player pays 1.10; decide before the harness run.
- [RECOMMENDED] Formula E: tier-6 artifacts span 20 ×; consider a tier 7.
- [RECOMMENDED] Rule 4: state the ore-to-stone conversion rate for Linh Thạch Khoáng.
- [RECOMMENDED] UI: a reason string on the scarcity line ("rare here vs world").
- [RECOMMENDED] Overview: one worked good → recipe → build chain.
- [RECOMMENDED] Open Question 11 (solved routes) as an advisory AC.
- [RECOMMENDED] Pending amendments to #43, Item Database and Travel & Map (Open Question 14).
Specialist disagreements (creative-director ruling): scarcity strength — typical about 1.4–1.5 × net is perceivable, the tail is the risk, η set in the harness; authored specialties rejected (terrain authors them on the fixed continent), replaced by calibration AC-TG-48; base carry 30 kept as a tuning knob.
Receipt note: the target GDD is not stamped. It was untracked in git and was revised in the same session, so the text this review read cannot be hashed; the next check reads it as NEW, which forces a full re-review.
Reviewed-Content-Hash: design/registry/entities.yaml 8b38ab0baa31f8e0a6f7ae1ec22eaeee5c5b83c8
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 20dbd38130edbfa4372593dcde2292370de1bb38
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 7
Summary: Every worked example and AC figure recomputes and the review-1 fixes hold. One blocker: Formula C's V_g/4 production threshold made the rarest goods (Hóa Thần Quả needs 750 a season) unable to be specialties, contradicting the Edge Cases example and the Catalogue. Revised in session (user: carry-based threshold V_g/16).
Prior verdict resolved: Yes (all 8 review-1 blockers confirmed resolved)
Findings:
- [BLOCKING] Formula C: V_g/4 threshold excluded rare goods. Revised: V_g/16, Edge Cases example 200 a season, AC-TG-07 updated.
- [RECOMMENDED] Rule 10, Formula J: flagship pills need aged herbs shelves never sell; about 100 gathered units per brew at step 2, carry 30. Added Open Question 16.
- [RECOMMENDED] Registry craft_plan note still said "Loop gain 0.105". Fixed.
- [RECOMMENDED] regional-economy-trade.md tuning table bmix row stale (0.5 herb, no pill). Fixed.
- [RECOMMENDED] AC-TG-20: Xích Đồng fill unstated. Fixed.
- [RECOMMENDED] Review-1 carry-overs not applied: Formula C hysteresis, Formula H ω_t 0/0, Formula J Σ V·q = 0 and μ ≥ 1, rule 4 ore-to-stone rate, scarcity reason string, Overview worked chain, Open Question 11 AC.
- [RECOMMENDED] Pending #43, Item Database and Travel & Map amendments (Open Question 14) block AC-TG-43 and AC-TG-06.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: item-database.md changed during the session (parallel edit) and is not stamped; the target, the registry and regional-economy-trade.md were edited in this session after being read, so they are not stamped; the next check reads them as CHANGED and forces a full re-review.
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: Review-2 fixes hold and every worked example and AC figure recomputes. One structural blocker: Formula B drains sub-unit value in proportion with everything else, and #43's steady state keeps only about 27 % of a pool a season (0.4 D of 1.5 D), so a good settles near 0.36 x its inflow; rarity 5-6 goods need about 2.7 x V_g of inflow a season to reach a shelf (Hóa Thần Quả about 8,100 against a specialty bar of 187.5), so AC-TG-34 fails by construction.
Prior verdict resolved: Yes (review-2 blocker, Formula C threshold, confirmed resolved)
Findings:
- [BLOCKING] Formula B / rule 6 / States: proportional drain caps sub-unit carry; rarity 5-6 goods can never be Source or Imported.
- [RECOMMENDED] Rule 10 / Formula J / K / 16a: revised pills need about 170 (best ground) to 1,240 (typical) gathered herbs per brew against a carry of 30; Open Question 16's AC still missing.
- [RECOMMENDED] Formula J: lint prices herbs at min_age 84 but held ages are discrete steps (100).
- [RECOMMENDED] Edge Cases / 16a: capacity enforced on purchases only; gathering, loot, crafting output and storage loss undefined; finished-good shelf contents undefined.
- [RECOMMENDED] Formula G: mu >= 1 contradicts Formula J allowing margin below 1.
- [RECOMMENDED] Registry: scarcity_factor output_range, craft_plan expression and site_yield (rem carry) are stale.
- [RECOMMENDED] Review-1 carry-overs unapplied: Formula C hysteresis, Formula H omega_t 0/0, Formula J sum V q = 0, rule 4 ore-to-stone rate, scarcity reason string, Overview worked chain, Open Question 11 AC.
- [RECOMMENDED] Pending #43, Item Database and Travel & Map amendments (Open Question 14) still block AC-TG-43 and AC-TG-06.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: hashes are of the text reviewed, before the in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md c11be30f0471c167756dd6e8df5291b3e446da2e
Reviewed-Content-Hash: design/registry/entities.yaml eb90a17be4301061b808cfdfa5a708809c987e92
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: Worked examples and AC figures recompute (A, B, D, F, K, most of J). The review-4 shelved-timing fix is consistent with the state table. Two structural blockers in the shelved/fill mechanics and one stale AC figure. Note: no log entry exists for the design-review 4 cited in the Status line.
Prior verdict resolved: Yes for reviews 1-3 blockers; review 4 not in the log
Findings:
- [BLOCKING] Formula B: the shortfall clause makes unshelved goods give up value when shelved goods cannot absorb #43's class-wide draw (e.g. nothing shelved in herb band 3), defeating the exemption; AC-TG-34b contradicts it.
- [BLOCKING] Formulas F, G: "any material of rarity r or more" slots spread over eligible goods and out = plan * min_g fill_g, so one absent or unshelved good (e.g. Tu Kim Sa) zeroes the class output in that market.
- [BLOCKING] Formula J, AC-TG-24: Ngung Nguyen Dan margin is 1.73 by the lint's held-step pricing (inputs 945), not 1.89.
- [RECOMMENDED] Formula B, D: dormant unbuyable value counts in stock, cover and the sf normalisation mean.
- [RECOMMENDED] Formula B: dust rule wipes a good whose inflow stays under 0.01 V_g; contradicts Edge Cases "loses nothing under one unit".
- [RECOMMENDED] Open Question 16: still no AC bounding gathered aged herbs per brew; NPC sourcing unspecified.
- [RECOMMENDED] Registry: craft_plan expression (class-level fill) and craft_margin expression (min_age) stale.
- [RECOMMENDED] Review log lacks the design-review 4 entry; Last Updated is stale.
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC.
- [RECOMMENDED] Pending #43, Item Database, Travel & Map amendments (Open Question 14) block AC-TG-06 and AC-TG-43.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: hashes are of the text reviewed, before any in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md 4e37521e2bf134b2cc1351c83d5acea8f72727c7
Reviewed-Content-Hash: design/registry/entities.yaml 069f57f4f6d76b71ae53a94ae535ad350258f59e
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: Review 6. The three review-5 blockers are resolved (draw capped at shelved value, slot groups, Ngung Nguyen 1.73), and every worked example and AC figure recomputed (A–D, F–H, J, K; AC-TG-04, 10, 12–14, 17–20, 22, 24, 30). The new draw cap breaks flow conservation between markets, and Formula F is only half migrated to the shelved-only draw.
Prior verdict resolved: Yes (review 5's 3 blockers)
Findings:
- [BLOCKING] Formula B: the shared draw cap can leave exports undrawn at the exporter while #43 Formula F still delivers the full Q to the importer (avail_A reads class stock incl. unshelved value): value created from nothing; no conservation AC.
- [RECOMMENDED] Formula F: D_g spreads other demand over all goods by sh, but demand now takes only shelved goods; fill understated, group denominator counts undrawable demand.
- [RECOMMENDED] Formula F: an "any material of rarity r or more" group can span two raw bands; stock_k + S_k needs a per-good k.
- [RECOMMENDED] Formulas F, G: plan windup; a named intermittent input gives out 0 most seasons while plan and craft_in (from plan, not out) keep rising; class likely pinned at P_maxeff (AC-TG-33).
- [RECOMMENDED] Formula B: price, cover and sf mean read stock' = sum X' incl. unshelved value; a class of dormant rare goods looks full with empty shelves.
- [RECOMMENDED] Formula B, Edge Cases: dust rule wipes a good whose market inflow stays under 0.01 V_g (Hoa Than Qua: 30 a season), contradicting "builds up".
- [RECOMMENDED] AC-TG-45: tests purchases only; no AC for gathered, looted or crafted overflow (Edge Cases 16a).
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC, Open Question 16.
- [RECOMMENDED] Housekeeping: Open Question 14 amendments block AC-TG-06/43; registry scarcity_factor omits wsh_min; no review-4 log entry.
Receipt note: hashes are of the text reviewed, before any in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md faf0bf7868944ba17533675a2c8be14b64d158da
Reviewed-Content-Hash: design/registry/entities.yaml 2744cb3ec441ded6172e140fac74078ab0d54cff
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: Review 7. The review-6 blocker is resolved at class level (exports fit inside shelved value), and every worked example and AC figure recomputed (A-D, F, H, J, K; AC-TG-04, 10, 12-14, 18-20, 22, 24, 30, 44, 47). Two per-good accounting gaps remain between Formula B and the import and craft-draw paths.
Prior verdict resolved: Yes (review 6's blocker, at class level)
Findings:
- [BLOCKING] Formula B: exports draw only shelved goods, but imports arrive at the exporter's last-tick shares incl. unshelved goods; per-good value is duplicated/destroyed (class totals balance, so AC-TG-51 passes).
- [BLOCKING] Formulas F, B: fill uses v_g = sh*(stock_k+S_k), B uses X_pre with S_own; for an imported-heavy good cd can exceed X0 and max(0,..) hides value created from nothing.
- [RECOMMENDED] AC-TG-51: "exact (integer ledger)" vs fractional X values; use a tolerance.
- [RECOMMENDED] Formula D: sf_raw reads sh over all goods, normalising weights read shelved stock.
- [RECOMMENDED] Open Question 16: aged-herb recipes feasibility; lint prices held value not acquisition cost.
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC.
- [RECOMMENDED] Pending #43, Item Database, Travel & Map amendments (Open Question 14) block AC-TG-06, 43, 51.
- [RECOMMENDED] No AC for gathered, looted or crafted overflow against carry cap.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard).
- [RECOMMENDED] Doc size and nested design-review notes in Formulas B, D, F.
Receipt note: hashes are of the text reviewed, before any in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md 60ba584f1e812298cceccfca3996eb86d7a9e834
Reviewed-Content-Hash: design/registry/entities.yaml b059508d5af50a0544e03bcd0c6b622d1038f000
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: Review 8. The review-7 fixes hold at class and good level for the import split and v_g, and every worked example and AC figure recomputed (A-D, F-H, J, K; AC-TG-04, 10, 12-14, 17-20, 22, 24, 30, 44). Two per-good accounting gaps remained; both were revised in the same session (user decision: player purchases are served first).
Prior verdict resolved: Yes (review 7's 2 blockers)
Findings:
- [BLOCKING] Formula B: exports were drawn "in proportion to X" while imports were split by ex (X_pre); a hub that imports and re-exports a class moved per-good value in different splits (AC-TG-51 passed at class level). Revised: exports take Exp * ex[g] exactly; AC-TG-51c added.
- [BLOCKING] Formulas B, F: "cd <= v_g so X_pre >= 0" ignored buy_pl; a purchase plus the craft draw could exceed v_g and max(0) hid the overdraw. Revised: player first, buy_pl <= v_g, cd <= v_g - buy_pl, fill measured on v_g - buy_pl; AC-TG-51b extended.
- [RECOMMENDED] Formula F: the no-windup rule lets the plan rise only at fill_c = 1; a sawtooth input leaves the plan ratcheted to the floor, so "the plan resumes" is not guaranteed (use a fill tolerance such as 0.95); AC-TG-33 at risk.
- [RECOMMENDED] Formula D: sf_raw reads sh over all goods, the normaliser reads shelved weights; no AC with unshelved goods.
- [RECOMMENDED] Open Question 16: no AC bounding gathered aged herbs per brew; NPC sourcing unspecified.
- [RECOMMENDED] AC-TG-45 tests purchases only; no AC for gathered, looted or crafted overflow.
- [RECOMMENDED] AC-TG-48 THEN clause is a document edit, not a pass/fail result.
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC, ore-to-stone rate.
- [RECOMMENDED] Pending #43, Item Database, Travel & Map amendments (Open Question 14) block AC-TG-06, 43, 51.
- [RECOMMENDED] Housekeeping: Last Verified stale, run-on Status header, 96 KB size with nested review notes; Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: hashes are of the text reviewed, before the in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md 453509ab037a8c59b843c37432678e3da14079c4
Reviewed-Content-Hash: design/registry/entities.yaml 8bdf74d56f345a5ca5a80788a51e2710a46b7a91
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: design/gdd/travel-map.md 3ac9a764c72ea55b83157af912a45db548806a41

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 10
Summary: Review 9. The review-8 fixes hold for named-good slots, and every worked example and AC figure recomputed (A-D, F-H, J, K; AC-TG-04, 10, 12-14, 17-20, 24, 44). One accounting hole remains in the slot-group path: the group's need spreads by v_g while the fill pools Σ(v_g − buy_pl), so uneven player purchases let cd exceed v_g − buy_pl and the max(0) hides value created from nothing. Revised in the same session (user: revise now, blocker plus recommended 1-3).
Prior verdict resolved: Yes (review 8's 2 blockers, for named goods)
Findings:
- [BLOCKING] Formulas F, B: group need spread by v_g, fill pooled over Σ(v_g − buy_pl); with a player purchase concentrated in one good, cd > v_g − buy_pl and X is clamped from negative (50 created from nothing in the 2-good example); AC-TG-51b covers named goods only.
- [RECOMMENDED] Formula B Output Range: "exports leave shares unchanged" is stale since exports take Exp · ex[g].
- [RECOMMENDED] Edge Cases (holder change), AC-TG-30: stock enters "at the old market's shares"; should be the export shares ex, with the old market losing exactly that per good.
- [RECOMMENDED] Formula F: cd = need · fill_c is ill-defined when one good serves two crafted classes (use Σ_c need[c,g] · fill_c).
- [RECOMMENDED] Formula F: no-windup lets the plan rise only at fill_c = 1 exactly; use a tolerance such as 0.95.
- [RECOMMENDED] Formula D: sf_raw reads sh over all goods, the normaliser reads shelved weights; no AC with unshelved goods.
- [RECOMMENDED] #43 spoilage and s_cap overflow: unstated whether they read stock_sh or ledger stock.
- [RECOMMENDED] Open Question 16 (open since review 2): aged-herb recipes need about 53+ gathered KTQ per brew against carry 30; user decision needed; no AC bounds gathered units per brew.
- [RECOMMENDED] AC-TG-45 tests purchases only (no AC for Edge Cases 16a overflow); AC-TG-48's THEN is a document edit.
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC, ore-to-stone rate.
- [RECOMMENDED] Housekeeping: Last Verified stale, run-on Status header, 98 KB with nested review notes; Open Question 14 amendments block AC-TG-06/43/51; Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: hashes are of the text reviewed, before the in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md 671195023cc51b8822953fb4324c94cccbfc37de
Reviewed-Content-Hash: design/registry/entities.yaml 6534f470eb7bd5d0aedc721271845c5af6af33d6
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: design/gdd/travel-map.md 3ac9a764c72ea55b83157af912a45db548806a41

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 9
Summary: Review 10. Review 9's fix holds for named-only and group-only slots, and every worked example and AC figure recomputed. One conservation gap remains: a good named in one class's recipe and also in another class's slot group can be drawn past v_g − buy_pl (g v 10, h v 1,000: named draw 9.90 + group draw 0.99 = 10.89), and the max(0) hides the value created. Revised in the same session (user: revise now, blocker plus recommended 1-3).
Prior verdict resolved: Yes (review 9's blocker, for single-shape slots)
Findings:
- [BLOCKING] Formula F cd: named slot measured against D_g (incl. group share) and group fill against pooled ΣD_g, with no allowance for the named draw; mixed named+group good overdraws; AC-TG-51b would fail on it.
- [RECOMMENDED] AC-TG-51b says v_g is "300 plus imports"; Formula F's v_g excludes imports (they arrive at step d).
- [RECOMMENDED] Formula G states no group spread rule (a[c,g] static); it lives only in Formula F and AC-TG-21.
- [RECOMMENDED] Formula F no-windup rises only at fill_c exactly 1; use a tolerance such as 0.95.
- [RECOMMENDED] Formula D: sf_raw reads sh over all goods, normaliser reads shelved; no AC with unshelved goods.
- [RECOMMENDED] #43 spoilage and s_cap overflow: stock_sh or ledger stock unstated.
- [RECOMMENDED] Open Question 16 (aged herbs vs carry 30; NPC fields have no GDD); no AC bounds gathered units per brew.
- [RECOMMENDED] AC-TG-45 lacks an Edge Case 16a overflow AC; AC-TG-48's THEN is a document edit.
- [RECOMMENDED] Carry-overs: Formula C hysteresis, Formula H omega_t 0/0, scarcity reason string, Overview worked chain, Open Question 11 AC, ore-to-stone rate.
- [RECOMMENDED] Housekeeping: Last Verified stale, run-on Status header, 100 KB; Open Question 14 amendments block AC-TG-06/43/51; Player Fantasy and Tuning Knobs absent (advisory).
Receipt note: hashes are of the text reviewed, before the in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md 08dc1e66f246f0c210a6ceeedd61ff56bb626a05
Reviewed-Content-Hash: design/registry/entities.yaml 6534f470eb7bd5d0aedc721271845c5af6af33d6
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: design/gdd/travel-map.md 3ac9a764c72ea55b83157af912a45db548806a41
Correction (2026-11-15, same session, user asked to make sure the fix holds): the first review-10 fix (reserve named draws, groups read the residual) failed a random property test, 5,152 of 200,000 markets overdrawn (worst 384; minimal case: groups {g,h} and {g,j}, all v 10, needs 1,000, draw on g 13.3). Replaced by a draw-scale step after fill_c (each class's fill × min over its inputs of min(1, (v_g − buy_pl)/cd_raw)), which holds by construction: 0 of 200,000. The same check found Formula B's avail_A exceeding shelved value when P_eff < 0 made D − craft_in negative (13,248 of 100,000 trials); now max(0, D − craft_in), 0 of 100,000. AC-TG-51 and 51b carry both cases and the random generator.
Tick test (2026-11-15, same session, user request): `tools/design/trade_goods_sim/tick_props.py` runs Formulas B, D, F, G as written over random linked worlds (all 6 market orders) and checks 19 invariants. As written (500 worlds × 40 seasons) it found: D − craft_in unclamped in Formula F's D_g and B's shared draw (negative fill and cd, up to 59,452 created; shared draw negative 1,165×); world sums in processing order (sf differs 2e-16 across orders, AC-TG-11); float rounding X' −7e-15 giving share −1 and NaN sf (22×). Fixed in the GDD (max(0, D − craft_in) everywhere, market-id-order sums, X' floored at 0); with them all 19 invariants pass on 1,500 worlds × 60 seasons. New AC-TG-52 requires the tool to pass.

## Review — 2026-11-15 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 10
Summary: Review 11. Review 10's overdraw fixes are internally consistent: AC-TG-19, 20 and 51b recompute, the draw-scale step holds `cd ≤ v_g − buy_pl` by construction, and `tick_props.py --variant fixed` passes all 19 invariants. No design blocker; the one required item is a stale registry entry (`craft_plan`). Revised in the same session (user: revise now, blocker plus recommended 1-4).
Prior verdict resolved: Yes (review 10's blocker)
Findings:
- [BLOCKING] Registry `craft_plan` expression says `plan' <= plan when fill_c < 1`; Formula F says `< fill_tol` 0.95, and the entry omits the draw scale, the `max(0, D − craft_in)` clamps and the group spread `v_g − buy_pl`.
- [RECOMMENDED] Formula F: `fill_tol` (0.95) is only inline, not in the variables table.
- [RECOMMENDED] Open Question 14 and the #43 amendment list omit review 10's changes (`avail_A` clamp, market-id-order sums, X' floor).
- [RECOMMENDED] Formula F's fill paragraph is one run-on bullet; `cd` is defined twice, before and after the draw scale.
- [RECOMMENDED] Order of `Σ_c` in `cd_raw` not stated fixed (AC-TG-11 and AC-TG-38 need bit-identical).
- [RECOMMENDED] AC-TG-45 has no Edge Case 16a overflow AC; AC-TG-48's THEN is a document edit; Open Question 16 has no AC.
- [RECOMMENDED] Formula C has no hysteresis (label can flip each season); Formula H ω_t has no 0/0 rule.
- [RECOMMENDED] Housekeeping: 105 KB; Status header about 3,000 characters of review history; Player Fantasy and Tuning Knobs absent (advisory at standard).
Receipt note: hashes are of the text reviewed, before the in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md c7d6af500d7a38d8bdd94a7ff93d6cfbf6fbcfc0
Reviewed-Content-Hash: design/registry/entities.yaml 6534f470eb7bd5d0aedc721271845c5af6af33d6
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: design/gdd/travel-map.md 3ac9a764c72ea55b83157af912a45db548806a41

## Review — 2026-11-15 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Review 12. Review 11's blocker (registry craft_plan entry) is resolved; the registry matches the formulas, worked examples and ACs recompute, and tick_props.py --variant fixed passes all 19 invariants. No new design defect; what remains is cross-document debt (#43, Item Database and Travel & Map amendments, Open Question 14) and spec hygiene.
Prior verdict resolved: Yes (review 11's blocker)
Findings:
- [RECOMMENDED] Open Question 14: #43, Item Database and Travel & Map amendments not applied; AC-TG-06, 43, 51, 51c cannot pass against #43 as written.
- [RECOMMENDED] Edge Cases (zero and limits): "sh · stock < V_g" should read end value X' against V_g.
- [RECOMMENDED] AC-TG-51b: six GIVEN branches plus a 200,000-market generator duplicated by AC-TG-52; split.
- [RECOMMENDED] AC-TG-45 lacks an Edge Case 16a overflow AC; AC-TG-48's THEN is a document edit; Open Question 16 has no AC.
- [RECOMMENDED] Formula C no hysteresis; Formula H omega_t no 0/0 rule.
- [RECOMMENDED] Housekeeping: ~4,000-char Status header, 107 KB, line 83 indentation; #43 dependency row says "pending review"; Player Fantasy and Tuning Knobs absent (advisory).
Receipt note: hashes are of the text reviewed; no in-session revision.
Reviewed-Content-Hash: design/gdd/trade-goods.md a454c37c568e2979c81166eab26d9bf57c3adfdf
Reviewed-Content-Hash: design/registry/entities.yaml f8e0e89b2c1fcd9774e1face5f9679e5f49fa6de
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0fe1e85367aae7ff7d863e12c5ebb89536ad2a0c
Reviewed-Content-Hash: design/gdd/item-database.md c42ce0b6726d140f5fcc4ee0edbe6f932bc9fd7f
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Reviewed-Content-Hash: design/gdd/travel-map.md 3ac9a764c72ea55b83157af912a45db548806a41
