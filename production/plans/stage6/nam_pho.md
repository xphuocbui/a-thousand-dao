# Stage 6: Nam Phố Đường (`nam_pho`) — progress file

Method: `production/plans/stage6/_brief-record.md` (decisions auto-accepted, user rule 2026-11-26; staged in `design/stage6-staging/nam_pho/`).

## Scope (initial gap report `depth_gap.py --sect nam_pho`)
- 3 depth techniques (`mulberry-ink-primer`, `southern-shore-cloud-canon`, `painted-beams-dawn-flight`). Existing in lineage: `thorn-and-ink-verses` (`catalogue-soul-song-seal.json`).
- 7 depth new arts (`three-wet-sheets`, `blotting-paper`, `catch-the-morning-cloud`, `painted-rain`, `paper-beam`, `dawn-flight`, `dusk-curtain`).
- 6 items, 2 sets, 3 Effects (1 item: `Dawn Ink`; 2 set: `Paper Laid at Dawn`, `Roll Up the Western Rain`).
- 0 beasts, 0 stand-ins, 0 unknown_ids, 0 unmapped ties, 1 over-cap tie (`chau_phi_van`, already closed by game cap), 4 structured events (`N-nam_pho-01`..`04`).
- 3 cross-owner references to `nam_pho`'s methods (`gian_van_lo` in `loose-south`, `trinh_hong_tien` and `trinh_chu_sa` in `market-folk`): these close when `nam_pho`'s techniques are merged in Stage 7.
- `auth-mod.json` wish `b4` (`Painted Leaf`) already carried into `mulberry-ink-primer` and `southern-shore-cloud-canon` passives and `"talisman"` tags on all 7 arts.

## Steps
- [x] 1. Verify first: ran `depth_gap.py --sect nam_pho` (+ `--list` on all open sections) and `spatial_words_check.py --sect nam_pho` (0 real spatial hits; 4 soft commentary hits in `ties.note` and `build.tree.intent`). All mechanics map cleanly to existing engine words (`0` pending words).
- [x] 2. Techniques and arts (staged): wrote `design/stage6-staging/nam_pho/techniques/catalogue-sect-nam_pho.json` (3 techniques, tier budgets `8.0/8`, `15.9/16`, `23.9/24 W`) and `design/stage6-staging/nam_pho/arts/part-sect-nam_pho.json` (7 arts). Registered all 7 art ids in `design/world/depth/sects/nam_pho.techniques.json`.
- [x] 3. Effects (staged): wrote `design/stage6-staging/nam_pho/effects/nam_pho.effects.json` (3 Effects, all counters explicitly declared on each Effect for standalone GDScript compilation; `pending.json` empty).
- [x] 4. Items and sets (staged): wrote `design/stage6-staging/nam_pho/items/catalogue-sect-nam_pho.json` (6 items, `sources: ["npc"]`, `unique: true`, R6 `exception` on 5 weapon/robe pieces) and `design/stage6-staging/nam_pho/items/sets-nam_pho.json` (2 sets).
- [x] 5. Stand-ins: 0 needed (`stand_ins` gap = 0).
- [x] 6. Beasts: 0 (`nam_pho` has no `beasts.json`).
- [x] 7. Holder check (with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nam_pho`):
  - `lint_arts.py`: 7 arts, **0 findings**.
  - `lint_techniques.py`: 3 techniques, **0 findings** (`8.0/8`, `15.9/16`, `23.9/24 W`).
  - `lint_items.py`: 6 items, **0 findings** (`unique 6 of 6`).
  - `depth_check.py --quiet`: **findings: none**.
  - `depth_gap.py --sect nam_pho`: `stand_ins 0`, `unknown_ids 0`, `engine_words 0`, `wishes_open 0`, `lines 34/34 runs`.
  - Standalone Effect validation (`engine.validate` + counter declaration audit): **3/3 VALID**, **0 undeclared counters**.
  - `sect_fight.py nam_pho --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN** at `--gap 1`; all 7 arts fire and all 3 Effects run on their real holders (confirmed with 10-seed probe for `chau_phi_van` slotting `dawn-flight` + `dusk-curtain`).
- [x] 8. Review file: wrote `production/plans/stage6/nam_pho-review.md` (ending with `REVIEW DONE`).
- [x] 9. Finish: wrote `production/plans/stage6/nam_pho.done`.

RECORD PASS DONE
