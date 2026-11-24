# UX Spec: Relationships Page

> **Status**: In Review, lean round 1 NEEDS REVISION (3 blocking, 8 advisory: all applied 2026-11-24); written
> 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/npc-relationships.md` (UI Requirements; rules 1, 1b, 5, 6, 7, 15c; Visual/Audio: glyphs and
> bands), `design/ux/person.md` (the person window links here; tie kinds in Vietnamese and English)
> **Patterns used**: Side panel with history, Sticky header and pinned action bar, Section jumps, Searchable list
> (sort and filter chips), Link styles, Nested lockable tooltip.

---

## Purpose & Player Need

"Who am I bound to, who owes whom, who wants me dead, and what happens if I make one more friend?" Every tie the
player holds, with its kind, strength band, direction and cause, the cap and who would be pushed out next; then the
people the player has met but holds no tie with, with their attitude. The page is read-only: ties change through
verbs, events and fights, never here.

## Player Context on Arrival

From the Relationships button (Z2) or R; from the person window's "Relations" action (person.md P5); from the character
sheet (later). Usually after an event that formed or broke a tie, or before a fight to see who might help.

## Navigation Position

A Z6 window of the window host. A partner's name opens their person window (one history step; back returns here).

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Relationships button, R | the top, sort and chips as last left |
| Person window "Relations" | the top, every group chip back on (All), the search filled with that person's name; the search then stays until cleared |

Exits: × / Esc, history, a partner's name (their person window), the action bar (Character).

## Layout Specification

### ASCII Wireframe

```
+-------------------------------------------+
| < >  Relationships                    [x] |  R1 frame
| Ties 5 / 16 (+1 outside) · Soft slots 3 / 12 |  R2 sticky header
| Room for 9 more soft ties or debts.       |
| [search…] Sort: [Kind ▾]                  |
| (All)(Pinned)(Soft)(Debts)(Feuds)         |
|-------------------------------------------|
| PINNED (2)                                |  R3 body
|  ✎ Sư đồ · master   Trần Vân   Trúc Cơ    |
|     at Thanh Vân Tông · warm +18          |
|  ⚭ Đạo lữ           Mai Linh   Luyện Khí  |
| FEUDS (1)                                 |
|  🗡 Huyết thù · toward you · does not fade  Hắc Sát  (inherited: your master was slain)
|  ☁ Thù hận · toward them · firm ││ ; toward you · deep │││  Hắc Sát
| SOFT AND DEBTS (2)                        |
|  ⚔ Rival · firm      Lý Hàn               |
|  ✋ Ân tình · you owe · faint  Bà Tư        |
| MET, NO TIE (12)                          |
|  Ngô Đức  Luyện Khí  neutral +2           |
|-------------------------------------------|
| [Character]                               |  R5 action bar
+-------------------------------------------+
```

### Layout Zones

| Zone | Holds | Scrolls |
|---|---|---|
| R1 Frame | Back, forward, title, close | No |
| R2 Sticky header | The cap line, the next eviction, search, sort, group chips | No |
| R3 Body | Pinned; Feuds; Soft and debts; Met, no tie. Each group sorted by the sort | Yes |
| R5 Action bar | Character | No |

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| R2 | Cap line | Text | "Ties 5 / 16" (Ties.cap; notable or ordinary), "+n outside the cap" (overflow pinned, mourner enmity), and **"Soft slots n / limit"** (rule 15c: soft-only records used out of `Ties.soft_limit`) | Tooltip: rule 5 (pinned never evicted; soft and debts compete) |
| R2 | Next eviction | Text | **Only when the soft slots are full**: the record rule 7 would evict next (weakest, then oldest, then lower id): partner, kind, band; otherwise "Room for n more soft ties or debts." | Tooltip: rule 7 |
| R2 | Search | LineEdit | Partner names (diacritics folded); matches outlined, others dimmed | Ctrl+F |
| R2 | Sort | Option | Kind (default), Strength, Name, Realm | Yes; persists for the screen |
| R2 | Group chips | Toggles | Pinned, Feuds, Soft and debts, Met no tie | Yes; persist; a filtered group keeps its heading with "hidden by the filter" (sections never vanish) |
| R3 | Tie row | Rows | **Glyph** per kind (GDD Visual: kin 家, sư đồ ✎, kết nghĩa 🍶, đạo lữ ⚭, companion 🚶, friend ☺, rival ⚔, ân tình ✋, enmity ☁, blood feud 🗡; a glyph, never colour alone), the kind in Vietnamese and English, the **band** (faint / firm / deep for strength 1–33 / 34–66 / 67–100) with one to three strokes (│ ││ │││, GDD Visual/Audio) for soft ties and debts, the **direction** (toward you / toward them; you owe / they owe); **enmity shows each direction with its own band** ("toward them · firm ││; toward you · deep │││"); a blood feud shows each direction held, marked "does not fade" (a pinned kind has no strength), the partner's name (person link), realm, where they are, their attitude band | The name opens their window; hover / Q: the tie tooltip (strength as a number, cause, when set, inherited from whom) |
| R3 | Favour block | Text + tooltip | "favour owed: <caller>" on a sworn sibling's row; the tooltip carries rule 15c's block: the state (**awaiting call-in**, presented, accepted), the call-in's timing (within `favour_call_seasons` of the join, or the first reachable season), what refusing costs (a slight: friend −`refuse_delta`, or enmity +`refuse_delta`), that abandoning an accepted task is a slight too, and the optional `favour_cost` in linh thạch that clears it. The tie record stores only the caller, so the state shows "awaiting call-in" with "presented and accepted are not recorded yet" until the call-in event stores it | Tooltip |
| R3 | Inherited mark | Text | "(inherited: cause)" on a feud or enmity passed down (rule 1b) | Tooltip |
| R3 | Met row | Rows | A met person with no tie: name, realm, place, attitude band and number | Name opens their window |
| R3 | Empty group | Text | "none" | No |

### Information Hierarchy

1. Danger and duty: blood feuds toward the player first among feuds, favours owed.
2. The pinned bonds (they give the build hooks).
3. Soft ties and debts with their bands, and the eviction line.
4. The met list (who could become a tie).

## States & Variants

| State | What changes |
|---|---|
| Normal | As the wireframe |
| No ties | "You hold no ties yet." above the met list |
| Full | The eviction line names the next record; "room for 0 more" |
| Partner dead | The row keeps the tie (inherited ties live on the heir); a "†" mark and "died" |
| Search active | Matches outlined, others dimmed; "n of m match" |
| Event waiting | Nothing to lock (the page has no actions) |

## Interaction Map

| Input | Action |
|---|---|
| R | Open / close |
| Ctrl+F | Search |
| Up / Down, Tab | Rows and names |
| Enter / click on a name | Open that person's window |
| Q on a row | The tie tooltip |
| Home / End, LT / RT | Section jumps |
| Esc | Close |

Tab lands on section headings and rows; Home / End go to the first and last heading; LT / RT jump sections. R, Q
and other single-letter keys are off while the search field has focus (IME-safe).

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

One read, `GameQuery.relationships(s)`: {cap, held, outside_cap, room, next_evict: {partner, kind, band} or {},
ties: [{partner_id, partner, realm, place, attitude, band_word, alive, group (pinned / feud / soft), kinds: [{kind,
label_vi, label_en, glyph, band, strength, direction, inherited, cause, set_season}], favour}], met: [{id, name,
realm, place, attitude, band_word}]}, a copy, built with `Ties` read functions (`ties_of`, `cap`, `soft_only`,
`room`, `soft_s`, `debt_s`), which never write (GDD rule 3). Re-read on open and after every job.

## Events Fired

`open_requested("person", partner_id)`, `open_requested("character")`.

## Transitions & Animations

None of its own; the host's slide becomes instant under reduced motion.

## Input Method Completeness Checklist

- [x] Keyboard: rows, names, sort and chips reachable; Ctrl+F
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B, LT / RT (Partial)
- [x] No hover-only information: Q opens the tie tooltip; bands and directions are in the row text

## Accessibility

Text at the 16 px floor (tooltips 14 px), checked at 75 % and 150 % UI scale; text contrast at least 4.5:1, glyphs and
the focus ring 3:1; kind by glyph and words, warm or cold tint only as a backup; bands in words and strokes;
directions in words; the attitude shows its band word beside the number ("warm +18"). Screen reader: a row reads "Huyết thù, blood feud, toward you, does not fade, inherited: your
master was slain, Hắc Sát"; an enmity row reads both directions with their bands; the cap line and eviction line read as text; the search count is a polite live region.

## Localization Considerations

Kind names in Vietnamese and English (the longest, "Dao companion / Đạo lữ", "blood feud / Huyết thù", fit at the base
font by wrapping); numbers follow the language; names wrap, never truncate (30 % longer text still fits by wrapping).
A partner whose record is gone shows the tie with their id and "(record gone)".

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.relationships` returns every tie record of the player with its kinds, band, direction,
      inherited mark and cause; the cap, held and outside-cap counts match `Ties`; it leaves `to_dict()` unchanged.
