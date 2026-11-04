# Cross-GDD Review Report — 2026-11-04 (sixth pass, 04f)

Date: 2026-11-04
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none
Focus: full (consistency and design theory)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)

**Method disclosure.**
- **Agents:** two `game-designer` agents ran in parallel, one for consistency and one for design theory. Both stopped at their turn limit before reporting, were resumed, and then delivered full reports.
- **Deviation from the skill:** the agents read the GDDs by section from disk instead of receiving pasted content. The five GDDs total about 440 KB, which is too large to paste.
- **Consistency coverage:** partial for every check from 2a to 2f. The pass concentrated on what changed since 04e: the F1 fix, the W-A to W-D fixes and I-G. In detail:
  - **2a:** only canh-gioi was checked against systems-index rows 6–10 and 14. The pairwise Dependencies walk across the other four GDDs did not run.
  - **2c:** only the canh-gioi Cross-References table was walked row by row. Prose was scanned by keyword.
  - **2f:** recomputed AC-CG-26, 29, 49, 58, 60 and 61, AC-LC-24 and 25, and the Character Stats lifespan example. The bot ACs have no data.
  - **Data files read for the F1 baseline:** `items_herbs.json`, `items_recipes.json` and `character_elements.json`.
- **Design-theory coverage:**
  - **3a, 3f and 3g:** full. Fantasies were inferred for the three GDDs that have no Player Fantasy section.
  - **3c:** full for the root, herb, plot and pill chain; partial for technique and tree paths, which are unchanged since 04e.
  - **3e:** full for FE→CF; partial for CF→NS and NS→DT, because their recipes are guesses and W has no formula.
  - **3b:** partial, because there are no UI, Guidance or Time & Turn GDDs.
  - **3d:** partial. Spirit stones, seed supply, market stock, alchemy yields and the Spirit Fields mastery curve are **NOT ASSESSED**, because Item DB, Spirit Fields, Alchemy and Market have no GDDs.
- **Scenarios:** the main session walked the Phase 4 scenarios from the GDD text.

---

## Consistency Issues

### Blocking

🔴 **B1 (was C3). Whether a root mutation's `herb_growth_pct` counts under the ceiling is undefined. This is a scenario blocker (scenario 2).**
- **Data (`character_elements.json`, matching linh-can Formulas E around lines 460–463):** three mutations grant `herb_growth_pct`:
  - Life (Sinh Mệnh) +30;
  - Spirit Farming (Linh Thực) +60;
  - Time (Thời Gian) +100.
- **Character Stats rule 14 (about lines 179–189):**
  - It lists the capped sources as "techniques, the tree, items and pills".
  - It says "the root's own terms (Wood's herb growth, Earth's plots, Fire's brew success) are separate factors and are not capped".
  - It places a mutation's `lifespan_years` under the ceiling (W10).
  - It says nothing about a mutation's `herb_growth_pct`.
- **canh-gioi Formulas D (495–509):** its four growth influences (Wood, items, techniques, knowledge) leave out both mutations and the tree, although line 463 names the tree.
- **Why it matters:** the two readings differ by up to ×1.7 in h.
  - **Uncapped:** Time takes h from ×1.4 to ×2.4 on top of a full ceiling, and AC-CG-60's ≤ 0.48 can be exceeded.
  - **Capped:** linh-can Formulas E prices Time's +100 at 90 W and Spirit Farming's +60 at full value, although at most 40 counts (36 W). That breaks W10's principle of pricing at what the ceiling lets through.
- **Fix (user decision; recommended: capped, consistent with W10):**
  - State the ruling in CS rule 14.
  - Reprice Life, Spirit Farming and Time in linh-can Formulas E, AC-LC-24/25 and OQ1 at min(value, 40) × 0.9 W.
  - Add mutations and the tree to canh-gioi's influence list.

### Warnings

