# Cross-GDD Review Report — 2026-11-04 (fifth pass, 04e)

Date: 2026-11-04
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none
Focus: full (consistency and design theory)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)

**Method disclosure.**
- **Agents:** two `game-designer` agents ran in parallel, one for consistency and one for design theory.
- **Deviation from the skill:** the agents read the GDDs by section from disk instead of receiving pasted content. The five GDDs total about 440 KB, which is too large to paste.
- **Consistency coverage:** this pass concentrated on what changed since 04d:
  - the lifespan ceiling and W10 repricing;
  - the NG8 Edge Case;
  - the cleanup edits made after the single-GDD reviews earlier today.
- **Partial checks:**
  - 2a was partial. Today's single-GDD reviews checked each GDD's own Dependencies against its siblings, but not every pair against each other.
  - 2b, 2d, 2e and 2f were checked around lifespan, death and burn only. The rest of that text is unchanged since 04d passed it.
- **Design-theory coverage:** 3d (the spirit stone and market economy) was not assessed, because Item DB, Market and Alchemy have no GDDs. 3b and 3f were covered only inside F1 and F2.
- **Scenarios:** the main session walked the Phase 4 scenarios from the GDD text.

---

## Consistency Issues

### Blocking

None.

### Warnings

⚠️ **W-A. linh-can AC-LC-25 and Open Question 1 were not updated for W10.**
- AC-LC-25 (about lines 815–819) and OQ1 (about line 943) still list Reincarnation and Time as over their bands.
- Formulas E (465–466) now prices them inside their bands, at 45 W and 135 W.
- The data still holds +200 and +50 years, so a tester pricing from data gets 590 W and 125 W.
- **Fix:** drop both names from AC-LC-25 and OQ1. Add a lifespan fixture to AC-LC-24: +200 `lifespan_years` → 45 W; +10 → 25 W.

⚠️ **W-B. Character Stats rule 14 has a dangling pointer.**
- Rule 14 (186–187) says `lifespan_pct` is uncapped, citing "Spiritual Roots Open Question on its price". No such question exists in linh-can, since option (a) of W10 replaced the `lifespan_pct` proposal.
- **Fix:** point to a live open question (for example a new CS question), or state that no current source grants `lifespan_pct`.

⚠️ **W-C. The #23 lifespan burn is not defined against the ceiling.**
- canh-gioi rule 18 (212–217) says "burn burn_cost years". Rule 14's cap formula has no burn term, and no GDD says how the burn is applied.
- If the burn is a negative entry in the raw bonus sum, it costs nothing above the ceiling. Example: QR, raw 40 with 18 counted; burn 10; raw 30, still 18 counted.
- **Fix:** the burn adds burn_cost to age, or is a `burned_years` term subtracted after the ceiling. Add a case to AC-CG-61.

⚠️ **W-D. kinh-mach-do names a system that does not exist.**
- The rule 17 catalogue (325 and 341) gives "Lifespan (Thọ Nguyên)" as the system touched by #7 Embryonic Breath and #23. The systems index has no Lifespan system.
- The host list (about line 1492) already routes #7 to Time & Turn, and #23 is hosted by Realms rule 18.
- **Fix:** relabel both catalogue rows.

### Info

ℹ️ **I-E. Two cap values exist for part of a season after involuntary loss.**
- canh-gioi's NG8 case (752–756) recomputes the cap "at the next season start".
- Character Stats says a treasure's modifiers leave the sheet immediately.
- #22 ("under 5 years left") and #23 ("remaining lifespan > burn_cost") read the cap in between.
- **Suggestion:** keep the cap live from the sheet, and run only the death check at season start.

ℹ️ **I-F. Registry `lifespan_cap` gaps.**
- `referenced_by` omits linh-can.md and kinh-mach-do.md, although both feed `lifespan_years` into it.
- `output_range: [120, unbounded]` assumes `lifespan_pct` ≥ 0, which no GDD states.

ℹ️ **I-G. linh-can Cross-References still has no `cong-phap.md` row** (C3 residual).

**Confirmed consistent by hand:**
- The W10 prices: Time 18 × 2.5 + 90 = 135 W; Reincarnation 45 W; Life 52 W.
- The W10 price is realm-independent: a full ceiling is 0.15·L_r years at 300/L_r W per year, so 45 W in every realm.
- The lifespan formula agrees across CS rules 13–14 and Formulas I, canh-gioi rule 14 and the registry.
- AC-CS-52, AC-CS-54, AC-CG-61 and AC-CG-62 reproduce.
- cong-phap rules 6 and 12 and AC-CP-05 agree with Realms rule 14.
- NG8's "next season start" timing matches cong-phap rule 8.

---

## Game Design Issues

### Blocking

🔴 **F1. The FE→CF pill cannot be grown in time by most lives (3e, 3c).**

**The numbers:**
- canh-gioi Formulas D: `λ = p_brew · n_plots · f · h · W / Y`, with W "about … 140 in FE".
- Kim Tủy Quả `min_age` is about 152 (Parameter keys, the registry), and it is plantable only from Foundation Establishment on (Formulas D).
- For a life with no Wood and no herb-growth bonus (h = 1), the herb ripens after the realm's growing years run out. Such a life harvests **zero** Core Formation pills, while the formula gives λ = 0.78.

