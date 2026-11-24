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
- **Top bar** (#8, part): the date cartouche grows with its text (no longer cut by W); W and ≡ are socket-sized.
  Kept by decision: the renown box (Must Show, user 2026-11-23; "—" until renown is tracked); the rating shows "—" only
  in runs with rating fights off.
- **Window buttons** (#7, part): each built window's button has its painted medallion (9 icons, gen_ui_icons.py
  win_*, about $0.06); the column is wider; Quests, News and the unbuilt map modes (Sect, Qi, Prices) are hidden in
  play (`--show-unbuilt` shows them). Kept by decision: Z3 is the portrait only (user 2026-11-23).
- **Debug line on the map** (#9, part): "Greybox: LLM off." is gone (no LLM by design); a small dim "Dev: rating
  fights off for this run." shows only in such runs.
- **Map labels and markers** (#9): a great sect's name shrinks until it clears the others; place diamonds are sized and
  faded by rank on the far map (user: "good keep").
- **Sect loose view** (#15): great-sect cards with the seat's painting and Visit the seat… (`travel_place`); standing
  as a meter.
- **Overview** (#2): tu vi and rate on one line. **Outliner** (#7): one-row places, a one-line empty state.
  **Top bar** (#8): a 6 px rimmed cultivation strip. **Dropdowns** (#13): themed PopupMenu.
- **Populated evidence**: `--crowded` (with `--inventory-fixture`: 43 items, long names, a missing icon; with
  `--relationships-fixture`: 24 ties, 12 met). It caught a real bug: an unwrapped feud badge widened the Relationships
  window over the map's buttons (now wraps at 280 px).
- **Rankings change** (#10): a Change column (▲ / ▼ / = / new) from a per-season snapshot of each rating record
  (`RatingService.snapshot_prev`, just before a season's results land).
- **Đạo Đồ toolbar and minimap** (#11): the bar in Points / Search / Plan / View groups, the next point source in the
  points' tooltip, a click-to-move minimap. Found on the way: the side pane (6759a269) had moved the Đạo Đồ canvas
  above its bar; fixed (`GameWindow.body_area`), with a test.
- **Window sizes** (#5): written as a pattern, `design/ux/interaction-patterns.md` Window sizes (side panel, full
  screen, centre window; never past its share; pinned side panes; compact).

## Suggestions, ranked (not built)
| # | Weak point | Suggestion | Effort |
|---|---|---|---|
| 4 | Combat tab (rest) | icons per stat; equipped techniques and wards beside the groups: **after combat formations are built** (user 2026-11-24) | S |

Decided: wiki links keep the art bible's cinnabar (user 2026-11-24). Cross-window links in the header and
CommitButton as the one primary are in place where a window has a decision (sect); the rest have none.

Broader: a single **window template** (one-line header with title, tabs and close; content grid; pinned action bar;
scroll fade; the size rule), **hide everything not built** behind a dev flag, lead each window with **the one decision
the player is there for**, reuse the **mock-up's carved frame and tile sprites** on every window, and retake evidence
with a **populated test world** (long names, 40 items, 200 ties).

Note: the top bar, map labels and window-button column (#7, #8, #9) are HUD and map work; check with the provinces
session before changing them.
