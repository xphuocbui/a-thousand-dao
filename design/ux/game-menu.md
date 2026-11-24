# UX Spec: Game Menu and Settings

> **Status**: In Review, lean round 2 NEEDS REVISION (3 blocking, 3 advisory: applied 2026-11-24); written
> 2026-11-23 night by Claude under the UI delegation (memory ui-design-delegated). Round 1 (5 blocking, 10 advisory)
> was applied 2026-11-23. Round 2 found the spec had not caught up with the illustrated rebuild; this update describes
> the window as built (`src/ui/windows/game_menu.gd`, evidence `production/qa/evidence/ui-windows/13-menu-illustrated-1920x1080.png`
> and `compact-1280/menu.png`). Where the review asked for something the code does not do, it is an Open Question below,
> not a claim.
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Look (2026-11-24)**: the illustrated style (user, 2026-11-24): the Menu page opens on a painted banner (a place painting,
> `ui_windows.json` `menu.banner`, `res://assets/art/places/5.webp`) in a brass frame, and every page sits in a
> parchment inset on a darker ground (`Illustrated.ground`, `Illustrated.inset`, `Illustrated.framed`). Buttons are dark
> wood plates with light text. There is no round-3 mock-up for the menu; the character sheet and sect window have one
> (Open Question 6).
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Sources**: `design/ux/hud.md` (element 4; HUD States, "Game menu (paused)"; Tuning Knobs, Player settings; Esc
> rules), `design/accessibility-requirements.md`, `design/gdd/world-generation.md` (the seed is shown and shareable)
> **Patterns used**: Centre window (as a modal), Confirm in place (here also with three buttons: [Save and quit] [Quit]
> [Cancel], an extension flagged for the library), Reply strip (the status line; it persists, a failed save never
> auto-dismisses), Refusal note. **New, flagged for the library's Gaps**: the paged modal (pages in one frame), the save
> row, the setting row, the illustrated banner (a framed painting with a visible placeholder) and the parchment inset
> (both shared with the other illustrated windows, `src/ui/windows/illustrated.gd`).

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
| F1 | Opens the Wiki (a button on the Menu page shows the hint; the wiki, not the menu, answers it) |

Ctrl+S and Ctrl+L are refused while a job runs and in a fight, with a Refusal note ("not while the season resolves").
The menu opens over a blocking event card: it takes focus and returns it to the card on close; the card still
blocks End turn.

Exits: Resume, Esc (on a sub-page Esc goes back to Menu first), Quit (after its confirm), a successful Load (closes on
the loaded world).

## Layout Specification

### ASCII Wireframe (centred, 520 px wide minimum, parchment window with a brass-and-wood frame)

Menu page, as built (screenshots `13-menu-illustrated-1920x1080.png`, `compact-1280/menu.png`):

```
+------------------------------------------+
|  Game menu                           [x] |  M1 frame (title follows the page)
|------------------------------------------|
| +--------------------------------------+ |  dark ground
| | [ painted banner, 150 px tall ]      | |  M5 banner (Menu page only, framed)
| +--------------------------------------+ |
| | parchment inset                      | |
| |  [ Resume          Esc ]             | |  M2 page body: wood-plate buttons
| |  [ Save game       Ctrl+S ]          | |
| |  [ Load game       Ctrl+L ]          | |
| |  [ Settings ]                        | |
| |  [ Wiki            F1 ]              | |
| |  [ Quit to desktop ]                 | |
| +--------------------------------------+ |
|------------------------------------------|
|  World seed 7 · Xuân, year 1200 [Copy seed] |  M3 footer: seed and date
|  status line (saved to …)                |  M4 status
+------------------------------------------+
```

The page body sits in a scroll area (no horizontal scroll, vertical scroll when the page is taller) that is at least
520 px high on a tall screen, so the Menu page fits without scrolling; on a short screen `GameMenu.fit_height` trims it
to the layout height minus 260 px, never under 280 px or over 520 px (built 2026-11-24). The window width is the 520 px
minimum; the window does not use the `ui_windows.json` `widths` shares the other illustrated windows use (Open Question 5).

