# Design Review: `design/gdd/modifiers.md`

**Reviewed:** 2026-11-10, after Combat economy revision #44 (parts 4 and 5 plus the 2026-11-10 rulings R1–R5).
**Mode:** headless. No questions were asked and no files were edited.
**Skill:** the `design-review` skill call failed with an execution error, so this is a manual review of the whole GDD against the 8-section standard.
**Not run:** `python -I tools/design/modifier_catalogue.py` was blocked for approval, so AC-MD-27 (the 342-row catalogue match) is unverified.

## Verdict: NEEDS REVISION (minor)

The #44 *content* is mostly in place: the Stat List, the price table, the catalogue rows and rule 1's exception. The problems are two incomplete integrations and a lot of stale text.

- **Integrations:** the new `dampened` operation and the element-stack modifiers are not wired into the rest of the document.
- **Stale text:** several sentences, examples and acceptance criteria still carry pre-#44 numbers and caps. Each one contradicts the stat list, so AC-MD-08, AC-MD-17 and AC-MD-21 would fail as written.

Nothing here needs a design rethink. It is a consistency sweep plus two small design gaps.

## Section completeness

The workflow mode was not resolved. Assuming `full`, 7 of 8 sections are present as headings.

| Section | State |
|---|---|
| Overview | Present, with a Summary |
| Player Fantasy | **Missing as a heading.** Only Game Feel and UI cover it. It is a Foundation system with no player-facing fantasy; one short paragraph would do |
| Detailed Rules | Present (Detailed Design) |
| Formulas | Present: A–E plus Realm drift, with variables and examples |
| Edge Cases | Present, but not updated for #44 (see M3) |
| Dependencies | Present |
| Tuning Knobs | Present, but not updated for #44 |
| Acceptance Criteria | Present, but 3 of 34 criteria are stale and #44 coverage is thin |

## Major findings (design gaps)

**M1. The `dampened` operation (rule 6a) is not integrated.**
- Rule 6a says "both regeneration stats accept the `D` op".
- The Stat List legend defines only F, I and M.
- `linh_luc_regen_pct` and `health_regen_pct` are listed as F only.
- `art_cost_health_pct` is listed as "F (pp, dampen-shaped)", with rule 6a as the only pointer. Rule 1 says `op` must be one the stat allows, so there is no valid record for it.
- Rule 6a gives `stat = value ÷ (1 + Σ dampened/100)` but does not say how it composes with flat and increased. The candidate is `(base + Σflat)·(1 + Σinc) ÷ (1 + ΣD)`. It also does not say how it composes with the regeneration log curve (`regen_k · ln(1 + bonus/regen_k)`), which is not a plain `value`.
- Cross-document rule: "Penalties apply after ceilings" (rule 3) is silent on dampened.
- There is no validation edge case and no AC for any of this.

**M2. Element-stack modifiers are only half-specified.**
- `stack_effect_pct`, `stack_duration_pct` and `stack_grant` are in the Stat List and price table but not in the General Catalogue or the Rare table. The 342 count therefore omits them.
- The target "the element's stacks" is not among the rule 8 scope targets. Nothing defines how an element scope plus buff/debuff is expressed. "Buff" and "debuff" are not in the tag vocabulary, and the family tag `stacks` is not in the rule 9 stat-family row.
- `stack_grant` is marked rare at 8 W per stack. Rule 13 lists the rare counts and does not include it, and the stated rare range is 10–30 W, so 8 W falls below it.
- Effects rule 9a owns these records and Effects is still marked "Needs revision". This GDD cannot be closed until the scope contract is agreed there.

**M3. Scope contradicts the E3 catalogue rows.**
- Rule 8 says a stat with target "none" cannot be scoped, and the Stat List gives `linh_luc_regen_inc_pct` target "none".
- The catalogue lists element-scoped rows for it (count 5).
- `linh_luc_on_hit_pct` and `leech_linh_luc_pct` have target "own hit". Rule 8 has no such target, and a hit-event stat scoped by element or form needs a matching rule.
- Either add targets for pool, hit-event and art-event stats to rule 8, or drop the scoped rows. E3 asked for them, so the first is the better fix.

## Stale text left over from #44

These contradict the Stat List and price table, which are the current values.

