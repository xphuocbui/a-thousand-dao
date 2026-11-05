# Review Log: Spiritual Roots (Linh Căn)

Note: the GDD header cites an earlier review on 2026-11-04 (NEEDS REVISION, 3 blockers: RNG order, Awakening alignment, pair-bonus dependency). It was not logged here; this is the first logged entry.

## Review — 2026-11-04 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Numbers, draw order and ACs reproduce and match the data files and the registry; the three blockers cited in the header are fixed. Remaining items are cross-document bookkeeping (Awakening trigger path, Realms consumer entry) and balance work the GDD already flags (retune, fruit frequency, bot run).
Prior verdict resolved: Yes (per GDD header; prior review not logged)
Findings:
- [RECOMMENDED] Dependencies: "No cycles" claim and the Awakening trigger path (Realms `breakthrough_succeeded` via the Meridian Map capability) are not stated; Realms' GDD does not list Spiritual Roots as a consumer
- [RECOMMENDED] Formulas F: "those new pairs give 7/13/19/25 %" is the expected new-mutation chance, not the pair bonus
- [RECOMMENDED] Acceptance Criteria (AC-LC-25) / Open Question 1: nine mutations lack target values; travel speed, alchemy_yield and presence weights are local guesses
- [RECOMMENDED] Core Rules 11 / Open Question 9: Linh Căn Quả has no per-life cap or named owner
- [RECOMMENDED] Core Rules 13: unclear whether NPCs get Mutation Awakening
- [RECOMMENDED] Acceptance Criteria (AC-LC-30): ±0.6 pp over 16,000 draws is about 3.2 SE, below the stated four-SE convention
- [RECOMMENDED] Housekeeping: AC-LC-45 to 47 out of order; saved mutation purities contradict recompute-on-load; registry lacks element_count_curve and root-change parameters, and the generating_pair_bonus entry lacks notes and added

Reviewed-Content-Hash: design/gdd/linh-can.md a229f14f4afcfc2d45c72d42055d1a714c0ea7c3
Reviewed-Content-Hash: design/registry/entities.yaml 0e33010f7fdb8dbb534ca36378b788609dea94ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md fd4adf4dcafa97384ecda6d65b2df4150246e95c
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb

## Review — 2026-11-04 (second) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 10
Summary: Numbers, draw order, the 29-mutation catalogue and the AC-LC-31 chains reproduce from the data files and the registry, and cross-review blocker C1 (Awakening trigger path) is resolved. Two blockers remained: the Awakening figure (61 % after 4 breakthroughs is unreachable; at most 2 passes, at most 43 %) and the Tẩy Tủy Đan quick spec contradicting rule 9. Both were fixed the same day, together with 8 of the recommended items, after user decisions (rare roots meant to win, Self-made convergence accepted, Linh Căn Quả rare by design with no per-life counter).
Prior verdict resolved: Partly (C1 resolved; D5 found and fixed here)
Findings:
- [BLOCKING] Formulas D / Open Question 5: "about 61 % after 4 breakthroughs" is unreachable (Meridian Map rule 16 leaves two passes); corrected to at most 43 %, cap of 2 stated in rule 9 (fixed)
- [BLOCKING] Core Rules 11 / quick spec phu-luc-linh-thu-thanh-tuu.md: Tẩy Tủy Đan "re-checks mutation" contradicted rule 9 (fixed)
- [RECOMMENDED] Formulas C: "no tier dominates" rested on whole-life years only; reworded, Open Question 11 added (fixed)
- [RECOMMENDED] Edge Cases: Self-made convergence recorded as accepted (fixed)
- [RECOMMENDED] Core Rules 11 / Open Question 9: Linh Căn Quả had no cap; now rare by design, frequency owned by Event Engine budgets, both modes (fixed)
- [RECOMMENDED] Formulas F: 7/13/19/25 % are new-mutation chances, not the pair bonus (fixed)
- [RECOMMENDED] Acceptance Criteria: AC-LC-19 mean mutations had no tolerance; AC-LC-30 tolerance was 3.1 SE (fixed)
- [RECOMMENDED] Tuning Knobs: "50–60 W keystone range" not in registry (fixed)
- [RECOMMENDED] Registry: element_count_curve and root-change parameters (fixed)
- [RECOMMENDED] Rule 9 / Edge Cases: Awakening RNG stream, Deity Transformation Tribulation timing, handler order and NPC Awakening unspecified (open)
- [RECOMMENDED] Open Question 1: nine mutations lack target values; travel speed, alchemy_yield, presence and lifespan_pct weights are guesses (open)
- [RECOMMENDED] Stage-group boundary: surplus rescaling across a multi-level season is undefined (Realms-owned, open)

