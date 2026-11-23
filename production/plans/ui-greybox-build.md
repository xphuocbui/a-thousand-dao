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

## Pass 3 checklist (2026-11-22)
User asked "how much further until we decide on the mood". Claude's recommendation (not yet confirmed by the user):
make this the last greybox pass, trimmed to work that survives a reskin; then the user picks the mood (`/art-bible`
sections 1-4 and 7; the mood work does not wait on this pass), then one Godot theme is applied to the built screens
(style slice: this also means removing the per-node colour and font-size overrides the greybox uses, since they beat a
Theme), and later screens are built in the final style.
- [x] Fight log: Summary / Full modes, folded repeats, filter chips by side and kind, result-and-reasons line first,
      Up / Down between lines, Enter or click pauses (`FightLog` model + `FightLogView`; tests `ui_fight_log_test.gd`)
- [x] 1920×1080 and 150 % UI scale screenshots; nothing clips (the roots line now wraps instead of "…")
- [x] Status / counter / stance id → icon table (findings below)
- [x] Portrait tooltip: the full sheet (health, linh lực, ward points / layer / drain, body shield, block, crit, evade,
      resistances by type, thần thức, soul resistance, power number). **Built, not yet observed**: added after the last
      windowed run; needs one short windowed run (with the user's OK) and a screenshot
- Moved to the styled build: F6 focus zones, reduced-motion helper, pad Inspect mode, screen-reader announcements

### Pass 3 results (2026-11-22)
- **Fight log** (`src/ui/fight/fight_log.gd`, `fight_log_view.gd`): Summary joins an art's firing with its same-instant
  hits and folds repeats of tick, qi_tick, hit, stacks, status, effect, bank and feed rows within `log.fold_gap_ms`
  (the folded line sits at its latest repeat; its total is the sum of its rows, tested). Full is one line per pulse:
  arts fired, damage dealt by type, health and linh lực after. Filter chips: You / Foe and Damage, Arts, Stacks,
  Status, Feeds, Linh lực (off chips are dimmed as well as unpressed). Once the fight has ended the first line is the
  result and up to three recorded facts (time below the cheapest art's cost, the largest damage-type share taken, the
  top source when it is not the whole of that share, dealt vs taken). Lines wrap, come from tr() templates with named
  slots, Up / Down move the selection, Enter or a click pauses and opens a line. Opening a hit shows the amounts the
  record has (before defence, dealt, the target's health after) with "the defence steps are not recorded yet": that is
  not the Breakdown.
- **Fixed, pre-existing**: the map screen configured the fight screen before `ui_hud.json` loaded, so no
  `fight_screen` setting (side colours, sizes, timings) ever applied; it ran on built-in defaults. Now configured in
  `_ready` after the load; a demo check guards it.
- **Floating numbers**: one per side per pulse (AC 22, `float_group_ms`), the sum of the hits and ticks it took.
- **Icons**: the 12 statuses the arts apply all match `status/status_<id>.png` (`status_icons` table empty, for
  exceptions). Effects: the record logs Effect *record* ids ("eff:Layered Earth block"); `GameQuery.effect_of` maps
  them to the Effect's name and rule (now in `practice_fight` as `effect_info`). None of the 109 Effects had an icon by
  file name; `effect_icons` (ui_hud.json) maps 21 whose subject clearly matches a painted counter or stance icon
  (provisional); the other 88 show their name. **The record has no counter or stance rows**, so counter chips (Twin
  flames, Tide ...) cannot show their counts yet: needs a COUNTER row kind in the engine.
- **Demo**: 60/60 at 1280×720, at 1920×1080 and at 1920×1080 with `--ui-scale=150` (shots 31-33, and the scaled set
  in `scaling/` tagged `-scale150`). The two 100 % runs came before the `push_input` change, the portrait tooltip and
  the reflect / return / qi-tick fix (all three checked headless only since). Two fixes to the demo itself: mouse events are pushed in layout coordinates
  (`push_input(ev, true)`; scaled runs missed every click before), and when nobody is at the place the Travel step
  lands on (it differs by window size) the person opens directly and the people-bubble check is skipped. Hover checks
  ("hovering a Places row", "a second tooltip") failed once and passed on rerun: they follow the real cursor.
- **User, 2026-11-22**: windowed demo runs take over the mouse and block the PC. Run only headless tests unless the user
  agrees to a windowed run; a `--no-cursor` mode (skipping hover checks) was offered.
- **Row attribution fix** (also in `FightPlayback`, from before this pass): RETURN is dealt by the row's side to its
  foe and carries the foe's readings (it was read as the side's own); QI_TICK's reading (the drained foe's linh lực)
  is now applied; Soul hits are labelled Soul. Regression test seen failing on the old file, passing on the new.