Settings page: the parchment inset with one row per setting, label left, control right, then the "coming with the
settings pass" line and [Back] (no Back in the settings-only variant):

```
|  Settings                            [x] |
|  UI scale                    [ 100 % v ] |  option row
|  Reduced motion              [ off (o) ] |  toggle, on / off in words
|  Colourblind mode            [ off   v ] |
|  Tooltip delay        ---o---- 0.30 s    |  slider + value
|  ... one row per setting (see inventory) |
|  Coming with the settings pass: …        |
|  [ Back ]                                |
```

Save page: a name field (default "Lâm Phong, Xuân year 1200"), [Save], then the existing saves (newest first), each
with its date, realm and [Overwrite]. Load page: the saves (newest first), each with name, date, realm and [Load];
a save that cannot load (another map version, an old ladder) shows why, greyed. Settings page: one row per setting.

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| M1 | Title + close | Label + button | "Game menu", "Save game", "Load game", "Settings" | × = Resume |
| M5 Menu | Banner | Framed painting, 150 px tall, brass frame | `ui_windows.json` `menu.banner`, cropped to cover. Missing or unloadable art shows `PlaceholderArt` (magenta stripes, "No painting yet"), never an empty or finished-looking frame (`.claude/rules/ui-code.md`; `Illustrated.framed` does this when the texture is null). Menu page only, not in the settings-only variant | No (decoration; no text over it) |
| M2 all pages | Parchment inset | Panel on a darker ground | Holds the page's buttons, rows and fields | No |
| M2 Menu | Six buttons | Buttons with key hints | Resume (Esc), Save game (Ctrl+S), Load game (Ctrl+L), Settings, Wiki (F1), Quit to desktop | Yes |
| M2 Quit | Confirm in place | Row | "Quit? Progress since your last save is lost." [Save and quit] [Quit] [Cancel] | Yes |
| M2 Save / Load / Settings | Back | Button, last in the page | Returns to Menu (not in the settings-only variant) | Yes |
| M2 Save | Name field + Save | LineEdit + button | The new save's name | Yes; Enter saves |
| M2 Save | Save rows | Rows | Name, the game date, realm, the file time; [Overwrite] (confirm in place) | Yes |
| M2 Load | Save rows | Rows | Name, date, realm, file time; [Load] (confirm in place: the Load button becomes one labelled "Load? Unsaved progress is lost." beside [Cancel]) or the reason it cannot load; a greyed row stays focusable and its name carries the reason | Yes |
| M2 Settings | UI scale | Option row | 75 / 90 / 100 / 115 / 125 / 150 % (capped per window, the Scaling rule) | Yes, applies at once |
| M2 Settings | Reduced motion | Toggle | on / off | Yes |
| M2 Settings | Colourblind mode | Option | off / red-green | Yes |
| M2 Settings | Tooltip delay | Slider + number | 0–2 s | Yes |
| M2 Settings | Tooltip lock delay | Slider + number | 0.5–3 s | Yes |
| M2 Settings | Tooltip close grace | Slider + number | 0.3–2 s | Yes |
| M2 Settings | Tooltip lock modes | Three toggles | after the delay, on a middle click, on a click (any of the three) | Yes |
| M2 Settings | Single-letter window hotkeys | Toggle | on / off (Q and V stay on) | Yes |
| M2 Settings | Map borders | Toggle | "Region and province borders on the map": on / off | Yes |
| M2 Settings | Outliner shown | Toggle | on / off | Yes |
| M2 Settings | Not yet adjustable | Text | Key bindings, brightness, End turn input, toast duration and alerts by kind: "coming with the settings pass" (owner: the UI build plan, `production/plans/ui-greybox-build.md`). The line no longer lists the outliner and borders, which are adjustable (fixed 2026-11-24) | No |
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
| Banner art missing | The banner frame shows `PlaceholderArt` ("No painting yet"); the buttons below are unaffected |
| Tall page | A page taller than its scroll area (Settings with all rows, Save or Load with many saves) scrolls vertically inside the window; the title, footer and status stay in view |

