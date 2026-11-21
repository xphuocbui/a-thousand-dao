# Alchemy (Luyện Đan)

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: 3 (Power Is Built, Not Given), 4 (Every Season Counts), 2 (Every Number Is Bounded and Visible)
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-21 — F5's breakthrough values and the breakthrough-pill prices marked provisional, blocking implementation until the Formula B re-tune and the Realms re-run (Pillars 2 and 3)

## Summary

Alchemy (luyện đan) turns herbs into pills: the breakthrough pills a realm gate needs, and cultivation, healing, detox, stat and lifespan pills. A recipe asks for herbs by **element value**, so many young herbs or one old one both serve. The brew succeeds on odds the alchemist builds (Đan Đạo mastery, Fire root, comprehension, `alchemy_success`), burns its herbs and a fuel of stones either way, and rewards extra value with quality. It closes the engine chain from root to breakthrough (Pillar 3), spends seasons of growing on one visible gamble (Pillars 4, 2), and its fuel is a small, lasting stone sink.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Spirit Herbs & Fields, Item Database, Character Stats, Realms & Bottlenecks, Trade Goods`

## Overview

Alchemy (luyện đan) turns spirit herbs into pills (đan dược): breakthrough pills that a realm gate needs, cultivation pills, healing, detox, stat and lifespan pills. A brew follows a **recipe**: herbs counted by their age equivalents (Item Database Formula B), a difficulty, and a minimum Đan Đạo level. It succeeds with a chance built from the alchemist's Đan Đạo mastery, Fire root, comprehension and `alchemy_success`. A failed brew burns its herbs. Putting in older herbs than the recipe needs raises the pill's **quality**. NPC workshops brew too, as Trade Goods' craft plan, so pills are also a priced crafted good.

Alchemy is where seasons of herb growing become power. It is the last step of the engine chain (root → herbs → pills → breakthrough → combat), and it is a sink: herbs are spent whether or not the brew succeeds, and laying a cauldron costs fuel.

**Player fantasy:** the alchemist's gamble. Herbs tended for decades go into the cauldron for one attempt at the pill a breakthrough needs. The odds are the alchemist's own making (Pillar 3): a Fire root, a trained hand, older herbs for a better pill. Every term of the chance is shown before the fire is lit (Pillar 2).

## Detailed Design

### Core Rules

1. **Scope.** This GDD owns recipes (ingredients by element and value, difficulty, `min_level`, yield, toxicity, effect, price), brew success, pill quality, fuel, crit, the Đan Đạo mastery and capabilities #10 and #11. It does not own herb values and equivalents (Item Database Formula B), what a pill does to a character (Character Stats for toxicity and stat effects; Realms for breakthrough use), market prices (Regional Economy) or NPC workshops' plans (Trade Goods).
2. **A recipe is a record** in `items_recipes.json`: `id`, ingredients as a list of (`element`, `value`), `difficulty`, `min_level`, `yield`, `xp`, `toxicity`, `effect`, `price`; e.g. Ngưng Nguyên Đan needs Metal ≥ 252 and Fire ≥ 41 *(user decision 2026-11-21: recipes by element value; `production/plans/herb-element-rework.md`)*.
3. **Brewing takes the season**, anywhere. The character picks a recipe; capability #10 allows one more brew in the same season.
4. **Level gate.** A recipe can be attempted at Đan Đạo level `min_level − 1` or above (level 0 can attempt level-1 recipes).
5. **Ingredients by value.** Each ingredient needs herbs of its element whose values (Item Database Formula B, `base_value × E(age / mature_years)`) add up to at least its `value`, so many young herbs or one old herb both serve. A multi-element herb fills one ingredient of any one of its elements at its full value. The default picks the youngest herbs first until the value is met, so an old treasure is never burned by accident; the player may choose others. Herbs are never split, and planted herbs are never used. The brew is refused, with what is missing, if the herbs fall short.
6. **Fuel.** Lighting the cauldron costs `fuel = ceil(fuel_frac × price)` linh thạch (Formulas F2). It is paid when the brew starts and burned whatever the result: a sink in Regional Economy Formula H. The brew is refused if the character cannot pay.
7. **Success.** The chance is `p_brew` (Formulas F1), the designed form shared with Realms Formula D and Character Stats rule 14: a base from difficulty, Đan Đạo level and comprehension, plus 0.25 points per Fire purity, with `alchemy_success` dividing the failure chance, clamped to 5–95 %. *(The built code adds `alchemy_success` linearly; it changes to this form.)*
8. **Failure.** The herbs and the fuel are lost ("the cauldron cracks"). The alchemist gains half the recipe's xp. With capability #11 there is a chance of one strange pill (`mutated_pill`).
9. **Success.** The brew makes `yield + alchemy_yield` pills, plus `crit_extra_yield` on a Khí vận crit (chance `eff(khi_van) × 0.0015`, Character Stats). Quality is the rank of ρ (value put in over value needed, summed over the ingredients) against `quality_grade_thresholds`. Pills of the same recipe and quality stack. The alchemist gains the recipe's xp.
10. **Đan Đạo mastery** (đạo nghệ, levels 0–9). Level n + 1 costs `xp_per_level × (n + 1)`, and each level adds `skill_success_per_level` to the base chance (Character Stats storage; not a sheet modifier, so not curved).
11. **Breakthrough recipes are calibrated.** The four breakthrough pills' value requirements are set with Realms Formula D's pill-supply calibration, so a change to them re-runs that calibration. They are first translated from the calibrated herb recipes (Trúc Cơ Đan: 2 at 40 + 1 at 10; Ngưng Nguyên Đan: 2 Kim Tủy Quả at 42 + 1 at 18; Hóa Anh Đan: 4 at 60 + 1 at 10; Hóa Thần Đan: 4 at 100 + 1 at 80) into element values (Formulas); a Realms re-run for the value form is owed.
12. **Price follows the margin, not the reverse.** A recipe that sells is priced so Trade Goods Formula J's craft margin, fuel included, sits in 1.2–2.0; the lint reads ingredient values directly. Where a recipe's ingredients are fixed (rule 11, or by design), its price moves instead. *(User decision 2026-11-21: this replaces the "raise their inputs and keep their prices" part of the 2026-11-14 decision for Ngưng Nguyên, Tẩy Tủy and Diên Thọ Đan; their built ingredients stand and their prices fall. Trade Goods is amended.)* **The new prices of the breakthrough pill Ngưng Nguyên Đan and of Tẩy Tủy and Diên Thọ Đan are provisional** until the Realms re-run checks that cheaper market pills do not undo Realms' `M_market ≈ 0` assumption (Open Question 2).
13. **NPC workshops** brew through Trade Goods' craft plan and pay fuel the same way, booked as one aggregate burn in Formula H.
14. **Visibility** (Pillar 2). Before lighting the fire, the screen shows the herbs to be used with their ages and values against each ingredient's value, the fuel, the chance with each term on its own line, the quality that ρ will give, and the toxicity; after the brew, the roll and the result.

### States and Transitions

**A brew (one attempt)**

| State | Meaning | Becomes | When |
|---|---|---|---|
| Chosen | A recipe is picked | Ready; Refused | The checks pass (level, herbs by value, fuel); or one fails, with the reason |
| Ready | The herbs and fuel are shown, with the chance and the quality ρ would give | Lit; Chosen | The player confirms; or changes the herb choice |
| Lit | Fuel paid and burned; herbs consumed | Succeeded; Failed | The roll against `p_brew` |
| Succeeded | Pills made: yield, crit, quality; full xp | Done | At once |
| Failed | Herbs and fuel lost; half xp; with #11, a chance of a strange pill | Done | At once |
| Done | The season passes (with #10, one more brew may follow in the same season) | — | — |

**Đan Đạo mastery:** level 0 → 9 by xp; it never falls. **Pills** are Item Database items (held, stacked by recipe and quality, consumed on use).

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Spirit Herbs & Fields #14 | in | Harvested herbs with their ages | Spirit Herbs |
| Item Database #13 | in / out | In: herb values (Formula B), element lists, pill templates. Out: pills with quality, stacks; `pill_value = price × (1 + 0.5 × quality)` | Item Database (items, values); this GDD (recipes) |
| Character Stats #7 | in / out | In: Fire purity, comprehension, Khí vận (crit), `alchemy_success` (failure divider), `alchemy_yield`, the Đan Đạo level storage. Out: a pill's toxicity and stat effects when it is used | Character Stats (stats, toxicity); this GDD (the brew) |
| Realms & Bottlenecks #8 | out / in | Out: breakthrough pills by tag and quality; `p_brew0`. In: the calibration that fixes the four breakthrough recipes (Formula D) | Realms (the gate and calibration); this GDD (the recipes) |
| Trade Goods #45 | out / in | Out: recipes as a crafted class's inputs; the margin lint's inputs. In: NPC workshops' craft plan | Trade Goods (plan, lint); this GDD (recipes, fuel) |
| Regional Economy #43 | out | Fuel burned (player per brew; NPC workshops as one aggregate) in Formula H; pill prices | Regional Economy |
| Time & Turn #4 | in | The season a brew takes | Time & Turn |
| Đạo Đồ #10 | in | Capabilities #10 (second brew a season) and #11 (strange pill on failure) | Đạo Đồ |
| Sects #26 | out | Pills as kind stipends (Trade Goods' kind share) | Sects |
| Event Engine #23 | out | Gifted pills enter like brewed ones | Event Engine |
| Game UI #37 | out | The brew screen data | This GDD owns the data; UI owns layout |

## Formulas

Starting values are built ones or **guesses** for the balance harness. Herb values are Item Database Formula B's.

### F1. Brew success

The brew_success formula is defined as:

`p0 = (100 − difficulty + skill_success_per_level × L + 0.1 × comprehension) / 100`; `p_brew = clamp(1 − (1 − p0 − 0.0025 × Fire) / (1 + max(0, alchemy_success) / 100), 0.05, 0.95)` (the form shared with Realms Formula D and Character Stats rule 14)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| difficulty | int | 40–75 | recipe | The recipe's difficulty |
| L, skill_success_per_level | int, float | 0–9; 6 | Character Stats storage; `items_recipes.json` | Đan Đạo level; points per level |
| comprehension | float | 0+ | Character Stats (effective) | Ngộ tính, 0.1 points each |
| Fire | float | 0–100+ | Spiritual Roots | 0.25 points per purity |
| alchemy_success | float | any; floored at 0 | Character Stats | Divides the failure chance |

**Output Range:** 5–95 %.
**Example:** Ngưng Nguyên Đan (difficulty 70), L 5, comprehension 50, Fire 60, `alchemy_success` 20: p0 0.65, failure 1 − 0.65 − 0.15 = 0.20, ÷ 1.2 = 0.167, so **p_brew 0.83**.

### F2. Fuel

The brew_fuel formula is defined as:

`fuel = ceil(fuel_frac × price)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| fuel_frac | float | 0.05 | data file *(guess)* | Share of the recipe's price burned per brew |
| price | int | 12–40,000 | recipe | The recipe's price |

