# Spiritual Roots (Linh Căn)

> **Status**: In Review (2026-11-04, after cross-GDD review 04g: holder-raised ceilings priced, plots at 20 W; awaiting re-review). See `reviews/linh-can-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-04
> **Last Verified**: 2026-11-04
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name); touches Pillar 3 (Power Is Built, Not Given) and Pillar 4 (Every Season Counts)

## Summary

The spiritual root is the talent a cultivator is born with for the five elements.
- **Elements and purity.** One to five elements, each with a purity of 10–100. A
  five-element root is about 1 life in 67.
- **Cultivation speed.** Many-element roots cultivate slower early and far faster late.
  Each generating pair inside the root adds +3 % cultivation speed.
- **Roles and scaling.** Each element has a craft or economy role, and purity scales the
  Meridian Map and techniques.
- **Mutations (biến dị).** 29 of them form from element pairs and combine up to Chaos.
  Each rolls once, about 13.5 % of lives have one, and each is held to a power band.
- **Changes.** The root changes only through a few capped pills and event fruits, and
  never loses anything. It is the run's first reveal and a long-term build goal.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Config, Sim Core`

## Overview

The spiritual root (linh căn) is the talent a cultivator is born with for the five
elements (ngũ hành): Wood, Fire, Earth, Metal and Water (Mộc, Hỏa, Thổ, Kim, Thủy).
- **Elements and purity.** A root owns one to five of them, each with a purity from 10
  to 100.
- **Root mutations (biến dị).** Pairs of owned elements can form mutations, such as
  Thunder from Fire and Metal or Life from Water and Wood. Mutations can combine further,
  up to the apex Chaos (Hỗn Độn), which needs all five.

The root shapes everything:
- **Cultivation speed.** Many-element roots start slow and grow fastest late, and every
  generating (tương sinh) pair inside the root adds a little speed.
- **Element roles.** Each element has a craft or economy role: Wood grows herbs, Fire
  brews pills, Earth adds field plots, Metal earns from missions and Water clears pill
  toxicity.
- **Purity scaling.** Purity sets how much each Meridian Map region and cultivation
  technique pays.
- **Mutation bonuses.** Each mutation adds its own bonuses to the stat sheet.

The root is rolled at birth (or chosen in a Self-made life). It changes only rarely,
through a few treasures and pills, so it is both the hand you are dealt and a long-term
build goal.

The system exists because it is the first and strongest source of Pillar 1 (Your Dao,
Your Name). Two lives with different roots play differently from the first season. A
single root cultivates fastest at the start; a five-element root must survive a slow
Qi Refining (Luyện Khí) to become the strongest cultivator in the world. That trade is
Pillar 4 (Every Season Counts) applied to a whole life.

## Player Fantasy

You open a life with a hand you did not choose, and you learn to love it. A single root
is a sprinter: fast now, with a long way to go. A five-element root is a long gamble: you
are slow and fragile in Qi Refining, then you pull away from everyone who started fast. A
mutation (biến dị) is a gift you did not earn, and a few treasures and the Meridian Map's
Mutation Awakening let you keep chasing the ones you missed. Nothing is ever taken from
the root, so every change is a step forward in a build you chose to pursue.

## Detailed Design

This section documents the system as built, plus the user's decisions of 2026-11-04.
Changes from the built game are marked **(change)**.

### Core Rules

**Elements**

1. **The five elements.**
   - **Generating cycle:** Wood → Fire → Earth → Metal → Water → Wood (tương sinh).
   - **Overcoming pairs** (tương khắc): Metal–Wood, Wood–Earth, Earth–Water, Water–Fire,
     Fire–Metal.
   - An owned element has an integer purity of 10–100 (`purity_min`–100). A mutation's
     purity is computed (rule 9) and can fall below 10: 8 for a first-order mutation from
     two minimum-purity parents, lower for higher orders, never below 1. An absent
     element has purity 0.
2. **Birth.**
   - **Fated birth (Thiên Định):**
     - the element count is drawn from `count_weights`, 45 / 32 / 15 / 6.5 / 1.5 % for 1
       to 5 elements (**change**, was 45 / 30 / 15 / 7 / 3; user decision);
     - the elements are chosen uniformly at random;
     - each purity is drawn from N(`purity_mean`, `purity_sd`), rounded (**change**: the
       code truncates today) and clamped to `purity_min`–100;
     - mutations are then rolled (rule 9).
   - **Self-made birth (Tự Định):** the player picks the elements and their purities
     (10–100; values outside are rejected at input) and may pick mutations whose parents
     they own. Picks are validated lowest order first, so a picked mutation counts as
     owned for a later pick of a higher order. A picked mutation's purity follows rule
     9's formula. Nothing is rolled:
     every mutation eligible at birth goes into the rolled set, picked or not.
3. **Tier.** The number of **base** elements names the root:

   | Elements | Tier |
   |---|---|
   | 1 | Single root (Đơn linh căn) |
   | 2 | Dual root (Song linh căn) |
   | 3 | Triple root (Tam linh căn) |
   | 4 | Quadruple root (Tứ linh căn) |
   | 5 | Five-element root (Ngũ Hành linh căn) |

   Mutations never change the tier.

**Cultivation**

4. **The element-count curve.**
   - **Lookup:** the curve factor is `element_count_curve[base element count][stage
     group]`, where Realms & Bottlenecks supplies the stage group (4 per realm).
   - **Mutations do not count (change):** the built game counts them, up to 8; user
     decision.
   - **Shape:** fewer elements are faster early and many elements far faster late.
     Parity with a single root comes at Foundation Establishment's middle stage for 2–3
     elements, its late stage for 4, and Core Formation's early stage for 5.
5. **Generating-pair bonus (new; user decision).** Each generating pair whose two
   elements are both owned adds `pair_bonus_pct` to cultivation speed. It appears as a
   stat sheet modifier whose source is the data's Vietnamese name, for example
   "Tương sinh: Mộc → Hỏa". Stat sheet sources always use these data names; the root
   line and other text show English names with Hán-Việt annotation (Wood [Mộc]).
   - A five-element root holds all 5 pairs.
   - The full cycle is also rewarded by the Chaos mutation (rule 8).
   - Overcoming pairs give no speed. They are where volatile mutations come from.

**What each element does**

6. **Element roles**, as built. Character Stats owns the formulas (its Formulas G) and the
   crafts own their checks:

   | Element | Role |
   |---|---|
   | Wood (Mộc) | Herb growth |
   | Fire (Hỏa) | Alchemy success and quality |
   | Earth (Thổ) | Spirit field plots |
   | Metal (Kim) | Mission income |
   | Water (Thủy) | Pill-toxicity decay |

7. **Purity as a scale.**
   - **Meridian Map:** acupoints scale by 0.5 + purity ÷ 100 for their sector's element,
     or 0.25 if it is absent; bridges average their two sectors (that GDD, rule 4).
   - **Cultivation techniques:** a technique's speed scales by the average purity of
     the elements and mutations it names ÷ 100. A technique naming an element or
     mutation the root lacks cannot be used at its speed (Cultivation Techniques owns the
     fallback).

**Root mutations (biến dị)**

8. **The catalogue.** It holds 29 mutations, in `character_elements.json`, each with
   parents, an order and fixed stat modifiers:
   - **First order:** 10 mutations from two base elements. The five generating pairs give
     *stable* ones (Light, Lava, Gravity, Ice, Life). The five overcoming pairs give
     *volatile* ones (Wind, Poison, Darkness, Mist, Thunder).
   - **Higher order:** 19 mutations from mutations, or a mutation plus an element (15
     at order 2, 3 at order 3, 1 at order 4). They come in combat, craft, esoteric and
     apex kinds, up to Taiji, Time and Chaos.
   - **Chaos (Hỗn Độn)** needs all five base elements.
   - **Bonuses.** Each owned mutation adds its modifiers to the stat sheet with the source
     "Biến dị: <data name>", for example "Biến dị: Quang". The values are fixed, not scaled
     by the mutation's purity.
   - **Power bands (change; user decision).** A mutation's modifiers, priced in the
     Meridian Map's power unit W, stay within its order's band: order 1 ≤ 30 W, order 2
     ≤ 60 W, order 3 ≤ 100 W, order 4 ≤ 150 W (Formulas E), and no lower than a floor of
     10 / 15 / 30 / 50 W, so a mutation is never a dud. Values outside a band are retuned
     in data. Today's data breaks the floor for Death and Reincarnation (Formulas E,
     Open Question 1). Lava returns to its band through its alchemy ceiling raise 3 → 5
     (13.5 W; user decision 2026-11-04), once the data pass adds it.
     **Holder-raised ceilings** (user decision 2026-11-04, cross-GDD review 04g, F15;
     Character Stats rule 14). A mutation may raise one character-wide ceiling for its
     holder only: Pill Fire raises `alchemy_success` 3 → 6 (31.2 W), Lava raises
     `alchemy_success` 3 → 5 (13.5 W) and Spirit Farming raises `herb_growth_pct`
     10 → 20 (49 W). Raises on one key do not stack, and the
     highest applies. Formulas E prices each raise as power. Time, the apex, takes its power outside the character-wide
     ceilings: +40 % cultivation speed and a ×1.25 herb-aging root factor, 110.5 W (user
     decision 2026-11-04). Until the data pass adds those lines, Time's built data prices
     at 0 W and fails the floor too (AC-LC-25).
