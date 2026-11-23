# Regional Economy & Trade (Vùng Kinh Tế & Thương Lộ)

> **Status**: Amended 2026-11-23 by Provinces (#48), awaiting re-review: provinces are the land unit (Formulas units note; rules 3, 6, 7, 11, 16, 20), Formula A's access reads Provinces F6 (Victoria 3: infrastructure over usage) times the existing safety term, distance no longer sets access. Earlier: Approved (design-review 11, lean, 2026-11-14: 0 blocking, 9 recommended); amended 2026-11-14 by Trade Goods (#45): crafted classes (rule 4), `craft_in` and crafted demand (rule 9, Formula C), the scarcity factor (Formula G), in-kind workshops (Formula H), the `kind_stipend` split (Formula I), `bmix` herb 0.40 and pill 0.10 (Formulas C, L2); amended 2026-11-15 by Trade Goods Open Question 14 (user approved): raw rarity bands (rule 4, Formula C, per-band `D_min`), shelved stock (rule 8, Formulas D, E, F: unshelved goods skip the draw; price, cover and `avail_A` read shelved value; exports first; `max(0, D − craft_in)`; market-id-order world sums). Earlier: Needs Revision (design-review 10, lean, 2026-11-14: review-9 blocker resolved; 1 blocker, the tick order of F3 invest and spend_T, revised the same day, awaiting a re-review; design-review 9, lean, 2026-11-14: review-8 blockers confirmed resolved; 1 blocker, Sects AC-SM-08's stale Tr', revised the same day, awaiting a re-review; earlier: design-review 8, lean: 2 small blockers revised; design-system 2026-11-14, guided and lean: CD-GDD-ALIGN skipped, Lean mode; specialists consulted for Formulas (systems-designer, economy-designer) and Acceptance Criteria (qa-lead))
> **Author**: user + Claude
> **Last Updated**: 2026-11-23
> **Last Verified**: 2026-11-14
> **Implements Pillar**: Pillar 5 (A World That Remembers), Pillar 4 (Every Season Counts); touches Pillar 2 (Every Number Is Bounded and Visible)

## Summary

Regional Economy & Trade turns what the land produces into what people can buy. Each of the 7 great sects' territories
is one market: once a season it reads Travel & Map's production contract and sets stock and a price for each good class
(herbs, ores, beast parts, special goods) from supply and demand, and goods flow between linked markets up to the
capacity their sects' Trade allows. Mines are the only source of money, and stone cultivation (cheap at the bottom,
ruinous at the top) is its main sink. Prices also differ by province with access and local surplus, and every cultivator
buys a realm-sized provision basket each season for a cultivation bonus. The player sees prices that differ by place
and season, can carry goods where they are scarce, and every price shows its parts. It reworks the built Market (#20) and replaces Sects' production
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

## Player Fantasy

The world's wealth is real and finite. Every stone in your purse came out of a mine someone holds, and every price
tells you what the land is short of. The cultivator who reads the map, carries herbs from a glut to a famine and gets
home alive turns travel into cultivation resources; the one who ignores it pays village prices forever.
*(Accepted 2026-11-14 in the design-review revision.)*

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
   villages with a market flag) all sell from the market's price for each good, moved by their province's local price
   (rule 20). A place adds only its own stock depth and a settlement margin (rule 14). There is one **market price** per
   good per market; each place sells at its province's **local price** (rule 20), not at a price of its own.
   *(Design-review 7: the earlier "one price per market, not one per place" contradicted rule 20.)*

**Goods and money**

4. **Priced goods.** The priced goods are the resource kinds Travel & Map produces (ores, herbs, beast parts, special
   goods), by **good class**, and the **crafted classes** of Trade Goods (#45): pills, talismans and artifacts, each split
   by tier (Trade Goods rule 11, Formula E). A finished good prices from its own crafted class. Technique manuals are not
   priced (P = 1.0). The named goods inside a class are Trade Goods' compositions; this system keeps prices per class.
   *(Amended 2026-11-14 by Trade Goods; closes Open Questions 1 and 17.)* **Raw classes by rarity band** *(amended
   2026-11-15, Trade Goods rule 8a)*: each raw kind is priced in bands, `band = ceil(rarity / 2)` (rarity 1–2, 3–4,
   5–6), and only bands that hold goods exist, so the MVP has 8 raw classes (herb 1–3, ore 1–2, beast 1, special 1–2).
   A band takes its kind's parameters (`dk`, `s_cap`, `c_ref`, ε, the price bands, δ) and its own `D_min` (Formula E);
   the kind's demand is split across its bands by Formula C. Wherever this document writes a raw class k, read
   (kind, band).
5. **Linh thạch is money, not a good.** It has no price. Mines make it (Travel & Map rule 21), and it is the only source
   of new money. Missions, stipends, tribute, taxes and purchases move money and never create it (**mine output replaces
   the mission faucet; user decision 2026-11-14, Travel & Map Open Question 1**). Event and loot money is drawn from a
   named holder, never created (Formulas K). Money leaves the world through works and **stone cultivation**:
   cultivators absorb linh thạch for tu vi, cheap at the bottom and ruinous at the top (Formulas H, J; user decision
   2026-11-14). A sect takes its income from mine cash, from goods it sells, and from tariffs; collected goods are money
   only once sold (Formulas I).

**Supply, demand and price**

6. **Supply.** A market's supply of a good in a season is its provinces' production of that kind (Provinces #48, Formula F4) (the contract's `qty`),
   scaled by what the holder collects (Holdings, Sects rule 9) and by **market access** (rule 7), plus imports
   (rule 13). Stock carried over (rule 8) adds to supply when cover is computed.
7. **Market access** *(amended 2026-11-23, Provinces #48; Victoria 3's rule, user decision)*. Each province reaches its
   market at a rate from 0 to 1: its infrastructure over its usage (Provinces Formula F6: roads, rivers, landings and
   logistics buildings against the goods it ships), cut by Military safety and war. Distance no longer sets access; the
   sect's Trade level acts by capping logistics buildings (Provinces rule 9). An under-connected province uses part of
   its output locally and loses the rest to spoilage and loss. Access is computed per province each season.
8. **Stock carries over.** What a market does not sell in a season stays as stock. Stock decays by good class (herbs
   fast, ores almost never). Price depends on **cover**: stock plus supply, divided by demand. *(Amended 2026-11-15,
   Trade Goods rule 6 and Formula B.)* A named good whose pool value is under one unit is **unshelved**: spoilage,
   exports, demand and the `s_cap` overflow skip it, so it builds up, and price, cover and exports read only the
   **shelved stock** (`stock_sh`).
9. **Demand.** Demand for a good is population demand (the provision baskets NPCs actually buy, rules 21–22, plus
   settlement weight), plus the sect's own use (Institutions use herbs, Military uses ores and beast parts, works use
   ores), plus the player's purchases, plus the inputs workshops draw for crafting (`craft_in`, Trade Goods Formula G).
   Demand for the crafted classes is Trade Goods Formula H.
10. **Price.** Each season a market's price for a good moves toward the level its cover implies. It is bounded by a floor
    and a ceiling and limited in how far it may move in one season (inertia), so a shock shows over several seasons.
    The price is a multiplier on the Item Database's base value; 1.0 is the base.
11. **Prices feed the land.** At the end of the tick each province's **local price** (rule 20) for each good class is
    written back as the `price_index` that Travel & Map reads for its demand factor `D_f` (Travel & Map Formula H); a
    place reads its province's. `price_index` stays 1.0 for any province whose market has not ticked yet.

**Trade between markets**

12. **Links.** Two markets are **linked** when their territories border (or a teleport array joins them), neither is at
    war with the other, both sects' Openness allows it, and both have Trade level 1 or more. Links are recomputed once
    a season and come and go with politics.
13. **Flow.** Each season, goods flow along a link from the market with the lower price to the one with the higher
    price. The flow is limited by the link's **trade capacity** (set by both sects' Trade levels and cut by Military
    safety on the route) and stops when the price gap falls to tariff plus transport cost. Imports and exports both use
    the capacity.
14. **Tariffs and margins.** The importing sect charges its tariff (a sect dial, Sects rule 9) on goods that cross, and
    the revenue is the sect's income. A place's margin applies on top at the shop, and for finished goods the sect's standing price (Sects,
    `sect_standing_price`); raw goods ignore standing (Formula G).

**The player**

15. **Buying and selling.** The player buys and sells at a place at the local price (rule 20) for the item's class, times the
    Item Database value, the buy markup and sell ratio, Mị lực, standing and tariff. Raw goods (herbs, ores, beast
    parts, special goods) trade at a narrow **bulk spread** with no charm or standing; finished goods keep the built
    retail spread (Formulas G; user decision 2026-11-14). Each trade moves
    that market's supply or demand a little, bounded per season, so one player cannot corner a market.
