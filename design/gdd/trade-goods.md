# Trade Goods (Hàng Hóa)

> **Status**: Approved (design-review 12, 2026-11-15, lean, 0 blocking, 6 recommended; Open Question 14 amendments applied to #43, Item Database and Travel & Map 2026-11-15). Earlier: revised after design-review 11 (2026-11-15, lean, NEEDS REVISION; 1 blocker, the registry `craft_plan` entry out of date with Formula F, synced; also `fill_tol` in the variables table, the review-10 clamps in the #43 amendment list, a fixed class order for `Σ_c`, post-scale `fill_c` stated once), pending re-review. Earlier: design-review 10 (2026-11-15, lean, NEEDS REVISION; 1 blocker addressed: a draw-scale step after `fill_c` holds `cd ≤ v_g − buy_pl` by construction for any slot mix (a first fix, reserving named draws, failed 5,152 of 200,000 random cases with overlapping groups and was replaced); `avail_A`, `D_g` and the shared draw use `max(0, D − craft_in)`, since a negative `P_eff` let exports exceed shelved value and made fill and `cd` negative; world sums in market-id order; X' floored at 0 against rounding; all found and checked by `tools/design/trade_goods_sim/tick_props.py` (AC-TG-52); also the plan-rise tolerance, Formula G group spread, AC-TG-51b imports wording), pending re-review. Earlier: design-review 9 (2026-11-15, lean, NEEDS REVISION; 1 blocker addressed: a slot group's need spreads by `v_g − buy_pl` so `cd ≤ v_g − buy_pl` holds per good; also stale export-share and holder-change wording, multi-class `cd`), pending re-review. Earlier: design-review 8 (2026-11-15, lean, NEEDS REVISION; 2 blockers addressed: exports take `Exp · ex[g]` per good so hubs conserve; player purchases served first and `cd ≤ v_g − buy_pl` so `X_pre ≥ 0`), pending re-review. Earlier: design-review 7 (2026-11-15, lean, NEEDS REVISION; 2 blockers addressed: imports split by the exporter's shelved export shares so each good conserves; fill and craft draw read the good's own pre-draw value so `cd ≤ X0`), pending re-review. Earlier: design-review 6 (2026-11-15, lean, NEEDS REVISION; 1 blocker addressed: exports bounded by shelved value so links conserve value; also price reads shelved stock, `D_g` over shelved goods, cross-band groups, no plan windup, dust only without inflow), pending re-review. Earlier: design-review 5 (2026-11-15, lean, NEEDS REVISION; 3 blockers addressed: draw capped at shelved value, slot-group fill, Ngưng Nguyên margin 1.73). Earlier: design-review 4 (2026-11-15, lean, NEEDS REVISION; 2 blockers addressed: shelved timing and `sh'` from end values), pending re-review. Earlier: design-review 1 (full; 8 blockers), 2 and 3 (lean; 1 each) all addressed (design-system 2026-11-14, guided, --review full: economy-designer, systems-designer, game-designer, qa-lead and creative-director consulted)
> **Author**: user + Claude
> **Last Updated**: 2026-11-15
> **Last Verified**: 2026-11-15
> **Implements Pillar**: Pillar 5 (A World That Remembers), Pillar 4 (Every Season Counts); serves Pillar 3 (Power Is Built, Not Given) through crafting inputs, and Pillar 1 (Your Dao, Your Name) through roots that steer a cultivator to the regions their build needs; touches Pillar 2 (Every Number Is Bounded and Visible)
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-14 (CONCERNS; items 1, 4, 6, 7 revised; 2, 3 moved to Open Questions 13 and 11; 5 left for ux-designer)

## Summary

Trade Goods turns the regional economy's four priced classes into things a cultivator can hold: 23 named herbs, ores,
beast parts and special goods, each an Item Database template with an element, a weight and a source in the land. The land
decides where each good grows; a good only a few regions produce becomes a specialty, worth more where it is scarce.
Crafted goods (pills, talismans, artifacts) get priced classes of their own, supplied by workshops that answer prices, so
crafting moves markets. It gives carrying a reason beyond a price gap and closes the craft-to-sell arbitrage Regional
Economy & Trade left open.

> **Quick reference** — Layer: `Feature` · Priority: `To decide` · Key deps: `Regional Economy & Trade, Item Database, Travel & Map, Market; soft: Realms, Sects & Missions, Alchemy, Artifact Refining, Talismans, Codex`

## Overview

Trade Goods (Hàng Hóa) defines the goods the regional economy trades as items a cultivator can hold, carry and sell.
Regional Economy & Trade (#43) prices four good classes (herb, ore, beast, special) by market and season, but a class is
a number, not a thing: this system fills each class with **named goods** (Xích Đồng, a Fire-element red copper; Băng Tâm
Thảo, an ice-heart grass; Yêu Thú Bì, a demon-beast hide), each with a base value, a carry weight and a source in the land, mapped to the Item Database's herbs
and materials. Some goods are **regional specialties**, produced only where the land allows (Travel & Map's terrain, element
and density), so they are plentiful at the source and scarce elsewhere, and a trip has a reason beyond a price gap.
**Crafted goods** (pills, artifacts, talismans) get a market of their own instead of borrowing their main input's price
(amending #43 rule 4), so a glut of pills in one sect's territory shows in their price, and crafting raw goods into
finished goods cannot become a trade with no market response. A cultivator's spiritual root steers them to the
specialties their build needs: a Fire-root alchemist learns that Xích Huyết Đằng grows in only a few jungle and volcano
regions.

The player meets it whenever they buy, sell, gather or loot: every good has a name, a class, a region it comes from and a
price that shows its parts (Pillar 2). Without it, the market trades abstract class quantities, no place has goods of its
own, and carrying has only one reason, a price gap. Linh thạch is money, not a trade good (#43 rule 5); this system never
prices it.

## Detailed Design

### Core Rules

**Goods**

1. **A trade good is an Item Database template, not a new item kind.** A raw trade good is a herb or material template
   with a `trade` block: `good_class` (herb for herbs; ore, beast or special for materials, Item Database Open Question
   25), `element`, `source` (site kind, resource kind, element or "any", biomes, `density_min`, rarity) and `weight` per
   unit (cargo). Its value stays the Item Database's (rule 9): a material's template value, a herb's base value and
   potency.
2. **MVP catalogue: 23 goods** (Catalogue, below): herbs 11, ores 6 (the five element ores plus one rare), beast parts 3
   (bone, hide, core), special goods 3. 17 already exist in `items_herbs.json` and `items_materials.json`; 6 are new and
   their values wait on the Item Database revision.
3. **Fallback goods.** Every pair of resource kind and element has one generic good, so every site yields something.
   A fallback skips the biome, fit, density and rarity tests and counts as fit 1, and it is eligible only when no other
   good is. A world with a pair lacking its fallback is rejected at load.
4. **Outside trade:** linh thạch (money, Regional Economy & Trade rule 5), treasures and technique manuals. Manuals keep
   P = 1.0 (#43 Formula E). Bound items cannot be sold anyway (Item Database rule 13).

4a. **Every good feeds a build.** Each catalogue good is an input to at least one recipe whose output (a pill, talisman
    or artifact) a build uses. Refining, talisman and formation recipes take materials by count and minimum rarity, so
    every material whose rarity fits a slot counts, and the refining element-match bonus ties material elements to builds;
    the new herb Thiết Tuyến Thảo gets a new Qi Refining pill, **Thiết Cốt Đan** (iron-bone pill: 3 Thiết Tuyến Thảo at age
    1, yield 2, price 15, margin 1.82; a small body-tempering pill whose effect is hand-designed at the content pass) (user decision 2026-11-14). Recipes read a good's `good_class`, `element` and `rarity`: the contract handed to Alchemy,
    Artifact Refining and Talismans. The data load warns, naming the good, if no recipe uses it *(CD-GDD-ALIGN,
    2026-11-14)*.

**Where goods come from**

5. **Site yield table.** A site's eligible goods are those whose `source` matches it: site kind and resource kind,
   element (or "any"), the part's biome, herb fit 0.6 or more for herbs (Travel & Map rule 18), land density at least
   `density_min`, and rarity no higher than the site's top rarity. Eligible goods are weighted by fit and rarity
   (Formulas). The table is built at world generation (the world is fixed) and rebuilt only when a site's layers change
   (scar or works).
6. **Split value, not counts.** A site's `value_lt` of a kind is split among its eligible goods by those weights; the
   parts always sum to `value_lt`, so #43's supply is unchanged and nothing is counted twice. Travel & Map's production
   contract carries the split (`by_good`, new). Whole units are counted only where a good is gathered or shelved; value
   below one unit is **carried**, at the site (`rem[s,g]`, added to the next season's part) and in the market pool (a
   good under one unit keeps its value there until it builds up to one), so a rare good accumulates instead of being
   reset each season *(design-review 1, 2026-11-14)*. **A good below one unit is outside the proportional draw**
   *(design-review 3, 2026-11-14, user)*: demand, exports and the `s_cap` overflow take only from shelved goods (pool
   value ≥ `V_g`), and a good under one unit does not spoil either (it is a value ledger like the site's `rem`, not
yet a stock of goods). Without this the pool kept only about 27 % of a
   good's value a season (#43's steady state, 0.4 D of 1.5 D), so a rarity 5–6 good needed about 2.7 × `V_g` of
   inflow a season to reach a shelf and never could.
7. **A specialty is computed, never authored.** A good that 3 or fewer regions produce in a season is a **specialty**.
   The label is recomputed each season, so scars, works and holder changes can make or unmake one. Where specialties
   occur follows the terrain.

**In the market**

8. **Prices stay per class** (#43). Each class pool in each market carries a **composition**: the share of its base
   value that each good makes up. Supply, link flows (split by the exporter's composition) and class spoilage (#43
   Formula D's `dk`) move the shares. Shelves list goods by share, as a view of the pool (#43 Edge Cases, restock).

8a. **Raw classes by rarity band** *(user decision 2026-11-14, design-review 1; amends #43 rule 4)*. Each raw kind is
    priced in bands, `band = ceil(rarity / 2)`: rarity 1–2, 3–4 and 5–6. Only bands that hold goods exist, so the MVP
    has **8 raw classes**: herb 1–3, ore 1–2, beast 1, special 1–2. A band takes its kind's #43 parameters and its own
    `D_min`, and the kind's demand is split across its bands by their season-0 world supply shares, so one Anh Tâm Liên
    sale moves band-3 herb prices, never Ngưng Khí Thảo's.

9. **Scarcity factor.** A good's shop price is its class's local price (#43 L1) times a **scarcity factor** from the
   good's share in this market against its share in the world: above 1 where it is scarce, below 1 where it is
   plentiful. It is set by a formula with no cap; a softening term keeps it finite in a market that has none
   (Formulas). It shows as its own line in the price breakdown (Pillar 2). *(User decision 2026-11-14.)* The good's
   world share is floored at `wsh_min` (Formula D), so the factor has no jump where a good is nearly gone.
10. **A harvested herb's age is fixed** *(user decision 2026-11-14, design-review 1; replaces "held herbs keep
    ageing")*. Only a planted herb ages (Item Database state Planted; the field is Spirit Herbs & Fields', `design/gdd/spirit-herbs.md` rules 2, 6, 8); carried, stored, shelved and pooled herbs keep
    their harvest age, so holding herbs earns nothing. **Wild herbs come in an age mix** (Formula K): most units gathered
    at herb ground are at `mature_years`, and a share is older, more on dense, rarely reached ground. Market pools and
    shelves hold herbs at `mature_years` only (user decision 2026-11-20: shops are a view of the pool); an older herb
    sold to a market is paid at its held value (base · E, Item Database Formula B) and joins the pool as E mature units
    of its good. Market pools spoil at the class `dk` only.

**Crafted goods** (amends #43 rule 4; closes #43 Open Questions 1 and 17)

11. **Crafted classes.** Pills, talismans and artifacts, each split by tier (about 15 classes; tiers by the value
    bands of Formula E; the exact list comes from the data), become priced classes that run through #43 Formulas C–E and L1 with their own
    parameters. They are split by tier because artifact values run from 20 to about 1.2 million (Item Database Formula
    D), and one high-tier sale would swamp a single class (raw classes are split the same way, rule 8a). Crafted goods keep the retail spread, charm, standing and
    `loc_band_fin` (#43 Formula G).
12. **Supply from a craft plan.** Each market's workshops (sect Institutions and the commons' artisans) make the output
    they planned last season for each crafted class, placed at crafting places by settlement weight (a regional supply
    for L1). The next plan is set at the end of the tick from this season's crafted price against input prices **and
    how full the class's stock is**: more where finished goods sell high against their inputs, less where stock is
    already above normal cover. A plan never falls below a small share of its plan at rest (Formula F). Crafted goods
    the player and NPCs sell add to supply.
13. **Crafting draws raw demand, good by good.** The plan's inputs enter #43 Formula C as a `craft_in` term per raw
    class, drawn from the **specific goods** its recipes use; an "any material of rarity r or more" slot is one group,
    spread over its eligible goods on the shelf here (Formula F). Demand follows last season's fill, so an input that is
    off the shelf adds no demand it cannot meet, and a plan does not rise while its inputs fall short. So a workshop brewing with Kim Tủy Quả drains Kim Tủy Quả, not the cheap herbs
    beside it. An aged input counts as its value in mature units (NPC workshops' aged herbs come from their own fields).
    The calibration tool re-solves `d_scale`. A market that brews many pills buys many herbs, and the price answers.
14. **Demand for crafted goods:** a pill share of the provision basket (taken from its herb share); sect Military, which
    takes artifacts and talismans for part of its ore and beast use; kind stipends paid in pills from the sect's
    workshops; and player and NPC purchases.
15. **Origin of a crafted item.** It carries the `origin_market` of its main input (the input with the highest value ×
    quantity; ties by Formula I). Crafting inside an importing market does not remove a tariff tag.
16. **The player's crafted sales** count against their crafted class (P_eff, slippage, `sell_pl`) like raw sales, so a
    craft-and-sell route wears out like a raw route (#43 rule 16).

**Cargo**

16a. **Storage capacity by weight** (user decision 2026-11-14). How much trade goods a cultivator can carry is set by the best storage item
    they carry; capacities do not add up, and storage takes no equipment slot. Without one: **30**; rarity 1 (storage pouch,
    trữ vật đại) **150**; rarity 2 (storage bag) **400**; rarity 3 (storage ring, trữ vật giới) **1,000**; rarity 4 **2,500**;
    rarity 5 **6,000**; rarity 6 **15,000** (about ×2.5 a rarity). For MVP only trade goods count against it. Goods kept at a
    home are capped too, at 1,000 until a cave-abode system sets home storage. The Item Database gains a storage-item kind
    at its revision.

**Knowledge**

17. **Specialty knowledge is a game-start setting.** **Known world**: every specialty is shown on the map. **Discover**:
    the home market's specialties are known, and up to two specialties of bordering markets are heard as rumours (one per
    market, chosen by the game seed, ties by market id; one if only one exists); the rest are learned by visiting or from
    NPCs and kept in the Codex across lives. *(User decision 2026-11-14.)* On a fixed world, knowledge under Discover
    converging toward Known world over several lives is intended; specialties made "former" by scars and politics keep
    that knowledge from going stale.

**What the player cannot do**
- Move a single good's price except through its class, its share and their own bounded trades.
- Remove an origin tag by crafting.
- Sell goods conjured from nothing: every shelf item comes from a pool.
- Escape slippage or local prices by selling specialties or crafted goods.
- Gain stats by holding goods. Goods reach builds only through what they are crafted into (recipes read their tags);
  there are no build-shaped baskets *(user decision 2026-11-14)*.

### Catalogue (MVP)

*(Approved 2026-11-14.)* Values of existing goods are the Item Database's and are not restated as owned here; values of
the 6 new goods were accepted 2026-11-14 (user) and go into the Item Database at its revision; the harness tunes them. **Weight** is physical bulk per unit *(user decision
2026-11-14)*: rare goods are compact treasure, bounded by their small supply share and by slippage; AC-RE-49's route check
guards the profit. "Land" names the matching biomes or features (Travel & Map rules 2 and 4); for herbs the match is herb
fit (Travel & Map rule 18). Specialty status is **computed** (Formula C); "likely specialty" is only an expectation from
how narrow the land is.

**Herbs** (site: herb ground; weight 1 each)

| id | Name | Element | Rarity | V | Land | Status | Likely specialty |
|---|---|---|---|---|---|---|---|
| ngung_khi_thao | Ngưng Khí Thảo (qi-gathering grass) | Wood | 1 | 2 | Temperate forest, grassland | existing; Wood fallback | no |
| thanh_tam_lien | Thanh Tâm Liên (clear-heart lotus) | Water | 1 | 6 | Lake, swamp | existing; Water fallback | no |
| hoa_linh_chi | Hỏa Linh Chi (fire lingzhi) | Fire | 2 | 10 | Volcano edge, desert, jungle | existing; Fire fallback | no |
| hoang_tinh_sam | Hoàng Tinh Sâm (yellow-essence ginseng) | Earth | 2 | 20 | Highland, steppe | existing; Earth fallback | no |
| thiet_tuyen_thao | Thiết Tuyến Thảo (iron-thread grass) | Metal | 1 | 3 (mature 1 year) | High mountain, salt flats, bamboo forest | **new**; Metal fallback | no |
| xich_huyet_dang | Xích Huyết Đằng (red-blood vine) | Fire | 3 | 45 | Jungle, volcano | existing | maybe |
| bang_tam_thao | Băng Tâm Thảo (ice-heart grass) | Water | 3 | 60 | Tundra, glacier edge | existing | maybe |
| kim_tuy_qua | Kim Tủy Quả (golden-marrow fruit) | Metal | 4 | 150 | High mountain with an ore vein | existing | yes |
| van_nien_moc_linh | Vạn Niên Mộc Linh (myriad-year wood spirit) | Wood | 5 | 400 | Old temperate forest, high density | existing | yes |
| anh_tam_lien | Anh Tâm Liên (nascent-heart lotus) | Water | 5 | 900 | Lake at a spirit vein | existing | yes |
| hoa_than_qua | Hóa Thần Quả (deity-transformation fruit) | Fire | 6 | 3,000 | Volcano at a lava vent, very high density | existing | yes |

**Ores** (site: mine; resource kind: element ore; weight 5 each)

| id | Name | Element | Rarity | V | Land | Status | Likely specialty |
|---|---|---|---|---|---|---|---|
| tinh_thiet | Tinh Thiết (refined iron) | Metal | 1 | 15 | High mountain, salt flats, ore veins | existing; Metal fallback | no |
| xich_dong | Xích Đồng (red copper) | Fire | 2 | 30 | Volcano, desert | existing; Fire fallback | no |
| han_ngoc | Hàn Ngọc (cold jade) | Water | 2 | 35 | Tundra, glacier, karst peaks | existing; Water fallback | no |
| linh_moc_tam | Linh Mộc Tâm (spirit-wood heart) | Wood | 3 | 50 | Temperate forest, jungle, bamboo forest (petrified spirit-wood seams) | existing; Wood fallback | no |
| huyen_hoang_thach | Huyền Hoàng Thạch (dark-yellow stone) | Earth | 3 | 60 | Highland, badlands, karst peaks | existing; Earth fallback | no |
| tu_kim_sa | Tử Kim Sa (purple-gold sand) | Metal | 4 | 180 | Salt flats or desert with an ore vein, density ≥ 1.2 | **new** | yes |

**Beast parts** (site: beast lair; any element and biome)

| id | Name | Rarity | V | Weight | Status |
|---|---|---|---|---|---|
| yeu_cot | Yêu Cốt (demon-beast bone) | 1 | 10 | 2 | **new**; beast fallback |
| yeu_thu_bi | Yêu Thú Bì (demon-beast hide) | 1 | 12 | 3 | **new** |
| yeu_dan | Yêu Đan (demon core) | 2 | 40 | 1 | existing |

**Special goods** (site: spirit vein or feature)

| id | Name | Element | Rarity | V | Weight | Land | Status | Likely specialty |
|---|---|---|---|---|---|---|---|---|
| linh_tuyen_thuy | Linh Tuyền Thủy (spirit-spring water) | any | 1 | 8 | 2 | Spirit vein, hot spring | **new**; special fallback | no |
| dia_hoa_tinh | Địa Hỏa Tinh (earth-fire essence) | Fire | 3 | 80 | 1 | Lava vent, hot spring | **new** | yes |
| loi_kich_moc | Lôi Kích Mộc (lightning-struck wood) | Wood | 4 | 120 | 4 | Storm peaks over forest | existing | yes |

**Outside trade:** Linh Thạch Khoáng (spirit-stone ore, V 8) is linh thạch's raw form; it trades at P = 1.0 with
#43 Formula G's raw spread (buy 1.10, sell 0.90), with no local price, class, composition or scarcity factor (rule 4). Beast parts and special goods have no element, so each has one "any"
fallback (rule 3).

### States and Transitions

Availability of good g in market m, recomputed each tick:

| State | Condition | Effect | Next |
|---|---|---|---|
| **Source** | Own supply `S_own[m,g]` > 0 this season, and end value `X'` (= `sh · stock`, last tick) ≥ one unit (`V_g`) | Shelves stock it | Imported, Absent |
| **Imported** | No own supply, and pool value ≥ `V_g` | Shelves stock it | Source, Absent |
| **Absent** | Pool value < `V_g` | Not on shelves; the value is kept, outside the proportional draw and spoilage, and builds up (rule 6); the player may sell it here at the highest scarcity factor | Source, Imported |

A crafted class uses #43's market states: a crafted class in shortage makes the market Strained for that class.

### Interactions with Other Systems

| System | Direction | What passes |
|---|---|---|
| Regional Economy & Trade (#43) | in / out | In: class prices, local prices, stock and flows. Out: compositions, scarcity factors, the raw rarity bands (rule 8a), the crafted classes, the `craft_in` demand, and the amendments to rule 4 (and rules 9 and 19, Formulas C–G, I and L1) |
| Travel & Map (#25) | in / out | In: site kind, element, biome, density, herb fit, top rarity. Out: the site yield table and the contract's `by_good` split |
| Item Database | in / out | In: templates, values, the rarity ladder. Out: the `trade` block (`good_class`, `weight`, `source`), the crafted-origin rule, and a revised `pill_margin` lint (raw buy at 1.10, not 1.5) |
| Market (#20) | out | Named goods on shelves; the scarcity factor in shop prices |
| Alchemy, Artifact Refining, Talismans | in / out | In: recipes (a crafted class's inputs). Out: the craft plan as NPC workshop output |
| Sects & Missions (#26) | out | Workshop output; kind stipends in pills; Military's crafted demand |
| Codex (#12) | out | Discovered specialties (Discover setting) |
| Game UI (#37) | out | The scarcity line in the price breakdown; specialty map markers |

## Formulas

All values are **guesses** until the economy tick runs in the Balance Simulation Harness (#33). Units are base value, as in
Regional Economy & Trade (#43). A raw class is k = (kind, band) (herb, ore, beast, special by rarity band, rule 8a), a
crafted class is c = (kind, tier), and a named good is g; `k(g)` is the class of good g. Specialists consulted: `systems-designer` (formula forms), `economy-designer` (values, margins, money).

### A. Site yield (rules 5–6)

The site_yield formula is defined as:

`w[s,g] = fit[s,g] · ω^(rar_g − 1)`, or `fit[s,g]` alone for a herb of rarity `rare_min` or more at a blessed land
(phúc địa; user decision 2026-11-21: the blessed lands are where rare herbs are found, so commons do not dilute them) ·
`value_g[s] = value_lt[s,k] · w[s,g] / Σ_g' w[s,g']`, made into whole units by
largest remainder (floor every part, then give the leftover units one each to the largest fractional parts; ties go to
the lower `good_id`)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| fit[s,g] | float | 0.6–1 (herbs); 1 (other goods) | calculated (Travel & Map Formula G) | Herb fit at the site's part; a non-herb good that meets its `source` counts as 1 |
| rar_g | int | 1–6 | data file | The good's rarity (Item Database rule 7) |
| ω | float | 0.5 | data file *(guess)* | Weight per rarity step; rarer goods take a smaller part |
| rare_min | int | 4 | data file *(guess)* | At a blessed land, herbs of this rarity or more take weight `fit` (no ω) |
| value_lt[s,k] | int | ≥ 0 | Travel & Map Formula L | The site's value of kind k this season |

**Output Range:** whole numbers from 0 to `value_lt` that always sum to `value_lt` exactly. The fallback good (rule 3) is
eligible only when no other good is, and then counts as fit 1. Weights are computed in fixed point (× 10⁶, as integers)
so near-ties split the same way on every machine, and the parts are integer arithmetic: `(value_lt · w_i) div Σw`, with
remainders compared by cross-multiplication, never by float division. Gathered units are
`floor((value_g + rem[s,g]) / V_g)`; the value left over carries to the next season as `rem[s,g]` (rule 6), so a rare
good at a modest site yields a unit every few seasons instead of never.
**Example:** a herb site of `value_lt` 4,000 with Hỏa Linh Chi (fit 1.0, rarity 2: w 0.5), Ngưng Khí Thảo (0.7, rarity 1:
0.7) and Xích Huyết Đằng (0.8, rarity 3: 0.2). Σw = 1.4, so the raw parts are 1,428.57 / 2,000 / 571.43; the floors sum
to 3,999 and the leftover unit goes to Hỏa Linh Chi (fraction .571): **1,429 / 2,000 / 571**.

### B. Composition (rule 8)

The composition_update formula is defined as:

`X0[m,g] = sh[m,g] · stock[m,k] + S_own[m,g] + Σ_A Q[A→m,k] · ex[A,g] + sell_pl[m,g]` (inflows; `ex[A,g] = X_pre[A,g] / Σ_{g' shelved} X_pre[A,g']` for a good shelved at A, else 0: imports arrive in the proportions the exporter's draw took them, design-review 7) ·
`X[m,g] = max(0, X0[m,g] − cd[m,g] − buy_pl[m,g])` (good-specific outflows, before the shared draw) · the shared draw
(**exports first**, then spoilage, the rest of demand and the `s_cap` overflow) takes from **shelved** goods only (below),
giving the end-of-tick value `X'[m,g]`, floored at 0 after the draw (`X' = max(0, X')`: a rounding guard only; the proportional draw of a whole pool leaves values like −7e-15, which gave a share of −1 and a NaN sf in the tick test; AC-TG-52 checks the floor never trims more than 1e-9 of the good's inflow). **Exports take exactly `Exp[m,k] · ex[m,g]` from each shelved good** (`ex` by `X_pre`,
the split the importer was given), **not** a share of `X`; only what remains (spoilage, the rest of demand `max(0, D − craft_in)`, overflow; the `max` is design-review 10: #43's `P_eff` reaches −0.10 · `D_pre`, so in a market whose demand is mostly workshops `D − craft_in` can be negative, and unclamped it made `D_g` and fill negative and a negative `cd` or shared draw created value, up to 59,000 in the tick test) is
taken in proportion to the shelved goods' `X` left after exports. So a market that imports and re-exports a class still
moves each good's value out in the split the next market received (design-review 8). **The player's purchase is served first
and is bounded by the good's pre-draw value:** `buy_pl[m,g] ≤ v_g` (a purchase beyond it is refused at settlement), and the
workshops' draw is capped at what is left, `cd ≤ v_g − buy_pl` (Formula F) · a good that had **no inflow this season** (`S_own`, imports and `sell_pl` all 0)
and ends with `X' < dust · V_g` is set to 0 (the dropped value counts as spoilage; design-review 6, 2026-11-15, user: a
slow trickle under `dust · V_g` a season still builds) · `sh'[m,g] = X'[m,g] / Σ_g' X'[m,g']`, so `sh' · stock' = X'`;
if `Σ X' = 0`, every `sh'` is 0 (the pool is empty) · `stock_sh'[m,k] = Σ_{g: X'[m,g] ≥ V_g} X'[m,g]`, the **shelved
stock** (the value on next season's shelves). A good whose end value `X'` is under one unit (`V_g`) is **Absent** but
keeps its value, so it can build up (rule 6) *(design-review 1, 2026-11-14: the old form took exports at last tick's
shares and could go negative when exports exceeded stock; design-review 4, 2026-11-15: shares are taken from the end
value `X'`, after the draw)*

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| sh[m,g] | float | 0–1 | calculated (last tick) | The good's share of its class pool in market m |
| S_own[m,g] | float | ≥ 0 | calculated: `h_f · Σ_r value_g[r] · acc_r` (#43 Formula B) | The market's own supply of g |
| Q[A→m,k] | float | ≥ 0 | #43 Formula F | Imports arrive split by the exporter's export shares `ex[A,g]` (its shelved goods by `X_pre`), the same split its capped draw takes them in, so each good's value leaves one market and arrives in the other exactly (design-review 7; the old last-tick shares included unshelved goods, which the draw never touched) |
| cd[m,g] | float | ≥ 0 | F | The workshops' draw of good g this season (`need[m,g]` × the class's slot fill `fill_c`) |
| sell_pl, buy_pl | float | ≥ 0 | the player's trade ledger | The player's sales and purchases of g in the market this season, at held value (an aged herb at its `herb_value`, Formula K) |
| dust | float | 0.01 | data file *(guess)* | Below this fraction of a unit, the pool value of a good with no inflow this season is dropped |
| stock_sh[m,k] | float | ≥ 0 | calculated (this tick's end values) | Shelved stock: the end value of the class's goods at one unit or more; what #43's price, cover and link flows read |
| X_pre[m,g] | float | ≥ 0 | calculated (step c) | `v_g − cd − buy_pl` with `v_g = sh · stock + S_own + sell_pl` (the good's value before the craft draw, Formula F): a good's value before link flows, known before step (d). `buy_pl ≤ v_g` (player first) and `cd ≤ v_g − buy_pl` (Formula F), so `X_pre` is never negative and the `max(0, ·)` in `X` never hides a draw the pool cannot meet; the `max` stays as a guard only *(design-review 7 and 8: the review-7 claim ignored `buy_pl`)* |

**Shelved and unshelved goods** *(design-review 3, 2026-11-14, user; timing fixed in design-review 4, 2026-11-15)*: a
good is **shelved** in a tick when **last tick's end value** `X'_prev[m,g] ≥ V_g`, that is, when it was on the shelves
the season just played (a good with no history starts unshelved). The shared draw (spoilage `dk`, exports, the rest of
demand and the `s_cap` overflow) takes only from shelved goods, in proportion to their X, so an unshelved good keeps
all of its X. The draw is **capped at the shelved value** *(user decision 2026-11-15, design-review 5)*: the shared draw
`= min(#43's spoilage + exports + demand + overflow, Σ_shelved X)`, taken in proportion from the shelved goods. What the
cap leaves undrawn (nothing shelved, or too little) is unmet demand and unspoiled stock: it stays in the pool and **no
unshelved good is ever touched**. The class's ledger stock `stock'` is the sum of the end values `Σ X'` (shares are taken
from it), but **#43's price (Formula E), cover and link flows (Formula F) read the shelved parts**, `stock_sh` and the
shelved goods' supply *(user decision 2026-11-15, design-review 6)*: a class whose goods are all under one unit reads as
short, so its price rises and it pulls in imports, instead of looking full while its shelves are empty. **Exports always
fit** *(user decision 2026-11-15, design-review 6)*: #43 Formula F's `avail_A` reads shelved value only,
`avail_A[k] = max(0, Σ_{g shelved} X_pre[A,g] − max(0, D_A − craft_in_A))` (the inner `max` is design-review 10: #43's `P_eff` reaches −0.10 · `D_pre`, so a player selling into a market whose demand is mostly workshops makes `D_A − craft_in_A` negative and `avail_A` would exceed the shelved value) (the craft draw is already out of `X_pre`), and
exports are taken first in the capped draw. Since imports only add to a shelved good's X, exports never exceed the
shelved value, so the importer receives exactly what left the exporter, and the cap only ever trims demand, spoilage
and overflow. **Workshops and the player draw only shelved value** *(user, design-review 4)*: `cd` and `buy_pl` of an
unshelved good are 0 (its `fill_g` is 0, Formula F), so crafting cannot drain a rare good before it reaches a shelf. A
good's value therefore builds linearly, `v' = v + s`, until its end value reaches one unit; it is then on the shelf for
the next season and shelved in the next tick. Once shelved, the proportional draw takes about 73 % of it at #43's rest
state, so a rare good appears on a shelf in a **sawtooth** (it builds for about `V_g / s` seasons, is on the shelf for
one season, is drawn down in the next tick, and builds again), not continuously. This is intended: rarity 5–6 goods
are intermittent. Without the end-value timing, a good reaching `V_g` would be drawn the same tick and end at about
0.27 `V_g`, Absent, so it would need about 2.7 × `V_g` of inflow in one season to ever show.

**Output Range:** each share 0–1, summing to 1 (or all 0), taken from the end values `X'`. With every good shelved (the usual case for cheap goods),
the rest of demand, spoilage and the overflow take from every good in proportion, so they leave shares
unchanged; **exports take each good at its `X_pre` export share `ex`, not its `X` share, so they move shares whenever imports or
sales have made `X` differ from `X_pre`** (design-review 9: the old sentence still counted exports as proportional); the craft draw and the player's purchases take specific goods. Unshelved goods raise their share
slowly (the rule above). Every market reads its
exporters' **export shares** `ex[A,g]` (from `X_pre`, known before the flows), and `wsh_g` (D) is computed after every market's B, so the order markets are processed in
never changes the result.
**Example:** stock 3,000 (Hỏa Linh Chi share 0.2), own supply 14,463 (Hỏa Linh Chi 1,500), an import of 859 at the
exporter's export share 0.5, and the player sells 120: X = 600 + 1,500 + 429.5 + 120 = 2,649.5; ΣX = 18,442; **sh' = 0.1437**.

### C. Specialty (rule 7)

The specialty formula is defined as:

`prod[r,g] = (value_g[r] ≥ max(V_g / 16, θ_s · max_r' value_g[r']))` · `N_g = Σ_r prod[r,g]` · `specialty_g = (1 ≤ N_g ≤ N_spec)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| value_g[r] | int | ≥ 0 | A, summed over the region's sites | This season's output of g in region r |
| θ_s | float | 0.10 | data file *(guess)* | A region counts only if it makes at least this fraction of the top region's output |
| V_g | int | ≥ 1 | Item Database rule 9 | One unit: the region must make at least one unit every four years (`V_g / 16` a season; remainders carry, rule 6). Design-review 2 (2026-11-14, user): was `V_g / 4`, which put Hóa Thần Quả's bar at 750 a season so the rarest goods could never be specialties |
| N_spec | int | 3 | data file (user decision 2026-11-14) | Most regions a specialty may have |

**Output Range:** true or false. The threshold is relative to the top region, not the world total, so a good spread
thinly over many regions still counts as produced. A good with N_g = 0 is unproduced, not a specialty.
**Example:** Băng Tâm Thảo making 2,400 / 900 / 300 / 150 / 40 in five regions: the threshold is 240, three regions
pass, and it is a **specialty**.

### D. Scarcity factor (rule 9)

The scarcity_factor formula is defined as:

`w_g = max(wsh_g, wsh_min)` · `sf_raw[m,g] = ((sh[m,g] + σ · w_g) / ((1 + σ) · w_g))^(−η)` ·
`sf[m,g] = sf_raw[m,g] / Σ_{g' shelved} (X'[m,g'] / stock_sh[m,k]) · sf_raw[m,g']` (normalised so the share-weighted mean of the
goods on the shelf is 1; with every good shelved this is the pool's share-weighted mean, design-review 6). **The shop always uses the normalised sf**;
the raw share-0 limit `((1+σ)/σ)^η` applies only where there is nothing to normalise against: no shelved good (`stock_sh` = 0), or
`wsh_g = 0` (the good exists nowhere, for example a looted good or an old save's) · `wsh_g = Σ_m stock_k[m] · sh[m,g] /
Σ_m stock_k[m]` (if the class has no stock anywhere, `wsh_g` keeps last season's value); every world sum (`wsh_g`, its denominator, and any other sum over markets) is taken in **market-id order**, never processing order, so floating-point results are bit-identical whatever order markets run in (design-review 10: summing in processing order changed sf by 2e-16 and broke AC-TG-11). Crafted classes have
no composition, and their sf is 1

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| wsh_g | float | 0–1 | calculated | The good's share of the world's class pool |
| σ | float | 0.12 | data file *(guess)* | Softening term: keeps sf finite where the market has none |
| η | float | 0.18 | data file *(guess)* | How strongly price answers a good's scarcity; the harness sets it in 0.10–0.18 against AC-RE-49 and AC-TG-35 |
| wsh_min | float | 0.005 | data file *(guess; user decision 2026-11-14, design-review 1)* | Floor on the world share, so a nearly vanished good has no jump (as `wsh_g` → 0 with `sh` > 0 the raw factor fell toward 0, then jumped to 1.49 at 0) |

**Output Range:** no clamp on the factor; the bounds come from σ, η and `wsh_min`. Before normalising: **1.49** where the
good is absent (share 0: `((1+σ)/σ)^η`, whatever `w_g`) and **0.80** at a source market holding 3.75 × the world share.
The low end is reached by a market that holds all of a good: `((1/f + σ)/(1+σ))^(−η)`, with f the market's share of the
world's class stock, so **0.72** at f = 1/7, **0.50** at f = 0.02 and **0.39** at the floor. **After normalising** the
range is wider: an absent good in a pool dominated by one locally plentiful good (share 0.9 at world share 0.02) gets
about **2.66**. That tail is the route risk; η is its lever, set in the harness. Normalising keeps each class pool's
share-weighted mean at 1, so the pool's value at the class price is unchanged *(user decision 2026-11-14)*; a player who
picks the cheapest good inside a class still pays less than the class price for it. One good per class gives sf = 1. Slippage stays per
class (#43 G).
**Example:** a herb band-2 class of Băng Tâm Thảo (world share 0.04) and Xích Huyết Đằng (0.96). At its source (shares
0.15 / 0.85): raw 0.800 and 1.020, pool mean 0.987, so **Băng Tâm Thảo 0.811** and Xích Huyết Đằng 1.033. In a market with none
(Xích Huyết Đằng 1.0): raw 1.495 and 0.993, mean 0.993, so **Băng Tâm Thảo 1.505** and Xích Huyết Đằng 1.000. It sells
about 1.86 × higher where it is absent than at its source, before local prices and travel.

### E. Crafted classes (rule 11)

The crafted_class formula is defined as:

`tier = 1 + #{e ∈ band_edges : e < V_q0}` · `D_min[c] = max(V_lo[tier], 0.05 · D_cal[m,c])` (for price cover and the
stock cap only; the plan has its own floor, Formula F) · price, stock and cover by
#43 Formulas D and E with the parameters below. There is no `d_scale`: the calibration tool solves the plan at rest
instead, `plan_ref[m,c] = D_cal[m,c] · (1 + dk[c] · (c_ref[c] − 1))`, with starting stock `c_ref · D − S` (#43 Formula C's
steady state)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| band_edges | int[] | 20, 150, 1,500, 8,000, 60,000 | Item Database Formula A (`pill_band_edges`) | Value bands; tiers 1–6 |
| V_q0 | int | ≥ 1 | Item Database Formulas C, D | Value at quality 0 (a pill's recipe price; an artifact's or talisman's own value), so quality never moves an item to another class |
| V_lo[tier] | int | 1 / 20 / 150 / 1,500 / 8,000 / 60,000 | constant (the band floors) | Demand floor of about one item, so one sale cannot crash a high-tier class |
| D_cal[m,c] | float | ≥ 0 | calibration tool | Season-0 demand of class c in market m |

| Kind | dk | s_cap | c_ref | ε | P_min | P_max | P_maxeff | δ |
|---|---|---|---|---|---|---|---|---|
| pill | 0.05 | 3 | 1.5 | 0.7 | 0.6 | 1.8 | 2.5 | 1.15 |
| talisman | 0.03 | 3 | 1.5 | 0.7 | 0.6 | 1.8 | 2.5 | 1.20 |
| artifact | 0.01 | 6 | 2.0 | 0.6 | 0.7 | 1.6 | 2.2 | 1.10 |

*(All guesses; user decision 2026-11-14: narrower than raw goods' bands, because the craft plan already pulls prices
toward cost.)* The P_min / P_max / P_maxeff bands are #43 Formula E's price bands, inherited on purpose; the plan itself
has no cap (Formula F).

**Output Range:** tiers 1–6. Classes that occur: pills 1–5, artifacts 1–6, talismans about 1–4, so **about 15**. Prices
run from P_min to P_max (P_maxeff while Strained).
**Example:** Trúc Cơ Đan (recipe price 400) is above two edges (20, 150): **tier 3**.

### F. Craft plan (rule 12)

The craft_plan formula is defined as:

`r = P[m,c] / Σ_g a[c,g] · P[m,k(g)] · sf[m,g]` · `plan* = plan_ref[m,c] · r^κ · (c_ref[c] / max(c[m,c], c_lo))^λ_c` ·
`plan' = clamp(p̂ · (plan*/p̂)^α_p, p̂/δ_p, p̂ · δ_p)`, with `p̂ = max(plan, φ_p · plan_ref[m,c])`; if `plan_ref = 0` the
plan is 0 and no floor applies · then `plan_ref' = plan_ref + ρ_ref · (D[m,c] − plan_ref)`, this season's demand (user
decision 2026-11-21: workshops follow lasting demand; calibrated on season 0's upkeep-only spending, plan_ref sat at a
third to a sixth of live Military demand, and the plan cannot pass about 2 × plan_ref) ·
`v_g = sh[m,g] · stock_k + S_own[m,g] + sell_pl[m,g]`, k = k(g) (the good's own value in this market before the craft draw, exactly Formula B's pre-draw value, so `cd ≤ v_g − buy_pl ≤ v_g ≤ X0` and workshops never draw value the pool does not hold; design-review 7: the old `sh · (stock_k + S_k)` spread the class's supply by last-tick share) ·
`fill_g = min(1, (v_g − buy_pl[m,g]) / D_g)` (the player's purchase is served first, so workshops are measured against what is left; design-review 8) with `D_g = need[m,g] + (v_g / Σ_{g' shelved, k(g')=k} v_g') · max(0, D_k − craft_in[m,k])`: the
rest of the class's demand falls on **shelved goods only**, in proportion to their value, as Formula B draws it
(design-review 6; with every good shelved this is the old `sh`-weighted split) (`fill_g` = 1 if `D_g` = 0; the plan rises only when `fill_c ≥ fill_tol` = 0.95, design-review 10; **`fill_g` = 0
and `D_g` = 0 if g is unshelved**, Formula B, design-review 4) · **slot groups** *(user decision 2026-11-15,
design-review 5)*: an "any material of rarity r or more" slot is one group Γ of substitutable goods, drawn **from the
goods on the shelf here**: `fill_Γ = min(1, Σ_{g∈Γ, shelved} (v_g − buy_pl[m,g]) / Σ_{g∈Γ, shelved} D_g)` (1 if that `Σ D_g` = 0; 0 if no
good of Γ is shelved); a group may span raw bands (rarity 2 or more spans ore 1 and ore 2), and each good's `v_g` and
`D_g` read its own band. A group's `need` spreads over its shelved goods by what is left of each after the player's purchase, `v_g − buy_pl[m,g]`
(by `wsh_g` only if none is shelved or that sum is 0, so the demand is still priced), not by `v_g` or by `wsh_g` over all eligible goods. So `cd[g] = need_Γ · (v_g − buy_pl) / Σ(v − buy_pl) · fill_Γ ≤ v_g − buy_pl` for every good, because `fill_Γ ≤ Σ(v − buy_pl) / need_Γ`; a purchase concentrated in one good can no longer push the draw past it (design-review 9: spreading by `v_g` let `cd` exceed `v_g − buy_pl` and the `max(0, ·)` hid the value created). A named-good slot is a group of one ·
`fill_c[m,c] = min over the class's slots of fill` · **draw scale** *(design-review 10, checked by property test)*: with `cd_raw[g] = Σ_c need[c,g] · fill_c` (group goods by their spread share), each class's fill is lowered to `fill_c := fill_c · min_{g drawn by c, cd_raw[g] > 0} min(1, (v_g − buy_pl[m,g]) / cd_raw[g])` (1 if no such g); this holds `cd[g] ≤ v_g − buy_pl` for every good **by construction, whatever the slots** (named, groups, nested or overlapping groups, several classes: each good's draw is at most `cd_raw[g] · min(1, (v_g − buy_pl) / cd_raw[g])`), and it only ever lowers output, so no value is created. The per-shape bounds above make it rarely bind; it is the guarantee, not they. Every `Σ_c` here and in Formula G runs in **crafted-class id order**, so the floating-point result is bit-identical on every machine and run (AC-TG-11, AC-TG-38) · from here on `fill_c` means the **post-scale** fill: `out[m,c] = plan[m,c] · fill_c` (crafting competes with other buyers
for the goods it needs, and a workshop never makes goods from nothing) · `cd[m,g] = Σ_c need[c,g] · fill_c` over the crafted classes that use g (the draw, into
Formula B; with one class this is `need[m,g] · fill_c`; for a group's goods `need` is the group's spread share) · **no windup** *(user decision 2026-11-15, design-review 6; tolerance design-review 10)*: if this season's `fill_c` < `fill_tol` (0.95, data file *(guess)*), `plan' ≤ plan`
(the plan update may fall or hold, never rise), so a class whose named input is off the shelf does not climb by δ_p every
season it cannot make anything ·
`S_fin[r,c] = out[m,c] · sw_r / Σ_r' sw_r'` (all at the seat if Σ sw = 0) · `S[m,c] = Σ_r S_fin[r,c] · acc_r + sells + Imp − Exp`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| a[c,g] | float | 0–1, summing to 1 | data file (from recipes) | Share of the class's input value drawn from good g; an "any material of rarity r or more" slot is a group; its share spreads over the group's shelved goods by available value each season, not by `wsh_g` |
| need[m,g] | float | ≥ 0 | G | Inputs the full plan would use (Formula G); what the fill is measured against |
| fill_c[m,c] | float | 0–1 | calculated (step c) | This season's slot fill of the class; read by the plan update (f) and by next season's `craft_in` (G) |
| fill_tol | float | 0.95 | data file *(guess; design-review 10)* | Slot fill at or above which the plan may rise; below it `plan' ≤ plan` (no windup). A tolerance, not 1, so float rounding or a tiny shortfall does not freeze the plan |
| plan_ref | float | ≥ 0 | E (calibration), then drifts (F) | The plan at rest |
| ρ_ref | float | 0.05 | data file *(guess)* | Share of the gap between demand and plan_ref closed each season (half-life about 3.5 years) |
| c[m,c] | float | ≥ 0 | #43 Formula E (this season's (e)) | The class's cover, `(stock + S) / max(D, D_min)` |
| κ | float | 0.5 | data file *(guess)* | How strongly the plan answers the price ratio |
| λ_c | float | 0.5 | data file *(guess; user decision 2026-11-14, design-review 1)* | How strongly the plan answers cover: damps the stock loop |
| c_lo | float | 0.1 | data file *(guess)* | Cover floor in the damping term, so an empty class gives a finite plan* |
| α_p | float | 0.3 | data file *(guess)* | Inertia: share of the gap to plan* closed in a season |
| δ_p | float | 1.15 | data file *(guess)* | Largest move a season (a rate limit, like #43 E's δ) |
| φ_p | float | 0.05 | data file *(guess; design-review 1)* | Plan floor as a share of the plan at rest; replaces `D_min`, which forced a tier-6 class to plan about 54,000 a season in a market with almost no demand |
| sw_r | float | ≥ 0 | Travel & Map L | Summed settlement weight of the region's crafting places |

**Output Range:** the plan has no cap of its own. The price term lies within `plan_ref · [(P_min,c / P_maxeff,in)^κ,
(P_maxeff,c / P_min,in)^κ]`, for pills with herb inputs **0.45–2.24 × plan_ref**; the cover term multiplies it by
`(c_ref / c)^0.5`, about 0.61 at a pill class's full store (cover 4) and 3.87 at the `c_lo` floor, and δ_p bounds each
season's move. The floor p̂ keeps a plan from dying at 0. **Stability is not claimed from a loop gain**: stock carries
the plan over, so the loop is second-order (design-review 1; the earlier "loop gain 0.105" argument left that out). The
cover term damps it: in a one-market sketch (fixed demand, inputs at P 1, #43 D and E with this table's parameters), a
glut at `s_cap` halves its price gap in about **12 seasons** for pills and artifacts (28 for artifacts without the
term), with at most one swing above 1 %. AC-TG-36 tests it in the harness.
**Example:** a tier-3 pill plan of 2,000 (= plan_ref), pill price 1.30, inputs 0.8 Hỏa Linh Chi at P 1.0 and 0.2 Xích Đồng
at P 1.1 (both sf 1), cover 1.5 (= c_ref): r = 1.30 / 1.02 = 1.2745, plan* = **2,257.9**, plan' = 2,000 · 1.12894^0.3 =
**2,074.1** (δ_p does not bind). At cover 3.0 the cover term is 0.7071: plan* = **1,596.6** and plan' = **1,869.3**.

### G. Craft input demand (rule 13)

The craft_in formula is defined as:

`need[m,g] = Σ_c plan[m,c] · a[c,g] / (μ_c · ps_c)` (the full plan's inputs) · `craft_in[m,g] = Σ_c plan[m,c] ·
fill_c,prev[m,c] · a[c,g] / (μ_c · ps_c)` (the demand, scaled by last season's slot fill, 1 at season 0; design-review 6,
user: demand follows what workshops could actually make, so an input that is off the shelf adds no unfillable demand) ·
for an "any material of rarity r or more" slot `a[c,g]` is the group's share spread over its shelved goods by `v_g − buy_pl[m,g]`, as in Formula F (not a static datum) · `craft_in[m,k] = Σ_{g: k(g) = k} craft_in[m,g]`, added to #43 Formula C's D and, split by `sw_r`, to L1's `D_r`;
`d_scale` is then re-solved (AC-RE-51). An aged input counts at its `herb_value(min_age)` in mature units

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| μ_c | float | > 0 (usually ≥ 1) | calculated from recipes | Output value over input value at quality 0; a recipe with margin below 1 (Formula J, own-use) gives μ < 1 and draws more input than it makes in value |
| ps_c | float | 0.8 | data file *(guess)* | Workshop success rate |

**Output Range:** ≥ 0; 0 when the plan is 0, and `craft_in` is 0 after a season at fill 0 (`need` is not). Craft input
demand is in goods only: workshops draw their inputs in kind, and no money moves (Money, below).
**Example:** a plan of 2,000 with μ 2.5 and ps 0.8 needs 2,000 · 0.8 / 2.0 = **800 of Hỏa Linh Chi** (herb band 1) and
**200 of Xích Đồng** (ore band 1); at last season's fill 1 that is also its `craft_in`, and at last season's fill 0.5 its
`craft_in` is 400 and 100.

### H. Crafted demand (rule 14)

The crafted_demand formula is defined as:

`D[m,c] = D_bask + D_bt + D_mil + P_eff[m,c]` ·
`D_bask[m,(pill,t)] = Σ_rl [tp(rl) = t] · n[m,rl] · basket[rl] · bmix[pill] · fill[m,rl]` ·
`D_bt[m,(pill,t)] = Σ_rl [tp_bt(rl) = t] · n[m,rl] · bt_rate[rl] · V_bt[rl]` ·
`D_mil[m,c] = goods_frac · spend_Mil · mil_cr[kind] · ω_t`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| bmix[pill] | float | 0.10 (herb drops from 0.5 to 0.40) | data file *(guess)* | Pill share of the provision basket; raise to 0.15 only if the calibrated herb `d_scale` stays at 2.4 or less |
| tp(rl) | int | Luyện Khí → 1 … Hóa Thần → 5 | data file | The pill tier each realm's basket buys |
| bt_rate[rl], V_bt[rl], tp_bt(rl) | float, int | ≥ 0 | Realms & Bottlenecks *(handoff)* | Share attempting a breakthrough this season, the value and tier of its breakthrough pill |
| mil_cr[kind] | float | artifact 0.2, talisman 0.1 | data file *(guess)* | Part of Military's goods spending moved to crafted goods; its ore and beast mix (#43 C) is scaled by 0.7 |
| ω_t | float | 0–1, summing to 1 | calculated: heads × basket by tier | How Military's crafted spending spreads over tiers |
| spend_Mil | float | ≥ 0 | Regional Economy C (`spend_T`, T = Military) | The mean of the last `mil_window` committed seasons of Military spending (fewer at the start of a game): Sects F19 invests in one track a season, so one season's value swings about four-fold (user decision 2026-11-21) |
| mil_window | int | 4 | data file | Seasons averaged |
| kind_pill | float | `min(kind_stipend, bmix[pill])` = 0.10 | calculated | Share of a member's stipend paid in pills; #43's `kind_stipend` (15 %) keeps its total, the other 0.05 stays in herbs |

**Output Range:** ≥ 0. Kind pills sit inside the members' basket term: they change who pays (the sect instead of the
member), not total demand. Pills have no `sub_floor`. A head's pill share worth less than one pill accrues as credit and is
delivered as a whole pill once the credit covers one.
**Example:** 130 Foundation Establishment heads × basket 20 × 0.10 = **260 a season** of tier-2 pills. Military spending
1,000 (goods half 500) gives artifacts **100**, talismans **50**, ore 0.6 · 0.7 · 500 = **210** and beast **140** *(amends
#43 AC-RE-11's ore +300 and beast +200)*.

### I. Origin of a crafted item (rule 15)

The crafted_origin formula is defined as:

`origin = origin_market of argmax_i (V_i · q_i)` over the inputs as held (herb potency included). On a tie, tied inputs
that share one origin give that origin; tied inputs with different origins, or untagged inputs, give the crafter's market;
a crafter in a region with no market takes the lowest market id among the tied inputs

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| V_i, q_i | int | ≥ 1 | Item Database | Value and quantity of input i |

**Output Range:** one market id. The item's `P_eff`, `slip` and `q_sold` count against its own crafted class (amends #43
Formula G).
**Example:** 2 Hỏa Linh Chi (V 10, tagged A) and 5 Ngưng Khí Thảo (V 2, tagged B): 20 against 10, origin **A**.

### J. Craft margin lint (user decision 2026-11-14; replaces the Item Database `pill_margin` check)

The craft_margin formula is defined as:

`margin = (sr_fin · V_out · yield · ps_mean) / (bm_raw · Σ_i V_in,i · q_i)` · `profit = sr_fin · V_out · yield · ps_mean −
bm_raw · Σ_i V_in,i · q_i` (per brew), at P = 1 and local price = P, each herb input at the lowest age step a held herb can have that is at least its recipe's
`min_age` (ages are `mature_years · 2^j`, Formula K: Kim Tủy Quả at `min_age` 84 is priced at 100, value 225, not at
`herb_value(84)`); with `Σ V_in,i · q_i` = 0 the lint skips the recipe and warns

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| sr_fin, bm_raw | float | 0.6; 1.10 | #43 Formula G | Finished-goods sell ratio; raw-goods buy factor |
| V_out | int | ≥ 1 | Item Database Formulas C, D | Value of the output at quality 0 |
| yield | int | 1–2 | data file (recipes) | Items per brew |
| margin_warn_profit | int | 600 | data file *(guess; one Core Formation mission's pay)* | Profit per brew below which a high margin does not warn (a cheap pill's high ratio earns too little to matter) |
| ps_mean | float | 0–1 | Alchemy / Refining | Mean success at the recipe's intended level |

**Output Range:** target **1.2–2.0**. The data load warns when the margin is above 2.5 **and** the profit per brew is at
least `margin_warn_profit` *(user decision 2026-11-14: warn on profit too)*. Below 1.0 a recipe never pays to craft for
sale (allowed for recipes meant for one's own use).
**Example** (at ps_mean 1): the shipped Ngưng Nguyên Đan 5.38 (+1,466 a brew), Tẩy Tủy Đan 9.74 (+1,346) and Diên Thọ Đan
4.96 (+2,395) warn. **Decided 2026-11-14 (user): raise their inputs and keep their prices**: Ngưng Nguyên 4 Kim Tủy Quả at
age 84 + 1 Xích Huyết Đằng at 18 (**1.73**: inputs 4 × 225 + 45 = 945, 0.6 · 3,000 / (1.10 · 945); an earlier 1.89 priced Kim Tủy Quả at `herb_value(84)`); Tẩy Tủy 4 Xích Huyết Đằng at 80 + 3 Băng Tâm Thảo at 120 (**1.89**); Diên
Thọ 2 Vạn Niên Mộc Linh at 200 + 1 Kim Tủy Quả at 100 (**1.91**). Tụ Khí Đan 3.27 (+10), Thanh Độc Đan 3.64 (+17) and Hoàng
Long Đan 2.81 (+70) are above 2.5 but earn too little to warn, so with the revised recipes no recipe warns. Herbs older
than `mature_years` are never on a shelf (rule 10): they come from wild gathering (Formula K) or fields, and the lint
prices them at their held value, as a craft that uses them consumes that value.

### K. Wild herb age (rule 10; user decision 2026-11-14, design-review 1)

The wild_herb_age formula is defined as:

`q[s] = min(q_max, q_base · dens[s] · (1 − acc_r))` · each unit gathered at herb site s draws an age step `j ≥ 0` with
`P(j ≥ n) = q[s]^n`, from the seeded stream (world seed, site, season, good, unit index) · `age = mature_years · 2^j`,
fixed from then on; its value is Item Database Formula B's `herb_value(age)` (potency 1 + 0.5 j)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| q_base | float | 0.15 | data file *(guess)* | Old-herb rate on ground of density 1 that no one reaches |
| q_max | float | 0.5 | data file *(guess)* | Highest chance of each further doubling |
| dens[s] | float | 0.3–3.0 | Travel & Map (land density at the site) | Denser ground grows older herbs |
| acc_r | float | 0–1 | #43 Formula A | The region's market access: well-reached ground is picked young |

**Output Range:** `q` 0–0.5; the share of units at step n or more is `q^n`, so ages have no cap of their own (potency is
bounded by Item Database's `max_potency` 5, step 8). Only player and NPC gathering draws ages; the commons' harvest
(#43 Formula B) enters pools at `mature_years`, so pools never hold aged herbs.
**Example:** density 1.0, access 0.5: q = 0.075, so **7.5 %** of units are ×2 or older and **0.56 %** ×4. Remote dense
ground (density 1.5, access 0.1): q = 0.2025, so **20.3 %** ×2, **4.1 %** ×4 and **0.83 %** ×8. The revised recipes
(Formula J) need step 1 for Kim Tủy Quả at 84 (mature 50) and Vạn Niên Mộc Linh at 200 (mature 100), and step 2 for Xích
Huyết Đằng at 80 (mature 20) and Băng Tâm Thảo at 120 (mature 30).

### Money (amends #43 Formula H)

- **Workshop output is in kind.** It enters the crafted pool as goods, and craft inputs are drawn in kind. Only real
  buyers move cash (baskets, `Buy_short`, Military's shortfall, the player and NPCs), paid to the market's commons pool.
  Crafting creates goods value, never money *(user decision 2026-11-14)*.
- **A sect's workshop share** first meets its own kind pills and Military use; the rest joins the market pool.
- **A single crafted sale larger than the commons pool's balance** is paid only up to that balance (as #43 Formula K).

### Tick placement (#43 rule 19)

| Formula | Step | No-circularity check |
|---|---|---|
| A | World generation and site-layer changes; the split runs in Travel & Map's production | Reads only layers and fit |
| C | (a) | Reads this season's contract `by_good` |
| F (placement), G, H | (c) | Use the plan set in last season's (f), and last season's `fill` and spending |
| B, D, E | (e), after (d)'s flows | B reads (d); D reads B |
| F (plan update) | (f) | Reads (e)'s prices and this season's `fill_c` (set in (c)); first used in the next season's (c) |
| I, J, K | At craft time; at data load; at gather time | Outside the tick |

**Boundary checks:** an empty pool gives every share 0 (Absent); zero crafted demand leaves cover finite through D_min,
the price falls to P_min and, while `plan_ref` > 0, the plan falls toward `φ_p · plan_ref`, not 0 (with `plan_ref` = 0
the plan is 0, Edge Cases); share 0 gives a finite sf (1.49 raw); one good per class takes all of `value_lt` with sf = 1.

**#43 amendments these formulas need** (all applied to #43: those of 2026-11-14 then, the design-review 1–10 ones on 2026-11-15, Open Question 14):
rule 4 (crafted classes; **raw classes by rarity band**, rule 8a, design-review 1, applied 2026-11-15); Formulas C–E (**per-band
demand split by season-0 world supply share, per-band `D_min`**, applied 2026-11-15); Formulas D, E and F (**price, cover and `avail_A`
read the shelved stock; exports first in the draw**, design-review 6; **`avail_A` and the rest of demand clamp `D − craft_in` at 0, and every world sum runs in market-id order**, design-review 10; applied 2026-11-15); rule 9 and Formula C (`craft_in`, crafted demand, `bmix` herb 0.40); rule 19 (new parts of
steps a, c, e, f); Formula E (crafted parameters); Formula G (crafted class keys, the scarcity line); Formula H (in-kind
workshops, crafted-sale lines); Formula I (`kind_stipend` split); AC-RE-11 (the Military split).

## Edge Cases

Drafted with `systems-designer` (2026-11-14); the changes it needed in rule 3 and Formulas A, B, D, F and I are applied.

**Zero and limits**
- **If `value_lt[s,k]` is 0**: every part is 0 and the largest-remainder step is skipped.
- **If no good but the fallback is eligible at a site**: the fallback takes all of `value_lt` at fit 1 (rule 3), so
  Formula A never divides by zero.
- **If a good's pool value falls below one unit** (`sh · stock < V_g`): the good is **Absent** but keeps its value, which
  builds up again and loses nothing while under one unit (demand, exports, overflow and spoilage skip it, Formula B);
  only a good with no inflow this season that ends below `0.01 · V_g` is dropped, as spoilage, so a trickle of any size
  still builds. Its class's price reads only the shelved stock, so a class with nothing on the shelf reads as short. At a steady inflow `s` it is shelved after about `V_g / s`
  seasons, so Hóa Thần Quả at 200 a season is shelved every 15 seasons, then drawn down by the proportional draw.
- **If a rare good sits at a modest site**: the site carries the remainder (`rem[s,g]`, rule 6), so Hóa Thần Quả at a
  part of 200 a season yields one unit every 15 seasons, not never (and the region counts as producing it, Formula C).
- **If a class pool holds one good**: sf = 1; the specialty label still applies.
- **If the player holds a good that exists nowhere** (`wsh_g` = 0: loot, an old save): it is priced at the share-0 limit,
  1.49 (Formula D).
- **If a class has no stock anywhere**: `wsh_g` keeps last season's value, and `wsh_min` applies (Formula D).
- **If a crafted class has no demand anywhere** (`plan_ref` = 0): its plan is 0 and no floor applies (Formula F).

**Politics**
- **If a region changes holder**: it takes effect at tick step (b) (#43 rule 19). Its stock enters Formula B as an import
  at the old market's export shares `ex` (shelved goods by `X_pre`), and the old market loses exactly that per good, as for a link, and each crafted class's plan and `plan_ref` move in proportion to the region's crafting
  settlement weight `sw_r`.
- **If a market falls**: each victor receives the fallen market's stock at its composition, its crafted pools and a share
  of its plans in proportion to the `sw` it gains; the fallen sect's kind pills end.
- **If a market is embargoed**: only its own land feeds its composition (Imp = Exp = 0); its stock still counts in
  `wsh_g`.

**The player**
- **If the player sells a good that is Absent in a market**: they get last tick's normalised sf (about 1.5, Formula D); only
  per-class slippage and `player_cap` limit the sale. The sale enters `sell_pl`, so next season the good is Imported there.
- **If the player sells an aged herb**: it is paid at its held value (`herb_value`), and `sell_pl` counts that value; it
  joins the pool as value, since pools hold herbs at `mature_years` only. Shelf herbs are always sold at `mature_years`.
- **If a herb past a recipe's `min_age` is used**: it is consumed at its held value; its potency counts toward the main
  input (Formula I); no refund.
- **If the player holds herbs**: a harvested herb never changes value, carried or stored (rule 10), so holding earns
  nothing. Only planted herbs age (Item Database, Planted).
- **If the player gathers old herbs**: Formula K's draw is seeded, so the same gather gives the same ages on every run.
  Old herbs are gathering income, bounded by `q` and the band's slippage when sold.
- **If a good's specialty label flips while it is carried**: prices do not change (the scarcity factor reads shares, not
  the label). Under the Discover setting the Codex keeps the entry, marked "former".
- **If gathered, looted or crafted goods would exceed the carry capacity** (rule 16a): the player chooses what to leave;
  anything not taken stays as a place-owned lost item at the site, and a crafted batch that does not fit is held at the
  workshop until collected. Nothing is deleted.
- **If the player loses or sells their storage item while carrying more than the new capacity allows**: they keep the
  goods but cannot buy, gather or take more until under the cap; each fight's defeat rule applies to the excess first
  (the victor takes goods by value per weight).
- **If the player buys a finished good** (crafted class, no composition): the shelf offers any template whose `V_q0`
  falls in the class, each while the class pool's value is at least its `V_q0`; the price is the class price (sf 1).
- **If the player is defeated carrying several classes**: the victor takes the goods with the highest value per weight
  first, up to the victor's carry cap (ties to the lower `good_id`); the rest become place-owned lost items (Item Database
  rule 14). Origin tags are kept.

**Crafting**
- **If raw stock cannot cover the plan's inputs**: workshop output is scaled by the input fill (Formula F), so crafting
  never creates goods from nothing.
- **If a recipe's inputs split two classes equally**: `a[c,g]` = 0.5 / 0.5 over two goods works in Formulas F and G;
  pricing no longer needs a main class.
- **If a recipe slot takes "any material of rarity r or more"**: it is one slot group (Formula F): the draw and
  the fill use the eligible goods that are on the shelf here, by available value, so one absent specialty (Tử Kim Sa) does not stop
  the class; with none of the group shelved the fill is 0. A group may span two raw bands; each good reads its own band.
  A good with `D_g` = 0 has fill 1.
- **If a named input is off the shelf for many seasons** (a rarity 5–6 herb's sawtooth): the class's fill is 0, so it
  makes nothing, its plan does not rise (Formula F) and next season's `craft_in` is 0 (Formula G); the plan resumes when
  the input is shelved. The pill class is intermittent like its input.
- **If an exporter's class has nothing shelved**: its `avail` is 0 and it exports nothing; exports never exceed shelved
  value, so links never move value that the exporter keeps (Formula B).
- **If an NPC workshop's recipe needs an aged herb**: the workshop draws that input's value in mature units (Formula G);
  workshops' aged herbs come from their own fields.
- **If the main inputs tie on value × quantity**: Formula I's tie rule decides (shared origin, else the crafter's market,
  else the lowest market id).
- **If a crafted class has no recipe, or its inputs are unpriced**: with no recipe the plan is 0 and there is no
  `craft_in`; unpriced inputs count at P = 1, and the data load warns.
- **If a single high-tier sale is larger than the commons pool's balance**: the shop shows the capped offer before the
  sale (Money); `P_eff` counts the full value. The `s_cap` overflow trims only anonymous pool value and never deletes a
  sold item's record.
- **If a sect's workshops produced no kind pills**: the sect buys the shortfall from the crafted pool at P (as
  `Buy_short`); if the pool is short, the remainder is paid in herbs.
- **If a crafted class has several recipes**: crafted classes have no composition, and their scarcity factor is 1 for
  MVP, because the plan is per class.

**Data**
- **If a good matches no land anywhere**: the data load warns but does not reject (quest and loot goods).
- **If a good is added to the data mid-save**: a changed data hash rebuilds all yield tables at the next tick; the new
  good starts Absent.
- **If a good's rarity is above a site's top rarity**: it is excluded there, and the fallback covers.

**Determinism**
- **If largest remainders tie, or floating-point error splits a near-tie**: weights are fixed point (× 10⁶, integers) and
  `good_id` is compared by ordinal (Formula A).
- **If markets update in sequence**: Formula B reads every exporter's export shares (from `X_pre`, known before the flows), and `wsh_g` is computed after
  every market's B, so market order cannot change the result.
- **If `V_q0` equals a band edge**: it takes the lower tier (strict `<`, as Item Database Formula A).

**Degenerate strategies**
- **If the player buys a good out to make it Absent, then sells it back**: the factor is continuous near 0 and the market's
  own supply refills each season; the gain is only the share change, less the bulk spread. Not an exploit.
- **If the player sells into a market where a good is Absent every season**: each sale ends the Absent state for the next
  season. The roughly 1.86 × source-to-absent gap is intended; slippage, tariffs and travel bound the route. The tail is
  about 2.66 × in a small market whose pool is dominated by one locally plentiful good (Formula D); η is the harness lever
  (AC-RE-49, AC-TG-35, Open Question 15).
- **If the player crafts repeatedly to reset an origin tag**: Formula I blocks it.

## Dependencies

Item Database, Travel & Map, Sects & Missions and Realms note Trade Goods (2026-11-14), and #43 is amended. The
design-review 1–10 changes were written to #43, Item Database and Travel & Map on 2026-11-15 (user approved; Open Question 14).

| System | Type | Interface | Status | Bidirectional |
|---|---|---|---|---|
| Regional Economy & Trade (#43) | Hard | In: class prices, local prices (L1), stock, flows, `d_scale`, baskets. Out: compositions, scarcity factors, crafted classes (about 15), `craft_in`, crafted demand | Approved | **Revised 2026-11-14** (user approved): rule 4 (crafted classes); rule 9 and Formula C (`craft_in`, crafted demand, `bmix` herb 0.40 and pill 0.10); rule 19 (new parts of steps a, c, e, f); Formula E (crafted parameters); Formula G (crafted class keys, the scarcity line); Formula H (in-kind workshops, crafted-sale lines); Formula I (`kind_stipend` split); AC-RE-11 (Military split). Closes #43 Open Questions 1 and 17. *Applied 2026-11-15 (Open Question 14):* raw classes by rarity band (rule 4), the per-band demand split (Formula C) and `D_min` (E); shelved stock (rule 8, Formulas D, E, F), `max(0, D − craft_in)`, market-id-order world sums |
| Item Database | Hard | In: herb and material templates, values, the rarity ladder, `pill_band_edges`. Out: the `trade` block (`good_class`, `element`, `source`, `weight`), 6 new templates, the crafted-origin rule, the craft-margin lint (Formula J) replacing `pill_margin` | In review | Noted 2026-11-14: its Formula C lint and AC-ID-21 now use Formula J; its Open Question 25 carries the `trade` block, the 6 goods and the three recipe changes, which wait on the Item Database revision. *Applied 2026-11-15 (Open Question 14):* a harvested herb's age is fixed, so its Formula B ages only Planted herbs (its rule 15, States); wild ages by Formula K; its Ngưng Nguyên margin corrected to 1.73 |
| Travel & Map (#25) | Hard | In: site kinds, biomes, features, density, herb fit (Formula G), `value_lt` (Formula L). Out: the site yield table; a `by_good` split in the production contract | Designed, pending review | Noted 2026-11-14 (its Dependencies): contract v2 with `by_good`; `unit_value[k]` a value-to-count conversion only. *Applied 2026-11-15 (Open Question 14):* contract v2 `by_good` and the per-site `rem[s,g]` carry (its Formula L); gathering draws Formula K ages (its rule 18) |
| Spirit Herbs & Fields (#14) | Soft | The field's growth and harvest of a herb (age fixed at harvest); a seed is a purchase from the commons | Designed 2026-11-21, pending review | Yes |
| Market (#20) | Hard | Out: named goods on shelves; the scarcity factor in shop prices | Built, no GDD | No GDD to update; a code change |
| World Generation & History (#27) | Hard | In: the fixed world, built once per game; the site yield tables are built from it at world build | Designed 2026-11-15, pending review | Yes (its Dependencies lists #45) |
| Realms & Bottlenecks (#8) | Soft | In: breakthrough rate and each realm's breakthrough pill value and tier (`bt_rate`, `V_bt`, `tp_bt`) for crafted demand | In review | Noted 2026-11-14 (its Open Question 25): breakthrough-pill demand handoff |
| Sects & Missions (#26) | Soft | Out: workshop output, kind pills, Military's crafted demand | Approved | Noted 2026-11-14 (its Dependencies): workshop share in kind; kind pills from workshops; Military mix |
| Alchemy (#15), Artifact Refining (#16), Talismans | Soft | In: recipes (a crafted class's input goods, `a[c,g]`). Out: the craft plan as NPC workshop output; the origin rule at craft time | Built, no GDD (Artifact Refining: quick spec) | No GDD; the code change and the quick spec |
| Codex & Karmic Carryover (#12) | Soft | Out: discovered specialties (Discover setting) | Not started | Note it when it gets a GDD |
| Game UI (#37) | Soft | Out: the scarcity line in the price breakdown; specialty map markers | Not started | Index |
| Balance Simulation Harness (#33) | Soft | Runs composition, the craft plan and crafted classes; the crafted-profit, rare-good and route checks | Built | Index |

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted (optional for an Economy system). Review manually before production.

- **Specialty marker:** a specialty shows a distinct icon on the map over each producing region and in the item's info
  panel. Colour is never the only cue.
- **Availability:** a good's state in a market (Source, Imported, Absent) shows as a word plus an icon on the shelf and in
  the ledger.
- **No new sounds:** trading uses #43's coin and refusal sounds.

## Game Feel

Optional for an Economy system; one target only. Scarcity factors, specialty labels and crafted prices change when the
season turns, never mid-season; a trade updates the purse and the price breakdown in the same frame as the click (#43).

## UI Requirements

`ux-designer` not consulted. Review manually before production. The first build is the Debug Terminal
(`src/debug_terminal/`), with a retained screenshot for AC-TG-39.

- **Price breakdown** (#43 rule 17): adds a "Scarcity" line (× sf) for raw goods, and the crafted class and tier for
  finished goods; a sale larger than the commons pool's balance shows the capped offer before the sale.
- **Good info panel:** class, element, rarity, weight, `origin_market`, specialty label, the land it comes from (if
  known), and its state in this market.
- **Specialty map:** under Known world every specialty is marked; under Discover only known ones are marked, rumoured
  ones show as "rumoured", and former specialties are marked "former".
- **Market ledger** (#43): the composition of each class (each good's share), and the crafted classes with plan, output
  and price.

## Cross-References

| This GDD | Other GDD | What is referenced | Status |
|---|---|---|---|
| Rules 4, 6, 8–16; Formulas B, D–I; Money | regional-economy-trade.md rules 4, 5, 8, 9, 16, 19; Formulas B–I, L1, L2 | Class pools, raw bands, shelved stock, prices, spreads, baskets, tick order, money ledger | **#43 amended 2026-11-14 and 2026-11-15** |
| Rules 1–2, 10; Catalogue; Formula J | item-database.md rules 2, 7, 9, 13, 14, 15, 19; Formulas A–D; Open Question 25 | Templates, values, rarity, `pill_band_edges`, herb ageing, the margin lint | Lint replaced 2026-11-14; herb ageing amended 2026-11-15; **revision needed** for the goods and recipes |
| Rules 5–7, 10; Formulas A, K | travel-map.md rules 2, 4, 18–21; Formulas G, L | Biomes, features, sites, herb fit, `value_lt`, contract v2 `by_good`, `rem[s,g]`, gathered ages | Amended 2026-11-15 |
| Formula H | sects.md F3, rule 9 | `kind_stipend`, Military spending, workshops | Noted 2026-11-14 |
| Formula H | canh-gioi.md (Realms) | Breakthrough rate and breakthrough pills | Noted (Realms Open Question 25) |

## Acceptance Criteria

Drafted with `qa-lead` (2026-11-14); every worked example was recomputed, and revised after design-review 1 (2026-11-14).
Tolerance: ±0.5 in the last digit shown; integer splits, unit counts and money ledgers must match exactly. Shop prices use
#43 Formula G's rounding: buy = ceil, sell = floor. Every *PROPOSAL* threshold is owned by `economy-designer` and set at
the first harness run, before the Pre-Production gate, except AC-TG-41 (owner `technical-director`). Gate levels follow
the defaults (`testing.strict` unset): Logic, Integration and UI are BLOCKING; Config is ADVISORY. **Harness** criteria
run in the Balance Simulation Harness (#33): AC-TG-37 and AC-TG-38 are BLOCKING invariants, also run as a unit test on a
3-market fixture for 40 seasons; the other Harness criteria are ADVISORY until their PROPOSAL thresholds are set. Logic
tests live in `tests/unit/trade_goods/`.

**Fixtures** (`assets/data/economy.json` and the trade-goods data at the Formulas values)
- **FX-TG-SITE**: a herb ground, `value_lt` 4,000, top rarity 3, ω 0.5: Hỏa Linh Chi fit 1.0, Ngưng Khí Thảo 0.7, Xích
  Huyết Đằng 0.8; also Băng Tâm Thảo at fit 0.5 and Kim Tủy Quả (rarity 4) on matching land; `rem` 0 at season 0.
- **FX-TG-HERB2**: a two-good herb band-2 class, Băng Tâm Thảo (V 60, world share 0.04) and Xích Huyết Đằng (0.96); σ 0.12,
  η 0.18, `wsh_min` 0.005, class P 1.0; market S holds 0.15 / 0.85, market N holds 0 / 1.0; a city, `p_loc` 1.0, Mị lực
  50 (ch 0), untagged, `slip` stubbed to 1.
- **FX-TG-CRAFT**: one market, a tier-3 pill class (V_q0 400), plan = plan_ref 2,000, D_min 150; inputs Hỏa Linh Chi
  (herb band 1) a 0.8 and Xích Đồng (ore band 1) a 0.2, both sf 1; μ 2.5, ps 0.8; P_pill 1.30, P_herb1 1.0, P_ore1 1.1;
  cover 1.5 (= c_ref) unless stated; κ 0.5, λ_c 0.5, c_lo 0.1, α_p 0.3, δ_p 1.15, φ_p 0.05; input fill 1 unless stated;
  crafting places in two regions with sw 8 and 4, both at access 1.
- **FX-TG-CRAFTER**: a scripted crafter, one run per realm and recipe, at maximum alchemy level and 95 % success, at
  quality 0 and again at quality 3; each season it buys inputs at the cheapest place, brews to the cap, sells at the best
  place and reinvests, for 40 seasons; seeds FX-TM-SEEDS[0..9].
- **FX-TG-GATHER**: a herb site at density 1.0 in a region of access 0.5 (q 0.075), world seed 7, 10,000 gathered units.
- **FX-TG-WORLD**: FX-RE-WORLD plus the 23-good catalogue, the 8 raw classes (rule 8a) and the crafted classes, `bmix`
  herb 0.40 and pill 0.10; the player's cargo capped at #43 FX-RE-PLAYER's 2,000 base value
  (regional-economy-trade.md, Acceptance Criteria), and in a second run at a carry cap of 400 weight (a rarity-2 storage
  bag, rule 16a).

**Catalogue and load**
- **AC-TG-01** [Config] Rules 2, 8a, 11. **GIVEN** the shipped data, **THEN** there are exactly 23 trade goods (herbs 11,
  ores 6, beast 3, special 3; 17 existing, 6 new), each with a `trade` block (`good_class`, `element`, `source`,
  `weight`); weights are herb 1, ore 5, Yêu Cốt 2, Yêu Thú Bì 3, Yêu Đan 1, Linh Tuyền Thủy 2, Địa Hỏa Tinh 1, Lôi Kích Mộc
  4; the raw classes are exactly rule 8a's 8, and the crafted classes exactly those Formula E derives from the shipped
  recipes' `V_q0`, each listed with its tier.
- **AC-TG-01b** [Logic] Rule 4. **THEN** Linh Thạch Khoáng (V 8) buys for **9** and sells for **7**, with no class, share or
  scarcity factor; linh thạch itself has no price; a technique manual trades at P 1.0; selling a bound item is refused.
- **AC-TG-42** [Config] Rule 4a. **GIVEN** the shipped data, **THEN** every catalogue good appears as an input in at
  least one recipe; a good no recipe uses logs a load warning naming it (a warning, not a rejection, until the 6 new goods
  have recipes at the Item Database revision).
- **AC-TG-02** [Logic] Rule 3. **THEN** each of the 12 kind and element pairs (herb × 5, ore × 5, beast "any", special
  "any") has exactly one fallback; a world missing one is rejected at load, naming the pair; a good matching no land loads
  with a warning.
- **AC-TG-43** [Logic] Rule 8a. **THEN** `band = ceil(rarity / 2)` gives exactly: herb 1 {Ngưng Khí Thảo, Thanh Tâm Liên,
  Hỏa Linh Chi, Hoàng Tinh Sâm, Thiết Tuyến Thảo}, herb 2 {Xích Huyết Đằng, Băng Tâm Thảo, Kim Tủy Quả}, herb 3 {Vạn Niên
  Mộc Linh, Anh Tâm Liên, Hóa Thần Quả}, ore 1 {Tinh Thiết, Xích Đồng, Hàn Ngọc}, ore 2 {Linh Mộc Tâm, Huyền Hoàng Thạch,
  Tử Kim Sa}, beast 1 {the 3 beast parts}, special 1 {Linh Tuyền Thủy}, special 2 {Địa Hỏa Tinh, Lôi Kích Mộc}; each
  kind's band demands sum to its demand within 1e-6; selling one Anh Tâm Liên updates `q_sold` and `P_eff` for (herb, 3)
  only, and herb band 1's price is unchanged by it.

**Site yield**
- **AC-TG-03** [Logic] Rule 5. **GIVEN** FX-TG-SITE, **THEN** exactly Hỏa Linh Chi, Ngưng Khí Thảo and Xích Huyết Đằng
  are eligible; fit 0.59 and 0.5 are excluded and fit 0.6 included; a rarity above the site's top, or a density below
  `density_min`, is excluded.
- **AC-TG-04** [Logic] Formula A, rule 6. **GIVEN** FX-TG-SITE, **THEN** the parts are **1,429 / 2,000 / 571** (sum
  4,000), the gathered counts **142 / 1,000 / 12**, and `rem` **9 / 0 / 31** carries; the next season with the same parts
  gives **143 / 1,000 / 13** with `rem` **8 / 0 / 17**.
- **AC-TG-05** [Logic] Formula A, edges. **GIVEN** `value_lt` 1,001 and two equal weights, **THEN** the split is
  **501 / 500**, the extra unit to the lower `good_id` by ordinal; weights are integers × 10⁶ and parts integer division;
  `value_lt` 0 gives all parts 0; a site where only the fallback is eligible gives it all of `value_lt`.
- **AC-TG-06** [Integration] Rule 6 → Travel & Map. **THEN** every site's `by_good` sums to `value_lt` exactly; #43's S,
  summed over each kind's bands, equals a build without Trade Goods within 1e-6; tables rebuild only on a scar, a works
  change or a data-hash change, after which a new good starts Absent.

**Specialty and knowledge**
- **AC-TG-07** [Logic] Formula C. **GIVEN** outputs 2,400 / 900 / 300 / 150 / 40, **THEN** the threshold is 240, N_g is
  **3** and the good is a specialty; a fourth region at exactly 240 gives N_g 4 (not a specialty); when `θ_s · max` is
  below `V_g / 16` a region needs `V_g / 16` (Hóa Thần Quả: 187.5; a region making 200 counts, one making 150 does not); N_g 0 is not a specialty.
- **AC-TG-08** [Integration] Rule 7. **GIVEN** a scar removes a source region, **THEN** the label is recomputed in the
  next season's tick, the scarcity factors are unchanged by the flip, and under Discover the Codex marks the entry
  "former".
- **AC-TG-09** [Logic] Rule 17. **GIVEN** Known world, **THEN** every specialty is in the known set. **GIVEN** Discover, a
  fixed seed and a home market with 3 bordering markets that each have a specialty, **THEN** the home market's
  specialties are known, exactly 2 bordering markets' specialties are rumoured (one per market, the same on every run with
  that seed, ties by market id; with 1 bordering market, 1), and the rest are unknown until visited or told; Codex entries
  survive into the next life. (The map markers are AC-TG-49.)
- **AC-TG-48** [Config] Calibration, Overview. **GIVEN** the shipped map at season 0, **THEN** Băng Tâm Thảo and Xích
  Huyết Đằng are specialties (N_g 1–3); if either is not, the Overview's examples change, not the terrain.

**Composition and scarcity**
- **AC-TG-10** [Logic] Formula B. **GIVEN** the Formula B example, **THEN** X = **2,649.5**, ΣX = **18,442**, sh' =
  **0.1437**; with a craft draw `cd` of 100 Hỏa Linh Chi, X = 2,549.5, ΣX = 18,342 and sh' = **0.1390**; ΣX = 0 gives
  every share 0; a good with pool value 44.9 at V 45 is Absent and keeps 44.9, while 0.44 (< 0.01 · V) with no inflow this
  season is dropped as spoilage; a good of V 3,000 with an inflow of 20 a season (under 0.01 · V) keeps 20 × n after n
  seasons; exports larger than stock leave no X negative; demand, `dk` and `s_cap` overflow leave the shares unchanged;
  `stock_sh` is the sum of the end values at one unit or more.
- **AC-TG-51** [Logic] Formula B, conservation. **GIVEN** three linked markets of one class over 40 seasons, some with
  goods unshelved, **THEN** each season the imports summed over all markets equal the exports summed over all markets
  within 1e-9, **good by good** (each good's value leaving the exporters equals what its importers gain; no good gains or loses value in transit), and every exporter's exports are at most `Σ_{shelved} X_pre − max(0, D − craft_in)`; **GIVEN** an exporter with `craft_in` 1,000, other demand 50 and the player's `P_eff` −105, **THEN** `avail_A` is `Σ X_pre`, not `Σ X_pre + 55`, and each good's export is at most its `X_pre`; **GIVEN** an
  exporter whose class has nothing shelved, **THEN** it exports 0; **GIVEN** a class whose only good is unshelved,
  **THEN** #43's price and cover read `stock_sh` = 0 (the class is short) and the price rises.
- **AC-TG-51b** [Logic] Formulas B, F, craft draw. **GIVEN** a market where Hỏa Linh Chi is imported only (share 0.3 of a 1,000 class stock, own supply of the class's other goods 5,000) and a recipe whose full `need` of it is 1,000, **THEN** `v_g` is its own pre-draw value (300; imports arrive at step (d) and are not in it), `fill_g` follows that, `cd ≤ v_g`, no `X` is clamped from a negative, and every good's `X_pre ≥ 0` in every season of the 40-season fixture. **GIVEN** a good with `v_g` 1,000 where the player buys 900 and the workshops' full `need` is 500, **THEN** the purchase is served (900), `fill_g` is measured against 100, `cd ≤ 100`, `X_pre ≥ 0`; a purchase of 1,001 is refused at settlement. **GIVEN** a slot group Γ of two shelved goods with `v_g` 100 each, the player buying 100 of the first, a full group `need` of 100 and no other demand, **THEN** the group's need spreads by `v_g − buy_pl` (0 / 100), `cd` is **0 / 100**, `fill_Γ` is 1, every `X_pre ≥ 0` without the `max` clamp acting, and the pool's total value drawn equals the workshops' input (no value created); a good serving two crafted classes draws `Σ_c need[c,g] · fill_c`. **GIVEN** two classes with slot groups {g, h} and {g, j} (each good `v` 10, each group need 1,000, no buy, no other demand), **THEN** before the draw scale g's draw would be **13.3**; after it every class's fill is scaled so `cd[g]` ≤ **10**, `cd` of h and j ≤ 10, and `out` falls with the fill. **GIVEN** a seeded random generator of 200,000 markets (2–7 goods in two bands, some unshelved, player buys from 0 to `v_g`, 1–4 crafted classes of 1–3 slots each, named or random groups including nested and overlapping ones), **THEN** no good has `cd[g] > v_g − buy_pl` by more than 1e-9 · max(1, max v).
- **AC-TG-51c** [Logic] Formula B, hub conservation. **GIVEN** a market that imports a class from one market and exports it to another in the same season, with at least two shelved goods whose `X` and `X_pre` shares differ, **THEN** each good's value leaving it equals `Exp · ex[m,g]` exactly, and what the next market gains of each good equals that amount within 1e-9.
- **AC-TG-11** [Logic] Order independence. **GIVEN** three linked markets processed in all 6 orders, **THEN** shares,
  `wsh_g` and sf are bit-identical.
- **AC-TG-12** [Logic] Formula D. **GIVEN** FX-TG-HERB2, **THEN** in S the raw factors are **0.800 / 1.020**, the mean
  **0.987** and sf **0.811 / 1.033** (Băng Tâm Thảo / Xích Huyết Đằng); in N raw **1.495 / 0.993** and sf **1.505 /
  1.000**; the ratio is **1.856**; a class with one good, or any crafted class, has sf 1.
- **AC-TG-13** [Logic] Formula D, bounds. **THEN** the raw sf at share 0 is **1.4949** whatever `wsh_g`; a market holding
  all of a good gives **0.717** at f = 1/7, **0.505** at f = 0.02 and **0.393** at the floor (`wsh_g` 1e-6); a pool with
  one good at share 0.9 and world share 0.02, the rest at raw 1, gives an absent good sf **2.66**; `wsh_g` = 0, or a
  class with no stock anywhere, gives no NaN.
- **AC-TG-14** [Logic] Rule 9. **GIVEN** FX-TG-HERB2's Băng Tâm Thảo, **THEN** in N it is Absent: not for sale, and the
  player's sale pays **81** (60 × 1.505 × 0.90, floored); in S it buys for **54** (ceil) and sells for **43** (floor).
- **AC-TG-14b** [Logic] Rule 16. **THEN** each sale in AC-TG-14 adds its value to `q_sold[(herb, 2)]` and to `sell_pl`.
- **AC-TG-15** [Logic] Rule 10. **GIVEN** a harvested Kim Tủy Quả at age 100 (`herb_value` **225**), **THEN** after 40
  seasons carried, and again after 40 stored, its age is 100 and its value 225; a Planted one ages by Item Database
  Formula B; pool shares are unchanged by time, and pools lose only `dk`.
- **AC-TG-16** [Logic] States. **GIVEN** own supply > 0 and pool value exactly `V_g`, **THEN** Source and on shelves;
  pool value `V_g − 0.01` gives Absent; with no own supply and pool value ≥ `V_g`, Imported. **GIVEN** a Source good whose
  pool value falls below `V_g`, **THEN** Absent; an import bringing it to `V_g` or more makes it Imported; a player's sale
  into an Absent market of at least `V_g` makes it Imported in the next season.
- **AC-TG-44** [Logic] Formula K. **GIVEN** FX-TG-GATHER, **THEN** q = **0.075**; of the 10,000 units, 7.5 % ± 0.5 pp are
  at step 1 or more and 0.56 % ± 0.15 pp at step 2 or more; every age is `mature_years · 2^j`; the same seed gives
  identical ages; density 3.0 at access 0 gives q **0.45**; the commons' harvest adds no aged herb to any pool.

**Crafted classes**
- **AC-TG-17** [Logic] Formula E. **THEN** V_q0 400 gives tier **3**, 150 gives 2, 151 gives 3, 60,000 gives 5 and
  60,001 gives 6; a quality change never changes the tier; D_min at tier 3 is **150** for D_cal 2,000 and **500** for
  D_cal 10,000.
- **AC-TG-18** [Logic] Formula E, calibration. **GIVEN** a pill class with D_cal 2,000 and no shocks, **THEN** plan_ref
  is **2,050**, starting stock **950**, and cover 1.5 and P 1.000 hold for 40 seasons (within 1e-6); an artifact class
  starts with stock 0.99 · D.
- **AC-TG-19** [Logic] Formula F. **GIVEN** FX-TG-CRAFT, **THEN** r = **1.2745**, plan* = **2,257.9**, plan' =
  **2,074.1**; at cover 3.0, plan* **1,596.6** and plan' **1,869.3**; P_pill 2.5 with herb 0.5 and ore 0.7 gives
  **2,300** (δ_p binds); P_pill 0.6 with herb 3.0 and ore 2.2 gives **1,739.1**; a plan of 0 at r 1 gives **115**
  (floor φ_p · plan_ref = 100, then δ_p); cover 0 uses `c_lo` and gives a finite plan*; plan_ref 0 gives 0; at this
  season's `fill_c` 0.5, P_pill 2.5 with herb 0.5 and ore 0.7 gives **2,000** (the plan may not rise), and next season's
  `craft_in` is **400** Hỏa Linh Chi while `need` stays 800. (The
  herb 0.5 and 3.0 cases sit at the outer price bounds: pure-function tests.)
- **AC-TG-20** [Logic] Formula F, fill and placement. **GIVEN** FX-TG-CRAFT with Xích Đồng's fill 1 and Hỏa Linh Chi at share 0.1 of a herb-1
  class whose goods are all shelved and whose Hỏa Linh Chi `v_g` is 1,800 (`sh · stock + S_own + sell_pl`; the class's other goods hold the rest of 18,000) against a whole D of 12,000 (craft_in 800 of it), **THEN** `D_g` = 1,920, fill **0.9375**,
  out **1,875**, placed **1,250 / 625** by sw, and the draw `cd` **750** Hỏa Linh Chi and **187.5** Xích Đồng; at
  Hỏa Linh Chi share 0, out is 0 however full the class is; with Σ sw 0, all output goes to the seat. **GIVEN** the same
  class with goods holding 0.5 of its value unshelved, **THEN** the rest of demand falls on the shelved goods only
  (Hỏa Linh Chi's `D_g` = 800 + 0.2 · 11,200 = **3,040**, fill **0.5921**) and every unshelved good has `D_g` 0.
- **AC-TG-21** [Logic] Formula G. **GIVEN** FX-TG-CRAFT, **THEN** craft_in is **800** Hỏa Linh Chi and **200** Xích Đồng;
  an "any ore of rarity 3 or more" slot is one group: with Tử Kim Sa absent and the other two shelved its fill is that of the two (out is not 0) and its `craft_in` spreads over the two by available value; with none of the three shelved its fill is 0; an "any ore of
  rarity 2 or more" group spans ore 1 and ore 2, and each good's `v_g` and `D_g` read its own band's stock and demand; a plan of 0,
  or no recipe, gives 0; an unpriced input counts at P 1 with a load warning.
- **AC-TG-22** [Logic] Formula H. **GIVEN** 130 Foundation Establishment heads, basket 20, `bmix[pill]` 0.10, fill 1 and
  `tp` 2, **THEN** **260** a season of (pill, 2). **GIVEN** Military spending 1,000, `goods_frac` 0.5, ore and beast mix
  0.6 / 0.4, **THEN** artifacts **100**, talismans **50**, ore **210** and beast **140** (amends AC-RE-11).
- **AC-TG-22b** [Logic] Formula H, credit. **GIVEN** `kind_stipend` 0.15, **THEN** `kind_pill` is 0.10 and 0.05 stays in
  herbs; **GIVEN** a head's pill credit of +2 a season against a fixture pill of V 20, **THEN** the credit is 18 at the
  end of season 9 with no pill, and in season 10's step (c) one pill is delivered and the credit returns to 0.
- **AC-TG-47** [Logic] Formula H, edges. **GIVEN** 50 heads of a realm with `bt_rate` 0.1, `V_bt` 400 and `tp_bt` 3,
  **THEN** `D_bt` is **2,000** of (pill, 3); ω_t over tiers sums to 1; with `kind_stipend` 0.08, `kind_pill` is 0.08;
  pills have no `sub_floor`.
- **AC-TG-23** [Logic] Formula I. **THEN** the example gives origin **A** (20 against 10); on a tie, inputs sharing one
  origin give that origin, different origins give the crafter's market, and a crafter in a region with no market gives
  the lowest tied id; untagged inputs give the crafter's market; re-crafting never removes a tariff tag.
- **AC-TG-24** [Logic] Formula J. **GIVEN** V_out 400, yield 1 and ps 0.9, **THEN** inputs of 120 give **1.636**, 70 give
  **2.805** with a profit of **139** (no warning: under 600) and 200 give **0.982**; **GIVEN** V_out 4,000 and inputs of
  700, **THEN** **2.805** with a profit of **1,390** warns; a margin of exactly 2.5 does not warn (strict >); a margin above
  2.5 warns at a profit of 600 and not at 599. **GIVEN** the recipes at ps 1 after the 2026-11-14 revision (Formula J's
  example), **THEN** Ngưng Nguyên Đan **1.73**, Tẩy Tủy Đan 1.89, Diên Thọ Đan 1.91 and Thiết Cốt Đan 1.82, and no recipe
  warns.
- **AC-TG-46** [Logic] Rules 12, 16. **GIVEN** two sales of one (pill, 2) item at the same place in a season, **THEN** the
  second sale's slip is #43 Formula G's value at the `q_sold` left by the first, and both count against (pill, 2), not
  herb; the sold items add to next season's crafted S (Formula F's `sells`).

**Money**
- **AC-TG-25** [Integration] In-kind workshops. **GIVEN** workshop output of 2,074 and craft_in of 800 / 200 in a season,
  **THEN** no purse, pool or treasury changes because of them and AC-RE-07 still holds; a sect's share meets its kind
  pills and Military use first; a shortfall is bought at P, and what the pool cannot cover is paid in herbs.
- **AC-TG-26** [Logic] Capped sale. **GIVEN** a commons pool of 3,000 and a crafted sale worth 5,000, **THEN** the sale
  pays 3,000 and leaves the pool at 0; `P_eff` counts the full V; no holder goes below 0. (The capped-offer display is
  AC-TG-49.)

**Integration with #43**
- **AC-TG-27** [Logic] Amended rule 4 (owner of the value; AC-RE-05 refers here). **GIVEN** a finished good of V 100 in
  class (pill, 2) at P 1.065, in a city, Mị lực 50, St 0, **THEN** buy = **160**; changing P_herb does not change it; the
  sale updates `q_sold`, `P_eff` and `sell_pl` for (pill, 2), not for herb.
- **AC-TG-28** [Integration] Tick placement. **GIVEN** an instrumented season, **THEN** C runs in (a); F placement, G and
  H in (c); B, D and E in (e) after (d), with D after every market's B; the F plan update in (f), first read in the next
  season's (c); K only at gather time.
- **AC-TG-29** [Config] Calibration. **GIVEN** `bmix` herb 0.40 and pill 0.10, **THEN** the calibration tool exits
  non-zero if any `d_scale` (AC-RE-51) is outside 0.5–3, and its report contains the line
  `herb d_scale = X (<= 2.4: yes/no)`.
- **AC-TG-30** [Integration] Politics, holder change. **GIVEN** a region with sw_r 4 of its market's 12 changes holder,
  and a crafted class with plan_ref 2,000, **THEN** **666.7** of plan_ref and the same share of the plan move to the new
  holder, and the region's stock enters B at the old market's export shares `ex`, each good leaving the old market in the same amount it arrives.
- **AC-TG-30b** [Integration] Politics, a fallen market. **GIVEN** a market falls and two victors gain sw 6 and 2,
  **THEN** they receive **75 % / 25 %** of its stock (at its composition), its crafted pools and its plans, and its kind
  pills end.
- **AC-TG-30c** [Integration] Politics, embargo. **GIVEN** an embargoed market, **THEN** Imp = Exp = 0 in its Formula B,
  and its stock still counts in every good's `wsh_g`.
- **AC-TG-31** [Integration] Defeat. **GIVEN** a defeated player carrying several classes, **THEN** the victor takes goods
  by value per weight up to its carry cap (ties to the lower `good_id`), the rest become lost items (Item Database rule
  14), and origin tags are kept.
- **AC-TG-45** [Logic] Rule 16a. **THEN** carry capacity is 30 with no storage item and 150 / 400 / 1,000 / 2,500 / 6,000
  / 15,000 at rarity 1–6; carrying a pouch and a ring gives 1,000, not 1,150; no equipment slot is used; a purchase that
  would exceed the capacity by any weight is refused; a home holds at most 1,000 weight of trade goods.
- **AC-TG-50** [Logic] Game Feel. **GIVEN** a trade mid-season, **THEN** sf, specialty labels and crafted prices are
  unchanged until the next tick, and the purse and price breakdown reflect the trade before the next frame.

**Harness** (FX-TG-WORLD, 10 seeds, seasons 41–400 unless stated)
- **AC-TG-32** [Harness] **GIVEN** FX-TG-CRAFTER, **THEN** mean crafted profit per season is at most **1.5 ×** that
  realm's mission pay (Sects & Missions) *(PROPOSAL)*.
- **AC-TG-32b** [Harness] **GIVEN** FX-TG-CRAFTER, **THEN** in seasons 31–40 it is at most **1.0 ×** *(PROPOSAL)*.
- **AC-TG-32c** [Harness] **GIVEN** FX-TG-CRAFTER at fixed capital, **THEN** the margin in seasons 31–40 is below that in
  seasons 1–10.
- **AC-TG-33** [Harness] No crafted class sits at P_min or at P_maxeff for more than **20** seasons in a row
  *(PROPOSAL)*.
- **AC-TG-34** [Harness] Rule 6, Formula B. Every rarity 5–6 good is Source in at least one market in at least **30 %**
  of seasons *(PROPOSAL; was 90 %, which the sawtooth of the shelved draw cannot meet: design-review 3)*; the harness
  reports the fraction per good and the longest absence.
- **AC-TG-34b** [Logic] Formula B, rule 6. **GIVEN** an unshelved good (V 3,000) with an inflow of 200 a season and
  no sales, **THEN** its end value `X'` is 200 × n after n seasons (no decay, no draw); at the end of season 15 it is 3,000
  and is on the shelf (Source or Imported) for season 16; in season 16's tick it is shelved and the draw takes from it
  (it ends below 3,000 and is Absent again); in the tick it reaches 3,000 the draw does not touch it; the draw never
  touches the other unshelved goods, **including when the shelved goods are too few or none** (the draw is capped at the
  shelved value and `stock'` is `Σ X'`: GIVEN a class holding only this unshelved good, a #43 draw of 20 % plus demand
  leaves X' at 200 × n); **GIVEN** a pool with one shelved and one unshelved good, **THEN** exports, demand
  and overflow reduce only the shelved one, the ledger `stock'` is `Σ X'`, `sh' = X' / Σ X'`, and #43's price and cover
  read `stock_sh` (the shelved good's X' only).
- **AC-TG-34c** [Logic] Formula B, F, rule 6. **GIVEN** FX-TG-CRAFT with Hỏa Linh Chi unshelved, **THEN** its `fill_g` is
  0, `out` is 0 and `cd` is 0 for every input of that recipe; the player's purchase of an unshelved good is refused;
  once it is shelved the fill follows Formula F.
- **AC-TG-35** [Harness] **GIVEN** FX-RE-PLAYER (regional-economy-trade.md) at both of FX-TG-WORLD's cargo limits,
  **THEN** the best specialty route returns at most **1.3 ×** the best non-specialty route of the same round-trip length
  in seasons *(PROPOSAL; η is the lever, Open Question 15)*.
- **AC-TG-36** [Harness] A plan's direction is the sign of `plan' − plan` where `|plan' − plan|` exceeds 1 % of plan_ref;
  a shock is a holder change, scar, embargo or works change in that market this season or the last. No craft plan
  changes direction more than once in any 8-season window without a shock; and a crafted class started at `s_cap` stock
  halves its price gap to 1.0 within **15** seasons *(PROPOSAL)*.
- **AC-TG-37** [Harness, BLOCKING] Every season, every class pool's shares sum to 1 (or are all 0) within 1e-9.
- **AC-TG-52** [Logic, BLOCKING] Formulas B, D, F, G, tick properties *(design-review 10)*. **GIVEN** `python -I tools/design/trade_goods_sim/tick_props.py --variant fixed` (default 300 random worlds × 40 seasons, 3 linked markets, each world also run in all 6 market orders), **THEN** every invariant prints ok: `cd ≤ v_g − buy_pl`, `cd ≥ 0`, fill in 0–1, the `max(0)` in X never acts, each export ≤ the good's X, link conservation good by good, the per-good ledger, X' ≥ 0 with the rounding floor trimming only rounding, unshelved goods untouched, shared draw ≥ 0, shares sum to 1, final state and sf bit-identical across orders, sf finite with shelved mean 1, plans finite with no windup. The tool mirrors this GDD; a formula change here updates it in the same revision. The game's own unit tests in `tests/unit/trade_goods/` reproduce the same properties on the implementation.
- **AC-TG-38** [Harness, BLOCKING] The same seed run twice gives byte-identical ledgers, compositions, plans and gathered
  herb ages.

**UI and Codex**
- **AC-TG-39** [UI] Rule 9 *(provisional until UI Requirements is finalised)*. **GIVEN** Băng Tâm Thảo in FX-TG-HERB2's
  market N, **THEN** the price breakdown shows a "Scarcity" line (×1.505) and the parts multiply to the price shown.
  Evidence: retained screenshot at `production/qa/evidence/tg-scarcity-line-[date].png`.
- **AC-TG-49** [UI] UI Requirements, Visual/Audio *(provisional until UI Requirements is finalised)*. **THEN** each of
  these has a retained screenshot in `production/qa/evidence/` (`tg-[screen]-[date].png`): the good info panel (class,
  element, rarity, weight, `origin_market`, specialty label, land, state as word and icon); the specialty map under Known
  world and under Discover (known, "rumoured" and "former" markers, each with a non-colour cue); the market ledger
  (composition of a class, and a crafted class's plan, output and price); a finished good's price breakdown with its
  crafted class and tier; and the capped offer of AC-TG-26 shown before the sale.
- **AC-TG-40** [Integration] Rule 17 → Codex. **GIVEN** Discover, **THEN** visiting a market, or being told by an NPC,
  adds its specialties to the Codex and to the map markers.

**Performance** *(PROPOSAL; owner technical-director)*
- **AC-TG-41** [Harness] On the project's reference machine (named by technical-director), in a release export run
  headless, the composition and crafted-class part of the tick (7 markets × 23 goods in 8 raw classes, about 15 crafted
  classes) runs in a median of 1 ms or less and a p99 of 3 ms or less over 400 seasons; the whole economy tick stays
  within AC-RE-44's 8 ms, or technical-director amends that budget; building all site yield tables at world generation
  takes 200 ms or less.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Recipe revisions for the three margin outliers~~ **Decided 2026-11-14 (user):** raise inputs, keep prices (Formula J's example); applied to `items_recipes.json` at the Item Database revision | user | Item Database revision (data) |
| 2 | ~~Values and recipes for the 6 new goods~~ **Decided 2026-11-14 (user):** the catalogue values; materials pass rule 4a through refining, talisman and formation slots; Thiết Tuyến Thảo feeds the new Thiết Cốt Đan | user | Item Database revision (data) |
| 3 | ~~Storage capacities~~ **Decided 2026-11-14 (user):** rule 16a's ladder | user | Item Database revision (storage-item kind) |
| 4 | Breakthrough-pill demand: `bt_rate`, `V_bt`, `tp_bt` by realm | Realms | Realms revision |
| 5 | ~~Apply the #43 amendments~~ **Done 2026-11-14**: #43 rules 4, 9, 19, Formulas C, E, G, H, I, L2, AC-RE-05, AC-RE-11 amended; registry updated | user | Done |
| 6 | Raise `bmix[pill]` from 0.10 to 0.15 if the calibrated herb `d_scale` stays at 2.4 or less | economy-designer | Harness run |
| 7 | ~~If holding herbs fails AC-TG-34, the mitigation~~ **Decided 2026-11-14 (user, design-review 1):** a harvested herb's age is fixed, so holding earns nothing; old herbs come from wild ground (Formula K) and fields (rule 10) | user | Done |
| 8 | Do crafted classes get compositions and scarcity factors after MVP (sf = 1 for now)? | user | Post-MVP |
| 9 | Talismans have no GDD; their recipes set `a[c,g]` for the talisman classes | Talismans | When it gets a GDD |
| 10 | Should a sect's workshops sell surplus for sect income? Today all workshop output is in kind and earns no cash | user, economy-designer | Harness run |
| 11 | Solved routes in a fixed world: does politics move the best route between lives? A harness check that no route stays best for more than N seasons, and that the source regions of rarity 5–6 goods (Hóa Thần Quả, Anh Tâm Liên) vary between lives through per-life reserve rolls and politics (Formula A's inputs must feel the reserve roll) | economy-designer | Harness run |
| 12 | Codex storage for discovered and rumoured specialties under Discover | Codex (#12) | Codex GDD |
| 13 | Should a beast part take its lair's element from the land (computed, never authored), so beast goods can feed element-based builds? | user, economy-designer | Post-MVP |
| 14 | ~~Apply the design-review-1 amendments: #43 (raw rarity bands, rule 4 and Formulas C–E; unshelved goods exempt from spoilage, exports, demand and the `s_cap` overflow, design-review 3–4; price, cover and `avail_A` read the shelved stock, design-review 6; `avail_A` and the rest of demand use `max(0, D − craft_in)`, and Formula D's world sums run in market-id order, design-review 10), Item Database (harvested age fixed, Formula B and the Planted state; Formula K's wild ages; Open Question 25), Travel & Map (gathering draws Formula K; `rem[s,g]` carry)~~ **Done 2026-11-15 (user approved):** applied to #43 (rules 4, 8; Formulas C, D, E, F), Item Database (rule 15, States, Formula B, its Open Question 25) and Travel & Map (rule 18, Formula L contract v2 with `by_good` and `rem[s,g]`, AC-TM-94) | user | Done |
| 15 | η against the route tail: after normalising, an absent good reaches about 2.66 × in a small pool dominated by one plentiful good (Formula D). Set η in 0.10–0.18 so AC-RE-49 and AC-TG-35 pass | economy-designer | Harness run |
| 16 | Aged-herb recipes (Tẩy Tủy, Ngưng Nguyên, Diên Thọ Đan) need step 1–2 herbs that shelves never sell; wild gathering gives 0.56 %–4 % of units at step 2, against a base carry of 30 weight. Add an AC bounding gathered units per brew by the carry caps, and say how NPC workshops source them (fields have no GDD) *(design-review 2, 2026-11-14)* | economy-designer, user | Harness run / Item Database revision |
