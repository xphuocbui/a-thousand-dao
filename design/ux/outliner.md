# UX Spec: Outliner

> **Status**: In Review, lean round 1 NEEDS REVISION (3 blocking, 8 advisory: applied 2026-11-24); written 2026-11-24
> night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Sources**: `design/ux/hud.md` (Z2; element 6; States "Nothing to show"; Visual Budget: the outliner collapses first;
> Tuning Knobs: Outliner shown / collapsed; the pin ACs), `design/ux/person.md` (P5 Pin), `interaction-patterns.md`
> (Outliner)
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

Part of the HUD (Z2), not a window. Rows open Z6 windows (the person window, the place details) or the abode screen.

## Entry & Exit Points

| Entry | Effect |
|---|---|
| The person window's Pin button | Adds that person (Unpin removes) |
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
|   2 seasons         |
| ONGOING             |
|  ! Event waiting    |
```

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| Header | Toggle | Button | "Outliner ▾" / "Outliner ▸" | Collapse / expand; the setting `outliner_open` |
| People | Pinned rows | Link + line | Name (person link style), where they are now (or "travelling", "died"), attitude band word | Click: the person window; × unpins; tooltip: realm, place, attitude number |
| Places | Home, sect seat | Link + line | "Home: <place>" and "Seat: <place>", each with "here" or the travel time in seasons ("no route" when none) | Click: the map centres on it and its window opens (hud.md element 6): the abode screen (home) or the place details (seat). These are automatic rows, not pins: place and quest pins are a known gap against element 6 |
| Ongoing | Rows | Text | "Event waiting: <title>" while one waits | Click: opens it |
| Empty | Text | Text | "Pin people, places or quests here" (hud.md "Nothing to show") when there are no pins and nothing ongoing | No |

Pin limit: `outliner_pins_max` (12) people; the Pin button says "outliner full (12)" past it.

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
| Delete / × | Unpin the focused person |
| Q | The row's tooltip (Nested lockable tooltip, every lock mode) |
| Esc | Leaves the outliner's focus zone (nothing to close) |

After an unpin, focus moves to the next row (or the header when none is left).

## Data Requirements

`GameQuery.outliner(s, pins)` with the pinned ids: {people: [{id, name, place, travelling, alive, band}], home: {id,
name, here, seasons}, seat: {id, name, here, seasons} or {}, event: {title} or {}}; a copy, changes nothing. **Pins**
are kept UI-side in `user://outliner_pins.cfg`, keyed by the world seed and the player's id, until the save format
carries them (hud.md Open Questions: "outliner pins saved with the game"; an ADR item); test runs keep them in memory.

## Events Fired

`person_requested(id)`, `place_requested(id)`, `abode_requested`, `event_requested`, `unpin_requested(id)`.

## Transitions & Animations

None.

## Input Method Completeness Checklist

- [x] Keyboard: rows and × reachable; Delete unpins
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad inside Z2, A opens, X unpins (Partial)
- [x] No hover-only information: place and band in the row

## Accessibility

Text at the 16 px floor (HUD text; the column wraps names and places at 16 px); "died" and the event mark are words;
rows read "Trần Vân, at Thanh Vân, warm"; × buttons read "Unpin Trần Vân"; the focus ring is 3:1; a pinned person's
death reaches the player through the alert row and the season summary (the outliner itself does not announce).

## Localization Considerations

Names wrap within the 144 px column (no limit: wrapping holds 40 % longer text); numbers follow the language.

## Acceptance Criteria

- [ ] `[GdUnit]` A pinned person's row shows their current place and changes when they move.
- [ ] `[GdUnit]` A pinned person who dies shows "died" until unpinned.
- [ ] `[GdUnit]` With no pins and nothing ongoing the empty line shows.
- [ ] `[GdUnit]` Pins persist per world and player across a reload of the store; test runs keep them in memory.
- [ ] `[GdUnit]` Collapsing hides the rows and stores the setting.
- [ ] `[GdUnit]` The pin limit (12) refuses the 13th with "The outliner is full".
- [ ] `[GdUnit]` × and Delete unpin from the keyboard; rows have accessible names.
- [ ] `[Screenshot]` 1920×1080 with a pinned person (`production/qa/evidence/ui-windows/80-*.png`), and 1280×720 collapsed; nothing clips.

## Open Questions

- Pins in the save file (ADR, logged 2026-11-24 in production/plans/ui-greybox-build.md): the UI store is a stopgap;
  the owner should be the session's save. hud.md's "whether the outliner has a pin limit" is answered here: 12.
- Places and quests pins: places pin from the place details once that panel is a window; quests wait for #31.
