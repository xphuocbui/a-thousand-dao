# Quests Review Log

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: The budget, fight-ratio and deadline formulas and the worked ACs reproduce exactly, and registry and data-file values match. Three specification gaps block implementation: the stage-window source, the reward effect count against `max_effects_per_outcome`, and an orphan payout that beats the per-season pay bound.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas C vs AC-QS-38/85: `w_i` is "by stage kind" but ACs use windows of 1. Decision: the plan sets it, 1–12, at least `s_i`.
- [BLOCKING] Rule 9 vs `max_effects_per_outcome` 3: a final stage can need more than 3 effects. Decision: final stage up to `quest_final_effects_max` 6.
- [BLOCKING] Rule 10 vs Formulas A: the orphan payout of half the unpaid reward on one stage doubles pay per season. Decision: scale by `s_cur / S_remaining`.
- [RECOMMENDED] Rule 9, AC-QS-18/27: stage pay is exact or a maximum?
- [RECOMMENDED] Rule 2, Rule 10: board quests (removal on accept, payer on orphan, cooldown source) are underspecified.
- [RECOMMENDED] Rule 11: no AC for insight and recipe pricing or rarity; no safe range for `stage_hold`.
- [RECOMMENDED] Dependencies: `thien-kiep.md` does not name `quests.md`.
- [RECOMMENDED] Open Questions: numbering runs 1–6, 8, 7.
- [RECOMMENDED] Open Question 1: plan-level rejection is new Event Engine work; size it.
- [RECOMMENDED] Player Fantasy and Tuning Knobs sections absent (advisory at `standard`).
- [RECOMMENDED] Formulas D: above-cap items have no lifetime bound; the Balance Harness should test about 20 Legendary quests per 2,000-year life.
Reviewed-Content-Hash: design/gdd/quests.md f509c659fc4618fc20f7a52205b0ab89818801d7
Reviewed-Content-Hash: design/registry/entities.yaml 6231bfc51d649f685f723b037c1818b3b77aae03
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 54d78223432601169217b415c55362025e7fc221
Reviewed-Content-Hash: design/gdd/item-database.md 2d8f02625fe8d987513f8170b7ab538d63c16bc6
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b41ee3f9c8eaf8345cb99f0bbdd29d07e0e4232c
Reviewed-Content-Hash: design/gdd/thien-kiep.md 23517d46fccdd02152d05e7e9cd8b948f8686d1f
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-06 (re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 12
Summary: The three prior blockers are resolved and every formula, registry value and worked AC reproduces. Two new gaps were found and revised in the same session: no rule for a stage target (visit person, defeat opponent, deliver recipient) dying, and AC-QS-57 contradicting rule 8's season-end order.
Prior verdict resolved: Yes (3 of 3)
Findings:
- [BLOCKING] Rules 5 and 10: a stage target's death had no rule. Decision: new `if_target_lost` clause (`orphan` default, `skip`, `drop`), chosen by the LLM at plan time and frozen; a target killed by the player, party or sect is Failed. REVISED same day (AC-QS-93 to 97).
- [BLOCKING] AC-QS-57 vs Rule 8: an offerer dying in the deadline season is Orphaned and then Dropped at that season end, never Lapsed. REVISED same day.
- [RECOMMENDED] Rule 9, AC-QS-18/27: stage pay is exact or a maximum (carried).
- [RECOMMENDED] Rules 2, 10: board quests (removal on accept, payer on orphan, cooldown source) (carried).
- [RECOMMENDED] No AC for insight and recipe pricing or rarity; no safe range for `stage_hold` (carried).
- [RECOMMENDED] Dependencies: `thien-kiep.md` does not name `quests.md`; its Open Question 9 is cited but holds no quest mention.
- [RECOMMENDED] Open Questions numbering runs 1-6, 8, 7 (carried).
- [RECOMMENDED] Open Question 1: plan-level rejection is new Event Engine work; size it (carried).
- [RECOMMENDED] Rule 9: a Legendary final stage can want 7+ effects against the cap of 6; say whether a multi-key `quest_boon` is one effect and whether relationship, access and `tu_vi` count.
- [RECOMMENDED] Formulas A: "stage pay always below mission income" fails at `stage_reward_share` 0.4 for Legendary (1.0 `I_r` per season).
- [RECOMMENDED] States: Withdrawn covers only the offerer dying while Offered; a sect or place lost while Offered is undefined.
- [RECOMMENDED] AC-QS-08: FX-P is Qi Refining where Legendary becomes Major; say whether the drawn tier or the converted tier is counted.
- [RECOMMENDED] Formulas D: above-cap items have no lifetime bound; test about 20 Legendary quests per 2,000-year life (carried).
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`).
Note: the target document's hash is deliberately not stamped. It was revised after this review, so the next /design-review must run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 6231bfc51d649f685f723b037c1818b3b77aae03
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 54d78223432601169217b415c55362025e7fc221
Reviewed-Content-Hash: design/gdd/item-database.md 2d8f02625fe8d987513f8170b7ab538d63c16bc6
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b41ee3f9c8eaf8345cb99f0bbdd29d07e0e4232c
Reviewed-Content-Hash: design/gdd/thien-kiep.md 23517d46fccdd02152d05e7e9cd8b948f8686d1f
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
Reviewed-Content-Hash: assets/data/events_budgets.json 33ffea68cbd99d84dfb7278b0518bc1088b24e80

## Review — 2026-11-06 (second re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 12
Summary: Both blockers of the prior re-review are resolved, and every formula, registry value, data-file value and worked AC reproduces. Two new specification gaps were found and revised in the same session: no rule for a source fact after a quest ends (a Completed grievance could be offered again), and Rule 5 `skip` contradicting AC-QS-95 on the skipped stage's pay.
Prior verdict resolved: Yes (2 of 2)
Findings:
- [BLOCKING] Rules 2, 7, Formulas C: the source fact after Completed, Orphaned or Dropped had no rule. Decision: Completed spends the fact; Declined, Lapsed, Orphaned, Dropped 8-season cooldown; Failed 16; Withdrawn none. REVISED same day (AC-QS-47, 98).
- [BLOCKING] Rule 5 `skip` vs AC-QS-95: "stays in the final stage's pay" against "final pay stays 47". Decision: the skipped pay is never paid and does not move; `unpaid` excludes it. REVISED same day (FX-SKIP, AC-QS-95, 99).
- [RECOMMENDED, applied] AC-QS-08 fixture and rule number; AC-QS-95 fixture; AC-QS-30 tier; a lost place on the current stage; orphan payer for a living offerer and for boards; stage pay as a maximum; Formulas A mission-income claim at share 0.4; `stage_hold` vs `deadline_max`; Withdrawn for a lost sect or place; Open Question 1 scope; Open Questions numbering.
- [RECOMMENDED] Rule 9: does a multi-key `quest_boon` count as one effect, and do relationship, access and `tu_vi` count against the cap of 6? (carried)
- [RECOMMENDED] Dependencies: `thien-kiep.md` does not name `quests.md`; its Open Question 9 is cited but holds no quest mention. Item Database and Combat rows still say "not yet reviewed". (carried)
- [RECOMMENDED] No AC for insight and recipe pricing or rarity, the safe range of `stage_hold`, or about 20 Legendary quests per 2,000-year life for the Balance Harness. (carried)
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`).
Note: the target document's hash is deliberately not stamped. It was revised after this review, so the next /design-review must run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 6231bfc51d649f685f723b037c1818b3b77aae03
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 54d78223432601169217b415c55362025e7fc221
Reviewed-Content-Hash: design/gdd/item-database.md 2d8f02625fe8d987513f8170b7ab538d63c16bc6
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b41ee3f9c8eaf8345cb99f0bbdd29d07e0e4232c
Reviewed-Content-Hash: design/gdd/thien-kiep.md 23517d46fccdd02152d05e7e9cd8b948f8686d1f
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
Reviewed-Content-Hash: assets/data/events_budgets.json 33ffea68cbd99d84dfb7278b0518bc1088b24e80
Reviewed-Content-Hash: assets/data/session_actions.json f3fa31939874337902fe77a9306b4ebd8ac02a37

