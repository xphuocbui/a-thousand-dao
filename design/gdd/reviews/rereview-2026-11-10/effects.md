## Design Review: Effects System (Hiệu Ứng), `design/gdd/effects.md`

Specialists consulted: none. I ran this as a single-session lean review. The skill's full mode needs spawned agents, and the headless run did not ask for them, so there is no `game-designer`, `systems-designer`, `qa-lead` or `creative-director` pass.
Re-review: Yes. The prior verdict was NEEDS REVISION on 2026-11-08 (log `reviews/effects-review-log.md`, 8 entries, the latest being 2026-11-08b). The #44 changes of 2026-11-09 and 2026-11-10 came after that review.

**What did not run:**
- Both helper scripts were refused permission in this headless session: `gdd-structure-check.sh` and `review-receipts.sh check`. So there is no deterministic section report and no byte-identity check. I read the whole document by hand instead. Every prior entry is lean and some have no content receipts, and the document has changed since, so a full review was due anyway.
- I did not grep the registry for the full list of entry names, and I did not cross-read every related GDD. Only the targeted checks listed below were done.

### Completeness: 6/6 required at `standard`
Workflow tier is taken as `standard`, which is what the prior log entries record. I could not confirm it against `project.yaml`.
- Present: Overview, Detailed Design (accepted as Detailed Rules), Formulas (the system has numeric rules, so it is required), Edge Cases, Dependencies, Acceptance Criteria.
- Advisory at `standard`: Player Fantasy has no heading of its own. Overview and Game Feel carry it. Tuning Knobs is present.

### Dependency Graph
- ✓ Modifier System: `modifiers.md`
- ✓ Combat: `combat.md`
- ✓ Combat Defence & Healing: `combat-defence.md`
- ✓ Combat Damage Types: `combat-damage-types.md`
- ✓ Character Stats: `character-stats.md`
- ✓ Realms: `canh-gioi.md`
- ✓ Heavenly Tribulation: `thien-kiep.md`
- ✓ Meridian Map: `kinh-mach-do.md`
- ✓ The Way: `dao.md`
- ✓ Cultivation Techniques: `cong-phap.md`
- ✓ Item DB: `item-database.md`
- ✓ Spiritual Roots (cited in rule 9a): `linh-can.md`
- ✗ Talismans, Formations, Alchemy, Spirit Beasts, Event Engine, NPC Builds: no GDD in `design/gdd/`. The document already says so in Open Questions 10, so this is a known gap and not a new one.
- The Dependencies table has no row for Spiritual Roots, even though rule 9a and Formulas D now depend on `linh-can.md` rule 8a (purity powers stacks). That GDD does define the rule (`linh-can.md:204`).

### Registry Values
I searched `design/registry/entities.yaml` for entries sourced from or referencing `effects.md`.
- Found: `counted_chance`, `standing_status`, `down_step`, `curse_heal_taken_max`, `curse_soul_shred_max`, `curse_bounds`, and `dot_pool_cap`. No value conflicts with the GDD for those.
- **Stale reference:** `dot_pool_cap` is deprecated by #44 but still lists `effects.md` in `referenced_by`. The GDD still talks about tick caps in several places (see Required item 1).
- **Not registered:** none of the #44 element-stack facts has an entry. That covers the per-stack table, `cleanse_share` 0.25, `w_kind` 0.010 / 0.015, the charge cap 0.6, and Burn and Poison `c_tick` 0.019 (searches for `per_stack`, `0.019`, `element_stacks`, `cleanse_share` and `w_kind` returned nothing). Several numbers are now stated in more than one place (rule 9a, Formulas D, Tuning Knobs, the Status Catalogue and the AC list), with no registry entry to arbitrate. Re-measuring or refitting a value therefore carries drift risk.
- The full-document registry-name grep from Phase 3 was not run.

### Required Before Implementation
1. **Stale tick-cap and heal-cap text contradicts #44.** [main review]
   - Rule 7 (line 172) still lists "the heal and tick caps" as caps that stay with their owners.
   - The Corpse Rot row (line 331) says "Counts inside both tick caps". Rule 6 and the status-catalogue header say there are no tick caps.
   - AC-EF-25 asserts "neither is capped per tick or per pulse". AC-EF-25 and the Corpse Rot row cannot both be true.
   - Line 720 (Cross-References) still says "tick caps".
   - A programmer would not know whether to implement a cap. Remove or reword each of these.
2. **AC-EF-16 tests a retired status.** [main review]
   - It says "GIVEN Shock recast, THEN its duration refreshes and it does not stack." Shock is retired, and AC-EF-22 says load rejects a status named Shock.
   - These two criteria contradict each other, and AC-EF-16 is untestable as written. Replace it with a live status that refreshes, such as Exposed or Leaking Ward.
3. **Combat Defence & Healing does not define the cleansing ward.** [main review]
   - Rule 9a and Formulas D make the cleansing ward (`cleanse_share`) the main answer to stack piles. They also say tribulations may forbid it.
   - A search of `combat-defence.md` and `combat-damage-types.md` found no mention of cleansing ward or element stacks. The ward family is owned by Combat Defence & Healing (rules 5–9), and the Dependencies table lists that GDD as "Needs revision".
   - Until the ward record, its slot and pulse timing, and its interaction with Combat rule 10 exist there, the central counter to the new mechanic has no owner. Add the ward kind in `combat-defence.md`, or state here that this GDD owns it.
