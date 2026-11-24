# Combat formations (trận đồ) in the game, and the combat UI around them

Started 2026-11-24. User: "I want you to implement the formation system into our system now. Then redesign the combat ui
to accomodate the combat formation." Design: `design/gdd/formations.md` Part I (Approved 2026-11-21, rules 1-12, F1-F4,
F6). Owner: the UI-windows session (Claude); the provinces session (my-game-99) works in world / economy files.

## Decisions (user, 2026-11-24)

- **Catalogue**: Claude drafts a starter set by hand, the user approves it before it goes into
  `assets/data/crafting_diagrams.json` (GDD Open Question 4).
- **Acquisition v1**: taught only (công pháp manuals and sects); a new character knows one simple diagram besides the
  Plain Row. Crafting diagrams waits on Open Question 5.
- **NPCs**: player first. NPC choice (rule 12, `Diagrams.choose`) comes as a second step with a census and rating check,
  coordinated with the provinces session. Until then a data flag keeps NPCs on the default line.
- **Mock-ups first**: 2-3 low-quality OpenAI mock-ups of the combat UI (Combat tab as collection and editor, the fight
  screen's formation as a graph, lay or carry), the user picks, then build.

## What exists (checked 2026-11-24)

- `src/gameplay/crafting/diagrams.gd`: F1 strength, F2 fuel, F3 raise cost, F6 reservation, can_set, F4 place and
  choose, `apply` (node rules `mod`, `adj_mod`, `gate`; links `feed`, `adj`), `compile_for`, `prepare`, `pay_fuel`.
- `Character.diagram` holds the Set diagram {record, level, placement, lay}; saved.
- Only event fights apply it (`event_resolver.gd:153`). Not applied: rating panels (`rating_service.gd:243`), event odds
  trial fights (`event_resolver.gd:188`), the character sheet's combat rows (`game_query.gd:460`), practice fights /
  the fight screen (`game_query.gd:1091`). `build_sig` does not include the diagram (a change never marks Stale).
- `compile_for` gives an NPC with no diagram the best fit from the catalogue: an authored catalogue would turn NPCs on.
- No list of known diagrams; no node positions for drawing; the Python sim has no diagrams.
- Fight screen: a FORMATION row of plain slots with a "not built yet" tooltip.

## Plan

1. Mock-ups (OpenAI, low) and the catalogue draft (table + shape drawings) -> user approval. **Current step.** Draft:
   `design/formations/catalogue-draft-2026-11-24.json` + `.png` (8 diagrams, grades 0-2; drawn by
   `tools/design/render_diagram_draft.py`). Mock-ups: `prototypes/ui-mood/out/r4-editor-l.png`, `r4-fight-l.png`.
   **v2 → 50 (user 2026-11-24):** "be a bit more creative, lines don't have to always be straight ... fancy looking
   formations like in the movies ... each trận should have levels and additional slot" / "they don't always have to
   have levels ... I just don't want things to repeat" / "at least 38 more so it reaches 50". Now
   `design/formations/catalogue-draft-50-2026-11-24.json` + `.png` (authored by `tools/design/author_diagram_draft_v2.py`
   and `author_diagram_draft_more.py`, drawn by `render_diagram_draft_v2.py`): 50 diagrams, grades 0-4 (10 / 15 / 13 /
   7 / 5); 27 grow by level, 19 strength only, 4 one level. Record additions: node `unlock`, link `unlock` and `bend`,
   per-diagram `max_level`, `figure` (drawing). GDD change owed: rules 1, 3, 7 (levels can open nodes and links; each
   diagram its own max level).
2. Data: the approved catalogue with node `pos` for drawing, `npc_use: false`, `starter` id, `cost_lt`; a catalogue
   validation test (indices, N against slot counts, reserve against the cap, rule and read vocabulary).
3. Model: `Character.known_diagrams`; the starter taught at character creation; manuals teach (`teaches_diagram`);
   session actions set_diagram / place_art / set_lay; `build_sig` includes the diagram; every compile path applies it
   (sheet, rating panel, practice, trial fights); GameQuery reads (collection, editor, fight record).
   **Picks (user 2026-11-24):** round 4 rejected ("looks really bad", with the in-game fight screen); round 5:
   Combat tab **A** (`prototypes/ui-mood/out/r5-tab-a-l.png`: formations as shape medallions left, the board with level
   pips centre, arts right, the price tiles and combat numbers below); fight screen **B** liked but "a bit too big, will
   cover everything else" -> **B2** (`out/r5-fight-b2-l.png`: per column portrait + gauges ~20 %, the formation board ~40 %,
   wards / items / buffs / debuffs / status / numbers ~40 %); user: "go".
   **Built 2026-11-24:** data (50, npc_use false, starter, cost_lt), GDD rules 1, 3, 7 + OQ4 closed, engine (levels open
   nodes and links, own max_level, catalogue by id, compile_read on the sheet / practice / odds paths, the rating panel
   payload, build_sig), session actions (learn_diagram, set_diagram, place_diagram_art, set_diagram_lay; the starter at
   new game and on load), reads (GameQuery.formations, diagram_view, the fight record's diagram and portrait),
   FormationBoard (src/ui/formations/), the Combat tab editor (mock-up A), the fight screen (B2). Tests: catalogue
   validation, levels, session actions, the editor. Left: raising a diagram's level (F3, the abode; UX OQ 1), teaching
   by sects and manuals (only the starter and learn_diagram exist), drag and drop, the per-node tally (GDD OQ 9), the
   NPC step (npc_use, census).
4. UX spec `design/ux/diagram-editor.md` (the GDD's UX flag), then the Combat tab as collection + editor, then the fight
   screen's FORMATION row as a graph with feeds and polarity marks; remove the stale tooltip.
5. Evidence: a diagram set in real play, a feed firing in the log, the max-node case with long names at 1920x1080 and
   1280x720; reshoot the Đạo Đồ, Abode and fight screens after any shared-code change.
6. NPC step (separate, later): `npc_use` on, census + ratings, with the provinces session.

## Open (GDD) questions left at their defaults
- OQ 8 (a different preset for ambush and blind fights): no, one Set diagram.
- OQ 10 (a feed that makes an art ready at once): no, feeds floor at `cooldown_min`.
- OQ 9 (per-node contribution tally): with the UX spec.

## Teaching (2026-11-24, user: "approve" the teaching draft)
Hand-assigned per sect (`assets/data/sects_teaching.json`), contribution by grade, rank by grade; the sect window's
"Formations taught" list (members and outsiders); `GameSession.sect_teach_check` / `learn_sect_diagram`; formation
manuals (`ItemFactory.diagram_manual`, kind `diagram_manual`, rarity grade + 1, icon `assets/icons/items/diagram_manual.png`)
from 25 % of event công pháp drops (`Diagrams.manual_pick`, keyed stream), read with `learn`; wiki "Formations" pages
(rules, levels, where learned). The special five wait for events. Back-link owed: Sects rule 19a (services) should
name formation teaching.

