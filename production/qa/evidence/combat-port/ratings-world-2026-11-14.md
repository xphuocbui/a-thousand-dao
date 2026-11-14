# Power Rankings measured world run — 2026-11-14

ADR-0003 step 3: a full generated world (seed 4242, 5,177 people) with Power Rankings switched on **in memory only**
(the shipped `combat_rankings.json` stays `enabled: false`), simulated for 4 years (16 seasons) at the default
knobs (`season_fight_budget` 10,000, `panel_budget_share` 0.5, `worldgen_fight_budget` 8,000).

- Tool: `tests/performance/combat/ratings_world_run.gd`, through the release bench export:
  `build/bench/combat_bench.exe --headless -- --ratings-world --years=4 --accuracy --out=<absolute path>`
- Machine: 16 cores, Godot 4.7.1 release export. Each season's batch ran blocking here (the game runs it on a
  background thread, ADR-0003 decision 6); the times include planning (compiling every NPC the first season).
- AC-PR-55 data: `ratings-world-accuracy-2026-11-14.json` (a separate run of the same world, the 4-year run's JSON
  was lost to a relative output path, now fixed; the season and realm figures below are from its console log).

## Throughput (AC-PR-51, Open Question 7)

| | Measured |
|---|---|
| World generation with ratings | 20.9 s (world + player panel 40 fights + 528 coarse panels, 3,444 fights; the load set ran out before the 8,000 cap) |
| A full season batch (10,000 fights) | 31–47 s; 3.1–4.7 ms a fight on threads (first season slowest: it compiles all ~5,000 NPCs) |
| Fights a season | always exactly 10,000: panels 4,968–4,992 (share full every season), pair fights 5,008–5,032 |

## Rule 14 in practice: the panel share is the bottleneck

| Season | Panels run / queued | Pair fights played / planned | Luyện Khí rated |
|---|---|---|---|
| 1 | 188 / 5,000 | 5,024 / 9,324 | 0 |
| 4 | 166 / 4,540 | 5,008 / 9,308 | 0 |
| 8 | 170 / 4,095 | 5,008 / 9,552 | 0 |
| 9 | 171 / 3,996 | 5,032 / 9,860 | 28 |
| 12 | 172 / 3,695 | 5,024 / 9,870 | 294 |
| 16 | 177 / 3,322 | 5,008 / 10,235 | 624 |

- About 170 panels a season (about 29 fights each) against about 70–100 new Stale or Provisional fighters a
  season: the queue drains by about 100 a season. Trúc Cơ is refined by season 9; Luyện Khí starts then, and at
  this rate its remaining ~3,000 take about 30–40 more seasons (8–10 years), as Season budget predicted (~44).
- With the panel share always full, about half the planned pair fights drop every season, nearly all of them from
  the Kết Đan round robin's slice (lowest priority), as Season budget predicted.

## Where NPCs sit after 4 years (panel-rated NPCs; base, not offset)

| Realm | NPCs (panel-rated) | Base p10 / p50 / p90 | Strength × typical p10 / p50 / p90 | Power p10 / p50 / p90 | Largest 240-pt bin |
|---|---|---|---|---|---|
| Luyện Khí | 3,784 (773) | −4,755 / −1,245 / 902 | 0.35 / 0.65 / 0.98 | 37 / 68 / 98 | 11 % |
| Trúc Cơ | 946 (935) | 6,724 / 14,818 / 18,211 | 0.28 / 1.14 / 2.00 | 272 / 1,100 / 1,830 | 5 % |
| Kết Đan | 239 (236) | 27,687 / 35,797 / 40,121 | 0.75 / 2.65 / 5.19 | 7,610 / 23,100 / 41,000 | 3 % |
| Nguyên Anh | 28 (28) | 46,804 / 54,030 / 58,066 | 1.00 / 3.59 / 7.18 | 99,500 / 306,000 / 574,000 | 11 % |
| Hóa Thần | 3 (3) | 70,640 / 72,103 / 73,997 | 4.18 / 5.30 / 7.18 | 4.07 M / 5.11 M / 6.87 M | 33 % (3 NPCs) |

Anchors (typical fighters): 1,000 / 14,195 / 29,506 / 46,842 / 61,627 (power 100 / 1,000 / 10,000 / 100,000 /
1,000,000).

- **Realms never overlap:** no panel-rated NPC of any realm is above the next realm's p10.
- **AC-PR-54 passes** for every realm with at least 20 NPCs (spread ≥ 1,000; no 240-point bin above 25 %). The
  Luyện Khí row is the refined subset only (the starting place first, then the player's region), so it is biased.
- The typical fighter is not the realm median: it sits above most Luyện Khí NPCs, near the Trúc Cơ median, and
  below most Kết Đan and higher NPCs (median ×2.6 to ×5.3). Realm medians show power 68 / 1,100 / 23,100 / 306,000
  / 5.1 M instead of 100 / 1,000 / 10,000 / 100,000 / 1,000,000.
- The starting player (Luyện Khí stage 0, tán tu) rated −7,991, power 21: below the Luyện Khí p10 (37).
- After world generation, coarse panels leave bases clumped (largest bin 29–42 %) because a coarse bracket is 32
  rungs (×2 strength); a year of full panels removes the clumps.

## AC-PR-55 (Open Question 8): warm and coarse panels against a cold one, 50 sampled NPCs

| Check | As written (rungs at `rung_div` 4) | Same strength at `rung_div` 32 |
|---|---|---|
| Warm within 1 rung of cold (×1.19) | 52 % within 1 rung of 32 | **100 %** within 8 rungs; 96 % within 3 |
| Coarse within 3 rungs of cold (×1.68) | 24 % within 3 rungs of 32 | **88 %** within 24 rungs; 66 % within 16 |

AC-PR-55's rung counts were written for `rung_div` 4 and were not rescaled when the guard raised it to 32 (the knobs
were). In strength terms warm panels pass and coarse ones fall just short of 90 %. Fights: cold 32 (40 at most),
warm 24, coarse 6 (10 at most).

## Not covered here

- AC-PR-48's "next season equals a run that never saved": a reloaded game's world tick drifts from an unsaved one's
  within one season **with ratings off too** (12 of 197 people differ in an 80-cultivator world; a different world
  duel is drawn). A Save / Load finding outside Power Rankings; the rating records and the re-planned batch do survive
  a save (rating_session_test).
