# Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền)

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-21 (review round 4 revisions)
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

Numbers are the built ones (3 base plots, 0.04 plots and 0.8 % growth (0.008) per purity, the seed rarity ladder) or guesses for the balance harness. Plots have **no upper bound** (user decision 2026-11-10, no caps; Character Stats rule 14 and Formulas G removed `max_plots`).

1. **Scope.** This GDD owns plots, planting, tending, harvesting, growth, seeds and the Linh Điền mastery. It does **not** own the herb catalogue and values (Item Database, Trade Goods), `mature_years` and the equivalents curve (Item Database Formula B), fit (Travel & Map Formula G), wild gathering ages (Trade Goods Formula K) or what a herb is used for (Alchemy #15).
2. **A herb is an item** with `template`, `age` (years), and, while growing, a `plot` index (Item Database rule 15). It is **Planted** when `plot ≥ 0`. Only a Planted herb ages, and a harvested herb's age is fixed.
3. **Plots at the home.** The home has `plots = max(1, floor(base_plots + Thổ purity × plots_per_purity + total(field_plots)))`: the whole sum is floored once, so `plots` is always an integer, with no upper bound (Character Stats Formulas G, which Realms Formula D reads; its rounding is a **back-link owed**). A plot with index `≥ plots` is **Locked** when empty and **Frozen** when it holds a herb (States), whatever lowered `plots` (the field work going dormant, Thổ, the stat, a field level); the highest indices go first. The base, Thổ and the tree's and edges' `field_plots` are the **home garden** and take no abode slot; the field work (rule 4) is one more source of `field_plots`.
4. **The field work.** The Linh Điền field is a **home work** (Cave Abode rule 4) that takes one slot, has levels up to the abode's level ceiling and its own `max`, and adds `level × plots_per_field_level` (raw, not floored here; rule 3 floors the whole sum once) to the `field_plots` stat as a modifier with source `home work`. Its build cost and upkeep follow Cave Abode's work rules. When it goes dormant or the home is left, its plots stop counting (rule 11).
5. **Planting.** At the home, with a free plot, a character plants a herb: from a bought **seed** (the herb's `seed_price`, paid to the commons pool of the **home market**, the market of the home place's region (Regional Economy); with none, no seed is for sale and `origin_market` is empty; the five basic herbs' seeds are sold at every realm, and a multi-element herb's seed only up to the buyer's current realm's `seed_rarity_by_realm`; herb element rework, user decision 2026-11-21; `production/plans/herb-element-rework.md`), or by **transplanting** an owned herb, which keeps its age. A herb can be planted only where its fit is at least `plant_floor` (Travel & Map Formula G), and the screen says why a herb cannot grow here. Planting a seed creates a herb at age 0.
6. **Growth.** Each season tick, in this order: plots, dormancy and modifiers are refreshed; then every Planted herb that is not Frozen gains the years below; then Linh Điền xp is added from those years (rule 9). Player actions happen between ticks: a herb planted this turn ages this tick, a herb harvested this turn does not. Each Planted herb gains `(seasons / seasons_per_year) × growth_rate × fit_growth` years (Formulas F1). `growth_rate` is the Wood root and growth-stat factor; `fit_growth` is Travel & Map's `g_max × fit` for that herb at the home. A herb already planted keeps growing below the plant floor.
7. **Tending is free of time.** Growth needs no action; the cost is the plot, the seed and the wait. A herb never withers or dies in a plot (Edge Cases). The decisions are what to plant, and when to harvest.
8. **Harvest.** At the home, any season, a character harvests a plot. The herb leaves the plot at its current age, which then freezes (Trade Goods rule 10), joins the inventory. It is tagged with its home market (`origin_market`) **only if it has no tag yet** (on a move, the old home's market, tagged before the home changes), so a transplanted bought or found herb keeps its original tag. The plot is free at once. There are no seeds back: replanting costs a new seed.
9. **Linh Điền mastery** (đạo nghệ, levels 0–9). Mastery xp accrues each season from the years every Planted, non-Frozen herb actually grows in a plot, Mature and old herbs included (`xp = xp_per_herb_year × Δage`, the real years added by Formulas F1; F4), so a herb found or bought old gives nothing for its past years, and a Frozen herb gives nothing. Level n + 1 costs `xp_per_level × (n + 1)` (Character Stats). Each level adds `mastery_growth_per_level` to `herb_growth_pct` on the stat sheet, through Character Stats' bonus curve for that key. Mastery does not change plots or seed gates.
10. **Capabilities as built.** Capability #12 ages unplanted herbs in the inventory at `rate` as well; capability #14 lets the character tend (plant, transplant and harvest) away from the home, as built. Both keep their current meaning.
11. **Moving home and dormant fields.** When a character moves home, every herb in the old field is **harvested into the inventory at its current age** (no loss, but no more ageing), and plots at the new home start empty. When the field work goes dormant, the herbs in plots whose index is now `≥ plots` become Frozen (rule 3; States): they stop ageing and can be harvested or transplanted but not replaced; herbs in plots below the new count keep growing.
12. **NPCs have no plots.** NPC workshops' aged herbs are Trade Goods' abstraction (their `craft_in` and ages); no per-NPC field is simulated here.
13. **Other sources** (buying at a market, wild gathering, found plants) are outside this GDD; their herbs enter the same inventory and can be planted by rule 5.
14. **Visibility** (Pillar 2). The field screen lists each plot with its herb, age, equivalents `E` (Item Database Formula B), `mature_years`, fit and its word, the growth rate with each source on its own line (Wood root, `herb_growth_pct` with mastery, fit), and the years left to maturity.

### States and Transitions

**A plot (per plot index at the home)**

| State | Meaning | Becomes | When |
|---|---|---|---|
| Locked | The plot index is `≥ plots` and empty (a plot source lowered, or a Frozen plot harvested or transplanted out) | Free | `plots` rises (a field level, Thổ, the stat) |
| Free | Usable, empty | Growing; Locked | A seed is planted, or a herb is transplanted in; `plots` falls below its index |
| Growing | A herb with age below `mature_years` | Mature; Free | The herb reaches `mature_years`; it is harvested or the home is left |
| Mature | Age at or above `mature_years`; still ageing | Free | Harvested or the home is left |
| Frozen | Derived each tick, not stored: the plot index is `≥ plots` and holds a herb (any cause); the herb does not age or earn xp | Growing/Mature; Locked | `plots` rises again; or the herb is harvested or transplanted out (the plot is then Locked) |

**The herb in a plot** has a descriptive band for the screen only (no state change): **young** (age < `mature_years`), **mature** (value = `base_value`), **plateau** (up to the knee, `x_k` × `mature_years`) and **old** (past the knee, where Formula B compounds).

**Linh Điền mastery:** level 0 → 9 by growth xp (F4; Character Stats storage); it never falls and stays across a move.

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
| fit_growth | float | 0–1.2 (g_max × fit; 0.24 at the planting floor, which only gates planting); 1 where the ground has no qi | Travel & Map Formula G | Growth by fit |

**Output Range:** seasons until a target are rounded up, and are "never" (the screen says not growing) when `h × fit_growth` = 0. `h` from 0 (clamped, with negative modifiers) through 1 (no Wood, no modifiers) to about 2.3 (Wood 100, Σ⁺ about 150); with fit_growth 1.2 up to about 2.8 herb-years a year.
**Example:** Wood 60, Σ⁺ 20, fit 0.8 (growth 0.96): `hgp = 10 ln 3 = 11.0`, `h = 1.48 × 1.11 = 1.64`, 0.39 years a season; Hoàng Tinh Sâm (mature 10) takes 25.4 seasons, rounded up to 26.

### F2. Plots

The plot_count formula is defined as:

`plots = max(1, floor(base_plots + Thổ purity × 0.04 + total(field_plots)))` (Character Stats Formulas G; the one floor is on the whole sum), with `total(field_plots)` = the tree's and edges' plots + `field_level × plots_per_field_level` from the field work (a raw modifier)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| base_plots | int | 3 | `session_actions.json` (as built) | Base plots; `max_plots` 12 in that file is stale (removed 2026-11-10 by Character Stats) and is to be dropped |
| total(field_plots) | float | 0+ | Modifier System; Character Stats | The stat's total: the tree, edges and the field work's modifier |
| plots_per_field_level | float | 1 *(guess)* | data file | Plots per level of the Linh Điền field work (active only) |
| field_level | int | 0 to the abode's ceiling (max 5) | Cave Abode | The field work's level, 0 if dormant |

**Output Range:** 1 and up, with no upper bound (a deliberate build lever: Character Stats rule 14).
**Example:** Thổ 50, stat 1, field level 3: 3 + 2 + 1 + 3 = **9**; stat 0.5 instead: floor(8.5) = **8**.
**Note:** Realms Formula D reads Character Stats Formulas G, which already totals `field_plots`, so no change is owed there; the field work needs Character Stats and Cave Abode to name it as a source (back-links).

### F3. Value a plot can earn (an upper bound for the economy check, not a mechanic)

The plot_value formula is defined as:

`net_value_per_plot_year (harvest at maturity) = (base_value − seed_price) × h × fit_growth / mature_years`; a herb left in its plot past the knee is worth Formula B's `base_value × E(age / mature_years)` instead, a value realised only if a buyer holds that much.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| base_value, seed_price, mature_years | int | per herb (2–3,000; 2–1,200; 1–100) | `items_herbs.json` | The herb's value, seed cost and maturity |
| h, fit_growth | float | F1 | calculated | The growth factors |

**Output Range:** 0 (Ngưng Khí Thảo: value equals seed price) to about 50 stones a plot-year (Hóa Thần Quả, the best row of the 11-good catalogue, which owns the check). **Example:** Hóa Thần Quả (3,000, seed 1,200, mature 100) at 2.8 herb-years a year: 1,800 × 2.8 / 100 = **50**; at 12 plots (an assumption, as there is no bound) about 600 a year, less than one season of a Hóa Thần grade-5 abode's upkeep (3,000).
A sale is paid by the market's commons pool, up to its balance (Regional Economy), so the field mints no stones and the pool balance bounds what held herbs can fetch; the held-old-herb value is Item Database's (no ceiling, user decision 2026-11-20).

### F4. Linh Điền mastery

The mastery_xp formula is defined as:

`xp per season = xp_per_herb_year × Δage` for each Planted herb that is not Frozen, Mature and old herbs included, on the years actually added (a herb harvested at age 0 has earned 0; Frozen herbs earn nothing); level n + 1 costs `xp_per_level × (n + 1)`; level L adds `mastery_growth_per_level × L` to `herb_growth_pct` (raw, through F1's curve).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| xp_per_herb_year | float | 2 *(guess)* | data file | Mastery xp per year a herb grows in a plot |
| xp_per_level | float | 100 *(guess, as the other crafts)* | data file | Level cost scale |
| mastery_growth_per_level | float | 4 *(guess)* | data file | Raw `herb_growth_pct` per level |

**Output Range:** level 0–9; at level 9 +36 raw, which the curve turns into `hgp` +15.3 (×1.153).
**Example:** reaching level 9 costs 100 × (1 + … + 9) = 4,500 xp, about 2,250 herb-years of growth: about 68 years at the best case (12 plots, 2.8 herb-years each a year), about 470 years at 3 plots (about 1.6 herb-years a year each). The pacing is for the harness (Open Question 3).

### Boundary and loop checks

- **No Wood, no modifiers:** `h = 1`. **Negative `hgp`:** `max(0, …)` floors the rate at 0, so a herb stops but never un-ages.
- **Fit at the planting floor (0.2):** growth ×0.24; a herb already planted whose ground falls below it keeps growing at `g_max × fit`, and at fit 0 it stops.
- **Plots at 0:** floored at 1; there is no upper bound.
- **Positive loop:** mastery → faster growth → more xp. Bounded by the log curve (Σ⁺ of 150 gives only +27.7) and by 9 levels.
- **Dominant purchase:** inside each realm's seed gate the rarest seed earns most per plot-year (F3); this is accepted. The offsets are the gate (`seed_rarity_by_realm`) and the maturity wait (Hóa Thần Quả about 36 years to first harvest).
- **Faucet:** the field mints no stones. A harvest moves value from the commons pool to the grower (sale price less the seed price, F3), bounded by the pool's balance; the seed price returns to the pool, so it is not a sink.

## Edge Cases

**Planting and plots**

- **If there is no free plot**: planting or transplanting is refused with the plot count, and nothing is spent.
- **If a multi-element herb's seed is rarer than `seed_rarity_by_realm`**: no seed is for sale (basic herbs' seeds always are); the screen says to find a living plant and transplant it.
- **If the home's fit for a herb is below `plant_floor` (0.2)**: planting is refused with each factor's line (element, temperature, rainfall, density). Exactly 0.2 is plantable.
- **If the character is away from home**: planting, transplanting and harvesting are refused unless they hold capability #14. Growth needs no presence.
- **If the character cannot pay the seed price**: refused, nothing paid.
- **If the home's ground has no land qi**: `fit_growth` is ×1 and planting is always allowed (no `plant_floor` check, no fit word; the screen says "no land qi here"), as built. Note for the user: ×1 outgrows any real fit below about 0.83.

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
- **If the owner dies**: planted herbs pass with the estate under Item Database and Living World Tick's rules as ordinary items; their `plot` is cleared and their age fixed, and each is tagged as at harvest (rule 8: the home's market, only if it has no tag yet). This GDD adds nothing else.

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
| Realms & Bottlenecks (#8) | Hard (out) | Pill supply reads plots and the growth rate (Formula D) | In review | Yes; it reads plots from Character Stats Formulas G, so no change is owed (the pill-supply calibration is re-run, Open Question 3) |
| Time & Turn (#4) | Soft | The season tick, `seasons_per_year` | Built, no GDD | n/a |
| Cave Abode (#47) | Soft | The home; the Linh Điền field work (slot, level, plots per level, dormant) | Approved | Yes (rule 5; back-link added 2026-11-21) |
| Trade Goods (#45) | Hard | The herb catalogue, a harvested herb's fixed age (rule 10), wild ages (Formula K) | Approved | Yes (rule 10; back-link added 2026-11-21) |
| Alchemy (#15) | Soft (out) | Herbs counted by equivalents in recipes | Built, no GDD | n/a (no GDD) |
| Regional Economy (#43) | Soft (out) | Seeds bought from the commons; the harvested herb's market tag | Approved | Yes (Dependencies; back-link added 2026-11-21) |
| Formations (#17) | Soft | Thanh Mộc array's `herb_growth_pct` at the field | Approved | Yes (rule 14, Dependencies; back-link added 2026-11-21) |
| Đạo Đồ (#10) | Soft | Capabilities #12 and #14 | In review | Yes (capability host) |
| World Database (#3), Game UI (#37) | Soft | Herb records; the field screen | Built / not started | n/a |

**Circularity:** none added. This GDD reads Item Database, Trade Goods and Travel & Map and supplies a rate and a harvested herb; none of them writes back into the field.

**Back-links:** added 2026-11-21 in Cave Abode, Trade Goods, Regional Economy, Formations and Character Stats; Realms needs none.

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
| Field screen | Every plot with herb, age, `E`, fit word, growth rate lines, seasons to maturity, Frozen and Locked marks, the plots total with each source's line | Plant, transplant, harvest; open a herb's detail |
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
| Rule 3; F2 | Character Stats Formulas G; Realms Formula D | The plot formula and where Realms reads it |
| Rule 4 | Cave Abode rules 3–5 | The field work, slots, dormant (back-link added 2026-11-21) |
| Rules 5, 8 | Regional Economy Formula G | Seeds paid to the commons; `origin_market` |
| F1 | Formations Part II | Thanh Mộc's `herb_growth_pct` |
| Rule 10 | Đạo Đồ capabilities #12, #14 | Ageing inventory herbs; tending away |

## Acceptance Criteria

**Core rules**

- **AC-SH-01** [Logic] Rules 2, 8. **GIVEN** a character without capability #12 and a herb in plot 2, **WHEN** a season passes, **THEN** its age rises by F1's Δage; **WHEN** it is harvested, **THEN** its age stops changing and it carries an `origin_market` tag.
- **AC-SH-02** [Logic] Rule 3, F2. **GIVEN** Thổ purity 50, `field_plots` 1 and field level 3, **THEN** plots are 3 + 2 + 1 + 3 = 9; **GIVEN** `field_plots` 0.5, **THEN** floor(8.5) = 8. **GIVEN** Thổ purity 100, `field_plots` 7 and field level 5, **THEN** 3 + 4 + 7 + 5 = 19 (no upper bound). **GIVEN** every term 0 and no base, **THEN** at least 1.
- **AC-SH-03** [Logic] Rule 4. **GIVEN** base plots 3, Thổ purity 50, `field_plots` stat 1 (the F2 example) and a field work at level 3 holding herbs in 9 plots, **WHEN** it goes dormant (plots fall to 6), **THEN** the 3 herbs in plots 6–8 are Frozen: they keep their age, do not grow, can be harvested or transplanted, and are not destroyed; **WHEN** one is harvested, **THEN** its plot is Locked, and **WHEN** the field is active again, **THEN** the rest age again.
- **AC-SH-04** [Logic] Rule 5. **GIVEN** a free plot, a seed price of 5 and 10 stones, **WHEN** planting, **THEN** the herb is at age 0 and 5 stones go to the commons. **GIVEN** fit 0.19, **THEN** refused with four lines (element, temperature, rainfall, density); **GIVEN** fit exactly 0.2, **THEN** allowed. **GIVEN** a seed above `seed_rarity_by_realm`, **THEN** refused with "transplant a living plant". **GIVEN** 4 stones, **THEN** refused, nothing paid.
- **AC-SH-05** [Logic] Rule 5, Edge. **GIVEN** the character is away from home, **THEN** planting, transplanting and harvesting are refused; **GIVEN** capability #14, **THEN** all three are allowed (rule 10). **GIVEN** a transplanted herb at age 7, **THEN** it keeps age 7. **GIVEN** a bought herb tagged `origin_market` A harvested later from a plot at a home in market B, **THEN** its tag stays A (rule 8).
- **AC-SH-06** [Logic] Rule 6, F1. **GIVEN** Wood 60, Σ⁺ 20 and fit growth 0.96, **THEN** Δage is 0.39 years a season (±0.01) and Hoàng Tinh Sâm (mature 10) matures in exactly 26 seasons (25.4 rounded up, F1).
- **AC-SH-07** [Logic] F1 boundaries. **GIVEN** Wood 0 and no modifiers, **THEN** h = 1. **GIVEN** `hgp` negative enough that 1 + hgp/100 < 0, **THEN** the rate is 0 and the age does not fall. **GIVEN** a planted herb with fit 0.1 (`g_max × 0.1` = 0.12), h 1, **THEN** it still grows 0.25 × 0.12 = 0.03 years a season; **GIVEN** fit 0, **THEN** growth is 0 and the herb remains.
- **AC-SH-08** [Logic] Rule 8. **GIVEN** an empty plot, **THEN** harvest is refused; **GIVEN** a herb at age 0, **THEN** harvest is allowed and has earned 0 xp.
- **AC-SH-09** [Logic] Rule 11. **GIVEN** 5 herbs planted and the owner moves home, **THEN** all 5 are in the inventory at their current ages, the old field is empty and the new field starts empty.
- **AC-SH-10** [Logic] Rule 9, F4. **GIVEN** a herb that grows 5 years in a plot, **THEN** mastery xp rises by 10 (2 × 5). **GIVEN** an age-100 herb transplanted in and harvested at once, **THEN** 0 xp. **GIVEN** a Frozen herb, **THEN** 0 xp. **GIVEN** a Mature herb that ages 1 year, **THEN** 2 xp. **GIVEN** level 0, **THEN** level 1 costs 100 and level 2 costs 200 (reaching 9 costs 4,500).
- **AC-SH-11** [Logic] Rule 9, F1. **GIVEN** mastery level 9 and no other modifier, **THEN** raw `herb_growth_pct` is +36 and `hgp` is 15.3 (±0.1).
- **AC-SH-12** [Logic] F3. **GIVEN** Hóa Thần Quả at 2.8 herb-years a year, **THEN** the bound is 1,800 × 2.8 / 100 = 50 stones a plot-year (±1); **GIVEN** Ngưng Khí Thảo, **THEN** 0.
- **AC-SH-13** [Logic] Rule 12. **GIVEN** an NPC, **THEN** no plot or field record exists for it.
- **AC-SH-14** [Logic] Rule 14. **GIVEN** a field with three planted herbs, **THEN** the screen shows each plot's herb, age, `E`, `mature_years`, fit and word, the growth rate with the Wood, `herb_growth_pct` and fit lines, and the seasons to maturity.

**Cross-system**

- **AC-SH-15** [Integration] Realms Formula D. **GIVEN** a character at F2's example, **THEN** Realms' `n_plots` (read from Character Stats Formulas G) equals 9.
- **AC-SH-16** [Integration] Cave Abode rule 5. **GIVEN** an abode at grade 3 with a level-3 Linh Điền field in one of its slots, **THEN** it adds 3 plots; **WHEN** the abode falls a grade and the field goes dormant, **THEN** AC-SH-03 holds.
- **AC-SH-17** [Integration] Item Database rule 15, Trade Goods rule 10. **GIVEN** a character without capability #12 and a harvested herb, **THEN** its age is unchanged after 4 seasons (with #12 the herb ages at its `rate`: Open Question 1).
- **AC-SH-18** [Integration] Alchemy. **GIVEN** a herb of age a harvested at any age, **THEN** Alchemy counts `E(a / mature_years)` equivalents for it.

**Screens**

- **AC-SH-19** [UI] **GIVEN** the field screen with a Frozen herb, a long plots list and a poor-fit herb, **THEN** a screenshot in `production/qa/evidence/` shows the plots, each herb's age and fit word, the frozen mark (not by colour alone), each plot source's line and the growth rate lines.

**Gaps noted (not criteria):** pill supply against the Realms calibration (does the field supply the breakthrough gifts) is a harness check; the herb catalogue contents are Trade Goods' and Item Database's; the capability #12 conflict has no criterion until it is resolved.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Capability #12 ages inventory herbs, against Item Database rule 15 and Trade Goods rule 10 (only a Planted herb ages). Keep #12, retire it, or amend the two rules | user | With the Đạo Đồ and Item Database reviews |
| 2 | **Closed 2026-11-21:** back-links added in Cave Abode (rule 5, rows), Trade Goods (rule 10, Dependencies), Regional Economy (Dependencies), Formations (rule 14, Dependencies) and Character Stats (rule 14, Dependencies, Formulas G); Realms needs none | user | Done |
| 3 | Back-link owed: Character Stats Formulas G should floor the whole sum (this GDD's F2). Starting values (`plots_per_field_level`, `xp_per_herb_year`, `xp_per_level`, `mastery_growth_per_level`) and the pill-supply check against the Realms calibration | Balance Harness (#33) | Harness pass |
| 4 | **Closed 2026-11-21:** the catalogue is five basic herbs (one per element, Thiết Tuyến Thảo the Metal one) and six multi-element herbs (herb element rework, user decision 2026-11-21; `production/plans/herb-element-rework.md`) | Trade Goods; Item Database | Done |
| 5 | Plots have no upper bound (Character Stats), and a field work adds more: does the harness show a runaway plot count for Earth-heavy builds? The built `max_plots` 12 in `session_actions.json` is stale and should be dropped | Balance Harness; implementer | Harness pass |
| 6 | Held-old-herb value compounds without a ceiling (Item Database); watch how much the markets pay for held herbs (F3) | Balance Harness | Harness pass |
| 7 | Build gap: no Linh Điền mastery skill or data file exists yet (`crafting_*.json` has the others) | implementer | Before implementation |
| 8 | Beyond Cave Abode's standard work upkeep (rule 4), should the field have a realm-scaled upkeep as a stone sink, like the abode grade? Today it has only the standard one | user | After the harness pass |
