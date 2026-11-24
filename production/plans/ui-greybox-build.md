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
| Z6 window host | `src/ui/windows/window_host.gd`, `game_window.gd`, `assets/data/ui_windows.json` | Built 2026-11-23 night: frame, history (back / forward, Alt+← / →, mouse 4 / 5, forward entries dropped), focus return, sticky header, section jumps (Home / End, LT / RT), reply strip (3 lines + dismiss), Z2 buttons and hotkeys from `ui_windows.json` |
| Character sheet | `src/ui/windows/character_window.gd`, `GameQuery.character`; spec `design/ux/character-sheet.md` (lean r1 NEEDS REVISION, all 11 findings applied) | Built 2026-11-23 night, see its section below |

## Illustrated windows (2026-11-24, user: the windows "look so bad"; OpenAI mock-ups, "learn from ck3 and eu5")
Round 3 mock-ups (`prototypes/ui-mood/`: `r3_wireframes.py` layout sketch with real text and pasted art, gpt-image-2
low) approved for the character sheet and the sect window ("Yes, build it"). Portraits (user: "Set + special
characters"): `tools/asset-pipeline/portraits/gen_portraits.py` painted 144 type portraits (sex × look age × 11 dresses
× 2 tiers, 3 faces for low loose cultivators) and 86 fixed-cast portraits at low quality, about $2.30; game copies
400x600 webp in `assets/portraits/` (9 MB), masters git-ignored in `out/`. `PortraitPicker` (src/ui/portraits/) picks
by GameQuery.portrait_of fields (cast key, sex, look from age over the realm's lifespan, dress from the sect or
loose, tier from realm), stable per person. Place paintings installed as banners (`tools/asset-pipeline/places/
install_place_paintings.py` → `assets/art/places/<continent id>.webp`, 254, 30 MB). `Illustrated` (src/ui/windows/)
holds the shared pieces (wood ground, parchment insets, framed art, round medallions, plaque, icon tiles, gauges, slot
cards); `GameWindow.section_in` makes an inset a jump target; `WindowHost.widths` per kind (character and sect 0.62).
The HUD Z3 portrait shows the player's painting. Evidence: `04/05-character-illustrated-*`, `52/53-sect-illustrated-*`.
Next: the character list (relationships) with portraits and the other windows in the same language; the Thiên phú,
trait and fact-tile icons are still missing (new art).

