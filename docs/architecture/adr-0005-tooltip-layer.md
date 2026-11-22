# ADR-0005: Tooltip Layer

## Status
Proposed. Conditions for Accepted: a screen-reader check of an open tooltip, and a release-export run of the tooltip
demo steps (Validation Criteria).

## Date
2026-11-22

## Last Verified
2026-11-22 (against Godot 4.7.1 in the greybox; see Engine Compatibility for what the engine reference does not cover)

## Decision Makers
The user (the tooltip rules in `design/ux/hud.md`, approved 2026-11-22; "short ADR now" and "revise the ADR and make
the small fixes", 2026-11-22), with the assistant drafting; reviewed by godot-specialist (no blocking issues) and
technical-director (TD-ADR: CONCERNS, all addressed in this revision).

## Summary
The HUD's tooltips must nest, lock, be hovered into and be reachable from the keyboard and a screen reader, which
Godot's built-in tooltip cannot do. The game draws its own tooltip layer: a pure rules object (`TooltipChain`, driven by
an injected clock) and a thin view (`TooltipLayer`), with every source carrying its tip as metadata instead of
`tooltip_text`.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (installed 4.7.1) |
| **Domain** | UI |
| **Layer** | Presentation |
| **Knowledge Risk** | HIGH (4.5–4.7 are past the model's training cutoff; VERSION.md) |
| **References Consulted** | `docs/engine-reference/godot/VERSION.md`, `modules/ui.md`, `breaking-changes.md`, `deprecated-apis.md` |
| **Post-Cutoff APIs Used** | 4.6 dual focus (`modules/ui.md`: hover is separate from keyboard focus). 4.5+ AccessKit `Control.accessibility_name` / `accessibility_description`: the reference names AccessKit support (`breaking-changes.md`) but not these properties, so they are NOT SOURCEABLE by name; checked present on 4.7.1 with `ClassDB`. |
| **Verification Required** | (1) `Viewport.gui_get_hovered_control()`: NOT SOURCEABLE; present on 4.7.1 (`ClassDB.class_has_method`). (2) Hover follows the real OS cursor, not motion events pushed with `Viewport.push_input`: NOT SOURCEABLE; measured in the greybox 2026-11-22. (3) `gui_get_focus_owner()` returns the keyboard focus under 4.6 dual focus: NOT SOURCEABLE; the demo's Q / Tab / Esc focus checks pass on 4.7.1. (4) `_input` runs before GUI controls get a click, so `set_input_as_handled()` there consumes it: NOT SOURCEABLE; the demo's outside-click check passes. (5) The 4.5 recursive mouse-filter behaviour (`modules/ui.md`) is not switched on for the layer, whose IGNORE must not reach its STOP panels: the controlling property is not named in the reference (NOT SOURCEABLE); the panels take clicks in the demo. (6) AccessKit reads `LinkButton`s in an `HFlowContainer` and announces an opened tooltip: NOT SOURCEABLE, not checked (condition for Accepted). If announcements use `accessibility_live`, its 4.7 type is `AccessibilityServer.AccessibilityLiveMode` (`deprecated-apis.md`). (7) Release export: not checked (condition for Accepted). |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | None Accepted. Every state-reading tip builds on Required ADR #2 (the `GameSession` facade and frontend rule, `docs/architecture/architecture.md`), which is in the "must decide before the next work that builds on it" tier and is not written; the greybox's tips run under a named exemption until it is (Implementation Guidelines). |
| **Enables** | Every later screen's tooltips (person, sect, trade, abode windows; the Đạo Đồ screen; the in-game wiki's links) |
| **Blocks** | None (the layer is built; screens that add tooltips use it) |
| **Ordering Note** | Required ADR #9 (Game UI framework, after the art bible) references this ADR rather than absorbing it. Fonts and the art bible's look come later; the layer takes its look from the theme. |

## Context

### Problem Statement
The HUD is played like a grand-strategy map game: almost every number and word explains itself in a tooltip, and a
highlighted word inside a tooltip opens its own (user, 2026-11-21; `design/ux/hud.md` HUD Philosophy rule 4 and
Tooltips). Godot's built-in tooltip is a short-lived popup: it closes when the pointer leaves the source, so the
player cannot move into it, lock it, click a word in it or open a second level, and the keyboard cannot reach it. The
greybox needed a decision before any screen grew its own tooltip code.

