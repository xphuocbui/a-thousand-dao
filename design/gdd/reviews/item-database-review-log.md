# Item Database & Generation: Review Log

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 6 | Recommended: 7
Summary: Math is sound (hand-checked herbs, artifacts, pills, caps, roles, margins) and the registry has zero value conflicts. Blockers are open design decisions and contradictions: the rule 12 risk trigger, the rule 4 action interface, unconfirmed rules 12 and 13, dead-owner item handling, the planted-herb sale gap, and a false bidirectional claim for Combat.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design rule 12: "choice or risk" preview trigger is undefined (OQ 12) and timed pill effects are undefined (OQ 7)
- [BLOCKING] Detailed Design rule 4: action interface and "automatic caller" undefined (OQ 11); AC-ID-37, 38, 40 untestable
- [BLOCKING] Detailed Design rules 12, 13: unconfirmed assumptions (OQ 1); Mạch Ấn "bound to its cluster" conflicts with code (OQ 16)
- [BLOCKING] States / Edge Cases / rule 14: dead owner's items are Lost per States but "the caller moves them" per Edge Cases; no owning system named
- [BLOCKING] Rule 4 vs Edge Cases: every unbound item can be sold, but a planted herb cannot (AC-ID-53)
- [BLOCKING] Dependencies: Combat does not list Item DB (#13); systems-index row for #13 omits the soft Character Stats dependency
- [RECOMMENDED] Acceptance Criteria: AC-ID-71 to 77 and 82 depend on open questions 13 and 14; mark deferred
- [RECOMMENDED] Player Fantasy section absent (advisory at standard)
- [RECOMMENDED] Formulas F: `pill_price_max` 400,000 never binds (max recipe price 40,000); rank-6 pills pass the ladder cap 5 at Nascent Soul
- [RECOMMENDED] Formulas E: example "10 / 35" reads as attack/defence
- [RECOMMENDED] No performance target for per-tick item operations at 200,000 records
- [RECOMMENDED] Rule 16: Mạch Ấn is on no realm whitelist, so events cannot grant seals (Meridian Map OQ 13)
- [RECOMMENDED] Registry names drift: `potency_per_doubling` / `equip_max_slots` vs `per_doubling` / `equip.max_slots`
Reviewed-Content-Hash: design/gdd/item-database.md 5cf8f18fb25328c8f6656d85340ac2faec352b6a
Reviewed-Content-Hash: design/registry/entities.yaml fe930d66a6d40b91770ecfe332b8c11bc489cc8a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 2017d0eaac9940f04149de9616a313f30977083b
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md b8cae5370082854ad69412572d4e3b84cf5f27a9
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/combat.md 90eecf726ff9489b65c0b5f7e75c1a2930dfe23b
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043

## Review — 2026-11-06 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 9
Summary: All six blockers from the first review are resolved: the rule 12 preview trigger, the rule 4 caller behaviour, the confirmed rules 12 and 13, dead-owner handling, the planted-herb sale gap and the Combat dependency row. The remaining items are missing acceptance criteria for the new rule 12 triggers and small contradictions.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Acceptance Criteria: no AC for the rule 12 breakthrough-attempt and over-limit-toxicity previews, or for an ordinary pill showing none
- [RECOMMENDED] Detailed Design rule 12: whether over-limit toxicity is refused or previewed and confirmed is unstated
- [RECOMMENDED] UI Requirements: "its risk or choice" is stale against rule 12
- [RECOMMENDED] Rule 14: a dead owner's planted herb is unspecified
- [RECOMMENDED] Rule 14 / combat.md: no system owns the death transfer; invalid-killer fallback unnamed
- [RECOMMENDED] AC-ID-03 and 53: planted herb contradicts "every unbound item lists sell and give"; giving is untested
- [RECOMMENDED] Open Question 7: timed pill effects still open
- [RECOMMENDED] Quick reference header and systems-index line 170 omit the Character Stats soft dependency
- [RECOMMENDED] Formulas F and H: pill_price_max never binds, rank-6 pills pass the cap, no performance target, Mạch Ấn on no whitelist (carried over)
Reviewed-Content-Hash: design/gdd/item-database.md d5a00386f64b31c8da3e777268254a00d24dcc8e
Reviewed-Content-Hash: design/registry/entities.yaml 464360d88fc691b1b317b8fbb25374ec9a19448b
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 2017d0eaac9940f04149de9616a313f30977083b
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md b8cae5370082854ad69412572d4e3b84cf5f27a9
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/combat.md 22fbc87e3673fe79e6494ffb4c92e824c48f2cfe
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043
