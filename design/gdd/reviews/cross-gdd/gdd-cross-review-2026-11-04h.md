# Cross-GDD Review Report — 2026-11-04 (eighth pass, 04h)

Date: 2026-11-04
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none
Focus: full (consistency and design theory)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)

**Method disclosure.**
- **Agents:** two `game-designer` agents ran in parallel, one for consistency and one for design theory. Both read the GDDs by section from disk. The main session walked the Phase 4 scenarios.
- **Context:** this pass follows the 04g rulings, which subagents applied per GDD:
  - F2: shorter, more numerous CF/NS herbs;
  - F11: plots at 20 W, so the tree gives no plots;
  - F13: failure insight;
  - F14: q-extras ceiling;
  - F15: holder-raised ceilings, with Lava confirmed;
  - F16: plant plan;
  - C5: root factors and holders outside the target;
  - the #23 insight guard in Meridian Map E2.

  These rulings are treated as settled.
- **Consistency coverage:**
  - Full on the changed seams: insight against #22/#23 and E2; raises against pricing against rule 14; X_q against the tree cap; lifespan against the registry.
  - Recomputed the cross-file fixtures: AC-CG-29 / 50 / 52 / 60 / 64 / 65, AC-KMD-44, AC-CS-54 and AC-LC-24.
  - Partial: 2a and 2d, where cong-phap's and kinh-mach-do's Tuning Knobs were searched only.
- **Design-theory coverage:**
  - Figures marked "est." are hand arithmetic, not a model run.
  - 3b is partial: no UI, Guidance or Time & Turn GDD.
  - **3d NOT ASSESSED:** no Item DB, Market, Alchemy or Spirit Fields GDD.

---

## Consistency Issues

### Blocking

🔴 **C1. The failure-insight cap limit lives only in the Meridian Map, and Realms' safe range breaks it.**
- **The limit:** kinh-mach-do E2 (~l.742) says the #23 guard holds only if `failure_insight_cap` ≤ 2 × `failure_insight_pp`.
- **The conflict:**
  - canh-gioi Tuning Knobs (~l.1263) gives a safe range of "pp 1–3, cap 2–6" and quotes "2 / 6".
  - Formulas H says "by construction" with no condition.
  - The registry `failure_insight` entry has no limit either.
- **Why it blocks:** AC-KMD-44 tests launch values only, so tuning inside the documented range would silently break the δ_max guard.
- **Options:**
  - (A) Limit the knob to cap ≤ 2 × pp in Realms Tuning Knobs, Formulas H and the registry (recommended).
  - (B) Generalise E2's ι_23 to the summed carry.

### Warnings

- ⚠️ **C2. Registry `breakthrough_guard` lacks E2's #23 insight carry term.** It also defines ι_23 as "0.02 or 0", and its variables list is incomplete.
- ⚠️ **C3. "Mutation Awakening off" does not exclude birth-formed holders and plot mutations from AC-CG-30 and AC-CG-60.**
  - Lava (order 1) forms at birth, and Pill Fire, Spirit Farming and Space (order 2) can.
  - **Options:**
    - (A) The bot strips `ceiling_raise` and `field_plots` mutation effects (recommended).
    - (B) Exclude holders from the gate means.
    - (C) Measure the contamination.
- ⚠️ **C4. "Craft mutation" wording is left after the Lava ruling.** It remains in canh-gioi (~l.694, 698, 1261, 1739), in the registry `bonus_ceilings` note (which also omits Lava 3 → 5) and in linh-can Dependencies row 7.
- ⚠️ **C5. Character Stats sums `breakthrough_chance` into one total, but Realms Formulas C needs it split by source.**
  - Character Stats adds destiny perks into the same total (AC-CS-48: 8 + 12 = 20).
  - Realms caps q_tree and q_event under X_q, but keeps q_destiny outside.
  - **Fix:** Character Stats defines subtotals by source kind, and Realms names which subtotal feeds which term.
- ⚠️ **C6. canh-gioi Open Question 15 still prices plots at 10 W.**
- ⚠️ **C7. linh-can Tuning Knobs points a Pill Fire change at AC-CG-60.** AC-CG-60 excludes holders, so it should point to the Formulas D holder ceiling runs.
- ⚠️ **C8. systems-index row 8 says Needs Revision**, but canh-gioi's status is In Review.

### Info

