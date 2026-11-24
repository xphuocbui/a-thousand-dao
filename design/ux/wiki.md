# UX Spec: In-Game Wiki

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 5 advisory: applied 2026-11-24); written 2026-11-24
> night by Claude under the UI delegation (memory ui-design-delegated)
> **Illustrated rebuild (user, 2026-11-24)**: the window was rebuilt with pictures: trait medallions and item icons on
> the index and a large framed icon on an entry (`src/ui/windows/wiki_window.gd`, `illustrated.gd`). This spec now
> describes that built window. What the build does not do yet is listed under Open Questions, not specified as built.
> The character sheet (not `design/ux/person.md`, which it supersedes) owns the person window.
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Sources**: `design/ux/hud.md` (element 4 W; Tooltips: "Open in wiki" and highlighted words at the last level),
> memory map-centric-ui ("traits catalogue in an in-game wiki"), `assets/data/ui_terms.json`, `traits.json`,
> `cultivation_realms.json`, `character_elements.json`, `ui_windows.json` tie_kinds, the item data files listed in
> `WikiData.ITEM_GROUPS` (artifact bases, recipes, herbs, materials, talismans, treasures), the painted icons in
> `assets/icons/traits/` and `assets/icons/items/`; the character sheet spec (owner of the person window)
> **Patterns used**: Side panel with history, Searchable list, Link styles, Section jumps. **New pattern, not in
> `design/ux/interaction-patterns.md` yet**: the Illustrated index (a parchment ground with a section per category,
> each entry an icon beside its link) and the Entry header with a large framed icon; to be added to the library.

---

## Purpose & Player Need

"What does this word mean, and what does this trait do?" One place for the game's concepts, built from the game's own
data so it never drifts: the glossary terms the tooltips highlight, every trait (personality, calling, fate, gained)
with its boons and costs, the realms, the five elements and the tie kinds. Every highlighted word in an entry opens its
own entry, like the tooltips' last level. **Scope:** the first slice of hud.md's "Wiki and Codex": terms, traits,
realms, elements and ties; Effects, modifiers, herbs, rules and the Codex come later.

## Player Context on Arrival

From the wiki button in Z1 (element 4) or F1: the index. From a tooltip's "Open in wiki" or a highlighted word at its
last level: that entry (the tooltip chain closes; an open wiki takes it as a new history step; it opens while an event
waits too, being read-only). From a trait in the person window (the character sheet, any person): built through the
tooltip, not a direct link. A trait icon's tooltip carries "Open in wiki" for `trait:<id>` (`Illustrated`, trait
tooltip), so it is the tooltip's route above. There is no separate "open in wiki" control on the sheet itself.

## Navigation Position

