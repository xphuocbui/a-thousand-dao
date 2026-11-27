# Stage 6: Sương Tùng Các (`suong_tung`, progress file)

Brief: `production/plans/stage6/_brief-record.md` (headless record pass, batch `b05`, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect suong_tung`)
- **3 proposal techniques:** `pine-paper-talisman-primer` (Tier 0 main, Wood+Water, outer), `frost-pine-ward-canon` (Tier 1 main, Wood+Water, inner), `lantern-ward-art` (Tier 1 secret, Wood+Water, elders/head). Existing: `thorn-and-ink-verses` (committed in `catalogue-soul-song-seal.json`).
- **4 new active arts:** `frost-sheet`, `laid-ward` (`d15, a1`), `frost-on-the-pine`, `cold-night-lamp`. Existing referenced arts: `ambush-talisman`, `lamp-oil-lance`.
- **3 signature items, 1 set, 3 Effects:** `st-cold-night-lantern` (`The Light That Stays`), `st-hundred-wards-flag` (`Sheets in the Wind`), `st-lantern-maker-brush`, set `st-lamp-and-brush` (`Ward Written Inside`).
- **0 stand-ins, 0 beasts, 0 cross-owner references, 3 structured events (`N-suong_tung-01..03`).**

## Steps
- [x] 1. Verify first: mechanic table, `spatial_words_check.py --sect suong_tung`, uniqueness check across `combat_effects.json`, `design/`, and `design/stage6-staging/`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/suong_tung/`, art ids inserted in `suong_tung.techniques.json`).
- [x] 3. Effects (staged in `design/stage6-staging/suong_tung/effects/suong_tung.effects.json`).
- [x] 4. Items and sets (staged under `design/stage6-staging/suong_tung/items/`, `pending.json` empty).
- [x] 5. Stand-ins (none needed: 0).
- [x] 6. Beasts (none: 0).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\suong_tung`):
      - `lint_arts.py`: 4 arts, 0 findings (`frost-sheet empower 1: x1.04 of the lint, gated`).
      - `lint_techniques.py`: 3 techniques, 0 findings (`7.2/8`, `15.8/16`, `15.4/16 W`).
      - `lint_items.py`: 3 items, 0 findings (`unique 3 of 3`).
      - `depth_check.py --quiet`: findings: none.
      - `spatial_words_check.py --sect suong_tung` + staged scan: 0 real spatial hits (only "Flag of a Hundred Wards" item-name `"flag"` false positives).
      - Standalone `engine.validate`: 3/3 VALID, `missing_counters=[]`.
      - `sect_fight.py suong_tung --seeds 5` (`--gap 0` and `--gap 1`): 0 REFUSED, 0 NEVER_FIRED, 0 NEVER_RAN across all 16/16 living members.
- [x] 8. Review file (`production/plans/stage6/suong_tung-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` and `production/plans/stage6/suong_tung.done`).

RECORD PASS DONE