- **C9.** canh-gioi Formulas H defines ι_23 as "0.02 or 0", while E2 uses min(pp, cap − I). Use E2's form.
- **C10.** AC-CG-58's brew bounds (46 / 82) don't reproduce from the listed W (47 / 83). State the exact W.
- **C11.** Realms Dependencies leaves out inputs:
  - row 6 is missing `herb_age_root_pct`;
  - row 7 is missing `herb_growth_pct`, `alchemy_success`, the lifespan bonus and the holder raises.
- **C12.** Registry `guard_success` was never revised for the 04g C11 counting rule (attempts with τ and insight).
- **C13.** kinh-mach-do's Cross-References table lists no sibling GDDs.
- **C14.** The holder-raise values have no registry entry of their own (proposed: `ceiling_raises`, source linh-can).
- **C15.** #22's 2q doubles failure insight and destiny perks, but never τ. Say so in rule 17 and in the "up to ×2" text.
- **C16.** Character Stats types `breakthrough_chance` as "pct"; everywhere else it is percentage points.

**Confirmed consistent by hand:**
- **The #23 insight guard:**
  - E2's exact lift derivation holds;
  - AC-KMD-44 gives 0.096567 against 0.10087 for the old guard;
  - the q 0.30 case gives 0.0920 against 0.1115;
  - #22 stays exact;
  - rules 8, 10 and 18 and Formulas C and H agree that q includes insight and excludes τ.
- **Realms fixtures:**
  - AC-CG-52: 0.1255 and 0.080.
  - AC-CG-50: 0.6063, 0.9498 and 0.9700.
  - AC-CG-29: every C_k by exact packing, B, and the S values 0.2079 / 0.1869 / 0.3148 / 0.2496 / 0.2128 / 0.1247 / 0.2124.
  - AC-CG-64 and AC-CG-65.
  - AC-CG-60 and the holder, fully built and edge-plus-build figures across Formulas C and D, Tuning Knobs and the registry.
- **X_q ordering** (tree cap 8, then X_q 10; destiny perks, τ and insight outside) agrees in Character Stats, kinh-mach-do, the registry and Realms.
- **AC-CS-54 raise lines** check out.
- **AC-LC-24 raise fixtures** check out (31.2 / 49 / 13.5), and the equivalent pricing form is truly equivalent.
- **Lifespan:** registry `lifespan_cap` matches Character Stats B_life and Realms rule 14.
- **`pill_chance`** 0.04 / 0.045 / 0.02 / 0.0225 matches everywhere.
- **No live stale old recipes or τ 10** remain.

---

## Game Design Issues

### Blocking

🔴 **F20. Pill Fire's `alchemy_yield` +1 is priced but not modelled in pill supply (3c, 3e; Pillars 2 and 3).**
- **Where it is priced:** linh-can prices it at 15 of Pill Fire's 31.2 W.
- **Where it is missing:**
  - Character Stats calls it "flat pills", with no ceiling.
  - Realms Formulas D assumes 1 pill per successful brew.
  - The holder table leaves out the yield.
- **Arithmetic (est.):** if yield applies to breakthrough pills, a root-free Pill Fire holder at FE→CF goes from S 0.275 to S 0.465 (+0.19). The birth-mix holder S would be about 0.65–0.70, at the edge's level.
- **Options (user decision):**
  - (a) Breakthrough pills ignore `alchemy_yield`.
  - (b) Model it for everyone, with a yield ceiling.
  - (c) Yield applies to breakthrough pills for holders only, which makes Pill Fire a real breakthrough identity. AC-CG-60's holder rows are re-run.

### Warnings

- ⚠️ **F17 (new). At CF→NS and NS→DT the pill's own chance is the smallest part of q (3g, 3c; Pillars 2 and 3).**
  - **The share:** `pill_chance` is 24–26 % of first-attempt q (16 % by the third attempt; about 10 % with Đạo Cốt).
  - **Gates no longer share one shape:** a low-talent life is at 52 % of typical at CF→NS but 61 % at QR→FE.
  - **The fine lever is near its floor:** typical extras 2 pp higher would need `pill_chance` 0.
  - **Pill quality and the tree compete under X_q:** on a tree build, pill quality adds 0, which hollows out Alchemy's quality output.
  - **Options:**
    - (a) Accept, and reword "same shape".
    - (b) Move pill quality outside X_q under its own small cap.
    - (c) Raise the late `pill_chance` and pay for it elsewhere.
    - (d) The bot measures the typical extras first, and calibration fails if `pill_chance` < 0.01.
