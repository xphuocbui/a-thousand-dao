# Power Rankings evidence

| File | What it shows |
|---|---|
| `01-play-session-commands.txt` | The scripted local play session (ratings and the fight engine on in memory via `--set`). |
| `01-play-session-transcript.txt` | 2026-11-15, release build: world generation with ratings (player panel 40 fights, 528 coarse panels); the sheet and HUD showing `power 21`; `explain power` (rating = base + offset, state, rung); the Luyện Khí ranking with the player marked; the Vấn Đỉnh Bảng; the Kết Đan ranking; `look` listing power numbers; `cul 4`; an event fight lost to a rated Luyện Khí Đại viên mãn (1 rated fight, offset ~0 as Formulas D gives against a far stronger opponent; the injury no longer re-runs the panel); a 3-stage jump showing `Power 21 → 43` in the change line; recovery from 35 % to 100 % leaving power unchanged; a 1-year closed-door under the shared multi-season budget (last season 1,648 panel and 1,685 pair fights of its 3,333). |

Not shown: a breakthrough to Provisional (the bare attempt is 0 % without a Trúc Cơ Đan; covered by `rating_service` refresh tests) and the beast list (the player owns none).

Timings in the release build (16 cores), over the new-game baseline of 68 s (world generation 10 s, ratings at load ~21 s, the first season's batch ~38 s at exit):

| Command | Before the shared budget | After |
|---|---|---|
| `cul 4` | 143 s | 71 s |
| 5-year closed-door | ~12 min | 118 s |
| Ratings off, for comparison | new game 10 s, 5-year closed-door +3 s | |