| Where | Says | Should say |
|---|---|---|
| Rule 7 and Edge Cases "stat's sum passes its owner's cap" | Caps include health regeneration 2 pp, linh lực regeneration 8 pp and resistance 0.75 | Both regeneration caps were removed. Resistance is 0.90, with `resist_cap_max` 0.95 |
| Edge Cases, "single modifier larger than its cap" | A parenthetical already notes health regeneration has no cap | OK, but the sentence above it still lists the old caps |
| Catalogue note under the table (line 659) | "A notable of health regeneration (+2.66 pp) is above the stat's own 2 pp cap" | The notable is +0.80 and there is no cap. Delete the note |
| Open Question 5 | Same 2.66 pp / 2 pp claim | Same fix |
| Rare table, Resistance cap raise | "to 90 %" | 95 % (F2 and the Stat List row) |
| Formulas A, Body shield | 1.0 W per pp (F) | 0.51 (the Stat List says 0.51, and the Formulas A table has both values) |
| Formulas C worked examples | A notable of art cost is −6.6 %, and a small of linh lực regeneration is +0.15 pp/s | −13.3 %, and +0.05 pp/s |
| Formulas E example | Maximum health +1.0 % / +6.6 % | +2.0 % / +13.3 % |
| Rule 9 status family | Lists `frostbite` and `shock` tags | D1 retired them. Burn and Poison are now stack debuffs, so re-check the tag list against Effects |
| Last Verified header | 2026-11-08 | Needs re-verification |
| Stat List legend | Ops are F, I, M | Add D |
| `art_cost_health_pct` price note | "10 W buys about 28.5 pp" | 0.35 W gives 22.8 pp at 8 W, which is consistent. The note should say the 0.35 W is measured near-linear and dampening shifts less per point |

## Acceptance Criteria problems

Failing or stale:
- **AC-MD-08** says a notable of health regeneration is +0.81 pp. The catalogue and 8 / 9.9 give 0.80.
- **AC-MD-07** says a resistance sum of 0.95 applies 0.75. It should be 0.90, or 0.95 with a raised cap.
- **AC-MD-17** has the −6.6 % and +0.15 pp/s examples. They are now −13.3 % and +0.05 pp/s.
- **AC-MD-21** has `body_shield_pct` F 1.0. It is 0.51 now. Its rounding-lint claim for regeneration at small also changed: at 22.8 W on the 0.01 grid the loss is about 5 %.
- **AC-MD-27** needs the script run to confirm 342, and the stack rows must be added if they join the catalogue.

Missing coverage for #44:
- `dampened`: the formula, the 100 % to half and 200 % to a third cases, never reaching 0, and rejecting `D` on a stat that does not allow it.
- `art_cost_health_pct`: its own behaviour, including "never below 1 health". AC-MD-33 only covers `linh_luc_on_hit` and `leech_health`.
- Per-key coverage of `linh_luc_on_crit_pct`, `linh_luc_on_kill_pct` and `leech_linh_luc_pct`.
- `linh_luc_regen_inc_pct` and `health_regen_inc_pct`, in particular how they compose with the log curve.
- The stack modifiers, once M2 is settled.
- AC-MD-33 sits out of order, between AC-MD-27 and AC-MD-28. Renumbering would break references, so move it only if no other document cites it.

## Minor

1. **Guessed prices.** Several #44 prices are marked G: `linh_luc_on_crit` 6.3, `linh_luc_on_kill` 0.5, `health_regen_inc` 0.3, and the three stack stats. Combined with the ±30 % simulator noise on measured values, the Tuning Knobs "±30 % per stat" range is as wide as some of the differences between stats. That is acceptable under the balance-depth direction. Say so in the knobs table and do not tune further.
2. **Tuning Knobs.** No new knob is listed for the #44 items (the dampen shape, the sustain exception key list, `rounding_lint_threshold` exceptions for the new stats). Run the rounding lint on the new rows: `linh_luc_on_kill` small is +2.4 pp per kill and `linh_luc_on_hit` small is +0.03 pp.
3. **Cross-document drift.** Dependencies still show "Not yet" for several readers, and Combat Defence & Healing "Needs revision". The decisions doc says a fresh review of Combat, Defence and Effects is still owed. This review depends on theirs, especially for M2.
4. **No Pillar 2 conflict.** The sustain exception is bounded (five named keys), and the dampen shape is the user-requested replacement for caps. Both fit the "every number bounded and visible" pillar.

## What is good

- The sustain exception is narrow and names its keys. Rule 1 is unambiguous, and AC-MD-33 tests its main case.
- The Stat List and General Catalogue agree with each other where I checked (health regeneration, linh lực regeneration, on-hit, leech and the shifted-cost rows). Spot checks of grid rounding were correct.
- The #44 pricing basis is traceable: each re-price names its simulator source and marks measured (D) against guessed (G).
- Rule 6a's design is sound: the `1/(1+D/100)` shape needs no cap, and the Stagnation and art-speed precedent is consistent.

## Recommended order

1. Fix M1 by adding `D` to the legend and the two regeneration rows, and by stating how `dampened` composes with flat, increased and the log curve. Then settle `art_cost_health_pct`'s op. This is a small design decision for the user.
2. Resolve M2 and M3 with Effects rule 9a, so the scope targets and the stack rows are settled once. The user decides; these are design calls, not typo fixes.
3. Sweep the stale-text table and the five failing ACs. These are mechanical.
4. Run `modifier_catalogue.py` and update the 342 count if it changes.
5. Add the missing ACs and a Player Fantasy paragraph.
6. Re-run `/design-review` after Effects is revised.

Nothing was written, and no commit was made.