**Output Range:** 1 stone (Tụ Khí Đan) to 2,000 (Hóa Thần Đan).
**Example:** the repriced Ngưng Nguyên Đan (1,140) burns 57 a brew.

### F3. Quality and value

The pill_quality formula is defined as:

`ρ = Σ value put in / Σ value needed` over the ingredients; quality = the highest rank q with ρ ≥ `quality_grade_thresholds[q]`; `pill_value = price × (1 + 0.5 × quality)` (Item Database)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| quality_grade_thresholds | float list | 0 / 1.5 / 2.5 / 4 | `items_recipes.json` | ρ at which ranks 0–3 begin |

**Output Range:** quality 0–3.
**Example:** Metal 504 put in for a 252 need, with Fire exact (41): ρ = (504 + 41) / 293 = 1.86, quality 1.

### F4. Price from the margin (a recipe whose ingredients are fixed, rule 12)

The recipe_price formula is defined as:

`price = m* × bm_raw × V_in / (sr_fin × yield × ps_mean − m* × fuel_frac)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| m* | float | 1.8 | data file *(guess; the middle of Trade Goods' 1.2–2.0)* | Target margin |
| bm_raw, sr_fin | float | 1.10; 0.6 | Regional Economy Formula G | Raw buy factor; finished sell ratio |
| ps_mean | float | 1 | Trade Goods Formula J's convention | Mean success assumed by the lint |
| V_in | float | ≥ 1 | Item Database Formula B | Σ ingredient values |
| yield | int | 1–2 | recipe | Pills per brew |

**Output Range:** a price that sets the margin at m*.

| Recipe | Inputs by element value (V_in) | Margin at today's price | New price | Margin |
|---|---|---|---|---|
| Ngưng Nguyên Đan | Metal 252 + Fire 41 = 293 | 3.82 (3,000) | **1,140** | 1.80 |
| Tẩy Tủy Đan | Fire 50 + Water 62 = 112 | 6.06 (2,500) | **430** | 1.80 |
| Diên Thọ Đan | Wood 400 + Metal 150 = 550 | 3.51 (5,000) | **2,140** | 1.80 |

The other nine recipes sit at 0.86–3.16 with fuel; those above 2.5 earn under `margin_warn_profit` (600) a brew, so the lint does not warn. Trúc Cơ Đan's 0.86 is allowed: it is for one's own use.

### F5. Breakthrough recipes as element values (rule 11)

The breakthrough_values formula is defined as: `V_e = Σ qty × base_value × E(min_age / mature_years)` over the calibrated herb recipe's ingredients of element e (Item Database Formula B).

| Pill | Element values |
|---|---|
| Trúc Cơ Đan (FE) | Earth ≥ 224, Fire ≥ 11 |
| Ngưng Nguyên Đan (CF) | Metal ≥ 252, Fire ≥ 41 |
| Hóa Anh Đan (NS) | Water ≥ 3,600, Fire ≥ 11 |
| Hóa Thần Đan (DT) | Fire ≥ 12,000, Wood ≥ 320 |

**Provisional, blocking implementation (CD-GDD-ALIGN 2026-11-21).** **These values are fair only once Item Database re-tunes Formula B per basic herb** (`production/plans/herb-element-rework.md`). With today's curve, Water 3,600 from the basic Water herb (Thanh Tâm Liên, mature at 3) is reached by one lotus about 21 years old, where the old recipe needed Anh Tâm Liên at 60. The Realms Formula D re-run follows that re-tune.

### F6. Mastery

The dan_dao_xp formula is defined as: a success gives the recipe's `xp`, a failure `xp × fail_xp_fraction`; level n + 1 costs `xp_per_level × (n + 1)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| xp | int | per recipe | recipe | Xp of a success |
| fail_xp_fraction, xp_per_level, max_level | float, float, int | 0.5; 100; 9 | `items_recipes.json` (as built) | Failure share; level cost scale; top level |

