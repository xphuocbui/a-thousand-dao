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

## Suggestions, ranked (not built)
| # | Weak point | Suggestion | Effort |
|---|---|---|---|
| 2 | Character Overview clips with no scroll cue | scroll fade + visible scrollbar on every clipped body; Tu vi / Rate onto one line under the bar | S |
| 4 | Combat tab is a bare table in a dark void | Offence / Defence / Utility cards with icon tiles and breakdown tooltips; explain values over 100 %; equipped techniques and wards beside | M |
| 5 | Window sizes and modes look arbitrary (Abode full screen with a narrow column, Inventory huge and empty, Wiki narrow) | one size rule: sheets and lists 60 % side panel, wiki and tree full screen, decisions centre window; Abode two-column or side panel | M |
| 6 | Inventory is a list, not an inventory | tile grid with rarity frames + an equipment paper-doll (5 base, 2 extra sockets) + detail card on selection | M |
| 7 | Map nav column and outliner cramped; dead Quests / News | icon + letter tiles for the window buttons; hide Quests / News until built; wider outliner with a one-line empty state; name and realm on the portrait | M |
| 8 | Top bar unlabeled, dead "—" slots, date clipped by the buttons | short labels or tooltips, hide empty slots, a real thin cultivation bar, a fixed date slot clear of W / ≡ | S |
| 9 | Map labels and markers fight; greybox debug line on the map | cap region label size inside its polygon, fade markers by importance and zoom, bigger player marker, move the debug line to a dev badge | M |
| 10 | Rankings say nothing at the start (all ~197, 0 fights) | a sticky "You" row, a change-since-last-season column, hide Stage on single-realm tabs, a visible provisional tint | M |
| 11 | Đạo Đồ toolbar overloaded; no orientation | split the toolbar (points / search / view), a minimap with the viewport and your path, brighter unallocated nodes, "Next:" into the points tooltip, Apply as the gold primary | L |
| 12 | Wiki is a link dump | two panes: categories + search on the left, the article on the right; one link colour that is not warning red | M |
| 13 | Actions and information look alike | three button tiers (primary, secondary, text), disabled as a hatched tint with a "why" tooltip, styled dropdowns, cross-window links in the header | M |
| 15 | Sect call to action below the fold | Join / Visit the seat pinned in the action bar; standing as a meter | S |

Broader: a single **window template** (one-line header with title, tabs and close; content grid; pinned action bar;
scroll fade; the size rule), **hide everything not built** behind a dev flag, lead each window with **the one decision
the player is there for**, reuse the **mock-up's carved frame and tile sprites** on every window, and retake evidence
with a **populated test world** (long names, 40 items, 200 ties).

Note: the top bar, map labels and window-button column (#7, #8, #9) are HUD and map work; check with the provinces
session before changing them.
