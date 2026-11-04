# Realms & Bottlenecks (Cảnh Giới & Bình Cảnh)

> **Status**: Approved (2026-11-04, fifth lean /design-review, after the cross-GDD review blockers C1 and D1 were applied). See `reviews/canh-gioi-review-log.md`.
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
risk. Pill supply, set by herb aging, tunes the odds so about 3 in 10 lives cross each
bottleneck at baseline and about 7 in 10 with the player's edge.

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
     chance, plus pill quality, comprehension, Dao heart, the tree's breakthrough chance
     (capped by the Meridian Map's `tree_breakthrough_cap`, 8 pp, which limits the
     tree's own contribution only) and item and event bonuses (destiny perk [thiên mệnh], one
     breakthrough talisman, fortuitous encounters [cơ duyên]), clamped to 1%–95%. It burns
     the best matching pill and the talisman, whether it succeeds or not.
   - **Bare attempt** (no pill, or the condition is unmet): the realm's bare chance only.
     No talent, tree, talisman or event bonus applies, and no pill is burned. A failed
     bare attempt still takes rule 10's penalties. A bare attempt is near-hopeless by
     design.

   A breakthrough talisman boosts only a pill attempt.
9. **Success.** The character enters the early stage of the next realm: level +1, bar 0,
   vitality full, stats at the next realm's bases, lifespan cap (thọ nguyên) raised to the
   new realm's, and the great breakthrough bonus points paid (the bonus minus the `pct_dai` (35 %)
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
    beyond its maximum realm works at ×0.25), event and reward budgets (Pillar 2), pill and
    item gating, and price tiers. The level matters for points and the stage multiplier
    only.
14. **Lifespan.** The cap is the realm's lifespan plus pill and treasure bonuses plus
    lifespan_years, times (1 + lifespan_pct), as built. At age ≥ cap the character dies of
    old age.
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
    At most one of #22 and #23 acts per realm step.

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
| Any | Dead | Age reaches the lifespan cap | Old age |

### Interactions with Other Systems

