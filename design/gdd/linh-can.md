# Spiritual Roots (Linh Căn)

> **Status**: In Review (2026-11-05: independent review findings applied; cross-GDD review CONCERNS, no blockers). See `reviews/linh-can-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-05
> **Last Verified**: 2026-11-05
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name); touches Pillar 3 (Power Is Built, Not Given) and Pillar 4 (Every Season Counts)
> **Archived 2026-11-09 (user): Void (Hư Không) and Blood (Huyết).** Both variant roots are out of the game for now. They no longer roll at birth, cannot be picked in Self-made, and get no element stacks (Combat economy revision #44). Their rules, rows, worked examples and acceptance criteria stay below, marked or unchanged, so they can return. **Not yet applied in code:** the build still rolls them (`innate_chance` huyet 0.015, hu_khong 0.005) and about 20 acceptance criteria (AC-LC-04 to AC-LC-51, among them 05, 11, 28 and 42) still test them; switching them off moves the innate share from 4.34 % to 2.5 % and needs those criteria and Realms' calibration rechecked (Open Question 13).

## Summary

The spiritual root is the talent a cultivator is born with: one to five base elements
(Metal, Wood, Water, Fire, Earth) with purities of 10–100, plus, in about 1 life in 8, one
of six variant roots in play (Light, Darkness, Ice, Wind, Thunder, Chaos; Void and Blood are archived).
- **Variants** arise by convergence of owned elements, transmutation of one element, or
  innately at birth. Each has a purity-scaled role and its own hidden Meridian Map sector.
  Innate ones count as an extra element for the speed curve.
- **Speed and roles.** Many-element roots cultivate slower early and far faster late, each
  generating pair adds +3 %, and every element and variant has a craft, economy or combat
  role.
- **Changes.** After birth, the root changes only through a few capped pills and event
  fruits, never
  loses anything, and is the run's first reveal and a long-term build goal.

The old higher-order mutations moved to a new system, the Way (Đạo).

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Config, Sim Core; soft: Realms & Bottlenecks, Character Stats`

## Overview

The spiritual root (linh căn) is the talent a cultivator is born with. It has two layers.

- **Base elements.** The five elements (ngũ hành): Metal (Kim), Wood (Mộc), Water (Thủy),
  Fire (Hỏa) and Earth (Thổ). A root owns one to five of them, each with a purity from 10
  to 100.
- **Variant roots (biến dị linh căn).** Eight rarer roots: Light (Quang), Darkness (Ám),
  Ice (Băng), Wind (Phong), Thunder (Lôi), Void (Hư Không), Blood (Huyết) and Chaos (Hỗn
  Độn). A variant is not built from other variants. It arises in one of three ways: a
  *convergence* of specific owned elements (Thunder from Fire and Metal), a
  *transmutation* of one element (Ice from Water), or it is *innate*, appearing at birth
  with no required element (Wind, Blood, and Void, which asks only for a sparse root).

The root shapes the life from the first season:
- **Cultivation speed.** Many-element roots start slow and grow fastest late, and each
  generating (tương sinh) pair inside the root adds a little speed. Variants count
  partly toward that curve.
- **Roles.** Each base element and each variant has a craft or economy role (Wood grows
  herbs, Fire brews pills, Wind speeds travel, Blood deepens vitality, and so on).
- **Meridian Map.** Purity scales the five element sectors. Each variant has a sector of
  its own that stays hidden and locked until the root owns that variant.
- **Techniques.** Purity sets how well a cultivation technique (công pháp) that names an
  element or variant runs.

The root is rolled at birth (or chosen in a Self-made life) and changes only rarely, so
it is both the hand you are dealt and a long-term build goal.

**What this system no longer holds.** The older second-, third- and fourth-order
mutations (Sword, Pill Fire, Spirit Farming, Space, Time and the rest) are not part of the
root. They move to a separate system, the Way (Đạo), which has many more possibilities and
is designed on its own. This GDD defines only the contract it expects from that system
(see Dependencies).

The system exists because it is the first and strongest source of Pillar 1 (Your Dao,
Your Name). Two lives with different roots play differently from the first season. A
single root cultivates fastest at the start; a five-element root must survive a slow
Qi Refining (Luyện Khí) to become the strongest cultivator in the world. That trade is
Pillar 4 (Every Season Counts) applied to a whole life.

## Player Fantasy

You open a life with a hand you did not choose, and you learn to love it. A single root
is a sprinter: fast now, with a long way to go. A five-element root is a long gamble: you
are slow and fragile in Qi Refining, then you pull away from everyone who started fast.

A variant root is a gift you did not earn, and each kind feels different to get. Thunder
is what happens when Fire and Metal in you meet. Ice is your Water running pure. Wind,
Blood and Void simply arrive, and the rarest of them make a life you will retell. A
variant also opens a place on the Meridian Map that nobody without it can even see.

Nothing is ever taken from the root, so every change is a step forward in a build you
chose to pursue.

## Detailed Design

### Core Rules

This section is the 2026-11-04 redesign. It replaces the earlier 29-mutation catalogue
with eight variant roots and moves the rest to the Way (Đạo). Items that differ from the
pre-redesign GDD (git b7f4639) are marked **(change)**.

**Elements**

1. **The five elements.**
   - **Generating cycle:** Wood → Fire → Earth → Metal → Water → Wood (tương sinh).
   - **Overcoming pairs** (tương khắc): Metal–Wood, Wood–Earth, Earth–Water, Water–Fire,
     Fire–Metal. They give no speed. The two pair convergences form from an overcoming
     pair (Thunder from Fire–Metal, Darkness from Earth–Water).
   - An owned element has an integer purity of 10–100 (`purity_min`–100); an absent
     element has purity 0. A derived variant's purity (rule 10) can fall below 10: its
     floor is 8 (all required elements at 10), and a clamp to 1 stays only as a guard.
2. **Birth.**
   - **Fated birth (Thiên Định):**
     - the base element count is drawn from `count_weights`, 45 / 32 / 15 / 6.5 / 1.5 %
       for 1 to 5 elements;
     - the elements are chosen uniformly at random;
     - each purity is drawn from N(`purity_mean`, `purity_sd`), rounded and clamped to
       `purity_min`–100;
     - variants are then rolled (rules 9 and 10).
   - **Self-made birth (Tự Định):** the player picks the elements and their purities
     (10–100; values outside are rejected at input) and may pick any variant the root
     qualifies for (rule 9). A picked derived variant takes its formula purity (rule 10);
     a picked innate variant takes `purity_mean`. Nothing is rolled. Every variant that
     qualifies at birth, picked or not, goes into the rolled set; the ones not picked are
     marked **declined** and are never rolled, not even by Mutation Awakening. A derived
     variant that did not qualify at birth rolls normally if a root change later makes it
     eligible. Picks are free: Self-made is the casual mode with achievements off, and Fated lives are the
     competitive mode (user decision 2026-11-04, kept for the redesign).
   - **Birth perk.** After every birth roll, a destiny perk with `birth.purity_all` (Linh Căn
     Thuần Tịnh, +8) raises every owned base element, capped at 100, and derived variants'
     purities are recomputed. It makes no roll and writes no change record, because it is
     part of birth; the birth chances used the raw purities. It applies in Self-made lives too,
     and to an NPC whose blessing (Progression Edges) is that perk.
3. **Tier and effective count (change).**
   - **Tier.** The number of **base** elements, `n_base`, names the root: 1 Single
     (Đơn linh căn), 2 Dual (Song), 3 Triple (Tam), 4 Quadruple (Tứ), 5 Five-element
     (Ngũ Hành linh căn). Variants never change the tier. The root line shows the owned
     variants after the elements, for example "Dual root: Fire [Hỏa] 86, Water [Thủy] 60 +
     Wind [Phong] 62 (counts as 3)".
   - **Effective count.** `n_eff = min(n_cap, n_base + n_innate)`, where `n_innate` is
     the number of **innate** variants owned and `n_cap` is 5 (the curve has five rows).
     A convergence or transmutation variant is mutated from elements the root already
     counts, so it adds nothing. Chaos counts as 5, which a root that can hold it already
     has. `n_eff` is read by the curve only. Everything else that depends on the element
     count reads `n_base`: the tier, the generating pairs, the center keystone and
     Cultivation Techniques' `count_gain`, which divides out the strongest-purity gain of
     an n-element root (an innate variant does not change that purity).

**Cultivation**

4. **The element-count curve.**
   - **Lookup:** the curve factor is `element_count_curve[n_eff][stage group]`, where
     Realms & Bottlenecks supplies the stage group (4 per realm). The table is unchanged
     from the pre-redesign GDD.
   - **Shape:** fewer elements are faster early and many elements far faster late.
     Parity with a single root comes at Foundation Establishment's middle stage for 2–3,
     its late stage for 4 and Core Formation's early stage for 5.
   - **Trade-off.** An innate variant is a real extra element for the curve: Wind on a
     single root makes it cultivate like a dual root. It buys late speed with early
     speed.
5. **Generating-pair bonus.** Each generating pair whose two **base** elements are both
   owned adds `pair_bonus_pct` (3) to cultivation speed. It appears as a stat sheet
   modifier whose source is the data's Vietnamese name, for example "Tương sinh: Mộc →
   Hỏa". Stat sheet sources always use data names; the root line and other text show
   English names with Hán-Việt annotation (Wood [Mộc]). A five-element root holds all 5
   pairs. Variants form no pairs.

**What each element and variant does**

6. **Element roles**, as built. Character Stats owns the formulas (its Formulas G) and the
   crafts own their checks:

   | Element | Role |
   |---|---|
   | Wood (Mộc) | Herb growth |
   | Fire (Hỏa) | Alchemy success and quality |
   | Earth (Thổ) | Spirit field plots; cuts formation upkeep |
   | Metal (Kim) | Mission income; refining success |
   | Water (Thủy) | Pill-toxicity decay |

7. **Variant roles (change).** A variant has a role like an element does. Its strength
   scales with the variant's purity, so purity matters for a variant too. Character Stats
   owns the formulas (its Formulas G), and the per-purity coefficients are data
   (`variant_effects` in the elements data file; Formulas E sets their pricing).

   | Variant | Role | Stat it scales |
   |---|---|---|
   | Light (Quang) | Heart-demon ward | `tam_ma_resist_pct` |
   | Darkness (Ám) | Stealth and ambush | `stealth` |
   | Ice (Băng) | Pill-toxicity resistance | `dan_doc_resist_pct` |
   | Wind (Phong) | Travel | `travel_speed_pct` |
   | Thunder (Lôi) | Offense | `attack_pct` |
   | Blood (Huyết) — **archived** | Vitality | `khi_huyet_pct` |
   | Void (Hư Không) — **archived** | Secret realms and fortunate encounters | `co_duyen_pct` |
   | Primordial Chaos (Hỗn Độn) | Cultivation and breakthrough | `cultivation_speed_pct` and `breakthrough_chance` |

   Each owned variant adds its lines to the stat sheet with the source
   "Biến dị: <data name>", for example "Biến dị: Quang". Variant roles stay inside
   the existing character-wide ceilings (Character Stats rule 14); the earlier
   holder-raised ceilings belonged to craft mutations that moved to the Way and are gone
   from this system.
8. **Purity as a scale.**
   - **Meridian Map:** an element sector's gate and cluster acupoints scale by 0.5 + purity ÷ 100 for the
     sector's element, or 0.25 if it is absent; meridian roads are exact (Meridian Map rule 21); bridges average their two sectors. A
     **variant sector** scales by 0.5 + purity ÷ 100 for its variant (rule 12).
   - **Cultivation techniques:** a technique's speed scales by the average purity of the
     elements and variants it names ÷ 100. A technique naming something the root lacks
     cannot be used at its speed (Cultivation Techniques owns the fallback).

**Variant roots (biến dị linh căn)**

9. **The catalogue and the three origins (change).** Eight variants, in
   `character_elements.json`, no orders and no chains. The table is in catalogue order,
   which is also the roll order: innate first, then derived.

   | Variant | Origin | Requirement |
   |---|---|---|
   | Wind (Phong) | Innate (Thiên Sinh) | none |
   | Blood (Huyết) — **archived** | Innate | none |
   | Void (Hư Không) — **archived** | Innate | `n_base` ≤ `void_max_elements` (2), at birth |
   | Thunder (Lôi) | Convergence (Hội Tụ) | owns Fire and Metal |
   | Darkness (Ám) | Convergence | owns Earth and Water |
   | Primordial Chaos (Hỗn Độn) | Convergence | owns all five base elements |
   | Light (Quang) | Transmutation (Chuyển Hóa) | owns Fire |
   | Ice (Băng) | Transmutation | owns Water |

   **Archived (2026-11-09):** Blood and Void keep their catalogue places and roll order, but their
   `innate_chance` is 0 and Self-made rejects them, so no new life holds them. A save that already holds one
   keeps it.

   - **Convergence** and **transmutation** are *derived*: the variant is formed from
     elements the root owns. A transmutation keeps its element; nothing is replaced.
   - **Innate** variants are decided once, at birth, and do not depend on which elements
     the root owns (Void reads only the element count).
     They are never rolled again, by Awakening or by a root change.
