# Design Re-Review: The Way (Đạo) — 2026-11-10 (confirming, report only)

Review mode: lean · Workflow: standard · Specialists: none (lean). Re-review: yes, prior verdict NEEDS REVISION (1 blocking) the same day.
Nothing was edited. This file and the log entry in `dao-review-log.md` are the only writes.

## Verdict: NEEDS REVISION (1 blocking, a wording fix)

All seven recorded answers and the applied fixes are present and, where they carry numbers, correct. One new contradiction came from the D-05 fix, and it blocks approval until it is reworded. The rest is small.

Completeness: all 5 standard sections present, plus Formulas, Player Fantasy and Tuning Knobs. Dependency graph: every named GDD exists on disk. Registry values: the dao keys all match the GDD.

## (a) Answers and fixes checked

| Item | Result |
|---|---|
| D-01 headroom lint dropped | Present: D1 part 5 is the rate cap only; rule 4, rule 12, Edge Cases, UI, AC-DAO-09 and AC-DAO-26 agree. The registry `dao_node_value` expression agrees. |
| D-02 premium 3.38 W/pt, 1.63× | Correct. 121×2.4 + 15×16 = 530.4; 530 ÷ 157 = 3.38; 3.38 ÷ 2.07 = 1.63; 157×2.07 = 325. D3 repeats the 0.37× remainder. |
| D-03 ◇ archive | Present in the Catalogue, and combat.md Open Question 27 exists and lists the facets. |
| D-04 shared minors | Present in rules 3 and 12, D1 part 4, AC-DAO-23, and effects.md `host_dao`. Two gaps: D-R03 and D-R04 below. |
| D-05 Effects beyond the ceiling | Present in rule 4, AC-DAO-29, canh-gioi (`q_way`, Open Question 23). It contradicts rule 4's first sentence and AC-DAO-22: D-R01. |
| D-06 / AC-DAO-11 NPC numbers | All five stage rows re-derived and correct: 1.661, 1.667, 1.660, 1.663, 1.664. P_npc 40/54/69/114/141 and map points 121/162/209/344/425 are right. The cap binds only from 596 points. Knob "0.30 gives 1.86" is right. |
| D-07 Stars stays | No change was needed. Tinh Đạo row 9 has no †, and the seed mapping sends Stars to Mệnh Đạo. |
| D-08 soft rows | Present in Dependencies, but one-sided: D-R02. |
| D-09 rival lint | Present in D1 part 4, AC-DAO-28, effects.md. |
| D-10 Player Fantasy | Written. |
| D-11/13/24 AC-DAO-10 | Arithmetic holds: 121×2.88 + 36×19.2 = 1,039.7 ÷ 157 = 6.62 W/pt. |
| D-12 purity 30 | Rule 5, knob, AC-DAO-06, Catalogue note, registry, linh-can reference. |
| D-14 registry `dao_two_art_max` | Present. |
| D-15 / D-16 / D-17 | Titles are present for all 94 Ways. The shuffle uses stable `dao.json` id order. The data-size knob row and UI note are present. |
| D-18–D-26 sweep | Done, except the leftovers listed as D-R05 to D-R09. |
| D-27 | kinh-mach-do, character-stats, effects and combat lines are fixed, except the combat.md leftover in D-R12. |

Other arithmetic re-derived and correct: AC-DAO-01 bands (1.92–2.88, 12.8–19.2; ×3 gives 2.88–4.32, 19.2–28.8); 0.9·2·2.07 = 3.73; `dao_open_min` 3 + 4 − 1 = 6; the knob limits at offers 3 and 4; AC-DAO-03 (121+15+15+6 = 157 points, 158 nodes); AC-DAO-18 (8+4 → clamp at 10; 5.5+4 = 9.5); rate cap 10 × 2.2 = 22 W (modifiers.md row 2.2 confirms).

## Findings

### Blocking

**D-R01 [blocking] Rule 4, "What the player cannot do", AC-DAO-22 contradict AC-DAO-29.**
- Where: Core Rules 4 (lines 110–111) says "A Dao may not raise a cap that Character Stats still keeps (the q-extras ceiling…) or multiply the … breakthrough chance". The same rule (lines 123–126) and AC-DAO-29 let Effects exceed that ceiling. Line 214 ("make a node raise a cap") and AC-DAO-22 ("No node carries a ceiling raise… none multiplies a whole … breakthrough chance") are written for every node.
- What is wrong: taken literally, AC-DAO-22 fails every fixture that AC-DAO-29 requires (Kiếp Hiểm Phá, Cải Mệnh). Two testable criteria cannot both pass.
- Fix: scope the prohibitions to **stat lines** in rule 4 sentence 1, line 214 and AC-DAO-22. Add "Effects on breakthrough or heart-demon odds are the exception (rule 4, AC-DAO-29)" to AC-DAO-22.

### Recommended

