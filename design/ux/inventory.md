# UX Spec: Inventory

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 3 advisory: applied 2026-11-24); written
> 2026-11-23 night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **2026-11-24 note**: the window was rebuilt in the illustrated style (user 2026-11-24, `illustrated.gd`): a wood
> ground, one parchment inset per kind, and each row has a 56 px icon tile framed in the item's rarity colour with an
> "×N" quantity badge. This spec now describes that build. Evidence: `production/qa/evidence/ui-windows/22-inventory-illustrated-1920x1080.png`
> (older: 20 and 21, and `compact-1280/inventory.png`, show the text-only rows).
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/item-database.md` (kinds, rarity ladder rule 7, equipping rule 11, named items rule 20,
> item arts rule 21: the icons of the row tile), `cong-phap.md` (learning a manual, rule 4), `design/ux/hud.md` (element 2 opens it; element 5 I)
> **Patterns used**: Side panel with history, Sticky header and pinned action bar, Searchable list, Item tooltip,
> Inline chooser, Confirm in place, Reply strip, Look-only lock, Link styles.

---

## Purpose & Player Need

"What do I carry, what is it worth to my build, and what can I do with it now?" One list of everything the player
owns, grouped by kind, searchable, with the item tooltip's comparison against what is equipped, and the item verbs the
game already has: equip (into a chosen slot), unequip, nurture, eat a pill or use a treasure, read a manual. Trading
belongs to the market (a later trade window); crafting to the crafting screens.

## Player Context on Arrival

From the linh thạch box (hud.md element 2: "click: inventory"), the Inventory button (Z2) or I; from the character
sheet's action bar. Usually between seasons, after loot or a purchase, or while planning a build.

## Navigation Position

A Z6 window of the window host (history, focus return), like the character sheet. An item's own window does not exist:
an item is shown by its tooltip and its expanded row.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Linh thạch box, Inventory button, I, character sheet action bar | the top, search empty, filters as last left |

Exits: × / Esc (an open chooser or armed confirm first), the window history, the action bar (Character).

## Layout Specification

### ASCII Wireframe

```
+-------------------------------------------+
| < >  Inventory                        [x] |  I1 frame
| Linh thạch 1,240 · Gear 3 of 5 base, 1 of 2 extra
| [search…                    ] Ctrl+F      |  I2 sticky header
| (All)(Pháp bảo)(Công pháp)(Đan dược)(Bảo vật)(Phù lục)(Linh thảo)(Tài liệu)
|-------------------------------------------|  wood ground (I3 body, scrolls)
| +---------------------------------------+ |
| | PHÁP BẢO (4)                          | |  parchment inset per kind
| | [icon] Thanh Phong Kiếm · Trung · ATK 42 [weapon]
| | [tile]   ▸ Unequip  Nurture           | |  (expanded row)
| | [icon] Hắc Thiết Giáp · Hạ · DEF 18   | |
| +---------------------------------------+ |
| | CÔNG PHÁP (1)                         | |
| | [icon] Bạch Kim Bí Điển · Thượng · main · known
| +---------------------------------------+ |
| | ĐAN DƯỢC (2)                          | |
| | [icon ×3] Tụ Khí Đan · Hạ · x3 (phẩm 1)
| +---------------------------------------+ |
|-------------------------------------------|
| reply strip                               |  I4
| [Character]                               |  I5 action bar
+-------------------------------------------+
```

### Layout Zones

| Zone | Holds | Scrolls |
|---|---|---|
| I1 Frame | Back, forward, title, close | No |
| I2 Sticky header | Linh thạch; gear slots used (base and extra, EquipSlots); the search field; the kind chips | No |
| I3 Body | A wood ground holding one parchment inset per kind, in a fixed order: Pháp bảo, Công pháp, Đan dược, Bảo vật, Phù lục, Linh thảo, Tài liệu; each inset has its heading and its rows, sorted equipped first, then rarity high to low, then name | Yes |
| I4 Reply strip | The result of the last item action (3 lines, dismiss) | No |
| I5 Action bar | Character | No |

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| I2 | Linh thạch | Number | Held, grouped digits | Tooltip: "the only money" |
| I2 | Gear slots | Text | "Gear 3 of 5 base, 1 of 2 extra" (and "⚠ 1 unslotted" when an extra piece has no room) | Tooltip: the slot rule (item-database rule 11): base slots 1 weapon, 1 armour, 2 rings, 1 necklace; extra slots by realm plus `artifact_slots`; equipping costs no thần thức; a piece past the extra count stays equipped but adds nothing |
| I2 | Search | LineEdit | Matches names and kind words; matching rows are outlined, the rest dimmed (Searchable list: highlight in place) | Ctrl+F focuses; IME-safe |
| I2 | Kind chips | Toggle buttons | All, then one per kind present; off chips are dimmed and unpressed | Yes; the choice persists for this screen across opens (Searchable list); there is no sort control: the kind sections and the fixed order within them are the sort |
| I3 | Section heading | Gilt caps + count | Kind name in Vietnamese with the count | Focus stop (Section jumps) |
| I3 | Icon tile | Picture in a frame | A 56 px square tile left of every row (the row's height is the tile's, so rows without art keep the same height): the item's icon (`icon` from the read: a named item's own icon, else by kind and template or element) on a dark ground (#1B120C) in a 2 px frame of the item's rarity colour; when `qty` is above 1 an "×N" badge sits at its bottom right (bone colour, black outline). **Decorative**: it has no accessible name and no tab stop; the row button's name and text carry the item, its rarity word and its count. The tile is part of the row, so it takes the row's hover tooltip only through the button. Item arts are item-database.md rule 21 | No |
| I3 | Item row | Button row | Name in its rarity colour plus the **rarity word** (Phàm, Hạ, Trung, Thượng, Cực, Thánh: item-database.md Formulas A, Open Question 13 closed; art bible: "the rarity word always shows"), the kind's key fact (ATK / DEF for pháp bảo, kind and known for công pháp, count and phẩm for pills and talismans, age and element for herbs, count for materials), marks in words: "[weapon]" when equipped, "known", "⚠ unslotted (adds nothing)" | Hover / Q: item tooltip; Enter / click: expand its verbs |
| I3 | Expanded verbs | Buttons | The verbs this item has now (below); greyed with the reason when not possible | Yes |
| I3 | Slot chooser | Inline chooser | For Equip: the slots the piece fits (weapon, armour, ring ×2, necklace, extra), each with "free" or the piece it would displace; a free slot equips at once, an occupied one arms "Replace <piece>? [Confirm] [Cancel]" | Yes |
| I3 | Element chooser | Inline chooser | For a treasure that asks for an element (a Linh Căn Quả): the options the session gives, with their preview lines | Yes |
| I3 | Empty kind | Text | "none" under a kind with no items when its chip is the only one on | No |
| Tooltip | Item tooltip | Overlay | Header: the name and the rarity word; **comparison first**: for a pháp bảo not equipped, the equipped piece in a slot it fits, with ATK and DEF deltas (▲ / ▼ and the number); then the kind and base properties (the row's fact), then the full item text (affix lines included); Ctrl+C on a focused row copies the item text. **Deviations**: no Alt advanced view (tiers and roll ranges are not in the item text yet), no requirement or flavour sections (the records have none) | Lockable (Nested lockable tooltip) |
| I5 | Character | Button | Opens the character sheet (the only action-bar entry; the character sheet's own action bar lists Inventory) | Yes |

The inventory is the player's own: `GameQuery.inventory(s)` reads the session's player, so Inventory never opens for
another person (their gear is shown on their character sheet, if at all).

**Verbs by kind** (only commands the session already has; item-database.md and cong-phap.md):

| Kind | Verbs |
|---|---|
| Pháp bảo (artifact) | Equip… (slot chooser; Replace confirm on an occupied slot) / Unequip (at once: reversible); Nurture (equipped only) |
| Công pháp (manual) | Read (learn) when not known; "known" otherwise |
| Đan dược (pill) | Eat (confirm in place: "Eat 1 Tụ Khí Đan? +toxicity") |
| Bảo vật (treasure) | Use (confirm in place; may ask for an element) |
| Phù lục (talisman) | none: used automatically (shown as a note) |
| Linh thảo, Tài liệu | none here: crafting uses them (a note names the screen) |

### Information Hierarchy

1. What is equipped and what it does (equipped rows first, tooltips).
2. What could replace it (comparison in the tooltip).
3. Consumables and their verbs; then materials as a count.

## States & Variants

| State | What changes |
|---|---|
| Normal | As the wireframe |
| Search active | Matches outlined, others dimmed; "n of m match" under the field |
| Row expanded | Its verbs row below it; only one row expanded at a time |
| Chooser open | Slot or element chooser under the row; Esc closes it first |
| Replace armed | "Replace <piece>?" [Confirm] [Cancel] under the chooser |
| Unslotted piece | Its row says "⚠ unslotted (adds nothing)"; unequipping another extra piece frees a slot for it after the re-read |
| Confirm armed | "Eat 1 …?" [Confirm] [Cancel] under the row |
| Action refused | The session's reason in the reply strip; the view re-reads after every action |
| Event waiting | Look-only: verbs disabled with 🔒 and "locked while an event waits"; search, chips and tooltips stay live |
| Empty inventory | "You carry nothing yet." and the linh thạch line |
| Missing icon | The tile shows `PlaceholderArt` (magenta-and-ink stripes) inside the rarity frame, and its tooltip reads "PLACEHOLDER: No icon painted for this item yet." (built 2026-11-24, per `.claude/rules/ui-code.md`; `_item_row` uses it when `Illustrated.tex` returns null) |

## Interaction Map

| Input | Action |
|---|---|
| I | Open / close |
| Ctrl+F | Focus the search |
| Up / Down | Move between rows (and verbs when expanded) |
| Enter / click on a row | Expand or collapse its verbs |
| Q on a row | Its item tooltip |
| Esc | Close chooser / disarm, then collapse the row, then close the window |
| Home / End, LT / RT | First / last section heading; previous / next section |
| Gamepad A / B | Activate / back |

Every key is rebindable (hud.md Platform Adaptation); the table lists the defaults. Single-letter hotkeys are off while
the search field has focus.

**Focus order:** the frame, the search field, the chips, then the body rows top to bottom, then the action bar. On open
focus goes to the search field. After a chooser or confirm closes, focus returns to its row. The mouse alone does
everything: rows, verbs, choosers and confirms are clickable, and tooltips lock by any of the three lock modes.
Z2's Inventory button has no badge (hud.md element 5 lists badges for unspent points and unread news only).

## Data Requirements

One read, `GameQuery.inventory(s)`: {stones, gear: {base_used, base_total, extra_used, extra_limit, unslotted},
items: [{id, kind, name, rarity, text, fact (the row's key fact), icon (res:// path, "" when none), qty, equipped, slot,
known, fits: [slots], displaces: {slot: item name}, compare: [{label, mine, equipped, against (the equipped piece's name)}],
verbs: [{id, label, reason}]}]}; a copy, changes nothing. Verbs run the existing
session commands through `session.run` as jobs: `equip(item_id, slot)`, `unequip(item_id)`, `nurture(item_id)`,
`use_item(item_id, element)`, `learn(item_id)`. A `use_item` answer with `needs_element` opens the element chooser with
its `options` and preview lines. The view is read on open, after every job and on End turn; never on hover.

| Data | Owning system |
|---|---|
| Items, rarity, text | Item Database (`ItemRarity`, `ItemFactory.describe`) |
| Gear slots | Item Database rule 11 (`EquipSlots.assign`) |
| Known techniques | Công Pháp |

## Events Fired

`action_requested("equip" | "unequip" | "nurture" | "use_item" | "learn", args)`, `open_requested("character")`.

## Transitions & Animations

None of its own (the host's open); rows expand at once.

## Input Method Completeness Checklist

- [x] Keyboard: every row, verb and chip in Tab / arrow order; Ctrl+F
- [x] Mouse: everything clickable; hover tooltips
- [x] Gamepad: A / B, d-pad, LT / RT (Partial)
- [x] No hover-only information: Q opens the item tooltip

## Accessibility

Text at the 16 px floor, tooltip detail at 14 px (`design/accessibility-requirements.md`). Rarity is a word as well as
a colour (the colourblind audit's backup); the icon tile is decorative (no accessible name; the row's name says everything it shows); the rarity-coloured frame is never the only carrier of rarity; equipped, known and unslotted are words, never colour; the dimmed-by-search rows
keep 4.5:1 text contrast (dimming lowers to no less than that); the comparison uses ▲ / ▼ with the number and reads "attack up 6". Screen reader:
rows read "Thanh Phong Kiếm, pháp bảo, Trung, attack 42, equipped as weapon" (or "..., unslotted, adds nothing"); verbs by their text; the search count is
a polite live region; the reply strip is announced politely.

## Localization Considerations

Kind names in Vietnamese with English in tooltips; numbers follow the language; names wrap; the search folds diacritics
(WorldDB.fold) so "thanh phong" finds "Thanh Phong".

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.inventory` lists every item the player owns except planted herbs, with kind, rarity, text,
      equipped slot and verbs; it leaves `to_dict()` unchanged.