10. **Forming variants.**
    - **When.** Each derived variant rolls **once**, when its requirement is first met:
      at birth, or when a root change adds an element (rule 13). Each innate variant
      rolls once, at birth only, if it is eligible. The only other roll is Mutation
      Awakening (below). A purity change never triggers a roll.
    - **Pass order.** In one pass every variant that has just become eligible rolls, in
      catalogue order (the order of `character_elements.json`), one uniform draw each; a
      roll succeeds when the draw is below the chance. An ineligible variant makes no
      draw (full draw order: Formulas A). No variant is a parent of another, so the order
      only fixes the draws.
    - **Chance.** Pair convergence (Thunder, Darkness): `convergence_factor` × the product
      of the required elements' purities ÷ 100. Chaos: the same with `chaos_factor`,
      capped at 1. Transmutation: `transmutation_factor` × its element's purity ÷ 100.
      Innate: a flat `innate_chance` per variant. Formulas D sets the values.
    - **Purity.** A derived variant's purity is round(`variant_purity_factor` (0.8) × the
      geometric mean of its required elements' current purities), clamped 1–100. It is
      **recomputed** whenever a required element's purity changes, so a Tẩy Tủy Đan lifts
      the variant built on that element. An innate variant's purity is drawn from the
      birth purity distribution when it forms and never changes.
    - **Mutation Awakening (Biến Dị Khai Mở).** This system subscribes to Realms &
      Bottlenecks' `breakthrough_succeeded` event (a successful move to the next realm).
      On each event, if the Meridian Map capability #24 is in the character's capability
      set (Character Stats rule 16), it gives one more roll to every **derived** variant
      that is not owned, not declined (rule 2) and whose requirement is met, including
      ones that failed earlier. Innate variants are not re-rolled. The chance is the same formula at the
      current purities, and a variant that forms is owned from then on.
    - **At most two Awakening passes per life.** Every capability sits behind the Core
      Formation gate (Meridian Map rule 16), so only Core Formation → Nascent Soul and
      Nascent Soul → Deity Transformation can fire it.
11. **What a variant is and is not.**
    - It counts as an owned id for techniques, crafts and recipes that name it, and its
      current purity (rule 10) is used there.
    - It does **not** count as a base element: it forms no generating pair, is not
      counted in the tier or `n_base`, and does not scale an element sector. An innate
      variant counts once toward `n_eff` (rule 3).
12. **Variant sectors (Meridian Map contract).**
    - Each variant has its own sector on the Meridian Map. A sector is **hidden and
      locked** while the root does not own its variant: it is not drawn, no point can be
      spent in it, and it is not counted when the map's visible size is reported.
    - When the root gains the variant, at birth or later (Awakening, Linh Căn Quả), its
      sector becomes visible from that moment, and its entries join the frontier where
      their host is open (Meridian Map rule 20). Variants are never lost, so
      a sector never relocks.
    - The sector's geometry, size, attachment points and pricing belong to the Meridian
      Map (its rule 20). This system supplies only the owned set and each variant's purity.

**Changing the root**

13. **Root changes** after birth, only through items and events (quick spec
    `phu-luc-linh-thu-thanh-tuu.md`):
    - **Tẩy Tủy Đan** (Marrow-Cleansing Pill): raises the weakest owned **base** element by
      max(1, round(6 × pill potency)), capped at 100. At most 3 per life; a further pill,
      or one taken when every owned element is at 100, is refused and kept. Derived
      variants' purities are recomputed; no variant rolls.
    - **Linh Căn Quả** (Spiritual Root Fruit; rare by design): adds a missing element
      at purity 20–35. The player picks which one when the fruit is used, so the fruit holds
      no element until then (user decision 2026-11-05). An NPC's fruit takes a missing
      element uniformly at random (not reachable yet, rule 15). If all five are owned it adds +8 to the weakest
      instead (ties in cycle order); with all five at 100 it is refused and kept. It is
      granted only by events, from Foundation Establishment on.
    - After a change that adds an element, the **derived** variants it makes newly
      eligible roll (rule 10). Innate variants do not roll. Every change is recorded in
      the World Database.
14. **No loss.** A change never removes an element or a variant, and purity never falls.
    There is no respec.
15. **NPCs** roll and change their roots by the same rules, except Mutation Awakening:
    `breakthrough_succeeded` is player-only (Realms & Bottlenecks rule 9), so NPCs get no
    Awakening passes. An archetype never changes a root (user decision 2026-11-05). An NPC
    whose root lacks any of its archetype's elements usually switches to an archetype that
    fits, and may keep it anyway with chance `archetype_keep_chance` (0.2, a guess), at the
    disadvantage of a poor match. NPC Builds owns that pick.
    - **Root changes are not reachable for NPCs yet.** Nothing gives an NPC a Linh Căn Quả or
      feeds it a Tẩy Tủy Đan: fruits come from events the player resolves, and root-change
      records are written for the player only. Rule 13 is the rule for when that path exists;
      until then it is tested at function level.

**What moved to the Way (Đạo)**

16. **Relocated mutations.** These are no longer part of the root and are never rolled
    here: Lava (Dung Nham), Gravity (Trọng), Life (Sinh Mệnh), Poison (Độc), Mist (Vụ),
    Sword (Kiếm), Heavenly Thunder (Thiên Lôi), Destruction (Hủy Diệt), Death (Tử), Pill
    Fire (Đan Hỏa), Spirit Farming (Linh Thực), Refined Metal (Tinh Kim), Array (Trận),
    Soul (Hồn), Illusion (Huyễn), Stars (Tinh Thần), Space (Không Gian), Yin (Âm), Yang
    (Dương), Reincarnation (Luân Hồi), Taiji (Thái Cực) and Time (Thời Gian). They are
    **seeds** for the Way's own design, not commitments. The Way may read the root
    (elements, purities, variants) as prerequisites. Anything that named one of them (a
    technique, a recipe, an item) is re-pointed when the Way is designed.

**What the player cannot do:**
- choose the root in a Fated life;
- remove an element or a variant;
- raise purity above 100;
- make a variant count as a base element (pairs, tier, element sectors);
- pick a variant the root does not qualify for in a Self-made life.

### States and Transitions

The root has no states. It is a set of values that only grows: the base elements and their
purities, the owned variants (each with its purity; its origin kind comes from the data), the **rolled set**
(every variant id that has rolled or been marked rolled) and the Tẩy Tủy Đan use counter.
All four are saved.