### Constraints
- The rules are many and timed (open delay, close grace, lock by timer / middle click / click, one chain, depth 5,
  Esc one level at a time) and the spec's acceptance criteria state them in frames and simulated minutes, so they must
  be testable without a window or a real clock.
- UI never owns or changes game state (`.claude/rules/ui-code.md`); tooltip content reads state only.
- Text is localised (`tr()`), scales with the UI scale rule, and the tooltip detail floor is 14 px
  (`design/accessibility-requirements.md`).
- Keyboard and gamepad input must both work (`.claude/rules/ui-code.md`).
- The engine reference does not cover hover tracking or input order (Engine Compatibility).

### Requirements
- Nested, lockable, hoverable tooltips with the timings as player settings (`tooltip_delay`, `tooltip_lock`,
  `tooltip_lock_delay`, `tooltip_close_grace`) and `tooltip_depth_max` 5, then the wiki.
- Keyboard: Q / F2 opens the focused element's tooltip locked with focus in it; Tab wraps; Enter opens a word; Esc
  closes the top level and returns focus.
- Screen reader: every highlighted word is a real focusable control, every tooltip has an "Open in wiki" button.
- A click outside a locked chain closes it and does not reach what is under it; an unlocked tooltip never locks on a
  click that belongs to a button.
- One mechanism for every tooltip in the game, so no second tooltip ever shows beside it.

## Decision

The game has its own tooltip layer, in two parts.

**`TooltipChain`** (`src/ui/tooltip/tooltip_chain.gd`, `RefCounted`, no nodes, no clock) holds every rule. Each frame
the view calls `advance(dt, hit)`, where `hit` says what the pointer is over: the topmost open level and the word in
it, or a source and its content. Clicks go through `click(button, hit, source_clickable)`, which returns whether the
press is consumed; words through `press_word(level, key, keyboard)`, which returns `"opened"` or `"wiki"`. Keyboard
opens are `open_keyboard(source, content)`; Esc is `close_top()`; season changes and windows are `close_all()`; a freed
source is `source_gone(id)`. A level is `{key, source, content, locked, keyboard, rest, off}`; locking a level locks
every level below it; a keyboard-opened level is locked and ignores the pointer.

**`TooltipLayer`** (`src/ui/tooltip/tooltip_layer.gd`, a full-rect `Control` added as the screen's last child, mouse
filter IGNORE) feeds the chain and draws it.
- **Sources** carry their tip as metadata, set with `TooltipLayer.set_tip(control, tip)`. It clears the control's
  `tooltip_text` and, if the control's mouse filter is IGNORE, sets it to PASS so the engine can report it as hovered
  (PASS still passes the click to the parent, so no click changes owner).
- **Hover** comes from the engine: `Viewport.gui_get_hovered_control()`, then up to the nearest control with a tip, so
  z-order, covering windows and mouse filters behave exactly as they do for clicks. The open levels are hit-tested by
  rectangle (the grace needs it).
- **Clicks** are seen in the layer's `_input`, which runs before GUI controls get them: a click outside a locked chain
  closes it and calls `set_input_as_handled()`, so it does not reach what is under it; any other click passes on.
- **Busy guard:** the layer has `busy: Callable`; while it returns true, the layer calls no tip Callable (hovering and
  the tooltip action open nothing new). The screen sets it to its "a session job is running" check.
- **Keys:** the input action `tooltip_open` (default Q and F2 as physical keys, added at start-up unless already
  defined) opens the focused element's tooltip; it can be rebound through the InputMap.
- **Focus:** whenever levels close by any route (Esc, outside click, grace, source gone, `close_all`) and keyboard
  focus was inside one, focus goes to where the lowest closing level came from (its parent's word or its source), else
  to `fallback_focus` (End turn).
- **Views:** each level is a `PanelContainer` holding labels, an `HFlowContainer` of word labels and flat underlined
  `LinkButton`s (one per highlighted word), the Breakdown lines at the 14 px detail size, and an "Open in wiki"
  button; the first and last focusable controls wrap Tab. Levels are placed beside what they describe (the root beside
  its source, each child beside its parent), inside `edge_margin`.
- **Coordinates:** positions are in the root canvas's layout coordinates. This holds because the screen sets the
  window's stretch at run time (`canvas_items` mode, `expand` aspect, content scale size = the window size, factor =
  `UiScale.factor`); `project.godot` sets no stretch keys.