Character Stats (`character-stats.md`), Spiritual Roots (`linh-can.md`) and the Meridian
Map have GDDs. Time & Turn, Item DB and the other systems below have none yet, so their
interfaces are provisional.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Character Stats | out / in | out: realm, level, stage multiplier (bases for spiritual power, divine sense, vitality, the combat power realm term); in: comprehension, Dao heart, and the stat sheet's `breakthrough_chance` | Character Stats (stat keys, units); this GDD (the ladder) |
| Spiritual Roots (Linh Căn) | in / out | in: base element count (mutations excluded) and the curve factor, looked up by realm and stage. Out: the `breakthrough_succeeded` event (player only, rule 9), which triggers Mutation Awakening (its rule 9; capability #24) | Spiritual Roots (the curve, the roll); this GDD (the event) |
| Time & Turn | in | seasons, age, death by old age | Time & Turn |
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
| Save/Load | out | level, bar, bottleneck state, bare attempts used this realm step, per-realm capability use | Save/Load |

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

- **Pacing.** With a 3-element root and other rate factors at 1.25 (guess), the first level
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
  The Cultivation Techniques GDD (Formulas A) normalises a typical technique to 1.0,
  but its strongest-element starter makes multi-element roots climb about 24 % faster
  than this table (3-element QR about 29 years). Its Open Question 1 hands this to the
  bot run; if confirmed, the lever is `climb_total` (user decision 2026-11-04).

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

`q_pill = clamp(p_pill + k_q·rank + k_n·ngo + k_d·dao + q_tree + τ·[talisman] + q_bonus, q_min, q_max)` ; `q_bare = p_bare`

A pill attempt needs the pill to be held and the realm condition met (rule 7). Every
other attempt is bare: it uses p_bare alone and burns nothing.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_pill | float | 0.06 / 0.16 / 0.20 / 0.15 | data file (`entry_requirement.pill_chance`) | Entry pill chance at QR→FE, FE→CF, CF→NS, NS→DT (FE→CF lowered from 0.20) |
| p_bare | float | 0.004 / 0.0037 / 0.0037 / 0.003 | data file (`entry_requirement.base_chance`) | Bare chance, the only term of a bare attempt; not clamped |
| k_q·rank | float | 0–0.075 | data file | Pill quality, 0.015 per grade |
| k_n·ngo | float | 0–0.075 | data file | Comprehension (ngộ tính), 0.0005 per point; pill attempts only |
| k_d·dao | float | 0–0.025 | data file | Dao heart (đạo tâm), 0.00025 per point; pill attempts only |
| q_tree | float | 0–0.08 | calculated (Meridian Map) | The tree's breakthrough chance, capped by the Meridian Map's `tree_breakthrough_cap` (8 pp); item and event bonuses go in q_bonus and are not capped by it |
| τ | float | 0.10 | data file (`crafting_talismans.json`) | Breakthrough talisman (Phá Cảnh Phù), at most one per pill attempt (user decision) |
| q_bonus | float | 0–0.30 | calculated | Destiny perk (thiên mệnh), e.g. Đạo Cốt +0.12, and event bonuses |
| q_min, q_max | float | 0.01, 0.95 | data file | Clamp on pill attempts |

**Output Range:** pill attempts 0.01–0.95, in practice from about 0.06; bare attempts
0.003–0.004. The breakdown names the kind of attempt and shows whether the condition is
met (Pillar 2).

Typical values, with pill rank 1, comprehension 40, Dao heart 30 and tree 0.02, so the
extras E = 0.0625 (guess):

| | QR→FE | FE→CF | CF→NS | NS→DT |
|---|---|---|---|---|
| Baseline q_pill | 0.1225 (no talisman yet) | 0.3225 | 0.3625 | 0.3125 |
| Edge q_pill (Đạo Cốt perk) | 0.2425, +0.10 with a starting talisman (one per attempt, 2 in stock) | 0.4425 | 0.4825 | 0.4325 |

- The talisman stays at or below the pill's own chance from FE→CF on, so the pill
  remains the gate.
- From FE→CF on, the baseline q_pill includes one talisman (+0.10): talisman skill
  level 4 is assumed reachable by then (guess; Open Question 3).
- A baseline life is assumed unable to craft a talisman before the QR→FE bottleneck
  (talisman skill level 4; guess, to verify). If it can, its QR→FE success rises from
  0.30 to about 0.47.

**Example:** FE→CF baseline: 0.16 + 0.015 + 0.020 + 0.0075 + 0.02 + 0.10 = **0.3225**.

### D. Pill supply

The pill_supply formula is defined as:

`λ = p_brew · n_plots · f · h · W / Y + λ_market + G` ; `Y = Σ_j qty_j · min_age_j`

`n_plots = clamp(3 + ⌊0.04 · purity_earth⌋ + field_plots, 1, 12)` ; `h = (1 + 0.008 · purity_wood) · max(0, 1 + herb_growth_pct / 100)` ; `p_brew = clamp(p_brew0 + 0.0025 · purity_fire, 0.05, 0.95)`

The spiritual root enters through all three terms (added 2026-11-04, cross-GDD review D1):
Earth adds plots and Wood speeds herbs (Character Stats, Formulas G), and Fire raises brew
success (Alchemy, as built: +0.25 percentage points per purity point). An absent element has
purity 0. The root multiplier is `m = (n_plots / 3) · h · (p_brew / p_brew0)` for a life
with no `field_plots`, `herb_growth_pct` or other alchemy bonus.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_brew0 | float | 0.05–0.95 | calculated (Alchemy) | Brew success without Fire; about 0.65 for the FE pill, 0.64 for the CF pill (guess) |
| p_brew | float | 0.05–0.95 | calculated (Alchemy) | Brew success with Fire purity |
| purity_earth, purity_wood, purity_fire | int | 0, 10–100 | calculated (Spiritual Roots) | 0 when the element is absent |
| n_plots | int | 1–12 | calculated (Character Stats, Formulas G) | Spirit field plots: base 3, +1 per 25 Earth purity, plus `field_plots` |
| f | float | 0–1 | constant (bot policy) | Share of plots given to breakthrough herbs; 0.5 (guess) |
| h | float | 0+ | calculated (Character Stats, Formulas G) | Herb growth factor from Wood purity and `herb_growth_pct` |
| m | float | 1–5.8 | calculated | Root multiplier (5.8 = Earth, Wood and Fire all at 100: 7/3 × 1.8 × 0.90/0.65); birth-mix means 1.22 / 1.48 / 1.78 / 2.13 / 2.52 for 1–5 elements |
| W | float | years | calculated | Growing years left in the realm: about 104 in QR, 140 in FE (guess). The CF→NS and NS→DT λ (0.70, 0.80) are calibration targets: with Y ≈ 390 / 680 and p_brew0 ≈ 0.65 they imply W ≈ 280 / 560 years, which the bot run must confirm |
| Y | float | plot-years | data file (recipe) | Plot-years per pill, recalibrated ×1.43 for the root terms (Formulas E): FE pill 40 + 10 = 50 (was 35); CF pill about 152 + 20 = 172 (was 120); NS pill ≈ 390, DT pill ≈ 680 (new recipes, guess) |
| λ_market | float | 0+ | calculated (Market) | Pills bought; about 0 at baseline (a pill is stocked about 1 restock in 10 and costs 11–15 years of missions) |
| G | float | 0–2 | calculated | Pills gifted by fortuitous encounters (cơ duyên); they ignore min_age |
| λ | float | 0+ | calculated | Expected pill attempts in the realm step |

**Output Range:** 0 upward, roughly proportional to plots ÷ min_age, and ×1–5.8 by root.

**Example:** QR→FE for a root with no Wood, Earth or Fire: λ = 0.65 × 3 × 0.5 × 1 × 104 ÷
50 = **2.03** pills. For the root {Wood 40, Fire 86, Water 10}: h = 1.32, p_brew = 0.865, so
m = 1.32 × 0.865 ÷ 0.65 = 1.757 and λ = **3.56** pills.

The Core Formation pill's herb Kim Tủy Quả (rarity 4) becomes plantable from Foundation
Establishment on (`seed_rarity_max` 4 from FE; user decision), so the CF pill is a
planned, decades-long project.

### E. Realm-step success

The realm_step_success formula is defined as:

`S = P_C · (1 − e^(−Σq)) + S_bare` ; `Σq = λ · q_pill + Σ talisman extras` ; `S_bare ≤ 1 − (1 − p_bare)^bare_attempt_cap`

For a known number of pills A, use `S = 1 − Π_{i=1..A} (1 − q_i)` instead.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| P_C | float | 0–1 | calculated | Chance the life ever meets the realm condition; about 1 for the CF density condition with competent play; the CF→NS heart-demon gate's P_C is also assumed about 1 (kills add no heart demon, Character Stats, so the gate tests failed breakthroughs, events and #9) |
| Σq | float | 0+ | calculated | Expected successes from pill attempts |
| S_bare | float | 0–0.012 | calculated | The most a life spamming bare attempts can add: at most `bare_attempt_cap` (3) attempts per realm step, so 0.0119 / 0.0110 / 0.0110 / 0.0090 |
| S | float | 0–1 | calculated | Chance to cross the bottleneck before the life ends |

**Output Range:** 0–1. For a single life the targets need Σq = −ln 0.7 = 0.357 at
baseline and −ln 0.3 = 1.204 with the edge.

**The targets are averages over the birth mix (user decision 2026-11-04, cross-GDD review
D1).** λ depends on the root (Formulas D), so S does too. The 0.30 / 0.70 targets are the
mean S over lives born with the count weights 45 / 32 / 15 / 6.5 / 1.5 % and the purity
roll of Spiritual Roots (Formulas A). Without recalibration the root terms would lift the
baseline mean to about 0.40; scaling every pill's plot-years Y by about ×1.43 (root-free λ
×0.70) brings it back. Roots with more elements then cross more often, so "more elements
is better" also holds for breakthrough odds. Figures are exact expectations over the
purity distribution, not simulated:

| Gate | Root-free λ | Mean S (P_C = 1) | S by element count 1 / 2 / 3 / 4 / 5 | Gift pills G the edge needs for a mean of 0.70 (Đạo Cốt only; QR→FE adds the 2 starting talismans; no Tổ Truyền Linh Điền) | Edge S by element count |
|---|---|---|---|---|---|
| QR→FE | 2.03 | 0.301 | 0.26 / 0.30 / 0.35 / 0.40 / 0.46 | 1.27 | 0.67 / 0.70 / 0.74 / 0.78 / 0.82 |
| FE→CF | 0.78 | 0.304 | 0.26 / 0.31 / 0.36 / 0.41 / 0.46 | 1.61 | 0.68 / 0.70 / 0.73 / 0.76 / 0.79 |
| CF→NS | 0.70 | 0.304 | 0.26 / 0.31 / 0.36 / 0.41 / 0.46 | 1.50 | 0.68 / 0.70 / 0.73 / 0.76 / 0.79 |
| NS→DT | 0.80 | 0.302 (provisional: P_C < 1 lowers it, Open Question 10) | 0.26 / 0.31 / 0.35 / 0.41 / 0.46 | 1.64 | 0.68 / 0.70 / 0.73 / 0.76 / 0.79 |

The q_pill values are unchanged: 0.1225 / 0.3225 / 0.3625 / 0.3125 at baseline, +0.12 with
Đạo Cốt. Mean S is the birth-weighted mean of the per-tier S, each itself a mean of
1 − e^(−λ·m·q) over the tier's roots.

