# Combat revision (#43): decision triage, D5 to D19

I changed no files. "Settled" below means I found the answer in an approved GDD or a recorded user answer. For D5 to D9 and D16 to D19 I found no text that settles them. I searched with keyword greps and did not read the GDDs end to end, so a rule I missed could change a status, but none is expected. I did not re-run any number. Every figure quoted was read from the file named.

## Summary table

| ID | Status | One-line summary |
|---|---|---|
| D5 | CHANGED | Derived art tags: thresholds are already in the approved Modifiers GDD. Only "does Combat adopt them" is left. |
| D6 | OPEN | Does `start_qi_share` apply to the usable maximum? Defence rule 10 only settles the default case. |
| D7 | CHANGED | Which damage-type mix ehp and `display_power` use. Defence now gives per-type ehp, so the question is sharper. |
| D8 | OPEN | Enemy coverage groups for rule 18. No GDD decides them. |
| D9 | CHANGED | Trigger wards. Effects already has "raise or lower a ward" and live changes were answered. Only retiring the two keys is left. |
| D10 | SETTLED | Down step against overkill and draws. Written into effects.md rule 11 by user decisions. |
| D11 | CHANGED | Ticks. Resistance and per-tick billing are settled. Penetration, its snapshot and the floor of 1 are not. |
| D12 | CHANGED | The healing floor is settled. The Slackened Soul unit is not. |
| D13 | SETTLED | Standing statuses are exempt from the duration lint. |
| D14 | SETTLED | Keep both ways of paying in health. Effects records the difference. |
| D15 | OPEN | Retire Combat's duplicate ACs into pointers. This is a #43 housekeeping choice. |
| D16 (Minor) | OPEN | The Advisor threshold. The recommendation stands, with one caveat. |
| D17 (Minor) | CHANGED | Tag vocabulary. A "status" tag family now exists. Where `bleed` and `seal` sit is still unstated. |
| D18 (Minor) | OPEN | Where the defence data keys live. |
| D19 (Minor) | OPEN | Shield recharge on the millisecond timeline. |
| New N1 | OPEN | Order of conversion Effects by host (Damage Types DT-01, round c). |
| New N2 | OPEN | Per-part scaling of conversions (Damage Types DT-04, round c). |
| New N3 | OPEN | Nothing limits stacked Chaos conversion (Effects EF-05, round c). |

N1 to N3 are not on the draft's list. The reviews left them as DECISION and they change what #43 writes about conversion.

---

## Settled items: evidence

**D10: Down step and overkill.**
- effects.md:211-215 says refusals run first and a refusal is not healing.
- effects.md:216-218 says last acts resolve once and the side making one cannot refuse again.
- effects.md:225-231 reads "user decision 2026-11-08, re-review EF 7": the requesting side resolves first, and a Down side keeps its overkill. It adds "user decision 2026-11-08b, EF-05": a last act's damage counts toward its target's overkill, so it can swing a double knockout, and equal shares are a draw.
- Effects Formulas C and AC-EF-29 repeat this.
- Left for #43: write it into Combat rule 10 (items 4, 31, 62).

**D13: standing statuses.**
- effects.md:285 puts Corpse Rot at "Never ends on its own". effects.md:290 says standing statuses are bound by the tick caps and their standing cost instead of a duration.
- AC-EF-17 and AC-EF-25 test it.
- Left for #43: write the lint exemption (items 50, 76).

**D14: two ways to pay in health.**
- effects.md:145 reads "it can put the side Down, and the Down step, refusals included, then runs as usual".
- effects.md:395 (Blood Casting) says the same.
- AC-EF-07 tests it.
- Left for #43: record that `body_cost_share` floors at 1 and Effects does not (items 23, 48).

---

## OPEN and CHANGED items