9. **Forming mutations.** Each mutation rolls **once**, when its parents first become all
   owned: at birth, or when a root change adds an element (rule 11). The only other roll
   is Mutation Awakening (below). A purity change never triggers a roll (**change**; user
   decision: the built game re-rolls every eligible mutation after any change, which let
   purity pills farm mutations).
   - in one pass, every mutation that has just become eligible rolls;
   - lower orders roll first, so a mutation formed in this pass can be a parent later in
     the same pass; within one order, mutations roll in catalogue order (the order of
     `character_elements.json`), one uniform draw each, and a roll succeeds when the draw
     is below the chance. An ineligible mutation makes no draw (full draw order: Formulas A);
   - the chance is the product of the parents' current purities ÷ 100, × a factor
     (`bien_di_chance_factor` for first order, smaller for higher orders; see Formulas);
   - a mutation's purity is round(the parents' geometric-mean current purity ×
     `bien_di_purity_factor`), clamped to 1–100. It is **recomputed from the current
     parents** whenever a parent's purity changes (**change**; user decision 2026-11-04),
     lowest order first, so a Tẩy Tủy Đan also lifts the purity of the mutations built on
     that element. A mutation's modifiers stay fixed (rule 8), and the change never rolls.
   - **Mutation Awakening (Biến Dị Khai Mở; user decision 2026-11-04).** This system
     subscribes to Realms & Bottlenecks' `breakthrough_succeeded` event (a successful move
     to the next realm). On each event, if the Meridian Map capability #24 is in the
     character's capability set (Character Stats rule 16), it gives one more roll to
     every mutation that is not owned but whose parents are all owned, including the
     ones that failed earlier. The chance is the same formula at the parents' current
     purities, the pass rules above apply, and a mutation that forms is owned from then
     on. Nothing else re-rolls a failed mutation.
   - **At most two Awakening passes per life.** Every capability sits behind the Core
     Formation gate (Meridian Map rule 16: none can affect the first two
     breakthroughs), so only Core Formation → Nascent Soul and Nascent Soul → Deity
     Transformation can fire it.
10. **What a mutation is and is not.**
    - A mutation counts as an owned id for techniques, crafts and recipes that name it,
      and its current purity (rule 9) is used there.
    - It does **not** count toward the tier, the element-count curve or generating
      pairs.

**Changing the root**

11. **Root changes**, only through items and events (as built; quick spec
    `phu-luc-linh-thu-thanh-tuu.md`):
    - **Tẩy Tủy Đan** (Marrow-Cleansing Pill): raises the weakest owned element by
      max(1, round(6 × pill potency)), capped at 100. At most 3 per life; a further pill, or one taken when
      every owned element is at 100, is refused and kept.
    - **Linh Căn Quả** (Spiritual Root Fruit; rare by design, user decision 2026-11-04):
      adds a missing element, chosen uniformly at
      random unless the event names one, at purity 20–35. An event-named element that is
      already owned is ignored, and the element is chosen uniformly among the missing
      ones. If all five are owned it adds
      +8 to the weakest instead (ties in cycle order); with all five at 100 it is refused
      and kept. It is granted only by events, from Foundation Establishment on, and can
      be used whenever held.

    After a change that adds an element, the mutations it makes newly eligible roll (rule
    9); a purity change rolls nothing. Every change is recorded in the World Database.
12. **No loss.** A change never removes an element or a mutation, and purity never falls.
    There is no respec.
13. **NPCs** roll and change their roots by the same rules, except Mutation Awakening:
    `breakthrough_succeeded` is player-only (Realms & Bottlenecks rule 9, user decision
    2026-11-04), so NPCs get no Awakening passes. Their mutations come from the birth
    roll and from root changes.

**What the player cannot do:**
- choose the root in a Fated life;
- remove an element or a mutation;
- raise purity above 100;
- make a mutation count as an element.

### States and Transitions

The root has no states. It is a set of values that only grows: the elements and their
purities, the owned mutations with their purities, the **rolled set** (every mutation id
that has rolled or been marked rolled) and the Tẩy Tủy Đan use counter. All four are saved.

