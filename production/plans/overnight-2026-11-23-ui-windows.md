# Overnight 2026-11-23/24: UI windows (session my-game-ff)

User (2026-11-23 night): "please start implementing missing ui panels and features ... start with the 10 ... there's
another session working in the same repo in this machine, please communicate with it accordingly. Imma go to sleep,
please run overnight". Working mode: `production/plans/ui-greybox-build.md` (UI delegated; ask only big decisions).

## Agreements (with the map/provinces session my-game-b3)
- No commits tonight (CLAUDE.md: commits need the user's go). Morning: commit own paths only, with index blobs where a
  file also holds the peer's hunks (memory commit-own-paths-only).
- Peer works in worktree `C:\Users\xphuo\IdeaProjects\my-game-provinces` (branch provinces-v2). Its uncommitted alive
  layer in main stays untouched: assets/data/ui_hud.json, assets/map/terrain/*, design/ux/hud.md, src/ui/map/*,
  the map_screen.gd hunks in `_shot_and_quit` and `_refresh_map`, tests/unit/ui/ui_map_alive_test.gd, bake_data.py.
- Do not build a province panel (peer has one on provinces-v2); leave a hook in the window list.
- My settings live in a new `assets/data/ui_windows.json`, not ui_hud.json.
- Godot processes: at most 3 mine; together under 8. Test reports in my own dir.

## Backlog (in order)
1. Character sheet (Z6 window, replaces the text panel) + the shared Z6 window host (history back/forward, sticky
   header, section jumps, focus return) + `--open-window=<kind>` for shot runs
2. Game menu (≡): save, load, settings (UI scale, reduced motion, language), quit
3. Inventory
4. Relationships
5. Rankings
6. Sect window
7. Abode (full screen)
8. Wiki
9. Outliner + Borders toggle
10. Đạo Đồ in-game view (full screen, one custom-draw canvas with culling)
Quests and News: no engine systems: left disabled.

Per window: lean spec (person.md headings) -> one headless /ux-review round -> apply -> GameQuery reads (structured,
pure; added to session_reads_test) -> window -> unit tests -> frontend-rule test + UI suite -> shots at 1280x720 and
1920x1080 -> tick the Component Inventory -> update ui-greybox-build.md.
Rules: no new game rules or engine commands without logging a question; a window whose action has no GameSession
command ships read-only and the gap is logged.

## Own paths (for the morning commit)
New files (all mine): design/ux/character-sheet.md, design/ux/game-menu.md, assets/data/ui_windows.json,
src/ui/windows/{game_window,window_host,character_window,game_menu}.gd (+ .uid), src/ui/settings/player_settings.gd (+ .uid),
tests/unit/ui/{ui_window_host_test,ui_character_window_test,ui_game_menu_test}.gd (+ .uid),
production/qa/evidence/ui-windows/*.png, production/plans/overnight-2026-11-23-ui-windows.md.
Shared files with my hunks: src/ui/greybox/map_screen.gd (peer hunks: production/session-state/peer-alive-map_screen.patch;
commit = current file with that patch reversed), src/gameplay/session/game_query.gd, tests/unit/session/session_reads_test.gd,
src/ui/fight/fight_screen.gd (settings_requested), production/plans/ui-greybox-build.md, .godot/global_script_class_cache.cfg
(generated; peer's alive_layer class too).

## Progress log
- 1 Character sheet + window host: DONE. Spec lean r1 NEEDS REVISION -> 11 findings applied. Tests: host 6, character 9,
  reads +2 (10 total), frontend rule 1: green. Shots 01-03.
- 2 Game menu + settings: DONE. Spec lean r1 NEEDS REVISION (5 blocking) -> all applied. PlayerSettings
  (user://settings.cfg; memory-only in test runs), save/load as jobs with meta files (user://saves/meta), settings-only
  variant on Esc in a fight, Ctrl+S / Ctrl+L, F1, gamepad Select / View (map_screen _unhandled_input).
  Tests: ui_game_menu_test 10. Shots 10-11.
- 3 Inventory: DONE. Spec lean r1 NEEDS REVISION (3 blocking) -> applied. Tests 13 + reads 11. Shots 20-21.
  New: src/ui/windows/inventory_window.gd, tests/unit/ui/ui_inventory_window_test.gd, design/ux/inventory.md.
- 4 Relationships: DONE. Spec lean r1 NEEDS REVISION (3 blocking) -> applied. Tests 8 + reads 12. Shots 30-31.
  New: src/ui/windows/relationships_window.gd, tests/unit/ui/ui_relationships_window_test.gd, design/ux/relationships-page.md.
  Also touched: src/ui/windows/person_panel.gd (Relations button + signal).
- 5 Rankings: DONE. Spec lean r1 NEEDS REVISION (4 blocking) -> applied. Tests 7 + reads 13. Shots 40-41. UI folder 157/157.
  New: src/ui/windows/rankings_window.gd, tests/unit/ui/ui_rankings_window_test.gd, design/ux/rankings.md.
  QUESTION for the user: rule 9 lists provisional after rated, so a new player shows "1st of 1 rated" above 3,935 provisional NPCs.
- 6 Sect: DONE. Spec lean r1 NEEDS REVISION (3 blocking) -> applied. Tests 6 + reads 13. Shots 50-51.
  New: src/ui/windows/sect_window.gd, tests/unit/ui/ui_sect_window_test.gd, design/ux/sect-window.md.
- 7 Abode (full screen): DONE. Spec lean r1 NEEDS REVISION (5 blocking) -> applied. Tests 8 + reads 14. Shots 60-62.
  New: src/ui/windows/{full_screen_host,abode_screen}.gd, tests/unit/ui/ui_abode_screen_test.gd, design/ux/abode-screen.md.
- 8 Wiki: DONE. Spec lean r1 NEEDS REVISION (4 blocking) -> applied. Tests 5. Shots 70-71.
  New: src/ui/windows/{wiki_data,wiki_window}.gd, tests/unit/ui/ui_wiki_test.gd, design/ux/wiki.md.
- 9 Outliner + Borders: DONE. Spec lean r1 NEEDS REVISION (3 blocking) -> applied. Tests 7 + reads. Shot 80.
  New: src/ui/hud/{outliner_panel,outliner_pins}.gd, tests/unit/ui/ui_outliner_test.gd, design/ux/outliner.md.
  QUESTION for the user: outliner pins live in a UI file until the save format carries them (ADR).
- 10 Đạo Đồ view: DONE. User (mid-run): "don't we just use v5 ... do something similar to" the viewer artifact; the canvas
  draws v5 in the viewer's palette and Stats colouring (icons deferred to release per 2026-11-20). Spec r1 NEEDS REVISION
  (5 blocking), applied. Tests 8 + reads 15. Shots 90-91.
  New: src/ui/dao_do/dao_do_canvas.gd, src/ui/dao_do/dao_do_screen.gd, tests/unit/ui/ui_dao_do_test.gd, design/ux/dao-do-view.md.
- Final checks (2026-11-24): full parallel suite 983 cases in 24 groups, all green (JOBS=3); UI folder 191/191 on the
  latest code; headless --window-actions-smoke: all 16 window commands reach the session (2 ok, 14 refused with reasons;
  the abode's commands were unwired until this pass). Peer patch reverse-applies cleanly. NOT done: the windowed demo
  (60 checks, 7 updated for the window host) needs the user's OK to drive the mouse. Every new spec is "In Review" after
  one lean round (none approved). Abode grade-3 evidence is a fixture shot.