Note: the target GDD and design/registry/entities.yaml are deliberately not stamped below, because both were revised after this review; the next /design-review therefore runs in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md 67204d2eb2bcee0dbd806cd79b930c2c7b093202
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md 5768f5cbf3f675d0cb0078925e30d10feb0c9ff7
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918

## Review — 2026-11-04 (third) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 9
Summary: Full re-review after the second review's fixes. Numbers, draw order, the 29-mutation catalogue, the AC-LC-31 chains and AC-LC-46 purities reproduce from the data files and the registry; no registry conflicts; Realms, Meridian Map and Character Stats list Spiritual Roots in return. Remaining items are specification gaps (RNG stream for Awakening and fruit rolls) and balance work the GDD already tracks as open questions.
Prior verdict resolved: Yes (2 blockers fixed)
Findings:
- [RECOMMENDED] Rules 9 and 11 / Formulas A: RNG stream, handler order and Deity Transformation tribulation timing for Awakening and Linh Căn Quả rolls unspecified
- [RECOMMENDED] AC-LC-19: mean-mutations tolerances say "confirm against the first seeded run"
- [RECOMMENDED] AC-LC-25: expected to fail until Open Question 1; mark pending
- [RECOMMENDED] AC-LC-38: {Wood, Fire} fixture conflicts with the "4 base elements" keystone bullet
- [RECOMMENDED] Cross-References: canh-gioi row says its DT figure "needs correcting" but Open Question 4 is closed
- [RECOMMENDED] Acceptance Criteria: AC-LC-45 to 47 out of order
- [RECOMMENDED] Open Question 11: a five-element root's ~109 W start conflicts with "slow and fragile in Qi Refining"
- [RECOMMENDED] Open Questions 1, 2, 8, 9, 10: retune, bot run, aggregate power cap, fruit frequency, single-root identity still open
- [RECOMMENDED] game-concept.md lines 98 and 172-173: "about 30" mutations and the mutations-count-as-elements question are stale

Reviewed-Content-Hash: design/gdd/linh-can.md 3830e428a2190d178cc469a4e377bf4e688f4f68
Reviewed-Content-Hash: design/registry/entities.yaml e2cecf0f0cfa507b467ba301a020ac3cd2c8333c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md 943bb6c6bb9137d909d4cfd212cb7838bb63dcf5
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md 5768f5cbf3f675d0cb0078925e30d10feb0c9ff7
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918

## Cleanup — 2026-11-04 (no new review)
Applied after cross-GDD review W10 (user decision 2026-11-04): Formulas E prices lifespan years up to the QR ceiling of 18 years, so Time falls from 590 W to 135 W (inside the 150 W band) and Reincarnation from 125 W to 45 W (inside the 100 W band); Life stays at 52 W. The data values (+200 and +50 years) are unchanged and will show as held back until a data pass trims them. The registry note is updated.

## Cleanup — 2026-11-04 (no new review)
Cross-GDD review 04e: W-A (AC-LC-25 and OQ1 no longer list Reincarnation and Time as over band; AC-LC-24 gains the 18-year lifespan pricing fixture) and I-G (Cross-References gains a cong-phap.md row). No values changed.