## Review — 2026-11-07 (third re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 9
Summary: Rules 15–18 and Formulas E were reviewed for the first time. Every formula, registry value, data-file value and worked AC (about 40) reproduces. Three specification gaps in the new rules were found and revised in the same session: two formats for world changes, no moment for a `death`, and a benefit test the template fallback could not be guaranteed to pass.
Prior verdict resolved: Yes (2 of 2)
Findings:
- [BLOCKING] Rules 17, 18, 1: `world_effects` and `outcomes` described the same changes twice. Decision: `outcomes` is the one format, rule 17 owns the effect table and limits, `amount_share` is a share of B. REVISED same day.
- [BLOCKING] Rule 17 vs 18: a `death` had no moment (knockout or ending) and no rule if the quest later failed. Decision: it lands at the knockout and always stands. REVISED same day (AC-QS-129, 130).
- [BLOCKING] Rules 15, 4, 18: "benefit" was untestable and an optional `outcomes` list let the template fallback fail rule 15. Decision: structured benefit (a `completed` gain for the offerer's side), person-offer templates must carry one, no offer if a fallback still fails. REVISED same day (AC-QS-131 to 133).
- [RECOMMENDED, applied] Rule 5 `orphan` row; AC-QS-106 "two targets"; degenerate-strategy pay figure by tier; `world_effects_max` counting.
- [RECOMMENDED] Board quests: does the sect head named by the `offerer` role take an attitude change, and who takes `fail_relationship`?
- [RECOMMENDED] Rule 9: does a multi-key `quest_boon` count as one effect, and do relationship, access and `tu_vi` count against the cap of 6? (carried)
- [RECOMMENDED] Dependencies: `thien-kiep.md` does not name `quests.md`, and its Open Question 9 holds no quest mention. Item Database and Combat rows say "not yet reviewed". (carried)
- [RECOMMENDED] Registry: `world_wealth_share`, `world_injury_max`, `adversary_attitude_max`, `quest_final_effects_max`, `stage_hold`, `quest_tu_vi_share`, `fail_relationship`, `orphan_reward_share` are not registered.
- [RECOMMENDED] No AC for insight and recipe pricing or rarity, the safe range of `stage_hold`, or about 20 Legendary quests per 2,000-year life for the Balance Harness. (carried)
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`).
Note: the target document's hash is deliberately not stamped. It was revised after this review, so the next /design-review must run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 951a4c90b2abae3c02275827e2af3f9dbd22a454
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 54d78223432601169217b415c55362025e7fc221
Reviewed-Content-Hash: design/gdd/item-database.md 2d8f02625fe8d987513f8170b7ab538d63c16bc6
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b41ee3f9c8eaf8345cb99f0bbdd29d07e0e4232c
Reviewed-Content-Hash: design/gdd/thien-kiep.md 23517d46fccdd02152d05e7e9cd8b948f8686d1f
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
Reviewed-Content-Hash: assets/data/events_budgets.json 33ffea68cbd99d84dfb7278b0518bc1088b24e80
Reviewed-Content-Hash: assets/data/session_actions.json f3fa31939874337902fe77a9306b4ebd8ac02a37

## Review — 2026-11-07 (fourth review, same day) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 10
Summary: The file changed after the third re-review, so this was a full review. About 45 formulas, worked ACs and registry and data-file values reproduce, and the eight previously unregistered values are now registered. Two specification gaps were found in the newest rules and revised in the same session: sect offerers and adversaries had no resolved root, and the "templates always pass the validator" guarantee could not hold for player-dependent stages.
Prior verdict resolved: Yes (3 of 3)
Findings:
- [BLOCKING] Rules 15, 16, 18, Formulas E, AC-52: a sect offerer or adversary had no root. Decision: offerer root is the speaking member, adversary root is the sect head; AC-52 now has the member take -15. REVISED same day (AC-QS-140, 141).
- [BLOCKING] Rule 4, AC-76: template fallbacks cannot be validated at load for `defeat` and `reach`. Decision: templates may not hold either kind. REVISED same day (AC-QS-142).
- [RECOMMENDED] Player death: do `failed` outcomes and the source-fact cooldown apply?
- [RECOMMENDED] Rule 18: which of `amount`, `amount_share` and a step applies to each effect.
- [RECOMMENDED] Abandoning in stage 1: state that the relationship loss and cooldown still apply.
- [RECOMMENDED] Rule 17 and Combat: `death` fires on any knockout, so the player cannot spare the adversary; confirm.
- [RECOMMENDED] Orphan pay: "the estate" is undefined (Open Question 9).
- [RECOMMENDED] Errand and Ordinary cannot harm an adversary on completion, because the one `completed` entry must be an offerer gain.
- [RECOMMENDED] Board quests: whether a Completed board quest spends its source fact.
- [RECOMMENDED] Formulas A value check is gross of `deliver` and `craft` costs.
- [RECOMMENDED] NPC `wealth` gains have no source.
- [RECOMMENDED] Formulas E `d_root` for sect and board offerers with no relationship reward.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`).
Note: the target document's hash is deliberately not stamped. It was revised after this review, so the next /design-review must run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 72b64e2499131f024c8452c529ea791f9a53fee0
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/item-database.md 4dec0e6d01c6c3c6875dcd55e5f895f4de5018c5
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2aeb95e571aec946efb94cfec4648ce6604c0638
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
Reviewed-Content-Hash: assets/data/events_budgets.json 33ffea68cbd99d84dfb7278b0518bc1088b24e80
Reviewed-Content-Hash: assets/data/session_actions.json f3fa31939874337902fe77a9306b4ebd8ac02a37