**D-R02 [recommended] Dependencies are not bidirectional for the three soft rows added by D-08.**
- Where: Dependencies, soft table (Heavenly Tribulation #22, Quests #31, Item Database #13).
- What is wrong: `thien-kiep.md`, `quests.md` and `item-database.md` do not mention the Way or `dao.md` at all.
- Fix: add a one-line Way row to each GDD's Dependencies during its next sweep. Until then, mark the three rows "back-reference pending".

**D-R03 [recommended] What happens when one character buys the same shared `minor` through two Daos is unspecified.**
- Where: rule 3 / rule 12 (shared pool), Edge Cases line 604 ("both apply and stack… A Dao's Effects have their own ids (rule 12)").
- What is wrong: a shared `minor` has one id in several Daos, so the "own ids" sentence no longer holds. A character with two such Daos could stack it, and the Effect limits may not stop that. The same stat could also be bought twice for a point each.
- Fix: see decision 1.

**D-R04 [recommended] No limit on how much of a Dao the shared pool may take.**
- Where: rule 3, rule 12, D1 part 4, AC-DAO-23.
- What is wrong: with no cap, a Dao could hold 10 shared minors, and rule 12's "name hidden, 2 of 3 reviewers" test (AC-DAO-20) becomes weaker.
- Fix: see decision 2.

### Minor

- **D-R05** Interactions row "NPC Builds, Living World Tick" (line 256) says "its simplified `npc_effect`"; D3 uses `power_mult`. Use `power_mult`.
- **D-R06** Interactions row "World Database" (line 257) says "a glimpse and a Keystoned Dao are recorded as events", but rule/AC-DAO-14 write one event per capstone bought. Edge Cases line 622–623 says "the keystone's … event". Use "each capstone bought" in both.
- **D-R07** Open Question 5 and registry `npc_dao` notes say "about 11–25 %". D3 gives +25 % at every level (+16 % if only the stat lines count, 1 + 0.63 × 0.25). Restate the range, or say "about 25 %, 16 % without Effects".
- **D-R08** Registry `dao_node_tol` notes still say "V-bar" (swept in the GDD, not in the registry). Use W_small and W_notable.
- **D-R09** UI Requirements line 758 says a Dao graph is "110–170 points"; nodes are 110–170 and points 109–169.
- **D-R10** Catalogue row 92 (Cô Đạo): the facet Cô Tinh says "more power per missing ally", and Combat has no allies. Reword to companion, or mark it ◇ with Khắc Thân.
- **D-R11** D1 part 3 (mean ≥ 3.73 W) implies at least about 10 % of priced nodes are stat notables (2.4(1−f) + 16f ≥ 3.73, so f ≥ 0.098). The Sword pilot has 15 of 136 (11 %), a 4.5 % margin. State the floor, because a Dao with many Effect notables will fail part 3.
- **D-R12** Stale text in other GDDs: linh-can.md line 368 calls `dao.md` "approved" (it is In Review); combat.md line 1235 says arts "remain on hold" and cites `dao.md` Open Question 3, which is closed.

## Mechanical fixes (one sweep)

1. D-R01 wording in rule 4, line 214 and AC-DAO-22 (the stat-line scope).
2. D-R05, D-R06, D-R07, D-R09 in `dao.md`.
3. D-R08 and D-R07 in the registry.
4. D-R10 in the Catalogue.
5. D-R12 in linh-can.md and combat.md; D-R02 rows in the three GDDs.

## Decisions for the user

1. **D-R03: a shared `minor` bought through two Daos on one life: stack, apply once, or refuse?** Recommended: refuse the second buy and name the other Dao (as for a rival), so a shared minor is one Effect per character. Alternatives: it applies once and the second copy is a free dead node; it stacks as a separate source.
2. **D-R04: should a Dao's shared-minor share be capped?** Recommended: at most 4 of its 10 `minor` slots, as a knob `dao_shared_minor_max` (4, range 2–6), linted in D1 part 4 and AC-DAO-23. Alternatives: no cap; at most half of them (5).

## Still blocking approval

D-R01 only. Open Question 1 (the `dao_glimpse` contract) still gates any Dao being playable, and the catalogue graphs are still a content pass. Those are known open items, not review findings.

## Scope signal

L, unchanged. Rough signal; the producer should verify before sprint planning.

## User answers and applied fixes (2026-11-10, same session)

- D-R03: a shared `minor` is held once per character; the second buy is refused and names the first Dao (rule 3, Edge Cases, AC-DAO-23).
- D-R04: `dao_shared_minor_max` 4 (range 2–6), linted in D1 part 4 and AC-DAO-23; registered.
- Applied: D-R01 (stat-line scope in rule 4, "cannot do", AC-DAO-22), D-R02 (Way rows in thien-kiep.md and quests.md; item-database.md in its own sweep), D-R05, D-R06, D-R07 (and the registry note), D-R08 (registry), D-R09, D-R10 (Cô Tinh reads companions), D-R11 (the stat-notable floor stated), D-R12 (linh-can.md, combat.md).
