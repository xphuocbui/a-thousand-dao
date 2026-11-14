# Review Log: NPC Traits — Catalogue

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: The content is sound: every F1 row size, the boon and cost tallies and the 20-core-tag rule check out. Two gaps block implementation: the Sects `rebel_odds` pulls (Ambitious or Brave 0.8, Cautious or Content 1.3) are missing from the catalogue's rows, and the catalogue has no testable acceptance criteria beyond the 37 + 6 FX-CAT subset.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Personality sect pulls: Brave, Cautious, Ambitious and Content omit the rebel_odds pull that sects.md:471 reads
- [BLOCKING] Whole file: no testable validation criteria for the 14 callings, 10 fate-given and 16 gained traits
- [RECOMMENDED] F4 variables: b_t range says 1.0; Cruel 0.5 and Arbitrary 0.7 differ
- [RECOMMENDED] Fate-given: root-bound traits (F4) not identified
- [RECOMMENDED] Fate-given: g_f must read the talent before trait rows (feedback)
- [RECOMMENDED] Summary: gained traits also carry sect pulls
- [RECOMMENDED] Fate-given: Wise-born "sought as a disciple" is a perk, not a world price
- [RECOMMENDED] Callings: loose stat fits (Teacher healing, Diplomat health); Alchemist row near-invisible
- [RECOMMENDED] Dependencies: list Event Engine, NPC Builds, World Generation and Talismans as open owners
- [RECOMMENDED] Sect pulls for weariness and attitude speed not verified against Sects F7/F9
Reviewed-Content-Hash: design/gdd/npc-traits-catalogue.md d9ede6746ca270056448ff5d5f60294fce7cf739
Reviewed-Content-Hash: design/registry/entities.yaml 8b69ba1acdd496e1dd852edcdb95bed4ba7903b5
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/npc-traits.md 0c4d53a9f6e09692dd2cf009d11fa65056a07425
Reviewed-Content-Hash: design/gdd/sects.md 3f76acfb0db8cc0c3d97271b03d76426e8082509

## Review — 2026-11-14 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Both blockers from the first review are resolved: rebel_odds pulls are on Brave, Cautious, Ambitious and Content, and AC-NTC-01 to 08 cover every trait kind. The tag-core rule, the boon and cost tallies, the archetype calling weights and the fate-given flaw netting all check out against npc-traits.md, sects.md and modifiers.md. What remains is applying the sect-side rule changes the file itself asks for and tightening the acceptance criteria.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Dependencies: sects.md F15 still says 6 callings and lacks a rebel-odds pull kind
- [RECOMMENDED] F4: npc-traits.md b_t range still reads 1.0; Cruel 0.5 and Arbitrary 0.7 differ
- [RECOMMENDED] Validation: no AC for F15 pull kinds, regard values or b_t range
- [RECOMMENDED] Callings: Alchemist A +0.4 has no unit; alchemy_success is not on the precision grid
- [RECOMMENDED] Personality: seed cells "bold", "never bold; needs halved", "fickle" are shorthand; spell out
- [RECOMMENDED] Edge Cases: no section; target death, full slots and Oath-bound break live only in notes or npc-traits.md
- [RECOMMENDED] Gained notes: "Rule 3 allows two target ids" is loose; each targeted trait stores one id
Reviewed-Content-Hash: design/gdd/npc-traits-catalogue.md 6b45239eb4191d271f3f3a049bc87435aff303f7
Reviewed-Content-Hash: design/registry/entities.yaml 8b69ba1acdd496e1dd852edcdb95bed4ba7903b5
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/npc-traits.md 0c4d53a9f6e09692dd2cf009d11fa65056a07425
Reviewed-Content-Hash: design/gdd/sects.md 3f76acfb0db8cc0c3d97271b03d76426e8082509
Reviewed-Content-Hash: design/gdd/modifiers.md 85585177df4bf77132eba252c9af08ee864632c2
