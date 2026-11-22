# Evidence: HUD greybox, slices 1 and 2 (2026-11-22)

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
| `08-comparison-travel`, `08b-travel-focus` | A place clicked: the focus comparison opens with "Travel to …" preselected; on confirm the focus is set and a ring marks the destination |
| `09-journey-summary` | The journey resolved: arrival, places discovered on the way, the fallback note |
| `10-after-journey` | Back on the map: marker moved, more places known, focus back to Cultivate with its note |
| `11-input-sheet-by-key`, `11b-input-sheet-by-portrait` … `14-input-enter-end-turn` | The same screen driven by **real input events** through the viewport (key presses and mouse clicks, not handler calls) |
| `16-region-bubbles` | Slice 2: region zoom with the map bubbles (your bubble, the abode bubble, area bubbles at known places within one season by the game's own route times) |
| `17-bubble-elsewhere-comparison` | A real click on a bubble at another place: the comparison with Travel preselected, naming what is there |
| `18-bubble-here` | Enter on a focused bubble at your place: its window opens (the market's read-only stock as a stand-in) |
| `19-back-to-continent` | − back to continent zoom: only your bubble and the abode bubble remain |

**Run result:** the screen launches at both sizes and plays the slice end to end: a new life, the sheet, seasons of
Cultivate, events answered, a journey to a known place with the fallback to Cultivate. No script errors in the run
output.

**Real-input checks** (printed by the run; all PASS, 18 at 1280×720 and 20 at 1920×1080, where more bubbles fit on screen):
- C opens the character panel
- Esc closes the panel
- clicking the portrait opens the character panel
- clicking a place opens the focus comparison with Travel preselected
- confirming in the comparison sets Travel to it
- clicking End turn passes a season
- the summary opens after the turn
- Enter on the summary closes it
- clicking an event option answers it
- Enter on a focused End turn passes a season
- clicking an event option answers it
- continent zoom shows no area bubbles
- + switches to region zoom
- region zoom shows area bubbles (8)
- no more than bubbles_max area bubbles
- a bubble at another place opens the comparison with Travel preselected
- Esc closes the comparison without changing the focus
- Enter on a focused bubble here acts like a click (market)
- clicking your bubble opens the character sheet
- - returns to continent zoom

**Not exercised by real input in this run:** clicking an event option with the mouse when no event came up during the
input segment (the option buttons were exercised through their handler in shots 04–05).

**Found by looking, fixed before these shots:** the default panels were see-through (text over the map), now opaque
plates; the demo picked a disabled event option and pressed End turn inside the cooldown (demo bugs, the screen
refused correctly); the Z5 note overflowed the panel at 1080p, now Z5 grows upward; the arrival note carried into the next season's
summary (regression test `test_fallback_note_clears_after_the_next_turn`, seen failing first); the map and the sheet
could be used while an event answer was resolving on the worker thread, now the HUD is inert while a job runs.

**Found by looking in slice 2, fixed:** the demo's place click landed on the abode bubble (a bubble on a place wins the
click, per the spec: the demo now picks an uncovered place); off-road places have no road links, so bubble reach now
uses the game's own route times (TravelGrid.trip, roads as fallback); rebuilding bubbles on every refresh dropped
keyboard focus, now the same bubble gets focus back; the market stand-in repeated each item's name.

**Known limits** (by design, not defects): Godot's default look; Godot's built-in tooltips stand in for the
nested tooltip layer; no scaling rule (the HUD is the same pixel size at 1080p as at 720p); the LLM is off; Power
Rankings' rating fights are off in memory for the run until `power-rankings.md` rule 13 is coded; season text comes
from the session as terminal-style lines (for example "type 'event' to read"), which the UI does not rewrite; a whole
journey runs in one End turn (multi-season stepping is a session dependency in the spec). Slice 2: the trade, sect,
person and abode windows are terminal-text stand-ins; people bubbles show only at your own place (no last-seen data
yet); the quests bubble is missions and bounties (the quest system is not built); the clue search bubble waits; event
cards cannot be minimised yet, so bubbles cannot be clicked while a card is open; the focus comparison has no preview
numbers yet (the session's preview contract); place labels can overlap each other and the Z4 buttons at region zoom.

Stamp of the files these shots prove: `stamp.txt`.
