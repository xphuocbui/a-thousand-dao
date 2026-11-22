# Evidence: HUD greybox, slice 1 (2026-11-22)

Spec: `design/ux/hud.md` (Approved 2026-11-22). Scene: `res://src/ui/greybox/map_screen.tscn`.

Produced by a windowed run at each size, never headless (`.claude/docs/run-and-observe.md`):

```
Godot_v4.7.1-stable_win64_console.exe --path . --windowed --resolution 1280x720 res://src/ui/greybox/map_screen.tscn -- --demo --shot-dir res://production/qa/evidence/hud-greybox
```

(and again with `--resolution 1920x1080`). `--demo` plays a fixed script on seed 7 and saves a screenshot per step.

| Shot | Shows |
|---|---|
| `00-loading` | "Generating the world…" while world generation runs on a worker thread (about 22 s) |
| `01-new-life-summary` | Z7 summary of the new life over a 30 % map dim |
| `02-map` | The map screen: continent from the grid, known places, the player's marker; Z1 top bar, Z2 window buttons, Z3 portrait cluster, Z4 map modes, Z5 focus and End turn |
| `03-character-panel` | Z6 panel: the character sheet (the debug terminal's text view, for now) |
| `04-event-card-*` | An event card: an option the player cannot pay for is disabled with its reason; End turn reads "Event waiting" |
| `05-outcome-*` | The answer's outcome |
| `06-resolving` | "The world turns…" on End turn while the season runs on the worker thread |
| `07-season-summary-*` | Season summaries (the session's own lines) |
| `08-travel-focus` | A place clicked: the focus becomes "Travel to …", a ring marks the destination |
| `09-journey-summary` | The journey resolved: arrival, places discovered on the way, the fallback note |
| `10-after-journey` | Back on the map: marker moved, more places known, focus back to Cultivate with its note |
| `11-input-sheet-by-key`, `11b-input-sheet-by-portrait` … `14-input-enter-end-turn` | The same screen driven by **real input events** through the viewport (key presses and mouse clicks, not handler calls) |

**Run result:** the screen launches at both sizes and plays the slice end to end: a new life, the sheet, seasons of
Cultivate, events answered, a journey to a known place with the fallback to Cultivate. No script errors in the run
output.

**Real-input checks** (printed by the run, both sizes, all PASS): C opens the character panel; Esc closes it; clicking the portrait opens it (element 7, added 2026-11-22
at the user's request); clicking a place sets Travel to it; clicking End turn passes a season; the summary opens after the turn; Enter on the summary
closes it; Enter on a focused End turn passes a season. **Not exercised by real input in this run:** clicking an event
option (no event came up during the input segment; the option buttons were exercised through their handler in shots
04–05).

**Found by looking, fixed before these shots:** the default panels were see-through (text over the map), now opaque
plates; the demo picked a disabled event option and pressed End turn inside the cooldown (demo bugs, the screen
refused correctly); the Z5 note overflowed the panel at 1080p, now Z5 grows upward; the arrival note carried into the next season's
summary (regression test `test_fallback_note_clears_after_the_next_turn`, seen failing first); the map and the sheet
could be used while an event answer was resolving on the worker thread, now the HUD is inert while a job runs.

**Known limits of slice 1** (by design, not defects): Godot's default look; Godot's built-in tooltips stand in for the
nested tooltip layer; no scaling rule (the HUD is the same pixel size at 1080p as at 720p); the LLM is off; Power
Rankings' rating fights are off in memory for the run until `power-rankings.md` rule 13 is coded; season text comes
from the session as terminal-style lines (for example "type 'event' to read"), which the UI does not rewrite; a whole
journey runs in one End turn (multi-season stepping is a session dependency in the spec).

Stamp of the files these shots prove: `stamp.txt`.