## Review — 2026-11-07 (fifth review, same day) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: The file changed after the fourth review, so this was a full review. Both prior blockers (sect roots, template stage kinds) are resolved. Formulas, worked ACs, registry and data-file values reproduce. One new defect: rule 15's offerer-gain entry plus `world_effects_max` 2 for Major left no room for two adversary losses, so the Formulas E example and AC-QS-107, 127 and 141 were unsatisfiable. Revised the same day (Major raised to 3, registry updated), with six recommended clarifications.
Prior verdict resolved: Yes (2 of 2)
Findings:
- [BLOCKING] Rule 15, 17, Formulas E, AC-QS-107/127/141: a Major plan could not hold an offerer gain plus two adversary losses. Decision: `world_effects_max` Major 2 to 3. REVISED same day (AC-QS-144).
- [RECOMMENDED] Rule 4, AC-QS-142: the template guarantee ignored `travel_seasons`. REVISED: `template_travel_max` 4 (AC-QS-143).
- [RECOMMENDED] Player death: `failed` outcomes and cooldown. REVISED (AC-QS-145).
- [RECOMMENDED] Rule 18: which field each effect uses. REVISED (AC-QS-144).
- [RECOMMENDED] Rule 17: the player cannot spare the adversary. REVISED (stated).
- [RECOMMENDED] Rule 10: "the estate" undefined. REVISED (provisional definition).
- [RECOMMENDED] Rule 7: a Completed board quest spends its place fact. REVISED.
- [RECOMMENDED] Formulas A value check is gross; NPC wealth gains have no source. REVISED (noted).
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`). Not changed.
Note: the target document's hash is deliberately not stamped. It was revised after this review, so the next /design-review must run in full. `modifiers.md` already lists Quests, so no bidirectional gap exists there.

## Review — 2026-11-08 (sixth review) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: The file changed after the fifth review, so this was a full review. Formulas A–E, worked examples, ACs, registry values and the data files (`events_budgets.json`, `session_actions.json`) all reproduce, and the fifth-pass blocker and its fixes hold. No new contradiction was found. Approved for its rules; numbers remain guesses (Open Question 3) and the Event Engine, LLM GM and Dialogue contracts remain provisional. The one item to fix next edit is that quest attitude changes (−15, −30, +12) exceed the dialogue clamp `attitude_change_max` 10.
Prior verdict resolved: Yes (1 of 1 blocker, 6 recommendations)
Findings:
- [RECOMMENDED] Rules 10, 16, Formulas D/E: state that quest endings bypass the dialogue clamp `attitude_change_max` 10 (`game_session.gd:979`), or AC-QS-49/107/109 cannot pass.
- [RECOMMENDED] Rule 4, Formulas C: `template_travel_max` is missing from the offer-value table and the registry.
- [RECOMMENDED] States table: the Failed row omits "stage target killed by the player, party or sect".
- [RECOMMENDED] AC-QS-49: "after stage 1" is ambiguous against rule 18; say "during stage 2".
- [RECOMMENDED] Rule 14 table: add `world_effects_max` as a column.
- [RECOMMENDED] AC-QS-142 and 143 overlap; merge them.
- [RECOMMENDED] Rules 16–17: say that at Errand and Ordinary an adversary can only gain on `failed`.
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at `standard`).
Reviewed-Content-Hash: design/gdd/quests.md 1625dc47907e5c0385c331a41ea7538051f90578
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3758b6d694b928dd40d5c44d7808aaf5cbe64a52
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/item-database.md 4dec0e6d01c6c3c6875dcd55e5f895f4de5018c5
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2aeb95e571aec946efb94cfec4648ce6604c0638
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
Reviewed-Content-Hash: assets/data/events_budgets.json 33ffea68cbd99d84dfb7278b0518bc1088b24e80
Reviewed-Content-Hash: assets/data/session_actions.json f3fa31939874337902fe77a9306b4ebd8ac02a37
