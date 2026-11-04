# Cross-GDD Review Report — 2026-11-04 (seventh pass, 04g)

Date: 2026-11-04
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none
Focus: full (consistency and design theory)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)

**Method disclosure.**
- **Agents:** two `game-designer` agents ran in parallel, one for consistency and one for design theory. Both read the GDDs by section from disk; 440 KB is too large to paste.
- **Main session:** walked the Phase 4 scenarios.
- **Context:** this pass follows the 04f revisions and the subagent-run lean design reviews of the same day: canh-gioi eighth pass, character-stats fourth, linh-can fourth (all NEEDS REVISION, then revised). The user decisions recorded in those review logs are treated as settled design, not as findings.
- **Consistency coverage:**
  - **Full on the changed seams:** the h formula; ceilings and penalties after the cap; the talisman between canh-gioi rule 8 and kinh-mach-do E2; the root terms against linh-can pricing.
  - **Recomputed across files:** the AC fixtures AC-CS-28, AC-LC-24, AC-KMD-44 and AC-CG-19/20/22/29/60.
  - **Partial:** 2a (cong-phap's Dependencies not read), 2c (the canh-gioi and kinh-mach-do Cross-References tables not read; prose by targeted grep) and 2d (cong-phap's and kinh-mach-do's Tuning Knobs not read).
- **Design-theory coverage:**
  - **Not read directly:** `character-stats.md` itself; its changes came from its review log.
  - **Not verified independently:** the Time ceiling-run and 12-plot figures, which come from the canh-gioi scratch model. The edge-plus-build figures are estimates.
  - **NOT ASSESSED:** 3d for spirit stones, seeds, market stock, alchemy yields, Spirit Fields mastery and plot cost, because Item DB, Market, Alchemy and Spirit Fields have no GDDs.

---

## Consistency Issues

### Blocking

🔴 **C1. Registry `breakthrough_guard` lacks τ_a and contradicts kinh-mach-do E2.**
- The registry (~l.338) still has `q_desp = min(2q, q+delta_desp, q_max, q+delta_max*(1-q)/(1-S))`.
- E2 (~l.719) now uses `q_max − τ_a` and `(1 − q − τ_a)`, an attempt chance of `q_desp + τ_a`, and `S'_22 = 1 − (1 − S)(1 − q_desp − τ_a)/(1 − q − τ_a)`.
- Code built from the registry would give the 0.106 lift that AC-KMD-44 and canh-gioi rule 8 forbid.
- **Fix (mechanical):** copy E2's formulas into the registry, add `tau_a`, extend `referenced_by`, and set `revised`.

🔴 **C2. Registry `lifespan_cap` contradicts Character Stats rule 14 and Formulas I (changed today).**
- The registry (~l.433) has `min(pill_years + treasure_years + sum(lifespan_years), lifespan_frac*L_realm)` and `output_range: [120, unbounded]`.
- Character Stats now has:
  - `B_life = min(pill_years + Σ⁺ lifespan_years, f_life·L) + Σ⁻ lifespan_years`;
  - no separate treasure term;
  - a negative bonus is allowed, below the base. AC-CS-54 expects a QR cap of 90.
- canh-gioi rule 14 agrees with Character Stats.
- **Fix (mechanical):** rewrite the expression, drop `treasure_years`, set the range to `[0, unbounded]`, and set `revised`.

### Warnings

- ⚠️ **C3. canh-gioi Formulas D "Growth pays in steps" (~l.640) contradicts the text just above it.**
  - It says "Everything except Wood shares the `herb_growth_pct` ceiling of 10".
  - The lines above it (629–631) and Character Stats rule 14 make Time's factor a root term too.
  - **Fix:** "Everything except the root terms (Wood's purity and Time's herb-aging factor)".
- ⚠️ **C4. canh-gioi ~l.634 still lists Time as granting `herb_growth_pct`.** Under linh-can, Time's +100 % herb growth is held-back data that the data pass drops.
- ⚠️ **C5. Time holders break `bonus_ceiling_target`, and no document scopes them out.**
  - canh-gioi l.652 says that at every ceiling with the talisman, a Time holder reaches 0.50 / 0.51 at CF→NS / NS→DT.
  - The registry note, canh-gioi Tuning Knobs l.1108, Character Stats Formulas I l.603 and AC-CG-60 exempt only fields.
  - linh-can's knob allows `herb_age_root_pct` up to 68.
  - **Options (user decision):**
    - (A) Root factors are outside the target, like fields; AC-CG-60 runs with Awakening off.
    - (B) Shrink Time's factor until it fits.
    - (C) Lower every ceiling.
- ⚠️ **C6 → Scenario blocker S1** (below): h can be 0, and Formulas D divides by it.
- ⚠️ **C7. kinh-mach-do E2's intent text (~l.758–765) is out of date.**
  - It claims "a life without edges at most 0.40" and "the tree's 8 pp ceiling sits inside the targets".
  - canh-gioi now has a ceiling run of 0.43–0.44, a maxed tree at +0.12 (OQ13) and fields up to 0.84.
  - **Fix:** restate it as "a capability adds at most 0.10 to whatever S the life has built".
- ⚠️ **C8. systems-index row 7 omits a dependency.** Its soft list does not include Spirit Herbs & Spirit Fields, which Character Stats Dependencies (l.807) now lists.
- ⚠️ **C9. `herb_age_root_pct`'s ownership and range disagree.**
  - linh-can makes it a knob (25, safe 0–68).
  - Character Stats types it `{0, 25}` and derives its 2.475 maximum from the 25; canh-gioi says "0 or 25".
  - There is no registry entry.
  - **Fix:** use "0, or Time's value (Spiritual Roots knob)" in every document, and add a registry entry.

### Info

- **C10. AC-KMD-44's talisman fixture uses an impossible state.** It sets S = q = 0.1225 with τ_a 0.05, so S is below the attempt's own chance. The domain should be S ≥ q + τ_a. The arithmetic (30439/140400) is correct.
- **C11. canh-gioi Formulas H does not say whether an attempt made counts its q including τ.** Leaving τ out keeps S_guard a lower bound.
- **C12. linh-can Formulas E (l.492):** "a drawback would need its own rule". Penalties-after-cap already prices v < 0 in full.
- **C13. Character Stats leaves Time's root factor out of two places:** the Interactions row (l.298) and Dependencies row 6 (l.793).
- **C14. canh-gioi's Dependencies row for the Meridian Map** should also say that rule 8 consumes E2's q_desp with τ_a.
- **C15. Cross-References gaps.**
  - linh-can: Character Stats rule 14 and Realms Formulas D's h.
  - Character Stats: Realms Formulas D and `bonus_ceiling_target`.
- **C16. AC-CG-22 wording:** "the attempt's chance is q_desp + 0.05".
- **C17. The registry `bonus_ceiling_target` note** should say `field_plots` 0.
- **C18. kinh-mach-do E2's S range** is "0–0.95" in Variables but "0–1" in Output Range.

**Confirmed consistent by hand:**
- **The h formula** is identical in Character Stats Formulas G, canh-gioi Formulas D, linh-can Formulas E and the registry. Herb growth runs 0–2.475.
- **n_plots and p_brew** match across files.
- **Ceilings 10 / 3 / 0.15 with penalties after the cap** agree across Character Stats rule 14, Formulas I, AC-CS-54, canh-gioi and the registry.
- **Rule 12 has nine source kinds** in every place that counts them.
- **The talisman** (one per step, τ 0.05, held pill only, never on #23, #13 still counts as used) agrees between rule 8, E2, the Formulas C clamp and the registry.
- **Recomputed and passing:**
  - AC-CS-28: 2.035 and 1.628.
  - AC-CG-19: 0.1725.
  - AC-CG-20: 0.1225 / 0.2425 / 0.2925.
  - AC-CG-29: every recipe's C_k by exact packing, attempt years, and S 0.2204 / 0.2172 / 0.3159 / 0.2623 / 0.1322 / 0.2300.
  - AC-KMD-44: all values.
  - linh-can prices: Life 34, Lava 8.1, Pill Fire 23.1, Spirit Farming 20, Reincarnation 20, Time 110.5.
  - AC-CG-60: 0.43 / 0.44 / 0.42 / 0.43.
- **The registry entries** for recipes, `pill_chance` and targets match canh-gioi.

---

## Game Design Issues

### Blocking

None new. 04f's B2 and B3 are closed by the user's decisions: discrete brews with the entry-age W, best plot play, and fields as a build.

### Warnings

⚠️ **F2 (carried; WORSE, now measured). Idle years at a full bar at the CF and NS bottlenecks (3a, 3e, Pillar 4).**
- **Measured for a root-free life with a 3-element climb** (years at a full bar up to the third attempt):
  - QR→FE: about 50 (48 % of W);
  - FE→CF: about 47 (39 %);
  - CF→NS: about 234 (78 %; recipe 2 × 130 + 40);
  - NS→DT: about 431 (80 %).
- **What stalls:** levels, tree points and the technique mastery excess.
- **Time's speed line** (88 of its 110.5 W) adds no S at CF and NS, because the herb clock binds; the exception is 1-element roots.
- **Options (user decision):**
  - (a) A bounded sink for a full bar.
  - (b) Plant the next realm's herb one realm early.
  - (c) Shorten the CF and NS `min_age` toward the climbs (about 60 / 100) and raise qty.
  - (d) Accept the wait as tending the herb, with a one-click "retreat until ripe" in Time & Turn.
  - (e) Rework Time's speed line.

⚠️ **F7 (carried; CHANGED). Growth pays in steps, but the tree prices it linearly (3c, Pillar 2).**
- At the median W, the capped 10 % herb growth usually buys 0 brews for a root-free life (for example FE→CF T₄ = 131 > W 120). So the 9 W it costs is dead.
- Time's ×1.25 gives +1 brew at every median, so it is priced fairly.
- **Options:** price growth by expected steps; take `herb_growth_pct` out of the tree pools; or accept it with the Advisor's "next step" line.

⚠️ **F8 (carried; slightly worse). Attention budget (3b).**
- The bottleneck adds B / B_remaining, the "+1 plot" preview, the talisman toggle, the #22/#23 choice and the staggered packing.
- **NOT ASSESSED** further without UI, Guidance or Time & Turn GDDs.
- **Option:** a season digest.

⚠️ **F11 (new). Plots are the cheapest breakthrough odds in the game, and they bypass `tree_breakthrough_cap` (3c, Pillars 1 and 3).**
- **S per W at the root-free median:**

  | Lever | S per W |
  |---|---|
  | +1 plot (10 W) | 0.0062 |
  | +1 pp `breakthrough_chance` (5 W) | 0.0033 |
  | `alchemy_success` 3 (8.1 W) | 0.0011 |
  | `herb_growth_pct` 10 | ≈ 0 |

- **Against the tree cap:**
  - One tree plot per cluster is worth about 3.8 pp of q, against the 0.5 pp per-cluster breakthrough cap.
  - Two tree plots beat the whole 8 pp `tree_breakthrough_cap`.
  - Spirit Farming (order 2, 20 W) beats Time (110.5 W) on S by about 2×.
- **Bot policy gap:** the bot ACs run at `field_plots` 0 but "allocate the tree", and nothing says whether the bot may take a plot notable.
- **Options (user decision):**
  - (a) Reprice `field_plots` in the tree (about 19–25 W), or remove it from the pools.
  - (b) Count tree plots against `tree_breakthrough_cap`.
  - (c) State that the bot takes no plot notable.
  - (d) Accept the field cultivator as the strongest bottleneck build, and require the Spirit Fields GDD to give plots upkeep.
- **Becomes Blocking** if the Spirit Fields GDD makes plots cheap.

⚠️ **F13 (new). Each attempt is a 1-in-8 roll (3g, Pillars 2 and 3).**
- A root-free life fails all three attempts with chance 0.78.
- Preparation pays through the brew count, not the moment. The only choice at the attempt is the talisman, which is on by default. Failure feedback is "the 88 % came up".
- **Mitigations:** about half of q is already built, and S is shown exactly.
- **Options:**
  - (a) Accept it, and make cumulative S the headline everywhere.
  - (b) Failure insight: a bounded + q on later attempts in the step, with `pill_chance` lowered to compensate.
  - (c) Partial-failure outcomes.
  - (d) Move some preparation into per-attempt q (pill quality from Alchemy).

⚠️ **F14 (new; folds in OQ13). A built life reaches the edge target, and edge plus build approaches q_max (3e, 3f).**
- **Without an edge:**
  - the ceiling run gives 0.43;
  - all q extras at their maxima give about 0.62, plus #22/#23 on top;
  - 12 plots give 0.61–0.70;
  - Time with the ceilings gives 0.50–0.51.
  - So a maxed life without an edge reaches 0.70 or more.
- **With an edge:** edge plus build is estimated at 0.85–0.93.
- **Options:**
  - (a) Accept: 0.70 means "an edge, unbuilt".
  - (b) Add an `edge_ceiling_target`.
  - (c) Combine q terms in odds space for diminishing returns.
  - (d) Cap the q extras, Đạo Cốt included.

⚠️ **F15 (new). Marginal ancestor pricing hollows out the craft mutations (3g, Pillar 1, near the "stat-block card picking" anti-pillar).**
- Pill Fire's signature 3 pp of alchemy adds +0.009 S. It equals 12 points of Fire purity, and one tree cluster can fill the whole ceiling.
- Spirit Farming's herb line adds 0 over Life.
- Lava, Reincarnation and Death sit under their floors.
- **Options:**
  - (a) Holder-raised ceilings (Pill Fire raises the alchemy ceiling 3 → 6, with AC-CG-60 re-run).
  - (b) Turn signature lines into root factors, as was done for Time.
  - (c) Unique rule effects.
  - (d) Accept, and retune the lines in the OQ1 data pass.

⚠️ **F16 (new). The targets assume exact staggered packing, and plant order alone can drop B to 0 (3b, 3e, Pillar 2).**
- At FE→CF's 10th-percentile W of 94, root-free:
  - staggered planting gives B 2;
  - naive K-K-C in every plot gives B 0;
  - C-K-K gives B 1.
- B_remaining only reports the damage after planting.
- **Options:**
  - (a) An Advisor one-click best-play plant plan.
  - (b) Show B for the planned layout before sowing.
  - (c) Calibrate on a simpler policy.
  - (d) A warning when the planned B is below the best B.

### Info

- **F3 (carried; downgraded, largely resolved).**
  - P(no pill) is 0.043–0.047 at B 3 and 0.12–0.13 at B 2.
  - The remainder is FE→CF's 1st percentile (B 1, 0.36).
  - F16 can reopen it.
- **F4 (carried; unchanged).**
  - The cross-realm-win fantasy still has no combat budget.
  - NOT ASSESSED (no Combat GDD).
- **F10 (positive).** The exact "B brews, S %" readout is the strongest Pillar 2 feature.
- **Talisman (I-12).** One per step, about +0.04 on the mean; the E2 guard is exact at δ_max.
- **Stakes (I-13).** Odds are flat at about 0.30 per gate, but the years at stake grow: 104 → 120 → 345 → 641. At baseline the chance of reaching DT is about 0.3⁴ ≈ 0.008 per life.
- **Diên Thọ Đan (I-14, OQ14).** Its competition for the CF pill's herb is still not in the bot plan.

**Pillar map** (● primary, ○ secondary):

| System | P1 | P2 | P3 | P4 | P5 | Note |
|---|---|---|---|---|---|---|
| Spiritual Roots | ● (strained: F15) | ● | ○ | ● | | Time is now a real apex, but its speed is idle at late gates |
| Character Stats | ○ | ● | ● | ○ | | No Player Fantasy (advisory) |
| Realms & Bottlenecks | | ● (F10; F16 gap) | ● | ● (strained: F2) | | F13's feel is open |
| Cultivation Techniques | ● | ○ | ● | ● | ○ | Unchanged since 04f |
| Meridian Map | ● (strained: F11) | ● | ● | ○ | ○ | The E2 guard is exact |

No anti-pillar is violated. The shared identity holds: "a mortal who builds an engine within visible rules". The risk is that the engine collapses into "more plots".

---

## Cross-System Scenario Issues

Scenarios walked: 5
1. A heavy herb-growth penalty → h = 0 → harvest timing.
2. A talisman on a #22 Last Radiance attempt → E2 guard → the registry.
3. A lifespan penalty → bonus below 0 → cap below base → the rule 14 confirmation.
4. Time awakened at Core Formation → h × 1.25 → B + 1 → the ceiling target.
5. Unaided planting at a late FE entry → B → the brew guarantee.

### Blockers

🔴 **S1 (C6): heavy herb-growth penalty (Character Stats → Realms).**
- Under penalties-after-cap, `herb_growth_pct` can reach −100 or below, and Character Stats Formulas G then gives h = 0.
- canh-gioi Formulas D computes T_k = C_k / h (l.451), with h's range "0+", and no Edge Case covers h = 0.
- **Undefined behaviour: a division by zero.**
- **Fix:** "if h = 0, no herb ripens: T_k = ∞ and B = 0", plus an Edge Case and an AC-CG-29 line (−150 → h 0 → B 0).

### Warnings

- ⚠️ **S2 (C1): talisman on a #22 attempt (Realms rule 8 → Meridian Map E2 → registry).** The GDDs agree. The registry formula is stale, so code generated from it would exceed δ_max.
- ⚠️ **S3 (C2): lifespan penalty (Character Stats → Realms rule 14).**
  - The flow is defined: a cap below base is allowed, and a player-made change that would put the cap at or below age needs confirmation.
  - The registry's `lifespan_cap` range still says it cannot happen.
- ⚠️ **S4 (C5): Time awakened at Core Formation (Spiritual Roots → Character Stats → Realms).**
  - h × 1.25 lifts B by 1 at the median, taking S 0.30 → 0.36. At every ceiling with the talisman it reaches 0.50–0.51.
  - Whether that breaks AC-CG-60 depends on the C5 decision.
- ⚠️ **S5 (F16): unaided planting at a late FE entry (W 94, Realms → Guidance).** Naive planting gives B 0, the cliff the brew guarantee was meant to remove. No Advisor plan prevents it.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| canh-gioi.md | S1/C6: h = 0 undefined. C3, C4, C11, C14, C16. F2 and F16 (design) | Consistency / Design | Blocking |
| kinh-mach-do.md | C7 stale E2 intent; C10, C18; F11 plot prices (design) | Consistency / Design | Warning |
| character-stats.md | C9, C13, C15; C5 scope (design) | Consistency | Warning |
| linh-can.md | C9, C12, C15; F15 (design) | Consistency / Design | Warning |
| (registry, not a GDD) | C1, C2, C9, C17 | Consistency | Blocking |

---

## Verdict: FAIL

Three blockers remain, and all three are mechanical:
- the stale registry `breakthrough_guard` (C1);
- the stale registry `lifespan_cap` (C2);
- the undefined h = 0 case in canh-gioi Formulas D (S1).

None needs a design decision. The design-theory pass found no new blocker, but six warnings need user rulings: F2, F11, F13, F14, F15, F16, and C5.

### Required actions before re-running
1. Registry: rewrite `breakthrough_guard` from kinh-mach-do E2, and `lifespan_cap` from Character Stats Formulas I (C1, C2).
2. canh-gioi Formulas D: define h = 0 (no herb ripens, B = 0), with an Edge Case and an AC line (S1).
3. Recommended in the same pass: the small wording fixes C3, C4, C7, C8, C9 and C13–C18.
4. User rulings, best taken before the next cross-review:
   - C5 (Time against the ceiling target);
   - F11 (plot pricing);
   - F2 (idle years at CF and NS);
   - F16 (planting aid);
   - F13 and F14 (odds feel, and the edge against a built life);
   - F15 (craft-mutation identity).