## Revision — 2026-11-04 (after cross-GDD review 04f, no new review)
B1 follow-on: a mutation's herb_growth_pct now counts under Character Stats' ceiling of 10, so Formulas E prices it up to 10 (0.9 W per %). Life 52 -> 34 W (still over its 30 W band), Spirit Farming 74 -> 29 W (now inside its band), Time 135 -> 54 W (inside its band, but weak for the apex). AC-LC-24 gains a herb growth fixture; AC-LC-25 and Open Question 1 updated (Time needs new power that does not run through a ceiling). Status set to In Review.

## Review — 2026-11-04 (fourth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; run by a subagent, read-only)
Blocking items: 2 | Recommended: 6
Summary: Re-review after the 04f B1 revision. All 29 mutation prices recompute; Life 34, Spirit Farming 29 and Time 54 W are correct and no old prices remain. Two blockers: Formulas E does not price alchemy_success at its ceiling of 3 as it does herb growth and lifespan, and stand-alone pricing ignores that guaranteed ancestors already fill the shared ceilings, so Time adds 0 W and Reincarnation 20 W while AC-LC-25 passes both.
Prior verdict resolved: Yes (third pass APPROVED; four carried recommendations open)
Findings:
- [BLOCKING] Formulas E / AC-LC-24/25 / OQ1: alchemy_success not priced at its ceiling (Lava 22 -> 8.1 W under its floor, Pill Fire 55.5 -> 23.1 W)
- [BLOCKING] Formulas E / AC-LC-25 / rule 8: ceilinged keys priced stand-alone; Time 0 W and Reincarnation 20 W at the margin over their ancestors
- [RECOMMENDED] Registry bien_di_power_band note
- [RECOMMENDED] Player Fantasy: craft-mutation growth and alchemy lines largely redundant under shared ceilings; give Time power outside the ceilings
- [RECOMMENDED] OQ6 and character-stats line 1131 stale cross-status wording
- [RECOMMENDED] OQ11 recompute after the OQ1 retune
- [RECOMMENDED] Carried: Awakening and fruit RNG stream; AC-LC-19; AC-LC-38 fixture; canh-gioi Cross-References row; AC-LC-45 to 47 order
- [RECOMMENDED] OQ2, 8, 9, 10 open as tracked
User decision (2026-11-04): price every ceilinged key at what the ceiling lets through, marginal over guaranteed ancestors.

Reviewed-Content-Hash: design/gdd/linh-can.md 8ed898fd73f7e724822ed0420b16c758dea70bb7
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/registry/entities.yaml 98f81534bc9142f93b105089d9d6424018851e12
Reviewed-Content-Hash: design/gdd/character-stats.md e5aa42a5613aa8a09e7ee8a827a0b7aae835a123
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 8c00f8258e2d5d0e5f009be308d9abfe7b736899