- ⚠️ **F18 (new; follows F11 and F14). Extra plots are the only breakthrough lever with no ceiling below `max_plots` 12 (3c, 3e, 3f).**
  - Spirit Farming (49 W) adds +0.19–0.21 S, about 15× Pill Fire, and gives about 0.18 odds of reaching DT, against 0.008 at baseline.
  - Builds without extra plots stay 0.15–0.18 below the edge, so F14 worked.
  - Field builds reach the edge: Spirit Farming with full extras gives about 0.70–0.77 (est.). Mutation and root plots alone (10 plots) give about 0.73–0.81 (est.) with no edge. Edge plus fields is near-certain.
  - `bonus_ceiling_target`'s "edge stays distinct" guard does not cover field builds, because they are outside the target by ruling.
  - **Options:**
    - (a) Accept fields as the strongest build.
    - (b) A ceiling on extra plots that count for breakthrough recipes (for example +3 above base and Earth), which holders can raise.
    - (c) Make plot upkeep a hard Spirit Fields obligation.
    - (d) Reprice plots at their marginal S on a built life (about 28 W). Spirit Farming then needs trimming to +1 plot.
- ⚠️ **F19 (new). Holder and Time figures isolate one factor (3e; Pillar 2).**
  - Real holders carry their guaranteed ancestors' lines. A Time holder always has Space's plot and Life's herb growth and lifespan.
  - A realistic Time holder at the ceilings is about 0.60–0.63 (est.), and about 0.70 with full extras. Space holders are missing from the table.
  - **Options:**
    - (a) "Realistic holder" rows that include the ancestor bundle.
    - (b) A footnote.
    - (c) The Advisor computes holder S from the real sheet.
- ⚠️ **F2 (carried; changed, open).**
  - Idle time is 54 % / 57 % of W. The fix depends on the Time & Turn GDD's "retreat until ripe" (OQ18): what interrupts a retreat, and how skipped years are shown.
  - The 4 + 1 recipes mean about 15 sowings per realm, so the plant plan must queue the whole sowing sequence.
  - Time's speed line still sits idle at a full bar.
- ⚠️ **F7 (carried; changed from dead to lumpy).**
  - Capped growth buys no brew at QR→FE and FE→CF.
  - It buys a whole 4th brew at CF→NS with +5.4 % and at NS→DT with +2.4 %.
  - The tree's linear 0.9 W per % misprices both ends.
  - Calibration is sensitive to herb growth in the bot's rolled arts.
- ⚠️ **F8 (carried; worse) and F21 (new). Several gains are silently zero at the moment of choice.**
  - **Read-out depth:** q has four nested bounds, plus three ceilings with raises, root factors, penalties after the cap, the insight cap, the talisman and the bare cap.
  - **F21's silent zeros:** pill quality under X_q, tree breakthrough past about 5.75 pp, herb growth at early gates, and an unfilled raise all add nothing. The clamp line appears only at the attempt preview.
  - **Options:**
    - (a) A marginal-effect preview at every acquisition point (a Guidance requirement).
    - (b) A season digest.
    - (c) Collapse layers.
  - NOT ASSESSED further: no UI, Guidance or Time & Turn GDD.
- ⚠️ **F11 (carried).** The tree part is resolved. Fields carry over to F18. It is Blocking if the Spirit Fields GDD makes plots cheap.

### Info

- **F13: resolved.** Failure insight works, and no fail-on-purpose or attempt-spam incentive was found. Residual: cheap low-rank pills from an Alchemy GDD could enable insight farming (NOT ASSESSED).
- **F14: resolved for builds without extra plots.** Built 0.52–0.55; edge plus build 0.83–0.86. Field builds reopen it (F18). Stacked destiny perks have no combined rule (Progression Edges; NOT ASSESSED).
- **F15: changed, still weak.** Pill Fire adds +0.013 S and Lava about +0.010. F20 may overturn this.
- **F16: resolved.** Residual: re-plan when W changes, and cover re-sowing.
- **F22 (new; ordering).**
  - With insight rising, burning the worst pill first is weakly better (about 0.001).
  - Saving the talisman has option value against the "first attempt" default.
  - **Options:** document it, or let the player choose.
- **F3 and F4: unchanged.** F4 (combat budget) is NOT ASSESSED.
- **Stakes (3e).** Chance of reaching DT per life:

  | Life | Chance |
  |---|---|
  | Baseline | about 0.008 |
  | Ceiling run | about 0.04 |
  | Spirit Farming holder at ceilings | about 0.18 |
  | Edge | about 0.24 |
  | Edge plus full build | about 0.52 |

**Pillar map:**