**Output Range:** level 0–9 (4,500 xp to level 9).

### Boundary and loop checks

- **Difficulty 100 at level 0:** p0 0, so `p_brew` clamps at 0.05. **Negative `alchemy_success`:** floored at 0, so it never raises the failure chance.
- **ρ below 1:** cannot happen; the brew is refused if the value falls short.
- **Fuel for a price-1 recipe:** at least 1, by the ceil.
- **Positive loop:** brews → xp → higher odds → more brews. Bounded by level 9 and the 95 % clamp.
- **Sink size:** fuel is modest (2,000 for a Hóa Thần brew; a life makes a few). Crafting fuel is a real but small sink; most of its volume comes through NPC workshops.

## Edge Cases

**Before the brew**

- **If the alchemist's level is below `min_level − 1`**: refused, with the level needed, and nothing is spent.
- **If the herbs of an element fall short of the value**: refused, with each missing value ("Metal 252 needed, 180 held"). Nothing is spent.
- **If the fuel cannot be paid**: refused, nothing spent.
- **If a multi-element herb could fill two ingredients**: it fills one, chosen by the player; the default puts it where the shortfall is larger.
- **If only an old treasure herb can meet a value**: the default uses it only when no younger set suffices, and the screen warns which herb is about to be spent.
- **If the player picks more value than needed**: allowed; the excess raises ρ and so quality (F3), and none of it is refunded.