- **What the targets assume (bot policy).** The 0.30 / 0.70 targets are measured with
  capabilities #22 and #23 disabled and the tree allocated as the bot plays it (typically
  about 0.02 of the 8 pp cap). With #22 or #23, a life can gain up to the Meridian Map
  guard's +0.10 (so up to about 0.80 for the edge); a tree that maximises its 8 pp adds
  about 0.04–0.05 more.
- **The baseline-only lever.** For QR→FE through CF→NS it is pill supply, set by the
  herbs' min_age and the plot count. Gift pills ignore min_age, so a change moves the
  baseline about 1.7× as much as the edge. Example: Kim Tủy Quả at 202 years instead of
  152 moves the baseline mean 0.30 → 0.245 and the edge mean only 0.70 → 0.67. Changing p_pill is
  a bad lever, because it moves both equally.
- **The Deity Transformation lever** is the condition. Fortuitous encounters can grant
  the edge the insight (P_C = 1), while baseline lives depend on the enlightenment
  event rate. For example, P_C = 0.6 with λ = 1.9 gives 0.6 × (1 − e^(−0.594)) = 0.27.
- **DT targets include the Heavenly Tribulation.** The 0.30 / 0.70 targets cover the
  roll and the tribulation together (user decision), so the roll's own target is 0.30 ÷
  p_t, where p_t is the tribulation survival chance set by the Heavenly Tribulation
  GDD. Until then, the roll target is 0.30 / 0.70.
- **What the edge contributes.** Each perk pays through q, λ, G or P_C:
  - Đạo Cốt: +0.12 on q.
  - Tổ Truyền Linh Điền: λ × 1.87 (+1 plot, faster herbs; figure for a root with no Earth
    or Wood, so smaller for roots that already have them).
  - The starting talismans: QR→FE only.
  - Gift pills or herbs already at age: G.
  - Gifts that meet a condition (a spirit vein, a calming pill, an enlightenment event):
    P_C.

  A perk that touches none of these lands the edge at about 0.60–0.65.
- **Fortuitous encounter weights must change.** The edge needs about 1.2–1.6 gift pills
  per gate, but today's fortuitous encounters give a pill only about a third of the
  time. Their weights should favour pills and herbs already at age (data, Progression
  Edges).
- **Sample size.** Verifying 0.30 ± 0.05 and 0.70 ± 0.05 at 95 % needs about 330
  bottleneck arrivals per arm per gate (1.96² × 0.21 ÷ 0.05²). About 35–50 lives are
  enough if the bot logs λ and q per life and averages the analytic S.

S_bare is left out of the table above. The bare-attempt cap (rule 11) bounds it at about 0.012, inside the ±0.05 tolerance. The heart demon does not: a patient life that waits out the decay could otherwise make dozens of attempts. A bare success counts as a crossing.

**Example:** CF→NS for a root with m = 1: 1 − e^(−0.70 × 0.3625) = **0.224**; for the
{Wood 40, Fire 86, Water 10} root (m = 1.757): 1 − e^(−0.70 × 1.757 × 0.3625) = **0.360**.

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

- Pill attempts are spaced years apart by supply, and a failure's +15 decays within
  about 15 years. So heart demon mainly drives the NS condition. Death by qi deviation is a
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
| DT: insight | `condition.type` "insight" | kept once gained (user decision) | One enlightenment event unlocks every later attempt in that realm step, so λ is not limited by insights |

### H. Guard hook (for the Meridian Map's Formulas E2)

The guard_success formula is defined as:

`S_guard = min(1 − Π_{i ∈ made ∪ held} (1 − q_i), s_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| q_i | float | 0.01–0.95 | calculated | q_pill of each pill attempt made this realm step, plus one per held pill whose condition is met now; bare attempts excluded |
| s_max | float | 0.95 | data file (`guard.s_max`) | Cap that keeps 1 − S away from 0 |
| S_guard | float | 0–0.95 | calculated | Lower bound on the unknown S, used in place of S in the Meridian Map's E2 |

**Output Range:** 0–0.95. Future pills only raise the true S, so using a lower bound can
only shrink capabilities #22 and #23's lift: the +0.10 guard holds by construction. The
attempt log is saved with the character.

**Example:** CF→NS baseline, one failed attempt at 0.3625 and no pills held:
- S_guard = 0.3625;
- q_retry = min(0.3625, 0.10 ÷ 0.6375) = 0.157;
- lift = 0.157 × 0.6375 = **0.100**.

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
| tech, comp, density, tox | float | 0+ | Cultivation Techniques, Character Stats, Travel & Map / Formulas, Character Stats | Technique speed, comprehension, local qi density and pill-toxicity penalty factors |
| speed_pct | float | 0–about 40 | calculated (stat sheet `cultivation_speed_pct`, Character Stats Formulas I) | The sum of every speed bonus, including Spiritual Roots' generating pairs (+3 % each, up to +15) |

**Output Range:** 0 upward. The speed bonuses never reduce the rate below 0.

**Example:** base 25, comprehension 1.25, the other factors 1.0: 31.25 per season. With
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
  - `pill_chance` 0.06 / 0.16 / 0.20 / 0.15;
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
- `crafting_talismans.json`: `pha_canh` value 10.
- Item DB and economy:
  - the FE pill's ginseng `min_age` 40 (2026-11-04, root terms in λ; its "thirty years"
    text becomes "forty years");
  - Kim Tủy Quả `min_age` about 152 (2026-11-04, same reason);
  - `field.seed_rarity_max` 4 from FE on;
  - new NS and DT pill recipes (`hoa_anh_dan`, `hoa_than_dan`) sized to Y ≈ 390 and 680
    plot-years;
  - fortuitous encounter weights favouring pills and herbs already at age.

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
- **If several talismans are held:** one is burned per pill attempt. A bare attempt burns
  none.
- **If a held pill belongs to another realm's bottleneck:** it is not usable and not
  burned. It waits for its bottleneck.
- **If the condition changes during the attempt's season** (a formation lapses, heart
  demon rises): the condition is checked once, at the start of the attempt, before
  anything is burned.
- **If heart demon is exactly 20 at the Nascent Soul attempt:** the condition holds (at
  most 20).
- **If a gathering formation lapses because its upkeep went unpaid:** its density bonus no
  longer counts toward the Core Formation condition.
- **If the attempt season would also end the life by old age:** the attempt resolves
  first. A success raises the lifespan cap before the season's aging is applied.
- **If q_pill would exceed 0.95:** it is clamped to 0.95. Bare chances are never clamped
  upward.
- **If a qi deviation leaves the character at 5 % vitality without killing them:** the
  next attempt still waits for the bar to refill. Vitality recovers with time or pills.

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

Spiritual Roots (`linh-can.md`), Character Stats (`character-stats.md`) and the Meridian
Map (Kinh Mạch Đồ, `kinh-mach-do.md`) have GDDs among the systems below, and each lists
Realms & Bottlenecks. Every other interface is provisional. When each remaining GDD is
written, it must list Realms & Bottlenecks in its own Dependencies section.

**Upstream: this system cannot work without them (hard)**

| # | System | What Realms & Bottlenecks needs from it |
|---|---|---|
| 1 | Data-Driven Config | `cultivation_realms.json` (bands, costs, chances, conditions), `character_attributes.json` (curve, heart demon decay) |
| 2 | Deterministic Simulation Core | The seeded RNG for attempts and NPC fate; Breakdown for every rate and chance |
| 4 | Time & Turn | Seasons, age, death by old age |
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
| 10 | Meridian Map | `level_gained`, `stage_reached` and `breakthrough_succeeded` events; the ladder constants; S_guard for its guard (E2) |
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
| 5 | Save/Load | Level, bar, attempt log, insight, per-realm capability use |

**Cycles and how they are broken:**
- **Realms ↔ Progression Edges.** Edges reads realms; Realms only reads the stat sheet and
  items that Edges fills, never Edges itself.
- **Realms ↔ Event Engine.** Events read the bottleneck flag; Realms reads the insight from
  the character's state, which an event set.
- **Realms ↔ Cultivation Techniques.** This cycle is already in the systems index: the
  technique feeds the rate, and the realm caps the technique tier.

**Systems index change (proposed for Phase 5):**
- Row 8's Depends On becomes Config, Sim Core, Time & Turn, Spiritual Roots, Character
  Stats, Item DB; soft: Cultivation Techniques, Spirit Herbs, Alchemy, Formations, Travel &
  Map, Event Engine, Progression Edges.
- Its status becomes "Designed (pending review)". The built game still runs the old stage
  ladder.

## Tuning Knobs

Every knob is a data key (Formulas, Parameter keys). Ranges marked *derived* follow from
other numbers in this GDD; ranges marked *guess* wait for a bot run.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `climb_total` | 1,025 / 5,600 / 42,000 / 276,000 / 1,850,000 | QR −30 % to +19 % (derived: a five-element root already uses 84 % of the half-lifespan ceiling in QR, Spiritual Roots Formulas B); FE and CF −30 % to +30 % (five-element check pending, AC-CG-33a); NS and DT −30 % to +8 % (derived: +30 % would push a 1-element NS and DT past the ceiling); derived ceiling: a root of any element count must clear a realm in at most half its lifespan | Years per realm (Pillar 4) |
| `climb_growth` | 6 / 3 / 3 / 3 / 3 | 2–6 (QR 4–8) | How much later levels cost than early ones |
| `bar_mult` | 4 / 10 / 10 / 10 | 6–15 (QR 3–5) | Bottleneck bar size; with the 30 % loss, how many levels a failure costs |
| `stage_power_step` | 0.15 | 0.10–0.20; derived ceiling 0.24, above which divine sense's great-breakthrough jump becomes smaller than the realm's own ladder | Stat rise per small breakthrough |
| `pill_chance` | 0.06 / 0.16 / 0.20 / 0.15 | ±0.03; derived by p_pill = −ln(1 − S) ÷ λ − E − τ | Per-attempt odds; moves baseline and edge equally, so not the baseline lever |
| `base_chance` | 0.004 / 0.0037 / 0.0037 / 0.003 | jointly with `bare_attempt_cap`: 1 − (1 − base_chance)^cap ≤ 0.03 (derived), so at most 0.0101 at cap 3 and 0.0061 at cap 5 | Hope for bare attempts; must stay near-hopeless |
| Comprehension, Dao heart, quality per-point bonuses | 0.0005 / 0.00025 / 0.015 | ±50 % | How much talent and pill quality matter |
| Breakthrough talisman τ (`pha_canh` value) | 10 pp | 5–10; derived ceiling: at most the pill's chance from FE→CF on | The talisman's weight against the pill |
| `failure_tam_ma_gain` | 15 | 10–20, and at most `nascent_tam_ma_max` (one failure must still allow the next Nascent Soul attempt; Character Stats states 10–20 exclusive, so align at its next pass) | How fast back-to-back failures become deadly |
| `tam_ma_natural_decay` | 0.25 per season | 0.15–0.25; *derived*: n_90 must stay at 7–10, which holds up to about 0.256 (at 0.5 it is 8 / 11 / 12 / 28) | How long a failure haunts the character |
| `failure_tu_vi_loss_pct` | 0.30 | 0.2–0.4 | Refill time after a failure |
| `core_density_min` | 1.4 | 1.3–1.5; derived: 28 % to 9.5 % of places qualify | How hard the Core Formation condition is |
| `nascent_tam_ma_max` | 20 | 15–30, and at least `failure_tam_ma_gain` | How much heart demon a Nascent Soul attempt tolerates |
| FE pill ginseng `min_age` (Item DB) | 40 years (**change** 2026-11-04, was 25; recalibrated for the root terms in λ, Formulas D–E) | 35–50; derived baseline QR→FE mean success 0.33–0.26 (30 gives 0.36, outside 0.30 ± 0.05) | **The baseline lever** at QR→FE |
| Kim Tủy Quả `min_age` (Item DB) | about 152 years (**change** 2026-11-04, was 100; same reason) | 125–195 (derived: mean success 0.35–0.25; 120 gives 0.36 and 202 gives 0.245) | The baseline lever at FE→CF |
| Fortuitous encounter weights (Progression Edges) | favour pills and herbs at age | enough for about 1.2–1.6 gift pills per gate | The edge's 0.70 |
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
  - talismans held;
  - attempts made in this realm step;
  - the qi deviation chance if this attempt fails;
  - bare attempts used out of `bare_attempt_cap`.
- **Attempt preview.** Before any attempt, the full chance breakdown shows whether it will
  be a pill attempt or a bare one. A bare attempt needs an explicit confirmation.
- **Warnings** (Advisor):
  - cultivation base that would be wasted at a full bar;
  - a pill held for the wrong bottleneck;
  - a slow root whose estimated time to the bottleneck exceeds its remaining lifespan.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Realm Ladder, Character Stats (draft formulas, heart demon, Dao heart) and Pillars 2–4 |
| `design/gdd/kinh-mach-do.md` | Points arithmetic (Formulas A), the breakthrough guard (E2, which now takes S_guard from Formulas H here), and capabilities #9, #22 and #23 hosted here; the ladder constants it reads (bonuses, shares) are owned and registered here |
| `design/gdd/linh-can.md` | The element-count curve (Formulas B), the generating-pair speed bonus (Formulas C), Mutation Awakening on `breakthrough_succeeded` (rule 9), and the birth mix the 0.30 / 0.70 targets average over (Formulas A) |
| `design/gdd/character-stats.md` | The stat sheet (`cultivation_speed_pct` stacking, Formulas I), comprehension, Dao heart, heart demon and vitality keys shared with this GDD |
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
  - Base 25 with comprehension factor 1.25 and the rest 1.0 gives 31.25; halving any one
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
  heart 30, tree 0.02 and one talisman:
  - q = 0.3225;
  - the breakdown names "pill attempt" and "condition met", with lines 0.16 / 0.015 /
    0.020 / 0.0075 / 0.02 / 0.10.
- **AC-CG-20** [Logic] Formula C table, with E = 0.0625.
  - Baseline q_pill: 0.1225 / 0.3225 / 0.3625 / 0.3125.
  - With q_bonus 0.12: 0.2425 / 0.4425 / 0.4825 / 0.4325.
  - QR→FE with the bonus and one talisman: 0.3425.
- **AC-CG-21** [Logic] Rule 8, bare attempt. No pill held, but comprehension 100, Dao heart
  100, tree 0.08, two talismans, the Đạo Cốt perk and an event bonus:
  - q is exactly 0.004 / 0.0037 / 0.0037 / 0.003;
  - the breakdown shows "bare attempt" and no other term;
  - after a forced success or failure, the talisman and pill counts are unchanged.
- **AC-CG-22** [Logic] Rule 8. A pill attempt holding 2 pills and 3 talismans ends with 1
  pill and 2 talismans, whether the RNG is forced to success or to failure. The talisman
  term is +0.10.
- **AC-CG-23** [Logic] Edge cases.
  - Holding rank-1 and rank-3 FE→CF pills burns the rank-3 one; the quality term is 0.045.
  - Holding only a QR→FE pill at the FE→CF bottleneck makes the attempt bare (0.0037), and
    that pill is not burned.
- **AC-CG-24** [Logic] Formula C clamp.
  - A raw 0.9625 is clamped to 0.95.
  - A raw 0 is clamped to 0.01.
  - A bare 0.0037 stays 0.0037.
- **AC-CG-25** [Logic] Rule 8. Tree-sourced `breakthrough_chance` of 12 pp counts as 8 pp
  (q_tree 0.08), so the FE→CF baseline q = 0.3825. A non-tree bonus (a perk) is a
  separate q_bonus term and is not capped (Character Stats rule 14).
- **AC-CG-26** [Logic] Rule 9. A forced FE→CF success at level 79 leads to:
  - level 80, bar 0, full vitality;
  - CF bases at multiplier 1.00;
  - the lifespan cap raised from 200 to 500 (plus bonuses);
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

- **AC-CG-29** [Logic] Formulas D and E.
  - λ(p_brew0 0.65, Earth 0, f 0.5, Wood 0, Fire 0, W 104, Y 50, λ_market 0, G 0) = 2.028;
    with G = 1 it is 3.028.
  - With Wood 40, Fire 86, Earth 0 and Y 50: h = 1.32, p_brew = 0.865, λ = 3.562.
  - Earth 25 / 49 / 50 / 100 gives n_plots 4 / 4 / 5 / 7; Fire 100 with p_brew0 0.70 gives
    p_brew 0.95 (clamped).
  - S = 0.2200 / 0.2228 / 0.2241 / 0.2212 for root-free (2.028, 0.1225), (0.7814, 0.3225),
    (0.70, 0.3625) and (0.80, 0.3125).
  - The birth-mix mean S at those root-free λ values (exact expectation over Spiritual Roots
    Formulas A) is 0.301 / 0.304 / 0.304 / 0.302 (±0.002).
  - P_C 0.6, λ 1.9, q 0.3125 gives 0.2686.
  - The known-A form with [0.3625, 0.3625] gives 0.5936.
- **AC-CG-30** [Bot] Formula E. `autoplay.gd --edge off`, run to ≥ 330 bottleneck arrivals
  per gate, with roots rolled by the birth mix: each gate's mean crossing rate is
  0.25–0.35. Bare successes count. Bot policy: capabilities #22 and #23 disabled, the tree
  as the bot allocates it. Per tier (`--elements 1..5`, ≥ 330 arrivals each), each gate is
  within ±0.05 of the Formulas E row (0.26 / 0.30 / 0.35 / 0.40 / 0.46 at QR→FE).
- **AC-CG-31** [Bot] The same with `--edge on`: each gate's mean is 0.65–0.75, and each
  tier is within ±0.05 of the Formulas E edge row. Until the Heavenly Tribulation exists,
  the DT roll is held to 0.30 / 0.70.
- **AC-CG-32** [Bot] Alternative to 30–31: the mean of the analytic per-life S over ≥ 50
  lives per arm is in the same windows. This needs per-life λ and q logging, which
  `autoplay.gd` does not have yet.
- **AC-CG-33** [Bot] `climb_total` ceiling. `autoplay.gd --elements 1` over ≥ 50 lives:
  the median years to clear each realm is at most 60 / 100 / 250 / 500 / 1,000.
- **AC-CG-33a** [Bot] `climb_total` ceiling for five elements. `autoplay.gd --elements 5`
  over ≥ 50 lives: the median years to clear QR is at most 60 (the half-lifespan
  ceiling), at the current totals and at `climb_total` +19 %. Expected about 50 at the
  current totals, with the full pair bonus (Spiritual Roots Formulas B). Extend to FE and
  CF after the first run.

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
- **AC-CG-50** [Logic] Formula H.
  - One failed attempt at 0.3625 with no pills: S_guard = 0.3625.
  - Adding one held pill with the condition met: 0.5936. An unmet-condition pill and bare
    attempts are excluded.
  - Six failures → 0.9329; seven → raw 0.9572, capped at 0.95.

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
  from this system and computes q_retry 0.157 and lift 0.100.

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
  bottleneck state, attempt log (same S_guard), insight, bare attempts used and #22 / #23 use.
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
  - `tam_ma_natural_decay` is 0.25, `pha_canh` is 10, the FE ginseng `min_age` is 40 and Kim Tủy Quả's is 152.

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

**Still provisional:**
- The Deity Transformation success criteria stand until the Heavenly Tribulation GDD
  exists.
- Pacing guesses (T_r, W, p_brew) are testable only through AC-CG-33 and the bot targets.
- Bot items 30–33 and 54 need the tooling gaps closed: per-life λ and q logging, and a
  cohort size of at least 330.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | What lies beyond Deity Transformation? Deferred by the user (the Meridian Map's Open Question 2) | user | Nothing for now |
| 2 | The Heavenly Tribulation's survival chance p_t, which sets the Deity Transformation roll target (0.30 ÷ p_t) | Heavenly Tribulation GDD | Formulas E for Deity Transformation |
| 3 | When can a baseline life craft a breakthrough talisman? Formulas C assumes not before the QR→FE bottleneck but yes from FE→CF on. If it can, baseline QR→FE success rises from 0.30 to about 0.47 | calibration (bot) | Formulas C and E sign-off |
| 4 | The Nascent Soul and Deity Transformation pill recipes (about 390 and 680 plot-years after the 2026-11-04 root recalibration, Formulas D; they were 270 and 470), including a new top-rarity herb for Deity Transformation | Item DB, economy-designer | Those two gates |
| 5 | Fortuitous encounter weights that give the edge about 1.2–1.6 gift pills per gate | Progression Edges | The edge's 0.70 |
| 6 | ~~How fast killing adds heart demon~~ **Answered 2026-11-04 by Character Stats:** kills add none (user decision) | — | — |
| 7 | ~~The realm bases with the stage multiplier~~ **Answered 2026-11-04 by Character Stats (Formulas C):** unchanged; every great-breakthrough jump stays ≥ ×2.07 | — | — |
| 8 | The move from stages to levels in code: `cultivation_rules.gd` (cost curve, pill vs bare attempts, conditions), `combat_power.gd`, `world_ticker.gd` (NPCs advance by 4 stages, including in Qi Refining), `build_generator.gd` (`tree_points_for`), the terminal views, the Advisor, the event context and save migration | implementation story | Building this GDD |
| 9 | The FE pill ginseng's text says "thirty years"; with `min_age` 40 (2026-11-04 recalibration) the text must change to "forty years" | Item DB | Data consistency |
| 10 | The Deity Transformation baseline P_C: how often a baseline life gets an enlightenment event that grants the insight, and the matching event rate (needed to verify AC-CG-31) | Event Engine, calibration (bot) | Formulas E for Deity Transformation |
| 11 | Duplicate keys with Character Stats: `vitality_floor` (here `breakthrough.vitality_floor`, there `derived.vitality_floor`) and `tam_ma_natural_decay` (listed in both Parameter keys). This GDD owns the values; Character Stats should read them and drop its copies, and its AC-CS-36 / AC-CG-58 then agree | Character Stats | Data consistency |