| Event | Effect | Guard |
|---|---|---|
| Birth | Elements, purities and mutations set (rule 2) | Once per life |
| Tẩy Tủy Đan | Weakest element +max(1, round(6 × potency)), capped at 100; no mutation roll; owned mutations' purity recomputed | 3 per life; refused (and kept) beyond that, or when every owned element is at 100 |
| Linh Căn Quả | New element at 20–35, then rolls for newly eligible mutations (or +8 to one element: no roll, owned mutations' purity recomputed) | Events only, Foundation Establishment on |
| New mutation formed | Added with its purity and modifiers | Parents owned; not already owned |
| Realm breakthrough | Every unowned mutation whose parents are owned rolls once more (rule 9) | Mutation Awakening (Meridian Map #24) held; a successful realm change |

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Character Stats | out | per-element purity, base element count, mutation modifiers (into the stat sheet), the generating-pair bonus modifier | this GDD (the root); Character Stats (the sheet, the element multipliers) |
| Realms & Bottlenecks | out / in | out: the curve factor by base element count and stage group. In: the player-only `breakthrough_succeeded` event, which triggers the Mutation Awakening roll (rule 9) | this GDD (the curve, the roll); Realms (the stage groups, the event) |
| Meridian Map | out / in | out: purity per element (acupoint scaling), base element count (the center keystone needs all five). In: whether capability #24 (Mutation Awakening) is held, read from the character's capability set; the Meridian Map never calls this system | Meridian Map (the scaling rule, the capability); Character Stats (the capability set); this GDD (the roll, rule 9) |
| Cultivation Techniques | out | purity of the elements and mutations a technique names | Cultivation Techniques |
| Crafts (Alchemy, Spirit Fields, Artifact Refining, Formations) | out | element purities for their roles; craft mutations (Pill Fire, Spirit Farming, Refined Metal, Array) | each craft |
| Item DB, Event Engine | in | Tẩy Tủy Đan and Linh Căn Quả effects (budgeted by events) | Item DB, Event Engine |
| World Database | out | root changes and mutations formed | World Database |
| NPC Builds, World Generation | in / out | NPC roots rolled by the same rules | NPC Builds |
| Codex & Karmic Carryover | out | mutations discovered across lives | Codex |
| Guidance Layer, Debug Terminal, Game UI | out | the root line, tier, purities, mutations and their parents, the curve position | Guidance Layer |
| Save/Load | out | elements, purities, mutations, change counts | Save/Load |

## Formulas

Proposed with `systems-designer` (2026-11-04); figures re-checked by simulation (400,000
births). Values marked *guess* need a bot run; **(change)** marks a difference from the
build. Realm abbreviations: QR, FE, CF, NS, DT.

### A. Birth roll

The birth_roll formula is defined as:

`P(n) = w_n / Σw` ; `P(subset) = 1 / C(5, n)` ; `purity = clamp(round(N(μ, σ)), p_min, p_max)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_n | float | 45 / 32 / 15 / 6.5 / 1.5 | data file (`count_weights`) | Weight for 1–5 elements (user decision) |
| μ, σ | float | 50, 20 | data file (`purity_mean`, `purity_sd`) | Purity distribution |
| p_min, p_max | int | 10, 100 | data file | Purity clamp |
| purity | int | 10–100 | calculated | One owned element's purity |

**Output Range:**
- Tier shares are 45 / 32 / 15 / 6.5 / 1.5 %, so a five-element root is about 1 life in
  67.
- About 2.4 % of purity draws clamp to 10 and 0.67 % to 100; the mean is 50.1.
- The chance that an element has purity ≥ 85 is 4.2 %. By tier, a root has at least one
  such element with chance 4.2 / 8.3 / 12.2 / 15.9 / 19.5 % (7.7 % of all births).

**Draw order (Fated birth).** The seeded RNG is consumed in this order, so a seed always
gives the same root and tests can stub it:
1. **Count:** one uniform draw u. The count is the smallest n with u · Σw ≤ the cumulative
   weight of n (the intervals are (0, 45], (45, 77], (77, 92], (92, 98.5], (98.5, 100]).
2. **Elements:** a partial Fisher–Yates shuffle of [Wood, Fire, Earth, Metal, Water] (cycle
   order). For i = 0 … n−1, one uniform draw u gives j = i + floor(u · (5 − i)), and
   positions i and j swap. The first n positions are the owned elements.
3. **Purities:** one normal draw per owned element, in cycle order (not shuffle order),
   rounded and clamped as above.
4. **Mutations:** the rolls of rule 9, lower order first, catalogue order within an
   order, one uniform draw per eligible mutation.

Self-made birth makes no draws in steps 1–3 (step 4 draws nothing either: rule 2).
The build's own order is aligned in the implementation story (Open Question 7).

**Example:** a count roll of 0.80 falls in (77, 92], so the root has 3 elements. Subset
draws 0.0, 0.0 and 0.9 pick Wood, Fire and Water (the last swaps position 4 into position
2). The purity draws in cycle order are Wood 40, Fire 86 and Water 2 → clamped to 10 (a
draw of −2.4σ).

### B. Element-count curve

The curve_factor formula is defined as:

`curve_factor = element_count_curve[n_base][stage_group]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_base | int | 1–5 | calculated | Base elements only; mutations excluded (**change**) |
| stage_group | enum | 13 keys | data file (Realms & Bottlenecks) | Prefix = realm: `lk` QR, `tc` FE, `kd` CF, `na` NS, `ht` DT. QR `[lk_early, lk_mid, lk_late, lk_late]`; FE `tc_so / tc_trung / tc_hau / tc_dvm`; CF `kd_so / kd_trung / kd_hau / kd_dvm` (early / mid / late / peak); NS `na`; DT `ht`. The table below abbreviates `trung` to `tr` |
| curve_factor | float | 0.3–9.0 | data file (`element_count_curve`) | Speed relative to a single root |

| n | lk_e | lk_m | lk_l | tc_so | tc_tr | tc_hau | tc_dvm | kd_so | kd_tr | kd_hau | kd_dvm | na | ht |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | .6 | .7 | .8 | .9 | **1.0** | 1.3 | 1.6 | 2.0 | 2.4 | 2.8 | 3.1 | 3.5 | 4.0 |
| 3 | .5 | .6 | .75 | .9 | **1.0** | 1.4 | 1.8 | 2.3 | 2.8 | 3.4 | 3.9 | 4.5 | 5.5 |
| 4 | .4 | .5 | .6 | .75 | .9 | **1.0** | 1.5 | 2.1 | 2.8 | 3.6 | 4.3 | 5.0 | 7.0 |
| 5 | .3 | .4 | .5 | .6 | .75 | .85 | .95 | **1.0** | 1.8 | 2.8 | 3.8 | 6.0 | 9.0 |

**Output Range:** 0.3–9.0. The parity points (bold) hold exactly as the concept promised.

Years per realm (Realms & Bottlenecks Formulas A costs, other rate factors 1.25 *guess*,
with each tier's expected pair bonus: 0 / 1.5 / 4.5 / 9 / 15 %), and the share of the half-lifespan ceiling:

| Elements | QR | FE | CF | NS | DT | Whole life |
|---|---|---|---|---|---|---|
| 1 | 25 (42 %) | 64 (64 %) | 187 (75 %) | 456 (91 %) | 925 (93 %) | 1,657 |
| 2 | 33 (56 %) | 52 (52 %) | 71 (28 %) | 128 (26 %) | 228 (23 %) | 513 |
| 3 | 36 (60 %) | 48 (48 %) | 58 (23 %) | 97 (19 %) | 161 (16 %) | 400 |
| 4 | 43 (72 %) | 57 (57 %) | 55 (22 %) | 84 (17 %) | 121 (12 %) | 359 |
| 5 | 50 (84 %) | 69 (69 %) | 79 (32 %) | 66 (13 %) | 89 (9 %) | 354 |

- **The tight spots.** A single root at NS and DT needs other rate factors of at least
  about 1.15; a five-element root in QR is at 84 %. If technique purity (about 0.5 on
  average) sits inside those factors, these lives fail to clear the realm in half their
  lifespan. Realms & Bottlenecks owns that rate, so a bot run must confirm it.
- **The pair bonus fixes QR for five elements.** Without it, a five-element root needs 58
  years in QR, 97 % of the ceiling.

**Example:** a triple root in FE without the pair bonus:
1,223 ÷ (125 × 0.9) + 1,782 ÷ 125 + 2,595 ÷ (125 × 1.4) + 2,360 ÷ (125 × 1.8) = 10.9 +
14.3 + 14.8 + 10.5 = **50.4 years**.

### C. Generating-pair bonus

The pair_bonus formula is defined as:

`pair_pct = pair_bonus_pct · Σ_{i=0..4} [owned(e_i) ∧ owned(e_{(i+1) mod 5})]`

One `cultivation_speed_pct` modifier is added per pair. They add to the other cultivation
speed bonuses (Character Stats, Formulas I).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| e_i | enum | Wood, Fire, Earth, Metal, Water | data file (`cycle`) | The generating cycle |
| pair_bonus_pct | float | 3 | data file (new; user decision) | Bonus per generating pair |
| pair_pct | float | 0–15 | calculated | Total bonus |

**Output Range:** 0–15 %. The pairs are the five edges of a cycle, so:

| Elements | Generating pairs | Bonus |
|---|---|---|
| 1 | 0 | 0 % |
| 2 | 0 or 1 (50 / 50) | 0–3 % |
| 3 | 1 or 2 (50 / 50) | 3–6 % |
| 4 | always 3 | 9 % |
| 5 | always 5 | 15 % |

- **Power check.** One pair is 6.6 W at the Meridian Map's 2.2 W per cultivation speed
  point, about half a notable. All five are 33 W, under the 50 W keystone floor; the
  ceiling for the knob is 4.5 %.
- **Dominance check.** At DT a five-element root runs at 9 × 1.15 = ×10.35 against a
  single root, and with Chaos (+25 %) at ×12.6. A four-element root runs at 7 × 1.09 =
  ×7.6. Over a whole life five elements (354 years) lead four (359) by about 1 %, so
  years alone do not separate the top two tiers.
- **Rare roots are meant to win (user decision 2026-11-04).** Five elements also bring
  the keystone, Chaos, more mutations and all five pairs, so the rarest root is the
  strongest by design (Pillar 1). Its price is a slow, fragile Qi Refining. How large its
  early head start stays open (Open Question 11).

**Example:** Fire, Water and Wood own Wood → Fire and Water → Wood, so 2 pairs and **+6 %**.

### D. Mutation formation

The mutation formulas are defined as:

`chance = f_order · Π_parents (purity_p / 100)` ; `f_1 = bien_di_chance_factor` ; `f_o = bien_di_higher_order_factor / (o − 1)` for o ≥ 2

`purity_m = clamp(round(bien_di_purity_factor · (Π_parents purity_p)^(1/m)), 1, 100)`, using the parents' **current** purities and recomputed whenever one changes

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| purity_p | int | 1–100 | calculated | Each parent's purity |
| o, m | int | 1–4, 2–5 | data file | The mutation's order and parent count |
| bien_di_chance_factor | float | 0.5 | data file | First-order factor |
| bien_di_higher_order_factor | float | 0.25 | data file | Gives 0.25 / 0.125 / 0.083 at orders 2 / 3 / 4 |
| bien_di_purity_factor | float | 0.8 | data file | Purity discount |

**Output Range:**
- A first-order chance runs from 0.5 % (two parents at 10) to 50 % (two at 100), with a
  mean of about 12.6 %.
- A first-order mutation's purity is at most 80. An order-2 mutation can reach 72 (an
  element at 100 with a mutation at 80).
- At birth (simulated):

  | Elements | ≥ 1 first-order mutation | Any higher order | Mean mutations |
  |---|---|---|---|
  | 2 | 12.6 % | 0.2 % | 0.13 |
  | 3 | 32.6 % | 0.8 % | 0.39 |
  | 4 | 53.7 % | 2.2 % | 0.78 |
  | 5 | 71.7 % | 5.0 % | 1.31 |

- Across all births, **13.5 %** have at least one mutation. Chaos is about 0.4 % of
  five-element roots, and Taiji and Time are effectively unreachable at birth.
- Rolls happen once, at first eligibility (rule 9), so these rates hold over a life
  without Mutation Awakening. Linh Căn Quả's new element adds new rolls.
- With Mutation Awakening held, a mutation with chance c that failed has formed by the
  k-th later breakthrough with probability 1 − (1 − c)^(1 + k) at constant purity.
  At most two Awakening passes exist in a life (rule 9), so k ≤ 2: Light at 17.2 %
  reaches at most 1 − 0.828³ = **43 %**, after the birth roll and both passes. The
  capability is priced by the Meridian Map (Open Question 5).

**Example:** Wood 40 and Fire 86 form Light (Quang) with chance 0.5 × 0.40 × 0.86 =
**17.2 %**, at purity round(0.8 × √3,440) = **47**.

### E. Mutation power

The mutation_power formula is defined as:

`power_W = Σ_{k uncapped} w_k · v_k + Σ_{k ceilinged} [ w_k · max(0, min(a_k + v_k, c_k) − min(a_k, c_k)) + w_k · (c'_k − c_k) ]` ; `floor[order] ≤ power_W ≤ band[order]`

`c_k = max(base_k, highest raise on k among the guaranteed ancestors)` ; `c'_k = max(c_k, r_k)`, or c'_k = c_k when the mutation has no raise on k

**Ceilinged keys, priced at the margin (user decision 2026-11-04, fourth-pass review).**
A key under one of Character Stats' character-wide bonus ceilings (its rule 14:
`herb_growth_pct` 10, `alchemy_success` 3, the lifespan bonus 15 % of the realm's base
lifespan) is priced at what the ceiling still lets through **after the mutation's
guaranteed ancestors**, not at its data value. This one rule replaces the earlier per-key
wording and extends it: W10 priced lifespan years up to the ceiling, 04f B1 did the same
for herb growth, and this rule adds `alchemy_success` and makes all three marginal.
- **Guaranteed ancestors** of a mutation are its mutation parents in Formulas D's parent
  list, their mutation parents, and so on to first order. A mutation forms only when every
  parent is owned (rule 9; Self-made picks are validated the same way, rule 2), and nothing
  is ever lost (rule 12), so every guaranteed ancestor's modifiers are on the sheet
  whenever the mutation is. Base elements carry no sheet modifiers, so they add nothing to
  a_k, and Chaos (all five base elements) has no ancestors.
- Only ancestors count. A mutation that merely shares a parent is not guaranteed: Lava is
  not counted for Pill Fire, even on a root that holds both.
- Other sources (techniques, the tree, items, pills, craft mastery) are not counted. They
  are not guaranteed, and the price is the mutation's own worth.

**Root factors are uncapped keys (user decision 2026-11-04).** A modifier of kind "root"
(today only `herb_age_root_pct`) is not a sheet modifier: it is a separate multiplying
factor in the herb-aging formula, like Wood's root term, and sits outside rule 14's herb
growth ceiling. It is not a ceilinged key, so it is priced in full, w_k · v_k, in the
first sum. Character Stats Formulas G and Realms & Bottlenecks Formulas D take it as
`h = (1 + 0.008 · purity_wood) · (1 + herb_age_root_pct/100) · max(0, 1 + herb_growth_pct/100)`.

**Holder-raised ceilings are priced as headroom (user decision 2026-11-04, cross-GDD review
04g, F15).** A mutation with an effect of kind "ceiling_raise" (key k, value r_k) moves
its holder's ceiling on k (Character Stats rule 14). The rule has three parts:
- **The raise is priced in full, as headroom:** w_k · (c'_k − c_k). It counts whether or
  not anything fills it, because techniques, the tree, items and pills can fill the room,
  much as a plot is priced whether or not it is sown. It is marginal over the
  ancestors: c_k already includes the highest raise on k among the guaranteed
  ancestors, and a raise at or below c_k adds 0 W, since raises do not stack. A raise
  held by an owned mutation that is not an ancestor is not counted, just as for lines.
- **The mutation's own line on k is priced against c_k**, the ceiling that holds without
  this mutation's raise.
- **No double counting.** The brief's form prices the line against the raised ceiling,
  min(a_k + v_k, c'_k) − min(a_k, c'_k). That form is equivalent only if the raise is
  then priced for the part of (c_k, c'_k] that the line does **not** fill. Pricing the
  line against c'_k and the raise in full pays twice for the band the line fills: Pill
  Fire would be 8.1 + 16.2 + 15 = 39.3 W, while its holder gets 6 alchemy points (16.2 W)
  and the yield (15 W), which is 31.2 W. Both correct forms give the same total for every
  a_k, v_k, c_k and c'_k. The worth delivered on k is then w_k · (c'_k − a_k) when the
  ancestors and the line reach c'_k.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_k | float | per stat | data file (the Meridian Map's Formulas F weights) | W per unit of key k. Lifespan years are 300 ÷ the QR lifespan, 2.5 W per year, since most lives end in QR. Ceilinged keys: `herb_growth_pct` 0.9, `alchemy_success` 2.7, `lifespan_years` 2.5. Uncapped keys used by Time: `cultivation_speed_pct` 2.2, and the root factor `herb_age_root_pct` 0.9 (priced like herb growth, but in full). `field_plots` **20 W per plot** (Meridian Map Formulas F, repriced from 10 W by cross-GDD review 04g, F11) |
| v_k | float | signed | data file (`character_elements.json`) | The mutation's own fixed modifier on key k |
| a_k | float | ≥ 0 | calculated | Sum of key k over the mutation's guaranteed ancestors (0 for first order and for Chaos) |
| base_k | float | 10 / 3 / 18 | data file (Character Stats `bonus_ceilings`) | Base ceiling for `herb_growth_pct` 10, `alchemy_success` 3, and `lifespan_years` 18: the QR lifespan bonus ceiling, 15 % of 120 years (W10) |
| r_k | float | > base_k | data file (`character_elements.json`, effect kind "ceiling_raise") | The mutation's own raised ceiling on key k: Pill Fire `alchemy_success` 6, Spirit Farming `herb_growth_pct` 20, Lava `alchemy_success` 5 |
| c_k | float | ≥ base_k | calculated | The ceiling on k without this mutation's raise: base_k, or the highest raise on k among the guaranteed ancestors |
| c'_k | float | ≥ c_k | calculated | The holder's ceiling on k with this mutation's raise: max(c_k, r_k); equal to c_k when the mutation has no raise on k |
| band[order], floor[order] | float | ceilings 30 / 60 / 100 / 150 W; floors 10 / 15 / 30 / 50 W | data file (`bien_di_power_band`, new) | User decision |
| power_W | float | see Output Range | calculated | The mutation's price |

Stats the Meridian Map doesn't price (*guess*): travel speed 0.3 W per point,
`alchemy_yield` 15 W per +1, presence 2 W per point.

**Output Range:**
- A ceilinged key's term is bounded: it is 0 when the ancestors already fill the
  ceiling (a_k ≥ c_k), and at most w_k · c_k when a_k = 0 and v_k ≥ c_k. That is 9 W for
  herb growth, 8.1 W for alchemy success and 45 W for lifespan years.
- A raise term is at least 0 and at most w_k · (r_k − base_k), which is 0 when an
  ancestor already holds an equal or higher raise. Today that maximum is 8.1 W for Pill
  Fire's alchemy 3 → 6, 9 W for Spirit Farming's herb growth 10 → 20 and 5.4 W for
  Lava's alchemy 3 → 5. A ceilinged key's line plus raise is at most w_k · r_k.
- Uncapped keys are unbounded in the formula; the band clamps them in data.
- No mutation today has a negative value on a ceilinged key. A negative value on a
  ceilinged key is priced in full (w_k · v_k, negative), because Character Stats applies
  penalties after the cap (its rule 14).
- Each mutation must sit between its order's floor and ceiling. Today's values, which
  need retuning **(change)**:

| Order (floor–ceiling) | Within band | Over or under band |
|---|---|---|
| 1 (10–30) | Light 15, Gravity 15, Ice 24, Wind 15, Poison 26, Darkness 22.5, Mist 22.5, Thunder 20, Lava 13.5 (`alchemy_success` +8 with 3 priced = 8.1 W, plus its raise 3 → 5 = 5.4 W; user decision 2026-11-04; was 22, and 8.1 without the raise) | Over: **Life 34** (herb +30 with 10 priced = 9 W, +10 lifespan years = 25 W) |
| 2 (15–60) | Sword 30, Heavenly Thunder 50, Destruction 30 net, Blood 36, Pill Fire 31.2 (raise 3 → 6 = 8.1 W, alchemy +15 priced to the pre-raise 3 = 8.1 W, `alchemy_yield` 15 W; was 23.1), Spirit Farming 49 (raise 10 → 20 = 9 W; herb +60 adds 0 over Life's 30 at the pre-raise 10; +2 plots at 20 W = 40 W; was 20), Soul 52, Illusion 57.5, Space 50 (travel +100 = 30 W, +1 plot = 20 W; was 40), Yin 22, Yang 22 | Over: **Array 73, Stars 75, Refined Metal 62.5**. Under: **Death 5 net** (its −10 presence eats it) |
| 3 (30–100) | Chaos 80 | Over: **Taiji 133**. Under: **Reincarnation 20** (+50 years over Life's 10: 18 − 10 = 8 years priced; was 45) |
| 4 (50–150) | Time 110.5 (+40 % cultivation speed = 88 W, plus the herb-aging root factor +25 % = 22.5 W, priced in full; was 0) | — |

What the margin shows:
- Time's old +200 years and +100 % herb growth add nothing (0 W). A character who holds
  Time already holds Reincarnation and Life, whose 60 years and 30 % fill both ceilings.
  Its power now comes from two uncapped lines instead (user decision 2026-11-04), and the
  two old lines are dropped in the data pass.
- Reincarnation adds 8 years over Life.
- Spirit Farming's herb line adds nothing over Life at the base ceiling. Its herb
  identity is now the raise, 10 → 20 (9 W), which its +60 % fills for the holder.
- Pill Fire's alchemy is now delivered up to 6 through its raise, and Lava's up to 5
  through its own.
- Plots at 20 W are now most of Spirit Farming's price (40 of 49 W) and two-fifths of
  Space's (20 of 50 W).

These data values stay for now and show as held back: Time (+200 years, +100 % herb
growth; the data file still holds them until the data pass, but they are not design
values), Reincarnation (+50 years), Spirit Farming (+60 %; 20 is delivered at most),
Pill Fire (+15; 6 is delivered at most) and Lava (+8; 5 is delivered at most).
The data pass in Open Question 1 trims or replaces them, and adds Time's two new lines. A mutation never exists without
its ancestors, and the herb growth and alchemy ceilings are flat, so those held-back parts
are never delivered. The lifespan ceiling grows with realm (15 % of base lifespan), so
held-back years do deliver more after QR; the price uses QR by decision W10.

For the over-band mutations, Life must fall to 30 W (by 4), Array, Stars and Refined
Metal to 60 W (by 13, 15 and 2.5 W) and Taiji to 100 W (by 33). Death needs a larger positive side (Destruction's
30 W net is inside its band). Each value must also respect the Meridian Map's compounding
caps (for example Stars' +10 comprehension against a cap of 1 per cluster; that cap is for
clusters, but it shows the scale).

**Example:** Light: `tam_ma_resist_pct` +10 × 1.5 = **15 W**. Heavenly Thunder: 35 ×
1.0 + 3 × 5 = **50 W**. Reincarnation: its one guaranteed ancestor with lifespan is Life
(+10; Death has none), so 2.5 × (min(10 + 50, 18) − min(10, 18)) = 2.5 × 8 = **20 W**.
Time: its design lines are uncapped, so 2.2 × 40 (`cultivation_speed_pct`) + 0.9 × 25
(`herb_age_root_pct`, a root factor, ×1.25 on h) = 88 + 22.5 = **110.5 W**, inside the
order-4 band of 50–150 W. Its old +200 years and +100 % herb growth would add 0 W: its
ancestors (Space, Gravity, Wind, Reincarnation, Life, Death, Darkness and Poison) give
a = 60 years and 30 % herb growth, both at or above the ceilings.

**Example (holder-raised ceilings):** Pill Fire has no ancestor with alchemy (Life has
none), so c = 3 and c' = 6. Its line is 2.7 × (min(0 + 15, 3) − 0) = 8.1 W, its raise is
2.7 × (6 − 3) = 8.1 W, and `alchemy_yield` +1 is 15 W, making **31.2 W**. That equals
the worth it delivers: 6 points (16.2 W) plus the yield. Spirit Farming's ancestor Life
holds +30 % herb growth, so c = 10 and c' = 20. Its line is 0.9 × (min(90, 10) −
min(30, 10)) = 0 W, its raise is 0.9 × 10 = 9 W, and +2 plots are 2 × 20 = 40 W, making
**49 W**, inside the order-2 band (60 W). The holder's herb growth goes from 10 to 20,
which is 10 points, or 9 W.

### F. Root changes

The root_change formulas are defined as:

`gain = max(1, round(tay_tuy_value · potency))` ; `purity' = min(100, purity + gain)` (Tẩy Tủy Đan, on the weakest owned element)

`purity_new ~ U{20..35}` for an added element (Linh Căn Quả), or `min(purity + raise, 100)` when all five are owned

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tay_tuy_value | int | 6 | data file (`items_recipes.json`) | Base purity per pill |
| potency | float | 0–about 2 | calculated (Character Stats, Formulas D) | Pill potency (quality, toxicity, `pill_effect_pct`) |
| max_uses | int | 3 | data file | Tẩy Tủy Đan per life |
| purity range, raise | int | 20–35, 8 | data file (`items_treasures.json`) | Linh Căn Quả |

**Output Range:**
- Three Tẩy Tủy Đan at quality 1 and low toxicity give about +8 each, **+24** in total
  (*guess*). The gain always lands on the weakest element, so per element it averages
  12 / 8 / 6 / 4.8 for 2–5 elements.
- A Linh Căn Quả adds an element at 27.5 on average. That changes the tier, the curve
  row and the pairs, and rolls the newly eligible first-order mutations. On a root of 1
  / 2 / 3 / 4 elements, the new pairs give an expected chance of at least one new
  first-order mutation of 7 / 13 / 19 / 25 % at average purities (this is not the pair
  bonus, which is +3 % per generating pair).
- Purity pills never roll mutations (rule 9), but they recompute owned mutations' purity.
  Wood 40 → 48 with Fire 86 moves Light from 47 to round(0.8 × √(48 × 86)) = **51**.

**Example:** Water 10 with potency 1.25 → +8, so Water 18 (no roll). A Linh Căn Quả on
{Wood 40, Fire 86} adds Earth 28. The new pair Fire → Earth takes the pair bonus from +3 % to +6 %. Two
mutations become eligible and roll once each: Lava at 0.5 × 0.86 × 0.28 = **12 %** and
Poison (Wood–Earth) at 0.5 × 0.40 × 0.28 = **5.6 %**.

### G. Purity as a scale (owned elsewhere)

Restated for reference:
- **The Meridian Map** owns acupoint scaling: 0.5 + purity ÷ 100, or 0.25 if absent, so
  0.6–1.5.
- **Cultivation Techniques** owns the technique factor: the average purity of the ids it
  names ÷ 100, about 0.5 for a typical root.
- **Character Stats** owns the element role formulas (Formulas G).

**Example:** with Wood 40 and Fire 86, a Wood–Fire bridge acupoint is (0.9 + 1.36) ÷ 2 =
1.13, and a technique naming both runs at 0.63.

### Parameter keys

**`character_attributes.json` (`linh_can`):**
- `count_weights` {1: 45, 2: 32, 3: 15, 4: 6.5, 5: 1.5} **(change)**;
- `purity_mean` 50, `purity_sd` 20, `purity_min` 10, `purity_max` 100;
- `pair_bonus_pct` 3 **(new)**;
- `bien_di_chance_factor` 0.5, `bien_di_higher_order_factor` 0.25,
  `bien_di_purity_factor` 0.8;
- `bien_di_power_band` [30, 60, 100, 150] **(new)**;
- removed: `bien_di_counts_as_element` and `max_counted_elements` (dead once mutations
  stop counting) **(change)**.

**`character_attributes.json` (`element_count_curve`):** unchanged values, keyed by base
element count.

**`character_elements.json`:** mutation `effects` retuned into their bands **(change)**.
Effects gain a new kind, **"root" (new)**: a root factor that multiplies its formula
directly instead of adding to the stat sheet, and sits outside the character-wide
ceilings. Today only Time uses it: `herb_age_root_pct` 25 (×1.25 on herb aging h),
alongside `cultivation_speed_pct` 40 (Formulas E).
Effects also gain the kind **"ceiling_raise" (new; user decision 2026-11-04, cross-GDD
review 04g, F15)**, with a key and a value. The key is a Character Stats `bonus_ceilings`
key, and the value is the holder's raised ceiling (Character Stats rule 14). It is not a
sheet modifier. The data pass adds three raises: Pill Fire (`dan_hoa`) `alchemy_success` 6,
Spirit Farming (`linh_thuc`) `herb_growth_pct` 20, and Lava (`dung_nham`)
`alchemy_success` 5 (user decision 2026-11-04).

## Edge Cases

**Birth**

- **If a purity draw falls outside 10–100:** it is clamped. About 2.4 % of draws land on
  10 and 0.6 % on 100.
- **If the root has five elements:** it holds all five generating pairs and is eligible
  for Chaos at birth.
- **If a Self-made player picks mutations:** they need the parents owned, cost nothing
  (Self-made is the casual mode, with achievements off) and never count toward the
  curve. The picked mutations still obey their power bands.
- **If a Self-made player picks the strongest root:** five elements at 100 plus every
  mutation is allowed. Free picks make it the dominant choice, and that is accepted by
  user decision 2026-11-04: Self-made is casual, and Fated lives are the competitive
  mode.

**Root changes**

- **If several elements tie for weakest when a Tẩy Tủy Đan is taken:** the first in
  cycle order (Wood, Fire, Earth, Metal, Water) gains.
- **If every owned element is already at 100:** the Tẩy Tủy Đan cannot be taken and is
  not consumed.
- **If a Linh Căn Quả is used with all five elements owned:** the +8 goes to the weakest
  element, ties in cycle order, capped at 100. Nothing rolls; the purity of owned
  mutations built on that element is recomputed (rule 9).
- **If an added element raises the element count mid-realm:** the tier, the curve row
  and the generating pairs change at once. In an early stage the curve factor can fall,
  so cultivation slows until the curve's crossover. The UI shows the old and new speed
  before the fruit is used.
- **If a newly formed mutation makes a higher order eligible:** that higher order rolls
  in the same pass, because lower orders roll first.
- **If a mutation already rolled and failed:** it never rolls again in that life (rule
  9), except through Mutation Awakening. The root keeps the set of rolled mutation ids.
- **If Mutation Awakening is held and no unowned mutation has its parents owned:** the
  breakthrough makes 0 rolls and writes no record.
- **If an Awakening roll forms a mutation that is a parent of a higher order:** the higher
  order rolls in the same pass (a first roll if it was never eligible, a re-roll if it
  failed earlier).
- **If a Self-made life left eligible mutations unpicked:** they are in the rolled set, so
  Mutation Awakening can still form them.
- **If a Tẩy Tủy Đan raises an element:** the purity of every owned mutation built on it is
  recomputed, lowest order first, with no roll; the modifiers do not change.

**Use by other systems**

- **If a technique names a mutation the root lacks:** the technique cannot run at its
  speed. Cultivation Techniques owns the fallback (as built, ×0.3 of the strongest
  purity).
- **If a mortal NPC has no root:** it does not cultivate and is outside this system. A
  cultivator always has at least one element.

**Saves**

- **If a save comes from the build where mutations counted toward the curve:** the curve
  now uses the base count, and the mutations stay owned. Their modifiers are recomputed
  from the retuned data, and their purity from the current parents (a stored purity is
  ignored).
- **If a save has no rolled-mutation set:** every mutation whose parents are owned is
  marked as rolled on load. This preserves the save's outcome and prevents a free
  re-roll.

## Dependencies

**Upstream:**

| # | System | What Spiritual Roots needs from it |
|---|---|---|
| 1 | Data-Driven Config | `character_attributes.json` (`linh_can`, `element_count_curve`), `character_elements.json` |
| 2 | Deterministic Simulation Core | The seeded RNG for the birth roll and mutation rolls |

**Upstream, soft (needed for a part of the system):**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 8 | Realms & Bottlenecks | The stage group for the curve lookup; the `breakthrough_succeeded` event | No curve position; Mutation Awakening never rolls |
| 7 | Character Stats | The capability set (rule 16), to check whether #24 is held | Mutation Awakening never rolls |

**Downstream:**

| # | System | What it takes |
|---|---|---|
| 7 | Character Stats | Purities, base element count, mutation modifiers and pair-bonus modifiers (through its provider interface); Time's root factor `herb_age_root_pct` (kind "root") for Formulas G's herb growth; the holder-raised ceilings (kind "ceiling_raise") of Pill Fire and Spirit Farming for rule 14 |
| 8 | Realms & Bottlenecks | The curve factor by base element count and stage group; Time's `herb_age_root_pct` in Formulas D's herb growth factor h |
| 10 | Meridian Map | Purity per element; base element count for the center keystone |
| 9 | Cultivation Techniques | Purity of the elements and mutations a technique names |
| 14–18 | Crafts | Element purities for their roles; craft mutations |
| 13, 23 | Item DB, Event Engine | They call the root-change rules (Tẩy Tủy Đan, Linh Căn Quả) |
| 3 | World Database | Root changes and mutations formed |
| 24, 27 | NPC Builds, World Generation | NPC roots by the same rules |
| 12 | Codex & Karmic Carryover | Mutations discovered across lives |
| 35–37 | Guidance Layer, Debug Terminal, Game UI | The root display |
| 5 | Save/Load | Elements, purities, mutations, rolled set, pill counts |

**Cycles and how they are broken:**
- **Spiritual Roots ↔ Realms & Bottlenecks.** Realms reads the curve factor; Spiritual Roots
  takes the stage group as a lookup argument and subscribes to the `breakthrough_succeeded`
  event. Realms never calls this system, and this system never calls Realms.
- **Spiritual Roots ↔ Character Stats and the Meridian Map.** Both read purities and the
  base element count. This system reads only the capability set, which the Meridian Map
  writes and Character Stats holds; the Meridian Map never calls it (its capability-host
  rule).
- Item DB and the Event Engine invoke the change rules (rule 11); this system reads nothing
  from them.

## Tuning Knobs

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `count_weights` | 45 / 32 / 15 / 6.5 / 1.5 | five-element weight 0.5–3; the weights sum to 100 | Tier rarity; the five-element share is also the share of lives that can reach the center keystone (*derived*) |
| `purity_mean` | 50 | 40–60; *derived* floor 40, below which five-element roots fail QR in time | Every purity-scaled value |
| `purity_sd` | 20 | 15–25 | The share of purity ≥ 85 per element: 1.1 % at 15, 4.2 % at 20, 8.4 % at 25 |
| `purity_min` | 10 | 5–20 | The lowest purity; mutations from minimum-purity parents |
| `pair_bonus_pct` | 3 | 1–4.5; *derived* ceiling 4.5 (5 pairs under the 50 W keystone floor) | The pair bonus; at 2 four- and five-element roots tie, at 4+ five pulls ahead |
| `bien_di_chance_factor` | 0.5 | 0.3–0.6 | First-order rate: about 9 % of births at 0.3, 13.5 % at 0.5, 16 % at 0.6 |
| `bien_di_higher_order_factor` | 0.25 | 0.1–0.4 | Higher-order rates |
| `bien_di_purity_factor` | 0.8 | 0.6–1.0 | Mutation purity |
| `bien_di_power_band` | ceilings 30 / 60 / 100 / 150 W; floors 10 / 15 / 30 / 50 W | each band ≤ the next; the order-2 ceiling (60 W) already exceeds the weakest keystone (50 W, registry `keystone_min_power`), so raising it widens that gap (*derived*) | How strong a mutation may be |
| Time's root factor `herb_age_root_pct` (effect kind "root") | 25 (×1.25 on h), 22.5 W | any value keeping Time inside 50–150 W with its +40 % cultivation speed (88 W): 0–68; priced in full at 0.9 W per % (not ceilinged) | Herb aging for an apex holder, multiplying like Wood's root term outside the herb growth ceiling. Read by Character Stats Formulas G and Realms Formulas D (h); registry entry `herb_age_root_pct` |
| Holder-raised ceilings (effect kind "ceiling_raise") | Pill Fire `alchemy_success` 6 (31.2 W); Spirit Farming `herb_growth_pct` 20 (49 W); Lava `alchemy_success` 5 (13.5 W; user decision 2026-11-04) | Inside each band at 2.7 W per alchemy point and 0.9 W per herb %: Pill Fire 4–16, Spirit Farming 11–32, Lava 4–11. Keep Lava below Pill Fire, so the order-2 craft mutation stays the alchemy identity. Any Pill Fire change re-runs Realms' AC-CG-60 | How far a craft holder outgrows the flat character-wide ceiling. Read by Character Stats rule 14 |
| `element_count_curve` | Formulas B | any change must keep the parity points | Pacing by tier |
| Tẩy Tủy Đan, Linh Căn Quả values | 6 × 3 per life; 20–35 or +8 | owned by Item DB | Root growth over a life |

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). Intent: each element has its colour (the data
already holds an ANSI colour per element); mutations show their parents; a mutation forming
is a celebrated moment.

## Game Feel

Not specified at this tier. Intent: the birth roll is the run's first big reveal; a
five-element root should feel like a gamble on the long game, and a mutation like a
gift.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.
- **The root line.** It shows the tier, each element with its purity (in its colour) and
  each mutation with its purity, for example "Triple root: Wood 40, Fire 86, Water 10 |
  Light 47".
- **Speed.** The current curve factor, where parity comes, and the generating pairs with
  their +3 % each.
- **Mutations.** Each owned mutation's parents and bonuses (via `explain`). Mutations
  that rolled and failed are not shown as available.
- **Root changes.** Before a Linh Căn Quả is used, the screen shows the new tier and the
  speed before and after; a Tẩy Tủy Đan shows which element it will raise.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Spiritual Root System (tiers, the trade-off, mutations, changing roots); its open question on counting mutations is answered here (they don't) |
| `design/gdd/canh-gioi.md` | Stage groups and the years-per-realm costs (Formulas A); its five-element DT figure (103 years, 89 with the pair bonus) matches Formulas B (Open Question 4, closed); the player-only `breakthrough_succeeded` event that Mutation Awakening reads (rule 9); Formulas D's herb growth factor h, which reads Time's `herb_age_root_pct` |
| `design/gdd/character-stats.md` | Element role formulas (Formulas G), the stat sheet and its provider interface; rule 14 (the ceilings, the root-term test, penalties after the cap), which Formulas E prices against |
| `design/gdd/kinh-mach-do.md` | Acupoint scaling (rule 4), stat weights W for mutation power (Formulas F) |
| `design/gdd/cong-phap.md` | Rule 7's purity contract, which a technique's speed (`match`) and bonuses (F) read; usability of techniques naming a mutation (its rule 8) |
| `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md` | Tẩy Tủy Đan and Linh Căn Quả |
| `design/glossary.md` | Element and mutation names |
| `assets/data/character_attributes.json`, `character_elements.json` | The data this GDD's keys change |
| `src/gameplay/character/linh_can.gd`, `src/gameplay/cultivation/cultivation_rules.gd` | Code the (change) items touch |

## Acceptance Criteria

Drafted with `qa-lead`, which recomputed every number and checked the rates on 4,000,000
simulated births.

- **Gate levels.** Logic, Integration and UI are BLOCKING; Config/Data is ADVISORY.
- **Suites.** Logic suites live in `tests/unit/character/` (next to
  `linh_can_rules_test.gd` and `linh_can_change_test.gd`); integration suites live in
  `tests/integration/character/`. Every statistical test uses a fixed seed, with
  tolerances of about four standard errors.
- **UI evidence** is a debug-terminal transcript kept with its ANSI colour codes in
  `production/qa/evidence/debug-terminal/`.

**Birth**

- **AC-LC-01** [Config/Data] The data holds:
  - `count_weights` 45 / 32 / 15 / 6.5 / 1.5 (summing to 100);
  - purity 50 / 20 / 10 / 100;
  - `pair_bonus_pct` 3;
  - the three mutation factors 0.5 / 0.25 / 0.8;
  - the power-band ceilings and floors.

  `bien_di_counts_as_element` and `max_counted_elements` are gone, from the data and from
  `src/`.
- **AC-LC-02** [Logic] Formula A. Stubbed count draws 0.30 / 0.60 / 0.80 / 0.95 / 0.99
  give 1 / 2 / 3 / 4 / 5 elements.
- **AC-LC-03** [Logic] Rule 2, over 200,000 births:
  - tier shares 45 / 32 / 15 / 6.5 / 1.5 % (±0.5 pp);
  - among 2-element roots each of the 10 pairs appears 10 % ± 1.0 pp of the time, and
    among 3-element roots each of the 10 triples does.
- **AC-LC-04** [Logic] Rounding, not truncating. Raw 59.6 / 84.5 / 10.4 / 10.5 / 99.5 /
  2.0 / 130 gives 60 / 85 / 10 / 11 / 100 / 10 / 100.
- **AC-LC-05** [Logic] Formula A distribution, over 200,000 draws:
  - exactly 10: 2.41 % (±0.2 pp); exactly 100: 0.67 % (±0.1 pp);
  - ≥ 85: 4.24 % (±0.25 pp); mean 50.1 (±0.2);
  - roots with any element ≥ 85: 4.2 / 8.3 / 12.2 / 15.9 / 19.5 % by tier (±1.0 pp), and
    7.7 % overall.
- **AC-LC-06** [Logic] The Formula A example, with a stub RNG returning, in order: 0.80
  (count); 0.0, 0.0, 0.9 (elements); normal draws 40.0, 86.0, 2.0 (purities); 0.99, 0.99,
  0.99 (the Light, Life and Mist rolls). The root is {Wood 40, Fire 86, Water 10}, a
  Triple root with no mutations, the rolled set is {Light, Life, Mist}, and the stub was
  consumed in exactly that order with nothing left over.
- **AC-LC-07** [Logic] Rule 3. Tiers 1–5 are named correctly. {Wood, Fire} plus Light is
  Dual; all five plus Chaos is Five-element.
- **AC-LC-08** [Logic] Rule 2, Self-made.
  - Picked purities are kept, and the RNG is called 0 times.
  - Purity 9 or 101 is rejected at input.
  - A mutation without its parents is rejected; one with its parents is accepted at the
    formula purity.
  - Every eligible mutation goes into the rolled set, picked or not.

**Curve and pairs**

- **AC-LC-09** [Config/Data] `element_count_curve` equals the Formulas B table (65
  values).
- **AC-LC-10** [Logic] Rule 4, the curve's shape.
  - The parity points are exactly 1.0, and each column before them is below 1.0.
  - `lk_early` falls with element count (1 / 0.6 / 0.5 / 0.4 / 0.3).
  - `ht` rises (1 / 4 / 5.5 / 7 / 9).
  - No row ever falls from one stage group to the next.
- **AC-LC-11** [Logic] Mutations excluded.
  - {Wood 40, Fire 86} plus Light gives 0.6 at `lk_early` and 4.0 at `ht`.
  - For 1,000 seeded roots, the factor with mutations equals the factor without them.
- **AC-LC-12** [Logic] Formula C, over all 31 element subsets:
  - 1 element → 0 pairs; 2 → 50 / 50 between 0 and 1; 3 → 50 / 50 between 1 and 2; 4 →
    3; 5 → 5;
  - {Fire, Water, Wood} → 2 pairs, +6 %;
  - overcoming pairs and mutations add nothing.
- **AC-LC-13** [Logic] Over 200,000 births, the pair distributions match AC-LC-12
  (±1.0 pp).
- **AC-LC-14** [Integration] With Realms & Bottlenecks: a triple root in FE at 125 a
  year, with no pair bonus, takes 10.87 + 14.26 + 14.83 + 10.49 = **50.44 ± 0.1 years**.

**Mutations**

- **AC-LC-15** [Config/Data] The catalogue.
  - 29 mutations, 10 / 15 / 3 / 1 by order.
  - The 10 first-order mutations cover the 10 element pairs: generating pairs are
    `stable`, overcoming pairs are `volatile`.
  - Chaos has all five elements as parents, and every parent exists.
  - Every mutation's order is above that of each mutation parent.
- **AC-LC-16** [Logic] Formula D chances, within 1e-9:
  - Light (40, 86) = 0.172;
  - Pill Fire (86, Life 47) = 0.10105;
  - Chaos (all 50) = 0.00390625;
  - Time (40, 40) = 0.013333;
  - first order at 10 / 10 = 0.005, and at 100 / 100 = 0.5.
- **AC-LC-17** [Logic] Formula D purity:
  - Light (40, 86) → 47; Lava (86, 28) → 39; Pill Fire (86, 47) → 51;
  - Chaos (40, 86, 28, 50, 10) → 28;
  - 10 / 10 → 8; 100 / 100 → 80; an element at 100 with a mutation at 80 → 72.
- **AC-LC-18** [Logic] Over 50,000 rolls, Light on {Wood 40, Fire 86} forms 17.2 % ±
  0.8 pp of the time, always at purity 47.
- **AC-LC-19** [Logic] Birth rates by tier (50,000 births each):
  - at least one first-order mutation: 12.6 / 32.6 / 53.7 / 71.7 % (±1.0 pp);
  - any higher order: 0.2 / 0.8 / 2.2 / 5.0 % (±0.3 pp);
  - mean mutations 0.13 / 0.39 / 0.78 / 1.31 (±0.02 / ±0.03 / ±0.04 / ±0.05). The test
    also asserts that each listed tolerance is at least four standard errors of that
    run's mean (4 × the sample standard deviation ÷ √50,000), so a tolerance too tight
    for the data fails on the fixed seed instead of passing by luck;
  - Chaos in 0.40 % (±0.15 pp) of five-element roots.
- **AC-LC-20** [Logic] Over 200,000 births, 13.5 % ± 0.5 pp have at least one mutation.
- **AC-LC-21** [Logic] Rule 9, ordering and chaining, on {Wood, Fire, Water}:
  - with every roll forced to succeed: {Light, Life, Mist, Pill Fire}, with all three
    first-order rolls before Pill Fire's;
  - with every roll forced to fail: no mutations, and the rolled set is {Light, Life,
    Mist}.
- **AC-LC-22** [Logic] Rule 9, rolling once.
  - A second formation pass makes 0 rolls.
  - Three Tẩy Tủy Đan and a five-element Linh Căn Quả make 0 rolls.
  - A failed mutation never rolls again, unless Mutation Awakening is held (AC-LC-45).
- **AC-LC-23** [Logic] Rule 10.
  - Light counts as owned, but `base_count()` is unchanged.
  - A technique naming [Wood, Light] at 40 / 47 runs at 0.435.
  - Light's modifier is the same at purity 47 and at purity 80.
- **AC-LC-24** [Logic] Formula E, power, with fixed fixtures that do not read the data
  files that Open Question 1 retunes:
  - Light (`tam_ma_resist_pct` +10) is 15 W;
  - a fixture of 35 × 1.0 W plus 3 × 5 W is 50 W;
  - a fixture with a 25 W positive side and presence −10 nets 5 W (presence at 2 W per
    point);
  - the ceilinged-key fixtures use hard-coded fixture values, not the data: ceilings
    `herb_growth_pct` 10, `alchemy_success` 3 and `lifespan_years` 18, and weights 0.9,
    2.7 and 2.5 W per unit. A data change to Character Stats' `bonus_ceilings` or the
    Meridian Map's weights does not change these expectations;
  - with no ancestors, lifespan is priced up to 18 years: +200 `lifespan_years` is 45 W
    and +10 is 25 W (W10);
  - with no ancestors, herb growth is priced up to 10: +100 or +30 `herb_growth_pct` is
    9 W, and +5 is 4.5 W (04f, B1);
  - with no ancestors, `alchemy_success` +8 is 3 × 2.7 = 8.1 W, and +2 is 5.4 W;
  - marginal over ancestors: a fixture mutation with +60 `herb_growth_pct` whose
    ancestor holds +30 (already at the ceiling) is 0 W on that key; one with +50
    `lifespan_years` whose ancestor holds +10 is 2.5 × 8 = 20 W; a fixture whose
    ancestor chain holds +60 years and +30 % herb growth prices +200 years and +100 %
    herb growth at 0 W;
  - only ancestors count: a fixture mutation with +15 `alchemy_success` and no ancestors
    is 8.1 W even when another owned mutation that is not its ancestor holds +8;
  - a root factor is priced in full, not as a ceilinged key: a fixture with
    `herb_age_root_pct` +25 (kind "root") is 25 × 0.9 = 22.5 W, even when its ancestors
    hold +30 % `herb_growth_pct`; adding +40 `cultivation_speed_pct` at 2.2 W per % makes
    110.5 W;
  - plots use a hard-coded fixture weight of 20 W per plot: +2 `field_plots` is 40 W and
    +1 is 20 W (04g, F11);
  - holder-raised ceilings (kind "ceiling_raise"), with the fixture ceilings and weights
    above:
    - with no ancestors, `alchemy_success` +15 and a raise 3 → 6 is 8.1 W (line, priced to
      3) + 8.1 W (raise) = 16.2 W, **not** 24.3 W (the band 3–6 is not paid twice);
    - with no ancestors, `alchemy_success` +2 and a raise 3 → 6 is 5.4 + 8.1 = 13.5 W
      (the unfilled headroom is still priced);
    - a raise with no line on that key, `herb_growth_pct` 10 → 20, is 9 W;
    - marginal over an ancestor's line: `herb_growth_pct` +60 and a raise 10 → 20, with an
      ancestor holding +30, is 0 + 9 = 9 W; adding +2 `field_plots` makes 49 W;
    - marginal over an ancestor's raise: a raise of `alchemy_success` 3 → 6 whose ancestor
      raises it to 5 is 2.7 W, and a raise to 4 under an ancestor's raise to 6 is 0 W (no
      stacking);
    - only ancestors count: a raise 3 → 6 with no ancestors is 8.1 W even when an owned
      mutation that is not its ancestor raises the same key to 5;
    - the equivalent form gives the same totals in every fixture above: the line priced
      against c' plus the raise priced only for the part of (c, c'] the line leaves
      empty;
    - the fixture of `alchemy_success` +15, a raise 3 → 6 and `alchemy_yield` +1 at 15 W
      is 31.2 W.