Content is a Dictionary `{id, title, fact, summary, body, lines, wiki}`; `body` is plain text segments and
`{text, key}` highlighted words. Authored text marks words as `[[key|shown words]]` (`TooltipLayer.parse_body`).
Concept entries live in `assets/data/ui_terms.json`; the knobs in `assets/data/ui_hud.json` `"tooltips"`.

Esc is not handled by the layer alone: the screen asks `EscRouter.pick(state)` (`src/ui/hud/esc_router.gd`, pure),
which puts "focus inside a tooltip" before every window and "a tooltip is open" third in the ranked list (hud.md
Platform Adaptation), and then calls `close_top()`.

### Architecture Diagram
```
 input events ─┐                         ┌─> TooltipLayer views (PanelContainer per level)
               v                         │     labels · LinkButton words · Breakdown · Open in wiki
 Viewport.gui_get_hovered_control()      │
        │  (nearest control with "tip" metadata; skipped while busy())
        v                                │
 TooltipLayer._hit() ──hit──> TooltipChain.advance(dt, hit) ──version──┘
        │                       click() / press_word() / open_keyboard()   <── _input (clicks, tooltip_open)
        │                       close_top() <── EscRouter.pick() <── screen Esc
        └─ content: tip String | Dictionary | Callable(local_pos) -> String | Dictionary   (read-only)
```

### Key Interfaces
```gdscript
# Sources
static func TooltipLayer.set_tip(c: Control, tip: Variant) -> void   # String | Dictionary | Callable(Vector2) -> Variant
# Vector2.INF is passed to a Callable for a keyboard open (describe the focused or selected item).
const TooltipLayer.ACTION := &"tooltip_open"                          # InputMap action; Q and F2 by default

# Content: {id?, title, fact?, summary?, body?: Array[String | {text, key}], lines?: Array, wiki?: String}
static func TooltipLayer.parse_body(text: String) -> Array        # "[[key|shown]]" -> {key, text}
static func TooltipLayer.term_content(terms: Dictionary, key: String) -> Dictionary

# Layer
signal wiki_requested(key: String)
var chain: TooltipChain                 # chain.resolve: Callable(key) -> Dictionary for nested words
var busy: Callable                      # -> bool; true = call no tip Callable
var fallback_focus: Callable            # -> Control focused when a closing level held focus and its origin is gone
func configure(cfg: Dictionary) -> void # ui_hud.json "tooltips"; applies at once
func close_all() -> void
func close_top() -> void
func owns(c: Control) -> bool
func is_open() -> bool

# Rules
func TooltipChain.advance(dt: float, hit: Dictionary) -> void
func TooltipChain.click(button: int, hit: Dictionary, source_clickable: bool) -> bool   # true = consumed
func TooltipChain.press_word(level: int, key: String, keyboard: bool) -> String         # "opened" | "wiki" | ""
func TooltipChain.open_keyboard(source: String, content: Dictionary) -> void

# Esc
static func EscRouter.pick(state: Dictionary) -> String
```

### Implementation Guidelines
- Every tooltip in the game **must** go through `TooltipLayer.set_tip`. Game code **must never** use a built-in
  tooltip API: a non-empty `Control.tooltip_text`, `ItemList` / `PopupMenu` `set_item_tooltip`,
  `TabBar` / `TabContainer` `set_tab_tooltip`, `TreeItem.set_tooltip_text`, or `RichTextLabel.push_meta`'s tooltip
  argument. `tests/integration/ui/ui_no_builtin_tooltips_test.gd` scans `src/` for them. Item lists **must** call
  `set_item_tooltip_enabled(i, false)` and give the list a Callable tip.
- Tip Callables **must** be read-only. They **must** read game state through `StateSnapshot` / `Advisor` and
  `GameSession` read methods, the shipped frontend rule (ADR-0006). The greybox exemption recorded here ended on
  2026-11-22: the greybox's tips now read through `StateSnapshot` and `GameQuery`, and
  `tests/integration/ui/ui_frontend_rule_test.gd` checks it.
- The screen **must** set `TooltipLayer.busy` to its "a session job is running" check, so no tip reads state while the
  session works on its thread. A tip **may** also check it itself (defence in depth).
- A tip Callable **must** build its content within 1 ms; a tip that cannot **must** cache and rebuild only when what
  it shows changes.
