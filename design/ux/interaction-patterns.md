# Interaction Pattern Library

> **Status**: In Review, **v2** (written 2026-11-22 by Claude under the user's delegation of UI design: "only come to
> me for really big decisions and the overall style"; v2 the same day after the user asked for "the best of best" of
> Paradox games (Victoria 3, CK3, EU5) and Path of Exile)
> **Author**: ux-designer (Claude), from the HUD, person window and fight screen specs, and the research in
> `design/research/ui-patterns-paradox-poe-2026-11-22.md`
> **Last Updated**: 2026-11-24 (11 entries added for the illustrated windows, each naming its code)
> **Template**: Interaction Pattern Library
> **Sources**: `design/ux/hud.md`, `design/ux/person.md`, `design/ux/fight-screen.md`,
> `docs/architecture/adr-0005-tooltip-layer.md`, `docs/architecture/adr-0006-game-session-facade.md`,
> `design/accessibility-requirements.md`

---

## Overview

The patterns every screen of the game reuses, so a window built next month behaves like the HUD built today. A screen
spec names the pattern it uses instead of re-specifying it; a spec that needs something new adds it here first. The
look (colours, frames, fonts) belongs to the art bible; this library owns behaviour: input, feedback, states and
accessibility.

Rules that hold for every pattern:
- **Keyboard, mouse and gamepad** all reach it (gamepad Partial: every map-screen action, and dense full screens
  through an Inspect mode); Tab moves within a zone, F6 between zones, Esc follows the HUD's Esc router.
- **Colour is never the only cue:** a word, a mark, a shape or an icon always backs it.
- **Text floors** 16 px, 14 px for secondary and tooltip detail; contrast 4.5 : 1 text, 3 : 1 icons, bars and focus.
- **Reduced motion** makes every animation instant through the one motion helper; nothing depends on an animation.
- **Reads, never writes:** a pattern reads game state through `GameSession` read methods and Guidance reads
  (ADR-0006) and changes it only through an action.
