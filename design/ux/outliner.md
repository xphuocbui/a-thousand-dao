# UX Spec: Outliner

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 4 advisory: applied 2026-11-24); written 2026-11-24
> night by Claude under the UI delegation (memory ui-design-delegated)
> **Note 2026-11-24**: the illustrated rebuild (portraits, parchment insets, icon tiles) covers the character sheet and
> person window only. The outliner is deliberately still plain: flat buttons and labels on the wood plate, no
> portraits or icons. Round 2 changes below are corrections to match the built code, not a restyle.
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of the earlier person spec)
> **Sources**: `design/ux/hud.md` (Z2; element 6; States "Nothing to show"; Visual Budget: the outliner collapses first;
> Tuning Knobs: Outliner shown / collapsed; the pin ACs), `design/ux/character-sheet.md` (the Pin / Unpin button on
> another person's Interact tab; `person.md` is superseded by it), `interaction-patterns.md` (Outliner)
> **Patterns used**: Outliner (**a variant**: one list grouped People / Places / Ongoing instead of the pattern's tabs, no
> sorting (pins keep their pin order), names wrap rather than truncate in the 144 px column; the row's live value is
> the band word or the travel time, the number in the tooltip), Link styles, Nested lockable tooltip. Flagged for the
> pattern library.

---

## Purpose & Player Need

"Where are the people and places I follow, right now?" A short list under the window buttons: the people the player
pinned (where they are now, attitude), the player's home and sect seat (travel time), and what is ongoing (an event
waiting). One click opens the person or place. It answers at a glance what would otherwise need a window each.

## Player Context on Arrival

Always on the map screen (Z2, below the window buttons, on a wood plate), unless collapsed. Rows update at every End
turn (hud.md element 6) and also after any action or pin change (a deliberate addition: a pin should show at once).

## Navigation Position

Part of the HUD (Z2), not a window. Rows open Z6 windows (the character sheet on that person's Interact tab, the place
details) or the abode screen.

## Entry & Exit Points

| Entry | Effect |
|---|---|
| The character sheet's Pin button (action bar of another person's sheet; it reads "Unpin" while pinned) | Adds that person (Unpin removes). Past the limit the button does nothing but a toast says "The outliner is full (12 people)." |
| The outliner's × on a row | Unpins |
| The header button | Collapses / expands (a player setting) |

## Layout Specification

### ASCII Wireframe (Z2, 144 px wide, under the window buttons)

```
| Outliner ▾          |
| PEOPLE              |
|  Trần Vân           |
|   Thanh Vân · warm ×|
|  Hắc Sát † died    ×|
| PLACES              |
|  Home: Tùng Hạ Thị  |
|   here              |
|  Seat: Thanh Vân Sơn|
|   2.0 seasons away  |
| ONGOING             |
|  ! Event waiting    |
```

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| Header | Toggle | Button | "Outliner ▾" / "Outliner ▸" | Collapse / expand; the setting `outliner_open` |
| People | Pinned rows | Link + line | Name (person link style), where they are now (or "travelling", "died"), attitude band word | Click: the character sheet (Interact tab); × unpins; tooltip: realm, place, attitude number |
| Places | Home, sect seat | Link + line | "Home: <place>" and "Seat: <place>", each with "here", the travel time ("2.0 seasons away", one decimal) or "no route" | No tooltip on place rows. Click: the map centres on it and its window opens (hud.md element 6): the abode screen (home) or the place details (seat). These are automatic rows, not pins: place and quest pins are a known gap against element 6 |
| Ongoing | Rows | Text | "Event waiting: <title>" while one waits | Click: opens it |
| Empty | Text | Text | "Pin people, places or quests here" (hud.md "Nothing to show") when there are no pinned people and no event. **As built, the Home and Seat rows do not count as content**: with no pins and no event the Places rows show and the empty line shows under them. Intended for now: the Places rows are automatic, so the line still tells the player what the list is for | No |

Pin limit: `outliner_pins_max` (12) people. Past it the Pin button on the character sheet does nothing and a toast
reads "The outliner is full (12 people)." (one string, used here and in the acceptance criteria).

## States & Variants

| State | What changes |
|---|---|
| Expanded | As the wireframe |
| Collapsed | The header only. The player's setting `outliner_open` wins; the compact layout (1280×720, hud.md Visual Budget step 1) collapses it only while the setting was never changed |
| A pinned person died | "† died" until unpinned (hud.md) |
| A season resolving | Rows keep their last values; they re-read after the job |
| No sect | No Seat row |
| No event | No Ongoing row |
| Person's place unknown | "unknown" (hud.md Open Questions) |
| Pin store unreadable | The outliner starts empty; nothing else breaks |

## Interaction Map