### D5. Derived art tags (CHANGED)
- **Question:** The Modifiers GDD is approved and already defines `quick` (authored cooldown under 2 s), `slow`, `cheap` (cost share 5 % or less) and `costly` (20 % or more). Does Combat adopt `basic`, `quick`, `slow`, `cheap` and `costly` in #43?
- **Why it changed:** The thresholds are no longer a proposal. They are in modifiers.md:186-190, in AC-MD-13 and in a tuning-knob row (modifiers.md:1003). Modifiers OQ 2 (modifiers.md:1069) names the user as the owner and #43 as the time. Until Combat adopts them, those scopes are Pending and add nothing. This also holds Bare Rack's `basic` half Pending (effects.md:333).
- **Options:**
  - **A.** Adopt all five, assigned at compile from authored cooldown and cost.
  - **B.** Adopt `basic` only.
  - **C.** Defer all of them.
- **Recommendation:** A. The thresholds and the "authored" basis are already written down, and B or C leaves Pending rows in the catalogue.
- **Blocks:** 8, 16.

### D6. Starting shares and reservation (OPEN)
- **Question:** When a Tribulation wave sends `start_qi_share`, does the share apply to `qi_max` or to the usable maximum `qi_max · (1 − Σ reserved)`?
- **Evidence:** combat-defence.md:213 says "Linh lực starts at" the usable maximum, but only for the default start. combat.md:370 still says `qi_start = qi_max · start_qi_share`.
- **Options:**
  - **A.** Apply the share to the usable maximum.
  - **B.** Apply it to `qi_max`, then clip to the usable maximum.
  - **C.** Ignore reservation for shared starts.
- **Recommendation:** A. It matches rule 10, and a reserved aura stays held between waves.
- **Blocks:** 5, 40.

### D7. Damage-type mix for the rating and `display_power` (CHANGED)
- **Question:** Defence ehp now depends on damage type. Which mix does the rating use in a clash, and which does `display_power` use?
- **What changed:**
  - The thể tu at Qi Refining now has ehp 570.4 against Physical, 368.5 against Force and 221.3 against Chaos (combat-defence.md:725-730). The draft's 570 and 221 were rounded.
  - Healing stays out of `display_power`'s ehp (combat-defence.md:737).
  - ehp leaves out any shield the damage type passes (Formulas G, combat-defence.md:699). So the mix also decides which shields count.
- **Options:**
  - **A.** In a clash, each side's ehp uses the attacker's own type mix. `display_power` uses a fixed `reference_type_mix` fitted by the harness.
  - **B.** Use one fixed mix everywhere.
  - **C.** Use the worst type for `display_power`.
- **Recommendation:** A. A clash is about a specific attacker. A fixed reference mix keeps the displayed number stable.
- **Blocks:** 17, 56, 58, 77.

### D8. Enemy coverage groups for rule 18 (OPEN)
- **Question:** Which damage-type groups must each realm's enemies cover, both dealing and resisting?
- **Evidence:** No GDD decides this. Resistance is per final type after conversion (combat-defence.md:93-96), so a group means "final type".
- **Options:**
  - **A.** Four groups: Physical/Force; Fire/Cold/Lightning/Light; Chaos; Soul.
  - **B.** One group per type (8).
  - **C.** Three groups, with Chaos folded into the elements.
- **Recommendation:** A. Chaos and Soul each have a different defence path (they pass body shields, or pass everything but soul shields). Grouping any elements with them would hide that.
- **Blocks:** 18.

### D9. Trigger wards (CHANGED)
- **Question:** Retire `trig_ward_strength` and `trig_ward_seconds`, and let a trigger use Effects' "raise or lower a ward" action with its duration on the Effect record?
- **Why it changed:** effects.md:143 already lists "Raise or lower a ward, or change its payload while a condition holds". The live-change question was answered: the 2026-11-08b report (CD-08) says AC-CD-49 "contradicts the live-change answer". What I found nothing on is a duration field on the Effect record, or retiring the two keys.
- **Options:**
  - **A.** Retire both keys. Put the duration on the Effect record.
  - **B.** Keep the keys as defaults for the action.
  - **C.** Retire the keys but allow only condition-bound changes, with no durations.