- **Compute once, show everywhere** (CK3's red-X-versus-tooltip bug): a verdict, odds or total is computed in one
  place and every surface that shows it (row, tooltip, Breakdown) reads that one value.
- **Information never looks like an action** (EU5 criticism): buttons have a frame and a hover state; information
  icons and readouts have neither. Vital actions are never tiny.
- **At most two levels deep** (EU5's sub-sub-screens): a screen may have tabs or sections, never a screen inside a
  screen inside a screen; links between panels replace nesting.
- **Teach where it is used** (PoE 2's untaught tooltip chaining): every power feature (locking, Alt for detail, search
  syntax, Inspect) shows a one-line hint where it applies the first few times, and its shortcut is in its tooltip.
- **Every shortcut is rebindable** and shown in its control's tooltip; the bindings screen flags conflicts.
- **Panels remember** their scroll position, tab and filters (Victoria 3's most wanted fix).
- **Turn-based translation:** where the Paradox games pause, this game blocks End turn instead.

**Lineage** (`design/research/ui-patterns-paradox-poe-2026-11-22.md`): tooltips and concepts from CK3 and Victoria 3;
number breakdowns, lists, outliner and notification settings from Victoria 3; alert muting, automation and map-mode
breadth from EU5; item tooltips, comparison, tree search and path preview from Path of Exile and Path of Building;
genre conventions only, never any game's art, icons or frames.

---

## Pattern Catalog

| Pattern | Category | Used in | Learned from |
|---|---|---|---|
| [Nested lockable tooltip](#nested-lockable-tooltip) | Overlay | Every screen (ADR-0005) | CK3, Victoria 3 |
| [Link styles](#link-styles) | Data display | Every screen with tooltips | CK3 concepts, PoE keywords |
| [Breakdown](#breakdown) | Data display | Tooltips, fight screen, person window | Victoria 3 |
| [Side panel with history](#side-panel-with-history) | Navigation | HUD Z6: character, person, place, sect, places list | CK3, Victoria 3 |
| [Sticky header and pinned action bar](#sticky-header-and-pinned-action-bar) | Layout | Person window; future long panels | — |
| [Section jumps](#section-jumps) | Navigation | Person window, fight screen | — |
| [Centre window](#centre-window) | Modal | Event card, season summary, focus comparison | CK3 events |
| [Decision window](#decision-window) | Modal | Big irreversible choices (joining a sect, a breakthrough attempt, a bond) | CK3 decisions |
| [Focus comparison](#focus-comparison) | Input | HUD (element 29) | Civ end turn, Victoria 3 predictions |
| [End turn gate and blocker](#end-turn-gate-and-blocker) | Input | HUD (element 15) | Civ |
| [Look-only lock](#look-only-lock) | Feedback | HUD bubbles, person window, any changing action | — |
| [Will / won't badge](#will--wont-badge) | Feedback | Person window verbs | CK3, Victoria 3 |
| [Confirm in place](#confirm-in-place) | Input | Person window verbs; costly actions | — |
| [Inline chooser](#inline-chooser) | Input | Person window verbs (gift, lesson, loan) | — |
| [Reply strip](#reply-strip) | Feedback | Person window | — |
| [Toast](#toast) | Feedback | HUD (free-action results), fight screen (controller disconnect) | Victoria 3 feed |
| [Refusal note](#refusal-note) | Feedback | HUD (End turn, focus) | — |
| [Alert row](#alert-row) | Feedback | HUD Z1 | CK3, EU5 1.1, Victoria 3 #74 |
| [Notification settings](#notification-settings) | Settings | Game menu (to be specced) | Victoria 3 #74, EU5 1.1 |
| [Outliner](#outliner) | Navigation | HUD Z2 | Victoria 3, CK3 |
| [Map modes](#map-modes) | Navigation | HUD Z4 | EU5, Victoria 3 lenses |
| [Map bubble](#map-bubble) | Navigation | HUD map | CK3 |
| [Top bar resource](#top-bar-resource) | Data display | HUD Z1 | CK3, Victoria 3 |
| [Searchable list](#searchable-list) | Data display | Places panel; inventory, known list, trade, sect roster | Victoria 3, PoE stash |
| [Item tooltip](#item-tooltip) | Overlay | Inventory, trade, loot, gear in the person window | Path of Exile |
| [Tree view](#tree-view) | Data display | Đạo Đồ; the diagram editor | Path of Exile, Path of Building |
| [Status chip](#status-chip) | Data display | Fight screen; person window badges | PoE buff bar |
| [Stat bar](#stat-bar) | Data display | Fight screen, HUD cultivation bar | — |
| [Loadout icon](#loadout-icon) | Data display | Fight screen (nodes, wards, items) | Auto-battler loadouts |
| [Formation diagram](#formation-diagram) | Data display | Fight screen; diagram editor (to be specced) | PoE 2 gem linking |
| [Log list](#log-list) | Data display | Fight log; future news and journal | — |
| [Playback bar](#playback-bar) | Input | Fight screen | — |
| [Inspect mode](#inspect-mode) | Input (gamepad) | Fight screen; any dense full screen | — |
| [Automation toggle](#automation-toggle) | Input | Herb fields, abode upkeep, sect chores (to be specced) | EU5 |
| [Tab bar](#tab-bar) | Navigation | Character sheet | — |
| [Wood ground and parchment inset](#wood-ground-and-parchment-inset) | Layout | Every illustrated window | — |
| [Hero painting](#hero-painting) | Data display | Sect window, abode screen, game menu | — |
| [Portrait frame and round medallion](#portrait-frame-and-round-medallion) | Data display | Character sheet, sect, relationships, rankings | — |
| [Icon tile](#icon-tile) | Data display | Character sheet, sect window, abode screen | — |
| [Slot card](#slot-card) | Data display | Character sheet | — |
| [Trait icon](#trait-icon) | Data display | Character sheet | CK3 trait row |
| [Person card](#person-card) | Data display | Relationships page | CK3 |
| [Podium](#podium) | Data display | Rankings | — |
| [Rarity-framed item tile](#rarity-framed-item-tile) | Data display | Inventory | Path of Exile |
| [Node card](#node-card) | Overlay | Đạo Đồ | Path of Exile |

---

## Patterns

### Nested lockable tooltip
**Category**: Overlay · **Used in**: every screen

**Description**: the game's own tooltip layer (ADR-0005). Hovering a source opens a tooltip; a highlighted word inside
it opens the next level; the chain locks so the player can read and move through it.

**Specification**:
- Opens after `tooltip_delay` (0.3 s); closes after `tooltip_close_grace` (0.3 s) off the source and the chain; locks
  after `tooltip_lock_delay` (1 s) of rest, on a middle click, or on a click inside (lock modes are a setting).
- One chain at a time; at most `tooltip_depth_max` (5) levels; a word at the last level opens the wiki. From level 3 a
  **breadcrumb** at the top of the newest level names the chain ("Spirit stones › Spiritual qi › Cultivation base"),
  and a click on a crumb closes the levels above it.
- **A forgiving corridor** (CK3's Mouse Tendency, Victoria 3 #74): while the pointer moves from a source toward its
  open tooltip, nothing it crosses on the way opens a new tooltip.
- **A visible lock timer:** a thin bar along the tooltip's top edge fills during `tooltip_lock_delay`, then shows the
  lock mark; the first few tooltips carry the footer hint "Middle-click or rest to pin" (teach where it is used).
- Keyboard: Q or F2 opens the focused element's tooltip locked with focus inside; Tab wraps through its words; Enter
  opens a word; Esc closes one level and returns focus. Gamepad: Y opens it; A opens a word; B closes.
- Content: name, key fact, one-line summary, then the [Breakdown](#breakdown). Highlighted words follow
  [Link styles](#link-styles).
- A season change or a window opening over the chain closes it; a click outside a locked chain closes it and is
  consumed. No tooltip reads game state while a session job runs.
- Screen reader: words are focusable link buttons; each tooltip has "Open in wiki".

**When to use**: anything a number, term, person, place or item needs explained. **When NOT to use**: never Godot's
built-in `tooltip_text` (banned by a scan test); not for actions (use a button).

### Link styles
**Category**: Data display · **Used in**: every screen with tooltips

**Description**: how text that has a tooltip looks (`design/ux/hud.md`, Tooltips: Link styles).

**Specification**: always underlined, then by kind: terms in the term colour; numbers with a Breakdown bold; people bold
in their relation colour; places italic; items in their rarity colour; sects bold italic in the sect's colour. In a
readout only the part with the tooltip is styled. Buttons, bubbles and icons keep their own look. Colours are data
(`ui_hud.json` `link_styles`).

**When to use**: every tooltipable text or number. **When NOT to use**: buttons and icons.

### Breakdown
**Category**: Data display · **Used in**: tooltips, the fight screen, the person window

**Description**: every derived number explains itself as an ordered list of steps (Architecture Principle 2).

**Specification** (Victoria 3's breakdowns): the **total first**, then the base, then the contributions **sorted by
size**, each with its sign and a word, never an icon alone ("+30 % Mộc purity", "× 0.75 season left"), each source a
[link](#link-styles); contributions too small to matter fold into "Other (n)", which expands on click; where order
matters for the maths (multipliers after additions), the steps keep the rule's order and the sorting applies within
each group. Before an action, a **prediction line** shows the change ("after this: 12 → 15"). A value that changes by
season may show a small sparkline of the last 8 seasons. Secondary lines at 14 px. In the fight, a hit's steps run
evade → resistance → block → each ward shield → body shield → health, with each part's type history; a heal shows
healing and healing taken. The Breakdown is recorded or computed by the rules, never by the screen.

**When to use**: any number the player might ask "why?" about. **When NOT to use**: plain counts with no rule behind them.

### Side panel with history
**Category**: Navigation · **Used in**: HUD Z6 (character, person, place, sect, places list)

**Description**: one panel at a time over the left third of the map; the map stays live.

**Specification**: slides in over `motion_fast`; opening a name inside replaces it; back and forward step through the
last `history_max` (20) windows (Alt+← / →, mouse 4 / 5, the frame's arrows); opening it moves focus to its first
control; closing returns focus to the opener; Esc closes it when it holds focus. A history entry stores the window kind
and subject id; a gone subject shows a note. Each panel kind remembers its scroll position, tab and filters when
reopened. A panel may have sections or tabs but never a panel inside it; another entity always opens as its own panel.
The illustrated windows may be wider than a third of the screen: `ui_windows.json` `widths` gives 0.62 of the screen to
the character sheet, sect window, relationships page and rankings, and 0.5 to the inventory; the behaviour is the same.

**When to use**: information about one thing (a person, place, sect). **When NOT to use**: decisions that need an answer
(use a [Centre window](#centre-window)).

### Sticky header and pinned action bar
**Category**: Layout · **Used in**: person window; future long panels

**Description**: for a panel taller than its space: who or what it is stays in view at the top, the main actions at the
bottom, and the body scrolls between them.

**Specification**: the header never scrolls (identity and the key numbers); the action bar never scrolls (at most 4
buttons; wraps or shrinks to icon + short label under 30 % longer text); the body scrolls with wheel, arrows, PgUp / PgDn
and the right stick; sections never vanish when empty ("none").

**When to use**: a panel whose content is several screens tall. **When NOT to use**: short panels (no chrome needed).

### Section jumps
**Category**: Navigation · **Used in**: person window, fight screen

**Description**: section headings are jump targets, so a long body is quick to move through.

**Specification**: Tab lands on headings; Home / End go to the first and last; a pinned button can jump to a named
section (Verbs); gamepad uses the triggers LT / RT (the shoulders belong to the HUD's window buttons). Nothing collapses.

**When to use**: bodies with 3 or more sections. **When NOT to use**: single-section panels.

### Centre window
**Category**: Modal · **Used in**: event card, season summary, focus comparison

**Description**: a window in the centre of the map over a dim, for something that wants an answer or a read.

**Specification**: width capped by `centre_width_max`; with a panel open, it centres in the space right of it; focus
moves into it; a blocking event card keeps focus and F6 inside until answered or minimised; a non-blocking one closes on
Esc or Enter on its default button; closing returns focus to where it was.

**When to use**: events, summaries, comparisons. **When NOT to use**: browsing information (use a panel).

### Focus comparison
**Category**: Input · **Used in**: HUD element 29

**Description**: every season focus the player can take, side by side, with its preview, so a turn is chosen knowingly.

**Specification**: rows of options (Cultivate, Travel to X, Explore, Mission …) each with gain, seasons, lifespan used,
risk band and cost; unavailable ones greyed with the reason; preselected by what opened it; confirming sets the focus
and does not end the turn; the preview is deterministic and cached until the state changes; the share of the season left
after timed free actions scales it.

**When to use**: choosing what the season is spent on. **When NOT to use**: free actions (they act at once).

### End turn gate and blocker
**Category**: Input · **Used in**: HUD element 15

**Description**: one gate decides whether End turn works and says why not.

**Specification**: the button names the focus ("End turn: Cultivate") or the blocker ("Event waiting: <title>", "Check
focus: <reason>", "The world turns…"); a click on a blocked button opens the blocker; a cooldown after each turn; key
repeat never ends two turns; while a season resolves the HUD is inert.

**When to use**: the season turn only. **When NOT to use**: other actions (they use [Refusal note](#refusal-note)).

### Look-only lock
**Category**: Feedback · **Used in**: HUD bubbles, the person window, any action that changes the character

**Description**: while a blocking event waits, windows stay readable but anything that changes the character is locked.

**Specification**: a lock mark on the control plus the words "locked while an event waits (look only)" in its tooltip
and accessible name; reading, tooltips and navigation stay live; the lock lifts when the event is answered.

**When to use**: every changing action during a blocking event. **When NOT to use**: reading.

### Will / won't badge
**Category**: Feedback · **Used in**: person window verbs

**Description**: before an action whose answer is decided by a score, show the answer and why, so there are no surprise
refusals.

**Specification**: "v will accept" or "x won't accept" (a word plus a mark, never colour alone) in a fixed short column;
the reason in words on the row (the score's parts: "score −12: attitude −8, realm gap −4"); the full breakdown in its
tooltip; the same state always gives the same answer. **Levers** (Victoria 3 #74): a refused row says what would flip
it when the player can do it now ("a gift worth 40 stones would make them accept"); **the decline consequence** (CK3)
is on the row's tooltip ("refusing costs nothing" or "they remember it"). The verdict is computed once and every
surface reads it.

**When to use**: any action another character can refuse by a score. **When NOT to use**: chance-based outcomes (show
the odds instead).

### Confirm in place
**Category**: Input · **Used in**: person window verbs; any costly or irreversible action

**Description**: a costly action asks for a second press on the same spot rather than opening a dialog.

**Specification**: the first press turns the row or button into "Confirm: <cost>? [Confirm] [Cancel]" with no movement;
a second press confirms; Esc or Cancel backs out and changes nothing; it times out never (no timed input).

**When to use**: actions that spend resources, create a debt or can't be undone. **When NOT to use**: free, safe actions
(they run at once).

### Inline chooser
**Category**: Input · **Used in**: person window verbs (which gift, which lesson, loan size)

**Description**: an action with one parameter expands in place into its choices.

**Specification**: the row expands into a short list (items, lessons) or a stepper (an amount), keyboard and pad
navigable, then [Confirm in place](#confirm-in-place); Esc collapses it.

**When to use**: one small parameter. **When NOT to use**: several parameters (give the action its own panel).

### Reply strip
**Category**: Feedback · **Used in**: person window

**Description**: the result of an action shown where the player is, without moving them.

**Specification**: pinned above the action bar, up to 3 wrapped lines (the line, then effect lines such as "attitude +3:
gift"); slides up over `motion_fast`; dismissed by its own button, the next action or closing the panel; announced
politely to screen readers.

**When to use**: results of actions inside a panel. **When NOT to use**: map-level results (use a [Toast](#toast)).

### Toast
**Category**: Feedback · **Used in**: HUD free-action results; the fight screen's controller-disconnect notice

**Description**: a short note that something happened.

**Specification**: bottom centre above Z4; at most 3 stacked, newest on top; lasts `toast_seconds` (3 s); announced to
screen readers; never the only record of anything important (the season summary or a log keeps it).

**When to use**: confirmations ("Bought 3 herbs"), notices. **When NOT to use**: anything needing an answer.

### Refusal note
**Category**: Feedback · **Used in**: HUD (End turn, focus)

**Description**: why an action could not run, said next to it.

**Specification**: one line in words beside the control for `refusal_seconds` (2 s), and in its tooltip until the
state changes; announced; never a modal.

**When to use**: a refused action. **When NOT to use**: predictable refusals (show them before, as a greyed control
with its reason).

### Alert row
**Category**: Feedback · **Used in**: HUD Z1

**Description**: open situations that want attention, as icons.

**Specification**: one icon per open alert (at most `alerts_shown_max`, 8), with **warnings and opportunities** in two
groups (CK3); critical alerts are larger and pulse once, so they never look routine (EU5's missed shortage); hover for
detail; a click opens the window concerned; right-click, Delete or gamepad X snoozes a non-blocking one until next
season, and "mute this kind" mutes it until unmuted in [Notification settings](#notification-settings); blocking
alerts cannot be snoozed or muted.

**When to use**: standing conditions (an event waiting, low lifespan). **When NOT to use**: one-off results (use a toast).

### Map bubble
**Category**: Navigation · **Used in**: HUD map (elements 30–32)

**Description**: what can be done at a place, as round icons on the map.

**Specification**: your bubble and the abode at every zoom; area bubbles at region zoom within one season of travel (at
most 12); kinds market, sect and quests, people you know (where they are now), explore and search; a free action at your
place opens its window, anything elsewhere or season-long opens the [Focus comparison](#focus-comparison); never shown
under the HUD zones or an open panel.

**When to use**: map-level shortcuts. **When NOT to use**: inside windows.

### Status chip
**Category**: Data display · **Used in**: fight screen; person window badges

**Description**: a compact icon with a number for a stack, status, counter or curse.

**Specification**: an icon and its number only; buffs a soft round halo with ↑, debuffs a jagged halo with ↓ (shape
and pip, not colour alone); hover shows the Effects tooltip shape (name, kind, `closes`, rule, limits); at least
32 × 32 px; Enter or click pins its tooltip and filters the log.

**When to use**: many small states at once. **When NOT to use**: single important states (give them words).

### Stat bar
**Category**: Data display · **Used in**: fight screen, HUD cultivation bar

**Description**: a pool as a bar, with its value in words.

**Specification**: a label and the number beside it (never the bar alone); a locked segment for a reserved share; a
trailing segment shows a chunk lost; eases over about 120 ms (instant under reduced motion); hover for exact numbers and
the Breakdown.

**When to use**: pools that rise and fall. **When NOT to use**: counts (use a number).

### Loadout icon
**Category**: Data display · **Used in**: fight screen (nodes, wards, items)

**Description**: a slotted art, ward or item that charges and fires.

**Specification**: a cooldown fill; a flash on fire within the flash cap (at most 3 flashes a second on the screen,
merged per instant, a steady highlight at 4×); badges for next step, empowered and charges; dimmed when unaffordable;
a real `Control` with an accessible name ("Node 1, positive, Twin Flame Echo, ready").

**When to use**: things that fire on a timer. **When NOT to use**: passive stats.

### Formation diagram
**Category**: Data display · **Used in**: fight screen; the diagram editor (to be specced)

**Description**: a side's art loadout as a small graph (`design/gdd/formations.md`).

**Specification**: round nodes with the art inside, in the Đạo Đồ node grammar; polarity as a mark in the ring (+, −, a
condition glyph); feed links as arrows, adjacency as plain lines; the heading names the diagram and its share (laid
100 %, carried 70 % or 50 %, dimmed when carried); plain slots follow as a row; up to 8 nodes at 1280 × 720, larger
ones scale to a 32 px floor then scroll; a feed shows as a pulse along its arrow; each node's tally on hover; the
heading opens the diagram's Breakdown.

**When to use**: showing or editing a diagram. **When NOT to use**: the default line (a plain row of icons).

### Log list
**Category**: Data display · **Used in**: the fight log; future news and journal

**Description**: a time-ordered list of lines, each one openable.

**Specification**: newest at the top; a Summary and a Full mode; **repeats fold** ("Burn ×12, 96 total") and expand
on click; filter chips by actor and by kind; for a finished sequence the **result and its top three reasons come first**
("lost: out of linh lực at 18 s; 60 % of damage taken was Earth"), so nobody has to read the raw log for the outcome; Up / Down move between lines; Enter or a click opens the
line's detail (a Breakdown) and pauses anything playing; lines are built from templates with named slots and wrap
(never truncate); read by screen readers on focus, never announced live.

**When to use**: event histories. **When NOT to use**: lists of things to choose (use a list with selection).

### Playback bar
**Category**: Input · **Used in**: fight screen

**Description**: controls for watching a recorded sequence.

**Specification**: play / pause (Space, pad A), step by event (. and , or ← / →, pad D-pad; Shift by pulse), speed
1× / 2× / 4× (1 / 2 / 3, pad LB / RB), skip to the end (S, pad Y; Enter only activates the focused control), a timeline
scrubber (drag; focused: ← / → by event, PageUp / PageDown ±10 s, Home / End); the outcome is fixed before playback, so
skipping or scrubbing changes nothing.

**When to use**: watching a recorded fight or sequence. **When NOT to use**: live, interactive time.

### Inspect mode
**Category**: Input (gamepad) · **Used in**: fight screen; any dense full screen

**Description**: on a pad, a mode that pauses and lets a focus ring visit every element so its tooltip can be read.

**Specification**: the right stick click toggles it; anything playing pauses; the D-pad moves a focus ring spatially;
each focused element shows its tooltip; A pins it (as a click); the same button returns. It makes the pillar "every
number explains itself" hold on a pad.

**When to use**: full screens too dense for the HUD's Partial gamepad rule. **When NOT to use**: the map screen (it is
already pad-navigable).

### Decision window
**Category**: Modal · **Used in**: big irreversible choices (joining or leaving a sect, a breakthrough attempt, a bond)

**Description** (CK3 decisions): before a big, irreversible choice, one window lists what it needs, what it costs and
what follows.

**Specification**: a [Centre window](#centre-window) with three blocks: requirements (each met or unmet, with a mark
and a word), costs (with prediction lines), consequences (what changes and what cannot be undone); the confirm button
names the action ("Join Thiên Xu Tông"); Esc cancels. Cheap or reversible actions never get one: they use
[Confirm in place](#confirm-in-place) or nothing.

**When to use**: a few big, irreversible choices. **When NOT to use**: anything routine (dialog fatigue).

### Notification settings
**Category**: Settings · **Used in**: the game menu (to be specced)

**Description** (Victoria 3 #74, EU5 1.1): the player decides what each kind of notice does.

**Specification**: one row per notice kind with three choices: **blocks End turn** (an alert that needs an answer),
**season report only**, **silent**; defaults put only significant kinds in the alert row and roughly half the minor
kinds silent; a "hidden alerts" list restores anything muted; notices fire only when they concern the player.

**When to use**: every notice kind. **When NOT to use**: blocking events (they always block).

### Outliner
**Category**: Navigation · **Used in**: HUD Z2

**Description** (Victoria 3, CK3): the right-hand column of things the player follows.

**Specification**: tabs (Pinned, People, Sect, Places, Ongoing) plus one the player defines; a pin icon on every
person, place, item and plan; each row shows one live number (a person's attitude, a place's travel time, a quest's
seasons left); rows sort and collapse; names truncate, numbers never do; collapsible as a whole (HUD drop order).

**When to use**: things the player tracks across turns. **When NOT to use**: things they act on once.

### Map modes
**Category**: Navigation · **Used in**: HUD Z4

**Description** (EU5, Victoria 3 lenses): ways of colouring the map, each with a legend.

**Specification**: a grouped mode bar (geography, power, people, economy) with number keys; every mode has a legend
(hues and patterns, never hue alone) and hovering the map shows the value under the pointer; changing modes fades over
`motion_fast`; a mode may carry related actions as a **lens** (pick the action, then click targets), but every action
is also reachable from its panel.

**When to use**: questions about the whole map. **When NOT to use**: one place's detail (its panel).

### Top bar resource
**Category**: Data display · **Used in**: HUD Z1

**Description** (CK3, Victoria 3): the few resources that matter every turn.

**Specification**: the value, its change since last season (+ / −), and a [Breakdown](#breakdown) of income and
spending on hover; a resource stays hidden until it matters (Victoria 3's convoys); rarely used stats live in panels,
not the bar.

**When to use**: per-turn resources. **When NOT to use**: rare stats.

### Searchable list
**Category**: Data display · **Used in**: the Places panel; inventory, the known list, trade, a sect roster

**Description** (Victoria 3 lists, PoE stash search): a list the player can search, sort, group and filter.

**Specification**: a search box (Ctrl+F focuses it; IME-safe for Vietnamese typing, so single-letter hotkeys are off
while it is focused); search **highlights matches in place** (outline them, dim the rest) rather than only removing
rows; sortable columns; group-by; **filter chips** for the common cuts (realm ≥ X, element, met / not met) that persist
per screen; structured filters instead of a query language; Up / Down and Enter navigate.

**When to use**: any list longer than a screen. **When NOT to use**: short fixed lists.

### Item tooltip
**Category**: Overlay · **Used in**: inventory, trade, loot, gear in the person window

**Description** (Path of Exile): an item's tooltip, structured and comparable.

**Specification**: the header shows the name in its **rarity colour plus the rarity word**; sections divided by
separators: kind and base properties, requirements, implicit lines, crafted lines (one per affix), special effects,
then flavour (muted); a stat changed by the item's own lines is tinted; **comparison first**: hovering an item shows the
equipped one beside it, with per-stat deltas (▲ / ▼ and the number) above the full text; **Alt** shows the advanced
view (each line's tier, roll range, prefix or suffix); **Ctrl+C** copies the item as text. Keyword explanations live in
[link styles](#link-styles), not inline prose.

**When to use**: every item. **When NOT to use**: non-items (use the plain tooltip).

### Tree view
**Category**: Data display · **Used in**: Đạo Đồ; the diagram editor

**Description** (Path of Exile, Path of Building): a large graph of nodes the player allocates.

**Specification**: zoom (wheel, + / −) and pan (drag, arrows); **search** makes matching nodes pulse at every zoom
level, Enter cycles through them and centres each; **hovering an unallocated node previews the shortest path**, its
point cost and the net stat change of the whole path; allocations are **pending** until Apply (a running point counter,
Reset to undo all); node classes (small, notable, keystone) differ by size and frame, not colour only; refunds show
their price and follow the tree's rule (leaf first); a node's scope or set shows by a mark as well as colour.

**When to use**: any allocatable graph. **When NOT to use**: small fixed loadouts (use a row).

### Tab bar
**Category**: Navigation · **Used in**: the character sheet (`CharacterWindow._build_tabs`)

**Description**: the pages of one window as a row of toggle buttons in the sticky header, so the player's place and the
key numbers stay in view while the page changes.

**Specification**: one toggle button per tab, the open one pressed; its accessible name adds ", selected"; Ctrl+Tab and
Ctrl+Shift+Tab step through the tabs and wrap; the window remembers its tab (see Side panel with history). A tab that
does not apply (Interact on the player's own sheet) is left out, not greyed. Gamepad: LT / RT step the tabs on the
character sheet (decided 2026-11-24, UI owner; not built yet, part of the gamepad pass). Not built: tablist / tab /
tabpanel roles for screen readers (accessibility pass).

**When to use**: a window with several pages of equal weight. **When NOT to use**: sections of one page (use
[Section jumps](#section-jumps)); more than two levels (see the rules above).

### Wood ground and parchment inset
**Category**: Layout · **Used in**: every illustrated window (`Illustrated.ground`, `Illustrated.inset`,
`GameWindow.section_in`)

**Description**: the illustrated windows' look as a layout pattern: a dark wood ground holding parchment insets, each
under a small brass heading.

**Specification**: `Illustrated.ground` is the one wood column of the window body; each section is a parchment inset
with a brass-edged frame and an upper-case heading with a thin brass rule. `GameWindow.section_in` makes the inset a
[Section jumps](#section-jumps) target: its heading is a focus stop with an accessible name and is registered under
the section's key. Text on the parchment uses the ink colours, text on the wood uses the bone colours; colours come from
`Illustrated` and the Rosewood theme, never set in a window. Every piece is a plain Control, so the window keeps its own
tooltips, focus and accessibility names.

**When to use**: any window that groups facts into sections. **When NOT to use**: the HUD and the map (they keep the
wood plate buttons and bubbles).

### Hero painting
**Category**: Data display · **Used in**: the sect window, the abode screen, the game menu (`Illustrated.framed` with a
name cartouche or plaque)

**Description**: a framed place painting across the top of a window, with the name of the place on a cartouche.

**Specification**: `Illustrated.framed(texture, size, fallback)` crops the picture to cover a brass frame; the name
sits on a plaque (`Illustrated.plaque`) over or under it. A missing painting shows `PlaceholderArt` (never a stand-in
that looks finished), with the fallback word if given. The painting is decorative: the window title, the plaque and the
text lines carry the same facts, so a screen reader skips it (marking the abode's hero decorative is not built yet).
No text is drawn over the picture itself, so it cannot lower a label's contrast.

**When to use**: a window about one place or sect. **When NOT to use**: a person (use the
[portrait frame](#portrait-frame-and-round-medallion)).

### Portrait frame and round medallion
**Category**: Data display · **Used in**: the character sheet, sect window (head and notables), relationships page and
rankings (`Illustrated.framed`, `Illustrated.medallion`, `PortraitPicker`)

**Description**: a person's face: a tall framed portrait where it is the subject, a round medallion in lists.

**Specification**: `PortraitPicker.texture_for` returns the portrait; the frame is `Illustrated.framed`, the medallion a
round mask with a brass ring at the size the list wants (36 to 96 px), cropped to the head and shoulders of a tall
portrait. A dead person's medallion is faded and the row says "died" in words. A missing portrait shows `PlaceholderArt`
inside the frame or the ring with the tooltip "PLACEHOLDER · No portrait yet"; ordinary NPCs' type portraits are the
design and are not "missing". The portrait carries no information the text does not (a screen reader skips it; marking
medallions decorative is not built yet).

**When to use**: any person shown with a name. **When NOT to use**: places and items.

### Icon tile
**Category**: Data display · **Used in**: the character sheet, sect window, abode screen (`Illustrated.tile`)

**Description**: one figure at a glance: an icon, a small label, a big value and an optional note.

**Specification**: a parchment tile in a grid (`Illustrated.grid`); the icon is optional; the value is in the heading
face and trims with an ellipsis rather than wrapping; the tile is a focus stop with the accessible name "label value
note"; its tooltip (when it has one) names the rule behind the number, as a [Breakdown](#breakdown) would. The figure
is a number or a short word, never the only place a fact lives (the text line says it too). Tooltips on the abode's
four tiles are not built yet.

**When to use**: the three to six numbers that sum a thing up. **When NOT to use**: a number with a long explanation
(use a [Breakdown](#breakdown)).

### Slot card
**Category**: Data display · **Used in**: the character sheet (`Illustrated.card`)

**Description**: one loadout slot: an icon in a recessed frame, the slot's kind, its occupant's name and an optional
line under it.

**Specification**: a parchment card with a 72 px icon frame (a card with no icon shows the bare recessed frame), the kind in the small label face and the name wrapped under it; a focus stop with the accessible name
"kind: title, sub". Changing the slot goes through the window's chooser, never a drag.

**When to use**: a fixed set of slots. **When NOT to use**: a long list (use a [searchable list](#searchable-list)).

### Trait icon
**Category**: Data display · **Used in**: the character sheet (`Illustrated.trait_chip`)

**Description** (CK3's trait row): a trait is its painted medallion alone; the information is on hover.

**Specification**: the icon (40 px by default) is a focus stop with the accessible name "name (Vietnamese), group". The
[tooltip](#nested-lockable-tooltip) (hover, or Q on focus) shows the name with the Vietnamese, the group, the stat
lines and what the trait leans a person to; its wiki key opens the trait's wiki entry. No label is printed beside the
icon, so a trait row stays one line. Not built: a missing trait icon file shows an empty chip, not `PlaceholderArt`
(`Illustrated.trait_chip` loads it with `Illustrated.tex`, which returns null).

**When to use**: a row of traits. **When NOT to use**: a stat the player must read without hovering.

### Person card
**Category**: Data display · **Used in**: the relationships page (`RelationshipsWindow._card`)

**Description**: one person among many: medallion, name link, who they are, how they feel and their ties as badges.

**Specification**: a parchment tile in a two-column grid. The round medallion (64 px for ties) sits left; right of it
the name link (opens the character sheet; accessible name "Open <name>"), the "realm · sect · at place" line, the mood
word with its number, and a wrapping row of badges. Badges are pills with bone text at 16 px on a tint by tie family
(pinned brass, feud cinnabar, enmity dark red, soft ties teal, debt amber), always with their words. A dead person
carries "†" and "died". Focus order is row-major (Godot's default); both the card and its name link are focus stops.

**When to use**: a list of people with a state each. **When NOT to use**: a plain roster (use a
[searchable list](#searchable-list) row).

### Podium
**Category**: Data display · **Used in**: rankings (`RankingsWindow._podium`)

**Description**: the top three of a list as cards over the table.

**Specification**: three parchment cards in the order 2nd, 1st, 3rd, the first larger (96 px medallion against 76 px),
each with the medallion, an ordinal plaque, the name link, "sect · stage" and the power number ("~" when provisional).
The cards are not focus stops (`focus_mode` NONE): the name link is. Ranks 1–3 are also in the table, so a screen reader
meets them twice (accepted for now). Hidden when the layout is compact (1280×720), while searching, and when the list
has fewer than three rows.

**When to use**: a ranked list where the top matters. **When NOT to use**: a list the player scans for a name.

### Rarity-framed item tile
**Category**: Data display · **Used in**: inventory (`InventoryWindow._item_row`)

**Description** (Path of Exile): the item's painted icon in a frame coloured by its rarity, with a count badge.

**Specification**: a 56 px tile on the near-black ground, framed in the rarity colour (`LinkStyle`), with the icon
centred; a stack shows a "×N" badge at 16 px in the bottom corner, outlined for legibility on any icon; one item shows
none. The colour is never the only carrier of rarity: the row's text and accessible name carry the rarity word. A
missing icon shows `PlaceholderArt` with the tooltip "PLACEHOLDER". The tile is decorative for a screen reader.

**When to use**: any item row. **When NOT to use**: a non-item (use an [icon tile](#icon-tile)).

### Node card
**Category**: Overlay · **Used in**: the Đạo Đồ (`DaoDoScreen` hover card)

**Description** (Path of Exile's node tooltip): a floating card about the node under the pointer or the keyboard
selection.

**Specification**: mouse-transparent (it never takes a click, so it cannot block the canvas); it shows the node's
painting, name in its class colour, the class and land in words, the stats, any capability or Effect, the price, then
one status line. It follows the pointer (22 px right, 18 px below), or sits at the selected node when the selection moves
by keyboard; it flips to the left of the pointer at the right edge and moves up at the bottom edge, and it clamps to
the canvas. Every line is at least 16 px. Screen reader: only the card's accessible name (the node's title) is set; a
live announcement of the stats is not built yet.

**When to use**: a dense canvas where a node needs a full read on hover. **When NOT to use**: a normal list
(use a [tooltip](#nested-lockable-tooltip)).

### Automation toggle
**Category**: Input · **Used in**: herb fields, abode upkeep, sect chores (to be specced)

**Description** (EU5): let the game run a routine the player does not want to manage.

**Specification**: a toggle per area with a short description of what the game will do; optional partial delegation
(a share or a limit); everything it did appears in the season report; the area stays inspectable and can be taken back
at any time; automation never makes a choice the player would call big (no bonds, no breakthroughs, no spending above
a set limit).

**When to use**: repetitive chores. **When NOT to use**: anything a build depends on.


---

## Gaps & Patterns Needed

- **Settings controls** (sliders, toggles, key rebinding capture with conflict warnings): needed for the game menu and
  settings spec.
- **Radial menu** (the HUD's gamepad radial for map modes and window buttons): specified in the HUD only by intent.
- **Drag and drop** (placing arts in a diagram, equipping gear): needed by the diagram editor and inventory; must have a
  keyboard and pad equivalent (pick up, move, drop).
- **Wiki page**: the destination of "Open in wiki" (CK3 encyclopedia, Victoria 3's "show me in the UI" button).
- **Graphs over time** (Victoria 3): sparklines are in the Breakdown; full history charts wait for a ledger screen.

## Not to Copy

Research findings (`design/research/ui-patterns-paradox-poe-2026-11-22.md`): unlimited or unpredictable tooltip depth;
icon-only rows; information icons that look like buttons, or tiny vital buttons; sub-sub-screens; alert floods and
dismissals that return; two calculations for one verdict; undiscoverable power features; text-wall tooltips; "ship now,
fix the UI later"; real-time pause rules (here they become End turn rules); any game's art, icons or frames.

## Open Questions

1. The visual look of every pattern (frames, colours, fonts with Vietnamese diacritics) waits on the art bible and the
   user's choice of overall style.
2. Whether toasts and the reply strip should merge into one feedback pattern once more panels exist.
3. ~~The list-with-selection pattern~~ written in v2 as [Searchable list](#searchable-list).
4. Some research rests on snippets or general knowledge (EU5's official UI diaries, CK3's acceptance internals, PoE's
   comparison and crafting bench): check them in the games before a screen spec depends on them.
5. **Spec follow-ups from v2** (applied as each screen is next touched): the person window's verbs gain levers and
   decline consequences; the fight log gains folded repeats, actor filters and a result-and-reasons summary; the HUD's
   alert row gains warning and opportunity groups and "mute this kind"; tooltips gain the breadcrumb, corridor and lock
   bar (ADR-0005 implementation).
