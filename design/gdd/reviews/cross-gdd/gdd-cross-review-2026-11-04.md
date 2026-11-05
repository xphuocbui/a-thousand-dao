# Cross-GDD Review Report

Date: 2026-11-04
GDDs Reviewed: 4 of 4 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `kinh-mach-do.md`)
Not read: none wholly. Partial-section gaps are listed under Coverage.
Focus: full (consistency + design theory + scenarios)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Meridian Map (#10)
Pillars: `game-concept.md` (5 pillars, 6 anti-pillars); `game-pillars.md` does not exist.
Prior report: `gdd-cross-review-2026-11-03.md` (2 GDDs). Its consistency warnings 1 and 3 were
spot-checked and are fixed. Its warning on canh-gioi having no Player Fantasy section is still open
(advisory at `standard`).

**Method disclosure.** Phases 2 and 3/4 ran as two parallel `game-designer` subagents. The four GDDs
total about 330 KB, so the agents were given section pointers and the established context, not pasted
section text (a deviation from the skill's contract), and read by section. Both hit their turn limit
once and were resumed to deliver. The main session verified both Blocking findings and design
finding 5 against the GDD text.

---

## Consistency Issues

### Blocking

🔴 **C1. No GDD delivers the realm-breakthrough trigger for Mutation Awakening (#24), and two GDDs contradict on who calls whom.**
- `linh-can.md` Dependencies, row 10: the Meridian Map "also calls this system's Awakening roll at each realm breakthrough (capability #24)". In the same section: "No cycles: Spiritual Roots reads nothing from its downstream systems ... the Meridian Map invoke[s] its change and roll rules rather than the reverse."
- `kinh-mach-do.md:1474`: "Hosts do **not** call the Meridian Map: The Meridian Map writes held capability ids into a capability set on the character. Hosts read that set ... This breaks what would otherwise be cycles with the upstream hosts (Realms & Bottlenecks, Spiritual Root, ...)". So the Meridian Map never calls a host.
- `canh-gioi.md` Interactions and Downstream row 10 send `breakthrough_succeeded` to the Meridian Map only. AC-CG-51 tests only a Meridian Map subscriber.
- Result: Spiritual Roots must itself read the capability set and Realms' event. Both systems are downstream of it in its own table, so its "No cycles" claim is false. systems-index row 6 still says "Depends On: Config, Sim Core".
- Options (do not decide here):
  - (a) Spiritual Roots subscribes to `breakthrough_succeeded` and reads the capability set. Then add Realms and Character Stats as soft upstreams in linh-can, add Spiritual Roots to canh-gioi's Interactions, Downstream table and AC-CG-51, and update systems-index row 6.
  - (b) Realms or the Meridian Map relays the event. This breaks the Meridian Map's host model, so its Dependencies section would need to change.

### Warnings

⚠️ **C2. Out-of-date "no GDD yet" statements.**
- CS Interactions: "Spiritual Roots ... have no GDD yet".
- CS Dependencies: "Only Realms & Bottlenecks and the Meridian Map have GDDs".
- canh-gioi Interactions: "Character Stats, Spiritual Roots ... have no GDD yet".
- canh-gioi Dependencies: "Only the Meridian Map has a GDD".
- kinh-mach-do Dependencies: "None of the systems below has a GDD yet; every interface is provisional".

⚠️ **C3. Missing Cross-References rows.**
- character-stats has no `linh-can.md` row.
- canh-gioi has no `character-stats.md` or `linh-can.md` row, although its prose cites both.
- kinh-mach-do has none for the other three GDDs, although rules 3–4, E2 and capability #24 cite them.

⚠️ **C4. Character Stats has not absorbed Spiritual Roots.**
- CS Open Question 1 still calls the root's purity rules "provisional here".
- CS Formulas B and AC-CS-07 use Stars +10 and Death −10. linh-can Formulas E marks both for retuning, and AC-LC-25 fails until they are.
- If AC-CS-07 reads live data, the retune breaks it. Use fixtures, as AC-LC-24 does.

⚠️ **C5. `stage_power_step` is per realm in one GDD and global in the other.**
- canh-gioi Parameter keys lists it per realm.
- CS lists it as "one global key (change)", and AC-CS-36 tests it that way.
- Read strictly, AC-CG-58 ("every Parameter key has its GDD value") conflicts with AC-CS-36.

⚠️ **C6. `vitality_floor` is defined twice.**
- CS: `character_attributes.json` `derived.vitality_floor`.
- canh-gioi: `cultivation_realms.json` `breakthrough.vitality_floor`.
- Both ACs pass only if the value is duplicated.

⚠️ **C7. `tam_ma_natural_decay` is owned twice.**
- CS rule 8 says it is "set by Realms & Bottlenecks", yet CS also lists it in its own Parameter keys and Tuning Knobs.
- canh-gioi lists it too.
- The values match today. Keep one owner.

⚠️ **C8. The `failure_tam_ma_gain` safe range differs, and a joint constraint is missing.**
- CS: above 10 and below 20 (exclusive).
- canh-gioi: 10–20 (inclusive).
- canh-gioi's "one failure (+15) still allows the next attempt" needs gain ≤ `nascent_tam_ma_max`, whose safe range is 15–30. Neither GDD states that constraint.

⚠️ **C9. The cultivation-rate formula has no owner, and "plus" reads as additive.**
- canh-gioi rule 3 and AC-CG-07: "... × pill-toxicity penalty, **plus** cultivation-speed bonuses".
- CS rule 13 and AC-CS-51 apply × (1 + total ÷ 100), and linh-can's ×10.35 and ×12.6 figures multiply.
- Add `rate = base × curve × tech × comp × density × tox × max(0, 1 + cultivation_speed_pct/100)` to canh-gioi Formulas.

⚠️ **C10. canh-gioi's `climb_total` safe range ignores five-element roots in QR.**
- The range is −30 % to +30 %, derived from the one-element case only (AC-CG-33 runs `--elements 1`).
- linh-can B: a five-element root in QR is already at 84 % of the half-lifespan ceiling. +30 % breaks it; about +19 % is the real ceiling.
- Add an `--elements 5` QR criterion. This depends on linh-can Open Question 2.

⚠️ **C11. The mutation band derivation cites a keystone range nobody defines, and the total is unbounded.**
- linh-can Tuning Knobs cites "the 50–60 W keystone range". kinh-mach-do defines keystones only as ≥ 50 W.
- The pair bonus (33 W), the keystone (≥ 50 W), Chaos (80 W) and Awakening re-rolls stack with no combined bound (linh-can Open Question 8).

⚠️ **C12. No single owner publishes the stat weights.**
- kinh-mach-do Dependencies row 7 says Character Stats owns "the stat weights' reference values". CS claims none, and the weights live in kinh-mach-do Formulas F.
- Travel speed, `alchemy_yield`, presence and `lifespan_pct` have no weight. The linh-can retune direction ("become `lifespan_pct`") therefore cannot be checked against the bands.

⚠️ **C13. canh-gioi says "element count" where linh-can means *base* count.**
- linh-can rule 4 excludes mutations.
- The build counts them, up to 8.

⚠️ **C14. The registry still holds a renamed key.** `failure_khi_huyet_loss_pct` and `failure_khi_huyet_loss_frac` are both registered. CS renamed `_pct` to `_frac`, and AC-CS-36 requires the old name to be gone.

### Info
- **C15.** CS rule 13 says "Cultivation owns the lifespan formula" (no such system) and omits pill bonuses. The owner is canh-gioi rule 14.
- **C16.** canh-gioi Formulas E, P_C row, still cites Open Question 6 as open. It is answered: kills add no heart demon.
- **C17.** The NS and DT `stage_curve_groups` (`na`×4, `ht`×4) are not stated in canh-gioi.
- **C18.** linh-can "6.6 W ... about half a notable" holds only against deep hidden notables. It is 0.47–0.83 of N0 / E_notable.
- **C19.** linh-can prices lifespan at the QR rate (2.5 W per year), while the Meridian Map uses 300 / L_r. This is deliberate, but mutation W and tree W are not comparable at later realms.

---

## Game Design Issues

### Blocking

🔴 **D1. The 3-in-10 / 7-in-10 breakthrough targets are calibrated for a root with no Wood, Earth or Fire.**
- canh-gioi Formulas D: `λ = p_brew · n_plots · f · (1 + g_herb) · W / Y`. The example uses `n_plots` 3 (the base) and `g_herb` = `herb_growth_pct` ÷ 100 = 0.
- CS Formulas G: `plots = 3 + ⌊0.04 · purity_earth⌋ + ...` and `herb_growth = (1 + 0.008 · purity_wood) · ...`. Fire drives `p_brew`.
- At purity 50, Earth and Wood raise λ ×2.33. Baseline S goes from 0.30 to about 0.56, and the edge S from 0.70 to about 0.94 (subagent calc; main session confirmed the terms).
- 10 / 30 / 60 / 100 % of 2–5-element roots hold both Wood and Earth, so this is also a hidden "more elements is better" channel in breakthrough odds.
- Fix (a design choice): write the root terms into λ and calibrate the targets against the expected root mix, or state which root the targets assume. Run the bot per tier for AC-CG-31.

### Warnings

⚠️ **D2. A five-element root starts with about a full QR tree's power, erasing its slow start.**
- The center keystone (1 point at d 1, ≥ 50 W, takeable at season 1 with the 2 birth points), the pair bonus (33 W) and about 1.3 mutations (about 26 W) total about 109 W.
- KMD A2 targets "about 106 W" at the end of QR.
- This conflicts with linh-can's "slow and fragile in Qi Refining" and KMD's "earned, never bought".
- Options: give the keystone a QR-relevant drawback (KMD Open Question 4), gate it at FE, or move it outward.

⚠️ **D3. linh-can's "no tier dominates" check is one-dimensional.**
- Five elements trail four by about 1 % in whole-life years.
- Five beats four on every other axis: keystone, Chaos, mutations (mean 1.31 vs 0.78), crafts, all five tree sectors, and the D1 pill channel.
- Either rewrite the check as a matrix, or state that the rare root is meant to be strongest (Pillar 1).

⚠️ **D4. The single root (45 % of lives) is weakest on almost every axis, and its QR lead does not survive the pill gate.**
- It has 0 pairs, no mutations at birth (so #24 does nothing for it), no keystone, 4 of 5 tree sectors at ×0.25, one craft, and a ×0.3 technique fallback.
- Its 25-versus-33-year QR lead is cancelled because QR→FE is limited by pill supply (λ), not by bar speed.
- It is also a soft class lock. The only way out, Linh Căn Quả, is event-granted (risk to the "NOT fixed classes" anti-pillar and Pillar 3).
- Add a buildable single-root identity, and align its Player Fantasy line. This extends linh-can Open Question 10.

⚠️ **D5. Mutation Awakening can fire at most twice, not four times.**
- `cap_min_n` 7 puts every capability on a CF-or-later cluster (KMD `size_realm_gates`, Tuning Knobs: "it must keep every capability at Core Formation or later").
- DT has no next realm, so the only breakthroughs left are CF→NS and NS→DT.
- linh-can Formulas D's "Light ... about 61 % after 4 breakthroughs" is therefore unreachable; at most about 43 % (1 − 0.828³). Verified by the main session.
- Price #24 (linh-can Open Question 5) and Open Question 8 on two rolls.

⚠️ **D6. In a Self-made life every player converges on one root.**
- Picks are free, so the dominant choice is five elements at 100 plus every mutation. The band ceilings sum to about 1,650 W, above the whole DT tree (about 1,100–1,300 W).
- Self-made stays casual (user decision). A point-buy budget would keep it a real choice (Pillar 1, Pillar 2).

⚠️ **D7. The `lifespan_pct` retune has no W price and scales by realm.** +15 % is +18 years in QR and +300 in DT (see also C12).

⚠️ **D8. Linh Căn Quả is an uncapped purity source.** With five elements owned it gives +8 per fruit, bypassing Tẩy Tủy Đan's 3-per-life cap. Open Question 9's cap must cover both of the fruit's modes.

⚠️ **D9. A Tẩy Tủy Đan at high toxicity can waste a lifetime use.** Potency floors at 0 for non-cleansing pills, so the pill gives +1 and still spends one of the 3 uses. The preview should show the gain and warn when it is low.

⚠️ **D10. Pillar 4 fades in late realms for 2+ element roots.**
- These roots use only 9–26 % of the half-lifespan ceiling at NS and DT.
- A five-element root finishes the ladder in about 354 years against a 2,000-year DT cap, leaving 1,500+ years with no goal.
- Accept this explicitly, or plan post-cap goals (canh-gioi Open Question 1).

⚠️ **D11. No GDD owns the per-season attention budget.** The concept's season already lists more than 4 active systems. Assign batching and digest to Time & Turn and the Guidance Layer.

### Info
- **D12.** Progression is one loop (bar → levels → points → tree → crafts → pills → breakthroughs). Good. Tree `cultivation_speed_pct` has no tree-wide cap, only per cluster, and `cultivation_speed_per_element_pct` has no weight.
- **D13.** Only linh-can and kinh-mach-do have a Player Fantasy section. The two agree with each other, but conflict with the mechanics in D2 and D4.
- **D14.** The concept's "30–120 minutes" per life is set against 1,400–6,600 seasons per life. This is a Time & Turn question.

---

## Cross-System Scenario Issues

Scenarios walked: 6
1. Realm breakthrough with Mutation Awakening held
2. Linh Căn Quả taking a 4-element root to 5 mid-realm
3. Tẩy Tủy Đan
4. Failed NS attempt with #23 and #25
5. Several levels in one season across a stage-group boundary
6. Self-made maximal birth

### Blockers
None beyond C1, which S1 depends on.

### Warnings

⚠️ **S1 Breakthrough + Awakening (Realms, Meridian Map, Spiritual Roots, Character Stats, World DB).**
- The Awakening pass's position in the season's RNG stream is undefined. linh-can defines only the birth draw order.
- For DT, "Attempting → Tribulation" means a successful roll is not yet a completed breakthrough. Awakening should wait for the tribulation.
- Whether a successful #23 extra roll counts as a breakthrough is implied, not stated.

⚠️ **S2 Linh Căn Quả 4 → 5 (Spiritual Roots, Realms, Meridian Map, Character Stats, crafts).**
- One uncapped event item stacks five rewards: the curve row, +6 % pairs, new rolls including Chaos, a new sector rescaled from ×0.25, and the keystone unlocking.
- The preview shows speed only.
- The best order with a Tẩy Tủy Đan is invisible to the player.

⚠️ **S4 Failed NS attempt with #23 and #25 (Realms, Character Stats, Meridian Map).**
- A failed extra roll resolves a second time in the same season: heart demon +30, and two doubled deviation rolls of about 26 % then about 52 %.
- The preview must show the cumulative risk.
- The 50-year burn can strand a single root.

⚠️ **S5 Multi-level season across a stage-group boundary (Realms, Spiritual Roots).**
- Undefined: is carried-over surplus rescaled by the new curve factor? For example, a five-element root going from `kd_so` 1.0 to `kd_trung` 1.8.
- Also undefined: the order of stage multipliers and point grants.
- Specify per-level or season-start evaluation, and add an AC.

⚠️ **S6 Self-made maximal birth.** About 1,650 W at birth (D6). The rolled set handling is consistent.

### Info
- **S3 Tẩy Tủy Đan.** The recompute order is consistent and has no double-dip. The only issue is the wasted-use trap (D9). Earth crossing a multiple of 25 adds a plot, which feeds D1.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| linh-can.md | C1 Awakening trigger and "No cycles"; D5 61 % figure; D3 dominance check; D4 single-root identity; D6–D8 | Consistency + Design | Blocking |
| canh-gioi.md | D1 λ omits root terms; C1 missing Spiritual Roots consumer; C9 rate formula; C10 `climb_total` range; C13; C5–C7 key ownership | Design + Consistency | Blocking |
| character-stats.md | C2–C8 (stale "no GDD", OQ1, duplicated keys, ranges), C15 | Consistency | Warning |
| kinh-mach-do.md | C2–C3, C11–C12 (keystone ceiling, weight ownership), D2 keystone at season 1 | Consistency + Design | Warning |

---

## Verdict: FAIL

Two blocking issues (C1, D1) must be resolved before architecture begins. Neither needs a redesign:
C1 is an ownership and wiring decision, and D1 is a formula that omits terms another GDD already defines.

### Required actions before re-running
1. **C1.** Choose (a) or (b). Update linh-can Dependencies (drop or reword "No cycles"), canh-gioi Interactions, Downstream table and AC-CG-51, and systems-index row 6. Under (b), also update the kinh-mach-do capability-host paragraph.
2. **D1.** Put the Wood, Earth and Fire terms into canh-gioi Formulas D (λ), or state the assumed root. Recompute the targets per tier, and extend AC-CG-31 and the bot to `--elements 1..5`.

### Coverage
- Phase 2 did not read the kinh-mach-do Acceptance Criteria (lines 1602–2120) or Open Questions, so the AC cross-check (2f) covered linh-can, character-stats and canh-gioi only.
- Phase 2 checked the registry by name, source and value lines up to line 784; `referenced_by` lists were not read.
- Phase 3 did not read most Acceptance Criteria or the Edge Cases sections, and opened no `assets/data` files.
- Edge Cases sections were outside both phases' scope by design (skill Phase 1c).