- A tip that describes several things of one control (a map place, a list row) **must** give each its own `id`, or
  its title is used as the id; one id means one source.
- Rules **must** stay in `TooltipChain`, driven by `dt`, never by `Time` or frames, so they stay unit-testable.
- Highlighted words **must** be focusable controls (`LinkButton`), never `RichTextLabel` meta links.
- Esc **must** go through `EscRouter`; nothing else closes a tooltip on Esc.
- Season changes and windows opening over the chain **must** call `close_all()`.
- A screen that adds engine popups (`OptionButton`, `PopupMenu`, any embedded `Window`) **must** first move the layer
  onto a high `CanvasLayer` or give the popup its own tooltips through the layer, because embedded windows draw above
  the root canvas and the layer cannot hover them.
- The tooltip key **must** be read through the `tooltip_open` action, never a hard-coded keycode.

## Alternatives Considered

### Alternative 1: Godot's tooltip with `_make_custom_tooltip`
- **Description**: Keep `tooltip_text` and override `_make_custom_tooltip()` on sources to return a richer Control.
- **Pros**: Engine-native timing and placement; no layer node; little code.
- **Cons**: The popup still closes when the pointer leaves the source, cannot be hovered into, locked, nested or
  focused, and the delay is one project setting rather than a player setting with a lock mode.
- **Rejection Reason**: It cannot meet the spec's core rules (hover into, lock, nest, keyboard).

### Alternative 2: Nested words as `RichTextLabel` meta links
- **Description**: Draw each tooltip body as a `RichTextLabel` with `[url]` meta for highlighted words, opening the
  next level on `meta_hover_started` / `meta_clicked`.
- **Pros**: Natural text flow and wrapping; one node per body; the 4.4 `push_meta` tooltip parameter.
- **Cons**: Meta links are not focusable controls, so Tab, Enter and screen readers cannot reach them; whether
  AccessKit reads them is unknown (hud.md Open Questions).
- **Rejection Reason**: It fails the keyboard and screen-reader requirements, which the accessibility tier (Standard)
  makes mandatory.

### Alternative 3: Pointer from pushed input events and rectangle hit tests for sources
- **Description**: Track the pointer only from `InputEventMouseMotion` and find sources by testing every tip control's
  rectangle, so synthetic input could drive hover.
- **Pros**: Fully scriptable without moving the real cursor.
- **Cons**: Re-implements the GUI's z-order, mouse filters and covering windows; diverges from what the engine hovers
  and clicks; measured unnecessary once the demo warps the cursor.
- **Rejection Reason**: The engine's own hover is the truth the player sees; matching it beats re-deriving it.

## Consequences

### Positive
- One tooltip mechanism for the whole game, guarded by a scan test; the rules are unit-tested
  (`tests/unit/ui/ui_tooltip_chain_test.gd`, 15 cases) against the spec's numbers, with no window.
- Keyboard paths (the `tooltip_open` action, Tab, Enter, Esc with focus return) are built and checked by real input in
  the demo. The screen-reader path is built (focusable words, accessible names, "Open in wiki") but **not yet checked
  with a screen reader**.
- Settings (delay, lock mode, grace) apply at once through `configure`.
- Content is data: authored terms in `ui_terms.json`, Breakdowns straight from the rules (`Breakdown.lines()`).

### Negative
- The game owns placement, focus wrapping and hit testing that Godot would otherwise provide.
- Word-by-word labels in a flow container are heavier than one `RichTextLabel` and wrap slightly less naturally.
- Callable tips run every frame while hovered (within the 1 ms rule).
- Panels are `MOUSE_FILTER_STOP` and focusable: a tooltip placed over a button takes that button's click, and a
  click on a panel can take focus from a text field. Placement keeps tooltips beside what they describe, but not off
  every other control.
- Scripted hover moves the user's real cursor (Validation).
- Gamepad: Y to open, the d-pad between words, B to close (hud.md Tooltips) are **deferred** to the gamepad pass, with
  the rest of the HUD's gamepad layer; until then a gamepad has no tooltip path.

## Risks
- **AccessKit may not announce a flow of labels and link buttons as one text.** Mitigation: the panel carries an
  accessible name and description; a screen-reader check is a condition for Accepted.
