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

## 5. Progress

- **M1 done** (a63dfc5e): mines by name; faucet 124,560 a season (linh thạch kind factor 0.72).
- **M2 done** (user-approved 2026-11-20): `design/map/continent-11/sites.json` (14 beast lairs, 5 hot springs, 4 lava
  vents, 1 lightning wood) exported as places 231-254 (ids of earlier places unchanged), sites of their good; new
  goods Yêu Cốt, Yêu Thú Bì, Linh Tuyền Thủy, Địa Hỏa Tinh; place types yêu sào, ôn tuyền, địa hỏa khẩu. Ice variant
  now at 2.3 % of places (Hàn Giao Chử, a cold islet, holds Ice; the land's truth, over the 2 % target).
- **Herb sites:** every place with herb grounds (95) is a herb site; value split among its herbs by Trade Goods
  Formula A. The contract now has `production_value` {good: base value} per region. Non-mine value 250,235 a season
  (herb 120k, ore 84k, beast 28k, special 18k) after tuning kind_value_mult herb 0.17, beast 1.6 and beast settle_w 1.0.
- **L done:** `MoneyLedger` (holders sect:/npc:/pool:/stash:/player; mint, transfer, burn; season books; property test
  watched failing on a broken burn). NPC purses seeded at reserve x U(0.5, 1.5); commons pools 20,000 each.
  M_0 about 1.53M (GDD guess 1.2M). Old saves: the map version changed with M2, so they are refused anyway.
- **R1 done:** `EconomyRules` (Formulas A-L2 as pure functions; the GDD's worked examples are its tests) and
  `WorldEconomy` (markets table, calibration of d_scale and starting stock, the season tick, local prices and
  price_index back to Formula H's D_f). d_scale herb 2.58, ore 3.87 (above the 0.5-3 range: ore supply is high
  against baskets; AC-RE-51 flags it), beast 1.22, special 1.55. Without links markets drift apart (ore 0.70 in
  Thúy Vi and Thiên Xu, 2.20 in Lạc Hà and Phượng Minh by season 20): R3's job.
- **R2 (part) done:** shop prices on the continent follow Formula G at the region's local price (raw goods at the
  bulk spread 1.10 / 0.90, finished goods at the retail spread); money through the commons pool; slippage; the
  player's trades enter P_eff and L1. Not yet: tariffs on goods from other markets (origin tags, with R3/S1),
  standing (S1), cargo by storage items, restock from market stock (rule 19 g, with T).
- **R3 done:** 21 candidate links (bordering territories by road, the rest through the teleport arrays); Formula F
  flows in (id_A, id_B) order, depleting the exporter, scaled to capacity, paid pool to pool with the importer's
  tariff to its sect; links read Trade >= 1, Openness (default 2) and wars each season.
- **H (world side) done:** `WorldMoney.season` after the markets: mines mint (collect_mine to the holder, the rest to
  the market's commons pool; wild sites half to the stash), cash stipends, commons missions (pool / 3 a season, one
  mission per cultivator at realm pay), baskets (L2) to the pool, market tax and goods sold (Inc_goods) to the
  treasury, the treasury rule (missions to members, the track's cash share burned, its kind share kept from the next
  goods sales). Deaths settle the purse (heir, sect, or lost_frac burned and the rest to the stash).
  `tests/integration/economy/money_conservation_test.gd` checks ΔM = minted − burned every season on the real
  ticker (watched failing by 301,701 without the death settlement).
- **J done:** NPC stones (Formula J at a reference rate by realm, npc_rate_ref from Formula J's output range) and
  the provision bonus speed NPCs' stage chance by (1 + prov) x (1 + stone_boost) (decision 2). With stones, M settles:
  1.56M -> 1.93M over 80 seasons (about +1.3 % a year; AC-RE-37 wants -2 % to +5 %). Stones burn about 83k a season,
  works about 36k.
- **Player stream:** the player and the play after world building draw from rng keyed "player:<seed>", so paired
  balance runs compare across world changes.
- **Tick cost:** the money step about 85 ms a season (batched ledger flows, slot cache); world tick about 330 ms.

- **Found money (user decision 2026-11-20, "a share of every mine"):** 5 % of every mine's output goes to its
  market's lost stash (losses, theft, buried caches); explore finds, buried caches and discovery loot draw from it
  (Formula K). The design's wild-site share alone left the stash empty: every mine on continent 11 has a holder.
- **H (player side) done:** the player's stipend is paid by the sect's treasury, a sect mission by the treasury and a
  bounty by the town's commons, explore finds and caches by the lost stash, event money by the commons; array fees
  half burned and half to the array's holder, rent and residences to the place's holder, seeds bought from the
  commons, a cave abode's opening burned (`MoneyLedger.player_take` / `player_pay`). Player-only sinks (crafting
  fuel, ink, formations, beast feed, works) still write the purse directly: the player is outside M.
- **S1 done:** `SectEconomy`: F1 investment, levels and upkeep (goods share in kind, cash share burned; two unpaid
  seasons drop a level), F2 capacity, F4 tribute, F17 intake (function; intake still by the world target), F19's
  track takes the treasury rule's investment. The market tax is split among a market's sects by V_own (F3 share_s).
- **S2 done:** `SectPolitics`: F6 dials from needs (trait pulls wait for #42), F7 attitudes with authored grudges and
  the balance-of-power damper, pacts and feuds, F18 war declaration and goal, F9 war score with keyed fortune, losses
  (members die, purses settled), weariness, war cost, Military drops, spoils (a captured site at x0.5 for 8
  seasons), fall of a great sect with no region; F5 loyalty and F5b's new lord. Markets follow the holders each
  season (rule 2). Not yet: rebellion (F5b check 2), levy refusal, pacts' defence calls in a war, the rebel becoming a
  great sect, members' rank and desertion. Probe (120 seasons, seed 11): three wars, two won (border sites), one
  feud, then peace; tier-1 levels 13-14 (F1's 11-14); M about +1.5 % a year.

### Open for the user (to ask)

- **Numbers set without sign-off** (for the economy review): kind_value_mult herb 0.17, beast 1.6, linh thạch 0.72;
  beast settle_w 1.0; the mine resource table (design/map/continent-11/mine_resources.json, DRAFT but live); Ice
  variant at 2.3 % of places; M_0 about 1.53M (pools 20,000 each); npc_rate_ref.
- **Calibration:** d_scale ore 3.87 (outside 0.5-3) is left until S1 adds the sects' ore spending (then recalibrate).
