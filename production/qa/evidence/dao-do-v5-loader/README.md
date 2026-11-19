# Đạo Đồ v5 loader (evidence)

ADR-0004 and `production/plans/dao-do-v5-loader.md`: the game plays the drawn v5 map.

| File | What it shows |
|---|---|
| `01-session-commands.txt` | One Tự Định life {Fire 70, Metal 40} + Thunder in the debug terminal. |
| `02-allocator-perf.txt` | AC-KMD-54, first passing run (2026-11-20, reference machine AMD Ryzen 7 9800X3D): `tests/performance/dao_do/allocator_perf.gd`, 200 seeded NPCs per group, timed around `BuildGenerator.allocate` only. A later run may not exceed it by more than 20 %. The 5,000-NPC world-generation total is not measured here. |
| `03-worldgen-perf.txt` | AC-KMD-54, the world-generation budget: `tests/performance/dao_do/worldgen_perf.gd`, one seeded world of 5,061 people (every NPC's tree allocated on the v5 map), ratings off: 10.2 s against 30 s. |
| `01-session-transcript.txt` | 2026-11-20: birth line "Đạo Đồ start: Fire start (#36) ... 'tree start <kim\|loi>'" (rule 3, AC-KMD-96); `tree` shows spent/unspent points and the next sources "level 2 +1, Luyện Khí Trung kỳ +13, Luyện Khí Hậu kỳ +13" (AC-KMD-56) and each openable node's value after rule 4, e.g. "+0.48 Thần hồn (x1.20 from your root)" (AC-KMD-57); `tree start kim` then `hoa` moves the start before any Dao mark; `tree alloc 42` opens a Fire road: "Fire [Hỏa] purity +0.5 (now 70.5)" (AC-KMD-97); `tree node 2843` (Ember Heart, Chaos land): "no route: behind the Chaos gate", x0.25 (AC-KMD-102); `tree go 2131` opens a 16-node route in one go (AC-KMD-14); `tree targets` lists notables and keystones by cost, the start keystone Fire Feeds Fire at cost 1 with its Effect and closing; `tree map` draws the map around the start, the closed Chaos land as `~`. |

Automated: the GdUnit suite, 474 cases, 0 failures (`tests/unit/dao_do/dao_do_tree_test.gd` rewritten for v5).

Not yet covered here: the keystone Effects in fights (the Effects series).
