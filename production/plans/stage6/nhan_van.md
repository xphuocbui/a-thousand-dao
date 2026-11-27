# Stage 6: Nhàn Vân Quán (record pass, progress file)

Brief: `production/plans/stage6/_brief-record.md` (OWNER = nhan_van). Headless/delegated job, decisions auto-accepted (user, 2026-11-26) and logged in `production/plans/stage6/nhan_van-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/nhan_van/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect nhan_van`)
- 4 depth techniques: `ink-grinding-primer` (Yellow main, Water+Wood), `idle-cloud-reflection-canon` (Profound main, Water), `living-scroll-art` (Profound secret, Wood+Water, `authored: a1`), `old-reflection-art` (Earth secret, Water).
- 7 new arts in depth text: `wet-stroke`, `cloud-in-the-pool`, `upside-down-sky`, `door-guardian`, `ink-rain`, `ink-sediment`, `sky-of-a-moment-ago`. 2 existing ref arts: `backwash-seal`, `deep-lake-stance`.
- 6 items (`nv-plain-silk-scroll`, `nv-cloud-washing-brush`, `nv-pool-house-mirror`, `nv-upside-down-sky-scroll`, `nv-one-cloud-robe`, `nv-mothers-portrait-brush`), 2 sets (`nv-idle-cloud`, `nv-mothers-sky`), 3 Effects (`The Scroll Before the Painting`, `Paint It Back`, `Figure on the Clouds`).
- 27 modifier lines (all 27 already run in `fight.py`).
- 0 stand-ins; 0 beasts; 0 unknown_ids; 0 cross_owner refs.
- No prior `design/techniques/catalogue-sect-nhan_van.json` existed.

## Steps
- [x] 1. Verify first: mechanic table logged in `nhan_van-review.md` §A. `spatial_words_check.py --sect nhan_van` checked (only rename/soft prose notes in `nhan_van.techniques.json` and cast notes).
- [x] 2. Techniques and arts (staged): 4 techniques (`7.6/8`, `15.3/16`, `15.4/16`, `23.4/24 W`), 7 new arts; all 7 art IDs inserted in place into `design/world/depth/sects/nhan_van.techniques.json`.
- [x] 3. Effects (staged): 3 entries in `effects/nhan_van.effects.json` (each declaring all counters it reads/writes for standalone GDScript compilation); empty `pending.json` (0 new engine words needed).
- [x] 4. Items and sets (staged): 6 items (`unique: true`, `sources: ["npc"]`, R6 `exception` on `cham`/`dao_bao`, `rarity: 5` on treasure `nv-plain-silk-scroll`), 2 sets.
- [x] 5. Stand-ins: none (`stand_ins: 0`).
- [x] 6. Beasts: none (`beasts: 0`).
- [x] 7. Holder check: `lint_arts.py` (0 findings), `lint_techniques.py` (0 findings), `lint_items.py` (0 findings), `depth_check.py` (findings: none), `depth_gap.py --sect nhan_van` (`stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`), standalone compile check (3/3 Effects PASS), sub-record fire probe (caught and fixed `Paint It Back` `paint_back_used` 0→1→2 arming so 50 % rewind fires exactly once per fight), `sect_fight.py nhan_van --seeds 5` and `--gap 1 --seeds 5` (0 REFUSED, all arts fire at gap 0, all 3 Effects run).
- [x] 8. Review file: `production/plans/stage6/nhan_van-review.md` (ending with `REVIEW DONE`).
- [x] 9. Finish: `RECORD PASS DONE` appended and `production/plans/stage6/nhan_van.done` written.

## Exact commands (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nhan_van"`)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/nhan_van/techniques/catalogue-sect-nhan_van.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/nhan_van/items/catalogue-sect-nhan_van.json`
- `python -I tools/design/world/depth_check.py`
- `python -I tools/design/world/depth_gap.py --sect nhan_van`
- `python -I tools/design/combat_sim/sect_fight.py nhan_van --seeds 5`
- `python -I tools/design/combat_sim/sect_fight.py nhan_van --gap 1 --seeds 5`

RECORD PASS DONE