- [ ] `[GdUnit]` The next eviction is the record `Ties.room` would evict (when full) and "room for n" otherwise.
- [ ] `[GdUnit]` Groups come in the order Pinned, Feuds, Soft and debts, Met no tie; a group chip hides its group.
- [ ] `[GdUnit]` Sorting by Strength orders soft rows by strength, strongest first.
- [ ] `[GdUnit]` A partner's name emits `open_requested("person", id)`.
- [ ] `[GdUnit]` Every tie row's accessible name has the kind's words, the band and the direction (never colour alone).
- [ ] `[GdUnit]` The header shows "Soft slots n / limit" from `Ties`; the eviction line appears only when the soft slots are full.
- [ ] `[GdUnit]` An enmity held both ways shows both directions with their bands; a feud row says "does not fade".
- [ ] `[GdUnit]` A sworn sibling's favour row carries the favour block (state, refuse cost, buy-off cost).
- [ ] `[GdUnit]` The Relations entry turns every group back on and fills the search.
- [ ] `[GdUnit]` The read and build take under 50 ms for 16 ties and 200 met people (headless test machine).
- [ ] `[Screenshot]` 1280×720 and 1920×1080; nothing clips; and at 150 % and 75 % UI scale.

## Open Questions

- Glyphs are text placeholders until the §7.1 dark-tile icons are painted (art budget).
- Favour states (presented, accepted) are not stored in the tie record yet: the favour block says so and shows
  "awaiting call-in"; the call-in event (Event Engine) should store the state on the record.
- The character screen's own relationships section (GDD: "on the player's character screen") is this window, opened
  from the character sheet's action bar in a later pass (the bar holds 3 of 4 buttons now).