| System | P1 | P2 | P3 | P4 | P5 | Note |
|---|---|---|---|---|---|---|
| Spiritual Roots | ● (strained: F15, F18) | ● (F19) | ○ | ● | | Spirit Farming is now the breakthrough apex among mutations |
| Character Stats | ○ | ● (F21) | ● | ○ | | Yield has no ceiling (F20) |
| Realms & Bottlenecks | | ● (F17, F21) | ● (strained: F18 vs the edge) | ● (F2 partial) | | Insight resolves F13; the plant plan resolves F16 |
| Cultivation Techniques | ● | ○ | ● | ● | ○ | Unchanged; rolled arts feed F17's lever risk |
| Meridian Map | ● | ● | ● | ○ | ○ | Tree plot part resolved |

No anti-pillar is violated. The nearest is "stat-block card picking", via F17 and F21. The identity holds. The risk is that the engine collapses into "more plots" (F18) or "more pills per brew" (F20).

---

## Cross-System Scenario Issues

Scenarios walked: 4
1. A Pill Fire holder brews a CF pill → `alchemy_yield` +1 → pill count → S.
2. A designer sets `failure_insight_cap` 6 inside the safe range → #23 fails after a failed attempt → E2 guard.
3. A bot calibration life is born with Spirit Farming → AC-CG-60.
4. A destiny perk and the tree both grant `breakthrough_chance` → Character Stats total → Realms Formulas C split.

### Blockers

- 🔴 **S1 = F20 (Spiritual Roots → Character Stats → Alchemy → Realms).** Whether one successful brew yields one pill or two is undefined for breakthrough pills, and the answer moves S by about 0.19.
- 🔴 **S2 = C1 (Realms Tuning Knobs → Meridian Map E2).** A cap of 6 inside the documented safe range breaks the δ_max guard silently. No AC catches it.

### Warnings

- ⚠️ **S3 = C3.** Birth-formed holders and plot mutations contaminate the 0.30 / 0.45 calibration runs.
- ⚠️ **S4 = C5.** Realms cannot split the sheet's `breakthrough_chance` into the X_q-capped part and the destiny part. The data flow is undefined.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| canh-gioi.md | C1 knob limit; F20 yield in Formulas D; C3, C4, C6, C9, C10, C11, C15; F17, F18, F19, F21 | Consistency / Design | Blocking |
| character-stats.md | F20 yield ceiling / scope; C5 `breakthrough_chance` subtotals; C16 | Consistency / Design | Blocking (F20) |
| linh-can.md | F20 yield pricing follows the ruling; C4, C7; F18 / F19 | Consistency / Design | Warning |
| kinh-mach-do.md | C13; C15 wording; F7 / F21 | Consistency | Warning |
| (registry, not a GDD) | C1, C2, C4, C12, C14 | Consistency | Blocking (C1) |
| systems-index.md | C8 | Consistency | Warning |

---

## User direction (2026-11-04, after this report)

The user stopped the balancing passes here: "we don't have to balance it too much, the most important thing is the macro stats are as expected. A little bit overpowered builds are ok." Consequences:
- The macro targets hold: every gate averages about 0.30 at baseline and about 0.70 with the edge; built lives without extra plots sit at 0.52–0.55.
- F17, F18, F19, F21 and F22 (strong field, holder and Pill Fire builds; silent zeros) are accepted as tolerable over-power or deferred to the Guidance, Spirit Fields and Alchemy GDDs. They are not blockers.
- C1 and F20 stay open as small definitional items (the insight-cap knob limit; whether alchemy_yield applies to breakthrough pills). They need a one-line ruling, not a rebalance.
- C2–C16 are mechanical cleanups for a later pass.

## Verdict: FAIL

There are two blockers:
- **C1:** an insight-cap knob range that can silently break the #22 / #23 guard. The fix is mechanical once the option is chosen.
- **F20:** an unmodelled `alchemy_yield`. This needs a user decision.

Seven of the nine carried design items are resolved or changed. The two new pressures are extra plots (F18) and yield (F20).

### Required actions before re-running
1. **F20:** rule on whether `alchemy_yield` applies to breakthrough pills. Then align Realms Formulas D, Character Stats and linh-can's pricing, and re-run the holder rows.
2. **C1:** constrain the insight-cap knob (option A), or generalise E2 (option B). Mirror the choice in Formulas H and the registry.
3. **Recommended in the same pass:** C2–C16 (mostly mechanical), and rulings on C3, F17, F18, F19, F21 and F22.
