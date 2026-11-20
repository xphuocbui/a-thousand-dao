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

### Progress, 2026-11-20 evening (continued)

- **7ed0584f** markets price raw goods by rarity band (8 classes), compositions (Formula B), shelved cover, scarcity
  factor in shop prices. Herb band 3 sits near its ceiling (rare goods intermittent): balance item.
- **71be6138 / 9adcdadb** settlements produce by population and land (Travel & Map rule 21, Formula H2; user-approved):
  P = size weight x livability; settlements 34 % of herb value, 25 % of ore; non-mine total 251,772.
- **549448b4 / 20023bd8** herbs count as mature equivalents (Item Database Formula B, user-approved: E = x to maturity,
  plateau s 0.1 to the knee 3, then doubling every 0.45 mature-ages); recipes count equivalents; pill quality from ρ.
  Shops are a view of their market's pool (user decision: option A, mature herbs only).
- **Baseline autoplay** (before the bands, settlements, shelves and equivalents): 72 / 56 / 16 / 0 of 9.
- **Known test isolation bug:** `tests/unit/crafting/talismans_test.gd`'s combat test fails when run alone (also at the
  committed code before these changes); it passes inside the full suite. To fix.
- **Next:** crafted goods as value classes (Trade Goods rules 11-16, Formulas E-J); lair hide and cores; Thiết Tuyến
  Thảo and Thiết Cốt Đan; cargo (rule 16a); origin tariffs; specialty knowledge (rule 17); the leftover politics
  (rebellion, levy refusal, pacts called into wars); then the balance pass.

### Progress, 2026-11-20/21 night (user asleep: "continue the sects and works, then the simulation and bug fixing")

- **a3ab2fa8, b34450c6** crafted classes for pills, talismans and artifacts (Trade Goods Formulas E-H): workshops
  plan by price over input cost and cover, each recipe (or input group, "any material of rarity r or more") drawing
  from the shelves; demand from the baskets' pill share and Military's crafted spending. The sects' goods spending
  (upkeep plus investment, half in goods) is now raw demand (Formula C's goods_frac term); d_scale ore 3.87 -> 3.32.
- **e9b59b18** lairs yield bone, hide and demon cores; items carry their origin market and pay the import tariff
  where sold.
- **c41232ab** sects build works on their land (worked mines, vein dressing, great array, spirit grove, up to
  ceil(Holdings / 2)) from the Holdings investment; works upkeep in cash and goods; unpaid works fade. Mine output
  124,560 -> 161,132 a season over 120 seasons.
- **abb992e0** F17 intake by capacity, F3 desertions, F5b rebellions, levy refusal, rule 30 new sects.
- **Fixes found by the bug check:** the Advisor's market hint before planting (4fd1780d), and its price estimate of a
  30-year herb (c41232ab): both made the balance bot save for herbs it could not afford and take missions all life.
- **Tools:** tools/run-tests-parallel.sh (616 cases in about 7-10 min), tools/balance/world_sim.gd (the chronicle).
- **Not yet:** breakthrough pill demand (D_bt, a Realms handoff), crafted flows between markets, crafted origin tags,
  cargo by storage items (no storage items exist yet), specialty knowledge (rule 17), Thiết Tuyến Thảo and Thiết Cốt
  Đan (its effect is a content-pass item), NPC traits' pulls (#42), relationships (#46, another session).

### Progress, 2026-11-21 (night, continued)

- **b8cc1383** tools/balance/world_sim.gd (a chronicle per decade) and assets/data/traits.json, exported from the
  NPC Traits catalogue by tools/design/traits/export_traits.py (37 personality, 14 callings, 10 fate-given, 16
  gained; the Sects F15 pulls parsed; pulls the engine doesn't read yet are kept as notes).
- **49552e63** NPCs roll traits (F4, keyed on the person id); the cast keeps its authored ones. Leaders' F15 pulls
  reach the politics (dial pulls, bold, Stubborn, Fickle, war and rebel odds, weariness limits, loyalty, pact line,
  alignment factor, attitude speed and bias), the head's draw (F13) and the invest share.
- **530e7d1e** gained traits (grant, refresh, replace, fade at 40 seasons; a won war makes the head Battle-hardened,
  a lost one Shaken); directed regard (Cruel -10 to rivals, Devout -10 to the opposite alignment, righteous sects -10
  to a Demon-seeded head); F6's boldness constants in data.
- **Suite:** 627 cases green (JOBS=4).

**What the simulations show (observation; probes in tests/performance/world/):**

1. **Great-sect wars stop after the first burst** (sim-11.md, sim-11-traits.md; war_probe.gd). Not a bug: with F7's
   terms only chính against ma can reach the feud line (-30 alignment, -5 a shared border); same or neutral alignment
   pairs sit between -25 and +25. F7's "+ events" term has no feeder yet (the Event Engine). Thính Vũ Lâu is the only
   ma great sect, so one pair can fight. **Decision for the user:** a source of hostility between great sects that
   aren't chính against ma (border friction over sites, events, rivalry of the strongest two, or a lower feud line).
2. **Crafted prices above the band (1.8-2.1) for two reasons** (price_drift_probe.gd, craft_plan_probe.gd):
   - **Military's crafted demand is lumpy by design:** Sects F19 invests in exactly one track a season, and Trade
     Goods D_mil reads last season's Military spending. A talisman class sees demand of about 100, then about 470,
     then 100, then 390. Stock runs out in the high seasons, and Formula F's plan falls back in the low ones, so supply
     settles near 130 against a mean demand of about 230. **Decision for the user:** D_mil reads the mean of the last 4
     seasons' Military spending (recommended), or F19 spreads investment over tracks by deficit.
   - **pill5 (and part of pill4, artifact5-6) can't be made:** no rarity-4 herb or material exists on the map, so the
     workshops' fill is 0 while Hóa Thần baskets keep demanding. The known rare-goods scarcity: content, in the balance
     pass.
3. **The census sits above Realms' solved counts, and money is not the cause** (census_probe.gd): with the money
   speed-up switched off the census drifts the same way (40 years: Trúc Cơ 1,244, Nguyên Anh 47 against 844 and 27).
   census_cause_probe.gd: world generation starts everyone at about half their lifespan, so in the first 20 years
   only 64 die of age against 591 breakthroughs, and 96 % of Luyện Khí reach the last stage. A transient: Kết Đan and
   above live 500-2,000 years. The 2026-11-05 run (2,000 years, random world) held Nguyên Anh at 29. A 400-year run on
   the continent settles it (sim-11-400y.md). If the long run is still high, the census retune (approved with the
   money decision) moves the NPC gate odds; if only the start is off, world generation's ages are the fix (a
   proposal, as World Generation owns them).
