# Plan: the world economy (Regional Economy & Trade #43, Trade Goods #45, the Sects economy)

Status: DECIDED 2026-11-20. The user's answers to section 2:
1. **Sects scope:** the economy **and** sect politics (wars, levies, vassal loyalty, attitudes, stances: F5-F9, F18),
   so territory changes hands in play.
2. **NPC money:** purses, baskets and stones **also speed NPCs** (their stage chance), and the census is re-tuned.
3. **Mines:** each mine's resource **by its name** (an authored table); the grade values tuned to the ~124,000 faucet.
4. **Beast parts and special goods:** beast lairs and special sites **authored on the map** (a continent 11 design
   pass, proposed for the user's approval as the map's other layers were) before the economy prices them. Design: `design/gdd/regional-economy-trade.md`,
`design/gdd/trade-goods.md`, `design/gdd/sects.md` (all approved), `design/gdd/living-world-tick.md` (tick order,
designed). Builds on the continent (`production/plans/continent-world.md`): the map's production contract is the input.

## 1. Measured on the built continent (tests/performance/world/economy_probe.gd)

| Figure | Built | The GDDs assume |
|---|---|---|
| Mine faucet a season | 327,125 linh thạch (22 of 23 sites yield linh thạch) | ~124,000 |
| Non-mine output at P = 1 | 6,675 (one ore site; no herb, beast or special sites) | world_production_guess 250,000 |
| Money at year 0 | 521,000 (treasuries only; NPC purses 0) | M_0 ~1,200,000 |
| World tick | 237 ms a season (5,000 NPCs) | per-NPC purses allowed if affordable |
| Money writes in code | 22 in 12 files | all through named holders (Formula H) |

So before the economy can price anything, the land must produce what it prices: the mines' resources, herb supply
(the wild herb grounds exist as place attributes but produce nothing), beast parts and special goods.

## 2. Decisions for the user (asked 2026-11-20)

1. Scope line in Sects.
2. The NPC side of money (does it change NPC cultivation and so the census?).
3. The mines' resources.
4. Beast parts and special goods (no sites exist).

## 4. Order (one commit a step, the suite green at each; the user's approval where authored content is proposed)

- **M1** the mines' resources by name (authored table in the map layer, export, MapProduction reads it); faucet tuned.
- **M2** beast lairs and special sites: a proposal on continent 11 (names, places, yields) for the user's approval,
  then exported as sites. Herb grounds become herb sites (production and reserves).
- **L** the money ledger and the conservation property test; NPC purses seeded to M_0; old saves seeded at load.
- **R1** markets: classes, supply, demand, stock, price, local price, price_index; the market places restock from it.
- **R2** the player's trade: bulk spread, slippage, carrying, cargo by storage items, tariffs at the border.
- **R3** links and flows between markets.
- **H** money holders: commons pools, mission pay from holders, stipends from treasuries, loot from holders (K), heirless
  burn, teleport and works burns; the old faucets switched off.
- **J** stone cultivation (player and NPCs) and provision baskets (L2), speeding NPCs' stage chance (decision 2).
- **T** Trade Goods: named goods, compositions, specialties, scarcity, crafted classes, craft plan, origins, lint.
- **S1** Sects economy: F1-F4, F12-F14, F17, F19, the dials (F6) and the treasury rule.
- **S2** Sects politics: attitudes (F7), loyalty (F5), war strength, score, spoils and goals (F8, F9, F18); holder
  changes through MapChange.transfer; markets follow (rule 2).
- **W** the tick order (Living World Tick S1-S10) settled across all of it.
- **B** balance: the economy harness, then the census (NPC speed) and autoplay on 10-12 processes.

## 3. Shape

- **Ledger first:** every linh thạch movement through `transfer(from, to, n)` / `burn(from, n)` on named holders
  (sect treasuries, NPC purses, a commons pool per market, the player, the lost-stash pool, the sink ledger); a
  conservation property test (ΔM = mines − sinks each season) written first and watched failing; the old faucets
  (mission cash from nowhere, event grants, explore loot, cache pay) switched to holders last.
- **The land's supply:** mines' resources; herb grounds as herb sites (production and reserves, Formula H/I of Travel
  & Map); beast and special supply per the answer; the contract by region, kind and good (Trade Goods Formula A).
- **Markets:** one per great sect; Formulas A-G, L1 (access, supply, demand, stock, price, local price, price_index
  back to the land); restock of market places from market stock; the player's bulk spread for raw goods, slippage,
  cargo by storage items.
- **Trade between markets:** links and flows (Formula F), tariffs.
- **Money:** Formulas H-K (holders, sect income, stone cultivation for the player and per the answer for NPCs, loot
  from holders), the commons pool rule, the treasury rule; missions paid by holders.
- **Trade Goods:** named goods and compositions (Formula B), regional specialties (C), scarcity (D), crafted classes
  (E), the craft plan (F-H), origins (I), the craft margin lint (J).
- **Sects economy** (per the scope answer): F1-F3 tracks, income, costs, treasury; F12 board; F13 head's draw;
  F17 intake; F19 investment.
- **Tick order** per Living World Tick S1-S10 and #43 rule 19; all economy state in the World DB (a reload re-plans the
  same, the AC-PR-48 lesson); old saves get ledgers seeded at load.
- **Tests from fixtures** and the GDDs' worked examples (H: 60,000 -> 52,500; I: 7,938 and 5,834; J: 26.25; K: 40,000).
- **Balance:** an economy-only harness (tick N years: M, ΔM a year, mean price, pool levels against AC-RE-37's bands)
  first; autoplay only at checkpoints, on 10-12 processes, with the player rolled independently of world building so
  runs compare (baseline 65 / 49 / 15 / 0 of 7).