- **Recommendation:** A. It matches the Effects action table, and the expiry-millisecond rule stays (combat-defence.md:158).
- **Blocks:** 4, 11, 53, 59, 65, 75.

### D11. Ticks under the new path (CHANGED)
- **Settled:**
  - A tick uses the resistance of its own type (combat-defence.md:95, 267-268).
  - A per-hit ward charges one fee per tick (combat-defence.md:170).
  - AC-CD-68 shows the default ward billing 6.0 on a tick of 10.
- **Still open:** I found no text on whether resistance penetration applies to ticks, whether it is snapshotted at application, or where the floor of 1 sits.
- **Question:** Does the attacker's penetration of the tick's type apply to its ticks, and is it taken when the status is applied? Does the floor of 1 apply only to what reaches health?
- **Options:**
  - **A.** Apply penetration, snapshotted at application. The floor applies to health only.
  - **B.** Apply penetration live each pulse.
  - **C.** Ticks ignore penetration.
- **Recommendation:** A. A snapshot stops a later swap of gear from rewriting an old burn. The floor on health only keeps shields and wards billing true amounts.
- **Blocks:** 9, 50, 76.

### D12. Curse units and stacking (CHANGED)
- **Settled:** the healing floor. Blood Casting and Withering share one floor at −50 % (effects.md:395, AC-EF-60 at effects.md:745). The plan's own note also says it was applied.
- **Still open:** the Slackened Soul unit. effects.md:305 reads "−0.15 per stack (`curse_soul_shred_max` 0.30)". The registry note (entities.yaml:3489) says "pending the Combat revision". The draft says `soul_res_pct` is in percentage points. I found no text on "never below 0".
- **Question:** Is the curse −15 pp per stack and at most −30 pp, with `soul_res_pct` held at 0 or above?
- **Options:**
  - **A.** −15 pp per stack, at most −30 pp, floor 0.
  - **B.** Keep the fraction −0.15 and convert at read time.
  - **C.** Let it go below 0, to the −50 % resistance floor (rule 3 uses −0.50).
- **Recommendation:** A. It matches the pp unit and the registry cap 0.30.
- **Blocks:** 49, 51, 76.

### D15. Duplicated acceptance criteria (OPEN)
- **Question:** Retire Combat's ward and body-guard ACs into pointers to Defence and Damage Types?
- **Context:** Defence now runs to at least AC-CD-69 and Damage Types has its own AC-DT range. Keep only what Combat owns: cross-system path order, the timeline, and same-millisecond expiry.
- **Options:**
  - **A.** Pointers, keeping Combat's three own topics.
  - **B.** Keep the duplicates, each citing its source.
  - **C.** Delete them with no pointer.
- **Recommendation:** A. Two copies of an AC drift apart.
- **Blocks:** 72-78.

### D16. Advisor warning threshold (Minor, OPEN; recommendation stands)
- **Question:** Fire the warning when the build's Physical ehp at 0 linh lực is below 1.25 × `health_max`?
- **Caveat:** Formulas G now counts shields in `P` (`P = H + S_std + S_body`), so builds with a shield no longer trip it. At 0 linh lực, x is 0 and ehp is `P / λ_fix` (combat-defence.md:699). So the drain-paid default ward drops out, which makes the 1.25 line meaningful.
- **Options:**
  - **A.** 1.25 × `health_max`, with the shield note.
  - **B.** 1.5.
  - **C.** A data knob.
- **Recommendation:** A, with the threshold read from data so the harness can move it.
- **Blocks:** 67, 77.

### D17. Tag vocabulary (Minor, CHANGED)
- **Question:** Do the cleanse tags `bleed` and `seal` go in the effect family, or in the new status family?
- **Why it changed:** modifiers.md:142 and 204 now list a "status family". The review answer was one tag per status, owned by the Effects Status Catalogue. Silence still carries `seal` as a cleanse tag (effects.md:300).
- **Options:**
  - **A.** Cleanse tags stay in the effect family (rule 6, Modifiers rule 9). The status family holds one tag per status.
  - **B.** Move cleanse tags into the status family.
  - **C.** Add both families.
