# Stage 6: Nhạn Trận Môn (`nhan_tran`) — progress file

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md` (decisions auto-accepted, user rule 2026-11-26).

## Scope (`python -I tools/design/world/depth_gap.py --sect nhan_tran`)
- **3 techniques:** `wild-geese-formation-canon` (Profound main, `names: []`), `spring-levy-drum` (Profound secret, `names: []`), `walking-out-of-the-grey` (Earth secret, `names: []`). Existing in lineage: `mountain-bone-body-art` (Yellow body, already in `design/techniques/catalogue-body.json`).
- **5 new arts:** `geese-stance`, `trading-the-point`, `close-the-file`, `one-breath-down-the-file`, `the-rear-guard-faces-back` (plus 2 existing refs: `mountain-root-stance`, `marching-dirge`).
- **6 items, 2 sets, 4 Effects:** `One Goose`, `Geese Line`, `Last Man in the File`, `Take the Wind`.
- **0 stand-ins, 0 beasts, 0 cross-owner refs, 4 structured events (`N-nhan_tran-01..04`).**

## Steps
- [x] 1. Verify first: mechanic table + `spatial_words_check.py --sect nhan_tran` (flagged ally-counting / `held_damage` / `banner` / `Piece` / `Displace` entries in `postponed-2026-11-26.json`; resolved via faithful 1v1 rewrites so the sect's main method and head/point sets run cleanly in 1v1, matching `phan_vu` / `truc_thuc`).
- [x] 2. Techniques and arts (staged):
      - `design/stage6-staging/nhan_tran/techniques/catalogue-sect-nhan_tran.json` (`names: []` supported directly in `lint_techniques.py`; tier-sized bonuses & passives; `b1` lines kept verbatim on `wild-geese-formation-canon`).
      - `design/stage6-staging/nhan_tran/arts/part-sect-nhan_tran.json` (5 element-free arts; `geese-stance` uses self-counter `geese_stance` instead of `s.state`/`tags: ["stance"]` to avoid colliding with `mountain-root-stance` and `marching-dirge`).
      - `design/world/depth/sects/nhan_tran.techniques.json` updated in place with `"id"` on all 5 new arts.
- [x] 3. Effects (staged): `design/stage6-staging/nhan_tran/effects/nhan_tran.effects.json` (all 4 Effects; every read/written counter declared locally; `STANDALONE_OK 4`).
- [x] 4. Items and sets (staged): `design/stage6-staging/nhan_tran/items/catalogue-sect-nhan_tran.json` (6 unique items, `sources: ["npc"]`, `rarity: 5` on treasure `nt-first-file-banner`, R6 `exception` on the 4 armour/shield/weapon pieces) and `sets-nhan_tran.json` (2 sets).
- [x] 5. Stand-ins: 0 open (`depth_gap.py`: `stand_ins 0`).
- [x] 6. Beasts: 0 (`nhan_tran` has no `beasts.json`).
- [x] 7. Holder check (`DEPTH_STAGE=design/stage6-staging/nhan_tran`):
      - `lint_arts.py`: 5 arts, 0 findings.
      - `lint_techniques.py`: 3 techniques (`16.0 W / 16`, `15.6 W / 16`, `22.5 W / 24`), 0 findings.
      - `lint_items.py`: 6 items (`unique 6 of 6`), 0 findings.
      - `depth_check.py --quiet`: `findings: none`.
      - `depth_gap.py --sect nhan_tran`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `lines 29/29 runs`.
      - `sect_fight.py nhan_tran --seeds 5` (`--gap 0` and `--gap 1`): `0 REFUSED`, all 5 new arts fire on real holders; targeted probes confirmed `Last Man in the File` poison/miasma cleanse, `Trading the Point` rotation, `One Breath Down the File` cleanse/pulse, and `Close the File` Wounded surge.
- [x] 8. Review file: `production/plans/stage6/nhan_tran-review.md`.
- [x] 9. Finish: `nhan_tran.done` written.

RECORD PASS DONE
