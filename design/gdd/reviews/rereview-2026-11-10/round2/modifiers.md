I'm finishing the confirming review of `design/gdd/modifiers.md`. The round-2 reviewer outputs (`round2/*.json` and `.err`) are all empty, so I checked the file against the triage list myself. I read only the GDD and the triage, edited nothing, and did not re-check combat, combat-defence, effects or the registry.

**Review: modifiers.md. Verdict: NEEDS REVISION (minor).** Most of the fixes landed, but a few stale resistance-cap references and the missing ACs remain.

**Landed**
- The `D` (dampened) op, its compose rule and the legend.
- Scope targets for the pool, hit-event and stack stats.
- The stack rows in the catalogue.
- `resist_cap_pct` retired as a row.
- Edge Cases cap text.
- The 0.51 body shield in Formulas A and AC-MD-21.
- AC-MD-07, 08, 17 and 21.

**Still wrong, most important first**
1. **No new ACs for the new rules (modifiers.md, Acceptance Criteria).** The triage promised ACs for dampened composition, shifted art costs and the new keys. None exist. The last AC is AC-MD-33, which covers only sustain. Nothing tests `÷ (1 + ΣD/100)`, the regeneration-curve ordering, `art_cost_health_pct`, `stack_effect_pct` / `stack_duration_pct`, or the 10 W `stack_grant`.
2. **Stale resistance-cap text:**
   - Line 141 (rule 8, incoming hit) still says "resistance and the resistance cap raise (`resist_cap_pct`)". Cap raises are retired.
   - Line 249 (rule 13) still lists "the resistance cap raise" among the rare stats.
   - AC-MD-23 still says "Chaos resistance or a resistance cap raise on a tree notable". Cap raise no longer exists.
   - Line 301 (Combat: defence families) still lists "resistance, cap, foe resistance".
3. **Header not updated.** `Last Updated` is 2026-11-09 (#44 part 4), and the Status block never mentions the 2026-11-10 re-review fixes or the dampened op. `Last Verified` is 2026-11-08.
4. **Edge Cases still says validation rejects "resistance scoped by an element tag"** (line 943). This is likely still right, but it should be checked against the new scope-target wording.
5. **Edge Cases on a dampened stat is missing.** There is nothing on negative dampen, on dampen with no `increased`, or on Stagnation stacking.
6. **Not checked:** I did not verify the Formulas C and E examples beyond AC-MD-17/20/21. I also did not verify the AC-MD-27 catalogue count of 342 against the generator, and I did not run `tools/design/modifier_catalogue.py`.