# UX Spec: In-Game Wiki

> **Status**: In Review, lean round 1 NEEDS REVISION (4 blocking, 7 advisory: applied 2026-11-24); written 2026-11-24
> night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **Sources**: `design/ux/hud.md` (element 4 W; Tooltips: "Open in wiki" and highlighted words at the last level),
> memory map-centric-ui ("traits catalogue in an in-game wiki"), `assets/data/ui_terms.json`, `traits.json`,
> `cultivation_realms.json`, `character_elements.json`, `ui_windows.json` tie_kinds
> **Patterns used**: Side panel with history, Searchable list, Link styles, Section jumps.

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
waits too, being read-only). From a trait row in the person window: deferred.

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
| [search the wiki…              ] Ctrl+F   |  W2 sticky header (index)
|-------------------------------------------|
| TERMS (11)                                |  W3 body
|  Spirit stones (linh thạch) · Spiritual qi …|
| PERSONALITY TRAITS (37)                   |
|  Brave (dũng mãnh) · Cautious …           |
| CALLINGS (14) · FATE (10) · GAINED (16)   |
| REALMS (5) · ELEMENTS (5) · TIES (11)     |
+-------------------------------------------+

Entry:
| < >  Wiki: Brave (dũng mãnh)          [x] |
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
| W3 Index | Category sections | Headings + link rows | Each category with its count; entries as links (title, Vietnamese name) | Links open entries |
| W3 Entry | Title and kind | Heading + line | Title, the category word, extra facts (a trait's set, a fate's pair, a gained trait's trigger) | No |
| W3 Entry | Summary and body | Rich text | The authored text; highlighted words are links ([[key\|words]]) | Links |
| W3 Entry | Facts | Rows | A trait's boons and costs as modifiers (the game's stat words), leanings (tags), opposed trait; a fate's rows; a realm's levels; an element's role | Opposed and linked names |
| W3 Entry | Index link | Link | "← Index" | Yes |
| W3 | Unknown entry | Text | "No entry for this word yet." with the index link | Yes |

## States & Variants

| State | What changes |
|---|---|
| Index | The categories |
| Entry | One entry |
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
the index ({categories: [{id, title, entries: [{key, title, name_vi, summary}]}]}) or one entry ({key, category,
title, name_vi, summary, body (segments), facts: [lines], links: [{key, title}]}). Keys: `term:<id>`, `trait:<id>`,
`realm:<index>`, `element:<id>`, `tie:<kind>`; a bare term id (from a tooltip) resolves to `term:`.

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
coloured (Link styles) and are real focusable controls; contrast 4.5:1, focus ring 3:1; boons and costs carry the
words "Boon" and "Cost" and the sign; the host's slide is instant under reduced motion. Screen reader: entries
read their title and category; links read their text and "opens in the wiki".

## Localization Considerations

Titles carry English and Vietnamese; the authored text goes through `tr()` with its keys; numbers follow the language;
index links wrap in a flow (a two-name title at +40 % still fits by wrapping).

## Acceptance Criteria

- [ ] `[GdUnit]` The index lists every term, every trait of the four groups, the five realms, the five elements and the
      tie kinds, with counts matching the data files.
- [ ] `[GdUnit]` A trait entry shows its boons and costs as the game's modifier text, its leanings and its opposed trait.
- [ ] `[GdUnit]` A term's highlighted words become links to their entries; a bare id resolves to `term:`.
- [ ] `[GdUnit]` Search over the index keeps only matching entries (diacritics folded).
- [ ] `[GdUnit]` An unknown key shows the unknown line.
- [ ] `[GdUnit]` Opening a highlighted word adds a history step; Back returns to the entry before.
- [ ] `[GdUnit]` The index (read + build) builds in under 100 ms.
- [ ] `[Screenshot]` 1280×720 and 1920×1080: the index and a trait entry; nothing clips.

## Open Questions

- Authored entries exist for 11 terms; traits, realms and elements read from their data (no flavour text yet).
- The wiki has no pictures (art budget).
