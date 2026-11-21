# The world economy in the game (evidence)

Plan: `production/plans/world-economy.md` (user decisions 2026-11-20: the economy and sect politics; money speeds NPCs;
mines by name; beast lairs and special sites authored on the map).

| File | What it shows |
|---|---|
| `01-shop-commands.txt`, `01-shop-transcript.txt` | Regional Economy & Trade at the shop (R2) with Trade Goods' bands and scarcity (T): at Thiều Âm Thị (a market in Thê Ngô Lĩnh, Phượng Minh Cung's market) the stock lists at Formula G prices from the region's local price of each good's rarity band, times the good's scarcity factor; a Hỏa Linh Chi bought for 12 and sold back for 8, Linh Tuyền Thủy (a hot-spring good) bought for 10 and sold for 6: the bulk spread 1.10 / 0.90 with the market's margins 1.05 / 0.95, not the old retail 1.5 / 0.6. The money goes through the market's commons pool. An earlier recording sold a herb for 1: a new world's regions had no demand on record before the first season, so slippage took most of the price (fixed, regression test `market_shop_test.gd`). |

| `sim-11.md` | A 100-year world simulation with no player (tools/balance/world_sim.gd, seed 11, 2026-11-21): money +3.6 % a year in the first decade falling to +0.6 %; prices drift above the 0.9-1.15 band (ore 1.48, special 1.91, crafted 1.85-2.16 by year 1300: the sects' goods spending grows with their investment, which the calibration does not count); the census runs high (Trúc Cơ 1,185 against 844, Nguyên Anh 44 against 27; money speeds NPCs, to retune); one war burst (Thính Vũ Lâu takes two vassals from Phượng Minh Cung, new sects fill the gap), then 80 years of peace and loyalty, because leaders have no traits yet. |

| `sim-11-traits.md` | The same 100 years with leaders' trait pulls (2026-11-21): more feuds and a pact among minor sects; great-sect wars still stop after the first burst. |
| `sim-11-400y.md` | 400 years (2026-11-21): the census returns to target by year 1600 (3,949 / 818 / 196 / 34 / 3), so the first century's excess is world generation's age spread; money +0.2-0.6 % a year; crafted prices 1.7-2.3 throughout; one war; 687 ms a season (beside other runs at low priority). |

| `sim-11-200y-gained.md` | 200 years with trait rows, gained traits from wars, deaths, duels and rebellions (2026-11-21): about 110 people hold a gained trait at years 40-100, falling to 7 by year 200 (F6 expects about 1,000 once the Event Engine grants about 25 a season). Grief fades because only world generation gives masters: new cultivators never get one, so master and disciple ties die out with the first generation. Census, money and prices as in the 400-year run. |

Automated: `tests/unit/economy/` (the ledger and its conservation property test, the formulas against the GDD's worked
examples, the markets on the built continent, the shop).
Probes (observations): `tests/performance/world/economy_probe.gd` (faucet, contract value, M_0),
`tests/performance/world/market_probe.gd` (prices, cover, flows over seasons).