- **AC-LC-25** [Config/Data] Every mutation's power (Formulas E, with ancestors from the
  data) is within its order's ceiling and floor. This is expected to fail until Open
  Question 1's data retune:
  - over the ceiling: Life (34 W), Array (73), Stars (75), Refined Metal (62.5) and Taiji
    (133);
  - under the floor: Death (5 W net) and Reincarnation (20 W).

  Raises are read from the data's "ceiling_raise" effects and plots are priced at 20 W.
  With the three decided raises, Pill Fire (31.2 W), Lava (13.5 W), Spirit Farming (49 W)
  and Space (50 W) are inside their band. Before the data pass adds the raises, Pill Fire
  prices at 23.1 W and Spirit Farming at 40 W, and both are still in band; Lava prices at
  8.1 W and fails its floor until its raise is added. Time is 110.5 W
  once the data pass gives it its design lines (Open Question 1); with today's data it
  still prices at 0 W and fails until then.

**Root changes**

- **AC-LC-26** [Logic] Rule 11, Tẩy Tủy Đan.
  - Water 10 at potency 1.25 → 18, with 0 RNG calls.
  - Potency 0.05 → +1, and potency 0 → +1.
  - A weakest element at 97 with potency 1.0 → 100.
- **AC-LC-27** [Logic] Ties go in cycle order.
  - {Water 30, Metal 50, Fire 30} → Fire gains.
  - {Water 30, Wood 30} → Wood gains.