**The brew**

- **If the season ends mid-way**: it cannot; a brew is the whole season (or the second slot with capability #10).
- **If `p_brew` would pass 95 % or fall below 5 %**: it is clamped.
- **If the brew fails with capability #11**: the strange pill is rolled after the herbs and fuel are lost; it never refunds them.
- **If Khí vận crits on a recipe with yield 1**: the brew makes 2.
- **If two brews run in one season** (#10): each pays its own fuel and herbs and rolls on its own.

**Values and prices**

- **If a herb's value is fractional**: values are summed as stored and compared at the end; the screen rounds for display only.
- **If a recipe's price falls into a lower crafted-goods band** (Ngưng Nguyên and Tẩy Tủy, Trade Goods `pill_band_edges`): the pill is priced and stocked in its new band; Trade Goods is amended.
- **If Item Database's re-tune changes a herb's value curve**: every recipe's value need is re-checked against the Realms calibration before release (F5).

**Pills and NPCs**

- **If pills of the same recipe and quality already exist**: they stack.
- **If an NPC workshop brews**: its fuel is part of Trade Goods' workshop cost and booked as one aggregate burn, never per brew.
- **If a pill is a breakthrough pill**: Realms decides when it can be used; Alchemy only makes it.

## Dependencies

| System | Type | Interface | State | Lists Alchemy? |
|---|---|---|---|---|
| Spirit Herbs & Fields (#14) | Hard | Harvested herbs and their ages | Designed, in review | Yes |
| Item Database (#13) | Hard | Herb values (Formula B), element lists, pill items, `pill_value` | In review | Yes; **catalogue and Formula B re-tune owed** (`production/plans/herb-element-rework.md`) |
| Character Stats (#7) | Hard | Fire purity, comprehension, Khí vận, `alchemy_success`, `alchemy_yield`, Đan Đạo storage, pill toxicity | In review | Yes |
| Realms & Bottlenecks (#8) | Hard (both ways) | Breakthrough pills; `p_brew0`; the calibration behind the four breakthrough recipes | In review | Yes; **Formula D re-run for the value form owed** |
| Trade Goods (#45) | Hard | Crafted class, craft plan, margin lint, `pill_band_edges` | Approved | Yes; **amendment owed** (prices, value-form lint, NPC fuel) |
| Regional Economy (#43) | Soft (out) | Fuel burned in Formula H; pill prices | Approved | Yes; **fuel term owed** (`burn_craft`) |
| Time & Turn (#4) | Soft | The season a brew takes | Built, no GDD | n/a |
| Đạo Đồ (#10) | Soft | Capabilities #10, #11 | In review | Yes |
| Event Engine (#23) | Soft | Gifted pills | Designed | Yes |
| Sects (#26) | Soft | Pills as kind stipends | Approved | **No: note owed** |
| Game UI (#37) | Soft | The brew screen | Not started | n/a |

**Circularity:** none added. Alchemy reads herbs and stats and writes pills; Realms' calibration constrains the recipes but is a design-time check, not a runtime loop.

**Owed:** back-links in Trade Goods, Regional Economy, Sects and Realms, plus the herb rework's Item Database and Trade Goods catalogue changes. None has been edited.

## Visual/Audio Requirements

Art bible §1–4 are still placeholders; this section draws on §7 and the pillars.

- **Terminal today.** The brew screen prints the recipe, a per-element value bar as text (`Metal 252 / 252 ✓`), the herbs to be spent with age and value, the fuel, `p_brew` with one line per term, the quality ρ gives, and the toxicity; after the roll, the result line.
- **Game UI intent.** An ink-wash cauldron over a fire whose colour follows the dominant element; herbs drop in as medallions (art bible §7.9 frames, §7.5 hues). Success: smoke clears to a pill in its quality's ring; failure: the cauldron cracks.
- **Events needing a visual and sound later:** lighting the fire, success with quality, a Khí vận crit, failure, the strange pill (#11), a level gained.

## Game Feel

The moment that matters: **the roll on a breakthrough pill**, with every term visible beforehand, so the result feels earned or bravely risked.

- **Before:** the screen makes the choice plain: which herbs go in, what the old treasure would add in quality, what is burned.
- **After:** the result names the deciding term ("Fire root +15 pp") and, on failure, what was lost.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Recipe list | Known recipes with level gate, element values needed, held value per element, fuel, `p_brew` | Pick a recipe |
| Brew screen | Herbs chosen per ingredient (age, value), the old-treasure warning, multi-element herbs' assignment, fuel, `p_brew` lines, quality preview, toxicity | Change the herb choice; assign a multi-element herb; light the fire |
| Result | Roll vs chance, pills made with quality and crit, xp, a level gained, what was lost on failure | Continue |
| Character sheet | Đan Đạo level and xp | Open the breakdown |

All of these work in the debug terminal first, with numbered menus.

> **📌 UX Flag — Alchemy:** this system has UI requirements. In Pre-Production, run `/ux-design` for the brew screen and the recipe list before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | References | What |
|---|---|---|
| Rules 5, 9; F3, F5 | Item Database Formula B; rule 15 | Herb value, pill value, the catalogue (rework owed) |
| Rule 7; F1 | Realms Formula D; Character Stats rule 14 | `p_brew`'s form, the failure divider |
| Rules 11, 12; F4, F5 | Realms Formula D; Trade Goods Formula J; `pill_band_edges` | Calibrated recipes, the margin lint, price bands |
| Rules 6, 13; F2 | Regional Economy Formula H | Fuel as a sink |
| Rule 9 | Character Stats (Khí vận crit) | Crit chance |
| Rules 3, 8 | Đạo Đồ capabilities #10, #11 | Second brew, strange pill |
| Rule 1 | Spirit Herbs & Fields | Herb supply |
| Overall | `production/plans/herb-element-rework.md` | The element-value recipe decision |

## Acceptance Criteria

**Core rules**

- **AC-AL-01** [Logic] Rule 4. **GIVEN** Đan Đạo level 4 and a recipe with `min_level` 6, **THEN** refused with "level 5 needed" and nothing spent; **GIVEN** level 5, **THEN** allowed.
- **AC-AL-02** [Logic] Rule 5. **GIVEN** Ngưng Nguyên Đan (Metal ≥ 252, Fire ≥ 41) and Metal herbs worth 180, **THEN** refused with "Metal 252 needed, 180 held"; **GIVEN** five Metal herbs worth 60 each, **THEN** the default takes them youngest first until 252 is met, splitting none.
- **AC-AL-03** [Logic] Rule 5. **GIVEN** a Fire-Earth herb worth 50 and a recipe needing Fire 41 and Earth 30, **THEN** the herb fills only one of them at 50; **GIVEN** planted herbs, **THEN** they are never used.
- **AC-AL-04** [Logic] Rule 6, F2. **GIVEN** a price of 1,140, **THEN** 57 stones are burned when the brew starts, on success or failure; **GIVEN** Tụ Khí Đan (12), **THEN** 1; **GIVEN** 56 stones held, **THEN** refused, nothing spent.
- **AC-AL-05** [Logic] Rule 7, F1. **GIVEN** difficulty 70, level 5, comprehension 50, Fire 60, `alchemy_success` 20, **THEN** `p_brew` is 0.833 (±0.005). **GIVEN** difficulty 100 at level 0, **THEN** 0.05; **GIVEN** a chance above 0.95, **THEN** 0.95; **GIVEN** `alchemy_success` −30, **THEN** it is treated as 0.
- **AC-AL-06** [Logic] Rule 8. **GIVEN** a failed brew, **THEN** the herbs and fuel are gone and half the recipe's xp is gained; **GIVEN** capability #11, **THEN** a strange pill may appear and nothing is refunded.
- **AC-AL-07** [Logic] Rule 9. **GIVEN** a success with yield 1, `alchemy_yield` 0 and a Khí vận crit, **THEN** 2 pills; **GIVEN** an existing stack of that recipe and quality, **THEN** they merge.
- **AC-AL-08** [Logic] Rule 9, F3. **GIVEN** Metal 504 and Fire 41 put in against needs of 252 and 41, **THEN** ρ is 1.86 and quality 1; **GIVEN** ρ 4.0, **THEN** quality 3; **GIVEN** quality 2 on a 1,140 pill, **THEN** `pill_value` 2,280.
- **AC-AL-09** [Logic] Rule 3. **GIVEN** a brew, **THEN** the season passes; **GIVEN** capability #10, **THEN** a second brew may follow in the same season, each with its own fuel, herbs and roll.
- **AC-AL-10** [Logic] Rule 10, F6. **GIVEN** level 0, **THEN** level 1 costs 100 xp and level 2 costs 200; **GIVEN** 4,500 xp in all, **THEN** level 9, and no level beyond.
- **AC-AL-11** [Logic] Rule 14. **GIVEN** the brew screen, **THEN** it shows the herbs to be spent with ages and values against each need, the fuel, `p_brew` with one line per term, the quality ρ gives, and the toxicity.

**Formulas and data**

- **AC-AL-12** [Config] F4. **GIVEN** the shipped recipes, **THEN** Ngưng Nguyên Đan is 1,140, Tẩy Tủy Đan 430 and Diên Thọ Đan 2,140, each with margin 1.80 (±0.02) including fuel, and no recipe above 2.5 earns `margin_warn_profit` or more a brew.
- **AC-AL-13** [Config] F5. **GIVEN** the shipped breakthrough recipes, **THEN** their element values are Earth 224 + Fire 11, Metal 252 + Fire 41, Water 3,600 + Fire 11, and Fire 12,000 + Wood 320.

**Cross-system**

- **AC-AL-14** [Integration] Realms Formula D. **GIVEN** a brew of a breakthrough pill, **THEN** its success chance equals Realms' `p_brew` for the same inputs.
- **AC-AL-15** [Integration] Regional Economy Formula H. **GIVEN** a season with player brews and NPC workshop brews, **THEN** the player's fuel and the workshops' aggregate fuel are separate sink entries, and `ΔM = F_mine − sinks` holds.
- **AC-AL-16** [Integration] Character Stats. **GIVEN** a pill with toxicity 10 taken, **THEN** toxicity rises by Character Stats' rule (10 × the resistance factor).

**Screens**

- **AC-AL-17** [UI] **GIVEN** the brew screen for a recipe with a multi-element herb and an old treasure herb available, **THEN** a screenshot in `production/qa/evidence/` shows the value bars per element, the treasure warning, the fuel and the chance lines, with no meaning carried by colour alone.

**Gaps noted (not criteria):** the breakthrough values' fairness waits on the Formula B re-tune and the Realms re-run; recipe content (more recipes, multi-element herbs) waits on the catalogue rework.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Item Database re-tunes Formula B per basic herb (or in years) so no short-lived herb explodes in value; then the breakthrough values (F5) are re-checked | Item Database; user | Herb rework |
| 2 | Realms Formula D re-run for value-form recipes; does the player edge (0.70/0.70/0.30/0.20) hold? Also re-check `M_market ≈ 0` now that Ngưng Nguyên Đan costs 1,140 instead of 3,000 | Realms; Balance Harness | After 1 |
| 3 | Back-links owed: Trade Goods (prices, value-form lint, NPC fuel, band moves), Regional Economy (`burn_craft`), Sects (kind pills), Realms | user | After this GDD |
| 4 | The catalogue: which five current herbs become multi-element herbs, which are retired; more recipes for multi-element herbs | user | Herb rework |
| 5 | `fuel_frac` (0.05) and the sink size: is crafting fuel worth keeping as a sink, or only as a cost? | Balance Harness | Harness pass |
| 6 | Code lags the design: `alchemy_success` is added linearly in `alchemy.gd`; recipes are named-herb in `items_recipes.json` | implementer | Before implementation |
