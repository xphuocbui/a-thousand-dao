# UX Spec: Relationships Page

> **Status**: In Review, lean round 2 NEEDS REVISION (3 blocking, 3 advisory: applied 2026-11-24); round 1 was 3
> blocking, 8 advisory, all applied 2026-11-24. Written 2026-11-24 night by Claude under the UI delegation (memory
> ui-design-delegated)
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/npc-relationships.md` (UI Requirements; rules 1, 1b, 5, 6, 7, 15c; Visual/Audio: glyphs and
> bands), `design/ux/character-sheet.md` (the sheet opens this page from its Interact tab; `design/ux/person.md` is
> superseded by the sheet, its tie kind names in Vietnamese and English still apply)
> **Patterns used**: Side panel with history, Sticky header and pinned action bar, Section jumps (not built, see Open
> Question 5), Searchable list (sort and filter chips), Link styles, Nested lockable tooltip.
> **New patterns (not in `design/ux/interaction-patterns.md` yet, to add to the library)**: person card, portrait
> medallion, parchment inset (the group box), tie badge (pill).
> **Illustrated (user 2026-11-24: "the character list, show the character and some info of the char")**: each person
> is a card on the dark wood ground (see Layout Specification for what a card holds). Width 62 % of the screen.
> Evidence `production/qa/evidence/ui-windows/32-relationships-illustrated-1920x1080.png` (the `--relationships-fixture`
> shot: real people, sample ties). Only the 1920×1080 shot is retained so far (see Acceptance Criteria).

---

## Purpose & Player Need

"Who am I bound to, who owes whom, who wants me dead, and what happens if I make one more friend?" Every tie the
player holds, with its kind, strength band, direction and cause, the cap and who would be pushed out next; then the
people the player has met but holds no tie with, with their attitude. The page is read-only: ties change through
verbs, events and fights, never here.

## Player Context on Arrival

From the Relationships button (Z2) or R; from the "Relations" button on the character sheet's Interact tab (the sheet
shows any person, so this works for everyone). Usually after an event that formed or broke a tie, or before a fight to
see who might help.

## Navigation Position

A Z6 window of the window host. A partner's name opens the character sheet with that person as its subject (the
player's own name opens the player's own sheet); the host's history arrows return here.

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Relationships button, R | the top, sort and chips as last left |
| Character sheet, Interact tab, "Relations" button (about another person) | the top, every group chip back on (All), the search filled with that person's name; the search then stays until cleared |

Exits: × / Esc, history, a partner's name (the character sheet about them), the action bar's "Character" button (the
player's own character sheet).

## Layout Specification

### ASCII Wireframe

```
+---------------------------------------------------------------+
| < >  Relationships                                        [x] |  R1 frame
| Ties 5 / 16 (+1 outside the cap) · Soft slots 3 / 12          |  R2 sticky header
| Room for 9 more soft ties or debts.                           |
| [search…  (Ctrl+F)]   (n of m match)                          |
| [Sort: kind ▾] (Pinned)(Feuds)(Soft ties and debts)(Met)      |
|---------------------------------------------------------------|
| PINNED (2)                                                    |  R3 body: a parchment inset per group
|  +-------------------------+ +-------------------------+      |
|  | (o) Trần Vân            | | (o) Mai Linh            |      |  two cards a row; (o) = portrait medallion
|  |     Trúc Cơ · Thanh Vân | |     Luyện Khí · loose   |      |
|  |     Tông · at Thanh Vân | |     cultivator · at …   |      |
|  |     warm +18            | |     friendly +40        |      |
|  |     [✎ Sư đồ (master)]  | |     [⚭ Đạo lữ (Dao …)]  |      |  [ ] = tie badge, wraps
|  +-------------------------+ +-------------------------+      |
| FEUDS (1)                                                     |
|  +-------------------------+                                  |
|  | (o) Hắc Sát             |                                  |
|  |     … · hostile -60     |                                  |
|  |     [🗡 Huyết thù · toward you · does not fade · inherited: |
|  |      your master was slain] [☁ Thù hận · firm ││ · toward   |
|  |      them] [☁ Thù hận · deep │││ · toward you]            |
|  +-------------------------+                                  |
| SOFT TIES AND DEBTS (2)  …                                    |
| MET, NO TIE (12)  (cards without badges, smaller medallion)   |
|---------------------------------------------------------------|
| [Character]                                                   |  R4 action bar
+---------------------------------------------------------------+
```

In the compact layout the cards are one a row.

### Layout Zones

| Zone | Holds | Scrolls |
|---|---|---|
| R1 Frame | Back, forward, title, close | No |
| R2 Sticky header | The cap line, the next eviction, search and its match count, sort, group chips | No |
| R3 Body | Four groups, each a parchment inset on the dark ground: Pinned; Feuds; Soft ties and debts; Met, no tie. Each group is a grid of cards sorted by the sort; an empty group shows "none" | Yes |
| R4 Action bar | Character | No |

(Round 1's wireframe skipped R4; the zones are now R1 to R4.)

**Card grid and compact layout**: two cards a row; one a row when the host's compact flag is on, which it sets when the
viewport is narrower than `compact_width` in `assets/data/ui_windows.json` (1500 px: 1280×720 is compact, 1920×1080 is
not). The window is 62 % of the screen wide. Text in a card wraps, never truncates, and the badges flow onto further
lines. The per-direction bands and the favour live in the badges, so the compact layout loses none of them.

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| R2 | Cap line | Text | "Ties 5 / 16" (Ties.cap; notable or ordinary), "+n outside the cap" (overflow pinned, mourner enmity), and **"Soft slots n / limit"** (rule 15c: soft-only records used out of `Ties.soft_limit`) | Tooltip: rule 5 (pinned never evicted; soft and debts compete) |
| R2 | Next eviction | Text | **Only when the soft slots are full**: "Next to go if a new tie forms: partner (kind, band)", the record rule 7 would evict next (weakest, then oldest, then lower id); otherwise "Room for n more soft ties or debts." | Tooltip: rule 7 |
| R2 | Search | LineEdit | Partner names (diacritics folded); matching cards stay full strength, others dim to 45 %; "n of m match" is a polite live region | Ctrl+F |
| R2 | Sort | Option | Kind (default), Strength, Name, Realm | Yes; persists for the screen |
| R2 | Group chips | Toggles | Pinned, Feuds, Soft ties and debts, Met no tie | Yes; persist; a filtered group keeps its heading with "hidden by the filter" (sections never vanish) |
| R3 | Group inset | Container (new pattern) | A parchment-toned box with the group heading and count, "Feuds (1)"; stays when filtered | No |
| R3 | Person card | Panel (new pattern) | One person: medallion on the left; on the right the name link, a line "realm · sect (or "loose cultivator") · at place" (a missing part is left out), the attitude line ("warm +18", band word and number, plus "· died" for the dead), then the tie badges. Tie cards use a 64 px medallion, met cards 52 px | The card is a focus stop and carries the tie tooltip |
| R3 | Portrait medallion | Image (new pattern) | The person's painted portrait (`PortraitPicker` from the `portrait` field) in a round brass ring, faded to grey for the dead; with no portrait, the `PlaceholderArt` stripes inside the ring with the tooltip "PLACEHOLDER · No portrait yet" (never a stand-in face) | Tooltip on a placeholder only |
| R3 | Name link | LinkButton | The partner's name (" †" when dead), tinted friend / hostile / neutral by attitude (+30 / −30); accessible name "Open <name>" | Enter / click: open their character sheet |
| R3 | Tie badge | Pill (new pattern) | One per tie kind on the person: the **glyph** per kind (GDD Visual: kin 家, sư đồ ✎, kết nghĩa 🍶, đạo lữ ⚭, companion 🚶, friend ☺, rival ⚔, ân tình ✋, enmity ☁, blood feud 🗡; a glyph, never colour alone), the kind in Vietnamese and English, the **band** (faint / firm / deep for strength 1–33 / 34–66 / 67–100) with one to three strokes (│ ││ │││, GDD Visual/Audio) for soft ties and debts, the **direction** in words (toward you / toward them; you owe / they owe); **an enmity held both ways is one badge per direction, each with its own band**; a blood feud shows "does not fade" (a pinned kind has no strength); "inherited: cause" when passed down (rule 1b). Tint: brass pinned kinds, cinnabar blood feud, dark red enmity, amber debt and favour, teal soft ties; tint is a backup cue only | None of its own; the card tooltip carries the detail |
| R3 | Favour badge | Pill + tooltip | "favour owed: <caller>" on a sworn sibling's card (amber); the card tooltip carries rule 15c's block: the state (**awaiting call-in**, with "presented and accepted are not recorded yet"), the call-in's timing (within `favour_call_seasons` of the join), what refusing costs (a slight: friend −`refuse_delta`, or enmity +`refuse_delta`) and the `favour_cost` in linh thạch that clears it. The tie record stores only the caller, so the state is always "awaiting call-in" until the call-in event stores it | Tooltip |
| R3 | Card tooltip | Tooltip | Title the partner, the realm, then one line per tie kind: the badge words, "strength n", the cause (when not inherited); the favour lines when owed. Tie cards only; met cards have none | Hover / Q |
| R3 | Met card | Card | A met person with no tie: the same card without badges, 52 px medallion | Name opens their sheet |
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
| Compact layout (viewport under 1500 px wide) | One card a row |
| No ties | "You hold no ties yet." above the groups |
| Full | The eviction line names the next record instead of "Room for n more" |
| Partner dead | The card keeps the tie (inherited ties live on the heir); the name gets " †", the attitude line "· died", the portrait is faded to grey |
| Portrait missing | The `PlaceholderArt` stripes inside the medallion ring, tooltip "PLACEHOLDER · No portrait yet" |
| No sect | The card line says "loose cultivator" |
| Search active | Matching cards full strength, others dimmed to 45 %; "n of m match" |
| Group filtered off | Heading kept, "hidden by the filter" |
| Relationships off in this build | One line: "Relationships are switched off in this build…" |
| Event waiting | Nothing to lock (the page has no actions) |

Not built: a portrait loading state (portraits are read when the card is built), and a "(record gone)" text (Open
Questions 9, 10).

## Interaction Map

| Input | Action |
|---|---|
| R | Open / close |
| Ctrl+F | Search |
| Tab, Shift+Tab | The search, sort, chips, then each card and its name link (Godot's default focus order) |
| Enter / click on a name | Open that person's character sheet |
| Q or hover on a tie card | The tie tooltip (the whole card is the target; badges have no tooltips of their own) |
| Esc | Close |

R, Q and other single-letter keys are off while the search field has focus (IME-safe).

Not built yet: Home / End and LT / RT section jumps (the window has no handlers of its own), and a specified Left /
Right / Up / Down order across the two columns (focus between cards follows Godot's default by position). See Open
Questions 4 and 5.

Every key is rebindable (hud.md Platform Adaptation).

## Data Requirements

One read, `GameQuery.relationships(s)`: {cap, held, outside_cap, soft_used, soft_limit, room, next_evict: {partner,
kind, band} or {}, ties: [{partner_id, partner, alive, realm, place, attitude, band_word, **sect**, **portrait**,
group (pinned / feud / soft), kinds: [{kind, band, strength, direction, inherited, cause, set_season}], favour,
favour_info}], met: [{id, name, realm, place, attitude, band_word, **sect**, **portrait**}]}, a copy, built with
`Ties` read functions (`ties_of`, `cap`, `soft_only`, `room`, `soft_s`, `debt_s`), which never write (GDD rule 3).
Re-read on open and after every job.

Presentation fields added with the illustration: `sect` is the sect's name or "" (shown as "loose cultivator");
`portrait` is the choice data `PortraitPicker` turns into a texture, `{}` when the person's record is gone (shown as
the placeholder). The glyph and the Vietnamese and English names of each kind come from `ui_windows.json`
(`tie_kinds`), not from the read. A missing `place` or `realm` leaves that part out of the card line.

## Events Fired

`open_requested("person", partner_id)` (the host opens the character sheet about that person, or the player's own
sheet), `open_requested("character")` (the action bar: the player's own sheet). The kind name `"person"` is the built
one, kept from the old person window; renaming it is a code change (Open Question 6).

## Transitions & Animations

None of its own; the host's slide becomes instant under reduced motion.

## Input Method Completeness Checklist

- [x] Keyboard: cards, names, sort and chips reachable; Ctrl+F
- [x] Mouse: everything clickable
- [ ] Gamepad: d-pad and A / B reach cards by Godot's default focus; LT / RT section jumps are not built (Partial)
- [x] No hover-only information: Q opens the tie tooltip; bands and directions are in the badge text

## Accessibility

Target Standard tier (`design/accessibility-requirements.md`, 2026-11-22). Text at the 16 px floor (tooltips 14 px),
checked at 75 % and 150 % UI scale; text contrast at least 4.5:1, glyphs and the focus ring 3:1; kind by glyph and
words, tint only as a backup; bands in words and strokes; directions in words; the attitude shows its band word beside
the number ("warm +18"); the dead are marked by "†" and the word "died", not only by the faded portrait.

Screen reader: a tie card reads each badge's words separated by semicolons, then the partner's name (for example
"Huyết thù (blood feud), toward you, does not fade, inherited: your master was slain, Hắc Sát"); an enmity held both
ways reads both directions with their bands; a met card reads "<name>, <realm>"; the name link reads "Open <name>"; the
cap line and eviction line read as text; the search count is a polite live region.

Gaps against this target, as built: contrast on the badge
tints and the parchment surfaces is unmeasured (Open Question 11); the portrait is not marked decorative for screen
readers (Open Question 8).

## Localization Considerations

Kind names in Vietnamese and English (the longest, "Dao companion / Đạo lữ", "blood feud / Huyết thù", fit at the base
font by wrapping); numbers follow the language; names wrap, never truncate (30 % longer text still fits by wrapping);
a badge wraps onto the next line of the flow rather than clipping. A partner whose record is gone: round 1 asked for
their id and "(record gone)"; not built (Open Question 10).

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.relationships` returns every tie record of the player with its kinds, band, direction,
      inherited mark and cause; the cap, held and outside-cap counts match `Ties`; it leaves `to_dict()` unchanged.
