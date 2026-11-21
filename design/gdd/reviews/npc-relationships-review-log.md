# NPC Relationships — Review Log

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, narrative-director, ux-designer; senior creative-director
Blocking items: 7 | Recommended: 12
Summary: The record model (sparse pair records, pinned/soft kinds, lazy fade, S8b, one hook per kind) is sound; every blocker is a local rule patch. The weak point is the hooks: rule precedences that silently drop betrayal enmity or harden every mourner's enmity, a help call whose cost can raise p_help, and errands that mint money and are unbounded through pinned overflow. Caps decision (user, 2026-11-21): bound what hooks pay out, not how many bonds a person holds.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 11/13: "at once" hardening on a kill of a close tie overrides mourner enmity 50 (S8b order) and escapes inherit_feud_max; AC-NR-16/18/19 contradict
- [BLOCKING] Core Rules 10/12: a weaker new soft kind is dropped, so betrayal of a friend ≥ 70 leaves no enmity; Formula A example (enmity 80, betrayer keeps sư đồ) unreachable
- [BLOCKING] Core Rule 7: eviction can pick a soft part of a pinned record (frees no slot); not atomic on both sides; mourner enmity floods and evicts the killer's soft ties
- [BLOCKING] Rule 15a / Formula F: hook rows "recomputed only when a tie changes" miss master realm/death and đạo lữ location; "same place" undefined; AC-NR-32/33
- [BLOCKING] Rule 15a / Formula F: help_cost ân tình branch raises the sibling's opinion (p_help rises); friend < help_cost case unspecified; no joiner selection rule (AC-NR-35)
- [BLOCKING] Rule 15a / Edge Cases: errands pay 3-10x errand_cost (Quests Formula A), mostly unbacked items; pinned overflow makes disciples unbounded; errand_cost flow (burn or transfer) unnamed
- [BLOCKING] Formula E / AC-NR-28: overflow_pinned not small (~2,000 from elders' disciples), 500 "met" notables and cap_ordinary safe range break the 20,000 target; AC-NR-28 unverifiable
- [RECOMMENDED] UI / News: notice when the player inherits a feud; tie-event news families with slots and a no-LLM check
- [RECOMMENDED] Open Questions 1: minimal origin field per record so inherited feuds keep their cause
- [RECOMMENDED] Rule 15a: b_v teaching waiver makes a master a free technique vendor; state its cost
- [RECOMMENDED] Rule 6: "met the player" needs a stored flag
- [RECOMMENDED] Formula F: re-run NPC census with +13 cultivation from ties against ape5
- [RECOMMENDED] Formula D: "three insults harden" claim fails against fade; retune or reword
- [RECOMMENDED] Formula A: −70 floor wrong (−80 reachable); Grudge/enmity/feud stacking; Δ ≤ 0 new soft kind
- [RECOMMENDED] Formula B: floor + last_season reset freezes frequently touched ties
- [RECOMMENDED] Rule 13 / Edge Cases: define "known" killer; feuds and debts toward the player have no behaviour
- [RECOMMENDED] Acceptance Criteria: AC-NR-12 fixture, AC-NR-24 target, perf reference machine, ~20 missing ACs, gdUnit4 and tests/performance path, rounding, renumbering
- [RECOMMENDED] UI Requirements: hand to a UX spec (gamepad-reachable numbers, errand flow, help-call cost, eviction warning naming the tie, card priority, accessibility labels)
- [RECOMMENDED] Core Rules 2/13: derived đồng môn and lineage, senior disciple as first heir, distinct expelled/left/betrayed news, realm-weighted revenge, rival→friend
Reviewed-Content-Hash: design/gdd/npc-relationships.md 18dab2a8962488c0d5d00a13825bff67be72f886
Reviewed-Content-Hash: design/registry/entities.yaml f0ca9c6905f41a8c1fde57df21b9e495b426de29
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 51f530136f59401c0c91d26a84fff0473cf4a0b8
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md 12990f3b631e3ca399df45e576ddeda3d0ba4e08
Reviewed-Content-Hash: design/gdd/combat.md 3adb15892427ae143f9c2eb393c9a49158d02f57
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: production/plans/world-economy.md 47aaf84d25c41226deac1f6eb9a5d055603a2fef

## Review — 2026-11-21 (re-review) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, narrative-director, ux-designer; senior creative-director
Blocking items: 16 | Recommended: 10
Summary: The model is sound and the revision closed eviction of pinned soft parts, the p_help-raising help cost and the errand stone mint. Still open: rule 11 against the S8b order, set-vs-add between rule 10 and Formula C, fade rounding that freezes touched ties, and Formula E that is not a bound; new hook gaps (errand pricing by disciple realm, unpaid favour with no consequence, rescues that leave no debt, soft-tie starvation under pinned overflow). One user decision: how a help call is paid (CD: favour repaid by a deed, stones optional; no new stone sink).
Prior verdict resolved: Partly (3 of 7 fixed, 3 partly, 1 not)
Findings:
- [BLOCKING] Rules 9/11/13: hardening test after inheritance; mourner enmity downgrades 80; heir double hardening escapes inherit_feud_max; in-step order undefined
- [BLOCKING] Rules 10/14 vs Formula C: replace vs add; repay may fire repay_friend (loan loop to friend 100)
- [BLOCKING] Rule 13 / Formula A: feud plus soft enmity gives −110; registry tie_value range wrong
- [BLOCKING] Formula B: floor + last_season reset freezes fade; "three insults harden" fails
- [BLOCKING] Formulas C/D: zero-strength soft ties stored and unevictable
- [BLOCKING] Formula E: not a bound (N_ord 4,250; met and ex-notables; O_sd ≤ N; killer-side faded enmity never swept)
- [BLOCKING] Rule 7: all-pinned person can never form a soft tie (player starvation); AC-NR-18 unsettled
- [BLOCKING] Rules 8/10: a rescue of a friend leaves no debt
- [BLOCKING] Rule 15a: unpaid favour has no consequence (user decision on payment)
- [BLOCKING] Rule 15a / Formula F: errand cost by disciple realm; non-B outcomes uncapped; no one-per-disciple; profit claim wrong; errand items unregistered faucet
- [BLOCKING] Rule 15a: S2 skips the player, runs before S8b (dead master row lingers), "season close" lags
- [BLOCKING] Rules 14a/15: feuds toward the player have no behaviour
- [BLOCKING] Rule 1 / OQ 1: no stored cause for authored news and cards
- [BLOCKING] UI rules: favour consequence before a call, named eviction victim, inherited-feud notice
- [BLOCKING] Acceptance Criteria: AC-NR-12, 16, 18, 19, 24, 25, 28, 31, 32, 33, 43 wrong or unrunnable
- [BLOCKING] Dependencies: back-links owed (Dialogue, Quests, Tick, Character Stats); last_met_season in World DB
- [RECOMMENDED] Rule 12: end_reason (betrayed, expelled, left, mutual)
- [RECOMMENDED] Rule 13: senior-disciple heir slot; realm-weighted revenge; rival→friend
- [RECOMMENDED] Formula F: name the burns as sinks; register errand items as goods faucet; state what errands are for; b_v waiver cost
- [RECOMMENDED] UI: kin vs blood-feud glyph; numbers on demand; UX spec design/ux/relationships-page.md
- [RECOMMENDED] Acceptance Criteria: missing ACs (notability, mourners outside cap, rule 13 sub-cases, S8b property test); renumbering
- [RECOMMENDED] Hán-Việt glosses (tin đồn, song tu)
Reviewed-Content-Hash: design/gdd/npc-relationships.md 9a80b5fac790a73d31f9b992c6fb879b8b9c5d41
Reviewed-Content-Hash: design/registry/entities.yaml ff654c367788169aea4b062fc7e5935f2d9b8bf0
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 7b1627533426feabf5817e44967e666c15c2e240
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef

## Review — 2026-11-21 (re-review 3, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, narrative-director, ux-designer; senior creative-director
Blocking items: 12 | Recommended: about 25
Summary: The model and every standing decision hold; 4 of the 16 round-2 blockers are fully closed and the rest are narrower. Remaining blockers are local: per-direction enmity/feud storage, betrayal and repay applied in place, the S8b order, heirs outside a kill, who decides a kill is known, the favour call-in (scheduled, B = 0, no slight if unpresentable), causes that must outlive the event log, Formula B reads, errand margin, Formula E numbers, four wrong ACs, and the player-told contract (rule 15c). No new user decision is needed.
Prior verdict resolved: Mostly (round-2 items closed or narrowed; 12 remain)
Findings:
- [BLOCKING] Rules 1/2/10, Formula A: one soft strength cannot hold enmity or a feud held both ways; F3 Grudge + feud stack to −110
- [BLOCKING] Rules 12/14: betrayal and repay remove then re-add at step 3 and can be dropped for lack of room
- [BLOCKING] Rule 9: S8b order contradicts event-log order; verbs "update hook rows at once" contradicts the hook pass
- [BLOCKING] Rule 13: heirs undefined outside a known kill; inherited debt floor vs netting
- [BLOCKING] Rule 13: no producer says a kill is known
- [BLOCKING] Rule 15a: call-in inside event budgets can bring an unearned slight; pays B; "answered" undefined
- [BLOCKING] Rule 1b: cause links outlive no retention; avenged/heaven's-judgement kinds undefined
- [BLOCKING] Formula B: faded unswept part reads shown 0; debt sentence false
- [BLOCKING] Formula F: errand_margin 1.25 returns more than cost when items are used
- [BLOCKING] Formula E: arithmetic (18,750; 22,150; N_ord 4,248), "hard bound" wording, O_kill omits feuds the dead held
- [BLOCKING] AC-NR-21, 25, 31, 50 wrong or unrunnable
- [BLOCKING] Rule 15c / AC-NR-51: help-call chance, favour countdown, verb refusal reason, soft-only slots, eviction and feud-toward-player notices untested
- [RECOMMENDED] player "part ways" verb; gratitude payouts from the Event Engine budget; friend fade speed; lazy met-list eviction; b_v waiver scope; missing ACs; registry additions; glyph and gamepad notes
Reviewed-Content-Hash: design/gdd/npc-relationships.md ceaf1d78ecba30f8be0dc5fcd4d5b56e562504cd
Reviewed-Content-Hash: design/registry/entities.yaml b6a90c2882bd1ccf01f4a23102c79e04792df3c2
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 7b1627533426feabf5817e44967e666c15c2e240
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md 3adb15892427ae143f9c2eb393c9a49158d02f57
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e

## Review — 2026-11-21 (re-review 4, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, narrative-director, ux-designer; senior creative-director
Blocking items: 9 | Recommended: about 25
Summary: The model and every standing decision hold; 6 of round 3's 12 blockers are closed (S8b order, heirs outside a kill, known kills, Formula B, causes, errand_margin number) and 6 are narrower. Remaining blockers are local patches: per-direction enmity not carried into rules 7/10/11/13, in-place betrayal leaving a person over the cap, the favour clock (presentation, answered, unreachable player), avengers/mourners, a feud target slain by a third party, repay and declare-enmity verbs, errand stone payer and the false "never a profit" claim, Formula E and registry stale numbers, and ACs. Three of the errors are stale numbers left by the last revision (25, 0.85, 18,750).
Prior verdict resolved: Partly (6 of 12 closed, 6 narrower)
Findings:
- [BLOCKING] Rules 1/7/10/11/13: per-direction enmity has no record-level strength for eviction, replacement, removal; rules 11/13 remove the other party's enmity
- [BLOCKING] Rule 5 / AC-NR-28/48: in-place betrayal and repay can leave a person over the soft-only cap with no stated exception or add behaviour
- [BLOCKING] Rule 15a / Edge Cases: favour clock contradicts itself for an unreachable player; presentation vs answer intervals; "answered" gameable; slight not in deeds list
- [BLOCKING] Rule 13: avenger status ignores pinned feuds so "a new kill renews it" is unreachable; mourner vs rule 10; outside_cap marker; tie-breaks
- [BLOCKING] Rules 1b/14: a feud target slain by a third party reads as heaven's judgement; tie_end lacks the ending death's payload
- [BLOCKING] Rules 8/14, Formula C: repay and declare-enmity verbs have no delta, gate or cost
- [BLOCKING] Rule 15a / Formula F: errand stone share has no payer; "never a profit" false against market buy markup
- [BLOCKING] Formula E and registry: 18,760 / 22,160 / 12,388; registry hooks 0.85 vs 0.68
- [BLOCKING] Acceptance Criteria: AC-NR-37 (25 vs 20), 30, 31, 50, 51 wrong or ambiguous; missing ACs for per-direction, favour clock, feuds the dead held, over-limit, cause payload after pruning
- [RECOMMENDED] UI help-call bullet vs rule 15c; direction of enmity; notice templates; parted reasons; avenger-loop exit; gratitude payer; heir debt multiplication; hardening on exact strength; integer arithmetic; stip_r floor; player records exempt from met-list eviction; split AC-NR-51
Reviewed-Content-Hash: design/gdd/npc-relationships.md cccfe34537323752a38de9a666555054cfd539a0
Reviewed-Content-Hash: design/registry/entities.yaml 970ee781331363007da95f5a53117b920216c356
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 7b1627533426feabf5817e44967e666c15c2e240
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md 3adb15892427ae143f9c2eb393c9a49158d02f57
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e

## Review — 2026-11-21 (re-review 5, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, narrative-director, ux-designer; senior creative-director
Blocking items: 6 | Recommended: about 20
Summary: The model and every standing decision hold; round 4's blockers are closed. Six local blockers remain: same-season deaths (struck set vs log order), hook rows orphaned when an end removes the record, errand bound labelling and a dead `min` in B_errand, who takes an inherited feud's soft pass, end reasons with no producing rule (`parted`), and the "presented" favour state's deadline. Creative-director overruled the stale-AC-NR-12, AC-NR-06 and AC-NR-52 findings as mostly wording; no further full specialist round is wanted after these land.
Prior verdict resolved: Yes (all 9 round-4 blockers closed; 6 new, local)
Findings:
- [BLOCKING] Rule 13 / Edge Cases: deaths processed one by one lose the feud in a massacre; strike the whole queued dead set first, drop the same-season no-pass rule
- [BLOCKING] Rule 15a hook pass: a record removed at step 1/2 orphans the disciple's `tie` row; reconcile rows by source
- [BLOCKING] Formula F / rule 15a: 1.40 labelled goods but includes stones; commons are raw goods (bulk 1.10 gives 1.08); `min(B_quests, ...)` never binds and its realm is undefined
- [BLOCKING] Rule 13: an inherited feud passes "as soft enmity" with no named takers and no outside-cap rule; AC-NR-20 unrunnable (FX-FAM gives C1 no heirs)
- [BLOCKING] Rules 1b/14, AC-NR-56: `parted` has no producing rule; no reason for a partner's death or a holder dying with no heir; lifespan vs failed breakthrough not distinguished
- [BLOCKING] Rule 15c / UI Requirements: "presented" favour state names a deadline that does not exist until accept; favour block missing from UI Requirements
- [RECOMMENDED] gratitude events do not consume the debt; declare-enmity cooldown; met-list loss exempts the player's records; S8b steps 4/5 log order; notability evictions first; composite eviction tie-break; hundredths everywhere; favour_cost realm; origin payload; refuse-branch preview; avenger minimum; stale Overview line; FX-STUBS gaps; UI AC split; missing ACs
Reviewed-Content-Hash: design/gdd/npc-relationships.md 680c0d6ecf1a87b92b2431f2d15d37940d9c5a8f
Reviewed-Content-Hash: design/registry/entities.yaml e0c1fe5f48205404a2c1daa5645fc35ab06ea52c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 7b1627533426feabf5817e44967e666c15c2e240
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md 3adb15892427ae143f9c2eb393c9a49158d02f57
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e

## Review — 2026-11-21 (re-review 6, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 9 | Recommended: about 15
Summary: The model and every standing decision hold; round 5's six blockers are closed. Nine local blockers remain, all one- or two-line fixes: Edge Cases and AC-NR-54 stale against the struck dead set, the per-target feud count (Edge Cases, AC-NR-48), `favour_owed` orphaned by a `parted` end, end reasons for part-level ends, what `errands_max` counts, the `outside_cap` marker vs rule 1/5, errand items minted not drawn from market stock, met_notable_max safe range (24,660 at 1,000), and soft_reserve vs cap. Creative-director: close with a targeted diff check, no seventh full round.
Prior verdict resolved: Yes (all 6 round-5 blockers closed; 9 new, local)
Findings:
- [BLOCKING] Edge Cases / AC-NR-54: log-order death processing and "passes to no one" stale against the struck dead set
- [BLOCKING] Edge Cases / AC-NR-48: pinned feuds per death is per death per target
- [BLOCKING] Rule 12 / 15a / Edge Cases: favour_owed orphaned when kết nghĩa ends by `parted`/`tie_end`; Edge Case says it cannot happen
- [BLOCKING] Rule 1b table: no reason for Δ-to-0, replaced kind, hardening, netted or cancelled debt; holder and target dying together overlap
- [BLOCKING] Rule 15a / AC-NR-37: errands_max counts sends vs in-flight
- [BLOCKING] Rules 1/5/7: outside_cap marker cleared by another part breaks the cap exceptions and rule 1
- [BLOCKING] Rule 15a / Formula F: errand items "from the market commons" vs a goods faucet; disciple "is paid" vs burned
- [BLOCKING] Formula E: met_notable_max safe 100-1,000 breaks the 23,000 target
- [BLOCKING] Formula E: soft_reserve safe range vs cap_ordinary; cap-3 figure omits O_res
- [RECOMMENDED] call-in fire season and slight write time; slight on a shared friend strength; killing-blow enmity vs step-1 removal; per-target slot lists; hook-pass row index; favour states in the States table; failed or lapsed errand pay; errand stone rounding; AC rewrites (AC-NR-21, 51, 56, 01/11/18/25/29); missing ACs
Reviewed-Content-Hash: design/gdd/npc-relationships.md 8b6ea3b5b40943a13315981dd8c800f9e0404fad
Reviewed-Content-Hash: design/registry/entities.yaml fb903400785030c35e4958f4be0326f2c6a8667c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 7b1627533426feabf5817e44967e666c15c2e240
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md 3adb15892427ae143f9c2eb393c9a49158d02f57
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e

## Review — 2026-11-21 (re-review 7, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 7 | Recommended: about 12
Summary: The model and every standing decision hold; round 6's nine blockers are closed and Formula E / registry arithmetic recomputes clean (systems-designer found no blocker). Seven local blockers remain: an accepted favour abandoned or lost is counted as answered (free clear), pool draws' budgets unsaid, a record holding only `favour_owed` is evicted first, the dead's master has no mourner slot, verb-written records never harden, AC-NR-54's last case, AC-NR-56 missing `replaced`/`cancelled`/same-season precedence. Creative-director overruled the FX-PAIR finding (a GIVEN describes state) and gratitude paying the debt down (declined in rounds 2 and 3).
Prior verdict resolved: Yes (all 9 round-6 blockers closed; 7 new, local)
Findings:
- [BLOCKING] Rule 15a/15c: Quests Failed includes abandon, disposed item, killed target; "answered" must map end states directly (abandon/lapse/drop = slight)
- [BLOCKING] Rule 15b: avenger and gratitude pool draws do not say they count against player_events_per_season_max and the chain budget
- [BLOCKING] Rules 5/6/7: a record holding only favour_owed is soft-only strength 0 and evicted first; it must count as pinned while the flag is set
- [BLOCKING] Rule 13: mourner order omits the dead's master
- [BLOCKING] Rules 9/11: hardening only tests queued changes, so verb-written enmity never hardens
- [BLOCKING] AC-NR-54: last GIVEN names K vs T inconsistently, H's feud unstated, C2 missing from mourners
- [BLOCKING] AC-NR-56: no sub-cases for `replaced`, `cancelled` and same-season target-reason precedence
- [RECOMMENDED] pay favour_cost cancels call-in (needed by blocker 1); repay-deed refusal mapping (needed); cap_notable/inherit_feud_max/mourner_max safe ranges; -70 minimum vs rule 10; line 598 wording; one call-in per season; heirs split debt; sư đồ ending mid-errand; Formula D avenger order; tie-break direction; AC-NR-20 generation; AC-NR-52 sweep wording; p_help fixture stubs
Reviewed-Content-Hash: design/gdd/npc-relationships.md 02841b8ee6d4dabb43dc306e0febf1f4aaf7ca62
Reviewed-Content-Hash: design/registry/entities.yaml 5200e2ca13254929c0152cee18b8404a1638e275
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 8, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 4 | Recommended: about 20
Summary: Round 7's seven blockers are closed; arithmetic recomputes clean (systems-designer: no blocker). Four small local blockers remain: an outside_cap record may be picked as an eviction candidate on the side where it does not count; slot counting across two targets of one death is ambiguous; a call-in can outlive a cleared favour and write a slight to a removed record; the generation count in AC-NR-20 is not derivable from rule 13. Creative-director downgraded the economy sell-back valuation finding to recommended and overruled the rest as polish or redundant; expects APPROVED after a targeted check.
Prior verdict resolved: Yes (all 7 round-7 blockers closed; 4 new, local)
Findings:
- [BLOCKING] Rules 5/7: an outside_cap record must be neither counted nor an eviction candidate on its marked side
- [BLOCKING] Rule 13: slots, struck sets and de-duplication are per target (one part toward each target)
- [BLOCKING] Rules 12/13/15a: death or betrayal must Withdraw any call-in with no slight; a slight never writes to a removed record
- [BLOCKING] Rule 13 / AC-NR-20 / FX-FAM-2: generation is not derivable (kill = 0, each hand-down +1)
- [RECOMMENDED] errand item valuation at base price; AC-NR-21/25/26/43/44/48/50/53/54 hygiene; missing ACs (favour_owed counts as pinned, repay refused, companion hook); shown vs threshold; opinion integer rounding; stale registry notes; Formula D feud-holders-first; -70 floor sentence; hook-pass row index; player kills source
Reviewed-Content-Hash: design/gdd/npc-relationships.md 1f1bf362496dc5fb6d9439a5fb9f0c04d4f03208
Reviewed-Content-Hash: design/registry/entities.yaml 5200e2ca13254929c0152cee18b8404a1638e275
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 9, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 2 | Recommended: about 15
Summary: Round 8's four blockers are closed; every number and registry entry recomputes (systems-designer and economy-designer found no blocker). Two small blockers remain, both wording or fixture only: FX-FAM-2 / AC-NR-20 expect a cause origin naming H, who is alive in the fixture; rule 13's "Who takes it" label reads as covering the pinned feud pass. Creative-director confirmed both, ruled the repay-verb ambiguity a Dialogue (#30) menu detail (back-link), and expects APPROVED next round without a full specialist pass.
Prior verdict resolved: Yes (all 4 round-8 blockers closed; 2 new, wording)
Findings:
- [BLOCKING] FX-FAM-2 / AC-NR-20: origin must name an already-dead first victim W, not the living H; generation 1 stands
- [BLOCKING] Rule 13 "Who takes it": label and "all as soft enmity" read as covering feuds passed as pinned; scope it to an inherited feud
- [RECOMMENDED] stale "errands a season" wording (lines ~357, 751, registry tie_hooks); AC-NR-55 favour record counting and strengths; Formula D debt max; cap_notable safe range; Formula C Δ=0; gratitude gift bound; 1.08 at cost 3; OQ3 metrics (refusal ladder, NPC cultivation stack, favour_cost_mult); favour_cost clears the flag (lines 372, 715); rule 12 scope; 80-byte record label; AC-NR-01 direction; AC-NR-49 seclusion season; FX-PAIR note; AC-NR-28 FX-EV-T bound
- [BACK-LINK] Dialogue: the repay verb lists each open obligation (debt, favour, loan) as its own entry
Reviewed-Content-Hash: design/gdd/npc-relationships.md dbf515539af6c02195d810ae93fd808551d0856d
Reviewed-Content-Hash: design/registry/entities.yaml 5200e2ca13254929c0152cee18b8404a1638e275
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 10, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 7 | Recommended: about 15
Summary: Arithmetic and registry numbers recompute clean (economy: no blocker). Seven small blockers, all one-clause fixes confirmed by the creative-director: a debt inherited by its own debtor or owed by a same-season dead debtor; fractional or zero favour/errand costs; the lost-notability eviction not re-tested at S8b; a queued change naming a person who dies the same season rebuilds an orphan record; a betrayal on a pair holding several pinned kinds is ambiguous; AC-NR-48's last bullet contradicts rule 13's inherited-feud pass; AC-NR-49's seclusion fixture cannot be built.
Prior verdict resolved: Yes (both round-9 blockers closed; 7 new, local)
Findings:
- [BLOCKING] Rule 13 Debts: strike the debtor from a debt's heirs; a debt whose debtor is in the season's dead set is cancelled
- [BLOCKING] Formula F: favour_cost and errand_cost use ceil(stip_r x mult), output range stated at multiplier 1.0
- [BLOCKING] Rule 6: the lost-notability eviction applies only if the person is still not notable when S8b runs
- [BLOCKING] Rule 9: a change naming a person in the season's dead set is dropped; AC-NR-48 gains a no-orphan bullet
- [BLOCKING] Rule 12: betrayal removes every pinned kết nghĩa, đạo lữ and sư đồ the pair holds; AC-NR-17 two-kind case
- [BLOCKING] AC-NR-48 last bullet: soft enmity toward a target is bounded by inherit_feud_max + mourner_max
- [BLOCKING] AC-NR-49: seclusion begins after the join
- [RECOMMENDED] repay-verb clock; Formula D feud-holders-first; kin tie_end; declare-enmity cooldown; outside_cap label; stale registry notes (tie_hooks errands wording, tie_value); FX-FAM notable; AC-NR-20 H/C2; AC-NR-29 fields; missing ACs (soft_reserve load reject, failed errand pays nothing); errand wording "at most" and 1.10 at cost 3; state-table rows 454/456; step-1 adds vs step-3 eviction
Reviewed-Content-Hash: design/gdd/npc-relationships.md c744ea5e85d62994f74a5ff81a61fcee9de78e14
Reviewed-Content-Hash: design/registry/entities.yaml 5200e2ca13254929c0152cee18b8404a1638e275
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 11, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 5 | Recommended: about 20
Summary: Arithmetic and registry numbers recompute clean again; economy found no blocker. Five small blockers, each a one-clause fix confirmed by the creative-director: FX-PAIR holds bonds rule 6 refuses (AC-NR-04/05/17); step-1 deaths have no order; heir order "longest-held / eldest" needs data the record does not store; the favour flag's clearing and a flag-only record's removal conflict; a mid-game cap change contradicts rule 5. The creative-director advises ending the loop after this round and leaving the Recommended list to the single review after all GDDs.
Prior verdict resolved: Yes (all seven round-10 blockers closed; 5 new, local)
Findings:
- [BLOCKING] FX-PAIR / AC-NR-04, 05, 17: GIVEN-line ties are written directly as authored (rule 6)
- [BLOCKING] Rule 9: deaths within step 1 apply in ascending dead-person id
- [BLOCKING] Rule 13 / Formula D / FX-FAM: heir order uses World DB parentage and eldest first, ties by lower id; no formed-season field
- [BLOCKING] Rule 15a: favour flag clears at once on an answer or payment, with its slight on a refusal or unanswered end; a record left with no flag and no part is removed in that change; AC-NR-49 timing
- [BLOCKING] Edge Cases (cap data change): persons are over the limit under rule 5, no unconditional eviction
- [RECOMMENDED] sweep before room test; errands "a season" wording, conservation "at most", cost fixed at send, 1.10 at cost 3; Overview line 36 met list; AC-NR-55 K-at-limit and favour GIVEN; AC-NR-21 slots; AC-NR-52 lazy sweep; AC-NR-25 wording; FX-EV-T kill rate; Formula D feud holders first; float in floor/ceil; state-table gaps; step 3 vs step 1; eviction tie-break; debt heir with no room; friend direction; tie_end on kin/feud; declare-enmity spam (Dialogue's)
Reviewed-Content-Hash: design/gdd/npc-relationships.md 2999006a97ddbbdccf1436579db94578fbab9ee5
Reviewed-Content-Hash: design/registry/entities.yaml 9d51fa4f3e0535eb36cd8f0e57bc06b1842bfb8d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 12, unattended) — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior creative-director
Blocking items: 3 | Recommended: about 20
Summary: Economy and qa-lead found no blocker; arithmetic and registry recompute clean. Three real blockers, all in the favour-clearing text from round 9: the Edge Case says a flag-only record is removed on refusal/lapse while rule 15a keeps it for the slight's enmity (rule 15a lines 381-382 say the same); the end-reason table gives a friend tie lost to a slight as both `replaced` and `faded`; the flag-clear and empty-record test have no fixed point in the step 4/5 split slight. The creative-director asks for one consistent rewrite of the favour-clearing bullet and the Edge Case together. The set_season-on-floor item is Recommended (field definitions settle it), applied as a clause since it is cheap.
Prior verdict resolved: Yes (all five round-11 blockers closed; 3 new, local to favour clearing)
Findings:
- [BLOCKING] Edge Cases / Rule 15a: flag-only record survives a refusal or lapse (slight written in place); removed only on answer, payment or sibling death
- [BLOCKING] End-reason table: friend tie lost to a slight is `faded` only, not `replaced`
- [BLOCKING] Rule 15a: flag clears and empty-record test runs after the slight's last write (step 5 when a remainder exists)
- [RECOMMENDED] Formula C / registry tie_soft_strength: set_season = season_now on inherited and new-part writes (applied, one clause)
- [RECOMMENDED] AC-NR-02 pair notable; FX-FAM-2 free slots; AC-NR-35/38 met list; AC-NR-44 schedule; AC-NR-54 bullets; Summary hook wording; flag-only slight and parted-kind soft-only exceptions; feud_threshold and errand_cost_mult safe ranges; gratitude per-debt cap; heir debt weight; ledger note for errand refund; hook-pass row index
Reviewed-Content-Hash: design/gdd/npc-relationships.md 23cf869fd57a46fc6e98db499af6593bc81895cb
Reviewed-Content-Hash: design/registry/entities.yaml 9d51fa4f3e0535eb36cd8f0e57bc06b1842bfb8d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e

## Review — 2026-11-21 (re-review 13, unattended, round 11) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean, single-session)
Blocking items: 0 | Recommended: 4
Summary: Full read of the GDD against the registry and the round 12 log. Formula E, A, B, C and D arithmetic and examples recompute clean; every AC with numbers was hand-checked (AC-NR-12, 13, 14, 16, 18, 21, 37, 43, 46, 52, 53, 54) and agrees with the rules; the registry values match the GDD; all declared dependencies have GDD files on disk (Realms is canh-gioi.md). The three round-12 favour-clearing fixes read consistently in rule 15a, the Edge Cases, the state table and AC-NR-49. No contradiction or unbuildable rule found. Player Fantasy and Tuning Knobs are advisory at standard. Back-links owed, the NPC-kill share of Formula E / AC-NR-24 and Open Question 7 stay tracked outside this document.
Prior verdict resolved: Yes (all three round-12 blockers closed)
Findings:
- none blocking
- [RECOMMENDED] Formula D: heirs line says "avengers by enmity, strongest first"; rule 13 puts feud holders first (a pinned feud has no strength). Rule 13 governs; align the formula line
- [RECOMMENDED] Registry tie_hooks expression and rule 15a line 358-359 still say errands "a season"; the rule is errands in progress at once
- [RECOMMENDED] AC-NR-46 mourner order among C1, C2 and S relies on the lower-id tie-break with no ids in the fixture
- [RECOMMENDED] Carried from earlier rounds: sweep before room test, cost fixed at send, 1.10 at cost 3, state-table gaps, declare-enmity spam (Dialogue's)
Reviewed-Content-Hash: design/gdd/npc-relationships.md 788ca6f02bd4f10b0340a7ad58a1308db44eb868
Reviewed-Content-Hash: design/registry/entities.yaml dfd77c86944e326b9e90dd81689c4e8f54ec1815
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/quests.md 369b504f4c0dc2d9caa8f1078ceebe80afbbcd92
Reviewed-Content-Hash: design/gdd/sects.md 48007871aaabd485e82d4ce86d71bd00549262b7
Reviewed-Content-Hash: design/gdd/npc-interaction-dialogue.md 4093f27162ad3741b90ee8447536abbaa501b030
Reviewed-Content-Hash: design/gdd/npc-traits.md 0cad429849cd044ad9de1efe792c548966214934
Reviewed-Content-Hash: design/gdd/living-world-tick.md 8a1be00dc176e654533d1a0f9585f2685d9a8eef
Reviewed-Content-Hash: design/gdd/world-generation.md d302345c8b3ba4d4046c43d5f18b90f608adbbf8
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: production/plans/world-economy.md 996ac56259a607288c17f2d8fd8ae927c062486e
Reviewed-Content-Hash: design/gdd/event-engine.md 62fe9099b82171cdc2e4dae98607c369ea0a640e
Reviewed-Content-Hash: design/gdd/power-rankings.md 93a50dbbfa01ba4efdd8ca43b233f327938753a4
Reviewed-Content-Hash: design/gdd/canh-gioi.md 8011250a48b0c53cd1ac4e62856006e703771c8f
