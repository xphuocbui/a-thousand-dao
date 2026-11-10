# Design Review: Spiritual Roots (Linh Căn), 2026-11-10

Report only. No GDD, registry, config or code was edited.
Mode: lean (no specialists), workflow standard, autonomous. Re-review: yes. The last logged verdict was NEEDS REVISION on 2026-11-05, and its fixes were never re-reviewed.
Scope signal: L (producer should verify).

## Verdict: NEEDS REVISION

3 blocking, 11 recommended, 5 minor, 6 user decisions.

The core is sound and still recomputes: tier odds, the element-count curve, pair bonus, variant chance and purity formulas, Formulas H (1.172 / 1.252 / 1.15 / 1.18 / 1.06 all check). The revision that added purity-powers-stacks (rule 8a, Formulas H) and the archiving of Void and Blood went in as patches on top of rules written for a capped, eight-variant world. The result is three places where the document gives two answers to one question (blocking), and a layer of stale text about the Way, the ceilings and the archived variants.

Completeness at standard: 5 of 5 required sections present, plus Formulas (required, since the system defines rates and curves). Player Fantasy and Tuning Knobs present. Nothing is missing.

### Dependency graph
- Exists: character-stats, canh-gioi, kinh-mach-do, cong-phap, effects, modifiers, dao, combat, combat-defence, combat-damage-types.
- `design/glossary.md`, `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md`, `progression-and-edges.md` are cited. I did not re-verify them beyond the receipt check, where `phu-luc` showed CHANGED.
- The Way (Đạo) is cited as "undesigned". Its GDD exists (`dao.md`, system #39, Approved in the index). See LC-04.

### Registry values
Searched the entries this GDD owns (count_weights, purity distribution, pair_bonus, n_eff, element_count_curve, variant_formation_factors, innate_chance, variant_power_band, variant_catalogue_size, root_change values, archetype_keep_chance) across the whole document. All stated values match the registry. Two registry facts disagree with the GDD's own text, both listed below: `innate_chance` still 0.015 / 0.005 (LC-02); no entry exists for `stack_purity_factor` or `pair_share` (LC-10). The registry's `element_stacks` note carries the literal `0.002 x purity`.

## Findings

### Blocking

**LC-01 (blocking) Purity cap: the document both removes and keeps the 100 cap.**
- Locations: rule 8 "No cap" and rule 8a, Edge Cases line 854 (uncapped) against rule 13 Tẩy Tủy ("capped at 100", "when every owned element is at 100 … refused"), rule 13 Linh Căn Quả ("with all five at 100 it is refused and kept"), States table row Tẩy Tủy, Edge Cases lines 890 to 894, Formulas F first formula (`min(100, …)`) against its second formula ("no cap since 2026-11-10"), AC-LC-39, AC-LC-43 ("95 → 100", "all five at 100 refused"), AC-LC-44 ("none exceeds 100"), rule 10 and Formulas D2 (derived variant clamped 1 to 100 while its parents are uncapped), Formulas D2 "derived 8–80" and Formulas E "a derived variant tops out at purity 80, real ceiling 24 W".
- What is wrong: a pill, a fruit and a derived variant each need one rule once element purity can pass 100. Today a programmer cannot tell whether a Metal 140 element refuses a pill, whether the +8 fruit path is refused at 100, whether Thunder built on Fire 200 / Metal 200 is 100 or 160, or whether AC-LC-44 fails on a road-raised root. AC-LC-44 as written fails the moment rule 8a works.
- Fix: state once (rule 13 and Formulas F) which sources are capped: recommended, pills and fruits stay capped at 100 and refuse at 100, birth stays 10 to 100, and only the rare sources of rule 8a go past 100. Say that "all at 100 refused" means all at least 100. Rewrite AC-LC-44 to "no element or variant is lost and no purity falls". Add an AC that a road-raised element past 100 still refuses a pill. Decision D1 covers the derived-variant clamp.

**LC-02 (blocking) Void and Blood are "archived, `innate_chance` 0" in rule 9 but live in every formula, key table, AC and the registry.**
- Locations: header line 10 and rule 9 "Archived" paragraph (`innate_chance` is 0, Self-made rejects them) against Formulas A step 4, D1 table (Blood 0.015, Void 0.005), D1 rates (12.14 %, 4.34 %), Parameter keys, Tuning Knobs `innate_chance`, AC-LC-04 to AC-LC-51, registry `innate_chance`, and `character_attributes.json` line 31.
- What is wrong: rule 9 states a present-tense value (0) that the data, registry and every downstream number contradict. The header does admit the code is not changed, but rule 9 reads as current. A reader of Formulas A draws for Blood; a reader of rule 9 does not.
- Fix: put the target state in one labelled block ("Target after archive: `innate_chance` huyet 0, hu_khong 0; shipped build today: 0.015 / 0.005") and mark every affected formula and AC as "pre-archive figures" until the code pass (Open Question 13). Or apply the archive to the numbers now (decision D5). Either way rule 9 must not say 0 without saying the data still says 0.015.

**LC-03 (blocking) Formulas H does not say whose purity powers a debuff stack, or what purity a foe, beast or tribulation has.**
- Locations: rule 8a ("An element's buff and debuff stacks are multiplied by `(1 + stack_purity_factor × P)`"), Formulas H (`stack_power(e)`, "P is the element's purity"), against Effects rule 9a ("P the owner's purity in that element"; "enemies, beasts and tribulations use the same rules").
- What is wrong: Burn on a foe is a debuff placed by the player, held by the foe. By Effects' wording P is the owner's (the foe's) purity; by Combat's "debuff ticks are the applier's damage" it should be the applier's. Neither GDD gives an enemy, beast or tribulation a purity. A programmer must guess, and the guess changes every debuff build.
- Fix: say in Formulas H that a stack's power uses the **applier's** purity read at the moment the batch is applied (matching Combat Formulas F's snapshot rule), and that buff stacks use the holder's. Give non-player combatants a rule: a `stack_purity` field on enemy records, default 0, or NPC root purity for NPC cultivators. Add an Edge Case and an AC for a foe with no purity. Effects rule 9a needs the same wording (flag for that GDD's owner).

### Recommended

**LC-04 (recommended) The Way is described as undesigned; it is designed and approved.**
- Locations: Dependencies row 39 "(new, undesigned) … Provisional", Interactions table row "the Way (undesigned; provisional contract)", Cross-References row "New, undesigned … Run `/design-system dao`", Open Question 9, rule 16 ("seeds for the Way's own design"), and the Dependencies bidirectional paragraph.
- Wrong: `dao.md` exists, `systems-index.md` row 39 says Approved, and `dao.md` already says "Open Question 9 is answered here: the relocated mutations are Daos" and uses the root's purity as requirements (Spiritual Roots rule 8a). Dao's `dao.md` Catalogue marks the 22 seeds with †.
- Fix: replace "undesigned/provisional" with the real contract (what Dao reads: elements, purities, variants). Close Open Question 9 (strike through, point to `dao.md`). Rule 16 keeps the 22-name list as history. AC-LC-47's id list matches the 22 names and needs no change.

**LC-05 (recommended) Rule 8a names "Đạo nodes" and "rare items" as purity sources; no GDD defines them.**
- Location: rule 8a "Purity past 100 comes only from rare sources: an element land's meridian roads …, a Linh Căn Quả raise, rare items and Đạo nodes."
- Wrong: `dao.md` has no node that grants purity (no match for purity grants outside its requirement column). Item Database has no purity item beyond the two root items. Meridian roads are the only source with a home (kinh-mach-do rule 21 area). Open Question 14 asks for the amounts but not for the existence of the other two sources.
- Fix: list roads and the Linh Căn Quả raise as the defined sources. Mark "rare items" and "Đạo nodes" as "intended, undefined", and add them to Open Question 14 with an owner (Item DB, Dao).

**LC-06 (recommended) An element the root does not own but has road purity in: sector scale, roles and techniques are contradictory.**
- Locations: rule 8 ("0.25 if absent"), rule 8a (unowned purity "changes no … sector"), Edge Cases line 854 ("every use reads the full value: … sector scaling and the element roles"), line 856, AC-LC-26 ("An absent element contributes 0"), rule 8 techniques ("naming something the root lacks cannot be used at its speed").
- Wrong: line 854 says roles and sector scale read full purity; rule 8a and AC-LC-26 say an unowned element has no effect beyond stacks. Both cannot hold for a Wood-less root with 30 Wood purity from roads.
- Fix: decision D2. Then make line 854, rule 8, AC-LC-26 and AC-LC-53 agree.

**LC-07 (recommended) Rule 7 and Formulas E cite character-wide ceilings that no longer exist.**
- Locations: rule 7 "stay inside the existing character-wide ceilings (Character Stats rule 14)"; Formulas E "No variant key is under a Character Stats ceiling (rule 14)".
- Wrong: Character Stats rule 14 turned its ceilings into log curves (2026-11-10, "no caps"). Only herb growth and lifespan keep a curve; none of the variant keys is on one, so Formulas E's pricing still holds, but the wording is wrong. Rule 7's sentence is false.
- Fix: rule 7: "Variant role lines sit on no curve of Character Stats rule 14; Chaos's `breakthrough_chance` still meets Realms' q-extras ceiling." Formulas E: reword the same way. Keep the per-source tree cap mention in AC-LC-29.

**LC-08 (recommended) Technique speed reading uncapped purity disagrees with Cultivation Techniques' ranges.**
- Locations: rule 8 "No cap: … Cultivation techniques"; Edge Cases line 854; against `cong-phap.md` lines 364, 368, 545 (`match` 0.08–1.00, `strongest_purity` 10–100, avg_purity 8–100) and its tier ceilings (lines 372 to 423).
- Wrong: with purity 300, `match` is 3 and the tier-ceiling and Realms years calibration is off by that factor. The research note (`linh-can-proficiency-direction.md`) recommended capped reads for craft roles and technique speed, and recorded "capped reads" as applied; the GDD now says the opposite (decision D6).
- Fix: after D6, update either this rule or Cultivation Techniques' ranges and ceiling check, and note Realms' calibration re-run.

**LC-09 (recommended) Acceptance criteria: a duplicate ID, orphaned bullets and a criterion with no assertion.**
- Locations: AC-LC-52 appears twice (birth perk at line 1156, Formulas H at line 1406); AC-LC-53 (line 1407) carries four UI bullets about the root line, `explain` and the Linh Căn Quả preview that belong to AC-LC-51; AC-LC-51 (line 1405) states only "Evidence is a retained screenshot" with no assertion.
- Wrong: ID collision breaks traceability; AC-LC-51 is not testable as written; AC-LC-53's bullets test nothing about rule 8a.
- Fix: renumber the Formulas H criterion (AC-LC-54), move the four UI bullets under AC-LC-51, keep AC-LC-53 to the Metal-30 case. Add the missing criteria: a foe's stack power (LC-03), pill refusal on a road-raised element (LC-01), the unowned-element rule (LC-06).

**LC-10 (recommended) `stack_purity_factor` and `pair_share` are not in the registry, the data files or AC-LC-19.**
- Locations: Parameter keys (marked new), Tuning Knobs, AC-LC-19 (its list stops at `variant_power_band_apex`); registry has no entry; `assets/data/character_attributes.json` has neither key; Effects rule 9a and the registry's `element_stacks` note hardcode `0.002`.
- Wrong: coding standards want gameplay values data-driven and registered; one value now lives as a literal in two GDDs.
- Fix: add registry entries (source linh-can.md, referenced_by effects.md), add both keys to AC-LC-19, and have Effects say "`stack_purity_factor`" instead of 0.002.

**LC-11 (recommended) Dependencies and Interactions miss the systems that now read purity.**
- Locations: Downstream table lists no Effects System, Modifier System or Combat Damage Types row (the last two appear only in the "Combat sub-systems" note); Interactions row for Effects says "(rule 9a)" with no system name, so it reads as this GDD's rule 8a.
- Fix: add Effects System (stack power, Formulas H), Modifier System (root bonuses as catalogue modifiers, element scopes) and Combat Damage Types (tags) as downstream rows. In the Interactions row write "Effects System rule 9a". Add Effects and Modifier System to the Quick reference key deps.

**LC-12 (recommended) Rates and the "1 in 8" claim are pre-archive.**
- Locations: Summary line 15 ("about 1 life in 8"), Overview, Formulas A example (Blood draws), Formulas D1 rates table (12.14 %, 4.34 % innate), Formulas B ("43.00 / 32.55 / … %", "innate variant moves 4.3 % of lives"), D3 planning assumption (12.4–13.5 %), Player Fantasy ("Wind, Blood and Void simply arrive"), Tuning Knobs `innate_chance` ("each 0–0.04, sum ≤ 0.06"), Open Question 1.
- Wrong: with Void and Blood off, innate share is 2.5 %, about 10.3 % of lives hold any variant (12.14 minus about 1.9; recompute exactly), and `n_eff` shares move. The "1 in 8" and the Player Fantasy line describe a game that no longer rolls them.
- Fix: do not recompute until D5 is decided; then regenerate D1, B and D3 from the simulator and update AC-LC-23 tolerances. Player Fantasy: remove Blood and Void from the "arrive" line now.

**LC-13 (recommended) Rule 8a says variants use their own purity, but no rule lets a variant's purity rise.**
- Locations: rule 8a "Variants (Thunder, Wind, Ice) use their own purity"; rule 10 ("An innate variant's purity … never changes"; derived purity recomputed from parents); rule 14.
- Wrong: roads raise element purity only. A derived variant's purity then follows its parents (clamped, LC-01). Wind is fixed at its birth draw and no source can raise it, so a Wind stack build is stuck at 10–100 while Fire builds go past 100. This may be intended but is not said.
- Fix: decision D4; then state it in rule 8a.

**LC-14 (recommended) Edge Cases lack the cases the revision created.**
- Missing: a foe or beast with no purity (LC-03); Water and Ice both owned and a Tẩy Tủy Đan raising one; Ice stacks from an item on a root with Water but no Ice (P = ½ Water); derived variant above 80 after a road raise (LC-01); a Linh Căn Quả that adds an element the roads already raised (does the 20–35 replace or add?); an unowned element's purity after a Linh Căn Quả gives it birth purity.
- Fix: add each as an Edge Case with the stated result and an AC. The last one needs a rule (recommended: the fruit sets purity to max(existing, 20–35 draw)... for the user to confirm, see D2).

### Minor

**LC-15 (minor) D1 text says the `min(1, …)` clamp "matters only for Chaos".** With purity past 100 a convergence (two parents at 130 give 1.01) and a transmutation can reach 1. Reword to "binds for Chaos at birth and for any variant on road-raised purities".

**LC-16 (minor) Status block is stale.** Header: "Last Updated 2026-11-05", "Last Verified 2026-11-05"; the 2026-11-10 revision line is present but the status line still reads "independent review findings applied; cross-GDD review CONCERNS". Update after the fixes. (The systems index row 6 carries the same stale status; not edited here.)

**LC-17 (minor) "Chaos" is used bare in about 40 places while Combat Damage Types has a Chaos (Tà) damage type.** Combat Damage Types Open Question 7 asked for the "Primordial Chaos (Hỗn Độn)" sweep in this file; only 5 lines carry it. Use "Primordial Chaos" or `hon_don` everywhere the variant is meant.

**LC-18 (minor) Tuning Knobs rows for `stack_purity_factor` and `pair_share` have five cells in a four-column table** ("… | How much purity strengthens element stacks | Formulas H |"). Merge the last two cells.

**LC-19 (minor) Open Question 5 uses the pre-redesign 109 W figure and the old derived numbers; Open Question 8 mentions Blood and Void.** Refresh after D5.

## Findings that need a user decision

- **D1.** Should a derived variant's purity stay clamped at 100, or follow its parents past 100? Recommended: stay clamped at 100 (keeps variant power inside its 30 W and 60 W bands; the role lines are priced at 100). Alternative: uncapped like elements, then re-price the bands, since Formulas E's ceiling assumes at most 80.
- **D2.** Does road-granted purity in an element the root does not own scale that element's sector, run its craft role, or count for a technique naming it? Recommended: stacks only (matches rule 8a "changes no … sector" and AC-LC-26); sector stays 0.25, roles 0, techniques unusable. Alternative: it counts everywhere except `n_base`, pairs, curve and variant eligibility.
- **D3.** Whose purity powers a debuff stack, and what do foes have? Recommended: the applier's, read when the batch is applied; enemies and beasts carry a `stack_purity` of 0 unless their record sets one. Alternative: the holder's purity, with foes' purity set by their record (stronger foes resist nothing, but their own debuffs scale).
- **D4.** Can a rare source raise an innate variant's purity (Wind) or a variant stack's purity directly? Recommended: no, only elements, so variant stack power follows parents (derived) or the birth draw (innate); document it. Alternative: allow roads of a variant sector to grant its own purity, and drop the "never changes" rule for innate.
- **D5.** Apply the Void and Blood archive to the GDD numbers now, or leave all formulas pre-archive until the code pass? Recommended: leave the formulas as the shipped build, add the target state in one labelled block (LC-02), and regenerate the tables in the code pass. Alternative: rewrite D1, B, D3 and about 20 ACs to the archived state now.
- **D6.** Technique speed (and craft roles) read purity uncapped, or capped at 100? Recommended: capped at 100 for technique speed, because Cultivation Techniques' tier ceilings and Realms' years table assume `match` at most 1; crafts uncapped per the 2026-11-10 "no caps" decision. Alternative: uncapped everywhere, then widen `match` and recalibrate Realms.

## Mechanical fixes (one sweep)

1. Line 3 to 6: update the status line, Last Updated and Last Verified (LC-16).
2. Line 15 and Player Fantasy: "about 1 life in 8" and "Wind, Blood and Void simply arrive" (LC-12).
3. Dependencies row "39 The Way (new, undesigned)", Interactions row for the Way, Cross-References row for the Way, Open Question 9, "Run `/design-system dao`" (LC-04).
4. Rule 7 and Formulas E ceiling sentences (LC-07).
5. Interactions row for Effects: "(rule 9a)" to "Effects System rule 9a" (LC-11).
6. AC-LC-52 duplicate and the AC-LC-53 bullets (LC-09).
7. D1 clamp sentence (LC-15).
8. Tuning Knobs rows at lines 1020 and 1021, extra cell (LC-18).
9. Bare "Chaos" to "Primordial Chaos (Hỗn Độn)" (LC-17).
10. AC-LC-19: add `stack_purity_factor` and `pair_share` (LC-10).
11. Open Question 5 and 8 figures (LC-19).

## Prior review items
The 2026-11-05 NEEDS REVISION blockers (NPC archetype adds elements; birth perk undocumented) are resolved in rules 2, 13 and 15 and AC-LC-46 and AC-LC-52. Its recommended items on Formulas D3 and F were reworked; the "typical derived purity 45.5" figure now appears in D2 and E. The fixes were never re-reviewed until now.

## Cross-document facts checked
- Effects rule 9a and Formulas D: purity multiplier `(1 + 0.002 × P)`, Water and Ice sharing: consistent in value; differs in wording (LC-03, LC-10).
- Character Stats rule 14 and Formulas G: purity term keeps rising past 100: consistent with rule 8; ceilings wording stale here (LC-07).
- Meridian Map rules 20 and 21: variant sectors, 0.5 + purity ÷ 100, roads exact, Blood and Void sectors stay locked: consistent.
- Combat Damage Types: elements are art tags only, no relations in fights: consistent. Its Open Question 7 (name sweep) is still open (LC-17).
- Realms: curve keyed by `n_eff`, `breakthrough_succeeded` player only: consistent.
- Cultivation Techniques: purity ranges stop at 100 (LC-08).
- The Way: designed; this GDD still calls it undesigned (LC-04).
- Combat economy revision #44 changed nothing else this GDD owns.

RESULT: verdict=NEEDS REVISION blocking=3 recommended=11 minor=5 decisions=6

---

## User answers and applied fixes (2026-11-10, parent session)

- **D6:** technique speed reads purity **uncapped** (also answers Cultivation Techniques D1); its ranges and tier
  ceilings widen in its own revision, and Realms re-calibrates.
- **D1:** a derived variant **follows its parents past 100** (no upper clamp); variant bands re-price later (OQ 15).
- **D2:** purity in an unowned element **counts everywhere except the root's own counts** (n_base, pairs, curve row,
  variant eligibility).
- **D3:** a debuff uses the **applier's** purity, a buff the holder's; foes default `stack_purity` 0 (effects.md
  rule 9a reworded).
- **D4:** **yes**: a variant land's roads grant that variant's purity, innate ones included (Meridian Map rule 4,
  its OQ 22 resolved).
- **D5:** Void and Blood: a labelled target block in rule 9 now; numbers regenerate at the code pass.
- Applied: LC-01 (pill capped at 100 and refused only when all owned are ≥ 100; Linh Căn Quả never refused, +8 past
  100; AC-LC-39/43/44), LC-02, LC-03, LC-04 (the Way designed; OQ 9 closed), LC-05 (defined vs intended sources),
  LC-06 via D2, LC-07, LC-08 via D6, LC-09 (AC-LC-52 duplicate renumbered to AC-LC-54; UI bullets under AC-LC-51;
  AC-LC-55/56 added), LC-10 (registry `stack_purity_factor`, `pair_share`; AC-LC-19), LC-11, LC-13 via D4, LC-14 (new
  edge cases), LC-15, LC-16; rule 12 and every "variant sector" passage now describe variant lands. LC-12, LC-17, LC-19
  wait for the code pass (D5).