## Revision — 2026-11-04 (after the fourth pass, no new review)
Implements the user decision on both blockers. Formulas E now has one general rule: every key under a Character Stats rule 14 ceiling (`herb_growth_pct` 10, `alchemy_success` 3, lifespan years 18 at QR) is priced at w_k · max(0, min(a_k + v_k, c_k) − min(a_k, c_k)), where a_k sums key k over the mutation's guaranteed ancestors (its mutation parents, recursively; formation needs them and rule 12 means they are never lost). This extends W10 and 04f B1 and adds alchemy. New prices: Lava 22 -> 8.1 W (under its 10 W floor), Pill Fire 55.5 -> 23.1 W (in band), Spirit Farming 29 -> 20 W (in band, plots only), Reincarnation 45 -> 20 W (under its 30 W floor), Time 54 -> 0 W (under its 50 W floor), Life 34 W (unchanged, over). No other mutation carries a ceilinged key, so no other price moves.
Other changes: rule 8 notes the floor fails for Lava, Death, Reincarnation and Time; Formulas E table, prose (names Time and Reincarnation, drops "lose about a fifth", notes lifespan ceiling grows after QR) and examples rewritten; AC-LC-24 gains hard-coded fixture ceilings, alchemy +8 -> 8.1 W and marginal fixtures (ancestor at ceiling -> 0 W; +50 over +10 years -> 20 W); AC-LC-25 lists over: Life, Array, Stars, Refined Metal, Taiji and under: Lava, Death, Reincarnation, Time, expected to fail until OQ1; OQ1 retune list updated with three undecided options for Time's power (cultivation/breakthrough line, unique rule effect, bounded lifespan_pct blocked on CS OQ7); OQ6 reworded without status claims; OQ11 notes the ~109 W recompute; new OQ12 (Linh Căn Quả and Awakening RNG stream and draw order); AC-LC-19 concrete tolerance check; AC-LC-38 keystone fixture matches the 4-vs-5 rule; canh-gioi Cross-References row updated (OQ4 closed); AC-LC-45 to 47 moved after AC-LC-44 unchanged. Status set to In Review.

## Revision — 2026-11-04 (Time's new power; no new review)
Implements the user decision on Time (Thời Gian), the order-4 apex: its power comes from outside the character-wide ceilings. Design effects: `cultivation_speed_pct` +40 at 2.2 W per % = 88 W, plus a new root factor `herb_age_root_pct` +25 (effect kind "root", ×1.25 on herb aging h, like Wood's root term; not a sheet modifier and not under the herb growth ceiling) priced in full at 0.9 W per % = 22.5 W. Total 110.5 W, inside the order-4 band 50–150 W (was 0 W under the marginal rule, 54 W before it). Its old +100 % `herb_growth_pct` and +200 `lifespan_years` add 0 W over its ancestors and are dropped in the data pass; the data file holds them until then. Character Stats Formulas G and Realms Formulas D take `h = (1 + 0.008 · purity_wood) · (1 + herb_age_root_pct/100) · max(0, 1 + herb_growth_pct/100)` (edited in those GDDs, not here).
Changes: status line; rule 8 (Time no longer a dud; Lava, Death, Reincarnation remain); Formulas E gains the general rule that a declared root factor is not a ceilinged key and is priced in full, w_k row lists `cultivation_speed_pct` 2.2 and `herb_age_root_pct` 0.9, table moves Time to "within band" at 110.5 W, prose and example rewritten; Parameter keys add the "root" effect kind; Tuning Knobs add Time's root factor (safe 0–68 to keep Time in band); AC-LC-24 adds a root-factor fixture (+25 -> 22.5 W, +40 cultivation speed -> 110.5 W); AC-LC-25 drops Time from the under-floor list (still fails on today's data until the data pass); OQ1 records Time as decided and lists its data pass, other retunes stay open; OQ11 notes the ~109 W recompute must use Time's new price.

## Cleanup — 2026-11-04 (cross-GDD review 04g fixes; no new review)
Applied the user-approved wording fixes from `gdd-cross-review-2026-11-04g.md`:
- C9: the Tuning Knobs row for `herb_age_root_pct` notes that Character Stats Formulas G and Realms Formulas D (h) read it, and that the registry entry `herb_age_root_pct` exists.
- C12: Formulas E Output Range no longer says a drawback on a ceilinged key needs its own rule; a negative value on a ceilinged key is priced in full (w_k · v_k, negative), because Character Stats applies penalties after the cap (its rule 14).
- C15: Cross-References name Character Stats rule 14 (the ceilings, the root-term test, penalties after the cap), which Formulas E prices against, and Realms Formulas D's h.
No tuned values changed.

