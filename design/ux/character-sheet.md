# UX Spec: Character Sheet

> **Status**: In Review, lean round 1 NEEDS REVISION (all 11 findings applied 2026-11-23); written 2026-11-23 night by
> Claude under the UI delegation (memory ui-design-delegated)
> **GDDs read**: `design/gdd/canh-gioi.md` (UI Requirements: the bottleneck panel), `character-stats.md`, `cong-phap.md`
> (slots), `power-rankings.md` (the power number), `dao-do.md`
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-23
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Patterns used** (`design/ux/interaction-patterns.md`): Side panel with history, Sticky header and pinned action
> bar, Section jumps, Breakdown, Link styles, Nested lockable tooltip, Confirm in place, Inline chooser, Reply strip,
> Refusal note.
> **Illustrated layout (user 2026-11-24, round-3 mock-up `prototypes/ui-mood/out/r3-character-l.png`, "Yes, build
> it")**: on a dark wood ground, a framed portrait (PortraitPicker: the painted type set, or the person's own for the
> fixed cast) with a name plaque and the Thiên phú tiles in the left column; the Cultivation inset (realm, gauge,
> bottleneck), the linh căn gauges in element colours and the vitals tiles on the right; the công pháp slot cards with
> Change under each; the remaining sections as parchment insets two by two. Section jumps follow this reading order
> (talents, cultivation, roots, vitals, công pháp, combat, Đạo Đồ, gear, crafts, fate, lifespan). The sticky header
> keeps the name and the age / rating numbers; the standing line moved into the Cultivation inset. Width: 62 % of the
> screen (ui_windows.json widths). Not yet: the mock-up's tabs and trait medallions (the player has no trait list).

---

## Purpose & Player Need

The player's own sheet: "what am I made of, how fast am I growing, and what can I change right now?" It replaces the
greybox's text dump (`GameQuery.sheet_lines`). Everything here is the player's own state, so everything is shown; every
derived number explains itself (Breakdown). Two decisions live here because they are about the self: which công pháp
sit in which slot, and when to attempt the great breakthrough.

## Player Context on Arrival

- From the portrait (Z3), the Character button (Z2) or C: to look at the whole self.
- From a top-bar box (hud.md elements 8, 10, 34): the cultivation, lifespan or renown question; the sheet opens
  scrolled to that section.
- From the bottleneck alert (hud.md Information Architecture, Group 4): at great perfection, to decide on a
  breakthrough.

## Navigation Position