| Event | Effect | Guard |
|---|---|---|
| Birth | Elements, purities and variants set (rules 2, 9, 10) | Once per life |
| Tẩy Tủy Đan | Weakest base element +max(1, round(6 × potency)), capped at 100; no roll; derived variants' purity recomputed | 3 per life; refused (and kept) beyond that, or when every owned element is at 100 |
| Linh Căn Quả | New element at 20–35, then the newly eligible derived variants roll (or +8 to one element: no roll, derived purities recomputed) | Events only, Foundation Establishment on |
| Variant formed | Added with its purity and origin; its Meridian Map sector unlocks (rule 12) | Requirement met; not already owned; not declined; a first roll needs the variant outside the rolled set, an Awakening roll does not |
| Realm breakthrough | Every unowned derived variant whose requirement is met rolls once more (rule 10) | Mutation Awakening (Meridian Map #24) held; a successful realm change |

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Character Stats | out | per-element purity, `n_base`, `n_eff`, the variant set with purities (into the sheet through the variant roles), the generating-pair bonus modifier | this GDD (the root); Character Stats (the sheet, the element and variant role formulas) |
| Realms & Bottlenecks | out / in | out: the curve factor by `n_eff` and stage group. In: the player-only `breakthrough_succeeded` event, which triggers the Mutation Awakening roll (rule 10) | this GDD (the curve, the roll); Realms (the stage groups, the event) |
| Meridian Map | out / in | out: purity per element (acupoint scaling), `n_base` (the center keystone needs all five), the owned variants with purities (which variant sectors unlock and how they scale). In: whether capability #24 (Mutation Awakening) is held, read from the character's capability set; the Meridian Map never calls this system | Meridian Map (the scaling rule, the capability, the variant sectors' geometry); Character Stats (the capability set); this GDD (the roll, rule 10) |
| Cultivation Techniques | out | purity of the elements and variants a technique names; `n_base` for the technique count gain | Cultivation Techniques |
| Crafts (Alchemy, Spirit Fields, Artifact Refining, Formations) | out | element purities for their roles. Craft mutations no longer exist here | each craft |
| The Way (Đạo) | out | the root as read-only prerequisites (elements, purities, variants). The Way owns the relocated mutations (rule 16) | the Way (undesigned; provisional contract) |
| Item DB, Event Engine | in | Tẩy Tủy Đan and Linh Căn Quả effects (budgeted by events) | Item DB, Event Engine |
| World Database | out | root changes and variants formed | World Database |
| NPC Builds, World Generation | in / out | NPC roots rolled by the same rules; the owned elements, for the archetype fit (rule 15) | NPC Builds |
| Progression Edges | in / out | in: the birth perk's `birth.purity_all`, raising purity after the birth rolls (rule 2), for the player and a blessed NPC. Out: purities and the variant count, for the NPC edge score | Progression Edges |
| Market, Combat, Achievements | out | the root as read-only input: stock bias (Market), artifact element match (Combat), `n_base` and the variant count (Achievements) | each system |
| Codex & Karmic Carryover | out | variants discovered across lives | Codex |
| Guidance Layer, Debug Terminal, Game UI | out | the root line, tier, `n_eff`, purities, variants and their origin, the curve position | Guidance Layer |
| Save/Load | out | elements, purities, variants, the rolled set, change counts | Save/Load |

## Formulas

Redesign formulas, drafted with `systems-designer` (2026-11-04). Rates come from a
2,000,000-life Monte Carlo and were re-checked analytically. Values marked *guess* need a
bot run. Realm abbreviations: QR, FE, CF, NS, DT.

### A. Birth roll

The birth_roll formula is defined as:

`P(n_base = n) = w_n / Σw` ; `P(subset) = 1 / C(5, n_base)` ; `purity = clamp(round(N(μ, σ)), p_min, p_max)` ; `variant formed iff u < chance_v`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_n | float | 45 / 32 / 15 / 6.5 / 1.5 | data file (`count_weights`) | Weight for 1–5 base elements |
| μ, σ | float | 50, 20 | data file (`purity_mean`, `purity_sd`) | Purity distribution, used for elements and for innate variants |
| p_min, p_max | int | 10, 100 | data file | Purity clamp |
| purity | int | 10–100 | calculated | One owned element's, or one innate variant's, purity |
| u | float | [0, 1) | calculated (seeded RNG) | One uniform draw per roll |
| chance_v | float | 0–1 | calculated | The variant's chance (Formulas D) |

**Output Range:**
- Tier shares are 45 / 32 / 15 / 6.5 / 1.5 %. About 2.4 % of purity draws clamp to 10
  and 0.67 % to 100. The mean is 50.1.
- An element has purity ≥ 85 with chance 4.2 %. A root has at least one such element
  with chance 4.2 / 8.3 / 12.2 / 15.9 / 19.5 % by tier (7.7 % of births).

**Draw order (Fated birth).** The seeded RNG is consumed in this order, so a seed always
gives the same root and tests can stub it.

| Step | What | Uniform draws | Normal draws |
|---|---|---|---|
| 1. Count | Smallest n with u · Σw < the cumulative weight of n (half-open intervals [0, 45), [45, 77), [77, 92), [92, 98.5), [98.5, 100), the same convention as every variant roll) | 1 | 0 |
| 2. Elements | Partial Fisher–Yates over [Wood, Fire, Earth, Metal, Water] (cycle order). For i = 0 … n_base−1, j = i + floor(u · (5 − i)); swap i and j | `n_base` (the last draw is still made when `n_base` = 5) | 0 |
| 3. Purities | One per owned element, in cycle order (not shuffle order) | 0 | `n_base` |
| 4. Innate rolls | Wind, Blood, Void, in catalogue order. Each rolls `u < innate_chance[v]`. Void is eligible only when `n_base` ≤ `void_max_elements`, and **makes no draw otherwise** | 1 each for Wind and Blood; 1 for Void only if `n_base` ≤ 2 | 1 immediately after each success (that variant's purity); none after a failure |
| 5. Derived rolls | Thunder, Darkness, Chaos, Light, Ice, in catalogue order. A variant rolls only if its requirement is met, **and makes no draw otherwise** | 1 per variant whose requirement is met | 0 (purity is a formula) |

- **Uniform draws per birth:** `1 + n_base + 2 + [n_base ≤ 2] + d`, where d (0–5) is the
  number of derived variants whose requirement is met. The most is 13 (`n_base` 5, d = 5).
- **Normal draws per birth:** `n_base + (innate successes)`.
- **Self-made birth** makes no draws at all. The player's picks stand: derived picks take
  the formula purity, innate picks take `purity_mean`.
- **The rolled set** is every variant that made a roll at birth, success or failure. In a
  Self-made life it is every variant that qualifies, picked or not; the ones not picked
  are also marked **declined** (rule 2).

**Example:** the count roll is 0.80, in [77, 92), so 3 elements. Subset draws pick Wood,
Fire and Water. The purity draws in cycle order are Wood 40, Fire 86 and Water 2σ below
the mean, clamped to 10.
- Wind draws 0.021 < 0.025, so it forms, and a normal draw of +0.5σ gives purity 60.
- Blood draws 0.40 and fails.
- Void makes no draw (`n_base` 3).
- Thunder, Darkness and Chaos are not eligible and make no draw.
- Light draws 0.05 < 0.12 × 0.86 = 0.103 and forms, at purity round(0.8 × 86) = 69.
- Ice draws 0.20 > 0.12 × 0.10 = 0.012 and fails.

The root is a Triple root + Wind, Light. That is 8 uniform and 4 normal draws, and
`n_eff` = 4.

### B. Effective count and the element-count curve

The effective_count and curve_factor formulas are defined as:

`n_eff = min(n_cap, n_base + n_innate)` ; `curve_factor = element_count_curve[n_eff][stage_group]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_base | int | 1–5 | calculated | Base elements owned |
| n_innate | int | 0–3 | calculated | Innate variants owned (Wind, Blood, Void). Derived variants add 0 |
| n_cap | int | 5 | data file (`n_cap`) | The curve has five rows |
| n_eff | int | 1–5 | calculated | Row of the curve. Integer, no interpolation |
| stage_group | enum | 13 keys | data file (Realms & Bottlenecks) | Prefix = realm: `lk` QR, `tc` FE, `kd` CF, `na` NS, `ht` DT. QR `[lk_early, lk_mid, lk_late, lk_late]`; FE `tc_so / tc_trung / tc_hau / tc_dvm`; CF `kd_so / kd_trung / kd_hau / kd_dvm`; NS `na`; DT `ht`. The table abbreviates `trung` to `tr` |
| curve_factor | float | 0.3–9.0 | data file (`element_count_curve`) | Speed relative to a single root |

| n_eff | lk_e | lk_m | lk_l | tc_so | tc_tr | tc_hau | tc_dvm | kd_so | kd_tr | kd_hau | kd_dvm | na | ht |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | .6 | .7 | .8 | .9 | **1.0** | 1.3 | 1.6 | 2.0 | 2.4 | 2.8 | 3.1 | 3.5 | 4.0 |
| 3 | .5 | .6 | .75 | .9 | **1.0** | 1.4 | 1.8 | 2.3 | 2.8 | 3.4 | 3.9 | 4.5 | 5.5 |
| 4 | .4 | .5 | .6 | .75 | .9 | **1.0** | 1.5 | 2.1 | 2.8 | 3.6 | 4.3 | 5.0 | 7.0 |
| 5 | .3 | .4 | .5 | .6 | .75 | .85 | .95 | **1.0** | 1.8 | 2.8 | 3.8 | 6.0 | 9.0 |

**Output Range:**
- `n_eff` runs 1–5. It is at least `n_base` and is raised only by innate variants. The
  maximum is reached by 2 base + 3 innate, 3 base + 2, 4 base + 1, or 5 base.
- `curve_factor` runs 0.3–9.0. The parity points (bold) are unchanged: 2–3 at FE middle,
  4 at FE late, 5 at CF early.
- Births by `n_eff`, 1–5: **43.00 / 32.55 / 15.83 / 6.85 / 1.76 %**, against
  `n_base` 45 / 32 / 15 / 6.5 / 1.5 %. An innate variant moves 4.3 % of lives up one row.
  Derived variants never move a row.
- Years per realm and the share of the half-lifespan ceiling (Realms & Bottlenecks
  Formulas A costs, other rate factors 1.25 *guess*, each tier's expected pair bonus 0 /
  1.5 / 4.5 / 9 / 15 %; carried over unchanged from the pre-redesign GDD). The table holds
  for a root with no innate variant, 95.7 % of births:

| Elements | QR | FE | CF | NS | DT | Whole life |
|---|---|---|---|---|---|---|
| 1 | 25 (42 %) | 64 (64 %) | 187 (75 %) | 456 (91 %) | 925 (93 %) | 1,657 |
| 2 | 33 (56 %) | 52 (52 %) | 71 (28 %) | 128 (26 %) | 228 (23 %) | 513 |
| 3 | 36 (60 %) | 48 (48 %) | 58 (23 %) | 97 (19 %) | 161 (16 %) | 400 |
| 4 | 43 (72 %) | 57 (57 %) | 55 (22 %) | 84 (17 %) | 121 (12 %) | 359 |
| 5 | 50 (84 %) | 69 (69 %) | 79 (32 %) | 66 (13 %) | 89 (9 %) | 354 |

- A root with an innate variant reads the row of `n_eff` but pays the pair bonus of
  `n_base`. A Dual root + Wind runs the 3-element curve with at most 1 pair (+3 %), where a
  true Triple root has 1 or 2.
- The tight spots: a single root at NS and DT needs other rate factors of at least about
  1.15, and a five-element root in QR sits at 84 %. Roots above their base row are tighter
  in QR, because they climb on the `n_eff` row while technique gain follows `n_base`: a
  four-element root with 1 innate variant takes 52.5 years (87 %), a three-element root
  with 2 takes 54.7 (91 %) and a two-element root with 3 takes 56.3 (94 %). Those are about
  0.26 % of lives and the median still passes, so they are accepted. Realms & Bottlenecks
  owns that rate, so a bot run must confirm it.

**Example:** a Dual root (Fire, Water) + Wind has `n_base` 2 and `n_innate` 1, so `n_eff`
= min(5, 3) = 3.
- At FE middle its factor is 1.0, where a plain Dual root also has 1.0 (parity).
- In QR early it is 0.5, against 0.6 for a plain Dual root.
- At CF great perfection it is 3.9, against 3.1.

A Four-element root + Wind + Blood has `n_eff` = min(5, 6) = 5.

### C. Generating-pair bonus

The pair_bonus formula is defined as:

`pair_pct = pair_bonus_pct · Σ_{i=0..4} [owned(e_i) ∧ owned(e_{(i+1) mod 5})]`

One `cultivation_speed_pct` modifier is added per pair, with source "Tương sinh: <from> →
<to>". They add to the other cultivation speed bonuses (Character Stats Formulas I). Only
**base** elements count. Variants form no pairs.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| e_i | enum | Wood, Fire, Earth, Metal, Water | data file (`cycle`) | The generating cycle |
| owned(e) | bool | true / false | calculated | The base element is owned |
| pair_bonus_pct | float | 3 | data file | Bonus per generating pair |
| pair_pct | float | 0–15 | calculated | Total bonus |

**Output Range:** 0–15 %. The pairs are the five edges of a cycle.

| Elements | Generating pairs | Bonus |
|---|---|---|
| 1 | 0 | 0 % |
| 2 | 0 or 1 (50 / 50) | 0–3 % |
| 3 | 1 or 2 (50 / 50) | 3–6 % |
| 4 | always 3 | 9 % |
| 5 | always 5 | 15 % |

- **Power check.** One pair is 6.6 W at 2.2 W per cultivation speed point, about two-thirds
  to four-fifths of a notable (8–10 W). All five are 33 W, under the 50 W keystone floor. The ceiling for the knob is
  4.5 %.
- **Rare roots are meant to win** (user decision 2026-11-04). The five-element root also
  holds the keystone and the chance at Chaos, and its price is a slow, fragile Qi
  Refining.

**Example:** Fire, Water and Wood own Wood → Fire and Water → Wood, so 2 pairs and
**+6 %**. A Wind variant adds no pair and no bonus.

### D. Variant formation

**D1. Chance.** The variant_chance formulas are defined as:

`chance_v = min(1, f_v · Π_{e ∈ req(v)} purity_e / 100)` for derived variants ; `chance_v = innate_chance[v]` for innate variants

`f_v = convergence_factor` for the pair convergences (Thunder, Darkness) ; `transmutation_factor` for Light and Ice ; `chaos_factor` for Chaos

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| req(v) | set | 1, 2 or 5 base elements | data file (variant `requires`) | Thunder {Fire, Metal}; Darkness {Earth, Water}; Chaos all five; Light {Fire}; Ice {Water} |
| purity_e | int | 10–100 | calculated | The element's **current** purity at the roll |
| convergence_factor | float | 0.6 | data file | Pair convergence factor |
| transmutation_factor | float | 0.12 | data file | Transmutation factor |
| chaos_factor | float | 5 | data file | Five-parent factor; the `min(1, …)` clamp matters only for this variant |
| innate_chance | float | Wind 0.025, Blood 0.015, Void 0.005 | data file | Flat chance, rolled at birth only |
| void_max_elements | int | 2 | data file | Void is eligible only when `n_base` ≤ this at birth |
| chance_v | float | 0–1 | calculated | The roll succeeds when `u < chance_v` |

**Output Range:**
- Pair convergence: 0.6 % (both parents at 10) to 60 % (both at 100). Transmutation: 1.2 %
  to 12 %. Chaos: 0.005 % (five at 10) to 100 % (the clamp binds from a product of 0.2,
  for example five at 72.5).
- Chance at average purities (0.501), by `n_base`:

| Variant | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Thunder, Darkness | 0 | 1.5 % | 4.5 % | 9.0 % | 15.1 % |
| Light, Ice | 1.2 % | 2.4 % | 3.6 % | 4.8 % | 6.0 % |
| Chaos | 0 | 0 | 0 | 0 | 15.8 % |

- **Rates per birth (simulated; analytic check in brackets):**

| Variant | % of births |
|---|---|
| Thunder | 2.00 (1.97) |
| Darkness | 1.97 (1.97) |
| Chaos | 0.23 (0.236) |
| Light | 2.26 (2.25) |
| Ice | 2.26 (2.25) |
| Wind | 2.50 |
| Blood | 1.50 |
| Void | 0.38 (0.385) |
| At least one variant | **12.14** |
| At least one innate | 4.34 (4.33) |

- Chaos is 15.8 % of five-element roots, about 1 life in 420.

**Example:** Fire 86 and Metal 40 give Thunder chance 0.6 × 0.86 × 0.40 = **20.6 %**.
Fire 86 gives Light 0.12 × 0.86 = **10.3 %**. Five elements at 60 / 50 / 45 / 70 / 55 give
Chaos 5 × 0.0520 = **26.0 %**.

**D2. Purity.** The variant_purity formulas are defined as:

`purity_v = clamp(round(variant_purity_factor · (Π_{e ∈ req(v)} purity_e)^(1/m)), 1, 100)` for derived variants, recomputed whenever a required element's purity changes ; `purity_v = clamp(round(N(μ, σ)), p_min, p_max)` for innate variants, drawn once and fixed

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| variant_purity_factor | float | 0.8 | data file | Discount on the geometric mean |
| m | int | 1, 2 or 5 | calculated | Number of required elements |
| purity_e | int | 10–100 | calculated | Current element purity |
| purity_v | int | derived 8–80; innate 10–100 | calculated | The variant's purity |

**Output Range:**
- A derived purity is at most 80 (all required at 100) and at least 8, so the 1–100 clamp
  is only a guard.
- Exact .5 ties cannot occur. The geometric mean of integers is an integer or irrational,
  and 0.8 g = k + 0.5 needs g = (10k + 5)/8, never an integer. Float `round()` is
  therefore safe here.
- A derived variant formed with chance ∝ purity has a typical purity of about 45.5, so the
  derived typical value sits at roughly 0.91 of the purity-50 figure used in Formulas E.
  Innate purity has mean 50.1.

**Example:** Fire 86 and Metal 40 give Thunder round(0.8 × √3,440) = round(46.9) = **47**.
After a Tẩy Tủy Đan lifts Metal to 48, Thunder is round(0.8 × √4,128) = **51**. Light on
Fire 86 is round(68.8) = **69**. Five elements at 60 / 50 / 45 / 70 / 55 give Chaos
round(0.8 × 55.3) = **44**.

**D3. Mutation Awakening (Biến Dị Khai Mở).** The awakening formulas are defined as:

`c_j = chance_v at the purities of pass j` ; `P(v owned after pass k) = 1 − Π_{j=0..k} (1 − c_j)`, with pass 0 the birth roll and k ≤ `awakening_max_passes`

`top_up ≈ h · (g_1 · 0.147 + g_2 · 0.029)` percentage points, with h the share of lives holding #24 ; `E_p = h × 0.176`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c_j | float | as D1 | calculated | The chance at pass j. Only derived, unowned, not-declined variants whose requirement is met roll |
| awakening_max_passes | int | 2 | data file | Only CF→NS and NS→DT can fire it |
| g_1, g_2 | float | about 6.0, 4.8 pp | calculated (analytic) | Lives newly holding their first variant, for the first and second pass fired |
| E_p | float | 0–0.176 | **estimate** | Expected passes fired per life. The player always has the edge, so about 0.147 of lives cross CF→NS and 0.029 cross NS→DT (Realms & Bottlenecks Formulas E), and only lives holding capability #24 fire. Good roots cross every gate more often, so the true reach is a little higher (about 0.157 and 0.034) |
| top_up | float | 0–about 1 pp | calculated | Added to the 12.14 % birth rate |

**Output Range:**
- Pass gain, derived analytically at average purities, ignoring Tẩy Tủy gains (which would
  raise it a little).
  - Pass 1 gross is Light 2.10 + Ice 2.10 + Thunder 1.58 + Darkness 1.58 + Chaos 0.16 =
    7.5 % of lives. About 0.80 of those hold no variant already, because re-rolls
    concentrate in many-element roots, so the net is about **6.0 pp**.
  - Pass 2 net is about **4.8 pp**.
  - Both passes together add about **10.8 pp**, only if every life fired both.
- **Estimate** (unsourced; Open Question 1), by share of lives holding #24:

| h (lives holding #24) | E_p (passes per life) | Total lives holding a variant |
|---|---|---|
| 0.25 | 0.044 | 12.4 % |
| 0.50 | 0.088 | 12.7 % |
| 1.00 | 0.176 | 13.2 % |

- Planning assumption: **about 12.4–12.7 %**, accepted without a retune. The old 13.5 %
  target is dropped: after the last two gates were made harder, only a world where every
  life held #24 would come near it (about 13.5 % once good roots' extra reach is counted).
- A single variant's reach: Light on Fire 86 (10.3 %) is owned by the second pass with
  probability 1 − 0.8968³ = **27.9 %**, after the birth roll and both passes.

**Example:** Thunder on Fire 86, Metal 40 (20.6 %). It fails at birth. A Core Formation →
Nascent Soul breakthrough gives a second roll at the same purities and forms it with
probability 20.6 %. The chance it is owned after both passes is 1 − 0.794³ = **50 %**.

### E. Variant power

The variant_power formulas are defined as:

`value_{v,k} = floor(per_purity_{v,k} · purity_v / u_k) · u_k` ; `power_W(v) = Σ_k w_k · value_{v,k}` ; `floor_band ≤ power_W(v | purity 50)` and `power_W(v | purity 100) ≤ ceiling_band`

No variant key is under a Character Stats ceiling (rule 14), so each is priced in full. In
practice Chaos's `breakthrough_chance` can be partly absorbed by Realms' q-extras ceiling.
There is no marginal pricing, no ancestors and no holder-raised ceilings. Because power is
linear in purity, `power_W(100) ≈ 2 · power_W(50)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| per_purity_{v,k} | float | table below | data file (`variant_effects`) | Displayed units of key k per purity point, at most 2 decimals |
| purity_v | int | 8–100 | calculated | Variant purity (Formulas D2) |
| u_k | float | 0.1 (all keys here) | constant (Meridian Map Formulas F precision) | The displayed unit. Values are whole counts of u_k and are only rounded **down**, in integer arithmetic on hundredths, so rounding can lower a price but never raise it |
| w_k | float | table below | constant (design-only; Meridian Map Formulas F weights, not runtime data) | W per displayed unit |
| floor_band, ceiling_band | float | 10 / 30 W (common); 20 / 60 W (Chaos) | data file (`variant_power_band`, `variant_power_band_apex`) | The band |
| power_W | float | 0–about 60 | calculated | The variant's price |

| Variant | Key | w (W/unit) | Per purity | Value p50 | Value p100 | W p50 | W p100 | In band |
|---|---|---|---|---|---|---|---|---|
| Light (Quang) | `tam_ma_resist_pct` | 1.5 | 0.20 | 10.0 | 20.0 | 15.0 | 30.0 | yes |
| Darkness (Ám) | `stealth` | 1.5 | 0.20 | 10.0 | 20.0 | 15.0 | 30.0 | yes |
| Ice (Băng) | `dan_doc_resist_pct` | 1.6 | 0.18 | 9.0 | 18.0 | 14.4 | 28.8 | yes |
| Wind (Phong) | `travel_speed_pct` | 0.3 *guess* | 1.00 | 50.0 | 100.0 | 15.0 | 30.0 | yes |
| Thunder (Lôi) | `attack_pct` | 1.0 | 0.30 | 15.0 | 30.0 | 15.0 | 30.0 | yes |
| Blood (Huyết) | `khi_huyet_pct` | 1.2 | 0.25 | 12.5 | 25.0 | 15.0 | 30.0 | yes |
| Void (Hư Không) | `co_duyen_pct` | 0.3 *guess* | 1.00 | 50.0 | 100.0 | 15.0 | 30.0 | yes |
| Primordial Chaos (Hỗn Độn) | `cultivation_speed_pct` | 2.2 | 0.13 | 6.5 | 13.0 | 14.3 | 28.6 | |
| | `breakthrough_chance` | 5 | 0.06 | 3.0 pp | 6.0 pp | 15.0 | 30.0 | |
| | **Chaos total** | | | | | **29.3** | **58.6** | **yes (apex band)** |

**Output Range:**
- These bands price the role line only. A variant's sector adds about +26 W net at purity 50
  and +71 W at purity 100 (Meridian Map Formulas H3), so role and sector together are about
  41 W and 101 W.
- **Common band: 10–30 W**, the old order-1 band, now flat for all seven non-Chaos
  variants. Every one has a purity-50 price of 14.4–15.0 W (≥ 10) and a purity-100 price
  of 28.8–30.0 W (≤ 30). Ice is trimmed to 0.18 to stay under the ceiling at its 1.6
  weight.
- **Reachable range.** A derived variant tops out at purity 80, so its real ceiling is
  24 W. Its typical purity is about 45.5, around 13.7 W. Only innate variants (Wind, Blood,
  Void) can reach the purity-100 ceiling.
- **Chaos band: 20–60 W** (user decision 2026-11-04: raised to about 30 W at purity 50).
  Chaos is about 2 × a common variant at the same purity. The derived maximum, purity 80,
  gives +10.4 % cultivation speed and +4.8 pp `breakthrough_chance`, 46.9 W. 0.14 / 0.06
  would price 60.8 W at purity 100, over the band, so cultivation speed is 0.13.
- Chaos's `breakthrough_chance` line is not tree-capped (the cap is per source) but joins
  Realms & Bottlenecks' per-attempt extras ceiling in its Formulas C, which Realms owns.
- `co_duyen_pct` and `travel_speed_pct` have no Meridian weight, because the map excludes
  them from fills. 0.3 W per point is a *guess* carried from the earlier pricing of travel
  speed, applied to both (Open Question 2).

**Example:** Thunder at purity 47 (the Fire 86 / Metal 40 root): value = floor(0.30 × 47 /
0.1) × 0.1 = floor(141) × 0.1 = **+14.1 % attack**, which is 14.1 W. Blood at innate
purity 50: **+12.5 % `khi_huyet_pct`** = 15.0 W. Chaos at 44: +5.7 % cultivation speed and
+2.6 pp `breakthrough_chance` = 12.54 + 13.0 = **25.54 W**. W figures are exact and are
never rounded; prose may show them to one decimal.

### F. Root changes

The root_change formulas are defined as:

`gain = max(1, round(tay_tuy_value · potency))` ; `purity' = min(100, purity + gain)` (Tẩy Tủy Đan, on the weakest owned **base** element, no roll, then derived variants' purity recomputed by D2)

`purity_new ~ U{20..35}` for an added element (Linh Căn Quả), followed by the derived rolls of D1 for variants that **became eligible**, or `min(purity + raise, 100)` on the weakest element when all five are owned (no roll; derived purities recomputed)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tay_tuy_value | int | 6 | data file (`items_recipes.json`) | Base purity per pill |
| potency | float | 0–about 2 | calculated (Character Stats, Formulas D) | Pill potency (quality, toxicity, `pill_effect_pct`) |
| max_uses | int | 3 | data file | Tẩy Tủy Đan per life |
| purity range, raise | int | 20–35, 8 | data file (`items_treasures.json`) | Linh Căn Quả |

**Output Range:**
- Three Tẩy Tủy Đan at quality 1 and low toxicity give about +8 each, **+24** in total
  (*guess*). The gain lands on the weakest element, so per element it averages 12 / 8 / 6 /
  4.8 for 2–5 elements.
- Purity pills never roll variants but they recompute derived purity. Metal 40 → 48 with
  Fire 86 moves Thunder from 47 to **51**. Because variant power is linear in purity
  (Formulas E), the same pill adds about 1.2 W to Thunder.
- A Linh Căn Quả adds an element at 27.5 on average. That changes `n_base`, the pairs and,
  through the cap, `n_eff`.
  - **Newly eligible derived variants** roll once each. With a random element (NPCs), the
    expected number of new variants at average purities is **3.0 / 4.6 / 6.3 / 16.6 %** on a
    root of 1 / 2 / 3 / 4 base elements; a player who picks for variants gets about 8.6 / 8.9 /
    8.9 / 16.6 %. Light and Ice are 3.3 % each, a convergence is 8.3 % and Chaos on the
    fifth element is 8.7 %.
  - Innate variants never roll.
  - On a root with `n_eff` already 5 (for example 4 base + Wind), the new element changes
    the pairs but not the curve row.
- **Linh Căn Quả draw order.** A Tẩy Tủy Đan makes no draw. A fruit that adds an element
  makes, in order: for an NPC only, 1 uniform draw for the element, uniform over the missing
  elements in cycle order (the player picks, with no draw); 1 uniform draw for its purity,
  20 + floor(u · 16); then 1 uniform draw per newly eligible derived variant, in catalogue
  order. The +8 path makes no draw. A player's fruit and Mutation Awakening draw from the
  session's one seeded RNG, in call order; its state is saved with the game.

**Example:** Water 10 with potency 1.25 → +8 (round(7.5) = 8), so Water 18, with no roll.
A Linh Căn Quả on {Fire 86, Wood 40} adds Metal 28, and Fire–Metal makes Thunder eligible.
It rolls once at 0.6 × 0.86 × 0.28 = **14.4 %**, and if it forms its purity is round(0.8 ×
√2,408) = **39**. Light was rolled at birth and does not roll again. `n_base` goes 2 → 3
and the pair bonus is unchanged, because Metal is not adjacent to Fire or Wood in the
generating cycle.

### G. Purity as a scale (owned elsewhere)

Restated for reference:
- **The Meridian Map** owns acupoint scaling (meridian roads are exact and do not scale): `0.5 + purity / 100` for an element sector
  (0.25 if the element is absent, so 0.6–1.5), and bridges average their two sectors. A
  **variant sector** scales by `0.5 + purity / 100` for its variant. It is hidden and
  locked while the variant is not owned, so there is no absent value. A derived variant
  gives 0.58–1.30 and an innate one 0.6–1.5.
- **Cultivation Techniques** owns the technique factor: the average purity of the elements
  and variants it names ÷ 100, about 0.5 for a typical root.
- **Character Stats** owns the element and variant role formulas (Formulas G). Formulas E
  sets the variant coefficients.

**Example:** with Fire 86 and Thunder 47, the Thunder sector scales by 0.5 + 0.47 = 0.97.
A technique naming both Fire and Thunder runs at (86 + 47) ÷ 2 ÷ 100 = **0.665**. A
Wood–Fire bridge acupoint on Wood 40 and Fire 86 is (0.9 + 1.36) ÷ 2 = 1.13.

### Parameter keys

**`character_attributes.json` (`linh_can`):**

| Key | Value | Meaning |
|---|---|---|
| `count_weights` | {1: 45, 2: 32, 3: 15, 4: 6.5, 5: 1.5} | Birth weights for the number of base elements (unchanged) |
| `purity_mean`, `purity_sd` | 50, 20 | Purity distribution for elements and innate variants (unchanged) |
| `purity_min`, `purity_max` | 10, 100 | Purity clamp (unchanged) |
| `pair_bonus_pct` | 3 | Cultivation speed per generating pair (unchanged) |
| `element_count_curve` | table in Formulas B | Keyed by `n_eff` **(change)**; values unchanged |
| `n_cap` | 5 **(new)** | Upper limit of `n_eff` (the curve has five rows) |
| `void_max_elements` | 2 **(new)** | Void is eligible only when `n_base` is at most this, at birth |
| `convergence_factor` | 0.6 **(new)** | Chance factor for Thunder and Darkness |
| `transmutation_factor` | 0.12 **(new)** | Chance factor for Light and Ice |
| `chaos_factor` | 5 **(new)** | Chance factor for Chaos (five parents) |
| `innate_chance` | {phong: 0.025, huyet: 0.015, hu_khong: 0.005} **(new)** | Flat birth chance per innate variant |
| `variant_purity_factor` | 0.8 **(renamed from `bien_di_purity_factor`)** | Discount on the geometric mean for derived purity |
| `awakening_capability` | 24 | The Meridian Map capability that unlocks Mutation Awakening |
| `awakening_max_passes` | 2 **(new)** | Mutation Awakening passes per life. Structural, not a limit the code enforces: only CF→NS and NS→DT can fire it, and no pass counter is saved |
| `variant_power_band` | [10, 30] W **(replaces `bien_di_power_band`)** | Common band: floor at purity 50, ceiling at purity 100 |
| `variant_power_band_apex` | [20, 60] W **(new)** | Chaos band |

Removed: `bien_di_chance_factor`, `bien_di_higher_order_factor`, `bien_di_power_band` (the
four-value form), `herb_age_root_pct` (Time moved to the Way).

**`character_elements.json`:**

| Key | Value | Meaning |
|---|---|---|
| `variants` | 8 entries **(replaces `bien_di`)** | Per variant: `id`, `name`, `desc`, `origin` (convergence, transmutation, innate), `requires` (element ids; empty for innate). Catalogue order is the roll order: Wind, Blood, Void, then Thunder, Darkness, Chaos, Light, Ice |
| `variant_effects` | per variant a list of {`stat`, `per_purity`} **(new)** | Quang `tam_ma_resist_pct` 0.20; Am `stealth` 0.20; Bang `dan_doc_resist_pct` 0.18; Phong `travel_speed_pct` 1.00; Loi `attack_pct` 0.30; Huyet `khi_huyet_pct` 0.25; Hu Khong `co_duyen_pct` 1.00; Hon Don `cultivation_speed_pct` 0.13 and `breakthrough_chance` 0.06 |
| `element_effects` | unchanged | Per-purity element roles (for example `herb_growth_pct_per_purity` 0.8) |

**Other data files:**

| Key | Value | File | Meaning |
|---|---|---|---|
| `tay_tuy_value` | 6 | `items_recipes.json` | Base purity per Tẩy Tủy Đan (minimum gain 1) |
| `max_uses` | 3 | `items_recipes.json` | Tẩy Tủy Đan per life |
| Linh Căn Quả purity range, raise | 20–35, 8 | `items_treasures.json` | Purity of the added element, and the raise when all five are owned |
| `npc_builds.archetype_keep_chance` | 0.2 (*guess*) | `world_generation.json` | Chance an NPC keeps an archetype its root does not fit (rule 15). Owned by NPC Builds |

Design-only constants (not runtime): the Meridian Map stat weights used by Formulas E, with
`travel_speed_pct` and `co_duyen_pct` at 0.3 W per point as a guess.

## Edge Cases

`systems-designer` not consulted for this section (Lean mode). Review manually before
production.

**Birth**

- **If a purity draw falls outside 10–100:** it is clamped. About 2.4 % of draws land on
  10 and 0.67 % on 100. This applies to innate variant purity too.
- **If the root has five elements:** it holds all five generating pairs and is eligible
  for Chaos at birth. Innate variants cannot raise its `n_eff` above 5.
- **If several innate variants form at birth:** each adds 1 to `n_eff`, capped at 5. A
  single root with Wind, Blood and Void has `n_eff` 4. Each innate variant draws its own
  purity right after its success (Formulas A).
- **If Void would be eligible but the root has three or more base elements:** Void makes
  no draw. A Self-made pick of Void on such a root is rejected at input.
- **If a Self-made player picks the strongest root:** five elements at 100 plus every
  qualifying variant (all five derived at their formula purities, plus Wind and Blood) is
  allowed, and is the dominant choice. That is accepted: Self-made is casual (rule 2).
- **If a Self-made life leaves a qualifying variant unpicked:** it is declined and never
  rolls, Awakening included (rule 2). **(change)**: before the redesign, Awakening could
  still form it.

**Effective count**

- **If an innate variant puts `n_eff` above `n_base`:** the curve uses `n_eff`, but the
  pair bonus, the tier name and the Meridian center keystone use `n_base`. A Dual root +
  Wind cultivates on the 3-element curve with at most one pair.
- **If a root reaches `n_eff` 5 through innate variants:** it uses the five-element curve
  row but is not a five-element root. It cannot hold Chaos, does not hold all five pairs
  and does not open the center keystone.
- **If a Linh Căn Quả adds an element to a root already at `n_eff` 5:** `n_base` and the
  pairs change; `n_eff` stays 5.

**Root changes**

- **If several elements tie for weakest when a Tẩy Tủy Đan is taken:** the first in
  cycle order (Wood, Fire, Earth, Metal, Water) gains.
- **If every owned element is already at 100:** the Tẩy Tủy Đan cannot be taken and is
  not consumed.
- **If a Linh Căn Quả is used with all five elements owned:** the +8 goes to the weakest
  element, ties in cycle order, capped at 100. Nothing rolls; the purity of derived
  variants built on that element is recomputed.
- **If an added element raises `n_eff` mid-realm:** the curve row and the generating
  pairs change at once. In an early stage the curve factor can fall, so cultivation slows
  until the curve's crossover. The UI shows the old and new speed before the fruit is
  used.
- **If a Linh Căn Quả adds the fifth element:** Chaos becomes eligible and rolls in the
  same pass as any other newly eligible derived variant, in catalogue order.
- **If a Linh Căn Quả would make Void eligible:** it cannot. Void is innate and decided at
  birth; adding elements never rolls it, and a root that holds Void keeps it when it later
  grows past two elements.
- **If a derived variant already rolled and failed:** it never rolls again in that life,
  except through Mutation Awakening. The root keeps the rolled set.
- **If Mutation Awakening is held and no unowned, non-declined derived variant has its
  requirement met:** the breakthrough makes 0 rolls and writes no record.
- **If every roll in an Awakening pass fails:** no record is written. Only a formed
  variant is recorded.
- **If a Tẩy Tủy Đan raises an element:** the purity of every derived variant that
  requires it is recomputed, with no roll. Its role values (Formulas E) follow the new
  purity at once. Innate purity never changes.

**Meridian Map sectors**

- **If a variant forms mid-life (Awakening, Linh Căn Quả):** its sector appears at once, and
  its entries join the frontier when their host is open (Meridian Map rule 20). Points
  already spent elsewhere are not refunded.
- **If a derived variant's purity rises:** its sector's acupoint scale (0.5 + purity ÷ 100)
  rises with it, like an element sector's.
- **If an NPC owns a variant:** its sector is available to the NPC's build by the same
  rule; hiding is a presentation rule for the player's map only.

**Use by other systems**

- **If a technique names a variant the root lacks:** the technique cannot run at its
  speed. Cultivation Techniques owns the fallback (as built, ×0.3 of the strongest
  purity).
- **If a technique, recipe or item names a relocated mutation (rule 16):** this system
  reports it as not owned. Until the Way is designed and the reference is re-pointed, the
  content is unusable, and the data pass must flag it (Cross-References).
- **If a mortal NPC has no root:** it does not cultivate and is outside this system. A
  cultivator always has at least one element.

**Saves**

- **If a save holds pre-redesign mutations:** the eight retained ids (Light, Darkness,
  Ice, Wind, Thunder, Chaos, Blood and the new Void, which no old save holds) keep their
  ownership; their purity is recomputed by D2 for derived variants, and for Wind and Blood
  (now innate) the stored purity is kept, clamped to 10–100. Relocated mutations are
  dropped from the root and handed to the Way's migration, which that system defines. The
  game is pre-release, so this matters only for development saves.
- **If a save has no rolled set:** every derived variant whose requirement is met is
  marked as rolled on load, and every innate variant is marked as rolled. This preserves
  the save's outcome and prevents a free re-roll. It differs harmlessly from a live birth,
  where a root too large for Void makes no Void roll and so has no Void mark.
- **If a pre-redesign save has a rolled set:** relocated ids are dropped from it, retained
  ids stay, and then the same marking applies. Light now needs only Fire and Ice only
  Water, so a root can meet a requirement it never rolled; those variants are marked
  rolled and get no first roll, though Awakening can still roll them.

## Dependencies

**Upstream:**

| # | System | What Spiritual Roots needs from it |
|---|---|---|
| 1 | Data-Driven Config | `character_attributes.json` (`linh_can`, `element_count_curve`), `character_elements.json` (`variants`, `variant_effects`) |
| 2 | Deterministic Simulation Core | The seeded RNG for the birth roll and variant rolls |

**Upstream, soft (needed for a part of the system):**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 8 | Realms & Bottlenecks | The stage group for the curve lookup; the `breakthrough_succeeded` event | No curve position; Mutation Awakening never rolls |
| 7 | Character Stats | The capability set (rule 16), to check whether #24 is held | Mutation Awakening never rolls |

**Downstream:**

| # | System | What it takes |
|---|---|---|
| 7 | Character Stats | Purities, `n_base`, `n_eff`, the variant set with purities and the variant role lines (Formulas E), the pair-bonus modifiers (through its provider interface). **No longer**: Time's `herb_age_root_pct` or the holder-raised ceilings (relocated mutations) |
| 8 | Realms & Bottlenecks | The curve factor by `n_eff` and stage group. **No longer**: Time's `herb_age_root_pct` in its Formulas D herb factor h |
| 10 | Meridian Map | Purity per element; `n_base` for the center keystone; the owned variants and their purities for the hidden variant sectors (rule 12) |
| 9 | Cultivation Techniques | Purity of the elements and variants a technique names; `n_base` for the count gain (unchanged) |
| 14–18 | Crafts | Element purities for their roles. **No longer**: craft mutations |
| 39 | The Way (Đạo) **(new, undesigned)** | The root as read-only prerequisites; the relocated mutations as seeds (rule 16). Provisional: the Way's GDD confirms or changes this contract |
| 13, 23 | Item DB, Event Engine | They call the root-change rules (Tẩy Tủy Đan, Linh Căn Quả) |
| 3 | World Database | Root changes and variants formed |
| 24, 27 | NPC Builds, World Generation | NPC roots by the same rules; the owned elements for the archetype fit (rule 15) |
| 12 | Codex & Karmic Carryover | Variants discovered across lives |
| 35–37 | Guidance Layer, Debug Terminal, Game UI | The root display |
| 5 | Save/Load | Elements, purities, variants with purities, the rolled set with declined marks, pill counts |
| 11 | Progression Edges | It calls the birth perk rule (rule 2); it reads purities and the variant count for the NPC edge score |
| 20, 21, 32 | Market, Combat, Achievements | The root as read-only input (stock bias, artifact element match, `n_base` and the variant count) |

**Cycles and how they are broken:**
- **Spiritual Roots ↔ Realms & Bottlenecks.** Realms reads the curve factor; Spiritual
  Roots takes the stage group as a lookup argument and subscribes to the
  `breakthrough_succeeded` event. Neither system calls the other.
- **Spiritual Roots ↔ Character Stats and the Meridian Map.** Both read purities, counts
  and variants. This system reads only the capability set, which the Meridian Map writes
  and Character Stats holds; the Meridian Map never calls it (its capability-host rule).
- **Spiritual Roots → the Way.** One-way: the Way reads the root; this system reads
  nothing from the Way.
- Item DB and the Event Engine invoke the change rules (rule 13), and Progression Edges
  invokes the birth perk (rule 2); this system reads nothing from them.

**Bidirectional check.** Character Stats, Realms & Bottlenecks, the Meridian Map and
Cultivation Techniques each list this system. All four were aligned to the redesign on
2026-11-04. Realms was revised on 2026-11-05 (110 levels, harder last two gates): the curve
contract is unchanged, and Awakening's reach in Formulas D3 now follows its odds. The Meridian Map now defines the variant sectors (its rule 20, Formulas H2–H4
and G9; its Open Question 15 is answered), and the Way's row is in the systems index.

**Combat sub-systems (back-references added by the Combat revision #43, 2026-11-08).** This system and the four
systems split out of Combat depend on each other as follows.

- **Combat Damage Types (#21b):** reads the element and variant tags. Elements are art tags only and never enter defence, and the generating and overcoming relations give no damage bonus in fights (its rules 3, 8). The convergence root is named **Primordial Chaos (Hỗn Độn)** in player text, so it is never confused with the Chaos damage type (Tà; its Open Question 1).
- **Modifier System (#40):** root bonuses are catalogue modifiers; element scopes (`kim`, `moc`, `thuy`, `hoa`, `tho`) are its element family.

## Tuning Knobs

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `count_weights` | 45 / 32 / 15 / 6.5 / 1.5 | five-element weight 0.5–3; the weights sum to 100 | Tier rarity; the five-element share is also the share of lives that can reach the center keystone and Chaos (*derived*) |
| `purity_mean` | 50 | 40–60; *derived* floor 40, below which five-element roots fail QR in time. Cultivation Techniques' `tech_norm` 2.0 is tied to it | Every purity-scaled value, element and variant |
| `purity_sd` | 20 | 15–25 | The share of purity ≥ 85 per element: 1.1 % at 15, 4.2 % at 20, 8.4 % at 25 |
| `purity_min` | 10 | 5–20 | The lowest element purity; the derived-variant floor (0.8 × this) |
| `pair_bonus_pct` | 3 | 1–4.5; *derived* ceiling 4.5 (5 pairs under the 50 W keystone floor) | The pair bonus; at 2 four- and five-element roots tie, at 4+ five pulls ahead |
| `n_cap` | 5 | 5 only, unless a sixth curve row is added (which reopens Realms' years table) | How far innate variants can push `n_eff` |
| `convergence_factor` | 0.6 | 0.4–0.8 | Thunder and Darkness, about 1.3–2.6 % of births each |
| `transmutation_factor` | 0.12 | 0.08–0.16 | Light and Ice, about 1.5–3.0 % of births each |
| `chaos_factor` | 5 | 2–8 | Chaos: about 6–25 % of five-element roots (0.09–0.38 % of births); the `min(1, …)` clamp binds sooner as it rises |
| `innate_chance` | Wind 0.025, Blood 0.015, Void 0.005 | each 0–0.04; keep their sum ≤ 0.06 so that at most about 6 % of lives move up a curve row | Innate rarity and the share of lives whose `n_eff` exceeds `n_base` |
| `void_max_elements` | 2 | 1–3; at 5 Void is unconditional | Void's niche as a sparse-root gift |
| `variant_purity_factor` | 0.8 | 0.6–1.0; at 1.0 a derived variant can reach purity 100 and the 30 W ceiling | Derived variant purity, hence its role strength and sector scale |
| `variant_effects` | Formulas E table | any value keeping each variant inside its band (common 10–30 W, Chaos 20–60 W) at purity 50 and 100 | Each variant's role strength |
| `variant_power_band`, `variant_power_band_apex` | 10–30 W; 20–60 W | the apex ceiling should stay above the weakest keystone (50 W, registry `keystone_min_power`) only at purity 100, which a derived Chaos cannot reach (max 80, 46.9 W) | How strong a variant may be |
| `element_count_curve` | Formulas B | any change must keep the parity points | Pacing by `n_eff` |
| `awakening_max_passes` | 2 | structural (only CF→NS and NS→DT can fire it) | Mutation Awakening's reach |
| Tẩy Tủy Đan, Linh Căn Quả values | 6 × 3 per life; 20–35 or +8 | owned by Item DB | Root growth over a life |
| `archetype_keep_chance` | 0.2 (*guess*) | 0–1; owned by NPC Builds | How many NPCs stay in an archetype their root does not fit (rule 15) |

**Interactions.** Raising `variant_purity_factor` raises every derived variant's power and
sector scale at once; retune `variant_effects` in the same pass. Raising any
`innate_chance` also raises the share of lives on a higher curve row, which moves Realms
& Bottlenecks' tier pacing; check it with the Realms bot run (Open Question 1).

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). Intent: each element and each variant has its
colour (the data already holds an ANSI colour per element; variants need one each in the
data pass); a variant shows its origin (the elements it converged or transmuted from, or
"innate"); a variant forming is a celebrated moment, and its Meridian sector revealing
itself is part of that moment.

## Game Feel

Not specified at this tier. Intent: the birth roll is the run's first big reveal; a
five-element root should feel like a gamble on the long game; a derived variant should
feel earned by the root you have, and an innate one like fate.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.
- **The root line.** It shows the tier, each element with its purity (in its colour) and
  each variant with its purity, and the effective count when it differs from the tier,
  for example "Dual root: Fire [Hỏa] 86, Water [Thủy] 60 + Wind [Phong] 62 (counts as 3)".
  It appears on the birth line and in NPC views.
- **The sheet's root block.** It shows the tier, the curve row and factor, a bar per element
  and, for each owned variant, its purity, origin and role lines.
- **Speed.** The current curve factor (by `n_eff`), where parity comes (not built yet, Open
  Question 12), and the generating pairs with their +3 % each.
- **Variants.** Each owned variant's origin, requirement and role lines (via `explain`; not
  built yet, Open Question 12). Variants that rolled and failed, or were declined, are not
  shown as available.
- **Meridian Map.** An unowned variant's sector is not drawn and not hinted; the map shows
  only owned variants' sectors.
- **Root changes.** Before a Linh Căn Quả is used, the screen lists each missing element
  to pick from, and for each one the new tier, the new `n_eff`, the speed before and after,
  the pair bonus and the derived variants it would make eligible. The added purity is still
  rolled, so it is shown as 20–35. A Tẩy Tủy Đan shows which element it will raise and which
  derived variants' purity will rise with it (not built yet, Open Question 12).

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Spiritual Root System: tiers, the trade-off, root mutations, changing roots. Now has a "Variant roots" section (eight variants, three origins) and names the Way (Đạo); re-check its remaining Spiritual Root prose against this GDD at its next edit |
| `design/gdd/canh-gioi.md` | Stage groups and the years-per-realm costs (Formulas A); the `breakthrough_succeeded` event (Mutation Awakening). **Cross-edit done** (its status line, 2026-11-04): curve keyed by `n_eff`, Time's `herb_age_root_pct` removed, AC-CG-60 runs with Awakening off |
| `design/gdd/character-stats.md` | Element and variant role formulas (Formulas G), the stat sheet and provider interface, rule 14 (ceilings). **Cross-edit done** (its status line, 2026-11-04): variant role lines added, holder-raised ceilings and Time's root factor removed, `co_duyen_pct` is a sheet key. Its Formulas G example no longer names Time (checked 2026-11-05) |
| `design/gdd/kinh-mach-do.md` | Acupoint scaling (rule 4), stat weights W (Formulas F). Its rule 20 and Formulas H2–H4 define the hidden variant sectors (rule 12). Still open there: weights for `travel_speed_pct` and `co_duyen_pct` (Open Question 2) |
| `design/gdd/cong-phap.md` | Rule 8's purity contract (`match`); usability of techniques naming an id the root lacks (its rule 8). `count_gain` stays keyed by `n_base` (rule 3). Wording aligned to variant roots (its status line). **Pending**: techniques naming relocated mutations are re-pointed to the Way |
| The Way (Đạo), system 39 | **New, undesigned.** Owns the relocated mutations (rule 16) and reads the root. Run `/design-system dao` |
| `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md` | Tẩy Tủy Đan and Linh Căn Quả |
| `design/quick-specs/progression-and-edges.md` | The birth perk Linh Căn Thuần Tịnh (rule 2) |
| `design/glossary.md` | Element and variant names |
| `assets/data/character_attributes.json`, `character_elements.json` | The data behind this GDD's keys: `bien_di` → `variants` + `variant_effects`, new chance keys, curve keyed by `n_eff` |
| `src/gameplay/character/linh_can.gd`, `src/gameplay/cultivation/cultivation_rules.gd`, `src/gameplay/items/treasure_effects.gd`, `src/gameplay/items/pill_effects.gd`, `src/gameplay/build/build_generator.gd` | Code the redesign touches |

## Acceptance Criteria

Drafted with `qa-lead`, which recomputed every worked number and checked the birth rates on
2,000,000 simulated births.

- **Tags.** Each criterion carries [story type · gate]. Logic, Integration and UI are
  BLOCKING and Config/Data is ADVISORY (`testing.strict` is unset). BLOCKED-ON means the
  criterion is written and gated but cannot run until the named cross-edit lands.
- **Suites.** Logic suites live in `tests/unit/character/`, next to
  `linh_can_rules_test.gd` and `linh_can_change_test.gd`. Integration suites live in
  `tests/integration/character/`.
- **RNG stub.** A test double returns a scripted list and logs each call in order: U is a
  uniform draw in [0, 1), N is a normal draw. N returns the final sample, so N 40.0 is raw
  purity 40.0 before rounding. A call past the end of the list, or a value left over,
  fails the test.
- **Statistical tests.** Each uses a fixed seed stored as a constant in the test, with a
  tolerance of at least four standard errors.
- **Notation.** {Fire 86, Metal 40} + Thunder 47 is a root with those purities that owns
  Thunder at 47.
  - Cycle order: Wood, Fire, Earth, Metal, Water.
  - Catalogue order: Wind, Blood, Void, Thunder, Darkness, Chaos, Light, Ice.
  - "Forced" means the stub makes that roll succeed (U 0.0) or fail (U 0.99).
- **UI evidence** is a retained screenshot plus transcript in
  `production/qa/evidence/debug-terminal/`.

**Birth**

- **AC-LC-01** [Logic · BLOCKING] Rule 2, count. Stubbed count draws 0.0 / 0.30 / 0.449 / 0.451 / 0.60 / 0.769 / 0.771 / 0.80 / 0.919 / 0.921 / 0.95 / 0.984 / 0.986 / 0.99 / 0.9999 give 1 / 1 / 1 / 2 / 2 / 2 / 3 / 3 / 3 / 4 / 4 / 4 / 5 / 5 / 5 elements. The values sit either side of each boundary on purpose: an exact float boundary such as 0.92 × 100 is not reliable, so the test does not rely on one.
- **AC-LC-02** [Logic · BLOCKING] Rule 2, elements, over 200,000 births:
  - tier shares 45 / 32 / 15 / 6.5 / 1.5 % (±0.5 pp);
  - among 2-element roots each of the 10 pairs appears 10 % ± 1.0 pp of the time, and among 3-element roots each of the 10 triples does.
- **AC-LC-03** [Logic · BLOCKING] Purity rounding and clamp.
  - Raw 59.6 / 84.5 / 10.4 / 10.5 / 99.5 / 2.0 / 130 gives 60 / 85 / 10 / 11 / 100 / 10 / 100, for an element and for an innate variant.
  - Over 200,000 draws: exactly 10 is 2.41 % (±0.2 pp), exactly 100 is 0.67 % (±0.1 pp), ≥ 85 is 4.24 % (±0.25 pp), and the mean is 50.1 (±0.2).
- **AC-LC-04** [Logic · BLOCKING] Draw order, Triple root. The stub gives U 0.80, U 0.0, U 0.0, U 0.9, N 40.0, N 86.0, N 10.0, U 0.021, N 60.0, U 0.40, U 0.05, U 0.20. Then:
  - the root is {Wood 40, Fire 86, Water 10} + Wind 60, Light 69, a Triple root with effective count 4;
  - Void, Thunder, Darkness and Chaos make no draw;
  - the rolled set is {Wind, Blood, Light, Ice};
  - the call log equals that list exactly: 8 U, 4 N, and the N for Wind comes directly after its U.
- **AC-LC-05** [Logic · BLOCKING] Draw order, Dual root with Void. The stub gives U 0.50, U 0.30, U 0.60, N 86.0, N 40.0, U 0.99, U 0.010, N 30.0, U 0.004, N 75.0, U 0.10, U 0.99. Then:
  - the root is {Fire 86, Metal 40} + Blood 30, Void 75, Thunder 47, with `n_base` 2 and `n_eff` 4;
  - Wind failed with no N after it, and Blood and Void each drew their N directly after success;
  - Light drew and failed; Darkness, Chaos and Ice made no draw;
  - the rolled set is {Wind, Blood, Void, Thunder, Light}.
- **AC-LC-06** [Logic · BLOCKING] Draw counts.
  - Five elements: U 0.99, U 0.0 × 5, N 60.0, 50.0, 45.0, 70.0, 55.0, U 0.99 × 7 makes 13 U and 5 N. The fifth element draw is still made, Void makes no draw, and all five derived variants draw.
  - Single root {Wood 50}: U 0.30, U 0.0, N 50.0, U 0.99 × 3 makes 5 U and 1 N, with no derived draw.
  - Over 10,000 seeded births, U = 1 + `n_base` + 2 + (1 if `n_base` ≤ 2) + the number of derived variants whose requirement is met, and N = `n_base` + innate successes.
  - The same seed twice gives the same root and rolled set.
- **AC-LC-07** [Logic · BLOCKING] Rule 1, ranges. Over 10,000 seeded births:
  - every owned element is an integer in 10–100 and every absent element reports 0;
  - every derived variant is in 8–80 and every innate variant in 10–100;
  - {Earth 10, Water 10} + Darkness has Darkness at 8.
- **AC-LC-08** [Logic · BLOCKING] Rule 3, tier. 1–5 base elements name Single, Dual, Triple, Quadruple and Five-element. {Fire, Metal} + Thunder is Dual, {Wood} + Wind is Single, and all five + Chaos is Five-element.
- **AC-LC-09** [Logic · BLOCKING] Rule 2, Self-made, on {Fire 86, Metal 40} with picks Thunder and Wind:
  - the RNG is called 0 times;
  - Thunder is 47 and Wind is 50;
  - the rolled set is {Wind, Blood, Void, Thunder, Light} and the declined set is {Blood, Void, Light};
  - purity 9 or 101 is rejected at input, and 10 and 100 are accepted;
  - Thunder on {Fire 86} is rejected;
  - Void on any 3-, 4- or 5-element root is rejected, and Void on {Fire, Metal} is accepted at 50;
  - five elements at 100 with all five derived variants, Wind and Blood is accepted, with every derived variant at 80.
- **AC-LC-10** [Integration · BLOCKING] Rule 2, declined. Given the AC-LC-09 root with capability #24 held, when Core Formation → Nascent Soul succeeds with rolls forced to succeed, then Light makes no draw and is not owned. When a Linh Căn Quả then adds Water, Ice (which did not qualify at birth) makes one draw and Light still makes none.
- **AC-LC-52** [Logic · BLOCKING] Rule 2, birth perk. {Fire 86, Metal 40} + Thunder 47 with Linh Căn Thuần Tịnh gives Fire 94, Metal 48 and Thunder round(0.8 × √4512) = 54, with 0 rolls and 0 change records. Fire 95 stops at 100.

**Effective count, curve and pairs**

- **AC-LC-11** [Logic · BLOCKING] Rule 3, `n_eff`:
  - {Fire} = 1;
  - {Fire} + Wind = 2;
  - {Fire} + Wind, Blood, Void = 4;
  - {Fire, Water} + Wind = 3;
  - {Fire, Metal} + Thunder, Light = 2 (derived adds 0);
  - {Fire, Metal} + Wind, Blood, Void = 5;
  - three elements + Wind, Blood = 5;
  - four elements + Wind = 5;
  - four elements + Wind, Blood = 5 (capped from 6);
  - all five + Chaos = 5;
  - all five + Wind = 5.
- **AC-LC-12** [Config/Data · ADVISORY] `element_count_curve` holds 65 values, identical to `assets/data/character_attributes.json` at git b7f4639, and its rows are keyed 1–5.
- **AC-LC-13** [Logic · BLOCKING] Rule 4, shape.
  - The factor is exactly 1.0 at `tc_trung` for rows 2 and 3, at `tc_hau` for row 4 and at `kd_so` for row 5, and below 1.0 in every earlier column.
  - `lk_early` runs 1 / 0.6 / 0.5 / 0.4 / 0.3 and `ht` runs 1 / 4 / 5.5 / 7 / 9.
  - No row falls from one stage group to the next.
- **AC-LC-14** [Logic · BLOCKING] Rules 3–5, what reads which count.
  - {Fire 86, Water 60} + Wind reads 0.5 at `lk_early`, 1.0 at `tc_trung` and 3.9 at `kd_dvm`. Plain {Fire 86, Water 60} reads 0.6, 1.0 and 3.1.
  - {Fire 86, Metal 40} + Thunder reads 0.6 at `lk_early` and 4.0 at `ht`.
  - Over 1,000 seeded roots, removing the derived variants never changes the factor.
  - {Wood 40, Fire 86} + Wind has tier Dual, `n_eff` 3 and 1 pair (+3 %).
  - {Fire, Metal} + Wind, Blood, Void has `n_eff` 5, tier Dual, 0 pairs, and Chaos is not eligible.
- **AC-LC-15** [Integration · BLOCKING] Curve with Realms & Bottlenecks.
  - Stage groups map QR `lk_early` / `lk_mid` / `lk_late` / `lk_late`; FE `tc_so` / `tc_trung` / `tc_hau` / `tc_dvm`; CF `kd_so` / `kd_trung` / `kd_hau` / `kd_dvm`; NS `na`; DT `ht`.
  - A Dual root + Wind reads 0.75 at QR stage 4, 4.5 at NS and 5.5 at DT.
  - At equal rate with the pair bonus off, it crosses FE in the same time as a plain Triple root.
  - A single root in FE early stage that gains a second element reads 0.9 on the next cultivation tick.
  - {Fire, Water} + Wind in FE early stage that gains Metal goes from 0.9 to 0.75 on the next tick, and its pairs go from 0 to 1.
  - A four-element root + Wind that gains its fifth element keeps its factor and goes from 3 pairs to 5.
- **AC-LC-16** [Logic · BLOCKING] Formula C, over all 31 element subsets.
  - 1 element gives 0 pairs. 2 elements give 0 or 1 pair, 5 subsets each. 3 elements give 1 or 2 pairs, 5 subsets each. 4 elements give 3 and 5 elements give 5.
  - The bonus is 3 % per pair, 0–15 % in total.
  - {Fire, Water, Wood} is 2 pairs, +6 %.
  - The overcoming pair {Fire, Metal} is 0 pairs, and adding Thunder or Wind to it stays 0.
- **AC-LC-17** [Integration · BLOCKING] Rule 5, stat sheet.
  - {Wood, Fire, Water} gives exactly two `cultivation_speed_pct` +3 modifiers, sourced "Tương sinh: Mộc → Hỏa" and "Tương sinh: Thủy → Mộc".
  - A five-element root gets five totalling +15.
  - A single root gets none.

**Variants: data and rolls**

- **AC-LC-18** [Config/Data · ADVISORY] Rule 9, catalogue. `character_elements.json` has no `bien_di` key and exactly 8 `variants`, in this order:

  | id | origin | `requires` |
  |---|---|---|
  | `phong` | innate | [] |
  | `huyet` | innate | [] |
  | `hu_khong` | innate | [] |
  | `loi` | convergence | hoa, kim |
  | `am` | convergence | tho, thuy |
  | `hon_don` | convergence | all five |
  | `quang` | transmutation | hoa |
  | `bang` | transmutation | thuy |

  Every entry has `id`, `name`, `desc`, `origin` and `requires`, and every id in `requires` is an element.
- **AC-LC-19** [Config/Data · ADVISORY] Parameters.
  - `linh_can` holds `count_weights` 45 / 32 / 15 / 6.5 / 1.5 (sum 100), `purity_mean` 50, `purity_sd` 20, `purity_min` 10, `purity_max` 100, `pair_bonus_pct` 3, `n_cap` 5, `void_max_elements` 2, `convergence_factor` 0.6, `transmutation_factor` 0.12, `chaos_factor` 5, `innate_chance` {phong 0.025, huyet 0.015, hu_khong 0.005}, `variant_purity_factor` 0.8, `awakening_capability` 24, `awakening_max_passes` 2, `variant_power_band` [10, 30] and `variant_power_band_apex` [20, 60].
  - `bien_di_chance_factor`, `bien_di_higher_order_factor`, `bien_di_purity_factor`, `bien_di_power_band`, `herb_age_root_pct`, `bien_di_counts_as_element` and `max_counted_elements` are gone from the data and from `src/`.
- **AC-LC-20** [Logic · BLOCKING] Formula D1 chances, within 1e-9:
  - Thunder (Fire 86, Metal 40) = 0.2064 (20.6 %);
  - Light (Fire 86) = 0.1032 (10.3 %);
  - Chaos (60 / 50 / 45 / 70 / 55) = 0.259875 (26.0 %);
  - Ice (Water 10) = 0.012 and Ice (Water 100) = 0.12;
  - Darkness at 10 / 10 = 0.006 and at 100 / 100 = 0.6;
  - Chaos with five at 10 = 0.00005, five at 72 = 0.967458816, and five at 73 = 1.0 (clamped);
  - Wind, Blood and Void are 0.025, 0.015 and 0.005 on every root.

  A draw equal to the chance fails: U 0.025 on Wind does not form it.
- **AC-LC-21** [Logic · BLOCKING] Formula D2 purity:
  - Thunder (86, 40) → 47 and (86, 48) → 51;
  - Thunder (86, 28) → 39;
  - Light (86) → 69;
  - Chaos (60 / 50 / 45 / 70 / 55) → 44;
  - any derived variant with all requirements at 10 → 8 and at 100 → 80.
- **AC-LC-22** [Logic · BLOCKING] Rule 10, formation over 50,000 rolls. Thunder on {Fire 86, Metal 40} forms 20.64 % ± 0.75 pp of the time, always at 47. Light on {Fire 86} forms 10.32 % ± 0.55 pp, always at 69.
- **AC-LC-23** [Logic · BLOCKING] Formula D1, birth rates over 200,000 births:

  | Measure | Rate | Tolerance |
  |---|---|---|
  | At least one variant | 12.14 % | ±0.30 pp |
  | At least one innate | 4.34 % | ±0.20 pp |
  | Wind | 2.50 % | ±0.15 pp |
  | Blood | 1.50 % | ±0.12 pp |
  | Void | 0.385 % | ±0.06 pp |
  | Thunder | 1.97 % | ±0.15 pp |
  | Darkness | 1.97 % | ±0.15 pp |
  | Light | 2.25 % | ±0.15 pp |
  | Ice | 2.25 % | ±0.15 pp |
  | Chaos | 0.236 % | ±0.05 pp |

  Births by `n_eff` 1–5 are 43.00 / 32.55 / 15.83 / 6.85 / 1.76 % (±0.45 / 0.45 / 0.35 / 0.25 / 0.12 pp).
- **AC-LC-24** [Logic · BLOCKING] Rule 10, rolling once. Given {Fire 86, Metal 40} with Thunder and Light rolled and failed:
  - a second formation pass makes 0 draws;
  - three Tẩy Tủy Đan make 0 draws;
  - a Linh Căn Quả adding Water draws for Ice only, never for Thunder or Light.
- **AC-LC-25** [Logic · BLOCKING] Rules 9 and 11, what a variant is. {Fire 86} + Light 69:
  - Light reports as owned at purity 69;
  - Fire is still owned at 86;
  - the tier is Single, `n_base` is 1 and `n_eff` is 1;
  - there are 0 pairs.

**Roles and power**

- **AC-LC-26** [Integration · BLOCKING] Rule 6, element roles as built. On {Wood 40, Fire 86, Earth 50, Metal 40, Water 60} the root's lines in each breakdown are:
  - herb growth "Mộc purity 40" +32 %;
  - alchemy "Hỏa purity 86" +21.5;
  - field plots "Thổ purity 50" +2;
  - mission income "Kim purity 40" +32 %;
  - pill-toxicity decay "Thủy purity 60" +3.0.

  Adding Wind or Thunder changes none of these. An absent element contributes 0.
- **AC-LC-27** [Logic · BLOCKING] Formula E, with hard-coded fixture weights (W per displayed unit):

  | Variant | Key | Per purity | W per unit | Value p50 / p100 | W p50 / p100 |
  |---|---|---|---|---|---|
  | Light | `tam_ma_resist_pct` | 0.20 | 1.5 | 10.0 / 20.0 | 15.0 / 30.0 |
  | Darkness | `stealth` | 0.20 | 1.5 | 10.0 / 20.0 | 15.0 / 30.0 |
  | Ice | `dan_doc_resist_pct` | 0.18 | 1.6 | 9.0 / 18.0 | 14.4 / 28.8 |
  | Wind | `travel_speed_pct` | 1.00 | 0.3 | 50.0 / 100.0 | 15.0 / 30.0 |
  | Thunder | `attack_pct` | 0.30 | 1.0 | 15.0 / 30.0 | 15.0 / 30.0 |
  | Blood | `khi_huyet_pct` | 0.25 | 1.2 | 12.5 / 25.0 | 15.0 / 30.0 |
  | Void | `co_duyen_pct` | 1.00 | 0.3 | 50.0 / 100.0 | 15.0 / 30.0 |
  | Chaos | `cultivation_speed_pct` | 0.13 | 2.2 | 6.5 / 13.0 | 14.3 / 28.6 |
  | Chaos | `breakthrough_chance` | 0.06 | 5 | 3.0 / 6.0 | 15.0 / 30.0 |
  | Chaos total | | | | | 29.3 / 58.6 |

  Values floor to 0.1 in integer arithmetic on hundredths:
  - Thunder 47 → 14.1 and Thunder 51 → 15.3;
  - Blood 47 → 11.7 and Ice 47 → 8.4;
  - Chaos 44 → 5.7 and 2.6 (25.54 W);
  - Chaos 80 → 10.4 and 4.8 (46.88 W).

  A floating-point floor returns 15.2 for Thunder 51 and 4.7 for Chaos 80 at the `breakthrough_chance` line, so those two cases catch it.
- **AC-LC-28** [Config/Data · ADVISORY] Band check. `variant_effects` has one entry per variant and two for `hon_don`.
  - Each `per_purity` has at most 2 decimals and each `stat` exists in `character_stat_labels.json`.
  - At the AC-LC-27 weights, the seven common variants price ≥ 10 W at purity 50 and ≤ 30 W at purity 100.
  - Chaos prices ≥ 20 W at 50 and ≤ 60 W at 100.
  - The Wind and Void results are provisional: their 0.3 W weight is a guess.
- **AC-LC-29** [Integration · BLOCKING] Rule 7, stat sheet. Each owned variant adds exactly these lines:

  | Owned | Stat and value | Source |
  |---|---|---|
  | Light 69 | `tam_ma_resist_pct` +13.8 | "Biến dị: Quang" |
  | Darkness 47 | `stealth` +9.4 | "Biến dị: Ám" |
  | Ice 47 | `dan_doc_resist_pct` +8.4 | "Biến dị: Băng" |
  | Wind 60 | `travel_speed_pct` +60.0 | "Biến dị: Phong" |
  | Thunder 47 | `attack_pct` +14.1 | "Biến dị: Lôi" |
  | Blood 50 | `khi_huyet_pct` +12.5 | "Biến dị: Huyết" |
  | Void 75 | `co_duyen_pct` +75.0 | "Biến dị: Hư Không" |
  | Chaos 44 | `cultivation_speed_pct` +5.7 and `breakthrough_chance` +2.6 | "Biến dị: Hỗn Độn" |

  - An unowned variant adds no line.
  - Thunder's line reads +15.3 straight after a pill lifts it to 51.
  - Chaos's line sits outside the tree's 8 pp cap: tree lines at the cap plus Chaos 80 total +12.8 pp on the sheet. At an attempt, Realms' q-extras ceiling then clamps that sum (its Formulas C, AC-CG-65).

**Mutation Awakening (Biến Dị Khai Mở)**

- **AC-LC-30** [Integration · BLOCKING] Rule 10 and Formula D3. Given a player on {Fire 86, Metal 40} with the rolled set {Wind, Blood, Void, Thunder, Light} and nothing owned:
  - without #24, a realm breakthrough makes 0 draws;
  - with #24, Core Formation → Nascent Soul makes exactly 2 U and 0 N, Thunder at chance 0.2064 then Light at 0.1032, and forced fail changes nothing and writes no record;
  - with Metal raised to 48 first, Thunder's chance is 0.24768, read from current purities;
  - Nascent Soul → Deity Transformation with forced success forms Thunder and Light, and they make no further draw;
  - Wind, Blood, Void and Ice make no draw in any pass, even with every roll forced to succeed.
- **AC-LC-31** [Logic · BLOCKING] Formula D3, reach, over 50,000 fixture lives of a birth roll plus two passes. Thunder on {Fire 86, Metal 40} is owned in 50.0 % ± 0.9 pp and Light on {Fire 86} in 27.9 % ± 0.85 pp.
- **AC-LC-32** [Integration · BLOCKING] Zero rolls. With #24 held, a breakthrough on {Wood 40} makes 0 draws and writes 0 World Database records. The same holds for {Fire 86} + Light, and for a root whose only unowned eligible variants are declined.

**Meridian Map and techniques**

- **AC-LC-33** [Integration · BLOCKING] Rule 12.
  - While a variant is unowned, its sector is not drawn, a spend into it is refused, and the reported map size excludes it.
  - A root with Wind at birth has the Wind sector visible at once, and a spend into it is accepted with the entry's host open.
  - Thunder forming mid-life, through Awakening or a Linh Căn Quả, makes its sector visible at once and spendable with a host open, and refunds nothing.
  - With every host closed, the sector is visible and a spend into it is refused until the player walks to a host (Meridian Map AC-KMD-71).
  - Across every later root change and a save/load, the sector stays visible.
  - An NPC owning a variant can spend in that sector.
- **AC-LC-34** [Integration · BLOCKING] Formula G and rule 8, with {Wood 40, Fire 86} and {Fire 86, Metal 40} + Thunder 47, Wind 62.
  - Sector scale: Thunder 0.97, then 1.01 after a pill lifts it to 51; Wind 1.12, unchanged by the pill.
  - A technique naming Fire and Thunder runs at 0.665, then 0.685 after the pill.
  - On {Wood 40, Fire 86}: Wood sector 0.9, Fire 1.36, absent Earth 0.25, Wood–Fire bridge 1.13, and a Wood–Fire technique runs at 0.63.
  - Owning Thunder does not change the Fire or Metal sector scale.
- **AC-LC-35** [Integration · BLOCKING] Center keystone reads `n_base`. It is refused on four elements + Wind (`n_eff` 5) and on {Fire, Metal} + Wind, Blood, Void, and allowed on all five base elements.
- **AC-LC-36** [Integration · BLOCKING] Rule 3, `count_gain` reads `n_base`. A Dual root + Wind and a Dual root + Thunder read the same `count_gain` as a plain Dual root, and a Triple root reads its own value.

**Root changes**

- **AC-LC-37** [Logic · BLOCKING] Rule 13, Tẩy Tủy Đan.
  - Water 10 at potency 1.25 → 18, with 0 RNG calls.
  - Potency 0.05 → +1 and potency 0 → +1.
  - A weakest element at 97 with potency 1.0 → 100.
  - Ties go in cycle order: {Fire 30, Metal 50, Water 30} raises Fire, and {Wood 30, Water 30} raises Wood.
  - Variants are not candidates: {Fire 40, Metal 50} + Wind 12 raises Fire.
- **AC-LC-38** [Logic · BLOCKING] Rule 10 recompute. {Fire 86, Metal 40} + Thunder 47, Light 69, Wind 60 at potency 1.25 raises Metal to 48. Thunder becomes 51, Light stays 69 and Wind stays 60, with 0 draws. {Fire 30, Metal 30} + Thunder 24 at potency 1.0 raises Fire to 36 and Thunder to 26.
- **AC-LC-39** [Logic · BLOCKING] Refused and kept. A fourth Tẩy Tủy Đan, or one taken with every owned element at 100, is refused. The inventory, the use counter, the purities and the World Database are all unchanged. A refusal at 100 does not count toward the three.
- **AC-LC-40** [Logic · BLOCKING] Linh Căn Quả adds an element. Given {Fire 86, Wood 40} with the rolled set {Wind, Blood, Void, Light}, the player picking Metal, and added purity 28:
  - the call log is 1 U for the purity, then 1 U for Thunder at chance 0.14448, with no element draw;
  - a forced success forms it at 39, and Light does not roll;
  - `n_base` goes 2 → 3 and the pairs stay at 1 (+3 %);
  - the pick offers Earth, Metal and Water, never owned Fire;
  - at function level (rule 15), an NPC's fruit first draws 1 U for the element: over 16,000 NPC uses, Earth, Metal and Water each appear 33.3 % ± 1.5 pp, never Fire;
  - over 16,000 uses each purity from 20 to 35 appears 6.25 % ± 0.8 pp.
- **AC-LC-41** [Logic · BLOCKING] Fifth element. Given {Wood 50, Fire 60, Earth 50, Metal 40} with Wind, Blood, Thunder and Light rolled and failed, a Linh Căn Quả adds Water at 30.
  - Exactly three rolls are made, in order: Darkness (0.09), Chaos (0.09), Ice (0.036).
  - Forced success forms Darkness 31, Chaos 36 and Ice 24.
  - The root is Five-element with 5 pairs.
- **AC-LC-42** [Logic · BLOCKING] Innate never rolls later. A Linh Căn Quả or a pill makes no draw for Wind, Blood or Void on any root. {Fire, Metal} + Void 75 that gains Water keeps Void at 75, with `n_base` 3 and `n_eff` 4.
- **AC-LC-43** [Logic · BLOCKING] All five owned, on {Wood 50, Fire 30, Earth 60, Metal 30, Water 90} + Thunder 24:
  - a Linh Căn Quả raises Fire to 38, a tie broken in cycle order;
  - Thunder becomes 27 and 0 rolls are made;
  - the player is offered no pick, because no element is missing;
  - a weakest element at 95 → 100;
  - with all five at 100, the fruit is refused and kept.
- **AC-LC-44** [Logic · BLOCKING] Rule 14. Over 1,000 seeded random sequences of pills, fruits and Awakening passes, no element or variant is lost, no purity falls, and none exceeds 100.
- **AC-LC-45** [Integration · BLOCKING] World Database. Each accepted change and each formed variant writes exactly one record with the old and new values. A refused item, and an Awakening pass with no formed variant, writes none.

**NPCs and relocated mutations**

- **AC-LC-46** [Integration · BLOCKING] Rule 15.
  - An NPC and a player with the same RNG state at the root roll get the same root and rolled set.
  - An archetype adds no element: an NPC whose root lacks any of its archetype's elements keeps its root, and over 16,000 such NPCs about 20 % ± 1.3 pp keep the archetype.
  - An NPC blessed with Linh Căn Thuần Tịnh has every element at its rolled purity + 8, capped at 100, and derived variants recomputed. A blessing with no birth effect leaves the root unchanged.
  - Every NPC cultivator has at least one element.
  - At function level (rule 15), NPC pills and fruits follow AC-LC-37 to AC-LC-43.
  - An NPC breakthrough with #24 in its capability set makes 0 Awakening draws and writes 0 records.
- **AC-LC-47** [Logic · BLOCKING] Rule 16. For each of the 22 ids `dung_nham`, `trong`, `sinh_menh`, `doc`, `vu`, `kiem`, `thien_loi`, `huy_diet`, `tu`, `dan_hoa`, `linh_thuc`, `tinh_kim`, `tran`, `hon`, `huyen`, `tinh_than`, `khong_gian`, `am_tinh`, `duong`, `luan_hoi`, `thai_cuc`, `thoi_gian`:
  - the root reports not owned and purity 0;
  - the id is absent from `variants`;
  - it never enters an owned or rolled set over 200,000 births and 1,000 change sequences.

**Saves**

- **AC-LC-48** [Logic · BLOCKING] Round trip. A save/load keeps the elements, purities, variants with their purities, the rolled set with declined marks, and the pill count; each variant's origin still reads from the data. After reload:
  - a fourth pill is still refused;
  - a failed variant still makes no draw on a fruit;
  - a declined variant still makes no Awakening draw.
- **AC-LC-49** [Logic · BLOCKING] Pre-redesign save. Given {Wood 40, Fire 86, Metal 40, Water 60} holding `quang` stored 47, `loi` stored 99, `phong` stored 39, `huyet` stored 6, `dan_hoa` and `kiem`, with an old rolled set holding `quang`, `loi` and `kiem`:
  - after load Light is 69 and Thunder 47 (stored purities ignored);
  - Wind is 39 and Blood is 10 (stored value kept, clamped);
  - `dan_hoa` and `kiem` are not in the root or the rolled set;
  - Ice, which the old rolled set lacks but whose requirement is met, is marked rolled;
  - the tier is Quadruple and `n_eff` is 5.
- **AC-LC-50** [Logic · BLOCKING] Save with no rolled set. {Wood 40, Fire 86, Water 60} + Light loads with the rolled set {Wind, Blood, Void, Light, Ice}. A later fruit adding Earth at 28 draws for Darkness only (chance 0.1008), not for Ice. With #24 held, a later Awakening pass does roll Ice.

**UI**

- **AC-LC-51** [UI · BLOCKING] Root line and `explain`. Evidence is a retained screenshot plus transcript in `production/qa/evidence/debug-terminal/`.
  - {Fire 86, Water 60} + Wind 62: the root line (birth line) reads "Dual root: Fire [Hỏa] 86, Water [Thủy] 60 + Wind [Phong] 62 (counts as 3)". The sheet's root block shows curve row 3 and Wind 62 with origin innate.
  - {Fire 86, Metal 40} + Thunder 47: the root line reads "Dual root: Fire [Hỏa] 86, Metal [Kim] 40 + Thunder [Lôi] 47" with no "counts as" text. The sheet's root block shows Thunder 47 with origin convergence.
  - A variant that failed its roll does not appear on either screen.
  - **Provisional** (not built, Open Question 12): `explain` for Thunder shows its origin, its requirement (Fire and Metal), purity 47 and +14.1 attack with source "Biến dị: Lôi".
  - `explain rate` shows the curve row read (3 for the first fixture). **Provisional** (not built, Open Question 12): it also shows each pair source.
  - The Linh Căn Quả preview on the first fixture in FE early stage lists each missing element, and Metal shows Dual → Triple, the factor 0.9 → 0.75 and the added +3 % pair.

**Not testable here, by design:**
- Total lives holding a variant (about 12.4–13.5 %) depends on E_p, an unsourced estimate that needs a bot run (Open Question 1).
- The years-per-realm table depends on the guessed rate factor.
- The Wind and Void weights are guesses, so their band results in AC-LC-28 are provisional.
- Granting Linh Căn Quả only by events from Foundation Establishment on belongs to the Event Engine's suite.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Awakening frequency and pacing. Formulas D3 puts Awakening at about 0.176 passes per life with every life holding #24 (about 13.2–13.5 % of lives with a variant); a bot run must supply the real figure. The same run checks the tight timing spots (single roots at NS and DT, five-element roots in QR) and the share of lives that innate variants move up a curve row (4.3 %) | Realms & Bottlenecks calibration, systems-designer | Formulas B, D3 |
| 2 | `travel_speed_pct` (Wind) and `co_duyen_pct` (Void) have no Meridian Map weight; Formulas E prices both at 0.3 W per point, a guess. Void's purity-100 value (+100 %) matches the Cơ duyên edge's `co_duyen_pct` +100, which also carries `khi_van` 15. What Void's `co_duyen_pct` actually does, and what "secret realms" means, is undefined in any GDD; deferred by the user 2026-11-05 | Meridian Map, systems-designer | Formulas E |
| 3 | Meridian Map capability #24 (Mutation Awakening) still needs a price. It now affects only five derived variants: Light on Fire 86 goes from 10.3 % to 27.9 % over its two possible passes | Meridian Map | Capability pricing |
| 4 | ~~The variant sectors (rule 12) are a contract only~~ **Closed 2026-11-04:** Meridian Map rule 20 and its Formulas H2–H4 define geometry, size, attachment and pricing | — | — |
| 5 | A five-element root's early power. Before the redesign it started with about 109 W (keystone, pair bonus, mean mutations) against the Meridian Map's ~106 W end-of-QR target (cross-review D2). Recompute with the variant prices (a five-element root averages more derived variants: 16 % Chaos, 15 % each convergence, 6 % each transmutation) and the variant sectors (Meridian Map Formulas H3: 88.5 W at purity 50) | Meridian Map, game-designer | Player Fantasy, Formulas C |
| 6 | Linh Căn Quả is rare by design and has no per-life counter, yet one fruit can add a curve row and make Chaos or a convergence eligible. Its frequency is owned by the Event Engine budgets (`events_budgets.json` `treasures`): set a target frequency there | Item DB, Event Engine | Rule 13 |
| 7 | ~~RNG stream for the rolls after birth~~ **Closed 2026-11-05:** as built, a player's fruit and Mutation Awakening draw from the session's one seeded RNG, in call order, and its state is saved with the game (Formulas F) | — | — |
| 8 | Single roots (45 % of lives) need 1,657 years for a whole life against 513 for a dual root. With innate variants a single root can now move up a row (Wind, Blood, Void); state single roots' late-game identity after the Open Question 1 bot run | game-designer, Realms calibration | Player Fantasy |
| 9 | The Way (Đạo), system 39, is undesigned. Its GDD decides what the relocated mutations become, how they are gained (not by the root roll), what it reads from the root, and the migration of content that named them (techniques, recipes, items). Keep its scope distinct from craft mastery (đạo nghệ, Character Stats). A plain id search gives false hits when scoping that migration: `huyen` is a technique rank in `items_cong_phap.json`, and `tran` is an unrelated id in the event, action and world data | game-designer, user | Rule 16; Cultivation Techniques re-pointing |
| 10 | ~~Implementation changes: `bien_di` → `variants` + `variant_effects`; the three origin kinds and chance keys; `n_eff` wherever a count is looked up; innate draws in the birth order; the declined mark in the rolled set; removing the relocated mutations and their dead keys (`herb_age_root_pct`, holder-raised ceilings)~~ **Built 2026-11-05** | — | — |
| 11 | ~~The built fruit picks a random element at grant~~ **Closed 2026-11-05:** the build picks at use (`treasure_effects.gd`), and the item holds no element | — | — |
| 12 | UI Requirements not built in the Debug Terminal: `explain` for a variant id (origin, requirement, purity, role lines); each pair source in `explain rate` (it shows one summed line); where parity comes; the Tẩy Tủy Đan preview. AC-LC-51's two provisional bullets wait on the first two | implementation story | AC-LC-51 |
| 13 | Void and Blood are archived (user, 2026-11-09). To apply in code: set `innate_chance` huyet and hu_khong to 0 and reject them in Self-made; update the about 20 acceptance criteria that name them (AC-LC-04 to AC-LC-51) and their tests (scripted births, the 4.34 % innate share, Void picks); recheck Realms' calibration, which assumed about 4.3 % of lives move up a curve row. Decide whether the Meridian Map keeps their variant sectors | game-designer, gameplay-programmer | Code pass |
