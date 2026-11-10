# Confirming re-review: Cultivation Techniques (Công Pháp), 2026-11-10

Report only. Nothing in `cong-phap.md`, any other GDD, the registry, project.yaml or code was edited.
Review mode: lean (solo) · Workflow: standard · Re-review of `cong-phap-review-2026-11-10.md` (NEEDS REVISION) after its answers and fixes.
Scope signal: L (unchanged).

## Verdict: NEEDS REVISION (2 blocking, both small and local)

Almost every recorded answer and fix is present and the numbers re-derive. Two things still stop approval: the new
"purity of an unowned element counts" sentence cannot happen under the usability rule (CP-R01), and the D2 body-technique
tier mapping is not defined precisely enough to implement or test (CP-R02). Neither needs a redesign.

## (a) Answers and fixes: checked

| Item | Present? | Correct? |
|---|---|---|
| D1 uncapped purity: rule 9, Formulas A and D ranges (`match` 0.08 and up, `tech` 4.35 with #6, F 0.58 and up, v "more past it"), AC-CP-18 (purity 150 case), Edge Case "purity passes 100" | yes | Re-derived 2.9 (1.45 × 2.0) and 4.35 (+1.45); registry `technique_speed_factor` [0.03, 4.35] matches. Two wording slips: CP-R10. Unowned-purity sentence: CP-R01 |
| D2 body techniques, fixed sizes: rule 2, `body_defence`, AC-CP-23 | yes | 10 / 0.10 / 8.3 per tier; tier 3 = 30 / 0.30 / 25 points, tier 5 = 50 / 0.50 / 41.5, all match Combat Defence Formulas H. Mapping of layers to tiers is not defined: CP-R02. Feasibility at Qi Refining: CP-R03 |
| D3 harmony average for 3+ pairs, Chaos neutral: rule 12, Formulas D, Edge Cases, AC-CP-22; Blood and Void not nameable | yes | [Wood, Water] under Thunder (Fire, Metal): (1.00 + 0.60 + 0.60 + 1.15) ÷ 4 = 0.8375, shown 0.84. Correct. Side effect: CP-R08 |
| D4 interim `bonus_pool`; `effects`, `tags`, art pointer in the template | yes (rule 1) | `more` hook and enabler wording not added: CP-R06 |
| CP-03 curves (rule 12, Formulas D range), CP-09 header, CP-10 OQ 14, CP-11 4.35, CP-12 0.5 to 3.355, CP-13 review count, CP-14 body guard | yes | Consistent with Character Stats rule 14 and registry `bonus_curves` (`bonus_ceilings` is now `deprecated`) |
| CP-06 art record and slots: rules 1 and 13 | yes | Matches Combat rule 13. AC-CP-09 not updated: CP-R07 |
| CP-07 Combat sub-systems, Modifiers, Effects | partly | Added as prose only: CP-R05 |
| CP-08 States table exits | no (not in the applied list) | Still open: CP-R09 |

Spot-rechecked arithmetic this pass: AC-CP-02, 14, 18 (0.035, 0.258, 2.9, 4.35), 20, 21, 22 (12.213 / 6.372), 23 (11.0 / 15.0 / 5.1 / 13.6), 37 (9,087.27). All correct.
Rule numbers cited in other GDDs exist (Combat 13 and 23, Effects 13, Modifiers 9 and 12, Character Stats rule 14). Registry values this GDD owns match.

## (b) New contradictions from the fixes

### Blocking

**CP-R01 (blocking) Purity gained in an element the root does not own can never be read by a technique.**
- Where: rule 9 ("Purity a road granted in an element the root does not own counts here too ... a named id at purity 0 makes the technique unusable at its speed") against rule 8 ("usable only if the root has every element and variant it names"; unusable cannot be slotted) and AC-CP-07.
- Against: `linh-can.md` rule 8a ("elements and variants the root does not own ... that purity counts everywhere a purity is read ... techniques that name it") and rule 8 / edge case line 935 ("naming something at purity 0 cannot be used at its speed; Cultivation Techniques owns the fallback").
- What goes wrong: a technique naming an unowned element is unusable, so it is never slotted and its `match` is never computed; the sentence in rule 9 has no effect, and Linh Căn's claim that techniques read that purity is false in practice. The "purity 0 makes it unusable at its speed" clause is also muddled: purity 0 is only possible for an unowned id (derived variants floor at 8), which rule 8 already makes unusable, and the crude floor is only defined for "no usable main method".
- Fix: take D-1. Either keep ownership as the only usability test, delete the unowned-purity sentence and the purity-0 clause from rule 9, and add one Edge Case line ("purity in an unowned element is not read by techniques; no technique naming it can be slotted"), with Linh Căn rule 8a and its edge case lines amended to match; or make usability "purity above 0", and rewrite rule 8, the Known · unusable state, AC-CP-07 and the root-change guard.

**CP-R02 (blocking) The body-technique tier mapping is not implementable.**
- Where: rule 2 ("tier 1 at its first layer and each further tier at an even share of its layers"), rule 1 `body_defence`, AC-CP-23.
- What goes wrong: "an even share" does not say at which layer each tier is reached (a Yellow body technique has 6 layers and two tiers, a Heaven one 15 layers and five). Combat needs an integer tier. `body_defence` is declared as "the Combat Iron Body tier it reaches" but rule 2 also derives it as t + 2, so it is unclear which is authoritative. AC-CP-23 tests only the first and last layers.
- Fix: take D-2. Recommended text: `iron_tier(k) = 1 + floor((k − 1) × (T − 1) ÷ (layers − 1))` with `T = t + 2` (so T = 2 / 3 / 4 / 5 for Yellow / Profound / Earth / Heaven), read at the mastered layer k; `body_defence` is derived, not a field (or, if kept, it must equal t + 2 and the validator checks it). Add the middle values to AC-CP-23: Profound at k 5 gives tier 2 (20 / 0.20 / 16.6); Yellow at k 6 gives tier 2 and at k 3 gives tier 1.

### Recommended

**CP-R03 (recommended) Combat's Qi Refining thể tu fixture cannot be reached under D2.**
- Where: `combat-defence.md` line 752 (the thể tu at Qi Refining with Iron Body tier 3: 30 / 0.30 / 25) and Formulas G; `combat.md` line 598.
- Against: rule 2 here and rule 5 (layers 1 to 3 only at Qi Refining). Tier 3 comes from a Profound body technique at great completion (layer 9, Core Formation at the earliest), or from a Heaven one at about layer 8. At Qi Refining, with the CP-R02 formula, the best case is tier 1 (Yellow and Profound at k 3) or tier 2 (Heaven at k 3 gives tier 1 as well).
- Effect: the Combat worked example is a build no life can have at that realm. Combat AC-CB-60 itself is only a fixture ("given Iron Body Art at tier 3"), so it still passes.
- Fix: D-3.

**CP-R04 (recommended) Acceptance criteria miss the Combat hand-off and the new fields.**
- Where: AC-CP-39 (no Iron Body case, yet Combat AC-CB-60 says "AC-CP-39 is rewritten first"); AC-CP-36 (a body technique "carrying 1 modifier": with body defence it also carries block, body shield and resistance lines); AC-CP-34 (validator does not cover `effects` ids, `ability_id` pointing at no Combat art, tags, or a body `body_defence` that disagrees with the tier); no AC for `effects` / `tags` (rule 1).
- Fix: add an integration case to AC-CP-39 that a Profound body technique at great completion gives the profile block 30, σ_b 0.30, resistance 25 points, unscaled by Physique, Comprehension or ws; state in AC-CP-36 how many modifiers a body technique's line carries; extend AC-CP-34 and add one AC for the template's `effects` and `tags`.

**CP-R05 (recommended) The Combat sub-systems fix was applied as prose only; the tables still omit them.**
- Where: Interactions table, Combat row (line 313) and Dependencies Downstream row 21 (line 842) list only abilities and `tech_power`, not body techniques' block, body shield and resistance; no rows for #21a, #21b, #40, #41; the "Combat sub-systems" paragraph appears twice (lines 869 and 876 to 882) and the Bidirectionality paragraph (lines 871 to 874) still lists only four related GDDs.
- Fix: add the rows with direction and owner (Combat Defence & Healing, Combat Damage Types, Modifier System, Effects System, and the Item DB manual copy), merge the two paragraphs, and rewrite the Bidirectionality sentence to the real list (combat, combat-defence, combat-damage-types, modifiers, effects, dao, item-database, linh-can, canh-gioi, character-stats, kinh-mach-do).

**CP-R06 (recommended) D4's template fields are added, but the rules around them are not.**
- Where: rule 1 (`effects`, `tags`); Formulas D; Edge Cases.
- Against: `effects.md` rule 13 (a technique may be an enabler, whose `closes` is part of the rule) and `modifiers.md` rules 9 and 12 (`more` on L2).
- What is missing: whether a `damage_more` or conversion modifier on a technique scales with B(k), F, H and `comp_strength` or is fixed per layer; whether an enabler technique's `closes` is checked at load; that `effects` do not count against `bonus_budget`. The review asked for this ("or that they do not").
- Fix: one sentence each in rule 1 and Formulas D. Recommended: L2 `more` values scale with B(k) only and are not multiplied by F, H or `comp_strength` (they are priced in W later), and Effects do not use the pool budget.

### Minor

**CP-R07 (minor) AC-CP-09 does not test the art-slot wording added to rule 13.** Add: an unlocked ability is only eligible for the loadout's art slots; it is usable once slotted (Combat rule 13).

**CP-R08 (minor) Harmony cliff at three pairs (see D-4).** Under a Thunder main, a [Wood] art gives 0.60 (worst of two pairs) but a [Wood, Water] art gives 0.84 (average of four). Adding an element raises H. Probably acceptable, but say so in Edge Cases so it is not read as a bug.

**CP-R09 (minor) States table gaps (CP-08 from the first review, not applied).** Gated and Great completion leave only to Slotted or Known · usable; a Gated technique can also be unslotted, and a root change can make any Slotted sub-state unusable. Say "any Slotted sub-state" in the Leaves-to column.

**CP-R10 (minor) Two wording slips about purity and power.** The Edge Case "If purity passes 100: speed, power and bonuses read it in full" and Open Question 14 ("uncapped purity lifts [tech_power] further") are wrong: `tech_power` (Formulas C) does not read purity. Say "speed and bonuses" and drop the clause from OQ 14.

**CP-R11 (minor) Cross-References table is out of date.** It lacks rows for `combat.md`, `combat-defence.md`, `combat-damage-types.md`, `modifiers.md`, `effects.md`, `dao.md`, `item-database.md`, and its Character Stats row should name the bonus curves (rule 14, Formulas I), not only "provider interface".

## Decisions needed (recommended answer first)

- **D-1 (CP-R01).** May a technique name an element the root does not own once a road has given it purity? **Recommended: no; ownership stays the usability test**, so unowned-element purity is ignored by technique reads and the Linh Căn sentence is amended. Alternative: yes, usable at purity above 0, rewriting rule 8, the states table and AC-CP-07.
- **D-2 (CP-R02).** Which layer-to-tier rule for body defence? **Recommended: `iron_tier(k) = 1 + floor((k − 1)(T − 1) ÷ (layers − 1))`, T = t + 2, and `body_defence` derived.** Alternative: authored per-template tier thresholds (more control, more data to write).
- **D-3 (CP-R03).** Qi Refining thể tu example: **recommended: Combat moves its worked example (Formulas G, Combat line 598) to Core Formation, where tier 3 exists**, keeping D2 as answered. Alternative: let Yellow and Profound body techniques reach tier 3 earlier by mapping on the realm gate rather than the mastered layer.
- **D-4 (CP-R08).** Is "a wider art can out-harmonise a narrow one" intended? **Recommended: yes, keep and note it.** Alternative: count pairs per art element and take the worst relation across the art's own elements, which removes the cliff.

## Mechanical fixes (one sweep, after the decisions)

1. Rule 9 and an Edge Case line per D-1; same text in Linh Căn rule 8a (not this GDD's file).
2. Rule 2 and `body_defence` per D-2; extend AC-CP-23.
3. Add the AC-CP-39 integration case, the AC-CP-36 modifier count, the AC-CP-34 validator rows and the `effects` / `tags` AC (CP-R04).
4. Interactions and Dependencies rows; merge the duplicate Combat sub-systems paragraph; rewrite Bidirectionality (CP-R05).
5. `more` and `effects` sentences in rule 1 and Formulas D (CP-R06).
6. AC-CP-09 slot wording (CP-R07).
7. States table exits (CP-R09).
8. "speed and bonuses" in the purity Edge Case and OQ 14 (CP-R10).
9. Cross-References rows (CP-R11).
10. Header: keep Status at In Review until a clean re-review; update dates.

## Cross-document notes (not this GDD's to fix)

- `combat-defence.md` line 752 / Formulas G and `combat.md` line 598: the Qi Refining Iron Body tier 3 example (CP-R03).
- `combat.md` AC-CB-60 still says Iron Body "Physical resistance 25 points" correctly here but its rewrite note "AC-CP-39 is rewritten first" is stale until CP-R04 is applied.
- `linh-can.md` rule 8, rule 8a and edge case line 935: the unowned-purity and purity-0 wording (CP-R01).
- `item-database.md` line 240 (authored manuals copy `value`, `bonuses`, `layers`): recheck once `effects`, `tags` and body defence are final.

## Still sound

Formulas A to F arithmetic and the pacing tables, registry values this GDD owns, rule numbers cited in the dependency GDDs, the harmony table counts (5 / 10 / 10), the Realms and Meridian Map links, and the dependency graph (every depended-on GDD exists on disk; systems without GDDs are marked provisional).

## User answers and applied fixes (2026-11-10, same session)

- D-1: a named element the root does not own is usable from purity 10 (`tech_foreign_purity_min`, registered); rule 8, rule 9, States, AC-CP-07; Spiritual Roots rule 8 matches.
- D-2: `iron_tier(k) = 1 + floor((k − 1)(T − 1) ÷ (layers − 1))`, T = t + 2; `body_defence` derived, not a field; AC-CP-23 middle values.
- D-3: Combat's Qi Refining thể tu is marked a formula fixture in combat-defence.md (Formulas G and the fixture list) and combat.md; re-deriving the worked example at Core Formation is left to the harness re-fit (Combat Open Question 6). Not yet re-derived.
- D-4: wide-art harmony kept and noted in Edge Cases.
- Applied: CP-R01 to CP-R11. Also retired rule 15 (Meridian seals), `seal_clusters`, `seal_seasons`, AC-CP-10 and AC-CP-38's seal cases, Open Question 12, the registry `cong_phap_seal_seasons` (deprecated), following the Meridian Map re-review KMD-R06 and the user's 2026-11-09 scrapping of sealed clusters.
