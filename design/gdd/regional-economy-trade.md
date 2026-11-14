# Regional Economy & Trade (Vùng Kinh Tế & Thương Lộ)

> **Status**: Designed (pending review; design-system 2026-11-14, guided and lean: CD-GDD-ALIGN skipped, Lean mode; specialists consulted for Formulas (systems-designer, economy-designer) and Acceptance Criteria (qa-lead))
> **Author**: user + Claude
> **Last Updated**: 2026-11-14
> **Last Verified**: 2026-11-14
> **Implements Pillar**: Pillar 5 (A World That Remembers), Pillar 4 (Every Season Counts); touches Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Regional Economy & Trade turns what the land produces into what people can buy. Each of the 7 great sects' territories
is one market: once a season it reads Travel & Map's production contract and sets stock and a price for each good class
(herbs, ores, beast parts, special goods) from supply and demand, and goods flow between linked markets up to the
capacity their sects' Trade allows. Mines are the only source of money, and stone cultivation (cheap at the bottom,
ruinous at the top) is its main sink. The player sees prices that differ by country and season, can carry goods where
they are scarce, and every price shows its parts. It reworks the built Market (#20) and replaces Sects' production
guess with real sect income.

> **Quick reference** — Layer: `Feature` · Priority: `MVP (provisional)` · Key deps: `Travel & Map, Sects & Missions, Market, Item Database, Realms & Bottlenecks, Time & Turn, Living World Tick; soft: Event Engine, Character Stats`

## Overview

Regional Economy & Trade (Vùng Kinh Tế & Thương Lộ) is the seasonal supply-and-demand layer between the land and the
shop. Travel & Map publishes, once a season, how much each region and each sect territory produces of each resource
kind (linh thạch, ores, herbs, beast parts, special goods) together with the region's population (rule 25 and
Formula L). This system turns those quantities into **stock** at each market, **prices** that rise when a good is
scarce and fall when it is plentiful, and a **flow of goods** between markets that sects' Trade development links.
Prices feed back to the land through Travel & Map's demand factor (`price_index`, `D_f`, today fixed at 1.0), so a
high price pushes extraction up within bounds. Sects read the results: production in value and prices set each
sect's income, and its Tax, Openness and tariff dials shape what moves and what the sect keeps.

The player meets it passively and actively. Passively, the same herb costs different amounts in different towns and
changes with the season, war and sect policy. Actively, the player can carry goods where they are scarce, choose
where to buy, and feel the cost of a closed border. Without it the Market stays a flat price list that ignores the
land beneath it, Sects' income stays a guess (`world_production_guess`), and the production contract has no reader.
It serves Pillar 5 (A World That Remembers: a mine thinned by war is still thin, and the price remembers) and
Pillar 4 (Every Season Counts: stock and prices move once a season); every price is a stored, inspectable number
(Pillar 2). Item value stays owned by the Item Database; this system owns the multiplier on it by place and season.

*Provisional until reviewed:* what the player may do with it directly (carry and sell goods), and whether mine output
adds to or replaces the mission and stipend faucets (Travel & Map Open Question 1), are decided in Detailed Design.

## Detailed Design

### Core Rules

**Markets**

1. **One market per great sect.** Each of the 7 great sects (đại tông môn) is a country (Travel & Map rule 24), and its
   territory is one **market** (thị trường): every region it holds, with its vassals' sites inside. A minor sect never
   has a market of its own. *(User decision 2026-11-14: "1 market per country".)*
2. **Markets follow the politics.** When a region or site changes holder (Sects rules 17–18), its production and its
   stock join the new holder's market in the same season's economy tick (the Sects tick, which moves holders, runs
   first; rule 19). A great sect that falls closes its market; its regions join the victors' markets. There is no market without a sect.
3. **Market places.** Inside a market, the places that sell to the player (Market #20: cities, towns, markets and
   villages with a market flag) all sell at the market's price for each good. A place adds only its own stock depth and
   a settlement margin (rule 14). There is one price per good per market, not one per place.

**Goods and money**

4. **Priced goods.** The priced goods are the resource kinds Travel & Map produces (ores, herbs, beast parts, special
   goods), by **good class**. Finished goods (pills, artifacts, talismans, manuals) are not priced here: their value is
   the Item Database's (rule 9), multiplied by the market's price for the class of their main input. *(Provisional:
   whether crafted goods get their own supply and demand is deferred; see Open Questions.)*
5. **Linh thạch is money, not a good.** It has no price. Mines make it (Travel & Map rule 21), and it is the only source
   of new money. Missions, stipends, tribute, taxes and purchases move money and never create it (**mine output replaces
   the mission faucet; user decision 2026-11-14, Travel & Map Open Question 1**). Event and loot money is drawn from a
   named holder, never created (Formulas K). Money leaves the world through works and **stone cultivation**:
   cultivators absorb linh thạch for tu vi, cheap at the bottom and ruinous at the top (Formulas H, J; user decision
   2026-11-14). A sect takes its income from mine cash, from goods it sells, and from tariffs; collected goods are money
   only once sold (Formulas I).

**Supply, demand and price**

6. **Supply.** A market's supply of a good in a season is its regions' production of that kind (the contract's `qty`),
   scaled by what the holder collects (Holdings, Sects rule 9) and by **market access** (rule 7), plus imports
   (rule 13). Stock carried over (rule 8) adds to supply when cover is computed.
7. **Market access.** Each region reaches its market's hub at a rate from 0 to 1 set by distance, roads, the sect's
   Trade level and Military safety. A region far from the seat uses part of its output locally and loses the rest to
   spoilage and loss. The hub is the seat's market place. Access is derived from Travel & Map data, not stored per place.
8. **Stock carries over.** What a market does not sell in a season stays as stock. Stock decays by good class (herbs
   fast, ores almost never). Price depends on **cover**: stock plus supply, divided by demand.
9. **Demand.** Demand for a good is population demand (heads by realm from the contract's `pop_cultivators`, and
   settlement weight), plus the sect's own use (Institutions use herbs, Military uses ores and beast parts, works use
   ores), plus the player's purchases.
10. **Price.** Each season a market's price for a good moves toward the level its cover implies. It is bounded by a floor
    and a ceiling and limited in how far it may move in one season (inertia), so a shock shows over several seasons.
    The price is a multiplier on the Item Database's base value; 1.0 is the base.
11. **Prices feed the land.** At the end of the tick the market's price for each good class is written back as the
    `price_index` that Travel & Map reads for its demand factor `D_f` (Formula H). `price_index` stays 1.0 for any
    region whose market has not ticked yet.

**Trade between markets**

12. **Links.** Two markets are **linked** when their territories border (or a teleport array joins them), neither is at
    war with the other, both sects' Openness allows it, and both have Trade level 1 or more. Links are recomputed once
    a season and come and go with politics.
13. **Flow.** Each season, goods flow along a link from the market with the lower price to the one with the higher
    price. The flow is limited by the link's **trade capacity** (set by both sects' Trade levels and cut by Military
    safety on the route) and stops when the price gap falls to tariff plus transport cost. Imports and exports both use
    the capacity.
14. **Tariffs and margins.** The importing sect charges its tariff (a sect dial, Sects rule 9) on goods that cross, and
    the revenue is the sect's income. A place's margin and the sect's standing price (Sects, `sect_standing_price`)
    apply on top, at the shop.