**Why the formula misses it:**
- λ treats herb age as if it could be split. In practice it is a step function: a harvest happens only when h × W ≥ 152.
- That requires roughly Wood purity ≥ 11, `herb_growth_pct` ≥ 9, or a lifespan bonus of 12 years or more.
- About 62 % of lives have no Wood.

**How it happened:** the ×1.43 Y recalibration earlier on 2026-11-04 (cross-review D1) raised `min_age` from 100 to 152, which pushed it past W. Under the old value one harvest fit.

**Consequences:**
- The FE→CF row of the Formulas E S-by-count table is invalid.
- The Tuning Knobs safe range for Kim Tủy Quả `min_age` (125–195) was derived from the linear model, so it is also invalid.
- Herb-growth and lifespan bonuses stop being a build choice and become a toll every life must pay at FE (3c).
- The cliff appears in no breakdown (Pillar 2).
- The guessed NS and DT recipes (Y ≈ 390 / 680, W ≈ 280 / 560) may hit the same trap.

**Options (user decision):**
- (a) Add a constraint to Formulas D and the Item DB obligations: at least two sequential harvests fit in the realm, `min_age / h_min + brew ≤ W / 2`.
- (b) Make Kim Tủy Quả plantable in QR.
- (c) Lower its `min_age`, and move the baseline lever to plot count or brew rate.
- (d) Replace the linear λ with a discrete harvest model, and have AC-CG-30 run the bot per root.

### Warnings

⚠️ **F2. The herb clock, not climbing, sets how long FE takes (3a, 3g).**
- When `min_age` exceeds the climb (FE: 152 years against climbs of 50–80), roots of every speed leave FE at about the same age.
- While waiting at the bottleneck, all three progression loops stop:
  - the bar's excess is lost (Realms rule 7);
  - no levels means no Meridian points;
  - gated technique mastery loses its excess (cong-phap B).
- For a 3-element root that is about 100 of about 150 FE years with no growth. Speed builds buy idle time, which strains Pillars 3 and 4.
- **Options:**
  - (a) A small, capped "consolidate the foundation" use for bottleneck surplus.
  - (b) Plant breakthrough herbs one realm early, so the wait overlaps the climb.
  - (c) Accept it, with a one-click "wait until ripe" closed-door retreat in Time & Turn.

⚠️ **F3. About half of baseline lives never roll at CF→NS (3e).**
- Root-free λ = 0.70, so P(no pill) = e^(−0.70) ≈ 0.50. Over the birth mix it is about 0.37.
- Much of the 7-in-10 baseline failure is dying in the queue, not a chosen risk. That weakens "each realm crossed is a story".
- **Options:**
  - (a) Accept it, and have the Advisor show P(no pill this life).
  - (b) Move baseline difficulty from supply to per-attempt odds: more pills at a lower q gives the same S with more rolls.
  - (c) Guarantee one market pill per realm, at a price.

### Info

ℹ️ **F4. The cross-realm win fantasy has no budget yet (3g).**
- game-concept builds a retention hook on "absurd cross-realm wins".
- The combat realm term (CS Formulas C) jumps ×6.9–×10 per realm, while `tech_power` reaches only ×4.4 and scales spiritual power, not combat power.
- **Suggestion:** record a target as a Combat GDD obligation in the systems index.

---

## Cross-System Scenario Issues

Scenarios walked: 4
1. **FE entry → plant Kim Tủy Quả → wait at the bottleneck → lifespan nears → #22 or #23.** ⚠️ This is where F1 and F2 show. With h = 1 the herb ripens after the life ends, so #22 and #23 never get a pill attempt to act on. W-C applies to the burn.
2. **A treasure is stolen mid-season → #22's "under 5 years left" check → season start.** ⚠️ I-E: which cap #22 reads during the rest of that season is undefined.
3. **Great breakthrough → Mutation Awakening grants Time → the ceiling rises → the old main method at ×0.25 → crude floor → rule 18 copy.** ℹ️ The data flows correctly. Time's +200 years shows mostly as held back until the planned data pass.
4. **Failure at heart demon 80 with #25 → qi deviation → vitality 5 % (#4's −20 % attack) → #23 extra roll → second failure → heart demon 95 → doubled deviation chance → death.** ℹ️ A deliberate gamble, and every step is defined.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| canh-gioi.md | F1: discrete herb timing breaks FE→CF λ and the Kim Tủy Quả range; W-C: #23 burn undefined against the ceiling | Design / Consistency | Blocking |
| linh-can.md | W-A: AC-LC-25 and OQ1 stale after W10; I-G | Consistency | Warning |
| character-stats.md | W-B: dangling `lifespan_pct` pointer | Consistency | Warning |
| kinh-mach-do.md | W-D: "Lifespan" system label on #7 and #23 | Consistency | Warning |

---

## Verdict: FAIL

F1 must be resolved before architecture begins. Its fix needs a user design decision, from options (a)–(d) above.

### Required actions before re-running
- canh-gioi Formulas D and E, and the Kim Tủy Quả row in Tuning Knobs: resolve F1 by one of options (a)–(d), and recompute the FE→CF row and the safe range. Check the NS and DT recipes against the same constraint.
- canh-gioi rule 18 and AC-CG-61: define how the #23 burn applies against the ceiling (W-C).
- Recommended in the same pass: W-A, W-B and W-D, which are small edits.
