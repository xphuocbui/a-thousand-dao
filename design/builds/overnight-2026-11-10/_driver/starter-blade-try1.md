# Session transcript: starter-blade-try1

> Final message of one headless `claude -p` session.

The Whetted Edge (Mài Phong Kiếm) is designed and all seven files are written. The fight and identity checks could not be fully assessed because the build's engine, Whetted Edge, is not modelled by the simulator.

The build: a Metal sword for a new player. Quick Draw Cut and the basic attack roll crits constantly. Each crit puts a Whet stack on you (+2 pp crit chance each, max 8, lapsing after 6 s without a crit). The Effect is staged as `whetted-edge`. Flowing Water then trims other arts' timers on each crit. Defence is the sacrifice: it wears the Common Ward with no body bonus.

Directions considered: I chose the Whetted Edge. The two I did not pick are Thousand Returns (many quick arts, crit a side stat) and the Patient Blade (one sheathed art that grows while it waits, so nothing fires early).

Simulator results, 20 fixed seeds:

| Realm | Opponent | Wins / losses | Mean time |
|---|---|---|---|
| Trúc Cơ | typical, same realm | 16 / 4 | 27.1 s |
| Trúc Cơ | typical, one realm above | 0 / 20 | 7.9 s |
| Kết Đan | typical, same realm | 14 / 6 | 20.3 s |
| Kết Đan | typical, one realm above | 0 / 20 | 6.4 s |

Same-realm fights end under the 30 s a typical build is meant to last. The 16 of 20 at Trúc Cơ is on the strong side of the 0.70 edge, which I left alone. Luyện Khí was not run, since only the defining realm and one other are required.

Checks: 7 PASS, 0 FAIL, 3 NOT ASSESSED.
- **Budgets:** the technique's combat bonuses sit outside `bonus_pool`, so its budget can't be checked. The arts and slots pass.
- **Identity test:** the identity piece is unmodelled. The `--without returning-sword-light` proxy changed the fight at both realms (16 to 6 wins at Trúc Cơ, 14 to 6 at Kết Đan), which only shows the flying sword art matters.
- **The fight:** the engine is unmodelled, so the runs are observation only.

The simulator averaged Whet into crit chance. It also could not express the Flowing Water timer cut, linh lực regained on a crit, `basic_coef_add` or Hot Edge's condition. These are listed in the sheet.

Staged: 15 new pieces (3 modifiers, 1 Effect, 3 items, 1 công pháp, 5 arts, 1 Đạo notable pair, 1 cluster idea) and 10 reused. There are two system suggestions: crit as an event with self-stacks, and overflow on the crit-chance cap. Both are also in the guide's last section.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `starter-blade.sheet.md`
- `starter-blade.md` (the player guide)
- `starter-blade.fight.json`
- `starter-blade.ket-dan.fight.json`
- `starter-blade.staging.md`
- `starter-blade.suggestions.md`
- `starter-blade.ledger.md`

BUILD-RESULT: slug=starter-blade status=DONE staged_new=15 staged_reused=10 suggestions=2 checks_fail=0 checks_na=3