- [ ] `[GdUnit]` The next eviction is the record `Ties.room` would evict (when full) and "room for n" otherwise.
- [ ] `[GdUnit]` Every tie and met entry carries `sect` (a name or "") and `portrait`.
- [ ] `[GdUnit]` Groups come in the order Pinned, Feuds, Soft ties and debts, Met no tie; a group chip hides its group
      and keeps its heading.
- [ ] `[GdUnit]` Sorting by Strength orders soft cards by strength, strongest first.
- [ ] `[GdUnit]` A partner's name emits `open_requested("person", id)`.
- [ ] `[GdUnit]` A tie card shows the name, the realm, the sect or "loose cultivator", the place, the attitude with its
      band word, and one badge per tie kind; a met card shows the same without badges.
- [ ] `[GdUnit]` A group is a two-column grid, and one column when `compact` is true.
- [ ] `[GdUnit]` A card whose person has no portrait shows the `PlaceholderArt` medallion; a dead person's card shows
      "†", "died" and a faded medallion.
- [ ] `[GdUnit]` Every tie card's accessible name has each badge's kind words, the band and the direction, then the
      partner's name (never colour alone); the name link's accessible name is "Open <name>".
- [ ] `[GdUnit]` The header shows "Soft slots n / limit" from `Ties`; the eviction line appears only when the soft slots are full.
- [ ] `[GdUnit]` An enmity held both ways shows both directions with their bands; a feud badge says "does not fade".
- [ ] `[GdUnit]` A sworn sibling's favour badge and tooltip carry the favour block (state, refuse cost, buy-off cost).
- [ ] `[GdUnit]` The Relations entry turns every group back on and fills the search.
- [ ] `[GdUnit]` The read and build take under 50 ms for 16 ties and 200 met people (headless test machine). Opening
      the window with portraits is measured in the editor and recorded (no budget set yet, Open Question 9).