## Đạo Đồ view: PoE rework (2026-11-24, user: "The dao do view is really bad actually i want a rework. It should be like PoE's skill tree. Please add with icon, and hovering over it gives the stat")
The icon deferral (2026-11-20) is lifted by this request. `tools/asset-pipeline/icons/game_icons_dao_do.py` reuses the
viewer's icon builder at game sizes: 1,678 framed icons for all 8,051 nodes in one 3.3 MB sheet
(`assets/icons/dao_do/game/di-sheet-0.webp` + `icons.json`), no image API calls. The canvas now draws PoE's way: dark
navy ground, every node's framed icon (mipmapped), unallocated dim, allocated bright with gold glowing lines, the plan
and the hovered route pale blue, the frontier ringed; dots in family colours only when zoomed far out. The screen lost
its side inspector: the tree fills the screen, a slim bar on top, and a PoE-style dark hover card follows the pointer
(name in its class colour, stats one per line in mod blue, the purity scale, capability / Effect / price, the cost to
reach it). Click plans a route; clicking a planned mark takes it and everything after it out. Opens at 46 px per unit.
Tests 11 (+3: the card's stat lines, click-to-unplan, an icon for every node). Evidence `92-dao-do-poe-1920x1080.png`.
Blur fix (user: "why is the image quality for the nodes are so blurry"): the first sheet was built at 0.6x the
viewer's sizes (40-112 px); rebuilt at 64-224 px from the 1024 px paintings, 4 sheets, 8.5 MB.

## Đạo Đồ view (built 2026-11-24 night; a full screen; superseded by the PoE rework above)
Spec `design/ux/dao-do-view.md` (lean r1 NEEDS REVISION, 5 blocking + 8 advisory applied). **Look: the v5 viewer
artifact's** (user 2026-11-24: "don't we just use v5 ... do something similar to that"): `src/ui/dao_do/dao_do_canvas.gd`
draws dao_do_map.json (v5) with the viewer's palette (render_tree.py / the artifact's CSS), dots by class, roads and
links, and its Stats colouring by stat family (report.py FAM, copied to `ui_windows.json` dao_do.families); one custom
Control (skips off-screen nodes, redraws only on a change: a test caught it redrawing every frame). The painted framed
icons the viewer shows zoomed in are NOT drawn: the user deferred icon engine wiring to release (2026-11-20).
`src/ui/dao_do/dao_do_screen.gd`: counters (points, open, plan cost, the next point source), search (names and stat
words, pulsing matches, Enter cycles), Apply (only when the points cover the whole plan, rule 3; confirm "permanent: never
refunded"; one `tree_allocate` job per mark, stops at a refusal) and Reset, zoom, Whole, My marks, the start chooser while
no mark is open, the inspector (class and land in words, lines at the player's root, the Chaos gate's condition and
purities, the route's cost, purity before and after, every route mark's lines), Plan (double-click, P, Enter), Shift+arrows
move the selection, leaving with a plan asks keep / discard / stay. `GameQuery.dao_do`, `GameQuery.dao_do_node` (path_to on
a copy of the player with the plan opened). Opens from the Đạo Đồ button / D and the character sheet. Tests
`tests/unit/ui/ui_dao_do_test.gd` (8), reads +2. Evidence `90-91-*.png`. Not built: the icons (release), land names on the
canvas, the start chooser's 9-point preview, the GDD's base-element-count condition (not in the engine).

## Outliner and the Borders toggle (built 2026-11-24 night)
Spec `design/ux/outliner.md` (lean r1 NEEDS REVISION, 3 blocking + 8 advisory applied). `src/ui/hud/outliner_panel.gd`,
`src/ui/hud/outliner_pins.gd`, `GameQuery.outliner`. Z2 under the window buttons on a wood plate: pinned people
(place, band, † died, × / Delete unpins), Home and Seat with here / seasons away (a click centres the map and opens
the window), Ongoing (event waiting), the empty line; collapsible (setting `outliner_open`; compact collapses it until
the player sets it). The person window has a Pin / Unpin button. **Pins are UI-side** (`user://outliner_pins.cfg`,
per world seed and player; memory-only in test runs) until the save format carries them: an ADR item for the user.
Borders: element 13's toggle in Z4 calls `MapView.set_borders` (the map session's method), a player setting for all
saves (also in the menu's Settings). Tests `tests/unit/ui/ui_outliner_test.gd` (7), reads +1. Evidence `80-*.png`.

## Wiki (built 2026-11-24 night)
Spec `design/ux/wiki.md` (lean r1 NEEDS REVISION, 4 blocking + 7 advisory applied). `src/ui/windows/wiki_data.gd`
(static reader over ui_terms, traits, realms, elements, tie kinds), `src/ui/windows/wiki_window.gd`. Index with search
(dims in place) and seven categories; entries with the authored body (highlighted words as links, also as focusable
links), facts (a trait's boons and costs in the game's modifier words, leanings, set, fate pair and price, gained
trigger), related links, ← Index. Opens from the W button, F1, the game menu and every tooltip's "Open in wiki" or
highlighted word (replacing the old text-panel stand-in). Tests `tests/unit/ui/ui_wiki_test.gd` (5). Evidence `70-71-*.png`.
Not built: Effects, modifiers, herbs, rules, the Codex (hud.md's later slices), flavour text for traits.

## Abode screen (built 2026-11-24 night; the first full screen)
Spec `design/ux/abode-screen.md` (lean r1 NEEDS REVISION, 5 blocking + 7 advisory applied). `src/ui/windows/full_screen_host.gd`
(hud.md full screens: an opaque wood board under Z1, ← Back to map, one parchment column; Esc disarms first, then
backs out; it owns the keys while up), `src/ui/windows/abode_screen.gd`, `GameQuery.abode` (CaveAbode and MapWorks
reads). Home line (grade, slots, upkeep or rent, pending raise, unpaid warning, here / away), Raise grade (confirm),
density at home (place_density; the works' layer and clamp lines in the tooltip), Leave shown greyed (no command),
works with level, effective level (dormant, the grade's ceiling), gain, upkeep, Raise (build_work / formation_build,
confirm), Sleep / Wake swaps with the rule 9 banner, clamps, the layer-1 catalogue with Build (element chooser for
share works); no-home view: rent / buy here (the confirm says the current home is left), opening explained, claim with
works kept. Opens from the Abode button / A and the abode bubble. Tests `tests/unit/ui/ui_abode_screen_test.gd` (8),
reads +1. Evidence `60-62-*.png`: AC-CA-21 is the fixture shot (`--abode-fixture`, `AbodeScreen.sample_view()`, display
only: a fresh life cannot show grade 3 with a dormant work). Not built: Leave (no command), opening an abode by a map
tile pick (needs a lens), spirit fields (#14).

## Sect window (built 2026-11-24 night)
Spec `design/ux/sect-window.md` (lean r1 NEEDS REVISION, 3 blocking + 9 advisory applied). `src/ui/windows/sect_window.gd`,
`GameQuery.sect` (SectMembers' pure reads; never `record()`). Member view: rank, contribution, standing (range and
hostile line in the tooltip), the ladder from the data, the next rank's gate as a ✓ / ✗ checklist, Promote (confirm,
names the cost), the sect's facts, other sects, a read-only Services line (not built in the game), Leave on good terms /
Desert with confirms stating what the built game does (desertion: standing now → after by F10, hostile). Loose view:
the sect seated here with `can_join`'s reasons and Join (confirm), other sects, the great sects. The contribution box
(element 35) and the map's sect bubble open it. Tests `tests/unit/ui/ui_sect_window_test.gd` (6), reads +2.
Evidence `50-51-*.png` (a fresh life: loose view). Not built: the head's trial (no trial in the game), services,
rule 19a's loans / residence / deposit on leaving (no such records exist yet), the member view in a shot.

## Rankings (built 2026-11-24 night)
Spec `design/ux/rankings.md` (lean r1 NEEDS REVISION, 4 blocking + 6 advisory applied). `src/ui/windows/rankings_window.gd`,
`GameQuery.rankings` (rule 9 order via `RatingService.peek_person`, which never writes; the player's row reads
`rating_of`, the same value as the rating box). Header: your standing ("1st of 1 rated … · 3,935 provisional, listed
after the rated": rule 9 puts provisional people after the rated, so early in a game the rank counts within the rated),
the last applied batch, realm tabs + Vấn Đỉnh Bảng (a dropdown in the compact layout), search over every row, Jump to
me. Rows: rank, name link, sect (dropped in the compact layout, kept in the tooltip), realm (top list only), stage,
power (~ provisional, stale), rated fights; the player's row framed and "▶ (you)"; the top 50, gap rows (focusable,
Enter shows them) and 5 either side of the player. The rating box opens it (hud.md element 33). Tests
`tests/unit/ui/ui_rankings_window_test.gd` (7), reads +1 (order, the box agreement, the top list). Evidence `40-41-*.png`
(ratings on). **For the user:** at the start every NPC is provisional and the player rated, so the player reads "1st"
until background panels rate the NPCs: a rule-9 presentation question (listed in the morning report).

## Relationships page (built 2026-11-24 night)
Spec `design/ux/relationships-page.md` (lean r1 NEEDS REVISION, 3 blocking + 8 advisory applied).
`src/ui/windows/relationships_window.gd`, `GameQuery.relationships` (built from `Ties` reads). Header: ties / cap,
outside the cap, soft slots used / limit, the next eviction only when full (`Ties.room`), else the room left; search,
sort (kind, strength, name, realm), group chips that keep their headings. Rows: glyph placeholder, kind in Vietnamese
and English, band word and strokes, direction in words (enmity both ways with each band, a feud "does not fade"),
inherited cause, the partner's link (opens the person window), realm, place, attitude band and number, the favour block
in the tooltip (state "awaiting call-in": presented / accepted are not stored yet). "Met, no tie" lists met people.
The person window gained a Relations button (opens the page filtered to that person). Tests
`tests/unit/ui/ui_relationships_window_test.gd` (8), reads +1. Evidence `30-31-*.png` (a fresh life: no ties, so the
shots show the empty states; rows are covered by unit tests). Not built: the painted tie glyphs (text placeholders),
the person window opening inside the host's history (it is its own panel), favour states.

## Inventory (built 2026-11-23 night)
Spec `design/ux/inventory.md` (lean r1 NEEDS REVISION, 3 blocking + 7 advisory applied). `src/ui/windows/inventory_window.gd`,
`GameQuery.inventory`. Header (linh thạch, gear slots base / extra / unslotted with the rule 11 tooltip, search with
diacritic folding and in-place dimming, All + kind chips that persist per screen), kind sections in the data order
(`ui_windows.json` inventory.kind_order), equipped first, rows with the rarity word (`rarity_words`, item-database.md
Formulas A) and colour, item tooltip with the comparison first, Ctrl+C copies an item's text; verbs: Equip (slot
chooser, Replace confirm on an occupied slot), Unequip, Nurture, Eat / Use (confirm), Read, the element chooser for a
treasure that asks (`needs_element`). The linh thạch box opens it (hud.md element 2). Tests
`tests/unit/ui/ui_inventory_window_test.gd` (13), reads +1. Evidence `production/qa/evidence/ui-windows/20-21-*.png`.
**Inventory check**: all rows present; a fresh life owns only a manual and a talisman, so the shots show two kinds (the
pháp bảo rows, chooser and comparison are covered by the unit tests, not by a shot); no Alt advanced view (no tier or
roll data in the item text yet); no item icons (art budget); chips' pressed look is the default theme's.

## Game menu and settings (built 2026-11-23 night)
Spec `design/ux/game-menu.md` (lean r1 NEEDS REVISION, 5 blocking + 10 advisory applied). `src/ui/windows/game_menu.gd`,
`src/ui/settings/player_settings.gd`, map screen `_open_menu` / save / load jobs. Menu (Resume, Save, Load, Settings,
Wiki, Quit with confirm in place), Save (name field, file-safe slot, overwrite confirm, collision check), Load (confirm,
greyed rows with the reason), Settings (UI scale, reduced motion, colourblind, tooltip delay / lock delay / close grace /
lock modes, single-letter hotkeys; applied at once; `user://settings.cfg`, memory-only in test runs), seed + Copy seed.
Opens from ≡, Esc (EscRouter "menu"), Ctrl+S / Ctrl+L, gamepad Select; Esc mid-fight opens it settings-only. Saves:
`user://saves/<slot>.json` + `user://saves/meta/<slot>.json`. Tests `tests/unit/ui/ui_game_menu_test.gd` (10). Evidence
`production/qa/evidence/ui-windows/10-11-*.png`. **Inventory check**: every row present except the deferred settings
(key bindings, brightness, End turn input, toast duration, outliner, borders, alerts by kind: listed on the page); the
fade-in is not animated (no motion helper). A save → load cycle ran on screen through the menu's own jobs
(`--menu-roundtrip`: same player, clock and stones after the load; shot 12); test runs save to `user://saves_test`.

## Character sheet (built 2026-11-23 night)
- Sticky header (name, standing, age / lifespan with ⌛ warning, rating), eleven sections in the spec's order, every derived
  number with its Breakdown tooltip (rate, lifespan, health, linh lực, thần thức, đan độc, backlash, each talent,
  breakthrough chance), element rows with Hán marks, the fighter's combat sheet, công pháp slots with an inline chooser
  (`set_slot` job), the bottleneck block with a confirm-in-place breakthrough (`breakthrough` job; the result opens the
  centre summary), look-only lock marks, compact header at 1280×720. Top-bar boxes open their sections (cultivation,
  lifespan, renown → Fate). Tests: `tests/unit/ui/ui_character_window_test.gd` (9), `ui_window_host_test.gd` (6),
  reads `session_reads_test.gd` (+2 cases, the read added to the no-change table). Evidence:
  `production/qa/evidence/ui-windows/01-03-*.png`.
- **Component Inventory check** (from the shots): all rows present except: the Bottleneck block is not in a shot (a fresh
  life is not at great perfection; covered by unit tests and the reads test); the Combat rows are below the fold in the
  shots; screen-reader roles are names only (Godot exposes `accessibility_name`; no heading role is set); panel slide-in
  is not animated (no motion helper yet; it appears at once, which is also the reduced-motion behaviour).
- Not built: pins (the player is always in the outliner), the portrait art (initial box), the Refusal note beside the
  control (a refused action shows its reason in the reply strip only).

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