## Interaction Map

| Input | Action |
|---|---|
| ≡ / Esc | Open; Esc again: back to Menu from a page, close from Menu |
| Up / Down, Tab | Move between buttons and rows |
| Enter / click | Activate |
| Ctrl+S / Ctrl+L | Save / Load page (works with the menu closed too) |
| Gamepad A / B | Activate / back; Select / View opens the menu; Left / Right adjust sliders and option rows |
| Esc while saving or loading | Consumed; the status line says to wait |

**Initial focus:** the first enabled control of the page: Resume on Menu, the name field on Save, the first enabled
Load button on Load (a greyed row stays focusable on its label), the first setting (UI scale) on Settings. Focus order
is top to bottom as built (Godot's default Tab and arrow focus); on Settings that is each row's control in turn, then
Back. Sliders move with Left / Right. Gamepad focus on Settings and on the Save and Load rows is not yet checked
(Open Question 3).

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
- [ ] `[GdUnit]` With the banner path missing, the Menu page shows `PlaceholderArt` in the Banner frame (no test yet).
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the Menu page and the Settings page; nothing clips. On file: Menu at both
      sizes, Settings at 1280×720 (taken before the borders and outliner rows were added, so it must be retaken).
      Still to capture at 1280×720 into `production/qa/evidence/ui-windows/`: Menu with quit armed, Save with several
      saves, Load with a greyed row, Settings with all twelve rows. `compact-1280/menu.png` shows the menu touching the
      top and bottom screen edges from before `fit_height`; retake it (Open Question 2).
- [ ] `[Screenshot]` Contrast on the new look: 4.5:1 for text on the parchment inset and on the wood-plate buttons, 3:1
      for controls and the focus ring; text at the 16 px floor. The banner is a separate frame above the buttons with no
      text over it, so it cannot lower any label's contrast (checked by layout, confirmed in the screenshots). No
      measurement has been taken yet.
- [ ] `[Manual]` Keyboard only and mouse only; NVDA reads the page names and toggle states.

## Open Questions

Round 2 (2026-11-24), things the review asked for that the build does not do yet:

1. The interaction-patterns library now has the illustrated banner ("Hero painting") and the "Wood ground and parchment
   inset" (2026-11-24). The paged modal, save row and setting row are still not in it; they are covered by the
   "Settings controls" gap listed there.
2. (Closed 2026-11-24: `GameMenu.fit_height` sets the scroll height to clamp(layout height − 260, 280, 520), so at
   1280×720 the menu no longer touches the screen edges. The 1280×720 screenshots are still to be retaken.)
3. **Not verified: gamepad and keyboard focus on the Settings page** (option rows, sliders, toggles) and on the Save and
   Load rows. Needs a manual pass; the Input checklist's gamepad line is Partial until then.
4. (Closed 2026-11-24: the "Coming with the settings pass" line no longer lists the outliner and borders.)
5. (Decided 2026-11-24, UI owner; the user may overrule: the menu stays at 520 px, not a `widths` share.)
6. (Decided 2026-11-24, UI owner; the user may overrule: no mock-up for the menu; the built look, screenshot 13, is
   the target.)
7. (Decided 2026-11-24, UI owner; the user may overrule: the banner stays `assets/art/places/5.webp`, Thiên Xu Tông's seat.)

- Autosave (every N seasons, a rolling slot) is not designed: noted for the settings pass.
- Key binding capture and brightness wait for the settings pass (hud.md Tuning Knobs lists them).
- Language switching needs the localization system (#34, not designed).
- The photosensitivity notice (first launch) has no home yet; it belongs to the first-launch flow, with a re-open
  link in Settings once written.