A Z6 side panel (hud.md Layout Zones), one of the window kinds of the shared window host
(`src/ui/windows/window_host.gd`): history back / forward, close, focus return. Not a full screen: the map stays live.
Opening a linked entity (a technique's entry, the inventory, the Đạo Đồ) replaces the panel and is one history step.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Portrait click / Enter, Character button, C | the top |
| Cultivation box | CULTIVATION |
| Lifespan box | LIFESPAN |
| Renown box | FATE |
| Bottleneck alert | CULTIVATION, its Breakthrough block focused |

On full screens (Z6 hidden) the three boxes are tooltip-only and a click does nothing (hud.md Resource box).

Exits: × or Esc (focus back to the opener), back arrow (previous window), the action bar's buttons (another window),
a link in the body (another window). C again while it is open closes it (toggle, like P for Places).

## Layout Specification

### ASCII Wireframe (Z6, about one third of the screen width)

```
+-------------------------------------------+
| < >  Character                        [x] |  C1 frame
| Lâm Phong                                 |  C2 sticky header
| Trúc Cơ Sơ kỳ L3 · Thanh Vân Tông, disciple|
| Age 42 / 136 (94 y left)    Rating 1,512  |
|-------------------------------------------|
| CULTIVATION                               |  C3 body (scrolls)
|  [#########-------] 62 %  tu vi 1,240/2,000|
|  +38 a season here · next level in 3 seasons
|  (at great perfection: the BOTTLENECK block)|
| LINH CĂN   Song linh căn, x1.4             |
|  Hỏa  [######----] 62  Trung phẩm          |
|  Mộc  [###-------] 31  Hạ phẩm             |
| THIÊN PHÚ  Căn cốt 54 · Ngộ tính 71 ...    |
| VITALS     Health 820 · Linh lực 310 ...   |
| COMBAT     Block 12 % · Evade 8 % ...      |
| CÔNG PHÁP  Main: Liệt Hỏa Quyết L3/9 [Change]
| ĐẠO ĐỒ     41 marks open · 2 points unspent|
| GEAR       Thanh Phong Kiếm (weapon)       |
| CRAFTS     Alchemy 3 · Refining 1          |
| FATE       Origin, background, thiên mệnh  |
| LIFESPAN   136 years (Breakdown)           |
|-------------------------------------------|
| reply strip (after an action)             |  C4
| [Inventory] [Đạo Đồ] [Rankings]           |  C5 pinned action bar
+-------------------------------------------+
```

### Layout Zones

| Zone | Holds | Scrolls |
|---|---|---|
| C1 Frame | Back, forward, title, close (hud.md element 20) | No |
| C2 Sticky header | Name, standing, age / lifespan, rating; in the compact layout (1280×720) the standing line folds into the name's tooltip, so the header is two lines | No |
| C3 Body | Eleven sections in this fixed order: Cultivation, Linh căn, Thiên phú, Vitals, Combat, Công pháp, Đạo Đồ, Gear, Crafts, Fate, Lifespan | Yes |
| C4 Reply strip | The result lines of the last action (slot change, breakthrough), up to 3 wrapped lines and a dismiss button (Reply strip pattern) | No |
| C5 Action bar | Inventory, Đạo Đồ, Rankings (at most 4) | No |

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| C1 | Back / forward / close | Buttons | Window history (`history_max` 20) | Yes |
| C2 | Name | Text, heading face | The player's name | No |
| C2 | Standing | Text | Realm, stage, level (tầng in Luyện Khí); sect and rank or "loose cultivator (tán tu)" | Tooltip |
| C2 | Age and lifespan | Text | "Age 42 / 136 (94 y left)"; amber with ⌛ under `lifespan_warn_share` | Tooltip: lifespan Breakdown |
| C2 | Rating | Number | The power number, "~" when provisional, "—" when unrated | Tooltip: what it is |
| C3 Cultivation | Progress | Bar + text | Tu vi / requirement and %, the rate here a season, seasons to the next level | Tooltip: rate Breakdown |
| C3 Cultivation | Bottleneck block | Rows + button | Only at great perfection: bar full or not, the condition and whether it is met, the pill, the talisman, this attempt's chance, the qi deviation risk; **Attempt breakthrough** | Confirm in place: the armed row reads "Attempt the breakthrough? 62 % success; 8 % qi deviation if it fails" with [Confirm] and [Cancel]; tooltip: chance Breakdown |
| C3 Linh căn | Element rows | Element mark + bar + number + grade word per element | The element's Hán mark (火 木 水 金 土, a shape, never colour alone), purity of each of the five elements ("—" when absent), the tier name and the speed against a single root; variants with their lines | Tooltip per element: its role |
| C3 Thiên phú | Talent rows | Number + grade word + bonus | The six talents, effective value, grade, gear / tree bonus as a signed number | Tooltip: talent Breakdown |
| C3 Vitals | Stat rows | Number | Health (current / max), linh lực, thần thức, vitality %, đan độc (pills −n %), tâm ma (backlash %) | Tooltip: Breakdown each |
| C3 Combat | Stat rows | Number | The fight sheet: ward points, ward layer, body shield share, block, evade, crit chance and multiplier, resistance by damage type (each with its type word), soul resistance, health regen | Tooltip: what it does |
| C3 Công pháp | Slot rows | Row + Change button | Main, second, art 1, art 2: technique, kind, layer / layers, mastery to the next layer, "gated" or "unusable" marks; the speed factor line; known techniques not slotted | Change opens an inline chooser of known usable techniques plus "Empty"; a change that would end the life asks to confirm in place |
| C3 Gear | Item rows | Row | Equipped items with their slot | Tooltip: the item text; a link opens the inventory |
| C3 Crafts | Skill rows | Row | Each đạo nghệ and its level, "none yet" | No |
| C3 Đạo Đồ | Summary | Row + button | Dao marks open, points unspent, the next points line | "Open Đạo Đồ" |
| C3 Fate | Rows | Text | Origin, background, birth mode (Thiên Định / Tự Định), thiên mệnh perks with their text, renown ("not tracked yet") | Tooltips |
| C3 Lifespan | Breakdown | Lines | The lifespan Breakdown in full, age, years left | No |
| C4 | Reply strip | Text + dismiss | Up to 3 result lines of the last action | Dismiss button, the next action, or close |
| C5 | Inventory / Đạo Đồ / Rankings | Buttons | Open that window | Yes |

Sections never vanish: an empty one says "none". The Combat section reads the compiled fighter (the same compile as
the practice fight), so it is the sheet a fight uses.

### Information Hierarchy

1. Who and how strong (C2), always in view.
2. Growth (Cultivation): the most-asked question each season.
3. Made of (Linh căn, Thiên phú, Vitals, Combat): why the numbers are what they are.
4. Choices (Công pháp, Đạo Đồ), then the record (Gear, Crafts, Fate, Lifespan).

## States & Variants

| State | What changes |
|---|---|
| Normal | As the wireframe |
| Action refused | The session refused a slot change or breakthrough (unusable technique, not at the bottleneck, already slotted, not at the season start): its reason shows in the reply strip and as a Refusal note beside the control for `refusal_seconds` (2 s); the view refreshes from the session after every action, refused or not |
| At great perfection | The Bottleneck block shows in Cultivation; the bar reads "full" when the bar cost is met |
| Realm cap / last realm | Cultivation says "the highest realm" and shows no next-level line; no Bottleneck block |
| Event waiting | Look-only (pattern): Change and Attempt show a lock mark 🔒, are disabled, and their tooltip and accessible name say "locked while an event waits"; reading, scrolling and tooltips stay live |
| A job running | The host does not read; the window keeps its last view and its buttons are disabled |
| Dead (life ended) | The sheet is as at death, header marked "(died)"; no actions |

## Interaction Map

| Input | Action |
|---|---|
| C | Open (top) / close |
| Tab / Shift+Tab | Next / previous control; section headings are focus stops (Section jumps) |
| Home / End | First / last section heading |
| Up / Down, wheel, PgUp / PgDn | Scroll the body |
| Q on a focused number | Its tooltip (Nested lockable tooltip) |
| Enter on Change | Opens the inline chooser; Up / Down pick, Enter applies, Esc cancels |
| Enter on Attempt breakthrough | Arms it: the row shows the chance and the risk with [Confirm] and [Cancel], focus on Cancel; Confirm runs it; Cancel or Esc disarms; nothing times out |
| Alt+← / Alt+→, mouse 4 / 5 | Window history |
| Esc | Closes the chooser or disarms first, then closes the window |
| Gamepad A / B, LT / RT | Activate / back; previous / next section |

Every key above is rebindable (hud.md Platform Adaptation); the table lists the defaults.

## Data Requirements

One read, `GameQuery.character(s)` (ADR-0006: a copy, changes nothing), returns every field the window shows,
including the Breakdowns (each `{total, lines}`), so the window never reads the session on hover. The slot chooser's
options (known techniques, usable or not with the reason) are part of the same read. Actions go through the existing
session commands via `session.run`: `set_slot(slot, index, key, confirm)` and `breakthrough(confirm_bare,
use_talisman)`; the window only requests them (signal), the map screen runs the job and refreshes the view.

**Updates:** the view is read when the window opens, after every job (any action, End turn) and on history steps;
the window never polls and never reads while a job runs.

| Section | Owning system | Empty / unknown value |
|---|---|---|
| Header rating | Power Rankings (`power-rankings.md`) | "—" unrated, "~1,512" provisional |
| Cultivation, Bottleneck | Realms (`canh-gioi.md`) | "the highest realm" at the cap |
| Linh căn | Character Stats | "—" for an absent element |
| Thiên phú, Vitals, Lifespan | Character Stats | never empty |
| Combat | Combat (the fighter compile) | "—" when the fighter cannot compile |
| Công pháp | Công Pháp (`cong-phap.md`) | "Empty" slot; "none" known |
| Đạo Đồ | Đạo Đồ (`dao-do.md`) | "0 open" |
| Gear | Item Database | "none" |
| Crafts | Crafting skills | "none yet (practice raises them)" |
| Fate | Origins, Progression Edges | renown "not tracked yet" |

A history entry for the sheet has no subject, so it is never gone.

## Events Fired

- `action_requested("set_slot", [slot, index, key, confirm])`, `action_requested("breakthrough", [confirm_bare, true])`
- `open_requested(kind, subject, section)` for Inventory, Đạo Đồ, Rankings
A breakthrough's result also runs the HUD's banner and summary order (hud.md Feedback) through the session events.

## Transitions & Animations

Opens and closes with the host (slides over `motion_fast`; none under reduced motion). The cultivation bar does not
animate in the sheet. No other motion.

## Input Method Completeness Checklist

- [x] Every control reachable by keyboard (Tab order: header, sections top to bottom, action bar)
- [x] Mouse: every control clickable, every number hoverable
- [x] Gamepad: A / B, LT / RT section jumps, d-pad focus (Partial, as the HUD)
- [x] No hover-only information: Q opens every tooltip from the keyboard

## Accessibility

Text at the 16 px floor (secondary lines 14 px, `design/accessibility-requirements.md`); grades and changes carry a
word or sign, never colour alone (element bars carry the number and the Hán mark); text contrast at least 4.5:1,
bars, marks and the focus ring at least 3:1 against the parchment (the amber lifespan warning carries ⌛ as well); the
Attempt button's armed state changes its text, not only its colour.

**Screen reader** (the committed panel tier):
- On open the panel is announced as a named region ("Character sheet, Lâm Phong") and focus goes to its first control.
- Section headings have the heading role; each is a focus stop.
- Buttons are named for what they do: "Back", "Forward", "Close character sheet", "Change main technique", "Change art 1", "Attempt breakthrough".
- Each bar exposes its value as text: "Hỏa purity 62, Trung phẩm"; "Cultivation 62 percent, 1,240 of 2,000".
- The armed confirm is announced: "Attempt the breakthrough? 62 percent success, 8 percent qi deviation. Confirm or Cancel".
- The reply strip and a refusal note are announced politely.

## Localization Considerations

Every string through `tr()`; numbers follow the language (HudReadouts); Vietnamese terms stay in Hán-Việt with English
glosses where the HUD already uses them; rows wrap rather than truncate (30 % longer text).

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.character` returns name, standing, age, lifespan, rating, cultivation progress and rate, the
      five element purities, the six talents, the vitals, the combat sheet, the four slots, known techniques, gear,
      crafts, Đạo Đồ counts, fate, and the Breakdowns for rate, lifespan, health, linh lực, thần thức, đan độc, backlash
      and each talent.
- [ ] `[GdUnit]` Calling it leaves `to_dict()` unchanged and creates no rating record for an unrated player.
- [ ] `[GdUnit]` The Bottleneck block is present exactly when the player is at great perfection.
- [ ] `[GdUnit]` The window built from a view has the eleven section headings in order and a Change button per slot;
      choosing a technique in the chooser emits `action_requested("set_slot", ...)` with that key.
- [ ] `[GdUnit]` Attempt breakthrough emits nothing on the first press (arms) and `action_requested("breakthrough", ...)`
      on Confirm.
- [ ] `[GdUnit]` Look-only: with an event waiting, Change and Attempt are disabled.
- [ ] `[GdUnit]` The host's back arrow returns to the previous window and forward goes again; opening a new window after
      going back drops the forward entries.
- [ ] `[GdUnit]` A refused action's reason appears in the reply strip, and the view is re-read after the job.
- [ ] `[GdUnit]` The armed breakthrough row names the chance and the qi deviation risk; Cancel disarms without emitting.
- [ ] `[GdUnit]` Opening the sheet (read + build) takes under 50 ms on the test world.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the top of the sheet, and the sheet scrolled to Công pháp with the chooser
      open; nothing clips; text at or above the 16 / 14 px floor; contrast checked on the shot.
- [ ] `[Screenshot]` 150 % UI scale at 1920×1080, and 75 % at 1280×720: nothing clips.
- [ ] `[Manual]` Keyboard only and mouse only, every control reached; reduced motion: the panel appears without sliding;
      NVDA reads the region name, the headings and the armed confirm (accessibility test plan).

## Open Questions

- Renown has no sources yet (hud.md): shown as "not tracked yet" in Fate.
- Portrait art: the greybox draws an initial (as the person window).
- Pins to the outliner: the player is always in it; no pin button here.
