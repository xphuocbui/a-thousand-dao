# UX Spec: Character Sheet

> **Status**: In Review, lean round 2 NEEDS REVISION (5 blocking, 4 advisory: applied 2026-11-24); written 2026-11-23
> night by Claude under the UI delegation (memory ui-design-delegated). Round 1 (11 findings) applied 2026-11-23. This
> spec supersedes `design/ux/person.md` (its content has a home here; see Acceptance Criteria). Where the spec says
> "Not built yet", the build (`src/ui/windows/character_window.gd`) does not do it and the item is an Open Question.
> **GDDs read**: `design/gdd/canh-gioi.md` (UI Requirements: the bottleneck panel), `character-stats.md`, `cong-phap.md`
> (slots), `power-rankings.md` (the power number), `dao-do.md`
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Patterns used** (`design/ux/interaction-patterns.md`): Side panel with history (at 62 % width, not the pattern's
> usual one third), Sticky header and pinned action bar, Section jumps (per tab), Breakdown, Link styles, Nested
> lockable tooltip, Confirm in place, Inline chooser, Reply strip, Refusal note.
> **New patterns needed (not in the library yet)**: Tab bar (toggle buttons in the sticky header; Ctrl+Tab steps them;
> see Interaction Map), and Illustrated tile (framed portrait, medallion, trait chip, stat tile, slot card:
> `src/ui/windows/illustrated.gd`). Both are to be added to `interaction-patterns.md` by its owner.
> **Illustrated layout (user 2026-11-24, round-3 mock-up `prototypes/ui-mood/out/r3-character-l.png`, "Yes, build
> it")**: on a dark wood ground, a framed portrait (PortraitPicker: the painted type set, or the person's own for the
> fixed cast) with a name plaque and the Thiên phú tiles in the left column; the Cultivation inset (realm, gauge,
> bottleneck), the linh căn gauges in element colours and the vitals tiles on the right; the công pháp slot cards with
> Change under each; the remaining sections as parchment insets two by two. Section jumps follow this reading order
> (talents, cultivation, roots, vitals, công pháp, combat, Đạo Đồ, gear, crafts, fate, lifespan). The sticky header
> keeps the name and the age / rating numbers; the standing line moved into the Cultivation inset. Width: 62 % of the
> screen (ui_windows.json widths). Traits (2026-11-24): a Traits inset under Cultivation with the painted trait
> medallions (assets/icons/traits, 77, tools/asset-pipeline/icons/gen_traits.py) and their stat lines in the tooltip; a
> new player has none yet ("deeds and fate give traits"). Tabs (2026-11-24): Overview (the mock-up's page: portrait,
> Thiên phú, cultivation, traits, linh căn, vitals, công pháp), Combat, Equipment (Đạo Đồ, gear, crafts), Fate & life;
> a section jump opens its tab; Ctrl+Tab / Ctrl+Shift+Tab step the tabs.
> One window for everyone (2026-11-24): the sheet shows any person (subject = their id), look-only, with an Interact
> tab first (design/ux/person.md's content: verbs, ties, history, Pin / Relations / Practice fight / Travel); traits are
> icons with their info on hover.

---

## Purpose & Player Need

One window, two subjects.

**The player's own sheet** (subject ""): "what am I made of, how fast am I growing, and what can I change right now?"
It replaces the greybox's text dump (`GameQuery.sheet_lines`). Everything here is the player's own state, so everything
is shown; every derived number explains itself (Breakdown). Two decisions live here because they are about the self:
which công pháp sit in which slot, and when to attempt the great breakthrough.

**Another person's sheet** (subject = their id): "who is this, what do they think of me, and what can I do with them
right now?" It is the same sheet, look-only (no slot changes, no breakthrough), plus an Interact tab: attitude, where
they are, ties, recent history, the verbs, and Pin / Relations / Practice fight / Travel. The player always sees
everything about a person (nothing is withheld for distance or acquaintance), as `person.md` decided.

## Player Context on Arrival

- From the portrait (Z3), the Character button (Z2) or C: to look at the whole self.
- From a top-bar box (hud.md elements 8, 10, 34): the cultivation, lifespan or renown question; the sheet opens at that
  section's tab, scrolled to it.
- From the bottleneck alert (hud.md Information Architecture, Group 4): at great perfection, to decide on a
  breakthrough.
- From a person's name or portrait in another window, the outliner or the map (a link of kind "person"): to decide
  what to do with them; the sheet opens on their Interact tab.

## Navigation Position

A Z6 side panel (hud.md Layout Zones), one of the window kinds of the shared window host
(`src/ui/windows/window_host.gd`): history back / forward, close, focus return. The sheet is 62 % of the screen width
(`ui_windows.json` `widths.character`); the map stays live in the remaining 38 %, but it is a narrow strip, so the map
is for glancing, not for working, while the sheet is open. Not a full screen. Opening a linked entity (a technique's
entry, the inventory, the Đạo Đồ, a tie's person) replaces the panel and is one history step.

## Entry & Exit Points

Section order, stated once and used everywhere (the jump order of `CharacterWindow.SECTIONS`): Thiên phú, Cultivation,
Traits, Linh căn, Vitals, Công pháp, Combat, Đạo Đồ, Gear, Crafts, Fate, Lifespan (the Interact tab adds Who they
are, Ties, Recent history, Verbs).

Tabs, in order: **Interact** (another person only), **Overview** (Thiên phú, Cultivation, Traits, Linh căn, Vitals,
Công pháp), **Combat** (Combat), **Equipment** (Đạo Đồ, Gear, Crafts), **Fate & life** (Fate, Lifespan).

| Entry | Subject | Opens at |
|---|---|---|
| Portrait click / Enter, Character button, C | the player | Overview, top |
| Cultivation box | the player | Overview, CULTIVATION |
| Lifespan box | the player | Fate & life, LIFESPAN |
| Renown box | the player | Fate & life, FATE |
| Bottleneck alert | the player | Overview, CULTIVATION, its Breakthrough block focused |
| A person's name, portrait or tie (any window) | that person | Interact, top; first live verb focused |
| V while a person's sheet is open | that person | Interact, VERBS, first live verb focused |
| History back / forward | as it was | the entry's own subject and section; the tab follows the section (see Data Requirements for a person who is gone) |

Default tab: Overview for the player, Interact for another person. The tab resets to that default only when the sheet
changes subject; reopening the same subject keeps the tab you were on.

On full screens (Z6 hidden) the three boxes are tooltip-only and a click does nothing (hud.md Resource box).

Exits: × or Esc (focus back to the opener), back arrow (previous window), the action bar's buttons (another window),
a link in the body (another window). C again while it is open closes it (toggle, like P for Places).

## Layout Specification

### ASCII Wireframe (Z6, 62 % of the screen width; the Overview tab, the player's own sheet)

```
+-----------------------------------------------------------+
| < >  Character                                        [x] |  C1 frame
| Lâm Phong                                                 |  C2 sticky header
| Age 42 / 136 (94 y left)                  Rating 1,512    |
| [Overview] [Combat] [Equipment] [Fate & life]             |  C2 tab bar
|-----------------------------------------------------------|
| +----------+  CULTIVATION  Trúc Cơ · L3                   |  C3 body (scrolls), dark wood ground
| | portrait |   sect, rank · age 42 / 136                  |
| |  (framed)|   [=========-------] brass gauge             |
| +----------+   Tu vi 1,240 / 2,000 (62 %) · Rate +38 ...  |
| [ Lâm Phong ]  (BOTTLENECK block at great perfection)     |  name plaque
| THIÊN PHÚ     TRAITS  (medallions, or "none yet")         |
| [tile][tile]  LINH CĂN · tier · x1.4   VITALS             |
| [tile][tile]   火 Hỏa [#####--] 62     [tile][tile]       |
| [tile][tile]   木 Mộc [##-----] 31     [tile][tile]       |
|               CÔNG PHÁP  speed factor                     |
|               [card Main][card Second][card Art 1][Art 2] |
|               [Change]    [Change]    [Change]  [Change]  |
|-----------------------------------------------------------|
| reply strip (after an action)                             |  C4
| [Inventory] [Đạo Đồ] [Rankings]                           |  C5 pinned action bar
+-----------------------------------------------------------+
```

The other tabs are parchment insets two by two on the same wood ground (one column at 1280×720): Combat (the fighter's
rows), Equipment (Đạo Đồ summary, Gear, Crafts), Fate & life (Fate, Lifespan).

Another person's sheet opens on **Interact**:

```
+-----------------------------------------------------------+
| < >  Hạ Thanh Vân                                     [x] |
| Hạ Thanh Vân            Age 61 / 140        Rating ~1,420 |
| [Interact] [Overview] [Combat] [Equipment] [Fate & life]  |
|-----------------------------------------------------------|
| +--------+  WHO THEY ARE   Kết Đan · L2                    |
| |portrait|   sect, rank, archetype · age                  |
| +--------+   Attitude: friendly +12 · Where: Thanh Vân (here)
|              Home: ... · trait medallions                 |
| TIES (portrait, kinds, partner link)  RECENT HISTORY (5)  |
| VERBS  Social / Favours / Conflict / Bonds                |
|   [Greet (Hàn huyên)   v will accept]                     |
|   [Spar (Luận bàn)     — not in the game yet ...]         |
|-----------------------------------------------------------|
| [Pin] [Relations] [Practice fight] [Travel there]         |  C5 (replaces Inventory / Đạo Đồ / Rankings)
+-----------------------------------------------------------+
```

### Layout Zones

| Zone | Holds | Scrolls |
|---|---|---|
| C1 Frame | Back, forward, title ("Character" for the player, the person's name for another, "(died)" appended when dead), close (hud.md element 20) | No |
| C2 Sticky header | Name, age / lifespan, rating, then the tab bar; the standing (realm, sect, rank) is in the Cultivation inset and in the name's tooltip. In the compact layout (below 1500 px width, `compact_width`; the 1280×720 case) the name joins the numbers on one line, so the header is the numbers line plus the tab bar | No |
| C3 Body | The open tab's sections, in the section order under Entry & Exit Points, on a dark wood ground; Overview is a left column (portrait, plaque, Thiên phú tiles) beside a right column (Cultivation, Traits, Linh căn and Vitals side by side, Công pháp cards); the other tabs are parchment insets two by two (one column when compact) | Yes |
| C4 Reply strip | The result lines of the last action (slot change, breakthrough), up to 3 wrapped lines and a dismiss button (Reply strip pattern) | No |
| C5 Action bar | The player: Inventory, Đạo Đồ, Rankings. Another person: Pin / Unpin, Relations, Practice fight (living non-beasts only), Travel there (when they are elsewhere and alive). At most 4 | No |

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| C1 | Back / forward / close | Buttons | Window history (`history_max` 20) | Yes |
| C2 | Name | Text, heading face | The subject's name | Tooltip: the standing (realm, level, sect and rank, or "loose cultivator (tán tu)") |
| C2 | Age and lifespan | Text | "Age 42 / 136 (94 y left)"; amber with ⌛ under `lifespan_warn_share` | Tooltip: lifespan Breakdown |
| C2 | Rating | Number | The power number, "~" when provisional, "—" when unrated | Tooltip: what it is |
| C2 | Tab bar | Toggle buttons | Interact (another person only), Overview, Combat, Equipment, Fate & life; the open tab pressed; accessible name "Overview, selected" | Click, Enter, Ctrl+Tab / Ctrl+Shift+Tab |
| C3 Overview | Portrait | Framed picture | `PortraitPicker`: the painted type set, or the person's own for the fixed cast; **missing art shows `PlaceholderArt`** (magenta-and-ink stripes, the word PLACEHOLDER), never a stand-in | No |
| C3 Overview | Name plaque | Text | The name | No |
| C3 Thiên phú | Talent tiles | Icon tile (focus stop) | Icon, talent name, value, grade, signed gear / tree bonus; two per row | Tooltip: talent Breakdown |
| C3 Traits | Trait chips | Painted medallion (focus stop) | One icon per trait (77 painted); "none yet: deeds and fate give traits as your life goes on" for a new player; accessible name "title, group"; the stat lines are in the tooltip | Tooltip on hover |
| C3 Cultivation | Progress | Bar + text | Tu vi / requirement and %, the rate here a season, seasons to the next level | Tooltip: rate Breakdown |
| C3 Cultivation | Bottleneck block | Rows + button | Only at great perfection: bar full or not, the condition and whether it is met, the pill, the talisman, this attempt's chance, the qi deviation risk; **Attempt breakthrough** | Confirm in place: the armed row reads "Attempt the breakthrough? 62 % success; 8 % qi deviation if it fails" with [Confirm] and [Cancel]; tooltip: chance Breakdown |
| C3 Linh căn | Element rows | Element mark + bar + number + grade word per element | The element's Hán mark (火 木 水 金 土, a shape, never colour alone), purity of each of the five elements ("—" when absent), the tier name and the speed against a single root; variants with their lines | Tooltip per element: its role |
| C3 Vitals | Stat tiles | Icon tile (focus stop) | Health (current / max), linh lực, thần thức, vitality %, đan độc (pills −n %), tâm ma (backlash %) | Tooltip: Breakdown each |
| C3 Combat | Stat rows | Number | The fight sheet: ward points, ward layer, body shield share, block, evade, crit chance and multiplier, resistance by damage type (each with its type word), soul resistance, health regen | Tooltip: what it does |
| C3 Công pháp | Slot cards | Card (focus stop) + Change button under each | Main, second, art 1, art 2: painted icon (its own, else its type's, else its element's), technique name, layer / layers; the card tooltip has the mastery to the next layer and the "gated" mark; the speed factor line; known techniques not slotted with an "unusable" mark | Change opens an inline chooser of known techniques that fit the slot (unusable or already slotted ones greyed with the reason) plus "Empty the slot" and Cancel. **Not built yet:** a change that would end the life asking to confirm in place (Open Question 1) |
| C3 Gear | Item rows | Row | Equipped items with their slot | Tooltip: the item text; a link opens the inventory |
| C3 Crafts | Skill rows | Row | Each đạo nghệ and its level, "none yet" | No |
| C3 Đạo Đồ | Summary | Row + button | Dao marks open, points unspent, the next points line | "Open Đạo Đồ" |
| C3 Fate | Rows | Text | Origin, background, birth mode (Thiên Định / Tự Định), thiên mệnh perks with their text, renown ("not tracked yet") | Tooltips |
| C3 Lifespan | Breakdown | Lines | The lifespan Breakdown in full, age, years left | No |
| C3 Interact | Who they are | Inset: portrait, realm title, rows | Realm, sect, rank, archetype, age; Attitude ("not met", or band and signed number); Where (place, "(here)"); Home; trait chips | Rows are focus stops; tooltips |
| C3 Interact | Ties | Inset | Per tie: partner portrait medallion, the kinds ("master", "feud", "debt" ...), the partner as a link; "none" when empty; the player's ties first, then up to 3 others | Link opens that person's sheet (a history step) |
| C3 Interact | Recent history | Inset | The last 5 events about them, or "none" | No |
| C3 Interact | Verbs | Button rows in four groups: Social (5), Favours (3), Conflict (3), Bonds (4) | Each row reads "will accept" with a ✓ mark when live, or "— reason" when not: "not here: [place]", "locked while an event waits (look only)", or "not in the game yet (the verb system is designed, not built)"; the reason is also in the accessible name | Enter on a live verb emits `person_verb`; only Greet is live today |
| C4 | Reply strip | Text + dismiss | Up to 3 result lines of the last action | Dismiss button, the next action, or close |
| C5 | Inventory / Đạo Đồ / Rankings (the player) | Buttons | Open that window | Yes |
| C5 | Pin or Unpin, Relations, Practice fight, Travel there (another person) | Buttons | Pin follows them in the outliner; Relations opens the relationships page filtered to them; Practice fight opens a preview fight (living non-beasts only); Travel there appears only when they are elsewhere and alive | Yes |

Sections never vanish: an empty one says "none". The Combat section reads the compiled fighter (the same compile as
the practice fight), so it is the sheet a fight uses.

### Information Hierarchy

1. Who and how strong (C2), always in view, and the tab bar to move between pages.
2. For another person: the Interact tab first (attitude, where, what can I do now); then the same sheet as the player's.
3. Growth (Cultivation): the most-asked question each season.
4. Made of (Thiên phú, Linh căn, Vitals, Combat): why the numbers are what they are.
5. Choices (Công pháp, Đạo Đồ), then the record (Gear, Crafts, Fate, Lifespan).

## States & Variants

| State | What changes |
|---|---|
| Normal | As the wireframe |
| Action refused | The session refused a slot change or breakthrough (unusable technique, not at the bottleneck, already slotted, not at the season start): its reason shows in the reply strip and as a Refusal note beside the control for `refusal_seconds` (2 s); the view refreshes from the session after every action, refused or not |
| At great perfection | The Bottleneck block shows in Cultivation; the bar reads "full" when the bar cost is met |
| Realm cap / last realm | Cultivation says "the highest realm" and shows no next-level line; no Bottleneck block |
| Event waiting | Look-only (pattern): Change and Attempt show a lock mark 🔒, are disabled, and their tooltip and accessible name say "locked while an event waits"; reading, scrolling and tooltips stay live |
| A job running | The host does not read; the window keeps its last view and its buttons are disabled |
| Dead (life ended) | The sheet is as at death (the dead keep their record), title marked "(died)"; no actions: the sheet is look-only, and on the Interact tab every verb is greyed with its reason and Practice fight and Travel there are not shown (Pin and Relations stay) |
| Another person (look-only) | Slot Change buttons and the breakthrough are disabled (locked); no cultivation rate or bottleneck block; the Interact tab is first and open |
| Person not met | Attitude reads "not met"; nothing else is hidden |
| Person elsewhere | Where shows their place without "(here)"; every verb greyed "not here: [place]"; Travel there shown. **Not built yet:** the seasons away in the reason and Travel there opening the focus comparison preselected (Open Question 4) |
| Person gone (no record: a stale history entry) | The body says "This window's subject is gone."; the back arrow still works; no error. Dead people are not "gone": they show as died |
| Event waiting, Interact tab | Verbs greyed "locked while an event waits (look only)"; Pin, Relations stay live |
| Missing portrait | `PlaceholderArt` in the frame (see Component Inventory) |

## Interaction Map

| Input | Action |
|---|---|
| C | Open (top) / close |
| Tab / Shift+Tab | Next / previous control; the tab buttons, section headings, tiles, cards and trait chips are focus stops |
| Ctrl+Tab / Ctrl+Shift+Tab | Next / previous tab (wraps; Interact is skipped for the player's own sheet) |
| Enter or click on a tab button | Opens that tab; the chooser and the armed confirm are dropped |
| Home / End | First / last section heading **of the open tab** (a jump to a section on another tab opens that tab first) |
| V (a person's sheet open, focus not in a text field) | Opens Interact and focuses the first live verb |
| Up / Down, wheel, PgUp / PgDn | Scroll the body |
| Q on a focused number | Its tooltip (Nested lockable tooltip) |
| Enter on Change | Opens the inline chooser; Up / Down pick, Enter applies, Esc cancels |
| Enter on Attempt breakthrough | Arms it: the row shows the chance and the risk with [Confirm] and [Cancel], focus on Cancel; Confirm runs it; Cancel or Esc disarms; nothing times out |
| Alt+← / Alt+→, mouse 4 / 5 | Window history |
| Esc | Closes the chooser or disarms first, then closes the window |
| Enter on a live verb (Interact) | Emits the verb request; only Greet is live. A costed or time-taking verb asking a second press: **Not built yet** (Open Question 4) |
| Gamepad A / B, LT / RT | Activate / back; LT / RT = previous / next section heading **within the open tab** (as Home / End). Switching tabs by gamepad: the d-pad focuses a tab button and A opens it; there is no trigger or shoulder binding for it (the shoulders stay with the HUD's window buttons; Open Question 2) |

Every key above is rebindable (hud.md Platform Adaptation); the table lists the defaults.

## Data Requirements

One read, `GameQuery.character(s, person_id)` (ADR-0006: a copy, changes nothing; `person_id` "" or the player's id
is the player), returns every field the window shows, including the Breakdowns (each `{total, lines}`), so the window
never reads the session on hover. For another person it builds the same sheet from their record and their build's stat
sheet (no cultivation rate, bottleneck or slot choices), adds a `person` block from `GameQuery.person` (attitude, band,
met, where, home, ties, recent history, beast flag) for the Interact tab, and the map screen adds `pinned`. The slot
chooser's options (known techniques, usable or not with the reason) are part of the same read. Actions go through the
existing session commands via `session.run`: `set_slot(slot, index, key, confirm)` and `breakthrough(confirm_bare,
use_talisman)`; the window only requests them (signal), the map screen runs the job and refreshes the view. The
Interact tab's requests are UI actions the map screen handles itself (see Events Fired).

**Updates:** the view is read when the window opens, after every job (any action, End turn) and on history steps;
the window never polls and never reads while a job runs.

**A history entry carries its subject** (kind, subject id, section). On Back or Forward the host re-reads it:
- a person who has since died: the sheet shows them as died (the record stays);
- a person with no record any more (`{gone: true}` or an empty read): the window shows "This window's subject is
  gone." and the history arrows still work; the entry is **not skipped**, it stays a step you can move past;
- the player's own entry never goes stale.

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
| Interact: attitude, where, ties, history | NPC Relationships (`GameQuery.person`) | "not met", "none" |
| Interact: verbs | NPC Interaction (`npc-interaction-dialogue.md` rules 8-11) | greyed with a reason |
| Traits | NPC Traits (`GameQuery.traits_view`) | "none yet" |

## Events Fired

- `action_requested("set_slot", [slot, index, key, confirm])`, `action_requested("breakthrough", [confirm_bare, true])`
- `open_requested(kind, subject, section)` for Inventory, Đạo Đồ, Rankings, and a tie's person (`"person"`, their id)
- The Interact tab's UI actions (handled by the map screen, not the session): `person_verb [id, verb]`, `person_pin
  [id, pin_on]`, `person_relations [name]`, `person_fight [id]`, `person_travel [place_id]`
A breakthrough's result also runs the HUD's banner and summary order (hud.md Feedback) through the session events.

## Transitions & Animations

Opens and closes with the host (slides over `motion_fast`; none under reduced motion). The cultivation bar does not
animate in the sheet. No other motion.

## Input Method Completeness Checklist

- [x] Every control reachable by keyboard (Tab order: header, sections top to bottom, action bar)
- [x] Mouse: every control clickable, every number hoverable
- [x] Gamepad: A / B, LT / RT heading jumps within a tab, d-pad focus including the tab buttons (Partial, as the HUD); no trigger binding for switching tabs (Open Question 2)
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
- Tabs: each tab button is a toggle button named with its state ("Overview, selected"; the others just their title).
  **Not built yet:** a tablist / tab / tabpanel role set and an announcement of the panel change on switching (Open
  Question 2).
- Tiles, slot cards and trait chips are focus stops with accessible names ("Căn cốt 54 ...", "Main: [technique], L3/9",
  "[trait], [group]"); the trait's stat lines are in its tooltip. Whether Q opens a chip's or tile's tooltip is the
  generic Q rule of the tooltip layer and is to be verified for these tiles in the manual test (Open Question 6).
- Verbs read their name and the reason they are greyed ("Spar (Luận bàn): not here: [place]").
- The portrait has no accessible name or alt text yet; a placeholder is labelled by the word PLACEHOLDER drawn on it
  only (Open Question 6).

**Dark wood ground.** The body is drawn on dark wood with parchment insets; the text-contrast and 3:1 rules above are
for text on parchment. Text and focus rings that sit directly on the wood (the plaque, tab buttons, portrait frame)
have **not been measured**; the screenshot criterion below requires it (Open Question 6). Element gauges carry the Hán
mark and the number, so they do not rely on colour; whether the colourblind mode covers the new gauge fills is
unchecked (Open Question 6).

## Localization Considerations

Every string through `tr()`; numbers follow the language (HudReadouts); Vietnamese terms stay in Hán-Việt with English
glosses where the HUD already uses them; rows wrap rather than truncate. The target is **40 % longer** than English (the
checklist figure; the earlier 30 % is superseded). Layout-critical strings with a fixed-size home need a maximum
character count: tab labels, trait names (on the tooltip title), Thiên phú and vitals tile labels, the name plaque, slot
card names, verb names. The numbers are not set yet (Open Question 5); until then the rule is "never truncate, wrap or
grow the tile". The Vietnamese verb names already carry a gloss, so they are the longest strings on the Interact tab.

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.character` returns name, standing, age, lifespan, rating, cultivation progress and rate, the
      five element purities, the six talents, the vitals, the combat sheet, the four slots, known techniques, gear,
      crafts, Đạo Đồ counts, fate, and the Breakdowns for rate, lifespan, health, linh lực, thần thức, đan độc, backlash
      and each talent.
- [ ] `[GdUnit]` Calling it leaves `to_dict()` unchanged and creates no rating record for an unrated player.
- [ ] `[GdUnit]` The Bottleneck block is present exactly when the player is at great perfection.
- [ ] `[GdUnit]` The window built from the player's view has four tabs (Overview, Combat, Equipment, Fate & life), no
      Interact tab, and the Overview tab holds the Thiên phú, Cultivation, Traits, Linh căn, Vitals and Công pháp
      headings in that order with a Change button per slot; every section heading of the other tabs is on its tab.
      Choosing a technique in the chooser emits `action_requested("set_slot", ...)` with that key.
- [ ] `[GdUnit]` `CharacterWindow.tab_of(section)` returns the tab in the Entry table for every section; opening with a
      section (Lifespan box, Renown box, bottleneck alert) opens that tab at that section; Ctrl+Tab and Ctrl+Shift+Tab
      step the tabs and wrap, skipping Interact for the player.
- [ ] `[GdUnit]` `GameQuery.character(s, id)` for another person returns the same sheet fields plus the `person` block;
      the same data comes back for a person not met and for one elsewhere (nothing hidden); it leaves `to_dict()` and the
      session RNG unchanged, runs no rating panel and does not add an unmet person to the met list. A dead person's read
      has `alive` false; an id with no record returns `{gone: true}`.
- [ ] `[GdUnit]` A person's sheet opens on Interact with the Verbs, Ties and Recent history sections, slot Change and
      Attempt breakthrough disabled, the action bar showing Pin, Relations, Practice fight and Travel there as the
      Component Inventory says (Practice fight absent for a beast or a dead person; Travel there absent when they are
      here), and each button emitting its `person_*` action.
- [ ] `[GdUnit]` Interact verbs: with the person here and no event waiting, only Greet is enabled and shows "will accept";
      every other verb is greyed with a reason; with the person elsewhere every verb is greyed "not here: [place]"; with
      an event waiting every verb is greyed "locked while an event waits"; a verb's accessible name includes its reason.
- [ ] `[GdUnit]` V on a person's sheet opens Interact and focuses the first live verb; a person's name in another window
      opens their sheet on Interact; back returns to the previous window and the person is re-read.
- [ ] `[GdUnit]` A dead person shows "(died)" in the title and no live verb; an id with no record shows "This window's
      subject is gone." and the back arrow still works; neither raises an error. (From `person.md`.)
- [ ] `[GdUnit]` A person with no ties, history or filled slots shows "none" rows; no section disappears. (From
      `person.md`.)
- [ ] `[GdUnit]` A history entry for a person who has died or been removed is reachable by Back and Forward without an
      error, and the history arrows still step past it.
- [ ] `[GdUnit]` Attempt breakthrough emits nothing on the first press (arms) and `action_requested("breakthrough", ...)`
      on Confirm.
- [ ] `[GdUnit]` Look-only: with an event waiting, Change and Attempt are disabled.
- [ ] `[GdUnit]` The host's back arrow returns to the previous window and forward goes again; opening a new window after
      going back drops the forward entries.
- [ ] `[GdUnit]` A refused action's reason appears in the reply strip, and the view is re-read after the job.
- [ ] `[GdUnit]` The armed breakthrough row names the chance and the qi deviation risk; Cancel disarms without emitting.
- [ ] `[GdUnit]` Opening the sheet (read + build, with the portrait and icon loads) takes under 50 ms on the test world,
      for the player's Overview and for a person's Interact tab with the heaviest trait / tie fixture; switching tab
      (rebuild) is under 50 ms too.
- [ ] `[GdUnit]` A missing portrait builds a `PlaceholderArt` node, not an empty frame or a generic face.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the top of the Overview tab, the Overview scrolled to Công pháp with the
      chooser open, and the Interact tab of a person; the sheet is 62 % wide; nothing clips; text at or above the 16 / 14
      px floor; contrast checked on the shot, including text and focus rings over the dark wood. Retained in
      `production/qa/evidence/`.
- [ ] `[Screenshot]` Each tab (Overview, Combat, Equipment, Fate & life, Interact) at 1280×720 in the compact layout
      shows one column of insets and the header on two lines (numbers line plus tab bar), nothing clipped.
- [ ] `[Screenshot]` 150 % UI scale at 1920×1080, and 75 % at 1280×720: nothing clips.
- [ ] `[Manual]` Keyboard only and mouse only, every control reached (tab buttons, tiles, cards, chips, verbs); reduced
      motion: the panel appears without sliding; NVDA reads the region name, the headings, the selected tab and the
      armed confirm (accessibility test plan).

## Revision: weak-point pass (2026-11-24)

Combat tab (weak-point pass, 2026-11-24, #4): the stats are tiles in groups, Defence (ward points, ward layer,
block, body shield, evade, soul resistance), Offence (crit chance, crit multiplier), Sustain (health regeneration) and
Resistances (typed), at the full width, each with a one-line hint in its tooltip. Units: shares (evade, crit, body
shield) show as %, block, wards and resistances as points (the old table showed block 3.91 as "391 %").

Overview cultivation: tu vi and the rate are one line under the bar ("Tu vi 0 / 39 (0 %) · +7.47 a season here · next
level in 6 seasons"), its tooltip the rate's breakdown.

## Open Questions

Resolved by the round-2 revision: the portrait is the PortraitPicker's, with `PlaceholderArt` when art is missing (the
greybox initial is gone); the player's sheet has no Pin button because the player is always in the outliner, while
another person's sheet has Pin / Unpin on the Interact tab (the "no pin button" line applied to the player only).

1. (Dropped 2026-11-24, UI owner; the user may overrule: no slot change ends a life, so no confirm is needed and the
   chooser applies the change at once.)
2. **Tabs for gamepad and screen reader.** (Decided 2026-11-24, UI owner; the user may overrule: LT / RT step the
   tabs on the character sheet, since the sections inside a tab are short. Not built yet; part of the gamepad pass.)
   The tab buttons still expose a selected state in their name but no tablist / tab / tabpanel roles; that stays open
   for the accessibility pass.
3. (Done 2026-11-24: the library has "Tab bar", "Icon tile", "Slot card", "Trait icon" and "Portrait frame and round
   medallion" entries, and a note that illustrated windows may be wider than the "Side panel with history" third.)
4. **Interact verbs beyond Greet.** Not built: the verb system's per-verb "won't accept" with the score's parts in words,
   the cost and time lines, the second press for a costed verb, "seasons away" in the reason, and Travel there opening the
   focus comparison preselected, as `person.md` specified. All depend on the verb system
   (`npc-interaction-dialogue.md`), which is designed, not built.
5. **Localization maximums.** Character counts for tab labels, trait names, tile labels, the plaque, card names and verb
   names are not set (the layout must be measured at 40 % expansion first). Needs the user's decision on the limits or a
   measured pass.
6. **Accessibility of the illustrated elements, not built or not checked:** an accessible name / alt text for the
   portrait; Q opening the tooltip of a tile, card or trait chip from the keyboard; contrast of text and focus rings on
   the dark wood ground; the colourblind mode over the new gauge fills.
7. (Decided 2026-11-24, UI owner; the user may overrule: right-click on a person's name is kept, as `person.md`
   specified; the V key and the Interact default tab cover it today.)
8. Renown has no sources yet (hud.md): shown as "not tracked yet" in Fate.