## Revision — 2026-11-04 (after cross-GDD review 04g; no new review)
Implements the user rulings on F15 (holder-raised ceilings) and F11 (plot price) from `gdd-cross-review-2026-11-04g.md`.
- F15: a craft mutation may raise one character-wide ceiling for its holder (effect kind "ceiling_raise", key and value; Character Stats rule 14; raises on one key do not stack, and the highest applies). The decided raises are Pill Fire `alchemy_success` 3 -> 6 and Spirit Farming `herb_growth_pct` 10 -> 20.
- Formulas E prices a raise as headroom, in full: w_k · (c'_k − c_k), where c_k is the base ceiling or the highest raise among the guaranteed ancestors, so the raise is marginal over them. The mutation's own line is priced against c_k, the ceiling without its own raise.
- Double-count check: pricing the line against c'_k and the raise in full pays twice for the band the line fills (Pill Fire would be 39.3 W against 31.2 W delivered). The equivalent correct form prices the line against c'_k and the raise only for the part of (c_k, c'_k] that the line leaves empty. Both forms are stated.
- F11: `field_plots` is weighted 20 W per plot (Meridian Map Formulas F; was 10).
- Reprices:
  - Pill Fire 23.1 -> 31.2 W (in band);
  - Spirit Farming 20 -> 49 W (in band at order 2, so no plot trim is needed; it would need one only if plots pass 25 W);
  - Space 40 -> 50 W (its +1 plot; in band).
- Lava: a raise of 3 -> 5 is proposed, 8.1 -> 13.5 W, which clears its floor. It is marked "proposed, user to confirm in the data pass" (OQ1), and it needs Character Stats' "craft mutation" wording widened, since Lava is "stable".

Changes:
- Status line.
- Rule 8: the raises are described, and Lava's proposal noted; Lava, Death and Reincarnation remain floor-breakers.
- Formulas E:
  - the formula gains the raise term and the definitions of c_k and c'_k;
  - a new paragraph gives the raise pricing and the double-count rule;
  - the variables gain base_k, r_k, c_k, c'_k and the `field_plots` weight;
  - the Output Range bounds the raise term;
  - the band table, prose and held-back list are updated;
  - a holder-raised example is added.
- Parameter keys: the "ceiling_raise" effect kind and the data-pass raises.
- Dependencies: Character Stats takes the raises.
- Tuning Knobs: a new raises row (safe Pill Fire 4–16, Spirit Farming 11–32, Lava 4–11).
- AC-LC-24: a 20 W plot fixture and seven raise fixtures (16.2 W not 24.3 W; unfilled headroom; raise-only 9 W; marginal over an ancestor's line or raise; non-ancestor raise ignored; equivalence; 31.2 W).
- AC-LC-25: updated prices, and the pre-data-pass prices (Pill Fire 23.1 W, Spirit Farming 40 W).
- OQ1: the raises are decided, the Lava proposal recorded, and the held-back trims updated.

## Cleanup — 2026-11-04 (user decisions after cross-GDD review 04g; no new review)
User decision 2026-11-04: Lava's `alchemy_success` raise 3 → 5 is confirmed. "Proposed, user to confirm" is removed everywhere (rule 8, Formulas E variables, output range, band table, margin notes and held-back list, Parameter keys, Tuning Knobs, AC-LC-25, OQ1). Lava prices at 13.5 W, inside its order-1 band, so it leaves the under-floor lists in rule 8, AC-LC-25 and OQ1 (it moves to the within-band column of the band table); AC-LC-25 and OQ1 note that before the data pass adds the raise, Lava still prices at 8.1 W and fails its floor. Rule 8 now says "a mutation may raise…", and OQ1 records that Character Stats rule 14 now says "a mutation", which resolves the conflict it noted. The tree-gives-no-plots note was not added: this GDD does not name the tree as a plot source. No tuned values changed. Status unchanged.

## Redesign — 2026-11-04 (no new review)
User-directed rebuild of the GDD (/design-system): five elements plus eight flat variant roots (three origins: convergence, transmutation, innate); 22 mutations moved to the new system 39, the Way (Đạo); variants get purity-scaled roles and hidden Meridian Map sectors; innate variants count toward the curve (n_eff); Self-made picks stay free, declined variants never roll. Formulas by systems-designer, AC-LC-01..51 by qa-lead. Earlier verdicts in this log apply to the pre-redesign text (git b7f4639). Needs /design-review in a fresh session.

## Review — 2026-11-04 (first review of the redesign) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: First review of the redesign (five elements + eight variant roots; 22 mutations moved to the Way). Every worked chance, purity, price, birth rate, draw count and AC stub sequence recomputes; registry values match. Open work is cross-system: Meridian Map variant sectors, the Wind and Void weights, the Way.
Prior verdict resolved: Yes (earlier verdicts applied to the pre-redesign text, git b7f4639)
Findings:
- [RECOMMENDED] Rule 12 / AC-LC-33, 34: variant sectors are a contract only; Meridian Map Open Question 15, capability #24 price
- [RECOMMENDED] Cross-References and Dependencies: stale "pending cross-edit" wording (fixed in this session)
- [RECOMMENDED] character-stats Formulas G example still named Time (fixed in this session)
- [RECOMMENDED] Formulas E: Chaos breakthrough_chance is under Realms' 10 pp q-extras ceiling but the section says every variant key is unceilinged
- [RECOMMENDED] Wind and Void priced on a guessed 0.3 W per point weight (Open Question 2)
- [RECOMMENDED] Formulas A / AC-LC-01: count roll used a closed upper bound, variant rolls use u < chance (fixed: half-open, AC boundary values moved off exact floats)
- [RECOMMENDED] Light reach 27.8 vs 27.9 and registry rule number (fixed in this session)
- [RECOMMENDED] Data files still hold pre-redesign shape (bien_di); AC-LC-18 and 19 fail until the data pass (Open Question 10)
Reviewed-Content-Hash: design/gdd/linh-can.md 4115275a964b926f75e75810cff982794c9cbce0
Reviewed-Content-Hash: design/registry/entities.yaml 3884819fdaf07f174f31d15ba4b6f76a56b792ca
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 7bf79075658e456d8919f4f22e29fd5484a98646
Reviewed-Content-Hash: design/gdd/canh-gioi.md 9f1acabdc4d0b501c48438e00c4c2160931d1e72
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md e2e932ec476590295cbb93e626b21b7bc81da0b5
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/game-concept.md 548ea01d5cd8dd7c3c864164389a3b388caff094
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md d4103af24fb601354c8c46232e355e0a16561a87
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb
Reviewed-Content-Hash: design/gdd/systems-index.md cadcaa85edb93b547f543c2f23d3a6c9cb0e035f

## Review — 2026-11-05 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Lean re-review after the Meridian Map variant sectors (its rule 20, Formulas H2–H4) landed. Recomputed with no discrepancy: the AC-LC-01, 04, 05, 06 draw sequences, every worked chance and purity (AC-LC-20, 21, 38, 40, 41, 43, 49, 50), the birth rates, the power table including Chaos at 44, 50, 80 and 100, the sheet lines of AC-LC-29, and the sector scales shared with Meridian Map AC-KMD-73 and 86. Registry matches. Rule 12, the edge cases and AC-LC-33/34 agree with Meridian Map rule 20.
Prior verdict resolved: Yes (the 2026-11-04 recommended items are applied or tracked; Open Question 4 closed)
Findings:
- [RECOMMENDED] Dependencies, bidirectional check: stale statements about the Meridian Map's variant sectors and a Time example in Character Stats (fixed in this session)
- [RECOMMENDED] Cross-References, Character Stats row: stale "Still open" Time example (fixed in this session)
- [RECOMMENDED] Formulas E: the 10–30 W band prices the role line only; the Meridian sector adds about 88.5 W unscaled (about 103 W with the role at purity 50), so say so and link Meridian H3
- [RECOMMENDED] Formulas A / Edge Cases "Saves" / AC-LC-04 vs AC-LC-50: the rolled set excludes Void on a 3-element birth but the no-rolled-set load marks every innate variant; state the difference
- [RECOMMENDED] Formulas E opening line: "all variant keys are unceilinged" holds for Character Stats rule 14 only; Chaos breakthrough_chance joins Realms' 10 pp q-extras ceiling
- [RECOMMENDED] AC-LC-29: no criterion points at the Realms clamp when the tree (8 pp) and Chaos (4.8 pp) are both present
Resolution: Status header and the two stale cross-reference statements edited in this session, before the hash below was taken, so the hash covers the final file. Items 3 to 6 are not yet applied.
Reviewed-Content-Hash: design/gdd/linh-can.md 01525f1f35a406d3ea2c89ebe858c97ae300ca4f
Reviewed-Content-Hash: design/registry/entities.yaml 454a4906d2577c927c2194447dbca63568a2c309
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 7bf79075658e456d8919f4f22e29fd5484a98646
Reviewed-Content-Hash: design/gdd/canh-gioi.md 9f1acabdc4d0b501c48438e00c4c2160931d1e72
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md c95fda2f3db1240f4eab6afc0ba9d3b3ceb8fe62
Reviewed-Content-Hash: design/gdd/game-concept.md 548ea01d5cd8dd7c3c864164389a3b388caff094
Reviewed-Content-Hash: design/gdd/systems-index.md 0df28c5e1b72d12660d2dcd305af494e11925c0d

## Review — 2026-11-05 — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 1 | Recommended: 10
Summary: Independent re-review by a fresh subagent, read-only, after the user set the earlier approval aside. The core maths recomputes; the blocker is wording that contradicts the Meridian Map's frontier rule. No bot or game run, so E_p and the tight timing spots stay not assessed.
Prior verdict resolved: Earlier approval set aside by the user
Findings:
- [BLOCKING] Detailed Design rule 12, Edge Cases, AC-LC-33: "spendable" contradicts Meridian rule 20; entries join the frontier only with their host open
- [RECOMMENDED] Formulas D3: E_p about 0.2 is unreachable under the new gate odds; 13.5 % target has no live source
- [RECOMMENDED] Formulas D3: Awakening nets wrong (6.0 / 4.8 / 10.8 pp, g about 5.4)
- [RECOMMENDED] Formulas B: tight spots are not unchanged for roots above their base row
- [RECOMMENDED] Formulas E, AC-LC-29: Chaos and the q-extras ceiling not stated consistently
- [RECOMMENDED] Formulas E: Void's `co_duyen_pct` and "secret realms" have no defined effect
- [RECOMMENDED] Formulas F: when Linh Căn Quả picks its element is undefined; code picks at grant
- [RECOMMENDED] Formulas E: the variant band prices the role line only
- [RECOMMENDED] Edge Cases: Void in the rolled set differs by path
- [RECOMMENDED] Open Questions, Cross-References: stale bookkeeping
- [RECOMMENDED] Parameter keys: `awakening_capability` undocumented; other keys unread by code
Resolution: The blocker and the plain-error items were fixed after this review, on the user's instruction, and are NOT yet reviewed. Left open as design questions: Void's effect, the Linh Căn Quả element timing, and the keys code does not read. The hashes below stamp the files as reviewed, before those fixes, so the next freshness check reports them changed.
Reviewed-Content-Hash: design/gdd/linh-can.md 4c8abfb95124d01d27bf531dbb5ba14eeac020fb
Reviewed-Content-Hash: design/registry/entities.yaml caa09b94e15419dcb851f36f77d27c89c876be4a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 7bf79075658e456d8919f4f22e29fd5484a98646
Reviewed-Content-Hash: design/gdd/canh-gioi.md 3dbcfde3cc903d285e7ed38d82683627be9c48b4
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 3957524a53436c15089fa33deaeb1a66ea085229
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/game-concept.md 548ea01d5cd8dd7c3c864164389a3b388caff094
Reviewed-Content-Hash: design/gdd/systems-index.md 977b2a49f2ae746844dbe750346aa00e24fb00cd

## Revision — 2026-11-05 (user decisions after the review; no new review)
Linh Căn Quả: the player picks the element when the fruit is used, and an NPC's fruit stays random (rule 13, Formulas F, UI, AC-LC-40, AC-LC-51, Open Question 11). Void's effect deferred by the user (Open Question 2). Not yet reviewed.

## Review — 2026-11-05 (second independent review) — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 2 | Recommended: 4
Summary: Fresh read-only review. The earlier blocker is resolved and the core maths recomputes. Both blockers are statements the data and code contradicted.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rule 15: NPC roots were not rolled by the same rules; archetype elements were added after the roll
- [BLOCKING] Rules 2, 13: the birth perk Linh Căn Thuần Tịnh changes the root and was undocumented
- [RECOMMENDED] Formulas D3: "at most" was not a bound, and the formula did not give its table
- [RECOMMENDED] Formulas F: fruit figures stale after the player pick
- [RECOMMENDED] Formulas D, E: typical derived purity about 45.5, not 43
- [RECOMMENDED] Open Question 7: RNG streams still open though built
Resolution: Fixed on the user's instruction and NOT yet reviewed. User decision on the first blocker: an archetype never changes a root; an NPC whose root does not fit usually switches archetype and may keep it at a disadvantage. Open Question 7 and the Meridian Map's "43 (derived mean)" row are left open. The hashes stamp the files as reviewed, before those fixes.
Reviewed-Content-Hash: design/gdd/linh-can.md 0c53e0c0e82c78907a9067fd8e0dc86c50a26626
Reviewed-Content-Hash: design/registry/entities.yaml c4290ef42c28e913206d3a13e72840596edd4ce4
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 55d9ae80692694927176c65f7603cb63f1cab407
Reviewed-Content-Hash: design/gdd/canh-gioi.md 68261c1ab3ee96bfe30ff4f4f363abeaa6327290
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 8a3b40480be08d1afbaf0686522c57136fbb38ae
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/game-concept.md 97d16997e271c1a187365e08392eab74f8ed60e2
Reviewed-Content-Hash: design/gdd/systems-index.md a623e273f1661fa40a9195582b36c8421d95c717

## Review — 2026-11-05 (independent, ahead of the cross-GDD pass) — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 1 | Recommended: 11
Summary: Blessed NPCs did not get the birth perk's purity.
Prior verdict resolved: Yes
Resolution: Fixed the same day by the reviewing agent under decisions from the main session, with the user's mandate to accept the right fixes. A cross-GDD review then found no blockers (design/gdd/gdd-cross-review-2026-11-05.md). The fixes have not had their own solo re-review. The hashes stamp the files as reviewed, before those fixes.
Reviewed-Content-Hash: design/gdd/linh-can.md f88b04a3e103bc0e817ff0ef33948dd9e7d14227
Reviewed-Content-Hash: design/registry/entities.yaml 598fceae60b85a79be6a2763e0bba270d5e0f684
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/systems-index.md 316bd191788182445931fcf87c1dae09c7ac0fbd
Reviewed-Content-Hash: design/gdd/game-concept.md 97d16997e271c1a187365e08392eab74f8ed60e2
Reviewed-Content-Hash: design/gdd/canh-gioi.md bab602ac6aefc7a4e8589f7078e93f28560c930c
Reviewed-Content-Hash: design/gdd/character-stats.md 55d9ae80692694927176c65f7603cb63f1cab407
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md a9ddc4cd7fdba22c937c6afa9bb916ad1a2827db
