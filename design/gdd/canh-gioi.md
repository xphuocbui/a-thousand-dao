# Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)

> **Status**: In Review (2026-11-04, after cross-GDD review 04g: shorter CF/NS herbs, failure insight, q-extras ceiling, root factors and holders outside the target, plant plan; awaiting re-review). See `reviews/canh-gioi-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-04
> **Last Verified**: 2026-11-04
> **Implements Pillar**: Pillar 3 (Power Is Built, Not Given), Pillar 4 (Every Season Counts); touches Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Realms & Bottlenecks is the cultivation ladder: 300 levels in five realms, climbed
season by season by filling a cultivation base bar. Every level pays a skill tree point,
and each small breakthrough raises stats by +15 %. At the top of each realm a bottleneck
requires a great breakthrough: a pill attempt that needs the realm's breakthrough pill
plus one realm-specific condition (none, a spirit vein, low heart demon, an insight and
the tribulation). Each attempt's chance is visible, and a failure costs real time and
risk. Each pill is about a 1-in-10 roll (1 in 12 at the two later gates), and each failed
pill attempt adds a little failure insight to the next, up to +4 points. The herbs a life
can age before its lifespan runs out set how many pills it brews, so about 3 in 10 lives
cross each bottleneck at baseline and about 7 in 10 with the player's edge.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Character Stats, Spiritual Roots (Linh Căn), Time & Turn, Item DB`

## Overview

Realms & Bottlenecks (Cảnh Giới & Bình Cảnh) is the game's cultivation ladder: 300 levels
grouped into five realms, from Qi Refining (Luyện Khí) through Foundation Establishment
(Trúc Cơ), Core Formation (Kết Đan) and Nascent Soul (Nguyên Anh) to Deity Transformation
(Hóa Thần). Each season the character cultivates, which fills a cultivation base (tu vi)
bar at a rate shaped by spiritual root (linh căn), cultivation technique (công pháp),
comprehension (ngộ tính), local spiritual qi (linh khí) and pill toxicity (đan độc). A full
bar raises the level. Every level pays a Meridian Map (Kinh Mạch Đồ) point, and the small
breakthroughs inside a realm (the middle stage, the late stage and great perfection:
trung kỳ, hậu kỳ, đại viên mãn) raise stats and pay bonus points. At the top of each realm
a bottleneck (bình cảnh) holds the level until a great breakthrough succeeds: a rolled
chance that needs the realm's pill and one condition of that realm (none for Foundation
Establishment, a spirit vein for Core Formation, low heart demon for Nascent Soul, an
insight and the tribulation for Deity Transformation), shaped by talent and bonuses,
whose failure costs
cultivation base, vitality and sanity (heart demon, tâm ma) and can end the life.

The player's part is mostly passive until the bottleneck: choose where and how to cultivate
(open or closed-door, which technique) and spend seasons. The bottleneck is the
decision point: prepare the pill and herbs, seek a fortuitous encounter (cơ duyên), and
choose when to risk the attempt. NPCs follow the same ladder, with their fate rolled once
per realm.

