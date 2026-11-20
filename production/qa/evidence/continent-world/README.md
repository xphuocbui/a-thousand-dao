# Continent 11 and its history in the game (evidence)

Plan: `production/plans/continent-world.md` (user decisions 2026-11-20: all of Travel & Map, the fine-cell Formula C
first, hand-authored cast builds, travel anywhere with part seasons).

| File | What it shows |
|---|---|
| `01-session-commands.txt`, `01-session-transcript.txt` | A loose cultivator's new life on the authored world: "A new world: 20 regions, 230 places, 41 sects, 5033 people, 517 recorded events (Thiên Nguyên lịch năm 1200)"; the start at an approved market; the land-match line in `explain rate`; `history` showing the authored annals in Vietnamese; `travel Thiên Quyền Thị` crossing the continent, "You travel 12.21 season(s) over 23 leg(s) ... (13 season(s) pass)", the rest of the last season cultivated. (Recorded before tile travel; the place count is 272 since the history's sites joined.) |
| `02-worldgen-perf.txt` | World generation on the continent: 5,032 people in 9.8 s against the 30 s budget. |
| `03-session-commands.txt`, `03-session-transcript.txt` | A sect disciple's life: the place stat block (land part, shares, climate, "Density for you: 1.80 (place 1.50, layer 2 +0.40, capped at 1.80)"), the map listing only known places ("163 more places you have not seen or heard of"), an authored cast member met through an event, `clues` and `search` without a clue, `arrays`, `work`, a refused rent at one's own sect ("Your sect houses you here"), the free sect residence's furnishing (layer 1 +0.05), flight refused before Trúc Cơ. |

| `04-ac-coverage.md` | The acceptance-criteria audit of both GDDs (189 criteria classified, the most important gaps and every contradiction); its fixes are in 0649d7a and a4777f4. |
| `05-balance.txt` | The balance rounds on the continent, one change at a time, from 50 / 27 / 0 to 66 / 52 / 22 % per gate with the edge (targets 70 / 71 / 33 / 23), the causes found on the way, the accepted gap, and the census. |

Automated: the GdUnit suite (`tests/unit/world/*`: land qi, the builder, travel by link and by tile, discovery, herb
fit, production, map change, works, cast builds).
