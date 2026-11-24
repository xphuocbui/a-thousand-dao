# UI weak points and suggestions (2026-11-24)

Source: a fresh-eyes review of 12 screenshots (`production/qa/evidence/ui-windows/review-2026-11-24/`) against the
CK3 / EU5 / Victoria 3 bar and the approved round-3 mock-ups (`prototypes/ui-mood/out/r3-*.png`); the full report is in
the session scratchpad (`reviews/weakpoints.md`). User asked: "keep on doing the uiux polishing and reviewing, also,
find weakpoints and suggestions on how to improve them".

## Done the same day
- **Unbuilt verbs read as a spec** (review #1): the Interact tab shows only the verbs the game runs (Greet) as buttons;
  the planned ones are one muted "Coming later" line (`CharacterWindow.BUILT_VERBS`).
- **Header repeats the name three times** (#3): the sheet's sticky header is one line (name · age · rating) plus the tabs.
- **Sect tiles miss what a chooser needs** (#15, part): tiles are Path, Craft, Members (since year), Treasury; the
  regions held are a line; the seat's look from the place catalogue is the lore card.
- **Emoji tie glyphs and ASCII bars** (#14, part): 11 painted tie icons (`assets/icons/ui/tie_*.png`, gen_ui_icons.py)
  in the badges; strength as pips ●○○ / ●●○ / ●●●.
- **Screenshot runs went fullscreen** (found while reviewing): fullscreen is set in `map_screen._ready` for play only.
- **Inventory is a list** (#6): a tile grid per kind (fixed 64 px icon, two-line name, rarity frame, gold edge when
  equipped, count in the icon's corner), an Equipped panel with every gear slot and empty sockets (GameQuery.inventory
  "slots"), and a Selected panel with the item large, its facts, comparison and verbs, both in a pinned side pane
  (`GameWindow.use_side`) that stays in view while the bag scrolls (Selected heads the body at 1280x720); focus moves
  to the first usable verb and back to the tile on Esc; `--inventory-fixture` for shots.
- **Combat tab is a bare table** (#4, part): Defence / Offence / Sustain / Resistances groups of tiles at full width,
  a hint per stat; fixed two unit bugs (Block and typed resistances are points, not shares: "Block 391 %" was 3.91).
- **Actions and information look alike** (#13, part): disabled buttons on parchment are a flat faint outline with
  readable muted text (no longer a dimmed live plaque; on the wood HUD over the map the opaque dimmed plaque stays), and every disabled one carries its reason in the tooltip; links to another
  window (`GameWindow.bar_open`) are the third tier, `TextButton`: text with a ›, underlined on hover.
- **Bodies clip with no scroll cue** (#2, part): every window body shows a dark fade with a ▾ over its bottom edge
  while more lies below (`GameWindow._update_scroll_cue`).
- **Sect call to action below the fold** (#15, part): the action bar leads with the one decision, a gold Join ↓ for an
  outsider at a seat (its reason when not open) or Promote ↓ for a member, scrolling to where the confirm is
  (`GameWindow.bar_jump`).
- **Abode: a narrow column hiding the whole map** (#5, part): the Abode is two columns (home, clamps, build on the
  left; the works on the right) in a 1440 px parchment column (`GameWindow.column_width`, capped by the screen), so it
  fits one screen without scrolling.
- **Wiki is a link dump** (#12, part): two panes, a pinned Contents side pane (categories; on the index each jumps to its
  section, on an entry its own category opens with its neighbours) and the index or the article on the right; the wiki
  is a 62 % side panel like the sheets.
- **Rankings at the start** (#10, part): provisional rows are tinted only among rated rows, so a new world's table is
  not dimmed throughout.

## Suggestions, ranked (not built)
| # | Weak point | Suggestion | Effort |
|---|---|---|---|
| 2 | Scroll cue (rest) | Tu vi / Rate onto one line under the bar | S |
| 4 | Combat tab (rest) | icons per stat; equipped techniques and wards beside the groups | S |
| 5 | Window sizes (rest) | one size rule: sheets and lists 60 % side panel, wiki and tree full screen, decisions centre window; the loose Sect view half empty; (the Abode's clamp lines now hide the "(Formula B)" reference in a tooltip) | M |
| 7 | Map nav column and outliner cramped; dead Quests / News | icon + letter tiles for the window buttons; hide Quests / News until built; wider outliner with a one-line empty state; name and realm on the portrait | M |
| 8 | Top bar unlabeled, dead "—" slots, date clipped by the buttons | short labels or tooltips, hide empty slots, a real thin cultivation bar, a fixed date slot clear of W / ≡ | S |
| 9 | Map labels and markers fight; greybox debug line on the map | cap region label size inside its polygon, fade markers by importance and zoom, bigger player marker, move the debug line to a dev badge | M |
| 10 | Rankings (rest) | a change-since-last-season column needs a per-season rank snapshot (a Power Rankings data change, not UI only) | M |
| 11 | Đạo Đồ toolbar overloaded; no orientation | split the toolbar (points / search / view), a minimap with the viewport and your path, brighter unallocated nodes, "Next:" into the points tooltip, Apply as the gold primary | L |
| 12 | Wiki (rest) | links are the art bible's on-parchment term colour (cinnabar #84191B), which the review read as warning red: **a style decision for the user** | S |
| 13 | Buttons (rest) | styled dropdowns; cross-window links in the header; CommitButton as the one primary per window | S |
| 15 | Sect (rest) | Visit the seat from the loose view; standing as a meter | S |

Broader: a single **window template** (one-line header with title, tabs and close; content grid; pinned action bar;
scroll fade; the size rule), **hide everything not built** behind a dev flag, lead each window with **the one decision
the player is there for**, reuse the **mock-up's carved frame and tile sprites** on every window, and retake evidence
with a **populated test world** (long names, 40 items, 200 ties).

Note: the top bar, map labels and window-button column (#7, #8, #9) are HUD and map work; check with the provinces
session before changing them.