The system exists because it is the game's spine and its clock (Pillars 3 and 4): power is
earned by climbing, and lifespan (thọ nguyên) turns the climb into a plan instead of a
grind. The odds are tuned so that most lives stall at a bottleneck (about 3 in 10 cross
at baseline, about 7 in 10 with the player's edge), which is what makes each realm
crossed a story. Every number it produces is visible as a breakdown (Pillar 2).

## Detailed Design

Rules 1–15 describe the ladder and Rules 16–18 the capability hooks; together they are the
target design. The built game (`src/gameplay/cultivation/`,
`assets/data/cultivation_realms.json`) still runs the older stage ladder: 13 Qi Refining
layers plus 4 stages per realm, with a tu vi cost per stage. Moving it to levels is an
implementation story; Open Questions lists what the move touches.

### Core Rules

**The ladder**

1. **Levels and realms.** A character has a level L from 1 to 300 (`level_cap`). L fixes
   the realm: Qi Refining (Luyện Khí) 1–39, Foundation Establishment (Trúc Cơ) 40–79, Core
   Formation (Kết Đan) 80–129, Nascent Soul (Nguyên Anh) 130–199, Deity Transformation
   (Hóa Thần) 200–300 (`realm_level_bands`; this GDD owns them). The level replaces the
   built stage counter, which becomes derived from L.
2. **Stages.** In a realm of N levels from lo to hi, the early stage (sơ kỳ) is levels lo
   to t−1, the middle stage (trung kỳ) is t to h−1, the late stage (hậu kỳ) is h to hi−1,
   and great perfection (đại viên mãn) is the single level hi, where t = lo + ⌊N/3⌋ and
   h = lo + ⌊2N/3⌋. Qi Refining also shows 13 layers (tầng) as labels, 3 levels each (layer
   k is levels 3k−2 to 3k). Layers and stages are independent overlays, so Qi Refining's
   middle stage starts at level 14 and its late stage at level 27, both inside a layer.
3. **Cultivation base (tu vi).** The character holds a bar toward the next level. Each
   season it gains the cultivation rate, always shown as a breakdown (Pillar 2): realm
   base rate × spiritual root curve × cultivation technique × comprehension × local qi
   density × pill-toxicity penalty × (1 + cultivation-speed bonuses ÷ 100). The speed
   bonuses are one multiplier, not a flat addition (Formulas I).
   - **Season-start rate.** The rate is computed once, at the start of the season, from
     the stage then (user decision 2026-11-04). A stage-group boundary crossed during
     the season changes the curve factor from the next season.
   - When the bar reaches the current level's cost, the level rises and the surplus
     carries over; several levels can rise in one season. Costs are data (Formulas).
4. **Level reward.** Each level gained is announced to the Meridian Map, which pays 1
   point per level. Points are a pure function of the highest level reached (the Meridian
   Map's Formulas A); the `level_gained`, `stage_reached` and `breakthrough_succeeded`
   events tell it when to recompute and feed the log, UI and achievements. A level never
   changes stats.

**Breakthroughs**

5. **Small breakthroughs.** Reaching the middle stage, the late stage or great perfection
   of any realm is a small breakthrough. It needs no roll and no item: it happens as the
   level is reached. It pays its bonus points (the Meridian Map owns the arithmetic) and
   raises stats (rule 6).
6. **Stat rise.** Spiritual power (linh lực), divine sense (thần thức), vitality (khí
   huyết) and the realm term of combat power (chiến lực) equal the realm's base × a stage
   multiplier. The multiplier is 1.0 in the early stage and rises by `stage_power_step` at
   each small breakthrough. A great breakthrough moves the character to the next realm's
   bases (about ×10 per realm) at multiplier 1.0. Innate talents (thiên phú) never change
   by climbing. Today only combat power uses the stage multiplier; extending it to the
   other three is part of this design.
7. **The bottleneck (bình cảnh) and its condition.** At great perfection of a realm that
   has a next realm, the level cannot rise. The character still cultivates: the bottleneck
   bar (its cost is data) fills, and any excess is lost. When the bar is full the
   character is at the bottleneck and may attempt the great breakthrough. Every great
   breakthrough needs its realm's entry pill, and each has one extra condition of its own
   (user decision, 2026-11-03), so every bottleneck is a different preparation:

   | Breakthrough into | Condition, checked at the attempt | What it asks of the player |
   |---|---|---|
   | Foundation Establishment | none: the pill alone | learn the loop: grow herbs, brew, attempt |
   | Core Formation | local spiritual qi density at least `core_density_min`: a spirit vein (linh mạch) place, or the character's own gathering formation, whose density bonus counts | travel to a vein, or build and maintain a formation |
   | Nascent Soul | heart demon at most `nascent_tam_ma_max` | keep heart demon low across a whole realm: fewer kills, purging, Dao heart (đạo tâm) |
   | Deity Transformation | holds this realm's breakthrough insight, granted by an enlightenment (đốn ngộ) event and kept once gained; a successful roll then faces the Heavenly Tribulation (Thiên Kiếp) | comprehension and story; survive the tribulation |

   The terminal and UI show each condition as met or unmet before the attempt.
8. **Attempt.** The player chooses when to attempt; an attempt takes one season. The
   success chance is a breakdown (Pillar 2):
   - **Pill attempt** (the pill is held and the condition is met): the entry pill's
     chance, plus:
     - the **q extras**: pill quality, comprehension, Dao heart, the tree's breakthrough
       chance (capped by the Meridian Map's `tree_breakthrough_cap`, 8 pp, which limits
       the tree's own contribution only) and item and event bonuses (fortuitous
       encounters [cơ duyên]). Their sum is capped character-wide at
       `q_extras_ceiling_pp` (10 pp; Formulas C; user decision 2026-11-04, cross-GDD
       review 04g, F14);
     - outside that ceiling: destiny-perk (thiên mệnh) bonuses such as Đạo Cốt, the
       step's failure insight (rule 10) and a breakthrough talisman, each bounded on its
       own.

     The total is clamped to 1%–95%. The attempt burns the best matching pill and the
     talisman, whether it succeeds or not.
   - **Bare attempt** (no pill, or the condition is unmet): the realm's bare chance only.
     No talent, tree, talisman, failure insight or event bonus applies, and no pill is
     burned. A failed bare attempt still takes rule 10's penalties but adds no failure
     insight. A bare attempt is near-hopeless by design.

   A breakthrough talisman boosts only a pill attempt, and at most one talisman is used per
   realm step (user decision 2026-11-04, cross-GDD review 04f). Its rules (eighth-pass
   review 2026-11-04):
   - **Assignment.** The attempt preview has a toggle, "use talisman on this attempt". It
     is on by default for the realm step's first pill attempt when a talisman is held, and
     the player may turn it off to save the talisman for a later attempt.
   - **Once used.** The step's flag "talisman used this breakthrough" is set and saved.
     The preview then shows the toggle disabled with "talisman already used this
     breakthrough". The flag clears on a successful great breakthrough.
   - **Capability #13 Endless Talismans** (30 % chance a used talisman is not consumed):
     a talisman it keeps still counts as used this step.
   - **Gift pills.** A talisman may go on an attempt with a gift or bought pill.
   - **With #22.** The Meridian Map's q_desp is computed from the attempt's chance without
     τ, using its Formulas E2 guard with the talisman term: when a talisman is on the
     attempt, the guard's #22 term uses (1 − q − τ) instead of (1 − q). τ is then added to
     that attempt. So the lift stays at δ_max (Open Question 16, answered 2026-11-04).
     E2's q is the attempt's chance including its failure insight (rule 10), without τ.
   - **With #23.** The extra roll may not use a talisman. It counts as a pill attempt for
     failure insight (rule 18).
9. **Success.** The character enters the early stage of the next realm: level +1, bar 0,
   vitality full, stats at the next realm's bases, lifespan cap (thọ nguyên) raised to the
   new realm's (rule 14; the lifespan bonus ceiling rises with it, so clamped bonus counts
   again), and the great breakthrough bonus points paid (the bonus minus the `pct_dai` (35 %)
   advance already paid at great perfection).
   - **The `breakthrough_succeeded` event** fires once per success, for the player only
     (user decision 2026-11-04). NPC stage advances and fate rolls (rule 12) emit
     nothing, so NPCs get no Mutation Awakening from it.
   - For the Deity Transformation step the event fires when the Heavenly Tribulation
     resolves in survival. Until that system exists, it fires on roll success.
10. **Failure.** The bar loses 30 % of its content (`failure_tu_vi_loss_pct`), the
    character gains heart demon (tâm ma, `failure_tam_ma_gain`) and loses 40 % of maximum
    vitality (`failure_khi_huyet_loss_frac`, floor 5 %). The heart demon gain lands first;
    then a qi deviation (tẩu hỏa nhập ma) rolls with chance max(0, heart demon − Dao heart
    ÷ `tam_ma_backlash_divisor`) % × (1 + `qi_deviation_pct` ÷ 100), using the new value. Heart demon is a decimal number.
    A deviation that hits sets vitality to 5 %, unless heart demon is
    `backlash_death_tam_ma_threshold` (90) or more, in which case the character dies.
    Death needs both: a deviation hit and heart demon at 90 or more. With no deviation hit
    the character lives, however high heart demon is. A safe-failure effect (a
    destiny perk) removes the bar loss and halves the heart demon gain. A failure never
    lowers the level and takes no points back. The bar must refill before the next
    attempt, which is the time cost.
    - **Failure insight** (user decision 2026-11-04, cross-GDD review 04g, F13). Each
      failed pill attempt in a realm step adds `failure_insight_pp` (2 percentage points)
      to every later pill attempt in the same step, up to `failure_insight_cap` (4 pp).
      So a step's first pill attempt has +0, the second +0.02 and every later one +0.04.
    - It resets on a successful great breakthrough, and nothing else resets it (not time,
      not a stage loss). #23's extra roll counts as a pill attempt: it carries the step's
      insight, and its failure adds insight. Bare attempts neither use nor add it.
    - It is a breakdown line ("failure insight +0.02, 1 failed pill attempt") and is saved
      with the character. It sits outside the q-extras ceiling (Formulas C), because its
      own cap bounds it. `pill_chance` was lowered so the baseline means stay at 0.30.
11. **Retries.** There is no cap on pill attempts (user decision, 2026-11-03). They are limited
    by the pill each pill attempt burns (pills are scarce: herbs must age, brewing can
    fail, the market rarely stocks them), the realm's condition, the time to refill the
    bar, the heart demon building toward 90 (it decays slowly between attempts), and
    lifespan. Bare attempts burn no pill but take the full failure penalties of rule
    10, so spamming them is dangerous; they almost never succeed. Bare attempts are also
    capped: at most `bare_attempt_cap` (3, user decision 2026-11-03) per realm step. The
    count resets on a successful breakthrough, never on time and never on a stage loss (capability #5; user decision 2026-11-03). Waiting out the heart demon
    decay (about 15 years per failure) would otherwise allow dozens of bare attempts over a
    long realm lifespan and break the 0.30 / 0.70 targets. Once the cap is used, a bare
    attempt is refused (the preview says "bare attempts used up"); pill attempts are
    unaffected. #23's extra roll is not a bare attempt and is not counted.

**The world and the top**

12. **NPCs.** NPCs carry a realm and a stage and advance abstractly: each season the world
    tick moves an NPC up one stage with chance 1 ÷ `npc_cultivation_seasons_per_stage` (12, `world_generation.json`, as built); they do not run the
    bar. An NPC's level is the first level of its stage. At the bottleneck its fate is
    rolled once per realm with p_step = base_step + min(e, 1) × (max_step − base_step),
    0.30 to 0.70 (Progression Edges owns e): if fated, it breaks through with chance
    `fated_breakthrough_per_season` (0.08, `character_edges.json`, as built) each season,
    about 12 seasons on average; otherwise it stays until death.
13. **Realm effects.** The realm, not the level, sets: the lifespan cap, the base
    cultivation rate, the stat bases, the cultivation technique tier cap (a technique
    beyond its maximum realm works at ×0.25, never below the crude floor; Cultivation
    Techniques Formulas A owns `tech`), event and reward budgets (Pillar 2), pill and
    item gating, and price tiers. The level matters for points and the stage multiplier
    only.
14. **Lifespan.** The cap is (the realm's base lifespan + the lifespan bonus) × (1 +
    lifespan_pct ÷ 100). The lifespan bonus is Character Stats' ceilinged total (its rule
    14 and Formulas I): lifespan pill years plus every `lifespan_years` (including an
    equipped treasure's, counted once), at most 15 % of the realm's base lifespan. A
    negative bonus is allowed and can put the cap below the base. At age ≥ cap the character dies of old age.
    (Changed 2026-11-04, cross-GDD review B1: the built formula has no ceiling.)
    - **Clamped bonus is kept** (user decision 2026-11-04). The ceiling is applied to the
      stored total each season, against the current realm. Bonus above the ceiling counts
      again when a great breakthrough raises it. Before the player uses a lifespan pill
      or treasure whose years would all sit above the ceiling, the Advisor warns that
      they will not count until a later realm.
    - **A change that would end the life needs confirmation** (user decision 2026-11-04,
      cross-GDD review NG4). Technique and treasure lifespan counts only while slotted or
      equipped (Cultivation Techniques rule 12). If a slot, equipment or main-method
      change would put the cap at or below the character's age, the change preview names
      the result ("your lifespan falls to 120; you are 130: you will die of old age") and
      the player must confirm. Declining leaves everything unchanged. A confirmed change
      kills at once, before the season's cultivation.
15. **The top.** At level 300 there is no next realm, so there is no bottleneck and the
    bar stops. What lies beyond Deity Transformation is deferred (the same open question as
    in the Meridian Map GDD).

**Capability hooks hosted here** (catalogue in the Meridian Map GDD)

16. **#9 Great Essence-Draining Art (Hấp Tinh Đại Pháp):** defeating a cultivator adds
    cultivation base equal to 5 % of the total cost of the current stage. Combat reports
    the defeat, and the heart demon +2 goes through Character Stats.
17. **#22 Last Radiance (Hồi Quang Phản Chiếu):** with under 5 years of lifespan left, one
    pill attempt per realm uses the raised chance q_desp (the Meridian Map GDD, Formulas E2).
18. **#23 Burning Life to Break Through (Thiêu Thọ Phá Cảnh):** after a failed pill attempt, once
    per realm, the character may burn burn_cost years (the greater of 10 and 5 % of the
    realm's lifespan) to roll one extra attempt at q_retry at once, with no new pill and no
    bar refill. The extra roll resolves in the same season as the failed attempt (user
    decision 2026-11-03) and is the one exception to "attempt only with a full bar". It is
    not offered if the remaining lifespan is not greater than burn_cost.
    It follows only a failed pill attempt, never a failed bare attempt (so S_guard and q_retry
    are always defined), and the extra roll inherits that attempt's condition result: the
    condition is checked once, at the start of the attempt, and the failure's own heart demon
    gain does not void it (user decision 2026-11-03).
    Burning adds burn_cost to the character's age at once. It is not a lifespan bonus, so
    the lifespan ceiling cannot absorb it (user decision 2026-11-04, cross-GDD review W-C).
    At most one of #22 and #23 acts per realm step.
    The extra roll counts as a pill attempt for failure insight (rule 10): its chance
    includes the step's insight, including the +0.02 the failed attempt just added, and
    its failure adds insight to later attempts. The Meridian Map's E2 counts that later
    insight in its guard: q_retry = min(q, (δ_max − ι) ÷ (1 − S)), where ι is the insight
    the roll's failure would add (0.02, or 0 at the cap), so the lift stays at δ_max
    (user decision 2026-11-04; Formulas H, Open Question 17).

**What the player cannot do:** skip a bottleneck or buy past it; attempt before the bar is
full (the only exception is #23's same-season extra roll); make more than
`bare_attempt_cap` bare attempts in one realm step; raise the level except through cultivation base (or an event or item that grants
it); lose points through a failure; raise innate talents by climbing; use #22 and #23 on
the same realm step.

### States and Transitions

Small breakthroughs are events inside Climbing, not states.

| State | Becomes | When | Guard |
|---|---|---|---|
| Climbing | Climbing (level +1) | The bar reaches the level's cost | Level below the realm's last level |
| Climbing | At great perfection | The level reaches the realm's last level | The realm has a next realm |
| Climbing | Capped | The level reaches 300 | Deity Transformation |
| At great perfection | At the bottleneck | The bottleneck bar is full | — |
| At the bottleneck | Attempting | The player attempts (an NPC rolls its fate) | Bar full |
| Attempting | Climbing (next realm, early stage) | The roll succeeds | — |
| Attempting | At great perfection (bar refilling) | The roll fails | No fatal qi deviation; bar down 30 % |
| Attempting | Dead | Qi deviation with heart demon at 90 or more | — |
| Attempting | Attempting (#23 extra roll) | A pill attempt failed, #23 is held and unused this realm step, and remaining lifespan exceeds burn_cost | Same season; no bar refill; not combined with #22 on the step. Success and failure resolve as above |
| Attempting | Tribulation | The roll succeeds on the Deity Transformation breakthrough | Owned by Heavenly Tribulation; until it is designed, success stands and `breakthrough_succeeded` fires on the roll |
| Tribulation | Climbing (Deity Transformation, early stage) or Dead | The tribulation resolves | Heavenly Tribulation GDD; `breakthrough_succeeded` fires on survival |
| Any | Dead | Age reaches the lifespan cap, including a confirmed change that lowers the cap to the age or below (rule 14) | Old age |

### Interactions with Other Systems

Character Stats (`character-stats.md`), Spiritual Roots (`linh-can.md`), Cultivation
Techniques (`cong-phap.md`) and the Meridian Map have GDDs. Time & Turn, Item DB and the other systems below have none yet, so their
interfaces are provisional.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Character Stats | out / in | out: realm, level, stage multiplier (bases for spiritual power, divine sense, vitality, the combat power realm term); in: comprehension, Dao heart, and the stat sheet's `breakthrough_chance` | Character Stats (stat keys, units); this GDD (the ladder) |
| Spiritual Roots (Linh Căn) | in / out | in: base element count (mutations excluded) and the curve factor, looked up by realm and stage. Out: the `breakthrough_succeeded` event (player only, rule 9), which triggers Mutation Awakening (its rule 9; capability #24) | Spiritual Roots (the curve, the roll); this GDD (the event) |
| Time & Turn | in / out | in: seasons, age, death by old age; out: the bottleneck state and the ripening year of the next brew, for a one-click "retreat until ripe" (cross-GDD review 04g, F2; Open Question 18) | Time & Turn |
| Item DB | in | breakthrough pills (the realm's entry pill tag and quality), breakthrough talismans (consumed) | Item DB |
| Meridian Map (Kinh Mạch Đồ) | out | `level_gained`, `stage_reached` and `breakthrough_succeeded` events, and the ladder constants (bands, `great_breakthrough_bonus`, `pct_trung` / `pct_hau` / `pct_dai`), which this GDD owns | Meridian Map (point arithmetic); this GDD (the ladder and its constants) |
| Cultivation Techniques (Công Pháp) | in / out | in: technique speed in the rate; out: the realm for the tier cap | Cultivation Techniques |
| Progression Edges | in | perks, talismans and fortuitous encounters as attempt bonuses; the NPC edge score e | Progression Edges (the edges); this GDD (where they plug in) |
| Event Engine | out / in | out: the bottleneck flag (raises event chance and unlocks protagonist-only templates), realm-keyed budgets; in: events that grant cultivation base | Event Engine |
| Combat | out | the realm term of combat power, defeats reported for #9 | Combat |
| Heavenly Tribulation (Thiên Kiếp, not started) | out | hand-off after a successful Deity Transformation roll (rule 7) | Heavenly Tribulation GDD |
| Travel & Map | in | the place's spiritual qi density (spirit veins) for the Core Formation condition | Travel & Map |
| Formations (Trận Pháp) | in | a gathering formation's density bonus, which counts toward the Core Formation condition | Formations |
| Event Engine (insight) | in | the Deity Transformation breakthrough insight, granted by an enlightenment event | Event Engine (the event); this GDD (the condition) |
| Living World Tick / NPC Builds | out / in | NPC realm and stage, fate roll | Living World Tick |
| Market | out | realm price tiers, breakthrough pill stock | Market |
| Guidance Layer / Debug Terminal / Game UI | out | bottleneck state, the attempt chance breakdown, goals | Guidance Layer |
| Save/Load | out | level, bar, bottleneck state, bare attempts used this realm step, the failure insight count, the flag "talisman used this breakthrough", per-realm capability use | Save/Load |

## Formulas

Proposed with `systems-designer` and `economy-designer` (2026-11-03). Values marked
*guess* need a bot run (`tools/balance/autoplay.gd`, `tools/balance/npc_cohort.gd`)
before they are trusted. Realm abbreviations: QR = Qi Refining (Luyện Khí), FE =
Foundation Establishment (Trúc Cơ), CF = Core Formation (Kết Đan), NS = Nascent Soul
(Nguyên Anh), DT = Deity Transformation (Hóa Thần).

### A. Level cost

The level_cost formula is defined as:

`cost(L) = c0 · r^(L − lo)` for lo ≤ L ≤ hi − 1 ; `M = hi − lo` ; `r = g^(1/(M − 1))` ; `c0 = T_c · (r − 1) / (r^M − 1)` ; `bar = b · cost(hi − 1)`

cost(L) is the cultivation base (tu vi) needed to go from level L to L + 1. The bar is
the bottleneck bar at level hi; it exists only if the realm has a next realm.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | lo..hi−1 | calculated | Level being climbed |
| lo, hi | int | the realm bands | data file (`levels`) | First and last level of the realm |
| M | int | 38, 39, 49, 69, 100 | calculated | Climbing costs in the realm |
| T_c | float | 1,025 / 5,600 / 42,000 / 276,000 / 1,850,000 | data file (`climb_total`) | Sum of the realm's climbing costs (user decision: built totals rescaled ×1 / ×2 / ×3 / ×4 / ×5) |
| g | float | 6 / 3 / 3 / 3 / 3 | data file (`climb_growth`) | Last level's cost ÷ first level's cost |
| b | float | 4 / 10 / 10 / 10 / none | data file (`bar_mult`) | Bottleneck bar as a multiple of the last climbing cost |
| r, c0 | float | > 0 | calculated | Growth per level and the first level's cost |

**Output Range:** costs are always positive and sum exactly to T_c.

| Realm | First level | Middle (level) | Last climbing level | Bottleneck bar | Realm total |
|---|---|---|---|---|---|
| QR | 9.6 | 24.1 (20) | 57.6 | 230 | 1,255 |
| FE | 78.7 | 136.3 (59) | 236.0 | 2,360 | 7,960 |
| CF | 469.9 | 813.8 (104) | 1,409.6 | 14,096 | 56,096 |
| NS | 2,194 | 3,800 (164) | 6,582 | 65,821 | 341,821 |
| DT | 10,152 | 17,680 (250) | 30,456 | none | 1,850,000 |

- **Pacing.** With a 3-element root and other rate factors at 1.25 (a planning guess; at the
  roll mean, Formulas I gives comprehension 1.225 × technique 0.91–0.98, about 1.1–1.2), the first level
  of every realm takes about 3 seasons, so a point comes every few seasons early.
- **Years per realm** (climb plus the first bar fill, guess):

  | Root | QR | FE | CF | NS | DT |
  |---|---|---|---|---|---|
  | 1 element | 25 | 64 | 187 | 456 | 925 |
  | 3 elements | 38 | 50 | 60 | 101 | 168 |
  | 5 elements | 58 | 80 | 91 | 76 | 103 |
  | Lifespan cap | 120 | 200 | 500 | 1,000 | 2,000 |

  Corrected 2026-11-04 from the Spiritual Roots GDD (Formulas B), which recomputed these
  from the element-count curve: the 5-element DT figure was 137. Values exclude the
  generating-pair bonus (with it, 5 elements at DT is 89 years). The 1.25 rate factor is
  a guess; that GDD's tight timing spots depend on it (its Open Question 2).
  The Cultivation Techniques GDD (Formulas A) normalises a typical technique to 1.0.
  Its strongest-element starter would make multi-element roots climb about 24 % faster
  than this table, so it divides that gain out per element count (`count_gain`), and
  every element count meets this table on average (user decision 2026-11-04,
  cross-GDD review N6). `climb_total` is not the lever: one global value cannot fix a
  gap that depends on the element count without slowing single roots.

  Without the rescale a 3-element root would take 20–38 years per realm, only 2–4 % of
  the lifespan after QR.
- **Refills.** A failure (30 % of the bar) takes about 7.4 / 12.6 / 14.5 / 23.4 seasons to
  refill at the four bottlenecks (guess).

**Example:** FE level 60.
- r = 3^(1/38) = 1.02933 and c0 = 78.7.
- cost(60) = 78.7 × 1.02933^20 = **140.3** cultivation base.
- At a rate of 25 × 1.0 × 1.25 = 31.25 per season, that is 4.5 seasons.

### B. Stage multiplier

The stage_multiplier formula is defined as:

`stage_mult(L) = 1 + stage_power_step · s(L)` ; `s(L) = [L ≥ t] + [L ≥ h] + [L ≥ hi]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s | int | 0–3 | calculated | Small breakthroughs reached in the current realm |
| t, h, hi | int | per realm | calculated (rule 2) | First levels of the middle stage, late stage and great perfection |
| stage_power_step | float | 0.15 | data file | Rise per small breakthrough (user decision) |
| stage_mult | float | 1.00–1.45 | calculated | Multiplier on spiritual power, divine sense, vitality and the combat power realm term |

**Output Range:** 1.00 / 1.15 / 1.30 / 1.45 through a realm, back to 1.00 on the next
realm's bases. The great breakthrough is always the bigger jump:

| Stat | Realm base ratio | Jump at the great breakthrough (next base ÷ 1.45) |
|---|---|---|
| Combat power | ×10.0 | ×6.9 |
| Spiritual power | ×7.5–8.3 | ×5.2–5.7 |
| Vitality | ×3.0–4.0 | ×2.1–2.8 |
| Divine sense | ×3.0–3.3 | ×2.1–2.3 |

At a step of 0.30 the divine sense jump (×1.6) would be smaller than the realm's own
small-breakthrough ladder (×1.9).

**Example:** CF level 113 (late stage): stage_mult = 1.30. At level 129 (great
perfection), the combat power realm term is 10,000 × 1.45 = 14,500. At NS level 130 it
is 100,000, a ×6.9 jump.

### C. Attempt chance

The attempt_chance formula is defined as:

`q_pill = clamp(p_pill + min(k_q·rank + k_n·ngo + k_d·dao + q_tree + q_event, X_q) + q_destiny + ι_j + τ·[talisman], q_min, q_max)` ; `ι_j = min(j · ι_pp, ι_cap)` ; `q_bare = p_bare`

A pill attempt needs the pill to be held and the realm condition met (rule 7). Every
other attempt is bare: it uses p_bare alone and burns nothing. j counts the failed pill
attempts made earlier in the realm step, #23's extra roll included (rule 10).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_pill | float | 0.04 / 0.045 / 0.02 / 0.0225 | data file (`entry_requirement.pill_chance`) | Entry pill chance at QR→FE, FE→CF, CF→NS, NS→DT (**change** 2026-11-04, after cross-GDD review 04g: lowered from 0.06 at every gate to pay for failure insight, and further at CF→NS and NS→DT for the shorter, more numerous herbs; Formulas D–E) |
| p_bare | float | 0.004 / 0.0037 / 0.0037 / 0.003 | data file (`entry_requirement.base_chance`) | Bare chance, the only term of a bare attempt; not clamped |
| k_q·rank | float | 0–0.075 | data file | Pill quality, 0.015 per grade |
| k_n·ngo | float | 0–0.075 | data file | Comprehension (ngộ tính), 0.0005 per point; pill attempts only |
| k_d·dao | float | 0–0.025 | data file | Dao heart (đạo tâm), 0.00025 per point; pill attempts only |
| q_tree | float | 0–0.08 | calculated (Meridian Map) | The tree's breakthrough chance, capped by the Meridian Map's `tree_breakthrough_cap` (8 pp) and then counted under X_q |
| q_event | float | 0+ | calculated | Item and event bonuses (fortuitous encounters), counted under X_q |
| X_q | float | 0.10 | data file (`breakthrough.q_extras_ceiling_pp`, 10) | Character-wide ceiling on the summed q extras (**new** 2026-11-04, cross-GDD review 04g, F14). Sized in the entry-age model so a fully built life with no edge stays at or below about 0.55 per gate (Formulas E) |
| q_destiny | float | 0–0.30 | calculated | Destiny-perk (thiên mệnh) bonuses, e.g. Đạo Cốt +0.12. Outside X_q: they are the edge |
| ι_j | float | 0–0.04 | calculated (rule 10) | Failure insight on the step's pill attempt after j failed ones. Outside X_q; bounded by its own cap |
| ι_pp, ι_cap | float | 0.02, 0.04 | data file (`breakthrough.failure_insight_pp` 2, `breakthrough.failure_insight_cap` 4, in percentage points) | Insight per failed pill attempt, and its cap (**new** 2026-11-04, 04g F13) |
| τ | float | 0.05 | data file (`crafting_talismans.json`) | Breakthrough talisman (Phá Cảnh Phù), on at most one pill attempt per realm step (rule 8). Outside X_q. **Change** 2026-11-04: one per realm step (04f; was one per attempt), and 0.05 (eighth pass; was 0.10) |
| q_min, q_max | float | 0.01, 0.95 | data file | Clamp on pill attempts |

**Output Range:** pill attempts 0.01–0.95, in practice from about 0.08; bare attempts
0.003–0.004. The breakdown names the kind of attempt and shows whether the condition is
met (Pillar 2). When the q extras exceed X_q, the breakdown lists each and then a clamp
line ("q extras 0.1225, ceiling 0.10").

Typical values, with pill rank 1, comprehension 40, Dao heart 30 and tree 0.02, so the
extras E = 0.0625 (guess; under X_q):

| | QR→FE | FE→CF | CF→NS | NS→DT |
|---|---|---|---|---|
| Baseline q_pill, first pill attempt of the step | 0.1025 | 0.1075 | 0.0825 | 0.085 |
| After one failed pill attempt / two or more | +0.02 / +0.04 | +0.02 / +0.04 | +0.02 / +0.04 | +0.02 / +0.04 |
| Edge q_pill (Đạo Cốt perk), first attempt | 0.2225 | 0.2275 | 0.2025 | 0.205 |
| With the realm step's one talisman, on that attempt | +0.05 | +0.05 | +0.05 | +0.05 |

- **Every gate has the same shape** (user decision 2026-11-04, cross-GDD review 04f):
  a pill is a low-odds roll, and a life brews about three pills per realm at the median
  (Formulas D). The baseline is set by these odds, not by rationing pills. Rationing
  left root-free lives with one pill, or none if they entered the realm late. The two
  later gates have the lower `pill_chance` because their herbs are shorter and a recipe
  needs four of them (Formulas D; cross-GDD review 04g, F2).
- **Failure insight** (rule 10) makes a failure count for something: a life's second and
  third pills are 2 and 4 points better than its first. It adds about +0.04 to +0.05 to a
  gate's mean, and `pill_chance` was lowered to match (Formulas E).
- **The talisman is not in the baseline.** At these odds a 5 pp talisman on every attempt
  would raise a gate's mean from 0.30 to about 0.40. So a realm step allows one, which
  adds about +0.04 to the mean (0.30 → 0.34; Formulas E). It is a crafted build bonus, and
  AC-CG-60's ceiling run includes it.
- **The q-extras ceiling** (user decision 2026-11-04, cross-GDD review 04g, F14; answers
  Open Question 13). Pill quality, comprehension, Dao heart, the tree and item and event
  bonuses add up to 0.255 or more at their maxima, against E 0.0625 typical. Uncapped, a
  life maxing them reached q ≈ 0.30 and a gate's mean of 0.62–0.65 before any other build;
  with the bonus ceilings and the talisman, 0.76–0.81 without an edge. X_q = 0.10 holds
  that fully built life to 0.52–0.55 (Formulas E). Đạo Cốt and other destiny perks stay
  outside it, so the edge stays distinct; the talisman and failure insight are outside
  it too, because each has its own bound. A tree at its 8 pp on an otherwise typical life
  now gives 0.37–0.39 (was 0.42): past about 5.75 pp of tree chance, the ceiling binds.

**Example:** FE→CF baseline, first pill attempt: 0.045 + 0.015 + 0.020 + 0.0075 + 0.02 =
**0.1075**; the next pill attempt, after it fails, is 0.1275.

### D. Pill supply

The pill_supply formula is defined as:

`B = the number of brews k = 1, 2, … that count` ; brew k counts if `A_k ≤ cap − 0.25`, where `A_1 = max(e + T_1, e + Y_climb)` and `A_k = max(e + T_k, A_(k−1) + r)` ; `T_k = C_k / h` ; `C_k = min { c : the herbs of k recipes fit in n_plots plots of c herb-years each }`

`W = cap − e` ; `n_plots = clamp(3 + ⌊0.04 · purity_earth⌋ + field_plots, 1, 12)` ; `h = (1 + 0.008 · purity_wood) · (1 + herb_age_root_pct / 100) · max(0, 1 + herb_growth_pct / 100)` ; `p_brew = clamp(p_brew0 + 0.0025 · purity_fire + alchemy_success / 100, 0.05, 0.95)`

**Pills are whole** (changed 2026-11-04, cross-GDD review 04f, B2). A herb ripens only at
its `min_age`, and a pill needs every herb of its recipe. So supply is a count of brews per
realm step, not an average:
- Each brew succeeds with chance p_brew. A failed brew burns its herbs.
- The expected number of pills is p_brew · B, plus pills bought and gifted.
- The linear λ used before 04f treated herb age as divisible. It broke twice: when a herb
  could not ripen in the realm (cross-GDD review F1), and again when a recipe needed more
  herbs than the plots could ripen (04f B2).

**Timing: a brew counts only if its attempt fits in the life** (eighth-pass review
2026-11-04).
- **Ripening.** A plot grows herbs one after another, so in T years it ripens herbs whose
  `min_age` sum to at most ⌊h · T⌋. C_k is the smallest such capacity that holds k
  recipes (exact packing), and T_k = C_k ÷ h is the first year after entry at which k
  recipes can be ripe.
- **Attempts.** An attempt needs a full bar, so the first one waits for the climb (Y_climb)
  and each later one waits r years for the bar to refill after a failure.
- **The counting rule.** Brew k counts if, even when every earlier brew made a pill that
  failed, its attempt could start at least one season before the lifespan cap. This
  undercounts slightly, because a failed brew frees its attempt slot, but it keeps B a
  single number the Advisor can show.
- **If h = 0** (herb growth at −100 % or below), no herb ripens: T_k = ∞ and B = 0. No
  division is performed (cross-GDD review 04g, S1).

The Advisor computes B and shows it ("3 brews possible this realm, 21 %"), so the plan is
readable before the first seed goes in (Pillar 2). A plot may grow different herbs in
turn, for example two ginseng and then two companion herbs.

**B_remaining (Advisor).** Mid-realm, the Advisor recomputes from the current plot state
(the herbs in the ground and their ages, the empty plots) and the years left: the brews
the plots can still finish under the counting rule. It shows B_remaining, the pills held
and the chance of brewing no pill, (1 − p_brew)^B_remaining.

The spiritual root enters through all three terms (added 2026-11-04, cross-GDD review D1):
- Earth adds plots and Wood speeds herbs (Character Stats, Formulas G). The Time (Thời
  Gian) mutation adds a herb-aging root factor, ×1.25 (added 2026-11-04).
- Fire raises brew success (Alchemy, as built: +0.25 percentage points per purity point).
- An absent element has purity 0.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| B | int | 0+ | calculated | Brews that count in the realm step (the counting rule) |
| e | float | years | calculated | Age at the realm's entry; 16 at Qi Refining (guess) |
| cap | float | years | calculated (rule 14) | The realm's lifespan cap at entry: 120 / 200 / 500 / 1,000 at baseline, raised by the lifespan bonus |
| W | float | years | calculated | Growing years: `cap − e`. The calibration takes it from the entry-age model below: QR→FE 104 for every life; FE→CF 94 / 116 / 144, CF→NS 310 / 342 / 382, NS→DT 540 / 645 / 767 (10th / 50th / 90th percentile of the lives that reach the gate; recomputed after 04g) |
| Y_climb | float | years | calculated (Spiritual Roots Formulas B) | Years to clear the realm, including the first bar fill, by base element count: QR 25 / 33 / 36 / 43 / 50, FE 64 / 52 / 48 / 57 / 69, CF 187 / 71 / 58 / 55 / 79, NS 456 / 128 / 97 / 84 / 66 |
| r | float | years | calculated (Formulas A) | Gap between attempts: the refill time (7.4 / 12.6 / 14.5 / 23.4 seasons for a 3-element root, scaled by the root's Y_climb ÷ the 3-element Y_climb; guess) plus the attempt's season |
| C_k, T_k | int, float | herb-years, years | calculated | Plot capacity that holds k recipes, and the year after entry it is reached |
| n_plots | int | 1–12 | calculated (Character Stats, Formulas G) | Spirit field plots: base 3, +1 per 25 Earth purity, plus `field_plots` |
| h | float | 0 or above (0 when `herb_growth_pct` ≤ −100) | calculated (Character Stats, Formulas G) | Herb growth factor from Wood purity, `herb_age_root_pct` and `herb_growth_pct`. At h = 0 no herb ripens: T_k = ∞ and B = 0 |
| herb_age_root_pct | float | 0 or 25 | calculated (Character Stats, Formulas G; Spiritual Roots) | Time's herb-aging root factor: 25 for a character holding the Time (Thời Gian) mutation, else 0. A root term like Wood's: set by the mutation, not a sheet modifier, and not under the herb growth ceiling (added 2026-11-04) |
| p_brew0 | float | 0.05–0.95 | calculated (Alchemy) | Brew success without Fire: about 0.65 for the FE pill, 0.64 for the CF pill, 0.65 for the NS and DT pills (guess) |
| p_brew | float | 0.05–0.95 | calculated (Alchemy) | Brew success with Fire purity and `alchemy_success` |
| herb_growth_pct, alchemy_success | float | at most 10, at most 3 pp; negative totals allowed (h floors at 0) | calculated (Character Stats, rule 14 ceilings) | Character-wide totals from every Character Stats rule 12 source. Penalties apply after the cap: total = min(Σ positive, ceiling) + Σ negative. `alchemy_success` adds percentage points to brew success (user decision 2026-11-04) |
| purity_earth, purity_wood, purity_fire | int | 0, 10–100 | calculated (Spiritual Roots) | 0 when the element is absent |
| recipe | list | (min_age, qty) per herb | data file (Item DB) | FE pill: 2 ginseng at 40 + 1 companion at 10. CF pill: 2 Kim Tủy Quả at 42 + 1 Xích Huyết Đằng at 18. NS pill: 4 at 60 + 1 at 10 (new recipe, guess). DT pill: 4 at 100 + 1 at 80 (new recipe, guess). **Change** 2026-11-04 (after cross-GDD review 04g, F2: the NS and DT herbs shortened toward the 3-element climbs and doubled in number; the eighth pass had 2 × 130 + 40 and 2 × 230 + 80, and 04f 2 × 50 + 20, 2 × 100 + 40 and 2 × 200 + 80) |
| Y | float | plot-years | calculated | Σ qty · min_age: 90 / 102 / 250 / 480. A summary of a recipe's size only; B is the rule |
| M_market | float | 0+ | calculated (Market) | Pills bought; about 0 at baseline (a pill is stocked about 1 restock in 10 and costs 11–15 years of missions). A bought pill enters Formulas E like a gift pill |
| G | float | 0–2 | calculated | Pills gifted by fortuitous encounters (cơ duyên); they skip growing and brewing. In the calibration G is an expectation, so it may be fractional |

**Output Range:** B from 0 upward. A root-free life brews 3 at the median W of every gate,
and at the 10th percentile 3 everywhere except FE→CF (2); Earth, Wood and growth bonuses
add brews in steps.

**Example:** FE→CF, root-free, a 3-element root entering at 80 (W 120).
- C_k is 42 / 84 / 102 / 144: one plot each of Kim Tủy Quả, Kim Tủy Quả and the companion
  for the first recipe; then two Kim Tủy Quả in each of two plots and two companions in
  the third; then two Kim Tủy Quả and a companion in every plot (102 of 102).
- The climb takes 48 years and r = 12.6 ÷ 4 + 0.25 = 3.4 years. The attempts could start
  at 128, 164 and 182, all before 199.75, and the fourth recipe does not ripen by the
  cap. So **B = 3**.
- With p_brew 0.64 the life expects 1.92 pills, and fails to brew any with chance 0.36³ =
  **0.047**.
- For the root {Wood 40, Fire 86, Water 10}: h = 1.32, so T_4 = 144 ÷ 1.32 = 109 years and
  B = 4; p_brew = 0.64 + 0.215 = 0.855.

**The entry-age model** (eighth-pass review 2026-11-04). W depends on when a life entered
the realm, so the calibration derives it instead of guessing one value per gate. A
fixed-seed simulation of 20,000 lives per element count (purities by Spiritual Roots
Formulas A) follows each life through the four gates. Its assumptions:
- every life enters Qi Refining at age 16 (guess);
- the climb takes Y_climb by base element count, from Spiritual Roots Formulas B (whose
  rate factor of 1.25 is itself a guess);
- the baseline lifespan caps are the base lifespans, 120 / 200 / 500 / 1,000;
- breakthrough herbs are plantable from the realm's entry, not earlier (the rule below);
- plots are planted at best play, and brew k is ready at e + T_k (brewing takes no time).
  This is the earliest any planting order allows. Where no single order reaches every
  T_k, the model runs some years ahead of the bot (guess);
- each attempt happens at the later of the climb's end, the pill being ready, and the
  previous attempt plus r;
- each pill attempt succeeds with chance q plus the step's failure insight (rule 10), gift
  pills first;
- a life crosses at its first success, and that season's end is its entry age in the
  next realm;
- a life that fails every attempt never reaches the next gate. Per-root S at a gate uses
  that root's entry-age distribution given it reached the gate. The target stays the
  mean over the birth mix (per-root S weighted by birth probability).

Means are stable to ±0.002 across seeds. The model is a scratch script, not a bot run;
AC-CG-30 replaces it.

**Breakthrough herbs are plantable from the realm's entry, not earlier.** A gate's main
herb unlocks when the character enters the realm whose bottleneck it serves: ginseng in
Qi Refining, Kim Tủy Quả in Foundation Establishment (`seed_rarity_max` 4 from FE; user
decision), the NS pill's herb in Core Formation and the DT pill's herb in Nascent Soul. So
no life can grow the next pill's herbs a realm early, and W starts at entry.

**The brew guarantee** (revised 2026-11-04, eighth pass). A root-free life (3 plots, h 1)
must brew at least 2 pills at the gate's 10th-percentile W and 3 at its median W, by exact
packing.
- At W 104 / 94 / 310 / 540 and 104 / 116 / 342 / 645 this bounds the main herb's
  `min_age` (companion as reciped) at **47 / 46 / 82 / 141** years, at qty 2 / 2 / 4 / 4.
  The recipes (40 / 42 / 60 / 100) are inside it. (The eighth pass's 152 and 269 were at
  qty 2.)
- At the 1st percentile (W 104 / 82 / 302 / 505) a root-free life still brews 3 / 1 / 3 /
  3.
- It keeps a life that entered the realm late off the zero-pill cliff. This is the rule
  each new recipe is checked against, including the NS and DT recipes (Open Question 4).

**Years at a full bar** (user decision 2026-11-04, cross-GDD review 04g, F2, accepted as
partial). A life whose bar is full waits for its herbs, and its levels, tree points and
technique mastery stall.
- For a root-free 3-element life at the median W, the years at a full bar up to the
  third attempt are 50 / 47 / 184 / 371: 48 / 41 / **54 / 57 %** of W. The NS and DT
  herbs were shortened toward the climbs (58 and 97 years) and doubled in number, which
  cut the two later gates from 234 and 431 years (68 and 67 %).
- Shorter herbs alone cannot cut the wait while B stays 3 at the median: the third recipe
  then ripens after about three quarters of W, whatever the herb length. A fourth brew at
  the median would cut it, but the odds cannot pay for one (`pill_chance` would fall to
  0 or below).
- So the rest of the wait stays, and it must cost no attention: Time & Turn owes a
  one-click "retreat until ripe" that advances seasons at the bottleneck until the next
  brew is ready or something needs the player (Interactions; Open Question 18).

**Plot policy: the targets assume best play** (user decision 2026-11-04, cross-GDD review
04f, B3).
- The player decides which herb goes in which plot. At a full bar the bottleneck wastes
  cultivation base (rule 7), so giving plots to the breakthrough recipe costs almost
  nothing there, and players will do it.
- So the targets are calibrated on a life that puts as many plots into the recipe as
  raise B. A life that plants fewer lands below 0.30, and the Advisor shows what it is
  giving up.
- **The targets assume no extra plots** (user decision 2026-11-04). The 0.30 / 0.70
  targets and `bonus_ceiling_target` 0.45 are set on a life with `field_plots` 0, so
  base 3 plus Earth's plots. Extra plots from any source (the Spirit Farming mutation,
  Tổ Truyền Linh Điền and other perks, items, Spirit Fields) are a deliberate build lever
  that can beat those odds. Pillar 3 applies: power is built. The tree gives no plots at
  its launch values (user decision 2026-11-04, cross-GDD review 04g, F11).
- **Plant order (bot rule).** At the realm's entry the bot plants the packing that
  achieves B at its W, and staggers each plot's herb order so every recipe completes as
  early as the plots allow. In the FE→CF example below the three plots grow K-K-C, K-C-K
  and C-K-K (K Kim Tủy Quả, C the companion), which completes recipes at 42, 84 and 102,
  exactly T_1 to T_3. After a failed brew the bot keeps the same plan.
- **The Advisor's plant plan** (user decision 2026-11-04, cross-GDD review 04g, F16).
  Order matters: at FE→CF's 10th-percentile W of 94 the staggered layout brews 2, but
  K-K-C in every plot brews 0 (no companion ripens) and C-K-K in every plot brews 1. So
  the Advisor offers a one-click plant plan: the bot's layout (best B at the current W,
  staggered), with its B and S shown before any seed goes in. A manual layout is scored
  the same way; if its B is below the plan's, the Advisor warns before sowing ("this
  layout brews 0; the plan brews 2, 14 %"). The calibration's best play is the plan, so a
  player who takes it gets the targets.
- **Diên Thọ Đan.** The bot does not grow the lifespan pill at gates, so it never takes
  plots from the breakthrough recipe (Open Question 14).

**Calibration loadout and bonus ceilings** (user decisions 2026-11-04, cross-GDD reviews G1
and 04f).
- **The hand values carry no bonuses.** The 0.30 / 0.70 targets are hand-calibrated at
  best plot play with no bonuses, and Formulas E's table gives those values.
- **The bot sets the final value.** It plays the typical loadout: Cultivation Techniques'
  AC-CP-46 policy, plus two auxiliary arts drawn as par-tier Market commons (`root_bias`
  0.6) with their rolled bonuses, plus the tree as the bot allocates it, taking no plot
  node (cross-GDD review 04g, F11). AC-CG-30 sets the final `pill_chance` on that loadout.
- **The ceilings were lowered.** Character Stats caps three totals character-wide (its
  rule 14 and Formulas I): `herb_growth_pct` at 10 and `alchemy_success` at 3 (**change**
  04f, was 40 and 8), and the lifespan bonus at 15 % of the realm's base lifespan.
- **What the ceilings achieve.** A life at all three ceilings that also uses the realm
  step's talisman (τ 0.05), at best plot play, with typical q extras and no edge, reaches
  **0.44 / 0.46 / 0.45 / 0.45** at the four gates in the entry-age model (recomputed after
  04g with failure insight; was 0.43 / 0.44 / 0.42 / 0.43). The lifespan bonus raises
  every cap, and that life's own earlier crossings raise W further. That is at
  `bonus_ceiling_target` 0.45, with FE→CF 0.009 over it, and is accepted inside
  AC-CG-60's ≤ 0.48 tolerance (user decision 2026-11-04); without the talisman it is
  0.40 / 0.42 / 0.41 / 0.41. Building into alchemy pays, up to a bound the player can see.
- **A fully built life.** With every q extra at its maximum as well, the q-extras ceiling
  (Formulas C) holds it to 0.52 / 0.54 / 0.55 / 0.54 (uncapped it was 0.76–0.81).
- **Fields are a build, outside the ceiling target** (user decision 2026-11-04).
  `field_plots` is outside Character Stats' ceilings, bounded only by `max_plots` 12,
  and `bonus_ceiling_target` covers lives without extra plots. A field build can beat
  it, by design: on top of the ceiling run, +1 plot gives 0.52 / 0.55 / 0.55 / 0.54 and
  +2 give 0.61–0.63. At 12 plots the run gives 0.78–0.88, and a life with 12 plots and
  no other bonus 0.62–0.75. AC-CG-60 runs at `field_plots` 0 (Open Question 13, answered
  for fields), and the bot's calibration runs (AC-CG-30, AC-CG-60) take no plot node from
  the tree (cross-GDD review 04g, F11).
- **Root factors and craft-mutation holders are outside the target too** (user decisions
  2026-11-04, cross-GDD review 04g, C5 and F15).
  - `bonus_ceiling_target` covers lives with no root factor beyond Wood's purity: Time's
    herb-aging factor is excluded, and AC-CG-60 runs with Mutation Awakening off.
  - A craft mutation raises its holder's ceiling (Character Stats and Spiritual Roots
    define it). Pill Fire raises `alchemy_success` 3 → 6, Lava raises it 3 → 5, and
    Spirit Farming raises `herb_growth_pct` 10 → 20 and adds 2 `field_plots`. Raises do
    not stack: the highest applies.
  - On the ceiling run with `field_plots` 0, a Pill Fire holder reaches 0.45 / 0.47 / 0.46
    / 0.46, a Lava holder 0.45 / 0.47 / 0.46 / 0.46 and a Spirit Farming holder 0.46 /
    0.50 / 0.48 / 0.48; with Spirit Farming's two plots, 0.62 / 0.67 / 0.65 / 0.64 (a field
    build). Like root factors, holders sit outside the target.

**The Core Formation herb.**
- Kim Tủy Quả (rarity 4) becomes plantable from Foundation Establishment on, so the CF
  pill is a planned, decades-long project.
- The Diên Thọ Đan lifespan pill also needs one Kim Tủy Quả, so it competes for the same
  FE plots (cross-GDD review 04f, C6).
- A lifespan pill raises W and so can add a brew. The lifespan ceiling bounds that, but
  the bot does not plan it (Open Question 14).

**What the player can do about growth** (user decisions 2026-11-04). The herb growth
factor h gathers:
- **elemental affinity:** Wood purity (Character Stats Formulas G; a root term, not
  capped);
- **Time (Thời Gian):** a ×1.25 herb-aging root factor, outside the ceiling
  (`herb_age_root_pct` 25; Character Stats Formulas G). It is set by the mutation, not
  a sheet modifier;
- **items** (spirit field tools, fertilisers), **techniques** (auxiliary arts), **the
  tree** and **destiny perks**: `herb_growth_pct` modifiers;
- **root mutations:** Life and Spirit Farming grant `herb_growth_pct`, which counts under
  the ceiling; Time's old +100 % is dropped in the data pass (Spiritual Roots Open
  Question 1) (cross-GDD reviews 04f, B1, and 04g, C4);
- **knowledge:** Spirit Fields craft mastery (đạo nghệ) adds `herb_growth_pct` as a sheet
  modifier. Its curve belongs to Spirit Herbs & Spirit Fields (system 14, no GDD yet;
  Open Question 12).

**Growth pays in steps.** Everything except the root terms (Wood's purity and Time's
herb-aging factor) shares Character Stats' `herb_growth_pct` ceiling of 10. A plot ripens one more herb only when ⌊h · W⌋ crosses the next sum of
herb ages, so between steps extra growth is worth nothing. The Advisor names the next step
("+4 % herb growth: one more brew"). Pricing growth by steps rather than linearly is open
(cross-GDD review 04f, F7; Open Question 15).

**What Time's factor does** (entry-age model, recomputed 2026-11-04 after 04g). A
root-free life holding Time (h 1.25) brews one more pill at the median W of QR→FE and
FE→CF (3 → 4) and two more at CF→NS and NS→DT (3 → 5), where the shorter herbs let the
faster clock add steps. At the 10th-percentile W it brews 4 instead of 3 (QR→FE, CF→NS,
NS→DT) and 3 instead of 2 (FE→CF). Over the birth mix, a life that gains Time at Core
Formation goes from 0.30 to 0.38 at CF→NS and to 0.37 at NS→DT (a rare life holding it
from Qi Refining gains +0.07–0.09 at every gate). At the three ceilings with the talisman
it reaches 0.53 at CF→NS and NS→DT. Root factors are outside `bonus_ceiling_target` (user
decision 2026-11-04, cross-GDD review 04g, C5; the ceilings paragraph above). Time is an
order-4 mutation formed mostly by Awakening at Core Formation or later, and it is not in
the birth mix, so the baseline means and Formulas E's table are unchanged; Spiritual
Roots owns how often it occurs.

### E. Realm-step success

The realm_step_success formula is defined as:

`S = P_C · (1 − F) + S_bare` ; `F = Σ_{x=0..B} C(B, x) · p_brew^x · (1 − p_brew)^(B−x) · Π_{j=0..G+x−1} (1 − q_j)` ; `q_j = min(q_max, q + min(j · ι_pp, ι_cap) + τ · [j = 0 and the realm step's talisman is used])` ; `S_bare ≤ 1 − (1 − p_bare)^bare_attempt_cap`

- **Attempts in order** (rewritten 2026-11-04 for failure insight, cross-GDD review 04g,
  F13). A life that brews x pills (binomial in B and p_brew) and holds G gift pills makes
  G + x pill attempts, gift pills first. Attempt j (counted from 0) carries the failure
  insight of the j failures before it, so q rises by 2 points per failure, up to 4.
- **The talisman sits on a held pill at an attempt, not on a brew** (rule 8; corrected
  2026-11-04, eighth pass). It goes on the step's first pill attempt (j = 0), whether
  that pill was gifted or brewed. If no pill exists it is never used.
- With insight off (ι_pp = 0), no gift pills and no talisman, F reduces to the earlier
  closed form (1 − p_brew · q)^B.
- G is an expectation: a fractional G mixes ⌊G⌋ and ⌈G⌉ gift pills.
- q is the baseline q_pill of the step's first attempt (Formulas C).
- For a known list of pills held, use `S = 1 − Π_i (1 − q_i)` with each q_i including its
  insight.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_C | float | 0–1 | calculated | Chance the life ever meets the realm condition; about 1 for the CF density condition with competent play; the CF→NS heart-demon gate's P_C is also assumed about 1 (kills add no heart demon, Character Stats, so the gate tests failed breakthroughs, events and #9) |
| B, p_brew, G | | | Formulas D | Brews that count, brew success, gift pills (an expectation) |
| q, τ, ι_pp, ι_cap | float | | Formulas C | First pill attempt's chance, the talisman, failure insight per failure and its cap |
| q_j | float | 0.01–0.95 | calculated | Chance of the step's pill attempt j |
| S_bare | float | 0–0.012 | calculated | The most a life spamming bare attempts can add: at most `bare_attempt_cap` (3) attempts per realm step, so 0.0119 / 0.0110 / 0.0110 / 0.0090 |
| S | float | 0–1 | calculated | Chance to cross the bottleneck before the life ends |

**Output Range:** 0–1. A root-free life with three brews at p_brew 0.64–0.65 and each
gate's baseline q crosses with chance 0.208 / 0.213 / 0.174 / 0.178 (with failure insight;
without it 0.187 / 0.193 / 0.152 / 0.157).

**The targets are averages over the birth mix (user decision 2026-11-04, cross-GDD review
D1).**
- The 0.30 / 0.70 targets are the mean S over lives born with the count weights 45 / 32 /
  15 / 6.5 / 1.5 % and the purity roll of Spiritual Roots (Formulas A).
- Roots with more elements cross more often, so "more elements is better" also holds for
  breakthrough odds.
- Per-life S is exact given the life's B. The W each life gets comes from the entry-age
  model (Formulas D), so the figures below are model results, not a bot run (recomputed
  2026-11-04 after cross-GDD review 04g, with failure insight).

| Gate | Recipe | `pill_chance` (first-attempt q) | W at the 10th / 50th / 90th percentile | Root-free B at W p10 / p50 | Mean S (P_C = 1) | S by element count 1 / 2 / 3 / 4 / 5 | Gift pills G the edge needs for a mean of 0.70 (Đạo Cốt; at QR→FE also the one usable starting talisman; no Tổ Truyền Linh Điền) | Edge S by element count |
|---|---|---|---|---|---|---|---|---|
| QR→FE | 2 × 40 + 10 | 0.04 (0.1025) | 104 / 104 / 104 | 3 / 3 | 0.299 | 0.25 / 0.30 / 0.36 / 0.42 / 0.49 | 1.42 | 0.66 / 0.71 / 0.75 / 0.79 / 0.84 |
| FE→CF | 2 × 42 + 18 | 0.045 (0.1075) | 94 / 116 / 144 | 2 / 3 | 0.302 | 0.25 / 0.31 / 0.38 / 0.44 / 0.50 | 1.19 | 0.66 / 0.71 / 0.76 / 0.80 / 0.84 |
| CF→NS | 4 × 60 + 10 | 0.02 (0.0825) | 310 / 342 / 382 | 3 / 3 | 0.298 | 0.24 / 0.31 / 0.38 / 0.44 / 0.50 | 1.35 | 0.65 / 0.71 / 0.77 / 0.81 / 0.85 |
| NS→DT | 4 × 100 + 80 | 0.0225 (0.085) | 540 / 645 / 767 | 3 / 3 | 0.301 (provisional: P_C < 1 lowers it, Open Question 10) | 0.23 / 0.32 / 0.38 / 0.45 / 0.52 | 1.29 | 0.63 / 0.72 / 0.78 / 0.83 / 0.87 |

A step's first pill attempt has the baseline q above, and 0.12 more with Đạo Cốt. A
root-free life fails to brew any pill with chance 0.043–0.047 at B 3 and 0.12–0.13 at B 2,
against about 0.36–0.50 under the old rationed supply (cross-GDD review 04e, F3). The
edge's W comes from the edge's own crossings, which are earlier (FE→CF median 146).

**Builds against the targets** (entry-age model, birth-mix means; ceiling run = the three
Character Stats ceilings 10 / 3 / 15 %, the step's talisman, typical q extras, best plots,
`field_plots` 0, #22 and #23 off):

| Gate | + talisman | Tree at 8 pp (under X_q) | Ceiling run (AC-CG-60) | Fully built, no edge (every q extra at its maximum, X_q 0.10) | Edge + full build (Đạo Cốt, G as above) | Pill Fire holder (alchemy 6) | Lava holder (alchemy 5) | Spirit Farming holder (herb 20; with its +2 plots) |
|---|---|---|---|---|---|---|---|---|
| QR→FE | 0.337 | 0.374 | 0.437 | 0.519 | 0.826 | 0.450 | 0.446 | 0.456 (0.624) |
| FE→CF | 0.346 | 0.376 | 0.459 | 0.541 | 0.854 | 0.473 | 0.469 | 0.495 (0.672) |
| CF→NS | 0.340 | 0.384 | 0.450 | 0.547 | 0.858 | 0.464 | 0.460 | 0.483 (0.655) |
| NS→DT | 0.344 | 0.387 | 0.447 | 0.542 | 0.852 | 0.461 | 0.456 | 0.478 (0.642) |

The fully built life with no edge stays at or below about 0.55 and edge plus full build at
about 0.85, which is what the q-extras ceiling was sized for (Formulas C; cross-GDD review
04g, F14). Without that ceiling they were 0.76–0.81 and 0.94–0.96.

- **What the targets assume (bot policy).**
  - Capabilities #22 and #23 are disabled.
  - No talisman is used. Failure insight is on (a rule, not a bonus).
  - The tree is allocated as the bot plays it, typically about 0.02 of the 8 pp cap, and
    takes no plot node (cross-GDD review 04g, F11).
  - Plots are used at best play (Formulas D's plant order, the Advisor's plant plan); no
    Diên Thọ Đan.
- **What a life can add on top.**
  - #22 or #23: up to the Meridian Map guard's +0.10 (with #23's failure-insight term,
    Formulas H).
  - The realm step's talisman: about +0.04 (0.30 → 0.34).
  - A tree that maximises its 8 pp: about +0.08 (0.30 → 0.37–0.39); the q-extras ceiling
    clips it on a typical life (Formulas C; it was +0.12 before the ceiling).
  - **Extra plots, as a build** (user decision 2026-11-04): `field_plots` from the Spirit
    Farming mutation, Tổ Truyền Linh Điền and other perks, items or Spirit Fields add
    brews (the tree gives none at its launch values). The targets assume none; 12 plots
    and no other bonus give 0.62–0.75 (Formulas D).
  - **Everything at once, no edge:** 0.52–0.55 (the builds table above).
- **The levers.**
  - **Fine lever: `pill_chance`.** It moves the mean about 0.021 per 0.01 at QR→FE and
    FE→CF and 0.024 at CF→NS and NS→DT. It moves the edge too, but the edge's gift pills
    absorb that.
  - **Coarse lever: the recipe's `min_age`.** It moves B in whole steps (Tuning Knobs
    table), and gift pills ignore it, so it moves the baseline more than the edge.
  - Raising `min_age` past the brew guarantee's bound is not allowed.
- **The Deity Transformation lever** is the condition.
  - Fortuitous encounters can grant the edge the insight (P_C = 1), while baseline lives
    depend on the enlightenment event rate.
  - At P_C 0.6, a mean of 0.30 needs a per-life S of 0.50, which is about a first-attempt
    q of 0.31 with three brews and failure insight. So the DT `pill_chance` is re-set once
    P_C is known (Open Question 10).
- **DT targets include the Heavenly Tribulation.** The 0.30 / 0.70 targets cover the
  roll and the tribulation together (user decision), so the roll's own target is 0.30 ÷
  p_t, where p_t is the tribulation survival chance set by the Heavenly Tribulation
  GDD. Until then, the roll target is 0.30 / 0.70.
- **What the edge contributes.** Each perk pays through q, B, G or P_C:
  - Đạo Cốt: +0.12 on q, outside the q-extras ceiling, which more than doubles it.
  - Tổ Truyền Linh Điền: +1 plot and faster herbs, so a root-free life at QR→FE goes from
    3 to 4 brews. Its +40 % herb growth clamps to the ceiling of 10; at 40 it would give 6.
  - The starting talismans: QR→FE only, and only one is usable per realm step, so the
    second carries over.
  - Gift pills: G.
  - Gifts that meet a condition (a spirit vein, a calming pill, an enlightenment event):
    P_C.

  A perk that touches none of these lands the edge at about 0.52–0.55, Đạo Cốt's own level
  (with the starting talisman at QR→FE).
- **Fortuitous encounter weights must change.** The edge needs about 1.2–1.4 gift pills
  per gate, but today's fortuitous encounters give a pill only about a third of the
  time. Their weights should favour pills and herbs already at age (data, Progression
  Edges).
- **Sample size.** Verifying 0.30 ± 0.05 and 0.70 ± 0.05 at 95 % needs about 330
  bottleneck arrivals per arm per gate (1.96² × 0.21 ÷ 0.05²). About 35–50 lives are
  enough if the bot logs B, p_brew and q per life and averages the analytic S.

S_bare is left out of the table above. The bare-attempt cap (rule 11) bounds it at about
0.012, inside the ±0.05 tolerance. The heart demon does not: a patient life that waits out
the decay could otherwise make dozens of attempts. A bare success counts as a crossing.

**Example:** CF→NS, root-free, B = 3, p_brew 0.65, first-attempt q 0.0825, so the attempts
run at 0.0825 / 0.1025 / 0.1225.
- F = 0.0429 (no pill) + 0.2389 × 0.9175 (one pill) + 0.4436 × 0.8235 (two) + 0.2746 ×
  0.7226 (three) = 0.8258, so S = **0.174**.
- With the talisman on the first pill attempt (0.1325): S = **0.217**.
- For the {Wood 40, Fire 86, Water 10} root at the median W, B = 5 and p_brew 0.865:
  S = **0.389**.

### F. Failure and heart demon

The heart_demon_per_failure formula is defined as:

`Δhd = h_f − d · T_r` ; `n_90 = ⌈90 / Δhd⌉`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| h_f | float | 15 | data file (`breakthrough.failure_tam_ma_gain`) | Heart demon (tâm ma) per failure (was 10) |
| d | float | 0.25 per season | data file (`tam_ma_natural_decay`, `character_attributes.json`) | Natural decay (was 0.5) |
| T_r | float | 7.4 / 12.6 / 14.5 / 23.4 seasons | calculated (A) | Time to refill the bar after a failure |
| n_90 | int | 7–10 | calculated | Back-to-back failures before death by qi deviation becomes possible |

**Output Range:** Δhd = 13.2 / 11.9 / 11.4 / 9.2 at the four gates, so n_90 = 7 / 8 / 8 /
10. The bare chances were first sized as 0.03 ÷ n_90; the bare-attempt cap (rule 11) now does the bounding, so n_90 only describes how soon back-to-back failures become deadly.

- Pill attempts are usually spaced years apart, by herb ripening and the bar refill,
  though two pills held at once can be used one refill apart. A failure's +15 decays
  within about 15 years. So heart demon mainly drives the NS condition. Death by qi deviation is a
  deliberate rare tail risk (user decision 2026-11-03): it needs a deviation hit and heart
  demon of 90 or more, i.e. 7 or more failures in quick succession (3 bare attempts plus a
  run of failed pill attempts), which normal play almost never produces (AC-CG-36a).
- The qi deviation (tẩu hỏa nhập ma) chance is max(0, heart demon − Dao heart ÷ 2) % ×
  (1 + `qi_deviation_pct` ÷ 100) (Character Stats, Formulas E). After
  one failure with Dao heart 30 it is 0 %; after two quick failures it is about 13 %.

**Example:** QR→FE: 15 − 0.25 × 7.4 = 13.2, so ⌈90 ÷ 13.2⌉ = **7**.

### G. Realm condition values

| Condition | Key | Value | Why |
|---|---|---|---|
| CF: local spiritual qi | `core_density_min` | 1.4 (user decision) | Place density plus `density_bonus`, the same sum the cultivation rate uses. About 18 % of places qualify, 2–4 per world (guess): mountains 20 %, valleys 40 %, islands 20 %, every secret domain (bí cảnh), no lakes or towns. A gathering formation (Tụ Linh Trận, +0.15 per level, home only) reaches it at level 3 from a home at 1.0, or level 4 in a town. At 1.3, 28 % of places would qualify; at 1.5 only 9.5 %, mostly secret domains |
| NS: heart demon | `nascent_tam_ma_max` | 20 (user decision) | One failure (+15) still allows the next attempt. Two quick failures (about 30) force a 10-year wait or a calming pill (Tĩnh Tâm Đan, −25). Kills add no heart demon (Character Stats), so it tests failed breakthroughs, events and capability #9 across the realm |
| DT: insight | `condition.type` "insight" | kept once gained (user decision) | One enlightenment event unlocks every later attempt in that realm step, so supply (B) is not limited by insights |

### H. Guard hook (for the Meridian Map's Formulas E2)

The guard_success formula is defined as:

`S_guard = min(1 − Π_{i ∈ made ∪ held} (1 − q_i), s_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| q_i | float | 0.01–0.95 | calculated | q_pill of each pill attempt made this realm step, plus one per held pill whose condition is met now; bare attempts excluded. An attempt made counts its q_pill including τ if a talisman was on it, and including the failure insight it carried; a held pill counts without τ, at the step's current failure insight. Insight only grows within a step, so a held pill's real attempt is at least that good. Leaving τ out of held pills keeps S_guard a lower bound (cross-GDD review 04g, C11 and F13) |
| s_max | float | 0.95 | data file (`guard.s_max`) | Cap that keeps 1 − S away from 0 |
| S_guard | float | 0–0.95 | calculated | Lower bound on the unknown S, used in place of S in the Meridian Map's E2 |

**Output Range:** 0–0.95. Future pills only raise the true S, so using a lower bound can
only shrink capabilities #22 and #23's lift: the +0.10 guard holds by construction. The
attempt log is saved with the character.

**#23 and failure insight** (user decision 2026-11-04, cross-GDD review 04g, F13; Open
Question 17, answered). The extra roll's chance includes the step's insight, and its
failure adds +0.02 to the next pill attempt. That later insight is outside the roll's own
lift, so with E2's earlier q_retry = min(q, δ_max ÷ (1 − S)) the lift could reach 0.1009
at the CF→NS baseline (one failed attempt, one held pill) and 0.111 at q 0.30. The
Meridian Map's E2 now uses `q_retry = min(q, (δ_max − ι) ÷ (1 − S))`, where ι is the
insight the roll's failure would add (0.02, or 0 at the cap). The insight term adds at
most ι, so the lift stays at or below δ_max by construction (0.097 and 0.092 in those
cases). q is the extra roll's own chance, without τ.

**Example:** CF→NS baseline, one failed attempt at 0.0825 and no pills held (recomputed
after 04g):
- S_guard = 0.0825;
- the extra roll's own chance is 0.1025 (the +0.02 insight from that failure);
- q_retry = min(0.1025, (0.10 − 0.02) ÷ 0.9175 = 0.0872) = 0.0872;
- the roll's own lift = 0.0872 × 0.9175 = **0.080**, and its failure's insight adds at
  most 0.02 more.

### I. Cultivation rate

The cultivation_rate formula is defined as:

`rate = base · curve · tech · comp · density · tox · max(0, 1 + speed_pct ÷ 100)`

It is computed once per season, at the start of the season (rule 3). Every factor is
shown as one line of the breakdown.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base | float | per realm | data file | Realm base rate |
| curve | float | 0.3–9.0 | Spiritual Roots (Formulas B) | `element_count_curve[base element count][stage group]` |
| tech, comp, density, tox | float | 0+ (comp 1.005–1.75) | Cultivation Techniques (Formulas A), Character Stats (Formulas J, `comp = 1 + effective comprehension ÷ 200`), Travel & Map / Formulas, Character Stats | Technique speed, comprehension, local qi density and pill-toxicity penalty factors |
| speed_pct | float | 0 upward (no ceiling; a five-element root's generating pairs alone are +15, with techniques, the tree and items on top) | calculated (stat sheet `cultivation_speed_pct`, Character Stats Formulas I) | The sum of every speed bonus, including Spiritual Roots' generating pairs (+3 % each, up to +15) |

**Output Range:** 0 upward. The speed bonuses never reduce the rate below 0.

**Example:** base 25, comprehension factor 1.25 (effective comprehension 50), the other
factors 1.0: 31.25 per season. With
two generating pairs (+6 %): 31.25 × 1.06 = **33.125**, not 31.25 + 6.

### Parameter keys

**`cultivation_realms.json`, per realm:**
- `levels` `[lo, hi]`, `climb_total`, `climb_growth`, `bar_mult` (null for DT).
- `layers` `{count: 13, levels_per_layer: 3}`, Qi Refining only.
- `stage_curve_groups`: 4 entries (early, middle, late, great perfection), keys of
  `element_count_curve`: QR becomes `[lk_early, lk_mid, lk_late, lk_late]`, FE `[tc_so,
  tc_trung, tc_hau, tc_dvm]`, CF `[kd_so, kd_trung, kd_hau, kd_dvm]`, NS `[na, na, na,
  na]` and DT `[ht, ht, ht, ht]`.
- `entry_requirement`:
  - `pill_chance` 0.04 / 0.045 / 0.02 / 0.0225 (**change** after cross-GDD review 04g:
    failure insight and the shorter NS/DT herbs; 04f had 0.06 at every gate; built 0.06 /
    0.20 / 0.20 / 0.15);
  - `base_chance` 0.004 / 0.0037 / 0.0037 / 0.003;
  - `condition`: FE null; CF `{type: "density_min", value: 1.4}`; NS
    `{type: "tam_ma_max", value: 20}`; DT `{type: "insight", consumed: false}`.
- Removed: `tu_vi_required` (replaced by the cost curve) and `tree_points_per_stage` (the
  Meridian Map owns points).

**`cultivation_realms.json`, global:**
- `level_cap` 300.
- `breakthrough.chance_min` 0.01 and `chance_max` 0.95, for pill attempts (replaces the
  hard-coded clamp).
- `breakthrough.failure_tam_ma_gain` 15.
- `breakthrough.failure_tu_vi_loss_pct` 0.30 (bar lost on a failure).
- `breakthrough.failure_khi_huyet_loss_frac` 0.40 (share of maximum vitality lost).
- `breakthrough.vitality_floor` 0.05 (floor for that loss, and vitality after a deviation).
- `breakthrough.backlash_death_tam_ma_threshold` 90 (a deviation at or above it kills).
- `breakthrough.tam_ma_backlash_divisor` 2.0 (Dao heart divisor in the deviation chance).
- `breakthrough.failure_insight_pp` 2 and `breakthrough.failure_insight_cap` 4 (percentage
  points; rule 10; **new** after 04g).
- `breakthrough.q_extras_ceiling_pp` 10 (percentage points; the cap on the summed q
  extras, Formulas C; **new** after 04g).
- `guard.s_max` 0.95.
- `stage_power_step` 0.15, one global key (**change**: per realm today; Character Stats
  AC-CS-36 tests it as global).
- Keys shared with Character Stats, one owner each (cross-review C6, C7): this GDD owns
  the values of `vitality_floor` and `tam_ma_natural_decay`; Character Stats reads them
  (Open Question 11).

**`cultivation_realms.json`, ladder constants owned here (the Meridian Map reads them):**
- `bare_attempt_cap` 3 (bare attempts per realm step).
- Read from the Meridian Map: `tree_breakthrough_cap` 8 pp (the cap on the tree's share of
  `breakthrough_chance`).
- `great_breakthrough_bonus` 15 / 25 / 40 / 60 (Foundation Establishment, Core Formation, Nascent Soul, Deity Transformation; a placeholder 90 for the realm after Deity Transformation).
- `pct_trung` 15, `pct_hau` 25, `pct_dai` 35 (integer percents of the next great bonus; `pct_dai` is the advance paid at great perfection and deducted at the breakthrough, rule 9).

**Other files:**
- `character_attributes.json`: `tam_ma_natural_decay` 0.25.
- `crafting_talismans.json`: `pha_canh` value 5 (**change** eighth pass, was 10); new
  `per_realm_step` 1 (at most one talisman per realm step, rule 8; 04f).
- Item DB and economy (all **change** 04f, cross-GDD review B2; the data still holds the
  built recipes until the implementation story):
  - the FE pill (`truc_co_dan`) needs 2 ginseng at `min_age` 40 plus 1 `hoa_linh_chi` at
    10 (built: 1 ginseng at 30). The ginseng's "thirty years" text becomes "forty years";
  - the CF pill (`ngung_nguyen_dan`) needs 2 Kim Tủy Quả at `min_age` 42 plus 1
    `xich_huyet_dang` at 18 (**change** eighth pass, was 2 at 50 + 1 at 20; built: 1 Kim
    Tủy Quả at 100). The herb's text "at a hundred years" becomes "at forty-two years";
  - `field.seed_rarity_max` 4 from FE on; the NS and DT pill herbs unlock at CF and NS
    entry (Formulas D);
  - new NS and DT pill recipes (`hoa_anh_dan`, `hoa_than_dan`): 4 herbs at 60 plus 1 at
    10, and 4 at 100 plus 1 at 80 (**change** after 04g, F2: the eighth pass had 2 at
    130 plus 1 at 40 and 2 at 230 plus 1 at 80; guesses; each meets the brew guarantee);
  - fortuitous encounter weights favouring pills and herbs already at age;
  - `to_truyen_linh_dien`'s `herb_growth_pct` 40 counts under the ceiling of 10; a data
    pass may trim it.

## Edge Cases

**Levels and stages**

- **If one season gains several levels and crosses one or more stage boundaries:**
  - each small breakthrough fires in order and pays its points;
  - stats use the final stage multiplier;
  - the log lists every level and stage reached;
  - the whole season's gain uses the season-start rate (rule 3), so a curve-factor change
    at a stage-group boundary applies from the next season.
- **If cultivation base overflows the realm's last climbing level:** the surplus carries
  into the bottleneck bar. Anything beyond a full bar is lost, and the bar shows it as
  wasted.
- **If a cultivation-base grant (an event, a pill, capability #9) arrives while the bar is
  full:** the excess is lost. Before the player consumes a cultivation pill at a full
  bar, the Advisor warns that it would be wasted.
- **If an effect would move the level outside 1–300:** it is clamped to that range.
- **If a level is regained after a stage loss:** `level_gained` fires only for a level
  above the highest ever reached, so no level pays twice.
- **If the level is 300:** the state is Capped. Cultivating adds nothing, and the UI says
  so. What lies beyond is an open question.
- **If an effect costs a stage** (for example capability #5, which saves the life by
  losing one stage):
  - the level drops to the first level of the previous stage, or to the realm's first
    level if the character is already in the early stage;
  - it never crosses a realm boundary;
  - the bar resets to 0 and the stage multiplier is recomputed;
  - points already earned are kept, because the Meridian Map counts the highest level
    reached.
- **If a slow root cannot reach the bottleneck before its lifespan ends:** that is a valid
  outcome, not a bug. The Advisor shows the estimated years to the bottleneck against the
  years left.

**Attempts**

- **If the player attempts with a pill but the condition is unmet:**
  - the attempt is bare and burns no pill;
  - before the roll, the attempt preview shows "condition not met" and the bare chance,
    and the player must confirm.
- **If several matching pills are held:** the highest-quality one is burned.
- **If several talismans are held:** only one can be used per realm step (rule 8). The
  first pill attempt with the toggle on burns it (the toggle is on by default for the
  step's first pill attempt); later attempts in the same realm step burn none and gain
  nothing. A bare attempt and #23's extra roll burn none. Unused talismans carry over to
  the next realm step. A talisman that capability #13 keeps still marks the step as used.
- **If a pill attempt fails:** the step's failure insight rises by 2 points, up to 4
  (rule 10). A failed bare attempt adds none, and a bare attempt never uses it. #23's
  extra roll uses it and, if it fails, adds to it. A stage loss and the passing of time
  leave it unchanged; only a successful great breakthrough resets it.
- **If the q extras sum above `q_extras_ceiling_pp`:** they count as 0.10, and the
  breakdown shows each extra and the clamp line. Destiny perks, failure insight and the
  talisman are added after that clamp; the 0.95 clamp then applies to the total.
- **If a held pill belongs to another realm's bottleneck:** it is not usable and not
  burned. It waits for its bottleneck.
- **If the condition changes during the attempt's season** (a formation lapses, heart
  demon rises): the condition is checked once, at the start of the attempt, before
  anything is burned.
- **If heart demon is exactly 20 at the Nascent Soul attempt:** the condition holds (at
  most 20).
- **If a gathering formation lapses because its upkeep went unpaid:** its density bonus no
  longer counts toward the Core Formation condition.
- **If a slot, equipment or main-method change would lower the lifespan cap to the
  character's age or below:** the preview names the death and the player must confirm
  (rule 14). Declining changes nothing; confirming kills at once, before cultivation.
  A change that lowers the cap but leaves it above the age needs no confirmation; the
  preview still shows the new cap.
- **If lifespan bonus sits above the ceiling at a great breakthrough:** the new realm's
  ceiling applies from the success, so the clamped years count again (rule 14).
- **If lifespan bonus is lost without a player choice** (a lifespan treasure destroyed or
  stolen, a slotted art made unusable by Cultivation Techniques rule 8): no confirmation
  is possible. The cap is recomputed at the next season start. If it is at or below the
  age, the character dies of old age then, and the log names the lost source (cross-GDD
  review NG8).
- **If the attempt season would also end the life by old age:** the attempt resolves
  first. A success raises the lifespan cap before the season's aging is applied.
- **If q_pill would exceed 0.95:** it is clamped to 0.95. Bare chances are never clamped
  upward.
- **If a qi deviation leaves the character at 5 % vitality without killing them:** the
  next attempt still waits for the bar to refill. Vitality recovers with time or pills.

**Supply**

- **If the herb growth factor h is 0** (`herb_growth_pct` at −100 % or below, so
  max(0, 1 + herb_growth_pct / 100) = 0): no herb ripens. T_k = ∞ for every k and B = 0;
  no division is performed. Pills can still come from the Market (M_market) and gifts (G).
  The Advisor shows "no herb can ripen" and the growth penalty's sources (Formulas D;
  cross-GDD review 04g, S1).

**Conditions and insight**

- **If the Deity Transformation insight is gained before great perfection:** any insight
  gained while in Nascent Soul counts, and it is kept for every later attempt.
- **If a Deity Transformation roll succeeds before the Heavenly Tribulation exists:** the
  success stands and `breakthrough_succeeded` fires on the roll. Once the Tribulation
  exists, the event fires only if the character survives it.
- **If the character is at a spirit vein that only a secret domain holds:** the condition
  counts while the character is there. The attempt still takes its season inside the
  domain.

**Capabilities**

- **If #22 Last Radiance applies:** it applies only to a pill attempt, once per realm
  step, and never together with #23 on the same step.
- **If #9 Great Essence-Draining Art triggers at great perfection:** the stage's total
  cost is the bottleneck bar. When the character is Capped, it adds nothing.
- **If #23 Burning Life to Break Through is used:** burn_cost uses the base lifespan of
  the realm being left. A failed #23 roll takes rule 10's penalties and enters the
  attempt log (Formulas H).
- **If #23's extra roll is made:** it burns no pill and inherits the failed pill attempt's
  condition result (not rechecked, so a Nascent Soul attempt that failed and pushed heart
  demon above 20 can still use it). It is offered only after a failed *pill* attempt, and
  only when the remaining lifespan exceeds burn_cost.
- **If a stage loss (capability #5) happens at a bottleneck:** the bare-attempt count is
  unchanged; only a successful breakthrough resets it.

- **If a qi deviation leaves the character alive at 5 % vitality after a failed pill
  attempt:** #23 may still be used in the same season. A second failure adds another
  +15 heart demon and a second deviation roll, so the chain is a real gamble.

**NPCs**

- **If an NPC is fated to break through:** it does so with chance `fated_breakthrough_per_season` (0.08, as built) each season. It emits no `breakthrough_succeeded` event (rule 9).
- **If a fated NPC dies of old age before its breakthrough lands:** the death stands, and
  the world database records it as dying at the bottleneck.
- **If an NPC's stage changes:** its level becomes the first level of the new stage, and
  its tree points follow points_total for that level.

**Saves**

- **If a save holds the old stage ladder (realm, stage, cultivation base in the stage):**
  - it migrates to level = the first level of the matching stage + ⌊(cultivation base
    fraction) × the stage's levels⌋;
  - its points are recomputed with the Meridian Map's points_total, and the difference is
    added as unspent;
  - if more points were already spent than the new total allows, the allocation is kept
    and the unspent count is 0;
  - a fraction that would land past the realm's last climbing level is clamped to great
    perfection with a full bottleneck bar; an old save at a full bottleneck maps to great
    perfection with a full bar;
  - an old Qi Refining layer k maps to level 3(k − 1) + 1 + ⌊fraction × 3⌋;
  - heart demon and other state carry over unchanged;
  - the migration is logged once.

## Dependencies

Spiritual Roots (`linh-can.md`), Character Stats (`character-stats.md`), Cultivation
Techniques (`cong-phap.md`) and the Meridian Map (Kinh Mạch Đồ, `kinh-mach-do.md`) have
GDDs among the systems below, and each lists Realms & Bottlenecks. Every other interface is provisional. When each remaining GDD is
written, it must list Realms & Bottlenecks in its own Dependencies section.

**Upstream: this system cannot work without them (hard)**

| # | System | What Realms & Bottlenecks needs from it |
|---|---|---|
| 1 | Data-Driven Config | `cultivation_realms.json` (bands, costs, chances, conditions), `character_attributes.json` (curve, heart demon decay) |
| 2 | Deterministic Simulation Core | The seeded RNG for attempts and NPC fate; Breakdown for every rate and chance |
| 4 | Time & Turn | Seasons, age, death by old age; a one-click "retreat until ripe" at the bottleneck (Open Question 18) |
| 6 | Spiritual Roots (Linh Căn) | Base element count (mutations excluded) and the curve factor by realm and stage |
| 7 | Character Stats | Comprehension, Dao heart, heart demon, vitality and the stat sheet (`breakthrough_chance`, `cultivation_speed_pct`, flags); it receives the stage multiplier |
| 13 | Item Database & Generation | Breakthrough pills (tag, quality), breakthrough talismans |

**Upstream: needed for a part of the system (soft)**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 9 | Cultivation Techniques (Công Pháp) | Technique speed in the rate | Crude cultivation at ×0.3 of the strongest purity (as built) |
| 14 / 15 | Spirit Herbs & Spirit Fields, Alchemy | Pill supply: herb ages, plots, brew success | Pills only from the market and gifts |
| 17 | Formations (Trận Pháp) | A gathering formation's density bonus for the Core Formation condition | Only spirit vein places meet it |
| 25 | Travel & Map | Place density (spirit veins) | Only a home formation meets it |
| 23 | Event Engine | The Deity Transformation insight (an enlightenment event) and cultivation-base grants | The Deity Transformation condition can't be met |
| 11 | Progression Edges | Perk and talisman bonuses and gift pills (through the stat sheet and items); the NPC edge score e | No player edge; NPCs at the 0.30 baseline |

**Downstream: systems that depend on Realms & Bottlenecks**

| # | System | What it takes |
|---|---|---|
| 10 | Meridian Map | `level_gained`, `stage_reached` and `breakthrough_succeeded` events; the ladder constants; S_guard for its guard (E2). Rule 8 consumes Formulas E2's q_desp with τ_a (#22 on a talisman attempt); E2's q includes the step's failure insight, and its q_retry subtracts the insight #23's failed roll would add (Formulas H) |
| 6 | Spiritual Roots (Linh Căn) | The `breakthrough_succeeded` event, for Mutation Awakening (its rule 9). Spiritual Roots is also upstream (the curve); the event breaks the cycle, since neither system calls the other |
| 21 | Combat | The combat power realm term (realm base × stage multiplier); it reports defeats for capability #9 |
| 22 | Heavenly Tribulation | The hand-off after a successful Deity Transformation roll |
| 24 / 28 | NPC Build Generation, Living World Tick | NPC realm, stage and level; the fate roll |
| 9 | Cultivation Techniques | The realm, for the technique tier cap |
| 20 | Market | Realm price tiers and breakthrough pill stock |
| 23 | Event Engine | The bottleneck flag (event chance, protagonist-only templates) and realm-keyed budgets |
| 32 | Achievements (Thành Tựu) | Realms reached |
| 33 | Balance Simulation Harness | The targets (0.30 / 0.70) and the per-life attempt log |
| 35 / 36 / 37 | Guidance Layer, Debug Terminal, Game UI | Bar, ETA, bottleneck state, conditions met or unmet, the attempt breakdown |
| 5 | Save/Load | Level, bar, attempt log, insight, failure insight count, per-realm capability use |

**Cycles and how they are broken:**
- **Realms ↔ Progression Edges.** Edges reads realms; Realms only reads the stat sheet and
  items that Edges fills, never Edges itself.
- **Realms ↔ Event Engine.** Events read the bottleneck flag; Realms reads the insight from
  the character's state, which an event set.
- **Realms ↔ Cultivation Techniques.** This cycle is already in the systems index: the
  technique feeds the rate, and the realm caps the technique tier.

**Systems index.** Row 8 already carries the dependencies above (hard: Config, Sim Core,
Time & Turn, Spiritual Roots, Character Stats, Item DB; soft: Cultivation Techniques,
Spirit Herbs, Alchemy, Formations, Travel & Map, Event Engine, Progression Edges). The
built game still runs the old stage ladder.

## Tuning Knobs

Every knob is a data key (Formulas, Parameter keys). Ranges marked *derived* follow from
other numbers in this GDD; ranges marked *guess* wait for a bot run.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `climb_total` | 1,025 / 5,600 / 42,000 / 276,000 / 1,850,000 | QR −30 % to +19 % (first derived from a five-element root at 84 % of the half-lifespan ceiling in QR at tech 1.0, Spiritual Roots Formulas B; with Cultivation Techniques' `count_gain` 1.27 it is about 44 years, 73 %, so +19 % is now a margin, not the limit); FE and CF −30 % to +30 % (five-element check pending, AC-CG-33a); NS and DT −30 % to +8 % (derived: +30 % would push a 1-element NS and DT past the ceiling); derived ceiling: a root of any element count must clear a realm in at most half its lifespan | Years per realm (Pillar 4) |
| `climb_growth` | 6 / 3 / 3 / 3 / 3 | 2–6 (QR 4–8) | How much later levels cost than early ones |
| `bonus_ceiling_target` (calibration target, not a data key) | S 0.45 per gate, no edge, at best plot play with the realm step's talisman (04f), for lives without extra plots (`field_plots` 0), without a root factor beyond Wood (Time excluded) and without a craft mutation's raised ceiling (04g) | 0.40–0.50; *derived*: must stay well under the 0.70 edge target, or the edge stops being distinct | How much a dedicated alchemy build can raise breakthrough odds. Met by tuning Character Stats' `bonus_ceilings`: 10 / 3 / 15 % with the 5 pp talisman gives 0.44–0.46 in the entry-age model after failure insight (Formulas D; AC-CG-60), accepted inside AC-CG-60's ≤ 0.48 tolerance (user decision 2026-11-04). Outside it by design (user decisions 2026-11-04): extra plots (+1 plot gives 0.52–0.55), Time's root factor (0.53 at CF→NS and NS→DT) and craft-mutation holders (Pill Fire and Lava 0.45–0.47, Spirit Farming 0.46–0.50) |
| `q_extras_ceiling_pp` (`breakthrough`) | 10 pp (**new** after 04g, F14) | 8–10 (*derived*: a fully built life with no edge gives 0.48–0.50 at 8, 0.52–0.55 at 10, 0.54–0.57 at 11 and 0.56–0.59 at 12; the 0.55 bound sets the top, and it must stay above the typical extras, 6.25 pp) | How much talent, pill quality, the tree and events can add to a pill attempt together. Destiny perks, the talisman and failure insight are outside it |
| `failure_insight_pp`, `failure_insight_cap` (`breakthrough`) | 2 pp per failed pill attempt, cap 4 pp (**new** after 04g, F13) | pp 1–3, cap 2–6, with `pill_chance` re-tuned (*derived* at today's `pill_chance`: off gives 0.25–0.27, 1 / 2 gives 0.27–0.29, 2 / 2 gives 0.28–0.29, 2 / 6 gives 0.30–0.31, 3 / 6 gives 0.32) | How much a failure teaches. Larger values move odds from the first pill to the later ones |
| `bar_mult` | 4 / 10 / 10 / 10 | 6–15 (QR 3–5) | Bottleneck bar size; with the 30 % loss, how many levels a failure costs |
| `stage_power_step` | 0.15 | 0.10–0.20; derived ceiling 0.24, above which divine sense's great-breakthrough jump becomes smaller than the realm's own ladder | Stat rise per small breakthrough |
| `pill_chance` | 0.04 / 0.045 / 0.02 / 0.0225 (**change** after 04g: failure insight and the NS/DT recipes; 04f had 0.06 at every gate, built 0.06 / 0.20 / 0.20 / 0.15) | each gate ±0.01 (*derived* in the entry-age model: mean success 0.27–0.33; about 0.021 per 0.01 at QR→FE and FE→CF and 0.024 at CF→NS and NS→DT; −0.02 gives 0.25–0.26 and +0.02 gives 0.34–0.35) | **The fine baseline lever** (04f): per-attempt odds. It moves the edge too, but gift pills absorb that. AC-CG-30 sets the final value |
| `base_chance` | 0.004 / 0.0037 / 0.0037 / 0.003 | jointly with `bare_attempt_cap`: 1 − (1 − base_chance)^cap ≤ 0.03 (derived), so at most 0.0101 at cap 3 and 0.0061 at cap 5 | Hope for bare attempts; must stay near-hopeless |
| Comprehension, Dao heart, quality per-point bonuses | 0.0005 / 0.00025 / 0.015 | ±50 % | How much talent and pill quality matter |
| Breakthrough talisman τ (`pha_canh` value) and `per_realm_step` | 5 pp, 1 per realm step (**change** 2026-11-04: 1 per step from 04f, was 1 per attempt; 5 pp from the eighth pass, was 10) | τ 3–5 at 1 per step (*derived* after 04g: about +0.04 on the mean at 5; the ceiling run is 0.42–0.44 at 3, 0.43–0.45 at 4, 0.44–0.46 at 5 and up to 0.47 at 6; AC-CG-60). 2 per step would give about +0.08 | What a crafted talisman is worth at a bottleneck |
| `failure_tam_ma_gain` | 15 | 10–20, and at most `nascent_tam_ma_max` (one failure must still allow the next Nascent Soul attempt; Character Stats states 10–20 exclusive, so align at its next pass) | How fast back-to-back failures become deadly |
| `tam_ma_natural_decay` | 0.25 per season | 0.15–0.25; *derived*: n_90 must stay at 7–10, which holds up to about 0.256 (at 0.5 it is 8 / 11 / 12 / 28) | How long a failure haunts the character |
| `failure_tu_vi_loss_pct` | 0.30 | 0.2–0.4 | Refill time after a failure |
| `core_density_min` | 1.4 | 1.3–1.5; derived: 28 % to 9.5 % of places qualify | How hard the Core Formation condition is |
| `nascent_tam_ma_max` | 20 | 15–30, and at least `failure_tam_ma_gain` | How much heart demon a Nascent Soul attempt tolerates |
| Breakthrough recipe main herb `min_age` and qty (Item DB): ginseng, Kim Tủy Quả, NS herb, DT herb | 40 / 42 / 60 / 100 years at qty 2 / 2 / 4 / 4, with companions at 10 / 18 / 10 / 80 (**change** after 04g, F2: NS and DT were 2 × 130 + 40 and 2 × 230 + 80; 04f was 40 / 50 / 100 / 200; built ginseng 30 ×1 and Kim Tủy Quả 100 ×1) | QR→FE 36–46, FE→CF 38–44, CF→NS 55–65, NS→DT 95–110 (*derived* in the entry-age model at today's `pill_chance`: mean success 0.31–0.28, 0.33–0.28, 0.33–0.28 and 0.31–0.28; all inside the brew guarantee's 47 / 46 / 82 / 141, Formulas D). Steps are uneven: QR→FE drops from 0.28 at 46 to 0.24 at 47, and FE→CF from 0.28 at 44 to 0.26 at 47 | **The coarse baseline lever**: moves B in whole brews, so it shifts the per-element-count steps; gift pills ignore it, so it moves the baseline more than the edge |
| Fortuitous encounter weights (Progression Edges) | favour pills and herbs at age | enough for about 1.2–1.4 gift pills per gate (after 04g) | The edge's 0.70 |
| `bare_attempt_cap` | 3 | 2–5, jointly with `base_chance` under the same 0.03 limit (see the row above) | How much a patient life can add from bare attempts |
| `great_breakthrough_bonus`, `pct_trung` / `pct_hau` / `pct_dai` | 15 / 25 / 40 / 60 and 15 / 25 / 35 | provisional (owned here; the Meridian Map reads them); shares sum to at most 100 | Meridian points per life |
| `chance_min`, `chance_max` | 0.01, 0.95 | fixed: the guard's s_max needs 0.95 | Clamp on pill attempts |
| `guard.s_max` | 0.95 | fixed; must equal `chance_max` (the Meridian Map calls the same value `q_max`) | Keeps the Meridian Map's guard finite |

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37) and Audio (system 38). Intent: a small
breakthrough is a brief flourish; a great breakthrough is the biggest moment a life can
have; a qi deviation should feel dangerous.

## Game Feel

Not specified at this tier. Intent for later work:
- **Levels** tick by often, about every few seasons early in each realm.
- **Small breakthroughs** feel like real steps, with a visible jump in four stats.
- **The bottleneck** feels like a wall that preparation, not grinding, gets past.
- **A failed attempt** should hurt (a lost pill, lost years, rising heart demon) without
  ending the run outright; a qi deviation death is a rare tail risk, not an expected outcome.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.

- **Progress.** Level, realm and stage are always visible, with the Qi Refining layer
  (tầng) as well. The cultivation base bar shows its cost, the rate per season (as a
  breakdown) and the estimated seasons to the next level and to the bottleneck.
- **Breakthrough events.** Each small breakthrough prints the stage reached, the stat
  multiplier change and the points paid.
- **The bottleneck panel**, shown at great perfection:
  - whether the bar is full;
  - the realm's condition, met or not met, with the current value (for example "qi
    density 1.2 / 1.4", "heart demon 26 / 20");
  - the matching pill held and its quality;
  - talismans held, and "talisman: available" or "talisman: used this breakthrough";
  - attempts made in this realm step, and the failure insight they give the next pill
    attempt (+0.00 / +0.02 / +0.04);
  - the qi deviation chance if this attempt fails;
  - bare attempts used out of `bare_attempt_cap`.
- **Attempt preview.** Before any attempt, the full chance breakdown shows whether it will
  be a pill attempt or a bare one. A bare attempt needs an explicit confirmation. A pill
  attempt shows the toggle "use talisman on this attempt" (rule 8), on by default for the
  step's first pill attempt. The breakdown shows the failure insight line, and the
  q-extras clamp line when the extras exceed `q_extras_ceiling_pp`.
- **Warnings** (Advisor):
  - cultivation base that would be wasted at a full bar;
  - a pill held for the wrong bottleneck;
  - a slow root whose estimated time to the bottleneck exceeds its remaining lifespan;
  - brews still possible (B_remaining, Formulas D), the pills held and the chance of
    brewing no pill;
  - **the plant plan** (Formulas D; cross-GDD review 04g, F16): a one-click best-play
    layout, showing its planned B and S before sowing; a manual layout whose B is below
    the plan's gets a warning naming both ("this layout brews 0; the plan brews 2");
  - at a full bar with no pill ready, the years until the next brew ripens, with Time &
    Turn's "retreat until ripe" (Open Question 18);
  - what one more plot would add (B and S with +1 plot), so a field build is readable
    before it is chosen (Formulas D, fields as a build);
  - a lifespan pill or treasure whose years would all sit above the ceiling (rule 14).
- **Lifespan.** The lifespan line shows base, bonus (with a clamp line when above the
  ceiling, and the years held back), lifespan_pct and the cap. A change that would
  end the life shows the confirmation of rule 14.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Realm Ladder, Character Stats (draft formulas, heart demon, Dao heart) and Pillars 2–4 |
| `design/gdd/kinh-mach-do.md` | Points arithmetic (Formulas A), the breakthrough guard (E2, which now takes S_guard from Formulas H here), and capabilities #9, #22 and #23 hosted here; the ladder constants it reads (bonuses, shares) are owned and registered here |
| `design/gdd/linh-can.md` | The element-count curve (Formulas B), the generating-pair speed bonus (Formulas C), Mutation Awakening on `breakthrough_succeeded` (rule 9), and the birth mix the 0.30 / 0.70 targets average over (Formulas A) |
| `design/gdd/character-stats.md` | The stat sheet (`cultivation_speed_pct` stacking, Formulas I), the comprehension factor (Formulas J), the bonus ceilings and lifespan bonus (rule 14, Formulas I), comprehension, Dao heart, heart demon and vitality keys shared with this GDD |
| `design/gdd/cong-phap.md` | Technique speed `tech` in the rate (Formulas A, including the tier cap and crude floor), slot-dependent bonuses (rule 12) that rule 14's confirmation covers, and the breakthrough-preview ×0.25 warning |
| `design/quick-specs/progression-and-edges.md` | The 0.30 / 0.70 targets and the NPC edge curve. Its round-3 values (FE→CF pill 0.20, bare 0.005 / 0.01, heart demon +10, talisman +25) are superseded by Formulas C and F |
| `design/glossary.md` | Terms and realm abbreviations |
| `design/gdd/systems-index.md` | System 8; the changes proposed under Dependencies |
| `assets/data/cultivation_realms.json`, `character_attributes.json`, `crafting_talismans.json`, `items_recipes.json` | Data the parameter keys change |
| `src/gameplay/cultivation/cultivation_rules.gd`, `combat/combat_power.gd`, `world/world_ticker.gd`, `build/build_generator.gd` | Code that moves from stages to levels (Open Questions) |

## Acceptance Criteria

Drafted with `qa-lead`, which recomputed every GDD number.

- **Gate levels.** `project.yaml` sets no `testing.strict`, so Logic, Integration and UI
  are BLOCKING and Config/Data is ADVISORY.
- **Logic suites** live in `tests/unit/cultivation/` (for example `realm_ladder_test.gd`,
  `breakthrough_attempt_test.gd`, `realm_migration_test.gd`). They extend `DaoTestSuite`
  and use an injected seeded RNG; "RNG forced" means a stub whose next roll lands below or
  above q. Float tolerance is ±0.01 unless stated.
- **[Bot] items** are judged on the printed output of `tools/balance/autoplay.gd` or
  `npc_cohort.gd`.
- **UI evidence** is a debug-terminal transcript in
  `production/qa/evidence/debug-terminal/`.

**Ladder and cost**

- **AC-CG-01** [Logic] Rule 1.
  - Levels 1 and 39 are QR; 40 and 79 FE; 80 and 129 CF; 130 and 199 NS; 200 and 300 DT.
  - `level_cap` is 300, and a level outside 1–300 is clamped.
- **AC-CG-02** [Logic] Rule 2. Stage starts (t / h / hi):

  | Realm | t | h | hi |
  |---|---|---|---|
  | QR | 14 | 27 | 39 |
  | FE | 53 | 66 | 79 |
  | CF | 96 | 113 | 129 |
  | NS | 153 | 176 | 199 |
  | DT | 233 | 267 | 300 |

  For example FE 52 is early stage, 53 middle, 66 late and 79 great perfection.
- **AC-CG-03** [Logic] Rule 2. The QR layer label is ⌈L ÷ 3⌉: levels 1, 4, 14, 27 and 39
  give layers 1, 2, 5, 9 and 13. Level 14 is middle stage in layer 5, and level 27 is late
  stage in layer 9.
- **AC-CG-04** [Logic] Formula A, within 0.1 % relative. First / middle (level) / last
  climbing cost:

  | Realm | First | Middle (level) | Last |
  |---|---|---|---|
  | QR | 9.60 | 24.09 (20) | 57.60 |
  | FE | 78.67 | 136.26 (59) | 236.01 |
  | CF | 469.87 | 813.84 (104) | 1,409.60 |
  | NS | 2,194.04 | 3,800.19 (164) | 6,582.13 |
  | DT | 10,152.05 | 17,681.70 (250) | 30,456.15 |
- **AC-CG-05** [Logic] Formula A.
  - The climbing costs of each realm sum to `climb_total` within 1e-6 relative.
  - Bars are 230.40 / 2,360.11 / 14,096.04 / 65,821.26; DT has no bar.
  - Realm totals are 1,255.4 / 7,960.1 / 56,096.0 / 341,821.3 / 1,850,000.
- **AC-CG-06** [Logic] Rule 3, Formula A example. An FE character at level 60, bar 0,
  cultivating at an injected 31.25 per season:
  - after 4 seasons: level 60, bar 125.00;
  - after the 5th: level 61, bar 15.99.
- **AC-CG-07** [Logic] Rule 3.
  - The rate breakdown has one line each for base rate, root curve, technique,
    comprehension, qi density and toxicity, plus the speed bonus.
  - Base 25 with comprehension factor 1.25 (effective comprehension 50, Character
    Stats Formulas J) and the rest 1.0 gives 31.25; halving any one
    factor halves the total.
  - A +6 % speed bonus (two generating pairs) gives 33.125 (multiplied, Formulas I), not
    31.25 + 6; a total bonus of −150 % gives 0, never a negative rate.
  - With no speed bonus it matches the built output for the same inputs.
- **AC-CG-08** [Logic] Rule 3, several levels in one season.
  - QR level 13, bar 0, gains 40.18 → level 15, bar 5.00.
  - QR level 13 gains 336.52 → level 27, bar 1.00:
    - `stage_reached` fires twice, middle then late;
    - `level_gained` fires 14 times, ascending;
    - stage_mult ends at 1.30.
- **AC-CG-08a** [Logic] Rule 3, season-start rate. A five-element root at CF level 94
  (early stage; the middle stage starts at 96) gains enough in one season to reach level
  97. The whole season's gain uses `kd_so` (1.0), and the next season's rate uses
  `kd_trung` (1.8).
- **AC-CG-09** [Logic] Rule 7, overflow.
  - QR level 38, bar 0, gains 357.60 → level 39 with the bottleneck bar full at 230.40,
    and 69.60 reported wasted.
  - A further 50 is reported wasted.
- **AC-CG-10** [Logic] Edge case: at QR 39 with a full bar, an event grant of 100 and a #9
  grant are both lost and reported as wasted.
- **AC-CG-11** [Logic] Rule 15. At level 300 the state is Capped:
  - cultivating 1,000,000 changes nothing;
  - no bottleneck is set, no attempt is offered, and no event fires.
- **AC-CG-12** [Logic] Rule 4. The stat sheets at FE 41 and 52 are identical, and so are
  FE 53 and 65.

**Stage multiplier**

- **AC-CG-13** [Logic] Formula B.
  - QR 13 / 14 / 26 / 27 / 38 / 39 → 1.00 / 1.15 / 1.15 / 1.30 / 1.30 / 1.45.
  - The same pattern holds at every realm's boundaries.
  - Levels 40, 80, 130 and 200 are 1.00.
- **AC-CG-14** [Integration] Rule 6. At FE 66 the stat sheet receives 1.30. Spiritual
  power, divine sense, vitality and the combat power realm term each equal FE base × 1.30.
- **AC-CG-15** [Integration] Formula B example.
  - At CF 129 the combat power realm term is 14,500.
  - After the breakthrough, NS 130 is 100,000 at multiplier 1.00.
- **AC-CG-16** [Logic] Rule 6. Innate talents are identical at QR 1, FE 79 and CF 80.
- **AC-CG-17** [Config/Data] `stage_power_step` is 0.15. For every adjacent pair of
  realms and all four stats, next base ÷ (base × 1.45) > 1.45.

**Attempts**

- **AC-CG-18** [Logic] Rules 7–8.
  - At 99 % of the bottleneck bar an attempt is refused: nothing is burned, no season
    passes and no RNG is drawn.
  - At 100 % it is allowed.
  - Below great perfection no attempt is offered.
  - The one exception is #23's extra roll (AC-CG-49), which is made with a partly refilled bar.
- **AC-CG-19** [Logic] Formula C example. FE→CF with a rank-1 pill, comprehension 40, Dao
  heart 30, tree 0.02 and the realm step's talisman, on the step's first pill attempt:
  - q = 0.1575;
  - the breakdown names "pill attempt" and "condition met", with lines 0.045 / 0.015 /
    0.020 / 0.0075 / 0.02 / failure insight 0 / 0.05.
- **AC-CG-20** [Logic] Formula C table, with E = 0.0625 (recomputed after cross-GDD review
  04g).
  - Baseline q_pill on a step's first pill attempt: 0.1025 / 0.1075 / 0.0825 / 0.085.
  - With q_destiny 0.12: 0.2225 / 0.2275 / 0.2025 / 0.205.
  - With the bonus and the talisman: 0.2725 / 0.2775 / 0.2525 / 0.255.
- **AC-CG-21** [Logic] Rule 8, bare attempt. No pill held, but comprehension 100, Dao heart
  100, tree 0.08, two talismans, the Đạo Cốt perk and an event bonus:
  - q is exactly 0.004 / 0.0037 / 0.0037 / 0.003;
  - the breakdown shows "bare attempt" and no other term;
  - after a forced success or failure, the talisman and pill counts are unchanged.
- **AC-CG-22** [Logic] Rule 8. A pill attempt holding 2 pills and 3 talismans ends with 1
  pill and 2 talismans, whether the RNG is forced to success or to failure. The talisman
  term is +0.05.
  - The step's first pill attempt shows "use talisman on this attempt" on by default.
    With it turned off, that attempt burns none and has no talisman term, and the next
    pill attempt shows the toggle on.
  - A second pill attempt in the same realm step (forced failure first) ends with 0 pills
    and still 2 talismans, has no talisman term (and a failure insight term of +0.02), and
    its preview says "talisman already used this breakthrough". After a forced success, the next realm step's first pill
    attempt may use one again.
  - With capability #13 forced to keep the talisman, the count stays 3 and the step is
    still marked used.
  - #23's extra roll after a talisman-free failed attempt has no talisman term and burns
    none.
  - A gift pill attempt with the toggle on has the +0.05 term.
  - With #22 acting on the talisman attempt, the attempt's chance is q_desp + 0.05
    (q_desp from the attempt's chance without τ, with E2's (1 − q − τ) guard term).
- **AC-CG-23** [Logic] Edge cases.
  - Holding rank-1 and rank-3 FE→CF pills burns the rank-3 one; the quality term is 0.045.
  - Holding only a QR→FE pill at the FE→CF bottleneck makes the attempt bare (0.0037), and
    that pill is not burned.
- **AC-CG-24** [Logic] Formula C clamp.
  - A raw 0.9625 is clamped to 0.95.
  - A raw 0 is clamped to 0.01.
  - A bare 0.0037 stays 0.0037.
- **AC-CG-25** [Logic] Rule 8. Tree-sourced `breakthrough_chance` of 12 pp counts as 8 pp
  (q_tree 0.08). With the other typical extras (0.0425) the q extras sum to 0.1225, which
  the q-extras ceiling clamps to 0.10, so the FE→CF first-attempt q = 0.145 and the
  breakdown shows the clamp line. A destiny-perk bonus (Đạo Cốt 0.12) is a separate
  q_destiny term outside that ceiling: q = 0.265 (Character Stats rule 14).
- **AC-CG-26** [Logic] Rule 9. A forced FE→CF success at level 79 leads to:
  - level 80, bar 0, full vitality;
  - CF bases at multiplier 1.00;
  - the lifespan cap raised from 200 to 500 plus the lifespan bonus (rule 14; with a
    stored bonus of 40, the cap goes from 200 + 30 = 230 to 500 + 40 = 540);
  - the bottleneck flag cleared;
  - `breakthrough_succeeded` fired once.
- **AC-CG-27** [Logic] Rules 8 and 11.
  - Every attempt takes exactly one season, except #23's extra roll, which resolves in the same season as the failed attempt.
  - 25 pill attempts, each made after the bar refills (deviation forced off), are all
    accepted: no cap exists on pill attempts. (Bare attempts are capped: AC-CG-40a.)
- **AC-CG-28** [Logic] Edge case. A character whose lifespan cap is reached this season
  attempts:
  - forced success → alive, with the new realm's cap;
  - forced failure → dies of old age.

**Supply and success**

- **AC-CG-29** [Logic] Formulas D and E (rewritten 04f for discrete brews; recomputed
  2026-11-04 after cross-GDD review 04g).
  - For a root-free life (3 plots, h 1), C_k for k = 1 / 2 / 3 / 4 is 40 / 80 / 90 / 120
    (2 × 40 + 10), 42 / 84 / 102 / 144 (2 × 42 + 18), 120 / 180 / 250 / 360 (4 × 60 +
    10) and 200 / 360 / 480 / 660 (4 × 100 + 80).
  - So, by packing alone, root-free B at W 104 / 116 / 342 / 645 is 3 at every gate, and
    at W 104 / 94 / 310 / 540 it is 3 / 2 / 3 / 3.
  - Counting rule: FE→CF, 3-element root, entry age 80 → attempts could start at 128,
    164 and 182, B = 3. NS→DT, single root, entry age 520 (W 480): packing gives 3, but
    the climb ends at 976 and r = 23.4 ÷ 4 × 456 ÷ 97 + 0.25 = 27.75, so the second attempt
    would start at 1,003.75 > 999.75 and B = 1.
  - FE→CF with Wood 40 at entry 80: h = 1.32, T_4 = 144 ÷ 1.32 = 109.1, B = 4.
  - `herb_growth_pct` −150 → h 0 → B 0, with no division performed (cross-GDD review 04g,
    S1).
  - Earth 25 / 49 / 50 / 100 gives n_plots 4 / 4 / 5 / 7; Fire 100 with p_brew0 0.70 gives
    p_brew 0.95 (clamped).
  - Wood 40, Fire 86 with `alchemy_success` 3 at QR→FE: p_brew = 0.895;
    `alchemy_success` 12 is clamped by Character Stats to 3 first, so the same.
  - S for root-free B 3 with failure insight: 0.2079 at QR→FE (q 0.1025, p_brew 0.65) and
    0.2128 at FE→CF (q 0.1075, p_brew 0.64); with insight off, 0.1869 at QR→FE. QR→FE
    with G = 1: 0.3148; with the talisman (τ 0.05) on the first pill attempt, 0.2496.
  - The birth-mix mean S from the entry-age model (Formulas D; seed 20261104, 20,000 lives
    per element count) is 0.299 / 0.302 / 0.298 / 0.301 (±0.003).
  - P_C 0.6 at QR→FE, B 3, p_brew 0.65: 0.1247.
  - The known-pills form with two pills at QR→FE's first-attempt q 0.1025 (the second at
    0.1225 with insight) gives 0.2124.
- **AC-CG-30** [Bot] Formula E. `autoplay.gd --edge off`, run to ≥ 330 bottleneck arrivals
  per gate, with roots rolled by the birth mix: each gate's mean crossing rate is
  0.25–0.35. Bare successes count. Bot policy: capabilities #22 and #23 disabled, no
  talisman, the tree as the bot allocates it, techniques as the typical loadout (Formulas
  D, calibration loadout) with no plot node from the tree (cross-GDD review 04g, F11),
  failure insight on, `field_plots` 0, and **plots at best play** (the Advisor's plant
  plan): every plot that raises B goes to the breakthrough recipe from the moment its
  herbs are plantable. `pill_chance` is tuned on this run. Per tier (`--elements 1..5`,
  ≥ 330 arrivals each), each gate is within ±0.05 of the Formulas E row (0.25 / 0.30 /
  0.36 / 0.42 / 0.49 at QR→FE).
- **AC-CG-31** [Bot] The same with `--edge on`: each gate's mean is 0.65–0.75, and each
  tier is within ±0.05 of the Formulas E edge row. Until the Heavenly Tribulation exists,
  the DT roll is held to 0.30 / 0.70.
- **AC-CG-32** [Bot] Alternative to 30–31: the mean of the analytic per-life S over ≥ 50
  lives per arm is in the same windows. This needs per-life B, p_brew and q logging, which
  `autoplay.gd` does not have yet. The analytic S uses the same discrete B as the bot, so
  the two cannot disagree by model (cross-GDD review 04f, C1).
- **AC-CG-33** [Bot] `climb_total` ceiling. `autoplay.gd --elements 1` over ≥ 50 lives:
  the median years to clear each realm is at most 60 / 100 / 250 / 500 / 1,000.
- **AC-CG-33a** [Bot] `climb_total` ceiling for five elements. `autoplay.gd --elements 5`
  over ≥ 50 lives: the median years to clear QR is at most 60 (the half-lifespan
  ceiling), at the current totals and at `climb_total` +19 %. Expected about 44 at the
  current totals, with the full pair bonus and Cultivation Techniques' `count_gain` 1.27
  (its Formulas A, AC-CP-47). Extend to FE and CF after the first run.

**Failure and heart demon**

- **AC-CG-34** [Logic] Rule 10. A forced failure at the FE→CF gate (bar 2,360.11, heart
  demon 0, vitality 75 % of maximum, deviation forced off):
  - bar 1,652.08, heart demon 15, vitality 35 %;
  - level 79 with points unchanged;
  - state "at great perfection, refilling".
- **AC-CG-35** [Logic] Rule 10. Vitality at 12.5 % falls to the 5 % floor.
- **AC-CG-36** [Logic] Rule 10.
  - The heart demon gain lands before the deviation roll.
  - The deviation chance is 0 % at heart demon 15 / Dao heart 30, 13 % at 28 / 30, and 0 %
    (never negative) at 10 / 40.
  - A deviation that hits at heart demon below 90 sets vitality to 5 %.
  - Death needs a deviation hit and heart demon ≥ 90 after the gain. With the roll forced
    on, 90 kills and 89.75 leaves vitality at 5 %. With the roll forced off, heart demon
    95 survives with no vitality change beyond rule 10's 40 % loss.
- **AC-CG-36a** [Bot] Rare tail risk. Over ≥ 330 arrivals per gate (edge off), deaths by qi deviation are at most 1 % of failures; the count is printed.
- **AC-CG-37** [Logic] Rule 10. With safe failure, the bar is unchanged and heart demon
  rises by 7.5 (a decimal).
- **AC-CG-38** [Logic] Rule 11. A failed bare attempt takes the full rule 10 penalties and
  burns no pill.
- **AC-CG-39** [Logic] Formula F.
  - Δhd = 13.15 / 11.85 / 11.375 / 9.15, so n_90 = 7 / 8 / 8 / 10.
  - Heart demon 15 decays to 0 in 60 seasons.
- **AC-CG-40** [Config/Data] Every `base_chance` ≤ 0.01, and `bare_attempt_cap` is 3, so 1 − (1 − base_chance)^3 is 0.0119 / 0.0110 / 0.0110 / 0.0090 and never above 0.03.
- **AC-CG-40a** [Logic] Rule 11, bare cap. At the FE→CF gate with no pill, the 1st, 2nd and 3rd bare attempts are accepted (each after the bar refills, deviation forced off, heart demon waited down to 0). The 4th is refused: no season passes, no RNG is drawn, and the preview says "bare attempts used up". A pill attempt is still accepted. A #23 extra roll does not count toward the cap. A successful breakthrough resets the count; waiting 100 years and a stage loss (#5) do not.
- **AC-CG-40b** [Bot] A "patient bare grinder" policy (waits 15 years after each bare failure, never uses pills) over ≥ 330 arrivals per gate crosses at most 0.012 of the time at each gate, within the ±0.05 tolerance.

**Conditions**

- **AC-CG-41** [Logic] Rule 7, FE. A held FE pill alone makes a pill attempt.
- **AC-CG-42** [Logic] Rule 7, CF.
  - Density 1.40 is met; 1.39 is not.
  - Home 1.0 with a level-3 gathering formation (1.45) is met; with level 2 (1.30) it is
    not.
  - A lapsed formation counts 0.
  - A spirit vein inside a secret domain counts while the character is there.
- **AC-CG-43** [Logic] Rule 7, NS. Heart demon 20 is met; 20.25 is not.
- **AC-CG-44** [Logic] Rule 7, DT.
  - With no insight the attempt is bare; with an insight it is a pill attempt.
  - An insight gained at NS 150 counts, and it remains after a failure.
  - With no Tribulation system, a success reaches level 200 and `breakthrough_succeeded`
    fires once, on the roll.
- **AC-CG-45** [Logic] Edge case. At the FE→CF gate holding a pill and a talisman, at
  density 1.39:
  - the preview says "condition not met", shows q 0.0037, says it uses one of the `bare_attempt_cap`
    bare attempts and how many remain, and asks for confirmation;
  - declining → no season passes and no RNG is drawn;
  - confirming → a bare attempt, with the pill and talisman counts unchanged.
- **AC-CG-46** [Integration] Edge case. The condition is evaluated exactly once, at the
  start of the attempt, before anything burns. Heart demon rising from 20 to 35 during the
  season does not change the attempt.

**Capability hooks**

- **AC-CG-47** [Logic] Rule 16, #9.
  - A defeat in FE early stage adds 61.18 (5 % of 1,223.57); in QR middle stage, 15.92.
  - At great perfection it uses the bottleneck bar; when Capped it adds 0.
  - [Integration] The heart demon +2 arrives through Character Stats.
- **AC-CG-48** [Logic] Rule 17, #22.
  - With 4.75 years left the next pill attempt uses q_desp (from the Meridian Map); with
    5.00 years left it does not.
  - A bare attempt neither uses nor spends it.
  - It applies once per realm step and never on a step where #23 was used.
- **AC-CG-49** [Logic] Rule 18, #23.
  - burn_cost is 10 / 10 / 25 / 50 at the four gates.
  - At CF→NS it is not offered with 25.00 years left, and is offered with 25.25.
  - The extra roll burns no pill, inherits the failed pill attempt's condition result (a
    Nascent Soul attempt at heart demon 18 that fails, leaving 33, still gets the roll) and
    uses q_retry.
  - It is not offered after a failed bare attempt.
  - A failed roll takes the rule 10 penalties and is logged.
  - It is offered once per realm and never on a step where #22 was used.
  - The roll's chance includes the step's failure insight (after one failed pill attempt,
    +0.02), and its forced failure raises the next pill attempt's insight to +0.04.
- **AC-CG-50** [Logic] Formula H.
  - One failed attempt at a fixture q of 0.3625 with no pills: S_guard = 0.3625. (The
    value is a test fixture, not a calibrated life; an edge life at FE→CF with the
    talisman and the tree at its cap has 0.315, its q extras clamped to 0.10.)
  - Adding one held pill with the condition met, counted at the step's current failure
    insight (+0.02, so 0.3825): 0.6063. An unmet-condition pill and bare attempts are
    excluded.
  - Six failures (attempts at 0.3625 / 0.3825 / 0.4025 / …) → 0.9498; seven → raw
    0.9700, capped at 0.95.

**Cross-system contracts**

- **AC-CG-51** [Integration] A real Meridian Map subscriber receives:
  - one `level_gained` per new highest level, ascending;
  - one `stage_reached` per small breakthrough;
  - one `breakthrough_succeeded` per success.

  Nothing fires on a failure, a bare failure or a stage loss, and re-climbing after a
  stage loss fires nothing. A real Spiritual Roots subscriber, subscribed at the same
  time, receives the same `breakthrough_succeeded` events, one per success. A fated NPC's
  stage advance or breakthrough (AC-CG-53) fires no `breakthrough_succeeded` event for
  either subscriber.
- **AC-CG-52** [Integration] For the AC-CG-50 state, the Meridian Map's guard reads S_guard
  from this system and, with the failure-insight term (Formulas H; ι 0.02), computes
  q_retry = min(0.3825, 0.08 ÷ 0.6375) = 0.1255 and a roll lift of 0.080.

**NPCs**

- **AC-CG-53** [Logic] Rule 12. A fated NPC's per-season break-through chance is `fated_breakthrough_per_season` (0.08) and its per-season stage chance is 1 ÷ 12.
  - p_step = 0.30 / 0.50 / 0.70 / 0.70 for e = 0 / 0.5 / 1 / 2.
  - An NPC's level is the first level of its stage: FE middle → 53, CF late → 113, NS
    great perfection → 199.
  - Exactly one fate roll per realm, even over 40 ticks at the bottleneck.
  - A fated NPC that dies first is recorded as having died at the bottleneck.
- **AC-CG-54** [Bot] `npc_cohort.gd --size 330`: no-edge steps 0.25–0.35 and all-edge steps
  0.65–0.75 at each step.

**Stage loss, persistence and migration**

- **AC-CG-55** [Logic] Edge case, stage loss.
  - FE 70 → 53.
  - FE 79 at the bottleneck → 66, with the flag cleared.
  - FE 45 → 40, CF 80 → 80, QR 1 → 1. It never crosses a realm.
  - The bar becomes 0, stage_mult is recomputed (1.30 → 1.15), and points are unchanged.
- **AC-CG-56** [Integration] A save/load round trip keeps exactly the level, bar,
  bottleneck state, attempt log (same S_guard), insight, failure insight count, bare
  attempts used, the flag
  "talisman used this breakthrough" and #22 / #23 use.
- **AC-CG-57** [Logic] Old-save migration.
  - FE middle stage at fraction 0.5 → level 59.
  - CF late stage at 0.99 → 128.
  - CF great perfection at 0.5 → 129.
  - A fraction that would pass the last climbing level → great perfection with a full
    bar.
  - QR layer 5 at 0.5 → level 14.
  - A great-perfection save with a partial bar keeps the fraction: bar = fraction × the bottleneck bar.
  - Unspent points = points_total(level) − spent, never below 0.
  - The migration is logged once; a second load logs nothing.
- **AC-CG-58** [Config/Data] A data test of `cultivation_realms.json`:
  - `bare_attempt_cap` is 3, `great_breakthrough_bonus` is [15, 25, 40, 60] and the shares `pct_trung` / `pct_hau` / `pct_dai` are 15 / 25 / 35 (this GDD owns them; the Meridian Map reads them), the shares sum to at most 100;
  - the bands are contiguous over 1–300;
  - every Parameter key has its GDD value, and the conditions match Formula G;
  - `stage_curve_groups` match Parameter keys for all five realms (QR `[lk_early, lk_mid,
    lk_late, lk_late]`, NS `na` ×4, DT `ht` ×4), and `stage_power_step` is one global key;
  - `tu_vi_required` and `tree_points_per_stage` are absent;
  - the five failure and death keys (Parameter keys, global) hold 0.30 / 0.40 / 0.05 / 90 /
    2.0;
  - `tam_ma_natural_decay` is 0.25, `pha_canh` is 5 with `per_realm_step` 1,
    `pill_chance` is 0.04 / 0.045 / 0.02 / 0.0225, `failure_insight_pp` is 2,
    `failure_insight_cap` is 4 and `q_extras_ceiling_pp` is 10;
  - the breakthrough recipes are 2 ginseng at 40 + 1 at 10, 2 Kim Tủy Quả at 42 + 1 at 18,
    4 at 60 + 1 at 10, and 4 at 100 + 1 at 80;
  - the brew guarantee: for every breakthrough recipe, a root-free life (3 plots, h 1)
    gets B ≥ 2 by packing at the 10th-percentile W (104 / 94 / 310 / 540) and B ≥ 3 at the
    median W (104 / 116 / 342 / 645), so each main herb's `min_age` is at most 47 / 46 /
    82 / 141 at its qty (Formulas D).

**UI (debug terminal transcripts)**

- **AC-CG-59** [UI] Transcripts show:
  - at each of the four bottlenecks, the attempt preview with the attempt kind, the
    condition met or unmet with its value, every breakdown term and the clamped total;
  - one transcript with the bare-attempt confirmation;
  - a multi-level season listing every level and stage;
  - wasted cultivation base at a full bar;
  - the Capped message at level 300;
  - the Advisor's years-to-bottleneck against years left;
  - the Advisor's warning before a cultivation pill at a full bar.
- **AC-CG-60** [Bot] Formulas D, bonus ceilings. `autoplay.gd --edge off`, ≥ 330
  bottleneck arrivals per gate, roots by the birth mix with Mutation Awakening off (no
  root factor beyond Wood, no craft mutation's raised ceiling; cross-GDD review 04g, C5
  and F15), with auxiliary arts, items and pills chosen to push `herb_growth_pct`,
  `alchemy_success` and the lifespan bonus to their Character Stats ceilings (10 / 3 /
  15 %), plots at best play, `field_plots` 0 with no plot node from the tree (F11),
  failure insight on, #22 and #23 off, and the realm step's one talisman (5 pp) used.
  Each gate's mean crossing rate is ≤ 0.48 (`bonus_ceiling_target` 0.45 + 0.03;
  entry-age model values 0.44 / 0.46 / 0.45 / 0.45, Formulas D, accepted inside this
  tolerance by user decision 2026-11-04), and the transcript shows the clamp lines.
  Field builds, root factors and holders are outside the ceiling target by design (user
  decisions 2026-11-04; +1 plot gives 0.52–0.55, `max_plots` 12 gives 0.78–0.88). If a
  gate is over, lower the Character Stats `bonus_ceilings`, not the recipes or
  `pill_chance`. **Run order:** this run uses the `pill_chance` that AC-CG-30 set; run
  AC-CG-30 first, then this one.
- **AC-CG-61** [Logic] Rule 14, lifespan cap.
  - QR (base 120), pill 10, two `lifespan_years` 15, `lifespan_pct` 0: bonus min(40, 18)
    = 18, cap 138, with a clamp line showing 22 years held back.
  - The same character at FE (base 200) after a forced success: bonus min(40, 30) = 30,
    cap 230.
  - FE, bonus 25, `lifespan_pct` +10: cap (200 + 25) × 1.10 = 247.5.
  - Age 137.75 at the QR cap of 138 is alive; at 138 the character dies of old age.
  - #23 adds burn_cost to age: QR, raw bonus 40 (18 counted), age 100, cap 138; burning
    10 gives age 110 with the cap still 138, so 28 years remain. The held-back years do
    not absorb the burn.
- **AC-CG-62** [Logic] Rule 14, confirmation. QR, age 130, cap 135 (bonus 15 from one
  slotted art):
  - unslotting the art shows a preview naming cap 120 and death, and asks to confirm;
  - declining → the art stays slotted, no season passes, no RNG is drawn;
  - confirming → the character dies of old age before the season's cultivation, and the
    log names the change;
  - at age 110 the same unslot needs no confirmation and shows cap 120;
  - a main-method switch that lowers an art's harmony and so its `lifespan_years` takes
    the same path, and so does unequipping a treasure.
- **AC-CG-63** [UI] Transcripts show the lifespan line with a clamp, the Advisor warning
  before a lifespan pill whose years would all sit above the ceiling, and the rule 14
  confirmation.

**Failure insight, q-extras ceiling and plant plan** (added after cross-GDD review 04g)

- **AC-CG-64** [Logic] Rule 10, failure insight. At the FE→CF gate (q 0.1075), with four
  pills and no talisman, attempts forced to fail:
  - the first pill attempt's breakdown shows failure insight +0.00 and q 0.1075, the
    second +0.02 (0.1275), the third and fourth +0.04 (0.1475);
  - a failed bare attempt between them leaves the insight unchanged, and a bare
    attempt's breakdown has no insight line;
  - #23's extra roll after the first failed pill attempt uses +0.02, and its forced
    failure makes the next pill attempt +0.04;
  - a stage loss (#5) and 100 years of waiting keep it; a forced success resets it to 0
    for the next realm step;
  - with insight at +0.04 and a raw q of 0.93, the total clamps to 0.95.
- **AC-CG-65** [Logic] Formula C, the q-extras ceiling. FE→CF first pill attempt with pill
  rank 5 (0.075), comprehension 150 (0.075), Dao heart 100 (0.025), tree 0.08 and an event
  bonus 0.05: the extras sum to 0.305 and count as 0.10, so q = 0.145; the breakdown lists
  each extra and the clamp line "q extras 0.305, ceiling 0.10". Adding Đạo Cốt (0.12) and
  the talisman (0.05) gives 0.315. With the typical extras (0.0625) nothing clamps and q
  = 0.1075.
- **AC-CG-66** [Logic] Formulas D, the plant plan. FE→CF, a root-free 3-element life
  entering at 106 (W 94), 3 empty plots:
  - the Advisor's plan is the staggered layout (K-K-C, K-C-K, C-K-K), with planned B 2
    and S 0.140 shown before sowing;
  - a manual layout of K-K-C in every plot scores B 0 and triggers the warning naming 0
    against the plan's 2; C-K-K in every plot scores B 1 (S 0.069) and also warns;
  - a manual layout with the plan's B gives no warning.
- **AC-CG-67** [UI] Transcripts show the failure insight line and the q-extras clamp line
  in an attempt preview, and the plant plan with its planned B and S and the warning for
  a worse manual layout.

**Still provisional:**
- The Deity Transformation success criteria stand until the Heavenly Tribulation GDD
  exists.
- Pacing guesses (T_r, W, p_brew) are testable only through AC-CG-33 and the bot targets.
- Bot items 30–33 and 54 need the tooling gaps closed: per-life B, p_brew and q logging,
  a best-play plot policy, and a cohort size of at least 330.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | What lies beyond Deity Transformation? Deferred by the user (the Meridian Map's Open Question 2) | user | Nothing for now |
| 2 | The Heavenly Tribulation's survival chance p_t, which sets the Deity Transformation roll target (0.30 ÷ p_t) | Heavenly Tribulation GDD | Formulas E for Deity Transformation |
| 3 | ~~When can a baseline life craft a breakthrough talisman?~~ **Answered 2026-11-04 (cross-GDD review 04f):** the talisman is no longer in the baseline at any gate. It is a crafted build bonus limited to one per realm step (rule 8), and AC-CG-60's ceiling run includes it | — | — |
| 4 | The Nascent Soul and Deity Transformation pill recipes: proposed 4 herbs at 60 + 1 at 10 and 4 at 100 + 1 at 80 (Formulas D; changed 2026-11-04 after cross-GDD review 04g, F2, from 2 × 130 + 40 and 2 × 230 + 80; guesses), including a new top-rarity herb for Deity Transformation. Each recipe must meet the brew guarantee (main herb `min_age` ≤ 82 for NS and ≤ 141 for DT at qty 4). The shorter herbs cut the years at a full bar up to the third attempt from 234 to 184 at CF→NS and from 431 to 371 at NS→DT (54 % and 57 % of W, against 48 % and 41 % at the first two gates). F2 is accepted as partial (user decision 2026-11-04): the rest of the wait stays while B is 3 at the median, and Time & Turn owes a one-click "retreat until ripe" (Open Question 18) | Item DB, economy-designer | Those two gates |
| 5 | Fortuitous encounter weights that give the edge about 1.2–1.4 gift pills per gate (1.42 / 1.19 / 1.35 / 1.29, an expectation; recomputed after 04g) | Progression Edges | The edge's 0.70 |
| 6 | ~~How fast killing adds heart demon~~ **Answered 2026-11-04 by Character Stats:** kills add none (user decision) | — | — |
| 7 | ~~The realm bases with the stage multiplier~~ **Answered 2026-11-04 by Character Stats (Formulas C):** unchanged; every great-breakthrough jump stays ≥ ×2.07 | — | — |
| 8 | The move from stages to levels in code: `cultivation_rules.gd` (cost curve, pill vs bare attempts, conditions), `combat_power.gd`, `world_ticker.gd` (NPCs advance by 4 stages, including in Qi Refining), `build_generator.gd` (`tree_points_for`), the terminal views, the Advisor, the event context and save migration | implementation story | Building this GDD |
| 9 | The data still holds the built recipes (FE pill: 1 ginseng at 30; CF pill: 1 Kim Tủy Quả at 100), the built `pill_chance` (0.06 / 0.20 / 0.20 / 0.15) and one 10 pp talisman per attempt. The implementation story changes them to Parameter keys (FE pill 2 × 40 + 10, CF pill 2 × 42 + 18, NS pill 4 × 60 + 10, DT pill 4 × 100 + 80, `pill_chance` 0.04 / 0.045 / 0.02 / 0.0225, `failure_insight_pp` 2, `failure_insight_cap` 4, `q_extras_ceiling_pp` 10, `pha_canh` 5, one per step), and the herb texts to "forty years" and "forty-two years". AC-CG-58 fails until then | Item DB, implementation story | Data consistency |
| 10 | The Deity Transformation baseline P_C: how often a baseline life gets an enlightenment event that grants the insight, and the matching event rate (needed to verify AC-CG-31) | Event Engine, calibration (bot) | Formulas E for Deity Transformation |
| 11 | Duplicate keys with Character Stats: `vitality_floor` (here `breakthrough.vitality_floor`, there `derived.vitality_floor`) and `tam_ma_natural_decay` (listed in both Parameter keys). This GDD owns the values; Character Stats should read them and drop its copies, and its AC-CS-36 / AC-CG-58 then agree | Character Stats | Data consistency |
| 12 | Herb growth from knowledge and affinity: the curve by which Spirit Fields craft mastery adds `herb_growth_pct` (counted under Character Stats' ceiling of 10), and whether a root holding a herb's own element (Metal for Kim Tủy Quả) should also speed that herb, beyond Wood's general term. An own-element term would be a root term, so it would bypass the ceiling; it must still stay inside `bonus_ceiling_target` (AC-CG-60) | Spirit Herbs & Spirit Fields, user | Formulas D growth term |
| 13 | ~~The q extras at low base odds (cross-GDD review 04f): pill quality, comprehension, Dao heart and the tree (up to 0.075 / 0.075 / 0.025 / 0.08) carry far more weight at a low baseline q. Should AC-CG-60 include them, and should their per-point values or the `tree_breakthrough_cap` shrink?~~ **Answered 2026-11-04 (user decision, cross-GDD review 04g, F14):** a character-wide `q_extras_ceiling_pp` of 10 caps their sum (Formulas C). A fully built life with no edge reaches 0.52–0.55 per gate (0.76–0.81 uncapped), and edge plus full build 0.83–0.86 (0.94–0.96 uncapped). Đạo Cốt and other destiny perks, the talisman and failure insight are outside it. **`field_plots`** was answered earlier the same day: fields are a build (user decision; Formulas D, AC-CG-60), and the tree gives no plots at its launch values | — | — |
| 14 | Diên Thọ Đan shares Kim Tủy Quả with the CF pill (cross-GDD review 04f, C6), so both compete for FE plots, and a lifespan pill raises W and so can add a brew. The bot does not grow it at gates for now (Formulas D). Should the bot plan it, and should the lifespan pill take a different herb? | Item DB, economy-designer | AC-CG-30 bot policy |
| 15 | Growth pays in steps under discrete brews (cross-GDD review 04f, F7), but the Meridian Map prices `herb_growth_pct` (0.9 W per %), `field_plots` (10 W) and lifespan linearly. Should those prices follow the steps? Under the q-extras ceiling (04g, F14), the tree's `breakthrough_chance` also stops paying past about 5.75 pp on a typical life (the other extras are 4.25 pp of the 10), so its price may need to follow the ceiling too | Meridian Map, user | Meridian Map Formulas F prices |
| 16 | ~~The talisman with #22 (rule 8): the Meridian Map's E2 guard divides by 1 − q, so a talisman on the same attempt lets #22 lift S by up to δ_max · (1 − q) ÷ (1 − q − τ) = 0.106 at q 0.1225. Should E2 use 1 − q − τ in its fourth term (which restores the 0.10 bound exactly), or should a talisman be barred from #22's attempt?~~ **Answered 2026-11-04: the Meridian Map's Formulas E2 now uses (1 − q − τ) in the #22 guard term when a talisman is on the attempt, so the lift stays at δ_max (user decision).** Rule 8 agrees | Meridian Map, user | AC-KMD guard bound with a talisman |
| 17 | ~~#23 and failure insight (rule 18, Formulas H): the extra roll's failure adds +0.02 to the next pill attempt, outside the Meridian Map's q_retry term, so #23's lift could exceed δ_max (worst case 0.1009 at the CF→NS baseline, 0.111 at q 0.30).~~ **Answered 2026-11-04 (user decision):** the Meridian Map's E2 uses q_retry = min(q, (δ_max − ι) ÷ (1 − S)), ι the insight the roll's failure would add (0.02, or 0 at the cap), which restores the bound by construction (0.097 and 0.092 in those cases). Applied in kinh-mach-do by its owner | — | — |
| 18 | Time & Turn's one-click "retreat until ripe" (cross-GDD review 04g, F2, accepted as partial): at a full bar the years waiting for herbs stay at 54 % (CF→NS) and 57 % (NS→DT) of W for a root-free 3-element life at the median W (48 % and 41 % at QR→FE and FE→CF). The wait must cost no attention: one action advances seasons until the next brew can be made or an event, attack or warning needs the player. What interrupts it, and how it shows the years skipped? | Time & Turn, Guidance Layer | Pillar 4 at the CF and NS bottlenecks |