4. **Boundary rules are specified only inside Acceptance Criteria.** [main review]
   - AC-EF-68 removes any batch "below 0.05 stacks", but Formulas D never states that threshold or where it lives as a knob.
   - AC-EF-69 and the Formulas D example (charge 0.28 → c_art 3.55 × 0.72 = 2.556) say "2.55 passes, 2.56 fails". Rounding 2.556 gives 2.56, which would pass under normal rounding.
   - State the rounding rule (floor or round, and at what decimal), and put the 0.05 threshold in Formulas D and Tuning Knobs. At present the AC is the only spec for both.
5. **Stack-per-second charge has no defined window for "for the fight" or long batches.** [main review]
   - `charge = Σ w_kind · stacks · seconds`, with `charge ≤ 0.6`. Rule 9a allows batches "for the fight", and Effects (unpriced) may also grant stacks.
   - The GDD does not say what "seconds" is for a whole-fight batch, so the lint cannot be computed. Fight length varies, and 30–60 s is the target. Define a fixed lint horizon or forbid whole-fight batches on arts.

### Recommended Revisions
1. **Header and status drift.** `Last Verified: 2026-11-08` is older than the #44 revisions of 2026-11-09 and 2026-11-10. The Status line and Last Updated do not mention the 2026-11-10 changes (equal-value stacks, Stagnation as dampened, removal of the two-sided discount). Update them so the next review's receipt is meaningful.
2. **Rule 9's status bounds are no longer true.** The Status Catalogue note says Combat Formulas F bounds `c_tick` at 0.15–0.5, a stack cap of 5, and the lint `c_tick · duration ≤ 1.2 · c_art`. Burn and Poison use 0.019 with no stack cap. Rule 9 and the AC-EF-16 wording should say Burn and Poison are exempt, with the Formulas D charge replacing the Formulas F lint for them.
3. **Standing status example.** Formulas B's example (regen 6.05 against a 5.2 upkeep, "0.85 to spare") uses a fixture of 0.03. The catalogue's only standing status costs 0.02, which is 3.45. Use Corpse Rot's real number, or say plainly that 0.03 is a test fixture.
4. **Spiritual Roots dependency.** Add `linh-can.md` (rule 8a, Formulas H) to the Dependencies table as a Hard dependency for stack strength. Also record whether it lists Effects back.
5. **Status table for stackable debuffs vs Combat.** Combat Formulas F and Combat rules 7–8 are the owner of status caps, but the stack-based Burn and Poison now sit outside them. Confirm the Combat GDD has the same exemption, as part of #44's sweep.
6. **Heavy Breath vs Ice stacks.** Ice stacks bypass `curse_cost_raise_max` on purpose, so costs compound multiplicatively (AC-EF-65 shows ×1.5 × 2.17). There is no upper bound at all, so the Advisor in Combat UI should warn on it. Say so in UI Requirements, or add a floor that keeps arts castable.
7. **Test traceability.** AC-EF-45–47 sit after AC-EF-70 in the list, and the AC numbers are not in document order. This is harmless for QA, but a test file naming scheme keyed to numbers will be confusing. Reorder, or note that the order is by topic.
8. **Open Question 11** (stacked Physical → Chaos conversion) now interacts with Poison being Wood's debuff and passing every shield. Note the overlap so the balance pass measures both together.

### Specialist Disagreements
None. No specialists were run. The 2026-11-08 reviews flagged the same classes of issue, and items 1 and 2 above look like fallout from the #44 edit that missed other places, not new design problems.

### Nice-to-Have
- Collect the element-stack numbers in one table in Formulas D and have rule 9a link to it, so there is one place to refit.
- One AC for Wind and Earth accuracy and evade stacks against a foe with 0 evade, to pin the "no effect" case the Equal-value note implies.
- A short worked fight with 3 batches and a cleansing ward, to show the pulse ordering in prose.

### Senior Verdict [creative-director]
Not run. In my own reading, the #44 element-stack design fits the pillars (Power Is Built, Not Given; Every Number Is Bounded and Visible). "No cap on stacks" sits awkwardly with "Bounded" in Pillar 2, and the doc leans on cleansing wards to bound it, which makes item 3 above a design dependency, not a clerical one. The mechanics are largely coherent, and the blockers are leftover contradictions from #44 plus one unowned counter-mechanic.

### Scope Signal
Rough scope signal: **L** (producer should verify before sprint planning). There are 4 formula families (A–D), 12+ dependencies across the Combat, Modifier and host GDDs, a closed action list of about 25 actions, and about 70 acceptance criteria. Element stacks as a new subsystem likely need an ADR for the batch and timer model.

### Verdict: NEEDS REVISION

Blocking items: 5. Recommended: 8.

The review log was not appended and the systems index was not touched, because the run was headless and read-only. A log entry would need the receipt hash line from `review-receipts.sh hash`, which also did not run.