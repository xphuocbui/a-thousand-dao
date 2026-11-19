# Đạo Đồ v5 loader (evidence)

ADR-0004 and `production/plans/dao-do-v5-loader.md`: the game plays the drawn v5 map.

| File | What it shows |
|---|---|
| `01-session-commands.txt` | One Tự Định life {Fire 70, Metal 40} + Thunder in the debug terminal. |
| `01-session-transcript.txt` | 2026-11-20: birth line "Đạo Đồ start: Fire start (#36) ... 'tree start <kim\|loi>'" (rule 3, AC-KMD-96); `tree` shows spent/unspent points and the next sources "level 2 +1, Luyện Khí Trung kỳ +13, Luyện Khí Hậu kỳ +13" (AC-KMD-56) and each openable node's value after rule 4, e.g. "+0.48 Thần hồn (x1.20 from your root)" (AC-KMD-57); `tree start kim` then `hoa` moves the start before any Dao mark; `tree alloc 42` opens a Fire road: "Fire [Hỏa] purity +0.5 (now 70.5)" (AC-KMD-97); `tree node 2843` (Ember Heart, Chaos land): "no route: behind the Chaos gate", x0.25 (AC-KMD-102); `tree go 2131` opens a 16-node route in one go (AC-KMD-14); `tree targets` lists notables and keystones by cost, the start keystone Fire Feeds Fire at cost 1 with its Effect and closing; `tree map` draws the map around the start, the closed Chaos land as `~`. |

Automated: the GdUnit suite, 474 cases, 0 failures (`tests/unit/dao_do/dao_do_tree_test.gd` rewritten for v5).

Not yet covered here: the keystone Effects in fights (the Effects series), the allocator's performance budget
(AC-KMD-54).
