# UI Greybox Build: Handoff

> **Purpose**: the running list of what the UI greybox has and what is left, so a new session can resume the UI build
> (user, 2026-11-22: "mark down what needs to be done so I could start again the UI building in another session").
> **Working mode (user, 2026-11-22)**: the user does not want to design the UI: "I want the next session to take care
> of the UI on its own, make decisions except for big ones." So a UI session **works on its own**: pick the next item
> below, decide the layout, components, states, inputs and accessibility details, build it, run the demo, look at the
> screenshots, update this file, then report what was decided. Ask the user only for big decisions: the overall visual
> style (art bible, fonts, colour direction), changes to game rules or other systems' design, scope changes, and
> anything costly or hard to reverse. Before calling a screen done, check every row of its spec's Component Inventory
> against the screenshot and list what is missing, and why, here.
> **Read first**: `design/ux/interaction-patterns.md` (v2, the pattern library), then the screen's spec in
> `design/ux/`. UI design calls are Claude's (memory: ui-design-delegated); ask the user only for big decisions and
> the overall visual style. Commits need the user's go; stage only these paths (a parallel session shares the repo).
> **Run**: `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --path . --windowed --resolution 1280x720
> res://src/ui/greybox/map_screen.tscn -- --ratings-off` (add `--demo --shot-dir res://production/qa/evidence/hud-greybox`
> for the scripted input checks; do not move the mouse while the demo runs: it drives the real cursor).
> **Rules**: ADR-0005 (tooltips: `TooltipLayer.set_tip`, no built-in tooltips) and ADR-0006 (the frontend reads only
> through GameSession read methods, GameQuery, StateSnapshot and Advisor; `tests/integration/ui/ui_frontend_rule_test.gd`
> enforces it; even demo code may not touch `session.db`).

## Done

| Screen | Files | State |
|---|---|---|
| HUD and map (slices 1-3) | `src/ui/greybox/map_screen.gd`, `src/ui/map/*`, `src/ui/windows/places_panel.gd` | Built; spec `design/ux/hud.md` APPROVED |
| Tooltip layer | `src/ui/tooltip/*` | Built (ADR-0005) |
| Person window | `src/ui/windows/person_panel.gd`, `GameQuery.person`, `GameQuery.people_at` | Built: sticky header, sections, ties link on, verbs (only Greet live), reply strip, action bar; the people bubble counts everyone at the place |
| Fight screen | `src/ui/fight/fight_screen.gd`, `GameQuery.practice_fight` | See its own section below |

## Fight screen (`design/ux/fight-screen.md`, APPROVED 2026-11-22)

Entry: person window → Practice fight (a read: nothing changes).

### Built (2026-11-22, pass 2)
- **Data**: `GameQuery.practice_fight` carries per side the arts (id, library name and rule, cooldown, cost,
  element, damage type, charges, steps, empower, pool, statuses), wards (model, cost, drain, cooldown, up, shield,
  block), shields, body shield share, block, evade, crit, reserved, feeds and Effect ids; `items` is always empty.
- **Playback model** `src/ui/fight/fight_playback.gd` (`FightPlayback`, unit-tested in
  `tests/unit/ui/ui_fight_playback_test.gd`): bars, art tallies (firings, damage), charge from the recorded firing
  gaps, steps, empowers, stacks by batch expiry and cleanse, statuses by expiry, fired Effects and banks, the pulse
  count, and the recent rows for floating numbers and link lines.
- **Drawn pieces**: `FightStatBar` (fill, numbers inside, hatched reserved end, mirrored for the foe), `FightSlot`
  (painted icon, cooldown veil, fire flash, step and ⚡ badges, unaffordable veil, ward chamfer, dashed empty slot),
  `FightChip` (painted buff/debuff icon with its baked halo, plus ↑/↓ pip and round/dashed ring; counts; text fallback).
- **Screen** `src/ui/fight/fight_screen.gd`: header (situation, ⏱ clock, pulse, foe realm); mirrored columns:
  portrait box (initial), name, realm and roots, Health, Body shield and Ward shield (starting values, marked
  "(start)"), Linh lực; FORMATION (default line) art slots; WARDS; ITEMS (2 empty); BUFFS; DEBUFFS; STATUS (statuses and
  fired Effects); DOWN. Log newest at top, side-coloured, with step, empower, feed, stacks, status, cleanse lines.
  Floating numbers over the struck health bar (damage-type colour), feed link arrows with "−x s". Every element has a
  tooltip (art: name, cooldown, cost, element and type, the library rule, firings, damage so far, charge, step).