- Still not built here: Full mode lacks resistance, block, shield soaks and heals (not in the record); the Breakdown, ward / shield state over time, exact stack counts, counter counts (all need new
  record rows); toggle chips' pressed look is the default theme's (the theme pass); the 88 unmapped Effect icons.

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
- ~~Summary / Full log modes, folded repeats, filters, result line~~ (pass 3). ~~Icon table~~ (pass 3). ~~Portrait
  sheet~~ (pass 3).
- Hit lines open a Breakdown once the engine records one (today they open the recorded amounts only).
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

## Style decided (2026-11-22): build in the art bible's Rosewood Campaign Table
Greybox stopped (user, 2026-11-22). `design/art/art-bible.md` Sections 1-4 and 7.10-7.16 define the look; mock-ups in
`prototypes/ui-mood/`. Next: theme assets (nine-slice frames, textures, tab and button states, fonts), one Godot theme,
the fight screen as the style slice (remove per-node colour and font-size overrides), then the other screens; map art
after a one-region test (engine-built vs AI-painted tiles) with a province drawing layer.

**Done overnight 2026-11-22 (Claude, under the UI delegation; see `production/plans/overnight-2026-11-22.md`):**
- `src/ui/theme/rosewood_theme.gd` builds the theme in two surfaces: **wood** (the map screen root: bone text, HUD
  plates as the wood plaque) and **paper** (every window, the tooltip layer and the fight screen: ink text, framed
  parchment). Type variations: WindowPanel, BoardPanel, PaperPanel, WoodPanel, TooltipPanel; WoodLabel, HeadingLabel,
  TitleLabel, WoodHeading, RowLabel, WoodRowLabel; CommitButton (End turn). Lists and text fields styled (parchment
  inset, cinnabar selection band). Tests: `tests/unit/ui/ui_rosewood_theme_test.gd`.
- Fight screen restyled (style slice): carved frames over the wood board, slot rows on a parchment inset with titles
  beside the slots, the log a parchment window; FightStatBar draws the brass trough; FightSlot reads theme colours
  (recess, dashed brass, double focus ring); ward shields hatched.
- Map screen: wood HUD, parchment windows and tooltips, End turn cinnabar; LinkStyle has a "paper" table (cinnabar
  terms, darker relation and rarity colours) and uses the real Literata semibold and italic faces.
- Map view: painted far layer (paper) at continent zoom and near layer (relief) at region zoom, region names on the
  paper map (engine-drawn), diamond markers (art bible Section 3), names on a dark backing with overlap skipping, place
  art drawn on known places only; the place details window shows the place's painting, look, lore and history.
- Not done: the greybox `_greybox_theme()` is still set first and replaced in `_ready`; per-node font-size overrides
  remain in places (map screen, person window, places panel title); the HUD's resource boxes wait for the user's pick;
  labels on the map still use the default font size 13 (below the 14 px floor: raise when the map is reviewed).

