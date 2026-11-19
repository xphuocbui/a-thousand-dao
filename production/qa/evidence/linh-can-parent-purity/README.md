# Spiritual Roots: parent purity and the stronger Chaos (evidence)

Decisions #25-26 (design/dao-do/content-decisions.md), linh-can.md rules 7, 10 and 12, Formulas D2 and E.

| File | What it shows |
|---|---|
| `01-session-commands.txt` | Two Tự Định lives in the debug terminal: {Fire 86, Metal 40} + Thunder, and {Wood 60, Fire 50, Earth 45, Metal 70, Water 55} + Chaos. |
| `01-session-transcript.txt` | 2026-11-19: the sheet reads **Thunder [Lôi] 59, +17.7 % attack** (was 47, +14.1 %: parent purity round(√(86 × 40)), AC-LC-21/-29) and **Primordial Chaos [Hỗn Độn] 55, +11 % cultivation speed, +3.3 % breakthrough chance, +16.5 % attack, +13.7 % khí huyết** (was 44 with two lines: AC-LC-21, Formulas E). |
| `stamp.txt` | Hashes of the files this evidence proves. |

Automated: the GdUnit suite, 466 cases, 0 failures (new: `test_wind_follows_its_parents_ac58`, `test_parents_lands_scale_by_the_variant_ac58`).

Run result: the session reaches "(end of input)" with the expected lines, then Godot 4.7.1 exits 139 (segmentation fault)
at quit. The same session on the code before this change crashes the same way, so the crash predates it (two worlds
generated in one run; not investigated here).

Not covered: the Đạo Đồ half of the 2026-11-19 decisions (hub roads, the Chaos-land gate and its scaling, the 19 new
keystones). The game still builds the old generated tree; those wait for the v5 map loader (dao-do.md, Known gaps).
