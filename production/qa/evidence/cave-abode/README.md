# Cave Abode in the game (evidence)

GDD: `design/gdd/cave-abode.md` (#47). Plan: `production/plans/cave-abode.md`.

| File | What it shows |
|---|---|
| `01-abode-commands.txt`, `01-abode-transcript.txt` | The debug terminal, 2026-11-21, seed 777 (`new quick`). The starting home in Hạnh Hoa Thị is a free grade-1 residence with 0 of 2 slots (user decision 2026-11-21), and its grade cannot be raised. A cave abode opened on tile 261,244 starts at grade 1 (2 slots, upkeep 1 a season, next grade 20 stones). Tụ Linh and Hộ Sơn take the two slots; Thanh Mộc is refused for want of a slot. `abode raise` pays 20 and the abode is grade 2 after the season (3 slots, rule 6), so Thanh Mộc builds. `explain rate` shows Tụ Linh as layer-1 density (+0.15) under the layer-1 cap. Opening a second abode on 263,244 leaves the first one: the arrays stay behind (rule 10), and the new home is grade 1 with no works. Claiming and reclaiming are covered by `tests/integration/world/cave_abode_session_test.gd`; the terminal has no way here to walk back to an unnamed abode. |

AC-CA-21 (the abode screen) waits for the Game UI GDD (#37). The terminal's `abode` block stands in for it.
