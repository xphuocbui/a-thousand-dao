# Combat revision (#43): draft plan, 2026-11-08 (overnight)

**Result:** combat.md needs **76 changes** to point at the four new GDDs. They are numbered 1–78; items 29 and
36 only point to where their change is made. 19 decisions come first: **4 before
the revision starts**, 11 during it, and 4 minor ones where the recommendation can stand unless you object.
I estimate **5 sessions to apply it, plus 1 for a design review**.

Nothing was edited. combat.md, the four new GDDs, the registry and the index are unchanged, and nothing was
committed. This is the only file written.

Sources (read as they are now, after tonight's review fixes): combat-defence.md (#21a), combat-damage-types.md
(#21b), modifiers.md (#40), effects.md (#41), and tonight's `consistency.md` (findings N1, N2, N5, N6, N13, K6,
K9, K10).

Short names below: **Defence** = combat-defence.md, **Types** = combat-damage-types.md, **Modifiers** =
modifiers.md, **Effects** = effects.md. "rule 4" with no file name means combat.md.

---

## 1. Decisions needed

### Before #43 starts (they change what #43 writes)

> **Decided 2026-11-08 (user):** D1, D2 and D3 as recommended. D4 is done: the blockers were answered and
> applied, with one change from the recommendation: **shields are uncapped** (`shield_total_cap` and
> `body_shield_cap` are off-by-default knobs; AC-CD-59 checks for stalls). D12's healing floor and D13's
> standing-status exemption were also applied with the review items. To do before #43: move ws, we, the gear
> term, `ward_floor`, `ward_cap`, a_w and a_b into Defence Formulas A (D1); rename Item DB's role tags to
> `ward_gear` / `body_gear` (D2); write the soul-shield formula in Defence (D3).

| # | Decision | Recommended | Blocks items |
|---|---|---|---|
| D1 | **Where do ward strength and ward efficiency (`ws`, `we`) live once Formulas D is deleted?** The `ws` gear term (`100 · ward_gear_scale · a_w`, which gives the typical 30.8), `ward_floor`, `ward_cap` and the `a_w` / `a_b` definitions exist only in Combat D. Defence cites "Combat Formulas D" for them (consistency N5) | Move them into Defence Formulas A before #43, and leave a short stub in Combat D that points there | 44, 60, 73 |
| D2 | **Artifact role tags, and what `a_w` means** (N1). Item DB uses `ward`, `body`; Modifiers uses `ward_gear`, `body_gear`. `ward` clashes with the mode tag `ward`. Defence A2 calls `a_w` "ward-role" defence, but Combat D and Item DB count all non-body defence | Rename to `ward_gear` / `body_gear` (Item DB is the owner). Keep `a_w` = all non-body defence, which is what the 0.85 × B_p anchor assumes | 34, 60, 68 |
| D3 | **The soul shield formula** (N2). Defence gives soul wards a soul shield ("soaking 50 % of each soul hit"), but no formula. Combat rule 24 and E2 say soul hits ignore every ward | Defence defines it first: the soul shield takes `soul_shield_share × pct` off each pool loss, after E2's `pct`, and its own bar is spent first. #43 then adds that term to E2 | 20, 49 |
| D4 | **Three of tonight's review blockers rewrite Combat text.** Types blocker 1 (mixed Soul hits), Types blocker 2 (same-step conversions), Defence blocker 2 (drain billing for block payloads, `r_eff < 0`, `R_pos = 0`) | Answer them as the reviewers recommended (summary file). Then rule 6 and E2 take Types' answers, and Formulas C and K take Defence's | 8, 20, 46, 56 |

### During #43

> **Decided 2026-11-08 (evening, user), after the triage in `combat-revision-triage.md`.** D2 is applied in
> Item DB, Defence, Modifiers and the registry (6 combat.md sites remain for #43, listed at the end of the triage).
> Settled by the approved GDDs: D10 (effects.md rule 11), D13 (standing statuses exempt), D14 (both ways to pay in
> health kept). Answered, all as recommended:
> - **D5** adopt `basic`, `quick`, `slow`, `cheap`, `costly` with the thresholds in modifiers.md rule 10.
> - **D6** `start_qi_share` applies to the usable maximum `qi_max · (1 − Σ reserved)`.
> - **D7** a clash uses each attacker's own damage-type mix for ehp; `display_power` uses a fixed
>   `reference_type_mix` fitted by the harness.
> - **D8** four coverage groups: Physical/Force; Fire/Cold/Lightning/Light; Chaos; Soul.
> - **D9** retire `trig_ward_strength` and `trig_ward_seconds`; a trigger uses Effects' "raise or lower a ward"
>   action with its duration on the Effect record.
> - **D11** resistance penetration applies to ticks, snapshotted when the status is applied; the at-least-1 floor
>   applies only to what reaches health.
> - **D12** Slackened Soul is −15 pp per stack, at most −30 pp, and soul resistance never goes below 0.
> - **D15** Combat's duplicate ward and body-guard ACs become pointers; Combat keeps path order, the timeline and
>   same-millisecond expiry.
> - **D16** the Advisor warns when Physical ehp at 0 linh lực is below 1.25 × `health_max`, the threshold a data knob.
> - **D17** cleanse tags stay in the effect family; the status family holds one tag per status.
> - **D18** the defence keys go in a `defence` section of `combat_rules.json`.
> - **D19** shield recharge is computed when read; it schedules no timeline event.
> Also settled for #43's rule 6 (round 3 reviews, all option A): conversion host order, per-part scaling, stacked
> Chaos conversion accepted.

| # | Decision | Recommended | Blocks items |
|---|---|---|---|
| D5 | **Adopt the derived art tags** `basic`, `quick` (cooldown under 2 s), `slow` (6 s or more), `cheap` (cost share 5 % or less) and `costly` (20 % or more)? (Modifiers OQ 2, rule 10) | Adopt them as proposed. Combat assigns them at compile, from **authored** cooldown and cost, so art speed and cost cuts never change them | 8, 16 |
| D6 | **Starting shares versus reservation.** A Tribulation wave sends `start_qi_share`. Defence rule 10 starts linh lực at the usable maximum, `qi_max · (1 − Σ reserved)` | The share applies to the **usable** maximum. A reserved aura then stays held between waves | 5, 40 |
| D7 | **Which damage-type mix the rating and `display_power` use.** Defence's ehp now depends on damage type (the thể tu has 570 against Physical but 221 against Chaos) | In a clash, each side's ehp uses the attacker's own type mix. `display_power` uses a fixed mix in data (`reference_type_mix`) that the harness fits | 17, 56, 58, 77 |
| D8 | **Enemy coverage groups for rule 18** (and Thiên Kiếp, N3) | Four groups: Physical/Force; Fire/Cold/Lightning/Light; Chaos; Soul. Each realm has an enemy that deals each group, and one that resists each | 18 |
| D9 | **Trigger wards** (`trig_ward_strength` 50, `trig_ward_seconds` 2 s). A trigger "adds this to ws for this long" | Retire both keys. A trigger that raises a ward becomes Effects' "raise or lower a ward" action, with its duration on the Effect record. The expiry-millisecond rule stays | 4, 11, 53, 59, 65, 75 |
| D10 | **Down step against the overkill and draw rule.** Effects' Down step (refusals, then last acts, then a follow-up check) has to fit rule 10's defeat check | Refusals and last acts run **before** the overkill comparison. A last act resolves as a follow-up instant at the same t (no pulse, the draws continue in order). So a side with an unspent refusal beats a side without one, even on a double knockout | 4, 31, 62 |
| D11 | **Ticks under the new path.** Defence says ticks meet resistance, but not whether resistance penetration applies to them, whether drain wards bill for the tick damage they prevent, or where the floor of 1 sits | Penetration of the tick's damage type applies, snapshotted when the status is applied. Drain wards bill prevented tick damage like hit damage. The floor of 1 applies only to what reaches health. (Defence owns these rules; #43 writes them into Formulas F) | 9, 50, 76 |
| D12 | **Curse units and stacking.** Slackened Soul is "−0.15 per stack", but `soul_res_pct` is in percentage points. Withering and Blood Casting each give −50 % healing taken (K6) | Slackened Soul: −15 pp per stack, at most −30 pp, and `soul_res_pct` never goes below 0. Healing taken has one floor at −50 %, however the sources stack | 49, 51, 76 |
| D13 | **Standing statuses** (Corpse Rot) have no duration, so they break the duration 2–6 lint (K10) | Exempt them. The tick caps, the caster's upkeep (Effects Formulas B) and `c_tick ≤ 0.15` bound them instead | 50, 76 |
| D14 | **Two ways to pay in health.** Combat E's `body_cost_share` "cannot take health below 1". Effects' pay-in-health action "can put the side Down" | Keep both and say so: an art-record health cost floors at 1, and an Effect's health payment does not | 23, 48 |
| D15 | **Duplicated acceptance criteria.** Most of Combat's ward and body-guard ACs now test Defence's rules | Retire them into pointers to the AC-CD and AC-DT ranges. Keep only what Combat owns: path order across systems, the timeline, and expiry in the same millisecond | 72–78 |

### Minor (the recommendation stands unless you object)

| # | Decision | Recommended | Blocks items |
|---|---|---|---|
| D16 | **The Advisor's warning threshold.** Today it fires on "no ward and under 0.2 body guard mitigation" | Fire when the build's Physical ehp at 0 linh lực is below 1.25 × `health_max`. That is the same line: 0.2 mitigation means 80 % lands | 67, 77 |
| D17 | **Tag vocabulary** (N13). Bleed's cleanse tag `bleed`, and Sealed Meridian's and Silence's `seal`, are in no tag family | Add `bleed` and `seal` to the effect family in rule 6 and Modifiers rule 9 | 8 |
| D18 | **Where the defence data keys live** | A `defence` section in `combat_rules.json`, so there is one fight data file | 59 |
| D19 | **Shield recharge on a millisecond timeline.** A ward shield recharges per second once `recharge_delay` passes | Computed when read, at each event. Recharge creates no new event, because it fires nothing (like ward expiry) | 4 |

---

## 2. Session estimate

combat.md is 124 KB. Every rewritten example needs recomputing, and most ACs need restating.

| Session | Work | Items |
|---|---|---|
| 0 (before #43) | Answer D1–D4. Apply them in Defence, Types and Item DB, plus Defence's soul shield formula | — |
| 1 | Header, Summary, Overview, Core Rules 1–24, States | 1–36 |
| 2 | Formulas A–F and recomputed examples | 37–52 |
| 3 | Formulas G–K, Parameter keys, the Formulas D stub, Edge Cases | 53–63 |
| 4 | Dependencies, Tuning Knobs, Visual/Audio, UI, Cross-References, Open Questions; the companion edits (Section 4) | 64–70 |
| 5 | Acceptance Criteria: restate, retire or point (D15), and recompute the timeline fixtures (AC-CB-30, 49, 58) | 71–78 |
| 6 | `/design-review design/gdd/combat.md` in a fresh session | — |

**About 5 sessions to apply and 1 to review.** Sessions 3 and 4 can merge if the decisions are already made.
Session 5 can grow by one if the harness has to re-run the timeline fixtures (FX-T mirror, `health_units` limit,
Formulas K's T0), since they cannot be worked out by hand.

---

## 3. The change list

Each item gives the combat.md place, the text now (quoted briefly), the proposed text, the source, and whether it
waits on a decision. Proposed text is a draft for the session, not final wording.

### Header, Summary, Overview

**1. Status line and Quick reference.** Decision: no
- Now: "Reworked 2026-11-06 to a timeline of seconds…"; key deps "Character Stats, Realms, Cultivation Techniques, …"
- New: add "Revised [date] for #43: the defence path, wards and healing move to Combat Defence & Healing (#21a), damage types to Combat Damage Types (#21b), modifier operations to the Modifier System (#40), and statuses and the Down step to the Effects System (#41)." Add the four GDDs to Key deps.
- Source: Defence rule 1; Types Dependencies; Effects Dependencies; Modifiers Dependencies.

**2. Summary.** Decision: no
- Now: "linh lực pays for arts and wards off damage, and thần thức strikes past wards for a share of both"
- New: "linh lực pays for arts and for the wards that cut damage, and thần thức strikes past every defence except the soul's own, for a share of both pools."
- Source: Defence rules 5–8, 14.

**3. Overview, the four ideas.** Decision: no
- Now: "A Dao can convert one tag to another (Fire to Lava)"; "**Several kinds of threat.** Body and qi attacks, soul strikes…"; "powers the ward that blocks most damage"
- New: "A Dao can convert one damage type to another (Physical to Fire)." / "**Eight damage types.** Physical, Force, Fire, Cold, Lightning, Light, Chaos and Soul, plus damage over time and curses, so a one-note build gets punished (Combat Damage Types)." / "pays for the wards that cut most damage (Combat Defence & Healing)".
- Source: Types rules 1, 10; Defence Overview.

### Core Rules

**4. Rule 10, the timeline.** Decision: D9, D10, D19
- Now (time keys): "`escape_channel`, `soul_lockout`, `ward_art_duration`, `trig_ward_seconds`, `time_limit`"
- New: "`escape_channel`, `soul_lockout`, `recharge_delay`, `heal_decay_end`, `time_limit`". Drop `ward_art_duration`. Drop `trig_ward_seconds` if D9 retires it.
- Now (Wake-ups): "The expiry of a ward (a ward art's `ward_art_duration`, a trigger ward's `trig_ward_seconds`)…"
- New: "The expiry of a cast ward (its authored duration, Combat Defence & Healing rule 7) or of an Effect's timed ward change is a scheduled time but fires nothing. A ward stays up through the whole millisecond it expires in. A trigger's own cooldown ending is a wake-up (Effects System, States)."
- Now (Start): "autocast wards are up… A per-pulse ward pays its first upkeep at t = 0 (rule 22)."
- New: "reservations are taken and standing wards are up (Combat Defence & Healing rules 7, 10). An upkeep ward pays its first fee at t = 0."
- Now (Pulse): "sides that are not Down regenerate linh lực, per-pulse wards pay their upkeep, and the per-pulse limits reset (`trig_cap`, the trigger budget, `dot_pulse_cap`)"
- New: "standing statuses take their caster's upkeep before they tick (Effects Formulas B); over-time statuses tick; sides that are not Down regenerate linh lực and health (health inside the heal cap, Combat Defence & Healing rule 17); upkeep wards pay their growing fee; and the per-pulse limits reset (`trig_cap`, the trigger budget, `dot_pulse_cap`, the `heal_pulse_cap` window)."
- Now (Hit): "A hit lands at once, against the defender's live linh lực, its parts in conversion order."
- New: add "Each part then meets the defence path (Combat Defence & Healing rule 1)."
- Now (Defeat check): "A side with no health is **Down**, and its health is set to 0."
- New: "A side with no health first runs the Down step (Effects System rule 11, Formulas C): a refusal may set it to 1, and a last act resolves as a follow-up instant at the same t. Only a side still at 0 or below after that is **Down**, and its health is set to 0. The overkill and draw comparison then applies to the sides that are Down." (D10)
- Shield recharge: "A ward shield's recharge is computed when it is read and adds no event." (D19)
- Source: Defence rules 7, 8, 9, 10, 16–18, States; Effects rules 9, 11, Formulas B and C.

**5. Rule 3, one health bar.** Decision: D6
- Now: "Linh lực starts full… each pool then starts at that share of its maximum exactly"
- New: "Linh lực starts at its usable maximum, `qi_max · (1 − Σ reserved)` (Combat Defence & Healing rule 10). With starting shares, linh lực starts at that share of the usable maximum." Add: "Health may rise during a fight through healing (Combat Defence & Healing rules 16–19), but never above `health_max`, and vitality never rises."
- Source: Defence rules 10, 19.

**6. Rule 4, threat kinds → damage types.** Decision: no (wording follows D11)
- Now: "**Three threat kinds, and how each gets through.** Every attack has a kind. **Body** and **qi** attacks meet the ward (rule 22), and what passes meets the body guard (rule 23)… **Soul** attacks skip both (rule 24)."
- New: "**Damage types, and the defence path.** Every part of every hit and every tick has one of eight damage types (Combat Damage Types rule 1). After offence (rule 5, Formulas C and H), a part meets Combat Defence & Healing's defence path: evade, then resistance, then block, then shields, then health (that GDD's rule 1). A tick meets resistance and the shields it does not pass, and never evade or block. A soul hit meets only soul resistance and soul wards (rule 24). Curses carry no damage type and deal no damage (rule 8)."
- Source: Defence rule 1; Types rules 1, 4.

**7. Rule 5, layers.** Decision: no
- Now: "The other layers are filled by sources priced separately: tagged art modifiers, equipment and companions, preparation and ground, and conversion and trigger effects."
- New: add "Modifier operations (flat, increased, more), scope and W prices are the Modifier System's (rules 4–8, 12). `more` fills L2 and L4 and is budgeted in layer points (Modifier System Formulas D). L3 comes from gear only. L5 is granted only as an Effect's payload (Modifier System rule 6; Effects System)."
- Source: Modifiers rules 5, 6, 12, Formulas D.

**8. Rule 6, tag families and conversion.** Decision: D4 (Types blocker 2), D5, D17
- Now: "element (the five elements and the eight variants), form…, kind (body, qi, soul), mode…, source… and effect (pierce, lock, poison, cleanse, escape)… **Conversion** turns a share of a hit's element or kind tags into another (Fire to Lava, body to qi)…"
- New: "element (the five elements and the root variants; art tags only, never defence), form (sword, palm, seal, beast, formation), **damage type** (physical, force, fire, cold, lightning, light, chaos, soul), mode (hit, over_time, curse, ward), source (art, artifact, talisman, formation, companion), effect (pierce, lock, poison, cleanse, escape, bleed, seal) and the **derived art tags** (basic, quick, slow, cheap, costly), which compile assigns from an art's authored cooldown and cost." Conversion: "**Conversion** turns a share of a part's damage type into another (Physical → Fire). At most 2 per hit, in the order art, then Effects, then modifiers. Element tags never convert. Nothing converts to or from Soul. A converted part keeps its earlier types as tags for offence modifiers. Resistance, penetration and block read its final type only (Combat Damage Types rule 6, Formulas A)." Add the same-step rule from D4.
- Source: Types rules 2, 6, 9, 10; Modifiers rules 9, 10; consistency N13.

**9. Rule 7, damage over time.** Decision: D11, D13
- Now: "An over-time effect has a kind… It ticks at every pulse (rule 10) inside the ward, so only body guard reduces it"
- New: "An over-time status has a damage type, tags, a strength, a duration in pulses and a stacking rule. It ticks at every pulse, meets the resistance of its type, and passes ward shields by default but meets the body shield unless it is Chaos (Combat Defence & Healing rules 1, 9; Combat Damage Types rule 7). It never meets evade or block. The status catalogue is the Effects System's (rule 9). Combat keeps the tick formula and caps (Formulas F). A standing status has no duration and is bounded by its caster's upkeep (Effects Formulas B)."
- Source: Defence rules 1, 9; Types rules 1, 7; Effects rule 9, Formulas B.

**10. Rule 8, curses.** Decision: no
- Now: "A curse can lower a defence, lock one layer, raise an art's cost, block regeneration or block a tag."
- New: "A curse can lower resistance, soul resistance or healing taken, lock one layer, raise an art's cost or a drain ward's bill, block linh lực and health regeneration, or block a tag (Formulas F). The curse catalogue is the Effects System's. Status payloads on wards add status resistance and cleanse tags (Combat Defence & Healing rule 6)."
- Source: Effects Status Catalogue (Curses); Defence rules 6, 15.

**11. Rule 9, triggers.** Decision: D9
- Now: "an effect (a free hit, a status, a refund, a ward, a conversion toggle)"
- New: "an action from the Effects System's closed list (rule 6: free hit, status, restore, refund, conversion, reservation, ward change, timer move, health payment). Trigger records are Effects. Combat keeps the event list, the fixed order and the three limits."
- Source: Effects rules 6, 7.

**12. Rule 11, linh lực is mana and defence.** Decision: no
- Now: "blocked damage drains it (rule 22). Nothing reserves it: a side may spend it all, and every point spent on arts is a point its ward no longer has."
- New: "wards pay from it in five ways (Combat Defence & Healing rule 8). A reserved ward holds a share off the top for the whole fight (rule 10 there), which leaves fewer casts. Every point spent on arts is a point that drain, per-hit and upkeep wards no longer have." Add: "Healing decays over the fight (Combat Defence & Healing rule 18), so a sustain build must still win, not just outlast."
- Source: Defence rules 8, 10, 18.

**13. Rule 12, preparation table.** Decision: no
- Now: "…pills taken, the ward chosen, the slot order set…"; Blind: "Only the loadout, including its ward…"
- New: "…pills taken, wards placed in ward slots and art slots and standing wards switched on or off…"; Blind: "Only the loadout, including its wards…"
- Source: Defence rules 5, 7.

**14. Rule 13, the loadout.** Decision: no
- Now: "A combatant's **loadout** has `slot_count` art slots (Formulas A2), a ward slot (rule 22) and the basic attack… a slotted ward art each take one… The basic attack and an autocast ward take none."
- New: "A combatant's **loadout** has `slot_count` art slots (Formulas A2), its free ward slots (Combat Defence & Healing Formulas D) and the basic attack… a ward placed in an art slot takes one… The basic attack and wards in ward slots take none."
- Source: Defence rule 5, Formulas D.

**15. Rule 13, the art record and the basic attack.** Decision: no
- Now: "An **art** has an id, tags, a kind, a linh lực cost…"; "basic attack (body kind, tags body, hit and art, no cost)"
- New: "An **art** has an id, tags, damage parts with their types (Combat Damage Types rule 1), a linh lực cost…, and optionally a heal payload under the heal lint (Combat Defence & Healing Formulas E)"; "basic attack (Physical, tags physical, hit, art and basic, no cost)".
- Source: Types rules 1, 10; Defence rule 16, Formulas E.

**16. Rule 13, derived tags at compile.** Decision: D5
- Now: (none)
- New: add "Compile gives each art its derived tags (rule 6) from its authored cooldown and cost share. Art speed and cost reduction do not change them."
- Source: Modifiers rule 10, AC-MD-13.

**17. Rule 17, mass battles.** Decision: D7
- Now: "a **rating profile** (offence, defence and sustain per threat kind…)"
- New: "a **rating profile** (offence by damage-type mix, defence by Combat Defence & Healing Formulas G, and sustain…)". The mix rule from D7.
- Source: Defence Formulas G ("For Combat Formulas K").

**18. Rule 18, enemies.** Decision: D8
- Now: "Each realm tier has at least one enemy that attacks with each threat kind, one with a ward that resists each kind and one that drains linh lực hard"
- New: "Each realm tier has at least one enemy that deals each damage-type group (Physical/Force; Fire/Cold/Lightning/Light; Chaos; Soul), one with high resistance to each group, one that drains linh lực hard and one that heals. Every enemy profile lists its damage types (Combat Damage Types Open Question 5), its wards, and a soul defence (Combat Defence & Healing rule 14)."
- Source: Defence rules 14, 21; Types OQ 5; consistency N6.

**19. Rule 19, companions.** Decision: no
- Now: "with its own tags and a simple fixed art"
- New: "with its own tags and a simple fixed art whose damage type is authored (Physical when none is set)". The fallback is an assumption; flag it in the session.
- Source: Types rule 1, Edge Cases ("every damaging art names a type").

**20. Rule 24, soul attacks.** Decision: D3, D4 (Types blocker 1)
- Now: "It ignores wards and body guard… The reliable defences are the defender's own thần thức and the Way; other sources are rare."
- New: "It ignores every defence except soul resistance and soul wards (Combat Defence & Healing rule 14): soul resistance raises the defender's side of rho, and a soul shield soaks a share of each loss (Formulas E2). A soul hit is all Soul; a hit that mixes Soul with other types is rejected at compile. The reliable defences are thần thức, soul resistance (the Way, rare items, soul wards) and soul shields. Its linh lực loss comes out of the usable pool only."
- Source: Defence rules 10, 14; Types blocker 1 (recommended); consistency N2.

**21. Rule 22, warding spells → wards (whole rule replaced).** Decision: D2
- Now: "**Warding spells.** A ward is resistance-based blocking… **The default cost model is drain**… One ward is up at a time…"
- New: "**Wards.** Wards are spells. They sit in free ward slots or in art slots, all of them are up at once, and each carries payloads and one of five payments. The default ward is the fallback for any part that no other ward covers. Combat Defence & Healing owns all of this (rules 5–11, Formulas A–D, F, H). Combat keeps three things: a cast ward fires on the timeline like an art (rule 13); a ward stays up through the millisecond it expires in (rule 10); and compile takes reservations at t = 0."
- Source: Defence rules 5–11; Cross-References ("Rules 5–11 | combat.md rule 22 | Replaced").

**22. Rule 22, the No Ward flags.** Decision: no (Defence adds the flags; Effects OQ 3)
- Now: (none)
- New: add "A side whose Effects set `no_wards` cannot slot any ward, soul wards included. One that sets `no_default_ward` has no default ward. Compile reads both flags (Combat Defence & Healing; the No Ward keystone, Effects System)."
- Source: Effects Starter Effects (No Ward), OQ 3, AC-EF-40.

**23. Rule 23, body guard → body defence (whole rule replaced).** Decision: D14
- Now: "**Body guard, and being a mortal.** Body guard is a mitigation anyone can build from physique… Damage that gets past the ward then meets the body guard… Unless it built body guard or a gimmick that replaces the ward, every hit lands nearly in full."
- New: "**Body defence, and being a mortal.** Body guard is retired. The body defends with block, body shields and resistance from căn cốt, body techniques and body gear (Combat Defence & Healing rule 12). A thể tu is a build that stacked them, and its weakness is Chaos, which passes body shields. A side with no linh lực has no default ward and no drain, per-hit or upkeep ward. Unless it built resistance from other sources, block, body shields or a reserved ward, every hit lands nearly in full. An art may cost health instead (Formulas E)."
- Source: Defence rules 11, 12; Cross-References ("Rule 12 | combat.md rule 23 | Replaced").

**24. Rule 2, compile.** Decision: no
- Now: "returns the health and linh lực maxima, thần thức, the ward, the body guard, the layered modifiers…"
- New: "returns the health and linh lực maxima and the reserved share, thần thức, the ward slots and wards, resistances by damage type, block, shields, healing stats, soul and status defence, the layered modifiers, the art loadout with its derived tags, the triggers and Effects, and the tag set."
- Source: Defence rules 5, 10, 21; Effects rule 13.

**25. Rule 14, the result.** Decision: no
- Now: "The result is: the winning side, how it ended…, each side's health, linh lực and `wound`…, the resources spent…"
- New: add "the costs and gains that outlive the fight (heart demon, lifespan, toxicity and the rest) and wounds that run on, which the caller applies (Effects System rules 10, 11)."
- Source: Effects rules 10, 11.

**26. Rule 15, randomness.** Decision: no
- Now: "Randomness enters only through explicit `chance` fields…"
- New: add "A keystone may turn one chance into a counted chance, which uses no draw and is not shifted by fortune (Effects System rule 12, Formulas A)."
- Source: Effects rule 12.

**27. Rule 16, the Breakdown.** Decision: no
- Now: "its actor, art, tags, kind, the Breakdown of every layer…, what the ward blocked and drained, the body guard, and health and linh lực before and after"
- New: "its actor, art, tags, each part's damage type and history, the Breakdown of every layer, then the defence path as Combat Defence & Healing lists it (evade, resistance with its cap, block, each ward shield, the body shield, health, and each ward's payment), heals with their decay and cap, Effects that fired, and health and linh lực before and after."
- Source: Defence AC-CD-48, UI Requirements; Types AC-DT-23.

**28. Rule 20, crossing realms.** Decision: no
- Now: "fight power (damage × effective health)"
- New: "fight power (damage × effective health, Combat Defence & Healing Formulas G)"
- Source: Defence Formulas G.

**29. Rule 24 / Formulas E2, soul resistance curses.** Decision: D12. Folded into items 49 and 51.

**30. Rule 1, inputs.** Decision: no
- Now: "the two compiled profiles (rule 2), the preparation (rule 12), the ground tags, any starting shares (rule 3) and one seed"
- New: add "and the request's `no_heal` flag (Combat Defence & Healing rule 19; Heavenly Tribulation sets it on every wave)".
- Source: Defence rule 19, Interactions.

### States and Transitions

**31. Combatant states.** Decision: D10
- Now: "Down: mortal wound | Health is empty at an instant's defeat check"
- New: "Down: mortal wound | Health is still empty after the Down step at an instant's defeat check (Effects System rule 11)"
- Source: Effects rule 11, Formulas C.

**32. Ward note under the table.** Decision: no
- Now: "A ward is not a state: at any moment it is up if it was cast and paid for."
- New: "Ward states (Off, Up, Down, Broken, Expired) are Combat Defence & Healing's. Effect states (Ready, Spent, On cooldown) are the Effects System's."
- Source: Defence States; Effects States.

### Interactions table

**33. Character Stats row.** Decision: no
- Now: "`defense_pct` (as ward strength), … resistance keys…"
- New: list the defence keys of item 59; "`defense_pct` (ward strength, which scales ward payloads)".
- Source: Modifiers Stat List; Defence rule 6.

**34. Cultivation Techniques, Item Database and Artifact Refining rows.** Decision: D2
- Now: "`t_b` from body techniques"; "role tags (weapon, ward, body, utility)"; "defense (ward, or body guard if body-tagged)"
- New: "body techniques' block, body shield and resistance (Combat Defence & Healing rule 12, Formulas H)"; "role tags (weapon, ward_gear, body_gear, utility)"; "defence: ward gear feeds ws, we and block up to a = 1; body gear gives 12 block and 0.60 body shield per a_b (Combat Defence & Healing Formulas A2, B)".
- Source: Defence rule 12, Formulas A2, B, H; consistency N1, N10.

**35. New rows, and the Heavenly Tribulation and Event Engine rows.** Decision: no
- New rows: Combat Defence & Healing (#21a), Combat Damage Types (#21b), Modifier System (#40), Effects System (#41), each with the data from their own Interactions tables. Heavenly Tribulation: add "`no_heal` on every wave". Event Engine: add "`no_heal`; reported life costs in the result".
- Source: Interactions tables of the four GDDs.

**36. Rule 10 and Edge Cases, two refused Downs.** Decision: D10. Edge case added in item 62.

### Formulas

**37. Formulas intro note.** Decision: no
- New: add "The defence path's formulas are Combat Defence & Healing's (A–I), damage parts Combat Damage Types' (A), modifier values the Modifier System's (A–D), and the Down step and standing statuses the Effects System's (B, C)."

**38. Formulas A, the ehp formula.** Decision: no
- Now: "`ehp = min(health_max / (pass · f), health_max / f + qi_max / drain)`"
- New: "`ehp` is Combat Defence & Healing Formulas G (typical Qi Refining **297.8**, which was 298)." Drop `pass, drain, f` from the variable table, and change the `ehp` row's source to Defence G.
- Source: Defence Formulas G, OQ 2.

**39. Formulas A, `health_units`.** Decision: no
- Now: "Health in fight units; smaller than linh lực, so most staying power sits in the ward"
- New: "…so most staying power sits in wards and shields". Keep "26 is the unbuilt-mirror limit of AC-CB-58", flagged for re-check under flesh block (item 78).

**40. Formulas A, `qi_start`.** Decision: D6
- Now: "`qi_start = qi_max`, or `qi_max · start_qi_share` likewise"
- New: "`qi_start = qi_use = qi_max · (1 − Σ reserved)`, or `qi_use · start_qi_share`".
- Source: Defence rule 10.

**41. Formulas A2, `ward_art_duration`.** Decision: no
- Now: row "ward_art_duration | 1 s (guess) | … How long a slotted ward art stays up after firing"
- New: delete the row. A cast ward's duration is on its record (Combat Defence & Healing rule 7).
- Source: Defence Dependencies and OQ 2; registry note C5.

**42. Formulas A2, the slots text, and Open Questions 21 and 22.** Decision: no
- Now: "…leaving nothing for the ward"; `art_speed_pct` "not yet in Character Stats (Open Question 21)"; bonus slots "None are authored yet (Open Question 22)"
- New: "…leaving nothing for drain, per-hit or upkeep wards". Note that the Modifier System now prices `art_speed_pct` (0.6 W) and `bonus_slots` (20 W per slot, rare). Ward slots are separate (Combat Defence & Healing Formulas D).
- Source: Modifiers Stat List.

**43. Formulas B, layer table and anchors.** Decision: no
- Now: L1 "and 'increased' tags"; L2 "authored at 5–50 points each"; typical "ward pass 0.45 and drain 1.25 (means of kinds)"; top-end "ward pass 0.35 and drain 0.9"
- New: L1 "the increased sum of damage modifiers (Modifier System rule 5)"; L2 "`damage_more` points from arts, techniques and Way art nodes, typical +40, up to the 300 cap (Modifier System rule 12, Formulas D)"; L4 likewise, typical +20; L5 "Effect payloads only". Typical: "Common Ward (all 0.50, drain 1.64), so r 0.654 at ws 30.8, plus block rating 15.0". Top-end: "r 0.75 at Qi Refining, rising to 0.90 with cap raises (Combat Defence & Healing Formulas A anchors)".
- Source: Modifiers rules 5, 6, 12, Formulas D; Defence Formulas A, A2.

**44. Formulas B, the thể tu anchor.** Decision: D1 (gear term)
- Now: "**Thể tu:** attack 45 %, body guard 25 %, health 20 %, body gear 5 × B_p, body technique 3, default ward."
- New: "**Thể tu:** Combat Defence & Healing's Formulas G fixture: block 88.3 rating (flesh 5.3, gear 12, Iron Body Art tier 3 30, W 41), body shield 0.90 (technique 0.30, gear 0.60), Physical resistance 0.30, body gear 1.0 × B_p, default ward." Fix the 0.30 first (K9: the named sources give 0.20, so name Black Iron Armour's Physical affix as the other 0.10). The W shares need a harness re-fit (Open Question 6).
- Source: Defence Formulas G, H; consistency K9.

**45. Formulas B, the anchor table's ehp columns.** Decision: no
- Now: "Typical ehp (U) 47 / 56 / 73 / 94 / 127; Top-end 125 / 163 / 217 / 315 / 460"
- New: Qi Refining typical stays 47 (297.8 ÷ 6.31). Mark the other cells "re-derive from Combat Defence & Healing Formulas G" (Defence calibrated Qi Refining only), and keep Open Question 20's note.
- Source: Defence Formulas G, Calibration.

**46. Formulas C, `dealt_j` and the order line.** Decision: D4 (Defence blocker 2)
- Now: "`dealt_j = max(1, leak_j · (1 − m · guard_share_kind))`"; order "…suppression, the ward, body guard, floor"
- New: "`D_j` then meets the defence path: `a_j` (Combat Defence & Healing Formulas A), block split `k_j` (A2), shields (B), then `dealt_j = 0` if nothing reaches health, else `max(1, h_j)`". Order: "…suppression, then the defence path." Delete the `leak_j` and `m, guard_share_kind` rows. Output range: "0 if block or shields take all of a part, otherwise at least 1".
- Source: Defence rule 1, Formulas A, A2, B, G ("For Combat Formulas K").

**47. Formulas C, kind wording and the examples.** Decision: no
- Now: "(at most 2 per hit, fixed order; the kind follows the part's final tag)"; "Against the Formulas D ward the body hit deals **15.9** and drains 18.5 linh lực; with the ward off it deals **38.5**. On a ×1.7 crit the warded hit deals **27.0**. Conversion: base 100, Fire +30 %, Lava +40 %…"
- New: "(at most 2 per hit, in Combat Damage Types' order; the part's final damage type decides its defence)". Example, FX-T against FX-T with the Common Ward, Physical: "D **41.30**; after resistance 14.29; block 0.946; **13.34** dealt; drain bill **25.89**. With every standing ward switched off, the default ward (all 0.30) covers it: **27.96**. With no linh lực: **40.35**. A ×1.7 crit: **23.35**. At g 2 and P 0.5: **11.56**. Conversion: base 100, Physical +30 %, Fire +40 %, 40 % Physical → Fire: 0.6 × 1.3 + 0.4 × 1.7 = **146** against 130."
- Source: Types Formulas A; Defence Formulas A–C, AC-CD-06, AC-CD-22, AC-CD-32. Worked by hand from FX-T (r 0.654, block 0.94578).

**48. Formulas E, linh lực.** Decision: D14
- Now: "**Output Range:** linh lực runs 0 to `qi_max`. A side may spend itself to 0."; "the ward is nearly empty from 3 s"; `body_cost_share` "cannot take health below 1"
- New: "0 to the usable maximum (`qi_max · (1 − Σ reserved)`). Art costs and regeneration stay shares of the full `qi_max` (Combat Defence & Healing rule 10)." / "drain wards have almost nothing to bill from 3 s". `body_cost_share`: add "An Effect's health payment is different: it can put the side Down (Effects System rule 6)." Add a pointer: "health regeneration and heals: Combat Defence & Healing Formulas E".
- Source: Defence rule 10, Formulas E; Effects rule 6.

**49. Formulas E2, soul attacks.** Decision: D3, D12
- Now: "Wards, body guard, evade and crit do not apply."; `soul_res_pct` "0–100 | Way nodes and rare items"
- New: "Only soul resistance and soul wards apply. Soul-ward payloads add soul resistance (scaled by ws), and a soul shield soaks its share of each pool loss while its bar lasts (formula from D3). Evade, crit, resistance, block and every other shield do not apply. `qi_loss` comes out of the usable pool." `soul_res_pct` source: "Way nodes, rare items, soul wards; lowered by Slackened Soul, never below 0".
- Source: Defence rules 10, 14, Formulas H (Soul-Guarding Lamp); Effects Status Catalogue.

**50. Formulas F, the tick formula and text.** Decision: D11, D13
- Now: "`tick = clamp(U_src · stage_src · c_tick · stacks · L1..L4(tags) · supp · (1 − m · guard_share_kind), 1, dot_pool_cap · health_max)`"; "Ticks work inside the ward: it does not block them, and body guard applies."
- New: "`tick = clamp(U_src · stage_src · c_tick · stacks · L1..L4(tags) · supp · (1 − r_type), …, dot_pool_cap · health_max)`, where `r_type` is the target's resistance for the status's damage type (Combat Defence & Healing Formulas A). The tick then meets the shields it does not pass (by default it passes ward shields and meets the body shield unless it is Chaos). What reaches health is at least 1." Duration row: "2–6, or none for a standing status (Effects Formulas B)". Add: "The status catalogue is the Effects System's."
- Example (5 stacks, so the cap still shows): "c_tick 0.3, 5 stacks, L1 × L2 1.771, Chaos tick on FX-T (r 0.654): 6.31 × 0.3 × 5 × 1.771 × 0.346 = **5.80**, capped to **5.49**." (At 3 stacks it would be 3.48, under the cap.)
- Source: Defence rules 1, 3, 9; Types rule 7; Effects rule 9, Formulas B; consistency K10.

**51. Formulas F, curse bounds (restated, retired and new).** Decision: D12
- Now: "`curse_shred_max` 0.5 (shreds add), `curse_pass_raise_max` ×1.5 on ward pass, `curse_drain_raise_max` +50 % on drain, `curse_cost_raise_max` +50 %…, `curse_layer_lock_max` 2 pulses…, `curse_tag_block_max` 3 pulses…, `curse_duration_max` 5 pulses; regeneration is blocked or not."
- New:

  | Key | Value | Meaning | Change |
  |---|---|---|---|
  | `curse_shred_max` | 0.50 | Resistance points taken off by Sundered and Exposed together, never below `resist_floor` −0.50 | Restated (was body guard shred) |
  | `curse_pass_raise_max` | — | — | **Retired** (there is no ward pass now) |
  | `curse_drain_raise_max` | +50 % | Drain wards bill more (Leaking Ward) | Kept, drain wards only |
  | `curse_cost_raise_max` | +50 % | Art cost raise | Kept |
  | `curse_heal_taken_max` | 0.50 | Healing taken down (Withering). One floor of −50 % across all sources (D12) | **New** |
  | `curse_soul_shred_max` | 30 pp | Soul resistance down (Slackened Soul, 15 pp per stack) | **New** |
  | `curse_reapply_lockout` | 2 pulses | Sealed Meridian and Silence cannot be put back on that target for 2 pulses after they end | **New** |
  | `curse_layer_lock_max`, `curse_tag_block_max`, `curse_duration_max` | 2, 3, 5 pulses | Unchanged. Silence may not name `ward`, `basic` or `escape` | Kept, one note added |
  | regeneration block | on or off | Stops linh lực **and** health regeneration (Stagnation) | Widened |

- Source: Effects OQ 2, Status Catalogue; Defence rule 3.

**52. Formulas F, the `resist` row.** Decision: no
- Now: "Target's resistance to statuses"
- New: add "Status payloads on wards add to it (Combat Defence & Healing rule 15). A tick's damage is cut by damage-type resistance, not by this."
- Source: Defence rule 15.

**53. Formulas G, triggers.** Decision: D9
- Now: "then the ward and body guard as any hit"; `direct_damage_this_pulse` "…after ward and body guard"; "trig_ward_strength, trig_ward_seconds | 50, 2 s (guesses) | A ward trigger adds this to ws for this long"; "A refund trigger returns at most the fired art's cost, which is now also defence."; example "through the body ward: **3.6**. Six of them make 21.7, clipped to 0.5 × 15.9 = **7.9**."
- New: "then the defence path as any hit"; "…after the defence path"; delete the trig_ward row (D9); "…which drain, per-hit and upkeep wards can then spend". Example: "typical, c_trig 0.5, against FX-T with the Common Ward: free hit D 9.39, **2.30** dealt. Six make 13.81, clipped to 0.5 × 13.34 = **6.67**." Add: "Trigger Effects and their actions are the Effects System's (rules 6, 7)."
- Source: Defence rule 1; Effects rules 6, 7, OQ (AC-EF-10).

**54. Formulas I, evade and draws.** Decision: no
- Now: "Evade applies to body and qi hits only, never soul hits or ticks"
- New: "Evade applies to every hit except Soul, and never to ticks. Evade payloads on wards add to it (Combat Defence & Healing rules 6, 13). `escape_bonus` is the `escape_pct` sum (Modifier System)." In the draw order, add: "A counted chance takes no draw (Effects System rule 12)."
- Source: Defence rule 13; Modifiers Stat List; Effects rule 12.

**55. Formulas J, companions.** Decision: no
- Now: "then the ward and body guard as any hit"; "A companion hit takes the kind of its art"; example "deals **3.2** through the typical ward"
- New: "then the defence path as any hit"; "…takes the damage type of its art"; example "D 8.26, which deals **1.91** against FX-T with the Common Ward".
- Source: Defence rule 1; Types rule 1.

**56. Formulas K, `t_w`, `t_h` and `f`.** Decision: D4 (Defence blocker 2), D7
- Now: "`t_w = qi / (D · (1 − pass) · drain + net_spend)` ; `t_h = health / (D · pass · f)`"; "weighted means of pass, drain and f"; row "f | `1 − m · guard_share_kind`…"
- New: "`t_w = Q_use / (D · b_drain + n_hits · fee + upkeep_avg(T0) + net_spend)` ; `t_h = (S / λ_all + (H + heal(T0)) / λ_all) / D̄`, with one fixed-point pass for the decaying heal (Combat Defence & Healing Formulas G)." The late phase uses `λ_fix`. Forces: "weighted means of b, λ_all and λ_fix". Delete the `f` row. Add rows for `b`, `λ_all`, `λ_fix`, `S`, `n_hits`, `fee`, `upkeep_avg`, `heal(T0)`, each sourced to Defence C, E and G.
- Source: Defence Formulas G ("For Combat Formulas K"); consistency C6.

**57. Formulas K, the example.** Decision: no (but needs a recompute)
- Now: "Off 36.51, pass 0.344, drain 0.956, f 0.932… t_w 5.80, t_h 9.39, T0 **7.77** s"
- New: "Off 36.51, Common Ward b 0.627, λ_all 0.320, health 109.87, linh lực 172.74, net spend 6.91: t_w **5.80**, health-only t_h **9.40**." Recompute T0 in the session. The old 7.77 could not be reproduced from the formula as written, so the late-phase term needs re-deriving. Defence's calibration expects a mirror of about 7.7 s.
- Source: Defence Formulas C, G. Worked by hand: b = 0.95857 × 0.654.

**58. Formulas K, `display_power`.** Decision: D7
- Now: "`display_power = B_p · sqrt(F / F_unbuilt)`, where `F = Off · ehp`."
- New: add "ehp uses Combat Defence & Healing Formulas G against `reference_type_mix` (D7), and leaves out healing."
- Source: Defence Formulas G ("Healing stays out of `display_power`'s ehp").

**59. Parameter keys.** Decision: D18
- Now: "New stat keys…: `crit_chance_pct`, …, `ward_efficiency_pct`, `body_guard_pct`, `soul_res_pct`."
- New: drop `body_guard_pct`. Add `resist_pct`, `resist_cap_pct`, `resist_pen_pct`, `block_rating`, `body_shield_pct`, `health_regen_pct`, `healing_pct`, `healing_taken_pct`, `bonus_ward_slots`, `reserve_eff_pct`, `x_soul`, `escape_pct`, `bonus_slots` and `damage_more`; `art_speed_pct` is already listed (Modifier System Stat List). Under "Removed from `combat_rules.json`" add: `default_ward_pass`, `default_ward_drain`, `pass_min`, `drain_min`, `guard_base`, `guard_pool_slope`, `guard_cap`, `guard_max_mit`, `guard_half`, `guard_share_kind`, `ward_art_duration`, `curse_pass_raise_max`, `hit_cost_share` and `upkeep_share` (now on ward records), and `trig_ward_strength` and `trig_ward_seconds` if D9. Add: "Defence keys (`default_resist`, `default_drain`, `resist_cap`, `resist_cap_max`, `resist_floor`, `heal_pulse_cap` and the rest) live in the `defence` section and are owned by Combat Defence & Healing."
- Source: Modifiers Stat List; Defence Formulas A–I; consistency C14.

**60. Formulas D (whole section).** Decision: D1
- Now: "### D. Ward and body guard", with the ward formula, the three cost models, the body_guard formula, "Being a mortal, in numbers" and the example.
- New: replace it with "### D. Defence (moved)": one paragraph saying the ward, cost models and body defence are Combat Defence & Healing's, and that body guard is retired. If D1 moves `ws`, `we` and `a_w` / `a_b` to Defence, this is a pointer only. If not, it keeps just the `ws` / `we` clamp and the `a_w` / `a_b` definitions. Move "Being a mortal" into rule 23's numbers: "with no linh lực, 97.7 % of a typical Physical hit lands on FX-T (40.35 of 41.30) and 99.3 % on FX-U. On the thể tu fixture, Physical loses 30 % to resistance and 5.57 to block, and the body shield soaks the rest until it breaks. Chaos passes the shield: 35.73 of 41.30 (86.5 %) lands."
- Source: Defence rule 1, Dependencies, OQ 2; consistency N5. Worked by hand.

### Edge Cases

**61. Health, linh lực and wards.** Decision: D16 (Advisor; item 70)
- Now: "If a per-pulse ward cannot pay its first upkeep…"; "If a side spends all its linh lực on arts in an instant: its ward blocks nothing…"; "If a hit needs more blocking than the linh lực can pay…"; "If the player switches the ward off: no ward cost is paid and only body guard stands…"; "If a soul attack drains linh lực to 0: the ward has nothing to block with"
- New: "upkeep ward" for "per-pulse ward". "…drain, per-hit, upkeep and default wards cover nothing against that instant's hits; reserved and cast wards and body defence still stand." "If a drain bill is larger than the live pool: Combat Defence & Healing Edge Cases (the unpaid share leaks)." "If the player switches standing wards off: they take no payment, the default ward covers any part no other ward covers, and body defence still stands." "If a soul attack drains linh lực to 0: drain, per-hit, upkeep and default wards are down; reserved wards stay up." Add: "If a side carries No Ward: see rule 22's flags."
- Source: Defence rules 7, 8, 11, Edge Cases.

**62. Ending a fight.** Decision: D10
- Now: "If neither side can hurt the other: the damage floor of at least 1 per part still applies, so health falls until a side is Down or `time_limit` is reached."
- New: "If neither side can hurt the other: block can take every part to 0 (Combat Defence & Healing rule 12), so the fight may run to `time_limit` and be a stalemate. Otherwise a part that reaches health deals at least 1." Add: "If a side would be Down but holds an unspent refusal: it is set to 1 and fights on (Effects System rule 11). If both sides are saved, both stand at 1." Add: "If a heal and lethal damage land in the same instant: the heal counts, and only the defeat check decides (Combat Defence & Healing Edge Cases)."
- Source: Defence rule 12, Formulas A2, Edge Cases; Effects rule 11.

**63. Arts, tags and triggers.** Decision: no
- Now: "If conversions on a hit total over 100 %: shares are scaled down to 100 %. A conversion to the tag a part already has does nothing. A third conversion…"; "If two statuses with 'the stronger wins' have equal strength: the one already on the target stays."
- New: point the conversion cases to Combat Damage Types' Edge Cases (scaled per source type in one step; a conversion back into the history does nothing; a third is ignored; to or from Soul is ignored and not counted). Add: "If old content carries `body` or `qi` kind tags: it loads as Physical and Force, with a warning (Combat Damage Types rule 10)." Move the status-stacking case to the Effects System and leave a pointer. Add: "If an art declares no damage type: compile rejects it."
- Source: Types Edge Cases, rule 10; Effects rule 9.

### Dependencies, Tuning Knobs, Visual/Audio, UI, Cross-References

**64. Dependencies, upstream.** Decision: no
- Now: no rows for the four new GDDs; Character Stats state "11 new stat keys…"
- New: add Combat Defence & Healing (#21a), Hard, "the defence path, wards, healing; owns all of old rule 22, rule 23 and Formulas D"; Combat Damage Types (#21b), Hard, "damage types, conversion"; Modifier System (#40), Hard, "operations, scope, prices, Stat List"; Effects System (#41), Hard, "status catalogue, trigger Effects, the Down step, reported costs". Character Stats: "the new defence and offence keys (item 59), still to add (consistency C14)". Update the bidirectional-check paragraph: the four new GDDs list Combat; Combat now lists them.
- Source: the Dependencies tables of the four GDDs.

**65. Tuning Knobs.** Decision: D9
- Now: rows `default_ward_pass, default_ward_drain, ward_gear_scale, ward_cap, ward_floor`; `guard_base, …, guard_share_kind`; `pass_min, drain_min, hit_cost_share, upkeep_share`; `ward_art_duration` in the pace row; `curse_pass_raise_max` in the status row; `trig_ward_strength, trig_ward_seconds`
- New: delete the guard row and the pass/drain row. Replace the ward row with "Defence knobs: Combat Defence & Healing (its Tuning Knobs, once added)". Drop `ward_art_duration` and `curse_pass_raise_max`. Add `curse_heal_taken_max`, `curse_soul_shred_max` and `curse_reapply_lockout`. Drop the trig_ward keys if D9. Change "how much staying power sits in the ward" to "…in wards and shields".
- Source: items 51, 59.

**66. Visual/Audio.** Decision: no
- Now: "Each threat kind has its own colour on its damage lines, and each line also names the kind"; events "hit by kind, ward block, …"
- New: "Each damage type uses its colour from Combat Damage Types (Visual/Audio), and each line also names the type." Events: "hit by damage type, resistance cut, block, shield soak and break, heal and heal cap, Down refused, …". Defence's own cue table is cited, not copied.
- Source: Types Visual/Audio, AC-DT-22; Defence Visual/Audio.

**67. UI Requirements.** Decision: D16
- Now: Preparation "ward, body guard and loadout"; "choose the ward and switch it on or off"; Fight log "damage by kind, what the ward blocked"; Character sheet "ward strength and efficiency, body guard"; Advisor "no ward and under 0.2 body guard mitigation"
- New: Preparation "ward slots and their wards, the resistance panel, block and shields (Combat Defence & Healing UI Requirements)"; "fill ward slots and art slots with wards, switch standing wards off"; Fight log "damage by type, resistance, block, shield soaks, heals"; Sheet "ward strength and efficiency, resistances by type, block, body shield, ward slots"; Advisor "Physical ehp at 0 linh lực below 1.25 × health_max" (D16).
- Source: Defence UI Requirements; Types UI Requirements.

**68. Cross-References.** Decision: no
- Now: "Formulas C, D, E, E2, F, H, I | character-stats.md stat keys | 11 new keys…"; "Rule 13, Formulas A, D | cong-phap.md… body techniques (`t_b`)"; "Interactions, rule 12 | item-database.md… Role tags (body, ward)"
- New: update the key list (item 59). Body techniques now grant "block, body shield and resistance (combat-defence.md rule 12)". Role tags follow D2. Add rows: rules 4, 22, 23, Formulas A, C, D, F, G, J, K → combat-defence.md; rules 6, 7, Formulas C → combat-damage-types.md; rule 5, Formulas B, Parameter keys → modifiers.md; rules 7–10, 14, 15, Formulas F, I → effects.md.
- Source: the four GDDs' Cross-References.

### Open Questions

**69. Close or narrow the old questions.** Decision: no
- OQ 5 (L2–L5 costs in W): **close**. Modifier System Formulas D answers it (`more` in layer points, and the exchange rate).
- OQ 14: change "2 % for a ward stat" to "for ward strength", and keep the rest.
- OQ 16 (soul balance): add soul wards, soul shields and Slackened Soul to the list of what the soul numbers must cover.
- OQ 17 (thể tu against a ward build): restate it as block, body shield and Physical resistance against layered wards. Note that `t_b` is gone and Iron Body Art tiers stand in for it (Combat Defence & Healing Formulas H).
- OQ 18 (ward catalogue): **narrow** it to the content pass. A starter catalogue exists (Combat Defence & Healing Formulas H).
- OQ 21, 22: narrow as in item 42.

**70. New open questions.** Decision: no
- The `reference_type_mix` values (D7), if D7 is adopted: the harness fits them.
- Re-run the timeline fixtures under the new path: the FX-T mirror (AC-CB-30), the `health_units` limit (AC-CB-58) and Formulas K's T0 (AC-CB-49).
- If D9 is not adopted: say how a trigger ward maps onto Defence's payloads.

### Acceptance Criteria

Fixtures first, then each AC that changes. "Point" means: replace the AC with a one-line pointer to the named AC-CD or AC-DT criteria, as D15 recommends.

**71. Fixtures FX-T and FX-U.** Decision: no
- Now: FX-T "Common ward (pass 0.54 body, 0.36 qi; drain 1.0 body, 1.5 qi), ws = we = 30.8, so body pass 0.4128 and drain 0.7645. Body guard g 0.1633, m 0.0679. One body art…"; FX-U "…default ward. Health 100.95, linh lực 164.05, m 0.0628."
- New: FX-T "Common Ward (all r 0.50, drain 1.64), ws = we = 30.8, so r 0.654; block rating 15.0 (0.946 points); no body shield. One Physical art: c_art 2.0…". FX-U "…default ward (all 0.30, drain 2.0); block rating 4.4 (0.278 points)." These match Defence's fixtures.
- Source: Defence AC fixtures, AC-CD-54.

**72. AC-CB-07, 11, 19.** Decision: no
- AC-CB-07: "ward, body guard" → "wards and ward slots, resistances, block, shields, healing stats".
- AC-CB-11: "the body and qi attacks meet the ward and then body guard, and the soul attack meets neither" → "a Physical hit meets evade, resistance, block, shields and health in that order; a tick skips evade and block; a soul hit meets only soul resistance and soul wards" (point to AC-CD-01 to 03 for the numbers).
- AC-CB-19: "Fire +30 and Lava +40… body-to-qi conversion… own kind's ward pass, drain and `guard_share_kind`… a ward with a Fire `pass_tag`" → "Physical +30 and Fire +40, 40 % Physical → Fire gives 146 against 130; each part uses the resistance of its final type (AC-DT-08); a Fire-resistance ward does not touch a Physical part of a Fire-element art (AC-DT-03)."

**73. AC-CB-12 and AC-CB-13.** Decision: D15, D1
- AC-CB-12 (ward numbers 24.25 / 18.54 / 17.05 / 15.89): **point** to AC-CD-22.
- AC-CB-13 (pass and drain floors, ws −90, g_b, m 0.754, `body_guard_pct`): **point** to AC-CD-09, 10, 16 and 24. Keep one Combat line if D1 leaves the `ws` clamp in Combat: "`defense_pct` −500 gives ws −90".

**74. AC-CB-21, 22, 23.** Decision: no
- AC-CB-21: "dealt 15.89. With the ward off, 38.50. With g 2 and P 0.5, dealt is 13.91" → "dealt **13.34**. With standing wards off (default ward), **27.96**. With no linh lực, **40.35**. With g 2 and P 0.5, **11.56**."
- AC-CB-22: "A ×1.7 crit on AC-CB-21 deals 27.02" → "**23.35**".
- AC-CB-23: keep the FX-U floor case (M 0.1 still deals 1 per part through FX-U's block of 0.278). Add: "Given the same part against FX-T, block takes it to 0 and it deals 0, logged 'blocked' (AC-CD-05)."

**75. AC-CB-27, 31, 35 (timeline and wards).** Decision: D9, D15
- AC-CB-27: "autocast ward… ward switched off… body guard still applies… slotted ward art… `ward_art_duration`… trigger ward's `trig_ward_seconds`" → "a standing ward is Up from t = 0; a cast ward is Up through the whole millisecond its authored duration ends and Down one millisecond later (also for an Effect's timed ward change if D9 is adopted)." Point to AC-CD-17 and 18 for the rest.
- AC-CB-31: "Rules 11, 23… its drain ward blocks nothing… the ward blocks at most what 3.45 can pay" → cite Defence rule 11 and add "and the default ward is down at 0 linh lực".
- AC-CB-35: "Given a soul attack that empties linh lực, the ward then blocks nothing" → "…drain, per-hit, upkeep and default wards are down, and reserved wards stay up."

**76. AC-CB-38, 40, 42, 45 (statuses, curses, triggers, companions).** Decision: D11, D12, D13
- AC-CB-38: "raw tick is 9.37 and it stops at the cap of 5.49. The ward blocks nothing and drains nothing from a tick" → "5 stacks, Chaos, on FX-T: raw tick **5.80**, capped to **5.49**. A tick meets resistance, never evade or block; it passes ward shields and meets the body shield unless it is Chaos." Keep the qi burn and `dot_pulse_cap` lines. Add D11's billing and penetration lines.
- AC-CB-40: "Shred 0.5 halves g_b… Pass is raised at most ×1.5 and drain at most +50 %" → "Sundered plus Exposed lower resistance by at most 0.50, never below −0.50. Drain bills rise at most +50 %. Healing taken falls at most −50 %, from one source or many. Soul resistance falls at most 30 pp and never below 0. Sealed Meridian and Silence cannot be reapplied for 2 pulses after they end." Add: "Given Corpse Rot, it has no duration and passes the lint (D13)."
- AC-CB-42: "a free hit deals 3.61 through the ward… clipped to 7.95… two art hits of 10 and 5.89… is 15.89" → "**2.30**; six clip to **6.67**; art hits of 10 and 3.34 give 13.34". Drop the `trig_ward_strength` sentence if D9. Restate AC-EF-10 with the same numbers (Section 4).
- AC-CB-45: "the hit deals 3.18" → "**1.91**".

**77. AC-CB-49, 59, 68 to 71, 74, 75 (rating, integration, terminal, body, soul).** Decision: D7, D16
- AC-CB-49: replace pass, drain and f with b 0.627 and λ_all 0.320. t_w **5.80**, health-only t_h **9.40**; T0 recomputed (item 57).
- AC-CB-59: "`defense_pct` reaches ws and not body guard… The 11 new keys appear" → "`defense_pct` reaches ws and scales only ward payloads; the new keys of Parameter keys appear in the sheet."
- AC-CB-68: "damage by kind, ward blocks… what the ward blocked and drained, body guard" → "damage by type, the defence path steps of AC-CD-48, heals".
- AC-CB-69: "each threat kind has its own colour" → "each damage type has its Combat Damage Types colour" (AC-DT-22 holds the screenshot).
- AC-CB-70, 71: "ward, body guard" → "ward slots and wards, resistance panel, block, shields". The Advisor warning uses D16's threshold.
- AC-CB-74 (body guard numbers): **rewrite**: "Given no linh lực, 97.7 % of a Physical hit of D 41.30 lands on FX-T (40.35). On the thể tu fixture a Physical hit goes into the body shield after resistance and block, and a Chaos hit lands **35.73** (86.5 %)."
- AC-CB-75: "Wards, body guard, evade and crit do not apply" → "only soul resistance and soul wards apply (AC-CD-03); evade and crit do not. A soul hit's linh lực loss comes from the usable pool (AC-CD-26)." Add the soul-shield case after D3.

**78. AC-CB-30, 54, 56, 58, 72, 73 (harness, data, cost models).** Decision: D15
- AC-CB-30 (FX-U draw at t = 25; FX-T at t = 8): mark **re-run**. Defence's calibration gives about 24.3 s and 7.7 s (AC-CD-46).
- AC-CB-54: the thể tu and anchor lines follow items 44 and 45.
- AC-CB-56: add the removed keys of item 59.
- AC-CB-58 ("`health_units` 26 passes and 27 fails… under the default ward"): mark **re-run** with flesh block.
- AC-CB-72 (per-hit and per-pulse cost models): **point** to AC-CD-20 and 21.
- AC-CB-73 (ws and we effects, pass above 0.55 lint): **point** to AC-CD-16, 24 and 41.

---

## 4. Companion edits routed to #43 (outside combat.md)

These are not in the numbered list, but tonight's reviews route them to the #43 session.

| Edit | File | Source |
|---|---|---|
| Restate AC-EF-10 with item 53's numbers (2.30, 13.81, clipped to 6.67 against 13.34) | effects.md | Effects review item 10 |
| Retire `ward_block`, `body_guard`, `body_guard_pct`. Mark `default_ward_pass`, `default_ward_drain`, `guard_*`, `pass_min`, `drain_min`, `ward_art_duration`, `trig_ward_strength` and `curse_pass_raise_max` deprecated. Register the new curse bounds | registry | Defence OQ 10/14 (review item 8); consistency N17c; Effects OQ 8 |
| Fix the registry `soul_attack` note ("Ignores wards") | registry | consistency N2 |
| Back-references to the four GDDs in the older GDDs (C13) | 10 GDDs | review items: Modifiers 12, Effects 13, Defence 11, Types 9 |
| Defence: add the No Ward flags (Effects OQ 3) and the tick rules of D11 | combat-defence.md | Effects OQ 3; this plan |

Each of these writes outside combat.md, so it needs your go-ahead in that session.

---

## 5. What was not done

| Step | Status |
|---|---|
| Editing combat.md or any other GDD | Not done, as the task said |
| The harness | Not run, so the T0 recompute (item 57) and the re-runs (item 78) are left open |
| Running scripts | A Python check needed approval, which unattended mode cannot give. All new numbers were worked by hand from FX-T (D 41.2998, r 0.654, block 0.94578, U 6.30957). They agree with Defence's AC-CD-06, 22 and 32 |
| Formulas K's old T0 (7.77) | Could not be reproduced from the formula as written. Flagged for re-derivation, not changed |
| Specialist agents | None spawned |
| Commits | None |
