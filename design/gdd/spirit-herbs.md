# Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền)

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: 4 (Every Season Counts), 3 (Power Is Built, Not Given), 2 (Every Number Is Bounded and Visible)
> **Creative Director Review (CD-GDD-ALIGN)**: APPROVED 2026-11-21 (observation: held-old-herb value is uncapped by Item Database decision, tracked in Open Question 6)

## Summary

Spirit herbs (linh thảo) are the living input of the pill economy, and spirit fields (linh điền) are where a cultivator grows them. A planted herb ages each season at a rate set by the Wood root, growth stats, a Linh Điền mastery and how well the land suits it; it stops ageing when harvested, so the choices are what to plant, where, and when to harvest. A free home garden of plots is extended by a field work in the cave abode's slots. The system turns seasons into a patient supply of ingredients for breakthroughs (Pillars 4, 3), bounded and visible (Pillar 2).

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Item Database, Character Stats, Travel & Map, Trade Goods, Cave Abode, Realms & Bottlenecks`

## Overview

Spirit herbs (linh thảo) are the living input of the cultivation economy. Each herb has an element, a climate band, a `mature_years` and a value that grows with age (Item Database Formula B); pills, and so breakthroughs, are made from them (Alchemy, #15). Spirit fields (linh điền) are where a cultivator grows them: plots at the home where a planted herb ages every season, at a rate set by their Wood root, their growth stats and how well the land suits that herb (Travel & Map Formula G). A herb stops ageing the moment it is harvested (Trade Goods rule 10), so the choices are when to plant, what to plant, and when to harvest.

Beside the field are the other sources of herbs: buying them at a market, gathering wild herb ground (aged by Trade Goods Formula K) and transplanting a found plant.

**Player fantasy:** the patient gardener of a long life. A cultivator plants a slow, precious herb in the first season of a plan and tends it for decades, turning scarce years into the ingredient a breakthrough needs. The reward is waiting, and it is earned in seasons, not bought (Pillars 4, 3). Every growth rate and plot count is on the screen with its source (Pillar 2).

## Detailed Design

### Core Rules

Numbers are the built ones (3 base plots, cap 12, 0.04 and 0.8 per purity, the seed rarity ladder) or guesses for the balance harness.

1. **Scope.** This GDD owns plots, planting, tending, harvesting, growth, seeds and the Linh Điền mastery. It does **not** own the herb catalogue and values (Item Database, Trade Goods), `mature_years` and the equivalents curve (Item Database Formula B), fit (Travel & Map Formula G), wild gathering ages (Trade Goods Formula K) or what a herb is used for (Alchemy #15).
2. **A herb is an item** with `template`, `age` (years), and, while growing, a `plot` index (Item Database rule 15). It is **Planted** when `plot ≥ 0`. Only a Planted herb ages, and a harvested herb's age is fixed.
3. **Plots at the home.** The home has `plots = clamp(base_plots + floor(Thổ purity × plots_per_purity) + floor(field_plots stat) + field-work plots, 1, max_plots)`, with `max_plots` the total cap (12, as built). The first three terms are the **home garden** and take no abode slot. The last is rule 4.
4. **The field work.** The Linh Điền field is a **home work** (Cave Abode rule 4) that takes one slot, has levels up to the abode's level ceiling and its own `max`, and adds `plots_per_field_level` plots per level. Its build cost and upkeep follow Cave Abode's work rules. When it goes dormant or the home is left, its plots stop counting (rule 11).
5. **Planting.** At the home, with a free plot, a character plants a herb: from a bought **seed** (the herb's `seed_price`, paid to the market commons; only herbs up to the realm's `seed_rarity_by_realm` are for sale), or by **transplanting** an owned herb, which keeps its age. A herb can be planted only where its fit is at least `plant_floor` (Travel & Map Formula G), and the screen says why a herb cannot grow here. Planting a seed creates a herb at age 0.
6. **Growth.** Each season every Planted herb gains `(seasons / seasons_per_year) × growth_rate × fit_growth` years (Formulas F1). `growth_rate` is the Wood root and growth-stat factor; `fit_growth` is Travel & Map's `g_max × fit` for that herb at the home. A herb already planted keeps growing below the plant floor.
7. **Tending is free of time.** Growth needs no action; the cost is the plot, the seed and the wait. A herb never withers or dies in a plot (Edge Cases). The decisions are what to plant, and when to harvest.
8. **Harvest.** At the home, any season, a character harvests a plot. The herb leaves the plot at its current age, which then freezes (Trade Goods rule 10), is tagged with its home market (`origin_market`), and joins the inventory. The plot is free at once. There are no seeds back: replanting costs a new seed.
9. **Linh Điền mastery** (đạo nghệ, levels 0–9). Mastery xp accrues each season from the years a herb grows in a plot (`xp = xp_per_herb_year × Δage`, Formulas F4), so a herb found or bought old gives nothing for its past years, and a Frozen herb gives nothing. Level n + 1 costs `xp_per_level × (n + 1)` (Character Stats). Each level adds `mastery_growth_per_level` to `herb_growth_pct` on the stat sheet, through Character Stats' bonus curve for that key. Mastery does not change plots or seed gates.
10. **Capabilities as built.** Capability #12 ages unplanted herbs in the inventory at `rate` as well; capability #14 lets the character tend and harvest away from the home. Both keep their current meaning.
11. **Moving home and dormant fields.** When a character moves home, every herb in the old field is **harvested into the inventory at its current age** (no loss, but no more ageing), and plots at the new home start empty. When the field work goes dormant, herbs in its plots stop ageing and can be harvested or transplanted but not replaced.
12. **NPCs have no plots.** NPC workshops' aged herbs are Trade Goods' abstraction (their `craft_in` and ages); no per-NPC field is simulated here.
13. **Other sources** (buying at a market, wild gathering, found plants) are outside this GDD; their herbs enter the same inventory and can be planted by rule 5.
14. **Visibility** (Pillar 2). The field screen lists each plot with its herb, age, equivalents `E` (Item Database Formula B), `mature_years`, fit and its word, the growth rate with each source on its own line (Wood root, `herb_growth_pct` with mastery, fit), and the years left to maturity.

### States and Transitions

**A plot (per plot index at the home)**

| State | Meaning | Becomes | When |
|---|---|---|---|
| Locked | The plot index is beyond `plots` (cap, or its field work dormant) | Free | `plots` rises (a field level, Thổ, the stat) |
| Free | Usable, empty | Growing | A seed is planted, or a herb is transplanted in |
| Growing | A herb with age below `mature_years` | Mature; Free | The herb reaches `mature_years`; it is harvested or the home is left |
| Mature | Age at or above `mature_years`; still ageing | Free | Harvested or the home is left |
| Frozen | The plot's field work is dormant: the herb does not age | Growing/Mature; Free | The work is active again; the herb is harvested or transplanted |

**The herb in a plot** has a descriptive band for the screen only (no state change): **young** (age < `mature_years`), **mature** (value = `base_value`), **plateau** (up to the knee, `x_k` × `mature_years`) and **old** (past the knee, where Formula B compounds).

**Linh Điền mastery:** level 0 → 9 by harvest xp (Character Stats storage); it never falls.

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Item Database #13 | in / out | In: herb templates (`mature_years`, `base_value`, `seed_price`, `rarity`), Formula B's `E`, the Planted state and `plot` field. Out: planted herbs aged on the tick, harvested herbs with a fixed age and `origin_market` | Item Database owns the item; this GDD owns when a planted herb ages |
| Trade Goods #45 | in | The herb catalogue (11 goods), a harvested herb's fixed age (rule 10), wild gathering ages (Formula K) | Trade Goods |
| Travel & Map #25 | in | Herb fit and `g_max × fit` for the home place, the `plant_floor`, the climate and density factors, wild herb grounds | Travel & Map (Formula G); this GDD (what growth does with it) |
| Character Stats #7 | in / out | In: Wood and Earth purity, `herb_growth_pct`, `field_plots`, the mastery level storage and the bonus curve. Out: Linh Điền mastery's `herb_growth_pct` modifier | Character Stats (stacking curve); this GDD (mastery's per-level value) |
| Modifier System #40 | in | `herb_growth_pct` and `field_plots` Stat List rows | Modifier System |
| Time & Turn #4 | in | The season tick and `seasons_per_year` | Time & Turn |
| Cave Abode #47 | in | The home, the field work (slot, level, plots per level, dormant state) | Cave Abode (slots, cost, upkeep); this GDD (plots, growth) |
| Alchemy #15 | out | Herbs of any age, counted by equivalents in recipes | Alchemy |
| Regional Economy #43 / Market | out | Seed purchases paid to the commons pool; the harvested herb's market tag | Regional Economy |
| Formations #17 | in | Thanh Mộc array's `herb_growth_pct` (applies always, at the field) | Formations (its array); this GDD (reads the stat) |
| Đạo Đồ | in | Capabilities #12 and #14 (unplanted herbs age; tend away from home) | Đạo Đồ |
| Realms #8 | out | Pill supply: herb ages and plots for the breakthrough gifts | Realms (Formulas D) |
| World Database | in / out | Herb items and their plot and age | World Database |
| Game UI #37 | out | The field screen data | This GDD owns the data; UI owns layout |

## Formulas

Reuses Realms Formula D's `h` and `n_plots` and Character Stats Formula I's stacking curve, so each number has one owner. Starting values are built ones or **guesses** for the balance harness.

### F1. Growth of a planted herb

The herb_growth formula is defined as:

`Δage per season = (1 / seasons_per_year) × h × fit_growth`, with `h = (1 + 0.008 × Wood purity) × max(0, 1 + hgp / 100)` and `hgp = 10 × ln(1 + Σ⁺ / 10) + Σ⁻` over the `herb_growth_pct` modifiers (Character Stats Formula I). Seasons until a target age: `(target − age) / (h × fit_growth) × seasons_per_year`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| seasons_per_year | int | 4 | `cultivation_rules` | Seasons in a year |
| Wood purity | float | 0–100 | Spiritual Roots | The Wood root's purity |
| 0.008 | float | 0.008 | `element_effects.herb_growth_pct_per_purity` (0.8 %) | Growth per Wood purity point, as built |
| Σ⁺, Σ⁻ | float | ≥ 0, ≤ 0 | Character Stats | Positive and negative `herb_growth_pct` modifiers (mastery, Thanh Mộc, edges, tree) |
| fit_growth | float | 0.24–1.2 (g_max × fit); 1 where the ground has no qi | Travel & Map Formula G | Growth by fit |

**Output Range:** `h` from 1 (no Wood, no modifiers) to about 2.3 (Wood 100, Σ⁺ about 150); with fit_growth 1.2 up to about 2.8 herb-years a year.
**Example:** Wood 60, Σ⁺ 20, fit 0.8 (growth 0.96): `hgp = 10 ln 3 = 11.0`, `h = 1.48 × 1.11 = 1.64`, 0.39 years a season; Hoàng Tinh Sâm (mature 10) takes about 25 seasons.

### F2. Plots

The plot_count formula is defined as:

`plots = clamp(base_plots + floor(Thổ purity × 0.04) + floor(field_plots stat) + floor(field_level × plots_per_field_level), 1, max_plots)`

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| base_plots, max_plots | int | 3, 12 | `session_actions.json` (as built) | Base and total cap |
| field_plots stat | float | 0+ | Modifier System (tree, edges) | Plots from the build |
| plots_per_field_level | float | 1 *(guess)* | data file | Plots per level of the Linh Điền field work (active only) |
| field_level | int | 0 to the abode's ceiling (max 5) | Cave Abode | The field work's level, 0 if dormant |

**Output Range:** 1–12.
**Example:** Thổ 50, stat 1, field level 3: 3 + 2 + 1 + 3 = **9**.
**Back-link:** Realms Formula D's `n_plots` reads only the first three terms, with no cap; it needs the field-work term and the 12 cap.

### F3. Value a plot can earn (an upper bound for the economy check, not a mechanic)

The plot_value formula is defined as:

`net_value_per_plot_year (harvest at maturity) = (base_value − seed_price) × h × fit_growth / mature_years`; a herb left in its plot past the knee is worth Formula B's `base_value × E(age / mature_years)` instead, a value realised only if a buyer holds that much.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| base_value, seed_price, mature_years | int | per herb (2–3,000; 2–1,200; 1–100) | `items_herbs.json` | The herb's value, seed cost and maturity |
| h, fit_growth | float | F1 | calculated | The growth factors |

**Output Range:** 0 (Ngưng Khí Thảo: value equals seed price) to about 50 stones a plot-year (Hóa Thần Quả). **Example:** Hóa Thần Quả (3,000, seed 1,200, mature 100) at 2.8 herb-years a year: 1,800 × 2.8 / 100 = **50**; twelve plots earn about 600 a year, less than one season of a Hóa Thần grade-5 abode's upkeep (3,000).
A sale is a purchase paid from a market holder's purse (Regional Economy Formula H), so the field mints no stones; the held-old-herb value is Item Database's (no ceiling, user decision 2026-11-20).

### F4. Linh Điền mastery

The mastery_xp formula is defined as:

`xp per season = xp_per_herb_year × Δage` for each Planted, growing herb (a herb harvested at age 0 has earned 0; Frozen herbs earn nothing); level n + 1 costs `xp_per_level × (n + 1)`; level L adds `mastery_growth_per_level × L` to `herb_growth_pct` (raw, through F1's curve).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| xp_per_herb_year | float | 2 *(guess)* | data file | Mastery xp per year a herb grows in a plot |
| xp_per_level | float | 100 *(guess, as the other crafts)* | data file | Level cost scale |
| mastery_growth_per_level | float | 4 *(guess)* | data file | Raw `herb_growth_pct` per level |

**Output Range:** level 0–9; at level 9 +36 raw, which the curve turns into `hgp` +15.3 (×1.153).
**Example:** reaching level 9 costs 100 × (1 + … + 9) = 4,500 xp, about 2,250 herb-years of growth, roughly 40–75 years of a full field.

### Boundary and loop checks

- **No Wood, no modifiers:** `h = 1`. **Negative `hgp`:** `max(0, …)` floors the rate at 0, so a herb stops but never un-ages.
- **Fit at the planting floor (0.2):** growth ×0.24; a herb already planted whose ground falls below it keeps growing at `g_max × fit`, and at fit 0 it stops.
- **Plots at 0 and above the cap:** clamped to 1–12.
- **Positive loop:** mastery → faster growth → more xp. Bounded by the log curve (Σ⁺ of 150 gives only +27.7) and by 9 levels.
- **Dominant purchase:** none. Seed price rises with rarity faster than value per year at low rarity, so the best earner (Hóa Thần Quả) needs realm 3+ seeds.
- **Faucet:** none from the field itself (F3).

## Edge Cases

**Planting and plots**

- **If there is no free plot**: planting or transplanting is refused with the plot count, and nothing is spent.
- **If a herb's seed is rarer than `seed_rarity_by_realm`**: no seed is for sale; the screen says to find a living plant and transplant it.
- **If the home's fit for a herb is below `plant_floor` (0.2)**: planting is refused with each factor's line (element, temperature, rainfall, density). Exactly 0.2 is plantable.
- **If the character is away from home**: planting, transplanting and harvesting are refused unless they hold capability #14. Growth needs no presence.
- **If the character cannot pay the seed price**: refused, nothing paid.
- **If the home's ground has no land qi**: `fit_growth` is ×1 (as built).

**Growth**

- **If the ground's fit changes after planting** (a layer-3 secret lost, an element push removed): growth follows the new fit from the next season, and the herb keeps its age. A planted herb below the floor keeps growing at `g_max × fit`; at fit 0 it stops, and is never lost.
- **If the Wood root or `herb_growth_pct` changes**: the rate changes at once.
- **If `hgp` is negative**: the rate is floored at 0; a herb never loses age.
- **If a herb passes the knee**: it keeps ageing with no maximum age; its value compounds under Item Database Formula B.
- **If the character is not at the home for many seasons**: planted herbs still age every season.

**Harvest, move and loss**

- **If an empty or Locked plot is harvested**: refused, with the reason.
- **If a herb is harvested at age 0**: allowed; it is worth little and has earned 0 xp.
- **If the owner moves home**: every herb in the old field is harvested at once (no travel needed) into the inventory at its current age, and the old field is left empty; this happens before the new home's plots open.
- **If the field work goes dormant or the plots fall** (Thổ, stat or field level lowered): the herbs in plots beyond the new count become **Frozen**, keep their age and are never destroyed; they can be harvested or transplanted, and the plots cannot be refilled.
- **If the owner dies**: planted herbs pass with the estate under Item Database and Living World Tick's rules as ordinary items; their `plot` is cleared and their age fixed. This GDD adds nothing.
- **If plots would exceed 12**: the total is clamped and the field screen shows the clamp as its own line (the extra field levels buy nothing).

**Mastery**

- **If a herb is Frozen**: it does not age, so it earns no xp. A herb transplanted in at any age earns xp only for the years it then grows, so buying or finding an old herb gives no free mastery.
- **If mastery's `Σ⁺` is large**: the log curve limits its effect (F1); there is no cap to hit.

**Interactions**

- **If capability #12 is held**: inventory herbs also age at its `rate`. This conflicts with Trade Goods rule 10 and Item Database rule 15 (Open Questions).
- **If Alchemy counts herbs by equivalents**: a young herb counts as `E` mature herbs (Item Database Formula B); this GDD does not change that.

## Dependencies

| System | Type | Interface | State | Lists Spirit Herbs? |
|---|---|---|---|---|
| Item Database (#13) | Hard | Herb templates, Formula B's `E`, the Planted state and `plot` field, ageing only while Planted | In review | Yes (rules 15, Dependencies) |
| Character Stats (#7) | Hard | Wood and Earth purity, `herb_growth_pct`, `field_plots`, mastery storage, the stacking curve | In review | Yes (soft sources row 14) |
| Modifier System (#40) | Hard | `herb_growth_pct` and `field_plots` Stat List rows | Approved | Yes |
| Travel & Map (#25) | Hard | Herb fit, `g_max × fit`, `plant_floor`, wild herb grounds | Designed | Yes |
| Realms & Bottlenecks (#8) | Hard (out) | Pill supply reads plots and the growth rate (Formula D) | In review | Yes, but `n_plots` needs the field-work term and the cap (**back-link owed**) |
| Time & Turn (#4) | Soft | The season tick, `seasons_per_year` | Built, no GDD | n/a |
| Cave Abode (#47) | Soft | The home; the Linh Điền field work (slot, level, plots per level, dormant) | Approved | Yes (rule 5); needs a pointer to this GDD's plots (**back-link owed**) |
| Trade Goods (#45) | Hard | The herb catalogue, a harvested herb's fixed age (rule 10), wild ages (Formula K) | Approved | **No: note owed** |
| Alchemy (#15) | Soft (out) | Herbs counted by equivalents in recipes | Built, no GDD | n/a (no GDD) |
| Regional Economy (#43) | Soft (out) | Seeds bought from the commons; the harvested herb's market tag | Approved | **No: note owed** |
| Formations (#17) | Soft | Thanh Mộc array's `herb_growth_pct` at the field | Approved | **No: note owed** |
| Đạo Đồ (#10) | Soft | Capabilities #12 and #14 | In review | Yes (capability host) |
| World Database (#3), Game UI (#37) | Soft | Herb records; the field screen | Built / not started | n/a |

**Circularity:** none added. This GDD reads Item Database, Trade Goods and Travel & Map and supplies a rate and a harvested herb; none of them writes back into the field.

**Back-links owed (six):** Realms Formula D (`n_plots`), Cave Abode rule 5, Trade Goods, Regional Economy, Formations and Character Stats (names the mastery per-level value's owner). They are listed in Cross-References and Open Questions; none has been edited.

## Visual/Audio Requirements

Art bible §1–4 are still placeholders; this section draws on §7 and the pillars.

- **Terminal today.** The field prints a plots table: plot, herb, age, `E`, `mature_years`, fit and its word, growth per year, seasons to maturity. A Frozen herb is marked with text, never colour alone. The growth rate prints with its Wood, `herb_growth_pct` and fit lines.
- **Game UI intent.** A small walled garden of ink-wash beds, one per plot: the herb grows through three drawn stages (young, mature, old) in its element hue (art bible §7.5); the old stage gains a gilded edge past the knee. Seed packets use the Đạo Đồ medallion frame (§7.9).
- **Events needing a visual and sound later:** planting, a herb reaching maturity, a harvest, a herb passing the knee, a plot Frozen or Locked.

## Game Feel

The moment that matters: **harvesting a herb you planted decades ago**, and seeing its age and value on the screen.

- **Before:** choosing what to plant shows the fit word, years to maturity and net value, so the plan is clear.
- **During:** nothing is real-time; the season summary says which herb matured.
- **After:** the harvest shows the age it froze at, its `E`, and what it can brew.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Field screen | Every plot with herb, age, `E`, fit word, growth rate lines, seasons to maturity, Frozen and Locked marks, the plots total and any clamp | Plant, transplant, harvest; open a herb's detail |
| Seed picker | Herbs sold at the realm's rarity ladder, each with its fit word at the home, years to maturity and net value per plot-year | Choose a herb and a plot |
| Character sheet | Linh Điền mastery level and xp, its `herb_growth_pct` line | Open the breakdown |
| Season summary | Herbs that matured or were Frozen | Open the field screen |
| Advisor | A herb that cannot grow at home points to the nearest known herb ground (as built) | — |

All of these work in the debug terminal first, with numbered menus.

> **📌 UX Flag — Spirit Herbs & Fields:** this system has UI requirements. In Pre-Production, run `/ux-design` for the field screen and the seed picker before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | References | What |
|---|---|---|
| Rules 2, 8; F3 | Item Database rule 15; Formula B | The Planted state, `E`, herb value |
| Rule 8; Edge Cases | Trade Goods rule 10; Formulas A, K | Fixed harvested age, the catalogue, wild ages |
| Rules 5, 6; F1 | Travel & Map rule 18; Formula G | Herb fit, `g_max × fit`, `plant_floor` |
| F1, F4 | Character Stats Formula I; rule 12; Interactions | The `herb_growth_pct` curve, mastery storage |
| Rule 3; F2 | Realms Formula D | `n_plots` (**back-link owed**) |
| Rule 4 | Cave Abode rules 3–5 | The field work, slots, dormant (**back-link owed**) |
| Rules 5, 8 | Regional Economy Formula G | Seeds paid to the commons; `origin_market` |
| F1 | Formations Part II | Thanh Mộc's `herb_growth_pct` |
| Rule 10 | Đạo Đồ capabilities #12, #14 | Ageing inventory herbs; tending away |

## Acceptance Criteria

**Core rules**

- **AC-SH-01** [Logic] Rules 2, 8. **GIVEN** a herb in plot 2, **WHEN** a season passes, **THEN** its age rises by F1's Δage; **WHEN** it is harvested, **THEN** its age stops changing and it carries an `origin_market` tag.
- **AC-SH-02** [Logic] Rule 3, F2. **GIVEN** Thổ purity 50, `field_plots` 1 and field level 3, **THEN** plots are 3 + 2 + 1 + 3 = 9. **GIVEN** the sum 15, **THEN** 12. **GIVEN** every term 0 and no base, **THEN** at least 1.
- **AC-SH-03** [Logic] Rule 4. **GIVEN** a field work at level 3 holding herbs in 9 plots, **WHEN** it goes dormant (plots fall to 6), **THEN** the 3 herbs in plots 6–8 are Frozen: they keep their age, do not grow, can be harvested or transplanted, and are not destroyed.
- **AC-SH-04** [Logic] Rule 5. **GIVEN** a free plot, a seed price of 5 and 10 stones, **WHEN** planting, **THEN** the herb is at age 0 and 5 stones go to the commons. **GIVEN** fit 0.19, **THEN** refused with one line per factor; **GIVEN** fit exactly 0.2, **THEN** allowed. **GIVEN** a seed above `seed_rarity_by_realm`, **THEN** refused with "transplant a living plant". **GIVEN** 4 stones, **THEN** refused, nothing paid.
- **AC-SH-05** [Logic] Rule 5, Edge. **GIVEN** the character is away from home, **THEN** planting, transplanting and harvesting are refused; **GIVEN** capability #14, **THEN** allowed. **GIVEN** a transplanted herb at age 7, **THEN** it keeps age 7.
- **AC-SH-06** [Logic] Rule 6, F1. **GIVEN** Wood 60, Σ⁺ 20 and fit growth 0.96, **THEN** Δage is 0.39 years a season (±0.01) and Hoàng Tinh Sâm (mature 10) matures in 25 seasons (±1).
- **AC-SH-07** [Logic] F1 boundaries. **GIVEN** Wood 0 and no modifiers, **THEN** h = 1. **GIVEN** `hgp` negative enough that 1 + hgp/100 < 0, **THEN** the rate is 0 and the age does not fall. **GIVEN** a planted herb with fit growth `g_max × 0.1`, **THEN** it still grows at 0.12; **GIVEN** fit 0, **THEN** growth is 0 and the herb remains.
- **AC-SH-08** [Logic] Rule 8. **GIVEN** an empty plot, **THEN** harvest is refused; **GIVEN** a herb at age 0, **THEN** harvest is allowed and has earned 0 xp.
- **AC-SH-09** [Logic] Rule 11. **GIVEN** 5 herbs planted and the owner moves home, **THEN** all 5 are in the inventory at their current ages, the old field is empty and the new field starts empty.
- **AC-SH-10** [Logic] Rule 9, F4. **GIVEN** a herb that grows 5 years in a plot, **THEN** mastery xp rises by 10 (2 × 5). **GIVEN** an age-100 herb transplanted in and harvested at once, **THEN** 0 xp. **GIVEN** a Frozen herb, **THEN** 0 xp. **GIVEN** level 0, **THEN** level 1 costs 100 and level 2 costs 200 (reaching 9 costs 4,500).
- **AC-SH-11** [Logic] Rule 9, F1. **GIVEN** mastery level 9 and no other modifier, **THEN** raw `herb_growth_pct` is +36 and `hgp` is 15.3 (±0.1).
- **AC-SH-12** [Logic] F3. **GIVEN** Hóa Thần Quả at 2.8 herb-years a year, **THEN** the bound is 1,800 × 2.8 / 100 = 50 stones a plot-year (±1); **GIVEN** Ngưng Khí Thảo, **THEN** 0.
- **AC-SH-13** [Logic] Rule 12. **GIVEN** an NPC, **THEN** no plot or field record exists for it.
- **AC-SH-14** [Logic] Rule 14. **GIVEN** a field with three planted herbs, **THEN** the screen shows each plot's herb, age, `E`, `mature_years`, fit and word, the growth rate with the Wood, `herb_growth_pct` and fit lines, and the seasons to maturity.

**Cross-system**

- **AC-SH-15** [Integration] Realms Formula D. **GIVEN** a character at F2's example, **THEN** Realms' `n_plots` equals 9 (this holds after the Formula D back-link).
- **AC-SH-16** [Integration] Cave Abode rule 5. **GIVEN** an abode at grade 3 with a level-3 Linh Điền field in one of its slots, **THEN** it adds 3 plots; **WHEN** the abode falls a grade and the field goes dormant, **THEN** AC-SH-03 holds.
- **AC-SH-17** [Integration] Item Database rule 15, Trade Goods rule 10. **GIVEN** a harvested herb, **THEN** its age never changes (capability #12 excepted: see Open Questions).
- **AC-SH-18** [Integration] Alchemy. **GIVEN** a herb of age a harvested at any age, **THEN** Alchemy counts `E(a / mature_years)` equivalents for it.

**Screens**

- **AC-SH-19** [UI] **GIVEN** the field screen with a Frozen herb, a clamped plot count and a poor-fit herb, **THEN** a screenshot in `production/qa/evidence/` shows the plots, each herb's age and fit word, the frozen mark (not by colour alone), the clamp line and the growth rate lines.

**Gaps noted (not criteria):** pill supply against the Realms calibration (does the field supply the breakthrough gifts) is a harness check; the herb catalogue contents are Trade Goods' and Item Database's; the capability #12 conflict has no criterion until it is resolved.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Capability #12 ages inventory herbs, against Item Database rule 15 and Trade Goods rule 10 (only a Planted herb ages). Keep #12, retire it, or amend the two rules | user | With the Đạo Đồ and Item Database reviews |
| 2 | Back-links owed in Realms Formula D (`n_plots`: field-work term, cap 12), Cave Abode rule 5, Trade Goods, Regional Economy, Formations and Character Stats | user | At the Phase 5 registry and index pass |
| 3 | Starting values (`plots_per_field_level`, `xp_per_herb_year`, `xp_per_level`, `mastery_growth_per_level`) and the pill-supply check against the Realms calibration | Balance Harness (#33) | Harness pass |
| 4 | The herb catalogue: `items_herbs.json` has 10, Trade Goods lists 11 herb goods | Trade Goods; Item Database | With the Item Database revision |
| 5 | Is the total plot cap 12 right now that a field work adds plots? | game-designer | With the harness pass |
| 6 | Held-old-herb value compounds without a ceiling (Item Database); watch how much the markets pay for held herbs (F3) | Balance Harness | Harness pass |
| 7 | Build gap: no Linh Điền mastery skill or data file exists yet (`crafting_*.json` has the others) | implementer | Before implementation |
| 8 | Should the field have a realm-scaled upkeep as a stone sink, like the abode grade? Today it has none | user | After the harness pass |