- **AC-LC-28** [Logic] With every owned element at 100, the pill is refused and **kept**:
  the inventory, the use counter, the purities and the World Database are all unchanged.
- **AC-LC-29** [Logic] A fourth Tẩy Tủy Đan in one life is refused and kept.
- **AC-LC-30** [Logic] The Formula F example. Starting from {Wood 40, Fire 86}, with Light
  already rolled, the fruit adds Earth 28:
  - the root becomes Triple and the pairs go from +3 % to +6 %;
  - exactly two rolls: Lava 0.1204 and Poison 0.056; Light does not roll again.
  - Over 16,000 draws, the added purity is uniform over 20–35 (each value 6.25 % ±
    0.8 pp, about four standard errors).
- **AC-LC-31** [Logic] A Linh Căn Quả chains in one pass.
  - {Wood 40, Water 60}, with Life rolled and failed, plus Earth, every roll forced to
    succeed → {Poison, Darkness, Death}. Life never rolls again.
  - {Wood, Fire, Earth, Metal} plus Water, with every earlier mutation rolled and failed
    and every roll forced to succeed, forms exactly ten, in one pass and order by
    order: {Ice, Life, Darkness, Mist} (order 1, catalogue order), then {Pill Fire, Spirit
    Farming, Soul, Illusion, Yin} (order 2), then {Chaos} (order 3).
