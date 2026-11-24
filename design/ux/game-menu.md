# UX Spec: Game Menu and Settings

> **Status**: In Review, lean round 1 NEEDS REVISION (5 blocking, 10 advisory: all applied 2026-11-23); written
> 2026-11-23 night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-23
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Sources**: `design/ux/hud.md` (element 4; HUD States, "Game menu (paused)"; Tuning Knobs, Player settings; Esc
> rules), `design/accessibility-requirements.md`, `design/gdd/world-generation.md` (the seed is shown and shareable)
> **Patterns used**: Centre window (as a modal), Confirm in place (here also with three buttons: [Save and quit] [Quit]
> [Cancel], an extension flagged for the library), Reply strip (the status line; it persists, a failed save never
> auto-dismisses), Refusal note. **New, flagged for the library's Gaps**: the paged modal (pages in one frame), the save
> row, the setting row.

---

## Purpose & Player Need

"Let me save, load, change how the game looks and feels, or stop." The menu is the one place for things outside the
world: save files, player settings, the world seed and quitting. The game has no pause (seasons are turns), so the
menu changes nothing in the world; it only blocks input to the HUD while open.

## Player Context on Arrival

From ≡ in the top bar (element 4) or Esc when nothing else answers it (hud.md Esc rules: the ranked list ends in "the
game menu"). The player is between actions; no job runs (the menu does not open while a season resolves).

## Navigation Position

A modal centre window over a dimmed screen (hud.md HUD States: "Game menu (paused)"), above Z6 and Z7, below the
tooltip layer. It has four pages in one frame: **Menu**, **Save**, **Load**, **Settings**. It is not a Z6 window and has
no history; Back on a page returns to Menu.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| ≡ (top bar) | Menu |
| Esc with nothing else to close | Menu |
| Ctrl+S | Save page |
| Ctrl+L | Load page |
| Gamepad Select / View | Menu (Start is held for End turn, hud.md Platform Adaptation) |
| Esc in a fight or tribulation | **Settings only** (no Save, Load or Quit; Esc closes it; hud.md Esc rules) |

Ctrl+S and Ctrl+L are refused while a job runs and in a fight, with a Refusal note ("not while the season resolves").
The menu opens over a blocking event card: it takes focus and returns it to the card on close; the card still
blocks End turn.

Exits: Resume, Esc (on a sub-page Esc goes back to Menu first), Quit (after its confirm), a successful Load (closes on
the loaded world).

## Layout Specification

### ASCII Wireframe (centred, about 520 px wide, parchment window)

```
+------------------------------------------+
|  Game menu                           [x] |  M1 frame (title follows the page)
|------------------------------------------|
|  [ Resume                ]               |  M2 page body
|  [ Save game             ]  Ctrl+S       |
|  [ Load game             ]  Ctrl+L       |
|  [ Settings              ]               |
|  [ Wiki                  ]  F1           |
|  [ Quit to desktop       ]               |
|------------------------------------------|
|  World seed 7 · Xuân, year 1200          |  M3 footer: seed and date
|  status line (saved to …)                |  M4 status
+------------------------------------------+
```

Save page: a name field (default "Lâm Phong, Xuân year 1200"), [Save], then the existing saves (newest first), each
with its date, realm and [Overwrite]. Load page: the saves (newest first), each with name, date, realm and [Load];
a save that cannot load (another map version, an old ladder) shows why, greyed. Settings page: one row per setting.

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| M1 | Title + close | Label + button | "Game menu", "Save game", "Load game", "Settings" | × = Resume |
| M2 Menu | Six buttons | Buttons | Resume, Save game, Load game, Settings, Wiki, Quit to desktop | Yes |
| M2 Quit | Confirm in place | Row | "Quit? Unsaved progress since your last save is lost." [Save and quit] [Quit] [Cancel] | Yes |
| M2 Save | Name field + Save | LineEdit + button | The new save's name | Yes; Enter saves |
| M2 Save | Save rows | Rows | Name, the game date, realm, the file time; [Overwrite] (confirm in place) | Yes |
| M2 Load | Save rows | Rows | Name, date, realm, file time; [Load] (confirm in place: "Load? Unsaved progress is lost." [Load] [Cancel]) or the reason it cannot load; a greyed row stays focusable and its name carries the reason | Yes |
| M2 Settings | UI scale | Option row | 75 / 90 / 100 / 115 / 125 / 150 % (capped per window, the Scaling rule) | Yes, applies at once |
| M2 Settings | Reduced motion | Toggle | on / off | Yes |
| M2 Settings | Colourblind mode | Option | off / red-green | Yes |
| M2 Settings | Tooltip delay | Slider + number | 0–2 s | Yes |
| M2 Settings | Tooltip lock delay | Slider + number | 0.5–3 s | Yes |
| M2 Settings | Tooltip close grace | Slider + number | 0.3–2 s | Yes |
| M2 Settings | Tooltip lock modes | Three toggles | after the delay, on a middle click, on a click (any of the three) | Yes |
| M2 Settings | Single-letter window hotkeys | Toggle | on / off (Q and V stay on) | Yes |
| M2 Settings | Not yet adjustable | Text | Key bindings, brightness, End turn input, toast duration, the outliner, borders and alerts by kind: "coming with the settings pass" (owner: the UI build plan, `production/plans/ui-greybox-build.md`) | No |
| M3 | Seed and date | Text + [Copy seed] | "World seed 7 · Xuân, year 1200" | Copy seed puts it on the clipboard |
| M4 | Status line | Text | "Saved to … (slot)", "Loaded", or a refusal reason | Announced politely |

Settings are the player's (one for all saves, `user://settings.cfg`), applied the moment they change; defaults come
from `assets/data/ui_windows.json` `settings`.

## States & Variants

| State | What changes |
|---|---|
| Menu | Six buttons |
| Quit armed | The quit confirm row replaces the Quit button; focus on Cancel |
| Saving / Loading | Buttons disabled, status "Saving…" / "Loading…"; the job runs (ADR-0006); Esc does nothing until it ends |
| Save failed | Status shows the error; nothing else changes |
| Load refused | Status shows the session's reason ("made on map version …"); the current world stays |
| No saves | Load page: "No saves yet." |
| Event waiting | Saving and loading still work; the menu does not answer the event |
| Settings only | In a fight or tribulation: the Settings page alone, no Back, Esc closes |
| Name collision | A new save whose file-safe name exists arms the Overwrite confirm for that file; the status names the file |
| File unreadable | Load page: "Cannot read this file" on its row; a disk-full or write error shows in the status line |

## Interaction Map

| Input | Action |
|---|---|
| ≡ / Esc | Open; Esc again: back to Menu from a page, close from Menu |
| Up / Down, Tab | Move between buttons and rows |
| Enter / click | Activate |
| Ctrl+S / Ctrl+L | Save / Load page (works with the menu closed too) |
| Gamepad A / B | Activate / back; Select / View opens the menu; Left / Right adjust sliders and option rows |
| Esc while saving or loading | Consumed; the status line says to wait |

**Initial focus:** Resume on Menu, the name field on Save, the first row on Load, the first control on Settings. Tab
order follows the wireframe.

Every key is rebindable once the key-binding settings exist (hud.md Platform Adaptation).

## Data Requirements

- Save: `session.to_dict()` as a job, then `SaveStore.write(slot, dict)` under `user://saves`; the slot name is the
  player's text made file-safe. Rows read each file's header only once per page open (name, date, realm, version,
  file time), from a small meta file written beside the save (`user://saves/meta/<slot>.json`). The slot is the
  name's ASCII letters and digits in lower case, other runs one "_" ("Lâm Phong 2" → `l_m_phong_2`); names are
  at most `name_max` (48) characters; long names wrap in their row.
- Load: a new `GameSession` with `load_dict(dict)` as a job; on success the map screen swaps to it (the old session is
  shut down), the HUD baselines reset (no season change shows until the next End turn: hud.md Resource box).
- Seed and date: `GameQuery.clock` and the session seed through a new read, `GameQuery.world_seed`.
- Settings: `PlayerSettings` (`user://settings.cfg`), a UI-side store; nothing in the world.

## Events Fired

`save_requested(slot)`, `load_requested(slot)`, `quit_requested(save_first)`, `wiki_requested()`,
`setting_changed(key, value)`: the map screen does the work.

## Transitions & Animations

Fades in over `motion_fast` (none under reduced motion); the dim behind it is instant.

## Input Method Completeness Checklist

- [x] Keyboard: every control in Tab order; Enter activates; Esc backs out
- [x] Mouse: everything clickable
- [x] Gamepad: A / B and d-pad focus (Partial)
- [x] No hover-only information

## Accessibility

Text at the 16 px floor; toggles say on / off in words; the modal traps focus while open and returns it to the opener
(≡ or the focused control) on close; the status line is a polite live region; the dim never hides the menu's own
contrast (4.5:1 text, 3:1 controls). Screen reader: the window is announced "Game menu" (then the page name), each
button by its text, toggles by "Reduced motion, off", the slider by its value in seconds.

## Localization Considerations

Every string through `tr()`; dates and numbers follow the language; save names are the player's own text (Vietnamese
typing allowed: the field is IME-safe, so single-letter hotkeys are off while it has focus).

