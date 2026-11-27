# Stage 6: Trúc Thực Viên (`truc_thuc`) progress file

Method: `production/plans/stage6/_brief-record.md` (`OWNER = truc_thuc`, headless/delegated job, decisions auto-accepted).

## Scope (`depth_gap.py --sect truc_thuc`, 2026-11-27)
- 3 depth techniques (`rain-on-bamboo-breath`, `flooded-field-verse`, `sixty-year-flower`) + 1 new servants' method (`furrow-iron-breath`). Existing lineage main: `verdant-cycle-scripture` (`catalogue-wood.json`).
- 6 depth new arts + 1 new servants' art (`turn-the-furrow`).
- 6 items, 2 sets, 4 Effects (2 item, 2 set).
- 2 stand-ins (`phi_dong_canh`, `ngo_le_thach`), 0 beasts, 5 structured events, 0 cross-owner refs.
- Spatial check hits: `warm-the-grove` (`allies`, `ally` — 1v1 rewrite to "you" per `DECISIONS-2026-11-26.md`).

## Steps
- [x] 1. Verify first: mechanic table built; `spatial_words_check.py` checked; `rooted-form` stance conflict identified and resolved.
- [x] 2. Techniques and arts staged (`design/stage6-staging/truc_thuc/techniques/catalogue-sect-truc_thuc.json`, `arts/part-sect-truc_thuc.json`); art ids and `furrow-iron-breath` registered in `design/world/depth/sects/truc_thuc.techniques.json`.
- [x] 3. Effects staged (`design/stage6-staging/truc_thuc/effects/truc_thuc.effects.json`): all 4 Effects self-declare every counter id they read or write for GDScript standalone compilation.
- [x] 4. Items and sets staged (`design/stage6-staging/truc_thuc/items/catalogue-sect-truc_thuc.json`, `items/sets-truc_thuc.json`).
- [x] 5. Stand-ins resolved (`phi_dong_canh` and `ngo_le_thach` -> `furrow-iron-breath` in `truc_thuc.cast.json` and `truc_thuc.5.cast.json`).
- [x] 6. Beasts: none (`truc_thuc` has 0 beasts).
- [x] 7. Holder check: `lint_arts.py` (0 findings), `lint_techniques.py` (0 findings), `lint_items.py` (0 findings), `depth_check.py --quiet` (findings: none), `depth_gap.py --sect truc_thuc` (`stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `lines: 28/28`), standalone Effect validation (4/4 OK), `sect_fight.py truc_thuc` (`--seeds 5`, `gap 0` and `gap 1`, 0 REFUSED, all 7 new arts fire and all 4 Effects run), plus 10-seed Fire+Wood and sub-record probes.
- [x] 8. Review file (`production/plans/stage6/truc_thuc-review.md`, ends with `REVIEW DONE`).
- [x] 9. Finish (`production/plans/stage6/truc_thuc.done` written).

RECORD PASS DONE
