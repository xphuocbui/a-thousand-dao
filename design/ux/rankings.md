# UX Spec: Rankings

> **Status**: In Review, lean round 2 NEEDS REVISION (2 blocking, 4 advisory: applied 2026-11-24; the code gaps are
> Open Questions 3–7); written 2026-11-24 night by Claude under the UI delegation (memory ui-design-delegated)
> **Illustrated rebuild (2026-11-24)**: the window is drawn in the illustrated style (user 2026-11-24, as the
> character sheet and sect window; no r3 mock-up exists for this screen, so the build itself is the reference): a
> podium of the top three, a portrait medallion on every row, the table in a parchment inset, a compact 1280×720
> layout, and a hover tooltip on the "You" line. Source: `src/ui/windows/rankings_window.gd`, `illustrated.gd`.
> **Author**: Claude (ux-designer role)
> **Last Updated**: 2026-11-24
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec (lean: the headings of `design/ux/person.md`)
> **GDDs read**: `design/gdd/power-rankings.md` (rule 9 rankings and the Vấn Đỉnh Bảng; rule 13 one season late;
> Formulas E the power number; UI Requirements), `design/ux/hud.md` (element 33: the rating box opens rankings)
> **Patterns used**: Side panel with history (HUD Z6), Sticky header, Searchable list (deviation below), Link styles,
> Nested lockable tooltip. **New, flagged for the library's Gaps** (not yet in `interaction-patterns.md`): the tab bar
> (toggle buttons; the Left / Right and Ctrl+Tab keys are not built, Open Question 3), the gap row (a focusable row
> standing for hidden rows; Enter or a click shows them), the podium (top-N cards over a table) and the illustrated
> inset (a parchment table with portrait medallions); the last two only if another list window reuses them.

---

## Purpose & Player Need

"Where do I stand, who is above me, and who is just within reach?" A realm's ranking by rating (power-rankings.md rule
9), the player's place highlighted, and the Vấn Đỉnh Bảng (the Summit-Asking List: Nguyên Anh and Hóa Thần together).
Read-only: ratings move by rated fights, shown one season late (rule 13).

## Player Context on Arrival

From the rating box (hud.md element 33: "click: rankings"), the Rankings button (Z2) or K; after a season whose
fights moved the player's rating; before choosing whom to challenge or avoid.

## Navigation Position

A Z6 window of the window host. A name opens that person's window (one step outside the host's history, as the
relationships page).

## Entry & Exit Points

| Entry | Opens at |
|---|---|
| Rating box, Rankings button, K | the player's realm tab, scrolled to the player's row |

Exits: × / Esc, history, a name (person window), the action bar (Character).

## Layout Specification

### ASCII Wireframe

```
+-------------------------------------------+
| < >  Rankings                         [x] |  K1 frame
| You: 120th of 835 Trúc Cơ · power ~1,510  |  K2 sticky header
| Shown one season late. Last season: 40 of 52 panels, 310 fights
| [Luyện Khí][Trúc Cơ][Kết Đan][Nguyên Anh][Hóa Thần][Vấn Đỉnh Bảng]
| [search…]                [Jump to me]     |
|-------------------------------------------|
|   (o)2nd      (O)1st       (o)3rd         |  podium: top three on dark wood
|  Name        Name         Name            |  (portrait, rank plaque, name,
|  sect·stage  sect·stage   sect·stage      |  sect · stage, power)
|  power 9,1   power 9,820  power 8,7       |
| +---------------------------------------+ |  parchment inset (K3 body, scrolls)
| |  #  (o) Name   Sect   Stage Power Fights |
| |  1  (o) Trần Vân Thanh Vân Hậu kỳ 9,820 24
| |  2  (o) ...                           | |
| |  …   ranks 51–114: 64 people (show)   | |
| | 119 (o) Lý Hàn    —   Sơ kỳ  1,560  6 | |
| |[120 ▶ (o) Lâm Phong — Sơ kỳ ~1,510  0]| |  (you, framed)
| | 121 ...                               | |
| |  …   ranks 126–835: 710 people (show) | |
| +---------------------------------------+ |
| [Character]                               |  K5 action bar
+-------------------------------------------+
```