**Queued HUD spec change** (`design/ux/hud.md` Z1 Top bar, Group 2; user idea 2026-11-22, Paradox-style resource
boxes; art in art bible 7.13): one box per resource with icon, tabular number and a signed ▲/▼ season change; hover a
breakdown, click the resource's window; contextual boxes only when they apply. Candidates: linh thạch, lifespan left
(moves up from the character box), sect contribution (in a sect), reputation, unspent Đạo Đồ points.
**Picked (user, 2026-11-23):** linh thạch, lifespan left, sect contribution (in a sect), reputation, and a cultivation
box: realm level + exp, cultivation rate at the current place, and the current rating (power number). Unspent Đạo Đồ
points not picked. **Done 2026-11-23:** `design/ux/hud.md` revised (elements 2, 8, 10, 33-35; Z3 readouts moved up, user
pick "move up"; Borders toggle; drop steps 4-5); lean review rounds 12 NEEDS REVISION, 13 NEEDS REVISION, **14
APPROVED** (headless Sonnet, read-only; every finding applied). Built: `src/ui/hud/resource_box.gd`,
`GameQuery.resources` (rate here, power, provisional, contribution, held), HudReadouts change/short/years-left and
numbers following the language, the boxes in the map screen with the frozen per-season change, element 3's short
season label. Evidence: `production/qa/evidence/hud-greybox/10-resource-boxes-{1920x1080,1280x720}.png`; UI tests 83/83,
demo 60/60. **Then, same day (user: "looks a bit bare, do it similar to Paradox"):** CK3/EU4 layout picked; one carved
strip, resources from the left in brass sockets with painted medallions, brass dividers, a hanging date cartouche with
the season's medallion, the alert row (Z1a) below the bar. Art: 3 images (about $0.16), icons picked by the user from
candidates (`tools/asset-pipeline/ui/prompts/topbar-picks.json`), cut by `tools/asset-pipeline/ui/cut_topbar.py`
(`check` mode enforces 8.6 for HUD medallions; watched failing, then fixed). Spec: lean rounds 15 and 16 NEEDS
REVISION, **17 APPROVED**, all findings applied; art bible 7.13, 8.1, 8.3 and 8.6 note. Evidence:
`production/qa/evidence/hud-greybox/11-topbar-paradox-{1920x1080,1280x720}.png`; UI 83/83, reads suite exits 0 with `-d`,
demo 60/60. Not built yet: the Borders toggle (map overlay), alert icons and fold icons (Z1a is still one label),
renown (no game stat yet; shows "—"), the wiki and menu buttons' art.
**Provinces (user, 2026-11-23):** borders only: soft region/control borders drawn over the painted map as a toggleable
overlay; tiles stay the rule unit, no rule change.

## Done 2026-11-23 (afternoon, user requests)
- **Map zoom and the political map** (`design/ux/hud.md` section of that name; lean rounds 18 NEEDS REVISION, 19 and
  20 APPROVED, all findings applied): one continuous zoom in px per tile with momentum (acceleration and friction),
  gliding jumps and pan inertia; the paper map cross-fades into the relief over a transition band; at continent zoom
  the political map (great sects' colours, smoothed bold borders where the holder changes, the sects' names large).
  `src/ui/map/map_view.gd`; tests `tests/unit/ui/ui_map_zoom_test.gd` (7). Sect colours and the red-green palette
  (`ui_hud.json` greybox.map_zoom) approved by the user from `13-zoom-1920x1080-fit(cb).png`.
- **Sharper map:** the paper map repainted at 3x (`tools/asset-pipeline/map/far_upres.py`, 16 crops, ~$0.85), BPTC
  import for both layers, a light unsharp mask on the relief's game copy (`sea_fix.py`).
- **Fight screen** restyled toward mock-up B: one parchment band per slot row, recessed empty slots, numbers on a
  plate at the bar's end, the log's Summary/Full switch and light filter chips, the carved strip behind the header and
  the playback bar, a diamond on the timeline, a framed portrait, a vignette; the ending moved into the header.
- **Test runs:** a cached world per seed and data (`user://world_cache_*`, ~35 s saved a launch), `--shots=` for
  several zoom states in one launch, and ratings off by default in test runs (`--ratings-on` keeps them; the 40-50 s
  End turn wait is recorded in `production/qa/bugs/2026-11-23-season-end-waits-for-ratings.md`).