- [ ] `[GdUnit]` Sections come in the fixed kind order; equipped rows first within Pháp bảo.
- [ ] `[GdUnit]` Search outlines matches and dims the rest, folding diacritics; a kind chip hides other kinds.
- [ ] `[GdUnit]` Equip opens the slot chooser with only fitting slots; a free slot emits `action_requested("equip", [id, slot])` at once;
      an occupied slot arms "Replace …?" and only Confirm emits.
- [ ] `[GdUnit]` Unequip emits `unequip`; Nurture shows only on equipped pieces; Read emits `learn` and is greyed "you already know it" for a known manual.
- [ ] `[GdUnit]` An equipped piece past the extra count shows "unslotted" in its row and accessible name.
- [ ] `[GdUnit]` Esc order: chooser, then the expanded row, then the window.
- [ ] `[GdUnit]` An empty inventory shows "You carry nothing yet."
- [ ] `[GdUnit]` Eat arms first; Confirm emits `use_item`; Cancel emits nothing.
- [ ] `[GdUnit]` A `needs_element` answer opens the element chooser; picking emits `use_item` with that element.
- [ ] `[GdUnit]` Look-only disables every verb with a reason in its accessible name.
- [ ] `[GdUnit]` The read and build take under 50 ms for 200 items (the test machine, a headless run).
- [ ] `[Screenshot]` 1280×720 and 1920×1080 with items of several kinds, one row expanded; nothing clips; and at 150 % UI
      scale (1920×1080) and 75 % (1280×720). Include a row with no icon file: its height equals the others'.