(o) is a round portrait medallion. On the Vấn Đỉnh Bảng a Realm column sits after Sect. At 1280×720 (compact) the
tabs become one "Which ranking" dropdown, the podium is hidden and the Sect column is dropped (Compact state).

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| K2 | Your standing | Text | "You: 12th of 835 Trúc Cơ · power ~1,512" ("~" provisional, "(stale)" when the build moved since the last panel), plus "~ n still provisional" when others are; "You are not in this list (you are in …)" when the player is not in it; the off line when ratings are off | Hover tooltip "Your power number": what it is (Formulas E), rule 13's one-season lag, ~ and stale |
| K2 | Last batch | Text | "Last season: a of b panels, c fights" (the session's last rating batch), or nothing before the first season | No |
| K2 | Realm tabs | Toggle buttons | The five realms, then Vấn Đỉnh Bảng; the player's realm first selected. No count on a tab (dropped, Open Question 4). Compact: replaced by the "Which ranking" dropdown (below) | Yes by click and Tab/Enter; Left / Right and Ctrl+Tab are not built (Open Question 3) |
| K2 | Which ranking | Dropdown (OptionButton) | Compact layout only: the same six lists as the tabs, the current one selected | Yes; choosing opens that list |
| K2 | Search | LineEdit | Names (diacritics folded); searching lists every match from the whole ranking, not only the shown rows | Ctrl+F |
| K2 | Jump to me | Button | Scrolls to the player's row (on the player's tab; disabled elsewhere) | Yes |
| K3 | Podium | Three cards (hidden when compact, while searching, and when fewer than 3 rows) | Ranks 2, 1, 3 (the first raised and larger): portrait medallion, rank plaque ("1st"), name (person link; the player's own is "(you)" and not a link), "sect (or loose cultivator) · stage", "power ~n" (~ when provisional). Paper-on-brass text. **Built gaps**: no "(stale)" marker and no realm on the cards (Open Question 5) | The name opens the person; the card is also a focus stop with no action of its own (Open Question 5) |
| K3 | Table inset | Parchment panel | Holds the header row, rows and gap rows; on the dark wood ground | No |
| K3 | Header row | Text | #, (portrait), Name, Sect, **Realm (Vấn Đỉnh Bảng only)**, Stage, Power, Fights | No |
| K3 | Portrait medallion | Round image, 36 px | On every row and on each podium card; from the row's `portrait` (see Data Requirements). A missing portrait shows the `PlaceholderArt` stripes inside the ring, never a finished-looking stand-in | No |
| K3 | Rank rows | Rows | Rank, portrait, name (person link), sect or "—", **realm (on the Vấn Đỉnh Bảng tab only)**, stage, power number (Formulas E: 3 significant figures, thousands separators; whole numbers below 100; "~" provisional; "(stale)"; the order is by rating, so two neighbours can show the same rounded number), rated-fight count; Provisional people mixed in by their estimated rating and marked "~" (AC-PR-16, rule 9 as changed by the user 2026-11-24) | The name opens their window; tooltip: rating, base and offset |
| K3 | Your row | Row | The same, marked "▶ (you)" and highlighted by a frame as well as a tint | Focused on open |
| K3 | Gap rows | Focusable row | "… ranks a–b: n people (show)" between the top `rankings.top_rows` (50) and the `rankings.around` (5) rows either side of the player, and after them | Enter or a click shows that gap's rows |
| K3 | Off state | Text | "Power Rankings is off in this run." | No |

The tooltip follows the Nested lockable tooltip pattern; it shows the rating as base and offset (the numbers the
power number comes from). **Search deviation:** search lists only the matching rows with their true ranks instead
of dimming the rest, because most rows sit in closed gaps and a dimmed list would hide its matches.

### Information Hierarchy

1. The player's own place (header line and the highlighted row).
2. The top of the realm (who leads).
3. The neighbours (who is within reach).

## States & Variants

| State | What changes |
|---|---|
| Normal | As the wireframe |
| Compact (1280×720) | The tabs become the "Which ranking" dropdown; the podium is hidden (the table comes first); the Sect column is dropped (the sect is in the row's tooltip) |
| Podium hidden | While searching, when compact, and when the list has fewer than 3 rows |
| Player in another realm's tab | No "you" row; Jump to me disabled ("you are in Trúc Cơ") |
| Ratings off | The off line; tabs and search hidden |
| Search active | Only matching rows, with their true ranks; "n matches" |
| Gap expanded | The hidden rows of that gap show |
| Provisional | Rows marked "~", listed after the rated ones |
| Stale | A rated row whose build moved since its last panel: "(stale)" beside the power; it keeps its rating (rule 5) |
| Season resolving | The host does not read while a job runs: the window keeps the last view; it re-reads after the job |
| Empty realm | "Nobody is ranked here yet." (an empty realm, or an old save whose people are all provisional shows them, marked) |
| Player not listed | On another realm's tab, or on the Vấn Đỉnh Bảng below Nguyên Anh: "You are not in this list (you are in …)" |

## Interaction Map

| Input | Action |
|---|---|
| K | Open / close |
| Left / Right (on the tabs), Ctrl+Tab | **Not built** for the tabs (Open Question 3); Left / Right in the window host are the history |
| Ctrl+F | Search (built in the window) |
| Up / Down | Rows |
| Enter on a name | Open that person |
| Q on a row | Its tooltip |
| Enter on a gap row | Show its rows |
| Esc | Close |

Focus order as built: the tabs (compact: the dropdown), the search, Jump to me, the three podium name links (when shown),
the rows (gap rows included), the action bar; on open, the player's row. The podium cards are not focus stops
(`focus_mode` NONE; built 2026-11-24): their name link is the stop. **Duplication:** ranks 1–3 are still read twice
by a screen reader (podium, then table) (Open Question 5).

Every key is rebindable (hud.md Platform Adaptation); single-letter keys are off while the search has focus.

## Data Requirements

One read, `GameQuery.rankings(s, realm)` (realm 0–4, or "top" for the Vấn Đỉnh Bảng): {on, realm, title, total,
player_rank (0 when not in it), rows: [{rank, id, name, sect, stage, realm, portrait, power, rating, base, offset, state, n, age, you}],
last_batch: {panels, queued, panel_fights, pair_fights}}. It orders people as rule 9 does (rating, then rated fights,
then age, then id; Provisional after) but reads each person with `RatingService.peek_person`, which never writes
(ADR-0006 decision 1): opening the ranking runs no panel and marks nobody Stale. The window shows the top
`rankings.top_rows` and `rankings.around` either side of the player (ui_windows.json); search scans all rows. Spirit
beasts are never listed (rule 1). **The one-season lag (rule 13):** every rating read here is the stored value after
the last *applied* batch; the player's own row reads `RatingService.rating_of`, the same value as the HUD's rating box
(element 33), so the two always agree. "Last season" is that applied batch (panels run of those queued, fights).
`realm` is the realm's name (the Vấn Đỉnh Bảng's Realm column). `portrait` is the descriptor from
`GameQuery.portrait_of` (cast key, gender, age, realm, sect), built in `GameQuery`, not in the UI; the window turns it
into a texture with `PortraitPicker.texture_for`. When no portrait is installed (a named cast member without a
painting) the texture is null and `Illustrated.medallion` draws the `PlaceholderArt` stripes (ui-code.md rule).
Ordinary people get a generic type portrait, which is the design, not a stand-in.

## Events Fired

`open_requested("person", id)`, `open_requested("character")`.

## Transitions & Animations

None of its own; the host's slide is instant under reduced motion.

## Input Method Completeness Checklist

- [x] Keyboard: tabs, search, rows, gap rows (Enter), names, Jump to me
- [x] Mouse: everything clickable
- [x] Gamepad: d-pad, A / B, shoulders for tabs (Partial)
- [x] No hover-only information: the row shows the power and state in text

## Accessibility

Text at the 16 px floor (tooltips 14 px), checked at 75 % and 150 % UI scale; the player's row is marked by "▶ (you)"
and a frame (the board inset, 3:1 against the parchment), not tint alone; row text 4.5:1; the podium's paper-on-brass text must also reach 4.5:1 (unmeasured, Acceptance Criteria); provisional and stale are words or "~" with the tooltip saying so. Screen reader: a row
reads "12th, Lâm Phong, no sect, Sơ kỳ, power about 1,510, provisional, 0 rated fights, you"; tabs read their realm and "selected"; the standing line is
re-read after End turn.

## Localization Considerations

Ordinals and numbers follow the language ("12th" / "hạng 12"); names wrap; columns are a row of labels with fixed
minimum widths, so 30 % longer text wraps inside its column.

## Acceptance Criteria

- [ ] `[GdUnit]` `GameQuery.rankings` orders a realm as rule 9 (AC-PR-16's case), lists the player, not the Gone, and the
      top list is exactly Nguyên Anh and Hóa Thần; reading it leaves `to_dict()` unchanged and creates no rating record.
- [ ] `[GdUnit]` The window shows the top rows, a gap row, and the rows around the player; the player's row is marked.
- [ ] `[GdUnit]` Searching shows every match with its true rank, including rows hidden in a gap; the podium is hidden while searching (`Podium` absent) and with fewer than 3 rows.
- [ ] `[GdUnit]` Compact: the "Which ranking" dropdown reaches all six lists, with no Tab buttons, no podium and no Sect column.
- [ ] `[GdUnit]` A person with no portrait shows the `PlaceholderArt` stripes in the medallion, not a stand-in.
- [ ] `[GdUnit]` With ratings off the window shows the off line.
- [ ] `[GdUnit]` A name emits `open_requested("person", id)`.
- [ ] `[GdUnit]` The read of a 900-person realm takes under 100 ms (headless test machine).
- [ ] `[GdUnit]` The player's row shows the same power number as the rating box (`GameQuery.resources`).
- [ ] `[GdUnit]` The Vấn Đỉnh Bảng tab has a Realm column; a gap row expands on Enter.
- [ ] `[GdUnit]` The window opens (read + build) in under 150 ms on a 900-person realm.
- [ ] `[Screenshot]` 1280×720 (compact: dropdown, no podium) and 1920×1080 (podium, medallions, parchment inset, framed "you" row) with ratings on, and 75 % / 150 % UI scale; a long Vietnamese name wraps; nothing clips. Retained in `production/qa/evidence/` (none named for rankings there yet).
- [ ] `[Manual]` Contrast of the podium's paper-on-brass text and the row text on the parchment is at least 4.5:1.

## Open Questions

- **Deferred GDD item:** the "last fights that moved the offset" (power-rankings.md UI Requirements, Explain) are not
  stored per person; the tooltip shows base and offset only until they are.
- Challenging a ranked person (a duel verb) belongs to the person window's verbs, not here.
- **Not built yet (round 2), for a code change or the user's decision:**
  3. Left / Right on the tabs and Ctrl+Tab are not bound in `rankings_window.gd` (Left / Right in the host are the
     history). Bind them in the window, or drop them from this spec. Ctrl+F is built.
  4. (Dropped 2026-11-24, UI owner; the user may overrule: no count on each tab; the spec no longer promises one.)
  5. Built 2026-11-24: the podium cards are out of the focus order and the name link is the stop. Still not built:
     "(stale)" beside the power and the realm on the Vấn Đỉnh Bảng cards. Ranks 1–3 are heard twice by a screen
     reader; accept or hide the table rows' duplicates.
  6. (Done 2026-11-24: the library has a "Podium" entry (`RankingsWindow._podium`, hidden in compact) and covers the
     inset through "Wood ground and parchment inset". The tab bar entry covers the tab row; the gap row stays specified here only.)
  7. (Decided 2026-11-24, UI owner; the user may overrule: no GDD change; the podium and portraits are a UI detail,
     so `power-rankings.md` does not mention them.)