**The player**

15. **Buying and selling.** The player buys and sells at a place at the market price for the item's class, times the
    Item Database value, the buy markup and sell ratio, Mị lực, standing and tariff. Raw goods (herbs, ores, beast
    parts, special goods) trade at a narrow **bulk spread** with no charm or standing; finished goods keep the built
    retail spread (Formulas G; user decision 2026-11-14). Each trade moves
    that market's supply or demand a little, bounded per season, so one player cannot corner a market.
16. **Carrying.** The player may buy in one market and sell in another. They pay the importing sect's tariff, spend the
    travel seasons and meet the encounter risk (Travel & Map), and are subject to the sect's Openness: an Embargoed or Closed
    market refuses outsiders. Profit is bounded by the price gap, which flow already closes.
17. **Visible numbers.** Every price shows its parts (Item Database value, market price, tariff, margin, standing,
    Mị lực), and the market ledger shows supply, demand, stock, cover and flow for the season (Pillar 2).

**Change and the seasonal tick**

18. **Shocks come from events.** War raids (Sects F9), blights, gluts and embargoes change supply or demand by budgeted
    amounts set by the Event Engine. The LLM narrates a shock and never sets a price (Pillar 2).
19. **Tick order, once a season, after Travel & Map's production and Sects' season tick:** (a) read the contract;
    (b) apply holder changes; (c) compute access, supply and demand; (d) compute links and flows; (e) update prices and
    stock; (f) write `price_index`, each sect's trade income and production value; (g) restock the market places
    (replacing the built yearly restock).

### States and Transitions

A market has a state, recomputed each tick. When more than one condition holds, the state is the first of Closed,
Embargoed, Strained, Open. A war cuts only the link between the two warring markets (rule 12); it does not embargo
either market.


| State | Condition | Effect | Next |
|---|---|---|---|
| **Open** | Holder exists, no embargo, no good in severe shortage | Normal flow and prices | Strained, Embargoed, Closed |
| **Strained** | A good's cover is below `c_short`, or war touches the territory | Shortage: the ceiling widens for that good only. War: it widens for every good. Shortages may raise events | Open (cover recovers, war ends), Embargoed, Closed |
| **Embargoed** | The sect sets Openness 0 | No links, outsiders refused. A shortage still widens that good's ceiling | Open or Strained (Openness raised) |
| **Closed** | The great sect has fallen | The market ends; its regions join the victors' markets | None |

### Interactions with Other Systems