## Acceptance Criteria

- [ ] `[GdUnit]` The menu has the six buttons in order; Esc on a page returns to Menu, Esc on Menu closes.
- [ ] `[GdUnit]` Quit arms first; Cancel disarms without emitting; Quit emits `quit_requested(false)`.
- [ ] `[GdUnit]` A save written and read back through SaveStore restores the same `to_dict()` (round trip) and its row shows
      the name, date and realm.
- [ ] `[GdUnit]` PlayerSettings returns the data defaults when no file exists, keeps a changed value across a reload, and
      clamps the UI scale and tooltip delay to their ranges.
- [ ] `[GdUnit]` A load refused by the session leaves the current session in place and shows the reason.
- [ ] `[GdUnit]` Load arms first; only its confirm emits `load_requested`.
- [ ] `[GdUnit]` A new save whose slot exists arms the overwrite confirm instead of saving.
- [ ] `[GdUnit]` The settings-only variant shows the Settings page with no Back, and Esc closes it.
- [ ] `[GdUnit]` Esc while busy is consumed and leaves the page.
- [ ] `[GdUnit]` Opening the menu and saving the test world each take under 200 ms and 2 s.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the Menu page and the Settings page; nothing clips.
- [ ] `[Manual]` Keyboard only and mouse only; NVDA reads the page names and toggle states.

## Open Questions

- Autosave (every N seasons, a rolling slot) is not designed: noted for the settings pass.
- Key binding capture and brightness wait for the settings pass (hud.md Tuning Knobs lists them).
- Language switching needs the localization system (#34, not designed).
- The photosensitivity notice (first launch) has no home yet; it belongs to the first-launch flow, with a re-open
  link in Settings once written.