- **No room at a high UI scale** (deep chains at 150 %). Mitigation: the spec's title strips (older levels shrink),
  deferred; placement already flips sides and stays inside `edge_margin`.
- **Hover or input-order behaviour changes in a later 4.x.** Mitigation: the demo's real-input checks (hover, nested,
  lock, outside click, focus return) catch it on the next run.
- **Engine popups added later draw above the layer.** Mitigation: the CanvasLayer guideline above.
- **A per-frame cost creeps in:** `words()` walks the level's children each frame in the hit test and placement, and an
  autowrapped label's first-frame minimum size can be stale for one frame. Mitigation: cache the word list per view if
  a profile shows it; no flicker seen in the shots.
- **A tip reading the session while the season resolves on its thread.** Mitigation: the layer-level busy guard.

## GDD Requirements Addressed

| GDD System | Requirement | How This ADR Addresses It |
|------------|-------------|--------------------------|
| `design/ux/hud.md` (Game UI #37) | Tooltips: one chain; open after `tooltip_delay`; lock by timer, middle click or click; close grace; depth 5 then the wiki; Esc closes only the top | `TooltipChain` rules with injected `dt`; 15 unit tests; demo real-input checks |
| `design/ux/hud.md` | HUD Philosophy rule 4: highlighted words open their own tooltip; Content: name, key fact, summary, then the Breakdown | Content Dictionary; `[[key|text]]` words; `lines` from `Breakdown.lines()` |
| `design/ux/hud.md` | Tooltips, Keyboard: Q (or F2) opens the focused element's tooltip locked; Tab wraps; Esc returns focus | The `tooltip_open` action; Tab wrap; focus returned on every close |
| `design/ux/hud.md` | Platform Adaptation: Esc acts on the focused window first, then the ranked list (tooltip third) | `EscRouter.pick`, 9 unit tests |
| `design/accessibility-requirements.md` | Tooltip timing settings; 14 px tooltip detail; screen-reader reachable content | Settings via `configure`; detail labels at 14 px; focusable `LinkButton` words and "Open in wiki" (screen-reader check pending) |
| `docs/architecture/architecture.md` TR-ui-001 | Accessibility in the 2D UI | Keyboard path built and checked; screen-reader path built, check pending |

## Performance Implications
- **CPU**: One `advance` and one hit test per frame; while hovering a Callable source, its content is built each frame,
  within 1 ms (Implementation Guidelines). Views are rebuilt only when the chain's version changes.
- **Memory**: At most 5 panels of a few dozen controls.
- **Load Time**: None (terms are a small JSON file loaded with the rest of `assets/data`).
- **Network**: None.

## Migration Plan
Done in greybox slice 3 (`bbe01751`): every `tooltip_text` in `src/ui/` was moved to `TooltipLayer.set_tip`, and the
Places list's item tooltips to a Callable tip. The ADR review fixes (layer busy guard, focus return on every close,
the `tooltip_open` action, the scan test) follow in the commit that adds this ADR. The greybox tips move to the read
API of Required ADR #2 when it is written.

## Validation Criteria
- `tests/unit/ui/ui_tooltip_chain_test.gd` (15), `ui_tooltip_layer_test.gd` (4), `ui_esc_router_test.gd` (9) and
  `tests/integration/ui/ui_no_builtin_tooltips_test.gd` pass; the scan was seen failing on a planted `tooltip_text`.
- The greybox demo's tooltip checks pass at 1280×720 and 1920×1080 (`production/qa/evidence/hud-greybox/README.md`):
  hover, a nested word, a middle-click lock, a consumed outside click, Q / Enter / Tab / Esc focus, depth 5 to the
  wiki, and a Places row by hover and by Q. Demo procedure: hover steps move the real cursor (`Input.warp_mouse`) as
  well as pushing the motion event, and wait in seconds, not frames, because hover follows the real cursor and the
  delay is in seconds.
- A nested tooltip at 150 % UI scale is placed correctly (`scaling/1920x1080-scale150-tooltip.png`).
- **Conditions for Accepted:** a screen-reader check (NVDA or Narrator) that an opened tooltip and its words are read;
  a release-export run of the demo's tooltip steps.

## Related
- `design/ux/hud.md` (Tooltips, Platform Adaptation, Open Questions), `design/accessibility-requirements.md`
- `docs/architecture/architecture.md` Required ADRs #2 and #9
- `production/qa/evidence/hud-greybox/README.md`