- **Recommendation:** A. A cleanse tag names what removes an effect, while a status tag names the status itself.
- **Blocks:** 8.

### D18. Where the defence data keys live (Minor, OPEN)
- **Question:** Put them in a `defence` section of `combat_rules.json`, or in a separate file?
- **Evidence:** combat-defence.md says "data file" for every knob and names none.
- **Options:**
  - **A.** A `defence` section in `combat_rules.json`.
  - **B.** A separate `defence.json`.
- **Recommendation:** A. It means one fight data file, so one load and one validate.
- **Blocks:** 59.

### D19. Shield recharge on a millisecond timeline (Minor, OPEN)
- **Question:** Compute recharge when read at each event, creating no event of its own?
- **Evidence:** combat-defence.md:839 says `recharge_delay` restarts at the millisecond a shield soaks. I found nothing on how recharge advances on the timeline.
- **Options:**
  - **A.** Compute when read.
  - **B.** Schedule a recharge event.
- **Recommendation:** A. Recharge fires nothing, as with ward expiry, so an event would add nothing but ordering risk.
- **Blocks:** 4.

---

## New open items from the review logs

The Defence log (design/gdd/reviews/combat-defence-review-log.md, round 3) records these three as "Not applied, DECISION (open for the user)". They affect what #43 writes in rule 6. I did not map them to change-list item numbers.

- **N1. Conversion order by host (Damage Types DT-01).**
  - **Question:** Rule 6's host order is shorter than Effects rule 13's list of hosts. How are conversion Effects on a formation, talisman or root ordered?
  - **Options:** A: slotted hosts first (art slots, then equipped pieces in equip order, then talismans in slot order), then other hosts in Effects rule 13's list order, then record id. B: all unslotted hosts by record id alone. C: allow conversions only on hosts that already have an order.
  - **Recommendation:** A. It extends the existing answer and adds no mechanism.
- **N2. Per-part scaling (Damage Types DT-04).**
  - **Question:** Are conversions that sum over 100 % scaled per part or per step?
  - **Evidence:** At the default limit of 2 it cannot matter. It matters only if the knob is set to 3 (the worked case gives 0.25 against about 0.208).
  - **Options:** A: per part. B: once per step. C: fix the knob at 2.
  - **Recommendation:** A. It matches the Formulas A wording ("that apply to j").
- **N3. Stacked Chaos conversion (Effects EF-05).**
  - **Question:** About 7 notables at +15 pp each would turn all Physical into Chaos, which passes body shields. Is that acceptable?
  - **Options:** A: accept it and watch it in the balance pass. B: make Chaos-ending conversion rows rare. C: cap the Chaos share per hit.
  - **Recommendation:** A. It follows the recorded "slightly OP builds are fine" balance direction, and Chaos resistance is already rare.
---

## D2 applied: combat.md sites left for #43

D2 (role tags `ward`/`body` → `ward_gear`/`body_gear`) was applied on 2026-11-08 in item-database.md,
combat-defence.md, modifiers.md and the registry (`registry.sh validate` clean). combat.md was not edited. These
lines still need the rename in the Combat revision:

1. Line 337: the Item Database dependency row lists "(weapon, ward, body, utility)".
2. Line 338: the Artifact Refining row says "body guard if body-tagged".
3. Line 549: the `a_w` variable says "without the body tag".
4. Line 564: the `a_b` variable says "body-tagged items".
5. Line 1063: the interactions row says "Role tags (body, ward)".
6. Line 1227: Open Question 10 says "`body` is an authored role tag... Giáp is body and Thuẫn is ward".

N1 to N3 above were already decided by the user on 2026-11-08 (round 3, all option A) and are applied in
combat-damage-types.md and effects.md; the triage read a log note written before they were applied.