- [ ] `[Screenshot]` Retained in `production/qa/evidence/ui-windows/`: 1920×1080 (exists:
      `32-relationships-illustrated-1920x1080.png`), 1280×720 (compact; not retained yet), and 150 % and 75 % UI
      scale (not retained yet); nothing clips.

## Open Questions

1. Glyphs are text placeholders until the §7.1 dark-tile icons are painted (art budget).
2. Favour states (presented, accepted) are not stored in the tie record yet: the favour block says so and shows
   "awaiting call-in"; the call-in event (Event Engine) should store the state on the record.
3. (Resolved 2026-11-24.) The player's relationships section is this window, opened from the character sheet's
   Interact tab ("Relations") for any person, and from the Relationships button and R.
4. (Decided 2026-11-24, UI owner; the user may overrule: focus order across the two-column grid is row-major, Godot's
   default, accepted as built. Both the card and its name link stay focus stops.)
5. Section jumps (Home / End, LT / RT) are in the pattern library but the window has no handlers: build them or drop
   the pattern from this page.
6. (Decided 2026-11-24, UI owner; the user may overrule: the event kind stays `"person"`; the map screen routes it to
   the character sheet.)
7. (Closed 2026-11-24: tie and favour badges are 16 px, `relationships_window.gd` `_card`. A screenshot check that they
   still fit two cards a row is still owed.)
8. The portrait medallion is not marked decorative for screen readers (code change).
9. Open time with portraits has no budget and no measurement, and there is no portrait loading state (portraits are
   read synchronously when the card is built).
10. A partner whose record is gone: the card shows the placeholder portrait, but the "(record gone)" text is not built.
11. Contrast of the badge tints (brass, cinnabar, dark red, amber, teal) with their bone text, and of text on the
    parchment card and inset, is unmeasured.
12. Whether "Side panel with history" still fits a window 62 % of the screen wide, or `interaction-patterns.md` needs a
    "wide window" variant; and the new patterns (card, medallion, inset, badge) need adding to that library.
    (Done 2026-11-24: the library has "Person card", "Portrait frame and round medallion" and "Wood ground and
    parchment inset" entries, and a note on "Side panel with history" that illustrated windows may be wider.)