- [ ] `[Screenshot]` Icon tile contrast: each rarity frame colour against the tile ground (#1B120C) reaches 3:1 (non-text
      contrast), measured from the rarity colours in `LinkStyle`; the "×N" badge is legible on a bright icon.
- [ ] `[GdUnit]` Every item row has an icon tile of 56 px; a row with qty above 1 has a "×N" badge, one with qty 1 has none.
- [ ] `[GdUnit]` A row whose icon is missing shows `PlaceholderArt` in the tile (built; the test is not written yet).
- [ ] `[GdUnit]` The "×N" badge is 16 px.

## Open Questions

- Rarity words come from item-database.md Formulas A (closed Open Question 13); the window's table is
  `ui_windows.json` `rarity_words` until the item data carries them.
- Selling and buying belong to the trade window (market), not designed yet.
1. (Closed 2026-11-24: item icons exist for the 171 named items and by kind and template or element; rows carry them.)
2. Item tooltip: each comparison line reads "<label> <mine> ▲ +d (vs <equipped piece's name>)"; the "vs" wording is in
   the code (`_item_tip`) and is the spec's wording from now on.
3. Icon tile size at 75 % and 150 % UI scale: the 56 px tile and the 8 px gap are fixed numbers in the window code
   (`_item_row`), not read from `UiScale`; whether the window's own scaling already grows them is not verified.
   Decide, then check in the screenshot criterion.
4. (Closed 2026-11-24: a missing item icon shows `PlaceholderArt` in the 56 px tile with a PLACEHOLDER tooltip,
   `inventory_window.gd` `_item_row`.)
5. (Closed 2026-11-24: the "×N" badge is 16 px, raised to the floor with no exemption.)
6. (Closed 2026-11-24: the library has a "Rarity-framed item tile" entry, and an "Icon tile" entry for the stat tile.)