- **AC-LC-32** [Logic] A Linh Căn Quả with all five owned, on {Wood 50, Fire 30, Earth 60,
  Metal 30, Water 90}:
  - Fire gains 8, to 38 (a tie broken in cycle order);
  - a weakest element at 95 → 100;
  - 0 rolls, and the purity of an owned mutation built on the raised element is
    recomputed (AC-LC-46's rule);
  - with all five at 100, it is refused and kept.
- **AC-LC-33** [Logic] Rule 12. Over 1,000 random sequences of changes, the element and
  mutation sets never lose a member, no purity falls, and none exceeds 100.
- **AC-LC-34** [Integration] A single root in FE early stage uses a Linh Căn Quả (the
  fixture grants it; events grant it from FE on). The next cultivation tick reads a curve
  factor of 0.9 (two elements, `tc_so`) and the new pair count.

**Contracts**

- **AC-LC-35** [Integration] Character Stats. With Light owned, the sheet has exactly one
  modifier from it: `tam_ma_resist_pct`, at its current data value, with source
  "Biến dị: Quang".
- **AC-LC-36** [Integration] Character Stats, pairs.
  - {Wood, Fire, Water} gives exactly two `cultivation_speed_pct` +3 modifiers, sourced
    "Tương sinh: Mộc → Hỏa" and "Tương sinh: Thủy → Mộc".
  - A five-element root gets five modifiers totalling +15; a single root gets none.
- **AC-LC-37** [Integration] Realms & Bottlenecks.
  - The stage-group mapping is QR `lk_early` / `lk_mid` / `lk_late` / `lk_late`; FE
    `tc_so` / `tc_trung` / `tc_hau` / `tc_dvm`; CF `kd_so` / `kd_trung` / `kd_hau` /
    `kd_dvm`; NS `na`; DT `ht`.
  - A triple root with mutations reads 0.75 at QR stage 4, 4.5 at NS and 5.5 at DT.
- **AC-LC-38** [Integration] Meridian Map and Cultivation Techniques, with {Wood 40, Fire
  86}:
  - the Wood sector scales 0.9, Fire 1.36, the absent Earth 0.25;
  - the bridge is 1.13 and a Wood–Fire technique runs at 0.63;
  - the center keystone is locked for {Wood 40, Fire 86} (2 base elements). Two further
    fixture roots check the threshold: {Wood, Fire, Earth, Metal} plus Light, Lava and
    Gravity (4 base elements plus mutations) stays locked, and all five base elements
    unlock it (the Meridian Map's rule: refused with 4, allowed with 5).
- **AC-LC-39** [Integration] World Database. Each change and each formed mutation writes
  exactly one record with the old and new values. A refused item writes none.
- **AC-LC-40** [Integration] Rule 13. An NPC with the same seed gets the same root and
  rolled set as a player; every NPC cultivator has at least one element; NPC pills follow
  AC-LC-26 to AC-LC-28; an NPC stage advance or breakthrough makes 0 Awakening rolls and
  writes 0 records.

**Persistence**

- **AC-LC-41** [Logic] A save/load round trip keeps:
  - the elements, purities and mutations;
  - the rolled set and the pill count, so after a reload a fourth pill is still refused
    and a failed mutation still never rolls.
- **AC-LC-42** [Logic] An old save with no rolled set: {Wood 40, Fire 86, Water 60} with
  Life.
  - It loads with the rolled set {Light, Life, Mist, Pill Fire}.
  - A later Earth fruit, every roll forced to succeed, forms only newly eligible
    mutations and never Light, Mist or Pill Fire.
- **AC-LC-43** [Logic] An old save from the mutation-counting build: {Wood 40, Fire 86}
  plus Light keeps Light, uses curve 0.6 at `lk_early`, and takes Light's modifier from
  the current data (a stored 99 is ignored), and its purity from the current parents (a
  stored purity is ignored).

**UI**

- **AC-LC-44** [UI] The fixture is {Wood 40, Fire 86, Water 10} plus Light 47, with Life
  failed. The transcript shows:
  - the root line "Triple root: Wood 40, Fire 86, Water 10 | Light 47", in element
    colours;
  - the speed line, which contains the curve factor as a number, the name of the stage
    where parity comes, and one entry per generating pair with its source ("Tương sinh:
    Mộc → Hỏa", "Tương sinh: Thủy → Mộc") and "+3 %";
  - `explain` for Light, with its parents and +10 heart demon resistance;
  - no Life;
  - a Linh Căn Quả preview, with the tier and the speed before and after;
  - a Tẩy Tủy Đan preview naming Water.

**Mutation Awakening, purity recompute and named fruits** (added 2026-11-04; numbered
after the first draft, so they sit here)

- **AC-LC-45** [Integration] Mutation Awakening, with {Wood 40, Fire 86} and Light rolled
  and failed:
  - without capability #24, a realm breakthrough makes 0 rolls;
  - with it, one breakthrough with the roll forced to fail leaves the set unchanged, and
    the roll's chance is 0.172 (within 1e-9);
  - the next breakthrough with the roll forced to succeed forms Light at purity 47, and
    Light never rolls again;
  - on {Wood, Fire, Water} with Light, Life and Mist failed, one forced-success
    breakthrough forms {Light, Life, Mist, Pill Fire} in one pass;
  - with nothing eligible, a breakthrough makes 0 rolls and writes 0 records.
- **AC-LC-46** [Logic] Mutation purity recompute, with {Wood 40, Fire 86, Water 60} and
  Light 47, Life 39 and Pill Fire 46 owned. A Tẩy Tủy Đan that raises Wood to 48 gives
  Light 51, Life 43 and Pill Fire 49, with 0 RNG calls, 0 rolls and no change to any
  modifier.
- **AC-LC-47** [Logic] A Linh Căn Quả whose event names an owned element adds a uniformly
  chosen missing element instead; with all five owned it adds the +8 rule.

**Not testable here, by design:**
- The years-per-realm table and the tight spots depend on the guessed rate factor (Open
  Question 2).
- The weights for travel speed, `alchemy_yield` and presence are guesses, so AC-LC-25 is
  provisional.
- "A celebrated moment" when a mutation forms is a Game UI matter.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Retune the out-of-band mutations in data, priced by Formulas E's marginal rule. Over the ceiling: Life 34, Array 73, Stars 75, Refined Metal 62.5, Taiji 133. Under the floor: Death 5 net, Reincarnation 20 (8 years over Life). **Holder-raised ceilings are decided (user decision 2026-11-04, cross-GDD review 04g, F15).** The data pass adds "ceiling_raise" effects: Pill Fire `alchemy_success` 6 (31.2 W, was 23.1), Spirit Farming `herb_growth_pct` 20 (49 W, was 20; plots now 20 W each, F11) and Lava `alchemy_success` 5. **Lava's raise 3 → 5 is decided (user decision 2026-11-04):** +5.4 W, so 8.1 → 13.5 W, which clears its 10 W floor and gives it an alchemy identity below Pill Fire's 6. Character Stats rule 14 now says "a mutation" (not "a craft mutation"), so Lava, a stable mutation, may hold the raise; that resolves the conflict this question noted. Spirit Farming stays within the order-2 band at 49 W, so no plot trim is needed. If the plot weight rises past 25 W, +2 plots would push it over 60 W, and the trim would be +1 plot. The held-back lines should be trimmed or replaced: Reincarnation's +50 years (Life already fills part of the ceiling), Spirit Farming's +60 % herb growth (it delivers at most its raised 20, so +20 or less would do; Life's 30 already fills the base ceiling), Pill Fire's +15 alchemy (6 delivered, so +6 would do), and Lava's +8 (5 delivered with its raise, so +5 would do). **Time's power is decided (user decision 2026-11-04):** +40 `cultivation_speed_pct` (88 W) and the root factor `herb_age_root_pct` +25 (kind "root", ×1.25 on h, 22.5 W), 110.5 W in total. Data pass for Time: add `cultivation_speed_pct` 40 and `herb_age_root_pct` 25; remove its `herb_growth_pct` +100 and `lifespan_years` +200 lines (0 W over its ancestors). Still open: the retunes for Life, Array, Stars, Refined Metal, Taiji, Death and Reincarnation; until they land, rule 8's "never a dud" promise fails for Death and Reincarnation (and for Lava only until the data pass adds its raise) | content (data), systems-designer, user (Time) | Formulas E, rule 8 |
| 2 | Bot check of the tight timing spots: single roots at NS and DT, five-element roots in QR, depending on how technique purity enters the rate | Realms & Bottlenecks calibration | Formulas B |
| 3 | Closed 2026-11-04: Cultivation Techniques rule 8. A technique naming an id the root lacks can be learned but not slotted; with no usable main method the cultivator cultivates crudely at ×0.3 of the strongest base purity | — | — |
| 4 | Closed 2026-11-04: Realms & Bottlenecks now lists 103 years at DT for a five-element root (89 with the pair bonus), matching Formulas B | — | — |
| 5 | Meridian Map capability #24 (Mutation Awakening): its text was aligned with rule 9 on 2026-11-04; it still needs a price, since it lifts Light from 17 % to at most 43 % over its two possible passes | Meridian Map | Capability pricing |
| 6 | Character Stats' Stars (+10 comprehension) and Death (−10 presence) examples follow this GDD's data, so they change with the Open Question 1 retune | Character Stats | Data consistency |
| 7 | Implementation changes: rounding the purity draw; the draw order of Formulas A; the curve by base count; pair-bonus modifiers; rolling mutations once (a saved rolled set); power bands; removing the two dead keys; the new count weights | implementation story | Building this GDD |
| 8 | Total mutation power is bounded only per mutation. With Mutation Awakening a five-element root can own up to 25 mutations; simulate the expected and maximum total W per tier and decide whether an aggregate cap is needed | systems-designer | Formulas E |
| 9 | Linh Căn Quả is rare by design (user decision 2026-11-04) and has no per-life counter, yet one fruit is worth ×3.5 at NS and ×4 at DT for a single root, and used early it can lower speed. Its frequency covers both modes (adding an element, and the +8 raise that bypasses Tẩy Tủy Đan's 3-per-life limit) and is owned by the Event Engine budgets (`events_budgets.json` `treasures`): set a target frequency there | Item DB, Event Engine | Rule 11 |
| 10 | Single roots (45 % of lives) need 1,657 years for a whole life against 513 for a dual root. State their late-game identity, after the Open Question 2 bot run | game-designer, Realms calibration | Player Fantasy |
| 11 | A five-element root starts with about 109 W (keystone, pair bonus, mean mutations) against the Meridian Map's ~106 W end-of-Qi-Refining target, which conflicts with "slow and fragile in Qi Refining" (cross-review D2). Options: a Qi Refining drawback on the keystone, gating it at Foundation Establishment, or moving it outward. The ~109 W figure uses mutation prices from before the marginal rule and the retune, so recompute it after Open Question 1. That recompute must also use Time's new price (110.5 W, was 54 before the marginal rule and 0 after it); Time needs its whole ancestor chain, so its share of a birth's mean mutation power is very small, but it changes | Meridian Map, game-designer | Player Fantasy, Formulas C |
| 12 | Draw order and RNG stream for the rolls after birth. Formulas A fixes the birth order only. Linh Căn Quả makes three kinds of draw: the missing element (unless the event names one), its purity U{20..35}, and the rule 9 rolls. Mutation Awakening makes the rule 9 rolls on `breakthrough_succeeded`. Which seeded stream (Deterministic Simulation Core) each draws from, and the order of those draws, must be fixed, or seeded tests and replays diverge | systems-designer, Deterministic Simulation Core | AC-LC-30, AC-LC-45, AC-LC-47 determinism |