**Provinces (user, 2026-11-23):** drawn on the map (bf7158b2). Next: provinces as the economy's units (prototype in `prototypes/province-economy/`, then the GDD revision with the user, section by section; the GDD rule is lifted). **Each province is a full record** (user): its resources, mortal population, production, buildings and works, bonuses and modifiers, and so on: designed in the GDD revision.

## Queued (user, 2026-11-23)
- **Map name font looks a bit bad** (region names, and now the great sects' names on the political map): find a
  better way. Options to try: a real calligraphic display face (7.14 asks for one; today the heading face is
  used), drawing names as SDF/MSDF text so they stay crisp at every zoom, a softer paper halo than the 4 px outline,
  kerning and letter-spacing tuned per size, and names following the territory's long axis (curved, CK3-style).
  Judge by screenshot beside a Paradox reference shot.

## Pattern-library v2 follow-ups owed to existing screens
- Person window verbs: levers that would flip a refusal, decline consequences (when the verb epic exists).
- HUD alert row: warning / opportunity groups, "mute this kind".
- Tooltips: breadcrumb from level 3, the hover corridor, the lock timer bar (ADR-0005 implementation).

## Log
- 2026-11-22: person window and a bare fight screen (bars, art names, log) wired; demo 51/51. User: the fight screen
  "doesn't look anything like what I wanted, where are the art slots, the buff slots": rebuild toward the spec started.
- 2026-11-22 (pass 2): fight screen rebuilt toward the spec (see Built). Demo 53/53 at 1280x720; tests/unit/ui 66,
  tests/unit/session 52, tests/integration/ui 2, all green. Not yet run at 1920x1080 after this pass; the full
  parallel suite last ran before pass 2 (838 cases, the one frontend-rule failure since fixed). COMMITTED in e7826bde (were awaiting
  the user's go). Own paths: assets/data/ui_hud.json, design/ux/{fight-screen,person,interaction-patterns}.md,
  design/research/ui-patterns-paradox-poe-2026-11-22.md, production/plans/ui-greybox-build.md,
  src/gameplay/session/game_query.gd, src/ui/greybox/map_screen.gd, src/ui/tooltip/tooltip_layer.gd,
  src/ui/windows/{person_panel,places_panel}.gd(+uid), src/ui/fight/ (all), tests/unit/session/session_reads_test.gd,
  tests/unit/ui/ui_fight_playback_test.gd(+uid), production/qa/evidence/hud-greybox/25-30 PNGs, .godot class cache.
  Next suggested step: the fight log's Summary / Full modes and folded repeats, then the 1920x1080 run.
- 2026-11-22 (pass 3): see "Pass 3 results" above. Full parallel suite (JOBS=4, headless): 856 cases in 24 groups,
  all green. Not committed (awaiting the user's go). Own paths added:
  src/ui/fight/fight_log.gd, src/ui/fight/fight_log_view.gd (+uid), tests/unit/ui/ui_fight_log_test.gd (+uid),
  tests/unit/session/session_reads_test.gd, src/gameplay/session/game_query.gd, assets/data/ui_hud.json,
  src/ui/fight/fight_screen.gd, src/ui/fight/fight_playback.gd, src/ui/greybox/map_screen.gd, .godot/global_script_class_cache.cfg,
  production/qa/evidence/hud-greybox/ (re-shot 16, 18, 20, 28-30; new 25-33 at 1920x1080, 31-33 at 1280x720, 04/05
  event shots of this run) and scaling/*-scale150 (skip 04-event-card-6-0 and 05-outcome-7-0: from the failed scaled
  run). Not ours, untracked before the session: production/todo.md, tests/performance/world/*.uid,
  tests/unit/crafting/herb_rework_test.gd.uid.
  User also asked (2026-11-22) about replacing tiles with Paradox-style provinces; Claude's estimate is in the
  conversation (province layer over the kept grid ~1-2 sessions; provinces as the rules' unit = several sessions +
  balance). Awaiting the user's goal and province count; do it before restyling the map screen.