| Input | Action |
|---|---|
| Tab / Shift+Tab, Up / Down | Rows (inside Z2's focus zone; F6 reaches Z2) |
| Enter / click | Open the row's window |
| × (click or Enter on it) | Unpin that person |
| Delete | Unpin the person **only while the name button has focus** (as built); on the × or the sub-label it does nothing |
| Q | The tooltip of a person row (Nested lockable tooltip, every lock mode); place rows have none |
| Esc | Leaves the outliner's focus zone (nothing to close) |

Not built yet: moving focus after an unpin. The rows are rebuilt at each refresh, so as built focus is lost, not
moved to the next row (Open Question 4). A gamepad X-to-unpin is also not built in the panel (Open Question 5).

## Data Requirements

`GameQuery.outliner(s, pins)` with the pinned ids: {people: [{id, name, place, travelling, alive, band}], home: {id,
name, here, seasons}, seat: {id, name, here, seasons} or {}, event: {title} or {}}; a copy, changes nothing. **Pins**
are kept UI-side in `user://outliner_pins.cfg` during play, keyed by the world seed and the player's id, and a save
carries them in its `frontend` block (ADR-0007, user decision 2026-11-24 "Save them"): loading restores the pins as they
were saved; an older save without the block leaves them as they are. Test runs keep them in memory.

## Events Fired

`person_requested(id)`, `place_requested(id)`, `abode_requested`, `event_requested`, `unpin_requested(id)`.

## Transitions & Animations

None.

## Input Method Completeness Checklist

- [x] Keyboard: rows and × reachable; × and Delete (on the name button) unpin
- [x] Mouse: everything clickable
- [ ] Gamepad (Partial): d-pad inside Z2 and A opens, through the buttons' own focus; X unpins is not built
- [x] No hover-only information: place and band in the row

## Accessibility

Text at the 16 px floor (HUD text; the column wraps names and places at 16 px); "died" and the event mark are words;
rows read "Trần Vân, at Thanh Vân, warm"; place rows read "Home: Tùng Hạ Thị, here"; × buttons read "Unpin Trần
Vân"; the header reads "Outliner, expanded" / "Outliner, collapsed"; the focus ring is 3:1; a pinned person's
death reaches the player through the alert row and the season summary (the outliner itself does not announce).
Text contrast on the wood plate (`WoodLabel`, `WoodRowLabel`) has no stated ratio yet (Open Question 6).

## Localization Considerations

Names wrap within the 144 px column (no limit: wrapping holds 40 % longer text); numbers follow the language.

## Acceptance Criteria

- [ ] `[GdUnit]` A pinned person's row shows their current place and changes when they move.
- [ ] `[GdUnit]` A pinned person who dies shows "died" until unpinned.
- [ ] `[GdUnit]` With no pins and nothing ongoing the empty line shows.
- [ ] `[GdUnit]` Pins persist per world and player across a reload of the store; test runs keep them in memory.
- [ ] `[GdUnit]` Saving writes the pins into the save's `frontend` block; loading that save restores them as saved;
  an older save without the block leaves the pins as they are.
- [ ] `[GdUnit]` Collapsing hides the rows and stores the setting.
- [ ] `[GdUnit]` The pin limit (12) refuses the 13th with the toast "The outliner is full (12 people)."
- [ ] `[GdUnit]` × unpins; Delete on the name button unpins; rows have accessible names.
- [ ] `[Screenshot]` 1920×1080 with a pinned person (`production/qa/evidence/ui-windows/80-*.png`), and 1280×720 collapsed; nothing clips.

## Revision: weak-point pass (2026-11-24)

A place and its distance share one row ("here" or "N seasons", right-aligned); the empty state is one line, "Nothing
pinned yet", with how to pin in its tooltip.

## Open Questions

- Closed 2026-11-24: pins in the save file. The user decided "Save them" (ADR-0007); the save's `frontend` block owns
  them, the UI file is the live copy during play (Data Requirements). hud.md's "whether the outliner has a pin
  limit" is answered here: 12.
1. Places and quests pins: places pin from the place details once that panel is a window; quests wait for #31.
2. Should the Home and Seat rows count as content, so the empty line hides when only they show? No change decided
   (2026-11-24, UI owner; the user may overrule). Checked against `outliner_panel.gd` `show_view`: the Home and Seat
   rows do not set the `any` flag, so with no pins and no event the Places rows show and the empty line shows under
   them, as the Empty row says.
3. Should Delete work from anywhere on a person row (× and sub-label too)? As built, name button only. Code change.
4. Focus after an unpin: the rows are rebuilt, so focus is lost. Wanted: next row, or the header when none is left.
   Code change (keep the focused index across `show_view`).
5. Gamepad X to unpin is promised by hud.md's Partial gamepad support but is not in the panel. (Decided 2026-11-24,
   UI owner; the user may overrule: deferred to the gamepad pass; not built.)
6. Standard-tier numbers are missing: a contrast ratio for `WoodLabel` / `WoodRowLabel` text at 16 px on the wood plate
   (measure from the theme colours), and a timing criterion (rows refresh within X ms of an action; X needs a
   measurement on the 12-pin worst case).
