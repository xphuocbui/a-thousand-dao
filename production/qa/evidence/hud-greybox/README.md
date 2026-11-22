# Evidence: HUD greybox, slices 1 to 3 (2026-11-22)

Spec: `design/ux/hud.md` (Approved 2026-11-22). Scene: `res://src/ui/greybox/map_screen.tscn`.

Produced by a windowed run at each size, never headless (`.claude/docs/run-and-observe.md`):

```
Godot_v4.7.1-stable_win64_console.exe --path . --windowed --resolution 1280x720 res://src/ui/greybox/map_screen.tscn -- --ratings-off --demo --shot-dir res://production/qa/evidence/hud-greybox
```

(and again with `--resolution 1920x1080`). `--demo` plays a fixed script on seed 7 and saves a screenshot per step.
`--ratings-off` switches Power Rankings' fights off for the run: since slice 3 the greybox runs them by default (rule 13
one season late, worker processes), and the demo presses through seasons without pausing. The demo moves the real
cursor for its hover steps (`Input.warp_mouse`): since Godot 4.3 hover follows the real cursor, not pushed motion
events (measured 2026-11-22), so do not use the mouse while it runs.

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
| `20-places-panel` | Slice 3: the Places panel (P): your place and its free actions, known places by region with route times worked out a few per frame, a selected row centring the map at region zoom |
| `21-place-details` | Enter on a row: the place's details in the side panel |
| `22-tooltip-nested` | The tooltip layer: the spirit stones' tooltip opened by hover, a highlighted word's tooltip opened by hover, locked by a middle click ("locked") |
| `23-tooltip-depth-5` | Five levels opened from the keyboard (Q, then Enter on words); at the 5th level the word reads ↗ (opens in the wiki) |
| `24-wiki-stub` | Enter on that word: the wiki entry (a stub in the side panel) instead of a 6th level |

Scaling rule (`scaling/`, one frame each via `--ui-scale=N --shot-and-quit=<path>`, which prints the window, factor and
layout size): `1920x1080-scale100` (factor 1.0, layout 1920×1080), `1920x1080-scale150` (factor 1.5, layout 1280×720:
the cap), `1280x720-scale100` and `1280x720-scale150` (both factor 1.0: at 1280×720 the cap is 100 %), and
`1920x1080-scale150-tooltip` (a nested tooltip at 150 %, placed in layout coordinates). Measured: leaving the content
scale size unset (the engine review's build note) makes Godot stretch from the project's default 1152×648, so the
screen sets the base size to the window size and drives only the factor. Live resizes (`--resize-to=WxH`):
`resized-1280x720-to-1920x1080-scale150` (factor 1.5 after growing) and `resized-1920x1080-to-1280x720-scale150`
(factor 1.0 after shrinking: the cap; the 150 % setting is kept).

Link styles (`scaling/link-styles-1280x720`, user decision 2026-11-22, hud.md Tooltips: Link styles): every
tooltipable readout is underlined and styled by kind: "Linh thạch **30**" and "age **16 / 120**" (numbers, bold), the
date and the realm (terms, gold); tooltip words in the term gold. Item rarity colours are placeholders until the art
bible names them.

After the ADR-0005 review fixes (the layer's busy guard, focus returned on every close, the `tooltip_open` action) and
the link styles, the demo was re-run at both sizes: still 42 and 44 PASS.

After ADR-0006 (the greybox reads only through GameSession's allowlist, StateSnapshot, Advisor and GameQuery; actions
through GameSession.run), the demo was re-run at both sizes: still 42 and 44 PASS.

Rating fights on (the default path, `--turns=4`, shot `scaling/ratings-on-after-4-turns`): world ready in 37 s, End turn
waits 2.7 / 49 / 49 / 32 s back to back (the one-season lag plus 12 worker processes; ADR-0003's 20 s target is not
met). Quitting while a season resolves (`--turns=2 --quit-in-turn`): 12 rating workers alive at the quit, no Godot
process left after exit.

**Run result:** the screen launches at both sizes and plays the slice end to end: a new life, the sheet, seasons of
Cultivate, events answered, a journey to a known place with the fallback to Cultivate. No script errors in the run
output.

**Real-input checks** (printed by the run; all PASS, 42 at 1280×720 and 44 at 1920×1080; the two extra at 1920×1080
are event options clicked, as different events came up):
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
- region zoom shows area bubbles (4 at 1280×720, 8 at 1920×1080)
- no more than bubbles_max area bubbles
- a bubble at another place opens the comparison with Travel preselected
- Esc closes the comparison without changing the focus
- Enter on a focused bubble here acts like a click (market)
- clicking your bubble opens the character sheet
- - returns to continent zoom
- P opens the Places panel; every route time is worked out; selecting a row centres the map at region zoom
- Travel here opens the comparison with Travel preselected
- after travelling with Places open it shows the new place (seen failing first with the rebuild switched off)
- hovering a Places row shows the whole row; Q on the list opens the selected row's tooltip; Esc closes that tooltip and
  focus goes back to the list
- Enter on a row opens the place's details; Esc closes the Places panel
- hovering the spirit stones opens their tooltip; hovering a highlighted word opens a second tooltip
- a middle click locks the chain; a locked chain stays open with the pointer away; a click outside closes it and does not
  reach the map
- Q opens the focused readout's tooltip, locked, with focus inside; Enter on a highlighted word opens its tooltip with
  focus in it; Tab wraps inside the tooltip
- Esc closes only the top tooltip and focus goes back to its word; Esc again closes the root and focus goes back to the
  source
- five levels open; a word at the 5th level opens the wiki (stub) instead of a 6th level; Esc closes the wiki panel
- Esc closes the season summary (a waiting event's card shows instead)

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

**Found by looking in slice 3, fixed:** a NUL character used as the "no region yet" marker in the Places panel made
Godot report "Unexpected NUL character" on every load; `--name=value` launch arguments were not read (the runs hung
waiting to quit); with the panel open, a season's travel left the rows describing the old place (now rebuilt after each
season and each event answer); the tooltip body put a space before punctuation after a highlighted word; the demo's
tooltip waits were in frames, shorter than the 0.3 s delay at this machine's frame rate (now in seconds). A frame-rate cap
during world generation was tried and dropped: 22.0 s with it against 21.7 s without (two runs each).

**Known limits** (by design, not defects): Godot's default look; the LLM is off; season text comes
from the session as terminal-style lines (for example "type 'event' to read"), which the UI does not rewrite; a whole
journey runs in one End turn (multi-season stepping is a session dependency in the spec). Slice 2: the trade, sect,
person and abode windows are terminal-text stand-ins; people bubbles show only at your own place (no last-seen data
yet); the quests bubble is missions and bounties (the quest system is not built); the clue search bubble waits; event
cards cannot be minimised yet, so bubbles cannot be clicked while a card is open; the focus comparison has no preview
numbers yet (the session's preview contract); place labels can overlap each other and the Z4 buttons at region zoom. Slice 3 tooltips: no title strips when
there is no room (older levels can cover neighbouring readouts, never the one they describe), no gamepad Y / d-pad, no
screen-reader announcement of an opened tooltip, the wiki is a stub in the side panel, terms are a small authored file
(`assets/data/ui_terms.json`); Esc runs through `EscRouter`, but the greybox has no banner, confirm mode, multi-season
run, card minimising or game menu, so those answers do nothing; the UI scale setting comes from `--ui-scale` (no
settings menu yet).

Stamp of the files these shots prove: `stamp.txt`.