16. **Carrying.** The player may buy in one market and sell in another. They pay the importing sect's tariff, spend the
    travel seasons and meet the encounter risk (Travel & Map), and are subject to the sect's Openness: an Embargoed or Closed
    market refuses outsiders (anyone who is not a member, at any rank, of
    the market's great sect or its vassal sects; (user decision 2026-11-14)). **Trading is a rewarded way to spend time** *(user decision 2026-11-14: a season spent
    travelling is a season not cultivating, so the trip must be able to pay)*. Between markets the price gap, which flow
    closes to tariff plus transport, bounds profit. **Between provinces of one market**, local prices (rule 20) differ by up
    to ±`loc_band`, so buying in a glut province and selling in a shortage province is allowed and untariffed. Only the
    player's own trading closes that gap: what the player buys and sells in a province enters its balance and moves its
    local price at the season's tick (Formula L1), and selling many goods at one place in one season fetches less for
    each (slippage, Formula G). A route therefore wears out as the player works it *(user decision 2026-11-14,
    design-review 6)*. It is also bounded by `loc_band`, by the travel seasons and encounter risk, and by what the
    player can carry and afford; the harness checks the resulting profit against realm mission pay (AC-RE-49).
    **Cargo** *(user decision 2026-11-14, design-review 7)*: how much the player can carry is set by their storage
    items (bags, storage rings; the Item Database owns the capacities), so trade ties into gear. Goods carried on the
    road are at stake: if the player dies or is defeated, the cargo is lost or taken by the victor (Formula K treats it
    as the victim's holding).
17. **Visible numbers.** Every price shows its parts (Item Database value, market price, tariff, margin, standing,
    Mị lực), and the market ledger shows supply, demand, stock, cover and flow for the season (Pillar 2).

**Change and the seasonal tick**

18. **Shocks come from events.** War raids (Sects F9), blights, gluts and embargoes change supply or demand by budgeted
    amounts set by the Event Engine. The LLM narrates a shock and never sets a price (Pillar 2).
19. **Tick order, once a season, after Travel & Map's production and Sects' season tick:** (a) read the contract;
    (b) apply holder changes; (c) compute access, supply and demand; (d) compute links and flows; (e) update prices and
    stock; (f) write `price_index`, each sect's trade income and production value; (g) restock the market places
    (replacing the built yearly restock). Local prices (rule 20) and provision baskets (rule 21) are worked out in step
    (e), after market prices.
    **Which season's values:** step (c) reads the **previous season's committed** `spend_T` (including the track share of
    Sects F3's `invest`) and `works_due`; the Sects tick computes this season's `invest` from the `Inc` that step (f) wrote
    last season, and it is counted in D next season. No step reads a value written later in the same tick, so the
    tick has no circular dependency (AC-RE-28, AC-RE-43). *(Design-review 10.)*
    **Trade Goods (#45)** adds to steps (a) the contract's `by_good` split, (c) crafted supply from last season's craft
    plan, `craft_in` and crafted demand, (e) compositions and scarcity factors, and (f) the next craft plan (Trade Goods,
    Tick placement).

**Local prices, realm needs and merchants** (user decisions 2026-11-14, after comparing EU5 and Victoria 3)

20. **Local prices.** Each province has a local price for each good: its market's price, moved by the province's own
    surplus or shortage, and moved more the poorer its access. At access 1 the local price equals the market price.
    Shops sell at the local price of the province they stand in, and Travel & Map's `price_index` for a place is its
    province's local price (Formula L1). *(After Victoria 3's market access; per province since 2026-11-23.)*
21. **Realm needs.** Every cultivator, the player and NPCs alike, has a **provision basket** each season that grows
    steeply by realm: mostly herbs, then ores (gear upkeep), beast parts and special goods. It is bought at local prices
    and consumed. A full basket gives a **provisioned** bonus to that season's cultivation rate; a part-filled basket
    gives part of it; an empty basket gives no bonus and no penalty (user decision: a bonus, not a slowdown). A sect
    member's stipend is sized to pay for about one basket at P = 1; when local prices rise, the same stipend buys a
    smaller share and the bonus shrinks, which is intended (prices bite) (user decision 2026-11-14); a loose cultivator pays from their own
    purse (Formula L2).
22. **Demand follows wealth.** An NPC fills as much of their basket as their purse allows above their reserve, before
    any stone cultivation. Population demand (Formula C) is the sum of what NPCs actually buy, so a poor territory
    demands less and its prices fall, **except for staple goods**: herbs and beast parts keep a **subsistence floor**
    of need that does not depend on purses (`sub_floor`, Formula C), so a famine still shows as a high price where the
    land is short *(user decision 2026-11-14, design-review 7: a poor famine region must not pay a trader least)*.
23. **Merchant charters (Post-MVP outline; no numbers, not built for MVP).** A cultivator, the player included, may buy a
    charter on a link from the sect that holds it. The charter pays upkeep each season and earns a share of the margin
    on that link's flow. War on the route or low Military can seize goods or void the charter. A sect sells charters
    only at a given standing and Trade level. *(After EU5's merchants and Victoria 3's companies.)*

### States and Transitions

A market has a state, recomputed each tick. When more than one condition holds, the state is the first of Closed,
Embargoed, Strained, Open. A war cuts only the link between the two warring markets (rule 12); it does not embargo
either market.


| State | Condition | Effect | Next |
|---|---|---|---|
| **Open** | Holder exists, no embargo, no good in severe shortage | Normal flow and prices | Strained, Embargoed, Closed |
| **Strained** | A good's cover is below `c_short`, or war touches the territory | Shortage: the ceiling widens for that good only. War: it widens for every good. Shortages may raise events | Open (cover recovers, war ends), Embargoed, Closed |
| **Embargoed** | The sect sets Openness 0 | No links, outsiders refused. A shortage still widens that good's ceiling, and a war touching the territory still widens every good's ceiling (user decision 2026-11-14, design-review 5) | Open or Strained (Openness raised) |
| **Closed** | The great sect has fallen | The market ends; its regions join the victors' markets | None |

### Interactions with Other Systems

| System | Direction | What passes between them |
|---|---|---|
| **Travel & Map** (#25) | in / out | In: the seasonal production contract (rule 25; Formula L), population, settlement weights, regions and holders, travel and encounter risk for carrying. Out: `price_index` per good class (Travel & Map Formula H's `D_f`). |
| **Sects & Missions** (#26) | in / out | In: development levels (Holdings, Trade, Military, Institutions), the Tax, Openness and tariff dials, holder changes, war state. Out: each sect's production value and trade income (replacing `world_production_guess`), market prices, and the client-paid mission cash pool. |
| **Market** (#20) | out | The market price per good class, each place's stock list, and the seasonal restock. Market keeps buying and selling at a place. |
| **Item Database** | in | Value per unit and good class of each item (rule 4). It owns value; this system owns the multiplier. |
| **Time & Turn** (#4) | in | The season clock that triggers the tick. |
| **Event Engine** (#23) and the **LLM game master** (#29) | in / out | In: shock events inside budgets. Out: market state changes and notable price moves for narration. |
| **Provinces** (#48) | in / out | In: production, potential, population and access per province (Provinces rule 6, F3, F4, F6). Out: local price per good per province, last season's market prices, and each province's own demand `D_loc` (Formula L1's `D_r`) and staple cover. |
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

**Units of land** *(amended 2026-11-23, Provinces #48)*. Wherever Formulas B, C (`D_r`), I and L1 write region r, read
**province** v: production is Provinces Formula F4, `W_set` is the province's mortal population (Provinces F3), and
`acc` is Formula A per province. A region's values, where a rule still names one, are the sums of its provinces.
Market-wide terms (`shockS[m,k]`, links, `fill`, sect spending) are unchanged.

**Good classes** k: herb, ore, beast, special, each by rarity band (rule 4, amended 2026-11-15: 8 raw classes in the
MVP), plus Trade Goods' crafted classes. Linh thạch is money (rule 5) and has no k.

**Anchors.** Mines make about 124,000 linh thạch a season (Travel & Map L). Non-mine goods are about 250,000 a season
in base value (Sects `world_production_guess`, which this GDD turns into an acceptance check, I). Census 3,936 / 844 /
191 / 27 / 3 by realm (Realms C2). Stipends a season 3 / 20 / 50 / 325 / 2,500 (Sects anchors); about 3,300 sect
members are paid about 41,800 a season, and the ~1,700 loose cultivators (tán tu) are paid nothing.

### A. Market access (rule 7)

The market_access formula is defined as:

*(Amended 2026-11-23, Provinces #48, user decision: Victoria 3's rule. The distance term `exp(−d / (d_reach ·
trade_mult))` is replaced by the province's infrastructure access; the safety term is kept.)*

`acc_v = inf_v · safe_v` · `inf_v = acc[v]` (Provinces Formula F6: `min(1, infra / usage)`) ·
`safe_v = clamp(1 − λ_road · dmg^M · (1 − inf_v) − λ_war · war_v, 0, 1)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| inf_v | float | 0–1 | Provinces F6 | Infrastructure over usage; Trade caps the logistics buildings behind it (Provinces rule 9) |
| dmg^M | float | 0.92^M | Sects F2 (`road_danger`) | Military safety |
| λ_road, λ_war | float | 0.10, 0.40 | data file *(guess)* | Loss to bandits on poorly served roads; loss in a province war touches |
| war_v | int | 0 or 1 | Sects (war state) | War touches the province's region this season |

**Output Range:** 0 to 1; 1 for a fully served province in peace. Linh thạch always has access 1 (money is not goods).
**Example:** infrastructure 7,292 against usage 10,000 (inf 0.7292), Military 6 (0.606), peace: safe = 1 − 0.1 · 0.606
· 0.2708 = 0.9836; **acc = 0.7172**. With war: safe = 0.5836, **acc = 0.4256**.

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
**Example:** herbs, a seat province of 12,000 (acc 1) plus a province of 8,000 (acc 0.7172), Holdings 6 (collect 0.3231, h_f 0.8154):
0.8154 · 17,737.6 = 14,463.2, plus imports 1,200 = **15,663.2**.

### C. Demand (rule 9)

The market_demand formula is defined as:

`D[m,k] = d_scale[k] · bmix[k] · (Σ_rl n[m,rl] · basket[rl] · max(fill[m,rl], sub_floor[k]) + set_w · W_set[m]) · (1 + shockD[m,k]) + goods_frac · (Σ_T spend_T · mix[T,k] + works_due · wmix[k]) + craft_in[m,k] + P_eff[m,k]`, clamped at 0

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n[m,rl] | int | ≥ 0 | contract `pop_cultivators` | Heads by realm in the territory |
| basket[rl] | float | 3 / 20 / 50 / 325 / 2,500 | data file, pegged to Sects' stipends | Provision basket per head a season, in base value (rule 21; Formula L2) |
| fill[m,rl] | float | 0–1 | calculated (L2), **previous season's value** (baskets are worked out after demand, tick step (e)); 1 at season 0 | Mean basket fill of the market's NPCs of that realm; 1 in the worked examples |
| sub_floor[k] | float | herb 0.5, beast 0.5, ore 0, special 0 | data file *(guess)*; user decision 2026-11-14, design-review 7 | Subsistence floor: the share of a basket of a staple good that counts as need even when purses cannot pay for it. The part above the actual `fill` is demand in goods only, like the `d_scale` part below: it moves stock and price and no money |
| W_set, set_w | float | ≥ 0; 50 | contract (Travel & Map Formula H2's population P, summed over the market's settlements; 2026-11-20); data file *(guess)* | Mortal population (in settlement-weight units) and its scale |
| bmix[k] | float | herb 0.40, ore 0.2, beast 0.2, special 0.1, pill 0.10 (sums to 1; herb was 0.5 before Trade Goods, 2026-11-14; FX-RE-B injects herb 0.5) | data file *(guess)*; the same table as L2 | The class's share of a basket and of settlement demand; the pill share is crafted demand (Trade Goods Formula H) |
| d_scale[k] | float | ~0.5–3 (guess; was 0.3–1.5 before `bmix` was applied here) | data file (computed once by a calibration tool) | Sets world demand so every class starts at P = 1 |
| spend_T | float | ≥ 0 | Sects F1, F3 | Investment plus upkeep paid into track T, including the track share of F3 `invest`; **the previous season's committed value** (rule 19; design-review 10). For T = Military, the mean of the last `mil_window` (4) committed seasons (Trade Goods H; user decision 2026-11-21) |
| works_due | float | ≥ 0 | Travel & Map L (`works_upkeep_due_lt`) | Layer-2 works upkeep |
| goods_frac | float | 0.5 | data file *(guess)* | Share of sect spending met in goods from its own collection (in kind, no cash; I); the rest is cash and burned (H) |
| mix[T,k] | float | Institutions → herb 1; Military → ore 0.42, beast 0.28, artifact 0.2, talisman 0.1 (Trade Goods Formula H; was ore 0.6, beast 0.4); Holdings and Trade → ore 1 | data file *(guess)* | What each track uses |
| craft_in[m,k] | float | ≥ 0 | Trade Goods Formula G | Raw inputs workshops draw for last season's craft plan (goods only, no money) |
| wmix[k] | float | ore 0.7, special 0.3 | data file *(guess)* | Works materials |
| shockD | float | −0.5–0.8 (summed, clamped) | Event Engine | Demand shocks |
| P_eff | float | ±player_cap · D_pre | calculated (G) | The player's bounded net buying; D_pre is D without P_eff |

**Raw rarity bands** *(amended 2026-11-15, Trade Goods rule 8a)*: for a raw class (κ, b) of kind κ and band b,
`D[m,(κ,b)] = bs[κ,b] · D_kind[m,κ] + craft_in[m,(κ,b)] + P_eff[m,(κ,b)]`, clamped at 0, where `D_kind` is the formula
above without its `craft_in` and `P_eff` terms, and `bs[κ,b] = Σ_m S[m,(κ,b)] / Σ_m S[m,κ]` is the band's share of
the kind's **season-0** world supply (fixed at calibration; sums are in market-id order). `craft_in` and `P_eff`
already belong to one band, so they are not split, and the bands of a kind sum to its demand (AC-TG-43). A kind with
one band has `bs` 1.

**Output Range:** ≥ 0.
**Example:** heads 600 / 130 / 30 / 5 / 1 → 10,025; plus 60 · 50 = 3,000; × bmix[herb] 0.5 × d_scale 2.2 = 14,328; plus Institutions
spending 327 · 0.5 = 163; plus the player's 400 = **14,891**.
**Calibration (season 0).** A calibration tool solves `d_scale[k]` once so that the **no-shock world is at rest** at
P = 1: stock decays at `dk` every season, so cover holds at `c_ref[k]` only if the world's supply runs a little above
its demand, `Σ_m S[m,k] / Σ_m D[m,k] = 1 + dk[k] · (c_ref[k] − 1)` (herb 1.10, beast 1.05, special 1.03, ore 1.01;
flows sum to 0 over the world). Then the steady stock is `(1 − dk) · (c_ref − 1) · D`, and the next season's stock is
the same: herb `0.8 · (0.4 + 1.10 − 1) · D = 0.4 · D`, cover `0.4 + 1.10 = 1.5` = `c_ref` (AC-RE-57). *(Design-review
7: with S = D herb stock decayed to 0, cover fell to 1.0 and the herb price drifted to about 1.33 with no shock.)*
Rough world check *(guess)*: baskets come to about 54.5k a season (census × basket), and settlement demand
is unknown until the map is final. About 160k of the 250k non-mine supply reaches markets (h_f ~0.8 × access ~0.8),
and sects use about 47k of it (`goods_frac` × investment and upkeep). That leaves a mean `d_scale` of about 1.2–2.1,
inside 0.5–3. A class that lands outside the range means the production or basket data are off; d_scale is not
stretched to hide it (AC-RE-51).
**What `d_scale` stands for.** Demand above the baskets NPCs actually pay for is the consumption this model does not
simulate: mortal households, crafting inputs and wastage. The subsistence part (`sub_floor` above `fill`) is the same
kind of demand: unpaid need, met by barter, charity and hunger. It is demand in goods only. No holder pays for the part
above the actual basket spend, so it moves prices and stock but no money (money moves only for purchases the harness
can see: baskets, sect goods spending, works and the player). The market ledger shows the two parts separately.

### D. Stock (rule 8)

The stock_update formula is defined as:

`stock'[m,k] = min((1 − dk[k]) · max(0, stock + S − D), s_cap[k] · max(D, D_min[k]))` · `short[m,k] = max(0, D − stock − S)` (D_min from E, so a market with no demand still keeps `s_cap · D_min` of stock)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| dk[k] | float | herb 0.20, beast 0.10, special 0.03, ore 0.01 | data file *(guess)* | Spoilage a season |
| s_cap[k] | float | herb 2, beast 2, special 4, ore 6 (seasons of demand) | data file *(guess)* | Storage bound (Pillar 2); overflow is lost |
| short | float | ≥ 0 | calculated | Unmet demand, shown in the ledger; never carried as backlog |

**Output Range:** 0 to s_cap · D. Market stock is pooled goods in base value; a harvested herb's age is fixed, so a
herb the player holds never changes value (only a Planted herb ages, Item Database Formula B; Trade Goods rule 10).
Spoilage applies to the market pool only.
**Shelved stock** *(amended 2026-11-15, Trade Goods Formula B)*: with named goods, this formula is the class total of
Trade Goods Formula B's per-good update, and it holds as written only while every good is shelved. In general the
workshops' draw (`craft_in`) and the player's purchases take specific goods first; the shared draw then takes
**exports first**, then spoilage `dk`, the rest of demand `max(0, D − craft_in)` and the `s_cap` overflow, from
**shelved** goods only, in proportion, and is **capped at the shelved value**. What the cap leaves undrawn stays as
unmet demand and unspoiled stock. The ledger stock is `stock' = Σ_g X'[m,g]`; price, cover and link flows read the
shelved stock `stock_sh' = Σ_{g: X' ≥ V_g} X'[m,g]` (Formulas E, F).
**Starting stock** is `max(0, c_ref[k] · D − S)` per market and class at calibration, so each market's cover starts
at `c_ref` and its price at 1.0. A market whose season-0 supply alone exceeds `c_ref · D` starts with stock 0 and a
cover above `c_ref` (a glut market, price below 1.0 from season 1); the calibration tool lists it (AC-RE-51).
*(Design-review 6: the earlier `(c_ref − 1) · D` gave cover `c_ref` only where S = D.)*
**Example:** 0.80 · (3,000 + 15,663.2 − 14,891) = **3,017.8**; the cap (29,782) does not bind.

### E. Price and price_index (rules 10–11)

The market_price formula is defined as:

`c = (stock + S) / max(D, D_min[k])` · `P* = P_maxeff[k]` if c = 0, else `clamp((c / c_ref[k])^(−ε[k]), P_min[k], P_maxeff[k])` · `P' = clamp(P · (P*/P)^α, P / δ[k], P · δ[k])` · `price_index[r,k] = p_loc[r,k]` (Formula L1; at access 1, the seat, this equals `P'[m(r),k]`)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c_ref[k] | float | herb 1.5, beast 1.5, special 2, ore 2 | data file *(guess)* | Cover that means "normal" (1 + normal stock) |
| ε[k] | float | herb 0.7, beast 0.6, ore 0.4, special 0.8 | data file *(guess)* | How hard price answers cover |
| P_min[k] | float | herb 0.50, ore 0.70, beast 0.60, special 0.50 | data file *(guess)* | Floor |
| P_max[k] | float | herb 2.0, ore 1.6, beast 1.8, special 2.5 | data file *(guess)* | Ceiling while Open |
| P_maxeff[k] | float | herb 3.0, ore 2.2, beast 2.5, special 4.0 while Strained, or while Embargoed with a shortage of that good or a war touching the territory (States), else P_max | data file *(guess)* | The Strained ceiling (States) |
| c_short | float | 0.5 | data file *(guess)* | Cover below this makes the market Strained |
| α | float | 0.5 | data file *(guess)* | Partial adjustment toward P* |
| δ[k] | float | herb 1.25, ore 1.10, beast 1.20, special 1.30 | data file *(guess)* | Largest move a season (multiplicative) |
| D_min[k] | float | `max(1, 0.05 · calibrated D[m,k])`, ≥ 1 base value | data file | Demand floor used wherever D divides or caps (D, E, F). The absolute floor of 1 keeps a market with no heads, settlements or spending finite *(design-review 7: 0.05 · calibrated demand was 0 there, and F divided by raw D)* |

**Shelved cover** *(amended 2026-11-15, Trade Goods Formula B)*: for a raw class, cover reads the shelved parts,
`c = (stock_sh + S_sh) / max(D, D_min[k])`, with `S_sh` the supply of the class's shelved goods this season. A class
whose goods are all under one unit has c = 0 and reads as short, so its price rises and it draws imports instead of
looking full while its shelves are empty. With every good shelved this is the formula above. Each raw band has its
own `D_min = max(1, 0.05 · calibrated D[m,(κ,b)])`.

**Output Range:** P from P_min to P_max (P_maxeff while Strained). A herb shock reaches its ceiling in 3–4 seasons, an
ore shock in about 5 (from 1.0 with cover 0, a herb price crosses 2.0 in season 4 and an ore price crosses 1.6 in
season 5). Partial adjustment approaches P* without reaching it exactly. `price_index` is 1.0 for any region whose market has not ticked. Travel & Map's D_f stays in
0.75–1.25.
Linh thạch has no price: a mine's `price_index` is always 1.0, so its D_f is 1. A technique manual uses P = 1.0;
the crafted classes take Trade Goods Formula E's parameters.
**Example:** c = 18,663.2 / 14,891 = 1.2533; c / c_ref = 0.8355; herbs P* = 0.8355^−0.7 = 1.1341; P' = 1.00 · 1.1341^0.5
= **1.0649** (within δ); D_f = 1 + 0.5 · 0.0649 = **1.0325**.

**Stability.** The loop price → D_f → production → price has a direct gain of about α · ε_max · demand_elasticity =
0.5 · 0.8 · 0.5 = 0.20 with a one-season lag. That estimate leaves out the stock carry-over (stock decays only at
`dk`, so a lasting supply change moves cover by up to `1/dk` times as much, capped by `s_cap`) and the basket fill loop
(L2), both of which raise the gain. Design-review 6 estimated that herb prices may ring after a shock and that special
goods, which barely spoil, may cycle between floor and ceiling. Stability is therefore not claimed here: the harness
tests it with a herb and a special-class shock (AC-RE-40), and α, δ or `s_cap[special]` are tuned if it fails. The
direct-gain check `α · ε_max · demand_elasticity < 1` stays as a necessary condition, not a sufficient one.

### F. Link capacity and flow (rules 12–14)

The link_flow formula is defined as (A the cheaper market, B the dearer):

`τ_AB = τ0 + τ_tile · d_AB / ((trade_mult_A + trade_mult_B) / 2)` (array link: `τ0 + τ_array`) ·
`gap = P_B · (1 − tar[O_B]) − P_A · (1 + τ_AB)`, no flow if gap ≤ 0 ·
`Q_close = gap / (ε[k] · (P_A / (c̃_A · D̃_A) + P_B / (c̃_B · D̃_B)))` · `D̃ = max(D, D_min[k])` (E) · `c̃ = max(c, c_short)` (each market's cover from last season's ledger, Formula E; the floor keeps an empty market finite) · `Q_k = min(β · Q_close, avail_A)` · `avail_A = max(0, stock_A + S_pre,A − D_A)` (`S_pre` is supply before this tick's imports and exports; `Imp`/`Exp` are added to S afterwards) ·
`Cap_AB = cap_base · min(trade_mult_A, trade_mult_B) · safe_AB`; if `Σ_k Q_k > Cap_AB`, every Q_k scales by `Cap_AB / Σ_k Q_k` ·
`tariff_B += tar[O_B] · P_B · Q_k`, paid by B's commons pool (the importing buyers) into B's sect treasury


**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| τ0, τ_tile, τ_array | float | 0.05, 0.0005, 0.03 | data file *(guess)* | Transport cost as a share of price |
| d_AB | float | tiles | calculated | Seat hub to seat hub by road |
| tar[O] | float | Openness 1–4: 0.20 / 0.12 / 0.08 / 0.05; Openness 0: no link | data file *(guess)* | The importer's tariff (Sects rule 9, Openness) |
| β | float | 0.5 | data file *(guess)* | Closes at most half the gap a season; prevents ping-pong |
| c̃_A, c̃_B | float | ≥ c_short (0.5) | calculated (E, last season) | Cover of each market, floored; price moves `ε · P / c` per unit of cover, so a thin market's price answers a small import |
| cap_base | float | 6,000 base value | data file *(guess)* | Capacity per link a season; both directions share it |
| safe_AB | float | 0–1 | calculated: `clamp(1 − λ_road · dmg^M̄ · (1 − exp(−d_AB / (d_reach · t̄m))) − λ_war · war_route, 0, 1)`, M̄ and t̄m the means of both sects | Military cut on the route; war_route is 1 if war touches a region the road crosses |

Flows use last season's prices. **Resolution order (deterministic, AC-RE-50):** links are processed in ascending
`(id_A, id_B)` order of their two market ids, and within a link the classes in the order herb, ore, beast, special.
`avail_A` is **depleted** by each flow taken from A, so a market on several links cannot export the same stock twice; a
link's `Cap_AB` is spent by its classes in that order before scaling. No random choice enters. *(Amended 2026-11-15,
Trade Goods Formula B.)* Within a kind the raw bands run low to high, and the crafted classes follow the raw ones in
crafted-class id order. For a raw class, `avail_A = max(0, Σ_{g shelved} X_pre[A,g] − max(0, D_A − craft_in_A))`
replaces the form above: it reads shelved value only (`X_pre`, Trade Goods Formula B, already has the craft draw and
the player's purchases taken out), and the inner `max` stops a negative `P_eff` (down to −0.10 · `D_pre`) from lifting
`avail_A` above the shelved value where demand is mostly workshops. Exports come first in the shared draw (Formula D),
so they always fit. Every sum over markets (calibration, Trade Goods' `wsh_g`) runs in **market-id order**, never
processing order, so results are bit-identical whatever order markets tick in. **Output Range:** 0 to Cap_AB. Linked prices settle within (1 + tariff)(1 + transport),
about 1.15–1.25 apart; unlinked markets can sit 3–5× apart.
**Example:** herbs (ε 0.7). P_A 0.90, D_A 20,000, cover 1.25; P_B 1.30, D_B 15,000, cover 1.0; Openness 2 (0.12);
200 tiles; trade_mult 1.9 / 1.6; safe_AB 0.97: τ = 0.10714; gap = 1.144 − 0.99643 = 0.14757; Q_close = 0.14757 /
(0.7 · (0.9 / 25,000 + 1.3 / 15,000)) = 0.14757 / (0.7 · 0.00012267) = 1,718.6; **Q = 859.3**; Cap = 6,000 · 1.6 ·
0.97 = 9,312; tariff to B = 0.12 · 1.30 · 859.3 = **134.1**.

### G. Shop price and the player's impact (rules 15–16)

The shop_price formula is defined as:

`buy = max(1, ceil(V · p_loc[r,k] · sf[m,g] · bm[cls] · (1 − ch) · stp · mg_buy[p] − 1e-6))` ·
`sell = max(1, floor(V · p_loc[r,k] · sf[m,g] · sr[cls] · (1 + ch) · sts · mg_sell[p] · (1 − tar_in) · slip + 1e-6))` ·
`slip = (1 + (q_sold[p,k] + V) / Dp[p,k])^(−ε[k])` · `Dp[p,k] = max(1, D_r[r,k] · w_p / Σ_{p'∈r} w_p')` ·
`ch = clamp((Mị lực − 50) · 0.004, −ch_max, ch_max)` · `stp = 1 − 0.002 · St` (Sects F11) · `sts = 1 + 0.001 · St` ·
`P_eff[m,k] = clamp(Σ buys · V − Σ sells · V, −player_cap · D_pre, player_cap · D_pre)` (a finished good counts against its own crafted class, Trade Goods Formula E; a manual counts against none)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| V | int | ≥ 1 | Item Database rule 9 | Base value; finished goods use their own crafted class for P (rule 4) |
| sf[m,g] | float | ~0.5–1.5 | Trade Goods Formula D | Scarcity factor of the named good in this market (normalised per class pool); 1 for crafted classes and manuals |
| bm, sr | float | raw goods 1.10 / 0.90; finished goods 1.5 / 0.6 | data file (finished: built `buy_markup`, `sell_ratio`; raw: *guess*) | The bulk spread (user decision 2026-11-14) |
| ch, ch_max | float | ±0.20 | data file *(guess)*; Mị lực step 0.004 built | Charm, now clamped |
| St | int | −100–100 | Sects (standing) | Standing lowers buy prices and lifts sell prices a little (finished goods only). Sects F11's refusal at St ≤ −30 applies to the sect's own stock; market places never refuse on standing, only when Embargoed or Closed (rule 16) |
| mg_buy, mg_sell | float | city 1.0 / 1.0; town and market 1.05 / 0.95; village 1.15 / 0.90 | data file *(guess)* | Place margin |
| tar_in | float | tar[O] of this market if the item's `origin_market` ≠ m, else 0 | calculated (F) | Rule 16. The tag changes only when a shop sells the item (to the shop's market), when it is gathered (to the market where it is gathered) or crafted (Trade Goods Formula I); gifts, loot, theft and carrying keep it (user decision 2026-11-14) |
| loc_band_fin | float | 0.25 | data file *(guess)*; user decision 2026-11-14 | Narrower local band for finished goods' shop prices (L1's `loc_band` is 0.5 for raw goods) |
| player_cap | float | 0.10 | data file *(guess)* | The player's share of a season's demand |
| slip | float | 0–1 | calculated | Sell slippage at one place within a season (user decision 2026-11-14, design-review 6). 1 at the first sale of a small item; falls as the player sells more of that class there. Never applies to buys (buys are bounded by the shelf, Edge Cases) |
| q_sold[p,k] | float | ≥ 0 | calculated | Base value the player has already sold of class k at place p this season; resets at the season tick. A finished good counts against its own crafted class; a manual has slip 1 |
| Dp[p,k] | float | ≥ 1 | calculated (L1's `D_r`) | The place's share of its region's demand for the season, by settlement weight `w_p` (city 8, town 4, market 3, village 1; Travel & Map L). The floor of 1 keeps a region with no demand finite: it buys at the floor price |

**Raw goods trade at the bulk spread and place margin only:** charm and standing do not apply to them (`ch = 0`,
`stp = sts = 1`), or charm and standing at their limits would let a player buy and sell at one place for profit.
**Output Range:** buying and selling at one place never pays. **Carrying between places can pay by design** (rule 16;
user decision 2026-11-14): with p_loc spread over ±`loc_band`, a raw good bought at the lowest local price (factor
1.10 · 0.5 = 0.55 of P) and sold at the highest (0.90 · 1.5 = 1.35 of P) returns up to about 2.4×, before travel. Real
spreads are smaller (a herb region at 0.656 against a short one near 1.4 P in L1: about 1.8×), and the trip costs seasons and risk.
These are first-trip figures: the player's purchases raise the glut region's local price and their sales lower the
short region's at the next tick (L1), and `slip` lowers each further sale within the season, so a worked route
returns less each time (AC-RE-49, AC-RE-55, AC-RE-56).
Finished goods carried between regions of one market can return more: buying at the lowest local price (0.5 · 1.5 · 0.8 ·
0.8 = 0.48 of P) and selling at the highest (1.5 · 0.6 · 1.2 · 1.1 = 1.19 of P) is about **2.5×** before travel. **Decided 2026-11-14 (design-review 3, user):** finished goods use a narrower local band,
`loc_band_fin` 0.25, applied as `p_loc` clamped to `P · (1 ± loc_band_fin)` in their shop prices only (raw goods keep
`loc_band` 0.5). The same trip then returns at most 0.75 · 1.5 · 0.8 · 0.8 = 0.72 of P bought and 1.25 · 0.6 · 1.2 · 1.1
= 0.99 of P sold, about **1.4×** before travel. No same-season resale rule is needed. AC-RE-49 still tests finished goods as well as raw.
Raw: lowest buy factor 1.10 > highest sell 0.90 *at the same local price*.
Finished: lowest buy 1.5 · 0.80 · 0.80 = 0.96 > highest sell 0.6 · 1.20 · 1.10 = 0.792. The player moves cover by at
most ±10 %, about ±4 % of price a season after α.
**Example:** a V 120 herb at P 1.065 in a village: buy 120 · 1.065 · 1.10 · 1.15 = 161.7 → **162**. Carried to a city
in B (P 1.30, tariff 0.12): sell 120 · 1.30 · 0.90 · 1.0 · 0.88 = 123.6 → **123**, a loss at settled prices. After a
shock that puts B at 2.0, the same herb sells for **190**: profit 28 before travel from the village, or 49 if it was
bought in a city (120 · 1.065 · 1.10 = 140.6 → 141). These sells assume a small sale (slip ≈ 1).
**Slippage example:** a city in a region with herb `Dp` 2,000, `p_loc` 1.0, an untagged V 120 herb: the first sale has
slip (1 + 120 / 2,000)^−0.7 = 0.960 and sells for **103**; after 1,000 already sold that season, slip 0.7325 and **79**;
after 2,000, slip 0.603 and **65**.

### H. Money holders and balance (rule 5)

The money_balance formula is defined as:

`M' = M + F_mine − burn_works − burn_stone − burn_fees − burn_formation − burn_abode − burn_craft − burn_heirless − player_net` · `burn_works = (1 − goods_frac) · (Σ_T spend_T + Σ works_due)` (`spend_T` here is **this season's actual** spending, including the track share of Sects F3's `invest`, the treasury rule below; only Formula C's D reads the previous season's, rule 19) · `burn_fees = f_burn · Σ teleport_fees` · `burn_heirless = lost_frac · W_dead` · `burn_stone` from J · `burn_formation` = laid diagrams' fuel + standing-array upkeep + protective triggers (Formations F2, rule 14, F5; added 2026-11-21) · `burn_abode` = abode grade raises + abode upkeep + claims (Cave Abode F1, F2, F4; added 2026-11-21) · `burn_craft` = craft fuel: Alchemy's brew fuel (F2), Artifact Refining's fuel and talisman ink (their quick specs), the player per craft and NPC workshops as one aggregate (added 2026-11-21)

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
| burn_formation | float | ≥ 0 | Formations (#17) F2, F5, rule 14 | Stones burnt this season laying combat diagrams (NPCs as an aggregate), building and raising arrays of every kind and diagrams (Formations F3, rule 17), on standing-array upkeep and on protective triggers; teleport jump fees stay in `burn_fees` |
| burn_abode | float | ≥ 0 | Cave Abode & Home Works (#47) F1, F2, F4 | Stones spent this season on abode grade raises, abode upkeep and claims; NPC abodes as one aggregate |
| burn_craft | float | ≥ 0 | Alchemy (#15) F2; Artifact Refining (#16), Talismans (#18) quick specs | Craft fuel burned this season (brew fuel, refining fuel, talisman ink): the player's per craft, NPC workshops' as one aggregate |
| M_0 | float | ~1,200,000 | data file *(guess)* | Starting money, about 10 seasons of the faucet |
| inv_miss | float | 0.5 | data file *(guess)*; user decision 2026-11-14, design-review 7 | Share of Sects F3's `invest` posted as missions from the treasury; the rest goes to the track F19 picks as `spend_T` |

| A season (**unverified estimates**; the harness derives the real figures) | Linh thạch |
|---|---|
| Faucet: mines | +124,000 |
| Works: investment ~63k and upkeep ~31k, half burned | −47,000 |
| Teleport fees, half burned | −1,500 |
| Heirless deaths (~50 × ~460 × 0.3) | −7,000 |
| Formation fuel, upkeep and triggers (Formations, 2026-11-21) | not derived |
| Abode grades, upkeep and claims (Cave Abode, 2026-11-21) | not derived |
| Craft fuel: brew fuel, refining fuel, talisman ink (2026-11-21) | not derived |
| Sects F3 `invest`, track share, cash half burned (inside `burn_works`) | self-adjusting: grows with what sects hold above their reserve |
| Stone cultivation (J), from mission and loot money above the basket only | about 5–10k without treasury missions; more as `inv_miss` missions reach cultivators |
| **Net** | **not derived; target ΔM a year −2 % to +5 % (AC-RE-37)** |

*(Design-review 6: the earlier table booked stone cultivation at 60–75k a season. With the basket pegged to the stipend
(AC-RE-48), a member living on the stipend has nothing left for stones, so that figure had no income behind it. The
treasury rule below supplies both a burn and the mission money that feeds stones.)*

**Output Range:** M ≥ 0 (a sink is paid only from money a holder has). Two sinks grow with money held: stone
cultivation (from purses above reserve) and the burned half of F3's track investment (from treasuries above their
reserve), so the money stock is
meant to settle; whether it does is the harness's to show (AC-RE-37), not a claim of this GDD. Health: ΔM a year within −2 % to +5 %; world mean
price within 0.9–1.15; each commons pool at 2 or more seasons of its mission cash; no sect below its reserve for more
than 4 seasons outside war; each sect's excess over its reserve near the treasury rule's `E*` (AC-RE-60); no market and good at or above P_max for more than 40 seasons in a row.
**Who pays whom.** The `goods_frac` share of a sect's spending on works and tracks is met **in kind**, from the goods
the sect collected (`own_use`, Formula I); it moves no cash and pays nothing to the commons pool. The other
`1 − goods_frac` share is cash and burns (`burn_works`). Stipends paid in kind (`kind_stipend`) are likewise goods, not
cash. *(User decision 2026-11-14, design-review 5: own-use goods are in kind only, so they are not also paid for.)*
Own use and kind stipends beyond what the sect collected of that class are **bought in cash at P from the commons pool**
(Formula I, `Buy_short`; a transfer, not a burn; design-review 6). The
player's purchases go to the market's commons pool (the sellers); the player's sales are paid by it. **Crafted goods**
(Trade Goods, Money): workshop output and craft inputs are in kind and move no cash; a crafted sale is paid by its buyer
to the commons pool, and a sale larger than the pool's balance pays only that balance. Tariffs are paid by the importing market's commons pool to its sect.
**Sects F3's other lines** each have one payer *(design-review 7)*, and every one is a transfer between holders:
- **Market tax** (`tf · trade_mult · share_s · Turn_m`): from the market's commons pool to the sect's treasury, limited by
  what the pool holds.
- **Tribute**: from the vassal's treasury to the overlord's treasury (`trib_out` = the overlord's `trib_in`).
- **Mission fee** (`fee · board_cash`): from the mission's client to the board's sect. The client is the commons pool for
  commons missions, and the posting treasury for treasury missions. A mission a sect's treasury posts on **its own
  board pays no fee**, so a treasury never pays itself.
- **Head's draw**: from the treasury to the head's purse (an NPC purse, or the player).
- **War cost** (Sects F9): from the treasury to its market's commons pool (suppliers and hired hands).
- **Teleport fees**: the `1 − f_burn` share that is not burned goes to the treasury of the sect that holds the array.
**Goods that cross a link** are paid for: the importing market's commons pool pays the exporting market's commons pool
`P_A · Q` per class, and keeps the rest of its sales (the margin up to `P_B`, less the tariff it hands to the sect).
The transport cost `τ` is a threshold only, with no goods lost and no money burned: it decides whether a gap is worth
closing, nothing more. A pool that cannot pay limits the flow to what it can pay (the rest stays in A as stock).
Mine output a sect does not collect goes to the commons pool; output of unworked (wild) sites goes half to the
lost-stash pool (K) and half to the commons pool.
**Commons pool rule.** A pool keeps 2–4 seasons of its mission cash *(guess)*. Above the band it posts more or bigger
missions; below it, fewer. Money then flows to cultivators, who burn it.
**Treasury rule** *(user decision 2026-11-14, design-review 7; replaces design-review 6's treasury band)*. Sects F3's
`invest = max(0, Tr + Inc − Cost − R) · inv_frac` (R = 4 · Cost, `inv_frac` 0.5) is the **only** rule that spends a
treasury's surplus. Of `invest`, `inv_miss` (0.5) is **posted as missions from the treasury** (reserved at posting, so it
counts as spent for this rule and cannot be committed twice; paid to the cultivator on completion; returned to the treasury if
nobody takes it by the deadline, so next season's `invest` re-spends it; a transfer, no fee, see above; (user decision 2026-11-14)) and the rest goes to the track F19 picks as `spend_T`, met like all track
spending: `goods_frac` in kind from collected goods (`own_use`, I) and the rest in cash, burned (`burn_works`). The
treasury therefore pays in cash `inv_miss · invest + (1 − inv_miss) · (1 − goods_frac) · invest`; the in-kind part
lowers `Inc_goods` instead (I), so Sects F3's `Tr'` subtracts only that cash share (`c_inv = inv_miss + (1 − inv_miss) ·
(1 − goods_frac)`, 0.75 at the guesses), not the whole `invest`. With net income N = Inc − Cost held steady, the excess
over R after `invest` settles at `E* = N · (1 − c_inv · inv_frac) / (c_inv · inv_frac)`, about **1.67 N** at the
guesses, so a sect does not hoard without bound (AC-RE-60). *(The design-review 6 band rule
stacked a second spender on the same excess and kept a sect about 2N above its band forever, so AC-RE-37 failed by
construction.)*
**Example:** R 40,000, treasury 60,000, Inc = Cost (N 0): invest 0.5 · 20,000 = 10,000; **5,000** reserved for missions;
5,000 to the track, of which **2,500** cash is burned and 2,500 is met in kind from collected goods. The treasury ends at
**52,500**. At 40,000 or below, `invest` is 0.

### I. Sect income: mine cash and goods (replaces Sects F3's `V_own` guess)

The sect_income formula is defined as:

`Inc_mine[s] = collect_mine · Σ_{mines held} value_lt` · `collect_mine = cm0 + (1 − cm0) · collect` ·
`G_coll[s,k] = collect · Σ_{r∈held} value_lt[r,k] · acc_r` · `G_sold[s,k] = max(0, G_coll − own_use[s,k] − kind_stipend[s,k])` ·
`short_own[s,k] = max(0, own_use[s,k] + kind_stipend[s,k] − G_coll[s,k])` · `Buy_short[s] = Σ_k short_own[s,k] · P[m,k]`,
paid in cash by the sect to its market's commons pool (design-review 6; the goods were already in D, so they leave
stock once) ·
`Inc_goods[s] = Σ_k G_sold · P[m,k] · sell_bulk`, paid by the market's buyers (the commons pool) and limited by what the
pool can pay · `Inc_tariff[s] = Σ_links tariff + Σ player tariffs` ·
`V_own[s] = Σ_{mines} value_lt + Σ_k Σ_r value_lt[r,k] · acc_r · P[m,k]` (shown; no longer counted as cash)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cm0 | float | 0.5 | data file *(guess)* | Sects run the spirit-stone veins: collect_mine ≈ 0.54–0.80 |
| collect | float | 0.086–0.6 | Sects F2 | Holdings share of goods |
| own_use | float | ≥ 0 | `goods_frac · spend_T · mix`, with **this season's actual** `spend_T` (Formula C's D uses the previous season's, rule 19) | Goods the sect uses before selling |
| kind_stipend | float | 15 % of LK and TC stipends: 0.10 in pills from the sect's workshops, 0.05 in herbs (Trade Goods Formula H) | data file *(guess)* | Part of stipends paid in pills and herbs |
| short_own | float | ≥ 0 | calculated | Own use and kind stipends of class k beyond what the sect collected of k; bought in cash (`Buy_short`) |
| sell_bulk | float | 0.90 | G (raw sell factor) | What the sect gets per unit of value |

**Output Range:** ≥ 0. With these values the world's sects take about 70–74k of mine cash, ~15k of goods sales and their
tariffs from this system, and about 50–55k more from Sects F3's market tax, mission fees and tribute (in F3's tier-1
example, 9,120 + 4,000 + 976 of 29,668): **about 142k in**. Their cash out is the cash stipends (41.8k less the kind share, about 7k *(estimate)*, so about 35k) +
the cash half of investment and upkeep (the burned half of ~94k, about 47k), **about 82k**, plus the heads' draws. The
goods half of investment and upkeep (about 47k) and the kind stipends are met from collected goods and cost no cash.
The rest (about 60k a season *(estimate)*) goes to treasuries; above a sect's reserve, Sects F3's `invest` spends it,
and the treasury rule (Formula H) posts `inv_miss` of that as missions and sends the rest to the tracks, whose cash half
burns *(design-review 5, user decision: own use is in kind only; design-review 7, user decision: F3 invest is the only
spender)*. All the figures in this paragraph
are unverified estimates: design-review 6 put the world's own use plus kind stipends near 54k against about 60k collected,
which would leave goods sales nearer 6k than 15k. The harness settles it. Sects F3 reads
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

`tv_stone = min(stones / spt[rl], absorb_cap · rate)` · `stones_npc = s_spend · max(0, purse − reserve[rl] − basket_spend)` (L2: the basket is bought first, from the whole purse above reserve; `s_spend` caps stones only), spent only up to `absorb_cap · rate · spt[rl]` · `burn_stone = Σ stones absorbed`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| spt[rl] | float | 1 / 4 / 20 / 150 / 1,000 stones per tu vi (QR / FE / CF / NS / DT) | data file *(guess)* | Steep by realm |
| absorb_cap | float | 0.5 | data file *(guess)* | Stones add at most half the season's normal rate (Realms Formulas I); a boost, never a replacement |
| rate | float | ≥ 0 | Realms Formulas I | The season's cultivation rate |
| s_spend | float | 0.3 | data file *(guess)* | NPC share of the purse left above reserve, after the basket, that goes to stones a season. It never limits the basket (L2) |
| reserve[rl] | float | 2 × the realm's mission pay | data file *(guess)* | NPCs keep this |

**The player** *(user decision 2026-11-14, design-review 4)* chooses how many stones to absorb each season, up to
`absorb_cap · rate · spt[rl]`, at the same `spt` and `absorb_cap` as NPCs; there is no `s_spend` or `reserve` for the
player. The stones leave the player's purse and are destroyed. This is a player sink outside M (M excludes the player),
so AC-RE-07 still balances through `player_net`. Realms owns the tu vi term.

**Output Range:** at the cap, a season's absorption costs about 15 stones in QR (rate ~30), 70 in FE, 2,000 in CF,
57,000 in NS and about 1.2 million in DT: one Nascent Soul at the cap burns about half the world's mine output, so the
highest realms absorb stones only from great wealth (a sect master, a treasure hoard). The sink is bounded by money,
not by heads.
**Example:** a Core Formation NPC (rate 200, reserve 1,200) with 3,000 stones has 1,800 above reserve; the
basket takes 50, and 0.3 · (1,800 − 50) = 525 goes to stones, gaining 525 / 20 = **26.25 tu vi** (cap 100).

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

### L1. Local price (rule 20)

The local_price formula is defined as:

`p_loc[r,k] = clamp(P[m,k] · bal_r^(−ε[k] · (1 − acc_r)), P[m,k] · (1 − loc_band), P[m,k] · (1 + loc_band))` ·
`bal_r = ((value_lt[r,k] + sell_pl[r,k] + 1) / (D_r[r,k] + buy_pl[r,k] + 1)) / ρ[m,k]` · `ρ[m,k] = Σ_{r∈m} value_lt[r,k] / Σ_{r∈m} D_r[r,k]` (the market's own ratio, so a region that is typical of its market has bal = 1; ρ = 1 if either sum is 0; ρ leaves out the player's trades) ·
`D_r[r,k] = d_scale[k] · bmix[k] · (Σ_rl n[r,rl] · basket[rl] · max(fill[m,rl], sub_floor[k]) + set_w · W_set[r]) + goods_frac · works_due[r] · wmix[k]` (Formula C's population and works terms for the region's own heads, settlements and works, with the same `d_scale`, `bmix`, `sub_floor` and previous-season `fill`; sect track spending and the player are market-wide and are not assigned to regions) · `price_index[r,k] = p_loc[r,k]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| value_lt[r,k] | float | ≥ 0 | Travel & Map L | What region r makes of good k |
| D_r[r,k] | float | ≥ 0 | calculated (the formula above, from C's terms) | The region's own demand, in the same base-value units as `value_lt` |
| ρ[m,k] | float | > 0 | calculated | The market's total production over its total regional demand; normalises `bal_r` so d_scale does not bias local prices |
| acc_r | float | 0–1 | A (per province) | Market access; at 1 the local price is the market price |
| ε[k] | float | per class | E | Same elasticity as the market price |
| loc_band | float | 0.5 | data file *(guess)* | The farthest a local price may sit from its market's price |
| buy_pl, sell_pl | float | ≥ 0 | calculated (the player's trade ledger) | Base value of class k the player bought and sold at places in region r, read at the season's tick (step e), **with memory**: this season's trades plus `pl_mem` (0.5, guess) times last season's carried value, so a worked route recovers over a few seasons (user decision 2026-11-14). Uncapped: the `loc_band` clamp bounds the effect (user decision 2026-11-14, design-review 6) |

**Output Range:** P · (1 − loc_band) to P · (1 + loc_band). The +1 keeps a region with no output or no demand finite.
**Example** (market ratio ρ = 1, no player trades): a herb region at access 0.5 making 8,000 against 2,000 of demand: bal = 3.9985; 1.065 · 3.9985^−0.35 =
**0.656**. An ore-short region at access 0.5 (500 made, 3,000 needed): 1.0 · 0.1669^−0.2 = **1.43**.
**Player feedback example:** the player buys 2,000 of herbs in that herb region in a season: bal = 8,001 / 4,001 =
1.9998 and next season's local price is **0.836**. The player sells 2,000 of ore in the ore-short region: bal =
2,501 / 3,001 = 0.8334 and its local price falls to **1.037**. At access 1 the exponent is 0 and the
player moves only P, through `P_eff` (G).

### L2. Provision basket and bonus (rules 21–22)

The provision formula is defined as:

`basket_cost = Σ_k basket[rl] · bmix[k] · p_loc[r,k]` · `fill = min(1, spent / basket_cost)` · `prov = prov_max · fill` ·
NPC: `excess = max(0, purse − reserve[rl])`, `basket_spend = min(basket_cost, excess)` (the whole excess may go to the basket; a stipend-sized basket is therefore filled by the stipend), then `s_spend` of what is left goes to stones (J). `fill` used in Formula C is **last season's** value (the baskets are worked out in tick step (e), after demand in step (c))

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| basket[rl] | float | 3 / 20 / 50 / 325 / 2,500 | data file (pegged to stipends) | Base value of a full basket a season |
| bmix[k] | float | herb 0.40, ore 0.2, beast 0.2, special 0.1, pill 0.10 (herb was 0.5 before Trade Goods, 2026-11-14) | data file *(guess)* | What a basket is made of |
| prov_max | float | 0.15 | data file *(guess)* | The most a full basket adds to the cultivation rate; a factor `(1 + prov)` in Realms Formulas I (handoff) |
| spent | float | ≥ 0 | calculated | Value bought (or taken from the cultivator's own goods, at their value) this season |

**Output Range:** prov 0 to prov_max; never negative (no penalty). Goods in a basket are consumed; the money paid goes to
the commons pool (a transfer, not a burn).
**Example:** a Nascent Soul at local prices near 1.0 pays about **325** a season, about 11 % of capped Nascent Soul mission
pay, for +15 %; half a basket (162.5) gives +7.5 %. Buying where goods are cheap (L1) lowers the cost.

## Edge Cases

`systems-designer` not consulted separately for this section (Lean mode); the cases below include those its Formulas
report raised. Review manually before production.

**Zero and limits**
- **If demand for a good is 0**: D_min (Formula E, at least 1) stands in wherever D divides or caps (D, E, F). With stock or supply above `D_min`, cover is large and the price falls toward its floor; with stock and supply both 0, cover is 0 and the price climbs (AC-RE-62); stock fills to `s_cap · D_min` (Formula D) and the rest is lost; a link's `Q_close` stays finite.
- **If a region is poor and short of a staple** (famine): its herb and beast demand does not fall below `sub_floor` of its baskets (Formula C, rule 22), so the shortage still raises cover-based and local prices; the unpaid part moves goods and price, not money.
- **If supply and stock are both 0**: cover is 0, P* is the Strained ceiling, and the price climbs at δ a season. The
  market turns Strained for that good, its places restock nothing of that class, and the ledger still shows a price.
- **If a market's places restock**: each place's shelf is a **view** of the pool, not a withdrawal. It lists items whose
  base value is the place's share of the market's `stock'` in proportion to its settlement weight (city 8, town 4,
  market 3, village 1; Travel & Map L). Restock never changes `stock'`, and unsold shelf items are simply replaced next
  season. A player's purchase reaches the pool only through `P_eff` (Formula G), so it is never counted twice.
  *(User decision 2026-11-14, design-review 4.)*
- **If a price reaches its floor or ceiling**: it stays there while cover holds; Travel & Map's D_f stays within
  0.75–1.25 whatever the price.
- **If summed shocks on one good leave their range in a season**: supply shocks are capped at 0.8 and demand shocks
  clamped to −0.5–0.8; the excess is logged and dropped.

**Politics**
- **If a region changes holder**: in that same season's economy tick (rule 2; the Sects tick runs first) its production joins the new market. It brings stock in
  proportion to its share of the old market's supply, and the new market's price for each good starts at the
  supply-weighted mean of the two markets' prices.
- **If a great sect falls**: its market closes, its links are deleted, and its stock is split among the victors'
  markets in proportion to the base value (`value_lt`) of the regions each gains. Its commons pool is split the same way.
- **If two markets go to war**: their link is cut from that season's tick. Flow is settled within each tick, so no goods
  are in transit.
- **If a market is Embargoed**: it has no links, Imp = Exp = 0, and outsiders (anyone who is not a member of its great sect or a vassal, rule 16; the player included)
  can neither buy nor sell there.
- **If a sect's Openness is 0**: no links; members still trade at its places.
- **If a sect has Trade 0**: it has no links, and its provinces can hold no logistics buildings above level 0 (Provinces rule 9), so their access comes from land and `infra_old` alone.

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
  moving with it. The region's local price still moves with all of it (`buy_pl`, `sell_pl`, L1), within `loc_band`.
- **If the player sells a lot at one place in one season**: each sale is cheaper by `slip` (Formula G), down to the floor
  price of 1. `q_sold` resets at the season tick. A region with no demand for a class (`D_r` 0) buys it at about the floor.
- **If a sect's own use of a class exceeds what it collected**: it buys the shortfall in cash at P from the commons pool
  (`Buy_short`, Formula I). If its treasury cannot pay, it buys what it can, and its works and tracks progress with
  only the goods it had *(the Sects tick owns the progress rule)*.
- **If a sect's treasury is above its reserve**: Sects F3's `invest` spends `inv_frac` of the excess; `inv_miss` of that
  is posted as missions and the rest goes to a track, whose cash half burns (Formula H). Nothing else spends the excess,
  and `invest` never takes the treasury below its reserve.
- **If the player heads a sect** *(user decision 2026-11-14, design-review 7)*: the player cannot take missions posted
  from their own sect's treasury, and their draw stays under Sects' cap (F13's embezzlement ceiling). Their own sect's
  tariffs and tax apply to their trade as to anyone's.
- **If the player dies or is defeated while carrying goods**: the cargo is lost, or taken by the victor as loot drawn
  from the player's holding (Formula K); carried goods count against the carry cap of the player's storage items
  (rule 16).
- **If a mission is posted from a sect's treasury on its own board**: no mission fee is charged (Formula H).
- **If the player buys a raw good and sells it back at the same place**: the bulk spread makes it a loss (buy ≥ 1.10 ×
  value × P, sell ≤ 0.90 × value × P).
- **If the player sells an item with no `origin_market`** (from an old save): it is treated as local, with no tariff.
- **If the player carries goods into a market that closed or embargoed them on the way**: they cannot sell there;
  the goods keep their origin tag.
- **If the player carries a harvested herb**: its age is fixed, so its value never changes (Trade Goods rule 10, amended
  2026-11-15; only a Planted herb ages by Item Database Formula B); market spoilage applies only to market stock.

**Local prices and baskets**
- **If a local price passes its band**: it is clamped to P · (1 ± loc_band), and the breakdown says so.
- **If a region makes none of a good, or needs none**: the +1 in bal_r keeps the price finite, inside the band.
- **If a cultivator is a loose cultivator (tán tu, no stipend)** *(user decision 2026-11-14, design-review 3)*: they have
  no faucet of their own. Their purse starts at reserve and rises only from missions and loot, so their basket fill is 0
  until a mission or loot lifts the purse above reserve (rule 22, AC-RE-47). Their fill then tracks how much the commons
  pool posts (Formula H), which is intended. About 1,700 heads at fill near 0 lowers population demand, so the
  harness watches the tán tu realm bands' mean fill (AC-RE-47, Open Question 14).
- **If the player fills a basket from goods they carry**: those goods count at their value and are consumed.
- **If a basket good is short in the market**: the basket fills as far as stock allows; fill is below 1 and the bonus
  shrinks with it.

**Order and timing**
- **If a market has not ticked yet** (first season, or a new market): `price_index` is 1.0 and P = 1.0 for every good.
- **If flows on a link would reverse every season**: β (half the gap) and last season's prices prevent it; the harness
  checks that a link's flow does not change direction more than once in 8 seasons without a shock.

## Dependencies

| System | Type | Interface | Status | Bidirectional |
|---|---|---|---|---|
| Travel & Map (#25) | Hard | In: the seasonal production contract (rule 25, Formula L), population, settlement weight, regions and holders, road distances, travel and encounter risk. Out: `price_index` per good class (Travel & Map Formula H's `D_f`) | Designed, pending review | Yes (Dependencies lists #43) |
| Sects & Missions (#26) | Hard | In: development levels, Openness (tariffs, links), Tax, war state, holder changes, standing, investment and upkeep spent. Out: `Inc_mine`, `Inc_goods`, `Inc_tariff`, `V_own`, prices, the commons pool that pays mission cash | Approved | Yes; Sects F3 revised 2026-11-14 to read Formula I. **Note written 2026-11-14 (design-review 8; Sects F3 `Tr'` and example).** Still open: whether F3's `Cost` already counts the in-kind share of track spending (Open Question 15). The note covers (design-review 7): F3's `invest` is the only spender of a treasury's surplus; `inv_miss` of it is posted as missions (no fee on a sect's own board), and `Tr'` subtracts only the cash share `c_inv` of `invest` (the in-kind part lowers `Inc_goods`); each F3 line's payer (Formula H); a player head cannot take their own treasury's missions; `Buy_short` is a sect cash outflow |
| Market (#20) | Hard (this system reworks it) | Out: price per good class per market, each place's stock, the seasonal restock, the bulk spread. Market keeps the buy and sell actions | Built, no GDD | No GDD to update; the code change is the rework |
| Item Database | Hard | In: value per unit (rule 9), good class, `origin_market` tag (new), herb ageing, the carry cap of storage items (rule 16, new) | In review | Noted (its Open Question 25, 2026-11-14); the `origin_market` tag and the storage carry cap (design-review 7) wait on the Item Database revision |
| Realms & Bottlenecks (#8) | Hard for stone cultivation and baskets | Out: stones absorbed and basket fill per cultivator. In: the season's cultivation rate | In review | **Needs a revision**: Formulas I gains a stone term (Formula J, `absorb_cap`, `spt`) and a provisioned factor `(1 + prov)` (L2); its bot re-runs the NPC targets with both. Noted as its Open Question 24 (2026-11-14); the formula change waits on the Realms revision |
| Time & Turn (#4) | Hard | The season clock | Built | Index |
| World Generation & History (#27) | Hard | In: the fixed world's sites, each resource site's reserve picked per game from its hand-set sizes (World Generation Formula C), and the sects' authored start states | Designed 2026-11-15, pending review | Yes (its Dependencies lists #43) |
| Provinces (#48) | Hard | In: per-province production, population (`W_set`), access (F6). Out: local prices, `D_loc`, staple cover, market prices | Designed 2026-11-23, pending review | Yes (Provinces lists #43) |
| Living World Tick (#28) | Hard | Calls this tick after the sect tick; NPC purses, deaths and heirs | Built (abstract) | Needs a note when it gets a GDD |
| Event Engine (#23) | Soft | In: shocks within budgets. Its `linh_thach_max` grants draw from holders (Formula K) | Built, no GDD | **Needs a revision**: event loot draws on a holder |
| LLM game master (#29) | Soft | Out: market state and notable price moves for narration. It never sets a price | Built | Note when it gets a GDD |
| Character Stats | Soft | Mị lực for finished-goods prices | Approved | Yes (Mị lực is already read by Market) |
| Game UI (#37) | Soft | The market ledger and price breakdown | Not started | Index |
| Balance Simulation Harness (#33) | Soft | Runs the economy tick for 400 seasons and checks the health metrics (Formula H) | Built | Index |
| Formations (#17) | Soft | In: stones burnt: laid diagrams' fuel (Formations F2; NPC fuel as an aggregate), standing-array upkeep, protective triggers (F5), booked as `burn_formation` in Formula H; teleport arrays stay on `teleport_fees` | Designed 2026-11-21, pending review | Yes |
| Alchemy (#15) | Soft | In: brew fuel, booked as `burn_craft` in Formula H; pill prices from the craft margin | Designed 2026-11-21, pending review | Yes |
| Artifact Refining (#16), Talismans (#18) | Soft | In: refining fuel and talisman ink, booked as `burn_craft` | Quick specs only (`design/quick-specs/luyen-khi-and-tran-phap.md`, `design/quick-specs/phu-luc-linh-thu-thanh-tuu.md`) | n/a (no GDD) |
| Cave Abode & Home Works (#47) | Soft | In: the stones above, booked as `burn_abode` in Formula H | Designed 2026-11-21, pending review | Yes |
| Spirit Herbs & Fields (#14) | Soft | In: seeds bought from the commons pool (a purchase, no burn); out: the harvested herb's `origin_market` tag | Designed 2026-11-21, pending review | Yes |
| Trade Goods (#45) | Hard (amends rules 4, 9, 19; Formulas C, E, G, H, I, L2) | In: named goods and compositions, scarcity factors, crafted classes, the craft plan, `craft_in`, crafted demand. Out: class prices, local prices, stock, flows, baskets | Approved 2026-11-15 (design-review 12); its Open Question 14 amendments applied here 2026-11-15 | Yes (Trade Goods Dependencies lists #43) |

## Tuning Knobs

Every knob lives in `assets/data/economy.json`. Values are the Formulas' guesses; the safe ranges are guesses too until
the harness run (Open Question 8). Per-class values read herb / ore / beast / special. **Hard constraints** a tuner must keep: `α · max ε · demand_elasticity < 1`
(AC-RE-40); `β ≤ 1`; raw `bm` > `sr` and finished `bm · (1 − ch_max) · (1 − 0.2)` > `sr · (1 + ch_max) · 1.1`, so that
buying and selling at one place never pays (AC-RE-22); `P_min < 1 < P_max ≤ P_maxeff`; every `d_scale[k]` inside 0.5–3
(AC-RE-51); `D_min ≥ 1`; `inv_frac · c_inv > 0` so a treasury's excess settles (AC-RE-60).

| Knob | Value | Safe range *(guess)* | What it affects | Formula |
|---|---|---|---|---|
| `d_reach` | 250 tiles | 150–400 | How fast route safety falls with distance on a link between markets (no longer used for access, 2026-11-23) | F |
| `λ_road`, `λ_war` | 0.10; 0.40 | 0–0.3; 0.2–0.7 | Loss to bandits; loss in a region at war | A, F |
| `h0` | 0.6 | 0.4–0.8 | How much a poor (low Holdings) sect's land still supplies its market | B |
| `bmix[k]` | herb 0.40 / ore 0.2 / beast 0.2 / special 0.1 / pill 0.10 | sums to 1 | What a basket and settlement demand are made of | C, L2 |
| `d_scale[k]` | calibrated | 0.5–3 | World demand per class; set by the tool, never by hand | C |
| `set_w` | 50 | 20–100 | Mortal settlements' weight in demand | C |
| `goods_frac` | 0.5 | 0.3–0.7 | Share of sect spending met in kind from its own goods; the rest burns (money sink) | C, H, I |
| `mix[T,k]`, `wmix[k]` | see C | each sums to 1 | Which classes sect tracks and works consume | C |
| `dk[k]` | 0.20 / 0.01 / 0.10 / 0.03 | 0–0.3 | Spoilage of market stock; how long a glut lasts | D |
| `s_cap[k]` | 2 / 6 / 2 / 4 seasons | 1–8 | Most stock a market keeps; how far a glut can pile up | D |
| `c_ref[k]` | 1.5 / 2 / 1.5 / 2 | 1.2–3 | Cover counted as normal; the starting stock | D, E |
| `ε[k]` | 0.7 / 0.4 / 0.6 / 0.8 | 0.3–1.0 | How hard price answers scarcity | E, F, L1 |
| `P_min`, `P_max`, `P_maxeff` | see E | P_min 0.3–0.8; P_max 1.4–2.5; P_maxeff ≤ 4 | Price floor, normal ceiling, Strained ceiling | E |
| `c_short` | 0.5 | 0.3–0.8 | Cover that makes a market Strained; the flow cover floor | E, F |
| `α` | 0.5 | 0.3–0.7 | How fast a price follows its target | E |
| `δ[k]` | 1.25 / 1.10 / 1.20 / 1.30 | 1.05–1.4 | Largest price move a season; how many seasons a shock takes to show | E |
| `τ0`, `τ_tile`, `τ_array` | 0.05; 0.0005; 0.03 | 0.02–0.1; 0.0002–0.001; 0.01–0.06 | Transport cost; how far apart linked prices settle | F |
| `tar[O]` | 0.20 / 0.12 / 0.08 / 0.05 | 0.02–0.3 | Import tariffs by Openness; sect income and carry profit across borders | F, G |
| `β` | 0.5 | 0.3–0.7 | Share of a price gap closed a season | F |
| `cap_base` | 6,000 | 2,000–15,000 | How much a link can carry a season | F |
| `bm`, `sr` (raw) | 1.10 / 0.90 | spread 0.1–0.3 | The bulk spread; same-place trading never pays | G |
| `ch_max` | 0.20 | 0.1–0.25 | How far Mị lực moves finished-goods prices | G |
| `mg_buy`, `mg_sell` | see G | buy 1.0–1.25; sell 0.85–1.0 | Village versus city prices | G |
| `player_cap` | 0.10 | 0.05–0.2 | How far the player can move a market a season | G |
| `f_burn`, `lost_frac` | 0.5; 0.3 | 0.2–0.8; 0.1–0.5 | Array-fee and heirless-death sinks | H |
| `M_0` | ~1,200,000 | 6–15 seasons of faucet | Starting money | H |
| commons pool band | 2–4 seasons of mission cash | 1–6 | When the commons posts more or fewer missions | H |
| `inv_miss` | 0.5 | 0.2–0.8 | Share of Sects F3's `invest` posted as missions rather than sent to a track; how much treasury surplus reaches cultivators (and stones) versus burns in works | H |
| `sub_floor[k]` | herb 0.5, beast 0.5, ore 0, special 0 | 0–0.8 | Subsistence need of staple goods that ignores purses; how strongly a poor famine region still prices a shortage | C, L1 |
| `cm0` | 0.5 | 0.3–0.7 | Share of mine output a sect keeps even at low Holdings | I |
| `kind_stipend` | 15 % | 0–30 % | Stipends paid in goods rather than money | I |
| `spt[rl]` | 1 / 4 / 20 / 150 / 1,000 | steepness kept rising | Stones per tu vi by realm; the main money sink | J |
| `absorb_cap` | 0.5 | 0.2–0.8 | Most stones may add to a season's cultivation rate | J |
| `s_spend`, `reserve[rl]` | 0.3; 2 × mission pay | 0.1–0.5; 1–4 × | How freely NPCs spend their purses | J, L2 |
| `loc_band` | 0.5 | 0.2–0.6 | How far a region's price may sit from its market's; regional carrying profit (rule 16) | L1 |
| `loc_band_fin` | 0.25 | 0.1–0.4 (≤ `loc_band`) | The same band for finished goods' shop prices; keeps their same-market carry near 1.4× | G, L1 |
| `basket[rl]` | 3 / 20 / 50 / 325 / 2,500 | pegged to stipends | Cost of being provisioned | C, L2 |
| `prov_max` | 0.15 | 0.05–0.25 | Cultivation bonus of a full basket | L2 |

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
| Rules 6, 7, 11, 20; Formulas A, B, C, L1 | provinces.md rules 5, 6, 9, 11; Formulas F3, F4, F6 | Provinces as the land unit; access as infrastructure over usage | Read (2026-11-23) |
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
- **FX-RE-B** (one market, herbs): seat province 12,000 herbs (inf 1); province R2 8,000 with infrastructure 7,292 against usage 10,000 (inf 0.7292; was d 150, amended 2026-11-23); holder Trade 6, Military 6,
  Holdings 6 (collect 0.3231), peace; heads 600 / 130 / 30 / 5 / 1, W_set 60, bmix[herb] 0.5, d_scale[herb] 2.2, Institutions spending
  327; injected Imp 1,200, Exp 0; stock 3,000, P 1.00; player net buying 400.
- **FX-RE-2M** (two linked markets, herbs): A P 0.90, D 20,000, stock 5,000, S 20,000 (cover 1.25), trade_mult 1.9; B P 1.30,
  D 15,000, stock 0, S 15,000 (cover 1.0), Openness 2 (tariff 0.12), trade_mult 1.6; 200 tiles hub to hub, safe_AB injected 0.97, peace.
- **FX-RE-SECT**: mines 12,000; Holdings 6 with `collect` injected as **0.323** (Sects F2's rounded example value, so
  AC-RE-30's figures reproduce; the exact 0.3231 gives G_coll 12,278 and Inc_mine 7,939); Σ herb value · acc 38,000; own use 5,000; kind stipends 1,100; P 1.05;
  3 links at 600 tariff each; commons pool 100,000; Institutions spending 10,000 (own use 5,000 herb at goods_frac
  0.5); cash stipends 6,000; treasury at or below its reserve R, so F3 `invest` is 0; Sects F3's market tax, mission
  fees, tribute, head's draw and war cost all 0 *(design-review 7)*.
- **FX-RE-PLAYER** *(design-review 7)*: a scripted Foundation Establishment player, purse 4 × FE mission pay, carry cap
  2,000 base value *(fixture value until the Item Database sets storage caps)*; each trip buys up to the cap of the raw
  good with the largest `p_loc` gap between the two fixed regions and sells it all at the other; a **travel season** is
  each season the player spends on the road, both legs counted; seeds FX-TM-SEEDS[0..9]; route regions fixed per run
  by the largest raw-herb `p_loc` gap at season 41.
- **FX-RE-WORLD**: FX-TM-WORLD plus the defaults, seeds FX-TM-SEEDS[0..9], 400 seasons, burn-in 40 seasons
  *(PROPOSAL)*; no scripted shocks and no player unless stated.

**Markets and money**
- **AC-RE-01** [Config] Rule 1. **GIVEN** the shipped world at season 0, **THEN** there are exactly 7 markets, one per
  great sect; every region is in exactly one market; no minor sect has a market.
- **AC-RE-02** [Integration] Rule 2. **GIVEN** region R2 moves from market X to Y in the Sects tick of season s, **THEN**
  in season s's economy tick R2's production counts for Y, Y receives stock_X · S_R2 / S_X, and Y's price is
  (S_Y · P_Y + S_R2 · P_X) / (S_Y + S_R2).
- **AC-RE-03** [Integration] Rule 2, sect falls. **GIVEN** X falls and regions worth 2/3 of its `value_lt` go to Y and
  1/3 to Z, **THEN** X's market is Closed, its links are deleted, and its stock (each class by that class's `value_lt` of the regions gained) and its commons pool (by total `value_lt`) split 2:1.
- **AC-RE-04** [Logic] Rules 3 and 20. **GIVEN** a city, a town and a village in **one region** at access 1, P 1.0, a raw
  herb of V 120 and no player sales, **THEN** all price from the same `p_loc` (= P), and their buy prices are **132**,
  **139** and **152** (margins 1.0 / 1.05 / 1.15). Places in different regions of one market share P but may differ by `p_loc` (AC-RE-45).
- **AC-RE-05** [Logic] Rule 4 *(amended 2026-11-14; as Trade Goods AC-TG-27)*. **GIVEN** a finished good of V 100 in
  crafted class (pill, 2) at P 1.065, in a city, Mị lực 50, St 0, **THEN** buy = **160**; changing P_herb does not change
  it; a manual uses P = 1.0.
- **AC-RE-06** [Logic] Rule 5. **THEN** the price table has 4 classes and no linh thạch; a mine's access is 1 and its
  `price_index` is 1.0.
- **AC-RE-07** [Harness] Rule 5, Formula H. **GIVEN** FX-RE-WORLD with a scripted player, **THEN** every season
  ΔM = F_mine − (burn_works + burn_stone + burn_fees + burn_formation + burn_abode + burn_heirless) − player_net within 1e-6 (float
  ledgers); missions, cash stipends, tribute, tax, mission fees, the head's draw, war cost, the unburned teleport fees,
  tariffs, `Buy_short` and loot only move balances between holders, each from the payer Formula H names.

**Supply, demand, stock and price**
- **AC-RE-08** [Logic] Formula A, rule 7. **GIVEN** FX-RE-B, **THEN** R2: inf **0.7292**, safe **0.9836**, acc
  **0.7172**; a province
  at inf 1 in peace acc 1, with war_v 1 acc **0.60**; R2 with war_v 1 acc **0.4256**; a province with usage 0 has inf 1.
- **AC-RE-09** [Logic] Formula B, rule 6. **GIVEN** FX-RE-B, **THEN** h_f = **0.8154**; at Holdings 0 (collect 0.0857)
  h_f = **0.6571**; shockS 0.5 halves the production term.
- **AC-RE-10** [Integration] Formulas B → E. **GIVEN** FX-RE-B for one tick, **THEN** S **15,663.2**, D **14,891.0**,
  stock' **3,017.8**, P' **1.0649**, D_f **1.0325**.
- **AC-RE-11** [Logic] Formula C, rule 9. **GIVEN** FX-RE-B, **THEN** D = **14,891.0**; separately, Military spending
  1,000 adds ore +210, beast +140, artifact +100 and talisman +50 (Trade Goods Formula H; amended 2026-11-14); works_due 2,000 adds ore +700 and special +300; herb shockD +0.2 turns the
  population term 14,327.5 into **17,193.0**.
- **AC-RE-12** [Logic] Formula D, rule 8. **GIVEN** stock 3,000, S 15,663.2, D 14,891, **THEN** stock' **3,017.8** and
  short 0; stock 40,000 caps at **29,782**; stock 0 with S 10,000 gives stock' 0 and short **4,891**, which does not add
  to next season's D; ore with stock 10,000 and S = D gives **9,900**.
- **AC-RE-13** [Logic] Formula E, rule 10. **GIVEN** the AC-RE-10 inputs, **THEN** c **1.2533**, P* **1.1341**, P'
  **1.0649**. With cover 0 from P 1.0, herbs run 1.25, 1.5625, 1.9531, **2.4206** (Strained ceiling 3.0), crossing 2.0
  in season 4; ores run 1.10, 1.21, 1.331, 1.4641, **1.6105**, crossing 1.6 in season 5. With very large herb cover the
  price falls 0.80, 0.64, 0.5657 and never below 0.50.
- **AC-RE-14** [Logic] States. **GIVEN** herb cover 0.49, **THEN** the market is Strained with a herb ceiling of 3.0 and
  other ceilings unchanged; cover 0.50 at peace gives Open; war touching the territory gives Strained with every
  ceiling widened; Openness 0 gives Embargoed even when a good is short, and Embargoed with war touching the territory
  still has every ceiling widened; a fallen sect gives Closed with no next state.
- **AC-RE-15** [Logic] Edge cases, zero and limits. **GIVEN** D = 0, **THEN** D_min stands in; **GIVEN** supply and stock
  0, **THEN** the market is Strained, its places restock nothing of that class, and the ledger shows P; **GIVEN** summed
  shockS 0.5 + 0.5, **THEN** 0.8 applies and the dropped 0.2 is logged.

**Feeding the land, and trade**
- **AC-RE-16** [Integration] Rule 11 → Travel & Map. **GIVEN** the AC-RE-10 tick, **THEN** the seat province (access 1)
  reads `price_index` **1.0649** and D_f **1.0325**, and R2 reads its local price (L1, AC-RE-45); P 3.0 gives D_f **1.25**, P 0.5 gives **0.75**; an unticked market gives 1.0.
- **AC-RE-17** [Logic] Rule 12. **THEN** a link exists only with a border or teleport array, no war between the two,
  Openness ≥ 1 and Trade ≥ 1 on both sides; flipping any one condition removes it in the tick of the season it flips
  (as war does, AC-RE-20).
- **AC-RE-18** [Logic] Formula F, rule 13. **GIVEN** FX-RE-2M, **THEN** τ **0.10714**, gap **0.14757**, Q_close
  **1,718.6**, Q **859.3** from A to B, Cap **9,312**, tariff to B **134.1**; B's cover 0.25 is floored at 0.5 and gives
  Q_close **1,007.1**. Separately: P_B 1.10 gives gap −0.0284 and
  no flow; avail_A 300 gives Q = 300; Cap 600 with herb 800 and ore 400 scales to 400 / 200; a teleport-array link gives
  τ **0.08**.
- **AC-RE-19** [Logic] Rule 14. **THEN** a tariff moves money from the importing market's commons pool to its sect's
  treasury and Inc_tariff; margins and standing change shop prices only, never P[m,k].
- **AC-RE-20** [Integration] War. **GIVEN** A and B go to war in season s, **THEN** their link is gone in s's tick and
  Imp = Exp = 0 between them; neither market is Embargoed by it.

**The player**
- **AC-RE-21** [Logic] Formula G, rule 15. **GIVEN** a raw herb of V 120 at P 1.065, **THEN** village buy **162**, city buy
  **141**, unchanged by Mị lực 100 or St 100. **GIVEN** a finished good of V 100 at P 1.0 in a city, Mị lực 100, St 50,
  **THEN** buy **108** and sell **75** (`slip` stubbed to 1); Mị lực 150 clamps charm to 0.20.
- **AC-RE-22** [Logic] Formula G. **GIVEN** the grid Mị lực 0–200, St −100–100, every margin, P 0.5–4.0, V 1–10,000,
  **THEN** for raw and finished goods the buy price is at least the sell price at any one place (cross-place carrying is allowed by design: rule 16, AC-RE-49).
- **AC-RE-23** [Logic] P_eff. **GIVEN** D_pre 14,491 and player buys of 3,000, **THEN** P_eff = **1,449.1**, and further
  buys still go through at the shop price; sells of 3,000 give **−1,449.1**.
- **AC-RE-24** [Logic] Rule 16. **GIVEN** a herb of V 120 tagged with origin A, sold in a city in B with `slip` stubbed to 1, **THEN** at P 1.30
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
- **AC-RE-31** [Logic] Formulas J and L2. **GIVEN** a Core Formation NPC with rate 200, reserve 1,200 and a basket of 50 at
  P 1.0, **THEN** a purse of 3,000 spends 50 on the basket and **525** on stones (0.3 · (1,800 − 50)) for **26.25** tu vi; a purse of 1,210 spends **10** on the basket (fill 0.2) and 0 on stones; a stipend-only NPC at reserve plus one stipend fills the whole basket; a purse of 10,000
  spends 50 on the basket and **2,000** (the cap) on stones for 100; a purse of 1,000 spends 0.
- **AC-RE-32** [Logic] Formula K. **GIVEN** a budget of 300,000 against a stash of 40,000, **THEN** the grant is
  **40,000**, the stash 0 and the narration is told 40,000; a budget of 5,000 against a victim's purse of 12,000 grants
  5,000 and leaves 7,000.

**Other systems**
- **AC-RE-33** [Integration] Sects. **THEN** sect income reads Inc_mine + Inc_goods + Inc_tariff, plus Sects' tribute,
  mission fee and market tax on cash turnover (Sects F3); a static check (a grep of the income code) finds no read of
  `world_production_guess` and no `collect · V_own` term, as in Sects AC-SM-08; V_own is display and a weight only.
- **AC-RE-34** [Integration] Event Engine. **GIVEN** an event budgeted at 600 drawing on a commons pool of 250, **THEN**
  the player gets 250, the pool loses 250, and AC-RE-07 still holds.
- **AC-RE-35** [Integration] Market. **THEN** at each season boundary every place's shelf is rebuilt as a view of its market's
  stock in proportion to its settlement weight; a class with stock 0 restocks nothing; and `stock'` is identical
  before and after the restock step.

**Harness** (FX-RE-WORLD, all 10 seeds, seasons 41–400; a **year** is 4 seasons). Every *PROPOSAL* threshold in
AC-RE-36 to AC-RE-43, AC-RE-57 to AC-RE-61 and FX-RE-WORLD's burn-in is owned by `economy-designer` and set at the first
harness run *(design-review 7)*.
- **AC-RE-36** [Config] Anchor. At season 0 (P = 1) the world's non-mine `value_lt` is 200,000–300,000.
- **AC-RE-37** [Harness] Money. Each year ΔM / M is within −2 % and +5 % *(PROPOSAL)*. AC-RE-59 to AC-RE-61 keep this
  check from passing by dilution while treasuries hoard.
- **AC-RE-38** [Harness] Prices. The world mean price, weighted by D[m,k], is 0.9–1.15 every season; **and** for every
  class, at least one market's P moves by 1 % or more in at least 50 % of seasons *(PROPOSAL)*, so a frozen economy
  fails. *(The P and D_f range checks were dropped in design-review 7: the formulas' clamps enforce them, so they could
  not fail; AC-RE-13 and AC-RE-16 test the clamps.)*
- **AC-RE-39** [Harness] Pools. Every commons pool holds at least 2 seasons of its mission cash; **and** every pool posts
  at least 1 mission per 50 heads in its market each season *(PROPOSAL)*, so a pool cannot hold its band by posting
  nothing; no sect stays below its reserve for more than 4 seasons in a row outside war.
- **AC-RE-40** [Config + Harness] Stability. α · max ε · demand_elasticity = **0.20** (< 1). A single herb shockS 0.5 in
  one market at season 100 (the reference level is the mean P over seasons 92–99) returns P within 5 % of that level
  within 12 seasons, and over seasons 101–112 P never falls more than 2 % below it *(thresholds PROPOSAL)*. The peak P
  in seasons 100–104 is at least 1.10 × the reference (the shock showed). The same test runs with a **special-class**
  shockS 0.5 (the class that barely spoils): P returns within 5 % of its reference within 20 seasons and does not
  swing between P_min and P_maxeff *(PROPOSAL; design-review 6)*.
- **AC-RE-41** [Harness] Flow. On no link and class does flow change direction more than once in any 8 seasons without a
  shock at either end; **and** for each class, at least one link carries flow in at least 80 % of seasons *(PROPOSAL)*.
- **AC-RE-42** [Harness] Ceiling. No market and class sits at or above P_max (the Open ceiling, not P_maxeff) for more
  than 40 seasons in a row.
- **AC-RE-43** [Harness] Determinism. The same seed run twice gives byte-identical ledgers.

**Local prices, baskets, carrying and calibration** (numbered after the sections above; numbers kept because other
sections cite them)
- **AC-RE-45** [Logic] Formula L1, rule 20. **GIVEN** herb P 1.065, access 0.5, value_lt 8,000, D_r 2,000 and ρ 1, **THEN**
  p_loc = **0.656**; with ρ 2 the same region gives bal 2.0 and p_loc **0.836**; D_r is built from the region's own heads, settlements and works with `d_scale`, `bmix` and previous-season `fill` (a fixture region of 100 QR heads, W_set 10, works_due 0, herb: 0.5 · 2.2 · (300 + 500) = **880**); **GIVEN** ore P 1.0, access 0.5, value_lt 500 and D_r 3,000, **THEN** p_loc = **1.43**; at access 1
  p_loc = P; a raw value outside the band clamps to P · (1 ± 0.5); a finished good's shop price clamps p_loc to P · (1 ± `loc_band_fin` 0.25), so a region at 1.43 P prices a finished good from 1.25 P. A shop in the region prices from p_loc.
- **AC-RE-46** [Logic] Formula L2, rule 21. **GIVEN** a Nascent Soul with all local prices 1.0, **THEN** basket_cost =
  **325**; spending 325 gives prov **0.15**, 162.5 gives **0.075**, 0 gives 0 and no penalty; the goods are consumed and
  the money goes to the commons pool.
- **AC-RE-47** [Logic] Rule 22. **GIVEN** an NPC whose purse is at or below reserve, **THEN** they buy no basket and no
  stones, and their realm's fill in Formula C falls accordingly. **GIVEN** a loose cultivator with no stipend at season 0,
  **THEN** their purse equals reserve and their fill is 0; after a mission pays 20 above reserve in a realm whose basket
  is 20, the basket step of that season's tick (E) buys it in full and fill is 1.0; Formula C reads it the following
  season's tick; their money comes only from missions and loot (no stipend is created).
- **AC-RE-48** [Config] Rule 21. **THEN** each realm's basket at P = 1 equals that realm's season stipend (3 / 20 / 50 /
  325 / 2,500).
- **AC-RE-49** [Harness] Rule 16, Formulas G and L1 (user decisions 2026-11-14, design-reviews 4, 6 and 7). **GIVEN**
  FX-RE-PLAYER (run once with raw goods and once with finished goods) carrying between two regions of one market for
  **40 seasons**, **THEN** (a) the trip is allowed and untariffed; (b) **with all profit reinvested**, the player's mean
  profit per travel season over the 40 seasons stays within **0.5–1.5×** FE mission pay *(PROPOSAL; economy-designer
  owns the band)*; (c) **in a separate run at fixed capital** (profit withdrawn each season, cargo at the cap), the mean
  margin per unit of base value, (sell − buy) / buy, in seasons 31–40 is below that in seasons 1–10 (the route wears
  out; reinvestment growth cannot mask it). Same-place trading is AC-RE-22's. The run is repeated for a scripted player
  carrying between two **markets**, once on a linked pair and once on an unlinked pair at the largest price gap the
  world reaches, paying the importing sect's tariff; the same band applies *(design-review 4, user decision
  2026-11-14)*.
- **AC-RE-50** [Logic] Formula F, resolution order. **GIVEN** market A exports herb to both B and C with `avail_A` 1,000
  and Q 800 wanted on each link, **THEN** the link with the lower id pair gets 800, the next gets 200, and the result is
  identical across 10 runs and any storage order of the links.
- **AC-RE-51** [Config] Formula C, calibration. **GIVEN** the shipped world at season 0, **THEN** the calibration tool
  finds every `d_scale[k]` within 0.5–3, and every market whose season-0 supply is at most `c_ref[k] · D` starts with
  stock `c_ref[k] · D − S` and cover equal to `c_ref[k]` (P = 1) within 1 % (Formula D, starting stock). Example: D
  10,000, S 9,000, herb c_ref 1.5 gives stock **6,000** and cover 1.5. A market with S above `c_ref · D` starts with
  stock 0 and is listed as a glut market. A `d_scale` outside the range fails the check and names the class and market.

**Design-review 6 additions**
- **AC-RE-52** [Logic] Formulas H and I, in kind. **GIVEN** FX-RE-SECT (Institutions spending 10,000, cash stipends
  6,000, kind stipends 1,100; treasury at or below R so `invest` is 0; F3's other lines 0), **THEN** the sect's treasury changes by
  7,938 + 5,834.4 + 1,800 − 6,000 − 5,000 = **+4,572.4**; the commons pool receives **0** for the 5,000 own use and the
  1,100 kind stipends; the sink ledger shows burn_works **5,000** (not 10,000); and the commons pool changes by
  +4,062 (uncollected mine cash, (1 − 0.6615) · 12,000) − 5,834.4 − 1,800 = **−3,572.4**.
- **AC-RE-53** [Logic] Formula I, shortfall. **GIVEN** a sect with Military spending 10,000 (own use beast 0.5 · 10,000 ·
  0.4 = 2,000), G_coll[beast] 500 and P_beast 1.2, **THEN** G_sold[beast] = 0, short_own[beast] = **1,500**, the sect
  pays **1,800** in cash to the commons pool, and market beast stock falls by the 2,000 own use once (through D).
- **AC-RE-54** [Logic] Formula H, treasury rule (design-review 7). **GIVEN** a sect with R 40,000, a treasury of
  60,000, Inc = Cost (N 0), `inv_frac` 0.5, `inv_miss` 0.5 and `goods_frac` 0.5, **THEN** `invest` is **10,000**:
  **5,000** reserved at posting for missions from the treasury with no mission fee (paid on completion; an untaken
  mission's 5,000 returns to the treasury at its deadline), 5,000 to the track as `spend_T`, of which
  `burn_works` gains **2,500** and own use gains 2,500 of goods; the treasury ends at **52,500**; nothing else spends
  the excess. **GIVEN** a treasury of 40,000 or less, **THEN** `invest` is 0.
- **AC-RE-55** [Logic] Formula L1, player feedback. **GIVEN** AC-RE-45's herb region (P 1.065, access 0.5, value_lt
  8,000, D_r 2,000, ρ 1) and player purchases there of 2,000 this season, **THEN** next season's p_loc is **0.836**
  (was 0.656); **GIVEN** the ore-short region (P 1.0, access 0.5, value_lt 500, D_r 3,000) and player sales of 2,000,
  **THEN** p_loc is **1.037** (was 1.43); ρ is unchanged by the player's trades; at access 1 p_loc stays equal to P.
  **GIVEN** no player trades the following season, **THEN** half carries (`pl_mem` 0.5): the herb region's p_loc is
  **0.756** and the ore region's **1.149**.
- **AC-RE-56** [Logic] Formula G, slippage. **GIVEN** a city in a region with herb Dp 2,000, p_loc 1.0, and untagged V 120
  herbs, **THEN** the first sale is **103**, a sale after 1,000 already sold that season is **79**, and after 2,000 it
  is **65**; buys are unchanged by slippage; q_sold is 0 again after the season tick; a manual (no main input) has slip 1.

**Design-review 7 additions**
- **AC-RE-57** [Logic] Formula C, steady-state calibration. **GIVEN** one market with no links or shocks, herb
  (dk 0.20, c_ref 1.5), D 10,000 and S 11,000 (S/D = 1 + 0.20 · 0.5 = 1.10), starting stock 4,000 and P 1.0, **THEN**
  stock stays **4,000**, cover **1.5** and P **1.000** in each of 40 seasons (within 1e-6). **GIVEN** the shipped world,
  **THEN** the calibration tool's world S/D per class is herb **1.10**, beast **1.05**, special **1.03**, ore **1.01**
  (within 0.1 %).
- **AC-RE-58** [Logic] Formula C, subsistence floor. **GIVEN** FX-RE-B's heads but every realm's `fill` 0, **THEN** the
  herb population term is d_scale · bmix · (Σ n · basket · 0.5 + set_w · W_set) = 2.2 · 0.5 · (5,012.5 + 3,000) =
  **8,813.8**, and the ore term counts settlements only (`sub_floor` 0); with `fill` 0.8 the herb term uses 0.8; the
  part above the actual fill moves no money (the commons pool and NPC purses are unchanged by it).
- **AC-RE-59** [Harness] Money, treasury share. The treasuries' share of M stays within 10–40 % every season
  *(PROPOSAL)*.
- **AC-RE-60** [Harness] Money, no hoarding. Over every 20-season window, each sect's mean excess over its reserve R is
  at most **1.5 × E*** of the treasury rule (Formula H, `E* = N̄ · (1 − c_inv · inv_frac) / (c_inv · inv_frac)`, N̄ its
  mean net income over the window), or at most 0.05 · R when N̄ ≤ 0 *(PROPOSAL)*.
- **AC-RE-61** [Harness] Money, sinks live. `burn_stone + burn_works` is above 0 in every season.
- **AC-RE-62** [Logic] Zero demand. **GIVEN** a market with no heads, settlements or sect spending (calibrated D 0), stock
  0, S 0, **THEN** D_min = 1, cover 0 (Strained) and P climbs at δ with no NaN or infinity; **GIVEN** the same market at
  the low end of a link, **THEN** `Q_close` is finite; **GIVEN** stock 50 and S 0, **THEN** stock' = min(0.8 · 50,
  2 · 1) = **2**.
- **AC-RE-63** [Logic] Payers. **GIVEN** a season with market tax 1,000, tribute 500, a commons mission of 2,000 on the
  sect's board, a treasury mission of 1,000 on its own board, a head's draw 325 to an NPC head, war cost 800 and teleport fees 400 paid by NPC
  cultivators, at `f_burn` 0.5 and Sects' mission fee 0.20 (fee 400 on the 2,000 commons mission), **THEN** the commons pool pays 1,000 + 2,400 (the 2,000 reward plus the 400 fee) and receives 800; the vassal treasury pays 500 to the
  overlord's; the treasury mission pays no fee; the head's purse gains 325; the array holder's treasury gains 200 and
  `burn_fees` is 200; with no other flows, ΔM over the season is −200 (the fee burn only).
- **AC-RE-64** [Logic] Player head. **GIVEN** the player heads a sect whose treasury posts a mission, **THEN** the player
  cannot accept it, and an attempted draw above the F13 ceiling is cut to the ceiling.

**Design-review 11 additions**
- **AC-RE-65** [Integration] Rule 19, season lag. **GIVEN** a sect whose `Inc` rises by 1,000 in season s's step (f),
  **THEN** its Sects F3 `invest` changes in season s+1's Sects tick, its `burn_works` and `own_use` change in season s+1,
  and Formula C's `spend_T` term in D changes first in season s+2's step (c); no step reads a value written later in the
  same tick.
- **AC-RE-66** [UI] Visual/Audio. **GIVEN** a market where one good's price rose a little, one fell a lot and one sits
  at its ceiling, and markets in each of the four states, **THEN** each price shows an up or down mark banded small / large
  / at ceiling or floor, each market state shows its own icon on the ledger and over the seat on the map, and colour is
  never the only cue. Evidence: `production/qa/evidence/re-price-marks-[date].png`. *(Provisional.)*
- **AC-RE-67** [Logic] Rule 22, famine (Player Fantasy). **GIVEN** herb P 1.0, a region at access 0.5 making 500 of herbs
  with 100 Qi Refining heads at fill 0, W_set 10, d_scale 2.2, bmix[herb] 0.5 and ρ 1, **THEN** D_r = **715** (the
  subsistence floor counts half a basket) and p_loc = **1.133**, above the market price; with `sub_floor` 0 it would be
  550 and 1.034. A poor region short of a staple is where a trader is paid most.
- **AC-RE-68** [Harness] Per-market drift. With no scripted shocks, every market's mean P per class over any 40-season
  window stays within **0.85–1.20** *(PROPOSAL)*, so a world mean inside AC-RE-38's band cannot hide one market drifting.

**Performance** *(PROPOSAL; owner technical-director)*
- **AC-RE-44** [Harness] The market part of the tick (7 markets × 4 classes, ~20 regions, up to 21 links) runs in a
  median of 2 ms or less, p99 5 ms; stone cultivation over 5,000 NPCs 5 ms or less; the whole economy tick 8 ms or less on
  the reference machine over 400 seasons; memory does not grow past the bounded ledger history.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~Do crafted goods get their own supply and demand?~~ **Closed 2026-11-14 by Trade Goods (#45):** crafted classes by kind × tier, a craft plan and `craft_in` (rule 4) | economy-designer, user | Before the crafting and alchemy pass |
| 2 | Stone cultivation's tu vi side: Realms Formulas I gains a stone term (`absorb_cap`, `spt`), and the Realms bot re-runs the NPC targets (1 in 8 / 12 / 15 / 20; about 27 Nascent Soul, about 3 Hóa Thần) with it | Realms, Balance Harness | Realms revision |
| 3 | Stone grades: do low, middle, high and top-grade stones (hạ / trung / thượng / cực phẩm linh thạch) exist as items, so a Nascent Soul's 57,000 stones a season are fewer, rarer stones? Pure presentation or a separate good? | user, Item Database | Before the Item Database revision |
| 4 | ~~Sects F3 revision~~ **Done 2026-11-14.** Still open: re-derive the Sects budget table and `s_max`, rerun AC-SM-42 | economy-designer | Harness run |
| 5 | Event Engine: every linh thạch grant draws from a holder (Formula K), and the budgets are restated | Event Engine | Event Engine GDD |
| 6 | NPC purses: one per NPC or one per realm band per market? A technical decision → becomes an ADR | technical-director | `/create-architecture` |
| 7 | What the player knows of other markets' prices: last seen, rumours from travellers, or a sect's trade report by standing? | user, ux-designer | Before the market UI |
| 8 | All Formulas values are guesses: the harness run (AC-RE-36 to AC-RE-43) may move `d_scale`, `spt`, `cm0`, `goods_frac` and the price bands | economy-designer, Balance Harness | Before approval of the numbers |
| 9 | Performance budget (AC-RE-44) | technical-director | `/create-architecture` |
| 10 | Should a strong market pull a weak neighbour's border regions into it (EU5's markets that cross borders)? Revisit if wars feel economically flat | user | After the harness run |
| 11 | Merchant charters (rule 23): price, upkeep, margin share, seizure odds | economy-designer | Post-MVP |
| 12 | Do `prov_max` 0.15 and stone cultivation together keep the player edge at 0.70 and the NPC realm targets? | Realms, Balance Harness | Realms revision |
| 13 | A continent-wide trade hub (Victoria 3's World Market) as a shared price anchor above the 7 markets | user | After the harness run |
| 14 | Loose cultivators (~1,700) start at reserve with no stipend (decided 2026-11-14): does their near-zero basket fill drag population demand and prices below the calibrated level? Calibration (Formula C) assumes fill 1 at season 0. Design-review 7's `sub_floor` keeps herb and beast demand at half a basket or more, which narrows the gap. The harness reports the loose cultivators' mean basket fill by realm (moved from AC-RE-39, a report and not a pass condition) | economy-designer, Balance Harness | Harness run |
| 15 | ~~Sect cash balance after own use moved in kind~~ **Answered 2026-11-14:** Sects F3's `invest` is the only spender of a treasury's surplus (design-review 7). **Closed 2026-11-14 (user):** Sects F3's `Cost` counts the cash share only (no double count); treasury missions are reserved at posting, paid on completion and returned if untaken (Formula H). Still open: `inv_miss` value and the AC-SM-42 re-run | economy-designer, Balance Harness | Harness run |
| 16 | ~~Carry capacity and cargo loss~~ **Answered 2026-11-14 (design-review 7, user):** a carry cap set by storage items, and cargo lost or looted on death or defeat (rule 16, Formula K). Still open: the capacity of each storage item (Item Database) and whether road encounters can take part of a cargo short of defeat | Item Database, Travel & Map | Item Database revision |
| 17 | ~~Crafted goods' `origin_market` and crafting arbitrage~~ **Closed 2026-11-14 by Trade Goods (#45):** the main input's origin (Trade Goods Formula I); crafted sales move their own class, and the craft margin lint (Trade Goods Formula J) bounds recipes | economy-designer, Item Database | Before the crafting and alchemy pass |