- **Config**: `ui_hud.json` `fight_screen` (timings, sizes, side, bar, damage-type and element colours, item slots).
- **Demo checks**: painted art slots on both sides; slots charge and fire during playback; screenshots 28-30.

### Left to build
Blocked on game data or engine work:
- **Formation diagram shape** (node polarity, layout, links drawn as a graph): Formations #17 is designed
  (`design/gdd/formations.md`) but not built in the engine; until then each side shows the default line (plain slots).
- **Item slots**: fight items are not in the engine; the ITEMS row is an empty placeholder.
- **Ward and shield state over time** (up / down / broken, shield bars draining): the fight log records no ward or
  shield events; the rows show the loadout only. Needs new FightLogRow kinds (ward_up, ward_down, shield_soak).
- **Per-hit Breakdown panel**: the engine does not store each hit's defence steps (evade, resistance, block, shields).
- **Exact stack counts**: the screen sums stack batches by their expiry and removes cleansed stacks oldest first;
  caps and merges inside the engine are not recorded, so a count can drift from the engine's. A STACKS_TOTAL value per
  row would make it exact.
- **Escape channel chip, gate state, record version** (spec Data Requirements: new fight-record events).

Buildable now, not yet done:
- Summary / Full log modes, folded repeats ("Burn ×12"), filter chips by actor and kind, the result-and-reasons line
  first (pattern library v2: Log list).
- Hit lines clickable for a Breakdown once the engine records one.
- Status / counter / stance icon mapping is by file name guess (`status_<id>`, `counter_<id>`, `stance_<id>`): check
  the engine's status and Effect ids against `assets/icons/status/` and add an id-to-icon table where they differ.
- Portrait tooltip should show the full sheet (spec: health, linh lực, ward strength, resistances by type, power).
- Header situation is always "Practice fight"; real fights (sect duel, ambush, tribulation) need their entry points.
- Pad Inspect mode (spec: Inspect mode).
- Reduced motion for floating numbers and flashes (there is no motion helper in `src/` yet: write one, then route
  every animation through it).
- Portrait art (greybox draws an initial in a box).
- Screen-reader announcements on focus and at the ending.

## Other screens not started
Character sheet (a text panel today), inventory, sect screen, Đạo Đồ in-game view (Tree view pattern), formation
diagram editor, season summary polish, notification settings, outliner, map modes beyond terrain, game menu and
settings (rebinding). Specs needed first for most: run `/ux-design <screen>`.

## Pattern-library v2 follow-ups owed to existing screens
- Person window verbs: levers that would flip a refusal, decline consequences (when the verb epic exists).
- HUD alert row: warning / opportunity groups, "mute this kind".
- Tooltips: breadcrumb from level 3, the hover corridor, the lock timer bar (ADR-0005 implementation).

## Log
- 2026-11-22: person window and a bare fight screen (bars, art names, log) wired; demo 51/51. User: the fight screen
  "doesn't look anything like what I wanted, where are the art slots, the buff slots": rebuild toward the spec started.
- 2026-11-22 (pass 2): fight screen rebuilt toward the spec (see Built). Demo 53/53 at 1280x720; tests/unit/ui 66,
  tests/unit/session 52, tests/integration/ui 2, all green. Not yet run at 1920x1080 after this pass; the full
  parallel suite last ran before pass 2 (838 cases, the one frontend-rule failure since fixed). UNCOMMITTED: awaiting
  the user's go. Own paths: assets/data/ui_hud.json, design/ux/{fight-screen,person,interaction-patterns}.md,
  design/research/ui-patterns-paradox-poe-2026-11-22.md, production/plans/ui-greybox-build.md,
  src/gameplay/session/game_query.gd, src/ui/greybox/map_screen.gd, src/ui/tooltip/tooltip_layer.gd,
  src/ui/windows/{person_panel,places_panel}.gd(+uid), src/ui/fight/ (all), tests/unit/session/session_reads_test.gd,
  tests/unit/ui/ui_fight_playback_test.gd(+uid), production/qa/evidence/hud-greybox/25-30 PNGs, .godot class cache.
  Next suggested step: the fight log's Summary / Full modes and folded repeats, then the 1920x1080 run.