| System | Direction | What passes between them |
|---|---|---|
| **Travel & Map** (#25) | in / out | In: the seasonal production contract (rule 25; Formula L), population, settlement weights, regions and holders, travel and encounter risk for carrying. Out: `price_index` per good class (Formula H's `D_f`). |
| **Sects & Missions** (#26) | in / out | In: development levels (Holdings, Trade, Military, Institutions), the Tax, Openness and tariff dials, holder changes, war state. Out: each sect's production value and trade income (replacing `world_production_guess`), market prices, and the client-paid mission cash pool. |
| **Market** (#20) | out | The market price per good class, each place's stock list, and the seasonal restock. Market keeps buying and selling at a place. |
| **Item Database** | in | Value per unit and good class of each item (rule 4). It owns value; this system owns the multiplier. |
| **Time & Turn** (#4) | in | The season clock that triggers the tick. |
| **Event Engine** (#23) and the **LLM game master** (#29) | in / out | In: shock events inside budgets. Out: market state changes and notable price moves for narration. |
| **Living World Tick** (#28) | in | Calls this system's tick after the sect tick, each season. |
| **Character Stats** | in | Mị lực for the player's prices. |
| **Game UI** (#37) | out | The market ledger and the price breakdown. |

## Formulas

All values are **guesses** until the economy tick runs in the Balance Simulation Harness (#33) for 400 seasons
(Acceptance Criteria). Specialists consulted: `systems-designer` (A–I), `economy-designer` (money holders, sinks,
price bands, spreads, exploits). All values live in a new data file, `assets/data/economy.json`, unless marked as built.

**Units.** Supply, demand, stock and flow are counted in **base value** (`value_lt = qty · unit_value`, Travel & Map
Formula L), because a good class holds items worth 10 to 120 each and raw counts cannot be added. Cover is unitless.
Prices come from cover only. Money never sets a price; inflation shows only as purses growing, which H bounds.

**Good classes** k: herb, ore, beast, special. Linh thạch is money (rule 5) and has no k.

**Anchors.** Mines make about 124,000 linh thạch a season (Travel & Map L). Non-mine goods are about 250,000 a season
in base value (Sects `world_production_guess`, which this GDD turns into an acceptance check, I). Census 3,936 / 844 /
191 / 27 / 3 by realm (Realms C2). Stipends a season 3 / 20 / 50 / 325 / 2,500 (Sects anchors); about 3,300 sect
members are paid about 41,800 a season, and the ~1,700 loose cultivators (tán tu) are paid nothing.

### A. Market access (rule 7)

The market_access formula is defined as:

`reach_r = exp(−d_r / (d_reach · trade_mult))` · `safe_r = clamp(1 − λ_road · dmg^M · (1 − reach_r) − λ_war · war_r, 0, 1)` · `acc_r = reach_r · safe_r`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| d_r | float | 0–~400 tiles | calculated (Travel & Map D, road path) | Region centroid to the seat's market place (the hub) |
| d_reach | float | 250 | data file *(guess)* | Distance scale |
| trade_mult | float | 1 + 0.15 · T | Sects F2 | Roads and caravans of the holder |
| dmg^M | float | 0.92^M | Sects F2 (`road_danger`) | Military safety |
| λ_road, λ_war | float | 0.10, 0.40 | data file *(guess)* | Loss to bandits; loss in a region war touches |
| war_r | int | 0 or 1 | Sects (war state) | War touches the region this season |

**Output Range:** 0 to 1; 1 at the seat in peace. Linh thạch always has access 1 (money is not goods).
**Example:** 150 tiles, Trade 6 (1.9), Military 6 (0.606), peace: reach = e^−0.316 = 0.729; safe = 1 − 0.1 · 0.606 ·
0.271 = 0.984; **acc = 0.717**.

### B. Supply (rule 6)

The market_supply formula is defined as:

`S[m,k] = h_f · Σ_{r∈m} value_lt[r,k] · acc_r · (1 − shockS[m,k]) + Imp[m,k] − Exp[m,k]` · `h_f = h0 + (1 − h0) · collect / s_max`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| value_lt[r,k] | float | ≥ 0 | Travel & Map L (contract) | Base value produced in region r, non-money kinds |
| collect, s_max | float | 0.086–0.6; 0.6 | Sects F2 | Holdings collect share and its limit |
| h0 | float | 0.6 | data file *(guess)* | Share that reaches the market even at Holdings 0, so a poor sect is not also starved of goods |
| shockS | float | 0–0.8 (summed) | Event Engine | Raids, blight (rule 18) |
| Imp, Exp | float | ≥ 0 | calculated (F) | Flow on links |

**Output Range:** ≥ 0, no upper bound. h_f runs from 0.657 at Holdings 0 toward 1.
**Example:** herbs, seat 12,000 (acc 1) plus a region of 8,000 (acc 0.7172), Holdings 6 (collect 0.3231, h_f 0.8154):
0.8154 · 17,737.6 = 14,462.4, plus imports 1,200 = **15,662.4**.

### C. Demand (rule 9)

The market_demand formula is defined as:

`D[m,k] = d_scale[k] · (Σ_rl n[m,rl] · head_w[rl] + set_w · W_set[m]) · (1 + shockD[m,k]) + goods_frac · (Σ_T spend_T · mix[T,k] + works_due · wmix[k]) + P_eff[m,k]`, clamped at 0

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n[m,rl] | int | ≥ 0 | contract `pop_cultivators` | Heads by realm in the territory |
| head_w[rl] | float | 3 / 20 / 50 / 325 / 2,500 | Sects anchors (stipends) | Use per head, pegged to the stipend |
| W_set, set_w | float | ≥ 0; 50 | contract; data file *(guess)* | Mortal settlement weight and its scale |
| d_scale[k] | float | ~0.3–1.5 | data file (computed once by a calibration tool) | Sets world demand so every class starts at P = 1 |
| spend_T | float | ≥ 0 | Sects F1 | Investment plus upkeep paid into track T this season |
| works_due | float | ≥ 0 | Travel & Map L (`works_upkeep_due_lt`) | Layer-2 works upkeep |
| goods_frac | float | 0.5 | data file *(guess)* | Share of sect spending that buys goods; the rest is burned (H) |
| mix[T,k] | float | Institutions → herb 1; Military → ore 0.6, beast 0.4; Holdings and Trade → ore 1 | data file *(guess)* | What each track uses |
| wmix[k] | float | ore 0.7, special 0.3 | data file *(guess)* | Works materials |
| shockD | float | −0.5–0.8 (summed, clamped) | Event Engine | Demand shocks |
| P_eff | float | ±player_cap · D_pre | calculated (G) | The player's bounded net buying; D_pre is D without P_eff |

**Output Range:** ≥ 0.
**Example:** heads 600 / 130 / 30 / 5 / 1 → 10,025; plus 60 · 50 = 3,000; × d_scale 1.1 = 14,328; plus Institutions
spending 327 · 0.5 = 163; plus the player's 400 = **14,891**.

### D. Stock (rule 8)

The stock_update formula is defined as:

`stock'[m,k] = min((1 − dk[k]) · max(0, stock + S − D), s_cap[k] · D)` · `short[m,k] = max(0, D − stock − S)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| dk[k] | float | herb 0.20, beast 0.10, special 0.03, ore 0.01 | data file *(guess)* | Spoilage a season |
| s_cap[k] | float | herb 2, beast 2, special 4, ore 6 (seasons of demand) | data file *(guess)* | Storage bound (Pillar 2); overflow is lost |
| short | float | ≥ 0 | calculated | Unmet demand, shown in the ledger; never carried as backlog |

**Output Range:** 0 to s_cap · D. Market stock is pooled goods in base value; an herb item the player holds still ages
by Item Database Formula B. Spoilage applies to the market pool only.
**Starting stock** is `(c_ref[k] − 1) · D` at calibration, so every price starts at 1.0.
**Example:** 0.80 · (3,000 + 15,662.4 − 14,891) = **3,017.1**; the cap (29,782) does not bind.

### E. Price and price_index (rules 10–11)

The market_price formula is defined as:

`c = (stock + S) / max(D, D_min[k])` · `P* = P_maxeff[k]` if c = 0, else `clamp((c / c_ref[k])^(−ε[k]), P_min[k], P_maxeff[k])` · `P' = clamp(P · (P*/P)^α, P / δ[k], P · δ[k])` · `price_index[r,k] = P'[m(r),k]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c_ref[k] | float | herb 1.5, beast 1.5, special 2, ore 2 | data file *(guess)* | Cover that means "normal" (1 + normal stock) |
| ε[k] | float | herb 0.7, beast 0.6, ore 0.4, special 0.8 | data file *(guess)* | How hard price answers cover |
| P_min[k] | float | herb 0.50, ore 0.70, beast 0.60, special 0.50 | data file *(guess)* | Floor |
| P_max[k] | float | herb 2.0, ore 1.6, beast 1.8, special 2.5 | data file *(guess)* | Ceiling while Open |
| P_maxeff[k] | float | herb 3.0, ore 2.2, beast 2.5, special 4.0 while Strained, else P_max | data file *(guess)* | The Strained ceiling (States) |
| c_short | float | 0.5 | data file *(guess)* | Cover below this makes the market Strained |
| α | float | 0.5 | data file *(guess)* | Partial adjustment toward P* |
| δ[k] | float | herb 1.25, ore 1.10, beast 1.20, special 1.30 | data file *(guess)* | Largest move a season (multiplicative) |
| D_min[k] | float | 0.05 · calibrated demand | data file | Avoids division by zero |

**Output Range:** P from P_min to P_max (P_maxeff while Strained). A herb shock reaches its ceiling in 3–4 seasons, an
ore shock in about 5 (from 1.0 with cover 0, a herb price crosses 2.0 in season 4 and an ore price crosses 1.6 in
season 5). Partial adjustment approaches P* without reaching it exactly. `price_index` is 1.0 for any region whose market has not ticked. Travel & Map's D_f stays in
0.75–1.25.
Linh thạch has no price: a mine's `price_index` is always 1.0, so its D_f is 1. A finished good with no main input
(a manual) uses P = 1.0.
**Example:** c = 18,662.4 / 14,891 = 1.2533; c / c_ref = 0.8355; herbs P* = 0.8355^−0.7 = 1.1341; P' = 1.00 · 1.1341^0.5
= **1.0649** (within δ); D_f = 1 + 0.5 · 0.0649 = **1.0325**.

**Stability.** The loop price → D_f → production → price has gain about α · ε_max · demand_elasticity = 0.5 · 0.8 · 0.5
= 0.20 with a one-season lag; below 1 it decays without overshoot. Acceptance requires `α · ε_max · demand_elasticity < 1`.

### F. Link capacity and flow (rules 12–14)

The link_flow formula is defined as (A the cheaper market, B the dearer):

`τ_AB = τ0 + τ_tile · d_AB / ((trade_mult_A + trade_mult_B) / 2)` (array link: `τ0 + τ_array`) ·
`gap = P_B · (1 − tar[O_B]) − P_A · (1 + τ_AB)`, no flow if gap ≤ 0 ·
`Q_close = gap / (ε[k] · (P_A / D_A + P_B / D_B))` · `Q_k = min(β · Q_close, avail_A)` · `avail_A = max(0, stock_A + S_A − D_A)` ·
`Cap_AB = cap_base · min(trade_mult_A, trade_mult_B) · safe_AB`; if `Σ_k Q_k > Cap_AB`, every Q_k scales by `Cap_AB / Σ_k Q_k` ·
`tariff_B += tar[O_B] · P_B · Q_k`, paid by B's commons pool (the importing buyers) into B's sect treasury


**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| τ0, τ_tile, τ_array | float | 0.05, 0.0005, 0.03 | data file *(guess)* | Transport cost as a share of price |
| d_AB | float | tiles | calculated | Seat hub to seat hub by road |
| tar[O] | float | Openness 1–4: 0.20 / 0.12 / 0.08 / 0.05; Openness 0: no link | data file *(guess)* | The importer's tariff (Sects rule 9, Openness) |
| β | float | 0.5 | data file *(guess)* | Closes at most half the gap a season; prevents ping-pong |
| cap_base | float | 6,000 base value | data file *(guess)* | Capacity per link a season; both directions share it |
| safe_AB | float | 0–1 | calculated: `clamp(1 − λ_road · dmg^M̄ · (1 − exp(−d_AB / (d_reach · t̄m))) − λ_war · war_route, 0, 1)`, M̄ and t̄m the means of both sects | Military cut on the route; war_route is 1 if war touches a region the road crosses |

Flows use last season's prices. **Output Range:** 0 to Cap_AB. Linked prices settle within (1 + tariff)(1 + transport),
about 1.15–1.25 apart; unlinked markets can sit 3–5× apart.
**Example:** herbs (ε 0.7). P_A 0.90, D_A 20,000; P_B 1.30, D_B 15,000; Openness 2 (0.12); 200 tiles; trade_mult 1.9 /
1.6; safe_AB 0.97: τ = 0.10714; gap = 1.144 − 0.99643 = 0.14757; Q_close = 0.14757 / (0.7 · 0.00013167) = 1,601.1;
**Q = 800.6**; Cap = 6,000 · 1.6 · 0.97 = 9,312; tariff to B = 0.12 · 1.30 · 800.6 = **124.9**.

### G. Shop price and the player's impact (rules 15–16)

The shop_price formula is defined as:

`buy = max(1, ceil(V · P[m,k] · bm[cls] · (1 − ch) · stp · mg_buy[p] − 1e-6))` ·
`sell = max(1, floor(V · P[m,k] · sr[cls] · (1 + ch) · sts · mg_sell[p] · (1 − tar_in) + 1e-6))` ·
`ch = clamp((Mị lực − 50) · 0.004, −ch_max, ch_max)` · `stp = 1 − 0.002 · St` (Sects F11) · `sts = 1 + 0.001 · St` ·
`P_eff[m,k] = clamp(Σ buys · V − Σ sells · V, −player_cap · D_pre, player_cap · D_pre)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| V | int | ≥ 1 | Item Database rule 9 | Base value; finished goods use their main input's class for P |
| bm, sr | float | raw goods 1.10 / 0.90; finished goods 1.5 / 0.6 | data file (finished: built `buy_markup`, `sell_ratio`; raw: *guess*) | The bulk spread (user decision 2026-11-14) |
| ch, ch_max | float | ±0.20 | data file *(guess)*; Mị lực step 0.004 built | Charm, now clamped |
| St | int | −100–100 | Sects (standing) | Standing lowers buy prices and lifts sell prices a little |
| mg_buy, mg_sell | float | city 1.0 / 1.0; town and market 1.05 / 0.95; village 1.15 / 0.90 | data file *(guess)* | Place margin |
| tar_in | float | tar[O] of this market if the item's `origin_market` ≠ m, else 0 | calculated (F) | Rule 16. An item is tagged with its market when bought, gathered or looted |
| player_cap | float | 0.10 | data file *(guess)* | The player's share of a season's demand |

**Raw goods trade at the bulk spread and place margin only:** charm and standing do not apply to them (`ch = 0`,
`stp = sts = 1`), or charm and standing at their limits would let a player buy and sell at one place for profit.
**Output Range:** buying and selling at one place never pays. Raw: lowest buy factor 1.10 > highest sell 0.90.
Finished: lowest buy 1.5 · 0.80 · 0.80 = 0.96 > highest sell 0.6 · 1.20 · 1.10 = 0.792. The player moves cover by at
most ±10 %, about ±4 % of price a season after α.
**Example:** a V 120 herb at P 1.065 in a village: buy 120 · 1.065 · 1.10 · 1.15 = 161.7 → **162**. Carried to a city
in B (P 1.30, tariff 0.12): sell 120 · 1.30 · 0.90 · 1.0 · 0.88 = 123.6 → **123**, a loss at settled prices. After a
shock that puts B at 2.0, the same herb sells for **190**: profit 28 before travel from the village, or 49 if it was
bought in a city (120 · 1.065 · 1.10 = 140.6 → 141).

### H. Money holders and balance (rule 5)

The money_balance formula is defined as:

`M' = M + F_mine − burn_works − burn_stone − burn_fees − burn_heirless − player_net` · `burn_works = (1 − goods_frac) · (Σ_T spend_T + Σ works_due)` · `burn_fees = f_burn · Σ teleport_fees` · `burn_heirless = lost_frac · W_dead` · `burn_stone` from J

**Holders** (each a stored ledger, Pillar 2): sect treasuries (Sects F3); NPC purses (per NPC, or per realm band per
market if per-NPC is too heavy: an ADR); one **commons pool** per market (towns, merchants and mine labour: the clients
who pay mission cash and fees, buy goods and receive the mine share sects do not collect); the player; and the **sink
ledger**, which counts what was burned so the harness can check `ΔM = F_mine − sinks` each season.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| M | float | ≥ 0 | World Database (sum of ledgers, player excluded) | Money in the world |
| player_net | float | any | calculated | Money that moved from the world's holders to the player this season (sales, loot, missions, stipends, less purchases and fees) |
| F_mine | float | ~124,000 | Travel & Map L | The only faucet; the holder collects `collect_mine` (I), the commons pool the rest |
| goods_frac | float | 0.5 | data file *(guess)* | As in C |
| f_burn | float | 0.5 | data file *(guess)* | Share of array fees burned powering arrays |
| lost_frac | float | 0.3 | data file *(guess)* | Share of an heirless death's purse lost (it can seed a hidden place) |
| W_dead | float | ≥ 0 | Living World Tick | Purses of NPCs who died this season with no heir or sect |
| M_0 | float | ~1,200,000 | data file *(guess)* | Starting money, about 10 seasons of the faucet |

| A season (guess) | Linh thạch |
|---|---|
| Faucet: mines | +124,000 |
| Works: investment ~63k and upkeep ~31k, half burned | −47,000 |
| Teleport fees, half burned | −1,500 |
| Heirless deaths (~50 × ~460 × 0.3) | −7,000 |
| Stone cultivation (J) | −60,000 to −75,000, rising with purses |
| **Net** | **about −6,500 to +8,500** |

**Output Range:** M ≥ 0 (a sink is paid only from money a holder has). Stone cultivation is spent from purses above a
reserve, so it grows with M and pulls it back: the money stock settles. Health: ΔM a year within −2 % to +5 %; world mean
price within 0.9–1.15; each commons pool at 2 or more seasons of its mission cash; no sect below its reserve for more
than 4 seasons outside war; no market and good at or above P_max for more than 40 seasons in a row.
**Who pays whom.** Sect goods spending (`goods_frac`) and the player's purchases go to the market's commons pool (the
sellers); the player's sales are paid by it. Tariffs are paid by the importing market's commons pool to its sect.
Mine output a sect does not collect goes to the commons pool; output of unworked (wild) sites goes half to the
lost-stash pool (K) and half to the commons pool.
**Commons pool rule.** A pool keeps 2–4 seasons of its mission cash *(guess)*. Above the band it posts more or bigger
missions; below it, fewer. Money then flows to cultivators, who burn it.

### I. Sect income: mine cash and goods (replaces Sects F3's `V_own` guess)

The sect_income formula is defined as:

`Inc_mine[s] = collect_mine · Σ_{mines held} value_lt` · `collect_mine = cm0 + (1 − cm0) · collect` ·
`G_coll[s,k] = collect · Σ_{r∈held} value_lt[r,k] · acc_r` · `G_sold[s,k] = max(0, G_coll − own_use[s,k] − kind_stipend[s,k])` ·
`Inc_goods[s] = Σ_k G_sold · P[m,k] · sell_bulk`, paid by the market's buyers (the commons pool) and limited by what the
pool can pay · `Inc_tariff[s] = Σ_links tariff + Σ player tariffs` ·
`V_own[s] = Σ_{mines} value_lt + Σ_k Σ_r value_lt[r,k] · acc_r · P[m,k]` (shown; no longer counted as cash)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cm0 | float | 0.5 | data file *(guess)* | Sects run the spirit-stone veins: collect_mine ≈ 0.54–0.80 |
| collect | float | 0.086–0.6 | Sects F2 | Holdings share of goods |
| own_use | float | ≥ 0 | C (`goods_frac · spend_T · mix`) | Goods the sect uses before selling |
| kind_stipend | float | 15 % of LK and TC stipends | data file *(guess)* | Part of stipends paid in pills and herbs |
| sell_bulk | float | 0.90 | G (raw sell factor) | What the sect gets per unit of value |

**Output Range:** ≥ 0. With these values the world's sects take about 70–74k of mine cash and ~15k of goods sales, and
spend stipends 41.8k + investment ~63k + upkeep ~31k: about 142k in and out *(economy-designer)*. Sects F3 reads
`Inc_mine + Inc_goods + Inc_tariff` in place of `collect · V_own`, and keeps tribute, the mission fee and its market tax,
now levied on the cash turnover of goods (`tf · trade_mult · share_s · Turn_m`; revised 2026-11-14).
`world_production_guess` (250,000) becomes a check: the world's non-mine value_lt at P = 1 lies within ±20 % of it.
**Example:** a tier-1 sect with 12,000 of mines at Holdings 6 (collect 0.323): collect_mine 0.6615, **Inc_mine 7,938**;
goods collected 0.323 · 38,000 = 12,274, own use 5,000 and kind stipends 1,100 leave 6,174 sold at P 1.05 · 0.90 =
**5,834**; three links at ~600 tariff each, **1,800**.

### J. Stone cultivation (user decision 2026-11-14)

Cultivators absorb linh thạch to cultivate, as in Tiên Nghịch and Già Thiên: cheap at the bottom, ruinous at the top.
This is the main money sink. The tu vi it gives is **Realms'** to own (Formulas I needs a stone term; handoff), so the
figures here are the economic side.

The stone_cultivation formula is defined as:

`tv_stone = min(stones / spt[rl], absorb_cap · rate)` · `stones_npc = s_spend · max(0, purse − reserve[rl])`, spent only up to `absorb_cap · rate · spt[rl]` · `burn_stone = Σ stones absorbed`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| spt[rl] | float | 1 / 4 / 20 / 150 / 1,000 stones per tu vi (QR / FE / CF / NS / DT) | data file *(guess)* | Steep by realm |
| absorb_cap | float | 0.5 | data file *(guess)* | Stones add at most half the season's normal rate (Realms Formulas I); a boost, never a replacement |
| rate | float | ≥ 0 | Realms Formulas I | The season's cultivation rate |
| s_spend | float | 0.3 | data file *(guess)* | NPC share of the purse above reserve spent a season |
| reserve[rl] | float | 2 × the realm's mission pay | data file *(guess)* | NPCs keep this |

**Output Range:** at the cap, a season's absorption costs about 15 stones in QR (rate ~30), 70 in FE, 2,000 in CF,
57,000 in NS and about 1.2 million in DT: one Nascent Soul at the cap burns about half the world's mine output, so the
highest realms absorb stones only from great wealth (a sect master, a treasure hoard). The sink is bounded by money,
not by heads.
**Example:** a Core Formation NPC (rate 200, reserve 1,200) with 3,000 stones spends 0.3 · 1,800 = 540, gaining
540 / 20 = **27 tu vi** (cap 100).

### K. Loot drawn from holders (Pillar 2, user decision 2026-11-14)

The loot_source formula is defined as:

`grant = min(budget, balance[source])` · `balance[source]' = balance[source] − grant` · source ∈ {victim purse, sect treasury, commons pool, lost-stash pool}

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| budget | int | Event Engine budget (`linh_thach_max` 80 / 600 / 5,000 / 40,000 / 300,000) | Event Engine | The most the event may grant |
| stash_share | float | 0.5 of wild-mine output | data file *(guess)* | Feeds the lost-stash pool for "found" money |

**Output Range:** 0 to the source's balance. No event creates money; the harness asserts it every season.
**Example:** a Hóa Thần event budgeted at 300,000 drawing on a lost-stash pool of 40,000 grants **40,000**, and the
narration is told the smaller sum.

## Edge Cases

`systems-designer` not consulted separately for this section (Lean mode); the cases below include those its Formulas
report raised. Review manually before production.

**Zero and limits**
- **If demand for a good is 0**: D_min (Formula E) stands in, so cover is large and the price falls toward its floor; stock fills to `s_cap · D_min` and the rest is lost.
- **If supply and stock are both 0**: cover is 0, P* is the Strained ceiling, and the price climbs at δ a season. The
  market turns Strained for that good, its places restock nothing of that class, and the ledger still shows a price.
- **If a market's places restock**: each place gets a share of the market stock in proportion to its settlement
  weight (city 8, town 4, market 3, village 1; Travel & Map L), as items drawn from that stock.
- **If a price reaches its floor or ceiling**: it stays there while cover holds; Travel & Map's D_f stays within
  0.75–1.25 whatever the price.
- **If summed shocks on one good leave their range in a season**: supply shocks are capped at 0.8 and demand shocks
  clamped to −0.5–0.8; the excess is logged and dropped.

**Politics**
- **If a region changes holder**: from the next tick its production joins the new market. It brings stock in
  proportion to its share of the old market's supply, and the new market's price for each good starts at the
  supply-weighted mean of the two markets' prices.
- **If a great sect falls**: its market closes, its links are deleted, and its stock is split among the victors'
  markets in proportion to the base value (`value_lt`) of the regions each gains. Its commons pool is split the same way.
- **If two markets go to war**: their link is cut from that season's tick. Flow is settled within each tick, so no goods
  are in transit.
- **If a market is Embargoed**: it has no links, Imp = Exp = 0, and outsiders (including the player when not a member)
  can neither buy nor sell there.
- **If a sect's Openness is 0**: no links; members still trade at its places.
- **If a sect has Trade 0**: it has no links, and its trade_mult is 1 for access.

**Money**
- **If a sink would take a holder below 0**: it takes only what the holder has; nothing goes negative.
- **If a commons pool cannot pay a mission's cash**: the mission is not posted, and a sect's goods sales are paid only up
  to the pool's balance (the rest of the goods stays as market stock).
- **If an event's loot budget exceeds its source**: the grant is the source's balance (Formula K), and the narration is
  told the smaller sum.
- **If an NPC dies with no heir or sect**: `lost_frac` of the purse burns, and the rest goes to the commons pool of the
  market where they died (it can seed a hidden place's treasure).
- **If a cultivator's purse is at or below reserve**: they absorb no stones that season.

**The player**
- **If the player trades beyond `player_cap`**: the trade goes through at the shop price, but the market's price stops
  moving with it.
- **If the player buys a raw good and sells it back at the same place**: the bulk spread makes it a loss (buy ≥ 1.10 ×
  value × P, sell ≤ 0.90 × value × P).
- **If the player sells an item with no `origin_market`** (from an old save): it is treated as local, with no tariff.
- **If the player carries goods into a market that closed or embargoed them on the way**: they cannot sell there;
  the goods keep their origin tag.
- **If a herb the player holds ages while carried**: its value follows Item Database Formula B; market spoilage applies
  only to market stock.

**Order and timing**
- **If a market has not ticked yet** (first season, or a new market): `price_index` is 1.0 and P = 1.0 for every good.
- **If flows on a link would reverse every season**: β (half the gap) and last season's prices prevent it; the harness
  checks that a link's flow does not change direction more than once in 8 seasons without a shock.

## Dependencies

| System | Type | Interface | Status | Bidirectional |
|---|---|---|---|---|
| Travel & Map (#25) | Hard | In: the seasonal production contract (rule 25, Formula L), population, settlement weight, regions and holders, road distances, travel and encounter risk. Out: `price_index` per good class (Formula H's `D_f`) | Designed, pending review | Yes (Dependencies lists #43) |
| Sects & Missions (#26) | Hard | In: development levels, Openness (tariffs, links), Tax, war state, holder changes, standing, investment and upkeep spent. Out: `Inc_mine`, `Inc_goods`, `Inc_tariff`, `V_own`, prices, the commons pool that pays mission cash | Approved | Yes; Sects F3 revised 2026-11-14 to read Formula I |
| Market (#20) | Hard (this system reworks it) | Out: price per good class per market, each place's stock, the seasonal restock, the bulk spread. Market keeps the buy and sell actions | Built, no GDD | No GDD to update; the code change is the rework |
| Item Database | Hard | In: value per unit (rule 9), good class, `origin_market` tag (new), herb ageing | In review | **Needs a note**: the `origin_market` tag on items |
| Realms & Bottlenecks (#8) | Hard for stone cultivation | Out: stones absorbed per cultivator. In: the season's cultivation rate | In review | **Needs a revision**: Formulas I gains a stone term (Formula J, `absorb_cap`, `spt`); its bot re-runs the NPC targets with it |
| Time & Turn (#4) | Hard | The season clock | Built | Index |
| Living World Tick (#28) | Hard | Calls this tick after the sect tick; NPC purses, deaths and heirs | Built (abstract) | Needs a note when it gets a GDD |
| Event Engine (#23) | Soft | In: shocks within budgets. Its `linh_thach_max` grants draw from holders (Formula K) | Built, no GDD | **Needs a revision**: event loot draws on a holder |
| LLM game master (#29) | Soft | Out: market state and notable price moves for narration. It never sets a price | Built | Note when it gets a GDD |
| Character Stats | Soft | Mị lực for finished-goods prices | Approved | Yes (Mị lực is already read by Market) |
| Game UI (#37) | Soft | The market ledger and price breakdown | Not started | Index |
| Balance Simulation Harness (#33) | Soft | Runs the economy tick for 400 seasons and checks the health metrics (Formula H) | Built | Index |

## Visual/Audio Requirements

`art-director` and `audio-director` not consulted (Lean mode; optional for an Economy system). Review manually before
production. The art style is still open (Travel & Map Open Question 11).

- **Price movement:** each price shows its change since last season as an up or down mark, with the size banded (small,
  large, at ceiling or floor). Colour is never the only cue.
- **Market state:** Open, Strained, Embargoed and Closed each have a distinct icon on the market ledger and on the map
  over the territory's seat.
- **Trade sound:** one short coin sound on a buy or sell; a different, muted sound when a trade is refused (Embargoed,
  Closed, Openness).


## Game Feel

Optional for an Economy system; one target only. A buy or sell updates the purse, the stock and the price breakdown in
the same frame as the click, and the season's price change is shown when the season turns, never mid-season.


## UI Requirements

`ux-designer` not consulted (Lean mode). Review manually before production. The first build is the Debug Terminal
(existing `src/debug_terminal/`), with retained screenshots for AC-RE-25 and AC-RE-26.

- **Price breakdown** (rule 17): every shop price opens a breakdown listing V, P, tariff, place margin, standing and
  Mị lực, each as one line, multiplying to the price shown; for raw goods charm and standing read "not applied".
- **Market ledger:** per market, per good class: supply, demand, stock, cover, short, price and its change, flow on
  each link (in and out), tariff paid, and the market's state. It also shows the market's links and why a link is
  missing (war, Openness 0, Trade 0, no border).
- **Origin tag:** an item carried from another market shows its `origin_market` and the tariff it will pay here.
- **Prices elsewhere:** the player sees another market's prices only as last seen there, with the season they were
  seen *(provisional; see Open Questions)*.
- **Money ledger (debug only):** M, the faucet, each sink and player_net for the season (Formula H), for the harness
  and for tuning.


## Cross-References

| This GDD | Other GDD | What is referenced | Status |
|---|---|---|---|
| Rules 1–2, 12 | sects.md rules 1–3, 9, 17–18; F2 | Great sects as countries, holder changes, Openness, Trade, Military, `trade_mult`, `road_danger` | Read |
| Rule 5; Formula I | sects.md rule 10; F3 | Sect income; `world_production_guess` replaced; mission cash paid by clients | Sects F3 revised 2026-11-14 |
| Rules 6, 11; Formulas A, B, E | travel-map.md rules 21, 24–25; Formulas H, L | The production contract, `price_index` and `D_f` | Read; Travel & Map Open Question 1 answered here |
| Formula G | sects.md F11 (`sect_standing_price`); built Market (`buy_markup`, `sell_ratio`, Mị lực 0.004) | Shop prices | Read |
| Rule 4; Formula G | item-database.md rule 9; Formula B | Value per unit; herb ageing | Read; **`origin_market` tag to be added** |
| Formula J | canh-gioi.md Formulas I, A | The cultivation rate; realm tu vi costs | **Realms Formulas I needs a stone term** |
| Formula K | Event Engine budgets (`events_budgets.json`, `linh_thach_max`) | Loot drawn from holders | **Event Engine revision** (no GDD yet) |


## Acceptance Criteria

Drafted with `qa-lead` (2026-11-14); the worked examples were re-checked against these criteria and corrected.
Tolerance: ±0.5 in the last digit shown; money ledgers must balance exactly.

**Fixtures** (`assets/data/economy.json` at the Formulas values; Travel & Map `demand_elasticity` 0.5, D_f clamped to
0.75–1.25)
- **FX-RE-B** (one market, herbs): seat region 12,000 herbs (d 0); region R2 8,000 at d 150; holder Trade 6, Military 6,
  Holdings 6 (collect 0.3231), peace; heads 600 / 130 / 30 / 5 / 1, W_set 60, d_scale[herb] 1.1, Institutions spending
  327; injected Imp 1,200, Exp 0; stock 3,000, P 1.00; player net buying 400.
- **FX-RE-2M** (two linked markets, herbs): A P 0.90, D 20,000, stock 5,000, S 20,000, trade_mult 1.9; B P 1.30, D 15,000,
  Openness 2 (tariff 0.12), trade_mult 1.6; 200 tiles hub to hub, safe_AB injected 0.97, peace.
- **FX-RE-SECT**: mines 12,000; Holdings 6; Σ herb value · acc 38,000; own use 5,000; kind stipends 1,100; P 1.05;
  3 links at 600 tariff each; commons pool 100,000.
- **FX-RE-WORLD**: FX-TM-WORLD plus the defaults, seeds FX-TM-SEEDS[0..9], 400 seasons, burn-in 40 seasons
  *(PROPOSAL)*; no scripted shocks and no player unless stated.

**Markets and money**
- **AC-RE-01** [Config] Rule 1. **GIVEN** the shipped world at season 0, **THEN** there are exactly 7 markets, one per
  great sect; every region is in exactly one market; no minor sect has a market.
- **AC-RE-02** [Integration] Rule 2. **GIVEN** region R2 moves from market X to Y in the Sects tick of season s, **THEN**
  in season s's economy tick R2's production counts for Y, Y receives stock_X · S_R2 / S_X, and Y's price is
  (S_Y · P_Y + S_R2 · P_X) / (S_Y + S_R2).
- **AC-RE-03** [Integration] Rule 2, sect falls. **GIVEN** X falls and regions worth 2/3 of its `value_lt` go to Y and
  1/3 to Z, **THEN** X's market is Closed, its links are deleted, and its stock and commons pool split 2:1.
- **AC-RE-04** [Logic] Rule 3. **GIVEN** a city, a town and a village in one market, **THEN** all use the same P[m,k], and
  their buy prices for one raw good differ only by the margins 1.0 / 1.05 / 1.15.
- **AC-RE-05** [Logic] Rule 4. **GIVEN** a finished good of V 100 whose main input is herb, P_herb 1.065, in a city,
  Mị lực 50, St 0, **THEN** buy = **160**; changing P_ore does not change it; a manual (no main input) uses P = 1.0.
- **AC-RE-06** [Logic] Rule 5. **THEN** the price table has 4 classes and no linh thạch; a mine's access is 1 and its
  `price_index` is 1.0.
- **AC-RE-07** [Harness] Rule 5, Formula H. **GIVEN** FX-RE-WORLD with a scripted player, **THEN** every season
  ΔM = F_mine − (burn_works + burn_stone + burn_fees + burn_heirless) − player_net exactly; missions, stipends,
  tribute, tax, tariffs and loot only move balances between holders.

**Supply, demand, stock and price**
- **AC-RE-08** [Logic] Formula A, rule 7. **GIVEN** FX-RE-B, **THEN** R2: reach **0.7292**, safe **0.9836**, acc
  **0.7172**; the seat at peace acc 1, with war_r 1 acc **0.60**; R2 with war_r 1 acc **0.4256**; at Trade 0 R2's reach
  is **0.5488**.
- **AC-RE-09** [Logic] Formula B, rule 6. **GIVEN** FX-RE-B, **THEN** h_f = **0.8154**; at Holdings 0 (collect 0.0857)
  h_f = **0.6571**; shockS 0.5 halves the production term.
- **AC-RE-10** [Integration] Formulas B → E. **GIVEN** FX-RE-B for one tick, **THEN** S **15,662.4**, D **14,891.0**,
  stock' **3,017.1**, P' **1.0649**, D_f **1.0325**.
- **AC-RE-11** [Logic] Formula C, rule 9. **GIVEN** FX-RE-B, **THEN** D = **14,891.0**; separately, Military spending
  1,000 adds ore +300 and beast +200; works_due 2,000 adds ore +700 and special +300; herb shockD +0.2 turns the
  population term 14,327.5 into **17,193.0**.
- **AC-RE-12** [Logic] Formula D, rule 8. **GIVEN** stock 3,000, S 15,662.4, D 14,891, **THEN** stock' **3,017.1** and
  short 0; stock 40,000 caps at **29,782**; stock 0 with S 10,000 gives stock' 0 and short **4,891**, which does not add
  to next season's D; ore with stock 10,000 and S = D gives **9,900**.
- **AC-RE-13** [Logic] Formula E, rule 10. **GIVEN** the AC-RE-10 inputs, **THEN** c **1.2533**, P* **1.1341**, P'
  **1.0649**. With cover 0 from P 1.0, herbs run 1.25, 1.5625, 1.9531, **2.4206** (Strained ceiling 3.0), crossing 2.0
  in season 4; ores run 1.10, 1.21, 1.331, 1.4641, **1.6105**, crossing 1.6 in season 5. With very large herb cover the
  price falls 0.80, 0.64, 0.5657 and never below 0.50.
- **AC-RE-14** [Logic] States. **GIVEN** herb cover 0.49, **THEN** the market is Strained with a herb ceiling of 3.0 and
  other ceilings unchanged; cover 0.50 at peace gives Open; war touching the territory gives Strained with every
  ceiling widened; Openness 0 gives Embargoed even when a good is short; a fallen sect gives Closed with no next state.
- **AC-RE-15** [Logic] Edge cases, zero and limits. **GIVEN** D = 0, **THEN** D_min stands in; **GIVEN** supply and stock
  0, **THEN** the market is Strained, its places restock nothing of that class, and the ledger shows P; **GIVEN** summed
  shockS 0.5 + 0.5, **THEN** 0.8 applies and the dropped 0.2 is logged.

**Feeding the land, and trade**
- **AC-RE-16** [Integration] Rule 11 → Travel & Map. **GIVEN** the AC-RE-10 tick, **THEN** both regions read
  `price_index` **1.0649** and D_f **1.0325**; P 3.0 gives D_f **1.25**, P 0.5 gives **0.75**; an unticked market gives 1.0.
- **AC-RE-17** [Logic] Rule 12. **THEN** a link exists only with a border or teleport array, no war between the two,
  Openness ≥ 1 and Trade ≥ 1 on both sides; flipping any one condition removes it at the next tick.
- **AC-RE-18** [Logic] Formula F, rule 13. **GIVEN** FX-RE-2M, **THEN** τ **0.10714**, gap **0.14757**, Q_close
  **1,601.1**, Q **800.6** from A to B, Cap **9,312**, tariff to B **124.9**. Separately: P_B 1.10 gives gap −0.0283 and
  no flow; avail_A 300 gives Q = 300; Cap 600 with herb 800 and ore 400 scales to 400 / 200; a teleport-array link gives
  τ **0.08**.
- **AC-RE-19** [Logic] Rule 14. **THEN** a tariff moves money from the importing market's commons pool to its sect's
  treasury and Inc_tariff; margins and standing change shop prices only, never P[m,k].
- **AC-RE-20** [Integration] War. **GIVEN** A and B go to war in season s, **THEN** their link is gone in s's tick and
  Imp = Exp = 0 between them; neither market is Embargoed by it.

**The player**
- **AC-RE-21** [Logic] Formula G, rule 15. **GIVEN** a raw herb of V 120 at P 1.065, **THEN** village buy **162**, city buy
  **141**, unchanged by Mị lực 100 or St 100. **GIVEN** a finished good of V 100 at P 1.0 in a city, Mị lực 100, St 50,
  **THEN** buy **108** and sell **75**; Mị lực 150 clamps charm to 0.20.
- **AC-RE-22** [Logic] Formula G. **GIVEN** the grid Mị lực 0–200, St −100–100, every margin, P 0.5–4.0, V 1–10,000,
  **THEN** for raw and finished goods the buy price is at least the sell price everywhere.
- **AC-RE-23** [Logic] P_eff. **GIVEN** D_pre 14,491 and player buys of 3,000, **THEN** P_eff = **1,449.1**, and further
  buys still go through at the shop price; sells of 3,000 give **−1,449.1**.
- **AC-RE-24** [Logic] Rule 16. **GIVEN** a herb of V 120 tagged with origin A, sold in a city in B, **THEN** at P 1.30
  with tariff 0.12 it sells for **123**, at P 2.0 for **190**; the same herb tagged B at P 2.0 sells for **216**; an item
  with no `origin_market` pays no tariff. **GIVEN** B is Embargoed or Closed and the player is not a member, **THEN**
  buying and selling are refused and the item keeps tag A.
- **AC-RE-25** [UI] Rule 17. **GIVEN** a raw and a finished item at a village in B, **THEN** the breakdown shows V, P,
  tariff, margin, standing and Mị lực, the parts multiply to the price shown, and for the raw item charm and standing
  show as not applied. Evidence: retained screenshots at `production/qa/evidence/re-price-breakdown-[date].png`.
  *(Provisional until UI Requirements is written.)*
- **AC-RE-26** [UI] Rule 17. **THEN** the ledger shows supply, demand, stock, cover, short, flow per link and state for
  all 4 classes, matching the tick's dump. Evidence: `production/qa/evidence/re-ledger-[date].png`. *(Provisional.)*

**Shocks and tick order**
- **AC-RE-27** [Logic] Rule 18. **GIVEN** a mock LLM that tries to set a price, **THEN** nothing changes; shocks come only
  from the Event Engine within its budgets.
- **AC-RE-28** [Integration] Rule 19. **GIVEN** an instrumented season, **THEN** steps a–g run in order, after Travel &
  Map production and the Sects tick; restock runs once a season and the old yearly restock is never called.

**Money formulas**
- **AC-RE-29** [Logic] Formula H. **GIVEN** a sink of 300 against a holder with 100, **THEN** it takes 100; no holder
  ever goes below 0.
- **AC-RE-30** [Logic] Formula I. **GIVEN** FX-RE-SECT, **THEN** collect_mine **0.6615**, Inc_mine **7,938**, G_coll
  **12,274**, G_sold **6,174**, Inc_goods **5,834.4**, Inc_tariff **1,800**. With a commons pool of 3,000, Inc_goods is
  3,000, the pool falls to 0, and **2,999.4** of base value returns to stock.
- **AC-RE-31** [Logic] Formula J. **GIVEN** a Core Formation NPC with rate 200 and reserve 1,200, **THEN** a purse of 3,000
  spends **540** for **27** tu vi; a purse of 10,000 spends **2,000** (the cap) for 100; a purse of 1,000 spends 0.
- **AC-RE-32** [Logic] Formula K. **GIVEN** a budget of 300,000 against a stash of 40,000, **THEN** the grant is
  **40,000**, the stash 0 and the narration is told 40,000; a budget of 5,000 against a victim's purse of 12,000 grants
  5,000 and leaves 7,000.

**Other systems**
- **AC-RE-33** [Integration] Sects. **THEN** sect income reads Inc_mine + Inc_goods + Inc_tariff, plus Sects' tribute,
  mission fee and market tax on cash turnover (Sects F3); the income code reads neither `world_production_guess` nor
  `collect · V_own`; V_own is display and a weight only.
- **AC-RE-34** [Integration] Event Engine. **GIVEN** an event budgeted at 600 drawing on a commons pool of 250, **THEN**
  the player gets 250, the pool loses 250, and AC-RE-07 still holds.
- **AC-RE-35** [Integration] Market. **THEN** at each season boundary every place restocks from its market's stock in
  proportion to its settlement weight; a class with stock 0 restocks nothing.

**Harness** (FX-RE-WORLD, all 10 seeds, seasons 41–400)
- **AC-RE-36** Anchor. At season 0 (P = 1) the world's non-mine `value_lt` is 200,000–300,000.
- **AC-RE-37** Money. Each year ΔM / M is within −2 % and +5 %.
- **AC-RE-38** Prices. The demand-weighted world mean price is 0.9–1.15 every season; every P stays within
  [P_min, P_maxeff]; every D_f within 0.75–1.25.
- **AC-RE-39** Pools. Every commons pool holds at least 2 seasons of its mission cash; no sect stays below its reserve
  for more than 4 seasons in a row outside war.
- **AC-RE-40** [Config + Harness] Stability. α · max ε · demand_elasticity = **0.20** (< 1). A single herb shockS 0.5 in
  one market at season 100 returns P within 5 % of its earlier level within 12 seasons and never undershoots by more
  than 2 % *(thresholds PROPOSAL)*.
- **AC-RE-41** Flow. On no link and class does flow change direction more than once in any 8 seasons without a shock
  at either end.
- **AC-RE-42** Ceiling. No market and class sits at or above P_max for more than 40 seasons in a row.
- **AC-RE-43** Determinism. The same seed run twice gives byte-identical ledgers.

**Performance** *(PROPOSAL; owner technical-director)*
- **AC-RE-44** [Harness] The market part of the tick (7 markets × 4 classes, ~20 regions, up to 21 links) runs in a
  median of 2 ms or less, p99 5 ms; stone cultivation over 5,000 NPCs 5 ms or less; the whole economy tick 8 ms or less on
  the reference machine over 400 seasons; memory does not grow past the bounded ledger history.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Do crafted goods (pills, artifacts, talismans) get their own supply and demand, or keep "value × input class price" (rule 4)? | economy-designer, user | Before the crafting and alchemy pass |
| 2 | Stone cultivation's tu vi side: Realms Formulas I gains a stone term (`absorb_cap`, `spt`), and the Realms bot re-runs the NPC targets (1 in 8 / 12 / 15 / 20; about 27 Nascent Soul, about 3 Hóa Thần) with it | Realms, Balance Harness | Realms revision |
| 3 | Stone grades: do low, middle, high and top-grade stones (hạ / trung / thượng / cực phẩm linh thạch) exist as items, so a Nascent Soul's 57,000 stones a season are fewer, rarer stones? Pure presentation or a separate good? | user, Item Database | Before the Item Database revision |
| 4 | ~~Sects F3 revision~~ **Done 2026-11-14.** Still open: re-derive the Sects budget table and `s_max`, rerun AC-SM-42 | economy-designer | Harness run |
| 5 | Event Engine: every linh thạch grant draws from a holder (Formula K), and the budgets are restated | Event Engine | Event Engine GDD |
| 6 | NPC purses: one per NPC or one per realm band per market? A technical decision → becomes an ADR | technical-director | `/create-architecture` |
| 7 | What the player knows of other markets' prices: last seen, rumours from travellers, or a sect's trade report by standing? | user, ux-designer | Before the market UI |
| 8 | All Formulas values are guesses: the harness run (AC-RE-36 to AC-RE-43) may move `d_scale`, `spt`, `cm0`, `goods_frac` and the price bands | economy-designer, Balance Harness | Before approval of the numbers |
| 9 | Performance budget (AC-RE-44) | technical-director | `/create-architecture` |
