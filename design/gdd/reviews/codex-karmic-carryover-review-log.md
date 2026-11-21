# Review Log — Codex & Karmic Carryover

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, economy-designer; senior: creative-director
Blocking items: 7 | Recommended: 6
Summary: Structure is sound and no standing decision is reopened. Seven gaps make rules unbuildable or contradictory: an heir's birth mode for the gates, the perk-option refund, K_new definition, a playthrough id for death_reloaded, the state table, a realm-less heir cost, and r_max for an heir.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 5/9: an heir has no birth mode, so the Fated/Self-made writing and perk gates cannot be evaluated for heirs.
- [BLOCKING] Formulas B / Edge Cases / AC-CK-17: perk_extra refund contradicts the edge case; options that cannot be filled are charged for.
- [BLOCKING] Formulas A / Edge Cases: K_new counts Lives entries (infinite set) and has no stored counter.
- [BLOCKING] Rule 11: death_reloaded needs a playthrough id on the save and the Lives entry.
- [BLOCKING] States and Transitions / Rule 3: "player ends Continue" is Succession to Ended; Ended is a property of the save.
- [BLOCKING] Formulas B: heir_cost for an heir with no realm is undefined.
- [BLOCKING] Formulas A: whether an heir's inherited realm counts as r_max is undefined.
- [RECOMMENDED] Rule 6: state the rule-9 gate. Formula B: spend <= karma, heir and lineage exclusive.
- [RECOMMENDED] heir_cost[1] equals realm_karma[1]: balance pass.
- [RECOMMENDED] No saving during Succession; quit resumes at its start.
- [RECOMMENDED] AC-CK-15 cannot fail; ACs missing for rules 3, 10 and others; AC numbering; 64 hard-coded vs 4 x rebirth_years.
- [RECOMMENDED] Dedupe an heir who is both child and disciple; recognition pool drops past_ties who died in the gap.
- [RECOMMENDED] Estate dominance of the free Luyện Khí heir: watch in playtest.
Reviewed-Content-Hash: design/gdd/codex-karmic-carryover.md 016bce099f85aede0521c1fda81f8e53499e298f
Reviewed-Content-Hash: design/registry/entities.yaml f14f908c24850946f0af2dc5869480695bff8da4
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f

## Review — 2026-11-21 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean, single-session)
Blocking items: 0 | Recommended: 4
Summary: All seven round-1 blockers are resolved in the text and the registry entries match the GDD. No contradiction or unbuildable rule found; the heir birth mode, perk_extra cap, K_new counter, playthrough_id, states and heir r_max rules are consistent across rules, formulas, edge cases and ACs.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Formulas A: state in one line that realm_karma[r_max] applies only when r_max exceeds the heir's realm at succession (the table text implies it).
- [RECOMMENDED] AC-CK-15 cannot fail as written; add ACs for rule 3 (ended status), rule 5 heir birth mode and rule 6 gate.
- [RECOMMENDED] 64 seasons is hard-coded in AC-CK-06 and Game Feel; write 4 x rebirth_years.
- [RECOMMENDED] Back-links owed in sibling GDDs and the UX spec remain tracked, not blockers.
Reviewed-Content-Hash: design/gdd/codex-karmic-carryover.md 9ec01992e503e7c7d5e0f3a997f49bff2355a47f
Reviewed-Content-Hash: design/registry/entities.yaml 5a0ba7f742789d35294ddcee9ca04a44dc85b514
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/npc-relationships.md f3717045d2eb7c03a16abbbff1dcf85cc038be25
Reviewed-Content-Hash: design/gdd/living-world-tick.md 4cc3d1fcbfc35f661c6381902e5821d6f5450213
Reviewed-Content-Hash: design/gdd/world-generation.md 4e472003f2b0dcd5a7e242c0277c68b9078bf39f
Reviewed-Content-Hash: design/gdd/linh-can.md dd9cc8515c196464f9b3236d9a8874a52a1739f0
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 92bd2d2958a5720cd1427a5398ff89c5c4e1f632
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md 652d088006a6eee6ab7921f506c60190df8a15da