⚠️ **C2. Craft mastery is named as a `herb_growth_pct` source in canh-gioi only.**
- **canh-gioi:** Formulas D (502–506) says "Spirit Fields craft mastery (đạo nghệ) adds `herb_growth_pct` as a sheet modifier", and Open Question 12 (1385) gives its curve to system 14.
- **The other places leave it out:**
  - CS rule 12, the modifier sources (156–162);
  - CS rule 14, the ceiling sources (179–184);
  - the CS Interactions table (279), where Crafts are "out" only;
  - canh-gioi's own variable table (443), "techniques, the tree, items and pills";
  - the registry `bonus_ceilings` note.
- **Ownership is split:** systems-index row 7 folds craft mastery into Character Stats, while OQ12 gives the curve to Spirit Herbs & Spirit Fields (#14).
- **Fix:**
  - Add craft mastery to CS rules 12 and 14, with a Crafts → CS "in" row.
  - Align canh-gioi line 443 and the registry note.
  - Make OQ12 and the index agree on who owns the curve.

⚠️ **C4. The CF Tuning Knob lever has no in-range move.**
- **Where:** canh-gioi Tuning Knobs (933): "Y 125–195 … `min_age` ≤ 70 … so move the count, not the age".
- **The problem:** with Y = 50·n + 20, the counts give Y 120 / 170 / 220, and only 170 lies inside 125–195. The count is a ±29 % step. The fine lever is `min_age` 35–58 at count 3, all under the limit of 70.
- **Also stale:** Formulas E (555–556) "set by the herbs' min_age and the plot count", and the registry `realm_step_success` note "herb min_age".
- **Fix:** make the lever "min_age 35–58 at count 3; the count is a coarse step", or give the companion herb finer steps.

⚠️ **C5. The FE→CF row was not recomputed for Y 170.**
- **Recomputed:** root-free λ = 0.64 × 3 × 0.5 × 140 ÷ 170 = **0.7906**. The 0.78 / 0.7814 in the tables is the old Y of 172.
- **AC-CG-29 (1159):** "(0.7814, 0.3225) → 0.2228". At 0.7906, S = 1 − e^(−0.2550) = **0.2250**.
- **The mean:** about 0.307 (an elasticity estimate), outside AC-CG-29's ±0.002. Line 484's "170 against 172, so the calibration holds" is true only within AC-CG-30's ±0.05.
- **Fix:** recompute the FE→CF row (λ, mean, per-count S, edge G) and AC-CG-29, or state that the row is a Y-172 fixture. B2 may supersede this.

⚠️ **C6. The Diên Thọ Đan lifespan pill uses Kim Tủy Quả, and no GDD says so.**
- **Data:** `items_recipes.json` `dien_tho_dan` needs `kim_tuy_qua` at min_age 50 ×1 and `van_nien_moc_linh` at min_age 100. It gives +15 lifespan, twice per life.
- **Effects:** the two recipes compete for FE plots, and the lifespan pill raises W, which feeds back into CF λ. That feedback is bounded by the lifespan ceiling.
- **Fix:** note the shared herb in canh-gioi Formulas D and the bot policy, or give Diên Thọ Đan a different herb (Item DB / economy-designer).

### Info

- ℹ️ **I1. More kinh-mach-do labels that are not systems (W-D residual).** The rule 17 catalogue (319–343) still uses non-index host labels: #12 "Herbs", #25 "Heart Demon", #8 "Cultivation, Travel", #24 "Spiritual Root", #1–#3 "Magic treasures" and #16 "Spirit Beasts". Relabel them to systems-index names, as the host list near line 1492 already does.
- ℹ️ **I2. The Age row needs the burn.** In the CS rule 6 state table (103), "Age … Time & Turn" should add "and #23's burn (Realms rule 18)".
- ℹ️ **I3. The `herb_growth_pct` range.** canh-gioi line 443 gives "0–40", but CS allows negative totals and floors only the factor (AC near CS line 973). Use "≤ 40 (negative allowed; the factor floors at 0)".
- ℹ️ **I4. The ginseng "was" value.** Tuning Knobs (932) says "was 25", but the data and OQ9 say 30.
- ℹ️ **I5. Empty `revised:` fields.** The registry entries `breakthrough_pill_plot_years` and `lifespan_cap` changed today but have `revised: ""`.
- ℹ️ **I6. Two "was" values in different places.** Parameter keys (719–721) say "not 1 at 100", the built value, while Formulas D says "was one at 152", the earlier GDD value. Name both.
- ℹ️ **I7. The data recipe has no open question.** The data still holds `kim_tuy_qua` min_age 100, qty 1, and AC-CG-58 fails until the implementation story lands. Add this to OQ8 or OQ9.
- ℹ️ **I8. I-E is still open.** It concerns two cap values mid-season after an involuntary loss, and canh-gioi Edge Cases (785–789) is unchanged.
- ℹ️ **I9. I-F is partly fixed.** `lifespan_cap` referenced_by now lists linh-can and kinh-mach-do, and a comment covers the `lifespan_pct ≥ 0` assumption.

**Confirmed consistent by hand:**
- **F1 headline numbers:** Y = 3 × 50 + 20 = 170; limits W/2 = 52 / 70 / 140 / 280; ginseng 40 ≤ 52; Kim Tủy Quả 50 ≤ 70. The 220 example is 4 × 50 + 20. These agree across Formulas D, Tuning Knobs, AC-CG-58, OQ4 and the registry. No stale 152, "one Kim Tủy Quả" or "a hundred years" is left in the live rules.
- **QR→FE under discrete harvests:** 2 pills against a linear 2.08 (ratio 0.96), so there is no problem at this gate.
- **The herb-growth ceiling:** 40 agrees across CS rule 14, CS Formulas I and the registry. h is identical in CS Formulas G and canh-gioi D, and CS's example 1.48 × 1.4 = 2.07 is correct.
- **W-C:** QR cap 120 + min(40, 18) = 138; age 100 + 10 = 110. The burn_cost values are 10 / 10 / 25 / 50, and the kinh-mach-do values 120 → 10, 500 → 25 and 2000 → 100.
- **W-A:** AC-LC-25 and OQ1 are clean. AC-LC-24 gives 18 × 2.5 = 45 W, and +10 years gives 25 W. Life costs 52 W and Time 135 W.
- **W-B:** CS rule 14 now points to the new CS OQ7.
- **W-D:** #7 is relabelled Time & Turn (aging) and #23 Realms.
- **I-G:** linh-can's Cross-References table has a cong-phap row.
- **The lifespan formula** agrees across CS rule 13, canh-gioi rule 14 and the registry, and AC-CG-26 and AC-CG-61 reproduce.
- **Formulas D examples:** λ 2.028, 3.56 and 3.89 all reproduce.

---

## Game Design Issues

### Blocking

🔴 **B2 (F5 + C1). F1's fix works only if a life gives at least two plots to the herb. The linear λ and the S-by-count table are still invalid under discrete harvests (3e, 3c).**
- **Shared figures:** FE W 140, p_brew 0.64, q 0.3225, so one brew gives 0.2064. Harvests per plot are H = ⌊h·W / min_age⌋, and brews are B = ⌊k·H / qty⌋, where k is the number of plots given to the herb.
- **What the fix solved:** the herb-age cliff. At h = 1, H = 2, so every no-Wood life can now grow Kim Tủy Quả inside FE.
- **What it brought back:** a quantity cliff. A pill needs 3 herbs:

  | Plots on the herb (k) | Herbs | Brews B | S at h = 1 |
  |---|---|---|---|
  | 1 | 2 | 0 | 0 (F1's cliff again, for the ~62 % of lives with no Wood) |
  | 2 | 4 | 1 | 0.206 |
  | 3 | 6 | 2 | 0.370 |

- **Why the model misses it:**
  - The bot's f = 0.5 is 1.5 plots, and nothing says how it rounds.
  - The harvest-timing rule (486–493) checks one herb, not the herbs a pill needs. Line 449 claims "the linear λ holds" under that rule.
  - W is listed as "calculated" but has no formula. It runs about 104–144 by FE entry age, and H jumps to 3 at W ≥ 150, so a +12-year lifespan bonus is also a step lever.
  - The other ingredients' 20 plot-years also need plots.
- **Effect on the per-root table:**
  - A single Wood root at purity 10–53 has h 1.08–1.42, so H = 3. At k = 2 that gives B = 2 and S 0.370, while the linear model gives about 0.24–0.30. The deviation is +0.07 to +0.13, outside AC-CG-30's ±0.05.
  - AC-CG-32 (analytic, linear) can disagree with AC-CG-30 and 31 (the bot, discrete).
- **Options (user decision):**
  - (a) Extend the harvest-timing rule to brews: `k_base · ⌊W_min / min_age⌋ ≥ 2 · qty`, with an integer k_base and the earliest-death W_min.
  - (b) Replace the linear λ with the discrete B. Calibrate qty, min_age and plots on it, and give AC-CG-30 an integer plot policy. This is the most legible for Pillar 2: "2 brews this realm, 37 %".
  - (c) Keep λ for hand calibration, but require the bot to simulate discrete harvests, with a per-tier guard that k = 1 never yields B = 0 at baseline.
  - (d) Define W as the realm's lifespan cap minus the entry age, and report S across the W distribution.

🔴 **B3 (F6). Plot share f is a free player lever outside every target (3c, 3e, Pillar 4).**
- **f is a constant only for the bot.** Formulas D (446) gives f = 0.5 as a guessed bot policy. For the player it is a seasonal choice, and the core loop's 30-second decision is "which herb goes in this plot".
- **The swing:**
  - Linear model: f 0.5 → 1 doubles λ. A root-free life at the 40 % herb-growth ceiling with `alchemy_success` 8 reaches S of about 0.55.
  - Discrete, root-free, 40 % growth, k = 3: H 3, B 3, S **0.50**.
  - Both exceed AC-CG-60's ≤ 0.48.
  - Wood 60 at the ceiling with k = 3: H 5, B 5, S **0.69**, which is the edge target without an edge.
- **It is nearly costless:**
  - At the bottleneck the bar's excess is wasted (Realms rule 7), so cultivation-speed crops are worthless, and committing plots costs only spirit-stone income. That income cannot be assessed (no Spirit Fields or Market GDD).
  - This fails Pillar 4's design test.
  - AC-CG-60 caps growth, alchemy and lifespan, but not f or `field_plots`.
- **Plots step in groups of 3 herbs:** at H = 2, k = 3 → 4 adds nothing, and k = 5 gives a third brew. The tree's linear 10 W price per plot pays 0 or +1 brew.
- **Options (user decision):**
  - (a) Calibrate 0.30 and 0.45 at the player's best plot policy.
  - (b) Give breakthrough herbs a real plot cost: upkeep, scarce rarity-4 seeds per realm from the Market, or a sect tithe.
  - (c) A visible cap on breakthrough-herb plots, for example 2 plus Earth plots.
  - (d) Accept fields as a build ("the field cultivator"). Restate the targets as "for a life that does not specialise", and add field allocation to AC-CG-60's ceiling run.

**B2 and B3 come down to one decision:** the supply model plus the plot policy.

### Warnings

⚠️ **F2 (carried; improved at FE, open at CF and NS). The herb clock against climbing (3a, 3g).**
- **The first FE attempt is largely fixed.** The first harvest at year 50 roughly matches the climbs: 48 (3 elements), 57 (4), 64 (1) and 69–80 (5). The exception is k = 3 with no spare plot for the other ingredients, where the first brew comes at about year 70.
- **Between attempts it is still idle.** The next harvest is 50 years later, against a bar refill of about 3 years, so about 47 years pass at a full bar. That is about 37 of 140 FE years, down from about 100 of 150 in 04e.
- **CF and NS are unconstrained.** The rule allows `min_age` up to 140 and 280, against climbs of about 55–79 and 66–97. That could mean up to about 61 and 214 idle years.
- **Options:**
  - Cap breakthrough `min_age` near the 3-element climb (about 50 / 60 / 100), and set Y through the herb count.
  - Or 04e's options: a capped "consolidate the foundation" sink, planting one realm early, or a one-click "wait until ripe" retreat.

⚠️ **F3 (carried; mechanism changed). Lives that never roll (3e).**
- **The 04e figure was a Poisson artifact.** Under discrete supply, P(never roll) = (1 − p_brew)^B: 0.35 at B = 1 and 0.12 at B = 2. B = 0 is the B2 cliff.
- **CF→NS depends on the unwritten NS recipe (OQ4).** For example, 3 × 120 + 30 at W 280 gives B = 0 at k = 1.
- **Options:** fold this into B2 by guaranteeing B ≥ 1, have the Advisor show "brews possible" and "P(no pill)", or apply 04e's options (b) and (c).

⚠️ **F7. Growth bonuses are lumpy, and their W prices do not match their value (3c, Pillar 2).**
- **Thresholds at W 140:** H steps up at h 1.071, 1.429, 1.786, 2.143 and 2.5. The first is reached by any Wood root, by herb growth of at least 7.2 %, or by a lifespan bonus of at least +10 years.
- **Value between steps:** zero. Wood 10 and Wood 53 are identical at FE.
- **Prices:** the tree prices growth linearly at 0.9 W per % (kinh-mach-do 823), so the first 7 % is underpriced and the next 35 % overpriced. The lifespan W price has the same problem.
- **Dominant strategy:** buy just past the first threshold, commit every plot, and stop.
- **OQ12's "a herb's own element speeds it" would make this worse:** as a root term it is uncapped and bypasses AC-CG-60.
- **Options:** show and price the count of harvests this realm, spread the steps through the min_age choice, carry partial herb age over between realms, or accept the lumpiness and have the Advisor show the next threshold.

⚠️ **F8. Attention budget over 4 in a typical FE season (3b).**
- **About 8 decision systems:** Spirit Fields, Alchemy, Market, Realms, Techniques, the Meridian Map, Travel and Events.
- **4 meters to watch:** toxicity, heart demon, vitality and lifespan.
- **Mitigations:** the Guidance and Advisor layers, and the passive pre-bottleneck phase. It cannot be judged further without UI, Guidance or Time & Turn GDDs.
- **Option:** a "season digest" in Time & Turn that surfaces only the fields, alchemy and attempt decisions by default.

### Info

- ℹ️ **F4 (carried; unchanged; 3g).** The cross-realm win fantasy has no combat budget. The realm term is ×10 per realm base and ×6.9 at a great breakthrough, while `tech_power` reaches ×4.4. Record a target in the Combat obligations.
- ℹ️ **F9.** The same as C4 (the coarse count lever). Also, the systems index's "approved" list is out of date: 8 is In Review and 9 is approved.
- ℹ️ **F10 (positive).** A discrete brew count can be shown exactly ("2 brews, 37 %"), which is more legible than λ 0.78 (Pillar 2).
- ℹ️ **Pillars:** no anti-pillar is violated. The coherent identity across systems is "a mortal who builds an engine within visible rules".

**Pillar map** (● primary, ○ secondary):

| System | P1 Your Dao | P2 Bounded & Visible | P3 Built, Not Given | P4 Every Season Counts | P5 World Remembers | Note |
|---|---|---|---|---|---|---|
| Spiritual Roots | ● | ● | ○ | ● | | Has Player Fantasy |
| Character Stats | ○ | ● | ● | ○ | | No Player Fantasy; inferred |
| Realms & Bottlenecks | | ● | ● | ● (strained by F2, B3) | | No Player Fantasy; inferred |
| Cultivation Techniques | ● | ○ | ● | ● | ○ | No Player Fantasy; inferred |
| Meridian Map | ● | ● | ● | ○ | ○ | Has Player Fantasy |

**3d, resource by resource:**

| Resource | Assessed? | Sources and sinks |
|---|---|---|
| Cultivation base | Yes | Faucet: the rate formula. Sinks: the level ladder, 30 % lost on failure, waste at a full bar. That waste is the only sink at the bottleneck and drives F2. |
| Herbs and plot-years | Yes | Faucet: plots × growth. Sink: pills. f is uncosted (B3). |
| Pills | Yes | Faucets: brews, market (≈ 0), gifts G. Sink: attempts. |
| Lifespan | Yes | Faucets: base plus a bonus with a ceiling. Sinks: time, the #23 burn (as age, now defined). |
| Toxicity, heart demon | Yes | Bounded faucets and decay sinks. No issue found. |
| Tree points | Yes | Faucets: levels and breakthroughs. Sink: placement, no respec. They stall at the bottleneck. |
| Technique copies | Yes | Faucets: world, market, sect, inheritance. The guaranteed copy is reserved. |
| Spirit stones, seed supply, market stock, alchemy yields, Spirit Fields mastery curve | **NOT ASSESSED** | Item DB, Spirit Fields, Alchemy and Market have no GDDs. |

---

## Cross-System Scenario Issues

Scenarios walked: 4
1. FE entry → plant → harvest → brew → attempt → fail → wait.
2. A great breakthrough awakens Time or Spirit Farming → h → λ.
3. A failed CF attempt → #23 burn → age + burn → #22 eligibility.
4. Diên Thọ Đan and the CF pill grown in the same FE plots.

### Blockers

🔴 **Scenario 1 (Realms, Spirit Fields, Alchemy, Character Stats).**
- **Where it breaks:** between harvest and brew. The number of plots on the herb (k) is undefined, and at k = 1 the life never has three herbs, so it never brews (B2).
- **At k = 2:** the third herb ripens at FE year 100, so the first attempt waits about 40 years at a full bar, with no levels, no Meridian points and lost mastery excess (F2).
- **At k = 3:** the life can exceed the bonus-ceiling target with no edge (B3).

🔴 **Scenario 2 (Spiritual Roots, Character Stats, Realms).**
- **Where it breaks:** at the moment a mutation granting `herb_growth_pct` +60 or +100 is awakened. Whether the 40 ceiling applies is undefined (B1).
- **What depends on it:** the sheet's clamp line, AC-CG-60's bound and linh-can's price all depend on a reading no GDD states. This is undefined behaviour.

### Warnings

⚠️ **Scenario 4 (Item DB, Realms, Character Stats).**
- **The overlap:** Diên Thọ Đan and the CF pill compete for Kim Tủy Quả plots (C6).
- **The feedback:** the lifespan pill raises W, which raises CF λ. This is bounded by the lifespan ceiling, but no GDD names it and the bot policy ignores it.

### Info

ℹ️ **Scenario 3 (Realms, Meridian Map).**
- **The data flows correctly.** The AC-CG-61 case holds (cap 138; age 100 → 110; 28 years remain), and "only one of #22 / #23 per realm step" covers the overlap.
- **The remaining gap** is I-E: which cap #22 and #23 read mid-season after an involuntary loss of lifespan bonus.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| canh-gioi.md | B2: brew quantisation and undefined W break FE→CF λ. B3: plot share unbounded against the targets. C4, C5, C6. F2 at CF/NS. | Design / Consistency | Blocking |
| character-stats.md | B1: mutation `herb_growth_pct` against the ceiling. C2: craft mastery as a source. I2. | Consistency | Blocking |
| linh-can.md | B1 follow-on: reprice Life, Spirit Farming and Time if they are capped | Consistency | Blocking (depends on B1) |
| kinh-mach-do.md | F7: linear growth and plot prices for a step payoff. I1: host labels | Design / Consistency | Warning |

---

## Verdict: FAIL

The F1 fix solved the herb-age cliff but left a cliff caused by herb count and plot count (B2). The calibration targets also ignore the player's plot choice (B3). B1 is a ruling in one line plus a repricing.

### Required actions before re-running
1. **canh-gioi Formulas D, E and Tuning Knobs, and AC-CG-29/30/32/60:** make one decision on the supply model and plot policy (B2 options a–d, B3 options a–d). Then define W, recompute the FE→CF row and AC-CG-29 (C5), and fix the lever wording (C4).
2. **character-stats rule 14:** rule on whether a mutation's `herb_growth_pct` counts under the ceiling (B1). Then reprice in linh-can Formulas E, AC-LC-24/25 and OQ1.
3. **Recommended in the same pass:**
   - C2: add craft mastery to CS rules 12 and 14, and settle who owns the curve.
   - C6: note the shared herb.
   - The Info edits I1–I7.