A Z6 window of the window host (Side panel with history): entries are history steps (`history_max` 20; Alt+← / →,
mouse 4 / 5, the frame's arrows), so Back returns through what was read; Back is disabled at the first step. Focus goes
to the search field on the index and to the first link of an entry; closing returns focus to the opener. The search
text is kept while the window lives. The header (search on the index; the category and summary on an entry) never
scrolls; section headings are Tab stops; Home / End and LT / RT jump between them.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| W, F1, the game menu's Wiki | the index |
| A tooltip's "Open in wiki", a highlighted word | that entry |

Exits: × / Esc, history, the index link on every entry.

## Layout Specification

### ASCII Wireframe

```
+-------------------------------------------+
| < >  Wiki                             [x] |  W1 frame
| [search the wiki…              ] Ctrl+F   |  W2 sticky header (index) + "n matches"
|-------------------------------------------|
| .--- one parchment ground (W3) -----------. |
| | TERMS (11)                              | |  a section per category
| |  Spirit stones (linh thạch) · Spiritual qi …| |  text links only: terms have no icon
| | PERSONALITY TRAITS (37)                 | |
| |  (o) Brave (dũng mãnh) · (o) Cautious … | |  (o) = 32 px medallion beside its link
| | CALLINGS · FATE · GAINED · REALMS …     | |
| | TIES · ARTIFACTS · PILLS · HERBS …      | |  item sections: 32 px item icon + link
| '-----------------------------------------' |
+-------------------------------------------+

Entry (with art):
| < >  Wiki: Brave (dũng mãnh)          [x] |
| [ 112 px framed icon ]                    |  W2 header: icon, category, summary
| Personality trait · set 1                 |
|-------------------------------------------|
|  Boon: +2 % health                        |
|  Cost: −0.8 % evade                       |
|  Leans: bold, aggressive; less cautious   |
|  Opposed: Cowardly (a link)               |
|  ← Index                                  |
```

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| W2 | Search | LineEdit | Titles and summaries (diacritics folded); on the index matches stay full and the rest are dimmed in place (Searchable list), with "n matches"; 0 matches reads "0 matches" | Ctrl+F, or Tab to it; gamepad: focus it and A opens the on-screen keyboard |
| W3 Index | Parchment ground | Panel (`Illustrated.ground`) | One ground holding every category section | No |
| W3 Index | Category sections | Headings + wrapping flow | Each category with its count (terms, four trait groups, realms, elements, ties, then artifacts, pills, herbs, materials, talismans, treasures); entries as links (title, Vietnamese name) in a wrapping flow, 14 px apart | Links open entries; hover shows the entry's summary as a tooltip |
| W3 Index | Entry icon | 32 px image beside the link | The entry's `icon` (trait medallion or item icon), drawn only when the entry has one; no frame or card around it; not focusable, no alt text of its own (the link carries the name) | No |
| W2 Entry | Entry art | 112 px image (`EntryArt`) at the left of the header | The entry's `icon`, large; drawn only when the entry has one | No |
| W3 Entry | Title and kind | Heading + line | Title, the category word, extra facts (a trait's set, a fate's pair, a gained trait's trigger) | No |
| W3 Entry | Summary and body | Rich text | The authored text; highlighted words are links ([[key\|words]]) | Links |
| W3 Entry | Facts | Rows | A trait's boons and costs as modifiers (the game's stat words), leanings (tags), opposed trait; a fate's rows; a realm's levels; an element's role | Opposed and linked names |
| W3 Entry | Index link | Link | "← Index" | Yes |
| W3 | Unknown entry | Text | "No entry for this word yet." with the index link | Yes |

## States & Variants

| State | What changes |
|---|---|
| Index | The categories on the parchment ground |
| Entry | One entry |
| Entry or index row with art | The icon shows (32 px on the index, 112 px on an entry) |
| Entry or index row without art | No icon and no gap: the row is the link alone, the entry header starts at the category line. Terms, realms, elements and ties have no art by design (their `icon` is "") |
| Entry or index row whose art file is missing | A trait or item whose icon file is absent: `WikiData.item_icon` / `trait_icon` return "placeholder" and the window shows the `PlaceholderArt` stripes in the icon's place (built 2026-11-24; test `ui_wiki_test` `test_an_entry_whose_art_is_missing_asks_for_the_placeholder`) |
| Search active | Matching entries only, "n matches" |
| Unknown key | The unknown line |
| No matches | "0 matches"; every entry dimmed |
| Data missing | A category with no data shows "(none)" |

## Interaction Map

| Input | Action |
|---|---|
| W, F1 | Open the index / close |
| Ctrl+F | Search |
| Tab, Up / Down | Links |
| Enter / click | Open the link |
| Alt+← / → | History |
| Home / End, LT / RT | Section jumps |
| Gamepad d-pad, A, B | Move between links, open, back (close on the index) |
| Esc | Close |

Every key is rebindable (hud.md Platform Adaptation); single-letter keys are off while the search has focus.

## Data Requirements

`WikiData.view(gd, key)` (`src/ui/windows/wiki_data.gd`, owned by the UI; a static reader over the data files; no session state is read, so it can run any time):
the index ({categories: [{id, title, entries: [{key, title, name_vi, summary, icon?}]}]}) or one entry ({key, category,
title, name_vi, summary, body (segments), facts: [lines], links: [{key, title}], icon?}). `icon` is a `res://` path
or "" (absent for terms, realms, elements and ties; set for traits and items only when the painted file exists:
`WikiData.trait_icon`, `item_icon`). Keys: `term:<id>`, `trait:<id>`, `realm:<index>`, `element:<id>`, `tie:<kind>`,
`item:<kind>_<template>`; a bare term id (from a tooltip) resolves to `term:`. Icons are loaded with `Illustrated.tex`
when the window builds the index (up to the number of entries with art, about 170 item icons plus the trait medallions).

## Events Fired

`open_requested("wiki", key)` for every link (one history step each).

## Transitions & Animations

None of its own.

## Input Method Completeness Checklist

- [x] Keyboard: search, every link
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B (Partial)
- [x] No hover-only information

## Accessibility

Text at the 16 px floor (secondary lines 14 px), checked at 75 % and 150 % UI scale; links underlined as well as
coloured (Link styles; the links use the `paper` variant for the parchment ground) and are real focusable controls;
contrast 4.5:1 for link and body text on the parchment (the `paper` link variant is built for it; to be checked in the
screenshot, see Acceptance), focus ring 3:1; boons and costs carry the words "Boon" and "Cost" and the sign; the host's
slide is instant under reduced motion. Screen reader: entries read their title and category; links read their text and
"opens in the wiki"; the icons are decoration (they repeat the link's name), so they carry no label of their own and
the link is the one stop per entry. Focus order on the index is the flow's reading order (left to right, then down,
category by category); the gamepad moves through it with the d-pad like any link list.

## Localization Considerations

Titles carry English and Vietnamese; the authored text goes through `tr()` with its keys; numbers follow the language;
index entries sit in a wrapping flow (an icon beside its link), so a two-name title at +40 % still fits by wrapping
to the next line; the 32 px icon and the 112 px entry art are fixed pixel sizes (scaled with the UI scale, not with
the text), and the entry summary wraps by word.

## Acceptance Criteria

- [ ] `[GdUnit]` The index lists every term, every trait of the four groups, the five realms, the five elements and the
      tie kinds, with counts matching the data files.
- [ ] `[GdUnit]` A trait entry shows its boons and costs as the game's modifier text, its leanings and its opposed trait.
- [ ] `[GdUnit]` A term's highlighted words become links to their entries; a bare id resolves to `term:`.
- [ ] `[GdUnit]` Search over the index keeps only matching entries (diacritics folded).
- [ ] `[GdUnit]` An unknown key shows the unknown line.
- [ ] `[GdUnit]` Opening a highlighted word adds a history step; Back returns to the entry before.
- [ ] `[GdUnit]` The index (read + build) builds in under 100 ms.
- [ ] `[GdUnit]` `WikiData.view` entries for a trait and an item with a painted file carry a non-empty `icon`; a term,
      a realm, an element and a tie carry none.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the index (sections with icons and sections without) and a trait entry
      with its large icon; nothing clips; link text on the parchment reads at 4.5:1.
- [ ] `[Screenshot]` An entry without art (a term or a realm): the header starts at the category line, no empty gap.
- [ ] `[Screenshot]` An item entry with its large icon (a herb or a pill), kept in `production/qa/evidence/`.
- [ ] `[Perf]` Opening the index with every icon loaded stays under 100 ms of build time on the target PC (the
      icon-bearing index, not only the text index); to be measured.

## Open Questions

1. Authored entries exist for 11 terms; traits, realms and elements read from their data (no flavour text yet).
2. (Decided 2026-11-24, UI owner; the user may overrule: keep the flat flow of icon + link, as built; no card per
   entry. The window's doc comment was corrected to say so.)
3. (Closed 2026-11-24: `WikiData.item_icon` / `trait_icon` return "placeholder" when the art file is missing and the
   window shows the `PlaceholderArt` stripes; entries that never have art carry "" and show no icon.)
4. **Gamepad search** is still "focus it and A opens the on-screen keyboard"; the order from the search field into the
   flow of icon links is the reading order and has not been tested with a pad.
5. **Screen-reader labels for icons** are not set (the link names the entry); confirm that is enough, or add a label.
6. (Done 2026-11-24: the library covers the icon index through its "Icon tile", "Trait icon" and "Portrait frame"
   entries; the wiki's flat icon-plus-link flow needs none of its own.)
7. The index is not yet checked for load time with every icon (see Acceptance).
